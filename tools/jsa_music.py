#!/usr/bin/env python3
"""The sequencer's data in asm/jsa/data (docs/12-sound-music.md): the op table, the statement
parser, the stream walker and the summary of `make musictrace`.

    tools/jsa_music.py summary --listing build/stunrun-jsa.lst \
        --out artifacts/musictrace-summary.json build/mame/musictrace.txt

The op table is what the interpreter's handlers read (sequencer.asm: run_op 505D hands every
handler the byte after the op; each call of next_operand 507B reads one more): the length of
every op and where its address operands are. `statements` reads the data files the way 64tass
lays them out (one macro or .word line after another from each file's start guard) and `walk`
follows the streams through an assembled image from their starts as the interpreter would:
tools/test_jsa_music.py checks that both agree on every byte of the data region. `summary`
checks the MAME run against the source (every statement the reader took is a statement start
of the source, never an operand byte inside one) and writes the committed summary: per
injected command the sound and its key-ons, the entries started, the ops dispatched, the
streams whose statements were read, the key-ons per sound and channel. The data files and the
region's bounds come from jsa.asm's includes and the files' guards. Addresses, labels, counts and command/sound numbers only: no ROM byte.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PATCH_SIZE = 0x2A
GUARD = re.compile(r"^\s+\.cerror \* != \$([0-9A-Fa-f]{4}),")


def data_files(tree: Path = REPO / "asm/jsa") -> list[str]:
    """The data region's files: the data/ includes of jsa.asm after data/sounds.asm (the
    sounds table, not part of the region) up to the first include outside data/ (lookup.asm).
    A file split or renamed in jsa.asm is followed here without an edit."""
    out: list[str] = []
    seen_sounds = False
    for raw in (tree / "jsa.asm").read_text().splitlines():
        m = re.match(r'^\s+\.include "([^"]+)"', raw)
        if not m:
            continue
        name = m.group(1)
        if name == "data/sounds.asm":
            seen_sounds = True
        elif seen_sounds:
            if not name.startswith("data/"):
                break
            out.append(name)
    if not out:
        raise ValueError("jsa.asm: no data/ include after data/sounds.asm")
    return out


def data_bounds(tree: Path = REPO / "asm/jsa", files: list[str] | None = None) -> tuple[int, int]:
    """The region's first address and the address after it: the first file's first guard and the
    last file's last guard (each data file opens and closes with `.cerror * != $addr`)."""
    files = data_files(tree) if files is None else files

    def guards(name: str) -> list[int]:
        return [int(m.group(1), 16) for line in (tree / name).read_text().splitlines()
                if (m := GUARD.match(line))]

    first, last = guards(files[0]), guards(files[-1])
    if not first or not last:
        raise ValueError("a data file without its start and end guards")
    return first[0], last[-1]


DATA_FILES = data_files()
DATA_LO, DATA_HI = data_bounds(files=DATA_FILES)  # 65E6, AB48: the streams and patch records


@dataclass(frozen=True)
class Op:
    """A stream op: its macro, its length in bytes, how the stream goes on, where its address
    operand is (offset from the op byte, 0: none) and the label of its handler."""

    macro: str
    length: int
    flow: str  # next, call, jump, branch, table, stop, hang (never returns)
    pointer: int
    handler: str


def _ops() -> dict[int, Op]:
    two = {
        0x82: ("volume", "op_volume"),
        0x83: ("volume_add", "op_volume_add"),
        0x84: ("transpose", "op_transpose"),
        0x85: ("transpose_add", "op_transpose_add"),
        0x88: ("sync", "op_sync"),
        0x89: ("sync_group", "op_sync_group"),
        0x8A: ("ctl_bits", "op_ctl_bits"),
        0x8B: ("ctl_set", "op_ctl_set"),
        0x8C: ("portamento", "op_portamento"),
        0x8E: ("loop", "op_loop"),
        0x8F: ("loop_end", "op_loop_end"),
        0x95: ("oki", "op_95"),
        0x96: ("respond", "op_respond"),
        0x97: ("release", "op_release"),
        0x9B: ("ctl_clear", "op_ctl_clear"),
        0xA0: ("pan", "op_pan"),
        0xA1: ("carrier_tl_sub", "op_carrier_tl_sub"),
        0xA2: ("velocity", "op_velocity"),
        0xA3: ("velocity_add", "op_velocity_add"),
        0xA5: ("ym_ct", "cmdtype_11"),
        0xA6: ("fine_tune", "op_fine_tune"),
        0xA7: ("bend", "op_bend"),
        0xA8: ("fade_mode", "op_fade_mode"),
        0xA9: ("var_add", "op_var_add"),
        0xAA: ("var_sub", "op_var_sub"),
        0xAB: ("var_and", "op_var_and"),
        0xAC: ("var_or", "op_var_or"),
        0xAD: ("var_xor", "op_var_xor"),
        0xB0: ("var_store", "op_var_store"),
        0xB1: ("var_add_to", "op_var_add_to"),
        0xB2: ("var_load", "op_var_load"),
        0xB3: ("var_shr", "op_var_shr"),
        0xB4: ("var_shl", "op_var_shl"),
        0xB9: ("var_cmp_reg", "op_var_cmp_reg"),
        0xBA: ("var_cmp", "op_var_cmp"),
    }
    ops = {op: Op(m, 2, "next", 0, h) for op, (m, h) in two.items()}
    for op in (0x90, 0x91, 0x92, 0x93, 0x94, 0x98, 0x9A, 0x9C):
        ops[op] = Op("hang_op", 2, "hang", 0, "read_item")  # re-dispatches itself (484B)
    ops[0x80] = Op("tempo", 3, "next", 0, "op_tempo")
    ops[0x81] = Op("tempo_add", 3, "next", 0, "op_tempo_add")
    ops[0x86] = Op("pitch_env", 3, "next", 1, "op_pitch_env")
    ops[0x87] = Op("level_env", 3, "next", 1, "op_level_env")
    ops[0x8D] = Op("call", 3, "call", 1, "op_call")
    ops[0x99] = Op("jump", 3, "jump", 1, "op_jump")
    ops[0x9D] = Op("patch", 3, "next", 1, "op_patch")
    ops[0x9E] = Op("lfo", 3, "next", 1, "op_lfo")
    ops[0x9F] = Op("noise", 3, "next", 1, "op_noise")
    ops[0xA4] = Op("fade", 3, "next", 0, "op_fade")
    ops[0xAE] = Op("jump_table", 1, "table", 0, "op_jump_table")
    ops[0xAF] = Op("jump_table_inc", 1, "table", 0, "op_jump_table_inc")
    ops[0xB5] = Op("branch_zero", 4, "branch", 2, "op_branch_zero")
    ops[0xB6] = Op("branch_nonzero", 4, "branch", 2, "op_branch_nonzero")
    ops[0xB7] = Op("branch_plus", 4, "branch", 2, "op_branch_plus")
    ops[0xB8] = Op("branch_minus", 4, "branch", 2, "op_branch_minus")
    return ops


OPS = _ops()
NOTE_MACROS = {"note": 2, "rest": 2, "ret": 2}
PATCH_MACROS = {"ym_voice": 4, "ym_operator": 6, "ym_scaling": 2, "ym_lfo": 4, "ym_noise": 2}
MACRO_SIZE: dict[str, int] = {
    **NOTE_MACROS,
    **PATCH_MACROS,
    **{op.macro: op.length for op in OPS.values()},
    "stop": 1,
}


@dataclass
class Statement:
    file: str
    line: int
    address: int
    name: str  # a macro, or ".word"
    args: list[str]
    size: int
    labels: list[str] = field(default_factory=list)
    comment: str = ""


LABEL = re.compile(r"^([A-Za-z]\w*)\s*(;.*)?$")


def split_args(text: str) -> list[str]:
    return [a.strip() for a in text.split(",")] if text.strip() else []


def statements(tree: Path = REPO / "asm/jsa", files: list[str] | None = None) -> list[Statement]:
    """The data files' statements in address order, each address counted from the file's start
    guard. Raises ValueError on a line that is not a label, a macro statement, a .word of
    labels, a guard, a comment or blank (a raw .byte, for one)."""
    out: list[Statement] = []
    for name in data_files(tree) if files is None else files:
        address: int | None = None
        pending: list[str] = []
        for n, raw in enumerate((tree / name).read_text().splitlines(), 1):
            code, _, comment = raw.partition(";")
            if not code.strip():
                continue
            m = GUARD.match(raw)
            if m:
                if address is None:
                    address = int(m.group(1), 16)
                continue
            m = LABEL.match(raw)
            if m:
                pending.append(m.group(1))
                continue
            if address is None:
                raise ValueError(f"{name}:{n}: statement before the start guard")
            text = code.strip()
            if text.startswith("#"):
                macro, _, rest = text[1:].partition(" ")
                if macro not in MACRO_SIZE:
                    raise ValueError(f"{name}:{n}: unknown macro {macro}")
                args = split_args(rest)
                size = MACRO_SIZE[macro]
            elif text.startswith(".word "):
                macro, args = ".word", split_args(text[6:])
                size = 2 * len(args)
            else:
                raise ValueError(f"{name}:{n}: not a structured statement: {text}")
            out.append(Statement(name, n, address, macro, args, size, pending, comment.strip()))
            pending = []
            address += size
    return out


RECORD_OPS = ("patch", "lfo", "noise")
TARGET_LABEL = re.compile(r"_(t|sub)\d+$")


def named_by(sts: list[Statement] | None = None) -> dict[str, list[str]]:
    """Per patch record label, the streams whose patch, lfo or noise ops name it, sorted by
    name; a statement belongs to the last stream label at or before it (a
    `_tK` or `_subK` target label belongs to its stream). Records no op names map to []."""
    sts = statements() if sts is None else sts
    out: dict[str, list[str]] = {
        lab: [] for st in sts if st.name in PATCH_MACROS for lab in st.labels
    }
    owner: str | None = None
    for st in sts:
        if st.name in PATCH_MACROS:
            continue
        for lab in st.labels:
            if not TARGET_LABEL.search(lab):
                owner = lab
        if st.name in RECORD_OPS:
            if owner is None or st.args[0] not in out:
                raise ValueError(f"{st.file}:{st.line}: {st.name} before a stream or of no record")
            if owner not in out[st.args[0]]:
                out[st.args[0]].append(owner)
    return {lab: sorted(names) for lab, names in out.items()}


@dataclass
class Item:
    address: int
    kind: str  # note, op, table, stop
    length: int
    op: int | None = None
    targets: list[int] = field(default_factory=list)
    pointers: list[int] = field(default_factory=list)  # offsets of the address words in the image
    record: int | None = None  # a patch record named by patch, lfo or noise


def word(img: bytes, a: int) -> int:
    return img[a] | img[a + 1] << 8


def walk(img: bytes, roots: list[int], table_len: dict[int, int]) -> dict[int, Item]:
    """Every statement the interpreter can read from the roots: notes (2 bytes; length 0 ends
    the path, a return), ops by OPS (a call goes on after the call, a jump does not, a branch
    goes both ways), the stop bytes BB-FF. table_len gives the entries of each jump table (the
    list's length is not in the data; the source's .word line says it)."""
    items: dict[int, Item] = {}
    work = list(roots)
    while work:
        a = work.pop()
        while a not in items:
            b = img[a]
            if b < 0x80:
                items[a] = Item(a, "note", 2)
                if img[a + 1] == 0:
                    break
                a += 2
                continue
            if b >= 0xBB:
                items[a] = Item(a, "stop", 1, b)
                break
            op = OPS[b]
            if op.flow == "table":
                n = table_len[a]
                ptrs = [a + 1 + 2 * i for i in range(n)]
                targets = [word(img, p) for p in ptrs]
                items[a] = Item(a, "table", 1 + 2 * n, b, targets, ptrs)
                work.extend(targets)
                break
            item = Item(a, "op", op.length, b)
            items[a] = item
            if op.pointer:
                p = a + op.pointer
                item.pointers.append(p)
                if op.flow in ("call", "jump", "branch"):
                    item.targets.append(word(img, p))
                    work.append(word(img, p))
                else:
                    item.record = word(img, p)
            if op.flow in ("jump", "hang"):
                break
            a += op.length
    return items


# --- the summary of `make musictrace` -----------------------------------------------------------


def listing_labels(listing: str) -> dict[int, str]:
    """Label lines of the 64tass listing (".65e6\\t\\t\\t\\t\\tsnd_0F_0") in the data region."""
    out: dict[int, str] = {}
    for line in listing.splitlines():
        m = re.match(r"^\.([0-9a-f]{4})\t+([A-Za-z]\w*)\s*$", line)
        if m:
            a = int(m.group(1), 16)
            if DATA_LO <= a < DATA_HI:
                out.setdefault(a, m.group(2))
    return out


def listing_starts(listing: str) -> set[int]:
    """Addresses where a macro expansion line of the listing starts (">65e6\\t9d ..."). Every
    statement start is one, but a multi-line macro adds lines inside its statement (`patch`:
    the op byte, then its .word), so this set is wider than the statement starts: summarize
    checks the trace against statements() and uses this only to tie the listing to the tree."""
    out = set()
    for line in listing.splitlines():
        m = re.match(r"^>([0-9a-f]{4})\t", line)
        if m:
            out.add(int(m.group(1), 16))
    return out


def summarize(
    trace: str, listing: str, heads: set[int] | None = None
) -> tuple[dict[str, object], list[str]]:
    """The committed summary of a musictrace output and its problems: every statement the trace
    read must be a statement start of the source (heads: by default the addresses of
    statements(), the first byte of each macro or .word statement, never an operand byte inside
    one) and a line start of the listing."""
    if heads is None:
        heads = {s.address for s in statements()}
    header: dict[str, str] = {}
    windows, starts, ops, items, keyons, suppressed = [], {}, {}, {}, {}, {}
    for line in trace.splitlines():
        if line.startswith("# "):
            k, _, v = line[2:].partition(" ")
            header[k] = v
            continue
        f = line.split()
        if f[0] == "window":
            windows.append(
                {"command": f[1], "sound": f[2], "key_ons": int(f[3]), "frames": int(f[4])}
            )
        elif f[0] == "start":
            starts[f"{f[1]} {f[2]}"] = int(f[3])
        elif f[0] == "op":
            ops[f"{f[1]} {f[2]}"] = int(f[3])
        elif f[0] == "item":
            items[int(f[1], 16)] = int(f[2])
        elif f[0] == "keyon":
            keyons[f"{f[1]} {f[2]}"] = int(f[3])
        elif f[0] == "suppressed":
            suppressed[f[1]] = int(f[2])
    labels = listing_labels(listing)
    begins = listing_starts(listing)
    problems = [f"item {a:04X}: not a statement start of the source" for a in items
                if a not in heads]
    problems += [f"item {a:04X}: not a line start of the listing" for a in items
                 if a in heads and a not in begins]
    # the streams read: the label at or before each statement read, among the stream labels
    stream_labels = sorted((a, n) for a, n in labels.items() if not n.startswith("patch_"))
    read: dict[str, int] = {}
    for a, count in items.items():
        owner = None
        for la, n in stream_labels:
            if la > a:
                break
            if "_t" not in n and "_sub" not in n:
                owner = n
        if owner is None:
            problems.append(f"item {a:04X}: before every stream label")
            continue
        read[owner] = read.get(owner, 0) + count
    summary: dict[str, object] = {
        "source": "tools/mame/musictrace.lua (make musictrace), checked by tools/jsa_music.py",
        "frames": int(header.get("frames", "0")),
        "window_frames": int(header.get("window", "0")),
        "resets": int(header.get("resets", "0")),
        "windows_redone": int(header.get("redone", "0")),
        "windows": windows,
        "entries_started": dict(sorted(starts.items())),
        "ops_dispatched": dict(sorted(ops.items())),
        "streams_read": dict(sorted(read.items())),
        "statements_read": len(items),
        "key_ons": dict(sorted(keyons.items())),
        "suppressed_68010_commands": dict(sorted(suppressed.items())),
    }
    return summary, problems


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("summary")
    s.add_argument("--listing", required=True, type=Path)
    s.add_argument("--out", required=True, type=Path)
    s.add_argument("trace", type=Path)
    args = ap.parse_args(argv)
    text = args.trace.read_text()
    if "# frames" not in text:
        print(f"{args.trace}: not a musictrace output", file=sys.stderr)
        return 1
    summary, problems = summarize(text, args.listing.read_text())
    for p in problems:
        print(p, file=sys.stderr)
    if problems:
        return 1
    args.out.write_text(json.dumps(summary, indent=1) + "\n")
    windows = summary["windows"]
    assert isinstance(windows, list)
    print(
        f"musictrace: {len(windows)} windows, {summary['statements_read']} statements read, "
        f"{len(summary['ops_dispatched'])} op/handler pairs -> {args.out}"  # type: ignore[arg-type]
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
