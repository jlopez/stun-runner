"""The `ida.snapshot.Database` protocol over the open idalib database.

Import only after `idapro` (that is, inside `ida.headless.database()` or `create_database`).
"""

from __future__ import annotations

import sys
from collections.abc import Iterable

import ida_bytes
import ida_funcs
import ida_lines
import ida_loader
import ida_name
import ida_offset
import ida_segment
import ida_ua
import idautils

from ida.snapshot import Comment, DataItem, Name, Segment

_BITNESS = {16: 0, 32: 1, 64: 2}
_CREATE = {
    "byte": ida_bytes.create_byte,
    "word": ida_bytes.create_word,
    "dword": ida_bytes.create_dword,
}


def warn(message: str) -> None:
    print(f"warning: {message}", file=sys.stderr)


class IdaDatabase:
    """`image` is the file the database was made from (needed only to add segments with bytes)."""

    def __init__(self, image: bytes | None = None) -> None:
        self.image = image

    # segments
    def segments(self) -> list[Segment]:
        out = []
        for i in range(ida_segment.get_segm_qty()):
            seg = ida_segment.getnseg(i)
            fpos = ida_loader.get_fileregion_offset(seg.start_ea)
            out.append(
                Segment(
                    seg.start_ea,
                    seg.end_ea,
                    ida_segment.get_segm_name(seg),
                    ida_segment.get_segm_class(seg),
                    {v: k for k, v in _BITNESS.items()}[seg.bitness],
                    None if fpos < 0 else fpos,
                    ida_segment.get_segment_cmt(seg, False) or "",
                )
            )
        return out

    def add_segment(self, segment: Segment) -> None:
        seg = ida_segment.getseg(segment.start)
        if seg is None or seg.start_ea != segment.start or seg.end_ea != segment.end:
            new = ida_segment.segment_t()
            new.start_ea, new.end_ea = segment.start, segment.end
            new.bitness = _BITNESS[segment.bitness]
            new.sel = ida_segment.setup_selector(0)
            new.align, new.comb = ida_segment.saRelByte, ida_segment.scPub
            new.type = ida_segment.SEG_CODE if segment.sclass == "CODE" else ida_segment.SEG_DATA
            flags = ida_segment.ADDSEG_NOSREG | ida_segment.ADDSEG_QUIET
            if not ida_segment.add_segm_ex(new, segment.name, segment.sclass, flags):
                raise RuntimeError(f"cannot add segment {segment}")
            if segment.file_offset is not None:
                if self.image is None:
                    raise RuntimeError(f"segment {segment.name} needs the image bytes")
                size = segment.end - segment.start
                chunk = self.image[segment.file_offset : segment.file_offset + size]
                if len(chunk) != size:
                    raise RuntimeError(f"segment {segment.name} runs past the image")
                ida_loader.mem2base(chunk, segment.start, segment.file_offset)
            seg = ida_segment.getseg(segment.start)
        ida_segment.set_segm_name(seg, segment.name)
        ida_segment.set_segm_class(seg, segment.sclass)
        if segment.comment:
            ida_segment.set_segment_cmt(seg, segment.comment, False)

    # names
    def names(self) -> list[Name]:
        """The user names of the name list (the global ones) and the local names of every
        function (IDA keeps those out of the name list)."""
        out = [
            Name(ea, name)
            for ea, name in idautils.Names()
            if ida_bytes.has_user_name(ida_bytes.get_flags(ea))
        ]
        for start in idautils.Functions():
            func = ida_funcs.get_func(start)
            for chunk_start, chunk_end in idautils.Chunks(func.start_ea):
                for ea in idautils.Heads(chunk_start, chunk_end):
                    if local_name(ea):
                        out.append(Name(ea, local_name(ea), True))
        return out

    def set_name(self, ea: int, name: str, local: bool = False) -> None:
        if not local:
            if not ida_name.set_name(ea, name, ida_name.SN_NOWARN):
                warn(f"cannot name {ea:06X} {name}")
            return
        # A global (or dummy) name first goes: IDA 9.1 does not turn it into a local name.
        ida_name.set_name(ea, "", ida_name.SN_NOWARN)
        ida_name.set_name(ea, name, ida_name.SN_NOWARN | ida_name.SN_LOCAL)
        if local_name(ea) != name:
            warn(f"cannot name {ea:06X} {name} (local)")

    # functions
    def function_starts(self) -> list[int]:
        return list(idautils.Functions())

    def add_function(self, ea: int) -> None:
        func = ida_funcs.get_func(ea)
        if func is not None and func.start_ea == ea:
            return
        if func is not None:
            make_room_for_function(ea)
        if not ida_funcs.add_func(ea):
            warn(f"cannot create a function at {ea:06X}")

    # comments
    def comments(self, eas: Iterable[int]) -> list[Comment]:
        candidates = set(eas)
        for i in range(ida_segment.get_segm_qty()):
            seg = ida_segment.getnseg(i)
            for ea in idautils.Heads(seg.start_ea, seg.end_ea):
                if ida_bytes.has_cmt(ida_bytes.get_flags(ea)):
                    candidates.add(ea)
        out = []
        for i in range(ida_segment.get_segm_qty()):
            seg = ida_segment.getnseg(i)
            for ea in idautils.Heads(seg.start_ea, seg.end_ea):
                if ida_bytes.has_extra_cmts(ida_bytes.get_flags(ea)):
                    candidates.add(ea)
        for ea in sorted(candidates):
            for kind, repeatable in (("regular", False), ("repeatable", True)):
                text = ida_bytes.get_cmt(ea, repeatable)
                if text:
                    out.append(Comment(ea, kind, text))
            func = ida_funcs.get_func(ea)
            if func is not None and func.start_ea == ea:
                for kind, repeatable in (("function", False), ("function_repeatable", True)):
                    text = ida_funcs.get_func_cmt(func, repeatable)
                    if text:
                        out.append(Comment(ea, kind, text))
            anterior = extra_comment_lines(ea, ida_lines.E_PREV)
            if anterior:
                out.append(Comment(ea, "anterior", "\n".join(anterior)))
        return out

    def set_comment(self, comment: Comment) -> None:
        if comment.kind == "anterior":
            set_extra_comment_lines(comment.ea, ida_lines.E_PREV, comment.text.split("\n"))
            return
        if comment.kind in ("regular", "repeatable"):
            ida_bytes.set_cmt(comment.ea, comment.text, comment.kind == "repeatable")
            return
        func = ida_funcs.get_func(comment.ea)
        if func is None or func.start_ea != comment.ea:
            warn(f"function comment at {comment.ea:06X} without a function")
            return
        ida_funcs.set_func_cmt(func, comment.text, comment.kind == "function_repeatable")

    # data items
    def data_item(self, ea: int) -> DataItem | None:
        flags = ida_bytes.get_flags(ea)
        if not ida_bytes.is_data(flags) or not ida_bytes.is_head(flags):
            return None
        for kind, test in (
            ("byte", ida_bytes.is_byte),
            ("word", ida_bytes.is_word),
            ("dword", ida_bytes.is_dword),
        ):
            if test(flags):
                width = {"byte": 1, "word": 2, "dword": 4}[kind]
                count = ida_bytes.get_item_size(ea) // width
                return DataItem(ea, kind, count, bool(ida_bytes.is_off0(flags)))
        return None

    def create_data(self, item: DataItem) -> None:
        width = {"byte": 1, "word": 2, "dword": 4}[item.type]
        ida_bytes.del_items(ea=item.ea, flags=ida_bytes.DELIT_SIMPLE, nbytes=width * item.count)
        if not _CREATE[item.type](item.ea, width * item.count):
            warn(f"cannot create {item}")
            return
        if item.offset:
            ida_offset.op_plain_offset(item.ea, 0, 0)

    def data_items(self, start: int, end: int) -> list[DataItem]:
        out = []
        for ea in idautils.Heads(start, end):
            item = self.data_item(ea)
            if item is not None:
                out.append(item)
        return out

    def code_ranges(self, start: int, end: int) -> list[tuple[int, int]]:
        out: list[tuple[int, int]] = []
        for ea in idautils.Heads(start, end):
            if not ida_bytes.is_code(ida_bytes.get_flags(ea)):
                continue
            item_end = ida_bytes.get_item_end(ea)
            if out and out[-1][1] == ea:
                out[-1] = (out[-1][0], item_end)
            else:
                out.append((ea, item_end))
        return out

    def create_code(self, start: int, end: int) -> None:
        ea = start
        while ea < end:
            flags = ida_bytes.get_flags(ea)
            if not (ida_bytes.is_code(flags) and ida_bytes.is_head(flags)):
                # at most one 6502 instruction's length, never past the range
                ida_bytes.del_items(ea, ida_bytes.DELIT_SIMPLE, min(3, end - ea))
                if not ida_ua.create_insn(ea):
                    warn(f"cannot create an instruction at {ea:06X}")
                    return
            ea = ida_bytes.get_item_end(ea)


def local_name(ea: int) -> str:
    """The local name at `ea`, or ''. IDA keeps local names out of the name list, and the plain
    name of the address is '' or, on the last instruction of a function that returns, still the
    dummy `locret_` (IDA 9.1: the user-name flag stays clear there), never the local name."""
    if ida_name.is_in_nlist(ea):
        return ""
    name = ida_name.get_ea_name(ea, ida_name.GN_LOCAL)
    return name if name and name != ida_name.get_ea_name(ea) else ""


def make_room_for_function(ea: int) -> None:
    """End the function whose main body or tail holds `ea` there, so that a function can start
    at `ea` (a source routine that IDA's flow analysis ran into from the routine before)."""
    func = ida_funcs.get_func(ea)
    if func is None or func.start_ea == ea:
        return
    tail = ida_funcs.get_fchunk(ea)
    if tail is not None and tail.start_ea != func.start_ea:
        ida_funcs.remove_func_tail(func, tail.start_ea)
        return
    ida_funcs.set_func_end(func.start_ea, ea)


def extra_comment_lines(ea: int, base: int) -> list[str]:
    out = []
    for i in range(1000):
        line = ida_lines.get_extra_cmt(ea, base + i)
        if line is None:
            break
        out.append(line)
    return out


def set_extra_comment_lines(ea: int, base: int, lines: list[str]) -> None:
    ida_lines.delete_extra_cmts(ea, base)
    for i, line in enumerate(lines):
        ida_lines.update_extra_cmt(ea, base + i, line)
