"""The moved-build experiment (M5d, docs/17 section 5; `make movedcheck`).

How far is the 68k tree from relocatable? The tree is copied with a pad of zero bytes inserted
before the game code (after `game/vectors.asm`, at 020430), so every label of the game code, the
island and the data moves by the pad while the boot program, the coprocessor programs, the game
vector table (020000, installed by `movec` at 000294) and pairs U-W stay where they are: the fill
at 05CF86 (`dcb.b $060000-*,0`) is shorter by the pad. The guards are commented out (they name the
original addresses) and the incbin paths made absolute; the generated includes are copied the same
way. What is still blob keeps its bytes: a pointer in it still names the old address.

`compare` reads the per-frame logs of tools/mame/movedcheck.lua for the reference set and the moved
one and reports, per stream (the GSP host port, the ADSP, the sound latch), the first frame whose
writes differ. No ROM byte is written anywhere but build/.
"""

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass, field
from pathlib import Path

from . import listing as ls

ANCHOR = '\tinclude\t"game/vectors.asm"\n'
STREAMS = ("gsp", "adsp", "snd")


def moved_tree(tree: Path, build: Path, out: Path, pad: int) -> Path:
    """Copy `tree` to out/asm/68k with `pad` zero bytes after game/vectors.asm; returns the main
    file. Generated includes of `build` are copied to out/gen."""
    if pad <= 0 or pad % 2:
        raise ValueError("the pad is a positive even number of bytes (68010 word alignment)")
    work = out / "asm/68k"
    gen = out / "gen"
    if work.exists():
        shutil.rmtree(work)
    if gen.exists():
        shutil.rmtree(gen)
    shutil.copytree(tree, work)
    built = build.resolve()

    def fix(text: str) -> str:
        text = re.sub(r"^(\s+)assert\b", r"\1; assert", text, flags=re.M)

        def include(m: re.Match[str]) -> str:
            dst = gen / m[2]
            if not dst.exists():
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.write_text(fix((built / m[2]).read_text()))
            return f'{m[1]}"{dst.resolve()}"'

        text = re.sub(r'^(\s+include\s+)"\.\./\.\./build/([^"]+)"', include, text,
                      flags=re.M | re.I)
        return text.replace('"../../build/', f'"{built}/')

    for f in work.rglob("*.asm"):
        text = fix(f.read_text())
        if f.name == "stunrun.asm":
            if text.count(ANCHOR) != 1:
                raise ValueError("stunrun.asm: no single include of game/vectors.asm")
            text = text.replace(ANCHOR, ANCHOR + f"\tdcb.b\t{pad},0\t; the moved-build pad\n")
        f.write_text(text)
    return work / "stunrun.asm"


def build_moved(tree: Path, build: Path, out: Path, pad: int,
                vasm: str = "vasmm68k_mot") -> bytes:
    """The moved 68k image, assembled into out/stunrun-68k.out (and its listing)."""
    main = moved_tree(tree, build, out, pad)
    image, _ = ls.assemble(main, out / "stunrun-68k.out", vasm)
    if len(image) != 0x0C0000:
        raise ValueError(f"the moved image is {len(image):X} bytes, not C0000")
    return image


@dataclass
class Run:
    frames: dict[int, dict[str, tuple[int, int]]] = field(default_factory=dict)
    header: dict[str, str] = field(default_factory=dict)


LINE = re.compile(r"^f (\d+)((?: \w+ \d+ [0-9A-F]{8})+)$")


def load(path: Path) -> Run:
    run = Run()
    for line in path.read_text().splitlines():
        if line.startswith("# "):
            k, _, v = line[2:].partition(" ")
            run.header[k] = v
            continue
        m = LINE.match(line)
        if not m:
            continue
        parts = m[2].split()
        run.frames[int(m[1])] = {parts[k]: (int(parts[k + 1]), int(parts[k + 2], 16))
                                 for k in range(0, len(parts), 3)}
    return run


def compare(ref: Run, moved: Run) -> dict[str, int | None]:
    """The first frame each stream differs in (count or hash), None when it never does over the
    frames both runs logged."""
    out: dict[str, int | None] = {}
    common = sorted(set(ref.frames) & set(moved.frames))
    for s in STREAMS:
        out[s] = next((f for f in common if ref.frames[f].get(s) != moved.frames[f].get(s)), None)
    return out


def summary(name: str, ref: Run, moved: Run) -> str:
    first = compare(ref, moved)
    common = sorted(set(ref.frames) & set(moved.frames))
    resets = [f"{who} reset at frame {r.header['reset_at_frame']}"
              for who, r in (("reference", ref), ("moved", moved)) if "reset_at_frame" in r.header]
    lines = [f"{name}: {len(common)} frames compared (reference {len(ref.frames)}, moved "
             f"{len(moved.frames)})" + (f"; {', '.join(resets)}" if resets else "")]
    for s in STREAMS:
        f = first[s]
        total = sum(ref.frames[x][s][0] for x in common if s in ref.frames[x])
        if f is None:
            lines.append(f"  {s}: equal in every frame ({total} writes)")
        else:
            r, m = ref.frames[f].get(s, (0, 0)), moved.frames[f].get(s, (0, 0))
            lines.append(f"  {s}: first differs at frame {f} (writes, hash: reference {r[0]} "
                         f"{r[1]:08X}, moved {m[0]} {m[1]:08X})")
    return "\n".join(lines)


MOVING = (0x020430, 0x05CF86)  # what the pad moves: the game code, the island, the data
DATA = (0x046AEE, 0x05CF86)


def candidates(lst: ls.Listing, image: bytes, least: int = 4) -> list[tuple[int, int]]:
    """A worklist for the naming legs, not evidence (decision C18): the runs of at least `least`
    consecutive longs at even addresses inside incbin slices of the moving range whose value
    (bit 31 ignored, a flag in the level lists, docs/17 section 5) lies in the data, or is an
    even address of the game code: (start, end) of each run."""
    spans = [(s.address, s.address + s.size) for s in lst.statements
             if s.kind == "blob" and MOVING[0] <= s.address < MOVING[1]]
    runs: list[list[int]] = []
    for a, e in spans:
        x = a + (a & 1)
        while x + 4 <= e:
            v = int.from_bytes(image[x : x + 4], "big") & 0x7FFFFFFF
            if DATA[0] <= v < DATA[1] or (MOVING[0] <= v < DATA[0] and v % 2 == 0):
                if runs and runs[-1][1] == x:
                    runs[-1][1] = x + 4
                else:
                    runs.append([x, x + 4])
                x += 4
            else:
                x += 2
    return [(r[0], r[1]) for r in runs if (r[1] - r[0]) // 4 >= least]
