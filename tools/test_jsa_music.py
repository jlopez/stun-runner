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
        ops = [op for op, o in jm.OPS.items() if o.macro == name and name != "hang_op"]
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


def test_hang_ops_redispatch_themselves() -> None:
    """The hang_op ops' handler is read_item, which reaches `jsr run_op` without writing
    stream_ptr (only trk_ptr_lo/trk_ptr_hi move): it reads the same op byte and dispatches it again,
    so the walk must end a path there (flow hang), never read on as if two bytes were skipped."""
    hang = [o for o in jm.OPS.values() if o.macro == "hang_op"]
    assert len(hang) == 8 and all(o.handler == "read_item" and o.flow == "hang" for o in hang)
    _, body = handler_body("read_item")
    head = body[: next(i for i, line in enumerate(body) if "jsr run_op" in line)]
    assert any("lda (stream_ptr),y" in line for line in head)
    assert not any(re.search(r"\bst[axy] stream_ptr", line) for line in head)


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
        if op.flow == "table" or op.macro == "hang_op":
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
    keyed the YM2151 on, the key-on table adds up to the windows' counts, and every stream it
    lists as read is a stream label of the source."""
    summary = json.loads(SUMMARY.read_text())
    windows = summary["windows"]
    assert sorted(int(w["sound"], 16) for w in windows) == list(range(0x20))
    assert all(w["key_ons"] > 0 for w in windows)
    # the key-on table counts inside the windows only: its total is the windows' total
    assert sum(summary["key_ons"].values()) == sum(w["key_ons"] for w in windows)
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


def test_summary_refuses_operand_addresses() -> None:
    """An item recorded at an operand byte inside a statement is a problem, even where the
    listing has a line (`patch` lists its .word on a line of its own): the check uses the
    statement starts of the source, not every listing line."""
    sts = jm.statements()
    st = next(s for s in sts if s.name == "patch")
    inside = st.address + 1
    listing = f".{jm.DATA_LO:04x}\t\t\t\t\t{sts[0].labels[0]}\n"
    listing += "".join(f">{a:04x}\t00\n" for a in (st.address, inside))
    trace = f"# frames 1\nitem {st.address:04X} 1\n"
    _, problems = jm.summarize(trace, listing)
    assert problems == []
    _, problems = jm.summarize(trace + f"item {inside:04X} 1\n", listing)
    assert problems == [f"item {inside:04X}: not a statement start of the source"]


def test_named_by_lists_are_whole() -> None:
    """Each record's comment (the comment lines just above its label) and docs/12 section 5's
    "Named by" column list every stream whose patch, lfo or noise ops name the record, in full:
    the lists of the streams, not a cut-off copy."""
    nb = jm.named_by()
    assert len(nb) == 101 and sum(not v for v in nb.values()) == 22
    assert len(nb["patch_10"]) == 8 and len(nb["patch_23"]) == 14
    for name in ("patches_1.asm", "patches_2.asm"):
        lines = (TREE / "data" / name).read_text().splitlines()
        for i, line in enumerate(lines):
            if not re.fullmatch(r"patch_[0-9A-F]{2}", line):
                continue
            assert not lines[i + 1].startswith(";"), (name, line)
            k = i
            while lines[k - 1].startswith(";"):
                k -= 1
            text = " ".join(c[1:].strip() for c in lines[k:i])
            if nb[line]:
                assert text == "named by the patch, lfo or noise ops of " + ", ".join(nb[line])
            else:
                assert text == "no patch, lfo or noise op names this record", line
    doc = (REPO / "docs/12-sound-music.md").read_text()
    rows = dict(re.findall(r"^\| `(patch_[0-9A-F]{2})` \|[^\n]*\| ([^|\n]*) \|$", doc, re.M))
    assert rows == {k: ", ".join(v) if v else "-" for k, v in nb.items()}


def test_data_files_follow_jsa_asm(tmp_path: Path) -> None:
    """The region's files are jsa.asm's data/ includes after data/sounds.asm, and its bounds the
    first file's start guard and the last file's end guard: a split in jsa.asm needs no edit
    of the tool."""
    (tmp_path / "data").mkdir()
    (tmp_path / "jsa.asm").write_text(
        '    .include "data/macros.asm"\n    .include "data/sounds.asm"\n'
        '    .include "data/a.asm"\n    .include "data/b.asm"\n    .include "lookup.asm"\n'
    )
    (tmp_path / "data/a.asm").write_text(
        '    .cerror * != $65E6, "a"\nx\n    #ret\n    .cerror * != $65E8, "a"\n'
    )
    (tmp_path / "data/b.asm").write_text(
        '    .cerror * != $65E8, "b"\n    #ret\n    .cerror * != $65EA, "b"\n'
    )
    assert jm.data_files(tmp_path) == ["data/a.asm", "data/b.asm"]
    assert jm.data_bounds(tmp_path) == (0x65E6, 0x65EA)
    assert [s.address for s in jm.statements(tmp_path)] == [0x65E6, 0x65E8]
    assert jm.data_files() == jm.DATA_FILES and (jm.DATA_LO, jm.DATA_HI) == (0x65E6, 0xAB48)


SND_TRACES = [REPO / f"build/mame/sndtrace-{run}.txt" for run in ("attract", "sound", "play")]


def test_sndtrace_reads_lie_in_walked_statements(image: tuple[bytes, dict[str, int]]) -> None:
    """When `make sndtrace` has run here: every data read of 65E6-AB47 (the D lines) lies in a
    statement the walk of the streams reaches or in a patch record (no ROMs in CI: skipped)."""
    traces = [t for t in SND_TRACES if t.exists()]
    if not traces:
        pytest.skip("no sndtrace run here")
    img, syms = image
    items, _ = walk_image(img, syms)
    allowed: set[int] = set()
    for a, item in items.items():
        allowed.update(range(a, a + item.length))
    for s in jm.statements():
        if s.name in jm.PATCH_MACROS:
            allowed.update(range(s.address, s.address + s.size))
    reads = 0
    for trace in traces:
        for line in trace.read_text().splitlines():
            f = line.split()
            if f and f[0] == "D" and jm.DATA_LO <= int(f[1], 16) < jm.DATA_HI:
                reads += 1
                assert int(f[1], 16) in allowed, f"{trace.name}: read of {f[1]} by {f[2]}"
    assert reads


CITING = [
    REPO / "docs/12-sound-music.md",
    TREE / "sequencer.asm",
    *sorted((TREE / "data").glob("*.asm")),
]


@needs_tass
def test_code_citations_are_instruction_starts(tmp_path: Path) -> None:
    """A code address (4000-5DB4) cited in docs/12, sequencer.asm or the data files, alone or as
    the start of a range "a-b", is where an instruction or a label starts, never an operand byte;
    the end of a range is a byte and not checked (round-3 review: 4A84, 5062, 4EF0 and others
    were operand bytes; round 4: range starts such as 545A, 4F16, 4966)."""
    r = assemble(TREE, tmp_path / "jsa.bin")
    assert r.returncode == 0, r.stdout + r.stderr
    listing = (tmp_path / "jsa.bin.lst").read_text()
    starts = {int(a, 16) for a in re.findall(r"^\.([0-9a-f]{4})\t", listing, re.M)}
    bad = []
    for path in CITING:
        for n, line in enumerate(path.read_text().splitlines(), 1):
            cited = re.findall(r"(?<![\w$#+-])([45][0-9A-F]{3})-[0-9A-F]{2,4}\b", line)
            line = re.sub(r"\b[0-9A-F]{4}-[0-9A-F]{2,4}\b", "", line)
            cited += re.findall(r"(?<![\w$#+-])([45][0-9A-F]{3})(?![\w-])", line)
            for c in cited:
                a = int(c, 16)
                if 0x4000 <= a <= 0x5DB4 and a not in starts:
                    bad.append(f"{path.name}:{n} {c}")
    assert not bad, bad


def test_no_branch_on_register_00() -> None:
    """docs/12 section 3.7: on a YM2151 track a branch on register 00 decides on the saved Y, not
    on the 0 read_register returns (54CA), so no stream may branch on it without docs/12 and
    macros.asm saying what it does there."""
    regs = [s.args[0] for s in jm.statements() if s.name.startswith("branch_")]
    assert len(regs) == 21
    assert not [r for r in regs if r in ("R_VOLUME", "$00", "0")], regs


def test_unused_stream_openings() -> None:
    """docs/12 section 7: unused streams 03-07 open with tempo then patch, 09-12 with a patch,
    and 08 is the fragment note, rest, ret."""
    by_label: dict[str, list[str]] = {}
    current = None
    for s in jm.statements(files=["data/unused_streams.asm"]):
        for label in s.labels:
            if re.fullmatch(r"unused_stream_\d\d", label):
                current = label
                by_label[current] = []
        if current:
            by_label[current].append(s.name)
    assert sorted(by_label) == [f"unused_stream_{n:02}" for n in range(3, 13)]
    for n in range(3, 8):
        assert by_label[f"unused_stream_{n:02}"][:2] == ["tempo", "patch"], n
    for n in range(9, 13):
        assert by_label[f"unused_stream_{n:02}"][0] == "patch", n
    assert by_label["unused_stream_08"] == ["note", "rest", "ret"]


def test_sndtrace_column_claims_no_unused_op() -> None:
    """docs/12 section 4: an op no stream uses (0 / 0) was never dispatched, so a handler the
    sndtrace runs executed must be reached another way: its cell is not a bare "yes" (A1's
    handler is also entered from add_volume and volume_ym: "(shared)")."""
    doc = (REPO / "docs/12-sound-music.md").read_text()
    doc = doc[doc.index("| Op | Macro |") :]
    doc = doc[: doc.index("\n\n")]
    row = r"^\| ([0-9A-F-, ]+) \| `[^|]*\|[^|]*\|[^|]*\| ([^|]*) \| ([^|]*) \| ([^|]*) \|"
    rows = re.findall(row, doc, re.M)
    assert len(rows) == 53
    for op, _music, snd, streams in rows:
        if streams.strip() == "0 / 0":
            assert snd.strip() != "yes", op
    assert ("A1", "(shared)") in {(op, snd.strip()) for op, _m, snd, _s in rows}
