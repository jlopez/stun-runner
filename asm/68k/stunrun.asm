; S.T.U.N. Runner (rev 6), 68010 program space 000000-0BFFFF: the twelve 200x/210x files.
;
; Every byte is still an incbin: of build/stunrun-68k.bin, the image tools/merge-roms
; interleaves from the reference set (200x = even bytes D15-D8, 210x = odd bytes D7-D0;
; docs/01-hardware.md section 2), except the ADSP and GSP programs, which tools/extract-programs
; cuts out of that image into build/adsp/program.bin and build/gsp/program.bin (M2). M5 replaces
; the 68k blobs region by region with source, M6 the two programs. Assembled with vasmm68k_mot
; -Fbin -no-opt -m68010 (docs/04-build.md); tools/split-roms cuts build/stunrun-68k.out back into
; the twelve files.

	org	0

; 000000-01FFFF: 136070-2102.200r (even) / 136070-2101.210r (odd): the boot program, with the
; ADSP and GSP programs at 01702E-01EFD4 (docs/06-code-map.md). Those two are their own blobs,
; cut out of the image by tools/extract-programs; M6 assembles them from source.
rom_r:
	assert	*=$000000,"pair R misplaced"
	incbin	"../../build/stunrun-68k.bin",$000000,$1702E

; 01702E-01907C: the ADSP-2100 program as the loader at 02D2E0 reads it (records: flag byte,
; word address, count, 24-bit opcodes; terminator byte), reached through the long at 017000.
adsp_program:
	assert	*=$01702E,"adsp_program misplaced"
	incbin	"../../build/adsp/program.bin"
	assert	*=$01907C,"adsp_program is not 0x204E bytes"

; 01907C-01EFD4: the TMS34010 program as the loader at 02FDD0 reads it (section count, then per
; section a bit address, a bit length and the data as longs), reached through the long at 017004.
gsp_program:
	assert	*=$01907C,"gsp_program misplaced"
	incbin	"../../build/gsp/program.bin"
	assert	*=$01EFD4,"gsp_program is not 0x5F58 bytes"

; 01EFD4-01FFFF: the rest of the boot program's pair
rom_r_tail:
	incbin	"../../build/stunrun-68k.bin",$01EFD4,$20000-$01EFD4

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
