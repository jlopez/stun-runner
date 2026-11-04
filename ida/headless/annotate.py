"""Re-apply the setup (memory map, vector tables, code map) over existing databases.

    uv run python -m ida.headless.annotate [68k|jsa|all] [--build DIR] [--data DIR]

`make ida` applies the setup first and the committed snapshot last, so a name the setup changes
(ida/memory_map.py, ida/code_map.py) loses to the old one in the snapshot. Run this once after
such a change (`make ida-annotate`), then `make ida-export` to rewrite the snapshot; from then
on `make ida` reproduces it. The databases are opened in place and saved.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from ida.headless import BUILD, DATA, database
from ida.memory_map import DATABASES


def annotate_one(key: str, build: Path, data: Path) -> None:
    spec = DATABASES[key]
    image = (build / f"{spec.name}.bin").read_bytes()
    setup = spec.setup(image)
    with database(data / f"{spec.name}.i64", write=True):
        import ida_auto

        from ida.headless.idadb import IdaDatabase
        from ida.snapshot import apply

        apply(setup, IdaDatabase(image))
        ida_auto.auto_wait()
    print(f"{spec.name}: setup re-applied ({len(setup.names)} names, {len(setup.comments)} comments)")


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("which", nargs="?", default="all", choices=[*DATABASES, "all"])
    ap.add_argument("--build", type=Path, default=BUILD, help="directory of the images")
    ap.add_argument("--data", type=Path, default=DATA, help="directory of the databases")
    args = ap.parse_args(argv)
    if args.which != "all":
        annotate_one(args.which, args.build, args.data)
        return
    for key in DATABASES:  # idalib holds one database per process
        cmd = [sys.executable, "-m", "ida.headless.annotate", key]
        cmd += ["--build", str(args.build), "--data", str(args.data)]
        subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
