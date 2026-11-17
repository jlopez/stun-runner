; game/code_030012.asm, 030012-034010: game program code (pair S) with the data,
; text and tables that lie between its routines; the first routine is sub_30012. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 030012 034010 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$030012,"game/code_030012.asm misplaced"
sub_30012:
	link	a6,#$0
	move.b	($B,a6),d0
	unlk	a6
	rts
sound_watchdog:
	incbin	"../../build/stunrun-68k.bin",$3001E,$DA
reset_sound:
	link	a6,#$0
	jsr	reset_sound_board
	move.w	#$B4,sound_wait_ready
	clr.w	sound_wait_status
	clr.w	sound_check_tries
	clr.b	sound_queue_fill
	move.b	#$1,sound_queue_send
	clr.b	d0
	move.b	d0,ram_FFDBC6
	move.b	d0,ram_FFDBC5
	move.b	d0,sound_queue_count
	unlk	a6
	rts
flush_sound_queue:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	#sound_queue_send,a4
	clr.w	d3
	movea.l	#sound_queue,a2
	movea.l	#sound_queue_count,a3
	bra.s	.l30186
.l3015A:
	moveq	#$3,d2
	moveq	#$0,d0
	move.b	(a4),d0
	asl.w	#5,d0
	movea.l	a2,a0
	move.w	d3,d1
	adda.w	d0,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	move.l	d0,-(sp)
	jsr	send_sound_byte
	clr.w	d1
	addq.l	#4,sp
.l3017A:
	addq.w	#1,d1
	move.w	d1,d0
	ext.l	d0
	cmp.l	d2,d0
	blt.s	.l3017A
	addq.w	#1,d3
.l30186:
	moveq	#$0,d0
	move.b	(a4),d0
	moveq	#$0,d1
	move.b	($0,a3,d0.w),d1
	cmp.w	d3,d1
	bhi.s	.l3015A
	moveq	#$0,d0
	move.b	(a4),d0
	movea.l	#sound_queue_count,a0
	clr.b	($0,a0,d0.w)
	addq.b	#1,(a4)
	move.b	(a4),d0
	subq.b	#2,d0
	bls.s	.l301AC
	clr.b	(a4)
.l301AC:
	movea.l	#sound_queue_fill,a0
	addq.b	#1,(a0)
	move.b	(a0),d0
	subq.b	#2,d0
	bls.s	.l301C0
	clr.b	sound_queue_fill
.l301C0:
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
queue_sound_command:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.l	($8,a6),d2
	movea.l	#sound_queue_fill,a1
	moveq	#$0,d0
	move.b	(a1),d0
	movea.l	#sound_queue_count,a0
	cmpi.b	#$20,($0,a0,d0.w)
	bcc.s	.l30216
	moveq	#$0,d0
	move.b	(a1),d0
	asl.w	#5,d0
	movea.l	#sound_queue,a0
	moveq	#$0,d1
	move.b	(a1),d1
	movea.l	#sound_queue_count,a1
	move.b	($0,a1,d1.w),d3
	addq.b	#1,($0,a1,d1.w)
	moveq	#$0,d1
	move.b	d3,d1
	adda.w	d0,a0
	move.b	d2,($0,a0,d1.w)
.l30216:
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_30220:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	lea	($10,a6),a2
	clr.w	d1
	move.w	d1,d4
	move.w	d1,d2
	move.w	d2,d3
.l30234:
	movea.l	($C,a6),a0
	addq.l	#1,($C,a6)
	move.b	(a0),d0
	beq.w	.l3037A
	tst.w	d2
	beq.w	.l30362
	move.b	d0,d1
	ext.w	d1
	cmpi.w	#$58,d1
	blt.s	.l30258
	bgt.s	.l30294
	bra.w	.l302E2
.l30258:
	cmpi.w	#$43,d1
	blt.s	.l30264
	bgt.s	.l3027C
	bra.w	.l302FC
.l30264:
	cmpi.w	#$25,d1
	blt.w	.l3032C
	bgt.s	.l30270
	bra.s	.l302BE
.l30270:
	cmpi.w	#$30,d1
	bne.w	.l3032C
	bra.w	.l30326
.l3027C:
	cmpi.w	#$44,d1
	blt.w	.l3032C
	bgt.s	.l30288
	bra.s	.l302C2
.l30288:
	cmpi.w	#$53,d1
	bne.w	.l3032C
	bra.w	.l3030E
.l30294:
	cmpi.w	#$73,d1
	blt.s	.l302A0
	bgt.s	.l302B6
	bra.w	.l3030E
.l302A0:
	cmpi.w	#$63,d1
	blt.w	.l3032C
	bgt.s	.l302AC
	bra.s	.l302FC
.l302AC:
	cmpi.w	#$64,d1
	bne.w	.l3032C
	bra.s	.l302C2
.l302B6:
	cmpi.w	#$78,d1
	bne.s	.l3032C
	bra.s	.l302E2
.l302BE:
	bra.w	.l3034E
.l302C2:
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	($8,a6)
	move.l	(a2)+,-(sp)
	jsr	sub_3038A
.l302DA:
	lea	($10,sp),sp
	bra.w	.l30358
.l302E2:
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	($8,a6)
	move.l	(a2)+,-(sp)
	jsr	sub_30546
	bra.s	.l302DA
.l302FC:
	movea.l	($8,a6),a0
	addq.l	#1,($8,a6)
	movea.l	a2,a1
	addq.l	#4,a2
	move.b	($3,a1),(a0)
	bra.s	.l30358
.l3030E:
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	($8,a6)
	move.l	(a2)+,-(sp)
	jsr	sub_305D2
	lea	($C,sp),sp
	bra.s	.l30358
.l30326:
	moveq	#$1,d3
	bra.w	.l30234
.l3032C:
	cmpi.b	#$31,d0
	blt.s	.l3034E
	cmpi.b	#$39,d0
	bgt.s	.l3034E
	subq.l	#1,($C,a6)
	pea	($C,a6)
	jsr	sub_30618
	move.w	d0,d4
	addq.l	#4,sp
.l3034A:
	bra.w	.l30234
.l3034E:
	movea.l	($8,a6),a0
	addq.l	#1,($8,a6)
	move.b	d0,(a0)
.l30358:
	clr.w	d1
	move.w	d1,d4
	move.w	d1,d2
	move.w	d2,d3
.l30360:
	bra.s	.l3034A
.l30362:
	cmpi.b	#$25,d0
	bne.s	.l3036C
	moveq	#$1,d2
	bra.s	.l30360
.l3036C:
	movea.l	($8,a6),a0
	addq.l	#1,($8,a6)
	move.b	d0,(a0)
	bra.w	.l30234
.l3037A:
	movea.l	($8,a6),a0
	clr.b	(a0)
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_3038A:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a5,-(sp)
	move.l	($8,a6),d0
	movea.l	($C,a6),a1
	move.l	($10,a6),d4
	movea.l	(a1),a0
	movea.l	a0,a3
	clr.w	d1
	movea.w	d1,a4
	move.l	d0,d3
	tst.l	d0
	bge.s	.l303B4
	move.l	d0,d3
	neg.l	d3
	moveq	#$1,d1
	movea.w	d1,a4
.l303B4:
	cmpi.l	#$9FFF6,d3
	bls.s	.l303EC
	move.l	d3,d2
	move.l	d3,d0
	lsr.l	#5,d0
	move.l	d0,d3
	move.l	d3,d0
	divu.w	#$C35,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,(-$4,a6)
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,d3
	mulu.w	#$C35,d3
	move.l	d3,d0
	lsl.l	#5,d0
	move.l	d0,d3
	move.l	d2,d0
	sub.l	d3,d0
	move.l	d0,d3
	bra.s	.l303F0
.l303EC:
	clr.l	(-$4,a6)
.l303F0:
	cmpi.l	#$FFFF,d3
	bls.s	.l30424
	move.l	d3,d2
	move.l	d3,d0
	divu.w	#$A,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d3
	move.l	a0,d0
	addq.l	#1,a0
	move.l	d2,d1
	moveq	#$30,d2
	add.l	d2,d1
	moveq	#$0,d2
	move.w	d3,d2
	add.l	d2,d2
	move.l	d2,d5
	asl.l	#2,d2
	add.l	d5,d2
	sub.l	d2,d1
	movea.l	d0,a2
	move.b	d1,(a2)
	subq.l	#1,d4
.l30424:
	moveq	#$A,d5
	moveq	#$30,d6
	moveq	#$A,d2
.l3042A:
	subq.l	#1,d4
	move.l	d5,d0
	cmp.l	d3,d0
	bls.s	.l30442
	move.l	a0,d0
	addq.l	#1,a0
	move.l	d3,d1
	moveq	#$30,d2
	add.l	d2,d1
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l30468
.l30442:
	move.l	a0,d0
	addq.l	#1,a0
	moveq	#$0,d1
	move.w	d3,d1
	divu.w	d2,d1
	swap	d1
	and.l	#$FFFF,d1
	add.l	d6,d1
	movea.l	d0,a2
	move.b	d1,(a2)
	move.l	d3,d0
	divu.w	#$A,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d3
	bra.s	.l3042A
.l30468:
	tst.l	(-$4,a6)
	beq.s	.l304BA
	moveq	#$A,d6
	moveq	#$30,d0
	movea.l	d0,a2
	moveq	#$A,d5
	move.l	(-$4,a6),d3
.l3047A:
	subq.l	#1,d4
	move.l	d6,d0
	cmp.l	d3,d0
	bls.s	.l30492
	move.l	a0,d0
	addq.l	#1,a0
	move.l	d3,d1
	moveq	#$30,d2
	add.l	d2,d1
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l304BA
.l30492:
	move.l	a0,d0
	addq.l	#1,a0
	moveq	#$0,d2
	move.w	d3,d2
	divu.w	d5,d2
	swap	d2
	and.l	#$FFFF,d2
	moveq	#$0,d1
	move.w	d2,d1
	add.l	a2,d1
	movea.l	d0,a5
	move.b	d1,(a5)
	move.l	d3,d0
	divu.w	d5,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d3
	bra.s	.l3047A
.l304BA:
	move.l	a4,d0
	tst.w	d0
	beq.s	.l304FE
	tst.l	($14,a6)
	beq.s	.l304E2
	moveq	#$30,d1
.l304C8:
	subq.l	#1,d4
	ble.s	.l304D6
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l304C8
.l304D6:
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	#$2D,(a2)
	bra.s	.l304FC
.l304E2:
	moveq	#$20,d1
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	#$2D,(a2)
.l304EE:
	subq.l	#1,d4
	ble.s	.l304FC
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l304EE
.l304FC:
	bra.s	.l3052C
.l304FE:
	tst.l	($14,a6)
	beq.s	.l30518
	moveq	#$30,d1
.l30506:
	move.l	d4,d0
	subq.l	#1,d4
	tst.l	d0
	ble.s	.l3052C
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l30506
.l30518:
	moveq	#$20,d1
.l3051A:
	move.l	d4,d0
	subq.l	#1,d4
	tst.l	d0
	ble.s	.l3052C
	move.l	a0,d0
	addq.l	#1,a0
	movea.l	d0,a2
	move.b	d1,(a2)
	bra.s	.l3051A
.l3052C:
	clr.b	(a0)
	move.l	a0,(a1)
.l30530:
	cmpa.l	a3,a0
	bls.s	.l3053C
	move.b	-(a0),d0
	move.b	(a3),(a0)
	move.b	d0,(a3)+
	bra.s	.l30530
.l3053C:
	movem.l	(-$28,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_30546:
	link	a6,#$0
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	($8,a6),d6
	movea.l	($C,a6),a2
	move.w	($12,a6),d3
	moveq	#$30,d4
	moveq	#$41,d5
	moveq	#$A,d2
	movea.l	(a2),a1
	movea.l	a1,a3
.l30564:
	move.l	d6,d0
	moveq	#$F,d1
	and.l	d1,d0
	move.l	d2,d1
	cmp.l	d0,d1
	bls.s	.l30578
	movea.l	a1,a0
	addq.l	#1,a1
	add.l	d4,d0
	bra.s	.l30580
.l30578:
	movea.l	a1,a0
	addq.l	#1,a1
	sub.l	d2,d0
	add.l	d5,d0
.l30580:
	move.b	d0,(a0)
	move.l	d6,d0
	lsr.l	#4,d0
	move.l	d0,d6
	subq.w	#1,d3
	tst.l	d6
	bne.s	.l30564
	tst.w	($16,a6)
	beq.s	.l305A6
	moveq	#$30,d0
.l30596:
	move.w	d3,d1
	subq.w	#1,d3
	tst.w	d1
	ble.s	.l305B8
	movea.l	a1,a0
	addq.l	#1,a1
	move.b	d0,(a0)
	bra.s	.l30596
.l305A6:
	moveq	#$20,d0
.l305A8:
	move.w	d3,d1
	subq.w	#1,d3
	tst.w	d1
	ble.s	.l305B8
	movea.l	a1,a0
	addq.l	#1,a1
	move.b	d0,(a0)
	bra.s	.l305A8
.l305B8:
	clr.b	(a1)
	move.l	a1,(a2)
.l305BC:
	cmpa.l	a3,a1
	bls.s	.l305C8
	move.b	-(a1),d0
	move.b	(a3),(a1)
	move.b	d0,(a3)+
	bra.s	.l305BC
.l305C8:
	movem.l	(-$1C,a6),d2-d6/a2-a3
	unlk	a6
	rts
sub_305D2:
	link	a6,#$0
	movem.l	d2/a2-a3,-(sp)
	movea.l	($8,a6),a3
	movea.l	($C,a6),a1
	move.l	($10,a6),d1
	movea.l	a3,a0
	bra.s	.l305EC
.l305EA:
	subq.l	#1,d1
.l305EC:
	tst.b	(a0)+
	bne.s	.l305EA
	moveq	#$20,d0
	movea.l	(a1),a0
.l305F4:
	move.l	d1,d2
	subq.l	#1,d1
	tst.l	d2
	ble.s	.l30604
	movea.l	a0,a2
	addq.l	#1,a0
	move.b	d0,(a2)
	bra.s	.l305F4
.l30604:
	move.b	(a3)+,(a0)+
	bne.s	.l30604
	movea.l	a0,a2
	subq.l	#1,a2
	move.l	a2,(a1)
	movem.l	(-$C,a6),d2/a2-a3
	unlk	a6
	rts
sub_30618:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	movea.l	($8,a6),a0
	movea.l	(a0),a1
	move.b	(a1),d3
	ext.w	d3
	subi.w	#$30,d3
	tst.w	d3
	blt.s	.l30638
	cmpi.w	#$9,d3
	ble.s	.l3063E
.l30638:
	move.l	a1,(a0)
	moveq	#$0,d0
	bra.s	.l3066C
.l3063E:
	moveq	#$30,d1
	moveq	#$9,d2
	move.w	d3,d4
.l30644:
	addq.l	#1,a1
	move.b	(a1),d3
	ext.w	d3
	sub.w	d1,d3
	tst.w	d3
	blt.s	.l30658
	move.w	d3,d0
	ext.l	d0
	cmp.l	d2,d0
	ble.s	.l3065A
.l30658:
	bra.s	.l30666
.l3065A:
	add.w	d4,d4
	move.w	d4,d0
	asl.w	#2,d4
	add.w	d0,d4
	add.w	d3,d4
	bra.s	.l30644
.l30666:
	move.l	a1,(a0)
	move.w	d4,d0
	ext.l	d0
.l3066C:
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_30676:
	link	a6,#$0
	pea	($A,a6)
	pea	$1.w
	jsr	sub_30972
	jsr	soft_reset
	unlk	a6
	rts
sub_30692:
	link	a6,#$0
	pea	($A,a6)
	pea	$2.w
	jsr	sub_30972
	jsr	soft_reset
	unlk	a6
	rts
sub_306AE:
	link	a6,#$0
	pea	($A,a6)
	pea	$3.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_306CA:
	link	a6,#$0
	pea	($A,a6)
	pea	$4.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_306E6:
	link	a6,#$0
	pea	($A,a6)
	pea	$5.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_30702:
	link	a6,#$0
	pea	($A,a6)
	pea	$6.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_3071E:
	link	a6,#$0
	pea	($A,a6)
	pea	$7.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_3073A:
	link	a6,#$0
	pea	($A,a6)
	pea	$F.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_30756:
	link	a6,#$0
	clr.w	WATCHDOG
	pea	($A,a6)
	pea	$E.w
	jsr	sub_30A2C
	jsr	soft_reset
	unlk	a6
	rts
sub_30778:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d2
	move.w	($E,a6),d3
	pea	$2700.w
	jsr	set_sr
	cmpi.w	#$10,d2
	bls.s	.l3079A
	moveq	#$10,d2
.l3079A:
	jsr	init_gsp
	clr.w	WATCHDOG
	tst.w	d3
	beq.s	.l307B0
	jsr	clear_gsp_screen
.l307B0:
	clr.w	WATCHDOG
	pea	dat_44930
	jsr	sub_2F524
	clr.w	WATCHDOG
	pea	dat_4A8DA
	clr.l	-(sp)
	pea	$D0.w
	clr.l	-(sp)
	jsr	sub_23898
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	#dat_4A954,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$FF.w
	pea	$D0.w
	pea	$20.w
	jsr	sub_23898
	pea	$1.w
	moveq	#$0,d0
	move.w	d2,d0
	movea.l	#io_FF4B90,a0
	pea	($0,a0,d0.l)
	jsr	sub_2F022
	pea	io_FF4BA4
	pea	io_FF4B90
	jsr	sub_2EFB6
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_30830:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.w	($A,a6),d0
	move.l	#$100000,d2
	movea.l	#WATCHDOG,a2
	pea	$1.w
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30778
	moveq	#$0,d0
	addq.l	#8,sp
.l3085A:
	clr.w	(a2)
	addq.l	#1,d0
	cmp.l	d2,d0
	blt.s	.l3085A
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
dat_3086C:
	incbin	"../../build/stunrun-68k.bin",$3086C,$58
sub_308C4:
	link	a6,#$FF9C
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d0
	move.l	($C,a6),d2
	move.l	#$100000,d3
	movea.l	#WATCHDOG,a2
	clr.l	-(sp)
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30778
	move.l	d2,-(sp)
	pea	$FF.w
	pea	$80.w
	pea	$20.w
	jsr	sub_23898
	moveq	#$0,d0
	lea	($18,sp),sp
.l30906:
	clr.w	(a2)
	addq.l	#1,d0
	cmp.l	d3,d0
	blt.s	.l30906
	jsr	soft_reset
	movem.l	(-$70,a6),d2-d3/a2
	unlk	a6
	rts
sub_3091E:
	link	a6,#$FFFC
	movem.l	d2-d6/a2,-(sp)
	clr.b	(-$1,a6)
	moveq	#$1,d3
	moveq	#$10,d2
	moveq	#$0,d0
	movea.l	d0,a2
	move.l	#$FF4B90,d4
	move.l	#$FF4B90,d6
	move.l	#$FF4BA4,d5
.l30944:
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	pea	(-$1,a6)
	jsr	copy_to_zram
	move.l	d5,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2EFB6
	lea	($14,sp),sp
	addq.l	#1,a2
	addq.l	#1,d4
	cmpa.l	d2,a2
	ble.s	.l30944
	movem.l	(-$1C,a6),d2-d6/a2
	unlk	a6
	rts
sub_30972:
	link	a6,#$FFD8
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d0
	move.l	($C,a6),d2
	move.l	#$100000,d3
	movea.l	#WATCHDOG,a2
	pea	$1.w
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30778
	move.l	d2,-(sp)
	jsr	sub_30AE0
	movea.l	d2,a0
	moveq	#$3C,d0
	adda.l	d0,a0
	move.l	(a0),-(sp)
	movea.l	d2,a0
	moveq	#$74,d0
	adda.l	d0,a0
	move.l	a0,-(sp)
	pea	dat_4A8FA
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	pea	$A0.w
	pea	$10.w
	jsr	sub_23898
	movea.l	d2,a0
	moveq	#$44,d0
	adda.l	d0,a0
	move.l	(a0),-(sp)
	movea.l	d2,a0
	moveq	#$3A,d0
	adda.l	d0,a0
	moveq	#$0,d0
	move.w	(a0),d0
	move.l	d0,-(sp)
	pea	dat_4A90A
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	pea	$B0.w
	pea	$10.w
	jsr	sub_23898
	moveq	#$0,d0
	lea	($4C,sp),sp
.l30A1A:
	clr.w	(a2)
	addq.l	#1,d0
	cmp.l	d3,d0
	blt.s	.l30A1A
	movem.l	(-$34,a6),d2-d3/a2
	unlk	a6
	rts
sub_30A2C:
	link	a6,#$FFD8
	movem.l	d2-d3/a2,-(sp)
	move.w	($A,a6),d1
	move.l	($C,a6),d2
	move.l	#$100000,d3
	movea.l	#WATCHDOG,a2
	pea	$1.w
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	sub_30778
	move.l	d2,-(sp)
	jsr	sub_30AE0
	movea.l	d2,a0
	moveq	#$3C,d0
	adda.l	d0,a0
	move.l	(a0),-(sp)
	move.l	d2,d0
	moveq	#$42,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	dat_4A91A
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	pea	$A0.w
	pea	$10.w
	jsr	sub_23898
	movea.l	d2,a0
	moveq	#$3A,d0
	adda.l	d0,a0
	moveq	#$0,d0
	move.w	(a0),d0
	move.l	d0,-(sp)
	pea	dat_4A92A
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	pea	$B0.w
	pea	$10.w
	jsr	sub_23898
	moveq	#$0,d0
	lea	($48,sp),sp
.l30ACE:
	clr.w	(a2)
	addq.l	#1,d0
	cmp.l	d3,d0
	blt.s	.l30ACE
	movem.l	(-$34,a6),d2-d3/a2
	unlk	a6
	rts
sub_30AE0:
	link	a6,#$FFD8
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	($8,a6),a0
	moveq	#$7,d2
	subq.l	#2,a0
	movea.l	a0,a4
	moveq	#$0,d3
	movea.l	a4,a3
	movea.l	a4,a2
	moveq	#$20,d0
	adda.l	d0,a2
.l30AFC:
	move.l	(a2),-(sp)
	move.l	d3,-(sp)
	move.l	(a3),-(sp)
	move.l	d3,-(sp)
	pea	dat_4A932
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	move.l	d3,d0
	asl.l	#4,d0
	moveq	#$10,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$10.w
	jsr	sub_23898
	lea	($28,sp),sp
	addq.l	#1,d3
	addq.l	#4,a4
	addq.l	#4,a2
	addq.l	#4,a3
	cmp.l	d2,d3
	blt.s	.l30AFC
	move.l	(a4),-(sp)
	move.l	d3,-(sp)
	pea	dat_4A948
	pea	(-$28,a6)
	jsr	sub_30220
	pea	(-$28,a6)
	pea	$FF.w
	move.l	d3,d0
	asl.l	#4,d0
	moveq	#$10,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$10.w
	jsr	sub_23898
	lea	($20,sp),sp
	movem.l	(-$3C,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_30B7E:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	move.l	($8,a6),d0
	moveq	#-$10,d3
	moveq	#$4,d2
	moveq	#$2,d1
	move.l	d0,d4
	moveq	#$4,d0
	cmp.l	d4,d0
	bls.s	.l30B9E
	move.l	d4,d0
	bra.w	.l30BFC
.l30B9E:
	move.l	d3,d0
	and.l	d4,d0
	beq.s	.l30BB8
	move.l	d3,d0
	lsl.l	#2,d0
	move.l	d0,d3
	move.l	d2,d0
	lsl.l	#2,d0
	move.l	d0,d2
	move.w	d1,d0
	lsl.w	#1,d0
	move.w	d0,d1
	bra.s	.l30B9E
.l30BB8:
	move.w	d1,d5
	move.l	d2,d3
	sub.l	d2,d4
	move.w	d1,d0
	lsr.w	#1,d0
	move.w	d0,d1
	move.l	d2,d0
	lsr.l	#2,d0
	move.l	d0,d2
.l30BCA:
	tst.w	d1
	beq.s	.l30BF8
	move.l	d2,d0
	add.l	d3,d0
	cmp.l	d0,d4
	bcs.s	.l30BE4
	or.w	d1,d5
	move.l	d2,d0
	add.l	d3,d0
	sub.l	d0,d4
	move.l	d2,d0
	lsl.l	#1,d0
	add.l	d0,d3
.l30BE4:
	move.w	d1,d0
	lsr.w	#1,d0
	move.w	d0,d1
	move.l	d2,d0
	lsr.l	#2,d0
	move.l	d0,d2
	move.l	d3,d0
	lsr.l	#1,d0
	move.l	d0,d3
	bra.s	.l30BCA
.l30BF8:
	moveq	#$0,d0
	move.w	d5,d0
.l30BFC:
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_30C06:
	link	a6,#$0
	move.l	($8,a6),d1
	movea.l	#sub_30C8E,a0
	move.l	d1,d0
	andi.l	#$C000,d0
	cmpi.l	#$8000,d0
	blt.s	.l30C28
	bgt.s	.l30C3A
	bra.s	.l30C56
.l30C28:
	tst.l	d0
	blt.s	.l30C6C
	bgt.s	.l30C30
	bra.s	.l30C44
.l30C30:
	cmpi.l	#$4000,d0
	bne.s	.l30C6C
	bra.s	.l30C4A
.l30C3A:
	cmpi.l	#$C000,d0
	bne.s	.l30C6C
	bra.s	.l30C66
.l30C44:
	move.l	d1,-(sp)
.l30C46:
	jsr	(a0)
	bra.s	.l30C6C
.l30C4A:
	move.l	#$8000,d0
	sub.l	d1,d0
	move.l	d0,-(sp)
	bra.s	.l30C46
.l30C56:
	move.l	d1,d0
	addi.l	#$8000,d0
.l30C5E:
	move.l	d0,-(sp)
	jsr	(a0)
	neg.l	d0
	bra.s	.l30C6C
.l30C66:
	move.l	d1,d0
	neg.l	d0
	bra.s	.l30C5E
.l30C6C:
	ext.l	d0
	unlk	a6
	rts
sub_30C72:
	link	a6,#$0
	move.l	($8,a6),d0
	addi.l	#$4000,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	ext.l	d0
	unlk	a6
	rts
sub_30C8E:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d2
	move.w	d2,d0
	lsr.w	#6,d0
	move.w	d0,d1
	addq.w	#1,d1
	add.w	d0,d0
	movea.l	#dat_4AABA,a0
	move.w	($0,a0,d0.w),d3
	move.w	d2,d0
	andi.w	#$3F,d0
	ext.l	d0
	add.w	d1,d1
	movea.l	#dat_4AABA,a0
	move.w	($0,a0,d1.w),d1
	sub.w	d3,d1
	muls.w	d1,d0
	divs.w	#$40,d0
	ext.l	d0
	move.w	d3,d1
	ext.l	d1
	add.l	d1,d0
	ext.l	d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_30CDE:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d2
	cmpi.w	#$8000,d2
	bcs.s	.l30CF6
	move.w	#$2000,d0
	bra.s	.l30D32
.l30CF6:
	move.w	d2,d0
	lsr.w	#7,d0
	move.w	d0,d1
	addq.w	#1,d1
	add.w	d0,d0
	movea.l	#dat_4ACBC,a0
	move.w	($0,a0,d0.w),d3
	move.w	d2,d0
	andi.w	#$7F,d0
	ext.l	d0
	add.w	d1,d1
	movea.l	#dat_4ACBC,a0
	move.w	($0,a0,d1.w),d1
	sub.w	d3,d1
	muls.w	d1,d0
	divs.w	#$80,d0
	moveq	#$0,d1
	move.w	d0,d1
	moveq	#$0,d0
	move.w	d3,d0
	add.l	d0,d1
	move.w	d1,d0
.l30D32:
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_30D42:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d1
	move.w	($E,a6),d3
	tst.w	d1
	bne.s	.l30D5E
	tst.w	d3
	bne.s	.l30D5E
	clr.w	d2
	bra.s	.l30DA2
.l30D5E:
	cmp.w	d3,d1
	bls.s	.l30D80
	moveq	#$0,d0
	move.w	d3,d0
	asl.l	#8,d0
	asl.l	#7,d0
	move.l	d0,d2
	divs.w	d1,d2
	move.w	d2,d1
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	sub_30CDE
	move.w	d0,d2
	bra.s	.l30DA2
.l30D80:
	moveq	#$0,d0
	move.w	d1,d0
	asl.l	#8,d0
	asl.l	#7,d0
	move.l	d0,d2
	divs.w	d3,d2
	move.w	d2,d1
	move.l	#$4000,d2
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	jsr	sub_30CDE
	sub.l	d0,d2
.l30DA2:
	moveq	#$0,d0
	move.w	d2,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_30DB0:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.w	($A,a6),d1
	move.w	($E,a6),d0
	movea.l	#sub_30D42,a0
	tst.w	d1
	bge.s	.l30E00
	tst.w	d0
	bge.s	.l30DE8
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	move.w	d1,d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	(a0)
	move.l	d0,d2
	addi.l	#$8000,d2
	bra.s	.l30E28
.l30DE8:
	move.l	#$8000,d2
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d1,d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	(a0)
	sub.l	d0,d2
	bra.s	.l30E28
.l30E00:
	tst.w	d0
	bge.s	.l30E18
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a0)
	neg.l	d0
	move.w	d0,d2
	bra.s	.l30E28
.l30E18:
	move.w	d0,d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a0)
	move.w	d0,d2
.l30E28:
	move.w	d2,d0
	ext.l	d0
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
dat_30E36:
	incbin	"../../build/stunrun-68k.bin",$30E36,$106
sub_30F3C:
	link	a6,#$0
	move.w	($A,a6),d0
	tst.w	d0
	blt.s	.l30F5A
	move.w	d0,d1
	add.w	d1,d1
	movea.l	#dat_4AF6A,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	bra.s	.l30F70
.l30F5A:
	ext.l	d0
	neg.l	d0
	add.w	d0,d0
	movea.l	#dat_4AF6A,a0
	moveq	#$0,d1
	move.w	($0,a0,d0.w),d1
	neg.l	d1
	move.l	d1,d0
.l30F70:
	unlk	a6
	rts
sub_30F74:
	link	a6,#$0
	move.w	($A,a6),d0
	tst.w	d0
	blt.s	.l30F84
	ext.l	d0
	bra.s	.l30F88
.l30F84:
	ext.l	d0
	neg.l	d0
.l30F88:
	move.w	d0,d1
	add.w	d1,d1
	movea.l	#dat_4AF74,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	unlk	a6
	rts
sub_30F9C:
	link	a6,#$FFCC
	movem.l	d2-d7/a2-a5,-(sp)
	movea.l	($8,a6),a3
	movea.l	($C,a6),a2
	move.l	($10,a6),(-$8,a6)
	move.l	#$FF4528,(-$10,a6)
	lea	($10,a3),a0
	move.l	a0,d0
	move.l	d0,($14,a3)
	move.l	d0,($10,a3)
	move.l	(-$8,a6),-(sp)
	move.b	($5,a2),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30F74
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.b	($5,a2),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30F3C
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	move.l	(-$8,a6),-(sp)
	move.b	($4,a2),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30F74
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.b	($4,a2),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30F3C
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	move.l	(-$8,a6),-(sp)
	jsr	sub_2CECC
	move.l	(-$8,a6),-(sp)
	move.l	($14,a6),d0
	addq.l	#8,d0
	movea.l	d0,a4
	move.l	(a4),-(sp)
	move.l	($14,a6),d0
	addq.l	#4,d0
	movea.l	d0,a4
	move.l	(a4),-(sp)
	movea.l	($14,a6),a0
	move.l	(a0),-(sp)
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,d6
	move.l	d6,($C,a3)
	btst	#$7,($11,a2)
	lea	($30,sp),sp
	beq.s	.l31082
	tst.b	ram_FFDC1E
	beq.s	.l3107E
	moveq	#$2,d0
	bra.s	.l31080
.l3107E:
	moveq	#$0,d0
.l31080:
	bra.s	.l31088
.l31082:
	move.b	ram_FFDC1E,d0
.l31088:
	and.b	#$3,d0
	add.b	d0,d0
	movea.l	d6,a0
	andi.b	#$F9,($38,a0)
	movea.l	d6,a0
	or.b	d0,($38,a0)
	move.l	($E,a2),d0
	andi.l	#$40000,d0
	beq.s	.l310B0
	movea.l	d6,a0
	bset	#$5,($38,a0)
.l310B0:
	movea.l	($14,a6),a4
	move.l	(a4),(-$32,a6)
	move.l	($14,a6),d0
	addq.l	#4,d0
	movea.l	d0,a4
	move.l	(a4),(-$2E,a6)
	move.l	($14,a6),d0
	addq.l	#8,d0
	movea.l	d0,a4
	move.l	(a4),(-$2A,a6)
	move.w	($8,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D0AE
	move.l	($14,a6),d0
	movea.l	d6,a4
	movea.l	d0,a5
	move.l	($8,a4),(a5)
	move.l	($14,a6),d0
	addq.l	#4,d0
	movea.l	d6,a4
	movea.l	d0,a5
	move.l	($C,a4),(a5)
	move.l	($14,a6),d0
	addq.l	#8,d0
	movea.l	d6,a4
	movea.l	d0,a5
	move.l	($10,a4),(a5)
	movea.l	d6,a4
	move.l	(-$32,a6),($8,a4)
	movea.l	d6,a4
	move.l	(-$2E,a6),($C,a4)
	movea.l	d6,a4
	move.l	(-$2A,a6),($10,a4)
	move.w	($6,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D0AE
	movea.l	d6,a4
	move.l	($8,a4),(-$32,a6)
	movea.l	d6,a4
	move.l	($C,a4),(-$2E,a6)
	movea.l	d6,a4
	move.l	($10,a4),(-$2A,a6)
	move.b	dat_4B057,d0
	and.b	#$3,d0
	lsl.b	#3,d0
	movea.l	d6,a4
	andi.b	#$E7,($38,a4)
	movea.l	d6,a4
	or.b	d0,($38,a4)
	move.l	($E,a2),d0
	andi.l	#$200000,d0
	lea	($10,sp),sp
	bne.s	.l3117A
	tst.b	ram_FFDBD0
	beq.s	.l3118A
.l3117A:
	movea.l	d6,a0
	andi.b	#$E7,($38,a0)
	movea.l	d6,a0
	ori.b	#$18,($38,a0)
.l3118A:
	move.l	a3,-(sp)
	move.l	($18,a6),-(sp)
	jsr	sub_2E7C4
	move.w	($1C,a6),($18,a3)
	tst.w	($1E,a6)
	addq.l	#8,sp
	beq.s	.l311B8
	move.l	($20,a6),-(sp)
	moveq	#$0,d0
	move.w	($1E,a6),d0
	move.l	d0,-(sp)
	jsr	sub_33480
	addq.l	#8,sp
.l311B8:
	move.w	($1C,a6),d1
	andi.w	#$1FF,d1
	tst.w	d1
	beq.w	.l31474
	moveq	#$0,d0
	move.w	d1,d0
	asl.l	#2,d0
	movea.l	#dat_4C712,a0
	move.l	($0,a0,d0.l),d3
	bra.w	.l3146C
.l311DA:
	movea.l	d3,a5
	movea.l	(a5)+,a4
	move.l	a5,d3
	move.l	(-$8,a6),-(sp)
	move.l	(-$2A,a6),-(sp)
	move.l	(-$2E,a6),-(sp)
	move.l	(-$32,a6),-(sp)
	move.w	(a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,d6
	cmpi.w	#$6,($10,a4)
	lea	($14,sp),sp
	bne.s	.l3121C
	tst.b	ram_FFDBD0
	bne.s	.l3121C
	move.b	#$1,ram_FFDBD0
	bra.s	.l31232
.l3121C:
	cmpi.w	#$6,($10,a4)
	bne.s	.l31232
	tst.b	ram_FFDBD0
	beq.s	.l31232
	clr.b	ram_FFDBD0
.l31232:
	move.w	(a4),d0
	cmpi.w	#$7B,d0
	blt.w	.l31294
	bgt.s	.l31240
	bra.s	.l31248
.l31240:
	cmpi.w	#$D4,d0
	bne.s	.l31294
	bra.s	.l31288
.l31248:
	moveq	#$2,d0
	clr.l	(-$1E,a6)
	movea.l	#ram_FFDC78,a0
.l31254:
	tst.l	(a0)
	bne.s	.l31278
	move.l	(-$1E,a6),d0
	asl.l	#2,d0
	movea.l	#ram_FFDC78,a0
	move.l	d6,($0,a0,d0.l)
	move.l	(-$1E,a6),d0
	movea.l	#ram_FFDC86,a0
	clr.b	($0,a0,d0.l)
	bra.s	.l31286
.l31278:
	addq.l	#1,(-$1E,a6)
	addq.l	#4,a0
	move.l	(-$1E,a6),d1
	cmp.l	d0,d1
	blt.s	.l31254
.l31286:
	bra.s	.l31294
.l31288:
	move.l	d6,ram_FFDC80
	clr.b	ram_FFDC88
.l31294:
	movea.l	d6,a5
	bclr	#$6,($38,a5)
	movea.l	d6,a5
	move.w	($4,a4),($36,a5)
	move.w	($2,a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D0AE
	btst	#$1,($11,a2)
	addq.l	#8,sp
	beq.s	.l312DA
	move.w	($2,a4),d0
	ext.l	d0
	divs.w	($C,a2),d0
	move.w	d0,(-$1A,a6)
	move.w	(-$1A,a6),d1
	add.w	($A,a2),d1
	move.w	d1,(-$1A,a6)
	bra.s	.l312E0
.l312DA:
	move.w	($A,a2),(-$1A,a6)
.l312E0:
	btst	#$7,($11,a2)
	beq.s	.l31310
	move.w	($6,a4),d0
	ext.l	d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D172
	move.l	#$FFFFFA10,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D110
	lea	($10,sp),sp
	bra.w	.l31420
.l31310:
	move.w	#$CCC,d0
	sub.w	($6,a4),d0
	cmpi.w	#$1999,d0
	bls.s	.l31352
	movea.l	d6,a5
	pea	($14,a5)
	moveq	#$0,d0
	move.w	($6,a4),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($6,a4),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	bra.w	.l313CC
.l31352:
	moveq	#$0,d1
	move.w	(-$1A,a6),d1
	move.l	d1,d0
	divu.w	#$14,d0
	move.w	(-$1A,a6),d4
	sub.w	d0,d4
	move.w	d4,(-$1A,a6)
	moveq	#$0,d0
	move.w	($6,a4),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.l	d0,(-$14,a6)
	moveq	#$0,d0
	move.w	(-$1A,a6),d0
	movea.l	d0,a0
	move.l	(-$14,a6),d1
	move.l	d1,d0
	move.l	a0,d4
	move.l	(-$14,a6),d5
	mulu.w	d4,d5
	move.l	d5,(-$14,a6)
	swap	d1
	move.l	a0,d4
	mulu.w	d4,d1
	move.l	a0,d2
	swap	d2
	mulu.w	d2,d0
	add.l	d1,d0
	swap	d0
	clr.w	d0
	move.l	(-$14,a6),d4
	add.l	d0,d4
	move.l	d4,(-$14,a6)
	moveq	#$E,d0
	move.l	(-$14,a6),d4
	asr.l	d0,d4
	move.l	d4,(-$14,a6)
	move.l	(-$14,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D172
.l313CC:
	lea	($C,sp),sp
	moveq	#$0,d0
	move.w	($A,a2),d0
	neg.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D110
	btst	#$1,($11,a2)
	addq.l	#8,sp
	beq.s	.l31420
	movea.l	d6,a5
	pea	($14,a5)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	lea	($C,sp),sp
.l31420:
	movea.l	d6,a5
	pea	($14,a5)
	moveq	#$0,d0
	move.w	($8,a4),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	($8,a4),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	jsr	sub_2E8FC
	movea.l	d0,a0
	move.l	d6,($8,a0)
	move.l	a0,-(sp)
	pea	($10,a3)
	jsr	sub_2E7C4
	lea	($14,sp),sp
.l3146C:
	movea.l	d3,a0
	tst.l	(a0)
	bne.w	.l311DA
.l31474:
	cmpi.w	#$16,ram_FF9578
	bne.w	.l31860
	moveq	#$0,d1
	move.w	game_options,d1
	move.l	d1,d0
	andi.l	#$100,d0
	beq.w	.l31624
	cmpi.w	#$21C,ram_FFDBE6
	bne.w	.l31624
	moveq	#$20,d2
	moveq	#$50,d3
	moveq	#$41,d4
	move.w	#$5F0,(-$1A,a6)
	clr.l	(-$18,a6)
	move.l	(-$18,a6),(-$14,a6)
	move.w	(-$12,a6),d0
	movea.l	#str_4AFE6,a1
	adda.w	d0,a1
	movea.l	#dat_4AEC6,a4
	bra.s	.l31500
.l314CA:
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d2,d0
	bne.s	.l314E0
	move.l	(-$18,a6),d0
	sub.l	d3,d0
	move.l	d0,(-$18,a6)
	bra.s	.l314FA
.l314E0:
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	sub.l	d4,d0
	add.w	d0,d0
	moveq	#$0,d1
	move.w	($0,a4,d0.w),d1
	move.l	(-$18,a6),d5
	sub.l	d1,d5
	move.l	d5,(-$18,a6)
.l314FA:
	addq.l	#1,(-$14,a6)
	addq.l	#1,a1
.l31500:
	tst.b	(a1)
	bne.s	.l314CA
	moveq	#$20,d2
	move.l	(-$18,a6),d0
	asr.l	#1,d0
	move.l	d0,(-$18,a6)
	clr.l	(-$14,a6)
	movea.l	#str_4AFE6,a4
	move.l	#$240,d4
	moveq	#$0,d1
	move.w	(-$1A,a6),d1
	move.l	d1,d0
	sub.l	d0,d4
	move.l	#dat_4AEC6,d3
	lea	($10,a3),a0
	move.l	a0,d5
	bra.w	.l3161E
.l3153A:
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d2,d0
	bne.s	.l3156A
	move.l	(-$8,a6),-(sp)
	move.l	(-$2A,a6),-(sp)
	move.l	(-$2E,a6),-(sp)
	move.l	(-$32,a6),-(sp)
	pea	$10C.w
	jsr	sub_2EF4C
	move.l	d0,d6
	movea.l	d6,a5
	bset	#$5,($38,a5)
	bra.s	.l31594
.l3156A:
	move.l	(-$8,a6),-(sp)
	move.l	(-$2A,a6),-(sp)
	move.l	(-$2E,a6),-(sp)
	move.l	(-$32,a6),-(sp)
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	moveq	#$41,d1
	sub.l	d1,d0
	addi.l	#$10C,d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,d6
.l31594:
	lea	($14,sp),sp
	move.l	#$FFFFF400,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D0AE
	move.l	d4,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D110
	move.l	(-$18,a6),-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D172
	movea.l	d6,a5
	andi.b	#$F9,($38,a5)
	movea.l	d6,a5
	ori.b	#$6,($38,a5)
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d2,d0
	lea	($18,sp),sp
	bne.s	.l315E2
	moveq	#$50,d0
	add.l	d0,(-$18,a6)
	bra.s	.l31600
.l315E2:
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	moveq	#$41,d1
	sub.l	d1,d0
	add.w	d0,d0
	movea.l	d3,a1
	moveq	#$0,d1
	move.w	($0,a1,d0.w),d1
	move.l	(-$18,a6),d7
	add.l	d1,d7
	move.l	d7,(-$18,a6)
.l31600:
	jsr	sub_2E8FC
	movea.l	d0,a0
	move.l	d6,($8,a0)
	move.l	a0,-(sp)
	move.l	d5,-(sp)
	jsr	sub_2E7C4
	addq.l	#8,sp
	addq.l	#1,(-$14,a6)
	addq.l	#1,a4
.l3161E:
	tst.b	(a4)
	bne.w	.l3153A
.l31624:
	clr.l	(-$1E,a6)
	move.l	(-$10,a6),d3
	movea.l	(-$10,a6),a1
	lea	($8,a1),a0
	move.l	a0,(-$26,a6)
	move.l	(-$10,a6),(-$C,a6)
	move.l	#dat_4AEBE,d4
	move.l	#dat_4AEC6,d5
	move.l	#dat_4AEC6,(-$4,a6)
.l31652:
	moveq	#$0,d1
	move.w	ram_FFDBE6,d1
	move.l	d1,d0
	moveq	#$0,d1
	movea.l	(-$C,a6),a0
	move.w	($4,a0),d1
	moveq	#$A,d2
	sub.l	d2,d1
	cmp.l	d1,d0
	bne.w	.l31840
	btst	#$7,($11,a2)
	beq.s	.l31680
	move.w	#$5F0,(-$1A,a6)
	bra.s	.l316C4
.l31680:
	btst	#$1,($11,a2)
	beq.s	.l316A8
	movea.l	(-$C,a6),a0
	move.w	($6,a0),d0
	ext.l	d0
	divs.w	($C,a2),d0
	move.w	d0,(-$1A,a6)
	move.w	(-$1A,a6),d1
	add.w	($A,a2),d1
	move.w	d1,(-$1A,a6)
	bra.s	.l316AE
.l316A8:
	move.w	($A,a2),(-$1A,a6)
.l316AE:
	moveq	#$0,d1
	move.w	(-$1A,a6),d1
	move.l	d1,d0
	divu.w	#$14,d0
	move.w	(-$1A,a6),d2
	sub.w	d0,d2
	move.w	d2,(-$1A,a6)
.l316C4:
	moveq	#$20,d2
	moveq	#$50,d6
	moveq	#$41,d1
	movea.l	d1,a4
	clr.l	(-$18,a6)
	move.l	(-$18,a6),(-$14,a6)
	move.w	(-$12,a6),d0
	movea.l	(-$C,a6),a5
	lea	($8,a5),a1
	adda.w	d0,a1
	bra.s	.l3171E
.l316E6:
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d2,d0
	bne.s	.l316FC
	move.l	(-$18,a6),d0
	sub.l	d6,d0
	move.l	d0,(-$18,a6)
	bra.s	.l31718
.l316FC:
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	sub.l	a4,d0
	add.w	d0,d0
	movea.l	d5,a5
	moveq	#$0,d1
	move.w	($0,a5,d0.w),d1
	move.l	(-$18,a6),d7
	sub.l	d1,d7
	move.l	d7,(-$18,a6)
.l31718:
	addq.l	#1,(-$14,a6)
	addq.l	#1,a1
.l3171E:
	tst.b	(a1)
	bne.s	.l316E6
	move.l	(-$18,a6),d0
	asr.l	#1,d0
	move.l	d0,(-$18,a6)
	clr.l	(-$22,a6)
	movea.l	(-$26,a6),a4
	move.l	#$180,d2
	moveq	#$0,d1
	move.w	(-$1A,a6),d1
	move.l	d1,d0
	sub.l	d0,d2
	bra.w	.l31834
.l31748:
	cmpi.b	#$20,(a4)
	bne.s	.l31774
	move.l	(-$8,a6),-(sp)
	move.l	(-$2A,a6),-(sp)
	move.l	(-$2E,a6),-(sp)
	move.l	(-$32,a6),-(sp)
	pea	$10C.w
	jsr	sub_2EF4C
	move.l	d0,d6
	movea.l	d6,a5
	bset	#$5,($38,a5)
	bra.s	.l3179E
.l31774:
	move.l	(-$8,a6),-(sp)
	move.l	(-$2A,a6),-(sp)
	move.l	(-$2E,a6),-(sp)
	move.l	(-$32,a6),-(sp)
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	moveq	#$41,d1
	sub.l	d1,d0
	addi.l	#$10C,d0
	move.l	d0,-(sp)
	jsr	sub_2EF4C
	move.l	d0,d6
.l3179E:
	lea	($14,sp),sp
	movea.l	d3,a5
	move.w	($6,a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D0AE
	move.l	d2,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D110
	move.l	(-$18,a6),-(sp)
	move.l	d6,-(sp)
	jsr	sub_2D172
	movea.l	d4,a5
	move.b	(a5),d0
	and.b	#$3,d0
	add.b	d0,d0
	movea.l	d6,a5
	andi.b	#$F9,($38,a5)
	movea.l	d6,a5
	or.b	d0,($38,a5)
	cmpi.b	#$20,(a4)
	lea	($18,sp),sp
	bne.s	.l317F4
	moveq	#$50,d0
	add.l	d0,(-$18,a6)
	bra.s	.l31814
.l317F4:
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	moveq	#$41,d1
	sub.l	d1,d0
	add.w	d0,d0
	movea.l	(-$4,a6),a1
	moveq	#$0,d1
	move.w	($0,a1,d0.w),d1
	move.l	(-$18,a6),d7
	add.l	d1,d7
	move.l	d7,(-$18,a6)
.l31814:
	jsr	sub_2E8FC
	movea.l	d0,a0
	move.l	d6,($8,a0)
	move.l	a0,-(sp)
	pea	($10,a3)
	jsr	sub_2E7C4
	addq.l	#8,sp
	addq.l	#1,(-$22,a6)
	addq.l	#1,a4
.l31834:
	move.l	(-$22,a6),d0
	cmp.l	(-$14,a6),d0
	blt.w	.l31748
.l31840:
	addq.l	#1,(-$1E,a6)
	addq.l	#1,d4
	moveq	#$1C,d0
	add.l	d0,(-$C,a6)
	moveq	#$1C,d0
	add.l	d0,(-$26,a6)
	moveq	#$1C,d0
	add.l	d0,d3
	moveq	#$5,d0
	cmp.l	(-$1E,a6),d0
	bgt.w	.l31652
.l31860:
	movem.l	(-$5C,a6),d2-d7/a2-a5
	unlk	a6
	rts
sub_3186A:
	link	a6,#$FFFC
	movem.l	d2-d5/a2-a5,-(sp)
	movea.l	#ram_FFDC6C,a2
	movea.l	(a2),a0
	tst.l	(a0)
	bne.s	.l3188E
	move.w	#$13,ram_FF9550
	moveq	#$0,d0
	movea.l	d0,a1
	bra.w	.l31AB2
.l3188E:
	jsr	sub_2E89E
	move.l	d0,d2
	movea.l	(a2),a1
	addq.l	#4,(a2)
	movea.l	(a1),a3
	movea.l	d2,a4
	move.l	a3,($8,a4)
	movea.l	(a2),a0
	move.l	(a0),(-$4,a6)
	movea.l	(-$4,a6),a1
	exg	d3,a1
	andi.l	#$80000000,d3
	exg	d3,a1
	beq.s	.l318C4
	andi.l	#$7FFFFFFF,(-$4,a6)
	addq.l	#4,(a2)
	bra.s	.l318CC
.l318C4:
	clr.w	(-$2,a6)
	clr.w	(-$4,a6)
.l318CC:
	movea.l	($E,a3),a1
	exg	d0,a1
	andi.l	#$1000,d0
	exg	d0,a1
	beq.s	.l318E2
	movea.l	(a2),a0
	move.l	(a0),(a2)
	bra.s	.l31936
.l318E2:
	movea.l	($E,a3),a1
	exg	d0,a1
	andi.l	#$80020,d0
	exg	d0,a1
	beq.s	.l31936
	pea	ram_FFDC58
	pea	ram_FFDC22
	jsr	sub_22DD6
	move.l	ram_FFDC02,ram_FFDC0E
	move.l	ram_FFDC06,ram_FFDC12
	move.l	ram_FFDC0A,ram_FFDC16
	movea.l	(a2),a1
	addq.l	#4,(a2)
	move.l	(a1),ram_FFDC70
	move.b	#$1,ram_FFDC20
	addq.l	#8,sp
.l31936:
	clr.l	-(sp)
	move.l	(-$4,a6),-(sp)
	pea	ram_FFDBEE
	pea	ram_FFDC02
	pea	ram_FFDC22
	move.l	a3,-(sp)
	move.l	d2,-(sp)
	jsr	sub_30F9C
	movea.l	($E,a3),a1
	exg	d3,a1
	andi.l	#$80020,d3
	exg	d3,a1
	lea	($1C,sp),sp
	bne.s	.l3197C
	movea.l	#ram_FFDBF6,a1
	cmpa.l	ram_FFDBF6,a1
	beq.w	.l31A24
.l3197C:
	jsr	sub_2E89E
	movea.l	d0,a4
	movea.l	#ram_FFDC70,a0
	movea.l	(a0),a1
	addq.l	#4,(a0)
	movea.l	(a1),a2
	move.l	a2,($8,a4)
	movea.l	ram_FFDC70,a0
	move.l	(a0),(-$4,a6)
	movea.l	(-$4,a6),a1
	exg	d2,a1
	andi.l	#$80000000,d2
	exg	d2,a1
	beq.s	.l319BE
	andi.l	#$7FFFFFFF,(-$4,a6)
	addq.l	#4,ram_FFDC70
	bra.s	.l319C6
.l319BE:
	clr.w	(-$2,a6)
	clr.w	(-$4,a6)
.l319C6:
	movea.l	($E,a2),a1
	exg	d0,a1
	andi.l	#$1000,d0
	exg	d0,a1
	beq.s	.l319E2
	movea.l	ram_FFDC70,a0
	move.l	(a0),ram_FFDC70
.l319E2:
	pea	$1.w
	move.l	(-$4,a6),-(sp)
	pea	ram_FFDBF6
	pea	ram_FFDC0E
	pea	ram_FFDC58
	move.l	a2,-(sp)
	move.l	a4,-(sp)
	jsr	sub_30F9C
	movea.l	($E,a2),a1
	exg	d2,a1
	andi.l	#$80020,d2
	exg	d2,a1
	lea	($1C,sp),sp
	beq.s	.l31A24
	movea.l	($C,a4),a0
	bset	#$5,($38,a0)
.l31A24:
	eori.b	#$1,ram_FFDC1E
	move.b	#$1,ram_FFDC1C
	moveq	#$0,d0
	movea.l	d0,a4
	clr.w	d3
	move.l	ram_FFDBEE,d2
	move.l	#$FFDBEE,d1
	movea.l	#ram_FFDBF6,a2
	bra.s	.l31A76
.l31A4E:
	move.w	d3,d0
	addq.w	#1,d3
	movea.l	d2,a5
	move.w	d0,($1A,a5)
	movea.l	d2,a5
	movea.l	($8,a5),a0
	movea.l	($E,a0),a1
	exg	d5,a1
	andi.l	#$80020,d5
	exg	d5,a1
	beq.s	.l31A72
	move.w	d3,d4
	movea.l	(a2),a4
.l31A72:
	movea.l	d2,a0
	move.l	(a0),d2
.l31A76:
	cmp.l	d1,d2
	bne.s	.l31A4E
	move.l	a4,d0
	beq.s	.l31A96
	move.w	d4,d3
	move.l	#$FFDBF6,d1
	bra.s	.l31A92
.l31A88:
	move.w	d3,d0
	addq.w	#1,d3
	move.w	d0,($1A,a4)
	movea.l	(a4),a4
.l31A92:
	cmpa.l	d1,a4
	bne.s	.l31A88
.l31A96:
	move.l	($E,a3),d1
	andi.l	#$40000,d1
	movea.l	d1,a1
	move.l	($E,a3),d0
	andi.l	#$80,d0
	move.l	a1,d1
	or.l	d0,d1
	movea.l	d1,a1
.l31AB2:
	move.l	a1,d0
	movem.l	(-$24,a6),d2-d5/a2-a5
	unlk	a6
	rts
sub_31ABE:
	link	a6,#$FFFC
	movem.l	d2-d4/a2-a3,-(sp)
	move.l	($8,a6),d3
	move.l	($C,a6),d2
	movea.l	#ram_FFDC74,a3
	clr.b	ram_FFDC1E
	clr.b	ram_FFDBD0
	clr.b	ram_FF9514
	clr.w	ram_FFDBE6
	move.l	#$FFFFF3E0,ram_FFDBDE
	jsr	sub_4170E
	clr.w	d4
	movea.l	#ram_FFDC78,a0
	movea.l	#ram_FFDC84,a1
	movea.l	#ram_FFDC86,a2
.l31B10:
	clr.l	(a0)
	clr.b	d0
	move.b	d0,(a2)
	move.b	d0,(a1)
	addq.w	#1,d4
	addq.l	#1,a2
	addq.l	#1,a1
	addq.l	#4,a0
	cmpi.w	#$2,d4
	blt.s	.l31B10
	clr.l	ram_FFDC80
	moveq	#$0,d0
	move.l	d0,ram_FFDC0A
	move.l	d0,ram_FFDC06
	move.l	d0,ram_FFDC02
	move.l	d0,ram_FFDBFE
	move.w	d0,ram_FFDC6A
	pea	ram_FFDC22
	pea	dat_47D34
	jsr	sub_22DD6
	clr.w	ram_FFDC1A
	move.l	d3,ram_FFDC6C
	clr.w	d4
	movea.l	#ram_FFDC6C,a1
	lea	(-$4,a6),a2
	addq.l	#8,sp
	bra.s	.l31B96
.l31B7A:
	movea.l	(a1),a0
	addq.l	#4,(a1)
	move.l	(a0),d0
	movea.l	(a1),a0
	move.l	(a0),(a2)
	movea.l	(a2),a0
	exg	d1,a0
	andi.l	#$80000000,d1
	exg	d1,a0
	beq.s	.l31B94
	addq.l	#4,(a1)
.l31B94:
	addq.w	#1,d4
.l31B96:
	move.w	d4,d0
	ext.l	d0
	cmp.l	d2,d0
	blt.s	.l31B7A
	moveq	#$C,d2
	clr.w	d4
.l31BA2:
	jsr	sub_3186A
	move.w	d0,d3
	addq.w	#1,d4
	move.w	d4,d0
	ext.l	d0
	cmp.l	d2,d0
	blt.s	.l31BA2
	pea	ram_FFDC22
	move.l	ram_FFDC0A,-(sp)
	move.l	ram_FFDC06,-(sp)
	move.l	ram_FFDC02,-(sp)
	pea	$53.w
	jsr	sub_2EF4C
	move.l	d0,(a3)
	movea.l	(a3),a0
	move.w	#$1900,($36,a0)
	tst.w	d3
	lea	($14,sp),sp
	beq.s	.l31BF8
	movea.l	(a3),a0
	andi.b	#$F9,($38,a0)
	ori.b	#$4,($38,a0)
	bra.s	.l31C10
.l31BF8:
	movea.l	(a3),a0
	move.b	ram_FFDC1E,d0
	and.b	#$3,d0
	add.b	d0,d0
	andi.b	#$F9,($38,a0)
	or.b	d0,($38,a0)
.l31C10:
	tst.w	d3
	beq.s	.l31C18
	moveq	#$1,d0
	bra.s	.l31C1A
.l31C18:
	moveq	#$0,d0
.l31C1A:
	movea.l	(a3),a0
	and.b	#$1,d0
	lsl.b	#5,d0
	andi.b	#$DF,($38,a0)
	or.b	d0,($38,a0)
	move.l	(a3),-(sp)
	jsr	sub_2E7EE
	clr.w	d0
	move.w	d0,ram_FFDBD6
	move.w	d0,ram_FFDBD4
	move.w	d0,ram_FFDBD2
	clr.w	d0
	move.w	d0,ram_FFDBDC
	move.w	d0,ram_FFDBDA
	move.w	d0,ram_FFDBD8
	cmpi.w	#$16,ram_FF9578
	addq.l	#4,sp
	bne.s	.l31C80
	moveq	#$5,d1
	clr.w	d4
	movea.l	#ram_FFDBE8,a0
.l31C72:
	clr.b	(a0)
	addq.w	#1,d4
	addq.l	#1,a0
	move.w	d4,d0
	ext.l	d0
	cmp.l	d1,d0
	blt.s	.l31C72
.l31C80:
	movem.l	(-$18,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_31C8A:
	link	a6,#$FFD4
	movem.l	d2-d6/a2-a5,-(sp)
	move.l	#$FFDC1A,(-$4,a6)
	move.b	ram_FFDCEE,(-$D,a6)
	clr.w	(-$12,a6)
	tst.l	ram_FFDC80
	beq.s	.l31CFE
	btst	#$0,ram_FF9567
	beq.s	.l31CFE
	movea.l	#ram_FFDC88,a2
	addq.b	#1,(a2)
	move.b	(a2),d0
	subq.b	#4,d0
	bcs.s	.l31CCC
	clr.b	ram_FFDC88
.l31CCC:
	movea.l	ram_FFDC80,a2
	moveq	#$0,d0
	move.b	ram_FFDC88,d0
	add.w	d0,d0
	movea.l	#dat_4B04E,a0
	moveq	#$0,d3
	move.w	($0,a0,d0.w),d3
	move.l	d3,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	move.b	#$1,ram_FFDC1C
	addq.l	#4,sp
.l31CFE:
	moveq	#$1,d3
	moveq	#$7,d5
	clr.w	(-$A,a6)
	movea.l	#ram_FFDC78,a4
	movea.l	#ram_FFDC86,a3
	move.l	#$FFDC84,d4
.l31D18:
	tst.l	(a4)
	beq.w	.l31D8E
	tst.b	(a3)
	beq.w	.l31D8E
	moveq	#$0,d0
	move.b	(a3),d0
	move.l	d0,d2
	cmp.l	d5,d2
	bhi.w	.l31D8E
	movea.l	d4,a0
	subq.b	#1,(a0)
	bne.s	.l31D8E
	addq.b	#1,(a3)
	move.b	(a3),d0
	moveq	#$0,d1
	move.b	d0,d1
	move.l	d1,d2
	cmp.l	d5,d2
	bls.s	.l31D5A
	movea.l	(a4),a2
	move.b	d3,d0
	and.b	#$1,d0
	lsl.b	#5,d0
	andi.b	#$DF,($38,a2)
	or.b	d0,($38,a2)
	bra.s	.l31D8E
.l31D5A:
	movea.l	d4,a5
	move.b	#$2,(a5)
	movea.l	(a4),a2
	moveq	#$0,d0
	move.b	(a3),d0
	move.l	d0,d2
	moveq	#$7B,d1
	add.l	d1,d2
	move.l	d2,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	(a4),a2
	move.b	d3,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	addq.l	#4,sp
.l31D8E:
	addq.w	#1,(-$A,a6)
	addq.l	#1,d4
	addq.l	#1,a3
	addq.l	#4,a4
	cmpi.w	#$2,(-$A,a6)
	blt.w	.l31D18
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a0
	move.l	($8,a0),d6
	movea.l	(-$8,a6),a0
	move.l	($C,a0),d5
	movea.l	d6,a0
	move.w	($8,a0),d2
	ext.l	d2
	movea.l	d6,a0
	move.w	($6,a0),d0
	ext.l	d0
	sub.l	d0,d2
	cmp.l	ram_FFDBFE,d2
	bgt.w	.l325D2
	pea	ram_FFDC34
	movea.l	d5,a2
	pea	($14,a2)
	jsr	sub_22DD6
	tst.b	ram_FF9BC0
	addq.l	#8,sp
	beq.s	.l31E16
	move.w	ram_FFDBD2,ram_FFDBD4
	move.w	ram_FFDBD8,ram_FFDBDA
	clr.w	d0
	move.w	d0,ram_FFDBDC
	move.w	d0,ram_FFDBD6
.l31E16:
	cmpi.w	#$7FF,ram_FFDD16
	bgt.s	.l31E2A
	move.w	ram_FFDD16,d0
	ext.l	d0
	bra.s	.l31E30
.l31E2A:
	move.l	#$7FF,d0
.l31E30:
	move.w	d0,(-$A,a6)
	move.w	(-$A,a6),d2
	ext.l	d2
	asr.l	#6,d2
	moveq	#$1F,d0
	and.l	d0,d2
	add.w	d2,d2
	movea.l	#dat_4B00E,a2
	move.w	($0,a2,d2.w),ram_FFDC6A
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$80020,d1
	beq.s	.l31E6C
	pea	ram_FFDBF6
	jsr	sub_2EAB4
	addq.l	#4,sp
.l31E6C:
	movea.l	d6,a4
	move.w	($10,a4),(-$10,a6)
	andi.w	#$80,(-$10,a6)
	movea.l	d6,a4
	move.w	($8,a4),d2
	ext.l	d2
	sub.l	d2,ram_FFDBFE
	move.l	ram_FFDBEE,(-$8,a6)
	movea.l	(-$8,a6),a4
	move.l	($C,a4),-(sp)
	jsr	sub_2E872
	movea.l	(-$8,a6),a4
	clr.l	($C,a4)
	movea.l	#ram_FFDC80,a3
	movea.l	(-$8,a6),a4
	lea	($10,a4),a2
	addq.l	#4,sp
.l31EB6:
	movea.l	(-$8,a6),a0
	move.l	($10,a0),d1
	movea.l	d1,a4
	cmpa.l	d1,a2
	beq.s	.l31EF0
	move.l	(a3),d1
	cmp.l	($8,a4),d1
	bne.s	.l31ED0
	clr.l	(a3)
	bra.s	.l31EDA
.l31ED0:
	move.l	a4,-(sp)
	jsr	sub_333A4
	addq.l	#4,sp
.l31EDA:
	move.l	($8,a4),-(sp)
	jsr	sub_2E872
	move.l	a4,-(sp)
	jsr	sub_2E92E
	addq.l	#8,sp
	bra.s	.l31EB6
.l31EF0:
	moveq	#$9,d3
	movea.l	ram_FFDAAE,a0
	move.l	#$FFDAAE,d4
	movea.l	#ram_FF9532,a3
	bra.s	.l31F44
.l31F06:
	move.l	(-$8,a6),d0
	cmp.l	($1A,a0),d0
	bne.s	.l31F2C
	movea.l	($12,a0),a2
	btst	#$5,($38,a2)
	bne.s	.l31F1E
	addq.l	#5,(a3)
.l31F1E:
	move.l	a0,-(sp)
	jsr	sub_35502
	move.l	d0,d5
	addq.l	#4,sp
	bra.s	.l31F42
.l31F2C:
	addq.w	#1,(-$12,a6)
	move.l	(a0),d5
	move.w	(-$12,a6),d2
	ext.l	d2
	cmp.l	d3,d2
	ble.s	.l31F42
	jsr	soft_reset
.l31F42:
	movea.l	d5,a0
.l31F44:
	cmpa.l	d4,a0
	bne.s	.l31F06
	move.l	(-$8,a6),-(sp)
	jsr	sub_2E8D0
	addi.l	#$1840,ram_FFDBDE
	addq.w	#1,ram_FFDBE6
	cmpi.w	#$16,ram_FF9578
	addq.l	#4,sp
	bne.s	.l31FBE
	moveq	#$0,d0
	move.w	game_options,d0
	move.l	d0,d2
	andi.l	#$100,d2
	beq.s	.l31FBE
	cmpi.w	#$217,ram_FFDBE6
	bne.s	.l31FBE
	move.w	#$2D,ram_FF954E
	move.l	#str_4AFF6,ram_FFDE74
	move.w	#$28,ram_FF9550
	jsr	sub_2BAD6
	pea	$16.w
	jsr	queue_sound_command
	move.b	#$1,ram_FF9514
	addq.l	#4,sp
.l31FBE:
	jsr	sub_3186A
	tst.l	d0
	beq.s	.l31FDC
	movea.l	ram_FFDC74,a2
	andi.b	#$F9,($38,a2)
	ori.b	#$4,($38,a2)
	bra.s	.l31FF8
.l31FDC:
	movea.l	ram_FFDC74,a2
	move.b	ram_FFDC1E,d0
	and.b	#$3,d0
	add.b	d0,d0
	andi.b	#$F9,($38,a2)
	or.b	d0,($38,a2)
.l31FF8:
	movea.l	ram_FFDC74,a2
	pea	($14,a2)
	pea	ram_FFDC22
	jsr	sub_22DD6
	movea.l	ram_FFDBF2,a2
	movea.l	($8,a2),a0
	btst	#$7,($11,a0)
	addq.l	#8,sp
	beq.s	.l32026
	moveq	#$1,d0
	bra.s	.l32028
.l32026:
	moveq	#$0,d0
.l32028:
	movea.l	ram_FFDC74,a2
	and.b	#$1,d0
	lsl.b	#5,d0
	andi.b	#$DF,($38,a2)
	or.b	d0,($38,a2)
	movea.l	ram_FFDC74,a2
	move.l	ram_FFDC02,($8,a2)
	movea.l	ram_FFDC74,a2
	move.l	ram_FFDC06,($C,a2)
	movea.l	ram_FFDC74,a2
	move.l	ram_FFDC0A,($10,a2)
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a0
	move.l	($8,a0),d6
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$100,d1
	beq.s	.l320C4
	move.w	#$3,ram_FF9550
	pea	$21.w
	jsr	queue_sound_command
	pea	$B.w
	jsr	queue_sound_command
	move.w	ram_FF9578,d0
	asl.w	#2,d0
	movea.l	#dat_4AF7E,a2
	move.l	($0,a2,d0.w),d2
	add.l	d2,ram_FF9532
	addq.w	#1,ram_FF9578
	addq.l	#8,sp
.l320C4:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$40000,d1
	beq.s	.l32110
	tst.b	ram_FFDCF2
	bne.s	.l32110
	move.b	#$1,ram_FFDCF2
	move.w	ram_FF9578,d0
	cmpi.w	#$8,d0
	blt.s	.l32110
	bgt.s	.l320F2
	bra.s	.l320FA
.l320F2:
	cmpi.w	#$B,d0
	bne.s	.l32110
	bra.s	.l32104
.l320FA:
	move.w	#$C,ram_FF9578
	bra.s	.l32110
.l32104:
	move.w	#$11,ram_FF9578
	bra.w	.l32110
.l32110:
	movea.l	d6,a0
	btst	#$2,($11,a0)
	beq.s	.l3215C
	tst.l	ram_FF9BAE
	beq.s	.l32132
	move.b	#$1,ram_FF9BC2
	clr.b	ram_FF9BC0
	bra.s	.l32140
.l32132:
	clr.b	ram_FF9BC2
	move.b	#$1,ram_FF9BC0
.l32140:
	move.b	#$1,ram_FF9540
	clr.b	ram_FF953E
	move.b	#$1,ram_FFDBCC
	addq.w	#1,ram_FF9B94
.l3215C:
	movea.l	d6,a0
	btst	#$3,($11,a0)
	beq.s	.l32180
	clr.b	ram_FF9540
	clr.b	ram_FF9BC2
	clr.b	ram_FF9BC0
	move.b	#$1,ram_FF953E
.l32180:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$100000,d1
	beq.s	.l32196
	move.b	#$1,ram_FF9BC2
.l32196:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$400000,d1
	beq.s	.l321AA
	clr.b	ram_FF9BC2
.l321AA:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$100,d1
	beq.s	.l321C0
	move.b	#$1,ram_FF953E
.l321C0:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$400,d1
	beq.s	.l321E4
	move.b	#$1,ram_FF9542
	move.b	#$1,ram_FF9BC0
	clr.b	ram_FF9BC2
.l321E4:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$800,d1
	beq.s	.l3222C
	clr.b	ram_FF9542
	clr.b	ram_FF9BC0
	clr.b	ram_FF9BC2
	clr.w	d0
	move.w	d0,ram_FFDBD6
	move.w	d0,ram_FFDBD4
	move.w	d0,ram_FFDBD2
	clr.w	d0
	move.w	d0,ram_FFDBDC
	move.w	d0,ram_FFDBDA
	move.w	d0,ram_FFDBD8
.l3222C:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$2000,d1
	beq.s	.l32242
	move.w	#$8,ram_FF9BB6
.l32242:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$4000,d1
	beq.s	.l32256
	clr.w	ram_FF9BB6
.l32256:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$10000,d1
	beq.s	.l32280
	move.w	ram_FF9578,d1
	movea.l	#dat_4AEFA,a2
	moveq	#$0,d0
	move.b	($0,a2,d1.w),d0
	move.l	d0,-(sp)
	jsr	queue_sound_command
	addq.l	#4,sp
.l32280:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$20000,d1
	beq.s	.l322DC
	movea.l	d6,a0
	move.w	($C,a0),d0
	blt.s	.l322C4
	bgt.s	.l3229A
	bra.s	.l322A0
.l3229A:
	subq.w	#1,d0
	bne.s	.l322C4
	bra.s	.l322B4
.l322A0:
	move.w	ram_FF9578,d0
	ext.l	d0
	movea.l	#dat_4CB1C,a2
.l322AE:
	move.b	($0,a2,d0.l),d1
	bra.s	.l322CA
.l322B4:
	move.w	ram_FF9578,d0
	ext.l	d0
	movea.l	#dat_4CB36,a2
	bra.s	.l322AE
.l322C4:
	movea.l	d6,a0
	move.b	($D,a0),d1
.l322CA:
	tst.b	d1
	beq.s	.l322DC
	moveq	#$0,d0
	move.b	d1,d0
	move.l	d0,-(sp)
	jsr	sub_2DA6E
	addq.l	#4,sp
.l322DC:
	tst.b	ram_FF9BC0
	beq.w	.l32398
	move.w	ram_FFDBD2,ram_FFDBD4
	movea.l	d6,a0
	tst.b	($5,a0)
	beq.s	.l32348
	movea.l	d6,a0
	move.b	($5,a0),d1
	ext.w	d1
	ext.l	d1
	addq.l	#4,d1
	add.w	d1,d1
	movea.l	#dat_4AF10,a2
	move.w	($0,a2,d1.w),d0
	ext.l	d0
	move.l	d0,d1
	asl.l	#3,d0
	move.l	d0,d2
	add.l	d0,d0
	add.l	d2,d0
	add.l	d1,d0
	move.l	d0,d2
	divs.w	#$28,d2
	move.w	d2,(-$A,a6)
	move.w	(-$A,a6),d0
	add.w	d0,ram_FFDBD2
	move.w	(-$A,a6),d2
	ext.l	d2
	divs.w	ram_FFDC6A,d2
	ext.l	d2
	move.w	d2,ram_FFDBD6
	bra.s	.l3234E
.l32348:
	clr.w	ram_FFDBD6
.l3234E:
	movea.l	d6,a0
	tst.b	($4,a0)
	beq.s	.l32392
	moveq	#$4,d2
	movea.l	d6,a0
	move.b	($4,a0),d0
	ext.w	d0
	ext.l	d0
	sub.l	d0,d2
	add.w	d2,d2
	movea.l	#dat_4AF10,a2
	move.w	($0,a2,d2.w),(-$A,a6)
	move.w	(-$A,a6),d0
	add.w	d0,ram_FFDBD8
	move.w	(-$A,a6),d2
	ext.l	d2
	divs.w	ram_FFDC6A,d2
	ext.l	d2
	move.w	d2,ram_FFDBDC
	bra.s	.l32398
.l32392:
	clr.w	ram_FFDBDC
.l32398:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$80,d1
	move.b	d1,ram_FF9544
	movea.l	d6,a0
	btst	#$0,($11,a0)
	beq.w	.l32440
	moveq	#$1,d4
	moveq	#$2,d3
	clr.w	(-$A,a6)
	moveq	#$1,d0
	move.w	d0,(-$C,a6)
	movea.l	#ram_FFDC78,a3
	movea.l	#ram_FFDC86,a4
	move.l	#$FFDC84,d5
	bra.w	.l32436
.l323DA:
	tst.l	(a3)
	beq.s	.l3242C
	tst.b	(a4)
	bne.s	.l3242C
	addq.b	#1,(a4)
	movea.l	d5,a5
	move.b	d3,(a5)
	movea.l	(a3),a2
	moveq	#$0,d0
	move.b	(a4),d0
	move.l	d0,d2
	moveq	#$7B,d1
	add.l	d1,d2
	move.l	d2,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	(a3),a2
	move.b	d4,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	tst.w	(-$C,a6)
	addq.l	#4,sp
	beq.s	.l3242C
	pea	$68.w
	jsr	queue_sound_command
	clr.w	(-$C,a6)
	addq.l	#4,sp
.l3242C:
	addq.w	#1,(-$A,a6)
	addq.l	#1,d5
	addq.l	#1,a4
	addq.l	#4,a3
.l32436:
	move.w	(-$A,a6),d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l323DA
.l32440:
	movea.l	d6,a0
	btst	#$7,($11,a0)
	beq.s	.l32454
	move.b	#$1,ram_FF9544
	bra.s	.l3245A
.l32454:
	clr.b	ram_FF9544
.l3245A:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$80,d1
	moveq	#$0,d3
	move.w	(-$10,a6),d3
	move.l	d3,d0
	eor.l	d0,d1
	beq.w	.l32548
	pea	(-$1E,a6)
	pea	ram_FF9C88
	movea.l	(-$8,a6),a2
	move.l	($C,a2),-(sp)
	jsr	sub_3C136
	tst.w	(-$10,a6)
	lea	($C,sp),sp
	beq.s	.l32500
	move.l	(-$1E,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$1A,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	sub_30DB0
	movea.l	(-$4,a6),a2
	move.w	d0,(a2)
	move.w	ram_FFDD1C,d0
	asl.w	#3,d0
	move.w	d0,ram_FFDD1C
	pea	(-$1E,a6)
	pea	ram_FFDAF8
	movea.l	(-$8,a6),a2
	move.l	($C,a2),-(sp)
	jsr	sub_3C136
	move.l	(-$1E,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$1A,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	sub_30DB0
	move.w	d0,ram_FFDCDC
	move.w	d0,ram_FFDCDE
	lea	($1C,sp),sp
	bra.s	.l32548
.l32500:
	move.w	ram_FFDD1C,d0
	asr.w	#3,d0
	move.w	d0,ram_FFDD1C
	move.l	(-$1E,a6),d2
	neg.l	d2
	movea.l	(-$4,a6),a2
	move.w	d2,(a2)
	pea	(-$1E,a6)
	pea	ram_FFDAF8
	movea.l	(-$8,a6),a2
	move.l	($C,a2),-(sp)
	jsr	sub_3C136
	move.l	(-$1E,a6),d2
	neg.l	d2
	move.w	d2,ram_FFDCDC
	move.w	d2,ram_FFDCDE
	lea	($C,sp),sp
.l32548:
	movea.l	d6,a0
	btst	#$5,($11,a0)
	beq.s	.l3257C
	movea.l	(-$4,a6),a0
	cmpi.w	#$8000,(a0)
	bcs.s	.l3257A
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a3
	move.l	($8,a3),d6
	addq.l	#4,sp
.l3257A:
	bra.s	.l325C0
.l3257C:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$80000,d1
	beq.s	.l325C0
	moveq	#$0,d0
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	move.l	d0,d2
	addi.l	#$4000,d2
	andi.l	#$8000,d2
	beq.s	.l325C0
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a3
	move.l	($8,a3),d6
	addq.l	#4,sp
.l325C0:
	movea.l	(-$8,a6),a2
	move.l	($C,a2),d5
	move.l	d5,-(sp)
	jsr	sub_33406
	addq.l	#4,sp
.l325D2:
	cmpi.w	#$16,ram_FF9578
	bne.w	.l32646
	moveq	#$1,d3
	moveq	#$4,d0
	move.w	d0,(-$A,a6)
	movea.l	#io_FF4598,a2
	movea.l	#ram_FFDBEC,a4
	movea.l	#ram_FFDBE6,a3
	move.l	#$FFDBFE,d4
.l325FE:
	tst.b	(a4)
	bne.s	.l32636
	move.w	($4,a2),d0
	cmp.w	(a3),d0
	bls.s	.l3260C
	bra.s	.l32646
.l3260C:
	move.w	($4,a2),d0
	cmp.w	(a3),d0
	bcs.s	.l32628
	move.w	($4,a2),d0
	cmp.w	(a3),d0
	bne.s	.l32636
	move.w	($6,a2),d2
	ext.l	d2
	movea.l	d4,a0
	cmp.l	(a0),d2
	bge.s	.l32636
.l32628:
	move.b	d3,(a4)
	pea	$16.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l32636:
	subq.w	#1,(-$A,a6)
	subq.l	#1,a4
	moveq	#$1C,d2
	suba.l	d2,a2
	tst.w	(-$A,a6)
	bge.s	.l325FE
.l32646:
	pea	ram_FF9C94
	movea.l	d5,a2
	pea	($14,a2)
	jsr	sub_22DD6
	movea.l	d5,a2
	move.l	($8,a2),ram_FF9C88
	movea.l	d5,a2
	move.l	($C,a2),ram_FF9C8C
	movea.l	d5,a2
	move.l	($10,a2),ram_FF9C90
	move.l	ram_FFDBFE,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D0AE
	bset	#$6,ram_FF9CB8
	tst.w	ram_FFDC6A
	lea	($10,sp),sp
	beq.w	.l327B0
	subq.w	#1,ram_FFDC6A
	clr.w	(-$A,a6)
	movea.l	#ram_FFDC34,a2
	movea.l	#ram_FFDC46,a3
.l326B4:
	moveq	#$3,d1
	clr.w	(-$C,a6)
	movea.l	a2,a0
	movea.l	a3,a1
.l326BE:
	move.w	(a1),d0
	add.w	d0,(a0)
	addq.w	#1,(-$C,a6)
	addq.l	#2,a1
	addq.l	#2,a0
	move.w	(-$C,a6),d2
	ext.l	d2
	cmp.l	d1,d2
	blt.s	.l326BE
	addq.w	#1,(-$A,a6)
	addq.l	#6,a3
	addq.l	#6,a2
	cmpi.w	#$3,(-$A,a6)
	blt.s	.l326B4
	pea	ram_FF9C94
	pea	ram_FFDC34
	jsr	sub_22DD6
	tst.w	ram_FFDBD6
	addq.l	#8,sp
	beq.w	.l32754
	move.w	ram_FFDBD6,d0
	add.w	d0,ram_FFDBD4
	tst.w	ram_FFDBD6
	bge.s	.l32736
	move.w	ram_FFDBD2,d0
	cmp.w	ram_FFDBD4,d0
	ble.s	.l32734
	move.w	ram_FFDBD2,ram_FFDBD4
	clr.w	ram_FFDBD6
.l32734:
	bra.s	.l32754
.l32736:
	move.w	ram_FFDBD2,d0
	cmp.w	ram_FFDBD4,d0
	bge.s	.l32754
	move.w	ram_FFDBD2,ram_FFDBD4
	clr.w	ram_FFDBD6
.l32754:
	tst.w	ram_FFDBDC
	beq.w	.l327B0
	move.w	ram_FFDBDC,d0
	add.w	d0,ram_FFDBDA
	tst.w	ram_FFDBDC
	bge.s	.l32792
	move.w	ram_FFDBD8,d0
	cmp.w	ram_FFDBDA,d0
	ble.s	.l32790
	move.w	ram_FFDBD8,ram_FFDBDA
	clr.w	ram_FFDBDC
.l32790:
	bra.s	.l327B0
.l32792:
	move.w	ram_FFDBD8,d0
	cmp.w	ram_FFDBDA,d0
	bge.s	.l327B0
	move.w	ram_FFDBD8,ram_FFDBDA
	clr.w	ram_FFDBDC
.l327B0:
	movea.l	#ram_FF9C80,a2
	movea.l	#ram_FFDAF0,a0
	moveq	#$1E,d2
.l327BE:
	move.w	(a2)+,(a0)+
	dbf	d2,.l327BE
	movea.l	d6,a1
	btst	#$1,($11,a1)
	beq.s	.l327E4
	move.l	ram_FFDBFE,d2
	movea.l	d6,a0
	divs.w	($C,a0),d2
	movea.w	d2,a3
	movea.l	d6,a0
	adda.w	($A,a0),a3
	bra.s	.l327EA
.l327E4:
	movea.l	d6,a0
	movea.w	($A,a0),a3
.l327EA:
	tst.b	ram_FFDCF0
	beq.s	.l32800
	move.w	ram_FFDD00,d2
	ext.l	d2
	divs.w	#$7,d2
	suba.w	d2,a3
.l32800:
	movea.l	d6,a0
	btst	#$7,($11,a0)
	bne.w	.l32C4E
	clr.b	ram_FFDCEE
	move.w	#$C16,d0
	movea.l	(-$4,a6),a0
	sub.w	(a0),d0
	cmpi.w	#$182D,d0
	bls.w	.l32958
	movea.l	d6,a0
	btst	#$5,($11,a0)
	beq.w	.l3289A
	tst.b	ram_FFDC20
	beq.s	.l32842
	movea.l	(-$4,a6),a0
	cmpi.w	#$8000,(a0)
	bhi.s	.l32854
.l32842:
	tst.b	ram_FFDC20
	bne.s	.l32896
	movea.l	(-$4,a6),a0
	cmpi.w	#$8000,(a0)
	bcc.s	.l32896
.l32854:
	pea	ram_FFDC34
	movea.l	d5,a4
	pea	($14,a4)
	jsr	sub_22DD6
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a4
	move.l	($8,a4),d6
	movea.l	(-$8,a6),a4
	move.l	($C,a4),d5
	move.l	d5,-(sp)
	jsr	sub_33406
	lea	($10,sp),sp
.l32896:
	bra.w	.l3291C
.l3289A:
	movea.l	d6,a0
	move.l	($E,a0),d1
	andi.l	#$80000,d1
	beq.w	.l3291C
	movea.l	(-$4,a6),a0
	move.w	(a0),(-$A,a6)
	addi.w	#$4000,(-$A,a6)
	andi.w	#$8000,(-$A,a6)
	tst.b	ram_FFDC20
	beq.s	.l328CC
	tst.w	(-$A,a6)
	bne.s	.l328DA
.l328CC:
	tst.b	ram_FFDC20
	bne.s	.l3291C
	tst.w	(-$A,a6)
	bne.s	.l3291C
.l328DA:
	pea	ram_FFDC34
	movea.l	d5,a4
	pea	($14,a4)
	jsr	sub_22DD6
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a4
	move.l	($8,a4),d6
	movea.l	(-$8,a6),a4
	move.l	($C,a4),d5
	move.l	d5,-(sp)
	jsr	sub_33406
	lea	($10,sp),sp
.l3291C:
	pea	ram_FF9C94
	moveq	#$0,d0
	movea.l	(-$4,a6),a2
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	(-$4,a6),a2
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	lea	($C,sp),sp
	bra.w	.l32A50
.l32958:
	moveq	#$0,d0
	move.w	a3,d0
	move.l	d0,d2
	divu.w	#$14,d2
	suba.w	d2,a3
	moveq	#$0,d0
	movea.l	(-$4,a6),a2
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	move.l	d0,d4
	moveq	#$0,d3
	move.w	a3,d3
	move.l	d4,d1
	move.l	d1,d0
	mulu.w	d3,d4
	swap	d1
	mulu.w	d3,d1
	swap	d3
	mulu.w	d3,d0
	add.l	d1,d0
	swap	d0
	clr.w	d0
	add.l	d0,d4
	moveq	#$E,d0
	asr.l	d0,d4
	move.l	d4,d2
	neg.l	d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D172
	movea.l	d6,a2
	btst	#$5,($11,a2)
	lea	($C,sp),sp
	beq.w	.l32A50
	pea	(-$1E,a6)
	pea	ram_FF9C88
	movea.l	ram_FFDBF6,a2
	move.l	($C,a2),-(sp)
	jsr	sub_3C136
	tst.l	(-$1E,a6)
	lea	($C,sp),sp
	blt.s	.l329E0
	move.l	(-$1E,a6),d0
	bra.s	.l329E6
.l329E0:
	move.l	(-$1E,a6),d0
	neg.l	d0
.l329E6:
	tst.l	d4
	blt.s	.l329EC
	bra.s	.l329EE
.l329EC:
	neg.l	d4
.l329EE:
	cmp.l	d4,d0
	bge.s	.l32A50
	pea	ram_FFDC34
	movea.l	d5,a4
	pea	($14,a4)
	jsr	sub_22DD6
	move.l	(-$1E,a6),d2
	neg.l	d2
	move.l	d2,-(sp)
	move.l	(-$1A,a6),d0
	neg.l	d0
	move.l	d0,-(sp)
	jsr	sub_30DB0
	movea.l	(-$4,a6),a4
	move.w	d0,(a4)
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a4
	move.l	($8,a4),d6
	movea.l	(-$8,a6),a4
	move.l	($C,a4),d5
	move.l	d5,-(sp)
	jsr	sub_33406
	lea	($18,sp),sp
.l32A50:
	tst.b	ram_FFDCF4
	beq.s	.l32A7C
	move.w	ram_FFDCFC,d1
	ext.l	d1
	moveq	#$0,d3
	move.w	a3,d3
	move.l	d3,d0
	sub.l	d0,d1
	move.l	d1,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D110
	addq.l	#8,sp
	bra.w	.l32BBC
.l32A7C:
	tst.w	ram_FFDD24
	beq.w	.l32B88
	move.w	ram_FFDD24,d2
	ext.l	d2
	asr.l	#1,d2
	move.w	ram_FFDD24,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_23FBA
	move.l	d0,d1
	sub.l	d1,d2
	move.w	d2,ram_FFDD24
	move.w	ram_FFDD24,d2
	ext.l	d2
	move.w	ram_FFDD22,d0
	ext.l	d0
	move.w	ram_FFDD20,d1
	ext.l	d1
	add.l	d1,d0
	add.l	d0,d2
	moveq	#$0,d0
	move.w	a3,d0
	sub.l	d0,d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D110
	pea	$2.w
	jsr	sub_41606
	move.w	ram_FFDD22,d2
	ext.l	d2
	move.w	ram_FFDD24,d0
	ext.l	d0
	add.l	d0,d2
	moveq	#-$C,d1
	cmp.l	d2,d1
	lea	($10,sp),sp
	ble.w	.l32B86
	pea	$6A.w
	jsr	queue_sound_command
	move.l	#$FFFFFF80,-(sp)
	move.l	#$FFFFFFE0,-(sp)
	moveq	#$30,d2
	pea	$60.w
	jsr	sub_23FBA
	sub.l	d0,d2
	addq.l	#4,sp
	move.l	d2,-(sp)
	pea	$2.w
	jsr	sub_23FBA
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_3DCBC
	pea	$2.w
	jsr	sub_23FBA
	tst.l	d0
	lea	($18,sp),sp
	beq.s	.l32B86
	move.l	#$FFFFFF80,-(sp)
	move.l	#$FFFFFFE0,-(sp)
	moveq	#$30,d2
	pea	$60.w
	jsr	sub_23FBA
	sub.l	d0,d2
	addq.l	#4,sp
	move.l	d2,-(sp)
	pea	$2.w
	jsr	sub_23FBA
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_3DCBC
	lea	($10,sp),sp
.l32B86:
	bra.s	.l32BBC
.l32B88:
	move.w	ram_FFDD22,d2
	ext.l	d2
	move.w	ram_FFDD20,d0
	ext.l	d0
	add.l	d0,d2
	moveq	#$0,d1
	move.w	a3,d1
	sub.l	d1,d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D110
	pea	$2.w
	jsr	sub_416AE
	lea	($C,sp),sp
.l32BBC:
	tst.b	ram_FFDCF0
	beq.s	.l32BDE
	pea	ram_FF9C94
	pea	$666.w
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$666.w
	bra.s	.l32C36
.l32BDE:
	tst.b	ram_FFDCF4
	beq.s	.l32C08
	pea	ram_FF9C94
	move.w	ram_FFDCFE,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	ram_FFDCFE,d2
	bra.s	.l32C32
.l32C08:
	movea.l	d6,a0
	btst	#$1,($11,a0)
	beq.s	.l32C4A
	pea	ram_FF9C94
	movea.l	d6,a2
	move.w	($2,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	movea.l	d6,a2
	move.w	($2,a2),d2
.l32C32:
	ext.l	d2
	move.l	d2,-(sp)
.l32C36:
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	lea	($C,sp),sp
.l32C4A:
	bra.w	.l32F44
.l32C4E:
	movea.l	d6,a0
	btst	#$5,($11,a0)
	beq.w	.l32DC6
	movea.l	(-$4,a6),a4
	move.w	(a4),d2
	ext.l	d2
	neg.l	d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D172
	pea	(-$1E,a6)
	pea	ram_FF9C88
	movea.l	ram_FFDBF6,a2
	move.l	($C,a2),-(sp)
	jsr	sub_3C136
	tst.l	(-$1E,a6)
	lea	($14,sp),sp
	blt.s	.l32C9C
	move.l	(-$1E,a6),d1
	bra.s	.l32CA2
.l32C9C:
	move.l	(-$1E,a6),d1
	neg.l	d1
.l32CA2:
	movea.l	(-$4,a6),a0
	tst.w	(a0)
	blt.s	.l32CB4
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	ext.l	d0
	bra.s	.l32CBE
.l32CB4:
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	ext.l	d0
	neg.l	d0
.l32CBE:
	cmp.l	d0,d1
	bge.s	.l32D10
	pea	ram_FFDC34
	movea.l	d5,a3
	pea	($14,a3)
	jsr	sub_22DD6
	movea.l	(-$4,a6),a3
	move.w	(-$1C,a6),(a3)
	move.l	(-$8,a6),-(sp)
	jsr	sub_33292
	movea.l	ram_FFDBEE,a2
	move.l	(a2),(-$8,a6)
	movea.l	(-$8,a6),a3
	move.l	($8,a3),d6
	movea.l	(-$8,a6),a3
	move.l	($C,a3),d5
	move.l	d5,-(sp)
	jsr	sub_33406
	lea	($10,sp),sp
	bra.w	.l32DC2
.l32D10:
	movea.l	(-$4,a6),a0
	move.w	(a0),d4
	ext.l	d4
	movea.l	(-$4,a6),a0
	cmpi.w	#$8000,(a0)
	bcs.s	.l32D68
	btst	#$5,ram_FF9DB0
	beq.s	.l32D34
	move.l	a3,d0
	addi.w	#$60,d0
	movea.w	d0,a3
.l32D34:
	moveq	#$0,d2
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	ext.l	d0
	moveq	#$0,d3
	move.w	a3,d3
	neg.l	d3
	cmp.l	d3,d0
	scs	d2
	neg.b	d2
	move.b	d2,ram_FFDCEE
	tst.b	ram_FFDCEE
	beq.s	.l32D66
	moveq	#$0,d0
	move.w	a3,d0
	move.l	d0,d1
	neg.l	d1
	movea.l	(-$4,a6),a0
	move.w	d1,(a0)
.l32D66:
	bra.s	.l32D9A
.l32D68:
	btst	#$5,ram_FF9D72
	beq.s	.l32D7A
	move.l	a3,d0
	addi.w	#$60,d0
	movea.w	d0,a3
.l32D7A:
	moveq	#$0,d2
	movea.l	(-$4,a6),a0
	cmpa.w	(a0),a3
	scs	d2
	neg.b	d2
	move.b	d2,ram_FFDCEE
	tst.b	ram_FFDCEE
	beq.s	.l32D9A
	movea.l	(-$4,a6),a0
	move.w	a3,(a0)
.l32D9A:
	movea.l	(-$4,a6),a0
	move.w	(a0),d2
	ext.l	d2
	cmp.l	d4,d2
	beq.s	.l32DC2
	move.l	d4,d2
	movea.l	(-$4,a6),a2
	move.w	(a2),d0
	ext.l	d0
	sub.l	d0,d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D172
	addq.l	#8,sp
.l32DC2:
	bra.w	.l32E62
.l32DC6:
	movea.l	(-$4,a6),a0
	cmpi.w	#$8000,(a0)
	bcs.s	.l32E16
	btst	#$5,ram_FF9DB0
	beq.s	.l32DE2
	move.l	a3,d0
	addi.w	#$60,d0
	movea.w	d0,a3
.l32DE2:
	moveq	#$0,d2
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	ext.l	d0
	moveq	#$0,d3
	move.w	a3,d3
	neg.l	d3
	cmp.l	d3,d0
	scs	d2
	neg.b	d2
	move.b	d2,ram_FFDCEE
	tst.b	ram_FFDCEE
	beq.s	.l32E14
	moveq	#$0,d0
	move.w	a3,d0
	move.l	d0,d1
	neg.l	d1
	movea.l	(-$4,a6),a0
	move.w	d1,(a0)
.l32E14:
	bra.s	.l32E48
.l32E16:
	btst	#$5,ram_FF9D72
	beq.s	.l32E28
	move.l	a3,d0
	addi.w	#$60,d0
	movea.w	d0,a3
.l32E28:
	moveq	#$0,d2
	movea.l	(-$4,a6),a0
	cmpa.w	(a0),a3
	scs	d2
	neg.b	d2
	move.b	d2,ram_FFDCEE
	tst.b	ram_FFDCEE
	beq.s	.l32E48
	movea.l	(-$4,a6),a0
	move.w	a3,(a0)
.l32E48:
	movea.l	(-$4,a6),a2
	move.w	(a2),d2
	ext.l	d2
	neg.l	d2
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D172
	addq.l	#8,sp
.l32E62:
	tst.b	ram_FFDCF4
	beq.s	.l32E74
	move.w	ram_FFDCFC,d2
	ext.l	d2
	bra.s	.l32EBA
.l32E74:
	tst.b	ram_FFDCF0
	beq.s	.l32EA8
	move.w	ram_FFDD00,d0
	ext.l	d0
	divs.w	#$7,d0
	ext.l	d0
	move.l	d0,d2
	move.w	ram_FFDD22,d1
	ext.l	d1
	move.w	ram_FFDD20,d0
	ext.l	d0
	add.l	d0,d1
	subi.l	#$5F0,d1
	add.l	d1,d2
	bra.s	.l32EC0
.l32EA8:
	move.w	ram_FFDD22,d2
	ext.l	d2
	move.w	ram_FFDD20,d0
	ext.l	d0
	add.l	d0,d2
.l32EBA:
	subi.l	#$5F0,d2
.l32EC0:
	move.l	d2,-(sp)
	pea	ram_FF9C80
	jsr	sub_2D110
	addq.l	#8,sp
	tst.b	ram_FFDCF0
	beq.s	.l32EF2
	pea	ram_FF9C94
	pea	$666.w
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$666.w
	bra.s	.l32F1E
.l32EF2:
	tst.b	ram_FFDCF4
	beq.s	.l32F32
	pea	ram_FF9C94
	move.w	ram_FFDCFE,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	ram_FFDCFE,d2
	ext.l	d2
	move.l	d2,-(sp)
.l32F1E:
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	lea	($C,sp),sp
.l32F32:
	tst.b	ram_FFDCEE
	bne.s	.l32F44
	clr.l	-(sp)
	jsr	sub_416AE
	addq.l	#4,sp
.l32F44:
	pea	ram_FF9C94
	move.w	ram_FFDD26,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.w	ram_FFDD26,d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	cmpi.l	#$988,ram_FF9568
	lea	($C,sp),sp
	bge.s	.l32FA0
	cmpi.w	#$1,ram_FF9550
	bne.s	.l32FA0
	btst	#$2,ram_FF9567
	beq.s	.l32FA0
	moveq	#$1,d0
	bra.s	.l32FA2
.l32FA0:
	moveq	#$0,d0
.l32FA2:
	move.w	d0,(-$C,a6)
	move.b	(-$B,a6),d0
	and.b	#$3,d0
	add.b	d0,d0
	andi.b	#$F9,ram_FF9CB8
	or.b	d0,ram_FF9CB8
	moveq	#$1,d1
	move.w	d1,(-$A,a6)
	move.l	#$FF9CBE,d3
	move.l	#$FF9CD2,d4
	movea.l	#ram_FF9CBE,a3
	movea.l	#ram_FFBBD0,a4
	move.l	#$FF9C94,d5
.l32FE2:
	move.w	(-$A,a6),d0
	ext.l	d0
	movea.l	#ram_FFBBBE,a2
	tst.b	($0,a2,d0.l)
	ble.w	.l33052
	move.l	ram_FF9C88,($8,a3)
	move.l	ram_FF9C8C,($C,a3)
	move.l	ram_FF9C90,($10,a3)
	move.w	(-$A,a6),d0
	ext.l	d0
	movea.l	#ram_FFBBC6,a2
	tst.b	($0,a2,d0.l)
	beq.s	.l33040
	cmpi.b	#$4,ram_FFBBBE
	bne.s	.l3303E
	move.w	(a4),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	jsr	sub_2D0AE
	subi.w	#$10,(a4)
	addq.l	#8,sp
.l3303E:
	bra.s	.l3304C
.l33040:
	move.l	d4,-(sp)
	move.l	d5,-(sp)
	jsr	sub_22DD6
	addq.l	#8,sp
.l3304C:
	bset	#$6,($38,a3)
.l33052:
	move.b	(-$B,a6),d0
	and.b	#$3,d0
	add.b	d0,d0
	andi.b	#$F9,($38,a3)
	or.b	d0,($38,a3)
	addq.w	#1,(-$A,a6)
	addq.l	#2,a4
	moveq	#$3E,d2
	adda.l	d2,a3
	moveq	#$3E,d2
	add.l	d2,d4
	moveq	#$3E,d2
	add.l	d2,d3
	cmpi.w	#$8,(-$A,a6)
	blt.w	.l32FE2
	pea	ram_FF9E46
	moveq	#$0,d0
	move.w	ram_FFDD4C,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	ram_FFDD4C,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	move.l	ram_FF9C88,ram_FF9E78
	move.l	ram_FF9C8C,ram_FF9E7C
	move.l	ram_FF9C90,ram_FF9E80
	pea	ram_FF9E84
	pea	ram_FF9C94
	jsr	sub_22DD6
	tst.b	ram_FFDCF4
	lea	($14,sp),sp
	beq.s	.l3310E
	move.w	ram_FFDCFC,d2
	ext.l	d2
	move.w	ram_FFDD22,d0
	ext.l	d0
	move.w	ram_FFDD20,d1
	ext.l	d1
	add.l	d1,d0
	bra.s	.l3311E
.l3310E:
	move.w	ram_FFDD22,d2
	ext.l	d2
	move.w	ram_FFDD20,d0
	ext.l	d0
.l3311E:
	add.l	d0,d2
	neg.l	d2
	move.l	d2,-(sp)
	pea	ram_FF9E70
	jsr	sub_2D110
	addq.l	#8,sp
	bset	#$6,ram_FF9EA8
	cmpi.w	#$17,ram_FF9550
	beq.s	.l33150
	jsr	sub_3DBAE
	jsr	sub_3887A
.l33150:
	move.b	(-$D,a6),d0
	cmp.b	ram_FFDCEE,d0
	beq.s	.l33182
	tst.b	ram_FFDCEE
	beq.s	.l33170
	tst.w	ram_FFDD4E
	bne.s	.l33170
	moveq	#$2D,d0
	bra.s	.l33172
.l33170:
	moveq	#$2E,d0
.l33172:
	move.l	d0,-(sp)
	jsr	queue_sound_command
	clr.b	ram_FFDBCE
	addq.l	#4,sp
.l33182:
	tst.b	ram_FFDCEE
	beq.w	.l33288
	tst.w	ram_FFDD4E
	bne.w	.l33288
	clr.l	-(sp)
	jsr	sub_41606
	tst.b	ram_FFDBCE
	addq.l	#4,sp
	beq.s	.l331B2
	subq.b	#1,ram_FFDBCE
	bra.w	.l33288
.l331B2:
	moveq	#$0,d0
	movea.l	(-$4,a6),a0
	move.w	(a0),d0
	move.l	d0,d2
	andi.l	#$8000,d2
	beq.s	.l33210
	btst	#$5,ram_FF9DB0
	beq.s	.l331D2
	moveq	#$50,d0
	bra.s	.l331D8
.l331D2:
	move.l	#$86,d0
.l331D8:
	move.l	d0,(-$1E,a6)
	cmpi.b	#$1,ram_FFDCE7
	bne.s	.l331EE
	moveq	#$40,d3
	pea	$80.w
	bra.s	.l331F8
.l331EE:
	move.l	#$A0,d3
	pea	$E0.w
.l331F8:
	jsr	sub_23FBA
	move.l	d0,d2
	sub.l	d2,d3
	addq.l	#4,sp
	move.l	d3,(-$16,a6)
	moveq	#$1,d0
	move.w	d0,(-$A,a6)
	bra.s	.l33258
.l33210:
	clr.w	(-$A,a6)
	btst	#$5,ram_FF9D72
	beq.s	.l33222
	moveq	#-$50,d0
	bra.s	.l33228
.l33222:
	move.l	#$FFFFFF7A,d0
.l33228:
	move.l	d0,(-$1E,a6)
	cmpi.b	#$1,ram_FFDCE6
	bne.s	.l3323E
	moveq	#$40,d3
	pea	$80.w
	bra.s	.l33248
.l3323E:
	move.l	#$A0,d3
	pea	$E0.w
.l33248:
	jsr	sub_23FBA
	move.l	d0,d2
	sub.l	d2,d3
	addq.l	#4,sp
	move.l	d3,(-$16,a6)
.l33258:
	move.l	(-$16,a6),-(sp)
	clr.l	-(sp)
	move.l	(-$1E,a6),-(sp)
	move.w	(-$A,a6),d2
	ext.l	d2
	move.l	d2,-(sp)
	jsr	sub_3DCBC
	pea	$8.w
	jsr	sub_23FBA
	move.l	d0,d2
	addq.l	#5,d2
	move.b	d2,ram_FFDBCE
	lea	($14,sp),sp
.l33288:
	movem.l	(-$50,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_33292:
	link	a6,#$FFD8
	movem.l	a2-a3,-(sp)
	movea.l	($8,a6),a2
	movea.l	#ram_FFDBF6,a3
	move.l	ram_FFDC6C,d0
	move.l	ram_FFDC70,ram_FFDC6C
	move.l	d0,ram_FFDC70
	pea	(-$12,a6)
	pea	ram_FFDC22
	jsr	sub_22DD6
	pea	ram_FFDC22
	pea	ram_FFDC58
	jsr	sub_22DD6
	pea	ram_FFDC58
	pea	(-$12,a6)
	jsr	sub_22DD6
	move.l	ram_FFDC02,(-$1E,a6)
	move.l	ram_FFDC06,(-$1A,a6)
	move.l	ram_FFDC0A,(-$16,a6)
	move.l	ram_FFDC0E,ram_FFDC02
	move.l	ram_FFDC12,ram_FFDC06
	move.l	ram_FFDC16,ram_FFDC0A
	move.l	(-$1E,a6),ram_FFDC0E
	move.l	(-$1A,a6),ram_FFDC12
	move.l	(-$16,a6),ram_FFDC16
	move.l	a2,(-$26,a6)
	move.l	ram_FFDBF2,(-$22,a6)
	move.l	($4,a3),ram_FFDBF2
	movea.l	($4,a3),a0
	move.l	#$FFDBEE,(a0)
	movea.l	($4,a2),a0
	move.l	(a3),(a0)
	movea.l	(a3),a0
	move.l	($4,a2),($4,a0)
	lea	(-$26,a6),a0
	movea.l	a3,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	movea.l	(a3),a0
	move.l	a3,($4,a0)
	movea.l	($4,a3),a0
	move.l	a3,(a0)
	moveq	#$0,d0
	tst.b	ram_FFDC20
	seq	d0
	neg.b	d0
	move.b	d0,ram_FFDC20
	movem.l	(-$30,a6),a2-a3
	unlk	a6
	rts
sub_333A4:
	link	a6,#$0
	movem.l	d2,-(sp)
	movea.l	($8,a6),a1
	moveq	#$2,d2
	clr.w	d1
	movea.l	#ram_FFDC78,a0
.l333BA:
	move.l	(a0),d0
	cmp.l	($8,a1),d0
	bne.s	.l333F0
	move.w	d1,d0
	ext.l	d0
	asl.l	#2,d0
	movea.l	#ram_FFDC78,a0
	clr.l	($0,a0,d0.l)
	move.w	d1,d2
	ext.l	d2
	movea.l	#ram_FFDC84,a0
	ext.l	d1
	movea.l	#ram_FFDC86,a1
	clr.b	d0
	move.b	d0,($0,a1,d1.l)
	move.b	d0,($0,a0,d2.l)
	bra.s	.l333FC
.l333F0:
	addq.w	#1,d1
	addq.l	#4,a0
	move.w	d1,d0
	ext.l	d0
	cmp.l	d2,d0
	blt.s	.l333BA
.l333FC:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_33406:
	link	a6,#$0
	movem.l	d2-d4/a2-a4,-(sp)
	movea.l	($8,a6),a1
	move.w	ram_FFDD16,d0
	ext.l	d0
	asr.l	#6,d0
	moveq	#$1F,d1
	and.l	d1,d0
	add.w	d0,d0
	movea.l	#dat_4B00E,a0
	move.w	($0,a0,d0.w),ram_FFDC6A
	moveq	#$0,d4
	move.l	#$FFDC34,d2
	move.l	#$FFDC46,d1
	lea	($14,a1),a0
	movea.l	#ram_FFDC6A,a4
.l33448:
	moveq	#$0,d3
	movea.l	d2,a1
	movea.l	d1,a2
	movea.l	a0,a3
.l33450:
	move.w	(a3),d0
	sub.w	(a1),d0
	ext.l	d0
	divs.w	(a4),d0
	move.w	d0,(a2)
	addq.l	#1,d3
	addq.l	#2,a3
	addq.l	#2,a2
	addq.l	#2,a1
	moveq	#$3,d0
	cmp.l	d3,d0
	bgt.s	.l33450
	addq.l	#1,d4
	addq.l	#6,a0
	addq.l	#6,d1
	addq.l	#6,d2
	moveq	#$3,d0
	cmp.l	d4,d0
	bgt.s	.l33448
	movem.l	(-$18,a6),d2-d4/a2-a4
	unlk	a6
	rts
sub_33480:
	link	a6,#$FFE4
	movem.l	d2-d6/a2-a5,-(sp)
	move.w	($A,a6),d0
	move.l	($C,a6),d3
	move.l	#sub_2EF4C,d6
	tst.w	d0
	bcc.s	.l3349E
	bra.w	loc_33C20
.l3349E:
	tst.b	ram_FF953E
	bne.s	.l334AA
	bra.w	loc_33C20
.l334AA:
	move.w	d0,(-$10,a6)
	andi.w	#$F000,(-$10,a6)
	move.w	d0,d1
	andi.w	#$FFF,d1
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,d1
	add.l	d1,d1
	move.l	d1,d0
	add.l	d1,d1
	add.l	d0,d1
	movea.l	#dat_4DF9C,a0
	adda.l	d1,a0
	lea	(-$1C,a6),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	tst.b	(-$1C,a6)
	bne.s	.l334EA
	bra.w	loc_33C20
.l334EA:
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	movea.l	#dat_4EF04,a1
	moveq	#$0,d1
	move.b	($0,a1,d0.l),d1
	move.l	d1,d0
	moveq	#$0,d1
	move.b	(-$1C,a6),d1
	moveq	#$0,d2
	move.b	ram_FF9C7C,d2
	add.l	d2,d1
	cmp.l	d1,d0
	bcc.s	.l3351A
	moveq	#$0,d0
	bra.w	loc_33CA2
.l3351A:
	movea.l	(-$1A,a6),a0
	clr.w	(-$12,a6)
	clr.b	(-$D,a6)
	move.l	a0,(-$C,a6)
	moveq	#$0,d2
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	andi.l	#$8000,d0
	sne	d2
	neg.b	d2
	move.l	#$FFDAAE,d4
	bra.w	loc_33C90
loc_33546:
	movea.l	(-$C,a6),a2
	move.l	(a2),(-$4,a6)
	move.l	d3,-(sp)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	jsr	sub_33DB6
	move.l	d0,d5
	movea.l	(-$4,a6),a2
	move.w	(a2),d0
	addq.l	#8,sp
	cmpi.w	#$1,d0
	bcs.w	loc_33C88
	cmpi.w	#$B,d0
	bhi.w	loc_33C88
	add.w	d0,d0
	move.w	(.l3357E+2,pc,d0.w),d0
.l3357E:
	jmp	(.l33582,pc,d0.w)
.l33582:
	dc.w	sub_33598-.l33582
	dc.w	loc_33C88-.l33582
	dc.w	sub_337A2-.l33582
	dc.w	sub_33836-.l33582
	dc.w	sub_33880-.l33582
	dc.w	sub_337EC-.l33582
	dc.w	sub_338CA-.l33582
	dc.w	sub_339BE-.l33582
	dc.w	sub_33AA2-.l33582
	dc.w	sub_33B90-.l33582
	dc.w	sub_33C12-.l33582
sub_33598:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l335AA
	bra.w	loc_33C20
.l335AA:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a5
	move.l	($8,a5),(-$8,a6)
	movea.l	d5,a5
	movea.l	($C,a5),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$B.w
	movea.l	d6,a5
	jsr	(a5)
	move.l	d0,($12,a4)
	movea.l	(-$4,a6),a5
	move.w	($2,a5),(-$12,a6)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a5
	move.w	(a5),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a4,-(sp)
	jsr	sub_33DFA
	movea.l	a4,a0
	subi.w	#$460,(-$12,a6)
	movea.l	(-$4,a6),a5
	move.b	($8,a5),(-$13,a6)
	clr.w	(-$16,a6)
	lea	($8,a0),a2
	lea	($34,sp),sp
	bra.w	.l3371C
.l33634:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l33646
	bra.w	.l3372A
.l33646:
	move.l	a4,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2E7C4
	tst.w	(-$12,a6)
	addq.l	#8,sp
	blt.s	.l33660
	move.w	(-$12,a6),d1
	ext.l	d1
	bra.s	.l33668
.l33660:
	move.w	(-$12,a6),d1
	ext.l	d1
	neg.l	d1
.l33668:
	movea.l	(-$8,a6),a0
	move.w	($6,a0),d0
	ext.l	d0
	cmp.l	d1,d0
	bge.s	.l336AA
	movea.l	(-$8,a6),a0
	move.w	(-$12,a6),d1
	add.w	($6,a0),d1
	move.w	d1,(-$12,a6)
	movea.l	d5,a0
	move.l	($4,a0),d5
	movea.l	d5,a0
	move.l	($8,a0),(-$8,a6)
	movea.l	(-$8,a6),a0
	move.w	(-$12,a6),d1
	add.w	($6,a0),d1
	move.w	d1,(-$12,a6)
	movea.l	d5,a0
	movea.l	($C,a0),a3
.l336AA:
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$C.w
	movea.l	d6,a5
	jsr	(a5)
	move.l	d0,($12,a4)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	pea	$2.w
	move.w	(-$12,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a4,-(sp)
	jsr	sub_33DFA
	pea	($8,a4)
	move.l	a2,-(sp)
	jsr	sub_2E7C4
	tst.l	d2
	lea	($34,sp),sp
	beq.s	.l3370C
	clr.b	($68,a4)
	move.w	#$1000,($76,a4)
	bra.s	.l33712
.l3370C:
	move.b	#$1,($68,a4)
.l33712:
	subi.w	#$460,(-$12,a6)
	addq.w	#1,(-$16,a6)
.l3371C:
	moveq	#$0,d0
	move.b	(-$13,a6),d0
	cmp.w	(-$16,a6),d0
	bhi.w	.l33634
.l3372A:
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$D.w
	movea.l	d6,a2
	jsr	(a2)
	move.l	d0,($16,a4)
	movea.l	($16,a4),a1
	move.w	#$FCB0,($36,a1)
	movea.l	($16,a4),a1
	pea	($14,a1)
	movea.l	($12,a4),a0
	pea	($14,a0)
	jsr	sub_22DD6
	movea.l	($16,a4),a1
	movea.l	($12,a4),a0
	move.l	($8,a0),($8,a1)
	movea.l	($16,a4),a1
	movea.l	($12,a4),a0
	move.l	($C,a0),($C,a1)
	movea.l	($16,a4),a1
	movea.l	($12,a4),a0
	move.l	($10,a0),($10,a1)
	movea.l	($16,a4),a1
	bset	#$6,($38,a1)
	lea	($1C,sp),sp
	bra.w	loc_33C88
sub_337A2:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l337B4
	bra.w	loc_33C20
.l337B4:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a2
	move.l	($8,a2),(-$8,a6)
	movea.l	d5,a2
	movea.l	($C,a2),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$14.w
	bra.w	loc_33C5A
sub_337EC:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l337FE
	bra.w	loc_33C20
.l337FE:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a2
	move.l	($8,a2),(-$8,a6)
	movea.l	d5,a2
	movea.l	($C,a2),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$21.w
	bra.w	loc_33C5A
sub_33836:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l33848
	bra.w	loc_33C20
.l33848:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a2
	move.l	($8,a2),(-$8,a6)
	movea.l	d5,a2
	movea.l	($C,a2),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$19.w
	bra.w	loc_33C5A
sub_33880:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	.l33892
	bra.w	loc_33C20
.l33892:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a2
	move.l	($8,a2),(-$8,a6)
	movea.l	d5,a2
	movea.l	($C,a2),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$13.w
	bra.w	loc_33C5A
sub_338CA:
	jsr	sub_2E95A
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l338DC
	bra.w	loc_33C20
.l338DC:
	move.l	a2,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a4
	move.l	($8,a4),(-$8,a6)
	movea.l	d5,a4
	movea.l	($C,a4),a3
	move.l	d5,($1A,a2)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$9F.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($12,a2)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a4
	move.w	(a4),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a2,-(sp)
	jsr	sub_33DFA
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$A0.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($16,a2)
	movea.l	($16,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$A1.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($28,a2)
	movea.l	($28,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	clr.w	($2C,a2)
	move.w	#$DC72,($2E,a2)
	clr.w	($20,a2)
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.l	d0,d1
	movea.l	#dat_4EEFC,a1
	moveq	#$0,d0
	move.b	($0,a1,d1.l),d0
	move.w	d0,($32,a2)
	lea	($5C,sp),sp
	bra.w	loc_33C88
sub_339BE:
	jsr	sub_2E95A
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l339D0
	bra.w	loc_33C20
.l339D0:
	move.l	a2,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a4
	move.l	($8,a4),(-$8,a6)
	movea.l	d5,a4
	movea.l	($C,a4),a3
	move.l	d5,($1A,a2)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$AD.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($12,a2)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a4
	move.w	(a4),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a2,-(sp)
	jsr	sub_33DFA
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$AF.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($16,a2)
	movea.l	($16,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$AE.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($28,a2)
	movea.l	($28,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	clr.w	($2C,a2)
	clr.w	($2E,a2)
	pea	$28.w
	jsr	queue_sound_command
	clr.l	ram_FFDCBC
	lea	($60,sp),sp
	bra.w	loc_33C88
sub_33AA2:
	jsr	sub_2E95A
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l33AB4
	bra.w	loc_33C20
.l33AB4:
	move.l	a2,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a4
	move.l	($8,a4),(-$8,a6)
	movea.l	d5,a4
	movea.l	($C,a4),a3
	move.l	d5,($1A,a2)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$B7.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($12,a2)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a4
	move.w	(a4),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a2,-(sp)
	jsr	sub_33DFA
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$B8.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($16,a2)
	movea.l	($16,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$19.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($28,a2)
	move.l	#$FFFFFDC0,-(sp)
	move.l	($28,a2),-(sp)
	jsr	sub_2D110
	movea.l	($28,a2),a1
	movea.l	($12,a2),a0
	move.w	($36,a0),($36,a1)
	clr.w	($2C,a2)
	clr.w	($2E,a2)
	pea	$26.w
	jsr	queue_sound_command
	lea	($68,sp),sp
	bra.w	loc_33C88
sub_33B90:
	jsr	sub_2E95A
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l33BA2
	bra.w	loc_33C20
.l33BA2:
	move.l	a2,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a4
	move.l	($8,a4),(-$8,a6)
	movea.l	d5,a4
	movea.l	($C,a4),a3
	move.l	d5,($1A,a2)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$C1.w
	movea.l	d6,a4
	jsr	(a4)
	move.l	d0,($12,a2)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a4
	move.w	(a4),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a2,-(sp)
	jsr	sub_33DFA
	move.b	#$5,($69,a2)
	moveq	#$0,d0
	move.l	d0,($16,a2)
	move.l	d0,($28,a2)
	bra.s	loc_33C84
sub_33C12:
	jsr	sub_2E95A
	movea.l	d0,a4
	cmpa.w	#$0,a4
	bne.s	loc_33C26
loc_33C20:
	moveq	#$0,d0
	bra.w	loc_33CA2
loc_33C26:
	move.l	a4,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	movea.l	d5,a2
	move.l	($8,a2),(-$8,a6)
	movea.l	d5,a2
	movea.l	($C,a2),a3
	move.l	d5,($1A,a4)
	pea	($14,a3)
	move.l	($10,a3),-(sp)
	move.l	($C,a3),-(sp)
	move.l	($8,a3),-(sp)
	pea	$F4.w
loc_33C5A:
	movea.l	d6,a2
	jsr	(a2)
	move.l	d0,($12,a4)
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	movea.l	(-$4,a6),a2
	move.w	(a2),d1
	move.l	d1,-(sp)
	clr.l	-(sp)
	move.l	d5,-(sp)
	move.l	(-$4,a6),-(sp)
	move.l	a4,-(sp)
	jsr	sub_33DFA
loc_33C84:
	lea	($34,sp),sp
loc_33C88:
	addq.b	#1,(-$D,a6)
	addq.l	#4,(-$C,a6)
loc_33C90:
	movea.l	(-$C,a6),a0
	tst.l	(a0)
	bne.w	loc_33546
	move.b	#$1,ram_FFDC1C
loc_33CA2:
	movem.l	(-$40,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_33CAC:
	link	a6,#$FFF8
	movem.l	d2-d4/a2-a4,-(sp)
	move.w	($A,a6),d1
	movea.l	($C,a6),a2
	move.w	($12,a6),d2
	move.w	#$1000,d4
	moveq	#$0,d0
	move.w	d1,d0
	add.l	d0,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	movea.l	#dat_4DF9C,a1
	adda.l	d0,a1
	lea	(-$6,a6),a0
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	tst.b	(-$6,a6)
	bne.s	.l33CF4
	jsr	soft_reset
.l33CF4:
	moveq	#$0,d1
	move.b	ram_FFDE72,d1
	movea.l	#dat_4EF04,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.l),d0
	moveq	#$0,d1
	move.b	(-$6,a6),d1
	move.l	d1,d3
	moveq	#$0,d1
	move.b	ram_FF9C7C,d1
	add.l	d1,d3
	cmp.l	d3,d0
	bcc.s	.l33D26
	moveq	#$0,d0
	movea.l	d0,a3
	bra.w	.l33DAA
.l33D26:
	move.l	(-$4,a6),d0
	movea.l	d0,a0
	movea.l	(a0),a4
	cmpi.w	#$4,(a4)
	beq.s	.l33D3A
	jsr	soft_reset
.l33D3A:
	jsr	sub_2E95A
	movea.l	d0,a3
	cmpa.w	#$0,a3
	bne.s	.l33D4E
	moveq	#$0,d0
	movea.l	d0,a3
	bra.s	.l33DAA
.l33D4E:
	move.l	a3,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	move.l	($8,a2),d0
	movea.l	($C,a2),a0
	move.l	a2,($1A,a3)
	pea	($14,a0)
	move.l	($10,a0),-(sp)
	move.l	($C,a0),-(sp)
	move.l	($8,a0),-(sp)
	pea	$19.w
	jsr	sub_2EF4C
	move.l	d0,($12,a3)
	moveq	#$0,d1
	move.w	d4,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(a4),d0
	move.l	d0,-(sp)
	ext.l	d2
	move.l	d2,-(sp)
	move.l	a2,-(sp)
	move.l	a4,-(sp)
	move.l	a3,-(sp)
	jsr	sub_33DFA
	move.b	#$1,ram_FFDC1C
.l33DAA:
	move.l	a3,d0
	movem.l	(-$20,a6),d2-d4/a2-a4
	unlk	a6
	rts
sub_33DB6:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.w	($A,a6),d2
	move.l	($C,a6),d1
	moveq	#$0,d0
	move.w	d2,d0
	andi.l	#$8000,d0
	beq.s	.l33DDA
	move.l	ram_FFDBEE,d0
	bra.s	.l33DF0
.l33DDA:
	tst.l	d1
	beq.s	.l33DE6
	movea.l	ram_FFDBFA,a0
	bra.s	.l33DEC
.l33DE6:
	movea.l	ram_FFDBF2,a0
.l33DEC:
	move.l	($4,a0),d0
.l33DF0:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_33DFA:
	link	a6,#$0
	movem.l	d2/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	movea.l	($10,a6),a4
	tst.w	($16,a6)
	beq.s	.l33E1C
	move.w	($16,a6),($22,a2)
	bra.s	.l33E22
.l33E1C:
	move.w	($2,a3),($22,a2)
.l33E22:
	moveq	#$0,d0
	move.b	($1B,a6),d0
	move.w	d0,($10,a2)
	clr.l	($16,a2)
	lea	($8,a2),a0
	move.l	a0,($8,a2)
	lea	($8,a2),a0
	move.l	a0,($C,a2)
	moveq	#$0,d1
	move.w	($1E,a6),d1
	move.l	d1,-(sp)
	move.l	a3,-(sp)
	move.l	a2,-(sp)
	jsr	sub_33F9C
	move.w	($22,a2),d2
	ext.l	d2
	move.l	d2,-(sp)
	move.l	($12,a2),-(sp)
	jsr	sub_2D0AE
	movea.l	($12,a2),a0
	bset	#$6,($38,a0)
	clr.w	($24,a2)
	clr.w	($20,a2)
	clr.w	($2C,a2)
	cmpi.w	#$3,($10,a2)
	bne.s	.l33E8E
	btst	#$2,($67,a2)
	beq.s	.l33E8E
	moveq	#$1,d0
	bra.s	.l33E90
.l33E8E:
	moveq	#$0,d0
.l33E90:
	tst.l	d0
	beq.s	.l33EB6
	move.w	($26,a2),d0
	ext.l	d0
	asl.l	#8,d0
	asl.l	#5,d0
	moveq	#$0,d1
	move.w	($4,a3),d1
	move.w	ram_FFDD18,d2
	ext.l	d2
	add.l	d2,d1
	add.l	d1,d0
	move.w	d0,($30,a2)
	bra.s	.l33EBC
.l33EB6:
	move.w	($4,a3),($30,a2)
.l33EBC:
	move.w	($4,a3),($34,a2)
	moveq	#$0,d0
	move.w	($1E,a6),d0
	move.l	d0,d2
	andi.l	#$7000,d2
	cmpi.l	#$4000,d2
	bne.w	.l33F4A
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	add.w	d0,d0
	movea.l	#dat_4D694,a0
	moveq	#$0,d1
	move.w	($0,a0,d0.w),d1
	move.l	d1,d0
	moveq	#$0,d1
	move.w	($4,a3),d1
	add.l	d1,d0
	move.w	d0,($2E,a2)
	cmpi.w	#$3,($10,a2)
	bne.s	.l33F12
	btst	#$2,($67,a2)
	beq.s	.l33F12
	moveq	#$1,d0
	bra.s	.l33F14
.l33F12:
	moveq	#$0,d0
.l33F14:
	tst.l	d0
	bne.s	.l33F48
	moveq	#$0,d0
	move.w	($2E,a2),d0
	move.l	d0,d2
	moveq	#$0,d0
	move.b	ram_FFDE72,d0
	move.w	d0,d1
	add.w	d1,d1
	movea.l	#dat_4D694,a0
	moveq	#$0,d0
	move.w	($0,a0,d1.w),d0
	lsl.l	#1,d0
	move.l	d0,-(sp)
	jsr	sub_23FBA
	sub.l	d0,d2
	move.w	d2,($30,a2)
.l33F48:
	bra.s	.l33F50
.l33F4A:
	move.w	($4,a3),($2E,a2)
.l33F50:
	clr.w	($3C,a2)
	clr.b	($66,a2)
	clr.b	($69,a2)
	clr.b	($6A,a2)
	clr.b	($6B,a2)
	clr.w	($6C,a2)
	clr.l	($6E,a2)
	clr.w	($72,a2)
	clr.w	($74,a2)
	cmpi.b	#$9,($1B,a6)
	bne.s	.l33F86
	clr.w	($20,a2)
	move.w	#$C80,($72,a2)
.l33F86:
	move.l	($8,a4),-(sp)
	move.l	a2,-(sp)
	jsr	sub_35230
	movem.l	(-$10,a6),d2/a2-a4
	unlk	a6
	rts
sub_33F9C:
	link	a6,#$0
	movem.l	a2-a3,-(sp)
	movea.l	($8,a6),a0
	movea.l	($C,a6),a2
	move.w	($12,a6),d1
	movea.l	#ram_FFDD16,a3
	move.b	#$8,($67,a0)
	clr.w	($26,a0)
	move.w	d1,($76,a0)
	moveq	#$0,d0
	move.w	d1,d0
	andi.l	#$8000,d0
	beq.s	.l33FDC
	clr.b	($68,a0)
	move.w	#$1000,($76,a0)
	bra.s	.l33FE2
.l33FDC:
	move.b	#$1,($68,a0)
.l33FE2:
	move.w	($10,a0),d0
	cmpi.w	#$B,d0
	bhi.w	loc_34368
	add.w	d0,d0
	move.w	(.l33FF8,pc,d0.w),d0
	jmp	(.l33FF8,pc,d0.w)
.l33FF8:
	dc.w	sub_34010-.l33FF8
	dc.w	sub_34010-.l33FF8
	dc.w	sub_34010-.l33FF8
	dc.w	sub_34062-.l33FF8
	dc.w	sub_340FA-.l33FF8
	dc.w	sub_3414C-.l33FF8
	dc.w	sub_3419C-.l33FF8
	dc.w	sub_341EE-.l33FF8
	dc.w	sub_34236-.l33FF8
	dc.w	sub_34292-.l33FF8
	dc.w	sub_342DA-.l33FF8
	dc.w	sub_34320-.l33FF8
	assert	*=$034010,"game/code_030012.asm does not end at 034010"
