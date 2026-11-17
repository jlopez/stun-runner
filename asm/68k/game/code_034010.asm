; game/code_034010.asm, 034010-037C52: game program code (pair S) with the data, text and tables
; that lie between its routines; the first routine is sub_34010. Cut at routine starts into files
; of about 16 KB named by their first address (decision C11).
; 034010-037C52: 28 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 034010 037C52 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$034010,"game/code_034010.asm misplaced"
sub_34010:
	move.w	#$186,($2A,a0)
	move.w	#$700,($28,a0)
	move.w	#$B60,($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$140,($3A,a0)
	move.w	#$64,($3E,a0)
	move.w	#$19,($64,a0)
	movea.l	($12,a0),a1
	move.w	#$FDC0,($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l3405C
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l3405E
.l3405C:
	moveq	#$0,d1
.l3405E:
	bra.w	loc_34364
sub_34062:
	move.w	#$E1,($2A,a0)
	move.w	#$48A,($28,a0)
	move.w	#$700,($36,a0)
	move.w	#$320,($38,a0)
	move.w	#$C0,($3A,a0)
	move.w	#$1,($3E,a0)
	move.w	#$4B,($64,a0)
	movea.l	($12,a0),a1
	move.w	#$FE60,($36,a1)
	move.w	($6,a2),($26,a0)
	moveq	#$0,d0
	move.w	d1,d0
	andi.l	#$8000,d0
	beq.s	.l340D8
	move.b	#$4,($67,a0)
	move.w	(a3),d0
	ext.l	d0
	addi.l	#$4B0,d0
	cmpi.l	#$C80,d0
	bhi.s	.l340CC
	move.w	(a3),d0
	ext.l	d0
	addi.l	#$4B0,d0
	bra.s	.l340D2
.l340CC:
	move.l	#$C80,d0
.l340D2:
	move.w	d0,($1E,a0)
	bra.s	.l340F6
.l340D8:
	cmpi.w	#$C,ram_FF9550
	bne.s	.l340F0
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l340F2
.l340F0:
	moveq	#$0,d1
.l340F2:
	move.w	d1,($1E,a0)
.l340F6:
	bra.w	loc_34368
sub_340FA:
	move.w	#$226,($2A,a0)
	move.w	#$4BA,($28,a0)
	move.w	#$DA0,($36,a0)
	move.w	#$320,($38,a0)
	move.w	#$190,($3A,a0)
	move.w	#$8,($3E,a0)
	move.w	#$64,($64,a0)
	movea.l	($12,a0),a1
	move.w	#$FD60,($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l34146
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l34148
.l34146:
	moveq	#$0,d1
.l34148:
	bra.w	loc_34364
sub_3414C:
	move.w	#$145,($2A,a0)
	move.w	#$4B0,($28,a0)
	move.w	#$A00,($36,a0)
	move.w	#$280,($38,a0)
	move.w	#$F0,($3A,a0)
	move.w	#$3,($3E,a0)
	clr.w	($64,a0)
	movea.l	($12,a0),a1
	move.w	#$FE40,($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l34196
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l34198
.l34196:
	moveq	#$0,d1
.l34198:
	bra.w	loc_34364
sub_3419C:
	move.w	#$190,($2A,a0)
	move.w	#$6D9,($28,a0)
	move.w	#$C10,($36,a0)
	move.w	#$640,($38,a0)
	move.w	#$190,($3A,a0)
	move.w	#$64,($3E,a0)
	move.w	#$32,($64,a0)
	movea.l	($12,a0),a1
	move.w	#$FCB0,($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l341E8
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l341EA
.l341E8:
	moveq	#$0,d1
.l341EA:
	bra.w	loc_34364
sub_341EE:
	clr.w	($2A,a0)
	clr.w	($28,a0)
	clr.w	($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$280,($3A,a0)
	clr.w	($3E,a0)
	move.w	#$3E8,($64,a0)
	movea.l	($12,a0),a1
	clr.w	($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l34230
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l34232
.l34230:
	moveq	#$0,d1
.l34232:
	bra.w	loc_34364
sub_34236:
	clr.w	($2A,a0)
	clr.w	($28,a0)
	clr.w	($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$230,($3A,a0)
	clr.w	($3E,a0)
	move.w	#$2EE,($64,a0)
	movea.l	($12,a0),a1
	clr.w	($36,a1)
	move.b	#$4,($67,a0)
	move.w	(a3),d0
	ext.l	d0
	addi.l	#$4B0,d0
	cmpi.l	#$C80,d0
	bhi.s	.l34284
	move.w	(a3),d0
	ext.l	d0
	addi.l	#$4B0,d0
	bra.s	.l3428A
.l34284:
	move.l	#$C80,d0
.l3428A:
	move.w	d0,($1E,a0)
	bra.w	loc_34368
sub_34292:
	clr.w	($2A,a0)
	clr.w	($28,a0)
	clr.w	($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$280,($3A,a0)
	clr.w	($3E,a0)
	move.w	#$1F4,($64,a0)
	movea.l	($12,a0),a1
	clr.w	($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l342D4
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l342D6
.l342D4:
	moveq	#$0,d1
.l342D6:
	bra.w	loc_34364
sub_342DA:
	clr.w	($2A,a0)
	clr.w	($28,a0)
	clr.w	($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$320,($3A,a0)
	clr.w	($3E,a0)
	move.w	#$1F4,($64,a0)
	movea.l	($12,a0),a1
	clr.w	($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l3431C
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	.l3431E
.l3431C:
	moveq	#$0,d1
.l3431E:
	bra.s	loc_34364
sub_34320:
	clr.w	($2A,a0)
	clr.w	($28,a0)
	clr.w	($36,a0)
	move.w	#$460,($38,a0)
	move.w	#$230,($3A,a0)
	clr.w	($3E,a0)
	move.w	#$2710,($64,a0)
	movea.l	($12,a0),a1
	clr.w	($36,a1)
	cmpi.w	#$C,ram_FF9550
	bne.s	.l34362
	move.w	(a3),d1
	ext.l	d1
	move.b	dat_4D6A8,d0
	asr.l	d0,d1
	bra.s	loc_34364
.l34362:
	moveq	#$0,d1
loc_34364:
	move.w	d1,($1E,a0)
loc_34368:
	movem.l	(-$8,a6),a2-a3
	unlk	a6
	rts
sub_34372:
	link	a6,#$0
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d4
	move.w	($12,a6),d0
	movea.l	#dat_4AF22,a3
	movea.l	($1A,a2),a4
	move.l	($8,a4),d5
	moveq	#$0,d1
	move.w	($76,a2),d1
	move.l	d1,d0
	andi.l	#$7000,d0
	cmpi.l	#$1000,d0
	bne.s	.l343B4
	move.l	d5,-(sp)
	move.l	a2,-(sp)
	jsr	sub_34578
.l343B4:
	move.l	a2,-(sp)
	jsr	sub_3475A
	clr.w	d2
	movea.l	d5,a5
	move.l	($E,a5),d3
	andi.l	#$8000,d3
	beq.w	.l34456
	btst	#$6,($67,a2)
	bne.s	.l343E2
	ori.b	#$40,($67,a2)
	move.w	($2E,a2),($32,a2)
.l343E2:
	movea.l	d5,a5
	move.w	(a5),d0
	ext.l	d0
	moveq	#$63,d1
	sub.l	d1,d0
	move.l	d0,d6
	move.l	d0,d2
	asl.l	#2,d2
	moveq	#$0,d1
	move.w	($2,a3,d2.l),d1
	move.l	d1,d3
	move.l	d0,d2
	asl.l	#2,d2
	moveq	#$0,d1
	move.w	($0,a3,d2.l),d1
	cmp.l	d1,d3
	bcc.s	.l34430
	moveq	#$0,d3
	move.l	d0,d1
	asl.l	#2,d1
	move.w	($2,a3,d1.l),d1
	cmp.w	($30,a2),d1
	bcc.s	.l34426
	asl.l	#2,d0
	move.w	($0,a3,d0.l),d1
	cmp.w	($30,a2),d1
	bls.s	.l34426
	moveq	#$1,d3
.l34426:
	moveq	#$0,d2
	tst.l	d3
	seq	d2
	neg.b	d2
	bra.s	.l3444E
.l34430:
	moveq	#$0,d2
	move.l	d0,d1
	asl.l	#2,d1
	move.w	($0,a3,d1.l),d1
	cmp.w	($30,a2),d1
	bcc.s	.l3444E
	asl.l	#2,d0
	move.w	($2,a3,d0.l),d1
	cmp.w	($30,a2),d1
	bls.s	.l3444E
	moveq	#$1,d2
.l3444E:
	tst.w	d2
	beq.s	.l34454
	move.w	d6,d2
.l34454:
	bra.s	.l3446A
.l34456:
	btst	#$6,($67,a2)
	beq.s	.l3446A
	move.w	($32,a2),($2E,a2)
	andi.b	#$BF,($67,a2)
.l3446A:
	move.l	a2,-(sp)
	jsr	sub_3584A
	cmp.l	a2,d0
	beq.s	.l3447A
.l34476:
	bra.w	.l3456E
.l3447A:
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_34924
	cmp.l	a2,d0
	beq.s	.l3448E
	bra.s	.l34476
.l3448E:
	move.l	d5,-(sp)
	move.l	a4,-(sp)
	move.l	a2,-(sp)
	jsr	sub_34F14
	cmp.l	a2,d0
	beq.s	.l344A2
	bra.w	.l3456E
.l344A2:
	movea.l	($1A,a2),a4
	move.l	($8,a4),d5
	movea.l	($C,a4),a3
	moveq	#$0,d1
	move.w	d4,d1
	move.l	d1,-(sp)
	move.l	a4,-(sp)
	move.l	a2,-(sp)
	jsr	sub_35166
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	($14,a3)
	jsr	sub_22DD6
	movea.l	($12,a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	($12,a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	($12,a2),a0
	move.l	($10,a3),($10,a0)
	move.w	($22,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($12,a2),a0
	bset	#$6,($38,a0)
	move.l	a2,-(sp)
	jsr	sub_351D0
	move.l	d5,-(sp)
	move.l	a2,-(sp)
	jsr	sub_35230
	tst.l	($16,a2)
	beq.s	.l3456C
	movea.l	($16,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($8,a1),($8,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($C,a1),($C,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($10,a1),($10,a0)
	movea.l	($16,a2),a0
	bset	#$6,($38,a0)
.l3456C:
	move.l	(a2),d0
.l3456E:
	movem.l	(-$24,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_34578:
	link	a6,#$0
	movem.l	d2-d5/a2-a3,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	btst	#$7,($11,a3)
	bne.w	.l34648
	cmpi.w	#$8000,($30,a2)
	bcc.s	.l345A4
	moveq	#$0,d2
	move.w	($30,a2),d2
	move.l	d2,d0
	bra.s	.l345B2
.l345A4:
	move.l	#$10000,d0
	moveq	#$0,d2
	move.w	($30,a2),d2
	sub.l	d2,d0
.l345B2:
	moveq	#$0,d2
	move.w	d0,d2
	divu.w	dat_4D840,d2
	move.w	d2,d5
	cmpi.w	#$8000,($30,a2)
	bcc.s	.l345CE
	move.w	d5,d2
	ext.l	d2
	neg.l	d2
	move.w	d2,d5
.l345CE:
	move.b	($4,a3),d2
	ext.w	d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C06
	move.l	d0,d2
	move.w	($1E,a2),d1
	ext.l	d1
	move.l	d2,d0
	move.l	d0,d3
	mulu.w	d1,d2
	swap	d0
	mulu.w	d1,d0
	swap	d1
	mulu.w	d1,d3
	add.l	d0,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	move.b	dat_4D849,d0
	subq.b	#1,d0
	asr.l	d0,d2
	move.w	d2,d3
	tst.w	d3
	beq.s	.l34620
	tst.w	d3
	bge.s	.l34618
	move.l	#$C000,d4
	bra.s	.l3461E
.l34618:
	move.l	#$4000,d4
.l3461E:
	bra.s	.l34622
.l34620:
	clr.w	d4
.l34622:
	moveq	#$0,d1
	move.w	($30,a2),d1
	move.l	d1,d0
	move.w	d3,d1
	ext.l	d1
	eor.l	d1,d0
	andi.l	#$C000,d0
	cmpi.l	#$4000,d0
	bne.s	.l34646
	move.w	d3,d2
	ext.l	d2
	neg.l	d2
	move.w	d2,d3
.l34646:
	bra.s	.l3464C
.l34648:
	clr.w	d3
	clr.w	d5
.l3464C:
	btst	#$7,($11,a3)
	beq.s	.l3465E
	move.w	d3,d0
	add.w	d0,($20,a2)
	bra.w	.l346B8
.l3465E:
	moveq	#$0,d1
	move.w	($30,a2),d1
	move.l	d1,d0
	moveq	#$0,d1
	move.w	d4,d1
	sub.l	d1,d0
	bcs.s	.l3467C
	moveq	#$0,d0
	move.w	($30,a2),d0
	moveq	#$0,d1
	move.w	d4,d1
	sub.l	d1,d0
	bra.s	.l3468A
.l3467C:
	moveq	#$0,d0
	move.w	($30,a2),d0
	moveq	#$0,d1
	move.w	d4,d1
	sub.l	d1,d0
	neg.l	d0
.l3468A:
	tst.w	d3
	blt.s	.l34694
	move.w	d3,d2
	ext.l	d2
	bra.s	.l3469A
.l34694:
	move.w	d3,d2
	ext.l	d2
	neg.l	d2
.l3469A:
	cmp.l	d0,d2
	bcc.s	.l346A6
	move.w	d3,d0
	add.w	d0,($20,a2)
	bra.s	.l346B8
.l346A6:
	moveq	#$0,d1
	move.w	d4,d1
	move.l	d1,d0
	moveq	#$0,d1
	move.w	($30,a2),d1
	sub.l	d1,d0
	move.w	d0,($20,a2)
.l346B8:
	tst.b	ram_FF9540
	beq.s	.l346C6
	move.w	d5,d0
	add.w	d0,($20,a2)
.l346C6:
	cmpi.w	#$3,($10,a2)
	bne.s	.l346DA
	btst	#$2,($67,a2)
	beq.s	.l346DA
	moveq	#$1,d0
	bra.s	.l346DC
.l346DA:
	moveq	#$0,d0
.l346DC:
	tst.l	d0
	beq.s	.l34732
	move.w	($26,a2),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#5,d0
	moveq	#$0,d1
	move.w	($2E,a2),d1
	move.w	ram_FFDD18,d2
	ext.l	d2
	add.l	d2,d1
	add.l	d1,d0
	move.w	d0,($30,a2)
	move.w	ram_FFDD16,d0
	ext.l	d0
	addi.l	#$4B0,d0
	cmpi.l	#$C80,d0
	bhi.s	.l34726
	move.w	ram_FFDD16,d0
	ext.l	d0
	addi.l	#$4B0,d0
	bra.s	.l3472C
.l34726:
	move.l	#$C80,d0
.l3472C:
	move.w	d0,($1E,a2)
	bra.s	.l34750
.l34732:
	move.w	($20,a2),d2
	ext.l	d2
	asr.l	#3,d2
	move.w	d2,d0
	sub.w	d0,($20,a2)
	cmpi.w	#$1,($10,a2)
	beq.s	.l34750
	move.w	($20,a2),d0
	add.w	d0,($30,a2)
.l34750:
	movem.l	(-$18,a6),d2-d5/a2-a3
	unlk	a6
	rts
sub_3475A:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($22,a2),d2
	move.w	($1E,a2),d0
	add.w	d0,($22,a2)
	move.w	($22,a2),d1
	ext.l	d1
	move.w	d2,d0
	ext.l	d0
	eor.l	d0,d1
	andi.l	#$8000,d1
	move.w	d1,d2
	moveq	#$0,d0
	move.w	($76,a2),d0
	move.l	d0,d1
	andi.l	#$F000,d1
	cmpi.l	#$1000,d1
	blt.w	.l34842
	bgt.s	.l347A4
	bra.w	.l34842
.l347A4:
	cmpi.l	#$3000,d1
	bne.s	.l347AE
	bra.s	.l347BA
.l347AE:
	cmpi.l	#$4000,d1
	bne.w	.l34842
	bra.s	.l347C6
.l347BA:
	move.w	ram_FFDC1A,($2E,a2)
	bra.w	.l3491A
.l347C6:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	btst	#$7,($11,a0)
	beq.s	.l34824
	moveq	#$0,d0
	move.w	($30,a2),d0
	move.l	d0,d1
	andi.l	#$8000,d1
	beq.s	.l347F8
	move.l	#$10000,d2
	moveq	#$0,d0
	move.w	($30,a2),d0
	move.l	d0,d1
	sub.l	d1,d2
	bra.s	.l34800
.l347F8:
	moveq	#$0,d1
	move.w	($30,a2),d1
	move.l	d1,d2
.l34800:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	move.w	($A,a0),d0
	cmp.w	d2,d0
	bhi.s	.l34822
	move.l	#$10000,d1
	moveq	#$0,d0
	move.w	($2E,a2),d0
	sub.l	d0,d1
	move.w	d1,($2E,a2)
.l34822:
	bra.s	.l3483E
.l34824:
	move.w	($30,a2),d0
	cmp.w	($2E,a2),d0
	bne.s	.l3483E
	move.w	($2E,a2),d0
	sub.w	($34,a2),d0
	ext.l	d0
	asl.l	#1,d0
	sub.w	d0,($2E,a2)
.l3483E:
	bra.w	.l3491A
.l34842:
	tst.w	d2
	beq.w	.l3491A
	tst.b	($6A,a2)
	bne.w	.l3491A
	move.w	($10,a2),d0
	bcs.s	.l34884
	bhi.s	.l3485A
	bra.s	.l3486A
.l3485A:
	cmpi.w	#$1,d0
	bne.s	.l34862
	bra.s	.l3486A
.l34862:
	cmpi.w	#$2,d0
	bne.s	.l34884
	bra.s	.l3486E
.l3486A:
	bra.w	.l3491A
.l3486E:
	move.l	($C,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a0
	move.w	($2E,a0),($2E,a2)
	bra.w	.l3491A
.l34884:
	cmpi.w	#$3,($10,a2)
	bne.s	.l34898
	btst	#$2,($67,a2)
	beq.s	.l34898
	moveq	#$1,d0
	bra.s	.l3489A
.l34898:
	moveq	#$0,d0
.l3489A:
	tst.l	d0
	bne.w	.l3491A
	btst	#$1,($67,a2)
	bne.w	.l3491A
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	move.b	($4,a0),d0
	addq.b	#4,d0
	movea.l	($1A,a2),a0
	movea.l	(a0),a0
	movea.l	($8,a0),a0
	move.b	($4,a0),d1
	addq.b	#4,d1
	cmp.b	d1,d0
	beq.s	.l3491A
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	btst	#$7,($11,a0)
	beq.s	.l348FC
	ext.w	d0
	add.w	d0,d0
	move.w	d0,d2
	asl.w	#3,d0
	add.w	d2,d0
	movea.l	#dat_4D6AA,a0
	ext.w	d1
	add.w	d1,d1
	adda.w	d0,a0
	move.w	($0,a0,d1.w),d0
	ext.l	d0
	asr.l	#3,d0
	bra.s	.l34916
.l348FC:
	ext.w	d0
	add.w	d0,d0
	move.w	d0,d2
	asl.w	#3,d0
	add.w	d2,d0
	movea.l	#dat_4D6AA,a0
	ext.w	d1
	add.w	d1,d1
	adda.w	d0,a0
	move.w	($0,a0,d1.w),d0
.l34916:
	add.w	d0,($2E,a2)
.l3491A:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_34924:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_34B9C
	tst.b	ram_FF9540
	beq.s	.l34962
	move.w	ram_FFDD16,d0
	addi.w	#$F0,d0
	cmp.w	($1E,a2),d0
	ble.s	.l3495E
	move.w	d0,($1E,a2)
.l3495E:
	bra.w	loc_34B90
.l34962:
	cmpi.w	#$2,($10,a2)
	bne.s	.l34984
	move.l	($C,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a0
	move.w	($1E,a0),($1E,a2)
	move.w	($20,a0),($20,a2)
	bra.s	.l3499A
.l34984:
	btst	#$5,($67,a2)
	bne.s	.l3499A
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_34D40
.l3499A:
	tst.b	($6A,a2)
	beq.s	.l349AC
	move.l	a2,-(sp)
	jsr	sub_34EC6
	bra.w	loc_34B90
.l349AC:
	move.w	($2E,a2),d3
	sub.w	($30,a2),d3
	tst.w	d3
	bne.s	.l349C2
	btst	#$1,($67,a2)
	beq.w	loc_34B90
.l349C2:
	btst	#$1,($67,a2)
	beq.w	.l34A44
	btst	#$5,($67,a2)
	bne.s	.l34A0A
	movea.l	ram_FFDBEE,a0
	move.l	(a0),d0
	movea.l	($1A,a2),a0
	movea.l	($4,a0),a0
	cmp.l	($4,a0),d0
	bne.s	.l34A0A
	ori.b	#$20,($67,a2)
	movea.l	($12,a2),a0
	andi.b	#$F9,($38,a0)
	ori.b	#$2,($38,a0)
	pea	$65.w
	jsr	queue_sound_command
.l34A0A:
	move.w	ram_FFDC1A,d4
	move.w	ram_FFDC1A,($2E,a2)
	btst	#$5,($67,a2)
	beq.s	.l34A42
	cmpi.w	#$190,($1E,a2)
	bls.s	.l34A42
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEDC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	sub.w	d0,($1E,a2)
.l34A42:
	bra.s	.l34A48
.l34A44:
	move.w	($2E,a2),d4
.l34A48:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	btst	#$7,($11,a0)
	beq.w	.l34ABA
	btst	#$1,($67,a2)
	beq.s	.l34A8C
	tst.w	d3
	blt.s	.l34A6C
	move.w	d3,d1
	ext.l	d1
	bra.s	.l34A72
.l34A6C:
	move.w	d3,d1
	ext.l	d1
	neg.l	d1
.l34A72:
	moveq	#$60,d0
	cmp.l	d1,d0
	bge.s	.l34A7C
	moveq	#$60,d0
	bra.s	.l34A8A
.l34A7C:
	tst.w	d3
	blt.s	.l34A84
	ext.l	d3
	bra.s	.l34A88
.l34A84:
	ext.l	d3
	neg.l	d3
.l34A88:
	move.l	d3,d0
.l34A8A:
	bra.s	.l34AB4
.l34A8C:
	tst.w	d3
	blt.s	.l34A96
	move.w	d3,d1
	ext.l	d1
	bra.s	.l34A9C
.l34A96:
	move.w	d3,d1
	ext.l	d1
	neg.l	d1
.l34A9C:
	moveq	#$30,d0
	cmp.l	d1,d0
	bge.s	.l34AA6
	moveq	#$30,d0
	bra.s	.l34AB4
.l34AA6:
	tst.w	d3
	blt.s	.l34AAE
	ext.l	d3
	bra.s	.l34AB2
.l34AAE:
	ext.l	d3
	neg.l	d3
.l34AB2:
	move.l	d3,d0
.l34AB4:
	move.w	d0,d1
	bra.w	.l34B38
.l34ABA:
	btst	#$1,($67,a2)
	bne.s	.l34ACC
	tst.w	d2
	beq.s	.l34AFC
	tst.b	($6A,a2)
	bne.s	.l34AFC
.l34ACC:
	tst.w	d3
	blt.s	.l34AD6
	move.w	d3,d0
	ext.l	d0
	bra.s	.l34ADC
.l34AD6:
	move.w	d3,d0
	ext.l	d0
	neg.l	d0
.l34ADC:
	cmpi.l	#$2D8,d0
	bls.s	.l34AEC
	move.l	#$2D8,d1
	bra.s	.l34AFA
.l34AEC:
	tst.w	d3
	blt.s	.l34AF4
	ext.l	d3
	bra.s	.l34AF8
.l34AF4:
	ext.l	d3
	neg.l	d3
.l34AF8:
	move.l	d3,d1
.l34AFA:
	bra.s	.l34B2A
.l34AFC:
	tst.w	d3
	blt.s	.l34B06
	move.w	d3,d0
	ext.l	d0
	bra.s	.l34B0C
.l34B06:
	move.w	d3,d0
	ext.l	d0
	neg.l	d0
.l34B0C:
	cmpi.l	#$16C,d0
	bls.s	.l34B1C
	move.l	#$16C,d1
	bra.s	.l34B2A
.l34B1C:
	tst.w	d3
	blt.s	.l34B24
	ext.l	d3
	bra.s	.l34B28
.l34B24:
	ext.l	d3
	neg.l	d3
.l34B28:
	move.l	d3,d1
.l34B2A:
	cmpi.w	#$1000,($76,a2)
	beq.s	.l34B38
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
.l34B38:
	move.w	($10,a2),d0
	cmpi.w	#$8,d0
	bcs.s	loc_34B5C
.l34B42:
	cmpi.w	#$B,d0
	bhi.s	loc_34B5C
	add.w	d0,d0
	move.w	(.l34B42,pc,d0.w),d0
	jmp	(.l34B52,pc,d0.w)
.l34B52:
	dc.w	sub_34B5A-.l34B52
	dc.w	sub_34B5A-.l34B52
	dc.w	sub_34B5A-.l34B52
	dc.w	sub_34B5A-.l34B52
sub_34B5A:
	bra.s	loc_34B90
loc_34B5C:
	cmp.w	($30,a2),d4
	ble.s	.l34B7A
	move.w	d1,d0
	add.w	d0,($30,a2)
	move.w	($2E,a2),d0
	cmp.w	($30,a2),d0
	bge.s	.l34B78
	move.w	($2E,a2),($30,a2)
.l34B78:
	bra.s	loc_34B90
.l34B7A:
	move.w	d1,d0
	sub.w	d0,($30,a2)
	move.w	($2E,a2),d0
	cmp.w	($30,a2),d0
	ble.s	loc_34B90
	move.w	($2E,a2),($30,a2)
loc_34B90:
	move.l	a2,d0
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_34B9C:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a1
	move.w	($E,a6),d3
	movea.l	#dat_4AF22,a2
	tst.w	d3
	beq.w	.l34D36
	tst.b	($6A,a1)
	bne.w	.l34D36
	cmpi.w	#$320,($1E,a1)
	bls.s	.l34BEA
	move.w	($1E,a1),d1
	ext.l	d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d2
	movea.l	#dat_4EEA4,a0
	moveq	#$0,d0
	move.b	($0,a0,d2.l),d0
	divs.w	d0,d1
	sub.w	d1,($1E,a1)
.l34BEA:
	moveq	#$0,d1
	move.w	($30,a1),d1
	andi.l	#$8000,d1
	beq.w	.l34C9A
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	add.l	d0,d0
	movea.l	#dat_4EEAC,a0
	move.w	($0,a0,d0.l),d0
	add.w	d0,($2E,a1)
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($2,a2,d1.l),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($0,a2,d0.l),d2
	cmp.l	d2,d1
	bcc.s	.l34C64
	moveq	#$0,d0
	move.w	($2E,a1),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($0,a2,d0.l),d2
	move.l	d2,d0
	cmp.l	d0,d1
	bls.s	.l34C62
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($0,a2,d1.l),d0
	move.l	d0,d1
	addi.l	#$16C,d1
	move.w	d1,($2E,a1)
.l34C62:
	bra.s	.l34C96
.l34C64:
	moveq	#$0,d0
	move.w	($2E,a1),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($2,a2,d0.l),d2
	move.l	d2,d0
	cmp.l	d0,d1
	bls.s	.l34C96
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($2,a2,d1.l),d0
	move.l	d0,d1
	addi.l	#$16C,d1
	move.w	d1,($2E,a1)
.l34C96:
	bra.w	.l34D36
.l34C9A:
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	add.l	d0,d0
	movea.l	#dat_4EEAC,a0
	move.w	($0,a0,d0.l),d0
	sub.w	d0,($2E,a1)
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($2,a2,d1.l),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($0,a2,d0.l),d2
	cmp.l	d2,d1
	bcc.s	.l34D04
	moveq	#$0,d0
	move.w	($2E,a1),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($2,a2,d0.l),d2
	move.l	d2,d0
	cmp.l	d0,d1
	bcc.s	.l34D02
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($2,a2,d1.l),d0
	move.l	d0,d1
	addi.l	#$16C,d1
	move.w	d1,($2E,a1)
.l34D02:
	bra.s	.l34D36
.l34D04:
	moveq	#$0,d0
	move.w	($2E,a1),d0
	move.l	d0,d1
	move.w	d3,d0
	ext.l	d0
	asl.l	#2,d0
	moveq	#$0,d2
	move.w	($0,a2,d0.l),d2
	move.l	d2,d0
	cmp.l	d0,d1
	bcc.s	.l34D36
	move.w	d3,d1
	ext.l	d1
	asl.l	#2,d1
	moveq	#$0,d0
	move.w	($0,a2,d1.l),d0
	move.l	d0,d1
	addi.l	#$16C,d1
	move.w	d1,($2E,a1)
.l34D36:
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_34D40:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a0
	move.w	($E,a6),d0
	movea.l	#ram_FFDD16,a2
	cmpi.b	#$1,($68,a0)
	bne.w	.l34E1C
	tst.w	d0
	beq.s	.l34D6C
	tst.b	($6A,a0)
	beq.w	.l34E1C
.l34D6C:
	btst	#$3,($67,a0)
	beq.s	.l34D8E
	cmpi.w	#$320,(a2)
	bcc.s	.l34D80
	move.w	(a2),($1E,a0)
	bra.s	.l34D8A
.l34D80:
	move.w	(a2),d0
	ext.l	d0
	asr.l	#3,d0
	move.w	d0,($1E,a0)
.l34D8A:
	bra.w	.l34E18
.l34D8E:
	cmpi.w	#$320,(a2)
	bcc.s	.l34D9E
	move.w	#$320,($1E,a0)
	bra.w	.l34E18
.l34D9E:
	move.w	(a2),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a1
	moveq	#$0,d0
	move.w	($0,a1,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d2
	move.b	($0,a1,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l34E0E
	move.w	(a2),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a1
	moveq	#$0,d0
	move.w	($0,a1,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d1
	move.b	($0,a1,d0.l),d1
	sub.l	d1,d2
	bra.s	.l34E14
.l34E0E:
	move.l	#$7D0,d2
.l34E14:
	move.w	d2,($1E,a0)
.l34E18:
	bra.w	.l34EBC
.l34E1C:
	tst.w	d0
	beq.s	.l34E28
	tst.b	($6A,a0)
	beq.w	.l34EBC
.l34E28:
	btst	#$2,($67,a0)
	bne.w	.l34EBC
	cmpi.w	#$320,(a2)
	bcc.s	.l34E42
	move.w	#$320,($1E,a0)
	bra.w	.l34EBC
.l34E42:
	move.w	(a2),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a1
	moveq	#$0,d0
	move.w	($0,a1,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d2
	move.b	($0,a1,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l34EB2
	move.w	(a2),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a1
	moveq	#$0,d0
	move.w	($0,a1,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d1
	move.b	($0,a1,d0.l),d1
	sub.l	d1,d2
	bra.s	.l34EB8
.l34EB2:
	move.l	#$7D0,d2
.l34EB8:
	move.w	d2,($1E,a0)
.l34EBC:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_34EC6:
	link	a6,#$0
	movea.l	($8,a6),a0
	tst.w	($74,a0)
	beq.s	.l34EE8
	cmpi.w	#$12,($74,a0)
	bls.s	.l34EE4
	subi.w	#$12,($74,a0)
	bra.s	.l34EE8
.l34EE4:
	clr.w	($74,a0)
.l34EE8:
	moveq	#$20,d0
	sub.l	d0,($6E,a0)
	move.w	($70,a0),d0
	add.w	d0,($72,a0)
	tst.w	($72,a0)
	bgt.s	.l34F10
	clr.b	($6A,a0)
	clr.w	d0
	move.w	d0,($74,a0)
	move.w	d0,($72,a0)
	ext.l	d0
	move.l	d0,($6E,a0)
.l34F10:
	unlk	a6
	rts
sub_34F14:
	link	a6,#$FFF4
	movem.l	d2-d5/a2-a5,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a4
	movea.l	($10,a6),a3
	move.w	($22,a2),d0
	ext.l	d0
	move.w	($8,a3),d1
	ext.l	d1
	move.w	($6,a3),d2
	ext.l	d2
	sub.l	d2,d1
	cmp.l	d1,d0
	blt.w	.l3515A
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a1
	move.w	($10,a1),d3
	andi.w	#$80,d3
	movea.l	($1A,a2),a0
	move.l	($C,a0),d2
	pea	($52,a2)
	movea.l	d2,a5
	pea	($14,a5)
	jsr	sub_22DD6
	move.w	($8,a3),d0
	sub.w	d0,($22,a2)
	movea.l	($1A,a2),a0
	move.l	(a0),($1A,a2)
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a3
	move.l	#$FFDBEE,d1
	cmp.l	($1A,a2),d1
	addq.l	#8,sp
	beq.s	.l34F9E
	move.l	#$FFDBF6,d1
	cmp.l	($1A,a2),d1
	bne.w	.l3505E
.l34F9E:
	cmpi.w	#$2,($10,a2)
	bne.w	.l3504E
	tst.l	($16,a2)
	beq.w	.l3504E
	move.l	($C,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	cmpa.l	a2,a3
	addq.l	#4,sp
	beq.w	.l35042
	movea.l	d2,a4
	pea	($14,a4)
	movea.l	d2,a4
	move.l	($10,a4),-(sp)
	movea.l	d2,a4
	move.l	($C,a4),-(sp)
	movea.l	d2,a4
	move.l	($8,a4),-(sp)
	pea	$D.w
	jsr	sub_2EF4C
	move.l	d0,($16,a3)
	movea.l	($16,a3),a0
	pea	($14,a0)
	movea.l	($12,a3),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($16,a3),a0
	movea.l	($12,a3),a1
	move.l	($8,a1),($8,a0)
	movea.l	($16,a3),a0
	movea.l	($12,a3),a1
	move.l	($C,a1),($C,a0)
	movea.l	($16,a3),a0
	movea.l	($12,a3),a1
	move.l	($10,a1),($10,a0)
	movea.l	($16,a3),a0
	move.w	#$FCB0,($36,a0)
	movea.l	($16,a3),a0
	bset	#$6,($38,a0)
	lea	($1C,sp),sp
.l35042:
	move.l	($16,a2),-(sp)
	jsr	sub_2E872
	addq.l	#4,sp
.l3504E:
	move.l	a2,-(sp)
	jsr	sub_35502
	movea.l	d0,a2
	addq.l	#4,sp
	bra.w	.l3515A
.l3505E:
	move.l	($E,a3),d1
	andi.l	#$80,d1
	moveq	#$0,d0
	move.w	d3,d0
	eor.l	d0,d1
	beq.w	.l350D8
	pea	(-$C,a6)
	movea.l	($12,a2),a0
	pea	($8,a0)
	move.l	($C,a4),-(sp)
	jsr	sub_3C136
	tst.w	d3
	lea	($C,sp),sp
	beq.s	.l350B8
	move.l	(-$C,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	(-$8,a6),d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	sub_30DB0
	move.w	d0,($30,a2)
	move.w	($2E,a2),d0
	lsl.w	#5,d0
	move.w	d0,($2E,a2)
	addq.l	#8,sp
	bra.s	.l350D8
.l350B8:
	tst.w	($30,a2)
	bne.s	.l350C4
	tst.w	($2E,a2)
	beq.s	.l350D8
.l350C4:
	move.l	(-$C,a6),d0
	neg.l	d0
	move.w	d0,($30,a2)
	move.w	($2E,a2),d0
	lsr.w	#5,d0
	move.w	d0,($2E,a2)
.l350D8:
	move.b	($5,a3),d0
	ext.w	d0
	ext.l	d0
	move.b	($4,a3),d1
	ext.w	d1
	ext.l	d1
	or.l	d1,d0
	beq.w	.l3515A
	move.w	($1E,a2),d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d1
	and.l	d1,d0
	add.l	d0,d0
	movea.l	#dat_4B00E,a0
	move.w	($0,a0,d0.l),($24,a2)
	movea.l	($1A,a2),a0
	move.l	($C,a0),d2
	clr.w	d3
	movea.l	d2,a1
	lea	($14,a1),a0
	move.l	a0,d4
	lea	($52,a2),a0
	move.l	a0,d5
	lea	($40,a2),a0
.l35124:
	moveq	#$0,d2
	movea.l	d4,a1
	movea.l	d5,a3
	movea.l	a0,a4
.l3512C:
	move.w	(a1),d1
	ext.l	d1
	move.w	(a3),d0
	ext.l	d0
	sub.l	d0,d1
	move.l	d1,d0
	divs.w	($24,a2),d0
	move.w	d0,(a4)
	addq.l	#1,d2
	addq.l	#2,a4
	addq.l	#2,a3
	addq.l	#2,a1
	moveq	#$3,d0
	cmp.l	d2,d0
	bgt.s	.l3512C
	addq.w	#1,d3
	addq.l	#6,a0
	addq.l	#6,d5
	addq.l	#6,d4
	cmpi.w	#$3,d3
	blt.s	.l35124
.l3515A:
	move.l	a2,d0
	movem.l	(-$2C,a6),d2-d5/a2-a5
	unlk	a6
	rts
sub_35166:
	link	a6,#$0
	movea.l	($8,a6),a0
	move.l	($C,a6),d1
	move.w	($12,a6),d0
	tst.w	d0
	beq.s	.l351B2
	tst.b	ram_FF9540
	beq.s	.l351B0
	cmp.l	ram_FFDBEE,d1
	beq.s	.l351A2
	movea.l	ram_FFDBEE,a1
	cmp.l	(a1),d1
	bne.s	.l351AA
	move.w	($22,a0),d0
	ext.l	d0
	cmp.l	ram_FFDBFE,d0
	bge.s	.l351AA
.l351A2:
	subi.w	#$28,($1E,a0)
	bra.s	.l351B0
.l351AA:
	addi.w	#$28,($1E,a0)
.l351B0:
	bra.s	.l351CC
.l351B2:
	tst.w	($1E,a0)
	beq.s	.l351CC
	move.w	($1E,a0),d0
	ext.l	d0
	asr.l	#3,d0
	move.l	d0,d0
	beq.s	.l351C6
	bra.s	.l351C8
.l351C6:
	moveq	#$1,d0
.l351C8:
	move.w	d0,($1E,a0)
.l351CC:
	unlk	a6
	rts
sub_351D0:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	($8,a6),a0
	tst.w	($24,a0)
	beq.s	.l35226
	subq.w	#1,($24,a0)
	moveq	#$0,d3
	lea	($52,a0),a4
	lea	($40,a0),a1
.l351F0:
	moveq	#$3,d0
	moveq	#$0,d2
	movea.l	a4,a2
	movea.l	a1,a3
.l351F8:
	move.w	(a3),d1
	add.w	d1,(a2)
	addq.l	#1,d2
	addq.l	#2,a3
	addq.l	#2,a2
	cmp.l	d0,d2
	blt.s	.l351F8
	addq.l	#1,d3
	addq.l	#6,a1
	addq.l	#6,a4
	moveq	#$3,d0
	cmp.l	d3,d0
	bgt.s	.l351F0
	movea.l	($12,a0),a1
	pea	($14,a1)
	pea	($52,a0)
	jsr	sub_22DD6
	addq.l	#8,sp
.l35226:
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_35230:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	movea.l	#sub_2D110,a4
	btst	#$1,($11,a3)
	beq.s	.l35260
	move.w	($22,a2),d0
	ext.l	d0
	divs.w	($C,a3),d0
	move.w	d0,d2
	add.w	($A,a3),d2
	bra.s	.l35264
.l35260:
	move.w	($A,a3),d2
.l35264:
	btst	#$7,($11,a3)
	bne.w	.l353AE
	move.w	#$AAA,d0
	sub.w	($30,a2),d0
	cmpi.w	#$1555,d0
	bls.w	.l352EC
	movea.l	($12,a2),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	($30,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($30,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	btst	#$5,($11,a3)
	beq.s	.l352EA
	cmpi.w	#$8000,($30,a2)
	bcs.s	.l352EA
	movea.l	ram_FFDBF6,a1
	movea.l	($C,a1),a0
	btst	#$5,($38,a0)
	beq.s	.l352D8
	move.l	a1,($1A,a2)
	bra.s	.l352E2
.l352D8:
	movea.l	ram_FFDBEE,a0
	move.l	(a0),($1A,a2)
.l352E2:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a3
.l352EA:
	bra.s	.l35340
.l352EC:
	moveq	#$0,d0
	move.w	d2,d0
	divu.w	#$14,d0
	sub.w	d0,d2
	moveq	#$0,d0
	move.w	($30,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.l	d0,d3
	moveq	#$0,d0
	move.w	($A,a3),d0
	move.l	d3,d1
	move.l	d1,d2
	mulu.w	d0,d3
	swap	d1
	mulu.w	d0,d1
	swap	d0
	mulu.w	d0,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d3
	moveq	#$E,d0
	asr.l	d0,d3
	move.l	d3,d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D172
	move.l	d3,-(sp)
	move.l	a2,-(sp)
	jsr	sub_35460
.l35340:
	tst.b	($6A,a2)
	beq.s	.l35356
	move.w	($72,a2),d1
	ext.l	d1
	moveq	#$0,d0
	move.w	($A,a3),d0
	sub.l	d0,d1
	bra.s	.l35368
.l35356:
	cmpi.w	#$B,($10,a2)
	beq.s	.l35370
	moveq	#$0,d0
	move.w	($A,a3),d0
	move.l	d0,d1
	neg.l	d1
.l35368:
	move.l	d1,-(sp)
	move.l	($12,a2),-(sp)
	jsr	(a4)
.l35370:
	btst	#$1,($11,a3)
	beq.s	.l353AA
	movea.l	($12,a2),a0
	pea	($14,a0)
	move.w	($2,a3),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	($2,a3),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
.l353AA:
	bra.w	.l35456
.l353AE:
	cmpi.w	#$8000,($30,a2)
	bcs.s	.l353D4
	move.w	($30,a2),d1
	ext.l	d1
	moveq	#$0,d0
	move.w	d2,d0
	neg.l	d0
	cmp.l	d0,d1
	bcc.s	.l353D2
	moveq	#$0,d0
	move.w	d2,d0
	move.l	d0,d1
	neg.l	d1
	move.w	d1,($30,a2)
.l353D2:
	bra.s	.l353EA
.l353D4:
	cmp.w	($30,a2),d2
	bcs.s	.l353E2
	moveq	#$0,d1
	move.w	($30,a2),d1
	bra.s	.l353E6
.l353E2:
	moveq	#$0,d1
	move.w	d2,d1
.l353E6:
	move.w	d1,($30,a2)
.l353EA:
	tst.b	($6A,a2)
	beq.s	.l35406
	move.w	($72,a2),d0
	ext.l	d0
	subi.l	#$5F0,d0
.l353FC:
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	(a4)
	bra.s	.l35442
.l35406:
	tst.b	($6B,a2)
	beq.s	.l35428
	move.w	($6C,a2),d0
	ext.l	d0
	divs.w	#$7,d0
	ext.l	d0
	move.w	($72,a2),d1
	ext.l	d1
	subi.l	#$5F0,d1
	add.l	d1,d0
	bra.s	.l353FC
.l35428:
	cmpi.w	#$B,($10,a2)
	bne.s	.l35436
	pea	$A00.w
	bra.s	.l3543C
.l35436:
	move.l	#$FFFFFA10,-(sp)
.l3543C:
	move.l	($12,a2),-(sp)
	jsr	(a4)
.l35442:
	move.w	($30,a2),d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D172
.l35456:
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_35460:
	link	a6,#$FFF4
	movem.l	d2/a2-a3,-(sp)
	movea.l	($8,a6),a2
	move.l	($C,a6),d2
	movea.l	#ram_FFDBF6,a3
	move.l	#$FFDBF6,d0
	cmp.l	(a3),d0
	bne.s	.l35486
	moveq	#$0,d0
	bra.w	.l354F8
.l35486:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	btst	#$5,($11,a0)
	beq.w	.l354F8
	pea	(-$C,a6)
	movea.l	(a3),a0
	movea.l	($C,a0),a0
	pea	($8,a0)
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	tst.l	(-$C,a6)
	blt.s	.l354BC
	move.l	(-$C,a6),d0
	bra.s	.l354C2
.l354BC:
	move.l	(-$C,a6),d0
	neg.l	d0
.l354C2:
	tst.l	d2
	blt.s	.l354C8
	bra.s	.l354CA
.l354C8:
	neg.l	d2
.l354CA:
	cmp.l	d2,d0
	bge.s	.l354F8
	move.l	(a3),($1A,a2)
	move.w	($1E,a2),d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d1
	and.l	d1,d0
	add.l	d0,d0
	movea.l	#dat_4B00E,a0
	move.w	($0,a0,d0.l),($24,a2)
	moveq	#$0,d0
	move.w	($30,a2),d0
	neg.l	d0
	move.w	d0,($30,a2)
.l354F8:
	movem.l	(-$18,a6),d2/a2-a3
	unlk	a6
	rts
sub_35502:
	link	a6,#$0
	movem.l	d2-d4/a2-a5,-(sp)
	movea.l	($8,a6),a2
	movea.l	#sub_2E872,a4
	movea.l	(a2),a3
	move.w	($10,a2),d0
	cmpi.w	#$A,d0
	bhi.w	loc_35694
	add.w	d0,d0
	move.w	(.l3552C,pc,d0.w),d0
	jmp	(.l3552C,pc,d0.w)
.l3552C:
	dc.w	sub_35542-.l3552C
	dc.w	sub_355AA-.l3552C
	dc.w	sub_355AA-.l3552C
	dc.w	loc_35694-.l3552C
	dc.w	loc_35694-.l3552C
	dc.w	loc_35694-.l3552C
	dc.w	loc_35694-.l3552C
	dc.w	sub_3562E-.l3552C
	dc.w	sub_3562E-.l3552C
	dc.w	sub_3562E-.l3552C
	dc.w	sub_3562E-.l3552C
sub_35542:
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	addq.l	#4,sp
.l35550:
	cmpa.l	a2,a3
	beq.s	.l3558E
	pea	($8,a2)
	jsr	sub_2E7EE
	move.l	($12,a2),-(sp)
	jsr	(a4)
	tst.l	($16,a2)
	addq.l	#8,sp
	beq.s	.l35574
	move.l	($16,a2),-(sp)
	jsr	(a4)
	addq.l	#4,sp
.l35574:
	move.l	a2,-(sp)
	jsr	sub_2E992
	movea.l	a3,a2
	move.l	($8,a3),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	addq.l	#8,sp
	bra.s	.l35550
.l3558E:
	movea.l	(a2),a3
	move.l	($12,a2),-(sp)
	jsr	(a4)
	tst.l	($16,a2)
	addq.l	#4,sp
	beq.s	.l355A6
	move.l	($16,a2),-(sp)
	jsr	(a4)
	addq.l	#4,sp
.l355A6:
	bra.w	loc_356AC
sub_355AA:
	moveq	#$2,d2
.l355AC:
	moveq	#$0,d0
	move.w	($10,a2),d0
	cmp.l	d2,d0
	bne.s	.l355C6
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a2
	addq.l	#4,sp
	bra.s	.l355AC
.l355C6:
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	addq.l	#4,sp
.l355D4:
	cmpa.l	a2,a3
	beq.s	.l35612
	pea	($8,a2)
	jsr	sub_2E7EE
	move.l	($12,a2),-(sp)
	jsr	(a4)
	tst.l	($16,a2)
	addq.l	#8,sp
	beq.s	.l355F8
	move.l	($16,a2),-(sp)
	jsr	(a4)
	addq.l	#4,sp
.l355F8:
	move.l	a2,-(sp)
	jsr	sub_2E992
	movea.l	a3,a2
	move.l	($8,a3),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	addq.l	#8,sp
	bra.s	.l355D4
.l35612:
	movea.l	(a2),a3
	move.l	($12,a2),-(sp)
	jsr	(a4)
	tst.l	($16,a2)
	addq.l	#4,sp
	beq.s	.l3562A
	move.l	($16,a2),-(sp)
	jsr	(a4)
	addq.l	#4,sp
.l3562A:
	bra.w	loc_356AC
sub_3562E:
	move.l	a2,d2
	movea.l	d2,a1
	move.l	($8,a1),d3
	movea.l	d2,a1
	lea	($8,a1),a3
	bra.s	.l35656
.l3563E:
	movea.l	d3,a5
	move.l	(a5),d4
	movea.l	d3,a5
	move.l	($8,a5),-(sp)
	jsr	(a4)
	move.l	d3,-(sp)
	jsr	sub_2EA08
	addq.l	#8,sp
	move.l	d4,d3
.l35656:
	cmp.l	a3,d3
	bne.s	.l3563E
	movea.l	d2,a0
	tst.l	($28,a0)
	beq.s	.l3566C
	movea.l	d2,a3
	move.l	($28,a3),-(sp)
	jsr	(a4)
	addq.l	#4,sp
.l3566C:
	move.w	($10,a2),d0
	cmpi.w	#$8,d0
	bcs.s	loc_35694
	bhi.s	.l3567A
	bra.s	.l35686
.l3567A:
	cmpi.w	#$9,d0
	bne.s	loc_35694
	pea	$27.w
	bra.s	.l3568A
.l35686:
	pea	$29.w
.l3568A:
	jsr	queue_sound_command
	addq.l	#4,sp
	nop
loc_35694:
	movea.l	(a2),a3
	move.l	($12,a2),-(sp)
	jsr	(a4)
	tst.l	($16,a2)
	addq.l	#4,sp
	beq.s	loc_356AC
	move.l	($16,a2),-(sp)
	jsr	(a4)
	addq.l	#4,sp
loc_356AC:
	move.l	a2,-(sp)
	jsr	sub_2E992
	addq.l	#4,sp
	move.b	#$1,ram_FFDC1C
	move.l	a3,d0
	movem.l	(-$1C,a6),d2-d4/a2-a5
	unlk	a6
	rts
sub_356CA:
	link	a6,#$FFF4
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.b	($F,a6),d2
	move.l	a2,-(sp)
	jsr	sub_3D348
	move.w	($10,a2),d1
	movea.l	#dat_4D764,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	move.l	d0,-(sp)
	jsr	queue_sound_command
	tst.b	d2
	beq.s	.l3570E
	moveq	#$0,d0
	move.w	($64,a2),d0
	add.l	d0,ram_FF9532
	clr.w	($3E,a2)
.l3570E:
	movem.l	(-$14,a6),d2/a2
	unlk	a6
	rts
sub_35718:
	link	a6,#$FFE8
	movem.l	d2-d5/a2-a5,-(sp)
	clr.b	d4
	move.l	#$FFDAF8,d3
	move.l	#$FFDB04,d2
	movea.l	#ram_FF9564,a2
	movea.l	#ram_FFDC8A,a3
	movea.l	#ram_FFDCB6,a4
	bra.w	.l357C4
.l35744:
	moveq	#$0,d0
	move.b	d4,d0
	asl.w	#2,d0
	move.l	($0,a3,d0.w),d5
	movea.l	d5,a1
	tst.l	($12,a1)
	beq.w	.l357C0
	pea	(-$4,a6)
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	movea.l	d5,a5
	movea.l	($12,a5),a0
	pea	($8,a0)
	jsr	sub_2C8FE
	tst.l	d0
	lea	($10,sp),sp
	beq.s	.l357C0
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($64,a5),d0
	move.l	d0,-(sp)
	pea	dat_4D68C
	pea	(-$18,a6)
	jsr	sub_30220
	pea	$1.w
	move.l	(a2),d1
	moveq	#$7,d0
	and.l	d0,d1
	moveq	#$C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$4,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(-$18,a6)
	jsr	sub_2F2CC
	lea	($20,sp),sp
.l357C0:
	addq.b	#1,d4
	addq.b	#1,d4
.l357C4:
	cmp.b	(a4),d4
	bcs.w	.l35744
	tst.b	ram_FFDD10
	beq.w	.l35840
	pea	(-$4,a6)
	pea	ram_FFDB04
	pea	ram_FFDAF8
	pea	ram_FF9C88
	jsr	sub_2C8FE
	tst.l	d0
	lea	($10,sp),sp
	beq.s	.l35840
	move.l	ram_FFDD0C,-(sp)
	pea	dat_4D690
	pea	(-$18,a6)
	jsr	sub_30220
	pea	$1.w
	move.l	ram_FF9564,d1
	moveq	#$7,d0
	and.l	d0,d1
	moveq	#$C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$4,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(-$18,a6)
	jsr	sub_2F2CC
	lea	($20,sp),sp
.l35840:
	movem.l	(-$38,a6),d2-d5/a2-a5
	unlk	a6
	rts
sub_3584A:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a2
	move.l	#$FFDCB8,d4
	clr.b	d5
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	move.b	($11,a0),d6
	andi.b	#$80,d6
	movea.l	($1A,a2),a0
	moveq	#$0,d0
	move.w	($18,a0),d0
	andi.l	#$4000,d0
	beq.s	.l35898
	movea.l	($1A,a2),a0
	moveq	#$0,d0
	move.w	($18,a0),d0
	andi.l	#$3FFF,d0
	moveq	#$9,d1
	asr.l	d1,d0
	clr.w	d0
	bra.s	.l358A0
.l35898:
	movea.l	($1A,a2),a0
	move.w	($18,a0),d0
.l358A0:
	tst.b	($6A,a2)
	bne.w	.l359DC
	tst.w	d0
	beq.w	.l359DC
	moveq	#$1,d2
	moveq	#$7,d3
	moveq	#$0,d1
	move.w	d0,d1
	asl.l	#2,d1
	movea.l	#dat_4C712,a0
	move.l	($0,a0,d1.l),(-$4,a6)
	movea.l	#ram_FFDCBA,a3
	bra.w	.l359D2
.l358CE:
	movea.l	(-$4,a6),a0
	movea.l	(a0)+,a4
	move.l	a0,(-$4,a6)
	move.w	($10,a4),d0
	bcs.w	.l359D2
	bhi.s	.l358E6
	bra.w	.l359D2
.l358E6:
	subq.w	#3,d0
	bne.w	.l359D2
	move.b	d2,d5
	moveq	#$0,d0
	move.b	d6,d0
	move.l	d0,-(sp)
	move.l	a4,-(sp)
	move.l	a2,-(sp)
	jsr	sub_35A1C
	tst.l	d0
	lea	($C,sp),sp
	beq.w	.l35988
	tst.b	($6B,a2)
	beq.s	.l35938
	moveq	#$0,d0
	move.w	($A,a4),d0
	neg.l	d0
	movea.l	d4,a0
	cmp.w	(a0),d0
	ble.s	.l35922
	clr.w	($6C,a2)
	bra.s	.l35936
.l35922:
	moveq	#$0,d0
	move.w	($A,a4),d0
	move.l	d0,d1
	movea.l	d4,a0
	move.w	(a0),d0
	ext.l	d0
	add.l	d0,d1
	move.w	d1,($6C,a2)
.l35936:
	bra.s	.l35986
.l35938:
	movea.l	d4,a0
	tst.w	(a0)
	bge.s	.l35970
	move.b	d2,($6B,a2)
	movea.l	d4,a0
	move.w	(a0),d1
	ext.l	d1
	moveq	#$0,d0
	move.w	($A,a4),d0
	neg.l	d0
	cmp.l	d0,d1
	bcc.s	.l3595A
	clr.w	($6C,a2)
	bra.s	.l3596E
.l3595A:
	moveq	#$0,d0
	move.w	($A,a4),d0
	move.l	d0,d1
	movea.l	d4,a0
	move.w	(a0),d0
	ext.l	d0
	add.l	d0,d1
	move.w	d1,($6C,a2)
.l3596E:
	bra.s	.l35986
.l35970:
	tst.w	(a3)
	bge.s	.l3597C
	move.l	#$FFFFFA00,d0
	bra.s	.l35982
.l3597C:
	move.l	#$600,d0
.l35982:
	add.w	d0,($20,a2)
.l35986:
	bra.s	.l359CE
.l35988:
	tst.b	($6B,a2)
	beq.s	.l359CE
	move.b	d2,($6A,a2)
	clr.b	($6B,a2)
	move.l	d3,d1
	move.w	($1E,a2),d0
	ext.l	d0
	jsr	sub_23E70
	move.l	d0,($6E,a2)
	moveq	#$0,d0
	move.w	($A,a4),d0
	movea.l	d4,a5
	move.w	(a5),d1
	ext.l	d1
	add.l	d1,d0
	move.l	d3,d1
	jsr	sub_23E62
	move.l	d0,d1
	move.w	d1,($72,a2)
	move.w	#$666,($74,a2)
	clr.w	($6C,a2)
.l359CE:
	bra.w	.l359D2
.l359D2:
	movea.l	(-$4,a6),a0
	tst.l	(a0)
	bne.w	.l358CE
.l359DC:
	tst.b	($6B,a2)
	beq.s	.l35A10
	tst.b	d5
	bne.s	.l35A10
	move.b	#$1,($6A,a2)
	clr.b	($6B,a2)
	move.w	($1E,a2),d0
	ext.l	d0
	divs.w	#$7,d0
	ext.l	d0
	move.l	d0,($6E,a2)
	move.w	#$1C0,($72,a2)
	move.w	#$666,($74,a2)
	clr.w	($6C,a2)
.l35A10:
	move.l	a2,d0
	movem.l	(-$28,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_35A1C:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a0
	move.b	($13,a6),d0
	movea.l	#ram_FFDCB8,a2
	move.w	($28,a1),d4
	move.w	($A,a0),d1
	subi.w	#$3B3,d1
	add.w	d1,d4
	tst.b	d0
	beq.s	.l35A5C
	moveq	#$0,d1
	move.w	($2A,a1),d1
	moveq	#$0,d0
	move.w	($E,a0),d0
	subi.l	#$3B3,d0
	bra.s	.l35A6E
.l35A5C:
	moveq	#$0,d1
	move.w	($36,a1),d1
	moveq	#$0,d0
	move.w	($C,a0),d0
	subi.l	#$766,d0
.l35A6E:
	add.l	d0,d1
	move.w	d1,d5
	move.w	($22,a1),d1
	ext.l	d1
	move.w	($2,a0),d0
	ext.l	d0
	sub.l	d0,d1
	move.w	d1,(a2)
	moveq	#$0,d0
	move.w	($30,a1),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.w	($6,a0),d0
	sub.l	d0,d1
	move.w	d1,ram_FFDCBA
	moveq	#$0,d3
	tst.w	(a2)
	blt.s	.l35AA4
	move.w	(a2),d2
	ext.l	d2
	bra.s	.l35AAA
.l35AA4:
	move.w	(a2),d2
	ext.l	d2
	neg.l	d2
.l35AAA:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	cmp.l	d2,d1
	bls.s	.l35ADC
	tst.w	ram_FFDCBA
	blt.s	.l35AC6
	move.w	ram_FFDCBA,d2
	ext.l	d2
	bra.s	.l35AD0
.l35AC6:
	move.w	ram_FFDCBA,d2
	ext.l	d2
	neg.l	d2
.l35AD0:
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	cmp.l	d2,d1
	bls.s	.l35ADC
	moveq	#$1,d3
.l35ADC:
	move.l	d3,d0
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
dat_35AE8:
	incbin	"../../build/stunrun-68k.bin",$35AE8,$1BA
sub_35CA2:
	link	a6,#$0
	movem.l	d2,-(sp)
	clr.b	ram_FFDCB6
	move.l	$FFFF8014,d1
	sub.l	ram_FFDCC0,d1
	moveq	#$78,d0
	cmp.l	d1,d0
	bgt.s	.l35CD6
	move.b	#$1,ram_FFDCC4
	move.l	$FFFF8014,ram_FFDCC0
	bra.s	.l35CDC
.l35CD6:
	clr.b	ram_FFDCC4
.l35CDC:
	movea.l	ram_FFDAAE,a0
	move.l	#$FFDAAE,d2
	bra.w	loc_35D98
loc_35CEC:
	move.w	($10,a0),d0
	cmpi.w	#$B,d0
	bhi.w	loc_35D96
	add.w	d0,d0
	move.w	(.l35D02,pc,d0.w),d0
	jmp	(.l35D02,pc,d0.w)
.l35D02:
	dc.w	sub_35D1A-.l35D02
	dc.w	sub_35D26-.l35D02
	dc.w	sub_35D30-.l35D02
	dc.w	sub_35D3A-.l35D02
	dc.w	sub_35D58-.l35D02
	dc.w	sub_35D44-.l35D02
	dc.w	sub_35D4E-.l35D02
	dc.w	sub_35D62-.l35D02
	dc.w	sub_35D6C-.l35D02
	dc.w	sub_35D76-.l35D02
	dc.w	sub_35D80-.l35D02
	dc.w	sub_35D8A-.l35D02
sub_35D1A:
	move.l	a0,-(sp)
	jsr	sub_35DA8
	bra.w	loc_35D92
sub_35D26:
	move.l	a0,-(sp)
	jsr	sub_35E8C
	bra.s	loc_35D92
sub_35D30:
	move.l	a0,-(sp)
	jsr	sub_35F66
	bra.s	loc_35D92
sub_35D3A:
	move.l	a0,-(sp)
	jsr	sub_360F8
	bra.s	loc_35D92
sub_35D44:
	move.l	a0,-(sp)
	jsr	sub_361D4
	bra.s	loc_35D92
sub_35D4E:
	move.l	a0,-(sp)
	jsr	sub_36278
	bra.s	loc_35D92
sub_35D58:
	move.l	a0,-(sp)
	jsr	sub_3634E
	bra.s	loc_35D92
sub_35D62:
	move.l	a0,-(sp)
	jsr	sub_3646E
	bra.s	loc_35D92
sub_35D6C:
	move.l	a0,-(sp)
	jsr	sub_36E12
	bra.s	loc_35D92
sub_35D76:
	move.l	a0,-(sp)
	jsr	sub_37714
	bra.s	loc_35D92
sub_35D80:
	move.l	a0,-(sp)
	jsr	sub_37C52
	bra.s	loc_35D92
sub_35D8A:
	move.l	a0,-(sp)
	jsr	sub_3848E
loc_35D92:
	movea.l	d0,a1
	addq.l	#4,sp
loc_35D96:
	movea.l	a1,a0
loc_35D98:
	cmpa.l	d2,a0
	bne.w	loc_35CEC
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_35DA8:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	clr.b	d2
	move.l	(a2),d3
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l35E6E
	tst.b	($66,a2)
	bne.s	.l35E22
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a0
	cmpa.l	a2,a0
	beq.s	.l35DE8
	clr.w	($10,a0)
.l35DE8:
	pea	($8,a2)
	jsr	sub_2E7EE
	lea	($8,a2),a0
	move.l	a0,d0
	move.l	d0,($C,a2)
	move.l	d0,($8,a2)
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l35E1A
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l35E1A:
	move.b	#$7,($66,a2)
	bra.s	.l35E6E
.l35E22:
	cmpi.b	#$1,($66,a2)
	bne.s	.l35E50
	move.l	($12,a2),-(sp)
	jsr	sub_2E872
	tst.l	($16,a2)
	beq.s	.l35E44
	move.l	($16,a2),-(sp)
	jsr	sub_2E872
.l35E44:
	move.l	a2,-(sp)
	jsr	sub_2E992
	moveq	#$1,d2
	bra.s	.l35E6E
.l35E50:
	subq.b	#1,($66,a2)
	moveq	#$0,d0
	move.b	ram_FFDCB6,d0
	asl.l	#2,d0
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d0.l)
	addq.b	#1,ram_FFDCB6
.l35E6E:
	tst.b	d2
	bne.s	.l35E80
	clr.l	-(sp)
	clr.l	-(sp)
	move.l	a2,-(sp)
	jsr	sub_34372
	move.l	d0,d3
.l35E80:
	move.l	d3,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_35E8C:
	link	a6,#$0
	movem.l	a2-a3,-(sp)
	movea.l	($8,a6),a2
	move.l	(a2),d0
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l35F1A
	tst.b	($66,a2)
	bne.w	.l35F1A
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a0
	cmpa.l	a0,a2
	beq.s	.l35EF6
	move.l	($8,a2),-(sp)
	jsr	sub_22E16
	movea.l	d0,a3
	pea	($8,a2)
	jsr	sub_2E7EE
	lea	($8,a2),a0
	move.l	a0,($C,a2)
	move.l	a0,($8,a2)
	cmpi.w	#$2,($10,a3)
	bne.s	.l35EF6
	clr.w	($10,a3)
.l35EF6:
	clr.w	($10,a2)
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l35F14
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l35F14:
	move.b	#$7,($66,a2)
.l35F1A:
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	bne.s	.l35F4C
	moveq	#$0,d1
	move.b	($67,a2),d1
	moveq	#-$D,d0
	and.l	d0,d1
	moveq	#$10,d0
	or.l	d0,d1
	move.b	d1,($67,a2)
.l35F4C:
	pea	$640.w
	pea	$4A0.w
	move.l	a2,-(sp)
	jsr	sub_34372
	movem.l	(-$8,a6),a2-a3
	unlk	a6
	rts
sub_35F66:
	link	a6,#$0
	movem.l	d2-d3/a2-a5,-(sp)
	movea.l	($8,a6),a2
	move.l	#sub_22E16,d3
	movea.l	(a2),a1
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l360D6
	tst.b	($66,a2)
	bne.w	.l360D6
	moveq	#$2,d2
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	move.l	($C,a2),-(sp)
	movea.l	d3,a5
	jsr	(a5)
	movea.l	d0,a3
	move.l	($8,a2),-(sp)
	movea.l	d3,a5
	jsr	(a5)
	movea.l	d0,a4
	movea.l	a3,a1
	lea	($10,sp),sp
.l35FB4:
	moveq	#$0,d0
	move.w	($10,a1),d0
	cmp.l	d2,d0
	bne.s	.l35FCC
	move.l	($C,a1),-(sp)
	movea.l	d3,a5
	jsr	(a5)
	movea.l	d0,a1
	addq.l	#4,sp
	bra.s	.l35FB4
.l35FCC:
	cmpa.l	a4,a1
	beq.w	.l3604E
	move.l	($C,a1),($C,a4)
	lea	($8,a3),a0
	move.l	a0,($C,a1)
	lea	($8,a1),a0
	move.l	a0,($8,a3)
	move.l	($C,a4),-(sp)
	movea.l	d3,a5
	jsr	(a5)
	movea.l	d0,a1
	lea	($8,a4),a0
	move.l	a0,($8,a1)
	movea.l	($12,a3),a0
	pea	($14,a0)
	movea.l	($12,a3),a0
	move.l	($10,a0),-(sp)
	movea.l	($12,a3),a0
	move.l	($C,a0),-(sp)
	movea.l	($12,a3),a0
	move.l	($8,a0),-(sp)
	pea	$D.w
	jsr	sub_2EF4C
	move.l	d0,($16,a3)
	movea.l	($16,a3),a0
	move.w	#$FCB0,($36,a0)
	movea.l	($16,a3),a0
	bset	#$6,($38,a0)
	cmpi.w	#$1,($10,a4)
	lea	($18,sp),sp
	beq.s	.l3604C
	clr.w	($10,a4)
.l3604C:
	bra.s	.l3609E
.l3604E:
	movea.l	($12,a3),a0
	pea	($14,a0)
	movea.l	($12,a3),a0
	move.l	($10,a0),-(sp)
	movea.l	($12,a3),a0
	move.l	($C,a0),-(sp)
	movea.l	($12,a3),a0
	move.l	($8,a0),-(sp)
	pea	$D.w
	jsr	sub_2EF4C
	move.l	d0,($16,a3)
	movea.l	($16,a3),a0
	move.w	#$FCB0,($36,a0)
	movea.l	($16,a3),a0
	bset	#$6,($38,a0)
	pea	($8,a2)
	jsr	sub_2E7EE
	lea	($18,sp),sp
.l3609E:
	move.b	#$1,ram_FFDC1C
	lea	($8,a2),a1
	move.l	a1,($C,a2)
	move.l	a1,($8,a2)
	clr.w	($10,a2)
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l360D0
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l360D0:
	move.b	#$7,($66,a2)
.l360D6:
	pea	$640.w
	pea	$4A0.w
	move.l	a2,-(sp)
	jsr	sub_34372
	movea.l	d0,a1
	lea	($C,sp),sp
	move.l	a1,d0
	movem.l	(-$18,a6),d2-d3/a2-a5
	unlk	a6
	rts
sub_360F8:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	clr.b	d2
	move.l	(a2),d3
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l3617A
	tst.b	($66,a2)
	bne.s	.l36146
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l3613E
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l3613E:
	move.b	#$7,($66,a2)
	bra.s	.l3617A
.l36146:
	cmpi.b	#$1,($66,a2)
	bne.s	.l3615C
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	moveq	#$1,d2
	bra.s	.l3617A
.l3615C:
	subq.b	#1,($66,a2)
	moveq	#$0,d0
	move.b	ram_FFDCB6,d0
	asl.l	#2,d0
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d0.l)
	addq.b	#1,ram_FFDCB6
.l3617A:
	tst.b	d2
	bne.s	.l361C8
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	bne.s	.l361B6
	moveq	#$0,d1
	move.b	($67,a2),d1
	moveq	#-$D,d0
	and.l	d0,d1
	moveq	#$10,d0
	or.l	d0,d1
	move.b	d1,($67,a2)
	andi.w	#$7FFF,($76,a2)
.l361B6:
	pea	$7E0.w
	pea	$580.w
	move.l	a2,-(sp)
	jsr	sub_34372
	move.l	d0,d3
.l361C8:
	move.l	d3,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_361D4:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	clr.b	d2
	move.l	(a2),d3
	cmpi.w	#$64,($3C,a2)
	bcs.s	.l36210
	pea	$62.w
	jsr	queue_sound_command
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	moveq	#$1,d2
	bra.s	.l36224
.l36210:
	tst.w	($3C,a2)
	beq.s	.l36224
	pea	$62.w
	jsr	queue_sound_command
	clr.w	($3C,a2)
.l36224:
	tst.b	d2
	bne.s	.l3626C
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	bne.s	.l3625A
	moveq	#$0,d1
	move.b	($67,a2),d1
	moveq	#-$D,d0
	and.l	d0,d1
	moveq	#$10,d0
	or.l	d0,d1
	move.b	d1,($67,a2)
.l3625A:
	pea	$7E0.w
	pea	$580.w
	move.l	a2,-(sp)
	jsr	sub_34372
	move.l	d0,d3
.l3626C:
	move.l	d3,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_36278:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	clr.b	d2
	move.l	(a2),d3
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l362FA
	tst.b	($66,a2)
	bne.s	.l362C6
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l362BE
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l362BE:
	move.b	#$7,($66,a2)
	bra.s	.l362FA
.l362C6:
	cmpi.b	#$1,($66,a2)
	bne.s	.l362DC
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	moveq	#$1,d2
	bra.s	.l362FA
.l362DC:
	subq.b	#1,($66,a2)
	moveq	#$0,d0
	move.b	ram_FFDCB6,d0
	asl.l	#2,d0
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d0.l)
	addq.b	#1,ram_FFDCB6
.l362FA:
	tst.b	d2
	bne.s	.l36342
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	bne.s	.l36330
	moveq	#$0,d1
	move.b	($67,a2),d1
	moveq	#-$D,d0
	and.l	d0,d1
	moveq	#$10,d0
	or.l	d0,d1
	move.b	d1,($67,a2)
.l36330:
	pea	$640.w
	pea	$4A0.w
	move.l	a2,-(sp)
	jsr	sub_34372
	move.l	d0,d3
.l36342:
	move.l	d3,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3634E:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	clr.b	d2
	move.l	(a2),d3
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l363D0
	tst.b	($66,a2)
	bne.s	.l3639C
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	beq.s	.l36394
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l36394:
	move.b	#$7,($66,a2)
	bra.s	.l363D0
.l3639C:
	cmpi.b	#$1,($66,a2)
	bne.s	.l363B2
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	moveq	#$1,d2
	bra.s	.l363D0
.l363B2:
	subq.b	#1,($66,a2)
	moveq	#$0,d0
	move.b	ram_FFDCB6,d0
	asl.l	#2,d0
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d0.l)
	addq.b	#1,ram_FFDCB6
.l363D0:
	tst.b	d2
	bne.w	.l36462
	btst	#$1,($67,a2)
	bne.s	.l36412
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EED4,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	bne.s	.l36410
	moveq	#$0,d0
	move.b	($67,a2),d0
	moveq	#-$D,d1
	and.l	d1,d0
	moveq	#$2,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l36410:
	bra.s	.l36450
.l36412:
	movea.l	($1A,a2),a0
	moveq	#$0,d0
	move.w	($1A,a0),d0
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	move.l	d1,d2
	movea.l	#dat_4EED4,a0
	moveq	#$0,d1
	move.b	($0,a0,d2.l),d1
	addq.l	#2,d1
	cmp.l	d1,d0
	bne.s	.l36450
	andi.b	#$FD,($67,a2)
	moveq	#$0,d0
	move.b	($67,a2),d0
	moveq	#-$D,d1
	and.l	d1,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l36450:
	pea	$640.w
	pea	$4A0.w
	move.l	a2,-(sp)
	jsr	sub_34372
	move.l	d0,d3
.l36462:
	move.l	d3,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3646E:
	link	a6,#$FF30
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a2
	move.l	#$FFDD16,d4
	movea.l	($8,a2),a4
	bra.w	loc_366A6
loc_36488:
	moveq	#$0,d3
	move.l	(a4),d6
	movea.l	($8,a4),a3
	movea.l	($26,a3),a0
	move.w	($4,a0),d0
	move.w	d0,d5
	cmpi.w	#$94,d0
	blt.w	loc_36540
	cmpi.w	#$97,d0
	bgt.s	.l364BE
	sub.w	#$94,d0
	add.w	d0,d0
	move.w	(.l364B6,pc,d0.w),d0
	jmp	(.l364B6,pc,d0.w)
.l364B6:
	dc.w	sub_364FC-.l364B6
	dc.w	sub_364FC-.l364B6
	dc.w	sub_364FC-.l364B6
	dc.w	loc_36522-.l364B6
.l364BE:
	cmpi.w	#$A2,d0
	bne.s	.l364C6
	bra.s	.l364D0
.l364C6:
	cmpi.w	#$A3,d0
	bne.w	loc_36540
	bra.s	.l364F0
.l364D0:
	movea.l	($8,a4),a3
	pea	$A3.w
	jsr	object_descriptor
	move.l	d0,($26,a3)
	movea.l	($8,a4),a3
	bset	#$6,($38,a3)
	addq.l	#4,sp
	bra.s	loc_36540
.l364F0:
	tst.w	($16,a4)
	beq.s	.l364FA
	clr.w	($16,a4)
.l364FA:
	bra.s	loc_36540
sub_364FC:
	movea.l	($8,a4),a3
	move.w	d5,d0
	ext.l	d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a3)
	movea.l	($8,a4),a3
	bset	#$6,($38,a3)
	addq.l	#4,sp
loc_3651E:
	bra.w	loc_366A4
loc_36522:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA08
	move.b	#$1,ram_FFDC1C
	addq.l	#8,sp
	bra.s	loc_3651E
loc_36540:
	subq.w	#1,($12,a4)
	beq.w	.l36688
	movea.l	($8,a4),a0
	lea	(-$58,a6),a1
	moveq	#$3D,d0
.l36552:
	move.b	(a0)+,(a1)+
	dbf	d0,.l36552
	move.w	($10,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($8,a4),-(sp)
	jsr	sub_2D0AE
	movea.l	($8,a4),a3
	bset	#$6,($38,a3)
	move.l	($C,a4),d2
	pea	(-$E,a6)
	movea.l	($8,a4),a3
	pea	($8,a3)
	movea.l	d2,a5
	move.l	($C,a5),-(sp)
	jsr	sub_3C136
	tst.l	(-$6,a6)
	lea	($14,sp),sp
	blt.s	.l365A0
	move.l	(-$6,a6),d1
	bra.s	.l365A6
.l365A0:
	move.l	(-$6,a6),d1
	neg.l	d1
.l365A6:
	movea.l	($C,a4),a3
	movea.l	($8,a3),a0
	move.w	($6,a0),d0
	ext.l	d0
	cmp.l	d1,d0
	bge.s	.l365E8
	movea.l	($C,a4),a3
	move.l	($4,a3),d2
	cmp.l	#$FFDBEE,d2
	bne.s	.l365CC
	bra.w	loc_36522
.l365CC:
	pea	(-$E,a6)
	movea.l	($8,a4),a3
	pea	($8,a3)
	movea.l	d2,a5
	move.l	($C,a5),-(sp)
	jsr	sub_3C136
	lea	($C,sp),sp
.l365E8:
	movea.l	ram_FFDBEE,a3
	movea.l	(a3),a0
	tst.l	ram_FFDBFE
	bge.s	.l365FE
	movea.l	($4,a0),a1
	bra.s	.l36600
.l365FE:
	movea.l	(a0),a1
.l36600:
	cmpa.l	#$FFDBEE,a1
	bne.s	.l3660A
	movea.l	a0,a1
.l3660A:
	tst.w	ram_FFDD4E
	bne.w	.l36668
	cmp.l	a1,d2
	beq.s	.l36628
	cmp.l	a0,d2
	beq.s	.l36628
	cmpa.l	($C,a4),a1
	beq.s	.l36628
	cmpa.l	($C,a4),a0
	bne.s	.l36668
.l36628:
	pea	$F0.w
	pea	$640.w
	pea	(-$58,a6)
	move.l	a4,-(sp)
	pea	ram_FF9C80
	jsr	sub_3C1C8
	move.l	d0,d3
	tst.l	d3
	lea	($14,sp),sp
	beq.s	.l36668
	jsr	sub_3997A
	movea.l	($8,a4),a3
	pea	$94.w
	jsr	object_descriptor
	move.l	d0,($26,a3)
	addq.l	#4,sp
	bra.s	loc_366B0
.l36668:
	tst.l	d3
	bne.s	.l36686
	pea	(-$58,a6)
	pea	$94.w
	pea	(-$E,a6)
	move.l	d2,-(sp)
	move.l	a4,-(sp)
	jsr	sub_3C746
	lea	($14,sp),sp
.l36686:
	bra.s	loc_366A4
.l36688:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA08
	move.b	#$1,ram_FFDC1C
	addq.l	#8,sp
loc_366A4:
	movea.l	d6,a4
loc_366A6:
	lea	($8,a2),a3
	cmpa.l	a3,a4
	bne.w	loc_36488
loc_366B0:
	movea.l	($1A,a2),a0
	move.l	($8,a0),d5
	move.l	(a2),d6
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l36736
	tst.b	($66,a2)
	bne.s	.l366FE
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a3
	bset	#$5,($38,a3)
	movea.l	($16,a2),a3
	bset	#$5,($38,a3)
	movea.l	($28,a2),a3
	bset	#$5,($38,a3)
	move.b	#$7,($66,a2)
	addq.l	#8,sp
	bra.s	.l36732
.l366FE:
	cmpi.b	#$1,($66,a2)
	bne.s	.l36714
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d6
	addq.l	#4,sp
	bra.s	.l36732
.l36714:
	subq.b	#1,($66,a2)
	moveq	#$0,d1
	move.b	ram_FFDCB6,d1
	asl.l	#2,d1
	movea.l	#ram_FFDC8A,a3
	move.l	a2,($0,a3,d1.l)
	addq.b	#1,ram_FFDCB6
.l36732:
	bra.w	.l36E06
.l36736:
	tst.b	ram_FF9540
	beq.s	.l36770
	cmpa.l	ram_FFDBEE,a0
	beq.s	.l3675E
	movea.l	ram_FFDBEE,a3
	cmpa.l	(a3),a0
	bne.s	.l36766
	move.w	($22,a2),d0
	ext.l	d0
	cmp.l	ram_FFDBFE,d0
	bge.s	.l36766
.l3675E:
	subi.w	#$28,($1E,a2)
	bra.s	.l3676C
.l36766:
	addi.w	#$28,($1E,a2)
.l3676C:
	bra.w	.l3682A
.l36770:
	btst	#$3,($67,a2)
	beq.s	.l36798
	movea.l	d4,a0
	cmpi.w	#$320,(a0)
	bcc.s	.l36788
	movea.l	d4,a0
	move.w	(a0),($1E,a2)
	bra.s	.l36794
.l36788:
	movea.l	d4,a0
	move.w	(a0),d0
	ext.l	d0
	asr.l	#3,d0
	move.w	d0,($1E,a2)
.l36794:
	bra.w	.l3682A
.l36798:
	movea.l	d4,a0
	cmpi.w	#$320,(a0)
	bcc.s	.l367AA
	move.w	#$320,($1E,a2)
	bra.w	.l3682A
.l367AA:
	movea.l	d4,a1
	move.w	(a1),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a3
	moveq	#$0,d0
	move.w	($0,a3,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a0
	moveq	#$0,d2
	move.b	($0,a0,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l36820
	movea.l	d4,a1
	move.w	(a1),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a3
	moveq	#$0,d0
	move.w	($0,a3,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEE4,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	sub.l	d0,d2
	bra.s	.l36826
.l36820:
	move.l	#$7D0,d2
.l36826:
	move.w	d2,($1E,a2)
.l3682A:
	move.w	($1E,a2),d0
	add.w	d0,($22,a2)
	move.w	($22,a2),d0
	ext.l	d0
	movea.l	d5,a0
	move.w	($8,a0),d2
	ext.l	d2
	movea.l	d5,a0
	move.w	($6,a0),d3
	ext.l	d3
	sub.l	d3,d2
	cmp.l	d2,d0
	blt.w	.l36934
	movea.l	($1A,a2),a3
	movea.l	($C,a3),a4
	pea	($52,a2)
	pea	($14,a4)
	jsr	sub_22DD6
	movea.l	d5,a5
	move.w	($8,a5),d0
	sub.w	d0,($22,a2)
	movea.l	($1A,a2),a3
	move.l	(a3),($1A,a2)
	movea.l	($1A,a2),a3
	move.l	($8,a3),d5
	move.l	#$FFDBEE,d1
	cmp.l	($1A,a2),d1
	addq.l	#8,sp
	beq.s	.l3689A
	move.l	#$FFDBF6,d1
	cmp.l	($1A,a2),d1
	bne.s	.l368AA
.l3689A:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d6
	addq.l	#4,sp
	bra.w	.l36E06
.l368AA:
	movea.l	d5,a0
	move.b	($5,a0),d0
	ext.w	d0
	ext.l	d0
	movea.l	d5,a0
	move.b	($4,a0),d2
	ext.w	d2
	ext.l	d2
	or.l	d2,d0
	beq.w	.l36934
	moveq	#$3,d1
	move.w	($1E,a2),d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d2
	and.l	d2,d0
	add.l	d0,d0
	movea.l	#dat_4B00E,a3
	move.w	($0,a3,d0.l),($24,a2)
	movea.l	($1A,a2),a3
	movea.l	($C,a3),a4
	clr.w	d5
	lea	($14,a4),a3
	move.l	a3,d2
	lea	($52,a2),a3
	move.l	a3,d3
	lea	($40,a2),a3
.l368FA:
	clr.w	(-$2,a6)
	movea.l	d2,a0
	movea.l	d3,a1
	movea.l	a3,a4
.l36904:
	move.w	(a0),d0
	sub.w	(a1),d0
	ext.l	d0
	divs.w	($24,a2),d0
	move.w	d0,(a4)
	addq.w	#1,(-$2,a6)
	addq.l	#2,a4
	addq.l	#2,a1
	addq.l	#2,a0
	move.w	(-$2,a6),d0
	ext.l	d0
	cmp.l	d1,d0
	blt.s	.l36904
	addq.w	#1,d5
	addq.l	#6,a3
	addq.l	#6,d3
	addq.l	#6,d2
	move.w	d5,d0
	ext.l	d0
	cmp.l	d1,d0
	blt.s	.l368FA
.l36934:
	movea.l	($1A,a2),a3
	move.l	($8,a3),d5
	movea.l	($1A,a2),a3
	movea.l	($C,a3),a4
	movea.l	($12,a2),a3
	pea	($14,a3)
	pea	($14,a4)
	jsr	sub_22DD6
	movea.l	($12,a2),a3
	move.l	($8,a4),($8,a3)
	movea.l	($12,a2),a3
	move.l	($C,a4),($C,a3)
	movea.l	($12,a2),a3
	move.l	($10,a4),($10,a3)
	move.w	($22,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($12,a2),a3
	bset	#$6,($38,a3)
	move.l	a2,-(sp)
	jsr	sub_351D0
	move.l	$FFFF8014,d2
	asl.l	#8,d2
	move.l	d2,-(sp)
	jsr	sub_30C72
	ext.l	d0
	asl.l	#5,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D110
	movea.l	($16,a2),a3
	pea	($14,a3)
	movea.l	($12,a2),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	($16,a2),a3
	movea.l	($12,a2),a0
	move.l	($8,a0),($8,a3)
	movea.l	($16,a2),a3
	movea.l	($12,a2),a0
	move.l	($C,a0),($C,a3)
	movea.l	($16,a2),a3
	movea.l	($12,a2),a0
	move.l	($10,a0),($10,a3)
	movea.l	d4,a5
	tst.w	(a5)
	lea	($24,sp),sp
	beq.w	.l36BBA
	pea	(-$1A,a6)
	pea	ram_FF9C88
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	movea.l	#ram_FF9C80,a3
	lea	(-$58,a6),a0
	moveq	#$1E,d0
.l36A30:
	move.w	(a3)+,(a0)+
	dbf	d0,.l36A30
	lea	(-$58,a6),a3
	move.l	a3,(-$BE,a6)
	clr.b	d0
	move.b	d0,(-$65,a6)
	move.b	d0,(-$66,a6)
	move.w	#$3,(-$C0,a6)
	move.l	(-$12,a6),d2
	neg.l	d2
	movea.l	d4,a4
	move.w	(a4),d0
	ext.l	d0
	move.l	d2,d1
	move.l	d1,d3
	mulu.w	d0,d2
	swap	d1
	mulu.w	d0,d1
	swap	d0
	mulu.w	d0,d3
	add.l	d1,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	movea.l	d4,a4
	move.w	(a4),d0
	ext.l	d0
	move.w	($1E,a2),d1
	ext.l	d1
	subi.l	#$780,d1
	sub.l	d1,d0
	move.l	d0,d1
	move.l	d2,d0
	jsr	sub_23E70
	movea.l	d4,a4
	move.w	(a4),d1
	ext.l	d1
	sub.l	d1,d0
	move.w	d0,(-$B2,a6)
	movea.l	ram_FFDBEE,a3
	move.l	(a3),(-$B6,a6)
	move.w	(-$B2,a6),d3
	ext.l	d3
	muls.w	ram_FFDD1C,d3
	movea.l	d4,a4
	move.w	(a4),d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	move.l	d3,d0
	jsr	sub_23E70
	moveq	#$0,d1
	move.w	ram_FFDC1A,d1
	add.l	d1,d0
	move.w	d0,(-$A0,a6)
	move.w	ram_FFDC00,(-$AE,a6)
	movea.l	(-$BE,a6),a3
	pea	($14,a3)
	movea.l	(-$B6,a6),a0
	movea.l	($C,a0),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	(-$BE,a6),a3
	movea.l	(-$B6,a6),a0
	movea.l	($C,a0),a0
	move.l	($8,a0),($8,a3)
	movea.l	(-$BE,a6),a3
	movea.l	(-$B6,a6),a0
	movea.l	($C,a0),a0
	move.l	($C,a0),($C,a3)
	movea.l	(-$BE,a6),a3
	movea.l	(-$B6,a6),a0
	movea.l	($C,a0),a0
	move.l	($10,a0),($10,a3)
	move.w	(-$AE,a6),d0
	ext.l	d0
	move.w	(-$B2,a6),d2
	ext.l	d2
	add.l	d2,d0
	move.l	d0,-(sp)
	pea	(-$58,a6)
	jsr	sub_2D0AE
	movea.l	(-$B6,a6),a3
	move.l	($8,a3),-(sp)
	pea	(-$D0,a6)
	jsr	sub_35230
	pea	(-$1A,a6)
	pea	(-$50,a6)
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	move.l	(-$1A,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	(-$12,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	jsr	sub_30DB0
	move.w	d0,($2C,a2)
	move.l	(-$16,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$12,a6),d3
	neg.l	d3
	move.l	d3,-(sp)
	jsr	sub_30DB0
	move.l	d0,d1
	move.w	($20,a2),d2
	ext.l	d2
	move.l	d2,d0
	mulu.w	#$FF49,d2
	swap	d0
	mulu.w	#$FF49,d0
	swap	d0
	clr.w	d0
	add.l	d0,d2
	add.l	d2,d1
	move.w	d1,($2E,a2)
	lea	($40,sp),sp
.l36BBA:
	movea.l	($16,a2),a3
	pea	($14,a3)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	($16,a2),a3
	bset	#$6,($38,a3)
	movea.l	($28,a2),a3
	pea	($14,a3)
	movea.l	($16,a2),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	($28,a2),a3
	movea.l	($16,a2),a0
	move.l	($8,a0),($8,a3)
	movea.l	($28,a2),a3
	movea.l	($16,a2),a0
	move.l	($C,a0),($C,a3)
	movea.l	($28,a2),a3
	movea.l	($16,a2),a0
	move.l	($10,a0),($10,a3)
	movea.l	($28,a2),a3
	pea	($14,a3)
	moveq	#$0,d0
	move.w	($2E,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($2E,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	movea.l	($28,a2),a3
	bset	#$6,($38,a3)
	btst	#$1,($67,a2)
	lea	($20,sp),sp
	bne.s	.l36CAC
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEEC,a3
	moveq	#$0,d1
	move.b	($0,a3,d0.l),d1
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d1
	bne.s	.l36CAC
	moveq	#$0,d2
	move.b	($67,a2),d2
	move.l	d2,d0
	moveq	#-$D,d3
	and.l	d3,d0
	moveq	#$2,d1
	bra.s	.l36CF2
.l36CAC:
	movea.l	($1A,a2),a3
	moveq	#$0,d2
	move.w	($1A,a3),d2
	move.l	d2,d0
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEEC,a0
	moveq	#$0,d3
	move.b	($0,a0,d1.l),d3
	addq.l	#2,d3
	cmp.l	d3,d0
	beq.s	.l36CDE
	movea.l	($1A,a2),a3
	cmpi.w	#$1,($1A,a3)
	bne.s	.l36CF8
.l36CDE:
	andi.b	#$FD,($67,a2)
	moveq	#$0,d2
	move.b	($67,a2),d2
	move.l	d2,d0
	moveq	#-$D,d3
	and.l	d3,d0
	moveq	#$10,d1
.l36CF2:
	or.l	d1,d0
	move.b	d0,($67,a2)
.l36CF8:
	btst	#$1,($67,a2)
	beq.w	.l36E06
	move.l	ram_FF9564,d0
	moveq	#$3,d2
	and.l	d2,d0
	bne.w	.l36E06
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEF4,a3
	moveq	#$0,d0
	move.b	($0,a3,d1.l),d0
	cmp.w	($20,a2),d0
	bhi.s	.l36D34
	subq.w	#1,($32,a2)
	bne.w	.l36E06
.l36D34:
	jsr	sub_2E9D6
	movea.l	d0,a4
	cmpa.w	#$0,a4
	beq.w	.l36E06
	tst.w	($32,a2)
	bne.s	.l36D68
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEFC,a3
	moveq	#$0,d0
	move.b	($0,a3,d1.l),d0
	move.w	d0,($32,a2)
	clr.w	($20,a2)
	bra.s	.l36D6C
.l36D68:
	addq.w	#1,($20,a2)
.l36D6C:
	move.l	a4,-(sp)
	pea	($8,a2)
	jsr	sub_2E79C
	movea.l	($28,a2),a3
	pea	($14,a3)
	movea.l	($12,a2),a0
	move.l	($10,a0),-(sp)
	movea.l	($12,a2),a0
	move.l	($C,a0),-(sp)
	movea.l	($12,a2),a0
	move.l	($8,a0),-(sp)
	pea	$A2.w
	jsr	sub_2EF4C
	move.l	d0,($8,a4)
	move.l	($8,a4),-(sp)
	jsr	sub_2E7EE
	move.l	($8,a4),-(sp)
	pea	ram_FFDA96
	jsr	sub_2E79C
	move.l	($1A,a2),($C,a4)
	movea.l	($C,a4),a3
	movea.l	($8,a3),a0
	move.w	($A,a0),($14,a4)
	move.w	#$C,($12,a4)
	move.w	($1E,a2),d0
	ext.l	d0
	subi.l	#$780,d0
	move.w	d0,($10,a4)
	move.w	#$1,($16,a4)
	move.b	#$1,ram_FFDC1C
	pea	$5E.w
	jsr	queue_sound_command
	lea	($2C,sp),sp
.l36E06:
	move.l	d6,d0
	movem.l	(-$F4,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_36E12:
	link	a6,#$FF30
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	($8,a6),a2
	move.l	#$FFDD16,d5
	movea.l	($1A,a2),a1
	movea.l	($8,a1),a4
	move.l	(a2),d6
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l36EBE
	tst.b	($66,a2)
	bne.s	.l36E72
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
	movea.l	($28,a2),a0
	bset	#$5,($38,a0)
	move.b	#$7,($66,a2)
	addq.l	#8,sp
	bra.s	.l36EBA
.l36E72:
	cmpi.b	#$1,($66,a2)
	bne.s	.l36E9C
	btst	#$1,($67,a2)
	beq.s	.l36E8E
	pea	$36.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l36E8E:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d6
	addq.l	#4,sp
	bra.s	.l36EBA
.l36E9C:
	subq.b	#1,($66,a2)
	moveq	#$0,d1
	move.b	ram_FFDCB6,d1
	asl.l	#2,d1
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d1.l)
	addq.b	#1,ram_FFDCB6
.l36EBA:
	bra.w	.l37708
.l36EBE:
	addi.w	#$FA4,($2C,a2)
	addi.w	#$47D2,($2E,a2)
	btst	#$1,($67,a2)
	beq.w	.l3705E
	movea.l	($8,a2),a3
	move.w	($10,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	($8,a3),-(sp)
	jsr	sub_2D0AE
	movea.l	($C,a3),a4
	pea	(-$C,a6)
	movea.l	($8,a3),a0
	pea	($8,a0)
	move.l	($C,a4),-(sp)
	jsr	sub_3C136
	tst.l	(-$4,a6)
	lea	($14,sp),sp
	blt.s	.l36F14
	move.l	(-$4,a6),d0
	bra.s	.l36F1A
.l36F14:
	move.l	(-$4,a6),d0
	neg.l	d0
.l36F1A:
	movea.l	($C,a3),a0
	movea.l	($8,a0),a1
	move.w	($6,a1),d2
	ext.l	d2
	cmp.l	d0,d2
	bge.s	.l36F60
	movea.l	($C,a3),a0
	movea.l	($4,a0),a4
	cmpa.l	#$FFDBEE,a4
	bne.s	.l36F46
.l36F3C:
	move.w	#$1,($3C,a2)
	bra.w	.l37708
.l36F46:
	pea	(-$C,a6)
	movea.l	($8,a3),a0
	pea	($8,a0)
	move.l	($C,a4),-(sp)
	jsr	sub_3C136
	lea	($C,sp),sp
.l36F60:
	movea.l	ram_FFDBEE,a0
	movea.l	(a0),a0
	tst.l	ram_FFDBFE
	bge.s	.l36F76
	movea.l	($4,a0),a1
	bra.s	.l36F78
.l36F76:
	movea.l	(a0),a1
.l36F78:
	cmpa.l	#$FFDBEE,a1
	bne.s	.l36F82
	movea.l	a0,a1
.l36F82:
	tst.w	ram_FFDD4E
	bne.s	.l36FCA
	cmpa.l	a1,a4
	beq.s	.l36F9E
	cmpa.l	a0,a4
	beq.s	.l36F9E
	cmpa.l	($C,a3),a1
	beq.s	.l36F9E
	cmpa.l	($C,a3),a0
	bne.s	.l36FCA
.l36F9E:
	pea	$F0.w
	pea	$640.w
	pea	(-$56,a6)
	move.l	a3,-(sp)
	pea	ram_FF9C80
	jsr	sub_3C1C8
	tst.l	d0
	lea	($14,sp),sp
	beq.s	.l36FCA
	jsr	sub_3997A
	bra.w	.l36F3C
.l36FCA:
	tst.l	d0
	bne.s	.l37018
	pea	(-$56,a6)
	pea	$94.w
	pea	(-$C,a6)
	move.l	a4,-(sp)
	move.l	a3,-(sp)
	jsr	sub_3C746
	tst.l	d0
	lea	($14,sp),sp
	beq.s	.l36FF0
	bra.w	.l36F3C
.l36FF0:
	move.l	ram_FFDBEE,d1
	cmp.l	($C,a3),d1
	beq.s	.l37008
	move.l	#$FFDBEE,d1
	cmp.l	($C,a3),d1
	bne.s	.l37018
.l37008:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d6
	addq.l	#4,sp
	bra.w	.l37708
.l37018:
	movea.l	($12,a2),a0
	pea	($14,a0)
	movea.l	($8,a3),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($12,a2),a0
	movea.l	($8,a3),a1
	move.l	($8,a1),($8,a0)
	movea.l	($12,a2),a0
	movea.l	($8,a3),a1
	move.l	($C,a1),($C,a0)
	movea.l	($12,a2),a0
	movea.l	($8,a3),a1
	move.l	($10,a1),($10,a0)
	addq.l	#8,sp
	bra.w	.l3737C
.l3705E:
	tst.b	ram_FF9540
	beq.s	.l37098
	cmpa.l	ram_FFDBEE,a1
	beq.s	.l37086
	movea.l	ram_FFDBEE,a0
	cmpa.l	(a0),a1
	bne.s	.l3708E
	move.w	($22,a2),d2
	ext.l	d2
	cmp.l	ram_FFDBFE,d2
	bge.s	.l3708E
.l37086:
	subi.w	#$28,($1E,a2)
	bra.s	.l37094
.l3708E:
	addi.w	#$28,($1E,a2)
.l37094:
	bra.w	.l371FE
.l37098:
	btst	#$2,($67,a2)
	beq.w	.l3716C
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d1
	move.b	($0,a0,d0.l),d1
	movea.l	($1A,a2),a1
	cmp.w	($1A,a1),d1
	bne.w	.l37168
	moveq	#$0,d0
	move.b	($67,a2),d0
	move.l	d0,d2
	moveq	#-$D,d3
	and.l	d3,d2
	moveq	#$10,d0
	or.l	d0,d2
	move.b	d2,($67,a2)
	movea.l	d5,a0
	cmpi.w	#$320,(a0)
	bcc.s	.l370E8
	move.w	#$320,($1E,a2)
	bra.w	.l37168
.l370E8:
	movea.l	d5,a3
	move.w	(a3),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d2
	move.b	($0,a1,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l3715E
	movea.l	d5,a3
	move.w	(a3),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d0
	move.b	($0,a1,d1.l),d0
	sub.l	d0,d2
	bra.s	.l37164
.l3715E:
	move.l	#$7D0,d2
.l37164:
	move.w	d2,($1E,a2)
.l37168:
	bra.w	.l371FE
.l3716C:
	movea.l	d5,a0
	cmpi.w	#$320,(a0)
	bcc.s	.l3717E
	move.w	#$320,($1E,a2)
	bra.w	.l371FE
.l3717E:
	movea.l	d5,a3
	move.w	(a3),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d2
	move.b	($0,a1,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l371F4
	movea.l	d5,a3
	move.w	(a3),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d0
	move.b	($0,a1,d1.l),d0
	sub.l	d0,d2
	bra.s	.l371FA
.l371F4:
	move.l	#$7D0,d2
.l371FA:
	move.w	d2,($1E,a2)
.l371FE:
	move.w	($1E,a2),d0
	add.w	d0,($22,a2)
	move.w	($22,a2),d2
	ext.l	d2
	move.w	($8,a4),d0
	ext.l	d0
	move.w	($6,a4),d3
	ext.l	d3
	sub.l	d3,d0
	cmp.l	d0,d2
	blt.w	.l372E6
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	pea	($52,a2)
	pea	($14,a3)
	jsr	sub_22DD6
	move.w	($8,a4),d0
	sub.w	d0,($22,a2)
	movea.l	($1A,a2),a0
	move.l	(a0),($1A,a2)
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a4
	move.l	#$FFDBEE,d1
	cmp.l	($1A,a2),d1
	addq.l	#8,sp
	beq.s	.l37268
	move.l	#$FFDBF6,d1
	cmp.l	($1A,a2),d1
	bne.s	.l3726C
.l37268:
	bra.w	.l37008
.l3726C:
	move.b	($5,a4),d2
	ext.w	d2
	ext.l	d2
	move.b	($4,a4),d0
	ext.w	d0
	ext.l	d0
	or.l	d0,d2
	beq.w	.l372E6
	move.w	($1E,a2),d2
	ext.l	d2
	asr.l	#6,d2
	moveq	#$1F,d0
	and.l	d0,d2
	add.l	d2,d2
	movea.l	#dat_4B00E,a0
	move.w	($0,a0,d2.l),($24,a2)
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	clr.w	d0
	lea	($14,a3),a0
	move.l	a0,d3
	lea	($52,a2),a0
	move.l	a0,d4
	lea	($40,a2),a0
.l372B6:
	clr.w	d1
	movea.l	d3,a1
	movea.l	d4,a3
	movea.l	a0,a4
.l372BE:
	move.w	(a1),d2
	sub.w	(a3),d2
	ext.l	d2
	divs.w	($24,a2),d2
	move.w	d2,(a4)
	addq.w	#1,d1
	addq.l	#2,a4
	addq.l	#2,a3
	addq.l	#2,a1
	cmpi.w	#$3,d1
	blt.s	.l372BE
	addq.w	#1,d0
	addq.l	#6,a0
	addq.l	#6,d4
	addq.l	#6,d3
	cmpi.w	#$3,d0
	blt.s	.l372B6
.l372E6:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a4
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	($14,a3)
	jsr	sub_22DD6
	movea.l	($12,a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	($12,a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	($12,a2),a0
	move.l	($10,a3),($10,a0)
	move.w	($22,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($12,a2),a0
	bset	#$6,($38,a0)
	move.l	a2,-(sp)
	jsr	sub_351D0
	move.l	$FFFF8014,d0
	asl.l	#8,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	move.w	d0,d2
	ext.l	d2
	asl.l	#5,d2
	move.l	d2,d0
	add.l	d2,d2
	add.l	d0,d2
	moveq	#$E,d0
	asr.l	d0,d2
	addq.l	#4,sp
	move.l	d2,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D110
	lea	($1C,sp),sp
.l3737C:
	movea.l	($16,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($8,a1),($8,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($C,a1),($C,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($10,a1),($10,a0)
	movea.l	($16,a2),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	($16,a2),a0
	bset	#$6,($38,a0)
	movea.l	($28,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($8,a1),($8,a0)
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($C,a1),($C,a0)
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($10,a1),($10,a0)
	movea.l	($28,a2),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	($2E,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($2E,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	($28,a2),a0
	bset	#$6,($38,a0)
	btst	#$4,($67,a2)
	lea	($28,sp),sp
	beq.w	.l37708
	tst.b	ram_FFDCC4
	beq.w	.l37708
	addq.l	#1,ram_FFDCBC
	moveq	#$2,d2
	cmp.l	ram_FFDCBC,d2
	bgt.w	.l37708
	clr.l	ram_FFDCBC
	jsr	sub_2E9D6
	movea.l	d0,a3
	cmpa.w	#$0,a3
	beq.w	.l37708
	move.b	#$2,($67,a2)
	pea	$35.w
	jsr	queue_sound_command
	move.l	a3,-(sp)
	pea	($8,a2)
	jsr	sub_2E79C
	movea.l	($12,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	move.l	($10,a1),-(sp)
	movea.l	($12,a2),a0
	move.l	($C,a0),-(sp)
	movea.l	($12,a2),a0
	move.l	($8,a0),-(sp)
	pea	$A2.w
	jsr	sub_2EF4C
	move.l	d0,($8,a3)
	movea.l	($8,a3),a0
	bset	#$5,($38,a0)
	move.l	($1A,a2),($C,a3)
	movea.l	($C,a3),a0
	movea.l	($8,a0),a1
	move.w	($A,a1),($14,a3)
	move.w	#$FD80,($10,a3)
	move.w	#$1,($16,a3)
	pea	(-$18,a6)
	pea	ram_FF9C88
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	movea.l	#ram_FF9C80,a0
	lea	(-$56,a6),a1
	moveq	#$1E,d2
.l37548:
	move.w	(a0)+,(a1)+
	dbf	d2,.l37548
	lea	(-$56,a6),a0
	move.l	a0,(-$BC,a6)
	clr.b	d0
	move.b	d0,(-$63,a6)
	move.b	d0,(-$64,a6)
	move.w	#$3,(-$BE,a6)
	movea.l	d5,a4
	move.w	(a4),d2
	ext.l	d2
	move.l	(-$10,a6),d3
	neg.l	d3
	movea.l	d5,a4
	move.w	(a4),d4
	ext.l	d4
	move.l	d3,d1
	move.l	d1,d0
	mulu.w	d4,d3
	swap	d1
	mulu.w	d4,d1
	swap	d4
	mulu.w	d4,d0
	add.l	d1,d0
	swap	d0
	clr.w	d0
	add.l	d0,d3
	movea.l	d5,a4
	move.w	(a4),d0
	ext.l	d0
	subi.l	#$FFFFFD80,d0
	move.l	d0,d1
	move.l	d3,d0
	jsr	sub_23E70
	add.l	d0,d2
	move.w	d2,(-$B0,a6)
	movea.l	ram_FFDBEE,a0
	move.l	(a0),(-$B4,a6)
	move.w	(-$B0,a6),d3
	ext.l	d3
	muls.w	ram_FFDD1C,d3
	movea.l	d5,a4
	move.w	(a4),d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	move.l	d3,d0
	jsr	sub_23E70
	move.l	d0,d2
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	add.l	d0,d2
	move.w	d2,(-$9E,a6)
	move.w	ram_FFDC00,(-$AC,a6)
	movea.l	(-$BC,a6),a0
	pea	($14,a0)
	movea.l	(-$B4,a6),a1
	movea.l	($C,a1),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	(-$BC,a6),a0
	movea.l	(-$B4,a6),a1
	movea.l	($C,a1),a1
	move.l	($8,a1),($8,a0)
	movea.l	(-$BC,a6),a0
	movea.l	(-$B4,a6),a1
	movea.l	($C,a1),a1
	move.l	($C,a1),($C,a0)
	movea.l	(-$BC,a6),a0
	movea.l	(-$B4,a6),a1
	movea.l	($C,a1),a1
	move.l	($10,a1),($10,a0)
	move.w	(-$AC,a6),d2
	ext.l	d2
	move.w	(-$B0,a6),d0
	ext.l	d0
	add.l	d0,d2
	move.l	d2,-(sp)
	pea	(-$56,a6)
	jsr	sub_2D0AE
	movea.l	(-$B4,a6),a0
	move.l	($8,a0),-(sp)
	pea	(-$CE,a6)
	jsr	sub_35230
	pea	(-$18,a6)
	pea	(-$4E,a6)
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	move.l	(-$18,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$10,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	sub_30DB0
	move.w	d0,d3
	move.l	(-$14,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$10,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	sub_30DB0
	move.w	d0,d2
	movea.l	($8,a3),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	($8,a3),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	d2,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	lea	($78,sp),sp
.l37708:
	move.l	d6,d0
	movem.l	(-$F0,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_37714:
	link	a6,#$FFA8
	movem.l	d2-d5/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.l	#ram_FFDD16,a3
	move.l	($1A,a2),d3
	movea.l	d3,a0
	movea.l	($8,a0),a4
	move.l	(a2),d4
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l377AE
	tst.b	($66,a2)
	bne.s	.l37776
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
	movea.l	($28,a2),a0
	bset	#$5,($38,a0)
	move.b	#$7,($66,a2)
	addq.l	#8,sp
	bra.s	.l377AA
.l37776:
	cmpi.b	#$1,($66,a2)
	bne.s	.l3778C
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d4
	addq.l	#4,sp
	bra.s	.l377AA
.l3778C:
	subq.b	#1,($66,a2)
	moveq	#$0,d1
	move.b	ram_FFDCB6,d1
	asl.l	#2,d1
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d1.l)
	addq.b	#1,ram_FFDCB6
.l377AA:
	bra.w	.l37C46
.l377AE:
	pea	(-$18,a6)
	pea	ram_FF9C88
	move.l	($12,a2),-(sp)
	jsr	sub_3C136
	addi.w	#$1D27,($2C,a2)
	tst.b	ram_FF9540
	lea	($C,sp),sp
	beq.s	.l37806
	cmp.l	ram_FFDBEE,d3
	beq.s	.l377F4
	movea.l	ram_FFDBEE,a0
	cmp.l	(a0),d3
	bne.s	.l377FC
	move.w	($22,a2),d0
	ext.l	d0
	cmp.l	ram_FFDBFE,d0
	bge.s	.l377FC
.l377F4:
	subi.w	#$28,($1E,a2)
	bra.s	.l37802
.l377FC:
	addi.w	#$28,($1E,a2)
.l37802:
	bra.w	.l37978
.l37806:
	btst	#$3,($67,a2)
	beq.s	.l37828
	cmpi.w	#$320,(a3)
	bcc.s	.l3781A
	move.w	(a3),($1E,a2)
	bra.s	.l37824
.l3781A:
	move.w	(a3),d0
	ext.l	d0
	asr.l	#3,d0
	move.w	d0,($1E,a2)
.l37824:
	bra.w	.l378B4
.l37828:
	cmpi.w	#$320,(a3)
	bcc.s	.l37838
	move.w	#$320,($1E,a2)
	bra.w	.l378B4
.l37838:
	move.w	(a3),d1
	ext.l	d1
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.l),d0
	sub.l	d0,d1
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d2
	move.b	($0,a1,d0.l),d2
	sub.l	d2,d1
	cmpi.l	#$7D0,d1
	bhi.s	.l378AA
	move.w	(a3),d2
	ext.l	d2
	move.w	ram_FF9578,d1
	ext.l	d1
	add.l	d1,d1
	movea.l	#dat_4EE68,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.l),d0
	move.l	d0,d1
	sub.l	d1,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEE4,a1
	moveq	#$0,d0
	move.b	($0,a1,d1.l),d0
	sub.l	d0,d2
	bra.s	.l378B0
.l378AA:
	move.l	#$7D0,d2
.l378B0:
	move.w	d2,($1E,a2)
.l378B4:
	btst	#$1,($67,a2)
	beq.w	.l37978
	cmpi.w	#$1,($20,a2)
	bne.w	.l37948
	cmpi.w	#$FC40,($72,a2)
	bge.w	.l37940
	tst.l	($28,a2)
	beq.s	.l378E8
	move.l	($28,a2),-(sp)
	jsr	sub_2E872
	clr.l	($28,a2)
	addq.l	#4,sp
.l378E8:
	move.w	($22,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	pea	$4C.w
	jsr	sub_33CAC
	movea.l	d0,a0
	moveq	#$0,d1
	move.b	($67,a0),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a0)
	moveq	#$0,d1
	move.b	($67,a0),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$2,d1
	or.l	d1,d0
	move.b	d0,($67,a0)
	move.w	($1E,a2),($1E,a0)
	move.w	#$2,($20,a2)
	move.b	#$1,ram_FFDC1C
	lea	($C,sp),sp
	bra.s	.l37946
.l37940:
	subi.w	#$C0,($72,a2)
.l37946:
	bra.s	.l37978
.l37948:
	cmpi.w	#$2,($20,a2)
	bne.s	.l3796C
	cmpi.w	#$C80,($72,a2)
	ble.s	.l37964
	clr.w	($20,a2)
	move.w	#$C80,($72,a2)
	bra.s	.l3796A
.l37964:
	addi.w	#$E0,($72,a2)
.l3796A:
	bra.s	.l37978
.l3796C:
	andi.b	#$FD,($67,a2)
	move.w	#$C80,($72,a2)
.l37978:
	move.w	($1E,a2),d0
	add.w	d0,($22,a2)
	move.w	($22,a2),d0
	ext.l	d0
	move.w	($8,a4),d1
	ext.l	d1
	move.w	($6,a4),d2
	ext.l	d2
	sub.l	d2,d1
	cmp.l	d1,d0
	blt.w	.l37A6C
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	pea	($52,a2)
	pea	($14,a3)
	jsr	sub_22DD6
	move.w	($8,a4),d0
	sub.w	d0,($22,a2)
	movea.l	($1A,a2),a0
	move.l	(a0),($1A,a2)
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a4
	move.l	#$FFDBEE,d1
	cmp.l	($1A,a2),d1
	addq.l	#8,sp
	beq.s	.l379E2
	move.l	#$FFDBF6,d1
	cmp.l	($1A,a2),d1
	bne.s	.l379F2
.l379E2:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d4
	addq.l	#4,sp
	bra.w	.l37C46
.l379F2:
	move.b	($5,a4),d0
	ext.w	d0
	ext.l	d0
	move.b	($4,a4),d1
	ext.w	d1
	ext.l	d1
	or.l	d1,d0
	beq.w	.l37A6C
	move.w	($1E,a2),d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d1
	and.l	d1,d0
	add.l	d0,d0
	movea.l	#dat_4B00E,a0
	move.w	($0,a0,d0.l),($24,a2)
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	clr.w	d1
	lea	($14,a3),a0
	move.l	a0,d3
	lea	($52,a2),a0
	move.l	a0,d5
	lea	($40,a2),a0
.l37A3C:
	clr.w	d2
	movea.l	d3,a1
	movea.l	d5,a3
	movea.l	a0,a4
.l37A44:
	move.w	(a1),d0
	sub.w	(a3),d0
	ext.l	d0
	divs.w	($24,a2),d0
	move.w	d0,(a4)
	addq.w	#1,d2
	addq.l	#2,a4
	addq.l	#2,a3
	addq.l	#2,a1
	cmpi.w	#$3,d2
	blt.s	.l37A44
	addq.w	#1,d1
	addq.l	#6,a0
	addq.l	#6,d5
	addq.l	#6,d3
	cmpi.w	#$3,d1
	blt.s	.l37A3C
.l37A6C:
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a4
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a3
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	($14,a3)
	jsr	sub_22DD6
	movea.l	($12,a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	($12,a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	($12,a2),a0
	move.l	($10,a3),($10,a0)
	move.w	($22,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($12,a2),a0
	bset	#$6,($38,a0)
	move.l	a2,-(sp)
	jsr	sub_351D0
	move.w	($72,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D110
	movea.l	($16,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($8,a1),($8,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($C,a1),($C,a0)
	movea.l	($16,a2),a0
	movea.l	($12,a2),a1
	move.l	($10,a1),($10,a0)
	movea.l	($16,a2),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($2C,a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	($16,a2),a0
	bset	#$6,($38,a0)
	tst.l	($28,a2)
	lea	($30,sp),sp
	beq.s	.l37BC6
	movea.l	($28,a2),a0
	pea	($14,a0)
	movea.l	($12,a2),a1
	pea	($14,a1)
	jsr	sub_22DD6
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($8,a1),($8,a0)
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($C,a1),($C,a0)
	movea.l	($28,a2),a0
	movea.l	($12,a2),a1
	move.l	($10,a1),($10,a0)
	move.l	#$FFFFFDC0,-(sp)
	move.l	($28,a2),-(sp)
	jsr	sub_2D110
	movea.l	($28,a2),a0
	bset	#$6,($38,a0)
	lea	($10,sp),sp
.l37BC6:
	movea.l	($1A,a2),a0
	moveq	#$0,d1
	move.w	($1A,a0),d1
	move.l	d1,d0
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEBC,a1
	moveq	#$0,d2
	move.b	($0,a1,d1.l),d2
	addq.l	#2,d2
	cmp.l	d2,d0
	bne.s	.l37C00
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l37C00:
	btst	#$1,($67,a2)
	bne.s	.l37C46
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEC4,a0
	moveq	#$0,d1
	move.b	($0,a0,d0.l),d1
	movea.l	($1A,a2),a1
	cmp.w	($1A,a1),d1
	bne.s	.l37C46
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$2,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
	move.w	#$1,($20,a2)
	move.w	#$C80,($72,a2)
.l37C46:
	move.l	d4,d0
	movem.l	(-$74,a6),d2-d5/a2-a4
	unlk	a6
	rts
	assert	*=$037C52,"game/code_034010.asm does not end at 037C52"
