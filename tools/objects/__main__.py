"""The object ROMs as data/objects (docs/07-objects.md); the format is in tools/objects/__init__.py.

    tools/objects decode [--image build/stunrun-obj.bin] [--out data/objects]
    tools/objects asm    [--data data/objects] [--image build/stunrun-obj.bin] [--out build/obj]
    tools/objects encode [--data data/objects] [--image IMAGE] --out FILE
    tools/objects inventory [--data data/objects]
    tools/objects trace  [--image build/stunrun-obj.bin] [--summary artifacts/objtrace-summary.json]
                         build/mame/objtrace-attract.txt build/mame/objtrace-play.txt

decode   reads the image as the ADSP does and writes the manifest and one mesh file per object
         (keeps the manifest's names); fails where the image is not the format.
asm      writes build/obj/page0.asm .. page2.asm, the vasm sources asm/obj/objects.asm includes
         (`make`): dc.w for every decoded structure, dcb.w for the zero fill, an incbin slice of
         the image for each residue range. The image supplies only the residue words (and so the
         checksum word of their page).
encode   writes the image itself (tests, experiments).
inventory prints the object table of docs/07 (numbers, addresses, counts, bounding boxes).
trace    checks MAME traces of the ADSP's object-ROM reads (tools/mame/objtrace.lua) against the
         decoder and writes their summary (addresses and counts only) to --summary.

Output lines carry counts and addresses only, never ROM words. Exit status 1 on a format error,
2 when the image is absent.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from objects import (  # noqa: E402
    PAGES,
    FormatError,
    asm_pages,
    check_trace,
    compact_lists,
    decode,
    encode,
    inventory,
    read_data,
    read_trace,
    trace_summary,
    write_data,
)

IMAGE = Path("build/stunrun-obj.bin")
DATA = Path("data/objects")


def main() -> int:
    ap = argparse.ArgumentParser(description=(__doc__ or "").split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    d = sub.add_parser("decode")
    d.add_argument("--image", type=Path, default=IMAGE)
    d.add_argument("--out", type=Path, default=DATA)
    a = sub.add_parser("asm")
    a.add_argument("--data", type=Path, default=DATA)
    a.add_argument("--image", type=Path, default=IMAGE)
    a.add_argument("--out", type=Path, default=Path("build/obj"))
    a.add_argument(
        "--incbin", default="../../build/stunrun-obj.bin", help="the image as the sources name it"
    )
    e = sub.add_parser("encode")
    e.add_argument("--data", type=Path, default=DATA)
    e.add_argument("--image", type=Path, help="supplies the residue words")
    e.add_argument("--out", type=Path, required=True)
    i = sub.add_parser("inventory")
    i.add_argument("--data", type=Path, default=DATA)
    t = sub.add_parser("trace")
    t.add_argument("--image", type=Path, default=IMAGE)
    t.add_argument("--summary", type=Path)
    t.add_argument("traces", nargs="+", type=Path)
    args = ap.parse_args()

    try:
        if args.cmd == "decode":
            if not args.image.exists():
                print(f"SKIP: {args.image} absent")
                return 2
            names: dict[int, str] = {}
            if (args.out / "manifest.json").exists():
                names = read_data(args.out)[2] if _complete(args.out) else {}
            decoded = decode(args.image.read_bytes())
            write_data(args.out, decoded, names)
            faces = sum(len(m.faces) for m in decoded.meshes.values())
            print(
                f"{args.out}: {len(decoded.meshes)} objects, {faces} faces, "
                f"{len(decoded.layout.residue)} residue ranges "
                f"({sum(r.words for r in decoded.layout.residue)} words)"
            )
        elif args.cmd == "asm":
            layout, meshes, _ = read_data(args.data)
            image = args.image.read_bytes() if args.image.exists() else None
            if image is None and layout.residue:
                print(f"{args.image} absent: needed for {len(layout.residue)} residue ranges")
                return 2
            args.out.mkdir(parents=True, exist_ok=True)
            for page, text in enumerate(asm_pages(layout, meshes, image, args.incbin)):
                (args.out / f"page{page}.asm").write_text(text)
            print(f"{args.out}: page0.asm-page{PAGES - 1}.asm from {len(meshes)} objects")
        elif args.cmd == "encode":
            layout, meshes, _ = read_data(args.data)
            image = args.image.read_bytes() if args.image else None
            args.out.parent.mkdir(parents=True, exist_ok=True)
            args.out.write_bytes(encode(layout, meshes, image))
            print(f"{args.out}: {len(meshes)} objects")
        elif args.cmd == "inventory":
            from objects import Decoded, place

            layout, meshes, names = read_data(args.data)
            rows = inventory(Decoded(layout, meshes, place(layout, meshes)))
            print("| # | page | address | vertices | normals | faces | x | y | z | name |")
            print("|---|---|---|---|---|---|---|---|---|---|")
            for r in rows:
                box = " | ".join(f"{r.lo[k]}..{r.hi[k]}" for k in range(3))
                print(
                    f"| {r.number} | {r.page} | {r.address:04X} | {r.vertices} | {r.normals} "
                    f"| {r.faces} | {box} | {names.get(r.number, '')} |"
                )
        elif args.cmd == "trace":
            if not args.image.exists() or not all(p.exists() for p in args.traces):
                print("SKIP: image or traces absent")
                return 2
            image = args.image.read_bytes()
            decoded = decode(image)
            runs = [read_trace(p) for p in args.traces]
            problems = [p for run in runs for p in check_trace(decoded, image, run)]
            for line in problems[:20]:
                print(line)
            summary = trace_summary(decoded, runs)
            if args.summary:
                args.summary.parent.mkdir(parents=True, exist_ok=True)
                args.summary.write_text(compact_lists(json.dumps(summary, indent=2)) + "\n")
            for r in summary["runs"]:  # type: ignore[attr-defined]
                print(f"{r['run']}: {r['sequences']} sequences, {len(r['objects_loaded'])} objects")
            never = summary["objects_never_loaded"]
            print(f"{len(problems)} problems; {len(never)} objects never loaded")  # type: ignore[arg-type]
            return 1 if problems else 0
    except FormatError as err:
        print(f"FAIL: {err}", file=sys.stderr)
        return 1
    return 0


def _complete(root: Path) -> bool:
    try:
        read_data(root)
    except (FormatError, OSError):
        return False
    return True


if __name__ == "__main__":
    sys.exit(main())
