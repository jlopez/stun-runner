; boot/code_00DDF2.asm, 00DDF2-0109D4: boot program code (pair R) with the data, text and tables
; that lie between its routines; the first routine is sub_DDF2. Cut at routine starts into files
; of about 16 KB named by their first address (decision C11).
; 00DDF2-0109D4: 40 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the boot naming legs (N1, N3-N5 for the boot program's tests and menus; docs/03).
;
; Generated once by tools/m68k gen 00DDF2 0109D4 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$00DDF2,"boot/code_00DDF2.asm misplaced"
sub_DDF2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$184,d0
	jsr	sub_2326
	clr.l	(ram_FF809C-ABS_SHORT).w
loc_DE0A:
	clr.w	(ram_FF8098-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$A
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lDE34:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lDE60
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	subq.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	cmpi.w	#$FFFF,(ram_FF8098-ABS_SHORT).w
	bne.w	.lDE60
	move.w	#$17,(ram_FF8098-ABS_SHORT).w
.lDE60:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lDE82
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	addq.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	cmpi.w	#$18,d0
	bne.w	.lDE82
	clr.w	(ram_FF8098-ABS_SHORT).w
.lDE82:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lDE9A
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lDE9A:
	clr.l	d2
	move.w	(ram_FF8098-ABS_SHORT).w,d1
	bset	d1,d2
	move.l	(ram_FF809C-ABS_SHORT).w,d3
	eor.l	d3,d2
	move.l	d2,(ram_FF80A0-ABS_SHORT).w
	move.l	d2,ADSP_PRAM
	move.l	ADSP_PRAM,(ram_FF80A4-ABS_SHORT).w
	lea	dat_DEDC,a0
	jsr	sub_D25C
	lea	dat_DEDC,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lDE34
dat_DEDC:
	incbin	"../../build/stunrun-68k.bin",$DEDC,$34
sub_DF10:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$185,d0
	jsr	sub_2326
	clr.l	(ram_FF809C-ABS_SHORT).w
loc_DF28:
	clr.w	(ram_FF8098-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$A
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lDF52:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lDF7E
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	subq.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	cmpi.w	#$FFFF,(ram_FF8098-ABS_SHORT).w
	bne.w	.lDF7E
	move.w	#$17,(ram_FF8098-ABS_SHORT).w
.lDF7E:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lDFA0
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	addq.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	cmpi.w	#$18,d0
	bne.w	.lDFA0
	clr.w	(ram_FF8098-ABS_SHORT).w
.lDFA0:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lDFB8
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lDFB8:
	clr.l	d2
	move.w	(ram_FF8098-ABS_SHORT).w,d1
	bset	d1,d2
	move.l	(ram_FF809C-ABS_SHORT).w,d3
	eor.l	d3,d2
	clr.w	ADSP_CONTROL+$A
	moveq	#-$1,d5
	eor.l	d2,d5
	move.l	d2,(ram_FF80A0-ABS_SHORT).w
	move.l	d5,ADSP_PRAM+$7000
	lea	dat_C0C4,a0
	bsr.w	sub_BE6A
	nop
	nop
	nop
	move.l	ADSP_PRAM,(ram_FF80A4-ABS_SHORT).w
	lea	dat_DEDC,a0
	jsr	sub_D25C
	lea	dat_DEDC,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lDF52
sub_E014:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$186,d0
	jsr	sub_2326
	clr.l	(ram_FF809C-ABS_SHORT).w
	move.l	#$FFFFFFFF,(ram_FF809C-ABS_SHORT).w
	bra.w	loc_DE0A
sub_E038:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$153,d0
	jsr	sub_2326
	move.l	#$FFFFFFFF,(ram_FF809C-ABS_SHORT).w
	bra.w	loc_DF28
sub_E058:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$188,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_E072:
	clr.w	ADSP_CONTROL+$A
	clr.w	(ram_FF80C8-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$A
	move.w	#$14B,d0
	jsr	sub_2326
	move.w	#$14C,d0
	jsr	sub_2326
	move.w	#$14A,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	bsr.w	sub_E160
.lE0B0:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lE0E2
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	subq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	bpl.w	.lE0DE
	move.b	#$C,(ram_FF80C8-ABS_SHORT).w
	ror.w	#3,d0
.lE0DE:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lE0E2:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lE110
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	addq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$D,d1
	bne.w	.lE10C
	clr.b	(ram_FF80C8-ABS_SHORT).w
	rol.w	#3,d0
.lE10C:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lE110:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lE128
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lE128:
	lea	ADSP_PRAM+$2,a0
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	lsl.w	#2,d0
	andi.w	#$7FFF,d0
	move.w	($0,a0,d0.w),(ram_FF809A-ABS_SHORT).w
	lea	dat_C9B6,a0
	jsr	sub_D25C
	lea	dat_C9B6,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lE0B0
sub_E160:
	lea	ADSP_PRAM,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lE16C:
	move.l	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.lE16C
	rts
sub_E176:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$189,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_E072
sub_E194:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	lea	ram_FF9020,a0
	move.l	#$1010101,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	dat_E734,a0
	bsr.w	sub_BE6A
	move.w	#$4B0,(ram_FF8120-ABS_SHORT).w
.lE1BC:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lE1D2
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lE226
.lE1D2:
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	beq.w	.lE218
	btst	#$0,ADSP_STATUS+$1
	beq.w	.lE1EE
	jsr	sub_13EC
	bra.s	.lE1BC
.lE1EE:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_IRQ_CLEAR
	lea	ADSP_PRAM+$1018,a0
	lea	ram_FF9026,a1
	move.w	#$5,d0
.lE20A:
	move.l	(a0)+,d1
	lsr.w	#8,d1
	move.b	d1,(a1)+
	dbf	d0,.lE20A
	bra.w	.lE234
.lE218:
	move.w	#$E7,d0
	jsr	sub_2326
	bra.w	.lE234
.lE226:
	move.w	#$E9,d0
	jsr	sub_2326
	bra.w	.lE2D4
.lE234:
	clr.w	ADSP_CONTROL+$A
	lea	ADSP_PRAM,a0
	move.w	#$FFF,d0
	move.l	#$19000F,d1
.lE24A:
	move.l	d1,(a0)+
	dbf	d1,.lE24A
	lea	dat_EC32,a0
	bsr.w	sub_BEB6
	move.w	#$4B0,(ram_FF8120-ABS_SHORT).w
.lE260:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lE276
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lE2CA
.lE276:
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	beq.w	.lE2BC
	btst	#$0,ADSP_STATUS+$1
	beq.w	.lE292
	jsr	sub_13EC
	bra.s	.lE260
.lE292:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_IRQ_CLEAR
	lea	ADSP_PRAM+$5000,a0
	lea	ram_FF9020,a1
	move.w	#$5,d0
.lE2AE:
	move.l	(a0)+,d1
	lsr.w	#8,d1
	move.b	d1,(a1)+
	dbf	d0,.lE2AE
	move.w	(sp)+,sr
	rts
.lE2BC:
	move.w	#$E8,d0
	jsr	sub_2326
	bra.w	.lE2D4
.lE2CA:
	move.w	#$E9,d0
	jsr	sub_2326
.lE2D4:
	move.w	(sp)+,sr
	rts
sub_E2D8:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	lea	ram_FF9010,a0
	move.l	#$1010101,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	dat_E390,a0
	bsr.w	sub_BE6A
	move.w	#$258,(ram_FF8120-ABS_SHORT).w
.lE2FE:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lE314
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lE368
.lE314:
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	beq.w	.lE35A
	btst	#$0,ADSP_STATUS+$1
	beq.w	.lE330
	jsr	sub_13EC
	bra.s	.lE2FE
.lE330:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_IRQ_CLEAR
	lea	ADSP_PRAM+$1000,a0
	lea	ram_FF9010,a1
	move.w	#$7,d0
.lE34C:
	move.l	(a0)+,d1
	lsr.w	#8,d1
	move.b	d1,(a1)+
	dbf	d0,.lE34C
	move.w	(sp)+,sr
	rts
.lE35A:
	move.w	#$E6,d0
	jsr	sub_2326
	bra.w	.lE372
.lE368:
	move.w	#$E9,d0
	jsr	sub_2326
.lE372:
	move.w	(sp)+,sr
	rts
dat_E376:
	incbin	"../../build/stunrun-68k.bin",$E376,$1A
dat_E390:
	incbin	"../../build/stunrun-68k.bin",$E390,$3A4
dat_E734:
	incbin	"../../build/stunrun-68k.bin",$E734,$4FE
dat_EC32:
	incbin	"../../build/stunrun-68k.bin",$EC32,$4FE
sub_F130:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	movea.l	ram_FF904A,a4
	cmpa.l	#$FF9436,a4
	blt.s	.lF158
	move.l	#$FF904E,ram_FF904A
	movea.l	ram_FF904A,a4
.lF158:
	move.l	a0,(a4)+
	move.w	d1,(a4)+
	move.w	d0,(a4)+
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.s	.lF180
	move.w	#$0,(a4)+
	move.w	#$0,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF180:
	move.l	d6,d4
	andi.l	#$F0,d4
	beq.s	.lF19E
	move.w	#$1,(a4)+
	move.w	#$1,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF19E:
	move.l	d6,d4
	andi.l	#$F00,d4
	beq.s	.lF1BC
	move.w	#$2,(a4)+
	move.w	#$2,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF1BC:
	move.l	d6,d4
	andi.l	#$F000,d4
	beq.s	.lF1DA
	move.w	#$3,(a4)+
	move.w	#$3,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF1DA:
	move.w	#$FFFF,(a4)+
	move.w	#$FFFF,(a4)
	move.l	a4,ram_FF904A
	movem.l	(sp)+,d7
	rts
sub_F1EE:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	movea.l	ram_FF904A,a4
	cmpa.l	#$FF9436,a4
	blt.s	.lF216
	move.l	#$FF904E,ram_FF904A
	movea.l	ram_FF904A,a4
.lF216:
	move.l	a0,(a4)+
	move.w	d1,(a4)+
	move.w	d0,(a4)+
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.s	.lF23E
	move.w	#$4,(a4)+
	move.w	#$4,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF23E:
	move.l	d6,d4
	andi.l	#$F0,d4
	beq.s	.lF25C
	move.w	#$5,(a4)+
	move.w	#$5,d4
	addi.l	#$FF9482,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
.lF25C:
	move.w	#$FFFF,(a4)+
	move.l	a4,ram_FF904A
	movem.l	(sp)+,d7
	rts
sub_F26C:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	clr.w	WATCHDOG
	move.l	#$FF904E,ram_FF904A
	move.w	#$FFFF,ram_FF904E
	moveq	#$3,d0
	lea	ram_FF9482,a5
	clr.w	WATCHDOG
	jsr	sub_12DBC
	clr.w	WATCHDOG
	lea	dat_12DD2,a5
	move.l	(a5),d0
	beq.s	.lF2C8
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_F2DC
	lea	dat_12DDE,a5
	move.l	(a5),d0
	beq.s	.lF2C8
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_F72E
.lF2C8:
	movea.l	ram_FF904A,a4
	move.w	#$FFFF,(a4)
	jsr	sub_4A48
	move.w	(sp)+,sr
	rts
sub_F2DC:
	clr.w	WATCHDOG
	move.l	a2,d4
	sub.l	a1,d4
	lsr.l	#4,d4
	addi.l	#$1,d4
	move.l	d4,ram_FF947E
	clr.l	d0
	clr.l	d1
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.w	WATCHDOG
	movea.l	#$0,a3
	bsr.w	sub_F526
	bsr.w	sub_F52A
	bsr.w	sub_F5A4
	bsr.w	sub_F5A8
	bsr.w	sub_F61A
	bsr.w	sub_F6AA
	moveq	#-$1,d0
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.w	WATCHDOG
	bsr.w	sub_F61E
	bsr.w	sub_F6AE
	jsr	sub_4A48
	rts
sub_F466:
	move.l	d6,d3
	andi.l	#$1000,d3
	beq.s	.lF482
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bra.s	.lF492
.lF482:
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
.lF492:
	move.l	d6,d3
	andi.l	#$2000,d3
	beq.s	.lF4AE
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bra.s	.lF4BE
.lF4AE:
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
.lF4BE:
	move.l	d6,d3
	andi.l	#$FFFF0FFF,d3
	move.l	d3,GSP_HOST+$2
	rts
sub_F4CE:
	move.l	#$100,d2
	andi.l	#$1,d2
	ori.w	#$1800,GSP_HOST+$8
	movea.l	#GSP_HOST+$C,a0
	move.l	a1,GSP_HOST+$2
	bra.s	.lF4F2
.lF4F0:
	move.w	d0,(a0)
.lF4F2:
	dbf	d2,.lF4F0
	move.l	#$100,d2
	lsr.l	#1,d2
	move.l	d2,d1
	clr.w	d1
	swap	d1
	bra.s	.lF508
.lF506:
	move.l	d0,(a0)
.lF508:
	dbf	d2,.lF506
	clr.w	WATCHDOG
	bra.s	.lF520
.lF514:
	move.l	d0,(a0)
	dbf	d2,.lF514
	clr.w	WATCHDOG
.lF520:
	dbf	d1,.lF514
	rts
sub_F526:
	clr.l	d5
	bra.s	loc_F52C
sub_F52A:
	moveq	#-$1,d5
loc_F52C:
	addq.l	#1,a3
	move.w	#$8000,d7
	clr.l	d4
	lea	(-$10,a1),a0
.lF538:
	adda.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
.lF542:
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF556
	bsr.w	sub_F130
.lF556:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.lF542
	clr.w	WATCHDOG
	cmpa.l	a2,a0
	bcs.s	.lF538
	adda.l	#$10,a0
.lF578:
	suba.l	#$10,a0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.lF598
	bsr.w	sub_F130
.lF598:
	cmpa.l	a1,a0
	bhi.s	.lF578
	jsr	sub_4A48
	rts
sub_F5A4:
	clr.l	d5
	bra.s	loc_F5AA
sub_F5A8:
	moveq	#-$1,d5
loc_F5AA:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.lF5B2:
	suba.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
	clr.w	WATCHDOG
.lF5C2:
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF5D6
	bsr.w	sub_F130
.lF5D6:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	lsl.w	#1,d2
	bcc.s	.lF5C2
	cmpa.l	a1,a0
	bhi.s	.lF5B2
	bra.s	.lF5F4
.lF5EE:
	adda.l	#$10,a0
.lF5F4:
	clr.w	WATCHDOG
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF60E
	bsr.w	sub_F130
.lF60E:
	cmpa.l	a2,a0
	bcs.s	.lF5EE
	jsr	sub_4A48
	rts
sub_F61A:
	clr.l	d5
	bra.s	loc_F620
sub_F61E:
	moveq	#-$1,d5
loc_F620:
	addq.l	#1,a3
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$10,a1),a0
.lF630:
	adda.l	#$10,a0
	move.w	d7,d2
.lF638:
	move.w	d5,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF64E
	bsr.w	sub_F130
.lF64E:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d5,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.lF638
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.lF630
	move.w	d5,d0
	adda.l	#$10,a0
.lF67E:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF69E
	bsr.w	sub_F130
.lF69E:
	cmpa.l	a1,a0
	bhi.s	.lF67E
	jsr	sub_4A48
	rts
sub_F6AA:
	clr.l	d5
	bra.s	loc_F6B0
sub_F6AE:
	moveq	#-$1,d5
loc_F6B0:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.lF6B8:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.w	d7,d2
.lF6C6:
	move.w	d5,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF6DC
	bsr.w	sub_F130
.lF6DC:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d5,GSP_HOST+$C
	lsl.w	#1,d2
	bcc.s	.lF6C6
	cmpa.l	a1,a0
	bhi.s	.lF6B8
	move.w	d5,d0
	bra.s	.lF708
.lF702:
	adda.l	#$10,a0
.lF708:
	clr.w	WATCHDOG
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.lF722
	bsr.w	sub_F130
.lF722:
	cmpa.l	a2,a0
	bcs.s	.lF702
	jsr	sub_4A48
	rts
sub_F72E:
	clr.w	WATCHDOG
	move.l	a2,d4
	sub.l	a1,d4
	lsr.l	#4,d4
	addi.l	#$1,d4
	move.l	d4,ram_FF947E
	clr.l	d0
	clr.l	d1
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.l	d0
	clr.l	d1
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.w	WATCHDOG
	movea.l	#$0,a3
	bsr.w	sub_F8B8
	bsr.w	sub_F8BC
	bsr.w	sub_F946
	bsr.w	sub_F94A
	bsr.w	sub_F9D0
	bsr.w	sub_FA70
	moveq	#-$1,d0
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	moveq	#-$1,d0
	move.l	#$F48000A0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F48000B0,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	bsr.w	sub_F4CE
	clr.w	WATCHDOG
	bsr.w	sub_F9D4
	bsr.w	sub_FA74
	jsr	sub_4A48
	rts
sub_F8B8:
	clr.l	d5
	bra.s	loc_F8C2
sub_F8BC:
	move.l	#$FF,d5
loc_F8C2:
	addq.l	#1,a3
	move.w	#$80,d7
	clr.l	d4
	lea	(-$10,a1),a0
.lF8CE:
	adda.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
.lF8D8:
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lF8F2
	bsr.w	sub_F1EE
.lF8F2:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.lF8D8
	clr.w	WATCHDOG
	cmpa.l	a2,a0
	bcs.s	.lF8CE
	adda.l	#$10,a0
.lF914:
	suba.l	#$10,a0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	clr.w	WATCHDOG
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lF93A
	bsr.w	sub_F1EE
.lF93A:
	cmpa.l	a1,a0
	bhi.s	.lF914
	jsr	sub_4A48
	rts
sub_F946:
	clr.l	d5
	bra.s	loc_F950
sub_F94A:
	move.l	#$FF,d5
loc_F950:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.lF958:
	suba.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
	clr.w	WATCHDOG
.lF968:
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lF982
	bsr.w	sub_F1EE
.lF982:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	lsl.w	#1,d2
	cmpi.w	#$100,d2
	bne.s	.lF968
	cmpa.l	a1,a0
	bhi.s	.lF958
	bra.s	.lF9A4
.lF99E:
	adda.l	#$10,a0
.lF9A4:
	clr.w	WATCHDOG
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lF9C4
	bsr.w	sub_F1EE
.lF9C4:
	cmpa.l	a2,a0
	bcs.s	.lF99E
	jsr	sub_4A48
	rts
sub_F9D0:
	clr.l	d5
	bra.s	loc_F9DA
sub_F9D4:
	move.l	#$FF,d5
loc_F9DA:
	addq.l	#1,a3
	clr.w	WATCHDOG
	move.w	#$80,d7
	lea	(-$10,a1),a0
.lF9EA:
	adda.l	#$10,a0
	move.w	d7,d2
.lF9F2:
	move.w	d5,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lFA0E
	bsr.w	sub_F1EE
.lFA0E:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d5,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.lF9F2
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.lF9EA
	move.w	d5,d0
	adda.l	#$10,a0
.lFA3E:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lFA64
	bsr.w	sub_F1EE
.lFA64:
	cmpa.l	a1,a0
	bhi.s	.lFA3E
	jsr	sub_4A48
	rts
sub_FA70:
	clr.l	d5
	bra.s	loc_FA7A
sub_FA74:
	move.l	#$FF,d5
loc_FA7A:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.lFA82:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.w	d7,d2
.lFA90:
	move.w	d5,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lFAAC
	bsr.w	sub_F1EE
.lFAAC:
	eor.w	d2,d0
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	d5,GSP_HOST+$C
	lsl.w	#1,d2
	cmpi.w	#$100,d2
	bne.s	.lFA90
	cmpa.l	a1,a0
	bhi.s	.lFA82
	move.w	d5,d0
	bra.s	.lFADC
.lFAD6:
	adda.l	#$10,a0
.lFADC:
	clr.w	WATCHDOG
	move.l	a0,d6
	bsr.w	sub_F466
	move.w	GSP_HOST+$C,d1
	andi.l	#$FF,d1
	cmp.w	d1,d0
	beq.s	.lFAFC
	bsr.w	sub_F1EE
.lFAFC:
	cmpa.l	a2,a0
	bcs.s	.lFAD6
	jsr	sub_4A48
	rts
dat_FB08:
	incbin	"../../build/stunrun-68k.bin",$FB08,$24
sub_FB2C:
	lea	ram_FF945E,a0
	move.w	#$7,d6
.lFB36:
	clr.l	(a0)+
	dbf	d6,.lFB36
	bsr.w	sub_FC38
	lea	dat_FBBA,a6
	move.w	(a6)+,(ram_FF8120-ABS_SHORT).w
.lFB4A:
	move.w	(a6),d0
	not.w	d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
	move.w	(a6),d1
	move.l	#$FF808000,d0
	bsr.w	sub_FCF6
	bsr.w	sub_FC84
	move.w	(a6)+,d1
	move.l	#$FF800000,d0
	bsr.w	sub_FD0C
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lFB4A
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	ori.w	#$1800,GSP_HOST+$8
	lea	dat_45BA,a0
	jsr	sub_A46
	move.w	#$39,d0
	jsr	sub_2326
	lea	dat_3978,a0
	jsr	sub_452A
	rts
dat_FBBA:
	incbin	"../../build/stunrun-68k.bin",$FBBA,$22
sub_FBDC:
	bsr.w	sub_FC38
	lea	ram_FF945E,a0
	move.w	#$7,d6
.lFBEA:
	clr.l	(a0)+
	dbf	d6,.lFBEA
	bsr.w	sub_FC38
	lea	dat_FBBA,a6
	move.w	(a6)+,(ram_FF8120-ABS_SHORT).w
.lFBFE:
	move.w	(a6),d0
	not.w	d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
	move.w	(a6),d1
	move.l	#$FF808000,d0
	bsr.w	sub_FCF6
	bsr.w	sub_FC84
	move.w	(a6)+,d1
	move.l	#$FF800000,d0
	bsr.w	sub_FD0C
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lFBFE
	jsr	boot_init_gsp
	rts
sub_FC38:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FFFFFFE0,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.w	#$FFFE,GSP_HOST+$C
	lea	dat_FE6C,a0
	move.w	dat_FE6A,d6
	move.l	#$FFFE0000,GSP_HOST+$2
.lFC70:
	move.w	(a0)+,GSP_HOST+$C
	dbf	d6,.lFC70
	andi.w	#$7FFF,GSP_HOST+$8
	rts
sub_FC84:
	jsr	sub_13EC
	move.l	#$C0000080,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	ori.w	#$800,d0
	move.l	#$C0000080,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.l	#$FFFE1000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.w	#$1E,d6
.lFCC4:
	dbf	d6,.lFCC4
	nop
	nop
	nop
	nop
	move.l	#$C0000080,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	andi.w	#$F7FF,d0
	move.l	#$C0000080,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	rts
sub_FCF6:
	move.l	d0,GSP_HOST+$2
	move.w	#$3FF,d2
.lFD00:
	move.w	d1,GSP_HOST+$C
	dbf	d2,.lFD00
	rts
sub_FD0C:
	lea	ram_FF945E,a0
	andi.w	#$E7FF,GSP_HOST+$8
	move.w	#$3FF,d2
.lFD1E:
	move.l	d0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d3
	cmp.w	d1,d3
	beq.w	.lFD34
	bsr.w	sub_FD68
.lFD34:
	addi.l	#$10,d0
	dbf	d2,.lFD1E
	rts
dat_FD40:
	incbin	"../../build/stunrun-68k.bin",$FD40,$28
sub_FD68:
	move.l	d0,d4
	andi.w	#$30,d4
	lsr.w	#2,d4
	move.w	d3,d5
	eor.w	d1,d5
	andi.w	#$F,d5
	beq.w	.lFD82
	move.b	#$FF,($0,a0,d4.w)
.lFD82:
	move.w	d3,d5
	eor.w	d1,d5
	andi.w	#$F0,d5
	beq.w	.lFD94
	move.b	#$FF,($1,a0,d4.w)
.lFD94:
	move.w	d3,d5
	eor.w	d1,d5
	andi.w	#$F00,d5
	beq.w	.lFDA6
	move.b	#$FF,($2,a0,d4.w)
.lFDA6:
	move.w	d3,d5
	eor.w	d1,d5
	andi.w	#$F000,d5
	beq.w	.lFDB8
	move.b	#$FF,($3,a0,d4.w)
.lFDB8:
	rts
dat_FDBA:
	incbin	"../../build/stunrun-68k.bin",$FDBA,$B0
dat_FE6A:
	incbin	"../../build/stunrun-68k.bin",$FE6A,$2
dat_FE6C:
	incbin	"../../build/stunrun-68k.bin",$FE6C,$8E
dat_FEFA:
	incbin	"../../build/stunrun-68k.bin",$FEFA,$23C
dat_10136:
	incbin	"../../build/stunrun-68k.bin",$10136,$634
boot_bus_error:
	move.w	#$E,d0
	jsr	sub_65E0
	jsr	boot_load_gsp_palette
	move.w	#$93,d0
	jsr	sub_2326
	bsr.w	sub_108A6
	addq.l	#1,(ram_FF80E8-ABS_SHORT).w
	rte
boot_address_error:
	move.w	#$E,d0
	jsr	sub_65E0
	jsr	boot_load_gsp_palette
	move.w	#$94,d0
	jsr	sub_2326
	bsr.w	sub_108A6
	bra.w	loc_10856
boot_illegal_instruction:
	move.w	#$95,d0
	jsr	sub_2326
	bsr.w	sub_1090C
	bra.w	loc_10856
boot_zero_divide:
	move.w	#$96,d0
	jsr	sub_2326
	bsr.w	sub_1090C
	bra.w	loc_10856
boot_chk:
	move.w	#$97,d0
	jsr	sub_2326
	bra.w	loc_10856
boot_trapv:
	move.w	#$98,d0
	jsr	sub_2326
	bra.w	loc_10856
boot_privilege_violation:
	move.w	#$99,d0
	jsr	sub_2326
	bra.w	loc_10856
boot_trace:
	move.w	#$9A,d0
	jsr	sub_2326
	bra.w	loc_10856
boot_format_error:
	move.w	#$9B,d0
	jsr	sub_2326
	bsr.w	sub_1090C
	bra.w	loc_10856
boot_uninitialized_interrupt:
	move.w	#$9C,d0
	jsr	sub_2326
	bra.w	loc_10856
boot_spurious_interrupt_etc:
	move.w	#$9D,d0
	jsr	sub_2326
	bra.w	loc_10856
dat_1083A:
	incbin	"../../build/stunrun-68k.bin",$1083A,$E
boot_trap_0_etc:
	move.w	#$9F,d0
	jsr	sub_2326
	bra.w	loc_10856
loc_10856:
	clr.w	WATCHDOG
	bra.s	loc_10856
dat_1085E:
	incbin	"../../build/stunrun-68k.bin",$1085E,$34
dat_10892:
	incbin	"../../build/stunrun-68k.bin",$10892,$14
sub_108A6:
	move.w	($E,sp),(ram_FF8098-ABS_SHORT).w
	move.w	($10,sp),(ram_FF809A-ABS_SHORT).w
	move.w	($6,sp),(ram_FF809E-ABS_SHORT).w
	move.w	($8,sp),(ram_FF80A0-ABS_SHORT).w
	move.w	($1C,sp),(ram_FF80A2-ABS_SHORT).w
	move.w	($C,sp),d0
	andi.w	#$100,d0
	beq.w	.l108DE
	move.w	#$52,d6
	move.w	($18,sp),(ram_FF809C-ABS_SHORT).w
	bra.w	.l108E8
.l108DE:
	move.w	#$57,d6
	move.w	($14,sp),(ram_FF809C-ABS_SHORT).w
.l108E8:
	move.w	#$E,d0
	move.w	#$1E,d1
	jsr	sub_2418
	move.b	d6,d1
	jsr	sub_22EC
	lea	dat_1085E,a0
	jsr	sub_993A
	rts
sub_1090C:
	move.w	($6,sp),(ram_FF809E-ABS_SHORT).w
	move.w	($8,sp),(ram_FF80A0-ABS_SHORT).w
	lea	dat_10892,a0
	jsr	sub_9856
	lea	dat_10892,a0
	jsr	sub_993A
	rts
sub_10932:
	jsr	boot_init_gsp
	move.w	#$B800,GSP_HOST+$8
	pea	dat_10F32
	jsr	sub_10960
	move.w	#$7800,GSP_HOST+$8
	move.w	#$3800,GSP_HOST+$8
	addq.l	#4,sp
	rts
sub_10960:
	move.l	d2,-(sp)
	movea.l	($8,sp),a0
	move.l	(a0)+,d2
	bra.s	.l10976
.l1096A:
	move.l	a0,-(sp)
	jsr	sub_10982
	movea.l	d0,a0
	addq.l	#4,sp
.l10976:
	move.l	d2,d0
	subq.l	#1,d2
	tst.l	d0
	bne.s	.l1096A
	move.l	(sp)+,d2
	rts
sub_10982:
	movem.l	d2/a2,-(sp)
	movea.l	($C,sp),a2
	move.l	(a2)+,d0
	move.l	(a2)+,d2
	clr.w	WATCHDOG
	move.l	d0,GSP_HOST+$2
	bra.s	.l109AA
.l1099C:
	move.l	(a2)+,-(sp)
	jsr	sub_109D4
	addq.l	#4,sp
	moveq	#$20,d0
	sub.l	d0,d2
.l109AA:
	moveq	#$20,d0
	cmp.l	d2,d0
	ble.s	.l1099C
	tst.l	d2
	beq.s	.l109CC
	moveq	#$10,d0
	cmp.l	d2,d0
	beq.s	.l109C0
	jsr	boot_line_a_etc
.l109C0:
	movea.l	a2,a0
	addq.l	#4,a2
	move.w	($2,a0),GSP_HOST+$C
.l109CC:
	move.l	a2,d0
	movem.l	(sp)+,d2/a2
	rts
	assert	*=$0109D4,"boot/code_00DDF2.asm does not end at 0109D4"
