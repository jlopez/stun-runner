"""The object ROMs (tools/objects, docs/07-objects.md): decoder, encoder, generated assembly.

Synthetic tests run everywhere (CI): hand-made objects through encode and decode, planted
differences, malformed input. Because data/objects is committed, CI also encodes it and checks
the four chips of pages 1 and 2 against the CRC-32 and SHA-1 MAME lists (page 0 holds a residue
word only the ROM image supplies). With the reference set built (`make`), decode(image) must
reproduce data/objects exactly and encode(data/objects) the image; with the MAME traces
(`make objtrace`), every object-ROM read sequence the ADSP made must match the decoder.
"""

from __future__ import annotations

import json
import os
import random
import shutil
import subprocess
import sys
from collections.abc import Callable
from pathlib import Path
from typing import Any

import pytest
from objects import (
    CHIPS,
    CNTR_MAX,
    DESCRIPTOR_BYTES,
    DESCRIPTORS,
    PAGE_WORDS,
    RECIP_FAR,
    RECIP_NEAR,
    RECIP_SPLIT,
    RECIP_WORDS,
    SEQ_DIRECTORY,
    SEQ_HEADER,
    SEQ_POLYGON,
    SEQ_RECORD,
    TERMINATOR,
    Face,
    FormatError,
    Layout,
    Mesh,
    Residue,
    TraceRun,
    asm_pages,
    check_trace,
    decode,
    descriptor_columns,
    descriptors,
    encode,
    encode_words,
    layout_from_manifest,
    manifest_json,
    mesh_from_json,
    mesh_json,
    part_sum,
    place,
    read_data,
    read_trace,
    reciprocal,
    run_columns,
    sequences,
    to_bytes,
    to_words,
    trace_summary,
    write_data,
)
from romset import hashes, load_snapshot

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
DATA = REPO / "data/objects"
IMAGE = REPO / "build/stunrun-obj.bin"
TRACES = [REPO / "build/mame/objtrace-attract.txt", REPO / "build/mame/objtrace-play.txt"]
IMAGE_68K = REPO / "build/stunrun-68k.bin"


def random_mesh(rng: random.Random, number: int) -> Mesh:
    nv, nn = rng.randint(1, 9), rng.randint(1, 4)
    vertices = [tuple(rng.randint(-0x8000, 0x7FFF) for _ in range(3)) for _ in range(nv)]
    normals = [tuple(rng.randint(-0x4000, 0x4000) for _ in range(3)) for _ in range(nn)]
    faces = [
        Face(
            rng.choice([1, 15, rng.randint(2, 14)]),
            rng.choice([0, rng.randint(1, 63)]),
            rng.randrange(nn),
            [rng.randrange(nv) for _ in range(rng.randint(1, 6))],
        )
        for _ in range(rng.randint(0, 6))
    ]
    return Mesh(number, vertices, normals, faces)  # type: ignore[arg-type]


def synthetic(seed: int = 1, count: int = 10) -> tuple[Layout, dict[int, Mesh]]:
    """`count` random objects spread over the three pages in number order. With count = 10 the
    directory and its terminator take words 0-10 and word 11 is padding."""
    rng = random.Random(seed)
    meshes = {n: random_mesh(rng, n) for n in range(count)}
    pages: list[list[int]] = [[], [], []]
    for n in range(count):
        pages[rng.randrange(3)].append(n)
    return Layout(count, pages), meshes


def test_part_sums() -> None:
    assert [(part_sum(e), part_sum(o)) for e, o in CHIPS] == [
        (0x21, 0x18),
        (0x22, 0x19),
        (0x20, 0x17),
    ]


def test_reciprocal_rule() -> None:
    assert reciprocal(0) == 0 and reciprocal(RECIP_WORDS - 1) == 0
    assert reciprocal(1) == RECIP_NEAR and reciprocal(RECIP_SPLIT) == RECIP_NEAR // RECIP_SPLIT
    # float32 rounding: equal to round() everywhere except five quotients just below n + 0.5
    off = [
        z
        for z in range(1, RECIP_WORDS - 1)
        if reciprocal(z) != round((RECIP_NEAR if z <= RECIP_SPLIT else RECIP_FAR) / z)
    ]
    assert off == [0x2F1, 0xAC9, 0xFD3, 0x205B, 0x2F79]


@pytest.mark.parametrize("seed", [1, 2, 3])
def test_round_trip_synthetic(seed: int) -> None:
    layout, meshes = synthetic(seed)
    image = encode(layout, meshes)
    decoded = decode(image)
    assert decoded.layout == layout
    assert decoded.meshes == meshes
    assert encode(decoded.layout, decoded.meshes) == image
    words = to_words(image)
    # the checksum makes each chip's byte sum its part number's last two digits (hex)
    for page in range(3):
        page_words = words[page * PAGE_WORDS : (page + 1) * PAGE_WORDS]
        assert sum(w >> 8 for w in page_words) & 0xFF == part_sum(CHIPS[page][0])
        assert sum(w & 0xFF for w in page_words) & 0xFF == part_sum(CHIPS[page][1])
    # every placed object starts at a multiple of 4 and the directory points at it
    for p in decoded.placed:
        assert p.address % 4 == 0 and words[p.number] == p.page << 14 | p.address >> 2
    assert words[layout.objects] == TERMINATOR


def test_planted_difference_is_one_word() -> None:
    layout, meshes = synthetic(4)
    image = to_words(encode(layout, meshes))
    n = next(n for n, m in meshes.items() if m.vertices)
    meshes[n].vertices[0] = (meshes[n].vertices[0][0] ^ 1,) + meshes[n].vertices[0][1:]
    planted = encode_words(layout, meshes)
    p = next(p for p in place(layout, meshes) if p.number == n)
    diff = [i for i, (a, b) in enumerate(zip(image, planted, strict=True)) if a != b]
    # the vertex's x word, and the checksum word of its page
    assert diff[0] == p.page * PAGE_WORDS + p.address + 3
    assert len(diff) == 2 and diff[1] // PAGE_WORDS == p.page


def test_residue_is_kept_out_of_the_data() -> None:
    layout, meshes = synthetic(5)
    words = encode_words(layout, meshes)
    words[layout.objects + 1] = 0x1234  # a non-zero word in the directory's padding
    # the checksum word of page 0 was computed without it: decode takes the word as residue,
    # re-encodes with it and finds the stale checksum
    with pytest.raises(FormatError, match="re-encode"):
        decode(to_bytes(words))
    layout2 = Layout(layout.objects, layout.pages, [Residue(0, layout.objects + 1, 1)])
    fixed = encode(layout2, meshes, to_bytes(words))
    decoded = decode(fixed)
    assert decoded.layout.residue == [Residue(0, layout.objects + 1, 1)]
    assert "1234" not in manifest_json(decoded.layout)
    # without the image the residue word is zero and its page's checksum word differs
    blank = to_words(encode(decoded.layout, decoded.meshes))
    diff = [i for i, (a, b) in enumerate(zip(blank, to_words(fixed), strict=True)) if a != b]
    assert len(diff) == 2 and diff[0] == layout.objects + 1


@pytest.mark.parametrize(
    ("offset", "value", "match"),
    [
        (0, None, "header point count"),  # the header's point count
        (3, None, "record list does not follow"),  # the record-list pointer, after 0 coords
        ("count", 0x0040, "polygon count field"),
        ("normal", 0, "not a normal point"),
        ("vertex", 0x7000, "not a vertex point"),
    ],
)
def test_malformed_images_are_rejected(offset: object, value: int | None, match: str) -> None:
    mesh = Mesh(0, [(1, 2, 3), (4, 5, 6)], [(0, 0x4000, 0)], [Face(15, 5, 0, [0, 1])])
    layout = Layout(1, [[0], [], []])
    words = encode_words(layout, {0: mesh})
    a = place(layout, {0: mesh})[0].address
    # header: 3 words, 9 coordinate words, the pointer at a + 12, records at a + 13
    if offset == 0:
        words[a] += 1
    elif offset == 3:
        words[a + 12] += 1
    elif offset == "count":
        words[a + 14] |= value or 0
    elif offset == "normal":
        words[a + 17] = 1  # point 1 is a vertex
    elif offset == "vertex":
        words[a + 18] = value or 0
    with pytest.raises(FormatError, match=match):
        decode(to_bytes(words))


def test_no_terminator_and_wrong_size() -> None:
    with pytest.raises(FormatError, match="393216"):
        decode(b"\0" * 10)
    with pytest.raises(FormatError):
        decode(b"\0" * 0x60000)  # a zero directory points every object at page 0 word 0


@pytest.mark.parametrize(
    ("edit", "match"),
    [
        (lambda d: d["vertices"].__setitem__(0, [40000, 0, 0]), "16-bit"),
        (lambda d: d["faces"][0].__setitem__("normal", 9), "normal 9"),
        (lambda d: d["faces"][0].__setitem__("vertices", []), "vertices out of range or empty"),
        (lambda d: d["faces"][0].__setitem__("type", 0), "type 0"),
        (lambda d: d["faces"][0].__setitem__("colour", 64), "colour 64"),
        (lambda d: d.__setitem__("extra", [1]), "unknown key"),
        (lambda d: d.pop("normals"), "malformed"),
    ],
)
def test_malformed_meshes_are_rejected(
    edit: Callable[[dict[str, Any]], object], match: str
) -> None:
    mesh = Mesh(7, [(1, 2, 3), (4, 5, 6)], [(0, 0x4000, 0)], [Face(15, 5, 0, [0, 1])])
    d = json.loads(mesh_json(mesh))
    assert mesh_from_json(mesh_json(mesh)) == mesh
    edit(d)
    with pytest.raises(FormatError, match=match):
        mesh_from_json(json.dumps(d))


def test_layout_errors() -> None:
    layout, meshes = synthetic(6)
    bad = Layout(
        layout.objects, [layout.pages[0] + [layout.objects], layout.pages[1], layout.pages[2]]
    )
    with pytest.raises(FormatError, match="exactly once"):
        encode(bad, meshes)
    unordered = Layout(layout.objects, [list(reversed(range(layout.objects))), [], []])
    with pytest.raises(FormatError, match="number order"):
        encode(unordered, meshes)
    big = Mesh(0, [(0, 0, 0)] * 11000, [(0, 0, 0)] * 11000, [])
    with pytest.raises(FormatError, match="overflow"):
        encode(Layout(1, [[], [], [0]]), {0: big})
    with pytest.raises(FormatError, match="format"):
        layout_from_manifest('{"format": "other"}')
    many = Mesh(0, [(0, 0, 0)] * (CNTR_MAX + 1), [(0, 0, 0)], [])
    with pytest.raises(FormatError, match="more than"):
        encode(Layout(1, [[], [], [0]]), {0: many})


def test_data_files_round_trip(tmp_path: Path) -> None:
    layout, meshes = synthetic(7)
    image = encode(layout, meshes)
    decoded = decode(image)
    write_data(tmp_path, decoded, {3: "a test name"})
    layout2, meshes2, names = read_data(tmp_path)
    assert (layout2, meshes2, names) == (layout, meshes, {3: "a test name"})
    (tmp_path / "999.json").write_text("{}")
    with pytest.raises(FormatError, match="beyond"):
        read_data(tmp_path)


def run_cli(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(TOOLS / "objects"), *args], capture_output=True, text=True, check=False
    )


def test_decode_keeps_names_when_a_mesh_is_invalid(tmp_path: Path) -> None:
    """`make objects` is how a person restores data/objects after a bad edit: the names live in
    the manifest and must survive an invalid mesh file."""
    layout, meshes = synthetic(9)
    image = tmp_path / "image.bin"
    image.write_bytes(encode(layout, meshes))
    out = tmp_path / "objects"
    write_data(out, decode(image.read_bytes()), {2: "kept"})
    bad = json.loads((out / "005.json").read_text())
    bad["faces"] = [{"type": 15, "colour": 64, "normal": 0, "vertices": [0]}]
    (out / "005.json").write_text(json.dumps(bad))
    with pytest.raises(FormatError):
        read_data(out)
    r = run_cli("decode", "--image", str(image), "--out", str(out))
    assert r.returncode == 0, r.stdout + r.stderr
    assert read_data(out) == (layout, meshes, {2: "kept"})
    (out / "manifest.json").write_text("{")
    r = run_cli("decode", "--image", str(image), "--out", str(out))
    assert r.returncode == 1 and "not overwritten" in r.stderr
    assert (out / "manifest.json").read_text() == "{"


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


@pytest.mark.skipif(vasm() is None, reason="vasm not available")
def test_generated_assembly_matches_encode(tmp_path: Path) -> None:
    layout, meshes = synthetic(8)
    words = encode_words(layout, meshes)
    words[layout.objects + 1] = 0xBEEF
    layout.residue = [Residue(0, layout.objects + 1, 1)]
    image = encode(layout, meshes, to_bytes(words))
    (tmp_path / "image.bin").write_bytes(image)
    main = ["\torg\t0"]
    for page, text in enumerate(asm_pages(layout, meshes, image, "image.bin")):
        (tmp_path / f"page{page}.asm").write_text(text)
        main.append(f'\tinclude\t"page{page}.asm"')
    main.append('\tassert\t*=$60000,"end"')
    (tmp_path / "main.asm").write_text("\n".join(main) + "\n")
    r = subprocess.run(
        [vasm(), "-quiet", "-Fbin", "-no-opt", "-o", "out.bin", "main.asm"],  # type: ignore[list-item]
        cwd=tmp_path,
        capture_output=True,
        text=True,
        check=False,
    )
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / "out.bin").read_bytes() == image


def test_committed_data_rebuilds_pages_1_and_2() -> None:
    """CI: the committed meshes encode to the four chips of pages 1 and 2 exactly as MAME lists
    them (page 0 needs the residue word from the ROM image)."""
    layout, meshes, _ = read_data(DATA)
    image = encode(layout, meshes)
    roms = {r["name"]: r for r in load_snapshot("stunrun")["roms"]}
    for page in (1, 2):
        block = image[page * 0x20000 : (page + 1) * 0x20000]
        for chip, data in zip(CHIPS[page], (block[0::2], block[1::2]), strict=True):
            assert hashes(data) == (roms[chip]["crc"], roms[chip]["sha1"]), chip
    assert [(r.page, r.words) for r in layout.residue] == [(0, 1)]


@pytest.mark.skipif(not IMAGE.exists(), reason="build/stunrun-obj.bin absent (no reference set)")
def test_reference_image_decodes_to_committed_data(tmp_path: Path) -> None:
    image = IMAGE.read_bytes()
    _, _, names = read_data(DATA)
    write_data(tmp_path, decode(image), names)
    committed = sorted(p.name for p in DATA.glob("*.json"))
    assert sorted(p.name for p in tmp_path.glob("*.json")) == committed
    differ = [n for n in committed if (tmp_path / n).read_text() != (DATA / n).read_text()]
    assert differ == []
    layout, meshes, _ = read_data(DATA)
    assert encode(layout, meshes, image) == image


@pytest.mark.skipif(
    not IMAGE.exists() or not all(p.exists() for p in TRACES),
    reason="object image or MAME traces absent (make objtrace)",
)
def test_mame_trace_matches_decoder() -> None:
    image = IMAGE.read_bytes()
    decoded = decode(image)
    for path in TRACES:
        run = read_trace(path)
        assert int(run.header["frames"]) >= 3600
        assert check_trace(decoded, image, run) == []
        loaded = {r[2] for r in run.rows if r[0] == SEQ_DIRECTORY}
        assert loaded and loaded <= set(decoded.meshes)


def test_trace_check_catches_planted_problems() -> None:
    layout, meshes = synthetic(9)
    image = encode(layout, meshes)
    decoded = decode(image)
    seq = sorted(sequences(decoded, image).items())
    (pc, page, address), reads = seq[0]

    good = TraceRun("t", {"frames": "1", "open_at_end": "1"}, [(pc, page, address, reads, 3)])
    assert check_trace(decoded, image, good) == []
    assert trace_summary(decoded, [good])["runs"][0]["open_at_end"] == 1  # type: ignore[index]
    bad = TraceRun(
        "t",
        {"orphan_reads": "1"},
        [(pc, page, address, reads + 1, 1), (pc, page, 0x0FFF, reads, 1), (0x04C2, 1, 0, 1, 1)],
    )
    problems = check_trace(decoded, image, bad)
    assert len(problems) == 4, problems


def adsp_walk(image: bytes) -> dict[tuple[int, int, int], int]:
    """The read sequences of the ADSP's object path, from the image words alone (not from the
    meshes, unlike `sequences`): 009E reads the directory word, 00A8 sends the object address
    and the header, vertices, normals and record pointer are read on (0172 reads the pointer);
    017B sends each record's address and reads its two words; a type-0 record ends the object;
    colour 0 reads on from the record list to the first FFFF (019F -> 01E4); otherwise 01A7
    sends the polygon address and the polygon is read up to its FFFF."""
    words = to_words(image)
    out: dict[tuple[int, int, int], int] = {}
    n = 0
    while words[n] != TERMINATOR:
        out[(SEQ_DIRECTORY, 0, n)] = 1
        page, a = words[n] >> 14, (words[n] << 2) & 0xFFFF
        base = page * PAGE_WORDS
        nv, nn = words[base + a + 1], words[base + a + 2]
        pointer = a + 3 + 3 * (nv + nn)
        out[(SEQ_HEADER, page, a)] = pointer + 1 - a
        r = words[base + pointer]
        while True:
            r0, r1 = words[base + r], words[base + r + 1]
            if r1 >> 12 == 0:
                out[(SEQ_RECORD, page, r)] = 2
                break
            q = r0 if r1 & 0x3F else r + 2
            while words[base + q] != TERMINATOR:
                q += 1
            if r1 & 0x3F:
                out[(SEQ_RECORD, page, r)] = 2
                out[(SEQ_POLYGON, page, r0)] = q + 1 - r0
            else:
                out[(SEQ_RECORD, page, r)] = q + 1 - r
            r += 2
        n += 1
    return out


@pytest.mark.parametrize("seed", [1, 2, 3, 9])
def test_trace_predictions_match_an_adsp_walk(seed: int) -> None:
    """CI: the lengths the trace oracle expects (`sequences`) are the ones an independent walk of
    the encoded words gives, for every kind: directory, header, records (colour 0 included),
    polygons, end record."""
    layout, meshes = synthetic(seed)
    # one hand-made object on page 2 with a colour-0 face between two drawn faces
    meshes[10] = Mesh(
        10,
        [(1, 2, 3), (4, 5, 6), (7, 8, 9)],
        [(0, 0, 0x4000), (0x4000, 0, 0)],
        [Face(15, 5, 0, [0, 1, 2]), Face(15, 0, 1, [2, 1]), Face(1, 7, 1, [0])],
    )
    layout = Layout(11, [*layout.pages[:2], [*layout.pages[2], 10]])
    image = encode(layout, meshes)
    decoded = decode(image)
    expected = sequences(decoded, image)
    assert expected == adsp_walk(image)
    a = next(p.address for p in decoded.placed if p.number == 10)
    # header 4 + 3 x 5 = 19 words; records at a + 19; polygons after 3 records and the end record
    assert expected[(SEQ_HEADER, 2, a)] == 19
    r, poly = a + 19, a + 19 + 8
    assert expected[(SEQ_RECORD, 2, r)] == 2
    assert expected[(SEQ_POLYGON, 2, poly)] == 5
    # colour 0: its record, the next record, the end record, the first polygon (to its FFFF)
    assert expected[(SEQ_RECORD, 2, r + 2)] == 6 + 5
    assert (SEQ_POLYGON, 2, poly + 5) not in expected
    assert expected[(SEQ_RECORD, 2, r + 4)] == 2
    assert expected[(SEQ_POLYGON, 2, poly + 9)] == 3
    assert expected[(SEQ_RECORD, 2, r + 6)] == 2


def test_descriptor_and_run_columns() -> None:
    """CI: the inventory's descriptor and run columns from a synthetic 68k image and summary."""
    image = bytearray(DESCRIPTORS + DESCRIPTOR_BYTES * 0x13A)
    table = {0: (0, 1), 1: (2, 2), 2: (3, 1), 0x139: (-1, -1)}
    for d, (near, far) in table.items():
        a = DESCRIPTORS + DESCRIPTOR_BYTES * d
        image[a : a + 4] = (near & 0xFFFF).to_bytes(2, "big") + (far & 0xFFFF).to_bytes(2, "big")
    descs = descriptors(bytes(image))
    assert len(descs) == 0x13A and descs[0x139] == (-1, -1)
    # descriptors 3..312 are all zero: object 0 is their near object too
    columns = descriptor_columns(descs, 5)
    assert columns[0].split(", ")[:2] == ["0", "3"]
    assert columns[1] == "0f, 2f"
    assert columns[2] == "1"
    assert columns[3] == "2"
    assert columns[4] == ""
    summary = {
        "runs": [
            {"run": "objtrace-attract", "objects_loaded": [0, 2]},
            {"run": "objtrace-play", "objects_loaded": [2, 3]},
        ]
    }
    assert run_columns(summary, 5) == {0: "A", 1: "-", 2: "AP", 3: "P", 4: "-"}


@pytest.mark.skipif(
    not IMAGE_68K.exists(), reason="build/stunrun-68k.bin absent (no reference set)"
)
def test_inventory_table_is_the_docs_table() -> None:
    """With the reference set: docs/07 section 10 is exactly what the inventory command prints,
    and every object is selected by a descriptor."""
    r = run_cli(
        "inventory",
        "--image68k",
        str(IMAGE_68K),
        "--summary",
        str(REPO / "artifacts/objtrace-summary.json"),
    )
    assert r.returncode == 0, r.stderr
    assert "0 in no descriptor" in r.stderr
    doc = (REPO / "docs/07-objects.md").read_text().splitlines()
    start = doc.index(r.stdout.splitlines()[0])
    table = doc[start : start + len(r.stdout.splitlines())]
    assert table == r.stdout.splitlines()


if __name__ == "__main__":
    sys.exit(pytest.main([__file__]))
