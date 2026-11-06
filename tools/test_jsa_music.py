"""The sequencer's data as structured source (asm/jsa/data, docs/12-sound-music.md).

Runs in CI without the ROMs, on the image the committed source assembles to: the op macros
emit what the interpreter reads (their lengths against the op table and the handlers' calls of
next_operand), every byte of the data region 65E6-AB47 is one structured statement (a macro or
a .word of labels; no raw .byte), a walk of the streams from entry_stream and the unused stream
labels lands on statement starts with the right macro and its pointers on labels, every patch
record is the 42-byte record, and the tree assembled with one byte inserted at the start of the
data region differs from the original only by addresses that moved by one, every pointer of the
data among them. The committed musictrace summary is checked against the source.
"""

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

import jsa_music as jm
import pytest
from test_jsa import TREE, assemble, needs_tass, symbols

REPO = Path(__file__).resolve().parent.parent
SUMMARY = REPO / "artifacts/musictrace-summary.json"
ENTRIES = 125


def build(tree: Path, out: Path) -> tuple[bytes, dict[str, int]]:
    r = assemble(tree, out)
    assert r.returncode == 0, r.stdout + r.stderr
    return out.read_bytes(), symbols(Path(f"{out}.labels").read_text())


@pytest.fixture(scope="module")
def image(tmp_path_factory: pytest.TempPathFactory) -> tuple[bytes, dict[str, int]]:
    if jm_tass_missing():
        pytest.skip("64tass not available")
    return build(TREE, tmp_path_factory.mktemp("music") / "jsa.bin")


def jm_tass_missing() -> bool:
    from test_jsa import tass

    return tass() is None


# --- the op table against the macros and the handlers ----------------------------------------

DUMMY = {"target": "here", "record": "here", "table": "here"}


def macro_params(text: str) -> dict[str, list[str]]:
    out = {}
    for m in re.finditer(r"^(\w+) \.macro ?([^;\n]*)", text, re.M):
        out[m.group(1)] = [p.split("=")[0].strip() for p in m.group(2).split(",") if p.strip()]
    return out


@needs_tass
def test_macros_emit_the_op_table(tmp_path: Path) -> None:
    """Each op macro assembles to its op byte and the length the op table gives, and the note
    and patch macros to theirs."""
    params = macro_params((TREE / "data/macros.asm").read_text())
    lines = ['    .include "macros.asm"', "* = $1000", "here"]
    names: list[str] = []
    for name in sorted(jm.MACRO_SIZE):
        args = []
        for p in params[name]:
            op = "$FF" if name == "stop" else "$90"
            args.append(DUMMY.get(p, {"op": op, "pitch": "$01", "len": "$01"}.get(p, "$01")))
        lines += [f"m_{name}", f"    #{name} {', '.join(args)}"]
        names.append(name)
    lines.append("m_end")
    (tmp_path / "macros.asm").write_text((TREE / "data/macros.asm").read_text())
    (tmp_path / "jsa.asm").write_text("\n".join(lines) + "\n")
    data, syms = build(tmp_path, tmp_path / "t.bin")
    order = [*names, "end"]
    for name, nxt in zip(order, order[1:], strict=False):
        start, end = syms[f"m_{name}"], syms[f"m_{nxt}"]
        assert end - start == jm.MACRO_SIZE[name], name
        ops = [op for op, o in jm.OPS.items() if o.macro == name and name != "skip"]
        if ops:
            assert data[start - 0x1000] == ops[0], name


# op_patch reads its second operand byte on each of two exclusive paths: 554A (the track is
# releasing: the patch is not loaded, 0248 = FF) and 555A (the patch is loaded)
EXCLUSIVE_PATHS = {"op_patch": 2}


def handler_body(label: str) -> tuple[str, list[str]]:
    for path in sorted(TREE.glob("*.asm")):
        lines = path.read_text().splitlines()
        if label in lines:
            at = lines.index(label)
            body = []
            for line in lines[at + 1 :]:
                if re.match(r"^[A-Za-z]\w*\s*$", line):
                    break
                body.append(line.split(";", 1)[0])
            return path.name, body
    raise AssertionError(f"no handler {label}")


def test_op_lengths_are_the_handlers_reads() -> None:
    """The op table against the code: op_handlers lists each op's handler (entry op - 80), and a
    handler of a fixed-length op reads op length - 2 bytes through next_operand before it
    returns (run_op hands it the first operand byte in A). Branches read their target in
    branch_taken or skip it in branch_not_taken (two calls each)."""
    seq = (TREE / "sequencer.asm").read_text()
    table = re.findall(r"^    \.word (\w+)-1\s+; \$([0-9A-F]{2}) \w+$", seq, re.M)
    assert len(table) == 0x3B
    for handler, op_hex in table:
        op = jm.OPS[int(op_hex, 16)]
        assert op.handler == handler, op_hex
    for op_byte, op in jm.OPS.items():
        if op.flow == "table" or op.macro == "skip":
            continue
        _, body = handler_body(op.handler)
        calls = sum("jsr next_operand" in line for line in body)
        if op.flow == "branch":
            assert calls == 0, op.macro
            for shared in ("branch_taken", "branch_not_taken"):
                _, b = handler_body(shared)
                assert sum("jsr next_operand" in line for line in b) == 2
        else:
            paths = EXCLUSIVE_PATHS.get(op.handler, 1)
            assert calls == paths * (op.length - 2), f"{op_byte:02X} {op.macro}"


# --- every byte of the data region is a structured statement ---------------------------------


def test_data_region_is_statements() -> None:
    """The five data files are one statement after another from 65E6 to AB47, each file starting
    where the last ended; no raw .byte (a residue would need its own label and decision)."""
    sts = jm.statements()
    assert sts[0].address == jm.DATA_LO
    for a, b in zip(sts, sts[1:], strict=False):
        assert b.address == a.address + a.size, (b.file, b.line)
    assert sts[-1].address + sts[-1].size == jm.DATA_HI
    for s in sts:
        if s.name == ".word":
            assert all(re.fullmatch(r"[A-Za-z]\w*", a) for a in s.args), (s.file, s.line)


def test_statement_parser_refuses_raw_bytes(tmp_path: Path) -> None:
    (tmp_path / "data").mkdir()
    (tmp_path / "data/x.asm").write_text(
        '    .cerror * != $65E6, "x"\nsnd\n    #ret\n    .byte $00\n'
    )
    with pytest.raises(ValueError, match="not a structured statement"):
        jm.statements(tmp_path, ["data/x.asm"])


def test_patch_records_are_whole() -> None:
    """Every patch_NN label starts the 42-byte record: ym_voice, four ym_operator, four
    ym_scaling, ym_lfo, ym_noise; the records are all of patches_1.asm and patches_2.asm."""
    sts = jm.statements()
    shape = ["ym_voice", *["ym_operator"] * 4, *["ym_scaling"] * 4, "ym_lfo", "ym_noise"]
    for i, s in enumerate(sts):
        if any(label.startswith("patch_") for label in s.labels):
            assert [t.name for t in sts[i : i + len(shape)]] == shape, s.labels
            assert sum(t.size for t in sts[i : i + len(shape)]) == jm.PATCH_SIZE
        if s.file.startswith("data/patches_"):
            assert s.name in jm.PATCH_MACROS, (s.file, s.line)


def table_lengths(sts: list[jm.Statement]) -> dict[int, int]:
    out = {}
    for i, s in enumerate(sts):
        if s.name in ("jump_table", "jump_table_inc"):
            n, j = 0, i + 1
            while j < len(sts) and sts[j].name == ".word" and not sts[j].labels:
                n += len(sts[j].args)
                j += 1
            assert n, (s.file, s.line)
            out[s.address] = n
    return out


def note_macro(img: bytes, a: int) -> str:
    if img[a + 1] == 0:
        return "ret"
    return "rest" if img[a] == 0 else "note"


def walk_image(img: bytes, syms: dict[str, int]) -> tuple[dict[int, jm.Item], list[int]]:
    sts = jm.statements()
    base = syms["entry_stream"]
    streams = [jm.word(img, base + 2 * e) for e in range(ENTRIES)]
    unused = [v for k, v in syms.items() if k.startswith("unused_stream_")]
    return jm.walk(img, streams + unused, table_lengths(sts)), streams


def test_walk_lands_on_statements(image: tuple[bytes, dict[str, int]]) -> None:
    """The interpreter's view and the source's agree: every statement a walk of the streams
    reaches (from entry_stream and the unused_stream labels) starts a statement of the right
    macro, every pointer it follows or names is a label, the ops patch, lfo and noise name record
    starts, and the statements no walk reaches are patch fields or marked "not reached"."""
    img, syms = image
    sts = jm.statements()
    by_addr = {s.address: s for s in sts}
    labels = {v: k for k, v in syms.items() if jm.DATA_LO <= v < jm.DATA_HI}
    items, streams = walk_image(img, syms)
    assert len(set(streams)) == 119
    covered: set[int] = set()
    for a, item in items.items():
        s = by_addr.get(a)
        assert s is not None, f"{a:04X}: the walk reads mid-statement"
        if item.kind == "note":
            assert s.name == note_macro(img, a), (s.file, s.line)
        elif item.kind == "stop":
            assert s.name == "stop", (s.file, s.line)
        else:
            assert item.op is not None
            assert s.name == jm.OPS[item.op].macro, (s.file, s.line)
        for t in item.targets:
            assert t in labels, f"{a:04X}: target {t:04X} has no label"
        if item.record is not None:
            assert labels.get(item.record, "").startswith("patch_"), f"{a:04X}"
        covered.update(range(a, a + item.length))
    for s in sts:
        if s.address in covered or s.name in jm.PATCH_MACROS:
            continue
        assert "not reached" in s.comment, f"{s.file}:{s.line} neither reached nor marked"
    # a labelled statement is a stream start, a target or a record
    targets = {t for i in items.values() for t in i.targets} | set(streams)
    for s in sts:
        for label in s.labels:
            assert label.startswith("patch_") or s.address in targets or label.startswith(
                "unused_stream_"
            ), label


@needs_tass
def test_relocation(tmp_path: Path, image: tuple[bytes, dict[str, int]]) -> None:
    """One byte inserted at the start of the data region (a temporary copy, the region guards
    removed and the fill after the data shortened): the image differs from the original only by
    words that grew by one, each an address into the moved range, and every pointer of the data
    (the walk's) and every entry_stream word is among them."""
    old, syms = image
    tree = tmp_path / "jsa"
    shutil.copytree(TREE, tree)
    for path in tree.rglob("*.asm"):
        text = path.read_text()
        text = re.sub(r"^\s+\.cerror \* != .*$", "", text, flags=re.M)
        path.write_text(text)
    jsa = tree / "jsa.asm"
    jsa.write_text(jsa.read_text().replace(".fill $FFFA - $AC49, 0", ".fill $FFFA - *, 0"))
    s1 = tree / "data/streams_1.asm"
    text = s1.read_text()
    at = text.index("\nsnd_0F_0\n")
    s1.write_text(text[:at] + "\n    .byte $EA                           ; moved" + text[at:])
    new, _ = build(tree, tmp_path / "moved.bin")
    lo, hi = jm.DATA_LO, syms["checksum_adjust"] + 1

    def moved(a: int) -> int:  # the new address of the old byte a
        return a + 1 if lo <= a < hi else a

    assert new[lo] == 0xEA and len(new) == len(old) == 0x10000
    diffs = [a for a in range(0x10000) if a not in (lo - 1, hi) and moved(a) < 0x10000
             and old[a] != new[moved(a)]]
    grown: set[int] = set()
    for a in diffs:
        for w in (a, a - 1):  # the low or the high byte of a word
            ow = old[w] | old[w + 1] << 8
            nw = new[moved(w)] | new[moved(w) + 1] << 8
            if nw == ow + 1 and lo <= ow < hi and moved(w + 1) == moved(w) + 1:
                grown.add(w)
                break
        else:
            raise AssertionError(f"{a:04X}: changed, not an address that moved")
    items, _ = walk_image(old, syms)
    pointers = {p for i in items.values() for p in i.pointers}
    base = syms["entry_stream"]
    pointers |= {base + 2 * e for e in range(ENTRIES)}
    # a pointer whose low byte did not carry changes only its low byte: still in grown
    assert pointers <= grown, sorted(f"{p:04X}" for p in pointers - grown)[:5]


# --- the MAME evidence --------------------------------------------------------------------


def test_committed_summary_agrees_with_source() -> None:
    """artifacts/musictrace-summary.json: one window per command of type 08, every sound 00-1F
    keyed the YM2151 on, and every stream it lists as read is a stream label of the source."""
    summary = json.loads(SUMMARY.read_text())
    windows = summary["windows"]
    assert sorted(int(w["sound"], 16) for w in windows) == list(range(0x20))
    assert all(w["key_ons"] > 0 for w in windows)
    labels = {lab for s in jm.statements() for lab in s.labels}
    assert set(summary["streams_read"]) <= labels
    for key in summary["ops_dispatched"]:
        op, pc = key.split()
        assert int(op, 16) in jm.OPS and pc in ("506D", "50A3")


def test_mame_trace_agrees_with_source(tmp_path: Path) -> None:
    """When `make musictrace` has run here: the trace's statements are statement starts of the
    listing the tree assembles to (no ROMs in CI: skipped)."""
    trace = REPO / "build/mame/musictrace.txt"
    if not trace.exists() or jm_tass_missing():
        pytest.skip("no musictrace run here")
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0
    _, problems = jm.summarize(trace.read_text(), (tmp_path / "jsa.bin.lst").read_text())
    assert problems == []
