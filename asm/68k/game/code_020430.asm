; game/code_020430.asm, 020430-024306: game program code (pair S) with the data,
; text and tables that lie between its routines; the first routine is sub_20430. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 020430 024306 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$020430,"game/code_020430.asm misplaced"
sub_20430:
	move.l	d2,-(sp)
	lea	ram_FF9000,a0
	move.w	ram_FFDAEE,d2
	bne.s	.l20446
	move.b	#$FF,d2
	bra.s	loc_2045E
.l20446:
	move.b	PORT0+$1,d2
	bset	#$5,d2
	btst	#$2,BUTTONS+$1
	bra.s	loc_2045E
dat_2045A:
	incbin	"../../build/stunrun-68k.bin",$2045A,$4
loc_2045E:
	moveq	#$0,d0
.l20460:
	asl.l	#2,d0
	move.b	($3,a0),d1
	asl.b	#1,d2
	bcs.s	.l20474
	clr.b	d1
	move.b	(a0),d0
	beq.s	.l2049A
	subq.b	#1,d0
	bra.s	.l20494
.l20474:
	move.b	(a0),d0
	cmp.b	#$C4,d0
	bcc.s	.l20490
	addi.b	#$20,d1
	bcc.s	.l20494
	tst.b	d0
	beq.s	.l20490
	addi.l	#$10000,d0
	addq.b	#1,($6,a0)
.l20490:
	move.b	#$C8,d0
.l20494:
	move.b	d1,($3,a0)
	move.b	d0,(a0)
.l2049A:
	addq.l	#1,a0
	cmpa.l	#$FF9003,a0
	bcs.s	.l20460
	clr.w	d0
	swap	d0
	beq.s	.l204BE
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	jsr	sub_418B8
	addq.l	#4,sp
	movea.l	(sp)+,a0
	addq.b	#1,ram_FF948F
.l204BE:
	subq.b	#1,($6,a0)
	bcc.s	.l2051C
	move.b	#$7,($6,a0)
	moveq	#-$1,d1
	moveq	#$2,d2
	lea	($6,a0),a0
.l204D2:
	move.b	-(a0),d0
	beq.s	.l204E2
	move.w	d2,d1
	subi.b	#$10,d0
	bcs.s	.l204E2
	move.b	d0,(a0)
	bra.s	.l204F0
.l204E2:
	dbf	d2,.l204D2
	tst.w	d1
	bmi.s	.l204F0
	addi.b	#$EF,($0,a0,d1.w)
.l204F0:
	lea	ram_FF9006,a0
	lea	WR0_LATCH+$C,a1
	moveq	#$1,d1
.l204FE:
	tst.b	(a0)+
	bmi.s	.l20506
	move.w	d0,(a1)+
	bra.s	.l2050C
.l20506:
	move.w	d0,($10,a1)
	addq.l	#2,a1
.l2050C:
	dbf	d1,.l204FE
	addq.l	#1,ram_FF9490
	jsr	sub_2053C
.l2051C:
	move.l	(sp)+,d2
	rts
dat_20520:
	incbin	"../../build/stunrun-68k.bin",$20520,$1C
sub_2053C:
	move.l	a2,-(sp)
	lea	ram_FF9498,a2
	addq.l	#1,ram_FF9490
	movea.l	($2A,a2),a0
	move.l	a0,d1
	beq.s	.l205A6
	move.w	($28,a2),d0
	andi.w	#$FFE,d0
	lea	io_FF4001,a1
	adda.w	d0,a1
	cmpm.b	(a0)+,(a1)+
	addq.l	#1,a1
	beq.s	.l20586
	subq.b	#1,($17,a2)
	bcs.s	.l20576
	subq.l	#1,a0
	subq.l	#2,a1
	bra.w	.l20640
.l20576:
	addq.b	#1,ram_FF94B0
	bcc.s	.l2058E
	subq.b	#1,ram_FF94B0
	bra.s	.l2058E
.l20586:
	subq.b	#1,($16,a2)
	bne.w	.l20640
.l2058E:
	cmp.w	#$3C,d0
	bcc.s	.l205A6
	moveq	#$2,d1
	cmp.w	#$1E,d0
	bcs.s	.l2059E
	moveq	#$3,d1
.l2059E:
	lea	($19,a2),a0
	bra.w	.l20624
.l205A6:
	suba.l	a0,a0
	moveq	#$0,d1
	move.b	($4,a2),d1
	cmp.b	($5,a2),d1
	beq.w	.l2066C
	move.l	($6,a2,d1.w),d0
	addq.b	#4,d1
	andi.b	#$C,d1
	move.b	d1,($4,a2)
	rol.l	#8,d0
	move.b	d0,d1
	lsr.l	#8,d0
	movea.l	d0,a0
	movem.l	d1-d6,-(sp)
	moveq	#$0,d2
	moveq	#$0,d3
	moveq	#$0,d4
	moveq	#$0,d5
	moveq	#$0,d6
	lea	(dat_206D8,pc),a1
	move.w	(a1)+,d1
.l205E0:
	move.b	(a0)+,d0
	move.b	d0,($19,a2,d1.w)
	lsr.b	#1,d1
	bcc.s	.l205EC
	eor.b	d0,d2
.l205EC:
	lsr.b	#1,d1
	bcc.s	.l205F2
	eor.b	d0,d3
.l205F2:
	lsr.b	#1,d1
	bcc.s	.l205F8
	eor.b	d0,d4
.l205F8:
	lsr.b	#1,d1
	bcc.s	.l205FE
	eor.b	d0,d5
.l205FE:
	eor.b	d0,d6
	move.b	(a1)+,d1
	bpl.s	.l205E0
	eor.b	d5,d6
	move.b	d5,($21,a2)
	eor.b	d4,d6
	move.b	d4,($1D,a2)
	lea	($1C,a2),a0
	eor.b	d3,d6
	move.b	d3,-(a0)
	eor.b	d2,d6
	move.b	d2,-(a0)
	not.b	d6
	move.b	d6,-(a0)
	movem.l	(sp)+,d1-d6
.l20624:
	move.l	d1,d0
	asl.w	#4,d0
	sub.w	d1,d0
	add.w	d0,d0
	lea	io_FF4001,a1
	adda.w	d0,a1
	move.b	#$F,($16,a2)
	move.b	#$4,($17,a2)
.l20640:
	move.b	(a0),d1
	cmp.b	(a1),d1
	beq.w	.l206CC
	move.w	sr,d0
	ori	#$700,sr
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	move.b	d1,(a1)
	clr.w	SOUND_RESET+$18
	clr.w	SOUND_RESET+$A
	move.w	d0,sr
	bra.s	.l206CC
.l2066C:
	move.l	($0,a2),d1
	beq.s	.l206CC
	moveq	#$1F,d0
.l20674:
	asl.l	#1,d1
	dbcs	d0,.l20674
	moveq	#$1,d1
	asl.l	d0,d1
	not.l	d1
	and.l	d1,($0,a2)
	move.l	d0,d1
	cmp.w	#$2,d0
	blt.s	.l206A4
	bgt.s	.l2069A
	movea.l	ram_FF9494,a1
	move.b	($13,a1),d1
	bra.s	.l206A4
.l2069A:
	cmp.w	#$6,d0
	bge.s	.l206A2
	subq.w	#6,d0
.l206A2:
	addq.w	#5,d0
.l206A4:
	mulu.w	#$A,d0
	add.l	ram_FF9494,d0
	andi.l	#$FFFFFF,d0
	ror.l	#8,d1
	or.l	d1,d0
	moveq	#$0,d1
	move.b	($5,a2),d1
	move.l	d0,($6,a2,d1.w)
	addq.b	#4,d1
	andi.b	#$C,d1
	move.b	d1,($5,a2)
.l206CC:
	move.w	a1,($28,a2)
	move.l	a0,($2A,a2)
	movea.l	(sp)+,a2
	rts
dat_206D8:
	incbin	"../../build/stunrun-68k.bin",$206D8,$C
loc_206E4:
	movea.l	a2,a1
	movem.l	(sp)+,d2-d5/a2-a3
	tst.b	ram_FF9492
	bne.w	.l206FE
	tst.b	ram_FF94B0
	bpl.w	loc_20726
.l206FE:
	moveq	#-$1,d0
	rts
sub_20702:
	bra.s	loc_20708
dat_20704:
	incbin	"../../build/stunrun-68k.bin",$20704,$4
loc_20708:
	moveq	#$7,d0
	and.b	dat_20419,d0
	mulu.w	#$14,d0
	addi.w	#$6E,d0
	movea.l	(sp)+,a0
	suba.l	d0,sp
	move.l	sp,ram_FF9494
	movea.l	sp,a1
	move.l	a0,-(sp)
loc_20726:
	movem.l	d2-d5/a2-a3,-(sp)
	movea.l	a1,a2
	lea	io_FF4001,a3
	moveq	#$0,d2
	moveq	#$0,d3
.l20736:
	bsr.w	sub_2086C
	beq.w	.l2078C
	move.l	d0,d5
	bmi.w	.l2075A
	move.l	d3,d0
	mulu.w	#$A,d0
	lea	(-$A,a2,d0.w),a0
	lea	($14,a2),a1
	moveq	#$9,d0
.l20754:
	move.b	(a0)+,(a1)+
	dbf	d0,.l20754
.l2075A:
	addq.l	#1,d2
	subq.l	#1,d3
	bsr.w	sub_2086C
	bpl.w	.l20782
	tst.l	d5
	bmi.w	loc_2093E
	move.l	d3,d0
	mulu.w	#$A,d0
	lea	(-$A,a2,d0.w),a1
	lea	($14,a2),a0
	moveq	#$9,d0
.l2077C:
	move.b	(a0)+,(a1)+
	dbf	d0,.l2077C
.l20782:
	subq.l	#3,d2
	move.l	d2,d0
	bsr.w	sub_2099E
	addq.l	#1,d2
.l2078C:
	cmp.w	#$2,d2
	bcs.s	.l20736
	moveq	#$2,d3
	move.b	($13,a2),d2
	moveq	#$21,d0
	sub.b	dat_20418,d0
	cmp.b	d2,d0
	bcc.s	.l207A6
	moveq	#$0,d2
.l207A6:
	moveq	#$7,d0
	and.b	dat_20419,d0
	add.w	d0,d0
	addq.w	#6,d0
	cmp.b	d0,d2
	bcc.s	.l207C0
	move.b	d0,($13,a2)
.l207BA:
	bsr.w	sub_20976
	bra.s	.l207D0
.l207C0:
	bsr.w	sub_2086C
	beq.s	.l207D0
	bmi.s	.l207BA
	move.l	d2,d0
	subq.l	#1,d0
	bsr.w	sub_2099E
.l207D0:
	move.b	($A,a2),d0
	not.l	d0
	cmp.b	($B,a2),d0
	beq.s	.l207E6
	clr.b	($A,a2)
	move.b	#$FF,($B,a2)
.l207E6:
	move.w	#$4F,d0
.l207EA:
	clr.b	($1E,a2,d0.w)
	dbf	d0,.l207EA
	moveq	#$4,d2
	moveq	#$3,d3
	moveq	#$0,d5
.l207F8:
	bsr.w	sub_2086C
	beq.s	.l20808
	or.l	d0,d5
	move.w	d2,d0
	subq.w	#1,d0
	bsr.w	sub_2099E
.l20808:
	move.w	d2,d0
	subq.w	#4,d0
	cmp.w	#$2,d0
	bne.s	.l20814
	addq.w	#6,d3
.l20814:
	cmp.w	#$6,d2
	bcs.s	.l207F8
	tst.l	d5
	bpl.w	.l20824
	bsr.w	sub_20966
.l20824:
	moveq	#$7,d4
	and.b	dat_20419,d4
	beq.s	.l20852
	add.l	d4,d4
	subq.l	#1,d4
.l20832:
	bsr.w	sub_2086C
	beq.w	.l2084E
	bpl.w	.l20846
	bsr.w	sub_209AA
	bra.w	.l20852
.l20846:
	move.l	d2,d0
	subq.l	#1,d0
	bsr.w	sub_2099E
.l2084E:
	dbf	d4,.l20832
.l20852:
	bsr.w	sub_209F2
	beq.w	.l20864
	moveq	#$1,d0
	bsr.w	sub_2099E
	bra.w	loc_209D6
.l20864:
	movem.l	(sp)+,d2-d5/a2-a3
	moveq	#$0,d0
	rts
sub_2086C:
	moveq	#$A,d0
	mulu.w	d3,d0
	lea	($0,a2,d0.w),a1
	move.l	d2,d0
	asl.w	#4,d0
	sub.w	d2,d0
	add.w	d0,d0
	lea	($0,a3,d0.w),a0
	movem.l	d2-d6/a1/a4,-(sp)
	move.b	(a0),d6
	not.b	d6
	move.b	($10,a0),d5
	eor.b	d5,d6
	move.b	($8,a0),d4
	eor.b	d4,d6
	move.b	($4,a0),d3
	eor.b	d3,d6
	move.b	($2,a0),d2
	eor.b	d2,d6
	lea	(dat_206D8,pc),a4
	move.w	(a4)+,d1
.l208A6:
	add.w	d1,d1
	move.b	($0,a0,d1.w),d0
	move.b	d0,(a1)+
	lsr.b	#2,d1
	bcc.s	.l208B4
	eor.b	d0,d2
.l208B4:
	lsr.b	#1,d1
	bcc.s	.l208BA
	eor.b	d0,d3
.l208BA:
	lsr.b	#1,d1
	bcc.s	.l208C0
	eor.b	d0,d4
.l208C0:
	lsr.b	#1,d1
	bcc.s	.l208C6
	eor.b	d0,d5
.l208C6:
	eor.b	d0,d6
	move.b	(a4)+,d1
	bpl.s	.l208A6
	moveq	#$0,d1
	move.b	d6,d0
	or.b	d2,d0
	or.b	d3,d0
	or.b	d4,d0
	or.b	d5,d0
	beq.s	.l20922
	moveq	#$1,d1
	lea	(dat_2092E,pc),a4
.l208E0:
	moveq	#$0,d0
	lsr.b	#1,d6
	roxl.w	#1,d0
	lsr.b	#1,d5
	roxl.w	#1,d0
	lsr.b	#1,d4
	roxl.w	#1,d0
	lsr.b	#1,d3
	roxl.w	#1,d0
	lsr.b	#1,d2
	roxl.w	#1,d0
	beq.s	.l2091A
	addq.w	#1,($E,a2)
	bcc.s	.l20902
	subq.w	#1,($E,a2)
.l20902:
	btst	#$4,d0
	bne.s	.l20910
	ori.l	#$80000000,d1
	bra.s	.l2091A
.l20910:
	move.b	(-$10,a4,d0.w),d0
	bmi.s	.l2091A
	eor.b	d1,(-$A,a1,d0.w)
.l2091A:
	add.b	d1,d1
	bcc.s	.l208E0
	move.b	#$1,d1
.l20922:
	movem.l	(sp)+,d2-d6/a1/a4
	addq.l	#1,d2
	addq.l	#1,d3
	move.l	d1,d0
	rts
dat_2092E:
	incbin	"../../build/stunrun-68k.bin",$2092E,$10
loc_2093E:
	move.w	dat_2041A,($C,a2)
	move.w	#$FF,($A,a2)
	moveq	#$7,d0
	and.b	dat_20419,d0
	add.w	d0,d0
	addq.w	#6,d0
	move.b	d0,($13,a2)
	bsr.s	sub_20966
	bsr.s	sub_209AA
	bsr.s	sub_20976
	bra.w	loc_209D6
sub_20966:
	move.w	#$4F,d0
.l2096A:
	clr.b	($1E,a2,d0.w)
	dbf	d0,.l2096A
	moveq	#$30,d1
	bra.s	loc_209A2
sub_20976:
	moveq	#$9,d0
.l20978:
	clr.b	($0,a2,d0.w)
	dbf	d0,.l20978
	moveq	#$2,d0
.l20982:
	clr.b	($10,a2,d0.w)
	dbf	d0,.l20982
	moveq	#$9,d0
.l2098C:
	clr.b	($14,a2,d0.w)
	dbf	d0,.l2098C
	move.b	#$7,d1
	bra.s	loc_209A2
dat_2099A:
	incbin	"../../build/stunrun-68k.bin",$2099A,$4
sub_2099E:
	moveq	#$1,d1
	asl.l	d0,d1
loc_209A2:
	or.l	d1,ram_FF9498
	rts
sub_209AA:
	moveq	#$7,d0
	and.b	dat_20419,d0
	bne.s	.l209B6
	rts
.l209B6:
	add.w	d0,d0
	moveq	#$1,d1
	asl.l	d0,d1
	subq.w	#1,d1
	lea	($6E,a2),a1
	mulu.w	#$A,d0
	subq.w	#1,d0
.l209C8:
	clr.b	($0,a1,d0.w)
	dbf	d0,.l209C8
	moveq	#$6,d0
	asl.l	d0,d1
	bra.s	loc_209A2
loc_209D6:
	bsr.w	sub_2053C
	move.l	#$1A0A,d0
.l209E0:
	subq.l	#1,d0
	bne.s	.l209E0
	move.w	d0,WATCHDOG
	bsr.s	sub_209F2
	bne.s	loc_209D6
	bra.w	loc_206E4
sub_209F2:
	lea	ram_FF9498,a1
	move.l	($0,a1),d0
	moveq	#$0,d1
	move.b	($5,a1),d1
	sub.b	($4,a1),d1
	or.l	d1,d0
	or.l	($2A,a1),d0
	beq.s	.l20A10
	moveq	#$1,d0
.l20A10:
	rts
dat_20A12:
	incbin	"../../build/stunrun-68k.bin",$20A12,$74
sub_20A86:
	moveq	#$7,d0
	and.b	dat_20419,d0
	move.w	($6,sp),d1
	cmp.w	d0,d1
	bcc.s	loc_20AB8
	move.w	($A,sp),d0
	cmp.w	#$14,d0
	bcc.s	loc_20ABC
	movea.l	ram_FF9494,a0
	mulu.w	#$14,d1
	adda.w	d0,a0
	adda.w	#$6E,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	rts
loc_20AB8:
	moveq	#-$2,d0
	rts
loc_20ABC:
	moveq	#-$1,d0
	rts
sub_20AC0:
	moveq	#$7,d0
	and.b	dat_20419,d0
	move.w	($6,sp),d1
	cmp.w	d0,d1
	bcc.s	loc_20AB8
	move.w	($A,sp),d0
	cmp.w	#$14,d0
	bcc.s	loc_20ABC
	movea.l	ram_FF9494,a0
	adda.w	#$6E,a0
	adda.w	d0,a0
	move.l	#$C0,d0
	add.w	d1,d1
	asl.l	d1,d0
	or.l	d0,ram_FF9498
	mulu.w	#$A,d1
	moveq	#$0,d0
	move.b	($F,sp),($0,a0,d1.w)
	rts
sub_20B04:
	moveq	#$7,d0
	and.b	dat_20419,d0
	move.w	($6,sp),d1
	cmp.w	d0,d1
	bcc.s	loc_20AB8
	move.w	($A,sp),d0
	cmp.w	#$14,d0
	bcc.s	loc_20ABC
	movea.l	ram_FF9494,a0
	adda.w	#$6E,a0
	adda.w	d0,a0
	move.l	#$C0,d0
	add.w	d1,d1
	asl.l	d1,d0
	or.l	d0,ram_FF9498
	mulu.w	#$A,d1
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	add.w	($E,sp),d0
	move.b	d0,($0,a0,d1.w)
	rts
sub_20B4E:
	move.l	($4,sp),d0
	cmp.b	#$F,d0
	bcs.s	.l20B5C
	moveq	#-$1,d0
	rts
.l20B5C:
	movea.l	ram_FF9494,a0
	lea	dat_20520,a1
	add.w	d0,d0
	adda.w	d0,a1
	moveq	#$1F,d1
	and.b	(a1),d1
	cmp.b	#$18,d0
	beq.s	.l20BA0
	move.b	($0,a0,d1.w),d0
	asl.w	#8,d0
	move.b	($1,a0,d1.w),d0
	move.b	(a1)+,d1
	bmi.s	.l20B94
	add.b	d1,d1
	bmi.s	.l20B92
	add.b	d1,d1
	bmi.s	.l20B90
	lsr.w	#8,d0
	bra.s	.l20B94
.l20B90:
	asl.w	#4,d0
.l20B92:
	lsr.w	#4,d0
.l20B94:
	move.b	(a1),d1
	bmi.s	.l20B9E
	asl.l	#8,d0
	move.b	($14,a0,d1.w),d0
.l20B9E:
	rts
.l20BA0:
	move.b	($0,a0,d1.w),d0
	move.b	($1,a0,d1.w),d1
	eor.b	d0,d1
	cmp.b	#$FF,d1
	beq.s	.l20B9E
	moveq	#$0,d0
	rts
sub_20BB4:
	move.l	($4,sp),d1
	cmp.b	#$F,d1
	bcs.s	.l20BC2
	moveq	#-$1,d0
	rts
.l20BC2:
	movea.l	ram_FF9494,a0
	move.l	($8,sp),d0
	cmp.b	#$C,d1
	bne.s	.l20BDE
	asl.w	#8,d0
	move.b	($B,sp),d0
	eori.b	#$FF,d0
	bra.s	.l20BF0
.l20BDE:
	cmp.b	#$E,d1
	bne.s	.l20BF0
	move.l	a2,-(sp)
	movea.l	a0,a2
	bsr.w	sub_209AA
	movea.l	(sp)+,a2
	rts
.l20BF0:
	pea	$0.w
	lea	dat_20520,a1
	add.w	d1,d1
	adda.w	d1,a1
	move.b	($1,a1),d1
	bmi.s	.l20C10
	move.b	d0,($14,a0,d1.w)
	lsr.l	#8,d0
	bset	#$2,($3,sp)
.l20C10:
	move.b	(a1),d1
	bclr	#$7,d1
	beq.s	.l20C24
	move.b	d0,($1,a0,d1.w)
	lsr.w	#8,d0
	move.b	d0,($0,a0,d1.w)
	bra.s	.l20C5E
.l20C24:
	bclr	#$6,d1
	beq.s	.l20C3E
	asl.w	#4,d0
	andi.b	#$F,($1,a0,d1.w)
	or.b	d0,($1,a0,d1.w)
	lsr.w	#8,d0
	move.b	d0,($0,a0,d1.w)
	bra.s	.l20C5E
.l20C3E:
	bclr	#$5,d1
	beq.s	.l20C5A
	move.b	d0,($1,a0,d1.w)
	lsr.w	#8,d0
	andi.b	#$F,d0
	andi.b	#$F0,($0,a0,d1.w)
	or.b	d0,($0,a0,d1.w)
	bra.s	.l20C5E
.l20C5A:
	move.b	d0,($0,a0,d1.w)
.l20C5E:
	move.l	(sp)+,d1
	ori.w	#$3,d1
	or.l	d1,ram_FF9498
	moveq	#$0,d0
	rts
sub_20C6E:
	move.l	($4,sp),d1
	cmp.b	#$F,d1
	bcs.s	.l20C7C
	moveq	#-$1,d0
	rts
.l20C7C:
	cmp.b	#$C,d1
	beq.s	.l20C88
	cmp.b	#$E,d1
	bne.s	.l20C8C
.l20C88:
	moveq	#-$2,d0
	rts
.l20C8C:
	move.l	($8,sp),d0
	movea.l	ram_FF9494,a0
	lea	dat_20520,a1
	add.w	d1,d1
	adda.w	d1,a1
	move.b	($1,a1),d1
	bmi.s	.l20CC0
	bset	#$2,ram_FF949B
	add.b	d0,($14,a0,d1.w)
	bcc.s	.l20CBA
	addi.l	#$100,d0
.l20CBA:
	lsr.l	#8,d0
	beq.w	.l20D54
.l20CC0:
	move.b	(a1),d1
	bclr	#$7,d1
	beq.s	.l20CDA
	add.b	d0,($1,a0,d1.w)
	bcc.s	.l20CD2
	addi.w	#$100,d0
.l20CD2:
	lsr.w	#8,d0
	add.b	d0,($0,a0,d1.w)
	bra.s	.l20D1E
.l20CDA:
	bclr	#$6,d1
	beq.s	.l20CF4
	asl.w	#4,d0
	add.b	d0,($1,a0,d1.w)
	bcc.s	.l20CEC
	addi.w	#$100,d0
.l20CEC:
	lsr.w	#8,d0
	add.b	d0,($0,a0,d1.w)
	bra.s	.l20D1E
.l20CF4:
	bclr	#$5,d1
	beq.s	.l20D1A
	add.b	d0,($1,a0,d1.w)
	bcc.s	.l20D04
	addi.w	#$100,d0
.l20D04:
	lsr.w	#8,d0
	add.b	($0,a0,d1.w),d0
	andi.b	#$F0,($0,a0,d1.w)
	andi.b	#$F,d0
	or.b	d0,($0,a0,d1.w)
	bra.s	.l20D1E
.l20D1A:
	add.b	d0,($0,a0,d1.w)
.l20D1E:
	moveq	#$0,d0
	moveq	#$3,d1
	cmpi.w	#$6,($6,sp)
	bne.s	.l20D4E
	addq.b	#1,($13,a0)
	moveq	#$21,d1
	sub.b	dat_20418,d1
	cmp.b	($13,a0),d1
	bcc.s	.l20D4C
	moveq	#$7,d1
	and.b	dat_20419,d1
	add.w	d1,d1
	addq.w	#6,d1
	move.b	d1,($13,a0)
.l20D4C:
	moveq	#$7,d1
.l20D4E:
	or.l	d1,ram_FF9498
.l20D54:
	rts
dat_20D56:
	incbin	"../../build/stunrun-68k.bin",$20D56,$5E
str_20DB4:
	dc.b	'Nu ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:;<2/',0
dat_20DE1:
	incbin	"../../build/stunrun-68k.bin",$20DE1,$EF
dat_20ED0:
	incbin	"../../build/stunrun-68k.bin",$20ED0,$1
str_20ED1:
	dc.b	'GAME DIFFICULTY',0
str_20EE1:
	dc.b	'VERY EASY',0
dat_20EEB:
	incbin	"../../build/stunrun-68k.bin",$20EEB,$5
str_20EF0:
	dc.b	'MEDIUM EASY',0
str_20EFC:
	dc.b	'MEDIUM',0
str_20F03:
	dc.b	'MEDIUM HARD',0
dat_20F0F:
	incbin	"../../build/stunrun-68k.bin",$20F0F,$5
str_20F14:
	dc.b	'VERY HARD',0
dat_20F1E:
	incbin	"../../build/stunrun-68k.bin",$20F1E,$7
str_20F25:
	dc.b	'CONTINUE IS ONE COIN LESS THAN START',0
dat_20F4A:
	incbin	"../../build/stunrun-68k.bin",$20F4A,$8
str_20F52:
	dc.b	'SOUNDS IN ATTRACT',0
dat_20F64:
	incbin	"../../build/stunrun-68k.bin",$20F64,$8
str_20F6C:
	dc.b	'AUTO RESET HIGH SCORES',0
dat_20F83:
	incbin	"../../build/stunrun-68k.bin",$20F83,$8
str_20F8B:
	dc.b	'HIGH SCORE NAME CENSOR',0
str_20FA2:
	dc.b	'EASYGOING',0
str_20FAC:
	dc.b	'STRICT',0
dat_20FB3:
	incbin	"../../build/stunrun-68k.bin",$20FB3,$1
str_20FB4:
	dc.b	'T-SHIRT CONTEST',0
str_20FC4:
	dc.b	'DISABLED',0
str_20FCD:
	dc.b	'ENABLED',0
str_20FD5:
	dc.b	'vCONTINUE ADVANCES TO NEXT LEVEL',0
dat_20FF6:
	incbin	"../../build/stunrun-68k.bin",$20FF6,$6
str_20FFC:
	dc.b	'ALWAYS',0
str_21003:
	dc.b	'AFTER 1 RETRY',0
str_21011:
	dc.b	'AFTER 2 RETRIES',0
dat_21021:
	incbin	"../../build/stunrun-68k.bin",$21021,$3
dat_21024:
	incbin	"../../build/stunrun-68k.bin",$21024,$1
str_21025:
	dc.b	'GAME DIFFICULTY',0
str_21035:
	dc.b	'VERY EASY',0
dat_2103F:
	incbin	"../../build/stunrun-68k.bin",$2103F,$5
str_21044:
	dc.b	'MEDIUM EASY',0
str_21050:
	dc.b	'MEDIUM',0
str_21057:
	dc.b	'MEDIUM HARD',0
dat_21063:
	incbin	"../../build/stunrun-68k.bin",$21063,$5
str_21068:
	dc.b	'VERY HARD',0
dat_21072:
	incbin	"../../build/stunrun-68k.bin",$21072,$7
str_21079:
	dc.b	'SOUNDS IN ATTRACT',0
dat_2108B:
	incbin	"../../build/stunrun-68k.bin",$2108B,$8
str_21093:
	dc.b	'AUTO RESET HIGH SCORES',0
dat_210AA:
	incbin	"../../build/stunrun-68k.bin",$210AA,$8
str_210B2:
	dc.b	'HIGH SCORE NAME CENSOR',0
str_210C9:
	dc.b	'EASYGOING',0
str_210D3:
	dc.b	'STRICT',0
dat_210DA:
	incbin	"../../build/stunrun-68k.bin",$210DA,$1
str_210DB:
	dc.b	'T-SHIRT CONTEST',0
str_210EB:
	dc.b	'DISABLED',0
str_210F4:
	dc.b	'ENABLED',0
str_210FC:
	dc.b	'vCONTINUE ADVANCES TO NEXT LEVEL',0
dat_2111D:
	incbin	"../../build/stunrun-68k.bin",$2111D,$6
str_21123:
	dc.b	'ALWAYS',0
str_2112A:
	dc.b	'AFTER 1 RETRY',0
str_21138:
	dc.b	'AFTER 2 RETRIES',0
dat_21148:
	incbin	"../../build/stunrun-68k.bin",$21148,$30
sub_21178:
	move.w	($6,sp),d1
.l2117C:
	move.l	#$208D,d0
.l21182:
	subq.l	#1,d0
	bpl.s	.l21182
	clr.w	WATCHDOG
	dbf	d1,.l2117C
	rts
dat_21192:
	incbin	"../../build/stunrun-68k.bin",$21192,$60
sub_211F2:
	move.l	d2,-(sp)
	move.w	($12,sp),d0
	movea.l	($C,sp),a0
	movea.l	a0,a1
	adda.w	d0,a0
	clr.b	(a0)
	subq.w	#1,d0
	moveq	#$0,d2
	tst.w	($16,sp)
	bne.s	.l21210
	bset	#$1F,d2
.l21210:
	move.l	($8,sp),d1
	cmp.l	#$1869F,d1
	ble.s	.l2122A
	lsr.l	#1,d1
	divu.w	#$C350,d1
	move.w	d1,d2
	clr.w	d1
	swap	d1
	addx.l	d1,d1
.l2122A:
	cmp.w	#$4,d0
	ble.s	.l2123A
	moveq	#$4,d0
	bra.s	.l2123A
.l21234:
	clr.w	d1
	swap	d1
	beq.s	.l21260
.l2123A:
	divu.w	#$A,d1
	swap	d1
.l21240:
	addi.b	#$30,d1
	move.b	d1,-(a0)
	dbf	d0,.l21234
	cmpa.l	a1,a0
	beq.s	.l21282
	move.l	d2,d1
	bmi.s	.l21254
	moveq	#$0,d2
.l21254:
	swap	d1
	move.w	($12,sp),d0
	subq.w	#6,d0
	bpl.s	.l21234
	bra.s	.l21282
.l21260:
	tst.l	d2
	bne.s	.l21240
	move.w	($16,sp),d1
	subq.w	#1,d1
	beq.s	.l2127A
.l2126C:
	move.b	(a0)+,(a1)+
	bne.s	.l2126C
	movea.l	($C,sp),a0
	adda.w	($12,sp),a0
	subq.l	#1,a1
.l2127A:
	moveq	#$20,d1
.l2127C:
	move.b	d1,-(a0)
	cmpa.l	a0,a1
	bne.s	.l2127C
.l21282:
	move.l	(sp)+,d2
	rts
soft_reset:
	stop	#$2700
sub_2128A:
	movea.l	vec_reset_sp.w,sp
	move.w	#$2700,sr
	movea.l	#$0,a0
	movec	a0,vbr
	move.w	#$4,ADSP_CONTROL+$40
	clr.l	(ram_FF8018-ABS_SHORT).w
	movea.l	vec_reset_pc.w,a0
	jmp	(a0)
game_reset:
	clr.w	WATCHDOG
	move.w	#$2700,sr
	move.w	#$4,ADSP_CONTROL+$40
	cmpi.l	#$31415982,(ram_FF8018-ABS_SHORT).w
	bne.s	.l212FA
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	addq.b	#1,io_FF4B90
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	pea	io_FF4BA4
	pea	io_FF4B90
	jsr	sub_2EFB6
.l212FA:
	lea	(ram_FF8000-ABS_SHORT).w,a0
	move.w	#$1FFF,d0
.l21302:
	clr.l	(a0)+
	dbf	d0,.l21302
	clr.w	WATCHDOG
	move.l	#$31415982,(ram_FF8018-ABS_SHORT).w
	jsr	clear_gsp_vram
	jsr	clear_msp_ram
	jsr	sub_20702
	jsr	sub_24306
	jmp	soft_reset
game_entry_1:
	clr.w	WATCHDOG
	move.w	#$2700,sr
	move.w	#$4,ADSP_CONTROL+$40
	lea	(ram_FF8000-ABS_SHORT).w,a0
	move.w	#$1FFF,d0
.l2134E:
	clr.l	(a0)+
	dbf	d0,.l2134E
	clr.w	WATCHDOG
	jsr	clear_gsp_vram
	jsr	clear_msp_ram
	jsr	sub_20702
	jsr	sub_2DCE0
	jmp	soft_reset
game_entry_2:
	clr.w	WATCHDOG
	move.w	#$2700,sr
	move.w	#$4,ADSP_CONTROL+$40
	lea	(ram_FF8000-ABS_SHORT).w,a0
	move.w	#$1FFF,d0
.l21392:
	clr.l	(a0)+
	dbf	d0,.l21392
	clr.w	WATCHDOG
	jsr	clear_gsp_vram
	jsr	sub_20702
	jsr	audio_test
	jmp	soft_reset
game_entry_3:
	clr.w	WATCHDOG
	move.w	#$2700,sr
	move.w	#$4,ADSP_CONTROL+$40
	lea	(ram_FF8000-ABS_SHORT).w,a0
	move.w	#$1FFF,d0
.l213D0:
	clr.l	(a0)+
	dbf	d0,.l213D0
	clr.w	WATCHDOG
	jsr	clear_gsp_vram
	jsr	sub_20702
	jsr	sub_3CE64
	jmp	soft_reset
dat_213F4:
	incbin	"../../build/stunrun-68k.bin",$213F4,$A
h_level2_adsp:
	movem.l	d0-d1/a0-a1,-(sp)
	clr.w	ADSP_IRQ_CLEAR
	jsr	sub_2E418
	clr.w	ADSP_CONTROL+$10
	movem.l	(sp)+,d0-d1/a0-a1
	rte
stop_adsp:
	clr.w	ADSP_CONTROL+$1C
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_IRQ_CLEAR
	clr.w	ADSP_CONTROL+$14
	move.w	#$4,ADSP_CONTROL+$40
	rts
h_level3_gsp:
	move.w	#$FFFF,ram_FFDB48
	move.l	d0,-(sp)
	andi.w	#$FF7F,GSP_HOST+$8
	move.l	(ram_FF8014-ABS_SHORT).w,d0
	sub.l	ram_FFDB36,d0
	move.l	d0,ram_FF9BAA
	move.l	(sp)+,d0
	rte
sub_21462:
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	clr.w	d0
	move.l	#$F5000000,GSP_HOST+$2
	move.w	#$FF,d1
.l21492:
	move.w	d0,GSP_HOST+$C
	addi.w	#$101,d0
	dbf	d1,.l21492
	clr.w	d0
	move.l	#$F5800000,GSP_HOST+$2
	move.w	#$FF,d1
.l214B0:
	move.w	d0,GSP_HOST+$C
	addi.w	#$101,d0
	dbf	d1,.l214B0
	rts
dat_214C0:
	incbin	"../../build/stunrun-68k.bin",$214C0,$EA
dat_215AA:
	incbin	"../../build/stunrun-68k.bin",$215AA,$30
dat_215DA:
	incbin	"../../build/stunrun-68k.bin",$215DA,$2
sub_215DC:
	lea	dat_215AA,a0
	move.w	dat_215DA,d0
.l215E8:
	move.l	(a0),GSP_HOST+$2
	move.w	($4,a0),GSP_HOST+$C
	adda.l	#$6,a0
	dbf	d0,.l215E8
	rts
delay:
	move.l	#$96,d0
.l21608:
	subq.w	#1,d0
	bne.s	.l21608
	rts
dat_2160E:
	incbin	"../../build/stunrun-68k.bin",$2160E,$F
dat_2161D:
	incbin	"../../build/stunrun-68k.bin",$2161D,$33
dat_21650:
	incbin	"../../build/stunrun-68k.bin",$21650,$1E
sub_2166E:
	lea	dat_21650,a0
	mulu.w	#$A,d0
	adda.l	d0,a0
	clr.w	d3
	clr.w	d0
	movea.l	(a0),a1
	move.w	($4,a0),d5
.l21684:
	move.b	($0,a1),d0
	clr.w	d1
	move.b	($1,a1),d1
	and.w	d1,d0
	move.b	($2,a1),d2
	lsl.w	d2,d0
	or.w	d0,d3
	adda.w	#$3,a1
	dbf	d5,.l21684
	move.l	($6,a0),GSP_HOST+$2
	move.w	d3,GSP_HOST+$C
	rts
sub_216B0:
	move.l	#$C0000090,GSP_HOST+$2
	moveq	#$0,d0
	lsr.l	#8,d0
	tst.b	dat_2161D
	bne.w	.l216CA
	not.w	d0
.l216CA:
	andi.w	#$FFFC,d0
	ori.w	#$3,d0
	move.w	d0,GSP_HOST+$C
	move.l	#$F4800000,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	rts
sub_216EA:
	move.l	#$C0000150,d0
	move.l	d0,GSP_HOST+$2
	move.w	#$1,GSP_HOST+$C
	rts
fill_gsp_vram:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4000000,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.l	#$2000000,GSP_HOST+$2
	move.w	#$FFFF,d0
	move.w	#$5F,d2
.l2172A:
	move.w	#$FF,d1
.l2172E:
	move.w	d0,GSP_HOST+$C
	dbf	d1,.l2172E
	clr.w	WATCHDOG
	dbf	d2,.l2172A
	rts
dat_21744:
	incbin	"../../build/stunrun-68k.bin",$21744,$B96
h_level5_timer:
	movem.l	d0-d1/a0-a1,-(sp)
	addq.l	#1,(ram_FF8014-ABS_SHORT).w
	jsr	sub_2FFF0
	movem.l	(sp)+,d0-d1/a0-a1
	clr.w	PORT0
	rte
dat_222F4:
	incbin	"../../build/stunrun-68k.bin",$222F4,$7C
reset_gsp:
	clr.w	SOUND_RESET+$C
	bsr.w	delay
	clr.w	SOUND_RESET+$1C
	rts
init_gsp:
	movem.l	d2-d7/a2-a6,-(sp)
	bsr.s	reset_gsp
	move.w	#$2,d0
	bsr.w	sub_2166E
	bsr.w	sub_215DC
	bsr.w	sub_216EA
	bsr.w	sub_216B0
	move.w	#$1,d0
	bsr.w	sub_2166E
	move.w	#$0,d0
	bsr.w	sub_2166E
	bsr.w	sub_21462
	move.l	#$F4800090,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800010,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800090,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	lea	dat_441EC,a0
	adda.l	#$404,a0
	jsr	(a0)
	movem.l	(sp)+,d2-d7/a2-a6
	rts
clear_gsp_vram:
	movea.l	#GSP_HOST+$C,a0
	move.l	#$FF800000,GSP_HOST+$2
	move.w	#$B800,GSP_HOST+$8
	moveq	#$4,d1
	move.l	#$FFFF,d0
	bra.s	.l2241C
.l22416:
	clr.l	(a0)
	dbf	d0,.l22416
.l2241C:
	clr.w	WATCHDOG
	dbf	d1,.l22416
	rts
clear_msp_ram:
	movea.l	#MSP_HOST+$C,a0
	move.l	#$0,MSP_HOST+$2
	move.w	#$B800,MSP_HOST+$8
	move.l	#$8000,d0
	bra.s	loc_22450
dat_22448:
	incbin	"../../build/stunrun-68k.bin",$22448,$6
loc_2244E:
	clr.l	(a0)
loc_22450:
	dbf	d0,loc_2244E
	clr.w	WATCHDOG
	rts
dat_2245C:
	incbin	"../../build/stunrun-68k.bin",$2245C,$C
clear_gsp_screen:
	movem.l	d2-d7/a2-a6,-(sp)
	move.w	#$0,d0
	bsr.w	fill_gsp_vram
	movem.l	(sp)+,d2-d7/a2-a6
	rts
sub_2247A:
	movea.l	($4,sp),a0
	move.l	($8,sp),d1
	movea.l	#GSP_HOST+$C,a1
	move.l	d1,d0
	lsr.l	#1,d1
	bra.s	.l22490
.l2248E:
	move.l	(a0)+,(a1)
.l22490:
	dbf	d1,.l2248E
	btst	#$0,d0
	beq.s	.l2249C
	move.w	(a0)+,(a1)
.l2249C:
	rts
dat_2249E:
	incbin	"../../build/stunrun-68k.bin",$2249E,$24
dat_224C2:
	incbin	"../../build/stunrun-68k.bin",$224C2,$AA
set_sr:
	move.w	($6,sp),d1
	moveq	#$0,d0
	move.w	sr,d0
	move.w	d1,sr
	rts
copy_to_zram:
	clr.l	d0
	movea.l	($4,sp),a0
	movea.l	($8,sp),a1
	move.w	($E,sp),d0
	move.w	sr,d1
	ori	#$700,sr
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	bra.s	.l2259C
.l2259A:
	move.b	(a0)+,(a1)+
.l2259C:
	dbf	d0,.l2259A
	clr.w	SOUND_RESET+$18
	clr.w	SOUND_RESET+$A
	move.w	d1,sr
	rts
sub_225B0:
	lea	ram_FF902A,a1
	moveq	#$0,d0
	moveq	#$F,d1
.l225BA:
	move.b	(a0)+,d0
	move.b	d0,(-$20,a1)
	move.w	d0,(a1)+
	dbf	d1,.l225BA
	lea	ram_FF902A,a1
	rts
loc_225CE:
	jsr	soft_reset
loc_225D4:
	tst.w	d2
	beq.s	.l225DC
	clr.b	d3
	move.w	d3,(a2)
.l225DC:
	move.l	a0,d0
	movem.l	(sp)+,d2-d5/a2-a3
	rts
unpack_gsp_image:
	movea.l	($4,sp),a0
	movem.l	d2-d5/a2-a3,-(sp)
	lea	GSP_HOST+$C,a2
	lea	WATCHDOG,a3
	moveq	#$0,d3
	moveq	#$0,d5
	moveq	#$0,d4
	moveq	#$0,d2
	move.b	(a0)+,d0
	bne.s	loc_225CE
.l22604:
	bsr.s	sub_225B0
.l22606:
	moveq	#$0,d0
	clr.w	(a3)
	move.b	(a0)+,d0
	bclr	#$7,d0
	bne.w	.l226CA
	bclr	#$6,d0
	bne.s	.l22672
	tst.b	d0
	beq.s	.l22604
	tst.w	d2
	beq.s	.l2262C
	move.b	(a0)+,d3
	move.w	d3,(a2)
	moveq	#$0,d2
	subq.w	#1,d0
	beq.s	.l22606
.l2262C:
	move.w	a0,d1
	andi.w	#$1,d1
	beq.s	.l22656
	move.b	d0,d1
	lsr.b	#1,d0
	subq.w	#1,d0
	bmi.s	.l22648
.l2263C:
	move.b	(a0)+,d3
	lsl.w	#8,d3
	move.b	(a0)+,d3
	move.w	d3,(a2)
	dbf	d0,.l2263C
.l22648:
	btst	#$0,d1
	beq.s	.l22606
	move.b	(a0)+,d3
	lsl.l	#8,d3
	not.w	d2
	bra.s	.l22606
.l22656:
	move.b	d0,d1
	lsr.b	#1,d0
	subq.w	#1,d0
	bmi.s	.l2266A
.l2265E:
	move.w	(a0)+,(a2)
	dbf	d0,.l2265E
	btst	#$0,d1
	beq.s	.l22606
.l2266A:
	move.w	(a0),d3
	addq.l	#1,a0
	not.w	d2
	bra.s	.l22606
.l22672:
	subq.w	#1,d0
	bmi.w	loc_225D4
	tst.w	d2
	bne.s	.l226A8
.l2267C:
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d4
	andi.w	#$1E,d4
	andi.w	#$F,d5
	add.w	d5,d5
	move.w	(-$20,a1,d4.w),d3
	move.b	($1,a1,d5.w),d3
	move.w	d3,(a2)
	dbf	d0,.l2267C
	bra.w	.l22606
.l2269E:
	andi.w	#$F,d4
	add.w	d4,d4
	move.w	(-$20,a1,d4.w),d3
.l226A8:
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d5
	andi.w	#$1E,d5
	move.b	($1,a1,d5.w),d3
	move.w	d3,(a2)
	dbf	d0,.l2269E
	andi.w	#$F,d4
	add.w	d4,d4
	move.w	(-$20,a1,d4.w),d3
	bra.w	.l22606
.l226CA:
	bclr	#$6,d0
	bne.w	.l22702
	tst.w	d0
	beq.w	loc_225CE
	move.b	(a0)+,d3
	tst.w	d2
	beq.s	.l226E8
	move.w	d3,(a2)
	moveq	#$0,d2
	subq.w	#1,d0
	beq.w	.l22606
.l226E8:
	lsr.w	#1,d0
	subx.w	d2,d2
	move.w	d3,d5
	lsl.w	#8,d3
	move.b	d5,d3
	subq.w	#1,d0
	bmi.w	.l22606
.l226F8:
	move.w	d3,(a2)
	dbf	d0,.l226F8
	bra.w	.l22606
.l22702:
	tst.w	d0
	beq.w	loc_225CE
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d4
	andi.w	#$1E,d4
	andi.w	#$F,d5
	add.w	d5,d5
	tst.w	d2
	beq.s	.l2273A
	move.b	($1,a1,d4.w),d3
	move.w	d3,(a2)
	move.w	(-$20,a1,d5.w),d3
	move.b	($1,a1,d4.w),d3
	subq.w	#2,d0
	bmi.w	.l22606
.l22730:
	move.w	d3,(a2)
	dbf	d0,.l22730
	bra.w	.l22606
.l2273A:
	move.w	(-$20,a1,d4.w),d3
	move.b	($1,a1,d5.w),d3
	subq.w	#1,d0
	bpl.s	.l22730
	bra.w	.l22606
loc_2274A:
	moveq	#$0,d0
	move.l	d0,ram_FF9BD0
	tst.w	d2
	beq.s	.l2275A
	move.b	d0,d3
	move.w	d3,(a2)
.l2275A:
	move.l	a3,GSP_HOST+$2
loc_22760:
	movem.l	(sp)+,d2-d6/a2-a3
	rts
sub_22766:
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	($20,sp),d6
	lea	GSP_HOST+$C,a2
	lea	ram_FF902A,a1
	moveq	#$0,d5
	moveq	#$0,d4
	move.l	ram_FF9BD0,d0
	movea.l	d0,a0
	bne.s	.l227C0
	move.w	ram_FF9BCC,d0
	beq.s	loc_22760
	move.w	d0,ram_FF9BCE
	asl.w	#2,d0
	lea	tbl_BFE00,a0
	movea.l	($0,a0,d0.w),a0
	move.w	d4,ram_FF9BCC
	move.w	d4,ram_FF9C66
	move.w	d4,ram_FF9C64
	move.l	#$FFE00000,d0
	move.l	d0,ram_FF9BD4
.l227C0:
	movea.l	GSP_HOST+$2,a3
	move.l	ram_FF9BD4,GSP_HOST+$2
	move.w	ram_FF9C66,d2
	move.w	ram_FF9C64,d3
.l227DC:
	subq.l	#1,d6
	bpl.s	.l2280E
	move.l	a0,ram_FF9BD0
	move.w	d2,ram_FF9C66
	move.w	d3,ram_FF9C64
	move.l	GSP_HOST+$2,ram_FF9BD4
	move.l	a3,GSP_HOST+$2
	moveq	#$1,d0
	bra.w	loc_22760
.l22808:
	jsr	sub_225B0
.l2280E:
	moveq	#$0,d0
	move.b	(a0)+,d0
	bclr	#$7,d0
	bne.w	.l228D4
	bclr	#$6,d0
	bne.s	.l2287C
	tst.b	d0
	beq.s	.l22808
	tst.w	d2
	beq.s	.l22832
	move.b	(a0)+,d3
	move.w	d3,(a2)
	moveq	#$0,d2
	subq.w	#1,d0
	beq.s	.l227DC
.l22832:
	move.w	a0,d1
	andi.w	#$1,d1
	beq.s	.l2285C
	move.b	d0,d1
	lsr.b	#1,d0
	subq.w	#1,d0
	bmi.s	.l2284E
.l22842:
	move.b	(a0)+,d3
	lsl.w	#8,d3
	move.b	(a0)+,d3
	move.w	d3,(a2)
	dbf	d0,.l22842
.l2284E:
	btst	#$0,d1
	beq.s	.l227DC
	move.b	(a0)+,d3
	lsl.l	#8,d3
	not.w	d2
	bra.s	.l227DC
.l2285C:
	move.b	d0,d1
	lsr.b	#1,d0
	subq.w	#1,d0
	bmi.s	.l22872
.l22864:
	move.w	(a0)+,(a2)
	dbf	d0,.l22864
	btst	#$0,d1
	beq.w	.l227DC
.l22872:
	move.w	(a0),d3
	addq.l	#1,a0
	not.w	d2
	bra.w	.l227DC
.l2287C:
	subq.w	#1,d0
	bmi.w	loc_2274A
	tst.w	d2
	bne.s	.l228B2
.l22886:
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d4
	andi.w	#$1E,d4
	andi.w	#$F,d5
	add.w	d5,d5
	move.w	(-$20,a1,d4.w),d3
	move.b	($1,a1,d5.w),d3
	move.w	d3,(a2)
	dbf	d0,.l22886
	bra.w	.l227DC
.l228A8:
	andi.w	#$F,d4
	add.w	d4,d4
	move.w	(-$20,a1,d4.w),d3
.l228B2:
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d5
	andi.w	#$1E,d5
	move.b	($1,a1,d5.w),d3
	move.w	d3,(a2)
	dbf	d0,.l228A8
	andi.w	#$F,d4
	add.w	d4,d4
	move.w	(-$20,a1,d4.w),d3
	bra.w	.l227DC
.l228D4:
	bclr	#$6,d0
	bne.w	.l2290C
	tst.w	d0
	beq.w	loc_225CE
	move.b	(a0)+,d3
	tst.w	d2
	beq.s	.l228F2
	move.w	d3,(a2)
	moveq	#$0,d2
	subq.w	#1,d0
	beq.w	.l227DC
.l228F2:
	lsr.w	#1,d0
	subx.w	d2,d2
	move.w	d3,d5
	lsl.w	#8,d3
	move.b	d5,d3
	subq.w	#1,d0
	bmi.w	.l227DC
.l22902:
	move.w	d3,(a2)
	dbf	d0,.l22902
	bra.w	.l227DC
.l2290C:
	tst.w	d0
	beq.w	loc_225CE
	move.b	(a0)+,d4
	move.w	d4,d5
	lsr.b	#3,d4
	andi.w	#$1E,d4
	andi.w	#$F,d5
	add.w	d5,d5
	tst.w	d2
	beq.s	.l22944
	move.b	($1,a1,d4.w),d3
	move.w	d3,(a2)
	move.w	(-$20,a1,d5.w),d3
	move.b	($1,a1,d4.w),d3
	subq.w	#2,d0
	bmi.w	.l227DC
.l2293A:
	move.w	d3,(a2)
	dbf	d0,.l2293A
	bra.w	.l227DC
.l22944:
	move.w	(-$20,a1,d4.w),d3
	move.b	($1,a1,d5.w),d3
	subq.w	#1,d0
	bpl.s	.l2293A
	bra.w	.l227DC
h_bus_error:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_30676
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_trapv:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_30702
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_privilege_violation:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_3071E
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_chk:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_306E6
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_zero_divide:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_306CA
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_illegal_instruction:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_306AE
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_address_error:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_30692
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_level7_nmi:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_30756
	movem.l	(sp)+,d0-d7/a0-a6
	rte
h_trace_etc:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	sub_3073A
	movem.l	(sp)+,d0-d7/a0-a6
	rte
sub_229E4:
	move.w	($6,sp),d0
	move.w	($A,sp),d1
	muls.w	d1,d0
	addi.l	#$2000,d0
	swap	d0
	rol.l	#2,d0
	ext.l	d0
	rts
dat_229FC:
	incbin	"../../build/stunrun-68k.bin",$229FC,$3A
sub_22A36:
	movem.l	d2-d7/a2-a4,-(sp)
	movea.l	($28,sp),a0
	movea.l	($2C,sp),a1
	movea.l	($30,sp),a2
	move.w	($2,a0),d0
	ext.l	d0
	cmp.l	($0,a0),d0
	bne.w	.l22B18
	move.w	($6,a0),d0
	ext.l	d0
	cmp.l	($4,a0),d0
	bne.w	.l22B18
	move.w	($A,a0),d0
	ext.l	d0
	cmp.l	($8,a0),d0
	bne.w	.l22B18
	move.w	($2,a0),d0
	muls.w	($0,a2),d0
	move.w	($6,a0),d1
	muls.w	($6,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($C,a2),d1
	add.l	d1,d0
	bpl.w	.l22A9A
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22AA0
.l22A9A:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22AA0:
	swap	d0
	move.l	d0,($0,a1)
	move.w	($2,a0),d0
	muls.w	($2,a2),d0
	move.w	($6,a0),d1
	muls.w	($8,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($E,a2),d1
	add.l	d1,d0
	bpl.w	.l22AD0
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22AD6
.l22AD0:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22AD6:
	swap	d0
	move.l	d0,($4,a1)
	move.w	($2,a0),d0
	muls.w	($4,a2),d0
	move.w	($6,a0),d1
	muls.w	($A,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($10,a2),d1
	add.l	d1,d0
	bpl.w	.l22B06
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22B0C
.l22B06:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22B0C:
	swap	d0
	move.l	d0,($8,a1)
	movem.l	(sp)+,d2-d7/a2-a4
	rts
.l22B18:
	move.l	($0,a0),d0
	move.w	($0,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($6,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($C,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($0,a1)
	move.l	($0,a0),d0
	move.w	($2,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($8,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($E,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($4,a1)
	move.l	($0,a0),d0
	move.w	($4,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($A,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($10,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($8,a1)
	movem.l	(sp)+,d2-d7/a2-a4
	rts
sub_22BA8:
	movem.l	d2-d7/a2-a4,-(sp)
	movea.l	($28,sp),a0
	movea.l	($2C,sp),a1
	movea.l	($30,sp),a2
	move.w	($2,a0),d0
	ext.l	d0
	cmp.l	($0,a0),d0
	bne.w	.l22C8A
	move.w	($6,a0),d0
	ext.l	d0
	cmp.l	($4,a0),d0
	bne.w	.l22C8A
	move.w	($A,a0),d0
	ext.l	d0
	cmp.l	($8,a0),d0
	bne.w	.l22C8A
	move.w	($2,a0),d0
	muls.w	($0,a2),d0
	move.w	($6,a0),d1
	muls.w	($2,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($4,a2),d1
	add.l	d1,d0
	bpl.w	.l22C0C
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22C12
.l22C0C:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22C12:
	swap	d0
	move.l	d0,($0,a1)
	move.w	($2,a0),d0
	muls.w	($6,a2),d0
	move.w	($6,a0),d1
	muls.w	($8,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($A,a2),d1
	add.l	d1,d0
	bpl.w	.l22C42
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22C48
.l22C42:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22C48:
	swap	d0
	move.l	d0,($4,a1)
	move.w	($2,a0),d0
	muls.w	($C,a2),d0
	move.w	($6,a0),d1
	muls.w	($E,a2),d1
	add.l	d1,d0
	move.w	($A,a0),d1
	muls.w	($10,a2),d1
	add.l	d1,d0
	bpl.w	.l22C78
	rol.l	#2,d0
	ori.w	#$FFFC,d0
	bra.w	.l22C7E
.l22C78:
	rol.l	#2,d0
	andi.w	#$3,d0
.l22C7E:
	swap	d0
	move.l	d0,($8,a1)
	movem.l	(sp)+,d2-d7/a2-a4
	rts
.l22C8A:
	move.l	($0,a0),d0
	move.w	($0,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($2,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($4,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($0,a1)
	move.l	($0,a0),d0
	move.w	($6,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($8,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($A,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($4,a1)
	move.l	($0,a0),d0
	move.w	($C,a2),d1
	bsr.w	sub_22D1A
	move.l	d0,d4
	move.l	($4,a0),d0
	move.w	($E,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	($8,a0),d0
	move.w	($10,a2),d1
	bsr.w	sub_22D1A
	add.l	d0,d4
	move.l	d4,($8,a1)
	movem.l	(sp)+,d2-d7/a2-a4
	rts
sub_22D1A:
	clr.b	d3
	tst.l	d0
	bpl.w	.l22D26
	neg.l	d0
	not.b	d3
.l22D26:
	tst.w	d1
	bpl.w	.l22D30
	neg.w	d1
	not.b	d3
.l22D30:
	move.w	d0,d2
	swap	d0
	mulu.w	d1,d0
	asl.l	#2,d0
	mulu.w	d1,d2
	asl.l	#2,d2
	clr.w	d2
	swap	d2
	add.l	d2,d0
	tst.b	d3
	bpl.w	.l22D4A
	neg.l	d0
.l22D4A:
	rts
dat_22D4C:
	incbin	"../../build/stunrun-68k.bin",$22D4C,$8A
sub_22DD6:
	movea.l	($4,sp),a0
	movea.l	($8,sp),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	rts
dat_22DEA:
	incbin	"../../build/stunrun-68k.bin",$22DEA,$2C
sub_22E16:
	move.l	($4,sp),d0
	subq.l	#8,d0
	rts
dat_22E1E:
	incbin	"../../build/stunrun-68k.bin",$22E1E,$72
	dcb.b	39,0
dat_22EB7:
	incbin	"../../build/stunrun-68k.bin",$22EB7,$5C7
sub_2347E:
	clr.l	d2
	move.b	d1,d2
	subi.b	#$2A,d2
	lsl.w	#5,d2
	lea	dat_22E1E,a1
	adda.w	d2,a1
	move.w	#$F,d3
.l23494:
	move.l	d0,GSP_HOST+$2
	bsr.w	sub_234B6
	addi.l	#$400,d0
	dbf	d3,.l23494
	subi.l	#$4000,d0
	addi.l	#$20,d0
	rts
sub_234B6:
	move.w	(a1)+,d5
	move.w	#$F,d7
	clr.l	d6
.l234BE:
	roxl.w	#1,d5
	roxl.l	#2,d6
	dbf	d7,.l234BE
	lsr.l	#1,d6
	move.w	d6,GSP_HOST+$C
	swap	d6
	addi.l	#$10,GSP_HOST+$2
	move.w	d6,GSP_HOST+$C
	rts
dat_234E2:
	incbin	"../../build/stunrun-68k.bin",$234E2,$3B6
sub_23898:
	move.b	($F,sp),d0
	lsl.w	#8,d0
	move.b	($F,sp),d0
	move.l	#$F4000000,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.w	($6,sp),d0
	andi.l	#$1F0,d0
	move.w	($A,sp),d1
	andi.l	#$1FF,d1
	asl.l	#2,d1
	asl.l	#8,d1
	asl.l	#1,d0
	add.l	d1,d0
	addi.l	#$2000000,d0
	movea.l	($10,sp),a0
	move.w	GSP_HOST+$8,-(sp)
	andi.w	#$E7FF,GSP_HOST+$8
	movem.l	d2-d3,-(sp)
.l238EA:
	move.b	(a0)+,d1
	beq.s	.l238FE
	cmp.b	#$20,d1
	bne.s	.l238F8
	move.b	#$2A,d1
.l238F8:
	bsr.w	sub_2347E
	bra.s	.l238EA
.l238FE:
	movem.l	(sp)+,d2-d3
	move.w	(sp)+,GSP_HOST+$8
	rts
dat_2390A:
	incbin	"../../build/stunrun-68k.bin",$2390A,$F4
h_level6_duart:
	movem.l	d0-d1/a0,-(sp)
	btst	#$0,$FFFF0012
	beq.s	.l23A10
	bsr.w	sub_23A54
.l23A10:
	btst	#$0,$FFFF0002
	beq.s	.l23A1E
	bsr.w	sub_23AA0
.l23A1E:
	btst	#$0,ram_FF904A
	beq.s	.l23A36
	btst	#$2,$FFFF0002
	beq.s	.l23A36
	bsr.w	sub_23B0A
.l23A36:
	btst	#$4,ram_FF904A
	beq.s	.l23A4E
	btst	#$2,$FFFF0012
	beq.s	.l23A4E
	bsr.w	sub_23B54
.l23A4E:
	movem.l	(sp)+,d0-d1/a0
	rte
sub_23A54:
	move.b	$FFFF0012,d1
	andi.w	#$F0,d1
	beq.s	.l23A82
	andi.w	#$90,d1
	beq.s	.l23A78
	move.b	#$20,$FFFF0014
	move.b	#$1,$FFFF0014
	rts
.l23A78:
	move.b	#$40,$FFFF0014
	rts
.l23A82:
	movem.l	a1,-(sp)
	clr.l	d0
	move.b	$FFFF0016,d0
	move.l	d0,-(sp)
	jsr	sub_30012
	addq.l	#4,sp
	movem.l	(sp)+,a1
	rts
loc_23A9E:
	rts
sub_23AA0:
	lea	ram_FF906C,a0
	move.b	ram_FF9054,d0
	move.b	$FFFF0002,d1
	andi.w	#$F0,d1
	beq.s	.l23AE0
	andi.w	#$90,d1
	beq.s	.l23AD0
	move.b	#$20,$FFFF0004
	move.b	#$1,$FFFF0004
	rts
.l23AD0:
	move.b	$FFFF0006,d1
	move.b	#$40,$FFFF0004
	rts
.l23AE0:
	lea	ram_FF906C,a0
	move.w	ram_FF9054,d0
	move.b	$FFFF0006,($0,a0,d0.w)
	addq.w	#1,d0
	andi.w	#$FF,d0
	cmp.w	ram_FF9056,d0
	beq.s	loc_23A9E
	move.w	d0,ram_FF9054
	rts
sub_23B0A:
	move.w	ram_FF905E,d1
	cmp.w	ram_FF905C,d1
	bne.s	.l23B2C
.l23B18:
	bclr	#$0,ram_FF904A
	move.b	ram_FF904A,$FFFF000A
	rts
.l23B2C:
	lea	ram_FF926C,a0
	clr.l	d0
	move.b	($0,a0,d1.w),d0
	addq.w	#1,d1
	andi.w	#$FF,d1
	move.w	d1,ram_FF905E
	move.b	d0,$FFFF0006
	cmp.w	ram_FF905C,d1
	beq.s	.l23B18
	rts
sub_23B54:
	move.w	ram_FF9068,d1
	bne.s	.l23B8A
	bclr	#$4,ram_FF904A
	move.b	ram_FF904A,$FFFF000A
.l23B6E:
	btst	#$3,$FFFF0012
	beq.s	.l23B6E
	move.b	#$20,$FFFF001E
	move.w	#$1,ram_FF906A
	rts
.l23B8A:
	movea.l	ram_FF9064,a0
	move.b	(a0)+,$FFFF0016
	move.l	a0,ram_FF9064
	subq.w	#1,d1
	move.w	d1,ram_FF9068
	rts
dat_23BA6:
	incbin	"../../build/stunrun-68k.bin",$23BA6,$F4
sub_23C9A:
	move.w	ram_FF9056,d1
	cmp.w	ram_FF9054,d1
	beq.s	sub_23C9A
	lea	ram_FF906C,a0
	clr.l	d0
	move.b	($0,a0,d1.w),d0
	addq.w	#1,d1
	andi.w	#$FF,d1
	move.w	d1,ram_FF9056
	rts
dat_23CC2:
	incbin	"../../build/stunrun-68k.bin",$23CC2,$CA
sub_23D8C:
	move.w	ram_FF946E,d1
	lea	$FFFF8000,a0
.l23D98:
	btst	#$4,PORT0+$1
	beq.s	.l23D98
	move.b	ADC8_DATA+$1,($0,a0,d1.w)
	move.w	ram_FF946C,d1
	cmp.w	dat_4A8AA,d1
	bcs.s	.l23DC0
	clr.w	d1
	clr.w	ram_FF946C
.l23DC0:
	lsl.w	#1,d1
	lea	dat_4A8AC,a0
	move.w	($0,a0,d1.w),d1
	move.w	d1,ram_FF946E
	andi.b	#$3,d1
	move.b	d1,ADC12+$1
	move.b	d1,d0
	ori.b	#$48,d1
	move.b	d1,ADC12+$1
	move.b	d0,ADC12+$1
	andi.l	#$3,d1
	move.l	d1,-(sp)
	jsr	sub_3CF40
	addq.l	#4,sp
	addq.w	#1,ram_FF946C
	rts
sub_23E06:
	move.b	#$48,ADC12+$1
	clr.b	ADC12+$1
	clr.w	ram_FF946C
	clr.w	ram_FF946E
	rts
sub_23E22:
	cmp.l	#$FFFF,d2
	bhi.s	.l23E42
	movea.w	d1,a1
	clr.w	d1
	swap	d1
	divu.w	d2,d1
	move.l	d1,d0
	swap	d1
	move.w	a1,d0
	divu.w	d2,d0
	move.w	d0,d1
	clr.w	d0
	swap	d0
	rts
.l23E42:
	move.l	d1,d0
	clr.w	d0
	swap	d0
	swap	d1
	clr.w	d1
	movea.l	d2,a1
	moveq	#$F,d2
.l23E50:
	add.l	d1,d1
	addx.l	d0,d0
	cmpa.l	d0,a1
	bhi.s	.l23E5C
	sub.l	a1,d0
	addq.w	#1,d1
.l23E5C:
	dbf	d2,.l23E50
	rts
sub_23E62:
	move.l	d2,-(sp)
	move.l	d1,d2
	move.l	d0,d1
	bsr.s	sub_23E22
	move.l	d1,d0
	move.l	(sp)+,d2
	rts
sub_23E70:
	move.l	d2,-(sp)
	movea.l	d0,a0
	moveq	#$0,d0
	move.l	d1,d2
	bge.s	.l23E7E
	neg.l	d2
	not.l	d0
.l23E7E:
	move.l	a0,d1
	bge.s	.l23E86
	neg.l	d1
	not.l	d0
.l23E86:
	movea.l	d0,a0
	bsr.s	sub_23E22
	move.l	a0,d2
	beq.s	.l23E90
	neg.l	d1
.l23E90:
	move.l	d1,d0
	move.l	(sp)+,d2
	rts
send_sound_with_reply:
	incbin	"../../build/stunrun-68k.bin",$23E96,$44
send_sound_byte:
	moveq	#$0,d0
	bra.s	loc_23EE0
send_sound_byte_once:
	incbin	"../../build/stunrun-68k.bin",$23EDE,$2
loc_23EE0:
	movea.l	d0,a0
	move.w	($6,sp),d0
	move.w	sr,d1
	move.w	#$2400,sr
	btst	#$F,BUTTONS
	beq.s	.l23F02
	move.b	d0,JSA_PORT
	move.w	d1,sr
	moveq	#$1,d0
	bra.s	.l23F0A
.l23F02:
	move.w	d1,sr
	move.l	a0,d0
	subq.b	#1,d0
	bne.s	loc_23EE0
.l23F0A:
	rts
dat_23F0C:
	incbin	"../../build/stunrun-68k.bin",$23F0C,$18
h_level4_sound:
	movem.l	d0/a0-a1,-(sp)
	lea	sound_resp_out,a1
	movea.l	($4,a1),a0
	move.l	a0,d0
	bne.w	.l23F56
	move.b	($1,a1),d0
	ext.w	d0
	lea	($8,a1,d0.w),a0
	addq.b	#1,($1,a1)
	cmp.b	#$F,d0
	bcs.w	.l23F66
	clr.b	($1,a1)
	bra.w	.l23F66
.l23F56:
	addq.l	#1,($4,a1)
	subq.b	#1,($2,a1)
	bne.w	.l23F66
	clr.l	($4,a1)
.l23F66:
	move.b	JSA_PORT,(a0)
	movem.l	(sp)+,d0/a0-a1
	rte
get_sound_response:
	incbin	"../../build/stunrun-68k.bin",$23F72,$30
reset_sound_board:
	lea	sound_resp_out,a1
	move.w	SOUND_RESET,d1
	move.b	JSA_PORT,d1
	clr.l	($4,a1)
	rts
sub_23FBA:
	lea	ram_FF9488,a0
	move.l	(a0),d0
	move.l	d0,d1
	swap	d1
	mulu.w	#$12B9,d0
	mulu.w	#$12B9,d1
	swap	d1
	clr.w	d1
	add.l	d1,d0
	move.l	(a0),d1
	mulu.w	#$B90D,d1
	swap	d1
	clr.w	d1
	add.l	d1,d0
	addi.l	#$38CE051F,d0
	move.l	d0,(a0)
	swap	d0
	mulu.w	($6,sp),d0
	clr.w	d0
	swap	d0
	rts
sub_23FF4:
	move.l	(ram_FF8014-ABS_SHORT).w,d0
	lea	ram_FF9488,a0
	move.l	d0,(a0)
	rts
sub_24002:
	lea	ram_FF9488,a0
	move.l	($4,sp),(a0)
	rts
sub_2400E:
	movem.l	d2,-(sp)
	moveq	#$0,d0
	moveq	#$0,d1
	lea	ram_FFDDD6,a0
	lea	dat_240FC,a1
.l24022:
	move.b	(a0)+,d2
	beq.s	.l24042
	cmp.b	#$20,d2
	beq.s	.l24022
	eor.b	d1,d2
	andi.w	#$FF,d2
	add.w	d2,d2
	move.b	($1,a1,d2.w),d1
	move.b	($0,a1,d2.w),d2
	eor.b	d2,d0
	exg	d0,d1
	bra.s	.l24022
.l24042:
	lea	ram_FFDDE1,a0
	lea	str_2409C,a1
	move.w	d0,d2
	lsr.w	#2,d2
	andi.w	#$1F,d2
	move.b	($0,a1,d2.w),(a0)
	asl.w	#8,d0
	or.w	d1,d0
	move.w	d0,d2
	lsr.w	#5,d2
	andi.w	#$1F,d2
	move.b	($0,a1,d2.w),($2,a0)
	lea	str_240BC,a1
	move.w	d0,d2
	andi.w	#$1F,d2
	move.b	($0,a1,d2.w),($1,a0)
	lea	dat_240DC,a1
	move.w	d1,d2
	lsr.w	#5,d2
	andi.w	#$1F,d2
	move.b	($0,a1,d2.w),($3,a0)
	clr.b	($4,a0)
	movem.l	(sp)+,d2
	rts
str_2409C:
	dc.b	'WXXZCCFFGGHHJKKZZFGHJJKKMNNSSTTW'
str_240BC:
	dc.b	'AEIUAEIUAEIUAEIUAEIUAEIUAEIUAEIU'
dat_240DC:
	incbin	"../../build/stunrun-68k.bin",$240DC,$20
dat_240FC:
	incbin	"../../build/stunrun-68k.bin",$240FC,$20A
	assert	*=$024306,"game/code_020430.asm does not end at 024306"
