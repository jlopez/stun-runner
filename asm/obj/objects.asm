; S.T.U.N. Runner (rev 6), ADSP II object ROMs: the 384 KB serial data stream the ADSP-2100
; reads through /SIMBUF as 16-bit words (docs/01-hardware.md section 5, docs/07-objects.md).
;
; Milestone 3: the source of the object image is data/objects (a manifest and one mesh file per
; object). `tools/objects asm` turns it into build/obj/page0.asm-page2.asm, one per /MP page of
; 0x10000 words: dc.w for the directory, the reciprocal table, every object and the checksum
; words, dcb.w for the zero fill, and an incbin slice of build/stunrun-obj.bin for each residue
; range the format does not explain (docs/07 section 5.3). Each page holds two chips: the even
; bytes (the high byte of each word) go to the first file of the pair (tools/split-roms).
; Assembled with vasmm68k_mot as a plain byte image (docs/04-build.md).

	org	0

; image 00000-1FFFF, words 00000-0FFFF (/MP page 0): 136070-2121.90h (even) / 136070-2118.90k (odd)
objects_90h:
	assert	*=$00000,"pair 90h misplaced"
	include	"../../build/obj/page0.asm"

; image 20000-3FFFF, words 10000-1FFFF (/MP page 1): 136070-2122.10h (even) / 136070-2119.10k (odd)
objects_10h:
	assert	*=$20000,"pair 10h misplaced"
	include	"../../build/obj/page1.asm"

; image 40000-5FFFF, words 20000-2FFFF (/MP page 2): 136070-2120.9h (even) / 136070-2117.9k (odd)
objects_9h:
	assert	*=$40000,"pair 9h misplaced"
	include	"../../build/obj/page2.asm"

	assert	*=$60000,"object image does not end at 60000"
