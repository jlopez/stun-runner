; boot/boot.asm, 000212-012F06: the boot program (pair R): code with data islands, then its data.
; Owner: the boot leg. Not source yet (docs/13-68k-source.md section 4).
;
; 000212-012DC6: 140 IDA functions, from boot_line_a_etc 000212 to sub_12DBC 012DBC-012DC6, with
; data islands such as 00FB08-01076A (docs/06 section 4.1). 012DC6-012F06: boot data, referenced
; from 00F2A4 (012DD2) and 00F2B6 (012DDE).

	assert	*=$000212,"boot/boot.asm misplaced"

boot_line_a_etc:
	incbin	"../../build/stunrun-68k.bin",$000212,$012DC6-$000212

dat_12DC6:
	incbin	"../../build/stunrun-68k.bin",$012DC6,$012F06-$012DC6

	assert	*=$012F06,"boot/boot.asm does not end at 012F06"
