"""Indexed PNG files, standard library only: the committed form of a GSP image.

`write` makes an 8-bit indexed PNG with a 256-entry PLTE (filter 0 on every row, zlib level 9,
no other chunk), so the same pixels and palette always give the same file. `read` takes any
non-interlaced indexed PNG (bit depth 1, 2, 4 or 8, any filter, a PLTE of any length, ancillary
chunks skipped), as an image editor may save it, and returns its pixel indices and palette.
"""

from __future__ import annotations

import struct
import zlib
from dataclasses import dataclass

SIGNATURE = b"\x89PNG\r\n\x1a\n"


class PngError(ValueError):
    """A file this reader does not take (not PNG, not indexed, interlaced, damaged)."""


@dataclass(frozen=True)
class Indexed:
    width: int
    height: int
    pixels: bytes  # row-major, one index per byte
    palette: list[tuple[int, int, int]]


def _chunk(tag: bytes, body: bytes) -> bytes:
    return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body))


def write(width: int, height: int, pixels: bytes, palette: list[tuple[int, int, int]]) -> bytes:
    if len(pixels) != width * height:
        raise PngError(f"{len(pixels)} pixels for {width}x{height}")
    if not 1 <= len(palette) <= 256:
        raise PngError(f"a palette of {len(palette)} colours")
    raw = b"".join(b"\0" + pixels[y * width : (y + 1) * width] for y in range(height))
    return (
        SIGNATURE
        + _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
        + _chunk(b"PLTE", bytes(c for rgb in palette for c in rgb))
        + _chunk(b"IDAT", zlib.compress(raw, 9))
        + _chunk(b"IEND", b"")
    )


def _paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    return b if pb <= pc else c


def read(blob: bytes) -> Indexed:
    if not blob.startswith(SIGNATURE):
        raise PngError("not a PNG file")
    p = len(SIGNATURE)
    header: tuple[int, ...] | None = None
    palette: list[tuple[int, int, int]] = []
    idat = bytearray()
    while p < len(blob):
        if p + 8 > len(blob):
            raise PngError("truncated chunk header")
        (length,) = struct.unpack(">I", blob[p : p + 4])
        tag = blob[p + 4 : p + 8]
        body = blob[p + 8 : p + 8 + length]
        if len(body) != length or p + 12 + length > len(blob):
            raise PngError(f"truncated {tag!r} chunk")
        (crc,) = struct.unpack(">I", blob[p + 8 + length : p + 12 + length])
        if crc != zlib.crc32(tag + body):
            raise PngError(f"bad CRC in the {tag.decode('latin-1')} chunk")
        p += 12 + length
        if tag == b"IHDR":
            header = struct.unpack(">IIBBBBB", body)
        elif tag == b"PLTE":
            if length % 3:
                raise PngError("PLTE length is not a multiple of 3")
            palette = [(body[k], body[k + 1], body[k + 2]) for k in range(0, length, 3)]
        elif tag == b"IDAT":
            idat += body
        elif tag == b"IEND":
            break
        elif not tag[0] & 0x20:
            raise PngError(f"unknown critical chunk {tag.decode('latin-1')}")
    if header is None:
        raise PngError("no IHDR")
    width, height, depth, colour, _compression, _filter, interlace = header
    if colour != 3:
        raise PngError(f"colour type {colour}: the image must be indexed (palette) colour")
    if depth not in (1, 2, 4, 8):
        raise PngError(f"bit depth {depth}")
    if interlace:
        raise PngError("interlaced PNG")
    if not palette:
        raise PngError("no PLTE")
    stride = (width * depth + 7) // 8
    try:
        raw = zlib.decompress(bytes(idat))
    except zlib.error as e:
        raise PngError(f"IDAT: {e}") from None
    if len(raw) != height * (stride + 1):
        raise PngError(f"IDAT holds {len(raw)} bytes, {height * (stride + 1)} expected")
    bpp = 1  # filter unit: one byte for every indexed depth
    rows: list[bytearray] = []
    prev = bytearray(stride)
    for y in range(height):
        f = raw[y * (stride + 1)]
        line = bytearray(raw[y * (stride + 1) + 1 : (y + 1) * (stride + 1)])
        if f == 2:
            line = bytearray((u + v) & 0xFF for u, v in zip(line, prev, strict=True))
            f = 0
        for x in range(stride if f else 0):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 0:
                pass
            elif f == 1:
                line[x] = (line[x] + a) & 0xFF
            elif f == 2:
                line[x] = (line[x] + b) & 0xFF
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 0xFF
            elif f == 4:
                line[x] = (line[x] + _paeth(a, b, c)) & 0xFF
            else:
                raise PngError(f"row {y}: filter type {f}")
        rows.append(line)
        prev = line
    if depth == 8:
        pixels = b"".join(bytes(r) for r in rows)
    else:
        per = 8 // depth
        mask = (1 << depth) - 1
        out = bytearray()
        for r in rows:
            for x in range(width):
                byte = r[x // per]
                out.append((byte >> (8 - depth * (x % per + 1))) & mask)
        pixels = bytes(out)
    if pixels and max(pixels) >= len(palette):
        raise PngError(f"pixel index {max(pixels)} outside the {len(palette)}-colour PLTE")
    return Indexed(width, height, pixels, palette)
