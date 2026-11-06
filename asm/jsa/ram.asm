; ram.asm: the 6502's RAM, 0000-1FFF, as equates (no bytes).
;
; Each name says what the code stores there, with the instructions that write and read it
; (docs/09-sound-program.md section 10.9). A variable only sequencer.asm, data/** or lookup.asm
; use is named by the sequencer leg (M4d) and keeps its zp_XX/ram_XXXX name here until then.
;
; The track arrays (0248-085F): the sequencer runs up to 30 tracks, each a byte stream of
; data/music.asm; X = 00-1D indexes one track's byte in each array, the arrays 1E bytes apart
; (init_track, 46A5, clears or presets each for a new track). cmdtype_08_start_sound (4569)
; starts one track per entry of the sound and links it into the list of a channel (trk_link,
; chan_list). The tick (tick_sequencer, 4229) runs two sets of lists on alternate timed IRQs:
; engine 0, the lists of YM2151 channels 0-7 (chan_list+0-7, group_kind = 02), and engine 1,
; six more lists (chan_list+8-D, group_kind = 03) that no sound of this ROM uses (entry_channel, the
; list of each entry, holds 0-7 only). Several arrays mean one thing to engine 0 and another to
; engine 1; the name says the engine-0 use, the comment both.

; --- zero page

tick_count = $00                        ; +1 per timed IRQ (h_irq 41DB, 4209); bit 0 picks the
                                        ; engine (4229), AND 06 gates the glide (4834, 4DCB, 4AF8)
irq_test_mode = $01                     ; FF while the self-test waits for the timed IRQ (40F0);
                                        ; h_irq then only counts tick_count (41D7-41E3); 0 after
board_status = $02                      ; the status imm_03_send_status sends: bit 7 ROM checksum
                                        ; bad (40EA), 4 a low RAM page bad, 3 a high one (418C),
                                        ; 2 no timed IRQ (410F; set again at 453A, cleared by
                                        ; h_irq 41F3), 1 YM2151 time-out (ym_wait 503D; cleared by
                                        ; init_sound 42A0), 0 set at 453C, cleared by main_loop 414E
start_sound = $03                       ; cmdtype_08_start_sound: the sound N being started (4569);
                                        ; stored into trk_sound of each new track (4670)
; 2 bytes: where h_nmi stores a byte while nmi_mode is 0 (57FA-5805); receive_bytes points it at
; rx_buffer (5CC7-5CCE)
nmi_data_ptr = $04
stream_ptr = $06
stream_ptr_hi = $07
; 2 bytes, written from group_chip_lo/group_chip_hi by init_sound (4269-4271) and the tick
; (5043-504B): 2000 (the YM2151) for engine 0, 0000 for engine 1. No instruction reads it.
engine_chip = $08
fm_op_index = $0C                       ; the operator loop's index: 6, 4, 2, 0 (4F22-4FD2) or a
                                        ; count 3-0 over the four operators (556C, 55C8, 57A0)
ym_channel = $0D                        ; the YM2151 channel 0-7 the code is writing (tick_ym_group
                                        ; 500E-5023 counts 7 to 0; ymtimer 5890, 58C0)
ym_timed_out = $0E                      ; bit 7 set by ym_wait after 255 busy reads (5039): later
                                        ; waits return at once; cleared by init_sound (4284-429E)
chain_mute = $0F
ymtimer_active = $10                    ; 1 while the timer-A sequence of ymtimer.asm runs (588C),
                                        ; 0 when it ends (59FB) or at init (5866); the tick
                                        ; leaves channels 6 and 7 silent while it is set (4E8B)
irq_busy = $11                          ; FF while h_irq runs its tick with interrupts enabled
                                        ; (41EE-4223)
irq_again = $12                         ; a timed IRQ came in during the tick: h_irq runs the tick
                                        ; once more (41E6-41EC, 4216-421E)
; 2 bytes: cmdtype_08_start_sound's entry E, the index into the sound tables (sound_first_entry
; 4570-4584, then entry_next 4694-469F)
start_entry = $13
; 2 bytes: cmdtype_08_start_sound's pointer into the sound tables (45A9-469D)
start_ptr = $15
start_tmp = $17                         ; cmdtype_08_start_sound: the entry's priority (45BA), then
                                        ; its list head's index in trk_link (list + 1E, 4619)
                                        ; and the list walk (4641)
; 2 bytes, scratch: a pointer (the self-test 4063-4082, checksum_pages, the patch pointer of
; ymtimer_start 5892-5898, the sequencer) or two bytes of arithmetic; no meaning across routines
tmp_ptr = $19
tmp_1B = $1B                            ; scratch: checksum_pages' page count (41A9), sequencer
                                        ; arithmetic
tmp_1C = $1C                            ; scratch: a handler's parameter
                                        ; (cmdtype_04_stop_priority 43D9), the sequencer's X
                                        ; across a dispatch (5069), arithmetic
seq_tmp = $1D
min_priority = $1E                      ; 4 x the parameter of a type-00 command (438A): a track
                                        ; whose priority byte is below it is not keyed on
                                        ; (4EE3-4EE8), a type-10 sound below it does not start
                                        ; (44C5-44CA), and no OKI sample starts unless it is 0
                                        ; (5BFE); 01 sets F0, 02 sets 0, reset 0 (412B)
frame_free = $1F                        ; the first free 4-byte frame of frame_pool (1-86, never
                                        ; 0): init_frame_pool, alloc_frame, free_track_frames
; 2 bytes: the address of a frame, set by frame_address (431A-433A)
frame_ptr = $20
track_muted = $22
; 32 bytes, 23-42: the variables 06-25 of the stream ops B0-B8 (53D2, 54EE); commands 1E-23
; (cmdtype_01_set_var) set variable 06, seq_vars+0, to 0-5
seq_vars = $23
unused_43 = $43                         ; written 0 by init_sound (42C3); no instruction reads it
; the value last written to MIX (written at 42CB and 4729)
mix_shadow = $44
; the value last written to WRIO (written at 4092, 409B, 411C, 5901, 5BB5, 5DA7); bits 7-6
; select the page at 3000, which only the self-test and the dormant ymtimer path (5901) change
wrio_shadow = $45
; the value last written to YM2151 register 1B (written at 4123, 4396, 43A5, 5674); bits 7-6 are
; the YM2151's CT2 and CT1 outputs, and CT1 gates the M6295's output on the JSA II
; (atarijsa.cpp ym2151_port_w 328, update_all_volumes 630)
ym_1b_shadow = $46
rng_state = $47                         ; an 8-bit shift register, seeded 0D at reset (4146) and
                                        ; stepped by random (asl, eor 1D) on every main_loop pass
group_count = $48
; 2 bytes: ymtimer.asm's data pointer (5906-5916, read 59CB, 5A5A)
ymt_ptr = $49
ymt_count = $4B                         ; ymtimer: the steps left before ymt_ptr moves 0E bytes on
                                        ; (5AC5, 5B4B-5B5F)
ymt_phase = $4C                         ; ymtimer: 1-3, the step within a 0E-byte group (5994,
                                        ; 5AB5-5ACA, 5B5E)
ymt_toggle = $4D                        ; ymtimer: 0, channel 6 is keyed next; 1, channel 7
                                        ; (5A80-5AB3)
ymt_entry = $4E                         ; ymtimer: the type-10 parameter (5888), a tbl_65DD index
ymt_priority = $4F                      ; ymtimer: tbl_65DD+3 of the entry (X at 586E), compared
                                        ; with the lists of channels 6-7 (cmp_list_priority)
oki_tmp = $50                           ; oki.asm scratch: the entry (5C14-5C36), the largest
                                        ; oki_duck (oki_duck_ym)
oki_divider = $51                       ; oki_tick runs every eighth call: counts 7 down (5BC6-5BCF)
; 4 bytes, M6295 channels 1-4: the cmdtype_13_oki_play entry last started (5C39)
oki_entry = $52
; 4 bytes each, channels 1-4: a play-time counter, oki_time_hi:oki_time_lo, 0100 at the start
; (5C3B-5C41), counted down by oki_tick every eighth timed IRQ; at 0 the channel is stopped
; (5BD9-5BE9): about 8.2 s at most
oki_time_lo = $56
oki_time_hi = $5A
; 4 bytes, channels 1-4: how much the channel lowers the YM2151's volume while it plays
; (effect_duck, 5C56; oki_duck_ym); cleared once the channel is idle, or in the tick that stops it
; on time-out (5BE9 falls into 5BEB-5BF3)
oki_duck = $5E
rx_count = $62                          ; receive_bytes: how many bytes to wait for (5CC5)
rx_buffer = $63                         ; where receive_bytes has h_nmi store them (5CC7-5CCE)
; 4 bytes, one per RDIO input bit 3-0 (+0 bit 3, +1 coin 3, +2 coin 2, +3 coin 1): coins counted
; and not yet pulsed out (5D57); bit 7 drives a WRIO coin counter (5D95-5DA9)
coin_pulse = $67
; 4 bytes, the same inputs: a debounce timer (bits 4-0) and the time released (bits 7-5),
; 5D16-5D45
coin_debounce = $6F
coin_ticks = $73                        ; +1 per read_inputs call in the normal mode (5D5D)
coin_state = $75                        ; two bits per input (bits 7-6 coin 3, 5-4 RDIO bit 3, 3-2
                                        ; coin 1, 1-0 coin 2): the coins counted, modulo 4 (5D48-
                                        ; 5D55), or in the self-test mode the input bits (5CEF-
                                        ; 5D06); imm_01_send_inputs sends it

; the stack page (h_irq reads the pushed status at stack+3,x after TSX, 41F9)
stack = $0100

; --- RAM

; 48 bytes, a ring of at most 47 commands: the ones h_nmi queues (5834-5846) and main_loop runs
; (4171-4186)
cmd_queue = $0200
; the entry main_loop took last (4171-4180)
cmd_queue_out = $0230
; the entry h_nmi filled last (5815-581F)
cmd_queue_in = $0231
; 2 bytes: the bytes h_nmi stored while nmi_mode is 0 (57F2-57F7)
nmi_data_count = $0232
; FF: h_nmi queues commands; 0: it stores the byte at nmi_data_ptr; else it drops it
nmi_mode = $0234
; 16 bytes, a ring of at most 15 responses: the ones queue_response queues (44D0) and main_loop
; sends (4159-416E)
resp_queue = $0235
; the next entry main_loop sends
resp_queue_out = $0245
; the next free entry
resp_queue_in = $0246
; 80 when queue_response found resp_queue full (44E6)
resp_queue_full = $0247

; The track arrays, 30 bytes each (X = 00-1D).
trk_sound = $0248                       ; the sound N (start_sound, 4672); FF: ended, the tick
                                        ; frees the track (4769-4770; set by a stream byte BB and
                                        ; up, 5063, and the stop commands); FE: released, the
                                        ; track ends when its level slide does (4802-480C,
                                        ; 4A67-4A71) or at its next op 9D (5540-554B)
trk_ptr_lo = $0266                      ; the stream address, from entry_stream (4632-463A)
trk_ptr_hi = $0284
trk_pitch_lo = $02A2                    ; engine 0: the note (48F6), key_codes' index (4EEF-4F02);
trk_pitch_hi = $02C0                    ; engine 1: a note_periods word (48B9-48D7)
; 3 bytes: the time left to the next stream event; the tick subtracts trk_tempo (4791-47AB),
; a note adds its note_lengths entry to trk_wait_hi:trk_wait_lo (498F-49BC)
trk_wait_frac = $02DE
trk_wait_lo = $02FC
trk_wait_hi = $031A
; 3 bytes: the time left to the key-off, the note's wait less 2 x trk_tempo, halved for a length
; byte with bits 5-4 = 1, 7F00 for one with bit 7 (49BF-4A04); counted down at 47AE-47CB
trk_gate_frac = $0338
trk_gate_lo = $0356
trk_gate_hi = $0374
trk_length_byte = $0392                 ; the note's length byte (4A5C, 4A85-4A91): bits 3-0 a
                                        ; note_lengths index, 6 dotted, 7 tied (4A05-4A07,
                                        ; 4A8B-4A95)
trk_priority = $03EC                    ; entry_priority x 4 + 1 (4604; 0 = free track); a list
                                        ; is kept in ascending priority (4641-4653) and only its
                                        ; last track sounds; compared with min_priority through
                                        ; sounding_prio (477B-477E, 4EE3)
trk_curve_index = $040A                 ; engine 1: the level_curves index (4A24, 4C5C-4C73)
trk_scale_ptr_lo = $0428                ; engine 0: the track's patch address + 1C (55A4-55AE),
trk_scale_ptr_hi = $0446                ; the 7 bytes 4DA3-4DBC copies; engine 1: bits ops 8B
                                        ; and 9B set and clear (5213-522D)
trk_key_fraction = $0464                ; engine 0: the key fraction for YM2151 register 30+ch
                                        ; (4E32-4E46; op A6 5739, op A7 5725); engine 1: a level
                                        ; 0-F (51D1-51F2, 4BEE)
; 4 rows 1E apart, one per operator: engine 0, the operator's total level (from the patch at 5570,
; to registers 60-7F at 4D8D-4DA0, the carriers changed by op A1 5766-5779); engine 1, two
; envelope pointers (+0/+1E and +3C/+5A, init_track 4718-4725, read 4AA6, 4ACD, 4B08, 4BDF)
trk_op_tl = $0482
trk_level_offset = $04FA                ; engine 0: a signed level offset scaled into each
                                        ; operator's total level (4DAF, 4F24-4FCA; op A2, A3)
trk_reg20 = $0518                       ; engine 0: the value for YM2151 register 20+ch (patch
                                        ; byte 0, 5567; 4906; op A0 sets bits 7-6, the outputs)
trk_patch_lo = $0536
trk_patch_hi = $0554                   ; engine 0: the patch address, high byte (555F; the low
                                        ; byte is trk_patch_lo); engine 1: an envelope loop count
trk_keyon_flags = $0572                 ; engine 0: the tick's flags at each event (478B into
                                        ; key_flags): bit 7 resets the LFO before a key-on (5652,
                                        ; 4FDD-4FF8); engine 1: an envelope position
trk_penv_count = $0590
; 3 bytes, engine 0: the time to the next level-slide step (480F-4826, preset 4CD3-4CDC);
; engine 1: a pitch envelope accumulator (4B96-4BAB)
trk_slide_wait_frac = $05AE
trk_slide_wait_lo = $05CC
trk_slide_wait_hi = $05EA
; engine 0: a mode flag, tested only for zero (47F5-47F8, 4CCE-4CD1; op A8 sets it). 0: the slide
; also steps on its own timer (47F5-4829), each step presetting trk_slide_wait to note_lengths
; entry 0A and taking slide_rates entry 0A (4CD3-4CDF). Non-zero: no timed step; the slide steps
; once per note (4A74, while trk_slide_time is not 0) by slide_rates[tmp_1C AND 0F], tmp_1C the
; note's length byte (4CE3-4CE8). Engine 1: an envelope loop count
trk_slide_step = $0608
trk_tempo_lo = $0626                    ; subtracted from the waits every tick (4795, 47B7,
trk_tempo_hi = $0644                    ; 4813); op 80 sets it, op 81 adds; 1000 at the start
trk_transpose = $0662                   ; added to each note (4888; op 84 sets, op 85 adds)
trk_sync_state = $0680                  ; op 88: the group being waited for (5130-5187)
trk_sync_group = $069E                  ; op 89: the track's sync group (5182)
trk_e1_ctl = $06BC                      ; engine 1: ORed into its output (4C8E); A0 at the start,
                                        ; op 8A sets it
trk_glide_rate = $06DA                  ; op 8C: how fast trk_glide returns to 0 (4DBE-4E10)
; 2 bytes, signed: the pitch offset from the last note to the new one (489B-48AA, 48E1-48F1),
; added to the pitch (4BC8, 4E12-4E33) and moved to 0 by trk_glide_rate
trk_glide_lo = $06F8
trk_glide_hi = $0716
trk_call_frame = $0734                  ; the frame of the last op 8D (5242-5249): the return
                                        ; address, popped at a 00 length byte (4919-493E)
trk_loop_frame = $0752                  ; the frame of the last op 8E (526A-5285), popped by op 8F
trk_loop_count = $0770                  ; the repeats left of that loop (5280-5286, 5296)
; the level slide: time left (16 bits, 4CF1-4D18), rate (16 bits, signed, 4CC1-4CC6) and the
; fraction carried (4D48-4D4E); set by op A4 (52C5-52E7), op 97 and the release commands
; (time 0200, rate D000)
trk_slide_time_lo = $078E
trk_slide_time_hi = $07AC
trk_slide_rate_lo = $07CA
trk_slide_rate_hi = $07E8
trk_slide_frac = $0806
trk_acc = $0824                         ; the ops A9-B4 compute in it (52EE-53C1)
trk_test = $0842                        ; what the conditional ops B5-B8 test: trk_acc, or
                                        ; trk_acc - A after op BA (545B, 5500)
; 44 bytes: 1 + the next track of the track's list, 0 at the end (4677, 4CB1-4CBE)...
trk_link = $0860
; ...followed by the 14 list heads, 1 + the first track: 0-7 the YM2151 channels, 8-D engine 1's
; lists (group_first_chain, 4E5A, 5013)
chan_list = $087E
key_tl_offset = $088C
kind_prio = $088D
sounding_prio = $088E
trk_kind = $088F
other_level = $0893
key_note = $0895
glide_hi = $0896
glide_lo = $0897
chain_prev = $0898
cur_group_kind = $0899
other_ctl_a = $089A
other_ctl_b = $089E
key_scaling = $08A2
key_scaling_depth = $08A3
key_velocity = key_scaling + 8          ; 08AA: the velocity (4DAF-4DB2, read at 4F32)
key_flags = $08AB
cmd_target_sound = $08AC                ; cmdtype_0D_run_op: the sound whose tracks run the op
                                        ; (4529, 5099)
cmd_op_operand = $08AD                  ; cmdtype_0D_run_op: the op's operand (4518, 50AB)
; 256 bytes: the value last written to each YM2151 register (4909, 4F05, 5009, 55C3-561B, 5678,
; 56B5 and more); read back to rewrite registers 20, 30 (4EB5, 4EC7) and the levels (4FB5)
ym_shadow = $08AE
; 199 x 4 bytes, 09AE-0CC9, frames 1-C7: the frame pool (frame_address 432D, 4334); byte 0 of a
; free frame links the next; init_frame_pool chains only 1-86 (its latent fault, 42FB)
frame_pool = $09AE
