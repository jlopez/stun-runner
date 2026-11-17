; game/island.asm, 04397E-046AEE: the island after the rts at 04397C: text, data and unknown
; slices around two code ranges, 0445F0-044630 (reached by the computed call at 0223E0-0223EC,
; executed in MAME; docs/14 section 9) and 046A00-046AEE, the last 68k code (MAME's highest PC is
; 046AEC).
; 04397E-046AEE: 8 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the game naming legs (N1-N6, docs/03).
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
; 044630-046A00: colour tables. The 32 palettes of data/palettes are generated includes
; (tools/gspimages asm writes ../../build/gsp-images/palettes/<name>.asm, an assert at both
; ends; M5d, docs/17 section 2), each under its label pal_<name>; the bytes between them
; (other colour tables no image pairs with, docs/17) stay incbin slices.
pal_level_base_00:
	include	"../../build/gsp-images/palettes/level_base_00.asm"
pal_level_base_01:
	include	"../../build/gsp-images/palettes/level_base_01.asm"
pal_level_base_02:
	include	"../../build/gsp-images/palettes/level_base_02.asm"
pal_level_base_03:
	include	"../../build/gsp-images/palettes/level_base_03.asm"
pal_level_base_05:
	include	"../../build/gsp-images/palettes/level_base_05.asm"
pal_level_base_04:
	include	"../../build/gsp-images/palettes/level_base_04.asm"
dat_45830:
	incbin	"../../build/stunrun-68k.bin",$45830,$300
pal_overlay_03:
	include	"../../build/gsp-images/palettes/overlay_03.asm"
dat_45B60:
	incbin	"../../build/stunrun-68k.bin",$45B60,$300
pal_overlay_26:
	include	"../../build/gsp-images/palettes/overlay_26.asm"
pal_overlay_65:
	include	"../../build/gsp-images/palettes/overlay_65.asm"
dat_45F20:
	incbin	"../../build/stunrun-68k.bin",$45F20,$2D0
pal_title:
	include	"../../build/gsp-images/palettes/title.asm"
pal_overlay_16:
	include	"../../build/gsp-images/palettes/overlay_16.asm"
pal_overlay_17:
	include	"../../build/gsp-images/palettes/overlay_17.asm"
pal_overlay_20:
	include	"../../build/gsp-images/palettes/overlay_20.asm"
pal_overlay_18:
	include	"../../build/gsp-images/palettes/overlay_18.asm"
pal_overlay_19:
	include	"../../build/gsp-images/palettes/overlay_19.asm"
pal_overlay_21:
	include	"../../build/gsp-images/palettes/overlay_21.asm"
pal_overlay_22:
	include	"../../build/gsp-images/palettes/overlay_22.asm"
pal_overlay_23:
	include	"../../build/gsp-images/palettes/overlay_23.asm"
pal_overlay_29:
	include	"../../build/gsp-images/palettes/overlay_29.asm"
pal_overlay_25:
	include	"../../build/gsp-images/palettes/overlay_25.asm"
pal_overlay_37:
	include	"../../build/gsp-images/palettes/overlay_37.asm"
pal_overlay_04:
	include	"../../build/gsp-images/palettes/overlay_04.asm"
dat_46790:
	incbin	"../../build/stunrun-68k.bin",$46790,$30
pal_overlay_05:
	include	"../../build/gsp-images/palettes/overlay_05.asm"
pal_overlay_08:
	include	"../../build/gsp-images/palettes/overlay_08.asm"
dat_46820:
	incbin	"../../build/stunrun-68k.bin",$46820,$30
pal_overlay_09:
	include	"../../build/gsp-images/palettes/overlay_09.asm"
dat_46880:
	incbin	"../../build/stunrun-68k.bin",$46880,$30
pal_overlay_10:
	include	"../../build/gsp-images/palettes/overlay_10.asm"
pal_overlay_11:
	include	"../../build/gsp-images/palettes/overlay_11.asm"
pal_overlay_12:
	include	"../../build/gsp-images/palettes/overlay_12.asm"
pal_overlay_13:
	include	"../../build/gsp-images/palettes/overlay_13.asm"
pal_overlay_14:
	include	"../../build/gsp-images/palettes/overlay_14.asm"
pal_overlay_15:
	include	"../../build/gsp-images/palettes/overlay_15.asm"
pal_overlay_31:
	include	"../../build/gsp-images/palettes/overlay_31.asm"
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
