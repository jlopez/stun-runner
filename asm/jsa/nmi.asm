; nmi.asm: 57E3-585D, NMI handler: the command byte from the 68010.
;
; The 68010 writes a byte at 600000 (the high byte; harddriv.cpp init_multisync); atarijsa.cpp's
; sound comm latches it and asserts the 6502's NMI until CMD_FROM_68K is read. h_nmi reads it in
; one of three modes (nmi_mode): FF, the command mode, set at reset; 0, the data mode of
; imm_04 (io.asm), which stores each byte at nmi_data_ptr; anything else, the byte is read and
; dropped (imm_03 sets nmi_mode to FF on its way out, 454C). In the command mode a byte below 6D
; whose cmd_class has bit 7 set is queued in cmd_queue for main_loop (the queue drops its
; oldest entry when full; any other byte queues 6D, which dispatch_command ignores); a byte whose
; cmd_class is 0-3 runs at once, inside the NMI, through imm_handlers entry class+1 (commands 03,
; 06, 07 and 08; docs/09-sound-program.md section 5).
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on.

    .cerror * != $57E3, "nmi.asm must start at $57E3"

; --- The NMI vector.
h_nmi
    pha
_l57E4
    lda #$20
    bit RDIO_M                          ; wait until the 68010 has read the last response
    bne _l57E4                          ; (RDIO bit 5, output buffer full)
    tya
    pha
    ldy nmi_mode
    bne _l580A
    inc nmi_data_count                  ; nmi_mode 0: store the byte at nmi_data_ptr
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
    lda CMD_FROM_68K_M                  ; neither 0 nor FF: read and drop
    jmp loc_584B
_l5813
    txa                                 ; nmi_mode FF: a command
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
    ldx cmd_queue_out                   ; full: drop the oldest
    inx
    cpx #$30
    bcc _l5831
    ldx #$00
_l5831
    stx cmd_queue_out
_l5834
    lda #$6D                            ; 6D, no command, unless the byte is a queued one
    sta cmd_queue,y
    ldx CMD_FROM_68K_M                  ; the command byte (clears the NMI)
    cpx #$6D
    bcs loc_5849                        ; 6D and up: not a command
    lda cmd_class,x
    bpl loc_584F                        ; bit 7 clear: an immediate command
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
; An immediate command: cmd_class 0-3 runs imm_handlers entry class+1 by RTS (the handler leaves
; through loc_5849 or loc_584B, or their copy at 4548, with X, Y and A on the stack); 4-7F drops
; the byte (no command uses one).
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
