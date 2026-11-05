; nmi.asm: 57E3-585D, NMI handler: the command byte from the 68010.
;
; Generated once from the recursive descent and the MAME trace (docs/09-sound-program.md);
; hand-maintained from here on.

    .cerror * != $57E3, "nmi.asm must start at $57E3"

h_nmi
    pha
_l57E4
    lda #$20
    bit RDIO_M
    bne _l57E4
    tya
    pha
    ldy nmi_mode
    bne _l580A
    inc nmi_data_count
    bne _l57FA
    inc nmi_data_count+1
_l57FA
    ldy #$00
    lda CMD_FROM_68K_M
    sta (nmi_data_ptr),y
    inc nmi_data_ptr
    bne _l5807
    inc nmi_data_ptr+1
_l5807
    jmp loc_584B
_l580A
    iny
    beq _l5813
    lda CMD_FROM_68K_M
    jmp loc_584B
_l5813
    txa
    pha
    ldy cmd_queue_in
    iny
    cpy #$30
    bcc _l581F
    ldy #$00
_l581F
    sty cmd_queue_in
    cpy cmd_queue_out
    bne _l5834
    ldx cmd_queue_out
    inx
    cpx #$30
    bcc _l5831
    ldx #$00
_l5831
    stx cmd_queue_out
_l5834
    lda #$6D
    sta cmd_queue,y
    ldx CMD_FROM_68K_M
    cpx #$6D
    bcs loc_5849
    lda cmd_class,x
    bpl loc_584F
    txa
    sta cmd_queue,y

; from 5DB2
loc_5849
    pla
    tax

; from 5807, 5810
loc_584B
    pla
    tay
    pla
    rti

; not executed in the make sndtrace runs
loc_584F
    cmp #$04
    bcs loc_5849
    asl a
    tay
    lda imm_handlers+3,y
    pha
    lda imm_handlers+2,y
    pha
    rts

    .cerror * != $585E, "nmi.asm must end at $585D"
