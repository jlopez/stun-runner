; oki.asm: 5BAC-5CB7, the OKI M6295 driver.
;
; The M6295 (okim6295.cpp) takes a two-byte start, 80 + the phrase number then the channel
; (bits 7-4, one bit per channel) and the attenuation (bits 3-0), and a one-byte stop (bits 6-3,
; one bit per channel); its status read has bits 3-0 set for the channels playing. tbl_5C63,
; tbl_5C67 and tbl_5C6B are those bits for channels 1-4. sub_5BAC resets it (WRIO bit 2 low,
; then high: called by imm_00); sub_5BC6 (every eighth timed IRQ) counts down each playing
; channel and stops it when its count runs out; cmdtype_13 (the commands of type 13, and stream
; op 95 with cmd_param) starts phrase tbl_6532,y on the channel tbl_6567,y names; cmdtype_14
; (command 66) stops the channel playing phrase A; sub_5C87 sets the YM2151 volume in MIX from
; the zp_5E values of the playing channels.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on. sub_/loc_/tbl_/dat_/_lXXXX labels are
; neutral address labels for later legs to rename.

    .cerror * != $5BAC, "oki.asm must start at $5BAC"

; from 423A
sub_5BAC
    lda wrio_shadow
    and #$FB
    sta WRIO
    ora #$04
    sta wrio_shadow
    sta WRIO
    lda #$01
    ldx #$11
    lda #$00
_l5BC0
    sta zp_56,x
    dex
    bpl _l5BC0
    rts

; from 420E
sub_5BC6
    dec zp_51
    bmi _l5BCB
    rts
_l5BCB
    lda #$07
    sta zp_51
    ldx #$03
_l5BD1
    lda tbl_5C67,x
    and OKI_READ_M
    beq _l5BEB
    dec zp_56,x
    bne _l5BF6
    dec zp_5A,x
    bne _l5BF6
    lda tbl_5C6B,x
    sta OKI_WRITE
    lda #$02
    sta zp_56,x
_l5BEB
    lda zp_5E,x
    beq _l5BF6
    lda #$00
    sta zp_5E,x
    jsr sub_5C87
_l5BF6
    dex
    bpl _l5BD1
    rts

; op_handlers entry for stream byte $95
op_95
    tay
    lda cmd_param,y

; cmdtype_handlers entry $13
cmdtype_13
    ldy @w zp_1E
    bne _l5C61
    php
    sei
    tay
    txa
    pha
    lda tbl_6567,y
    and #$30
    lsr a
    lsr a
    lsr a
    lsr a
    tax
    sty zp_50
    lda tbl_5C67,x
    and OKI_READ_M
    beq _l5C23
    ldy zp_52,x
    lda tbl_6567,y
    bmi _l5C5E
_l5C23
    lda tbl_5C6B,x
    sta OKI_WRITE
    ldy #$7F
_l5C2B
    nop
    dey
    bpl _l5C2B
    lda tbl_5C67,x
    and OKI_READ_M
    bne _l5C23
    ldy zp_50
    sty zp_52,x
    lda #$01
    sta zp_5A,x
    lda #$00
    sta zp_56,x
    lda tbl_6532,y
    ora #$80
    sta OKI_WRITE
    lda tbl_6567,y
    and #$0F
    ora tbl_5C63,x
    sta OKI_WRITE
    lda tbl_659C,y
    sta zp_5E,x
    jsr sub_5C87
_l5C5E
    pla
    tax
    plp
_l5C61
    sec
    rts

; read at 5C50
tbl_5C63
    .byte $10, $20, $40, $80

; read at 5BD1, 5C14, 5C2F
tbl_5C67
    .byte $01, $02, $04, $08

; read at 5BE1, 5C23, 5C7F
tbl_5C6B
    .byte $08, $10, $20, $40

; cmdtype_handlers entry $14; not executed in the make sndtrace runs
cmdtype_14
    php
    sei
    ldx #$03
_l5C73
    ldy zp_52,x
    cmp tbl_6532,y
    beq _l5C7F
    dex
    bpl _l5C73
    plp
    rts
_l5C7F
    lda tbl_5C6B,x
    sta OKI_WRITE
    plp
    rts

; from 5BF3, 5C5B
sub_5C87
    lda #$00
    sta zp_50
    ldy #$03
_l5C8D
    lda @w zp_5E,y
    cmp zp_50
    bcc _l5C96
    sta zp_50
_l5C96
    dey
    bpl _l5C8D
    lda zp_50
    lsr zp_50
    lda mix_shadow
    and #$0E
    lsr a
    sec
    sbc zp_50
    bpl _l5CA9
    lda #$00
_l5CA9
    asl a
    sta zp_50
    lda #$FF
    eor #$0E
    and mix_shadow
    ora zp_50
    sta MIX
    rts

    .cerror * != $5CB8, "oki.asm must end at $5CB7"
