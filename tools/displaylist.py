#!/usr/bin/env python3
"""The SOM display list: what the ADSP writes, what the 68k copies, how the GSP draws it.

    tools/displaylist.py DIR             # decode a capture of tools/mame/somdump.lua, summarise
    tools/displaylist.py DIR --json OUT  # ... and write the decoded structure as JSON
    tools/displaylist.py DIR --render PNG  # ... and draw it as the GSP does, compare with MAME
    tools/displaylist.py --som FILE      # decode a bare SOM list (artifacts/display-list/*.som)

Standard library only. docs/08-display-list.md has the evidence for every field; the addresses
below are ADSP program words (PM), 68k addresses (0x......) and GSP bit addresses (FFF.....).

The SOM bank (0x2000 words; the ADSP writes one bank through SOMLATCH while the 68k reads the
other at 810000, harddriv_m.cpp:614/811):

    word 0      N: the address of the last word, an FFFF (written at PM 00BE, read at 0x02F0C2
                as the copy length and checked at 0x02F0E2)
    word 1      T: the address of the FFFF that ends the commands (PM 00C0; GSP FFF44CA0)
    2 .. T-1    the commands, back to back, in the order the ADSP produced them
    T           FFFF (PM 00B5)
    T+1 .. N-1  the draw order: one entry e per command, the command at word e + 1, deepest
                first (PM 080B walks the depth-sorted list at PM 123C; GSP FFF45000)
    N           FFFF (PM 082B; ends the GSP's walk, FFF45020)

A command starts with a command word (PM 0515 or 066A, the record colour from DM 0036):

    bits 0-9    colour index into the GSP colour table FFF71D20 (0x400 words; GSP FFF452D0)
    bits 10-11  fill: 0 solid, 1 three pixels in four, 2 one in four, 3 outline (FFF45150)
    bit 12      an image quad instead of a polygon (GSP FFF450D0 -> FFF48FC0)
    bit 15      skipped by the GSP (FFF450A0)

    polygon:  cmd, xl, xr, y (top row: PM 0565, 0567, 056B), then per segment the right edge's
              slope (2 words, low first: PM 057F-0582), the left edge's slope (2 words: 0583-0586)
              and a row count (0588), and FFFF FFFF (PM 05D2/05D4). Slopes are signed 16.16 x
              steps per row; a segment of count n advances n - 1 rows (GSP FFF45460-FFF45620).
    image:    cmd, then (x, y) pairs (PM 0678/067A), then FFFF FFFF (PM 0680/0682).

The GSP command buffer (FFF9FC10 / FFFCFC10, filled by the 68k through the host port) starts with
a header block the GSP skips (FFF77F50 bits, 0x440 in every capture), then commands whose top
nibble is the code (dispatch table FFF470E0, FFF46FB0); code 7 is the SOM list, copied from word
1 on after a 7000 (0x02F0BA-0x02F0D2). gsp_command_length() gives every code's length.
"""

from __future__ import annotations

import argparse
import json
import struct
import sys
import zlib
from collections.abc import Sequence
from dataclasses import dataclass, field
from pathlib import Path

SOM_WORDS = 0x2000  # one SOM bank, 8K x 16 bits (m_som_memory, harddriv.h:386)
END = 0xFFFF
END32 = 0xFFFFFFFF

# The frame buffer: 512 x 240 pixels at 8 bits, rows 0-239 = GSP y 0x28-0x117 (the window set
# at FFF46EA0/FFF46ED0: WSTART = (0x28, 0), WEND = (0x117, 0x1FF); FFF46E70 OFFSET = B4 - A000h).
WIDTH = 512
HEIGHT = 240
TOP = 0x28
FB_PAGE_BYTES = WIDTH * HEIGHT

# command word fields (GSP FFF45090-FFF451F0)
CMD_SKIP = 0x8000
CMD_IMAGE = 0x1000
CMD_FILL_SHIFT = 10
COLOUR_MASK = 0x3FF
FILL_SOLID, FILL_75, FILL_25, FILL_OUTLINE = 0, 1, 2, 3
FILL_NAMES = {0: "solid", 1: "75%", 2: "25%", 3: "outline"}
# the COLOR1 patterns of 2-bit pixels the fill writes through the 2 bpp expander (FFF450C0,
# FFF45200, FFF452A0): a pixel is written where the low bit of its 2-bit field is set
PATTERN = {FILL_SOLID: 0xFFFFFFFF, FILL_75: 0x15151515, FILL_25: 0x01010101}

GSP_HEADER_BITS = 0x440  # FFF77F50 in every capture: the header block before the first command


class DisplayListError(ValueError):
    pass


def adsp_slope(dx: int, dy: int) -> int:
    """The slope `right_slope` (05DD) and `left_slope` (0607) write for a chain segment dx
    across and dy (1-1FFh) down: MY0 = PM(1036 + dy) is floor(8000h/dy) for dy <= 40h and
    floor(200000h/dy) above (reciprocal_table), the fractional multiply `MR = AR * MY0 (SU)`
    (05F1/0601) doubles it, and above 40h `ASHIFT ... BY -6` (0602-0603) shifts the product right
    arithmetically. About dx * 10000h / dy, but the reciprocal is truncated before the multiply:
    dx = 1, dy = 3 gives 5554h, not 5555h."""
    if dy <= 0x40:
        return dx * 2 * (0x8000 // dy)
    return (dx * 2 * (0x200000 // dy)) >> 6


@dataclass(frozen=True)
class Segment:
    offset: int  # word address of the first slope word
    right_slope: int  # signed 16.16, applied to the right edge (A6, GSP FFF45540)
    left_slope: int  # signed 16.16, applied to the left edge (B0, GSP FFF455A0)
    count: int  # rows + 1 (GSP DSJS at FFF45500)


@dataclass(frozen=True)
class Command:
    offset: int  # word address of the command word
    cmd: int
    length: int  # words, terminator included
    left_x: int = 0  # polygon: top row
    right_x: int = 0
    top_y: int = 0
    segments: tuple[Segment, ...] = ()
    points: tuple[tuple[int, int], ...] = ()  # image: corner points

    @property
    def is_image(self) -> bool:
        return bool(self.cmd & CMD_IMAGE)

    @property
    def colour(self) -> int:
        return self.cmd & COLOUR_MASK

    @property
    def fill(self) -> int:
        return (self.cmd >> CMD_FILL_SHIFT) & 3

    @property
    def skipped(self) -> bool:
        return bool(self.cmd & CMD_SKIP)


@dataclass
class SomList:
    last: int  # N: the address of the final FFFF
    table_at: int  # T: the address of the FFFF that ends the commands
    commands: list[Command]
    order: list[int]  # the table entries (command address - 1), in draw order

    @property
    def words(self) -> int:
        return self.last + 1

    def by_offset(self) -> dict[int, Command]:
        return {c.offset: c for c in self.commands}

    def draw_order(self) -> list[Command]:
        index = self.by_offset()
        return [index[e + 1] for e in self.order]


def s16(v: int) -> int:
    return v - 0x10000 if v & 0x8000 else v


def s32(v: int) -> int:
    return v - 0x100000000 if v & 0x80000000 else v


def _long(w: Sequence[int], i: int) -> int:
    return w[i] | (w[i + 1] << 16)  # GSP memory is little-endian by word: low word first


def _need(w: Sequence[int], i: int, n: int, what: str) -> None:
    if i + n > len(w):
        raise DisplayListError(f"{what} at {i:04X} runs past the end of the list ({len(w):04X})")


def decode_command(w: Sequence[int], i: int, limit: int) -> Command:
    """The command at word i; it must end at or before `limit` (T)."""
    _need(w, i, 1, "command")
    cmd = w[i]
    if cmd == END:
        raise DisplayListError(f"FFFF where a command word is expected at {i:04X}")
    if cmd & CMD_IMAGE:
        j = i + 1
        points: list[tuple[int, int]] = []
        while True:
            _need(w, j, 2, "image point")
            if j + 2 > limit:
                raise DisplayListError(f"image at {i:04X} runs into the table at {limit:04X}")
            if _long(w, j) == END32:
                j += 2
                break
            points.append((w[j], w[j + 1]))
            j += 2
        return Command(i, cmd, j - i, points=tuple(points))
    _need(w, i, 4, "polygon header")
    j = i + 4
    segments: list[Segment] = []
    while True:
        _need(w, j, 2, "polygon segment")
        if j + 2 > limit:
            raise DisplayListError(f"polygon at {i:04X} runs into the table at {limit:04X}")
        if _long(w, j) == END32:
            j += 2
            break
        _need(w, j, 5, "polygon segment")
        segments.append(Segment(j, s32(_long(w, j)), s32(_long(w, j + 2)), w[j + 4]))
        j += 5
    if not segments:
        pass  # a single-row polygon: legal (the GSP fills the top row and stops)
    return Command(i, cmd, j - i, w[i + 1], w[i + 2], w[i + 3], tuple(segments))


def decode_som(words: Sequence[int]) -> SomList:
    """Decode a SOM bank (or a list of at least N + 1 words), accounting for every word up to N.

    Raises DisplayListError when the header, the commands, the separator, the table or the end
    marker do not tile 0..N exactly, or when the table is not a permutation of the commands."""
    if len(words) < 4:
        raise DisplayListError(f"{len(words)} words: too short for a SOM list")
    n, t = words[0], words[1]
    if n >= SOM_WORDS or n >= len(words):
        raise DisplayListError(f"word 0 (last address) = {n:04X} is outside the list")
    if not 2 <= t < n:
        raise DisplayListError(f"word 1 (table) = {t:04X} is not between 2 and {n:04X}")
    if words[t] != END:
        raise DisplayListError(f"no FFFF at {t:04X} after the commands")
    if words[n] != END:
        raise DisplayListError(f"no FFFF end marker at {n:04X}")
    commands: list[Command] = []
    i = 2
    while i < t:
        c = decode_command(words, i, t)
        commands.append(c)
        i += c.length
    if i != t:
        raise DisplayListError(f"the commands end at {i:04X}, not at the separator {t:04X}")
    order = list(words[t + 1 : n])
    starts = {c.offset for c in commands}
    targets = [e + 1 for e in order]
    missing = [e for e, s in zip(order, targets, strict=True) if s not in starts]
    if missing:
        raise DisplayListError(f"table entries point at no command: {missing[:4]}")
    if len(set(targets)) != len(targets) or len(targets) != len(commands):
        raise DisplayListError(
            f"the table has {len(targets)} entries ({len(set(targets))} distinct) "
            f"for {len(commands)} commands")
    return SomList(n, t, commands, order)


def encode_som(commands: Sequence[Command], order: Sequence[int] | None = None) -> list[int]:
    """The words of a SOM list holding `commands` (their offsets are ignored and reassigned) and
    drawn in `order` (indices into `commands`; default: as given). For synthetic tests."""
    body: list[int] = []
    offsets: list[int] = []
    for c in commands:
        offsets.append(2 + len(body))
        body.append(c.cmd)
        if c.cmd & CMD_IMAGE:
            for x, y in c.points:
                body += [x & 0xFFFF, y & 0xFFFF]
        else:
            body += [c.left_x & 0xFFFF, c.right_x & 0xFFFF, c.top_y & 0xFFFF]
            for s in c.segments:
                r, left = s.right_slope & 0xFFFFFFFF, s.left_slope & 0xFFFFFFFF
                body += [r & 0xFFFF, r >> 16, left & 0xFFFF, left >> 16, s.count & 0xFFFF]
        body += [END, END]
    t = 2 + len(body)
    idx = list(range(len(commands))) if order is None else list(order)
    table = [offsets[k] - 1 for k in idx]
    n = t + 1 + len(table)
    return [n, t, *body, END, *table, END]


# ----------------------------------------------------------------------------------------------
# The GSP command buffer


@dataclass(frozen=True)
class GspCommand:
    offset: int  # word index in the buffer
    code: int  # top nibble (E: also the low 2 bits, E0-E3)
    length: int  # words
    name: str
    som: SomList | None = None


GSP_NAMES = {
    0x0: "end", 0x1: "image quad", 0x2: "line", 0x3: "rectangle", 0x4: "text",
    0x5: "window", 0x6: "words to FFFF", 0x7: "SOM list", 0x8: "image", 0x9: "palette",
    0xA: "dissolve", 0xB: "FFF52060", 0xC: "colour table", 0xD: "frame-buffer entry",
    0xE: "image table", 0xF: "end",
}


def _som_in_buffer(w: Sequence[int], i: int) -> SomList:
    """The SOM list whose word 1 is at w[i] (the 68k copies words 1..N after the 7000)."""
    _need(w, i, 1, "SOM list")
    t = w[i]
    j = i + t  # table start = word T + 1 = buffer i + T (GSP FFF44CB0-FFF44CC0)
    while True:
        _need(w, j, 1, "SOM table")
        if w[j] == END:
            break
        j += 1
    n = j - i + 1
    return decode_som([n, *w[i : i + n]])


def gsp_command_length(w: Sequence[int], i: int) -> tuple[int, str, SomList | None]:
    """The length in words of the GSP command at w[i] (handler addresses: docs/08 section 3)."""
    c = w[i]
    code = c >> 12
    name = GSP_NAMES[code]
    if code in (0x0, 0xF):
        return 1, name, None  # FFF47050: leaves the list
    if code == 0xE:
        if c & 3:
            # E1-E3: cmd_E's own CALL A0 (FFF47370) reaches FFF47050 one call deeper, whose
            # ADDK 20h,SP drops only one return address: the stack is unbalanced (docs/08 3.2)
            raise DisplayListError(f"command {c:04X} at {i:04X}: E1-E3 do not end a list cleanly")
        _need(w, i, 3, "image table")
        start, count = w[i + 1], w[i + 2]
        if start > 0x3F or start + count > 0x40:  # JAHI FFF40000 at FFF4A730 / FFF4A7C0
            raise DisplayListError(
                f"image table {start:X}+{count:X} out of range at {i:04X}: restarts gsp_main")
        return 3 + 2 * count, name, None  # FFF4A6F0: count longs into FFF78150
    if code == 0x1:  # FFF48FC0: six words, then longs up to FFFFFFFF (FFF499D0)
        j = i + 7
        while True:
            _need(w, j, 2, "image quad")
            if _long(w, j) == END32:
                return j + 2 - i, name, None
            j += 2
    if code in (0x2, 0x3, 0x5, 0xD):
        return 5, name, None  # FFF47E20 / FFF47900 / FFF47AF0 / FFF4A5C0: four words
    if code == 0x4:  # FFF48650: font, x, y, then a NUL-terminated string padded to a word
        j = i + 4
        while True:
            _need(w, j, 1, "text")
            lo, hi = w[j] & 0xFF, w[j] >> 8
            j += 1
            if lo == 0 or hi == 0:
                return j - i, name, None
    if code == 0x6:  # FFF477C0: words up to an FFFF (FFF478A0)
        j = i + 1
        while True:
            _need(w, j, 1, "word list")
            j += 1
            if w[j - 1] == END:
                return j - i, name, None
    if code == 0x7:
        som = _som_in_buffer(w, i + 1)
        return 1 + som.last, name, som
    if code == 0x8:
        return 6, name, None  # FFF489E0: three words and a long
    if code == 0x9:  # FFF48C20: a count, then 3 words per two colours, 2 for an odd one
        _need(w, i, 2, "palette")
        n = w[i + 1]
        return 2 + 3 * (n // 2) + 2 * (n & 1), name, None
    if code == 0xA:
        return 2, name, None  # FFF49AF0: one word
    if code == 0xB:
        return 1, name, None  # FFF4A040
    if code == 0xC:  # FFF4A420: start, count, count words
        _need(w, i, 3, "colour table")
        start, count = w[i + 1] & 0xFF, w[i + 2]
        if start + count > 0x100:
            raise DisplayListError(f"colour table {start:X}+{count:X} past 100h at {i:04X}")
        return 3 + count, name, None
    raise AssertionError(code)


def window_of(w: Sequence[int], i: int) -> tuple[int, int, int, int]:
    """Command 5 at w[i]: the clip window, clamped as FFF47AF0-FFF47DF0 does (x to 1FFh at
    most, y into 28h-117h)."""
    x0, y0, x1, y1 = w[i + 1 : i + 5]
    return (min(x0, 0x1FF), min(max(y0, TOP), 0x117), min(x1, 0x1FF), min(max(y1, TOP), 0x117))


# ST FE0, the extension of field 0 (16 bits), as the commands leave it. read_list_header runs
# before every list (CALLA FFF4D940 at FFF41270) and sets it, `SETF 10h,1,0` at FFF4D990: each list
# starts sign-extended (MAME: `make fieldext`, FFF46E30). These handlers run `SETF 10h,0,0` and
# return with field 0 zero-extended: 4 (FFF48900), 5 (FFF47B20, FFF47E00), 6 (FFF47890), 8
# (FFF48C00), 9 (FFF48C30), C (FFF4A420), E0 (FFF4A6F0). The others have no SETF of field 0 and
# call nothing that sets it (B's CALLA FFF52060 is a bare RETS): 1, 2, 3, 7, A, B and D keep the
# mode the previous command left; 0, F and E1-E3 end the list.
FE0_RESET_CODES = frozenset({0x4, 0x5, 0x6, 0x8, 0x9, 0xC, 0xE})


def field0_sign_extended(cmds: Sequence[GspCommand], k: int) -> bool:
    """ST FE0 when the GSP starts cmds[k]: True (sign-extended) unless an earlier command of the
    same list ran one of the handlers that reset it (FE0_RESET_CODES)."""
    return not any(c.code in FE0_RESET_CODES for c in cmds[:k])


def decode_gsp_buffer(w: Sequence[int], header_bits: int = GSP_HEADER_BITS) -> list[GspCommand]:
    """The commands of a GSP command buffer (from the flag word + 10h) up to and including the
    command that ends it; words after it are stale and not part of the list."""
    if header_bits % 16:
        raise DisplayListError(f"header of {header_bits:X} bits is not whole words")
    i = header_bits // 16
    out: list[GspCommand] = []
    while True:
        _need(w, i, 1, "GSP command")
        length, name, som = gsp_command_length(w, i)
        _need(w, i, length, name)
        out.append(GspCommand(i, w[i] >> 12, length, name, som))
        i += length
        if name == "end":
            return out


# ----------------------------------------------------------------------------------------------
# The reference renderer: the GSP's polygon code (FFF45090-FFF45C50), pixel for pixel as MAME's
# TMS34010 executes it (FILL XY with window clipping, LINE 0, the 2 bpp expander).


def _rotl(v: int, k: int) -> int:
    k &= 31
    return ((v << k) | (v >> (32 - k))) & 0xFFFFFFFF if k else v


def _xy(v: int) -> tuple[int, int]:
    return s16(v & 0xFFFF), s16((v >> 16) & 0xFFFF)


def _addxy(a: int, b: int) -> int:
    return (((a + b) & 0xFFFF) | (((a >> 16) + (b >> 16)) & 0xFFFF) << 16)


FULL_WINDOW = (0, TOP, WIDTH - 1, TOP + HEIGHT - 1)  # FFF46EA0/FFF46ED0: WSTART, WEND


@dataclass
class Canvas:
    window: tuple[int, int, int, int] = FULL_WINDOW  # x0, y0, x1, y1 inclusive (B5, B6)
    pixels: bytearray = field(default_factory=lambda: bytearray(FB_PAGE_BYTES))
    drawn: bytearray = field(default_factory=lambda: bytearray(FB_PAGE_BYTES))  # 1 = written
    images: int = 0  # image quads not drawn (no images given, or rejected by the GSP's checks)
    skipped: int = 0

    def put(self, x: int, y: int, value: int) -> None:
        x0, y0, x1, y1 = self.window
        if x0 <= x <= x1 and y0 <= y <= y1:
            k = (y - TOP) * WIDTH + x
            self.pixels[k] = value
            self.drawn[k] = 1

    def fill_row(self, x0: int, x1: int, y: int, colour: int, pattern: int) -> bool:
        """FILL XY of one row from x0 to x1 - 1 (DADDR = (y, x0), DYDX = (1, x1 - x0)): False
        when SUBXY sets V (x0 > x1; the caller skips the FILL and the pattern rotation)."""
        if x0 > x1:
            return False
        wx0, wy0, wx1, wy1 = self.window
        if not wy0 <= y <= wy1:
            return True  # clipped by the window (CONTROL W = 3), still executed
        lo = pattern & 0xFFFF  # MAME's FILL masks COLOR1 with the 16-bit word's pixel mask
        for x in range(max(x0, wx0), min(x1, wx1 + 1)):
            if (lo >> ((2 * x) & 15)) & 1:
                # the expander writes the colour word's low byte to even pixels, the high byte
                # to odd ones (harddriv_v.cpp:300, color | color << 16 under the 2 bpp masks)
                self.put(x, y, (colour >> (8 * (x & 1))) & 0xFF)
        return True

    def line(self, start: int, delta: int, colour: int) -> None:
        """GSP FFF45C60: LINE 0 from `start` by `delta` (XY), as MAME's line() steps it."""
        x, y = _xy(start)
        dx, dy = _xy(delta)
        incx = -1 if dx < 0 else 1
        adx = -dx if dx < 0 else dx
        if adx >= dy:  # x major (CMPXY at FFF45D20)
            major, minor = adx, dy
            inc1, inc2 = (incx, 1), (incx, 0)
        else:
            major, minor = dy, adx
            inc1, inc2 = (incx, 1), (0, 1)
        d = 2 * minor - major
        for _ in range(major + 1):
            # LINE writes one 2-bit pixel (COLOR1's low pixel, B9 = FFFFFFFF here) and the
            # expander gives it the colour byte of its parity, as for FILL (harddriv_v.cpp:300)
            self.put(x, y, (colour >> (8 * (x & 1))) & 0xFF)
            if d >= 0:
                d += 2 * minor - 2 * major
                x, y = x + inc1[0], y + inc1[1]
            else:
                d += 2 * minor
                x, y = x + inc2[0], y + inc2[1]


def draw_polygon(canvas: Canvas, c: Command, colours: Sequence[int]) -> None:
    colour = colours[c.colour]
    if c.fill == FILL_OUTLINE:
        _draw_outline(canvas, c, colour)
        return
    pattern = PATTERN[c.fill]
    if c.fill in (FILL_SOLID, FILL_25) and (c.cmd & 0xFF) == 4:
        pattern = PATTERN[FILL_75]  # FFF45230-FFF452A0: colour byte 4 is always 75%
    b9 = _rotl(pattern, (c.top_y << 2) & 31)  # FFF45370-FFF45390
    b0 = ((c.top_y << 16) | c.left_x) & 0xFFFFFFFF  # left edge (y, x), FFF453D0
    a6 = (((c.top_y << 16) | c.right_x) + 0x10001) & 0xFFFFFFFF  # right edge + (1, 1), FFF453E0
    a0 = a4 = 0x80000000  # the edges' fractions start at one half (FFF453F0-FFF45410)
    a7 = a8 = a9 = b1 = 0
    segments = list(c.segments)
    first = True
    rows = 1
    while True:
        if not first:  # FFF45460: the edges step one row, carries from the fractions
            a0 += a9
            b0 = (b0 + b1 + (a0 >> 32)) & 0xFFFFFFFF
            a0 &= 0xFFFFFFFF
            a4 += a7
            a6 = (a6 + a8 + (a4 >> 32)) & 0xFFFFFFFF
            a4 &= 0xFFFFFFFF
        first = False
        xl, y = _xy(b0)
        xr, _ = _xy(a6)
        if canvas.fill_row(xl, xr, y, colour, b9):  # FFF454A0-FFF454E0
            b9 = _rotl(b9, 4)  # FFF454F0
        rows -= 1  # FFF45500 DSJS
        while rows == 0:
            if not segments:
                return  # FFF45520: FFFFFFFF
            s = segments.pop(0)
            r, left = s.right_slope & 0xFFFFFFFF, s.left_slope & 0xFFFFFFFF
            a7 = (r << 16) & 0xFFFFFFFF  # FFF45540-FFF45570
            a8 = ((s32(r) >> 16) + 0x10000) & 0xFFFFFFFF
            b1 = ((s32(left) >> 16) + 0x10000) & 0xFFFFFFFF  # FFF455A0-FFF455E0
            a9 = (left << 16) & 0xFFFFFFFF
            rows = s.count - 1  # FFF45610, then DSJS
            if s.count == 0:
                rows = 0xFFFF  # DSJS on a zero count wraps (never produced, HYP)


def _draw_outline(canvas: Canvas, c: Command, colour: int) -> None:
    """FFF45800-FFF45C50: the top row, a LINE per edge and segment, the bottom row."""
    full = PATTERN[FILL_SOLID]
    b0 = ((c.top_y << 16) | c.left_x) & 0xFFFFFFFF
    a6 = ((c.top_y << 16) | c.right_x) & 0xFFFFFFFF
    xl, y = _xy(b0)
    xr, _ = _xy(_addxy(a6, 0x10001))
    canvas.fill_row(xl, xr, y, colour, full)  # FFF459A0-FFF45A00
    for s in c.segments:
        n = s.count - 1  # FFF45A60 DEC; zero: next segment
        if n <= 0:
            continue
        n12 = n - 0x1000 if n & 0x800 else n  # MPYS with field size 12 (FFF45A80)
        dr = ((s.right_slope * n12) & 0xFFFFFFFF) >> 16
        dl = ((s.left_slope * n12) & 0xFFFFFFFF) >> 16
        a7 = (n << 16 | dr) & 0xFFFFFFFF  # MOVX A10,A7 / RL 10h,A7: (y = n, x = int part)
        a9 = (n << 16 | dl) & 0xFFFFFFFF
        canvas.line(b0, a9, colour)  # FFF45B00-FFF45B40: the left edge
        canvas.line(a6, a7, colour)  # FFF45B70-FFF45BA0: the right edge (A13 bit 5 clear)
        b0 = _addxy(b0, a9)
        a6 = _addxy(a6, a7)
    xl, y = _xy(b0)
    xr, _ = _xy(_addxy(a6, 0x10001))
    canvas.fill_row(xl, xr, y, colour, full)  # FFF45BF0-FFF45C40


@dataclass(frozen=True)
class Image:
    height: int
    width: int
    pixels: bytes


def read_images(data: bytes) -> dict[int, Image]:
    """images.bin of a capture: the image table FFF78150 and the images it points at."""
    out: dict[int, Image] = {}
    p = 0
    for i in range(64):
        (ptr,) = struct.unpack_from("<I", data, p)
        p += 4
        if ptr:
            h, w = struct.unpack_from("<HH", data, p)
            p += 4
            out[i] = Image(h, w, data[p : p + h * w])
            p += h * w
    return out


def draw_image(canvas: Canvas, c: Command, images: dict[int, Image], loose: bool,
               sign_extended: bool = False) -> bool:
    """FFF48FC0: scale image cmd & 3Fh into the box from p0 to (p1.x, p2.y), 8 bits per pixel,
    pixel 0 transparent (CONTROL = E0h: T set). `loose` is FFF77E60 bit 4 (no size limits).
    False when the GSP's checks reject it (FFF49230-FFF49650; it then only skips the words).
    The corners are read with field 0 (`MOVE *A5+,An,0`) and the handler has no SETF: they are
    sign-extended when `sign_extended` (ST FE0 = 1, see field0_sign_extended). Zero-extended, no
    corner is negative: a p0.x or p0.y of 8000h or more fails the 200h/117h tests, and a p1.x of
    8000h or more is a very wide box that only the 15Eh limit rejects (drawn, clipped, when
    loose). Sign-extended, such a p0 passes them (the box starts left of or above the window,
    which clips it: PIXT XY with W = 3) and such a p1.x is rejected by the JRNN at FFF49390."""
    if len(c.points) < 3:
        return False
    img = images.get(c.cmd & 0x3F)
    ext = s16 if sign_extended else (lambda v: v)
    (x0, y0), (x1, y1), (_, y2) = c.points[0], c.points[1], c.points[2]
    x0, y0, x1, y1, y2 = ext(x0), ext(y0), ext(x1), ext(y1), ext(y2)
    width = x1 - x0 + 1  # SUB A0,A1 (FFF493D0): rejected when x1 - x0 < 0, then INC
    height = y2 - y1 + 1
    ok = (img is not None and x0 < 0x200 and y0 < 0x117 and x1 >= 0 and width > 0 and y2 >= TOP
          and height > 0 and (loose or (width < 0x15E and height < 0xC8)))
    if not ok or img is None:
        return False
    v = (img.height << 16) // height  # DIVU A2,A7 (FFF496E0)
    u = (img.width << 16) // width  # DIVU A1,A3 (FFF49760)
    vf, vi = (v << 16) & 0xFFFFFFFF, v >> 16
    uf, ui = (u << 16) & 0xFFFFFFFF, u >> 16
    row, racc = 0, vf  # B14, A8 = A6 (FFF49710)
    for dy in range(height):
        col, cacc = 0, uf  # A11 = A10 (FFF49790, FFF49910)
        for dx in range(width):
            k = row * img.width + col
            value = img.pixels[k] if k < len(img.pixels) else 0
            if value:  # PIXT with T: zero is transparent
                canvas.put(x0 + dx, y0 + dy, value)
            cacc += uf
            col += ui + (cacc >> 32)
            cacc &= 0xFFFFFFFF
        racc += vf  # FFF49980
        row += vi + (racc >> 32)
        racc &= 0xFFFFFFFF
    return True


def render(som: SomList, colours: Sequence[int],
           window: tuple[int, int, int, int] = FULL_WINDOW,
           images: dict[int, Image] | None = None, loose: bool = False,
           sign_extended: bool = False) -> Canvas:
    """Draw the list in table order into an empty 512 x 240 page (rows = GSP y 28h-117h),
    clipped to `window` (the last command 5 before the list sets it, FFF47AF0). `sign_extended`
    is ST FE0 when the list's command 7 starts (field0_sign_extended); nothing in the SOM loop
    (FFF44BF0-FFF45FB0) sets field 0, and only the image quads depend on it: the polygon code
    keeps the low 16 bits of its x reads (MOVY into B0/A6, FFF453B0-FFF453D0) and shifts y
    left by 16 (FFF453A0)."""
    if len(colours) < 0x400:
        raise DisplayListError(f"{len(colours)} colour words, need 400h")
    canvas = Canvas(window)
    for c in som.draw_order():
        if c.skipped:
            canvas.skipped += 1
        elif c.is_image:
            if images is None or not draw_image(canvas, c, images, loose, sign_extended):
                canvas.images += 1
        else:
            draw_polygon(canvas, c, colours)
    return canvas


@dataclass(frozen=True)
class Agreement:
    drawn: int  # pixels the renderer wrote
    equal: int  # ... equal to the MAME frame buffer after the list
    changed: int = 0  # pixels the list changed in MAME's page (before != after); -1: unknown
    missed: int = 0  # ... of which the renderer did not draw

    @property
    def share(self) -> float:
        return self.equal / self.drawn if self.drawn else 1.0


def compare(canvas: Canvas, page: bytes, before: bytes | None = None) -> Agreement:
    """The rendering against MAME's page after the list, and, given the page before it, the
    pixels the list changed there that the rendering does not draw."""
    if len(page) < FB_PAGE_BYTES:
        raise DisplayListError(f"frame buffer page of {len(page)} bytes")
    drawn = equal = changed = missed = 0
    for k in range(FB_PAGE_BYTES):
        if canvas.drawn[k]:
            drawn += 1
            equal += canvas.pixels[k] == page[k]
        if before is not None and before[k] != page[k]:
            changed += 1
            missed += not canvas.drawn[k]
    return Agreement(drawn, equal, changed if before is not None else -1, missed)


# ----------------------------------------------------------------------------------------------
# Files


def read_words(path: Path) -> list[int]:
    data = path.read_bytes()
    if len(data) % 2:
        raise DisplayListError(f"{path}: odd length")
    return list(struct.unpack(f"<{len(data) // 2}H", data))


def read_meta(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in path.read_text().splitlines():
        if line == "events:":
            break
        key, _, value = line.partition(" ")
        out[key] = value
    return out


def png(path: Path, width: int, height: int, rgb: bytes) -> None:
    """A minimal 8-bit RGB PNG (no dependencies)."""
    rows = b"".join(b"\0" + rgb[y * width * 3 : (y + 1) * width * 3] for y in range(height))

    def chunk(kind: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(kind + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", crc)

    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header)
                     + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


def read_png(path: Path) -> tuple[int, int, bytes]:
    """Width, height and RGB bytes of an 8-bit RGB PNG such as MAME's snapshots."""
    data = path.read_bytes()
    i, idat, width, height = 8, b"", 0, 0
    while i < len(data):
        (n,) = struct.unpack_from(">I", data, i)
        kind, body = data[i + 4 : i + 8], data[i + 8 : i + 8 + n]
        if kind == b"IHDR":
            width, height, depth, colour = struct.unpack_from(">IIBB", body)
            if (depth, colour) != (8, 2):
                raise DisplayListError(f"{path}: not 8-bit RGB")
        elif kind == b"IDAT":
            idat += body
        i += 12 + n
    raw = zlib.decompress(idat)
    stride = 3 * width
    out = bytearray()
    prev = bytearray(stride)
    p = 0
    for _ in range(height):
        kind_ = raw[p]
        line = bytearray(raw[p + 1 : p + 1 + stride])
        p += 1 + stride
        for x in range(stride):
            a = line[x - 3] if x >= 3 else 0
            b = prev[x]
            c = prev[x - 3] if x >= 3 else 0
            if kind_ == 1:
                line[x] = (line[x] + a) & 255
            elif kind_ == 2:
                line[x] = (line[x] + b) & 255
            elif kind_ == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif kind_ == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        out += line
        prev = line
    return width, height, bytes(out)


def snapshot_agreement(snapshot: Path, page: bytes, palette: Sequence[int]) -> int:
    """How many pixels of a MAME snapshot equal the frame-buffer page through palette bank 0."""
    width, height, rgb = read_png(snapshot)
    if (width, height) != (WIDTH, HEIGHT):
        raise DisplayListError(f"{snapshot}: {width} x {height}, not {WIDTH} x {HEIGHT}")
    equal = 0
    for k in range(FB_PAGE_BYTES):
        v = palette[page[k]]
        equal += rgb[3 * k : 3 * k + 3] == bytes(((v >> 16) & 255, (v >> 8) & 255, v & 255))
    return equal


def comparison_picture(canvas: Canvas, page: bytes, palette: Sequence[int]) -> bytes:
    """Three panels side by side: MAME's page, the rendering, and agreement (green equal, red
    different, grey not drawn by the list)."""
    out = bytearray()
    for y in range(HEIGHT):
        left = bytearray()
        mid = bytearray()
        right = bytearray()
        for x in range(WIDTH):
            k = y * WIDTH + x
            p = palette[page[k]]
            left += bytes(((p >> 16) & 255, (p >> 8) & 255, p & 255))
            if canvas.drawn[k]:
                q = palette[canvas.pixels[k]]
                mid += bytes(((q >> 16) & 255, (q >> 8) & 255, q & 255))
                right += b"\x00\xa0\x00" if canvas.pixels[k] == page[k] else b"\xff\x00\x00"
            else:
                mid += b"\x00\x00\x00"
                right += b"\x30\x30\x30"
        out += left + mid + right
    return bytes(out)


def field_writers(som: SomList, pcs: Sequence[int]) -> dict[str, list[int]]:
    """For a capture with som_pc.bin: which ADSP instructions wrote each kind of field."""
    kinds: dict[str, set[int]] = {}

    def note(kind: str, addr: int) -> None:
        if pcs[addr] != 0xFFFF:
            kinds.setdefault(kind, set()).add(pcs[addr])

    note("header N", 0)
    note("header T", 1)
    note("separator FFFF", som.table_at)
    note("end FFFF", som.last)
    for k in range(som.table_at + 1, som.last):
        note("table entry", k)
    for c in som.commands:
        note("command word", c.offset)
        if c.is_image:
            for p in range(len(c.points)):
                note("image x", c.offset + 1 + 2 * p)
                note("image y", c.offset + 2 + 2 * p)
        else:
            note("polygon xl", c.offset + 1)
            note("polygon xr", c.offset + 2)
            note("polygon y", c.offset + 3)
            for s in c.segments:
                note("right slope low", s.offset)
                note("right slope high", s.offset + 1)
                note("left slope low", s.offset + 2)
                note("left slope high", s.offset + 3)
                note("segment count", s.offset + 4)
        note("command end FFFF FFFF", c.offset + c.length - 2)
        note("command end FFFF FFFF", c.offset + c.length - 1)
    return {k: sorted(v) for k, v in kinds.items()}


def summary(som: SomList) -> list[str]:
    fills: dict[str, int] = {}
    for c in som.commands:
        kind = "image" if c.is_image else FILL_NAMES[c.fill]
        if c.skipped:
            kind += " (skipped)"
        fills[kind] = fills.get(kind, 0) + 1
    segs = sum(len(c.segments) for c in som.commands)
    return [
        f"SOM list: {som.words} words (N = {som.last:04X}, T = {som.table_at:04X}), "
        f"{len(som.commands)} commands, {segs} segments, {len(som.order)} table entries",
        "commands: " + ", ".join(f"{k} {v}" for k, v in sorted(fills.items())),
        f"every word accounted for: header 2, commands {som.table_at - 2}, separator 1, "
        f"table {len(som.order)}, end 1 = {som.words}",
    ]


def to_json(som: SomList) -> dict:
    return {
        "last": som.last,
        "table_at": som.table_at,
        "order": som.order,
        "commands": [
            {
                "offset": c.offset, "cmd": c.cmd, "length": c.length,
                "colour": c.colour, "fill": FILL_NAMES[c.fill],
                "image": c.is_image, "skipped": c.skipped,
                **({"points": [list(p) for p in c.points]} if c.is_image else {
                    "left_x": c.left_x, "right_x": c.right_x, "top_y": c.top_y,
                    "segments": [[s.right_slope, s.left_slope, s.count] for s in c.segments],
                }),
            }
            for c in som.commands
        ],
    }


ARTIFACTS = Path(__file__).resolve().parent.parent / "artifacts" / "display-list"


def synthetic_colours() -> list[int]:
    """A colour table that is not the game's (the committed tests redraw with it): two
    different bytes per index, for the expander's even and odd pixels."""
    return [((i * 7 + 1) & 0xFF) | ((((i * 13) + 2) & 0xFF) << 8) for i in range(0x400)]


def capture_state(d: Path) -> tuple[tuple[int, int, int, int], bool]:
    """The clip window and ST FE0 (True: field 0 sign-extended) in force when the capture's GSP
    buffer reaches its SOM list."""
    meta = read_meta(d / "meta.txt")
    buf = read_words(d / "cmdbuf.bin")
    window = FULL_WINDOW
    cmds = decode_gsp_buffer(buf, int(meta.get("FFF77F50", f"{GSP_HEADER_BITS:X}"), 16))
    for k, c in enumerate(cmds):
        if c.som is not None:
            return window, field0_sign_extended(cmds, k)
        if c.code == 0x5:
            window = window_of(buf, c.offset)
    raise DisplayListError(f"{d}: no SOM list in the GSP buffer")


def capture_window(d: Path) -> tuple[int, int, int, int]:
    """The clip window in force when the capture's GSP buffer reaches its SOM list."""
    return capture_state(d)[0]


def export(d: Path, name: str, som: SomList) -> None:
    """A capture's list as a committed artefact (runtime RAM state, N + 1 words) and the
    checksum of its redrawing with synthetic colours (CI redraws and compares)."""
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    words = read_words(d / "som.bin")[: som.words]
    (ARTIFACTS / f"{name}.som").write_bytes(struct.pack(f"<{len(words)}H", *words))
    window = capture_window(d)
    canvas = render(som, synthetic_colours(), window)
    masked = bytes(p if k else 0 for p, k in zip(canvas.pixels, canvas.drawn, strict=True))
    path = ARTIFACTS / "expected.json"
    table = json.loads(path.read_text()) if path.exists() else {}
    table[name] = {
        "capture": d.name, "commands": len(som.commands), "window": list(window),
        "drawn": sum(canvas.drawn), "crc32_synthetic_colours": zlib.crc32(masked),
    }
    path.write_text(json.dumps(table, indent=1, sort_keys=True) + "\n")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("capture", nargs="?", type=Path, help="a tools/mame/somdump.lua directory")
    ap.add_argument("--som", type=Path, help="a bare SOM list (16-bit little-endian words)")
    ap.add_argument("--json", type=Path, help="write the decoded list as JSON")
    ap.add_argument("--render", type=Path, help="draw the list, compare, write a PNG")
    ap.add_argument("--export", metavar="NAME",
                    help="write the list to artifacts/display-list/NAME.som and its expected "
                         "redrawing (synthetic colours) into expected.json there")
    args = ap.parse_args(argv)
    try:
        if args.som:
            som = decode_som(read_words(args.som))
            lines = summary(som)
        elif args.capture:
            d = args.capture
            words = read_words(d / "som.bin")
            som = decode_som(words)
            lines = summary(som)
            if (d / "som68k.bin").exists():
                same = read_words(d / "som68k.bin")[: som.words] == words[: som.words]
                lines.append(f"rebuilt bank equals the 68k's view at 810000: {same}")
            meta = read_meta(d / "meta.txt") if (d / "meta.txt").exists() else {}
            if (d / "cmdbuf.bin").exists():
                header = int(meta.get("FFF77F50", f"{GSP_HEADER_BITS:X}"), 16)
                cmds = decode_gsp_buffer(read_words(d / "cmdbuf.bin"), header)
                soms = [c.som for c in cmds if c.som is not None]
                end = cmds[-1].offset + cmds[-1].length
                lines.append(
                    f"GSP buffer: header {header // 16} words, {len(cmds)} commands to word "
                    f"{end:04X}: " + " ".join(f"{c.code:X}" for c in cmds))
                lines.append(
                    f"SOM lists in the buffer: {len(soms)}, equal to som.bin: "
                    f"{[x.order == som.order and x.commands == som.commands for x in soms]}")
            if (d / "som_pc.bin").exists():
                for kind, addrs in field_writers(som, read_words(d / "som_pc.bin")).items():
                    lines.append(f"  {kind:22} written at PM " + " ".join(f"{a:04X}" for a in addrs))
        else:
            ap.error("give a capture directory or --som")
        if args.export:
            if not args.capture:
                ap.error("--export needs a capture directory")
            export(args.capture, args.export, som)
            lines.append(f"exported {args.export}")
        if args.json:
            args.json.write_text(json.dumps(to_json(som), indent=1) + "\n")
        if args.render:
            if not args.capture:
                ap.error("--render needs a capture directory")
            d = args.capture
            colours = read_words(d / "colors.bin")
            page = (d / "fb_som.bin").read_bytes()
            window, sign_extended = capture_state(d)
            meta = read_meta(d / "meta.txt")
            images = None
            if (d / "images.bin").exists():
                images = read_images((d / "images.bin").read_bytes())
            loose = bool(int(meta.get("FFF77E60", "0"), 16) & 0x10)
            canvas = render(som, colours, window, images, loose, sign_extended)
            before = (d / "fb_pre.bin").read_bytes() if (d / "fb_pre.bin").exists() else None
            agreement = compare(canvas, page, before)
            pal = struct.unpack(f"<{len((d / 'palette.bin').read_bytes()) // 4}I",
                                (d / "palette.bin").read_bytes())
            png(args.render, 3 * WIDTH, HEIGHT, comparison_picture(canvas, page, pal))
            base = int(meta.get("fb_som_page", "0"), 16)
            final = (d / "fb.bin").read_bytes()[base : base + FB_PAGE_BYTES]
            for snap in sorted(d.glob("snap_*.png")):
                n = snapshot_agreement(snap, final, pal)
                lines.append(f"{snap.name}: {n} of {FB_PAGE_BYTES} pixels equal the drawn page "
                             f"at VRAM {base:05X} after the whole buffer, through palette bank 0")
            lines.append(
                f"render: {agreement.drawn} pixels drawn, {agreement.equal} equal to MAME's page "
                f"({100 * agreement.share:.3f}%); the list changed {agreement.changed} pixels of "
                f"the page, {agreement.missed} of them not drawn; {canvas.images} image quads not drawn "
                f"(no images, or rejected), "
                f"{canvas.skipped} skipped; field 0 "
                f"{'sign' if sign_extended else 'zero'}-extended at the list")
            if agreement.equal != agreement.drawn or agreement.missed:
                print("\n".join(lines))
                print("displaylist: the redrawing differs from MAME's page", file=sys.stderr)
                return 2
    except DisplayListError as e:
        print(f"displaylist: {e}", file=sys.stderr)
        return 1
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
