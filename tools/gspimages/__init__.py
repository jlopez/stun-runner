"""The packed GSP images of pairs U, V and W (060000-0C0000) and back (docs/15-gsp-images.md).

The region the 68010's `unpack_gsp_image` (0225E4) reads: 54 packed streams back to back
(tools/gspimages/stream.py), three checksum-adjust words between them, zero to 0BFE00, then the
image pointer table (0BFE00, 70 longs: entry 0 and entry 69 are 0, entries 58-64 placeholders
pointing at 060000, every other entry a stream; the 68010 indexes it by entry number, lea
$bfe00 at 022798 and nine `addi.l #$bfe00` sites, docs/06 section 4.2), and zero to 0C0000.

A stream decodes to a block of GSP memory the 68010 streams through HSTDATA: either one raw
screen (512 pixels per row, the row count from its length) or headed images back to back. A
headed image (docs/15 section 4) is a 12-byte header, four words and a long: its height, its
width, its size in bits as a GSP long (low word first; 16 x ceil(width x height / 2)) and a long
that is 0 in every image, then its pixels, then zero bytes to the next 32-bit boundary. Pixels
are bytes; in each big-endian word the unpacker writes, the low byte is the pixel at the lower
address, which the GSP (little-endian bit addressing) puts at the lower x.

The source (data/gsp-images): the manifest (streams in order, their entries, kinds and images
with their dimensions and palettes; the adjust words' places and the six chip sums the boot
self-test expects) and one indexed PNG per distinct image. The build (`asm`) takes the pixel
indices from the PNGs, re-encodes every stream (`stream.pack`), computes the adjust words from
the expected sums and writes the vasm includes of asm/68k/images.asm and image_table.asm. Every
derived field (header size and reserved long, padding, table pointers, stream addresses, the
stream's table and commands, the adjust words) is computed, never stored.

No message here carries a ROM byte: entry numbers, addresses, lengths and names only.
"""

from __future__ import annotations

import json
import re
import struct
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path

from gspimages import png
from gspimages.stream import StreamError, pack, unpack

FORMAT = "stunrun-gsp-images 1"
REGION = 0x060000  # first byte of pair U
TABLE = 0x0BFE00  # the image pointer table
TABLE_ENTRIES = 70
REGION_END = 0x0C0000
PAIR_SIZE = 0x20000
PAIRS = {"U": 0x060000, "V": 0x080000, "W": 0x0A0000}
RAW_WIDTH = 512  # a raw screen's row: the GSP's 512-pixel frame-buffer pitch (docs/15 4.1)
HEADER = 12
KINDS = ("raw", "headed")


class FormatError(ValueError):
    """Data that is not the format: a stream, a header, a manifest, a PNG, a palette."""


# --- images -----------------------------------------------------------------------------------


@dataclass(frozen=True)
class Image:
    width: int
    height: int
    pixels: bytes  # row-major, one index per pixel

    def __post_init__(self) -> None:
        if len(self.pixels) != self.width * self.height:
            raise FormatError(f"{len(self.pixels)} pixels for {self.width}x{self.height}")


def swap_pairs(data: bytes) -> bytes:
    """Decoded bytes <-> pixels: within each word the low (second) byte is the lower x."""
    out = bytearray(data)
    out[0 : len(out) - 1 : 2], out[1::2] = data[1::2], data[0 : len(data) - 1 : 2]
    return bytes(out)


def size_bits(width: int, height: int) -> int:
    """The header's size: the pixel bytes rounded up to a word, in bits."""
    return 16 * ((width * height + 1) // 2)


def headed_bytes(img: Image) -> bytes:
    """One headed image as the decoded stream holds it: header, pixels, padding."""
    if not (1 <= img.width <= 0xFFFF and 1 <= img.height <= 0xFFFF):
        raise FormatError(f"a {img.width}x{img.height} image does not fit the header")
    bits = size_bits(img.width, img.height)
    words = [img.height, img.width, bits & 0xFFFF, bits >> 16, 0, 0]
    body = img.pixels + bytes(bits // 8 - len(img.pixels))
    out = struct.pack(">6H", *words) + swap_pairs(body)
    return out + bytes(-len(out) % 4)


def raw_bytes(img: Image) -> bytes:
    if img.width != RAW_WIDTH:
        raise FormatError(f"a raw screen is {RAW_WIDTH} pixels wide, not {img.width}")
    return swap_pairs(img.pixels)


def split_headed(data: bytes, where: str) -> list[Image]:
    """The headed images of a decoded stream; fails on anything the format does not explain."""
    images: list[Image] = []
    p = 0
    while p < len(data):
        if p + HEADER > len(data):
            raise FormatError(f"{where}: a header runs past the stream at {p}")
        h, w, lo, hi, r0, r1 = struct.unpack(">6H", data[p : p + HEADER])
        bits = lo | hi << 16
        if not w or not h:
            raise FormatError(f"{where}: image {len(images)} is {w}x{h}")
        if bits != size_bits(w, h):
            raise FormatError(f"{where}: image {len(images)}'s size field is not 16 x ceil(w*h/2)")
        if r0 or r1:
            raise FormatError(f"{where}: image {len(images)}'s reserved long is not 0")
        n = bits // 8
        total = (HEADER + n + 3) // 4 * 4
        if p + total > len(data):
            raise FormatError(f"{where}: image {len(images)} runs past the stream")
        body = swap_pairs(data[p + HEADER : p + HEADER + n])
        if any(body[w * h :]) or any(data[p + HEADER + n : p + total]):
            raise FormatError(f"{where}: image {len(images)}'s padding is not zero")
        images.append(Image(w, h, body[: w * h]))
        p += total
    return images


def split_raw(data: bytes, where: str) -> Image:
    if not data or len(data) % RAW_WIDTH:
        raise FormatError(f"{where}: {len(data)} bytes is not whole {RAW_WIDTH}-pixel rows")
    return Image(RAW_WIDTH, len(data) // RAW_WIDTH, swap_pairs(data))


def stream_data(kind: str, images: Sequence[Image]) -> bytes:
    if kind == "raw":
        if len(images) != 1:
            raise FormatError("a raw stream holds exactly one screen")
        return raw_bytes(images[0])
    return b"".join(headed_bytes(i) for i in images)


# --- the manifest -----------------------------------------------------------------------------


@dataclass(frozen=True)
class Stream:
    entries: tuple[int, ...]  # table entries that point at it (ascending; the first names it)
    kind: str
    images: tuple[str, ...]

    @property
    def label(self) -> str:
        return f"gsp_image_{self.entries[0]:02d}"


@dataclass(frozen=True)
class Adjust:
    pair: str
    before_entry: int  # the adjust word sits right before this entry's stream


@dataclass(frozen=True)
class ChipSum:
    chip: str  # the ROM file name
    pair: str
    parity: int  # 0: even addresses (200x, the high byte), 1: odd (210x)
    sum: int
    evidence: str


@dataclass
class Manifest:
    streams: list[Stream]
    placeholders: list[int]
    adjust: list[Adjust]
    sums: list[ChipSum]
    images: dict[str, dict[str, object]] = field(default_factory=dict)

    def stream_order(self) -> list[Stream]:
        return sorted(self.streams, key=lambda s: s.entries[0])


LABEL = re.compile(r"[a-z][a-z0-9_]*\Z")


def entry_label(entry: int) -> str:
    """The label of an image table entry (M5d, docs/17 section 3): the code that reads one
    entry names it (`move.l gsp_image_entry_25,-(sp)`), not the table plus an offset."""
    return f"gsp_image_entry_{entry:02d}"


def adjust_label(pair: str) -> str:
    return f"gsp_images_sum_{pair.lower()}"


def check_manifest(m: Manifest) -> None:
    seen: dict[int, str] = {}
    for s in m.streams:
        if s.kind not in KINDS:
            raise FormatError(f"{s.label}: kind {s.kind!r}")
        if not s.entries or list(s.entries) != sorted(set(s.entries)):
            raise FormatError(f"stream entries {list(s.entries)} are not ascending and distinct")
        if not s.images or (s.kind == "raw" and len(s.images) != 1):
            raise FormatError(f"{s.label}: {len(s.images)} images for kind {s.kind}")
        for e in s.entries:
            if e in seen:
                raise FormatError(f"entry {e} is in two streams")
            seen[e] = s.label
        for name in s.images:
            if name not in m.images:
                raise FormatError(f"{s.label}: image {name!r} is not in the manifest's images")
    for e in m.placeholders:
        if e in seen:
            raise FormatError(f"entry {e} is a placeholder and a stream")
        seen[e] = "placeholder"
    want = set(range(1, TABLE_ENTRIES - 1))
    if set(seen) != want:
        missing = sorted(want - set(seen))
        extra = sorted(set(seen) - want)
        raise FormatError(f"table entries: missing {missing}, outside 1-68 {extra}")
    for name, info in m.images.items():
        if not LABEL.match(name):
            raise FormatError(f"image name {name!r}: lower case, digits and _ only")
        for k in ("width", "height"):
            if not isinstance(info.get(k), int) or not 1 <= int(info[k]) <= 0xFFFF:  # type: ignore[call-overload]
                raise FormatError(f"image {name}: {k} missing or out of range")
    if m.placeholders and not any(a.pair == "U" for a in m.adjust):
        raise FormatError("the placeholders point at the pair-U adjust word, which is missing")
    if sorted(a.pair for a in m.adjust) != sorted(PAIRS):
        raise FormatError("one adjust word per pair U, V, W")
    starts = {s.entries[0] for s in m.streams}
    for a in m.adjust:
        if a.before_entry not in starts:
            raise FormatError(f"adjust word {a.pair}: entry {a.before_entry} starts no stream")
    if sorted((c.pair, c.parity) for c in m.sums) != sorted((p, k) for p in PAIRS for k in (0, 1)):
        raise FormatError("one expected sum per chip of pairs U, V, W")


def read_manifest(path: Path) -> Manifest:
    try:
        raw = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as e:
        raise FormatError(f"{path}: {e}") from None
    if raw.get("format") != FORMAT:
        raise FormatError(f"{path}: format is not {FORMAT!r}")
    try:
        m = Manifest(
            streams=[
                Stream(tuple(s["entries"]), s["kind"], tuple(s["images"])) for s in raw["streams"]
            ],
            placeholders=list(raw["placeholders"]["entries"]),
            adjust=[Adjust(a["pair"], a["before_entry"]) for a in raw["adjust_words"]],
            sums=[
                ChipSum(c["chip"], c["pair"], c["parity"], int(c["sum"], 16), c["evidence"])
                for c in raw["chip_sums"]
            ],
            images=dict(raw["images"]),
        )
    except (KeyError, TypeError, ValueError) as e:
        raise FormatError(f"{path}: {e!r}") from None
    check_manifest(m)
    return m


def compact(text: str) -> str:
    """Put short lists of numbers or strings on one line."""

    def join(match: re.Match[str]) -> str:
        items = [x.strip() for x in match.group(1).split(",")]
        return "[" + ", ".join(items) + "]"

    return re.sub(r"\[\s*((?:(?:-?\d+|\"[^\"\n]*\")\s*,\s*)*(?:-?\d+|\"[^\"\n]*\"))\s*\]", join, text)


def manifest_json(m: Manifest, extra: Mapping[str, object] | None = None) -> str:
    doc: dict[str, object] = {"format": FORMAT}
    if extra:
        doc.update(extra)
    doc["streams"] = [
        {"entries": list(s.entries), "kind": s.kind, "images": list(s.images)}
        for s in m.stream_order()
    ]
    doc["placeholders"] = {
        "entries": m.placeholders,
        "comment": "table entries that point at the pair-U adjust word (060000), not at a stream",
    }
    doc["adjust_words"] = [{"pair": a.pair, "before_entry": a.before_entry} for a in m.adjust]
    doc["chip_sums"] = [
        {"chip": c.chip, "pair": c.pair, "parity": c.parity, "sum": f"{c.sum:02X}",
         "evidence": c.evidence}
        for c in m.sums
    ]
    doc["images"] = m.images
    return compact(json.dumps(doc, indent=2)) + "\n"


# --- palettes ---------------------------------------------------------------------------------


@dataclass(frozen=True)
class Palette:
    name: str
    address: int
    colors: tuple[tuple[int, int, int], ...]
    comment: str

    @property
    def count(self) -> int:
        return len(self.colors)

    def bytes(self) -> bytes:
        return bytes(c for rgb in self.colors for c in rgb)


def read_palette(path: Path) -> Palette:
    try:
        raw = json.loads(path.read_text())
        name, address, count = raw["name"], int(raw["address"], 16), int(raw["count"])
        colors = tuple((int(r), int(g), int(b)) for r, g, b in raw["colors"])
        comment = str(raw.get("comment", ""))
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ValueError) as e:
        raise FormatError(f"{path}: {e!r}") from None
    if name != path.stem or not LABEL.match(name):
        raise FormatError(f"{path}: name {name!r} must be the file's stem, a label")
    if count != len(colors) or not 1 <= count <= 256:
        raise FormatError(f"{path}: count {count}, {len(colors)} colours")
    if any(not 0 <= v <= 255 for rgb in colors for v in rgb):
        raise FormatError(f"{path}: a colour component outside 0-255")
    return Palette(name, address, colors, comment)


def palette_json(p: Palette) -> str:
    rows = ",\n".join(f"    [{r}, {g}, {b}]" for r, g, b in p.colors)
    return (
        "{\n"
        f'  "name": {json.dumps(p.name)},\n'
        f'  "address": "{p.address:06X}",\n'
        f'  "count": {p.count},\n'
        f'  "comment": {json.dumps(p.comment)},\n'
        f'  "colors": [\n{rows}\n  ]\n'
        "}\n"
    )


def read_palettes(folder: Path) -> dict[str, Palette]:
    return {p.stem: read_palette(p) for p in sorted(folder.glob("*.json"))}


GREY = [(i, i, i) for i in range(256)]


def compose(spec: Mapping[str, object], palettes: Mapping[str, Palette]) -> list[tuple[int, int, int]]:
    """An image's 256-entry PLTE from its manifest palette spec: the base palette (256 colours) or
    a grey ramp, with each overlay written over it at its index."""
    out = list(GREY)
    base = spec.get("base")
    if base is not None:
        if base not in palettes:
            raise FormatError(f"palette {base!r} is not in data/palettes")
        pb = palettes[str(base)]
        if pb.count != 256:
            raise FormatError(f"base palette {base} has {pb.count} colours, not 256")
        out = list(pb.colors)
    overlays = spec.get("overlays", [])
    assert isinstance(overlays, list)
    for ov in overlays:
        name, at = ov["name"], int(ov["at"], 16)
        if name not in palettes:
            raise FormatError(f"palette {name!r} is not in data/palettes")
        po = palettes[name]
        count = int(ov.get("count", po.count))
        if count > po.count or at + count > 256:
            raise FormatError(f"overlay {name}: {count} colours at {at:02X}")
        out[at : at + count] = po.colors[:count]
    return out


PALETTE_DIR = "palettes"  # under the includes' directory: one <name>.asm per palette


def palette_label(name: str) -> str:
    """The label game/island.asm gives a palette's first byte (decision of M5d, docs/17)."""
    return f"pal_{name}"


def palette_source(p: Palette) -> str:
    """One palette as the vasm include game/island.asm includes at its address (M5d, docs/17
    section 2): an assert at the palette's first and last byte, one `dc.b` of R, G, B per
    colour. The label is the including file's (`pal_<name>`), so a renamed palette fails the
    build at its include instead of moving a label."""
    end = p.address + 3 * p.count
    lines = [
        f"; palette {p.name}: {p.count} colours at 68k {p.address:06X}-{end - 1:06X}, generated by",
        "; tools/gspimages asm from data/palettes (docs/15 section 7, docs/17). Build output: do",
        "; not edit.",
        f'\tassert\t*=${p.address:06X},"palette {p.name} misplaced"',
    ]
    for k, (r, g, b) in enumerate(p.colors):
        lines.append(f"\tdc.b\t${r:02X},${g:02X},${b:02X}\t; {k:02X}")
    lines.append(f'\tassert\t*=${end:06X},"palette {p.name} does not end at {end:06X}"')
    return "\n".join(lines) + "\n"


def palette_sources(palettes: Mapping[str, Palette]) -> dict[str, str]:
    """file name (under PALETTE_DIR) -> source, for every palette of data/palettes."""
    return {f"{name}.asm": palette_source(p) for name, p in palettes.items()}


# --- the region -------------------------------------------------------------------------------


@dataclass
class Decoded:
    manifest: Manifest
    images: dict[str, Image]


def _table(image: bytes) -> list[int]:
    return list(struct.unpack(f">{TABLE_ENTRIES}L", image[TABLE : TABLE + 4 * TABLE_ENTRIES]))


def default_name(stream: Stream, k: int, n: int) -> str:
    first = stream.entries[0]
    if stream.kind == "raw":
        return f"screen_{first:02d}"
    return f"image_{first:02d}" if n == 1 else f"image_{first:02d}_{k:02d}"


def decode(image: bytes, sums_from: Sequence[ChipSum] | None = None) -> Decoded:
    """Read 060000-0C0000 of the 68k image as the format; fail on any byte it does not explain.
    A stream whose first header is not a valid image header is a raw screen (whole 512-pixel
    rows); the manifest then states the kind, so the build never guesses."""
    if len(image) < REGION_END:
        raise FormatError("the 68k image is shorter than 0C0000")
    table = _table(image)
    if table[0] or table[-1]:
        raise FormatError("entries 0 and 69 of the image table are not 0")
    by_addr: dict[int, list[int]] = {}
    placeholders = []
    for e in range(1, TABLE_ENTRIES - 1):
        if table[e] == REGION:
            placeholders.append(e)
        else:
            by_addr.setdefault(table[e], []).append(e)
    streams: list[Stream] = []
    images: dict[str, Image] = {}
    by_content: dict[tuple[int, int, bytes], str] = {}
    spans: list[tuple[int, int, int]] = []  # start, end, first entry
    for addr in sorted(by_addr):
        entries = by_addr[addr]
        try:
            u = unpack(image, addr)
        except StreamError as e:
            raise FormatError(str(e)) from None
        if u.tables != 1:
            raise FormatError(f"stream at {addr:06X} loads {u.tables} tables (only one is modelled)")
        if pack(u.data) != image[addr : u.end]:
            raise FormatError(f"stream at {addr:06X}: the encoder does not give its bytes back")
        spans.append((addr, u.end, entries[0]))
        where = f"stream at {addr:06X} (entry {entries[0]})"
        try:
            imgs = split_headed(u.data, where)
            kind = "headed"
        except FormatError:
            imgs = [split_raw(u.data, where)]
            kind = "raw"
        s0 = Stream(tuple(entries), kind, ())
        names = []
        for k, img in enumerate(imgs):
            key = (img.width, img.height, img.pixels)
            if key not in by_content:
                name = default_name(s0, k, len(imgs))
                by_content[key] = name
                images[name] = img
            names.append(by_content[key])
        streams.append(Stream(tuple(entries), kind, tuple(names)))
    # what lies between the streams: the adjust words, then zero to the table
    spans.sort()
    adjust: list[Adjust] = []
    at = REGION
    for start, end, first in spans:
        if start != at:
            if start - at != 2:
                raise FormatError(f"{start - at} unexplained bytes at {at:06X}")
            pair = pair_of(at)
            if any(a.pair == pair for a in adjust):
                raise FormatError(f"a second adjust word in pair {pair} at {at:06X}")
            adjust.append(Adjust(pair, first))
        at = end
    if any(image[at:TABLE]) or any(image[TABLE + 4 * TABLE_ENTRIES : REGION_END]):
        raise FormatError("the fills after the streams or after the table are not zero")
    sums = list(sums_from) if sums_from is not None else chip_sums_from_image(image)
    m = Manifest(streams, placeholders, adjust, sums,
                 {n: {"width": i.width, "height": i.height} for n, i in images.items()})
    check_manifest(m)
    return Decoded(m, images)


def pair_of(address: int) -> str:
    for p, base in PAIRS.items():
        if base <= address < base + PAIR_SIZE:
            return p
    raise FormatError(f"{address:06X} is outside pairs U-W")


# The boot self-test's ROM table (005FF6, 8 records of 18 bytes; record n covers pair R+n): +0 a
# word, 0 = skip; +2 the expected sum of the odd (210x) chip's bytes, compared at 0060F4; +3 the
# expected sum of the even (200x) chip's bytes, compared at 00615A; +4/+5 the error bits; +6 the
# pair's address (read at 0060C8, summed 0060D8-00614E).
SELFTEST_TABLE = 0x005FF6
SELFTEST_RECORD = 18
CHIP_NAMES = {
    ("U", 0): "136070-2108.200u", ("U", 1): "136070-2107.210u",
    ("V", 0): "136070-2110.200v", ("V", 1): "136070-2109.210v",
    ("W", 0): "136070-2112.200w", ("W", 1): "136070-2111.210w",
}


def chip_sums_from_image(image: bytes) -> list[ChipSum]:
    """The expected sums of the six chips, read from the self-test table (`make images` only)."""
    out = []
    for n, pair in enumerate(PAIRS, start=3):
        rec = SELFTEST_TABLE + n * SELFTEST_RECORD
        (start,) = struct.unpack(">L", image[rec + 6 : rec + 10])
        if start != PAIRS[pair] or not image[rec] | image[rec + 1]:
            raise FormatError(f"self-test record {n} is not pair {pair}")
        for parity, off, at in ((0, 3, "00615A"), (1, 2, "0060F4")):
            out.append(ChipSum(
                CHIP_NAMES[(pair, parity)], pair, parity, image[rec + off],
                f"boot self-test table 005FF6, record {n} (+6 = {start:06X}) byte +{off}, "
                f"compared with the chip's byte sum at {at}",
            ))
    return out


@dataclass(frozen=True)
class Placed:
    label: str
    address: int
    data: bytes  # the stream bytes, or b"" for an adjust word (its two bytes computed last)
    pair: str = ""


def place(m: Manifest, images: Mapping[str, Image]) -> tuple[list[Placed], int]:
    """Lay the streams out from 060000 in entry order with the adjust words before their entries;
    returns the placed items and the end of the last stream."""
    before = {a.before_entry: a.pair for a in m.adjust}
    at = REGION
    out: list[Placed] = []
    for s in m.stream_order():
        if s.entries[0] in before:
            pair = before[s.entries[0]]
            out.append(Placed(adjust_label(pair), at, b"", pair))
            at += 2
        data = stream_data(s.kind, [images[n] for n in s.images])
        packed = pack(data)
        out.append(Placed(s.label, at, packed))
        at += len(packed)
    if at > TABLE:
        raise FormatError(f"the streams end at {at:06X}, past the image table at {TABLE:06X}")
    for p in out:
        if p.pair and pair_of(p.address) != p.pair:
            raise FormatError(f"the pair-{p.pair} adjust word would sit at {p.address:06X}")
    return out, at


def table_values(m: Manifest, placed: Sequence[Placed]) -> list[int]:
    addr = {p.label: p.address for p in placed}
    values = [0] * TABLE_ENTRIES
    for s in m.streams:
        for e in s.entries:
            values[e] = addr[s.label]
    for e in m.placeholders:
        values[e] = addr[adjust_label("U")]
    return values


def build(m: Manifest, images: Mapping[str, Image]) -> tuple[bytes, list[Placed], int]:
    """060000-0C0000 as bytes (the adjust words computed), the placed items and the streams' end."""
    placed, end = place(m, images)
    region = bytearray(REGION_END - REGION)
    for p in placed:
        region[p.address - REGION : p.address - REGION + len(p.data)] = p.data
    tv = table_values(m, placed)
    region[TABLE - REGION : TABLE - REGION + 4 * TABLE_ENTRIES] = struct.pack(f">{TABLE_ENTRIES}L", *tv)
    sums = {(c.pair, c.parity): c.sum for c in m.sums}
    for p in placed:
        if not p.pair:
            continue
        base = PAIRS[p.pair] - REGION
        for k in (0, 1):
            a = p.address - REGION + k
            parity = (p.address + k) & 1
            region[a] = 0
            have = sum(region[base + parity : base + PAIR_SIZE : 2]) & 0xFF
            region[a] = (sums[(p.pair, parity)] - have) & 0xFF
    return bytes(region), placed, end


def chips(region: bytes) -> dict[str, bytes]:
    """The six ROM files of pairs U-W from 060000-0C0000."""
    out = {}
    for (pair, parity), name in CHIP_NAMES.items():
        base = PAIRS[pair] - REGION
        out[name] = region[base + parity : base + PAIR_SIZE : 2]
    return out


# --- the data folder --------------------------------------------------------------------------


def png_path(folder: Path, name: str) -> Path:
    return folder / f"{name}.png"


def read_images(folder: Path, m: Manifest, check_size: bool = True) -> dict[str, Image]:
    """The PNGs the manifest names, pixel indices only; with check_size a PNG whose dimensions
    differ from the manifest's fails (the 68k code holds them as constants, docs/15 section 6)."""
    out: dict[str, Image] = {}
    for name, info in m.images.items():
        path = png_path(folder, name)
        try:
            img = png.read(path.read_bytes())
        except OSError as e:
            raise FormatError(f"{path}: {e.strerror}") from None
        except png.PngError as e:
            raise FormatError(f"{path}: {e}") from None
        if check_size and (img.width, img.height) != (info["width"], info["height"]):
            raise FormatError(
                f"{path}: {img.width}x{img.height}, the manifest says "
                f"{info['width']}x{info['height']}: the 68k code holds image sizes and "
                "destinations as constants (docs/15-gsp-images.md section 6), so a size change "
                "is refused until that code is symbolic"
            )
        out[name] = Image(img.width, img.height, img.pixels)
    return out


def image_palette(m: Manifest, name: str, palettes: Mapping[str, Palette]) -> list[tuple[int, int, int]]:
    spec = m.images[name].get("palette", {})
    assert isinstance(spec, dict)
    return compose(spec, palettes)


def write_png(folder: Path, name: str, img: Image, plte: list[tuple[int, int, int]]) -> None:
    png_path(folder, name).write_bytes(png.write(img.width, img.height, img.pixels, plte))


# --- the vasm includes ------------------------------------------------------------------------


def _dcb(data: bytes, per: int = 16) -> list[str]:
    return [
        "\tdc.b\t" + ",".join(f"${b:02X}" for b in data[k : k + per]) for k in range(0, len(data), per)
    ]


def asm_sources(m: Manifest, images: Mapping[str, Image]) -> tuple[str, str]:
    """(build/gsp-images/images.asm, build/gsp-images/table.asm): the include of images.asm
    (060000 to the streams' end) and of image_table.asm (the 70 longs)."""
    region, placed, end = build(m, images)
    boundaries = sorted(b for b in PAIRS.values() if b != REGION)
    lines = [
        "; Pairs U-W, 060000 to the end of the last stream: generated by tools/gspimages asm from",
        "; data/gsp-images (docs/15-gsp-images.md). Build output: do not edit.",
    ]
    for p in placed:
        lines.append(f"{p.label}:")
        lines.append(f'\tassert\t*=${p.address:06X},"{p.label} misplaced"')
        if p.pair:
            v = region[p.address - REGION : p.address - REGION + 2]
            lines.append(
                f"\tdc.b\t${v[0]:02X},${v[1]:02X}\t; computed: the pair-{p.pair} chips' byte sums "
                "come out as the boot self-test expects (manifest chip_sums)"
            )
            continue
        s = next(s for s in m.streams if s.label == p.label)
        lines.append(
            f"; entries {', '.join(map(str, s.entries))}: {s.kind}, "
            + ", ".join(s.images)
        )
        a = p.address
        data = p.data
        cuts = [b - a for b in boundaries if a < b < a + len(data)]
        k = 0
        for cut in [*cuts, len(data)]:
            lines += _dcb(data[k:cut])
            if cut < len(data):
                lines.append(f'\tassert\t*=${a + cut:06X},"pair {pair_of(a + cut)} misplaced"')
            k = cut
    lines.append(f'\tassert\t*=${end:06X},"the streams do not end at {end:06X}"')
    lines.append(f"gsp_images_end:\t; {TABLE - end} bytes of zero follow to the table")
    for b in boundaries:
        if b >= end:
            raise FormatError(f"the streams end before pair {pair_of(b)}: not modelled")
    tv = table_values(m, placed)
    label_at = {p.address: p.label for p in placed}
    tl = [
        "; The image pointer table, 70 longs: generated by tools/gspimages asm from",
        "; data/gsp-images (docs/15-gsp-images.md). Build output: do not edit.",
    ]
    for e, value in enumerate(tv):
        target = label_at[value] if value else "0"
        tl.append(f"{entry_label(e)}:")
        tl.append(f"\tdc.l\t{target}\t; entry {e}")
    tl.append(f'\tassert\t*=${TABLE + 4 * TABLE_ENTRIES:06X},"the image table is not 70 longs"')
    return "\n".join(lines) + "\n", "\n".join(tl) + "\n"


def entries_of(m: Manifest) -> dict[str, list[int]]:
    """image name -> the table entries whose streams hold it."""
    out: dict[str, list[int]] = {}
    for s in m.streams:
        for n in s.images:
            out.setdefault(n, [])
            out[n] += [e for e in s.entries if e not in out[n]]
    return out


def ranges(values: Iterable[int]) -> str:
    v = sorted(set(values))
    out = []
    i = 0
    while i < len(v):
        j = i
        while j + 1 < len(v) and v[j + 1] == v[j] + 1:
            j += 1
        out.append(f"{v[i]}" if i == j else f"{v[i]}-{v[j]}")
        i = j + 1
    return ",".join(out)


REPO = Path(__file__).resolve().parents[2]


def write_palettes(out: Path, palettes: Mapping[str, Palette]) -> None:
    """Write <out>/palettes/<name>.asm for every palette (a file rewritten only when its text
    changes) and remove any other .asm there (a renamed or deleted palette)."""
    folder = out / PALETTE_DIR
    folder.mkdir(parents=True, exist_ok=True)
    sources = palette_sources(palettes)
    for name, text in sources.items():
        path = folder / name
        if not path.exists() or path.read_text() != text:
            path.write_text(text)
    for path in folder.glob("*.asm"):
        if path.name not in sources:
            path.unlink()


def write_includes(
    out: Path, data: Path = REPO / "data/gsp-images", palettes: Path = REPO / "data/palettes"
) -> bytes:
    """Write <out>/images.asm, <out>/table.asm and <out>/palettes/*.asm from the data (what
    `make` does, for the tests that assemble the 68k tree) and return 060000-0C0000 as the data
    builds it."""
    m = read_manifest(data / "manifest.json")
    images = read_images(data, m)
    images_src, table_src = asm_sources(m, images)
    out.mkdir(parents=True, exist_ok=True)
    (out / "images.asm").write_text(images_src)
    (out / "table.asm").write_text(table_src)
    write_palettes(out, read_palettes(palettes))
    return build(m, images)[0]
