"""The SOM display list decoder and the reference renderer (tools/displaylist.py, docs/08).

Synthetic tests run everywhere (CI): hand-built lists through the decoder, truncated and malformed
lists rejected, a GSP command buffer around a list, the renderer on known shapes. The committed
captures under artifacts/display-list/ (SOM lists as MAME's ADSP wrote them: runtime RAM state)
are decoded in CI too, and redrawn against a recorded checksum. The capture tests run on
`make somdump` output (build/mame/som/) and skip without it: every capture decodes with no word
unexplained, the rebuilt bank equals the 68k's view, the GSP buffer carries the same list, and the
redrawing equals MAME's frame buffer on every pixel it draws and misses none the list changed.
"""

from __future__ import annotations

import json
import zlib
from pathlib import Path

import pytest
from displaylist import (
    END,
    FB_PAGE_BYTES,
    TOP,
    WIDTH,
    Canvas,
    Command,
    DisplayListError,
    Segment,
    compare,
    decode_gsp_buffer,
    decode_som,
    draw_polygon,
    encode_som,
    field_writers,
    read_images,
    read_meta,
    read_words,
    render,
    synthetic_colours,
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


def test_window_clips():
    c = Canvas(window=(0, 0x41, 14, 0x117))
    draw_polygon(c, square(), synthetic_colours())
    assert sum(c.drawn) == 9 * 5  # rows 41h-48h... of 10, columns 10-14


def test_outline_is_edges_only():
    c = Canvas()
    draw_polygon(c, square(0x0C00 | 0x0140), synthetic_colours())
    # top and bottom rows (10 each) and both sides (8 inner rows each)
    assert sum(c.drawn) == 10 + 10 + 2 * 8


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
    masked = bytes(p if d else 0 for p, d in zip(canvas.pixels, canvas.drawn, strict=True))
    assert sum(canvas.drawn) == expected["drawn"]
    assert zlib.crc32(masked) == expected["crc32_synthetic_colours"]


# --------------------------------------------------------------- `make somdump` captures (local)


def captures() -> list[Path]:
    return sorted(p for p in CAPTURES.glob("*/") if (p / "som.bin").exists())


@pytest.mark.skipif(not captures(), reason="no captures: run make somdump (needs MAME and ROMs)")
def test_captures_against_mame():
    from displaylist import capture_window

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
        window = capture_window(d)
        images = read_images((d / "images.bin").read_bytes())
        loose = bool(int(meta["FFF77E60"], 16) & 0x10)
        canvas = render(som, read_words(d / "colors.bin"), window, images, loose)
        a = compare(canvas, (d / "fb_som.bin").read_bytes(), (d / "fb_pre.bin").read_bytes())
        assert a.drawn > 0 and a.equal == a.drawn, (d, a)
        assert a.missed == 0, (d, a)
        assert canvas.images == 0 and canvas.skipped == 0, d
        writers = field_writers(som, read_words(d / "som_pc.bin"))
        assert writers["header N"] == [0x00BE] and writers["header T"] == [0x00C0], d
        assert writers["table entry"] == [0x0828] and writers["end FFFF"] == [0x082B], d
