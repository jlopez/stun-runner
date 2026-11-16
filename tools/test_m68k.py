"""The 68k descent, classification, generator and listing checks (docs/14-68k-descent.md).

In CI (vasm only: no ROMs, no MAME, no unidasm, no IDA):

- the decoder on every 68010 instruction form, assembled by vasm here: each statement decodes to
  its length, and the decoder's text assembles back to the same bytes; the forms that are not
  68010 code decode to nothing;
- the descent, the classification and the generator on a synthetic 68010 program assembled here
  (vectors, a switch with its bound check, a computed call, a code-pointer table, the boot
  program's return-address idiom, a call that never returns, data that decodes as code, text,
  fill, both FFFF byte immediates, branches of both sizes, every absolute form): the generated
  source reassembles to the program, and the listing checks pass on it;
- the listing checks fail when the source is broken: a flow into data, an unreached instruction,
  a ROM address written as a number, a symbol that does not move with its target;
- asm/68k/macros.asm encodes what it says; the committed classification covers 000000-05CF86
  with no gap or overlap and decides 0445F0 and 026CD2 as code with their evidence; the operand
  decisions, the reviewed seeds and the MAME summary are consistent with it.

Locally, with build/stunrun-68k.bin: the generator's source for the three code regions
assembles to the image with 0 differences and passes the listing checks.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from pathlib import Path

import pytest
from m68k import __main__ as cli
from m68k import classify as cl
from m68k import gen as gn
from m68k import listing as ls
from m68k import operands as opd
from m68k import pccov as pc
from m68k.decode import decode, format_insn

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parent
MACROS = REPO / "asm/68k/macros.asm"
IMAGE = REPO / "build/stunrun-68k.bin"
CLASSIFICATION = REPO / "data/68k/classification.json"


def vasm() -> str | None:
    return shutil.which(os.path.expanduser(os.environ.get("VASM", "vasmm68k_mot")))


needs_vasm = pytest.mark.skipif(vasm() is None, reason="vasm not available")


def assemble(tmp: Path, name: str, source: str) -> tuple[bytes, str]:
    src = tmp / f"{name}.asm"
    src.write_text(source)
    return ls.assemble(src, tmp / f"{name}.bin", vasm() or "vasmm68k_mot")


# --- the decoder ---------------------------------------------------------------------------------

FORMS = """
	ori.b	#$12,d1
	ori.w	#$1234,(a2)
	ori.l	#$12345678,-(a3)
	ori.b	#$1F,ccr
	ori.w	#$2700,sr
	andi.b	#$F0,($10,a4)
	andi.w	#$F00F,($10,a4,d5.w)
	andi.l	#$FFFF,d0
	andi.b	#$FE,ccr
	andi.w	#$F8FF,sr
	subi.w	#3,$1234.w
	addi.l	#$10000,$123456
	eori.b	#$80,d7
	eori.w	#$8000,sr
	eori.b	#1,ccr
	cmpi.w	#$16,d0
	cmpi.l	#$7FFF,(a0)+
near:
	btst	#5,$60C001
	btst	#3,(label,pc)
	bchg	#7,d2
	bclr	#0,(a1)
	bset	#31,d3
	btst	d1,d2
	btst	d1,#$40
	bchg	d1,(a2)+
	bclr	d4,-(a5)
	bset	d6,($20,a6)
	movep.w	($10,a1),d2
	movep.l	($10,a1),d2
	movep.w	d2,($10,a1)
	movep.l	d2,(-$10,a1)
	moves.w	(a0),d1
	moves.l	d2,($8,a3)
	move.b	d0,d1
	move.w	a0,d1
	move.l	(a0)+,-(a1)
	move.b	#$FF,$FF9518
	move.w	(near,pc,d0.w),d0
	move.l	(near,pc,a1.l),($12,a2,d3.l)
	movea.w	d0,a1
	movea.l	#label,a2
	move.w	sr,d0
	move.w	ccr,d1
	move.w	d2,ccr
	move.w	#$2000,sr
	negx.b	d0
	negx.l	(a0)
	clr.b	d0
	clr.w	$FF8000
	clr.l	-(sp)
	neg.w	d1
	not.l	d2
	nbcd	d3
	swap	d4
	bkpt	#3
	pea	(a0)
	pea	$1234.w
	pea	label
	pea	(label,pc)
	ext.w	d5
	ext.l	d6
	movem.w	d0-d2/a0,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(sp)+,d2-d7/a2-a6
	movem.w	($10,a0),d0/a1
	movem.l	label,d0-d1
	movem.l	d0/d4,(a3)
	tst.b	d0
	tst.w	(a1)
	tst.l	$FF9000
	tas	(a2)
	illegal
	trap	#15
	link	a6,#-$20
	unlk	a6
	move.l	a0,usp
	move.l	usp,a1
	reset
	nop
	stop	#$2700
	rte
	rtd	#8
	rts
	trapv
	rtr
	movec	a0,vbr
	movec	sfc,d1
	movec	d2,dfc
	movec	usp,a3
	jsr	(a0)
	jsr	($10,a1)
	jsr	label
	jsr	label.w
	jsr	(label,pc)
	jmp	(a2)
	jmp	(near2,pc,d0.w)
	jmp	label
	lea	(label,pc),a0
	lea	(0,a0),a1
	lea	$400,a0
	move.w	#0,d0
	lea	$0.w,a1
	lea	label,a2
	lea	($10,a3,d0.l),a4
	chk	#$40,d1
	chk	(a0),d2
	addq.b	#1,d0
	addq.w	#8,a1
	subq.l	#4,(a2)
	st	d0
	sne	(a0)
	sgt	$FF9500
	dbf	d0,label
	dbeq	d1,label
	bra.s	near2
	bra.w	label
	bsr.s	near2
	bsr.w	label
near2:
	bhi.s	near2
	bls.w	label
	beq.w	label
	moveq	#-1,d0
	moveq	#$7F,d7
	or.b	(a0),d0
	or.w	d1,(a2)
	or.l	#$1,d3
	divu.w	#10,d0
	divs.w	(a1),d2
	sbcd	d0,d1
	sbcd	-(a0),-(a1)
	sub.b	d0,d1
	sub.w	a0,d1
	sub.l	d2,(a3)
	sub.l	#$10,d0
	suba.w	d0,a1
	suba.l	#4,sp
	subx.w	d0,d1
	subx.l	-(a0),-(a1)
	cmp.b	(a0)+,d0
	cmp.w	#$100,d1
	cmp.l	a0,d2
	cmpa.w	d0,a1
	cmpa.l	#label,a2
	cmpm.b	(a0)+,(a1)+
	eor.w	d0,d1
	eor.l	d2,($4,a3)
	and.b	d0,d1
	and.l	(a0),d2
	and.w	d3,-(a4)
	mulu.w	#$100,d0
	muls.w	d1,d2
	abcd	d0,d1
	abcd	-(a2),-(a3)
	exg	d0,d1
	exg	a0,a1
	exg	d2,a3
	add.b	d0,d1
	add.w	(a1),d2
	add.l	#$10,d0
	adda.w	#$404,a0
	adda.l	#label,a0
	addx.b	d0,d1
	addx.w	-(a0),-(a1)
	asl.w	#2,d0
	asr.l	d1,d2
	lsl.b	#8,d3
	lsr.w	d4,d5
	roxl.l	#1,d6
	roxr.b	d7,d0
	rol.w	#4,d1
	ror.l	d2,d3
	asl.w	(a0)
	lsr.w	($10,a1)
	roxl.w	$FF9000
	ror.w	-(a2)
label:
	nop
"""


@needs_vasm
def test_decoder_round_trip(tmp_path: Path) -> None:
    """Every form: the decoder's length is the statement's, its text assembles to its bytes."""
    src = f'\tinclude\t"{MACROS}"\n\torg\t$1000\n{FORMS}'
    image, lst_text = assemble(tmp_path, "forms", src)
    lst = ls.parse(lst_text, set())
    ls.sizes(lst, 0x1000 + len(image))
    full = bytes(0x1000) + image
    texts = []
    assert len(lst.statements) == FORMS.count("\n\t")
    for s in lst.statements:
        insn = decode(full, s.address)
        assert insn is not None, f"{s.address:X} {s.text}: not decoded"
        if s.text.startswith("move.b\t#$FF,$FF9518"):
            texts.append(s.text)
            continue
        assert insn.length == s.size, f"{s.text}: {insn.length} != {s.size}"
        texts.append(format_insn(insn, None))
    again, _ = assemble(tmp_path, "again", "\torg\t$1000\n" + "".join(f"\t{t}\n" for t in texts))
    assert again == image


def test_not_code() -> None:
    """Words a 68010 program does not contain decode to nothing."""
    bad = {
        "line A": [0xA000],
        "line F": [0xF200, 0x0000],
        "bra.l (68020)": [0x60FF, 0, 0],
        "chk.l (68020)": [0x4100],
        "a scale factor (68020)": [0x3030, 0x0200],
        "a full extension word (68020)": [0x3030, 0x0130],
        "cmpi.w #n,(d16,pc) (68020)": [0x0C7A, 0x0016, 0x0010],
        "a byte immediate with a high byte": [0x103C, 0x12FF],
        "movec of a 68020 register": [0x4E7A, 0x0002],
        "move.b to an address register": [0x1040],
        "addq.b to an address register": [0x5208],
        "tst of an address register (68020)": [0x4A48],
        "a bit-field instruction (68020)": [0xE8C0, 0x0000],
    }
    for why, words in bad.items():
        image = b"".join(w.to_bytes(2, "big") for w in words) + bytes(8)
        assert decode(image, 0) is None, why


# --- a synthetic program ---------------------------------------------------------------------

PROGRAM = """
	include	"{macros}"
ram_FF9518	equ	$FF9518
	org	0
vectors:
	dc.l	$FFFFC000,start,handler
	dcb.l	61,0
start:
	moveb_ffff_abs	ram_FF9518
	lea	(buffer).l,a1
	moveb_ffff_ind	1
	move.w	(ram_FF9518-ABS_SHORT).w,d0
	clr.w	$60C000
	bsr.s	near
	bsr.w	far
	jsr	switch
	jsr	switch2
	jsr	via_register
	jsr	via_table
	jsr	ret2
	jsr	walk
	jsr	low.w
	lea	(.ret,pc),a2
	bra.w	no_stack
.ret:
	move.l	#$12345,d0
	andi.l	#$FFFF,d0
	movea.l	#table,a3
	move.l	#callback,(a3)
	pea	$1234.w
	pea	text
	beq.s	.skip
	jsr	fatal
	dc.b	'NOT CODE',0,0
.skip:
	dbf	d0,start
	rts
near:
	beq.w	near_end
	nop
near_end:
	rts
switch:
	cmpi.w	#2,d0
	bhi.s	.default
	add.w	d0,d0
	move.w	(.tbl,pc,d0.w),d0
	jmp	(.tbl,pc,d0.w)
.tbl:
	dc.w	.c0-.tbl,.c1-.tbl,.c2-.tbl
.c0:
	moveq	#0,d1
	rts
.c1:
	moveq	#1,d1
	rts
.c2:
	moveq	#2,d1
.default:
	rts
switch2:
	cmpi.w	#2,d0
	bcs.s	.out
	cmpi.w	#4,d0
	bhi.s	.out
	add.w	d0,d0
	move.w	(.tbl-4,pc,d0.w),d0
	jmp	(.tbl,pc,d0.w)
.tbl:
	dc.w	.c2-.tbl,.c3-.tbl,.out-.tbl
.c2:
	moveq	#2,d1
	rts
.c3:
	moveq	#3,d1
.out:
	rts
via_register:
	lea	(computed-$40).l,a0
	adda.l	#$44,a0
	subq.l	#4,a0
	jsr	(a0)
	rts
computed:
	nop
	rts
via_table:
	lea	routines,a0
	move.w	d0,d1
	lsl.w	#2,d1
	movea.l	(0,a0,d1.w),a0
	jsr	(a0)
	rts
routines:
	dc.l	r0,r1,r2
ret2:
	lea	.back,a2	; the return address kept across another load, as at 00953A
	movea.l	#0,a0
	bra.w	no_stack
.back:
	moveq	#5,d0
	rts
walk:
	move.w	rec_count,d7	; a record table walked as at 000EB2
	lea	rec_table,a3
.loop:
	move.w	(0,a3),d1
	movea.l	(4,a3),a0
	jsr	(a0)
	adda.l	#10,a3
	dbf	d7,.loop
	rts
rec_count:
	dc.w	2
rec_table:
	dc.w	1,2
	dc.l	rec_a
	dc.w	3
	dc.w	4,5
	dc.l	rec_b
	dc.w	6
	dc.w	7,8
	dc.l	rec_a
	dc.w	9
rec_a:
	rts
rec_b:
	moveq	#1,d0
	rts
r0:
	rts
r1:
	moveq	#1,d0
	rts
r2:
	moveq	#2,d0
	rts
no_stack:
	moveq	#3,d7
	jmp	(a2)
fatal:
	stop	#$2700
	bra.s	fatal
handler:
	rte
callback:
	rts
	dc.w	$4E71,$4E71,$4E75
text:
	dc.b	'HELLO WORLD',0
	dc.b	"DON'T PANIC",0
	even
table:
	dc.w	1,2,3,4
	dcb.b	64,0
buffer:
	dc.w	$4E75
	dc.l	orphan
	even
	dcb.b	$7000-*,$FF
low:
	rts
orphan:
	moveq	#7,d0
	rts
far:
	rts
odd_text:
	dc.b	'ODD TEXT',0
odd_pad:
	dc.b	0
	nop
	rts
	dcb.b	32,0
dead_b:			; nothing reaches these three: unknown, with the search in their notes
	moveq	#0,d0
	rts
dead_inner:		; called from dead_a, another unknown range (as 02D9A8 calls 0224C2)
	moveq	#1,d0
	rts
	dcb.b	32,0
dead_a:
	jsr	dead_inner
	rts
	dcb.b	32,0
dead_switch:		; a switch in an unknown range (as 02E548): the note steps over its table
	cmpi.w	#2,d0
	bhi.s	.out
	add.w	d0,d0
	move.w	(.tbl,pc,d0.w),d0
	jmp	(.tbl,pc,d0.w)
.tbl:
	dc.w	.c0-.tbl,.c1-.tbl,.out-.tbl
.c0:
	moveq	#0,d1
	rts
.c1:
	moveq	#1,d1
.out:
	rts
end:
"""


def layout(end: int) -> cl.Layout:
    return cl.Layout(end=end, eligible=[(0x100, end)],
                     vector_tables=[(0, "the synthetic vector table")], entries=[], known=[])


def synthetic(tmp: Path) -> tuple[bytes, str, cl.Classification]:
    image, lst = assemble(tmp, "program", PROGRAM.format(macros=MACROS))
    callback = ls.parse(lst, set()).symbols["callback"]
    c = cl.classify(image, set(), [(callback, "a reviewed seed of the test")], {}, {},
                    layout(len(image)))
    return image, lst, c


def model(image: bytes, c: cl.Classification) -> gn.Model:
    assert c.result is not None
    starts = cl.routine_starts(c.result)
    addrs = {o.value for i in c.result.insns.values() for o in i.operands
             if o.mode in ("absl", "pcdisp")}
    decisions = {(int(str(e["at"]), 16), int(str(e["operand"]))): str(e["decision"])
                 for e in opd.build(c.result.insns, starts, addrs)}
    m = gn.Model(image, c, {}, set(), {}, gn.load_equates(None), gn.io_segments(), decisions)
    m.build({0x100})
    return m


@needs_vasm
def test_descent_and_classification(tmp_path: Path) -> None:
    image, lst_text, c = synthetic(tmp_path)
    assert cl.validate(c) == []
    syms = ls.parse(lst_text, ls.macro_names(MACROS)).symbols
    kinds = {s.start: s.kind for s in c.spans}
    ev = c.entries
    r = c.result
    assert r is not None

    def kind_at(a: int) -> str:
        return next(s.kind for s in c.spans if s.start <= a < s.end)

    for name in ("start", "near", "far", "switch", "computed", "via_table", "r0", "r1", "r2",
                 "no_stack", "fatal", "handler", "low", "callback"):
        assert syms[name] in r.insns, name
    # the switch: table, bound, cases
    tbl, tbl2 = sorted(r.switches.values(), key=lambda x: x.table)
    assert tbl.count == 3 and tbl.lo == 0 and "bound" in tbl.bound
    assert kinds[tbl.table] == "switch"
    # cases 2-4: the move reads (table - 4) + 2 * index, as at 026CCE
    assert (tbl2.lo, tbl2.count, tbl2.table, tbl2.base) == (2, 3, tbl2.jmp + 4, tbl2.jmp + 4)
    assert ev[syms["switch2.c3"] if "switch2.c3" in syms else tbl2.targets(image)[1]] \
        .startswith("case 3 of the switch")
    # the idioms leave their evidence
    assert ev[syms["computed"]].startswith("computed jsr")
    assert ev[syms["r1"]].startswith("entry 1 of the code-pointer table")
    assert ev[syms[".ret"]].startswith("return address")
    assert ev[syms["callback"]].startswith("reviewed: ")
    assert kind_at(syms["routines"]) == "pointers"
    # the return address with another load between the lea and the bra (00953A)
    assert ev[syms[".back"]].startswith("return address: a2 set at")
    # the record table (000E12): three records of ten bytes, the count word before them
    assert ev[syms["rec_b"]].startswith("entry 1 of the record table")
    rt = next(s for s in c.spans if s.start == syms["rec_table"])
    assert (rt.kind, rt.end) == ("data", syms["rec_a"]) and "3 records of 10 bytes" in rt.note
    assert kind_at(syms["rec_count"]) == "data"
    # what is not code stays out of it
    assert kind_at(syms["text"]) == "text"
    # a table loaded with movea.l # decodes cleanly into the rts of `buffer`: still data
    assert kind_at(syms["table"]) == "data"
    assert kind_at(syms["table"] + 8) == "fill"
    assert kind_at(syms["callback"] + 2) == "unknown"  # decodes, but nothing reaches it
    note = next(s.note for s in c.spans if s.start == syms["callback"] + 2)
    assert "decodes cleanly" in note and "no reference found" in note
    # a routine whose address is only in data: its note says where, not "no reference found"
    note = next(s.note for s in c.spans if s.start == syms["orphan"])
    assert kind_at(syms["orphan"]) == "unknown"
    assert f"possible references: {syms['buffer'] + 2:06X} (data)" in note, note
    # an unknown range from an odd address: the decode starts at the next even one
    note = next(s.note for s in c.spans if s.start == syms["odd_pad"])
    assert f"decodes cleanly from {syms['odd_pad'] + 1:06X} as 2 instructions" in note, note
    # a routine inside an unknown range called from another unknown range: the note names the
    # call, though nothing refers to the range's start (02249E, 0224C2 called from 02D9A8)
    note = next(s.note for s in c.spans if s.start == syms["dead_b"])
    assert kind_at(syms["dead_b"]) == "unknown" and "no reference found" not in note, note
    assert f"possible references to {syms['dead_inner']:06X} inside it: " \
        f"{syms['dead_a'] + 2:06X} (unknown)" in note, note
    note = next(s.note for s in c.spans if s.start == syms["dead_a"])
    assert "decodes cleanly" in note and "no reference found" in note, note
    # a switch in an unknown range: the decode steps over its table and decodes the cases
    sp = next(s for s in c.spans if s.start == syms["dead_switch"])
    assert (sp.kind, sp.end) == ("unknown", syms["end"]), (sp.kind, sp.end)
    assert f"decodes cleanly from {sp.start:06X} as 9 instructions, a switch table at " \
        f"{sp.start + 16:06X} (jmp at {sp.start + 12:06X}, cases 0-2)" in sp.note, sp.note
    assert kind_at(syms["buffer"]) == "data"  # referenced by the lea
    fatal_call = next(a for a, i in r.insns.items() if i.target == syms["fatal"])
    assert fatal_call in c.noreturn
    # the classification round-trips through its file
    path = tmp_path / "c.json"
    path.write_text(cl.dump(c))
    back = cl.load(path)
    assert [(s.start, s.end, s.kind) for s in back.spans] == \
        [(s.start, s.end, s.kind) for s in c.spans]
    assert back.entries == c.entries


def generated(tmp: Path) -> tuple[bytes, gn.Model, gn.Output, str]:
    image, _, c = synthetic(tmp)
    m = model(image, c)
    out = gn.generate(m, 0, len(image), str(tmp / "program.bin"))
    wrap = (f'\tinclude\t"{MACROS}"\n\tinclude\t"equates.asm"\n\tinclude\t"externals.asm"\n'
            "\torg\t0\n\tinclude\t\"gen.asm\"\n")
    (tmp / "gen.asm").write_text(out.source)
    (tmp / "equates.asm").write_text(gn.equates_text(out.equates))
    (tmp / "externals.asm").write_text(gn.externals_text(out.externals))
    return image, m, out, wrap


@needs_vasm
def test_generator_reassembles(tmp_path: Path) -> None:
    image, m, out, wrap = generated(tmp_path)
    built, _ = assemble(tmp_path, "main", wrap)
    assert built == image
    src = out.source
    assert "moveb_ffff_abs\tram_FF9518" in src and "moveb_ffff_ind\t1" in src
    assert "(ram_FF9518-ABS_SHORT).w" in src
    assert "PORT0" in src  # I/O by its equate
    assert "pea\t$1234.w" in src  # a constant
    assert "#$12345" in src and "#$FFFF" in src  # constants by the operand rules
    assert "movea.l\t#tbl_" in src or "movea.l\t#dat_" in src  # an address register load
    assert "\tincbin\t" in src and "\tdc.b\t'HELLO WORLD',0" in src and "\tdcb.b\t" in src
    assert "\tdc.b\t\"DON'T PANIC\",0" in src  # vasm has no escapes: the other quote
    assert "\tbra.s\t" in src and "\tbra.w\t" in src and "\tbsr.s\t" in src
    assert "jsr\tsub_7000.w" in src
    assert out.stats["macros"] == 2
    assert not out.externals


def checks(tmp: Path, wrap: str, source: str, m: gn.Model, lo: int, hi: int,
           noreturn: set[int] | None = None
           ) -> tuple[ls.DescentReport, ls.LintReport, ls.ShiftReport, bytes]:
    (tmp / "gen.asm").write_text(source)
    built, lst_text = assemble(tmp, "main", wrap)
    lst = ls.parse(lst_text, ls.macro_names(MACROS))
    lst.statements = [s for s in lst.statements if lo <= s.address < hi]
    ls.sizes(lst, hi)
    rep = ls.descent_check(lst, built, 0, list(m.cls.entries), set(),
                           set(m.cls.noreturn) if noreturn is None else noreturn)
    lint = ls.address_lint(lst, m.decisions, lo, hi, frozenset(ls.macro_names(MACROS)), built, 0,
                           cli.switch_ranges(m.cls), cli.pointer_ranges(m.cls))
    shifted = source.replace("\tassert\t*=$000000", "\tdcb.b\t2,0\n;", 1)
    shifted = shifted.replace(f"\tassert\t*=${hi:06X}", ";", 1)
    (tmp / "gen.asm").write_text(shifted)
    padded, _ = assemble(tmp, "main_shift", wrap)
    sh = ls.shift_check(lst, built, padded, 0, 2, lo, hi)
    return rep, lint, sh, built


@needs_vasm
def test_listing_checks_pass(tmp_path: Path) -> None:
    image, m, out, wrap = generated(tmp_path)
    rep, lint, sh, built = checks(tmp_path, wrap, out.source, m, 0, len(image))
    assert built == image
    assert rep.errors == [] and rep.unreached == [] and rep.reached == len(m.insns)
    assert lint.errors == [] and lint.allowed >= 2
    assert sh.errors == [] and sh.expected == sh.changed > 10


def inv(m: gn.Model) -> dict[str, int]:
    return {n: a for a, n in m.labels.items()}


@needs_vasm
def test_listing_checks_fail_on_broken_source(tmp_path: Path) -> None:
    image, m, out, wrap = generated(tmp_path)
    src = out.source
    hi = len(image)
    names = inv(m)
    # a ROM address written as a number: the lint, and the shift test (it does not move)
    line = next(x for x in src.splitlines() if x.startswith("\tjsr\tsub_") and ".w" not in x)
    broken = src.replace(line, f"\tjsr\t${names[line.split(chr(9))[2]]:X}", 1)
    _, lint, sh, built = checks(tmp_path, wrap, broken, m, 0, hi)
    assert built == image
    assert any("ROM address written as a number" in e for e in lint.errors)
    # a long immediate address left as a number: the lint
    line = next(x for x in src.splitlines() if x.startswith("\tmovea.l\t#"))
    sym = line.split("#")[1].split(",")[0]
    broken = src.replace(line, line.replace(sym, f"${names[sym]:X}"), 1)
    _, lint, _, _ = checks(tmp_path, wrap, broken, m, 0, hi)
    assert any("has no decision" in e for e in lint.errors)
    # a label pinned by an equate: the shift test
    name = "sub_100"
    broken = src.replace(f"{name}:\n", "", 1) + f"{name}\tequ\t$100\n"
    _, _, sh, _ = checks(tmp_path, wrap, broken, m, 0, hi)
    assert any("did not change" in e for e in sh.errors)
    # a flow into data: the descent check (pea text -> jsr text, same size)
    line = next(x for x in src.splitlines() if x.startswith("\tpea\tstr_"))
    rep, _, _, _ = checks(tmp_path, wrap, src.replace(line, line.replace("pea", "jsr"), 1), m,
                          0, hi)
    assert any("outside the code ranges" in e for e in rep.errors), rep.errors
    # an instruction nothing reaches: the unknown words written as instructions
    unk = next(x for x in m.cls.spans if x.kind == "unknown" and "decodes cleanly" in x.note)
    lines = src.splitlines()
    i = lines.index(f"dat_{unk.start:X}:") + 1
    assert lines[i].startswith("\tincbin") and unk.end - unk.start == 6
    lines[i] = "\tnop\n\tnop\n\trts"
    rep, _, _, built = checks(tmp_path, wrap, "\n".join(lines) + "\n", m, 0, hi)
    assert built == image and rep.errors == []
    assert rep.unreached == [unk.start, unk.start + 2, unk.start + 4]


@needs_vasm
def test_listing_checks_fail_on_more_broken_source(tmp_path: Path) -> None:
    """Each failure path of the listing checks has a case that takes it."""
    image, m, out, wrap = generated(tmp_path)
    src = out.source
    hi = len(image)
    names = inv(m)
    # a pointer written as a number in a dc.l: the lint
    line = next(x for x in src.splitlines() if x.startswith("\tdc.l\tsub_2"))
    sym = line.split("\t")[2]
    _, lint, _, built = checks(tmp_path, wrap, src.replace(line, f"\tdc.l\t${names[sym]:X}", 1),
                               m, 0, hi)
    assert built == image and any("dc.l" in e and "could be an address" in e for e in lint.errors)
    # pea of a ROM address written as a number (absolute long, not the constant pea N.w)
    line = next(x for x in src.splitlines() if x.startswith("\tpea\tstr_"))
    sym = line.split("\t")[2]
    _, lint, _, built = checks(tmp_path, wrap, src.replace(line, f"\tpea\t${names[sym]:X}", 1),
                               m, 0, hi)
    assert built == image and any("pea" in e and "written as a number" in e for e in lint.errors)
    # a PC-relative operand written as a number: the lint, and the shift test (the displacement
    # changes when the code moves, though no symbol is named)
    line = next(x for x in src.splitlines() if x.startswith("\tlea\t(sub_") and ",pc)" in x)
    sym = line.split("(")[1].split(",")[0]
    _, lint, sh, built = checks(tmp_path, wrap, src.replace(line, line.replace(
        sym, f"${names[sym]:X}"), 1), m, 0, hi)
    assert built == image and any("PC-relative" in e for e in lint.errors), lint.errors
    assert any("changed without naming a moved symbol" in e for e in sh.errors), sh.errors
    # a switch entry written as a number: the lint
    line = next(x for x in src.splitlines() if x.startswith("\tdc.w\tsub_") and "-" in x)
    a, b = line.split("\t")[2].split("-")
    _, lint, _, built = checks(tmp_path, wrap, src.replace(
        line, f"\tdc.w\t${(names[a] - names[b]) & 0xFFFF:X}", 1), m, 0, hi)
    assert built == image and any("switch entry" in e for e in lint.errors), lint.errors
    # an address written as an expression of numbers: the lint reads its value from the bytes
    line = next(x for x in src.splitlines() if x.startswith("\tjsr\tsub_") and ".w" not in x)
    sym = line.split("\t")[2]
    _, lint, _, built = checks(tmp_path, wrap, src.replace(
        line, f"\tjsr\t${names[sym] - 8:X}+8", 1), m, 0, hi)
    assert built == image and any("written as a number" in e for e in lint.errors), lint.errors
    # a pointer-table entry written as two numeric words: the lint (a dc.w in a pointer range)
    line = next(x for x in src.splitlines() if x.startswith("\tdc.l\tsub_2"))
    v = names[line.split("\t")[2]]
    _, lint, _, built = checks(tmp_path, wrap, src.replace(
        line, f"\tdc.w\t${v >> 16:04X},${v & 0xFFFF:04X}", 1), m, 0, hi)
    assert built == image and any("dc.w in a pointer table" in e for e in lint.errors), \
        lint.errors
    # a word that moves by something other than the pad: the shift test
    line = next(x for x in src.splitlines() if x.startswith("\tdc.l\tsub_2"))
    sym = line.split("\t")[2]
    _, _, sh, _ = checks(tmp_path, wrap, src.replace(line, f"\tdc.l\t{sym}*2", 1), m, 0, hi)
    assert any("not by the pad" in e for e in sh.errors), sh.errors
    # a call followed by data that the classification does not list as never returning
    rep, _, _, _ = checks(tmp_path, wrap, src, m, 0, hi, noreturn=set())
    assert any("falls through into no code" in e for e in rep.errors), rep.errors


@needs_vasm
def test_descent_check_statement_size(tmp_path: Path) -> None:
    """A statement holding more than the one instruction the descent decodes there."""
    src = "two\tmacro\n\tnop\n\tnop\n\tendm\n\torg\t0\n\ttwo\n\trts\n"
    image, lst_text = assemble(tmp_path, "size", src)
    lst = ls.parse(lst_text, {"two"})
    ls.sizes(lst, len(image))
    rep = ls.descent_check(lst, image, 0, [0], set(), set())
    assert any("statement of 4 bytes, instruction of 2" in e for e in rep.errors), rep.errors


LINT = """
	org	$30000
here:
	jsr	$30010
	lea	$BFF00,a0
	jsr	$C0000
	move.w	$FF9518,d0
	pea	$1234.w
	pea	$30000
	jsr	$418B0+8
	lea	$20520+0,a1
	movea.l	#$30220+0,a2
	lea	($30000,pc),a1
	move.w	($30004,pc,d0.w),d0
	bra.w	$30000
	lea	(here,pc),a1
	jsr	here
	moveq	#1,d0
	dc.l	$30000
	dc.l	$40+$30000
	dc.l	here
switch:
	dc.w	$10
	dc.w	here-switch
pointers:
	dc.l	here
	dc.w	$0003,$0010
	dc.w	0,0
"""


@needs_vasm
def test_address_lint_forms(tmp_path: Path) -> None:
    """Every operand form that can hold a ROM address as a number, above 020000 too."""
    image, lst_text = assemble(tmp_path, "lint", LINT)
    lst = ls.parse(lst_text, set())
    ls.sizes(lst, 0x30000 + len(image))
    sw = lst.symbols["switch"]
    pt = lst.symbols["pointers"]
    rep = ls.address_lint(lst, {}, 0, 0x0C0000, frozenset(), image, 0x30000, [(sw, sw + 4)],
                          [(pt, pt + 12)])
    bad = {e.split(":")[0] for e in rep.errors}
    flagged = {s.text.split(";")[0].strip() for s in lst.statements if f"{s.address:06X}" in bad}
    want = {"jsr\t$30010", "lea\t$BFF00,a0", "pea\t$30000", "jsr\t$418B0+8", "lea\t$20520+0,a1",
            "movea.l\t#$30220+0,a2", "lea\t($30000,pc),a1", "move.w\t($30004,pc,d0.w),d0",
            "bra.w\t$30000", "dc.l\t$30000", "dc.l\t$40+$30000", "dc.w\t$10",
            "dc.w\t$0003,$0010", "dc.w\t0,0"}
    assert flagged == want, flagged ^ want


def test_validate_finds_bad_ranges() -> None:
    def c(*spans: tuple[int, int, str]) -> cl.Classification:
        return cl.Classification([cl.Span(a, b, k) for a, b, k in spans], {}, {}, {}, None, 0x20)

    assert cl.validate(c((0, 0x10, "code"), (0x10, 0x20, "data"))) == []
    assert any("gap" in e for e in cl.validate(c((0, 0x10, "code"), (0x12, 0x20, "data"))))
    assert any("overlap" in e for e in cl.validate(c((0, 0x10, "code"), (0x0E, 0x20, "data"))))
    assert any("not word-aligned" in e for e in cl.validate(c((0, 0x11, "code"),
                                                              (0x11, 0x20, "data"))))
    assert any("whole longs" in e for e in cl.validate(c((0, 0x06, "pointers"),
                                                         (0x06, 0x20, "data"))))
    assert any("end at" in e for e in cl.validate(c((0, 0x10, "code"),)))


@needs_vasm
def test_check_listing_cli(tmp_path: Path, capsys: pytest.CaptureFixture[str],
                           monkeypatch: pytest.MonkeyPatch) -> None:
    """tools/m68k check-listing fails on an instruction statement nothing reaches, unless the
    seeds file lists it with an argument."""
    image, m, out, wrap = generated(tmp_path)
    c = m.cls
    assert c.result is not None
    (tmp_path / "program.bin").write_bytes(image)
    (tmp_path / "c.json").write_text(cl.dump(c))
    starts = cl.routine_starts(c.result)
    addrs = {o.value for i in c.result.insns.values() for o in i.operands
             if o.mode in ("absl", "pcdisp")}
    (tmp_path / "op.json").write_text(opd.dump(opd.build(c.result.insns, starts, addrs)))
    unk = next(x for x in c.spans if x.kind == "unknown" and "decodes cleanly" in x.note)
    lines = out.source.splitlines()
    i = lines.index(f"dat_{unk.start:X}:") + 1
    lines[i] = "\tnop\n\tnop\n\trts"
    (tmp_path / "gen.asm").write_text("\n".join(lines) + "\n")
    built, _ = assemble(tmp_path, "main", wrap)
    assert built == image

    def run(seeds: dict[str, object]) -> int:
        (tmp_path / "seeds.json").write_text(json.dumps(
            {"format": "stunrun-68k-seeds 1", "seeds": [], "untaken": [], **seeds}))
        monkeypatch.setattr("sys.argv", [
            "tools/m68k", "check-listing", "--listing", str(tmp_path / "main.lst"),
            "--binary", str(tmp_path / "main.bin"), "--image", str(tmp_path / "program.bin"),
            "--classification", str(tmp_path / "c.json"), "--operands",
            str(tmp_path / "op.json"), "--seeds", str(tmp_path / "seeds.json"),
            "--macros", str(MACROS)])
        return cli.main()

    assert run({}) == 1
    assert f"{unk.start:06X}: an instruction statement nothing reaches" in capsys.readouterr().out
    listed = [{"at": f"{unk.start + k:06X}", "argument": "the test's listed exception"}
              for k in (0, 2, 4)]
    assert run({"unreached": listed}) == 0, capsys.readouterr().out


@needs_vasm
def test_listed_seeds(tmp_path: Path) -> None:
    """The seeds of a descent check over part of the image: a zero vector is no seed (a range
    from 000000 is not seeded at the stack pointer's long), the entries of the layout are."""
    image, m, out, wrap = generated(tmp_path)
    c = m.cls
    names = inv(m)
    whole = layout(len(image))
    extra, outside = cli.listed_seeds(c, image, [], lambda x: 0 <= x < len(image), whole)
    assert 0 not in extra and names["sub_100"] in extra and outside == set()
    extra, _ = cli.listed_seeds(c, image, [], lambda x: 0 <= x < len(image))  # stunrun's layout
    assert 0 not in extra
    lay = layout(len(image))
    lay.entries = [names["sub_100"] + 4]
    extra, _ = cli.listed_seeds(c, image, [], lambda x: x == names["sub_100"] + 4, lay)
    assert extra == [names["sub_100"] + 4]
    # the descent check of the whole program from 000000 with those seeds: no error
    (tmp_path / "gen.asm").write_text(out.source)
    built, lst_text = assemble(tmp_path, "main", wrap)
    lst = ls.parse(lst_text, ls.macro_names(MACROS))
    ls.sizes(lst, len(built))
    extra, outside = cli.listed_seeds(c, image, [], lambda x: 0 <= x < len(image), whole)
    rep = ls.descent_check(lst, built, 0, extra, set(), set(c.noreturn), None, outside)
    assert rep.errors == [] and rep.unreached == [], (rep.errors, rep.unreached)


@needs_vasm
def test_check_listing_partial_tree(tmp_path: Path, capsys: pytest.CaptureFixture[str],
                                    monkeypatch: pytest.MonkeyPatch) -> None:
    """check-listing on a tree where one range is source and the rest still incbin slices: the
    range is reached only from code inside the blobs, and flows out of it into them; --range
    scopes what the descent check reports to the range."""
    image, m, _, _ = generated(tmp_path)
    c = m.cls
    assert c.result is not None
    # ret2 (jsr ret2 from start, in a blob) up to walk; it flows out by bra.w no_stack (a blob)
    syms = ls.parse(assemble(tmp_path, "program", PROGRAM.format(macros=MACROS))[1],
                    set()).symbols
    lo, hi = syms["ret2"], syms["walk"]
    unk = next(x for x in c.spans if x.kind == "unknown" and "decodes cleanly" in x.note)
    assert hi < unk.start
    prog = tmp_path / "program.bin"
    out = gn.generate(m, lo, hi, str(prog))
    (tmp_path / "gen.asm").write_text(out.source)
    (tmp_path / "equates.asm").write_text(gn.equates_text(out.equates))
    (tmp_path / "externals.asm").write_text(gn.externals_text(out.externals))
    tree = (f'\tinclude\t"{MACROS}"\n\tinclude\t"equates.asm"\n\tinclude\t"externals.asm"\n'
            f'\torg\t0\n\tincbin\t"{prog}",0,{lo}\n\tinclude\t"gen.asm"\n'
            f'\tincbin\t"{prog}",{hi},{unk.start - hi}\n\tnop\n\tnop\n\trts\n'
            f'\tincbin\t"{prog}",{unk.start + 6}\n')
    built, lst_text = assemble(tmp_path, "main", tree)
    assert built == image
    (tmp_path / "c.json").write_text(cl.dump(c))
    starts = cl.routine_starts(c.result)
    addrs = {o.value for i in c.result.insns.values() for o in i.operands
             if o.mode in ("absl", "pcdisp")}
    (tmp_path / "op.json").write_text(opd.dump(opd.build(c.result.insns, starts, addrs)))
    (tmp_path / "seeds.json").write_text(json.dumps(
        {"format": "stunrun-68k-seeds 1", "seeds": [], "untaken": []}))

    def run(*rng: int) -> int:
        monkeypatch.setattr("sys.argv", [
            "tools/m68k", "check-listing", "--listing", str(tmp_path / "main.lst"),
            "--binary", str(tmp_path / "main.bin"), "--image", str(prog),
            "--classification", str(tmp_path / "c.json"), "--operands",
            str(tmp_path / "op.json"), "--seeds", str(tmp_path / "seeds.json"),
            "--macros", str(MACROS)] + (["--range", f"{rng[0]:X}", f"{rng[1]:X}"] if rng else []))
        return cli.main()

    assert run(lo, hi) == 0, capsys.readouterr().out
    capsys.readouterr()
    # the planted instructions outside the range fail the check of the whole tree only
    assert run() == 1
    assert f"{unk.start:06X}: an instruction statement nothing reaches" in capsys.readouterr().out
    # the check needs both: the targets of the code in the blobs (jsr ret2 from start) ...
    lst = ls.parse(lst_text, ls.macro_names(MACROS))
    ls.sizes(lst, len(built))
    lst.statements = [x for x in lst.statements if lo <= x.address < hi]
    extra, outside = cli.listed_seeds(c, image, [], lambda x: lo <= x < hi)
    blob_targets = {i.target for a, i in c.result.insns.items() if not lo <= a < hi}
    assert lo in extra and lo in blob_targets and lo not in c.entries
    rep = ls.descent_check(lst, built, 0, [x for x in extra if x != lo], set(),
                           set(c.noreturn), None, outside)
    assert lo in rep.unreached, rep.unreached
    # ... and the instruction starts outside, where its bra.w ends
    rep = ls.descent_check(lst, built, 0, extra, set(), set(c.noreturn), None, set())
    assert any("outside the code ranges" in e for e in rep.errors), rep.errors
    rep = ls.descent_check(lst, built, 0, extra, set(), set(c.noreturn), None, outside)
    assert rep.errors == [] and rep.unreached == []


def test_gen_rejects_bad_ranges(capsys: pytest.CaptureFixture[str],
                                monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """gen and check-region refuse a reversed, negative or out-of-image range (exit 2) before
    reading the image."""
    for cmd, rng in (("gen", ["012F06", "000212"]), ("gen", ["05CF00", "05D000"]),
                     ("gen", ["-10", "300"]), ("check-region", ["012F06", "000212"])):
        extra = ["--out", str(tmp_path / "g.asm")] if cmd == "gen" else \
            ["--work", str(tmp_path / "w")]
        monkeypatch.setattr("sys.argv", ["tools/m68k", cmd, "--image",
                                         str(tmp_path / "absent.bin"), *extra, "--", *rng])
        assert cli.main() == 2, (cmd, rng)
        assert "is not within 000000-05CF86" in capsys.readouterr().err
    assert not (tmp_path / "g.asm").exists()


def test_classify_needs_the_mame_runs(capsys: pytest.CaptureFixture[str],
                                      monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """`classify` without the runs of make pccov would drop the MAME entries: it refuses."""
    monkeypatch.setattr("sys.argv", ["tools/m68k", "classify", "--image",
                                     str(tmp_path / "absent.bin"), "--out",
                                     str(tmp_path / "c.json")])
    assert cli.main() == 1
    assert "make pccov" in capsys.readouterr().out
    assert not (tmp_path / "c.json").exists()


@needs_vasm
def test_descent_check_mid_instruction(tmp_path: Path) -> None:
    """A flow into the middle of an instruction statement is reported."""
    image, lst_text = assemble(tmp_path, "mid", "\torg\t0\nb:\tmove.l\t#$4E714E75,d0\n")
    lst = ls.parse(lst_text, set())
    ls.sizes(lst, len(image))
    rep = ls.descent_check(lst, image, 0, [2], set(), set())
    assert any("where no instruction statement starts" in e for e in rep.errors), rep.errors
    assert rep.unreached == [0]


@needs_vasm
def test_macros(tmp_path: Path) -> None:
    src = (f'\tinclude\t"{MACROS}"\nram_FF9518\tequ\t$FF9518\n\torg\t0\n'
           "\tmoveb_ffff_ind\t1\n\tmoveb_ffff_ind\t4\n\tmoveb_ffff_abs\tram_FF9518\n"
           "\tmove.w\t(ram_FF9518-ABS_SHORT).w,d0\n")
    image, _ = assemble(tmp_path, "macros", src)
    assert image.hex() == "12bcffff" "18bcffff" "13fcffff00ff9518" "30389518"
    for at, dst in ((0, "(a1)"), (4, "(a4)"), (8, "$FF9518")):
        insn = decode(image, at)
        assert insn is not None and insn.operands[0].raw == 0xFFFF
        assert format_insn(insn, None) == f"move.b\t#$FF,{dst}"


def cli_files(tmp: Path, image: bytes, c: cl.Classification) -> list[str]:
    """The synthetic program's image, classification and operand decisions as the CLI's files."""
    assert c.result is not None
    (tmp / "program.bin").write_bytes(image)
    (tmp / "c.json").write_text(cl.dump(c))
    starts = cl.routine_starts(c.result)
    addrs = {o.value for i in c.result.insns.values() for o in i.operands
             if o.mode in ("absl", "pcdisp")}
    (tmp / "op.json").write_text(opd.dump(opd.build(c.result.insns, starts, addrs)))
    return ["--image", str(tmp / "program.bin"), "--classification", str(tmp / "c.json"),
            "--operands", str(tmp / "op.json"), "--seeds", str(tmp / "absent-seeds.json")]


@needs_vasm
def test_gen_reports_bad_cuts(tmp_path: Path, capsys: pytest.CaptureFixture[str],
                              monkeypatch: pytest.MonkeyPatch) -> None:
    """A START inside an instruction, or a range that leaves a used vasm local outside, is a
    usage error (exit 2 and the reason), not a traceback."""
    image, m, _, _ = generated(tmp_path)
    files = cli_files(tmp_path, image, m.cls)
    # a vasm local branched to from before it: the range up to it leaves it outside
    hi = min(a for a, n in m.labels.items() if n.startswith(".l") and m.anchors[a] == "code"
             and any(r < a for r in m.refs.get(a, ())))
    r = min(m.refs[hi])
    lo = max(a for a, n in m.labels.items() if a <= r and not n.startswith("."))
    for cmd, rng in (("gen", (lo + 1, hi)), ("gen", (lo, hi)), ("check-region", (lo, hi))):
        extra = ["--out", str(tmp_path / "g.asm")] if cmd == "gen" else \
            ["--work", str(tmp_path / "w")]
        monkeypatch.setattr("sys.argv", ["tools/m68k", cmd, *files, *extra,
                                         f"{rng[0]:X}", f"{rng[1]:X}"])
        assert cli.main() == 2, (cmd, rng)
        err = capsys.readouterr().err
        assert err.startswith(f"{cmd}: ") and "cut at global labels" in err, err
        assert ("not an instruction start" in err) == (rng[0] == lo + 1), err
    assert not (tmp_path / "g.asm").exists()


@needs_vasm
def test_gen_equates_and_snapshot(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """gen with --equates and a snapshot (decision C2, docs/14 section 5): a name the equates
    file defines is used and not emitted again; snapshot ROM and RAM names are used verbatim; a
    snapshot function start is a global label."""
    image, m, _, _ = generated(tmp_path)
    files = cli_files(tmp_path, image, m.cls)
    callback = next(a for a, e in m.cls.entries.items() if e.startswith("reviewed"))
    assert m.labels[callback] == f"sub_{callback:X}"
    local = min(a for a, n in m.labels.items() if n.startswith(".l") and m.anchors[a] == "code")
    (tmp_path / "snapshot.json").write_text(json.dumps({
        "names": [{"ea": f"0x{callback:06X}", "name": "my_callback"},
                  {"ea": "0xFF9518", "name": "game_flag"}],
        "functions": [f"0x{local:06X}"]}))
    (tmp_path / "hw.asm").write_text("; test equates\nMY_PORT0\tequ\t$60C000\n")
    monkeypatch.setattr("sys.argv", [
        "tools/m68k", "gen", *files, "--snapshot", str(tmp_path / "snapshot.json"),
        "--equates", str(tmp_path / "hw.asm"), "--incbin", str(tmp_path / "program.bin"),
        "--out", str(tmp_path / "gen.asm"), "--equates-out", str(tmp_path / "equates.asm"),
        "--externals-out", str(tmp_path / "externals.asm"), "0", f"{len(image):X}"])
    assert cli.main() == 0
    src = (tmp_path / "gen.asm").read_text()
    eq = (tmp_path / "equates.asm").read_text()
    assert "MY_PORT0" in src and "PORT0" not in src.replace("MY_PORT0", "")
    assert "MY_PORT0" not in eq and "PORT0" not in eq
    assert "game_flag" in src and "ram_FF9518" not in src and "game_flag\tequ\t$FF9518" in eq
    assert "my_callback:" in src and f"sub_{callback:X}" not in src
    assert f"sub_{local:X}:" in src and f".l{local:X}" not in src
    wrap = (f'\tinclude\t"{MACROS}"\n\tinclude\t"hw.asm"\n\tinclude\t"equates.asm"\n'
            '\tinclude\t"externals.asm"\n\torg\t0\n\tinclude\t"gen.asm"\n')
    built, _ = assemble(tmp_path, "main", wrap)
    assert built == image


@needs_vasm
def test_operand_rule_table_base(tmp_path: Path) -> None:
    """R2b: add.l/addi.l #X,Dn then movea.l Dn,An with X in a table range is an address (the
    boot program's 002FBE); without the movea of that register, or X outside a table, R6."""
    src = ("\torg\t$1000\n"
           "\taddi.l\t#$2000,d6\n\tmovea.l\td6,a6\n"      # R2b
           "\tadd.l\t#$2004,d3\n\tmovea.l\td3,a0\n"       # R2b (add form)
           "\taddi.l\t#$2000,d6\n\tmovea.l\td5,a6\n"      # another register: R6
           "\taddi.l\t#$2000,d6\n\tnop\n"                 # no movea: R6
           "\taddi.l\t#$3000,d6\n\tmovea.l\td6,a6\n")     # outside the table: R6
    image, _ = assemble(tmp_path, "r2b", src)
    image = bytes(0x1000) + image
    insns = {}
    a = 0x1000
    while a < len(image):
        insn = decode(image, a)
        assert insn is not None
        insns[a] = insn
        a += insn.length
    got = [(e["at"], e["rule"], e["decision"])
           for e in opd.build(insns, set(), set(), [(0x2000, 0x2010)])]
    assert got == [("001000", "R2b", "address"), ("001008", "R2b", "address"),
                   ("001010", "R6", "constant"), ("001018", "R6", "constant"),
                   ("001020", "R6", "constant")], got
    assert [e["rule"] for e in opd.build(insns, set(), set())] == ["R6"] * 5


def test_pccov_rejects_empty_runs(tmp_path: Path, capsys: pytest.CaptureFixture[str],
                                  monkeypatch: pytest.MonkeyPatch) -> None:
    """A trace the debugger never wrote (an empty run file) or a run that did not finish (no
    `# run` line) fails pccov-read, pccov and classify instead of passing vacuously."""
    trace = tmp_path / "empty.trace"
    trace.write_text("")
    monkeypatch.setattr("sys.argv", ["tools/m68k", "pccov-read", str(trace),
                                     str(tmp_path / "pccov-empty.txt")])
    assert cli.main() == 1
    assert "no executed PC" in capsys.readouterr().err
    empty = tmp_path / "pccov-empty.txt"
    empty.write_text(empty.read_text() + "# run frames 120\n")
    unfinished = tmp_path / "pccov-unfinished.txt"
    unfinished.write_text("# trace_lines 1\n# distinct_pcs 1\n000216\n")
    for run, why in ((empty, "no executed PC"), (unfinished, "no `# run` line")):
        summary = tmp_path / "summary.json"
        monkeypatch.setattr("sys.argv", ["tools/m68k", "pccov", "--image",
                                         str(tmp_path / "absent.bin"), "--summary",
                                         str(summary), str(run)])
        assert cli.main() == 1
        assert why in capsys.readouterr().out and not summary.exists()
        monkeypatch.setattr("sys.argv", ["tools/m68k", "classify", "--image",
                                         str(tmp_path / "absent.bin"), "--out",
                                         str(tmp_path / "c.json"), str(run)])
        with pytest.raises(SystemExit, match=why.replace("`", ".")):
            cli.main()
        assert not (tmp_path / "c.json").exists()


# --- the committed files ---------------------------------------------------------------------


def test_committed_classification() -> None:
    c = cl.load(CLASSIFICATION)
    assert c.end == 0x05CF86
    assert cl.validate(c) == []
    by_kind = {k: [s for s in c.spans if s.kind == k] for k in cl.KINDS}

    def span(a: int) -> cl.Span:
        return next(s for s in c.spans if s.start <= a < s.end)

    # docs/06 overturned: executed code in the island, a switch jmp IDA made a data word
    assert span(0x0445F0).kind == "code" and span(0x04462C).kind == "code"
    assert c.entries[0x0445F0].startswith("computed jsr")
    assert span(0x026CD2).kind == "code"
    sw = span(0x026CD6)
    assert sw.kind == "switch" and sw.jmp == 0x026CD2
    assert all(s.start % 2 == 0 for s in by_kind["code"])
    # addresses, kinds and evidence only: no byte values
    j = json.loads(CLASSIFICATION.read_text())
    assert set(j) == {"format", "range", "ranges", "entries", "noreturn"}
    for r in j["ranges"]:
        assert set(r) <= {"start", "end", "kind", "note", "jmp", "base"}
    for e in j["entries"]:
        assert set(e) == {"at", "evidence"}
    # every entry with evidence starts a code instruction range or lies in one
    for a in c.entries:
        assert span(a).kind == "code", f"{a:06X}"


def test_committed_operands_and_seeds() -> None:
    c = cl.load(CLASSIFICATION)
    code = [(s.start, s.end) for s in c.spans if s.kind == "code"]
    d = opd.load(REPO / "data/68k/operands.json")
    assert d
    for (a, i), decision in d.items():
        assert any(lo <= a < hi for lo, hi in code), f"{a:06X}"
        assert decision in ("address", "constant", "undecided") and 0 <= i < 2
    j = json.loads((REPO / "data/68k/seeds.json").read_text())
    assert j["format"] == "stunrun-68k-seeds 1"
    assert set(j) == {"format", "comment", "seeds", "untaken", "unreached"}
    for e in j["seeds"] + j["untaken"] + j["unreached"]:
        assert set(e) == {"at", "argument"} and len(e["argument"]) > 40
    for e in j["untaken"]:
        assert any(lo <= int(e["at"], 16) < hi for lo, hi in code)
    # R2b: the boot program's table bases added to an index and moved into A6 (002FBE ...)
    for at in (0x002FBE, 0x00307C, 0x00317E, 0x0048CC, 0x0049A6):
        assert d[(at, 0)] == "address", f"{at:06X}"


def test_committed_pccov_summary() -> None:
    """Every range of executed instructions MAME saw lies in the classification's code."""
    s = json.loads((REPO / "artifacts/pccov-summary.json").read_text())
    c = cl.load(CLASSIFICATION)
    code = [(x.start, x.end) for x in c.spans if x.kind == "code"]
    assert s["format"] == "stunrun-pccov 1"
    assert set(s["runs"]) == {"attract", "game", "selftest", "soundtest", "postest"}
    for lo, hi in s["union"]["ranges"]:
        a, b = int(lo, 16), int(hi, 16)
        assert any(x <= a and b <= y for x, y in code), f"{lo}-{hi}"


def test_pccov_reader(tmp_path: Path) -> None:
    trace = tmp_path / "t.txt"
    trace.write_text("000216: lea     $0.w, A0\n   (loops for 12 instructions)\n"
                     "00021A: movea.l ($0,A0), A7\n000216: lea     $0.w, A0\n")
    out = tmp_path / "pcs.txt"
    assert pc.read_trace(trace, out) == 2
    header, pcs = pc.load_run(out)
    assert pcs == {0x216, 0x21A} and header["distinct_pcs"] == "2"
    assert pc.check(pcs, {0x216}) == [0x21A]
    assert pc.ranges(pcs, {0x216: 4, 0x21A: 4}) == [["000216", "00021E"]]
    # the summary lists the runs by name, whatever order they are given in (make pccov's)
    runs: dict[str, tuple[dict[str, str], set[int]]] = {
        n: ({}, pcs) for n in ("soundtest", "attract", "postest")}
    assert list(json.loads(pc.summary(runs, {}, {}))["runs"]) == ["attract", "postest",
                                                                  "soundtest"]


# --- locally, with the image -----------------------------------------------------------------


@pytest.mark.skipif(not IMAGE.exists() or vasm() is None, reason="needs the image and vasm")
@pytest.mark.parametrize("lo,hi", [(0x000212, 0x012F06), (0x020430, 0x04397E),
                                   (0x04397E, 0x046AEE)])
def test_regions_reassemble(tmp_path: Path, lo: int, hi: int) -> None:
    """Point 6 of issue #29: the generator's source for a code region is the image."""
    r = subprocess.run(["uv", "run", "--frozen", "python", str(TOOLS / "m68k"), "check-region",
                        f"{lo:06X}", f"{hi:06X}", "--work", str(tmp_path)],
                       capture_output=True, text=True, check=False, cwd=REPO)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "0 differences" in r.stdout and r.stdout.rstrip().endswith("ok")
