; boot/code_00394E.asm, 00394E-0065E0: boot program code (pair R) with the data, text and tables
; that lie between its routines; the first routine is sub_394E. Cut at routine starts into files
; of about 16 KB named by their first address (decision C11).
; 00394E-0065E0: 30 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the boot naming legs (N1, N3-N5 for the boot program's tests and menus; docs/03).
;
; Generated once by tools/m68k gen 00394E 0065E0 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$00394E,"boot/code_00394E.asm misplaced"
sub_394E:
	move.w	#$F,d4
	move.l	#$40000004,d5
.l3958:
	move.l	d7,d6
	and.l	d5,d6
	beq.w	.l396C
	cmp.l	d5,d6
	beq.w	.l396C
	lsl.l	#1,d7
	bra.w	.l3972
.l396C:
	lsl.l	#1,d7
	ori.w	#$1,d7
.l3972:
	dbf	d4,.l3958
	rts
dat_3978:
	incbin	"../../build/stunrun-68k.bin",$3978,$142
dat_3ABA:
	incbin	"../../build/stunrun-68k.bin",$3ABA,$A70
sub_452A:
	ori.w	#$1800,GSP_HOST+$8
	clr.w	WATCHDOG
	move.w	(a0)+,d6
.l453A:
	movea.l	(a0),a1
	move.l	($4,a0),d0
	movea.l	($8,a0),a2
	move.w	($C,a0),d1
	adda.w	d1,a2
	move.w	($E,a0),d1
	tst.b	(a2)
	beq.w	.l4558
	move.w	($10,a0),d1
.l4558:
	move.l	#$F4000000,GSP_HOST+$2
	move.w	d1,GSP_HOST+$C
	jsr	(a1)
	adda.l	#$12,a0
	dbf	d6,.l453A
	rts
dat_4576:
	incbin	"../../build/stunrun-68k.bin",$4576,$C
dat_4582:
	incbin	"../../build/stunrun-68k.bin",$4582,$C
dat_458E:
	incbin	"../../build/stunrun-68k.bin",$458E,$2C
dat_45BA:
	incbin	"../../build/stunrun-68k.bin",$45BA,$C
dat_45C6:
	incbin	"../../build/stunrun-68k.bin",$45C6,$122
dat_46E8:
	incbin	"../../build/stunrun-68k.bin",$46E8,$DA
dat_47C2:
	incbin	"../../build/stunrun-68k.bin",$47C2,$92
dat_4854:
	incbin	"../../build/stunrun-68k.bin",$4854,$40
sub_4894:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	movea.l	ram_FF904A,a4
	cmpa.l	#$FF9436,a4
	blt.s	.l48BC
	move.l	#$FF904E,ram_FF904A
	movea.l	ram_FF904A,a4
.l48BC:
	move.l	a0,(a4)+
	move.w	d1,(a4)+
	move.w	d0,(a4)+
	move.l	a0,d6
	andi.l	#$70,d6
	asr.l	#1,d6
	addi.l	#dat_4854,d6
	movea.l	d6,a6
	move.l	d6,d7
	move.l	d0,d6
	eor.l	d1,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.w	.l48FC
	move.w	($6,a6),(a4)+
	move.w	($6,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l48FC:
	move.l	d6,d4
	andi.l	#$F0,d4
	beq.w	.l491E
	move.w	($4,a6),(a4)+
	move.w	($4,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l491E:
	move.l	d6,d4
	andi.l	#$F00,d4
	beq.w	.l4940
	move.w	($2,a6),(a4)+
	move.w	($2,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l4940:
	move.l	d6,d4
	andi.l	#$F000,d4
	beq.w	.l495E
	move.w	(a6),(a4)+
	move.w	(a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l495E:
	move.w	#$FFFF,(a4)+
	move.l	a4,ram_FF904A
	movem.l	(sp)+,d7
	rts
sub_496E:
	clr.w	SOUND_RESET+$12
	movem.l	d7,-(sp)
	movea.l	ram_FF904A,a4
	cmpa.l	#$FF9436,a4
	blt.s	.l4996
	move.l	#$FF904E,ram_FF904A
	movea.l	ram_FF904A,a4
.l4996:
	move.l	a0,(a4)+
	move.w	d0,(a4)+
	move.w	d2,(a4)+
	move.l	a0,d6
	andi.l	#$70,d6
	asr.l	#1,d6
	addi.l	#dat_4854,d6
	movea.l	d6,a6
	move.l	d6,d7
	move.l	d0,d6
	eor.l	d2,d6
	move.l	d6,d4
	andi.l	#$F,d4
	beq.w	.l49D6
	move.w	($6,a6),(a4)+
	move.w	($6,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l49D6:
	move.l	d6,d4
	andi.l	#$F0,d4
	beq.w	.l49F8
	move.w	($4,a6),(a4)+
	move.w	($4,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l49F8:
	move.l	d6,d4
	andi.l	#$F00,d4
	beq.w	.l4A1A
	move.w	($2,a6),(a4)+
	move.w	($2,a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l4A1A:
	move.l	d6,d4
	andi.l	#$F000,d4
	beq.w	.l4A38
	move.w	(a6),(a4)+
	move.w	(a6),d4
	addi.l	#$FF945E,d4
	movea.l	d4,a6
	move.b	#$1,(a6)
	movea.l	d7,a6
.l4A38:
	move.w	#$FFFF,(a4)+
	move.l	a4,ram_FF904A
	movem.l	(sp)+,d7
	rts
sub_4A48:
	clr.w	SOUND_RESET+$10
	clr.w	WATCHDOG
	move.l	#$FFFF,d0
.l4A5A:
	clr.w	WATCHDOG
	dbf	d0,.l4A5A
	clr.w	SOUND_RESET
	move.l	#$FFFF,d0
.l4A70:
	clr.w	WATCHDOG
	dbf	d0,.l4A70
	rts
sub_4A7C:
	clr.w	WATCHDOG
	jsr	boot_init_gsp
	clr.w	WATCHDOG
	move.l	#$FF904E,ram_FF904A
	moveq	#$10,d0
	lea	ram_FF945E,a5
	clr.w	WATCHDOG
	jsr	sub_12DBC
	clr.w	WATCHDOG
	lea	dat_12DC6,a5
.l4AB8:
	move.l	(a5),d0
	beq.s	.l4AC6
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	bsr.w	sub_4AD6
	bra.s	.l4AB8
.l4AC6:
	movea.l	ram_FF904A,a4
	move.w	#$FFFF,(a4)
	bsr.w	sub_4A48
	rts
sub_4AD6:
	clr.w	WATCHDOG
	move.l	a2,d4
	sub.l	a1,d4
	lsr.l	#4,d4
	addi.l	#$1,d4
	move.l	d4,ram_FF947E
	movea.l	#$0,a3
	clr.l	d0
	clr.l	d1
	bsr.w	sub_4B3A
	clr.w	WATCHDOG
	bsr.w	sub_4B92
	bsr.w	sub_4B96
	bsr.w	sub_4C14
	bsr.w	sub_4C18
	bsr.w	sub_4C8E
	bsr.w	sub_4D24
	moveq	#-$1,d0
	bsr.w	sub_4B3A
	clr.w	WATCHDOG
	bsr.w	sub_4C92
	bsr.w	sub_4D28
	bsr.w	sub_4A48
	rts
dat_4B34:
	incbin	"../../build/stunrun-68k.bin",$4B34,$6
sub_4B3A:
	move.l	ram_FF947E,d2
	andi.l	#$1,d2
	ori.w	#$1800,GSP_HOST+$8
	movea.l	#GSP_HOST+$C,a0
	move.l	a1,GSP_HOST+$2
	bra.s	.l4B5E
.l4B5C:
	move.w	d0,(a0)
.l4B5E:
	dbf	d2,.l4B5C
	move.l	ram_FF947E,d2
	lsr.l	#1,d2
	move.l	d2,d1
	clr.w	d1
	swap	d1
	bra.s	loc_4B74
dat_4B72:
	incbin	"../../build/stunrun-68k.bin",$4B72,$2
loc_4B74:
	dbf	d2,str_80D8
	clr.w	WATCHDOG
	bra.s	.l4B8C
.l4B80:
	move.l	d0,(a0)
	dbf	d2,.l4B80
	clr.w	WATCHDOG
.l4B8C:
	dbf	d1,.l4B80
	rts
sub_4B92:
	clr.l	d5
	bra.s	loc_4B98
sub_4B96:
	moveq	#-$1,d5
loc_4B98:
	addq.l	#1,a3
	move.w	#$8000,d7
	clr.l	d4
	lea	(-$10,a1),a0
.l4BA4:
	adda.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
.l4BAE:
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4BC4
	bsr.w	sub_4894
.l4BC4:
	eor.w	d2,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.l4BAE
	clr.w	WATCHDOG
	cmpa.l	a2,a0
	bcs.s	.l4BA4
	adda.l	#$10,a0
.l4BE8:
	suba.l	#$10,a0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	beq.s	.l4C0A
	bsr.w	sub_4894
.l4C0A:
	cmpa.l	a1,a0
	bhi.s	.l4BE8
	bsr.w	sub_4A48
	rts
sub_4C14:
	clr.l	d5
	bra.s	loc_4C1A
sub_4C18:
	moveq	#-$1,d5
loc_4C1A:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.l4C22:
	suba.l	#$10,a0
	move.w	d7,d2
	move.w	d5,d0
	clr.w	WATCHDOG
.l4C32:
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4C48
	bsr.w	sub_4894
.l4C48:
	eor.w	d2,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	lsl.w	#1,d2
	bcc.s	.l4C32
	cmpa.l	a1,a0
	bhi.s	.l4C22
	bra.s	.l4C68
.l4C62:
	adda.l	#$10,a0
.l4C68:
	clr.w	WATCHDOG
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4C84
	bsr.w	sub_4894
.l4C84:
	cmpa.l	a2,a0
	bcs.s	.l4C62
	bsr.w	sub_4A48
	rts
sub_4C8E:
	clr.l	d5
	bra.s	loc_4C94
sub_4C92:
	moveq	#-$1,d5
loc_4C94:
	addq.l	#1,a3
	clr.w	WATCHDOG
	move.w	#$8000,d7
	lea	(-$10,a1),a0
.l4CA4:
	adda.l	#$10,a0
	move.w	d7,d2
.l4CAC:
	move.w	d5,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4CC4
	bsr.w	sub_4894
.l4CC4:
	eor.w	d2,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d5,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.l4CAC
	cmpa.l	a2,a0
	clr.w	WATCHDOG
	bcs.s	.l4CA4
	move.w	d5,d0
	adda.l	#$10,a0
.l4CF8:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4D1A
	bsr.w	sub_4894
.l4D1A:
	cmpa.l	a1,a0
	bhi.s	.l4CF8
	bsr.w	sub_4A48
	rts
sub_4D24:
	clr.l	d5
	bra.s	loc_4D2A
sub_4D28:
	moveq	#-$1,d5
loc_4D2A:
	addq.l	#1,a3
	moveq	#$1,d7
	lea	($10,a2),a0
.l4D32:
	clr.w	WATCHDOG
	suba.l	#$10,a0
	move.w	d7,d2
.l4D40:
	move.w	d5,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4D58
	bsr.w	sub_4894
.l4D58:
	eor.w	d2,d0
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	d5,GSP_HOST+$C
	lsl.w	#1,d2
	bcc.s	.l4D40
	cmpa.l	a1,a0
	bhi.s	.l4D32
	move.w	d5,d0
	bra.s	.l4D88
.l4D82:
	adda.l	#$10,a0
.l4D88:
	clr.w	WATCHDOG
	move.l	a0,d6
	move.l	d6,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4DA4
	bsr.w	sub_4894
.l4DA4:
	cmpa.l	a2,a0
	bcs.s	.l4D82
	bsr.w	sub_4A48
	rts
sub_4DAE:
	clr.w	WATCHDOG
	jsr	boot_init_gsp
	move.l	#$FF904E,ram_FF904A
	moveq	#$10,d0
	lea	ram_FF945E,a5
	jsr	sub_12DBC
	clr.w	WATCHDOG
	lea	dat_12DC6,a5
.l4DDE:
	move.l	(a5),d0
	beq.s	.l4E10
	movea.l	(a5)+,a1
	movea.l	(a5)+,a2
	clr.w	WATCHDOG
	move.l	a2,d4
	sub.l	a1,d4
	lsr.l	#4,d4
	addi.l	#$1,d4
	move.l	d4,ram_FF947E
	clr.w	WATCHDOG
	clr.l	d0
	bsr.w	sub_4B3A
	bsr.w	sub_4E26
	bra.s	.l4DDE
.l4E10:
	clr.w	WATCHDOG
	movea.l	ram_FF904A,a4
	move.w	#$FFFF,(a4)
	bsr.w	sub_4A48
	rts
sub_4E26:
	clr.l	d5
	move.w	#$8000,d7
	clr.l	d4
	move.w	d7,d2
	move.w	d5,d0
.l4E32:
	move.l	a1,GSP_HOST+$2
	move.w	GSP_HOST+$C,d1
	cmp.w	d1,d0
	beq.s	.l4E46
	bsr.w	sub_4894
.l4E46:
	eor.w	d2,d0
	move.l	a1,GSP_HOST+$2
	move.w	d0,GSP_HOST+$C
	lsr.w	#1,d2
	bcc.s	.l4E32
	clr.w	WATCHDOG
	move.w	#$FFFF,d1
	clr.l	d2
	movea.l	a2,a3
	suba.l	#$10,a3
	movea.l	a1,a0
.l4E6E:
	adda.l	#$10,a0
	clr.w	WATCHDOG
	move.l	a0,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	adda.l	#$10,a0
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d2
	beq.s	.l4EA2
	bsr.w	sub_496E
.l4EA2:
	suba.l	#$20,a0
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d1
	beq.s	.l4EBC
	bsr.w	sub_4894
.l4EBC:
	adda.l	#$10,a0
	cmpa.l	a0,a3
	bhi.s	.l4E6E
	move.l	a2,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d1
	beq.s	.l4EE8
	bsr.w	sub_4894
.l4EE8:
	movea.l	a2,a0
	move.l	a0,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	movea.l	a1,a3
	adda.l	#$10,a3
.l4F00:
	suba.l	#$10,a0
	clr.w	WATCHDOG
	move.l	a0,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	adda.l	#$10,a0
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d2
	beq.s	.l4F34
	bsr.w	sub_496E
.l4F34:
	suba.l	#$20,a0
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d1
	beq.s	.l4F4E
	bsr.w	sub_4894
.l4F4E:
	adda.l	#$10,a0
	clr.w	WATCHDOG
	cmpa.l	a3,a0
	bhi.s	.l4F00
	move.l	a1,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	a0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmp.w	d0,d2
	beq.s	.l4F80
	bsr.w	sub_496E
.l4F80:
	rts
sub_4F82:
	clr.w	WATCHDOG
	jsr	boot_init_gsp
	clr.w	WATCHDOG
	moveq	#$8,d1
	movea.l	#ram_FF945E,a1
.l4F9C:
	move.l	#$1010101,(a1)+
	subq.l	#1,d1
	bgt.s	.l4F9C
	jsr	sub_10932
	jsr	sub_4A48
	movea.l	#$1,a1
.l4FB8:
	move.w	#$1D4C,d0
	clr.w	WATCHDOG
	movea.w	a1,a0
	cmpa.w	#$8,a0
	beq.w	.l5016
	move.l	#$0,ram_FF9042
.l4FD6:
	move.l	ram_FF9042,d1
	clr.w	WATCHDOG
	cmp.w	d1,d0
	bgt.s	.l4FD6
	move.l	#$FFC00000,GSP_HOST+$2
	movea.w	GSP_HOST+$C,a1
	cmpa.w	a0,a1
	bgt.s	.l4FB8
	move.b	#$FF,ram_FF945E
	clr.w	WATCHDOG
	jsr	boot_init_gsp
	clr.w	WATCHDOG
	rts
.l5016:
	jsr	sub_4A48
	clr.w	WATCHDOG
	movea.l	#$FFC00020,a2
	moveq	#$10,d1
	movea.l	#ram_FF945E,a1
.l5030:
	movea.l	#ram_FF9048,a0
	clr.w	WATCHDOG
	move.l	a2,GSP_HOST+$2
	adda.l	#$10,a2
	move.w	GSP_HOST+$C,(a0)
	move.b	(a0)+,d0
	move.b	(a0),(a1)+
	move.b	d0,(a1)+
	subq.l	#1,d1
	bgt.s	.l5030
	clr.w	WATCHDOG
	jsr	boot_init_gsp
	clr.w	WATCHDOG
	rts
loc_506C:
	movea.l	#$FFFFC000,sp
	lea	(sub_507A,pc),a0
	bra.w	loc_53F2
sub_507A:
	lea	(sub_5082,pc),a0
	bra.w	loc_548E
sub_5082:
	lea	(sub_508A,pc),a0
	bra.w	loc_54C2
sub_508A:
	move.w	#$47,d0
	lea	(sub_5098,pc),a2
	jmp	loc_25E8
sub_5098:
	lea	(sub_50A0,pc),a6
	bra.w	loc_6086
sub_50A0:
	move.w	#$54,d0
	lea	(sub_50AC,pc),a0
	bra.w	loc_566A
sub_50AC:
	bra.w	sub_56E6
loc_50B0:
	movea.l	#$FFFFC000,sp
	jsr	boot_load_gsp_palette
	bsr.w	sub_552C
	move.w	#$2400,sr
	move.w	#$E,d0
	jsr	sub_65E0
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	btst	#$5,PORT0+$1
	beq.s	.l50E8
	jmp	loc_260
.l50E8:
	btst	#$2,BUTTONS+$1
	bne.s	.l50F8
	jmp	loc_F94
.l50F8:
	jsr	sub_4DAE
	btst	#$5,PORT0+$1
	beq.s	.l510E
	jmp	loc_260
.l510E:
	btst	#$2,BUTTONS+$1
	bne.s	.l511E
	jmp	loc_F94
.l511E:
	jsr	sub_FBDC
	btst	#$5,PORT0+$1
	beq.s	.l5134
	jmp	loc_260
.l5134:
	btst	#$2,BUTTONS+$1
	bne.s	.l5144
	jmp	loc_F94
.l5144:
	jsr	boot_load_gsp_palette
	move.w	(ram_FF8090-ABS_SHORT).w,d0
	cmpi.w	#$5555,d0
	bne.w	.l5164
	move.w	#$53,d0
	jsr	sub_2326
	bra.w	.l516E
.l5164:
	move.w	#$54,d0
	jsr	sub_2326
.l516E:
	move.w	(ram_FF8092-ABS_SHORT).w,d0
	cmpi.w	#$5555,d0
	bne.w	.l5188
	move.w	#$55,d0
	jsr	sub_2326
	bra.w	.l5192
.l5188:
	move.w	#$56,d0
	jsr	sub_2326
.l5192:
	move.w	#$F,d0
	lea	ram_FF945E,a0
.l519C:
	tst.w	(a0)+
	dbne	d0,.l519C
	cmpi.w	#$FFFF,d0
	bne.w	.l51B8
	move.w	#$57,d0
	jsr	sub_2326
	bra.w	.l51C2
.l51B8:
	move.w	#$58,d0
	jsr	sub_2326
.l51C2:
	move.w	#$66,d0
	jsr	sub_2326
	jsr	sub_F26C
	jsr	boot_load_gsp_palette
	move.w	#$4,d0
	jsr	sub_65E0
	tst.l	ram_FF9482
	bne.w	.l51FE
	tst.w	ram_FF9486
	bne.w	.l51FE
	move.w	#$64,d0
	bra.w	.l5202
.l51FE:
	move.w	#$65,d0
.l5202:
	jsr	sub_2326
	bsr.w	sub_56A8
	tst.w	d2
	beq.w	loc_5224
	move.w	#$5D,d0
	lea	(sub_5220,pc),a2
	jmp	loc_25E8
sub_5220:
	bra.w	loc_533C
loc_5224:
	jsr	sub_B864
	cmpi.w	#$5555,d7
	bne.w	loc_530A
	jsr	sub_B8B4
	cmpi.w	#$5555,d7
	bne.w	loc_530A
	jsr	sub_B916
	cmpi.w	#$5555,d7
	bne.w	loc_530A
	cmpi.b	#$17,d4
	bne.w	loc_531C
	cmpi.b	#$18,d0
	bne.w	loc_531C
	cmpi.b	#$19,d2
	bne.w	loc_531C
	cmpi.b	#$20,d5
	bne.w	loc_531C
	cmpi.b	#$21,d1
	bne.w	loc_531C
	cmpi.b	#$22,d3
	bne.w	loc_531C
	move.w	#$5E,d0
	lea	(sub_528C,pc),a2
	jmp	loc_25E8
sub_528C:
	btst	#$5,PORT0+$1
	beq.s	.l529C
	jmp	loc_260
.l529C:
	btst	#$2,BUTTONS+$1
	bne.s	.l52AC
	jmp	loc_F94
.l52AC:
	jsr	sub_31DC
	move.w	#$5,d0
	jsr	sub_65E0
	tst.l	ram_FF9010
	bne.w	loc_532E
	tst.l	ram_FF9014
	bne.w	loc_532E
	tst.l	ram_FF9020
	bne.w	loc_532E
	tst.l	ram_FF9024
	bne.w	loc_532E
	tst.l	ram_FF9028
	bne.w	loc_532E
	tst.l	ram_FF9038
	bne.w	loc_532E
	move.w	#$5F,d0
	lea	(sub_5306,pc),a2
	jmp	loc_25E8
sub_5306:
	bra.w	loc_533C
loc_530A:
	move.w	#$61,d0
	lea	(sub_5318,pc),a2
	jmp	loc_25E8
sub_5318:
	bra.w	loc_533C
loc_531C:
	move.w	#$62,d0
	lea	(sub_532A,pc),a2
	jmp	loc_25E8
sub_532A:
	bra.w	loc_533C
loc_532E:
	move.w	#$60,d0
	lea	(loc_533C,pc),a2
	jmp	loc_25E8
loc_533C:
	jsr	boot_sa_ii_test
	move.w	#$63,d0
	jsr	sub_2326
.l534C:
	btst	#$5,PORT0+$1
	beq.s	.l535C
	jmp	loc_260
.l535C:
	clr.w	WATCHDOG
	movea.l	dat_135E,a0
	move.w	dat_1362,d0
	and.w	(a0),d0
	bne.s	.l534C
	lea	(sub_537A,pc),a0
	bra.w	loc_548E
sub_537A:
	move.w	#$49,d0
	jsr	sub_2326
	move.w	#$4A,d0
	jsr	sub_2326
	move.w	#$4B,d0
	jsr	sub_2326
	move.w	#$4C,d0
	jsr	sub_2326
	move.w	#$4D,d0
	jsr	sub_2326
	move.w	#$4E,d0
	jsr	sub_2326
	move.w	#$4F,d0
	jsr	sub_2326
.l53C0:
	btst	#$5,PORT0+$1
	beq.s	.l53D0
	jmp	loc_260
.l53D0:
	clr.w	WATCHDOG
	movea.l	dat_135E,a0
	move.w	dat_1362,d0
	and.w	(a0),d0
	bne.s	.l53C0
	movea.l	#$FFFFC000,sp
	jmp	loc_FB2
loc_53F2:
	clr.w	SOUND_RESET+$C
	move.l	#$96,d0
.l53FE:
	subq.w	#1,d0
	bne.s	.l53FE
	clr.w	SOUND_RESET+$1C
	move.w	#$B800,GSP_HOST+$8
	lea	dat_2B8,a1
	move.w	#$7,d0
.l541A:
	move.l	(a1),GSP_HOST+$2
	move.w	($4,a1),GSP_HOST+$C
	adda.l	#$6,a1
	dbf	d0,.l541A
	move.l	#$C0000090,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	move.l	#$C00000B0,GSP_HOST+$2
	move.w	#$8,GSP_HOST+$C
	move.l	#$C0000080,GSP_HOST+$2
	move.w	#$F010,GSP_HOST+$C
	move.l	#$F4800010,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	#$F4800090,GSP_HOST+$2
	move.w	#$FFFF,GSP_HOST+$C
	jmp	(a0)
loc_548E:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF800000,GSP_HOST+$2
	move.w	#$0,d0
	move.w	#$383,d2
.l54A8:
	move.w	#$FF,d1
.l54AC:
	move.w	d0,GSP_HOST+$C
	dbf	d1,.l54AC
	clr.w	WATCHDOG
	dbf	d2,.l54A8
	jmp	(a0)
loc_54C2:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4800020,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	move.l	#$F4800030,GSP_HOST+$2
	clr.w	GSP_HOST+$C
	clr.w	d0
	move.l	#$F5000000,GSP_HOST+$2
	move.w	#$FF,d1
.l54FA:
	move.w	d0,GSP_HOST+$C
	addi.w	#$101,d0
	dbf	d1,.l54FA
	clr.w	d0
	move.l	#$F5800000,GSP_HOST+$2
	move.w	#$FF,d1
.l5518:
	move.w	d0,GSP_HOST+$C
	addq.w	#1,d0
	dbf	d1,.l5518
	clr.w	WATCHDOG
	jmp	(a0)
sub_552C:
	move.l	#$C7,d0
.l5532:
	jsr	sub_13EC
	dbf	d0,.l5532
	rts
loc_553E:
	ori.w	#$1800,GSP_HOST+$8
	clr.w	d2
	move.w	a5,d5
loc_554A:
	btst	#$5,PORT0+$1
	beq.s	.l555A
	jmp	loc_260
.l555A:
	btst	#$2,BUTTONS+$1
	bne.s	.l556A
	jmp	loc_F94
.l556A:
	lea	dat_5FF6,a1
	move.w	d2,d4
	muls.w	#$12,d4
	tst.w	($0,a1,d4.w)
	beq.w	loc_55C6
	move.l	($A,a1,d4.w),d0
	move.b	($4,a1,d4.w),d6
	btst	d6,d5
	beq.w	loc_559A
	lea	(sub_5594,pc),a2
	bra.w	loc_55D2
sub_5594:
	jmp	sub_55A2
loc_559A:
	lea	(sub_55A2,pc),a2
	bra.w	loc_5644
sub_55A2:
	move.l	($E,a1,d4.w),d0
	move.b	($5,a1,d4.w),d6
	btst	d6,d5
	beq.w	loc_55BE
	lea	(sub_55B8,pc),a2
	bra.w	loc_55D2
sub_55B8:
	jmp	loc_55C6
loc_55BE:
	lea	(loc_55C6,pc),a2
	bra.w	loc_5644
loc_55C6:
	addq.w	#1,d2
	cmpi.w	#$8,d2
	bne.w	loc_554A
	jmp	(a0)
loc_55D2:
	move.l	d0,GSP_HOST+$2
	move.w	#$3,d7
.l55DC:
	move.w	#$FFFF,GSP_HOST+$C
	dbf	d7,.l55DC
	addi.l	#$1000,d0
	move.w	#$6,d7
.l55F2:
	move.l	d0,GSP_HOST+$2
	move.w	#$FF,GSP_HOST+$C
	addi.l	#$1000,d0
	dbf	d7,.l55F2
	move.w	#$3,d7
	move.l	d0,GSP_HOST+$2
.l5614:
	move.w	#$FFFF,GSP_HOST+$C
	dbf	d7,.l5614
	subi.l	#$6FD0,d0
	move.w	#$6,d7
.l562A:
	move.l	d0,GSP_HOST+$2
	move.w	#$FF00,GSP_HOST+$C
	addi.l	#$1000,d0
	dbf	d7,.l562A
	jmp	(a2)
loc_5644:
	move.w	#$7,d1
.l5648:
	move.l	d0,GSP_HOST+$2
	move.w	#$3,d7
.l5652:
	move.w	#$FFFF,GSP_HOST+$C
	dbf	d7,.l5652
	addi.l	#$1000,d0
	dbf	d1,.l5648
	jmp	(a2)
loc_566A:
	ori.w	#$1800,GSP_HOST+$8
	clr.l	d1
	move.w	d0,d1
	lsl.l	#8,d1
	lsl.l	#4,d1
	addi.l	#$FF800000,d1
	move.w	#$FF,d2
	move.l	d1,GSP_HOST+$2
	move.w	#$FFFF,d3
.l568E:
	move.w	d3,GSP_HOST+$C
	dbf	d2,.l568E
	jmp	(a0)
dat_569A:
	incbin	"../../build/stunrun-68k.bin",$569A,$E
sub_56A8:
	clr.w	ADSP_CONTROL+$E
	lea	dat_569A,a0
	move.w	(a0)+,d3
	move.w	#$5555,d0
	move.w	#$AAAA,d1
	move.w	#$FFFF,d2
.l56C2:
	movea.l	(a0)+,a1
	movea.l	a1,a2
	adda.l	#$4,a2
	move.w	d0,(a1)
	move.w	d1,(a2)
	cmp.w	(a1),d0
	bne.w	.l56DC
	cmp.w	(a2),d1
	beq.w	.l56E2
.l56DC:
	dbf	d3,.l56C2
	rts
.l56E2:
	clr.w	d2
	rts
sub_56E6:
	lea	$FFFF8000,a1
	lea	(ram_FFFFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF86A600,GSP_HOST+$2
	movea.w	a4,a5
	lea	(sub_570C,pc),a4
	bra.w	loc_5B6E
sub_570C:
	tst.w	d4
	bne.w	loc_5756
	move.w	#$3B,d0
	lea	(sub_5720,pc),a2
	jmp	loc_25E8
sub_5720:
	move.w	#$A4,d0
	lea	(sub_572C,pc),a0
	bra.w	loc_566A
sub_572C:
	move.w	a5,d0
	beq.w	.l5744
	move.w	#$0,(ram_FF8090-ABS_SHORT).w
	move.w	#$5555,(ram_FF8092-ABS_SHORT).w
	jmp	loc_50B0
.l5744:
	move.w	#$5555,(ram_FF8090-ABS_SHORT).w
	move.w	#$5555,(ram_FF8092-ABS_SHORT).w
	jmp	loc_50B0
loc_5756:
	move.w	#$3C,d0
	lea	(sub_5764,pc),a2
	jmp	loc_25E8
sub_5764:
	lea	$FFFF8000,a1
	lea	(ram_FFBFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF8C0C00,GSP_HOST+$2
	lea	(sub_5788,pc),a4
	bra.w	loc_5B6E
sub_5788:
	tst.w	d4
	beq.w	.l57BA
	eor.w	d0,d1
	tst.b	d1
	beq.w	.l57A4
	move.w	#$3D,d0
	lea	(.l57A4,pc),a2
	jmp	loc_25E8
.l57A4:
	andi.w	#$FF00,d1
	beq.w	.l57BA
	move.w	#$3E,d0
	lea	(.l57BA,pc),a2
	jmp	loc_25E8
.l57BA:
	lea	(ram_FFC000-ABS_SHORT).w,a1
	lea	(ram_FFFFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF8DCC00,GSP_HOST+$2
	lea	(sub_57DC,pc),a4
	bra.w	loc_5B6E
sub_57DC:
	tst.w	d4
	beq.w	.l580E
	eor.w	d0,d1
	tst.b	d1
	beq.w	.l57F8
	move.w	#$3F,d0
	lea	(.l57F8,pc),a2
	jmp	loc_25E8
.l57F8:
	andi.w	#$FF00,d1
	beq.w	.l580E
	move.w	#$40,d0
	lea	(.l580E,pc),a2
	jmp	loc_25E8
.l580E:
	move.w	#$41,d0
	lea	(sub_581C,pc),a2
	jmp	loc_25E8
sub_581C:
	move.w	#$42,d0
	lea	(sub_582A,pc),a2
	jmp	loc_25E8
sub_582A:
	move.w	#$67,d0
	lea	(sub_5838,pc),a2
	jmp	loc_25E8
sub_5838:
	move.w	#$48,d0
	lea	(sub_5846,pc),a2
	jmp	loc_25E8
sub_5846:
	move.w	#$AC,d0
	lea	(sub_5852,pc),a0
	bra.w	loc_566A
sub_5852:
	clr.w	(ram_FF8092-ABS_SHORT).w
	clr.w	(ram_FF8090-ABS_SHORT).w
	move.w	a5,d0
	bne.w	.l5866
	move.w	#$5555,(ram_FF8090-ABS_SHORT).w
.l5866:
	clr.w	WATCHDOG
	movea.l	dat_135E,a0
	move.w	dat_1362,d0
	and.w	(a0),d0
	bne.s	.l5866
	jmp	loc_50B0
dat_5882:
	incbin	"../../build/stunrun-68k.bin",$5882,$14
loc_5896:
	clr.l	d6
	clr.l	d0
	clr.l	d4
	lea	(sub_58A4,pc),a6
	bra.w	loc_59D8
sub_58A4:
	lea	(sub_58AC,pc),a6
	bra.w	loc_5DF0
sub_58AC:
	lea	(sub_58B4,pc),a6
	bra.w	loc_5E48
sub_58B4:
	lea	(sub_58BC,pc),a6
	bra.w	loc_59E6
sub_58BC:
	lea	(sub_58C4,pc),a6
	bra.w	loc_5E64
sub_58C4:
	lea	(sub_58CC,pc),a6
	bra.w	loc_5DFE
sub_58CC:
	lea	(sub_58D4,pc),a6
	bra.w	loc_5E48
sub_58D4:
	lea	(sub_58DC,pc),a6
	bra.w	loc_59EA
sub_58DC:
	lea	(sub_58E4,pc),a6
	bra.w	loc_5E64
sub_58E4:
	lea	(sub_58EC,pc),a6
	bra.w	loc_5DF0
sub_58EC:
	lea	(sub_58F4,pc),a6
	bra.w	loc_5E48
sub_58F4:
	lea	(sub_58FC,pc),a6
	bra.w	loc_5A32
sub_58FC:
	lea	(sub_5904,pc),a6
	bra.w	loc_5E64
sub_5904:
	lea	(sub_590C,pc),a6
	bra.w	loc_5DFE
sub_590C:
	lea	(sub_5914,pc),a6
	bra.w	loc_5E48
sub_5914:
	lea	(sub_591C,pc),a6
	bra.w	loc_5A36
sub_591C:
	lea	(sub_5924,pc),a6
	bra.w	loc_5E64
sub_5924:
	lea	(sub_592C,pc),a6
	bra.w	loc_5DF0
sub_592C:
	lea	(sub_5934,pc),a6
	bra.w	loc_5E48
sub_5934:
	lea	(sub_593C,pc),a6
	bra.w	loc_5A7E
sub_593C:
	lea	(sub_5944,pc),a6
	bra.w	loc_5E64
sub_5944:
	lea	(sub_594C,pc),a6
	bra.w	loc_5DFE
sub_594C:
	lea	(sub_5954,pc),a6
	bra.w	loc_5E48
sub_5954:
	lea	(sub_595C,pc),a6
	bra.w	loc_5AD4
sub_595C:
	lea	(sub_5964,pc),a6
	bra.w	loc_5E64
sub_5964:
	moveq	#-$1,d0
	lea	(sub_596E,pc),a6
	bra.w	loc_59D8
sub_596E:
	lea	(sub_5976,pc),a6
	bra.w	loc_5DF0
sub_5976:
	lea	(sub_597E,pc),a6
	bra.w	loc_5E48
sub_597E:
	lea	(sub_5986,pc),a6
	bra.w	loc_5A82
sub_5986:
	lea	(sub_598E,pc),a6
	bra.w	loc_5E64
sub_598E:
	lea	(sub_5996,pc),a6
	bra.w	loc_5DFE
sub_5996:
	lea	(sub_599E,pc),a6
	bra.w	loc_5E48
sub_599E:
	lea	(sub_59A6,pc),a6
	bra.w	loc_5AD8
sub_59A6:
	lea	(sub_59AE,pc),a6
	bra.w	loc_5E64
sub_59AE:
	lea	(sub_59B6,pc),a6
	bra.w	loc_5DF0
sub_59B6:
	lea	(sub_59BE,pc),a6
	bra.w	loc_5E48
sub_59BE:
	lea	(sub_59C6,pc),a6
	bra.w	loc_5B2A
sub_59C6:
	lea	(sub_59CE,pc),a6
	bra.w	loc_5E64
sub_59CE:
	lea	(sub_59D6,pc),a6
	bra.w	loc_5E0C
sub_59D6:
	jmp	(a4)
loc_59D8:
	lea	(-$2,a1),a0
.l59DC:
	addq.w	#2,a0
	move.w	d0,(a0)
	cmpa.l	a2,a0
	bcs.s	.l59DC
	jmp	(a6)
loc_59E6:
	clr.l	d5
	bra.s	loc_59EC
loc_59EA:
	moveq	#-$1,d5
loc_59EC:
	addq.l	#1,d6
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l59F6:
	addq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l59FC:
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5A0A
	moveq	#$1,d4
	jmp	loc_5E82
.l5A0A:
	clr.w	WATCHDOG
	eor.w	d2,d0
	move.w	d0,(a0)
	lsr.w	#1,d2
	bcc.s	.l59FC
	cmpa.l	a2,a0
	bcs.s	.l59F6
	addq.w	#2,a0
.l5A1E:
	move.w	-(a0),d1
	cmp.w	d1,d0
	beq.s	.l5A2C
	moveq	#$1,d4
	jmp	loc_5E82
.l5A2C:
	cmpa.l	a1,a0
	bhi.s	.l5A1E
	jmp	(a6)
loc_5A32:
	clr.l	d5
	bra.s	loc_5A38
loc_5A36:
	moveq	#-$1,d5
loc_5A38:
	addq.l	#1,d6
	moveq	#$1,d7
	lea	($2,a2),a0
.l5A40:
	subq.w	#2,a0
	move.w	d7,d2
	move.w	d5,d0
.l5A46:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5A5A
	moveq	#$1,d4
	jmp	loc_5E82
.l5A5A:
	eor.w	d2,d0
	move.w	d0,(a0)
	lsl.w	#1,d2
	bcc.s	.l5A46
	cmpa.l	a1,a0
	bhi.s	.l5A40
	bra.s	.l5A6A
.l5A68:
	addq.w	#2,a0
.l5A6A:
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5A78
	moveq	#$1,d4
	jmp	loc_5E82
.l5A78:
	cmpa.l	a2,a0
	bcs.s	.l5A68
	jmp	(a6)
loc_5A7E:
	clr.l	d5
	bra.s	loc_5A84
loc_5A82:
	moveq	#-$1,d5
loc_5A84:
	addq.l	#1,d6
	move.w	#$8000,d7
	lea	(-$2,a1),a0
.l5A8E:
	addq.w	#2,a0
	move.w	d7,d2
.l5A92:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5AA2
	moveq	#$1,d4
	jmp	loc_5E82
.l5AA2:
	clr.w	WATCHDOG
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsr.w	#1,d2
	bcc.s	.l5A92
	cmpa.l	a2,a0
	bcs.s	.l5A8E
	move.w	d5,d0
	addq.w	#2,a0
.l5ABA:
	clr.w	WATCHDOG
	move.w	-(a0),d1
	cmp.w	d1,d0
	beq.s	.l5ACE
	moveq	#$1,d4
	jmp	loc_5E82
.l5ACE:
	cmpa.l	a1,a0
	bhi.s	.l5ABA
	jmp	(a6)
loc_5AD4:
	clr.l	d5
	bra.s	loc_5ADA
loc_5AD8:
	moveq	#-$1,d5
loc_5ADA:
	addq.l	#1,d6
	moveq	#$1,d7
	lea	($2,a2),a0
.l5AE2:
	clr.w	WATCHDOG
	subq.w	#2,a0
	move.w	d7,d2
.l5AEC:
	move.w	d5,d0
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5AFC
	moveq	#$1,d4
	jmp	loc_5E82
.l5AFC:
	eor.w	d2,d0
	move.w	d0,(a0)
	move.w	d5,(a0)
	lsl.w	#1,d2
	bcc.s	.l5AEC
	cmpa.l	a1,a0
	bhi.s	.l5AE2
	move.w	d5,d0
	bra.s	.l5B10
.l5B0E:
	addq.w	#2,a0
.l5B10:
	clr.w	WATCHDOG
	move.w	(a0),d1
	cmp.w	d1,d0
	beq.s	.l5B24
	moveq	#$1,d4
	jmp	loc_5E82
.l5B24:
	cmpa.l	a2,a0
	bcs.s	.l5B0E
	jmp	(a6)
loc_5B2A:
	addq.l	#1,d6
	movea.l	a1,a0
	moveq	#$0,d0
.l5B30:
	clr.w	WATCHDOG
	eori.w	#$FFFF,($0,a0,d0.w)
	move.w	($0,a0,d0.w),d1
	beq.s	.l5B4A
	moveq	#$1,d4
	jmp	loc_5E82
.l5B4A:
	ori.w	#$FFFF,($0,a0,d0.w)
	move.w	($0,a0,d0.w),d1
	cmpi.w	#$FFFF,d1
	beq.w	.l5B66
	moveq	#-$1,d0
	moveq	#$1,d4
	jmp	loc_5E82
.l5B66:
	addq.w	#2,a0
	cmpa.l	a2,a0
	bne.s	.l5B30
	jmp	(a6)
loc_5B6E:
	clr.l	d6
	clr.l	d0
	clr.l	d4
	lea	(sub_5B7C,pc),a6
	bra.w	loc_59D8
sub_5B7C:
	btst	#$5,PORT0+$1
	beq.s	.l5B8C
	jmp	loc_260
.l5B8C:
	btst	#$2,BUTTONS+$1
	bne.s	.l5B9C
	jmp	loc_F94
.l5B9C:
	lea	(sub_5BA4,pc),a6
	bra.w	loc_5DF0
sub_5BA4:
	lea	(sub_5BAC,pc),a6
	bra.w	loc_5E48
sub_5BAC:
	lea	(sub_5BB4,pc),a6
	bra.w	loc_59E6
sub_5BB4:
	lea	(sub_5BBC,pc),a6
	bra.w	loc_5E9E
sub_5BBC:
	btst	#$5,PORT0+$1
	beq.s	.l5BCC
	jmp	loc_260
.l5BCC:
	btst	#$2,BUTTONS+$1
	bne.s	.l5BDC
	jmp	loc_F94
.l5BDC:
	lea	(sub_5BE4,pc),a6
	bra.w	loc_5DFE
sub_5BE4:
	lea	(sub_5BEC,pc),a6
	bra.w	loc_5E48
sub_5BEC:
	lea	(sub_5BF4,pc),a6
	bra.w	loc_59EA
sub_5BF4:
	lea	(sub_5BFC,pc),a6
	bra.w	loc_5E9E
sub_5BFC:
	btst	#$5,PORT0+$1
	beq.s	.l5C0C
	jmp	loc_260
.l5C0C:
	btst	#$2,BUTTONS+$1
	bne.s	.l5C1C
	jmp	loc_F94
.l5C1C:
	lea	(sub_5C24,pc),a6
	bra.w	loc_5DF0
sub_5C24:
	lea	(sub_5C2C,pc),a6
	bra.w	loc_5E48
sub_5C2C:
	lea	(sub_5C34,pc),a6
	bra.w	loc_5A32
sub_5C34:
	lea	(sub_5C3C,pc),a6
	bra.w	loc_5E9E
sub_5C3C:
	btst	#$5,PORT0+$1
	beq.s	.l5C4C
	jmp	loc_260
.l5C4C:
	btst	#$2,BUTTONS+$1
	bne.s	.l5C5C
	jmp	loc_F94
.l5C5C:
	lea	(sub_5C64,pc),a6
	bra.w	loc_5DFE
sub_5C64:
	lea	(sub_5C6C,pc),a6
	bra.w	loc_5E48
sub_5C6C:
	lea	(sub_5C74,pc),a6
	bra.w	loc_5A36
sub_5C74:
	lea	(sub_5C7C,pc),a6
	bra.w	loc_5E9E
sub_5C7C:
	btst	#$5,PORT0+$1
	beq.s	.l5C8C
	jmp	loc_260
.l5C8C:
	btst	#$2,BUTTONS+$1
	bne.s	.l5C9C
	jmp	loc_F94
.l5C9C:
	lea	(sub_5CA4,pc),a6
	bra.w	loc_5DF0
sub_5CA4:
	lea	(sub_5CAC,pc),a6
	bra.w	loc_5E48
sub_5CAC:
	lea	(sub_5CB4,pc),a6
	bra.w	loc_5A7E
sub_5CB4:
	lea	(sub_5CBC,pc),a6
	bra.w	loc_5E9E
sub_5CBC:
	btst	#$5,PORT0+$1
	beq.s	.l5CCC
	jmp	loc_260
.l5CCC:
	btst	#$2,BUTTONS+$1
	bne.s	.l5CDC
	jmp	loc_F94
.l5CDC:
	lea	(sub_5CE4,pc),a6
	bra.w	loc_5DFE
sub_5CE4:
	lea	(sub_5CEC,pc),a6
	bra.w	loc_5E48
sub_5CEC:
	lea	(sub_5CF4,pc),a6
	bra.w	loc_5AD4
sub_5CF4:
	lea	(sub_5CFC,pc),a6
	bra.w	loc_5E9E
sub_5CFC:
	moveq	#-$1,d0
	lea	(sub_5D06,pc),a6
	bra.w	loc_59D8
sub_5D06:
	btst	#$5,PORT0+$1
	beq.s	.l5D16
	jmp	loc_260
.l5D16:
	btst	#$2,BUTTONS+$1
	bne.s	.l5D26
	jmp	loc_F94
.l5D26:
	lea	(sub_5D2E,pc),a6
	bra.w	loc_5DF0
sub_5D2E:
	lea	(sub_5D36,pc),a6
	bra.w	loc_5E48
sub_5D36:
	lea	(sub_5D3E,pc),a6
	bra.w	loc_5A82
sub_5D3E:
	lea	(sub_5D46,pc),a6
	bra.w	loc_5E9E
sub_5D46:
	btst	#$5,PORT0+$1
	beq.s	.l5D56
	jmp	loc_260
.l5D56:
	btst	#$2,BUTTONS+$1
	bne.s	.l5D66
	jmp	loc_F94
.l5D66:
	lea	(sub_5D6E,pc),a6
	bra.w	loc_5DFE
sub_5D6E:
	lea	(sub_5D76,pc),a6
	bra.w	loc_5E48
sub_5D76:
	lea	(sub_5D7E,pc),a6
	bra.w	loc_5AD8
sub_5D7E:
	lea	(sub_5D86,pc),a6
	bra.w	loc_5E9E
sub_5D86:
	btst	#$5,PORT0+$1
	beq.s	.l5D96
	jmp	loc_260
.l5D96:
	btst	#$2,BUTTONS+$1
	bne.s	.l5DA6
	jmp	loc_F94
.l5DA6:
	lea	(sub_5DAE,pc),a6
	bra.w	loc_5DF0
sub_5DAE:
	lea	(sub_5DB6,pc),a6
	bra.w	loc_5E48
sub_5DB6:
	lea	(sub_5DBE,pc),a6
	bra.w	loc_5B2A
sub_5DBE:
	lea	(sub_5DC6,pc),a6
	bra.w	loc_5E9E
sub_5DC6:
	lea	(sub_5DCE,pc),a6
	bra.w	loc_5E0C
sub_5DCE:
	btst	#$5,PORT0+$1
	beq.s	.l5DDE
	jmp	loc_260
.l5DDE:
	btst	#$2,BUTTONS+$1
	bne.s	.l5DEE
	jmp	loc_F94
.l5DEE:
	jmp	(a4)
loc_5DF0:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$2
	jmp	(a6)
loc_5DFE:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$12
	jmp	(a6)
loc_5E0C:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	jmp	(a6)
dat_5E1A:
	incbin	"../../build/stunrun-68k.bin",$5E1A,$2E
loc_5E48:
	move.w	#$3F3F,GSP_HOST+$C
	move.w	#$3F3F,GSP_HOST+$C
	subi.l	#$20,GSP_HOST+$2
	jmp	(a6)
loc_5E64:
	tst.w	d4
	move.w	#$5F5F,GSP_HOST+$C
	move.w	#$5F5F,GSP_HOST+$C
	addi.l	#$20,GSP_HOST+$2
	jmp	(a6)
loc_5E82:
	move.w	#$9F9F,GSP_HOST+$C
	move.w	#$9F9F,GSP_HOST+$C
	addi.l	#$20,GSP_HOST+$2
	jmp	(a4)
loc_5E9E:
	move.w	#$FFFF,GSP_HOST+$C
	move.w	#$FFFF,GSP_HOST+$C
	addi.l	#$20,GSP_HOST+$2
	jmp	(a6)
dat_5EBA:
	incbin	"../../build/stunrun-68k.bin",$5EBA,$13C
dat_5FF6:
	incbin	"../../build/stunrun-68k.bin",$5FF6,$90
loc_6086:
	clr.w	d2
	clr.w	d3
	clr.w	d5
.l608C:
	btst	#$5,PORT0+$1
	beq.s	.l609C
	jmp	loc_260
.l609C:
	btst	#$2,BUTTONS+$1
	bne.s	.l60AC
	jmp	loc_F94
.l60AC:
	lea	dat_5FF6,a1
	move.w	d2,d4
	muls.w	#$12,d4
	tst.w	($0,a1,d4.w)
	beq.w	.l6168
	cmpi.w	#$7,d2
	beq.w	.l6176
	movea.l	($6,a1,d4.w),a0
	clr.w	WATCHDOG
	clr.w	d0
	move.w	#$7FFF,d1
.l60D8:
	add.w	(a0)+,d0
	dbf	d1,.l60D8
	clr.w	WATCHDOG
	move.w	#$7FFF,d1
.l60E8:
	add.w	(a0)+,d0
	dbf	d1,.l60E8
	clr.w	WATCHDOG
	cmp.b	($2,a1,d4.w),d0
	beq.w	.l6102
	move.b	($4,a1,d4.w),d6
	bset	d6,d5
.l6102:
	btst	#$5,PORT0+$1
	beq.s	.l6112
	jmp	loc_260
.l6112:
	btst	#$2,BUTTONS+$1
	bne.s	.l6122
	jmp	loc_F94
.l6122:
	move.w	d2,d4
	muls.w	#$12,d4
	movea.l	($6,a1,d4.w),a0
	clr.w	WATCHDOG
	clr.w	d0
	move.w	#$7FFF,d1
.l6138:
	add.w	(a0)+,d0
	clr.b	d0
	dbf	d1,.l6138
	clr.w	WATCHDOG
	move.w	#$7FFF,d1
.l614A:
	add.w	(a0)+,d0
	clr.b	d0
	dbf	d1,.l614A
	lsr.w	#8,d0
	clr.w	WATCHDOG
	cmp.b	($3,a1,d4.w),d0
	beq.w	.l6168
	move.b	($5,a1,d4.w),d6
	bset	d6,d5
.l6168:
	addq.w	#1,d2
	cmpi.w	#$8,d2
	bne.w	.l608C
	bra.w	loc_6288
.l6176:
	btst	#$5,PORT0+$1
	beq.s	.l6186
	jmp	loc_260
.l6186:
	btst	#$2,BUTTONS+$1
	bne.s	.l6196
	jmp	loc_F94
.l6196:
	move.w	d2,d4
	muls.w	#$12,d4
	clr.w	d0
	move.w	io_E0000,d7
	move.w	io_E0010,d7
	move.w	io_E0000,d7
	movea.l	#$1,a3
	lea	io_E8000,a2
	move.w	io_E0010,d7
	lea	(sub_61CA,pc),a4
	bra.w	loc_630A
sub_61CA:
	move.w	io_E0034,d7
	lea	(sub_61D8,pc),a4
	bra.w	loc_630A
sub_61D8:
	move.w	io_E0058,d7
	lea	(sub_61E6,pc),a4
	bra.w	loc_630A
sub_61E6:
	move.w	io_E007C,d7
	lea	(sub_61F4,pc),a4
	bra.w	loc_630A
sub_61F4:
	cmp.b	($2,a1,d4.w),d0
	beq.w	.l6202
	move.b	($4,a1,d4.w),d6
	bset	d6,d5
.l6202:
	btst	#$5,PORT0+$1
	beq.s	.l6212
	jmp	loc_260
.l6212:
	btst	#$2,BUTTONS+$1
	bne.s	.l6222
	jmp	loc_F94
.l6222:
	clr.w	d0
	move.w	io_E0000,d7
	move.w	io_E0010,d7
	move.w	io_E0000,d7
	movea.l	#$1,a3
	lea	io_E7FFF,a2
	move.w	io_E0010,d7
	lea	(sub_6250,pc),a4
	bra.w	loc_630A
sub_6250:
	move.w	io_E0034,d7
	lea	(sub_625E,pc),a4
	bra.w	loc_630A
sub_625E:
	move.w	io_E0058,d7
	lea	(sub_626C,pc),a4
	bra.w	loc_630A
sub_626C:
	move.w	io_E007C,d7
	lea	(sub_627A,pc),a4
	bra.w	loc_630A
sub_627A:
	cmp.b	($3,a1,d4.w),d0
	beq.w	loc_6288
	move.b	($5,a1,d4.w),d6
	bset	d6,d5
loc_6288:
	movea.w	d5,a5
	movea.w	d5,a4
	tst.w	d5
	bne.w	loc_62AC
	lea	(sub_629A,pc),a0
	bra.w	loc_553E
sub_629A:
	move.w	#$43,d0
	lea	(sub_62A8,pc),a2
	jmp	loc_25E8
sub_62A8:
	bra.w	sub_62DE
loc_62AC:
	lea	(sub_62B4,pc),a0
	bra.w	loc_553E
sub_62B4:
	move.w	#$44,d0
	lea	(sub_62C2,pc),a2
	jmp	loc_25E8
sub_62C2:
	move.w	#$45,d0
	lea	(sub_62D0,pc),a2
	jmp	loc_25E8
sub_62D0:
	move.w	#$46,d0
	lea	(sub_62DE,pc),a2
	jmp	loc_25E8
sub_62DE:
	move.w	#$50,d0
	lea	(sub_62EC,pc),a2
	jmp	loc_25E8
sub_62EC:
	move.w	#$51,d0
	lea	(sub_62FA,pc),a2
	jmp	loc_25E8
sub_62FA:
	move.w	#$52,d0
	lea	(sub_6308,pc),a2
	jmp	loc_25E8
sub_6308:
	jmp	(a6)
loc_630A:
	clr.w	WATCHDOG
	clr.w	d1
	movea.l	a2,a0
	move.w	#$3FFF,d3
.l6318:
	move.b	-(a0),d1
	add.w	d1,d0
	suba.l	a3,a0
	dbf	d3,.l6318
	clr.w	WATCHDOG
	jmp	(a4)
sub_632A:
	bsr.w	sub_63CC
	move.w	$FFFF4FEE,(ram_FF8094-ABS_SHORT).w
	lea	$FFFF4000,a1
	lea	$FFFF4FEE,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF88EA00,GSP_HOST+$2
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	lea	(sub_636E,pc),a4
	bra.w	loc_5896
sub_636E:
	bsr.w	sub_63EE
	move.w	(ram_FF8094-ABS_SHORT).w,$FFFF4FEE
	clr.w	SOUND_RESET+$18
	clr.w	SOUND_RESET+$A
	move.w	(sp)+,sr
	tst.w	d4
	bne.w	.l639C
	move.w	#$D5,d0
	jsr	sub_2326
	bra.w	.l63CA
.l639C:
	move.w	#$D6,d0
	jsr	sub_2326
	eor.w	d0,d1
	tst.b	d1
	beq.w	.l63B8
	move.w	#$D8,d0
	jsr	sub_2326
.l63B8:
	andi.w	#$FF00,d1
	beq.w	.l63CA
	move.w	#$D7,d0
	jsr	sub_2326
.l63CA:
	rts
sub_63CC:
	clr.w	WATCHDOG
	lea	$FFFF4000,a1
	lea	(ram_FF9000-ABS_SHORT).w,a2
	move.w	#$3FB,d6
.l63E0:
	move.l	(a1)+,(a2)+
	dbf	d6,.l63E0
	clr.w	WATCHDOG
	rts
sub_63EE:
	clr.w	WATCHDOG
	lea	$FFFF4000,a1
	lea	(ram_FF9000-ABS_SHORT).w,a2
	move.w	#$3FB,d6
.l6402:
	move.l	(a2)+,(a1)+
	dbf	d6,.l6402
	clr.w	WATCHDOG
	rts
dat_6410:
	incbin	"../../build/stunrun-68k.bin",$6410,$F8
sub_6508:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	cmpi.b	#$55,$FFFF4FEF
	beq.w	.l6558
	move.b	#$55,$FFFF4FEF
	clr.b	$FFFF4FE1
	clr.b	$FFFF4FE3
	clr.b	$FFFF4FE5
	clr.b	$FFFF4FE7
	clr.b	$FFFF4FE9
	clr.b	$FFFF4FEB
	clr.b	$FFFF4FED
.l6558:
	andi	#$EF,ccr
	move.b	#$1,d0
	move.b	$FFFF4FED,d1
	abcd.b	d0,d1
	move.b	d1,$FFFF4FED
	clr.b	d0
	move.b	$FFFF4FEB,d1
	abcd.b	d0,d1
	move.b	d1,$FFFF4FEB
	move.b	$FFFF4FE9,d1
	abcd.b	d0,d1
	move.b	d1,$FFFF4FE9
	move.b	$FFFF4FE1,d7
	lsl.l	#8,d7
	move.b	$FFFF4FE3,d7
	lsl.l	#8,d7
	move.b	$FFFF4FE5,d7
	lsl.l	#8,d7
	move.b	$FFFF4FE7,d7
	jsr	sub_394E
	move.b	d7,$FFFF4FE7
	lsr.l	#8,d7
	move.b	d7,$FFFF4FE5
	lsr.l	#8,d7
	move.b	d7,$FFFF4FE3
	lsr.l	#8,d7
	move.b	d7,$FFFF4FE1
	lsr.l	#8,d7
	clr.w	SOUND_RESET+$18
	clr.w	SOUND_RESET+$A
	move.w	(sp)+,sr
	rts
	assert	*=$0065E0,"boot/code_00394E.asm does not end at 0065E0"
