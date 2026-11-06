"""tools/adpcm (docs/10-adpcm.md): the phrase table, the PCM WAV, the M6295 decoder, the encoder.

CI runs everything here without the ROMs: synthetic data (random bytes) for the formats, and the
committed data/oki (the manifest and the 52 PCM WAVs, the OKI image's source) encoded into the
four OKI chips, checked against the CRC-32 and SHA-1 MAME lists. With the reference set merged
(build/stunrun-oki.bin) every committed WAV must be exactly what the image decodes to; with a
MAME source tree and a C++ compiler the decoder is compared with MAME's own okiadpcm.cpp,
compiled into tools/adpcm/mame_oracle.cpp.
"""

from __future__ import annotations

import itertools
import json
import math
import os
import random
import shutil
import struct
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

import pytest
from adpcm import (
    DIFF,
    IMAGE_SIZE,
    ROWS,
    SCALE,
    Entry,
    FormatError,
    Layout,
    Manifest,
    build,
    check_image,
    chunk,
    decode,
    decode_nibbles,
    decode_table,
    encode,
    encode_nibbles,
    encode_table,
    layout,
    nibbles,
    pcm,
    pcm_wav,
    read_manifest,
    read_wav,
    riff,
    round_trip,
    split,
    step,
    table_layout,
)
from adpcm.__main__ import (
    asm_source,
    chip_label,
    chips,
    encode_all,
    jsa_commands,
    read_trace,
)
from romset import DEFAULT_ARCHIVE, hashes, load_snapshot, merge, read_set

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
DATA = REPO / "data/oki"
MANIFEST = DATA / "samples.json"
COMMANDS = REPO / "data/sound/commands.json"
SET = "stunrun"
MAME_SRC = Path(os.environ.get("MAME_SRC", "~/.local/src/mame")).expanduser()
OKIADPCM = MAME_SRC / "src/devices/sound/okiadpcm.cpp"

# The reference layout (docs/10 section 3): the samples end at 3FCA7, three of them across a ROM
# file boundary.
REFERENCE_TAIL = 0x3FCA8


def synthetic_layout(seed: int, count: int = 9, entries: int | None = None) -> Layout:
    rng = random.Random(seed)
    entries = entries or count + 1
    manifest = Manifest(entries, [entry(n) for n in range(1, count + 1)])
    return layout(manifest, {n: rng.randrange(2, 0x6000) for n in range(1, count + 1)})


def entry(n: int) -> Entry:
    return Entry(n, f"sample_{n:02d}")


def synthetic_samples(lay: Layout, seed: int) -> dict[int, bytes]:
    rng = random.Random(seed)
    return {p.number: rng.randbytes(p.length) for p in lay.phrases}


def run(*args: object, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [str(a) for a in args], capture_output=True, text=True, check=False, cwd=cwd
    )


# --- WAV ---------------------------------------------------------------------------------------


@pytest.mark.parametrize("length", [1, 2, 3, 255, 4096, 17497])
def test_wav_round_trip_is_exact(length: int) -> None:
    rng = random.Random(length)
    values = [rng.randrange(-32768, 32768) for _ in range(length)]
    wav = pcm_wav(values)
    assert read_wav(wav) == values
    assert len(wav) == 44 + 2 * length + (length * 2 & 1)


def test_wav_header() -> None:
    wav = pcm_wav([0] * 100)
    assert wav[:4] == b"RIFF" and wav[8:12] == b"WAVE"
    assert struct.unpack_from("<I", wav, 4)[0] == len(wav) - 8
    assert wav[12:16] == b"fmt " and struct.unpack_from("<I", wav, 16)[0] == 16
    tag, channels, hz, avg, align, bits = struct.unpack_from("<HHIIHH", wav, 20)
    assert (tag, channels, align, bits) == (1, 1, 2, 16)
    assert hz == 7231 == round(3_579_545 / 3 / 165) and avg == 2 * 7231
    assert wav[36:40] == b"data" and struct.unpack_from("<I", wav, 40)[0] == 200
    assert len(wav) == 244


def fmt_body(tag: int = 1, channels: int = 1, hz: int = 7231, align: int = 2,
             bits: int = 16) -> bytes:
    return struct.pack("<HHIIHH", tag, channels, hz, hz * align, align, bits)


def extensible(subformat: bytes) -> bytes:
    return fmt_body(tag=0xFFFE) + struct.pack("<HHI", 22, 16, 4) + subformat


PCM_GUID = bytes.fromhex("0100000000001000800000aa00389b71")


@pytest.mark.parametrize(
    ("blob", "message"),
    [
        (b"RIFX" + bytes(8), "not a RIFF WAVE"),
        (riff([chunk(b"fmt ", fmt_body(tag=0x17)), chunk(b"data", b"ab")]), "format tag 0x0017"),
        (riff([chunk(b"fmt ", fmt_body(tag=3)), chunk(b"data", b"ab")]), "format tag 0x0003"),
        (riff([chunk(b"fmt ", fmt_body(channels=2, align=4)), chunk(b"data", b"abcd")]),
         "2 channels"),
        (riff([chunk(b"fmt ", fmt_body(bits=8, align=1)), chunk(b"data", b"ab")]), "8 bits"),
        (riff([chunk(b"fmt ", fmt_body(hz=44100)), chunk(b"data", b"ab")]), "resample"),
        (riff([chunk(b"fmt ", fmt_body())]), "0 'data' chunks"),
        (riff([chunk(b"data", b"ab")]), "0 'fmt' chunks"),
        (riff([chunk(b"fmt ", fmt_body()), chunk(b"data", b"ab"), chunk(b"data", b"cd")]),
         "2 'data' chunks"),
        (riff([chunk(b"fmt ", fmt_body()[:14]), chunk(b"data", b"ab")]), "shorter than 16"),
        (riff([chunk(b"fmt ", fmt_body()), chunk(b"data", b"abc")]), "not whole 16-bit"),
        (riff([chunk(b"fmt ", fmt_body()), chunk(b"data", b"")]), "no samples"),
        (riff([chunk(b"fmt ", extensible(bytes(16))), chunk(b"data", b"ab")]), "sub-format"),
        (pcm_wav([1, 2])[:-2], "RIFF size"),
    ],
)
def test_malformed_wav_rejected(blob: bytes, message: str) -> None:
    with pytest.raises(FormatError, match=message):
        read_wav(blob)


def test_editor_wavs_are_read() -> None:
    """What an editor may write: the extensible header with the PCM sub-format, chunks the
    reader does not know (LIST, cue), any 16-bit value, on the decoder's grid or not."""
    values = [32767, -32768, 1, -1, 15, 17]
    data = struct.pack("<6h", *values)
    wav = riff([chunk(b"JUNK", b"x" * 7), chunk(b"fmt ", extensible(PCM_GUID)),
                chunk(b"LIST", b"INFOINAM\x02\0\0\0x\0"), chunk(b"data", data)])
    assert read_wav(wav) == values


def test_truncated_chunk_rejected() -> None:
    bad = bytearray(pcm_wav([1, 2, 3]))
    struct.pack_into("<I", bad, 40, 1000)  # a data chunk that claims more than the file holds
    with pytest.raises(FormatError, match="runs past"):
        read_wav(bytes(bad))


# --- the layout and the phrase table -----------------------------------------------------------


def test_layout_from_lengths() -> None:
    manifest = Manifest(4, [Entry(1, "a"), Entry(2, "b"), Entry(3, "c")])
    lay = layout(manifest, {1: 5, 2: 2, 3: 0x100})
    assert [(p.start, p.end) for p in lay.phrases] == [(0x20, 0x24), (0x25, 0x26), (0x27, 0x126)]
    assert lay.tail == 0x127
    # exactly full is allowed, one byte more is not, with how much too much
    full = layout(manifest, {1: 5, 2: 2, 3: IMAGE_SIZE - 0x27})
    assert full.tail == IMAGE_SIZE
    with pytest.raises(FormatError, match="1 bytes more than the 256 KB image holds"):
        layout(manifest, {1: 5, 2: 2, 3: IMAGE_SIZE - 0x26})
    with pytest.raises(FormatError, match="an empty sample"):
        layout(manifest, {1: 5, 2: 0, 3: 2})
    # a 1-byte sample (a WAV of 1 or 2 values) has start == end: okim6295.cpp:266 never plays it
    with pytest.raises(FormatError, match="phrase 2: a sample of 1 byte would never play"):
        layout(manifest, {1: 5, 2: 1, 3: 2})


def test_table_encoder_and_decoder_on_a_synthetic_image() -> None:
    lay = synthetic_layout(1)
    samples = synthetic_samples(lay, 2)
    image = build(lay, samples)
    assert len(image) == IMAGE_SIZE
    table = encode_table(lay)
    assert len(table) == lay.entries * 8 and table[:8] == bytes(8)
    assert image[: len(table)] == table
    assert all(table[8 * n + 6 : 8 * n + 8] == b"\0\0" for n in range(lay.entries))
    assert decode_table(image, lay.entries) == [(p.start, p.end) for p in lay.phrases]
    check_image(image, lay)
    assert split(image, lay) == samples
    assert build(lay, split(image, lay)) == image
    entries, spans = table_layout(image)
    assert entries == lay.entries and spans == [(p.start, p.end) for p in lay.phrases]
    assert not any(image[lay.tail :])


def test_check_image_rejects_what_the_layout_does_not_describe() -> None:
    lay = synthetic_layout(4)
    image = bytearray(build(lay, synthetic_samples(lay, 5)))
    bad = bytearray(image)
    bad[8 * 3 + 5] ^= 1  # phrase 3's end
    with pytest.raises(FormatError, match="phrase table entry 3"):
        check_image(bytes(bad), lay)
    bad = bytearray(image)
    bad[3] = 1  # entry 0
    with pytest.raises(FormatError, match="phrase table entry 0"):
        check_image(bytes(bad), lay)
    bad = bytearray(image)
    bad[8 * 2 + 7] = 1  # the unused bytes of entry 2
    with pytest.raises(FormatError, match="phrase table entry 2"):
        check_image(bytes(bad), lay)
    bad = bytearray(image)
    bad[-1] = 1
    with pytest.raises(FormatError, match="1 nonzero bytes after the last sample"):
        check_image(bytes(bad), lay)
    with pytest.raises(FormatError, match="not 262144"):
        check_image(bytes(image[:-1]), lay)
    samples = synthetic_samples(lay, 5)
    samples[2] = samples[2][:-1]
    with pytest.raises(FormatError, match="phrase 2"):
        build(lay, samples)


def test_table_layout_finds_the_table_length() -> None:
    # five phrases: phrase 1 starts after entry 5, so the table has 6 entries
    lay = synthetic_layout(6, count=5)
    image = bytearray(build(lay, synthetic_samples(lay, 7)))
    assert table_layout(bytes(image))[0] == 6
    image[8 * 2 + 2] ^= 0x10  # phrase 2 no longer follows phrase 1
    with pytest.raises(FormatError, match="phrase 2"):
        table_layout(bytes(image))


# --- the manifest ------------------------------------------------------------------------------


def write_manifest(path: Path, count: int, **change: object) -> None:
    phrases: list[dict[str, object]] = [
        {"number": n, "name": f"sample_{n:02d}"} for n in range(1, count + 1)
    ]
    doc = {"format": "stunrun-oki 2", "table_entries": count + 1, "phrases": phrases}
    for key, value in change.items():
        number, field = key.split("__")
        phrases[int(number[1:]) - 1][field] = value
    path.write_text(json.dumps(doc))


def test_manifest_reader(tmp_path: Path) -> None:
    path = tmp_path / "m.json"
    write_manifest(path, 4)
    manifest = read_manifest(path)
    assert manifest.entries == 5 and [e.stem for e in manifest.phrases][-1] == "04-sample_04"
    cases = [
        ("p3__number", 7, "numbered 1, 2"),
        ("p1__name", "1abc", "not a unique label"),
        ("p2__name", "sample_01", "not a unique label"),
        ("p3__name", "phrase_01", "the OKI tree's own labels"),
        ("p1__name", "phrase_02_last", "the OKI tree's own labels"),
        ("p4__name", "oki_tail", "the OKI tree's own labels"),
        ("p2__start", "001A8", "derived from the WAV lengths"),
        ("p2__length", 4, "derived from the WAV lengths"),
        ("p4__seconds", 1.77, "derived from the WAV lengths"),
    ]
    for key, value, message in cases:
        write_manifest(path, 4, **{key: value})
        with pytest.raises(FormatError, match=message):
            read_manifest(path)
    doc = json.loads(path.read_text())
    doc["format"] = "stunrun-oki 1"
    path.write_text(json.dumps(doc))
    with pytest.raises(FormatError, match="not a 'stunrun-oki 2' manifest"):
        read_manifest(path)


def sample_name(commands: list[dict[str, Any]], phrase: int) -> str:
    """The name card A12 gives phrase `phrase`: the 68010's audio-test name, in lower case, of
    the one command in 38-6C (the 6502's OKI play commands, type 13) that plays it; phrase 1 is
    also played by 05 (ADTEST), which the rule leaves out (command snd_<name> plays <name>)."""
    plays = [c for c in commands if c["type"] == "13" and c["phrase"] == phrase]
    named = [c for c in plays if int(c["value"], 16) >= 0x38]
    assert len(named) == 1, (phrase, [c["value"] for c in plays])
    assert named[0]["name"] == "snd_" + named[0]["audio_test"].lower(), phrase
    return str(named[0]["audio_test"]).lower()


def test_committed_manifest() -> None:
    """52 phrases named by the 68010's audio test (card A12, derived here from
    data/sound/commands.json so the two files cannot drift), Jesus's words from listening
    verbatim in description (card A8), and the audio-test names of every command that plays the
    phrase in audio_test."""
    manifest = read_manifest(MANIFEST)
    assert manifest.entries == 53 and len(manifest.phrases) == 52
    doc = json.loads(MANIFEST.read_text())
    commands = json.loads(COMMANDS.read_text())["commands"]
    for p in doc["phrases"]:
        n = p["number"]
        # every phrase is played by some command (the 6502's tables) and MAME saw it start
        assert p["commands"], n
        assert sum(p["starts"].values()) > 0, n
        assert p["name"] == sample_name(commands, n), n
        assert isinstance(p["description"], str) and p["description"], n
        plays = [c["audio_test"] for c in commands if c["type"] == "13" and c["phrase"] == n]
        assert p["audio_test"] == plays, n
    assert [p["name"] for p in doc["phrases"]][:2] == ["welcome", "luck"]
    assert doc["phrases"][0]["audio_test"] == ["ADTEST", "WELCOME"]
    numbers = [p for p in doc["phrases"] if 10 <= p["number"] <= 31]
    assert (numbers[0]["description"], numbers[-1]["description"]) == ("One", "Twenty-two")


def test_docs_attribute_names_to_audio_test() -> None:
    """Card A12: the names come from the 68010's audio test, only the descriptions from Jesus's
    listening (card A8). No sentence of docs/10 or CLAUDE.md may say the names are his hearing."""
    import re

    stale = re.compile(r"names\s+(?:are|come\s+from)\s+Jesus's\s+(?:hearing|listening)", re.I)
    for path in (REPO / "docs/10-adpcm.md", REPO / "CLAUDE.md"):
        text = " ".join(path.read_text().split())
        assert not stale.search(text), path
    assert "audio-test abbreviations (card A12)" in " ".join(
        (REPO / "docs/10-adpcm.md").read_text().split()
    )


def test_sample_name_follows_commands() -> None:
    """The name rule fails when the manifest and data/sound/commands.json disagree: a command's
    audio-test name changed, or a phrase played by no command in 38-6C."""
    commands = json.loads(COMMANDS.read_text())["commands"]
    assert sample_name(commands, 39) == "gun1" and sample_name(commands, 1) == "welcome"
    changed = [dict(c) for c in commands]
    gun1 = next(c for c in changed if c["value"] == "67")
    gun1["audio_test"] = "GUN2"
    with pytest.raises(AssertionError):
        sample_name(changed, 39)  # the command's own name (snd_gun1) no longer follows
    gun1["name"] = "snd_gun2"
    assert sample_name(changed, 39) == "gun2"  # ... and the committed gun1 would fail
    only_05 = [c for c in commands if c["value"] != "38"]
    with pytest.raises(AssertionError):
        sample_name(only_05, 1)


# --- the committed samples (CI, no ROMs) -------------------------------------------------------

OKI_CHIPS = ["136070-2124.1fh", "136070-2125.1ef", "136070-2126.1de", "136070-2127.1cd"]


def committed_image() -> tuple[Layout, bytes]:
    lay, samples, trips = encode_all(DATA, MANIFEST)
    assert all(t.exact for t in trips.values())  # the committed WAVs are the decoder's output
    return lay, build(lay, samples)


def test_committed_wavs_rebuild_the_four_chips() -> None:
    """CI: data/oki (the manifest and the 52 WAVs) encodes to the four OKI chips exactly as MAME
    lists them (size, CRC-32, SHA-1), with no ROM file read."""
    lay, image = committed_image()
    assert lay.tail == REFERENCE_TAIL
    roms = {r["name"]: r for r in load_snapshot("stunrun")["roms"]}
    assert [name for _, name in chips()] == OKI_CHIPS
    for address, name in chips():
        data = image[address : address + roms[name]["size"]]
        assert len(data) == roms[name]["size"] == 0x10000
        assert hashes(data) == (roms[name]["crc"], roms[name]["sha1"]), name


def test_committed_audio_is_the_52_samples() -> None:
    """The only audio in the repository: data/oki/NN-name.wav, one per phrase of the manifest,
    each a canonical PCM WAV (the header `tools/adpcm samples` writes) of decoder output."""
    r = run("git", "-C", REPO, "ls-files")
    if r.returncode != 0:
        pytest.skip("not a git checkout")
    audio = (".wav", ".raw", ".pcm", ".vox", ".adpcm", ".aiff", ".aif", ".flac", ".mp3", ".ogg",
             ".opus", ".m4a")
    found = sorted(f for f in r.stdout.splitlines() if f.lower().endswith(audio))
    manifest = read_manifest(MANIFEST)
    assert found == sorted(f"data/oki/{e.stem}.wav" for e in manifest.phrases)
    assert len(found) == 52
    for f in found:
        blob = (REPO / f).read_bytes()
        values = read_wav(blob)
        assert pcm_wav(values) == blob, f
        assert len(values) % 2 == 0 and all(v % SCALE == 0 for v in values), f
    assert [f for f in r.stdout.splitlines() if f.startswith("data/oki/")] == sorted(
        found + ["data/oki/samples.json"]
    )


def reference_image() -> bytes | None:
    """The OKI image merged in memory from the reference set (where `tools/check-roms` looks,
    STUNRUN_ROMS), or None when the set is absent (CI). Never build/stunrun-oki.bin: since M4g
    nothing in `make` needs that file, so it may be missing while the set is present. Fails on
    an OKI chip whose hashes are not the snapshot's."""
    files = read_set(DEFAULT_ARCHIVE / SET)
    if files is None:
        return None
    snapshot = load_snapshot(SET)
    for rom in snapshot["roms"]:
        if rom["region"] == "mainpcb:jsa:oki1":
            assert rom["name"] in files, f"reference set: {rom['name']} missing"
            assert hashes(files[rom["name"]]) == (rom["crc"], rom["sha1"]), rom["name"]
    return merge(snapshot, files)["stunrun-oki"]


def require_reference_image() -> bytes:
    image = reference_image()
    if image is None:
        pytest.skip(f"reference set absent ({DEFAULT_ARCHIVE / SET})")
    return image


def test_committed_wavs_are_what_the_image_decodes_to() -> None:
    """With the reference set: every committed WAV is exactly the decoder's output for its
    phrase of the image's own table (`make samples` rewrites them), and the layout their lengths
    give is that table. Fails while data/oki and the image disagree. Decided by the set, not by
    build/stunrun-oki.bin (which `make` no longer writes)."""
    image = require_reference_image()
    entries, spans = table_layout(image)
    manifest = read_manifest(MANIFEST)
    assert entries == manifest.entries
    for e, (s, end) in zip(manifest.phrases, spans, strict=True):
        assert (DATA / f"{e.stem}.wav").read_bytes() == pcm_wav(pcm(image[s : end + 1])), e.stem
    lay, built = committed_image()
    assert [(p.start, p.end) for p in lay.phrases] == spans
    assert built == image


# --- the generated include ---------------------------------------------------------------------


def reference_layout() -> Layout:
    lay, _ = committed_image()
    return lay


def test_asm_source_cuts_at_chip_boundaries() -> None:
    lay = reference_layout()
    samples = synthetic_samples(lay, 9)
    text = asm_source(lay, samples)
    assert "oki_phrases\tequ\t52" in text
    assert "incbin" not in text
    for address, name in chips()[1:]:
        assert f'{chip_label(name)}:\n\tassert\t*=${address:05X},"{name} misplaced"' in text
    # every phrase's name is a label next to phrase_NN (the reader refuses the tree's own labels)
    for p in lay.phrases:
        assert f"phrase_{p.number:02d}:\n{p.name}:\n" in text
    # phrase 11 crosses 10000: its first 0x358 bytes, then 1ef's label, then the rest
    p11 = lay.phrases[10]
    assert p11.start < 0x10000 <= p11.end and 0x10000 - p11.start == 0x358
    assert text.rstrip().endswith("\tdcb.b\t$358,0")
    # every byte appears once, in order, 16 to a line
    body = [line for line in text.splitlines() if line.startswith("\tdc.b\t")]
    got = bytes(int(x[1:], 16) for line in body for x in line.split("\t")[2].split(","))
    assert got == b"".join(samples[p.number] for p in lay.phrases)


def resized_layout(lengths: dict[int, int]) -> Layout:
    """The reference layout with some phrases of other lengths and the rest moved."""
    lay = reference_layout()
    manifest = Manifest(lay.entries, [entry(p.number) for p in lay.phrases])
    return layout(manifest, {p.number: lengths.get(p.number, p.length) for p in lay.phrases})


def grown_layout() -> Layout:
    """Phrase 10 grown by 0x358 bytes: phrase 11 starts at 10000, phrase 52 ends at 3FFFF."""
    return resized_layout({10: reference_layout().phrases[9].length + 0x358})


def short_layout() -> Layout:
    """Phrases 40-52 cut to 0x80 bytes each: the samples end before 30000, where the last ROM
    file starts."""
    return resized_layout(dict.fromkeys(range(40, 53), 0x80))


def test_asm_source_labels_a_file_starting_at_a_sample() -> None:
    """Phrase 11 starting at 10000 (the first byte of the second ROM file), phrase 52 ending at
    3FFFF: phrase 10 grown by 0x358 bytes."""
    lay = grown_layout()
    assert lay.phrases[10].start == 0x10000 and lay.tail == 0x40000
    text = asm_source(lay, synthetic_samples(lay, 11))
    first = chips()[1][1]
    assert (f"{chip_label(first)}:\n\tassert\t*=$10000,\"{first} misplaced\"\n\tdc.b\t"
            in text.split("phrase_11:\nsample_11:\n")[1].split("phrase_11_last")[0])
    assert text.rstrip().endswith("\tdcb.b\t$0,0")


def test_asm_source_labels_a_file_in_the_zero_tail() -> None:
    """Samples shortened so that the last file starts in the zero tail: its label and assert
    sit between two dcb.b."""
    lay = short_layout()
    assert lay.tail < 0x30000
    text = asm_source(lay, synthetic_samples(lay, 12))
    tail = text.split("oki_tail:\n")[1]
    assert f"\tdcb.b\t${0x30000 - lay.tail:X},0\n" in tail
    assert '\tassert\t*=$30000,"136070-2127.1cd misplaced"\n\tdcb.b\t$10000,0' in tail


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


@pytest.mark.skipif(vasm() is None, reason="vasm not available")
@pytest.mark.parametrize("which", ["reference", "grown", "short"])
def test_tree_assembles_from_wavs(tmp_path: Path, which: str) -> None:
    """asm/oki/samples.asm + the include tools/adpcm asm generates from a directory of WAVs
    rebuild the image tools/adpcm builds, for the reference lengths, one sample longer (a file
    starting at a sample's first byte) and samples shorter (a file starting in the tail)."""
    lay = {"reference": lambda: resized_layout({}), "grown": grown_layout,
           "short": short_layout}[which]()
    data = tmp_path / "data/oki"
    data.mkdir(parents=True)
    doc = json.loads(MANIFEST.read_text())
    for entry in doc["phrases"]:
        entry["name"] = f"sample_{entry['number']:02d}"
    (data / "samples.json").write_text(json.dumps(doc))
    rng = random.Random(10)
    encoded = {}
    for p in lay.phrases:
        values = [SCALE * s for s in decode(rng.randbytes(p.length))]
        (data / f"{p.stem}.wav").write_bytes(pcm_wav(values))
        encoded[p.number] = encode(values)
    shutil.copytree(REPO / "asm/oki", tmp_path / "asm/oki")
    r = run(sys.executable, TOOLS / "adpcm", "asm", "--data", data, "--out",
            tmp_path / "build/oki")
    assert r.returncode == 0, r.stderr
    r = run(vasm(), "-quiet", "-Fbin", "-no-opt", "-m68010", "-o", tmp_path / "oki.out",
            "asm/oki/samples.asm", cwd=tmp_path)
    assert r.returncode == 0, r.stdout + r.stderr
    assert (tmp_path / "oki.out").read_bytes() == build(lay, encoded)


def test_asm_reports_edits_and_refuses_strays(tmp_path: Path) -> None:
    data = tmp_path / "oki"
    shutil.copytree(DATA, data)
    out = tmp_path / "build"
    adpcm = TOOLS / "adpcm"
    r = run(sys.executable, adpcm, "asm", "--data", data, "--out", out)
    assert r.returncode == 0, r.stderr
    assert "edited" not in r.stdout and "856 bytes free" in r.stdout
    # one sample of phrase 2 changed: built, with its round-trip error
    wav = data / "02-luck.wav"
    values = read_wav(wav.read_bytes())
    values[1000] = values[1000] - 4000 if values[1000] > 0 else values[1000] + 4000
    wav.write_bytes(pcm_wav(values))
    r = run(sys.executable, adpcm, "asm", "--data", data, "--out", out)
    assert r.returncode == 0, r.stderr
    assert "phrase 2 (02-luck.wav): edited" in r.stdout
    r = run(sys.executable, adpcm, "check", "--data", data)
    assert r.returncode == 0 and "51 of 52 WAVs come back exactly" in r.stdout, r.stdout
    # a WAV no phrase names, a missing WAV, samples past 256 KB
    shutil.copy(wav, data / "02-renamed.wav")
    r = run(sys.executable, adpcm, "asm", "--data", data, "--out", out)
    assert r.returncode == 1 and "no phrase of the manifest has this name" in r.stderr
    (data / "02-renamed.wav").unlink()
    wav.unlink()
    r = run(sys.executable, adpcm, "asm", "--data", data, "--out", out)
    assert r.returncode == 1 and "02-luck.wav absent" in r.stderr
    wav.write_bytes(pcm_wav(values + [0] * 2 * 857))
    r = run(sys.executable, adpcm, "asm", "--data", data, "--out", out)
    assert r.returncode == 1 and "1 bytes more than the 256 KB image holds" in r.stderr, r.stderr


# --- the decoder -------------------------------------------------------------------------------

# The 49 step sizes of Dialogic (VOX) ADPCM, the coding the M6295 uses, written out by hand: an
# independent statement of what okiadpcm.cpp computes as floor(16 * 1.1 ** step).
DIALOGIC_STEPS = [
    16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130,
    143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552,
]


def test_diff_table_by_hand() -> None:
    for step_, s in enumerate(DIALOGIC_STEPS):
        # nibble 0: s/8; nibble 7: s + s/2 + s/4 + s/8; bit 3 negates
        assert DIFF[step_ * 16 + 0] == s // 8
        assert DIFF[step_ * 16 + 7] == s + s // 2 + s // 4 + s // 8
        assert DIFF[step_ * 16 + 8] == -(s // 8)
        assert DIFF[step_ * 16 + 5] == s + s // 4 + s // 8
        assert DIFF[step_ * 16 + 15] == -DIFF[step_ * 16 + 7]


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
    assert pcm(b"\x77") == [480, 1488]


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
    image = reference_image()
    if image is not None:
        _, spans = table_layout(image)
        for number, (s, e) in enumerate(spans, 1):
            data = image[s : e + 1]
            assert decode(data) == mame_decode(exe, data), f"phrase {number}"


# --- the encoder (docs/10 section 6) -----------------------------------------------------------


def test_lemma_distinct_differences() -> None:
    """From any state the 16 nibbles give 16 distinct sums (each row of the table is
    injective), so two nibbles reach one output only when the clamp makes them equal, and the
    clamped output is -2048 or 2047."""
    for index, row in enumerate(ROWS):
        diffs = [d for d, _ in row]
        assert len(set(diffs)) == 16, index
        assert all(d != 0 for d in diffs)
    rng = random.Random(3)
    for _ in range(20000):
        signal, index = rng.randrange(-2048, 2048), rng.randrange(49)
        outs: dict[int, list[int]] = {}
        for n in range(16):
            outs.setdefault(step(signal, index, n)[0], []).append(n)
        for value, ns in outs.items():
            assert len(ns) == 1 or value in (-2048, 2047), (signal, index, value, ns)


def clamping(rng: random.Random, length: int) -> bytes:
    """Random ADPCM that spends much of its time at the clamps: runs of the largest nibbles."""
    out = bytearray()
    while len(out) < length:
        loud = rng.random() < 0.6
        b = rng.choice([0x77, 0xFF, 0x67, 0xEF, 0x76, 0xFE]) if loud else rng.randrange(256)
        out += bytes([b]) * rng.randrange(1, 12)
    return bytes(out[:length])


@pytest.mark.parametrize("seed", range(12))
def test_encoder_inverts_the_decoder(seed: int) -> None:
    """For any decoder output the encoder's bytes decode to the same PCM; they are the original
    bytes whenever no output sits at a clamp."""
    rng = random.Random(seed)
    data = clamping(rng, 3000) if seed % 2 else rng.randbytes(3000)
    values = pcm(data)
    again = encode(values)
    assert pcm(again) == values
    if not any(v in (-2048 * SCALE, 2047 * SCALE) for v in values):
        assert again == data
    # a quiet random walk of small nibbles never clamps: always the same bytes
    small = [0x00, 0x08, 0x80, 0x88, 0x18, 0x81, 0x09, 0x90]
    quiet = bytes(rng.choice(small) for _ in range(2000))
    assert max(abs(v) for v in decode(quiet)) < 2047
    assert encode(pcm(quiet)) == quiet


@pytest.mark.parametrize("start", [(2047, 48), (2000, 40), (1900, 48), (-2048, 48), (-1990, 44),
                                   (0, 0), (2040, 30)])
def test_encoder_picks_the_lexicographically_smallest(start: tuple[int, int]) -> None:
    """Every sequence of three nibbles from a state near a clamp: the encoder gives back a
    sequence with the same outputs, and the smallest (lexicographically) of all that do."""
    groups: dict[tuple[int, ...], list[tuple[int, ...]]] = {}
    for seq in itertools.product(range(16), repeat=3):
        groups.setdefault(tuple(decode_nibbles(list(seq), start)), []).append(seq)
    ambiguous = 0
    for outs, seqs in groups.items():
        got = encode_nibbles([SCALE * v for v in outs], start)
        assert tuple(got) == min(seqs), (start, outs)
        ambiguous += len(seqs) > 1
    if start[0] in (2047, -2048) or start == (2040, 30):
        assert ambiguous  # these starts do reach one output by several sequences


def test_encoder_on_an_edit() -> None:
    """PCM no decoder produced (a tone, off the grid, beyond the range): the encoder follows it,
    and round_trip measures how far the decoded result is."""
    tone = [round(6400 * math.sin(i / 7)) for i in range(2001)]
    data = encode(tone)
    assert len(data) == 1001  # odd: the last value once more
    trip = round_trip(tone, data)
    assert trip.padded and not trip.exact and trip.samples == 2001
    assert 0 < trip.max_error < 1000 and trip.differ > 0
    back = pcm(data)
    assert back[-1] == back[-2] or abs(back[-1] - tone[-1]) <= trip.max_error
    # what it decodes to is decoder output, so it comes back exactly a second time
    assert encode(back) == data and round_trip(back, data).exact
    # full scale: the nearest the clamp allows
    loud = [32767] * 200
    assert set(pcm(encode(loud))[100:]) == {2047 * SCALE}
    assert round_trip(loud, encode(loud)).max_error >= 15
    with pytest.raises(FormatError, match="no samples"):
        encode([])


def test_encoder_is_fast_on_decoder_output() -> None:
    """The build encodes the 52 samples (521,728 values) on every make: the common case (one
    candidate, an exact unclamped value) is a table lookup."""
    values = pcm(random.Random(5).randbytes(50000))
    t = time.perf_counter()
    encode(values)
    assert time.perf_counter() - t < 2.0


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


def test_survey_keeps_names_descriptions_and_audio_test(tmp_path: Path) -> None:
    """survey rewrites the commands and starts from the image's table, the 6502's tables and the
    traces, and keeps what Jesus named (name, description) and the cross evidence."""
    lay = reference_layout()
    image = tmp_path / "oki.bin"
    image.write_bytes(build(lay, synthetic_samples(lay, 13)))
    jsa = bytearray(0x10000)
    for effect, phrase in enumerate(range(1, 53), 1):
        jsa[0x6100 + 0x37 + effect] = 0x13
        jsa[0x616D + 0x37 + effect] = effect
        jsa[0x6532 + effect] = phrase
    (tmp_path / "jsa.bin").write_bytes(bytes(jsa))
    trace = tmp_path / "okitrace-inject.txt"
    trace.write_text("start 2 8 1 5C53 39 02 3 100\n")
    manifest = tmp_path / "samples.json"
    shutil.copy(MANIFEST, manifest)
    r = run(sys.executable, TOOLS / "adpcm", "survey", "--image", image, "--jsa",
            tmp_path / "jsa.bin", "--manifest", manifest, trace)
    assert r.returncode == 0, r.stderr
    old = json.loads(MANIFEST.read_text())["phrases"]
    new = json.loads(manifest.read_text())["phrases"]
    for a, b in zip(old, new, strict=True):
        assert {k: b[k] for k in ("name", "description", "audio_test")} == {
            k: a[k] for k in ("name", "description", "audio_test")}
        assert b["commands"] == [f"{0x37 + a['number']:02X}"]
        assert "start" not in b and "length" not in b
    assert new[1]["starts"] == {"inject": 3} and new[0]["starts"] == {"inject": 0}
    read_manifest(manifest)


def test_samples_writes_one_canonical_wav_per_phrase(tmp_path: Path) -> None:
    """`make samples` on a synthetic image: one WAV per phrase of the image's own table, the
    decoder's PCM, named from the manifest; a stale WAV is removed, a second run writes none."""
    lay = reference_layout()
    samples = synthetic_samples(lay, 14)
    image = tmp_path / "oki.bin"
    image.write_bytes(build(lay, samples))
    out = tmp_path / "oki"
    out.mkdir()
    (out / "99-stale.wav").write_bytes(pcm_wav([0, 0]))
    adpcm = TOOLS / "adpcm"
    r = run(sys.executable, adpcm, "samples", "--image", image, "--manifest", MANIFEST, "--out", out)
    assert r.returncode == 0 and "52 written, 1 stale removed" in r.stdout, r.stdout + r.stderr
    assert sorted(f.name for f in out.glob("*.wav")) == sorted(f"{p.stem}.wav" for p in lay.phrases)
    for p in lay.phrases:
        assert (out / f"{p.stem}.wav").read_bytes() == pcm_wav(pcm(samples[p.number]))
    r = run(sys.executable, adpcm, "samples", "--image", image, "--manifest", MANIFEST, "--out", out)
    assert r.returncode == 0 and "0 written" in r.stdout, r.stdout
