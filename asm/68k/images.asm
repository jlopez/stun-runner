; images.asm, 060000-0BFE00: the packed GSP images (pairs U, V, W), then zero.
; Owner: the images leg. Not source yet but the zero fill (docs/13-68k-source.md section 4).
;
; 060000-0B10EB: the images unpack_gsp_image (0225E4) streams into HSTDATA, reached through the
; image pointer table at 0BFE00 (entry 1 = 060002, entry 68 = 0ADE80; docs/06 section 4.2). The
; file crosses the pair boundaries 080000 and 0A0000, which are not image boundaries.

	assert	*=$060000,"images.asm misplaced (pair U)"

dat_60000:
	incbin	"../../build/stunrun-68k.bin",$060000,$0B10EB-$060000

; 0B10EB-0BFE00: zero (60,693 bytes)
	dcb.b	$0BFE00-*,0

	assert	*=$0BFE00,"images.asm does not end at 0BFE00"
