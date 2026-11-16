; game/vectors.asm, 020000-020430: the game program's vector table, its entries and a data block.
; Owner: the game leg. Not source yet but the zero fill (docs/13-68k-source.md section 4).
;
; 020000-020100: the game vector table (64 longs, game_vec_*), installed by movec at 000294.
; 020100-020112: game_entries, three jmp (docs/06 section 1.1). 020112-020418: zero.
; 020418-020430: 24 bytes of game data, read at 02079A and 020D30 (sub.b $20418.l) and 02093E
; (the word at 02041A), referenced from 0209AC, 020A88, 042324 (docs/06 section 4.2).

	assert	*=$020000,"game/vectors.asm misplaced (pair S)"

game_vec_reset_sp:
	incbin	"../../build/stunrun-68k.bin",$020000,$000100

game_entries:
	incbin	"../../build/stunrun-68k.bin",$020100,$000012

; 020112-020418: zero (774 bytes)
	dcb.b	$020418-*,0

dat_20418:
	incbin	"../../build/stunrun-68k.bin",$020418,$000018

	assert	*=$020430,"game/vectors.asm does not end at 020430"
