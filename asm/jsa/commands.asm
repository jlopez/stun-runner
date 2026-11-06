; commands.asm: 4238-4758, command execution: the command-type handlers and their table.
;
; A queued command byte (main_loop, from cmd_queue) goes to dispatch_command: cmd_type (tables.asm)
; gives its type 00-14, cmdtype_handlers the handler, cmd_param the byte the handler gets in A. Two
; immediate commands of h_nmi end here too (imm_02, imm_03), and imm_00, the sound initialisation
; run at reset (4141) and as the queued command 00 through cmdtype_03 (43CA), with send_response,
; which writes one byte to the 68010 and waits for it to be read, and queue_response, which leaves
; one for main_loop. Some handlers are also stream ops of the sequencer (op_handlers). What each
; type does to the sound is for a later leg: the labels name the dispatch, not the role.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on.

    .cerror * != $4238, "commands.asm must start at $4238"

; imm_handlers entry 0; from 4141
; The sound initialisation: run at reset (loc_4141) and as command 00 (cmd_type 03, cmd_param 00:
; cmdtype_03 picks imm_handlers entry 0). Resets the OKI (sub_5BAC), clears the response queue
; and the tables in RAM, keys off the eight YM2151 channels (register 08) and sets MIX.
imm_00
    php
    sei
    jsr sub_5BAC
    jsr sub_42D8
    lda #$00
    sta resp_queue_out
    sta resp_queue_in
    sta resp_queue_full
    ldx #$2B
_l424D
    sta ram_0860,x
    dex
    bpl _l424D
    ldx #$1D
_l4255
    sta ram_03EC,x
    sta ram_02A2,x
    sta ram_02C0,x
    sta ram_0464,x
    sta ram_06BC,x
    dex
    bpl _l4255
    ldx #$01
_l4269
    lda tbl_57DB,x
    sta zp_08
    lda tbl_57DD,x
    sta zp_09
    lda tbl_57DF,x
    cmp #$03
    beq _l42B9
    jsr ym_wait
    ldy #$08
    sty YM2151_REG
    lda #$00
    sta zp_0E
    jsr ym_wait
    sty YM2151_REG
    sta zp_0E
    jsr ym_wait
    ldy #$07
_l4293
    sta zp_0E
    jsr ym_wait
    sty YM2151_DATA
    dey
    bpl _l4293
    sta zp_0E
    lda zp_02
    and #$FD
    sta zp_02
    jsr ym_wait
    jsr sub_585E
    ldy #$1B
    jsr ym_wait
    sty YM2151_REG
    lda ym_1b_shadow
    sta YM2151_DATA
_l42B9
    dex
    bmi _l42BF
    jmp _l4269
_l42BF
    lda #$0F
    and #$00
    sta zp_43
    lda #$00
    eor #$FF
    and #$0F
    sta mix_shadow
    php
    sei
    sta MIX
    sta MIX
    plp
    plp
    rts

; from 423D
sub_42D8
    lda #$01
    sta zp_1F
    jsr sub_431A
    lda #$02
_l42E1
    sta (zp_20),y
    tax
    inx
    lda zp_20
    clc
    adc #$04
    sta zp_20
    bcc _l42F6
    inc zp_21
    lda #$1F
    cmp zp_21
    beq _l42FB
_l42F6
    txa
    cmp #$C8
    bcc _l42E1
_l42FB
    dec zp_21
    lda zp_20
    sec
    sbc #$04
    sta zp_20
    lda #$00
    sta (zp_20),y
    rts

; from 523C, 5264
sub_4309
    lda zp_1F
    jsr sub_431A
    pha
    lda (zp_20),y
    beq _l4317
    sta zp_1F
    pla
    rts
_l4317
    lda #$00
    rts

; from 42DC, 430B, 4343, 435B, 491F, 5293
sub_431A
    pha
    tay
    dey
    sty zp_20
    sty zp_19
    ldy #$00
    sty zp_21
    asl zp_20
    rol zp_21
    asl zp_20
    rol zp_21
    lda #$AE
    clc
    adc zp_20
    sta zp_20
    lda #$09
    adc zp_21
    sta zp_21
    pla
    rts

; from 465E, 495B
sub_433C
    tya
    pha
_l433E
    lda ram_0752,x
    beq _l4356
    jsr sub_431A
    pha
    lda (zp_20),y
    sta ram_0752,x
    lda zp_1F
    sta (zp_20),y
    pla
    sta zp_1F
    jmp _l433E
_l4356
    lda ram_0734,x
    beq _l436E
    jsr sub_431A
    pha
    lda (zp_20),y
    sta ram_0734,x
    lda zp_1F
    sta (zp_20),y
    pla
    sta zp_1F
    jmp _l4356
_l436E
    pla
    tay
    rts

; from 4186
; --- Run command Y (a byte main_loop took from cmd_queue): the handler cmdtype_handlers gives for
; cmd_type,y, entered by RTS with A = cmd_param,y. Y 6D and up (6D is what h_nmi queues for a
; byte that is not a command) or a type 15 and up (FF: commands 03, 06, 07 and 08, the immediate
; ones) do nothing.
dispatch_command
    cpy #$6D
    bcs _l4389
    lda cmd_type,y
    cmp #$15
    bcs _l4389
    asl a
    tax
    lda cmdtype_handlers+1,x            ; the handler's address - 1, high byte first
    pha
    lda cmdtype_handlers,x
    pha
    lda cmd_param,y                     ; A: the parameter
_l4389
    rts

; cmdtype_handlers entry $00
; zp_1E = 4 x the parameter: commands 01 (F0) and 02 (0). The OKI start (5BFE) needs zp_1E = 0;
; sub_4E79's key code, levels and key-on (after 4EE6) need ram_088E >= zp_1E: the 68010 sends 01
; when attract mode starts with "SOUNDS IN ATTRACT" off and 02 otherwise (docs/09-sound-program.md
; section 6).
cmdtype_00
    asl a
    asl a
    sta zp_1E
    rts

; cmdtype_handlers entry $11; op_handlers entry for stream byte $A5; not executed in the make
; sndtrace runs
cmdtype_11
    php
    sei
    pha
    lda ym_1b_shadow
    and #$3F
    sta ym_1b_shadow
    ldy #$1B
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

; cmdtype_handlers entry $01
cmdtype_01
    tay
    lda global_set_index,y
    and #$1F
    tax
    lda global_set_value,y
    sta zp_23,x
    rts

; cmdtype_handlers entry $02; not executed in the make sndtrace runs
cmdtype_02
    tay
    lda global_set_index,y
    and #$1F
    tax
    lda global_set_value,y
    clc
    adc zp_23,x
    sta zp_23,x
    rts

; cmdtype_handlers entry $03; not executed in the make sndtrace runs
; imm_handlers entry A, by RTS (command 00: entry 0, imm_00).
cmdtype_03
    asl a
    tay
    lda imm_handlers+1,y
    pha
    lda imm_handlers,y
    pha
    rts

; cmdtype_handlers entry $04; not executed in the make sndtrace runs
cmdtype_04
    php
    sei
    sta zp_1C
    ldy #$1D
_l43DB
    lda ram_03EC,y
    lsr a
    lsr a
    eor zp_1C
    bne _l43E9
    lda #$FF
    sta ram_0248,y
_l43E9
    dey
    bpl _l43DB
    plp
    rts

; cmdtype_handlers entry $05
cmdtype_05
    php
    sei
    tay
    lda cmd_type,y
    cmp #$08
    bne _l440E
    lda cmd_param,y
    sta zp_1C
    ldy #$1D
_l43FF
    cmp ram_0248,y
    bne _l440B
    lda #$FF
    sta ram_0248,y
    lda zp_1C
_l440B
    dey
    bpl _l43FF
_l440E
    plp
    rts

; cmdtype_handlers entry $06; not executed in the make sndtrace runs
cmdtype_06
    sta zp_1C
    lsr a
    lsr a
    lsr a
    lsr a
    tay
    lda zp_1C
    and #$0F
    clc
    adc tbl_57E1,y
    tay
    php
    sei
    lda ram_0860,y
    beq _l4433
_l4427
    tay
    dey
    lda #$FF
    sta ram_0248,y
    lda ram_0860,y
    bne _l4427
_l4433
    plp
    rts

; cmdtype_handlers entry $07; not executed in the make sndtrace runs
cmdtype_07
    php
    sei
    sta zp_1C
    lda zp_1C
    bne _l4443
    lda #$80
    sta zp_1C
    bne _l4447
_l4443
    lda #$40
    sta zp_1C
_l4447
    ldy #$1D
_l4449
    lda ram_03EC,y
    beq _l445A
    lda ram_0518,y
    and zp_1C
    beq _l445A
    lda #$FF
    sta ram_0248,y
_l445A
    dey
    bpl _l4449
    plp
    rts

; cmdtype_handlers entry $0A
cmdtype_0A
    php
    sei
    tay
    lda cmd_type,y
    cmp #$08
    bne _l4494
    lda cmd_param,y
    sta zp_1C
    ldy #$1D
_l4470
    cmp ram_0248,y
    bne _l4491
    lda #$00
    sta ram_078E,y
    sta ram_0806,y
    sta ram_07CA,y
    lda #$D0
    sta ram_07E8,y
    lda #$02
    sta ram_07AC,y
    lda #$FE
    sta ram_0248,y
    lda zp_1C
_l4491
    dey
    bpl _l4470
_l4494
    plp
    rts

; cmdtype_handlers entry $0B
cmdtype_0B
    php
    sei
    sta zp_1C
    ldy #$1D
_l449C
    lda ram_03EC,y
    lsr a
    lsr a
    eor zp_1C
    bne _l44BF
    lda #$00
    sta ram_078E,y
    sta ram_0806,y
    sta ram_07CA,y
    lda #$D0
    sta ram_07E8,y
    lda #$02
    sta ram_07AC,y
    lda #$FE
    sta ram_0248,y
_l44BF
    dey
    bpl _l449C
    plp
    rts

; cmdtype_handlers entry $10; not executed in the make sndtrace runs
cmdtype_10
    tay
    ldx tbl_65DD+3,y
    cpx zp_1E
    bcc _l44CF
    jmp loc_5869
_l44CF
    rts

; cmdtype_handlers entry $09; from 550E; not executed in the make sndtrace runs
; Queue A in resp_queue for main_loop to send; when the queue is full, the byte is dropped and
; resp_queue_full set to 80. Command 09 (cmd_param 55) queues 55; stream op 96 (op_96, 550E)
; queues its operand.
queue_response
    ldy resp_queue_in
    sta resp_queue,y
    iny
    cpy #$10
    bcc _l44DD
    ldy #$00
_l44DD
    cpy resp_queue_out
    beq _l44E6
    sty resp_queue_in
    rts
_l44E6
    lda #$80
    sta resp_queue_full
    rts

; cmdtype_handlers entry $0D; not executed in the make sndtrace runs
cmdtype_0D
    tax
    lda tbl_65DD+5,x
    cmp #$3B
    bcs _l4532
    cmp #$08
    bcc _l450C
    cmp #$0A
    bcc _l4532
    cmp #$0D
    bcc _l450C
    cmp #$12
    bcc _l4532
    cmp #$16
    bcc _l450C
    cmp #$19
    bcc _l4532
_l450C
    asl a
    tay
    lda tbl_65DD+8,x
    clc
    adc #$1E
    pha
    lda tbl_65DD+6,x
    sta ram_08AD
    lda tbl_65DD+7,x
    tax
    lda cmd_type,x
    cmp #$08
    bne _l4531
    lda cmd_param,x
    sta ram_08AC
    pla
    tax
    jmp loc_508D
_l4531
    pla
_l4532
    rts

; imm_handlers entry 3; not executed in the make sndtrace runs
; Command 07 (cmd_class 02): send zp_02, the status byte, then set its bits 0 and 2, which
; main_loop (414C) and the timed IRQ (41F3) clear: the next 07 tells whether both still run.
; Bit 1 is set by ym_wait on a YM2151 time-out, bits 7, 4, 3 and 2 by the self-test.
imm_03
    lda zp_02
    jsr send_response
    lda zp_02
    ora #$04
    ora #$01
    sta zp_02
    jmp loc_4548

; imm_handlers entry 2; not executed in the make sndtrace runs
; Command 06 (cmd_class 01): send 6D, the number of command bytes the tables cover.
imm_02
    lda #$6D
    jsr send_response

; from 4540, 5CC2; not executed in the make sndtrace runs
; The way out of an immediate command (h_nmi pushed A, Y, X): back to the command mode.
loc_4548
    pla
    tax
    pla
    tay
    lda #$FF
    sta nmi_mode
    pla
    rti

; from 4535, 4545, 5CBF, 5CDD, 5DAF; not executed in the make sndtrace runs
; Send A to the 68010 now: wait until RDIO bit 5 (output buffer full) is clear, write
; RESP_TO_68K, wait until the 68010 has read it. Used by the immediate commands only; main_loop
; sends queued responses without waiting.
send_response
    pha
    lda #$20
_l4556
    and RDIO_M
    bne _l4556
    pla
    pha
    sta RESP_TO_68K
    lda #$20
_l4562
    and RDIO_M
    bne _l4562
    pla
    rts

; cmdtype_handlers entry $08
cmdtype_08
    sta zp_03
    tay
    asl a
    tax
    bcs _l4575
    lda sound_first_entry,x
    bcc _l4578
_l4575
    lda sound_first_entry+$100,x
_l4578
    sta zp_13
    bcs _l4581
    lda sound_first_entry+1,x
    bcc _l4584
_l4581
    lda sound_first_entry+$101,x
_l4584
    sta zp_14
    lda sound_restartable,y
    bne _l459F
    lda zp_03
    ldy #$1D
_l458F
    cmp ram_0248,y
    bne _l459C
    lda ram_03EC,y
    beq _l459A
    rts
_l459A
    lda zp_03
_l459C
    dey
    bpl _l458F
_l459F
    ldy #$1D
_l45A1
    lda ram_03EC,y
    beq _l45EB
    dey
    bpl _l45A1
    ldy #$00
    lda #<entry_priority
    clc
    adc zp_13
    sta zp_15
    lda #>entry_priority
    adc zp_14
    sta zp_16
    lda (zp_15),y
    sta zp_17
    lda #<entry_channel
    clc
    adc zp_13
    sta zp_15
    lda #>entry_channel
    adc zp_14
    sta zp_16
    lda (zp_15),y
    clc
    adc #$1E
    tax
    php
    sei
    ldy ram_0860,x
    beq _l45E1
    dey
    lda zp_17
    asl a
    sec
    rol a
    cmp ram_03EC,y
    bcs _l45E4
_l45E1
    plp
    sec
    rts
_l45E4
    lda ram_0860,y
    sta ram_0860,x
    plp
_l45EB
    tya
    tax
    jsr sub_46A5
    ldy #$00
    lda #<entry_priority
    clc
    adc zp_13
    sta zp_15
    lda #>entry_priority
    adc zp_14
    sta zp_16
    lda (zp_15),y
    asl a
    sec
    rol a
    sta ram_03EC,x
    lda #<entry_channel
    clc
    adc zp_13
    sta zp_15
    lda #>entry_channel
    adc zp_14
    sta zp_16
    lda (zp_15),y
    clc
    adc #$1E
    sta zp_17
    lda zp_13
    asl a
    sta zp_15
    lda zp_14
    rol a
    sta zp_16
    lda #<entry_stream
    clc
    adc zp_15
    sta zp_15
    lda #>entry_stream
    adc zp_16
    sta zp_16
    lda (zp_15),y
    sta ram_0266,x
    iny
    lda (zp_15),y
    sta ram_0284,x
    ldy zp_17
    php
    sei
_l4641
    sty zp_17
    lda ram_0860,y
    beq _l4670
    tay
    dey
    lda ram_03EC,y
    ora #$01
    cmp ram_03EC,x
    bcc _l4641
    beq _l465A
    iny
    tya
    bcs _l466B
_l465A
    txa
    pha
    tya
    tax
    jsr sub_433C
    pla
    tax
    lda #$00
    sta ram_03EC,y
    lda ram_0860,y
_l466B
    sta ram_0860,x
    ldy zp_17
_l4670
    lda zp_03
    sta ram_0248,x
    inx
    txa
    sta ram_0860,y
    plp
    ldy #$00
    lda zp_13
    asl a
    sta zp_15
    lda zp_14
    rol a
    sta zp_16
    lda #<entry_next
    clc
    adc zp_15
    sta zp_15
    lda #>entry_next
    adc zp_16
    sta zp_16
    lda (zp_15),y
    sta zp_13
    iny
    ora (zp_15),y
    beq loc_46A4
    lda (zp_15),y
    sta zp_14
    jmp _l459F

; cmdtype_handlers entry $0C, $0F, $12
loc_46A4
    rts

; from 45ED
sub_46A5
    lda #$07
    sta ram_0464,x
    lda #$10
    sta ram_0644,x
    lda #$A0
    sta ram_06BC,x
    lda #$FF
    sta ram_0428,x
    lda #$00
    sta ram_0626,x
    sta ram_0446,x
    sta ram_0860,x
    sta ram_0662,x
    sta ram_02DE,x
    sta ram_02FC,x
    sta ram_031A,x
    sta ram_06DA,x
    sta ram_0770,x
    sta ram_06F8,x
    sta ram_0716,x
    sta ram_0734,x
    sta ram_0752,x
    sta ram_0338,x
    sta ram_0356,x
    sta ram_0374,x
    sta ram_0392,x
    sta ram_078E,x
    sta ram_07AC,x
    sta ram_05AE,x
    sta ram_05CC,x
    sta ram_05EA,x
    sta ram_0824,x
    sta ram_0842,x
    sta ram_069E,x
    sta ram_0680,x
    sta ram_0572,x
    sta ram_0608,x
    sta ram_04FA,x
    sta ram_0554,x
    sta ram_040A,x
    lda #<dat_5DB5
    sta ram_0482,x
    sta ram_04BE,x
    lda #>dat_5DB5
    sta ram_04A0,x
    sta ram_04DC,x
    rts

; cmdtype_handlers entry $0E; not executed in the make sndtrace runs
cmdtype_0E
    sta mix_shadow
    sta MIX
    rts

; read at 437E, 4382
; The 21 command-type handlers, each word the handler's address - 1 (dispatch_command pushes
; it and returns into it). Types 0C, 0F and 12 share one handler, which returns at once.
cmdtype_handlers
    .word cmdtype_00-1                  ; $00
    .word cmdtype_01-1                  ; $01
    .word cmdtype_02-1                  ; $02
    .word cmdtype_03-1                  ; $03
    .word cmdtype_04-1                  ; $04
    .word cmdtype_05-1                  ; $05
    .word cmdtype_06-1                  ; $06
    .word cmdtype_07-1                  ; $07
    .word cmdtype_08-1                  ; $08
    .word queue_response-1              ; $09
    .word cmdtype_0A-1                  ; $0A
    .word cmdtype_0B-1                  ; $0B
    .word loc_46A4-1                    ; $0C
    .word cmdtype_0D-1                  ; $0D
    .word cmdtype_0E-1                  ; $0E
    .word loc_46A4-1                    ; $0F
    .word cmdtype_10-1                  ; $10
    .word cmdtype_11-1                  ; $11
    .word loc_46A4-1                    ; $12
    .word cmdtype_13-1                  ; $13
    .word cmdtype_14-1                  ; $14

    .cerror * != $4759, "commands.asm must end at $4758"
