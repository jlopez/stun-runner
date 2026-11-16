"""The 68010 program of the 68k image (docs/14-68k-descent.md).

    tools/m68k classify [--image build/stunrun-68k.bin] [--out data/68k/classification.json]
                        [--operands data/68k/operands.json] [--seeds data/68k/seeds.json]
                        (PCCOV_RUN ... | --no-mame)
    tools/m68k stats    [--classification ...]
    tools/m68k gen START END --out FILE [--equates-out FILE] [--externals-out FILE]
                        [--equates asm/68k/hardware.asm] [--incbin PATH] [inputs as classify]
    tools/m68k check-region START END --work DIR [--equates FILE]
    tools/m68k check-listing --listing L --binary B [--origin N] [--classification ...]
                        [--operands ...] [--macros asm/68k/macros.asm] [--range START END]
    tools/m68k check-unidasm [--image ...] [--classification ...] [--unidasm unidasm]
    tools/m68k pccov-read FIFO OUT
    tools/m68k pccov [--image ...] [--classification ...] --summary FILE RUN ...

classify       runs the descent (with the MAME runs given as seeds) and rewrites the
               classification and the operand decisions (commit both when they change); without
               the runs of `make pccov` it refuses unless --no-mame says so (the committed file
               is classified with them: three entries have MAME as their only evidence)
stats          bytes per kind and region, the numbers of docs/14
gen            the one-shot generator (gen.py): vasm source for START-END
check-region   gen, then assemble the range alone in DIR with macros.asm, the equates and the
               externals, compare with the image (0 differences), run the listing descent
               check, the address lint and the shift test on it (needs the reference set)
check-listing  the descent check and the address lint on any vasm listing and its binary: fails
               on an error of either, and on an instruction statement nothing reaches unless the
               seeds file lists it under `unreached` with an argument
check-unidasm  every instruction boundary of the code ranges against unidasm's
pccov-read     drains a MAME trace pipe into the distinct PCs (make pccov)
pccov          fails unless every executed PC starts a code instruction; writes the summary
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections.abc import Callable
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from m68k import classify as cl  # noqa: E402
from m68k import gen as gn  # noqa: E402
from m68k import listing as ls  # noqa: E402
from m68k import operands as opd  # noqa: E402
from m68k import pccov as pc  # noqa: E402
from m68k.decode import decode  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent
IMAGE = REPO / "build/stunrun-68k.bin"
CLASSIFICATION = REPO / "data/68k/classification.json"
OPERANDS = REPO / "data/68k/operands.json"
SEEDS = REPO / "data/68k/seeds.json"
SNAPSHOT = REPO / "data/ida/stunrun-68k.json"
FUNCTIONS = REPO / "data/ida/stunrun-68k.functions.jsonl"
MACROS = REPO / "asm/68k/macros.asm"
REGIONS = [("boot vectors", 0x000000, 0x000212), ("boot code", 0x000212, 0x012F06),
           ("programs", 0x012F06, 0x020000), ("game vectors", 0x020000, 0x020430),
           ("game code", 0x020430, 0x04397E), ("game island", 0x04397E, 0x046AEE),
           ("game data", 0x046AEE, 0x05CF86)]
CODE_REGIONS = [(0x000212, 0x012F06), (0x020430, 0x04397E), (0x04397E, 0x046AEE)]


def hexarg(s: str) -> int:
    return int(s, 16)


def load_unreached(path: Path) -> dict[int, str]:
    """The instruction statements the descent check may leave unreached, each with its written
    argument (`unreached` of data/68k/seeds.json)."""
    if not path.exists():
        return {}
    j = json.loads(path.read_text())
    return {int(e["at"], 16): e["argument"] for e in j.get("unreached", [])}


def switch_ranges(c: cl.Classification) -> list[tuple[int, int]]:
    return [(s.start, s.end) for s in c.spans if s.kind == "switch"]


def load_seeds(path: Path) -> tuple[list[tuple[int, str]], dict[int, str]]:
    if not path.exists():
        return [], {}
    j = json.loads(path.read_text())
    if j.get("format") != "stunrun-68k-seeds 1":
        raise SystemExit(f"{path}: not stunrun-68k-seeds 1")
    seeds = [(int(e["at"], 16), e["argument"]) for e in j.get("seeds", [])]
    untaken = {int(e["at"], 16): e["argument"] for e in j.get("untaken", [])}
    return seeds, untaken


def ida_functions(path: Path) -> dict[int, str]:
    out = {}
    if path.exists():
        for line in path.read_text().splitlines():
            j = json.loads(line)
            out[int(j["start_ea"])] = j["name"]
    return out


def mame_pcs(paths: list[Path]) -> set[int]:
    out: set[int] = set()
    for p in paths:
        out |= pc.load_run(p)[1]
    return out


def cmd_classify(a: argparse.Namespace) -> int:
    if not a.runs and not a.no_mame:
        print("classify: no MAME run given: run `make pccov` first (the committed classification "
              "takes three entries from it), or pass --no-mame for a classification without them")
        return 1
    image = a.image.read_bytes()
    seeds, untaken = load_seeds(a.seeds)
    c = cl.classify(image, mame_pcs(a.runs), seeds, untaken, ida_functions(FUNCTIONS))
    errs = cl.validate(c)
    if errs:
        print("\n".join(errs))
        return 1
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(cl.dump(c))
    assert c.result is not None
    r = c.result
    starts = cl.routine_starts(r)
    addresses = set()
    for insn in r.insns.values():
        for o in insn.operands:
            if o.mode in ("absl", "pcdisp", "pcindex") or (o.mode == "absw" and
                                                           insn.mnemonic != "pea"):
                addresses.add(o.value)
    a.operands.write_text(opd.dump(opd.build(r.insns, starts, addresses)))
    st = cl.stats(c, REGIONS)
    code = sum(v["code"] for v in st.values())
    print(f"{a.out}: {len(c.spans)} ranges, {code} bytes of code, {len(c.entries)} entries with "
          f"evidence, {len(c.rejected)} seeds rejected; {a.operands}")
    for addr, why in sorted(c.rejected.items()):
        print(f"  rejected {addr:06X}: {why}")
    return 0


def cmd_stats(a: argparse.Namespace) -> int:
    c = cl.load(a.classification)
    st = cl.stats(c, REGIONS)
    print("region          " + " ".join(f"{k:>8}" for k in cl.KINDS))
    for name, row in st.items():
        print(f"{name:15} " + " ".join(f"{row[k]:8}" for k in cl.KINDS))
    tot = {k: sum(r[k] for r in st.values()) for k in cl.KINDS}
    print(f"{'total':15} " + " ".join(f"{tot[k]:8}" for k in cl.KINDS))
    ev: dict[str, int] = {}
    for e in c.entries.values():
        key = e.split(":")[0] if e.startswith(("reviewed", "computed", "address operand",
                                                "return address")) else " ".join(e.split()[:1])
        ev[key] = ev.get(key, 0) + 1
    print("entries by evidence:", ", ".join(f"{k} {v}" for k, v in sorted(ev.items())))
    return 0


def model(a: argparse.Namespace, forced: set[int]) -> gn.Model:
    image = a.image.read_bytes()
    c = cl.load(a.classification)
    names, functions, ram = gn.load_snapshot(a.snapshot)
    io = gn.load_equates(a.equates)
    m = gn.Model(image, c, names, functions, ram, io, gn.io_segments(), opd.load(a.operands))
    if a.equates is not None:
        m.equates_file = {n for _, n in io}
    m.build(forced)
    return m


def cmd_gen(a: argparse.Namespace) -> int:
    m = model(a, {a.start})
    out = gn.generate(m, a.start, a.end, a.incbin)
    a.out.write_text(out.source)
    if a.equates_out:
        a.equates_out.write_text(gn.equates_text(out.equates))
    if a.externals_out:
        a.externals_out.write_text(gn.externals_text(out.externals))
    print(f"{a.out}: {a.start:06X}-{a.end:06X}, " + ", ".join(
        f"{k} {v}" for k, v in out.stats.items()) + f", {len(out.equates)} equates, "
        f"{len(out.externals)} externals")
    return 0


def check_region(a: argparse.Namespace, lo: int, hi: int, m: gn.Model) -> list[str]:
    """Generate lo-hi, assemble it alone, compare with the image, run the listing checks."""
    work = a.work.resolve() / f"{lo:06X}"
    work.mkdir(parents=True, exist_ok=True)
    incbin = str(a.image.resolve())
    out = gn.generate(m, lo, hi, incbin)
    (work / "region.asm").write_text(out.source)
    (work / "equates.asm").write_text(gn.equates_text(out.equates))
    (work / "externals.asm").write_text(gn.externals_text(out.externals))
    eq = f'\tinclude\t"{a.equates.resolve()}"\n' if a.equates else ""
    wrap = (f'\tinclude\t"{MACROS}"\n{eq}\tinclude\t"equates.asm"\n\tinclude\t"externals.asm"\n'
            f"\torg\t${lo:X}\n\tinclude\t\"region.asm\"\n")
    (work / "main.asm").write_text(wrap)
    probs = []
    built, lst_text = ls.assemble(work / "main.asm", work / "main.bin")
    ref = m.image[lo:hi]
    if len(built) != hi - lo:
        return [f"{lo:06X}: built {len(built)} bytes, expected {hi - lo}"]
    diff = sum(1 for x, y in zip(built, ref, strict=True) if x != y)
    print(f"{lo:06X}-{hi:06X}: {len(built)} bytes, {diff} differences; " + ", ".join(
        f"{k} {v}" for k, v in out.stats.items()))
    if diff:
        probs.append(f"{lo:06X}-{hi:06X}: {diff} bytes differ")
    macros = ls.macro_names(MACROS)
    lst = ls.parse(lst_text, macros)
    lst.statements = [s for s in lst.statements if lo <= s.address < hi]
    ls.sizes(lst, hi)
    seeds, untaken = load_seeds(a.seeds)
    extra, outside = listed_seeds(m.cls, m.image, seeds, lambda x: lo <= x < hi)
    rep = ls.descent_check(lst, built, lo, extra, set(load_unreached(a.seeds)),
                           set(m.cls.noreturn), untaken, outside)
    print(f"  descent check: {rep.reached} instruction statements reached, "
          f"{len(rep.unreached)} not, {len(rep.errors)} errors")
    probs += [f"  {e}" for e in rep.errors[:20]]
    if rep.unreached:
        probs.append(f"  {len(rep.unreached)} instruction statements unreached, the first "
                     + ", ".join(f"{x:06X}" for x in rep.unreached[:8]))
    lint = ls.address_lint(lst, m.decisions, lo, hi, frozenset(macros), built, lo,
                           switch_ranges(m.cls))
    print(f"  address lint: {len(lint.errors)} errors, {lint.allowed} listed constants, "
          f"{len(lint.undecided)} undecided")
    probs += [f"  {e}" for e in lint.errors[:20]]
    # the shift test: the same source with a pad in front
    pad = 2
    shifted = out.source.replace(f"\tassert\t*=${lo:06X}", f"\tdcb.b\t{pad},0\n;", 1)
    shifted = shifted.replace(f"\tassert\t*=${hi:06X}", ";", 1)
    (work / "shifted.asm").write_text(shifted)
    (work / "main_shift.asm").write_text(wrap.replace("region.asm", "shifted.asm"))
    padded, _ = ls.assemble(work / "main_shift.asm", work / "main_shift.bin")
    sh = ls.shift_check(lst, built, padded, lo, pad, lo, hi)
    print(f"  shift test: {sh.changed} statements changed, {sh.expected} expected, "
          f"{len(sh.errors)} errors")
    probs += [f"  {e}" for e in sh.errors[:20]]
    return probs


def listed_seeds(c: cl.Classification, image: bytes, seeds: list[tuple[int, str]],
                 inside: Callable[[int], bool]
                 ) -> tuple[list[int], set[int]]:
    """For a descent check over part of the image: the seeds that lie inside (the entries with
    evidence, the reviewed seeds, the vectors and game_entries, the static targets of
    instructions outside) and the classified instruction starts outside (a flow may end there)."""
    extra = [x for x in c.entries if inside(x)] + [x for x, _ in seeds if inside(x)]
    for base, _ in cl.VECTOR_TABLES:
        for n in range(1, 64):
            v = int.from_bytes(image[base + 4 * n : base + 4 * n + 4], "big")
            if inside(v):
                extra.append(v)
    extra += [x for x in cl.GAME_ENTRIES if inside(x)]
    starts = c.code_starts(image)
    for a in starts:
        if not inside(a):
            insn = decode(image, a)
            t = insn.target if insn else None
            if t is not None and inside(t):
                extra.append(t)
    return extra, {x for x in starts if not inside(x)}


def cmd_check_region(a: argparse.Namespace) -> int:
    m = model(a, {a.start})
    probs = check_region(a, a.start, a.end, m)
    print("\n".join(probs) if probs else "ok")
    return 1 if probs else 0


def cmd_check_listing(a: argparse.Namespace) -> int:
    binary = a.binary.read_bytes()
    lst = ls.parse(a.listing.read_text(), ls.macro_names(a.macros))
    lo, hi = a.range if a.range else (a.origin, a.origin + len(binary))
    ls.sizes(lst, a.origin + len(binary))
    c = cl.load(a.classification)
    seeds, untaken = load_seeds(a.seeds)
    code = {x.address for x in lst.statements if x.kind == "instr"}
    image = a.image.read_bytes()
    extra, outside = listed_seeds(c, image, seeds, lambda x: x in code)
    allowed = load_unreached(a.seeds)
    rep = ls.descent_check(lst, binary, a.origin, extra, set(allowed), set(c.noreturn), untaken,
                           outside)
    lst.statements = [s for s in lst.statements if lo <= s.address < hi]
    lint = ls.address_lint(lst, opd.load(a.operands), lo, hi, frozenset(ls.macro_names(a.macros)),
                           binary, a.origin, switch_ranges(c))
    print(f"descent: {rep.reached} reached, {len(rep.unreached)} unreached, {len(rep.errors)} "
          f"errors; lint: {len(lint.errors)} errors, {len(lint.undecided)} undecided")
    for e in rep.errors + lint.errors:
        print(" ", e)
    for x in rep.unreached:
        print(f"  {x:06X}: an instruction statement nothing reaches (list it under `unreached` "
              f"in {a.seeds} with an argument, or make it data)")
    return 1 if rep.errors or rep.unreached or lint.errors else 0


def cmd_check_unidasm(a: argparse.Namespace) -> int:
    image = a.image.read_bytes()
    c = cl.load(a.classification)
    starts = c.code_starts(image)
    bad = 0
    total = 0
    for s in c.spans:
        if s.kind != "code":
            continue
        r = subprocess.run([a.unidasm, str(a.image), "-arch", "m68010", "-basepc",
                            f"{s.start:x}", "-skip", str(s.start), "-count",
                            str(s.end - s.start)], capture_output=True, text=True, check=True)
        got = []
        for line in r.stdout.splitlines():
            if ":" in line:
                got.append(int(line.split(":")[0], 16))
        mine = [x for x in starts if s.start <= x < s.end]
        total += len(mine)
        if got != sorted(mine):
            bad += 1
            first = next((x for x, y in zip(got, sorted(mine), strict=False) if x != y), None)
            print(f"{s.start:06X}-{s.end:06X}: boundaries differ (first at {first})")
    print(f"{total} instruction boundaries in {sum(1 for s in c.spans if s.kind == 'code')} "
          f"code ranges; {bad} ranges differ from unidasm")
    return 1 if bad else 0


def cmd_pccov(a: argparse.Namespace) -> int:
    image = a.image.read_bytes()
    c = cl.load(a.classification)
    starts = c.code_starts(image)
    runs = {}
    done = {}
    fail = 0
    for p in a.runs:
        name = p.stem.removeprefix("pccov-")
        header, pcs = pc.load_run(p)
        runs[name] = (header, pcs)
        done[name] = header.get("run", "")
        bad = pc.check(pcs, set(starts))
        print(f"{name}: {len(pcs)} distinct PCs, {len(bad)} not a classified instruction start")
        for x in bad[:20]:
            print(f"  {x:06X}")
        fail |= bool(bad)
    a.summary.write_text(pc.summary(runs, starts, done))
    print(f"{a.summary} written")
    return 1 if fail else 0


def main() -> int:
    p = argparse.ArgumentParser(prog="tools/m68k", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    def inputs(q: argparse.ArgumentParser) -> None:
        q.add_argument("--image", type=Path, default=IMAGE)
        q.add_argument("--classification", type=Path, default=CLASSIFICATION)
        q.add_argument("--operands", type=Path, default=OPERANDS)
        q.add_argument("--seeds", type=Path, default=SEEDS)
        q.add_argument("--snapshot", type=Path, default=SNAPSHOT)
        q.add_argument("--equates", type=Path, default=None)

    q = sub.add_parser("classify")
    q.add_argument("--image", type=Path, default=IMAGE)
    q.add_argument("--out", type=Path, default=CLASSIFICATION)
    q.add_argument("--operands", type=Path, default=OPERANDS)
    q.add_argument("--seeds", type=Path, default=SEEDS)
    q.add_argument("--no-mame", action="store_true",
                   help="classify without MAME runs (not the committed classification)")
    q.add_argument("runs", type=Path, nargs="*")
    q.set_defaults(func=cmd_classify)

    q = sub.add_parser("stats")
    q.add_argument("--classification", type=Path, default=CLASSIFICATION)
    q.set_defaults(func=cmd_stats)

    q = sub.add_parser("gen")
    inputs(q)
    q.add_argument("start", type=hexarg)
    q.add_argument("end", type=hexarg)
    q.add_argument("--out", type=Path, required=True)
    q.add_argument("--equates-out", type=Path)
    q.add_argument("--externals-out", type=Path)
    q.add_argument("--incbin", default="../../build/stunrun-68k.bin")
    q.set_defaults(func=cmd_gen)

    q = sub.add_parser("check-region")
    inputs(q)
    q.add_argument("start", type=hexarg)
    q.add_argument("end", type=hexarg)
    q.add_argument("--work", type=Path, required=True)
    q.set_defaults(func=cmd_check_region)

    q = sub.add_parser("check-listing")
    q.add_argument("--image", type=Path, default=IMAGE)
    q.add_argument("--listing", type=Path, required=True)
    q.add_argument("--binary", type=Path, required=True)
    q.add_argument("--origin", type=hexarg, default=0)
    q.add_argument("--range", type=hexarg, nargs=2)
    q.add_argument("--classification", type=Path, default=CLASSIFICATION)
    q.add_argument("--operands", type=Path, default=OPERANDS)
    q.add_argument("--seeds", type=Path, default=SEEDS)
    q.add_argument("--macros", type=Path, default=MACROS)
    q.set_defaults(func=cmd_check_listing)

    q = sub.add_parser("check-unidasm")
    q.add_argument("--image", type=Path, default=IMAGE)
    q.add_argument("--classification", type=Path, default=CLASSIFICATION)
    q.add_argument("--unidasm", default="unidasm")
    q.set_defaults(func=cmd_check_unidasm)

    q = sub.add_parser("pccov-read")
    q.add_argument("fifo", type=Path)
    q.add_argument("out", type=Path)
    q.set_defaults(func=lambda a: pc.read_trace(a.fifo, a.out) and 0)

    q = sub.add_parser("pccov")
    q.add_argument("--image", type=Path, default=IMAGE)
    q.add_argument("--classification", type=Path, default=CLASSIFICATION)
    q.add_argument("--summary", type=Path, required=True)
    q.add_argument("runs", type=Path, nargs="+")
    q.set_defaults(func=cmd_pccov)

    a = p.parse_args()
    return int(a.func(a))


if __name__ == "__main__":
    sys.exit(main())
