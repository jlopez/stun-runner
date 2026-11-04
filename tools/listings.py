"""Where the image bytes come from: vasm and 64tass listings classified by source line.

Used by tools/coverage (`make coverage`). Each statement that emits bytes owns the span from its
address to the next statement's address in the same section (or to the end of the section /
image), so repeated-byte runs (vasm `*`, 64tass `.fill` without bytes shown) and alignment
padding count for the statement that produced them. Classes:

    instr  instructions (and anything not recognised as one of the others)
    data   dc / dcb-free data statements: vasm dc.*, 64tass .byte .word .text .long ...
    blob   incbin / .binary
    fill   vasm ds.* dcb.* blk.*, 64tass .fill
"""

from __future__ import annotations

import re
from collections import defaultdict
from dataclasses import dataclass

CLASSES = ("instr", "data", "blob", "fill")

VASM_SECTION = re.compile(r'^([0-9A-F]{2}): "[^"]*" \(([0-9A-F]+)-([0-9A-F]+)\)$')
VASM_SOURCE = re.compile(r'^Source: "(.*)"$')
VASM_STATEMENT = re.compile(r"^([0-9A-F]{2}):([0-9A-F]{8}) [^\t]*\t\s*\d+: (.*)$")
VASM_CONTINUATION = re.compile(r"^[0-9A-F]{2}:[0-9A-F]{8} ")
TASS_ADDRESS = re.compile(r"^[.>]([0-9a-f]{4,8})$")
TASS_HEX = re.compile(r"^[0-9a-f]{2}( [0-9a-f]{2})*$")

VASM_DIRECTIVES = (
    ("blob", re.compile(r"(^|\s)incbin(\s|$)", re.I)),
    ("fill", re.compile(r"(^|\s)(ds|dcb|blk)(\.[bwlsdqx])?(\s|$)", re.I)),
    ("data", re.compile(r"(^|\s)dc(\.[bwlsdqx])?(\s|$)", re.I)),
)
TASS_DIRECTIVES = (
    ("blob", re.compile(r"(^|\s)\.binary(\s|$)")),
    ("fill", re.compile(r"(^|\s)\.fill(\s|$)")),
    (
        "data",
        re.compile(
            r"(^|\s)\.(byte|char|word|sint|addr|rta|long|lint|dword|dint|text|ptext|shift"
            r"|shiftl|null)(\s|$)"
        ),
    ),
)


def _code(source: str) -> str:
    """The source line without its comment (good enough: no ';' inside strings so far)."""
    return source.split(";", 1)[0]


def classify(source: str, directives: tuple[tuple[str, re.Pattern[str]], ...]) -> str:
    code = _code(source)
    for name, pattern in directives:
        if pattern.search(code):
            return name
    return "instr"


@dataclass
class Statement:
    file: str
    section: str
    address: int
    cls: str


Counts = dict[str, dict[str, int]]


def _attribute(statements: list[Statement], ends: dict[str, int]) -> Counts:
    counts: Counts = defaultdict(lambda: dict.fromkeys(CLASSES, 0))
    for i, s in enumerate(statements):
        nxt = next((t.address for t in statements[i + 1 :] if t.section == s.section), None)
        end = nxt if nxt is not None else ends[s.section]
        if end < s.address:
            raise ValueError(f"{s.file}: address goes backwards at ${s.address:X}")
        counts[s.file][s.cls] += end - s.address
    return dict(counts)


def vasm(listing: str) -> Counts:
    """Per source file and class, the bytes of a vasm -L listing."""
    lengths: dict[str, int] = {}
    statements: list[Statement] = []
    current = "?"
    in_sections = False
    for line in listing.splitlines():
        if line == "Sections:":
            in_sections = True
            continue
        if in_sections:
            m = VASM_SECTION.match(line)
            if m:
                lengths[m.group(1)] = int(m.group(3), 16) - int(m.group(2), 16)
                continue
            if line.strip():
                in_sections = False
        m = VASM_SOURCE.match(line)
        if m:
            current = m.group(1)
            continue
        m = VASM_STATEMENT.match(line)
        if m:
            cls = classify(m.group(3), VASM_DIRECTIVES)
            statements.append(Statement(current, m.group(1), int(m.group(2), 16), cls))
    # a section ends at its first address + its length (the header's range is section-relative)
    ends: dict[str, int] = {}
    for s in statements:
        if s.section not in ends:
            ends[s.section] = s.address + lengths[s.section]
    return _attribute(statements, ends)


def tass(listing: str, image_size: int) -> Counts:
    """Per source file and class, the bytes of a 64tass -L listing of an image of image_size."""
    statements: list[Statement] = []
    stack: list[str] = []
    for line in listing.splitlines():
        for marker in (";******  Processing input file: ", ";******  Processing file: "):
            if line.startswith(marker):
                stack.append(line[len(marker) :])
        if line.startswith(";******  Return to file: "):
            stack.pop()
            continue
        fields = line.split("\t")
        m = TASS_ADDRESS.match(fields[0])
        if not m:
            continue
        rest = fields[1:]
        if rest and TASS_ADDRESS.match("." + rest[0]):  # a .logical PC column after the offset
            rest = rest[1:]
        text = [f for f in rest if f and not TASS_HEX.match(f)]
        if not text:
            continue  # continuation of the previous statement's bytes
        cls = classify(" ".join(text), TASS_DIRECTIVES)  # label, monitor, source, comment
        statements.append(Statement(stack[-1] if stack else "?", "", int(m.group(1), 16), cls))
    return _attribute(statements, {"": image_size})
