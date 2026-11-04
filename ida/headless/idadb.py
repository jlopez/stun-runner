"""The `ida.snapshot.Database` protocol over the open idalib database.

Import only after `idapro` (that is, inside `ida.headless.database()` or `create_database`).
"""

from __future__ import annotations

import sys
from collections.abc import Iterable

import ida_bytes
import ida_funcs
import ida_loader
import ida_name
import ida_offset
import ida_segment
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
        return [
            Name(ea, name)
            for ea, name in idautils.Names()
            if ida_bytes.has_user_name(ida_bytes.get_flags(ea))
        ]

    def set_name(self, ea: int, name: str) -> None:
        if not ida_name.set_name(ea, name, ida_name.SN_NOWARN):
            warn(f"cannot name {ea:06X} {name}")

    # functions
    def function_starts(self) -> list[int]:
        return list(idautils.Functions())

    def add_function(self, ea: int) -> None:
        func = ida_funcs.get_func(ea)
        if func is not None and func.start_ea == ea:
            return
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
        return out

    def set_comment(self, comment: Comment) -> None:
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
