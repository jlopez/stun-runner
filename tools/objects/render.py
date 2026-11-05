"""Pictures of the meshes in data/objects (docs/07-objects.md section 11): a verification aid.

Standard library only. An object is drawn in a parallel projection from one of a few fixed
views, its faces filled through a z-buffer, with the ADSP's own visibility rule: a face is drawn
when its stored normal points towards the viewer (PM 01A8-01A9: `read_face_normal` returns the
sign of normal . first vertex in camera space, >= 0 looks away and 01E4 skips the polygon; with
the viewer at infinity along the view direction d that is normal . d >= 0). Faces of colour 0 are
skipped as the ADSP skips them (019F -> 01E4). Edges are drawn darker, two-vertex faces as lines.

Colours: the face's colour field (0-63) indexes runtime GSP tables that are not in the
repository, so a picture uses a fixed made-up colour per index (`index_rgb`, a golden-ratio walk
round the hue circle), lit flatly from the stored normal for the faces the ADSP shades (type 15
and colour below 1Fh, 0214 at 01C7) and unlit for the others (type 1, colours 1Fh up), or the RGB
of a palette file (`--palette`, a JSON list of 64 [r, g, b]) if one is given. The pictures
therefore show shape, face order and which faces share a colour index, not the game's colours.

Every step is IEEE 754 arithmetic whose result the standard fixes: + - * /, int() and round(),
and one square root, math.sqrt, which IEEE 754 requires correctly rounded (no pow, sin or cos:
the view matrices are literals). So a picture is the same on every machine that follows it; `png_pixels` reads a PNG back to its pixel rows for the test that pins
the committed pictures.
"""

from __future__ import annotations

import json
import math
import struct
import zlib
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

from objects import TYPE_UNSHADED, Face, Mesh

Vec = tuple[float, float, float]
RGB = tuple[int, int, int]

# Object space as the data shows it (docs/07 section 11.1): x to the right, y up, z forwards (a
# left-handed frame): the vehicles point their noses at +z and the letters and signs read from
# -z, so the game's camera, behind the player's vehicle, looks along +z. A view is the three rows
# right, up and into-the-screen of a rotation matrix, as literals.
_C45 = 0.7071067811865476  # cos 45 = sin 45
_C30 = 0.8660254037844386  # cos 30
VIEWS: dict[str, tuple[Vec, Vec, Vec]] = {
    # From behind (-z), right (+x) and above: yaw 45 degrees, pitch 30 degrees down.
    "three-quarter": (
        (_C45, 0.0, _C45),
        (-0.5 * _C45, _C30, 0.5 * _C45),
        (-_C30 * _C45, -0.5, _C30 * _C45),
    ),
    # Looking along +z, as the game's camera does: the letters read here.
    "rear": ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)),
    # From above, looking down -y, +z up the picture.
    "top": ((1.0, 0.0, 0.0), (0.0, 0.0, 1.0), (0.0, -1.0, 0.0)),
    # From the right (+x), looking along -x, +z to the right.
    "side": ((0.0, 0.0, 1.0), (0.0, 1.0, 0.0), (-1.0, 0.0, 0.0)),
}

LIGHT: Vec = (-0.48, 0.64, -0.6)  # unit, from the upper left front; used only for the shading
BACKGROUND: RGB = (24, 26, 32)
LABEL: RGB = (230, 230, 230)
_GOLDEN = 0.6180339887498949


def index_rgb(colour: int) -> RGB:
    """The made-up colour of a colour index: hue (colour x golden ratio) mod 1, saturation 0.55,
    value 0.95 (an HSV to RGB conversion in plain arithmetic)."""
    h = (colour * _GOLDEN) % 1.0
    s, v = 0.55, 0.95
    i = int(h * 6.0)
    f = h * 6.0 - i
    p, q, t = v * (1.0 - s), v * (1.0 - s * f), v * (1.0 - s * (1.0 - f))
    r, g, b = [(v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q)][i % 6]
    return (round(r * 255), round(g * 255), round(b * 255))


def read_palette(path: Path) -> list[RGB]:
    """A palette file: a JSON list of 64 [r, g, b] (0-255), one per colour index. None is
    committed: a palette captured from MAME is ROM-derived runtime state (build/ only)."""
    data = json.loads(path.read_text())
    if not isinstance(data, list) or len(data) != 64:
        raise ValueError(f"{path}: expected a list of 64 [r, g, b]")
    out: list[RGB] = []
    for e in data:
        r, g, b = (int(c) for c in e)
        out.append((r, g, b))
    return out


def _dot(a: Sequence[float], b: Sequence[float]) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def face_visible(mesh: Mesh, face_index: int, view: str) -> bool:
    """The ADSP's rule (01A8-01A9) for a viewer at infinity: drawn when normal . d < 0, d the
    view direction (into the screen)."""
    return _dot(mesh.normals[mesh.faces[face_index].normal], VIEWS[view][2]) < 0


Winding = Literal["agrees", "reversed", "in-plane", "zero-area", "line"]


def winding(mesh: Mesh, face_index: int) -> Winding:
    """How the vertex order relates to the stored normal, by Newell's normal n of the vertex
    order (the right-hand-rule formula, exact in integers): "agrees" when n points the way of the
    stored normal (n . normal > 0), "reversed" the other way, "in-plane" when the face has area
    (n != 0) but the stored normal lies in its plane (n . normal = 0), "zero-area" when n = 0,
    "line" for a face of fewer than three vertices. In the left-handed object space "agrees"
    means the vertices run clockwise on screen when the face is drawn (seen from the side its
    normal points to). Only the sign of n . normal counts: a stored normal 54 degrees off (object
122 faces 12 and 15) still "agrees". The ADSP never uses the winding; docs/07 section 11.1
counts it and lists the faces whose stored normal is far from n."""
    f = mesh.faces[face_index]
    vs = [mesh.vertices[i] for i in f.vertices]
    if len(vs) < 3:
        return "line"
    nx = ny = nz = 0
    for i, a in enumerate(vs):
        b = vs[(i + 1) % len(vs)]
        nx += (a[1] - b[1]) * (a[2] + b[2])
        ny += (a[2] - b[2]) * (a[0] + b[0])
        nz += (a[0] - b[0]) * (a[1] + b[1])
    if nx == ny == nz == 0:
        return "zero-area"
    d = _dot((nx, ny, nz), mesh.normals[f.normal])
    return "agrees" if d > 0 else "reversed" if d < 0 else "in-plane"


@dataclass
class Canvas:
    width: int
    height: int
    pixels: bytearray  # RGB rows

    @classmethod
    def blank(cls, width: int, height: int, colour: RGB = BACKGROUND) -> Canvas:
        return cls(width, height, bytearray(bytes(colour) * (width * height)))

    def put(self, x: int, y: int, c: RGB) -> None:
        if 0 <= x < self.width and 0 <= y < self.height:
            o = 3 * (y * self.width + x)
            self.pixels[o : o + 3] = bytes(c)

    def blit(self, other: Canvas, x0: int, y0: int) -> None:
        for y in range(other.height):
            o = 3 * ((y0 + y) * self.width + x0)
            self.pixels[o : o + 3 * other.width] = other.pixels[
                3 * y * other.width : 3 * (y + 1) * other.width
            ]


def _shade(rgb: RGB, k: float) -> RGB:
    return (min(255, int(rgb[0] * k)), min(255, int(rgb[1] * k)), min(255, int(rgb[2] * k)))


def face_rgb(mesh: Mesh, face_index: int, palette: Sequence[RGB] | None = None) -> RGB:
    """The fill colour: the index's colour, times 0.35 + 0.65 max(0, n . light) / |n| for the
    faces the ADSP shades (type other than 1, colour below 1Fh: 0214 at 01C7), unlit otherwise."""
    f = mesh.faces[face_index]
    base = palette[f.colour] if palette else index_rgb(f.colour)
    if f.type == TYPE_UNSHADED or f.colour >= 0x1F:
        return base
    n = mesh.normals[f.normal]
    length = math.sqrt(_dot(n, n))  # correctly rounded (IEEE 754), unlike pow
    lit = max(0.0, _dot(n, LIGHT) / length) if length else 0.0
    return _shade(base, 0.35 + 0.65 * lit)


def render(
    mesh: Mesh,
    view: str = "three-quarter",
    size: int = 256,
    palette: Sequence[RGB] | None = None,
    cull: bool = True,
    edges: bool = True,
) -> Canvas:
    """One object, fitted to a size x size square with a margin."""
    right, up, into = VIEWS[view]
    pts = [(_dot(v, right), _dot(v, up), _dot(v, into)) for v in mesh.vertices]
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    span = max(max(xs) - min(xs), max(ys) - min(ys), 1.0)
    scale = (size - 8) / span
    cx = (max(xs) + min(xs)) / 2
    cy = (max(ys) + min(ys)) / 2
    half = size / 2
    # Screen: x right, y down; depth grows into the screen.
    scr = [(half + (p[0] - cx) * scale, half - (p[1] - cy) * scale, p[2] * scale) for p in pts]
    canvas = Canvas.blank(size, size)
    zbuf = [float("inf")] * (size * size)
    eps = 0.5  # a face later in ROM order wins a tie with a coplanar one (decals, stripes)
    lines: list[tuple[int, RGB]] = []
    for k, f in enumerate(mesh.faces):
        if f.colour == 0 or (cull and not face_visible(mesh, k, view)):
            continue
        rgb = face_rgb(mesh, k, palette)
        poly = [scr[i] for i in f.vertices]
        if len(poly) >= 3:
            _fill(canvas, zbuf, poly, rgb, eps)
        lines.append((k, rgb))
    if edges:
        for k, rgb in lines:
            poly = [scr[i] for i in mesh.faces[k].vertices]
            dark = rgb if len(poly) < 3 else _shade(rgb, 0.55)
            n = len(poly)
            for i in range(n if n > 2 else 1):
                _line(canvas, zbuf, poly[i], poly[(i + 1) % n], dark, eps + 1.0)
    return canvas


def _plane(poly: Sequence[Vec]) -> tuple[float, float, float] | None:
    """depth = a x + b y + c over the polygon's plane (Newell's normal in screen space), or None
    for a face seen edge-on."""
    nx = ny = nz = 0.0
    for i, p in enumerate(poly):
        q = poly[(i + 1) % len(poly)]
        nx += (p[1] - q[1]) * (p[2] + q[2])
        ny += (p[2] - q[2]) * (p[0] + q[0])
        nz += (p[0] - q[0]) * (p[1] + q[1])
    if abs(nz) < 1e-9:
        return None
    mx = sum(p[0] for p in poly) / len(poly)
    my = sum(p[1] for p in poly) / len(poly)
    mz = sum(p[2] for p in poly) / len(poly)
    a, b = -nx / nz, -ny / nz
    return a, b, mz - a * mx - b * my


def _fill(canvas: Canvas, zbuf: list[float], poly: Sequence[Vec], rgb: RGB, eps: float) -> None:
    """Even-odd scanline fill at pixel centres with a depth test (later faces win ties)."""
    plane = _plane(poly)
    if plane is None:
        return
    a, b, c = plane
    w, h = canvas.width, canvas.height
    y_lo = max(0, int(min(p[1] for p in poly) - 0.5))
    y_hi = min(h - 1, int(max(p[1] for p in poly) + 0.5))
    col = bytes(rgb)
    n = len(poly)
    for y in range(y_lo, y_hi + 1):
        yc = y + 0.5
        xs: list[float] = []
        for i in range(n):
            p, q = poly[i], poly[(i + 1) % n]
            if (p[1] <= yc < q[1]) or (q[1] <= yc < p[1]):
                xs.append(p[0] + (yc - p[1]) * (q[0] - p[0]) / (q[1] - p[1]))
        xs.sort()
        for j in range(0, len(xs) - 1, 2):
            x0 = max(0, int(xs[j] + 0.5))
            x1 = min(w - 1, int(xs[j + 1] - 0.5))
            for x in range(x0, x1 + 1):
                z = a * (x + 0.5) + b * yc + c
                k = y * w + x
                if z <= zbuf[k] + eps:
                    zbuf[k] = z
                    o = 3 * k
                    canvas.pixels[o : o + 3] = col


def _line(canvas: Canvas, zbuf: list[float], p: Vec, q: Vec, rgb: RGB, eps: float) -> None:
    steps = int(max(abs(q[0] - p[0]), abs(q[1] - p[1]))) + 1
    for i in range(steps + 1):
        t = i / steps
        x = int(p[0] + (q[0] - p[0]) * t)
        y = int(p[1] + (q[1] - p[1]) * t)
        if 0 <= x < canvas.width and 0 <= y < canvas.height:
            z = p[2] + (q[2] - p[2]) * t
            k = y * canvas.width + x
            if z <= zbuf[k] + eps:
                canvas.put(x, y, rgb)


# A 3 x 5 font for the labels: digits and the hyphen.
_DIGITS = {
    "0": "111101101101111",
    "1": "010110010010111",
    "2": "111001111100111",
    "3": "111001111001111",
    "4": "101101111001001",
    "5": "111100111001111",
    "6": "111100111101111",
    "7": "111001001001001",
    "8": "111101111101111",
    "9": "111101111001111",
    "-": "000000111000000",
}


def label(canvas: Canvas, text: str, x: int, y: int, scale: int = 2, rgb: RGB = LABEL) -> None:
    for ch in text:
        bits = _DIGITS[ch]
        for k, bit in enumerate(bits):
            if bit == "1":
                for dy in range(scale):
                    for dx in range(scale):
                        canvas.put(x + (k % 3) * scale + dx, y + (k // 3) * scale + dy, rgb)
        x += 4 * scale


def sheet(
    meshes: Mapping[int, Mesh],
    numbers: Sequence[int],
    view: str = "three-quarter",
    tile: int = 96,
    columns: int = 16,
    palette: Sequence[RGB] | None = None,
    cull: bool = True,
) -> Canvas:
    """A contact sheet: one tile per object, its number in the top left corner."""
    rows = (len(numbers) + columns - 1) // columns
    out = Canvas.blank(columns * tile, rows * tile, (8, 8, 10))
    for i, n in enumerate(numbers):
        t = render(meshes[n], view, tile - 2, palette, cull)
        x0 = (i % columns) * tile + 1
        y0 = (i // columns) * tile + 1
        out.blit(t, x0, y0)
        label(out, str(n), x0 + 2, y0 + 2)
    return out


def merged(meshes: Mapping[int, Mesh], numbers: Sequence[int]) -> Mesh:
    """Several objects as one mesh in their shared object space (the parts of a vehicle)."""
    out = Mesh(numbers[0], [], [], [])
    for n in numbers:
        m = meshes[n]
        nv, nn = len(out.vertices), len(out.normals)
        out.vertices += m.vertices
        out.normals += m.normals
        out.faces += [
            Face(f.type, f.colour, f.normal + nn, [i + nv for i in f.vertices]) for f in m.faces
        ]
    return out


GRID = ("three-quarter", "rear", "top", "side")  # view "all": left to right, top to bottom


def draw(
    meshes: Mapping[int, Mesh],
    numbers: Sequence[int],
    view: str = "three-quarter",
    size: int = 256,
    sheet_mode: bool = False,
    columns: int = 16,
    palette: Sequence[RGB] | None = None,
    cull: bool = True,
) -> Canvas:
    """What `tools/objects render` draws: a contact sheet, or the objects together in one view
    or in the 2 x 2 grid of GRID (view "all"), labelled with the first object's number."""
    if sheet_mode:
        if view == "all":
            raise ValueError("a sheet takes one view")
        return sheet(meshes, numbers, view, size, columns, palette, cull)
    mesh = merged(meshes, numbers)
    tag = str(numbers[0]) if len(numbers) == 1 else f"{numbers[0]}-{numbers[-1]}"
    tag = tag if "-" not in tag or numbers == list(range(numbers[0], numbers[-1] + 1)) else ""
    if view != "all":
        out = render(mesh, view, size, palette, cull)
    else:
        out = Canvas.blank(2 * size + 2, 2 * size + 2, (8, 8, 10))
        for k, v in enumerate(GRID):
            out.blit(
                render(mesh, v, size, palette, cull),
                1 + (k % 2) * (size + 1),
                1 + (k // 2) * (size + 1),
            )
    if tag:
        label(out, tag, 4, 4)
    return out


def parse_numbers(text: str) -> list[int]:
    """ "0", "0-7", "48,50-53": object numbers in the order given."""
    out: list[int] = []
    for part in text.split(","):
        lo, _, hi = part.partition("-")
        a, b = int(lo), int(hi or lo)
        if b < a:
            raise ValueError(f"empty range {part}")
        out += range(a, b + 1)
    return out


# The pictures docs/07 section 11 shows: file name -> the `render` arguments. `make pictures`
# writes them (tools/objects pictures) and tools/test_render.py regenerates each and compares
# its pixels with the committed file.
PICTURES: dict[str, str] = {
    "player-craft-0-7.png": "--view all --size 160 0-7",
    "tunnel-straight-48-49.png": "--sheet --tile 192 --columns 2 48-49",
    "signs-198-203.png": "--sheet --view rear --tile 128 --columns 6 198-203",
    "iris-204-211.png": "--sheet --view rear --tile 128 --columns 8 204-211",
    "contact-sheet.png": "--sheet --tile 64 --columns 24 0-412",
}


def picture_args(spec: str) -> dict[str, object]:
    """The keyword arguments of `draw` for a PICTURES entry (its `render` command line)."""
    words = spec.split()
    kw: dict[str, object] = {"numbers": parse_numbers(words[-1])}
    i = 0
    while i < len(words) - 1:
        w = words[i]
        if w == "--sheet":
            kw["sheet_mode"] = True
        elif w == "--no-cull":
            kw["cull"] = False
        elif w in ("--view", "--size", "--tile", "--columns"):
            key = w[2:]
            val = words[i + 1]
            kw["size" if key == "tile" else key] = val if key == "view" else int(val)
            i += 1
        else:
            raise ValueError(f"PICTURES: unknown argument {w}")
        i += 1
    return kw


def pictures(meshes: Mapping[int, Mesh]) -> dict[str, bytes]:
    out = {}
    for name, spec in PICTURES.items():
        kw = picture_args(spec)
        numbers = kw.pop("numbers")
        out[name] = png(draw(meshes, numbers, **kw))  # type: ignore[arg-type]
    return out


# --- PNG ------------------------------------------------------------------------------------


def _chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))


def png(canvas: Canvas) -> bytes:
    """An 8-bit PNG: indexed when the picture has at most 256 colours (smaller files), RGB
    otherwise; filter 0 on every row, zlib level 9."""
    w, h = canvas.width, canvas.height
    px = canvas.pixels
    colours: dict[bytes, int] = {}
    for o in range(0, len(px), 3):
        c = bytes(px[o : o + 3])
        if c not in colours:
            colours[c] = len(colours)
            if len(colours) > 256:
                break
    if len(colours) <= 256:
        order = sorted(colours)
        index = {c: i for i, c in enumerate(order)}
        rows = b"".join(
            b"\0" + bytes(index[bytes(px[o : o + 3])] for o in range(3 * w * y, 3 * w * (y + 1), 3))
            for y in range(h)
        )
        head = struct.pack(">IIBBBBB", w, h, 8, 3, 0, 0, 0)
        extra = _chunk(b"PLTE", b"".join(order))
    else:
        rows = b"".join(b"\0" + bytes(px[3 * w * y : 3 * w * (y + 1)]) for y in range(h))
        head = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
        extra = b""
    return (
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", head)
        + extra
        + _chunk(b"IDAT", zlib.compress(rows, 9))
        + _chunk(b"IEND", b"")
    )


def png_pixels(data: bytes) -> tuple[int, int, bytes]:
    """Width, height and the RGB rows of a PNG `png` wrote (8-bit, filter 0, RGB or indexed).
    The test compares these, not the compressed stream, which may differ between zlib builds."""
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    pos, idat, plte = 8, b"", b""
    w = h = ctype = 0
    while pos < len(data):
        (n,) = struct.unpack(">I", data[pos : pos + 4])
        kind, body = data[pos + 4 : pos + 8], data[pos + 8 : pos + 8 + n]
        pos += 12 + n
        if kind == b"IHDR":
            w, h, depth, ctype, _, filt, inter = struct.unpack(">IIBBBBB", body)
            if depth != 8 or ctype not in (2, 3) or filt or inter:
                raise ValueError("unsupported PNG")
        elif kind == b"PLTE":
            plte = body
        elif kind == b"IDAT":
            idat += body
    raw = zlib.decompress(idat)
    stride = 1 + (3 * w if ctype == 2 else w)
    out = bytearray()
    for y in range(h):
        row = raw[y * stride : (y + 1) * stride]
        if row[0] != 0:
            raise ValueError("unsupported PNG filter")
        if ctype == 2:
            out += row[1:]
        else:
            for i in row[1:]:
                out += plte[3 * i : 3 * i + 3]
    return w, h, bytes(out)
