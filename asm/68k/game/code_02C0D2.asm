; game/code_02C0D2.asm, 02C0D2-030012: game program code (pair S) with the data,
; text and tables that lie between its routines; the first routine is init_coprocessors. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 02C0D2 030012 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$02C0D2,"game/code_02C0D2.asm misplaced"
init_coprocessors:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	movea.l	#sub_23898,a2
	clr.w	ram_FF9BB6
	clr.w	ram_FF9BB8
	move.w	#$3,ram_FF9BBA
	move.l	$FFFF8014,ram_FFDCC0
	clr.l	ram_FFDB4A
	clr.w	WATCHDOG
	move.w	#$64,ram_FF9BCA
	clr.l	$FFFF8014
	jsr	init_gsp
	clr.w	WATCHDOG
	jsr	clear_gsp_screen
	clr.w	WATCHDOG
	pea	str_4762E
	pea	$FF.w
	pea	$20.w
	pea	$40.w
	jsr	(a2)
	jsr	reset_sound
	clr.w	WATCHDOG
	pea	str_4763A
	pea	$FF.w
	pea	$30.w
	pea	$40.w
	jsr	(a2)
	jsr	sub_2D7C2
	jsr	sub_23E06
	clr.w	WATCHDOG
	jsr	stop_adsp
	clr.w	WATCHDOG
	pea	$2000.w
	jsr	set_sr
	pea	str_47652
	pea	$FF.w
	pea	$80.w
	pea	$40.w
	jsr	(a2)
	btst	#$6,PORT0
	lea	($34,sp),sp
	beq.s	.l2C1B6
	jsr	download_gsp_program
	bra.s	.l2C1C4
.l2C1B6:
	move.l	gsp_program_ptr,-(sp)
	jsr	load_gsp_program
	addq.l	#4,sp
.l2C1C4:
	move.w	#$7800,GSP_HOST+$8
	move.w	#$3800,GSP_HOST+$8
	clr.w	WATCHDOG
	pea	str_47662
	pea	$FF.w
	pea	$100.w
	pea	$40.w
	jsr	(a2)
	btst	#$4,PORT0
	lea	($10,sp),sp
	beq.s	.l2C204
	jsr	download_adsp_program
	bra.s	.l2C212
.l2C204:
	move.l	adsp_program_ptr,-(sp)
	jsr	load_adsp_program
	addq.l	#4,sp
.l2C212:
	move.l	#$2060,d3
	moveq	#$D,d2
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_CONTROL+$8
	clr.w	ADSP_CONTROL+$A
	move.w	#$FFFF,ADSP_DRAM+$3FFE
	clr.w	ADSP_IRQ_CLEAR
	clr.w	ram_FF9BB4
	move.w	#$1,ram_FF9BC8
	clr.w	ADSP_CONTROL+$14
	clr.w	ADSP_CONTROL+$16
	move.w	#$1,ram_FF9BB2
	clr.w	ADSP_CONTROL+$1E
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1C
	pea	ram_FFDB04
	pea	dat_47D34
	jsr	sub_22DD6
	clr.l	ram_FFDAF8
	move.l	#$FFFFFA60,ram_FFDAFC
	clr.l	ram_FFDB00
	jsr	sub_2ED1A
	clr.w	d0
	move.w	d0,ram_FFDD16
	move.w	d0,ram_FFDD1C
	clr.b	ram_FF9C7C
	jsr	sub_2F126
	jsr	sub_2D706
	pea	dat_44630
	jsr	sub_2F6BE
	pea	dat_4769A
	pea	$100.w
	clr.l	-(sp)
	pea	$1.w
	jsr	sub_2F6E6
	pea	dat_4789A
	pea	$100.w
	clr.l	-(sp)
	pea	$2.w
	jsr	sub_2F6E6
	pea	dat_47A9A
	pea	$100.w
	clr.l	-(sp)
	pea	$3.w
	jsr	sub_2F6E6
	move.l	#$FFF23F00,-(sp)
	pea	$1.w
	jsr	sub_2F742
	move.l	#$FFE00000,-(sp)
	pea	$2.w
	jsr	sub_2F742
	moveq	#$3,d4
	move.l	#$FFF2B760,d5
	lea	($4C,sp),sp
	bra.s	.l2C352
.l2C33E:
	move.l	d5,-(sp)
	moveq	#$0,d0
	move.b	d4,d0
	move.l	d0,-(sp)
	jsr	sub_2F742
	add.l	d3,d5
	addq.l	#8,sp
	addq.b	#1,d4
.l2C352:
	moveq	#$0,d0
	move.b	d4,d0
	cmp.l	d2,d0
	bcs.s	.l2C33E
	move.l	#$FFFFFFFF,-(sp)
	jsr	sub_2F1BE
	addq.l	#4,sp
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
sub_2C372:
	link	a6,#$0
	movem.l	d2-d5/a2-a4,-(sp)
	movea.l	#ram_FF9BC6,a4
	clr.w	WATCHDOG
	tst.w	ram_FF9BC8
	bne.w	.l2C416
	moveq	#$5,d2
	move.l	#$186A0,d4
	moveq	#$B,d3
	movea.l	#WATCHDOG,a3
	move.l	$FFFF8014,ram_FF9BA6
	moveq	#$0,d5
	movea.l	#ram_FF9BB4,a2
	bra.s	.l2C3D6
.l2C3B4:
	move.l	d2,-(sp)
	jsr	sub_22766
	cmp.l	d4,d5
	addq.l	#4,sp
	ble.s	.l2C3D2
	move.l	d3,-(sp)
	jsr	sub_30830
	jsr	soft_reset
	addq.l	#4,sp
.l2C3D2:
	clr.w	(a3)
	addq.l	#1,d5
.l2C3D6:
	tst.w	(a2)
	beq.s	.l2C3B4
	move.l	$FFFF8014,d0
	sub.l	ram_FF9BA6,d0
	move.l	d0,ram_FF9BA6
	clr.w	ram_FF9BB4
	tst.w	ram_FF9BB2
	beq.s	.l2C408
	clr.w	ADSP_CONTROL+$6
	clr.w	ram_FF9BB2
	bra.s	.l2C416
.l2C408:
	clr.w	ADSP_CONTROL+$16
	move.w	#$1,ram_FF9BB2
.l2C416:
	tst.b	ram_FFDC1C
	bne.s	.l2C432
	clr.w	SOUND_RESET+$10
.l2C424:
	jsr	sub_2E064
	clr.w	ADSP_CONTROL
	bra.s	.l2C44A
.l2C432:
	clr.w	SOUND_RESET+$10
	jsr	build_object_list
	clr.w	ADSP_CONTROL
	clr.b	ram_FFDC1C
.l2C44A:
	tst.w	ram_FF9BC8
	bne.w	loc_2C608
	jsr	sub_2F126
	jsr	sub_2D706
	jsr	sub_2C7EA
	move.w	ram_FF9550,d0
	cmpi.w	#$1B,d0
	bcs.s	.l2C4AA
	bhi.s	.l2C476
	bra.s	.l2C4A8
.l2C476:
	cmpi.w	#$32,d0
	bcs.s	.l2C4AA
	cmpi.w	#$3F,d0
	bhi.s	.l2C4AA
	add.w	d0,d0
	move.w	(.l2C424+4,pc,d0.w),d0
	jmp	(.l2C48C,pc,d0.w)
.l2C48C:
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4A8-.l2C48C
	dc.w	.l2C4AA-.l2C48C
	dc.w	.l2C4A8-.l2C48C
.l2C4A8:
	bra.s	.l2C4C0
.l2C4AA:
	addq.b	#3,ram_FF9BC4
	cmpi.b	#$15,ram_FF9BC4
	bls.s	.l2C4C0
	clr.b	ram_FF9BC4
.l2C4C0:
	moveq	#$0,d0
	move.b	ram_FF9BC4,d0
	movea.l	#dat_47C9A,a0
	pea	($0,a0,d0.w)
	pea	$1.w
	pea	$1D.w
	jsr	sub_2F610
	cmpi.w	#$23,ram_FF9550
	lea	($C,sp),sp
	bne.s	.l2C51C
	addq.b	#3,(a4)
	cmpi.b	#$1E,(a4)
	bcs.s	.l2C4F8
	clr.b	(a4)
.l2C4F8:
	moveq	#$0,d0
	move.b	(a4),d0
	movea.l	#dat_47CB2,a0
	pea	($0,a0,d0.w)
	pea	$A.w
	pea	$F5.w
	jsr	sub_2F610
	lea	($C,sp),sp
	bra.w	loc_2C5D0
.l2C51C:
	move.w	ram_FF9BCE,d0
	cmpi.w	#$4,d0
	blt.w	loc_2C596
	cmpi.w	#$9,d0
	bgt.s	loc_2C596
	add.w	d0,d0
.l2C532:
	move.w	(.l2C532,pc,d0.w),d0
	jmp	(.l2C53A,pc,d0.w)
.l2C53A:
	dc.w	sub_2C546-.l2C53A
	dc.w	sub_2C546-.l2C53A
	dc.w	loc_2C596-.l2C53A
	dc.w	loc_2C596-.l2C53A
	dc.w	sub_2C546-.l2C53A
	dc.w	sub_2C546-.l2C53A
sub_2C546:
	addq.b	#3,(a4)
	cmpi.b	#$F,(a4)
	bcs.s	.l2C550
	clr.b	(a4)
.l2C550:
	moveq	#$0,d0
	move.b	(a4),d0
	movea.l	#dat_47CEE,a0
	pea	($0,a0,d0.w)
	pea	$5.w
	pea	$6.w
	jsr	sub_2F610
	moveq	#$0,d0
	move.b	(a4),d0
	movea.l	#dat_47D0C,a0
	pea	($0,a0,d0.w)
	pea	$5.w
	pea	$B.w
	jsr	sub_2F610
	move.b	#$1,ram_FF9BBE
	lea	($18,sp),sp
	bra.s	loc_2C5D0
loc_2C596:
	tst.b	ram_FF9BBE
	beq.s	loc_2C5D0
	pea	dat_44642
	pea	$5.w
	pea	$6.w
	jsr	sub_2F610
	pea	dat_44651
	pea	$5.w
	pea	$B.w
	jsr	sub_2F610
	clr.b	ram_FF9BBE
	lea	($18,sp),sp
loc_2C5D0:
	pea	$F7.w
	pea	$1FF.w
	pea	$28.w
	clr.l	-(sp)
	jsr	sub_2F796
	jsr	sub_2C686
	move.l	#$810000,-(sp)
	jsr	sub_2F0AE
	tst.w	dat_48DE4
	lea	($14,sp),sp
	beq.s	loc_2C608
	jsr	sub_2C85A
loc_2C608:
	clr.w	ADSP_CONTROL+$2
	movem.l	(-$1C,a6),d2-d5/a2-a4
	unlk	a6
	rts
sub_2C618:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FF9BC4,a2
	clr.w	WATCHDOG
	jsr	sub_2F126
	jsr	sub_2D706
	tst.w	ram_FF9550
	beq.s	.l2C670
	cmpi.w	#$3B,ram_FF9550
	beq.s	.l2C670
	addq.b	#3,(a2)
	cmpi.b	#$15,(a2)
	bls.s	.l2C654
	clr.b	(a2)
.l2C654:
	moveq	#$0,d0
	move.b	(a2),d0
	movea.l	#dat_47C9A,a0
	pea	($0,a0,d0.w)
	pea	$1.w
	pea	$1D.w
	jsr	sub_2F610
.l2C670:
	jsr	sub_2C7EA
	clr.w	ADSP_CONTROL+$2
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2C686:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	movea.l	#ram_FF9BD8,a2
	tst.b	ram_FF9BC0
	beq.w	.l2C7E0
	move.w	ram_FFDBD4,d3
	ext.l	d3
	addi.l	#$A0,d3
	cmpi.l	#$F8,d3
	bge.s	.l2C6D4
	pea	$F0.w
	move.l	#$F8,d0
	sub.l	d3,d0
	move.l	d0,-(sp)
	pea	$200.w
	move.l	d3,-(sp)
	clr.l	-(sp)
	jsr	sub_2F674
	lea	($14,sp),sp
.l2C6D4:
	move.w	ram_FFDBDA,d2
	ext.l	d2
	movea.l	(a2),a0
	move.w	($1E,a0),d0
	ext.l	d0
	cmp.l	d2,d0
	bge.s	.l2C704
.l2C6E8:
	movea.l	(a2),a0
	move.w	($1E,a0),d0
	ext.l	d0
	cmp.l	d2,d0
	bge.s	.l2C702
	movea.l	(a2),a0
	moveq	#$0,d0
	move.w	(a0),d0
	asl.l	#8,d0
	asl.l	#1,d0
	sub.l	d0,d2
	bra.s	.l2C6E8
.l2C702:
	bra.s	.l2C74C
.l2C704:
	movea.l	(a2),a0
	movea.l	(a2),a1
	moveq	#$0,d0
	move.w	(a1),d0
	subq.l	#1,d0
	add.w	d0,d0
	move.w	($1E,a0,d0.w),d0
	ext.l	d0
	subi.l	#$200,d0
	cmp.l	d0,d2
	bge.s	.l2C74C
	move.l	#$200,d1
.l2C726:
	movea.l	(a2),a0
	movea.l	(a2),a1
	moveq	#$0,d0
	move.w	(a1),d0
	subq.l	#1,d0
	add.w	d0,d0
	move.w	($1E,a0,d0.w),d0
	ext.l	d0
	sub.l	d1,d0
	cmp.l	d0,d2
	bge.s	.l2C74C
	movea.l	(a2),a0
	moveq	#$0,d0
	move.w	(a0),d0
	asl.l	#8,d0
	asl.l	#1,d0
	add.l	d0,d2
	bra.s	.l2C726
.l2C74C:
	move.l	#$200,d1
	moveq	#$0,d4
	bra.s	.l2C758
.l2C756:
	addq.l	#1,d4
.l2C758:
	movea.l	(a2),a0
	move.w	d4,d0
	add.w	d0,d0
	move.w	($1E,a0,d0.w),d0
	ext.l	d0
	sub.l	d1,d0
	cmp.l	d0,d2
	blt.s	.l2C756
	movea.l	(a2),a0
	move.w	d4,d0
	add.w	d0,d0
	move.w	($1E,a0,d0.w),d0
	ext.l	d0
	sub.l	d0,d2
	move.l	d3,d1
	movea.l	(a2),a0
	move.w	d4,d0
	add.w	d0,d0
	move.w	($2C,a0,d0.w),d0
	ext.l	d0
	sub.l	d0,d1
	movea.l	(a2),a0
	move.w	d4,d0
	asl.w	#2,d0
	move.l	($2,a0,d0.w),-(sp)
	clr.l	-(sp)
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	jsr	sub_2F7D6
	addq.l	#1,d4
	movea.l	(a2),a0
	moveq	#$0,d0
	move.w	(a0),d0
	cmp.l	d4,d0
	lea	($10,sp),sp
	bhi.s	.l2C7B0
	moveq	#$0,d4
.l2C7B0:
	addi.l	#$200,d2
	move.l	d3,d1
	movea.l	(a2),a0
	move.w	d4,d0
	add.w	d0,d0
	move.w	($2C,a0,d0.w),d0
	ext.l	d0
	sub.l	d0,d1
	movea.l	(a2),a0
	move.w	d4,d0
	asl.w	#2,d0
	move.l	($2,a0,d0.w),-(sp)
	clr.l	-(sp)
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	jsr	sub_2F7D6
	lea	($10,sp),sp
.l2C7E0:
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
sub_2C7EA:
	link	a6,#$0
	tst.b	ram_FF9BC2
	beq.s	.l2C808
	move.l	ram_FF9BAE,-(sp)
	pea	$28.w
	move.l	#$FFE00000,-(sp)
	bra.s	.l2C814
.l2C808:
	move.l	ram_FF9BAE,-(sp)
	pea	$28.w
	clr.l	-(sp)
.l2C814:
	clr.l	-(sp)
	jsr	sub_2F88A
	unlk	a6
	rts
sub_2C820:
	link	a6,#$0
	tst.w	ram_FF9BC8
	bne.s	.l2C838
	move.l	#$FFFFFFFF,-(sp)
	jsr	sub_2F1BE
.l2C838:
	clr.w	ram_FF9BC8
	unlk	a6
	rts
dat_2C842:
	incbin	"../../build/stunrun-68k.bin",$2C842,$18
sub_2C85A:
	link	a6,#$FFE8
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	#$809400,d3
	moveq	#$30,d2
	movea.l	ram_FFDA96,a2
	move.l	#$FFDAF8,d6
	move.l	#$FFDB04,d5
	move.l	#$FFDA96,d4
	bra.w	.l2C8F0
.l2C886:
	move.l	($2A,a2),d0
	sub.l	d3,d0
	move.l	d2,d1
	jsr	sub_23E70
	movea.w	d0,a3
	pea	(-$4,a6)
	move.l	d5,-(sp)
	move.l	d6,-(sp)
	pea	($8,a2)
	jsr	sub_2C8FE
	tst.l	d0
	lea	($10,sp),sp
	beq.s	.l2C8EE
	move.w	a3,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_47674
	pea	(-$18,a6)
	jsr	sub_30220
	clr.l	-(sp)
	pea	$17.w
	move.w	(-$2,a6),d0
	ext.l	d0
	subq.l	#4,d0
	move.l	d0,-(sp)
	move.w	(-$4,a6),d0
	ext.l	d0
	subq.l	#4,d0
	move.l	d0,-(sp)
	pea	(-$18,a6)
	jsr	sub_2F2CC
	lea	($20,sp),sp
.l2C8EE:
	movea.l	(a2),a2
.l2C8F0:
	cmpa.l	d4,a2
	bne.s	.l2C886
	movem.l	(-$34,a6),d2-d6/a2-a3
	unlk	a6
	rts
sub_2C8FE:
	link	a6,#$FFE8
	movem.l	a2,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a2
	move.l	($10,a6),d1
	move.l	(a1),d0
	sub.l	(a2),d0
	move.l	d0,(-$C,a6)
	movea.l	a1,a0
	addq.l	#4,a0
	move.l	(a0),d0
	movea.l	a2,a0
	addq.l	#4,a0
	sub.l	(a0),d0
	move.l	d0,(-$8,a6)
	movea.l	a1,a0
	addq.l	#8,a0
	move.l	(a0),d0
	movea.l	a2,a0
	addq.l	#8,a0
	sub.l	(a0),d0
	move.l	d0,(-$4,a6)
	move.l	d1,-(sp)
	pea	(-$18,a6)
	pea	(-$C,a6)
	jsr	sub_22A36
	tst.l	(-$10,a6)
	bge.s	.l2C954
	moveq	#$0,d0
	bra.s	.l2C964
.l2C954:
	move.l	($14,a6),-(sp)
	pea	(-$18,a6)
	jsr	sub_2C96E
	moveq	#$1,d0
.l2C964:
	movem.l	(-$1C,a6),a2
	unlk	a6
	rts
sub_2C96E:
	link	a6,#$0
	movem.l	d2-d3/a2-a3,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a2
	movea.l	a1,a0
	addq.l	#8,a0
	tst.l	(a0)
	ble.s	.l2C9DA
	move.l	#$7FFF,d3
	movea.l	a1,a0
	addq.l	#8,a0
	move.l	(a0),d2
	moveq	#$9,d0
	bra.s	.l2C99E
.l2C996:
	move.l	d2,d1
	asr.l	#1,d1
	move.l	d1,d2
	subq.l	#1,d0
.l2C99E:
	cmp.l	d3,d2
	bgt.s	.l2C996
	move.l	(a1),d3
	move.b	d0,d1
	asl.l	d1,d3
	move.l	d3,d1
	divs.w	d2,d1
	ext.l	d1
	addi.l	#$100,d1
	move.w	d1,(a2)
	movea.l	a2,a0
	addq.l	#2,a0
	move.w	#$100,d3
	addq.l	#4,a1
	move.l	(a1),d1
	asl.l	d0,d1
	move.l	d1,d0
	divs.w	d2,d0
	sub.w	d0,d3
	move.w	d3,d1
	ext.l	d1
	muls.w	dat_48E2E,d1
	moveq	#$9,d0
	asr.l	d0,d1
	move.w	d1,(a0)
.l2C9DA:
	movem.l	(-$10,a6),d2-d3/a2-a3
	unlk	a6
	rts
dat_2C9E4:
	incbin	"../../build/stunrun-68k.bin",$2C9E4,$60
dat_2CA44:
	incbin	"../../build/stunrun-68k.bin",$2CA44,$294
sub_2CCD8:
	link	a6,#$0
	movem.l	d2-d6/a2-a4,-(sp)
	move.w	($A,a6),d4
	move.w	($E,a6),d5
	movea.l	($10,a6),a2
	movea.l	#sub_229E4,a3
	moveq	#$3,d3
	clr.w	d0
	movea.w	d0,a4
.l2CCF8:
	move.w	d5,d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($4,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	sub.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.l	d0,d2
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($4,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	add.l	d0,d2
	move.w	d2,($4,a2)
	move.w	d6,(a2)
	lea	($20,sp),sp
	addq.w	#1,a4
	addq.l	#6,a2
	move.w	a4,d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l2CCF8
	movem.l	(-$20,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_2CD5C:
	link	a6,#$0
	movem.l	d2-d6/a2-a4,-(sp)
	move.w	($A,a6),d4
	move.w	($E,a6),d5
	movea.l	($10,a6),a2
	movea.l	#sub_229E4,a3
	moveq	#$3,d3
	clr.w	d0
	movea.w	d0,a4
.l2CD7C:
	move.w	d5,d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($4,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	sub.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.l	d0,d2
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($4,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	add.l	d0,d2
	move.w	d2,($4,a2)
	move.w	d6,($2,a2)
	lea	($20,sp),sp
	addq.w	#1,a4
	addq.l	#6,a2
	move.w	a4,d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l2CD7C
	movem.l	(-$20,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_2CDE6:
	link	a6,#$0
	movem.l	d2-d6/a2-a4,-(sp)
	move.w	($A,a6),d4
	move.w	($E,a6),d5
	movea.l	($10,a6),a2
	movea.l	#sub_229E4,a3
	moveq	#$3,d3
	clr.w	d0
	movea.w	d0,a4
.l2CE06:
	move.w	d5,d2
	ext.l	d2
	move.l	d2,-(sp)
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	sub.w	d0,d6
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	move.l	d0,d2
	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($2,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a3)
	add.l	d0,d2
	move.w	d2,($2,a2)
	move.w	d6,(a2)
	lea	($20,sp),sp
	addq.w	#1,a4
	addq.l	#6,a2
	move.w	a4,d2
	ext.l	d2
	cmp.l	d3,d2
	blt.s	.l2CE06
	movem.l	(-$20,a6),d2-d6/a2-a4
	unlk	a6
	rts
dat_2CE6A:
	incbin	"../../build/stunrun-68k.bin",$2CE6A,$62
sub_2CECC:
	link	a6,#$FFEC
	movem.l	a2,-(sp)
	movea.l	($8,a6),a2
	pea	(-$6,a6)
	movea.l	a2,a0
	addq.l	#6,a0
	pea	(a0)
	movea.l	a2,a0
	pea	(a0)
	jsr	sub_2CFBE
	pea	(-$C,a6)
	movea.l	a2,a0
	pea	(a0)
	pea	(-$6,a6)
	jsr	sub_2CFBE
	movea.l	a2,a0
	addq.l	#6,a0
	pea	(a0)
	pea	(-$C,a6)
	jsr	sub_2CF40
	movea.l	a2,a0
	moveq	#$C,d0
	adda.l	d0,a0
	pea	(a0)
	pea	(-$6,a6)
	jsr	sub_2CF40
	movea.l	a2,a0
	pea	(a0)
	movea.l	a2,a0
	moveq	#$C,d0
	adda.l	d0,a0
	pea	(a0)
	addq.l	#6,a2
	pea	(a2)
	jsr	sub_2CFBE
	movem.l	(-$18,a6),a2
	unlk	a6
	rts
sub_2CF40:
	link	a6,#$0
	movem.l	d2/a2-a3,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	movea.l	a2,a0
	addq.l	#4,a0
	move.w	(a0),d0
	ext.l	d0
	movea.l	a2,a0
	addq.l	#4,a0
	muls.w	(a0),d0
	move.l	d0,d2
	movea.l	a2,a0
	addq.l	#2,a0
	move.w	(a0),d0
	ext.l	d0
	movea.l	a2,a0
	addq.l	#2,a0
	muls.w	(a0),d0
	move.w	(a2),d1
	ext.l	d1
	muls.w	(a2),d1
	add.l	d1,d0
	add.l	d0,d2
	move.l	d2,-(sp)
	jsr	sub_30B7E
	move.w	d0,d2
	move.w	(a2),d0
	ext.l	d0
	moveq	#$E,d1
	asl.l	d1,d0
	divs.w	d2,d0
	move.w	d0,(a3)
	movea.l	a3,a0
	addq.l	#2,a0
	movea.l	a2,a1
	addq.l	#2,a1
	move.w	(a1),d0
	ext.l	d0
	moveq	#$E,d1
	asl.l	d1,d0
	divs.w	d2,d0
	move.w	d0,(a0)
	movea.l	a3,a0
	addq.l	#4,a0
	addq.l	#4,a2
	move.w	(a2),d0
	ext.l	d0
	moveq	#$E,d1
	asl.l	d1,d0
	divs.w	d2,d0
	move.w	d0,(a0)
	movem.l	(-$C,a6),d2/a2-a3
	unlk	a6
	rts
sub_2CFBE:
	link	a6,#$0
	movem.l	a2-a4,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a2
	movea.l	($10,a6),a3
	movea.l	a3,a0
	movea.l	a2,a4
	addq.l	#4,a4
	move.w	(a4),d0
	ext.l	d0
	movea.l	a1,a4
	addq.l	#2,a4
	muls.w	(a4),d0
	movea.l	a2,a4
	addq.l	#2,a4
	move.w	(a4),d1
	ext.l	d1
	movea.l	a1,a4
	addq.l	#4,a4
	muls.w	(a4),d1
	sub.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	move.w	d0,(a0)
	movea.l	a3,a0
	addq.l	#2,a0
	move.w	(a2),d0
	ext.l	d0
	movea.l	a1,a4
	addq.l	#4,a4
	muls.w	(a4),d0
	movea.l	a2,a4
	addq.l	#4,a4
	move.w	(a4),d1
	ext.l	d1
	muls.w	(a1),d1
	sub.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	move.w	d0,(a0)
	movea.l	a3,a0
	addq.l	#4,a0
	movea.l	a2,a3
	addq.l	#2,a3
	move.w	(a3),d0
	ext.l	d0
	muls.w	(a1)+,d0
	move.w	(a2),d1
	ext.l	d1
	muls.w	(a1),d1
	sub.l	d1,d0
	moveq	#$E,d1
	asr.l	d1,d0
	move.w	d0,(a0)
	movem.l	(-$C,a6),a2-a4
	unlk	a6
	rts
dat_2D03E:
	incbin	"../../build/stunrun-68k.bin",$2D03E,$70
sub_2D0AE:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	move.w	($18,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($8,a2)
	move.w	($1E,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($C,a2)
	move.w	($24,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($10,a2)
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_2D110:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	move.w	($16,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($8,a2)
	move.w	($1C,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($C,a2)
	move.w	($22,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($10,a2)
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_2D172:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	move.w	($14,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($8,a2)
	move.w	($1A,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($C,a2)
	move.w	($20,a2),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,($10,a2)
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
download_adsp_program:
	link	a6,#$0
	movem.l	d2-d6/a2-a3,-(sp)
	movea.l	#sub_23C9A,a2
	clr.w	ADSP_CONTROL+$8
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_CONTROL+$C
.l2D1FA:
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	jsr	(a2)
	moveq	#$41,d1
	cmp.l	d0,d1
	bne.s	.l2D1FA
	moveq	#$41,d2
.l2D24C:
	jsr	(a2)
	move.b	d0,d1
	move.b	d1,d0
	ext.w	d1
	ext.l	d1
	cmp.l	d2,d1
	beq.s	.l2D24C
	cmpi.b	#$47,d0
	beq.s	.l2D262
	bra.s	.l2D1FA
.l2D262:
	move.l	#$800000,d3
	moveq	#$1,d2
.l2D26A:
	jsr	(a2)
	move.l	d0,d0
	bne.s	.l2D2C4
	jsr	(a2)
	move.l	d0,d4
	move.l	d4,d1
	asl.l	#8,d1
	move.l	d1,d4
	jsr	(a2)
	move.l	d0,d1
	add.l	d1,d4
	move.l	d4,d0
	asl.l	#2,d0
	add.l	d3,d0
	movea.l	d0,a3
	jsr	(a2)
	move.l	d0,d4
	move.l	d4,d1
	asl.l	#8,d1
	move.l	d1,d4
	jsr	(a2)
	move.l	d0,d1
	add.l	d1,d4
	move.l	d4,d6
	move.l	d2,d5
	bra.s	.l2D2BE
.l2D29E:
	jsr	(a2)
	move.l	d0,d4
	move.l	d4,d1
	asl.l	#8,d1
	move.l	d1,d4
	jsr	(a2)
	move.l	d0,d1
	add.l	d1,d4
	move.l	d4,d1
	asl.l	#8,d1
	move.l	d1,d4
	jsr	(a2)
	move.l	d0,d1
	add.l	d1,d4
	move.l	d4,(a3)+
	addq.l	#1,d5
.l2D2BE:
	cmp.l	d6,d5
	ble.s	.l2D29E
	bra.s	.l2D26A
.l2D2C4:
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1E
	movem.l	(-$1C,a6),d2-d6/a2-a3
	unlk	a6
	rts
load_adsp_program:
	link	a6,#$0
	movem.l	d2-d4/a2,-(sp)
	movea.l	($8,a6),a0
	clr.w	ADSP_CONTROL+$8
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_CONTROL+$C
.l2D304:
	moveq	#$0,d0
	move.b	(a0)+,d0
	move.l	d0,d0
	bne.s	.l2D366
	moveq	#$0,d0
	move.b	(a0)+,d0
	asl.l	#8,d0
	movea.l	a0,a1
	addq.l	#1,a0
	moveq	#$0,d1
	move.b	(a1),d1
	add.l	d1,d0
	move.l	d0,d1
	asl.l	#2,d1
	move.l	d1,d4
	addi.l	#$800000,d4
	movea.l	d4,a2
	moveq	#$0,d0
	move.b	(a0)+,d0
	asl.l	#8,d0
	movea.l	a0,a1
	addq.l	#1,a0
	moveq	#$0,d1
	move.b	(a1),d1
	add.l	d1,d0
	move.l	d0,d3
	moveq	#$1,d2
	bra.s	.l2D360
.l2D340:
	moveq	#$0,d0
	move.b	(a0)+,d0
	asl.l	#8,d0
	movea.l	a0,a1
	addq.l	#1,a0
	moveq	#$0,d1
	move.b	(a1),d1
	add.l	d1,d0
	asl.l	#8,d0
	movea.l	a0,a1
	addq.l	#1,a0
	moveq	#$0,d1
	move.b	(a1),d1
	add.l	d1,d0
	move.l	d0,(a2)+
	addq.l	#1,d2
.l2D360:
	cmp.l	d3,d2
	ble.s	.l2D340
	bra.s	.l2D304
.l2D366:
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1E
	movem.l	(-$10,a6),d2-d4/a2
	unlk	a6
	rts
dat_2D382:
	incbin	"../../build/stunrun-68k.bin",$2D382,$332
dat_2D6B4:
	incbin	"../../build/stunrun-68k.bin",$2D6B4,$24
copy_adsp_dram_to_18000:
	incbin	"../../build/stunrun-68k.bin",$2D6D8,$2E
sub_2D706:
	link	a6,#$0
	move.w	ram_FF9BB6,ram_FF9BFE
	move.w	ram_FF9BBA,ram_FF9C00
	tst.b	ram_FF9BC0
	beq.s	.l2D72E
	move.l	#$FFFF,d0
	bra.s	.l2D736
.l2D72E:
	move.w	ram_FF9BB8,d0
	ext.l	d0
.l2D736:
	move.w	d0,ram_FF9C02
	pea	ram_FF9BDC
	pea	ram_FFDB04
	jsr	sub_22DD6
	pea	$44.w
	pea	ram_FF9BDC
	jsr	sub_2247A
	unlk	a6
	rts
sub_2D762:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#unpack_gsp_image,a2
	move.l	#$FFF23F00,GSP_HOST+$2
	move.l	tbl_BFE00+$78,-(sp)
	jsr	(a2)
	move.l	#$FFF2B760,GSP_HOST+$2
	move.l	tbl_BFE00+$80,-(sp)
	jsr	(a2)
	move.l	#$FFF3FD80,GSP_HOST+$2
	move.l	tbl_BFE00+$84,-(sp)
	jsr	(a2)
	move.l	#$FFF3FB20,GSP_HOST+$2
	move.l	tbl_BFE00+$88,-(sp)
	jsr	(a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2D7C2:
	link	a6,#$0
	move.l	#$FFDE0000,GSP_HOST+$2
	move.l	tbl_BFE00+$4,-(sp)
	jsr	unpack_gsp_image
	jsr	sub_2D762
	move.l	#$FFE00000,GSP_HOST+$2
	move.l	tbl_BFE00+$8,-(sp)
	jsr	unpack_gsp_image
	move.l	dat_47F58,ram_FF9BAE
	move.w	#$2,ram_FF9BCE
	unlk	a6
	rts
dat_2D80E:
	incbin	"../../build/stunrun-68k.bin",$2D80E,$4A
dat_2D858:
	incbin	"../../build/stunrun-68k.bin",$2D858,$216
sub_2DA6E:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.w	($A,a6),d2
	movea.l	#dat_47F50,a2
	cmp.w	ram_FF9BCE,d2
	bne.s	.l2DA92
	clr.w	ram_FF9BCC
	bra.w	.l2DB1A
.l2DA92:
	move.w	d2,d0
	ext.l	d0
	asl.l	#2,d0
	move.l	d0,d1
	addi.l	#tbl_BFE00,d1
	movea.l	d1,a0
	movea.l	(a0),a0
	tst.b	(a0)
	beq.s	.l2DAAE
	jsr	soft_reset
.l2DAAE:
	move.w	d2,ram_FF9BCC
	clr.w	ram_FF9C6A
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	#dat_48068,a0
	tst.l	($0,a0,d0.w)
	beq.s	.l2DAEC
	move.w	d2,d0
	asl.w	#2,d0
	movea.l	#dat_48068,a0
	move.l	($0,a0,d0.w),ram_FFDB40
	move.b	#$F0,ram_FFDB44
	move.b	#$10,ram_FFDB46
.l2DAEC:
	move.w	d2,d0
	asl.w	#2,d0
	cmpi.l	#$400,($0,a2,d0.w)
	bge.s	.l2DB08
	move.w	d2,d0
	asl.w	#2,d0
	move.l	($0,a2,d0.w),ram_FF9BAE
	bra.s	.l2DB1A
.l2DB08:
	move.w	d2,d0
	asl.w	#2,d0
	move.l	($0,a2,d0.w),ram_FF9BD8
	clr.l	ram_FF9BAE
.l2DB1A:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_2DB24:
	link	a6,#$0
	move.l	#$FFE00000,GSP_HOST+$2
	move.l	tbl_BFE00+$C,-(sp)
	jsr	unpack_gsp_image
	move.l	dat_47F5C,ram_FF9BAE
	move.w	#$3,ram_FF9BCE
	unlk	a6
	rts
sub_2DB54:
	link	a6,#$0
	move.l	#$FFE00000,GSP_HOST+$2
	move.l	tbl_BFE00+$114,-(sp)
	jsr	unpack_gsp_image
	move.l	dat_48064,ram_FF9BAE
	move.w	#$45,ram_FF9BCE
	unlk	a6
	rts
sub_2DB84:
	link	a6,#$0
	move.l	#$FFE00000,GSP_HOST+$2
	move.l	tbl_BFE00+$8,-(sp)
	jsr	unpack_gsp_image
	move.l	dat_47F58,ram_FF9BAE
	move.w	#$2,ram_FF9BCE
	unlk	a6
	rts
sub_2DBB4:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d2
	movea.l	#dat_47F50,a1
	move.w	d2,d0
	asl.w	#2,d0
	cmpi.l	#$400,($0,a1,d0.w)
	bge.s	.l2DBE2
	move.w	d2,d0
	asl.w	#2,d0
	move.l	($0,a1,d0.w),ram_FF9BAE
	bra.s	.l2DBF4
.l2DBE2:
	move.w	d2,d0
	asl.w	#2,d0
	move.l	($0,a1,d0.w),ram_FF9BD8
	clr.l	ram_FF9BAE
.l2DBF4:
	move.l	#$FFE00000,GSP_HOST+$2
	move.w	d2,d0
	ext.l	d0
	asl.l	#2,d0
	move.l	d0,d3
	addi.l	#tbl_BFE00,d3
	movea.l	d3,a0
	move.l	(a0),-(sp)
	jsr	unpack_gsp_image
	move.w	d2,ram_FF9BCE
	clr.w	ram_FF9BCC
	clr.w	ram_FF9C6A
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
reload_gsp:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	clr.w	WATCHDOG
	clr.l	$FFFF8014
	jsr	init_gsp
	clr.w	WATCHDOG
	jsr	clear_gsp_screen
	clr.w	WATCHDOG
	move.l	d2,-(sp)
	pea	$FF.w
	pea	$20.w
	pea	$40.w
	jsr	sub_23898
	clr.w	WATCHDOG
	pea	$2000.w
	jsr	set_sr
	pea	str_47678
	pea	$FF.w
	pea	$90.w
	pea	$40.w
	jsr	sub_23898
	btst	#$6,PORT0
	beq.s	.l2DCB0
	jsr	download_gsp_program
	bra.s	.l2DCBC
.l2DCB0:
	move.l	gsp_program_ptr,-(sp)
	jsr	load_gsp_program
.l2DCBC:
	move.w	#$7800,GSP_HOST+$8
	move.w	#$3800,GSP_HOST+$8
	move.l	#dat_45830,ram_FFDB3C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2DCE0:
	link	a6,#$0
	clr.w	ram_FFDAEE
	pea	str_47688
	jsr	reload_gsp
	pea	$1.w
	clr.l	-(sp)
	jsr	sub_43360
	pea	$154.w
	jsr	sub_2DD10
	unlk	a6
	rts
sub_2DD10:
	link	a6,#$0
	movea.l	($8,a6),a0
	jsr	(a0)
	unlk	a6
	rts
sub_2DD1E:
	link	a6,#$FFB0
	movem.l	d2-d3/a2-a3,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	bra.s	.l2DD7A
.l2DD34:
	lea	(-$50,a6),a3
	movea.l	(a2),a0
	bra.s	.l2DD4C
.l2DD3C:
	move.w	($16,a6),d0
	subq.w	#1,($16,a6)
	tst.w	d0
	bgt.s	.l2DD4C
	clr.b	(a3)
	bra.s	.l2DD50
.l2DD4C:
	move.b	(a0)+,(a3)+
	bne.s	.l2DD3C
.l2DD50:
	clr.l	-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	(-$50,a6)
	jsr	sub_2F2CC
	addi.w	#$A,d2
	lea	($14,sp),sp
	addq.l	#4,a2
.l2DD7A:
	tst.w	($16,a6)
	ble.s	.l2DD84
	tst.l	(a2)
	bne.s	.l2DD34
.l2DD84:
	tst.l	(a2)
	beq.s	.l2DD92
	movea.l	a3,a0
	move.b	-(a0),d0
	ext.w	d0
	ext.l	d0
	bra.s	.l2DD94
.l2DD92:
	moveq	#$0,d0
.l2DD94:
	movem.l	(-$60,a6),d2-d3/a2-a3
	unlk	a6
	rts
build_object_list:
	link	a6,#$FFE4
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	#$FF9C6E,d5
	movea.l	d5,a1
	move.l	#$809400,(a1)
	movea.l	ram_FFDBEE,a0
	move.l	(a0),d4
	clr.w	d6
	move.l	#$FFDB04,d3
	movea.l	#ram_FFDB0A,a4
	movea.l	#ram_FFDB10,a3
	lea	(-$1C,a6),a2
.l2DDD4:
	move.w	(a3),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($22,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	move.l	d0,d2
	move.w	(a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($1C,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	move.l	d0,(-$4,a6)
	movea.l	d3,a5
	move.w	(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($16,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	move.l	(-$4,a6),d7
	add.l	d0,d7
	move.l	d7,(-$4,a6)
	add.l	(-$4,a6),d2
	move.w	d2,(a2)
	lea	($18,sp),sp
	addq.w	#1,d6
	addq.l	#2,a2
	addq.l	#2,a3
	addq.l	#2,a4
	addq.l	#2,d3
	cmpi.w	#$3,d6
	blt.s	.l2DDD4
	moveq	#$30,d3
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$8
	move.w	dat_48E2A,ADSP_DRAM+$3FCC
	move.l	dat_48E26,ADSP_DRAM+$3FCE
	move.w	dat_48E2C,ADSP_DRAM+$3FC8
	move.w	dat_48E2E,ADSP_DRAM+$3FCA
	move.w	(-$1C,a6),ADSP_DRAM+$3FDE
	move.w	(-$1A,a6),ADSP_DRAM+$3FE0
	move.w	(-$18,a6),ADSP_DRAM+$3FE2
	move.w	dat_4A82A,ADSP_DRAM+$3FE4
	move.w	dat_4A82C,ADSP_DRAM+$3FE6
	move.w	dat_4A82E,ADSP_DRAM+$3FE8
	move.l	#$80BFEA,-(sp)
	pea	ram_FFDB04
	jsr	sub_22DD6
	move.l	ram_FFDAF8,ADSP_DRAM+$3FD2
	move.l	ram_FFDAFC,ADSP_DRAM+$3FD6
	move.l	ram_FFDB00,ADSP_DRAM+$3FDA
	move.w	dat_48DE8,ADSP_DRAM+$3FFC
	movea.l	d5,a3
	move.l	(a3),ram_FF9C78
	movea.l	d5,a3
	move.l	(a3),-(sp)
	move.l	ram_FFDC74,-(sp)
	jsr	fill_object_entry
	moveq	#$30,d2
	movea.l	d5,a3
	add.l	d2,(a3)
	clr.w	d6
	move.l	#$FF9C80,d4
	movea.l	#ram_FF9C80,a2
	lea	($10,sp),sp
.l2DF24:
	movea.l	d5,a3
	move.l	(a3),-(sp)
	move.l	d4,-(sp)
	jsr	fill_object_entry
	tst.l	d0
	addq.l	#8,sp
	beq.s	.l2DF3E
	movea.l	d3,a0
	movea.l	d5,a1
	move.l	a0,d0
	add.l	d0,(a1)
.l2DF3E:
	bclr	#$6,($38,a2)
	addq.w	#1,d6
	moveq	#$3E,d2
	adda.l	d2,a2
	moveq	#$3E,d2
	add.l	d2,d4
	cmpi.w	#$8,d6
	blt.s	.l2DF24
	movea.l	d5,a2
	move.l	(a2),-(sp)
	pea	ram_FF9E70
	jsr	fill_object_entry
	tst.l	d0
	addq.l	#8,sp
	beq.s	.l2DF70
	moveq	#$30,d2
	movea.l	d5,a0
	add.l	d2,(a0)
.l2DF70:
	moveq	#$30,d2
	bclr	#$6,ram_FF9EA8
	movea.l	ram_FFDA96,a2
	move.l	#$FFDA96,d3
	bra.s	.l2DFAA
.l2DF88:
	movea.l	d5,a3
	move.l	(a3),-(sp)
	move.l	a2,-(sp)
	jsr	fill_object_entry
	tst.l	d0
	addq.l	#8,sp
	beq.s	.l2DFA2
	movea.l	d2,a0
	movea.l	d5,a1
	move.l	a0,d0
	add.l	d0,(a1)
.l2DFA2:
	bclr	#$6,($38,a2)
	movea.l	(a2),a2
.l2DFAA:
	cmpa.l	d3,a2
	bne.s	.l2DF88
	movea.l	d5,a1
	movea.l	(a1),a0
	movea.l	d5,a1
	addq.l	#2,(a1)
	move.w	#$FFFF,(a0)
	movea.l	d5,a1
	move.l	(a1),d2
	subi.l	#$809400,d2
	asr.l	#1,d2
	cmpi.l	#$15E3,d2
	ble.s	.l2DFD4
	jsr	soft_reset
.l2DFD4:
	clr.w	ADSP_DRAM+$3FFE
	clr.b	ram_FF9C72
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	move.w	#$1,ram_FF9C76
	movem.l	(-$44,a6),d2-d7/a2-a5
	unlk	a6
	rts
sub_2DFFE:
	link	a6,#$0
	movem.l	d2-d3/a2-a3,-(sp)
	movea.l	#ram_FF9C80,a0
	moveq	#$3E,d2
	moveq	#$0,d3
	movea.l	a0,a2
	movea.l	a2,a3
	movea.l	a0,a2
.l2E016:
	btst	#$6,($38,a2)
	beq.s	.l2E02E
	move.l	a3,-(sp)
	jsr	update_object_entry
	bclr	#$6,($38,a2)
	addq.l	#4,sp
.l2E02E:
	addq.l	#1,d3
	adda.l	d2,a2
	adda.l	d2,a3
	moveq	#$8,d0
	cmp.l	d3,d0
	bgt.s	.l2E016
	btst	#$6,ram_FF9EA8
	beq.s	.l2E05A
	pea	ram_FF9E70
	jsr	update_object_entry
	bclr	#$6,ram_FF9EA8
	addq.l	#4,sp
.l2E05A:
	movem.l	(-$10,a6),d2-d3/a2-a3
	unlk	a6
	rts
sub_2E064:
	link	a6,#$FFF8
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	ram_FFDBEE,a0
	move.l	(a0),d4
	moveq	#$0,d5
	move.l	#$FFDB04,d3
	movea.l	#ram_FFDB0A,a4
	movea.l	#ram_FFDB10,a3
	lea	(-$6,a6),a2
.l2E08C:
	move.w	(a3),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($22,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	move.l	d0,d2
	move.w	(a4),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($1C,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	move.l	d0,d6
	movea.l	d3,a5
	move.w	(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	movea.l	d4,a5
	movea.l	($C,a5),a0
	move.w	($16,a0),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_229E4
	add.l	d0,d6
	add.l	d6,d2
	move.w	d2,(a2)
	lea	($18,sp),sp
	addq.l	#1,d5
	addq.l	#2,a2
	addq.l	#2,a3
	addq.l	#2,a4
	addq.l	#2,d3
	moveq	#$3,d2
	cmp.l	d5,d2
	bgt.s	.l2E08C
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$8
	move.w	dat_48E2A,ADSP_DRAM+$3FCC
	move.l	dat_48E26,ADSP_DRAM+$3FCE
	move.w	(-$6,a6),ADSP_DRAM+$3FDE
	move.w	(-$4,a6),ADSP_DRAM+$3FE0
	move.w	(-$2,a6),ADSP_DRAM+$3FE2
	move.w	dat_4A82A,ADSP_DRAM+$3FE4
	move.w	dat_4A82C,ADSP_DRAM+$3FE6
	move.w	dat_4A82E,ADSP_DRAM+$3FE8
	move.l	#$80BFEA,-(sp)
	pea	ram_FFDB04
	jsr	sub_22DD6
	move.l	ram_FFDAF8,ADSP_DRAM+$3FD2
	move.l	ram_FFDAFC,ADSP_DRAM+$3FD6
	move.l	ram_FFDB00,ADSP_DRAM+$3FDA
	move.l	ram_FFDC74,-(sp)
	jsr	update_object_entry
	movea.l	ram_FFDA96,a2
	move.l	#$FFDA96,d2
	lea	($C,sp),sp
	bra.s	.l2E1B8
.l2E19E:
	btst	#$6,($38,a2)
	beq.s	.l2E1B6
	move.l	a2,-(sp)
	jsr	update_object_entry
	bclr	#$6,($38,a2)
	addq.l	#4,sp
.l2E1B6:
	movea.l	(a2),a2
.l2E1B8:
	cmpa.l	d2,a2
	bne.s	.l2E19E
	jsr	sub_2DFFE
	clr.w	ADSP_DRAM+$3FFE
	clr.b	ram_FF9C72
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	move.w	#$1,ram_FF9C76
	movem.l	(-$2C,a6),d2-d6/a2-a5
	unlk	a6
	rts
fill_object_entry:
	link	a6,#$FFFC
	movem.l	a2-a3,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	btst	#$5,($38,a2)
	beq.s	.l2E21C
	cmpa.l	ram_FFDC74,a2
	bne.s	.l2E214
	moveq	#$1,d0
	move.l	d0,($22,a3)
	bra.s	.l2E21A
.l2E214:
	moveq	#$0,d0
	bra.w	.l2E302
.l2E21A:
	bra.s	.l2E226
.l2E21C:
	movea.l	($26,a2),a0
	move.l	($C,a0),($22,a3)
.l2E226:
	movea.l	($26,a2),a0
	move.w	(a0),(a3)
	movea.l	($26,a2),a0
	move.w	($2,a0),($2,a3)
	pea	($4,a3)
	pea	($14,a2)
	jsr	sub_22DD6
	move.l	($8,a2),($16,a3)
	move.l	($C,a2),($1A,a3)
	move.l	($10,a2),($1E,a3)
	movea.l	($26,a2),a0
	move.l	($8,a0),($26,a3)
	movea.l	($26,a2),a0
	move.w	($6,a0),($2A,a3)
	move.w	($36,a2),($2C,a3)
	move.b	($38,a2),d1
	asl.b	#3,d1
	lsr.b	#6,d1
	move.b	d1,d0
	and.b	#$3,d0
	lsl.b	#2,d0
	andi.b	#$F3,(-$2,a6)
	or.b	d0,(-$2,a6)
	btst	#$0,($38,a2)
	sne	d1
	neg.b	d1
	move.b	d1,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,(-$2,a6)
	or.b	d0,(-$2,a6)
	move.b	($38,a2),d1
	asl.b	#5,d1
	lsr.b	#6,d1
	move.b	d1,d0
	and.b	#$3,d0
	andi.b	#$FC,(-$2,a6)
	or.b	d0,(-$2,a6)
	btst	#$7,($38,a2)
	sne	d1
	neg.b	d1
	move.b	d1,d0
	lsl.b	#7,d0
	andi.b	#$7F,(-$2,a6)
	or.b	d0,(-$2,a6)
	clr.b	d1
	move.b	d1,d0
	add.b	d0,d0
	andi.b	#$1,(-$1,a6)
	or.b	d0,(-$1,a6)
	and.b	#$3,d1
	lsl.b	#4,d1
	andi.b	#$CF,(-$2,a6)
	or.b	d1,(-$2,a6)
	move.w	(-$2,a6),($2E,a3)
	move.l	a3,($2A,a2)
	moveq	#$1,d0
.l2E302:
	movem.l	(-$C,a6),a2-a3
	unlk	a6
	rts
update_object_entry:
	link	a6,#$FFFC
	movem.l	a2,-(sp)
	movea.l	($8,a6),a2
	btst	#$5,($38,a2)
	beq.s	.l2E326
	moveq	#$0,d0
	bra.w	.l2E3D6
.l2E326:
	movea.l	($2A,a2),a0
	pea	($4,a0)
	pea	($14,a2)
	jsr	sub_22DD6
	movea.l	($2A,a2),a0
	move.l	($8,a2),($16,a0)
	movea.l	($2A,a2),a0
	move.l	($C,a2),($1A,a0)
	movea.l	($2A,a2),a0
	move.l	($10,a2),($1E,a0)
	movea.l	($2A,a2),a0
	movea.l	($26,a2),a1
	move.w	(a1),(a0)
	movea.l	($2A,a2),a0
	movea.l	($26,a2),a1
	move.w	($2,a1),($2,a0)
	movea.l	($2A,a2),a1
	move.w	($2E,a1),(-$2,a6)
	move.b	($38,a2),d0
	asl.b	#3,d0
	lsr.b	#6,d0
	and.b	#$3,d0
	lsl.b	#2,d0
	andi.b	#$F3,(-$2,a6)
	or.b	d0,(-$2,a6)
	btst	#$0,($38,a2)
	sne	d0
	neg.b	d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,(-$2,a6)
	or.b	d0,(-$2,a6)
	move.b	($38,a2),d0
	asl.b	#5,d0
	lsr.b	#6,d0
	and.b	#$3,d0
	andi.b	#$FC,(-$2,a6)
	or.b	d0,(-$2,a6)
	movea.l	($2A,a2),a0
	move.w	(-$2,a6),($2E,a0)
	movea.l	($2A,a2),a0
	move.w	($36,a2),($2C,a0)
	moveq	#$1,d0
.l2E3D6:
	movem.l	(-$8,a6),a2
	unlk	a6
	rts
dat_2E3E0:
	incbin	"../../build/stunrun-68k.bin",$2E3E0,$38
sub_2E418:
	link	a6,#$0
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$8
	tst.w	ADSP_DRAM+$3FC6
	beq.s	.l2E44A
	tst.b	ram_FF9C74
	beq.s	.l2E442
	move.b	#$1,ram_FF9C72
	bra.s	.l2E448
.l2E442:
	clr.w	ADSP_DRAM+$3FC6
.l2E448:
	bra.s	.l2E458
.l2E44A:
	move.w	#$1,ram_FF9BB4
	clr.b	ram_FF9C72
.l2E458:
	clr.w	ADSP_CONTROL+$18
	clr.w	ADSP_CONTROL+$1A
	unlk	a6
	rts
dat_2E468:
	incbin	"../../build/stunrun-68k.bin",$2E468,$4C
sub_2E4B4:
	link	a6,#$0
	movea.l	($8,a6),a0
	movea.l	($C,a6),a1
	move.l	a0,d0
.l2E4C2:
	move.b	(a1)+,(a0)+
	bne.s	.l2E4C2
	unlk	a6
	rts
dat_2E4CA:
	incbin	"../../build/stunrun-68k.bin",$2E4CA,$1C
sub_2E4E6:
	link	a6,#$0
	movea.l	($8,a6),a0
	movea.l	a0,a1
.l2E4F0:
	tst.b	(a0)+
	bne.s	.l2E4F0
	suba.l	a1,a0
	clr.b	d0
	move.l	a0,d1
	asr.l	d0,d1
	movea.l	d1,a0
	subq.l	#1,a0
	move.l	a0,d0
	unlk	a6
	rts
dat_2E506:
	incbin	"../../build/stunrun-68k.bin",$2E506,$296
sub_2E79C:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a0
	movea.l	(a1),a2
	move.l	a0,(a1)
	move.l	a2,(a0)
	move.l	a1,($4,a0)
	move.l	a0,($4,a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2E7C4:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	($8,a6),a1
	movea.l	($C,a6),a0
	movea.l	($4,a1),a2
	move.l	a0,($4,a1)
	move.l	a1,(a0)
	move.l	a2,($4,a0)
	move.l	a0,(a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2E7EE:
	link	a6,#$0
	movea.l	($8,a6),a0
	movea.l	(a0),a1
	move.l	($4,a0),($4,a1)
	movea.l	($4,a0),a1
	move.l	(a0),(a1)
	moveq	#$0,d0
	move.l	d0,($4,a0)
	move.l	d0,(a0)
	unlk	a6
	rts
sub_2E810:
	link	a6,#$0
	movem.l	a2,-(sp)
	move.l	#$FFDA86,d0
	movea.l	ram_FFDA86,a0
	movea.l	a0,a2
	cmp.l	a0,d0
	bne.s	.l2E830
	moveq	#$0,d0
	movea.l	d0,a2
	bra.s	.l2E866
.l2E830:
	move.l	a2,-(sp)
	jsr	sub_2E7EE
	bclr	#$5,($38,a2)
	andi.b	#$E7,($38,a2)
	ori.b	#$0,($38,a2)
	andi.b	#$F9,($38,a2)
	ori.b	#$0,($38,a2)
	bclr	#$7,($38,a2)
	clr.w	($36,a2)
	bclr	#$0,($38,a2)
.l2E866:
	move.l	a2,d0
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2E872:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,-(sp)
	pea	ram_FFDA86
	jsr	sub_2E79C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E89E:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	#$FFDA9E,d1
	move.l	ram_FFDA9E,d0
	move.l	d0,d2
	cmp.l	d0,d1
	bne.s	.l2E8BC
	moveq	#$0,d0
	bra.s	.l2E8C6
.l2E8BC:
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,d0
.l2E8C6:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E8D0:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,-(sp)
	pea	ram_FFDA9E
	jsr	sub_2E79C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E8FC:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	#$FFDAA6,d1
	move.l	ram_FFDAA6,d0
	move.l	d0,d2
	cmp.l	d0,d1
	bne.s	.l2E91A
	moveq	#$0,d0
	bra.s	.l2E924
.l2E91A:
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,d0
.l2E924:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E92E:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,-(sp)
	pea	ram_FFDAA6
	jsr	sub_2E79C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E95A:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	#$FFDAB6,d1
	move.l	ram_FFDAB6,d0
	move.l	d0,d2
	cmp.l	d0,d1
	bne.s	.l2E978
	moveq	#$0,d0
	bra.s	.l2E988
.l2E978:
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	addq.b	#1,ram_FF9C7C
	move.l	d2,d0
.l2E988:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2E992:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	($8,a6),a2
	move.l	a2,-(sp)
	jsr	sub_2E7EE
	move.w	#$FFFF,($10,a2)
	clr.l	($12,a2)
	clr.l	($16,a2)
	clr.l	($1A,a2)
	move.l	a2,-(sp)
	pea	ram_FFDAB6
	jsr	sub_2E79C
	subq.b	#1,ram_FF9C7C
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2E9D6:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	#$FFDAC6,d1
	move.l	ram_FFDAC6,d0
	move.l	d0,d2
	cmp.l	d0,d1
	bne.s	.l2E9F4
	moveq	#$0,d0
	bra.s	.l2E9FE
.l2E9F4:
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,d0
.l2E9FE:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2EA08:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,-(sp)
	pea	ram_FFDAC6
	jsr	sub_2E79C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2EA34:
	link	a6,#$0
	movem.l	d2,-(sp)
	cmpi.w	#$41,ram_FF9550
	beq.s	.l2EA54
	cmpi.b	#$28,ram_FF9C7E
	bcs.s	.l2EA54
.l2EA50:
	moveq	#$0,d0
	bra.s	.l2EA78
.l2EA54:
	move.l	#$FFDAD6,d1
	move.l	ram_FFDAD6,d0
	move.l	d0,d2
	cmp.l	d0,d1
	bne.s	.l2EA68
	bra.s	.l2EA50
.l2EA68:
	addq.b	#1,ram_FF9C7E
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,d0
.l2EA78:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2EA82:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	subq.b	#1,ram_FF9C7E
	move.l	d2,-(sp)
	jsr	sub_2E7EE
	move.l	d2,-(sp)
	pea	ram_FFDAD6
	jsr	sub_2E79C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2EAB4:
	link	a6,#$FFC4
	movem.l	d2-d6/a2-a5,-(sp)
	movea.l	($8,a6),a2
	move.l	#sub_2E872,d4
	move.l	(a2),d2
	clr.w	(-$2,a6)
	lea	(-$3A,a6),a3
	bra.s	.l2EB30
.l2EAD2:
	movea.l	d2,a1
	move.l	(a1),d6
	movea.l	d2,a1
	move.l	($10,a1),d3
	movea.l	d2,a1
	lea	($10,a1),a4
	bra.s	.l2EB08
.l2EAE4:
	movea.l	d3,a5
	move.l	(a5),d5
	move.l	d3,-(sp)
	jsr	sub_333A4
	movea.l	d3,a5
	move.l	($8,a5),-(sp)
	movea.l	d4,a5
	jsr	(a5)
	move.l	d3,-(sp)
	jsr	sub_2E92E
	lea	($C,sp),sp
	move.l	d5,d3
.l2EB08:
	cmp.l	a4,d3
	bne.s	.l2EAE4
	move.w	(-$2,a6),d0
	addq.w	#1,(-$2,a6)
	asl.w	#2,d0
	move.l	d2,($0,a3,d0.w)
	movea.l	d2,a4
	move.l	($C,a4),-(sp)
	movea.l	d4,a4
	jsr	(a4)
	move.l	d2,-(sp)
	jsr	sub_2E8D0
	addq.l	#8,sp
	move.l	d6,d2
.l2EB30:
	cmp.l	a2,d2
	bne.s	.l2EAD2
	movea.l	ram_FFDAAE,a1
	lea	(-$3A,a6),a2
	move.l	#$FFDAAE,d2
	bra.s	.l2EB70
.l2EB46:
	movea.l	(a1),a3
	clr.w	d6
	movea.l	a2,a0
	bra.s	.l2EB68
.l2EB4E:
	move.l	(a0),d0
	cmp.l	($1A,a1),d0
	bne.s	.l2EB64
	move.l	a1,-(sp)
	jsr	sub_35502
	movea.l	d0,a3
	addq.l	#4,sp
	bra.s	.l2EB6E
.l2EB64:
	addq.w	#1,d6
	addq.l	#4,a0
.l2EB68:
	cmp.w	(-$2,a6),d6
	blt.s	.l2EB4E
.l2EB6E:
	movea.l	a3,a1
.l2EB70:
	cmpa.l	d2,a1
	bne.s	.l2EB46
	move.l	ram_FFDADE,d5
	movea.l	#ram_FFDC1C,a3
	lea	(-$3A,a6),a4
	move.l	#$FFDADE,d3
	bra.s	.l2EBC8
.l2EB8C:
	moveq	#$1,d2
	movea.l	d5,a0
	move.l	(a0),(-$6,a6)
	clr.w	d6
	movea.l	a4,a2
	bra.s	.l2EBBE
.l2EB9A:
	move.l	(a2),d0
	movea.l	d5,a0
	cmp.l	($C,a0),d0
	bne.s	.l2EBBA
	movea.l	d5,a5
	move.l	($8,a5),-(sp)
	movea.l	d4,a5
	jsr	(a5)
	move.l	d5,-(sp)
	jsr	sub_2EA82
	move.b	d2,(a3)
	addq.l	#8,sp
.l2EBBA:
	addq.w	#1,d6
	addq.l	#4,a2
.l2EBBE:
	cmp.w	(-$2,a6),d6
	blt.s	.l2EB9A
	move.l	(-$6,a6),d5
.l2EBC8:
	cmp.l	d3,d5
	bne.s	.l2EB8C
	move.l	ram_FFDABE,d3
	lea	(-$3A,a6),a4
	move.l	#$FFDABE,d2
	movea.l	#ram_FFDD5A,a2
	movea.l	#ram_FFDC1C,a3
	bra.w	loc_2EC5C
loc_2EBEC:
	movea.l	d3,a1
	move.l	(a1),d5
	clr.w	d6
	movea.l	a4,a0
	bra.s	loc_2EC54
loc_2EBF6:
	move.l	(a0),d0
	movea.l	d3,a1
	cmp.l	($C,a1),d0
	bne.s	loc_2EC50
	movea.l	d3,a1
	movea.l	($8,a1),a0
	movea.l	($26,a0),a0
	move.w	($4,a0),d0
	cmpi.w	#$92,d0
	blt.s	loc_2EC36
	cmpi.w	#$97,d0
	bgt.s	loc_2EC36
	sub.w	#$92,d0
	add.w	d0,d0
	move.w	(.l2EC28,pc,d0.w),d0
	jmp	(.l2EC28,pc,d0.w)
.l2EC28:
	dc.w	sub_2EC34-.l2EC28
	dc.w	sub_2EC34-.l2EC28
	dc.w	sub_2EC34-.l2EC28
	dc.w	sub_2EC34-.l2EC28
	dc.w	sub_2EC34-.l2EC28
	dc.w	sub_2EC34-.l2EC28
sub_2EC34:
	subq.b	#1,(a2)
loc_2EC36:
	movea.l	d3,a5
	move.l	($8,a5),-(sp)
	movea.l	d4,a5
	jsr	(a5)
	move.l	d3,-(sp)
	jsr	sub_2EA08
	move.b	#$1,(a3)
	addq.l	#8,sp
	bra.s	loc_2EC5A
loc_2EC50:
	addq.w	#1,d6
	addq.l	#4,a0
loc_2EC54:
	cmp.w	(-$2,a6),d6
	blt.s	loc_2EBF6
loc_2EC5A:
	move.l	d5,d3
loc_2EC5C:
	cmp.l	d2,d3
	bne.s	loc_2EBEC
	movem.l	(-$60,a6),d2-d6/a2-a5
	unlk	a6
	rts
dat_2EC6A:
	incbin	"../../build/stunrun-68k.bin",$2EC6A,$32
sub_2EC9C:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	move.l	($C,a6),d2
	move.l	($10,a6),d3
	tst.l	d2
	beq.s	.l2ECB8
	move.l	a2,d0
	bne.s	.l2ECBE
.l2ECB8:
	jsr	soft_reset
.l2ECBE:
	move.l	d2,($26,a2)
	move.l	d3,($8,a2)
	move.l	($14,a6),($C,a2)
	move.l	($18,a6),($10,a2)
	pea	($14,a2)
	move.l	($1C,a6),-(sp)
	jsr	sub_22DD6
	clr.w	($36,a2)
	moveq	#$1,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
object_descriptor:
	link	a6,#$0
	move.w	($A,a6),d0
	cmpi.w	#$13A,d0
	bge.s	.l2ED10
	asl.w	#2,d0
	move.w	d0,d1
	asl.w	#2,d0
	add.w	d1,d0
	movea.l	#object_descriptors,a0
	adda.w	d0,a0
	bra.s	.l2ED14
.l2ED10:
	moveq	#$0,d0
	movea.l	d0,a0
.l2ED14:
	move.l	a0,d0
	unlk	a6
	rts
sub_2ED1A:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	move.l	($8,a6),d0
	movea.l	#sub_2E7C4,a2
	moveq	#$3E,d2
	move.l	d0,ram_FFDB32
	move.l	#$FFDA86,d0
	move.l	d0,ram_FFDA8A
	move.l	d0,ram_FFDA86
	move.l	#$FFDA9E,d0
	move.l	d0,ram_FFDAA2
	move.l	d0,ram_FFDA9E
	move.l	#$FFDAB6,d0
	move.l	d0,ram_FFDABA
	move.l	d0,ram_FFDAB6
	clr.b	ram_FF9C7C
	move.l	#$FFDAA6,d0
	move.l	d0,ram_FFDAAA
	move.l	d0,ram_FFDAA6
	move.l	#$FFDAC6,d0
	move.l	d0,ram_FFDACA
	move.l	d0,ram_FFDAC6
	move.l	#$FFDAD6,d0
	move.l	d0,ram_FFDADA
	move.l	d0,ram_FFDAD6
	move.l	#$FFDBEE,d0
	move.l	d0,ram_FFDBF2
	move.l	d0,ram_FFDBEE
	move.l	#$FFDBF6,d0
	move.l	d0,ram_FFDBFA
	move.l	d0,ram_FFDBF6
	move.l	#$FFDA96,d0
	move.l	d0,ram_FFDA9A
	move.l	d0,ram_FFDA96
	move.l	#$FFDAAE,d0
	move.l	d0,ram_FFDAB2
	move.l	d0,ram_FFDAAE
	move.l	#$FFDABE,d0
	move.l	d0,ram_FFDAC2
	move.l	d0,ram_FFDABE
	move.l	#$FFDADE,d0
	move.l	d0,ram_FFDAE2
	move.l	d0,ram_FFDADE
	clr.b	ram_FF9C7E
	move.l	#$FFDAE6,d0
	move.l	d0,ram_FFDAEA
	move.l	d0,ram_FFDAE6
	move.l	#$FFDACE,d0
	move.l	d0,ram_FFDAD2
	move.l	d0,ram_FFDACE
	clr.w	WATCHDOG
	move.l	#$FF9EAE,d5
	move.l	#$FFBBBE,d4
	move.l	#$FFDA86,d3
	bra.s	.l2EE60
.l2EE56:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EE60:
	cmp.l	d4,d5
	bcs.s	.l2EE56
	moveq	#$1C,d2
	clr.w	WATCHDOG
	move.l	#$FFBBDE,d5
	move.l	#$FFBF26,d4
	move.l	#$FFDA9E,d3
	bra.s	.l2EE8A
.l2EE80:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EE8A:
	cmp.l	d4,d5
	bcs.s	.l2EE80
	moveq	#$C,d2
	clr.w	WATCHDOG
	move.l	#$FFBF26,d5
	move.l	#$FFC35E,d4
	move.l	#$FFDAA6,d3
	bra.s	.l2EEB4
.l2EEAA:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EEB4:
	cmp.l	d4,d5
	bcs.s	.l2EEAA
	moveq	#$78,d2
	clr.w	WATCHDOG
	move.l	#$FFD55E,d5
	move.l	#$FFDA86,d4
	move.l	#$FFDAB6,d3
	bra.s	.l2EEDE
.l2EED4:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EEDE:
	cmp.l	d4,d5
	bcs.s	.l2EED4
	moveq	#$18,d2
	clr.w	WATCHDOG
	move.l	#$FFC35E,d5
	move.l	#$FFC47E,d4
	move.l	#$FFDAC6,d3
	bra.s	.l2EF08
.l2EEFE:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EF08:
	cmp.l	d4,d5
	bcs.s	.l2EEFE
	moveq	#$36,d2
	clr.w	WATCHDOG
	move.l	#$FFC47E,d5
	move.l	#$FFD55E,d4
	move.l	#$FFDAD6,d3
	bra.s	.l2EF32
.l2EF28:
	move.l	d5,-(sp)
	move.l	d3,-(sp)
	jsr	(a2)
	addq.l	#8,sp
	add.l	d2,d5
.l2EF32:
	cmp.l	d4,d5
	bcs.s	.l2EF28
	clr.w	WATCHDOG
	clr.b	ram_FFDD5A
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
sub_2EF4C:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	move.l	($8,a6),d4
	move.l	($C,a6),d3
	move.l	($10,a6),d2
	jsr	sub_2E810
	move.l	d0,d5
	beq.s	.l2EFA8
	move.l	d4,-(sp)
	jsr	object_descriptor
	tst.l	d0
	bne.s	.l2EF7A
	moveq	#$0,d5
	bra.s	.l2EFAA
.l2EF7A:
	move.l	($18,a6),-(sp)
	move.l	($14,a6),-(sp)
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	move.l	d0,-(sp)
	move.l	d5,-(sp)
	jsr	sub_2EC9C
	move.l	d5,-(sp)
	pea	ram_FFDA96
	jsr	sub_2E7C4
	move.b	#$1,ram_FFDC1C
	bra.s	.l2EFAA
.l2EFA8:
	moveq	#$0,d5
.l2EFAA:
	move.l	d5,d0
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_2EFB6:
	link	a6,#$FFFC
	movem.l	d2,-(sp)
	movea.l	($8,a6),a0
	move.l	($C,a6),d0
	clr.w	d1
	bra.s	.l2EFCC
.l2EFCA:
	add.w	(a0)+,d1
.l2EFCC:
	cmpa.l	d0,a0
	bcs.s	.l2EFCA
	move.l	#$BAD0,d2
	moveq	#$0,d0
	move.w	d1,d0
	sub.l	d0,d2
	move.w	d2,(-$2,a6)
	pea	$2.w
	move.l	a0,-(sp)
	pea	(-$2,a6)
	jsr	copy_to_zram
	lea	($C,sp),sp
	movem.l	(-$8,a6),d2
	unlk	a6
	rts
sub_2EFFE:
	link	a6,#$0
	movea.l	($8,a6),a0
	move.l	($C,a6),d0
	clr.w	d1
	bra.s	.l2F010
.l2F00E:
	add.w	(a0)+,d1
.l2F010:
	cmpa.l	d0,a0
	bls.s	.l2F00E
	moveq	#$0,d0
	cmpi.w	#$BAD0,d1
	seq	d0
	neg.b	d0
	unlk	a6
	rts
sub_2F022:
	link	a6,#$FFFC
	movem.l	d2,-(sp)
	movea.l	($8,a6),a0
	move.b	($F,a6),d2
	moveq	#$0,d1
	move.b	(a0),d1
	moveq	#$0,d0
	move.b	d2,d0
	add.l	d0,d1
	move.b	d1,(-$1,a6)
	pea	$1.w
	move.l	a0,-(sp)
	pea	(-$1,a6)
	jsr	copy_to_zram
	movem.l	(-$8,a6),d2
	unlk	a6
	rts
dat_2F05A:
	incbin	"../../build/stunrun-68k.bin",$2F05A,$54
sub_2F0AE:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	#$7000,GSP_HOST+$C
	move.w	(a2)+,d2
	move.w	d2,ram_FFDB4E
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_2247A
	move.w	d2,d0
	ext.l	d0
	subq.l	#1,d0
	add.l	d0,d0
	adda.l	d0,a2
	cmpi.w	#$FFFF,(a2)
	beq.s	.l2F0EE
	jsr	soft_reset
.l2F0EE:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
dat_2F0F8:
	incbin	"../../build/stunrun-68k.bin",$2F0F8,$2E
sub_2F126:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDB3A,a2
	tst.b	(a2)
	beq.s	.l2F13C
	clr.b	(a2)
	bra.s	.l2F140
.l2F13C:
	move.b	#$1,(a2)
.l2F140:
	move.b	(a2),d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	movea.l	#dat_4A88C,a0
	move.l	($0,a0,d0.l),GSP_HOST+$2
	tst.w	GSP_HOST+$C
	beq.s	.l2F19E
	clr.w	ram_FFDB48
	pea	str_4A830
	jsr	sub_2FC60
	move.b	(a2),d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	movea.l	#dat_4A88C,a0
	move.l	($0,a0,d0.l),GSP_HOST+$2
	tst.w	GSP_HOST+$C
	beq.s	.l2F19E
	pea	$8.w
	jsr	sub_30830
	jsr	soft_reset
.l2F19E:
	move.b	(a2),d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	movea.l	#dat_4A88C,a0
	move.l	($4,a0,d0.l),GSP_HOST+$2
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_2F1BE:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.w	($A,a6),d2
	movea.l	#ram_FFDB3C,a2
	tst.l	(a2)
	beq.s	.l2F1DE
	move.l	(a2),-(sp)
	jsr	sub_2F6BE
	clr.l	(a2)
.l2F1DE:
	tst.l	ram_FFDB40
	beq.s	.l2F20C
	move.l	ram_FFDB40,-(sp)
	moveq	#$0,d0
	move.b	ram_FFDB46,d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.b	ram_FFDB44,d0
	move.l	d0,-(sp)
	jsr	sub_2F610
	clr.l	ram_FFDB40
.l2F20C:
	pea	str_4A83C
	jsr	sub_2FC60
	move.w	#$FFFF,GSP_HOST+$C
	move.b	ram_FFDB3A,d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	movea.l	#dat_4A88C,a0
	move.l	($0,a0,d0.l),GSP_HOST+$2
	clr.w	ram_FFDB48
	move.w	d2,GSP_HOST+$C
	move.l	$FFFF8014,ram_FFDB36
	clr.l	ram_FFDB4A
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
dat_2F260:
	incbin	"../../build/stunrun-68k.bin",$2F260,$6C
sub_2F2CC:
	link	a6,#$0
	movem.l	d2,-(sp)
	movea.l	($8,a6),a0
	move.w	($E,a6),d2
	move.w	($12,a6),d1
	movea.l	#GSP_HOST+$C,a1
	moveq	#$0,d0
	move.b	($17,a6),d0
	ori.l	#$4000,d0
	move.w	d0,GSP_HOST+$C
	move.w	($1A,a6),GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	move.w	d1,GSP_HOST+$C
.l2F30C:
	moveq	#$0,d0
	move.b	(a0)+,d0
	move.w	d0,d1
	tst.w	d1
	bne.s	.l2F31E
	clr.w	GSP_HOST+$C
	bra.s	.l2F330
.l2F31E:
	moveq	#$0,d0
	move.b	(a0),d0
	lsl.l	#8,d0
	or.w	d0,d1
	move.w	d1,(a1)
	tst.b	(a0)
	beq.s	.l2F330
	tst.b	(a0)+
	bne.s	.l2F30C
.l2F330:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
dat_2F33A:
	incbin	"../../build/stunrun-68k.bin",$2F33A,$C6
dat_2F400:
	incbin	"../../build/stunrun-68k.bin",$2F400,$70
sub_2F470:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	move.w	($12,a6),d1
	moveq	#$0,d0
	move.b	($1B,a6),d0
	addi.l	#$2000,d0
	move.w	d0,GSP_HOST+$C
	move.w	d3,GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	move.w	d1,GSP_HOST+$C
	move.w	($16,a6),GSP_HOST+$C
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
dat_2F4BA:
	incbin	"../../build/stunrun-68k.bin",$2F4BA,$48
sub_2F502:
	link	a6,#$0
	move.l	($8,a6),d0
	move.l	d0,-(sp)
	pea	$100.w
	pea	$200.w
	pea	$20.w
	clr.l	-(sp)
	jsr	sub_2F674
	unlk	a6
	rts
sub_2F524:
	link	a6,#$0
	movem.l	d2-d4/a2-a3,-(sp)
	move.l	($8,a6),d2
	movea.l	#GSP_HOST+$C,a2
	move.l	GSP_HOST+$2,d4
	move.l	#$F5000000,GSP_HOST+$2
	movea.l	d2,a3
	move.l	#$100,d3
	movea.l	a3,a1
	movea.l	a3,a0
	addq.l	#1,a0
	bra.s	.l2F56E
.l2F556:
	moveq	#$0,d0
	move.b	(a0),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.b	(a1),d0
	lsl.l	#8,d0
	or.l	d0,d1
	move.w	d1,(a2)
	subq.l	#1,d3
	addq.l	#3,a3
	addq.l	#3,a0
	addq.l	#3,a1
.l2F56E:
	tst.l	d3
	bne.s	.l2F556
	movea.l	#GSP_HOST+$C,a1
	move.l	#$F5800000,GSP_HOST+$2
	move.l	d2,d0
	addq.l	#2,d0
	movea.l	d0,a3
	move.l	#$100,d3
	movea.l	a3,a0
	bra.s	.l2F5A8
.l2F592:
	moveq	#$0,d0
	move.b	(a0),d0
	move.l	d0,d1
	moveq	#$0,d0
	move.b	(a0),d0
	lsl.l	#8,d0
	add.l	d0,d1
	move.w	d1,(a1)
	subq.l	#1,d3
	addq.l	#3,a3
	addq.l	#3,a0
.l2F5A8:
	tst.l	d3
	bne.s	.l2F592
	move.l	d4,GSP_HOST+$2
	movem.l	(-$14,a6),d2-d4/a2-a3
	unlk	a6
	rts
sub_2F5BC:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.l	($8,a6),d0
	move.l	($C,a6),d3
	btst	#$0,d0
	beq.s	.l2F5FA
	movea.l	#GSP_HOST+$C,a1
.l2F5D8:
	movea.l	d3,a0
	subq.l	#1,d3
	move.l	a0,d1
	beq.s	.l2F5F8
	moveq	#$0,d1
	movea.l	d0,a2
	move.b	(a2)+,d1
	move.l	a2,d0
	lsl.l	#8,d1
	movea.l	d0,a0
	addq.l	#1,d0
	moveq	#$0,d2
	move.b	(a0),d2
	or.w	d2,d1
	move.w	d1,(a1)
	bra.s	.l2F5D8
.l2F5F8:
	bra.s	.l2F606
.l2F5FA:
	move.l	d3,-(sp)
	move.l	d0,-(sp)
	jsr	sub_2247A
	addq.l	#8,sp
.l2F606:
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_2F610:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	move.b	($B,a6),d2
	move.w	($E,a6),d3
	move.l	($10,a6),d4
	moveq	#$0,d1
	move.w	d3,d1
	moveq	#$0,d0
	move.b	d2,d0
	add.l	d0,d1
	cmpi.l	#$100,d1
	bhi.s	.l2F66A
	moveq	#$0,d0
	move.b	d2,d0
	addi.l	#$9000,d0
	move.w	d0,GSP_HOST+$C
	move.w	d3,GSP_HOST+$C
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	move.l	d0,d1
	addq.l	#1,d1
	lsr.l	#1,d1
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2F5BC
.l2F66A:
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_2F674:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	move.w	($12,a6),d1
	moveq	#$0,d0
	move.b	($1B,a6),d0
	addi.l	#$3000,d0
	move.w	d0,GSP_HOST+$C
	move.w	d3,GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	move.w	d1,GSP_HOST+$C
	move.w	($16,a6),GSP_HOST+$C
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_2F6BE:
	link	a6,#$0
	move.l	($8,a6),d0
	move.w	#$9000,GSP_HOST+$C
	move.w	#$100,GSP_HOST+$C
	pea	$180.w
	move.l	d0,-(sp)
	jsr	sub_2247A
	unlk	a6
	rts
sub_2F6E6:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.w	($A,a6),d1
	move.w	($E,a6),d2
	move.w	($12,a6),d3
	moveq	#$0,d0
	move.w	d1,d0
	moveq	#$3,d1
	and.l	d1,d0
	addi.l	#$C000,d0
	move.w	d0,GSP_HOST+$C
	andi.w	#$FF,d2
	move.w	d2,GSP_HOST+$C
	cmpi.w	#$100,d3
	bls.s	.l2F722
	move.w	#$100,d3
.l2F722:
	move.w	d3,GSP_HOST+$C
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,-(sp)
	move.l	($14,a6),-(sp)
	jsr	sub_2247A
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_2F742:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.b	($B,a6),d1
	move.l	($C,a6),d2
	move.w	#$E000,GSP_HOST+$C
	moveq	#$0,d0
	move.b	d1,d0
	move.w	d0,GSP_HOST+$C
	move.w	#$1,GSP_HOST+$C
	move.l	d2,GSP_HOST+$C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
dat_2F77C:
	incbin	"../../build/stunrun-68k.bin",$2F77C,$1A
sub_2F796:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.w	($A,a6),d2
	move.w	($E,a6),d1
	move.w	($12,a6),d0
	move.w	#$5000,GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	move.w	d1,GSP_HOST+$C
	move.w	d0,GSP_HOST+$C
	move.w	($16,a6),GSP_HOST+$C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_2F7D6:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.w	($A,a6),d2
	move.w	($E,a6),d1
	move.w	($12,a6),d0
	move.w	#$8000,GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	move.w	d1,GSP_HOST+$C
	move.w	d0,GSP_HOST+$C
	move.l	($14,a6),GSP_HOST+$C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
dat_2F816:
	incbin	"../../build/stunrun-68k.bin",$2F816,$74
sub_2F88A:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.b	($B,a6),d1
	move.l	($C,a6),d2
	move.w	($12,a6),d3
	moveq	#$0,d0
	move.b	d1,d0
	ori.l	#$D000,d0
	move.w	d0,GSP_HOST+$C
	move.l	d2,d0
	andi.l	#$FFFF,d0
	move.w	d0,GSP_HOST+$C
	move.l	d2,d0
	moveq	#$10,d1
	asr.l	d1,d0
	move.w	d0,GSP_HOST+$C
	move.w	d3,GSP_HOST+$C
	move.w	($16,a6),GSP_HOST+$C
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_2F8E0:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.l	($8,a6),d2
	move.w	($E,a6),d3
	move.w	($12,a6),d0
	cmpi.w	#$1,($1A,a6)
	bne.s	.l2F91E
	move.w	($1A,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	move.w	($16,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d3
	move.l	d2,-(sp)
	jsr	sub_2E4E6
	asl.l	#3,d0
	bra.s	.l2F93E
.l2F91E:
	move.w	($1A,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	move.w	($16,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d3
	move.l	d2,-(sp)
	jsr	sub_2E4E6
	asl.l	#2,d0
.l2F93E:
	sub.l	d0,d3
	addq.l	#4,sp
	move.l	d3,-(sp)
	move.l	d2,-(sp)
	jsr	sub_2F2CC
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
dat_2F956:
	incbin	"../../build/stunrun-68k.bin",$2F956,$7E
sub_2F9D4:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	move.l	($8,a6),d3
	move.w	($E,a6),d2
	move.w	($12,a6),d4
	cmpi.w	#$1,($1E,a6)
	bne.s	.l2FA00
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#3,d0
	sub.w	d0,d2
	moveq	#$2,d1
	bra.s	.l2FA0E
.l2FA00:
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#2,d0
	sub.w	d0,d2
	moveq	#$1,d1
.l2FA0E:
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d1,d0
	ext.l	d0
	move.w	d4,d5
	ext.l	d5
	add.l	d5,d0
	move.l	d0,-(sp)
	ext.l	d1
	move.w	d2,d0
	ext.l	d0
	add.l	d0,d1
	move.l	d1,-(sp)
	move.l	d3,-(sp)
	jsr	sub_2F2CC
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d2
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	jsr	sub_2F2CC
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_2FA68:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	move.l	($8,a6),d4
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2F2CC
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d3
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2F2CC
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_2FACE:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	move.l	($8,a6),d3
	move.w	($E,a6),d2
	move.w	($12,a6),d4
	cmpi.w	#$1,($1A,a6)
	bne.s	.l2FAF6
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#3,d0
	bra.s	.l2FB00
.l2FAF6:
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#2,d0
.l2FB00:
	sub.w	d0,d2
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d2
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	jsr	sub_2FA68
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_2FB2E:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	move.l	($8,a6),d4
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	movea.l	#sub_2F2CC,a2
	tst.w	($1E,a6)
	beq.s	.l2FB52
	moveq	#$2,d0
	bra.s	.l2FB54
.l2FB52:
	moveq	#$1,d0
.l2FB54:
	move.w	d0,d5
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.w	d2,d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.w	d3,d1
	ext.l	d1
	add.l	d1,d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	(a2)
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.w	d2,d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,-(sp)
	move.w	d5,d0
	ext.l	d0
	move.w	d3,d1
	ext.l	d1
	add.l	d1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	(a2)
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	(a2)
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d3
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	jsr	(a2)
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
sub_2FBFA:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	move.l	($8,a6),d3
	move.w	($E,a6),d2
	move.w	($12,a6),d4
	cmpi.w	#$1,($1E,a6)
	bne.s	.l2FC22
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#3,d0
	bra.s	.l2FC2C
.l2FC22:
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	asl.l	#2,d0
.l2FC2C:
	sub.w	d0,d2
	move.w	($1E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($1A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	($16,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	ext.l	d4
	move.l	d4,-(sp)
	ext.l	d2
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	jsr	sub_2FB2E
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_2FC60:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	move.l	($8,a6),d4
	moveq	#$5,d2
	moveq	#$C,d3
	clr.w	WATCHDOG
	move.l	#$80000,d5
	movea.l	#ram_FFDB48,a2
.l2FC82:
	tst.w	(a2)
	bne.s	.l2FCB6
	move.l	d2,-(sp)
	jsr	sub_22766
	move.l	d5,d0
	subq.l	#1,d5
	tst.l	d0
	addq.l	#4,sp
	bne.s	.l2FCA4
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	jsr	sub_308C4
	addq.l	#8,sp
.l2FCA4:
	move.l	d2,-(sp)
	jsr	sub_22766
	clr.w	WATCHDOG
	addq.l	#4,sp
	bra.s	.l2FC82
.l2FCB6:
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
download_gsp_program:
	link	a6,#$0
	movem.l	d2-d7/a2-a3,-(sp)
	movea.l	#sub_23C9A,a2
.l2FCCE:
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	jsr	(a2)
	moveq	#$53,d1
	cmp.l	d0,d1
	bne.s	.l2FCCE
	moveq	#$53,d2
.l2FD20:
	jsr	(a2)
	move.b	d0,d1
	move.b	d1,d0
	ext.w	d1
	ext.l	d1
	cmp.l	d2,d1
	beq.s	.l2FD20
	cmpi.b	#$47,d0
	beq.s	.l2FD36
	bra.s	.l2FCCE
.l2FD36:
	moveq	#$10,d3
	movea.l	#GSP_HOST+$2,a2
	jsr	init_gsp
	move.w	#$B800,GSP_HOST+$8
	jsr	sub_2FF8E
	move.l	d0,d6
.l2FD54:
	move.l	d6,d1
	subq.l	#1,d6
	tst.l	d1
	ble.w	.l2FDC6
	moveq	#$20,d2
	jsr	sub_2FF8E
	movea.l	d0,a3
	move.l	a3,d5
	jsr	sub_2FF8E
	move.l	d0,d4
	add.l	d4,d5
	move.l	a3,(a2)
	moveq	#$0,d7
	movea.l	d7,a3
	bra.s	.l2FD92
.l2FD7C:
	jsr	sub_2FF8E
	add.l	d0,d5
	addq.l	#1,a3
	move.l	d0,-(sp)
	jsr	write_gsp_long
	addq.l	#4,sp
	sub.l	d2,d4
.l2FD92:
	cmp.l	d2,d4
	bge.s	.l2FD7C
	tst.l	d4
	beq.s	.l2FDB4
	cmp.l	d3,d4
	beq.s	.l2FDA4
	jsr	soft_reset
.l2FDA4:
	jsr	sub_2FF8E
	add.l	d0,d5
	addq.l	#1,a3
	move.w	d0,GSP_HOST+$C
.l2FDB4:
	jsr	sub_2FF8E
	cmp.l	d0,d5
	beq.s	.l2FDC4
	jsr	soft_reset
.l2FDC4:
	bra.s	.l2FD54
.l2FDC6:
	movem.l	(-$20,a6),d2-d7/a2-a3
	unlk	a6
	rts
load_gsp_program:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	movea.l	($8,a6),a2
	jsr	init_gsp
	move.w	#$B800,GSP_HOST+$8
	move.l	(a2)+,d2
.l2FDEC:
	move.l	d2,d0
	subq.l	#1,d2
	tst.l	d0
	beq.s	.l2FE02
	move.l	a2,-(sp)
	jsr	load_gsp_section
	movea.l	d0,a2
	addq.l	#4,sp
	bra.s	.l2FDEC
.l2FE02:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
load_gsp_section:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	moveq	#$20,d2
	move.l	(a2)+,d0
	move.l	(a2)+,d3
	move.l	d0,GSP_HOST+$2
	bra.s	.l2FE32
.l2FE26:
	move.l	(a2)+,-(sp)
	jsr	write_gsp_long
	addq.l	#4,sp
	sub.l	d2,d3
.l2FE32:
	cmp.l	d2,d3
	bge.s	.l2FE26
	tst.l	d3
	beq.s	.l2FE52
	moveq	#$10,d0
	cmp.l	d3,d0
	beq.s	.l2FE46
	jsr	soft_reset
.l2FE46:
	movea.l	a2,a0
	addq.l	#4,a2
	move.w	($2,a0),GSP_HOST+$C
.l2FE52:
	move.l	a2,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
write_gsp_long:
	link	a6,#$0
	lea	($8,a6),a0
	addq.l	#2,a0
	move.w	(a0),GSP_HOST+$C
	move.w	($8,a6),GSP_HOST+$C
	unlk	a6
	rts
dat_2FE7A:
	incbin	"../../build/stunrun-68k.bin",$2FE7A,$114
sub_2FF8E:
	link	a6,#$FFFC
	movem.l	a2-a4,-(sp)
	movea.l	#sub_23C9A,a4
	lea	(-$4,a6),a3
	movea.l	a3,a2
	addq.l	#3,a2
	jsr	(a4)
	move.b	d0,(a2)
	movea.l	a3,a2
	addq.l	#2,a2
	jsr	(a4)
	move.b	d0,(a2)
	movea.l	a3,a2
	addq.l	#1,a2
	jsr	(a4)
	move.b	d0,(a2)
	jsr	(a4)
	move.b	d0,(a3)
	move.l	(-$4,a6),d0
	movem.l	(-$10,a6),a2-a4
	unlk	a6
	rts
dat_2FFCA:
	incbin	"../../build/stunrun-68k.bin",$2FFCA,$26
sub_2FFF0:
	link	a6,#$0
	jsr	sub_23D8C
	jsr	sub_20430
	addq.w	#1,ram_FFDB4A
	unlk	a6
	rts
dat_3000A:
	incbin	"../../build/stunrun-68k.bin",$3000A,$8
	assert	*=$030012,"game/code_02C0D2.asm does not end at 030012"
