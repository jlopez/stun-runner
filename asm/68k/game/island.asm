; game/island.asm, 04397E-046AEE: the island after the rts at 04397C: text, data and unknown
; slices around two code ranges, 0445F0-044630 (reached by the computed call at 0223E0-0223EC,
; executed in MAME; docs/14 section 9) and 046A00-046AEE, the last 68k code (MAME's highest PC is
; 046AEC).
; 04397E-046AEE: 8 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 04397E 046AEE (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$04397E,"game/island.asm misplaced"
str_4397E:
	dc.b	'Just press START',0
str_4398F:
	dc.b	'Hold a Coin Switch and press START',0
str_439B2:
	dc.b	'controls',0
dat_439BB:
	incbin	"../../build/stunrun-68k.bin",$439BB,$1
dat_439BC:
	incbin	"../../build/stunrun-68k.bin",$439BC,$4
dat_439C0:
	incbin	"../../build/stunrun-68k.bin",$439C0,$8
dat_439C8:
	incbin	"../../build/stunrun-68k.bin",$439C8,$824
dat_441EC:
	incbin	"../../build/stunrun-68k.bin",$441EC,$404
sub_445F0:
	lea	GSP_HOST+$2,a1
	lea	GSP_HOST+$C,a2
	move.l	#$F4800070,(a1)
	move.w	#$0,(a2)
	move.l	#$F48000F0,(a1)
	move.w	#$0,(a2)
	move.l	#$26088050,(a1)
	move.l	#$26088190,(a1)
	move.l	#$26088210,(a1)
	move.l	#$26088350,(a1)
	move.l	#$2000000,(a1)
	rts
dat_44630:
	incbin	"../../build/stunrun-68k.bin",$44630,$12
dat_44642:
	incbin	"../../build/stunrun-68k.bin",$44642,$F
dat_44651:
	incbin	"../../build/stunrun-68k.bin",$44651,$2DF
dat_44930:
	incbin	"../../build/stunrun-68k.bin",$44930,$F00
dat_45830:
	incbin	"../../build/stunrun-68k.bin",$45830,$249
str_45A79:
	dc.b	'###+++444===FFFNNNWWW```iiiqqqzzz'
dat_45A9A:
	incbin	"../../build/stunrun-68k.bin",$45A9A,$3C
str_45AD6:
	dc.b	'!$+-198=HCIVOVeZbsen'
dat_45AEA:
	incbin	"../../build/stunrun-68k.bin",$45AEA,$706
dat_461F0:
	incbin	"../../build/stunrun-68k.bin",$461F0,$3AB
str_4659B:
	dc.b	'\QIVVnTddlt'
dat_465A6:
	incbin	"../../build/stunrun-68k.bin",$465A6,$FA
dat_466A0:
	incbin	"../../build/stunrun-68k.bin",$466A0,$360
sub_46A00:
	btst	#$5,BUTTONS
	beq.w	.l46A1E
	lea	dat_46AEE,a0
	move.w	sr,d1
	move.w	#$2700,sr
	bsr.w	sub_46AC4
	move.w	d1,sr
.l46A1E:
	rts
sub_46A20:
	lea	dat_46B15,a0
	move.w	sr,d1
	move.w	#$2700,sr
	bsr.w	sub_46AC4
	move.w	d1,sr
	rts
sub_46A34:
	lea	dat_46B08,a0
	move.w	sr,d1
	move.w	#$2700,sr
	bsr.w	sub_46AC4
	move.w	d1,sr
	rts
dat_46A48:
	incbin	"../../build/stunrun-68k.bin",$46A48,$28
sub_46A70:
	move.w	d1,-(sp)
	move.w	#$20,d1
.l46A76:
	move.w	#$0,BUTTONS
	moveq	#$13,d0
	lsr.l	d0,d0
	moveq	#$13,d0
	lsr.l	d0,d0
	move.w	#$100,BUTTONS
	moveq	#$1B,d0
	lsr.l	d0,d0
	subq.w	#1,d1
	bne.s	.l46A76
	move.w	(sp)+,d1
	rts
sub_46A9A:
	move.w	d1,-(sp)
	move.w	#$20,d1
	move.w	#$100,BUTTONS
.l46AA8:
	moveq	#$1E,d0
	lsr.l	d0,d0
	moveq	#$1E,d0
	lsr.l	d0,d0
	moveq	#$14,d0
	lsr.l	d0,d0
	subq.w	#1,d1
	bne.s	.l46AA8
	move.w	(sp)+,d1
	rts
sub_46ABC:
	bsr.s	sub_46A70
	bra.s	sub_46A9A
sub_46AC0:
	bsr.s	sub_46A9A
	bra.s	sub_46A9A
sub_46AC4:
	movem.l	d1-d2,-(sp)
	bsr.s	sub_46A70
	bsr.s	sub_46A70
	bsr.s	sub_46A70
	bsr.s	sub_46A70
	bsr.s	sub_46A9A
	bsr.s	sub_46A9A
	bsr.s	sub_46A9A
	bsr.s	sub_46A9A
	moveq	#$C,d1
.l46ADA:
	move.b	(a0)+,d2
.l46ADC:
	bsr.s	sub_46ABC
	subq.b	#1,d2
	bne.s	.l46ADC
	bsr.s	sub_46AC0
	dbf	d1,.l46ADA
	movem.l	(sp)+,d1-d2
	rts
	assert	*=$046AEE,"game/island.asm does not end at 046AEE"
