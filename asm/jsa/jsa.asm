; S.T.U.N. Runner (rev 6), JSA II 6502 sound program: 136070-2123.10c, 64 KB.
;
; File offsets 0000-3FFF are four 4 KB pages that the 6502 sees one at a time at 3000-3FFF
; (/WRIO bits 7-6); 4000-FFFF is mapped at its own address (docs/01-hardware.md section 6).
;
; Milestone 1 zero point: .binary slices of build/stunrun-jsa.bin, copied as is from the file
; by tools/merge-roms. M4 turns them into source (the pages with .logical $3000). Assembled with
; 64tass -q -C -b (docs/04-build.md).

IMAGE = "../../build/stunrun-jsa.bin"
	.cerror len(binary(IMAGE)) != $10000, "build/stunrun-jsa.bin is not 64 KB"

* = $0000

bank0	.binary IMAGE, $0000, $1000	; page 0, seen at $3000-$3FFF
	.cerror * != $1000, "bank 1 misplaced"
bank1	.binary IMAGE, $1000, $1000	; page 1
	.cerror * != $2000, "bank 2 misplaced"
bank2	.binary IMAGE, $2000, $1000	; page 2
	.cerror * != $3000, "bank 3 misplaced"
bank3	.binary IMAGE, $3000, $1000	; page 3
	.cerror * != $4000, "the $4000-$FFFF window misplaced"
window	.binary IMAGE, $4000, $C000	; 4000-FFFF, at its own address
	; the program counter wraps from $FFFF to $0000 after the last byte
	.cerror * != $0000, "6502 image does not end at $FFFF"
