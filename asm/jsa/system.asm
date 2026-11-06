; system.asm: 4000-4237, reset, power-up self-test, main loop, IRQ handler.
;
; reset (the reset vector) starts the board: self_test when RDIO bit 7 asks for it, then
; init_board, which sends the 68010 FF to say the board is up, and warm_start, which runs
; init_sound and falls into main_loop: one queued command and one queued response per pass.
; h_irq (the IRQ vector) serves the two interrupt sources atarijsa.cpp ORs into the 6502's IRQ:
; the YM2151's (timer A flag, bit 0 of its status: ymtimer_irq) and the timed one (about 250 Hz,
; acknowledged by reading IRQ_ACK_M), which runs the sequencer, the OKI driver and the inputs.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.1).

    .cerror * != $4000, "system.asm must start at $4000"

; -------------------------------------------------------------------------------------------------
; The reset vector.
;
; Pulses the YM2151's reset (WRIO bit 0 low, 4005-4011) with every other WRIO bit 0: bank 0, the
; M6295 held in reset. Then RDIO bit 7: clear, the normal start, which clears the zero page and
; goes to init_board; set, self_test. In MAME 0.289 RDIO bit 7 always reads 0 (hardware.asm), so
; the self-test never runs there.
;
; Input: none. Output: the zero page cleared, X = 0. Never returns.
; -------------------------------------------------------------------------------------------------
reset
    sei
    cld
    ldx #$FF
    txs
    lda #WRIO_YM_RUN
    sta WRIO                            ; YM2151 out of reset
    and #$FF ^ WRIO_YM_RUN
    sta WRIO                            ; YM2151 reset (bit 0 low)
    ora #WRIO_YM_RUN
    sta WRIO                            ; and out of it again
    ldx #$00
    lda RDIO_M
    and #RDIO_SELF_TEST
    bne self_test
    lda #$00
_clear_zero_page
    sta $00,x                           ; the normal start: clear the zero page
    inx
    bne _clear_zero_page
    jsr ack_timed_irq
    jmp init_board

; -------------------------------------------------------------------------------------------------
; The power-up self-test (from reset, RDIO bit 7 set; not executed in the make sndtrace runs, and
; unreachable in MAME 0.289).
;
; 1. The zero page, a walking bit and its complement in each byte (402A-4052); a bad byte is fatal
;    (self_test_fatal).
; 2. Pages 01-1F through (tmp_ptr), X = the page, the same pattern (4053-408A); a bad page goes to
;    self_test_bad_page (page 01, the stack, is fatal there).
; 3. The ROM checksum (408B-40ED): the four bank pages at 3000 (WRIO bits 7-6 = 0-3), then
;    4000-FFFF, added with checksum_pages; a sum other than FF (checksum_adjust, AC48, makes it
;    FF) sets board_status bit 7.
; 4. The timed IRQ (40EE-4112): with irq_test_mode set h_irq only increments tick_count; if it
;    has not moved after 65536 loops, board_status bit 2.
;
; Then falls into init_board. The result bits are what imm_03_send_status sends the 68010.
; -------------------------------------------------------------------------------------------------
self_test
    ldy #$00                            ; the zero page (Y 00-FF): a walking bit
    lda #$01
_zp_byte
    sta @w $0000,y
    cmp @w $0000,y
    beq _zp_bit_ok
    jmp self_test_fatal                 ; zero page bad: fatal
_zp_bit_ok
    eor #$FF
    sta @w $0000,y
    cmp @w $0000,y
    beq _zp_complement_ok
    jmp self_test_fatal
_zp_complement_ok
    eor #$FF
    clc
    rol a
    bcc _zp_byte
    sta @w $0000,y
    rol a
    iny
    bne _zp_byte
    lda #$00                            ; pages 01-1F through (tmp_ptr), X = the page (0 since 4014)
    sta tmp_ptr
    lda #$00
    sta board_status                    ; the self-test result bits
_next_page
    inx
    cpx #$20
    bne _test_page
    jmp _checksum
_test_page
    stx tmp_ptr+1
    ldy #$00
    lda #$01
_page_byte
    sta (tmp_ptr),y
    cmp (tmp_ptr),y
    beq _page_bit_ok
    jsr self_test_bad_page
_page_bit_ok
    eor #$FF
    sta (tmp_ptr),y
    cmp (tmp_ptr),y
    beq _page_complement_ok
    jsr self_test_bad_page
_page_complement_ok
    eor #$FF
    clc
    rol a
    bcc _page_byte
    sta (tmp_ptr),y
    rol a
    iny
    bne _page_byte
    beq _next_page
_checksum
    ldx #$FF                            ; ROM checksum: the four bank pages at 3000 (WRIO bits
    txs                                 ; 7-6 = 0-3), then 4000-FFFF; the sum must be FF
    lda #WRIO_YM_RUN
    ora #WRIO_OKI_RUN
    sta wrio_shadow
    lda #$00                            ; A: the sum
    pha
    lda wrio_shadow
    and #$FF ^ WRIO_BANK
    sta wrio_shadow
    sta WRIO                            ; bank page 0
    pla
    ldx #>BANK_WINDOW
    ldy #$0F
    jsr checksum_pages
    pha
    lda wrio_shadow
    ora #WRIO_BANK_PAGE1
    sta WRIO                            ; bank page 1
    pla
    ldx #>BANK_WINDOW
    ldy #$0F
    jsr checksum_pages
    pha
    lda wrio_shadow
    ora #WRIO_BANK_PAGE2
    sta WRIO                            ; bank page 2
    pla
    ldx #>BANK_WINDOW
    ldy #$0F
    jsr checksum_pages
    pha
    lda wrio_shadow
    ora #WRIO_BANK_PAGE3
    sta WRIO                            ; bank page 3
    pla
    ldx #>BANK_WINDOW
    ldy #$0F
    jsr checksum_pages
    ldy #$7F                            ; 4000-BFFF
    ldx #$40
    jsr checksum_pages
    ldy #$3F                            ; C000-FFFF (X = C0 after the call above)
    jsr checksum_pages
    cmp #$FF                            ; checksum_adjust (AC48) makes it FF
    beq _test_irq
    lda board_status
    ora #$80                            ; bit 7: ROM checksum bad
    sta board_status
_test_irq
    lda #$FF                            ; the timed IRQ: h_irq counts tick_count while
    sta irq_test_mode                   ; irq_test_mode is set
    jsr ack_timed_irq
    lda #$00
    sta tick_count
    sta tmp_ptr
    sta tmp_ptr+1
    cli
_wait_irq
    lda tick_count
    bne init_board
    nop
    nop
    nop
    inc tmp_ptr
    bne _wait_irq
    inc tmp_ptr+1
    bne _wait_irq
    lda board_status
    ora #$04                            ; bit 2: no IRQ in 65536 loops
    sta board_status

; -------------------------------------------------------------------------------------------------
; The initialisation, after either start (from reset 4027 and self_test).
;
; WRIO 05: bank 0, the M6295 and the YM2151 out of reset; ym_1b_shadow C0 (CT2 and CT1 high:
; init_sound writes it to YM2151 register 1B, and CT1 lets the M6295 be heard); nmi_mode FF (h_nmi
; queues commands); min_priority 0; both queues empty. Drops a pending command byte (the read
; clears the NMI) and sends FF, the response the 68010 sees after every sound reset
; (docs/09-sound-program.md section 5). Falls into warm_start.
; -------------------------------------------------------------------------------------------------
init_board
    sei
    lda #$00
    sta irq_test_mode
    lda #WRIO_YM_RUN
    ora #WRIO_OKI_RUN
    sta wrio_shadow
    sta WRIO                            ; bank 0, OKI and YM2151 out of reset
    lda #$C0
    sta ym_1b_shadow
    ldx #$FF
    stx nmi_mode                        ; FF: h_nmi queues command bytes
    inx
    stx min_priority
    stx resp_queue_out                  ; both queues empty
    stx resp_queue_in
    stx cmd_queue_out
    stx cmd_queue_in
    lda CMD_FROM_68K_M                  ; drop a pending command (clears the NMI)
    ldx #$FF
    stx RESP_TO_68K                     ; FF: the sound board is up (the response after every reset)

; -------------------------------------------------------------------------------------------------
; The sound initialisation, then main_loop (from init_board, and from h_irq 4204 after a BRK,
; with an empty stack). Seeds rng_state with 0D. Neither it nor init_sound clears irq_busy, which
; the BRK path leaves FF: after a BRK commands still run but the timed tick does not (h_irq).
; -------------------------------------------------------------------------------------------------
warm_start
    jsr init_sound                      ; the sound initialisation (also command 00)
    lda #$0D
    sta rng_state                       ; the seed of random
    cli

; -------------------------------------------------------------------------------------------------
; The main loop, forever.
;
; Each pass: steps rng_state (random), clears board_status bit 0 (imm_03_send_status sets it:
; the next status shows whether the loop still runs), sends one queued response when the 68010
; has read the last one (RDIO bit 5, output buffer full, is clear), and runs one queued command
; through dispatch_command. h_nmi fills cmd_queue (a 48-byte ring, at most 47 queued: empty when
; in = out), queue_response fills resp_queue (a 16-byte ring, at most 15 queued).
; -------------------------------------------------------------------------------------------------
main_loop
    jsr random
    lda board_status
    and #$FE
    sta board_status
    lda #RDIO_RESP_FULL
    bit RDIO_M                          ; RDIO bit 5: the 68010 has not read RESP_TO_68K yet
    bne _take_command
    ldy resp_queue_out
    cpy resp_queue_in
    beq _take_command                   ; no response queued
    lda resp_queue,y
    sta RESP_TO_68K
    iny
    cpy #$10
    bcc _response_sent
    ldy #$00
_response_sent
    sty resp_queue_out
_take_command
    ldx cmd_queue_out
    cpx cmd_queue_in
    beq _again                          ; no command queued
    inx
    cpx #$30
    bcc _command_taken
    ldx #$00
_command_taken
    stx cmd_queue_out
    ldy cmd_queue,x                     ; the command byte
    jsr dispatch_command
_again
    jmp main_loop

; -------------------------------------------------------------------------------------------------
; Self-test: a RAM page failed (from 406F, 407A; not executed in the make sndtrace runs).
;
; Input: X = the page. Page 01 (the stack) is fatal (self_test_fatal). A page below 08 sets
; board_status to 10 (the other bits lost), a page from 08 up ORs in bit 3. Keeps A.
; -------------------------------------------------------------------------------------------------
self_test_bad_page
    cpx #$01
    beq self_test_fatal
    pha
    cpx #$08
    bcs _high_page
    lda #$10
    bne _store
_high_page
    lda board_status
    ora #$08
_store
    sta board_status
    pla
    rts

; -------------------------------------------------------------------------------------------------
; Self-test: the zero page (4036, 4043) or the stack page (418E) is bad. Sends 10 to the 68010
; and stops (not executed in the make sndtrace runs).
; -------------------------------------------------------------------------------------------------
self_test_fatal
    lda #$10
    sta RESP_TO_68K
_halt
    jmp _halt

; -------------------------------------------------------------------------------------------------
; Add pages to a sum (from the ROM checksum, 40A5-40E1; not executed in the make sndtrace runs).
;
; Input: A = the sum so far, X = the first page, Y = the number of pages - 1. Output: A += every
; byte of the pages (each add with carry clear), X = the page after the last. Uses tmp_ptr and
; tmp_1B.
; -------------------------------------------------------------------------------------------------
checksum_pages
    sty tmp_1B
_page
    ldy #$00
    sty tmp_ptr
    stx tmp_ptr+1
_byte
    clc
    adc (tmp_ptr),y
    iny
    bne _byte
    inx
    dec tmp_1B
    bpl _page
    rts

; -------------------------------------------------------------------------------------------------
; Acknowledge the timed IRQ (from reset 4024 and self_test 40F2).
; -------------------------------------------------------------------------------------------------
ack_timed_irq
    lda IRQ_ACK_M
    rts

; -------------------------------------------------------------------------------------------------
; The IRQ vector.
;
; YM2151 status bit 0 (timer A) set: ymtimer_irq only (ymtimer.asm; never in the make sndtrace
; runs, nothing there starts timer A). Otherwise the timed IRQ, acknowledged here (the read of
; IRQ_ACK_M happens on both paths): during the self-test (irq_test_mode set) it only counts
; tick_count. Else, unless it interrupted its own tick (irq_busy: it sets irq_again and returns),
; it counts tick_count and runs, with interrupts enabled, tick_sequencer, oki_tick and
; read_inputs, again as long as a nested IRQ set irq_again meanwhile. A BRK (status bit 4 on the
; stack) restarts at warm_start with an empty stack instead, but after the store of FF in irq_busy
; (41F0) and before the only one that clears it (4223): every timed IRQ after it takes the
; irq_busy path (41E6-41EC), so the timed tick never runs again until a reset (docs/09 section
; 10.10; never reached in the traces).
; -------------------------------------------------------------------------------------------------
h_irq
    pha
    txa
    pha
    cld
    lda YM2151_DATA                     ; YM2151 status
    and #YM_TIMER_A                     ; bit 0: timer A
    pha
    lda IRQ_ACK_M                       ; acknowledge the timed IRQ
    pla
    beq _timed
    jsr ymtimer_irq
    jmp _return
_timed
    lda irq_test_mode
    beq _not_self_test
    inc tick_count
    lda board_status
    and #$FB
    sta board_status
    jmp _return
_not_self_test
    lda irq_busy
    beq _tick
    sta irq_again                       ; the tick is running below us: run it once more
    bne _return
_tick
    lda #$FF
    sta irq_busy
    cli
_tick_again
    lda board_status
    and #$FB                            ; bit 2: the timed IRQ runs
    sta board_status
    tsx
    lda stack+$03,x                     ; the status pushed on entry
    and #$10                            ; B: a BRK, not an IRQ
    beq _run_tick
    ldx #$FF
    txs
    jmp warm_start
_run_tick
    tya
    pha
    inc tick_count
    jsr tick_sequencer
    jsr oki_tick
    jsr read_inputs
    pla
    tay
    lda irq_again
    pha
    lda #$00
    sta irq_again
    pla
    bne _tick_again
    sei
    lda #$00
    sta irq_busy
_return
    pla
    tax
    pla
    rti

; -------------------------------------------------------------------------------------------------
; One sequencer tick (from h_irq 420B): engine 0, the YM2151 channels (X = 0), on odd values of
; tick_count, engine 1 (X = 1) on even ones, through tick_group (sequencer.asm).
; -------------------------------------------------------------------------------------------------
tick_sequencer
    lda tick_count
    lsr a
    bcc _engine_1
    ldx #$00
    jmp tick_group
_engine_1
    ldx #$01
    jmp tick_group

    .cerror * != $4238, "system.asm must end at $4237"
