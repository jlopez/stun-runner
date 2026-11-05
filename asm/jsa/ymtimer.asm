; ymtimer.asm: 585E-5BAB, YM2151 channels 6-7 driven by the YM2151 timer interrupt.
;
; Generated once from the recursive descent and the MAME trace (docs/09-sound-program.md);
; hand-maintained from here on.

    .cerror * != $585E, "ymtimer.asm must start at $585E"

; from 42A9
sub_585E
    lda #$00
    sta zp_4C
    sta zp_4B
    sta zp_4D
    sta zp_10
    rts

; from 44CC; not executed in the make sndtrace runs
loc_5869
    lda zp_10
    beq _l586E
    rts
_l586E
    stx zp_4F
    php
    sei
    ldx ram_0884
    beq _l587E
    jsr sub_5B70
    bcs _l587E
_l587C
    plp
    rts
_l587E
    ldx ram_0885
    beq _l5888
    jsr sub_5B70
    bcc _l587C
_l5888
    sty zp_4E
    lda #$01
    sta zp_10
    lda #$06
    sta zp_0D
    lda #<dat_5B82
    sta zp_19
    lda #>dat_5B82
    sta zp_1A
    jsr sub_55B4
    clc
    lda #$20
    adc #$06
    tay
    jsr ym_wait
    sty YM2151_REG
    ldx zp_4E
    lda tbl_65DD+2,x
    and #$30
    asl a
    asl a
    sta zp_4F
    lda ram_08AE,y
    and #$3F
    ora zp_4F
    sta YM2151_DATA
    lda #$07
    sta zp_0D
    lda #<dat_5B82
    sta zp_19
    lda #>dat_5B82
    sta zp_1A
    jsr sub_55B4
    clc
    lda #$20
    adc #$07
    tay
    jsr ym_wait
    sty YM2151_REG
    ldx zp_4E
    lda tbl_65DD+2,x
    asl a
    asl a
    asl a
    asl a
    asl a
    asl a
    sta zp_4F
    lda ram_08AE,y
    and #$3F
    ora zp_4F
    sta YM2151_DATA
    lda #$20
    ora mix_shadow
    sta MIX
    sta MIX
    lda wrio_shadow
    and #$3F
    ora tbl_65DD+4,x
    sta wrio_shadow
    sta WRIO
    lda zp_4E
    asl a
    tax
    lda tbl_65DD,x
    sta zp_49
    lda tbl_65DD+1,x
    sta zp_4A
    ldy #$00
    lda (zp_49),y
    ldx #$2E
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$2F
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    inc zp_49
    bne _l5934
    inc zp_4A
_l5934
    lda (zp_49),y
    ldx #$86
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$8E
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$96
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$9E
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$87
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$8F
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$97
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    ldx #$9F
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    inc zp_49
    bne _l5994
    inc zp_4A
_l5994
    lda #$01
    sta zp_4C
    lda #$00
    ldx #$10
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$0A
    inx
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$15
    ldx #$14
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    plp
    rts

; from 41D1; not executed in the make sndtrace runs
sub_59C0
    tya
    pha
    lda zp_10
    bne _l59C9
    jmp _l5A49
_l59C9
    ldy #$00
    lda (zp_49),y
    beq _l59D2
    jmp _l5A59
_l59D2
    ldx #$06
    lda #$08
    jsr ym_wait
    sta YM2151_REG
    stx YM2151_DATA
    ldx #$07
    jsr ym_wait
    stx YM2151_DATA
    lda #$20
    eor #$FF
    and mix_shadow
    sta MIX
    sta MIX
    lda #$00
    sta zp_4B
    sta zp_4C
    sta zp_4D
    sta zp_10
    lda zp_1C
    pha
    lda zp_0C
    pha
    lda zp_19
    pha
    lda zp_1A
    pha
    lda zp_0D
    pha
    ldx ram_0884
    beq _l5A23
    dex
_l5A12
    lda ram_0860,x
    beq _l5A1C
    tax
    dex
    jmp _l5A12
_l5A1C
    lda #$06
    sta zp_0D
    jsr sub_559A
_l5A23
    ldx ram_0885
    beq _l5A3A
    dex
_l5A29
    lda ram_0860,x
    beq _l5A33
    tax
    dex
    jmp _l5A29
_l5A33
    lda #$07
    sta zp_0D
    jsr sub_559A
_l5A3A
    pla
    sta zp_0D
    pla
    sta zp_1A
    pla
    sta zp_19
    pla
    sta zp_0C
    pla
    sta zp_1C
_l5A49
    lda #$14
    ldx #$14
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    jmp _l5B60
_l5A59
    iny
    lda (zp_49),y
    ldx #$10
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$00
    inx
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$15
    ldx #$14
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda zp_4D
    bne _l5A9E
    lda #$06
    ldx #$08
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$7E
    jsr ym_wait
    sta YM2151_DATA
    inc zp_4D
    jmp _l5AB5
_l5A9E
    lda #$07
    ldx #$08
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    lda #$7F
    jsr ym_wait
    sta YM2151_DATA
    dec zp_4D
_l5AB5
    lda #$03
    cmp zp_4C
    bne _l5ABE
    jmp _l5B4B
_l5ABE
    lda #$01
    cmp zp_4C
    bne _l5ACA
    dey
    lda (zp_49),y
    sta zp_4B
    iny
_l5ACA
    inc zp_4C
    lda zp_4D
    beq _l5B0F
    ldx #$46
    jsr sub_5B63
    ldx #$4E
    jsr sub_5B63
    ldx #$56
    jsr sub_5B63
    ldx #$5E
    jsr sub_5B63
    ldx #$66
    jsr sub_5B63
    ldx #$6E
    jsr sub_5B63
    ldx #$76
    jsr sub_5B63
    ldx #$7E
    jsr sub_5B63
    ldx #$C6
    jsr sub_5B63
    ldx #$CE
    jsr sub_5B63
    ldx #$D6
    jsr sub_5B63
    ldx #$DE
    jsr sub_5B63
    jmp _l5B4B
_l5B0F
    ldx #$47
    jsr sub_5B63
    ldx #$4F
    jsr sub_5B63
    ldx #$57
    jsr sub_5B63
    ldx #$5F
    jsr sub_5B63
    ldx #$67
    jsr sub_5B63
    ldx #$6F
    jsr sub_5B63
    ldx #$77
    jsr sub_5B63
    ldx #$7F
    jsr sub_5B63
    ldx #$C7
    jsr sub_5B63
    ldx #$CF
    jsr sub_5B63
    ldx #$D7
    jsr sub_5B63
    ldx #$DF
    jsr sub_5B63
_l5B4B
    dec zp_4B
    bne _l5B60
    lda zp_49
    clc
    adc #$0E
    sta zp_49
    lda zp_4A
    adc #$00
    sta zp_4A
    lda #$01
    sta zp_4C
_l5B60
    pla
    tay
    rts

; from 5AD2, 5AD7, 5ADC, 5AE1, 5AE6, 5AEB, 5AF0, 5AF5, 5AFA, 5AFF, 5B04, 5B09, 5B11, 5B16, 5B1B,
; 5B20, 5B25, 5B2A, 5B2F, 5B34, 5B39, 5B3E, 5B43, 5B48; not executed in the make sndtrace runs
sub_5B63
    iny
    lda (zp_49),y
    jsr ym_wait
    stx YM2151_REG
    sta YM2151_DATA
    rts

; from 5877, 5883, 5B77; not executed in the make sndtrace runs
sub_5B70
    lda ram_0860,x
    beq _l5B7A
    tax
    dex
    jmp sub_5B70
_l5B7A
    lda zp_4F
    ora #$01
    cmp ram_03EC,x
    rts

dat_5B82
    .byte $C7, $00, $00, $00, $02, $7F, $19
    .byte $9F, $DF, $0A, $0D, $7F, $19, $9F
    .byte $1F, $0A, $05, $7F, $19, $9F, $DF
    .byte $0A, $0E, $7F, $19, $9F, $DF, $0A
    .byte $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $80, $00, $00, $00, $00

    .cerror * != $5BAC, "ymtimer.asm must end at $5BAB"
