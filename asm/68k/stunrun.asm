; S.T.U.N. Runner (rev 6), 68010 program space 000000-0BFFFF: the twelve 200x/210x files.
;
; Milestone 1 zero point: every byte is an incbin of build/stunrun-68k.bin, the image
; tools/merge-roms interleaves from the reference set (200x = even bytes D15-D8, 210x = odd
; bytes D7-D0; docs/01-hardware.md section 2). M5 replaces these blobs region by region with
; source. Assembled with vasmm68k_mot -Fbin -no-opt -m68010 (docs/04-build.md); tools/split-roms
; cuts build/stunrun-68k.out back into the twelve files.

	org	0

; 000000-01FFFF: 136070-2102.200r (even) / 136070-2101.210r (odd)
rom_r:
	assert	*=$000000,"pair R misplaced"
	incbin	"../../build/stunrun-68k.bin",$000000,$20000

; 020000-03FFFF: 136070-6104.200s (even) / 136070-6103.210s (odd)
rom_s:
	assert	*=$020000,"pair S misplaced"
	incbin	"../../build/stunrun-68k.bin",$020000,$20000

; 040000-05FFFF: 136070-6106.200t (even) / 136070-6105.210t (odd)
rom_t:
	assert	*=$040000,"pair T misplaced"
	incbin	"../../build/stunrun-68k.bin",$040000,$20000

; 060000-07FFFF: 136070-2108.200u (even) / 136070-2107.210u (odd)
rom_u:
	assert	*=$060000,"pair U misplaced"
	incbin	"../../build/stunrun-68k.bin",$060000,$20000

; 080000-09FFFF: 136070-2110.200v (even) / 136070-2109.210v (odd)
rom_v:
	assert	*=$080000,"pair V misplaced"
	incbin	"../../build/stunrun-68k.bin",$080000,$20000

; 0A0000-0BFFFF: 136070-2112.200w (even) / 136070-2111.210w (odd)
rom_w:
	assert	*=$0A0000,"pair W misplaced"
	incbin	"../../build/stunrun-68k.bin",$0A0000,$20000

	assert	*=$0C0000,"68k image does not end at 0C0000"
