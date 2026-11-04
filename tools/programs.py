"""The GSP and ADSP programs inside the 68k image: their ROM formats and what the loaders do.

Shared by tools/extract-programs, tools/test_programs.py and tools/annotate-listing. Standard
library only; nothing here prints a ROM byte. docs/06-code-map.md has the evidence.

Both programs sit in pair R (the boot program's 128 KB), reached through the table at 0x017000:

    017000  long  0x01702E  -> the ADSP record stream    (0x01702E-0x01907C)
    017004  long  0x01907C  -> the GSP section table     (0x01907C-0x01EFD4)

ADSP record stream, as the 68k loader at 0x02D2E0 reads it (called from 0x02C20A with the long
at 0x017000): a flag byte (0x02D306; anything but 0 ends the stream, 0x02D30A), a big-endian
16-bit word address A (0x02D30E-0x02D31A), a big-endian 16-bit count N (0x02D32C-0x02D33A),
then N packed big-endian 24-bit opcodes, each assembled into a long with a zero top byte
(0x02D342-0x02D35A) and stored with `move.l D0,(A2)+` at 0x800000 + 4*A onwards (0x02D35C).
MAME's 68k window over ADSP program RAM (harddriv_m.cpp hd68k_adsp_program_w) puts the even
16-bit half in bits 31-16 of the 32-bit word, so program word A + i receives the opcode.

GSP section table, as the 68k loader at 0x02FDD0 reads it (called from 0x02C1BC with the long
at 0x017004; the GSP halted, HSTCTL = 0xB800 at 0x02FDE2, autoincrement on write): a big-endian
section count (0x02FDEA), then per section (0x02FE0C) a big-endian destination bit address and
bit length (0x02FE1A/0x02FE1C), the destination written to HSTADRH:HSTADRL with `move.l
D0,$C00002` (0x02FE1E), and the data as big-endian longs: while the remaining length is 32 bits
or more, each long goes to HSTDATA low word first, then high word (0x02FE5E: 0x02FE68 then
0x02FE6E); a remainder of 16 bits writes the low word of one more long (0x02FE4A); any other
remainder calls the soft reset at 0x021286 (0x02FE40). Each HSTDATA write stores a 16-bit word
at the host address and adds 0x10 to it (tms34010.cpp host_w with HSTCTL INCW).
"""

from __future__ import annotations

import struct
from dataclasses import dataclass

PROGRAM_TABLE = 0x017000  # two longs: the ADSP stream, the GSP table
ADSP_START = 0x01702E
GSP_START = 0x01907C
GSP_END = 0x01EFD4

ADSP_PM_WORDS = 0x2000  # ADSP-2100 program RAM, 8K x 24 bits (800000-807FFF on the 68k)

GSP_VRAM_BASE = 0xFF800000  # GSP bit address of byte 0 of the VRAM image
GSP_VRAM_BYTES = 0x100000  # FF800000-FFFFFFFF in bits = 1 MB
GSP_ADDR_LIMIT = 0x100000000


class FormatError(ValueError):
    pass


@dataclass(frozen=True)
class AdspRecord:
    offset: int  # 68k address of the flag byte
    address: int  # ADSP program word address
    words: tuple[int, ...]  # the 24-bit opcodes

    @property
    def end(self) -> int:
        return self.address + len(self.words)


@dataclass(frozen=True)
class GspSection:
    offset: int  # 68k address of the section header
    address: int  # GSP bit address (destination)
    bits: int  # bit length
    words: tuple[int, ...]  # the 16-bit words in the order HSTDATA receives them

    @property
    def end(self) -> int:
        return self.address + self.bits


def parse_adsp(image: bytes, start: int) -> tuple[list[AdspRecord], int]:
    """The records from `start` and the address after the terminator byte."""
    records: list[AdspRecord] = []
    p = start
    while True:
        if p >= len(image):
            raise FormatError(f"ADSP stream runs past the image at {p:06X}")
        if image[p] != 0:
            return records, p + 1
        if p + 5 > len(image):
            raise FormatError(f"ADSP record header at {p:06X} runs past the image")
        address, count = struct.unpack_from(">HH", image, p + 1)
        data = p + 5
        if data + 3 * count > len(image):
            raise FormatError(f"ADSP record at {p:06X} runs past the image")
        if address + count > ADSP_PM_WORDS:
            raise FormatError(
                f"ADSP record at {p:06X} writes words {address:04X}-{address + count:04X}, "
                f"beyond program RAM (the 68k would write past 807FFF)"
            )
        words = tuple(
            int.from_bytes(image[data + 3 * i : data + 3 * i + 3], "big") for i in range(count)
        )
        records.append(AdspRecord(p, address, words))
        p = data + 3 * count


def parse_gsp(image: bytes, start: int) -> tuple[list[GspSection], int]:
    """The sections from `start` and the address after the last one."""
    if start + 4 > len(image):
        raise FormatError(f"GSP table at {start:06X} runs past the image")
    (count,) = struct.unpack_from(">I", image, start)
    p = start + 4
    sections: list[GspSection] = []
    for _ in range(count):
        if p + 8 > len(image):
            raise FormatError(f"GSP section header at {p:06X} runs past the image")
        address, bits = struct.unpack_from(">II", image, p)
        if bits >= 0x80000000:
            raise FormatError(f"GSP section at {p:06X}: negative length")
        if bits % 32 not in (0, 16):
            raise FormatError(
                f"GSP section at {p:06X}: {bits} bits; the loader resets on a remainder "
                f"other than 0 or 16 (0x02FE40)"
            )
        if address % 16:
            raise FormatError(f"GSP section at {p:06X}: destination {address:08X} not word aligned")
        if address + bits > GSP_ADDR_LIMIT:
            raise FormatError(f"GSP section at {p:06X} wraps past FFFFFFFF")
        longs = (bits + 31) // 32
        data = p + 8
        if data + 4 * longs > len(image):
            raise FormatError(f"GSP section at {p:06X} runs past the image")
        words: list[int] = []
        for i in range(bits // 32):
            (value,) = struct.unpack_from(">I", image, data + 4 * i)
            words += [value & 0xFFFF, value >> 16]  # low word first (0x02FE68, 0x02FE6E)
        if bits % 32:
            (value,) = struct.unpack_from(">I", image, data + 4 * (bits // 32))
            words.append(value & 0xFFFF)  # the low word of the padding long (0x02FE4A)
        sections.append(GspSection(p, address, bits, tuple(words)))
        p = data + 4 * longs
    return sections, p


@dataclass(frozen=True)
class Programs:
    adsp: list[AdspRecord]
    gsp: list[GspSection]
    adsp_range: tuple[int, int]  # 68k image range of the record stream
    gsp_range: tuple[int, int]  # 68k image range of the section table


def locate(image: bytes) -> Programs:
    """Parse both programs through the table at 0x017000 and check the boundaries that
    asm/68k/stunrun.asm asserts."""
    adsp_start, gsp_start = struct.unpack_from(">II", image, PROGRAM_TABLE)
    if (adsp_start, gsp_start) != (ADSP_START, GSP_START):
        raise FormatError(
            f"program table at {PROGRAM_TABLE:06X} points to {adsp_start:06X} and "
            f"{gsp_start:06X}, expected {ADSP_START:06X} and {GSP_START:06X}"
        )
    adsp, adsp_end = parse_adsp(image, adsp_start)
    if adsp_end != gsp_start:
        raise FormatError(f"ADSP stream ends at {adsp_end:06X}, the GSP table is at {gsp_start:06X}")
    gsp, gsp_end = parse_gsp(image, gsp_start)
    if gsp_end != GSP_END:
        raise FormatError(f"GSP table ends at {gsp_end:06X}, expected {GSP_END:06X}")
    return Programs(adsp, gsp, (adsp_start, adsp_end), (gsp_start, gsp_end))


def adsp_pm_image(records: list[AdspRecord]) -> tuple[bytes, list[tuple[int, int]]]:
    """Program RAM as the 68k leaves it: 0x2000 32-bit little-endian words (top byte 0), zero
    where nothing is loaded; and the loaded word ranges, one per record, in load order."""
    pm = [0] * ADSP_PM_WORDS
    for r in records:
        pm[r.address : r.end] = r.words
    return struct.pack(f"<{ADSP_PM_WORDS}I", *pm), [(r.address, r.end) for r in records]


def gsp_vram_image(sections: list[GspSection]) -> tuple[bytes, list[tuple[int, int]]]:
    """VRAM as the 68k leaves it: a sparse image of FF800000-FFFFFFFF (bit address
    GSP_VRAM_BASE + 8 * byte offset), 16-bit words little-endian, zero where nothing is loaded;
    and the loaded bit ranges, one per section."""
    vram = bytearray(GSP_VRAM_BYTES)
    for s in sections:
        if s.address < GSP_VRAM_BASE:
            raise FormatError(f"GSP section to {s.address:08X} is below the VRAM image")
        at = (s.address - GSP_VRAM_BASE) // 8
        for i, w in enumerate(s.words):
            struct.pack_into("<H", vram, at + 2 * i, w)
    return bytes(vram), [(s.address, s.end) for s in sections]


def bit_range_to_bytes(start: int, end: int) -> tuple[int, int]:
    """A GSP bit range as a byte range of the VRAM image."""
    return (start - GSP_VRAM_BASE) // 8, (end - GSP_VRAM_BASE) // 8


# --- the oracle comparison (tools/test_programs.py) -------------------------------------------

# GSP words the GSP program itself writes after the 68k has loaded it, so MAME's VRAM no longer
# holds the loaded value: (bit address, why). Each entry names the writing instructions.
GSP_RUNTIME_WORDS = [
    (0xFFF5C8F0, "a variable in section 2: MOVE B9,@FFF5C8F0h,0 at FFF46340 and FFF479B0"),
]


def diff_pm(pm: bytes, dump: bytes, ranges: list[tuple[int, int]]) -> list[int]:
    """The loaded ADSP program words (32-bit little-endian images) that differ."""
    out = []
    for start, end in ranges:
        for w in range(start, end):
            if pm[4 * w : 4 * w + 4] != dump[4 * w : 4 * w + 4]:
                out.append(w)
    return out


def diff_vram(
    vram: bytes, dump: bytes, ranges: list[tuple[int, int]], exclude: list[int] | None = None
) -> list[int]:
    """The bit addresses of the loaded GSP words that differ, the `exclude` words left out."""
    skip = set(exclude or ())
    out = []
    for start, end in ranges:
        b0, b1 = bit_range_to_bytes(start, end)
        for b in range(b0, b1, 2):
            if vram[b : b + 2] != dump[b : b + 2]:
                bit = GSP_VRAM_BASE + 8 * b
                if bit not in skip:
                    out.append(bit)
    return out


def read_ranges(doc: dict[str, object]) -> list[tuple[int, int]]:
    """The ranges of a pm.ranges.json / vram.ranges.json document (tools/extract-programs)."""
    rows = doc["ranges"]
    assert isinstance(rows, list)
    return [(int(s, 16), int(e, 16)) for s, e in rows]
