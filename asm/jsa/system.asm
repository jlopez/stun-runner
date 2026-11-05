; system.asm: 4000-4237, reset, power-up self-test, main loop, IRQ handler.
;
; reset (the reset vector) starts the board: the self-test when RDIO bit 7 asks for it, then the
; initialisation, the FF it sends the 68010 to say it is up, and main_loop, which runs the
; commands h_nmi queued and sends the responses others queued. h_irq (the IRQ vector) serves the
; two interrupt sources atarijsa.cpp ORs into the 6502's IRQ: the YM2151's (timer A flag, bit 0
; of its status) and the timed one (about 250 Hz, acknowledged by reading IRQ_ACK_M).
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on. sub_/loc_/_lXXXX labels are neutral
; address labels for later legs to rename.

    .cerror * != $4000, "system.asm must start at $4000"

; --- The reset vector. A pulse of WRIO bit 0 (YM2151 reset, active low) with every other WRIO bit
; 0 (bank 0, OKI reset held low). RDIO bit 7 is the self-test input (in MAME the inverted IN0
; bit 5 of the main board, the test switch): clear, the normal start, which clears the zero page
; and goes to the initialisation (_l4113); set, the self-test (_l402A): zero page and stack page
; with a walking bit, then pages 02-1F, the ROM checksum and the timed IRQ, each failure a bit in
; zp_02 (the byte imm_03 sends the 68010, 4533). Not executed in the make sndtrace runs.
reset
    sei
    cld
    ldx #$FF
    txs
    lda #$01
    sta WRIO                            ; YM2151 out of reset
    and #$FE
    sta WRIO                            ; YM2151 reset (bit 0 low)
    ora #$01
    sta WRIO                            ; and out of it again
    ldx #$00
    lda RDIO_M
    and #$80                            ; RDIO bit 7: self-test
    bne _l402A
    lda #$00
_l401F
    sta zp_00,x                         ; the normal start: clear the zero page
    inx
    bne _l401F
    jsr sub_41BD                        ; acknowledge the timed IRQ
    jmp _l4113
_l402A
    ldy #$00                            ; self-test: zero page and stack page, a walking bit
    lda #$01
_l402E
    sta @w zp_00,y
    cmp @w zp_00,y
    beq _l4039
    jmp loc_41A1                        ; zero page bad: fatal
_l4039
    eor #$FF
    sta @w zp_00,y
    cmp @w zp_00,y
    beq _l4046
    jmp loc_41A1
_l4046
    eor #$FF
    clc
    rol a
    bcc _l402E
    sta @w zp_00,y
    rol a
    iny
    bne _l402E
    lda #$00                            ; pages 02-1F through (zp_19), X = the page
    sta zp_19
    lda #$00
    sta zp_02                           ; the self-test result bits
_l405B
    inx
    cpx #$20
    bne _l4063
    jmp _l408B
_l4063
    stx zp_1A
    ldy #$00
    lda #$01
_l4069
    sta (zp_19),y
    cmp (zp_19),y
    beq _l4072
    jsr sub_418C
_l4072
    eor #$FF
    sta (zp_19),y
    cmp (zp_19),y
    beq _l407D
    jsr sub_418C
_l407D
    eor #$FF
    clc
    rol a
    bcc _l4069
    sta (zp_19),y
    rol a
    iny
    bne _l4069
    beq _l405B
_l408B
    ldx #$FF                            ; ROM checksum: the four bank pages at 3000 (WRIO bits
    txs                                 ; 7-6 = 0-3), then 4000-FFFF; the sum must be FF
    lda #$01
    ora #$04
    sta wrio_shadow
    lda #$00
    pha
    lda wrio_shadow
    and #$3F
    sta wrio_shadow
    sta WRIO
    pla
    ldx #$30
    ldy #$0F
    jsr sub_41A9
    pha
    lda wrio_shadow
    ora #$40
    sta WRIO
    pla
    ldx #$30
    ldy #$0F
    jsr sub_41A9
    pha
    lda wrio_shadow
    ora #$80
    sta WRIO
    pla
    ldx #$30
    ldy #$0F
    jsr sub_41A9
    pha
    lda wrio_shadow
    ora #$C0
    sta WRIO
    pla
    ldx #$30
    ldy #$0F
    jsr sub_41A9
    ldy #$7F
    ldx #$40
    jsr sub_41A9
    ldy #$3F
    jsr sub_41A9
    cmp #$FF                            ; checksum_adjust (AC48) makes it FF
    beq _l40EE
    lda zp_02
    ora #$80                            ; bit 7: ROM checksum bad
    sta zp_02
_l40EE
    lda #$FF                            ; the timed IRQ: h_irq counts zp_00 while zp_01 is set
    sta zp_01
    jsr sub_41BD
    lda #$00
    sta zp_00
    sta zp_19
    sta zp_1A
    cli
_l40FE
    lda zp_00
    bne _l4113
    nop
    nop
    nop
    inc zp_19
    bne _l40FE
    inc zp_1A
    bne _l40FE
    lda zp_02
    ora #$04                            ; bit 2: no IRQ in 65536 loops
    sta zp_02
; the initialisation, after either start
_l4113
    sei
    lda #$00
    sta zp_01
    lda #$01
    ora #$04
    sta wrio_shadow
    sta WRIO                            ; bank 0, OKI and YM2151 out of reset
    lda #$C0
    sta ym_1b_shadow
    ldx #$FF
    stx nmi_mode                        ; FF: h_nmi queues command bytes
    inx
    stx zp_1E
    stx resp_queue_out                  ; both queues empty
    stx resp_queue_in
    stx cmd_queue_out
    stx cmd_queue_in
    lda CMD_FROM_68K_M                  ; drop a pending command (clears the NMI)
    ldx #$FF
    stx RESP_TO_68K                     ; FF: the sound board is up (the response after every reset)

; from 4204 (h_irq, after a BRK)
loc_4141
    jsr imm_00                          ; the sound initialisation (also command 00)
    lda #$0D
    sta zp_47                           ; the seed of sub_5504
    cli

; --- The main loop, forever: one response out (when the 68010 has read the last one: RDIO bit 5,
; output buffer full, is clear) and one queued command run, each per pass. h_nmi fills cmd_queue
; (48 entries), queue_response fills resp_queue (16).
main_loop
    jsr sub_5504
    lda zp_02
    and #$FE
    sta zp_02
    lda #$20
    bit RDIO_M                          ; RDIO bit 5: the 68010 has not read RESP_TO_68K yet
    bne _l4171
    ldy resp_queue_out
    cpy resp_queue_in
    beq _l4171                          ; no response queued
    lda resp_queue,y
    sta RESP_TO_68K
    iny
    cpy #$10
    bcc _l416E
    ldy #$00
_l416E
    sty resp_queue_out
_l4171
    ldx cmd_queue_out
    cpx cmd_queue_in
    beq _l4189                          ; no command queued
    inx
    cpx #$30
    bcc _l4180
    ldx #$00
_l4180
    stx cmd_queue_out
    ldy cmd_queue,x                     ; the command byte
    jsr dispatch_command
_l4189
    jmp main_loop

; from 406F, 407A; not executed in the make sndtrace runs
; Self-test: a RAM page failed (X = the page). Page 01 (the stack) is fatal; the result bits are
; 10 for a page below 08, bit 3 added for the others.
sub_418C
    cpx #$01
    beq loc_41A1
    pha
    cpx #$08
    bcs _l4199
    lda #$10
    bne _l419D
_l4199
    lda zp_02
    ora #$08
_l419D
    sta zp_02
    pla
    rts

; from 4036, 4043; not executed in the make sndtrace runs
; Self-test: zero page or stack page bad. Sends 10 to the 68010 and stops.
loc_41A1
    lda #$10
    sta RESP_TO_68K
_l41A6
    jmp _l41A6

; from 40A5, 40B5, 40C5, 40D5, 40DC, 40E1; not executed in the make sndtrace runs
; A += every byte of Y+1 pages from page X (each add with carry clear).
sub_41A9
    sty zp_1B
_l41AB
    ldy #$00
    sty zp_19
    stx zp_1A
_l41B1
    clc
    adc (zp_19),y
    iny
    bne _l41B1
    inx
    dec zp_1B
    bpl _l41AB
    rts

; from 4024, 40F2
sub_41BD
    lda IRQ_ACK_M                       ; acknowledge the timed IRQ
    rts

; --- The IRQ vector. YM2151 status bit 0 (timer A) set: sub_59C0 only (ymtimer.asm; never in the
; make sndtrace runs, nothing there starts timer A). Otherwise the timed IRQ, acknowledged here:
; during the self-test (zp_01 set) it only counts zp_00; else, unless it interrupted itself
; (zp_11), it runs, with interrupts enabled, sub_4229 (into sequencer.asm at loc_5043, X = 0
; and 1 on alternate ticks), sub_5BC6 (oki.asm) and sub_5CE8 (io.asm), again as long as a nested
; IRQ came in meanwhile (zp_12). A BRK (status bit 4 on the stack) restarts at loc_4141 with an empty stack.
h_irq
    pha
    txa
    pha
    cld
    lda YM2151_DATA                     ; YM2151 status
    and #$01                            ; bit 0: timer A
    pha
    lda IRQ_ACK_M                       ; acknowledge the timed IRQ
    pla
    beq _l41D7
    jsr sub_59C0
    jmp _l4225
_l41D7
    lda zp_01
    beq _l41E6
    inc zp_00
    lda zp_02
    and #$FB
    sta zp_02
    jmp _l4225
_l41E6
    lda zp_11
    beq _l41EE
    sta zp_12
    bne _l4225
_l41EE
    lda #$FF
    sta zp_11
    cli
_l41F3
    lda zp_02
    and #$FB
    sta zp_02
    tsx
    lda stack+$03,x                     ; the status pushed on entry
    and #$10                            ; B: a BRK, not an IRQ
    beq _l4207
    ldx #$FF
    txs
    jmp loc_4141
_l4207
    tya
    pha
    inc zp_00
    jsr sub_4229
    jsr sub_5BC6
    jsr sub_5CE8
    pla
    tay
    lda zp_12
    pha
    lda #$00
    sta zp_12
    pla
    bne _l41F3
    sei
    lda #$00
    sta zp_11
_l4225
    pla
    tax
    pla
    rti

; from 420B
sub_4229
    lda zp_00
    lsr a
    bcc _l4233
    ldx #$00
    jmp loc_5043
_l4233
    ldx #$01
    jmp loc_5043

    .cerror * != $4238, "system.asm must end at $4237"
