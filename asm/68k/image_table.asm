; image_table.asm, 0BFE00-0C0000: the image pointer table, then zero to the end of pair W.
; Owner: the images leg. Not source yet but the zero fill (docs/13-68k-source.md section 4).
;
; 0BFE00-0BFF18: 70 longs, entry 0 = 0, entries 1-68 point into images.asm, entry 69 = 0 ends it;
; indexed from its base by lea $bfe00 at 022798 and addi.l #$bfe00 at 024AC4 and seven more
; places (docs/06 section 4.2). An incbin until the images leg gives the images labels.

	assert	*=$0BFE00,"image_table.asm misplaced"

tbl_BFE00:
	incbin	"../../build/stunrun-68k.bin",$0BFE00,$0BFF18-$0BFE00

; 0BFF18-0C0000: zero (232 bytes)
	dcb.b	$0C0000-*,0

	assert	*=$0C0000,"image_table.asm does not end at 0C0000"
