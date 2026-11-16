"""The 68k tree's partition (docs/13-68k-source.md): region files, guards, fills, the program
table, the hardware equates and `make labels`, on random bytes, never ROM data.

The structural tests read asm/68k only; the assembled ones (vasm on PATH or in $VASM, as in CI)
assemble the committed tree against a random blob laid out like build/ (the image, the ADSP and
GSP programs cut out of it) and check what the tree itself contributes: zero fills, the program
table's pointers and text, and every other byte from the blob at its own address.
"""

from __future__ import annotations

import json
import os
import random
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

import pytest
from listings import vasm_symbols
from programs import ADSP_START, GSP_END, GSP_START, PROGRAM_TABLE

from ida.memory_map import IO_68K

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
TREE = REPO / "asm/68k"
IMAGE_SIZE = 0xC0000

# The partition (docs/13 section 2, docs/06 section 4): file, start, end.
REGIONS = [
    ("boot/vectors.asm", 0x000000, 0x000212),
    ("boot/boot.asm", 0x000212, 0x012F06),
    ("programs.asm", 0x012F06, 0x020000),
    ("game/vectors.asm", 0x020000, 0x020430),
    ("game/code.asm", 0x020430, 0x04397E),
    ("game/island.asm", 0x04397E, 0x046AEE),
    ("data.asm", 0x046AEE, 0x060000),
    ("images.asm", 0x060000, 0x0BFE00),
    ("image_table.asm", 0x0BFE00, 0x0C0000),
]

# The six zero runs that are dcb.b source (94,883 bytes).
FILLS = [
    (0x012F06, 0x017000),
    (0x01EFD4, 0x020000),
    (0x020112, 0x020418),
    (0x05CF86, 0x060000),
    (0x0B10EB, 0x0BFE00),
    (0x0BFF18, 0x0C0000),
]

COPYRIGHT = b"Copyright 1989 ATARI GAMES\0\0"

ASSERT = re.compile(r"^\s+assert\s+\*=\$([0-9A-Fa-f]+)\s*,", re.M)
INCLUDE = re.compile(r'^\s+include\s+"([^"]+)"', re.M)
EQUATE = re.compile(r"^([A-Za-z_]\w*)\s+equ\s+\$([0-9A-Fa-f]+)\s*;\s*(.*)$", re.M)


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


needs_vasm = pytest.mark.skipif(vasm() is None, reason="vasm not available")


def assemble_68k(
    image: bytes, work: Path, tree: Path = TREE, expect_ok: bool = True
) -> tuple[bytes, str, subprocess.CompletedProcess[str]]:
    """The 68k tree assembled against `image` as build/stunrun-68k.bin (and the two programs cut
    out of it, as tools/extract-programs does): the output, the listing and vasm's result."""
    assert len(image) == IMAGE_SIZE
    shutil.copytree(tree, work / "asm/68k")
    build = work / "build"
    for sub in ("adsp", "gsp"):
        (build / sub).mkdir(parents=True)
    (build / "stunrun-68k.bin").write_bytes(image)
    (build / "adsp/program.bin").write_bytes(image[ADSP_START:GSP_START])
    (build / "gsp/program.bin").write_bytes(image[GSP_START:GSP_END])
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


def expected_68k(image: bytes) -> bytes:
    """What the tree contributes over a blob: the fills zero, the table's pointers and text."""
    out = bytearray(image)
    for start, end in FILLS:
        out[start:end] = bytes(end - start)
    struct.pack_into(">II", out, PROGRAM_TABLE, ADSP_START, GSP_START)
    out[0x017010 : 0x017010 + len(COPYRIGHT)] = COPYRIGHT
    return bytes(out)


def test_regions_tile_the_image_in_address_order() -> None:
    main = (TREE / "stunrun.asm").read_text()
    includes = INCLUDE.findall(main)
    assert includes[0] == "hardware.asm"
    assert includes[1:] == [f for f, _, _ in REGIONS]
    assert ASSERT.findall(main) == ["0C0000"]
    for (name, start, end), nxt in zip(REGIONS, REGIONS[1:] + [("", IMAGE_SIZE, 0)], strict=True):
        assert end == nxt[1]
        guards = [int(a, 16) for a in ASSERT.findall((TREE / name).read_text())]
        assert guards[0] == start and guards[-1] == end, name
        assert guards == sorted(guards), name
    assert REGIONS[0][1] == 0
    # the pair boundary inside game/code.asm: sub_3FEA6 runs across 040000 (docs/06 section 4.2)
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


@needs_vasm
def test_tree_assembles_a_random_blob(tmp_path: Path) -> None:
    image = random.Random(68010).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp_path)
    assert out == expected_68k(image)
    symbols = vasm_symbols(listing)
    assert symbols["adsp_program_ptr"] == ("A", PROGRAM_TABLE)
    assert symbols["gsp_program_ptr"] == ("A", PROGRAM_TABLE + 4)
    assert symbols["adsp_program"] == ("A", ADSP_START)
    assert symbols["gsp_program"] == ("A", GSP_START)
    assert symbols["copyright_text"] == ("A", 0x017010)


@needs_vasm
def test_a_moved_region_fails_its_guard(tmp_path: Path) -> None:
    tree = tmp_path / "tree"
    shutil.copytree(TREE, tree)
    code = tree / "game/code.asm"
    text = code.read_text()
    code.write_text(text.replace("sub_20430:\n", "sub_20430:\n\tdc.b\t0\n", 1))
    image = random.Random(1).randbytes(IMAGE_SIZE)
    _, _, r = assemble_68k(image, tmp_path / "work", tree, expect_ok=False)
    assert r.returncode != 0
    assert "game/code.asm does not end at 04397E" in r.stdout + r.stderr


@needs_vasm
def test_labels_on_the_tree(tmp_path: Path) -> None:
    """`make labels` on the committed tree assembled against a random blob: no failure, the
    program table's names are labels; a label taken out of source fails."""
    import importlib.machinery
    import importlib.util

    loader = importlib.machinery.SourceFileLoader("labels_tool", str(TOOLS / "labels"))
    spec = importlib.util.spec_from_loader("labels_tool", loader)
    assert spec is not None
    labels = importlib.util.module_from_spec(spec)
    sys.modules["labels_tool"] = labels  # its dataclass looks its module up there
    loader.exec_module(labels)
    names = labels.snapshot_names(json.loads((REPO / "data/ida/stunrun-68k.json").read_text()))
    image = random.Random(2).randbytes(IMAGE_SIZE)
    _, listing, _ = assemble_68k(image, tmp_path / "a")
    report = labels.check(listing, names)
    assert report.failures == []
    for name, ea in (("adsp_program_ptr", 0x017000), ("copyright_text", 0x017010)):
        assert f"{name} at {ea:06X}" in report.labelled
    assert report.in_blob and report.outside
    tree = tmp_path / "tree"
    shutil.copytree(TREE, tree)
    programs = tree / "programs.asm"
    programs.write_text(programs.read_text().replace("gsp_program_ptr:\n", "", 1))
    _, listing, _ = assemble_68k(image, tmp_path / "b", tree)
    report = labels.check(listing, names)
    assert report.failures == [
        "gsp_program_ptr at 017004: asm/68k/programs.asm has it as source (data) without the label"
    ]
