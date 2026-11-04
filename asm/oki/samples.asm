; S.T.U.N. Runner (rev 6), JSA II OKI M6295 ADPCM samples: 256 KB, not banked on JSA II
; (docs/01-hardware.md section 6).
;
; Milestone 1 zero point: one incbin per ROM file of build/stunrun-oki.bin (the four files
; concatenated by tools/merge-roms). M4 splits it into samples by the phrase table.

	org	0

; OKI 00000-0FFFF: 136070-2124.1fh
oki_1fh:
	assert	*=$00000,"136070-2124.1fh misplaced"
	incbin	"../../build/stunrun-oki.bin",$00000,$10000

; OKI 10000-1FFFF: 136070-2125.1ef
oki_1ef:
	assert	*=$10000,"136070-2125.1ef misplaced"
	incbin	"../../build/stunrun-oki.bin",$10000,$10000

; OKI 20000-2FFFF: 136070-2126.1de
oki_1de:
	assert	*=$20000,"136070-2126.1de misplaced"
	incbin	"../../build/stunrun-oki.bin",$20000,$10000

; OKI 30000-3FFFF: 136070-2127.1cd
oki_1cd:
	assert	*=$30000,"136070-2127.1cd misplaced"
	incbin	"../../build/stunrun-oki.bin",$30000,$10000

	assert	*=$40000,"OKI image does not end at 40000"
