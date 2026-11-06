"""The OKI M6295 ADPCM image of the JSA II board: phrase table, samples, PCM WAV (docs/10-adpcm.md).

The image (`stunrun-oki`, 256 KB, the four 1fh/1ef/1de/1cd files one after the other; the M6295
address is the image offset, JSA II does not bank it) starts with the chip's phrase table:
okim6295_device::write (okim6295.cpp) takes phrase n's entry at 8 * n, a 3-byte big-endian start
and a 3-byte big-endian end, each masked to 18 bits, and plays start..end inclusive
(`m_count = 2 * (stop - start + 1)` nibbles). Bytes 6-7 of an entry are not read by the chip.
In stunrun the table has entries 0-52 (0x000-0x1A7, entry 0 all zero, the 6502 never asks for
phrase 0 or for a phrase above 52); the 52 samples follow it back to back in phrase order and
the rest of the image is zero.

The source of the image is data/oki: the manifest samples.json (numbers, names, descriptions,
play evidence; no addresses) and one PCM WAV per phrase, NN-name.wav, 16-bit mono at the M6295's
rate, the decoder's output (`decode`, MAME's okiadpcm.cpp step for step) scaled as MAME's stream
outputs it (x16). The build encodes every WAV back to ADPCM (`encode`, specified below and in
docs/10 section 6) and lays the samples out in phrase order from their lengths, so no address is
written by hand: `layout` derives every start and end.

No function here prints a sample byte: messages carry phrase numbers, addresses and lengths.
"""

from __future__ import annotations

import json
import math
import re
import struct
from dataclasses import dataclass
from pathlib import Path

# atarijsa.cpp: JSA_MASTER_CLOCK = 3.579545 MHz; OKIM6295(config, m_oki1, JSA_MASTER_CLOCK/3, ...)
CLOCK = 3_579_545 / 3
# okim6295.cpp: divisor = m_pin7_state ? 132 : 165. JSA II's wrio_w drives pin 7 from bit 3 of
# 2A04; the 6502 never sets it (CODE: the one write that could, 5903, is in the routine 5869,
# reached only from handler type 10h, which no sound command has, docs/10 section 2; MAME: every
# 2A04 write in make okitrace is 00, 01 or 05), so MAME plays the samples at CLOCK / 165.
DIVISORS = {"low": 165, "high": 132}
PIN7 = "low"

IMAGE_SIZE = 0x40000
ENTRY = 8  # bytes per phrase-table entry
ADDRESS_MASK = 0x3FFFF  # okim6295_device::write masks start and stop to 18 bits
MIN_SAMPLE = 2  # bytes: a 1-byte sample has start == stop, which the chip never plays
MAX_PHRASES = 0x80  # a phrase number is 7 bits

FORMAT = "stunrun-oki 2"
# 16-bit PCM = the 12-bit decoder output x 16: okim6295.cpp adds `clock(nibble) * m_volume` to
# its stream with max 2048 (add_int, sound.h: sample / max), so at 0 dB (s_volume_table[0] = 1)
# a signal s is s / 2048 full scale, which a 16-bit recording writes as s * 32768 / 2048.
SCALE = 16
SIGNAL_MIN, SIGNAL_MAX = -2048, 2047


class FormatError(Exception):
    """An image, a manifest or a WAV that is not what this module expects."""


def rate(pin7: str = PIN7) -> float:
    """The M6295 output rate in Hz with pin 7 in the given state."""
    return CLOCK / DIVISORS[pin7]


def wav_rate(pin7: str = PIN7) -> int:
    """The WAV header's sample rate: the M6295 rate rounded to whole Hz (7231 at pin 7 low)."""
    return round(rate(pin7))


# --- the manifest ------------------------------------------------------------------------------


@dataclass(frozen=True)
class Entry:
    """A phrase as the manifest names it."""

    number: int
    name: str

    @property
    def stem(self) -> str:
        return f"{self.number:02d}-{self.name}"


@dataclass(frozen=True)
class Manifest:
    entries: int  # table entries, entry 0 included
    phrases: list[Entry]


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


# The OKI tree's own labels (asm/oki/samples.asm and the include tools/adpcm asm writes): a
# sample name is a label alias next to them, so it may not be one of them.
RESERVED_LABEL = re.compile(r"phrase_\d+(_last)?|oki_\w*")


def reserved_label(name: str) -> bool:
    """True for a name the OKI tree defines itself: phrase_NN, phrase_NN_last and every oki_
    label (oki_phrases, oki_phrase_table, oki_phrase_table_end, oki_tail, oki_<chip>)."""
    return RESERVED_LABEL.fullmatch(name) is not None


def read_manifest(path: Path) -> Manifest:
    """The phrases data/oki/samples.json names, checked: numbered 1..n in order, unique label
    names that are not the tree's own, a table of n + 1 entries."""
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
    for i, p in enumerate(doc.get("phrases", []), 1):
        where = f"{path}: phrase {i}"
        if not isinstance(p, dict) or p.get("number") != i:
            raise FormatError(f"{where}: phrases must be numbered 1, 2, ... in order")
        name = p.get("name")
        if not isinstance(name, str) or not is_label(name) or name in names:
            raise FormatError(f"{where}: name {name!r} is not a unique label")
        if reserved_label(name):
            raise FormatError(
                f"{where}: name {name!r} is one of the OKI tree's own labels "
                "(phrase_NN, phrase_NN_last, oki_*)"
            )
        for key in ("start", "end", "length", "seconds"):
            if key in p:
                raise FormatError(
                    f"{where}: {key!r} is derived from the WAV lengths, not written in the manifest"
                )
        names.add(name)
        phrases.append(Entry(i, name))
    if len(phrases) != entries - 1:
        raise FormatError(f"{path}: {len(phrases)} phrases for {entries} table entries")
    return Manifest(entries, phrases)


def layout(manifest: Manifest, lengths: dict[int, int]) -> Layout:
    """Every phrase's start and end from the sample lengths in bytes: phrase 1 right after the
    table, each next one where the previous one ends. Fails on a sample under MIN_SAMPLE bytes
    (it would never play) and when the samples do not fit."""
    phrases = []
    start = manifest.entries * ENTRY
    for e in manifest.phrases:
        n = lengths[e.number]
        if n < 1:
            raise FormatError(f"phrase {e.number}: an empty sample")
        if n < MIN_SAMPLE:
            # okim6295_device::write starts a voice only when start < stop (okim6295.cpp:265)
            raise FormatError(
                f"phrase {e.number}: a sample of {n} byte would never play (the M6295 starts "
                "a voice only when its start lies before its end); a WAV needs at least 3 samples"
            )
        phrases.append(Phrase(e.number, e.name, start, start + n - 1))
        start += n
    if start > IMAGE_SIZE:
        raise FormatError(
            f"the samples end at {start - 1:05X}: {start - IMAGE_SIZE} bytes more than the "
            f"{IMAGE_SIZE // 1024} KB image holds (the last address is {IMAGE_SIZE - 1:05X}); "
            "shorten a WAV by twice that many samples"
        )
    return Layout(manifest.entries, phrases)


# --- the phrase table --------------------------------------------------------------------------


def encode_table(lay: Layout) -> bytes:
    """The table as the image holds it: entry 0 and bytes 6-7 of every entry zero."""
    out = bytearray(ENTRY)
    for p in lay.phrases:
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


def table_layout(image: bytes) -> tuple[int, list[tuple[int, int]]]:
    """The image's own table: the number of entries phrase 1's start implies (it starts right
    after the table) and every (start, end), each phrase starting where the previous one ends."""
    if len(image) != IMAGE_SIZE:
        raise FormatError(f"image is {len(image)} bytes, not {IMAGE_SIZE}")
    start1 = int.from_bytes(image[ENTRY : ENTRY + 3], "big")
    if start1 % ENTRY or not 2 * ENTRY <= start1 <= MAX_PHRASES * ENTRY:
        raise FormatError(f"phrase 1 starts at {start1:05X}: no table length explains it")
    entries = start1 // ENTRY
    if any(image[:ENTRY]):
        raise FormatError("phrase table entry 0 is not zero")
    spans = decode_table(image, entries)
    expect = start1
    for n, (s, e) in enumerate(spans, 1):
        if s != expect or e < s:
            raise FormatError(f"phrase {n} ({s:05X}-{e:05X}) does not follow at {expect:05X}")
        expect = e + 1
    return entries, spans


def check_image(image: bytes, lay: Layout) -> None:
    """Fail unless the image is exactly the layout's table, samples and zero tail."""
    if len(image) != IMAGE_SIZE:
        raise FormatError(f"image is {len(image)} bytes, not {IMAGE_SIZE}")
    table = encode_table(lay)
    for n in range(lay.entries):
        if image[n * ENTRY : n * ENTRY + ENTRY] != table[n * ENTRY : n * ENTRY + ENTRY]:
            got = decode_table(image, lay.entries)[n - 1] if n else None
            want = (lay.phrases[n - 1].start, lay.phrases[n - 1].end) if n else None
            detail = (
                f"{got[0]:05X}-{got[1]:05X} in the image, {want[0]:05X}-{want[1]:05X} from the "
                "WAVs"
                if got and want
                else "not the zero entry and padding the layout describes"
            )
            raise FormatError(f"phrase table entry {n}: {detail}")
    tail = lay.tail
    nonzero = [a for a in range(tail, IMAGE_SIZE) if image[a]]
    if nonzero:
        raise FormatError(
            f"{len(nonzero)} nonzero bytes after the last sample (first at {nonzero[0]:05X})"
        )


def split(image: bytes, lay: Layout) -> dict[int, bytes]:
    """Phrase number -> its sample bytes, after check_image."""
    check_image(image, lay)
    return {p.number: image[p.start : p.end + 1] for p in lay.phrases}


def build(lay: Layout, samples: dict[int, bytes]) -> bytes:
    """The image from the layout and the sample bytes (the inverse of split)."""
    out = bytearray(encode_table(lay))
    for p in lay.phrases:
        data = samples[p.number]
        if len(data) != p.length:
            raise FormatError(f"phrase {p.number}: {len(data)} bytes, the layout says {p.length}")
        out += data
    if len(out) > IMAGE_SIZE:
        raise FormatError(f"the samples end at {len(out):05X}, past the image")
    return bytes(out) + bytes(IMAGE_SIZE - len(out))


# --- WAV ---------------------------------------------------------------------------------------

WAVE_FORMAT_PCM = 0x0001
WAVE_FORMAT_EXTENSIBLE = 0xFFFE
# KSDATAFORMAT_SUBTYPE_PCM: the extensible header's sub-format GUID for integer PCM
SUBTYPE_PCM = bytes.fromhex("0100000000001000800000aa00389b71")


def chunk(tag: bytes, body: bytes) -> bytes:
    return tag + struct.pack("<I", len(body)) + body + (b"\0" if len(body) & 1 else b"")


def riff(chunks: list[bytes]) -> bytes:
    body = b"WAVE" + b"".join(chunks)
    return b"RIFF" + struct.pack("<I", len(body)) + body


def pcm_wav(values: list[int], pin7: str = PIN7) -> bytes:
    """16-bit PCM mono at the M6295 rate, a canonical 44-byte header (fmt, data) and nothing
    else: the file `tools/adpcm samples` writes and data/oki commits."""
    hz = wav_rate(pin7)
    fmt = struct.pack("<HHIIHH", WAVE_FORMAT_PCM, 1, hz, 2 * hz, 2, 16)
    return riff([chunk(b"fmt ", fmt), chunk(b"data", struct.pack(f"<{len(values)}h", *values))])


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


def read_wav(blob: bytes, pin7: str = PIN7) -> list[int]:
    """The 16-bit samples of a mono 16-bit PCM WAV at the M6295 rate (format tag 1, or the
    extensible header with the PCM sub-format, as editors write it); chunks other than fmt and
    data are skipped. Any 16-bit value is accepted: one the decoder cannot produce is an edit,
    which `encode` quantises. Rejects another format, channel count, sample size or rate, a
    missing or doubled fmt/data chunk, an odd data size and an empty sample."""
    found: dict[bytes, list[bytes]] = {}
    for tag, body in chunks(blob):
        found.setdefault(tag, []).append(body)
    for tag in (b"fmt ", b"data"):
        if len(found.get(tag, [])) != 1:
            raise FormatError(f"{len(found.get(tag, []))} {tag.decode().strip()!r} chunks, not 1")
    fmt = found[b"fmt "][0]
    if len(fmt) < 16:
        raise FormatError("fmt chunk shorter than 16 bytes")
    tag, channels, hz, _, align, bits = struct.unpack_from("<HHIIHH", fmt)
    if tag == WAVE_FORMAT_EXTENSIBLE:
        if len(fmt) < 40 or fmt[24:40] != SUBTYPE_PCM:
            raise FormatError("an extensible WAV whose sub-format is not integer PCM")
    elif tag != WAVE_FORMAT_PCM:
        raise FormatError(f"format tag 0x{tag:04X}, not 0x0001 (PCM)")
    if channels != 1 or bits != 16 or align != 2:
        raise FormatError(
            f"{channels} channels, {bits} bits, block align {align}: not mono 16-bit PCM"
        )
    if hz != wav_rate(pin7):
        raise FormatError(
            f"{hz} Hz, not {wav_rate(pin7)} Hz (the M6295's rate): resample it to "
            f"{wav_rate(pin7)} Hz, the chip plays every sample at that rate"
        )
    data = found[b"data"][0]
    if len(data) & 1:
        raise FormatError(f"a data chunk of {len(data)} bytes: not whole 16-bit samples")
    if not data:
        raise FormatError("no samples")
    return list(struct.unpack(f"<{len(data) // 2}h", data))


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
# per step index: (difference, next step index) for nibbles 0-15, and difference -> nibble (the
# 16 differences of a row are distinct: see `encode`)
ROWS = [
    [(DIFF[i * 16 + n], min(48, max(0, i + INDEX_SHIFT[n & 7]))) for n in range(16)]
    for i in range(49)
]
INVERSE = [{d: n for n, (d, _) in enumerate(row)} for row in ROWS]


def nibbles(data: bytes) -> list[int]:
    """The order okim_voice::generate_adpcm reads: the high nibble of each byte first."""
    out: list[int] = []
    for b in data:
        out += (b >> 4, b & 15)
    return out


def step(signal: int, index: int, nibble: int) -> tuple[int, int]:
    """oki_adpcm_state::clock: the new (signal, step index)."""
    d, index = ROWS[index][nibble]
    return min(SIGNAL_MAX, max(SIGNAL_MIN, signal + d)), index


def decode_nibbles(nibs: list[int], start: tuple[int, int] = (0, 0)) -> list[int]:
    """The decoder's outputs for a nibble sequence from a state (signal, step index)."""
    signal, index = start
    out: list[int] = []
    for n in nibs:
        signal, index = step(signal, index, n)
        out.append(signal)
    return out


def decode(data: bytes) -> list[int]:
    """The 12-bit outputs (-2048..2047) the M6295 produces for a sample, one per nibble, from
    the reset state (signal 0, step 0, as a voice starts: voice.m_adpcm.reset())."""
    return decode_nibbles(nibbles(data))


def pcm(data: bytes) -> list[int]:
    """The 16-bit PCM of a sample: decode x SCALE, what a WAV in data/oki holds."""
    return [SCALE * s for s in decode(data)]


# --- the encoder -------------------------------------------------------------------------------

Node = tuple[int, "Node"] | None  # a nibble history, newest first: (nibble, the history before)


def encode_nibbles(targets: list[int], start: tuple[int, int] = (0, 0)) -> list[int]:
    """The encoder's nibble for each 16-bit target, from a decoder state (signal, step
    index): the rule `encode` states, one nibble per value."""
    cands: list[tuple[int, int, Node]] = [(start[0], start[1], None)]
    for v in targets:
        if len(cands) == 1 and v % SCALE == 0:
            # the common case: one candidate and a value on the decoder's grid that one nibble
            # reaches exactly without clamping, so it is the only error-0 successor
            signal, index, node = cands[0]
            n = INVERSE[index].get(v // SCALE - signal)
            if n is not None and SIGNAL_MIN < v // SCALE < SIGNAL_MAX:
                cands = [(v // SCALE, ROWS[index][n][1], (n, node))]
                continue
        best = -1
        found: dict[tuple[int, int], Node] = {}
        for signal, index, node in cands:
            for n, (d, nxt) in enumerate(ROWS[index]):
                s = min(SIGNAL_MAX, max(SIGNAL_MIN, signal + d))
                err = abs(SCALE * s - v)
                if best < 0 or err < best:
                    best, found = err, {}
                if err == best and (s, nxt) not in found:
                    found[(s, nxt)] = (n, node)
        cands = [(s, i, node) for (s, i), node in found.items()]
    out: list[int] = []
    node = cands[0][2]
    while node is not None:
        out.append(node[0])
        node = node[1]
    out.reverse()
    return out


def encode(values: list[int]) -> bytes:
    """ADPCM bytes for 16-bit PCM values, by the rule docs/10 section 6 states and proves:

    The decoder state is (signal, step index), (0, 0) at the start. The encoder keeps a set of
    candidate states, each with one nibble history that reaches it; at first only (0, 0). For
    each value v in turn, every candidate and every nibble 0-15 gives a successor state, with
    the error |SCALE * signal - v|. The new candidates are the successors whose error is the
    smallest one this value allows (over all candidates and nibbles), one per distinct state,
    each with the lexicographically smallest history that reaches it (candidates are kept in
    history order and nibbles tried from 0 up, so the first successor found for a state is
    that one). After the last value the first candidate's history is the result. An odd number
    of values gets the last value once more, so the last byte has two nibbles.

    Properties (docs/10 section 6): for any PCM the decoder produced, `pcm(encode(v)) == v`;
    the bytes are the original ones unless some output is -2048 or 2047 (only a clamped output
    can be reached by two nibbles from one state), and then they are the lexicographically
    smallest bytes that decode to v. For any other PCM (an edit) each value is followed as
    closely as the rule allows, one value at a time (not a global optimum); `round_trip` gives
    the error. At most 98 candidates (two signals at the smallest distance x 49 step indices).
    """
    if not values:
        raise FormatError("no samples")
    out = encode_nibbles(list(values) + ([values[-1]] if len(values) & 1 else []))
    return bytes(out[i] << 4 | out[i + 1] for i in range(0, len(out), 2))


@dataclass(frozen=True)
class RoundTrip:
    """What decoding the encoder's bytes gives back, compared with the PCM it was given."""

    samples: int  # the PCM's length
    differ: int  # samples whose decoded value is not the PCM's
    max_error: int  # the largest |decoded - PCM|, in 16-bit units
    rms_error: float
    padded: bool  # an odd length: the last byte's second nibble repeats the last value

    @property
    def exact(self) -> bool:
        return self.differ == 0 and not self.padded


def round_trip(values: list[int], data: bytes) -> RoundTrip:
    back = pcm(data)
    errors = [abs(a - b) for a, b in zip(back, values, strict=False)]
    return RoundTrip(
        len(values),
        sum(e != 0 for e in errors),
        max(errors, default=0),
        math.sqrt(sum(e * e for e in errors) / len(errors)) if errors else 0.0,
        len(back) != len(values),
    )
