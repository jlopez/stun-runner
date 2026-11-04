"""The S.T.U.N. Runner IDA databases without the IDA GUI (idalib), after Spindizzy's recipe.

Requirements (one-time, docs/05-ida.md): `uv sync --group ida` and an activated idalib
(`~/.idapro/ida-config.json`, written by IDA's `py-activate-idalib.py`).

    from ida.headless import DATA, database
    with database(DATA / "stunrun-68k.i64"):   # a read-only copy, never saved
        import idautils
        print(len(list(idautils.Functions())))

`idapro` must be imported before any other IDA module; both helpers do that. The databases are
build artefacts made by `create_database` (`make ida`), never committed (they embed the ROM
bytes); the repository commits their annotation snapshots (`ida.snapshot`).
"""

from __future__ import annotations

import shutil
import tempfile
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

from ida.snapshot import Snapshot

REPO_ROOT = Path(__file__).resolve().parents[2]
DATA = REPO_ROOT / "data"
SNAPSHOTS = DATA / "ida"
BUILD = REPO_ROOT / "build"

# IDA's unpacked database components, next to the .i64 while it is open.
_COMPONENTS = (".id0", ".id1", ".id2", ".nam", ".til")


@contextmanager
def database(path: Path, *, write: bool = False) -> Iterator[Path]:
    """Open an IDA database headlessly and yield the path actually opened.

    By default the database is copied to a temporary directory and never saved; `write=True`
    opens it in place and saves on exit."""
    import idapro  # noqa: F401  (must be the first IDA import)

    if not path.exists():
        raise FileNotFoundError(f"{path} (make ida)")
    tmpdir = None if write else tempfile.mkdtemp(prefix="stunrun-ida-")
    target = path if tmpdir is None else Path(tmpdir) / path.name
    if tmpdir is not None:
        shutil.copy2(path, target)
    rc = idapro.open_database(str(target), run_auto_analysis=False)
    if rc != 0:
        raise RuntimeError(f"idapro.open_database({target}) returned {rc}")
    try:
        yield target
    finally:
        idapro.close_database(save=write)
        if tmpdir is not None:
            shutil.rmtree(tmpdir, ignore_errors=True)


def create_database(
    image: Path, out: Path, processor: str, setup: Snapshot, snapshot: Snapshot | None = None
) -> None:
    """Make `out` (.i64) from the raw image: processor `processor` (IDA's -p name), the
    loader's segments that `setup` does not have removed, `setup` applied (segments with their
    bytes, names, vectors), auto-analysis, then the committed `snapshot` applied and the analysis it triggers, then saved.

    idalib's `open_database` takes IDA command-line switches: `-p<processor>` selects the
    processor module for a file the loaders see as a binary file, `-o<file>` the output database.
    Neither path may contain a space (the switches are split on whitespace)."""
    import idapro  # (must be the first IDA import)

    for path in (image, out):
        if " " in str(path.resolve()):
            raise ValueError(f"{path}: idalib switches cannot carry a path with spaces")
    out.parent.mkdir(parents=True, exist_ok=True)
    for stale in [out, *(out.with_suffix(s) for s in _COMPONENTS)]:
        stale.unlink(missing_ok=True)
    rc = idapro.open_database(str(image), False, f"-p{processor} -o{out.resolve()}")
    if rc != 0:
        raise RuntimeError(f"idapro.open_database({image}, -p{processor}) returned {rc}")
    saved = False
    try:
        import ida_auto
        import ida_ida
        import ida_segment

        from ida.headless.idadb import IdaDatabase
        from ida.snapshot import apply

        if ida_ida.inf_get_procname().lower() != processor.lower():
            raise RuntimeError(f"processor is {ida_ida.inf_get_procname()}, not {processor}")
        # Keep a loader segment that is already right (the 68k ROM: the binary loader has marked
        # its typical code sequences), remove the others (the 6502 file loaded flat at 0).
        wanted = {(s.start, s.end) for s in setup.segments}
        for seg in [ida_segment.getnseg(i) for i in range(ida_segment.get_segm_qty())]:
            if (seg.start_ea, seg.end_ea) not in wanted:
                flags = ida_segment.SEGMOD_KILL | ida_segment.SEGMOD_SILENT
                ida_segment.del_segm(seg.start_ea, flags)
        db = IdaDatabase(image.read_bytes())
        apply(setup, db)
        ida_auto.auto_wait()
        if snapshot is not None:
            apply(snapshot, db)
            ida_auto.auto_wait()
        saved = True
    finally:
        idapro.close_database(save=saved)
