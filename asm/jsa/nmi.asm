; nmi.asm: 57E3-585D, NMI handler: the command byte from the 68010.
;
; The 68010 writes a byte at 600000 (the high byte; harddriv.cpp init_multisync); atarijsa.cpp's
; sound comm latches it and asserts the 6502's NMI until CMD_FROM_68K is read. h_nmi reads it in
; one of three modes (nmi_mode): FF, the command mode, set at reset; 0, the data mode of
; receive_bytes (io.asm), which stores each byte at nmi_data_ptr; anything else, the byte is read
; and dropped. In the command mode a byte below 6D whose cmd_class has bit 7 set is queued in
; cmd_queue for main_loop (the queue drops its oldest entry when full; any other byte queues 6D,
; which dispatch_command ignores); a byte whose cmd_class is 0-3 runs at once, inside the NMI,
; through imm_handlers entry class+1 (commands 03, 06, 07 and 08; docs/09-sound-program.md
; section 5).
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); named in M4c (docs/09 section 10.3).

    .cerror * != $57E3, "nmi.asm must start at $57E3"

; -------------------------------------------------------------------------------------------------
; The NMI vector.
;
; Waits until the 68010 has read the last response (RDIO bit 5 clear), then takes the command
; byte as nmi_mode says. Keeps A, X and Y. The data mode nests: receive_bytes waits inside
; imm_04_loopback, itself inside an NMI, and the NMI is an edge, so the next byte's NMI comes in
; on top of it.
; -------------------------------------------------------------------------------------------------
h_nmi
    pha
_wait_read
    lda #RDIO_RESP_FULL
    bit RDIO_M                          ; wait until the 68010 has read the last response
    bne _wait_read                      ; (RDIO bit 5, output buffer full)
    tya
    pha
    ldy nmi_mode
    bne _not_data
    inc nmi_data_count                  ; nmi_mode 0: store the byte at nmi_data_ptr
    bne _store
    inc nmi_data_count+1
_store
    ldy #$00
    lda CMD_FROM_68K_M
    sta (nmi_data_ptr),y
    inc nmi_data_ptr
    bne _stored
    inc nmi_data_ptr+1
_stored
    jmp nmi_return
_not_data
    iny
    beq _command
    lda CMD_FROM_68K_M                  ; neither 0 nor FF: read and drop
    jmp nmi_return
_command
    txa                                 ; nmi_mode FF: a command
    pha
    ldy cmd_queue_in
    iny
    cpy #$30
    bcc _no_wrap
    ldy #$00
_no_wrap
    sty cmd_queue_in
    cpy cmd_queue_out
    bne _queue
    ldx cmd_queue_out                   ; full: drop the oldest
    inx
    cpx #$30
    bcc _drop_oldest
    ldx #$00
_drop_oldest
    stx cmd_queue_out
_queue
    lda #$6D                            ; 6D, no command, unless the byte is a queued one
    sta cmd_queue,y
    ldx CMD_FROM_68K_M                  ; the command byte (clears the NMI)
    cpx #$6D
    bcs nmi_return_x                    ; 6D and up: not a command
    lda cmd_class,x
    bpl nmi_immediate                   ; bit 7 clear: an immediate command
    txa
    sta cmd_queue,y

; -------------------------------------------------------------------------------------------------
; The NMI's exits: nmi_return_x pulls X, then nmi_return pulls Y and A and returns (from h_nmi,
; from nmi_immediate 5851 for a class 4-7F, and from imm_01_send_inputs 5DB2). imm_return
; (commands.asm) is a third, which also sets nmi_mode back to FF.
; -------------------------------------------------------------------------------------------------
nmi_return_x
    pla
    tax

nmi_return
    pla
    tay
    pla
    rti

; -------------------------------------------------------------------------------------------------
; An immediate command (from h_nmi 5843, A = cmd_class,X; executed only by the M4c probe, docs/09
; section 10.3).
;
; cmd_class 0-3 runs imm_handlers entry class+1 by RTS (the handler leaves through nmi_return_x
; or imm_return with X, Y and A on the stack); 4-7F drops the byte (no command has one).
; -------------------------------------------------------------------------------------------------
nmi_immediate
    cmp #$04
    bcs nmi_return_x
    asl a
    tay
    lda imm_handlers+3,y
    pha
    lda imm_handlers+2,y
    pha
    rts

    .cerror * != $585E, "nmi.asm must end at $585D"
