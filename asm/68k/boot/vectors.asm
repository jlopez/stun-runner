; boot/vectors.asm, 000000-000212: the boot program's vector table, vectors 0-63 as dc.l (docs/05 section 3: the reset PC,
; 000216, lies in the user-vector area, so vectors 64-255 are not a table), then 000100-000212,
; 274 bytes the classification leaves unknown (a jmp abs.l table no decided code reaches,
; docs/14 section 3) as one incbin slice.
; Owner: the boot naming legs (M5a, M5c-e for the boot program's tests and menus).
;
; Generated once by tools/m68k gen 000000 000212 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$000000,"boot/vectors.asm misplaced"
vec_reset_sp:
	dc.l	$FFFFC000
vec_reset_pc:
	dc.l	boot_reset
vec_bus_error:
	dc.l	boot_bus_error
vec_address_error:
	dc.l	boot_address_error
vec_illegal_instruction:
	dc.l	boot_illegal_instruction
vec_zero_divide:
	dc.l	boot_zero_divide
vec_chk:
	dc.l	boot_chk
vec_trapv:
	dc.l	boot_trapv
vec_privilege_violation:
	dc.l	boot_privilege_violation
vec_trace:
	dc.l	boot_trace
vec_line_a:
	dc.l	boot_line_a_etc
vec_line_f:
	dc.l	boot_line_a_etc
vec_reserved_12:
	dc.l	boot_line_a_etc
vec_reserved_13:
	dc.l	boot_line_a_etc
vec_format_error:
	dc.l	boot_format_error
vec_uninitialized_interrupt:
	dc.l	boot_uninitialized_interrupt
vec_reserved_16:
	dc.l	$0
vec_reserved_17:
	dc.l	$0
vec_reserved_18:
	dc.l	$0
vec_reserved_19:
	dc.l	$0
vec_reserved_20:
	dc.l	$0
vec_reserved_21:
	dc.l	$0
vec_reserved_22:
	dc.l	$0
vec_reserved_23:
	dc.l	$0
vec_spurious_interrupt:
	dc.l	boot_spurious_interrupt_etc
vec_level1_msp:
	dc.l	boot_level1_msp
vec_level2_adsp:
	dc.l	boot_level2_adsp
vec_level3_gsp:
	dc.l	boot_level3_gsp
vec_level4_sound:
	dc.l	boot_level4_sound
vec_level5_timer:
	dc.l	boot_level5_timer
vec_level6_duart:
	dc.l	boot_level6_duart
vec_level7_nmi:
	dc.l	boot_spurious_interrupt_etc
vec_trap_0:
	dc.l	boot_trap_0_etc
vec_trap_1:
	dc.l	boot_trap_0_etc
vec_trap_2:
	dc.l	boot_trap_0_etc
vec_trap_3:
	dc.l	boot_trap_0_etc
vec_trap_4:
	dc.l	boot_trap_0_etc
vec_trap_5:
	dc.l	boot_trap_0_etc
vec_trap_6:
	dc.l	boot_trap_0_etc
vec_trap_7:
	dc.l	boot_trap_0_etc
vec_trap_8:
	dc.l	boot_trap_0_etc
vec_trap_9:
	dc.l	boot_trap_0_etc
vec_trap_10:
	dc.l	boot_trap_0_etc
vec_trap_11:
	dc.l	boot_trap_0_etc
vec_trap_12:
	dc.l	boot_trap_0_etc
vec_trap_13:
	dc.l	boot_trap_0_etc
vec_trap_14:
	dc.l	boot_trap_0_etc
vec_trap_15:
	dc.l	boot_trap_0_etc
vec_reserved_48:
	dc.l	$0
vec_reserved_49:
	dc.l	$0
vec_reserved_50:
	dc.l	$0
vec_reserved_51:
	dc.l	$0
vec_reserved_52:
	dc.l	$0
vec_reserved_53:
	dc.l	$0
vec_reserved_54:
	dc.l	$0
vec_reserved_55:
	dc.l	$0
vec_reserved_56:
	dc.l	$0
vec_reserved_57:
	dc.l	$0
vec_reserved_58:
	dc.l	$0
vec_reserved_59:
	dc.l	$0
vec_reserved_60:
	dc.l	$0
vec_reserved_61:
	dc.l	$0
vec_reserved_62:
	dc.l	$0
vec_reserved_63:
	dc.l	$0
dat_100:
	incbin	"../../build/stunrun-68k.bin",$100,$112
	assert	*=$000212,"boot/vectors.asm does not end at 000212"
