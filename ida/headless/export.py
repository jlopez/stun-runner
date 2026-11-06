"""Export the IDA databases headlessly (docs/05-ida.md).

    uv run python -m ida.headless.export [68k|jsa|all] [--data DIR] [--out DIR] [--listing DIR]

Per database `data/<name>.i64` (opened as a read-only copy):

- `data/ida/<name>.json`: the annotation snapshot (`ida.snapshot`), committed;
- `data/ida/<name>.functions.jsonl`: one function per line (`ida.headless.functions`), committed;
- `build/ida/<name>.asm`: IDA's listing, which contains the bytes: build output, never committed.

Export before committing: the snapshot is what the next `make ida` re-applies.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

from ida.headless import BUILD, DATA, SNAPSHOTS, database
from ida.memory_map import DATABASES


def export_one(key: str, data: Path, out: Path, listing: Path) -> None:
    name = DATABASES[key].name
    with database(data / f"{name}.i64"):
        import ida_fpro
        import ida_ida
        import ida_loader

        from ida.headless.functions import collect_all_functions
        from ida.headless.idadb import IdaDatabase
        from ida.snapshot import dumps, export

        out.mkdir(parents=True, exist_ok=True)
        spec = DATABASES[key]
        snapshot = export(IdaDatabase(), name, ida_ida.inf_get_procname(), spec.classified)
        (out / f"{name}.json").write_text(dumps(snapshot))
        functions = collect_all_functions()
        with open(out / f"{name}.functions.jsonl", "w") as f:
            for record in functions:
                f.write(json.dumps(record) + "\n")
        # The listing stops at the last segment with bytes: the 68k I/O and RAM segments
        # would add millions of `ds.b 1` lines.
        end = max(s.end for s in snapshot.segments if s.file_offset is not None)
        listing.mkdir(parents=True, exist_ok=True)
        fp = ida_fpro.qfile_t()
        if not fp.open(str(listing / f"{name}.asm"), "w"):
            raise OSError(f"cannot write {listing / name}.asm")
        try:
            lines = ida_loader.gen_file(ida_loader.OFILE_ASM, fp.get_fp(), 0, end, 0)
        finally:
            fp.close()
        print(
            f"{name}: {len(functions)} functions, {len(snapshot.names)} names, "
            f"{len(snapshot.comments)} comments -> {out}; {lines} listing lines -> {listing}"
        )


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("which", nargs="?", default="all", choices=[*DATABASES, "all"])
    ap.add_argument("--data", type=Path, default=DATA, help="directory of the databases")
    ap.add_argument("--out", type=Path, default=SNAPSHOTS, help="snapshots and functions.jsonl")
    ap.add_argument("--listing", type=Path, default=BUILD / "ida", help=".asm listings")
    args = ap.parse_args(argv)
    if args.which != "all":
        export_one(args.which, args.data, args.out, args.listing)
        return
    for key in DATABASES:
        cmd = [sys.executable, "-m", "ida.headless.export", key]
        cmd += ["--data", str(args.data), "--out", str(args.out), "--listing", str(args.listing)]
        subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
