"""Where the image bytes come from: vasm and 64tass listings classified by source line.

Used by tools/coverage (`make coverage`). Each statement that emits bytes owns the span from its
address to the next statement's address in the same section (or to the end of the section /
image), so repeated-byte runs (vasm `*`, 64tass `.fill` without bytes shown) and alignment
padding count for the statement that produced them. Classes:

    instr  instructions (and anything not recognised as one of the others)
    data   dc / dcb-free data statements: vasm dc.*, 64tass .byte .word .text .long ...
    blob   incbin / .binary
    fill   vasm ds.* dcb.* blk.*, 64tass .fill

`vasm_blobs` / `tass_blobs` list each blob statement with the label before it and the file it
includes, so that `make coverage` names the blobs (adsp_program, gsp_program, ...).
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
VASM_ANY = re.compile(r"^[^\t]*\t\s*\d+: (.*)$")
VASM_LABEL = re.compile(r"^([A-Za-z_.][\w.]*):")
VASM_INCBIN = re.compile(r'incbin\s+"([^"]+)"', re.I)
TASS_BINARY = re.compile(r"^(?:([A-Za-z_][\w.]*)\s+)?\.binary\s+([^,;\s]+)")
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
    label: str = ""  # the last label at or before the statement (blobs only)
    target: str = ""  # the file a blob includes, as written in the source


@dataclass(frozen=True)
class Blob:
    file: str  # the source file
    label: str
    target: str  # the included file, as written
    address: int
    size: int


Counts = dict[str, dict[str, int]]


def _spans(statements: list[Statement], ends: dict[str, int]) -> list[tuple[Statement, int]]:
    out = []
    for i, s in enumerate(statements):
        nxt = next((t.address for t in statements[i + 1 :] if t.section == s.section), None)
        end = nxt if nxt is not None else ends[s.section]
        if end < s.address:
            raise ValueError(f"{s.file}: address goes backwards at ${s.address:X}")
        out.append((s, end - s.address))
    return out


def _attribute(statements: list[Statement], ends: dict[str, int]) -> Counts:
    counts: Counts = defaultdict(lambda: dict.fromkeys(CLASSES, 0))
    for s, size in _spans(statements, ends):
        counts[s.file][s.cls] += size
    return dict(counts)


def _blobs(statements: list[Statement], ends: dict[str, int]) -> list[Blob]:
    return [
        Blob(s.file, s.label, s.target, s.address, size)
        for s, size in _spans(statements, ends)
        if s.cls == "blob"
    ]


def vasm(listing: str) -> Counts:
    """Per source file and class, the bytes of a vasm -L listing."""
    return _attribute(*_vasm_parse(listing))


def vasm_blobs(listing: str) -> list[Blob]:
    """The incbin statements of a vasm -L listing, with their labels, files and sizes."""
    return _blobs(*_vasm_parse(listing))


def _vasm_parse(listing: str) -> tuple[list[Statement], dict[str, int]]:
    lengths: dict[str, int] = {}
    statements: list[Statement] = []
    current = "?"
    label = ""
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
        m = VASM_ANY.match(line)
        if m:
            lm = VASM_LABEL.match(m.group(1))
            if lm:
                label = lm.group(1)
        m = VASM_STATEMENT.match(line)
        if m:
            cls = classify(m.group(3), VASM_DIRECTIVES)
            target = ""
            if cls == "blob":
                im = VASM_INCBIN.search(_code(m.group(3)))
                target = im.group(1) if im else "?"
            statements.append(
                Statement(current, m.group(1), int(m.group(2), 16), cls, label, target)
            )
    # a section ends at its first address + its length (the header's range is section-relative)
    ends: dict[str, int] = {}
    for s in statements:
        if s.section not in ends:
            ends[s.section] = s.address + lengths[s.section]
    return statements, ends


def tass(listing: str, image_size: int) -> Counts:
    """Per source file and class, the bytes of a 64tass -L listing of an image of image_size."""
    return _attribute(*_tass_parse(listing, image_size))


def tass_statements(listing: str, image_size: int) -> list[tuple[Statement, int]]:
    """Every statement of a 64tass -L listing that emits bytes, with its size in bytes."""
    return _spans(*_tass_parse(listing, image_size))


def tass_blobs(listing: str, image_size: int) -> list[Blob]:
    """The .binary statements of a 64tass -L listing, with their labels, files and sizes."""
    return _blobs(*_tass_parse(listing, image_size))


def _tass_parse(listing: str, image_size: int) -> tuple[list[Statement], dict[str, int]]:
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
        label = target = ""
        if cls == "blob":
            bm = TASS_BINARY.match(_code(" ".join(text)).strip())  # [label] .binary FILE, ...
            label, target = (bm.group(1) or "", bm.group(2)) if bm else ("", "?")
        file = stack[-1] if stack else "?"
        statements.append(Statement(file, "", int(m.group(1), 16), cls, label, target))
    return statements, {"": image_size}
