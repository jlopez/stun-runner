; commands.asm: 4238-4758, command execution: the command-type handlers and their table.
;
; A queued command byte (main_loop, from cmd_queue) goes to dispatch_command: cmd_type (tables.asm)
; gives its type 00-14, cmdtype_handlers the handler, cmd_param the byte the handler gets in A. The
; handlers start sounds (cmdtype_08_start_sound: one track per entry of the sound, linked into a
; channel's list by priority), stop or release them, set the sequencer's variables and the
; priority floor, and play or stop OKI samples (oki.asm). Two immediate commands of h_nmi end here
; too (imm_02_send_count, imm_03_send_status), with send_response, which writes one byte to the
; 68010 and waits for it to be read, and queue_response, which leaves one for main_loop. Also here:
; init_sound (reset and command 00), init_track, and the pool of 4-byte frames the stream ops 8D
; and 8E (calls and loops) take their return addresses from. Some handlers are also stream ops
; (op_handlers: A5 is cmdtype_11_ym_ct, 96 calls queue_response).
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.2).

    .cerror * != $4238, "commands.asm must start at $4238"

; -------------------------------------------------------------------------------------------------
; The sound initialisation (from warm_start 4141; imm_handlers entry 0, which cmdtype_03_immediate
; runs for command 00: cmd_type 03, cmd_param 00).
;
; Resets the M6295 (oki_reset) and the frame pool, empties the response queue, clears every list
; (trk_link and chan_list) and frees every track (trk_priority 0). For engine 0 (engine 1, whose
; group_kind entry is 03, has no chip and is skipped at 4276-4278): keys off YM2151 channels 7-0
; (register 08, 427A-429C), clears ym_timed_out and board_status bit 1 (each wait gets a fresh
; time-out), resets the ymtimer state (ymtimer_reset) and writes ym_1b_shadow to register 1B. Then
; MIX 0F: YM2151 volume 7, M6295 full volume, low-pass filter off (mix_shadow too). Interrupts are
; off throughout and restored on return.
; -------------------------------------------------------------------------------------------------
init_sound
    php
    sei
    jsr oki_reset
    jsr init_frame_pool
    lda #$00
    sta resp_queue_out
    sta resp_queue_in
    sta resp_queue_full
    ldx #$2B
_clear_lists
    sta trk_link,x                      ; the 30 links and the 14 list heads
    dex
    bpl _clear_lists
    ldx #$1D
_clear_tracks
    sta trk_priority,x                  ; 0: the track is free
    sta trk_pitch_lo,x
    sta trk_pitch_hi,x
    sta trk_key_fraction,x
    sta trk_e1_ctl,x
    dex
    bpl _clear_tracks
    ldx #$01                            ; engine 1, then engine 0
_engine
    lda group_chip_lo,x
    sta engine_chip
    lda group_chip_hi,x
    sta engine_chip+1
    lda group_kind,x
    cmp #$03
    beq _next_engine                    ; engine 1: no chip
    jsr ym_wait
    ldy #YM_KEY_ON
    sty YM2151_REG
    lda #$00
    sta ym_timed_out
    jsr ym_wait
    sty YM2151_REG
    sta ym_timed_out
    jsr ym_wait
    ldy #$07
_key_off
    sta ym_timed_out
    jsr ym_wait
    sty YM2151_DATA                     ; key off channel Y: no operator bits
    dey
    bpl _key_off
    sta ym_timed_out
    lda board_status
    and #$FD                            ; bit 1: no YM2151 time-out
    sta board_status
    jsr ym_wait
    jsr ymtimer_reset
    ldy #YM_CT_LFO_WAVE
    jsr ym_wait
    sty YM2151_REG
    lda ym_1b_shadow
    sta YM2151_DATA
_next_engine
    dex
    bmi _set_mix
    jmp _engine
_set_mix
    lda #$0F
    and #$00
    sta unused_43
    lda #$00
    eor #$FF
    and #MIX_YM_VOLUME|MIX_OKI_FULL
    sta mix_shadow
    php
    sei
    sta MIX
    sta MIX
    plp
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Chain the frame pool (from init_sound 423D).
;
; The pool is 4-byte frames at frame_pool, 09AE (frame_address), numbered from 1. Links frame 1 to
; 2, 2 to 3 and so on up to C6 to C7 (byte 0 of a frame: the next free frame; the loop stops at C8
; or at the frame that would reach 1F00), then writes the terminating link 0; frame_free = 1.
; Latent fault: _last undoes the INC of the 1F00 exit with DEC frame_ptr+1 (42FB) on the normal
; exit too, where no carry happened, so frame_ptr goes from 0CC6 (frame C7) to 0BC2 and the 0 lands
; on frame 86's link (4306). The free chain is frames 1-86 (134), frames 87-C7 are never reached
; (a headless MAME probe at frame 400: frame_free 01, the chain ends at 86 after 134 frames, 0BC2 =
; 00, 0CC2 = C7). Uses frame_ptr, X; Y = 0 on return.
; -------------------------------------------------------------------------------------------------
init_frame_pool
    lda #$01
    sta frame_free
    jsr frame_address
    lda #$02
_link
    sta (frame_ptr),y                   ; this frame's link: the next one
    tax
    inx
    lda frame_ptr
    clc
    adc #$04
    sta frame_ptr
    bcc _no_carry
    inc frame_ptr+1
    lda #$1F
    cmp frame_ptr+1
    beq _last
_no_carry
    txa
    cmp #$C8
    bcc _link
_last
    dec frame_ptr+1
    lda frame_ptr
    sec
    sbc #$04
    sta frame_ptr
    lda #$00
    sta (frame_ptr),y                   ; the last frame: link 0
    rts

; -------------------------------------------------------------------------------------------------
; Take a frame from the pool (from op 8D 523C and op 8E 5264, sequencer.asm).
;
; Output: A = the frame number (Z clear) with frame_ptr at it and Y = 0, or A = 0 (Z set) when the
; free frame is the last one (its link is 0; frame 86, init_frame_pool). In that case the A pushed
; at 430E is not pulled before the RTS at 4319, so the return goes astray: a latent fault, never
; reached in the traces. Only frames 1-85 (133) can be taken; the 134th request takes that path.
; frame_free is never 0: _none does not store it.
; -------------------------------------------------------------------------------------------------
alloc_frame
    lda frame_free
    jsr frame_address
    pha
    lda (frame_ptr),y
    beq _none
    sta frame_free                      ; the next free frame
    pla
    rts
_none
    lda #$00
    rts

; -------------------------------------------------------------------------------------------------
; The address of a frame (from init_frame_pool, alloc_frame, free_track_frames, the sequencer
; 491F and op 8F 5293).
;
; Input: A = the frame number (1 up). Output: frame_ptr = frame_pool + (A - 1) x 4, Y = 0, A kept;
; tmp_ptr's low byte gets A - 1 as well.
; -------------------------------------------------------------------------------------------------
frame_address
    pha
    tay
    dey
    sty frame_ptr
    sty tmp_ptr
    ldy #$00
    sty frame_ptr+1
    asl frame_ptr
    rol frame_ptr+1
    asl frame_ptr
    rol frame_ptr+1
    lda #<frame_pool
    clc
    adc frame_ptr
    sta frame_ptr
    lda #>frame_pool
    adc frame_ptr+1
    sta frame_ptr+1
    pla
    rts

; -------------------------------------------------------------------------------------------------
; Return a track's frames to the pool (from cmdtype_08_start_sound 465E, when a new track replaces
; one of the same priority, and from the sequencer 495B, when a track ends).
;
; Input: X = the track. Pops every frame of trk_loop_frame's chain, then of trk_call_frame's, onto
; frame_free. Keeps Y.
; -------------------------------------------------------------------------------------------------
free_track_frames
    tya
    pha
_loop_frames
    lda trk_loop_frame,x
    beq _call_frames
    jsr frame_address
    pha
    lda (frame_ptr),y
    sta trk_loop_frame,x                ; the frame below it
    lda frame_free
    sta (frame_ptr),y
    pla
    sta frame_free
    jmp _loop_frames
_call_frames
    lda trk_call_frame,x
    beq _done
    jsr frame_address
    pha
    lda (frame_ptr),y
    sta trk_call_frame,x
    lda frame_free
    sta (frame_ptr),y
    pla
    sta frame_free
    jmp _call_frames
_done
    pla
    tay
    rts

; -------------------------------------------------------------------------------------------------
; Run command Y (a byte main_loop took from cmd_queue, from 4186).
;
; The handler cmdtype_handlers gives for cmd_type,y, entered by RTS with A = cmd_param,y. Y 6D and
; up (6D is what h_nmi queues for a byte that is not a command) or a type 15 and up (FF: commands
; 03, 06, 07 and 08, the immediate ones) do nothing.
; -------------------------------------------------------------------------------------------------
dispatch_command
    cpy #$6D
    bcs _ignore
    lda cmd_type,y
    cmp #$15
    bcs _ignore
    asl a
    tax
    lda cmdtype_handlers+1,x            ; the handler's address - 1, high byte first
    pha
    lda cmdtype_handlers,x
    pha
    lda cmd_param,y                     ; A: the parameter
_ignore
    rts

; -------------------------------------------------------------------------------------------------
; Type 00: set the priority floor (cmdtype_handlers entry 00; commands 01, F0, and 02, 0).
;
; min_priority = 4 x A. While it is above a track's priority byte (trk_priority, 4 x the entry's
; priority + 1) the track runs silently: its key-on, key code and levels are skipped (4EE3-4EE8);
; while it is not 0 no OKI sample starts (5BFE). The 68010 sends 01 when attract mode starts with
; "SOUNDS IN ATTRACT" off and 02 otherwise (docs/09-sound-program.md section 6). MAME (section
; 10.2): with min_priority F0 a sound of priority 3F (command 32, priority byte FD) keys on.
; -------------------------------------------------------------------------------------------------
cmdtype_00_min_priority
    asl a
    asl a
    sta min_priority
    rts

; -------------------------------------------------------------------------------------------------
; Type 11 and stream op A5: set the YM2151's CT outputs (cmdtype_handlers entry 11, no command;
; op_handlers entry A5; not executed in the make sndtrace runs).
;
; Bits 7-6 of A replace bits 7-6 of ym_1b_shadow, written to register 1B: CT2 and CT1. On the JSA
; II, CT1 gates the M6295's output (atarijsa.cpp 328, 630). Returns C set (for the op).
; -------------------------------------------------------------------------------------------------
cmdtype_11_ym_ct
    php
    sei
    pha
    lda ym_1b_shadow
    and #$3F
    sta ym_1b_shadow
    ldy #YM_CT_LFO_WAVE
    jsr ym_wait
    sty YM2151_REG
    pla
    and #$C0
    ora ym_1b_shadow
    sta ym_1b_shadow
    sta YM2151_DATA
    plp
    sec
    rts

; -------------------------------------------------------------------------------------------------
; Type 01: set a sequencer variable (cmdtype_handlers entry 01; commands 1E-23, parameters 0-5).
;
; seq_vars + (global_set_index,A AND 1F) = global_set_value,A. In this ROM global_set_index is all 0
; and global_set_value is 0-5, so commands 1E-23 set seq_vars+0, the variable 06 of the stream ops
; B0-B8, to 0-5.
; -------------------------------------------------------------------------------------------------
cmdtype_01_set_var
    tay
    lda global_set_index,y
    and #$1F
    tax
    lda global_set_value,y
    sta seq_vars,x
    rts

; -------------------------------------------------------------------------------------------------
; Type 02: add to a sequencer variable (cmdtype_handlers entry 02, no command; not executed in the
; make sndtrace runs). As cmdtype_01_set_var, but adds global_set_value,A.
; -------------------------------------------------------------------------------------------------
cmdtype_02_add_var
    tay
    lda global_set_index,y
    and #$1F
    tax
    lda global_set_value,y
    clc
    adc seq_vars,x
    sta seq_vars,x
    rts

; -------------------------------------------------------------------------------------------------
; Type 03: an immediate-command handler from main_loop (cmdtype_handlers entry 03; command 00;
; not executed in the make sndtrace runs).
;
; Runs imm_handlers entry A by RTS: command 00 has A = 0, init_sound.
; -------------------------------------------------------------------------------------------------
cmdtype_03_immediate
    asl a
    tay
    lda imm_handlers+1,y
    pha
    lda imm_handlers,y
    pha
    rts

; -------------------------------------------------------------------------------------------------
; Type 04: stop the tracks of one priority (cmdtype_handlers entry 04, no command; not executed in
; the make sndtrace runs).
;
; trk_sound = FF (the tick frees the track) for every track whose priority (trk_priority / 4)
; is A. Interrupts off meanwhile.
; -------------------------------------------------------------------------------------------------
cmdtype_04_stop_priority
    php
    sei
    sta tmp_1C
    ldy #$1D
_track
    lda trk_priority,y
    lsr a
    lsr a
    eor tmp_1C
    bne _next
    lda #$FF
    sta trk_sound,y
_next
    dey
    bpl _track
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 05: stop a command's sound (cmdtype_handlers entry 05; commands 2E, A = 2D, and 36, A = 35).
;
; A is a command number: when its type is 08, every track playing its sound (trk_sound =
; cmd_param of A) gets trk_sound FF. MAME (docs/09 section 10.2): command 2E after 2D, trk_sound
; FF at 4406.
; -------------------------------------------------------------------------------------------------
cmdtype_05_stop_sound
    php
    sei
    tay
    lda cmd_type,y
    cmp #$08
    bne _done
    lda cmd_param,y
    sta tmp_1C
    ldy #$1D
_track
    cmp trk_sound,y
    bne _next
    lda #$FF
    sta trk_sound,y
    lda tmp_1C
_next
    dey
    bpl _track
_done
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 06: stop a list (cmdtype_handlers entry 06, no command; not executed in the make sndtrace
; runs).
;
; A bits 7-4: the engine (group_first_chain: its first list in trk_link, 1E or 26), bits 3-0 the
; list: trk_sound FF for every track on that list.
; -------------------------------------------------------------------------------------------------
cmdtype_06_stop_list
    sta tmp_1C
    lsr a
    lsr a
    lsr a
    lsr a
    tay
    lda tmp_1C
    and #$0F
    clc
    adc group_first_chain,y
    tay
    php
    sei
    lda trk_link,y
    beq _done
_track
    tay
    dey
    lda #$FF
    sta trk_sound,y
    lda trk_link,y
    bne _track
_done
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 07: stop the tracks on one side (cmdtype_handlers entry 07, no command; not executed in the
; make sndtrace runs).
;
; trk_sound FF for every live track whose trk_reg20 has bit 7 (A = 0) or bit 6 (A not 0) set:
; for the YM2151 register 20 these are the right and the left output (ymfm_opm.h 196-197).
; -------------------------------------------------------------------------------------------------
cmdtype_07_stop_side
    php
    sei
    sta tmp_1C
    lda tmp_1C
    bne _left
    lda #$80
    sta tmp_1C
    bne _scan
_left
    lda #$40
    sta tmp_1C
_scan
    ldy #$1D
_track
    lda trk_priority,y
    beq _next
    lda trk_reg20,y
    and tmp_1C
    beq _next
    lda #$FF
    sta trk_sound,y
_next
    dey
    bpl _track
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 0A: release a command's sound (cmdtype_handlers entry 0A; commands 13, 15, 19, 27, 29).
;
; A is a command number: when its type is 08, every track playing its sound gets a level slide
; (trk_slide_time 0200, trk_slide_rate D000, the fraction 0) and trk_sound FE: the track plays on
; until the slide ends (4802-480C, 4A67-4A71) or its next op 9D (5540-554B), then ends. Op 97 does
; the same to its own track. MAME (docs/09 section 10.2): command 13 sets FE on the six tracks of
; command 12's sound at 448C, which end later at 4809 and 5547.
; -------------------------------------------------------------------------------------------------
cmdtype_0A_release_sound
    php
    sei
    tay
    lda cmd_type,y
    cmp #$08
    bne _done
    lda cmd_param,y
    sta tmp_1C
    ldy #$1D
_track
    cmp trk_sound,y
    bne _next
    lda #$00
    sta trk_slide_time_lo,y
    sta trk_slide_frac,y
    sta trk_slide_rate_lo,y
    lda #$D0
    sta trk_slide_rate_hi,y
    lda #$02
    sta trk_slide_time_hi,y
    lda #$FE
    sta trk_sound,y
    lda tmp_1C
_next
    dey
    bpl _track
_done
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 0B: release the tracks of one priority (cmdtype_handlers entry 0B; commands 0B, A = 27, and
; 0E, A = 29).
;
; As cmdtype_0A_release_sound, for every track whose priority (trk_priority / 4) is A. MAME
; (docs/09 section 10.2): command 0B sets FE on five tracks at 44BC.
; -------------------------------------------------------------------------------------------------
cmdtype_0B_release_priority
    php
    sei
    sta tmp_1C
    ldy #$1D
_track
    lda trk_priority,y
    lsr a
    lsr a
    eor tmp_1C
    bne _next
    lda #$00
    sta trk_slide_time_lo,y
    sta trk_slide_frac,y
    sta trk_slide_rate_lo,y
    lda #$D0
    sta trk_slide_rate_hi,y
    lda #$02
    sta trk_slide_time_hi,y
    lda #$FE
    sta trk_sound,y
_next
    dey
    bpl _track
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Type 10: start the timer-A sequence of ymtimer.asm (cmdtype_handlers entry 10, no command; not
; executed in the make sndtrace runs).
;
; Y = A, an entry of tbl_65DD; X = its priority byte tbl_65DD+3,y. Below min_priority, nothing;
; else ymtimer_start.
; -------------------------------------------------------------------------------------------------
cmdtype_10_ymtimer
    tay
    ldx tbl_65DD+3,y
    cpx min_priority
    bcc _below_floor
    jmp ymtimer_start
_below_floor
    rts

; -------------------------------------------------------------------------------------------------
; Queue a response (cmdtype_handlers entry 09, command 09 with A = 55; from op 96 550E; not
; executed in the make sndtrace runs).
;
; Puts A in resp_queue for main_loop to send. When the queue is full, the byte is dropped and
; resp_queue_full set to 80.
; -------------------------------------------------------------------------------------------------
queue_response
    ldy resp_queue_in
    sta resp_queue,y
    iny
    cpy #$10
    bcc _no_wrap
    ldy #$00
_no_wrap
    cpy resp_queue_out
    beq _full
    sty resp_queue_in
    rts
_full
    lda #$80
    sta resp_queue_full
    rts

; -------------------------------------------------------------------------------------------------
; Type 0D: run a stream op on a sound's tracks (cmdtype_handlers entry 0D, no command; not executed
; in the make sndtrace runs).
;
; X = A, an entry of tbl_65DD: the op tbl_65DD+5 (an op_handlers index; 3B and up, and the
; indexes 08-09, 0D-11 and 16-18, the ops 88, 89, 8D-91 and 96-98, refused at 44ED-450A for a
; reason the code does not show: 89, 96 and 97 do not move the stream), its operand
; tbl_65DD+6 (cmd_op_operand), a command tbl_65DD+7 whose type must be 08 (its parameter is
; cmd_target_sound) and a list tbl_65DD+8 (+ 1E, an index into trk_link). chain_run_op runs the op
; on every track of that list playing cmd_target_sound.
; -------------------------------------------------------------------------------------------------
cmdtype_0D_run_op
    tax
    lda tbl_65DD+5,x
    cmp #$3B
    bcs _refused
    cmp #$08
    bcc _allowed
    cmp #$0A
    bcc _refused
    cmp #$0D
    bcc _allowed
    cmp #$12
    bcc _refused
    cmp #$16
    bcc _allowed
    cmp #$19
    bcc _refused
_allowed
    asl a
    tay
    lda tbl_65DD+8,x
    clc
    adc #$1E
    pha
    lda tbl_65DD+6,x
    sta cmd_op_operand
    lda tbl_65DD+7,x
    tax
    lda cmd_type,x
    cmp #$08
    bne _not_a_sound
    lda cmd_param,x
    sta cmd_target_sound
    pla
    tax
    jmp chain_run_op
_not_a_sound
    pla
_refused
    rts

; -------------------------------------------------------------------------------------------------
; Command 07, immediate (imm_handlers entry 3; cmd_class 02).
;
; Sends board_status, then sets its bits 0 and 2, which main_loop (414C) and the timed IRQ (41F3)
; clear: the next 07 tells whether both still run. Bit 1 is set by ym_wait on a YM2151 time-out,
; bits 7, 4, 3 and 2 by the self-test. Leaves through imm_return. MAME (docs/09 section 10.2): 07
; answered 00 twice.
; -------------------------------------------------------------------------------------------------
imm_03_send_status
    lda board_status
    jsr send_response
    lda board_status
    ora #$04
    ora #$01
    sta board_status
    jmp imm_return

; -------------------------------------------------------------------------------------------------
; Command 06, immediate (imm_handlers entry 2; cmd_class 01): sends 6D, the number of command
; bytes the tables cover, then falls into imm_return. MAME (docs/09 section 10.2): answered 6D.
; -------------------------------------------------------------------------------------------------
imm_02_send_count
    lda #$6D
    jsr send_response

; -------------------------------------------------------------------------------------------------
; The way out of an immediate command (from imm_03_send_status 4540, imm_02_send_count and
; imm_04_loopback 5CC2): pulls X and Y, which h_nmi pushed, sets nmi_mode back to FF (the command
; mode), pulls A and returns from the NMI.
; -------------------------------------------------------------------------------------------------
imm_return
    pla
    tax
    pla
    tay
    lda #$FF
    sta nmi_mode
    pla
    rti

; -------------------------------------------------------------------------------------------------
; Send A to the 68010 now (from the immediate commands 4535, 4545, 5CBF, 5CDD, 5DAF).
;
; Waits until RDIO bit 5 (output buffer full) is clear, writes RESP_TO_68K, waits until the 68010
; has read it. Keeps A. main_loop sends queued responses without waiting.
; -------------------------------------------------------------------------------------------------
send_response
    pha
    lda #RDIO_RESP_FULL
_wait_empty
    and RDIO_M
    bne _wait_empty
    pla
    pha
    sta RESP_TO_68K
    lda #RDIO_RESP_FULL
_wait_read
    and RDIO_M
    bne _wait_read
    pla
    rts

; -------------------------------------------------------------------------------------------------
; Type 08: start a sound (cmdtype_handlers entry 08; 32 commands, A = the sound N, 00-1F).
;
; start_entry = sound_first_entry word N (4569-4584), the sound's first entry E. When
; sound_restartable,N is 0 (it is FF for every N in this ROM) a sound already playing is not started
; again (458D-459C). Then for E and each next entry entry_next gives until 0 (467B-46A1):
; - a free track (trk_priority 0, 459F-45A6); if none, the first track of the entry's list
;   (entry_channel + 1E in trk_link: the lowest priority there) when its priority is not above the
;   entry's (45A9-45E9), else the start ends there (C set);
; - init_track; trk_priority = entry_priority,E x 4 + 1; trk_ptr = entry_stream word E, the stream;
; - linked into its list in ascending priority (4641-4679); a track of the same priority is
;   replaced (its frames freed, its trk_priority 0); trk_sound = N.
; A track taken from a list (45E4-45E9) keeps its frames, which init_track forgets: they are not
; returned to the pool (compare 465A-4664).
; -------------------------------------------------------------------------------------------------
cmdtype_08_start_sound
    sta start_sound
    tay
    asl a
    tax
    bcs _high_half
    lda sound_first_entry,x
    bcc _entry_lo
_high_half
    lda sound_first_entry+$100,x
_entry_lo
    sta start_entry
    bcs _high_half_hi
    lda sound_first_entry+1,x
    bcc _entry_hi
_high_half_hi
    lda sound_first_entry+$101,x
_entry_hi
    sta start_entry+1
    lda sound_restartable,y
    bne _next_entry
    lda start_sound                     ; sound_restartable = 0: is the sound playing?
    ldy #$1D
_playing
    cmp trk_sound,y
    bne _not_this
    lda trk_priority,y
    beq _restore_n
    rts                                 ; yes: do not start it again
_restore_n
    lda start_sound
_not_this
    dey
    bpl _playing
_next_entry
    ldy #$1D
_find_free
    lda trk_priority,y
    beq _take_track
    dey
    bpl _find_free
    ldy #$00                            ; no free track: the head of the entry's list
    lda #<entry_priority
    clc
    adc start_entry
    sta start_ptr
    lda #>entry_priority
    adc start_entry+1
    sta start_ptr+1
    lda (start_ptr),y
    sta start_tmp                       ; the entry's priority
    lda #<entry_channel
    clc
    adc start_entry
    sta start_ptr
    lda #>entry_channel
    adc start_entry+1
    sta start_ptr+1
    lda (start_ptr),y
    clc
    adc #$1E
    tax                                 ; its list head in trk_link
    php
    sei
    ldy trk_link,x
    beq _give_up                        ; an empty list: nothing to take
    dey
    lda start_tmp
    asl a
    sec
    rol a
    cmp trk_priority,y
    bcs _steal
_give_up
    plp
    sec
    rts
_steal
    lda trk_link,y                      ; unlink the list's first track and take it
    sta trk_link,x
    plp
_take_track
    tya
    tax
    jsr init_track
    ldy #$00
    lda #<entry_priority
    clc
    adc start_entry
    sta start_ptr
    lda #>entry_priority
    adc start_entry+1
    sta start_ptr+1
    lda (start_ptr),y
    asl a
    sec
    rol a
    sta trk_priority,x                  ; priority x 4 + 1
    lda #<entry_channel
    clc
    adc start_entry
    sta start_ptr
    lda #>entry_channel
    adc start_entry+1
    sta start_ptr+1
    lda (start_ptr),y
    clc
    adc #$1E
    sta start_tmp                       ; the list head in trk_link
    lda start_entry
    asl a
    sta start_ptr
    lda start_entry+1
    rol a
    sta start_ptr+1
    lda #<entry_stream
    clc
    adc start_ptr
    sta start_ptr
    lda #>entry_stream
    adc start_ptr+1
    sta start_ptr+1
    lda (start_ptr),y
    sta trk_ptr_lo,x                    ; the stream
    iny
    lda (start_ptr),y
    sta trk_ptr_hi,x
    ldy start_tmp
    php
    sei
_walk
    sty start_tmp                       ; the link to update
    lda trk_link,y
    beq _link_in
    tay
    dey
    lda trk_priority,y
    ora #$01
    cmp trk_priority,x
    bcc _walk                           ; lower priority: further on
    beq _replace
    iny                                 ; higher: insert before it
    tya
    bcs _set_next
_replace
    txa                                 ; the same priority: the new track replaces it
    pha
    tya
    tax
    jsr free_track_frames
    pla
    tax
    lda #$00
    sta trk_priority,y
    lda trk_link,y
_set_next
    sta trk_link,x
    ldy start_tmp
_link_in
    lda start_sound
    sta trk_sound,x
    inx
    txa
    sta trk_link,y
    plp
    ldy #$00
    lda start_entry
    asl a
    sta start_ptr
    lda start_entry+1
    rol a
    sta start_ptr+1
    lda #<entry_next
    clc
    adc start_ptr
    sta start_ptr
    lda #>entry_next
    adc start_ptr+1
    sta start_ptr+1
    lda (start_ptr),y
    sta start_entry                     ; the next entry
    iny
    ora (start_ptr),y
    beq cmdtype_none
    lda (start_ptr),y
    sta start_entry+1
    jmp _next_entry

; -------------------------------------------------------------------------------------------------
; Types 0C, 0F and 12 (cmdtype_handlers, no command), and the end of cmdtype_08_start_sound: return.
; -------------------------------------------------------------------------------------------------
cmdtype_none
    rts

; -------------------------------------------------------------------------------------------------
; Preset track X for a new stream (from cmdtype_08_start_sound 45ED).
;
; trk_key_fraction 07, trk_tempo 1000, trk_e1_ctl A0, trk_scale_ptr 00FF, the four trk_op_tl rows
; (engine 1's two envelope pointers) at empty_envelope, everything else of the track 0: the waits
; and the gate, the length byte, the link, the transpose, the glide, the frames, the slide, the
; sync, trk_acc and trk_test.
; -------------------------------------------------------------------------------------------------
init_track
    lda #$07
    sta trk_key_fraction,x
    lda #$10
    sta trk_tempo_hi,x
    lda #$A0
    sta trk_e1_ctl,x
    lda #$FF
    sta trk_scale_ptr_lo,x
    lda #$00
    sta trk_tempo_lo,x
    sta trk_scale_ptr_hi,x
    sta trk_link,x
    sta trk_transpose,x
    sta trk_wait_frac,x
    sta trk_wait_lo,x
    sta trk_wait_hi,x
    sta trk_glide_rate,x
    sta trk_loop_count,x
    sta trk_glide_lo,x
    sta trk_glide_hi,x
    sta trk_call_frame,x
    sta trk_loop_frame,x
    sta trk_gate_frac,x
    sta trk_gate_lo,x
    sta trk_gate_hi,x
    sta trk_length_byte,x
    sta trk_slide_time_lo,x
    sta trk_slide_time_hi,x
    sta trk_slide_wait_frac,x
    sta trk_slide_wait_lo,x
    sta trk_slide_wait_hi,x
    sta trk_acc,x
    sta trk_test,x
    sta trk_sync_group,x
    sta trk_sync_state,x
    sta trk_keyon_flags,x
    sta trk_slide_step,x
    sta trk_level_offset,x
    sta trk_patch_hi,x
    sta trk_curve_index,x
    lda #<empty_envelope
    sta trk_op_tl,x
    sta trk_op_tl+$3C,x
    lda #>empty_envelope
    sta trk_op_tl+$1E,x
    sta trk_op_tl+$5A,x
    rts

; -------------------------------------------------------------------------------------------------
; Type 0E: set MIX (cmdtype_handlers entry 0E, no command; not executed in the make sndtrace
; runs): mix_shadow = MIX = A.
; -------------------------------------------------------------------------------------------------
cmdtype_0E_set_mix
    sta mix_shadow
    sta MIX
    rts

; read at 437E, 4382
; The 21 command-type handlers, each word the handler's address - 1 (dispatch_command pushes it
; and returns into it). Types 0C, 0F and 12 share cmdtype_none, which returns at once.
cmdtype_handlers
    .word cmdtype_00_min_priority-1     ; $00
    .word cmdtype_01_set_var-1          ; $01
    .word cmdtype_02_add_var-1          ; $02
    .word cmdtype_03_immediate-1        ; $03
    .word cmdtype_04_stop_priority-1    ; $04
    .word cmdtype_05_stop_sound-1       ; $05
    .word cmdtype_06_stop_list-1        ; $06
    .word cmdtype_07_stop_side-1        ; $07
    .word cmdtype_08_start_sound-1      ; $08
    .word queue_response-1              ; $09
    .word cmdtype_0A_release_sound-1    ; $0A
    .word cmdtype_0B_release_priority-1 ; $0B
    .word cmdtype_none-1                ; $0C
    .word cmdtype_0D_run_op-1           ; $0D
    .word cmdtype_0E_set_mix-1          ; $0E
    .word cmdtype_none-1                ; $0F
    .word cmdtype_10_ymtimer-1          ; $10
    .word cmdtype_11_ym_ct-1            ; $11
    .word cmdtype_none-1                ; $12
    .word cmdtype_13_oki_play-1         ; $13
    .word cmdtype_14_oki_stop-1         ; $14

    .cerror * != $4759, "commands.asm must end at $4758"
