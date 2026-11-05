"""The build tools on a synthetic set: random bytes laid out like stunrun, never ROM data.

merge-roms / split-roms round trip, bytecheck's report on a planted difference, and (when vasm
and 64tass are on PATH or in $VASM / $TASS) the whole `make all` + bytecheck + coverage on a copy
of the repository's Makefile, asm/, tools/ and data/objects.

The object image is built from the committed data/objects alone (docs/07-objects.md: meshes,
manifest, the residue constant), so the synthetic set carries, in place of random bytes there,
the image the committed data encodes to: `make all` must rebuild it without reading
build/stunrun-obj.bin, and a mesh edited in the copy must change the built object ROMs.

The OKI image goes through one WAV per sample (docs/10-adpcm.md), split by the phrase table that
data/oki/samples.json describes, so the synthetic set carries a valid OKI image: that table over
random sample bytes and a zero tail. A WAV altered by one data byte must change the built file.
"""

from __future__ import annotations

import json
import os
import random
import shutil
import subprocess
import sys
from pathlib import Path

import pytest
from adpcm import build as build_oki
from adpcm import read_manifest
from objects import checksum_address, encode, place, read_data
from romset import IMAGES, compare, layout, load_snapshot, merge, split
from test_programs import plant_programs

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent


def synthetic_set(seed: int = 1989) -> dict[str, bytes]:
    rng = random.Random(seed)
    return {r["name"]: rng.randbytes(r["size"]) for r in load_snapshot("stunrun")["roms"]}


def write_set(root: Path, files: dict[str, bytes]) -> Path:
    root.mkdir(parents=True)
    for name, data in files.items():
        (root / name).write_bytes(data)
    return root


def plant_objects() -> bytes:
    """The object image the committed data/objects encodes to."""
    layout_, meshes, _ = read_data(REPO / "data/objects")
    return encode(layout_, meshes)


def plant_oki(seed: int) -> bytes:
    """A valid OKI image: the committed manifest's phrase table over random sample bytes."""
    layout = read_manifest(REPO / "data/oki/samples.json")
    rng = random.Random(seed)
    return build_oki(layout, {p.number: rng.randbytes(p.length) for p in layout.phrases})


def run(*args: object, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [str(a) for a in args], capture_output=True, text=True, check=False, env=env
    )


def test_layout_sizes() -> None:
    _, sizes = layout(load_snapshot("stunrun"))
    assert sizes == {
        "stunrun-68k": 0xC0000,
        "stunrun-obj": 0x60000,
        "stunrun-oki": 0x40000,
        "stunrun-jsa": 0x10000,
        "stunrun-nvram": 0x1000,
    }
    assert sum(sizes.values()) == 1_511_424


def test_merge_interleaves_and_split_inverts() -> None:
    snapshot = load_snapshot("stunrun")
    files = synthetic_set()
    images = merge(snapshot, files)
    m68k = images["stunrun-68k"]
    # 200x even (D15-D8), 210x odd; pair S at 0x20000
    assert m68k[0] == files["136070-2102.200r"][0]
    assert m68k[1] == files["136070-2101.210r"][0]
    assert m68k[0x20000 + 2 * 5] == files["136070-6104.200s"][5]
    assert m68k[0x20000 + 2 * 5 + 1] == files["136070-6103.210s"][5]
    assert m68k[0xBFFFF] == files["136070-2111.210w"][-1]
    obj = images["stunrun-obj"]
    assert obj[0x40000:0x40004] == bytes(
        [files["136070-2120.9h"][0], files["136070-2117.9k"][0]]
        + [files["136070-2120.9h"][1], files["136070-2117.9k"][1]]
    )
    assert images["stunrun-oki"][0x30000:] == files["136070-2127.1cd"]
    assert images["stunrun-jsa"] == files["136070-2123.10c"]
    assert images["stunrun-nvram"] == files["stunrun.200e"] + files["stunrun.210e"]
    assert split(snapshot, images) == files


def test_merge_rejects_missing_and_short_files() -> None:
    snapshot = load_snapshot("stunrun")
    files = synthetic_set()
    del files["136070-2121.90h"]
    with pytest.raises(ValueError, match="missing 136070-2121.90h"):
        merge(snapshot, files)
    files = synthetic_set()
    files["stunrun.210e"] = files["stunrun.210e"][:-1]
    with pytest.raises(ValueError, match="2047 bytes"):
        merge(snapshot, files)


def test_cli_round_trip(tmp_path: Path) -> None:
    files = synthetic_set(7)
    write_set(tmp_path / "archive" / "stunrun", files)
    out = tmp_path / "images"
    r = run(sys.executable, TOOLS / "merge-roms", "--archive", tmp_path / "archive", "--out", out)
    assert r.returncode == 0, r.stdout + r.stderr
    assert sorted(p.stem for p in out.iterdir()) == sorted(IMAGES)
    back = tmp_path / "back"
    r = run(
        sys.executable, TOOLS / "split-roms", "--images", out, "--suffix", ".bin", "--out", back
    )
    assert r.returncode == 0, r.stdout + r.stderr
    assert {p.name: p.read_bytes() for p in back.iterdir()} == files
    r = run(sys.executable, TOOLS / "merge-roms", "--archive", tmp_path / "nowhere", "--out", out)
    assert r.returncode == 2 and "SKIP" in r.stdout


@pytest.mark.parametrize(
    ("name", "offset", "where"),
    [
        ("136070-6103.210s", 0x123, "68k $020247"),
        ("136070-2102.200r", 0x10, "68k $000020"),
        ("136070-2117.9k", 0x10, "ADSP object word $20010"),
        ("136070-2123.10c", 0x1234, "6502 bank 1 $3234"),
        ("136070-2123.10c", 0x5000, "6502 $5000"),
        ("136070-2126.1de", 0x42, "OKI $20042"),
        ("stunrun.210e", 0x7FF, "byte $7FF"),
    ],
)
def test_compare_reports_cpu_address(name: str, offset: int, where: str) -> None:
    snapshot = load_snapshot("stunrun")
    reference = synthetic_set()
    built = dict(reference)
    data = bytearray(built[name])
    data[offset] ^= 0xFF
    built[name] = bytes(data)
    assert compare(snapshot, built, reference) == [
        f"{name}: 1 differing bytes, first at file offset ${offset:05X} = {where}"
    ]


def test_compare_counts_and_sizes() -> None:
    snapshot = load_snapshot("stunrun")
    reference = synthetic_set()
    built = dict(reference)
    data = bytearray(built["136070-2111.210w"])
    for i in (0x300, 0x301, 0xFFFF):
        data[i] ^= 0x80
    built["136070-2111.210w"] = bytes(data)
    built["stunrun.200e"] = built["stunrun.200e"][:-2]
    del built["136070-2124.1fh"]
    assert compare(snapshot, built, reference) == [
        "136070-2111.210w: 3 differing bytes, first at file offset $00300 = 68k $0A0601",
        "136070-2124.1fh: not built",
        "stunrun.200e: built 2046 bytes, reference 2048",
    ]


def test_bytecheck_cli(tmp_path: Path) -> None:
    reference = synthetic_set(3)
    write_set(tmp_path / "ref" / "stunrun", reference)
    built = dict(reference)
    data = bytearray(built["136070-6106.200t"])
    data[0x100] ^= 0x5A
    built["136070-6106.200t"] = bytes(data)
    write_set(tmp_path / "built", built)
    args = [sys.executable, TOOLS / "bytecheck", "--archive", tmp_path / "ref"]
    r = run(*args, "--built", tmp_path / "built")
    assert r.returncode == 1
    assert (
        "136070-6106.200t: 1 differing bytes, first at file offset $00100 = 68k $040200" in r.stdout
    )
    (tmp_path / "built" / "136070-6106.200t").write_bytes(reference["136070-6106.200t"])
    r = run(*args, "--built", tmp_path / "built")
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    r = run(*args[:-1], tmp_path / "nowhere", "--built", tmp_path / "built")
    assert r.returncode == 2


def tool(env: str, default: str) -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get(env, default)))


@pytest.mark.skipif(
    tool("VASM", "vasmm68k_mot") is None or tool("TASS", "64tass") is None,
    reason="vasm or 64tass not available",
)
def test_make_all_on_synthetic_set(tmp_path: Path) -> None:
    # random bytes, except a valid (random) program table, ADSP stream and GSP table at
    # 0x017000-0x01EFD4, which tools/extract-programs parses
    snapshot = load_snapshot("stunrun")
    images = merge(snapshot, synthetic_set(42))
    images["stunrun-68k"] = plant_programs(images["stunrun-68k"], 42)
    images["stunrun-obj"] = plant_objects()
    images["stunrun-oki"] = plant_oki(42)
    files = split(snapshot, images)
    write_set(tmp_path / "archive" / "stunrun", files)
    work = tmp_path / "repo"
    work.mkdir()
    shutil.copy(REPO / "Makefile", work)
    shutil.copytree(REPO / "asm", work / "asm")
    shutil.copytree(TOOLS, work / "tools", ignore=shutil.ignore_patterns("__pycache__"))
    shutil.copytree(REPO / "data/objects", work / "data/objects")
    shutil.copytree(REPO / "data/oki", work / "data/oki")
    env = dict(os.environ, STUNRUN_ROMS=str(tmp_path / "archive"))
    make = [
        "make",
        "-C",
        work,
        f"PYTHON={sys.executable}",
        f"VASM={tool('VASM', 'vasmm68k_mot')}",
        f"TASS={tool('TASS', '64tass')}",
    ]
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    built = {p.name: p.read_bytes() for p in (work / "build/roms/stunrun").iterdir()}
    assert built == files
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    r = run(*make, "coverage", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "blob: 73.9% of 1511424 bytes" in r.stdout
    blobs = {line.split()[0]: line.split() for line in r.stdout.splitlines() if line.strip()}
    assert blobs["adsp_program"][1:4] == ["1702E", "8270", "../../build/adsp/program.bin"]
    assert blobs["gsp_program"][1:4] == ["1907C", "24408", "../../build/gsp/program.bin"]
    # the object image has no blob: the residue word is a dc.w like the rest
    # the JSON line is the last of tools/coverage's output (GNU make 4 may print more after it)
    summary = json.loads(next(x for x in reversed(r.stdout.splitlines()) if x.startswith("{")))
    assert summary["images"]["stunrun-obj"]["blob"] == 0
    # the OKI image: the phrase table is data, the tail fill, the 52 samples blob
    assert summary["images"]["stunrun-oki"] == {"instr": 0, "data": 424, "blob": 260864, "fill": 856}
    assert summary["blob"] == 1116928
    assert "build/stunrun-obj.bin" not in r.stdout
    # the merged blobs are kept (not deleted as intermediates of the pattern rules)
    assert sorted(p.name for p in (work / "build").glob("*.bin")) == sorted(
        f"{name}.bin" for name in IMAGES
    )
    # a listing is a target: a missing one reassembles its image instead of crashing coverage
    for name in ("stunrun-obj", "stunrun-jsa"):
        (work / f"build/{name}.lst").unlink()
    r = run(*make, "coverage", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "blob: 73.9% of 1511424 bytes" in r.stdout
    assert (work / "build/stunrun-obj.lst").exists() and (work / "build/stunrun-jsa.lst").exists()
    # the object image needs nothing from the set: rebuilt with build/stunrun-obj.bin gone (and
    # its generated sources and output removed), it is still the same and the blob stays absent
    for path in ["build/stunrun-obj.bin", "build/stunrun-obj.out", "build/stunrun-obj.lst"]:
        (work / path).unlink()
    shutil.rmtree(work / "build/obj")
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert not (work / "build/stunrun-obj.bin").exists()
    assert "stunrun-obj.bin" not in r.stdout + r.stderr
    built = {p.name: p.read_bytes() for p in (work / "build/roms/stunrun").iterdir()}
    assert built == files
    r = run(*make, "coverage", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert not (work / "build/stunrun-obj.bin").exists()
    # a planted difference in a blob reaches the built files and the report names the address
    image = work / "build/stunrun-68k.bin"
    data = bytearray(image.read_bytes())
    data[0x7FFFF] ^= 0x01
    image.write_bytes(bytes(data))
    later = image.stat().st_mtime + 5  # make 3.81 (macOS) compares whole seconds
    os.utime(image, (later, later))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1
    assert (
        "136070-2107.210u: 1 differing bytes, first at file offset $0FFFF = 68k $07FFFF" in r.stdout
    )
    # undo the plant, so that the WAV and mesh edits below are the only differences
    data[0x7FFFF] ^= 0x01
    image.write_bytes(bytes(data))
    later = image.stat().st_mtime + 5
    os.utime(image, (later, later))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    # one data byte of a WAV reaches its OKI file, at the sample's address: phrase 2, byte 0x10
    oki_layout = read_manifest(REPO / "data/oki/samples.json")
    phrase = oki_layout.phrases[1]
    wav = work / f"build/oki/wav/{phrase.stem}.wav"
    original = wav.read_bytes()
    edited = bytearray(original)
    edited[original.index(b"data") + 8 + 0x10] ^= 0x01
    # no mtime bump: the OKI step runs on every make, so an edit in the same second still counts
    wav.write_bytes(bytes(edited))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1
    address = phrase.start + 0x10
    assert "1 problems over 25 files" in r.stdout, r.stdout
    assert (
        f"136070-2124.1fh: 1 differing bytes, first at file offset ${address:05X} = "
        f"OKI ${address:05X}" in r.stdout
    ), r.stdout
    # the same edit from another directory (OKI_WAV_DIR), the build's own WAVs restored
    edits = work / "edited-wavs"
    shutil.copytree(work / "build/oki/wav", edits)
    wav.write_bytes(original)
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    r = run(*make, f"OKI_WAV_DIR={edits}", "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1 and "136070-2124.1fh: 1 differing bytes" in r.stdout, r.stdout
    # a WAV missing from that directory fails the build
    (edits / wav.name).unlink()
    r = run(*make, f"OKI_WAV_DIR={edits}", "all", env=env)
    assert r.returncode != 0 and "absent" in r.stdout + r.stderr
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    # an edited mesh reaches the object ROMs: the vertex's x word and its page's checksum word,
    # both on page 0 (the low bytes, chip 90k), and nothing else in the 25 files
    obj = images["stunrun-obj"]
    pointer = obj[2 * 100] << 8 | obj[2 * 100 + 1]
    assert pointer >> 14 == 0
    vertex_x = (pointer << 2 & 0xFFFF) + 3
    layout_, meshes, _ = read_data(REPO / "data/objects")
    checksum_word = checksum_address(0, place(layout_, meshes), layout_)
    mesh = work / "data/objects/100.json"
    text = mesh.read_text()
    first = text.index("    [") + 5
    end = text.index(",", first)
    mesh.write_text(text[:first] + str(int(text[first:end]) ^ 1) + text[end:])
    later = mesh.stat().st_mtime + 10
    os.utime(mesh, (later, later))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1
    assert "1 problems over 25 files" in r.stdout, r.stdout
    assert "136070-2118.90k: 2 differing bytes" in r.stdout, r.stdout
    built = {p.name: p.read_bytes() for p in (work / "build/roms/stunrun").iterdir()}
    assert {name for name in files if built[name] != files[name]} == {"136070-2118.90k"}
    chip, ref = built["136070-2118.90k"], files["136070-2118.90k"]
    assert [i for i in range(len(ref)) if chip[i] != ref[i]] == sorted([vertex_x, checksum_word])
