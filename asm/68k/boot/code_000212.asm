; boot/code_000212.asm, 000212-00394E: boot program code (pair R) with the data,
; text and tables that lie between its routines; the first routine is boot_line_a_etc. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the boot naming legs (M5a, M5c-e for the boot program's tests and menus).
;
; Generated once by tools/m68k gen 000212 00394E (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$000212,"boot/code_000212.asm misplaced"
boot_line_a_etc:
	stop	#$2700
boot_reset:
	lea	vec_reset_sp.w,a0
	movea.l	($0,a0),sp
	movec	a0,vbr
	clr.w	PORT0
	reset
	clr.w	WATCHDOG
	clr.w	PORT0
	clr.w	ADSP_IRQ_CLEAR
	move.w	SOUND_RESET,d0
	move.b	JSA_PORT,d0
	clr.w	io_840000
	clr.w	io_84C000
	btst	#$5,PORT0+$1
	beq.w	boot_select_self_test
loc_260:
	move.w	#$2F00,sr
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
boot_start_game:
	lea	game_vec_reset_sp,a0
	movea.l	($0,a0),sp
	movea.l	($4,a0),a1
	movec	a0,vbr
	clr.w	PORT0
	jmp	(a1)
boot_select_self_test:
	btst	#$0,PORT0+$1
	bne.w	.l2B2
	jmp	loc_8FEE
.l2B2:
	jmp	loc_506C
dat_2B8:
	incbin	"../../build/stunrun-68k.bin",$2B8,$30
dat_2E8:
	incbin	"../../build/stunrun-68k.bin",$2E8,$11
dat_2F9:
	incbin	"../../build/stunrun-68k.bin",$2F9,$33
dat_32C:
	incbin	"../../build/stunrun-68k.bin",$32C,$1E
sub_34A:
	lea	dat_2B8,a0
	move.w	dat_2E8,d0
.l356:
	move.l	(a0),GSP_HOST+$2
	move.w	($4,a0),GSP_HOST+$C
	adda.l	#$6,a0
	dbf	d0,.l356
	rts
boot_delay:
	move.l	#$190,d0
.l376:
	subq.w	#1,d0
	bne.s	.l376
	rts
sub_37C:
	lea	dat_32C,a0
	mulu.w	#$A,d0
	adda.l	d0,a0
	clr.w	d3
	clr.w	d0
	movea.l	(a0),a1
	move.w	($4,a0),d5
.l392:
	move.b	($0,a1),d0
	clr.w	d1
	move.b	($1,a1),d1
	and.w	d1,d0
	move.b	($2,a1),d2
	lsl.w	d2,d0
	or.w	d0,d3
	adda.w	#$3,a1
	dbf	d5,.l392
	move.l	($6,a0),GSP_HOST+$2
	move.w	d3,GSP_HOST+$C
	rts
sub_3BE:
	move.l	#$C0000090,GSP_HOST+$2
	moveq	#$0,d0
	lsr.l	#8,d0
	tst.b	dat_2F9
	bne.w	.l3D8
	not.w	d0
.l3D8:
	andi.w	#$FFFC,d0
	ori.w	#$3,d0
	move.w	d0,GSP_HOST+$C
	move.l	#$F4800000,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	rts
boot_init_gsp:
	movem.l	d2-d7/a2-a6,-(sp)
	clr.w	SOUND_RESET+$C
	bsr.w	boot_delay
	clr.w	SOUND_RESET+$1C
	move.w	#$A000,GSP_HOST+$8
	move.w	#$2,d0
	bsr.w	sub_37C
	bsr.w	sub_34A
	bsr.w	sub_7C2
	bsr.s	sub_3BE
	move.w	#$1,d0
	bsr.w	sub_37C
	move.w	#$0,d0
	bsr.w	sub_37C
	bsr.w	sub_48E
	lea	GSP_HOST+$2,a1
	lea	GSP_HOST+$C,a2
	move.l	#$F4800010,(a1)
	move.w	#$0,(a2)
	move.l	#$F4800090,(a1)
	move.w	#$FFFF,(a2)
	move.w	#$0,d0
	bsr.w	sub_67A
	movem.l	(sp)+,d2-d7/a2-a6
	rts
sub_468:
	move.l	#$F4800010,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	#$F4800090,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	rts
sub_48E:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	clr.w	d0
	move.l	#$F5000000,GSP_HOST+$2
	move.w	#$FF,d1
.l4C6:
	move.w	d0,GSP_HOST+$C
	addi.w	#$101,d0
	dbf	d1,.l4C6
	clr.w	d0
	move.l	#$F5800000,GSP_HOST+$2
	move.w	#$FF,d1
.l4E4:
	move.w	d0,GSP_HOST+$C
	addq.w	#1,d0
	dbf	d1,.l4E4
	bsr.w	sub_468
	rts
sub_4F6:
	move.w	#$1F,d2
	move.w	#$0,d3
	move.w	#$0,d4
.l502:
	move.w	d3,d5
	lsl.w	#8,d5
	move.b	d4,d5
	move.w	d5,GSP_HOST+$C
	add.b	d0,d3
	add.b	d1,d4
	dbf	d2,.l502
	rts
sub_518:
	move.w	#$1F,d2
	move.w	#$0,d3
.l520:
	move.w	d3,d5
	move.w	d5,GSP_HOST+$C
	add.b	d0,d3
	dbf	d2,.l520
	rts
sub_530:
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
boot_load_gsp_palette:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F5000000,GSP_HOST+$2
	move.w	#$0,d0
	move.w	#$0,d1
	bsr.w	sub_4F6
	bsr.w	sub_4F6
	move.w	#$0,d0
	move.w	#$8,d1
	bsr.w	sub_4F6
	bsr.w	sub_4F6
	move.w	#$8,d0
	move.w	#$0,d1
	bsr.w	sub_4F6
	bsr.w	sub_4F6
	move.w	#$8,d0
	move.w	#$8,d1
	bsr.w	sub_4F6
	bsr.w	sub_4F6
	move.l	#$F5800000,GSP_HOST+$2
	move.w	#$0,d0
	bsr.w	sub_518
	move.w	#$8,d0
	bsr.w	sub_518
	move.w	#$0,d0
	bsr.w	sub_518
	move.w	#$8,d0
	bsr.w	sub_518
	move.w	#$0,d0
	bsr.w	sub_518
	move.w	#$8,d0
	bsr.w	sub_518
	move.w	#$0,d0
	bsr.w	sub_518
	move.w	#$8,d0
	bsr.w	sub_518
	bsr.w	sub_530
	bsr.w	sub_468
	rts
boot_fill_gsp_vram:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4000000,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.l	#$2000000,GSP_HOST+$2
	move.w	#$FFFF,d0
	move.w	#$5F,d2
.l660:
	move.w	#$FF,d1
.l664:
	move.w	d0,GSP_HOST+$C
	dbf	d1,.l664
	clr.w	WATCHDOG
	dbf	d2,.l660
	rts
sub_67A:
	ori.w	#$1800,GSP_HOST+$8
	lea	GSP_HOST+$C,a0
	move.l	#$FF800000,GSP_HOST+$2
	move.w	#$383,d2
.l696:
	move.w	#$FF,d1
.l69A:
	move.w	d0,(a0)
	dbf	d1,.l69A
	clr.w	WATCHDOG
	dbf	d2,.l696
	rts
dat_6AC:
	incbin	"../../build/stunrun-68k.bin",$6AC,$42
sub_6EE:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.w	#$FF,d0
	move.w	(ram_FF801C-ABS_SHORT).w,d1
	move.l	#$F5800000,GSP_HOST+$2
.l728:
	move.w	d1,GSP_HOST+$C
	dbf	d0,.l728
	move.w	#$FF,d0
	move.w	(ram_FF8018-ABS_SHORT).w,d1
	lsl.w	#8,d1
	move.b	(ram_FF801B-ABS_SHORT).w,d1
	move.l	#$F5000000,GSP_HOST+$2
.l74A:
	move.w	d1,GSP_HOST+$C
	dbf	d0,.l74A
	rts
sub_756:
	move.l	#$2000200,d0
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.w	#$FFFF,GSP_HOST+$C
	move.w	#$FFFF,d3
	move.w	#$17F,d5
.l77E:
	move.l	d0,GSP_HOST+$2
	clr.w	WATCHDOG
	bsr.w	sub_7A6
	move.w	d3,GSP_HOST+$C
	move.w	d3,GSP_HOST+$C
	addi.l	#$400,d0
	dbf	d5,.l77E
	rts
sub_7A6:
	move.w	#$FA0,d1
.l7AA:
	subq.w	#1,d1
	bne.s	.l7AA
	rts
dat_7B0:
	incbin	"../../build/stunrun-68k.bin",$7B0,$12
sub_7C2:
	move.l	#$C0000150,GSP_HOST+$2
	move.w	#$1,GSP_HOST+$C
	rts
boot_level3_gsp:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$FFFF,ram_FF9046
	andi.w	#$FF7F,GSP_HOST+$8
	movem.l	(sp)+,d0-d1/a0-a1
	rte
boot_level2_adsp:
	movem.l	d0-d1/a0-a1,-(sp)
	movem.l	(sp)+,d0-d1/a0-a1
	rte
boot_level1_msp:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$FFFF,(ram_FF80E6-ABS_SHORT).w
	andi.w	#$FF7F,MSP_HOST+$8
	movem.l	(sp)+,d0-d1/a0-a1
	rte
boot_level6_duart:
	movem.l	d0-d1/a0-a1,-(sp)
	movem.l	(sp)+,d0-d1/a0-a1
	rte
boot_level4_sound:
	movem.l	d0-d1/a0-a1,-(sp)
	move.b	JSA_PORT,d0
	movem.l	(sp)+,d0-d1/a0-a1
	rte
boot_level5_timer:
	movem.l	d0-d1/a0-a1,-(sp)
	addq.l	#1,ram_FF9042
	clr.l	d0
	move.b	(ram_FF800F-ABS_SHORT).w,d0
	andi.b	#$7,d0
	lea	(ram_FF8007-ABS_SHORT).w,a0
	adda.w	d0,a0
	move.b	ADC8_DATA+$1,(a0)
	clr.l	d0
	move.b	(ram_FF800F-ABS_SHORT).w,d0
	andi.b	#$3,d0
	lsl.l	#1,d0
	lea	(ram_FF8010-ABS_SHORT).w,a0
	adda.w	d0,a0
	move.w	#$80,ADC12
	move.b	ADC12+$1,d0
	andi.b	#$F,d0
	lsl.w	#8,d0
	clr.w	ADC12
	move.b	ADC12+$1,d0
	move.w	d0,(a0)
	addq.b	#1,(ram_FF800F-ABS_SHORT).w
	move.b	(ram_FF800F-ABS_SHORT).w,d0
	andi.b	#$3,d0
	lsl.b	#4,d0
	move.b	(ram_FF800F-ABS_SHORT).w,d1
	andi.b	#$7,d1
	or.b	d1,d0
	move.w	d0,ADC12
	ori.b	#$48,d0
	move.w	d0,ADC12
	andi.b	#$B7,d0
	move.w	d0,ADC12
	bsr.w	boot_read_wheel
	movem.l	(sp)+,d0-d1/a0-a1
	clr.w	PORT0
	rte
boot_read_wheel:
	clr.w	d0
	move.b	io_400000,d0
	move.w	(ram_FF8132-ABS_SHORT).w,d1
	sub.b	d0,d1
	ext.w	d1
	move.w	d0,(ram_FF8132-ABS_SHORT).w
	add.w	d1,(ram_FF8130-ABS_SHORT).w
	btst	#$6,BUTTONS
	bne.w	.l8FA
	clr.w	io_408000
	clr.w	(ram_FF812E-ABS_SHORT).w
	move.w	#$400,(ram_FF8136-ABS_SHORT).w
	bra.w	.l8FE
.l8FA:
	add.w	d1,(ram_FF812E-ABS_SHORT).w
.l8FE:
	tst.w	(ram_FF8136-ABS_SHORT).w
	beq.w	.l90C
	subi.w	#$10,(ram_FF8136-ABS_SHORT).w
.l90C:
	rts
sub_90E:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	bsr.w	sub_958
	move.w	#$1,d0
	bsr.w	sub_958
	move.w	#$2,d0
	bsr.w	sub_958
	move.w	#$3,d0
	bsr.w	sub_958
	move.w	#$4,d0
	bsr.w	sub_958
	move.w	#$5,d0
	bsr.w	sub_958
	move.w	#$6,d0
	bsr.w	sub_958
	move.w	#$7,d0
	bsr.w	sub_958
	rts
sub_958:
	lea	(ram_FF8007-ABS_SHORT).w,a0
	clr.w	d1
	move.b	($0,a0,d0.w),d1
	move.w	#$2800,d2
	mulu.w	d0,d2
	addi.l	#$F800,d2
	addi.l	#$2000000,d2
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	d2,GSP_HOST+$2
	move.w	#$1F,d3
.l990:
	move.w	#$FFFF,GSP_HOST+$C
	dbf	d3,.l990
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.l	d2,GSP_HOST+$2
.l9B4:
	subq.w	#8,d1
	bmi.w	.l9C4
	move.w	#$FFFF,GSP_HOST+$C
	bra.s	.l9B4
.l9C4:
	addq.b	#8,d1
	clr.l	d3
	move.b	d1,d3
	lsl.l	#1,d3
	lea	dat_9DC,a0
	move.w	($0,a0,d3.w),GSP_HOST+$C
	rts
dat_9DC:
	incbin	"../../build/stunrun-68k.bin",$9DC,$6A
sub_A46:
	ori.w	#$1800,GSP_HOST+$8
	move.w	(a0)+,d5
	move.w	#$FFFF,d3
.lA54:
	clr.w	WATCHDOG
	move.l	#$2000000,d0
	add.l	($0,a0),d0
	move.w	($4,a0),d2
	move.w	($6,a0),d1
	move.l	#$F4000000,GSP_HOST+$2
	move.w	($8,a0),GSP_HOST+$C
.lA7E:
	move.l	d0,GSP_HOST+$2
	move.w	d2,d4
.lA86:
	move.w	d3,GSP_HOST+$C
	dbf	d4,.lA86
	addi.l	#$400,d0
	subq.w	#1,d1
	bne.s	.lA7E
	adda.l	#$A,a0
	subq.w	#1,d5
	bne.s	.lA54
	rts
dat_AA6:
	incbin	"../../build/stunrun-68k.bin",$AA6,$F4
dat_B9A:
	incbin	"../../build/stunrun-68k.bin",$B9A,$2A
sub_BC4:
	ori.w	#$1800,GSP_HOST+$8
	move.w	(a0)+,d5
.lBCE:
	move.w	(a0),d1
	move.w	($2,a0),d0
	jsr	sub_2418
	move.l	#$F4000000,GSP_HOST+$2
	move.w	($6,a0),GSP_HOST+$C
	move.w	($4,a0),d1
	move.w	#$FFFF,d3
	lea	GSP_HOST+$C,a1
	move.l	d0,GSP_HOST+$2
	move.w	d1,d2
	move.w	#$7,d4
.lC06:
	move.w	d3,(a1)
	move.w	d3,(a1)
	dbf	d2,.lC06
	addi.l	#$400,d0
	move.l	d0,GSP_HOST+$2
	move.w	d1,d2
	dbf	d4,.lC06
	addq.l	#8,a0
	dbf	d5,.lBCE
	rts
sub_C28:
	move.l	#$2000000,d0
	move.w	#$F,d1
	move.w	#$1,d2
.lC36:
	bsr.w	sub_C46
	addi.l	#$4000,d0
	subq.w	#1,d1
	bne.s	.lC36
	rts
sub_C46:
	move.l	d0,d3
	move.w	#$20,d4
.lC4C:
	move.l	d3,GSP_HOST+$2
	move.w	d2,GSP_HOST+$C
	addi.l	#$20,d3
	subq.w	#1,d4
	bne.s	.lC4C
	rts
sub_C64:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF800000,GSP_HOST+$2
	move.w	#$F0,d6
.lC7A:
	bsr.w	sub_C8A
	clr.w	WATCHDOG
	dbf	d6,.lC7A
	rts
sub_C8A:
	move.w	#$0,d0
	move.w	#$FFFF,GSP_HOST+$C
	move.w	#$FA,d1
.lC9A:
	move.w	d0,GSP_HOST+$C
	addi.w	#$100,d0
	addq.b	#1,d0
	dbf	d1,.lC9A
	clr.w	d1
	move.w	#$3,d2
.lCB0:
	move.w	d1,GSP_HOST+$C
	dbf	d2,.lCB0
	rts
dat_CBC:
	incbin	"../../build/stunrun-68k.bin",$CBC,$52
sub_D0E:
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	bsr.w	sub_D60
	bsr.w	sub_D2A
	rts
sub_D2A:
	move.l	#$2000000,d0
	move.l	d0,d3
	move.w	#$18,d1
	move.w	#$FFFF,d2
.lD3A:
	move.l	d3,GSP_HOST+$2
	move.w	#$1F,d4
.lD44:
	move.w	d2,GSP_HOST+$C
	move.w	d2,GSP_HOST+$C
	dbf	d4,.lD44
	addi.l	#$4000,d3
	subq.w	#1,d1
	bne.s	.lD3A
	rts
sub_D60:
	move.l	#$2000000,d0
	move.w	#$EF,d1
	move.w	#$1,d2
.lD6E:
	bsr.w	sub_C46
	addi.l	#$400,d0
	subq.w	#1,d1
	bne.s	.lD6E
	rts
sub_D7E:
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	bsr.w	sub_DAA
	andi.w	#$E7FF,GSP_HOST+$8
	bsr.w	sub_EB2
	ori.w	#$1800,GSP_HOST+$8
	rts
sub_DAA:
	move.w	#$1,d2
	move.l	#$2000000,d0
	bsr.w	sub_DF4
	move.w	#$FF00,d2
	move.l	#$20003E0,d0
	bsr.w	sub_DF4
	moveq	#-$1,d2
	move.l	#$2000000,d0
	bsr.w	sub_DDE
	move.l	#$203BC00,d0
	bsr.w	sub_DDE
	rts
sub_DDE:
	move.l	d0,GSP_HOST+$2
	move.w	#$3F,d4
.lDE8:
	move.w	d2,GSP_HOST+$C
	dbf	d4,.lDE8
	rts
sub_DF4:
	move.w	#$EF,d4
.lDF8:
	move.l	d0,GSP_HOST+$2
	move.w	d2,GSP_HOST+$C
	addi.l	#$400,d0
	dbf	d4,.lDF8
	rts
dat_E10:
	incbin	"../../build/stunrun-68k.bin",$E10,$2
dat_E12:
	incbin	"../../build/stunrun-68k.bin",$E12,$A0
sub_EB2:
	move.w	dat_E10,d7
	lea	dat_E12,a3
.lEBE:
	move.w	($0,a3),d1
	move.w	($2,a3),d0
	move.w	($8,a3),d5
	movea.l	($4,a3),a0
	jsr	(a0)
	adda.l	#$A,a3
	dbf	d7,.lEBE
	rts
sub_EDC:
	bsr.w	sub_EF8
	addq.w	#1,d1
	addq.w	#1,d0
	dbf	d5,sub_EDC
	rts
sub_EEA:
	bsr.w	sub_EF8
	addq.w	#1,d1
	subq.w	#1,d0
	dbf	d5,sub_EEA
	rts
sub_EF8:
	clr.l	d2
	move.w	d0,d2
	lsl.l	#8,d2
	lsl.l	#2,d2
	clr.l	d3
	move.w	d1,d3
	andi.w	#$FFF8,d3
	lsl.w	#1,d3
	add.l	d3,d2
	addi.l	#$2000400,d2
	move.w	d1,d3
	andi.l	#$7,d3
	lsl.w	#1,d3
	lea	dat_F34,a0
	adda.w	d3,a0
	move.w	(a0),d4
	move.l	d2,GSP_HOST+$2
	or.w	d4,GSP_HOST+$C
	rts
dat_F34:
	incbin	"../../build/stunrun-68k.bin",$F34,$20
sub_F54:
	move.w	(ram_FF8124-ABS_SHORT).w,d4
	tst.w	(ram_FF8126-ABS_SHORT).w
	bmi.w	.lF7A
	cmpi.w	#$7,d4
	beq.w	.lF6E
	addq.w	#1,d4
	bra.w	.lF8E
.lF6E:
	move.w	#$FFFF,(ram_FF8126-ABS_SHORT).w
	subq.w	#1,d4
	bra.w	.lF8E
.lF7A:
	cmpi.w	#$0,d4
	beq.w	.lF88
	subq.w	#1,d4
	bra.w	.lF8E
.lF88:
	clr.w	(ram_FF8126-ABS_SHORT).w
	addq.w	#1,d4
.lF8E:
	move.w	d4,(ram_FF8124-ABS_SHORT).w
	rts
loc_F94:
	move.w	#$0,d0
	jsr	sub_67A
	bra.w	loc_FB2
tbl_FA2:
	dc.l	sub_10D2
	dc.l	sub_1206
	dc.l	sub_116E
	dc.l	sub_1756
loc_FB2:
	movea.l	#$0,a0
	movec	a0,vbr
	movea.l	#$FFFFC000,sp
	move.w	SOUND_RESET,d0
	move.b	JSA_PORT,d0
	lea	(sub_FD6,pc),a2
	bra.w	loc_132A
sub_FD6:
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
	clr.w	(ram_FF801E-ABS_SHORT).w
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8066-ABS_SHORT).w
	clr.w	(ram_FF8076-ABS_SHORT).w
	clr.w	(ram_FF8086-ABS_SHORT).w
	lea	dat_135E,a0
	movea.l	($6,a0),a0
	move.w	#$F,($2,a0)
	move.w	#$FFFF,($4,a0)
	move.w	#$2400,sr
	bra.w	.l1092
.l1032:
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l105A
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF801E-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$4,d0
	bne.w	.l1052
	clr.w	d0
.l1052:
	move.w	d0,(ram_FF801E-ABS_SHORT).w
	bra.w	.l1092
.l105A:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l107C
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF801E-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l1074
	move.w	#$3,d0
.l1074:
	move.w	d0,(ram_FF801E-ABS_SHORT).w
	bra.w	.l1092
.l107C:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l108C
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l10A8
.l108C:
	bsr.w	sub_13EC
	bra.s	.l1032
.l1092:
	move.w	#$10,d1
	move.w	#$6,d2
	bsr.w	sub_145E
	bsr.w	sub_10BC
	bsr.w	sub_13EC
	bra.s	.l1032
.l10A8:
	lea	tbl_FA2,a0
	move.w	(ram_FF801E-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.l1092
sub_10BC:
	move.w	(ram_FF801E-ABS_SHORT).w,d0
	addq.w	#1,d0
	addi.w	#$10,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_10D2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$2F00,sr
	lea	game_vec_reset_sp,a0
	lea	game_entries,a1
	movec	a0,vbr
	clr.w	PORT0
	movea.l	#$0,sp
	jmp	(a1)
dat_10FE:
	incbin	"../../build/stunrun-68k.bin",$10FE,$38
tbl_1136:
	dc.l	sub_1494
	dc.l	sub_16E8
	dc.l	sub_14B0
	dc.l	sub_14D6
	dc.l	sub_14EC
	dc.l	sub_1514
	dc.l	sub_1528
	dc.l	sub_1722
	dc.l	sub_153C
	dc.l	sub_1556
	dc.l	sub_1570
	dc.l	sub_158A
	dc.l	sub_15A4
	dc.l	sub_162E
sub_116E:
	clr.w	(ram_FF8022-ABS_SHORT).w
	bra.w	.l11EC
.l1176:
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l119E
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$E,d0
	bne.w	.l1196
	clr.w	d0
.l1196:
	move.w	d0,(ram_FF8022-ABS_SHORT).w
	bra.w	.l11EC
.l119E:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l11C0
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l11B8
	move.w	#$D,d0
.l11B8:
	move.w	d0,(ram_FF8022-ABS_SHORT).w
	bra.w	.l11EC
.l11C0:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l11E6
	clr.w	(ram_FF8056-ABS_SHORT).w
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	rts
.l11E6:
	bsr.w	sub_13EC
	bra.s	.l1176
.l11EC:
	lea	tbl_1136,a0
	move.w	(ram_FF8022-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bsr.w	sub_13EC
	bra.w	.l1176
sub_1206:
	clr.w	ADSP_CONTROL+$40
	move.w	#$2400,sr
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$36,d0
	jsr	sub_2326
	move.w	#$103,d1
	move.w	#$1,d2
	bsr.w	sub_145E
	ori.w	#$1800,GSP_HOST+$8
.l1238:
	bsr.w	sub_13EC
	jsr	sub_90E
	lea	dat_1E5C,a0
	jsr	sub_98C6
	lea	dat_1E5C,a0
	jsr	sub_9A14
	bsr.w	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	bne.w	.l1274
	bsr.w	sub_12C6
	bsr.w	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	.l1238
.l1274:
	clr.w	(ram_FF8056-ABS_SHORT).w
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	rts
dat_1292:
	incbin	"../../build/stunrun-68k.bin",$1292,$34
sub_12C6:
	lea	dat_1300,a0
	move.w	(a0)+,(ram_FF8120-ABS_SHORT).w
.l12D0:
	movea.l	(a0),a1
	move.w	($4,a0),d1
	btst	d1,(a1)
	beq.w	.l12E4
	move.w	($6,a0),d0
	bra.w	.l12E8
.l12E4:
	move.w	($8,a0),d0
.l12E8:
	move.l	a0,-(sp)
	jsr	sub_2326
	movea.l	(sp)+,a0
	adda.l	#$A,a0
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.l12D0
	rts
dat_1300:
	incbin	"../../build/stunrun-68k.bin",$1300,$2A
loc_132A:
	clr.w	WATCHDOG
	lea	$FFFF8000,a0
	move.w	#$1FFF,d1
.l133A:
	clr.l	(a0)+
	dbf	d1,.l133A
	clr.w	WATCHDOG
	jmp	(a2)
dat_1348:
	incbin	"../../build/stunrun-68k.bin",$1348,$16
dat_135E:
	incbin	"../../build/stunrun-68k.bin",$135E,$4
dat_1362:
	incbin	"../../build/stunrun-68k.bin",$1362,$6
sub_1368:
	lea	dat_1348,a0
	move.w	(a0)+,d6
.l1370:
	bsr.w	sub_1392
	adda.l	#$A,a0
	dbf	d6,.l1370
	btst	#$5,PORT0+$1
	beq.w	.l1390
	jmp	loc_260
.l1390:
	rts
sub_1392:
	movea.l	(a0),a1
	move.w	($4,a0),d0
	movea.l	($6,a0),a2
	move.w	(a1),d1
	clr.w	(a2)
	and.w	d0,d1
	bne.w	.l13A8
	addq.w	#1,(a2)
.l13A8:
	move.w	($2,a2),d0
	lsl.w	#1,d0
	tst.w	(a2)
	beq.w	.l13B8
	ori.w	#$1,d0
.l13B8:
	move.w	d0,($2,a2)
	andi.w	#$F,d0
	bne.w	.l13CA
	clr.w	($4,a2)
	rts
.l13CA:
	cmpi.w	#$F,d0
	beq.w	.l13D4
	rts
.l13D4:
	tst.w	($4,a2)
	beq.w	.l13DE
	rts
.l13DE:
	move.w	#$1,($6,a2)
	move.w	#$1,($4,a2)
	rts
sub_13EC:
	clr.w	WATCHDOG
.l13F2:
	btst	#$2,PORT0+$1
	beq.s	.l13F2
.l13FC:
	btst	#$2,PORT0+$1
	bne.s	.l13FC
	btst	#$5,PORT0+$1
	beq.s	.l1416
	jmp	loc_260
.l1416:
	rts
loc_1418:
	bsr.s	sub_13EC
	bsr.w	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	loc_1418
	clr.w	(ram_FF8056-ABS_SHORT).w
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	rts
sub_1442:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	addq.l	#4,sp
	rts
sub_145E:
	move.w	d1,(ram_FF802A-ABS_SHORT).w
	move.w	d2,(ram_FF802C-ABS_SHORT).w
	clr.w	(ram_FF802E-ABS_SHORT).w
.l146A:
	move.w	(ram_FF802E-ABS_SHORT).w,d0
	add.w	(ram_FF802A-ABS_SHORT).w,d0
	jsr	sub_2326
	addq.w	#1,(ram_FF802E-ABS_SHORT).w
	move.w	(ram_FF802C-ABS_SHORT).w,d0
	cmp.w	(ram_FF802E-ABS_SHORT).w,d0
	bge.s	.l146A
	rts
sub_1488:
	move.w	#$CC,d1
	move.w	#$8,d2
	bsr.s	sub_145E
	rts
sub_1494:
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	lea	dat_AA6,a0
	bsr.w	sub_A46
	rts
sub_14B0:
	jsr	sub_48E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$22,d1
	move.w	#$6,d2
	bsr.s	sub_145E
	lea	dat_B9A,a0
	bsr.w	sub_BC4
	rts
sub_14D6:
	jsr	sub_48E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_C64
	rts
sub_14EC:
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	bsr.w	sub_C28
	rts
sub_1514:
	bsr.w	sub_48E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_D0E
	rts
sub_1528:
	bsr.w	sub_48E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_D7E
	rts
sub_153C:
	move.w	#$FFFF,(ram_FF8018-ABS_SHORT).w
	move.w	#$FFFF,(ram_FF801A-ABS_SHORT).w
	move.w	#$FFFF,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	rts
sub_1556:
	move.w	#$FFFF,(ram_FF8018-ABS_SHORT).w
	move.w	#$0,(ram_FF801A-ABS_SHORT).w
	move.w	#$0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	rts
sub_1570:
	move.w	#$0,(ram_FF8018-ABS_SHORT).w
	move.w	#$FFFF,(ram_FF801A-ABS_SHORT).w
	move.w	#$0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	rts
sub_158A:
	move.w	#$0,(ram_FF8018-ABS_SHORT).w
	move.w	#$0,(ram_FF801A-ABS_SHORT).w
	move.w	#$FFFF,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	rts
sub_15A4:
	move.w	#$30,d0
	move.w	d0,(ram_FF8018-ABS_SHORT).w
	move.w	d0,(ram_FF801A-ABS_SHORT).w
	move.w	d0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	move.w	#$24,(ram_FF8090-ABS_SHORT).w
.l15C0:
	bsr.w	sub_13EC
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	bne.w	.l162C
	tst.w	(ram_FF8046-ABS_SHORT).w
	bne.w	.l162C
	tst.w	(ram_FF8056-ABS_SHORT).w
	bne.w	.l162C
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bne.s	.l15C0
	move.w	#$FF,d0
	move.w	d0,(ram_FF8018-ABS_SHORT).w
	move.w	d0,(ram_FF801A-ABS_SHORT).w
	move.w	d0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	move.w	#$24,(ram_FF8090-ABS_SHORT).w
.l1602:
	bsr.w	sub_13EC
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	bne.w	.l162C
	tst.w	(ram_FF8046-ABS_SHORT).w
	bne.w	.l162C
	tst.w	(ram_FF8056-ABS_SHORT).w
	bne.w	.l162C
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bne.s	.l1602
	bra.w	sub_15A4
.l162C:
	rts
sub_162E:
	bsr.w	sub_48E
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_D7E
	move.w	#$7,(ram_FF8124-ABS_SHORT).w
	clr.w	(ram_FF8126-ABS_SHORT).w
.l164A:
	move.w	(ram_FF8124-ABS_SHORT).w,d4
	move.l	#$F4800090,GSP_HOST+$2
	move.w	d4,GSP_HOST+$C
	move.l	#$F4800010,GSP_HOST+$2
	move.w	d4,GSP_HOST+$C
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	#$2017C80,d0
	move.b	#$5C,d1
	jsr	sub_22EC
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.l	#$2017C80,d0
	move.w	d4,d1
	jsr	sub_240A
	move.w	#$10,(ram_FF8090-ABS_SHORT).w
.l16B6:
	jsr	sub_13EC
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	bne.w	.l16E6
	tst.w	(ram_FF8046-ABS_SHORT).w
	bne.w	.l16E6
	tst.w	(ram_FF8056-ABS_SHORT).w
	bne.w	.l16E6
	subq.w	#1,(ram_FF8090-ABS_SHORT).w
	bne.s	.l16B6
	bsr.w	sub_F54
	bra.w	.l164A
.l16E6:
	rts
sub_16E8:
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	lea	dat_FEFA,a0
	bsr.w	sub_A46
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	ori.w	#$1800,GSP_HOST+$8
	bsr.w	sub_DAA
	rts
sub_1722:
	move.w	#$68,d0
	move.w	d0,(ram_FF8018-ABS_SHORT).w
	move.w	d0,(ram_FF801A-ABS_SHORT).w
	move.w	d0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
	rts
tbl_173A:
	dc.l	sub_1442
	dc.l	sub_185C
	dc.l	sub_191E
	dc.l	sub_1946
	dc.l	sub_1AF6
	dc.l	sub_1B5A
	dc.l	sub_1C1C
sub_1756:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
	clr.w	(ram_FF8020-ABS_SHORT).w
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8066-ABS_SHORT).w
	clr.w	(ram_FF8076-ABS_SHORT).w
	clr.w	(ram_FF8086-ABS_SHORT).w
	lea	dat_135E,a0
	movea.l	($6,a0),a0
	move.w	#$F,($2,a0)
	move.w	#$FFFF,($4,a0)
	move.w	#$2400,sr
	bra.w	.l1800
.l17A0:
	bsr.w	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l17C8
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8020-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$7,d0
	bne.w	.l17C0
	clr.w	d0
.l17C0:
	move.w	d0,(ram_FF8020-ABS_SHORT).w
	bra.w	.l1800
.l17C8:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l17EA
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8020-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l17E2
	move.w	#$6,d0
.l17E2:
	move.w	d0,(ram_FF8020-ABS_SHORT).w
	bra.w	.l1800
.l17EA:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l17FA
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l1816
.l17FA:
	bsr.w	sub_13EC
	bra.s	.l17A0
.l1800:
	move.w	#$17,d1
	move.w	#$7,d2
	bsr.w	sub_145E
	bsr.w	sub_182A
	bsr.w	sub_13EC
	bra.s	.l17A0
.l1816:
	lea	tbl_173A,a0
	move.w	(ram_FF8020-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.l1800
sub_182A:
	move.w	(ram_FF8020-ABS_SHORT).w,d0
	addq.w	#1,d0
	addi.w	#$17,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
tbl_1840:
	dc.l	sub_1442
	dc.l	sub_1C2C
	dc.l	sub_1C86
	dc.l	sub_1CE6
	dc.l	sub_1D40
	dc.l	sub_1DC6
	dc.l	sub_1E48
sub_185C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8024-ABS_SHORT).w
	bra.w	.l18DC
.l187A:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l18A4
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$7,d0
	bne.w	.l189C
	clr.w	d0
.l189C:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l18DC
.l18A4:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l18C6
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l18BE
	move.w	#$6,d0
.l18BE:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l18DC
.l18C6:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l18D6
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l18F2
.l18D6:
	bsr.w	sub_13EC
	bra.s	.l187A
.l18DC:
	move.w	#$29,d1
	move.w	#$7,d2
	bsr.w	sub_145E
	bsr.w	sub_190A
	bsr.w	sub_13EC
	bra.s	.l187A
.l18F2:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_1840,a0
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.l18DC
sub_190A:
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addi.w	#$2A,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_191E:
	jmp	loc_3908
dat_1924:
	incbin	"../../build/stunrun-68k.bin",$1924,$22
sub_1946:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$A0,d1
	move.w	#$13,d2
	bsr.w	sub_145E
	move.w	#$B4,d1
	move.w	#$F,d2
	bsr.w	sub_145E
	bsr.w	sub_1970
	bra.w	loc_1418
sub_1970:
	clr.l	(ram_FF811C-ABS_SHORT).w
	move.w	#$7,(ram_FF8120-ABS_SHORT).w
	move.w	#$4,(ram_FF8122-ABS_SHORT).w
.l1980:
	movea.l	(ram_FF811C-ABS_SHORT).w,a0
	bsr.w	sub_19C6
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	movea.l	(ram_FF811C-ABS_SHORT).w,a0
	adda.l	#$1,a0
	bsr.w	sub_19C6
	move.w	d0,(ram_FF809A-ABS_SHORT).w
	bsr.w	sub_19FE
	addi.l	#$20000,(ram_FF811C-ABS_SHORT).w
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.l1980
	bsr.w	sub_1A3E
	move.w	d0,(ram_FF8098-ABS_SHORT).w
	bsr.w	sub_1AA8
	move.w	d0,(ram_FF809A-ABS_SHORT).w
	bsr.w	sub_19FE
	rts
sub_19C6:
	clr.w	d0
	clr.w	d1
	movea.l	#$1,a1
	bsr.w	sub_19E2
	bsr.w	sub_19E2
	bsr.w	sub_19E2
	bsr.w	sub_19E2
	rts
sub_19E2:
	clr.w	WATCHDOG
	move.w	#$3FFF,d2
.l19EC:
	move.b	(a0)+,d1
	add.w	d1,d0
	adda.l	a1,a0
	dbf	d2,.l19EC
	clr.w	WATCHDOG
	rts
sub_19FE:
	move.w	#$9F,d2
	jsr	sub_23F2
	move.w	(ram_FF8122-ABS_SHORT).w,d0
	move.w	#$A,d1
	jsr	sub_2418
	move.w	(ram_FF8098-ABS_SHORT).w,d1
	jsr	sub_2496
	move.w	(ram_FF8122-ABS_SHORT).w,d0
	move.w	#$1E,d1
	jsr	sub_2418
	move.w	(ram_FF809A-ABS_SHORT).w,d1
	jsr	sub_2496
	addq.w	#1,(ram_FF8122-ABS_SHORT).w
	rts
sub_1A3E:
	clr.w	d0
	move.w	io_E0000,d7
	move.w	io_E0010,d7
	move.w	io_E0000,d7
	movea.l	#$1,a1
	lea	io_E7FFF,a2
	move.w	io_E0010,d7
	bsr.w	sub_1A88
	move.w	io_E0034,d7
	bsr.w	sub_1A88
	move.w	io_E0058,d7
	bsr.w	sub_1A88
	move.w	io_E007C,d7
	bsr.w	sub_1A88
	rts
sub_1A88:
	clr.w	WATCHDOG
	clr.w	d1
	movea.l	a2,a0
	move.w	#$3FFF,d2
.l1A96:
	move.b	-(a0),d1
	add.w	d1,d0
	suba.l	a1,a0
	dbf	d2,.l1A96
	clr.w	WATCHDOG
	rts
sub_1AA8:
	clr.w	d0
	move.w	io_E0000,d7
	move.w	io_E0010,d7
	move.w	io_E0000,d7
	movea.l	#$1,a1
	lea	io_E8000,a2
	move.w	io_E0010,d7
	bsr.s	sub_1A88
	move.w	io_E0034,d7
	bsr.s	sub_1A88
	move.w	io_E0058,d7
	bsr.s	sub_1A88
	move.w	io_E007C,d7
	bsr.s	sub_1A88
	rts
dat_1AEA:
	incbin	"../../build/stunrun-68k.bin",$1AEA,$C
sub_1AF6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_1488
.l1B04:
	bsr.w	sub_1368
	bsr.w	sub_13EC
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l1B24
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
.l1B24:
	move.w	BUTTONS,d0
	andi.w	#$3,d0
	bne.s	.l1B04
	jsr	sub_632A
	bra.w	loc_1418
tbl_1B3A:
	dc.l	sub_1442
	dc.l	sub_1EB0
	dc.l	sub_1F16
	dc.l	sub_1F68
	dc.l	sub_B266
	dc.l	sub_B2E4
	dc.l	sub_B36A
	dc.l	sub_C118
sub_1B5A:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8024-ABS_SHORT).w
	bra.w	.l1BDA
.l1B78:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l1BA2
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$8,d0
	bne.w	.l1B9A
	clr.w	d0
.l1B9A:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l1BDA
.l1BA2:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l1BC4
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l1BBC
	move.w	#$7,d0
.l1BBC:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l1BDA
.l1BC4:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l1BD4
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l1BF0
.l1BD4:
	bsr.w	sub_13EC
	bra.s	.l1B78
.l1BDA:
	move.w	#$D9,d1
	move.w	#$8,d2
	bsr.w	sub_145E
	bsr.w	sub_1C08
	bsr.w	sub_13EC
	bra.s	.l1B78
.l1BF0:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_1B3A,a0
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.l1BDA
sub_1C08:
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addi.w	#$DA,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
sub_1C1C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jmp	loc_8C9E
sub_1C2C:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$11,d0
	jsr	sub_2326
	move.l	#$FA0,d0
.l1C46:
	subq.l	#1,d0
	bne.s	.l1C46
	jsr	sub_4DAE
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	lea	dat_458E,a0
	jsr	sub_A46
	move.w	#$4,d0
	jsr	sub_2326
	lea	dat_3978,a0
	jsr	sub_452A
	bra.w	loc_1418
sub_1C86:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$12,d0
	jsr	sub_2326
	move.l	#$FA0,d0
.l1CA0:
	subq.l	#1,d0
	bne.s	.l1CA0
	jsr	sub_4F82
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	lea	dat_458E,a0
	jsr	sub_A46
	move.w	#$3,d0
	jsr	sub_2326
	lea	dat_3978,a0
	jsr	sub_452A
	bra.w	loc_1418
sub_1CE6:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$13,d0
	jsr	sub_2326
	move.l	#$FA0,d0
.l1D00:
	subq.l	#1,d0
	bne.s	.l1D00
	jsr	sub_4A7C
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	lea	dat_458E,a0
	jsr	sub_A46
	move.w	#$5,d0
	jsr	sub_2326
	lea	dat_3978,a0
	jsr	sub_452A
	bra.w	loc_1418
sub_1D40:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	ADSP_CONTROL+$40
	move.w	#$2400,sr
	move.w	#$0,d0
	jsr	sub_2326
	move.w	#$1,d0
	jsr	sub_2326
	ori.w	#$1800,GSP_HOST+$8
	jsr	sub_756
.l1D76:
	bsr.w	sub_13EC
	move.w	#$640,d0
.l1D7E:
	clr.w	SOUND_RESET+$10
	move.l	#$2000000,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	dbf	d0,.l1D7E
	clr.w	SOUND_RESET
	bsr.w	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	.l1D76
	clr.w	(ram_FF8056-ABS_SHORT).w
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	rts
sub_1DC6:
	jsr	sub_C64
	jsr	sub_F26C
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	bsr.w	sub_1DEA
	bra.w	loc_1418
sub_1DEA:
	tst.l	ram_FF9482
	bne.w	.l1E0A
	tst.w	ram_FF9486
	bne.w	.l1E0A
	move.w	#$C4,d0
	jsr	sub_2326
	rts
.l1E0A:
	move.w	#$C5,d0
	jsr	sub_2326
	lea	dat_1E3A,a2
	lea	ram_FF9482,a3
	move.w	(a2)+,(ram_FF8120-ABS_SHORT).w
.l1E24:
	move.w	(a2)+,d0
	tst.b	(a3)+
	beq.w	.l1E32
	jsr	sub_2326
.l1E32:
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.l1E24
	rts
dat_1E3A:
	incbin	"../../build/stunrun-68k.bin",$1E3A,$E
sub_1E48:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	sub_FB2C
	bra.w	loc_1418
dat_1E5C:
	incbin	"../../build/stunrun-68k.bin",$1E5C,$54
sub_1EB0:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$2,d0
	jsr	sub_2326
	jsr	sub_31DC
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$14F,d0
	jsr	sub_2326
	lea	dat_4576,a0
	jsr	sub_A46
	lea	dat_4582,a0
	jsr	sub_A46
	move.w	#$2,d0
	jsr	sub_2326
	lea	dat_3ABA,a0
	jsr	sub_452A
	bra.w	loc_1418
sub_1F16:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$14E,d0
	jsr	sub_2326
	jsr	sub_E194
	jsr	boot_load_gsp_palette
	move.w	#$14F,d0
	jsr	sub_2326
	lea	dat_4576,a0
	jsr	sub_A46
	lea	dat_4582,a0
	jsr	sub_A46
	lea	dat_46E8,a0
	jsr	sub_452A
	bra.w	loc_1418
sub_1F68:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$14D,d0
	jsr	sub_2326
	jsr	sub_E2D8
	jsr	boot_load_gsp_palette
	move.w	#$14F,d0
	jsr	sub_2326
	lea	dat_4576,a0
	jsr	sub_A46
	lea	dat_4582,a0
	jsr	sub_A46
	lea	dat_47C2,a0
	jsr	sub_452A
	jmp	loc_1418
dat_1FBC:
	incbin	"../../build/stunrun-68k.bin",$1FBC,$330
sub_22EC:
	clr.l	d2
	move.b	d1,d2
	subi.b	#$2A,d2
	lsl.w	#4,d2
	lea	dat_1FBC,a1
	adda.w	d2,a1
	move.w	#$7,d3
.l2302:
	move.l	d0,GSP_HOST+$2
	move.w	(a1)+,GSP_HOST+$C
	addi.l	#$400,d0
	dbf	d3,.l2302
	subi.l	#$2000,d0
	addi.l	#$10,d0
	rts
sub_2326:
	clr.w	WATCHDOG
	andi.w	#$E7FF,GSP_HOST+$8
	lea	dat_10136,a0
	clr.l	d1
	move.w	d0,d1
	lsl.l	#2,d1
	adda.l	d1,a0
	movea.l	(a0),a0
	move.b	($2,a0),d0
	lsl.w	#8,d0
	move.b	($2,a0),d0
	move.l	#$F4000000,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	clr.l	d0
	move.b	($1,a0),d0
	mulu.w	#$2800,d0
	clr.l	d1
	move.b	($0,a0),d1
	lsl.l	#4,d1
	add.l	d1,d0
	addi.l	#$2000000,d0
	move.b	($3,a0),d4
	adda.l	#$4,a0
.l2382:
	move.b	(a0)+,d1
	bsr.w	sub_22EC
	subq.b	#1,d4
	bne.s	.l2382
	rts
sub_238E:
	clr.w	WATCHDOG
	andi.w	#$E7FF,GSP_HOST+$8
	lea	dat_10136,a0
	clr.l	d1
	move.w	d0,d1
	lsl.l	#2,d1
	adda.l	d1,a0
	movea.l	(a0),a0
	move.l	#$F4000000,GSP_HOST+$2
	move.b	d2,d3
	lsl.w	#8,d3
	move.b	d2,d3
	move.w	d3,GSP_HOST+$C
	clr.l	d0
	move.b	($1,a0),d0
	mulu.w	#$2800,d0
	clr.l	d1
	move.b	($0,a0),d1
	lsl.l	#4,d1
	add.l	d1,d0
	addi.l	#$2000000,d0
	move.b	($3,a0),d4
	adda.l	#$4,a0
.l23E6:
	move.b	(a0)+,d1
	bsr.w	sub_22EC
	subq.b	#1,d4
	bne.s	.l23E6
	rts
sub_23F2:
	move.l	#$F4000000,GSP_HOST+$2
	move.b	d2,d3
	lsl.w	#8,d3
	move.b	d2,d3
	move.w	d3,GSP_HOST+$C
	rts
sub_240A:
	andi.w	#$E7FF,GSP_HOST+$8
	bsr.w	sub_2444
	rts
sub_2418:
	andi.l	#$FF,d0
	mulu.w	#$2800,d0
	andi.l	#$FF,d1
	lsl.l	#4,d1
	add.l	d1,d0
	addi.l	#$2000000,d0
	rts
dat_2434:
	incbin	"../../build/stunrun-68k.bin",$2434,$10
sub_2444:
	move.w	d1,d2
	andi.w	#$F,d2
	lea	dat_2434,a0
	move.b	($0,a0,d2.w),d1
	bsr.w	sub_22EC
	rts
sub_245A:
	andi.w	#$E7FF,GSP_HOST+$8
	move.w	d1,d4
	lsr.w	#4,d1
	bsr.s	sub_2444
	move.w	d4,d1
	bsr.s	sub_2444
	rts
dat_246E:
	incbin	"../../build/stunrun-68k.bin",$246E,$28
sub_2496:
	andi.w	#$E7FF,GSP_HOST+$8
	move.w	d1,d4
	lsr.w	#8,d1
	lsr.w	#4,d1
	bsr.s	sub_2444
	move.w	d4,d1
	lsr.w	#8,d1
	bsr.s	sub_2444
	move.w	d4,d1
	lsr.w	#4,d1
	bsr.s	sub_2444
	move.w	d4,d1
	bsr.s	sub_2444
	rts
sub_24B8:
	andi.w	#$E7FF,GSP_HOST+$8
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.b	#$5C,d1
	bsr.w	sub_22EC
	move.b	#$5C,d1
	bsr.w	sub_22EC
	move.b	#$5C,d1
	bsr.w	sub_22EC
	move.b	#$5C,d1
	bsr.w	sub_22EC
	rts
dat_24F4:
	incbin	"../../build/stunrun-68k.bin",$24F4,$F4
loc_25E8:
	clr.w	WATCHDOG
	andi.w	#$E7FF,GSP_HOST+$8
	lea	dat_10136,a0
	andi.l	#$FFFF,d0
	lsl.l	#2,d0
	movea.l	($0,a0,d0.l),a0
	clr.w	d7
	move.b	($2,a0),d7
	move.w	d7,d6
	lsl.w	#8,d6
	clr.l	d0
	move.b	($1,a0),d0
	mulu.w	#$A0,d0
	lsl.l	#8,d0
	clr.l	d1
	move.b	($0,a0),d1
	lsl.l	#6,d1
	add.l	d1,d0
	addi.l	#$FF800000,d0
	move.b	($3,a0),d3
	adda.l	#$4,a0
.l2638:
	move.b	(a0)+,d1
	subi.b	#$2A,d1
	andi.l	#$FF,d1
	lsl.w	#4,d1
	lea	dat_1FBC,a1
	adda.w	d1,a1
	move.w	#$7,d2
.l2652:
	move.w	#$7,d1
	move.l	d0,GSP_HOST+$2
	move.w	(a1)+,d5
.l265E:
	btst	#$0,d5
	beq.w	.l266C
	move.w	d7,GSP_HOST+$C
.l266C:
	btst	#$2,d5
	beq.w	.l267A
	or.w	d6,GSP_HOST+$C
.l267A:
	addi.l	#$10,GSP_HOST+$2
	lsr.w	#4,d5
	dbf	d1,.l265E
	addi.l	#$1000,d0
	dbf	d2,.l2652
	subi.l	#$7FC0,d0
	subq.b	#1,d3
	bne.s	.l2638
	jmp	(a2)
dat_26A0:
	incbin	"../../build/stunrun-68k.bin",$26A0,$72
sub_2712:
	andi.w	#$E7FF,GSP_HOST+$8
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.b	#$5C,d1
	bsr.w	sub_22EC
	move.b	#$5C,d1
	bsr.w	sub_22EC
	rts
dat_273E:
	incbin	"../../build/stunrun-68k.bin",$273E,$54
	dcb.b	40,0
dat_27BA:
	incbin	"../../build/stunrun-68k.bin",$27BA,$4A
	dcb.b	39,0
dat_282B:
	incbin	"../../build/stunrun-68k.bin",$282B,$713
dat_2F3E:
	incbin	"../../build/stunrun-68k.bin",$2F3E,$C
dat_2F4A:
	incbin	"../../build/stunrun-68k.bin",$2F4A,$C
dat_2F56:
	incbin	"../../build/stunrun-68k.bin",$2F56,$C
dat_2F62:
	incbin	"../../build/stunrun-68k.bin",$2F62,$20
dat_2F82:
	incbin	"../../build/stunrun-68k.bin",$2F82,$18
dat_2F9A:
	incbin	"../../build/stunrun-68k.bin",$2F9A,$8
sub_2FA2:
	clr.w	SOUND_RESET+$12
	clr.w	WATCHDOG
	movem.l	d7,-(sp)
	move.l	a0,d6
	andi.l	#$3000,d6
	moveq	#$9,d7
	asr.l	d7,d6
	addi.l	#dat_2F62,d6
	movea.l	d6,a6
	move.l	d6,d7
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.w	.l2FEA
	clr.l	d4
	move.w	(a6),d4
	addi.l	#$FF9018,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l2FEA:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$F0,d4
	beq.w	.l3010
	clr.l	d4
	move.w	($2,a6),d4
	addi.l	#$FF9018,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l3010:
	move.l	d6,d4
	andi.l	#$F00,d4
	beq.w	.l3030
	clr.l	d4
	move.w	($4,a6),d4
	addi.l	#$FF9018,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l3030:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$F000,d4
	beq.w	.l3056
	clr.l	d4
	move.w	($6,a6),d4
	addi.l	#$FF9018,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l3056:
	movem.l	(sp)+,d7
	rts
sub_305C:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	clr.w	WATCHDOG
	move.l	a0,d6
	andi.l	#$4000,d6
	moveq	#$E,d7
	asr.l	d7,d6
	muls.w	#$C,d6
	addi.l	#dat_2F82,d6
	movea.l	d6,a6
	move.l	d6,d7
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.w	.l30A8
	clr.l	d4
	move.w	(a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l30A8:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$F0,d4
	beq.w	.l30CE
	clr.l	d4
	move.w	($2,a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l30CE:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$F00,d4
	beq.w	.l30F4
	clr.l	d4
	move.w	($4,a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l30F4:
	move.l	d6,d4
	andi.l	#$F000,d4
	beq.w	.l3114
	clr.l	d4
	move.w	($6,a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l3114:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$F0000,d4
	beq.w	.l313A
	clr.l	d4
	move.w	($8,a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l313A:
	move.l	d6,d4
	andi.l	#$F00000,d4
	beq.w	.l315A
	clr.l	d4
	move.w	($A,a6),d4
	addi.l	#$FF902C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l315A:
	clr.w	WATCHDOG
	movem.l	(sp)+,d7
	rts
sub_3166:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	clr.w	WATCHDOG
	move.l	ram_FF9040,d6
	asl.l	#1,d6
	addi.l	#dat_2F9A,d6
	movea.l	d6,a6
	move.l	d6,d7
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$FF,d4
	beq.w	.l31AA
	clr.l	d4
	move.w	(a6),d4
	addi.l	#$FF903C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l31AA:
	move.l	d6,d4
	clr.w	WATCHDOG
	andi.l	#$FF00,d4
	beq.w	.l31D0
	clr.l	d4
	move.w	($2,a6),d4
	addi.l	#$FF903C,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l31D0:
	clr.w	WATCHDOG
	movem.l	(sp)+,d7
	rts
sub_31DC:
	clr.w	WATCHDOG
	jsr	sub_3208
	clr.w	WATCHDOG
	jsr	sub_341A
	clr.w	WATCHDOG
	jsr	sub_369E
	clr.w	WATCHDOG
	rts
sub_3208:
	move.l	#$1,ADSP_CONTROL+$E
	move.l	#$1,ADSP_CONTROL+$C
	move.l	#$1,ADSP_CONTROL+$A
	moveq	#$4,d0
	lea	ram_FF9010,a5
	jmp	.l3238
.l3234:
	move.w	#$101,(a5)+
.l3238:
	dbf	d0,.l3234
	moveq	#$4,d0
	lea	ram_FF9018,a5
	clr.w	WATCHDOG
	jsr	sub_12DBC
	clr.w	WATCHDOG
	lea	dat_2F4A,a5
.l325C:
	clr.w	WATCHDOG
	move.l	(a5),d0
	beq.s	.l3270
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_3278
	bra.s	.l325C
.l3270:
	jsr	sub_4A48
	rts
sub_3278:
	clr.l	d6
	clr.l	d0
	clr.l	d4
	bsr.w	sub_32BE
	bsr.w	sub_32D2
	bsr.w	sub_32D6
	bsr.w	sub_3322
	bsr.w	sub_3326
	bsr.w	sub_3372
	bsr.w	sub_33C6
	moveq	#-$1,d0
	bsr.w	sub_32BE
	bsr.w	sub_3376
	bsr.w	sub_33CA
	moveq	#$4,d0
	lea	ram_FF9018,a2
	lea	ram_FF9010,a4
	jsr	sub_34D0
	rts
sub_32BE:
	lea	(-$2,a1),a0
.l32C2:
	addq.w	#2,a0
	move.w	d0,(a0)
	clr.w	WATCHDOG
	cmpa.l	a2,a0
	bcs.s	.l32C2
	rts
sub_32D2:
	clr.l	d5
	bra.s	loc_32D8
sub_32D6:
	moveq	#-$1,d5
loc_32D8:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l32E8:
	addq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l32EE:
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l32F8
	bsr.w	sub_2FA2
.l32F8:
	eor.w	d2,d0
	move.w	d0,(a0)
	lsr.w	#1,d2
	bcc.s	.l32EE
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l32E8
	addq.w	#2,a0
.l330C:
	move.w	-(a0),d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.l331C
	bsr.w	sub_2FA2
.l331C:
	cmpa.l	a1,a0
	bhi.s	.l330C
	rts
sub_3322:
	clr.l	d5
	bra.s	loc_3328
sub_3326:
	moveq	#-$1,d5
loc_3328:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($2,a2),a0
.l3336:
	subq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l333C:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l334C
	bsr.w	sub_2FA2
.l334C:
	eor.w	d2,d0
	move.w	d0,(a0)
	lsl.w	#1,d2
	bcc.s	.l333C
	cmpa.l	a1,a0
	bhi.s	.l3336
	bra.s	.l335C
.l335A:
	addq.w	#2,a0
.l335C:
	move.w	(a0),d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.l336C
	bsr.w	sub_2FA2
.l336C:
	cmpa.l	a2,a0
	bcs.s	.l335A
	rts
sub_3372:
	clr.l	d5
	bra.s	loc_3378
sub_3376:
	moveq	#-$1,d5
loc_3378:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l3388:
	addq.w	#2,a0
	move.w	d7,d2
.l338C:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l3398
	bsr.w	sub_2FA2
.l3398:
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsr.w	#1,d2
	bcc.s	.l338C
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l3388
	move.w	d5,d0
	addq.w	#2,a0
.l33B0:
	clr.w	WATCHDOG
	move.w	-(a0),d1
	cmp.w	d1,d0
	beq.s	.l33C0
	bsr.w	sub_2FA2
.l33C0:
	cmpa.l	a1,a0
	bhi.s	.l33B0
	rts
sub_33C6:
	clr.l	d5
	bra.s	loc_33CC
sub_33CA:
	moveq	#-$1,d5
loc_33CC:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($2,a2),a0
.l33DA:
	clr.w	WATCHDOG
	subq.w	#2,a0
	move.w	d7,d2
.l33E4:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l33F0
	bsr.w	sub_2FA2
.l33F0:
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsl.w	#1,d2
	bcc.s	.l33E4
	cmpa.l	a1,a0
	bhi.s	.l33DA
	move.w	d5,d0
	bra.s	.l3404
.l3402:
	addq.w	#2,a0
.l3404:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l3414
	bsr.w	sub_2FA2
.l3414:
	cmpa.l	a2,a0
	bcs.s	.l3402
	rts
sub_341A:
	move.l	#$1,ADSP_CONTROL+$E
	move.l	#$1,ADSP_CONTROL+$C
	move.l	#$1,ADSP_CONTROL+$A
	moveq	#$6,d0
	lea	ram_FF9020,a5
	jmp	.l344A
.l3446:
	move.w	#$101,(a5)+
.l344A:
	dbf	d0,.l3446
	moveq	#$6,d0
	lea	ram_FF902C,a5
	jsr	sub_12DBC
	clr.w	WATCHDOG
	lea	dat_2F3E,a5
.l3468:
	clr.w	WATCHDOG
	move.l	(a5),d0
	beq.s	.l347C
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_3484
	bra.s	.l3468
.l347C:
	jsr	sub_4A48
	rts
sub_3484:
	clr.l	d6
	clr.l	d0
	clr.l	d4
	clr.w	WATCHDOG
	bsr.w	sub_34DE
	bsr.w	sub_34F2
	bsr.w	sub_34F6
	bsr.w	sub_355C
	bsr.w	sub_3560
	bsr.w	sub_35C4
	bsr.w	sub_3632
	moveq	#-$1,d0
	bsr.w	sub_34DE
	bsr.w	sub_35C8
	bsr.w	sub_3636
	moveq	#$6,d0
	lea	ram_FF902C,a2
	lea	ram_FF9020,a4
	jsr	sub_34D0
	rts
sub_34D0:
	jmp	.l34D8
.l34D6:
	move.w	(a2)+,(a4)+
.l34D8:
	dbf	d0,.l34D6
	rts
sub_34DE:
	lea	(-$4,a1),a0
.l34E2:
	addq.l	#4,a0
	clr.w	WATCHDOG
	move.l	d0,(a0)
	cmpa.l	a2,a0
	bcs.s	.l34E2
	rts
sub_34F2:
	clr.l	d5
	bra.s	loc_34F8
sub_34F6:
	moveq	#-$1,d5
loc_34F8:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.l	#$800000,d7
	lea	(-$4,a1),a0
.l350A:
	addq.l	#4,a0
	move.l	d7,d2
	move.l	d5,d0
.l3510:
	move.l	(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l3526
	bsr.w	sub_305C
.l3526:
	eor.l	d2,d0
	move.l	d0,(a0)
	lsr.l	#1,d2
	bcc.s	.l3510
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l350A
	addq.l	#4,a0
.l353A:
	move.l	-(a0),d1
	clr.w	WATCHDOG
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l3556
	bsr.w	sub_305C
.l3556:
	cmpa.l	a1,a0
	bhi.s	.l353A
	rts
sub_355C:
	clr.l	d5
	bra.s	loc_3562
sub_3560:
	moveq	#-$1,d5
loc_3562:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($4,a2),a0
.l3570:
	subq.l	#4,a0
	move.l	d7,d2
	move.l	d5,d0
.l3576:
	clr.w	WATCHDOG
	move.l	(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l3592
	bsr.w	sub_305C
.l3592:
	eor.l	d2,d0
	move.l	d0,(a0)
	lsl.l	#1,d2
	bcc.s	.l3576
	cmpa.l	a1,a0
	bhi.s	.l3570
	bra.s	.l35A2
.l35A0:
	addq.l	#4,a0
.l35A2:
	move.l	(a0),d1
	clr.w	WATCHDOG
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l35BE
	bsr.w	sub_305C
.l35BE:
	cmpa.l	a2,a0
	bcs.s	.l35A0
	rts
sub_35C4:
	clr.l	d5
	bra.s	loc_35CA
sub_35C8:
	moveq	#-$1,d5
loc_35CA:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.l	#$800000,d7
	lea	(-$4,a1),a0
.l35DC:
	addq.l	#4,a0
	move.l	d7,d2
.l35E0:
	move.l	d5,d0
	move.l	(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l35F8
	bsr.w	sub_305C
.l35F8:
	eor.l	d2,d0
	move.l	d0,(a0)
	move.l	d5,(a0)
	lsr.l	#1,d2
	bcc.s	.l35E0
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l35DC
	move.l	d5,d0
	addq.l	#4,a0
.l3610:
	clr.w	WATCHDOG
	move.l	-(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l362C
	bsr.w	sub_305C
.l362C:
	cmpa.l	a1,a0
	bhi.s	.l3610
	rts
sub_3632:
	clr.l	d5
	bra.s	loc_3638
sub_3636:
	moveq	#-$1,d5
loc_3638:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($4,a2),a0
.l3646:
	clr.w	WATCHDOG
	subq.l	#4,a0
	move.l	d7,d2
.l3650:
	move.l	d5,d0
	move.l	(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l3668
	bsr.w	sub_305C
.l3668:
	eor.l	d2,d0
	move.l	d0,(a0)
	move.l	d5,(a0)
	lsl.l	#1,d2
	bcc.s	.l3650
	cmpa.l	a1,a0
	bhi.s	.l3646
	move.l	d5,d0
	bra.s	.l367C
.l367A:
	addq.l	#4,a0
.l367C:
	clr.w	WATCHDOG
	move.l	(a0),d1
	andi.l	#$FFFFFF,d1
	andi.l	#$FFFFFF,d0
	cmp.l	d1,d0
	beq.s	.l3698
	bsr.w	sub_305C
.l3698:
	cmpa.l	a2,a0
	bcs.s	.l367A
	rts
sub_369E:
	move.l	#$1,ADSP_CONTROL+$E
	move.l	#$1,ADSP_CONTROL+$C
	move.l	#$1,ADSP_CONTROL+$A
	move.l	#$1,ADSP_CONTROL+$6
	move.l	#$0,ram_FF9040
	moveq	#$2,d0
	lea	ram_FF9038,a5
	jmp	.l36E2
.l36DE:
	move.w	#$101,(a5)+
.l36E2:
	dbf	d0,.l36DE
	moveq	#$2,d0
	lea	ram_FF903C,a5
	jsr	sub_12DBC
	lea	dat_2F56,a5
	clr.w	WATCHDOG
	jsr	sub_376C
	clr.w	WATCHDOG
	move.l	#$1,ADSP_CONTROL+$E
	move.l	#$1,ADSP_CONTROL+$C
	move.l	#$1,ADSP_CONTROL+$A
	move.l	#$1,ADSP_CONTROL+$16
	move.l	#$2,ram_FF9040
	lea	dat_2F56,a5
	clr.w	WATCHDOG
	jsr	sub_376C
	clr.w	WATCHDOG
	moveq	#$2,d0
	lea	ram_FF903C,a2
	lea	ram_FF9038,a4
	jsr	sub_34D0
	rts
sub_376C:
	clr.w	WATCHDOG
	move.l	(a5),d0
	beq.s	.l3780
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_3788
	bra.s	sub_376C
.l3780:
	jsr	sub_4A48
	rts
sub_3788:
	clr.l	d6
	clr.w	WATCHDOG
	clr.l	d0
	clr.l	d4
	bsr.w	sub_32BE
	bsr.w	sub_37C0
	bsr.w	sub_37C4
	bsr.w	sub_3810
	bsr.w	sub_3814
	bsr.w	sub_3860
	bsr.w	sub_38B4
	moveq	#-$1,d0
	bsr.w	sub_32BE
	bsr.w	sub_3864
	bsr.w	sub_38B8
	rts
sub_37C0:
	clr.l	d5
	bra.s	loc_37C6
sub_37C4:
	moveq	#-$1,d5
loc_37C6:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l37D6:
	addq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l37DC:
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l37E6
	bsr.w	sub_3166
.l37E6:
	eor.w	d2,d0
	move.w	d0,(a0)
	lsr.w	#1,d2
	bcc.s	.l37DC
	clr.w	WATCHDOG
	cmpa.l	a2,a0
	bcs.s	.l37D6
	addq.w	#2,a0
.l37FA:
	move.w	-(a0),d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.l380A
	bsr.w	sub_3166
.l380A:
	cmpa.l	a1,a0
	bhi.s	.l37FA
	rts
sub_3810:
	clr.l	d5
	bra.s	loc_3816
sub_3814:
	moveq	#-$1,d5
loc_3816:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($2,a2),a0
.l3824:
	subq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l382A:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l383A
	bsr.w	sub_3166
.l383A:
	eor.w	d2,d0
	move.w	d0,(a0)
	lsl.w	#1,d2
	bcc.s	.l382A
	cmpa.l	a1,a0
	bhi.s	.l3824
	bra.s	.l384A
.l3848:
	addq.w	#2,a0
.l384A:
	move.w	(a0),d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.l385A
	bsr.w	sub_3166
.l385A:
	cmpa.l	a2,a0
	bcs.s	.l3848
	rts
sub_3860:
	clr.l	d5
	bra.s	loc_3866
sub_3864:
	moveq	#-$1,d5
loc_3866:
	addq.l	#1,d6
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l3876:
	addq.w	#2,a0
	move.w	d7,d2
.l387A:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l3886
	bsr.w	sub_3166
.l3886:
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsr.w	#1,d2
	bcc.s	.l387A
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l3876
	move.w	d5,d0
	addq.w	#2,a0
.l389E:
	clr.w	WATCHDOG
	move.w	-(a0),d1
	cmp.w	d1,d0
	beq.s	.l38AE
	bsr.w	sub_3166
.l38AE:
	cmpa.l	a1,a0
	bhi.s	.l389E
	rts
sub_38B4:
	clr.l	d5
	bra.s	loc_38BA
sub_38B8:
	moveq	#-$1,d5
loc_38BA:
	addq.l	#1,d6
	clr.w	WATCHDOG
	moveq	#$1,d7
	lea	($2,a2),a0
.l38C8:
	clr.w	WATCHDOG
	subq.w	#2,a0
	move.w	d7,d2
.l38D2:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l38DE
	bsr.w	sub_3166
.l38DE:
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsl.w	#1,d2
	bcc.s	.l38D2
	cmpa.l	a1,a0
	bhi.s	.l38C8
	move.w	d5,d0
	bra.s	.l38F2
.l38F0:
	addq.w	#2,a0
.l38F2:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l3902
	bsr.w	sub_3166
.l3902:
	cmpa.l	a2,a0
	bcs.s	.l38F0
	rts
loc_3908:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$1F,d0
	jsr	sub_2326
	move.w	#$20,d0
	jsr	sub_2326
	move.w	#$21,d0
	jsr	sub_2326
	clr.w	WATCHDOG
	jsr	sub_6508
	jsr	sub_9E26
	jsr	sub_9E80
	jmp	loc_1418
	assert	*=$00394E,"boot/code_000212.asm does not end at 00394E"
