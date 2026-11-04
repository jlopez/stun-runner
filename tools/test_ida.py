"""Tests of the IDA side (docs/05-ida.md).

The snapshot helpers and the memory-map setups are pure Python and run everywhere (CI included),
on synthetic structures and synthetic images. The round trip create -> export against the
committed snapshots needs idalib and the build images: it is skipped without them (CI).
"""

from __future__ import annotations

import importlib.util
import struct
import subprocess
import sys
from collections.abc import Iterable
from dataclasses import replace
from pathlib import Path

import pytest

from ida.code_map import CODE_MAP_68K, GAME_VECTORS
from ida.memory_map import (
    DATABASES,
    IO_68K,
    IO_JSA,
    JSA_READ_MIRROR_MASK,
    SEGMENTS_68K,
    SEGMENTS_JSA,
    jsa_bank_base,
    setup_68k,
    setup_68k_full,
    setup_jsa,
    vector_name_68k,
)
from ida.snapshot import (
    Comment,
    DataItem,
    Name,
    Segment,
    Snapshot,
    apply,
    dumps,
    export,
    ida_generated_comment,
    ida_generated_name,
    loads,
)

REPO = Path(__file__).resolve().parents[1]
SNAPSHOTS = REPO / "data" / "ida"


class FakeDatabase:
    """An in-memory `ida.snapshot.Database` that records the order of the calls."""

    def __init__(self) -> None:
        self.segs: dict[int, Segment] = {}
        self.name_map: dict[int, str] = {}
        self.funcs: list[int] = []
        self.cmts: dict[tuple[int, str], str] = {}
        self.items: dict[int, DataItem] = {}
        self.calls: list[str] = []

    def segments(self) -> list[Segment]:
        return list(self.segs.values())

    def add_segment(self, segment: Segment) -> None:
        self.calls.append("segment")
        self.segs[segment.start] = segment

    def names(self) -> list[Name]:
        return [Name(ea, n) for ea, n in self.name_map.items()]

    def set_name(self, ea: int, name: str) -> None:
        self.calls.append("name")
        self.name_map[ea] = name

    def function_starts(self) -> list[int]:
        return list(self.funcs)

    def add_function(self, ea: int) -> None:
        self.calls.append(f"function {ea:X}")
        if ea not in self.funcs:
            self.funcs.append(ea)

    def comments(self, eas: Iterable[int]) -> list[Comment]:
        wanted = set(eas) | {ea for ea, _ in self.cmts}
        return [Comment(ea, k, t) for (ea, k), t in self.cmts.items() if ea in wanted]

    def set_comment(self, comment: Comment) -> None:
        self.calls.append("comment")
        self.cmts[(comment.ea, comment.kind)] = comment.text

    def data_item(self, ea: int) -> DataItem | None:
        return self.items.get(ea)

    def create_data(self, item: DataItem) -> None:
        self.calls.append("data")
        self.items[item.ea] = item


def sample() -> Snapshot:
    return Snapshot(
        "sample",
        "68010",
        [
            Segment(0xFF8000, 0x1000000, "RAM", "DATA", 32, None, "work RAM"),
            Segment(0, 0x1000, "ROM", "CODE", 32, 0),
        ],
        [Name(0x200, "reset"), Name(0x0, "vec_reset_sp"), Name(0xFF8000, "ram_start")],
        [0x300, 0x200],
        [
            Comment(0x200, "function", "vectors: vec_reset_pc"),
            Comment(0x200, "regular", "first instruction"),
            Comment(0x0, "repeatable", 'stack "top"\nsecond line, é'),
        ],
        [DataItem(0x0, "dword", 1, False), DataItem(0x4, "dword", 2, True)],
    )


# --- the snapshot ------------------------------------------------------------------------------


def test_apply_then_export_round_trips() -> None:
    db = FakeDatabase()
    apply(sample(), db)
    db.name_map[0x4] = "vec_reset_pc"  # export reports data items only at named addresses
    expected = sample()
    expected.names.append(Name(0x4, "vec_reset_pc"))
    assert export(db, "sample", "68010") == expected.normalized()


def test_apply_order() -> None:
    db = FakeDatabase()
    apply(sample(), db)
    kinds = [c.split()[0] for c in db.calls]
    assert kinds == sorted(kinds, key=["segment", "data", "function", "name", "comment"].index)
    # functions from the highest address down (a function made first absorbs later starts)
    assert [c for c in db.calls if c.startswith("function")] == ["function 300", "function 200"]


def test_dumps_is_stable_and_loads_back() -> None:
    text = dumps(sample())
    shuffled = sample()
    shuffled.names.reverse()
    shuffled.comments.reverse()
    shuffled.segments.reverse()
    assert dumps(shuffled) == text
    assert loads(text) == sample().normalized()
    assert text.endswith("}\n")
    lines = text.splitlines()
    assert lines[1] == '  "database": "sample",'
    assert '    {"ea": "0x000000", "name": "vec_reset_sp"},' in lines
    assert '    "0x000200",' in lines  # functions sorted, one per line
    assert "é" in text  # UTF-8, not \u escapes


def test_empty_lists() -> None:
    text = dumps(Snapshot("e", "M6502"))
    assert '  "names": [],' in text.splitlines()
    assert loads(text) == Snapshot("e", "M6502")


def test_ida_generated_annotations_are_left_out() -> None:
    db = FakeDatabase()
    db.name_map.update({0x10: "jpt_24540", 0x20: "def_24A2C", 0x30: "jpt_menu", 0x40: "sub_40"})
    db.cmts.update(
        {
            (0x10, "regular"): "switch 70 cases",
            (0x12, "regular"): "switch jump",
            (0x14, "regular"): "jump table for switch statement",
            (0x16, "repeatable"): "jumptable 00024540 default case, cases 3,5-7",
            (0x18, "repeatable"): "jumptable 00024540 case 14",
            (0x1A, "regular"): "trap_0_instruction_entry\ntrap_1_instruction_entry",
            (0x1C, "regular"): "initial_sp\nfp_inexact_result_entry",
            (0x1E, "regular"): "switch 70 cases: the menu dispatch",  # edited by hand: kept
        }
    )
    snap = export(db, "x", "68010")
    assert [n.name for n in snap.names] == ["jpt_menu", "sub_40"]
    assert [c.text for c in snap.comments] == ["switch 70 cases: the menu dispatch"]
    assert ida_generated_name("def_FF") and not ida_generated_name("def_menu")
    assert not ida_generated_comment("jumptable 00024540 case 14, and why")


# --- the memory maps -----------------------------------------------------------------------------


def synthetic_68k() -> bytes:
    image = bytearray(0xC0000)
    vectors = [0] * 64
    vectors[0] = 0xFFFFC000  # reset SP: not code
    vectors[1] = 0x400  # reset PC
    vectors[2] = 0x500  # bus error, alone
    vectors[3] = 0x501  # odd: not code
    vectors[24] = vectors[31] = 0x600  # spurious and level 7 share a handler
    for n in range(32, 48):
        vectors[n] = 0x700  # the sixteen traps
    vectors[26] = 0x800000  # outside the ROM
    struct.pack_into(">64I", image, 0, *vectors)
    game = [0] * 64
    game[1] = 0x21000  # the game's reset
    game[26] = 0x21100  # level 2
    game[9] = game[10] = 0x21200  # trace and line A share a handler
    struct.pack_into(">64I", image, GAME_VECTORS, *game)
    return bytes(image)


def test_setup_68k() -> None:
    snap = setup_68k(synthetic_68k())
    names = {n.ea: n.name for n in snap.names}
    assert names[0x000] == "vec_reset_sp" and names[0x004] == "vec_reset_pc"
    assert names[0x068] == "vec_level2_adsp" and names[0x0FC] == "vec_reserved_63"
    assert names[0x400] == "boot_reset" and names[0x500] == "boot_bus_error"
    assert names[0x600] == "boot_spurious_interrupt_etc" and names[0x700] == "boot_trap_0_etc"
    assert names[0x20004] == "game_vec_reset_pc" and names[0x21000] == "game_reset"
    assert names[0x21100] == "h_level2_adsp" and names[0x21200] == "h_trace_etc"
    assert snap.functions == [0x400, 0x500, 0x600, 0x700, 0x21000, 0x21100, 0x21200]
    offsets = {d.ea for d in snap.data if d.offset}
    boot = {4, 8, 0x60, 0x7C} | {4 * n for n in range(32, 48)}
    assert offsets == boot | {GAME_VECTORS + 4 * n for n in (1, 9, 10, 26)}
    assert len(snap.data) == 128 and all(d.type == "dword" for d in snap.data)
    assert (
        Comment(0x600, "function", "vectors: vec_spurious_interrupt, vec_level7_nmi")
        in snap.comments
    )
    assert (
        Comment(0x21200, "function", "vectors: game_vec_trace, game_vec_line_a") in snap.comments
    )
    for ea, name, _ in IO_68K:
        assert names[ea] == name
        assert Comment(ea, "repeatable", _) in snap.comments
    with pytest.raises(ValueError):
        setup_68k(b"\0" * 100)


def test_setup_68k_full_adds_the_code_map_once() -> None:
    with pytest.raises(ValueError, match="handler comment"):
        setup_68k_full(synthetic_68k())  # the handlers code_map comments are not targets here
    snap = setup_68k_full(real_like_68k())
    names = {n.ea: n.name for n in snap.names}
    for entry in CODE_MAP_68K:
        if entry.name:
            assert names[entry.ea] == entry.name
        if entry.kind == "function":
            assert entry.ea in snap.functions
    function_comments = [c.ea for c in snap.comments if c.kind == "function"]
    assert len(function_comments) == len(set(function_comments))
    reset = next(c.text for c in snap.comments if c.ea == 0x216 and c.kind == "function")
    assert reset.startswith("vectors: vec_reset_pc\nBoot reset")


def real_like_68k() -> bytes:
    """Vector tables with the real targets (addresses, not ROM bytes: docs/05 and docs/06)."""
    image = bytearray(0xC0000)
    boot = [0] * 64
    boot[1], boot[25], boot[26], boot[27] = 0x216, 0x7FA, 0x7F0, 0x7D6
    boot[28], boot[29], boot[30] = 0x81C, 0x82C, 0x812
    game = [0] * 64
    game[1], game[2], game[3], game[4], game[5] = 0x212AE, 0x22954, 0x229B4, 0x229A4, 0x22994
    game[6], game[7], game[8], game[9] = 0x22984, 0x22964, 0x22974, 0x229D4
    game[26], game[27], game[28], game[29] = 0x213FE, 0x2143C, 0x23F24, 0x222DA
    game[30], game[31] = 0x239FE, 0x229C4
    struct.pack_into(">64I", image, 0, *boot)
    struct.pack_into(">64I", image, GAME_VECTORS, *game)
    return bytes(image)


def test_vector_names() -> None:
    assert [vector_name_68k(n) for n in (5, 14, 25, 29, 30, 47, 48, 64)] == [
        "vec_zero_divide",
        "vec_format_error",
        "vec_level1_msp",
        "vec_level5_timer",
        "vec_level6_duart",
        "vec_trap_15",
        "vec_reserved_48",
        "vec_user_64",
    ]
    assert len({vector_name_68k(n) for n in range(256)}) == 256


def test_setup_jsa() -> None:
    image = bytearray(0x10000)
    struct.pack_into("<3H", image, 0xFFFA, 0x5000, 0x4000, 0x4100)
    snap = setup_jsa(bytes(image))
    names = {n.ea: n.name for n in snap.names}
    assert names[0x4000] == "reset" and names[0x5000] == "h_nmi" and names[0x4100] == "h_irq"
    assert names[0xFFFC] == "vec_reset" and snap.functions == [0x4000, 0x4100, 0x5000]
    assert all(d.type == "word" and d.offset for d in snap.data)
    for ea, name, _ in IO_JSA:
        assert names[ea] == name


@pytest.mark.parametrize("segments", [SEGMENTS_68K, SEGMENTS_JSA])
def test_segments_do_not_overlap_and_labels_fall_inside(segments: list[Segment]) -> None:
    ordered = sorted(segments)
    for a, b in zip(ordered, ordered[1:], strict=False):
        assert a.end <= b.start
    table = IO_68K if segments is SEGMENTS_68K else IO_JSA
    for ea, _, _ in table:
        assert any(s.start <= ea < s.end for s in segments), hex(ea)
    assert len({name for _, name, _ in table}) == len(table)


def test_jsa_read_port_mirrors_are_labelled() -> None:
    # rev 6 reads the 2800-2806 ports only through 2808/280A/280C/280E (docs/05 section 4)
    names = {ea: name for ea, name, _ in IO_JSA}
    for base, used in [(0x2800, 0x2808), (0x2802, 0x280A), (0x2804, 0x280C), (0x2806, 0x280E)]:
        assert names[used] == names[base] + "_M"
        assert (used ^ base) & ~JSA_READ_MIRROR_MASK == 0
    comments = {ea: text for ea, _, text in IO_JSA}
    assert "mirror of 2802" in comments[0x280A] and "/RDP" in comments[0x280A]
    # the write ports and the YM2151 are not mirrored here
    assert 0x2A08 not in names and 0x2002 not in names


def test_jsa_banks() -> None:
    assert [jsa_bank_base(n) for n in range(4)] == [0x13000, 0x23000, 0x33000, 0x43000]
    banks = [s for s in SEGMENTS_JSA if s.name.startswith("BANK")]
    assert [(s.file_offset, s.end - s.start) for s in banks] == [
        (n * 0x1000, 0x1000) for n in range(4)
    ]
    # the file tiles exactly: four pages, then the 4000-FFFF window
    rom = [s for s in SEGMENTS_JSA if s.file_offset is not None]
    assert sum(s.end - s.start for s in rom) == 0x10000


# --- the committed snapshots ---------------------------------------------------------------------


@pytest.mark.parametrize("key", list(DATABASES))
def test_committed_snapshot_is_canonical_and_has_the_memory_map(key: str) -> None:
    spec = DATABASES[key]
    text = (SNAPSHOTS / f"{spec.name}.json").read_text()
    snap = loads(text)
    assert dumps(snap) == text, "not in canonical form: regenerate with make ida-export"
    assert snap.processor == spec.processor
    table, segments = (IO_68K, SEGMENTS_68K) if key == "68k" else (IO_JSA, SEGMENTS_JSA)
    assert {(ea, name) for ea, name, _ in table} <= {(n.ea, n.name) for n in snap.names}
    assert set(segments) <= set(snap.segments)
    assert (SNAPSHOTS / f"{spec.name}.functions.jsonl").exists()


# --- the round trip through idalib ----------------------------------------------------------------

IMAGES = [REPO / "build" / f"{spec.name}.bin" for spec in DATABASES.values()]
needs_idalib = pytest.mark.skipif(
    importlib.util.find_spec("idapro") is None or not all(p.exists() for p in IMAGES),
    reason="needs idalib (uv sync --group ida) and the build images (make)",
)


def run(*args: str) -> None:
    subprocess.run([sys.executable, "-m", *args], cwd=REPO, check=True, capture_output=True)


@needs_idalib
def test_create_export_reproduces_the_committed_snapshots(tmp_path: Path) -> None:
    run("ida.headless.create", "all", "--out", str(tmp_path / "db"))
    run(
        "ida.headless.export",
        "all",
        "--data",
        str(tmp_path / "db"),
        "--out",
        str(tmp_path / "ida"),
        "--listing",
        str(tmp_path / "listing"),
    )
    for spec in DATABASES.values():
        for suffix in (".json", ".functions.jsonl"):
            name = spec.name + suffix
            assert (tmp_path / "ida" / name).read_text() == (SNAPSHOTS / name).read_text(), name
        assert (tmp_path / "listing" / f"{spec.name}.asm").stat().st_size > 0


@needs_idalib
def test_an_annotation_survives_create_and_export(tmp_path: Path) -> None:
    """What a GUI session would add (a function name, comments) goes through the snapshot."""
    committed = loads((SNAPSHOTS / "stunrun-jsa.json").read_text())
    func = next(ea for ea in committed.functions if ea not in {n.ea for n in committed.names})
    edited = replace(
        committed,
        names=[*committed.names, Name(func, "test_annotation")],
        comments=[
            *committed.comments,
            Comment(func, "regular", "a test comment"),
            Comment(func, "function", "a function comment"),
        ],
    ).normalized()
    snapshots = tmp_path / "snapshots"
    snapshots.mkdir()
    (snapshots / "stunrun-jsa.json").write_text(dumps(edited))
    run("ida.headless.create", "jsa", "--out", str(tmp_path / "db"), "--snapshots", str(snapshots))
    run(
        "ida.headless.export",
        "jsa",
        "--data",
        str(tmp_path / "db"),
        "--out",
        str(tmp_path / "ida"),
        "--listing",
        str(tmp_path / "listing"),
    )
    assert (tmp_path / "ida" / "stunrun-jsa.json").read_text() == dumps(edited)
