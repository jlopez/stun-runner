"""The memory maps of docs/01 as the setup snapshots of the two IDA databases (docs/05-ida.md).

Pure Python: the setup is computed from the image bytes (the vector tables) and the tables below,
and `ida.headless.create` applies it before auto-analysis. Every name here is also in the
committed snapshot `data/ida/stunrun-*.json`, where it is reviewed.
"""

from __future__ import annotations

import struct
from collections.abc import Callable
from dataclasses import dataclass

from ida.snapshot import Comment, DataItem, Name, Segment, Snapshot

# --- 68010 (main board), docs/01 section 3 ----------------------------------------------------

ROM_68K_SIZE = 0xC0000

SEGMENTS_68K = [
    Segment(0x000000, ROM_68K_SIZE, "ROM", "CODE", 32, 0, "program ROM, the 12 files interleaved"),
    Segment(
        0x600000, 0x610000, "MAINIO", "DATA", 32, None, "JSA II port, NWR latch, watchdog, port 0"
    ),
    Segment(0x800000, 0x840000, "ADSP", "DATA", 32, None, "ADSP-2100 RAM windows, control, status"),
    Segment(0xA00000, 0xC00000, "LATCH", "DATA", 32, None, "WR0/WR1/WR2 latches, buttons, ADCs"),
    Segment(0xC00000, 0xC08000, "GSP", "DATA", 32, None, "TMS34010 and MSP host interfaces"),
    Segment(0xFF0000, 0xFF0020, "DUART", "DATA", 32, None, "MC68681 DUART"),
    Segment(0xFF4000, 0xFF5000, "ZRAM", "DATA", 32, None, "M48T02 (high byte) and 2816 (low byte)"),
    Segment(0xFF8000, 0x1000000, "RAM", "DATA", 32, None, "32 KB work RAM"),
]

# (address, name, repeatable comment). Where read and write differ, the read is the name and the
# write is in the comment (docs/05 section 2).
IO_68K = [
    (0x600000, "JSA_PORT", "JSA II, high byte: read the sound CPU's response, write a command"),
    (
        0x604000,
        "SOUND_RESET",
        "read: reset the sound board; write: NWR_LATCH (A0-A2 line, A3 value)",
    ),
    (0x608000, "WATCHDOG", "write: kick the watchdog"),
    (
        0x60C000,
        "PORT0",
        "read: port 0 (DIAGN, sync, EOC, self-test, coins, DIP SW1); write: IRQ5_ACK",
    ),
    (0x800000, "ADSP_PRAM", "ADSP program RAM, 8K x 24-bit words as 32-bit pairs"),
    (0x808000, "ADSP_DRAM", "ADSP data RAM, 8K x 16; a write to word 0x1FFF raises the ADSP IRQ"),
    (0x810000, "ADSP_BUFFER", "ADSP output buffer (SOM), bank from ADSP_CONTROL line 3"),
    (
        0x818000,
        "ADSP_CONTROL",
        "write: A0-A2 line, bit 3 value; 0-1 LEDs, 3 bank, 5 /BR, 6 /HALT, 7 reset",
    ),
    (0x818060, "ADSP_IRQ_CLEAR", "write: clear the ADSP interrupt (level 2)"),
    (0x838000, "ADSP_STATUS", "read: bit 0 low = ADSP IRQ pending, bit 1 low = XFLAG"),
    (0xA00000, "WR0_LATCH", "write: A0-A2 line, bit 3 value; 1-4 SEL1-SEL4, 6-7 coin counters"),
    (0xA80000, "BUTTONS", "read: bit 0 button 1, bit 1 button 2, bit 2 start; write: WR1_LATCH"),
    (
        0xB00000,
        "ADC8_DATA",
        "read, odd byte: ADC0809 result (ch 0 stick X, ch 2 stick Y); write: WR2_LATCH",
    ),
    (0xB80000, "ADC12", "12-bit ADC: read the result, write the channel select and start"),
    (
        0xC00000,
        "GSP_HOST",
        "TMS34010 host interface (HSTADRL/HSTADRH/HSTDATA/HSTCTL, swapped in pairs)",
    ),
    (0xC04000, "MSP_HOST", "MSP host interface, reads 0xFFFF (no MSP on this board)"),
    (0xFF0000, "DUART", "MC68681 DUART, high byte"),
]

# The 68010 exception vectors 0-63 (the reset pair, the exceptions, the autovectors with this
# board's interrupt sources, the traps). Vectors 64-255 are not a table on this ROM: the reset PC
# is inside them (docs/05 section 3).
VECTOR_COUNT_68K = 64
_FIXED_68K = {
    0: "reset_sp",
    1: "reset_pc",
    2: "bus_error",
    3: "address_error",
    4: "illegal_instruction",
    5: "zero_divide",
    6: "chk",
    7: "trapv",
    8: "privilege_violation",
    9: "trace",
    10: "line_a",
    11: "line_f",
    14: "format_error",
    15: "uninitialized_interrupt",
    24: "spurious_interrupt",
    25: "level1_msp",
    26: "level2_adsp",
    27: "level3_gsp",
    28: "level4_sound",
    29: "level5_timer",
    30: "level6_duart",
    31: "level7_nmi",
}


def vector_name_68k(n: int) -> str:
    if n in _FIXED_68K:
        return "vec_" + _FIXED_68K[n]
    if 32 <= n < 48:
        return f"vec_trap_{n - 32}"
    if n < VECTOR_COUNT_68K:
        return f"vec_reserved_{n}"
    return f"vec_user_{n}"


# --- 6502 (JSA II), docs/01 section 6 -----------------------------------------------------------

JSA_BANKS = 4
JSA_BANK_SIZE = 0x1000
JSA_BANK_WINDOW = 0x3000


def jsa_bank_base(n: int) -> int:
    """Linear address of bank page n in the IDA database; the 6502 sees it at 3000."""
    return ((n + 1) << 16) | JSA_BANK_WINDOW


SEGMENTS_JSA = [
    Segment(0x0000, 0x2000, "RAM", "DATA", 16, None, "8 KB RAM"),
    Segment(0x2000, 0x3000, "IO", "DATA", 16, None, "YM2151, OKI M6295, 68010 ports, WRIO, MIX"),
    Segment(0x4000, 0x10000, "ROM", "CODE", 16, 0x4000, "136070-2123.10c, offset 0x4000-0xFFFF"),
] + [
    Segment(
        jsa_bank_base(n),
        jsa_bank_base(n) + JSA_BANK_SIZE,
        f"BANK{n}",
        "CODE",
        16,
        n * JSA_BANK_SIZE,
        f"bank page {n} (WRIO bits 7-6 = {n}), seen by the 6502 at 3000-3FFF",
    )
    for n in range(JSA_BANKS)
]

# The read ports 2800-2806 are decoded with mirror mask 01F9 (docs/01 section 6): bits 0 and 3-8
# are don't-cares, so each one answers throughout 2800-29FF. The rev 6 sound program reads them
# only through the +8 mirrors (2808, 280A, 280C, 280E), so those get a name too (docs/05 section 4).
JSA_READ_MIRROR_MASK = 0x01F9
JSA_READ_MIRRORS_USED = (0x0008,)
_IO_JSA_READ = [
    (0x2800, "OKI_READ", "OKI M6295 status (/RDV)"),
    (0x2802, "CMD_FROM_68K", "command byte from the 68010 (/RDP)"),
    (0x2804, "RDIO", "/RDIO: 7 self-test, 6 NMI state, 5 output buffer full, 1-0 coins"),
    (0x2806, "IRQ_ACK", "IRQ acknowledge (read or write)"),
]


def jsa_read_mirrors() -> list[tuple[int, str, str]]:
    """The mirrors of the read ports that the code uses, named `<base>_M` (one used mirror)."""
    out = []
    for delta in JSA_READ_MIRRORS_USED:
        if delta & ~JSA_READ_MIRROR_MASK or delta == 0:
            raise ValueError(
                f"{delta:#x} is not a mirror offset under mask {JSA_READ_MIRROR_MASK:#x}"
            )
        suffix = "_M" if len(JSA_READ_MIRRORS_USED) == 1 else f"_M{delta:X}"
        for ea, name, text in _IO_JSA_READ:
            out.append((ea + delta, name + suffix, f"{text}; mirror of {ea:04X} (mask 01F9)"))
    return out


IO_JSA = [
    (0x2000, "YM2151_REG", "YM2151 register select (write), status (read)"),
    (0x2001, "YM2151_DATA", "YM2151 data"),
    *_IO_JSA_READ,
    *jsa_read_mirrors(),
    (0x2A00, "OKI_WRITE", "OKI M6295 command (/WRV)"),
    (0x2A02, "RESP_TO_68K", "response byte to the 68010 (/WRP)"),
    (0x2A04, "WRIO", "/WRIO: 7-6 ROM bank for 3000-3FFF, 0 YM2151 reset (low), coin counters, LPF"),
    (0x2A06, "MIX", "/MIX: 3-1 YM2151 volume, 7-5 OKI volume"),
]

VECTORS_JSA = [(0xFFFA, "nmi"), (0xFFFC, "reset"), (0xFFFE, "irq")]


# --- the setups -------------------------------------------------------------------------------


def _io(table: list[tuple[int, str, str]]) -> tuple[list[Name], list[Comment]]:
    return (
        [Name(ea, name) for ea, name, _ in table],
        [Comment(ea, "repeatable", text) for ea, _, text in table],
    )


def _handlers(
    targets: dict[int, list[str]], reset: str
) -> tuple[list[int], list[Name], list[Comment]]:
    """A function at each vector target; named after its vector, or after the range of vectors
    that share it, with a function comment that lists them."""
    functions: list[int] = []
    names: list[Name] = []
    comments: list[Comment] = []
    for ea, vectors in sorted(targets.items()):
        functions.append(ea)
        if reset in vectors:
            name = "reset"
        elif len(vectors) == 1:
            name = "h_" + vectors[0].removeprefix("vec_")
        else:
            name = "h_" + vectors[0].removeprefix("vec_") + "_etc"
        names.append(Name(ea, name))
        comments.append(Comment(ea, "function", "vectors: " + ", ".join(vectors)))
    return functions, names, comments


def setup_68k(image: bytes) -> Snapshot:
    if len(image) != ROM_68K_SIZE:
        raise ValueError(f"68k image is {len(image)} bytes, expected {ROM_68K_SIZE}")
    vectors = struct.unpack_from(f">{VECTOR_COUNT_68K}I", image, 0)
    names, comments = _io(IO_68K)
    data: list[DataItem] = []
    targets: dict[int, list[str]] = {}
    for n, value in enumerate(vectors):
        ea, name = 4 * n, vector_name_68k(n)
        in_rom = n > 0 and value != 0 and value < ROM_68K_SIZE and value % 2 == 0
        names.append(Name(ea, name))
        data.append(DataItem(ea, "dword", 1, in_rom))
        if in_rom:
            targets.setdefault(value, []).append(name)
    functions, handler_names, handler_comments = _handlers(targets, "vec_reset_pc")
    return Snapshot(
        "stunrun-68k",
        "68010",
        list(SEGMENTS_68K),
        names + handler_names,
        functions,
        comments + handler_comments,
        data,
    ).normalized()


def setup_jsa(image: bytes) -> Snapshot:
    if len(image) != 0x10000:
        raise ValueError(f"6502 image is {len(image)} bytes, expected 65536")
    names, comments = _io(IO_JSA)
    data: list[DataItem] = []
    targets: dict[int, list[str]] = {}
    for ea, short in VECTORS_JSA:
        name = "vec_" + short
        names.append(Name(ea, name))
        data.append(DataItem(ea, "word", 1, True))
        (value,) = struct.unpack_from("<H", image, ea)
        if value >= 0x4000:
            targets.setdefault(value, []).append(name)
    functions, handler_names, handler_comments = _handlers(targets, "vec_reset")
    return Snapshot(
        "stunrun-jsa",
        "M6502",
        list(SEGMENTS_JSA),
        names + handler_names,
        functions,
        comments + handler_comments,
        data,
    ).normalized()


@dataclass(frozen=True)
class DatabaseSpec:
    name: str  # data/<name>.i64, data/ida/<name>.json, build/<name>.bin
    processor: str  # IDA processor name (-p)
    setup: Callable[[bytes], Snapshot]


DATABASES = {
    "68k": DatabaseSpec("stunrun-68k", "68010", setup_68k),
    "jsa": DatabaseSpec("stunrun-jsa", "M6502", setup_jsa),
}
