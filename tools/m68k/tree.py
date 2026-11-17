"""The checks on the committed 68k tree (M5c, docs/16-68k-code.md section 4).

Since M5c the 68k code is source in `asm/68k` and the generator is frozen, so the checks run on
the tree's own listing (`build/stunrun-68k.lst` and `.out`, or the tree assembled against any
blob, as CI does), not on scratch output:

- the descent check of docs/14 section 5.3 over the whole listing: seeds from the source's own
  `dc.l`/`dc.w a-b`, the vectors, `game_entries`, the classification's entries with evidence and
  the reviewed seeds; every instruction statement reached unless `unreached` of
  data/68k/seeds.json lists it; and every instruction start of the classification is an
  instruction statement (code turned back into a blob or data fails), and, conversely, every
  instruction statement is a classified instruction start, so a range the classification does
  not call code cannot become instructions without a reviewed seed and `make classify`
  (decision C8): a `dc.l` naming it, which seeds the descent, is not enough;
- the address lint over 000000-0C0000 (docs/14 section 5.3); a reference into `images.asm` or
  `image_table.asm`, which this tree's code files do not own, is written as the label there plus
  an offset (`tbl_BFE00+$64`, decision C10) and counted;
- the raw-data check: in the code files (000000-012F06, 020000-046AEE) every `dc`/`dcb`
  statement is one of the kinds the generator emits for explained bytes: `dc.l` in a vector or
  pointer table, `dc.w a-b` in a switch table, `dc.b` of quoted strings and zeros in text, a
  `dcb.b N,0` fill. A `dc.b` wall in place of an `incbin` slice of unknown or data bytes fails
  (decision C3), and so does a string that starts with a record field (a count or an item
  byte, `record_field`) or ends with one (the next screen record's first header byte,
  `trailing_field`); in any file, a quoted `dc.b` that starts before the text field of a
  record of `classify.TEXT_RECORDS` (audio_test_list's command word, `record_word`) fails too;
- the shift test: the tree copied, its guards commented out, a two-byte pad after `org 0` (and
  every `dcb.b $X-*` fill kept at its length), assembled again: exactly the statements that name
  a ROM symbol other than PC-relatively or as a difference change, each by the pad;
- with MAME's run files of `make pccov`: every executed PC starts an instruction statement.
"""

from __future__ import annotations

import re
import shutil
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

from . import classify as cl
from . import listing as ls
from . import pccov as pc

ROM_END = 0x0C0000
CODE_FILES = [(0x000000, 0x012F06), (0x020000, 0x046AEE)]
# files this tree's code does not own: a reference into them is label + offset (decision C10)
FOREIGN = {"dat_60000": (0x060000, 0x0BFE00), "tbl_BFE00": (0x0BFE00, 0x0C0000)}
FOREIGN_REF = re.compile(r"(?<![\w.])(" + "|".join(FOREIGN) + r")\+")
STRING = re.compile(r"^(?:'(?:[^']|'')*'|\"[^\"]*\"|0|\$0)$")
FILL = re.compile(r"^dcb\.b\s+(?:\$?[0-9A-Fa-f]+|\$[0-9A-Fa-f]+-\*)\s*,\s*0$", re.I)


@dataclass
class TreeReport:
    descent: ls.DescentReport = field(default_factory=ls.DescentReport)
    lint: ls.LintReport = field(default_factory=ls.LintReport)
    raw: list[str] = field(default_factory=list)
    missing_code: list[int] = field(default_factory=list)
    extra_code: list[int] = field(default_factory=list)
    foreign: list[str] = field(default_factory=list)
    shift: ls.ShiftReport | None = None
    pccov: dict[str, list[int]] = field(default_factory=dict)

    def errors(self) -> list[str]:
        out = list(self.descent.errors)
        out += [f"{x:06X}: an instruction statement nothing reaches (list it under `unreached` "
                f"in data/68k/seeds.json with an argument, or make it data)"
                for x in self.descent.unreached]
        out += self.lint.errors + self.lint.undecided + self.raw
        out += [f"{x:06X}: a classified instruction start that is no instruction statement"
                for x in self.missing_code]
        out += [f"{x:06X}: an instruction statement that is no classified instruction start "
                f"(promoting a range to code needs a reviewed seed in data/68k/seeds.json and "
                f"make classify, decision C8)" for x in self.extra_code]
        if self.shift is not None:
            out += self.shift.errors
        for run, bad in self.pccov.items():
            out += [f"{x:06X}: executed in the {run} run, not an instruction statement"
                    for x in bad]
        return out


def in_code_files(a: int) -> bool:
    return any(lo <= a < hi for lo, hi in CODE_FILES)


def _unquote(op: str) -> str:
    return op[1:-1].replace("''", "'") if op.startswith("'") else op[1:-1]


def record_field(ops: list[str]) -> str:
    """Why a text statement's first characters are record fields, or "": an unterminated string
    whose first or second character is a count of the characters after it (or one more than
    them), or a terminated one whose first character is a lower-case item byte before
    upper-case text: the classifier's rules (classify._counted, classify.ITEM_PREFIX) on the
    source, so that a hand edit cannot put the field back into the string."""
    if not ops or ops[0] in ("0", "$0"):
        return ""
    s = _unquote(ops[0]).encode("latin-1")
    if len(ops) == 1:
        for p in (0, 1):
            c, n = s[p] if p < len(s) else 0x100, len(s) - p - 1
            if c <= cl.COUNT_MAX and n >= cl.TEXT_MIN and c in (n, n - 1):
                return f"character {p + 1} is the count of the {n} after it"
    elif cl.ITEM_PREFIX.match(s):
        return "the lower-case first character is an item byte before upper-case text"
    return ""


def record_word(address: int) -> str:
    """Which record of classify.TEXT_RECORDS a string at `address` would start inside."""
    for base, end, stride, off, why in cl.TEXT_RECORDS:
        if base <= address < end and (address - base) % stride < off:
            return (f"byte {(address - base) % stride} of the record at "
                    f"{address - (address - base) % stride:06X} is no character: {why}")
    return ""


def trailing_field(ops: list[str], address: int, binary: bytes) -> str:
    """Why an unterminated counted string's last character is the first byte of the next
    screen record's header (classify.trailing_header on the source and the image), or ""."""
    if len(ops) != 1 or not ops[0].startswith(("'", '"')) or not STRING.match(ops[0]):
        return ""
    n = len(_unquote(ops[0]).encode("latin-1"))
    if cl.trailing_header(binary, address, address + n):
        return (f"the last character is the first byte of the next record's 4-byte header "
                f"(the count before the string is {n - 1})")
    return ""


def raw_data(lst: ls.Listing, c: cl.Classification, binary: bytes) -> list[str]:
    """Every dc/dcb statement of the code files is an explained kind (module doc)."""
    starts = [s.start for s in c.spans]
    import bisect

    def kind(a: int) -> str:
        i = bisect.bisect_right(starts, a) - 1
        return c.spans[i].kind if i >= 0 and a < c.spans[i].end else "outside"

    fields = cl.text_fields(cl.TEXT_RECORDS)
    out = []
    for s in lst.statements:
        if s.kind != "data":
            continue
        parts = s.text.split(None, 1)
        mn = parts[0].lower()
        ops = ls._split_operands(parts[1]) if len(parts) > 1 else []
        if mn == "dc.b" and s.address in fields and any(op[:1] in "'\"" for op in ops):
            out.append(f"{s.address:06X}: {s.text}: {record_word(s.address)} (the text starts "
                       f"at {fields[s.address]:06X}, docs/16 section 3.1)")
            continue
        if not in_code_files(s.address):
            continue
        k = kind(s.address)
        if mn == "dcb.b" and FILL.match(s.text):
            continue
        if mn == "dc.l" and k == "pointers":
            continue
        if mn == "dc.w" and k == "switch" and all("-" in op and ls.names_symbol(op)
                                                  for op in ops):
            continue
        if mn == "dc.b" and k == "text" and ops and all(STRING.match(op) for op in ops):
            why = record_field(ops) or trailing_field(ops, s.address, binary)
            if why:
                out.append(f"{s.address:06X}: {s.text}: {why} (a record field stays an incbin "
                           f"slice; the text starts after it, docs/16 section 3)")
            continue
        out.append(f"{s.address:06X}: {s.text}: not an explained dc statement in a {k} range "
                   f"(an unexplained blob stays an incbin slice, decision C3)")
    return out


def foreign_refs(lst: ls.Listing) -> list[str]:
    """Operands that reach into images.asm or image_table.asm as label + offset."""
    out = []
    for s in lst.statements:
        if s.kind in ("instr", "data") and FOREIGN_REF.search(s.text):
            out.append(f"{s.address:06X}: {s.text}")
    return out


def shift(tree: Path, build: Path, lst: ls.Listing, binary: bytes, pad: int = 2,
          vasm: str = "vasmm68k_mot") -> ls.ShiftReport:
    """The tree copied with a pad after `org 0`, its guards commented out, its `$X-*` fills
    kept at their length and its incbin paths absolute; assembled and compared. A source file
    the tree includes from the build directory (a generated one, as tools/objects asm and
    tools/adpcm asm write, with an assert per structure) is copied and padded the same way."""
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp) / "68k"
        generated = Path(tmp) / "build"
        shutil.copytree(tree, work)
        built = build.resolve()

        def pad_source(text: str) -> str:
            text = re.sub(r"^(\s+)assert\b", r"\1; assert", text, flags=re.M)
            text = re.sub(r"(dcb\.b\s+\$[0-9A-Fa-f]+-\*)", rf"\1+{pad}", text)

            def include(m: re.Match[str]) -> str:
                dst = generated / m[2]
                if not dst.exists():
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    dst.write_text(pad_source((built / m[2]).read_text()))
                return f'{m[1]}"{dst}"'

            text = re.sub(r'^(\s+include\s+)"\.\./\.\./build/([^"]+)"', include, text,
                          flags=re.M | re.I)
            return text.replace('"../../build/', f'"{built}/')

        for f in work.rglob("*.asm"):
            text = pad_source(f.read_text())
            if f.name == "stunrun.asm":
                text = re.sub(r"^(\s+org\s+0)$", rf"\1\n\tdcb.b\t{pad},0", text, count=1,
                              flags=re.M)
            f.write_text(text)
        padded, _ = ls.assemble(work / "stunrun.asm", Path(tmp) / "padded.bin", vasm)
    return ls.shift_check(lst, binary, padded, 0, pad, 0, ROM_END)


def check(listing: str, binary: bytes, c: cl.Classification, decisions: dict[tuple[int, int], str],
          macros: set[str], seeds: list[tuple[int, str]], untaken: dict[int, str],
          unreached: set[int], tree: Path | None = None, build: Path | None = None,
          runs: dict[str, set[int]] | None = None, vasm: str = "vasmm68k_mot") -> TreeReport:
    """All the checks on the tree's listing and binary (binary[0] at 000000)."""
    from .__main__ import listed_seeds, pointer_ranges, switch_ranges

    rep = TreeReport()
    lst = ls.parse(listing, macros)
    ls.sizes(lst, len(binary))
    instr = {s.address for s in lst.statements if s.kind == "instr"}
    extra, outside = listed_seeds(c, binary, seeds, lambda x: x in instr)
    rep.descent = ls.descent_check(lst, binary, 0, extra, unreached, set(c.noreturn), untaken,
                                   outside)
    starts = set(c.code_starts(binary))
    rep.missing_code = sorted(x for x in starts if x not in instr)
    rep.extra_code = sorted(x for x in instr if x not in starts)
    rep.lint = ls.address_lint(lst, decisions, 0, ROM_END, frozenset(macros), binary, 0,
                               switch_ranges(c), pointer_ranges(c))
    rep.raw = raw_data(lst, c, binary)
    rep.foreign = foreign_refs(lst)
    if tree is not None and build is not None:
        rep.shift = shift(tree, build, lst, binary, vasm=vasm)
    for name, pcs in (runs or {}).items():
        rep.pccov[name] = pc.check(pcs, instr)
    return rep
