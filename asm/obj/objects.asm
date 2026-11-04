; S.T.U.N. Runner (rev 6), ADSP II object ROMs: the 384 KB serial data stream the ADSP-2100
; reads through /SIMBUF as 16-bit words (docs/01-hardware.md section 5).
;
; Milestone 1 zero point: incbin of build/stunrun-obj.bin, which tools/merge-roms interleaves
; from the six files (first of each pair = even bytes, high byte of the word). M3 decodes the
; records into meshes. Assembled with vasmm68k_mot as a plain byte image (docs/04-build.md).

	org	0

; image 00000-1FFFF, words 00000-0FFFF (/MP page 0): 136070-2121.90h (even) / 136070-2118.90k (odd)
objects_90h:
	assert	*=$00000,"pair 90h misplaced"
	incbin	"../../build/stunrun-obj.bin",$00000,$20000

; image 20000-3FFFF, words 10000-1FFFF (/MP page 1): 136070-2122.10h (even) / 136070-2119.10k (odd)
objects_10h:
	assert	*=$20000,"pair 10h misplaced"
	incbin	"../../build/stunrun-obj.bin",$20000,$20000

; image 40000-5FFFF, words 20000-2FFFF (/MP page 2): 136070-2120.9h (even) / 136070-2117.9k (odd)
objects_9h:
	assert	*=$40000,"pair 9h misplaced"
	incbin	"../../build/stunrun-obj.bin",$40000,$20000

	assert	*=$60000,"object image does not end at 60000"
