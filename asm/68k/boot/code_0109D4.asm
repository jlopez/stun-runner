; boot/code_0109D4.asm, 0109D4-012F06: boot program code (pair R) with the data,
; text and tables that lie between its routines; the first routine is sub_109D4. Cut at
; routine starts into files of about 16 KB named by their first address (decision C11).
; Owner: the boot naming legs (M5a, M5c-e for the boot program's tests and menus).
;
; Generated once by tools/m68k gen 0109D4 012F06 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$0109D4,"boot/code_0109D4.asm misplaced"
sub_109D4:
	lea	($4,sp),a0
	addq.l	#2,a0
	move.w	(a0),GSP_HOST+$C
	lea	($4,sp),a0
	move.w	(a0),GSP_HOST+$C
	rts
dat_109EC:
	incbin	"../../build/stunrun-68k.bin",$109EC,$546
dat_10F32:
	incbin	"../../build/stunrun-68k.bin",$10F32,$DFC
	dcb.b	228,0
dat_11E12:
	incbin	"../../build/stunrun-68k.bin",$11E12,$30
	dcb.b	32,0
dat_11E62:
	incbin	"../../build/stunrun-68k.bin",$11E62,$900
	dcb.b	32,0
dat_12782:
	incbin	"../../build/stunrun-68k.bin",$12782,$80
	dcb.b	32,0
dat_12822:
	incbin	"../../build/stunrun-68k.bin",$12822,$300
	dcb.b	32,0
dat_12B42:
	incbin	"../../build/stunrun-68k.bin",$12B42,$20
	dcb.b	32,0
dat_12B82:
	incbin	"../../build/stunrun-68k.bin",$12B82,$40
	dcb.b	72,0
dat_12C0A:
	incbin	"../../build/stunrun-68k.bin",$12C0A,$18
	dcb.b	32,0
dat_12C42:
	incbin	"../../build/stunrun-68k.bin",$12C42,$60
	dcb.b	32,0
dat_12CC2:
	incbin	"../../build/stunrun-68k.bin",$12CC2,$FA
sub_12DBC:
	move.w	#$0,(a5)+
	subq.l	#1,d0
	bgt.s	sub_12DBC
	rts
dat_12DC6:
	incbin	"../../build/stunrun-68k.bin",$12DC6,$C
dat_12DD2:
	incbin	"../../build/stunrun-68k.bin",$12DD2,$C
dat_12DDE:
	incbin	"../../build/stunrun-68k.bin",$12DDE,$128
	assert	*=$012F06,"boot/code_0109D4.asm does not end at 012F06"
