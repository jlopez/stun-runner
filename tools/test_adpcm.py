"""tools/adpcm (docs/10-adpcm.md): the phrase table, the verbatim ADPCM WAV, the M6295 decoder.

CI runs everything here on synthetic data (random bytes, never ROM data). With the reference set
merged (build/stunrun-oki.bin) the real image is checked against data/oki/samples.json and every
sample goes through WAV and back; with a MAME source tree and a C++ compiler the decoder is
compared with MAME's own okiadpcm.cpp, compiled into tools/adpcm/mame_oracle.cpp.
"""

from __future__ import annotations

import json
import math
import os
import random
import shutil
import struct
import subprocess
import sys
from pathlib import Path

import pytest
from adpcm import (
    DIFF,
    IMAGE_SIZE,
    FormatError,
    Layout,
    Phrase,
    adpcm_wav,
    build,
    check_image,
    chunk,
    decode,
    decode_table,
    encode,
    encode_table,
    nibbles,
    pcm_wav,
    rate,
    read_manifest,
    read_pcm_wav,
    riff,
    split,
    unwav,
)
from adpcm.__main__ import asm_source, chips, jsa_commands, read_trace, table_layout

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
MANIFEST = REPO / "data/oki/samples.json"
IMAGE = REPO / "build/stunrun-oki.bin"
MAME_SRC = Path(os.environ.get("MAME_SRC", "~/.local/src/mame")).expanduser()
OKIADPCM = MAME_SRC / "src/devices/sound/okiadpcm.cpp"


def synthetic_layout(seed: int, count: int = 9, entries: int | None = None) -> Layout:
    rng = random.Random(seed)
    entries = entries or count + 1
    phrases, start = [], entries * 8
    for n in range(1, count + 1):
        length = rng.randrange(1, 0x9000)
        phrases.append(Phrase(n, f"sample_{n:02d}", start, start + length - 1))
        start += length
    return Layout(entries, phrases)


def synthetic_samples(layout: Layout, seed: int) -> dict[int, bytes]:
    rng = random.Random(seed)
    return {p.number: rng.randbytes(p.length) for p in layout.phrases}


def run(*args: object, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [str(a) for a in args], capture_output=True, text=True, check=False, cwd=cwd
    )


# --- WAV ---------------------------------------------------------------------------------------


@pytest.mark.parametrize("length", [1, 2, 3, 255, 4096, 17497])
def test_wav_round_trip_is_exact(length: int) -> None:
    data = random.Random(length).randbytes(length)
    wav = adpcm_wav(data, "sample_01")
    assert unwav(wav) == data
    # the data chunk holds the bytes verbatim, padded to an even size as RIFF requires
    assert data in wav
    assert len(wav) % 2 == 0


def test_wav_header() -> None:
    wav = adpcm_wav(bytes(100), "x")
    assert wav[:4] == b"RIFF" and wav[8:12] == b"WAVE"
    assert struct.unpack_from("<I", wav, 4)[0] == len(wav) - 8
    fmt = wav.index(b"fmt ")
    tag, channels, hz, avg, align, bits = struct.unpack_from("<HHIIHH", wav, fmt + 8)
    assert (tag, channels, align, bits) == (0x0017, 1, 1, 4)
    assert hz == 7231 == round(3_579_545 / 3 / 165) and avg == 3616
    fact = wav.index(b"fact")
    assert struct.unpack_from("<II", wav, fact + 4) == (4, 200)
    assert b"INAM\x02\0\0\0x\0" in wav


def test_wav_cli_round_trip(tmp_path: Path) -> None:
    data = random.Random(3).randbytes(1001)
    (tmp_path / "s.bin").write_bytes(data)
    adpcm = TOOLS / "adpcm"
    r = run(sys.executable, adpcm, "wav", tmp_path / "s.bin", tmp_path / "s.wav", "--name", "s")
    assert r.returncode == 0, r.stderr
    r = run(sys.executable, adpcm, "unwav", tmp_path / "s.wav", tmp_path / "back.bin")
    assert r.returncode == 0, r.stderr
    assert (tmp_path / "back.bin").read_bytes() == data
    r = run(sys.executable, adpcm, "decode", tmp_path / "s.wav", tmp_path / "pcm.wav")
    assert r.returncode == 0, r.stderr
    assert read_pcm_wav((tmp_path / "pcm.wav").read_bytes()) == decode(data)
    (tmp_path / "bad.wav").write_bytes(b"RIFF")
    r = run(sys.executable, adpcm, "unwav", tmp_path / "bad.wav", tmp_path / "x.bin")
    assert r.returncode == 1 and "not a RIFF WAVE" in r.stderr


def fmt_body(tag: int = 0x17, channels: int = 1, align: int = 1, bits: int = 4) -> bytes:
    return struct.pack("<HHIIHHH", tag, channels, 7231, 3616, align, bits, 0)


@pytest.mark.parametrize(
    ("blob", "message"),
    [
        (b"RIFX" + bytes(8), "not a RIFF WAVE"),
        (riff([chunk(b"fmt ", fmt_body(tag=1)), chunk(b"data", b"ab")]), "format tag 0x0001"),
        (riff([chunk(b"fmt ", fmt_body(tag=0x10)), chunk(b"data", b"ab")]), "format tag 0x0010"),
        (riff([chunk(b"fmt ", fmt_body(channels=2)), chunk(b"data", b"ab")]), "2 channels"),
        (riff([chunk(b"fmt ", fmt_body(bits=8)), chunk(b"data", b"ab")]), "8 bits"),
        (riff([chunk(b"fmt ", fmt_body(align=2)), chunk(b"data", b"ab")]), "block align 2"),
        (riff([chunk(b"fmt ", fmt_body())]), "0 'data' chunks"),
        (riff([chunk(b"data", b"ab")]), "0 'fmt' chunks"),
        (
            riff([chunk(b"fmt ", fmt_body()), chunk(b"data", b"ab"), chunk(b"data", b"cd")]),
            "2 'data' chunks",
        ),
        (riff([chunk(b"fmt ", fmt_body()[:14]), chunk(b"data", b"ab")]), "shorter than 16"),
        (
            riff([chunk(b"fmt ", fmt_body()), chunk(b"fact", struct.pack("<I", 3)),
                  chunk(b"data", b"ab")]),
            "fact chunk",
        ),
        (adpcm_wav(b"abcd")[:-2], "RIFF size"),
    ],
)
def test_malformed_wav_rejected(blob: bytes, message: str) -> None:
    with pytest.raises(FormatError, match=message):
        unwav(blob)


def test_truncated_chunk_rejected() -> None:
    good = adpcm_wav(b"abcdef")
    # a data chunk that claims more bytes than the RIFF body holds
    bad = bytearray(good)
    i = bad.index(b"data")
    struct.pack_into("<I", bad, i + 4, 1000)
    with pytest.raises(FormatError, match="runs past"):
        unwav(bytes(bad))


def test_foreign_chunks_are_skipped() -> None:
    data = b"\x12\x34\x56"
    wav = riff([chunk(b"JUNK", b"x" * 7), chunk(b"fmt ", fmt_body()), chunk(b"cue ", b"1234"),
                chunk(b"data", data)])
    assert unwav(wav) == data


# --- the phrase table --------------------------------------------------------------------------


def test_table_encoder_and_decoder_on_a_synthetic_image() -> None:
    layout = synthetic_layout(1)
    samples = synthetic_samples(layout, 2)
    image = build(layout, samples)
    assert len(image) == IMAGE_SIZE
    table = encode_table(layout)
    assert len(table) == layout.entries * 8 and table[:8] == bytes(8)
    assert image[: len(table)] == table
    assert all(table[8 * n + 6 : 8 * n + 8] == b"\0\0" for n in range(layout.entries))
    assert decode_table(image, layout.entries) == [(p.start, p.end) for p in layout.phrases]
    check_image(image, layout)
    assert split(image, layout) == samples
    assert build(layout, split(image, layout)) == image
    entries, spans = table_layout(image)
    assert entries == layout.entries and spans == [(p.start, p.end) for p in layout.phrases]
    assert not any(image[layout.tail :])


def test_check_image_rejects_what_the_manifest_does_not_describe() -> None:
    layout = synthetic_layout(4)
    image = bytearray(build(layout, synthetic_samples(layout, 5)))
    bad = bytearray(image)
    bad[8 * 3 + 5] ^= 1  # phrase 3's end
    with pytest.raises(FormatError, match="phrase table entry 3"):
        check_image(bytes(bad), layout)
    bad = bytearray(image)
    bad[3] = 1  # entry 0
    with pytest.raises(FormatError, match="phrase table entry 0"):
        check_image(bytes(bad), layout)
    bad = bytearray(image)
    bad[8 * 2 + 7] = 1  # the unused bytes of entry 2
    with pytest.raises(FormatError, match="phrase table entry 2"):
        check_image(bytes(bad), layout)
    bad = bytearray(image)
    bad[-1] = 1
    with pytest.raises(FormatError, match="1 nonzero bytes after the last sample"):
        check_image(bytes(bad), layout)
    with pytest.raises(FormatError, match="not 262144"):
        check_image(bytes(image[:-1]), layout)
    samples = synthetic_samples(layout, 5)
    samples[2] = samples[2][:-1]
    with pytest.raises(FormatError, match="phrase 2"):
        build(layout, samples)


def test_table_layout_finds_the_table_length() -> None:
    # a table with unused entries after the last phrase: phrase 1 starts after entry 11
    layout = synthetic_layout(6, count=5, entries=6)
    image = bytearray(build(layout, synthetic_samples(layout, 7)))
    assert table_layout(bytes(image))[0] == 6
    image[8 * 2 + 2] ^= 0x10  # phrase 2 no longer follows phrase 1
    with pytest.raises(FormatError, match="phrase 2"):
        table_layout(bytes(image))


def write_manifest(path: Path, layout: Layout, **change: object) -> None:
    phrases = [
        {"number": p.number, "name": p.name, "start": f"{p.start:05X}", "end": f"{p.end:05X}",
         "length": p.length}
        for p in layout.phrases
    ]
    doc = {"format": "stunrun-oki 1", "table_entries": layout.entries, "phrases": phrases}
    for key, value in change.items():
        number, field = key.split("__")
        phrases[int(number[1:]) - 1][field] = value
    path.write_text(json.dumps(doc))


def test_manifest_reader(tmp_path: Path) -> None:
    layout = synthetic_layout(8, count=4)
    path = tmp_path / "m.json"
    write_manifest(path, layout)
    assert read_manifest(path) == layout
    cases = {
        "p2__start": ("00000", "starts at 00000"),
        "p3__number": (7, "numbered 1, 2"),
        "p1__name": ("1abc", "not a unique label"),
        "p2__name": ("sample_01", "not a unique label"),
        "p4__length": (1, "length is not end - start"),
        "p4__end": ("40000", "outside"),
    }
    for key, (value, message) in cases.items():
        write_manifest(path, layout, **{key: value})
        with pytest.raises(FormatError, match=message):
            read_manifest(path)


def test_committed_manifest() -> None:
    layout = read_manifest(MANIFEST)
    assert layout.entries == 53 and len(layout.phrases) == 52
    assert layout.table_end == 0x1A8 and layout.phrases[0].start == 0x1A8
    assert layout.tail == 0x3FCA8
    doc = json.loads(MANIFEST.read_text())
    for p in doc["phrases"]:
        # every phrase is played by some command (the 6502's tables) and MAME saw it start
        assert p["commands"], p["number"]
        assert sum(p["starts"].values()) > 0, p["number"]
        assert p["seconds"] == round(2 * p["length"] / rate(), 3)


# --- the generated include -----------------------------------------------------------------------


def test_asm_source_cuts_at_chip_boundaries(tmp_path: Path) -> None:
    layout = read_manifest(MANIFEST)
    samples = synthetic_samples(layout, 9)
    for p in layout.phrases:
        (tmp_path / f"{p.stem}.wav").write_bytes(adpcm_wav(samples[p.number], p.name))
    text, recovered = asm_source(layout, tmp_path, "../../build/oki/bin")
    assert recovered == samples
    assert "oki_phrases\tequ\t52" in text
    for address, name in chips()[1:]:
        assert f'\tassert\t*=${address:05X},"{name} misplaced"' in text
    assert text.count("\tincbin\t") == 52 + 3
    assert '\tincbin\t"../../build/oki/bin/11.bin",0,$358' in text
    assert '\tincbin\t"../../build/oki/bin/11.bin",$358' in text
    assert text.rstrip().endswith("\tdcb.b\t$358,0")
    # a WAV of another length, a missing WAV and a broken WAV fail
    p = layout.phrases[4]
    (tmp_path / f"{p.stem}.wav").write_bytes(adpcm_wav(samples[p.number] + b"\0"))
    with pytest.raises(FormatError, match="the manifest's addresses"):
        asm_source(layout, tmp_path, "bin")
    (tmp_path / f"{p.stem}.wav").write_bytes(b"RIFF")
    with pytest.raises(FormatError, match="not a RIFF WAVE"):
        asm_source(layout, tmp_path, "bin")
    (tmp_path / f"{p.stem}.wav").unlink()
    with pytest.raises(FormatError, match="absent"):
        asm_source(layout, tmp_path, "bin")


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


@pytest.mark.skipif(vasm() is None, reason="vasm not available")
def test_tree_assembles_a_synthetic_image(tmp_path: Path) -> None:
    """asm/oki/samples.asm + the generated include rebuild the image tools/adpcm builds."""
    layout = read_manifest(MANIFEST)
    samples = synthetic_samples(layout, 10)
    wavs = tmp_path / "wav"
    wavs.mkdir()
    for p in layout.phrases:
        (wavs / f"{p.stem}.wav").write_bytes(adpcm_wav(samples[p.number], p.name))
    shutil.copytree(REPO / "asm/oki", tmp_path / "asm/oki")
    out = tmp_path / "build/oki"
    r = run(sys.executable, TOOLS / "adpcm", "asm", "--manifest", MANIFEST, "--wav", wavs,
            "--out", out)
    assert r.returncode == 0, r.stderr
    r = run(vasm(), "-quiet", "-Fbin", "-no-opt", "-m68010", "-o", tmp_path / "oki.out",
            "asm/oki/samples.asm", cwd=tmp_path)
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / "oki.out").read_bytes() == build(layout, samples)


# --- the decoder -------------------------------------------------------------------------------

# The 49 step sizes of Dialogic (VOX) ADPCM, the coding the M6295 uses, written out by hand: an
# independent statement of what okiadpcm.cpp computes as floor(16 * 1.1 ** step).
DIALOGIC_STEPS = [
    16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130,
    143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552,
]


def test_diff_table_by_hand() -> None:
    for step, s in enumerate(DIALOGIC_STEPS):
        # nibble 0: s/8; nibble 7: s + s/2 + s/4 + s/8; bit 3 negates
        assert DIFF[step * 16 + 0] == s // 8
        assert DIFF[step * 16 + 7] == s + s // 2 + s // 4 + s // 8
        assert DIFF[step * 16 + 8] == -(s // 8)
        assert DIFF[step * 16 + 5] == s + s // 4 + s // 8
        assert DIFF[step * 16 + 15] == -DIFF[step * 16 + 7]


def test_decoder_by_hand() -> None:
    # 0x77: nibble 7 at step 0 adds 16+8+4+2 = 30, step 0 -> 8 (34): adds 34+17+8+4 = 63
    assert decode(b"\x77") == [30, 93]
    # 0x88: nibble 8 at step 0 subtracts 2, the step stays at 0 (clamped from -1)
    assert decode(b"\x88") == [-2, -4]
    # high nibble first: 0x70 is +30 then (step 8) nibble 0 adds 34/8 = 4, step back to 7
    assert decode(b"\x70\x00") == [30, 34, 37, 40]  # steps 8, 7 (31/8=3), 6 (28/8=3)
    # the signal clamps at 2047 and -2048, the step at 48
    out = decode(b"\x77" * 40)
    assert max(out) == 2047 and out[-1] == 2047
    out = decode(b"\xff" * 40)
    assert min(out) == -2048 and out[-1] == -2048
    assert nibbles(b"\xa5") == [0xA, 0x5]


def test_pcm_wav() -> None:
    samples = decode(random.Random(11).randbytes(500))
    wav = pcm_wav(samples)
    assert read_pcm_wav(wav) == samples
    fmt = wav.index(b"fmt ")
    assert struct.unpack_from("<HHIIHH", wav, fmt + 8) == (1, 1, 7231, 14462, 2, 16)


def test_encoder() -> None:
    # a quiet tone never clamps: the encoder's output decodes to the nearest reachable
    # signal, and re-encoding what it decodes gives the same bytes
    tone = [round(400 * math.sin(i / 7)) for i in range(2000)]
    data = encode(tone)
    pcm = decode(data)
    assert max(abs(a - b) for a, b in zip(pcm, tone, strict=True)) < 60
    assert encode(pcm) == data


def compile_oracle(tmp_path: Path) -> Path | None:
    cxx = shutil.which(os.environ.get("CXX", "c++"))
    if cxx is None or not OKIADPCM.exists():
        return None
    (tmp_path / "emu.h").write_text("#include <cstdint>\n#include <cmath>\n")
    exe = tmp_path / "oracle"
    r = run(cxx, "-std=c++17", "-O1", f"-I{tmp_path}", f"-I{OKIADPCM.parent}",
            TOOLS / "adpcm/mame_oracle.cpp", OKIADPCM, "-o", exe)
    assert r.returncode == 0, r.stderr
    return exe


def mame_decode(exe: Path, data: bytes) -> list[int]:
    out = subprocess.run([exe], input=data, capture_output=True, check=True).stdout
    return list(struct.unpack(f"<{len(out) // 2}h", out))


@pytest.mark.skipif(
    not OKIADPCM.exists() or shutil.which(os.environ.get("CXX", "c++")) is None,
    reason="no MAME source tree (MAME_SRC) or no C++ compiler",
)
def test_decoder_equals_mame(tmp_path: Path) -> None:
    exe = compile_oracle(tmp_path)
    assert exe is not None
    rng = random.Random(12)
    for length in (1, 7, 5000):
        data = rng.randbytes(length)
        assert decode(data) == mame_decode(exe, data)
    if IMAGE.exists():
        layout = read_manifest(MANIFEST)
        for number, data in split(IMAGE.read_bytes(), layout).items():
            assert decode(data) == mame_decode(exe, data), f"phrase {number}"


# --- the 6502's tables and the MAME traces ------------------------------------------------------


def test_jsa_commands_on_synthetic_tables() -> None:
    jsa = bytearray(0x10000)
    jsa[0x6100 + 0x40] = 0x13  # command 40: play effect 3
    jsa[0x616D + 0x40] = 3
    jsa[0x6532 + 3] = 17
    jsa[0x6100 + 0x41] = 0x14  # command 41: a stop, not a play
    jsa[0x616D + 0x41] = 3
    jsa[0x6100 + 0x6D] = 0x13  # beyond the dispatcher's CPY #$6D
    out = jsa_commands(bytes(jsa))
    # every other command has type 0 here, which is not the play handler
    assert out == {17: [0x40]}


def test_read_trace(tmp_path: Path) -> None:
    path = tmp_path / "okitrace-game.txt"
    path.write_text(
        "# frames 10\n"
        "start 39 8 1 5C53 67 2F 311 3394\n"
        "start 39 8 1 5C53 1E -- 1 8574\n"
        "start 5 1 0 5C53 3C 05 2 1532\n"
        "stop 8 5C26 391\nwrio 05 3\ndispatch 67 3\n"
    )
    assert read_trace(path) == {39: {"67": 311, "1E": 1}, 5: {"3C": 2}}


# --- the reference set (skipped in CI) ----------------------------------------------------------


@pytest.mark.skipif(not IMAGE.exists(), reason="build/stunrun-oki.bin absent (no reference set)")
def test_reference_image_round_trips_through_wav() -> None:
    layout = read_manifest(MANIFEST)
    image = IMAGE.read_bytes()
    samples = split(image, layout)
    assert len(samples) == 52
    back = {n: unwav(adpcm_wav(data, f"sample_{n:02d}")) for n, data in samples.items()}
    assert back == samples
    assert build(layout, back) == image
    entries, spans = table_layout(image)
    assert entries == layout.entries and spans == [(p.start, p.end) for p in layout.phrases]


def test_no_audio_or_sample_bytes_committed() -> None:
    r = run("git", "-C", REPO, "ls-files")
    if r.returncode != 0:
        pytest.skip("not a git checkout")
    banned = (".wav", ".raw", ".pcm", ".vox", ".adpcm", ".aiff", ".flac", ".mp3", ".ogg")
    found = [f for f in r.stdout.splitlines() if f.lower().endswith(banned)]
    assert found == []
    assert [f for f in r.stdout.splitlines() if f.startswith("data/oki/")] in (
        [],
        ["data/oki/samples.json"],
    )
