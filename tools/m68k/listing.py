"""Checks on vasm source through its listing (docs/14-68k-descent.md section 5.3).

These are the checks a code leg runs on its own source, and the CI tests run on synthetic source:

- `descent_check`: every instruction statement is reached by the descent from the source's own
  seeds (the `dc.l` pointers and the `dc.w a-b` switch entries that name an instruction, plus the
  extra seeds given: the classification's entries), except a listed set; every instruction the
  descent decodes starts at an instruction statement and has its length; no flow enters a
  `dc`/`dcb`/`ds`/`incbin` statement (a call that never returns is allowed to be followed by
  data only when it is listed);
- `address_lint`: no numeric operand that could be an address of the image: an absolute operand
  with a value in 000000-0BFFFF (but `pea N.w`, always a constant in this ROM), a long immediate
  or a `dc.l` value in 000100-0BFFFF that the operand decisions do not list as a constant
  (undecided ones are reported apart);
- `shift_check`: assembled again with a pad in front, exactly the statements whose operands
  name, other than PC-relatively, a symbol inside the moved range change, and each changed word
  grows by the pad.

A vasm listing (`vasmm68k_mot -L`) gives each statement's address and source text, and the
symbol table; the bytes come from the assembled binary.
"""

from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

from .descent import Descent

STATEMENT = re.compile(r"^([0-9A-F]{2}):([0-9A-F]{8}) ([0-9A-F ]*)\t\s*(\d+)(M?)[: ] ?(.*)$")
CONTINUATION = re.compile(r"^[0-9A-F]{2}:[0-9A-F]{8} [0-9A-F ]*$")
PLAIN = re.compile(r"^\s{20,}\t\s*(\d+)(M?)[: ] ?(.*)$")
SYMBOL = re.compile(r"^(\S+)\s+(?:[0-9A-F]{2}|[A-Z]):([0-9A-F]{8})$")
DATA = re.compile(r"^\s*(?:[\w.]+:?\s+)?(dc|dcb|ds|blk)(\.[bwl])?\s", re.I)
INCBIN = re.compile(r"^\s*(?:[\w.]+:?\s+)?incbin\s", re.I)
LABEL = re.compile(r"^([A-Za-z_.][\w.]*):?(?=\s|$)")
DIRECTIVE = re.compile(r"^(assert|org|even|cnop|align|include|section|equ|set|if\w*|else|endif"
                       r"|endc|macro|endm|rorg|public|xdef|xref|list|nolist|opt|fail|printt)\b",
                       re.I)
NUMBER = re.compile(r"^(?:\$[0-9A-Fa-f]+|%[01]+|@[0-7]+|\d+)$")


def macro_names(path: Path) -> set[str]:
    """The macros a file defines (`name macro`): their invocations are instructions."""
    out = set()
    for line in path.read_text().splitlines():
        m = re.match(r"^([A-Za-z_]\w*)\s+macro\b", line, re.I)
        if m:
            out.add(m.group(1).lower())
    return out


@dataclass
class Stmt:
    address: int
    kind: str  # instr, data, blob, other
    text: str  # the source line (label and comment removed)
    size: int = 0


@dataclass
class Listing:
    statements: list[Stmt] = field(default_factory=list)
    symbols: dict[str, int] = field(default_factory=dict)

    def by_address(self) -> dict[int, Stmt]:
        return {s.address: s for s in self.statements}


def _strip(src: str) -> str:
    code = src.split(";", 1)[0].rstrip()
    m = LABEL.match(code)
    if m and not code[:1].isspace():
        code = code[m.end():]
    return code.strip()


def parse(text: str, macros: set[str]) -> Listing:
    """Statements that emit bytes (address, kind, source) and the symbol table. A macro
    invocation from `macros` is one instruction statement at its first expansion address."""
    lst = Listing()
    pending_macro: str | None = None
    pending_labels: list[str] = []
    in_symbols = False
    for line in text.splitlines():
        if line.startswith("Symbols by name:"):
            in_symbols = True
            continue
        if line.startswith("Symbols by value:"):
            in_symbols = False
            continue
        if in_symbols:
            m = SYMBOL.match(line.strip())
            if m:
                lst.symbols.setdefault(m.group(1), int(m.group(2), 16))
            continue
        m = STATEMENT.match(line)
        if m:
            addr = int(m.group(2), 16)
            for name in pending_labels:  # local labels are not in vasm's symbol table
                lst.symbols.setdefault(name, addr)
            pending_labels = []
            src = m.group(6)
            if m.group(5) == "M":
                if pending_macro is not None:
                    lst.statements.append(Stmt(addr, "instr", pending_macro))
                    pending_macro = None
                    continue
                if lst.statements and lst.statements[-1].kind == "instr" \
                        and lst.statements[-1].text.split()[0].lower() in macros:
                    continue  # the rest of an instruction macro's expansion
            code = _strip(src)
            if not code:
                continue
            if DIRECTIVE.match(code):
                continue
            if INCBIN.match(" " + code):
                kind = "blob"
            elif DATA.match(" " + code):
                kind = "data"
            else:
                kind = "instr"
            lst.statements.append(Stmt(addr, kind, code))
            continue
        m = PLAIN.match(line)
        if m and m.group(2) != "M":
            lm = LABEL.match(m.group(3))
            if lm and not m.group(3)[:1].isspace() and not re.match(
                    r"^\S+\s+(equ|set|=|macro)\b", m.group(3), re.I):
                pending_labels.append(lm.group(1))
            code = _strip(m.group(3))
            word = code.split()[0].lower() if code else ""
            pending_macro = code if word in macros else None
    return lst


def sizes(lst: Listing, end: int) -> None:
    for s, t in zip(lst.statements, lst.statements[1:] + [Stmt(end, "", "")], strict=False):
        s.size = t.address - s.address


def assemble(src: Path, out: Path, vasm: str = "vasmm68k_mot") -> tuple[bytes, str]:
    """vasm as the Makefile runs it (-Fbin -no-opt -m68010), with a listing."""
    lst = out.with_suffix(".lst")
    r = subprocess.run([vasm, "-quiet", "-Fbin", "-no-opt", "-m68010", "-L", str(lst), "-o",
                        str(out), src.name], cwd=src.parent, capture_output=True, text=True,
                       check=False)
    if r.returncode != 0:
        raise RuntimeError(f"vasm failed on {src}:\n{r.stdout}{r.stderr}")
    return out.read_bytes(), lst.read_text()


# --- the descent check ---------------------------------------------------------------------


@dataclass
class DescentReport:
    reached: int = 0
    unreached: list[int] = field(default_factory=list)  # instruction statements not reached
    errors: list[str] = field(default_factory=list)


def _instr_ranges(lst: Listing) -> list[tuple[int, int]]:
    out: list[tuple[int, int]] = []
    for s in lst.statements:
        if s.kind != "instr" or s.size == 0:
            continue
        if out and out[-1][1] == s.address:
            out[-1] = (out[-1][0], s.address + s.size)
        else:
            out.append((s.address, s.address + s.size))
    return out


def source_seeds(lst: Listing) -> list[tuple[int, str]]:
    """The seeds the source gives itself: dc.l and dc.w a-b operands naming an instruction."""
    starts = {s.address for s in lst.statements if s.kind == "instr"}
    out = []
    for s in lst.statements:
        if s.kind != "data":
            continue
        m = re.match(r"dc\.([wl])\s+(.*)$", s.text, re.I)
        if not m:
            continue
        for op in _split_operands(m.group(2)):
            name = op.split("-")[0].split("+")[0].strip()
            v = lst.symbols.get(name)
            if v is not None and v in starts and (m.group(1) == "l" or "-" in op):
                out.append((v, f"{op} at {s.address:06X}"))
    return out


def descent_check(lst: Listing, image: bytes, origin: int, extra_seeds: list[int],
                  allowed_unreached: set[int], noreturn: set[int],
                  untaken: dict[int, str] | None = None, external: set[int] | None = None
                  ) -> DescentReport:
    """image: the assembled bytes, image[0] at address origin."""
    full = bytes(origin) + image
    rep = DescentReport()
    ranges = _instr_ranges(lst)
    d = Descent(full, ranges, untaken, external)
    seeds = source_seeds(lst)
    for a, _ in seeds:
        d.add(a, None, plain=True)
    for a in extra_seeds:
        d.add(a, "listed seed")
    d.run()
    starts = {s.address: s for s in lst.statements if s.kind == "instr"}
    for a, why in sorted(d.r.rejected.items()):
        rep.errors.append(f"seed {a:06X}: {why}")
    for c, why in sorted(d.r.noreturn.items()):
        if c not in noreturn:
            rep.errors.append(f"the call at {c:06X} falls through into no code: {why}")
    for a, insn in d.r.insns.items():
        st = starts.get(a)
        if st is None:
            rep.errors.append(f"{a:06X}: the descent decodes an instruction where no instruction "
                              f"statement starts")
        elif st.size != insn.length:
            rep.errors.append(f"{a:06X}: statement of {st.size} bytes, instruction of "
                              f"{insn.length}")
    for a in sorted(starts):
        if a in d.r.insns:
            rep.reached += 1
        elif a not in allowed_unreached:
            rep.unreached.append(a)
    return rep


# --- the address lint --------------------------------------------------------------------------


def _split_operands(ops: str) -> list[str]:
    out, depth, cur, quote = [], 0, "", ""
    for ch in ops:
        if quote:
            cur += ch
            if ch == quote:
                quote = ""
            continue
        if ch in "'\"":
            quote = ch
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif ch == "," and depth == 0:
            out.append(cur.strip())
            cur = ""
            continue
        cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def _num(t: str) -> int | None:
    t = t.strip()
    if not NUMBER.match(t):
        return None
    if t[0] == "$":
        return int(t[1:], 16)
    if t[0] == "%":
        return int(t[1:], 2)
    if t[0] == "@":
        return int(t[1:], 8)
    return int(t)


@dataclass
class LintReport:
    errors: list[str] = field(default_factory=list)
    undecided: list[str] = field(default_factory=list)
    allowed: int = 0


def address_lint(lst: Listing, decisions: dict[tuple[int, int], str],
                 lo: int = 0, hi: int = 0x0C0000, macros: frozenset[str] = frozenset()
                 ) -> LintReport:
    rep = LintReport()
    for s in lst.statements:
        if not lo <= s.address < hi or s.kind == "blob":
            continue
        parts = s.text.split(None, 1)
        if len(parts) < 2:
            continue
        mn, ops = parts[0].lower(), _split_operands(parts[1])
        if s.kind == "data":
            if mn == "dc.l":
                for op in ops:
                    v = _num(op)
                    if v is not None and 0x100 <= v < 0x0C0000:
                        rep.errors.append(f"{s.address:06X}: dc.l {op} could be an address")
            continue
        size = mn.rsplit(".", 1)[1] if "." in mn else ""
        for i, op in enumerate(ops):
            if op.startswith("#"):
                v = _num(op[1:])
                if v is None or not 0x100 <= v < 0x0C0000 or size != "l":
                    continue
                d = decisions.get((s.address, i))
                if d == "constant":
                    rep.allowed += 1
                elif d == "undecided":
                    rep.undecided.append(f"{s.address:06X}: {s.text}")
                else:
                    rep.errors.append(f"{s.address:06X}: {s.text}: the immediate {op} could be "
                                      f"an address and has no decision")
                continue
            inner = op[1:-1] if op.startswith("(") and op.endswith(")") else op
            for suffix in (".w", ".l", ".W", ".L"):
                if op.endswith(suffix):
                    inner = op[: -len(suffix)]
                    inner = inner[1:-1] if inner.startswith("(") and inner.endswith(")") else inner
            v = _num(inner)
            if v is None or v >= 0x0C0000 or (mn in macros and v < 0x100):
                continue  # a macro's small number is a register number, not an address
            if mn == "pea" and op.lower().endswith(".w"):
                continue
            rep.errors.append(f"{s.address:06X}: {s.text}: the absolute operand {op} is a ROM "
                              f"address written as a number")
    return rep


# --- the shift test ----------------------------------------------------------------------------

IDENT = re.compile(r"(?<![\w.$%@])([A-Za-z_.][\w.]*)")
REGISTERS = re.compile(r"^(d[0-7]|a[0-7]|sp|pc|sr|ccr|usp|vbr|sfc|dfc)(\.[wl])?$", re.I)


def symbolic_moving(s: Stmt, symbols: dict[str, int], lo: int, hi: int) -> bool:
    """Does the statement name, other than PC-relatively or as a difference, a symbol whose
    value lies in [lo, hi)?"""
    parts = s.text.split(None, 1)
    if len(parts) < 2:
        return False
    mn = parts[0].lower()
    ops = _split_operands(parts[1])
    branch = mn.startswith("b") and not mn.startswith(("bchg", "bclr", "bset", "btst", "bkpt")) \
        or mn.startswith("db")
    for i, op in enumerate(ops):
        if branch and i == len(ops) - 1:
            continue
        if re.search(r",\s*pc\b", op, re.I):
            continue
        if mn.startswith("dc.w") and "-" in op:
            continue
        for m in IDENT.finditer(op):
            name = m.group(1)
            if REGISTERS.match(name) or name.lower() in ("w", "l"):
                continue
            v = symbols.get(name)
            if v is None and name[-2:].lower() in (".w", ".l"):
                v = symbols.get(name[:-2])  # an absolute operand's size: sub_7000.w
            if v is not None and lo <= v < hi:
                return True
    return False


@dataclass
class ShiftReport:
    expected: int = 0
    changed: int = 0
    errors: list[str] = field(default_factory=list)


def shift_check(lst: Listing, plain: bytes, padded: bytes, origin: int, pad: int, lo: int,
                hi: int) -> ShiftReport:
    """plain: the source assembled at origin; padded: the same with `pad` bytes inserted before
    its first statement (so everything moved by pad)."""
    rep = ShiftReport()
    moved = padded[pad:]
    if len(moved) != len(plain):
        rep.errors.append(f"the padded image is {len(padded)} bytes, expected {len(plain) + pad}")
        return rep
    for s in lst.statements:
        a, b = s.address - origin, s.address - origin + s.size
        want = symbolic_moving(s, lst.symbols, lo, hi)
        got = plain[a:b] != moved[a:b]
        rep.expected += want
        rep.changed += got
        if want and not got:
            rep.errors.append(f"{s.address:06X}: {s.text}: names a moved symbol, did not change")
        elif got and not want:
            rep.errors.append(f"{s.address:06X}: {s.text}: changed without naming a moved "
                              f"symbol")
        elif got and s.kind != "blob":
            # each changed word: +pad (an address in a 16-bit or the low word of a 32-bit field)
            for w in range(a, b, 2):
                x = int.from_bytes(plain[w : w + 2], "big")
                y = int.from_bytes(moved[w : w + 2], "big")
                if x != y and (y - x) % 0x10000 != pad and not (
                        w + 2 < b and (int.from_bytes(moved[w : w + 4], "big")
                                       - int.from_bytes(plain[w : w + 4], "big")) % (1 << 32)
                        == pad):
                    rep.errors.append(f"{s.address:06X}: {s.text}: a word changed by "
                                      f"{(y - x) % 0x10000:X}, not by the pad")
                    break
    return rep
