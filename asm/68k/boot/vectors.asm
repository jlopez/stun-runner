; boot/vectors.asm, 000000-000212: the boot program's vector table and the block after it.
; Owner: the boot leg. Not source yet (docs/13-68k-source.md section 4).
;
; 000000-000100: the boot vector table, vectors 0-63 (docs/05 section 3; the reset PC, 000216,
; lies in the user-vector area, so vectors 64-255 are not a table). 000100-000212: 274 bytes,
; not a vector table, unclassified (docs/06 section 4.1).

	assert	*=$000000,"boot/vectors.asm misplaced"

vec_reset_sp:
	incbin	"../../build/stunrun-68k.bin",$000000,$000100

dat_100:
	incbin	"../../build/stunrun-68k.bin",$000100,$000212-$000100

	assert	*=$000212,"boot/vectors.asm does not end at 000212"
