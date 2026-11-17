; S.T.U.N. Runner (rev 6), factory NVRAM contents: the 200E (M48T02, high byte of ZRAM) and
; 210E (2816 EEPROM, low byte of ZRAM) images, 2 KB each (docs/01-hardware.md section 2).
;
; Both images are blank: every one of their 2 x 2,048 bytes is zero (measured on the reference
; set, M5-0; docs/13-68k-source.md section 8), so they are fills, as the 68k image's zero runs
; are. The 68010 sees the two chips interleaved as ZRAM at FF4000-FF4FFF (docs/01 section 3) and
; writes them at run time (copy_to_zram 022578; game_reset counts restarts at FF4B90, 02EFB6).
; Every MAME run of this repository starts from these images (an empty -nvram_directory).

	org	0

; stunrun.200e
nvram_200e:
	assert	*=$0000,"stunrun.200e misplaced"
	dcb.b	$0800,0

; stunrun.210e
nvram_210e:
	assert	*=$0800,"stunrun.210e misplaced"
	dcb.b	$0800,0

	assert	*=$1000,"NVRAM image does not end at 1000"
