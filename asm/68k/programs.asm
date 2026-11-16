; programs.asm, 012F06-020000: zero fill, the program table, the ADSP and GSP programs, zero fill.
; Owners: M5-0 (the table, the fills), M6 (the two programs, today blobs of their own).
;
; The program table (docs/06 section 2) is read by the game program: adsp_program_ptr at
; 02C204 (init_coprocessors, for load_adsp_program 02D2E0), gsp_program_ptr at 02C1B6
; (init_coprocessors) and 02DCB0 (reload_gsp), for load_gsp_program 02FDD0. The two pointers are
; the labels of the programs below, so the table follows them if they move;
; tools/extract-programs checks the same two values in the image. The two longs at 017008 and
; 01700C and the word at 01702C have no reader and no explanation (none is a sum or CRC-32 of the
; programs, docs/06 section 2): they stay incbin slices (the residue rule, CLAUDE.md section 5).

	assert	*=$012F06,"programs.asm misplaced"

; 012F06-017000: zero (16,634 bytes; docs/06 section 4.1)
	dcb.b	$017000-*,0

	assert	*=$017000,"program table misplaced"
adsp_program_ptr:
	dc.l	adsp_program			; read at 02C204
gsp_program_ptr:
	dc.l	gsp_program			; read at 02C1B6 and 02DCB0
program_table_long_8:
	incbin	"../../build/stunrun-68k.bin",$017008,4	; no reader
program_table_long_c:
	incbin	"../../build/stunrun-68k.bin",$01700C,4	; no reader
copyright_text:
	dc.b	"Copyright 1989 ATARI GAMES",0,0	; no reader; HYP: NUL-terminated, padded to a word
dat_1702C:
	incbin	"../../build/stunrun-68k.bin",$01702C,2	; no reader

; 01702E-01907C: the ADSP-2100 program as the loader at 02D2E0 reads it (records: flag byte,
; word address, count, 24-bit opcodes; terminator byte), reached through adsp_program_ptr.
adsp_program:
	assert	*=$01702E,"adsp_program misplaced"
	incbin	"../../build/adsp/program.bin"
	assert	*=$01907C,"adsp_program is not 0x204E bytes"

; 01907C-01EFD4: the TMS34010 program as the loader at 02FDD0 reads it (section count, then per
; section a bit address, a bit length and the data as longs), reached through gsp_program_ptr.
gsp_program:
	assert	*=$01907C,"gsp_program misplaced"
	incbin	"../../build/gsp/program.bin"
	assert	*=$01EFD4,"gsp_program is not 0x5F58 bytes"

; 01EFD4-020000: zero (4,140 bytes) to the end of pair R
	dcb.b	$020000-*,0

	assert	*=$020000,"programs.asm does not end at 020000"
