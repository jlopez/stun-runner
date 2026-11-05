"""The object ROMs as data/objects (docs/07-objects.md); the format is in tools/objects/__init__.py.

    tools/objects decode [--image build/stunrun-obj.bin] [--out data/objects]
    tools/objects asm    [--data data/objects] [--out build/obj]
    tools/objects encode [--data data/objects] --out FILE
    tools/objects inventory [--data data/objects] [--image68k build/stunrun-68k.bin]
                            [--summary artifacts/objtrace-summary.json]
                            [--levels artifacts/objlevels-summary.json]
    tools/objects trace  [--image build/stunrun-obj.bin] [--summary artifacts/objtrace-summary.json]
                         build/mame/objtrace-attract.txt build/mame/objtrace-play.txt
    tools/objects levels [--data data/objects] [--summary artifacts/objlevels-summary.json]
                         build/mame/objlevels-*.txt
    tools/objects render [--data data/objects] [--view VIEW] [--size N] [--no-cull]
                         [--palette FILE] [--sheet [--tile N] [--columns N]] --out FILE NUMBERS
    tools/objects pictures [--data data/objects] [--out artifacts/objects]

decode   reads the image as the ADSP does and writes the manifest and one mesh file per object
         (keeps the names of the existing manifest, even when a mesh file is invalid; refuses to
         overwrite a manifest that does not parse); fails where the image is not the format,
         including a word the format does not explain outside RESIDUE_ALLOWED.
asm      writes build/obj/page0.asm .. page2.asm, the vasm sources asm/obj/objects.asm includes
         (`make`): dc.w for every decoded structure and residue constant, dcb.w for the zero
         fill. Needs data/objects only, never the ROM image.
encode   writes the image itself from data/objects (tests, experiments).
inventory prints the object table of docs/07 (numbers, addresses, counts, bounding boxes); with
         --image68k the descriptor column (the 68k descriptors that select each object) and,
         on stderr, how many objects are near objects, only far objects or in no descriptor;
         with --summary the run column (the traced runs that loaded each object); with --levels
         the levels column (the level words of the per-level runs that loaded it).
levels   reads the per-level MAME runs (tools/mame/objlevels.lua) and writes their summary
         (object numbers and counts only) to --summary.
render   draws objects to a PNG (tools/objects/render.py): NUMBERS such as 0, 0-7 or 48,50-53;
         several objects without --sheet are drawn together in their shared object space (the
         parts of one vehicle), --sheet tiles them with their numbers (a contact sheet). VIEW is
         three-quarter, rear, top, side, or all (the four in a 2 x 2 grid). --no-cull draws the
         faces that look away too; --palette a JSON list of 64 [r, g, b] for the colour indices.
pictures rewrites the pictures docs/07 shows (render.PICTURES); `make pictures`.
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
    descriptor_columns,
    descriptors,
    encode,
    inventory,
    layout_from_manifest,
    level_columns,
    levels_summary,
    read_data,
    read_levels,
    read_trace,
    run_columns,
    trace_summary,
    write_data,
)
from objects.render import (  # noqa: E402
    VIEWS,
    draw,
    parse_numbers,
    pictures,
    png,
    read_palette,
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
    a.add_argument("--out", type=Path, default=Path("build/obj"))
    e = sub.add_parser("encode")
    e.add_argument("--data", type=Path, default=DATA)
    e.add_argument("--out", type=Path, required=True)
    i = sub.add_parser("inventory")
    i.add_argument("--data", type=Path, default=DATA)
    i.add_argument("--image68k", type=Path, help="the 68k image: adds the descriptor column")
    i.add_argument("--summary", type=Path, help="objtrace summary: adds the run column")
    i.add_argument("--levels", type=Path, help="objlevels summary: adds the levels column")
    t = sub.add_parser("trace")
    t.add_argument("--image", type=Path, default=IMAGE)
    t.add_argument("--summary", type=Path)
    t.add_argument("traces", nargs="+", type=Path)
    lv = sub.add_parser("levels")
    lv.add_argument("--data", type=Path, default=DATA)
    lv.add_argument("--summary", type=Path)
    lv.add_argument("runs", nargs="+", type=Path)
    rp = sub.add_parser("render")
    rp.add_argument("--data", type=Path, default=DATA)
    rp.add_argument("--view", default="three-quarter", choices=[*VIEWS, "all"])
    rp.add_argument("--size", type=int, default=256, help="pixels (per view, or per tile)")
    rp.add_argument("--no-cull", action="store_true", help="also the faces that look away")
    rp.add_argument("--palette", type=Path, help="JSON list of 64 [r, g, b]; build/ only")
    rp.add_argument("--sheet", action="store_true", help="one tile per object, numbered")
    rp.add_argument("--tile", type=int, default=96)
    rp.add_argument("--columns", type=int, default=16)
    rp.add_argument("--out", type=Path, required=True)
    rp.add_argument("numbers", type=parse_numbers)
    pi = sub.add_parser("pictures")
    pi.add_argument("--data", type=Path, default=DATA)
    pi.add_argument("--out", type=Path, default=Path("artifacts/objects"))
    args = ap.parse_args()

    try:
        if args.cmd == "decode":
            if not args.image.exists():
                print(f"SKIP: {args.image} absent")
                return 2
            # The names come from the manifest alone, so an invalid mesh file (the usual reason to
            # re-decode) does not lose them; a manifest that does not parse stops here instead of
            # being overwritten without its names.
            names: dict[int, str] = {}
            manifest = args.out / "manifest.json"
            if manifest.exists():
                try:
                    names = layout_from_manifest(manifest.read_text())[1]
                except FormatError as err:
                    raise FormatError(
                        f"{manifest}: {err}; not overwritten (restore it or move it aside)"
                    ) from err
            decoded = decode(args.image.read_bytes())
            write_data(args.out, decoded, names)
            faces = sum(len(m.faces) for m in decoded.meshes.values())
            print(
                f"{args.out}: {len(decoded.meshes)} objects, {faces} faces, "
                f"{len(decoded.layout.residue)} residue constants"
            )
        elif args.cmd == "asm":
            layout, meshes, _ = read_data(args.data)
            args.out.mkdir(parents=True, exist_ok=True)
            for page, text in enumerate(asm_pages(layout, meshes)):
                (args.out / f"page{page}.asm").write_text(text)
            print(f"{args.out}: page0.asm-page{PAGES - 1}.asm from {len(meshes)} objects")
        elif args.cmd == "encode":
            layout, meshes, _ = read_data(args.data)
            args.out.parent.mkdir(parents=True, exist_ok=True)
            args.out.write_bytes(encode(layout, meshes))
            print(f"{args.out}: {len(meshes)} objects")
        elif args.cmd == "inventory":
            from objects import Decoded, place

            layout, meshes, names = read_data(args.data)
            rows = inventory(Decoded(layout, meshes, place(layout, meshes)))
            extra: list[tuple[str, dict[int, str]]] = []
            if args.image68k:
                if not args.image68k.exists():
                    print(f"SKIP: {args.image68k} absent")
                    return 2
                desc = descriptor_columns(descriptors(args.image68k.read_bytes()), layout.objects)
                extra.append(("descriptor", desc))
                near = sum(1 for v in desc.values() if v and not v.split(", ")[0].endswith("f"))
                none = sum(1 for v in desc.values() if not v)
                print(
                    f"{layout.objects} objects: {near} near objects of a descriptor, "
                    f"{layout.objects - near - none} only far objects, {none} in no descriptor",
                    file=sys.stderr,
                )
            if args.summary:
                summary = json.loads(args.summary.read_text())
                extra.append(("run", run_columns(summary, layout.objects)))
            if args.levels:
                lsum = json.loads(args.levels.read_text())
                extra.append(("levels", level_columns(lsum, layout.objects)))
            heads = [h for h, _ in extra]
            name = "name"
            print(
                "| "
                + " | ".join(
                    ["#", "page", "address", "vertices", "normals", "faces"]
                    + ["x", "y", "z"]
                    + heads
                    + [name]
                )
                + " |"
            )
            print("|---:|---:|---|---:|---:|---:|---|---|---|" + "---|" * len(heads) + "---|")
            for r in rows:
                box = " | ".join(f"{r.lo[k]}..{r.hi[k]}" for k in range(3))
                cols = "".join(f" {c[r.number]} |" for _, c in extra)
                print(
                    f"| {r.number} | {r.page} | {r.address:04X} | {r.vertices} | {r.normals} "
                    f"| {r.faces} | {box} |{cols} {names.get(r.number, '')} |"
                )
        elif args.cmd == "levels":
            missing = [p for p in args.runs if not p.exists()]
            if missing:
                print(f"SKIP: {missing[0]} absent")
                return 2
            layout, _, _ = read_data(args.data)
            lsum = levels_summary(layout.objects, [read_levels(p) for p in args.runs])
            if args.summary:
                args.summary.parent.mkdir(parents=True, exist_ok=True)
                args.summary.write_text(compact_lists(json.dumps(lsum, indent=2)) + "\n")
            for run in lsum["runs"]:  # type: ignore[attr-defined]
                n = len(set().union(*map(set, run["levels"].values())))
                print(
                    f"{run['run']}: start {run['start_level']}, levels "
                    f"{','.join(run['levels'])}, {n} objects"
                )
            never = lsum["objects_never_loaded"]
            print(f"{lsum['objects_loaded']} objects loaded; {len(never)} never")  # type: ignore[arg-type]
        elif args.cmd == "render":
            _, meshes, _ = read_data(args.data)
            bad = [n for n in args.numbers if n not in meshes]
            if bad:
                raise FormatError(f"no object {bad[0]}")
            palette = read_palette(args.palette) if args.palette else None
            canvas = draw(
                meshes,
                args.numbers,
                view=args.view,
                size=args.tile if args.sheet else args.size,
                sheet_mode=args.sheet,
                columns=args.columns,
                palette=palette,
                cull=not args.no_cull,
            )
            args.out.parent.mkdir(parents=True, exist_ok=True)
            args.out.write_bytes(png(canvas))
            print(f"{args.out}: {len(args.numbers)} objects, {canvas.width} x {canvas.height}")
        elif args.cmd == "pictures":
            _, meshes, _ = read_data(args.data)
            args.out.mkdir(parents=True, exist_ok=True)
            for name, data in pictures(meshes).items():
                (args.out / name).write_bytes(data)
                print(f"{args.out / name}: {len(data)} bytes")
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


if __name__ == "__main__":
    sys.exit(main())
