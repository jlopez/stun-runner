"""Write the 6502 source's names, comments and classification into the IDA database (docs/05 s. 6).

    uv run python -m ida.headless.sync            # dry run on a copy: the changes, per category
    uv run python -m ida.headless.sync --write    # apply to data/stunrun-jsa.i64 and save
    uv run python -m ida.headless.sync --list     # dry run, and print every change

`make ida-sync` is the dry run, `make ida-sync WRITE=1` the write; then `make ida-export` and
commit data/ida/stunrun-jsa.*. The source (asm/jsa) is the truth and the database follows it:
`ida.jsa_source` says what the source carries, and this module makes the database say the same.

- **Classification.** Every data statement is a data item of its size and type, every
  instruction an instruction (`ida.jsa_source`); whatever IDA had there is undefined first.
- **Functions.** A function starts at every routine label; a function IDA ran into from the
  routine before is ended there first. A function IDA has at another address is reported, not
  deleted (auto-analysis makes it again on the next `make ida`).
- **Names.** Every global label and equate is the IDA name at its address, every `_local` a local
  name. A user name the source does not have, in any segment of the database, is deleted (the
  source wins) and reported.
- **Comments.** The source's comments replace the database's: regular, repeatable, function
  and anterior comments the source does not carry are deleted, everywhere in the database.

Idempotent: a second run reports no change, and so does a run after `make ida` (the snapshot
carries all of the above).
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

from ida.headless import DATA, database
from ida.jsa_source import TREE, Source, load
from ida.memory_map import DATABASES
from ida.snapshot import DataItem, ida_generated_comment

CATEGORIES = (
    "data",
    "code",
    "functions",
    "names",
    "names deleted",
    "locals",
    "locals deleted",
    "function comments",
    "repeatable comments",
    "comments",
    "anterior comments",
)
SPEC = DATABASES["jsa"]


class Sync:
    def __init__(self, src: Source, write: bool) -> None:
        self.src = src
        self.write = write
        self.counts: dict[str, int] = defaultdict(int)
        self.changes: list[str] = []
        self.skipped: list[str] = []
        self.extra_functions: list[str] = []

    def note(self, category: str, msg: str) -> None:
        self.counts[category] += 1
        self.changes.append(f"{category}: {msg}")

    def run(self) -> None:
        import ida_auto

        self.classify()
        if self.write:
            ida_auto.auto_wait()
        self.functions()
        if self.write:
            ida_auto.auto_wait()
        self.names()
        self.locals()
        self.comments()
        if self.write:
            ida_auto.auto_wait()

    # classification ------------------------------------------------------------------------

    def classify(self) -> None:
        import ida_bytes
        import ida_ua

        from ida.headless.idadb import IdaDatabase

        db = IdaDatabase()
        for item in self.src.data:
            current = db.data_item(item.ea)
            if current != item:
                self.note(
                    "data", f"{item.ea:06X} {describe_item(current)} -> {describe_item(item)}"
                )
                if self.write:
                    db.create_data(item)
        for ea, size in self.src.code:
            flags = ida_bytes.get_flags(ea)
            if ida_bytes.is_code(flags) and ida_bytes.is_head(flags):
                if ida_bytes.get_item_size(ea) == size:
                    continue
            self.note("code", f"{ea:06X} instruction ({self.src.where.get(ea, '')})".rstrip())
            if self.write:
                ida_bytes.del_items(ea, ida_bytes.DELIT_SIMPLE, size)
                if ida_ua.create_insn(ea) != size:
                    self.skipped.append(f"{ea:06X}: create_insn did not make a {size}-byte insn")

    # functions -----------------------------------------------------------------------------

    def functions(self) -> None:
        import ida_funcs
        import idautils

        from ida.headless.idadb import IdaDatabase

        db = IdaDatabase()
        wanted = set(self.src.functions)
        names = self.src.global_names()
        for ea in sorted(wanted, reverse=True):
            func = ida_funcs.get_func(ea)
            if func is not None and func.start_ea == ea:
                continue
            inside = "" if func is None else f", inside the function at {func.start_ea:06X}"
            self.note("functions", f"{ea:06X} {names.get(ea, '')}{inside}")
            if self.write:
                db.add_function(ea)
                if ida_funcs.get_func(ea) is None or ida_funcs.get_func(ea).start_ea != ea:
                    self.skipped.append(f"{ea:06X} {names.get(ea, '')}: add_func failed")
        self.extra_functions = [
            f"{ea:06X} {names.get(ea, '(no label)')}"
            for ea in idautils.Functions()
            if ea not in wanted
        ]

    # names ---------------------------------------------------------------------------------

    def names(self) -> None:
        import ida_name

        from ida.headless.idadb import IdaDatabase

        want = self.src.global_names()
        current = {n.ea: n.name for n in IdaDatabase().names() if not n.local}
        changes = []
        for ea in sorted(set(want) | set(current)):
            cur, new = current.get(ea, ""), want.get(ea, "")
            if cur == new:
                continue
            if new:
                self.note("names", f"{ea:06X} {cur or '(none)'} -> {new}")
            else:
                self.note("names deleted", f"{ea:06X} {cur} (not in the source)")
            changes.append((ea, new))
        if self.write:
            flags = ida_name.SN_NOWARN | ida_name.SN_NOCHECK
            for ea, _ in changes:  # first out of the way, so that a name can move
                ida_name.set_name(ea, "", flags)
            for ea, new in changes:
                if new and not ida_name.set_name(ea, new, flags):
                    self.skipped.append(f"{ea:06X} {new}: set_name failed")

    def locals(self) -> None:
        import ida_funcs
        import ida_name

        from ida.headless.idadb import IdaDatabase, local_name

        want = {}
        for ea, name in self.src.local_names().items():
            if self.write and ida_funcs.get_func(ea) is None:  # (a dry run makes no function)
                self.skipped.append(f"{ea:06X} {name}: a local outside every IDA function")
                continue
            want[ea] = name
        current = {n.ea: n.name for n in IdaDatabase().names() if n.local}
        changes = []
        for ea in sorted(set(want) | set(current)):
            cur, new = current.get(ea, ""), want.get(ea, "")
            if cur == new:
                continue
            if new:
                self.note("locals", f"{ea:06X} {cur or '(none)'} -> {new}")
            else:
                self.note("locals deleted", f"{ea:06X} {cur} (not in the source)")
            changes.append((ea, new))
        if self.write:
            flags = ida_name.SN_NOWARN | ida_name.SN_NOCHECK | ida_name.SN_LOCAL
            for ea, _ in changes:
                ida_name.set_name(ea, "", flags)
            for ea, new in changes:
                if new and (not ida_name.set_name(ea, new, flags) or local_name(ea) != new):
                    self.skipped.append(f"{ea:06X} {new}: set_name (local) failed")

    # comments ------------------------------------------------------------------------------

    def comments(self) -> None:
        import ida_bytes
        import ida_funcs
        import ida_lines
        import ida_segment
        import idautils

        from ida.headless.idadb import extra_comment_lines, set_extra_comment_lines

        want: dict[tuple[int, str], str] = {(c.ea, c.kind): c.text for c in self.src.comments}
        functions = set(idautils.Functions())
        for (ea, kind), _ in want.items():
            if self.write and kind == "function" and ea not in functions:
                self.skipped.append(f"{ea:06X}: a function comment without the function")
        eas = {ea for ea, _ in want}
        for i in range(ida_segment.get_segm_qty()):
            seg = ida_segment.getnseg(i)
            for ea in range(seg.start_ea, seg.end_ea):
                flags = ida_bytes.get_flags(ea)
                if ida_bytes.has_cmt(flags) or ida_bytes.has_extra_cmts(flags):
                    eas.add(ea)
        for ea in sorted(eas | functions):
            for kind, repeatable in (("regular", False), ("repeatable", True)):
                cur = ida_bytes.get_cmt(ea, repeatable) or ""
                new = want.get((ea, kind), "")
                if cur != new:
                    category = "repeatable comments" if repeatable else "comments"
                    self.note(category, f"{ea:06X} {describe(cur, new)}")
                    if self.write and not ida_bytes.set_cmt(ea, new, repeatable) and new:
                        self.skipped.append(f"{ea:06X}: set_cmt failed")
            if ea in functions:
                func = ida_funcs.get_func(ea)
                for kind, repeatable in (("function", False), ("function_repeatable", True)):
                    cur = ida_funcs.get_func_cmt(func, repeatable) or ""
                    new = want.get((ea, kind), "")
                    if cur != new:
                        self.note("function comments", f"{ea:06X} {kind}: {describe(cur, new)}")
                        if self.write:
                            ida_funcs.set_func_cmt(func, new, repeatable)
            for kind, base in (("anterior", ida_lines.E_PREV), ("posterior", ida_lines.E_NEXT)):
                cur_lines = extra_comment_lines(ea, base)
                new_text = want.get((ea, kind), "")
                new_lines = new_text.split("\n") if new_text else []
                if ida_generated_comment("\n".join(cur_lines)):
                    cur_lines = []  # the loader's lines at address 0: IDA's, not the source's
                if cur_lines != new_lines:
                    self.note(
                        "anterior comments",
                        f"{ea:06X} {kind}: {len(cur_lines)} -> {len(new_lines)} lines",
                    )
                    if self.write:
                        set_extra_comment_lines(ea, base, new_lines)


def describe_item(item: DataItem | None) -> str:
    if item is None:
        return "(no data item)"
    return f"{item.type} x{item.count}{' offset' if item.offset else ''}"


def describe(cur: str, new: str) -> str:
    def short(s: str) -> str:
        s = s.replace("\n", " | ")
        return repr(s[:50] + ("..." if len(s) > 50 else ""))

    if not cur:
        return f"added {short(new)}"
    if not new:
        return f"deleted {short(cur)}"
    return f"{short(cur)} -> {short(new)}"


def sync(path: Path, src: Source, write: bool) -> Sync:
    with database(path, write=write):
        s = Sync(src, write)
        s.run()
    return s


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("--write", action="store_true", help="apply and save (else a dry run)")
    ap.add_argument("--list", action="store_true", help="print every change")
    ap.add_argument("--db", type=Path, default=DATA / f"{SPEC.name}.i64", help="the database")
    ap.add_argument("--tree", type=Path, default=TREE, help="the 6502 source tree")
    ap.add_argument("--check", action="store_true", help="exit 1 when a change is found")
    args = ap.parse_args(argv)
    src = load(args.tree)
    print(
        f"source: {len(src.global_names())} names, {len(src.local_names())} locals, "
        f"{len(src.functions)} functions, {len(src.comments)} comments, {len(src.data)} data "
        f"items, {len(src.code)} instructions; {len(src.loose)} comment blocks at no address, "
        f"{len(src.left_out)} labels IDA cannot carry"
    )
    result = sync(args.db, src, args.write)
    print(f"changes ({'written' if args.write else 'dry run, nothing written'}):")
    for k in CATEGORIES:
        print(f"  {k:<20} {result.counts.get(k, 0)}")
    print(f"  {'total':<20} {sum(result.counts.values())}")
    if args.list:
        for c in result.changes:
            print("  " + c)
        print("comment blocks at no address:")
        for x in src.loose:
            print("  " + x)
    for title, rows in (
        ("labels IDA cannot carry", src.left_out),
        ("IDA functions at no routine label (kept)", result.extra_functions),
        ("not done", result.skipped),
    ):
        print(f"{title} ({len(rows)}):")
        for row in rows:
            print("  " + row)
    if args.write:  # idalib holds one database per process: the second run is a child
        print("second run, dry:", flush=True)
        cmd = [sys.executable, "-m", "ida.headless.sync", "--check", "--db", str(args.db)]
        again = subprocess.run([*cmd, "--tree", str(args.tree)], check=False)
        if again.returncode != 0:
            return 1
    if result.skipped:
        return 1
    return 1 if args.check and sum(result.counts.values()) else 0


if __name__ == "__main__":
    sys.exit(main())
