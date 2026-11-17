; data.asm, 046AEE-060000: the game program's data, then zero to the end of pair T.
; Owner: the data leg. Not source yet but the zero fill (docs/13-68k-source.md section 4).
;
; 046AEE-05CF86: data with a 68k consumer, 724 references from code, the first 046AEE from
; 046A0C, the last 05C63C (audio_test_list) from 043720 (docs/06 section 4.2).

	assert	*=$046AEE,"data.asm misplaced"

dat_46AEE:
	incbin	"../../build/stunrun-68k.bin",$046AEE,$05CF86-$046AEE

; 05CF86-060000: zero (12,410 bytes)
	dcb.b	$060000-*,0

	assert	*=$060000,"data.asm does not end at 060000"
