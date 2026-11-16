"""MAME's executed 68010 PCs (`make pccov`, tools/mame/pccov.lua; docs/14 section 6).

`read_trace` drains the debugger's trace pipe into the distinct PCs and writes them to a run file
(build/mame/pccov-<run>.txt: "# key value" header lines, then one PC per line, sorted). `check`
fails unless every executed PC is the first byte of a `code` instruction of the classification;
`summary` writes artifacts/pccov-summary.json: per run the frames, the number of distinct PCs
and the executed PCs as ranges of consecutive instructions (start, end of the last instruction),
plus the union; the runs in name order, so a re-run with the same PCs rewrites the same file.
Addresses and counts only.

A run file is valid only with PCs and the `# run` line `make pccov` appends from the Lua script's
done marker (`valid`): a trace the debugger never wrote (MAME exits 0 and the script still
writes its marker when `trace` fails) gives an empty file, which would pass the check vacuously
and let `classify` drop the MAME entries.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

TRACE_PC = re.compile(r"^([0-9A-Fa-f]{6,8}): ")


def read_trace(fifo: Path, out: Path) -> int:
    """Read the trace (a pipe or a file) to its end; write the distinct PCs to out."""
    pcs: set[int] = set()
    lines = 0
    with open(fifo, encoding="latin-1", errors="replace") as f:
        for line in f:
            lines += 1
            m = TRACE_PC.match(line)
            if m:
                pcs.add(int(m.group(1), 16))
    out.write_text(
        f"# trace_lines {lines}\n# distinct_pcs {len(pcs)}\n"
        + "".join(f"{pc:06X}\n" for pc in sorted(pcs))
    )
    return len(pcs)


def valid(header: dict[str, str], pcs: set[int]) -> str | None:
    """Why a run file cannot be used (no PCs, no `# run` line), or None."""
    if not pcs:
        return "no executed PC: the trace is empty (did the debugger's trace command fail?)"
    if not header.get("run"):
        return ("no `# run` line: the run did not finish (make pccov appends it from the done "
                "marker)")
    return None


def load_run(path: Path) -> tuple[dict[str, str], set[int]]:
    header: dict[str, str] = {}
    pcs: set[int] = set()
    for line in path.read_text().splitlines():
        if line.startswith("# "):
            k, _, v = line[2:].partition(" ")
            header[k] = v
        elif line.strip():
            pcs.add(int(line, 16))
    return header, pcs


def ranges(pcs: set[int], lengths: dict[int, int]) -> list[list[str]]:
    """Runs of executed instructions that follow each other in the image."""
    out: list[list[int]] = []
    for pc in sorted(pcs):
        end = pc + lengths.get(pc, 2)
        if out and out[-1][1] == pc:
            out[-1][1] = end
        else:
            out.append([pc, end])
    return [[f"{a:06X}", f"{b:06X}"] for a, b in out]


def check(pcs: set[int], starts: set[int]) -> list[int]:
    """The executed PCs that are not the start of a classified instruction."""
    return sorted(pc for pc in pcs if pc not in starts)


def summary(runs: dict[str, tuple[dict[str, str], set[int]]], lengths: dict[int, int],
            done: dict[str, str]) -> str:
    out: dict[str, object] = {"format": "stunrun-pccov 1", "runs": {}}
    allpcs: set[int] = set()
    for name, (_header, pcs) in sorted(runs.items()):  # by name: a re-run gives the same file
        allpcs |= pcs
        rs = ranges(pcs, lengths)
        out["runs"][name] = {  # type: ignore[index]
            "run": done.get(name, ""),
            "distinct_pcs": len(pcs),
            "boot_pcs": sum(1 for p in pcs if p < 0x20000),
            "game_pcs": sum(1 for p in pcs if p >= 0x20000),
            "executed_bytes": sum(lengths.get(p, 2) for p in pcs),
            "ranges": len(rs),
        }
    rs = ranges(allpcs, lengths)
    out["union"] = {
        "distinct_pcs": len(allpcs),
        "executed_bytes": sum(lengths.get(p, 2) for p in allpcs),
        "ranges": rs,
    }
    text = json.dumps(out, indent=1)
    # one range per line
    return re.sub(r"\[\s*\"([0-9A-F]+)\",\s*\"([0-9A-F]+)\"\s*\]", r'["\1", "\2"]', text) + "\n"
