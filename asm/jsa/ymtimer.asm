; ymtimer.asm: 585E-5BAB, YM2151 channels 6-7 driven by the YM2151 timer interrupt.
;
; A sequence of register writes paced by the YM2151's timer A instead of the timed IRQ. The way in
; is ymtimer_start (from cmdtype_10_ymtimer, 44CC): it loads ymtimer_patch into YM2151 channels 6
; and 7, sets their outputs, turns the low-pass filter on (MIX bit 5), selects the page at 3000
; (WRIO bits 7-6 from tbl_65DD+4), points ymt_ptr at the data a word of tbl_65DD gives, writes the
; channels' key codes and attack rates from it and starts timer A. Each timer A interrupt
; (ymtimer_irq, from h_irq) then keys channel 6 or 7 on in turn, sets the next period and writes
; the operator registers from the data, in groups of 0E bytes; a 0 byte ends it: both channels
; off, the filter off, timer A stopped, and the patches of the tracks the lists of channels 6 and
; 7 hold reloaded. While ymtimer_active is set the sequencer leaves channels 6 and 7 silent (4E8B).
;
; None of this ran in the make sndtrace runs: no command has type 10, so ymtimer_start is never
; entered, and init_sound only resets the state (ymtimer_reset). tbl_65DD is 9 zero bytes before
; the first stream (for entry 0 the data pointer would be 0000), so what data this path was meant
; to read is not in the table (docs/09 section 10.5). Whether the 68010 has a use for it is a
; question for M5.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.5).

    .cerror * != $585E, "ymtimer.asm must start at $585E"

; -------------------------------------------------------------------------------------------------
; Reset the timer-A sequence's state (from init_sound 42A9): ymt_phase, ymt_count, ymt_toggle and
; ymtimer_active 0.
; -------------------------------------------------------------------------------------------------
ymtimer_reset
    lda #$00
    sta ymt_phase
    sta ymt_count
    sta ymt_toggle
    sta ymtimer_active
    rts

; -------------------------------------------------------------------------------------------------
; Start the timer-A sequence (from cmdtype_10_ymtimer 44CC; not executed in the make sndtrace
; runs).
;
; Input: X = the priority byte (tbl_65DD+3 of the entry), Y = the entry. Nothing if a sequence
; runs already, or if the last track of channel 6's or 7's list has a higher priority
; (cmp_list_priority; it is entered with X = the list head, 1 + the track, where the other walk,
; 5A0C-5A11, first subtracts 1: it starts one track off). Else, with interrupts off:
; - ymt_entry = Y, ymtimer_active = 1;
; - channels 6 and 7: ymtimer_patch through sub_55B4 (sequencer.asm), then register 20+ch from
;   ym_shadow with bits 7-6 (the outputs) from tbl_65DD+2 bits 5-4 (channel 6) and 1-0 (channel 7);
; - MIX with bit 5 (low-pass filter) set, mix_shadow unchanged;
; - wrio_shadow bits 7-6 cleared and tbl_65DD+4 ORed in (the page at 3000; the byte is ORed whole,
;   so it could set any WRIO bit), written to WRIO;
; - ymt_ptr = the word tbl_65DD + 2 x the entry; its first byte to registers 2E and 2F (the key
;   codes of channels 6 and 7), the second to the eight KS/AR registers of the two channels;
; - ymt_phase 1, registers 10 = 00 and 11 = 0A (timer A period 002: register 11 holds bits 1-0
;   only), timer A loaded with its IRQ on (register 14 = 15).
; Uses ymt_priority as scratch after the checks.
; -------------------------------------------------------------------------------------------------
ymtimer_start
    lda ymtimer_active
    beq _check
    rts
_check
    stx ymt_priority
    php
    sei
    ldx chan_list+6
    beq _check_7
    jsr cmp_list_priority
    bcs _check_7
_refuse
    plp
    rts
_check_7
    ldx chan_list+7
    beq _start
    jsr cmp_list_priority
    bcc _refuse
_start
    sty ymt_entry
    lda #$01
    sta ymtimer_active
    lda #$06
    sta ym_channel
    lda #<ymtimer_patch
    sta tmp_ptr
    lda #>ymtimer_patch
    sta tmp_ptr+1
    jsr sub_55B4                        ; the patch into channel 6
    clc
    lda #YM_CONNECT
    adc #$06
    tay
    jsr ym_wait
    sty YM2151_REG
    ldx ymt_entry
    lda tbl_65DD+2,x
    and #$30
    asl a
    asl a
    sta ymt_priority                    ; bits 5-4 as bits 7-6: channel 6's outputs
    lda ym_shadow,y
    and #$3F
    ora ymt_priority
    sta YM2151_DATA
    lda #$07
    sta ym_channel
    lda #<ymtimer_patch
    sta tmp_ptr
    lda #>ymtimer_patch
    sta tmp_ptr+1
    jsr sub_55B4                        ; the patch into channel 7
    clc
    lda #YM_CONNECT
    adc #$07
    tay
    jsr ym_wait
    sty YM2151_REG
    ldx ymt_entry
    lda tbl_65DD+2,x
    asl a
    asl a
    asl a
    asl a
    asl a
    asl a
    sta ymt_priority                    ; bits 1-0 as bits 7-6: channel 7's outputs
    lda ym_shadow,y
    and #$3F
    ora ymt_priority
    sta YM2151_DATA
    lda #MIX_LPF
    ora mix_shadow
    sta MIX                             ; low-pass filter on
    sta MIX
    lda wrio_shadow
    and #$FF ^ WRIO_BANK
    ora tbl_65DD+4,x
    sta wrio_shadow
    sta WRIO                            ; the page at 3000
    lda ymt_entry
    asl a
    tax
    lda tbl_65DD,x
    sta ymt_ptr
    lda tbl_65DD+1,x
    sta ymt_ptr+1
    ldy #$00
    lda (ymt_ptr),y
    ldx #YM_KEY_CODE+6
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KEY_CODE+7
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    inc ymt_ptr
    bne _attack
    inc ymt_ptr+1
_attack
    lda (ymt_ptr),y
    ldx #YM_KS_AR+6
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$08+6
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$10+6
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$18+6
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+7
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$08+7
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$10+7
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #YM_KS_AR+$18+7
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    inc ymt_ptr
    bne _timer
    inc ymt_ptr+1
_timer
    lda #$01
    sta ymt_phase
    lda #$00
    ldx #YM_TIMER_A_HI
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$0A
    inx
    jsr ym_wait
    stx YM2151_REG                      ; YM_TIMER_A_LO
    sta YM2151_DATA
    lda #YM_TIMER_A_RUN
    ldx #YM_TIMER_CTRL
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    plp
    rts

; -------------------------------------------------------------------------------------------------
; The timer A interrupt (from h_irq 41D1; not executed in the make sndtrace runs).
;
; No sequence running: stop the timer (register 14 = 14). Else, the byte at (ymt_ptr):
; - 0, the end: key channels 6 and 7 off, MIX bit 5 (the filter) off, the state cleared; for each
;   of channels 6 and 7 whose list holds a track, sub_559A reloads the patch of its last track
;   (fm_op_index, tmp_ptr, ym_channel and tmp_1C saved around it); timer A stopped.
; - else a step: timer A's period from the group's byte 1 (register 10, 11 = 0), reloaded; key on
;   channel 6 (ymt_toggle 0) or 7 (1), all four operators, after a key-off write; on phase 1 the
;   group's byte 0 is the step count (ymt_count); on phases 1 and 2 the 12 bytes 2-0D go to the
;   DT1/MUL, total level and DT2/D2R registers of the four operators of the channel just keyed
;   (ymtimer_write); phase 3 writes nothing more. When ymt_count runs out, ymt_ptr moves on 0E
;   bytes (the next group) and the phase is 1 again.
; Keeps Y.
; -------------------------------------------------------------------------------------------------
ymtimer_irq
    tya
    pha
    lda ymtimer_active
    bne _running
    jmp _stop_timer
_running
    ldy #$00
    lda (ymt_ptr),y
    beq _end
    jmp _step
_end
    ldx #$06
    lda #YM_KEY_ON
    jsr ym_wait
    sta YM2151_REG
    stx YM2151_DATA                     ; channel 6 off
    ldx #$07
    jsr ym_wait
    stx YM2151_DATA                     ; channel 7 off
    lda #MIX_LPF
    eor #$FF
    and mix_shadow
    sta MIX                             ; low-pass filter off
    sta MIX
    lda #$00
    sta ymt_count
    sta ymt_phase
    sta ymt_toggle
    sta ymtimer_active
    lda tmp_1C
    pha
    lda fm_op_index
    pha
    lda tmp_ptr
    pha
    lda tmp_ptr+1
    pha
    lda ym_channel
    pha
    ldx chan_list+6
    beq _channel_7
    dex
_last_6
    lda trk_link,x
    beq _reload_6
    tax
    dex
    jmp _last_6
_reload_6
    lda #$06
    sta ym_channel
    jsr sub_559A                        ; the last track's patch into channel 6
_channel_7
    ldx chan_list+7
    beq _restore
    dex
_last_7
    lda trk_link,x
    beq _reload_7
    tax
    dex
    jmp _last_7
_reload_7
    lda #$07
    sta ym_channel
    jsr sub_559A                        ; the last track's patch into channel 7
_restore
    pla
    sta ym_channel
    pla
    sta tmp_ptr+1
    pla
    sta tmp_ptr
    pla
    sta fm_op_index
    pla
    sta tmp_1C
_stop_timer
    lda #YM_TIMER_A_STOP
    ldx #YM_TIMER_CTRL
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    jmp _return
_step
    iny
    lda (ymt_ptr),y
    ldx #YM_TIMER_A_HI
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA                     ; the period, byte 1 of the group
    lda #$00
    inx
    jsr ym_wait
    stx YM2151_REG                      ; YM_TIMER_A_LO
    sta YM2151_DATA
    lda #YM_TIMER_A_RUN
    ldx #YM_TIMER_CTRL
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda ymt_toggle
    bne _key_7
    lda #$06
    ldx #YM_KEY_ON
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA                     ; channel 6 off
    lda #$78|6
    jsr ym_wait
    sta YM2151_DATA                     ; and on, all four operators
    inc ymt_toggle
    jmp _phase
_key_7
    lda #$07
    ldx #YM_KEY_ON
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA                     ; channel 7 off
    lda #$78|7
    jsr ym_wait
    sta YM2151_DATA                     ; and on
    dec ymt_toggle
_phase
    lda #$03
    cmp ymt_phase
    bne _phase_1_2
    jmp _count
_phase_1_2
    lda #$01
    cmp ymt_phase
    bne _operators
    dey
    lda (ymt_ptr),y
    sta ymt_count                       ; phase 1: byte 0, the steps of the group
    iny
_operators
    inc ymt_phase
    lda ymt_toggle
    beq _channel_7_regs
    ldx #YM_DT1_MUL+6                   ; channel 6, just keyed
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$08+6
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$10+6
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$18+6
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+6
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$08+6
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$10+6
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$18+6
    jsr ymtimer_write
    ldx #YM_DT2_D2R+6
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$08+6
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$10+6
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$18+6
    jsr ymtimer_write
    jmp _count
_channel_7_regs
    ldx #YM_DT1_MUL+7                   ; channel 7, just keyed
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$08+7
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$10+7
    jsr ymtimer_write
    ldx #YM_DT1_MUL+$18+7
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+7
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$08+7
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$10+7
    jsr ymtimer_write
    ldx #YM_TOTAL_LEVEL+$18+7
    jsr ymtimer_write
    ldx #YM_DT2_D2R+7
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$08+7
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$10+7
    jsr ymtimer_write
    ldx #YM_DT2_D2R+$18+7
    jsr ymtimer_write
_count
    dec ymt_count
    bne _return
    lda ymt_ptr                         ; the group is done: the next one, 0E bytes on
    clc
    adc #$0E
    sta ymt_ptr
    lda ymt_ptr+1
    adc #$00
    sta ymt_ptr+1
    lda #$01
    sta ymt_phase
_return
    pla
    tay
    rts

; -------------------------------------------------------------------------------------------------
; Write the next data byte to a register (from ymtimer_irq 5AD2-5B48; not executed in the make
; sndtrace runs): Y + 1, register X = (ymt_ptr),y.
; -------------------------------------------------------------------------------------------------
ymtimer_write
    iny
    lda (ymt_ptr),y
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    rts

; -------------------------------------------------------------------------------------------------
; Compare with a list's last track (from ymtimer_start 5877, 5883, and itself; not executed in the
; make sndtrace runs).
;
; Follows trk_link from track X to the track whose link is 0, then compares ymt_priority OR 1 with
; its trk_priority: C set when not below it. The callers pass the list head (1 + the first track)
; as X, one more than the track (see ymtimer_start).
; -------------------------------------------------------------------------------------------------
cmp_list_priority
    lda trk_link,x
    beq _last
    tax
    dex
    jmp cmp_list_priority
_last
    lda ymt_priority
    ora #$01
    cmp trk_priority,x
    rts

; read through tmp_ptr by sub_55B4 (5892-5898, 58C2-58C8): the patch ymtimer_start loads into
; channels 6 and 7. Its layout is the sequencer's patch layout: sub_55B4 (55B4) writes a patch to
; the YM2151, and 5553-5584 reads byte 0 as trk_reg20 and bytes 5 + 6k as the four trk_op_tl rows
ymtimer_patch
    .byte $C7, $00, $00, $00, $02, $7F, $19
    .byte $9F, $DF, $0A, $0D, $7F, $19, $9F
    .byte $1F, $0A, $05, $7F, $19, $9F, $DF
    .byte $0A, $0E, $7F, $19, $9F, $DF, $0A
    .byte $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $80, $00, $00, $00, $00

    .cerror * != $5BAC, "ymtimer.asm must end at $5BAB"
