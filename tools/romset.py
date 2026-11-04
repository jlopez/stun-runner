"""The ROM set as data: the MAME snapshot, the reference set on disk, and the five build images.

Shared by tools/check-roms, tools/merge-roms, tools/split-roms and tools/bytecheck. Standard
library only. Nothing here prints a ROM byte: callers report offsets, counts and hashes.

The build works on five images, one per address space (docs/04-build.md):

    stunrun-68k    mainpcb:maincpu    768 KB, the twelve 200x/210x files as 16-bit byte pairs
    stunrun-obj    mainpcb:user1      384 KB, the six ADSP object ROMs as byte pairs
    stunrun-oki    mainpcb:jsa:oki1   256 KB, the four ADPCM files one after the other
    stunrun-jsa    mainpcb:jsa:cpu     64 KB, the 6502 file as is
    stunrun-nvram  mainpcb:200e+210e    4 KB, the two NVRAM images one after the other

Where a file lands inside its image comes from the snapshot's `offset` (MAME's ROM_LOAD
offset): a region where any file has an odd offset is a ROM_LOAD16_BYTE region, so its files
take every other byte starting at that offset (200x even = D15-D8, 210x odd = D7-D0); otherwise a
file is contiguous at its offset. An image made of several regions stacks them in the order
listed in IMAGES.
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
import zipfile
import zlib
from dataclasses import dataclass
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parents[1]
ROMSETS = REPO / "tools" / "romsets"
DEFAULT_ARCHIVE = Path(
    os.environ.get("STUNRUN_ROMS", "~/archive/261104-stun-runner/roms")
).expanduser()

# image name -> the MAME regions it holds, in order. The only hard-coded layout knowledge.
IMAGES: dict[str, tuple[str, ...]] = {
    "stunrun-68k": ("mainpcb:maincpu",),
    "stunrun-obj": ("mainpcb:user1",),
    "stunrun-oki": ("mainpcb:jsa:oki1",),
    "stunrun-jsa": ("mainpcb:jsa:cpu",),
    "stunrun-nvram": ("mainpcb:200e", "mainpcb:210e"),
}


def hashes(data: bytes) -> tuple[str, str]:
    return f"{zlib.crc32(data) & 0xFFFFFFFF:08x}", hashlib.sha1(data).hexdigest()


def load_snapshot(set_name: str) -> dict[str, Any]:
    path = ROMSETS / f"{set_name}.json"
    if not path.exists():
        sys.exit(
            f"no snapshot for set '{set_name}' at {path}; "
            f"run tools/check-roms --refresh --set {set_name}"
        )
    snapshot: dict[str, Any] = json.loads(path.read_text())
    return snapshot


def read_set(location: Path) -> dict[str, bytes] | None:
    """The set's files by name, from a directory or a zip; None when neither exists (an empty directory counts as absent)."""
    if location.is_dir():
        files = {
            p.name: p.read_bytes()
            for p in location.iterdir()
            if p.is_file() and not p.name.startswith(".")
        }
        if files:
            return files
    # <rompath>/<set>.zip (what MAME reads) or a zip dropped inside the set's folder
    for zip_path in (location.with_suffix(".zip"), location / f"{location.name}.zip"):
        if not zip_path.is_file():
            continue
        with zipfile.ZipFile(zip_path) as z:
            return {Path(i.filename).name: z.read(i) for i in z.infolist() if not i.is_dir()}
    return None


@dataclass(frozen=True)
class Placement:
    """Where one ROM file sits in one build image: bytes start, start+stride, start+2*stride..."""

    name: str
    size: int
    region: str
    image: str
    start: int  # image offset of the file's first byte
    stride: int  # 2 in a ROM_LOAD16_BYTE region, else 1
    region_offset: int  # MAME's offset of the file in its region

    def image_offset(self, i: int) -> int:
        return self.start + self.stride * i


def layout(snapshot: dict[str, Any]) -> tuple[list[Placement], dict[str, int]]:
    """Every file's placement (in snapshot order) and every image's size."""
    by_region: dict[str, list[dict[str, Any]]] = {}
    for rom in snapshot["roms"]:
        by_region.setdefault(rom["region"], []).append(rom)
    known = {r for regions in IMAGES.values() for r in regions}
    unknown = sorted(set(by_region) - known)
    if unknown:
        raise ValueError(f"regions without an image: {', '.join(unknown)}")
    where: dict[str, Placement] = {}
    sizes: dict[str, int] = {}
    for image, regions in IMAGES.items():
        base = 0
        for region in regions:
            roms = by_region.get(region, [])
            stride = 2 if any(r["offset"] % 2 for r in roms) else 1
            extent = 0
            for r in roms:
                start = base + r["offset"]
                where[r["name"]] = Placement(
                    r["name"], r["size"], region, image, start, stride, r["offset"]
                )
                extent = max(extent, r["offset"] + stride * (r["size"] - 1) + 1)
            base += extent
        sizes[image] = base
    placements = [where[r["name"]] for r in snapshot["roms"]]
    # every image byte belongs to exactly one file
    for image, size in sizes.items():
        owner = bytearray(size)
        for p in placements:
            if p.image != image:
                continue
            for i in range(p.size):
                owner[p.image_offset(i)] += 1
        if any(c != 1 for c in owner):
            raise ValueError(f"{image}: the snapshot's offsets do not tile the image exactly")
    return placements, sizes


def merge(snapshot: dict[str, Any], files: dict[str, bytes]) -> dict[str, bytes]:
    """The five images from the set's files. Raises ValueError on a missing or mis-sized file."""
    placements, sizes = layout(snapshot)
    images = {name: bytearray(size) for name, size in sizes.items()}
    for p in placements:
        data = files.get(p.name)
        if data is None:
            raise ValueError(f"missing {p.name}")
        if len(data) != p.size:
            raise ValueError(f"{p.name}: {len(data)} bytes, expected {p.size}")
        images[p.image][p.start : p.start + p.stride * p.size : p.stride] = data
    return {name: bytes(b) for name, b in images.items()}


def split(snapshot: dict[str, Any], images: dict[str, bytes]) -> dict[str, bytes]:
    """The set's files from the five images (the inverse of merge)."""
    placements, sizes = layout(snapshot)
    for name, size in sizes.items():
        got = len(images[name]) if name in images else None
        if got != size:
            raise ValueError(f"image {name}: {got} bytes, expected {size}")
    return {
        p.name: images[p.image][p.start : p.start + p.stride * p.size : p.stride]
        for p in placements
    }


def cpu_address(p: Placement, i: int) -> str:
    """Byte i of file p named in the address space of the processor that reads it."""
    if p.region == "mainpcb:maincpu":
        return f"68k ${p.image_offset(i):06X}"
    if p.region == "mainpcb:user1":
        return f"ADSP object word ${p.image_offset(i) // 2:05X}"
    if p.region == "mainpcb:jsa:cpu":
        offset = p.region_offset + i
        if offset < 0x4000:  # four 4 KB pages banked into 3000-3FFF
            return f"6502 bank {offset >> 12} ${0x3000 + (offset & 0xFFF):04X}"
        return f"6502 ${offset:04X}"
    if p.region == "mainpcb:jsa:oki1":
        return f"OKI ${p.region_offset + i:05X}"
    return f"byte ${p.region_offset + i:X}"


def compare(
    snapshot: dict[str, Any], built: dict[str, bytes], reference: dict[str, bytes]
) -> list[str]:
    """One report line per differing or missing file; empty when every file is identical.

    Offsets and counts only, never byte values (the repository is public)."""
    placements, _ = layout(snapshot)
    report = []
    for p in placements:
        b, r = built.get(p.name), reference.get(p.name)
        if r is None:
            report.append(f"{p.name}: absent from the reference set")
            continue
        if b is None:
            report.append(f"{p.name}: not built")
            continue
        diffs = [i for i in range(min(len(b), len(r))) if b[i] != r[i]]
        if len(b) != len(r):
            report.append(f"{p.name}: built {len(b)} bytes, reference {len(r)}")
        if diffs:
            first = diffs[0]
            report.append(
                f"{p.name}: {len(diffs)} differing bytes, first at file offset ${first:05X} "
                f"= {cpu_address(p, first)}"
            )
    return report
