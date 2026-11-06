; oki.asm: 5BAC-5CB7, the OKI M6295 driver.
;
; The M6295 (okim6295.cpp) takes a two-byte start, 80 + the phrase number then the channel (bits
; 7-4, one bit per channel) and the attenuation (bits 3-0), and a one-byte stop (bits 6-3, one bit
; per channel); its status read has bits 3-0 set for the channels playing. oki_start_bits,
; oki_busy_bits and oki_stop_bits are those bits for channels 1-4. oki_reset resets the chip
; (called by init_sound); oki_tick (every eighth timed IRQ) stops a channel that has played for
; about 8.2 s and lets the YM2151 volume back up when a channel goes idle; cmdtype_13_oki_play (the
; commands of type 13, and stream op 95 with cmd_param) starts phrase effect_phrase,y on the channel
; effect_voice,y names; cmdtype_14_oki_stop (command 66) stops the channel whose current entry
; (oki_entry,x) has phrase A in effect_phrase; oki_duck_ym lowers the YM2151 volume in MIX by the
; oki_duck values of the playing channels. The tables effect_phrase, effect_voice and effect_duck,
; one byte per effect entry 00-34, are in data/sounds.asm (docs/10-adpcm.md section 4).
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.4).

    .cerror * != $5BAC, "oki.asm must start at $5BAC"

; -------------------------------------------------------------------------------------------------
; Reset the M6295 (from init_sound 423A).
;
; WRIO bit 2 low then high (the M6295's reset, active low; wrio_shadow keeps bit 2 set), then
; clears the 18 bytes 56-67: oki_time_lo, oki_time_hi, oki_duck, rx_count, rx_buffer and the three
; bytes after it, and coin_pulse+0. The LDA #01 at 5BBC is overwritten at once.
; -------------------------------------------------------------------------------------------------
oki_reset
    lda wrio_shadow
    and #$FF ^ WRIO_OKI_RUN
    sta WRIO                            ; M6295 reset (bit 2 low)
    ora #WRIO_OKI_RUN
    sta wrio_shadow
    sta WRIO                            ; and out of it
    lda #$01
    ldx #$11
    lda #$00
_clear
    sta oki_time_lo,x
    dex
    bpl _clear
    rts

; -------------------------------------------------------------------------------------------------
; The OKI tick (from h_irq 420E, every timed IRQ; acts on every eighth: oki_divider counts 7-0).
;
; For channels 4-1 (X = 3-0): playing (OKI_READ bit), count oki_time down; when it reaches 0
; (256 ticks of 8 IRQs after a start, about 8.2 s) stop the channel and set oki_time_lo to 2,
; then fall into the idle path (5BE9 into 5BEB) in the same tick. Idle, or just stopped, with
; oki_duck set: clear it and recompute MIX (oki_duck_ym), so the YM2151 volume comes back once
; the sample has ended or been stopped.
; -------------------------------------------------------------------------------------------------
oki_tick
    dec oki_divider
    bmi _run
    rts
_run
    lda #$07
    sta oki_divider
    ldx #$03
_channel
    lda oki_busy_bits,x
    and OKI_READ_M
    beq _idle
    dec oki_time_lo,x
    bne _next
    dec oki_time_hi,x
    bne _next
    lda oki_stop_bits,x                 ; played too long: stop it
    sta OKI_WRITE
    lda #$02
    sta oki_time_lo,x
_idle
    lda oki_duck,x
    beq _next
    lda #$00
    sta oki_duck,x
    jsr oki_duck_ym
_next
    dex
    bpl _channel
    rts

; op_handlers entry for stream byte $95 (sequencer.asm): the OKI start of command A, by its
; cmd_param, then cmdtype_13_oki_play
op_95
    tay
    lda cmd_param,y

; -------------------------------------------------------------------------------------------------
; Type 13: play an OKI sample (cmdtype_handlers entry 13; commands 05 and 38-6C but 66, A = the
; effect entry 00-34; also op 95).
;
; Nothing while min_priority is not 0 (5BFE). The channel is effect_voice,A bits 5-4 (X = 0-3). If
; it is playing an entry whose effect_voice bit 7 is set, the new start is dropped; else the channel
; is stopped and polled until idle (5C23-5C34), oki_entry = A, oki_time = 0100, and the start is
; written: 80 + effect_phrase,A (the phrase), then the channel bit + effect_voice,A bits 3-0 (the
; attenuation). oki_duck = effect_duck,A and oki_duck_ym lowers the YM2151 volume. Returns C set
; (for op 95); keeps X; interrupts off meanwhile.
; -------------------------------------------------------------------------------------------------
cmdtype_13_oki_play
    ldy @w min_priority
    bne _return
    php
    sei
    tay
    txa
    pha
    lda effect_voice,y
    and #$30
    lsr a
    lsr a
    lsr a
    lsr a
    tax                                 ; the channel, 0-3
    sty oki_tmp
    lda oki_busy_bits,x
    and OKI_READ_M
    beq _stop
    ldy oki_entry,x
    lda effect_voice,y
    bmi _done                           ; the entry playing may not be interrupted
_stop
    lda oki_stop_bits,x
    sta OKI_WRITE
    ldy #$7F
_delay
    nop
    dey
    bpl _delay
    lda oki_busy_bits,x
    and OKI_READ_M
    bne _stop                           ; until the channel is idle
    ldy oki_tmp
    sty oki_entry,x
    lda #$01
    sta oki_time_hi,x
    lda #$00
    sta oki_time_lo,x
    lda effect_phrase,y
    ora #OKI_PHRASE
    sta OKI_WRITE                       ; 80 + the phrase
    lda effect_voice,y
    and #$0F
    ora oki_start_bits,x
    sta OKI_WRITE                       ; the channel and the attenuation
    lda effect_duck,y
    sta oki_duck,x
    jsr oki_duck_ym
_done
    pla
    tax
    plp
_return
    sec
    rts

; read at 5C50: the channel bit of the start's second byte, channels 1-4 (okim6295.cpp 238-247)
oki_start_bits
    .byte $10, $20, $40, $80

; read at 5BD1, 5C14, 5C2F: the status bit of channels 1-4, set while playing (okim6295.cpp 220-222)
oki_busy_bits
    .byte $01, $02, $04, $08

; read at 5BE1, 5C23, 5C7F: the stop byte of channels 1-4 (okim6295.cpp 303-308)
oki_stop_bits
    .byte $08, $10, $20, $40

; -------------------------------------------------------------------------------------------------
; Type 14: stop an OKI phrase (cmdtype_handlers entry 14; command 66, A = 30, phrase 48 in docs/10's
; decimal numbering; not executed in the make sndtrace runs).
;
; A is a phrase number: the first channel from 4 down whose current entry (oki_entry,x) has
; effect_phrase = A is stopped; at most one. oki_duck stays until oki_tick sees the channel idle.
; Interrupts off meanwhile.
; -------------------------------------------------------------------------------------------------
cmdtype_14_oki_stop
    php
    sei
    ldx #$03
_channel
    ldy oki_entry,x
    cmp effect_phrase,y
    beq _stop
    dex
    bpl _channel
    plp
    rts
_stop
    lda oki_stop_bits,x
    sta OKI_WRITE
    plp
    rts

; -------------------------------------------------------------------------------------------------
; Lower the YM2151 volume for the OKI samples (from oki_tick 5BF3 and cmdtype_13_oki_play 5C5B).
;
; MIX bits 3-1 = mix_shadow's YM2151 volume - (the largest oki_duck of the four channels) / 2, at
; least 0; the other bits from mix_shadow, which is not changed. Uses oki_tmp and Y.
; -------------------------------------------------------------------------------------------------
oki_duck_ym
    lda #$00
    sta oki_tmp
    ldy #$03
_largest
    lda @w oki_duck,y
    cmp oki_tmp
    bcc _smaller
    sta oki_tmp
_smaller
    dey
    bpl _largest
    lda oki_tmp
    lsr oki_tmp
    lda mix_shadow
    and #MIX_YM_VOLUME
    lsr a
    sec
    sbc oki_tmp
    bpl _positive
    lda #$00
_positive
    asl a
    sta oki_tmp
    lda #$FF
    eor #MIX_YM_VOLUME
    and mix_shadow
    ora oki_tmp
    sta MIX
    rts

    .cerror * != $5CB8, "oki.asm must end at $5CB7"
