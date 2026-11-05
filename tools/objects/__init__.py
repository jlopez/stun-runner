"""The ADSP object ROMs (384 KB, `build/stunrun-obj.bin`): their format, decoded and re-encoded.

Shared by `tools/objects` (the CLI: decode, asm, encode, inventory) and its tests. Standard
library only; nothing here prints a ROM word. docs/07-objects.md has the evidence: every rule
below is how the ADSP-2100 program reads the ROMs (PM addresses in brackets), checked against a
MAME trace of every object-ROM access (tools/mame/objtrace.lua).

The image is 0x30000 big-endian 16-bit words (byte offset / 2 = word index), three /MP pages of
0x10000 words (/MP DM 2007 sets the page, /SIMCLK DM 2001 the word address within it, each
/SIMBUF DM 2000 read returns a word and advances; harddriv_m.cpp:776-838).

    page 0  directory: one word per object, P = page << 14 | address >> 2 [009E-00A8], ended by
            FFFF; padding to a multiple of 4; objects
    page 1  the reciprocal table, words 0000-7FFF [04B2-04EA]; objects from 8000
    page 2  objects

An object, at a word address that is a multiple of 4 [00A5: the pointer is shifted left by 2]:

    header   points (= vertices + normals; not used by the ADSP: 011C reads it into I0 and 011F
             overwrites it), vertices [011F -> DM 0032], normals [0123 -> DM 08DA]
    vertices 3 words each, x y z signed [014C-0155, transformed by 0157-015C]
    normals  3 words each, x y z signed, typically of length about 0x4000 (not checked: some
             are not; docs/07 section 4) [0161-0172, rotated by 0169-0171]
    pointer  the address of the record list, the next word [read at 0172, sent to /SIMCLK 017B]
    records  2 words each: the address of the face's polygon, then type << 12 | count << 6 |
             colour [017F, 0182; JUMP (I4) at 0186 on the type through the table at 0187]; a
             record of type 0 ends the list (0187 RTS); here always 0000 0000
    polygons one per record in record order [01A7 sends the address to /SIMCLK]: the point
             number of the face normal [01EC], the point numbers of its vertices [01FC, 01B1],
             FFFF [01B2-01B3]; point n is DM 010A + 3n [01ED-01EF: MR0 + MR0 * 1 in fractional
             mode = 3n], so points are numbered from 1, vertices first, then normals

then zero padding to the next multiple of 4. After the last object of each page, at the next
multiple of 4, one checksum word: its high byte makes the even chip's byte sum and its low byte
the odd chip's byte sum, modulo 256, equal to the last two digits of the chip's part number read
as hex (136070-2121.90h sums to 0x21). The rest of the page is zero.

Mesh files use 0-based indices into `vertices` and `normals`; point numbers, the header's point
count, the record-list pointer, the polygon addresses, the end record, the FFFF terminators, the
padding, the directory and the checksum words are derived when encoding. Words the format does
not explain (a non-zero word where padding would be zero) are residue: they keep their place,
are never written into data/objects, and the generated assembly takes them from the ROM image
(an incbin slice: a blob in `make coverage`).
"""

from __future__ import annotations

import json
import struct
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, field
from pathlib import Path

FORMAT = "stunrun-objects 1"
IMAGE_WORDS = 0x30000
PAGE_WORDS = 0x10000
PAGES = 3
ALIGN = 4
TERMINATOR = 0xFFFF
MAX_OBJECTS = 0x1000  # the object number is masked with 0FFF [0056-0058]
CNTR_MAX = 0x3FFF  # vertex and normal counts are loaded into the 14-bit CNTR [014D, 015F]

# The reciprocal table the projection reads [04BB-04C5 /MP = 1, /SIMCLK = z, /SIMBUF]:
# z <= 0x200 takes the path at 04E0, which shifts the product left by 9.
RECIP_PAGE = 1
RECIP_WORDS = 0x8000
RECIP_SPLIT = 0x200
RECIP_NEAR = 1 << 15
RECIP_FAR = 1 << 24

# Chips per page, (even = high byte, odd = low byte), as tools/romsets/stunrun.json loads them.
CHIPS = (
    ("136070-2121.90h", "136070-2118.90k"),
    ("136070-2122.10h", "136070-2119.10k"),
    ("136070-2120.9h", "136070-2117.9k"),
)

# Record types [0187-0196]: 0 ends the list; 1 sets DM 0038 = 1 [0197-0198]: the face is not
# shaded (colour | 1000h at 01C9-01CC); 2-15 run through the NOPs to 0199 and are shaded from
# their normal by 0214 [01C7]. The ROM uses 1 and 15. Colour 0 skips the polygon [019F -> 01E4].
TYPE_UNSHADED = 1
TYPE_SHADED = 15


class FormatError(ValueError):
    pass


@dataclass
class Face:
    type: int  # 1-15
    colour: int  # 0-63
    normal: int  # index into normals
    vertices: list[int]  # indices into vertices


@dataclass
class Mesh:
    number: int
    vertices: list[tuple[int, int, int]]
    normals: list[tuple[int, int, int]]
    faces: list[Face]

    def words(self, address: int) -> list[int]:
        """The object's words when it starts at `address` (word address within its page)."""
        nv, nn = len(self.vertices), len(self.normals)
        out = [nv + nn, nv, nn]
        for v in self.vertices + self.normals:
            out += [c & 0xFFFF for c in v]
        records = address + len(out) + 1
        out.append(records & 0xFFFF)
        polygon = records + 2 * len(self.faces) + 2
        recs: list[int] = []
        polys: list[int] = []
        for f in self.faces:
            recs += [polygon & 0xFFFF, f.type << 12 | f.colour]
            poly = [nv + 1 + f.normal] + [1 + i for i in f.vertices] + [TERMINATOR]
            polys += poly
            polygon += len(poly)
        return out + recs + [0, 0] + polys

    def size(self) -> int:
        nv, nn = len(self.vertices), len(self.normals)
        return (
            4
            + 3 * (nv + nn)
            + 2 * len(self.faces)
            + 2
            + sum(len(f.vertices) + 2 for f in self.faces)
        )


@dataclass
class Residue:
    page: int
    address: int
    words: int


@dataclass
class Layout:
    """Where everything goes: per page the object numbers in ascending order (= address order;
    `place` and `decode` reject any other order)."""

    objects: int  # number of directory entries
    pages: list[list[int]]
    residue: list[Residue] = field(default_factory=list)


@dataclass(frozen=True)
class Placed:
    """An object as placed in the image."""

    number: int
    page: int
    address: int  # word address within the page
    size: int  # words, without the padding after it


def align(n: int) -> int:
    return (n + ALIGN - 1) // ALIGN * ALIGN


def s16(w: int) -> int:
    return w - 0x10000 if w & 0x8000 else w


def to_words(image: bytes) -> list[int]:
    if len(image) != 2 * IMAGE_WORDS:
        raise FormatError(f"object image is {len(image)} bytes, expected {2 * IMAGE_WORDS}")
    return list(struct.unpack(f">{IMAGE_WORDS}H", image))


def to_bytes(words: Sequence[int]) -> bytes:
    return struct.pack(f">{len(words)}H", *words)


def _f32(x: float) -> float:
    return float(struct.unpack("<f", struct.pack("<f", x))[0])


def reciprocal(z: int) -> int:
    """Entry z of the reciprocal table: 2^15 / z up to 0x200, 2^24 / z above, each rounded the
    way single-precision floats do it (quotient and + 0.5 in float32, then truncated), which
    reproduces the five entries a plain round() gets wrong (0x2F1, 0xAC9, 0xFD3, 0x205B,
    0x2F79). Entries 0 and 7FFF are 0."""
    if z <= 0 or z >= RECIP_WORDS - 1:
        return 0
    k = RECIP_NEAR if z <= RECIP_SPLIT else RECIP_FAR
    return int(_f32(_f32(k / z) + 0.5))


def reciprocal_table() -> list[int]:
    return [reciprocal(z) for z in range(RECIP_WORDS)]


def part_sum(chip: str) -> int:
    """The byte sum a chip is fudged to: the last two digits of its part number, read as hex."""
    digits = chip.split("-")[1].split(".")[0][-2:]
    return int(digits, 16)


def page_start(page: int, objects: int) -> int:
    """The first object address of a page: after the directory (and its terminator) on page 0,
    after the reciprocal table on page 1."""
    if page == 0:
        return align(objects + 1)
    if page == RECIP_PAGE:
        return RECIP_WORDS
    return 0


# --- decoding ---------------------------------------------------------------------------------


def _pointer(p: int) -> tuple[int, int]:
    return p >> 14, (p << 2) & 0xFFFF


def decode_object(words: Sequence[int], number: int, page: int, address: int) -> tuple[Mesh, int]:
    """The object at page:address, read as the ADSP reads it, and its size in words."""
    base = page * PAGE_WORDS

    def w(a: int) -> int:
        if not 0 <= a < PAGE_WORDS:
            raise FormatError(f"object {number}: runs off page {page}")
        return words[base + a]

    points, nv, nn = w(address), w(address + 1), w(address + 2)
    if nv == 0 or nn == 0:
        raise FormatError(f"object {number}: {nv} vertices, {nn} normals (a DO loop of 0)")
    if points != nv + nn:
        raise FormatError(f"object {number}: header point count is not vertices + normals")
    a = address + 3
    vertices = [
        (s16(w(a + 3 * i)), s16(w(a + 3 * i + 1)), s16(w(a + 3 * i + 2))) for i in range(nv)
    ]
    a += 3 * nv
    normals = [(s16(w(a + 3 * i)), s16(w(a + 3 * i + 1)), s16(w(a + 3 * i + 2))) for i in range(nn)]
    a += 3 * nn
    if w(a) != a + 1:
        raise FormatError(f"object {number}: the record list does not follow the header")
    r = a + 1
    records: list[tuple[int, int]] = []
    while True:
        r0, r1 = w(r), w(r + 1)
        r += 2
        if r1 >> 12 == 0:
            if (r0, r1) != (0, 0):
                raise FormatError(f"object {number}: end record is not 0000 0000")
            break
        if (r1 >> 6) & 0x3F:
            raise FormatError(f"object {number}: a record with a polygon count field")
        records.append((r0, r1))
    faces: list[Face] = []
    q = r
    for r0, r1 in records:
        if r0 != q:
            raise FormatError(f"object {number}: polygons are not in record order")
        n = w(q)
        if not nv < n <= nv + nn:
            raise FormatError(f"object {number}: a face normal is not a normal point")
        q += 1
        verts: list[int] = []
        while w(q) != TERMINATOR:
            if not 1 <= w(q) <= nv:
                raise FormatError(f"object {number}: a face vertex is not a vertex point")
            verts.append(w(q) - 1)
            q += 1
        q += 1
        if not verts:
            raise FormatError(f"object {number}: a face without vertices")
        faces.append(Face(r1 >> 12, r1 & 0x3F, n - nv - 1, verts))
    return Mesh(number, vertices, normals, faces), q - address


@dataclass
class Decoded:
    layout: Layout
    meshes: dict[int, Mesh]
    placed: list[Placed]


def decode(image: bytes) -> Decoded:
    """The whole image. Raises FormatError where it is not the format; non-zero words where
    padding would be zero become residue."""
    words = to_words(image)
    count = 0
    while words[count] != TERMINATOR:
        count += 1
        if count >= MAX_OBJECTS:
            raise FormatError("no directory terminator")
    expected = [0] * IMAGE_WORDS  # what the format alone predicts; residue = where they differ
    explained = [False] * IMAGE_WORDS
    for i in range(count + 1):
        expected[i] = words[i]
        explained[i] = True
    table = reciprocal_table()
    rb = RECIP_PAGE * PAGE_WORDS
    if words[rb : rb + RECIP_WORDS] != table:
        raise FormatError("page 1 does not start with the reciprocal table")
    for i in range(RECIP_WORDS):
        expected[rb + i] = table[i]
        explained[rb + i] = True
    by_page: dict[int, list[tuple[int, int]]] = {p: [] for p in range(PAGES)}
    for n in range(count):
        page, address = _pointer(words[n])
        if page >= PAGES:
            raise FormatError(f"object {n}: page {page}")
        by_page[page].append((address, n))
    meshes: dict[int, Mesh] = {}
    placed: list[Placed] = []
    pages: list[list[int]] = []
    for page in range(PAGES):
        entries = sorted(by_page[page])
        numbers = [n for _, n in entries]
        if numbers != sorted(numbers):
            raise FormatError(f"page {page}: objects are not in number order")
        a = page_start(page, count)
        base = page * PAGE_WORDS
        for address, n in entries:
            if address != a:
                raise FormatError(
                    f"object {n}: at {address:04X}, the packed layout puts it at {a:04X}"
                )
            mesh, size = decode_object(words, n, page, address)
            for i, v in enumerate(mesh.words(address)):
                expected[base + address + i] = v
                explained[base + address + i] = True
            meshes[n] = mesh
            placed.append(Placed(n, page, address, size))
            a = align(address + size)
        # the checksum word: computed after the residue is known, below
        if a >= PAGE_WORDS:
            raise FormatError(f"page {page}: no room for the checksum word")
        explained[base + a] = True
        pages.append(numbers)
    residue: list[Residue] = []
    i = 0
    while i < IMAGE_WORDS:
        if not explained[i] and words[i] != expected[i]:
            j = i
            while j < IMAGE_WORDS and not explained[j] and words[j] != expected[j]:
                j += 1
            residue.append(Residue(i // PAGE_WORDS, i % PAGE_WORDS, j - i))
            i = j
        else:
            i += 1
    layout = Layout(count, pages, residue)
    decoded = Decoded(layout, meshes, placed)
    rebuilt = encode_words(layout, meshes, image)
    if rebuilt != words:
        diff = sum(1 for x, y in zip(rebuilt, words, strict=True) if x != y)
        raise FormatError(f"{diff} words do not re-encode (checksum words or an unknown field)")
    return decoded


# --- encoding ---------------------------------------------------------------------------------


def place(layout: Layout, meshes: Mapping[int, Mesh]) -> list[Placed]:
    seen = [n for numbers in layout.pages for n in numbers]
    if sorted(seen) != list(range(layout.objects)):
        raise FormatError("the pages must list every object number 0..objects-1 exactly once")
    if layout.objects >= MAX_OBJECTS:
        raise FormatError(f"{layout.objects} objects: the ADSP masks object numbers with 0FFF")
    if len(layout.pages) != PAGES:
        raise FormatError(f"{len(layout.pages)} pages, expected {PAGES}")
    out: list[Placed] = []
    for page, numbers in enumerate(layout.pages):
        if numbers != sorted(numbers):
            raise FormatError(f"page {page}: objects must be in number order")
        a = page_start(page, layout.objects)
        for n in numbers:
            if n not in meshes:
                raise FormatError(f"object {n}: no mesh")
            size = meshes[n].size()
            out.append(Placed(n, page, a, size))
            a = align(a + size)
        if a >= PAGE_WORDS:
            raise FormatError(f"page {page}: the objects overflow the page")
    return out


def _is_int(v: object) -> bool:
    """A JSON integer: `type(v) is int` rules out floats (5.0) and booleans, which Python counts
    as ints (true would encode as 1, a colour false as 0, the hidden colour)."""
    return type(v) is int


def check_mesh(mesh: Mesh) -> None:
    def coords(rows: Iterable[tuple[int, int, int]], what: str) -> None:
        for row in rows:
            if len(row) != 3 or not all(_is_int(c) and -0x8000 <= c <= 0x7FFF for c in row):
                raise FormatError(f"object {mesh.number}: a {what} is not three 16-bit integers")

    # The vertex and normal counts are DO-loop counts (CNTR at 014D and 015F): the ADSP-2100's
    # counter is 14 bits, so a count above 3FFFh would be truncated, and a count of 0 does not
    # mean "no iterations" (MAME runs the body once, 2100ops.hxx slow_condition).
    if not mesh.vertices or not mesh.normals:
        raise FormatError(f"object {mesh.number}: needs at least one vertex and one normal")
    if len(mesh.vertices) > CNTR_MAX or len(mesh.normals) > CNTR_MAX:
        raise FormatError(f"object {mesh.number}: more than {CNTR_MAX} vertices or normals")
    coords(mesh.vertices, "vertex")
    coords(mesh.normals, "normal")
    for f in mesh.faces:
        fields = [f.type, f.colour, f.normal, *f.vertices]
        if not all(_is_int(v) for v in fields):
            raise FormatError(f"object {mesh.number}: a face field is not an integer")
        if not 1 <= f.type <= 15:
            raise FormatError(f"object {mesh.number}: face type {f.type} (1-15; 0 ends the list)")
        if not 0 <= f.colour <= 0x3F:
            raise FormatError(f"object {mesh.number}: face colour {f.colour} (0-63)")
        if not 0 <= f.normal < len(mesh.normals):
            raise FormatError(f"object {mesh.number}: face normal {f.normal} out of range")
        if not f.vertices or not all(0 <= v < len(mesh.vertices) for v in f.vertices):
            raise FormatError(f"object {mesh.number}: face vertices out of range or empty")


def encode_words(
    layout: Layout, meshes: Mapping[int, Mesh], residue_image: bytes | None = None
) -> list[int]:
    """The image's words. Residue words come from `residue_image` (zero without it, and then the
    checksum words of their pages are wrong)."""
    for mesh in meshes.values():
        check_mesh(mesh)
    placed = place(layout, meshes)
    words = [0] * IMAGE_WORDS
    for p in placed:
        words[p.number] = p.page << 14 | p.address >> 2
        base = p.page * PAGE_WORDS + p.address
        words[base : base + p.size] = meshes[p.number].words(p.address)
    words[layout.objects] = TERMINATOR
    rb = RECIP_PAGE * PAGE_WORDS
    words[rb : rb + RECIP_WORDS] = reciprocal_table()
    source = to_words(residue_image) if residue_image is not None else None
    for r in layout.residue:
        a = r.page * PAGE_WORDS + r.address
        if source is not None:
            words[a : a + r.words] = source[a : a + r.words]
    for page in range(PAGES):
        words[checksum_address(page, placed, layout)] = checksum(words, page, placed, layout)
    return words


def last_end(page: int, placed: Sequence[Placed], layout: Layout) -> int:
    on_page = [p for p in placed if p.page == page]
    if not on_page:
        return page_start(page, layout.objects)
    last = max(on_page, key=lambda p: p.address)
    return last.address + last.size


def checksum_address(page: int, placed: Sequence[Placed], layout: Layout) -> int:
    return page * PAGE_WORDS + align(last_end(page, placed, layout))


def checksum(words: Sequence[int], page: int, placed: Sequence[Placed], layout: Layout) -> int:
    at = checksum_address(page, placed, layout)
    rest = [
        w
        for i, w in enumerate(words[page * PAGE_WORDS : (page + 1) * PAGE_WORDS])
        if page * PAGE_WORDS + i != at
    ]
    even = sum(w >> 8 for w in rest) & 0xFF
    odd = sum(w & 0xFF for w in rest) & 0xFF
    hi = (part_sum(CHIPS[page][0]) - even) & 0xFF
    lo = (part_sum(CHIPS[page][1]) - odd) & 0xFF
    return hi << 8 | lo


def encode(layout: Layout, meshes: Mapping[int, Mesh], residue_image: bytes | None = None) -> bytes:
    return to_bytes(encode_words(layout, meshes, residue_image))


# --- data/objects: the manifest and one JSON file per mesh ------------------------------------


def mesh_name(number: int) -> str:
    return f"{number:03d}.json"


def _row(values: Iterable[int]) -> str:
    return "[" + ", ".join(str(v) for v in values) + "]"


def mesh_json(mesh: Mesh) -> str:
    lines = ["{", f'  "object": {mesh.number},', '  "vertices": [']
    lines += [f"    {_row(v)}," for v in mesh.vertices]
    lines[-1] = lines[-1].rstrip(",")
    lines += ["  ],", '  "normals": [']
    lines += [f"    {_row(v)}," for v in mesh.normals]
    lines[-1] = lines[-1].rstrip(",")
    lines += ["  ],", '  "faces": [']
    for f in mesh.faces:
        lines.append(
            f'    {{"type": {f.type}, "colour": {f.colour}, "normal": {f.normal}, '
            f'"vertices": {_row(f.vertices)}}},'
        )
    if mesh.faces:
        lines[-1] = lines[-1].rstrip(",")
    lines += ["  ]", "}"]
    return "\n".join(lines) + "\n"


def mesh_from_json(text: str) -> Mesh:
    try:
        d = json.loads(text)
        number = d["object"]
        vertices = [tuple(v) for v in d["vertices"]]
        normals = [tuple(v) for v in d["normals"]]
        faces = [Face(f["type"], f["colour"], f["normal"], list(f["vertices"])) for f in d["faces"]]
    except (ValueError, KeyError, TypeError) as e:
        raise FormatError(f"malformed mesh file: {e}") from e
    if not _is_int(number):
        raise FormatError(f"malformed mesh file: object number {number!r} is not an integer")
    for k in d:
        if k not in ("object", "vertices", "normals", "faces"):
            raise FormatError(f"object {number}: unknown key {k!r}")
    mesh = Mesh(number, vertices, normals, faces)
    check_mesh(mesh)
    return mesh


def manifest_json(layout: Layout, names: Mapping[int, str] | None = None) -> str:
    names = names or {}
    doc = {
        "format": FORMAT,
        "doc": "docs/07-objects.md; the format is tools/objects/__init__.py",
        "objects": layout.objects,
        "pages": [
            {"page": page, "chips": list(CHIPS[page]), "objects": numbers}
            for page, numbers in enumerate(layout.pages)
        ],
        "reciprocal_table": {
            "page": RECIP_PAGE,
            "words": RECIP_WORDS,
            "rule": "tools/objects reciprocal(): 2^15/z for z <= 0x200, 2^24/z above, float32",
        },
        "residue": [
            {"page": r.page, "address": f"{r.address:04X}", "words": r.words, "source": "ROM image"}
            for r in layout.residue
        ],
        "names": {str(n): names[n] for n in sorted(names)},
    }
    return compact_lists(json.dumps(doc, indent=2)) + "\n"


def compact_lists(text: str) -> str:
    """Put lists of numbers or strings on one line (json.dumps(indent) breaks every item)."""
    out: list[str] = []
    buf: list[str] | None = None
    for line in text.split("\n"):
        s = line.strip()
        if buf is not None:
            if s in ("]", "],"):
                out.append(buf[0] + "[" + ", ".join(x.rstrip(",") for x in buf[1:]) + s)
                buf = None
            elif s.startswith(("{", "[")):
                out += [buf[0] + "["] + ["  " + x for x in buf[1:]] + [line]
                buf = None
            else:
                buf.append(s)
            continue
        if s.endswith("[") and not s.startswith("{"):
            buf = [line[: len(line) - 1]]
            continue
        out.append(line)
    return "\n".join(out)


def layout_from_manifest(text: str) -> tuple[Layout, dict[int, str]]:
    try:
        d = json.loads(text)
        if d["format"] != FORMAT:
            raise FormatError(f"manifest format {d['format']!r}, expected {FORMAT!r}")
        pages = [list(p["objects"]) for p in d["pages"]]
        if [p["page"] for p in d["pages"]] != list(range(len(pages))):
            raise FormatError("manifest pages out of order")
        residue = [Residue(r["page"], int(r["address"], 16), r["words"]) for r in d["residue"]]
        names = {int(k): v for k, v in d.get("names", {}).items()}
        layout = Layout(d["objects"], pages, residue)
    except (ValueError, KeyError, TypeError) as e:
        if isinstance(e, FormatError):
            raise
        raise FormatError(f"malformed manifest: {e}") from e
    return layout, names


def write_data(out: Path, decoded: Decoded, names: Mapping[int, str] | None = None) -> None:
    out.mkdir(parents=True, exist_ok=True)
    for old in out.glob("[0-9][0-9][0-9].json"):
        old.unlink()
    (out / "manifest.json").write_text(manifest_json(decoded.layout, names))
    for n, mesh in sorted(decoded.meshes.items()):
        (out / mesh_name(n)).write_text(mesh_json(mesh))


def read_data(root: Path) -> tuple[Layout, dict[int, Mesh], dict[int, str]]:
    layout, names = layout_from_manifest((root / "manifest.json").read_text())
    meshes: dict[int, Mesh] = {}
    for n in range(layout.objects):
        path = root / mesh_name(n)
        if not path.exists():
            raise FormatError(f"{path}: missing")
        mesh = mesh_from_json(path.read_text())
        if mesh.number != n:
            raise FormatError(f"{path}: holds object {mesh.number}")
        meshes[n] = mesh
    expected = {mesh_name(n) for n in range(layout.objects)} | {"manifest.json"}
    extra = sorted(p.name for p in root.glob("*.json") if p.name not in expected)
    if extra:
        raise FormatError(f"{root}: files beyond the manifest's objects: {extra[:3]}")
    return layout, meshes, names


# --- generated assembly (vasm) ----------------------------------------------------------------


def _dcw(words: Sequence[int], per_line: int = 8) -> list[str]:
    return [
        "\tdc.w\t" + ",".join(f"${w:04X}" for w in words[i : i + per_line])
        for i in range(0, len(words), per_line)
    ]


def _fill(n: int) -> list[str]:
    return [f"\tdcb.w\t{n},0"] if n else []


def asm_pages(
    layout: Layout, meshes: Mapping[int, Mesh], residue_image: bytes | None, image_path: str
) -> list[str]:
    """One vasm source per page: dc.w for every decoded structure, dcb.w for the zero fill,
    incbin of `image_path` (as the main source sees it) for residue words."""
    words = encode_words(layout, meshes, residue_image)
    placed = place(layout, meshes)
    sources: list[str] = []
    for page in range(PAGES):
        base = page * PAGE_WORDS
        # (start, end, label, kind) over the page; kind: data / residue
        spans: list[tuple[int, int, str, str]] = []
        if page == 0:
            spans.append((0, layout.objects, "object_directory", "data"))
            spans.append((layout.objects, layout.objects + 1, "object_directory_end", "data"))
        if page == RECIP_PAGE:
            spans.append((0, RECIP_WORDS, "reciprocal_table", "data"))
        for p in placed:
            if p.page == page:
                spans.append((p.address, p.address + p.size, f"object_{p.number:03d}", "data"))
        ck = checksum_address(page, placed, layout) - base
        spans.append((ck, ck + 1, f"checksum_page{page}", "data"))
        for r in layout.residue:
            if r.page == page:
                spans.append(
                    (r.address, r.address + r.words, f"residue_{page}_{r.address:04X}", "residue")
                )
        spans.sort()
        lines = [
            f"; object ROM page {page} (words {base:05X}-{base + PAGE_WORDS - 1:05X}): generated by",
            "; tools/objects from data/objects (docs/07-objects.md). Build output: do not edit.",
        ]
        at = 0
        for start, end, label, kind in spans:
            if start < at:
                raise FormatError(f"page {page}: {label} overlaps the previous structure")
            lines += _fill(start - at)
            lines.append(f"{label}:")
            lines.append(f'\tassert\t*=${2 * (base + start):05X},"{label} misplaced"')
            if kind == "residue":
                lines.append(
                    f'\tincbin\t"{image_path}",${2 * (base + start):05X},{2 * (end - start)}'
                    "\t; residue: not explained by the format (docs/07)"
                )
            else:
                lines += _dcw(words[base + start : base + end])
            at = end
        lines += _fill(PAGE_WORDS - at)
        sources.append("\n".join(lines) + "\n")
    return sources


# --- the read sequences the ADSP makes (tools/mame/objtrace.lua) ------------------------------

# The /SIMCLK writes that start a read sequence, by ADSP PM address.
SEQ_DIRECTORY = 0x009E
SEQ_HEADER = 0x00A8
SEQ_RECORD = 0x017B
SEQ_POLYGON = 0x01A7
SEQ_RECIPROCAL = 0x04C2


def sequences(decoded: Decoded, image: bytes) -> dict[tuple[int, int, int], int]:
    """(pc, page, address) -> the number of words the ADSP reads from there, for every sequence
    the format predicts except the reciprocal reads (one word each, any z)."""
    words = to_words(image)
    out: dict[tuple[int, int, int], int] = {}
    for p in decoded.placed:
        mesh = decoded.meshes[p.number]
        nv, nn = len(mesh.vertices), len(mesh.normals)
        out[(SEQ_DIRECTORY, 0, p.number)] = 1
        out[(SEQ_HEADER, p.page, p.address)] = 4 + 3 * (nv + nn)
        records = p.address + 4 + 3 * (nv + nn)
        polygon = records + 2 * len(mesh.faces) + 2
        base = p.page * PAGE_WORDS
        for k, f in enumerate(mesh.faces):
            r = records + 2 * k
            if f.colour == 0:
                # 019F -> 01E4: reads on from the record list until an FFFF
                q = r + 2
                while words[base + q] != TERMINATOR:
                    q += 1
                out[(SEQ_RECORD, p.page, r)] = q + 1 - r
            else:
                out[(SEQ_RECORD, p.page, r)] = 2
                out[(SEQ_POLYGON, p.page, polygon)] = len(f.vertices) + 2
            polygon += len(f.vertices) + 2
        out[(SEQ_RECORD, p.page, records + 2 * len(mesh.faces))] = 2
    return out


@dataclass
class Inventory:
    number: int
    page: int
    address: int
    vertices: int
    normals: int
    faces: int
    lo: tuple[int, int, int]
    hi: tuple[int, int, int]


def inventory(decoded: Decoded) -> list[Inventory]:
    rows = []
    for p in sorted(decoded.placed, key=lambda p: p.number):
        m = decoded.meshes[p.number]
        xs, ys, zs = zip(*m.vertices, strict=True)
        lo = (min(xs), min(ys), min(zs))
        hi = (max(xs), max(ys), max(zs))
        rows.append(
            Inventory(
                p.number, p.page, p.address, len(m.vertices), len(m.normals), len(m.faces), lo, hi
            )
        )
    return rows


# The 68k's object descriptors (docs/07 section 3.2): `object_descriptor` (0x02ECF0) returns
# 0x048F9C + 20 x n for n < 13Ah (0x02ECF8-0x02ECFC); +0 is the near object, +2 the far object.
DESCRIPTORS = 0x048F9C
DESCRIPTOR_BYTES = 20
DESCRIPTOR_COUNT = 0x13A


def descriptors(image68k: bytes) -> list[tuple[int, int]]:
    """(near, far) object numbers, signed, of descriptors 0..13Ah-1 in the 68k image."""
    out = []
    for n in range(DESCRIPTOR_COUNT):
        a = DESCRIPTORS + DESCRIPTOR_BYTES * n
        near, far = struct.unpack(">hh", image68k[a : a + 4])
        out.append((near, far))
    return out


def descriptor_columns(descs: Sequence[tuple[int, int]], objects: int) -> dict[int, str]:
    """Per object 0..objects-1, the descriptors that select it: "d" where it is the near object
    of descriptor d, "df" where it is only the far object; "" where no descriptor names it.
    Negative object numbers (descriptor 313: -1, -1) select nothing."""
    near: dict[int, list[int]] = {}
    far: dict[int, list[int]] = {}
    for d, (n, f) in enumerate(descs):
        near.setdefault(n, []).append(d)
        if f != n:
            far.setdefault(f, []).append(d)
    return {
        o: ", ".join([str(d) for d in near.get(o, [])] + [f"{d}f" for d in far.get(o, [])])
        for o in range(objects)
    }


def far_name_problems(descs: Sequence[tuple[int, int]], names: Mapping[int, str]) -> list[str]:
    """The `_far` naming rule (docs/07 section 11.2) against the descriptor pairs: the far object
    of every descriptor whose near and far differ is named its near object's name + "_far", and
    no other object's name ends in "_far". Returns the violations (empty when the rule holds)."""
    problems = []
    far_of: dict[int, set[int]] = {}
    for n, f in descs:
        if n >= 0 and f >= 0 and f != n:
            far_of.setdefault(f, set()).add(n)
    for f, nears in sorted(far_of.items()):
        wanted = sorted(names[n] + "_far" for n in nears)
        if names.get(f) not in wanted:
            problems.append(f"{f} {names.get(f)}: want {' or '.join(wanted)}")
    for o, name in sorted(names.items()):
        if name.endswith("_far") and o not in far_of:
            problems.append(f"{o} {name}: ends in _far but is no descriptor's far object")
    return problems


def run_columns(summary: Mapping[str, object], objects: int) -> dict[int, str]:
    """Per object, the initials of the runs that loaded it (objtrace-attract -> A,
    objtrace-play -> P) in run order, or "-"."""
    loaded = [
        (str(r["run"]).removeprefix("objtrace-")[:1].upper(), set(r["objects_loaded"]))
        for r in summary["runs"]  # type: ignore[attr-defined]
    ]
    return {o: "".join(k for k, s in loaded if o in s) or "-" for o in range(objects)}


# --- the MAME trace (tools/mame/objtrace.lua, `make objtrace`) --------------------------------


@dataclass
class TraceRun:
    name: str
    header: dict[str, str]
    rows: list[tuple[int, int, int, int, int]]  # pc, page, address, reads, count


def read_trace(path: Path) -> TraceRun:
    header: dict[str, str] = {}
    rows: list[tuple[int, int, int, int, int]] = []
    for line in path.read_text().splitlines():
        if line.startswith("#"):
            parts = line[1:].split()
            if len(parts) == 2:
                header[parts[0]] = parts[1]
            continue
        pc, page, address, reads, count = line.split()
        rows.append((int(pc, 16), int(page), int(address, 16), int(reads), int(count)))
    return TraceRun(path.stem, header, rows)


def check_trace(decoded: Decoded, image: bytes, run: TraceRun) -> list[str]:
    """Every read sequence of the run against the decoder: it must start where the decoder has a
    structure of the kind the /SIMCLK write's PC reads, and read exactly the words the decoder
    says it has. Reciprocal reads: one word of the table, z in 1..7FFE. The problems found."""
    expected = sequences(decoded, image)
    problems: list[str] = []
    for pc, page, address, reads, count in run.rows:
        where = f"{run.name}: PC {pc:04X} page {page} {address:04X} ({count}x)"
        if pc == SEQ_RECIPROCAL:
            if page != RECIP_PAGE or not 0 < address < RECIP_WORDS - 1 or reads != 1:
                problems.append(f"{where}: {reads} reads outside the reciprocal table")
            continue
        want = expected.get((pc, page, address))
        if want is None:
            problems.append(f"{where}: no decoded structure of this kind starts here")
        elif want != reads:
            problems.append(f"{where}: read {reads} words, the decoder says {want}")
    # "open_at_end" (the sequence in flight when the run stopped, dropped by objtrace.lua because
    # it may be cut short) is not a problem and is not checked.
    for key in ("mp_inside_sequence", "orphan_reads"):
        if run.header.get(key, "0") != "0":
            problems.append(f"{run.name}: {key} {run.header[key]}")
    return problems


def trace_summary(decoded: Decoded, runs: Sequence[TraceRun]) -> dict[str, object]:
    """Addresses and counts only: per run and kind, the sequences and distinct start addresses;
    the objects each run loaded (directory reads); the objects no run loaded."""
    kinds = {
        SEQ_DIRECTORY: "directory",
        SEQ_HEADER: "header",
        SEQ_RECORD: "record",
        SEQ_POLYGON: "polygon",
        SEQ_RECIPROCAL: "reciprocal",
    }
    out: dict[str, object] = {"format": "objtrace summary 1", "doc": "docs/07-objects.md"}
    touched_all: set[int] = set()
    per_run = []
    for run in runs:
        stats = {}
        for pc, kind in kinds.items():
            rows = [r for r in run.rows if r[0] == pc]
            stats[kind] = {
                "sequences": sum(r[4] for r in rows),
                "start_addresses": len({(r[1], r[2]) for r in rows}),
                "words_read": sum(r[3] * r[4] for r in rows),
            }
        touched = sorted({r[2] for r in run.rows if r[0] == SEQ_DIRECTORY})
        touched_all.update(touched)
        z = [r[2] for r in run.rows if r[0] == SEQ_RECIPROCAL]
        per_run.append(
            {
                "run": run.name,
                "frames": int(run.header.get("frames", "0")),
                "play": run.header.get("play", "no"),
                "sequences": int(run.header.get("sequences", "0")),
                "open_at_end": int(run.header.get("open_at_end", "0")),
                "kinds": stats,
                "reciprocal_z": [f"{min(z):04X}", f"{max(z):04X}"] if z else [],
                "objects_loaded": touched,
            }
        )
    out["runs"] = per_run
    out["objects_loaded"] = len(touched_all)
    out["objects_never_loaded"] = sorted(set(decoded.meshes) - touched_all)
    return out


# --- the per-level runs (tools/mame/objlevels.lua, `make objlevels`) ----------------------------


@dataclass
class LevelRun:
    name: str
    header: dict[str, str]
    rows: list[tuple[int, int, int, int]]  # object, level word, first frame, count


def read_levels(path: Path) -> LevelRun:
    header: dict[str, str] = {}
    rows = []
    for line in path.read_text().splitlines():
        if line.startswith("#"):
            k, _, v = line[1:].strip().partition(" ")
            header[k] = v
        elif line.strip():
            o, lv, f, c = (int(x) for x in line.split())
            rows.append((o, lv, f, c))
    return LevelRun(path.stem, header, rows)


def levels_summary(objects: int, runs: Sequence[LevelRun]) -> dict[str, object]:
    """Counts and object numbers only: per run (one start level each) the frames, the writes the
    level select replaced, the first frame counted, and the objects loaded at each level word; then, per level, the
    objects loaded at it in any run, and the objects no run loaded (the objtrace runs aside)."""
    per_level: dict[int, set[int]] = {}
    out_runs = []
    for run in runs:
        levels: dict[int, set[int]] = {}
        for o, lv, _, _ in run.rows:
            levels.setdefault(lv, set()).add(o)
            per_level.setdefault(lv, set()).add(o)
        out_runs.append(
            {
                "run": run.name,
                "frames": int(run.header.get("frames", "0")),
                "start_level": int(run.header.get("start_level", "0")),
                "replaced_writes": int(run.header.get("replaced_writes", "0")),
                "counted_from": int(run.header.get("counted_from", "0")),
                "levels": {str(k): sorted(v) for k, v in sorted(levels.items())},
            }
        )
    loaded = set().union(*per_level.values()) if per_level else set()
    return {
        "format": "objlevels summary 1",
        "doc": "docs/07-objects.md section 11.4",
        "runs": out_runs,
        "levels": {str(k): sorted(v) for k, v in sorted(per_level.items())},
        "objects_loaded": len(loaded),
        "objects_never_loaded": sorted(set(range(objects)) - loaded),
    }


def _ranges(values: Iterable[int]) -> str:
    vs = sorted(set(values))
    out: list[str] = []
    i = 0
    while i < len(vs):
        j = i
        while j + 1 < len(vs) and vs[j + 1] == vs[j] + 1:
            j += 1
        out.append(str(vs[i]) if i == j else f"{vs[i]}-{vs[j]}")
        i = j + 1
    return ",".join(out)


def level_columns(summary: Mapping[str, object], objects: int) -> dict[int, str]:
    """Per object, the level words at which a level run loaded it ("0-3,7"), or "-"."""
    at: dict[int, set[int]] = {}
    for lv, objs in summary["levels"].items():  # type: ignore[attr-defined]
        for o in objs:
            at.setdefault(o, set()).add(int(lv))
    return {o: _ranges(at[o]) if o in at else "-" for o in range(objects)}
