; S.T.U.N. Runner (rev 6), 68010 program space 000000-0BFFFF: the twelve 200x/210x files.
;
; The main file: org 0, the equates (hardware.asm, ram.asm) and the macros, then the region files
; in address order (docs/13-68k-source.md); the code is neutral source since M5c (docs/16).
; Each region file is one contiguous range with an assert at both ends and one owner (the table
; below); a later leg may split its own file into several under its directory but never moves a
; boundary between owners. What is not source yet is an incbin of build/stunrun-68k.bin (offset
; and length, never the archive), the image tools/merge-roms interleaves from the reference set
; (200x = even bytes D15-D8, 210x = odd bytes D7-D0; docs/01-hardware.md section 2); the ADSP
; and GSP programs are incbins of build/adsp/program.bin and build/gsp/program.bin, which
; tools/extract-programs cuts out of that image (M2, docs/06-code-map.md section 3.4).
; Assembled with vasmm68k_mot -Fbin -no-opt -m68010 (docs/04-build.md); tools/split-roms cuts
; build/stunrun-68k.out back into the twelve files. An incbin path is relative to this file's
; directory, also in the files under boot/ and game/.
;
;   file                  range            owner
;   boot/vectors.asm      000000-000212    boot naming legs
;   boot/code_*.asm       000212-012F06    boot naming legs (six files, cut at routine starts)
;   programs.asm          012F06-020000    M5-0 (the table), M6 (the two programs)
;   game/vectors.asm      020000-020430    game naming legs
;   game/code_*.asm       020430-04397E    game naming legs (nine files, cut at routine starts)
;   game/island.asm       04397E-046AEE    game naming legs
;   data.asm              046AEE-060000    data leg
;   images.asm            060000-0BFE00    images leg
;   image_table.asm       0BFE00-0C0000    images leg
;
; The pair boundaries (020000 S, 040000 T, 060000 U, 080000 V, 0A0000 W) are not file
; boundaries: game/code_03FC22.asm crosses 040000 (the function at 03FEA6 does), images.asm
; 080000 and 0A0000.

	org	0

	include	"hardware.asm"
	include	"ram.asm"
	include	"macros.asm"

	include	"boot/vectors.asm"
	include	"boot/code_000212.asm"
	include	"boot/code_00394E.asm"
	include	"boot/code_0065E0.asm"
	include	"boot/code_009E80.asm"
	include	"boot/code_00DDF2.asm"
	include	"boot/code_0109D4.asm"
	include	"programs.asm"
	include	"game/vectors.asm"
	include	"game/code_020430.asm"
	include	"game/code_024306.asm"
	include	"game/code_028194.asm"
	include	"game/code_02C0D2.asm"
	include	"game/code_030012.asm"
	include	"game/code_034010.asm"
	include	"game/code_037C52.asm"
	include	"game/code_03BC3C.asm"
	include	"game/code_03FC22.asm"
	include	"game/island.asm"
	include	"data.asm"
	include	"images.asm"
	include	"image_table.asm"

	assert	*=$0C0000,"68k image does not end at 0C0000"
