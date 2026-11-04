"""The GSP and ADSP programs: the extractor on synthetic images, and the oracle comparison.

The synthetic tests run everywhere (CI): a valid program table, record stream and section table
with random contents, laid out at the real boundaries, never ROM data. The oracle tests compare
the extracted images (`make`: build/adsp/pm.bin, build/gsp/vram.bin) with MAME's memory after
boot (`make oracle`: build/mame/) and skip when either is absent (CI has neither ROMs nor MAME).
"""

from __future__ import annotations

import json
import random
import struct
import subprocess
import sys
from pathlib import Path

import pytest
from programs import (
    ADSP_START,
    GSP_END,
    GSP_RUNTIME_WORDS,
    GSP_START,
    GSP_VRAM_BASE,
    PROGRAM_TABLE,
    FormatError,
    adsp_pm_image,
    bit_range_to_bytes,
    diff_pm,
    diff_vram,
    gsp_vram_image,
    locate,
    parse_adsp,
    parse_gsp,
    read_ranges,
)

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
BUILD = REPO / "build"
MAME_DUMPS = BUILD / "mame"

# Synthetic geometry that fills the real boundaries exactly: two ADSP records,
# 5 + 3*2000 + 5 + 3*753 + 1 = 0x204E bytes; two GSP sections, 4 + 8 + 23808 + 8 + 580 = 0x5F58
# bytes, the second with a 16-bit remainder (0x02FE4A).
SYNTH_ADSP = [(0x0000, 2000), (0x1000, 753)]
SYNTH_GSP = [(0xFFF40000, 23808 * 8), (0xFFF80000, 144 * 32 + 16)]


def synthetic_programs(rng: random.Random) -> tuple[bytes, dict[int, int], dict[int, int]]:
    """The bytes of 0x017000-0x01EFD4 for a valid layout, and the expected program RAM words
    and VRAM words (bit address -> value)."""
    out = bytearray(struct.pack(">II", ADSP_START, GSP_START))
    out += rng.randbytes(ADSP_START - PROGRAM_TABLE - 8)
    pm: dict[int, int] = {}
    for address, count in SYNTH_ADSP:
        out += struct.pack(">BHH", 0, address, count)
        for i in range(count):
            pm[address + i] = rng.getrandbits(24)
            out += pm[address + i].to_bytes(3, "big")
    out.append(0xFF)
    assert PROGRAM_TABLE + len(out) == GSP_START
    out += struct.pack(">I", len(SYNTH_GSP))
    vram: dict[int, int] = {}
    for address, bits in SYNTH_GSP:
        out += struct.pack(">II", address, bits)
        for i in range((bits + 31) // 32):
            value = rng.getrandbits(32)
            out += struct.pack(">I", value)
            vram[address + 32 * i] = value & 0xFFFF
            if 32 * i + 16 < bits:
                vram[address + 32 * i + 16] = value >> 16
    assert PROGRAM_TABLE + len(out) == GSP_END
    return bytes(out), pm, vram


def plant_programs(image: bytes, seed: int = 0) -> bytes:
    """A 68k image with synthetic programs at 0x017000-0x01EFD4 (for the synthetic `make`)."""
    block, _, _ = synthetic_programs(random.Random(seed))
    return image[:PROGRAM_TABLE] + block + image[GSP_END:]


def synthetic_image(seed: int = 5) -> tuple[bytes, dict[int, int], dict[int, int]]:
    rng = random.Random(seed)
    block, pm, vram = synthetic_programs(rng)
    image = rng.randbytes(PROGRAM_TABLE) + block + rng.randbytes(0xC0000 - GSP_END)
    return image, pm, vram


def test_locate_and_unpack_synthetic() -> None:
    image, pm_words, vram_words = synthetic_image()
    progs = locate(image)
    assert progs.adsp_range == (ADSP_START, GSP_START)
    assert progs.gsp_range == (GSP_START, GSP_END)
    pm, pm_ranges = adsp_pm_image(progs.adsp)
    assert pm_ranges == [(0, 2000), (0x1000, 0x1000 + 753)]
    words = struct.unpack("<8192I", pm)
    assert all(words[a] == v for a, v in pm_words.items())
    assert sum(1 for w in words if w) <= len(pm_words)
    vram, vram_ranges = gsp_vram_image(progs.gsp)
    assert vram_ranges == [(a, a + b) for a, b in SYNTH_GSP]
    for bit, value in vram_words.items():
        b = (bit - GSP_VRAM_BASE) // 8
        assert struct.unpack_from("<H", vram, b)[0] == value
    # the 16-bit remainder writes the low word of the padding long and nothing after it
    end = bit_range_to_bytes(*vram_ranges[1])[1]
    assert vram[end : end + 2] == b"\0\0"


def test_gsp_word_order_low_first() -> None:
    table = struct.pack(">IIII", 1, 0xFFF40000, 48, 0x11112222) + struct.pack(">I", 0x33334444)
    sections, end = parse_gsp(table, 0)
    assert end == len(table)
    assert sections[0].words == (0x2222, 0x1111, 0x4444)


def test_adsp_stream_end_and_errors() -> None:
    stream = bytes([0, 0x00, 0x04, 0x00, 0x01, 0xAB, 0xCD, 0xEF, 0x01])
    records, end = parse_adsp(stream, 0)
    assert end == len(stream) and records[0].address == 4 and records[0].words == (0xABCDEF,)
    with pytest.raises(FormatError, match="beyond program RAM"):
        parse_adsp(bytes([0, 0x1F, 0xFF, 0x00, 0x02]) + bytes(7), 0)
    with pytest.raises(FormatError, match="runs past"):
        parse_adsp(bytes([0, 0, 0, 0, 2, 1, 2, 3]), 0)


def test_gsp_bad_remainder_is_rejected() -> None:
    with pytest.raises(FormatError, match="remainder"):
        parse_gsp(struct.pack(">III", 1, 0xFFF40000, 40) + bytes(8), 0)


def test_locate_checks_the_boundaries() -> None:
    image, _, _ = synthetic_image()
    bad = bytearray(image)
    struct.pack_into(">I", bad, PROGRAM_TABLE + 4, GSP_START + 2)
    with pytest.raises(FormatError, match="points to"):
        locate(bytes(bad))
    bad = bytearray(image)
    bad[GSP_START - 1] = 0  # the terminator becomes a record flag
    with pytest.raises(FormatError):
        locate(bytes(bad))


def test_extract_programs_cli(tmp_path: Path) -> None:
    image, _, _ = synthetic_image(9)
    (tmp_path / "img.bin").write_bytes(image)
    r = subprocess.run(
        [sys.executable, str(TOOLS / "extract-programs"), "--image", str(tmp_path / "img.bin")]
        + ["--out", str(tmp_path)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / "adsp/program.bin").read_bytes() == image[ADSP_START:GSP_START]
    assert (tmp_path / "gsp/program.bin").read_bytes() == image[GSP_START:GSP_END]
    ranges = read_ranges(json.loads((tmp_path / "gsp/vram.ranges.json").read_text()))
    assert ranges == [(a, a + b) for a, b in SYNTH_GSP]
    assert len((tmp_path / "adsp/pm.bin").read_bytes()) == 0x8000
    assert len((tmp_path / "gsp/vram.bin").read_bytes()) == 0x100000


def test_diffs_find_planted_differences() -> None:
    image, _, _ = synthetic_image()
    progs = locate(image)
    pm, pm_ranges = adsp_pm_image(progs.adsp)
    vram, vram_ranges = gsp_vram_image(progs.gsp)
    assert diff_pm(pm, pm, pm_ranges) == []
    planted = bytearray(pm)
    planted[4 * 0x1005 + 1] ^= 0x10
    planted[4 * 0x1FFF] ^= 0x10  # not loaded: ignored
    assert diff_pm(pm, bytes(planted), pm_ranges) == [0x1005]
    planted = bytearray(vram)
    b = bit_range_to_bytes(0xFFF40100, 0xFFF40110)[0]
    planted[b] ^= 1
    excluded = bit_range_to_bytes(0xFFF80020, 0xFFF80030)[0]
    planted[excluded + 1] ^= 1
    assert diff_vram(vram, bytes(planted), vram_ranges) == [0xFFF40100, 0xFFF80020]
    assert diff_vram(vram, bytes(planted), vram_ranges, [0xFFF80020]) == [0xFFF40100]


# --- the oracle: MAME's memory after boot (make oracle) ----------------------------------------


def _need(*paths: Path) -> None:
    missing = [str(p) for p in paths if not p.exists()]
    if missing:
        pytest.skip("no " + ", ".join(missing) + " (make and make oracle need the ROMs and MAME)")


def test_adsp_program_ram_equals_mame() -> None:
    pm_path, ranges_path = BUILD / "adsp/pm.bin", BUILD / "adsp/pm.ranges.json"
    dump_path = MAME_DUMPS / "adsp_pm.bin"
    _need(pm_path, ranges_path, dump_path)
    ranges = read_ranges(json.loads(ranges_path.read_text()))
    differing = diff_pm(pm_path.read_bytes(), dump_path.read_bytes(), ranges)
    loaded = sum(e - s for s, e in ranges)
    assert differing == [], f"{len(differing)} of {loaded} loaded words differ: " + ", ".join(
        f"{w:04X}" for w in differing[:16]
    )


def test_gsp_vram_equals_mame() -> None:
    vram_path, ranges_path = BUILD / "gsp/vram.bin", BUILD / "gsp/vram.ranges.json"
    dump_path = MAME_DUMPS / "gsp_vram.bin"
    _need(vram_path, ranges_path, dump_path)
    ranges = read_ranges(json.loads(ranges_path.read_text()))
    exclude = [bit for bit, _ in GSP_RUNTIME_WORDS]
    differing = diff_vram(vram_path.read_bytes(), dump_path.read_bytes(), ranges, exclude)
    assert differing == [], f"{len(differing)} loaded words differ: " + ", ".join(
        f"{a:08X}" for a in differing[:16]
    )


# --- the sidecars and tools/annotate-listing ----------------------------------------------------

LISTING = """; header
0000: 000a001f  RTI
0004: 001c780f  CALL $0780
0005: 00340008  L0 = $0000
"""


def _annotate(tmp_path: Path, entries: list[dict[str, str]]) -> subprocess.CompletedProcess[str]:
    (tmp_path / "s.json").write_text(json.dumps({"program": "t", "entries": entries}))
    (tmp_path / "p.lst").write_text(LISTING)
    return subprocess.run(
        [sys.executable, str(TOOLS / "annotate-listing")]
        + [str(tmp_path / n) for n in ("s.json", "p.lst", "out.lst")],
        capture_output=True,
        text=True,
        check=False,
    )


def test_annotate_listing(tmp_path: Path) -> None:
    r = _annotate(
        tmp_path,
        [{"addr": "0004", "name": "reset", "comment": "entry"}, {"addr": "5", "comment": "c"}],
    )
    assert r.returncode == 0, r.stdout + r.stderr
    out = (tmp_path / "out.lst").read_text().splitlines()
    i = out.index("reset:")
    assert out[i - 1] == "; entry" and out[i + 1].startswith("0004: ")
    assert out[i + 2].startswith("0005: ") and out[i + 2].endswith("; c")
    r = _annotate(tmp_path, [{"addr": "0003", "name": "nowhere"}])
    assert r.returncode == 1 and "3" in r.stdout


@pytest.mark.parametrize("program", ["adsp", "gsp"])
def test_committed_sidecars(program: str) -> None:
    doc = json.loads((REPO / "data" / program / "annotations.json").read_text())
    addrs = [int(e["addr"], 16) for e in doc["entries"]]
    assert addrs == sorted(set(addrs))
    assert all(e.get("name") or e.get("comment") for e in doc["entries"])
    listing = BUILD / program / "program.lst"
    if not listing.exists():
        pytest.skip(f"no {listing} (make dasm)")
    starts = {int(line.split(":")[0], 16) for line in listing.read_text().splitlines()
              if line[:1].isalnum() and ":" in line}
    assert set(addrs) <= starts
