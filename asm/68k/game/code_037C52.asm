; game/code_037C52.asm, 037C52-03BC3C: game program code (pair S) with the data, text and tables
; that lie between its routines; the first routine is sub_37C52 (037C52). Cut at routine starts
; into files of about 16 KB named by their first address (decision C11).
; 037C52-03BC3C: 26 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 037C52 03BC3C (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$037C52,"game/code_037C52.asm misplaced"
sub_37C52:
	link	a6,#$FF98
	movem.l	d2-d7/a2-a5,-(sp)
	movea.l	($8,a6),a2
	movea.l	#ram_FFDD16,a4
	move.l	($1A,a2),d4
	movea.l	d4,a0
	move.l	($8,a0),d3
	move.l	(a2),(-$C,a6)
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l37CEC
	tst.b	($66,a2)
	bne.s	.l37CB2
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a3
	bset	#$5,($38,a3)
	tst.l	($16,a2)
	addq.l	#8,sp
	beq.s	.l37CAA
	movea.l	($16,a2),a3
	bset	#$5,($38,a3)
.l37CAA:
	move.b	#$7,($66,a2)
	bra.s	.l37CE8
.l37CB2:
	cmpi.b	#$1,($66,a2)
	bne.s	.l37CCA
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,(-$C,a6)
	addq.l	#4,sp
	bra.s	.l37CE8
.l37CCA:
	subq.b	#1,($66,a2)
	moveq	#$0,d1
	move.b	ram_FFDCB6,d1
	asl.l	#2,d1
	movea.l	#ram_FFDC8A,a3
	move.l	a2,($0,a3,d1.l)
	addq.b	#1,ram_FFDCB6
.l37CE8:
	bra.w	.l3806C
.l37CEC:
	subq.b	#1,($69,a2)
	bne.w	.l37D56
	movea.l	($12,a2),a3
	movea.l	($26,a3),a0
	move.w	($4,a0),d0
	ext.l	d0
	addq.l	#1,d0
	cmpi.l	#$C6,d0
	ble.s	.l37D12
	move.l	#$C1,d0
.l37D12:
	movea.l	($12,a2),a3
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a3)
	move.b	#$5,($69,a2)
	addq.w	#1,($20,a2)
	move.w	($20,a2),d0
	ext.l	d0
	moveq	#$F,d1
	and.l	d1,d0
	addq.l	#4,sp
	moveq	#$2,d2
	cmp.l	d0,d2
	bgt.s	.l37D56
	blt.s	.l37D42
	bra.s	.l37D48
.l37D42:
	moveq	#$8,d1
	cmp.l	d0,d1
	bne.s	.l37D56
.l37D48:
	pea	$69.w
	jsr	queue_sound_command
	addq.l	#4,sp
	nop
.l37D56:
	tst.b	ram_FF9540
	beq.s	.l37D90
	cmp.l	ram_FFDBEE,d4
	beq.s	.l37D7E
	movea.l	ram_FFDBEE,a3
	cmp.l	(a3),d4
	bne.s	.l37D86
	move.w	($22,a2),d0
	ext.l	d0
	cmp.l	ram_FFDBFE,d0
	bge.s	.l37D86
.l37D7E:
	subi.w	#$28,($1E,a2)
	bra.s	.l37D8C
.l37D86:
	addi.w	#$28,($1E,a2)
.l37D8C:
	bra.w	.l37E70
.l37D90:
	btst	#$3,($67,a2)
	beq.s	.l37DE4
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEBC,a3
	moveq	#$0,d1
	move.b	($0,a3,d0.l),d1
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d1
	bne.s	.l37DCA
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l37DCA:
	cmpi.w	#$320,(a4)
	bcc.s	.l37DD6
	move.w	(a4),($1E,a2)
	bra.s	.l37DE0
.l37DD6:
	move.w	(a4),d0
	ext.l	d0
	asr.l	#3,d0
	move.w	d0,($1E,a2)
.l37DE0:
	bra.w	.l37E70
.l37DE4:
	cmpi.w	#$320,(a4)
	bcc.s	.l37DF4
	move.w	#$320,($1E,a2)
	bra.w	.l37E70
.l37DF4:
	move.w	(a4),d1
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
	bhi.s	.l37E66
	move.w	(a4),d2
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
	bra.s	.l37E6C
.l37E66:
	move.l	#$7D0,d2
.l37E6C:
	move.w	d2,($1E,a2)
.l37E70:
	move.w	($1E,a2),d0
	add.w	d0,($22,a2)
	move.w	($22,a2),d0
	ext.l	d0
	movea.l	d3,a0
	move.w	($8,a0),d1
	ext.l	d1
	movea.l	d3,a0
	move.w	($6,a0),d2
	ext.l	d2
	sub.l	d2,d1
	cmp.l	d1,d0
	blt.w	.l37F8E
	movea.l	($1A,a2),a3
	movea.l	($C,a3),a4
	pea	($52,a2)
	pea	($14,a4)
	jsr	sub_22DD6
	movea.l	d3,a5
	move.w	($8,a5),d0
	sub.w	d0,($22,a2)
	movea.l	($1A,a2),a3
	move.l	(a3),($1A,a2)
	movea.l	($1A,a2),a3
	move.l	($8,a3),d3
	move.l	#$FFDBEE,d1
	cmp.l	($1A,a2),d1
	addq.l	#8,sp
	beq.s	.l37EE0
	move.l	#$FFDBF6,d1
	cmp.l	($1A,a2),d1
	bne.s	.l37EF6
.l37EE0:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,(-$C,a6)
	move.l	(-$C,a6),d0
	addq.l	#4,sp
	bra.w	loc_38484
.l37EF6:
	movea.l	d3,a0
	move.b	($5,a0),d0
	ext.w	d0
	ext.l	d0
	movea.l	d3,a0
	move.b	($4,a0),d1
	ext.w	d1
	ext.l	d1
	or.l	d1,d0
	beq.w	.l37F8E
	move.w	($1E,a2),d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d1
	and.l	d1,d0
	add.l	d0,d0
	movea.l	#dat_4B00E,a3
	move.w	($0,a3,d0.l),($24,a2)
	movea.l	($1A,a2),a3
	movea.l	($C,a3),a4
	clr.w	(-$8,a6)
	lea	($14,a4),a3
	move.l	a3,d1
	lea	($52,a2),a3
	move.l	a3,d2
	lea	($40,a2),a3
.l37F46:
	clr.w	(-$2,a6)
	movea.l	d1,a0
	movea.l	d2,a1
	movea.l	a3,a4
.l37F50:
	move.w	(a0),(-$4,a6)
	move.w	(-$4,a6),d3
	sub.w	(a1),d3
	move.w	d3,(-$4,a6)
	move.w	(-$4,a6),d0
	ext.l	d0
	divs.w	($24,a2),d0
	move.w	d0,(a4)
	addq.w	#1,(-$2,a6)
	addq.l	#2,a4
	addq.l	#2,a1
	addq.l	#2,a0
	cmpi.w	#$3,(-$2,a6)
	blt.s	.l37F50
	addq.w	#1,(-$8,a6)
	addq.l	#6,a3
	addq.l	#6,d2
	addq.l	#6,d1
	cmpi.w	#$3,(-$8,a6)
	blt.s	.l37F46
.l37F8E:
	movea.l	($1A,a2),a3
	move.l	($8,a3),d3
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
	movea.l	d3,a5
	btst	#$7,($11,a5)
	lea	($10,sp),sp
	beq.s	.l37FF6
	move.w	#$5F0,(-$6,a6)
	bra.s	.l38022
.l37FF6:
	movea.l	($1A,a2),a3
	movea.l	($8,a3),a0
	move.w	($A,a0),(-$6,a6)
	movea.l	($1A,a2),a0
	movea.l	($8,a0),a0
	moveq	#$0,d1
	move.w	($A,a0),d1
	move.l	d1,d0
	divu.w	#$14,d0
	move.w	(-$6,a6),d2
	sub.w	d0,d2
	move.w	d2,(-$6,a6)
.l38022:
	movea.l	($12,a2),a3
	bset	#$6,($38,a3)
	move.l	a2,-(sp)
	jsr	sub_351D0
	move.l	$FFFF8014,d1
	asl.l	#8,d1
	move.l	d1,-(sp)
	jsr	sub_30C72
	ext.l	d0
	asl.l	#5,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	move.w	d0,(-$4,a6)
	move.w	(-$4,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D110
	lea	($10,sp),sp
.l3806C:
	move.l	($8,a2),d6
	move.l	#$FFFF8014,d2
	move.l	#$FFDD4A,d3
	move.l	#$FFDD26,d5
	move.l	#$FFDD1C,d4
	movea.l	#ram_FFDC1A,a4
	bra.w	loc_38334
loc_38092:
	movea.l	d6,a1
	move.l	(a1),(-$10,a6)
	movea.l	d6,a1
	movea.l	($8,a1),a3
	movea.l	($26,a3),a0
	move.w	($4,a0),d0
	move.w	d0,(-$8,a6)
	cmpi.w	#$C7,d0
	blt.s	loc_38102
	cmpi.w	#$CA,d0
	bgt.s	loc_38102
	sub.w	#$C7,d0
	add.w	d0,d0
	move.w	(.l380C4,pc,d0.w),d0
	jmp	(.l380C4,pc,d0.w)
.l380C4:
	dc.w	sub_380CC-.l380C4
	dc.w	sub_380D8-.l380C4
	dc.w	sub_380CC-.l380C4
	dc.w	sub_380E4-.l380C4
sub_380CC:
	movea.l	d6,a5
	movea.l	($8,a5),a3
	pea	$C8.w
	bra.s	loc_380EE
sub_380D8:
	movea.l	d6,a5
	movea.l	($8,a5),a3
	pea	$C9.w
	bra.s	loc_380EE
sub_380E4:
	movea.l	d6,a5
	movea.l	($8,a5),a3
	pea	$CB.w
loc_380EE:
	jsr	object_descriptor
	move.l	d0,($26,a3)
	move.b	#$1,ram_FFDC1C
	addq.l	#4,sp
loc_38102:
	movea.l	d6,a0
	tst.w	($16,a0)
	beq.w	.l381DE
	movea.l	d6,a5
	move.w	($10,a5),d1
	movea.l	d6,a5
	add.w	d1,($14,a5)
	movea.l	d6,a5
	addi.w	#$33,($10,a5)
	movea.l	d6,a5
	movea.l	($8,a5),a3
	pea	($14,a3)
	movea.l	($12,a2),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	d6,a5
	movea.l	($8,a5),a3
	movea.l	($12,a2),a0
	move.l	($8,a0),($8,a3)
	movea.l	d6,a5
	movea.l	($8,a5),a3
	movea.l	($12,a2),a0
	move.l	($C,a0),($C,a3)
	movea.l	d6,a5
	movea.l	($8,a5),a3
	movea.l	($12,a2),a0
	move.l	($10,a0),($10,a3)
	movea.l	d6,a5
	move.w	(-$6,a6),d7
	cmp.w	($14,a5),d7
	addq.l	#8,sp
	bhi.s	.l381AA
	movea.l	d6,a5
	move.l	($1A,a2),($C,a5)
	movea.l	d6,a5
	move.w	(-$6,a6),($14,a5)
	movea.l	d6,a5
	move.w	($22,a2),($10,a5)
	movea.l	d6,a5
	clr.w	($16,a5)
	movea.l	d6,a5
	movea.l	($8,a5),a3
	pea	$CA.w
	jsr	object_descriptor
	move.l	d0,($26,a3)
	addq.l	#4,sp
.l381AA:
	moveq	#$0,d0
	movea.l	d6,a5
	move.w	($14,a5),d0
	move.l	d0,d1
	move.w	(-$4,a6),d0
	ext.l	d0
	add.l	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	movea.l	d6,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2D110
	movea.l	d6,a5
	movea.l	($8,a5),a3
	bset	#$6,($38,a3)
.l381D8:
	addq.l	#8,sp
	bra.w	.l38330
.l381DE:
	movea.l	d6,a0
	movea.l	($C,a0),a3
	tst.w	($1A,a3)
	bne.s	.l38208
	movea.l	d6,a3
	move.l	($8,a3),-(sp)
	jsr	sub_2E872
	move.l	d6,-(sp)
	jsr	sub_2EA08
	move.b	#$1,ram_FFDC1C
	bra.s	.l381D8
.l38208:
	tst.w	ram_FFDD4E
	bne.w	.l38330
	movea.l	d3,a0
	tst.w	(a0)
	bne.w	.l38330
	tst.b	ram_FFDCF4
	bne.w	.l38330
	movea.l	d6,a0
	movea.l	($C,a0),a3
	cmpi.w	#$1,($1A,a3)
	bne.w	.l38330
	movea.l	d6,a1
	movea.l	($C,a1),a3
	movea.l	($8,a3),a0
	movea.w	($10,a0),a3
	exg	d0,a3
	andi.w	#$80,d0
	exg	d0,a3
	beq.s	.l38254
	move.w	#$190,(-$2,a6)
	bra.s	.l3827C
.l38254:
	move.w	#$900,(-$2,a6)
	tst.w	(a4)
	bcs.s	.l38268
	cmpi.b	#$1,ram_FFDCE7
	bhi.s	.l38276
.l38268:
	tst.w	(a4)
	bcc.s	.l3827C
	cmpi.b	#$1,ram_FFDCE6
	bls.s	.l3827C
.l38276:
	subi.w	#$400,(-$2,a6)
.l3827C:
	move.l	ram_FFDBFE,d0
	movea.l	d6,a0
	move.w	($10,a0),d1
	ext.l	d1
	sub.l	d1,d0
	blt.s	.l382A0
	move.l	ram_FFDBFE,d1
	movea.l	d6,a0
	move.w	($10,a0),d0
	ext.l	d0
	sub.l	d0,d1
	bra.s	.l382B2
.l382A0:
	move.l	ram_FFDBFE,d1
	movea.l	d6,a0
	move.w	($10,a0),d0
	ext.l	d0
	sub.l	d0,d1
	neg.l	d1
.l382B2:
	move.w	d1,(-$8,a6)
	tst.w	(a4)
	blt.s	.l382C0
	move.w	(a4),d1
	ext.l	d1
	bra.s	.l382C6
.l382C0:
	move.w	(a4),d1
	ext.l	d1
	neg.l	d1
.l382C6:
	move.w	(-$2,a6),d0
	ext.l	d0
	cmp.l	d1,d0
	blt.w	.l38330
	cmpi.w	#$3E8,(-$8,a6)
	bgt.w	.l38330
	pea	$30.w
	jsr	queue_sound_command
	movea.l	d3,a5
	move.w	#$7D2,(a5)
	movea.l	d5,a5
	subi.w	#$2EEC,(a5)
	move.l	a3,d6
	tst.w	d6
	addq.l	#4,sp
	beq.s	.l38314
	movea.l	d2,a0
	btst	#$0,($3,a0)
	beq.s	.l3830C
	move.l	#$222,d0
	bra.s	.l38312
.l3830C:
	move.l	#$FFFFFDDE,d0
.l38312:
	bra.s	.l3832C
.l38314:
	movea.l	d2,a0
	btst	#$0,($3,a0)
	beq.s	.l38326
	move.l	#$E38,d0
	bra.s	.l3832C
.l38326:
	move.l	#$FFFFF1C8,d0
.l3832C:
	movea.l	d4,a0
	add.w	d0,(a0)
.l38330:
	move.l	(-$10,a6),d6
loc_38334:
	lea	($8,a2),a3
	cmp.l	a3,d6
	bne.w	loc_38092
	btst	#$1,($67,a2)
	bne.s	.l38380
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEEC,a3
	moveq	#$0,d1
	move.b	($0,a3,d0.l),d1
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d1
	bne.s	.l38380
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$2,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
	move.w	#$1,($32,a2)
	bra.s	.l383CC
.l38380:
	movea.l	($1A,a2),a3
	moveq	#$0,d1
	move.w	($1A,a3),d1
	move.l	d1,d0
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEEC,a0
	moveq	#$0,d2
	move.b	($0,a0,d1.l),d2
	addq.l	#2,d2
	cmp.l	d2,d0
	beq.s	.l383B2
	movea.l	($1A,a2),a3
	cmpi.w	#$1,($1A,a3)
	bne.s	.l383CC
.l383B2:
	andi.b	#$FD,($67,a2)
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l383CC:
	btst	#$1,($67,a2)
	beq.w	.l38480
	subq.w	#1,($32,a2)
	bne.w	.l38480
	jsr	sub_2E9D6
	move.l	d0,d6
	beq.w	.l38480
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEFC,a3
	moveq	#$0,d2
	move.b	($0,a3,d0.l),d2
	move.l	d2,d0
	lsl.l	#1,d0
	move.w	d0,($32,a2)
	move.l	d6,-(sp)
	pea	($8,a2)
	jsr	sub_2E79C
	movea.l	($12,a2),a3
	pea	($14,a3)
	movea.l	($12,a2),a0
	move.l	($10,a0),-(sp)
	movea.l	($12,a2),a0
	move.l	($C,a0),-(sp)
	movea.l	($12,a2),a0
	move.l	($8,a0),-(sp)
	pea	$C7.w
	jsr	sub_2EF4C
	movea.l	d6,a4
	move.l	d0,($8,a4)
	movea.l	d6,a4
	move.l	($8,a4),-(sp)
	jsr	sub_2E7EE
	movea.l	d6,a4
	move.l	($8,a4),-(sp)
	pea	ram_FFDA96
	jsr	sub_2E79C
	movea.l	d6,a4
	clr.w	($14,a4)
	movea.l	d6,a4
	clr.w	($10,a4)
	movea.l	d6,a4
	move.w	#$1,($16,a4)
	move.b	#$1,ram_FFDC1C
	lea	($28,sp),sp
.l38480:
	move.l	(-$C,a6),d0
loc_38484:
	movem.l	(-$90,a6),d2-d7/a2-a5
	unlk	a6
	rts
sub_3848E:
	link	a6,#$0
	movem.l	d2-d5/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.l	#ram_FFDD16,a1
	movea.l	($1A,a2),a3
	movea.l	($8,a3),a4
	move.l	(a2),d3
	cmpi.w	#$1,($3C,a2)
	bcs.w	.l38522
	tst.b	($66,a2)
	bne.s	.l384EA
	pea	$1.w
	move.l	a2,-(sp)
	jsr	sub_356CA
	movea.l	($12,a2),a0
	bset	#$5,($38,a0)
	tst.l	($16,a2)
	addq.l	#8,sp
	beq.s	.l384E2
	movea.l	($16,a2),a0
	bset	#$5,($38,a0)
.l384E2:
	move.b	#$7,($66,a2)
	bra.s	.l3851E
.l384EA:
	cmpi.b	#$1,($66,a2)
	bne.s	.l38500
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	addq.l	#4,sp
	bra.s	.l3851E
.l38500:
	subq.b	#1,($66,a2)
	moveq	#$0,d0
	move.b	ram_FFDCB6,d0
	asl.l	#2,d0
	movea.l	#ram_FFDC8A,a0
	move.l	a2,($0,a0,d0.l)
	addq.b	#1,ram_FFDCB6
.l3851E:
	bra.w	.l387A4
.l38522:
	tst.b	ram_FF9540
	beq.s	.l3855C
	cmpa.l	ram_FFDBEE,a3
	beq.s	.l3854A
	movea.l	ram_FFDBEE,a0
	cmpa.l	(a0),a3
	bne.s	.l38552
	move.w	($22,a2),d0
	ext.l	d0
	cmp.l	ram_FFDBFE,d0
	bge.s	.l38552
.l3854A:
	subi.w	#$28,($1E,a2)
	bra.s	.l38558
.l38552:
	addi.w	#$28,($1E,a2)
.l38558:
	bra.w	.l38608
.l3855C:
	btst	#$3,($67,a2)
	beq.s	.l3857E
	cmpi.w	#$320,(a1)
	bcc.s	.l38570
	move.w	(a1),($1E,a2)
	bra.s	.l3857A
.l38570:
	move.w	(a1),d0
	ext.l	d0
	asr.l	#3,d0
	move.w	d0,($1E,a2)
.l3857A:
	bra.w	.l38608
.l3857E:
	cmpi.w	#$320,(a1)
	bcc.s	.l3858E
	move.w	#$320,($1E,a2)
	bra.w	.l38608
.l3858E:
	move.w	(a1),d0
	ext.l	d0
	move.w	ram_FF9578,d2
	ext.l	d2
	add.l	d2,d2
	movea.l	#dat_4EE68,a0
	moveq	#$0,d1
	move.w	($0,a0,d2.l),d1
	sub.l	d1,d0
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEE4,a0
	moveq	#$0,d2
	move.b	($0,a0,d1.l),d2
	sub.l	d2,d0
	cmpi.l	#$7D0,d0
	bhi.s	.l385FE
	move.w	(a1),d2
	ext.l	d2
	move.w	ram_FF9578,d0
	ext.l	d0
	add.l	d0,d0
	movea.l	#dat_4EE68,a0
	moveq	#$0,d1
	move.w	($0,a0,d0.l),d1
	move.l	d1,d0
	sub.l	d0,d2
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEE4,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	sub.l	d0,d2
	bra.s	.l38604
.l385FE:
	move.l	#$7D0,d2
.l38604:
	move.w	d2,($1E,a2)
.l38608:
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
	blt.w	.l386FC
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
	move.l	#$FFDBEE,d0
	cmp.l	($1A,a2),d0
	addq.l	#8,sp
	beq.s	.l38672
	move.l	#$FFDBF6,d0
	cmp.l	($1A,a2),d0
	bne.s	.l38682
.l38672:
	move.l	a2,-(sp)
	jsr	sub_35502
	move.l	d0,d3
	addq.l	#4,sp
	bra.w	.l387A4
.l38682:
	move.b	($5,a4),d0
	ext.w	d0
	ext.l	d0
	move.b	($4,a4),d1
	ext.w	d1
	ext.l	d1
	or.l	d1,d0
	beq.w	.l386FC
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
	move.l	a0,d4
	lea	($52,a2),a0
	move.l	a0,d5
	lea	($40,a2),a0
.l386CC:
	clr.w	d2
	movea.l	d4,a1
	movea.l	d5,a3
	movea.l	a0,a4
.l386D4:
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
	blt.s	.l386D4
	addq.w	#1,d1
	addq.l	#6,a0
	addq.l	#6,d5
	addq.l	#6,d4
	cmpi.w	#$3,d1
	blt.s	.l386CC
.l386FC:
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
	pea	$C80.w
	move.l	($12,a2),-(sp)
	jsr	sub_2D110
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EEBC,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	movea.l	($1A,a2),a0
	cmp.w	($1A,a0),d0
	lea	($1C,sp),sp
	bne.s	.l387A4
	moveq	#$0,d1
	move.b	($67,a2),d1
	move.l	d1,d0
	moveq	#-$D,d2
	and.l	d2,d0
	moveq	#$10,d1
	or.l	d1,d0
	move.b	d0,($67,a2)
.l387A4:
	move.l	d3,d0
	movem.l	(-$1C,a6),d2-d5/a2-a4
	unlk	a6
	rts
sub_387B0:
	link	a6,#$0
	move.w	#$B4,ram_FFDCD6
	clr.w	ram_FFDCD4
	unlk	a6
	rts
dat_387C6:
	incbin	"../../build/stunrun-68k.bin",$387C6,$B4
sub_3887A:
	link	a6,#$FFEC
	movem.l	d2-d5/a2,-(sp)
	movea.l	#ram_FFDCDC,a2
	tst.w	ram_FFDCE2
	beq.s	.l38896
	moveq	#$0,d0
	bra.w	.l38BC4
.l38896:
	tst.w	ram_FFDCCA
	beq.s	.l388D2
	move.w	ram_FFDD16,ram_FFDCCE
	move.w	ram_FFDD16,ram_FFDCCC
	move.w	ram_FFDCCC,ram_FFDCD0
	move.w	ram_FFDC1A,ram_FFDCDE
	move.w	ram_FFDC1A,(a2)
	clr.w	ram_FFDCCA
.l388D2:
	move.w	ram_FFDD16,d2
	sub.w	ram_FFDCCE,d2
	move.w	ram_FFDD16,ram_FFDCCE
	move.w	ram_FFDCCC,d0
	sub.w	ram_FFDCD0,d0
	move.w	ram_FFDCCC,ram_FFDCD0
	move.w	d2,d3
	sub.w	d0,d3
	tst.w	d3
	beq.s	.l38920
	move.w	d3,d0
	ext.l	d0
	move.b	dat_4D771,d1
	asr.l	d1,d0
	move.w	d0,d0
	beq.s	.l3891C
	ext.l	d0
	neg.l	d0
	bra.s	.l3891E
.l3891C:
	moveq	#-$1,d0
.l3891E:
	bra.s	.l3893C
.l38920:
	tst.w	ram_FFDCD2
	blt.s	.l38932
	move.w	ram_FFDCD2,d0
	ext.l	d0
	bra.s	.l3893C
.l38932:
	move.w	ram_FFDCD2,d0
	ext.l	d0
	neg.l	d0
.l3893C:
	move.w	d0,ram_FFDCD2
	add.w	d0,ram_FFDCC6
	cmpi.w	#$FCA0,ram_FFDCC6
	ble.s	.l3895C
	move.w	#$FCA0,ram_FFDCC6
	bra.s	.l3896E
.l3895C:
	cmpi.w	#$FA60,ram_FFDCC6
	bge.s	.l3896E
	move.w	#$FA60,ram_FFDCC6
.l3896E:
	tst.w	d3
	beq.s	.l389A2
	tst.w	d2
	ble.s	.l389A2
	move.w	d2,d0
	ext.l	d0
	divs.w	#$2,d0
	ext.l	d0
	tst.l	d0
	blt.s	.l38990
	move.w	d2,d0
	ext.l	d0
	divs.w	#$2,d0
	ext.l	d0
	bra.s	.l3899C
.l38990:
	move.w	d2,d0
	ext.l	d0
	divs.w	#$2,d0
	ext.l	d0
	neg.l	d0
.l3899C:
	add.w	d0,ram_FFDCCC
.l389A2:
	cmpi.w	#$FCA0,ram_FFDCC6
	blt.s	.l389CC
	move.w	ram_FFDD16,d0
	cmp.w	ram_FFDCCC,d0
	bge.s	.l389CC
	move.w	ram_FFDD16,d0
	move.w	d0,ram_FFDCCC
	move.w	d0,ram_FFDCD0
.l389CC:
	move.w	ram_FFDC1A,d0
	sub.w	(a2),d0
	tst.w	d0
	beq.s	.l38A14
	tst.w	d0
	blt.s	.l389E2
	move.w	d0,d1
	ext.l	d1
	bra.s	.l389E8
.l389E2:
	move.w	d0,d1
	ext.l	d1
	neg.l	d1
.l389E8:
	cmpi.l	#$AAA,d1
	bls.s	.l389FE
	move.w	ram_FFDC1A,d0
	sub.w	ram_FFDCDE,d0
	bra.s	.l38A12
.l389FE:
	ext.l	d0
	move.b	dat_4D773,d1
	asr.l	d1,d0
	move.w	d0,d0
	beq.s	.l38A10
	ext.l	d0
	bra.s	.l38A12
.l38A10:
	moveq	#$1,d0
.l38A12:
	add.w	d0,(a2)
.l38A14:
	move.w	ram_FFDC1A,ram_FFDCDE
	movea.l	ram_FFDBEE,a0
	movea.l	(a0),a0
	movea.l	($8,a0),a0
	btst	#$1,($11,a0)
	beq.s	.l38A44
	move.l	ram_FFDBFE,d0
	divs.w	($C,a0),d0
	move.w	d0,d4
	add.w	($A,a0),d4
	bra.s	.l38A48
.l38A44:
	move.w	($A,a0),d4
.l38A48:
	tst.b	ram_FFDCF0
	beq.s	.l38A5E
	move.w	ram_FFDD00,d0
	ext.l	d0
	divs.w	#$7,d0
	sub.w	d0,d4
.l38A5E:
	btst	#$7,($11,a0)
	bne.w	.l38B48
	move.w	#$C16,d5
	sub.w	ram_FFDC1A,d5
	cmpi.w	#$182D,d5
	bls.s	.l38AB6
	pea	(-$12,a6)
	pea	ram_FFDB04
	jsr	sub_22DD6
	pea	ram_FFDB04
	moveq	#$0,d0
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	bra.s	.l38AFC
.l38AB6:
	move.w	d4,d0
	ext.l	d0
	divs.w	#$14,d0
	sub.w	d0,d4
	moveq	#$0,d0
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.w	d4,d3
	ext.l	d3
	move.l	d0,d2
	move.l	d2,d1
	mulu.w	d3,d0
	swap	d2
	mulu.w	d3,d2
	swap	d3
	mulu.w	d3,d1
	add.l	d2,d1
	swap	d1
	clr.w	d1
	add.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D172
.l38AFC:
	tst.b	ram_FFDCF4
	beq.s	.l38B14
	move.w	ram_FFDCFC,d0
	ext.l	d0
	addi.l	#$C6,d0
	bra.s	.l38B1A
.l38B14:
	move.l	#$C6,d0
.l38B1A:
	move.w	d4,d1
	ext.l	d1
	sub.l	d1,d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D110
	cmpi.w	#$182D,d5
	bls.s	.l38B44
	pea	ram_FFDB04
	pea	(-$12,a6)
	jsr	sub_22DD6
.l38B44:
	bra.w	.l38BAE
.l38B48:
	tst.b	ram_FFDCF4
	beq.s	.l38B68
	move.w	ram_FFDCFC,d0
	ext.l	d0
	addi.l	#$C6,d0
	subi.l	#$5F0,d0
.l38B64:
	move.l	d0,-(sp)
	bra.s	.l38B8E
.l38B68:
	tst.b	ram_FFDCF0
	beq.s	.l38B88
	move.w	ram_FFDD00,d1
	ext.l	d1
	divs.w	#$7,d1
	ext.l	d1
	move.l	d1,d0
	addi.l	#$FFFFFAD6,d0
	bra.s	.l38B64
.l38B88:
	move.l	#$FFFFFAD6,-(sp)
.l38B8E:
	pea	ram_FFDAF0
	jsr	sub_2D110
	move.w	(a2),d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D172
.l38BAE:
	move.w	ram_FFDCC6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D0AE
.l38BC4:
	movem.l	(-$28,a6),d2-d5/a2
	unlk	a6
	rts
sub_38BCE:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	moveq	#$1,d2
	movea.l	#ram_FFDAF0,a2
	tst.w	ram_FFDCD4
	ble.w	.l38C7A
	subq.w	#6,ram_FFDCD4
	addi.w	#$C,ram_FFDCD6
	movea.l	#ram_FF9C80,a0
	movea.l	a2,a1
	moveq	#$3D,d0
.l38C00:
	move.b	(a0)+,(a1)+
	dbf	d0,.l38C00
	pea	($14,a2)
	move.w	ram_FFDCD4,d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#6,d0
	divs.w	#$5A,d0
	moveq	#$0,d1
	move.w	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	ram_FFDCD4,d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#6,d0
	divs.w	#$5A,d0
	moveq	#$0,d1
	move.w	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	move.w	ram_FFDCC6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2D0AE
	move.w	ram_FFDCD6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2D110
	bra.s	.l38CAA
.l38C7A:
	movea.l	#ram_FF9C80,a0
	movea.l	a2,a1
	moveq	#$3D,d0
.l38C84:
	move.b	(a0)+,(a1)+
	dbf	d0,.l38C84
	move.w	ram_FFDCC6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2D0AE
	pea	$C6.w
	pea	(a2)
	jsr	sub_2D110
	moveq	#$0,d2
.l38CAA:
	move.l	d2,d0
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_38CB6:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	moveq	#$1,d2
	movea.l	#ram_FFDCD4,a2
	cmpi.w	#$5A,(a2)
	bge.w	.l38D62
	addq.w	#6,(a2)
	subi.w	#$C,ram_FFDCD6
	movea.l	#ram_FF9C80,a0
	movea.l	#ram_FFDAF0,a1
	moveq	#$1E,d0
.l38CE6:
	move.w	(a0)+,(a1)+
	dbf	d0,.l38CE6
	pea	ram_FFDB04
	move.w	(a2),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#6,d0
	divs.w	#$5A,d0
	moveq	#$0,d1
	move.w	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	(a2),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#6,d0
	divs.w	#$5A,d0
	moveq	#$0,d1
	move.w	d0,d1
	neg.l	d1
	move.l	d1,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	move.w	ram_FFDCC6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D0AE
	move.w	ram_FFDCD6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D110
	bra.s	.l38D64
.l38D62:
	moveq	#$0,d2
.l38D64:
	move.l	d2,d0
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
dat_38D70:
	incbin	"../../build/stunrun-68k.bin",$38D70,$24
sub_38D94:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDAF0,a2
	pea	($14,a2)
	pea	ram_FF9C94
	jsr	sub_22DD6
	move.l	ram_FF9C88,($8,a2)
	move.l	ram_FF9C8C,($C,a2)
	move.l	ram_FF9C90,($10,a2)
	move.l	#$FFFFFCA0,-(sp)
	pea	(a2)
	jsr	sub_2D0AE
	pea	$C6.w
	pea	(a2)
	jsr	sub_2D110
	bset	#$6,($38,a2)
	clr.w	ram_FFDCDC
	move.w	#$FCA0,ram_FFDCC6
	clr.w	ram_FFDCCC
	clr.w	ram_FFDCCE
	clr.w	ram_FFDCD0
	clr.w	ram_FFDCD2
	clr.w	ram_FFDCDE
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_38E20:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDAF0,a2
	pea	($14,a2)
	pea	ram_FF9C94
	jsr	sub_22DD6
	move.l	ram_FF9C88,($8,a2)
	move.l	ram_FF9C8C,($C,a2)
	move.l	ram_FF9C90,($10,a2)
	move.l	#$FFFFFE00,-(sp)
	pea	(a2)
	jsr	sub_2D0AE
	pea	$40.w
	pea	(a2)
	jsr	sub_2D110
	bset	#$6,($38,a2)
	clr.w	ram_FFDCDC
	move.w	#$FE00,ram_FFDCC6
	move.w	#$40,ram_FFDCC8
	clr.w	ram_FFDCCC
	clr.w	ram_FFDCCE
	clr.w	ram_FFDCD0
	clr.w	ram_FFDCD2
	clr.w	ram_FFDCDE
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_38EB4:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	#ram_FFDCC6,a2
	cmpi.w	#$FCA0,(a2)
	ble.s	.l38EF2
	tst.w	(a2)
	blt.s	.l38ED2
	move.w	(a2),d1
	ext.l	d1
	bra.s	.l38ED8
.l38ED2:
	move.w	(a2),d1
	ext.l	d1
	neg.l	d1
.l38ED8:
	move.l	#$360,d0
	sub.l	d1,d0
	divs.w	#$3,d0
	cmpi.w	#$10,d0
	bge.s	.l38EF0
	move.w	#$FCA0,(a2)
	bra.s	.l38EF2
.l38EF0:
	sub.w	d0,(a2)
.l38EF2:
	cmpi.w	#$C6,ram_FFDCC8
	bge.s	.l38F26
	move.l	#$C6,d0
	move.w	ram_FFDCC8,d1
	ext.l	d1
	sub.l	d1,d0
	divs.w	#$3,d0
	cmpi.w	#$8,d0
	bge.s	.l38F20
	move.w	#$C6,ram_FFDCC8
	bra.s	.l38F26
.l38F20:
	add.w	d0,ram_FFDCC8
.l38F26:
	cmpi.w	#$FCA0,(a2)
	bne.s	.l38F44
	cmpi.w	#$C6,ram_FFDCC8
	bne.s	.l38F44
	pea	$15.w
	jsr	queue_sound_command
	moveq	#$16,d2
	bra.s	.l38F46
.l38F44:
	moveq	#$29,d2
.l38F46:
	pea	ram_FFDB04
	pea	ram_FF9C94
	jsr	sub_22DD6
	move.l	ram_FF9C88,ram_FFDAF8
	move.l	ram_FF9C8C,ram_FFDAFC
	move.l	ram_FF9C90,ram_FFDB00
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D0AE
	move.w	ram_FFDCC8,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D110
	bset	#$6,ram_FFDB28
	move.l	d2,d0
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_38FB2:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	#ram_FFDCC6,a2
	cmpi.w	#$FE00,(a2)
	bge.s	.l38FEC
	tst.w	(a2)
	blt.s	.l38FD0
	move.w	(a2),d0
	ext.l	d0
	bra.s	.l38FD6
.l38FD0:
	move.w	(a2),d0
	ext.l	d0
	neg.l	d0
.l38FD6:
	subi.l	#$200,d0
	asr.l	#1,d0
	cmpi.w	#$10,d0
	bge.s	.l38FEA
	move.w	#$FE00,(a2)
	bra.s	.l38FEC
.l38FEA:
	add.w	d0,(a2)
.l38FEC:
	cmpi.w	#$40,ram_FFDCC8
	ble.s	.l3901A
	move.w	ram_FFDCC8,d0
	ext.l	d0
	moveq	#$40,d1
	sub.l	d1,d0
	asr.l	#1,d0
	cmpi.w	#$8,d0
	bge.s	.l39014
	move.w	#$40,ram_FFDCC8
	bra.s	.l3901A
.l39014:
	sub.w	d0,ram_FFDCC8
.l3901A:
	cmpi.w	#$FE00,(a2)
	bne.s	.l3902E
	cmpi.w	#$40,ram_FFDCC8
	bne.s	.l3902E
	moveq	#$3D,d2
	bra.s	.l39030
.l3902E:
	moveq	#$3C,d2
.l39030:
	pea	ram_FFDB04
	pea	ram_FF9C94
	jsr	sub_22DD6
	move.l	ram_FF9C88,ram_FFDAF8
	move.l	ram_FF9C8C,ram_FFDAFC
	move.l	ram_FF9C90,ram_FFDB00
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D0AE
	move.w	ram_FFDCC8,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDAF0
	jsr	sub_2D110
	bset	#$6,ram_FFDB28
	move.l	d2,d0
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_3909C:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDAF0,a2
	move.w	#$FA60,ram_FFDCC6
	move.w	#$C6,ram_FFDCC8
	move.w	ram_FFDD16,ram_FFDCCE
	move.w	ram_FFDD16,ram_FFDCCC
	move.w	ram_FFDCCC,ram_FFDCD0
	move.w	ram_FFDC1A,ram_FFDCDE
	move.w	ram_FFDC1A,ram_FFDCDC
	pea	($14,a2)
	pea	ram_FF9C94
	jsr	sub_22DD6
	move.l	ram_FF9C88,($8,a2)
	move.l	ram_FF9C8C,($C,a2)
	move.l	ram_FF9C90,($10,a2)
	move.w	ram_FFDCC6,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2D0AE
	move.w	ram_FFDCC8,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(a2)
	jsr	sub_2D110
	bset	#$6,($38,a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_39148:
	link	a6,#$0
	move.w	#$1,ram_FFDCE2
	unlk	a6
	rts
sub_39158:
	link	a6,#$FFE8
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	#$FFDD1C,d5
	tst.w	ram_FFDD4E
	bne.s	.l39178
	cmpi.w	#$880,ram_FFDD16
	blt.s	.l3917E
.l39178:
	moveq	#$0,d0
	bra.w	.l39970
.l3917E:
	movea.l	ram_FFDBEE,a0
	move.l	(a0),(-$A,a6)
	tst.l	ram_FFDBFE
	bge.s	.l39194
	moveq	#$0,d0
	bra.s	.l3919A
.l39194:
	movea.l	(-$A,a6),a0
	move.l	(a0),d0
.l3919A:
	move.l	d0,(-$16,a6)
	move.l	ram_FFDAAE,d4
	move.l	#$FFDAAE,d3
	movea.l	#ram_FFDCE4,a2
	movea.l	#ram_FFDC1A,a3
	movea.l	#ram_FFDCF4,a4
	bra.w	.l3996A
.l391C0:
	movea.l	d4,a0
	tst.w	($3E,a0)
	beq.w	.l39966
	move.l	d4,d6
	movea.l	d6,a0
	cmpi.w	#$2,($10,a0)
	bne.s	.l391F8
	moveq	#$2,d2
.l391D8:
	moveq	#$0,d0
	movea.l	d6,a0
	move.w	($10,a0),d0
	move.l	d0,d1
	cmp.l	d2,d1
	bne.s	.l391F8
	movea.l	d6,a5
	move.l	($C,a5),-(sp)
	jsr	sub_22E16
	move.l	d0,d6
	addq.l	#4,sp
	bra.s	.l391D8
.l391F8:
	movea.l	d4,a1
	movea.l	($1A,a1),a0
	cmpa.l	(-$A,a6),a0
	beq.s	.l3920E
	cmpa.l	(-$16,a6),a0
	beq.s	.l3920E
	bra.w	.l39966
.l3920E:
	cmpa.l	(-$16,a6),a0
	bne.s	.l3925A
	movea.l	($8,a0),a1
	movea.l	(-$A,a6),a5
	movea.l	($8,a5),a0
	movea.l	d4,a5
	move.w	($22,a5),(-$2,a6)
	move.l	(-$4,a6),d7
	ext.l	d7
	move.l	d7,(-$4,a6)
	move.w	($6,a1),d1
	ext.l	d1
	move.w	($8,a0),d0
	ext.l	d0
	move.w	($6,a0),d2
	ext.l	d2
	sub.l	d2,d0
	sub.l	ram_FFDBFE,d0
	add.l	d0,d1
	move.l	(-$4,a6),d7
	add.l	d1,d7
	move.l	d7,(-$4,a6)
	bra.s	.l3927A
.l3925A:
	movea.l	d4,a0
	move.w	($22,a0),(-$2,a6)
	move.l	(-$4,a6),d1
	ext.l	d1
	move.l	d1,(-$4,a6)
	move.l	(-$4,a6),d1
	sub.l	ram_FFDBFE,d1
	move.l	d1,(-$4,a6)
.l3927A:
	moveq	#$0,d0
	movea.l	d4,a0
	move.w	($28,a0),d0
	move.l	d0,d1
	lsr.l	#2,d1
	neg.l	d1
	move.l	(-$4,a6),d2
	cmp.l	d1,d2
	bge.s	.l392A8
	movea.l	d4,a0
	cmpi.w	#$2,($10,a0)
	beq.s	.l3929E
	movea.l	d4,a0
	bra.s	.l392A0
.l3929E:
	movea.l	d6,a0
.l392A0:
	clr.w	($1E,a0)
	bra.w	.l39966
.l392A8:
	movea.l	d4,a1
	move.w	($36,a1),(-$10,a6)
	subi.w	#$400,(-$10,a6)
	movea.l	d4,a1
	move.w	($2A,a1),(-$12,a6)
	subi.w	#$C0,(-$12,a6)
	movea.l	(-$A,a6),a1
	movea.l	($8,a1),a0
	move.w	($10,a0),(-$E,a6)
	andi.w	#$80,(-$E,a6)
	move.w	(a3),(-$6,a6)
	movea.l	d4,a1
	move.w	(-$6,a6),d1
	sub.w	($30,a1),d1
	move.w	d1,(-$6,a6)
	tst.w	(-$E,a6)
	beq.w	.l39376
	tst.w	(-$6,a6)
	blt.s	.l39300
	cmpi.b	#$1,($3,a2)
	bhi.s	.l3930E
.l39300:
	tst.w	(-$6,a6)
	bge.s	.l3933C
	cmpi.b	#$1,($2,a2)
	bls.s	.l3933C
.l3930E:
	tst.w	(-$6,a6)
	blt.s	.l3931E
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	bra.s	.l39328
.l3931E:
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	neg.l	d1
.l39328:
	movea.l	d1,a0
	moveq	#$0,d2
	moveq	#$0,d0
	move.w	(-$12,a6),d0
	move.l	d0,d1
	cmp.l	a0,d1
	scc	d2
	neg.b	d2
	bra.s	.l39372
.l3933C:
	tst.w	(-$6,a6)
	blt.s	.l3934C
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	bra.s	.l39356
.l3934C:
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	neg.l	d1
.l39356:
	movea.l	d1,a0
	moveq	#$0,d2
	moveq	#$0,d0
	movea.l	d4,a1
	move.w	($2A,a1),d0
	move.l	d0,d1
	cmp.l	a0,d1
	scc	d2
	neg.b	d2
	movea.l	d4,a1
	move.w	($2A,a1),(-$12,a6)
.l39372:
	bra.w	.l3941E
.l39376:
	tst.w	(-$6,a6)
	blt.s	.l39384
	cmpi.b	#$1,($3,a2)
	bhi.s	.l3939A
.l39384:
	tst.w	(-$6,a6)
	bge.s	.l39392
	cmpi.b	#$1,($2,a2)
	bhi.s	.l3939A
.l39392:
	movea.l	d4,a0
	move.w	($36,a0),(-$10,a6)
.l3939A:
	movea.l	(-$A,a6),a1
	movea.l	($8,a1),a0
	move.w	($A,a0),d0
	cmpi.w	#$4B0,d0
	bcs.s	.l393B0
	bhi.s	.l393C2
	bra.s	.l393D2
.l393B0:
	cmpi.w	#$320,d0
	bcs.s	.l393F2
	bhi.s	.l393BA
	bra.s	.l393CA
.l393BA:
	cmpi.w	#$3E8,d0
	bne.s	.l393F2
	bra.s	.l393D2
.l393C2:
	cmpi.w	#$C80,d0
	bne.s	.l393F2
	bra.s	.l393E8
.l393CA:
	move.w	(-$10,a6),d0
	lsl.w	#1,d0
	bra.s	.l393EE
.l393D2:
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,d1
	lsr.l	#1,d1
	move.w	(-$10,a6),d2
	add.w	d1,d2
	move.w	d2,(-$10,a6)
	bra.s	.l393F2
.l393E8:
	move.w	(-$10,a6),d0
	lsr.w	#1,d0
.l393EE:
	move.w	d0,(-$10,a6)
.l393F2:
	tst.w	(-$6,a6)
	blt.s	.l39402
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	bra.s	.l3940C
.l39402:
	movea.w	(-$6,a6),a0
	move.l	a0,d1
	ext.l	d1
	neg.l	d1
.l3940C:
	movea.l	d1,a0
	moveq	#$0,d2
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,d1
	cmp.l	a0,d1
	scc	d2
	neg.b	d2
.l3941E:
	tst.w	d2
	beq.w	.l39966
	tst.l	(-$4,a6)
	blt.s	.l39430
	move.l	(-$4,a6),d2
	bra.s	.l39436
.l39430:
	move.l	(-$4,a6),d2
	neg.l	d2
.l39436:
	moveq	#$0,d0
	movea.l	d4,a0
	move.w	($28,a0),d0
	move.l	d0,d1
	cmp.l	d2,d1
	bcs.w	.l39966
	tst.b	(a4)
	beq.w	.l394FC
	move.w	ram_FFDCFC,(-$C,a6)
	movea.l	d4,a0
	move.w	(-$C,a6),d1
	sub.w	($72,a0),d1
	move.w	d1,(-$C,a6)
	cmpi.w	#$100,ram_FFDCFC
	blt.s	.l3949C
	movea.l	d4,a0
	tst.b	($6A,a0)
	bne.s	.l39478
	bra.w	.l39966
.l39478:
	tst.w	(-$C,a6)
	blt.s	.l39486
	move.w	(-$C,a6),d0
	ext.l	d0
	bra.s	.l3948E
.l39486:
	move.w	(-$C,a6),d0
	ext.l	d0
	neg.l	d0
.l3948E:
	cmpi.l	#$100,d0
	ble.s	.l3949A
	bra.w	.l39966
.l3949A:
	bra.s	.l394C6
.l3949C:
	movea.l	d4,a0
	tst.b	($6A,a0)
	beq.s	.l394C6
	tst.w	(-$C,a6)
	blt.s	.l394B2
	move.w	(-$C,a6),d0
	ext.l	d0
	bra.s	.l394BA
.l394B2:
	move.w	(-$C,a6),d0
	ext.l	d0
	neg.l	d0
.l394BA:
	cmpi.l	#$100,d0
	ble.s	.l394C6
	bra.w	.l39966
.l394C6:
	movea.l	d4,a0
	cmpi.w	#$6,($10,a0)
	bne.s	.l394F4
	movea.l	d4,a0
	move.w	#$11C7,($20,a0)
	btst	#$0,$FFFF8017
	beq.s	.l394F2
	movea.l	d4,a0
	move.w	($20,a0),d1
	ext.l	d1
	neg.l	d1
	movea.l	d4,a0
	move.w	d1,($20,a0)
.l394F2:
	bra.s	.l394FC
.l394F4:
	movea.l	d4,a0
	move.w	#$C8,($3C,a0)
.l394FC:
	pea	$63.w
	jsr	queue_sound_command
	movea.l	d4,a2
	cmpi.w	#$5,($10,a2)
	addq.l	#4,sp
	bne.s	.l3951E
	pea	$5.w
	jsr	sub_41606
	addq.l	#4,sp
.l3951E:
	movea.w	ram_FFDD16,a0
	movea.l	d4,a1
	suba.w	($1E,a1),a0
	tst.l	(-$4,a6)
	bge.s	.l39566
	movea.l	d4,a1
	cmpi.w	#$2,($10,a1)
	beq.s	.l39566
	move.w	a0,d1
	ext.l	d1
	movea.l	d4,a1
	divs.w	($3E,a1),d1
	ext.l	d1
	moveq	#$20,d0
	cmp.l	d1,d0
	bhi.s	.l3955A
	move.w	a0,d1
	ext.l	d1
	movea.l	d4,a1
	divs.w	($3E,a1),d1
	ext.l	d1
	bra.s	.l3955C
.l3955A:
	moveq	#$20,d1
.l3955C:
	move.w	d1,d0
	movea.l	d4,a1
	sub.w	d0,($1E,a1)
	bra.s	.l395B8
.l39566:
	move.w	a0,d1
	ext.l	d1
	movea.l	d4,a1
	divs.w	($3E,a1),d1
	move.w	d1,d2
	move.w	a0,d1
	ext.l	d1
	asl.l	#1,d1
	sub.w	d2,d1
	cmp.w	ram_FFDD1E,d1
	ble.s	.l395A8
	cmp.w	ram_FFDD16,d1
	ble.s	.l39592
	clr.w	ram_FFDD1A
	bra.s	.l395A0
.l39592:
	move.w	a0,d0
	sub.w	ram_FFDD1E,d0
	sub.w	d0,ram_FFDD1A
.l395A0:
	clr.w	ram_FFDD1E
	bra.s	.l395B0
.l395A8:
	move.w	d1,d0
	sub.w	d0,ram_FFDD1E
.l395B0:
	move.w	d2,d0
	movea.l	d6,a1
	add.w	d0,($1E,a1)
.l395B8:
	move.l	a0,d0
	tst.w	d0
	blt.s	.l395C4
	move.w	a0,d0
	ext.l	d0
	bra.s	.l395CA
.l395C4:
	move.w	a0,d0
	ext.l	d0
	neg.l	d0
.l395CA:
	movea.w	d0,a0
	move.w	a0,d1
	ext.l	d1
	asl.l	#3,d1
	movea.w	d1,a3
	movea.l	d4,a2
	movea.w	($20,a2),a1
	movea.l	d5,a2
	suba.w	(a2),a1
	move.l	a1,d2
	tst.w	d2
	blt.s	.l395EA
	move.w	a1,d0
	ext.l	d0
	bra.s	.l395F0
.l395EA:
	move.w	a1,d0
	ext.l	d0
	neg.l	d0
.l395F0:
	movea.w	d0,a1
	tst.w	(-$6,a6)
	ble.s	.l395FC
	moveq	#$3,d0
	bra.s	.l395FE
.l395FC:
	moveq	#$2,d0
.l395FE:
	movea.w	d0,a4
	tst.w	(-$E,a6)
	beq.s	.l39628
	tst.w	(-$6,a6)
	blt.s	.l39614
	move.w	(-$6,a6),d0
	ext.l	d0
	bra.s	.l3961C
.l39614:
	move.w	(-$6,a6),d0
	ext.l	d0
	neg.l	d0
.l3961C:
	moveq	#$0,d2
	move.l	(-$4,a6),d1
	cmp.l	d0,d1
	sgt	d2
	bra.s	.l3964E
.l39628:
	tst.w	(-$6,a6)
	blt.s	.l39636
	move.w	(-$6,a6),d3
	ext.l	d3
	bra.s	.l3963E
.l39636:
	move.w	(-$6,a6),d3
	ext.l	d3
	neg.l	d3
.l3963E:
	moveq	#$0,d2
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,d1
	lsr.l	#1,d1
	cmp.l	d1,d3
	slt	d2
.l3964E:
	neg.b	d2
	tst.l	(-$4,a6)
	ble.s	.l3965C
	tst.w	d2
	beq.s	.l3965C
	subq.w	#2,a4
.l3965C:
	tst.l	(-$4,a6)
	blt.s	.l39668
	move.l	(-$4,a6),d3
	bra.s	.l3966E
.l39668:
	move.l	(-$4,a6),d3
	neg.l	d3
.l3966E:
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($28,a2),d0
	move.l	d0,d1
	moveq	#$0,d2
	movea.l	d4,a2
	move.w	($28,a2),d2
	lsr.l	#3,d2
	sub.l	d2,d1
	cmp.l	d1,d3
	bge.s	.l3969E
	move.w	(-$10,a6),d0
	cmp.w	a3,d0
	bhi.s	.l39696
	move.w	a3,d1
	ext.l	d1
	bra.s	.l3969C
.l39696:
	moveq	#$0,d1
	move.w	(-$10,a6),d1
.l3969C:
	movea.w	d1,a3
.l3969E:
	tst.w	(-$E,a6)
	beq.s	.l396C0
	move.w	a0,d1
	ext.l	d1
	move.w	a1,d0
	ext.l	d0
	asl.l	#1,d0
	cmp.l	d0,d1
	bgt.s	.l396BA
	move.w	a1,d0
	ext.l	d0
	asl.l	#1,d0
	bra.s	.l396BE
.l396BA:
	move.w	a0,d0
	ext.l	d0
.l396BE:
	bra.s	.l396DA
.l396C0:
	move.w	a0,d1
	ext.l	d1
	move.w	a1,d0
	ext.l	d0
	asr.l	#2,d0
	cmp.l	d0,d1
	bgt.s	.l396D6
	move.w	a1,d0
	ext.l	d0
	asr.l	#2,d0
	bra.s	.l396DA
.l396D6:
	move.w	a0,d0
	ext.l	d0
.l396DA:
	move.w	d0,(-$C,a6)
	tst.w	(-$6,a6)
	bge.s	.l3971E
	move.w	a3,d1
	ext.l	d1
	neg.l	d1
	movea.w	d1,a3
	tst.w	(-$E,a6)
	beq.s	.l39704
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($30,a2),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.w	(-$12,a6),d0
	bra.s	.l39714
.l39704:
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($30,a2),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.w	(-$10,a6),d0
.l39714:
	sub.l	d0,d1
	move.w	d1,ram_FFDC1A
	bra.s	.l3974E
.l3971E:
	tst.w	(-$E,a6)
	beq.s	.l39736
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($30,a2),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.w	(-$12,a6),d0
	bra.s	.l39746
.l39736:
	moveq	#$0,d0
	movea.l	d4,a2
	move.w	($30,a2),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.w	(-$10,a6),d0
.l39746:
	add.l	d0,d1
	move.w	d1,ram_FFDC1A
.l3974E:
	movea.l	d4,a2
	cmpi.w	#$2,($10,a2)
	beq.s	.l39766
	move.w	a3,d0
	ext.l	d0
	movea.l	d4,a2
	divs.w	($3E,a2),d0
	movea.l	d4,a2
	bra.s	.l39772
.l39766:
	move.w	a3,d0
	ext.l	d0
	movea.l	d4,a2
	divs.w	($3E,a2),d0
	movea.l	d6,a2
.l39772:
	sub.w	d0,($20,a2)
	movea.l	d5,a2
	move.w	a3,(a2)
	movea.l	d5,a2
	tst.w	(a2)
	blt.s	.l39788
	movea.l	d5,a2
	move.w	(a2),d0
	ext.l	d0
	bra.s	.l39790
.l39788:
	movea.l	d5,a2
	move.w	(a2),d0
	ext.l	d0
	neg.l	d0
.l39790:
	cmpi.l	#$1000,d0
	ble.s	.l397B0
	move.l	a3,d0
	tst.w	d0
	bge.s	.l397A6
	move.l	#$FFFFF000,d0
	bra.s	.l397AC
.l397A6:
	move.l	#$1000,d0
.l397AC:
	movea.l	d5,a2
	move.w	d0,(a2)
.l397B0:
	tst.w	(-$E,a6)
	beq.s	.l397D8
	movea.l	d5,a2
	move.w	(a2),d0
	asr.w	#4,d0
	movea.l	d5,a2
	move.w	d0,(a2)
	move.l	a1,d1
	cmpi.w	#$E3,d1
	bcc.s	.l397D0
	move.l	a0,d0
	cmpi.w	#$E0,d0
	bcs.s	.l397D6
.l397D0:
	move.w	#$301,(-$C,a6)
.l397D6:
	bra.s	.l397EE
.l397D8:
	move.l	a1,d0
	cmpi.w	#$71C,d0
	bcc.s	.l397E8
	move.l	a0,d0
	cmpi.w	#$118,d0
	bcs.s	.l397EE
.l397E8:
	move.w	#$301,(-$C,a6)
.l397EE:
	move.w	a4,d1
	add.w	d1,d1
	movea.l	#ram_FF9546,a0
	move.w	(-$C,a6),d0
	add.w	d0,($0,a0,d1.w)
	move.w	a4,d0
	add.w	d0,d0
	movea.l	#ram_FF9546,a0
	cmpi.w	#$300,($0,a0,d0.w)
	bls.w	.l39962
	moveq	#$4,d2
	movea.l	d5,a5
	move.w	(a5),d0
	asl.w	#1,d0
	movea.l	d5,a5
	move.w	d0,(a5)
	clr.w	ram_FFDD1E
	move.w	#$190,ram_FFDD1A
	movea.l	d4,a5
	move.w	#$C8,($3C,a5)
	clr.w	(-$C,a6)
	move.w	a4,d1
	add.w	d1,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	movea.l	#dat_4D778,a0
	adda.w	d1,a0
	movea.l	a0,a1
	movea.l	#ram_FFBBBE,a2
.l39854:
	moveq	#$0,d0
	move.w	(a1),d0
	move.b	($0,a2,d0.l),d1
	ext.w	d1
	ext.l	d1
	cmp.l	d2,d1
	bne.w	.l39950
	move.l	a4,d0
	subq.w	#2,d0
	bge.s	.l3987C
	move.w	a4,d0
	movea.l	#ram_FFDCE4,a0
	move.b	#$1,($0,a0,d0.w)
	bra.s	.l39894
.l3987C:
	tst.w	(-$C,a6)
	beq.s	.l39886
	moveq	#$2,d1
	bra.s	.l39888
.l39886:
	moveq	#$1,d1
.l39888:
	move.w	a4,d0
	movea.l	#ram_FFDCE4,a0
	move.b	d1,($0,a0,d0.w)
.l39894:
	move.b	#$1,ram_FFDCE8
	move.w	a4,d1
	add.w	d1,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	movea.l	#dat_4D778,a0
	move.w	(-$C,a6),d0
	add.w	d0,d0
	adda.w	d1,a0
	tst.w	($0,a0,d0.w)
	beq.s	.l3991A
	move.w	a4,d1
	add.w	d1,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	movea.l	#dat_4D778,a0
	move.w	(-$C,a6),d2
	add.w	d2,d2
	adda.w	d1,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.w),d0
	movea.l	#ram_FFBBC6,a0
	move.b	#$1,($0,a0,d0.l)
	move.w	a4,d1
	add.w	d1,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	movea.l	#dat_4D778,a0
	move.w	(-$C,a6),d2
	add.w	d2,d2
	adda.w	d1,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.w),d0
	add.l	d0,d0
	movea.l	#ram_FFBBCE,a0
	move.w	#$FFE0,($0,a0,d0.l)
	move.w	#$C8,ram_FFDD1E
	bra.s	.l39940
.l3991A:
	move.l	a3,d0
	tst.w	d0
	bge.s	.l39928
	move.l	#$FFFFF05C,d0
	bra.s	.l3992E
.l39928:
	move.l	#$FA4,d0
.l3992E:
	move.w	d0,ram_FFDD4A
	move.w	ram_FFDD4A,d0
	add.w	d0,ram_FFDD26
.l39940:
	move.w	a4,d0
	add.w	d0,d0
	movea.l	#ram_FF9546,a0
	clr.w	($0,a0,d0.w)
	bra.s	.l39962
.l39950:
	addq.w	#1,(-$C,a6)
	addq.l	#2,a1
	move.w	(-$C,a6),d1
	ext.l	d1
	cmp.l	d2,d1
	blt.w	.l39854
.l39962:
	moveq	#$0,d0
	bra.s	.l39970
.l39966:
	movea.l	d4,a0
	move.l	(a0),d4
.l3996A:
	cmp.l	d3,d4
	bne.w	.l391C0
.l39970:
	movem.l	(-$40,a6),d2-d7/a2-a5
	unlk	a6
	rts
sub_3997A:
	link	a6,#$0
	movem.l	d2-d4/a2-a3,-(sp)
	movea.l	#dat_4D778,a3
	moveq	#$4,d1
	moveq	#$0,d3
	moveq	#$2,d2
	moveq	#$0,d4
	movea.l	#ram_FFDCE4,a0
	bra.s	.l399AC
.l39998:
	moveq	#$0,d0
	move.b	(a0),d0
	cmp.l	d2,d0
	bhi.s	.l399A8
	moveq	#$0,d0
	move.b	(a0),d0
	move.l	d0,d2
	move.l	d3,d4
.l399A8:
	addq.l	#1,d3
	addq.l	#1,a0
.l399AC:
	cmp.l	d1,d3
	blt.s	.l39998
	movea.l	ram_FFDBEE,a0
	movea.l	(a0),a0
	movea.l	($8,a0),a0
	btst	#$7,($11,a0)
	beq.s	.l399DE
	btst	#$0,$FFFF8017
	beq.s	.l399D6
	move.l	#$444,d0
	bra.s	.l399DC
.l399D6:
	move.l	#$FFFFFBBC,d0
.l399DC:
	bra.s	.l399F6
.l399DE:
	btst	#$0,$FFFF8017
	beq.s	.l399F0
	move.l	#$1C71,d0
	bra.s	.l399F6
.l399F0:
	move.l	#$FFFFE38F,d0
.l399F6:
	add.w	d0,ram_FFDD1C
	moveq	#$4,d1
	moveq	#$0,d3
	move.w	d4,d0
	add.w	d0,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d2,d0
	movea.l	a3,a0
	adda.w	d0,a0
	movea.l	a0,a1
	movea.l	#ram_FFBBBE,a2
.l39A16:
	moveq	#$0,d0
	move.w	(a1),d0
	move.b	($0,a2,d0.l),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d1,d0
	bne.w	.l39B6E
	moveq	#$2,d0
	cmp.l	d4,d0
	ble.s	.l39A3E
	move.w	d4,d0
	movea.l	#ram_FFDCE4,a0
	move.b	#$1,($0,a0,d0.w)
	bra.s	.l39A54
.l39A3E:
	tst.l	d3
	beq.s	.l39A46
	moveq	#$2,d1
	bra.s	.l39A48
.l39A46:
	moveq	#$1,d1
.l39A48:
	move.w	d4,d0
	movea.l	#ram_FFDCE4,a0
	move.b	d1,($0,a0,d0.w)
.l39A54:
	move.b	#$1,ram_FFDCE8
	move.w	d4,d0
	add.w	d0,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d2,d0
	movea.l	a3,a0
	move.w	d3,d1
	add.w	d1,d1
	adda.w	d0,a0
	tst.w	($0,a0,d1.w)
	beq.w	.l39B3C
	move.w	d4,d0
	add.w	d0,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d2,d0
	movea.l	a3,a0
	move.w	d3,d1
	add.w	d1,d1
	adda.w	d0,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	movea.l	#ram_FFBBC6,a0
	move.b	#$1,($0,a0,d0.l)
	move.w	d4,d0
	add.w	d0,d0
	movea.l	#ram_FF9546,a0
	clr.w	($0,a0,d0.w)
	move.w	d4,d0
	add.w	d0,d0
	move.w	d0,d2
	add.w	d0,d0
	add.w	d2,d0
	movea.l	a3,a0
	move.w	d3,d1
	add.w	d1,d1
	adda.w	d0,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	add.l	d0,d0
	movea.l	#ram_FFBBCE,a0
	move.w	#$FFE0,($0,a0,d0.l)
	tst.w	ram_FFDD1C
	bge.s	.l39ADE
	move.l	#$F333,d0
	bra.s	.l39AE4
.l39ADE:
	move.l	#$CCC,d0
.l39AE4:
	move.w	d0,ram_FFDD26
	move.w	ram_FFDD1E,d0
	ext.l	d0
	divs.w	#$3,d0
	sub.w	d0,ram_FFDD1E
	moveq	#$2,d0
	cmp.l	d4,d0
	ble.s	.l39B14
	tst.l	d4
	beq.s	.l39B0A
	moveq	#-$40,d0
	bra.s	.l39B0C
.l39B0A:
	moveq	#$40,d0
.l39B0C:
	move.l	d0,d3
	pea	$100.w
	bra.s	.l39B26
.l39B14:
	moveq	#$3,d0
	cmp.l	d4,d0
	bne.s	.l39B1E
	moveq	#-$80,d3
	bra.s	.l39B24
.l39B1E:
	move.l	#$80,d3
.l39B24:
	clr.l	-(sp)
.l39B26:
	pea	$20.w
	move.l	d3,-(sp)
	pea	$2.w
	jsr	sub_3DCBC
	lea	($10,sp),sp
	bra.s	.l39B6C
.l39B3C:
	move.w	#$FA4,ram_FFDD4A
	move.w	ram_FFDD4A,d0
	add.w	d0,ram_FFDD26
	clr.w	ram_FFDD1E
	clr.l	-(sp)
	pea	$80.w
	clr.l	-(sp)
	pea	$2.w
	jsr	sub_3DCBC
	lea	($10,sp),sp
.l39B6C:
	bra.s	.l39B78
.l39B6E:
	addq.l	#1,d3
	addq.l	#2,a1
	cmp.l	d1,d3
	blt.w	.l39A16
.l39B78:
	movem.l	(-$14,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_39B82:
	link	a6,#$FFD0
	movem.l	d2-d6/a2-a5,-(sp)
	move.w	($A,a6),(-$2,a6)
	move.b	($F,a6),d4
	move.l	#$FFDD1C,(-$6,a6)
	jsr	sub_3AE30
	tst.b	ram_FFDCF6
	beq.w	.l39C16
	btst	#$0,ram_FF9567
	beq.w	.l39C16
	movea.l	#ram_FFDCF6,a0
	move.b	(a0),d0
	addq.b	#1,(a0)
	moveq	#$0,d2
	move.b	d0,d2
	add.w	d2,d2
	movea.l	#dat_4D7A0,a0
	moveq	#$0,d0
	move.w	($0,a0,d2.w),d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,ram_FF9E58
	cmpi.b	#$5,ram_FFDCF6
	addq.l	#4,sp
	bcs.s	.l39C0E
	tst.w	ram_FFDD80
	bne.s	.l39C08
	pea	$7.w
	jsr	object_descriptor
	move.l	d0,ram_FF9E58
	addq.l	#4,sp
.l39C08:
	clr.b	ram_FFDCF6
.l39C0E:
	move.b	#$1,ram_FFDC1C
.l39C16:
	move.w	#$7E0,(-$18,a6)
	tst.w	ram_FFDD4E
	beq.w	.l39D22
	move.b	ram_FF9CB8,d0
	asl.b	#3,d0
	lsr.b	#6,d0
	cmpi.b	#$3,d0
	bcc.w	.l39D22
	move.l	ram_FF9564,d2
	moveq	#$3,d0
	and.l	d0,d2
	bne.s	.l39C78
	moveq	#$3E,d1
	moveq	#$8,d3
	clr.w	d0
	movea.w	d0,a3
	movea.l	#ram_FF9C80,a0
.l39C52:
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	addq.b	#1,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	andi.b	#$E7,($38,a0)
	or.b	d0,($38,a0)
	addq.w	#1,a3
	adda.l	d1,a0
	move.w	a3,d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l39C52
.l39C78:
	btst	#$0,ram_FF9567
	bne.w	.l39D1E
	addq.b	#1,ram_FFDD0A
	cmpi.b	#$6,ram_FFDD0A
	bge.w	.l39D1E
	jsr	sub_2E8FC
	movea.l	d0,a2
	cmpa.w	#$0,a2
	beq.w	.l39D1E
	move.b	ram_FFDD0A,d2
	ext.w	d2
	ext.l	d2
	asr.l	#1,d2
	addi.l	#$CC,d2
	move.l	d2,ram_FFDCEA
	pea	ram_FF9C94
	move.l	ram_FF9C90,-(sp)
	move.l	ram_FF9C8C,-(sp)
	move.l	ram_FF9C88,-(sp)
	move.l	ram_FFDCEA,-(sp)
	jsr	sub_2EF4C
	move.l	d0,($8,a2)
	movea.l	($8,a2),a0
	move.b	ram_FF9CB8,d0
	asl.b	#3,d0
	lsr.b	#6,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	andi.b	#$E7,($38,a0)
	or.b	d0,($38,a0)
	move.l	a2,-(sp)
	pea	ram_FFDACE
	jsr	sub_2E79C
	move.b	#$1,ram_FFDC1C
	lea	($1C,sp),sp
.l39D1E:
	bra.w	.l39D8E
.l39D22:
	tst.w	ram_FFDD4E
	bne.w	.l39D8E
	move.b	ram_FF9CB8,d0
	asl.b	#3,d0
	lsr.b	#6,d0
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,d2
	beq.s	.l39D8E
	move.l	ram_FF9564,d2
	moveq	#$3,d0
	and.l	d0,d2
	bne.s	.l39D8E
	moveq	#$3E,d1
	moveq	#$8,d3
	clr.w	d0
	movea.w	d0,a3
	movea.l	#ram_FF9C80,a0
.l39D58:
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	subq.b	#1,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	andi.b	#$E7,($38,a0)
	or.b	d0,($38,a0)
	addq.w	#1,a3
	adda.l	d1,a0
	move.w	a3,d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l39D58
	bclr	#$5,ram_FF9EA8
	move.b	#$1,ram_FFDC1C
.l39D8E:
	tst.b	ram_FFDD10
	bls.s	.l39D9E
	subq.b	#1,ram_FFDD10
	bra.s	.l39DA4
.l39D9E:
	clr.b	ram_FFDD10
.l39DA4:
	movea.l	ram_FFDBEE,a0
	movea.l	(a0),a2
	move.l	($8,a2),(-$A,a6)
	clr.b	d0
	move.b	d0,d1
	move.b	d0,(-$12,a6)
	move.b	d0,(-$10,a6)
	move.b	(-$10,a6),(-$11,a6)
	clr.w	ram_FFDD24
	movea.l	(-$A,a6),a1
	move.b	($11,a1),(-$F,a6)
	andi.b	#$80,(-$F,a6)
	clr.l	ram_FFDD72
	tst.w	ram_FFDD4E
	beq.s	.l39DF8
	clr.l	ram_FFDD6A
	move.w	dat_4D83A,d2
	bra.w	.l39F2E
.l39DF8:
	movea.l	(-$A,a6),a0
	tst.b	($4,a0)
	beq.w	.l39F22
	move.w	ram_FFDD16,d3
	ext.l	d3
	asr.l	#1,d3
	move.l	d3,d2
	move.l	d3,d0
	move.l	d0,d1
	mulu.w	d2,d3
	swap	d0
	mulu.w	d2,d0
	swap	d2
	mulu.w	d2,d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	add.l	d1,d3
	move.l	d3,d2
	move.w	dat_4D82C,d0
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
	movea.l	(-$A,a6),a4
	move.b	($4,a4),d0
	ext.w	d0
	ext.l	d0
	addq.l	#4,d0
	asl.w	#2,d0
	movea.l	#dat_4D7AA,a0
	move.l	($0,a0,d0.w),d1
	move.l	d2,d0
	jsr	sub_23E70
	movea.w	d0,a3
	move.l	a3,d5
	tst.w	d5
	blt.s	.l39E90
	move.w	a3,d2
	ext.l	d2
	cmp.l	ram_FFDD6A,d2
	ble.s	.l39E8A
	move.w	a3,d0
	ext.l	d0
	asr.l	#3,d0
	add.l	ram_FFDD6A,d0
	bra.s	.l39E8E
.l39E8A:
	move.w	a3,d0
	ext.l	d0
.l39E8E:
	bra.s	.l39EAE
.l39E90:
	move.w	a3,d2
	ext.l	d2
	cmp.l	ram_FFDD6A,d2
	bge.s	.l39EAA
	move.w	a3,d0
	ext.l	d0
	asr.l	#3,d0
	add.l	ram_FFDD6A,d0
	bra.s	.l39EAE
.l39EAA:
	move.w	a3,d0
	ext.l	d0
.l39EAE:
	move.l	d0,ram_FFDD6A
	movea.l	(-$A,a6),a0
	tst.b	($4,a0)
	ble.s	.l39EF0
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	move.l	d0,d2
	andi.l	#$8000,d2
	beq.s	.l39EE6
	move.l	#$10000,d1
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	move.l	d0,d2
	sub.l	d2,d1
	asr.l	#8,d1
	bra.s	.l39EE8
.l39EE6:
	moveq	#$0,d1
.l39EE8:
	move.w	d1,ram_FFDD24
	bra.s	.l39F20
.l39EF0:
	movea.l	(-$A,a6),a0
	tst.b	($4,a0)
	bge.s	.l39F20
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	move.l	d0,d2
	andi.l	#$8000,d2
	beq.s	.l39F10
	moveq	#$0,d2
	bra.s	.l39F1A
.l39F10:
	moveq	#$0,d2
	move.w	ram_FFDC1A,d2
	lsr.l	#8,d2
.l39F1A:
	move.w	d2,ram_FFDD24
.l39F20:
	bra.s	.l39F28
.l39F22:
	clr.l	ram_FFDD6A
.l39F28:
	move.w	dat_4D838,d2
.l39F2E:
	ext.l	d2
	neg.l	d2
	move.l	d2,ram_FFDD6E
	tst.b	(-$F,a6)
	beq.s	.l39F4C
	movea.w	#$4000,a3
	clr.w	d6
	clr.w	ram_FFDD24
	bra.s	.l39F72
.l39F4C:
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	movea.w	d0,a3
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.w	d0,d6
	addq.l	#8,sp
.l39F72:
	move.l	ram_FFDD6A,d2
	move.w	a3,d0
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
	moveq	#$E,d0
	asr.l	d0,d2
	move.l	ram_FFDD6E,d5
	move.w	d6,d3
	ext.l	d3
	move.l	d5,d0
	move.l	d0,d1
	mulu.w	d3,d5
	swap	d0
	mulu.w	d3,d0
	swap	d3
	mulu.w	d3,d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	add.l	d1,d5
	moveq	#$E,d0
	asr.l	d0,d5
	sub.l	d5,d2
	move.l	d2,(-$30,a6)
	move.l	ram_FFDD6A,d2
	move.w	d6,d0
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
	moveq	#$E,d0
	asr.l	d0,d2
	move.l	ram_FFDD6E,d5
	move.w	a3,d3
	ext.l	d3
	move.l	d5,d0
	move.l	d0,d1
	mulu.w	d3,d5
	swap	d0
	mulu.w	d3,d0
	swap	d3
	mulu.w	d3,d1
	add.l	d0,d1
	swap	d1
	clr.w	d1
	add.l	d1,d5
	moveq	#$E,d0
	asr.l	d0,d5
	add.l	d5,d2
	move.l	d2,(-$2C,a6)
	clr.l	(-$28,a6)
	moveq	#$0,d2
	move.l	d2,(-$1C,a6)
	move.l	d2,(-$24,a6)
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	mulu.w	ram_FFDC1A,d0
	move.w	dat_4D836,d3
	ext.l	d3
	move.l	d0,d1
	move.l	d1,d2
	mulu.w	d3,d0
	swap	d1
	mulu.w	d3,d1
	swap	d3
	mulu.w	d3,d2
	add.l	d1,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	move.l	#$640,d1
	jsr	sub_23E62
	move.l	d0,(-$20,a6)
	moveq	#$0,d0
	move.w	($18,a2),d0
	move.l	d0,d2
	andi.l	#$4000,d2
	beq.s	.l3A08A
	moveq	#$0,d0
	move.w	($18,a2),d0
	move.l	d0,d2
	andi.l	#$3FFF,d2
	moveq	#$9,d0
	asr.l	d0,d2
	moveq	#$0,d3
	move.w	d2,d3
	movea.l	#ram_FFDE9A,a0
	move.b	#$1,($0,a0,d3.l)
.l3A08A:
	move.w	($18,a2),d2
	andi.w	#$1FF,d2
	tst.b	ram_FFDCF4
	bne.w	loc_3A508
	tst.w	d2
	beq.w	loc_3A508
	moveq	#$0,d3
	move.w	d2,d3
	asl.l	#2,d3
	movea.l	#dat_4C712,a0
	move.l	($0,a0,d3.l),(-$16,a6)
	movea.l	#ram_FFDCF0,a2
	movea.l	#ram_FFDCF4,a3
	movea.l	#ram_FFDCF8,a4
	move.l	#$FFDD16,d5
	move.l	#$FFDCFC,d6
	bra.w	loc_3A4FE
loc_3A0D6:
	movea.l	(-$16,a6),a0
	move.l	(a0)+,(-$E,a6)
	move.l	a0,(-$16,a6)
	movea.l	(-$E,a6),a0
	move.w	($10,a0),d0
	cmpi.w	#$7,d0
	bhi.w	loc_3A4FE
	add.w	d0,d0
	move.w	(.l3A0FC,pc,d0.w),d0
	jmp	(.l3A0FC,pc,d0.w)
.l3A0FC:
	dc.w	loc_3A4FE-.l3A0FC
	dc.w	sub_3A10C-.l3A0FC
	dc.w	sub_3A21C-.l3A0FC
	dc.w	sub_3A3B4-.l3A0FC
	dc.w	sub_3A1E6-.l3A0FC
	dc.w	sub_3A262-.l3A0FC
	dc.w	loc_3A4FE-.l3A0FC
	dc.w	sub_3A31E-.l3A0FC
sub_3A10C:
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.w	.l3A1E2
	cmpi.w	#$32,ram_FFDD4E
	bhi.w	.l3A1CA
	pea	$31.w
	jsr	queue_sound_command
	pea	$4.w
	jsr	sub_41606
	pea	$A.w
	jsr	sub_23FBA
	tst.l	d0
	lea	($C,sp),sp
	bne.s	.l3A172
	pea	$5C.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A172:
	tst.b	ram_FFDCF2
	bne.s	.l3A1A6
	movea.l	#ram_FFDD50,a0
	addq.w	#1,(a0)
	move.w	(a0),d2
	moveq	#$0,d1
	move.w	d2,d1
	move.l	d1,d2
	muls.w	#$C8,d2
	move.l	d2,ram_FFDD0C
	move.l	ram_FFDD0C,d2
	add.l	d2,ram_FF9532
	addq.w	#1,ram_FFDD08
.l3A1A6:
	bset	#$5,ram_FF9EA8
	move.b	#$1,ram_FFDC1C
	tst.b	ram_FFDCEE
	beq.s	.l3A1CA
	pea	$2E.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A1CA:
	move.w	#$3C,ram_FFDD4E
	tst.b	ram_FFDCF2
	bne.s	.l3A1E2
	move.b	#$14,ram_FFDD10
.l3A1E2:
	bra.w	loc_3A4FE
sub_3A1E6:
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.s	.l3A218
	pea	$31.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A218:
	bra.w	loc_3A4FE
sub_3A21C:
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.s	.l3A25E
	move.l	(-$E,a6),d0
	cmp.l	ram_FFDD78,d0
	beq.s	.l3A25C
	addq.w	#1,ram_FFDD04
	move.l	(-$E,a6),ram_FFDD78
.l3A25C:
	moveq	#$1,d1
.l3A25E:
	bra.w	loc_3A4FE
sub_3A262:
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.w	.l3A31A
	move.l	(-$E,a6),d0
	cmp.l	ram_FFDD78,d0
	beq.w	.l3A314
	addq.w	#1,ram_FFDD02
	move.w	ram_FF9578,d0
	ext.l	d0
	movea.l	#dat_4EE4E,a0
	tst.b	($0,a0,d0.l)
	beq.s	.l3A2DA
	move.w	ram_FF9578,d1
	ext.l	d1
	movea.l	#dat_4EE4E,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	cmp.w	ram_FFDD02,d0
	bne.s	.l3A2DA
	pea	$16.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A2DA:
	tst.w	ram_FF9578
	beq.s	.l3A2EA
	move.l	#$1F4,d2
	bra.s	.l3A2EC
.l3A2EA:
	moveq	#$32,d2
.l3A2EC:
	add.l	d2,ram_FF9532
	move.l	(-$E,a6),ram_FFDD78
	tst.w	ram_FF9578
	beq.s	.l3A308
	pea	$5F.w
	bra.s	.l3A30C
.l3A308:
	pea	$6C.w
.l3A30C:
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A314:
	moveq	#$1,d0
	move.b	d0,(-$12,a6)
.l3A31A:
	bra.w	loc_3A4FE
sub_3A31E:
	cmpi.w	#$6,ram_FFDD80
	bcc.w	.l3A3B0
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.w	.l3A3B0
	move.l	(-$E,a6),d0
	cmp.l	ram_FFDD7C,d0
	beq.s	.l3A3AA
	tst.w	ram_FFDD80
	bne.s	.l3A390
	pea	$3.w
	jsr	sub_41606
	moveq	#$0,d0
	move.w	dat_4D7A0,d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,ram_FF9E58
	move.b	#$1,ram_FFDC1C
	addq.l	#8,sp
.l3A390:
	addq.w	#1,ram_FFDD80
	move.l	(-$E,a6),ram_FFDD7C
	pea	$6B.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A3AA:
	moveq	#$1,d0
	move.b	d0,(-$11,a6)
.l3A3B0:
	bra.w	loc_3A4FE
sub_3A3B4:
	moveq	#$1,d2
	move.b	d2,(-$10,a6)
	moveq	#$0,d0
	movea.l	(-$A,a6),a5
	move.w	($A,a5),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	(-$F,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_3B02C
	tst.l	d0
	lea	($C,sp),sp
	beq.w	.l3A4B2
	tst.b	(a2)
	beq.s	.l3A422
	moveq	#$0,d0
	movea.l	(-$E,a6),a0
	move.w	($A,a0),d0
	neg.l	d0
	cmp.w	ram_FFDD14,d0
	ble.s	.l3A402
	clr.w	ram_FFDD00
	bra.s	.l3A41E
.l3A402:
	moveq	#$0,d0
	movea.l	(-$E,a6),a0
	move.w	($A,a0),d0
	move.l	d0,d3
	move.w	ram_FFDD14,d0
	ext.l	d0
	add.l	d0,d3
	move.w	d3,ram_FFDD00
.l3A41E:
	bra.w	.l3A4B0
.l3A422:
	tst.w	ram_FFDD14
	bge.w	.l3A494
	pea	$60.w
	jsr	queue_sound_command
	pea	$A.w
	jsr	sub_23FBA
	tst.l	d0
	addq.l	#8,sp
	bne.s	.l3A452
	pea	$5C.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l3A452:
	move.b	#$1,(a2)
	move.w	ram_FFDD14,d3
	ext.l	d3
	moveq	#$0,d0
	movea.l	(-$E,a6),a0
	move.w	($A,a0),d0
	neg.l	d0
	cmp.l	d0,d3
	bcc.s	.l3A476
	clr.w	ram_FFDD00
	bra.s	.l3A492
.l3A476:
	moveq	#$0,d0
	movea.l	(-$E,a6),a0
	move.w	($A,a0),d0
	move.l	d0,d3
	move.w	ram_FFDD14,d0
	ext.l	d0
	add.l	d0,d3
	move.w	d3,ram_FFDD00
.l3A492:
	bra.s	.l3A4B0
.l3A494:
	tst.w	ram_FFDD12
	bge.s	.l3A4A4
	move.l	#$FFFFD000,d0
	bra.s	.l3A4AA
.l3A4A4:
	move.l	#$3000,d0
.l3A4AA:
	movea.l	(-$6,a6),a0
	add.w	d0,(a0)
.l3A4B0:
	bra.s	.l3A4FA
.l3A4B2:
	tst.b	(a2)
	beq.s	.l3A4FA
	move.b	#$1,(a3)
	clr.b	(a2)
	movea.l	d5,a5
	move.w	(a5),d2
	ext.l	d2
	divs.w	#$7,d2
	ext.l	d2
	move.l	d2,(a4)
	moveq	#$0,d0
	movea.l	(-$E,a6),a5
	move.w	($A,a5),d0
	move.w	ram_FFDD14,d1
	ext.l	d1
	add.l	d1,d0
	moveq	#$7,d1
	jsr	sub_23E62
	move.l	d0,d3
	movea.l	d6,a5
	move.w	d3,(a5)
	move.w	#$666,ram_FFDCFE
	clr.w	ram_FFDD00
.l3A4FA:
	bra.w	loc_3A4FE
loc_3A4FE:
	movea.l	(-$16,a6),a0
	tst.l	(a0)
	bne.w	loc_3A0D6
loc_3A508:
	tst.b	(-$12,a6)
	bne.s	.l3A514
	clr.l	ram_FFDD78
.l3A514:
	tst.b	(-$11,a6)
	bne.s	.l3A520
	clr.l	ram_FFDD7C
.l3A520:
	tst.b	ram_FFDCF0
	beq.s	.l3A566
	tst.b	(-$10,a6)
	bne.s	.l3A566
	move.b	#$1,ram_FFDCF4
	clr.b	ram_FFDCF0
	move.w	ram_FFDD16,d2
	ext.l	d2
	divs.w	#$7,d2
	ext.l	d2
	move.l	d2,ram_FFDCF8
	move.w	#$1C0,ram_FFDCFC
	move.w	#$666,ram_FFDCFE
	clr.w	ram_FFDD00
.l3A566:
	movea.l	(-$A,a6),a0
	tst.b	($4,a0)
	beq.s	.l3A58A
	movea.l	(-$A,a6),a0
	tst.b	($4,a0)
	bge.s	.l3A582
	move.l	#$C000,d5
	bra.s	.l3A588
.l3A582:
	move.l	#$4000,d5
.l3A588:
	bra.s	.l3A58C
.l3A58A:
	clr.w	d5
.l3A58C:
	clr.w	d0
	movea.l	(-$A,a6),a0
	move.l	($E,a0),d3
	andi.l	#$8000,d3
	beq.w	.l3A64C
	movea.l	(-$A,a6),a1
	movea.w	(a1),a3
	move.l	a3,d2
	subi.w	#$63,d2
	movea.w	d2,a3
	move.w	a3,d1
	ext.l	d1
	asl.l	#2,d1
	movea.l	#dat_4AF22,a0
	moveq	#$0,d0
	move.w	($2,a0,d1.l),d0
	move.l	d0,d3
	move.w	a3,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4AF22,a0
	moveq	#$0,d1
	move.w	($0,a0,d0.l),d1
	cmp.l	d1,d3
	bcc.s	.l3A616
	moveq	#$0,d1
	move.w	a3,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4AF22,a0
	move.w	($2,a0,d0.l),d0
	cmp.w	ram_FFDC1A,d0
	bcc.s	.l3A60C
	move.w	a3,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4AF22,a0
	move.w	($0,a0,d0.l),d0
	cmp.w	ram_FFDC1A,d0
	bls.s	.l3A60C
	moveq	#$1,d1
.l3A60C:
	moveq	#$0,d0
	tst.l	d1
	seq	d0
	neg.b	d0
	bra.s	.l3A64C
.l3A616:
	moveq	#$0,d1
	move.w	a3,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4AF22,a0
	move.w	($0,a0,d0.l),d0
	cmp.w	ram_FFDC1A,d0
	bcc.s	.l3A64A
	move.w	a3,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4AF22,a0
	move.w	($2,a0,d0.l),d0
	cmp.w	ram_FFDC1A,d0
	bls.s	.l3A64A
	moveq	#$1,d1
.l3A64A:
	move.w	d1,d0
.l3A64C:
	tst.b	ram_FFDCF4
	bne.w	.l3A734
	tst.w	d0
	beq.w	.l3A6B4
	tst.w	ram_FFDD4E
	bne.s	.l3A6B0
	pea	$1.w
	jsr	sub_41606
	tst.w	ram_FFDD1E
	addq.l	#4,sp
	beq.s	.l3A6B0
	move.w	ram_FFDD1E,d2
	ext.l	d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EEA4,a0
	moveq	#$0,d1
	move.b	($0,a0,d0.l),d1
	move.w	d1,d0
	divs.w	d0,d2
	movea.w	d2,a3
	exg	d0,a3
	tst.w	d0
	exg	d0,a3
	beq.s	.l3A6A8
	move.w	a3,d0
	ext.l	d0
	bra.s	.l3A6AA
.l3A6A8:
	moveq	#$1,d0
.l3A6AA:
	sub.w	d0,ram_FFDD1E
.l3A6B0:
	bra.w	.l3A734
.l3A6B4:
	tst.b	ram_FF950A
	beq.s	.l3A706
	tst.w	ram_FFDD4E
	bne.s	.l3A704
	tst.w	ram_FFDD1E
	beq.s	.l3A704
	move.w	ram_FFDD16,d3
	ext.l	d3
	move.w	(-$18,a6),d0
	ext.l	d0
	moveq	#$40,d1
	add.l	d1,d0
	cmp.l	d0,d3
	bhi.s	.l3A704
	move.w	ram_FFDD1E,d2
	ext.l	d2
	asr.l	#2,d2
	movea.w	d2,a3
	exg	d0,a3
	tst.w	d0
	exg	d0,a3
	beq.s	.l3A6FC
	move.w	a3,d0
	ext.l	d0
	bra.s	.l3A6FE
.l3A6FC:
	moveq	#$1,d0
.l3A6FE:
	sub.w	d0,ram_FFDD1E
.l3A704:
	bra.s	.l3A734
.l3A706:
	tst.w	ram_FFDD4A
	bne.s	.l3A734
	cmpi.w	#$320,ram_FFDD1A
	bcs.s	.l3A734
	move.w	(-$2,a6),d0
	add.w	d0,ram_FFDD1E
	cmpi.w	#$4C0,ram_FFDD1E
	bls.s	.l3A734
	move.w	#$4C0,ram_FFDD1E
.l3A734:
	tst.b	(-$F,a6)
	beq.w	.l3A82A
	movea.l	(-$A,a6),a0
	btst	#$6,($11,a0)
	bne.w	.l3A7D6
	cmpi.w	#$240,ram_FFDD16
	bcs.w	.l3A7D6
	moveq	#$0,d0
	move.b	d4,d0
	cmp.w	dat_4D826,d0
	bls.s	.l3A788
	tst.w	ram_FFDD4E
	beq.s	.l3A772
	move.w	dat_4D83C,d3
	bra.s	.l3A778
.l3A772:
	move.w	dat_4D832,d3
.l3A778:
	ext.l	d3
	moveq	#$0,d0
	move.b	d4,d0
	move.l	d0,d2
	move.w	dat_4D826,d1
	bra.s	.l3A7B8
.l3A788:
	moveq	#$0,d0
	move.b	d4,d0
	cmp.w	dat_4D828,d0
	bcc.s	.l3A7D6
	tst.w	ram_FFDD4E
	beq.s	.l3A7A4
	move.w	dat_4D83C,d3
	bra.s	.l3A7AA
.l3A7A4:
	move.w	dat_4D832,d3
.l3A7AA:
	ext.l	d3
	moveq	#$0,d0
	move.b	d4,d0
	move.l	d0,d2
	move.w	dat_4D828,d1
.l3A7B8:
	ext.l	d1
	sub.l	d1,d2
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
	add.l	d2,(-$30,a6)
.l3A7D6:
	move.w	dat_4D834,d1
	ext.l	d1
	move.l	(-$30,a6),d0
	jsr	sub_23E70
	asr.l	#3,d0
	movea.l	(-$6,a6),a2
	sub.w	d0,(a2)
	movea.l	(-$6,a6),a2
	tst.w	(a2)
	beq.s	.l3A826
	movea.l	(-$6,a6),a0
	move.w	(a0),d2
	ext.l	d2
	divs.w	dat_4D830,d2
	ext.l	d2
	move.l	d2,d3
	beq.s	.l3A80E
	bra.s	.l3A81E
.l3A80E:
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	bge.s	.l3A81A
	moveq	#-$1,d0
	bra.s	.l3A81C
.l3A81A:
	moveq	#$1,d0
.l3A81C:
	move.l	d0,d3
.l3A81E:
	move.w	d3,d0
	movea.l	(-$6,a6),a0
	sub.w	d0,(a0)
.l3A826:
	bra.w	.l3A90C
.l3A82A:
	movea.l	(-$A,a6),a0
	btst	#$6,($11,a0)
	bne.w	.l3A8A2
	cmpi.w	#$240,ram_FFDD16
	bcs.w	.l3A8A2
	moveq	#$0,d0
	move.b	d4,d0
	cmp.w	dat_4D826,d0
	bls.s	.l3A85C
	moveq	#$0,d2
	move.b	d4,d2
	move.w	dat_4D826,d0
	bra.s	.l3A866
.l3A85C:
	moveq	#$0,d2
	move.b	d4,d2
	move.w	dat_4D828,d0
.l3A866:
	ext.l	d0
	sub.l	d0,d2
	movea.w	d2,a3
	tst.w	ram_FFDD4E
	beq.s	.l3A87C
	move.w	dat_4D83C,d2
	bra.s	.l3A882
.l3A87C:
	move.w	dat_4D832,d2
.l3A882:
	ext.l	d2
	move.w	a3,d0
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
	add.l	d2,(-$30,a6)
.l3A8A2:
	move.l	(-$30,a6),d2
	add.l	(-$24,a6),d2
	move.l	d2,(-$30,a6)
	move.l	(-$2C,a6),d2
	add.l	(-$20,a6),d2
	move.l	d2,(-$2C,a6)
	move.l	(-$28,a6),d2
	add.l	(-$1C,a6),d2
	move.l	d2,(-$28,a6)
	move.l	(-$30,a6),d0
	divs.w	dat_4D834,d0
	movea.l	(-$6,a6),a0
	sub.w	d0,(a0)
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	beq.s	.l3A90C
	movea.l	(-$6,a6),a0
	move.w	(a0),d2
	ext.l	d2
	divs.w	dat_4D82E,d2
	ext.l	d2
	move.l	d2,d3
	beq.s	.l3A8F4
	bra.s	.l3A904
.l3A8F4:
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	bge.s	.l3A900
	moveq	#-$1,d0
	bra.s	.l3A902
.l3A900:
	moveq	#$1,d0
.l3A902:
	move.l	d0,d3
.l3A904:
	move.w	d3,d0
	movea.l	(-$6,a6),a0
	sub.w	d0,(a0)
.l3A90C:
	tst.w	ram_FFDD4A
	beq.s	.l3A966
	move.w	ram_FFDD4A,d0
	add.w	d0,ram_FFDD26
	tst.w	ram_FFDD26
	blt.s	.l3A932
	move.w	ram_FFDD26,d0
	ext.l	d0
	bra.s	.l3A93C
.l3A932:
	move.w	ram_FFDD26,d0
	ext.l	d0
	neg.l	d0
.l3A93C:
	tst.w	ram_FFDD4A
	blt.s	.l3A94E
	move.w	ram_FFDD4A,d1
	ext.l	d1
	bra.s	.l3A958
.l3A94E:
	move.w	ram_FFDD4A,d1
	ext.l	d1
	neg.l	d1
.l3A958:
	cmp.l	d1,d0
	bge.s	.l3A962
	clr.w	ram_FFDD4A
.l3A962:
	bra.w	.l3AA32
.l3A966:
	tst.b	(-$F,a6)
	beq.w	.l3A9CC
	movea.l	(-$6,a6),a0
	move.w	(a0),d2
	ext.l	d2
	asl.l	#3,d2
	tst.l	d2
	blt.s	.l3A988
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	asl.l	#3,d0
	bra.s	.l3A994
.l3A988:
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	asl.l	#3,d0
	neg.l	d0
.l3A994:
	cmpi.l	#$11C7,d0
	bhi.s	.l3A9C4
	movea.l	(-$6,a6),a0
	move.w	(a0),d2
	ext.l	d2
	asl.l	#3,d2
	tst.l	d2
	blt.s	.l3A9B6
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	asl.l	#3,d0
	bra.s	.l3A9C2
.l3A9B6:
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	asl.l	#3,d0
	neg.l	d0
.l3A9C2:
	bra.s	.l3A9CA
.l3A9C4:
	move.l	#$11C7,d0
.l3A9CA:
	bra.s	.l3AA14
.l3A9CC:
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	blt.s	.l3A9DE
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	bra.s	.l3A9E8
.l3A9DE:
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	neg.l	d0
.l3A9E8:
	cmpi.l	#$11C7,d0
	bhi.s	.l3AA0E
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	blt.s	.l3AA02
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	bra.s	.l3AA0C
.l3AA02:
	movea.l	(-$6,a6),a0
	move.w	(a0),d0
	ext.l	d0
	neg.l	d0
.l3AA0C:
	bra.s	.l3AA14
.l3AA0E:
	move.l	#$11C7,d0
.l3AA14:
	move.w	d0,ram_FFDD26
	movea.l	(-$6,a6),a0
	tst.w	(a0)
	blt.s	.l3AA32
	move.w	ram_FFDD26,d2
	ext.l	d2
	neg.l	d2
	move.w	d2,ram_FFDD26
.l3AA32:
	tst.b	ram_FFDCF4
	bne.w	.l3AAE6
	movea.l	#ram_FFDC1A,a0
	movea.l	(-$6,a6),a1
	move.w	(a1),d0
	add.w	d0,(a0)
	move.w	(a0),ram_FFDD18
	tst.w	ram_FFDD4E
	bne.w	.l3AAE6
	movea.l	(-$A,a6),a0
	btst	#$7,($11,a0)
	beq.s	.l3AA88
	tst.b	ram_FFDCEE
	beq.s	.l3AA86
	tst.w	ram_FFDD1E
	beq.s	.l3AA86
	move.w	ram_FFDD1E,d0
	ext.l	d0
	asr.l	#3,d0
	sub.w	d0,ram_FFDD1E
.l3AA86:
	bra.s	.l3AAE6
.l3AA88:
	move.w	d5,d0
	sub.w	ram_FFDC1A,d0
	tst.w	d0
	blt.s	.l3AAA0
	move.w	d5,d0
	sub.w	ram_FFDC1A,d0
	ext.l	d0
	bra.s	.l3AAAC
.l3AAA0:
	move.w	d5,d0
	sub.w	ram_FFDC1A,d0
	ext.l	d0
	neg.l	d0
.l3AAAC:
	moveq	#$0,d1
	move.w	d0,d1
	move.b	dat_4D84B,d0
	lsr.l	d0,d1
	addq.l	#1,d1
	move.w	ram_FFDD1E,d3
	ext.l	d3
	move.l	d1,d2
	move.l	d2,d0
	mulu.w	d3,d1
	swap	d2
	mulu.w	d3,d2
	swap	d3
	mulu.w	d3,d0
	add.l	d2,d0
	swap	d0
	clr.w	d0
	add.l	d0,d1
	move.l	d1,d0
	divs.w	dat_4D84C,d0
	sub.w	d0,ram_FFDD1E
.l3AAE6:
	tst.b	ram_FF950A
	beq.w	.l3AB4C
	tst.w	ram_FFDD4E
	bne.w	.l3AB4A
	tst.w	ram_FFDD1E
	bne.s	.l3AB4A
	tst.b	ram_FFDCF4
	bne.s	.l3AB4A
	tst.w	ram_FFDD1A
	beq.s	.l3AB4A
	move.w	ram_FFDD16,d3
	ext.l	d3
	move.w	(-$18,a6),d0
	ext.l	d0
	moveq	#$40,d1
	add.l	d1,d0
	cmp.l	d0,d3
	bhi.s	.l3AB4A
	move.w	ram_FFDD1A,d2
	ext.l	d2
	asr.l	#2,d2
	movea.w	d2,a3
	exg	d0,a3
	tst.w	d0
	exg	d0,a3
	beq.s	.l3AB42
	move.w	a3,d0
	ext.l	d0
	bra.s	.l3AB44
.l3AB42:
	moveq	#$1,d0
.l3AB44:
	sub.w	d0,ram_FFDD1A
.l3AB4A:
	bra.s	.l3AB7A
.l3AB4C:
	tst.w	ram_FFDD4A
	bne.s	.l3AB68
	cmpi.w	#$320,ram_FFDD1A
	bcc.s	.l3AB68
	move.w	(-$2,a6),d0
	add.w	d0,ram_FFDD1A
.l3AB68:
	cmpi.w	#$320,ram_FFDD1A
	bls.s	.l3AB7A
	move.w	#$320,ram_FFDD1A
.l3AB7A:
	tst.w	ram_FFDD4E
	beq.s	.l3ABAC
	subq.w	#1,ram_FFDD4E
	bne.s	.l3AB98
	clr.w	ram_FFDD50
	moveb_ffff_abs	ram_FFDD0A
.l3AB98:
	cmpi.w	#$B00,ram_FFDD16
	bcc.s	.l3ABAA
	addi.w	#$40,ram_FFDD16
.l3ABAA:
	bra.s	.l3ABE4
.l3ABAC:
	move.w	ram_FFDD16,d3
	ext.l	d3
	move.w	(-$18,a6),d0
	ext.l	d0
	moveq	#$40,d1
	add.l	d1,d0
	cmp.l	d0,d3
	bls.s	.l3ABCC
	subi.w	#$20,ram_FFDD16
	bra.s	.l3ABE4
.l3ABCC:
	move.w	ram_FFDD1E,d2
	ext.l	d2
	move.w	ram_FFDD1A,d0
	ext.l	d0
	add.l	d0,d2
	move.w	d2,ram_FFDD16
.l3ABE4:
	move.w	ram_FFDD16,d2
	ext.l	d2
	add.l	d2,ram_FFDBFE
	tst.b	ram_FF950A
	beq.w	loc_3AC7E
	tst.w	ram_FFDD16
	bne.w	loc_3AC7E
	move.w	ram_FF9578,d0
	cmpi.w	#$4,d0
	blt.s	loc_3AC76
	cmpi.w	#$16,d0
	bgt.s	loc_3AC76
	add.w	d0,d0
.l3AC1A:
	move.w	(.l3AC1A,pc,d0.w),d0
	jmp	(.l3AC22,pc,d0.w)
.l3AC22:
	dc.w	sub_3AC5A-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	sub_3AC5A-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	sub_3AC5A-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	loc_3AC76-.l3AC22
	dc.w	sub_3AC48-.l3AC22
sub_3AC48:
	move.l	ram_FFDBFE,d3
	addi.l	#$C20,d3
	add.l	d3,ram_FFDBDE
sub_3AC5A:
	move.w	ram_FF9578,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_2BC2A
	move.w	#$2C,ram_FF9550
	addq.l	#4,sp
	bra.s	loc_3AC7E
loc_3AC76:
	move.w	#$13,ram_FF9550
loc_3AC7E:
	jsr	sub_3B350
	tst.b	ram_FFDCF4
	beq.w	.l3AD46
	tst.w	ram_FFDCFE
	beq.s	.l3ACB0
	cmpi.w	#$12,ram_FFDCFE
	bls.s	.l3ACAA
	subi.w	#$12,ram_FFDCFE
	bra.s	.l3ACB0
.l3ACAA:
	clr.w	ram_FFDCFE
.l3ACB0:
	moveq	#$20,d2
	sub.l	d2,ram_FFDCF8
	move.w	ram_FFDCFA,d0
	add.w	d0,ram_FFDCFC
	tst.w	ram_FFDCFC
	bgt.w	.l3AD46
	moveq	#$2,d3
	moveq	#$30,d4
	moveq	#$60,d5
	moveq	#-$20,d6
	moveq	#-$80,d2
	movea.l	d2,a2
	clr.b	ram_FFDCF4
	clr.w	d0
	move.w	d0,ram_FFDD20
	move.w	d0,ram_FFDD22
	move.w	d0,ram_FFDCFE
	move.w	d0,ram_FFDCFC
	ext.l	d0
	move.l	d0,ram_FFDCF8
	pea	$3.w
	jsr	sub_23FBA
	movea.w	d0,a3
	addq.w	#2,a3
	addq.l	#4,sp
	bra.s	.l3AD40
.l3AD14:
	move.l	a2,-(sp)
	move.l	d6,-(sp)
	move.l	d4,d2
	move.l	d5,-(sp)
	jsr	sub_23FBA
	sub.l	d0,d2
	addq.l	#4,sp
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	jsr	sub_23FBA
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_3DCBC
	lea	($10,sp),sp
	subq.w	#1,a3
.l3AD40:
	move.l	a3,d0
	tst.w	d0
	bgt.s	.l3AD14
.l3AD46:
	move.w	ram_FFDD16,d2
	ext.l	d2
	sub.l	ram_FFDD56,d2
	add.l	d2,ram_FFDD52
	move.w	ram_FFDD16,d2
	ext.l	d2
	move.l	d2,ram_FFDD56
	moveq	#-$30,d2
	cmp.l	ram_FFDD52,d2
	ble.s	.l3AD7E
	moveq	#$40,d2
	add.l	d2,ram_FFDD52
	moveq	#$23,d2
	bra.s	.l3AD92
.l3AD7E:
	moveq	#-$10,d2
	cmp.l	ram_FFDD52,d2
	ble.s	.l3AD94
	moveq	#$20,d2
	add.l	d2,ram_FFDD52
	moveq	#$20,d2
.l3AD92:
	bra.s	.l3ADC2
.l3AD94:
	moveq	#$30,d2
	cmp.l	ram_FFDD52,d2
	bge.s	.l3ADAA
	moveq	#$40,d2
	sub.l	d2,ram_FFDD52
	moveq	#$22,d2
	bra.s	.l3AD92
.l3ADAA:
	moveq	#$10,d2
	cmp.l	ram_FFDD52,d2
	bge.s	.l3ADC0
	moveq	#$20,d2
	sub.l	d2,ram_FFDD52
	moveq	#$1F,d2
	bra.s	.l3AD92
.l3ADC0:
	moveq	#$1E,d2
.l3ADC2:
	cmp.b	ram_FFDD60,d2
	beq.s	.l3ADDE
	moveq	#$0,d0
	move.b	d2,d0
	move.l	d0,-(sp)
	jsr	queue_sound_command
	move.b	d2,ram_FFDD60
	addq.l	#4,sp
.l3ADDE:
	movem.l	(-$54,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3ADE8:
	link	a6,#$0
	move.l	#$CF,d1
	btst	#$5,ram_FF9D72
	beq.s	.l3AE00
	moveq	#$1,d0
	bra.s	.l3AE02
.l3AE00:
	moveq	#$0,d0
.l3AE02:
	add.l	d0,d1
	btst	#$5,ram_FF9DB0
	beq.s	.l3AE12
	moveq	#$2,d0
	bra.s	.l3AE14
.l3AE12:
	moveq	#$0,d0
.l3AE14:
	add.l	d0,d1
	move.l	d1,-(sp)
	jsr	object_descriptor
	move.l	d0,ram_FF9E96
	move.b	#$1,ram_FFDC1C
	unlk	a6
	rts
sub_3AE30:
	link	a6,#$0
	movem.l	d2-d4/a2-a5,-(sp)
	move.l	#$FFBBC6,d3
	moveq	#$1,d2
	moveq	#$1,d4
	movea.l	#ram_FF9CBE,a2
	movea.l	#dat_4D7D6,a4
	movea.l	#ram_FFBBBF,a3
.l3AE54:
	move.l	d4,d0
	movea.l	d3,a1
	tst.b	($0,a1,d0.l)
	beq.w	.l3AED0
	move.l	d4,d0
	movea.l	d3,a1
	subq.b	#1,($0,a1,d0.l)
	move.l	d4,d0
	movea.l	d3,a1
	tst.b	($0,a1,d0.l)
	bne.s	.l3AED0
	subq.b	#1,(a3)
	tst.b	(a3)
	bge.s	.l3AEAC
	move.l	d4,d0
	movea.l	d3,a5
	clr.b	($0,a5,d0.l)
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#5,d0
	andi.b	#$DF,($38,a2)
	or.b	d0,($38,a2)
	moveq	#$0,d0
	move.w	($6,a4),d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	jsr	sub_3ADE8
	bra.s	.l3AECE
.l3AEAC:
	move.b	(a3),d1
	ext.w	d1
	add.w	d1,d1
	moveq	#$0,d0
	move.w	($0,a4,d1.w),d0
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	move.l	d4,d0
	movea.l	d3,a5
	move.b	#$2,($0,a5,d0.l)
.l3AECE:
	addq.l	#4,sp
.l3AED0:
	addq.l	#1,d4
	addq.l	#1,a3
	addq.l	#8,a4
	moveq	#$3E,d0
	adda.l	d0,a2
	moveq	#$8,d0
	cmp.l	d4,d0
	bgt.w	.l3AE54
	movem.l	(-$1C,a6),d2-d4/a2-a5
	unlk	a6
	rts
sub_3AEEC:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	move.b	($B,a6),d1
	move.b	($F,a6),d3
	movea.l	#ram_FFDD4C,a0
	btst	#$5,ram_FF9E6A
	beq.s	.l3AF12
.l3AF0C:
	moveq	#$0,d0
	bra.w	.l3B022
.l3AF12:
	tst.w	ram_FFDD4A
	beq.s	.l3AF2C
	move.w	ram_FFDC1A,d0
	addi.w	#$1555,d0
	cmpi.w	#$2AAA,d0
	bls.s	.l3AF2C
	bra.s	.l3AF0C
.l3AF2C:
	move.b	d1,d2
	andi.b	#$3,d2
	move.b	ram_FFDD5C,d4
	move.b	d2,d0
	eor.b	d0,d4
	and.b	ram_FFDD5C,d4
	move.b	d2,ram_FFDD5C
	andi.b	#$4,d1
	move.b	ram_FFDD5E,d5
	move.b	d1,d0
	eor.b	d0,d5
	and.b	ram_FFDD5E,d5
	move.b	d1,ram_FFDD5E
	moveq	#$0,d2
	move.b	d3,d2
	move.w	dat_4D828,d0
	ext.l	d0
	sub.l	d0,d2
	move.l	d2,d1
	move.l	d1,d0
	mulu.w	#$B4,d2
	swap	d1
	mulu.w	#$B4,d1
	moveq	#$0,d0
	add.l	d1,d0
	swap	d0
	clr.w	d0
	add.l	d0,d2
	move.w	d2,(a0)
	moveq	#$0,d0
	move.b	d3,d0
	cmp.w	dat_4D828,d0
	bcc.s	.l3AFB6
	tst.b	ram_FFDCF4
	beq.s	.l3AFB2
	cmpi.w	#$F333,(a0)
	bcs.s	.l3AFAA
	moveq	#$0,d0
	move.w	(a0),d0
	bra.s	.l3AFB0
.l3AFAA:
	move.l	#$F333,d0
.l3AFB0:
	bra.s	.l3AFB4
.l3AFB2:
	moveq	#$0,d0
.l3AFB4:
	move.w	d0,(a0)
.l3AFB6:
	tst.b	d4
	beq.s	.l3AFEA
	moveq	#$0,d0
	move.w	(a0),d0
	move.l	d0,-(sp)
	move.w	ram_FFDD16,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$40.w
	clr.l	-(sp)
	pea	ram_FF9C80
	jsr	sub_3BC3C
	tst.l	d0
	beq.s	.l3AFEA
	pea	$67.w
	jsr	queue_sound_command
.l3AFEA:
	tst.b	d5
	beq.s	.l3B022
	tst.b	ram_FF9540
	bne.s	.l3B022
	tst.b	ram_FF950A
	bne.s	.l3B022
	move.w	ram_FFDD16,d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	ram_FFDBFE,-(sp)
	jsr	sub_3C9B2
	tst.l	d0
	beq.s	.l3B022
	pea	$2F.w
	jsr	queue_sound_command
.l3B022:
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3B02C:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	movea.l	($8,a6),a0
	move.b	($F,a6),d2
	move.w	($12,a6),d3
	movea.l	#ram_FFDD12,a1
	move.l	ram_FFDBFE,d1
	move.w	($2,a0),d0
	ext.l	d0
	sub.l	d0,d1
	move.w	d1,ram_FFDD14
	moveq	#$0,d0
	move.w	ram_FFDC1A,d0
	moveq	#$0,d1
	move.w	($6,a0),d1
	sub.l	d1,d0
	move.w	d0,(a1)
	move.w	($A,a0),d5
	move.w	($C,a0),d1
	move.w	($E,a0),d4
	tst.w	(a1)
	blt.s	.l3B086
	cmpi.b	#$1,ram_FFDCE7
	bhi.s	.l3B094
.l3B086:
	tst.w	(a1)
	bge.s	.l3B09C
	cmpi.b	#$1,ram_FFDCE6
	bls.s	.l3B09C
.l3B094:
	subi.w	#$400,d1
	subi.w	#$C0,d4
.l3B09C:
	tst.b	d2
	beq.s	.l3B0A6
	moveq	#$0,d0
	move.w	d4,d0
	bra.s	.l3B0AA
.l3B0A6:
	moveq	#$0,d0
	move.w	d1,d0
.l3B0AA:
	move.w	d0,d4
	tst.b	d2
	bne.s	.l3B0EE
	move.w	d3,d0
	cmpi.w	#$4B0,d0
	blt.s	.l3B0BC
	bgt.s	.l3B0CE
	bra.s	.l3B0DC
.l3B0BC:
	cmpi.w	#$320,d0
	blt.s	.l3B0EE
	bgt.s	.l3B0C6
	bra.s	.l3B0D6
.l3B0C6:
	cmpi.w	#$3E8,d0
	bne.s	.l3B0EE
	bra.s	.l3B0DC
.l3B0CE:
	cmpi.w	#$C80,d0
	bne.s	.l3B0EE
	bra.s	.l3B0E8
.l3B0D6:
	move.w	d4,d0
	lsl.w	#1,d0
	bra.s	.l3B0EC
.l3B0DC:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	lsr.l	#1,d1
	add.w	d1,d4
	bra.s	.l3B0EE
.l3B0E8:
	move.w	d4,d0
	lsr.w	#1,d0
.l3B0EC:
	move.w	d0,d4
.l3B0EE:
	tst.w	ram_FFDD4E
	beq.s	.l3B112
	cmpi.w	#$3,($10,a0)
	beq.s	.l3B112
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	lsr.l	#2,d1
	add.w	d1,d5
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	lsr.l	#4,d1
	add.w	d1,d4
.l3B112:
	moveq	#$0,d3
	tst.w	ram_FFDD14
	blt.s	.l3B126
	move.w	ram_FFDD14,d2
	ext.l	d2
	bra.s	.l3B130
.l3B126:
	move.w	ram_FFDD14,d2
	ext.l	d2
	neg.l	d2
.l3B130:
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	cmp.l	d2,d1
	bls.s	.l3B156
	tst.w	(a1)
	blt.s	.l3B144
	move.w	(a1),d2
	ext.l	d2
	bra.s	.l3B14A
.l3B144:
	move.w	(a1),d2
	ext.l	d2
	neg.l	d2
.l3B14A:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	cmp.l	d2,d1
	bls.s	.l3B156
	moveq	#$1,d3
.l3B156:
	move.l	d3,d0
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_3B162:
	link	a6,#$0
	movem.l	d2,-(sp)
	moveq	#$5,d2
	clr.w	d0
	move.w	d0,ram_FFDD20
	move.w	d0,ram_FFDD26
	move.w	d0,ram_FFDD1C
	move.w	d0,ram_FFDC1A
	move.w	d0,ram_FFDD1A
	move.w	d0,ram_FFDD16
	clr.b	d0
	move.b	d0,ram_FFDD60
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,ram_FFDD56
	move.l	d1,d0
	move.l	d0,ram_FFDD52
	move.w	d0,ram_FFDD1E
	ext.l	d0
	move.l	d0,ram_FFDBFE
	move.w	d0,ram_FFDD22
	clr.b	d0
	move.b	d0,ram_FFDCF6
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,ram_FFDCF8
	move.w	d1,d0
	move.w	d0,ram_FFDCFC
	move.w	d0,ram_FFDD00
	move.w	d0,ram_FFDCFE
	clr.b	d0
	move.b	d0,ram_FFDCF4
	move.b	d0,ram_FFDCF0
	moveq	#$0,d0
	movea.l	#ram_FFDCE4,a0
.l3B1FC:
	clr.b	(a0)
	addq.l	#1,d0
	addq.l	#1,a0
	cmp.l	d2,d0
	blt.s	.l3B1FC
	moveb_ffff_abs	ram_FFDD0A
	bclr	#$5,ram_FF9EA8
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_3B220:
	link	a6,#$0
	movea.l	#ram_FF9578,a1
	move.w	(a1),d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#dat_4EDE6,a0
	move.l	($0,a0,d0.l),ram_FF9568
	move.w	(a1),d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#io_FF47BA,a0
	move.l	($0,a0,d0.l),ram_FF956C
	move.w	(a1),d0
	ext.l	d0
	add.l	d0,d0
	movea.l	#io_FF4832,a0
	move.w	($0,a0,d0.l),ram_FF9570
	move.w	(a1),d0
	ext.l	d0
	add.l	d0,d0
	movea.l	#io_FF486E,a0
	move.w	($0,a0,d0.l),ram_FF9574
	move.w	(a1),d0
	ext.l	d0
	add.l	d0,d0
	movea.l	#io_FF48AA,a0
	move.w	($0,a0,d0.l),ram_FF9576
	clr.w	d0
	move.w	d0,ram_FFDD1A
	move.w	d0,d1
	move.w	d1,ram_FFDD1E
	move.w	d1,ram_FFDD16
	ext.l	d1
	move.l	d1,ram_FFDD56
	move.l	d1,ram_FFDD52
	clr.w	d0
	move.w	d0,ram_FFDD06
	move.w	d0,d1
	move.w	d1,ram_FFDD08
	move.w	d1,ram_FFDD04
	move.w	d1,ram_FFDD02
	clr.b	d0
	move.b	d0,ram_FFDD60
	moveq	#$0,d1
	move.b	d0,d1
	move.w	d1,ram_FFDD4A
	move.w	d1,ram_FFDD4E
	move.b	d1,ram_FFDD5A
	moveq	#$0,d0
	move.b	d1,d0
	move.w	d0,ram_FFDD1C
	move.w	d0,ram_FFDD22
	move.w	d0,ram_FFDD20
	clr.b	d0
	move.b	d0,ram_FFDCF6
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,ram_FFDCF8
	move.w	d1,d0
	move.w	d0,ram_FFDCFC
	move.w	d0,ram_FFDD00
	move.w	d0,ram_FFDCFE
	clr.b	d0
	move.b	d0,ram_FFDCF4
	move.b	d0,ram_FFDCF0
	move.b	d0,ram_FFDCF2
	bclr	#$5,ram_FF9EA8
	move.b	#$1,ram_FFDC1C
	unlk	a6
	rts
sub_3B350:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	#ram_FFDD22,a2
	cmpi.w	#$7E0,ram_FFDD16
	bhi.s	.l3B372
	move.w	ram_FFDD16,d0
	ext.l	d0
	bra.s	.l3B378
.l3B372:
	move.l	#$7E0,d0
.l3B378:
	ext.l	d0
	asr.l	#6,d0
	move.w	d0,ram_FFDD20
	move.l	$FFFF8014,d0
	moveq	#$9,d1
	asl.l	d1,d0
	andi.w	#$FFFF,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.w	ram_FFDD20,d3
	ext.l	d3
	move.l	d0,d2
	move.l	d2,d1
	mulu.w	d3,d0
	swap	d2
	mulu.w	d3,d2
	swap	d3
	mulu.w	d3,d1
	add.l	d2,d1
	swap	d1
	clr.w	d1
	add.l	d1,d0
	moveq	#$11,d1
	asr.l	d1,d0
	move.w	d0,(a2)
	move.w	(a2),d0
	ext.l	d0
	asr.l	#1,d0
	add.w	d0,(a2)
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_3B3D0:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	movea.l	#ram_FFDD16,a2
	jsr	sub_3AE30
	tst.w	(a2)
	ble.w	.l3B43E
	subi.w	#$A0,(a2)
	tst.w	(a2)
	bgt.s	.l3B3F6
	clr.w	(a2)
	bra.s	.l3B400
.l3B3F6:
	move.w	(a2),d0
	ext.l	d0
	add.l	d0,ram_FFDBFE
.l3B400:
	moveq	#$3E,d3
	moveq	#$8,d2
	moveq	#$0,d4
	movea.l	#ram_FF9C80,a0
.l3B40C:
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,d0
	beq.s	.l3B436
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	subq.b	#1,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	andi.b	#$E7,($38,a0)
	or.b	d0,($38,a0)
.l3B436:
	addq.l	#1,d4
	adda.l	d3,a0
	cmp.l	d2,d4
	blt.s	.l3B40C
.l3B43E:
	jsr	sub_3B350
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_3B44E:
	link	a6,#$0
	movem.l	d2-d6/a2-a5,-(sp)
	move.w	ram_FFDD16,d5
	ext.l	d5
	move.w	dat_4D84E,d0
	ext.l	d0
	sub.l	d0,d5
	move.l	ram_FFDACE,d4
	move.l	#$FF9C94,d3
	move.l	#$FFDACE,d2
	movea.l	#ram_FF9564,a2
	movea.l	#ram_FFDC1C,a4
	movea.l	#dat_4D84E,a3
	bra.w	.l3B538
.l3B490:
	movea.l	d4,a1
	move.l	(a1),d6
	movea.l	d4,a1
	movea.l	($8,a1),a0
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	cmpi.b	#$3,d0
	bne.s	.l3B4D4
	move.l	(a2),d0
	moveq	#$3,d1
	and.l	d1,d0
	moveq	#$3,d1
	cmp.l	d0,d1
	beq.s	.l3B4B8
	bra.w	.l3B536
.l3B4B8:
	movea.l	d4,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2E872
	move.l	d4,-(sp)
	jsr	sub_2E92E
	move.b	#$1,(a4)
	addq.l	#8,sp
	bra.s	.l3B536
.l3B4D4:
	movea.l	d4,a5
	movea.l	($8,a5),a0
	pea	($14,a0)
	move.l	d3,-(sp)
	jsr	sub_22DD6
	move.l	d5,-(sp)
	movea.l	d4,a5
	move.l	($8,a5),-(sp)
	jsr	sub_2D0AE
	move.l	(a2),d0
	moveq	#$3,d1
	and.l	d1,d0
	moveq	#$3,d1
	cmp.l	d0,d1
	lea	($10,sp),sp
	bne.s	.l3B524
	movea.l	d4,a1
	movea.l	($8,a1),a0
	move.b	($38,a0),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	addq.b	#1,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	andi.b	#$E7,($38,a0)
	or.b	d0,($38,a0)
.l3B524:
	move.w	(a3),d0
	ext.l	d0
	sub.l	d0,d5
	movea.l	d4,a1
	movea.l	($8,a1),a0
	bset	#$6,($38,a0)
.l3B536:
	move.l	d6,d4
.l3B538:
	cmp.l	d2,d4
	bne.w	.l3B490
	movem.l	(-$24,a6),d2-d6/a2-a5
	unlk	a6
	rts
dat_3B548:
	incbin	"../../build/stunrun-68k.bin",$3B548,$9C
sub_3B5E4:
	link	a6,#$0
	movem.l	d2/a2-a3,-(sp)
	move.w	($A,a6),d1
	movea.l	($C,a6),a2
	movea.l	#ram_FF9C80,a3
	move.w	d1,d0
	asl.w	#2,d0
	movea.l	#dat_4D80E,a0
	move.w	($0,a0,d0.w),d2
	move.w	d1,d0
	asl.w	#2,d0
	movea.l	#dat_4D80E,a0
	move.w	($2,a0,d0.w),d0
	add.w	d0,d0
	movea.l	#ram_FF9546,a1
	clr.w	($0,a1,d0.w)
	move.w	d1,d0
	asl.w	#2,d0
	movea.l	#dat_4D80E,a0
	move.w	($2,a0,d0.w),d0
	movea.l	#ram_FFDCE4,a1
	subq.b	#1,($0,a1,d0.w)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	pea	($14,a3)
	jsr	sub_22DD6
	tst.l	(a2)
	bne.w	loc_3B928
	move.w	d2,d0
	cmpi.w	#$1,d0
	bcs.w	loc_3B866
	cmpi.w	#$6,d0
	bhi.w	loc_3B866
	add.w	d0,d0
	move.w	(.l3B674+2,pc,d0.w),d0
.l3B674:
	jmp	(.l3B678,pc,d0.w)
.l3B678:
	dc.w	sub_3B684-.l3B678
	dc.w	sub_3B778-.l3B678
	dc.w	sub_3B6CE-.l3B678
	dc.w	sub_3B7C2-.l3B678
	dc.w	sub_3B716-.l3B678
	dc.w	sub_3B80A-.l3B678
sub_3B684:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$9D.w
	bra.w	loc_3B75C
sub_3B6CE:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$99.w
	bra.s	loc_3B75C
sub_3B716:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$9B.w
loc_3B75C:
	jsr	sub_2EF4C
	move.l	d0,(a2)
	move.w	#$FC40,ram_FFDD76
	moveq	#$1,d0
	move.l	d0,ram_FFDD62
	bra.w	loc_3B866
sub_3B778:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$9C.w
	bra.w	loc_3B850
sub_3B7C2:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$98.w
	bra.s	loc_3B850
sub_3B80A:
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	pea	($14,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($10,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($C,a3,d0.l),-(sp)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	move.l	($8,a3,d0.l),-(sp)
	pea	$9A.w
loc_3B850:
	jsr	sub_2EF4C
	move.l	d0,(a2)
	move.w	#$3C0,ram_FFDD76
	clr.l	ram_FFDD62
loc_3B866:
	movea.l	(a2),a0
	pea	($14,a0)
	pea	($14,a3)
	jsr	sub_22DD6
	movea.l	(a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	(a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	(a2),a0
	move.l	($10,a3),($10,a0)
	move.w	ram_FFDD76,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	(a2),-(sp)
	jsr	sub_2D172
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($8,a1),($8,a3,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($C,a1),($C,a3,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($10,a1),($10,a3,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	bset	#$6,($38,a3,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	a3,a0
	andi.b	#$E7,($38,a0,d0.l)
	ori.b	#$0,($38,a0,d0.l)
	moveq	#$0,d0
	move.w	d2,d0
	movea.l	#ram_FFBBBE,a0
	move.b	#$4,($0,a0,d0.l)
	moveq	#$1,d0
	move.l	d0,ram_FFDD66
	move.b	#$1,ram_FFDC1C
loc_3B928:
	movem.l	(-$C,a6),d2/a2-a3
	unlk	a6
	rts
sub_3B932:
	link	a6,#$0
	movem.l	d2-d4/a2-a3,-(sp)
	move.w	($A,a6),d0
	movea.l	($C,a6),a2
	movea.l	#ram_FF9C80,a3
	moveq	#$1,d3
	asl.w	#2,d0
	movea.l	#dat_4D80E,a0
	move.w	($0,a0,d0.w),d2
	tst.l	(a2)
	bne.s	.l3B960
	clr.w	d3
	bra.w	.l3BBF8
.l3B960:
	tst.l	ram_FFDD62
	beq.w	.l3BAB0
	tst.l	ram_FFDD66
	beq.w	.l3BA76
	cmpi.w	#$FFF0,ram_FFDD76
	ble.w	.l3BA04
	movea.l	(a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	(a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	(a2),a0
	move.l	($10,a3),($10,a0)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($8,a1),($8,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($C,a1),($C,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($10,a1),($10,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	bset	#$6,($38,a3,d0.l)
	clr.w	ram_FFDD76
	clr.l	ram_FFDD66
	jsr	sub_3ADE8
	pea	$63.w
	jsr	queue_sound_command
	bra.s	.l3BA74
.l3BA04:
	move.w	ram_FFDD76,d0
	ext.l	d0
	asr.l	#3,d0
	neg.l	d0
	move.w	d0,d4
	ext.l	d0
	move.l	d0,-(sp)
	move.l	(a2),-(sp)
	jsr	sub_2D172
	move.w	d4,d0
	add.w	d0,ram_FFDD76
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($8,a1),($8,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($C,a1),($C,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($10,a1),($10,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	bset	#$6,($38,a3,d0.l)
.l3BA74:
	bra.s	.l3BAAC
.l3BA76:
	cmpi.w	#$FC40,ram_FFDD76
	ble.s	.l3BA98
	move.l	#$FFFFFFD0,-(sp)
	move.l	(a2),-(sp)
	jsr	sub_2D172
	subi.w	#$30,ram_FFDD76
	bra.s	.l3BAAC
.l3BA98:
	move.l	(a2),-(sp)
	jsr	sub_2E872
	clr.l	(a2)
	moveq	#$0,d3
	move.b	#$1,ram_FFDC1C
.l3BAAC:
	bra.w	.l3BBF0
.l3BAB0:
	tst.l	ram_FFDD66
	beq.w	.l3BBBC
	cmpi.w	#$10,ram_FFDD76
	bge.w	.l3BB4A
	movea.l	(a2),a0
	move.l	($8,a3),($8,a0)
	movea.l	(a2),a0
	move.l	($C,a3),($C,a0)
	movea.l	(a2),a0
	move.l	($10,a3),($10,a0)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($8,a1),($8,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($C,a1),($C,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($10,a1),($10,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	bset	#$6,($38,a3,d0.l)
	clr.w	ram_FFDD76
	clr.l	ram_FFDD66
	jsr	sub_3ADE8
	pea	$62.w
	jsr	queue_sound_command
	bra.s	.l3BBBA
.l3BB4A:
	move.w	ram_FFDD76,d0
	ext.l	d0
	asr.l	#3,d0
	neg.l	d0
	move.w	d0,d4
	ext.l	d0
	move.l	d0,-(sp)
	move.l	(a2),-(sp)
	jsr	sub_2D172
	move.w	d4,d0
	add.w	d0,ram_FFDD76
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($8,a1),($8,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($C,a1),($C,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	(a2),a1
	move.l	($10,a1),($10,a3,d0.l)
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	bset	#$6,($38,a3,d0.l)
.l3BBBA:
	bra.s	.l3BBF0
.l3BBBC:
	cmpi.w	#$3C0,ram_FFDD76
	bge.s	.l3BBDC
	pea	$30.w
	move.l	(a2),-(sp)
	jsr	sub_2D172
	addi.w	#$30,ram_FFDD76
	bra.s	.l3BBF0
.l3BBDC:
	move.l	(a2),-(sp)
	jsr	sub_2E872
	clr.l	(a2)
	moveq	#$0,d3
	move.b	#$1,ram_FFDC1C
.l3BBF0:
	movea.l	(a2),a0
	bset	#$6,($38,a0)
.l3BBF8:
	move.w	d3,d0
	ext.l	d0
	movem.l	(-$14,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_3BC06:
	link	a6,#$0
	move.l	($8,a6),d1
	asl.w	#2,d1
	movea.l	#dat_4D80E,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#5,d0
	sub.l	d1,d0
	movea.l	#ram_FF9C80,a0
	bclr	#$5,($38,a0,d0.l)
	move.b	#$1,ram_FFDC1C
	unlk	a6
	rts
	assert	*=$03BC3C,"game/code_037C52.asm does not end at 03BC3C"
