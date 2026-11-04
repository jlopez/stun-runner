"""The tables of docs/06-code-map.md against their own arithmetic, IDA's function extents and,
when `make` has built it, the 68k image.

The document tests run everywhere (CI): the partition rows are contiguous and their byte counts
match their bounds, the GSP section table adds up to the VRAM total the text states, and no row
that is not code overlaps a function of the committed IDA export. The image tests skip without
build/stunrun-68k.bin: zero-fill rows hold zeros, no absolute long in the code rows points into a
zero-fill row, the image pointer table reaches exactly the packed-image rows, and the call
sites ida/code_map.py cites are call instructions.
"""

from __future__ import annotations

import json
import re
import struct
from pathlib import Path
from typing import NamedTuple

import pytest

from ida.code_map import CODE_MAP_68K

REPO = Path(__file__).resolve().parent.parent
DOC = REPO / "docs/06-code-map.md"
FUNCTIONS = REPO / "data/ida/stunrun-68k.functions.jsonl"
IMAGE = REPO / "build/stunrun-68k.bin"

ROW = re.compile(r"^\| 0x([0-9A-F]{6}) \| 0x([0-9A-F]{6}) \| ([\d,]+) \| ([^|]*) \|")
GSP_ROW = re.compile(
    r"^\| (\d) \| [^|]* \| ([0-9A-F]{8})-([0-9A-F]{8}) \| ([\d,]+) \|", re.MULTILINE
)


class Row(NamedTuple):
    start: int
    end: int
    size: int
    owner: str

    @property
    def is_code(self) -> bool:
        return self.owner.strip().startswith(("boot code", "game code"))

    @property
    def is_zero_fill(self) -> bool:
        return self.owner.strip() == "zero fill"


def _number(text: str) -> int:
    return int(text.replace(",", ""))


def partition_tables() -> list[list[Row]]:
    """The tables of section 4.1 and 4.2, in document order."""
    text = DOC.read_text()
    section = text[text.index("## 4. The partition") : text.index("### 4.3")]
    tables: list[list[Row]] = []
    for block in section.split("\n\n"):
        rows = [
            Row(int(m[1], 16), int(m[2], 16), _number(m[3]), m[4])
            for line in block.splitlines()
            if (m := ROW.match(line))
        ]
        if rows:
            tables.append(rows)
    return tables


def all_rows() -> list[Row]:
    return [row for table in partition_tables() for row in table]


def test_partition_rows_are_contiguous_and_add_up() -> None:
    tables = partition_tables()
    assert [(t[0].start, t[-1].end) for t in tables] == [(0, 0x020000), (0x020000, 0x0C0000)]
    for table in tables:
        for row, following in zip(table, table[1:], strict=False):
            assert row.end == following.start, f"gap or overlap after {row.start:06X}"
        for row in table:
            assert row.size == row.end - row.start, f"{row.start:06X}: {row.size}"


def test_gsp_section_table_counts_destination_bytes() -> None:
    """The byte column is what VRAM receives: a 16-bit remainder (0x02FE4A) writes half of the
    last source long, so the 68k source span is no measure of it."""
    text = DOC.read_text()
    rows = GSP_ROW.findall(text)
    assert [int(r[0]) for r in rows] == [0, 1, 2, 3]
    sizes = []
    for _, start, end, size in rows:
        # The trap vectors' range, FFFFFC00-FFFFFFFF, is written with an inclusive end.
        bits = int(end, 16) - int(start, 16) + (1 if end == "FFFFFFFF" else 0)
        assert bits % 8 == 0
        assert _number(size) == bits // 8, f"section at {start}: {size}"
        sizes.append(bits // 8)
    total = re.search(r"The program occupies ([\d,]+) bytes of VRAM", text)
    assert total is not None
    assert sum(sizes) == _number(total[1])


def test_rows_that_are_not_code_hold_no_ida_function() -> None:
    functions = [json.loads(line) for line in FUNCTIONS.read_text().splitlines()]
    for row in all_rows():
        if row.is_code:
            continue
        inside = [
            f["name"] for f in functions if f["start_ea"] < row.end and f["end_ea"] > row.start
        ]
        assert inside == [], f"{row.start:06X}-{row.end:06X} ({row.owner.strip()}): {inside}"


# --- against the image (skips without `make`) ---------------------------------------------------


@pytest.fixture(scope="module")
def image() -> bytes:
    if not IMAGE.exists():
        pytest.skip(f"no {IMAGE} (make needs the ROMs)")
    return IMAGE.read_bytes()


def test_zero_fill_rows_hold_zeros(image: bytes) -> None:
    for row in all_rows():
        if row.is_zero_fill:
            assert not any(image[row.start : row.end]), f"{row.start:06X}-{row.end:06X}"


def _absolute_long(opcode: int) -> bool:
    """An opcode word whose next long is an address: a source EA in absolute long mode (mode 7,
    register 1: `sub.b $20418.l,D0`, `move.l $bfe04.l,-(A7)`), `lea abs.l,An`, or
    `addi.l #imm,Dn` (the table bases at 0x024F16 and its siblings)."""
    return opcode & 0x3F == 0x39 or opcode & 0xF1FF == 0x41F9 or opcode & 0xFFF8 == 0x0680


def test_no_code_operand_points_into_zero_fill(image: bytes) -> None:
    """An address operand in a code row that falls inside a zero-fill row (0x02079A's
    `sub.b $20418.l`, 0x022798's `lea $bfe00.l`) means the bytes there are read: not fill."""
    rows = all_rows()
    fills = [r for r in rows if r.is_zero_fill]
    hits = []
    for row in (r for r in rows if r.is_code):
        for offset in range(row.start + 2, row.end - 3, 2):
            opcode, value = struct.unpack_from(">HI", image, offset - 2)
            if not _absolute_long(opcode):
                continue
            for fill in fills:
                if fill.start <= value < fill.end:
                    hits.append(f"{offset - 2:06X}: {value:06X} in {fill.start:06X}-{fill.end:06X}")
    assert hits == []


def test_image_pointer_table_reaches_the_packed_image_rows(image: bytes) -> None:
    rows = all_rows()
    (table,) = [r for r in rows if r.owner.startswith("image pointer table")]
    count = (table.end - table.start) // 4
    entries = struct.unpack_from(f">{count}I", image, table.start)
    assert entries[0] == 0 and entries[-1] == 0
    packed = [r for r in rows if r.owner.startswith("packed GSP images")]
    reached = {r.start for r in packed for e in entries[1:-1] if r.start <= e < r.end}
    assert all(any(r.start <= e < r.end for r in packed) for e in entries[1:-1])
    assert reached == {r.start for r in packed}
    # Every packed row but the first starts where a table entry points.
    assert {r.start for r in packed[1:]} <= set(entries)


CALLED_FROM = re.compile(r"Called from ((?:[0-9A-F]{6}(?:, | and )?)+)")
# jsr abs.l, jsr (d16,PC), bsr.w / bsr.b (0x61xx), jsr (An)
CALL_OPCODES = (0x4EB9, 0x4EBA)


def _is_call(opcode: int) -> bool:
    return opcode in CALL_OPCODES or opcode >> 8 == 0x61 or opcode & 0xFFF8 == 0x4E90


def test_cited_call_sites_are_call_instructions(image: bytes) -> None:
    """ "Called from X" in a code-map comment names the call instruction, not its operand."""
    cited = [
        (entry.ea, int(site, 16))
        for entry in CODE_MAP_68K
        for m in CALLED_FROM.finditer(entry.comment)
        for site in re.findall(r"[0-9A-F]{6}", m[1])
    ]
    assert cited
    for callee, site in cited:
        (opcode,) = struct.unpack_from(">H", image, site)
        assert _is_call(opcode), f"{callee:06X}: {site:06X} holds {opcode:04X}"
