; game/island.asm, 04397E-046AEE: a data island inside the game code, then the last code.
; Owner: the game leg. Not source yet (docs/13-68k-source.md section 4).
;
; 04397E-046A00: data, after the rts at 04397C; 32 references, e.g. 0439BC from 041F1C,
; 0461F0 from 02444E. 046A00-046AEE: code, sub_46A00 to sub_46AC4 (046AC4-046AEE), the end of
; the 68k code (MAME's highest 68k PC is 046AEC; docs/06 sections 4.2 and 7).

	assert	*=$04397E,"game/island.asm misplaced"

dat_4397E:
	incbin	"../../build/stunrun-68k.bin",$04397E,$046A00-$04397E

sub_46A00:
	incbin	"../../build/stunrun-68k.bin",$046A00,$046AEE-$046A00

	assert	*=$046AEE,"game/island.asm does not end at 046AEE"
