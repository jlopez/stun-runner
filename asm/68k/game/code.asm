; game/code.asm, 020430-04397E: the game program's code (pairs S and T).
; Owner: the game leg. Not source yet (docs/13-68k-source.md section 4).
;
; From sub_20430 to sub_43718 (043718-04397E); 0436FE-043718 is code IDA has not made a
; function (docs/06 section 4.2). The file crosses the S/T pair boundary 040000: sub_3FEA6 runs
; from 03FEA6 to 040488, so the boundary cannot be a file boundary.

	assert	*=$020430,"game/code.asm misplaced"

sub_20430:
	incbin	"../../build/stunrun-68k.bin",$020430,$04397E-$020430

	assert	*=$04397E,"game/code.asm does not end at 04397E"
