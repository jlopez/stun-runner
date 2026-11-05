"""The SOM display list decoder and the reference renderer (tools/displaylist.py, docs/08).

Synthetic tests run everywhere (CI): hand-built lists through the decoder, truncated and malformed
lists rejected, a GSP command buffer around a list, the clamp of a command-5 window, the renderer
on known shapes (the stipple phase at an odd row included), and the image-quad scaler on a made-up
image. The committed captures under artifacts/display-list/ (SOM lists as MAME's ADSP wrote them:
runtime RAM state) are decoded in CI too, and their polygons redrawn against a recorded checksum. The capture tests run on
`make somdump` output (build/mame/som/) and skip without it: every capture decodes with no word
unexplained, the rebuilt bank equals the 68k's view, the GSP buffer carries the same list, and the
redrawing equals MAME's frame buffer on every pixel it draws and misses none the list changed;
the dither-f* captures (a colour table whose words have two different bytes) pin the expander's
even/odd bytes for fills and outlines.
"""

from __future__ import annotations

import json
import re
import struct
import zlib
from pathlib import Path

import pytest
from displaylist import (
    END,
    FB_PAGE_BYTES,
    FLAG_LOOSE,
    FLAG_NO_RIGHT_EDGES,
    FLAG_OUTLINES,
    TOP,
    WIDTH,
    Canvas,
    Command,
    DisplayListError,
    Image,
    Segment,
    adsp_slope,
    capture_state,
    capture_window,
    compare,
    decode_gsp_buffer,
    decode_som,
    draw_image,
    draw_polygon,
    encode_som,
    field0_sign_extended,
    field_writers,
    read_images,
    read_meta,
    read_words,
    render,
    snapshot_agreement,
    synthetic_colours,
    window_of,
)

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
ARTIFACTS = REPO / "artifacts" / "display-list"
CAPTURES = REPO / "build" / "mame" / "som"

ONE = 1 << 16  # 1.0 in the 16.16 slopes


def triangle(cmd: int = 0x0130, top: int = 0x60) -> Command:
    """Apex at (100, top); the left edge one pixel left per row, the right one right, 10 rows."""
    return Command(0, cmd, 0, 100, 100, top, (Segment(0, ONE, -ONE, 11),))


def square(cmd: int = 0x0140) -> Command:
    return Command(0, cmd, 0, 10, 19, 0x40, (Segment(0, 0, 0, 10),))


def image(cmd: int = 0x1003) -> Command:
    return Command(0, cmd, 0, points=((10, 50), (40, 50), (40, 80), (10, 80)))


# ---------------------------------------------------------------------------------- the decoder


def test_round_trip_and_accounting():
    cmds = [triangle(), square(), image()]
    words = encode_som(cmds, order=[2, 0, 1])
    som = decode_som(words)
    assert som.words == len(words)
    assert som.last == len(words) - 1 and words[som.last] == END
    assert words[som.table_at] == END
    # header 2 + commands + separator 1 + table + end 1 = every word
    assert 2 + sum(c.length for c in som.commands) + 1 + len(som.order) + 1 == som.words
    drawn = som.draw_order()
    assert [c.cmd for c in drawn] == [0x1003, 0x0130, 0x0140]
    t = drawn[1]
    assert (t.left_x, t.right_x, t.top_y) == (100, 100, 0x60)
    assert t.segments[0].right_slope == ONE and t.segments[0].left_slope == -ONE
    assert drawn[0].is_image and drawn[0].points[2] == (40, 80)
    assert encode_som(som.commands, [som.commands.index(c) for c in drawn]) == words


def test_fields_of_the_command_word():
    c = Command(0, 0x8000 | 0x1000 | 0x0C00 | 0x2A5, 0)
    assert c.skipped and c.is_image and c.fill == 3 and c.colour == 0x2A5


def test_decoder_takes_a_whole_bank():
    words = encode_som([triangle()])
    bank = words + [0x1234] * (0x2000 - len(words))  # stale words after N are not the list's
    assert decode_som(bank).words == len(words)


@pytest.mark.parametrize("cut", [1, 3, 5, 9, 20])
def test_truncated_lists_are_rejected(cut):
    words = encode_som([triangle(), square()])
    with pytest.raises(DisplayListError):
        decode_som(words[: len(words) - cut])


def test_malformed_lists_are_rejected():
    good = encode_som([triangle(), square()])
    som = decode_som(good)

    def broken(k: int, v: int) -> list[int]:
        w = list(good)
        w[k] = v
        return w

    cases = {
        "N outside": broken(0, 0x2000),
        "T past N": broken(1, good[0]),
        "no separator": broken(som.table_at, 0),
        "no end marker": broken(som.last, 0),
        "entry to nowhere": broken(som.table_at + 1, 3),
        "entry twice": broken(som.table_at + 2, good[som.table_at + 1]),
        "segment into the table": broken(som.table_at - 1, 0),
        "FFFF as a command": broken(2, END),
    }
    for name, words in cases.items():
        with pytest.raises(DisplayListError):
            decode_som(words)
            pytest.fail(name)


def test_gsp_buffer_around_a_list():
    som_words = encode_som([triangle(), image()])
    header = [0] * 0x44
    text = [0x4013, 0, 0x40, 0xFD, 0x3A30, 0x3332, 0x0033]  # "0:233" and its NUL
    cmds = [0xD000, 0, 0, 0x28, 0, 0x5000, 0, 0x28, 0x1FF, 0xF7, 0x30F0, 0, 0xA0, 0x200, 0x58]
    pal = [0x9005, 3, 1, 2, 3, 4, 5]  # 3 colours: 3 + 2 words
    buf = header + cmds + pal + [0x7000] + som_words[1:] + text + [0xC001, 0x10, 2, 7, 8] + [0xF000]
    out = decode_gsp_buffer(buf + [0xDEAD] * 8)
    assert [c.code for c in out] == [0xD, 0x5, 0x3, 0x9, 0x7, 0x4, 0xC, 0xF]
    assert sum(c.length for c in out) == len(buf) - 0x44
    som = next(c.som for c in out if c.som)
    assert som is not None and som.order == decode_som(som_words).order


def test_gsp_buffer_errors():
    with pytest.raises(DisplayListError):
        decode_gsp_buffer([0] * 0x44 + [0xC000, 0xF0, 0x20] + [0] * 0x20)  # past 100h
    with pytest.raises(DisplayListError):
        decode_gsp_buffer([0] * 0x44 + [0x4013, 0, 1, 2, 0x4141])  # no NUL, no end
    for start, count in ((0x40, 0), (0x3F, 2)):  # E0 out of range: JAHI FFF40000 (FFF4A730/A7C0)
        with pytest.raises(DisplayListError):
            decode_gsp_buffer([0] * 0x44 + [0xE000, start, count] + [0] * 8 + [0xF000])
    for e in (0xE001, 0xE002, 0xE003):  # FFF47050 one call deeper: not a clean end
        with pytest.raises(DisplayListError):
            decode_gsp_buffer([0] * 0x44 + [e, 0xF000])
    ok = decode_gsp_buffer([0] * 0x44 + [0xE000, 0x3E, 2, 1, 2, 3, 4, 0xF000])
    assert [(c.code, c.length) for c in ok] == [(0xE, 7), (0xF, 1)]


def test_window_command_is_clamped(tmp_path):
    """Command 5 clamps x to 1FFh at most and y into 28h-117h (FFF47B60-FFF47DA0, unsigned)."""
    som_words = encode_som([square()])
    cmds = [0x5000, 5, 0x10, 0x250, 0x200, 0x5000, 0x300, 0x30, 0x40, 0x50]
    buf = [0] * 0x44 + cmds + [0x7000] + som_words[1:] + [0xF000]
    assert window_of(buf, 0x44) == (5, 0x28, 0x1FF, 0x117)
    assert window_of(buf, 0x49) == (0x1FF, 0x30, 0x40, 0x50)
    # a capture directory: the last command 5 before the list is the window it is drawn in
    (tmp_path / "cmdbuf.bin").write_bytes(struct.pack(f"<{len(buf)}H", *buf))
    (tmp_path / "meta.txt").write_text("FFF77F50 0440\n")
    assert capture_window(tmp_path) == (0x1FF, 0x30, 0x40, 0x50)
    buf[0x49 : 0x49 + 5] = [0x5000, 0, 0, 0xFFFF, 0xFFFF]
    (tmp_path / "cmdbuf.bin").write_bytes(struct.pack(f"<{len(buf)}H", *buf))
    assert capture_window(tmp_path) == (0, 0x28, 0x1FF, 0x117)


# --------------------------------------------------------------------------------- the renderer


def test_triangle_rows_and_widths():
    canvas = Canvas()
    draw_polygon(canvas, triangle(top=0x60), synthetic_colours())
    widths = []
    for r in range(0x60, 0x60 + 12):
        row = canvas.drawn[(r - TOP) * WIDTH : (r - TOP + 1) * WIDTH]
        widths.append(sum(row))
    # a count of 11 advances 10 rows: 11 rows of width 1, 3, 5, ... 21; nothing below
    assert widths == [1 + 2 * k for k in range(11)] + [0]


def test_expander_dither_and_stipple():
    colours = synthetic_colours()
    solid = Canvas()
    draw_polygon(solid, square(0x0140), colours)
    k = (0x40 - TOP) * WIDTH
    even, odd = solid.pixels[k + 10], solid.pixels[k + 11]
    assert even == colours[0x140] & 0xFF and odd == colours[0x140] >> 8
    quarter = Canvas()
    draw_polygon(quarter, square(0x0800 | 0x0140), colours)  # fill 2: one pixel in four
    assert sum(quarter.drawn) * 4 == sum(solid.drawn)
    three = Canvas()
    draw_polygon(three, square(0x0400 | 0x0140), colours)  # fill 1: three in four
    assert sum(three.drawn) * 4 == sum(solid.drawn) * 3


def test_stipple_phase_at_an_odd_row():
    """The pattern is rotated left by 4y bits at the top row (FFF45370-FFF45390) and by 4 after
    each row (FFF454F0); pixel x is written when bit 2x mod 16 is set. Top row y = 41h: 4y mod 32
    = 4."""
    colours = synthetic_colours()

    def columns(cmd: int) -> list[list[int]]:
        c = Canvas()
        draw_polygon(c, Command(0, cmd, 0, 10, 19, 0x41, (Segment(0, 0, 0, 10),)), colours)
        rows = (0x41, 0x42, 0x43)
        return [[x for x in range(WIDTH) if c.drawn[(y - TOP) * WIDTH + x]] for y in rows]

    # 25%: 01010101h rotated by 4, 8, 12: bits {4, 12}, {0, 8}, {4, 12} of the low half
    assert columns(0x0800 | 0x0140) == [[10, 14, 18], [12, 16], [10, 14, 18]]
    # 75%: 15151515h rotated by 4 = 51515151h (bits 0 4 6 8 12 14), then by 8 (0 2 4 8 10 12)
    assert columns(0x0400 | 0x0140)[:2] == [[10, 11, 12, 14, 15, 16, 18, 19],
                                             [10, 12, 13, 14, 16, 17, 18]]


def test_colour_byte_4_is_75_percent():
    """FFF45230-FFF452A0: fill 0 (via FFF45190) and fill 2 (after MOVI 01010101h) test the
    command's low byte; 4 loads 15151515h, three pixels in four. Top row 40h: no rotation, bits
    0 2 4 8 10 12 of 1515h, so x mod 8 in {0, 1, 2, 4, 5, 6}."""
    colours = synthetic_colours()
    k = (0x40 - TOP) * WIDTH

    def top_row(cmd: int) -> list[int]:
        c = Canvas()
        draw_polygon(c, square(cmd), colours)
        return [x for x in range(WIDTH) if c.drawn[k + x]]

    three = [10, 12, 13, 14, 16, 17, 18]
    assert top_row(0x0104) == top_row(0x0904) == top_row(0x0504) == three
    assert top_row(0x0105) == list(range(10, 20))  # another byte: solid
    assert top_row(0x0905) == [12, 16]  # ... and one in four (x mod 4 = 0)


def test_skipped_row_keeps_the_stipple_phase():
    """FFF454C0-FFF454F0: SUBXY sets V when xl > xr + 1 (MAME's SUB_XY: V = a.x > b.x) and JRV
    skips both the FILL and the RL 4 of B9; a row with xl = xr + 1 runs a FILL of width 0 (it
    draws nothing, 34010gfx.hxx `dx <= 0`) and rotates. 25% fill, top row 40h: x mod 4 = 0, then
    2 after one rotation, 0 after two."""
    colours = synthetic_colours()

    def rows(left_slope: int) -> list[list[int]]:
        # row 40h: 10..19; row 41h: xr + 1 = 10, xl = 10 + left_slope; row 42h: 10..19; no more
        segs = (Segment(0, -10 * ONE, left_slope * ONE, 2),
                Segment(0, 10 * ONE, -left_slope * ONE, 2))
        c = Canvas()
        draw_polygon(c, Command(0, 0x0940, 0, 10, 19, 0x40, segs), colours)
        return [[x for x in range(WIDTH) if c.drawn[(y - TOP) * WIDTH + x]]
                for y in (0x40, 0x41, 0x42, 0x43)]

    # xl = 15 > xr + 1 = 10: row 41h skipped and not rotated, row 42h has the second phase
    assert rows(5) == [[12, 16], [], [10, 14, 18], []]
    # xl = 10 = xr + 1: an empty FILL, rotated, row 42h back to the first phase
    assert rows(0) == [[12, 16], [], [12, 16], []]


def test_window_clips():
    c = Canvas(window=(0, 0x41, 14, 0x117))
    draw_polygon(c, square(), synthetic_colours())
    assert sum(c.drawn) == 9 * 5  # rows 41h-48h... of 10, columns 10-14


def test_outline_is_edges_only():
    colours = synthetic_colours()
    lo, hi = colours[0x140] & 0xFF, colours[0x140] >> 8
    assert lo != hi
    c = Canvas()
    draw_polygon(c, square(0x0C00 | 0x0140), colours)
    # top and bottom rows (10 each) and both sides (8 inner rows each)
    assert sum(c.drawn) == 10 + 10 + 2 * 8
    # the LINE pixels go through the 2 bpp expander as the fills do: the left edge (x = 10) gets
    # the low byte, the right edge (x = 19) the high byte (harddriv_v.cpp:300; MAME: dither-f*)
    for y in range(0x41, 0x49):
        k = (y - TOP) * WIDTH
        assert (c.pixels[k + 10], c.pixels[k + 19]) == (lo, hi), hex(y)


def test_header_flags_outline_every_polygon_and_drop_right_edges():
    """FFF77E60 bit 3 (`BTST 3h,A13` at FFF45130 -> draw_outline FFF45800) outlines a polygon
    whatever its fill, colour byte 4 included; bit 5 (`BTST 5h,A13` at FFF45B50) skips the right
    edges' LINEs; neither changes an image quad (bit 12 branches first, FFF450D0)."""
    colours = synthetic_colours()

    def drawn(cmd: int, flags: int) -> bytes:
        c = Canvas()
        draw_polygon(c, square(cmd), colours, flags)
        return bytes(c.drawn)

    outline = drawn(0x0C00 | 0x0140, 0)
    for cmd in (0x0140, 0x0540, 0x0940, 0x0104):
        assert drawn(cmd, FLAG_OUTLINES) == outline, hex(cmd)
        assert drawn(cmd, FLAG_NO_RIGHT_EDGES) == drawn(cmd, 0), hex(cmd)  # fills: no edges
    left = drawn(0x0C00 | 0x0140, FLAG_NO_RIGHT_EDGES)
    assert sum(left) == 10 + 10 + 8  # top and bottom rows, the left side only
    assert drawn(0x0140, FLAG_OUTLINES | FLAG_NO_RIGHT_EDGES) == left
    for y in range(0x41, 0x49):
        k = (y - TOP) * WIDTH
        assert left[k + 10] and not left[k + 19], hex(y)
    som = decode_som(encode_som([square(), quad(100, 0x50, 105, 0x54)]))
    plain = render(som, colours, images={3: PICTURE})
    flagged = render(som, colours, images={3: PICTURE}, flags=FLAG_OUTLINES)
    assert sum(plain.drawn) == 100 + 26 and sum(flagged.drawn) == 10 + 10 + 2 * 8 + 26


def test_bit_15_commands_are_not_drawn():
    """FFF450A0 `BTST Fh,A4` / `JRNE FFF44D50` (a RETS back to the table walk): a command with
    bit 15 set draws nothing, polygon or image quad, and the next one is drawn as usual."""
    colours = synthetic_colours()
    tri = triangle(0x8000 | 0x0130)
    som = decode_som(encode_som([tri, square(), quad(100, 0x50, 105, 0x54, cmd=0x9003)]))
    canvas = render(som, colours, images={3: PICTURE})
    assert canvas.skipped == 2 and canvas.images == 0
    alone = Canvas()
    draw_polygon(alone, square(), colours)
    assert bytes(canvas.drawn) == bytes(alone.drawn) and sum(canvas.drawn) == 100
    drawn_tri = Canvas()
    draw_polygon(drawn_tri, triangle(), colours)
    assert not any(a and b for a, b in zip(canvas.drawn, drawn_tri.drawn, strict=True))


def test_compare_counts():
    c = Canvas()
    draw_polygon(c, square(), synthetic_colours())
    page = bytes(c.pixels)
    before = bytes(FB_PAGE_BYTES)
    a = compare(c, page, before)
    assert a.drawn == a.equal == 100 and a.missed == 0
    wrong = bytearray(page)
    wrong[0] = 0x55  # a changed pixel the list did not draw
    assert compare(c, bytes(wrong), before).missed == 1


# A made-up 4 x 3 image (not the game's): pixel 0 is transparent (CONTROL E0h, T set).
PICTURE = Image(3, 4, bytes([1, 2, 3, 4,
                             5, 0, 7, 8,
                             9, 10, 11, 12]))


def quad(x0: int, y0: int, x1: int, y2: int, cmd: int = 0x1003) -> Command:
    """An image command: the box at p0, p1.x - p0.x + 1 wide and p2.y - p1.y + 1 high (here
    p1.y = p0.y, so its far corner is (x1, y2))."""
    return Command(0, cmd, 0, points=((x0, y0), (x1, y0), (x1, y2), (x0, y2)))


def test_image_quad_scaling():
    """FFF48FC0: a 6 x 5 box over the 4 x 3 image. Steps (DIVU, FFF496E0/FFF49760): u = 4 << 16
    / 6 = AAAAh, v = 3 << 16 / 5 = 9999h; each accumulator starts at one step (FFF49710,
    FFF49790), so the source columns are 0 1 1 2 3 3 and the rows 0 1 1 2 2 (from zero they would
    be 0 0 1 2 2 3 and 0 0 1 1 2)."""
    canvas = Canvas()
    assert draw_image(canvas, quad(100, 0x50, 105, 0x54), {3: PICTURE}, False)
    got = [[canvas.pixels[(y - TOP) * WIDTH + x] if canvas.drawn[(y - TOP) * WIDTH + x] else None
            for x in range(100, 106)] for y in range(0x50, 0x55)]
    assert got == [
        [1, 2, 2, 3, 4, 4],
        [5, None, None, 7, 8, 8],  # pixel 0: transparent, the page keeps its value
        [5, None, None, 7, 8, 8],
        [9, 10, 10, 11, 12, 12],
        [9, 10, 10, 11, 12, 12],
    ]
    assert sum(canvas.drawn) == 30 - 4


def test_image_quad_rejections():
    """FFF49230-FFF49650: no image, p0.x >= 200h, p0.y >= 117h, p1.x left of p0.x (FFF493D0),
    p2.y below 28h (FFF49510) or above p1.y (FFF49570), and, without FFF77E60 bit 4, a box 15Eh
    wide or C8h high or more. Zero-extended (the default, field 0 after a command 9 or 5), no
    corner is ever negative; the sign-extended reading is test_image_quad_sign_extended's."""
    images = {3: PICTURE}
    rejected = {
        "no image": quad(100, 0x50, 105, 0x54, cmd=0x1005),
        "x >= 200h": quad(0x200, 0x50, 0x205, 0x54),
        "y >= 117h": quad(100, 0x117, 105, 0x118),
        "far corner left": quad(100, 0x50, 99, 0x54),
        "far corner above": quad(100, 0x50, 105, 0x4E),
        "p2.y below 28h": quad(100, 0x20, 105, 0x27),
        "p2.y above p1.y": Command(0, 0x1003, 0, points=((100, 0x50), (105, 0x60), (105, 0x58))),
    }
    for name, c in rejected.items():
        canvas = Canvas()
        assert not draw_image(canvas, c, images, True), name
        assert not draw_image(canvas, c, images, False), name
        assert sum(canvas.drawn) == 0, name
    for c in (quad(0x10, 0x30, 0x10 + 0x15D, 0x31), quad(0x10, 0x30, 0x11, 0x30 + 0xC7)):
        assert not draw_image(Canvas(), c, images, False)  # the size limits
        assert draw_image(Canvas(), c, images, True)  # bit 4: none
    for c in (quad(0x10, 0x30, 0x10 + 0x15C, 0x31), quad(0x10, 0x30, 0x11, 0x30 + 0xC6)):
        assert draw_image(Canvas(), c, images, False)  # one less passes
    # the height is measured from p1.y, not p0.y: p0.y 60h, p1.y 50h, p2.y 58h is 6 x 9 from 60h
    canvas = Canvas()
    assert draw_image(canvas, Command(0, 0x1003, 0, points=((100, 0x60), (105, 0x50), (105, 0x58))),
                      images, False)
    assert {y for y in range(TOP, TOP + 240) for x in range(100, 106)
            if canvas.drawn[(y - TOP) * WIDTH + x]} == set(range(0x60, 0x69))
    # zero-extended (ST FE0 = 0), the corners are 16-bit unsigned: a p1.x of FFF0h is
    # never negative (the JRNN at FFF49390 is always taken), so the box is FF8Dh wide; only the
    # 15Eh limit rejects it, and with bit 4 it is drawn, clipped by the window to x 100-1FFh
    wide = quad(100, 0x50, 0xFFF0, 0x54)
    assert not draw_image(Canvas(), wide, images, False)
    canvas = Canvas()
    assert draw_image(canvas, wide, images, True)
    cols = {x for y in range(0x50, 0x55) for x in range(WIDTH)
            if canvas.drawn[(y - TOP) * WIDTH + x]}
    assert min(cols) == 100 and max(cols) == WIDTH - 1
    # a "negative" p0.x or p0.y reads as 8000h or more and fails the 200h/117h tests
    for c in (quad(0xFFF0, 0x50, 105, 0x54), quad(100, 0xFFF0, 105, 0x54)):
        assert not draw_image(Canvas(), c, images, True)
    som = decode_som(encode_som([quad(100, 0x50, 105, 0x54), quad(0x200, 0x50, 0x205, 0x54)]))
    canvas = render(som, synthetic_colours(), images=images)
    assert canvas.images == 1 and sum(canvas.drawn) == 26


def test_image_quad_sign_extended():
    """With ST FE0 = 1 (a list whose 7 no command 4, 5, 6, 8, 9, C or E0 precedes) the corners
    are read sign-extended: a p1.x of FFF0h is negative and rejected by the JRNN at FFF49390, and
    a p0.x or p0.y of FFF0h is -16, passes the 200h/117h tests and starts the box left of or
    above the window, which clips it."""
    images = {3: PICTURE}
    wide = quad(100, 0x50, 0xFFF0, 0x54)
    assert draw_image(Canvas(), wide, images, True)
    assert not draw_image(Canvas(), wide, images, True, sign_extended=True)
    left = quad(0xFFF0, 0x50, 5, 0x54)  # x -16..5: 22 columns, 6 of them in the window
    assert not draw_image(Canvas(), left, images, True)
    canvas = Canvas()
    assert draw_image(canvas, left, images, True, sign_extended=True)
    cols = {x for y in range(0x50, 0x55) for x in range(WIDTH)
            if canvas.drawn[(y - TOP) * WIDTH + x]}
    assert cols == set(range(0, 6))
    above = Command(0, 0x1003, 0, points=((100, 0xFFF0), (105, 0xFFF0), (105, 0x2A)))
    assert not draw_image(Canvas(), above, images, True)
    canvas = Canvas()
    assert draw_image(canvas, above, images, True, sign_extended=True)
    rows = {y for y in range(TOP, TOP + 240) for x in range(100, 106)
            if canvas.drawn[(y - TOP) * WIDTH + x]}
    assert rows == {0x28, 0x29, 0x2A}  # -16..2Ah, clipped to the window's top row 28h
    som = decode_som(encode_som([wide, left]))
    zero = render(som, synthetic_colours(), images=images, flags=FLAG_LOOSE)
    sign = render(som, synthetic_colours(), images=images, flags=FLAG_LOOSE, sign_extended=True)
    assert zero.images == 1 and sign.images == 1 and bytes(zero.drawn) != bytes(sign.drawn)


def test_field0_extension_through_the_buffer(tmp_path):
    """read_list_header (FFF4D990 `SETF 10h,1,0`) starts every list sign-extended; handlers 4,
    5, 6, 8, 9, C and E0 reset field 0 to zero-extended; 1, 2, 3, 7, A, B and D keep it."""
    som_words = [0x7000, *encode_som([square()])[1:]]
    header = [0] * 0x44
    rect = [0x30F0, 0, 0xA0, 0x200, 0x58]
    window = [0x5000, 0, 0x28, 0x1FF, 0x117]
    pal = [0x9001, 1, 5, 6]
    table = [0xE000, 0x3E, 1, 1, 2]
    cases = {
        "list first": ([], True),
        "D, 3, A, B first": ([0xD000, 0, 0, 0x28, 0, *rect, 0xA001, 0x10, 0xB000], True),
        "after 9": ([0xD000, 0, 0, 0x28, 0, *pal], False),
        "after 5": ([*window, *rect], False),
        "after E0": ([*table], False),
        "after C": ([0xC001, 0x10, 1, 7], False),
    }
    for name, (before, expected) in cases.items():
        buf = header + before + som_words + [0xF000]
        cmds = decode_gsp_buffer(buf)
        k = next(i for i, c in enumerate(cmds) if c.som is not None)
        assert field0_sign_extended(cmds, k) is expected, name
        (tmp_path / "cmdbuf.bin").write_bytes(struct.pack(f"<{len(buf)}H", *buf))
        (tmp_path / "meta.txt").write_text("FFF77F50 0440\n")
        assert capture_state(tmp_path)[1] is expected, name


# ------------------------------------------------------------------ committed captures (CI too)


def committed() -> list[Path]:
    return sorted(ARTIFACTS.glob("*.som"))


def test_artifacts_present():
    assert len(committed()) >= 2


@pytest.mark.parametrize("path", committed(), ids=lambda p: p.stem)
def test_committed_captures_decode_and_redraw(path):
    som = decode_som(read_words(path))
    assert som.words * 2 == path.stat().st_size  # nothing after the end marker
    expected = json.loads((ARTIFACTS / "expected.json").read_text())[path.stem]
    assert len(som.commands) == expected["commands"]
    canvas = render(som, synthetic_colours(), tuple(expected["window"]))
    # no images in CI (the game's data): the image quads are the commands left undrawn, and the
    # scaler is test_image_quad_scaling's
    assert canvas.images == sum(c.is_image for c in som.commands) and canvas.skipped == 0
    masked = bytes(p if d else 0 for p, d in zip(canvas.pixels, canvas.drawn, strict=True))
    assert sum(canvas.drawn) == expected["drawn"]
    assert zlib.crc32(masked) == expected["crc32_synthetic_colours"]


def test_slopes_are_the_adsps_reciprocal_products():
    """docs/08 section 1.3: every slope in the committed captures is adsp_slope(dx, dy) for some
    |dx| <= 1FFh and dy 1-1FFh, and some are not trunc(dx * 10000h / dy) for any: the reciprocal
    is truncated before the multiply (05F1, 0601-0603)."""
    assert adsp_slope(1, 3) == 0x5554 and adsp_slope(37, 3) == 0x000C5524
    assert adsp_slope(-1, 1) == -0x10000 and adsp_slope(-3, 0x41) == (-3 * 2 * 0x7E07) >> 6
    seen = {v for path in committed() for c in decode_som(read_words(path)).commands
            for s in c.segments for v in (s.right_slope, s.left_slope)}
    pairs = [(dx, dy) for dx in range(-0x1FF, 0x200) for dy in range(1, 0x200)]
    assert seen <= {adsp_slope(dx, dy) for dx, dy in pairs}
    assert seen - {int(dx * 0x10000 / dy) for dx, dy in pairs}


# --------------------------------------------------------------- `make somdump` captures (local)


def captures() -> list[Path]:
    return sorted(p for p in CAPTURES.glob("*/") if (p / "som.bin").exists())


# docs/08 section 1.1: the ADSP instructions whose SOMLATCH writes store each field
WRITERS = {
    "header N": {0x00BE}, "header T": {0x00C0}, "separator FFFF": {0x00B5},
    "table entry": {0x0828}, "end FFFF": {0x082B}, "command word": {0x0515, 0x066A},
    "polygon xl": {0x0565}, "polygon xr": {0x0567}, "polygon y": {0x056B},
    "right slope low": {0x0580, 0x05A0, 0x05BA}, "right slope high": {0x0582, 0x05A2, 0x05BC},
    "left slope low": {0x0584, 0x05A4, 0x05BE}, "left slope high": {0x0586, 0x05A6, 0x05C0},
    "segment count": {0x0588, 0x05A8, 0x05C2},
    "command end FFFF FFFF": {0x05D2, 0x05D4, 0x0680, 0x0682},
    "image x": {0x0678}, "image y": {0x067A},
}
IMAGE_WRITERS = {"command word": 0x066A, "command end FFFF FFFF": 0x0680,
                 "image x": 0x0678, "image y": 0x067A}


@pytest.mark.skipif(not captures(), reason="no captures: run make somdump (needs MAME and ROMs)")
def test_captures_against_mame():
    seen: dict[str, set[int]] = {}
    dithered: set[tuple[str, int, bool]] = set()
    for d in captures():
        words = read_words(d / "som.bin")
        som = decode_som(words)
        assert read_words(d / "som68k.bin")[: som.words] == words[: som.words], d
        meta = read_meta(d / "meta.txt")
        buf = read_words(d / "cmdbuf.bin")
        cmds = decode_gsp_buffer(buf, int(meta["FFF77F50"], 16))
        lists = [c.som for c in cmds if c.som is not None]
        assert len(lists) == 1 and lists[0].order == som.order, d
        assert lists[0].commands == som.commands, d
        window, sign_extended = capture_state(d)
        # every capture's 7 follows a 9 and a 5 (FFF48C30, FFF47B20): field 0 zero-extended
        assert not sign_extended, d
        images = read_images((d / "images.bin").read_bytes())
        flags = int(meta["FFF77E60"], 16)
        colours = read_words(d / "colors.bin")
        canvas = render(som, colours, window, images, flags, sign_extended)
        a = compare(canvas, (d / "fb_som.bin").read_bytes(), (d / "fb_pre.bin").read_bytes())
        assert a.drawn > 0 and a.equal == a.drawn, (d, a)
        assert a.missed == 0, (d, a)
        if d.name.startswith("dither-"):
            # SOM_DITHER: every word's bytes differ, so the comparison tests the expander's
            # even/odd bytes; it must cover fills and outlines at both parities
            assert all(c & 0xFF != c >> 8 for c in colours), d
            page = (d / "fb_som.bin").read_bytes()
            for c in som.commands:
                if c.is_image:
                    continue
                word = colours[c.colour]
                kind = "outline" if c.fill == 3 else "fill"
                one = Canvas(window)
                draw_polygon(one, c, colours)
                for m in re.finditer(b"\x01", bytes(one.drawn)):
                    k = m.start()
                    if page[k] == one.pixels[k]:
                        dithered.add((kind, (k % WIDTH) & 1, page[k] == word >> 8))
        else:
            assert all(c & 0xFF == c >> 8 for c in colours), d  # the game's table: no dither
        assert canvas.images == 0 and canvas.skipped == 0, d
        # the screen MAME shows a frame later is the page the buffer drew, rows 0-239 = GSP y
        # 28h-117h (snap_2, a frame further, can already show something else: game-f4200)
        base = int(meta["fb_som_page"], 16)
        final = (d / "fb.bin").read_bytes()[base : base + FB_PAGE_BYTES]
        raw = (d / "palette.bin").read_bytes()
        pal = struct.unpack(f"<{len(raw) // 4}I", raw)
        assert snapshot_agreement(d / "snap_1.png", final, pal) == FB_PAGE_BYTES, d
        pcs = read_words(d / "som_pc.bin")
        assert all(pcs[k] != 0xFFFF for k in range(som.words)), d  # every word has a writer
        writers = field_writers(som, pcs)
        has_images = any(c.is_image for c in som.commands)
        for kind, addrs in writers.items():
            assert set(addrs) <= WRITERS[kind], (d, kind, addrs)
            seen.setdefault(kind, set()).update(addrs)
        for kind, addr in IMAGE_WRITERS.items():
            assert (addr in writers.get(kind, [])) == has_images, (d, kind)
    assert seen == WRITERS  # over the captures, every writer of the table occurs
    if any(d.name.startswith("dither-") for d in captures()):
        # pixels equal to MAME's page: even x hold the low byte, odd x the high byte, both kinds
        assert dithered == {(k, x, x == 1) for k in ("fill", "outline") for x in (0, 1)}
