; game/vectors.asm, 020000-020430: the game program's vector table (64 longs, installed by movec
; at 000294) as dc.l, game_entries (three jmp, docs/06 section 1.1), the zero fill to 020400 and
; 48 bytes of data: 020400 is the base movea.l #$20400,a2 loads at 042356, 020418 the table read
; at 02079A, 020D30 and 02093E (docs/06 section 4.2). 020400-020418 is zero and stays a fill
; (docs/16).
; Owner: the game naming legs (M5a-M5f).
;
; Generated once by tools/m68k gen 020000 020430 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$020000,"game/vectors.asm misplaced"
game_vec_reset_sp:
	dc.l	$0
game_vec_reset_pc:
	dc.l	game_reset
game_vec_bus_error:
	dc.l	h_bus_error
game_vec_address_error:
	dc.l	h_address_error
game_vec_illegal_instruction:
	dc.l	h_illegal_instruction
game_vec_zero_divide:
	dc.l	h_zero_divide
game_vec_chk:
	dc.l	h_chk
game_vec_trapv:
	dc.l	h_trapv
game_vec_privilege_violation:
	dc.l	h_privilege_violation
game_vec_trace:
	dc.l	h_trace_etc
game_vec_line_a:
	dc.l	h_trace_etc
game_vec_line_f:
	dc.l	h_trace_etc
game_vec_reserved_12:
	dc.l	$0
game_vec_reserved_13:
	dc.l	$0
game_vec_format_error:
	dc.l	$0
game_vec_uninitialized_interrupt:
	dc.l	$0
game_vec_reserved_16:
	dc.l	$0
game_vec_reserved_17:
	dc.l	$0
game_vec_reserved_18:
	dc.l	$0
game_vec_reserved_19:
	dc.l	$0
game_vec_reserved_20:
	dc.l	$0
game_vec_reserved_21:
	dc.l	$0
game_vec_reserved_22:
	dc.l	$0
game_vec_reserved_23:
	dc.l	$0
game_vec_spurious_interrupt:
	dc.l	h_trace_etc
game_vec_level1_msp:
	dc.l	h_trace_etc
game_vec_level2_adsp:
	dc.l	h_level2_adsp
game_vec_level3_gsp:
	dc.l	h_level3_gsp
game_vec_level4_sound:
	dc.l	h_level4_sound
game_vec_level5_timer:
	dc.l	h_level5_timer
game_vec_level6_duart:
	dc.l	h_level6_duart
game_vec_level7_nmi:
	dc.l	h_level7_nmi
game_vec_trap_0:
	dc.l	h_trace_etc
game_vec_trap_1:
	dc.l	h_trace_etc
game_vec_trap_2:
	dc.l	h_trace_etc
game_vec_trap_3:
	dc.l	h_trace_etc
game_vec_trap_4:
	dc.l	h_trace_etc
game_vec_trap_5:
	dc.l	h_trace_etc
game_vec_trap_6:
	dc.l	h_trace_etc
game_vec_trap_7:
	dc.l	h_trace_etc
game_vec_trap_8:
	dc.l	h_trace_etc
game_vec_trap_9:
	dc.l	h_trace_etc
game_vec_trap_10:
	dc.l	h_trace_etc
game_vec_trap_11:
	dc.l	h_trace_etc
game_vec_trap_12:
	dc.l	h_trace_etc
game_vec_trap_13:
	dc.l	h_trace_etc
game_vec_trap_14:
	dc.l	h_trace_etc
game_vec_trap_15:
	dc.l	h_trace_etc
game_vec_reserved_48:
	dc.l	$0
game_vec_reserved_49:
	dc.l	$0
game_vec_reserved_50:
	dc.l	$0
game_vec_reserved_51:
	dc.l	$0
game_vec_reserved_52:
	dc.l	$0
game_vec_reserved_53:
	dc.l	$0
game_vec_reserved_54:
	dc.l	$0
game_vec_reserved_55:
	dc.l	$0
game_vec_reserved_56:
	dc.l	$0
game_vec_reserved_57:
	dc.l	$0
game_vec_reserved_58:
	dc.l	$0
game_vec_reserved_59:
	dc.l	$0
game_vec_reserved_60:
	dc.l	$0
game_vec_reserved_61:
	dc.l	$0
game_vec_reserved_62:
	dc.l	$0
game_vec_reserved_63:
	dc.l	$0
game_entries:
	jmp	game_entry_1
	jmp	game_entry_2
	jmp	game_entry_3
	dcb.b	750,0
dat_20400:
	dcb.b	24,0		; zero (020400-020418)
dat_20418:
	incbin	"../../build/stunrun-68k.bin",$20418,$1
dat_20419:
	incbin	"../../build/stunrun-68k.bin",$20419,$1
dat_2041A:
	incbin	"../../build/stunrun-68k.bin",$2041A,$2
dat_2041C:
	incbin	"../../build/stunrun-68k.bin",$2041C,$14
	assert	*=$020430,"game/vectors.asm does not end at 020430"
