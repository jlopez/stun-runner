"""The classification of the 68k image's 000000-05CF86 (data/68k/classification.json, docs/14).

`classify(image, ...)` runs the descent in stages, each recorded in the evidence of the entries
it adds, then classifies every byte that is not code:

1. plain seeds: the vectors of both tables (000000, 020000) and `game_entries` (020100, 020106,
   02010C), with the idioms of descent.py (switches, computed calls, code-pointer tables, return
   addresses) as they come;
2. code-pointer tables in data: a run of two or more aligned longs outside code, all pointing
   into the code ranges, one of them at an instruction already decided; the others are seeded;
3. MAME: every PC the `make pccov` runs executed (the runs given);
4. reviewed seeds: data/68k/seeds.json, an address and the written argument for each.

Then, for the bytes that are no instruction and no table: text (a run of at least six printable
characters, mostly letters, digits and the punctuation of messages, with a word and not made of
equal byte pairs, with its terminating zero; without one only a counted string or a run an
operand references, and a count or item byte at its start left out: _text_runs),
fill (a run of at least 32 zero bytes that no operand references), data (from an address an
operand references to the next boundary) and unknown (the rest; in a code range a note says when
the bytes decode cleanly as instructions and whether IDA has a function there).

The file holds addresses, kinds, notes and evidence strings only: no byte of the image.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

from .decode import ABSL, ABSW, CALL, IMM, JUMP, PCDISP, PCINDEX, STOP, Insn, decode
from .descent import P_LATE, Descent, Result, Switch, _abs

END = 0x05CF86
# where code may be (docs/06 section 4): pair R below the program table, the game's entry
# table and pairs S-T up to the data at 046AEE
ELIGIBLE = [(0x000100, 0x017000), (0x020100, 0x046AEE)]
VECTOR_TABLES = [(0x000000, "the boot program's vector table (docs/06 section 1.2)"),
                 (0x020000, "the game's vector table, installed at 000294 (docs/06 section 1.2)")]
GAME_ENTRIES = [0x020100, 0x020106, 0x02010C]
# ranges whose kind the code map decides (docs/06 sections 2-3)
KNOWN = [
    (0x017000, 0x017008, "pointers", "the program table: adsp_program, gsp_program (read at "
                                     "02C204, 02C1B6, 02DCB0; docs/06 section 2)"),
    (0x01702E, 0x01907C, "data", "the ADSP program's record stream, read by load_adsp_program "
                                 "02D2E0 (docs/06 section 3.1)"),
    (0x01907C, 0x01EFD4, "data", "the GSP program's section table, read by load_gsp_program "
                                 "02FDD0 (docs/06 section 3.2)"),
]


@dataclass
class Layout:
    """Where code may be and what the image says about itself (the defaults: stunrun's)."""

    end: int = END
    eligible: list[tuple[int, int]] = field(default_factory=lambda: list(ELIGIBLE))
    vector_tables: list[tuple[int, str]] = field(default_factory=lambda: list(VECTOR_TABLES))
    entries: list[int] = field(default_factory=lambda: list(GAME_ENTRIES))
    known: list[tuple[int, int, str, str]] = field(default_factory=lambda: list(KNOWN))


KINDS = ("code", "switch", "pointers", "text", "data", "fill", "unknown")
TEXT_MIN = 6
FILL_MIN = 32
TEXT_CHARS = set(range(0x20, 0x7F))
TEXT_WORDY = set(b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 *.-:/!?',()#%=&+")


@dataclass
class Span:
    start: int
    end: int
    kind: str
    note: str = ""
    jmp: int = -1  # switch: the jmp
    base: int = -1  # switch: the targets' base

    def to_json(self) -> dict[str, object]:
        d: dict[str, object] = {"start": f"{self.start:06X}", "end": f"{self.end:06X}",
                                "kind": self.kind}
        if self.jmp >= 0:
            d["jmp"] = f"{self.jmp:06X}"
            d["base"] = f"{self.base:06X}"
        if self.note:
            d["note"] = self.note
        return d


@dataclass
class Classification:
    spans: list[Span]
    entries: dict[int, str]
    noreturn: dict[int, str]
    rejected: dict[int, str]
    result: Result | None = None
    end: int = END

    def code_starts(self, image: bytes) -> dict[int, int]:
        """Every instruction start of the code ranges and its length, by linear decoding."""
        out: dict[int, int] = {}
        for s in self.spans:
            if s.kind != "code":
                continue
            a = s.start
            while a < s.end:
                insn = decode(image, a)
                if insn is None:
                    raise ValueError(f"code range {s.start:06X}-{s.end:06X}: no instruction at "
                                     f"{a:06X}")
                out[a] = insn.length
                a += insn.length
            if a != s.end:
                raise ValueError(f"code range {s.start:06X}-{s.end:06X} ends inside an "
                                 f"instruction")
        return out


def _long(image: bytes, a: int) -> int:
    return int.from_bytes(image[a : a + 4], "big")


def run_descent(image: bytes, mame_pcs: set[int], seeds: list[tuple[int, str]],
                untaken: dict[int, str], lay: Layout) -> Descent:
    d = Descent(image, lay.eligible, untaken)
    for base, _ in lay.vector_tables:
        d.table_bytes.update(range(base, base + 0x100))
    for lo, hi, _, _ in lay.known:
        d.table_bytes.update(range(lo, hi))
    # 1. plain seeds
    for base, _ in lay.vector_tables:
        for n in range(1, 64):
            v = _long(image, base + 4 * n)
            if v and d.is_eligible(v):
                d.add(v, None, plain=True)
    for a in lay.entries:
        d.add(a, None, plain=True)
    d.run()
    # 2. code-pointer tables in data
    _pointer_runs(d, image, lay.end)
    # 3. MAME
    for pc in sorted(mame_pcs):
        if pc not in d.r.insns:
            d.add(pc, "MAME executed (make pccov)", P_LATE)
    # 4. reviewed seeds
    for a, why in seeds:
        d.add(a, f"reviewed: {why}", P_LATE)
    d.run()
    return d


def routine_starts(r: Result) -> set[int]:
    """Addresses a call reaches, or that a seed with evidence entered: where routines start."""
    out = {i.target for i in r.insns.values() if i.flow == CALL and i.target is not None}
    out |= set(r.entries)
    return out


def _pointer_runs(d: Descent, image: bytes, end: int) -> None:
    """Runs of at least three aligned longs outside code, all into the code ranges, at least
    half of them (and at least two) at routine starts already decided: the others are seeds."""
    for _ in range(4):
        starts = routine_starts(d.r)
        found = False
        a = 0
        while a < end - 4:
            if not d.is_free(a, 4) or not d.is_eligible(_long(image, a)):
                a += 2
                continue
            run = []
            p = a
            while p < end - 4 and d.is_free(p, 4) and d.is_eligible(_long(image, p)):
                run.append(p)
                p += 4
            known = [q for q in run if _long(image, q) in starts]
            if len(run) >= 3 and len(known) >= 2 and 2 * len(known) >= len(run) \
                    and len(known) < len(run):
                for k, q in enumerate(run):
                    v = _long(image, q)
                    if v not in d.r.insns:
                        d.add(v, f"entry {k} of the code-pointer run at {run[0]:06X} ({len(run)} "
                                 f"longs into code, {len(known)} of them at routine starts)",
                              P_LATE)
                        found = True
            a = p
        if not found:
            return
        d.run()


def _data_refs(r: Result, end: int) -> dict[int, list[int]]:
    """Addresses below END that an instruction's operand designates as data."""
    refs: dict[int, list[int]] = {}
    for a, insn in r.insns.items():
        if insn.flow == JUMP or insn.target is not None:
            ops = insn.operands[:-1]
        else:
            ops = insn.operands
        for o in ops:
            if o.mode in (ABSW, ABSL) and not (insn.mnemonic == "pea" and o.mode == ABSW):
                v = _abs(o)
            elif o.mode in (PCDISP, PCINDEX):
                v = o.value
            elif o.mode == IMM and insn.mnemonic == "movea" and insn.size == "l":
                v = o.value
            else:
                continue
            if v < end:
                refs.setdefault(v, []).append(a)
    return refs


SAME_CASE = re.compile(rb"[A-Z]{4,}|[a-z]{4,}")
TEXT_DISTINCT = 3


def _doubled(run: bytes) -> bool:
    """The bytes come in equal pairs (at either alignment, one odd byte allowed at each end):
    words such as 6464 5A5A are numbers whose two bytes are equal, not characters."""
    for off in (0, 1):
        s = run[off:]
        n = len(s) // 2 * 2
        if n >= 4 and all(s[i] == s[i + 1] for i in range(0, n, 2)):
            return True
    return False


def _is_text(run: bytes) -> bool:
    """At least TEXT_MIN characters, nine in ten of them letters, digits, blanks or the
    punctuation of messages, half of them letters, at least TEXT_DISTINCT distinct characters,
    a word of four letters of one case with two distinct letters, and the bytes not in equal
    pairs: code is often printable too (4E71 4E75 is "NqNu"), and so are numeric tables whose
    words have two equal bytes (022DC-022EC, one byte 16 times, is 001FBC + 50 x 16 in the
    16-byte records sub_22EC indexes at 0022F0-0022FC)."""
    wordy = sum(1 for c in run if c in TEXT_WORDY)
    letters = sum(1 for c in run if chr(c).isalpha())
    return (len(run) >= TEXT_MIN and wordy * 10 >= 9 * len(run) and letters * 2 >= len(run)
            and len(set(run)) >= TEXT_DISTINCT and not _doubled(run)
            and any(len(set(w)) >= 2 for w in SAME_CASE.findall(run)))


COUNT_MAX = 0x3F
ITEM_PREFIX = re.compile(rb"[a-z][^a-z]*\Z")


def trailing_header(image: bytes, x: int, y: int) -> bool:
    """The last byte of the counted run x-y (its count the byte before x) is the first byte of
    the next screen record's 4-byte header, not a character: the count is one fewer than the
    run, and image[y-1:y+3] is a header (column, row, attribute, count) whose count is the
    printable run after it, or one fewer (007A7F: column 20h before 06 3F 12 and the 18
    characters of CONTROL*LEFT/RIGHT; also 007A95, 007B42, 007B53)."""
    if x == 0 or y + 3 > len(image) or image[x - 1] != y - x - 1:
        return False
    z = y + 3
    while z < len(image) and image[z] in TEXT_CHARS:
        z += 1
    k = image[y + 2]
    return TEXT_MIN <= k <= COUNT_MAX and k in (z - y - 3, z - y - 4)


def _counted(image: bytes, x: int, y: int) -> tuple[int, int] | None:
    """Where the text of an unterminated run x-y starts and ends when it is a counted string:
    the count is the byte before the run, or the run's first byte, or its second byte after an
    attribute byte (the boot program's screen records, 4-byte headers column, row, attribute,
    count, as at 007154-007158: a count of 20h-3Fh is printable and was read as a character).
    The count equals the characters after it, or one fewer (006D9C, 007397, 0088DC, 008908:
    the ROM's count is one short of the text), unless the run's last byte starts the next
    record's header (`trailing_header`): then the text ends one byte earlier. None when the
    run is no counted string."""
    if x > 0 and image[x - 1] in (y - x, y - x - 1):
        return x, y - 1 if trailing_header(image, x, y) else y
    for p in (0, 1):
        if x + p >= y:
            break
        c, n = image[x + p], y - (x + p + 1)
        if c <= COUNT_MAX and n >= TEXT_MIN and c in (n, n - 1):
            start = x + p + 1
            return start, y - 1 if trailing_header(image, start, y) else y
    return None


def _text_runs(image: bytes, lo: int, hi: int, refs: set[int]) -> list[tuple[int, int]]:
    """Printable runs that read as text, cut where an operand points (a string starts there).

    A run that ends with a terminating zero is a C string; a lower-case first byte before
    upper-case text is a record field (the option records at 020ED0-021148 start with an item
    byte, 76h at 020FD5 and 0210FC as FDh, CCh, BBh, ... before the others). A run with no
    terminating zero is text only when it is a counted string (`_counted`, the count left
    out) or an operand references its start: the printable middle of a numeric table (045A79,
    045AD6, 04659B in the island, values rising through and past the run) is neither."""
    out = []
    a = lo
    while a < hi:
        if image[a] not in TEXT_CHARS:
            a += 1
            continue
        b = a
        while b < hi and image[b] in TEXT_CHARS:
            b += 1
        cuts = [a] + sorted(r for r in refs if a < r < b) + [b]
        for x, y in zip(cuts, cuts[1:], strict=False):
            terminated = y == b and b < hi and image[b] == 0
            if terminated:
                if x not in refs and ITEM_PREFIX.match(image[x:y]):
                    x += 1
            elif x not in refs:
                counted = _counted(image, x, y)
                if counted is None:
                    continue
                x, y = counted
            if _is_text(image[x:y]):
                out.append((x, y + 1 if terminated else y))
        a = b + 1 if b < hi and image[b] == 0 else b
    return out


def _zero_runs(image: bytes, lo: int, hi: int) -> list[tuple[int, int]]:
    out = []
    for m in re.finditer(rb"\x00{%d,}" % FILL_MIN, image[lo:hi]):
        out.append((lo + m.start(), lo + m.end()))
    return out


def classify(image: bytes, mame_pcs: set[int], seeds: list[tuple[int, str]],
             untaken: dict[int, str], ida_functions: dict[int, str],
             lay: Layout | None = None) -> Classification:
    lay = lay or Layout()
    END = lay.end  # noqa: N806
    d = run_descent(image, mame_pcs, seeds, untaken, lay)
    r = d.r
    kind = ["unknown"] * END
    note: dict[int, str] = {}
    spans: list[Span] = []
    for a, insn in r.insns.items():
        for b in range(a, a + insn.length):
            kind[b] = "code"
    for base, why in lay.vector_tables:
        for b in range(base, base + 0x100):
            kind[b] = "pointers"
        note[base] = why
    for s in r.switches.values():
        for b in range(s.table, s.end):
            kind[b] = "switch"
    for t in r.pointer_tables.values():
        for b in range(t.start, t.end):
            kind[b] = "pointers"
        note[t.start] = f"code-pointer table: {t.evidence}"
    for rt in r.record_tables.values():
        for b in range(rt.start, rt.end):
            kind[b] = "data"
        note[rt.start] = (f"record table: {rt.count} records of {rt.stride} bytes, a routine "
                          f"pointer at +{rt.offset} of each ({rt.evidence})")
    for lo, hi, k, why in lay.known:
        for b in range(lo, hi):
            assert kind[b] == "unknown", f"{b:06X}"
            kind[b] = k
        note[lo] = why
    refs = _data_refs(r, END)
    # text, fill, data, unknown over what is left
    gaps = _runs(kind, "unknown")
    for lo, hi in gaps:
        for a, b in _text_runs(image, lo, hi, set(refs)):
            for x in range(a, b):
                kind[x] = "text"
    for lo, hi in _runs(kind, "unknown"):
        for a, b in _zero_runs(image, lo, hi):
            # up to the first address an operand references (a base pointing into the zeros)
            b = min([b] + [v for v in refs if a <= v < b])
            if b - a < FILL_MIN:
                continue
            for x in range(a, b):
                kind[x] = "fill"
    ref_starts = sorted(v for v in refs if kind[v] in ("unknown",))
    for v in ref_starts:
        x = v
        if kind[x] != "unknown":
            continue
        note.setdefault(v, "referenced from " + ", ".join(f"{i:06X}" for i in sorted(refs[v])[:4])
                        + (f" and {len(refs[v]) - 4} more" if len(refs[v]) > 4 else ""))
        while x < END and kind[x] == "unknown":
            kind[x] = "data"
            x += 1
    # spans: maximal runs of one kind, split where a note starts (a table, a reference)
    switch_at = {s.table: s for s in r.switches.values()}
    table_at = set(r.pointer_tables)
    start = 0
    for x in range(1, END + 1):
        split = x == END or kind[x] != kind[start] or x in note or x in switch_at \
            or x in table_at
        if kind[start] == "code" and x < END and kind[x] == "code" and x not in table_at:
            split = False  # code is one range per run of instructions
        if split:
            sp = Span(start, x, kind[start], note.get(start, ""))
            if sp.kind == "switch":
                s = switch_at[start]
                sp.jmp, sp.base = s.jmp, s.base
                sp.note = f"switch at {s.jmp:06X}: cases {s.lo}-{s.lo + s.count - 1}, {s.bound}"
            spans.append(sp)
            start = x
    index = reference_index(image, END)
    for sp in spans:
        if sp.kind == "unknown" and any(lo <= sp.start < hi for lo, hi in lay.eligible):
            sp.note = _unknown_note(image, sp, ida_functions, index, spans, lay.eligible)
    return Classification(spans, dict(r.entries), dict(r.noreturn), dict(r.rejected), r, END)


def _runs(kind: list[str], k: str) -> list[tuple[int, int]]:
    out = []
    a = 0
    n = len(kind)
    while a < n:
        if kind[a] != k:
            a += 1
            continue
        b = a
        while b < n and kind[b] == k:
            b += 1
        out.append((a, b))
        a = b
    return out


def reference_index(image: bytes, end: int) -> dict[int, list[int]]:
    """Every place in 000000-end that may refer to an address, by the address: a long at an even
    address equal to it (an absolute long operand, a pointer, a `jmp abs.l` of a jump table), a
    `jsr`/`jmp` absolute short to it, a branch or `bsr` (short or word) or a `jsr`/`jmp`/`lea`/
    `pea` (d16,pc) to it. A search of the bytes, whatever their kind: a hit is a possible
    reference, not a decided one."""
    out: dict[int, list[int]] = {}
    end = min(end, len(image))
    for a in range(0, end - 1, 2):
        w = int.from_bytes(image[a : a + 2], "big")
        hits = []
        if a + 4 <= end:
            hits.append(int.from_bytes(image[a : a + 4], "big") & 0xFFFFFFFF)
        nxt = int.from_bytes(image[a + 2 : a + 4], "big") if a + 4 <= end else None
        if w >> 12 == 6:  # bra, bsr, bcc
            d8 = w & 0xFF
            if d8 == 0 and nxt is not None:
                hits.append((a + 2 + (nxt - 0x10000 if nxt & 0x8000 else nxt)) & 0xFFFFFF)
            elif d8 != 0xFF:
                hits.append((a + 2 + (d8 - 0x100 if d8 & 0x80 else d8)) & 0xFFFFFF)
        elif nxt is not None and (w in (0x4EBA, 0x4EFA, 0x487A) or (w & 0xF1FF) == 0x41FA):
            hits.append((a + 2 + (nxt - 0x10000 if nxt & 0x8000 else nxt)) & 0xFFFFFF)
        elif nxt is not None and w in (0x4EB8, 0x4EF8) and nxt < 0x8000:
            hits.append(nxt)
        for h in hits:
            out.setdefault(h, []).append(a)
    return out


def _kind_at(spans: list[Span], a: int) -> str:
    for s in spans:
        if s.start <= a < s.end:
            return s.kind
    return "?"


def _linear(image: bytes, a0: int, end: int, eligible: list[tuple[int, int]]
            ) -> tuple[dict[int, Insn], list[Switch], int]:
    """A linear decode of a0-end that steps over the word table of a C switch (the idiom of
    descent.py): the instructions, the switches, and where the decode stopped."""
    probe = Descent(image, eligible)
    insns: dict[int, Insn] = {}
    switches: list[Switch] = []
    a = a0
    while a < end:
        insn = decode(image, a)
        if insn is None or a + insn.length > end:
            break
        insns[a] = insn
        a += insn.length
        if insn.mnemonic == "jmp":
            sw = probe.switch_at(insn, insns)
            if sw is not None and sw.table == a and sw.end <= end:
                switches.append(sw)
                a = sw.end
    return insns, switches, a


def _unknown_note(image: bytes, sp: Span, ida_functions: dict[int, str],
                  index: dict[int, list[int]] | None = None,
                  spans: list[Span] | None = None,
                  eligible: list[tuple[int, int]] | None = None) -> str:
    a0 = sp.start + (sp.start & 1)  # an instruction starts at an even address
    insns, switches, a = _linear(image, a0, sp.end, eligible or ELIGIBLE)
    n = len(insns)
    last = insns[max(insns)] if insns else None
    cases = {t for sw in switches for t in sw.targets(image)}
    ida = [f"{name} {ea:06X}" for ea, name in ida_functions.items() if sp.start <= ea < sp.end]
    parts = []
    tables = "".join(f", a switch table at {sw.table:06X} (jmp at {sw.jmp:06X}, cases "
                     f"{sw.lo}-{sw.lo + sw.count - 1})" for sw in switches)
    if a == sp.end and last is not None and last.flow in (STOP, JUMP) \
            and last.addr + last.length == sp.end and cases <= set(insns):
        # where a routine may start inside: the start, after each rts/rte/jmp, IDA's starts
        starts = {a0} | {x for x in ida_functions if sp.start <= x < sp.end and x in insns}
        starts |= {i.addr + i.length for i in insns.values()
                   if (i.flow == STOP or i.mnemonic == "jmp") and i.addr + i.length in insns}

        def refs(t: int) -> list[int]:
            return [x for x in (index or {}).get(t, []) if not sp.start <= x < sp.end]

        def where(rs: list[int]) -> str:
            return ", ".join(f"{x:06X} ({_kind_at(spans or [], x)})" for x in rs[:6]) + (
                f" and {len(rs) - 6} more" if len(rs) > 6 else "")

        inner = [(t, refs(t)) for t in sorted(starts - {a0}) if refs(t)]
        found = []
        if refs(a0):
            found.append(f"possible references: {where(refs(a0))} (a long equal to it, or a "
                         f"branch or call to it, found by a search of the bytes)")
        found += [f"possible references to {t:06X} inside it: {where(rs)}" for t, rs in inner]
        searched = len(starts)
        parts.append(f"decodes cleanly from {a0:06X} as {n} instructions{tables} ending with "
                     f"{last.mnemonic} at {last.addr:06X}; "
                     + ("; ".join(found) if found and index is not None else
                        ("no reference found (no long equal to it, no branch or call to it in "
                         "the bytes searched)" if searched == 1 else
                         f"no reference found (no long equal to its start or to any of the "
                         f"{searched - 1} routine starts inside it, no branch or call to them "
                         f"in the bytes searched)") if index is not None else
                        "references not searched"))
    elif n:
        parts.append(f"decodes as {n} instructions{tables} from {a0:06X}, then "
                     f"{'stops' if a >= sp.end else f'no instruction at {a:06X}'}")
    if ida:
        parts.append("IDA functions: " + ", ".join(ida[:4]) + (" ..." if len(ida) > 4 else ""))
    return "; ".join(parts)


# --- the file -------------------------------------------------------------------------------

FORMAT = "stunrun-68k-classification 1"


def dump(c: Classification) -> str:
    lines = ["{", f'  "format": "{FORMAT}",', f'  "range": ["000000", "{c.end:06X}"],',
             '  "ranges": [']
    lines += [f"    {json.dumps(s.to_json())}," for s in c.spans]
    lines[-1] = lines[-1].rstrip(",")
    lines += ["  ],", '  "entries": [']
    ent = [f'    {json.dumps({"at": f"{a:06X}", "evidence": e})},'
           for a, e in sorted(c.entries.items())]
    if ent:
        ent[-1] = ent[-1].rstrip(",")
    lines += ent + ["  ],", '  "noreturn": [']
    nr = [f'    {json.dumps({"call": f"{a:06X}", "why": w})},' for a, w in sorted(c.noreturn.items())]
    if nr:
        nr[-1] = nr[-1].rstrip(",")
    lines += nr + ["  ]", "}"]
    return "\n".join(lines) + "\n"


def load(path: Path) -> Classification:
    j = json.loads(path.read_text())
    if j.get("format") != FORMAT:
        raise ValueError(f"{path}: not {FORMAT}")
    spans = []
    for r in j["ranges"]:
        s = Span(int(r["start"], 16), int(r["end"], 16), r["kind"], r.get("note", ""),
                 int(r.get("jmp", "-1"), 16) if "jmp" in r else -1,
                 int(r["base"], 16) if "base" in r else -1)
        if s.kind not in KINDS:
            raise ValueError(f"{path}: unknown kind {s.kind}")
        spans.append(s)
    entries = {int(e["at"], 16): e["evidence"] for e in j["entries"]}
    noreturn = {int(e["call"], 16): e["why"] for e in j.get("noreturn", [])}
    return Classification(spans, entries, noreturn, {}, None, int(j["range"][1], 16))


def validate(c: Classification, start: int = 0) -> list[str]:
    """Problems with the ranges: a gap, an overlap, an empty or odd range."""
    end = c.end
    errs = []
    pos = start
    for s in c.spans:
        if s.start != pos:
            errs.append(f"{'gap' if s.start > pos else 'overlap'} at {pos:06X}-{s.start:06X}")
        if s.end <= s.start:
            errs.append(f"empty range at {s.start:06X}")
        if s.kind in ("code", "switch", "pointers") and (s.start % 2 or s.end % 2):
            errs.append(f"{s.kind} range {s.start:06X}-{s.end:06X} is not word-aligned")
        if s.kind == "pointers" and (s.end - s.start) % 4:
            errs.append(f"pointer range {s.start:06X}-{s.end:06X} is not whole longs")
        pos = s.end
    if pos != end:
        errs.append(f"the ranges end at {pos:06X}, not {end:06X}")
    return errs


def stats(c: Classification, regions: list[tuple[str, int, int]]) -> dict[str, dict[str, int]]:
    out: dict[str, dict[str, int]] = {}
    for name, lo, hi in regions:
        row = dict.fromkeys(KINDS, 0)
        for s in c.spans:
            a, b = max(s.start, lo), min(s.end, hi)
            if a < b:
                row[s.kind] += b - a
        out[name] = row
    return out


__all__ = ["Classification", "Span", "classify", "dump", "load", "validate", "stats"]
