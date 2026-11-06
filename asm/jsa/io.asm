; io.asm: 5CB8-5DB4, RDIO inputs and coin counters, two immediate commands.
;
; read_inputs (every timed IRQ, from h_irq) reads the four low RDIO bits (coins 1-3 and an unused
; bit 3 in MAME's jsa_ii_ioports, live in MAME 0.289 for stunrun: hardware.asm). In the self-test
; mode (RDIO bit 7) it copies them into coin_state; otherwise count_coins debounces them, counts
; each coin into coin_state and coin_pulse and pulses the WRIO coin counters (bits 5-4), one pulse
; per coin. Two of h_nmi's immediate commands: imm_04_loopback (command 08), a loop-back of one
; byte through receive_bytes, and imm_01_send_inputs (command 03), which sends coin_state.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.6, with the MAME probe of the coins).

    .cerror * != $5CB8, "io.asm must start at $5CB8"

; -------------------------------------------------------------------------------------------------
; Command 08, immediate (imm_handlers entry 4; cmd_class 03), inside the NMI.
;
; Sends AA, takes the next byte the 68010 writes into rx_buffer (receive_bytes, A = 1), sends that
; byte back and returns to the command mode (imm_return). MAME (docs/09 section 10.2): 08 then 5A
; answered AA, 5A.
; -------------------------------------------------------------------------------------------------
imm_04_loopback
    lda #$01
    jsr receive_bytes
    lda rx_buffer
    jsr send_response
    jmp imm_return

; -------------------------------------------------------------------------------------------------
; Receive bytes from the 68010 (from imm_04_loopback 5CBA).
;
; Input: A = how many. Points nmi_data_ptr at rx_buffer, clears nmi_data_count (its low byte),
; sets nmi_mode 0 (h_nmi stores each byte), sends AA and waits until h_nmi, nesting on each new
; byte, has stored A of them. nmi_mode stays 0: the caller sets it back (imm_return).
; -------------------------------------------------------------------------------------------------
receive_bytes
    sta rx_count
    lda #>rx_buffer
    sta @w nmi_data_ptr+1
    lda #<rx_buffer
    sta @w nmi_data_ptr
    lda #$00
    sta nmi_data_count
    lda #$00
    sta nmi_mode
    lda #$AA
    jsr send_response
_wait
    lda nmi_data_count
    cmp rx_count
    bne _wait
    rts

; -------------------------------------------------------------------------------------------------
; The inputs (from h_irq 4211, every timed IRQ).
;
; RDIO bit 7 set (the self-test request): the four low RDIO bits into coin_state, each as the
; low bit of its 2-bit field (coin_field_one, coin_field_mask; X = 3-0 takes RDIO bits 0-3).
; Clear: count_coins.
; -------------------------------------------------------------------------------------------------
read_inputs
    bit RDIO_M
    bpl count_coins
    ldx #$03
    lda RDIO_M
_input
    lsr a                               ; RDIO bit 3 - X
    pha
    lda coin_field_one,x
    bcs _set
    lda #$00
_set
    eor coin_state
    and coin_field_mask,x
    eor coin_state
    sta coin_state                      ; the field = the input bit
    pla
    dex
    bpl _input
    rts

; read at 5CF4, 5D48: 1 in the coin_state field of the input X (X = 3-0: RDIO bits 0-3)
coin_field_one
    .byte $10, $40, $01, $04

; read at 5CFD, 5D50: the coin_state field of the input X
coin_field_mask
    .byte $30, $C0, $03, $0C

; -------------------------------------------------------------------------------------------------
; Count the coins and pulse the coin counters (from read_inputs 5CEB, RDIO bit 7 clear).
;
; For the inputs X = 3-0 (RDIO bits 0-3: coin 1, coin 2, coin 3, bit 3), coin_debounce,x:
; - while the input is high, bits 4-0 count down from 1F: by 1 per call down to 1A, then by 1
;   every eighth call (coin_ticks AND 7 = 7) down to 0; bits 7-5 are cleared;
; - when it goes low after fewer than 5 calls high (bits 4-0 still 1B or more), it is set back to
;   1F, no coin; otherwise bits 7-5 count the calls low, and on the eighth a coin is counted
;   unless bits 4-0 had run down to 0 (a stuck input); then 1F again.
; A coin adds 1 to its 2-bit coin_state field (modulo 4) and to coin_pulse,x. On every other call
; (coin_ticks even after the increment) one pending coin_pulse moves on: a byte at 10 or above
; drops by 10, else the first of X = 3-0 with a count starts a pulse (+ EF: 1 becomes F0). WRIO bit
; 5 (counter 2) is bit 7 of coin_pulse+0 OR +2 (RDIO bit 3, coin 2), bit 4 (counter 1) bit 7 of
; +1 OR +3 (coin 3, coin 1): each coin holds its counter for 8 steps of 2 calls (about 64 ms)
; and leaves it off for 7 more. WRIO is written on every call. MAME (docs/09 section 10.6): a
; JSA coin 1 press of 10 frames is counted 2 frames after the release (coin_state 04), WRIO bit
; 4 on for about 4 frames; coin 2 sets coin_state bits 1-0 and WRIO bit 5; coin 3 bits 7-6 and
; bit 4.
; -------------------------------------------------------------------------------------------------
count_coins
    lda RDIO_M
    ldx #$03
_input
    lsr a                               ; RDIO bit 3 - X
    pha
    lda coin_debounce,x
    and #$1F
    bcc _released
    beq _store                          ; held: count bits 4-0 down, to 0
    cmp #$1B
    bcs _count_down
    pha
    lda coin_ticks
    and #$07
    cmp #$07
    pla
    bcc _store                          ; below 1B: only every eighth call
_count_down
    sbc #$01
_store
    sta coin_debounce,x
    jmp _next
_released
    cmp #$1B
    bcs _rearm                          ; high for fewer than 5 calls: not a coin
    lda coin_debounce,x
    adc #$20                            ; bits 7-5: the calls since the release
    bcc _store
    beq _rearm                          ; bits 4-0 had reached 0: stuck, not a coin
    clc
_rearm
    lda #$1F
    sta coin_debounce,x
    bcs _next
    lda coin_field_one,x                ; a coin: its coin_state field + 1
    clc
    adc coin_state
    eor coin_state
    and coin_field_mask,x
    eor coin_state
    sta coin_state
    inc coin_pulse,x                    ; and one more counter pulse to give
_next
    pla
    dex
    bpl _input
    inc coin_ticks
    lda coin_ticks
    lsr a
    bcs _counters                       ; every other call
    lda coin_pulse
    ora coin_pulse+1
    ora coin_pulse+2
    ora coin_pulse+3
    beq _counters                       ; nothing pending
    cmp #$10
    bcc _start_pulse
    ldx #$03
_pulse_step
    lda coin_pulse,x
    beq _pulse_next
    cmp #$10
    bcc _pulse_next
    adc #$EF                            ; C set: - 10
    sta coin_pulse,x
_pulse_next
    dex
    bpl _pulse_step
    bmi _counters
_start_pulse
    ldx #$03
_find
    lda coin_pulse,x
    beq _find_next
    clc
    adc #$EF                            ; n becomes F0 + n - 1: bit 7 on
    sta coin_pulse,x
    bmi _counters
_find_next
    dex
    bpl _find
_counters
    lda coin_pulse
    ora coin_pulse+2
    asl a                               ; C: counter 2 on
    lda coin_pulse+1
    ora coin_pulse+3
    ror a                               ; bit 7: counter 2, bit 6: counter 1
    lsr a
    lsr a
    eor wrio_shadow
    and #WRIO_COUNTER2|WRIO_COUNTER1
    eor wrio_shadow
    sta wrio_shadow
    sta WRIO
    rts

; -------------------------------------------------------------------------------------------------
; Command 03, immediate (imm_handlers entry 1; cmd_class 00), inside the NMI: sends coin_state.
; MAME (docs/09 section 10.2): answered 00 before any coin, 45 after one coin each on inputs 1-3.
; -------------------------------------------------------------------------------------------------
imm_01_send_inputs
    lda coin_state
    jsr send_response
    jmp nmi_return_x

    .cerror * != $5DB5, "io.asm must end at $5DB4"
