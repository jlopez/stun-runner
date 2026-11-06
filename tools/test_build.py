"""The build tools on a synthetic set: random bytes laid out like stunrun, never ROM data.

merge-roms / split-roms round trip, bytecheck's report on a planted difference, and (when vasm
and 64tass are on PATH or in $VASM / $TASS) the whole `make all` + bytecheck + coverage on a copy
of the repository's Makefile, asm/, tools/ and data/objects.

The object image is built from the committed data/objects alone (docs/07-objects.md: meshes,
manifest, the residue constant), so the synthetic set carries, in place of random bytes there,
the image the committed data encodes to: `make all` must rebuild it without reading
build/stunrun-obj.bin, and a mesh edited in the copy must change the built object ROMs.

The OKI image is built from the committed data/oki alone (docs/10-adpcm.md: the manifest and one
PCM WAV per phrase, encoded back to ADPCM), so the synthetic set carries the image the committed
WAVs encode to: `make all` must rebuild it without reading build/stunrun-oki.bin, one sample
changed in a WAV must change the built file at that phrase, a longer WAV must move the later
samples, and a phrase renamed with its WAV must build the same bytes.

The 6502 image is built from asm/jsa alone (docs/09-sound-program.md), so the synthetic set
carries the image the source assembles to, and an operand edited in the copy must change 10c.
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
from adpcm import pcm_wav, read_wav
from adpcm.__main__ import encode_all
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


def plant_oki(data: Path = REPO / "data/oki") -> bytes:
    """The OKI image the WAVs of data/oki encode to."""
    layout_, samples, _ = encode_all(data, data / "samples.json")
    return build_oki(layout_, samples)


def plant_jsa(tmp: Path) -> bytes:
    """The 6502 image the committed asm/jsa assembles to."""
    out = tmp / "jsa.bin"
    r = run(tool("TASS", "64tass"), "-q", "-C", "-b", "-o", out, REPO / "asm/jsa/jsa.asm")
    assert r.returncode == 0, r.stdout + r.stderr
    return out.read_bytes()


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


OKI_FILES = ["136070-2124.1fh", "136070-2125.1ef", "136070-2126.1de", "136070-2127.1cd"]


def bump(path: Path, seconds: int) -> None:
    """Move path's mtime into the future (make 3.81 on macOS compares whole seconds)."""
    later = path.stat().st_mtime + seconds
    os.utime(path, (later, later))


def oki_files(work: Path) -> bytes:
    return b"".join((work / "build/roms/stunrun" / n).read_bytes() for n in OKI_FILES)


def check_oki_edits(
    work: Path, make: list[object], env: dict[str, str], files: dict[str, bytes]
) -> None:
    """The edits docs/10 section 5 documents, through make, on the copy's data/oki: one sample
    changed, a longer WAV (the later samples move), a phrase renamed with its WAV."""
    data = work / "data/oki"
    layout_, _, _ = encode_all(data, data / "samples.json")
    phrase = layout_.phrases[1]
    wav = data / f"{phrase.stem}.wav"
    original = wav.read_bytes()
    values = read_wav(original)
    edited = list(values)
    edited[1000] = edited[1000] - 4000 if edited[1000] > 0 else edited[1000] + 4000
    # no mtime bump: the OKI step runs on every make, so an edit in the same second still counts
    wav.write_bytes(pcm_wav(edited))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert f"phrase 2 ({phrase.stem}.wav): edited" in r.stdout
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1
    address = phrase.start + 1000 // 2
    assert "1 problems over 25 files" in r.stdout, r.stdout
    assert "136070-2124.1fh: " in r.stdout and (
        f"first at file offset ${address:05X} = OKI ${address:05X}" in r.stdout
    ), r.stdout
    wav.write_bytes(original)
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    # phrase 1 longer by 256 samples (128 bytes): every later sample moves up by 128 bytes, the
    # table follows, and the tail shrinks; no address is edited anywhere
    first = layout_.phrases[0]
    one = data / f"{first.stem}.wav"
    one_original = one.read_bytes()
    one.write_bytes(pcm_wav(read_wav(one_original) + [0] * 256))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    moved, samples, _ = encode_all(data, data / "samples.json")
    assert [p.start for p in moved.phrases[1:]] == [p.start + 128 for p in layout_.phrases[1:]]
    assert oki_files(work) == build_oki(moved, samples)
    assert oki_files(work) != b"".join(files[n] for n in OKI_FILES)
    one.write_bytes(one_original)
    # phrase 3 renamed in the manifest and its WAV renamed with it: the same bytes; the manifest
    # alone renamed fails the build on the WAV no phrase names
    manifest = data / "samples.json"
    text = manifest.read_text()
    doc = json.loads(text)
    old = doc["phrases"][2]["name"]
    doc["phrases"][2]["name"] = "renamed_03"
    manifest.write_text(json.dumps(doc))
    r = run(*make, "all", env=env)
    assert r.returncode != 0 and "no phrase of the manifest has this name" in r.stdout + r.stderr
    (data / f"03-{old}.wav").rename(data / "03-renamed_03.wav")
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    manifest.write_text(text)
    (data / "03-renamed_03.wav").rename(data / f"03-{old}.wav")
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout


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
    images["stunrun-oki"] = plant_oki()
    images["stunrun-jsa"] = plant_jsa(tmp_path)
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
    assert "blob: 52.3% of 1511424 bytes" in r.stdout
    blobs = {line.split()[0]: line.split() for line in r.stdout.splitlines() if line.strip()}
    assert blobs["adsp_program"][1:4] == ["1702E", "8270", "../../build/adsp/program.bin"]
    assert blobs["gsp_program"][1:4] == ["1907C", "24408", "../../build/gsp/program.bin"]
    # the object image has no blob: the residue word is a dc.w like the rest
    # the JSON line is the last of tools/coverage's output (GNU make 4 may print more after it)
    summary = json.loads(next(x for x in reversed(r.stdout.splitlines()) if x.startswith("{")))
    assert summary["images"]["stunrun-obj"]["blob"] == 0
    # the OKI image has no blob either: the phrase table and the 52 samples data, the tail fill
    assert summary["images"]["stunrun-oki"] == {
        "instr": 0, "data": 424 + 260864, "blob": 0, "fill": 856}
    # nor has the 6502 image a blob: all instructions, data and fills
    assert summary["images"]["stunrun-jsa"]["blob"] == 0
    assert summary["images"]["stunrun-jsa"]["instr"] > 0
    assert summary["blob"] == 790528
    assert "build/stunrun-obj.bin" not in r.stdout
    assert "build/stunrun-oki.bin" not in r.stdout
    assert "build/stunrun-jsa.bin" not in r.stdout
    # the merged blobs are kept (not deleted as intermediates of the pattern rules)
    assert sorted(p.name for p in (work / "build").glob("*.bin")) == sorted(
        f"{name}.bin" for name in IMAGES
    )
    # a listing is a target: a missing one reassembles its image instead of crashing coverage
    for name in ("stunrun-obj", "stunrun-jsa"):
        (work / f"build/{name}.lst").unlink()
    r = run(*make, "coverage", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "blob: 52.3% of 1511424 bytes" in r.stdout
    assert (work / "build/stunrun-obj.lst").exists() and (work / "build/stunrun-jsa.lst").exists()
    # the object image needs nothing from the set: rebuilt with build/stunrun-obj.bin gone (and
    # its generated sources and output removed), it is still the same and the blob stays absent
    # and so does the OKI image (docs/10-adpcm.md: data/oki alone)
    for name in ("obj", "oki"):
        for suffix in (".bin", ".out", ".lst"):
            (work / f"build/stunrun-{name}{suffix}").unlink()
        shutil.rmtree(work / f"build/{name}")
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    for name in ("obj", "oki"):
        assert not (work / f"build/stunrun-{name}.bin").exists()
        assert f"stunrun-{name}.bin" not in r.stdout + r.stderr
    built = {p.name: p.read_bytes() for p in (work / "build/roms/stunrun").iterdir()}
    assert built == files
    r = run(*make, "coverage", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert not (work / "build/stunrun-obj.bin").exists()
    assert not (work / "build/stunrun-oki.bin").exists()
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
    # undo the plant, so that the WAV, mesh and operand edits below are the only differences
    data[0x7FFFF] ^= 0x01
    image.write_bytes(bytes(data))
    later = image.stat().st_mtime + 5
    os.utime(image, (later, later))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0 and "0 differences" in r.stdout, r.stdout
    check_oki_edits(work, make, env, files)
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
    # an operand edited in the 6502 source reaches 10c: reset's ldx #$FF (4002) becomes ldx #$FE,
    # one byte at 4003, and the guards still pass (nothing moved)
    mesh.write_text(text)
    later = mesh.stat().st_mtime + 20
    os.utime(mesh, (later, later))
    system = work / "asm/jsa/system.asm"
    source = system.read_text()
    first = source.index("    ldx #$FF")
    system.write_text(source[:first] + "    ldx #$FE" + source[first + len("    ldx #$FF") :])
    later = system.stat().st_mtime + 30
    os.utime(system, (later, later))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 1
    assert "1 problems over 25 files" in r.stdout, r.stdout
    assert "136070-2123.10c: 1 differing bytes, first at file offset $04003 = 6502 $4003" in (
        r.stdout
    ), r.stdout
    # the source restored in the same second as the last assembly (make 3.81 compares whole-second
    # mtimes; here the source's mtime is set equal to the image's) still reassembles: the 6502
    # tree is assembled on every make (Makefile, FORCE), so a planted-change probe cannot check
    # a stale image
    system.write_text(source)
    stamp = (work / "build/stunrun-jsa.out").stat().st_mtime
    os.utime(system, (stamp, stamp))
    r = run(*make, "all", env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    r = run(sys.executable, work / "tools/bytecheck", env=env)
    assert r.returncode == 0, r.stdout
