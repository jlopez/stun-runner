"""The object pictures, the viewer page and the object names (tools/objects/render.py,
tools/objects/viewer.html, data/objects/manifest.json; docs/07-objects.md section 11).

Everything here runs in CI: the pictures are drawn from the committed data/objects, never from
the ROM image.
"""

from __future__ import annotations

import json
import math
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
    plane, 2 are lines (310 and 336, face 0 each), none has zero area. The test is the sign
    of n . normal only (see the next test for the angle)."""
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
    assert by["line"] == [(310, 0), (336, 0)]


def _newell(m: Mesh, i: int) -> tuple[int, int, int]:
    vs = [m.vertices[k] for k in m.faces[i].vertices]
    nx = ny = nz = 0
    for k, a in enumerate(vs):
        b = vs[(k + 1) % len(vs)]
        nx += (a[1] - b[1]) * (a[2] + b[2])
        ny += (a[2] - b[2]) * (a[0] + b[0])
        nz += (a[0] - b[0]) * (a[1] + b[1])
    return nx, ny, nz


def _angle(u: tuple[int, int, int], v: tuple[int, int, int]) -> float:
    c = sum(a * b for a, b in zip(u, v, strict=True)) / math.hypot(*u) / math.hypot(*v)
    return math.degrees(math.acos(max(-1.0, min(1.0, c))))


def test_stored_normals_far_from_the_face_normal() -> None:
    """docs/07 section 11.1: the faces whose stored normal is more than 30 degrees from Newell's
    normal of the vertex order; object 122's left half (faces 10-17) carries the y-mirror of each
    face's own normal, its right half (0-9) agrees within a degree, and object 350's faces 15-20
    carry Newell's normal with y (and on 17-20 z) negated. The sign test of winding() calls
    12-15 of 122 and all of 350 "agrees"."""
    _, meshes, _ = read_data(DATA)
    far = []
    for n, m in sorted(meshes.items()):
        for i, f in enumerate(m.faces):
            if len(f.vertices) >= 3 and _angle(_newell(m, i), m.normals[f.normal]) > 30:
                far.append((n, i))
    assert far == [
        *((122, i) for i in (10, 11, 12, 15, 16, 17)),
        (260, 37),
        (262, 37),
        (264, 36),
        (264, 40),
        (350, 17),
        (350, 18),
    ]
    m = meshes[122]
    for i in range(10):
        assert _angle(_newell(m, i), m.normals[m.faces[i].normal]) < 1, i
    for i in range(10, 18):
        nx, ny, nz = _newell(m, i)
        stored = m.normals[m.faces[i].normal]
        assert _angle((nx, -ny, nz), stored) < 1, i
    assert [winding(m, i) for i in range(10, 18)] == [
        "reversed",
        "in-plane",
        *["agrees"] * 4,
        "in-plane",
        "reversed",
    ]
    m = meshes[350]
    for i in range(15, 21):
        nx, ny, nz = _newell(m, i)
        stored = m.normals[m.faces[i].normal]
        assert _angle((nx, -ny, -nz if i >= 17 else nz), stored) < 1, i
        assert winding(m, i) == "agrees", i


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


def coplanar(points: list[tuple[int, int, int]]) -> bool:
    """All points within one unit of one plane (the plane of the first three independent ones)."""
    p0 = points[0]
    d = [tuple(a - b for a, b in zip(p, p0, strict=True)) for p in points[1:]]
    for a in d:
        for b in d:
            n = (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])
            if any(n):
                size = math.sqrt(sum(c * c for c in n))
                return all(abs(sum(x * y for x, y in zip(n, p, strict=True))) <= size for p in d)
    return True


def test_shape_words_match_the_geometry() -> None:
    """The shape words in the names say what the mesh is, both ways (docs/07 section 11.2,
    reviews r5 and r6): every object of four non-coplanar corners and four triangles is a
    tetrahedron and every tetrahedron is one; every object of six corners, two triangles and
    three quadrilaterals is a prism, unless a proportion word (rod, slab: longest extent at least
    three times the middle one) or an identified role (the player craft's wings) names it, and
    every prism is one; a wedge is a solid of five to seven faces that is neither; a box has eight
    corners or more; a hexagon or an octagon has a face of six or eight vertices; a ring_round is
    circular in object space (equal x and y extents, centred on the z axis), a ring_oval is not;
    a panel (but a folded or framed one) is flat."""
    _, meshes, names = read_data(DATA)
    checked = 0
    tetrahedra, prisms = set(), set()
    for n, name in names.items():
        m = meshes[n]
        corners = sorted(set(m.vertices))
        sides = sorted(len(f.vertices) for f in m.faces)
        xs, ys = [v[0] for v in m.vertices], [v[1] for v in m.vertices]
        extents = sorted(max(v[i] for v in corners) - min(v[i] for v in corners) for i in range(3))
        is_tetrahedron = (
            len(corners) == 4
            and sides == [3, 3, 3, 3]
            and all(len({m.vertices[i] for i in f.vertices}) == 3 for f in m.faces)
            and not coplanar(corners)
        )
        is_prism = (len(corners), sides) == (6, [3, 3, 4, 4, 4])
        if is_tetrahedron:
            tetrahedra.add(n)
            assert name.startswith("tetrahedron_"), name
        if is_prism:
            prisms.add(n)
            if name.startswith(("rod_", "slab_")):
                assert extents[2] >= 3 * extents[1], name
            else:
                assert name.startswith(("prism_", "player_craft_wing_")), name
        if name.startswith("tetrahedron_"):
            assert is_tetrahedron, name
        elif name.startswith("prism_"):
            assert is_prism, name
        elif name.startswith("wedge_"):
            assert not is_tetrahedron and not is_prism and 5 <= len(m.faces) <= 7, name
        elif name.startswith("box_"):
            assert len(corners) >= 8, name
        elif "hexagon" in name:
            assert 6 in sides and 8 not in sides, name
        elif "octagon" in name:
            assert 8 in sides, name
        elif name.startswith("ring_round_"):
            assert (min(xs), max(xs)) == (min(ys), max(ys)) == (-max(xs), max(xs)), name
        elif name.startswith("ring_oval_"):
            assert max(xs) - min(xs) > 1.2 * (max(ys) - min(ys)), name
        elif name.startswith("panel_") and not name.startswith(("panel_folded", "panel_framed")):
            assert coplanar(corners), name
        else:
            continue
        checked += 1
    assert len(tetrahedra) == 28 and len(prisms) == 12
    assert checked == 79


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
