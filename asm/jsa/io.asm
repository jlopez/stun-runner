; io.asm: 5CB8-5DB4, RDIO inputs and coin counters, two immediate commands.
;
; sub_5CE8 (every timed IRQ, from h_irq) reads the four low RDIO bits (coins 1-3 and an unused
; one in MAME's jsa_ii_ioports; stunrun's coins go to the main board, so they read 0 there),
; keeps their state in zp_75 and pulses the WRIO coin counters (bits 5-4, 5D95-5DA9). Two of
; h_nmi's immediate commands: imm_04 (command 08), a loop-back of one byte, and imm_01 (command
; 03), which sends zp_75.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on. sub_/loc_/tbl_/dat_/_lXXXX labels are
; neutral address labels for later legs to rename.

    .cerror * != $5CB8, "io.asm must start at $5CB8"

; imm_handlers entry 4; not executed in the make sndtrace runs
; Command 08 (cmd_class 03), inside the NMI: send AA, take the next byte the 68010 writes into
; zp_63 (sub_5CC5: nmi_mode 0, nmi_data_ptr = zp_63, wait until nmi_data_count is 1; h_nmi
; nests, the NMI being an edge), send that byte back, return to the command mode (loc_4548).
imm_04
    lda #$01
    jsr sub_5CC5
    lda zp_63
    jsr send_response
    jmp loc_4548

; from 5CBA; not executed in the make sndtrace runs
sub_5CC5
    sta zp_62
    lda #>zp_63
    sta @w nmi_data_ptr+1
    lda #<zp_63
    sta @w nmi_data_ptr
    lda #$00
    sta nmi_data_count
    lda #$00
    sta nmi_mode
    lda #$AA
    jsr send_response
_l5CE0
    lda nmi_data_count
    cmp zp_62
    bne _l5CE0
    rts

; from 4211 (h_irq, every timed IRQ)
sub_5CE8
    bit RDIO_M
    bpl loc_5D11
    ldx #$03
    lda RDIO_M
_l5CF2
    lsr a
    pha
    lda tbl_5D09,x
    bcs _l5CFB
    lda #$00
_l5CFB
    eor zp_75
    and tbl_5D0D,x
    eor zp_75
    sta zp_75
    pla
    dex
    bpl _l5CF2
    rts

; read at 5CF4, 5D48
tbl_5D09
    .byte $10, $40, $01, $04

; read at 5CFD, 5D50
tbl_5D0D
    .byte $30, $C0, $03, $0C

loc_5D11
    lda RDIO_M
    ldx #$03
_l5D16
    lsr a
    pha
    lda zp_6F,x
    and #$1F
    bcc _l5D35
    beq _l5D30
    cmp #$1B
    bcs _l5D2E
    pha
    lda zp_73
    and #$07
    cmp #$07
    pla
    bcc _l5D30
_l5D2E
    sbc #$01
_l5D30
    sta zp_6F,x
    jmp _l5D59
_l5D35
    cmp #$1B
    bcs _l5D42
    lda zp_6F,x
    adc #$20
    bcc _l5D30
    beq _l5D42
    clc
_l5D42
    lda #$1F
    sta zp_6F,x
    bcs _l5D59
    lda tbl_5D09,x
    clc
    adc zp_75
    eor zp_75
    and tbl_5D0D,x
    eor zp_75
    sta zp_75
    inc zp_67,x
_l5D59
    pla
    dex
    bpl _l5D16
    inc zp_73
    lda zp_73
    lsr a
    bcs _l5D95
    lda zp_67
    ora zp_68
    ora zp_69
    ora zp_6A
    beq _l5D95
    cmp #$10
    bcc _l5D85
    ldx #$03
_l5D74
    lda zp_67,x
    beq _l5D80
    cmp #$10
    bcc _l5D80
    adc #$EF
    sta zp_67,x
_l5D80
    dex
    bpl _l5D74
    bmi _l5D95
_l5D85
    ldx #$03
_l5D87
    lda zp_67,x
    beq _l5D92
    clc
    adc #$EF
    sta zp_67,x
    bmi _l5D95
_l5D92
    dex
    bpl _l5D87
_l5D95
    lda zp_67
    ora zp_69
    asl a
    lda zp_68
    ora zp_6A
    ror a
    lsr a
    lsr a
    eor wrio_shadow
    and #$30
    eor wrio_shadow
    sta wrio_shadow
    sta WRIO
    rts

; imm_handlers entry 1; not executed in the make sndtrace runs
; Command 03 (cmd_class 00), inside the NMI: send zp_75.
imm_01
    lda zp_75
    jsr send_response
    jmp loc_5849

    .cerror * != $5DB5, "io.asm must end at $5DB4"
