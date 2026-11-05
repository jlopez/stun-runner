; sequencer.asm: 4759-57E2, the track interpreter and its YM2151 output.
;
; Generated once from the recursive descent and the MAME trace (docs/09-sound-program.md);
; hand-maintained from here on.

    .cerror * != $4759, "sequencer.asm must start at $4759"

; from 4CBD, 4E6E, 4E9F
sub_4759
    sta zp_0F
    ora ram_0860,x
    beq _l4762
    lda #$FF
_l4762
    sta zp_22
    lda ram_03EC,x
    beq _l4770
    ldy ram_0248,x
    iny
    bne _l4773
    tya
_l4770
    jmp loc_4941
_l4773
    and #$03
    sta ram_088F
    and #$01
    tay
    lda ram_03EC,x
    sta ram_088D,y
    lda ram_0266,x
    sta zp_06
    lda ram_0284,x
    sta zp_07
    lda ram_0572,x
    sta ram_08AB
    lda ram_02DE,x
    sec
    sbc ram_0626,x
    sta ram_02DE,x
    lda ram_02FC,x
    sbc ram_0644,x
    sta ram_02FC,x
    bcs _l47AE
    dec ram_031A,x
    bpl _l47AE
    jmp loc_484B
_l47AE
    lda ram_0374,x
    bmi _l47CD
    lda ram_0338,x
    sec
    sbc ram_0626,x
    sta ram_0338,x
    lda ram_0356,x
    sbc ram_0644,x
    sta ram_0356,x
    bcs _l47EB
    dec ram_0374,x
    bpl _l47EB
_l47CD
    lda ram_0899
    cmp #$02
    bne _l47E3
    lda #$01
    ora ram_08AB
    sta ram_08AB
    lda #$7F
    sta ram_0374,x
    bne _l47F5
_l47E3
    lda ram_088F
    beq _l47EB
    jmp loc_4C94
_l47EB
    lda ram_0899
    cmp #$02
    beq _l47F5
    jmp loc_4AE8
_l47F5
    lda ram_0608,x
    bne _l482F
    lda ram_078E,x
    ora ram_07AC,x
    bne _l480F
    ldy ram_0248,x
    cpy #$FE
    bne _l482F
    inc ram_0248,x
    jmp loc_4941
_l480F
    lda ram_05AE,x
    sec
    sbc ram_0626,x
    sta ram_05AE,x
    lda ram_05CC,x
    sbc ram_0644,x
    sta ram_05CC,x
    bcs _l482F
    dec ram_05EA,x
    bpl _l482F
    jsr sub_4CC1
    tya
    bne _l483A
_l482F
    lda ram_06DA,x
    beq _l4848
    lda zp_00
    and #$06
    bne _l4848
_l483A
    lda ram_02A2,x
    beq _l4848
    sta ram_0895
    lda ram_0392,x
    jsr sub_4D6C
_l4848
    jmp loc_4CB1

; op_handlers entry for stream byte $90, $91, $92, $93, $94, $98, $9A, $9C; from 47AB, 493E
loc_484B
    lda ram_0266,x
    clc
    adc #$02
    sta ram_0266,x
    bcc _l4859
    inc ram_0284,x
_l4859
    ldy #$00
    lda (zp_06),y
    bpl _l487E
    jsr sub_505D
    bcc _l4870
    lda ram_0284,x
    sta zp_07
    lda ram_0266,x
    sta zp_06
    bcs loc_484B
_l4870
    lda ram_088F
    and #$01
    tay
    lda #$00
    sta ram_088D,y
    jmp loc_4CB1
_l487E
    ldy ram_088F
    beq _l4887
    cmp #$00
    beq _l488B
_l4887
    clc
    adc ram_0662,x
_l488B
    ldy ram_0899
    cpy #$02
    beq _l48DD
    ldy ram_088F
    beq _l489B
    cpy #$01
    beq _l48B9
_l489B
    pha
    sec
    sbc ram_02A2,x
    sta ram_06F8,x
    asl a
    lda #$FF
    bcs _l48AA
    lda #$00
_l48AA
    sta ram_0716,x
    pla
    sta ram_02A2,x
    lda #$00
    sta ram_02C0,x
    jmp _l490C
_l48B9
    asl a
    tay
    sec
    lda ram_02A2,x
    sbc tbl_5DB9,y
    sta ram_06F8,x
    lda ram_02C0,x
    sbc tbl_5DB9+1,y
    sta ram_0716,x
    lda tbl_5DB9,y
    sta ram_02A2,x
    lda tbl_5DB9+1,y
    sta ram_02C0,x
    jmp _l490C
_l48DD
    sta zp_1B
    lda #$00
    sta ram_06F8,x
    sta ram_0716,x
    lda zp_1B
    beq _l48F6
    lda ram_02A2,x
    sec
    sbc zp_1B
    sta ram_0716,x
    lda zp_1B
_l48F6
    sta ram_02A2,x
    ldy zp_22
    bne _l490C
    sta ram_0895
    clc
    lda #$20
    adc zp_0D
    tay
    lda ram_0518,x
    sta ram_08AE,y
_l490C
    ldy #$01
    lda #$00
    sta zp_1C
    lda (zp_06),y
    beq _l4919
    jmp loc_497F
_l4919
    lda ram_0734,x
    beq loc_4941
    pha
    jsr sub_431A
    lda (zp_20),y
    sta ram_0734,x
    lda zp_1F
    sta (zp_20),y
    pla
    sta zp_1F
    iny
    lda (zp_20),y
    sta ram_0266,x
    sta zp_06
    iny
    lda (zp_20),y
    sta ram_0284,x
    sta zp_07
    jmp loc_484B

; from 4770, 480C, 4A71
loc_4941
    sta ram_03EC,x
    sta ram_0464,x
    sta ram_0392,x
    sta ram_078E,x
    sta ram_07AC,x
    sta ram_0895
    lda #$01
    ora ram_08AB
    sta ram_08AB
    jsr sub_433C
    lda ram_0860,x
    ldx ram_0898
    sta ram_0860,x
    ldy ram_0899
    cpy #$02
    bne _l497C
    cmp #$00
    bne _l4979
    cpx #$1E
    bcs _l4979
    jsr sub_5585
_l4979
    jmp loc_4CB1
_l497C
    jmp loc_4C94

; from 4916
loc_497F
    pha
    lda ram_088F
    bne _l4988
    jmp _l4A32
_l4988
    pla
    sta zp_1C
    and #$0F
    asl a
    tay
    lda tbl_5FE3,y
    clc
    adc ram_02FC,x
    sta ram_02FC,x
    lda tbl_5FE3+1,y
    adc ram_031A,x
    sta ram_031A,x
    lda zp_1C
    and #$40
    beq _l49BF
    lda tbl_5FE3+1,y
    lsr a
    pha
    lda tbl_5FE3,y
    ror a
    clc
    adc ram_02FC,x
    sta ram_02FC,x
    pla
    adc ram_031A,x
    sta ram_031A,x
_l49BF
    lda #$7F
    sta ram_0374,x
    lda zp_1C
    bmi _l4A05
    lda #$00
    sta zp_1B
    lda ram_0644,x
    sta zp_1A
    lda ram_0626,x
    asl a
    rol zp_1A
    rol zp_1B
    sta zp_19
    lda ram_02DE,x
    sec
    sbc zp_19
    sta ram_0338,x
    lda ram_02FC,x
    sbc zp_1A
    sta ram_0356,x
    lda ram_031A,x
    sbc zp_1B
    sta ram_0374,x
    lda zp_1C
    and #$30
    cmp #$10
    bne _l4A05
    lsr ram_0374,x
    ror ram_0356,x
    ror ram_0338,x
_l4A05
    lda ram_0392,x
    bpl _l4A17
    lda ram_06DA,x
    bne _l4A5F
    sta ram_06F8,x
    sta ram_0716,x
    beq _l4A5F
_l4A17
    lda #$00
    sta ram_06F8,x
    sta ram_0716,x
    lda zp_1C
    and #$38
    asl a
    sta ram_040A,x
    lda #$04
    ora ram_08AB
    sta ram_08AB
    jmp _l4A5F
_l4A32
    sta ram_040A,x
    sta ram_06F8,x
    sta ram_0716,x
    pla
    and #$7F
    lsr a
    ror zp_1C
    lsr a
    ror zp_1C
    lsr a
    ror zp_1C
    pha
    clc
    lda zp_1C
    adc ram_02FC,x
    sta ram_02FC,x
    pla
    adc ram_031A,x
    sta ram_031A,x
    lda (zp_06),y
    sta zp_1C
    sta ram_0392,x
_l4A5F
    lda ram_078E,x
    ora ram_07AC,x
    bne _l4A74
    ldy ram_0248,x
    cpy #$FE
    bne _l4A77
    inc ram_0248,x
    jmp loc_4941
_l4A74
    jsr sub_4CC1
_l4A77
    lda ram_0899
    cmp #$02
    bne _l4A8B
    lda zp_1C
    jsr sub_4D6C
    lda zp_1C
    sta ram_0392,x
    jmp loc_4CB1
_l4A8B
    lda ram_0392,x
    pha
    lda zp_1C
    sta ram_0392,x
    pla
    bmi loc_4AE8
    lda #$00
    tay
    sta ram_05AE,x
    sta ram_05CC,x
    sta ram_05EA,x
    sta ram_0608,x
    lda ram_04BE,x
    sta zp_06
    lda ram_04DC,x
    sta zp_07
    lda (zp_06),y
    sta ram_0590,x
    iny
    ora (zp_06),y
    iny
    ora (zp_06),y
    beq _l4AC1
    inc ram_0590,x
    tya
_l4AC1
    sta ram_0572,x
    lda #$00
    tay
    sta ram_0536,x
    sta ram_0554,x
    lda ram_0482,x
    sta zp_06
    lda ram_04A0,x
    sta zp_07
    lda (zp_06),y
    sta ram_0518,x
    iny
    ora (zp_06),y
    beq _l4AE5
    inc ram_0518,x
    tya
_l4AE5
    sta ram_04FA,x

; from 47F2; not executed in the make sndtrace runs
loc_4AE8
    ldy ram_088F
    beq _l4AF8
    lda ram_02A2,x
    ora ram_02C0,x
    bne _l4AF8
    jmp loc_4C94
_l4AF8
    lda zp_00
    and #$06
    bne _l4B08
    lda ram_0716,x
    asl a
    ror ram_0716,x
    ror ram_06F8,x
_l4B08
    lda ram_04BE,x
    sta zp_06
    lda ram_04DC,x
    sta zp_07
    ldy ram_0572,x
    bne _l4B1C
    tya
    clc
    jmp _l4BBB
_l4B1C
    dec ram_0590,x
    bne _l4B77
_l4B21
    iny
    lda (zp_06),y
    sta ram_0590,x
    iny
    cmp #$FF
    bne _l4B52
    lda ram_0608,x
    beq _l4B39
    dec ram_0608,x
    bne _l4B3E
    iny
    bne _l4B21
_l4B39
    lda (zp_06),y
    sta ram_0608,x
_l4B3E
    iny
    sec
    lda zp_06
    sbc (zp_06),y
    sta zp_06
    sta ram_04BE,x
    bcs _l4B21
    dec zp_07
    dec ram_04DC,x
    bcc _l4B21
_l4B52
    ora (zp_06),y
    iny
    cpy #$F9
    ora (zp_06),y
    bne _l4B62
    sta ram_0572,x
    tay
    clc
    beq _l4BBB
_l4B62
    tya
    bcc _l4B74
    sbc #$02
    adc ram_04BE,x
    sta ram_04BE,x
    lda #$01
    bcc _l4B74
    inc ram_04DC,x
_l4B74
    sta ram_0572,x
_l4B77
    lda #$00
    sta zp_1D
    lda (zp_06),y
    bpl _l4B81
    dec zp_1D
_l4B81
    sta zp_1C
    dey
    lda (zp_06),y
    asl a
    rol zp_1C
    rol zp_1D
    asl a
    rol zp_1C
    rol zp_1D
    asl a
    rol zp_1C
    rol zp_1D
    clc
    adc ram_05AE,x
    sta ram_05AE,x
    lda zp_1C
    adc ram_05CC,x
    sta ram_05CC,x
    sta zp_1C
    lda zp_1D
    adc ram_05EA,x
    sta ram_05EA,x
    tay
    lda ram_088F
    cmp #$02
    bne _l4BB8
    dec zp_1C
_l4BB8
    lda zp_1C
    clc
_l4BBB
    adc ram_02A2,x
    sta zp_1C
    tya
    adc ram_02C0,x
    tay
    clc
    lda zp_1C
    adc ram_06F8,x
    sta zp_1C
    tya
    adc ram_0716,x
    sta ram_0897
    lda ram_088F
    and #$01
    tay
    lda zp_1C
    sta ram_0895,y
    lda ram_0482,x
    sta zp_06
    lda ram_04A0,x
    sta zp_07
    ldy ram_04FA,x
    bne _l4BF4
_l4BEE
    lda ram_0464,x
    jmp _l4C8E
_l4BF4
    dec ram_0518,x
    bne _l4C4B
_l4BF9
    iny
    lda (zp_06),y
    sta ram_0518,x
    iny
    cmp #$FF
    bne _l4C2A
    lda ram_0554,x
    beq _l4C11
    dec ram_0554,x
    bne _l4C16
    iny
    bne _l4BF9
_l4C11
    lda (zp_06),y
    sta ram_0554,x
_l4C16
    iny
    sec
    lda zp_06
    sbc (zp_06),y
    sta zp_06
    sta ram_0482,x
    bcs _l4BF9
    dec zp_07
    dec ram_04A0,x
    bcc _l4BF9
_l4C2A
    cpy #$F9
    ora (zp_06),y
    bne _l4C36
    sta ram_04FA,x
    jmp _l4BEE
_l4C36
    tya
    bcc _l4C48
    sbc #$02
    adc ram_0482,x
    sta ram_0482,x
    lda #$01
    bcc _l4C48
    inc ram_04A0,x
_l4C48
    sta ram_04FA,x
_l4C4B
    lda (zp_06),y
    clc
    adc ram_0536,x
    bvc _l4C59
    lda #$80
    bcs _l4C59
    lda #$7F
_l4C59
    sta ram_0536,x
    ldy ram_040A,x
    clc
    adc tbl_6013,y
    bvc _l4C6B
    lda #$80
    bcs _l4C6B
    lda #$7F
_l4C6B
    pha
    tya
    and #$0F
    cmp #$0F
    beq _l4C76
    inc ram_040A,x
_l4C76
    pla
    lsr a
    lsr a
    lsr a
    cmp #$10
    bcc _l4C80
    ora #$F0
_l4C80
    clc
    adc ram_0464,x
    bpl _l4C88
    lda #$00
_l4C88
    cmp #$10
    bcc _l4C8E
    lda #$0F
_l4C8E
    ora ram_06BC,x
    jmp loc_4C96

; from 47E8, 497C, 4AF5; not executed in the make sndtrace runs
loc_4C94
    lda #$00

; from 4C91; not executed in the make sndtrace runs
loc_4C96
    pha
    lda ram_088F
    and #$01
    tay
    pla
    sta ram_0893,y
    cpx #$1E
    bcs loc_4CB1
    lda ram_0446,x
    sta ram_089A,y
    lda ram_0428,x
    sta ram_089E,y

; from 4848, 487B, 4979, 4A88
loc_4CB1
    lda ram_0860,x
    beq _l4CC0
    stx ram_0898
    tax
    dex
    lda zp_0F
    jmp sub_4759
_l4CC0
    rts

; from 4829, 4A74
sub_4CC1
    lda ram_07CA,x
    sta zp_19
    lda ram_07E8,x
    sta zp_1A
    lda zp_1C
    pha
    lda ram_0608,x
    bne _l4CE3
    lda tbl_5FE3+$14
    sta ram_05CC,x
    lda tbl_5FE3+$15
    sta ram_05EA,x
    lda #$0A
    bne _l4CE5
_l4CE3
    lda zp_1C
_l4CE5
    and #$0F
    tay
    lda tbl_6003,y
    sta zp_1C
    cmp #$FF
    bne _l4D03
    lda ram_07AC,x
    bne _l4CFB
    sta ram_078E,x
    beq _l4CFE
_l4CFB
    dec ram_07AC,x
_l4CFE
    lda zp_1A
    jmp _l4D63
_l4D03
    lda ram_078E,x
    sec
    sbc zp_1C
    sta ram_078E,x
    bcs _l4D1B
    dec ram_07AC,x
    bpl _l4D1B
    lda #$00
    sta ram_078E,x
    sta ram_07AC,x
_l4D1B
    ldy #$07
    lda zp_1A
_l4D1F
    cmp #$80
    ror a
    ror zp_19
    dey
    bmi _l4D2B
    asl zp_1C
    bcc _l4D1F
_l4D2B
    ldy #$00
    sty zp_1C
    sta zp_1A
    cmp #$80
    bcc _l4D48
    sta zp_1C
    eor #$FF
    sta zp_1A
    lda zp_19
    eor #$FF
    clc
    adc #$01
    sta zp_19
    bcc _l4D48
    inc zp_1A
_l4D48
    lda ram_0806,x
    clc
    adc zp_19
    sta ram_0806,x
    bcc _l4D55
    inc zp_1A
_l4D55
    lda zp_1A
    tay
    beq _l4D68
    ldy zp_1C
    bpl _l4D63
    eor #$FF
    clc
    adc #$01
_l4D63
    jsr sub_51C7
    ldy #$FF
_l4D68
    pla
    sta zp_1C
    rts

; from 4845, 4A80
sub_4D6C
    ldy zp_22
    bne _l4DBE
    and #$30
    beq _l4D79
    ora ram_08AB
    bne _l4D7C
_l4D79
    lda ram_08AB
_l4D7C
    ora #$02
    sta ram_08AB
    lda #$03
    sta zp_19
    txa
    pha
    clc
    lda #$60
    adc zp_0D
    tay
_l4D8D
    lda ram_0482,x
    sta ram_08AE,y
    tya
    clc
    adc #$08
    tay
    txa
    clc
    adc #$1E
    tax
    dec zp_19
    bpl _l4D8D
    pla
    tax
    lda ram_0428,x
    sta zp_19
    lda ram_0446,x
    sta zp_1A
    ldy #$08
    lda ram_04FA,x
    sta ram_08A2,y
    dey
_l4DB6
    lda (zp_19),y
    sta ram_08A2,y
    dey
    bne _l4DB6
_l4DBE
    lda ram_06DA,x
    beq _l4E12
    lda ram_0716,x
    ora ram_06F8,x
    beq _l4E12
    lda zp_00
    and #$06
    bne _l4E12
    lda #$00
    sta zp_1A
    lda ram_06DA,x
    asl a
    rol zp_1A
    sta zp_19
    lda ram_0716,x
    bmi _l4DF7
    lda ram_06F8,x
    sec
    sbc zp_19
    sta ram_06F8,x
    lda ram_0716,x
    sbc zp_1A
    sta ram_0716,x
    bpl _l4E12
    bmi _l4E0A
_l4DF7
    lda ram_06F8,x
    clc
    adc zp_19
    sta ram_06F8,x
    lda ram_0716,x
    adc zp_1A
    sta ram_0716,x
    bmi _l4E12
_l4E0A
    lda #$00
    sta ram_0716,x
    sta ram_06F8,x
_l4E12
    lda zp_22
    bne _l4E55
    lda ram_06F8,x
    sta ram_0897
    lda ram_0716,x
    sta ram_0896
    bpl _l4E32
    dec ram_0896
    lda ram_0897
    eor #$FF
    clc
    adc #$01
    sta ram_0897
_l4E32
    clc
    lda #$30
    adc zp_0D
    tay
    lda ram_0464,x
    clc
    adc ram_0897
    bcc _l4E44
    inc ram_0896
_l4E44
    and #$FC
    sta ram_08AE,y
    lda ram_0895
    beq _l4E55
    clc
    adc ram_0896
    sta ram_0895
_l4E55
    rts

; from 5057
loc_4E56
    lda #$05
    sta zp_48
    lda tbl_57E1,x
    clc
    adc #$05
    tay
_l4E61
    tya
    pha
    ldx ram_0860,y
    beq _l4E71
    sty ram_0898
    dex
    lda #$00
    jsr sub_4759
_l4E71
    pla
    tay
    dey
    dec zp_48
    bpl _l4E61
    rts

; from 501B
sub_4E79
    ldx ram_0860,y
    bne _l4E7F
    rts
_l4E7F
    dex
    lda #$00
    sta ram_088E
    sta ram_0895
    sty ram_0898
    lda zp_10
    beq _l4E9F
    lda zp_0D
    cmp #$06
    beq _l4E9D
    cmp #$07
    beq _l4E9D
    lda #$00
    beq _l4E9F
_l4E9D
    lda #$FF
_l4E9F
    jsr sub_4759
    lda zp_22
    beq _l4EA7
_l4EA6
    rts
_l4EA7
    clc
    lda #$20
    adc zp_0D
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda ram_08AE,y
    sta YM2151_DATA
    lda #$30
    clc
    adc zp_0D
    tay
    jsr ym_wait
    sty YM2151_REG
    lda ram_08AE,y
    sta YM2151_DATA
    plp
    lsr ram_08AB
    bcc _l4EE3
    ldy #$08
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda zp_0D
    sta YM2151_DATA
    plp
_l4EE3
    lda ram_088E
    cmp zp_1E
    bcc _l4EA6
    lsr ram_08AB
    bcc _l4EA6
    ldx ram_0895
    beq _l4EA6
    clc
    lda zp_0D
    adc #$28
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda tbl_5E7D,x
    sta ram_08AE,y
    sta YM2151_DATA
    plp
    sta ram_0895
    lda #$20
    clc
    adc zp_0D
    tax
    lda ram_08AE,x
    and #$07
    tax
    lda tbl_57D3,x
    sta zp_1A
    ldy #$06
    sty zp_0C
    lda ram_08AB
    lsr a
    lsr a
    and #$03
    tax
    lda tbl_5FDF,x
    sta ram_088F
    lda ram_08A4,y
    sec
    sbc ram_088F
    bmi _l4F3F
    bvc _l4F3F
    lda #$80
_l4F3F
    sta zp_19
    sta zp_1B
    cmp #$80
    beq _l4F50
    bcc _l4F54
    eor #$FF
    clc
    adc #$01
    bne _l4F52
_l4F50
    lda #$7F
_l4F52
    sta zp_19
_l4F54
    asl zp_19
_l4F56
    ldy zp_0C
    lda ram_08A3,y
    lsr a
    lsr a
    lsr a
    lsr a
    sta ram_088F
    lda ram_0895
    ora ram_08A2,y
    tay
    lda tbl_AB48,y
    eor ram_088F
    and #$F0
    eor ram_088F
    tay
    lda tbl_5EDF,y
    sta ram_088C
    ldy zp_0C
    lda ram_08A3,y
    eor zp_19
    and #$0F
    eor zp_19
    tay
    lda tbl_5EDF,y
    sta zp_1C
    rol zp_1A
    bcs _l4F92
    asl zp_1C
_l4F92
    lda zp_1B
    bpl _l4F9F
    lda zp_1C
    eor #$FF
    clc
    adc #$01
    sta zp_1C
_l4F9F
    clc
    lda zp_0C
    asl a
    asl a
    adc zp_0D
    adc #$60
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    clc
    jsr ym_wait
    lda ram_08AE,y
    adc ram_088C
    bmi _l4FC8
    clc
    adc zp_1C
    bpl _l4FCA
    bvs _l4FC8
    lda #$00
    beq _l4FCA
_l4FC8
    lda #$7F
_l4FCA
    sta YM2151_DATA
    plp
    dec zp_0C
    dec zp_0C
    bmi _l4FD7
    jmp _l4F56
_l4FD7
    lsr ram_08AB
    bcc _l500D
    php
    sei
    lda ram_08AB
    and #$10
    beq _l4FFA
    ldx #$01
    jsr ym_wait
    stx YM2151_REG
    lda #$02
    sta YM2151_DATA
    jsr ym_wait
    lda #$00
    sta YM2151_DATA
_l4FFA
    ldy #$08
    jsr ym_wait
    sty YM2151_REG
    lda zp_0D
    ora #$78
    sta YM2151_DATA
    sta ram_08AE,y
    plp
_l500D
    rts

; from 505A
loc_500E
    lda #$07
    sta zp_0D
    clc
    lda tbl_57E1,x
    adc #$07
    tay
_l5019
    tya
    pha
    jsr sub_4E79
    pla
    tay
    dey
    dec zp_0D
    bpl _l5019
    rts

; from 427A, 4286, 428E, 4295, 42A6, 42AE, 439A, 4EAF, 4EC1, 4ED7, 4EFC, 4FAB, 4FB2, 4FE7, 4FF2, 4FFC, 55B8, 55D0, 55F2, 5613, 56A8, 58A3, 58D3, 591A, 5925, 5938, 5943, 594E, 5959, 5964, 596F, 597A, 5985, 599C, 59A8, 59B5, 59D6, 59E1, 5A4D, 5A5E, 5A6A, 5A77, 5A88, 5A93, 5AA2, 5AAD, 5B66
ym_wait
    bit zp_0E
    bmi _l5042
    pha
    lda #$00
    clc
_l502E
    bit YM2151_DATA
    bpl _l5041
    adc #$01
    cmp #$FF
    bne _l502E
    sta zp_0E
    lda zp_02
    ora #$02
    sta zp_02
_l5041
    pla
_l5042
    rts

; from 4230, 4235
loc_5043
    lda tbl_57DB,x
    sta zp_08
    lda tbl_57DD,x
    sta zp_09
    lda tbl_57DF,x
    sta ram_0899
    cmp #$03
    bne _l505A
    jmp loc_4E56
_l505A
    jmp loc_500E

; from 485F
sub_505D
    cmp #$BB
    bcc _l5068
    lda #$FF
    sta ram_0248,x
    clc
    rts
_l5068
    iny
    stx zp_1C
    asl a
    tax
    lda op_handlers+1,x
    pha
    lda op_handlers,x
    pha
    ldx zp_1C
    lda (zp_06),y
    sec
    rts

; from 518E, 5199, 51A9, 51B8, 5237, 52C2, 537D, 5380, 5389, 53A4, 53A7, 53B0, 547A, 547D, 5482, 5487, 5531, 554A, 555A, 5641, 5685
sub_507B
    lda ram_0266,x
    clc
    adc #$01
    sta ram_0266,x
    bcc _l5089
    inc ram_0284,x
_l5089
    iny
    lda (zp_06),y
    rts

; from 452E; not executed in the make sndtrace runs
loc_508D
    php
    sei
_l508F
    lda ram_0860,x
    beq _l50A1
    tax
    dex
    lda ram_0248,x
    cmp ram_08AC
    bne _l508F
    jsr sub_50A3
_l50A1
    plp
    rts

; from 509E; not executed in the make sndtrace runs
sub_50A3
    lda op_handlers+1,y
    pha
    lda op_handlers,y
    pha
    lda ram_08AD
    rts

; read at 506D, 5071, 50A3, 50A7
op_handlers
    .word op_80-1                       ; $80
    .word op_81-1                       ; $81
    .word op_82-1                       ; $82
    .word op_83-1                       ; $83
    .word op_84-1                       ; $84
    .word op_85-1                       ; $85
    .word op_86-1                       ; $86
    .word op_87-1                       ; $87
    .word op_88-1                       ; $88
    .word op_89-1                       ; $89
    .word op_8A-1                       ; $8A
    .word op_8B-1                       ; $8B
    .word op_8C-1                       ; $8C
    .word op_8D-1                       ; $8D
    .word op_8E-1                       ; $8E
    .word op_8F-1                       ; $8F
    .word loc_484B-1                    ; $90
    .word loc_484B-1                    ; $91
    .word loc_484B-1                    ; $92
    .word loc_484B-1                    ; $93
    .word loc_484B-1                    ; $94
    .word op_95-1                       ; $95
    .word op_96-1                       ; $96
    .word op_97-1                       ; $97
    .word loc_484B-1                    ; $98
    .word op_99-1                       ; $99
    .word loc_484B-1                    ; $9A
    .word op_9B-1                       ; $9B
    .word loc_484B-1                    ; $9C
    .word op_9D-1                       ; $9D
    .word op_9E-1                       ; $9E
    .word op_9F-1                       ; $9F
    .word op_A0-1                       ; $A0
    .word op_A1-1                       ; $A1
    .word op_A2-1                       ; $A2
    .word op_A3-1                       ; $A3
    .word op_A4-1                       ; $A4
    .word cmdtype_11-1                  ; $A5
    .word op_A6-1                       ; $A6
    .word op_A7-1                       ; $A7
    .word op_A8-1                       ; $A8
    .word op_A9-1                       ; $A9
    .word op_AA-1                       ; $AA
    .word op_AB-1                       ; $AB
    .word op_AC-1                       ; $AC
    .word op_AD-1                       ; $AD
    .word op_AE-1                       ; $AE
    .word op_AF-1                       ; $AF
    .word op_B0-1                       ; $B0
    .word op_B1-1                       ; $B1
    .word op_B2-1                       ; $B2
    .word op_B3-1                       ; $B3
    .word op_B4-1                       ; $B4
    .word op_B5-1                       ; $B5
    .word op_B6-1                       ; $B6
    .word op_B7-1                       ; $B7
    .word op_B8-1                       ; $B8
    .word op_B9-1                       ; $B9
    .word op_BA-1                       ; $BA

; op_handlers entry for stream byte $88; not executed in the make sndtrace runs
op_88
    lda #$00
    sta ram_02DE,x
    sta ram_02FC,x
    sta ram_031A,x
    ldy ram_0680,x
    beq _l513D
    iny
    bne _l5170
_l5138
    sta ram_0680,x
    sec
    rts
_l513D
    lda ram_069E,x
    sta ram_0680,x
    ldy #$1D
_l5145
    cmp ram_069E,y
    bne _l5157
    cmp ram_0680,y
    beq _l5157
    lda ram_03EC,y
    bne _l5170
    lda ram_069E,x
_l5157
    dey
    bpl _l5145
    ldy #$1D
_l515C
    cmp ram_069E,y
    bne _l5169
    lda #$FF
    sta ram_0680,y
    lda ram_069E,x
_l5169
    dey
    bpl _l515C
    lda #$00
    beq _l5138
_l5170
    lda ram_0266,x
    cmp #$02
    bcs _l517A
    dec ram_0284,x
_l517A
    dec ram_0266,x
    dec ram_0266,x
    clc
    rts

; op_handlers entry for stream byte $89; not executed in the make sndtrace runs
op_89
    sta ram_069E,x
    lda #$00
    sta ram_0680,x
    rts

; op_handlers entry for stream byte $87; not executed in the make sndtrace runs
op_87
    sta ram_0482,x
    jsr sub_507B
    sta ram_04A0,x
    sec
    rts

; op_handlers entry for stream byte $86; not executed in the make sndtrace runs
op_86
    sta ram_04BE,x
    jsr sub_507B
    sta ram_04DC,x
    sec
    rts

; op_handlers entry for stream byte $81; not executed in the make sndtrace runs
op_81
    clc
    adc ram_0626,x
    sta ram_0626,x
    php
    jsr sub_507B
    plp

; from 5442; not executed in the make sndtrace runs
loc_51AD
    adc ram_0644,x
    sta ram_0644,x
    sec
    rts

; op_handlers entry for stream byte $80
op_80
    sta ram_0626,x
    jsr sub_507B

; from 5408
loc_51BB
    sta ram_0644,x
    sec
    rts

; op_handlers entry for stream byte $83; from 5446
op_83
    ldy ram_0248,x
    cpy #$FE
    beq loc_51F7

; from 4D63
sub_51C7
    ldy ram_0899
    cpy #$02
    bne _l51D1
    jmp op_A1
_l51D1
    clc
    adc ram_0464,x
    bpl _l51D9
    lda #$00
_l51D9
    cmp #$10
    bcc loc_51F2
    lda #$0F
    bne loc_51F2

; op_handlers entry for stream byte $82; from 540C
op_82
    ldy ram_0248,x
    cpy #$FE
    beq loc_51F7
    ldy ram_0899
    cpy #$02
    bne loc_51F2
    jmp loc_5788

; not executed in the make sndtrace runs
loc_51F2
    sta ram_0464,x
    sec
    rts

loc_51F7
    clc
    rts

; op_handlers entry for stream byte $85; from 543A; not executed in the make sndtrace runs
op_85
    clc
    adc ram_0662,x

; op_handlers entry for stream byte $84; from 5401
op_84
    sta ram_0662,x
    sec
    rts

; op_handlers entry for stream byte $8A; not executed in the make sndtrace runs
op_8A
    sta ram_06BC,x
    rts

; op_handlers entry for stream byte $8B; not executed in the make sndtrace runs
op_8B
    ldy ram_0899
    beq _l5213
    eor ram_089A
    and #$09
    eor ram_089A
_l5213
    ora ram_0446,x
    sta ram_0446,x
    rts

; op_handlers entry for stream byte $9B; not executed in the make sndtrace runs
op_9B
    eor #$FF
    ldy ram_0899
    bne _l5228
    and ram_0428,x
    sta ram_0428,x
    rts
_l5228
    ora #$F6
    and ram_0446,x
    sta ram_0446,x
    rts

; op_handlers entry for stream byte $8C; not executed in the make sndtrace runs
op_8C
    sta ram_06DA,x
    rts

; op_handlers entry for stream byte $8D
op_8D
    sta zp_1C
    jsr sub_507B
    sta zp_1D
    jsr sub_4309
    beq _l5261
    pha
    lda ram_0734,x
    sta (zp_20),y
    pla
    sta ram_0734,x
    iny
    lda ram_0266,x
    sta (zp_20),y
    iny
    lda ram_0284,x
    sta (zp_20),y
    lda zp_1C
    sta ram_0266,x
    lda zp_1D
    sta ram_0284,x
_l5261
    sec
    rts

; op_handlers entry for stream byte $8E
op_8E
    pha
    jsr sub_4309
    beq _l528B
    pha
    lda ram_0752,x
    sta (zp_20),y
    pla
    sta ram_0752,x
    iny
    lda ram_0266,x
    sta (zp_20),y
    iny
    lda ram_0284,x
    sta (zp_20),y
    iny
    lda ram_0770,x
    sta (zp_20),y
    pla
    sta ram_0770,x
    sec
    rts
_l528B
    pla
    sec
    rts

; op_handlers entry for stream byte $8F
op_8F
    lda ram_0752,x
    beq _l52A7
    jsr sub_431A
    dec ram_0770,x
    beq _l52A9
    iny
    lda (zp_20),y
    sta ram_0266,x
    iny
    lda (zp_20),y
    sta ram_0284,x
_l52A7
    sec
    rts
_l52A9
    pha
    lda (zp_20),y
    sta ram_0752,x
    lda zp_1F
    sta (zp_20),y
    pla
    sta zp_1F
    iny
    iny
    iny
    lda (zp_20),y
    sta ram_0770,x
    sec
    rts

; op_handlers entry for stream byte $A4
op_A4
    sta zp_1C
    jsr sub_507B
    ldy ram_0248,x
    cpy #$FE
    beq _l52EB
    sta ram_07E8,x
    lda zp_1C
    lsr a
    lsr a
    lsr a
    sta ram_07AC,x
    lda #$00
    sta ram_078E,x
    sta ram_0806,x
    lda zp_1C
    asl a
    asl a
    asl a
    asl a
    asl a
    sta ram_07CA,x
    sec
    rts
_l52EB
    clc
    rts

; op_handlers entry for stream byte $A9
op_A9
    clc
    adc ram_0824,x

; from 5300, 5306, 530C, 5312, 533F, 536C, 53C1, 544E
loc_52F1
    sta ram_0824,x
    sta ram_0842,x
    sec
    rts

; op_handlers entry for stream byte $AA; not executed in the make sndtrace runs
op_AA
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    jmp loc_52F1

; op_handlers entry for stream byte $AB
op_AB
    and ram_0824,x
    jmp loc_52F1

; op_handlers entry for stream byte $AC; not executed in the make sndtrace runs
op_AC
    ora ram_0824,x
    jmp loc_52F1

; op_handlers entry for stream byte $AD; not executed in the make sndtrace runs
op_AD
    eor ram_0824,x
    jmp loc_52F1

; op_handlers entry for stream byte $B3; not executed in the make sndtrace runs
op_B3
    clc
    tay
    lda ram_0824,x
    cpy #$04
    beq _l533B
    cpy #$02
    beq _l533D
    cpy #$06
    beq _l5339
    cpy #$07
    beq _l5338
    cpy #$05
    beq _l533A
    cpy #$03
    beq _l533C
    cpy #$01
    beq _l533E
    sec
    rts
_l5338
    lsr a
_l5339
    lsr a
_l533A
    lsr a
_l533B
    lsr a
_l533C
    lsr a
_l533D
    lsr a
_l533E
    lsr a
    jmp loc_52F1

; op_handlers entry for stream byte $B4; not executed in the make sndtrace runs
op_B4
    clc
    tay
    lda ram_0824,x
    cpy #$04
    beq _l5368
    cpy #$02
    beq _l536A
    cpy #$06
    beq _l5366
    cpy #$07
    beq _l5365
    cpy #$05
    beq _l5367
    cpy #$03
    beq _l5369
    cpy #$01
    beq _l536B
    sec
    rts
_l5365
    asl a
_l5366
    asl a
_l5367
    asl a
_l5368
    asl a
_l5369
    asl a
_l536A
    asl a
_l536B
    asl a
    jmp loc_52F1

; op_handlers entry for stream byte $AE
op_AE
    sta zp_1C
    lda ram_0824,x
    bne _l537B
    lda zp_1C
    jmp _l5389
_l537B
    sta zp_1B
_l537D
    jsr sub_507B
    jsr sub_507B
    sta zp_1C
    dec zp_1B
    bne _l537D
_l5389
    jsr sub_507B
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; op_handlers entry for stream byte $AF; not executed in the make sndtrace runs
op_AF
    sta zp_1C
    lda ram_0824,x
    bne _l53A2
    lda zp_1C
    jmp _l53B0
_l53A2
    sta zp_1B
_l53A4
    jsr sub_507B
    jsr sub_507B
    sta zp_1C
    dec zp_1B
    bne _l53A4
_l53B0
    jsr sub_507B
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    inc ram_0824,x
    lda ram_0824,x
    jmp loc_52F1

; op_handlers entry for stream byte $B0
op_B0
    cmp #$26
    bcs _l540F
    cmp #$06
    bcc _l53D8
    sbc #$06
    tay
    lda ram_0824,x
    sta @w zp_23,y
    jmp _l540F
_l53D8
    cmp #$05
    beq _l540F
    ldy ram_0899
    cpy #$02
    bne _l53F5
    tay
    lda ram_0824,x
    cpy #$04
    bcc _l53EE
    jmp op_A6
_l53EE
    cpy #$03
    bcc _l53FD
    jmp op_A2
_l53F5
    cmp #$03
    bcs _l540F
    tay
    lda ram_0824,x
_l53FD
    cpy #$02
    bcc _l5404
    jmp op_84
_l5404
    cpy #$01
    bcc _l540B
    jmp loc_51BB
_l540B
    sec
    jmp op_82
_l540F
    sec
    rts

; op_handlers entry for stream byte $B1; not executed in the make sndtrace runs
op_B1
    ldy ram_0899
    cpy #$02
    bne _l542E
    tay
    cpy #$05
    bcs _l5449
    lda ram_0824,x
    cpy #$04
    bcc _l5427
    jmp op_A7
_l5427
    cpy #$03
    bcc _l5436
    jmp op_A3
_l542E
    cmp #$03
    bcs _l5449
    tay
    lda ram_0824,x
_l5436
    cpy #$02
    bcc _l543D
    jmp op_85
_l543D
    cpy #$01
    bcc _l5445
    clc
    jmp loc_51AD
_l5445
    sec
    jmp op_83
_l5449
    sec
    rts

; op_handlers entry for stream byte $B2
op_B2
    jsr sub_5494
    jmp loc_52F1

; op_handlers entry for stream byte $B9; not executed in the make sndtrace runs
op_B9
    jsr sub_5494

; op_handlers entry for stream byte $BA
op_BA
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    sta ram_0842,x
    sec
    rts

; op_handlers entry for stream byte $B5
op_B5
    jsr sub_5494
    beq loc_5482
    bne loc_547A

; op_handlers entry for stream byte $B6; not executed in the make sndtrace runs
op_B6
    jsr sub_5494
    bne loc_5482
    beq loc_547A

; op_handlers entry for stream byte $B7
op_B7
    jsr sub_5494
    bpl loc_5482
    bmi loc_547A

; op_handlers entry for stream byte $B8
op_B8
    jsr sub_5494
    bmi loc_5482

loc_547A
    jsr sub_507B
    jsr sub_507B
    sec
    rts

loc_5482
    jsr sub_507B
    sta zp_1C
    jsr sub_507B
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; from 544B, 5451, 5460, 5467, 546E, 5475
sub_5494
    sty zp_1C
    cmp #$26
    bcs _l54FE
    cmp #$06
    bcs _l54EB
    cmp #$05
    beq _l54F6
    ldy ram_0899
    cpy #$02
    bne _l54CD
    cmp #$04
    bcc _l54B3
    ldy zp_1C
    lda ram_0464,x
    rts
_l54B3
    cmp #$03
    bcc _l54C2
    ldy zp_1C
    lda ram_04FA,x
    eor #$FF
    clc
    adc #$01
    rts
_l54C2
    cmp #$02
    beq _l54D5
    cmp #$01
    beq _l54DF
    ldy zp_1C
    rts
_l54CD
    cmp #$03
    bcs _l54FE
    cmp #$02
    bcc _l54DB
_l54D5
    ldy zp_1C
    lda ram_0662,x
    rts
_l54DB
    cmp #$01
    bcc _l54E5
_l54DF
    ldy zp_1C
    lda ram_0644,x
    rts
_l54E5
    ldy zp_1C
    lda ram_0464,x
    rts
_l54EB
    sbc #$06
    tay
    lda @w zp_23,y
    pha
    ldy zp_1C
    pla
    rts
_l54F6
    jsr sub_5504
    pha
    ldy zp_1C
    pla
    rts
_l54FE
    ldy zp_1C
    lda ram_0842,x
    rts

; from 4149, 54F6
sub_5504
    lda zp_47
    asl a
    bcc _l550B
    eor #$1D
_l550B
    sta zp_47
    rts

; op_handlers entry for stream byte $96; not executed in the make sndtrace runs
op_96
    jsr queue_response
    sec
    rts

; op_handlers entry for stream byte $97; not executed in the make sndtrace runs
op_97
    lda #$00
    sta ram_078E,x
    sta ram_0806,x
    sta ram_07CA,x
    lda #$D0
    sta ram_07E8,x
    lda #$02
    sta ram_07AC,x
    lda #$FE
    sta ram_0248,x
    sec
    rts

; op_handlers entry for stream byte $99
op_99
    sta zp_1C
    jsr sub_507B
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; op_handlers entry for stream byte $9D
op_9D
    sta zp_1C
    lda ram_0248,x
    cmp #$FE
    bne _l554F
    inc ram_0248,x
    jsr sub_507B
    clc
    rts
_l554F
    php
    sei
    lda zp_1C
    stx zp_1C
    sta zp_19
    sta ram_0536,x
    jsr sub_507B
    sta zp_1A
    sta ram_0554,x
    plp
    ldy #$00
    lda (zp_19),y
    sta ram_0518,x
    lda #$03
    sta zp_0C
    ldy #$05
_l5570
    lda (zp_19),y
    sta ram_0482,x
    tya
    clc
    adc #$06
    tay
    txa
    clc
    adc #$1E
    tax
    dec zp_0C
    bpl _l5570
    ldx zp_1C

; from 4976
sub_5585
    php
    sei
    ldy zp_22
    beq _l558E
    jmp loc_5638
_l558E
    stx zp_1C
    ldy ram_0899
    cpy #$02
    beq loc_559C
    jmp loc_5638

; from 5A20, 5A37; not executed in the make sndtrace runs
sub_559A
    php
    sei

loc_559C
    lda ram_0536,x
    sta zp_19
    clc
    adc #$1C
    sta ram_0428,x
    lda ram_0554,x
    sta zp_1A
    adc #$00
    sta ram_0446,x
    jmp loc_55B6

; from 589A, 58CA; not executed in the make sndtrace runs
sub_55B4
    php
    sei

; from 55B1
loc_55B6
    ldx #$08
    jsr ym_wait
    stx YM2151_REG
    lda zp_0D
    sta YM2151_DATA
    sta ram_08AE,x
    lda #$03
    sta zp_0C
    clc
    lda #$60
    adc zp_0D
_l55CF
    tax
    jsr ym_wait
    stx YM2151_REG
    lda #$7F
    sta ram_08AE,x
    sta YM2151_DATA
    txa
    clc
    adc #$08
    dec zp_0C
    bpl _l55CF
    ldy #$00
    lda #$03
    sta zp_0C
    clc
    lda zp_0D
    adc #$20
_l55F1
    tax
    jsr ym_wait
    stx YM2151_REG
    lda (zp_19),y
    sta ram_08AE,x
    sta YM2151_DATA
    txa
    clc
    adc #$08
    iny
    dec zp_0C
    bpl _l55F1
    lda #$03
    sta zp_0C
    clc
    lda #$40
    adc zp_0D
_l5612
    tax
    jsr ym_wait
    stx YM2151_REG
    lda (zp_19),y
    sta ram_08AE,x
    sta YM2151_DATA
    iny
    txa
    cmp #$60
    bcs _l562B
    clc
    adc #$20
    iny
_l562B
    clc
    adc #$20
    bcc _l5612
    adc #$47
    dec zp_0C
    bpl _l5612
    ldx zp_1C

; from 558B, 5597
loc_5638
    plp
    sec
    rts

; op_handlers entry for stream byte $9E
op_9E
    clc
    adc #$24
    sta zp_19
    php
    jsr sub_507B
    plp
    adc #$00
    sta zp_1A
    ldy ram_0899
    cpy #$02
    bne _l567D
    lda #$80
    sta ram_0572,x
    ldy #$00
    tya
    ldx #$18
    jsr sub_56A1
    ldx #$19
    lda #$00
    jsr sub_56A1
    ldx #$19
    lda #$00
    jsr sub_56A1
    lda ym_1b_shadow
    and #$C0
    ldx #$1B
    jsr sub_56A1
    sta ym_1b_shadow
    lda (zp_19),y
    sta ram_08AE,x
    ldx zp_1C
_l567D
    sec
    rts

; op_handlers entry for stream byte $9F; not executed in the make sndtrace runs
op_9F
    clc
    adc #$29
    sta zp_19
    php
    jsr sub_507B
    plp
    adc #$00
    sta zp_1A
    ldy ram_0899
    cpy #$02
    bne _l569F
    sec
    ldy #$00
    tya
    ldx #$0F
    jsr sub_56A1
    ldx zp_1C
_l569F
    sec
    rts

; from 565A, 5661, 5668, 5671, 569A
sub_56A1
    php
    sei
    pha
    lda zp_22
    bne _l56BA
    jsr ym_wait
    stx YM2151_REG
    pla
    ora (zp_19),y
    iny
    sta YM2151_DATA
    sta ram_08AE,x
    plp
    rts
_l56BA
    pla
    plp
    rts

; op_handlers entry for stream byte $A0; not executed in the make sndtrace runs
op_A0
    ldy zp_22
    bne _l56E0
    ldy ram_0899
    cpy #$02
    bne _l56E0
    asl a
    asl a
    asl a
    asl a
    asl a
    asl a
    cmp #$C0
    beq _l56D4
    eor #$C0
_l56D4
    sta zp_19
    lda ram_0518,x
    and #$3F
    ora zp_19
    sta ram_0518,x
_l56E0
    sec
    rts

; op_handlers entry for stream byte $A3; from 542B
op_A3
    ldy ram_0899
    cpy #$02
    bne loc_570D
    eor #$FF
    clc
    adc #$01
    clc
    adc ram_04FA,x
    bvc loc_570A
    bpl _l56FA
    lda #$7F
    bne loc_570A
_l56FA
    lda #$80
    bne loc_570A

; op_handlers entry for stream byte $A2; from 53F2
op_A2
    ldy ram_0899
    cpy #$02
    bne loc_570D
    eor #$FF
    clc
    adc #$01

loc_570A
    sta ram_04FA,x

; from 5733
loc_570D
    sec
    rts

; op_handlers entry for stream byte $A7; from 5424
op_A7
    ldy ram_0899
    cpy #$02
    bne loc_570D
    ldy #$00
    sty zp_1B
    asl a
    bcc _l5721
    ldy #$FF
    sty zp_1B
_l5721
    asl a
    rol zp_1B
    clc
    adc ram_0464,x
    sta ram_0464,x
    lda zp_1B
    adc ram_0662,x
    sta ram_0662,x
    jmp loc_570D

; op_handlers entry for stream byte $A6; from 53EB
op_A6
    ldy ram_0899
    cpy #$02
    bne loc_570D
    asl a
    asl a
    sta ram_0464,x
    sec
    rts

; op_handlers entry for stream byte $A8; not executed in the make sndtrace runs
op_A8
    sta ram_0608,x
    rts

; op_handlers entry for stream byte $A1; from 51CE, 57C0
op_A1
    ldy ram_0899
    cpy #$02
    beq _l5750
    rts
_l5750
    stx zp_1C
    eor #$FF
    clc
    adc #$01
    sta zp_19
    lda ram_0518,x
    and #$07
    tay
    lda tbl_57D3,y
    sta zp_1A
    ldy #$03
_l5766
    asl zp_1A
    bcs _l577C
    lda ram_0482,x
    adc zp_19
    bpl _l5779
    bvs _l5777
    lda #$00
    beq _l5779
_l5777
    lda #$7F
_l5779
    sta ram_0482,x
_l577C
    txa
    clc
    adc #$1E
    tax
    dey
    bpl _l5766
    ldx zp_1C
    sec
    rts

; from 51EF
loc_5788
    ldy ram_0248,x
    cpy #$FE
    bne _l5791
    clc
    rts
_l5791
    pha
    txa
    pha
    lda ram_0536,x
    sta zp_19
    lda ram_0554,x
    sta zp_1A
    lda #$03
    sta zp_0C
    ldy #$05
_l57A4
    lda (zp_19),y
    sta ram_0482,x
    tya
    clc
    adc #$06
    tay
    txa
    clc
    adc #$1E
    tax
    dec zp_0C
    bpl _l57A4
    pla
    tax
    pla
    and #$0F
    tay
    lda tbl_57C3,y
    jmp op_A1

; read at 57BD
tbl_57C3
    .byte $C0, $D6, $DC, $E1, $E9, $E6, $EE, $EB
    .byte $F2, $F0, $F6, $F5, $FA, $FB, $FE, $00

; read at 4F1B, 575F
tbl_57D3
    .byte $E0, $E0, $E0, $E0, $C0, $80, $80, $00

; read at 4269, 5043
tbl_57DB
    .byte $00, $00

; read at 426E, 5048
tbl_57DD
    .byte $20, $00

; read at 4273, 504D
tbl_57DF
    .byte $02, $03

; read at 441C, 4E5A, 5013
tbl_57E1
    .byte $1E, $26

    .cerror * != $57E3, "sequencer.asm must end at $57E2"
