; S.T.U.N. Runner (rev 6), factory NVRAM contents: the 200E (M48T02, high byte of ZRAM) and
; 210E (2816 EEPROM, low byte of ZRAM) images, 2 KB each (docs/01-hardware.md section 2).
;
; Milestone 1 zero point: one incbin per file of build/stunrun-nvram.bin (200e then 210e).

	org	0

; stunrun.200e
nvram_200e:
	assert	*=$0000,"stunrun.200e misplaced"
	incbin	"../../build/stunrun-nvram.bin",$0000,$0800

; stunrun.210e
nvram_210e:
	assert	*=$0800,"stunrun.210e misplaced"
	incbin	"../../build/stunrun-nvram.bin",$0800,$0800

	assert	*=$1000,"NVRAM image does not end at 1000"
