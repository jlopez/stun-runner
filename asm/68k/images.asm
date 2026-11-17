; images.asm, 060000-0BFE00: the packed GSP images (pairs U, V, W), then zero.
; Owner: the images leg (M5i, docs/15-gsp-images.md). Source: data/gsp-images.
;
; 060000 to the end of the last stream: tools/gspimages asm writes ../../build/gsp-images/images.asm
; from the committed data alone (the manifest and one indexed PNG per image): the 54 streams
; unpack_gsp_image (0225E4) streams into HSTDATA, re-encoded from the PNGs' pixel indices, each
; with its label gsp_image_NN (NN its first table entry) and an assert, and the three
; checksum-adjust words gsp_images_sum_u/v/w, computed so that each chip's byte sum is the one
; the boot self-test expects (table 005FF6, compared at 0060F4 and 00615A; docs/15 section 5).
; The file crosses the pair boundaries 080000 and 0A0000, which are not image boundaries: the
; include asserts them inside the streams. Nothing here reads build/stunrun-68k.bin.

	assert	*=$060000,"images.asm misplaced (pair U)"

dat_60000:
	include	"../../build/gsp-images/images.asm"

; the end of the last stream to 0BFE00: zero
	dcb.b	$0BFE00-*,0

	assert	*=$0BFE00,"images.asm does not end at 0BFE00"
