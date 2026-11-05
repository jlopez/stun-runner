; system.asm: 4000-4237, reset, power-up self-test, main loop, IRQ handler.
;
; Generated once from the recursive descent and the MAME trace (docs/09-sound-program.md);
; hand-maintained from here on.

    .cerror * != $4000, "system.asm must start at $4000"

reset
    sei
    cld
    ldx #$FF
    txs
    lda #$01
    sta WRIO
    and #$FE
    sta WRIO
    ora #$01
    sta WRIO
    ldx #$00
    lda RDIO_M
    and #$80
    bne _l402A
    lda #$00
_l401F
    sta zp_00,x
    inx
    bne _l401F
    jsr sub_41BD
    jmp _l4113
_l402A
    ldy #$00
    lda #$01
_l402E
    sta @w zp_00,y
    cmp @w zp_00,y
    beq _l4039
    jmp loc_41A1
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
    lda #$00
    sta zp_19
    lda #$00
    sta zp_02
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
    ldx #$FF
    txs
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
    cmp #$FF
    beq _l40EE
    lda zp_02
    ora #$80
    sta zp_02
_l40EE
    lda #$FF
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
    ora #$04
    sta zp_02
_l4113
    sei
    lda #$00
    sta zp_01
    lda #$01
    ora #$04
    sta wrio_shadow
    sta WRIO
    lda #$C0
    sta ym_1b_shadow
    ldx #$FF
    stx nmi_mode
    inx
    stx zp_1E
    stx resp_queue_out
    stx resp_queue_in
    stx cmd_queue_out
    stx cmd_queue_in
    lda CMD_FROM_68K_M
    ldx #$FF
    stx RESP_TO_68K

; from 4204
loc_4141
    jsr imm_00
    lda #$0D
    sta zp_47
    cli

; from 4189
main_loop
    jsr sub_5504
    lda zp_02
    and #$FE
    sta zp_02
    lda #$20
    bit RDIO_M
    bne _l4171
    ldy resp_queue_out
    cpy resp_queue_in
    beq _l4171
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
    beq _l4189
    inx
    cpx #$30
    bcc _l4180
    ldx #$00
_l4180
    stx cmd_queue_out
    ldy cmd_queue,x
    jsr dispatch_command
_l4189
    jmp main_loop

; from 406F, 407A; not executed in the make sndtrace runs
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
loc_41A1
    lda #$10
    sta RESP_TO_68K
_l41A6
    jmp _l41A6

; from 40A5, 40B5, 40C5, 40D5, 40DC, 40E1; not executed in the make sndtrace runs
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
    lda IRQ_ACK_M
    rts

h_irq
    pha
    txa
    pha
    cld
    lda YM2151_DATA
    and #$01
    pha
    lda IRQ_ACK_M
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
    lda stack+$03,x
    and #$10
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
