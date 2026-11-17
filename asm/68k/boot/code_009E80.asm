; boot/code_009E80.asm, 009E80-00DDF2: boot program code (pair R) with the data, text and tables
; that lie between its routines; the first routine is sub_9E80 (009E80). Cut at routine starts
; into files of about 16 KB named by their first address (decision C11).
; 009E80-00DDF2: 1 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the boot naming legs (N1, N3-N5 for the boot program's tests and menus; docs/03).
;
; Generated once by tools/m68k gen 009E80 00DDF2 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$009E80,"boot/code_009E80.asm misplaced"
sub_9E80:
	clr.w	WATCHDOG
	move.b	$FFFF4FF7,d0
	lsl.w	#8,d0
	move.b	$FFFF4FF1,d0
	move.w	d0,(ram_FF8092-ABS_SHORT).w
	move.b	$FFFF4FF3,d0
	lsl.w	#8,d0
	move.b	$FFFF4FF5,d0
	move.w	d0,(ram_FF8094-ABS_SHORT).w
	move.b	$FFFF4FEB,d0
	lsl.w	#8,d0
	move.b	$FFFF4FED,d0
	move.w	d0,(ram_FF80C8-ABS_SHORT).w
	move.b	$FFFF4FE1,d0
	lsl.w	#8,d0
	move.b	$FFFF4FE3,d0
	move.w	d0,(ram_FF80CA-ABS_SHORT).w
	clr.w	WATCHDOG
	lea	dat_9EEA,a0
	bsr.w	sub_9856
	lea	dat_9EEA,a0
	bsr.w	sub_993A
	rts
dat_9EEA:
	incbin	"../../build/stunrun-68k.bin",$9EEA,$24
loc_9F0E:
	move.w	#$114,d0
	jsr	sub_2326
	move.w	#$115,d0
	jsr	sub_2326
	move.w	#$116,d0
	jsr	sub_2326
	move.w	#$11B,d0
	jsr	sub_2326
	move.l	#$C00000B0,GSP_HOST+$2
	move.w	#$18,GSP_HOST+$C
.l9F48:
	clr.w	WATCHDOG
	move.l	#$F5001550,GSP_HOST+$2
	move.w	#$5555,GSP_HOST+$C
	move.l	#$F5001550,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmpi.w	#$5555,d0
	beq.w	.l9F80
	clr.w	SOUND_RESET+$10
	bra.s	.l9F48
.l9F80:
	clr.w	SOUND_RESET
	bra.s	.l9F48
loc_9F88:
	move.w	#$114,d0
	jsr	sub_2326
	move.w	#$115,d0
	jsr	sub_2326
	move.w	#$117,d0
	jsr	sub_2326
	move.w	#$11B,d0
	jsr	sub_2326
	move.l	#$C00000B0,GSP_HOST+$2
	move.w	#$18,GSP_HOST+$C
.l9FC2:
	clr.w	WATCHDOG
	move.l	#$F5002AA0,GSP_HOST+$2
	move.w	#$AAAA,GSP_HOST+$C
	move.l	#$F5002AA0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmpi.w	#$AAAA,d0
	beq.w	.l9FFA
	clr.w	SOUND_RESET+$10
	bra.s	.l9FC2
.l9FFA:
	clr.w	SOUND_RESET
	bra.s	.l9FC2
loc_A002:
	move.w	#$114,d0
	jsr	sub_2326
	move.w	#$118,d0
	jsr	sub_2326
	move.w	#$119,d0
	jsr	sub_2326
	move.w	#$11B,d0
	jsr	sub_2326
	move.l	#$C00000B0,GSP_HOST+$2
	move.w	#$18,GSP_HOST+$C
.lA03C:
	clr.w	WATCHDOG
	move.l	#$F5801550,GSP_HOST+$2
	move.w	#$5555,GSP_HOST+$C
	move.l	#$F5801550,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmpi.b	#$55,d0
	beq.w	.lA074
	clr.w	SOUND_RESET+$10
	bra.s	.lA03C
.lA074:
	clr.w	SOUND_RESET
	bra.s	.lA03C
loc_A07C:
	move.w	#$114,d0
	jsr	sub_2326
	move.w	#$118,d0
	jsr	sub_2326
	move.w	#$11A,d0
	jsr	sub_2326
	move.w	#$11B,d0
	jsr	sub_2326
	move.l	#$C00000B0,GSP_HOST+$2
	move.w	#$18,GSP_HOST+$C
.lA0B6:
	clr.w	WATCHDOG
	move.l	#$F5802AAA,GSP_HOST+$2
	move.w	#$AAAA,GSP_HOST+$C
	move.l	#$F5802AAA,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmpi.b	#$AA,d0
	beq.w	.lA0EE
	clr.w	SOUND_RESET+$10
	bra.s	.lA0B6
.lA0EE:
	clr.w	SOUND_RESET
	bra.s	.lA0B6
loc_A0F6:
	move.w	#$11C,d0
	jsr	sub_2326
	move.w	#$11D,d0
	jsr	sub_2326
	move.w	#$11E,d0
	jsr	sub_2326
	clr.w	(ram_FF80E2-ABS_SHORT).w
	move.l	#$1,(ram_FF80D8-ABS_SHORT).w
	clr.w	(ram_FF80E0-ABS_SHORT).w
.lA124:
	jsr	sub_F26C
	tst.l	ram_FF9482
	bne.w	.lA142
	tst.w	ram_FF9486
	bne.w	.lA142
	bra.w	.lA14A
.lA142:
	lea	(ram_FF80E4-ABS_SHORT).w,a3
	bsr.w	sub_9A5E
.lA14A:
	lea	dat_9AFE,a0
	bsr.w	sub_9856
	lea	dat_9AFE,a0
	bsr.w	sub_993A
	bsr.w	sub_9A70
	addq.w	#1,(ram_FF80E0-ABS_SHORT).w
	jsr	boot_load_gsp_palette
	move.w	#$12B,d0
.lA170:
	jsr	sub_13EC
	dbf	d0,.lA170
	bra.s	.lA124
dat_A17C:
	incbin	"../../build/stunrun-68k.bin",$A17C,$CF4
dat_AE70:
	incbin	"../../build/stunrun-68k.bin",$AE70,$378
sub_B1E8:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$C
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_IRQ_CLEAR
	bsr.w	sub_B228
	move.w	#$0,ADSP_DRAM+$2
	move.w	#$0,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1C
	clr.w	ADSP_CONTROL+$1E
	rts
sub_B228:
	lea	dat_AE70,a0
	move.w	(a0)+,d6
	lea	ADSP_PRAM,a1
.lB236:
	clr.l	d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.l	d0,(a1)+
	subq.w	#1,d6
	bne.s	.lB236
	rts
dat_B24A:
	incbin	"../../build/stunrun-68k.bin",$B24A,$1C
sub_B266:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$D9,d0
	jsr	sub_2326
	move.w	#$DC,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$0,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$6
	move.w	#$1234,d3
	move.w	d3,ADSP_DRAM+$6
	clr.w	ADSP_CONTROL+$1A
	nop
	nop
	nop
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM+$A,d0
	cmp.w	d0,d3
	bne.w	.lB2D4
	move.w	#$E2,d0
	bra.w	.lB2D8
.lB2D4:
	move.w	#$E3,d0
.lB2D8:
	jsr	sub_2326
	jmp	loc_1418
sub_B2E4:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$D9,d0
	jsr	sub_2326
	move.w	#$DD,d0
	jsr	sub_2326
	clr.w	ADSP_IRQ_CLEAR
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$6,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$C
	clr.w	ADSP_CONTROL+$1A
	move.l	#$1770,d3
.lB33A:
	subq.l	#1,d3
	beq.w	.lB358
	clr.w	WATCHDOG
	btst	#$0,ADSP_STATUS+$1
	bne.s	.lB33A
	move.w	#$E4,d0
	bra.w	.lB35C
.lB358:
	move.w	#$E5,d0
.lB35C:
	jsr	sub_2326
	move.w	(sp)+,sr
	jmp	loc_1418
sub_B36A:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$EA,d1
	move.w	#$8,d2
	jsr	sub_145E
	clr.w	ADSP_IRQ_CLEAR
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$A,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$C
	clr.w	ADSP_DRAM+$E
	clr.w	ADSP_DRAM+$10
	clr.w	ADSP_DRAM+$12
	clr.w	ADSP_DRAM+$14
	clr.w	ADSP_DRAM+$16
	clr.w	ADSP_CONTROL+$1A
	move.l	#$7530,d3
.lB3D8:
	clr.w	WATCHDOG
	subq.l	#1,d3
	beq.w	.lB434
	btst	#$0,ADSP_STATUS+$1
	bne.s	.lB3D8
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM+$C,(ram_FF8098-ABS_SHORT).w
	move.w	ADSP_DRAM+$E,(ram_FF809A-ABS_SHORT).w
	move.w	ADSP_DRAM+$10,(ram_FF809C-ABS_SHORT).w
	move.w	ADSP_DRAM+$12,(ram_FF809E-ABS_SHORT).w
	move.w	ADSP_DRAM+$14,(ram_FF80A0-ABS_SHORT).w
	move.w	ADSP_DRAM+$16,(ram_FF80A2-ABS_SHORT).w
	lea	dat_B446,a0
	jsr	sub_993A
	bra.w	.lB43E
.lB434:
	move.w	#$E3,d0
	jsr	sub_2326
.lB43E:
	move.w	(sp)+,sr
	jmp	loc_1418
dat_B446:
	incbin	"../../build/stunrun-68k.bin",$B446,$34
tbl_B47A:
	dc.l	sub_B57E
	dc.l	sub_B59A
	dc.l	sub_B5DE
	dc.l	sub_B622
	dc.l	sub_B66C
	dc.l	sub_B6B6
	dc.l	sub_B700
	dc.l	sub_B74A
	dc.l	sub_B78E
	dc.l	sub_B7D2
	dc.l	sub_BD84
	dc.l	sub_BDB2
	dc.l	sub_BDE0
	dc.l	sub_BE0E
	dc.l	sub_BE3C
sub_B4B6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8024-ABS_SHORT).w
	bra.w	.lB538
.lB4D4:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lB4FE
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$F,d0
	bne.w	.lB4F6
	clr.w	d0
.lB4F6:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.lB538
.lB4FE:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lB520
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.lB518
	move.w	#$E,d0
.lB518:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.lB538
.lB520:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lB530
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lB552
.lB530:
	jsr	sub_13EC
	bra.s	.lB4D4
.lB538:
	move.w	#$F3,d1
	move.w	#$F,d2
	jsr	sub_145E
	bsr.w	sub_B56A
	jsr	sub_13EC
	bra.s	.lB4D4
.lB552:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_B47A,a0
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.lB538
sub_B56A:
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addi.w	#$F4,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_B57E:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
sub_B59A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$F5,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$B,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B5DE:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$F6,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$C,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B622:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$F7,d0
	jsr	sub_2326
	clr.w	ADSP_CONTROL+$16
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$F,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B66C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$F8,d0
	jsr	sub_2326
	clr.w	ADSP_CONTROL+$16
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$10,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B6B6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$F9,d0
	jsr	sub_2326
	clr.w	ADSP_CONTROL+$6
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$F,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B700:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FA,d0
	jsr	sub_2326
	clr.w	ADSP_CONTROL+$6
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$10,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B74A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FB,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$D,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B78E:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FC,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$E,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_CONTROL+$1A
	jmp	loc_1418
sub_B7D2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	movea.l	dat_135E,a0
.lB7E2:
	clr.w	WATCHDOG
	move.w	dat_1362,d1
	and.w	(a0),d1
	beq.s	.lB7E2
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FD,d0
	jsr	sub_2326
	move.w	sr,-(sp)
	move.w	#$2F00,sr
.lB80C:
	clr.w	WATCHDOG
	clr.w	ADSP_CONTROL+$16
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	beq.w	.lB840
	clr.w	ADSP_CONTROL+$6
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.s	.lB80C
.lB840:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	movea.l	dat_135E,a0
.lB850:
	clr.w	WATCHDOG
	move.w	dat_1362,d1
	and.w	(a0),d1
	beq.s	.lB850
	move.w	(sp)+,sr
	rts
sub_B864:
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$0,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$6
	move.w	#$1234,d3
	move.w	d3,ADSP_DRAM+$6
	clr.w	ADSP_CONTROL+$1A
	nop
	nop
	nop
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM+$A,d0
	clr.w	d7
	cmp.w	d0,d3
	bne.w	.lB8B2
	move.w	#$5555,d7
.lB8B2:
	rts
sub_B8B4:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	clr.w	ADSP_IRQ_CLEAR
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$6,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$C
	clr.w	ADSP_CONTROL+$1A
	move.l	#$1770,d3
.lB8EC:
	subq.l	#1,d3
	beq.w	.lB90A
	clr.w	WATCHDOG
	btst	#$0,ADSP_STATUS+$1
	bne.s	.lB8EC
	move.w	#$5555,d7
	bra.w	.lB90C
.lB90A:
	clr.w	d7
.lB90C:
	clr.w	ADSP_IRQ_CLEAR
	move.w	(sp)+,sr
	rts
sub_B916:
	clr.w	ADSP_IRQ_CLEAR
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$A,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.w	ADSP_DRAM+$C
	clr.w	ADSP_DRAM+$E
	clr.w	ADSP_DRAM+$10
	clr.w	ADSP_DRAM+$12
	clr.w	ADSP_DRAM+$14
	clr.w	ADSP_DRAM+$16
	clr.w	ADSP_CONTROL+$1A
	move.l	#$7530,d3
.lB966:
	subq.l	#1,d3
	beq.w	.lB9AC
	clr.w	WATCHDOG
	btst	#$0,ADSP_STATUS+$1
	bne.s	.lB966
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM+$C,d0
	move.w	ADSP_DRAM+$E,d1
	move.w	ADSP_DRAM+$10,d2
	move.w	ADSP_DRAM+$12,d3
	move.w	ADSP_DRAM+$14,d4
	move.w	ADSP_DRAM+$16,d5
	move.w	#$5555,d7
	rts
.lB9AC:
	clr.w	d7
	rts
dat_B9B0:
	incbin	"../../build/stunrun-68k.bin",$B9B0,$3D4
sub_BD84:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FE,d0
	jsr	sub_2326
	lea	dat_BF02,a0
	bsr.w	sub_BE6A
	jmp	loc_1418
sub_BDB2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$FF,d0
	jsr	sub_2326
	lea	dat_BF22,a0
	bsr.w	sub_BE6A
	jmp	loc_1418
sub_BDE0:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$100,d0
	jsr	sub_2326
	lea	dat_BF40,a0
	bsr.w	sub_BE6A
	jmp	loc_1418
sub_BE0E:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$101,d0
	jsr	sub_2326
	lea	dat_BF64,a0
	bsr.w	sub_BE6A
	jmp	loc_1418
sub_BE3C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$F3,d0
	jsr	sub_2326
	move.w	#$102,d0
	jsr	sub_2326
	lea	dat_BF8E,a0
	bsr.w	sub_BE6A
	jmp	loc_1418
sub_BE6A:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$C
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_IRQ_CLEAR
	move.w	(a0)+,d6
	lea	ADSP_PRAM,a1
.lBE8A:
	clr.l	d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.l	d0,(a1)+
	subq.w	#1,d6
	bne.s	.lBE8A
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1C
	clr.w	ADSP_CONTROL+$1E
	nop
	nop
	nop
	rts
sub_BEB6:
	clr.w	ADSP_CONTROL+$A
	clr.w	ADSP_CONTROL+$C
	clr.w	ADSP_CONTROL+$E
	clr.w	ADSP_IRQ_CLEAR
	move.w	(a0)+,d6
	lea	ADSP_PRAM+$4000,a1
.lBED6:
	clr.l	d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	move.l	d0,(a1)+
	subq.w	#1,d6
	bne.s	.lBED6
	clr.w	ADSP_CONTROL+$1A
	clr.w	ADSP_CONTROL+$1C
	clr.w	ADSP_CONTROL+$1E
	nop
	nop
	nop
	rts
dat_BF02:
	incbin	"../../build/stunrun-68k.bin",$BF02,$20
dat_BF22:
	incbin	"../../build/stunrun-68k.bin",$BF22,$1E
dat_BF40:
	incbin	"../../build/stunrun-68k.bin",$BF40,$24
dat_BF64:
	incbin	"../../build/stunrun-68k.bin",$BF64,$2A
dat_BF8E:
	incbin	"../../build/stunrun-68k.bin",$BF8E,$2C
dat_BFBA:
	incbin	"../../build/stunrun-68k.bin",$BFBA,$1E
dat_BFD8:
	incbin	"../../build/stunrun-68k.bin",$BFD8,$30
dat_C008:
	incbin	"../../build/stunrun-68k.bin",$C008,$BC
dat_C0C4:
	incbin	"../../build/stunrun-68k.bin",$C0C4,$38
tbl_C0FC:
	dc.l	sub_C1E0
	dc.l	sub_C1FC
	dc.l	sub_C2FC
	dc.l	sub_C318
	dc.l	sub_C334
	dc.l	sub_C33A
	dc.l	sub_B4B6
sub_C118:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8022-ABS_SHORT).w
	bra.w	.lC19A
.lC136:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC160
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$7,d0
	bne.w	.lC158
	clr.w	d0
.lC158:
	move.w	d0,(ram_FF8022-ABS_SHORT).w
	bra.w	.lC19A
.lC160:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC182
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.lC17A
	move.w	#$6,d0
.lC17A:
	move.w	d0,(ram_FF8022-ABS_SHORT).w
	bra.w	.lC19A
.lC182:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC192
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lC1B4
.lC192:
	jsr	sub_13EC
	bra.s	.lC136
.lC19A:
	move.w	#$11F,d1
	move.w	#$7,d2
	jsr	sub_145E
	bsr.w	sub_C1CC
	jsr	sub_13EC
	bra.s	.lC136
.lC1B4:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_C0FC,a0
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.lC19A
sub_C1CC:
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	addi.w	#$120,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_C1E0:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
sub_C1FC:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$127,d1
	move.w	#$6,d2
	jsr	sub_145E
	clr.w	ADSP_CONTROL+$6
	move.w	#$0,ADSP_BUFFER
	clr.w	ADSP_CONTROL+$16
	move.w	#$FFFF,ADSP_BUFFER
	clr.w	ADSP_CONTROL+$6
	move.w	ADSP_BUFFER,(ram_FF8098-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$16
	move.w	ADSP_BUFFER,(ram_FF809A-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$6
	move.w	#$FFFF,ADSP_BUFFER
	clr.w	ADSP_CONTROL+$16
	move.w	#$0,ADSP_BUFFER
	clr.w	ADSP_CONTROL+$6
	move.w	ADSP_BUFFER,(ram_FF809C-ABS_SHORT).w
	clr.w	ADSP_CONTROL+$16
	move.w	ADSP_BUFFER,(ram_FF809E-ABS_SHORT).w
	lea	dat_C2D0,a0
	jsr	sub_9980
	cmpi.w	#$0,(ram_FF8098-ABS_SHORT).w
	bne.w	.lC2C0
	cmpi.w	#$FFFF,(ram_FF809A-ABS_SHORT).w
	bne.w	.lC2C0
	cmpi.w	#$FFFF,(ram_FF809C-ABS_SHORT).w
	bne.w	.lC2C0
	cmpi.w	#$0,(ram_FF809E-ABS_SHORT).w
	bne.w	.lC2C0
	move.w	#$12E,d0
	bra.w	.lC2C4
.lC2C0:
	move.w	#$12F,d0
.lC2C4:
	jsr	sub_2326
	jmp	loc_1418
dat_C2D0:
	incbin	"../../build/stunrun-68k.bin",$C2D0,$2C
sub_C2FC:
	move.l	#$818006,(ram_FF8140-ABS_SHORT).w
	move.l	#$818016,(ram_FF8144-ABS_SHORT).w
	move.w	#$0,(ram_FF813A-ABS_SHORT).w
	jmp	loc_C384
sub_C318:
	move.l	#$818016,(ram_FF8140-ABS_SHORT).w
	move.l	#$818006,(ram_FF8144-ABS_SHORT).w
	move.w	#$1,(ram_FF813A-ABS_SHORT).w
	jmp	loc_C384
sub_C334:
	jmp	loc_D306
sub_C33A:
	jmp	loc_DD02
tbl_C340:
	dc.l	sub_C45C
	dc.l	sub_C478
	dc.l	sub_C54E
	dc.l	sub_C64C
	dc.l	sub_C66A
	dc.l	sub_C688
	dc.l	sub_C7F6
	dc.l	sub_C8B4
	dc.l	sub_C9E8
	dc.l	sub_CBA4
	dc.l	sub_CBC2
	dc.l	sub_CBE0
	dc.l	sub_CD5E
	dc.l	sub_CE04
	dc.l	sub_CEAA
	dc.l	sub_CF96
	dc.l	sub_D078
loc_C384:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF813C-ABS_SHORT).w
	bra.w	.lC406
.lC3A2:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC3CC
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF813C-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$11,d0
	bne.w	.lC3C4
	clr.w	d0
.lC3C4:
	move.w	d0,(ram_FF813C-ABS_SHORT).w
	bra.w	.lC406
.lC3CC:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC3EE
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF813C-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.lC3E6
	move.w	#$10,d0
.lC3E6:
	move.w	d0,(ram_FF813C-ABS_SHORT).w
	bra.w	.lC406
.lC3EE:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC3FE
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lC430
.lC3FE:
	jsr	sub_13EC
	bra.s	.lC3A2
.lC406:
	move.w	#$130,d1
	move.w	#$10,d2
	jsr	sub_145E
	move.w	#$141,d0
	add.w	(ram_FF813A-ABS_SHORT).w,d0
	jsr	sub_2326
	bsr.w	sub_C448
	jsr	sub_13EC
	bra.w	.lC3A2
.lC430:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_C340,a0
	move.w	(ram_FF813C-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.lC406
sub_C448:
	move.w	(ram_FF813C-ABS_SHORT).w,d0
	addi.w	#$130,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_C45C:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
sub_C478:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$150,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_C492:
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lC4B8:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC4D4
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC4D4:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC4EA
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC4EA:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC502
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lC502:
	move.w	(ram_FF8098-ABS_SHORT).w,ADSP_BUFFER
	move.w	ADSP_BUFFER,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.s	.lC4B8
dat_C532:
	incbin	"../../build/stunrun-68k.bin",$C532,$1C
sub_C54E:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$151,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_C568:
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lC592:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC5AE
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC5AE:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC5C4
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC5C4:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC5DC
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lC5DC:
	bsr.w	sub_C608
	move.w	ADSP_BUFFER,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.s	.lC592
sub_C608:
	movea.l	(ram_FF8144-ABS_SHORT).w,a0
	clr.w	(a0)
	clr.w	ADSP_CONTROL+$A
	move.w	#$11,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.l	d2
	move.w	(ram_FF8098-ABS_SHORT).w,d2
	move.l	d2,ADSP_PRAM+$7000
	clr.w	ADSP_CONTROL+$1A
	move.w	#$14,d3
.lC63A:
	dbf	d3,.lC63A
	clr.w	ADSP_CONTROL+$A
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	rts
sub_C64C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$152,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_C492
sub_C66A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$153,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_C568
sub_C688:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$154,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8148-ABS_SHORT).w
	clr.l	(ram_FF80D8-ABS_SHORT).w
	clr.w	(ram_FF8120-ABS_SHORT).w
.lC6BE:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC6DC
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lC6DC:
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	move.w	#$FF,d1
.lC6E4:
	move.w	d0,ADSP_BUFFER
	move.w	ADSP_BUFFER,d2
	cmp.w	d0,d2
	beq.w	.lC6FA
	bsr.w	sub_C73A
.lC6FA:
	addq.w	#1,d0
	dbf	d1,.lC6E4
	move.w	d0,(ram_FF8148-ABS_SHORT).w
	jsr	sub_13EC
	addq.b	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lC6BE
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_C7E8,a0
	jsr	sub_988C
	lea	dat_C7E8,a0
	jsr	sub_9980
	bra.s	.lC6BE
sub_C73A:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	move.w	d2,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	move.w	#$146,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lC784:
	jsr	sub_1368
	jsr	sub_13EC
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC7A0
	clr.w	(ram_FF8036-ABS_SHORT).w
	bra.w	.lC7AC
.lC7A0:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC7D0
	clr.w	(ram_FF8046-ABS_SHORT).w
.lC7AC:
	move.w	#$6,d0
	jsr	sub_65E0
	move.w	#$8,d0
	jsr	sub_65E0
	move.w	#$147,d0
	jsr	sub_2326
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	rts
.lC7D0:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	.lC784
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	addq.l	#4,sp
	rts
dat_C7E8:
	incbin	"../../build/stunrun-68k.bin",$C7E8,$E
sub_C7F6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$155,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8148-ABS_SHORT).w
	clr.l	(ram_FF80D8-ABS_SHORT).w
	clr.w	(ram_FF8120-ABS_SHORT).w
.lC830:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC84E
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lC84E:
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	move.w	#$FF,d1
.lC856:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	bsr.w	sub_C608
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	move.w	ADSP_BUFFER,d2
	cmp.w	d0,d2
	beq.w	.lC872
	bsr.w	sub_C73A
.lC872:
	addq.w	#1,d0
	dbf	d1,.lC856
	move.w	d0,(ram_FF8148-ABS_SHORT).w
	jsr	sub_13EC
	addq.b	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lC830
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_C7E8,a0
	jsr	sub_988C
	lea	dat_C7E8,a0
	jsr	sub_9980
	bra.w	.lC830
sub_C8B4:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$156,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_C8CE:
	clr.w	(ram_FF80C8-ABS_SHORT).w
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	move.w	#$14B,d0
	jsr	sub_2326
	move.w	#$14C,d0
	jsr	sub_2326
	move.w	#$14A,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	bsr.w	sub_C9D2
.lC906:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lC938
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	subq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	bpl.w	.lC934
	move.b	#$C,(ram_FF80C8-ABS_SHORT).w
	ror.w	#3,d0
.lC934:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC938:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lC966
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	addq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$D,d1
	bne.w	.lC962
	clr.b	(ram_FF80C8-ABS_SHORT).w
	rol.w	#3,d0
.lC962:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lC966:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lC97E
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lC97E:
	lea	ADSP_BUFFER,a0
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	lsl.w	#1,d0
	andi.w	#$3FFF,d0
	move.w	($0,a0,d0.w),(ram_FF809A-ABS_SHORT).w
	lea	dat_C9B6,a0
	jsr	sub_D25C
	lea	dat_C9B6,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lC906
dat_C9B6:
	incbin	"../../build/stunrun-68k.bin",$C9B6,$1C
sub_C9D2:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lC9DE:
	move.w	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.lC9DE
	rts
sub_C9E8:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$157,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_CA02:
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	clr.w	(ram_FF80C8-ABS_SHORT).w
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	move.w	#$14B,d0
	jsr	sub_2326
	move.w	#$14C,d0
	jsr	sub_2326
	move.w	#$14A,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$12,d7
	bsr.w	sub_CAF8
.lCA48:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lCA7A
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	subq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	bpl.w	.lCA76
	move.b	#$C,(ram_FF80C8-ABS_SHORT).w
	ror.w	#3,d0
.lCA76:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lCA7A:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lCAA8
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	addq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$D,d1
	bne.w	.lCAA4
	clr.b	(ram_FF80C8-ABS_SHORT).w
	rol.w	#3,d0
.lCAA4:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lCAA8:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lCAC0
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lCAC0:
	lea	ADSP_BUFFER,a0
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	lsl.w	#1,d0
	andi.w	#$3FFF,d0
	move.w	($0,a0,d0.w),(ram_FF809A-ABS_SHORT).w
	lea	dat_C9B6,a0
	jsr	sub_D25C
	lea	dat_C9B6,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lCA48
sub_CAF8:
	movea.l	(ram_FF8144-ABS_SHORT).w,a0
	clr.w	(a0)
	clr.w	ADSP_CONTROL+$A
	move.w	d7,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.l	d2
	clr.w	ADSP_CONTROL+$1A
	jsr	sub_13EC
	jsr	sub_13EC
	clr.w	ADSP_CONTROL+$A
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	rts
sub_CB34:
	movea.l	(ram_FF8144-ABS_SHORT).w,a0
	clr.w	(a0)
	clr.w	ADSP_CONTROL+$A
	move.w	d7,ADSP_DRAM+$2
	move.w	#$2,ADSP_DRAM
	clr.l	d2
	clr.w	ADSP_CONTROL+$1A
	move.w	#$3C,d6
.lCB5A:
	jsr	sub_13EC
	dbf	d6,.lCB5A
	clr.w	ADSP_CONTROL+$A
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	rts
dat_CB72:
	incbin	"../../build/stunrun-68k.bin",$CB72,$32
sub_CBA4:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$158,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_C8CE
sub_CBC2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$159,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_CA02
sub_CBE0:
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15A,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.l	(ram_FF80D8-ABS_SHORT).w
.lCC08:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lCC26
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lCC26:
	bsr.w	sub_CD48
	clr.w	WATCHDOG
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lCC3C:
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lCC48
	bsr.w	sub_CC7E
.lCC48:
	addq.w	#1,d1
	dbf	d0,.lCC3C
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.s	.lCC08
sub_CC7E:
	movem.l	d0-d7/a0,-(sp)
	move.w	a0,d0
	subq.w	#2,d0
	lsr.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	move.w	d2,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	move.w	#$146,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lCCD2:
	jsr	sub_1368
	jsr	sub_13EC
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lCCEE
	clr.w	(ram_FF8036-ABS_SHORT).w
	bra.w	.lCCFA
.lCCEE:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lCD1E
	clr.w	(ram_FF8046-ABS_SHORT).w
.lCCFA:
	move.w	#$6,d0
	jsr	sub_65E0
	move.w	#$8,d0
	jsr	sub_65E0
	move.w	#$147,d0
	jsr	sub_2326
	movem.l	(sp)+,d0-d7/a0
	rts
.lCD1E:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	.lCCD2
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	movem.l	(sp)+,d0-d7/a0
	addq.l	#4,sp
	rts
dat_CD3A:
	incbin	"../../build/stunrun-68k.bin",$CD3A,$E
sub_CD48:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lCD54:
	move.w	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.lCD54
	rts
sub_CD5E:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15B,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	clr.l	(ram_FF80D8-ABS_SHORT).w
.lCD8A:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lCDA8
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lCDA8:
	move.w	#$12,d7
	bsr.w	sub_CAF8
	clr.w	WATCHDOG
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lCDC2:
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lCDCE
	bsr.w	sub_CC7E
.lCDCE:
	addq.w	#1,d1
	dbf	d0,.lCDC2
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.s	.lCD8A
sub_CE04:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15C,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	clr.l	(ram_FF80D8-ABS_SHORT).w
.lCE30:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lCE4E
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lCE4E:
	move.w	#$13,d7
	bsr.w	sub_CAF8
	clr.w	WATCHDOG
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lCE68:
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lCE74
	bsr.w	sub_CC7E
.lCE74:
	addq.w	#1,d1
	dbf	d0,.lCE68
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.s	.lCE30
sub_CEAA:
	movea.l	(ram_FF8140-ABS_SHORT).w,a0
	clr.w	(a0)
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15D,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.l	(ram_FF80D8-ABS_SHORT).w
loc_CED2:
	clr.w	SOUND_RESET+$10
	bsr.w	sub_CF72
	clr.w	SOUND_RESET
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.w	loc_CF12
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
dat_CF00:
	incbin	"../../build/stunrun-68k.bin",$CF00,$12
loc_CF12:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lCF22:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,d1
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lCF3C
	bsr.w	sub_CC7E
.lCF3C:
	dbf	d0,.lCF22
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.w	loc_CED2
sub_CF72:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lCF82:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,(a0)+
	dbf	d0,.lCF82
	rts
sub_CF96:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15E,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	clr.l	(ram_FF80D8-ABS_SHORT).w
loc_CFC2:
	clr.w	ADSP_CONTROL+$A
	move.l	#$443F00,d7
	move.l	d7,ADSP_PRAM+$7000
	move.l	#$4A4500,d7
	move.l	d7,ADSP_PRAM+$7004
	move.w	#$14,d7
	bsr.w	sub_CB34
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.w	loc_D018
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
dat_D006:
	incbin	"../../build/stunrun-68k.bin",$D006,$12
loc_D018:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lD028:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,d1
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lD042
	bsr.w	sub_CC7E
.lD042:
	dbf	d0,.lD028
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.w	loc_CFC2
sub_D078:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$15F,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	bsr.w	sub_B1E8
	clr.w	ADSP_CONTROL+$A
	clr.l	(ram_FF80D8-ABS_SHORT).w
loc_D0A4:
	clr.w	ADSP_CONTROL+$A
	move.l	#$443F00,d7
	move.l	d7,ADSP_PRAM+$7000
	move.l	#$4A4500,d7
	move.l	d7,ADSP_PRAM+$7004
	move.w	#$15,d7
	bsr.w	sub_CB34
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.w	loc_D0FA
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
dat_D0E8:
	incbin	"../../build/stunrun-68k.bin",$D0E8,$12
loc_D0FA:
	lea	ADSP_BUFFER,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lD10A:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,d1
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lD124
	bsr.w	sub_CC7E
.lD124:
	dbf	d0,.lD10A
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.w	loc_D0A4
dat_D15A:
	incbin	"../../build/stunrun-68k.bin",$D15A,$7C
sub_D1D6:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.lD1DE:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($4,a0),d2
	jsr	sub_23F2
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	movea.l	($8,a0),a1
	move.w	($6,a0),(ram_FF8090-ABS_SHORT).w
	jsr	sub_2418
	clr.l	d1
	move.w	(a1),d1
	move.l	d1,(ram_FF8092-ABS_SHORT).w
	jsr	sub_D228
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$C,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	bne.s	.lD1DE
	rts
sub_D228:
	move.w	(ram_FF8090-ABS_SHORT).w,d4
	move.l	(ram_FF8092-ABS_SHORT).w,d3
	btst	d4,d3
	beq.w	.lD244
	move.b	#$31,d1
	jsr	sub_22EC
	bra.w	.lD24E
.lD244:
	move.b	#$30,d1
	jsr	sub_22EC
.lD24E:
	addi.l	#$10,d0
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bpl.s	sub_D228
	rts
sub_D25C:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.lD264:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	#$0,d2
	jsr	sub_23F2
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	movea.l	($8,a0),a1
	move.w	($6,a0),(ram_FF8090-ABS_SHORT).w
	jsr	sub_2418
	clr.l	d1
	move.w	(a1),d1
	move.l	d1,(ram_FF8092-ABS_SHORT).w
	jsr	sub_D2AE
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$C,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	bne.s	.lD264
	rts
sub_D2AE:
	move.w	(ram_FF8090-ABS_SHORT).w,d4
	move.b	#$5C,d1
	jsr	sub_22EC
	addi.l	#$10,d0
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bpl.s	sub_D2AE
	rts
tbl_D2CA:
	dc.l	sub_D3DA
	dc.l	sub_D3F6
	dc.l	sub_D4B0
	dc.l	sub_D57A
	dc.l	sub_D598
	dc.l	sub_D5B6
	dc.l	sub_D66E
	dc.l	sub_D73A
	dc.l	sub_D858
	dc.l	sub_D96C
	dc.l	sub_D98A
	dc.l	sub_D9A8
	dc.l	sub_DA56
	dc.l	sub_DB06
	dc.l	sub_DBF2
loc_D306:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8026-ABS_SHORT).w
	bra.w	.lD388
.lD324:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lD34E
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$F,d0
	bne.w	.lD346
	clr.w	d0
.lD346:
	move.w	d0,(ram_FF8026-ABS_SHORT).w
	bra.w	.lD388
.lD34E:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lD370
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.lD368
	move.w	#$E,d0
.lD368:
	move.w	d0,(ram_FF8026-ABS_SHORT).w
	bra.w	.lD388
.lD370:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD380
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lD3AE
.lD380:
	jsr	sub_13EC
	bra.s	.lD324
.lD388:
	move.w	#$160,d1
	move.w	#$E,d2
	jsr	sub_145E
	move.w	#$14D,d0
	jsr	sub_2326
	bsr.w	sub_D3C6
	jsr	sub_13EC
	bra.w	.lD324
.lD3AE:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_D2CA,a0
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.lD388
sub_D3C6:
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	addi.w	#$160,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_D3DA:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
sub_D3F6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$16F,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_D410:
	clr.w	ADSP_CONTROL+$A
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lD436:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lD452
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD452:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lD468
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD468:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD480
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD480:
	move.w	(ram_FF8098-ABS_SHORT).w,ADSP_DRAM
	move.w	ADSP_DRAM,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.s	.lD436
sub_D4B0:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$170,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_D4CA:
	move.w	#$145,d0
	jsr	sub_2326
	move.w	#$149,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lD4EA:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lD506
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD506:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lD51C
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD51C:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD534
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD534:
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	not.w	d0
	move.w	d0,ADSP_DRAM+$2
	lea	dat_BFBA,a0
	bsr.w	sub_BE6A
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM,(ram_FF809A-ABS_SHORT).w
	lea	dat_C532,a0
	jsr	sub_D25C
	lea	dat_C532,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lD4EA
sub_D57A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$171,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_D410
sub_D598:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$172,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_D4CA
sub_D5B6:
	clr.w	ADSP_CONTROL+$A
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$173,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8148-ABS_SHORT).w
	clr.l	(ram_FF80D8-ABS_SHORT).w
	clr.w	(ram_FF8120-ABS_SHORT).w
.lD5F2:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD610
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD610:
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	move.w	#$FF,d1
.lD618:
	move.w	d0,ADSP_DRAM
	move.w	ADSP_DRAM,d2
	cmp.w	d0,d2
	beq.w	.lD62E
	bsr.w	sub_C73A
.lD62E:
	addq.w	#1,d0
	dbf	d1,.lD618
	move.w	d0,(ram_FF8148-ABS_SHORT).w
	jsr	sub_13EC
	addq.b	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lD5F2
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_C7E8,a0
	jsr	sub_988C
	lea	dat_C7E8,a0
	jsr	sub_9980
	bra.s	.lD5F2
sub_D66E:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$174,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8148-ABS_SHORT).w
	clr.l	(ram_FF80D8-ABS_SHORT).w
	clr.w	(ram_FF8120-ABS_SHORT).w
.lD6A4:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD6C2
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD6C2:
	move.w	#$100,(ram_FF8090-ABS_SHORT).w
.lD6C8:
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	not.w	d0
	move.w	d0,ADSP_DRAM+$2
	lea	dat_BFBA,a0
	bsr.w	sub_BE6A
	clr.w	ADSP_CONTROL+$A
	move.w	ADSP_DRAM,d2
	move.w	(ram_FF8148-ABS_SHORT).w,d0
	cmp.w	d0,d2
	beq.w	.lD6F8
	bsr.w	sub_C73A
.lD6F8:
	addq.w	#1,(ram_FF8148-ABS_SHORT).w
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bne.s	.lD6C8
	jsr	sub_13EC
	addq.b	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.lD6A4
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_C7E8,a0
	jsr	sub_988C
	lea	dat_C7E8,a0
	jsr	sub_9980
	bra.w	.lD6A4
sub_D73A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$175,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_D754:
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
	bsr.w	sub_D842
.lD792:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lD7C4
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	subq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	bpl.w	.lD7C0
	move.b	#$C,(ram_FF80C8-ABS_SHORT).w
	ror.w	#3,d0
.lD7C0:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD7C4:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lD7F2
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	addq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$D,d1
	bne.w	.lD7EE
	clr.b	(ram_FF80C8-ABS_SHORT).w
	rol.w	#3,d0
.lD7EE:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD7F2:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD80A
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD80A:
	lea	ADSP_DRAM,a0
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	lsl.w	#1,d0
	andi.w	#$3FFF,d0
	move.w	($0,a0,d0.w),(ram_FF809A-ABS_SHORT).w
	lea	dat_C9B6,a0
	jsr	sub_D25C
	lea	dat_C9B6,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lD792
sub_D842:
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lD84E:
	move.w	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.lD84E
	rts
sub_D858:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$176,d0
	jsr	sub_2326
	move.w	#$1,(ram_FF8098-ABS_SHORT).w
loc_D872:
	lea	dat_BFD8,a0
	bsr.w	sub_BE6A
	jsr	sub_13EC
	jsr	sub_13EC
	clr.w	ADSP_CONTROL+$A
	clr.w	(ram_FF80C8-ABS_SHORT).w
	move.w	#$14B,d0
	jsr	sub_2326
	move.w	#$14C,d0
	jsr	sub_2326
	move.w	#$14A,d0
	jsr	sub_2326
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
.lD8BC:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lD8EE
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	ror.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	subq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	bpl.w	.lD8EA
	move.b	#$C,(ram_FF80C8-ABS_SHORT).w
	ror.w	#3,d0
.lD8EA:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD8EE:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lD91C
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	rol.w	#1,d0
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	addq.b	#1,d1
	move.b	d1,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$D,d1
	bne.w	.lD918
	clr.b	(ram_FF80C8-ABS_SHORT).w
	rol.w	#3,d0
.lD918:
	move.w	d0,(ram_FF8098-ABS_SHORT).w
.lD91C:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD934
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD934:
	lea	ADSP_DRAM,a0
	move.w	(ram_FF8098-ABS_SHORT).w,d0
	lsl.w	#1,d0
	andi.w	#$3FFF,d0
	move.w	($0,a0,d0.w),(ram_FF809A-ABS_SHORT).w
	lea	dat_C9B6,a0
	jsr	sub_D25C
	lea	dat_C9B6,a0
	jsr	sub_D1D6
	jsr	sub_13EC
	bra.w	.lD8BC
sub_D96C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$177,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_D754
sub_D98A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$178,d0
	jsr	sub_2326
	move.w	#$FFFE,(ram_FF8098-ABS_SHORT).w
	bra.w	loc_D872
sub_D9A8:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$179,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.l	(ram_FF80D8-ABS_SHORT).w
.lD9CA:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lD9E8
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lD9E8:
	bsr.w	sub_DA40
	clr.w	WATCHDOG
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lD9FE:
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lDA0A
	bsr.w	sub_CC7E
.lDA0A:
	addq.w	#1,d1
	dbf	d0,.lD9FE
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.s	.lD9CA
sub_DA40:
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lDA4C:
	move.w	d1,(a0)+
	addq.w	#1,d1
	dbf	d0,.lDA4C
	rts
sub_DA56:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$17A,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	lea	dat_BFD8,a0
	bsr.w	sub_BE6A
	jsr	sub_13EC
	jsr	sub_13EC
	clr.w	ADSP_CONTROL+$A
	clr.l	(ram_FF80D8-ABS_SHORT).w
.lDA94:
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lDAB2
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.lDAB2:
	clr.w	WATCHDOG
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	clr.w	d1
.lDAC4:
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lDAD0
	bsr.w	sub_CC7E
.lDAD0:
	addq.w	#1,d1
	dbf	d0,.lDAC4
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.s	.lDA94
sub_DB06:
	clr.w	ADSP_CONTROL+$A
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$17B,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.l	(ram_FF80D8-ABS_SHORT).w
loc_DB2E:
	clr.w	SOUND_RESET+$10
	bsr.w	sub_DBCE
	clr.w	SOUND_RESET
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.w	loc_DB6E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
dat_DB5C:
	incbin	"../../build/stunrun-68k.bin",$DB5C,$12
loc_DB6E:
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lDB7E:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,d1
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lDB98
	bsr.w	sub_CC7E
.lDB98:
	dbf	d0,.lDB7E
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.w	loc_DB2E
sub_DBCE:
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lDBDE:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,(a0)+
	dbf	d0,.lDBDE
	rts
sub_DBF2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$17C,d0
	jsr	sub_2326
	move.w	#$147,d0
	jsr	sub_2326
	clr.l	(ram_FF80D8-ABS_SHORT).w
loc_DC14:
	clr.w	ADSP_CONTROL+$A
	move.l	#$443F00,d7
	move.l	d7,ADSP_PRAM+$7000
	move.l	#$4A4500,d7
	move.l	d7,ADSP_PRAM+$7004
	lea	dat_C008,a0
	bsr.w	sub_BE6A
	jsr	sub_13EC
	move.w	#$1E,d6
.lDC46:
	jsr	sub_13EC
	dbf	d6,.lDC46
	clr.w	ADSP_CONTROL+$A
	movea.l	dat_135E,a0
	move.w	dat_1362,d1
	and.w	(a0),d1
	bne.w	loc_DC86
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
dat_DC74:
	incbin	"../../build/stunrun-68k.bin",$DC74,$12
loc_DC86:
	lea	ADSP_DRAM,a0
	move.w	#$1FFF,d0
	move.l	#$4A45443F,d7
.lDC96:
	clr.w	WATCHDOG
	jsr	sub_394E
	move.w	d7,d1
	move.w	(a0)+,d2
	cmp.w	d1,d2
	beq.w	.lDCB0
	bsr.w	sub_CC7E
.lDCB0:
	dbf	d0,.lDC96
	jsr	sub_13EC
	move.w	#$148,d0
	jsr	sub_2326
	jsr	sub_9A70
	lea	dat_CD3A,a0
	jsr	sub_988C
	lea	dat_CD3A,a0
	jsr	sub_9980
	bra.w	loc_DC14
tbl_DCE6:
	dc.l	sub_DDD6
	dc.l	sub_DDF2
	dc.l	sub_DF10
	dc.l	sub_E014
	dc.l	sub_E038
	dc.l	sub_E058
	dc.l	sub_E176
loc_DD02:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8026-ABS_SHORT).w
	bra.w	.lDD84
.lDD20:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.lDD4A
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$7,d0
	bne.w	.lDD42
	clr.w	d0
.lDD42:
	move.w	d0,(ram_FF8026-ABS_SHORT).w
	bra.w	.lDD84
.lDD4A:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.lDD6C
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.lDD64
	move.w	#$6,d0
.lDD64:
	move.w	d0,(ram_FF8026-ABS_SHORT).w
	bra.w	.lDD84
.lDD6C:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.lDD7C
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.lDDAA
.lDD7C:
	jsr	sub_13EC
	bra.s	.lDD20
.lDD84:
	move.w	#$17D,d1
	move.w	#$6,d2
	jsr	sub_145E
	move.w	#$14E,d0
	jsr	sub_2326
	bsr.w	sub_DDC2
	jsr	sub_13EC
	bra.w	.lDD20
.lDDAA:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_DCE6,a0
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.lDD84
sub_DDC2:
	move.w	(ram_FF8026-ABS_SHORT).w,d0
	addi.w	#$17D,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_DDD6:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
	assert	*=$00DDF2,"boot/code_009E80.asm does not end at 00DDF2"
