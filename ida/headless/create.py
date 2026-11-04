"""Create the IDA databases headlessly from the build images (docs/05-ida.md).

    uv run python -m ida.headless.create [68k|jsa|all] [--build DIR] [--out DIR] [--snapshots DIR]

`data/stunrun-68k.i64` from `build/stunrun-68k.bin`, `data/stunrun-jsa.i64` from
`build/stunrun-jsa.bin` (`make` makes the images). Each is set up from `ida.memory_map`,
auto-analysed, then given the committed snapshot `data/ida/<name>.json` when it exists. The
databases embed the ROM bytes: they are gitignored build artefacts, never committed.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from ida.headless import BUILD, DATA, SNAPSHOTS, create_database
from ida.memory_map import DATABASES
from ida.snapshot import loads


def create_one(key: str, build: Path, out: Path, snapshots: Path) -> None:
    spec = DATABASES[key]
    image = build / f"{spec.name}.bin"
    if not image.exists():
        raise SystemExit(f"{image} is missing (make)")
    snapshot_path = snapshots / f"{spec.name}.json"
    snapshot = loads(snapshot_path.read_text()) if snapshot_path.exists() else None
    target = out / f"{spec.name}.i64"
    create_database(image, target, spec.processor, spec.setup(image.read_bytes()), snapshot)
    applied = f"setup + {snapshot_path}" if snapshot else "setup only (no snapshot yet)"
    print(f"{target}: {spec.processor}, {applied}")


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("which", nargs="?", default="all", choices=[*DATABASES, "all"])
    ap.add_argument("--build", type=Path, default=BUILD, help="directory of the images")
    ap.add_argument("--out", type=Path, default=DATA, help="directory of the databases")
    ap.add_argument("--snapshots", type=Path, default=SNAPSHOTS, help="committed snapshots")
    args = ap.parse_args(argv)
    if args.which != "all":
        create_one(args.which, args.build, args.out, args.snapshots)
        return
    # idalib holds one database per process: one child process per database.
    for key in DATABASES:
        cmd = [sys.executable, "-m", "ida.headless.create", key]
        cmd += [
            "--build",
            str(args.build),
            "--out",
            str(args.out),
            "--snapshots",
            str(args.snapshots),
        ]
        subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
