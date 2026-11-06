"""The memory maps of docs/01 as the setup snapshots of the two IDA databases (docs/05-ida.md).

Pure Python: the setup is computed from the image bytes (the vector tables) and the tables below,
and `ida.headless.create` applies it before auto-analysis. Every name here is also in the
committed snapshot `data/ida/stunrun-*.json`, where it is reviewed.
"""

from __future__ import annotations

import struct
from collections.abc import Callable
from dataclasses import dataclass

from ida.code_map import CODE_MAP_68K, GAME_VECTORS, HANDLER_COMMENTS
from ida.jsa_source import hardware_io, image_ranges
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

# The ports 2800-2A06 decode with mirror mask 01F9 (docs/01 section 6): bits 0 and 3-8 are
# don't-cares. The rev 6 sound program reads the read ports only through the +8 mirrors (2808,
# 280A, 280C, 280E), which hardware.asm names with _M (docs/05 section 4).
JSA_READ_MIRROR_MASK = 0x01F9

# (address, name, repeatable comment): the equates of asm/jsa/hardware.asm in the IO segment,
# read from the source (one source of truth: what `make ida-sync` writes is the same).
IO_JSA = [(eq.ea, eq.name, eq.comment) for eq in hardware_io()]

VECTORS_JSA = [(0xFFFA, "nmi"), (0xFFFC, "reset"), (0xFFFE, "irq")]


# --- the setups -------------------------------------------------------------------------------


def _io(table: list[tuple[int, str, str]]) -> tuple[list[Name], list[Comment]]:
    return (
        [Name(ea, name) for ea, name, _ in table],
        [Comment(ea, "repeatable", text) for ea, _, text in table],
    )


def _handlers(
    targets: dict[int, list[str]],
    reset: str,
    prefix: str = "h_",
    reset_name: str = "reset",
    strip: str = "vec_",
) -> tuple[list[int], list[Name], list[Comment]]:
    """A function at each vector target; named after its vector, or after the range of vectors
    that share it, with a function comment that lists them."""
    functions: list[int] = []
    names: list[Name] = []
    comments: list[Comment] = []
    for ea, vectors in sorted(targets.items()):
        functions.append(ea)
        if reset in vectors:
            name = reset_name
        elif len(vectors) == 1:
            name = prefix + vectors[0].removeprefix(strip)
        else:
            name = prefix + vectors[0].removeprefix(strip) + "_etc"
        names.append(Name(ea, name))
        comments.append(Comment(ea, "function", "vectors: " + ", ".join(vectors)))
    return functions, names, comments


def _vector_table_68k(
    image: bytes, base: int, prefix: str
) -> tuple[list[Name], list[DataItem], dict[int, list[str]]]:
    """The 64 named longs of a 68010 vector table at `base` and the ROM targets they reach."""
    vectors = struct.unpack_from(f">{VECTOR_COUNT_68K}I", image, base)
    names: list[Name] = []
    data: list[DataItem] = []
    targets: dict[int, list[str]] = {}
    for n, value in enumerate(vectors):
        ea, name = base + 4 * n, prefix + vector_name_68k(n)
        in_rom = n > 0 and value != 0 and value < ROM_68K_SIZE and value % 2 == 0
        names.append(Name(ea, name))
        data.append(DataItem(ea, "dword", 1, in_rom))
        if in_rom:
            targets.setdefault(value, []).append(name)
    return names, data, targets


def setup_68k(image: bytes) -> Snapshot:
    """The memory map and both vector tables: the boot program's at 0 (handlers `boot_*`) and
    the game's at GAME_VECTORS = 0x020000, which the boot code installs with movec A0,VBR at
    0x000294 (vectors `game_vec_*`, handlers `h_*`, the reset target `game_reset`)."""
    if len(image) != ROM_68K_SIZE:
        raise ValueError(f"68k image is {len(image)} bytes, expected {ROM_68K_SIZE}")
    names, comments = _io(IO_68K)
    boot_names, data, boot_targets = _vector_table_68k(image, 0, "")
    game_names, game_data, game_targets = _vector_table_68k(image, GAME_VECTORS, "game_")
    functions, handler_names, handler_comments = _handlers(
        boot_targets, "vec_reset_pc", "boot_", "boot_reset"
    )
    game_functions, game_handler_names, game_handler_comments = _handlers(
        game_targets, "game_vec_reset_pc", "h_", "game_reset", "game_vec_"
    )
    return Snapshot(
        "stunrun-68k",
        "68010",
        list(SEGMENTS_68K),
        names + boot_names + game_names + handler_names + game_handler_names,
        functions + game_functions,
        comments + handler_comments + game_handler_comments,
        data + game_data,
    ).normalized()


def setup_68k_full(image: bytes) -> Snapshot:
    """setup_68k plus the code map of milestone 2 (ida/code_map.py). One function comment per
    address: a code-map or handler comment is appended to the `vectors: ...` line."""
    base = setup_68k(image)
    function_comments = {c.ea: c.text for c in base.comments if c.kind == "function"}
    other = [c for c in base.comments if c.kind != "function"]
    names = {n.ea: n.name for n in base.names}
    functions = set(base.functions)
    data = list(base.data)

    def add_function_comment(ea: int, text: str) -> None:
        old = function_comments.get(ea)
        function_comments[ea] = text if old is None else old + "\n" + text

    for entry in CODE_MAP_68K:
        if entry.name is not None:
            names[entry.ea] = entry.name
        if entry.kind == "function":
            functions.add(entry.ea)
            add_function_comment(entry.ea, entry.comment)
        else:
            other.append(Comment(entry.ea, "regular", entry.comment))
    for ea, text in HANDLER_COMMENTS.items():
        if ea not in functions:
            raise ValueError(f"handler comment at {ea:06X} without a vector target there")
        add_function_comment(ea, text)
    data += [DataItem(ea, "dword", 1, True) for ea in (0x017000, 0x017004)]
    data += [DataItem(ea, "dword", 1, False) for ea in (0x017008, 0x01700C)]
    return Snapshot(
        base.database,
        base.processor,
        base.segments,
        [Name(ea, name) for ea, name in names.items()],
        sorted(functions),
        other + [Comment(ea, "function", t) for ea, t in function_comments.items()],
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
    # ranges whose every data item and instruction the snapshot records: the source owns their
    # classification (`make ida-sync`, docs/05 section 6)
    classified: tuple[tuple[int, int], ...] = ()


DATABASES = {
    "68k": DatabaseSpec("stunrun-68k", "68010", setup_68k_full),
    "jsa": DatabaseSpec("stunrun-jsa", "M6502", setup_jsa, tuple(image_ranges())),
}
