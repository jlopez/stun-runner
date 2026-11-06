"""The source side of `make ida-sync` (ida/jsa_source.py, docs/05-ida.md section 6), in CI.

No IDA here: the extraction of names, comments, functions and the classification from the 6502
source is checked on a synthetic tree and on asm/jsa, both assembled with 64tass; the committed
6502 snapshot must carry the source's names, functions and classification (so a rename in the
source without a sync fails here), and the setup of ida/memory_map.py must have the I/O names of
hardware.asm. The IDA side (ida/headless/sync.py) needs idalib: tools/test_ida.py's round trip
and `make ida && make ida-sync` (docs/05 section 6).
"""

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

import pytest

from ida import jsa_source as js
from ida.memory_map import DATABASES, IO_JSA
from ida.snapshot import Comment, DataItem, Name, loads, merge_ranges

REPO = Path(__file__).resolve().parents[1]
SNAPSHOT = REPO / "data" / "ida" / "stunrun-jsa.json"


def have_tass() -> bool:
    try:
        js.tass_program()
    except FileNotFoundError:
        return False
    return True


needs_tass = pytest.mark.skipif(not have_tass(), reason="64tass not available")


# --- pure helpers ----------------------------------------------------------------------------------


def test_ida_addresses() -> None:
    assert [js.ida_ea(x) for x in (0x0000, 0x0FFF, 0x1000, 0x3ABC, 0x4000, 0xFFFF)] == [
        0x13000,
        0x13FFF,
        0x23000,
        0x43ABC,
        0x4000,
        0xFFFF,
    ]
    for offset in (0, 0x1234, 0x3FFF, 0x4000, 0xAC48):
        assert js.source_value(js.ida_ea(offset)) == offset
    assert js.source_value(0x0010) == 0x0010  # RAM
    assert js.in_image(0x23000) and js.in_image(0x4000) and not js.in_image(0x2800)
    assert sum(b - a for a, b in js.image_ranges()) == 0x10000
    with pytest.raises(ValueError):
        js.ida_ea(0x10000)


def test_split_comment() -> None:
    assert js.split_comment("    lda #$01   ; one; two  ") == ("    lda #$01", "one; two")
    assert js.split_comment('    .cerror * != 1, "a; b" ; c') == ('    .cerror * != 1, "a; b"', "c")
    assert js.split_comment("; the 68010's command") == ("", "the 68010's command")
    assert js.split_comment("    rts") == ("    rts", None)
    assert js.clean_block(["---------", "", "text", "  more", "", "----"]) == ["text", "  more"]


def test_markers_go_before_labels_and_statements() -> None:
    text = "\n".join(
        [
            "; comment",
            "label ; with a comment",
            "_local",
            "    lda #1",
            "    #macro $01",
            "    .cerror * != 1, 'x'",
            '    .include "x.asm"',
            "* = $0000",
            "",
            "    ; indented comment",
        ]
    )
    out, marks = js.instrument(text, 7)
    assert marks == {"sync__7": 2, "sync__8": 3, "sync__9": 4, "sync__10": 5}
    assert out.splitlines()[1:3] == ["sync__7 = *", "label ; with a comment"]


def test_listing_statements() -> None:
    listing = "\n".join(
        [
            ";Offset\t;Hex\t\t;Monitor\t;Source",
            ".4000\t\t\t\t\treset",
            ".4000\t78\t\tsei\t\t    sei",
            ".4001\ta2 ff\t\tldx #$ff\t    ldx #$FF ; comment",
            ">4003\t01 02 03\t\t\t\t    .byte 1, 2, 3",
            ">4006\t00 40 01 40\t\t\t    .word reset, $4001",
            ">400a\t00 00 00 00 00 00 00 00\t\t    .fill 12, 0",
            ">4012\t00 00 00 00",
            ">4016\t9d\t\t\t\t    .byte $9D",
        ]
    )
    sts = js.listing_statements(listing, 0x4017)
    assert [(s.offset, s.kind, s.size) for s in sts] == [
        (0x4000, "code", 1),
        (0x4001, "code", 2),
        (0x4003, "byte", 3),
        (0x4006, "word", 4),
        (0x400A, "fill", 12),
        (0x4016, "byte", 1),
    ]
    assert sts[3].operands == "reset, $4001"
    assert js.data_item(sts[3], {"reset"}) == DataItem(0x4006, "word", 2, False)  # mixed
    labels = {"reset", "sub"}
    bank = 0x23000 - 0x10000 + 0x10
    assert js.data_item(js.Statement(0x10, "word", "reset, sub", 4), labels) == DataItem(
        bank, "word", 2, True
    )
    # an RTS-dispatch entry: the offset's target is the label, its delta the -1
    assert js.data_item(js.Statement(0x10, "word", "sub-1", 2), labels) == DataItem(
        bank, "word", 1, True, -1
    )
    assert js.data_item(js.Statement(0x10, "word", "sub - $2, reset-2", 4), labels) == DataItem(
        bank, "word", 2, True, -2
    )
    for plain in ("reset, reset+2", "reset*2", "reset>>8", "ptr", "PORT+1", "$1234"):
        assert js.data_item(js.Statement(0x10, "word", plain, 2), labels).offset is False, plain
    assert js.data_item(sts[4], set()) == DataItem(0x400A, "byte", 12, False)


def test_equates() -> None:
    text = "\n".join(
        [
            "; file header",
            "",
            "; 2 bytes: a pointer",
            "ptr = $10",
            "count = $12                             ; how many",
            "                                        ; continued",
            "BIT = $01                               ; not in range: a constant",
            "MIRROR = ptr + 8                        ; ptr's mirror",
        ]
    )
    known: dict[str, int] = {}

    def value(name: str, expr: str) -> int | None:
        v = js.evaluate(expr, known)
        if v is not None:
            known[name] = v
        return v

    found, loose = js.equates("ram.asm", text, 0x10, 0x20, value)
    assert [(e.ea, e.name, e.comment) for e in found] == [
        (0x10, "ptr", "2 bytes: a pointer"),
        (0x12, "count", "how many\ncontinued"),
        (0x18, "MIRROR", "ptr's mirror"),
    ]
    assert loose[0].startswith("ram.asm:1 file header")
    assert any("constant BIT" in x for x in loose)
    assert js.evaluate("$2800 + 8", {}) == 0x2808 and js.evaluate("x * 2", {"x": 1}) is None


# --- a synthetic tree, assembled --------------------------------------------------------------------

TREE = {
    "jsa.asm": """; the main file: its header belongs to no address

    .include "hardware.asm"
    .include "ram.asm"
    .include "data/macros.asm"

* = $0000
pages
    .fill $4000, 0                      ; the four bank pages
    .include "system.asm"
    .include "data/table.asm"
""",
    "hardware.asm": """; header

PORT = $2800                            ; a port
BIT = $01                               ; a bit, not an address
""",
    "ram.asm": """; 2 bytes: a pointer
ptr = $10
count = $12                             ; how many
                                        ; and a second line
""",
    "data/macros.asm": """pair .macro a, b                        ; a macro's comment stays out
    .byte \\a
    .word \\b
.endm
""",
    "system.asm": """; system.asm: a file header

; ---------------------------------------------------------------------------------
; The reset routine.
;
; Second paragraph.
; ---------------------------------------------------------------------------------
reset
    ldx #$FF                            ; the stack
_loop
    dex
    bne _loop
    ; an indented block above
    jsr sub
    jmp reset

; Helper.
sub
    lda ptr                             ; read
                                        ; continued
    rts
""",
    "data/table.asm": """; A table.
table
    .byte 1, 2, 3                       ; three
    .word sub, reset                    ; offsets
    .word $1234
    #pair $05, sub                      ; a macro call
    .word reset-1                       ; an RTS-dispatch entry
""",
}


@pytest.fixture(scope="module")
def synthetic(tmp_path_factory: pytest.TempPathFactory) -> js.Source:
    tree = tmp_path_factory.mktemp("tree")
    for rel, text in TREE.items():
        (tree / rel).parent.mkdir(parents=True, exist_ok=True)
        (tree / rel).write_text(text)
    return js.load(tree)


@needs_tass
def test_synthetic_names_and_functions(synthetic: js.Source) -> None:
    s = synthetic
    reset, loop, sub, table = 0x4000, 0x4002, 0x400B, 0x400E
    assert s.global_names() == {
        0x10: "ptr",
        0x12: "count",
        0x2800: "PORT",
        0x13000: "pages",
        reset: "reset",
        sub: "sub",
        table: "table",
    }
    assert s.local_names() == {loop: "_loop"}
    assert s.scope[loop] == "reset"
    assert s.functions == [reset, sub]  # code labels of a file with code; table is data
    assert s.left_out == []


@needs_tass
def test_functions_follow_a_renamed_code_file(synthetic: js.Source, tmp_path: Path) -> None:
    """The code files are derived from the listing: a code file under a new name keeps its
    functions (a fixed file list would silently drop them)."""
    tree = {k: v for k, v in TREE.items() if k != "system.asm"}
    tree["routines_renamed.asm"] = TREE["system.asm"]
    tree["jsa.asm"] = TREE["jsa.asm"].replace('"system.asm"', '"routines_renamed.asm"')
    for rel, text in tree.items():
        (tmp_path / rel).parent.mkdir(parents=True, exist_ok=True)
        (tmp_path / rel).write_text(text)
    renamed = js.load(tmp_path)
    assert renamed.functions == synthetic.functions == [0x4000, 0x400B]
    assert renamed.global_names() == synthetic.global_names()


@needs_tass
def test_synthetic_comments(synthetic: js.Source) -> None:
    c = {(x.ea, x.kind): x.text for x in synthetic.comments}
    assert c[(0x4000, "function")] == "The reset routine.\n\nSecond paragraph."
    assert c[(0x4000, "regular")] == "the stack"
    assert c[(0x4005, "regular")] == "an indented block above"
    assert c[(0x400B, "function")] == "Helper."
    assert c[(0x400B, "regular")] == "read\ncontinued"
    assert c[(0x400E, "repeatable")] == "A table."
    assert c[(0x400E, "regular")] == "three"
    assert c[(0x4011, "regular")] == "offsets"
    assert c[(0x4017, "regular")] == "a macro call"
    assert c[(0x401A, "regular")] == "an RTS-dispatch entry"
    assert c[(0x13000, "regular")] == "the four bank pages"
    assert c[(0x10, "repeatable")] == "2 bytes: a pointer"
    assert c[(0x12, "repeatable")] == "how many\nand a second line"
    assert c[(0x2800, "repeatable")] == "a port"
    assert not any("macro's comment" in x.text for x in synthetic.comments)
    assert len(c) == len(synthetic.comments)
    assert any(x.startswith("jsa.asm:1 ") for x in synthetic.loose)
    assert any(x.startswith("system.asm:1 ") for x in synthetic.loose)


@needs_tass
def test_synthetic_classification(synthetic: js.Source) -> None:
    s = synthetic
    assert s.code == [
        (0x4000, 2),  # ldx #$FF
        (0x4002, 1),  # dex
        (0x4003, 2),  # bne
        (0x4005, 3),  # jsr
        (0x4008, 3),  # jmp
        (0x400B, 2),  # lda ptr: zero page
        (0x400D, 1),  # rts
    ]
    assert s.data == [
        # one .fill over file 0000-3FFF: one item per bank page (each its own IDA segment)
        *[DataItem(js.ida_ea(n * 0x1000), "byte", 0x1000) for n in range(4)],
        DataItem(0x400E, "byte", 3),
        DataItem(0x4011, "word", 2, True),
        DataItem(0x4015, "word", 1, False),
        DataItem(0x4017, "byte", 1),  # the macro's .byte
        DataItem(0x4018, "word", 1, True),  # and its .word
        DataItem(0x401A, "word", 1, True, -1),  # reset-1: an offset to reset, delta -1
    ]


# --- the real tree and the committed snapshot -------------------------------------------------------


@pytest.fixture(scope="module")
def source() -> js.Source:
    return js.load()


@needs_tass
def test_source_tiles_the_image(source: js.Source) -> None:
    """Every byte of 136070-2123.10c is in exactly one instruction or data item."""
    spans = sorted(
        [(ea, size) for ea, size in source.code]
        + [(d.ea, d.count * (2 if d.type == "word" else 1)) for d in source.data]
    )
    covered: list[tuple[int, int]] = []
    for ea, size in spans:
        assert not covered or ea >= covered[-1][1], f"{ea:06X} overlaps"
        covered.append((ea, ea + size))
    assert merge_ranges(covered) == merge_ranges(js.image_ranges())
    assert source.left_out == []


@needs_tass
def test_committed_snapshot_has_the_source_names(source: js.Source) -> None:
    """The names of data/ida/stunrun-jsa.json are the source's, both ways, globals and locals:
    a label renamed in asm/jsa without `make ida && make ida-sync WRITE=1 && make ida-export`
    fails here."""
    snap = loads(SNAPSHOT.read_text())
    assert set(snap.names) == set(source.names)


@needs_tass
def test_committed_snapshot_has_the_source_functions_and_classification(
    source: js.Source,
) -> None:
    snap = loads(SNAPSHOT.read_text())
    assert set(source.functions) <= set(snap.functions)
    assert snap.code == merge_ranges((ea, ea + size) for ea, size in source.code)
    in_image = {d for d in snap.data if js.in_image(d.ea)}
    expected = set(source.data)
    # the setup's vector words are offsets that the source also writes as `.word label`
    assert in_image == expected
    spec = DATABASES["jsa"]
    assert spec.classified == tuple(js.image_ranges())


@needs_tass
def test_setup_io_is_hardware_asm(source: js.Source, tmp_path: Path) -> None:
    """ida/memory_map.py's 6502 I/O names and comments are hardware.asm's (it reads them from the
    file; here against what 64tass resolved and what the sync writes)."""
    syms = js.assembled_symbols(js.TREE, tmp_path)
    hardware = "\n" + (js.TREE / "hardware.asm").read_text()
    io_names = {n for n, v in syms.items() if 0x2000 <= v < 0x3000 and f"\n{n} " in hardware}
    assert {name for _, name, _ in IO_JSA} == io_names
    for ea, name, comment in IO_JSA:
        assert syms[name] == ea, name
        assert Name(ea, name) in source.names
        assert Comment(ea, "repeatable", comment) in source.comments


def test_committed_snapshot_is_json() -> None:
    assert json.loads(SNAPSHOT.read_text())["database"] == "stunrun-jsa"


def rename_in_tree(tree: Path, old: str, new: str) -> None:
    """`old` renamed to `new`, as a whole word, in every file of the tree."""
    pattern = re.compile(rf"(?<![A-Za-z0-9_]){re.escape(old)}(?![A-Za-z0-9_])")
    for path in tree.rglob("*.asm"):
        text = path.read_text()
        if pattern.search(text):
            path.write_text(pattern.sub(new, text))


@needs_tass
def test_a_rename_without_a_sync_is_caught(source: js.Source, tmp_path: Path) -> None:
    """A planted rename (a routine's global and a local) in a copy of asm/jsa: its names no
    longer equal the committed snapshot's, which is what
    test_committed_snapshot_has_the_source_names sees. The two labels are picked from the
    source, not named here, so that a later leg's own rename (with its sync) does not break this
    test."""
    globals_ = source.global_names()
    locals_ = list(source.local_names().values())
    victim_global = globals_[source.functions[0]]
    victim_local = next(n for n in locals_ if locals_.count(n) == 1)  # one local of that name
    tree = tmp_path / "jsa"
    shutil.copytree(js.TREE, tree)
    rename_in_tree(tree, victim_global, f"{victim_global}_planted")
    rename_in_tree(tree, victim_local, f"{victim_local}_planted")
    renamed = js.load(tree)
    assert {n.name for n in set(source.names) - set(renamed.names)} == {victim_global, victim_local}
    assert {n.name for n in set(renamed.names) - set(source.names)} == {
        f"{victim_global}_planted",
        f"{victim_local}_planted",
    }
    # the committed snapshot holds the source's names (test above): the copy no longer matches it
    snap = loads(SNAPSHOT.read_text())
    assert set(snap.names) != set(renamed.names)


@needs_tass
def test_an_equate_outside_the_constants_files_fails(tmp_path: Path) -> None:
    """A RAM equate moved from ram.asm into a file of its own (the image unchanged) would drop
    its name out of the database without a word: the load fails instead and names the file."""
    (tmp_path / "work").mkdir()
    (tmp_path / "moved").mkdir()
    syms = js.assembled_symbols(js.TREE, tmp_path / "work")
    tree = tmp_path / "jsa"
    shutil.copytree(js.TREE, tree)
    ram = (tree / "ram.asm").read_text().splitlines(keepends=True)
    no, line = next(
        (i, x)
        for i, x in enumerate(ram)
        if (m := js.EQUATE.match(js.split_comment(x)[0]))
        and m.group(1) in syms
        and syms[m.group(1)] < 0x2000
        and "*" not in m.group(2)
    )
    name = js.EQUATE.match(js.split_comment(line)[0]).group(1)  # type: ignore[union-attr]
    (tree / "ram.asm").write_text("".join(ram[:no] + ram[no + 1 :]))
    (tree / "ram_moved.asm").write_text(line)
    main = (tree / "jsa.asm").read_text()
    assert '    .include "ram.asm"\n' in main
    main = main.replace(
        '    .include "ram.asm"\n', '    .include "ram.asm"\n    .include "ram_moved.asm"\n'
    )
    (tree / "jsa.asm").write_text(main)
    assert js.assembled_symbols(tree, tmp_path / "moved")[name] == syms[name]
    with pytest.raises(ValueError, match=rf"ram_moved\.asm:1: the equate {name} "):
        js.load(tree)


def _plant_in_oki(tmp_path: Path, define: str, old: str | None = None, new: str = "") -> Path:
    """A copy of asm/jsa with `define` before oki.asm's first label and, if `old` is given, its
    first instruction line `old` (stripped) replaced by `new` (the same bytes)."""
    tree = tmp_path / "jsa"
    shutil.copytree(js.TREE, tree)
    lines = (tree / "oki.asm").read_text().splitlines(keepends=True)
    if old is not None:
        at = next(i for i, x in enumerate(lines) if x.strip() == old)
        lines[at] = lines[at].replace(old, new)
    first = next(
        i
        for i, x in enumerate(lines)
        if x[:1].strip() and js.GLOBAL_LABEL.match(js.split_comment(x)[0])
    )
    lines.insert(first, define + "\n")
    (tree / "oki.asm").write_text("".join(lines))
    (tmp_path / "work").mkdir()
    assert js._assemble(tree, tmp_path / "work" / "a.bin") == js._assemble(
        js.TREE, tmp_path / "work" / "b.bin"
    )
    return tree


@needs_tass
@pytest.mark.parametrize("form", ["=", ":=", ".var"])
def test_an_address_equate_outside_the_constants_files_fails(tmp_path: Path, form: str) -> None:
    """A RAM equate defined in a code file in any 64tass form (`=`, `:=`, `.var`) and used as a
    memory operand fails the load (the image unchanged)."""
    syms = js.assembled_symbols(js.TREE, tmp_path)
    value = syms["wrio_shadow"]
    tree = _plant_in_oki(tmp_path, f"zz_addr {form} ${value:04X}", "lda wrio_shadow", "lda zz_addr")
    with pytest.raises(
        ValueError, match=rf"oki\.asm:\d+: the equate zz_addr = \${value:04X} is used as an address"
    ):
        js.load(tree)


@needs_tass
def test_a_constant_outside_the_constants_files_loads(tmp_path: Path) -> None:
    """A small constant (a count, a mask) used only as an immediate is no address: it stays in its
    code file, the load succeeds and the database gets no name for it."""
    tree = _plant_in_oki(tmp_path, "ZZ_COUNT = $11 ; a count", "ldx #$11", "ldx #ZZ_COUNT")
    src = js.load(tree)
    assert not [n for n in src.names if n.name == "ZZ_COUNT"]
    assert src.global_names() == js.load().global_names()


@needs_tass
def test_an_unused_equate_outside_the_constants_files_fails(tmp_path: Path) -> None:
    """An equate in 0000-2FFF that nothing uses cannot be told from a RAM name: it fails."""
    tree = _plant_in_oki(tmp_path, "zz_ram := $0010")
    with pytest.raises(ValueError, match=r"the equate zz_ram = \$0010 is used nowhere"):
        js.load(tree)


def test_address_uses() -> None:
    """The leading name of a memory operand, an address byte or a pointer is an address; a plain
    immediate, a .byte value and an offset after the leading name are constants."""
    st = [
        js.Statement(0x4000, "code", "lda ram_a+1,x", 3),
        js.Statement(0x4003, "code", "jmp (ram_b)", 3),
        js.Statement(0x4006, "code", "lda #<ram_c", 2),
        js.Statement(0x4008, "code", "ldx #COUNT", 2),
        js.Statement(0x400A, "code", "lda table+OFFSET", 3),
        js.Statement(0x400D, "code", "asl a", 1),
        js.Statement(0x400E, "word", "ram_d, ram_e-1", 4),
        js.Statement(0x4012, "byte", "MASK, >ram_f", 2),
    ]
    assert js.address_uses(st) == {
        "ram_a": 0x4000,
        "ram_b": 0x4003,
        "ram_c": 0x4006,
        "table": 0x400A,
        "ram_d": 0x400E,
        "ram_e": 0x400E,
        "ram_f": 0x4012,
    }
