"""The 6502 sound program as source (asm/jsa, docs/09-sound-program.md).

Runs in CI without the ROMs: asm/jsa/jsa.asm assembles with 64tass to 136070-2123.10c as MAME
lists it (size, CRC-32, SHA-1), a planted change in an operand changes the hash, the region
guards catch a moved region, the tree has no .binary, the IDA names are carried in, and the
committed trace summary agrees with the source. The trace tools (tools/sndtrace.py) are tested
on synthetic traces of a synthetic program; the MAME traces under build/mame/, when present, are
checked against the source too.
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
    """64tass as the Makefile runs it, from the tree's directory; writes out and out.lst."""
    return subprocess.run(
        [tass(), "-q", "-C", "-b", "-L", f"{out}.lst", "-o", str(out), "jsa.asm"],  # type: ignore[list-item]
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
    at = text.index("\n    ", text.index("cmdtype_00"))  # the first instruction of cmdtype_00
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


def equates(text: str) -> dict[str, int]:
    out = {}
    for line in text.splitlines():
        m = re.match(r"^([A-Za-z_]\w*)\s*=\s*\$([0-9A-Fa-f]+)\b", line)
        if m:
            out[m.group(1)] = int(m.group(2), 16)
    return out


@needs_tass
def test_ida_names_carried_in(tmp_path: Path) -> None:
    """Every name of the IDA snapshot is in the source at the same address: the I/O ports and
    their mirrors as equates in hardware.asm, the vectors and their targets as labels."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    listing = (tmp_path / "jsa.bin.lst").read_text()
    labels = {}
    for line in listing.splitlines():
        m = re.match(r"^\.([0-9a-f]{4})\t\t\t\t\t([A-Za-z]\w*)$", line)
        if m:
            labels[m.group(2)] = int(m.group(1), 16)
    io = equates((TREE / "hardware.asm").read_text())
    io.update({k + "_M": io[k] + 8 for k in ("OKI_READ", "CMD_FROM_68K", "RDIO", "IRQ_ACK")})
    snapshot = json.loads((REPO / "data/ida/stunrun-jsa.json").read_text())
    for entry in snapshot["names"]:
        ea, name = int(entry["ea"], 16), entry["name"]
        assert io.get(name, labels.get(name)) == ea, name


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
