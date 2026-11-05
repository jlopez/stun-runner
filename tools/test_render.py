"""The object pictures, the viewer page and the object names (tools/objects/render.py,
tools/objects/viewer.html, data/objects/manifest.json; docs/07-objects.md section 11).

Everything here runs in CI: the pictures are drawn from the committed data/objects, never from
the ROM image.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest
from objects import Face, Mesh, read_data
from objects.render import (
    PICTURES,
    VIEWS,
    Canvas,
    draw,
    face_visible,
    index_rgb,
    parse_numbers,
    pictures,
    png,
    png_pixels,
    render,
    winding,
)

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
DATA = REPO / "data/objects"
PICTURE_DIR = REPO / "artifacts/objects"


def quad(normal_z: int, colour: int = 5, type_: int = 15) -> Mesh:
    """A square in the plane z = 0, clockwise on screen in the rear view, its normal (0, 0, normal_z)."""
    v = [(-10, -10, 0), (-10, 10, 0), (10, 10, 0), (10, -10, 0)]
    return Mesh(0, v, [(0, 0, normal_z)], [Face(type_, colour, 0, [0, 1, 2, 3])])


def test_committed_pictures_are_the_meshes() -> None:
    """Every picture docs/07 shows is what `tools/objects pictures` draws from data/objects, pixel
    for pixel (the compressed stream is not compared: it may differ between zlib builds), and
    artifacts/objects holds no other picture."""
    _, meshes, _ = read_data(DATA)
    assert PICTURES, "no pictures declared"
    assert sorted(p.name for p in PICTURE_DIR.glob("*.png")) == sorted(PICTURES)
    for name, data in pictures(meshes).items():
        assert png_pixels((PICTURE_DIR / name).read_bytes()) == png_pixels(data), name


def test_pictures_are_small() -> None:
    assert sum((PICTURE_DIR / n).stat().st_size for n in PICTURES) < 400_000
    for n in PICTURES:
        assert (PICTURE_DIR / n).stat().st_size < 150_000, n


def test_picture_changes_with_the_mesh() -> None:
    """A planted vertex move changes the picture: the test above would catch a stale file."""
    _, meshes, _ = read_data(DATA)
    before = png_pixels(png(draw(meshes, [48], size=96)))
    m = meshes[48]
    x, y, z = m.vertices[0]
    m.vertices[0] = (x + 800, y + 800, z)
    assert png_pixels(png(draw(meshes, [48], size=96))) != before


def test_png_round_trip_indexed_and_rgb() -> None:
    small = Canvas.blank(5, 3, (1, 2, 3))
    small.put(4, 2, (200, 100, 50))
    assert png(small)[25] == 3  # indexed: colour type 3 in IHDR
    assert png_pixels(png(small)) == (5, 3, bytes(small.pixels))
    many = Canvas.blank(300, 1)
    for x in range(300):
        many.put(x, 0, (x % 256, x // 256, 7))
    assert png(many)[25] == 2  # more than 256 colours: RGB
    assert png_pixels(png(many)) == (300, 1, bytes(many.pixels))


def test_culling_follows_the_adsp() -> None:
    """01A8-01A9: a face is drawn when its stored normal points at the viewer. The rear view
    looks along +z, so a normal of -z faces it; the same square with a +z normal is culled, and
    drawn again with culling off. The winding plays no part (both squares wind the same way)."""
    towards, away = quad(-0x4000), quad(0x4000)
    assert face_visible(towards, 0, "rear") and not face_visible(away, 0, "rear")
    assert winding(towards, 0) == "agrees" and winding(away, 0) == "reversed"
    bg = render(quad(0x4000, colour=0), "rear", 32)  # colour 0: never drawn (019F)
    assert render(away, "rear", 32).pixels == bg.pixels
    assert render(towards, "rear", 32).pixels != bg.pixels
    assert render(away, "rear", 32, cull=False).pixels != bg.pixels


def test_winding_tells_an_in_plane_normal_from_a_zero_area_face() -> None:
    """A square whose stored normal lies in its plane has area but is "in-plane"; a face whose
    vertices are collinear is "zero-area"; a two-vertex face is a "line"."""
    v = [(-10, -10, 0), (-10, 10, 0), (10, 10, 0), (10, -10, 0), (0, 0, 0)]
    mesh = Mesh(
        0,
        v,
        [(0x4000, 0, 0)],
        [Face(15, 5, 0, [0, 1, 2, 3]), Face(15, 5, 0, [0, 4, 2]), Face(15, 5, 0, [0, 2])],
    )
    assert [winding(mesh, i) for i in range(3)] == ["in-plane", "zero-area", "line"]


def test_winding_counts_of_the_data() -> None:
    """docs/07 section 11.1's winding counts over data/objects: 6,531 faces agree with their
    stored normal, 5 are reversed, 2 (object 122, faces 11 and 16) have a stored normal in their
    plane, 2 are lines, none has zero area."""
    _, meshes, _ = read_data(DATA)
    by: dict[str, list[tuple[int, int]]] = {}
    for n, m in sorted(meshes.items()):
        for i in range(len(m.faces)):
            by.setdefault(winding(m, i), []).append((n, i))
    assert {k: len(v) for k, v in by.items()} == {
        "agrees": 6531,
        "reversed": 5,
        "in-plane": 2,
        "line": 2,
    }
    assert by["reversed"] == [(122, 10), (122, 17), (260, 37), (262, 37), (264, 36)]
    assert by["in-plane"] == [(122, 11), (122, 16)]


def test_unshaded_faces_keep_the_index_colour() -> None:
    """Type 1 faces (and colours 1Fh up) are not shaded (01C9-01CC, 0214): the fill is the index
    colour itself; a shaded face is darker or equal."""
    flat = render(quad(-0x4000, colour=9, type_=1), "rear", 32)
    centre = 3 * (16 * 32 + 16)
    assert tuple(flat.pixels[centre : centre + 3]) == index_rgb(9)
    lit = render(quad(-0x4000, colour=9), "rear", 32)
    assert all(a <= b for a, b in zip(lit.pixels[centre : centre + 3], index_rgb(9), strict=True))


def test_views_are_rotations() -> None:
    """Each view is an orthonormal right, up, into with right x up = into (no mirror of the
    left-handed object space)."""
    for name, (r, u, f) in VIEWS.items():
        for a in (r, u, f):
            assert abs(sum(c * c for c in a) - 1) < 1e-12, name
        cross = (r[1] * u[2] - r[2] * u[1], r[2] * u[0] - r[0] * u[2], r[0] * u[1] - r[1] * u[0])
        assert all(abs(c - d) < 1e-12 for c, d in zip(cross, f, strict=True)), name


def test_parse_numbers() -> None:
    assert parse_numbers("0") == [0]
    assert parse_numbers("0-3,7,9-10") == [0, 1, 2, 3, 7, 9, 10]
    with pytest.raises(ValueError):
        parse_numbers("5-4")


NAME = re.compile(r"^[a-z][a-z0-9_]*$")


def test_every_object_has_a_unique_label_name() -> None:
    """Final names (M3c): one per object 0-412, lowercase identifiers usable as 68k labels,
    unique; a name ending in _far has its near name (the descriptor pairs themselves are
    checked with the reference set: tools/test_objects.py::test_names_follow_the_descriptor_pairs,
    and the rule synthetically in test_far_name_rule)."""
    layout, _, names = read_data(DATA)
    assert sorted(names) == list(range(layout.objects))
    assert all(NAME.match(v) for v in names.values()), [
        v for v in names.values() if not NAME.match(v)
    ]
    assert len(set(names.values())) == len(names)
    for n, v in names.items():
        if v.endswith("_far"):
            assert v[:-4] in names.values(), (n, v)


def test_docs_table_names_are_the_manifest() -> None:
    """docs/07 section 10's name column is the manifest's (the full table needs the reference
    set: tools/test_objects.py::test_inventory_table_is_the_docs_table)."""
    _, _, names = read_data(DATA)
    doc = (REPO / "docs/07-objects.md").read_text().splitlines()
    rows = [line for line in doc if re.match(r"^\| \d+ \| \d \| [0-9A-F]{4} \|", line)]
    assert len(rows) == len(names)
    for line in rows:
        cells = [c.strip() for c in line.strip("|").split("|")]
        assert cells[-1] == names[int(cells[0])], line


def test_viewer_page_is_self_contained() -> None:
    """One external script, Three.js at a pinned cdnjs version; the data comes from the repo."""
    page = (TOOLS / "objects/viewer.html").read_text()
    scripts = re.findall(r'<script[^>]*src="([^"]+)"', page)
    assert scripts == ["https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"]
    assert "../../data/objects/" in page
    assert not re.findall(r'<link[^>]*href="http', page)
    json.loads((DATA / "manifest.json").read_text())  # the page reads it as JSON
