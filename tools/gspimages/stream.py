"""The packed GSP image stream: the 68010's unpacker, instruction for instruction, and its inverse.

The consumer is `unpack_gsp_image` 0225E4-02274A (the resumable twin 022766-022954 runs the same
command loop a few commands per call, with its state in RAM FF9BCC-FF9BD4 and FF9C64-FF9C66; the
16-entry table is built by 0225B0). Both write the decoded bytes as big-endian words to HSTDATA
(C0000C, A2): the first byte of each pair is the word's high byte.

Stream (docs/15-gsp-images.md section 2):

- byte 0 must be 00 (02260A, `bne 0225CE` = soft_reset otherwise); it is the new-table command,
  so the twin reads it as a command (02280E) and `unpack_gsp_image` checks it at 022600.
- command byte c, n = c & 3F, taken apart by `bclr #7` (02260C) then `bclr #6` (022614/0226CA):
  - 00: a new 16-byte table follows (bsr 0225B0 at 022604);
  - 01-3F: n literal bytes (02261E-022670);
  - 40: end (022672 `subq #1` / `bmi 0225D4`): a pending odd byte is written with a 0 low byte
    (0225D4-0225DA);
  - 41-7F: n bytes, each two 4-bit codes, high nibble first, mapped through the table (022678-0226C6);
  - 80, C0: soft_reset (0226D4, 022704);
  - 81-BF: the next byte repeated n times (0226D8-0226FE);
  - C1-FF: the next byte's two codes, as one pair of table values, repeated n times (022708-022746).

The odd-byte state (D2 = FFFF while a byte waits in D3's high half) makes the stream a plain byte
sequence: no command is aligned to a word. `unpack` returns that byte sequence (the decoded
stream); its length may be odd only before the end, where the pad byte makes the last word.

`pack` is the encoder that gives the stream bytes of all 54 streams of the ROM back from their
decoded bytes (docs/15 section 3): its choices are not the format's, they are the original
packer's, measured.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass

END = 0x40
TABLE_SIZE = 16
MAX_COUNT = 0x3F  # n = c & 3F
MAX_NIBBLE_BYTES = 62  # the packer's longest nibble block (never 63 in the ROM)


class StreamError(ValueError):
    """A stream the unpacker would not decode (it would call soft_reset or run off the data)."""


@dataclass(frozen=True)
class Unpacked:
    data: bytes  # the decoded bytes, in HSTDATA order (pairs = big-endian words)
    end: int  # offset just past the end command
    tables: int  # how many tables the stream loads (the leading one included)


def unpack(src: bytes, start: int) -> Unpacked:
    """Decode the stream at src[start:] as 0225E4 does."""
    p = start
    out = bytearray()
    tables = 0

    def take(k: int) -> bytes:
        nonlocal p
        if p + k > len(src):
            raise StreamError(f"stream at {start:06X} runs past the data at {p:06X}")
        b = src[p : p + k]
        p += k
        return b

    if take(1)[0] != 0:
        raise StreamError(f"stream at {start:06X}: first byte is not 00 (0225CE soft_reset)")
    table = list(take(TABLE_SIZE))
    tables = 1
    while True:
        c = take(1)[0]
        n = c & 0x3F
        kind = c >> 6
        if kind == 0:
            if n == 0:
                table = list(take(TABLE_SIZE))
                tables += 1
            else:
                out += take(n)
        elif kind == 1:
            if n == 0:
                return Unpacked(bytes(out), p, tables)
            for b in take(n):
                out.append(table[b >> 4])
                out.append(table[b & 15])
        else:
            if n == 0:
                raise StreamError(f"stream at {start:06X}: command {c:02X} at {p - 1:06X} (soft_reset)")
            b = take(1)[0]
            if kind == 2:
                out += bytes([b]) * n
            else:
                out += bytes([table[b >> 4], table[b & 15]]) * n


def words(data: bytes) -> list[int]:
    """The HSTDATA words the unpacker writes for these decoded bytes (the last one padded with 0)."""
    if len(data) % 2:
        data = data + b"\0"
    return [(data[k] << 8) | data[k + 1] for k in range(0, len(data), 2)]


# --- the encoder ------------------------------------------------------------------------------


def make_table(data: bytes) -> bytes:
    """The 16 most frequent byte values, by count descending then value ascending, padded with 00."""
    counts = Counter(data)
    values = sorted(counts, key=lambda v: (-counts[v], v))[:TABLE_SIZE]
    return bytes(values + [0] * (TABLE_SIZE - len(values)))


def pack(data: bytes) -> bytes:
    """Encode decoded bytes into a stream: 00, the table, the commands, 40.

    The rules (docs/15 section 3), measured on the 54 streams of the ROM, which they give back
    byte for byte:

    - the table is `make_table(data)`; a value's code is its highest index in it (only 00 can be
      there twice, as padding);
    - at a position where this byte and the next are both in the table and at least one byte
      follows them, the packer chooses between a pair run and a nibble block: a pair run (C1-FF)
      when the pair repeats at least 3 times (2 right after a full nibble block of 62 bytes, or
      when the run's 4 bytes end the data); otherwise a nibble block of up to 62 bytes that stops
      where a pair run would start;
    - elsewhere, a byte not in the table that repeats at least twice is a byte run (81-BF, up to
      63, then 2 is enough for a pair run that follows it); otherwise a literal block (01-3F) up
      to 63 bytes that stops where a nibble pair or a byte run would start.
    """
    table = make_table(data)
    code = {v: k for k, v in enumerate(table)}  # highest index wins
    n = len(data)
    out = bytearray([0]) + table
    i = 0
    fresh = False  # the previous command was a full nibble block or a byte run

    def in_table(j: int) -> bool:
        return j < n and data[j] in code

    def pair_ok(j: int) -> bool:
        return j + 2 < n and data[j] in code and data[j + 1] in code

    def pair_run(j: int) -> int:
        if not pair_ok(j):
            return 0
        a, b = data[j], data[j + 1]
        r = 1
        while r < MAX_COUNT and j + 2 * r + 1 < n and data[j + 2 * r] == a and data[j + 2 * r + 1] == b:
            r += 1
        return r

    def byte_run(j: int) -> int:
        r = 1
        while r < MAX_COUNT and j + r < n and data[j + r] == data[j]:
            r += 1
        return r

    def breaks(j: int) -> bool:
        r = pair_run(j)
        return r >= 3 or (r == 2 and j + 4 == n)

    def nib(j: int) -> int:
        return (code[data[j]] << 4) | code[data[j + 1]]

    while i < n:
        if pair_ok(i):
            r = pair_run(i)
            if r >= (2 if fresh else 3) or breaks(i):
                out += bytes([0xC0 | r, nib(i)])
                i += 2 * r
                fresh = False
                continue
            block = bytearray()
            while pair_ok(i) and len(block) < MAX_NIBBLE_BYTES and (not block or not breaks(i)):
                block.append(nib(i))
                i += 2
            out += bytes([0x40 | len(block)]) + block
            fresh = len(block) == MAX_NIBBLE_BYTES
            continue
        fresh = False
        if not in_table(i):
            r = byte_run(i)
            if r >= 2:
                out += bytes([0x80 | r, data[i]])
                i += r
                fresh = True
                continue
        lit = bytearray()
        while i < n and len(lit) < MAX_COUNT:
            if lit and pair_ok(i):
                break
            if lit and not in_table(i) and byte_run(i) >= 2:
                break
            lit.append(data[i])
            i += 1
        out += bytes([len(lit)]) + lit
    out.append(END)
    return bytes(out)
