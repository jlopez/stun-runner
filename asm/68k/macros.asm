; Macros and constants the 68k source needs where vasm 2.0f cannot write an encoding the ROM has
; (docs/14-68k-descent.md section 5.2, every one with its tested example in tools/test_m68k.py).
; Owned by M5g; the code legs include this file once, before any region file that uses it.
; tools/m68k reads the macro names below: a statement that invokes one is an instruction for the
; listing checks (docs/14 section 5.3).

; ABS_SHORT: vasm 2.0f checks an absolute short address against -$8000..$7FFF and does not
; sign-extend a 24-bit RAM address (error 2033, "absolute short address out of range", for
; `move.w ram_FF9518.w,d0` with ram_FF9518 equ $FF9518). RAM equates stay 24-bit, as the
; absolute long operands need them, and an absolute short operand subtracts this:
;	move.w	(ram_FF9518-ABS_SHORT).w,d0	; 30389518
ABS_SHORT	equ	$1000000

; move.b #$FF,<ea> with the immediate word FFFF. The 68010 reads only the low byte of a byte
; immediate's extension word; assemblers write 00 above it, but ten instructions of the game
; carry FFFF (a sign-extended -1): 024350, 0244B2, 02B97C, 03AB90, 03B206, 03D0DE, 041726,
; 04172E, 04174A, 04174E. vasm writes 00FF for `move.b #-1` and `move.b #$FF` and refuses
; `move.b #$FFFF`, so these two macros write the opcode word and the immediate word and keep
; the operand symbolic. Only the two destinations the ROM uses exist.

; moveb_ffff_ind n: move.b #$FF,(An) with the immediate word FFFF; \1 = n, 0-7 (03D0DE: a1,
; 04174A: a4). Opcode 0001 nnn 010 111 100.
moveb_ffff_ind	macro
	dc.w	$10BC|((\1)<<9),$FFFF
	endm

; moveb_ffff_abs addr: move.b #$FF,addr (absolute long) with the immediate word FFFF (the other
; eight). Opcode 0001 001 111 111 100.
moveb_ffff_abs	macro
	dc.w	$13FC,$FFFF
	dc.l	\1
	endm
