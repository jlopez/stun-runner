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
    write_includes(build / "gsp-images")  # pairs U-W come from data/gsp-images (docs/15)
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
    """What the tree contributes over a blob: the fills zero, the table's pointers and text, and
    pairs U-W as data/gsp-images builds them (docs/15)."""
    out = bytearray(image)
    out[REGION:REGION_END] = gsp_region()
    for start, end in FILLS:
        out[start:end] = bytes(end - start)
    struct.pack_into(">II", out, PROGRAM_TABLE, ADSP_START, GSP_START)
    out[0x017010 : 0x017010 + len(COPYRIGHT)] = COPYRIGHT
    return bytes(out)
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
    assert includes[:3] == ["hardware.asm", "ram.asm", "macros.asm"]
    assert includes[3:] == [f for f, _, _ in REGIONS]
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
    assert struct.unpack_from(">II", out, PROGRAM_TABLE) == (ADSP_START, GSP_START)
    assert out[0x017010 : 0x017010 + len(COPYRIGHT)] == COPYRIGHT
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


def tree_check(tmp: Path, tree: Path = TREE, seed: int = 16, shift: bool = True
               ) -> tr.TreeReport:
    """tools/m68k check-tree's checks on `tree` assembled against a random blob."""
    image = random.Random(seed).randbytes(IMAGE_SIZE)
    out, listing, _ = assemble_68k(image, tmp, tree)
    seeds, untaken = load_seeds(REPO / "data/68k/seeds.json")
    return tr.check(
        listing, out, cl.load(REPO / "data/68k/classification.json"),
        opd.load(REPO / "data/68k/operands.json"), ls.macro_names(tree / "macros.asm"), seeds,
        untaken, set(load_unreached(REPO / "data/68k/seeds.json")),
        tmp / "asm/68k" if shift else None, tmp / "build" if shift else None,
    )


@needs_vasm
def test_tree_checks_pass(tmp_path: Path) -> None:
    """The committed tree: every instruction statement reached, no numeric ROM address, every dc
    statement of the code files explained, the shift test exact; the references into the image
    table are label + offset (decision C10)."""
    rep = tree_check(tmp_path)
    assert rep.errors() == []
    assert rep.descent.reached > 44_000 and rep.descent.unreached == []
    assert rep.lint.undecided == [] and rep.lint.allowed > 300
    assert rep.shift is not None and rep.shift.changed == rep.shift.expected > 4000
    assert rep.foreign and all("tbl_BFE00+$" in x for x in rep.foreign)


def planted(tmp: Path, file: str, old: str, new: str) -> Path:
    tree = tmp / "tree"
    shutil.copytree(TREE, tree)
    path = tree / file
    text = path.read_text()
    assert text.count(old) >= 1, (file, old)
    path.write_text(text.replace(old, new, 1))
    return tree


def slice_of(file: str, kind: str) -> tuple[str, int, int]:
    """The first incbin line of `file` over one range of the classification's `kind` of at
    least four even-aligned bytes: (the line, its address, its length)."""
    c = cl.load(REPO / "data/68k/classification.json")
    spans = {s.start: s for s in c.spans}
    for m in re.finditer(r'^\tincbin\t"\.\./\.\./build/stunrun-68k\.bin",\$([0-9A-F]+),\$([0-9A-F]+)$',
                         (TREE / file).read_text(), re.M):
        a, n = int(m[1], 16), int(m[2], 16)
        s = spans.get(a)
        if s is not None and s.kind == kind and s.end == a + n and n >= 4 and a % 2 == 0 \
                and n % 2 == 0:
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
