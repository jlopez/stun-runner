"""The 6502 sound program as source (asm/jsa, docs/09-sound-program.md).

Runs in CI without the ROMs: asm/jsa/jsa.asm assembles with 64tass to 136070-2123.10c as MAME
lists it (size, CRC-32, SHA-1), a planted change in an operand changes the hash, the region
guards catch a moved region, the tree has no .binary, the IDA names are carried in, the system
files carry no address-style label, and the committed trace summary agrees with the source. The
trace tools (tools/sndtrace.py) are tested on synthetic traces of a synthetic program; the MAME
traces under build/mame/, when present, are checked against the source too.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
from pathlib import Path

import pytest
import sndtrace
from romset import hashes, load_snapshot

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
TREE = REPO / "asm/jsa"
SUMMARY = REPO / "artifacts/sndtrace-summary.json"
CHIP = "136070-2123.10c"
TRACES = [REPO / f"build/mame/sndtrace-{run}.txt" for run in ("attract", "sound", "play")]


def tass() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("TASS", "64tass")))


needs_tass = pytest.mark.skipif(tass() is None, reason="64tass not available")


def assemble(tree: Path, out: Path) -> subprocess.CompletedProcess[str]:
    """64tass as the Makefile runs it, from the tree's directory; writes out, out.lst (the listing)
    and out.labels (every global symbol and its value, as 64tass resolved it)."""
    args = ["-q", "-C", "-b", "-L", f"{out}.lst", "-l", f"{out}.labels", "-o", str(out), "jsa.asm"]
    return subprocess.run(
        [tass(), *args],  # type: ignore[list-item]
        cwd=tree,
        capture_output=True,
        text=True,
        check=False,
    )


def reference() -> dict[str, object]:
    return next(r for r in load_snapshot("stunrun")["roms"] if r["name"] == CHIP)


@needs_tass
def test_source_assembles_to_10c(tmp_path: Path) -> None:
    """CI: the committed source is the chip, byte for byte, with no ROM file read."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    data = (tmp_path / "jsa.bin").read_bytes()
    ref = reference()
    assert len(data) == ref["size"] == 0x10000
    assert hashes(data) == (ref["crc"], ref["sha1"])


def copy_tree(tmp_path: Path) -> Path:
    tree = tmp_path / "jsa"
    shutil.copytree(TREE, tree)
    return tree


@needs_tass
def test_planted_operand_change_fails(tmp_path: Path) -> None:
    """One operand changed in the source: one byte of the image changes and the hash with it."""
    good = tmp_path / "good.bin"
    assert assemble(TREE, good).returncode == 0
    tree = copy_tree(tmp_path)
    system = tree / "system.asm"
    text = system.read_text()
    first = text.index("    ldx #$FF")  # reset, 4002: ldx #$FF before txs
    system.write_text(text[:first] + "    ldx #$FE" + text[first + len("    ldx #$FF") :])
    bad = tmp_path / "bad.bin"
    r = assemble(tree, bad)
    assert r.returncode == 0, r.stdout + r.stderr
    a, b = good.read_bytes(), bad.read_bytes()
    assert [i for i in range(len(a)) if a[i] != b[i]] == [0x4003]
    ref = reference()
    assert hashes(b) != (ref["crc"], ref["sha1"])


@needs_tass
def test_guards_catch_a_moved_region(tmp_path: Path) -> None:
    """A byte added inside a region moves everything after it: the next guard fails."""
    tree = copy_tree(tmp_path)
    commands = tree / "commands.asm"
    text = commands.read_text()
    label = text.index("\ncmdtype_00_min_priority\n")
    at = text.index("\n    ", label + 1)  # the first instruction of cmdtype_00_min_priority
    commands.write_text(text[:at] + "\n    nop" + text[at:])
    r = assemble(tree, tmp_path / "moved.bin")
    assert r.returncode != 0
    assert "commands.asm must end at $4758" in r.stdout + r.stderr


def tree_sources() -> list[Path]:
    return sorted(TREE.rglob("*.asm"))


def test_tree_is_all_source() -> None:
    """No .binary and nothing from build/ (or the archive) in the 6502 tree."""
    for path in tree_sources():
        code = "\n".join(line.split(";", 1)[0] for line in path.read_text().splitlines())
        assert ".binary" not in code, path
        assert "build/" not in code and "archive" not in code, path


def symbols(text: str) -> dict[str, int]:
    """64tass's -l output: `name = value`, the value in $hex or decimal."""
    out = {}
    for line in text.splitlines():
        m = re.match(r"^([A-Za-z_]\w*)\s*=\s*(\$[0-9A-Fa-f]+|\d+)\s*$", line)
        if m:
            v = m.group(2)
            out[m.group(1)] = int(v[1:], 16) if v.startswith("$") else int(v)
    return out


MIRRORS = ("OKI_READ", "CMD_FROM_68K", "RDIO", "IRQ_ACK")


@needs_tass
def test_ida_names_carried_in(tmp_path: Path) -> None:
    """Every name of the IDA snapshot is in the source at the same address: the I/O ports and
    their _M mirrors as equates in hardware.asm, the vectors and their targets as labels. The
    values are the ones the assembler resolved (its -l output), so an _M equate missing or wrong
    in hardware.asm fails here, whether or not the code still uses it."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    syms = symbols((tmp_path / "jsa.bin.labels").read_text())
    for base in MIRRORS:
        assert syms.get(base + "_M") == syms[base] + 8, base + "_M"
    snapshot = json.loads((REPO / "data/ida/stunrun-jsa.json").read_text())
    names = {entry["name"] for entry in snapshot["names"]}
    assert {m + "_M" for m in MIRRORS} <= names
    for entry in snapshot["names"]:
        ea, name = int(entry["ea"], 16), entry["name"]
        assert syms.get(name) == ea, name


GLOBAL_LABEL = re.compile(r"^([A-Za-z]\w*)\s*$")


def test_loc_labels_follow_the_rule() -> None:
    """docs/09 section 4: a loc_XXXX target is reached from another file, from a dispatch table
    (.word) or across another global label of its file (a 64tass local is visible only between
    two global labels); every other branch or jump target is an _lXXXX local."""
    files = {p: p.read_text().splitlines() for p in tree_sources()}
    for path, lines in files.items():
        globals_at = [i for i, t in enumerate(lines) if GLOBAL_LABEL.match(t)]
        for at, line in enumerate(lines):
            m = GLOBAL_LABEL.match(line)
            if not m or not m.group(1).startswith("loc_"):
                continue
            name = m.group(1)
            reasons = []
            for other, olines in files.items():
                for j, t in enumerate(olines):
                    code = t.split(";", 1)[0]
                    if GLOBAL_LABEL.match(t) or not re.search(rf"\b{name}\b", code):
                        continue
                    lo, hi = sorted((at, j))
                    reasons.append(
                        other != path
                        or ".word" in code
                        or any(lo < g < hi for g in globals_at if g != at)
                    )
            assert any(reasons), f"{path.name}: {name} could be an _l local"


# The files leg M4c named (docs/09 section 10); sequencer.asm, data/** and lookup.asm are M4d's.
SYSTEM_FILES = (
    "jsa.asm",
    "hardware.asm",
    "ram.asm",
    "system.asm",
    "commands.asm",
    "nmi.asm",
    "ymtimer.asm",
    "oki.asm",
    "io.asm",
    "tables.asm",
)
# The hex digits in either case: the build is case sensitive (-C), so loc_5d3a is its own symbol.
ADDRESS_LABEL = re.compile(r"^(?:(?:sub|loc|tbl|dat)_[0-9A-Fa-f]{4}|_l[0-9A-Fa-f]{4})$")
EQUATE = re.compile(r"^([A-Za-z_]\w*)\s*=")
# The symbol a line defines: its first token, whatever follows it (a colon, an instruction, a data
# statement, an equate's "=", a comment) and however far it is indented. A mnemonic or a directive
# never has an address label's shape, so only definitions can match ADDRESS_LABEL.
DEFINED = re.compile(r"^\s*(_?[A-Za-z]\w*)")
NEUTRAL_EQUATE = re.compile(r"^(?:zp_[0-9A-Fa-f]{2}|ram_[0-9A-Fa-f]{4})$")
# The sequencer's files (M4d's): the only users a neutral equate may have.
SEQUENCER_FILES = ("sequencer.asm", "lookup.asm", "data")


def address_labels(lines: list[str]) -> list[str]:
    """The lines that define a symbol with an address label's shape."""
    out = []
    for t in lines:
        m = DEFINED.match(t)
        if m and ADDRESS_LABEL.match(m.group(1)):
            out.append(t)
    return out


def test_address_label_guard_sees_every_form() -> None:
    """The forms 64tass accepts for a label definition, each caught; references are not."""
    planted = [
        "loc_4400",
        "loc_4400 ; x",
        "loc_4400:",
        "_l4400 ; x",
        "tbl_5DB5 .byte $00, $01",
        "_l5CE0 lda #0",
        "    sub_4100 rts",
        "dat_6000 = $6000",
        "loc_5d3a",
        "_l5cE0 ; x",
    ]
    assert address_labels(planted) == planted
    assert not address_labels(["    jsr sub_4100", "    .word tbl_5DB5", "; loc_4400", "lda_ok"])


def code_refers(lines: list[str], name: str) -> bool:
    return any(re.search(rf"\b{name}\b", t.split(";", 1)[0]) for t in lines)


def test_system_files_are_named() -> None:
    """docs/09 section 10: no address-style label (sub_, loc_, tbl_, dat_ + address, or an _lXXXX
    local) is left in the system files, and every RAM equate still called zp_XX or ram_XXXX is one
    that the sequencer's files use and no system file does (the M4c/M4d split of ram.asm). When
    M4d has named them all, none is left and the test still passes."""
    for name in SYSTEM_FILES:
        left = address_labels((TREE / name).read_text().splitlines())
        assert not left, f"{name}: {left}"
    system = {n: (TREE / n).read_text().splitlines() for n in SYSTEM_FILES if n != "ram.asm"}
    paths = [
        p
        for n in SEQUENCER_FILES
        for p in ((TREE / n).rglob("*.asm") if (TREE / n).is_dir() else [TREE / n])
    ]
    assert len(paths) > 2, paths
    sequencer = {str(p.relative_to(TREE)): p.read_text().splitlines() for p in paths}
    for t in (TREE / "ram.asm").read_text().splitlines():
        m = EQUATE.match(t)
        if m and NEUTRAL_EQUATE.match(m.group(1)):
            users = [n for n, lines in system.items() if code_refers(lines, m.group(1))]
            assert not users, f"{m.group(1)} is used by {users}: M4c names it"
            seq = [n for n, lines in sequencer.items() if code_refers(lines, m.group(1))]
            assert seq, f"{m.group(1)} is used by no sequencer file: it is not M4d's"


# A mask an AND or ORA applies to a value that A then carries to a store to a WRIO or MIX register
# (or its shadow) is made of the hardware equates (hardware.asm), not a raw number in any base
# (the M4c decision, CLAUDE.md).
RAW_MASK = re.compile(r"^(?:and|ora)\s+#(?:\$[0-9A-Fa-f]+|%[01]+|[0-9]+)$")
HW_STORE = re.compile(r"^sta\s+(?:WRIO|MIX|wrio_shadow|mix_shadow)\b")
# What may come between the mask and the store with A still derived from the mask: the other
# logic operations and the shifts on A, stores, compares, flag and index instructions. Anything
# else (a load or transfer into A, arithmetic, a call, a jump, a return, a branch, a directive)
# ends the search.
A_CARRIES = re.compile(
    r"^(?:(?:and|ora|eor|sta|stx|sty|ldx|ldy|cmp|cpx|cpy|bit)\s|(?:asl|lsr|rol|ror)\s+a$"
    r"|(?:clc|sec|cli|sei|cld|sed|clv|nop|inx|iny|dex|dey|tax|tay|pha|php)$)"
)
CODE_LABEL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*\s*(?:;|$)")


def raw_hardware_masks(lines: list[str]) -> list[str]:
    """The raw immediate AND/ORA masks whose value A carries, through what A_CARRIES allows, to a
    store to WRIO, MIX or their shadows. A label in between does not stop the search: the masked
    value still falls through it to the store."""
    found = []
    for i, line in enumerate(lines):
        if not RAW_MASK.match(line.split(";", 1)[0].strip()):
            continue
        for later in lines[i + 1 :]:
            text = later.split(";", 1)[0].strip()
            if not text or CODE_LABEL.match(later):
                continue
            if HW_STORE.match(text):
                found.append(line)
                break
            if not A_CARRIES.match(text):
                break
    return found


def test_hardware_masks_are_equates() -> None:
    """System files: no raw AND/ORA mask feeds a WRIO or MIX store, and no line is over 100
    columns (the repository's convention)."""
    assert raw_hardware_masks(["    and #$FB", "    sta WRIO ; x"]) == ["    and #$FB"]
    planted = [
        # ymtimer.asm's form (5903): another ORA, then the shadow, then WRIO
        ["    lda wrio_shadow", "    and #$3F", "    ora tbl_65DD+4,x", "    sta wrio_shadow"],
        ["    and #%00111111", "    sta wrio_shadow"],
        ["    and #63", "    sta WRIO"],
        ["    ora #$08 ; x", "_join", "    sta temp", "    sta MIX"],
    ]
    for case in planted:
        assert len(raw_hardware_masks(case)) == 1, case
    assert not raw_hardware_masks(["    and #$FF ^ WRIO_OKI_RUN", "    sta WRIO"])
    assert not raw_hardware_masks(
        ["    and #WRIO_BANK", "    ora #WRIO_BANK_PAGE1", "    sta WRIO"]
    )
    assert not raw_hardware_masks(["    and #$3F", "    lda wrio_shadow", "    sta WRIO"])
    assert not raw_hardware_masks(["    and #$3F", "    jsr random", "    sta WRIO"])
    assert not raw_hardware_masks(["    and #$3F", "    sta YM2151_DATA"])
    for name in SYSTEM_FILES:
        lines = (TREE / name).read_text().splitlines()
        assert not raw_hardware_masks(lines), f"{name}: {raw_hardware_masks(lines)}"
        long = [i + 1 for i, t in enumerate(lines) if len(t) > 100]
        assert not long, f"{name}: lines over 100 columns: {long}"
    # This file too: make lint does not run the formatter and ruff ignores E501.
    long = [i + 1 for i, t in enumerate(Path(__file__).read_text().splitlines()) if len(t) > 100]
    assert not long, f"{Path(__file__).name}: lines over 100 columns: {long}"


@needs_tass
def test_committed_summary_agrees_with_source(tmp_path: Path) -> None:
    """CI: the executed ranges of artifacts/sndtrace-summary.json are whole instructions of the
    source and its data reads lie in data statements, so the trace evidence still describes the
    tree."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    src = sndtrace.source((tmp_path / "jsa.bin.lst").read_text())
    summary = json.loads(SUMMARY.read_text())
    assert summary["instructions_in_source"] == len(src.instr)
    code = {a + k for a, n in src.instr.items() for k in range(n)}

    def expand(text: str) -> set[int]:
        a, _, b = text.partition("-")
        return set(range(int(a, 16), int(b or a, 16) + 1))

    executed: set[int] = set()
    for run in summary["runs"].values():
        for text in run["executed"]:
            span = expand(text)
            assert span <= code, text
            assert min(span) in src.instr, text
            executed |= span
        for entry in run["data_read"]:
            assert expand(entry["range"]) <= src.data, entry
    never: set[int] = set()
    for text in summary["never_executed"]:
        never |= expand(text)
    assert never | executed == code and not never & executed


# --- tools/sndtrace.py on a synthetic program and synthetic traces --------------------------

PROGRAM = """
* = $0000
    .fill $4000, 0
start
    lda table,x
    sta $2000
    jmp start
table
    .byte 1, 2, 3
    .fill $FFFA - *, 0
    .word start, start, start
"""


@pytest.fixture
def program(tmp_path: Path) -> sndtrace.Source:
    if tass() is None:
        pytest.skip("64tass not available")
    (tmp_path / "jsa.asm").write_text(PROGRAM)
    r = assemble(tmp_path, tmp_path / "p.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    return sndtrace.source((tmp_path / "p.bin.lst").read_text())


HEADER = "# frames 100\n# play no\n# attract_sound yes\n# data 3\n# fetches 30\n# mix 0\n# wrio 1\n"


def trace_text(body: str, done: bool = True) -> str:
    return HEADER + body + ("# done\n" if done else "")


def test_source_classifies_the_listing(program: sndtrace.Source) -> None:
    assert program.instr == {0x4000: 3, 0x4003: 3, 0x4006: 3}
    assert {0x4009, 0x400A, 0x400B, 0xFFFA, 0xFFFF} <= program.data
    assert 0x4000 not in program.data and 0x5000 in program.fill and 0x5000 not in program.data


def test_summary_of_a_trace(program: sndtrace.Source) -> None:
    text = trace_text(
        "F 4000 10\nF 4003 10\nD 4009 4000 2\nD 400A 4000 1\nD FFFC 0000 1\n"
        "C 5 023EF6 0A\nC 9 023EF6 0A\nC 9 023EF6 1E\nR 0 FF\nS 0\n"
        "Y 10 08 78\nY 11 08 00\nY 12 20 C7\nO 20 80\n"
    )
    t = sndtrace.parse(text)
    assert t.done and sndtrace.check(t, program, "t") == []
    s = sndtrace.run_summary(t, program)
    assert s["executed"] == ["4000-4005"]
    assert s["data_read"] == [
        {"range": "4009-400A", "by": ["4000"]},
        {"range": "FFFC", "by": ["0000"]},
    ]
    assert s["commands"] == {
        "0A": {"count": 2, "first_frame": 5, "68k_pc": ["023EF6"]},
        "1E": {"count": 1, "first_frame": 9, "68k_pc": ["023EF6"]},
    }
    assert s["responses"] == {"FF": 1}
    assert s["ym2151_key_ons"] == 1 and s["ym2151_writes"] == 3 and s["oki_commands"] == 1
    assert s["sound_resets_at_frame"] == [0]


@needs_tass
def test_summary_orders_runs_by_name(tmp_path: Path) -> None:
    """The committed summary does not depend on the order make passes the traces in."""
    (tmp_path / "jsa.asm").write_text(PROGRAM)
    assert assemble(tmp_path, tmp_path / "p.bin").returncode == 0
    listing = (tmp_path / "p.bin.lst").read_text()
    t = sndtrace.parse(trace_text("F 4000 1\n"))
    a = sndtrace.summary({"run-b": t, "run-a": t}, listing)
    b = sndtrace.summary({"run-a": t, "run-b": t}, listing)
    assert list(a["runs"]) == ["run-a", "run-b"]  # type: ignore[call-overload]
    assert sndtrace.dumps(a) == sndtrace.dumps(b)


def test_check_rejects_traces_the_source_contradicts(program: sndtrace.Source) -> None:
    t = sndtrace.parse(trace_text("F 4001 1\nD 4004 4003 1\nD 5000 4000 1\nF B1:3000 1\n"))
    problems = sndtrace.check(t, program, "t")
    assert any("opcode fetch at 4001" in p for p in problems)
    assert any("data read at 4004 (by 4003) inside an instruction" in p for p in problems)
    assert any("data read at 5000 (by 4000) not in a data statement" in p for p in problems)
    assert any("bank window" in p for p in problems)


def test_unfinished_trace_is_refused(tmp_path: Path) -> None:
    path = tmp_path / "t.txt"
    path.write_text(trace_text("F 4000 1\n", done=False))
    with pytest.raises(SystemExit):
        sndtrace.read(path)


def test_soundcheck() -> None:
    a = sndtrace.parse(trace_text("Y 10 08 78\nO 20 80\nC 5 023EF6 0A\nR 0 FF\n"))
    assert sndtrace.soundcheck(a, a, 100) == []
    b = sndtrace.parse(trace_text("Y 10 08 70\nO 20 80\nC 5 023EF6 0A\nR 0 FF\n"))
    assert any("YM2151 writes differ" in p for p in sndtrace.soundcheck(a, b, 100))
    # differences after the compared frames do not count
    c = sndtrace.parse(trace_text("Y 10 08 78\nO 20 80\nC 5 023EF6 0A\nR 0 FF\nO 200 81\n"))
    assert sndtrace.soundcheck(a, c, 100) == []
    silent = sndtrace.parse(trace_text("Y 10 08 00\n"))
    assert any("no YM2151 key-on" in p for p in sndtrace.soundcheck(silent, silent, 100))


def test_ranges() -> None:
    assert sndtrace.ranges({1, 2, 3, 7, 9, 10}) == ["0001-0003", "0007", "0009-000A"]


@needs_tass
@pytest.mark.skipif(not all(p.exists() for p in TRACES), reason="no make sndtrace traces")
def test_mame_traces_agree_with_source(tmp_path: Path) -> None:
    """The traces of `make sndtrace`, when present, against the current source."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    src = sndtrace.source((tmp_path / "jsa.bin.lst").read_text())
    for path in TRACES:
        assert sndtrace.check(sndtrace.read(path), src, path.stem) == []
