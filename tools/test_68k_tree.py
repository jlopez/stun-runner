"""The 68k tree (docs/13-68k-source.md, docs/16-68k-code.md): region files, guards, fills, the
program table, the hardware and RAM equates, `make labels` and the checks on the tree's own
listing (tools/m68k check-tree), on random bytes, never ROM data.

The structural tests read asm/68k only; the assembled ones (vasm on PATH or in $VASM, as in CI)
assemble the committed tree against a random blob laid out like build/ (the image, the ADSP and
GSP programs cut out of it) and check what the tree itself contributes: every incbin slice takes
the blob's bytes at its own address, the zero fills, the program table; the code is source since
M5c, so the descent check, the address lint, the raw-data check and the shift test run on that
listing, and each fails on the fault it exists for.
"""

from __future__ import annotations

import dataclasses
import json
import os
import random
import re
import shutil
import struct
import subprocess
import sys
import types
from pathlib import Path

import pytest
from gspimages import REGION, REGION_END, write_includes
from listings import vasm_symbols
from m68k import classify as cl
from m68k import listing as ls
from m68k import operands as opd
from m68k import tree as tr
from m68k.__main__ import load_seeds, load_unreached
from m68k.sound import write_equates
from programs import ADSP_START, GSP_END, GSP_START, PROGRAM_TABLE

from ida.memory_map import IO_68K

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
TREE = REPO / "asm/68k"
IMAGE_SIZE = 0xC0000

# The partition (docs/13 section 2, docs/06 section 4): file, start, end. M5c (docs/16) cut the
# boot and game code into files of about 16 KB at routine starts, named by their first address.
BOOT_CUTS = [0x000212, 0x00394E, 0x0065E0, 0x009E80, 0x00DDF2, 0x0109D4, 0x012F06]
GAME_CUTS = [0x020430, 0x024306, 0x028194, 0x02C0D2, 0x030012, 0x034010, 0x037C52, 0x03BC3C,
             0x03FC22, 0x04397E]
REGIONS = (
    [("boot/vectors.asm", 0x000000, 0x000212)]
    + [(f"boot/code_{a:06X}.asm", a, b) for a, b in zip(BOOT_CUTS, BOOT_CUTS[1:], strict=False)]
    + [("programs.asm", 0x012F06, 0x020000), ("game/vectors.asm", 0x020000, 0x020430)]
    + [(f"game/code_{a:06X}.asm", a, b) for a, b in zip(GAME_CUTS, GAME_CUTS[1:], strict=False)]
    + [
        ("game/island.asm", 0x04397E, 0x046AEE),
        ("data.asm", 0x046AEE, 0x060000),
        ("images.asm", 0x060000, 0x0BFE00),
        ("image_table.asm", 0x0BFE00, 0x0C0000),
    ]
)
CODE_FILES = [f for f, _, _ in REGIONS if f.startswith(("boot/", "game/"))]

# The six zero runs of wave 0 that are dcb.b source (94,883 bytes); since M5c the one at
# 020112-020418 is two statements (020400 is a base the code loads, dat_20400).
FILLS = [
    (0x012F06, 0x017000),
    (0x01EFD4, 0x020000),
    (0x020112, 0x020418),
    (0x05CF86, 0x060000),
    (0x0B10EB, 0x0BFE00),
    (0x0BFF18, 0x0C0000),
]
INCBIN = re.compile(r'^\s+incbin\s+"\.\./\.\./build/stunrun-68k\.bin",\$([0-9A-Fa-f]+),'
                    r"\$?([0-9A-Fa-f$\-]+)", re.M)

COPYRIGHT = b"Copyright 1989 ATARI GAMES\0\0"

ASSERT = re.compile(r"^\s+assert\s+\*=\$([0-9A-Fa-f]+)\s*,", re.M)
INCLUDE = re.compile(r'^\s+include\s+"([^"]+)"', re.M)
EQUATE = re.compile(r"^([A-Za-z_]\w*)\s+equ\s+\$([0-9A-Fa-f]+)\s*;\s*(.*)$", re.M)


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


needs_vasm = pytest.mark.skipif(vasm() is None, reason="vasm not available")


def assemble_68k(
    image: bytes, work: Path, tree: Path = TREE, expect_ok: bool = True,
    generated: dict[str, str] | None = None, palettes: Path = REPO / "data/palettes",
) -> tuple[bytes, str, subprocess.CompletedProcess[str]]:
    """The 68k tree assembled against `image` as build/stunrun-68k.bin (and the two programs cut
    out of it, as tools/extract-programs does), with `generated` written under build/ (path ->
    source, as a generator writes there): the output, the listing and vasm's result."""
    assert len(image) == IMAGE_SIZE
    shutil.copytree(tree, work / "asm/68k")
    build = work / "build"
    for sub in ("adsp", "gsp"):
        (build / sub).mkdir(parents=True)
    (build / "stunrun-68k.bin").write_bytes(image)
    (build / "adsp/program.bin").write_bytes(image[ADSP_START:GSP_START])
    (build / "gsp/program.bin").write_bytes(image[GSP_START:GSP_END])
    # pairs U-W come from data/gsp-images (docs/15), the palettes from data/palettes (docs/17)
    write_includes(build / "gsp-images", palettes=palettes)
    # the sound command equates (M5d, docs/17 section 3), from data/sound/commands.json
    write_equates(REPO / "data/sound/commands.json", build / "68k/sound_commands.asm")
    for path, text in (generated or {}).items():
        (build / path).parent.mkdir(parents=True, exist_ok=True)
        (build / path).write_text(text)
    out, lst = build / "68k.out", build / "68k.lst"
    tool = vasm()
    assert tool is not None
    r = subprocess.run(
        [tool, "-quiet", "-Fbin", "-no-opt", "-m68010", "-L", lst, "-o", out,
         "asm/68k/stunrun.asm"],
        cwd=work, capture_output=True, text=True, check=False,
    )
    if expect_ok:
        assert r.returncode == 0, r.stdout + r.stderr
    data = out.read_bytes() if r.returncode == 0 else b""
    text = lst.read_text(errors="replace") if r.returncode == 0 else ""
    return data, text, r


def blob_slices(listing: str) -> list[tuple[int, int, str]]:
    """(address, size, source) of every incbin statement of the listing."""
    lst = ls.parse(listing, ls.macro_names(TREE / "macros.asm"))
    ls.sizes(lst, IMAGE_SIZE)
    return [(s.address, s.size, s.text) for s in lst.statements if s.kind == "blob"]


_GSP_REGION: list[bytes] = []


def gsp_region() -> bytes:
    if not _GSP_REGION:
        import tempfile

        with tempfile.TemporaryDirectory() as tmp:
            _GSP_REGION.append(write_includes(Path(tmp)))
    return _GSP_REGION[0]


def test_regions_tile_the_image_in_address_order() -> None:
    main = (TREE / "stunrun.asm").read_text()
    includes = INCLUDE.findall(main)
    assert includes[:4] == ["hardware.asm", "ram.asm", "../../build/68k/sound_commands.asm",
                            "macros.asm"]
    assert includes[4:] == [f for f, _, _ in REGIONS]
    # no file under boot/ or game/ is left out (a stale boot/boot.asm or game/code.asm)
    assert sorted(
        str(p.relative_to(TREE)) for d in ("boot", "game") for p in (TREE / d).rglob("*.asm")
    ) == sorted(CODE_FILES)
    assert ASSERT.findall(main) == ["0C0000"]
    for (name, start, end), nxt in zip(REGIONS, REGIONS[1:] + [("", IMAGE_SIZE, 0)], strict=True):
        assert end == nxt[1]
        guards = [int(a, 16) for a in ASSERT.findall((TREE / name).read_text())]
        assert guards[0] == start and guards[-1] == end, name
        assert guards == sorted(guards), name
    assert REGIONS[0][1] == 0
    # the pair boundary inside game/code_03FC22.asm: sub_3FEA6 runs across 040000 (docs/06 section 4.2)
    functions = REPO / "data/ida/stunrun-68k.functions.jsonl"
    crossing = [
        f["name"]
        for f in map(json.loads, functions.read_text().splitlines())
        if f["start_ea"] < 0x40000 < f["end_ea"]
    ]
    assert crossing == ["sub_3FEA6"]


def test_fills_are_the_documented_zero_runs() -> None:
    assert sum(end - start for start, end in FILLS) == 94_883
    for start, end in FILLS:
        file = next(name for name, a, b in REGIONS if a <= start < b)
        assert end <= next(b for name, a, b in REGIONS if name == file)


def test_hardware_equates_are_the_ida_io_names() -> None:
    """asm/68k/hardware.asm and ida/memory_map.py's IO_68K: one spelling, one address, and every
    equate cites its docs/01 row."""
    text = (TREE / "hardware.asm").read_text()
    equates = [(int(a, 16), name) for name, a, _ in EQUATE.findall(text)]
    assert equates == [(ea, name) for ea, name, _ in IO_68K]
    docs01 = (REPO / "docs/01-hardware.md").read_text()
    for name, address, comment in EQUATE.findall(text):
        rows = re.findall(r"docs/01 rows? ([0-9A-F]{6})-([0-9A-F]{6})", comment)
        assert rows, f"{name}: no docs/01 row cited"
        start, end = rows[0]
        assert int(start, 16) == int(address, 16), name
        assert f"| {start}-{end} |" in docs01, f"{name}: docs/01 has no row {start}-{end}"
    # every equate line is one of those (no stray definitions)
    assert len(re.findall(r"\bequ\b", text)) == len(IO_68K)


def snapshot_functions() -> list[dict]:
    path = REPO / "data/ida/stunrun-68k.functions.jsonl"
    return [json.loads(line) for line in path.read_text().splitlines()]


def functions_starting(start: int, end: int) -> int:
    return sum(1 for f in snapshot_functions() if start <= f["start_ea"] < end)


# A name the region headers or docs/06 section 4 give with its address: `name 012345`,
# `name (012345` in asm/68k; `` `name` 0x012345 `` in docs/06's partition tables.
ASM_NAME_AT = re.compile(r"\b([A-Za-z]\w*_\w+) \(?([0-9A-F]{6})\b")
DOC_NAME_AT = re.compile(r"`([A-Za-z]\w*_\w+)` 0x([0-9A-F]{6})\b")
ASM_FUNCTION_COUNT = re.compile(r"([0-9A-F]{6})-([0-9A-F]{6}): (\d+) IDA functions")
DOC_FUNCTION_COUNT = re.compile(
    r"^\| 0x([0-9A-F]{6}) \| 0x([0-9A-F]{6}) \|.*?; (\d+) functions;", re.M
)
DOC_PAIR_COUNTS = re.compile(r"(\d+) functions in pair S and (\d+) in pair T")


def test_region_headers_and_docs06_follow_the_snapshot() -> None:
    """Every name the region files' headers or docs/06 sections 4.1-4.2 give with an address is the
    committed snapshot's name there (a user name or a function's), and every function count
    they give is the snapshot's: a rename or a new function in IDA (M4e named 043718
    `audio_test` and added five boot functions) fails until the prose follows."""
    snapshot = json.loads((REPO / "data/ida/stunrun-68k.json").read_text())
    where = {n["name"]: int(n["ea"], 16) for n in snapshot["names"]}
    for f in snapshot_functions():
        where.setdefault(f["name"], f["start_ea"])
    docs06 = (REPO / "docs/06-code-map.md").read_text()
    # the partition tables, 4.1 and 4.2 (elsewhere `name` 0x... is an instruction inside it)
    section4 = "\n".join(
        line
        for line in docs06[docs06.index("\n### 4.1") : docs06.index("\n### 4.3")].splitlines()
        if line.startswith("| 0x")
    )
    texts = {
        str(path.relative_to(REPO)): "\n".join(
            line for line in path.read_text().splitlines() if line.startswith(";")
        )
        for path in sorted(TREE.rglob("*.asm"))
        if path.name != "hardware.asm"
    }
    cited = [(f, n, int(a, 16)) for f, t in texts.items() for n, a in ASM_NAME_AT.findall(t)]
    cited += [("docs/06", n, int(a, 16)) for n, a in DOC_NAME_AT.findall(section4)]
    assert len(cited) > 10
    wrong = [
        f"{file}: {name} {ea:06X}, snapshot "
        + (f"{where[name]:06X}" if name in where else "has no such name")
        for file, name, ea in cited
        if where.get(name) != ea
    ]
    assert wrong == []
    counts = [(f, *m) for f, t in texts.items() for m in ASM_FUNCTION_COUNT.findall(t)]
    counts += [("docs/06", *m) for m in DOC_FUNCTION_COUNT.findall(section4)]
    assert len(counts) >= 2
    for file, start, end, n in counts:
        assert functions_starting(int(start, 16), int(end, 16)) == int(n), (file, start, end)
    pairs = DOC_PAIR_COUNTS.findall(section4)
    assert pairs == [
        (str(functions_starting(0x20000, 0x40000)), str(functions_starting(0x40000, 0x60000)))
    ]


WORDS = {"seven": 7, "eight": 8, "nine": 9, "ten": 10}


def test_image_table_sites_are_docs06s() -> None:
    """image_table.asm's header names two of the instructions that index the image table and
    counts the others; docs/06's 0x0BFE00 row lists them all. With build/stunrun-68k.bin (`make`)
    the instructions are every `lea $bfe00.l,An` and `addi.l #$bfe00,Dn` of the image."""
    header = (TREE / "image_table.asm").read_text()
    m = re.search(
        r"lea \$bfe00 at ([0-9A-F]{6}) and addi\.l #\$bfe00 at ([0-9A-F]{6}) and "
        r"(\w+) more\n; places",
        header,
    )
    assert m is not None
    row = next(
        line
        for line in (REPO / "docs/06-code-map.md").read_text().splitlines()
        if line.startswith("| 0x0BFE00 |")
    )
    listed = row[row.index("indexed from its base") : row.index("; entry 1 read")]
    sites = [int(a, 16) for a in re.findall(r"0x([0-9A-F]{6})", listed)]
    assert sites[:2] == [int(m[1], 16), int(m[2], 16)]
    assert len(sites) == 2 + WORDS[m[3]]
    image_path = REPO / "build/stunrun-68k.bin"
    if not image_path.exists():
        pytest.skip("build/stunrun-68k.bin absent (make)")
    image = image_path.read_bytes()
    found = []
    for at in range(2, 0x60000, 2):
        if struct.unpack_from(">I", image, at)[0] != 0x000BFE00:
            continue
        op = struct.unpack_from(">H", image, at - 2)[0]
        # lea (abs).l,An: 0100 nnn1 1111 1001; addi.l #imm,Dn: 0000 0110 1000 0nnn
        if op & 0xF1FF == 0x41F9 or op & 0xFFF8 == 0x0680:
            found.append(at - 2)
    assert found == sites


def test_ram_equates() -> None:
    """asm/68k/ram.asm (decision C9): one shared file of 24-bit equates, none in the ROM or in
    hardware.asm, each defined once, every one used by the source."""
    text = (TREE / "ram.asm").read_text()
    equates = re.findall(r"^([A-Za-z_]\w*)\s+equ\s+\$([0-9A-F]{6})$", text, re.M)
    assert len(equates) == len(re.findall(r"\bequ\b", text)) > 500
    names = [n for n, _ in equates]
    assert len(set(names)) == len(names)
    hardware = {n for n, _, _ in IO_68K}
    source = "\n".join((TREE / f).read_text() for f in CODE_FILES)
    for name, value in equates:
        assert int(value, 16) >= IMAGE_SIZE and name not in hardware, name
        assert re.search(rf"(?<![\w.]){name}(?![\w])", source), f"{name} unused"
        neutral = re.fullmatch(r"(ram|io)_([0-9A-F]+)", name)
        assert neutral is None or int(neutral[2], 16) == int(value, 16), name


@needs_vasm
def test_tree_assembles_a_random_blob(tmp_path: Path) -> None:
    image = random.Random(68010).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp_path)
    assert len(out) == IMAGE_SIZE
    # every slice of build/stunrun-68k.bin takes the blob's bytes at its own address, and every
    # incbin of the sources is one of the listing's slices
    slices = blob_slices(listing)
    assert len(slices) > 900
    for a, size, text in slices:
        m = re.search(r'stunrun-68k\.bin",\$([0-9A-Fa-f]+)', text)
        if m is None:
            assert a in (ADSP_START, GSP_START), f"{a:06X}: {text}"
            continue
        assert int(m[1], 16) == a, f"{a:06X}: {text}"
        assert out[a : a + size] == image[a : a + size], f"{a:06X}"
    starts = {a for a, _, _ in slices}
    for f, _, _ in REGIONS:
        for offset, _ in INCBIN.findall((TREE / f).read_text()):
            assert int(offset, 16) in starts, (f, offset)
    for start, end in FILLS:
        assert out[start:end] == bytes(end - start)
    # pairs U-W as data/gsp-images builds them (docs/15), whatever the blob
    assert out[REGION:REGION_END] == gsp_region()
    assert struct.unpack_from(">II", out, PROGRAM_TABLE) == (ADSP_START, GSP_START)
    assert out[0x017010 : 0x017010 + len(COPYRIGHT)] == COPYRIGHT
    symbols = vasm_symbols(listing)
    assert symbols["adsp_program_ptr"] == ("A", PROGRAM_TABLE)
    assert symbols["gsp_program_ptr"] == ("A", PROGRAM_TABLE + 4)
    assert symbols["adsp_program"] == ("A", ADSP_START)
    assert symbols["gsp_program"] == ("A", GSP_START)
    assert symbols["copyright_text"] == ("A", 0x017010)


@needs_vasm
def test_palettes_come_from_data_palettes(tmp_path: Path) -> None:
    """M5d (docs/17 section 2): the 32 palettes are bytes of the tree, from data/palettes alone,
    whatever the blob; a planted colour component changes exactly that byte of the image, at
    the palette's address plus three per colour."""
    from gspimages import read_palettes

    pals = read_palettes(REPO / "data/palettes")
    assert len(pals) == 32
    image = random.Random(5).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp_path / "a")
    symbols = vasm_symbols(listing)
    for name, p in pals.items():
        assert out[p.address : p.address + 3 * p.count] == p.bytes(), name
        assert symbols[f"pal_{name}"] == ("A", p.address), name
    planted = tmp_path / "palettes"
    shutil.copytree(REPO / "data/palettes", planted)
    raw = json.loads((planted / "title.json").read_text())
    raw["colors"][7][1] ^= 1
    (planted / "title.json").write_text(json.dumps(raw))
    out2, _, _ = assemble_68k(image, tmp_path / "b", palettes=planted)
    diff = [a for a in range(IMAGE_SIZE) if out[a] != out2[a]]
    assert diff == [pals["title"].address + 3 * 7 + 1]


@needs_vasm
def test_a_moved_region_fails_its_guard(tmp_path: Path) -> None:
    tree = tmp_path / "tree"
    shutil.copytree(TREE, tree)
    code = tree / "game/code_020430.asm"
    text = code.read_text()
    code.write_text(text.replace("sub_20430:\n", "sub_20430:\n\tdc.b\t0\n", 1))
    image = random.Random(1).randbytes(IMAGE_SIZE)
    _, _, r = assemble_68k(image, tmp_path / "work", tree, expect_ok=False)
    assert r.returncode != 0
    assert "game/code_020430.asm does not end at 024306" in r.stdout + r.stderr


def labels_tool() -> types.ModuleType:
    """tools/labels as a module (the script has no .py)."""
    import importlib.machinery
    import importlib.util

    loader = importlib.machinery.SourceFileLoader("labels_tool", str(TOOLS / "labels"))
    spec = importlib.util.spec_from_loader("labels_tool", loader)
    assert spec is not None
    labels = importlib.util.module_from_spec(spec)
    sys.modules["labels_tool"] = labels  # its dataclass looks its module up there
    loader.exec_module(labels)
    return labels


# A vasm -L listing (vasm 2.0f's form) of two org sections with a gap at 000002-000010.
GAP_LISTING = """Sections:
00: "org0001:0" (0-2)
01: "org0002:10" (10-12)


Source: "t.asm"
                            \t     1: \torg $0
                            \t     2: first:
00:00000000 0001            \t     3: \tdc.w 1
                            \t     4: \torg $10
                            \t     5: second:
01:00000010 0002            \t     6: \tdc.w 2


Symbols by name:
first                            A:00000000
second                           A:00000010

Symbols by value:
00000000 first
00000010 second
"""


def test_labels_without_a_statement() -> None:
    """A name whose address no statement of the listing holds fails `make labels`."""
    labels = labels_tool()
    report = labels.check(GAP_LISTING, [(0x000000, "first"), (0x000008, "gap"), (0xFF0000, "ram")])
    assert report.labelled == ["first at 000000"]
    assert report.in_blob == []
    assert report.outside == ["ram at FF0000"]
    assert report.failures == ["gap at 000008: no statement of the listing holds this address"]


@needs_vasm
def test_labels_on_the_tree(tmp_path: Path) -> None:
    """`make labels` on the committed tree assembled against a random blob: no failure, the
    program table's names are labels; a label taken out of source fails, and so does a snapshot
    name the tree has at another address while the snapshot's address is still in a blob."""
    labels = labels_tool()
    names = labels.snapshot_names(json.loads((REPO / "data/ida/stunrun-68k.json").read_text()))
    image = random.Random(2).randbytes(IMAGE_SIZE)
    _, listing, _ = assemble_68k(image, tmp_path / "a")
    report = labels.check(listing, names)
    assert report.failures == []
    for name, ea in (("adsp_program_ptr", 0x017000), ("copyright_text", 0x017010)):
        assert f"{name} at {ea:06X}" in report.labelled
    # since M5c every snapshot name in ROM is a label of the tree (docs/16)
    assert report.in_blob == [] and report.outside
    tree = tmp_path / "tree"
    shutil.copytree(TREE, tree)
    programs = tree / "programs.asm"
    programs.write_text(programs.read_text().replace("copyright_text:\n", "", 1))
    _, listing, _ = assemble_68k(image, tmp_path / "b", tree)
    report = labels.check(listing, names)
    assert report.failures == [
        "copyright_text at 017010: asm/68k/programs.asm has it as source (data) without the label"
    ]
    # vec_trapv (00001C in the snapshot) moved from boot/vectors.asm to 017010
    tree = tmp_path / "tree2"
    shutil.copytree(TREE, tree)
    vectors = tree / "boot/vectors.asm"
    assert vectors.read_text().count("vec_trapv:\n") == 1
    vectors.write_text(vectors.read_text().replace("vec_trapv:\n", "", 1))
    programs = tree / "programs.asm"
    text = programs.read_text()
    assert text.count("copyright_text:\n") == 1
    programs.write_text(text.replace("copyright_text:\n", "vec_trapv:\ncopyright_text:\n"))
    _, listing, _ = assemble_68k(image, tmp_path / "c", tree)
    report = labels.check(listing, names)
    assert report.failures == ["vec_trapv at 00001C: the tree has this label at 017010"]


# --- the checks on the tree's own listing (M5c, docs/16 section 4) ----------------------------


def tree_check(tmp: Path, tree: Path = TREE, seed: int = 16, shift: bool = True,
               runs: dict[str, set[int]] | None = None, patch: dict[int, bytes] | None = None,
               generated: dict[str, str] | None = None,
               explained: tr.Explained | None = None) -> tr.TreeReport:
    """tools/m68k check-tree's checks on `tree` assembled against a random blob (with `patch`
    written into it), the output and listing left in tmp/build/68k.out and 68k.lst."""
    blob = bytearray(random.Random(seed).randbytes(IMAGE_SIZE))
    for a, b in (patch or {}).items():
        blob[a : a + len(b)] = b
    image = bytes(blob)
    out, listing, _ = assemble_68k(image, tmp, tree, generated=generated)
    seeds, untaken = load_seeds(REPO / "data/68k/seeds.json")
    return tr.check(
        listing, out, cl.load(REPO / "data/68k/classification.json"),
        opd.load(REPO / "data/68k/operands.json"), ls.macro_names(tree / "macros.asm"), seeds,
        untaken, set(load_unreached(REPO / "data/68k/seeds.json")),
        tmp / "asm/68k" if shift else None, tmp / "build" if shift else None, runs,
        explained=explained,
    )


@needs_vasm
def test_tree_checks_pass(tmp_path: Path) -> None:
    """The committed tree: every instruction statement reached, no numeric ROM address, every dc
    statement of the code files and data.asm explained, the shift test exact; no reference into
    the image table as label + offset (M5d: each entry has its label, docs/17 section 3)."""
    rep = tree_check(tmp_path)
    assert rep.errors() == []
    assert rep.descent.reached > 44_000 and rep.descent.unreached == []
    assert rep.missing_code == [] and rep.extra_code == []
    assert rep.lint.undecided == [] and rep.lint.allowed == 337
    assert rep.shift is not None and rep.shift.changed == rep.shift.expected > 4000
    assert rep.foreign == []


def test_docs16_label_counts_are_the_trees() -> None:
    """docs/16 section 2's label and local counts are the committed tree's (they had stayed
    the first generation's after the review fixes changed the labels)."""
    label = re.compile(r"^[.A-Za-z_][A-Za-z0-9_]*:", re.M)
    local = re.compile(r"^\.[A-Za-z0-9_]*:", re.M)

    def count(files: list[str]) -> tuple[int, int]:
        texts = [(TREE / f).read_text() for f in files]
        return sum(len(label.findall(t)) for t in texts), sum(len(local.findall(t)) for t in texts)

    boot = count([f for f in CODE_FILES if f.startswith("boot/code_")])
    game = count([f for f in CODE_FILES if f.startswith("game/code_") or f == "game/island.asm"])
    vec = count(["boot/vectors.asm", "game/vectors.asm"])
    doc = " ".join((REPO / "docs/16-68k-code.md").read_text().split())
    assert f"({boot[0]:,} labels, {boot[1]:,} locals)" in doc, boot
    assert f"the island ({game[0]:,} labels, {game[1]:,} locals)" in doc, game
    total = boot[0] + game[0] + vec[0], boot[1] + game[1] + vec[1]
    assert f"{total[0]:,} labels, {total[1]:,} locals in all" in doc, total

COUNT_WORDS = {"two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8,
               "nine": 9, "ten": 10, "eleven": 11, "twelve": 12}


@needs_vasm
def test_pointer_variable_reasons_cite_every_store(tmp_path: Path) -> None:
    """A reviewed operand decision that calls a RAM long a pointer variable from its stores
    ("stores into FFxxxx, a pointer variable: ...") cites every instruction of the tree that
    stores into it (but the decided ones of the same variable, and up to the "and N more" it
    counts): FF9558's
    reasons had left out 0270B0, 027268 and 0273DA."""
    _, text, _ = assemble_68k(bytes(IMAGE_SIZE), tmp_path)
    lst = ls.parse(text, ls.macro_names(TREE / "macros.asm"))
    data = json.loads((REPO / "data/68k/operands.json").read_text())
    checked = 0
    for op in data["operands"]:
        m = re.match(r"stores into (FF[0-9A-F]{4}), a pointer variable: ", op.get("reason", ""))
        if not m:
            continue
        dest = re.compile(rf",\s*(?:ram_{m[1]}|\${m[1]}(?:\.l)?)\s*$", re.I)
        stores = {s.address for s in lst.statements
                  if s.kind == "instr" and s.text.split()[0].lower().startswith(("move", "clr"))
                  and dest.search(s.text)}
        cited = {int(x, 16) for x in re.findall(r"\b0[0-9A-F]{5}\b", op["reason"])}
        more = sum(COUNT_WORDS[w] for w in re.findall(r"and (\w+) more store", op["reason"]))
        decided = {int(o["at"], 16) for o in data["operands"]
                   if o.get("reason", "").startswith(f"stores into {m[1]},")}
        missing = stores - cited - decided
        assert len(missing) <= more, (op["at"], sorted(f"{x:06X}" for x in missing))
        checked += 1
    assert checked >= 3

def planted(tmp: Path, file: str, old: str, new: str, *more: tuple[str, str, str]) -> Path:
    """A copy of the tree with `old` replaced by `new` in `file` (and each further
    (file, old, new) applied the same way)."""
    tree = tmp / "tree"
    shutil.copytree(TREE, tree)
    for f, o, n in ((file, old, new), *more):
        path = tree / f
        text = path.read_text()
        assert text.count(o) >= 1, (f, o)
        path.write_text(text.replace(o, n, 1))
    return tree


def slice_of(file: str, kind: str, align: int = 2) -> tuple[str, int, int]:
    """The first incbin line of `file` over one range of the classification's `kind` of at
    least four bytes, its address and length multiples of `align`: (the line, its address,
    its length)."""
    c = cl.load(REPO / "data/68k/classification.json")
    spans = {s.start: s for s in c.spans}
    for m in re.finditer(r'^\tincbin\t"\.\./\.\./build/stunrun-68k\.bin",\$([0-9A-F]+),\$([0-9A-F]+)$',
                         (TREE / file).read_text(), re.M):
        a, n = int(m[1], 16), int(m[2], 16)
        s = spans.get(a)
        if s is not None and s.kind == kind and s.end == a + n and n >= 4 and a % 2 == 0 \
                and n % align == 0:
            return m[0], a, n
    raise AssertionError(f"no {kind} slice in {file}")


@needs_vasm
def test_tree_checks_fail(tmp_path: Path) -> None:
    """Each check fails on the fault it exists for (issue #33): an instruction nothing reaches,
    a ROM address written as a number, a dc.b wall in place of an incbin slice, a label pinned
    by an equ; the image is the same bytes in the first three."""
    file = "boot/code_000212.asm"
    line, a, n = slice_of(file, "unknown")
    # unreached: the unknown slice written as nops
    rep = tree_check(tmp_path / "a", planted(tmp_path / "a", file, line, "\tnop\n" * (n // 2)),
                     shift=False)
    assert rep.descent.unreached[: n // 2] == list(range(a, a + n, 2)), rep.descent.unreached
    # a dc.b wall: the same slice as bytes
    wall = "\tdc.b\t" + ",".join(["$00"] * n) + "\n"
    rep = tree_check(tmp_path / "b", planted(tmp_path / "b", file, line, wall), shift=False)
    assert [e.split(":")[0] for e in rep.raw] == [f"{a:06X}"], rep.raw
    # a ROM address left numeric: the first jsr to a routine of the file written as a number
    m = re.search(r"^\tjsr\t(sub_([0-9A-F]+))$", (TREE / file).read_text(), re.M)
    assert m is not None
    tree = planted(tmp_path / "c", file, m[0], f"\tjsr\t${m[2]}")
    rep = tree_check(tmp_path / "c", tree)
    assert any(f"jsr\t${m[2]}: the absolute operand" in e for e in rep.lint.errors), rep.lint
    # a label pinned by an equ: the shift test sees it
    m = re.search(r"^(sub_([0-9A-F]+)):$", (TREE / file).read_text(), re.M)
    assert m is not None
    tree = planted(tmp_path / "d", file, m[0] + "\n", f"{m[1]}_\n")
    ram = tree / "ram.asm"
    ram.write_text(ram.read_text() + f"{m[1]}\tequ\t${m[2]}\n")
    rep = tree_check(tmp_path / "d", tree)
    assert rep.shift is not None and rep.shift.errors, rep.shift
    # an image table entry read as the table plus an offset (decision C10's form, refused
    # since M5d gave every entry its label)
    tree = planted(tmp_path / "e", "game/code_024306.asm", "\tmove.l\tgsp_image_entry_25,-(sp)",
                   "\tmove.l\ttbl_BFE00+$64,-(sp)")
    rep = tree_check(tmp_path / "e", tree, shift=False)
    assert len(rep.foreign) == 1 and "tbl_BFE00+$64" in rep.foreign[0], rep.foreign
    assert any("as label+offset (write the entry's label" in e for e in rep.errors())
    # the same through the new labels: an entry label plus an offset (entry 25 as entry 24 + 4),
    # an image label plus an offset, an offset before the label (review of #38: the lint had
    # seen only tbl_BFE00+ and dat_60000+)
    tree = planted(tmp_path / "f", "game/code_028194.asm", "\tmove.l\tgsp_image_entry_25,-(sp)",
                   "\tmove.l\tgsp_image_entry_24+4,-(sp)",
                   ("game/code_024306.asm", "\tmove.l\tgsp_image_entry_25,-(sp)",
                    "\tmove.l\t4+gsp_image_entry_24,-(sp)"))
    rep = tree_check(tmp_path / "f", tree, shift=False)
    assert sorted(x.split(": ", 1)[1] for x in rep.foreign) == [
        "move.l\t4+gsp_image_entry_24,-(sp)", "move.l\tgsp_image_entry_24+4,-(sp)"], rep.foreign
    lst = ls.Listing()
    lst.symbols.update({"gsp_image_03": 0x061000, "sub_20430": 0x020430})
    lst.statements = [ls.Stmt(0x020000, "instr", "lea\t(gsp_image_03-$10,pc),a0"),
                      ls.Stmt(0x020004, "instr", "lea\t(sub_20430+$10,pc),a0"),
                      ls.Stmt(0x020008, "data", "dc.w\tgsp_image_03-sub_20430")]
    assert tr.foreign_refs(lst) == ["020000: lea\t(gsp_image_03-$10,pc),a0"]


@needs_vasm
def test_constant_written_as_a_label_fails(tmp_path: Path) -> None:
    """A long immediate data/68k/operands.json decides is a constant, written as a ROM label of
    the same value (the image unchanged): the address lint refuses it, whatever the shift test
    says (the label moves with the pad, so the statement changes as expected). A listed constant
    (R6 at 020CB4, `addi.l #$100,d0`) and a reviewed one (the countdown at 02FC76)."""
    tree = planted(tmp_path, "game/code_020430.asm", "\taddi.l\t#$100,d0\n",
                   "\taddi.l\t#dat_100,d0\n",
                   ("game/code_02C0D2.asm", "\tmove.l\t#$80000,d5\n",
                    "\tmove.l\t#dat_60000+$20000,d5\n"))
    rep = tree_check(tmp_path, tree, shift=False)
    bad = [e for e in rep.lint.errors if "is a constant (data/68k/operands.json) written as a "
           "ROM label" in e]
    assert len(bad) == 2 and len(rep.lint.errors) == 2, rep.lint.errors
    assert any("#dat_100,d0" in e for e in bad) and any(e.startswith("02FC76:") for e in bad), bad
    assert any(e.startswith("020CB4:") for e in bad), bad


@needs_vasm
def test_shift_test_pads_generated_includes(tmp_path: Path) -> None:
    """A source file the tree includes from build/ (a generator's output, as the GSP images'
    build/gsp-images/*.asm of issue #34) keeps its asserts in the build but loses them in the
    padded copy, like the tree's own files, and its `$X-*` fill keeps its length: the shift
    test passes."""
    tree = planted(tmp_path, "game/vectors.asm", "dat_20400:\n\tdcb.b\t24,0",
                   'dat_20400:\n\tinclude\t"../../build/gen/zeros.asm"')
    gen = '\tassert\t*=$020400,"build/gen/zeros.asm misplaced"\n\tdcb.b\t$020418-*,0\n'
    rep = tree_check(tmp_path, tree, generated={"gen/zeros.asm": gen})
    assert rep.shift is not None and rep.shift.errors == [], rep.shift
    assert rep.shift.changed == rep.shift.expected > 4000


@needs_vasm
def test_raw_data_check_fails(tmp_path: Path) -> None:
    """The raw-data check (decision C3) refuses every dc/dcb statement of a code file that is not
    one of the generator's explained kinds: a dc.l wall in a data range, numeric dc.b in a text
    range, a dcb.b fill of a byte other than zero, a switch entry that is not a difference, and
    a string that starts with a record field (a count, an item byte) or ends with one (the
    next screen record's first header byte); and, in any file, a string that starts in the
    command word of an audio_test_list record (made-up characters, the low byte of the word
    at 05C703 written as the first)."""
    file = "boot/code_000212.asm"
    line, a, n = slice_of(file, "data", align=4)
    text = "GAME DIFFICULTY"
    tree = planted(
        tmp_path, file, line, "\tdc.l\t" + ",".join(["$0"] * (n // 4)) + "\n",
        ("game/code_020430.asm", f"\tdc.b\t'{text}',0\n",
         "\tdc.b\t" + ",".join(f"${ord(ch):02X}" for ch in text) + ",0\n"),
        (file, "\tdcb.b\t40,0\n", "\tdcb.b\t40,$FF\n"),
        ("game/code_02C0D2.asm", "\tdc.w\t.l2C4A8-.l2C48C\n", "\tdc.w\t$1C\n"),
        # a record field written back into its string (the same number of bytes): a count as
        # the first character (37 = '%', the characters after it), an item byte
        ("boot/code_0065E0.asm", "\tdc.b\t'ERROR*80**P1BAD**6502*PROGRAM*PROM*BAD'\n",
         "\tdc.b\t'%RROR*80**P1BAD**6502*PROGRAM*PROM*BAD'\n"),
        ("game/code_020430.asm", "\tdc.b\t'CONTINUE ADVANCES TO NEXT LEVEL',0\n",
         "\tdc.b\t'vONTINUE ADVANCES TO NEXT LEVEL',0\n"),
        # the next record's first header byte (column 20h at 007A7F) written back as the
        # string's last character
        ("boot/code_0065E0.asm", "\tdc.b\t'INC*PM*DATA*0-7'\ndat_7A7F:\n"
         "\tincbin\t\"../../build/stunrun-68k.bin\",$7A7F,$4\n",
         "\tdc.b\t'INC*PM*DATA*0-7 '\ndat_7A80:\n"
         "\tincbin\t\"../../build/stunrun-68k.bin\",$7A80,$3\n"),
        # (since M5d the list is source: the record at 05C702 rewritten, same length)
        ("data.asm", "\tdc.w\tsnd_boostc\n\tdc.b\t'BOOSTC',0\n\tdcb.b\t13,0\n",
         "\tdc.b\t0\n\tdc.b\t'XMADEUP',0\n\tdcb.b\t13,0\n"),
        # a command word written as a ROM label of the same value (vec_reset_pc, 000004 =
        # snd_ytst): the bytes are equal, the statement names no sound-command equate (review
        # of #38)
        ("data.asm", "\tdc.w\tsnd_ytst\n", "\tdc.w\tvec_reset_pc\n"),
    )
    # the blob is random: the header bytes the check reads are written into it, made up but
    # for the counts, which are the strings' lengths (15 before the 16 characters, 18 for
    # CONTROL*LEFT/RIGHT, a non-printable byte after it)
    patch = {0x7A6F: bytes([15]), 0x7A80: bytes([0x01, 0x01, 18]), 0x7A95: b"\x01"}
    rep = tree_check(tmp_path, tree, shift=False, patch=patch)
    # the rewritten record also breaks its format (a dc.b 0 where its command word was, so the
    # record has no dc.w at 05C702): two more errors
    assert len(rep.raw) == 11, rep.raw
    assert any(e.startswith("05C702: dc.b\t0:") and "audio_test_list record" in e
               for e in rep.raw), rep.raw
    assert any("dc.w\tvec_reset_pc:" in e and "sound-command equate" in e
               for e in rep.raw), rep.raw
    assert any(e.startswith("05C702:") and "not 22 bytes" in e for e in rep.raw), rep.raw
    assert any(e.startswith("05C703: dc.b") and "record at 05C702" in e
               and "audio_test_list" in e for e in rep.raw), rep.raw
    assert any("'INC*PM*DATA*0-7 '" in e and "next record's 4-byte header" in e
               for e in rep.raw), rep.raw
    assert any("'%RROR" in e and "count of the 37 after it" in e for e in rep.raw), rep.raw
    assert any("'vONTINUE" in e and "item byte" in e for e in rep.raw), rep.raw
    assert rep.raw[0].startswith(f"{a:06X}: dc.l") and "in a data range" in rep.raw[0], rep.raw
    assert any("$47,$41,$4D,$45" in e and "in a text range" in e for e in rep.raw), rep.raw
    assert any("dcb.b" in e and "$FF" in e for e in rep.raw), rep.raw
    assert any("dc.w" in e and "$1C" in e and "in a switch range" in e for e in rep.raw), rep.raw


@needs_vasm
def test_code_turned_blob_fails(tmp_path: Path, capsys: pytest.CaptureFixture[str],
                                monkeypatch: pytest.MonkeyPatch) -> None:
    """A routine's instruction written back as an incbin slice of the same bytes: the classified
    instruction start without a statement fails check-tree (exit 1), and so does an executed PC
    there, through tr.check's runs and through tools/m68k pccov --listing."""
    from m68k import __main__ as cli

    file = "boot/code_000212.asm"
    m = re.search(r"^sub_([0-9A-F]+):\n(\tmoveq\t#-\$1,d5)\n", (TREE / file).read_text(), re.M)
    assert m is not None
    x = int(m[1], 16)
    tree = planted(tmp_path, file, m[0],
                   f'sub_{m[1]}:\n\tincbin\t"../../build/stunrun-68k.bin",${x:06X},$2\n')
    # the blob carries the instruction's own encoding (moveq #-1,d5), so the image is unchanged
    rep = tree_check(tmp_path, tree, shift=False, runs={"t": {x, 0x000216}},
                     patch={x: bytes([0x7A, 0xFF])})
    assert rep.missing_code == [x] and rep.extra_code == [], (rep.missing_code, rep.extra_code)
    assert rep.pccov == {"t": [x]}
    assert any(e.startswith(f"{x:06X}: a classified instruction start") for e in rep.errors())
    build = tmp_path / "build"
    cls = str(REPO / "data/68k/classification.json")
    monkeypatch.setattr("sys.argv", [
        "tools/m68k", "check-tree", "--listing", str(build / "68k.lst"), "--binary",
        str(build / "68k.out"), "--no-shift", "--classification", cls])
    assert cli.main() == 1
    assert "1 classified instruction starts without a statement" in capsys.readouterr().out
    run = tmp_path / "pccov-t.txt"
    run.write_text(f"# run 1\n{x:06X}\n000216\n")
    monkeypatch.setattr("sys.argv", [
        "tools/m68k", "pccov", "--image", str(build / "68k.out"), "--classification", cls,
        "--listing", str(build / "68k.lst"), "--summary", str(tmp_path / "s.json"), str(run)])
    assert cli.main() == 1
    out = capsys.readouterr().out
    assert "t: 2 distinct PCs, 0 not a classified instruction start" in out, out
    assert "t: 1 not an instruction statement" in out, out


@needs_vasm
def test_promoted_range_fails(tmp_path: Path) -> None:
    """Decision C8: an unknown range written as instructions fails even when a `dc.l` in
    data.asm names it and seeds the descent (the statements are reached): every instruction
    statement must be a classified instruction start."""
    file = "boot/code_000212.asm"
    line, a, n = slice_of(file, "unknown")
    long = re.search(r'^\tincbin\t"\.\./\.\./build/stunrun-68k\.bin",\$[0-9A-F]+,\$4$',
                     (TREE / "data.asm").read_text(), re.M)
    assert long is not None
    tree = planted(tmp_path, file, line, f"promoted_{a:X}:\n" + "\tnop\n" * (n // 2),
                   ("data.asm", long[0], f"\tdc.l\tpromoted_{a:X}"))
    rep = tree_check(tmp_path, tree, shift=False)
    nops = list(range(a, a + n, 2))
    assert not set(nops) & set(rep.descent.unreached), rep.descent.unreached
    assert rep.extra_code[: n // 2] == nops, rep.extra_code
    assert any(e.startswith(f"{a:06X}: an instruction statement that is no classified")
               for e in rep.errors())


def test_sound_equates_are_commands_json(tmp_path: Path) -> None:
    """M5d (docs/17 section 3): build/68k/sound_commands.asm holds one equate per command of
    data/sound/commands.json, its name and value, 00-6C; a doubled name is refused."""
    from m68k import sound

    out = tmp_path / "s.asm"
    assert write_equates(REPO / "data/sound/commands.json", out)
    assert not write_equates(REPO / "data/sound/commands.json", out)  # unchanged: not rewritten
    got = re.findall(r"^(\w+)\tequ\t\$([0-9A-F]{2})\t;", out.read_text(), re.M)
    data = json.loads((REPO / "data/sound/commands.json").read_text())["commands"]
    assert got == [(c["name"], c["value"]) for c in sorted(data, key=lambda c: c["value"])]
    assert [int(v, 16) for _, v in got] == list(range(0x6D))
    bad = json.loads((REPO / "data/sound/commands.json").read_text())
    bad["commands"][1]["name"] = bad["commands"][0]["name"]
    (tmp_path / "bad.json").write_text(json.dumps(bad))
    with pytest.raises(ValueError, match="occurs twice"):
        sound.commands(tmp_path / "bad.json")


@needs_vasm
def test_audio_test_list_is_source(tmp_path: Path) -> None:
    """M5d (docs/17 section 3): audio_test_list (05C63C) is 108 records of 22 bytes from source
    whatever the blob: each the command word of an equate whose audio-test name is the
    record's name, at the record commands.json gives (audio_test_entry), then FFFF."""
    image = random.Random(9).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp_path)
    data = json.loads((REPO / "data/sound/commands.json").read_text())["commands"]
    by_value = {int(c["value"], 16): c for c in data}
    base = vasm_symbols(listing)["audio_test_list"][1]
    assert base == 0x05C63C
    seen = []
    for k in range(108):
        rec = out[base + 22 * k : base + 22 * k + 22]
        value = int.from_bytes(rec[:2], "big")
        name = rec[2 : rec.index(0, 2)].decode()
        assert not any(rec[3 + len(name) :]), k
        c = by_value[value]
        assert c["audio_test"] == name and int(c["audio_test_entry"], 16) == base + 22 * k
        seen.append(value)
    assert out[base + 22 * 108 : base + 22 * 108 + 2] == b"\xff\xff"
    assert sorted(seen) == [v for v in range(0x6D) if v != 3]


@needs_vasm
def test_data_asm_raw_data_check_fails(tmp_path: Path) -> None:
    """M5d (docs/17): the raw-data check covers data.asm. A dc.b wall in place of a data slice
    fails at its address; so do a record field of 048180 written as dc.l (only +4-+40 are
    pointers), a long of a proven pointer table written as a count, a number of 400h or more
    in 047F50, and a table of data/68k/tables.json left an incbin slice."""
    wall = "\tdc.b\t" + ",".join(["$00"] * 0x1E) + "\n"
    tree = planted(
        tmp_path, "data.asm", '\tincbin\t"../../build/stunrun-68k.bin",$04A88C,$1E\n', wall,
        ("data.asm", '\tincbin\t"../../build/stunrun-68k.bin",$0481A8,$4\n', "\tdc.l\t0\n"),
        ("data.asm", "\tdc.l\tstr_4A998\n", "\tdc.l\t$12\n"),
        ("data.asm", "dat_47F58:\n\tdc.l\t$F0\n", "dat_47F58:\n\tdc.l\t$400\n"),
        ("data.asm", "dat_4E3B4:\n", "dat_4E3B4:\n\tincbin\t\"../../build/stunrun-68k.bin\","
         "$04E3B4,$24\n\tifne 0\n"),
        ("data.asm", "dat_4E3D8:\n", "\tendif\ndat_4E3D8:\n"),
    )
    rep = tree_check(tmp_path, tree, shift=False)
    assert any(e.startswith("04A88C: dc.b\t$00,") and "in a data range" in e
               for e in rep.raw), rep.raw
    assert any(e.startswith("0481A8: dc.l\t0:") and "+4-+28" in e for e in rep.raw), rep.raw
    assert any(e.startswith("04A954: dc.l\t$12:") and "labels or 0 only" in e
               for e in rep.raw), rep.raw
    assert any(e.startswith("047F58: dc.l\t$400:") and "below 400h" in e for e in rep.raw), rep.raw
    assert any(e.startswith("04E3B4: table dat_4E3B4") and "9 longs missing" in e
               for e in rep.raw), rep.raw
    assert len(rep.raw) == 5, rep.raw
    # three numbers outside any palette: the dc.b r,g,b allowance holds only inside a palette
    # of data/palettes (review of #38: no plant had three operands)
    tree = planted(tmp_path / "p", "data.asm",
                   '\tincbin\t"../../build/stunrun-68k.bin",$04A88C,$1E\n',
                   '\tdc.b\t$01,$02,$03\n\tincbin\t"../../build/stunrun-68k.bin",$04A88F,$1B\n')
    rep = tree_check(tmp_path / "p", tree, shift=False)
    assert [e.split(":")[0] for e in rep.raw] == ["04A88C"], rep.raw
    # constants written as symbols of the same value, so the bytes and the shift test do not
    # see them (review of #38): an equate (snd_stop, 0) as a pointer, a ROM label of value 0
    # (vec_reset_sp, 000000) as the null of 047F50, a ROM label below 400h (vec_reserved_60,
    # 0000F0) as one of its counts
    tree = planted(tmp_path / "s", "data.asm", "dat_4C712:\n\tdc.l\t0\n",
                   "dat_4C712:\n\tdc.l\tsnd_stop\n",
                   ("data.asm", "dat_47F50:\n\tdc.l\t0\n", "dat_47F50:\n\tdc.l\tvec_reset_sp\n"),
                   ("data.asm", "dat_47F58:\n\tdc.l\t$F0\n",
                    "dat_47F58:\n\tdc.l\tvec_reserved_60\n"))
    rep = tree_check(tmp_path / "s", tree, shift=True)
    assert len(rep.raw) == 3 and rep.errors() == rep.raw, rep.errors()
    assert rep.raw[0].startswith("047F50: dc.l\tvec_reset_sp:") and "value 0" in rep.raw[0], rep.raw
    assert rep.raw[1].startswith("047F58: dc.l\tvec_reserved_60:") and "below 400h" in rep.raw[1], \
        rep.raw
    assert rep.raw[2].startswith("04C712: dc.l\tsnd_stop:") and "an equate" in rep.raw[2], rep.raw
    # a registry label the listing does not define at the table's start (review of #38)
    ex = tr.load_explained()
    ex.tables = [dataclasses.replace(t, label="dat_nonexistent") if t.start == 0x047406
                 else dataclasses.replace(t, label="dat_47406") if t.start == 0x048068 else t
                 for t in ex.tables]
    rep = tree_check(tmp_path / "q", shift=False, explained=ex)
    assert sorted(rep.raw) == [
        "047406: table dat_nonexistent (data/68k/tables.json): the listing defines no such label",
        "048068: table dat_47406 (data/68k/tables.json): the listing defines that label at "
        "047406, not at the table's start"], rep.raw


@needs_vasm
def test_moved_build(tmp_path: Path) -> None:
    """The moved-build experiment's tree (M5d, docs/17 section 5): with a pad of 4 before the
    game code, the boot program, the coprocessor programs, the game vectors' place and pairs
    U-W stay where they are, every label of 020430-05CF86 moves by 4, the fill at 05CF86 is 4
    shorter, and the game vector table names the moved handlers."""
    from m68k import moved

    image = random.Random(11).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp_path / "a")
    build = tmp_path / "a/build"
    mov = moved.build_moved(tmp_path / "a/asm/68k", build, tmp_path / "moved", 4)
    assert mov[:0x020000] == out[:0x020000]  # the boot program and the coprocessor programs
    assert mov[0x060000:] == out[0x060000:]
    a = vasm_symbols(listing)
    b = vasm_symbols((tmp_path / "moved/stunrun-68k.lst").read_text(errors="replace"))
    for name in ("sub_20430", "audio_test", "audio_test_list", "pal_title", "dat_47406"):
        assert b[name][1] == a[name][1] + 4, name
    for name in ("copyright_text", "gsp_image_entry_25", "game_entries"):
        assert b[name][1] == a[name][1], name
    vec = struct.unpack_from(">I", mov, 0x020000 + 4 * 3)[0]  # game_vec_address_error
    assert vec == b["h_address_error"][1] == a["h_address_error"][1] + 4
    with pytest.raises(ValueError, match="even"):
        moved.moved_tree(tmp_path / "a/asm/68k", build, tmp_path / "m2", 3)


def test_moved_candidates_skip_flagged_longs() -> None:
    """tools/m68k moved-candidates (moved.py `candidates`) on made-up longs: a long with bit 31
    set is the level lists' parameter long (sub_3186A 0318A2-0318C0, its high word an index
    into 04C712 in sub_30F9C 0311B8-0311D2), never a pointer candidate, even when its value
    without bit 31 lies in the data."""
    from m68k import moved

    base = 0x050000
    longs = [0x050100, 0x048000, 0x80050200, 0x050300, 0x021000, 0x046B00, 0x047000, 0x80000001,
             0x049000, 0x04A000, 0x04B000, 0x04C000]
    image = bytearray(IMAGE_SIZE)
    for k, v in enumerate(longs):
        struct.pack_into(">I", image, base + 4 * k, v)
    lst = ls.Listing(statements=[ls.Stmt(base, "blob", "incbin", 4 * len(longs))])
    # the flagged longs at +8 and +1C cut the runs: +0..+8 (2), +C..+1C (4), +20..+30 (4)
    assert moved.candidates(lst, bytes(image), 4) == [(base + 0x0C, base + 0x1C),
                                                      (base + 0x20, base + 0x30)]


def test_moved_compare(tmp_path: Path) -> None:
    """tools/m68k moved-compare on made-up movedcheck.lua logs: the first frame per stream
    whose count or hash differs, and the moved run's reset."""
    from m68k import moved

    def log(path: Path, rows: list[str], extra: str = "") -> Path:
        path.write_text("# frames 3\n# play 0\n" + "".join(r + "\n" for r in rows) + extra
                        + "# done\n")
        return path

    same = "gsp 2 0000000A adsp 0 811C9DC5 snd 1 0000000B"
    ref = log(tmp_path / "r.txt", [f"f 1 {same}", f"f 2 {same}", f"f 3 {same}"])
    mov = log(tmp_path / "m.txt", [f"f 1 {same}", "f 2 gsp 2 0000000C adsp 0 811C9DC5 snd 1 "
                                   "0000000B", "f 3 gsp 2 0000000A adsp 0 811C9DC5 snd 0 811C9DC5"],
              "# reset_at_frame 3\n")
    r, m = moved.load(ref), moved.load(mov)
    assert moved.compare(r, m) == {"gsp": 2, "adsp": None, "snd": 3}
    text = moved.summary("t", r, m)
    assert "moved reset at frame 3" in text and "adsp: equal in every frame" in text
    assert "gsp: first differs at frame 2 (writes, hash: reference 2 0000000A, moved 2 0000000C)" \
        in text


def test_tables_registry_refuses_unproven_tables(tmp_path: Path) -> None:
    """data/68k/tables.json (M5d, decision C18): every table has its reader; a table without
    one, of an unknown format, a records table without its stride, or a table overlapping
    another is refused."""
    raw = json.loads((REPO / "data/68k/tables.json").read_text())
    tables = tr.load_tables(REPO / "data/68k/tables.json")
    assert len(tables) == 14 and all(t.reader.strip() for t in tables)
    longs = sum((t.end - t.start) // 4 for t in tables if t.format in ("pointers",
                                                                       "pointer_or_count"))
    longs += sum((t.end - t.start) // t.stride * (t.pointers[1] - t.pointers[0]) // 4
                 for t in tables if t.format == "records")
    assert longs == 658
    by_start = {t["start"]: k for k, t in enumerate(raw["tables"])}
    for start, change in (("047406", {"reader": " "}), ("047406", {"format": "words"}),
                          ("048180", {"stride": 0}), ("047F50", {"start": "047470"})):
        bad = json.loads(json.dumps(raw))
        bad["tables"][by_start[start]].update(change)
        (tmp_path / "t.json").write_text(json.dumps(bad))
        with pytest.raises(ValueError):
            tr.load_tables(tmp_path / "t.json")
