"""The packed GSP images as data/gsp-images and data/palettes (docs/15-gsp-images.md).

tools/gspimages is a package directory, run as `uv run python tools/gspimages <cmd>`.

    tools/gspimages asm      [--data data/gsp-images] [--palettes data/palettes] --out build/gsp-images
    tools/gspimages decode   [--image build/stunrun-68k.bin] [--data data/gsp-images]
                             [--palettes data/palettes]
    tools/gspimages check    [--data data/gsp-images] [--palettes data/palettes]
                             [--image build/stunrun-68k.bin]
    tools/gspimages palcheck [--palettes data/palettes] --bin FILE --image build/stunrun-68k.bin
    tools/gspimages trace    [--data data/gsp-images] [--image build/stunrun-68k.bin]
                             [--summary artifacts/gspimages-summary.json] TRACE ...

asm      the build step (`make`): reads the manifest and the PNGs (pixel indices only; a PNG
         whose size differs from the manifest's fails), re-encodes every stream, computes the
         adjust words and writes <out>/images.asm and <out>/table.asm (the includes of
         asm/68k/images.asm and asm/68k/image_table.asm) and <out>/palettes.asm (every palette
         of data/palettes as dc.b, for palcheck). A file is rewritten only when it changes.
decode   `make images`: reads 060000-0C0000 of the 68k image as the format (fails on any byte it
         does not explain) and rewrites the manifest and one PNG per distinct image, keeping the
         names and palette specs of the existing manifest (matched by stream and position) and
         writing each PNG's PLTE from data/palettes; removes any other PNG in --data.
check    the PNGs' PLTE against data/palettes, and with --image the region built from the data
         against the image (counts and addresses of differences only).
palcheck compares the assembled palettes (--bin, from <out>/palettes.asm) with the image at each
         palette's address: `make check` runs it; it fails on any difference.
trace    checks MAME traces of tools/mame/gspimages.lua against the decoded images and writes
         their summary (entries, frames, destinations, counts; no bytes).

Exit status 1 on a format error or a difference, 2 when an input file is absent.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from gspimages import (  # noqa: E402
    REGION,
    REGION_END,
    FormatError,
    Manifest,
    Stream,
    asm_sources,
    build,
    decode,
    entries_of,
    image_palette,
    manifest_json,
    palettes_asm,
    png,
    png_path,
    read_images,
    read_manifest,
    read_palettes,
    write_png,
)

MANIFEST = "manifest.json"


def write_if_changed(path: Path, text: str) -> None:
    if not path.exists() or path.read_text() != text:
        path.write_text(text)


def load_image(path: Path) -> bytes:
    if not path.exists():
        print(f"{path}: absent (make, with the reference set)", file=sys.stderr)
        sys.exit(2)
    return path.read_bytes()


def cmd_asm(args: argparse.Namespace) -> int:
    m = read_manifest(args.data / MANIFEST)
    images = read_images(args.data, m)
    pals = read_palettes(args.palettes)
    for name in m.images:
        image_palette(m, name, pals)  # every palette spec resolves
    images_src, table_src = asm_sources(m, images)
    pal_src, spans = palettes_asm(pals)
    args.out.mkdir(parents=True, exist_ok=True)
    write_if_changed(args.out / "images.asm", images_src)
    write_if_changed(args.out / "table.asm", table_src)
    write_if_changed(args.out / "palettes.asm", pal_src)
    write_if_changed(
        args.out / "palettes.map",
        "".join(f"{n} {a:06X} {o} {k}\n" for n, a, o, k in spans),
    )
    return 0


def _keep(old: Manifest | None, new: Manifest) -> dict[str, str]:
    """new default name -> the old manifest's name for the image at the same stream position."""
    if old is None:
        return {}
    pos = {(s.entries[0], k): n for s in old.streams for k, n in enumerate(s.images)}
    out = {}
    for s in new.streams:
        for k, n in enumerate(s.images):
            if (s.entries[0], k) in pos:
                out.setdefault(n, pos[(s.entries[0], k)])
    return out


def cmd_decode(args: argparse.Namespace) -> int:
    image = load_image(args.image)
    path = args.data / MANIFEST
    old: Manifest | None = None
    extra: dict[str, object] = {}
    if path.exists():
        old = read_manifest(path)
        raw = json.loads(path.read_text())
        extra = {k: raw[k] for k in ("comment",) if k in raw}
    dec = decode(image, old.sums if old else None)
    rename = _keep(old, dec.manifest)
    m = dec.manifest
    m.streams = [
        Stream(s.entries, s.kind, tuple(rename.get(n, n) for n in s.images)) for s in m.streams
    ]
    images = {rename.get(n, n): img for n, img in dec.images.items()}
    infos = {}
    for n, img in images.items():
        info: dict[str, object] = {}
        if old and n in old.images:
            info.update(old.images[n])
        info["width"], info["height"] = img.width, img.height
        infos[n] = info
    m.images = {n: infos[n] for n in sorted(infos, key=lambda n: _first(m, n))}
    pals = read_palettes(args.palettes)
    args.data.mkdir(parents=True, exist_ok=True)
    for n, img in images.items():
        write_png(args.data, n, img, image_palette(m, n, pals))
    for p in args.data.glob("*.png"):
        if p.stem not in images:
            p.unlink()
    path.write_text(manifest_json(m, extra))
    print(
        f"{args.data}: {len(m.streams)} streams, {len(images)} images, "
        f"{len(m.placeholders)} placeholder entries, {len(m.adjust)} adjust words"
    )
    return 0


def _first(m: Manifest, name: str) -> tuple[int, int]:
    for s in m.stream_order():
        if name in s.images:
            return (s.entries[0], s.images.index(name))
    return (999, 0)


def cmd_check(args: argparse.Namespace) -> int:
    m = read_manifest(args.data / MANIFEST)
    pals = read_palettes(args.palettes)
    bad = 0
    for name in m.images:
        want = image_palette(m, name, pals)
        have = png.read(png_path(args.data, name).read_bytes()).palette
        if have != want:
            diff = sum(1 for k in range(max(len(have), len(want)))
                       if k >= len(have) or k >= len(want) or have[k] != want[k])
            print(f"{name}.png: PLTE differs from its palette spec in {diff} entries")
            bad += 1
    print(f"PLTE: {len(m.images) - bad} of {len(m.images)} PNGs as data/palettes gives them")
    if args.image is not None:
        image = load_image(args.image)
        region, _, end = build(m, read_images(args.data, m))
        ref = image[REGION:REGION_END]
        diffs = [REGION + k for k in range(len(ref)) if ref[k] != region[k]]
        if diffs:
            print(f"region: {len(diffs)} bytes differ, the first at {diffs[0]:06X}")
            bad += 1
        else:
            print(f"region 060000-0C0000: equal to the image (streams end at {end:06X})")
    return 1 if bad else 0


def cmd_palcheck(args: argparse.Namespace) -> int:
    image = load_image(args.image)
    built = args.bin.read_bytes()
    pals = read_palettes(args.palettes)
    _, spans = palettes_asm(pals)
    bad = 0
    for name, addr, off, length in spans:
        mine = built[off : off + length]
        ref = image[addr : addr + length]
        if mine != ref:
            k = next(i for i in range(length) if i >= len(mine) or mine[i] != ref[i])
            print(f"palette {name} ({addr:06X}, {length // 3} colours): differs from the 68k image "
                  f"at colour {k // 3} (68k {addr + k:06X})")
            bad += 1
    print(f"palettes: {len(spans) - bad} of {len(spans)} equal to the 68k image at their address")
    return 1 if bad else 0


def cmd_trace(args: argparse.Namespace) -> int:
    from gspimages.trace import summary

    image = load_image(args.image)
    m = read_manifest(args.data / MANIFEST)
    doc, problems = summary(m, image, args.traces)
    for p in problems:
        print(p)
    args.summary.write_text(json.dumps(doc, indent=1) + "\n")
    names = entries_of(m)
    print(f"{args.summary}: {len(doc['entries'])} entries seen; {len(names)} images in the manifest")
    return 1 if problems else 0


def main() -> int:
    ap = argparse.ArgumentParser(prog="tools/gspimages", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    data = Path("data/gsp-images")
    pals = Path("data/palettes")
    img = Path("build/stunrun-68k.bin")

    p = sub.add_parser("asm")
    p.add_argument("--data", type=Path, default=data)
    p.add_argument("--palettes", type=Path, default=pals)
    p.add_argument("--out", type=Path, required=True)
    p.set_defaults(func=cmd_asm)

    p = sub.add_parser("decode")
    p.add_argument("--image", type=Path, default=img)
    p.add_argument("--data", type=Path, default=data)
    p.add_argument("--palettes", type=Path, default=pals)
    p.set_defaults(func=cmd_decode)

    p = sub.add_parser("check")
    p.add_argument("--data", type=Path, default=data)
    p.add_argument("--palettes", type=Path, default=pals)
    p.add_argument("--image", type=Path)
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("palcheck")
    p.add_argument("--palettes", type=Path, default=pals)
    p.add_argument("--bin", type=Path, required=True)
    p.add_argument("--image", type=Path, default=img)
    p.set_defaults(func=cmd_palcheck)

    p = sub.add_parser("trace")
    p.add_argument("--data", type=Path, default=data)
    p.add_argument("--image", type=Path, default=img)
    p.add_argument("--summary", type=Path, default=Path("artifacts/gspimages-summary.json"))
    p.add_argument("traces", type=Path, nargs="+")
    p.set_defaults(func=cmd_trace)

    args = ap.parse_args()
    try:
        return int(args.func(args))
    except FormatError as e:
        print(f"gspimages: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
