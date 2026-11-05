#!/usr/bin/env python3
"""The JSA II sound traces of tools/mame/sndtrace.lua (`make sndtrace`, `make soundcheck`).

    tools/sndtrace.py summary --listing build/stunrun-jsa.lst --out artifacts/sndtrace-summary.json \
        build/mame/sndtrace-attract.txt build/mame/sndtrace-sound.txt build/mame/sndtrace-play.txt
    tools/sndtrace.py soundcheck --frames 3000 REFERENCE.txt REBUILT.txt

`summary` checks each trace against the 6502 source (the 64tass listing of asm/jsa): every
opcode fetch must be at the first byte of an instruction statement, every data read inside a
data statement (never an instruction's bytes or a .fill); then it writes the committed summary: per run
the frames and counters, the executed instruction bytes as address ranges, the data reads as
address ranges with the instructions that made them, the command bytes the 68010 wrote (value,
count, first frame, the 68010 instructions) and the response bytes the 6502 wrote (value,
count), the YM2151 writes and key-ons, the OKI commands; and over all runs, the instructions
that never executed. Addresses, counts and command/response values only: no ROM byte (the YM2151
and OKI write streams stay in the build/ trace files).

`soundcheck` compares two traces of the same run (the reference set and the rebuilt one): the
YM2151 and OKI write streams, the commands and the responses must be equal frame by frame up to
--frames, and the reference must have keyed on at least one YM2151 channel (register 08 with a
slot bit set): attract mode made sound.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from listings import tass_statements  # noqa: E402

IMAGE_SIZE = 0x10000
YM_KEY_ON = 0x08  # YM2151 register 08: key on/off, bits 6-3 the slots, 2-0 the channel


@dataclass
class Trace:
    header: dict[str, str] = field(default_factory=dict)
    fetch: dict[int, int] = field(default_factory=dict)  # address -> opcode fetches
    bank_fetch: dict[str, int] = field(default_factory=dict)  # "B<n>:3xxx" -> fetches
    data: dict[tuple[int, int], int] = field(default_factory=dict)  # (address, pc) -> reads
    bank_data: dict[tuple[str, int], int] = field(default_factory=dict)
    events: list[tuple[str, ...]] = field(default_factory=list)  # in order
    done: bool = False


def parse(text: str) -> Trace:
    t = Trace()
    for line in text.splitlines():
        if line == "# done":
            t.done = True
            continue
        if line.startswith("# "):
            key, _, value = line[2:].partition(" ")
            t.header[key] = value
            continue
        p = line.split()
        if not p:
            continue
        if p[0] == "F":
            if p[1].startswith("B"):
                t.bank_fetch[p[1]] = int(p[2])
            else:
                t.fetch[int(p[1], 16)] = int(p[2])
        elif p[0] == "D":
            if p[1].startswith("B"):
                t.bank_data[(p[1], int(p[2], 16))] = int(p[3])
            else:
                t.data[(int(p[1], 16), int(p[2], 16))] = int(p[3])
        elif p[0] in "CRYOWXS":
            t.events.append(tuple(p))
        else:
            raise ValueError(f"unknown trace line: {line!r}")
    return t


def read(path: Path) -> Trace:
    t = parse(path.read_text())
    if not t.done:
        raise SystemExit(f"{path}: no '# done' line (the MAME run did not finish)")
    return t


@dataclass
class Source:
    """What the listing says each address of 4000-FFFF is."""

    instr: dict[int, int]  # instruction start -> length
    data: set[int]  # bytes of data statements (.byte .word ...)
    fill: set[int]  # bytes of .fill statements
    files: dict[int, str]  # instruction start -> source file


def source(listing: str) -> Source:
    instr: dict[int, int] = {}
    data: set[int] = set()
    fill: set[int] = set()
    files: dict[int, str] = {}
    for s, size in tass_statements(listing, IMAGE_SIZE):
        if size == 0:
            continue
        if s.cls == "instr":
            instr[s.address] = size
            files[s.address] = s.file
        else:
            (fill if s.cls == "fill" else data).update(range(s.address, s.address + size))
    return Source(instr, data, fill, files)


def ranges(addresses: set[int] | list[int]) -> list[str]:
    """Sorted addresses as "XXXX-YYYY" (or "XXXX") ranges of consecutive addresses."""
    out: list[list[int]] = []
    for a in sorted(addresses):
        if out and out[-1][1] == a - 1:
            out[-1][1] = a
        else:
            out.append([a, a])
    return [f"{a:04X}" if a == b else f"{a:04X}-{b:04X}" for a, b in out]


def check(trace: Trace, src: Source, name: str) -> list[str]:
    """Disagreements between a trace and the source (empty: the trace confirms it)."""
    problems = []
    for a in sorted(trace.fetch):
        if a not in src.instr:
            problems.append(f"{name}: opcode fetch at {a:04X}, not an instruction in the source")
    code_bytes = {a + k for a, n in src.instr.items() for k in range(n)}
    for a, pc in sorted(trace.data):
        if a in code_bytes:
            problems.append(f"{name}: data read at {a:04X} (by {pc:04X}) inside an instruction")
        elif a not in src.data:
            problems.append(f"{name}: data read at {a:04X} (by {pc:04X}) not in a data statement")
        if pc != 0 and pc not in src.instr:
            problems.append(f"{name}: data read by {pc:04X}, not an instruction in the source")
    if trace.bank_fetch:
        problems.append(f"{name}: opcode fetches in the bank window: {sorted(trace.bank_fetch)}")
    return problems


def key_ons(trace: Trace) -> int:
    return sum(
        1
        for e in trace.events
        if e[0] == "Y" and int(e[2], 16) == YM_KEY_ON and int(e[3], 16) & 0x78
    )


def run_summary(trace: Trace, src: Source) -> dict[str, object]:
    executed = {a + k for a in trace.fetch for k in range(src.instr[a])}
    readers: dict[int, set[int]] = defaultdict(set)
    for a, pc in trace.data:
        readers[a].add(pc)
    # data ranges: runs of consecutive addresses, with every instruction that read in the run
    data_ranges: list[tuple[int, int, set[int]]] = []
    for a in sorted(readers):
        if data_ranges and data_ranges[-1][1] == a - 1:
            start, _, pcs = data_ranges[-1]
            data_ranges[-1] = (start, a, pcs | readers[a])
        else:
            data_ranges.append((a, a, set(readers[a])))
    count: dict[int, int] = defaultdict(int)
    first: dict[int, int] = {}
    senders: dict[int, set[int]] = defaultdict(set)
    responses: dict[int, int] = defaultdict(int)
    resets = []
    for e in trace.events:
        if e[0] == "C":
            frame, pc, value = int(e[1]), int(e[2], 16), int(e[3], 16)
            count[value] += 1
            first.setdefault(value, frame)
            senders[value].add(pc)
        elif e[0] == "R":
            responses[int(e[2], 16)] += 1
        elif e[0] == "S":
            resets.append(int(e[1]))
    ym = [e for e in trace.events if e[0] == "Y"]
    return {
        "frames": int(trace.header["frames"]),
        "play": trace.header["play"],
        "attract_sound": trace.header.get("attract_sound", "no"),
        "opcode_fetches": int(trace.header["fetches"]),
        "data_reads": int(trace.header["data"]),
        "instructions_executed": len(trace.fetch),
        "executed_bytes": len(executed),
        "executed": ranges(executed),
        "data_read_bytes": len(readers),
        "data_read": [
            {"range": ranges(set(range(a, b + 1)))[0], "by": [f"{pc:04X}" for pc in sorted(pcs)]}
            for a, b, pcs in data_ranges
        ],
        "commands": {
            f"{v:02X}": {
                "count": count[v],
                "first_frame": first[v],
                "68k_pc": [f"{p:06X}" for p in sorted(senders[v])],
            }
            for v in sorted(count)
        },
        "responses": {f"{v:02X}": n for v, n in sorted(responses.items())},
        "sound_resets_at_frame": resets,
        "ym2151_writes": len(ym),
        "ym2151_key_ons": key_ons(trace),
        "ym2151_registers_written": len({e[2] for e in ym}),
        "oki_commands": sum(1 for e in trace.events if e[0] == "O"),
        "wrio_writes": int(trace.header["wrio"]),
        "mix_writes": int(trace.header["mix"]),
    }


def summary(traces: dict[str, Trace], listing: str) -> dict[str, object]:
    src = source(listing)
    problems = [p for name, t in traces.items() for p in check(t, src, name)]
    if problems:
        raise SystemExit("\n".join(problems))
    fetched = set().union(*(set(t.fetch) for t in traces.values()))
    never = sorted(set(src.instr) - fetched)
    by_file: dict[str, int] = defaultdict(int)
    for a in never:
        by_file[src.files[a]] += 1
    return {
        "source": "asm/jsa (64tass listing build/stunrun-jsa.lst)",
        "instructions_in_source": len(src.instr),
        "instructions_executed": len(fetched),
        "instructions_never_executed": len(never),
        "never_executed_by_file": dict(sorted(by_file.items())),
        "never_executed": ranges({a + k for a in never for k in range(src.instr[a])}),
        "runs": {name: run_summary(t, src) for name, t in traces.items()},
    }


def dumps(obj: object) -> str:
    """JSON with one line per object member and every list of scalars on one line."""
    text = json.dumps(obj, indent=1)
    return re.sub(
        r"\[\s*((?:(?:\"[^\"]*\"|-?\d+),\s*)*(?:\"[^\"]*\"|-?\d+))\s*\]",
        lambda m: "[" + re.sub(r",\s+", ", ", m.group(1)) + "]",
        text,
    )


def stream(trace: Trace, kinds: str, frames: int) -> list[tuple[str, ...]]:
    return [e for e in trace.events if e[0] in kinds and int(e[1]) <= frames]


def soundcheck(reference: Trace, rebuilt: Trace, frames: int) -> list[str]:
    """Differences between the two runs (empty: equal, and the reference made sound)."""
    problems = []
    for kind, what in (
        ("Y", "YM2151 writes"),
        ("O", "OKI commands"),
        ("C", "commands"),
        ("R", "responses"),
    ):
        a, b = stream(reference, kind, frames), stream(rebuilt, kind, frames)
        if a != b:
            pairs = enumerate(zip(a, b, strict=False))
            first = next((i for i, (x, y) in pairs if x != y), min(len(a), len(b)))
            problems.append(
                f"{what} differ: {len(a)} in the reference, {len(b)} rebuilt, first difference "
                f"at event {first}"
            )
    on = sum(
        1
        for e in stream(reference, "Y", frames)
        if int(e[2], 16) == YM_KEY_ON and int(e[3], 16) & 0x78
    )
    if on == 0:
        problems.append(f"no YM2151 key-on in the first {frames} frames of the reference")
    return problems


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("summary", help="check the traces against the source, write the summary")
    s.add_argument("--listing", type=Path, required=True)
    s.add_argument("--out", type=Path, required=True)
    s.add_argument("traces", type=Path, nargs="+")
    c = sub.add_parser("soundcheck", help="compare a reference and a rebuilt trace")
    c.add_argument("--frames", type=int, required=True)
    c.add_argument("reference", type=Path)
    c.add_argument("rebuilt", type=Path)
    args = ap.parse_args(argv)
    if args.cmd == "summary":
        traces = {p.stem: read(p) for p in args.traces}
        out = summary(traces, args.listing.read_text())
        args.out.write_text(dumps(out) + "\n")
        for name, r in out["runs"].items():  # type: ignore[attr-defined]
            print(
                f"{name}: {r['frames']} frames, {r['instructions_executed']} instructions "
                f"executed, {len(r['commands'])} command values, {r['ym2151_key_ons']} YM2151 "
                f"key-ons, {r['oki_commands']} OKI commands"
            )
        print(
            f"{out['instructions_executed']} of {out['instructions_in_source']} instructions "
            f"executed; every fetch and data read agrees with the source -> {args.out}"
        )
        return 0
    ref, new = read(args.reference), read(args.rebuilt)
    problems = soundcheck(ref, new, args.frames)
    if problems:
        print("FAIL soundcheck:\n  " + "\n  ".join(problems))
        return 1
    n = len(stream(ref, "Y", args.frames))
    on = sum(
        1
        for e in stream(ref, "Y", args.frames)
        if int(e[2], 16) == YM_KEY_ON and int(e[3], 16) & 0x78
    )
    print(
        f"OK soundcheck: {args.frames} frames, {n} YM2151 writes ({on} key-ons), "
        f"{len(stream(ref, 'O', args.frames))} OKI commands, equal in both runs"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
