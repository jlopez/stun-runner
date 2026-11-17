"""The packed GSP images (docs/15-gsp-images.md): the stream codec, the PNGs, the manifest, the
palettes and the six chips of pairs U-W.

In CI (no ROM): data/gsp-images builds the six chips 200u/210u, 200v/210v, 200w/210w with the
CRC-32 and SHA-1 MAME lists, both in Python and assembled by vasm from the generated includes;
every committed stream decodes back to its images; synthetic streams exercise every command of
the unpacker and every choice of the encoder; a one-pixel edit re-encodes and decodes to the edit;
a size change fails; every PNG's PLTE is what data/palettes gives; the PNGs are the only images
under data/. With the reference set (merged in memory): the committed data is what the image
decodes to, and every palette of data/palettes equals the image at its address. With the MAME
traces of `make imgtrace` in build/mame/: every unpacking is the decoder's output.
"""

from __future__ import annotations

import json
import os
import random
import shutil
import struct
import subprocess
import sys
from pathlib import Path

import gspimages as g
import pytest
from gspimages import png
from gspimages.stream import StreamError, make_table, pack, unpack, words
from romset import DEFAULT_ARCHIVE, hashes, load_snapshot, merge, read_set

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
DATA = REPO / "data/gsp-images"
PALETTES = REPO / "data/palettes"
SET = "stunrun"


def committed() -> tuple[g.Manifest, dict[str, g.Image]]:
    m = g.read_manifest(DATA / "manifest.json")
    return m, g.read_images(DATA, m)


# --- the stream codec ---------------------------------------------------------------------------


def stream(table: bytes, *commands: bytes) -> bytes:
    return b"\0" + table + b"".join(commands) + b"\x40"


TABLE = bytes(range(0xF0, 0x100))


def test_unpack_every_command() -> None:
    """Each command as 0225E4 executes it: literal, nibble block, byte run, pair run, new table,
    end; the odd-byte state carries across commands."""
    s = stream(
        TABLE,
        b"\x03\x11\x22\x33",  # 3 literal bytes (leaves one byte pending)
        b"\x42\x01\x23",  # 2 nibble bytes: F0 F1 F2 F3
        b"\x85\x7a",  # 5 x 7A
        b"\xc3\x45",  # 3 x (F4 F5)
        b"\x00" + bytes(range(16)),  # a new table: 00..0F
        b"\x41\x9f",  # 09 0F
        b"\x01\x55",  # one literal: odd total, the end pads it
    )
    u = unpack(s, 0)
    want = (b"\x11\x22\x33" + bytes([0xF0, 0xF1, 0xF2, 0xF3]) + b"\x7a" * 5
            + bytes([0xF4, 0xF5]) * 3 + b"\x09\x0f" + b"\x55")
    assert u.data == want
    assert u.end == len(s) and u.tables == 2
    assert len(want) % 2 == 1
    assert words(want)[-1] == 0x5500  # 0225D4: the pending byte goes out with a 0 low byte


@pytest.mark.parametrize(
    "blob, message",
    [
        (b"\x01" + TABLE + b"\x40", "first byte"),
        (b"\0" + TABLE + b"\x80\x00\x40", "soft_reset"),
        (b"\0" + TABLE + b"\xc0\x00\x40", "soft_reset"),
        (b"\0" + TABLE + b"\x05\x01\x02", "runs past"),
    ],
)
def test_unpack_rejects_what_the_unpacker_does_not_take(blob: bytes, message: str) -> None:
    with pytest.raises(StreamError, match=message):
        unpack(blob, 0)


def test_table_is_the_16_most_frequent_values() -> None:
    data = bytes([5] * 9 + [3] * 9 + [7] * 4 + [1])
    assert make_table(data)[:4] == bytes([3, 5, 7, 1])
    assert make_table(data)[4:] == bytes(12)  # padded with 00
    many = bytes(v for v in range(40) for _ in range(40 - v))
    assert make_table(many) == bytes(range(16))


def commands(blob: bytes) -> list[tuple[int, int]]:
    """(kind, n) of every command after the table: kind = c >> 6."""
    p, out = 17, []  # type: tuple[int, list[tuple[int, int]]]
    while True:
        c = blob[p]
        kind, n = c >> 6, c & 0x3F
        if c == 0x40:
            return out
        out.append((kind, n))
        p += 1 + (n if kind < 2 else 1)


@pytest.mark.parametrize(
    "data, want",
    [
        # a pair repeated 3 times is a pair run; twice is a nibble block
        (bytes([1, 2] * 3 + [9]), [(3, 3), (0, 1)]),
        (bytes([1, 2] * 2 + [3, 4, 9]), [(1, 3), (0, 1)]),
        # ... unless the two pairs end the data
        (bytes([1, 2, 3, 4, 1, 2, 1, 2]), [(1, 2), (3, 2)]),
        # a value not in the table repeated is a byte run, at most 63
        (bytes([1] * 16) + bytes(range(100, 100)) + bytes([200] * 70), None),
        # nibble blocks hold at most 62 bytes
        (bytes(range(16)) * 10 + b"\xaa", None),
    ],
)
def test_encoder_choices(data: bytes, want: list[tuple[int, int]] | None) -> None:
    blob = pack(data)
    assert unpack(blob, 0).data == data
    got = commands(blob)
    if want is not None:
        assert got == want
    assert all(n <= (62 if kind == 1 else 63) for kind, n in got)


def test_encoder_runs_and_limits() -> None:
    # 17 distinct values: the 17th (least frequent) is not in the table and goes as byte runs
    data = bytes(v for v in range(16) for _ in range(80)) + bytes([0xEE] * 70) + b"\x01\x02\x03"
    got = commands(pack(data))
    assert (2, 63) in got and (2, 7) in got
    assert unpack(pack(data), 0).data == data


def test_encoder_round_trip_on_random_data() -> None:
    rng = random.Random(1989)
    for _ in range(200):
        n = rng.randrange(1, 600)
        vals = [rng.randrange(256) for _ in range(rng.randrange(1, 30))]
        grow = bytearray()
        while len(grow) < n:
            v = rng.choice(vals)
            grow += bytes([v]) * rng.choice([1, 1, 1, 2, 3, 5, 70])
        data = bytes(grow[:n])
        assert unpack(pack(data), 0).data == data


# --- images -------------------------------------------------------------------------------------


def test_headed_image_layout() -> None:
    img = g.Image(5, 5, bytes(range(1, 26)))
    b = g.headed_bytes(img)
    assert struct.unpack(">6H", b[:12]) == (5, 5, 208, 0, 0, 0)  # 16 x ceil(25 / 2) bits
    assert len(b) == 40  # 12 + 26 rounded up to 32 bits
    assert b[12:14] == bytes([2, 1])  # the low byte of each word is the lower x
    assert g.split_headed(b, "t") == [img]
    with pytest.raises(g.FormatError, match="padding"):
        g.split_headed(b[:-1] + b"\1", "t")
    bad = bytearray(b)
    bad[11] = 1
    with pytest.raises(g.FormatError, match="reserved"):
        g.split_headed(bytes(bad), "t")


def test_png_round_trip_and_editor_forms() -> None:
    rng = random.Random(7)
    pixels = bytes(rng.randrange(256) for _ in range(13 * 7))
    pal = [(i, 255 - i, i // 2) for i in range(256)]
    blob = png.write(13, 7, pixels, pal)
    back = png.read(blob)
    assert (back.width, back.height, back.pixels, back.palette) == (13, 7, pixels, pal)
    # filters 1-4 and a 4-bit depth, as an editor may save them
    import zlib

    def chunk(t: bytes, b: bytes) -> bytes:
        return struct.pack(">I", len(b)) + t + b + struct.pack(">I", zlib.crc32(t + b))

    w, h = 6, 4
    px = [[(x * 3 + y * 5) % 16 for x in range(w)] for y in range(h)]
    rows = b""
    prev = bytes((w + 1) // 2)
    for y in range(h):
        line = bytes((px[y][2 * k] << 4) | px[y][2 * k + 1] for k in range(w // 2))
        f = y % 3 + 2  # 2 up, 3 average, 4 paeth
        enc = bytearray()
        for x, v in enumerate(line):
            a = line[x - 1] if x else 0
            b = prev[x]
            c = prev[x - 1] if x else 0
            pred = b if f == 2 else (a + b) // 2 if f == 3 else png._paeth(a, b, c)
            enc.append((v - pred) & 0xFF)
        rows += bytes([f]) + bytes(enc)
        prev = line
    four = (png.SIGNATURE + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 4, 3, 0, 0, 0))
            + chunk(b"PLTE", bytes(c for rgb in pal[:16] for c in rgb))
            + chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b""))
    got = png.read(four)
    assert got.pixels == bytes(v for row in px for v in row)
    with pytest.raises(png.PngError, match="indexed"):
        png.read(png.SIGNATURE + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
                 + chunk(b"IEND", b""))


# --- the committed data -------------------------------------------------------------------------

UVW = [
    "136070-2108.200u", "136070-2107.210u", "136070-2110.200v", "136070-2109.210v",
    "136070-2112.200w", "136070-2111.210w",
]


def test_committed_data_builds_the_six_chips() -> None:
    """CI: data/gsp-images builds pairs U-W exactly as MAME lists them, with no ROM read."""
    m, images = committed()
    region, _placed, end = g.build(m, images)
    roms = {r["name"]: r for r in load_snapshot(SET)["roms"]}
    chips = g.chips(region)
    assert sorted(chips) == sorted(UVW)
    for name, data in chips.items():
        assert len(data) == roms[name]["size"] == 0x10000
        assert hashes(data) == (roms[name]["crc"], roms[name]["sha1"]), name
    assert end == 0x0B10EB


def vasm() -> str:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot"))) or ""


@pytest.mark.skipif(not vasm(), reason="vasm not available")
def test_assembled_region_is_the_six_chips(tmp_path: Path) -> None:
    """CI: asm/68k/images.asm and image_table.asm, assembled with the includes tools/gspimages asm
    writes, are the six chips (the tree's own two files, not the Python model)."""
    (tmp_path / "asm/68k").mkdir(parents=True)
    for f in ("images.asm", "image_table.asm"):
        shutil.copy(REPO / "asm/68k" / f, tmp_path / "asm/68k" / f)
    r = subprocess.run([sys.executable, TOOLS / "gspimages", "asm", "--data", DATA, "--palettes",
                        PALETTES, "--out", tmp_path / "build/gsp-images"],
                       capture_output=True, text=True, check=False)
    assert r.returncode == 0, r.stderr
    (tmp_path / "asm/68k/uvw.asm").write_text(
        '\torg\t$060000\n\tinclude\t"images.asm"\n\tinclude\t"image_table.asm"\n'
    )
    r = subprocess.run([vasm(), "-quiet", "-Fbin", "-no-opt", "-m68010", "-o", "uvw.bin",
                        "asm/68k/uvw.asm"], cwd=tmp_path, capture_output=True, text=True,
                       check=False)
    assert r.returncode == 0, r.stdout + r.stderr
    region = (tmp_path / "uvw.bin").read_bytes()
    assert len(region) == 0x60000
    roms = {r["name"]: r for r in load_snapshot(SET)["roms"]}
    for name, data in g.chips(region).items():
        assert hashes(data) == (roms[name]["crc"], roms[name]["sha1"]), name
    # the palettes as dc.b assemble too (make check compares them with the image)
    pal = tmp_path / "build/gsp-images/palettes.asm"
    r = subprocess.run([vasm(), "-quiet", "-Fbin", "-no-opt", "-m68010", "-o", "pal.bin", pal],
                       cwd=tmp_path, capture_output=True, text=True, check=False)
    assert r.returncode == 0, r.stdout + r.stderr
    pals = g.read_palettes(PALETTES)
    assert (tmp_path / "pal.bin").read_bytes() == b"".join(
        pals[n].bytes() for n in sorted(pals, key=lambda n: (pals[n].address, n)))


def test_every_committed_stream_decodes_to_its_images() -> None:
    """The round trip from the committed side: every stream the build encodes decodes (as 0225E4
    does) back to its images; the table points at every stream."""
    m, images = committed()
    region, placed, _ = g.build(m, images)
    table = struct.unpack(">70L", region[g.TABLE - g.REGION : g.TABLE - g.REGION + 280])
    assert table[0] == 0 and table[69] == 0
    for s in m.streams:
        addrs = {table[e] for e in s.entries}
        assert len(addrs) == 1
        u = unpack(region, addrs.pop() - g.REGION)
        want = [images[n] for n in s.images]
        got = [g.split_raw(u.data, "t")] if s.kind == "raw" else g.split_headed(u.data, "t")
        assert got == want, s.label
    for e in m.placeholders:
        assert table[e] == g.REGION


def test_chip_sums_are_the_self_test_values() -> None:
    m, images = committed()
    region, _, _ = g.build(m, images)
    for c in m.sums:
        base = g.PAIRS[c.pair] - g.REGION
        assert sum(region[base + c.parity : base + g.PAIR_SIZE : 2]) & 0xFF == c.sum
        assert c.chip == g.CHIP_NAMES[(c.pair, c.parity)]
        assert "005FF6" in c.evidence and ("0060F4" in c.evidence or "00615A" in c.evidence)


def edited(tmp_path: Path) -> Path:
    data = tmp_path / "gsp-images"
    shutil.copytree(DATA, data)
    return data


def test_one_pixel_edit_reencodes(tmp_path: Path) -> None:
    """An edited pixel (a value outside the stream's table, so the encoder must change commands)
    builds and decodes to the edited image; the region moves, the chip sums stay right."""
    data = edited(tmp_path)
    m = g.read_manifest(data / "manifest.json")
    name = "story_text"
    path = data / f"{name}.png"
    img = png.read(path.read_bytes())
    px = bytearray(img.pixels)
    k = 100 * img.width + 200
    px[k] = 0x77
    path.write_bytes(png.write(img.width, img.height, bytes(px), img.palette))
    images = g.read_images(data, m)
    region, placed, _ = g.build(m, images)
    s = next(s for s in m.streams if name in s.images)
    at = next(p.address for p in placed if p.label == s.label)
    got = g.split_headed(unpack(region, at - g.REGION).data, "t")
    assert got[s.images.index(name)].pixels == bytes(px)
    for c in m.sums:
        base = g.PAIRS[c.pair] - g.REGION
        assert sum(region[base + c.parity : base + g.PAIR_SIZE : 2]) & 0xFF == c.sum


def test_size_change_fails(tmp_path: Path) -> None:
    data = edited(tmp_path)
    path = data / "tree.png"
    img = png.read(path.read_bytes())
    path.write_bytes(png.write(img.width + 1, img.height, bytes((img.width + 1) * img.height),
                               img.palette))
    r = subprocess.run([sys.executable, TOOLS / "gspimages", "asm", "--data", data, "--palettes",
                        PALETTES, "--out", tmp_path / "out"], capture_output=True, text=True,
                       check=False)
    assert r.returncode == 1
    assert "tree.png: 49x80, the manifest says 48x80" in r.stderr
    assert "constants" in r.stderr


def test_manifest_reader_refuses_a_broken_table(tmp_path: Path) -> None:
    raw = json.loads((DATA / "manifest.json").read_text())
    raw["streams"][0]["entries"] = [2]  # entry 1 lost, entry 2 twice
    p = tmp_path / "manifest.json"
    p.write_text(json.dumps(raw))
    with pytest.raises(g.FormatError, match="entry 2 is in two streams"):
        g.read_manifest(p)
    raw = json.loads((DATA / "manifest.json").read_text())
    raw["adjust_words"] = raw["adjust_words"][:2]
    p.write_text(json.dumps(raw))
    with pytest.raises(g.FormatError, match="adjust word per pair"):
        g.read_manifest(p)


def test_png_palettes_are_the_palette_source() -> None:
    """Card A13: every PNG's PLTE is what its manifest spec composes from data/palettes; the
    build never reads colours."""
    m = g.read_manifest(DATA / "manifest.json")
    pals = g.read_palettes(PALETTES)
    for name, info in m.images.items():
        have = png.read((DATA / f"{name}.png").read_bytes()).palette
        assert have == g.image_palette(m, name, pals), name
        spec = info["palette"]
        assert isinstance(spec, dict)
        assert spec["kind"] == ("full" if spec.get("base") else
                                "overlay" if spec.get("overlays") else "grey"), name
        assert spec["evidence"], name


def test_every_palette_is_used() -> None:
    m = g.read_manifest(DATA / "manifest.json")
    used = set()
    for info in m.images.values():
        spec = info["palette"]
        assert isinstance(spec, dict)
        if spec.get("base"):
            used.add(spec["base"])
        for sub in [spec, *spec.get("aliases", [])]:
            used |= {ov["name"] for ov in sub.get("overlays", [])}
    assert used == set(g.read_palettes(PALETTES))


def test_pngs_are_the_only_images_under_data() -> None:
    r = subprocess.run(["git", "-C", REPO, "ls-files", "data"], capture_output=True, text=True,
                       check=False)
    if r.returncode != 0:
        pytest.skip("not a git checkout")
    exts = (".png", ".gif", ".jpg", ".jpeg", ".bmp", ".tif", ".tiff", ".webp", ".ppm", ".pcx")
    found = sorted(f for f in r.stdout.splitlines() if f.lower().endswith(exts))
    m = g.read_manifest(DATA / "manifest.json")
    tracked = [f for f in r.stdout.splitlines() if f.startswith("data/gsp-images/")]
    if not tracked:
        pytest.skip("data/gsp-images not committed yet")
    assert found == sorted(f"data/gsp-images/{n}.png" for n in m.images)
    assert sorted(tracked) == sorted(found + ["data/gsp-images/manifest.json"])


def test_palcheck_fails_on_a_planted_colour(tmp_path: Path) -> None:
    """The make check palette comparison, on a synthetic image (CI): equal passes, one changed
    colour component fails and names the palette."""
    pals = g.read_palettes(PALETTES)
    image = bytearray(0xC0000)
    for p in pals.values():
        image[p.address : p.address + 3 * p.count] = p.bytes()
    src, _ = g.palettes_asm(pals)
    built = b"".join(pals[n].bytes() for n in sorted(pals, key=lambda n: (pals[n].address, n)))
    (tmp_path / "img.bin").write_bytes(bytes(image))
    (tmp_path / "pal.bin").write_bytes(built)
    cmd: list[str | Path] = [sys.executable, TOOLS / "gspimages", "palcheck", "--palettes", PALETTES, "--bin",
           tmp_path / "pal.bin", "--image", tmp_path / "img.bin"]
    r = subprocess.run(cmd, capture_output=True, text=True, check=False)
    assert r.returncode == 0, r.stdout
    title = pals["title"]
    image[title.address + 3 * 7 + 1] ^= 1
    (tmp_path / "img.bin").write_bytes(bytes(image))
    r = subprocess.run(cmd, capture_output=True, text=True, check=False)
    assert r.returncode == 1
    assert "palette title" in r.stdout and "colour 7" in r.stdout


def test_palette_bin_is_rebuilt_on_every_make() -> None:
    """make 3.81 compares whole-second mtimes: palettes.asm is rewritten only when its text
    changes, so a palettes.bin that followed it by mtime could be compared stale by palcheck.
    The palette binary and the 68k tree (which includes the image includes) depend on FORCE, so
    they assemble on every make, whatever the mtimes (make's database, as -p prints it)."""
    for target in ("build/gsp-images/palettes.bin", "build/stunrun-68k.out"):
        r = subprocess.run(["make", "-n", "-p", "--no-print-directory", target], cwd=REPO,
                           capture_output=True, text=True, check=False)
        rule = [ln for ln in r.stdout.splitlines() if ln.startswith(f"{target}:")]
        assert rule, f"make's database has no rule for {target}"
        assert "FORCE" in rule[0].split(":", 1)[1].split(), f"{target} is rebuilt by mtime only"


def test_trace_names_the_first_differing_word(tmp_path: Path) -> None:
    """A complete unpacking whose words differ from the decoder's only in content is reported by
    the word and its GSP address, not by two equal lengths (synthetic trace, CI)."""
    from gspimages.trace import summary

    m, images = committed()
    image = bytes(g.REGION) + g.build(m, images)[0]
    start = int.from_bytes(image[0x0BFE00 + 4 : 0x0BFE08], "big")  # entry 1
    up = unpack(image, start)
    w = words(up.data)
    run = tmp_path / "imgtrace-synthetic.txt"
    run.write_text(f"# frames 10\n"
                   f"call 1 frame 5 dest FFDE0000 words {len(w)} first {start:06X} "
                   f"last {up.end - 1:06X} pc 022602\n# done\n")
    blob = bytearray(b"".join(x.to_bytes(2, "big") for x in w))
    run.with_suffix(".vram").write_bytes(bytes(blob))
    run.with_suffix(".words").write_bytes(bytes(blob))
    assert summary(m, image, [run], PALETTES)[1] == []
    blob[2 * 7] ^= 0x10
    run.with_suffix(".words").write_bytes(bytes(blob))
    problems = summary(m, image, [run], PALETTES)[1]
    assert problems == [f"imgtrace-synthetic: stream {start:06X} (entry 1) at frame 5: word 7 "
                        f"(GSP {0xFFDE0000 + 16 * 7:08X}) differs from the decoded stream's"]


# --- with the reference set ---------------------------------------------------------------------


def reference_68k() -> bytes:
    files = read_set(DEFAULT_ARCHIVE / SET)
    if files is None:
        pytest.skip(f"reference set absent ({DEFAULT_ARCHIVE / SET})")
    return merge(load_snapshot(SET), files)["stunrun-68k"]


def test_committed_data_is_what_the_image_decodes_to() -> None:
    image = reference_68k()
    m, images = committed()
    dec = g.decode(image, m.sums)
    names: dict[str, str] = {}
    for a, b in zip(sorted(dec.manifest.streams, key=lambda s: s.entries),
                    sorted(m.streams, key=lambda s: s.entries), strict=True):
        assert (a.entries, a.kind, len(a.images)) == (b.entries, b.kind, len(b.images))
        for x, y in zip(a.images, b.images, strict=True):
            assert names.setdefault(x, y) == y
            assert dec.images[x] == images[y], y
    assert dec.manifest.placeholders == m.placeholders
    assert [(a.pair, a.before_entry) for a in dec.manifest.adjust] == [
        (a.pair, a.before_entry) for a in m.adjust]
    assert [(c.pair, c.parity, c.sum) for c in g.chip_sums_from_image(image)] == [
        (c.pair, c.parity, c.sum) for c in m.sums]
    assert g.build(m, images)[0] == image[g.REGION : g.REGION_END]


def test_palettes_equal_the_image() -> None:
    image = reference_68k()
    for p in g.read_palettes(PALETTES).values():
        assert image[p.address : p.address + 3 * p.count] == p.bytes(), p.name


# --- the MAME traces ----------------------------------------------------------------------------


def test_imgtrace_runs_match_the_decoder() -> None:
    runs = sorted((REPO / "build/mame").glob("imgtrace-*.txt"))
    if not runs:
        pytest.skip("no make imgtrace runs in build/mame")
    from gspimages.trace import summary

    m = g.read_manifest(DATA / "manifest.json")
    doc, problems = summary(m, reference_68k(), runs)
    assert problems == []
    assert doc["entries"]
