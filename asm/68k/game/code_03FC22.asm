; game/code_03FC22.asm, 03FC22-04397E: game program code (pairs S and T) with the data, text and
; tables that lie between its routines; the first routine is sub_3FC22 (03FC22). Cut at routine
; starts into files of about 16 KB named by their first address (decision C11). The routine at
; 03FEA6 crosses the S/T pair boundary 040000, which is therefore not a file boundary (docs/13
; section 2).
; 03FC22-04397E: 72 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 03FC22 04397E (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$03FC22,"game/code_03FC22.asm misplaced"
sub_3FC22:
	link	a6,#$FFFC
	movem.l	d2-d4,-(sp)
	move.l	($8,a6),d4
	move.l	($C,a6),d3
	move.l	($10,a6),d2
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	addq.l	#1,d0
	cmp.l	d2,d0
	ble.s	.l3FC6A
	move.l	d2,d0
	subq.l	#1,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	jsr	copy_to_zram
	clr.b	(-$1,a6)
	pea	$1.w
	move.l	d2,d0
	subq.l	#1,d0
	add.l	d4,d0
	move.l	d0,-(sp)
	pea	(-$1,a6)
	bra.s	.l3FC70
.l3FC6A:
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	move.l	d3,-(sp)
.l3FC70:
	jsr	copy_to_zram
	movem.l	(-$10,a6),d2-d4
	unlk	a6
	rts
sub_3FC80:
	link	a6,#$FFEC
	movem.l	d2-d3,-(sp)
	move.l	($8,a6),d3
	move.b	($F,a6),d2
	pea	$13.w
	move.l	d3,-(sp)
	pea	(-$14,a6)
	jsr	sub_3DEFC
	moveq	#$0,d0
	move.b	d2,d0
	move.l	d0,-(sp)
	pea	(-$14,a6)
	jsr	sub_3DD8E
	pea	$13.w
	pea	(-$14,a6)
	move.l	d3,-(sp)
	jsr	sub_3FC22
	movem.l	(-$1C,a6),d2-d3
	unlk	a6
	rts
sub_3FCCA:
	link	a6,#$FF94
	movem.l	d2-d6/a2-a5,-(sp)
	move.w	($A,a6),d3
	move.w	($E,a6),d2
	move.l	#sub_2F2CC,d4
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1C8.w
	pea	dat_4E6F8
	movea.l	d4,a5
	jsr	(a5)
	addi.w	#$A,d2
	moveq	#$1,d6
	move.w	d6,(-$2,a6)
	move.l	#$FF4528,d5
	movea.l	d5,a5
	lea	($8,a5),a4
	lea	(-$6A,a6),a2
	movea.l	#dat_4E700,a3
	lea	($14,sp),sp
	bra.w	.l3FDEC
.l3FD24:
	movea.l	d5,a5
	clr.b	($1A,a5)
	move.l	a4,-(sp)
	pea	(a3)
	pea	(a2)
	jsr	sub_30220
	movea.l	d5,a5
	move.l	(a5),d0
	lsr.l	#5,d0
	move.l	d0,(-$6,a6)
	movea.l	d5,a5
	move.l	(a5),d1
	moveq	#$1F,d0
	and.l	d0,d1
	add.l	d1,d1
	move.l	d1,d0
	asl.l	#2,d1
	add.l	d0,d1
	move.l	d1,d6
	lsr.l	#5,d6
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$120.w
	pea	(a2)
	movea.l	d4,a5
	jsr	(a5)
	move.l	(-$6,a6),-(sp)
	pea	dat_4E704
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1C0.w
	pea	(a2)
	movea.l	d4,a5
	jsr	(a5)
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1F0.w
	pea	dat_4E708
	movea.l	d4,a5
	jsr	(a5)
	move.l	d6,-(sp)
	pea	dat_4E70A
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1F6.w
	pea	(a2)
	movea.l	d4,a5
	jsr	(a5)
	lea	($74,sp),sp
	addq.w	#1,(-$2,a6)
	moveq	#$1C,d0
	add.l	d0,d5
	moveq	#$1C,d0
	adda.l	d0,a4
	addq.w	#8,d2
.l3FDEC:
	cmpi.w	#$5,(-$2,a6)
	ble.w	.l3FD24
	movem.l	(-$90,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_3FE00:
	link	a6,#$FF9C
	movem.l	d2-d5/a2-a5,-(sp)
	movea.l	($8,a6),a0
	move.w	($E,a6),d3
	move.w	($12,a6),d2
	moveq	#$1,d5
	move.l	a0,d4
	movea.l	d4,a1
	lea	($2,a1),a4
	lea	(-$64,a6),a2
	movea.l	#dat_4E70E,a3
	bra.s	.l3FE96
.l3FE2A:
	movea.l	d4,a5
	clr.b	($14,a5)
	move.l	a4,-(sp)
	pea	(a3)
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$130.w
	pea	(a2)
	jsr	sub_2F2CC
	movea.l	d4,a5
	move.w	(a5),d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	dat_4E712
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	move.w	d3,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d2,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$1D8.w
	pea	(a2)
	jsr	sub_2F2CC
	lea	($40,sp),sp
	addq.w	#1,d5
	moveq	#$16,d0
	add.l	d0,d4
	moveq	#$16,d0
	adda.l	d0,a4
	addq.w	#8,d2
.l3FE96:
	cmpi.w	#$5,d5
	ble.s	.l3FE2A
	movem.l	(-$84,a6),d2-d5/a2-a5
	unlk	a6
	rts
sub_3FEA6:
	link	a6,#$FF9C
	movem.l	d2-d3/a2,-(sp)
	movea.l	#sub_2F8E0,a2
	move.b	BUTTONS+$1,d1
	andi.b	#$3,d1
	move.b	ram_FFDDE6,d3
	move.b	d1,d0
	eor.b	d0,d3
	and.b	ram_FFDDE6,d3
	move.b	d1,ram_FFDDE6
	pea	$1.w
	pea	$14.w
	pea	$13.w
	pea	$2C.w
	pea	$100.w
	pea	str_4E716
	jsr	sub_2FBFA
	pea	$13.w
	pea	$34.w
	pea	$184.w
	pea	$34.w
	pea	$17C.w
	jsr	sub_2F470
	move.l	$FFFF8014,d0
	andi.l	#$C0,d0
	lea	($2C,sp),sp
	beq.s	.l3FF3A
	clr.l	-(sp)
	pea	$10.w
	pea	$D8.w
	pea	$100.w
	pea	str_4E732
	jsr	(a2)
	lea	($14,sp),sp
.l3FF3A:
	clr.l	-(sp)
	pea	$17.w
	pea	$E8.w
	pea	$100.w
	pea	str_4E74E
	jsr	(a2)
	moveq	#$0,d0
	move.b	ram_FFDE6A,d0
	lea	($14,sp),sp
	cmpi.w	#$4,d0
	bhi.w	loc_40470
	add.w	d0,d0
	move.w	(.l3FF6E,pc,d0.w),d0
	jmp	(.l3FF6E,pc,d0.w)
.l3FF6E:
	dc.w	sub_3FF78-.l3FF6E
	dc.w	loc_3FFC0-.l3FF6E
	dc.w	sub_400F4-.l3FF6E
	dc.w	sub_40228-.l3FF6E
	dc.w	sub_40340-.l3FF6E
sub_3FF78:
	moveq	#$8,d1
	moveq	#$20,d0
	moveq	#$0,d2
	movea.l	#ram_FFDDD6,a0
.l3FF84:
	move.b	d0,(a0)
	addq.l	#1,d2
	addq.l	#1,a0
	cmp.l	d1,d2
	blt.s	.l3FF84
	clr.b	d0
	move.b	d0,ram_FFDDDF
	move.b	d0,ram_FFDDDE
	move.b	#$1,ram_FFDE6C
	clr.b	d0
	move.b	d0,ram_FFDE6E
	move.b	d0,ram_FFDE70
	move.b	#$1E,ram_FFDDE8
	addq.b	#1,ram_FFDE6A
loc_3FFC0:
	clr.l	-(sp)
	pea	$17.w
	pea	$40.w
	pea	$100.w
	pea	str_4E780
	jsr	(a2)
	clr.l	-(sp)
	pea	$1E.w
	pea	$4C.w
	pea	$100.w
	pea	str_4E79A
	jsr	(a2)
	pea	$1.w
	pea	$1D.w
	pea	$5C.w
	pea	$B0.w
	pea	ram_FFDDD6
	jsr	sub_2FA68
	pea	$B8.w
	jsr	sub_3E51C
	cmpi.w	#$1C,ram_FFDE58
	lea	($40,sp),sp
	bne.s	.l40036
	moveq	#$0,d0
	move.b	ram_FFDE70,d0
	movea.l	#ram_FFDDD6,a0
	move.b	#$20,($0,a0,d0.w)
	bra.s	.l40056
.l40036:
	moveq	#$0,d0
	move.b	ram_FFDE70,d0
	movea.l	#ram_FFDDD6,a0
	move.w	ram_FFDE58,d1
	movea.l	#str_4EDA8,a1
	move.b	($0,a1,d1.w),($0,a0,d0.w)
.l40056:
	move.w	ram_FFDE58,d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	$BC.w
	jsr	sub_3E34E
	tst.b	ram_FFDDE8
	addq.l	#8,sp
	beq.s	.l4007C
	subq.b	#1,ram_FFDDE8
	clr.b	d3
.l4007C:
	tst.b	d3
	beq.w	.l400F0
	pea	$33.w
	jsr	queue_sound_command
	moveq	#$0,d0
	move.b	ram_FFDE70,d0
	movea.l	#ram_FFDDD6,a0
	move.b	($0,a0,d0.w),d0
	ext.w	d0
	addq.l	#4,sp
	cmpi.w	#$2,d0
	blt.s	.l400DA
	bgt.s	.l400AC
	bra.s	.l400D2
.l400AC:
	subq.w	#3,d0
	bne.s	.l400DA
	moveq	#$0,d0
	move.b	ram_FFDE70,d0
	movea.l	#ram_FFDDD6,a0
	clr.b	($0,a0,d0.w)
	tst.b	ram_FFDE70
	bls.s	.l400D0
	subq.b	#1,ram_FFDE70
.l400D0:
	bra.s	.l400F0
.l400D2:
	addq.b	#1,ram_FFDE6A
	bra.s	.l400F0
.l400DA:
	addq.b	#1,ram_FFDE70
	cmpi.b	#$3,ram_FFDE70
	bcs.s	.l400F0
	addq.b	#1,ram_FFDE6A
.l400F0:
	bra.w	loc_40470
sub_400F4:
	jsr	sub_3CF8E
	clr.l	-(sp)
	pea	$17.w
	pea	$40.w
	pea	$100.w
	pea	str_4E7B6
	jsr	(a2)
	clr.l	-(sp)
	pea	$1E.w
	pea	$4C.w
	pea	$100.w
	pea	str_4E7D0
	jsr	(a2)
	pea	$1.w
	pea	$1D.w
	pea	$5C.w
	pea	$B0.w
	pea	ram_FFDDD6
	jsr	sub_2FA68
	moveq	#$0,d0
	move.b	ram_FFDD82,d0
	lsr.l	#1,d0
	move.b	d0,d2
	cmpi.b	#$D,d2
	lea	($3C,sp),sp
	bcs.s	.l4015C
	moveq	#$D,d0
	bra.s	.l40160
.l4015C:
	moveq	#$0,d0
	move.b	d2,d0
.l40160:
	move.b	d0,d2
	cmpi.b	#$2,d2
	bhi.s	.l4016C
	moveq	#$2,d0
	bra.s	.l40170
.l4016C:
	moveq	#$0,d0
	move.b	d2,d0
.l40170:
	move.b	d0,d2
	subq.b	#2,d2
	moveq	#$0,d0
	move.b	d2,d0
	cmp.w	ram_FFDDEA,d0
	beq.s	.l4018C
	pea	$34.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l4018C:
	moveq	#$0,d0
	move.b	d2,d0
	move.w	d0,ram_FFDDEA
	moveq	#$0,d0
	move.b	d2,d0
	asl.w	#2,d0
	movea.l	#dat_4EA6A,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	(-$64,a6)
	jsr	sub_2E4B4
	clr.b	(-$61,a6)
	pea	$1.w
	pea	$13.w
	pea	$78.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2FACE
	jsr	sub_40488
	moveq	#$0,d0
	move.b	d2,d0
	asl.w	#2,d0
	movea.l	#dat_4EA6A,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	ram_FFDDDA
	jsr	sub_2E4B4
	tst.b	d3
	lea	($24,sp),sp
	beq.s	.l40224
	pea	$33.w
	jsr	queue_sound_command
	addq.b	#1,ram_FFDE6A
	pea	ram_FFDDD6
	pea	ram_FFDE60
	jsr	sub_2E4B4
	clr.b	ram_FFDE68
	lea	($C,sp),sp
.l40224:
	bra.w	loc_40470
sub_40228:
	jsr	sub_3CF8E
	clr.l	-(sp)
	pea	$17.w
	pea	$40.w
	pea	$100.w
	pea	str_4E7F6
	jsr	(a2)
	clr.l	-(sp)
	pea	$1E.w
	pea	$4C.w
	pea	$100.w
	pea	str_4E810
	jsr	(a2)
	moveq	#$0,d0
	move.b	ram_FFDE6C,d0
	move.l	d0,-(sp)
	pea	ram_FFDE60
	pea	dat_4E834
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$1D.w
	pea	$5C.w
	pea	$B0.w
	pea	(-$64,a6)
	jsr	sub_2FA68
	moveq	#$0,d0
	move.b	ram_FFDE6C,d0
	move.l	d0,-(sp)
	pea	dat_4E83C
	pea	(-$64,a6)
	jsr	sub_30220
	jsr	sub_40488
	pea	$1.w
	pea	$13.w
	pea	$78.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2FACE
	move.b	ram_FFDD82,ram_FFDE6C
	tst.b	ram_FFDE6C
	lea	($6C,sp),sp
	bne.s	.l402EC
	move.b	#$1,ram_FFDE6C
.l402EC:
	moveq	#$0,d0
	move.b	ram_FFDE6C,d0
	cmp.w	ram_FFDDEA,d0
	beq.s	.l40308
	pea	$34.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l40308:
	moveq	#$0,d0
	move.b	ram_FFDE6C,d0
	move.w	d0,ram_FFDDEA
	tst.b	d3
	beq.s	.l4033C
	pea	$33.w
	jsr	queue_sound_command
	move.b	ram_FFDE6C,ram_FFDDDE
	jsr	sub_2400E
	addq.b	#1,ram_FFDE6A
	addq.l	#4,sp
.l4033C:
	bra.w	loc_40470
sub_40340:
	clr.l	-(sp)
	pea	$1E.w
	pea	$40.w
	pea	$100.w
	pea	str_4E840
	jsr	(a2)
	clr.l	-(sp)
	pea	$1E.w
	pea	$4C.w
	pea	$100.w
	pea	str_4E872
	jsr	(a2)
	clr.l	-(sp)
	pea	$1E.w
	pea	$58.w
	pea	$100.w
	pea	dat_4E8A4
	jsr	(a2)
	clr.l	-(sp)
	pea	$17.w
	pea	$68.w
	pea	$100.w
	pea	str_4E8A8
	jsr	(a2)
	clr.l	-(sp)
	pea	$17.w
	pea	$74.w
	pea	$100.w
	pea	dat_4E8C2
	jsr	(a2)
	clr.l	-(sp)
	pea	$17.w
	pea	$80.w
	pea	$100.w
	pea	dat_4E8D4
	jsr	(a2)
	pea	$1.w
	pea	$13.w
	pea	$90.w
	pea	$100.w
	pea	str_4E8EE
	jsr	(a2)
	pea	ram_FFDDE1
	move.b	ram_FFDDDE,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	pea	ram_FFDE60
	pea	dat_4E908
	pea	(-$64,a6)
	jsr	sub_30220
	pea	$1.w
	pea	$1D.w
	pea	$A4.w
	pea	$100.w
	pea	(-$64,a6)
	jsr	sub_2FACE
	clr.l	-(sp)
	pea	$1E.w
	pea	$BC.w
	pea	$100.w
	pea	str_4E914
	jsr	(a2)
	clr.l	-(sp)
	pea	$18.w
	pea	$CC.w
	pea	$100.w
	pea	str_4E93A
	jsr	(a2)
	moveq	#$0,d0
	move.b	BUTTONS+$1,d0
	moveq	#$3,d1
	and.l	d1,d0
	moveq	#$3,d1
	eor.l	d1,d0
	lea	($DC,sp),sp
	beq.s	loc_40470
	btst	#$2,BUTTONS+$1
	bne.s	loc_40470
	addq.b	#1,ram_FFDE6A
loc_40470:
	moveq	#$0,d0
	cmpi.b	#$5,ram_FFDE6A
	scc	d0
	neg.b	d0
	movem.l	(-$70,a6),d2-d3/a2
	unlk	a6
	rts
sub_40488:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#sub_2F470,a2
	pea	$7F.w
	pea	$74.w
	pea	$120.w
	pea	$74.w
	pea	$E0.w
	jsr	(a2)
	pea	$7F.w
	pea	$8C.w
	pea	$120.w
	pea	$74.w
	pea	$120.w
	jsr	(a2)
	pea	$7F.w
	pea	$8C.w
	pea	$120.w
	pea	$8C.w
	pea	$E0.w
	jsr	(a2)
	pea	$7F.w
	pea	$8C.w
	pea	$E0.w
	pea	$74.w
	pea	$E0.w
	jsr	(a2)
	pea	$7A.w
	pea	$75.w
	pea	$11F.w
	pea	$75.w
	pea	$E1.w
	jsr	(a2)
	pea	$7A.w
	pea	$8B.w
	pea	$11F.w
	pea	$75.w
	pea	$11F.w
	jsr	(a2)
	pea	$7A.w
	pea	$8B.w
	pea	$11F.w
	pea	$8B.w
	pea	$E1.w
	jsr	(a2)
	pea	$7A.w
	pea	$8B.w
	pea	$E1.w
	pea	$75.w
	pea	$E1.w
	jsr	(a2)
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_40550:
	link	a6,#$0
	tst.l	dat_480DC
	beq.s	.l40576
	move.l	dat_480DC,ram_FFDB40
	move.b	#$F0,ram_FFDB44
	move.b	#$10,ram_FFDB46
.l40576:
	move.l	#$FFE00000,GSP_HOST+$2
	move.l	gsp_image_entry_29,-(sp)
	jsr	unpack_gsp_image
	move.b	#$14,ram_FFDE78
	clr.b	ram_FFDE7C
	move.b	#$FF,ram_FFDE7A
	clr.b	ram_FFDE80
	move.b	#$1,ram_FFDE7E
	move.l	#dat_4F17C,ram_FFDE82
	move.w	#$FFD2,ram_FFDE86
	move.w	#$8C,ram_FFDE88
	unlk	a6
	rts
sub_405CE:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE7A,a2
	subq.b	#1,ram_FFDE7E
	bne.w	.l40682
	addq.b	#1,(a2)
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$FFFE,d0
	blt.s	.l40638
	bgt.s	.l40604
	bra.s	.l4062C
.l40604:
	cmpi.w	#$FFFF,d0
	bne.s	.l40638
	clr.b	(a2)
	movea.l	#ram_FFDE80,a0
	addq.b	#1,(a0)
	move.b	(a0),d1
	subq.b	#2,d1
	bls.s	.l4062A
	clr.b	ram_FFDE80
	move.l	#dat_4F1A0,ram_FFDE82
.l4062A:
	bra.s	.l40638
.l4062C:
	jsr	sub_4072A
	moveq	#$1,d0
	bra.w	.l40720
.l40638:
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($3,a0),ram_FFDE7E
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($1,a0),d0
	ext.w	d0
	add.w	d0,ram_FFDE86
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($2,a0),d0
	ext.w	d0
	add.w	d0,ram_FFDE88
.l40682:
	moveq	#$0,d0
	move.b	ram_FFDE78,d0
	asl.w	#2,d0
	movea.l	#dat_4F11C,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	pea	$8C.w
	pea	$D6.w
	jsr	sub_2F7D6
	cmpi.b	#$1,ram_FFDE7C
	bne.s	.l406DC
	cmpi.b	#$17,ram_FFDE78
	bne.s	.l406C0
	moveq	#$14,d0
	bra.s	.l406CE
.l406C0:
	movea.l	#ram_FFDE78,a0
	addq.b	#1,(a0)
	move.b	(a0),d1
	moveq	#$0,d0
	move.b	d1,d0
.l406CE:
	move.b	d0,ram_FFDE78
	clr.b	ram_FFDE7C
	bra.s	.l406E2
.l406DC:
	addq.b	#1,ram_FFDE7C
.l406E2:
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	asl.w	#2,d0
	movea.l	#dat_4F11C,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	move.w	ram_FFDE88,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	ram_FFDE86,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2F7D6
	moveq	#$0,d0
.l40720:
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_4072A:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE78,a2
	moveq	#$0,d0
	move.b	(a2),d0
	asl.w	#2,d0
	movea.l	#dat_4F11C,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	pea	$8C.w
	pea	$D6.w
	jsr	sub_2F7D6
	cmpi.b	#$1,ram_FFDE7C
	bne.s	.l40780
	cmpi.b	#$17,(a2)
	bne.s	.l4076E
	moveq	#$14,d0
	bra.s	.l40776
.l4076E:
	addq.b	#1,(a2)
	move.b	(a2),d1
	moveq	#$0,d0
	move.b	d1,d0
.l40776:
	move.b	d0,(a2)
	clr.b	ram_FFDE7C
	bra.s	.l40786
.l40780:
	addq.b	#1,ram_FFDE7C
.l40786:
	move.l	dat_4F168,-(sp)
	pea	$20.w
	pea	$88.w
	pea	$D6.w
	jsr	sub_2F7D6
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_407A8:
	link	a6,#$0
	move.l	#$FFE30060,GSP_HOST+$2
	move.l	gsp_image_entry_65,-(sp)
	jsr	unpack_gsp_image
	move.b	#$15,ram_FFDE78
	clr.b	ram_FFDE7C
	move.b	#$FF,ram_FFDE7A
	clr.b	ram_FFDE80
	move.b	#$1,ram_FFDE7E
	move.l	#dat_4F28C,ram_FFDE82
	move.w	#$202,ram_FFDE86
	move.w	#$8C,ram_FFDE88
	pea	$43.w
	jsr	sub_2DBB4
	unlk	a6
	rts
sub_4080E:
	link	a6,#$0
	move.l	#$FFE30060,GSP_HOST+$2
	move.l	gsp_image_entry_66,-(sp)
	jsr	unpack_gsp_image
	move.b	#$11,ram_FFDE78
	clr.b	ram_FFDE7C
	move.b	#$FF,ram_FFDE7A
	clr.b	ram_FFDE80
	move.b	#$1,ram_FFDE7E
	move.l	#dat_4F2E4,ram_FFDE82
	move.w	#$201,ram_FFDE86
	move.w	#$8D,ram_FFDE88
	pea	$43.w
	jsr	sub_2DBB4
	unlk	a6
	rts
sub_40874:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE7A,a2
	subq.b	#1,ram_FFDE7E
	bne.w	.l40928
	addq.b	#1,(a2)
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$FFFE,d0
	blt.s	.l408DE
	bgt.s	.l408AA
	bra.s	.l408D2
.l408AA:
	cmpi.w	#$FFFF,d0
	bne.s	.l408DE
	clr.b	(a2)
	movea.l	#ram_FFDE80,a0
	addq.b	#1,(a0)
	move.b	(a0),d0
	subq.b	#2,d0
	bls.s	.l408D0
	clr.b	ram_FFDE80
	move.l	#dat_4F2B0,ram_FFDE82
.l408D0:
	bra.s	.l408DE
.l408D2:
	jsr	sub_40B2E
	moveq	#$1,d0
	bra.w	.l4096C
.l408DE:
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($3,a0),ram_FFDE7E
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($1,a0),d0
	ext.w	d0
	sub.w	d0,ram_FFDE86
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($2,a0),d0
	ext.w	d0
	add.w	d0,ram_FFDE88
.l40928:
	jsr	sub_40AB0
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	asl.w	#2,d0
	movea.l	#dat_4F1D4,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	move.w	ram_FFDE88,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	ram_FFDE86,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2F7D6
	moveq	#$0,d0
.l4096C:
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_40976:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE7A,a2
	subq.b	#1,ram_FFDE7E
	bne.w	.l40A62
	addq.b	#1,(a2)
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	cmpi.w	#$FFFD,d0
	blt.w	.l40A18
	bgt.s	.l409B0
	bra.w	.l40A0C
.l409B0:
	cmpi.w	#$FFFE,d0
	bne.s	.l409B8
	bra.s	.l409E0
.l409B8:
	cmpi.w	#$FFFF,d0
	bne.s	.l40A18
	clr.b	(a2)
	movea.l	#ram_FFDE80,a0
	addq.b	#1,(a0)
	move.b	(a0),d0
	subq.b	#2,d0
	bls.s	.l409DE
	clr.b	ram_FFDE80
	move.l	#dat_4F30C,ram_FFDE82
.l409DE:
	bra.s	.l40A18
.l409E0:
	clr.b	(a2)
	movea.l	#ram_FFDE80,a0
	addq.b	#1,(a0)
	move.b	(a0),d0
	subq.b	#1,d0
	bls.s	.l40A0A
	clr.b	ram_FFDE80
	move.l	#dat_4F31C,ram_FFDE82
	pea	$5B.w
	jsr	queue_sound_command
.l40A0A:
	bra.s	.l409DE
.l40A0C:
	jsr	sub_40BD2
	moveq	#$1,d0
	bra.w	.l40AA6
.l40A18:
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($3,a0),ram_FFDE7E
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($1,a0),d0
	ext.w	d0
	sub.w	d0,ram_FFDE86
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	($2,a0),d0
	ext.w	d0
	add.w	d0,ram_FFDE88
.l40A62:
	jsr	sub_40B54
	moveq	#$0,d0
	move.b	(a2),d0
	asl.l	#2,d0
	movea.l	d0,a0
	adda.l	ram_FFDE82,a0
	move.b	(a0),d0
	ext.w	d0
	asl.w	#2,d0
	movea.l	#dat_4F238,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	move.w	ram_FFDE88,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	ram_FFDE86,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_2F7D6
	moveq	#$0,d0
.l40AA6:
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_40AB0:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE78,a2
	moveq	#$0,d0
	move.b	(a2),d0
	asl.w	#2,d0
	movea.l	#dat_4F1D4,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	pea	$8C.w
	pea	$D6.w
	jsr	sub_2F7D6
	cmpi.b	#$1,ram_FFDE7C
	bne.s	.l40B06
	cmpi.b	#$18,(a2)
	bne.s	.l40AF4
	moveq	#$15,d0
	bra.s	.l40AFC
.l40AF4:
	addq.b	#1,(a2)
	move.b	(a2),d1
	moveq	#$0,d0
	move.b	d1,d0
.l40AFC:
	move.b	d0,(a2)
	clr.b	ram_FFDE7C
	bra.s	.l40B0C
.l40B06:
	addq.b	#1,ram_FFDE7C
.l40B0C:
	move.l	dat_4F224,-(sp)
	pea	$20.w
	pea	$88.w
	pea	$D6.w
	jsr	sub_2F7D6
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_40B2E:
	link	a6,#$0
	jsr	sub_40AB0
	move.l	dat_4F220,-(sp)
	pea	$20.w
	pea	$88.w
	pea	$D8.w
	jsr	sub_2F7D6
	unlk	a6
	rts
sub_40B54:
	link	a6,#$0
	movem.l	a2,-(sp)
	movea.l	#ram_FFDE78,a2
	moveq	#$0,d0
	move.b	(a2),d0
	asl.w	#2,d0
	movea.l	#dat_4F238,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$20.w
	pea	$8C.w
	pea	$D6.w
	jsr	sub_2F7D6
	cmpi.b	#$1,ram_FFDE7C
	bne.s	.l40BAA
	cmpi.b	#$14,(a2)
	bne.s	.l40B98
	moveq	#$11,d0
	bra.s	.l40BA0
.l40B98:
	addq.b	#1,(a2)
	move.b	(a2),d1
	moveq	#$0,d0
	move.b	d1,d0
.l40BA0:
	move.b	d0,(a2)
	clr.b	ram_FFDE7C
	bra.s	.l40BB0
.l40BAA:
	addq.b	#1,ram_FFDE7C
.l40BB0:
	move.l	dat_4F278,-(sp)
	pea	$20.w
	pea	$88.w
	pea	$D6.w
	jsr	sub_2F7D6
	movem.l	(-$4,a6),a2
	unlk	a6
	rts
sub_40BD2:
	link	a6,#$0
	jsr	sub_40B54
	move.l	dat_4F260,-(sp)
	pea	$20.w
	pea	$85.w
	pea	$F5.w
	jsr	sub_2F7D6
	unlk	a6
	rts
sub_40BF8:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a5,-(sp)
	move.l	#sub_22DD6,(-$4,a6)
	moveq	#$1,d2
	move.l	#$C6,d3
	move.l	ram_FFDAAE,d6
	move.l	#$FFDAAE,d4
	movea.l	#ram_FFDC1C,a3
	movea.l	#dat_4F104,a4
	bra.w	loc_40F4E
loc_40C2C:
	movea.l	d6,a5
	move.w	($10,a5),d0
	add.w	d0,d0
	move.w	($0,a4,d0.w),d5
	movea.l	d6,a5
	movea.l	($12,a5),a2
	pea	($14,a2)
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	d6,a5
	movea.l	($12,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	movea.l	d6,a5
	move.w	($10,a5),d0
	lea	($C,sp),sp
	cmpi.w	#$A,d0
	bhi.w	loc_40F4A
	add.w	d0,d0
	move.w	(.l40C9C,pc,d0.w),d0
	jmp	(.l40C9C,pc,d0.w)
.l40C9C:
	dc.w	sub_40CB2-.l40C9C
	dc.w	sub_40CB2-.l40C9C
	dc.w	sub_40CB2-.l40C9C
	dc.w	loc_40F4A-.l40C9C
	dc.w	loc_40F4A-.l40C9C
	dc.w	loc_40F4A-.l40C9C
	dc.w	loc_40F4A-.l40C9C
	dc.w	sub_40CF2-.l40C9C
	dc.w	sub_40E1C-.l40C9C
	dc.w	sub_40DA0-.l40C9C
	dc.w	sub_40F08-.l40C9C
sub_40CB2:
	movea.l	d6,a0
	tst.l	($16,a0)
	beq.s	.l40CEE
	movea.l	d6,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	movea.l	d6,a5
	movea.l	($12,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d6,a5
	movea.l	($16,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	addq.l	#8,sp
.l40CEE:
	bra.w	loc_40F4A
sub_40CF2:
	move.l	d6,d5
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	movea.l	d5,a5
	movea.l	($12,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d5,a5
	subi.w	#$7D2,($2C,a5)
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	d5,a5
	movea.l	($16,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	movea.l	d5,a5
	movea.l	($28,a5),a2
	pea	($14,a2)
	movea.l	d5,a5
	movea.l	($16,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d5,a5
	movea.l	($28,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	lea	($1C,sp),sp
	bra.w	loc_40F4A
sub_40DA0:
	move.l	d6,d5
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	movea.l	d5,a5
	movea.l	($12,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d5,a5
	subi.w	#$1D27,($2C,a5)
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	d5,a5
	movea.l	($16,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	lea	($14,sp),sp
	bra.w	loc_40F4A
sub_40E1C:
	move.l	d6,d5
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	movea.l	d5,a5
	movea.l	($12,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d5,a5
	addi.w	#$4FA,($2C,a5)
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2C,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	d5,a5
	movea.l	($16,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	movea.l	d5,a5
	movea.l	($28,a5),a2
	pea	($14,a2)
	movea.l	d5,a5
	movea.l	($12,a5),a0
	pea	($14,a0)
	movea.l	(-$4,a6),a5
	jsr	(a5)
	movea.l	d5,a5
	addi.w	#$1D27,($2E,a5)
	movea.l	d5,a5
	movea.l	($16,a5),a2
	pea	($14,a2)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2E,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C72
	addq.l	#4,sp
	move.l	d0,-(sp)
	moveq	#$0,d0
	movea.l	d5,a5
	move.w	($2E,a5),d0
	move.l	d0,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CCD8
	movea.l	d5,a5
	movea.l	($28,a5),a2
	move.b	d2,d0
	and.b	#$1,d0
	lsl.b	#6,d0
	andi.b	#$BF,($38,a2)
	or.b	d0,($38,a2)
	lea	($28,sp),sp
	bra.s	loc_40F4A
sub_40F08:
	movea.l	d6,a0
	subq.b	#1,($66,a0)
	bne.s	loc_40F4A
	movea.l	d6,a1
	movea.l	($12,a1),a2
	movea.l	($26,a2),a0
	move.w	($4,a0),d0
	ext.l	d0
	addq.l	#1,d0
	cmp.l	d3,d0
	ble.s	.l40F2C
	move.l	#$C1,d0
.l40F2C:
	movea.l	d6,a5
	movea.l	($12,a5),a2
	move.l	d0,-(sp)
	jsr	object_descriptor
	move.l	d0,($26,a2)
	movea.l	d6,a5
	move.b	#$2,($66,a5)
	move.b	d2,(a3)
	addq.l	#4,sp
loc_40F4A:
	movea.l	d6,a0
	move.l	(a0),d6
loc_40F4E:
	cmp.l	d4,d6
	bne.w	loc_40C2C
	movem.l	(-$28,a6),d2-d6/a2-a5
	unlk	a6
	rts
sub_40F5E:
	link	a6,#$FFE4
	movem.l	d2-d5/a2-a5,-(sp)
	move.l	#dat_4EFC6,d3
	move.l	ram_FFDAAE,d4
	move.l	#$FFDAAE,d2
	movea.l	#dat_4F056,a3
	lea	(-$1A,a6),a2
	movea.l	#dat_4EF0C,a4
	bra.w	.l4107C
.l40F8C:
	movea.l	d4,a1
	move.b	($11,a1),d5
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a1
	move.w	($2,a1,d0.w),d1
	tst.w	d1
	beq.s	.l40FF0
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	pea	(a4)
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	pea	$13.w
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a5
	move.l	($8,a5,d0.w),-(sp)
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a5
	move.l	($4,a5,d0.w),-(sp)
	pea	(a2)
	jsr	sub_2F8E0
	lea	($20,sp),sp
	bra.s	.l41034
.l40FF0:
	pea	str_4EF10
	pea	(a2)
	jsr	sub_30220
	clr.l	-(sp)
	pea	$13.w
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a5
	move.l	($8,a5,d0.w),-(sp)
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a5
	move.l	($4,a5,d0.w),-(sp)
	pea	(a2)
	jsr	sub_2F8E0
	lea	($1C,sp),sp
.l41034:
	clr.l	-(sp)
	pea	$12.w
	moveq	#$0,d1
	move.b	d5,d1
	asl.w	#2,d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	movea.l	d3,a5
	move.l	($8,a5,d1.w),d1
	moveq	#$A,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	d3,a5
	move.l	($4,a5,d0.w),-(sp)
	moveq	#$0,d0
	move.b	d5,d0
	asl.w	#2,d0
	move.l	($0,a3,d0.w),-(sp)
	jsr	sub_2F8E0
	lea	($14,sp),sp
	movea.l	d4,a0
	move.l	(a0),d4
.l4107C:
	cmp.l	d2,d4
	bne.w	.l40F8C
	movem.l	(-$3C,a6),d2-d5/a2-a5
	unlk	a6
	rts
sub_4108C:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	ram_FFDAAE,d0
	move.l	#$FFDAAE,d2
	bra.s	.l410AC
.l410A2:
	move.l	d0,-(sp)
	jsr	sub_35502
	addq.l	#4,sp
.l410AC:
	cmp.l	d2,d0
	bne.s	.l410A2
	clr.b	ram_FF9C7C
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_410C0:
	link	a6,#$0
	movem.l	d2/a2-a3,-(sp)
	move.l	($8,a6),d2
	movea.l	#sub_30C72,a3
	jsr	sub_2E95A
	movea.l	d0,a2
	cmpa.w	#$0,a2
	bne.s	.l410E6
	moveq	#$0,d0
	bra.w	loc_41538
.l410E6:
	move.l	a2,-(sp)
	pea	ram_FFDAAE
	jsr	sub_2E7C4
	clr.l	($16,a2)
	lea	($8,a2),a0
	move.l	a0,($8,a2)
	lea	($8,a2),a0
	move.l	a0,($C,a2)
	move.w	d2,($10,a2)
	move.l	d2,d1
	moveq	#$1,d0
	cmp.l	d1,d0
	bgt.w	loc_41538
	moveq	#$B,d0
	cmp.l	d1,d0
	blt.w	loc_41538
	add.l	d1,d1
	move.w	(.l41124+2,pc,d1.l),d1
.l41124:
	jmp	(.l41128,pc,d1.w)
.l41128:
	dc.w	sub_4113E-.l41128
	dc.w	loc_41538-.l41128
	dc.w	sub_411DA-.l41128
	dc.w	sub_411F4-.l41128
	dc.w	sub_41232-.l41128
	dc.w	sub_41256-.l41128
	dc.w	sub_41272-.l41128
	dc.w	sub_41342-.l41128
	dc.w	sub_413FA-.l41128
	dc.w	sub_41498-.l41128
	dc.w	sub_414C6-.l41128
sub_4113E:
	pea	dat_47D34
	pea	$1900.w
	pea	$610.w
	move.l	#$FFFFF9C0,-(sp)
	pea	$B.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$11C7.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$11C7.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$5B0.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$5B0.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	move.w	#$1,($10,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	pea	$610.w
	move.l	#$FFFFF9C0,-(sp)
	pea	$D.w
	jsr	sub_2EF4C
	move.l	d0,($16,a2)
	bra.w	loc_41538
sub_411DA:
	pea	dat_47D34
	pea	$1900.w
	pea	$610.w
	pea	$640.w
	pea	$14.w
	bra.w	loc_414DE
sub_411F4:
	pea	dat_47D34
	pea	$1900.w
	move.l	#$FFFFFD70,-(sp)
	move.l	#$FFFFF9C0,-(sp)
	pea	$19.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$11C7.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$11C7.w
	bra.w	loc_41502
sub_41232:
	pea	dat_47D34
	pea	$1900.w
	move.l	#$FFFFFEE0,-(sp)
	clr.l	-(sp)
	pea	$13.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	bra.w	loc_41538
sub_41256:
	pea	dat_47D34
	pea	$1900.w
	move.l	#$FFFFFD70,-(sp)
	pea	$640.w
	pea	$21.w
	bra.w	loc_414DE
sub_41272:
	pea	dat_47D34
	pea	$1900.w
	pea	$610.w
	move.l	#$FFFFF9C0,-(sp)
	pea	$9F.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$11C7.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$11C7.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$5B0.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$5B0.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	pea	$610.w
	move.l	#$FFFFF9C0,-(sp)
	pea	$A0.w
	jsr	sub_2EF4C
	move.l	d0,($16,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	pea	$610.w
	move.l	#$FFFFF9C0,-(sp)
	pea	$A1.w
	jsr	sub_2EF4C
	move.l	d0,($28,a2)
	movea.l	($28,a2),a0
	pea	($14,a0)
	pea	$2000.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$2000.w
	bra.w	loc_41528
sub_41342:
	pea	dat_47D34
	pea	$1900.w
	pea	$610.w
	pea	$640.w
	pea	$AD.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	move.l	#$EE38,-(sp)
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.l	#$EE38,-(sp)
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$5B0.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$5B0.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	pea	$610.w
	pea	$640.w
	pea	$AF.w
	jsr	sub_2EF4C
	move.l	d0,($16,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	pea	$610.w
	pea	$640.w
	pea	$AE.w
	jsr	sub_2EF4C
loc_413F2:
	move.l	d0,($28,a2)
	bra.w	loc_41538
sub_413FA:
	pea	dat_47D34
	pea	$1900.w
	move.l	#$FFFFFD70,-(sp)
	move.l	#$FFFFF9C0,-(sp)
	pea	$B7.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$11C7.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$11C7.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$5B0.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$5B0.w
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$1900.w
	move.l	#$FFFFFD70,-(sp)
	move.l	#$FFFFF9C0,-(sp)
	pea	$B8.w
	jsr	sub_2EF4C
	move.l	d0,($16,a2)
	clr.l	($28,a2)
	bra.w	loc_41538
sub_41498:
	pea	dat_47D34
	pea	$1900.w
	pea	$610.w
	clr.l	-(sp)
	pea	$C1.w
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	move.b	#$5,($66,a2)
	moveq	#$0,d0
	move.l	d0,($16,a2)
	bra.w	loc_413F2
sub_414C6:
	pea	dat_47D34
	pea	$1900.w
	move.l	#$FFFFFD70,-(sp)
	pea	$640.w
	pea	$F4.w
loc_414DE:
	jsr	sub_2EF4C
	move.l	d0,($12,a2)
	movea.l	($12,a2),a0
	pea	($14,a0)
	move.l	#$EE38,-(sp)
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	move.l	#$EE38,-(sp)
loc_41502:
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CDE6
	movea.l	($12,a2),a0
	pea	($14,a0)
	pea	$5B0.w
	jsr	(a3)
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	$5B0.w
loc_41528:
	jsr	sub_30C06
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_2CD5C
loc_41538:
	movem.l	(-$C,a6),d2/a2-a3
	unlk	a6
	rts
sub_41542:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.b	($B,a6),d2
	movea.l	#sub_410C0,a2
	pea	ram_FFDB04
	pea	dat_47D34
	jsr	sub_22DD6
	clr.l	ram_FFDAF8
	clr.l	ram_FFDAFC
	clr.l	ram_FFDB00
	moveq	#$0,d0
	move.b	d2,d0
	move.w	d0,d0
	bcs.s	.l415D0
	bhi.s	.l41584
	bra.s	.l41594
.l41584:
	cmpi.w	#$1,d0
	bne.s	.l4158C
	bra.s	.l415AC
.l4158C:
	cmpi.w	#$2,d0
	bne.s	.l415D0
	bra.s	.l415B8
.l41594:
	pea	$1.w
	jsr	(a2)
	pea	$3.w
	jsr	(a2)
	pea	$4.w
	jsr	(a2)
	pea	$6.w
	bra.s	.l415CE
.l415AC:
	pea	$A.w
	jsr	(a2)
	pea	$5.w
	bra.s	.l415CE
.l415B8:
	pea	$7.w
	jsr	(a2)
	pea	$8.w
	jsr	(a2)
	pea	$9.w
	jsr	(a2)
	pea	$B.w
.l415CE:
	jsr	(a2)
.l415D0:
	move.b	#$1,ram_FFDC1C
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_415E2:
	link	a6,#$0
	moveq	#$0,d1
	movea.l	#ram_FFDE8A,a1
	movea.l	#dat_4EF20,a0
.l415F4:
	move.w	(a0),(a1)
	addq.l	#1,d1
	addq.l	#8,a0
	addq.l	#2,a1
	moveq	#$6,d0
	cmp.l	d1,d0
	bgt.s	.l415F4
	unlk	a6
	rts
sub_41606:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.w	($A,a6),d2
	movea.l	#dat_4EF20,a2
	cmpi.w	#$1,ram_FF9550
	beq.s	.l41628
	moveq	#$0,d0
	bra.w	.l416A4
.l41628:
	move.w	d2,d0
	add.w	d0,d0
	movea.l	#ram_FFDE8A,a0
	tst.w	($0,a0,d0.w)
	beq.w	.l416A4
	move.w	d2,d0
	add.w	d0,d0
	movea.l	#ram_FFDE8A,a0
	subq.w	#1,($0,a0,d0.w)
	bne.s	.l416A4
	move.w	d2,d0
	asl.w	#3,d0
	tst.w	($2,a2,d0.w)
	beq.s	.l41666
	move.w	d2,d0
	asl.w	#3,d0
	moveq	#$0,d1
	move.w	($2,a2,d0.w),d1
	move.l	d1,-(sp)
	jsr	queue_sound_command
.l41666:
	move.w	d2,d0
	asl.w	#3,d0
	tst.l	($4,a2,d0.w)
	beq.s	.l416A4
	move.w	#$2D,ram_FF954E
	move.w	#$28,ram_FF9550
	jsr	sub_2BAD6
	move.w	d2,d0
	asl.w	#3,d0
	move.l	($4,a2,d0.w),ram_FFDE74
	move.b	#$1E,ram_FFDD60
	pea	$1E.w
	jsr	queue_sound_command
.l416A4:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
sub_416AE:
	link	a6,#$0
	move.w	($A,a6),d0
	move.w	d0,d1
	add.w	d1,d1
	movea.l	#ram_FFDE8A,a0
	tst.w	($0,a0,d1.w)
	beq.s	.l416DE
	move.w	d0,d1
	add.w	d1,d1
	movea.l	#ram_FFDE8A,a0
	asl.w	#3,d0
	movea.l	#dat_4EF20,a1
	move.w	($0,a1,d0.w),($0,a0,d1.w)
.l416DE:
	unlk	a6
	rts
sub_416E2:
	link	a6,#$0
	movem.l	d2,-(sp)
	moveq	#$6,d1
	moveq	#$0,d2
	movea.l	#ram_FFDE8A,a0
.l416F4:
	moveq	#$3,d0
	cmp.l	d2,d0
	beq.s	.l416FC
	clr.w	(a0)
.l416FC:
	addq.l	#1,d2
	addq.l	#2,a0
	cmp.l	d1,d2
	blt.s	.l416F4
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_4170E:
	link	a6,#$0
	moveq	#$20,d0
	moveq	#$0,d1
	movea.l	#ram_FFDE9A,a0
.l4171C:
	clr.b	(a0)
	addq.l	#1,d1
	addq.l	#1,a0
	cmp.l	d0,d1
	blt.s	.l4171C
	moveb_ffff_abs	ram_FFDF3C
	moveb_ffff_abs	ram_FFDF3A
	unlk	a6
	rts
sub_4173A:
	link	a6,#$0
	movem.l	d2-d3/a2-a4,-(sp)
	movea.l	#ram_FFDF3C,a4
	moveq	#$20,d2
	moveb_ffff_ind	4
	moveb_ffff_abs	ram_FFDF3A
	moveq	#$0,d3
	movea.l	#dat_4F8B8,a3
	movea.l	#ram_FF9578,a2
.l41764:
	move.l	d3,-(sp)
	move.w	(a2),d0
	asl.w	#2,d0
	move.l	($0,a3,d0.w),-(sp)
	jsr	sub_41856
	addq.l	#8,sp
	addq.l	#1,d3
	cmp.l	d2,d3
	ble.s	.l41764
	tst.b	(a4)
	beq.s	.l4179E
	move.b	(a4),d1
	ext.w	d1
	ext.l	d1
	moveq	#$60,d0
	jsr	sub_23E70
	move.b	d0,ram_FFDF40
	move.b	#$14,ram_FFDF3E
	bra.s	.l417AE
.l4179E:
	move.b	#$1,ram_FFDF40
	move.b	#$1,ram_FFDF3E
.l417AE:
	movem.l	(-$14,a6),d2-d3/a2-a4
	unlk	a6
	rts
sub_417B8:
	link	a6,#$0
	movem.l	d2-d4/a2-a4,-(sp)
	movea.l	#ram_FFDEBA,a2
	subq.b	#1,ram_FFDF3E
	bne.s	.l417F8
	move.b	ram_FFDF3C,d0
	cmp.b	ram_FFDF3A,d0
	ble.s	.l417F8
	move.b	ram_FFDF40,ram_FFDF3E
	addq.b	#1,ram_FFDF3A
	pea	$24.w
	jsr	queue_sound_command
	addq.l	#4,sp
.l417F8:
	moveq	#$20,d2
	moveq	#$0,d4
	movea.l	#ram_FFDF3C,a4
	movea.l	#dat_4F33C,a3
	move.l	#$FFDF3A,d3
	bra.s	.l41840
.l41810:
	move.b	(a4),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d4,d0
	beq.s	.l4181E
	move.l	(a3),-(sp)
	bra.s	.l41822
.l4181E:
	move.l	($4,a3),-(sp)
.l41822:
	move.l	d2,-(sp)
	moveq	#$0,d0
	move.w	($2,a2),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	(a2),d0
	move.l	d0,-(sp)
	jsr	sub_2F7D6
	lea	($10,sp),sp
	addq.l	#1,d4
	addq.l	#4,a2
.l41840:
	movea.l	d3,a0
	move.b	(a0),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d4,d0
	bge.s	.l41810
	movem.l	(-$18,a6),d2-d4/a2-a4
	unlk	a6
	rts
sub_41856:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.l	($8,a6),d3
	move.l	($C,a6),d2
	movea.l	#ram_FFDF3C,a2
	move.w	d2,d0
	movea.l	#ram_FFDE9A,a0
	tst.b	($0,a0,d0.w)
	beq.s	.l418AE
	addq.b	#1,(a2)
	move.b	(a2),d1
	ext.w	d1
	asl.w	#2,d1
	movea.l	#ram_FFDEBA,a0
	move.l	d2,d0
	asl.l	#2,d0
	movea.l	d0,a1
	adda.l	d3,a1
	move.w	(a1),($0,a0,d1.w)
	move.b	(a2),d1
	ext.w	d1
	asl.w	#2,d1
	movea.l	#ram_FFDEBA,a0
	move.l	d2,d0
	asl.l	#2,d0
	movea.l	d0,a1
	adda.l	d3,a1
	move.w	($2,a1),($2,a0,d1.w)
.l418AE:
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_418B8:
	link	a6,#$0
	movem.l	d2-d7/a2-a4,-(sp)
	move.b	($B,a6),d2
	movea.l	#ram_FF948D,a3
	pea	$C.w
	jsr	sub_20B4E
	move.b	d0,d6
	cmpi.b	#$E0,d6
	addq.l	#4,sp
	bcs.s	.l418E8
	clr.b	ram_FF948E
	bra.w	.l419BC
.l418E8:
	moveq	#$2,d1
	movea.w	d1,a4
	moveq	#$0,d0
	move.b	d6,d0
	move.l	d0,d3
	lsr.l	#4,d3
	moveq	#$1,d0
	and.l	d0,d3
	moveq	#$0,d0
	move.b	d6,d0
	move.l	d0,d4
	moveq	#$C,d0
	and.l	d0,d4
	asr.l	#2,d4
	movea.l	#ram_FF948E,a2
.l4190A:
	moveq	#$0,d0
	move.b	d2,d0
	moveq	#$3,d1
	and.l	d1,d0
	move.w	d0,d5
	cmpi.w	#$1,d0
	bne.s	.l4195C
	pea	$1.w
	move.w	a4,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_20C6E
	move.l	a4,d7
	subq.w	#1,d7
	addq.l	#8,sp
	bne.s	.l41942
	movea.w	d4,a1
	exg	d0,a1
	tst.w	d0
	exg	d0,a1
	beq.s	.l41942
	move.w	a1,d5
	addq.w	#3,d5
	bra.s	.l41954
.l41942:
	move.l	a4,d0
	tst.w	d0
	bne.s	.l41954
	movea.w	d3,a1
	exg	d0,a1
	tst.w	d0
	exg	d0,a1
	beq.s	.l41954
	moveq	#$2,d5
.l41954:
	move.b	d5,d0
	add.b	d0,(a2)
	move.b	d5,d0
	add.b	d0,(a3)
.l4195C:
	move.b	d2,d0
	lsr.b	#2,d0
	move.b	d0,d2
	tst.b	d0
	beq.s	.l4196E
	subq.w	#1,a4
	move.l	a4,d0
	tst.w	d0
	bge.s	.l4190A
.l4196E:
	moveq	#$0,d0
	move.b	d6,d0
	lsr.l	#5,d0
	move.w	d0,d4
	move.w	d0,d1
	movea.l	#dat_5BFB6,a0
	moveq	#$0,d0
	move.b	($0,a0,d1.w),d0
	movea.w	d0,a1
	exg	d0,a1
	tst.w	d0
	exg	d0,a1
	beq.s	.l419BC
	moveq	#$2,d2
	moveq	#$1,d3
	moveq	#$0,d1
	subq.w	#3,d4
	seq	d1
	neg.b	d1
	movea.l	#ram_FF948C,a0
.l419A0:
	moveq	#$0,d0
	move.b	(a3),d0
	cmp.w	a1,d0
	bcs.s	.l419BC
	move.l	a1,d4
	move.b	d4,d0
	sub.b	d0,(a3)
	tst.l	d1
	beq.s	.l419B6
	move.l	d2,d0
	bra.s	.l419B8
.l419B6:
	move.l	d3,d0
.l419B8:
	add.b	d0,(a0)
	bra.s	.l419A0
.l419BC:
	movem.l	(-$24,a6),d2-d7/a2-a4
	unlk	a6
	rts
sub_419C6:
	link	a6,#$0
	pea	$C.w
	jsr	sub_20B4E
	move.b	d0,d1
	cmpi.b	#$E0,d1
	bcs.s	.l419E0
	moveq	#$0,d1
	bra.s	.l419EC
.l419E0:
	moveq	#$0,d0
	move.b	d1,d0
	move.l	d0,d1
	moveq	#$3,d0
	and.l	d0,d1
	addq.l	#1,d1
.l419EC:
	move.l	d1,d0
	unlk	a6
	rts
sub_419F2:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	move.l	($8,a6),d2
	movea.l	#ram_FF948E,a2
	jsr	sub_419C6
	move.w	d0,d3
	bne.s	.l41A14
	moveq	#$18,d0
	bra.w	.l41A8A
.l41A14:
	tst.l	d2
	beq.s	.l41A20
	cmpi.w	#$1,d3
	bls.s	.l41A20
	subq.w	#1,d3
.l41A20:
	move.w	d3,d2
	moveq	#$0,d1
	move.b	(a2),d1
	moveq	#$0,d0
	move.w	d1,d0
	divu.w	d3,d0
	swap	d0
	and.l	#$FFFF,d0
	sub.w	d0,d2
	moveq	#$0,d1
	move.b	ram_FF948C,d1
	cmp.w	d2,d1
	bcs.s	.l41A4E
	move.b	d2,d0
	sub.b	d0,ram_FF948C
	move.b	d2,d0
	add.b	d0,(a2)
.l41A4E:
	movea.l	#ram_FF948C,a0
.l41A54:
	moveq	#$0,d1
	move.b	(a0),d1
	cmp.w	d3,d1
	bcs.s	.l41A66
	move.b	d3,d0
	sub.b	d0,(a0)
	move.b	d3,d0
	add.b	d0,(a2)
	bra.s	.l41A54
.l41A66:
	cmpi.b	#$19,(a2)
	bls.s	.l41A70
	move.b	#$19,(a2)
.l41A70:
	moveq	#$0,d1
	move.b	(a2),d1
	move.w	d1,d0
	asl.w	#2,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	ext.l	d0
	divs.w	d3,d0
	ext.l	d0
	move.w	d0,d1
	moveq	#$0,d0
	move.w	d1,d0
.l41A8A:
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_41A94:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.l	($8,a6),d2
	jsr	sub_419C6
	move.w	d0,d3
	bne.s	.l41AAE
	moveq	#$1,d1
	bra.s	.l41AD6
.l41AAE:
	tst.l	d2
	beq.s	.l41ABA
	cmpi.w	#$1,d3
	bls.s	.l41ABA
	subq.w	#1,d3
.l41ABA:
	move.l	d2,-(sp)
	jsr	sub_419F2
	moveq	#$C,d1
	cmp.l	d0,d1
	bgt.s	.l41AD4
	move.b	d3,d0
	sub.b	d0,ram_FF948E
	moveq	#$1,d1
	bra.s	.l41AD6
.l41AD4:
	moveq	#$0,d1
.l41AD6:
	move.l	d1,d0
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
dat_41AE2:
	incbin	"../../build/stunrun-68k.bin",$41AE2,$5A
sub_41B3C:
	link	a6,#$0
	movem.l	d2-d5,-(sp)
	pea	$C.w
	jsr	sub_20B4E
	move.w	d0,d1
	moveq	#$0,d5
	moveq	#$2,d4
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,d3
	lsr.l	#4,d3
	moveq	#$1,d0
	and.l	d0,d3
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,d2
	moveq	#$C,d0
	and.l	d0,d2
	asr.l	#2,d2
	addq.l	#4,sp
.l41B6E:
	move.w	d4,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_20B4E
	move.l	d0,d1
	cmpi.w	#$1,d4
	addq.l	#4,sp
	bne.s	.l41B8C
	move.w	d2,d0
	beq.s	.l41B8C
	addq.w	#3,d0
	bra.s	.l41B9A
.l41B8C:
	tst.w	d4
	bne.s	.l41B98
	move.w	d3,d0
	beq.s	.l41B98
	moveq	#$2,d0
	bra.s	.l41B9A
.l41B98:
	moveq	#$1,d0
.l41B9A:
	bra.s	.l41BA0
.l41B9C:
	add.l	d1,d5
	subq.w	#1,d0
.l41BA0:
	tst.w	d0
	bhi.s	.l41B9C
	subq.w	#1,d4
	tst.w	d4
	bge.s	.l41B6E
	move.l	d5,d0
	movem.l	(-$10,a6),d2-d5
	unlk	a6
	rts
sub_41BB6:
	link	a6,#$0
	movem.l	d2,-(sp)
	pea	$9.w
	jsr	sub_20B4E
	move.w	d0,d2
	pea	$8.w
	jsr	sub_20B4E
	add.w	d0,d2
	moveq	#$0,d0
	move.w	d2,d0
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_41BE4:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	jsr	sub_419C6
	move.l	d0,d1
	tst.l	d2
	beq.s	.l41C04
	moveq	#$1,d0
	cmp.l	d1,d0
	bge.s	.l41C04
	subq.l	#1,d1
.l41C04:
	moveq	#$0,d0
	move.b	ram_FF948E,d0
	sub.l	d0,d1
	tst.l	d1
	bge.s	.l41C14
	moveq	#$0,d1
.l41C14:
	move.l	d1,d0
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_41C20:
	link	a6,#$0
	movem.l	d2-d3/a2-a3,-(sp)
	movea.l	($8,a6),a2
	movea.l	($C,a6),a3
	move.l	($10,a6),d0
	move.l	d0,-(sp)
	jsr	sub_419F2
	move.w	d0,d3
	moveq	#$0,d0
	move.w	d3,d0
	divu.w	#$C,d0
	move.w	d0,d1
	moveq	#$0,d0
	move.w	d3,d0
	divu.w	#$C,d0
	swap	d0
	and.l	#$FFFF,d0
	move.w	d0,d2
	tst.w	d1
	bne.s	.l41C62
	tst.w	d2
	bne.s	.l41C78
.l41C62:
	moveq	#$0,d0
	move.w	d1,d0
	move.l	d0,-(sp)
	pea	dat_5BDF4
	move.l	a2,-(sp)
	jsr	sub_30220
	bra.s	.l41C7A
.l41C78:
	clr.b	(a2)
.l41C7A:
	tst.w	d2
	bne.s	.l41C82
	clr.b	(a3)
	bra.s	.l41C9E
.l41C82:
	move.w	d2,d0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	movea.l	#dat_5BFBE,a0
	pea	($0,a0,d0.w)
	move.l	a3,-(sp)
	jsr	sub_2E4B4
.l41C9E:
	moveq	#$0,d0
	move.w	d3,d0
	movem.l	(-$10,a6),d2-d3/a2-a3
	unlk	a6
	rts
sub_41CAC:
	link	a6,#$0
	jsr	sub_2F126
	pea	$1.w
	clr.l	-(sp)
	jsr	sub_2D706
	pea	$1.w
	jsr	sub_2F502
	unlk	a6
	rts
sub_41CD0:
	link	a6,#$0
	move.l	#$FFFFFFFF,-(sp)
	jsr	sub_2F1BE
	unlk	a6
	rts
dat_41CE4:
	incbin	"../../build/stunrun-68k.bin",$41CE4,$4E
sub_41D32:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	move.b	($B,a6),d3
	move.b	($F,a6),d2
	move.l	($10,a6),d4
	move.b	d2,ram_FF94E8
	move.l	d4,-(sp)
	jsr	sub_2E4E6
	move.b	d3,d1
	ext.w	d1
	ext.l	d1
	add.l	d1,d0
	move.b	d0,ram_FF94E6
	clr.l	-(sp)
	pea	$F.w
	move.b	d2,d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	moveq	#$30,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2F2CC
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_41D92:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.b	($B,a6),d0
	move.l	($C,a6),d1
	tst.b	dat_2041C
	beq.s	.l41DAE
	moveq	#$30,d2
	bra.s	.l41DB0
.l41DAE:
	moveq	#$40,d2
.l41DB0:
	move.l	d1,-(sp)
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	jsr	sub_2E4E6
	sub.l	d0,d2
	asr.l	#1,d2
	addq.l	#4,sp
	move.l	d2,-(sp)
	jsr	sub_41D32
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_41DD8:
	link	a6,#$0
	movem.l	d2-d3,-(sp)
	move.b	($B,a6),d0
	move.l	($C,a6),d1
	move.l	($10,a6),d3
	tst.b	dat_2041C
	beq.s	.l41DF8
	moveq	#$30,d2
	bra.s	.l41DFA
.l41DF8:
	moveq	#$40,d2
.l41DFA:
	move.l	d1,-(sp)
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	jsr	sub_2E4E6
	sub.l	d0,d2
	move.l	d3,-(sp)
	jsr	sub_2E4E6
	sub.l	d0,d2
	asr.l	#1,d2
	addq.l	#8,sp
	move.l	d2,-(sp)
	jsr	sub_41D32
	move.l	d3,-(sp)
	jsr	sub_41E34
	movem.l	(-$8,a6),d2-d3
	unlk	a6
	rts
sub_41E34:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	clr.l	-(sp)
	pea	$F.w
	move.b	ram_FF94E8,d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	moveq	#$30,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	move.b	ram_FF94E6,d0
	ext.w	d0
	ext.l	d0
	asl.l	#3,d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	jsr	sub_2F2CC
	move.l	d2,-(sp)
	jsr	sub_2E4E6
	add.b	d0,ram_FF94E6
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_41E86:
	link	a6,#$0
	move.l	($8,a6),d0
	move.l	d0,-(sp)
	move.b	ram_FF94E8,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	move.b	ram_FF94E6,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_41EB2
	unlk	a6
	rts
sub_41EB2:
	link	a6,#$FFF4
	movem.l	d2-d4,-(sp)
	move.b	($B,a6),d3
	move.b	($F,a6),d4
	move.l	($10,a6),d0
	moveq	#$20,d2
	pea	$1.w
	pea	$B.w
	pea	(-$C,a6)
	move.l	d0,-(sp)
	jsr	sub_211F2
	lea	(-$C,a6),a0
	lea	($10,sp),sp
	bra.s	.l41EE8
.l41EE6:
	addq.l	#1,a0
.l41EE8:
	move.b	(a0),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d2,d0
	beq.s	.l41EE6
	move.l	a0,-(sp)
	move.b	d4,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_41D32
	lea	($C,sp),sp
	movem.l	(-$18,a6),d2-d4
	unlk	a6
	rts
sub_41F18:
	link	a6,#$0
	move.l	dat_439BC,-(sp)
	pea	dat_5C006
	pea	$1B.w
	jsr	sub_41DD8
	pea	str_5C008
	pea	$1C.w
	jsr	sub_41D92
	unlk	a6
	rts
sub_41F46:
	link	a6,#$0
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	($8,a6),d2
	movea.l	#ram_FF94DE,a1
	move.l	ram_FF94E2,d3
	move.l	ram_FF9490,d0
	move.l	d0,ram_FF94E2
	sub.l	d3,d0
	move.l	d0,d3
	moveq	#$0,d6
	movea.l	#ram_FF94CE,a2
	moveq	#$0,d0
	move.b	ram_FF94CD,d0
	bra.s	.l41F92
.l41F80:
	btst	#$0,d1
	beq.s	.l41F8C
	move.l	d3,d0
	add.l	d0,(a2)
	addq.l	#1,d6
.l41F8C:
	addq.l	#4,a2
	move.l	d1,d0
	lsr.l	#1,d0
.l41F92:
	move.l	d0,d1
	tst.l	d1
	bne.s	.l41F80
	move.l	d6,d0
	addq.l	#1,d0
	asl.w	#2,d0
	movea.l	#ram_FF94CE,a0
	move.l	d3,d1
	add.l	d1,($0,a0,d0.w)
	tst.b	ram_FF94CD
	beq.s	.l41FBC
	tst.l	d2
	bne.s	.l41FBC
	move.l	#$3840,(a1)
.l41FBC:
	move.l	d3,d0
	add.l	d0,(a1)
	move.l	(a1),d1
	cmpi.l	#$3840,d1
	bcs.s	.l4201A
	move.w	#$E10,d5
	moveq	#$1,d4
	clr.l	(a1)
	movea.l	#ram_FF94D2,a2
	moveq	#$0,d6
	moveq	#$3,d3
	bra.s	.l42014
.l41FDE:
	moveq	#$0,d1
	move.w	d5,d1
	move.l	d1,d0
	move.l	(a2),d1
	movea.l	d1,a0
	cmp.l	d1,d0
	bcc.s	.l4200E
	move.l	a0,d0
	divu.w	d5,d0
	movea.w	d0,a3
	moveq	#$0,d1
	move.w	a3,d1
	move.l	d1,-(sp)
	move.l	d3,-(sp)
	jsr	sub_20C6E
	moveq	#$0,d1
	move.w	a3,d1
	move.l	d1,d0
	mulu.w	#$E10,d0
	sub.l	d0,(a2)
	addq.l	#8,sp
.l4200E:
	addq.l	#4,a2
	addq.l	#1,d6
	addq.l	#1,d3
.l42014:
	move.l	d4,d0
	cmp.l	d6,d0
	bcc.s	.l41FDE
.l4201A:
	move.b	d2,ram_FF94CD
	move.l	#$FF94CE,d0
	movem.l	(-$1C,a6),d2-d6/a2-a3
	unlk	a6
	rts
dat_42030:
	incbin	"../../build/stunrun-68k.bin",$42030,$46
sub_42076:
	link	a6,#$0
	movem.l	d2-d5/a2,-(sp)
	move.w	($A,a6),d3
	clr.l	-(sp)
	jsr	sub_41F46
	movea.l	d0,a1
	move.l	a1,d0
	moveq	#$C,d1
	add.l	d1,d0
	move.l	(a1),d2
	movea.l	d0,a2
	add.l	d2,(a2)
	movea.l	d0,a2
	move.l	(a2),d4
	cmpi.l	#$E10,d4
	bls.s	.l420BE
	move.l	d4,d1
	divu.w	#$E10,d1
	move.w	d1,d4
	move.l	a1,d0
	moveq	#$C,d1
	add.l	d1,d0
	moveq	#$0,d2
	move.w	d4,d2
	mulu.w	#$E10,d2
	movea.l	d0,a0
	sub.l	d2,(a0)
.l420BE:
	move.l	(a1),d4
	lsr.l	#2,d4
	clr.l	(a1)
	move.b	dat_20419,d1
	ext.w	d1
	ext.l	d1
	asr.l	#3,d1
	moveq	#$3,d0
	and.l	d0,d1
	movea.l	#dat_5C3F2,a0
	move.b	($0,a0,d1.w),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,d2
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#3,d0
	sub.l	d1,d0
	add.l	d2,d0
	move.l	d4,d1
	divu.w	d0,d1
	move.w	d1,d5
	move.b	dat_20419,d1
	ext.w	d1
	ext.l	d1
	asr.l	#5,d1
	andi.w	#$7,d1
	cmp.w	d1,d5
	bcc.s	.l4210C
	moveq	#$0,d0
	bra.s	.l42116
.l4210C:
	moveq	#$0,d0
	move.w	d5,d0
	moveq	#$0,d2
	move.w	d1,d2
	sub.l	d2,d0
.l42116:
	move.w	d0,d5
	cmpi.w	#$13,d5
	bls.s	.l42120
	moveq	#$13,d5
.l42120:
	tst.w	d3
	beq.s	.l4212E
	pea	$1.w
	pea	$9.w
	bra.s	.l42136
.l4212E:
	pea	$1.w
	pea	$8.w
.l42136:
	jsr	sub_20C6E
	move.w	ram_FF9578,d4
	cmpi.w	#$13,d4
	bls.s	.l4214A
	moveq	#$13,d4
.l4214A:
	pea	$C.w
	pea	$1.w
	moveq	#$0,d2
	move.w	d4,d2
	move.l	d2,-(sp)
	pea	$2.w
	jsr	sub_421B6
	move.l	#$1388,d1
	move.l	ram_FF9532,d0
	jsr	sub_23E62
	move.l	d0,d4
	moveq	#$13,d1
	cmp.l	d4,d1
	bcc.s	.l4217E
	moveq	#$13,d4
.l4217E:
	pea	$10.w
	pea	$1.w
	move.l	d4,-(sp)
	pea	$4.w
	jsr	sub_421B6
	pea	$3.w
	pea	$1.w
	moveq	#$0,d2
	move.w	d5,d2
	move.l	d2,-(sp)
	moveq	#$0,d2
	move.w	d3,d2
	move.l	d2,-(sp)
	jsr	sub_421B6
	movem.l	(-$14,a6),d2-d5/a2
	unlk	a6
	rts
sub_421B6:
	link	a6,#$0
	movem.l	d2-d6/a2,-(sp)
	move.l	($8,a6),d2
	move.l	($C,a6),d5
	move.l	($10,a6),d4
	move.l	d4,-(sp)
	move.l	d5,-(sp)
	move.l	d2,-(sp)
	jsr	sub_20B04
	move.l	d0,d4
	cmpi.l	#$FF,d0
	lea	($C,sp),sp
	bls.w	.l42258
	moveq	#$1,d3
	moveq	#$1,d0
	move.b	d2,d1
	asl.l	d1,d0
	or.l	d0,($14,a6)
	moveq	#$7,d6
.l421F4:
	move.l	d3,d0
	move.b	d6,d1
	asl.l	d1,d0
	and.l	($14,a6),d0
	beq.s	.l4223C
	clr.w	d0
	movea.w	d0,a2
.l42204:
	move.w	a2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_20A86
	move.w	d0,d0
	addq.l	#8,sp
	blt.s	.l4223C
	ext.l	d0
	asr.l	#1,d0
	move.l	d0,-(sp)
	move.w	a2,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_20AC0
	lea	($C,sp),sp
	addq.w	#1,a2
	bra.s	.l42204
.l4223C:
	subq.w	#1,d6
	tst.w	d6
	bge.s	.l421F4
	move.l	d4,d0
	addq.l	#1,d0
	lsr.l	#1,d0
	move.l	d0,-(sp)
	move.l	d5,-(sp)
	move.l	d2,-(sp)
	jsr	sub_20AC0
	lea	($C,sp),sp
.l42258:
	movem.l	(-$18,a6),d2-d6/a2
	unlk	a6
	rts
sub_42262:
	link	a6,#$FFF4
	movem.l	d2-d6/a2-a3,-(sp)
	move.w	($A,a6),d4
	move.w	d4,d0
	asl.w	#2,d0
	movea.l	#dat_5C47C,a0
	movea.l	($0,a0,d0.w),a3
	cmpa.w	#$0,a3
	bne.s	.l42288
	clr.w	d5
	bra.w	.l4230A
.l42288:
	moveq	#$4,d5
	clr.w	d6
	moveq	#$3,d2
	lea	(-$A,a6),a2
.l42292:
	moveq	#$3A,d1
	movea.l	a2,a0
.l42296:
	tst.b	(a3)
	beq.s	.l422A8
	move.b	(a3),d0
	ext.w	d0
	ext.l	d0
	cmp.l	d1,d0
	beq.s	.l422A8
	move.b	(a3)+,(a0)+
	bra.s	.l42296
.l422A8:
	tst.b	(a3)
	bne.s	.l422AE
	bra.s	.l4230A
.l422AE:
	addq.l	#1,a3
	clr.b	(a0)
	pea	(-$A,a6)
	move.l	d2,-(sp)
	moveq	#$8,d0
	move.l	a0,d1
	lea	(-$A,a6),a0
	sub.l	a0,d1
	clr.b	d3
	asr.l	d3,d1
	sub.l	d1,d0
	move.l	d0,-(sp)
	jsr	sub_41D32
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	d4,d1
	ext.l	d1
	move.l	d1,-(sp)
	jsr	sub_20A86
	move.w	d0,d3
	ext.l	d0
	addq.l	#8,sp
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	pea	$9.w
	jsr	sub_41EB2
	cmp.w	d5,d3
	lea	($18,sp),sp
	ble.s	.l42300
	move.w	d3,d5
.l42300:
	addq.w	#1,d6
	addq.l	#1,d2
	cmpi.w	#$14,d6
	blt.s	.l42292
.l4230A:
	move.w	d5,d0
	ext.l	d0
	movem.l	(-$28,a6),d2-d6/a2-a3
	unlk	a6
	rts
sub_42318:
	link	a6,#$FFEC
	movem.l	d2-d7/a2-a5,-(sp)
	movea.l	($8,a6),a4
	move.l	#dat_20419,(-$4,a6)
	movea.l	(-$4,a6),a0
	move.b	(a0),(-$5,a6)
	move.w	(-$6,a6),d0
	ext.w	d0
	move.w	d0,(-$6,a6)
	andi.w	#$7,(-$6,a6)
	tst.w	(-$6,a6)
	beq.w	.l426B8
	clr.w	(-$C,a6)
	movea.l	#dat_5C3F2,a3
	movea.l	#dat_20400,a2
	moveq	#$0,d3
	move.l	a4,d0
	sne	d3
	neg.b	d3
	bra.w	.l426AC
.l42368:
	jsr	sub_41CAC
	cmpi.w	#$1,(-$6,a6)
	ble.s	.l423B6
	pea	str_5C018
	pea	$1.w
	jsr	sub_41D92
	move.w	(-$C,a6),d0
	ext.l	d0
	addq.l	#1,d0
	move.l	d0,-(sp)
	jsr	sub_41E86
	move.w	(-$C,a6),d0
	asl.w	#2,d0
	movea.l	#dat_5C3F6,a0
	move.l	($0,a0,d0.w),-(sp)
	pea	$2.w
	jsr	sub_41D92
	lea	($14,sp),sp
	bra.s	.l423C8
.l423B6:
	pea	str_5C024
	pea	$1.w
	jsr	sub_41D92
	addq.l	#8,sp
.l423C8:
	move.w	(-$C,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	sub_42262
	move.w	d0,(-$A,a6)
	addq.l	#4,sp
	bne.w	.l42542
	moveq	#$64,d4
	moveq	#$2,d5
	moveq	#$1,d6
	clr.w	(-$12,a6)
	movea.l	(-$4,a6),a1
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	andi.l	#$E0,d0
	asr.l	#5,d0
	move.w	d0,(-$8,a6)
	addq.w	#1,(-$8,a6)
	move.w	(-$8,a6),(-$E,a6)
	movea.l	(-$4,a6),a1
	move.b	(a1),d0
	ext.w	d0
	ext.l	d0
	moveq	#$18,d1
	and.l	d1,d0
	asr.l	#3,d0
	movea.l	#dat_5C3F2,a0
	move.b	($0,a0,d0.w),d0
	ext.w	d0
	move.w	(-$E,a6),d7
	muls.w	d0,d7
	move.w	d7,(-$E,a6)
	subq.w	#1,(-$E,a6)
	moveq	#$4,d7
	move.w	d7,(-$A,a6)
	clr.w	(-$10,a6)
	moveq	#$3,d2
.l42440:
	cmpi.w	#$A,(-$12,a6)
	bge.s	.l4244C
	moveq	#$3,d0
	bra.s	.l4245C
.l4244C:
	move.w	(-$12,a6),d0
	ext.l	d0
	cmp.l	d4,d0
	bge.s	.l4245A
	move.l	d5,d0
	bra.s	.l4245C
.l4245A:
	move.l	d6,d0
.l4245C:
	move.w	d0,(-$8,a6)
	move.w	(-$12,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	move.w	(-$8,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	jsr	sub_41EB2
	pea	dat_5C03C
	move.l	d2,-(sp)
	pea	$4.w
	jsr	sub_41D32
	cmpi.w	#$13,(-$10,a6)
	lea	($18,sp),sp
	beq.s	.l424AC
	move.w	(-$E,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	pea	$5.w
	jsr	sub_41EB2
	bra.s	.l424C0
.l424AC:
	pea	dat_5C03E
	pea	$16.w
	pea	$4.w
	jsr	sub_41D32
.l424C0:
	lea	($C,sp),sp
	move.w	(-$E,a6),(-$12,a6)
	addq.w	#1,(-$12,a6)
	movea.l	(-$4,a6),a5
	move.b	(a5),d0
	ext.w	d0
	ext.l	d0
	moveq	#$18,d1
	and.l	d1,d0
	asr.l	#3,d0
	move.b	($0,a3,d0.w),d0
	ext.w	d0
	move.w	(-$E,a6),d7
	add.w	d0,d7
	move.w	d7,(-$E,a6)
	move.w	(-$10,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$C,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	jsr	sub_20A86
	move.l	d0,d1
	move.w	d1,d0
	move.w	d0,(-$8,a6)
	ext.l	d0
	addq.l	#8,sp
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	pea	$9.w
	jsr	sub_41EB2
	move.w	(-$8,a6),d7
	cmp.w	(-$A,a6),d7
	lea	($C,sp),sp
	ble.s	.l42532
	move.w	(-$8,a6),(-$A,a6)
.l42532:
	addq.w	#1,(-$10,a6)
	addq.l	#1,d2
	cmpi.w	#$14,(-$10,a6)
	blt.w	.l42440
.l42542:
	moveq	#$30,d4
	moveq	#$40,d5
	moveq	#$70,d6
	clr.w	(-$10,a6)
	moveq	#$3,d2
.l4254E:
	move.w	(-$10,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	(-$C,a6),d1
	ext.l	d1
	move.l	d1,-(sp)
	jsr	sub_20A86
	move.w	d0,(-$8,a6)
	tst.b	($1C,a2)
	addq.l	#8,sp
	beq.s	.l42574
	move.l	d4,d0
	bra.s	.l42576
.l42574:
	move.l	d5,d0
.l42576:
	pea	$5.w
	pea	$8.w
	moveq	#$E,d1
	sub.l	d1,d0
	asl.l	#3,d0
	move.w	d0,d1
	ext.l	d1
	muls.w	(-$8,a6),d1
	move.l	d1,d0
	divs.w	(-$A,a6),d0
	ext.l	d0
	move.l	d0,-(sp)
	move.l	d2,d0
	asl.l	#3,d0
	add.l	d4,d0
	move.l	d0,-(sp)
	move.l	d6,-(sp)
	jsr	sub_2F674
	lea	($14,sp),sp
	addq.w	#1,(-$10,a6)
	addq.l	#1,d2
	cmpi.w	#$14,(-$10,a6)
	blt.s	.l4254E
	move.w	(-$C,a6),d0
	ext.l	d0
	move.w	(-$6,a6),d1
	ext.l	d1
	subq.l	#1,d1
	cmp.l	d1,d0
	bne.s	.l4261C
	jsr	sub_41F18
	move.l	a4,d2
	beq.s	.l4261A
	move.l	dat_439C0,-(sp)
	pea	dat_5C044
	pea	$18.w
	jsr	sub_41DD8
	cmpi.w	#$1,(-$6,a6)
	lea	($C,sp),sp
	ble.s	.l425FE
	movea.l	#str_5C050,a0
	bra.s	.l42604
.l425FE:
	movea.l	#str_5C060,a0
.l42604:
	move.l	a0,-(sp)
	pea	str_5C046
	pea	$19.w
	jsr	sub_41DD8
	lea	($C,sp),sp
.l4261A:
	bra.s	.l42646
.l4261C:
	move.l	dat_439BC,-(sp)
	pea	dat_5C06A
	pea	$18.w
	jsr	sub_41DD8
	pea	str_5C06C
	pea	$19.w
	jsr	sub_41D92
	lea	($14,sp),sp
.l42646:
	moveq	#$1,d4
	jsr	sub_41CD0
	moveq	#$0,d2
	move.w	(-$C,a6),d0
	ext.l	d0
	move.w	(-$6,a6),d1
	ext.l	d1
	subq.l	#1,d1
	cmp.l	d1,d0
	seq	d2
	neg.b	d2
.l42664:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,(-$8,a6)
	btst	#$0,d0
	addq.l	#4,sp
	bne.s	.l426A8
	tst.l	d2
	beq.s	.l4269C
	btst	#$1,(-$7,a6)
	beq.s	.l4269C
	tst.l	d3
	beq.s	.l4269C
	clr.l	-(sp)
	pea	$E.w
	jsr	sub_20BB4
	subq.w	#1,(-$C,a6)
	addq.l	#8,sp
	bra.s	.l426A8
.l4269C:
	move.l	d4,-(sp)
	jsr	sub_21178
	addq.l	#4,sp
	bra.s	.l42664
.l426A8:
	addq.w	#1,(-$C,a6)
.l426AC:
	move.w	(-$C,a6),d0
	cmp.w	(-$6,a6),d0
	blt.w	.l42368
.l426B8:
	movem.l	(-$3C,a6),d2-d7/a2-a5
	unlk	a6
	rts
sub_426C2:
	link	a6,#$0
	movem.l	d2-d4,-(sp)
	jsr	sub_41B3C
	move.l	d0,d3
	tst.l	d3
	bne.s	.l426DC
	moveq	#$0,d0
	bra.w	.l42750
.l426DC:
	pea	$4.w
	jsr	sub_20B4E
	move.l	d0,d4
	cmpi.l	#$FFFF,d3
	addq.l	#4,sp
	bhi.s	.l426FA
	cmpi.l	#$FFFF,d4
	bls.s	.l4273C
.l426FA:
	move.l	#$1FFFE,d2
	moveq	#$1,d1
.l42702:
	move.l	d2,d0
	cmp.l	d3,d0
	bcs.s	.l4270E
	move.l	d2,d0
	cmp.l	d4,d0
	bcc.s	.l4272C
.l4270E:
	move.l	d1,d0
	cmp.l	d3,d0
	bne.s	.l4271E
	move.l	d4,d0
	lsl.l	#4,d0
	sub.l	d4,d0
	lsl.l	#2,d0
	bra.s	.l42750
.l4271E:
	move.l	d3,d0
	lsr.l	#1,d0
	move.l	d0,d3
	move.l	d4,d0
	lsr.l	#1,d0
	move.l	d0,d4
	bra.s	.l42702
.l4272C:
	move.l	d3,d0
	addq.l	#1,d0
	lsr.l	#1,d0
	move.l	d0,d3
	move.l	d4,d0
	addq.l	#1,d0
	lsr.l	#1,d0
	move.l	d0,d4
.l4273C:
	moveq	#$0,d0
	move.w	d4,d0
	asl.l	#2,d0
	move.l	d0,d1
	asl.l	#4,d0
	sub.l	d1,d0
	divu.w	d3,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d0
.l42750:
	movem.l	(-$C,a6),d2-d4
	unlk	a6
	rts
sub_4275A:
	link	a6,#$0
	movem.l	d2,-(sp)
	jsr	sub_41BB6
	move.l	d0,d2
	pea	str_5C07C
	pea	$19.w
	jsr	sub_41D92
	move.l	d2,-(sp)
	jsr	sub_41E86
	tst.l	d2
	beq.s	.l427DA
	jsr	sub_41B3C
	move.l	d0,d2
	tst.l	d2
	bne.s	.l42796
	moveq	#$0,d0
	bra.s	.l427DA
.l42796:
	pea	str_5C08C
	pea	$1A.w
	jsr	sub_41D92
	move.l	d2,-(sp)
	jsr	sub_41E86
	jsr	sub_426C2
	move.l	d0,d2
	pea	dat_5C09A
	pea	$1B.w
	jsr	sub_41D92
	move.l	d2,-(sp)
	jsr	sub_41E86
	pea	dat_5C0AA
	jsr	sub_41E34
.l427DA:
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_427E4:
	link	a6,#$FFB0
	movem.l	d2-d6/a2-a4,-(sp)
	move.l	($8,a6),d5
	moveq	#$1,d0
	move.l	d0,(-$4,a6)
	movea.l	#sub_41D92,a3
.l427FC:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,d1
	btst	#$0,d0
	addq.l	#4,sp
	bne.w	.l4297A
	btst	#$1,d1
	beq.s	.l42836
	tst.l	d5
	beq.s	.l42836
	moveq	#$C,d2
	moveq	#$0,d3
.l4281E:
	clr.l	-(sp)
	move.l	d3,-(sp)
	jsr	sub_20BB4
	addq.l	#8,sp
	addq.l	#1,d3
	cmp.l	d2,d3
	blt.s	.l4281E
	moveq	#$1,d0
	move.l	d0,(-$4,a6)
.l42836:
	tst.l	(-$4,a6)
	beq.w	.l4296A
	jsr	sub_41CAC
	pea	dat_47606
	pea	$3.w
	jsr	(a3)
	tst.b	dat_2041C
	addq.l	#8,sp
	beq.s	.l4285E
	moveq	#$0,d0
	bra.s	.l42860
.l4285E:
	moveq	#$4,d0
.l42860:
	moveq	#$B,d3
	moveq	#$4B,d4
	move.l	#$C8,d6
	move.l	d0,(-$C,a6)
	pea	str_5C0B0
	pea	$1.w
	jsr	(a3)
	clr.l	(-$4,a6)
	movea.l	#dat_5C0BC,a4
	moveq	#$5,d2
	movea.l	#str_5C1CC,a2
	addq.l	#8,sp
	bra.s	.l428EA
.l42890:
	move.l	(a4),-(sp)
	move.l	d2,-(sp)
	jsr	(a3)
	moveq	#$0,d0
	move.w	($4,a4),d0
	move.l	d0,-(sp)
	jsr	sub_20B4E
	move.l	d0,(-$8,a6)
	addq.l	#4,sp
	move.l	d0,-(sp)
	jsr	sub_41E86
	moveq	#$0,d0
	move.w	($4,a4),d0
	move.l	d0,d1
	cmp.l	d3,d1
	lea	($C,sp),sp
	bne.s	.l428E2
	move.l	d4,d1
	cmp.l	(-$8,a6),d1
	bcc.s	.l428E2
	clr.l	-(sp)
	pea	$3.w
	pea	$B0.w
	move.l	d6,-(sp)
	pea	(a2)
	jsr	sub_2F2CC
	lea	($14,sp),sp
.l428E2:
	addq.l	#1,(-$4,a6)
	addq.l	#1,d2
	addq.l	#6,a4
.l428EA:
	movea.l	(a4),a0
	tst.b	(a0)
	bne.s	.l42890
	tst.l	d5
	beq.s	.l42918
	move.l	dat_439C0,-(sp)
	pea	str_5C1DA
	pea	(-$4E,a6)
	jsr	sub_30220
	pea	(-$4E,a6)
	pea	$14.w
	jsr	(a3)
	lea	($14,sp),sp
.l42918:
	move.b	dat_20419,d1
	ext.w	d1
	ext.l	d1
	moveq	#$7,d0
	and.l	d0,d1
	beq.s	.l4294E
	move.l	dat_439BC,-(sp)
	pea	str_5C1F2
	pea	(-$4E,a6)
	jsr	sub_30220
	pea	(-$4E,a6)
	pea	$16.w
	jsr	(a3)
	lea	($14,sp),sp
	bra.s	.l42954
.l4294E:
	jsr	sub_41F18
.l42954:
	move.l	(-$C,a6),-(sp)
	jsr	sub_4275A
	jsr	sub_41CD0
	clr.l	(-$4,a6)
	addq.l	#4,sp
.l4296A:
	pea	$1.w
	jsr	sub_21178
	addq.l	#4,sp
	bra.w	.l427FC
.l4297A:
	movem.l	(-$70,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_42984:
	link	a6,#$0
	movem.l	d2,-(sp)
	move.l	($8,a6),d2
	move.l	d2,-(sp)
	jsr	sub_427E4
	move.l	d2,-(sp)
	jsr	sub_42318
	move.l	d2,-(sp)
	jsr	sub_42AF0
	move.l	d2,-(sp)
	jsr	sub_429BA
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_429BA:
	link	a6,#$FFB0
	movem.l	d2-d6/a2-a3,-(sp)
	move.l	($8,a6),d0
	clr.w	d5
	move.l	#$FF440E,d4
	move.l	#$FF4526,d3
	moveq	#$0,d2
	tst.l	d0
	sne	d2
	neg.b	d2
	movea.l	#dat_439C0,a3
	movea.l	#dat_439BC,a2
.l429E8:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,d6
	jsr	sub_41CAC
	clr.l	-(sp)
	pea	$5.w
	pea	$30.w
	pea	$100.w
	pea	str_5C204
	jsr	sub_2F8E0
	pea	$3C.w
	pea	$F.w
	pea	$F.w
	clr.l	-(sp)
	jsr	sub_3F008
	tst.l	d2
	lea	($28,sp),sp
	beq.s	.l42A5E
	tst.w	d5
	bne.s	.l42A5E
	btst	#$1,d6
	beq.s	.l42A5E
	moveq	#$1,d5
	jsr	sub_3F562
	jsr	sub_3F5B6
	jsr	sub_3F60A
	jsr	sub_3F65C
	jsr	sub_3F6AE
	jsr	sub_433BC
.l42A5E:
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	jsr	sub_2EFFE
	tst.l	d0
	addq.l	#8,sp
	bne.s	.l42A8C
	clr.l	-(sp)
	pea	$3.w
	pea	$D8.w
	pea	$100.w
	pea	str_5C210
	jsr	sub_2F8E0
	lea	($14,sp),sp
.l42A8C:
	tst.l	d2
	beq.s	.l42AB4
	move.l	(a3),-(sp)
	pea	str_5C232
	pea	(-$50,a6)
	jsr	sub_30220
	pea	(-$50,a6)
	pea	$17.w
	jsr	sub_41D92
	lea	($14,sp),sp
.l42AB4:
	move.l	(a2),-(sp)
	pea	str_5C24A
	pea	(-$50,a6)
	jsr	sub_30220
	pea	(-$50,a6)
	pea	$18.w
	jsr	sub_41D92
	jsr	sub_41CD0
	lea	($14,sp),sp
	btst	#$0,d6
	beq.w	.l429E8
	movem.l	(-$6C,a6),d2-d6/a2-a3
	unlk	a6
	rts
sub_42AF0:
	link	a6,#$FFB0
	movem.l	d2-d7/a2-a4,-(sp)
	move.w	($A,a6),d2
	moveq	#$40,d5
	clr.w	d4
.l42B00:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,d6
	jsr	sub_41CAC
	clr.l	-(sp)
	pea	$5.w
	pea	$30.w
	pea	$100.w
	pea	str_5C25C
	jsr	sub_2F8E0
	clr.w	d7
	movea.w	d7,a4
	move.l	d5,d3
	movea.l	#dat_4A954,a2
	movea.l	#io_FF4B90,a3
	lea	($18,sp),sp
.l42B40:
	moveq	#$0,d0
	move.b	(a3),d0
	move.l	d0,-(sp)
	move.l	(a2),-(sp)
	pea	dat_5C26A
	pea	(-$50,a6)
	jsr	sub_30220
	clr.l	-(sp)
	pea	$F.w
	move.l	d3,-(sp)
	pea	$20.w
	pea	(-$50,a6)
	jsr	sub_2F2CC
	lea	($24,sp),sp
	addq.w	#1,a4
	addq.l	#1,a3
	addq.l	#4,a2
	addq.l	#8,d3
	move.l	a4,d0
	cmpi.w	#$10,d0
	ble.s	.l42B40
	tst.w	d2
	beq.s	.l42BAA
	tst.w	d4
	bne.s	.l42BAA
	btst	#$1,d6
	beq.s	.l42BAA
	jsr	sub_3091E
	jsr	sub_436E4
	moveq	#$1,d4
	jsr	sub_3F562
	jsr	sub_3FA4A
.l42BAA:
	pea	io_FF4BA4
	pea	io_FF4B90
	jsr	sub_2EFFE
	tst.l	d0
	addq.l	#8,sp
	bne.s	.l42BE0
	clr.l	-(sp)
	pea	$3.w
	pea	$D8.w
	pea	$100.w
	pea	str_5C274
	jsr	sub_2F8E0
	lea	($14,sp),sp
.l42BE0:
	tst.w	d2
	beq.s	.l42C0C
	move.l	dat_439C0,-(sp)
	pea	str_5C296
	pea	(-$50,a6)
	jsr	sub_30220
	pea	(-$50,a6)
	pea	$14.w
	jsr	sub_41D92
	lea	($14,sp),sp
.l42C0C:
	move.l	dat_439BC,-(sp)
	pea	str_5C2B0
	pea	(-$50,a6)
	jsr	sub_30220
	pea	(-$50,a6)
	pea	$16.w
	jsr	sub_41D92
	jsr	sub_41CD0
	lea	($14,sp),sp
	btst	#$0,d6
	beq.w	.l42B00
	movem.l	(-$74,a6),d2-d7/a2-a4
	unlk	a6
	rts
sub_42C4C:
	link	a6,#$0
	movem.l	d2,-(sp)
	movea.l	($8,a6),a0
	moveq	#$0,d0
	move.b	(a0),d0
	movea.l	a0,a1
	addq.l	#1,a1
	moveq	#$0,d1
	move.b	(a1),d1
	move.l	d1,d2
	addq.l	#2,a0
	moveq	#$0,d1
	move.b	(a0),d1
	or.l	d1,d2
	or.l	d2,d0
	move.b	d0,d1
	moveq	#$0,d0
	move.b	d1,d0
	movem.l	(-$4,a6),d2
	unlk	a6
	rts
sub_42C80:
	link	a6,#$0
	movem.l	d2-d3/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	bra.s	.l42CC0
.l42C92:
	move.l	a2,-(sp)
	jsr	sub_42C4C
	move.b	d0,d0
	addq.l	#4,sp
	beq.s	.l42CC4
	move.b	(a2)+,d3
	moveq	#$2,d1
	moveq	#$0,d0
	move.b	d3,d0
	lsr.l	#4,d0
	andi.b	#$F,d3
	sub.b	d3,d0
	asl.l	d0,d1
	bra.s	.l42CBA
.l42CB4:
	tst.b	(a2)+
	bne.s	.l42CB4
	subq.w	#1,d1
.l42CBA:
	tst.w	d1
	bge.s	.l42CB4
	subq.w	#1,d2
.l42CC0:
	tst.w	d2
	bne.s	.l42C92
.l42CC4:
	move.l	a2,-(sp)
	jsr	sub_42C4C
	move.b	d0,d0
	addq.l	#4,sp
	bne.s	.l42CD8
	moveq	#$0,d0
	movea.l	d0,a2
	nop
.l42CD8:
	move.l	a2,d0
	movem.l	(-$C,a6),d2-d3/a2
	unlk	a6
	rts
sub_42CE4:
	link	a6,#$0
	movem.l	d2-d6/a2,-(sp)
	movea.l	($8,a6),a2
	move.w	($E,a6),d2
	move.w	($12,a6),d3
	moveq	#$0,d1
	move.b	(a2),d1
	lsr.l	#4,d1
	move.w	d1,d0
	moveq	#$0,d1
	move.b	(a2),d1
	move.w	d1,d4
	andi.w	#$F,d4
	moveq	#$2,d1
	sub.b	d4,d0
	asl.l	d0,d1
	move.w	d1,d6
	move.w	d2,d1
	move.b	d4,d0
	lsr.w	d0,d1
	move.w	d1,d2
	move.w	d6,d1
	subq.w	#1,d1
	and.w	d1,d2
	move.w	d3,d1
	move.b	d4,d0
	lsr.w	d0,d1
	move.w	d1,d3
	move.w	d6,d1
	subq.w	#1,d1
	and.w	d1,d3
	move.l	a2,-(sp)
	jsr	sub_42C4C
	move.b	d0,d0
	addq.l	#4,sp
	bne.s	.l42D44
	moveq	#$0,d0
	movea.l	d0,a2
	bra.w	.l42DCC
.l42D44:
	moveq	#$14,d4
	moveq	#$0,d1
	move.w	($16,a6),d1
	lsl.l	#3,d1
	move.w	d1,d5
	clr.l	-(sp)
	moveq	#$0,d0
	move.w	($1A,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	moveq	#$30,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,-(sp)
	addq.l	#1,a2
	move.l	a2,-(sp)
	jsr	sub_2F2CC
	clr.w	d0
	lea	($14,sp),sp
	bra.s	.l42D84
.l42D7E:
	tst.b	(a2)+
	bne.s	.l42D7E
	addq.w	#1,d0
.l42D84:
	cmp.w	d2,d0
	bls.s	.l42D7E
	addq.w	#8,d4
	addq.w	#8,d5
	cmp.w	d3,d2
	bne.s	.l42D96
	move.w	#$5,($1A,a6)
.l42D96:
	clr.l	-(sp)
	moveq	#$0,d0
	move.w	($1A,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	moveq	#$30,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_2F2CC
	move.w	d2,d0
	lea	($14,sp),sp
	bra.s	.l42DC8
.l42DC2:
	tst.b	(a2)+
	bne.s	.l42DC2
	addq.w	#1,d0
.l42DC8:
	cmp.w	d6,d0
	bcs.s	.l42DC2
.l42DCC:
	move.l	a2,d0
	movem.l	(-$18,a6),d2-d6/a2
	unlk	a6
	rts
sub_42DD8:
	link	a6,#$0
	movem.l	d2-d6,-(sp)
	move.l	($8,a6),d2
	move.w	($E,a6),d4
	move.w	($12,a6),d3
	moveq	#$0,d0
	move.w	($16,a6),d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	jsr	sub_42C80
	move.l	d0,d2
	move.l	d2,-(sp)
	jsr	sub_42C4C
	move.b	d0,d0
	lea	($C,sp),sp
	beq.s	.l42E44
	moveq	#$18,d6
	moveq	#$3,d5
	bra.s	.l42E40
.l42E14:
	moveq	#$0,d0
	move.w	($1A,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d3,d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,-(sp)
	move.l	d2,-(sp)
	jsr	sub_42CE4
	move.l	d0,d2
	lea	($14,sp),sp
	beq.s	.l42E44
	addq.w	#3,d5
.l42E40:
	cmp.w	d6,d5
	bls.s	.l42E14
.l42E44:
	movem.l	(-$14,a6),d2-d6
	unlk	a6
	rts
sub_42E4E:
	link	a6,#$FF7C
	movem.l	d2-d7/a2-a4,-(sp)
	movea.l	($8,a6),a2
	movea.w	($E,a6),a3
	move.w	($12,a6),d6
	movea.l	#sub_41D92,a4
	move.l	a2,(-$E,a6)
	moveq	#$7,d0
	move.w	d0,(-$18,a6)
	move.w	a3,(-$14,a6)
	clr.w	(-$10,a6)
	bra.s	.l42E80
.l42E7C:
	addq.w	#1,(-$10,a6)
.l42E80:
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_42C80
	tst.l	d0
	addq.l	#8,sp
	bne.s	.l42E7C
	moveq	#$1,d4
	move.w	(-$10,a6),(-$1C,a6)
	subq.w	#1,(-$1C,a6)
	clr.w	(-$16,a6)
	move.w	(-$16,a6),(-$10,a6)
	moveq	#$19,d0
	moveq	#$14,d0
	moveq	#$1,d0
	move.w	(-$18,a6),d3
	move.w	d3,d0
	add.w	d3,d3
	add.w	d0,d3
	ext.l	d3
	addq.l	#2,d3
	moveq	#$0,d0
	move.w	(-$18,a6),d0
	move.l	d0,d5
	move.l	d5,d0
	add.l	d5,d5
	add.l	d0,d5
	addq.l	#5,d5
.l42ED0:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,(-$12,a6)
	btst	#$0,d0
	addq.l	#4,sp
	bne.w	.l43294
	jsr	sub_41CAC
	move.w	d3,(-$A,a6)
	move.l	($14,a6),-(sp)
	clr.l	-(sp)
	jsr	(a4)
	pea	str_5C2C2
	addq.w	#1,(-$A,a6)
	move.w	(-$A,a6),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a4)
	pea	str_5C2EA
	addq.w	#1,(-$A,a6)
	move.w	(-$A,a6),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a4)
	pea	str_5C328
	addq.w	#1,(-$A,a6)
	move.w	(-$A,a6),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a4)
	pea	str_5C368
	addq.w	#1,(-$A,a6)
	move.w	(-$A,a6),d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a4)
	pea	$F.w
	moveq	#$0,d0
	move.w	(-$16,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	move.w	d6,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$14,a6),d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_42DD8
	tst.w	(-$16,a6)
	lea	($3C,sp),sp
	beq.s	.l42F8A
	pea	dat_5C398
	pea	$2.w
	jsr	(a4)
	addq.l	#8,sp
.l42F8A:
	move.w	(-$10,a6),d0
	sub.w	(-$16,a6),d0
	addq.w	#1,d0
	moveq	#$0,d1
	move.w	d0,d1
	move.l	d1,d0
	move.l	d0,d1
	add.l	d0,d0
	add.l	d1,d0
	move.w	d0,(-$A,a6)
	pea	$B.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d1
	move.w	d6,d1
	move.l	d1,-(sp)
	moveq	#$0,d0
	move.w	(-$14,a6),d0
	move.l	d0,-(sp)
	move.l	(-$E,a6),-(sp)
	jsr	sub_42CE4
	pea	$B.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	lsl.l	#3,d0
	moveq	#$2C,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$148.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	move.l	d0,d1
	lsl.l	#3,d1
	moveq	#$2C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$8.w
	jsr	sub_2F470
	pea	$B.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	lsl.l	#3,d0
	moveq	#$44,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$148.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	move.l	d0,d1
	lsl.l	#3,d1
	moveq	#$2C,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$148.w
	jsr	sub_2F470
	pea	$B.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	lsl.l	#3,d0
	moveq	#$44,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$8.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	move.l	d0,d1
	lsl.l	#3,d1
	moveq	#$44,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$148.w
	jsr	sub_2F470
	pea	$B.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	lsl.l	#3,d0
	moveq	#$2C,d1
	add.l	d1,d0
	move.l	d0,-(sp)
	pea	$8.w
	moveq	#$0,d0
	move.w	(-$A,a6),d0
	move.l	d0,d1
	lsl.l	#3,d1
	moveq	#$44,d0
	add.l	d0,d1
	move.l	d1,-(sp)
	pea	$8.w
	jsr	sub_2F470
	moveq	#$0,d0
	move.w	(-$18,a6),d0
	moveq	#$0,d1
	move.w	(-$1C,a6),d1
	moveq	#$0,d2
	move.w	(-$16,a6),d2
	sub.l	d2,d1
	cmp.l	d1,d0
	lea	($64,sp),sp
	bcc.s	.l430B6
	pea	str_5C3A4
	move.b	d5,d0
	ext.w	d0
	ext.l	d0
	move.l	d0,-(sp)
	jsr	(a4)
	addq.l	#8,sp
.l430B6:
	jsr	sub_41CD0
	clr.w	d0
	btst	#$1,(-$11,a6)
	beq.s	.l430CE
	move.w	a3,(-$14,a6)
	clr.w	(-$10,a6)
.l430CE:
	btst	#$6,(-$11,a6)
	beq.s	.l430EC
	addq.w	#1,(-$10,a6)
	move.w	(-$10,a6),d0
	move.w	(-$1C,a6),d1
	cmp.w	d0,d1
	bcc.s	.l430EC
	clr.w	(-$10,a6)
	bra.s	.l43100
.l430EC:
	btst	#$7,(-$11,a6)
	beq.s	.l43100
	subq.w	#1,(-$10,a6)
	bcc.s	.l43100
	move.w	(-$1C,a6),(-$10,a6)
.l43100:
	moveq	#$0,d0
	move.w	(-$12,a6),d0
	andi.l	#$C2,d0
	beq.s	.l43162
	move.w	d4,d0
	move.w	(-$16,a6),d1
	cmp.w	(-$10,a6),d1
	bls.s	.l43122
	move.w	(-$10,a6),(-$16,a6)
	bra.s	.l4314C
.l43122:
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	moveq	#$0,d1
	move.w	(-$18,a6),d1
	moveq	#$0,d2
	move.w	(-$16,a6),d2
	add.l	d2,d1
	cmp.l	d1,d0
	bls.s	.l4314C
	move.w	(-$10,a6),(-$16,a6)
	move.w	(-$16,a6),d0
	sub.w	(-$18,a6),d0
	move.w	d0,(-$16,a6)
.l4314C:
	moveq	#$0,d0
	move.w	(-$10,a6),d0
	move.l	d0,-(sp)
	move.l	a2,-(sp)
	jsr	sub_42C80
	move.l	d0,(-$E,a6)
	addq.l	#8,sp
.l43162:
	moveq	#$0,d0
	movea.l	(-$E,a6),a1
	move.b	(a1),d0
	movea.w	d0,a0
	move.l	a0,d7
	andi.w	#$F,d7
	movea.w	d7,a0
	move.l	d4,d0
	moveq	#$0,d1
	movea.l	(-$E,a6),a1
	move.b	(a1),d1
	lsr.l	#4,d1
	addq.b	#1,d1
	move.l	a0,d7
	sub.b	d7,d1
	asl.l	d1,d0
	move.w	d0,(-$1E,a6)
	moveq	#$0,d0
	move.w	(-$1E,a6),d0
	subq.l	#1,d0
	move.l	a0,d7
	move.b	d7,d1
	asl.l	d1,d0
	move.w	d0,(-$1A,a6)
	moveq	#$0,d2
	btst	#$4,(-$11,a6)
	sne	d2
	neg.b	d2
	moveq	#$0,d7
	move.l	d7,(-$8,a6)
	btst	#$5,(-$11,a6)
	sne	(-$5,a6)
	neg.b	(-$5,a6)
	moveq	#$0,d7
	move.l	d7,(-$4,a6)
	moveq	#$0,d0
	move.w	(-$12,a6),d0
	moveq	#$30,d1
	and.l	d1,d0
	sne	(-$1,a6)
	neg.b	(-$1,a6)
.l431D6:
	tst.l	(-$4,a6)
	beq.w	.l43290
	move.w	d4,d0
	tst.l	(-$8,a6)
	beq.s	.l43218
	moveq	#$0,d0
	move.w	(-$1A,a6),d0
	moveq	#$0,d1
	move.w	(-$14,a6),d1
	and.l	d1,d0
	bne.s	.l43204
	move.w	(-$14,a6),d0
	or.w	(-$1A,a6),d0
	move.w	d0,(-$14,a6)
	bra.s	.l43216
.l43204:
	move.l	d4,d0
	move.l	a0,d7
	move.b	d7,d1
	asl.l	d1,d0
	move.w	(-$14,a6),d7
	sub.w	d0,d7
	move.w	d7,(-$14,a6)
.l43216:
	bra.s	.l43254
.l43218:
	tst.l	d2
	beq.s	.l43254
	move.l	d4,d0
	move.l	a0,d7
	move.b	d7,d1
	asl.l	d1,d0
	move.w	(-$14,a6),d7
	add.w	d0,d7
	move.w	d7,(-$14,a6)
	moveq	#$0,d0
	move.w	(-$1A,a6),d0
	moveq	#$0,d1
	move.w	(-$14,a6),d1
	and.l	d1,d0
	bne.s	.l43254
	moveq	#$0,d0
	move.w	(-$1E,a6),d0
	move.l	a0,d7
	move.b	d7,d1
	lsl.l	d1,d0
	move.w	(-$14,a6),d7
	sub.w	d0,d7
	move.w	d7,(-$14,a6)
.l43254:
	move.l	(-$E,a6),d0
	addq.l	#1,d0
	movea.l	d0,a1
	moveq	#$0,d0
	move.w	(-$1A,a6),d0
	moveq	#$0,d1
	move.w	(-$14,a6),d1
	and.l	d1,d0
	move.l	a0,d7
	move.b	d7,d1
	lsr.l	d1,d0
	move.w	d0,(-$A,a6)
	addq.w	#1,(-$A,a6)
	bra.s	.l43282
.l4327A:
	tst.b	(a1)+
	bne.s	.l4327A
	subq.w	#1,(-$A,a6)
.l43282:
	tst.w	(-$A,a6)
	bne.s	.l4327A
	tst.b	(a1)
	bne.s	.l43290
	bra.w	.l431D6
.l43290:
	bra.w	.l42ED0
.l43294:
	moveq	#$0,d0
	move.w	(-$14,a6),d0
	movem.l	(-$A8,a6),d2-d7/a2-a4
	unlk	a6
	rts
sub_432A4:
	link	a6,#$0
	jsr	sub_419C6
	moveq	#$1,d1
	cmp.l	d0,d1
	bge.s	.l432E2
	pea	str_5C3B0
	move.w	dat_2041A,d1
	ext.l	d1
	move.l	d1,-(sp)
	pea	$D.w
	jsr	sub_20B4E
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	dat_20ED0
	jsr	sub_42E4E
	move.w	d0,d1
	bra.s	.l43312
.l432E2:
	pea	str_5C3BE
	move.w	dat_2041A,d1
	ext.l	d1
	move.l	d1,-(sp)
	pea	$D.w
	jsr	sub_20B4E
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	dat_21024
	jsr	sub_42E4E
	move.w	d0,d1
	andi.w	#$EFFF,d1
.l43312:
	ext.l	d1
	move.l	d1,-(sp)
	pea	$D.w
	jsr	sub_20BB4
	unlk	a6
	rts
sub_43324:
	link	a6,#$0
	pea	str_5C3CC
	pea	$1.w
	pea	$C.w
	jsr	sub_20B4E
	addq.l	#4,sp
	move.l	d0,-(sp)
	pea	dat_5BDF8
	jsr	sub_42E4E
	lea	($10,sp),sp
	move.l	d0,-(sp)
	pea	$C.w
	jsr	sub_20BB4
	unlk	a6
	rts
sub_43360:
	link	a6,#$0
	movem.l	d2/a2,-(sp)
	move.l	($8,a6),d0
	move.l	($C,a6),d2
	movea.l	#WATCHDOG,a2
	jsr	sub_43324
	jsr	sub_432A4
	move.l	d2,-(sp)
	jsr	sub_42984
	addq.l	#4,sp
.l4338C:
	jsr	sub_209F2
	tst.l	d0
	beq.s	.l4339A
	clr.w	(a2)
	bra.s	.l4338C
.l4339A:
	movem.l	(-$8,a6),d2/a2
	unlk	a6
	rts
get_game_options:
	link	a6,#$0
	pea	$D.w
	jsr	sub_20B4E
	move.w	d0,d1
	moveq	#$0,d0
	move.w	d1,d0
	unlk	a6
	rts
sub_433BC:
	link	a6,#$FFFC
	movem.l	d2-d6/a2-a4,-(sp)
	movea.l	#copy_to_zram,a2
	clr.l	(-$4,a6)
	moveq	#$0,d0
	movea.l	d0,a4
	move.l	#$FF47BA,d6
	move.l	#$FF4832,d5
	move.l	#$FF486E,d4
	move.l	#$FF48AA,d3
	move.l	#$FF4706,d2
	movea.l	#io_FF477E,a3
.l433F6:
	pea	$4.w
	move.l	d6,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	pea	$2.w
	move.l	d5,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	pea	$2.w
	move.l	d4,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	pea	$2.w
	move.l	d3,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	pea	$4.w
	move.l	d2,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	pea	$2.w
	move.l	a3,-(sp)
	pea	(-$4,a6)
	jsr	(a2)
	lea	($48,sp),sp
	addq.l	#1,a4
	addq.l	#2,a3
	addq.l	#4,d2
	addq.l	#2,d3
	addq.l	#2,d4
	addq.l	#2,d5
	addq.l	#4,d6
	moveq	#$1E,d0
	cmp.l	a4,d0
	bgt.s	.l433F6
	jsr	sub_43466
	movem.l	(-$24,a6),d2-d6/a2-a4
	unlk	a6
	rts
sub_43466:
	link	a6,#$FFF8
	move.w	#$C8,(-$2,a6)
	pea	$2.w
	pea	io_FF48E6
	pea	(-$2,a6)
	jsr	copy_to_zram
	move.l	#$7D0,(-$6,a6)
	pea	$4.w
	pea	io_FF48E8
	pea	(-$6,a6)
	jsr	copy_to_zram
	pea	io_FF48EC
	pea	io_FF4706
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_434B6:
	link	a6,#$FFFC
	move.l	io_FF48E8,(-$4,a6)
	tst.l	(-$4,a6)
	beq.s	.l434F2
	subq.l	#1,(-$4,a6)
	pea	$4.w
	pea	io_FF48E8
	pea	(-$4,a6)
	jsr	copy_to_zram
	pea	io_FF48EC
	pea	io_FF4706
	jsr	sub_2EFB6
.l434F2:
	unlk	a6
	rts
sub_434F6:
	link	a6,#$FFFC
	move.w	#$C8,(-$2,a6)
	pea	$2.w
	pea	io_FF48E6
	pea	(-$2,a6)
	jsr	copy_to_zram
	pea	io_FF48EC
	pea	io_FF4706
	jsr	sub_2EFB6
	unlk	a6
	rts
sub_4352A:
	link	a6,#$FFFC
	move.w	io_FF48E6,(-$2,a6)
	tst.w	(-$2,a6)
	beq.s	.l4357E
	subq.w	#1,(-$2,a6)
	bne.s	.l43558
	tst.l	io_FF48E8
	bne.s	.l43558
	jsr	sub_43466
	jsr	sub_3F832
	bra.s	.l4357E
.l43558:
	pea	$2.w
	pea	io_FF48E6
	pea	(-$2,a6)
	jsr	copy_to_zram
	pea	io_FF48EC
	pea	io_FF4706
	jsr	sub_2EFB6
.l4357E:
	unlk	a6
	rts
sub_43582:
	link	a6,#$0
	movem.l	d2-d6/a2,-(sp)
	movea.l	#ram_FFDF42,a2
	movea.l	#PORT0+$1,a0
	move.l	$FFFF8014,d6
	movea.l	#$FFFF8014,a1
	bra.w	.l4364C
.l435A6:
	moveq	#$0,d1
	btst	#$7,(a0)
	beq.s	.l435B4
	btst	#$6,(a0)
	bne.s	.l435B6
.l435B4:
	moveq	#$1,d1
.l435B6:
	move.w	d2,d0
	ext.l	d0
	cmp.l	d1,d0
	bne.s	.l43602
	moveq	#$0,d1
	btst	#$1,BUTTONS+$1
	bne.s	.l435CC
	moveq	#$1,d1
.l435CC:
	move.w	d3,d0
	ext.l	d0
	cmp.l	d1,d0
	bne.s	.l43602
	moveq	#$0,d1
	btst	#$0,BUTTONS+$1
	bne.s	.l435E2
	moveq	#$1,d1
.l435E2:
	move.w	d4,d0
	ext.l	d0
	cmp.l	d1,d0
	bne.s	.l43602
	moveq	#$0,d1
	btst	#$2,BUTTONS+$1
	bne.s	.l435F8
	moveq	#$1,d1
.l435F8:
	move.w	d5,d0
	ext.l	d0
	cmp.l	d1,d0
	beq.w	.l43646
.l43602:
	moveq	#$0,d0
	btst	#$7,(a0)
	beq.s	.l43610
	btst	#$6,(a0)
	bne.s	.l43612
.l43610:
	moveq	#$1,d0
.l43612:
	move.w	d0,d2
	moveq	#$0,d0
	btst	#$1,BUTTONS+$1
	bne.s	.l43622
	moveq	#$1,d0
.l43622:
	move.w	d0,d3
	moveq	#$0,d0
	btst	#$0,BUTTONS+$1
	bne.s	.l43632
	moveq	#$1,d0
.l43632:
	move.w	d0,d4
	moveq	#$0,d0
	btst	#$2,BUTTONS+$1
	bne.s	.l43642
	moveq	#$1,d0
.l43642:
	move.w	d0,d5
	move.l	(a1),d6
.l43646:
	clr.w	WATCHDOG
.l4364C:
	move.l	(a1),d1
	sub.l	d6,d1
	moveq	#$3,d0
	cmp.l	d1,d0
	bhi.w	.l435A6
	tst.w	d5
	beq.s	.l43684
	move.b	#$1,(a2)
	tst.b	ram_FFDF44
	bne.s	.l43680
	move.b	#$1,ram_FFDF44
	tst.w	d2
	beq.s	.l4367A
	moveq	#$2,d0
	bra.w	.l436D8
.l4367A:
	moveq	#$1,d0
	bra.w	.l436D8
.l43680:
	bra.w	.l436D6
.l43684:
	clr.b	ram_FFDF44
	tst.w	d3
	beq.s	.l43698
	tst.w	d4
	beq.s	.l43698
	move.b	#$1,(a2)
	bra.s	.l436D6
.l43698:
	tst.w	d3
	bne.s	.l436A4
	tst.w	d4
	bne.s	.l436A4
	clr.b	(a2)
	bra.s	.l436D6
.l436A4:
	tst.w	d4
	beq.s	.l436BE
	tst.b	(a2)
	bne.s	.l436BE
	move.b	#$1,(a2)
	tst.w	d2
	beq.s	.l436B8
	moveq	#$20,d0
	bra.s	.l436D8
.l436B8:
	move.w	#$80,d0
	bra.s	.l436D8
.l436BE:
	tst.w	d3
	beq.s	.l436D6
	tst.b	(a2)
	bne.s	.l436D6
	move.b	#$1,(a2)
	tst.w	d2
	beq.s	.l436D2
	moveq	#$10,d0
	bra.s	.l436D8
.l436D2:
	moveq	#$40,d0
	bra.s	.l436D8
.l436D6:
	clr.w	d0
.l436D8:
	ext.l	d0
	movem.l	(-$18,a6),d2-d6/a2
	unlk	a6
	rts
sub_436E4:
	link	a6,#$0
	pea	io_FF4B8E
	pea	io_FF48EE
	jsr	sub_2EFB6
	unlk	a6
	rts
dat_436FE:
	incbin	"../../build/stunrun-68k.bin",$436FE,$1A
audio_test:
	link	a6,#$FFF0
	movem.l	d2-d7/a2-a4,-(sp)
	movea.l	#audio_test_list,a4
	clr.w	d4
	jsr	reset_sound
	jsr	sub_3CD4C
	pea	str_5C3DA
	jsr	reload_gsp
	addq.l	#4,sp
.l43742:
	clr.l	-(sp)
	jsr	sub_43582
	move.w	d0,(-$C,a6)
	btst	#$0,d0
	addq.l	#4,sp
	bne.w	.l43968
	jsr	sub_3CF8E
	cmpi.b	#$5,ram_FFDD82
	bcc.s	.l4376C
	moveq	#$20,d5
	bra.s	.l43782
.l4376C:
	cmpi.b	#$19,ram_FFDD82
	bls.s	.l4377A
	moveq	#$10,d5
	bra.s	.l43782
.l4377A:
	moveq	#$0,d5
	move.l	d5,ram_FFDF46
.l43782:
	cmp.w	ram_FFDF50,d5
	bne.s	.l437A6
	movea.l	#ram_FFDF46,a0
	addq.l	#1,(a0)
	move.l	(a0),d1
	moveq	#$C,d0
	cmp.l	d1,d0
	ble.s	.l4379E
	clr.w	d5
	bra.s	.l437A4
.l4379E:
	clr.l	ram_FFDF46
.l437A4:
	bra.s	.l437AC
.l437A6:
	move.w	d5,ram_FFDF50
.l437AC:
	cmpi.b	#$5,ram_FFDD84
	bcc.s	.l437BA
	moveq	#$40,d6
	bra.s	.l437D2
.l437BA:
	cmpi.b	#$19,ram_FFDD84
	bls.s	.l437CA
	move.w	#$80,d6
	bra.s	.l437D2
.l437CA:
	moveq	#$0,d6
	move.l	d6,ram_FFDF4A
.l437D2:
	cmp.w	ram_FFDF4E,d6
	bne.s	.l437F6
	movea.l	#ram_FFDF4A,a0
	addq.l	#1,(a0)
	move.l	(a0),d1
	moveq	#$C,d0
	cmp.l	d1,d0
	ble.s	.l437EE
	clr.w	d6
	bra.s	.l437F4
.l437EE:
	clr.l	ram_FFDF4A
.l437F4:
	bra.s	.l437FC
.l437F6:
	move.w	d6,ram_FFDF4E
.l437FC:
	moveq	#$3C,d2
	moveq	#$50,d3
	jsr	sub_41CAC
	pea	str_5C3E6
	clr.l	-(sp)
	jsr	sub_41D92
	clr.l	(-$A,a6)
	moveq	#$20,d7
	move.w	d7,(-$4,a6)
	moveq	#$3C,d7
	move.w	d7,(-$2,a6)
	clr.w	(-$6,a6)
	lea	($2,a4),a3
	movea.l	a4,a2
	addq.l	#8,sp
	bra.w	.l438A4
.l43834:
	cmpi.w	#$100,(-$2,a6)
	bcs.s	.l4385C
	move.w	(-$8,a6),(-$E,a6)
	move.w	d2,(-$2,a6)
	move.w	(-$4,a6),d0
	add.w	d3,d0
	move.w	d0,(-$4,a6)
	tst.w	(-$6,a6)
	bne.s	.l4385C
	move.w	(-$8,a6),(-$6,a6)
.l4385C:
	moveq	#$0,d0
	move.w	d4,d0
	move.l	d0,d1
	cmp.l	(-$A,a6),d1
	bne.s	.l43870
	clr.l	-(sp)
	pea	$3.w
	bra.s	.l43876
.l43870:
	clr.l	-(sp)
	pea	$9.w
.l43876:
	moveq	#$0,d0
	move.w	(-$2,a6),d0
	move.l	d0,-(sp)
	moveq	#$0,d0
	move.w	(-$4,a6),d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	jsr	sub_2F2CC
	lea	($14,sp),sp
	addq.l	#1,(-$A,a6)
	moveq	#$16,d1
	adda.l	d1,a2
	moveq	#$16,d1
	adda.l	d1,a3
	addi.w	#$A,(-$2,a6)
.l438A4:
	cmpi.w	#$FFFF,(a2)
	bne.s	.l43834
	move.w	(-$8,a6),d2
	jsr	sub_41CD0
	btst	#$7,d6
	beq.s	.l438C4
	tst.w	d4
	beq.s	.l438C0
	bra.s	.l438C2
.l438C0:
	move.w	d2,d4
.l438C2:
	subq.w	#1,d4
.l438C4:
	btst	#$6,d6
	beq.s	.l438D2
	addq.w	#1,d4
	cmp.w	d2,d4
	bne.s	.l438D2
	clr.w	d4
.l438D2:
	btst	#$5,d5
	beq.s	.l438F0
	cmp.w	(-$6,a6),d4
	bcc.s	.l438EC
	add.w	(-$E,a6),d4
	cmp.w	d2,d4
	bcs.s	.l438EA
	move.w	d2,d4
	subq.w	#1,d4
.l438EA:
	bra.s	.l438F0
.l438EC:
	sub.w	(-$6,a6),d4
.l438F0:
	btst	#$4,d5
	beq.s	.l4390E
	cmp.w	(-$E,a6),d4
	bcs.s	.l43902
	sub.w	(-$E,a6),d4
	bra.s	.l4390E
.l43902:
	add.w	(-$6,a6),d4
	cmp.w	d2,d4
	bcs.s	.l4390E
	move.w	d2,d4
	subq.w	#1,d4
.l4390E:
	moveq	#$0,d0
	move.w	d5,d0
	move.l	d0,d1
	moveq	#$30,d0
	and.l	d0,d1
	bne.s	.l43928
	moveq	#$0,d0
	move.w	d6,d0
	move.l	d0,d1
	andi.l	#$C0,d1
	beq.s	.l43934
.l43928:
	pea	$34.w
	jsr	send_sound_byte
	addq.l	#4,sp
.l43934:
	btst	#$7,(-$B,a6)
	beq.s	.l43946
	clr.l	-(sp)
	jsr	send_sound_byte
	addq.l	#4,sp
.l43946:
	btst	#$6,(-$B,a6)
	beq.s	.l43964
	move.w	d4,d0
	mulu.w	#$16,d0
	move.w	($0,a4,d0.w),d1
	ext.l	d1
	move.l	d1,-(sp)
	jsr	send_sound_byte
	addq.l	#4,sp
.l43964:
	bra.w	.l43742
.l43968:
	pea	$154.w
	jsr	sub_2DD10
	addq.l	#4,sp
	movem.l	(-$34,a6),d2-d7/a2-a4
	unlk	a6
	rts
	assert	*=$04397E,"game/code_03FC22.asm does not end at 04397E"
