"""The OKI M6295 ADPCM image of the JSA II board: phrase table, samples, WAV (docs/10-adpcm.md).

The image (`stunrun-oki`, 256 KB, the four 1fh/1ef/1de/1cd files one after the other; the M6295
address is the image offset, JSA II does not bank it) starts with the chip's phrase table:
okim6295_device::write (okim6295.cpp) takes phrase n's entry at 8 * n, a 3-byte big-endian start
and a 3-byte big-endian end, each masked to 18 bits, and plays start..end inclusive
(`m_count = 2 * (stop - start + 1)` nibbles). Bytes 6-7 of an entry are not read by the chip.
In stunrun the table has entries 0-52 (0x000-0x1A7, entry 0 all zero, the 6502 never asks for
phrase 0 or for a phrase above 52); the 52 samples follow it back to back in phrase order and
the rest of the image is zero. data/oki/samples.json (the manifest) records that layout and the
names; this module checks an image against it, splits it, and builds it back.

Each sample is kept as a WAV that carries its ADPCM bytes verbatim (format tag 0x0017, Dialogic
OKI ADPCM: 4 bits per sample, high nibble first, as the M6295 reads them), so WAV -> bytes is a
copy and the round trip is exact by construction. `decode` is okiadpcm.cpp's oki_adpcm_state
(the M6295 decoder in MAME) step for step; `encode` is a deterministic greedy encoder used only
to measure whether PCM could stand in for the bytes (it is never part of the build).

No function here prints a sample byte: messages carry phrase numbers, addresses and lengths.
"""

from __future__ import annotations

import json
import math
import struct
from dataclasses import dataclass
from pathlib import Path

# atarijsa.cpp: JSA_MASTER_CLOCK = 3.579545 MHz; OKIM6295(config, m_oki1, JSA_MASTER_CLOCK/3, ...)
CLOCK = 3_579_545 / 3
# okim6295.cpp: divisor = m_pin7_state ? 132 : 165. JSA II's wrio_w drives pin 7 from bit 3 of
# 2A04; the 6502 never sets it (make okitrace: every 2A04 write is 00, 01 or 05), so MAME plays
# the samples at CLOCK / 165.
DIVISORS = {"low": 165, "high": 132}
PIN7 = "low"

IMAGE_SIZE = 0x40000
ENTRY = 8  # bytes per phrase-table entry
ADDRESS_MASK = 0x3FFFF  # okim6295_device::write masks start and stop to 18 bits
MAX_PHRASES = 0x80  # a phrase number is 7 bits

FORMAT = "stunrun-oki 1"
WAVE_FORMAT_DIALOGIC_OKI_ADPCM = 0x0017


class FormatError(Exception):
    """An image, a manifest or a WAV that is not what this module expects."""


def rate(pin7: str = PIN7) -> float:
    """The M6295 output rate in Hz with pin 7 in the given state."""
    return CLOCK / DIVISORS[pin7]


# --- the manifest ------------------------------------------------------------------------------


@dataclass(frozen=True)
class Phrase:
    number: int
    name: str
    start: int
    end: int  # inclusive, as the table stores it

    @property
    def length(self) -> int:
        return self.end - self.start + 1

    @property
    def stem(self) -> str:
        return f"{self.number:02d}-{self.name}"


@dataclass(frozen=True)
class Layout:
    entries: int  # table entries, entry 0 included
    phrases: list[Phrase]

    @property
    def table_end(self) -> int:
        return self.entries * ENTRY

    @property
    def tail(self) -> int:
        """The first address after the last sample: from there to the end the image is zero."""
        return self.phrases[-1].end + 1 if self.phrases else self.table_end


def is_label(name: str) -> bool:
    return bool(name) and (name[0].isalpha() or name[0] == "_") and all(
        c.isalnum() or c == "_" for c in name
    ) and name.isascii()


def parse_address(value: object, what: str) -> int:
    if not isinstance(value, str):
        raise FormatError(f"{what}: an address is a hex string, not {value!r}")
    try:
        return int(value, 16)
    except ValueError:
        raise FormatError(f"{what}: {value!r} is not a hex address") from None


def read_manifest(path: Path) -> Layout:
    """The layout data/oki/samples.json records, checked: phrases 1..n back to back from the end
    of the table, unique label names, inside the image."""
    try:
        doc = json.loads(path.read_text())
    except (OSError, ValueError) as e:
        raise FormatError(f"{path}: {e}") from None
    if not isinstance(doc, dict) or doc.get("format") != FORMAT:
        raise FormatError(f"{path}: not a {FORMAT!r} manifest")
    entries = doc.get("table_entries")
    if not isinstance(entries, int) or not 1 <= entries <= MAX_PHRASES:
        raise FormatError(f"{path}: table_entries must be 1..{MAX_PHRASES}")
    phrases = []
    names: set[str] = set()
    expect = entries * ENTRY
    for i, p in enumerate(doc.get("phrases", []), 1):
        where = f"{path}: phrase {i}"
        if not isinstance(p, dict) or p.get("number") != i:
            raise FormatError(f"{where}: phrases must be numbered 1, 2, ... in order")
        name = p.get("name")
        if not isinstance(name, str) or not is_label(name) or name in names:
            raise FormatError(f"{where}: name {name!r} is not a unique label")
        names.add(name)
        start = parse_address(p.get("start"), where)
        end = parse_address(p.get("end"), where)
        if start != expect:
            raise FormatError(f"{where}: starts at {start:05X}, the previous one ends at {expect:05X}")
        if end < start or end >= IMAGE_SIZE:
            raise FormatError(f"{where}: end {end:05X} outside {start:05X}-{IMAGE_SIZE - 1:05X}")
        if p.get("length") != end - start + 1:
            raise FormatError(f"{where}: length is not end - start + 1")
        phrases.append(Phrase(i, name, start, end))
        expect = end + 1
    if len(phrases) != entries - 1:
        raise FormatError(f"{path}: {len(phrases)} phrases for {entries} table entries")
    return Layout(entries, phrases)


# --- the phrase table --------------------------------------------------------------------------


def encode_table(layout: Layout) -> bytes:
    """The table as the image holds it: entry 0 and bytes 6-7 of every entry zero."""
    out = bytearray(ENTRY)
    for p in layout.phrases:
        out += p.start.to_bytes(3, "big") + p.end.to_bytes(3, "big") + b"\0\0"
    return bytes(out)


def decode_table(image: bytes, entries: int) -> list[tuple[int, int]]:
    """(start, end) of entries 1..entries-1, read as okim6295_device::write reads them."""
    out = []
    for n in range(1, entries):
        e = image[n * ENTRY : n * ENTRY + 6]
        out.append((int.from_bytes(e[:3], "big") & ADDRESS_MASK,
                    int.from_bytes(e[3:], "big") & ADDRESS_MASK))
    return out


def check_image(image: bytes, layout: Layout) -> None:
    """Fail unless the image is exactly the manifest's table, samples and zero tail."""
    if len(image) != IMAGE_SIZE:
        raise FormatError(f"image is {len(image)} bytes, not {IMAGE_SIZE}")
    table = encode_table(layout)
    for n in range(layout.entries):
        if image[n * ENTRY : n * ENTRY + ENTRY] != table[n * ENTRY : n * ENTRY + ENTRY]:
            got = decode_table(image, layout.entries)[n - 1] if n else None
            want = (layout.phrases[n - 1].start, layout.phrases[n - 1].end) if n else None
            detail = (
                f"{got[0]:05X}-{got[1]:05X} in the image, {want[0]:05X}-{want[1]:05X} in the manifest"
                if got and want
                else "not the zero entry and padding the manifest describes"
            )
            raise FormatError(f"phrase table entry {n}: {detail}")
    tail = layout.tail
    nonzero = [a for a in range(tail, IMAGE_SIZE) if image[a]]
    if nonzero:
        raise FormatError(
            f"{len(nonzero)} nonzero bytes after the last sample (first at {nonzero[0]:05X})"
        )


def split(image: bytes, layout: Layout) -> dict[int, bytes]:
    """Phrase number -> its sample bytes, after check_image."""
    check_image(image, layout)
    return {p.number: image[p.start : p.end + 1] for p in layout.phrases}


def build(layout: Layout, samples: dict[int, bytes]) -> bytes:
    """The image from the manifest and the sample bytes (the inverse of split)."""
    out = bytearray(encode_table(layout))
    for p in layout.phrases:
        data = samples[p.number]
        if len(data) != p.length:
            raise FormatError(f"phrase {p.number}: {len(data)} bytes, the manifest says {p.length}")
        out += data
    if len(out) > IMAGE_SIZE:
        raise FormatError(f"the samples end at {len(out):05X}, past the image")
    return bytes(out) + bytes(IMAGE_SIZE - len(out))


# --- WAV ---------------------------------------------------------------------------------------


def chunk(tag: bytes, body: bytes) -> bytes:
    return tag + struct.pack("<I", len(body)) + body + (b"\0" if len(body) & 1 else b"")


def riff(chunks: list[bytes]) -> bytes:
    body = b"WAVE" + b"".join(chunks)
    return b"RIFF" + struct.pack("<I", len(body)) + body


def adpcm_wav(data: bytes, name: str = "", pin7: str = PIN7) -> bytes:
    """A WAV whose data chunk is `data` verbatim: Dialogic OKI ADPCM (format tag 0x0017), mono,
    4 bits per sample, high nibble first; the fact chunk gives the number of samples (two per
    byte); the name, if any, goes into LIST/INFO/INAM."""
    hz = round(rate(pin7))
    fmt = struct.pack("<HHIIHHH", WAVE_FORMAT_DIALOGIC_OKI_ADPCM, 1, hz, (hz + 1) // 2, 1, 4, 0)
    chunks = [chunk(b"fmt ", fmt), chunk(b"fact", struct.pack("<I", 2 * len(data)))]
    if name:
        chunks.append(chunk(b"LIST", b"INFO" + chunk(b"INAM", name.encode("ascii") + b"\0")))
    chunks.append(chunk(b"data", data))
    return riff(chunks)


def chunks(blob: bytes) -> list[tuple[bytes, bytes]]:
    """The top-level chunks of a RIFF WAVE file; FormatError on anything malformed."""
    if len(blob) < 12 or blob[:4] != b"RIFF" or blob[8:12] != b"WAVE":
        raise FormatError("not a RIFF WAVE file")
    (size,) = struct.unpack_from("<I", blob, 4)
    if size + 8 > len(blob) or size < 4:
        raise FormatError(f"RIFF size {size} does not fit the {len(blob)}-byte file")
    out = []
    pos, end = 12, 8 + size
    while pos < end:
        if pos + 8 > end:
            raise FormatError(f"truncated chunk header at byte {pos}")
        tag = blob[pos : pos + 4]
        (n,) = struct.unpack_from("<I", blob, pos + 4)
        if pos + 8 + n > end:
            raise FormatError(f"chunk {tag!r} at byte {pos} runs past the RIFF body")
        out.append((tag, blob[pos + 8 : pos + 8 + n]))
        pos += 8 + n + (n & 1)
    return out


def unwav(blob: bytes) -> bytes:
    """The ADPCM bytes of a WAV made by adpcm_wav (or any WAV in the same format): the data
    chunk, verbatim. Rejects any other format, channel count or sample size, a missing or
    doubled fmt/data chunk, and a fact chunk that disagrees with the data."""
    found: dict[bytes, list[bytes]] = {}
    for tag, body in chunks(blob):
        found.setdefault(tag, []).append(body)
    for tag in (b"fmt ", b"data"):
        if len(found.get(tag, [])) != 1:
            raise FormatError(f"{len(found.get(tag, []))} {tag.decode().strip()!r} chunks, not 1")
    fmt = found[b"fmt "][0]
    if len(fmt) < 16:
        raise FormatError("fmt chunk shorter than 16 bytes")
    tag, channels, _, _, align, bits = struct.unpack_from("<HHIIHH", fmt)
    if tag != WAVE_FORMAT_DIALOGIC_OKI_ADPCM:
        raise FormatError(f"format tag 0x{tag:04X}, not 0x0017 (Dialogic OKI ADPCM)")
    if channels != 1 or bits != 4 or align != 1:
        raise FormatError(f"{channels} channels, {bits} bits, block align {align}: not 1, 4, 1")
    data = found[b"data"][0]
    for fact in found.get(b"fact", []):
        if len(fact) < 4 or struct.unpack_from("<I", fact)[0] != 2 * len(data):
            raise FormatError("fact chunk does not give two samples per data byte")
    return data


def pcm_wav(samples: list[int], pin7: str = PIN7) -> bytes:
    """16-bit PCM mono: each 12-bit decoder output shifted left by 4 (MAME's stream divides the
    output by 2048, the same scale)."""
    hz = round(rate(pin7))
    fmt = struct.pack("<HHIIHH", 1, 1, hz, 2 * hz, 2, 16)
    data = struct.pack(f"<{len(samples)}h", *(s * 16 for s in samples))
    return riff([chunk(b"fmt ", fmt), chunk(b"data", data)])


def read_pcm_wav(blob: bytes) -> list[int]:
    """The 12-bit samples of a pcm_wav file (each 16-bit sample shifted right by 4, which must
    be exact)."""
    found = dict(chunks(blob))
    fmt = found.get(b"fmt ")
    data = found.get(b"data")
    if fmt is None or data is None or len(fmt) < 16:
        raise FormatError("no fmt or data chunk")
    tag, channels, _, _, _, bits = struct.unpack_from("<HHIIHH", fmt)
    if (tag, channels, bits) != (1, 1, 16) or len(data) & 1:
        raise FormatError("not 16-bit mono PCM")
    values = struct.unpack(f"<{len(data) // 2}h", data)
    if any(v & 15 for v in values):
        raise FormatError("a sample is not a 12-bit value shifted left by 4")
    return [v >> 4 for v in values]


# --- the M6295's decoder (okiadpcm.cpp, oki_adpcm_state) ---------------------------------------

INDEX_SHIFT = (-1, -1, -1, -1, 2, 4, 6, 8)  # s_index_shift


def diff_lookup() -> list[int]:
    """s_diff_lookup[step * 16 + nibble], as compute_tables builds it."""
    table = []
    for step in range(49):
        stepval = math.floor(16.0 * math.pow(11.0 / 10.0, step))
        for nib in range(16):
            sign = -1 if nib & 8 else 1
            table.append(
                sign
                * (
                    stepval * (nib >> 2 & 1)
                    + stepval // 2 * (nib >> 1 & 1)
                    + stepval // 4 * (nib & 1)
                    + stepval // 8
                )
            )
    return table


DIFF = diff_lookup()


def nibbles(data: bytes) -> list[int]:
    """The order okim_voice::generate_adpcm reads: the high nibble of each byte first."""
    out: list[int] = []
    for b in data:
        out += (b >> 4, b & 15)
    return out


def step(signal: int, index: int, nibble: int) -> tuple[int, int]:
    """oki_adpcm_state::clock: the new (signal, step index)."""
    signal = min(2047, max(-2048, signal + DIFF[index * 16 + nibble]))
    index = min(48, max(0, index + INDEX_SHIFT[nibble & 7]))
    return signal, index


def decode(data: bytes) -> list[int]:
    """The 12-bit outputs (-2048..2047) the M6295 produces for a sample, one per nibble, from
    the reset state (signal 0, step 0, as a voice starts: voice.m_adpcm.reset())."""
    signal, index = 0, 0
    out: list[int] = []
    for n in nibbles(data):
        signal, index = step(signal, index, n)
        out.append(signal)
    return out


def encode(samples: list[int]) -> bytes:
    """A deterministic greedy encoder: at each sample the nibble whose decoded output is nearest
    (the lowest nibble on a tie). For PCM that decode() produced, the nibble the ROM holds
    reaches each sample exactly, so the encoder picks it unless a lower nibble reaches the same
    output, which only the clamp to -2048..2047 allows; `tools/adpcm encoder-check` measures it.
    Experiments only: the build never encodes PCM."""
    signal, index = 0, 0
    out: list[int] = []
    for target in samples:
        best = min(range(16), key=lambda n: (abs(step(signal, index, n)[0] - target), n))
        signal, index = step(signal, index, best)
        out.append(best)
    if len(out) & 1:
        out.append(0)
    return bytes(out[i] << 4 | out[i + 1] for i in range(0, len(out), 2))
