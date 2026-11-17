; game/code_03BC3C.asm, 03BC3C-03FC22: game program code (pair S) with the data,
; text and tables that lie between its routines; the first routine is sub_3BC3C. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 03BC3C 03FC22 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$03BC3C,"game/code_03BC3C.asm misplaced"
sub_3BC3C:
	link	a6,#$0
	movem.l	d2-d3/a2-a3,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	cmpi.b	#$9,ram_FFDD5A
	bcs.s	.l3BC60
.l3BC5A:
	moveq	#$0,d0
	bra.w	.l3BD5C
.l3BC60:
	jsr	sub_2E9D6
	movea.l	d0,a3
	cmpa.w	#$0,a3
	bne.s	.l3BC70
	bra.s	.l3BC5A
.l3BC70:
	addq.b	#1,ram_FFDD5A
	move.l	a3,-(sp)
	pea	ram_FFDABE
	jsr	sub_2E79C
	pea	($14,a2)
	move.l	($10,a2),-(sp)
	move.l	($C,a2),-(sp)
	move.l	($8,a2),-(sp)
	pea	$92.w
	jsr	sub_2EF4C
	move.l	d0,($8,a3)
	move.l	($8,a3),-(sp)
	jsr	sub_2E7EE
	move.l	($8,a3),-(sp)
	pea	ram_FFDA96
	jsr	sub_2E79C
	movea.l	ram_FFDBEE,a0
	move.l	(a0),($C,a3)
	movea.l	($C,a3),a0
	movea.l	($8,a0),a0
	moveq	#$0,d0
	move.w	($A,a0),d0
	move.w	d2,d1
	ext.l	d1
	sub.l	d1,d0
	move.w	d0,($14,a3)
	move.w	#$7,($12,a3)
	move.w	($16,a6),d0
	ext.l	d0
	addi.l	#$12C0,d0
	move.w	d0,($10,a3)
	move.w	#$1,($16,a3)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($8,a3),-(sp)
	jsr	sub_2D110
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($8,a3),-(sp)
	jsr	sub_2D172
	pea	$40.w
	move.l	($8,a3),-(sp)
	jsr	sub_2D0AE
	movea.l	($8,a3),a0
	pea	($14,a0)
	moveq	#$0,d0
	move.w	($1A,a6),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($1A,a6),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	moveq	#$1,d0
.l3BD5C:
	movem.l	(-$10,a6),d2-d3/a2-a3
	unlk	a6
	rts
sub_3BD66:
	link	a6,#$FFAC
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	ram_FFDABE,a4
	move.l	#$FFDBEE,d3
	move.l	#$FFDAAE,d2
	bra.w	loc_3C040
loc_3BD84:
	moveq	#$0,d6
	move.l	(a4),(-$8,a6)
	movea.l	($8,a4),a2
	movea.l	($26,a2),a0
	move.w	($4,a0),d0
	move.w	d0,d1
	cmpi.w	#$92,d0
	bcs.w	loc_3BE84
	cmpi.w	#$97,d0
	bhi.s	.l3BDC0
	sub.w	#$92,d0
	add.w	d0,d0
	move.w	(.l3BDB4,pc,d0.w),d0
	jmp	(.l3BDB4,pc,d0.w)
.l3BDB4:
	dc.w	sub_3BDFE-.l3BDB4
	dc.w	sub_3BE1E-.l3BDB4
	dc.w	sub_3BE30-.l3BDB4
	dc.w	sub_3BE30-.l3BDB4
	dc.w	sub_3BE30-.l3BDB4
	dc.w	loc_3BE56-.l3BDB4
.l3BDC0:
	cmpi.w	#$D8,d0
	bcs.w	loc_3BE84
	cmpi.w	#$E7,d0
	bhi.w	loc_3BE84
	sub.w	#$D8,d0
	add.w	d0,d0
	move.w	(.l3BDDE,pc,d0.w),d0
	jmp	(.l3BDDE,pc,d0.w)
.l3BDDE:
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
	dc.w	sub_3BE7A-.l3BDDE
sub_3BDFE:
	movea.l	($8,a4),a2
	pea	$93.w
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	($8,a4),a2
	bset	#$6,($38,a2)
	addq.l	#4,sp
	bra.s	loc_3BE84
sub_3BE1E:
	tst.w	($16,a4)
	beq.s	.l3BE2E
	subi.w	#$640,($10,a4)
	clr.w	($16,a4)
.l3BE2E:
	bra.s	loc_3BE84
sub_3BE30:
	movea.l	($8,a4),a2
	moveq	#$0,d0
	move.w	d1,d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	($8,a4),a2
	bset	#$6,($38,a2)
loc_3BE50:
	addq.l	#4,sp
loc_3BE52:
	bra.w	loc_3C03C
loc_3BE56:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA08
	subq.b	#1,ram_FFDD5A
	move.b	#$1,ram_FFDC1C
	addq.l	#8,sp
	bra.s	loc_3BE52
sub_3BE7A:
	move.l	a4,-(sp)
	jsr	sub_3CAD8
	bra.s	loc_3BE50
loc_3BE84:
	subq.w	#1,($12,a4)
	beq.w	.l3C01A
	movea.l	($8,a4),a0
	lea	(-$46,a6),a1
	moveq	#$3D,d0
.l3BE96:
	move.b	(a0)+,(a1)+
	dbf	d0,.l3BE96
	move.w	($10,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($8,a4),-(sp)
	jsr	sub_2D0AE
	movea.l	($8,a4),a2
	bset	#$6,($38,a2)
	move.l	($C,a4),d5
	pea	(-$52,a6)
	movea.l	($8,a4),a2
	pea	($8,a2)
	movea.l	d5,a3
	move.l	($C,a3),-(sp)
	jsr	sub_3C136
	tst.l	(-$4A,a6)
	lea	($14,sp),sp
	blt.s	.l3BEE4
	move.l	(-$4A,a6),d1
	bra.s	.l3BEEA
.l3BEE4:
	move.l	(-$4A,a6),d1
	neg.l	d1
.l3BEEA:
	movea.l	($C,a4),a2
	movea.l	($8,a2),a0
	move.w	($6,a0),d0
	ext.l	d0
	cmp.l	d1,d0
	bge.s	.l3BF1E
	movea.l	($C,a4),a2
	move.l	(a2),d5
	pea	(-$52,a6)
	movea.l	($8,a4),a2
	pea	($8,a2)
	movea.l	d5,a3
	move.l	($C,a3),-(sp)
	jsr	sub_3C136
	lea	($C,sp),sp
.l3BF1E:
	cmp.l	#$FFDBEE,d5
	bne.s	.l3BF2A
	bra.w	loc_3BE56
.l3BF2A:
	move.l	ram_FFDAB2,d4
	lea	(-$46,a6),a3
	bra.w	.l3BFF4
.l3BF38:
	movea.l	d4,a0
	move.l	($4,a0),(-$4,a6)
	movea.l	d4,a0
	movea.l	($12,a0),a2
	btst	#$5,($38,a2)
	beq.s	.l3BF52
	bra.w	.l3BFF0
.l3BF52:
	movea.l	d4,a0
	tst.w	($22,a0)
	bge.s	.l3BF66
	movea.l	d4,a0
	movea.l	($1A,a0),a2
	move.l	($4,a2),d0
	bra.s	.l3BF6E
.l3BF66:
	movea.l	d4,a0
	movea.l	($1A,a0),a2
	move.l	(a2),d0
.l3BF6E:
	cmp.l	d3,d0
	bne.s	.l3BF78
	movea.l	d4,a0
	move.l	($1A,a0),d0
.l3BF78:
	cmp.l	d0,d5
	beq.s	.l3BF96
	movea.l	d4,a0
	cmp.l	($1A,a0),d5
	beq.s	.l3BF96
	cmp.l	($C,a4),d0
	beq.s	.l3BF96
	movea.l	d4,a0
	move.l	($1A,a0),d0
	cmp.l	($C,a4),d0
	bne.s	.l3BFF0
.l3BF96:
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($3A,a2),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($38,a2),d0
	move.l	d0,-(sp)
	pea	(a3)
	move.l	a4,-(sp)
	movea.l	d4,a2
	move.l	($12,a2),-(sp)
	jsr	sub_3C1C8
	move.l	d0,d6
	tst.l	d6
	lea	($14,sp),sp
	beq.s	.l3BFF0
	movea.l	d4,a0
	addq.w	#1,($3C,a0)
	movea.l	d4,a0
	cmpi.w	#$5,($10,a0)
	beq.s	.l3BFDA
	addq.w	#1,ram_FFDD06
.l3BFDA:
	movea.l	($8,a4),a2
	pea	$94.w
	jsr	object_descriptor
	move.l	d0,($26,a2)
	addq.l	#4,sp
	bra.s	.l3BFFA
.l3BFF0:
	move.l	(-$4,a6),d4
.l3BFF4:
	cmp.l	d2,d4
	bne.w	.l3BF38
.l3BFFA:
	tst.l	d6
	bne.s	.l3C018
	pea	(-$46,a6)
	pea	$94.w
	pea	(-$52,a6)
	move.l	d5,-(sp)
	move.l	a4,-(sp)
	jsr	sub_3C746
	lea	($14,sp),sp
.l3C018:
	bra.s	loc_3C03C
.l3C01A:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA08
	subq.b	#1,ram_FFDD5A
	move.b	#$1,ram_FFDC1C
	addq.l	#8,sp
loc_3C03C:
	movea.l	(-$8,a6),a4
loc_3C040:
	cmpa.l	#$FFDABE,a4
	bne.w	loc_3BD84
	movem.l	(-$74,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_3C054:
	link	a6,#$0
	movem.l	d2-d6,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d3
	move.w	($12,a6),d4
	tst.l	d3
	blt.s	.l3C070
	move.l	d3,d5
	bra.s	.l3C074
.l3C070:
	move.l	d3,d5
	neg.l	d5
.l3C074:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	cmp.l	d5,d1
	bcs.s	.l3C082
	moveq	#$1,d0
	bra.s	.l3C084
.l3C082:
	moveq	#$0,d0
.l3C084:
	move.w	d0,d6
	tst.l	d2
	blt.s	.l3C08E
	move.l	d2,d5
	bra.s	.l3C092
.l3C08E:
	move.l	d2,d5
	neg.l	d5
.l3C092:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	cmp.l	d5,d1
	bcs.s	.l3C0A0
	moveq	#$2,d0
	bra.s	.l3C0A2
.l3C0A0:
	moveq	#$0,d0
.l3C0A2:
	or.w	d6,d0
	beq.s	.l3C0AA
	move.w	d0,d1
	bra.s	.l3C0C0
.l3C0AA:
	move.l	d3,d1
	move.l	d2,d0
	eor.l	d0,d1
	andi.l	#$80000000,d1
	beq.s	.l3C0BC
	moveq	#$4,d0
	bra.s	.l3C0BE
.l3C0BC:
	moveq	#$0,d0
.l3C0BE:
	move.w	d0,d1
.l3C0C0:
	moveq	#$0,d0
	move.w	d1,d0
	movem.l	(-$14,a6),d2-d6
	unlk	a6
	rts
sub_3C0CE:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	movea.l	($8,a6),a0
	tst.l	(a0)
	blt.s	.l3C0E2
	move.l	(a0),d0
	bra.s	.l3C0E6
.l3C0E2:
	move.l	(a0),d0
	neg.l	d0
.l3C0E6:
	move.l	d0,d2
	move.l	a0,d0
	addq.l	#4,d0
	movea.l	d0,a1
	tst.l	(a1)
	blt.s	.l3C0FC
	move.l	a0,d0
	addq.l	#4,d0
	movea.l	d0,a1
	move.l	(a1),d0
	bra.s	.l3C106
.l3C0FC:
	move.l	a0,d0
	addq.l	#4,d0
	movea.l	d0,a1
	move.l	(a1),d0
	neg.l	d0
.l3C106:
	move.l	d0,d3
	cmp.l	d3,d2
	ble.s	.l3C11A
	move.l	d3,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	asr.l	#3,d0
	add.w	d2,d0
	bra.s	.l3C126
.l3C11A:
	move.l	d2,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	asr.l	#3,d0
	add.w	d3,d0
.l3C126:
	movea.w	d0,a0
	moveq	#$0,d0
	move.w	a0,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_3C136:
	link	a6,#$FFF4
	movem.l	a2,-(sp)
	movea.l	($8,a6),a0
	movea.l	($C,a6),a2
	move.l	($10,a6),d1
	move.l	(a2),d0
	sub.l	($8,a0),d0
	move.l	d0,(-$C,a6)
	movea.l	a2,a1
	addq.l	#4,a1
	move.l	(a1),d0
	sub.l	($C,a0),d0
	move.l	d0,(-$8,a6)
	movea.l	a2,a1
	addq.l	#8,a1
	move.l	(a1),d0
	sub.l	($10,a0),d0
	move.l	d0,(-$4,a6)
	pea	($14,a0)
	move.l	d1,-(sp)
	pea	(-$C,a6)
	jsr	sub_22A36
	movem.l	(-$10,a6),a2
	unlk	a6
	rts
sub_3C18A:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d1
	move.l	($10,a6),d0
	cmp.l	d1,d2
	bge.s	.l3C1B0
	moveq	#$0,d3
	cmp.l	d0,d2
	bgt.s	.l3C1AE
	cmp.l	d1,d0
	bgt.s	.l3C1AE
	moveq	#$1,d3
.l3C1AE:
	bra.s	.l3C1BC
.l3C1B0:
	moveq	#$0,d3
	cmp.l	d0,d1
	bgt.s	.l3C1BC
	cmp.l	d2,d0
	bgt.s	.l3C1BC
	moveq	#$1,d3
.l3C1BC:
	move.l	d3,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_3C1C8:
	link	a6,#$FFE0
	movem.l	d2-d7/a2-a4,-(sp)
	move.l	($8,a6),d2
	movea.l	($C,a6),a2
	movea.l	($10,a6),a3
	movea.l	#sub_3C18A,a4
	pea	(-$12,a6)
	movea.l	($8,a2),a0
	pea	($8,a0)
	move.l	d2,-(sp)
	jsr	sub_3C136
	pea	(-$1E,a6)
	pea	($8,a3)
	move.l	d2,-(sp)
	jsr	sub_3C136
	moveq	#$0,d1
	move.w	($16,a6),d1
	move.l	d1,-(sp)
	move.l	(-$16,a6),-(sp)
	move.l	(-$A,a6),-(sp)
	jsr	sub_3C054
	move.w	d0,d0
	beq.w	loc_3C73C
	movea.w	(-$8,a6),a0
	suba.w	(-$14,a6),a0
	move.l	a0,d1
	tst.w	d1
	beq.s	.l3C236
	moveq	#$0,d0
	move.w	a0,d0
	bra.s	.l3C238
.l3C236:
	moveq	#$1,d0
.l3C238:
	movea.w	d0,a0
	move.l	(-$12,a6),d5
	sub.l	(-$1E,a6),d5
	move.l	(-$E,a6),d6
	sub.l	(-$1A,a6),d6
	tst.l	(-$16,a6)
	beq.w	.l3C2C8
	moveq	#$0,d1
	move.w	($16,a6),d1
	neg.l	d1
	cmp.l	(-$16,a6),d1
	bls.s	.l3C2C8
	movea.w	(-$8,a6),a1
	adda.w	($16,a6),a1
	move.l	(-$12,a6),d0
	move.l	d5,d2
	moveq	#$0,d1
	move.w	a1,d1
	move.l	d1,d4
	move.l	d2,d1
	move.l	d1,d3
	mulu.w	d4,d2
	swap	d1
	mulu.w	d4,d1
	swap	d4
	mulu.w	d4,d3
	add.l	d1,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	move.l	d2,d1
	move.l	a0,d7
	divs.w	d7,d1
	ext.l	d1
	sub.l	d1,d0
	move.l	d0,(-$1E,a6)
	move.l	(-$E,a6),d0
	move.l	d6,d2
	moveq	#$0,d1
	move.w	a1,d1
	move.l	d1,d4
	move.l	d2,d1
	move.l	d1,d3
	mulu.w	d4,d2
	swap	d1
	mulu.w	d4,d1
	swap	d4
	mulu.w	d4,d3
	add.l	d1,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	move.l	d2,d1
	move.l	a0,d7
	divs.w	d7,d1
	ext.l	d1
	sub.l	d1,d0
	move.l	d0,(-$1A,a6)
.l3C2C8:
	move.w	($16,a6),d0
	ext.l	d0
	cmp.l	(-$A,a6),d0
	bge.s	.l3C334
	movea.w	(-$8,a6),a1
	suba.w	($16,a6),a1
	move.l	d5,d2
	moveq	#$0,d0
	move.w	a1,d0
	move.l	d0,d3
	move.l	d2,d0
	move.l	d0,d1
	mulu.w	d3,d2
	swap	d0
	mulu.w	d3,d0
	swap	d3
	mulu.w	d3,d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	add.l	d1,d2
	move.l	d2,d1
	move.l	a0,d4
	divs.w	d4,d1
	move.w	d1,d0
	ext.l	d0
	sub.l	d0,(-$12,a6)
	move.l	d6,d2
	moveq	#$0,d0
	move.w	a1,d0
	move.l	d0,d3
	move.l	d2,d0
	move.l	d0,d1
	mulu.w	d3,d2
	swap	d0
	mulu.w	d3,d0
	swap	d3
	mulu.w	d3,d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	add.l	d1,d2
	move.l	d2,d1
	move.l	a0,d4
	divs.w	d4,d1
	move.w	d1,d0
	ext.l	d0
	sub.l	d0,(-$E,a6)
.l3C334:
	pea	(-$12,a6)
	jsr	sub_3C0CE
	move.w	d0,d3
	pea	(-$1E,a6)
	jsr	sub_3C0CE
	move.w	d0,d2
	moveq	#$0,d1
	move.w	($1A,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	move.l	d0,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,-(sp)
	jsr	sub_3C054
	movea.w	d0,a1
	move.w	a1,d0
	cmpi.w	#$4,d0
	bhi.w	loc_3C73C
	add.w	d0,d0
	move.w	(.l3C37E,pc,d0.w),d0
	jmp	(.l3C37E,pc,d0.w)
.l3C37E:
	dc.w	sub_3C3D8-.l3C37E
	dc.w	sub_3C388-.l3C37E
	dc.w	sub_3C3B0-.l3C37E
	dc.w	sub_3C3D2-.l3C37E
	dc.w	sub_3C3D8-.l3C37E
sub_3C388:
	tst.l	(-$16,a6)
	blt.s	.l3C394
	move.l	(-$16,a6),d2
	bra.s	.l3C39A
.l3C394:
	move.l	(-$16,a6),d2
	neg.l	d2
.l3C39A:
	moveq	#$0,d1
	move.w	($16,a6),d1
	move.l	d1,d0
	cmp.l	d2,d0
	bcs.s	loc_3C3AC
loc_3C3A6:
	moveq	#$1,d0
	bra.w	loc_3C73C
loc_3C3AC:
	bra.w	loc_3C73C
sub_3C3B0:
	tst.l	(-$A,a6)
	blt.s	.l3C3BC
	move.l	(-$A,a6),d2
	bra.s	.l3C3C2
.l3C3BC:
	move.l	(-$A,a6),d2
	neg.l	d2
.l3C3C2:
	moveq	#$0,d1
	move.w	($16,a6),d1
	move.l	d1,d0
	cmp.l	d2,d0
	bcs.s	.l3C3D0
	bra.s	loc_3C3A6
.l3C3D0:
	bra.s	loc_3C3AC
sub_3C3D2:
	moveq	#$1,d0
	bra.w	loc_3C73C
sub_3C3D8:
	move.w	($1A,a6),(-$2,a6)
	moveq	#$0,d4
	move.l	(-$1E,a6),d5
	sub.l	(-$12,a6),d5
	move.l	(-$1A,a6),d6
	sub.l	(-$E,a6),d6
	tst.l	d5
	blt.s	.l3C3F8
	move.l	d5,d0
	bra.s	.l3C3FC
.l3C3F8:
	move.l	d5,d0
	neg.l	d0
.l3C3FC:
	tst.l	d6
	blt.s	.l3C404
	move.l	d6,d1
	bra.s	.l3C408
.l3C404:
	move.l	d6,d1
	neg.l	d1
.l3C408:
	cmp.l	d1,d0
	bge.w	.l3C596
	tst.l	d5
	beq.w	.l3C536
	move.l	d5,d0
	asl.l	#8,d0
	move.l	d6,d1
	jsr	sub_23E70
	movea.l	d0,a3
	move.l	(-$1A,a6),(-$6,a6)
	move.l	(-$1E,a6),d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	a3,d7
	mulu.w	d7,d0
	swap	d1
	move.l	a3,d7
	mulu.w	d7,d1
	move.l	a3,d3
	swap	d3
	mulu.w	d3,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	addi.l	#$80,d0
	asr.l	#8,d0
	move.l	(-$6,a6),d7
	sub.l	d0,d7
	move.l	d7,(-$6,a6)
	move.l	a3,d0
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d0,d3
	move.l	d3,d2
	mulu.w	d1,d0
	swap	d3
	mulu.w	d1,d3
	swap	d1
	mulu.w	d1,d2
	add.l	d3,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	asr.l	#8,d0
	move.l	d0,d6
	move.l	d6,d2
	add.l	(-$6,a6),d6
	move.l	d6,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C4B4
	move.l	d6,-(sp)
	move.l	(-$E,a6),-(sp)
	move.l	(-$1A,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C4B4
	moveq	#$1,d4
	bra.w	.l3C534
.l3C4B4:
	move.l	(-$6,a6),d6
	sub.l	d2,d6
	move.l	d6,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C4EA
	move.l	d6,-(sp)
	move.l	(-$E,a6),-(sp)
	move.l	(-$1A,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C4EA
	moveq	#$1,d4
	bra.s	.l3C534
.l3C4EA:
	move.l	a3,d0
	beq.s	.l3C534
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,d0
	sub.l	(-$6,a6),d0
	asl.l	#8,d0
	move.l	a3,d1
	jsr	sub_23E70
	move.l	d0,d5
	move.l	d5,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C534
	move.l	d5,-(sp)
	move.l	(-$12,a6),-(sp)
	move.l	(-$1E,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C534
	moveq	#$1,d4
.l3C534:
	bra.s	.l3C592
.l3C536:
	move.l	(-$1E,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C592
	move.l	(-$1A,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	bne.s	.l3C590
	move.l	(-$E,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C592
.l3C590:
	moveq	#$1,d4
.l3C592:
	bra.w	.l3C71A
.l3C596:
	tst.l	d6
	beq.w	.l3C6BE
	move.l	d6,d0
	asl.l	#8,d0
	move.l	d5,d1
	jsr	sub_23E70
	movea.l	d0,a3
	move.l	(-$1E,a6),(-$6,a6)
	move.l	(-$1A,a6),d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	a3,d7
	mulu.w	d7,d0
	swap	d1
	move.l	a3,d7
	mulu.w	d7,d1
	move.l	a3,d3
	swap	d3
	mulu.w	d3,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	addi.l	#$80,d0
	asr.l	#8,d0
	move.l	(-$6,a6),d7
	sub.l	d0,d7
	move.l	d7,(-$6,a6)
	move.l	a3,d0
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d0,d2
	move.l	d2,d3
	mulu.w	d1,d0
	swap	d2
	mulu.w	d1,d2
	swap	d1
	mulu.w	d1,d3
	add.l	d2,d3
	swap	d3
	clr.w	d3
	add.l	d3,d0
	asr.l	#8,d0
	move.l	d0,d5
	move.l	d5,d2
	add.l	(-$6,a6),d5
	move.l	d5,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C63C
	move.l	d5,-(sp)
	move.l	(-$12,a6),-(sp)
	move.l	(-$1E,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C63C
	moveq	#$1,d4
	bra.w	.l3C6BC
.l3C63C:
	move.l	(-$6,a6),d5
	sub.l	d2,d5
	move.l	d5,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C672
	move.l	d5,-(sp)
	move.l	(-$12,a6),-(sp)
	move.l	(-$1E,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C672
	moveq	#$1,d4
	bra.s	.l3C6BC
.l3C672:
	move.l	a3,d0
	beq.s	.l3C6BC
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,d0
	sub.l	(-$6,a6),d0
	asl.l	#8,d0
	move.l	a3,d1
	jsr	sub_23E70
	move.l	d0,d6
	move.l	d6,-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C6BC
	move.l	d6,-(sp)
	move.l	(-$E,a6),-(sp)
	move.l	(-$1A,a6),-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C6BC
	moveq	#$1,d4
.l3C6BC:
	bra.s	.l3C71A
.l3C6BE:
	move.l	(-$1A,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C71A
	move.l	(-$1E,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	bne.s	.l3C718
	move.l	(-$12,a6),-(sp)
	moveq	#$0,d1
	move.w	(-$2,a6),d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	(a4)
	tst.l	d0
	beq.s	.l3C71A
.l3C718:
	moveq	#$1,d4
.l3C71A:
	tst.l	d4
	beq.s	.l3C738
	moveq	#$0,d1
	move.w	($16,a6),d1
	move.l	d1,d0
	add.l	(-$A,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	($8,a2),-(sp)
	jsr	sub_2D0AE
.l3C738:
	move.l	d4,d0
	nop
loc_3C73C:
	movem.l	(-$44,a6),d2-d7/a2-a4
	unlk	a6
	rts
sub_3C746:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a4
	move.l	($10,a6),d2
	move.l	#sub_2D0AE,d4
	movea.l	($8,a4),a3
	move.w	($A,a3),d3
	moveq	#$0,d0
	move.w	d3,d0
	divu.w	#$C,d0
	add.w	d0,d3
	move.l	d2,-(sp)
	jsr	sub_3C0CE
	move.w	d0,(-$2,a6)
	move.w	(-$2,a6),d5
	cmp.w	d3,d5
	addq.l	#4,sp
	bcs.s	.l3C792
	tst.b	ram_FF9540
	beq.w	.l3C81C
.l3C792:
	tst.b	ram_FF9540
	bne.w	.l3C80E
	move.l	#$140,d4
	move.l	#$240,d3
	moveq	#$54,d2
	move.l	($10,a4),d6
	lea	($10,a4),a3
	move.l	a3,d5
	bra.s	.l3C80A
.l3C7B6:
	movea.l	d6,a1
	movea.l	($8,a1),a3
	movea.l	($26,a3),a0
	move.w	($4,a0),d0
	ext.l	d0
	cmp.l	d2,d0
	bne.s	.l3C806
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	($18,a6),-(sp)
	move.l	a2,-(sp)
	movea.l	d6,a3
	move.l	($8,a3),-(sp)
	jsr	sub_3C1C8
	tst.l	d0
	lea	($14,sp),sp
	beq.s	.l3C806
.l3C7E8:
	movea.l	($8,a2),a3
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a3)
	moveq	#$1,d0
	addq.l	#4,sp
.l3C802:
	bra.w	.l3C9A8
.l3C806:
	movea.l	d6,a0
	move.l	(a0),d6
.l3C80A:
	cmp.l	d5,d6
	bne.s	.l3C7B6
.l3C80E:
	move.l	a4,($C,a2)
	move.w	(-$2,a6),($14,a2)
	moveq	#$0,d0
	bra.s	.l3C802
.l3C81C:
	movea.l	($8,a4),a3
	btst	#$7,($11,a3)
	beq.w	.l3C918
	movea.l	d2,a0
	addq.l	#4,a0
	cmpi.l	#$FFFFFA10,(a0)
	bge.w	.l3C8B8
	move.w	(-$2,a6),d5
	sub.w	($14,a2),d5
	tst.w	d5
	bne.s	.l3C846
	moveq	#$1,d5
.l3C846:
	move.l	d2,d1
	addq.l	#4,d1
	movea.l	d1,a0
	move.l	(a0),d0
	addi.l	#$5F0,d0
	neg.l	d0
	move.w	d0,d2
	tst.w	($10,a2)
	blt.s	.l3C866
	move.w	($10,a2),d0
	ext.l	d0
	bra.s	.l3C86E
.l3C866:
	move.w	($10,a2),d0
	ext.l	d0
	neg.l	d0
.l3C86E:
	moveq	#$0,d1
	move.w	d2,d1
	movea.l	d1,a0
	move.l	d0,d1
	move.l	d1,d2
	move.l	a0,d6
	mulu.w	d6,d0
	swap	d1
	move.l	a0,d6
	mulu.w	d6,d1
	move.l	a0,d3
	swap	d3
	mulu.w	d3,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	divu.w	d5,d0
	tst.w	($10,a2)
	bge.s	.l3C8A0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,-(sp)
	bra.s	.l3C8AA
.l3C8A0:
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d2
	neg.l	d2
	move.l	d2,-(sp)
.l3C8AA:
	move.l	($8,a2),-(sp)
	movea.l	d4,a3
	jsr	(a3)
	addq.l	#8,sp
	bra.w	.l3C914
.l3C8B8:
	move.l	#$140,d4
	move.l	#$240,d3
	moveq	#$3,d2
	move.l	($10,a4),d6
	lea	($10,a4),a3
	move.l	a3,d5
	bra.s	.l3C90C
.l3C8D2:
	movea.l	d6,a1
	movea.l	($8,a1),a3
	movea.l	($26,a3),a0
	move.w	($4,a0),d0
	ext.l	d0
	cmp.l	d2,d0
	bne.s	.l3C908
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	($18,a6),-(sp)
	move.l	a2,-(sp)
	movea.l	d6,a3
	move.l	($8,a3),-(sp)
	jsr	sub_3C1C8
	tst.l	d0
	lea	($14,sp),sp
	beq.s	.l3C908
	bra.w	.l3C7E8
.l3C908:
	movea.l	d6,a0
	move.l	(a0),d6
.l3C90C:
	cmp.l	d5,d6
	bne.s	.l3C8D2
	bra.w	.l3C80E
.l3C914:
	bra.w	.l3C98E
.l3C918:
	move.w	(-$2,a6),d0
	cmp.w	($14,a2),d0
	beq.w	.l3C98E
	move.w	(-$2,a6),d5
	sub.w	($14,a2),d5
	move.w	(-$2,a6),d2
	sub.w	d3,d2
	tst.w	($10,a2)
	blt.s	.l3C940
	move.w	($10,a2),d0
	ext.l	d0
	bra.s	.l3C948
.l3C940:
	move.w	($10,a2),d0
	ext.l	d0
	neg.l	d0
.l3C948:
	moveq	#$0,d1
	move.w	d2,d1
	movea.l	d1,a0
	move.l	d0,d1
	move.l	d1,d2
	move.l	a0,d6
	mulu.w	d6,d0
	swap	d1
	move.l	a0,d6
	mulu.w	d6,d1
	move.l	a0,d3
	swap	d3
	mulu.w	d3,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	divu.w	d5,d0
	tst.w	($10,a2)
	bge.s	.l3C97A
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,-(sp)
	bra.s	.l3C984
.l3C97A:
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d2
	neg.l	d2
	move.l	d2,-(sp)
.l3C984:
	move.l	($8,a2),-(sp)
	movea.l	d4,a3
	jsr	(a3)
	addq.l	#8,sp
.l3C98E:
	movea.l	($8,a2),a3
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a3)
	moveq	#$1,d0
	addq.l	#4,sp
.l3C9A8:
	movem.l	(-$24,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_3C9B2:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	tst.w	ram_FFDD80
	bne.s	.l3C9D0
.l3C9CA:
	moveq	#$0,d0
	bra.w	.l3CACE
.l3C9D0:
	jsr	sub_2E9D6
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l3C9E0
	bra.s	.l3C9CA
.l3C9E0:
	subq.w	#1,ram_FFDD80
	move.b	#$1,ram_FFDCF6
	move.l	a2,-(sp)
	pea	ram_FFDABE
	jsr	sub_2E79C
	movea.l	ram_FFDBEE,a0
	move.l	(a0),($C,a2)
	movea.l	($C,a2),a0
	movea.l	($C,a0),a1
	movea.l	($C,a2),a0
	movea.l	($8,a0),a0
	btst	#$7,($11,a0)
	beq.s	.l3CA26
	move.w	dat_4D868,d0
	bra.s	.l3CA4C
.l3CA26:
	cmpi.w	#$320,($A,a0)
	bls.s	.l3CA46
	cmpi.w	#$4B0,($A,a0)
	bls.s	.l3CA3E
	move.w	dat_4D850,d0
	bra.s	.l3CA44
.l3CA3E:
	move.w	dat_4D858,d0
.l3CA44:
	bra.s	.l3CA4C
.l3CA46:
	move.w	dat_4D860,d0
.l3CA4C:
	pea	($14,a1)
	move.l	($10,a1),-(sp)
	move.l	($C,a1),-(sp)
	move.l	($8,a1),-(sp)
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,($8,a2)
	movea.l	($8,a2),a0
	andi.b	#$E7,($38,a0)
	ori.b	#$18,($38,a0)
	movea.l	($8,a2),a0
	move.w	#$FDA0,($36,a0)
	move.w	d3,($10,a2)
	clr.w	($14,a2)
	move.l	($8,a2),-(sp)
	jsr	sub_2E7EE
	move.l	($8,a2),-(sp)
	pea	ram_FFDA96
	jsr	sub_2E79C
	cmpi.w	#$5A0,d2
	bcs.s	.l3CAB0
	ext.l	d2
	bra.s	.l3CAB6
.l3CAB0:
	move.l	#$5A0,d2
.l3CAB6:
	move.w	d2,d0
	ext.l	d0
	addi.l	#$640,d0
	move.w	d0,($12,a2)
	move.l	a2,-(sp)
	jsr	sub_3CAD8
	moveq	#$1,d0
.l3CACE:
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3CAD8:
	link	a6,#$0
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	($8,a6),a2
	move.w	($12,a2),d0
	add.w	d0,($10,a2)
	move.w	($10,a2),d0
	ext.l	d0
	movea.l	($C,a2),a3
	movea.l	($8,a3),a0
	move.w	($8,a0),d1
	ext.l	d1
	movea.l	($C,a2),a0
	movea.l	($8,a0),a0
	move.w	($6,a0),d2
	ext.l	d2
	sub.l	d2,d1
	cmp.l	d1,d0
	blt.s	.l3CB66
	movea.l	($C,a2),a3
	movea.l	($8,a3),a0
	move.w	($8,a0),d0
	sub.w	d0,($10,a2)
	movea.l	($C,a2),a3
	move.l	(a3),($C,a2)
	move.l	#$FFDBEE,d0
	cmp.l	($C,a2),d0
	beq.s	.l3CB44
	move.l	#$FFDBF6,d0
	cmp.l	($C,a2),d0
	bne.s	.l3CB66
.l3CB44:
	move.l	($8,a2),-(sp)
	jsr	sub_2E872
	move.l	a2,-(sp)
	jsr	sub_2EA08
	move.b	#$1,ram_FFDC1C
	moveq	#$0,d0
	addq.l	#8,sp
	bra.w	.l3CD0A
.l3CB66:
	btst	#$0,ram_FF9567
	beq.w	.l3CC02
	addq.w	#1,($14,a2)
	move.w	($14,a2),d0
	cmpi.w	#$4,d0
	bcs.s	.l3CB84
	clr.w	($14,a2)
.l3CB84:
	movea.l	($C,a2),a3
	movea.l	($8,a3),a0
	btst	#$7,($11,a0)
	beq.s	.l3CBA6
	move.w	($14,a2),d0
	add.w	d0,d0
	movea.l	#dat_4D868,a3
	move.w	($0,a3,d0.w),d0
	bra.s	.l3CBE6
.l3CBA6:
	cmpi.w	#$320,($A,a0)
	bls.s	.l3CBD6
	cmpi.w	#$4B0,($A,a0)
	bls.s	.l3CBC4
	move.w	($14,a2),d0
	add.w	d0,d0
	movea.l	#dat_4D850,a3
	bra.s	.l3CBD0
.l3CBC4:
	move.w	($14,a2),d0
	add.w	d0,d0
	movea.l	#dat_4D858,a3
.l3CBD0:
	move.w	($0,a3,d0.w),d0
	bra.s	.l3CBE6
.l3CBD6:
	move.w	($14,a2),d0
	add.w	d0,d0
	movea.l	#dat_4D860,a3
	move.w	($0,a3,d0.w),d0
.l3CBE6:
	movea.l	($8,a2),a3
	ext.l	d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a3)
	move.b	#$1,ram_FFDC1C
	addq.l	#4,sp
.l3CC02:
	move.l	#$C8,d2
	movea.l	($8,a2),a3
	pea	($14,a3)
	movea.l	($C,a2),a0
	movea.l	($C,a0),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	($8,a2),a3
	movea.l	($C,a2),a0
	movea.l	($C,a0),a0
	move.l	($8,a0),($8,a3)
	movea.l	($8,a2),a3
	movea.l	($C,a2),a0
	movea.l	($C,a0),a0
	move.l	($C,a0),($C,a3)
	movea.l	($8,a2),a3
	movea.l	($C,a2),a0
	movea.l	($C,a0),a0
	move.l	($10,a0),($10,a3)
	move.w	($10,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($8,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($8,a2),a3
	bset	#$6,($38,a3)
	movea.l	($C,a2),a3
	move.l	($4,a3),d5
	movea.l	ram_FFDAB2,a4
	move.l	#$FFDAAE,d3
	movea.l	#ram_FFDD06,a1
	lea	($10,sp),sp
	bra.w	.l3CD06
.l3CC96:
	move.l	($4,a4),d6
	movea.l	($12,a4),a3
	btst	#$5,($38,a3)
	beq.s	.l3CCAA
	bra.w	.l3CD04
.l3CCAA:
	move.l	($C,a2),d0
	cmp.l	($1A,a4),d0
	bne.s	.l3CCC8
	move.w	($22,a4),d0
	cmp.w	($10,a2),d0
	bgt.s	.l3CCC6
	move.w	d2,d0
	add.w	d0,($3C,a4)
	addq.w	#1,(a1)
.l3CCC6:
	bra.s	.l3CD04
.l3CCC8:
	cmp.l	($1A,a4),d5
	bne.s	.l3CD04
	movea.l	($1A,a4),a3
	movea.l	($8,a3),a0
	move.w	($8,a0),d4
	ext.l	d4
	move.w	($10,a2),d0
	ext.l	d0
	add.l	d0,d4
	move.w	($22,a4),d1
	ext.l	d1
	sub.l	d1,d4
	tst.l	d4
	ble.s	.l3CD04
	moveq	#$0,d1
	move.w	($12,a2),d1
	move.l	d1,d0
	cmp.l	d4,d0
	bcs.s	.l3CD04
	move.w	d2,d0
	add.w	d0,($3C,a4)
	addq.w	#1,(a1)
.l3CD04:
	movea.l	d6,a4
.l3CD06:
	cmpa.l	d3,a4
	bne.s	.l3CC96
.l3CD0A:
	movem.l	(-$20,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_3CD14:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#sub_3CEFA,a2
	pea	ram_FFDD86
	jsr	(a2)
	pea	ram_FFDD96
	jsr	(a2)
	pea	ram_FFDDA6
	jsr	(a2)
	pea	ram_FFDDB6
	jsr	(a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_3CD4C:
	link	a6,#$0
	movem.l	a2-a3,-(sp)
	movea.l	#ram_FFDD86,a2
	pea	io_FF440C
	pea	io_FF4400
	jsr	sub_2EFFE
	move.b	d0,ram_FFDDC8
	move.b	#$FF,ram_FFDDC6
	jsr	sub_3CD14
	tst.b	ram_FFDDC8
	addq.l	#8,sp
	beq.s	.l3CDBE
	clr.w	d1
	movea.l	a2,a0
	movea.l	#io_FF4400,a3
	movea.l	#io_FF4404,a2
	movea.l	#io_FF4408,a1
.l3CDA0:
	move.b	(a3),($A,a0)
	move.b	(a2),($3,a0)
	move.b	(a1),($4,a0)
	addq.w	#1,d1
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	moveq	#$10,d0
	adda.l	d0,a0
	cmpi.w	#$4,d1
	blt.s	.l3CDA0
.l3CDBE:
	movem.l	(-$8,a6),a2-a3
	unlk	a6
	rts
sub_3CDC8:
	link	a6,#$0
	movem.l	d2-d5/a2-a4,-(sp)
	movea.l	#ram_FFDD86,a1
	clr.w	d5
	lea	($A,a1),a4
	lea	($3,a1),a3
	lea	($4,a1),a2
	move.l	#$FF4400,d3
	move.l	#$FF4404,d2
	move.l	#$FF4408,d4
.l3CDF6:
	pea	$1.w
	move.l	d3,-(sp)
	move.l	a4,-(sp)
	jsr	copy_to_zram
	pea	$1.w
	move.l	d2,-(sp)
	move.l	a3,-(sp)
	jsr	copy_to_zram
	pea	$1.w
	move.l	d4,-(sp)
	move.l	a2,-(sp)
	jsr	copy_to_zram
	lea	($24,sp),sp
	addq.w	#1,d5
	addq.l	#1,d4
	addq.l	#1,d2
	addq.l	#1,d3
	moveq	#$10,d0
	adda.l	d0,a2
	moveq	#$10,d0
	adda.l	d0,a3
	moveq	#$10,d0
	adda.l	d0,a4
	cmpi.w	#$4,d5
	blt.s	.l3CDF6
	pea	io_FF440C
	pea	io_FF4400
	jsr	sub_2EFB6
	move.b	#$1,ram_FFDDC8
	addq.l	#8,sp
	movem.l	(-$1C,a6),d2-d5/a2-a4
	unlk	a6
	rts
sub_3CE64:
	link	a6,#$0
	move.b	#$FF,ram_FFDDC6
	jsr	sub_3CD14
	jsr	sub_3CDC8
	pea	$154.w
	jsr	sub_2DD10
	unlk	a6
	rts
sub_3CE8A:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	movea.l	#ram_FFDD86,a0
	moveq	#$1,d3
	moveq	#$10,d2
	moveq	#$4,d1
	moveq	#$0,d5
.l3CEA0:
	moveq	#$0,d0
	move.b	($4,a0),d0
	lsr.l	#4,d0
	sub.b	d0,($4,a0)
	moveq	#$0,d0
	move.b	($A,a0),d0
	lsr.l	#4,d0
	move.b	d0,d4
	tst.b	d4
	beq.s	.l3CEC0
	moveq	#$0,d0
	move.b	d4,d0
	bra.s	.l3CEC2
.l3CEC0:
	move.l	d3,d0
.l3CEC2:
	add.b	d0,($A,a0)
	move.b	($A,a0),d0
	cmp.b	($2,a0),d0
	bls.s	.l3CED8
	move.b	($A,a0),($2,a0)
	bra.s	.l3CEE8
.l3CED8:
	move.b	($4,a0),d0
	cmp.b	($2,a0),d0
	bcc.s	.l3CEE8
	move.b	($4,a0),($2,a0)
.l3CEE8:
	addq.l	#1,d5
	adda.l	d2,a0
	cmp.l	d1,d5
	blt.s	.l3CEA0
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3CEFA:
	link	a6,#$0
	movea.l	($8,a6),a0
	move.b	#$80,d0
	move.b	d0,($1,a0)
	move.b	d0,(a0)
	move.b	d0,($2,a0)
	move.b	#$80,d0
	move.b	d0,($8,a0)
	move.b	d0,($3,a0)
	move.b	#$92,d0
	move.b	d0,($4,a0)
	move.b	d0,($6,a0)
	moveq	#$6E,d0
	move.b	d0,($A,a0)
	move.b	d0,($C,a0)
	clr.b	d0
	move.b	d0,($B,a0)
	move.b	d0,($5,a0)
	unlk	a6
	rts
sub_3CF40:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.w	($A,a6),d2
	move.w	d2,d1
	movea.l	#$FFFF8000,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	move.l	d0,-(sp)
	move.w	d2,d0
	asl.w	#4,d0
	movea.l	#ram_FFDD86,a0
	pea	($0,a0,d0.w)
	jsr	sub_3D120
	move.w	d2,d0
	asl.w	#4,d0
	movea.l	#ram_FFDD86,a0
	pea	($0,a0,d0.w)
	jsr	sub_3D1A0
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_3CF8E:
	link	a6,#$FFF0
	movem.l	a2,-(sp)
	movea.l	#set_sr,a2
	pea	$2500.w
	jsr	(a2)
	move.w	d0,d1
	movea.l	#ram_FFDD86,a1
	lea	(-$10,a6),a0
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$1F.w
	pea	(-$10,a6)
	jsr	sub_3D254
	move.b	d0,ram_FFDD82
	pea	$2500.w
	jsr	(a2)
	move.w	d0,d1
	movea.l	#ram_FFDDA6,a1
	lea	(-$10,a6),a0
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$1F.w
	pea	(-$10,a6)
	jsr	sub_3D254
	move.b	d0,ram_FFDD84
	movem.l	(-$14,a6),a2
	unlk	a6
	rts
sub_3D012:
	link	a6,#$FFF0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	pea	$2500.w
	jsr	set_sr
	move.w	d0,d1
	move.w	d3,d0
	asl.w	#4,d0
	movea.l	#ram_FFDD86,a0
	adda.w	d0,a0
	lea	(-$10,a6),a1
	moveq	#$F,d0
.l3D040:
	move.b	(a0)+,(a1)+
	dbf	d0,.l3D040
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	set_sr
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(-$10,a6)
	jsr	sub_3D254
	movem.l	(-$18,a6),d2-d3
	unlk	a6
	rts
dat_3D06C:
	incbin	"../../build/stunrun-68k.bin",$3D06C,$24
dat_3D090:
	incbin	"../../build/stunrun-68k.bin",$3D090,$66
dat_3D0F6:
	incbin	"../../build/stunrun-68k.bin",$3D0F6,$2A
sub_3D120:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	movea.l	($8,a6),a0
	move.b	($F,a6),d0
	move.b	(a0),d1
	move.b	($1,a0),d3
	move.b	($2,a0),d4
	moveq	#$0,d1
	move.b	d0,d1
	moveq	#$0,d2
	move.b	d3,d2
	addq.l	#1,d2
	cmp.l	d2,d1
	bhi.s	.l3D158
	moveq	#$0,d1
	move.b	d0,d1
	moveq	#$0,d2
	move.b	d3,d2
	subq.l	#1,d2
	cmp.l	d2,d1
	bcs.s	.l3D158
	move.b	d3,d0
.l3D158:
	move.b	d3,d1
	move.b	d0,d3
	cmp.b	d4,d1
	bls.s	.l3D174
	cmp.b	d4,d3
	bls.s	.l3D174
	cmp.b	d3,d1
	bcc.s	.l3D16E
	moveq	#$0,d0
	move.b	d1,d0
	bra.s	.l3D172
.l3D16E:
	moveq	#$0,d0
	move.b	d3,d0
.l3D172:
	bra.s	.l3D18A
.l3D174:
	cmp.b	d4,d1
	bcc.s	.l3D18C
	cmp.b	d4,d3
	bcc.s	.l3D18C
	cmp.b	d3,d1
	bls.s	.l3D186
	moveq	#$0,d0
	move.b	d1,d0
	bra.s	.l3D18A
.l3D186:
	moveq	#$0,d0
	move.b	d3,d0
.l3D18A:
	move.b	d0,d4
.l3D18C:
	move.b	d1,(a0)
	move.b	d3,($1,a0)
	move.b	d4,($2,a0)
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_3D1A0:
	link	a6,#$0
	movea.l	($8,a6),a0
	move.b	($4,a0),d0
	cmp.b	($2,a0),d0
	bcc.s	.l3D1F4
	addq.b	#1,($5,a0)
	move.b	($2,a0),d0
	cmp.b	($6,a0),d0
	bcc.s	.l3D1C6
	move.b	($2,a0),($6,a0)
.l3D1C6:
	cmpi.b	#$6,($5,a0)
	bcs.s	.l3D1EC
	moveq	#$0,d0
	move.b	($6,a0),d0
	moveq	#$0,d1
	move.b	($4,a0),d1
	sub.l	d1,d0
	lsr.l	#1,d0
	add.b	d0,($4,a0)
	move.b	#$FF,($6,a0)
	clr.b	($5,a0)
.l3D1EC:
	move.b	($4,a0),($2,a0)
	bra.s	.l3D1FE
.l3D1F4:
	move.b	#$FF,($6,a0)
	clr.b	($5,a0)
.l3D1FE:
	move.b	($A,a0),d0
	cmp.b	($2,a0),d0
	bls.s	.l3D248
	addq.b	#1,($B,a0)
	move.b	($2,a0),d0
	cmp.b	($C,a0),d0
	bls.s	.l3D21C
	move.b	($2,a0),($C,a0)
.l3D21C:
	cmpi.b	#$6,($B,a0)
	bcs.s	.l3D240
	moveq	#$0,d0
	move.b	($A,a0),d0
	moveq	#$0,d1
	move.b	($C,a0),d1
	sub.l	d1,d0
	lsr.l	#1,d0
	sub.b	d0,($A,a0)
	clr.b	($C,a0)
	clr.b	($B,a0)
.l3D240:
	move.b	($A,a0),($2,a0)
	bra.s	.l3D250
.l3D248:
	clr.b	($C,a0)
	clr.b	($B,a0)
.l3D250:
	unlk	a6
	rts
sub_3D254:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d1
	move.w	($E,a6),d2
	tst.w	d2
	bge.s	.l3D282
	move.w	d2,d0
	ext.l	d0
	neg.l	d0
	add.l	d0,d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	jsr	sub_3D29A
	move.w	d2,d1
	ext.l	d1
	add.l	d1,d0
	bra.s	.l3D290
.l3D282:
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	jsr	sub_3D29A
.l3D290:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_3D29A:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	movea.l	($8,a6),a0
	move.w	($E,a6),d1
	addq.w	#1,d1
	move.b	($3,a0),d0
	cmp.b	($4,a0),d0
	bcc.s	.l3D2C0
	move.b	($A,a0),d0
	cmp.b	($3,a0),d0
	bcs.s	.l3D2CA
.l3D2C0:
	moveq	#$0,d0
	move.w	d1,d0
	lsr.l	#1,d0
	bra.w	.l3D338
.l3D2CA:
	move.b	($3,a0),d0
	cmp.b	($2,a0),d0
	bhi.s	.l3D2F8
	moveq	#$0,d0
	move.b	($4,a0),d0
	move.w	d0,d3
	moveq	#$0,d0
	move.b	($3,a0),d0
	sub.w	d0,d3
	moveq	#$0,d0
	move.b	($2,a0),d0
	move.w	d0,d2
	moveq	#$0,d0
	move.b	($3,a0),d0
	sub.w	d0,d2
	add.w	d3,d2
	bra.s	.l3D318
.l3D2F8:
	moveq	#$0,d0
	move.b	($3,a0),d0
	move.w	d0,d3
	moveq	#$0,d0
	move.b	($A,a0),d0
	sub.w	d0,d3
	moveq	#$0,d0
	move.b	($2,a0),d0
	move.w	d0,d2
	moveq	#$0,d0
	move.b	($A,a0),d0
	sub.w	d0,d2
.l3D318:
	moveq	#$0,d0
	move.w	d3,d0
	add.l	d0,d0
	move.w	d0,d3
	tst.w	d2
	beq.s	.l3D326
	subq.w	#1,d2
.l3D326:
	moveq	#$0,d0
	move.w	d2,d0
	lsl.l	#8,d0
	divs.w	d3,d0
	move.w	d0,d2
	moveq	#$0,d0
	move.w	d2,d0
	mulu.w	d1,d0
	lsr.l	#8,d0
.l3D338:
	move.w	d0,d1
	moveq	#$0,d0
	move.w	d1,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_3D348:
	link	a6,#$FFD8
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a2
	movea.l	#sub_229E4,a3
	movea.l	($1A,a2),a0
	movea.l	($C,a0),a4
	movea.l	($12,a2),a0
	move.l	($8,a0),(-$E,a6)
	movea.l	($12,a2),a0
	move.l	($C,a0),(-$A,a6)
	movea.l	($12,a2),a0
	move.l	($10,a0),(-$6,a6)
	moveq	#$0,d2
	move.l	d2,(-$1E,a6)
	move.l	d2,(-$26,a6)
	clr.w	d5
	move.w	($10,a2),d0
	cmpi.w	#$7,d0
	bcs.s	loc_3D3BA
.l3D396:
	cmpi.w	#$A,d0
	bhi.s	loc_3D3BA
	add.w	d0,d0
	move.w	(.l3D396+2,pc,d0.w),d0
	jmp	(.l3D3A6,pc,d0.w)
.l3D3A6:
	dc.w	sub_3D3B0-.l3D3A6
	dc.w	sub_3D3B0-.l3D3A6
	dc.w	sub_3D3AE-.l3D3A6
	dc.w	sub_3D3B0-.l3D3A6
sub_3D3AE:
	moveq	#$1,d5
sub_3D3B0:
	moveq	#$0,d2
	move.w	dat_4E1F0,d2
	bra.s	loc_3D3C2
loc_3D3BA:
	moveq	#$0,d2
	move.w	dat_4E1EE,d2
loc_3D3C2:
	move.l	d2,(-$22,a6)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	(-$1A,a6)
	pea	(-$26,a6)
	jsr	sub_22BA8
	move.w	($18,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($1E,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$26,a6)
	move.w	($1E,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($1E,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$22,a6)
	move.w	($24,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($1E,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$1E,a6)
	move.l	(-$1A,a6),d2
	add.l	(-$26,a6),d2
	move.l	d2,(-$1A,a6)
	move.l	(-$16,a6),d2
	add.l	(-$22,a6),d2
	move.l	d2,(-$16,a6)
	move.l	(-$12,a6),d2
	add.l	(-$1E,a6),d2
	move.l	d2,(-$12,a6)
	move.w	($16,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	dat_4E1F2,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$26,a6)
	move.w	($1C,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	dat_4E1F2,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$22,a6)
	move.w	($22,a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	dat_4E1F2,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	(a3)
	move.l	d0,(-$1E,a6)
	move.w	($10,a2),d0
	asl.w	#2,d0
	movea.l	#dat_4E3D8,a0
	move.l	($0,a0,d0.w),d4
	lea	($3C,sp),sp
	bra.w	.l3D5EA
.l3D4A2:
	jsr	sub_2EA34
	move.l	d0,d3
	bne.s	.l3D4B0
	bra.w	.l3D5F2
.l3D4B0:
	movea.l	($12,a2),a0
	pea	($14,a0)
	move.l	(-$6,a6),-(sp)
	move.l	(-$A,a6),-(sp)
	move.l	(-$E,a6),-(sp)
	moveq	#$0,d0
	movea.l	d4,a5
	move.b	(a5),d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	movea.l	d3,a5
	move.l	d0,($8,a5)
	movea.l	d3,a5
	move.l	($1A,a2),($C,a5)
	movea.l	d3,a5
	move.w	d5,($34,a5)
	moveq	#$0,d2
	move.w	dat_4E1F4,d2
	add.l	(-$1A,a6),d2
	moveq	#$0,d0
	move.w	dat_4E1F6,d0
	move.l	d0,-(sp)
	jsr	sub_23FBA
	sub.l	d0,d2
	movea.l	d3,a5
	move.l	d2,($10,a5)
	moveq	#$0,d2
	move.w	dat_4E1F4,d2
	add.l	(-$16,a6),d2
	moveq	#$0,d0
	move.w	dat_4E1F6,d0
	move.l	d0,-(sp)
	jsr	sub_23FBA
	sub.l	d0,d2
	movea.l	d3,a5
	move.l	d2,($14,a5)
	moveq	#$0,d2
	move.w	dat_4E1F4,d2
	add.l	(-$12,a6),d2
	moveq	#$0,d0
	move.w	dat_4E1F6,d0
	move.l	d0,-(sp)
	jsr	sub_23FBA
	sub.l	d0,d2
	movea.l	d3,a5
	move.l	d2,($18,a5)
	movea.l	d3,a5
	move.l	(-$26,a6),($1C,a5)
	movea.l	d3,a5
	move.l	(-$22,a6),($20,a5)
	movea.l	d3,a5
	move.l	(-$1E,a6),($24,a5)
	clr.w	(-$2,a6)
	movea.l	d3,a5
	lea	($28,a5),a3
	movea.l	d3,a5
	lea	($2E,a5),a4
	lea	($20,sp),sp
.l3D57E:
	pea	$18E3.w
	jsr	sub_23FBA
	move.w	d0,d6
	btst	#$0,d6
	addq.l	#4,sp
	beq.s	.l3D59A
	move.w	d6,d2
	ext.l	d2
	neg.l	d2
	bra.s	.l3D59E
.l3D59A:
	move.w	d6,d2
	ext.l	d2
.l3D59E:
	move.l	d2,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.w	d0,(a3)
	btst	#$0,d6
	beq.s	.l3D5B8
	move.w	d6,d2
	ext.l	d2
	neg.l	d2
	bra.s	.l3D5BC
.l3D5B8:
	move.w	d6,d2
	ext.l	d2
.l3D5BC:
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.w	d0,(a4)
	addq.w	#1,(-$2,a6)
	addq.l	#2,a4
	addq.l	#2,a3
	cmpi.w	#$3,(-$2,a6)
	blt.s	.l3D57E
	move.l	d3,-(sp)
	pea	ram_FFDADE
	jsr	sub_2E7C4
	addq.l	#8,sp
	addq.l	#1,d4
.l3D5EA:
	movea.l	d4,a0
	tst.b	(a0)
	bne.w	.l3D4A2
.l3D5F2:
	move.b	#$1,ram_FFDC1C
	movem.l	(-$4C,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3D604:
	link	a6,#$FFE8
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a1
	move.l	#sub_23FBA,d3
	move.l	(a1),(-$C,a6)
	movea.l	a1,a0
	addq.l	#4,a0
	move.l	(a0),(-$8,a6)
	movea.l	a1,a0
	addq.l	#8,a0
	move.l	(a0),(-$4,a6)
	moveq	#$0,d2
	move.l	d2,(-$10,a6)
	move.l	d2,(-$18,a6)
	move.w	dat_4E1F2,d2
	ext.l	d2
	move.l	d2,(-$14,a6)
	pea	$9.w
	movea.l	d3,a2
	jsr	(a2)
	asl.w	#2,d0
	movea.l	#dat_4E3B4,a0
	move.l	($0,a0,d0.w),d4
	addq.l	#4,sp
	bra.w	.l3D7A8
.l3D65A:
	jsr	sub_2EA34
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l3D66C
	bra.w	.l3D7B0
.l3D66C:
	pea	ram_FFDB04
	move.l	(-$4,a6),-(sp)
	move.l	(-$8,a6),-(sp)
	move.l	(-$C,a6),-(sp)
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,($8,a4)
	movea.l	d4,a2
	cmpi.w	#$108,(a2)
	lea	($14,sp),sp
	bne.s	.l3D6B6
	move.w	#$4,($34,a4)
	moveq	#$0,d2
	move.l	d2,($18,a4)
	move.l	d2,d0
	move.l	d0,($14,a4)
	move.l	d0,($10,a4)
	bra.w	.l3D796
.l3D6B6:
	pea	$C.w
	movea.l	d3,a5
	jsr	(a5)
	move.l	d0,d2
	moveq	#$18,d0
	add.l	d0,d2
	move.w	d2,($34,a4)
	moveq	#$0,d0
	move.w	dat_4E1F8,d0
	move.l	d0,d2
	moveq	#$0,d0
	move.w	dat_4E1FA,d0
	move.l	d0,-(sp)
	movea.l	d3,a5
	jsr	(a5)
	sub.l	d0,d2
	move.l	d2,($10,a4)
	moveq	#$0,d0
	move.w	dat_4E1F8,d0
	move.l	d0,d2
	moveq	#$0,d0
	move.w	dat_4E1FA,d0
	move.l	d0,-(sp)
	movea.l	d3,a5
	jsr	(a5)
	sub.l	d0,d2
	move.l	d2,($14,a4)
	moveq	#$0,d0
	move.w	dat_4E1F8,d0
	move.l	d0,d2
	moveq	#$0,d0
	move.w	dat_4E1FA,d0
	move.l	d0,-(sp)
	movea.l	d3,a5
	jsr	(a5)
	sub.l	d0,d2
	move.l	d2,($18,a4)
	move.l	(-$18,a6),($1C,a4)
	move.l	(-$14,a6),($20,a4)
	move.l	(-$10,a6),($24,a4)
	clr.w	d6
	lea	($28,a4),a2
	lea	($2E,a4),a3
	lea	($10,sp),sp
.l3D742:
	pea	$18E3.w
	movea.l	d3,a5
	jsr	(a5)
	move.w	d0,d5
	btst	#$0,d5
	addq.l	#4,sp
	beq.s	.l3D75C
	move.w	d5,d2
	ext.l	d2
	neg.l	d2
	bra.s	.l3D760
.l3D75C:
	move.w	d5,d2
	ext.l	d2
.l3D760:
	move.l	d2,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.w	d0,(a2)
	btst	#$0,d5
	beq.s	.l3D77A
	move.w	d5,d2
	ext.l	d2
	neg.l	d2
	bra.s	.l3D77E
.l3D77A:
	move.w	d5,d2
	ext.l	d2
.l3D77E:
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.w	d0,(a3)
	addq.w	#1,d6
	addq.l	#2,a3
	addq.l	#2,a2
	cmpi.w	#$3,d6
	blt.s	.l3D742
.l3D796:
	move.l	a4,-(sp)
	pea	ram_FFDADE
	jsr	sub_2E7C4
	addq.l	#8,sp
	addq.l	#2,d4
.l3D7A8:
	movea.l	d4,a0
	tst.w	(a0)
	bne.w	.l3D65A
.l3D7B0:
	move.b	#$1,ram_FFDC1C
	movem.l	(-$3C,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3D7C2:
	link	a6,#$FFF4
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	#ram_FFDC1C,a4
	movea.l	ram_FFDADE,a3
	move.l	#$FFDBEE,d5
	move.l	#$FFDBF6,d4
	move.l	#$FFDADE,d3
	movea.l	#ram_FFDBEE,a2
	bra.w	.l3D9EC
.l3D7F2:
	move.l	(a3),d6
	movea.l	($8,a3),a0
	movea.l	($8,a3),a1
	move.l	($8,a1),d2
	add.l	($10,a3),d2
	move.l	d2,($8,a0)
	movea.l	($8,a3),a0
	movea.l	($8,a3),a1
	move.l	($C,a1),d2
	add.l	($14,a3),d2
	move.l	d2,($C,a0)
	movea.l	($8,a3),a0
	movea.l	($8,a3),a1
	move.l	($10,a1),d2
	add.l	($18,a3),d2
	move.l	d2,($10,a0)
	movea.l	($8,a3),a0
	pea	($14,a0)
	move.w	($2E,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($28,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_2CDE6
	movea.l	($8,a3),a0
	pea	($14,a0)
	move.w	($30,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($2A,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_2CD5C
	movea.l	($8,a3),a0
	pea	($14,a0)
	move.w	($32,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($2C,a3),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_2CCD8
	movea.l	($8,a3),a0
	bset	#$6,($38,a0)
	pea	(-$C,a6)
	movea.l	($8,a3),a0
	pea	($8,a0)
	movea.l	($C,a3),a1
	move.l	($C,a1),-(sp)
	jsr	sub_3C136
	tst.l	(-$4,a6)
	lea	($30,sp),sp
	blt.s	.l3D8BE
	move.l	(-$4,a6),d0
	bra.s	.l3D8C4
.l3D8BE:
	move.l	(-$4,a6),d0
	neg.l	d0
.l3D8C4:
	movea.l	($C,a3),a0
	movea.l	($8,a0),a1
	move.w	($6,a1),d2
	ext.l	d2
	cmp.l	d0,d2
	bge.s	.l3D92E
	movea.l	($C,a3),a0
	move.l	(a0),($C,a3)
	cmp.l	($C,a3),d5
	beq.s	.l3D8F2
	move.l	(a2),d0
	cmp.l	($C,a3),d0
	beq.s	.l3D8F2
	cmp.l	($C,a3),d4
	bne.s	.l3D910
.l3D8F2:
	move.l	($8,a3),-(sp)
	jsr	sub_2E872
	move.l	a3,-(sp)
	jsr	sub_2EA82
	move.b	#$1,(a4)
	moveq	#$0,d0
	addq.l	#8,sp
	bra.w	.l3D9F2
.l3D910:
	pea	(-$C,a6)
	movea.l	($8,a3),a0
	pea	($8,a0)
	movea.l	($C,a3),a1
	move.l	($C,a1),-(sp)
	jsr	sub_3C136
	lea	($C,sp),sp
.l3D92E:
	movea.l	($C,a3),a0
	movea.l	($8,a0),a1
	btst	#$7,($11,a1)
	beq.s	.l3D988
	cmpi.l	#$FFFFFA10,(-$8,a6)
	bge.s	.l3D962
	move.l	($8,a3),-(sp)
	jsr	sub_2E872
	move.l	a3,-(sp)
	jsr	sub_2EA82
	move.b	#$1,(a4)
	addq.l	#8,sp
	bra.s	.l3D986
.l3D962:
	move.l	($10,a3),d2
	add.l	($1C,a3),d2
	move.l	d2,($10,a3)
	move.l	($14,a3),d2
	add.l	($20,a3),d2
	move.l	d2,($14,a3)
	move.l	($18,a3),d2
	add.l	($24,a3),d2
	move.l	d2,($18,a3)
.l3D986:
	bra.s	.l3D9EA
.l3D988:
	tst.w	($34,a3)
	bne.s	.l3D9C6
	movea.l	($C,a3),a0
	movea.l	($8,a0),a1
	moveq	#$0,d2
	move.w	($A,a1),d2
	pea	(-$C,a6)
	jsr	sub_3C0CE
	cmp.l	d0,d2
	addq.l	#4,sp
	bcc.s	.l3D9C6
	move.l	($8,a3),-(sp)
	jsr	sub_2E872
	move.l	a3,-(sp)
	jsr	sub_2EA82
	move.b	#$1,(a4)
	addq.l	#8,sp
	bra.s	.l3D9EA
.l3D9C6:
	move.l	($10,a3),d2
	add.l	($1C,a3),d2
	move.l	d2,($10,a3)
	move.l	($14,a3),d2
	add.l	($20,a3),d2
	move.l	d2,($14,a3)
	move.l	($18,a3),d2
	add.l	($24,a3),d2
	move.l	d2,($18,a3)
.l3D9EA:
	movea.l	d6,a3
.l3D9EC:
	cmpa.l	d3,a3
	bne.w	.l3D7F2
.l3D9F2:
	movem.l	(-$2C,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_3D9FC:
	link	a6,#$0
	movem.l	d2-d4/a2-a4,-(sp)
	moveq	#$1,d2
	movea.l	ram_FFDADE,a4
	move.l	#$FFDADE,d3
	movea.l	#ram_FFDC1C,a3
	bra.w	loc_3DB9E
loc_3DA1C:
	move.l	(a4),d4
	subq.w	#1,($34,a4)
	bne.s	.l3DA3E
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA82
	move.b	d2,(a3)
	addq.l	#8,sp
	bra.w	loc_3DB9C
.l3DA3E:
	movea.l	($8,a4),a2
	movea.l	($26,a2),a0
	move.w	($4,a0),d0
	cmpi.w	#$108,d0
	blt.w	loc_3DAEC
	cmpi.w	#$10B,d0
	bgt.w	loc_3DAEC
	sub.w	#$108,d0
	add.w	d0,d0
	move.w	(.l3DA68,pc,d0.w),d0
	jmp	(.l3DA68,pc,d0.w)
.l3DA68:
	dc.w	sub_3DA70-.l3DA68
	dc.w	sub_3DA70-.l3DA68
	dc.w	sub_3DA70-.l3DA68
	dc.w	sub_3DAD2-.l3DA68
sub_3DA70:
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($8,a0),d0
	add.l	($10,a4),d0
	move.l	d0,($8,a2)
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($C,a0),d0
	add.l	($14,a4),d0
	move.l	d0,($C,a2)
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($10,a0),d0
	add.l	($18,a4),d0
	move.l	d0,($10,a2)
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	movea.l	($26,a0),a0
	move.w	($4,a0),d0
	ext.l	d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	addq.l	#4,sp
	bra.w	loc_3DB86
sub_3DAD2:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2EA82
	move.b	d2,(a3)
	addq.l	#8,sp
	bra.w	loc_3DB86
loc_3DAEC:
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($8,a0),d0
	add.l	($10,a4),d0
	move.l	d0,($8,a2)
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($C,a0),d0
	add.l	($14,a4),d0
	move.l	d0,($C,a2)
	movea.l	($8,a4),a2
	movea.l	($8,a4),a0
	move.l	($10,a0),d0
	add.l	($18,a4),d0
	move.l	d0,($10,a2)
	movea.l	($8,a4),a2
	pea	($14,a2)
	move.w	($2E,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($28,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($8,a4),a2
	pea	($14,a2)
	move.w	($30,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($2A,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	movea.l	($8,a4),a2
	pea	($14,a2)
	move.w	($32,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($2C,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	lea	($24,sp),sp
loc_3DB86:
	movea.l	($8,a4),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
loc_3DB9C:
	movea.l	d4,a4
loc_3DB9E:
	cmpa.l	d3,a4
	bne.w	loc_3DA1C
	movem.l	(-$18,a6),d2-d4/a2-a4
	unlk	a6
	rts
sub_3DBAE:
	link	a6,#$0
	movem.l	d2-d6/a2-a5,-(sp)
	moveq	#$1,d2
	move.l	ram_FFDAE6,d5
	move.l	#$FF9C94,d4
	move.l	#$FFDAE6,d3
	movea.l	#ram_FF9C80,a3
	movea.l	#ram_FFDC1C,a4
	bra.w	.l3DCAC
.l3DBDA:
	movea.l	d5,a0
	move.l	(a0),d6
	movea.l	d5,a0
	cmpi.w	#$5,($2A,a0)
	blt.s	.l3DC02
	movea.l	d5,a2
	move.l	($8,a2),-(sp)
	jsr	sub_2E872
	move.l	d5,-(sp)
	jsr	sub_2EA82
	addq.l	#8,sp
	bra.w	.l3DCA8
.l3DC02:
	movea.l	d5,a5
	movea.l	($8,a5),a2
	movea.l	d5,a5
	move.w	($2A,a5),d0
	ext.l	d0
	movea.l	d5,a5
	move.w	($28,a5),d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	d5,a5
	movea.l	($8,a5),a2
	pea	($14,a2)
	move.l	d4,-(sp)
	jsr	sub_22DD6
	movea.l	d5,a5
	movea.l	($8,a5),a2
	move.l	($8,a3),($8,a2)
	movea.l	d5,a5
	movea.l	($8,a5),a2
	move.l	($C,a3),($C,a2)
	movea.l	d5,a5
	movea.l	($8,a5),a2
	move.l	($10,a3),($10,a2)
	movea.l	d5,a5
	move.w	($2E,a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d5,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2D172
	movea.l	d5,a5
	move.w	($30,a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d5,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2D110
	movea.l	d5,a5
	move.w	($32,a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d5,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2D0AE
	movea.l	d5,a5
	addq.w	#1,($2A,a5)
	lea	($24,sp),sp
.l3DCA8:
	move.b	d2,(a4)
	move.l	d6,d5
.l3DCAC:
	cmp.l	d3,d5
	bne.w	.l3DBDA
	movem.l	(-$24,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3DCBC:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	move.w	($A,a6),d4
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	jsr	sub_2EA34
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l3DCE4
	moveq	#$0,d0
	bra.w	.l3DD84
.l3DCE4:
	clr.l	($C,a2)
	move.w	d3,($2E,a2)
	move.w	d2,($30,a2)
	move.w	($16,a6),($32,a2)
	cmpi.w	#$2,d4
	bge.s	.l3DD12
	move.w	d4,d0
	ext.l	d0
	move.l	d0,d1
	asl.l	#2,d0
	add.l	d1,d0
	addi.l	#$FE,d0
	move.w	d0,($28,a2)
	bra.s	.l3DD18
.l3DD12:
	move.w	#$A4,($28,a2)
.l3DD18:
	clr.w	($2A,a2)
	pea	ram_FF9C94
	move.w	($16,a6),d0
	ext.l	d0
	add.l	ram_FF9C90,d0
	move.l	d0,-(sp)
	move.l	ram_FF9C8C,d1
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	ram_FF9C88,d0
	ext.l	d3
	add.l	d3,d0
	move.l	d0,-(sp)
	move.w	($2A,a2),d0
	ext.l	d0
	move.w	($28,a2),d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,($8,a2)
	movea.l	($8,a2),a0
	move.w	#$FC60,($36,a0)
	move.l	a2,-(sp)
	pea	ram_FFDAE6
	jsr	sub_2E7C4
	move.b	#$1,ram_FFDC1C
.l3DD84:
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_3DD8E:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.l	($8,a6),d2
	move.b	($F,a6),d0
	tst.b	d0
	beq.s	.l3DDA6
	moveq	#$2,d0
	bra.s	.l3DDA8
.l3DDA6:
	moveq	#$0,d0
.l3DDA8:
	move.b	d0,ram_FFDDD4
	clr.b	d3
	movea.l	#dat_4E95C,a2
	bra.s	.l3DDC8
.l3DDB8:
	move.l	d2,-(sp)
	move.l	(a2),-(sp)
	jsr	sub_3DDE8
	or.b	d0,d3
	addq.l	#8,sp
	addq.l	#4,a2
.l3DDC8:
	movea.l	(a2),a0
	tst.b	(a0)
	bne.s	.l3DDB8
	move.l	d2,-(sp)
	jsr	sub_3DEDA
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	addq.l	#4,sp
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3DDE8:
	link	a6,#$0
	movem.l	a2-a4,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a0
	move.l	a1,ram_FFDDCA
.l3DDFE:
	tst.b	(a0)
	bne.s	.l3DE08
	moveq	#$0,d0
	bra.w	.l3DED0
.l3DE08:
	move.b	(a1),d0
	cmp.b	(a0),d0
	bne.s	.l3DE10
	bra.s	.l3DE14
.l3DE10:
	addq.l	#1,a0
	bra.s	.l3DDFE
.l3DE14:
	move.l	a0,ram_FFDDCE
.l3DE1A:
	move.b	(a1),d0
	cmp.b	(a0),d0
	bne.s	.l3DE24
	addq.l	#1,a0
	bra.s	.l3DE1A
.l3DE24:
	movea.l	#WATCHDOG,a3
	movea.l	#ram_FFDDD4,a4
.l3DE30:
	moveq	#$20,d1
	clr.w	(a3)
.l3DE34:
	addq.l	#1,a1
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d1,d0
	beq.s	.l3DE34
	tst.b	(a1)
	bne.s	.l3DE48
	bra.w	.l3DEA6
.l3DE48:
	moveq	#$0,d0
	move.b	(a4),d0
	move.w	d0,ram_FFDDD2
.l3DE52:
	moveq	#$20,d1
.l3DE54:
	move.b	(a0),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d1,d0
	bne.s	.l3DE62
	addq.l	#1,a0
	bra.s	.l3DE54
.l3DE62:
	move.b	(a1),d0
	cmp.b	(a0),d0
	bne.s	.l3DE6A
	bra.s	.l3DE9A
.l3DE6A:
	tst.b	(a0)
	beq.s	.l3DE76
	tst.w	ram_FFDDD2
	bne.s	.l3DE90
.l3DE76:
	movea.l	ram_FFDDCE,a2
	addq.l	#1,a2
	move.l	a2,-(sp)
	move.l	ram_FFDDCA,-(sp)
	jsr	sub_3DDE8
	addq.l	#8,sp
	bra.s	.l3DED0
.l3DE90:
	addq.l	#1,a0
	subq.w	#1,ram_FFDDD2
	bra.s	.l3DE52
.l3DE9A:
	move.b	(a1),d0
	cmp.b	(a0),d0
	bne.s	.l3DEA4
	addq.l	#1,a0
	bra.s	.l3DE9A
.l3DEA4:
	bra.s	.l3DE30
.l3DEA6:
	moveq	#$2A,d0
.l3DEA8:
	cmpa.l	ram_FFDDCE,a0
	bls.s	.l3DEBE
	movea.l	#ram_FFDDCE,a1
	movea.l	(a1),a2
	addq.l	#1,(a1)
	move.b	d0,(a2)
	bra.s	.l3DEA8
.l3DEBE:
	move.l	a0,-(sp)
	move.l	ram_FFDDCA,-(sp)
	jsr	sub_3DDE8
	moveq	#$1,d0
	addq.l	#8,sp
.l3DED0:
	movem.l	(-$C,a6),a2-a4
	unlk	a6
	rts
sub_3DEDA:
	link	a6,#$0
	movea.l	($8,a6),a0
	moveq	#$20,d1
	movea.l	a0,a1
.l3DEE6:
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d1,d0
	bne.s	.l3DEF4
	addq.l	#1,a1
	bra.s	.l3DEE6
.l3DEF4:
	move.b	(a1)+,(a0)+
	bne.s	.l3DEF4
	unlk	a6
	rts
sub_3DEFC:
	link	a6,#$0
	movem.l	a2-a3,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a2
	move.l	($10,a6),d0
	movea.l	a1,a3
	tst.l	d0
	ble.s	.l3DF20
	movea.l	d0,a0
	subq.l	#1,a0
	adda.l	a3,a0
	clr.b	(a0)
	bra.s	.l3DF22
.l3DF20:
	clr.b	(a3)
.l3DF22:
	subq.l	#1,d0
	ble.s	.l3DF2A
	move.b	(a2)+,(a1)+
	bne.s	.l3DF22
.l3DF2A:
	move.l	a3,d0
	movem.l	(-$8,a6),a2-a3
	unlk	a6
	rts
sub_3DF36:
	link	a6,#$0
	movem.l	d2-d4/a2-a3,-(sp)
	move.l	($8,a6),d3
	move.l	($C,a6),d4
	move.l	($10,a6),d0
	subq.l	#1,d0
	asl.l	#3,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	move.l	d0,d1
	add.l	d4,d1
	movea.l	d1,a2
	cmp.l	(a2),d3
	bge.s	.l3DF66
	moveq	#$0,d0
	movea.l	d0,a3
	bra.w	.l3E030
.l3DF66:
	moveq	#$18,d2
	movea.l	a2,a3
	moveq	#$18,d0
	suba.l	d0,a2
	bra.s	.l3DF8C
.l3DF70:
	move.l	d2,-(sp)
	move.l	a3,d1
	moveq	#$18,d0
	suba.l	d0,a3
	move.l	d1,-(sp)
	movea.l	a2,a0
	moveq	#$18,d0
	suba.l	d0,a2
	move.l	a0,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3DF8C:
	cmpa.l	d4,a2
	bcs.s	.l3DF94
	cmp.l	(a2),d3
	bge.s	.l3DF70
.l3DF94:
	move.b	#$14,ram_FFDDE8
	move.l	$FFFF8014,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	addi.l	#$3A98,d0
	move.l	d0,ram_FFDDF0
	tst.b	ram_FF950E
	beq.s	.l3DFD6
	pea	ram_FFDE42
	pea	ram_FFDDFC
	jsr	sub_2E4B4
	addq.l	#8,sp
	bra.s	.l3DFF0
.l3DFD6:
	clr.b	d0
	move.b	d0,ram_FFDDFF
	move.b	d0,ram_FFDDFE
	move.b	d0,ram_FFDDFD
	move.b	d0,ram_FFDDFC
.l3DFF0:
	move.l	d3,ram_FFDDF8
	pea	$18.w
	move.l	a3,-(sp)
	pea	ram_FFDDF8
	jsr	copy_to_zram
	jsr	sub_3FA4A
	move.l	#$FFDDFC,ram_FFDDF4
	clr.w	ram_FFDE56
	moveq	#$E,d0
	move.w	d0,ram_FFDDEA
	move.w	d0,ram_FFDE58
	lea	($C,sp),sp
.l3E030:
	move.l	a3,d0
	movem.l	(-$14,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_3E03C:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	($8,a6),a2
	move.l	($C,a6),d0
	movea.l	#ram_FFDBDE,a3
	move.l	(a2),ram_FFDBE2
	subq.l	#1,d0
	asl.l	#2,d0
	move.l	d0,d1
	asl.l	#3,d0
	sub.l	d1,d0
	move.l	d0,d1
	add.l	a2,d1
	movea.l	d1,a4
	move.l	(a3),d1
	cmp.l	(a4),d1
	bcc.s	.l3E074
	moveq	#$0,d3
	bra.w	.l3E154
.l3E074:
	moveq	#$1C,d2
	move.l	a4,d3
	moveq	#$1C,d0
	suba.l	d0,a4
	bra.s	.l3E09A
.l3E07E:
	move.l	d2,-(sp)
	move.l	d3,d1
	moveq	#$1C,d0
	sub.l	d0,d3
	move.l	d1,-(sp)
	movea.l	a4,a0
	moveq	#$1C,d0
	suba.l	d0,a4
	move.l	a0,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3E09A:
	cmpa.l	a2,a4
	bcs.s	.l3E0A4
	move.l	(a3),d1
	cmp.l	(a4),d1
	bcc.s	.l3E07E
.l3E0A4:
	move.b	#$14,ram_FFDDE8
	move.l	$FFFF8014,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	addi.l	#$3A98,d0
	move.l	d0,ram_FFDDF0
	tst.b	ram_FF950E
	beq.s	.l3E0E6
	pea	ram_FFDE42
	pea	ram_FFDE18
	jsr	sub_2E4B4
	addq.l	#8,sp
	bra.s	.l3E100
.l3E0E6:
	clr.b	d0
	move.b	d0,ram_FFDE1B
	move.b	d0,ram_FFDE1A
	move.b	d0,ram_FFDE19
	move.b	d0,ram_FFDE18
.l3E100:
	move.l	(a3),ram_FFDE10
	move.w	ram_FFDBE6,ram_FFDE14
	move.w	ram_FFDC00,ram_FFDE16
	pea	$1C.w
	move.l	d3,-(sp)
	pea	ram_FFDE10
	jsr	copy_to_zram
	jsr	sub_3FA64
	move.l	#$FFDE18,ram_FFDDF4
	clr.w	ram_FFDE56
	moveq	#$E,d0
	move.w	d0,ram_FFDDEA
	move.w	d0,ram_FFDE58
	lea	($C,sp),sp
.l3E154:
	move.l	d3,d0
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_3E160:
	link	a6,#$0
	movem.l	d2-d4/a2-a3,-(sp)
	move.w	($A,a6),d3
	move.l	($C,a6),d4
	move.l	($10,a6),d1
	subq.l	#1,d1
	move.l	d1,d2
	move.l	d2,d0
	mulu.w	#$16,d1
	swap	d2
	mulu.w	#$16,d2
	moveq	#$0,d0
	add.l	d2,d0
	swap	d0
	clr.w	d0
	add.l	d0,d1
	move.l	d1,d0
	add.l	d4,d0
	movea.l	d0,a2
	cmp.w	(a2),d3
	bge.s	.l3E1A0
	moveq	#$0,d0
	movea.l	d0,a3
	bra.w	.l3E28A
.l3E1A0:
	moveq	#$16,d2
	movea.l	a2,a3
	moveq	#$16,d0
	suba.l	d0,a2
	bra.s	.l3E1C6
.l3E1AA:
	move.l	d2,-(sp)
	move.l	a3,d0
	moveq	#$16,d1
	suba.l	d1,a3
	move.l	d0,-(sp)
	movea.l	a2,a0
	moveq	#$16,d0
	suba.l	d0,a2
	move.l	a0,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3E1C6:
	cmpa.l	d4,a2
	bcs.s	.l3E1CE
	cmp.w	(a2),d3
	bge.s	.l3E1AA
.l3E1CE:
	move.b	#$14,ram_FFDDE8
	move.l	$FFFF8014,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	addi.l	#$3A98,d0
	move.l	d0,ram_FFDDF0
	tst.b	ram_FF950E
	beq.s	.l3E210
	pea	ram_FFDE42
	pea	ram_FFDE2E
	jsr	sub_2E4B4
	addq.l	#8,sp
	bra.s	.l3E22A
.l3E210:
	clr.b	d0
	move.b	d0,ram_FFDE31
	move.b	d0,ram_FFDE30
	move.b	d0,ram_FFDE2F
	move.b	d0,ram_FFDE2E
.l3E22A:
	move.w	d3,ram_FFDE2C
	pea	$16.w
	move.l	a3,-(sp)
	pea	ram_FFDE2C
	jsr	copy_to_zram
	cmp.l	#$FF45B6,d4
	lea	($C,sp),sp
	bne.s	.l3E256
	jsr	sub_3FA7E
	bra.s	.l3E26C
.l3E256:
	cmp.l	#$FF4626,d4
	bne.s	.l3E266
	jsr	sub_3FA98
	bra.s	.l3E26C
.l3E266:
	jsr	sub_3FAB2
.l3E26C:
	move.l	#$FFDE2E,ram_FFDDF4
	clr.w	ram_FFDE56
	moveq	#$E,d0
	move.w	d0,ram_FFDDEA
	move.w	d0,ram_FFDE58
.l3E28A:
	move.l	a3,d0
	movem.l	(-$14,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_3E296:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d3
	move.l	($10,a6),d4
	movea.l	#sub_2F470,a2
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	move.l	d2,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d3,-(sp)
	move.l	d2,-(sp)
	jsr	(a2)
	move.l	d4,-(sp)
	move.l	d3,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d2,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d3,-(sp)
	move.l	d2,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	jsr	(a2)
	move.l	d4,-(sp)
	move.l	d3,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	move.l	d3,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d2,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	jsr	(a2)
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	move.l	d2,-(sp)
	move.l	d3,d1
	moveq	#$10,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	jsr	(a2)
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_3E31A:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d1
	move.l	($10,a6),d0
	pea	$1.w
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	pea	dat_4E408
	jsr	sub_2F2CC
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_3E34E:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a4,-(sp)
	move.w	($A,a6),d5
	move.w	($E,a6),d6
	moveq	#$17,d2
	moveq	#$1,d3
	clr.b	(-$3,a6)
	clr.w	d0
	movea.w	d0,a4
	moveq	#$0,d4
	movea.l	#str_4EDA8,a3
	lea	(-$4,a6),a2
.l3E376:
	move.b	(a3),(a2)
	move.l	d4,d0
	divs.w	#$1D,d0
	move.w	d0,(-$2,a6)
	addq.w	#8,(-$2,a6)
	cmpa.w	d6,a4
	bne.s	.l3E3C0
	move.l	d3,-(sp)
	move.l	d2,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2F2CC
	move.l	d2,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_3E296
	lea	($20,sp),sp
	bra.s	.l3E3E0
.l3E3C0:
	move.l	d3,-(sp)
	pea	$11.w
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2F2CC
	lea	($14,sp),sp
.l3E3E0:
	addq.w	#1,a4
	addq.l	#1,a3
	addi.l	#$1F0,d4
	move.l	a4,d0
	cmpi.w	#$1D,d0
	blt.s	.l3E376
	movem.l	(-$24,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_3E3FC:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	movea.l	#sub_2F470,a2
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#6,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#3,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#3,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	subq.l	#6,d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	jsr	(a2)
	pea	$10.w
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	subq.l	#3,d0
	move.l	d0,-(sp)
	ext.l	d3
	subq.l	#6,d3
	move.l	d3,-(sp)
	jsr	(a2)
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3E51C:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d2
	movea.l	#ram_FFDE58,a2
	pea	$1F0.w
	clr.l	-(sp)
	jsr	sub_3D012
	move.w	d0,d3
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#8,d0
	move.l	d0,-(sp)
	jsr	sub_3E3FC
	move.w	(a2),d0
	ext.l	d0
	asl.l	#4,d0
	move.l	d0,d2
	asl.l	#5,d0
	sub.l	d2,d0
	divs.w	#$1D,d0
	addq.w	#8,d0
	cmp.w	d0,d3
	ble.s	.l3E56E
	move.w	d3,d0
	ext.l	d0
	subq.l	#4,d0
	bra.s	.l3E574
.l3E56E:
	move.w	d3,d0
	ext.l	d0
	addq.l	#4,d0
.l3E574:
	move.l	d0,d2
	asl.l	#2,d0
	move.l	d0,d1
	asl.l	#3,d0
	sub.l	d1,d0
	add.l	d2,d0
	move.l	#$1F0,d1
	jsr	sub_23E70
	move.w	d0,(a2)
	tst.w	(a2)
	bge.s	.l3E596
	clr.w	(a2)
	bra.s	.l3E5A0
.l3E596:
	cmpi.w	#$1C,(a2)
	ble.s	.l3E5A0
	move.w	#$1C,(a2)
.l3E5A0:
	move.w	(a2),d0
	cmp.w	ram_FFDDEA,d0
	beq.s	.l3E5B4
	pea	$34.w
	jsr	queue_sound_command
.l3E5B4:
	move.w	(a2),ram_FFDDEA
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3E5C4:
	link	a6,#$FF9C
	movem.l	d2-d5/a2,-(sp)
	move.l	($8,a6),d0
	move.l	($C,a6),d2
	moveq	#$0,d5
	movea.l	#ram_FFDDF4,a2
	move.b	BUTTONS+$1,d1
	andi.b	#$3,d1
	move.b	ram_FFDDE6,d4
	move.b	d1,d0
	eor.b	d0,d4
	and.b	ram_FFDDE6,d4
	move.b	d1,ram_FFDDE6
	jsr	sub_2C618
	pea	$20.w
	pea	$F8.w
	clr.l	-(sp)
	pea	$1.w
	jsr	sub_2F88A
	tst.b	ram_FF950E
	beq.s	.l3E67A
	pea	$1.w
	pea	$13.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E40A
	jsr	sub_2F8E0
	pea	$1.w
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E426
	jsr	sub_2F8E0
	moveq	#$8,d3
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d3
	clr.l	-(sp)
	pea	$58.w
	pea	$1D.w
	bra.w	.l3E866
.l3E67A:
	pea	$1.w
	pea	$17.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E43A
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E454
	jsr	sub_2F8E0
	moveq	#$14,d3
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d3
	move.l	d3,-(sp)
	pea	dat_4E48C
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$10.w
	pea	$4A.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2F8E0
	pea	$FE.w
	jsr	sub_3E51C
	movea.l	(a2),a0
	move.w	ram_FFDE58,d0
	movea.l	#str_4EDA8,a1
	move.b	($0,a1,d0.w),(a0)
	tst.b	ram_FFDDE8
	beq.s	.l3E71E
	subq.b	#1,ram_FFDDE8
	clr.b	d4
.l3E71E:
	tst.b	d4
	beq.w	.l3E7EE
	pea	$33.w
	jsr	queue_sound_command
	addi.l	#$9C4,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	cmp.l	$FFFF8014,d0
	ble.s	.l3E750
	move.l	$FFFF8014,ram_FFDDEC
.l3E750:
	move.l	ram_FFDDF0,d0
	cmp.l	ram_FFDDEC,d0
	bge.s	.l3E768
	move.l	ram_FFDDF0,ram_FFDDEC
.l3E768:
	movea.l	(a2),a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$2,d0
	blt.s	.l3E7B4
	bgt.s	.l3E778
	bra.s	.l3E78E
.l3E778:
	subq.w	#3,d0
	bne.s	.l3E7B4
	movea.l	(a2),a0
	clr.b	(a0)
	movea.l	#ram_FFDDFC,a0
	cmpa.l	(a2),a0
	bcc.s	.l3E78C
	subq.l	#1,(a2)
.l3E78C:
	bra.s	.l3E7EE
.l3E78E:
	movea.l	(a2),a0
	clr.b	(a0)
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDDFC
	jsr	sub_3DD8E
	moveq	#$1,d3
	moveq	#$1,d5
	bra.s	.l3E7EE
.l3E7B4:
	addq.l	#1,(a2)
	movea.l	(a2),a0
	addq.l	#1,a0
	clr.b	(a0)
	movea.l	#ram_FFDDFC,a0
	moveq	#$12,d0
	adda.l	d0,a0
	move.l	(a2),d0
	addq.l	#1,d0
	cmpa.l	d0,a0
	bhi.s	.l3E7EE
	moveq	#$1,d5
	moveq	#$1,d3
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDDFC
	jsr	sub_3DD8E
.l3E7EE:
	cmp.l	ram_FFDE5A,d3
	beq.s	.l3E800
	pea	$24.w
	jsr	queue_sound_command
.l3E800:
	tst.l	d3
	bgt.s	.l3E82E
	tst.b	ram_FF950E
	bne.s	.l3E812
	movea.l	(a2),a0
	move.b	#$20,(a0)
.l3E812:
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDDFC
	jsr	sub_3DD8E
.l3E82E:
	pea	$18.w
	move.l	d2,-(sp)
	pea	ram_FFDDF8
	jsr	copy_to_zram
	jsr	sub_3FA4A
	move.w	ram_FFDE58,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$100.w
	jsr	sub_3E34E
	pea	$10.w
	pea	$58.w
	pea	$17.w
.l3E866:
	pea	$12.w
	move.l	d2,-(sp)
	jsr	sub_3F008
	jsr	sub_2C820
	move.l	d3,ram_FFDE5A
	tst.l	d3
	bgt.s	.l3E884
	moveq	#$1,d5
.l3E884:
	tst.l	d5
	beq.s	.l3E8AA
	tst.b	ram_FFDDFC
	beq.s	.l3E8AA
	pea	ram_FFDDFC
	pea	ram_FFDE42
	jsr	sub_2E4B4
	move.b	#$1,ram_FF950E
.l3E8AA:
	move.l	d5,d0
	movem.l	(-$78,a6),d2-d5/a2
	unlk	a6
	rts
sub_3E8B6:
	link	a6,#$FF9C
	movem.l	d2-d5/a2,-(sp)
	move.l	($8,a6),d2
	moveq	#$0,d5
	movea.l	#ram_FFDDF4,a2
	move.b	BUTTONS+$1,d1
	andi.b	#$3,d1
	move.b	ram_FFDDE6,d4
	move.b	d1,d0
	eor.b	d0,d4
	and.b	ram_FFDDE6,d4
	move.b	d1,ram_FFDDE6
	jsr	sub_2C618
	pea	$20.w
	pea	$F8.w
	clr.l	-(sp)
	pea	$1.w
	jsr	sub_2F88A
	tst.b	ram_FF950E
	beq.s	.l3E974
	pea	$1.w
	pea	$13.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E490
	jsr	sub_2F8E0
	pea	$1.w
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E4AC
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$68.w
	pea	$1D.w
	pea	$12.w
	move.l	d2,-(sp)
	jsr	sub_3F15E
	moveq	#$8,d3
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d3
	bra.w	.l3EB6C
.l3E974:
	pea	$1.w
	pea	$17.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E4C2
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$13.w
	pea	$44.w
	pea	$100.w
	pea	str_4E4E2
	jsr	sub_2F8E0
	moveq	#$14,d3
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d3
	move.l	d3,-(sp)
	pea	dat_4E51A
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$10.w
	pea	$50.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2F8E0
	pea	$FE.w
	jsr	sub_3E51C
	movea.l	(a2),a0
	move.w	ram_FFDE58,d0
	movea.l	#str_4EDA8,a1
	move.b	($0,a1,d0.w),(a0)
	tst.b	ram_FFDDE8
	beq.s	.l3EA18
	subq.b	#1,ram_FFDDE8
	clr.b	d4
.l3EA18:
	tst.b	d4
	beq.w	.l3EAE8
	pea	$33.w
	jsr	queue_sound_command
	addi.l	#$9C4,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	cmp.l	$FFFF8014,d0
	ble.s	.l3EA4A
	move.l	$FFFF8014,ram_FFDDEC
.l3EA4A:
	move.l	ram_FFDDF0,d0
	cmp.l	ram_FFDDEC,d0
	bge.s	.l3EA62
	move.l	ram_FFDDF0,ram_FFDDEC
.l3EA62:
	movea.l	(a2),a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$2,d0
	blt.s	.l3EAAE
	bgt.s	.l3EA72
	bra.s	.l3EA88
.l3EA72:
	subq.w	#3,d0
	bne.s	.l3EAAE
	movea.l	(a2),a0
	clr.b	(a0)
	movea.l	#ram_FFDE18,a0
	cmpa.l	(a2),a0
	bcc.s	.l3EA86
	subq.l	#1,(a2)
.l3EA86:
	bra.s	.l3EAE8
.l3EA88:
	movea.l	(a2),a0
	clr.b	(a0)
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE18
	jsr	sub_3DD8E
	moveq	#$1,d3
	moveq	#$1,d5
	bra.s	.l3EAE8
.l3EAAE:
	addq.l	#1,(a2)
	movea.l	(a2),a0
	addq.l	#1,a0
	clr.b	(a0)
	movea.l	#ram_FFDE18,a0
	moveq	#$12,d0
	adda.l	d0,a0
	move.l	(a2),d0
	addq.l	#1,d0
	cmpa.l	d0,a0
	bhi.s	.l3EAE8
	moveq	#$1,d5
	moveq	#$1,d3
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE18
	jsr	sub_3DD8E
.l3EAE8:
	cmp.l	ram_FFDE5A,d3
	beq.s	.l3EAFA
	pea	$24.w
	jsr	queue_sound_command
.l3EAFA:
	tst.l	d3
	bgt.s	.l3EB28
	tst.b	ram_FF950E
	bne.s	.l3EB0C
	movea.l	(a2),a0
	move.b	#$20,(a0)
.l3EB0C:
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE18
	jsr	sub_3DD8E
.l3EB28:
	pea	$1C.w
	move.l	d2,-(sp)
	pea	ram_FFDE10
	jsr	copy_to_zram
	jsr	sub_3FA64
	move.w	ram_FFDE58,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$100.w
	jsr	sub_3E34E
	pea	$10.w
	pea	$68.w
	pea	$17.w
	pea	$12.w
	move.l	d2,-(sp)
	jsr	sub_3F15E
.l3EB6C:
	jsr	sub_2C820
	move.l	d3,ram_FFDE5A
	tst.l	d3
	bgt.s	.l3EB7E
	moveq	#$1,d5
.l3EB7E:
	tst.l	d5
	beq.s	.l3EBA4
	tst.b	ram_FFDE18
	beq.s	.l3EBA4
	pea	ram_FFDE18
	pea	ram_FFDE42
	jsr	sub_2E4B4
	move.b	#$1,ram_FF950E
.l3EBA4:
	move.l	d5,d0
	movem.l	(-$78,a6),d2-d5/a2
	unlk	a6
	rts
sub_3EBB0:
	link	a6,#$FF9C
	movem.l	d2-d6/a2,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d3
	move.w	($12,a6),d4
	movea.l	#ram_FFDDF4,a2
	move.b	BUTTONS+$1,d1
	andi.b	#$3,d1
	move.b	ram_FFDDE6,d6
	move.b	d1,d0
	eor.b	d0,d6
	and.b	ram_FFDDE6,d6
	move.b	d1,ram_FFDDE6
	jsr	sub_2C618
	pea	$20.w
	pea	$F8.w
	clr.l	-(sp)
	pea	$1.w
	jsr	sub_2F88A
	tst.b	ram_FF950E
	beq.w	.l3ECFA
	pea	$1.w
	pea	$13.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E51E
	jsr	sub_2F8E0
	move.w	d4,d0
	blt.w	.l3ECE0
	bgt.s	.l3EC34
	bra.s	.l3EC44
.l3EC34:
	cmpi.w	#$1,d0
	bne.s	.l3EC3C
	bra.s	.l3EC76
.l3EC3C:
	subq.w	#2,d0
	bne.w	.l3ECE0
	bra.s	.l3ECA8
.l3EC44:
	pea	$1.w
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E53A
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$68.w
	pea	$1D.w
	pea	$12.w
	pea	io_FF45B6
	bra.s	.l3ECD8
.l3EC76:
	pea	$1.w
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E54C
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$68.w
	pea	$1D.w
	pea	$12.w
	pea	io_FF4626
	bra.s	.l3ECD8
.l3ECA8:
	pea	$1.w
	pea	$13.w
	pea	$40.w
	pea	$100.w
	pea	str_4E55E
	jsr	sub_2F8E0
	clr.l	-(sp)
	pea	$68.w
	pea	$1D.w
	pea	$12.w
	pea	io_FF4696
.l3ECD8:
	move.l	d2,-(sp)
	jsr	sub_3F3A0
.l3ECE0:
	moveq	#$8,d5
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d5
	bra.w	.l3EFB0
.l3ECFA:
	move.w	d4,d0
	blt.s	.l3ED5C
	bgt.s	.l3ED02
	bra.s	.l3ED10
.l3ED02:
	cmpi.w	#$1,d0
	bne.s	.l3ED0A
	bra.s	.l3ED28
.l3ED0A:
	subq.w	#2,d0
	bne.s	.l3ED5C
	bra.s	.l3ED40
.l3ED10:
	pea	$1.w
	pea	$17.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E570
	bra.s	.l3ED56
.l3ED28:
	pea	$1.w
	pea	$17.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E58C
	bra.s	.l3ED56
.l3ED40:
	pea	$1.w
	pea	$17.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E5A8
.l3ED56:
	jsr	sub_2F8E0
.l3ED5C:
	clr.l	-(sp)
	pea	$13.w
	pea	$44.w
	pea	$100.w
	pea	str_4E5C4
	jsr	sub_2F8E0
	moveq	#$14,d5
	move.l	$FFFF8014,d0
	sub.l	ram_FFDDEC,d0
	divs.w	#$FA,d0
	ext.l	d0
	sub.l	d0,d5
	move.l	d5,-(sp)
	pea	dat_4E5FC
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$10.w
	pea	$50.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2F8E0
	pea	$FE.w
	jsr	sub_3E51C
	movea.l	(a2),a0
	move.w	ram_FFDE58,d0
	movea.l	#str_4EDA8,a1
	move.b	($0,a1,d0.w),(a0)
	tst.b	ram_FFDDE8
	beq.s	.l3EDE4
	subq.b	#1,ram_FFDDE8
	clr.b	d6
.l3EDE4:
	tst.b	d6
	beq.w	.l3EED2
	pea	$33.w
	jsr	queue_sound_command
	addi.l	#$9C4,ram_FFDDEC
	move.l	ram_FFDDEC,d0
	cmp.l	$FFFF8014,d0
	ble.s	.l3EE16
	move.l	$FFFF8014,ram_FFDDEC
.l3EE16:
	move.l	ram_FFDDF0,d0
	cmp.l	ram_FFDDEC,d0
	bge.s	.l3EE2E
	move.l	ram_FFDDF0,ram_FFDDEC
.l3EE2E:
	movea.l	(a2),a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$2,d0
	blt.s	.l3EE8A
	bgt.s	.l3EE3E
	bra.s	.l3EE56
.l3EE3E:
	subq.w	#3,d0
	bne.s	.l3EE8A
	movea.l	(a2),a0
	clr.b	(a0)
	movea.l	#ram_FFDE2E,a0
	cmpa.l	(a2),a0
	bcc.s	.l3EE52
	subq.l	#1,(a2)
.l3EE52:
	bra.w	.l3EED2
.l3EE56:
	movea.l	(a2),a0
	clr.b	(a0)
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE2E
	jsr	sub_3DD8E
	moveq	#$1,d5
	move.w	d3,ram_FF9550
	pea	$19.w
	jsr	queue_sound_command
	bra.s	.l3EED2
.l3EE8A:
	addq.l	#1,(a2)
	movea.l	(a2),a0
	addq.l	#1,a0
	clr.b	(a0)
	movea.l	#ram_FFDE2E,a0
	moveq	#$12,d0
	adda.l	d0,a0
	move.l	(a2),d0
	addq.l	#1,d0
	cmpa.l	d0,a0
	bhi.s	.l3EED2
	move.w	d3,ram_FF9550
	pea	$19.w
	jsr	queue_sound_command
	moveq	#$1,d5
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE2E
	jsr	sub_3DD8E
.l3EED2:
	cmp.l	ram_FFDE5A,d5
	beq.s	.l3EEE4
	pea	$24.w
	jsr	queue_sound_command
.l3EEE4:
	tst.l	d5
	bgt.s	.l3EF12
	tst.b	ram_FF950E
	bne.s	.l3EEF6
	movea.l	(a2),a0
	move.b	#$20,(a0)
.l3EEF6:
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	pea	ram_FFDE2E
	jsr	sub_3DD8E
.l3EF12:
	move.w	ram_FFDE58,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$100.w
	jsr	sub_3E34E
	pea	$16.w
	move.l	d2,-(sp)
	pea	ram_FFDE2C
	jsr	copy_to_zram
	move.w	d4,d0
	blt.w	.l3EFB0
	bgt.s	.l3EF42
	bra.s	.l3EF50
.l3EF42:
	cmpi.w	#$1,d0
	bne.s	.l3EF4A
	bra.s	.l3EF6E
.l3EF4A:
	subq.w	#2,d0
	bne.s	.l3EFB0
	bra.s	.l3EF8C
.l3EF50:
	jsr	sub_3FA7E
	pea	$10.w
	pea	$68.w
	pea	$17.w
	pea	$12.w
	pea	io_FF45B6
	bra.s	.l3EFA8
.l3EF6E:
	jsr	sub_3FA98
	pea	$10.w
	pea	$68.w
	pea	$17.w
	pea	$12.w
	pea	io_FF4626
	bra.s	.l3EFA8
.l3EF8C:
	jsr	sub_3FAB2
	pea	$10.w
	pea	$68.w
	pea	$17.w
	pea	$12.w
	pea	io_FF4696
.l3EFA8:
	move.l	d2,-(sp)
	jsr	sub_3F3A0
.l3EFB0:
	jsr	sub_2C820
	move.l	d5,ram_FFDE5A
	tst.l	d5
	bgt.s	.l3EFD0
	move.w	d3,ram_FF9550
	pea	$19.w
	jsr	queue_sound_command
.l3EFD0:
	moveq	#$0,d0
	move.w	ram_FF9550,d0
	cmp.l	d3,d0
	bne.s	.l3EFFE
	tst.b	ram_FFDE2E
	beq.s	.l3EFFE
	pea	ram_FFDE2E
	pea	ram_FFDE42
	jsr	sub_2E4B4
	move.b	#$1,ram_FF950E
.l3EFFE:
	movem.l	(-$7C,a6),d2-d6/a2
	unlk	a6
	rts
sub_3F008:
	link	a6,#$FF98
	movem.l	d2-d6/a2-a5,-(sp)
	move.l	($8,a6),d5
	move.w	($E,a6),d4
	move.w	($12,a6),d3
	move.l	#sub_2F2CC,d6
	moveq	#$1,d0
	move.w	d0,(-$2,a6)
	movea.l	#io_FF440E,a4
	move.w	($16,a6),d2
	ext.l	d2
	addq.l	#1,d2
	lea	($4,a4),a3
	lea	(-$66,a6),a2
	bra.w	.l3F144
.l3F042:
	clr.b	($16,a4)
	move.l	a3,-(sp)
	move.w	(-$2,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E600
	pea	(a2)
	jsr	sub_30220
	cmpa.l	d5,a4
	lea	($10,sp),sp
	bne.w	.l3F0E4
	pea	$1.w
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(a2)
	movea.l	d6,a5
	jsr	(a5)
	pea	(a2)
	jsr	sub_2E4E6
	subq.w	#1,d0
	ext.l	d0
	asl.l	#4,d0
	move.w	d0,d1
	tst.w	d1
	lea	($18,sp),sp
	bge.s	.l3F09C
	clr.w	d1
.l3F09C:
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_3E31A
	move.l	(a4),-(sp)
	pea	dat_4E608
	pea	(a2)
	jsr	sub_30220
	pea	$1.w
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(a2)
	movea.l	d6,a5
	jsr	(a5)
	lea	($2C,sp),sp
	bra.s	.l3F12E
.l3F0E4:
	pea	$1.w
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(a2)
	movea.l	d6,a5
	jsr	(a5)
	move.l	(a4),-(sp)
	pea	dat_4E60C
	pea	(a2)
	jsr	sub_30220
	pea	$1.w
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(a2)
	movea.l	d6,a5
	jsr	(a5)
	lea	($34,sp),sp
.l3F12E:
	addq.w	#1,(-$2,a6)
	moveq	#$18,d0
	adda.l	d0,a4
	moveq	#$18,d0
	adda.l	d0,a3
	addi.w	#$10,($16,a6)
	moveq	#$10,d0
	add.l	d0,d2
.l3F144:
	cmpi.w	#$A,(-$2,a6)
	ble.w	.l3F042
	move.w	($16,a6),d0
	ext.l	d0
	movem.l	(-$8C,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3F15E:
	link	a6,#$FF90
	movem.l	d2-d7/a2-a4,-(sp)
	move.l	($8,a6),d6
	move.w	($E,a6),d4
	move.w	($12,a6),d5
	movea.l	#sub_2F2CC,a3
	pea	$1.w
	pea	$13.w
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$180.w
	pea	dat_4E610
	jsr	(a3)
	addi.w	#$18,($16,a6)
	moveq	#$1,d7
	move.w	d7,(-$6,a6)
	movea.l	#io_FF4528,a4
	move.w	($16,a6),d3
	ext.l	d3
	addq.l	#1,d3
	move.w	($16,a6),d2
	ext.l	d2
	addq.l	#8,d2
	lea	($8,a4),a2
	lea	($14,sp),sp
	bra.w	.l3F386
.l3F1C2:
	clr.b	($1A,a4)
	move.l	a2,-(sp)
	move.w	(-$6,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E616
	pea	(-$6E,a6)
	jsr	sub_30220
	move.l	(a4),d0
	lsr.l	#5,d0
	move.l	d0,(-$A,a6)
	move.l	(a4),d1
	moveq	#$1F,d0
	and.l	d0,d1
	add.l	d1,d1
	move.l	d1,d0
	asl.l	#2,d1
	add.l	d0,d1
	move.l	d1,(-$4,a6)
	move.l	(-$4,a6),d7
	lsr.l	#5,d7
	move.l	d7,(-$4,a6)
	cmpa.l	d6,a4
	lea	($10,sp),sp
	bne.w	.l3F2D8
	pea	$1.w
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(-$6E,a6)
	jsr	(a3)
	pea	(-$6E,a6)
	jsr	sub_2E4E6
	subq.w	#1,d0
	ext.l	d0
	asl.l	#4,d0
	move.w	d0,d1
	tst.w	d1
	lea	($18,sp),sp
	bge.s	.l3F244
	clr.w	d1
.l3F244:
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_3E31A
	move.l	(-$A,a6),-(sp)
	pea	dat_4E61E
	pea	(-$6E,a6)
	jsr	sub_30220
	pea	$1.w
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(-$6E,a6)
	jsr	(a3)
	clr.l	-(sp)
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	pea	$1C0.w
	pea	dat_4E622
	jsr	(a3)
	move.l	(-$4,a6),-(sp)
	pea	dat_4E624
	pea	(-$6E,a6)
	jsr	sub_30220
	pea	$1.w
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1C6.w
	pea	(-$6E,a6)
	jsr	(a3)
	lea	($60,sp),sp
	bra.w	.l3F36C
.l3F2D8:
	pea	$1.w
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(-$6E,a6)
	jsr	(a3)
	move.l	(-$A,a6),-(sp)
	pea	dat_4E628
	pea	(-$6E,a6)
	jsr	sub_30220
	pea	$1.w
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(-$6E,a6)
	jsr	(a3)
	clr.l	-(sp)
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	pea	$1C0.w
	pea	dat_4E62C
	jsr	(a3)
	move.l	(-$4,a6),-(sp)
	pea	dat_4E62E
	pea	(-$6E,a6)
	jsr	sub_30220
	pea	$1.w
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1C6.w
	pea	(-$6E,a6)
	jsr	(a3)
	lea	($68,sp),sp
.l3F36C:
	addq.w	#1,(-$6,a6)
	moveq	#$1C,d0
	adda.l	d0,a4
	moveq	#$1C,d0
	adda.l	d0,a2
	addi.w	#$10,($16,a6)
	moveq	#$10,d0
	add.l	d0,d2
	moveq	#$10,d0
	add.l	d0,d3
.l3F386:
	cmpi.w	#$5,(-$6,a6)
	ble.w	.l3F1C2
	move.w	($16,a6),d0
	ext.l	d0
	movem.l	(-$94,a6),d2-d7/a2-a4
	unlk	a6
	rts
sub_3F3A0:
	link	a6,#$FF9C
	movem.l	d2-d6/a2-a5,-(sp)
	move.l	($8,a6),d4
	movea.l	($C,a6),a2
	move.w	($12,a6),d3
	movea.l	#sub_2F2CC,a4
	cmpa.l	#$FF45B6,a2
	bne.s	.l3F3DE
	pea	$1.w
	pea	$13.w
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$170.w
	pea	dat_4E632
	bra.s	.l3F41C
.l3F3DE:
	cmpa.l	#$FF4626,a2
	bne.s	.l3F402
	pea	$1.w
	pea	$13.w
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$190.w
	pea	dat_4E638
	bra.s	.l3F41C
.l3F402:
	pea	$1.w
	pea	$13.w
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$180.w
	pea	str_4E63E
.l3F41C:
	jsr	(a4)
	lea	($14,sp),sp
	addi.w	#$18,($1A,a6)
	moveq	#$1,d6
	move.l	a2,d5
	move.w	($1A,a6),d2
	ext.l	d2
	addq.l	#1,d2
	movea.l	d5,a0
	lea	($2,a0),a3
	lea	(-$64,a6),a2
	bra.w	.l3F54A
.l3F442:
	movea.l	d5,a5
	clr.b	($14,a5)
	move.l	a3,-(sp)
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E646
	pea	(a2)
	jsr	sub_30220
	cmp.l	d4,d5
	lea	($10,sp),sp
	bne.w	.l3F4EA
	pea	$1.w
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(a2)
	jsr	(a4)
	pea	(a2)
	jsr	sub_2E4E6
	subq.w	#1,d0
	ext.l	d0
	asl.l	#4,d0
	move.w	d0,d1
	tst.w	d1
	lea	($18,sp),sp
	bge.s	.l3F49C
	clr.w	d1
.l3F49C:
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_3E31A
	movea.l	d5,a5
	move.w	(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E64E
	pea	(a2)
	jsr	sub_30220
	pea	$1.w
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(a2)
	jsr	(a4)
	lea	($2C,sp),sp
	bra.s	.l3F536
.l3F4EA:
	pea	$1.w
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	(a2)
	jsr	(a4)
	movea.l	d5,a5
	move.w	(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E652
	pea	(a2)
	jsr	sub_30220
	pea	$1.w
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$160.w
	pea	(a2)
	jsr	(a4)
	lea	($34,sp),sp
.l3F536:
	addq.w	#1,d6
	moveq	#$16,d0
	add.l	d0,d5
	moveq	#$16,d0
	adda.l	d0,a3
	addi.w	#$10,($1A,a6)
	moveq	#$10,d0
	add.l	d0,d2
.l3F54A:
	cmpi.w	#$5,d6
	ble.w	.l3F442
	move.w	($1A,a6),d0
	ext.l	d0
	movem.l	(-$88,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3F562:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	moveq	#$18,d2
	move.l	#$FF440E,d4
	move.l	#dat_4ECB8,d5
	move.l	#$FF440E,d3
	addi.l	#$F0,d3
	bra.s	.l3F5A2
.l3F586:
	move.l	d2,-(sp)
	move.l	d4,d1
	moveq	#$18,d0
	add.l	d0,d4
	move.l	d1,-(sp)
	move.l	d5,d1
	moveq	#$18,d0
	add.l	d0,d5
	move.l	d1,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3F5A2:
	cmp.l	d3,d4
	bcs.s	.l3F586
	jsr	sub_3FA4A
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3F5B6:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	moveq	#$1C,d2
	move.l	#$FF4528,d4
	move.l	#dat_4EAE2,d5
	move.l	#$FF4528,d3
	addi.l	#$8C,d3
	bra.s	.l3F5F6
.l3F5DA:
	move.l	d2,-(sp)
	move.l	d4,d1
	moveq	#$1C,d0
	add.l	d0,d4
	move.l	d1,-(sp)
	move.l	d5,d1
	moveq	#$1C,d0
	add.l	d0,d5
	move.l	d1,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3F5F6:
	cmp.l	d3,d4
	bcs.s	.l3F5DA
	jsr	sub_3FA64
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3F60A:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	moveq	#$16,d2
	move.l	#$FF45B6,d4
	move.l	#dat_4EB6E,d5
	move.l	#$FF45B6,d3
	moveq	#$6E,d0
	add.l	d0,d3
	bra.s	.l3F648
.l3F62C:
	move.l	d2,-(sp)
	move.l	d4,d1
	moveq	#$16,d0
	add.l	d0,d4
	move.l	d1,-(sp)
	move.l	d5,d1
	moveq	#$16,d0
	add.l	d0,d5
	move.l	d1,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3F648:
	cmp.l	d3,d4
	bcs.s	.l3F62C
	jsr	sub_3FA7E
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3F65C:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	moveq	#$16,d2
	move.l	#$FF4626,d4
	move.l	#dat_4EBDC,d5
	move.l	#$FF4626,d3
	moveq	#$6E,d0
	add.l	d0,d3
	bra.s	.l3F69A
.l3F67E:
	move.l	d2,-(sp)
	move.l	d4,d1
	moveq	#$16,d0
	add.l	d0,d4
	move.l	d1,-(sp)
	move.l	d5,d1
	moveq	#$16,d0
	add.l	d0,d5
	move.l	d1,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3F69A:
	cmp.l	d3,d4
	bcs.s	.l3F67E
	jsr	sub_3FA98
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3F6AE:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	moveq	#$16,d2
	move.l	#$FF4696,d4
	move.l	#dat_4EC4A,d5
	move.l	#$FF4696,d3
	moveq	#$6E,d0
	add.l	d0,d3
	bra.s	.l3F6EC
.l3F6D0:
	move.l	d2,-(sp)
	move.l	d4,d1
	moveq	#$16,d0
	add.l	d0,d4
	move.l	d1,-(sp)
	move.l	d5,d1
	moveq	#$16,d0
	add.l	d0,d5
	move.l	d1,-(sp)
	jsr	copy_to_zram
	lea	($C,sp),sp
.l3F6EC:
	cmp.l	d3,d4
	bcs.s	.l3F6D0
	jsr	sub_3FAB2
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3F700:
	link	a6,#$0
	pea	io_FF4526
	pea	io_FF440E
	jsr	sub_2EFFE
	tst.l	d0
	bne.s	.l3F726
	jsr	sub_3F562
	jsr	sub_3FA4A
.l3F726:
	jsr	sub_3F7DA
	unlk	a6
	rts
sub_3F730:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#sub_2EFFE,a2
	pea	io_FF45B4
	pea	io_FF4528
	jsr	(a2)
	tst.l	d0
	bne.s	.l3F75C
	jsr	sub_3F5B6
	jsr	sub_3FA64
.l3F75C:
	pea	io_FF4624
	pea	io_FF45B6
	jsr	(a2)
	tst.l	d0
	bne.s	.l3F77A
	jsr	sub_3F60A
	jsr	sub_3FA7E
.l3F77A:
	pea	io_FF4694
	pea	io_FF4626
	jsr	(a2)
	tst.l	d0
	bne.s	.l3F798
	jsr	sub_3F65C
	jsr	sub_3FA98
.l3F798:
	pea	io_FF4704
	pea	io_FF4696
	jsr	(a2)
	tst.l	d0
	bne.s	.l3F7B6
	jsr	sub_3F6AE
	jsr	sub_3FAB2
.l3F7B6:
	jsr	sub_3F868
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_3F7C6:
	link	a6,#$0
	jsr	sub_3F700
	jsr	sub_3F730
	unlk	a6
	rts
sub_3F7DA:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	moveq	#$18,d2
	movea.l	#io_FF440E,a4
	move.l	#$FF440E,d3
	addi.l	#$F0,d3
	lea	($4,a4),a3
	movea.l	#game_options,a2
	bra.s	.l3F81E
.l3F802:
	moveq	#$0,d0
	move.w	(a2),d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	jsr	sub_3FC80
	addq.l	#8,sp
	moveq	#$18,d0
	adda.l	d0,a4
	adda.l	d2,a3
.l3F81E:
	cmpa.l	d3,a4
	bcs.s	.l3F802
	jsr	sub_3FA4A
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_3F832:
	link	a6,#$0
	moveq	#$0,d0
	move.w	game_options,d0
	andi.l	#$400,d0
	beq.s	.l3F864
	jsr	sub_3F562
	jsr	sub_3F5B6
	jsr	sub_3F60A
	jsr	sub_3F65C
	jsr	sub_3F6AE
.l3F864:
	unlk	a6
	rts
sub_3F868:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	#game_options,a3
	moveq	#$1C,d2
	movea.l	#io_FF4528,a4
	move.l	#$FF4528,d3
	addi.l	#$8C,d3
	lea	($8,a4),a2
	bra.s	.l3F8AC
.l3F890:
	moveq	#$0,d0
	move.w	(a3),d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_3FC80
	addq.l	#8,sp
	moveq	#$1C,d0
	adda.l	d0,a4
	adda.l	d2,a2
.l3F8AC:
	cmpa.l	d3,a4
	bcs.s	.l3F890
	moveq	#$16,d2
	jsr	sub_3FA64
	movea.l	#io_FF45B6,a4
	move.l	#$FF45B6,d3
	moveq	#$6E,d0
	add.l	d0,d3
	lea	($2,a4),a2
	bra.s	.l3F8EA
.l3F8CE:
	moveq	#$0,d0
	move.w	(a3),d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_3FC80
	addq.l	#8,sp
	moveq	#$16,d0
	adda.l	d0,a4
	adda.l	d2,a2
.l3F8EA:
	cmpa.l	d3,a4
	bcs.s	.l3F8CE
	moveq	#$16,d2
	jsr	sub_3FA7E
	movea.l	#io_FF4626,a4
	move.l	#$FF4626,d3
	moveq	#$6E,d0
	add.l	d0,d3
	lea	($2,a4),a2
	bra.s	.l3F928
.l3F90C:
	moveq	#$0,d0
	move.w	(a3),d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_3FC80
	addq.l	#8,sp
	moveq	#$16,d0
	adda.l	d0,a4
	adda.l	d2,a2
.l3F928:
	cmpa.l	d3,a4
	bcs.s	.l3F90C
	moveq	#$16,d2
	jsr	sub_3FA98
	movea.l	#io_FF4696,a4
	move.l	#$FF4696,d3
	moveq	#$6E,d0
	add.l	d0,d3
	lea	($2,a4),a2
	bra.s	.l3F966
.l3F94A:
	moveq	#$0,d0
	move.w	(a3),d0
	andi.l	#$200,d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_3FC80
	addq.l	#8,sp
	moveq	#$16,d0
	adda.l	d0,a4
	adda.l	d2,a2
.l3F966:
	cmpa.l	d3,a4
	bcs.s	.l3F94A
	jsr	sub_3FAB2
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_3F97A:
	link	a6,#$FF9C
	movem.l	d2,-(sp)
	move.w	($A,a6),d2
	pea	$1.w
	pea	$14.w
	pea	$13.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E656
	jsr	sub_2FBFA
	pea	$F6.w
	pea	$1FF.w
	pea	$49.w
	clr.l	-(sp)
	jsr	sub_2F796
	pea	$10.w
	move.w	d2,d1
	ext.l	d1
	move.l	d1,-(sp)
	pea	$1E.w
	pea	$1E.w
	clr.l	-(sp)
	jsr	sub_3F008
	move.l	d0,d2
	clr.l	-(sp)
	jsr	sub_419F2
	moveq	#$C,d1
	cmp.l	d0,d1
	bgt.s	.l3FA06
	pea	$1.w
	moveq	#$0,d0
	move.b	ram_FF9582,d0
	move.l	d0,-(sp)
	move.l	d2,d1
	moveq	#$C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$100.w
	pea	str_4E670
	bra.s	.l3FA26
.l3FA06:
	pea	$1.w
	moveq	#$0,d0
	move.b	ram_FF9582,d0
	move.l	d0,-(sp)
	move.l	d2,d1
	moveq	#$C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$100.w
	pea	str_4E684
.l3FA26:
	jsr	sub_2F8E0
	pea	$117.w
	pea	$1FF.w
	pea	$20.w
	clr.l	-(sp)
	jsr	sub_2F796
	movem.l	(-$68,a6),d2
	unlk	a6
	rts
sub_3FA4A:
	link	a6,#$0
	pea	io_FF4526
	pea	io_FF440E
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_3FA64:
	link	a6,#$0
	pea	io_FF45B4
	pea	io_FF4528
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_3FA7E:
	link	a6,#$0
	pea	io_FF4624
	pea	io_FF45B6
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_3FA98:
	link	a6,#$0
	pea	io_FF4694
	pea	io_FF4626
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_3FAB2:
	link	a6,#$0
	pea	io_FF4704
	pea	io_FF4696
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_3FACC:
	link	a6,#$FF9C
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	movea.l	#sub_2F8E0,a2
	pea	$1.w
	pea	$1E.w
	pea	$30.w
	pea	$100.w
	pea	str_4E692
	jsr	(a2)
	move.w	d2,d0
	blt.w	.l3FBAA
	bgt.s	.l3FB04
	bra.s	.l3FB14
.l3FB04:
	cmpi.w	#$1,d0
	bne.s	.l3FB0C
	bra.s	.l3FB44
.l3FB0C:
	subq.w	#2,d0
	bne.w	.l3FBAA
	bra.s	.l3FB74
.l3FB14:
	pea	$1.w
	pea	$1E.w
	pea	$44.w
	pea	$100.w
	pea	str_4E6A6
	jsr	(a2)
	pea	$10.w
	pea	$68.w
	pea	$12.w
	pea	$12.w
	pea	io_FF45B6
	bra.s	.l3FBA2
.l3FB44:
	pea	$1.w
	pea	$1E.w
	pea	$44.w
	pea	$100.w
	pea	str_4E6B8
	jsr	(a2)
	pea	$10.w
	pea	$68.w
	pea	$12.w
	pea	$12.w
	pea	io_FF4626
	bra.s	.l3FBA2
.l3FB74:
	pea	$1.w
	pea	$1E.w
	pea	$44.w
	pea	$100.w
	pea	str_4E6CA
	jsr	(a2)
	pea	$10.w
	pea	$68.w
	pea	$12.w
	pea	$12.w
	pea	io_FF4696
.l3FBA2:
	clr.l	-(sp)
	jsr	sub_3F3A0
.l3FBAA:
	tst.b	ram_FF950E
	beq.s	.l3FBC0
	pea	ram_FFDE42
	pea	dat_4E6E0
	bra.s	.l3FBC6
.l3FBC0:
	pea	str_4E6E6
.l3FBC6:
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$13.w
	pea	$E0.w
	clr.l	-(sp)
	pea	(-$64,a6)
	jsr	sub_2F2CC
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E6F4
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$13.w
	pea	$E0.w
	pea	$160.w
	pea	(-$64,a6)
	jsr	sub_2F2CC
	movem.l	(-$70,a6),d2-d3/a2
	unlk	a6
	rts
	assert	*=$03FC22,"game/code_03BC3C.asm does not end at 03FC22"
