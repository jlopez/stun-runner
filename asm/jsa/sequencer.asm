; sequencer.asm: 4759-57E2, the stream interpreter and its YM2151 output.
;
; Up to 30 entries (the X of the 1E-byte arrays of ram.asm) each read a byte stream of
; data/music.asm through stream_ptr (4859-486E: the pointer from ram_0266/ram_0284, which cmdtype_08
; sets from entry_stream). A byte below 80 is handled at 487E on; a byte 80-BA is an op, run by
; run_op through op_handlers with the next byte in A; BB and up ends the entry (ram_0248 =
; FF). The YM2151 register writes go through ym_wait. h_irq reaches this file through sub_4229
; (tick_group, X = 0 and 1 on alternate ticks). What the ops and the bytes mean is for a later leg;
; the labels name the dispatch only.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on. sub_/loc_/tbl_/dat_/_lXXXX labels are
; neutral address labels for later legs to rename.

    .cerror * != $4759, "sequencer.asm must start at $4759"

; from 4CBD, 4E6E, 4E9F
run_track
    sta chain_mute
    ora ram_0860,x
    beq _l4762
    lda #$FF
_l4762
    sta track_muted
    lda ram_03EC,x
    beq _l4770
    ldy ram_0248,x
    iny
    bne _l4773
    tya
_l4770
    jmp free_track
_l4773
    and #$03
    sta trk_kind
    and #$01
    tay
    lda ram_03EC,x
    sta kind_prio,y
    lda ram_0266,x
    sta stream_ptr
    lda ram_0284,x
    sta stream_ptr_hi
    lda ram_0572,x
    sta key_flags
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
    jmp read_item
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
    lda cur_group_kind
    cmp #$02
    bne _l47E3
    lda #$01
    ora key_flags
    sta key_flags
    lda #$7F
    sta ram_0374,x
    bne _l47F5
_l47E3
    lda trk_kind
    beq _l47EB
    jmp other_voice_off
_l47EB
    lda cur_group_kind
    cmp #$02
    beq _l47F5
    jmp other_voice_update
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
    jmp free_track
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
    jsr fade_step
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
    sta key_note
    lda ram_0392,x
    jsr prepare_key_on
_l4848
    jmp next_track

; op_handlers entry for stream byte $90, $91, $92, $93, $94, $98, $9A, $9C; from 47AB, 493E
read_item
    lda ram_0266,x
    clc
    adc #$02
    sta ram_0266,x
    bcc _l4859
    inc ram_0284,x
_l4859
    ldy #$00
    lda (stream_ptr),y
    bpl _l487E
    jsr run_op
    bcc _l4870
    lda ram_0284,x
    sta stream_ptr_hi
    lda ram_0266,x
    sta stream_ptr
    bcs read_item
_l4870
    lda trk_kind
    and #$01
    tay
    lda #$00
    sta kind_prio,y
    jmp next_track
_l487E
    ldy trk_kind
    beq _l4887
    cmp #$00
    beq _l488B
_l4887
    clc
    adc ram_0662,x
_l488B
    ldy cur_group_kind
    cpy #$02
    beq _l48DD
    ldy trk_kind
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
    ldy track_muted
    bne _l490C
    sta key_note
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
    lda (stream_ptr),y
    beq _l4919
    jmp set_note_length
_l4919
    lda ram_0734,x
    beq free_track
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
    sta stream_ptr
    iny
    lda (zp_20),y
    sta ram_0284,x
    sta stream_ptr_hi
    jmp read_item

; from 4770, 480C, 4A71
free_track
    sta ram_03EC,x
    sta ram_0464,x
    sta ram_0392,x
    sta ram_078E,x
    sta ram_07AC,x
    sta key_note
    lda #$01
    ora key_flags
    sta key_flags
    jsr sub_433C
    lda ram_0860,x
    ldx chain_prev
    sta ram_0860,x
    ldy cur_group_kind
    cpy #$02
    bne _l497C
    cmp #$00
    bne _l4979
    cpx #$1E
    bcs _l4979
    jsr load_patch
_l4979
    jmp next_track
_l497C
    jmp other_voice_off

; from 4916
set_note_length
    pha
    lda trk_kind
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
    ora key_flags
    sta key_flags
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
    lda (stream_ptr),y
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
    jmp free_track
_l4A74
    jsr fade_step
_l4A77
    lda cur_group_kind
    cmp #$02
    bne _l4A8B
    lda zp_1C
    jsr prepare_key_on
    lda zp_1C
    sta ram_0392,x
    jmp next_track
_l4A8B
    lda ram_0392,x
    pha
    lda zp_1C
    sta ram_0392,x
    pla
    bmi other_voice_update
    lda #$00
    tay
    sta ram_05AE,x
    sta ram_05CC,x
    sta ram_05EA,x
    sta ram_0608,x
    lda ram_04BE,x
    sta stream_ptr
    lda ram_04DC,x
    sta stream_ptr_hi
    lda (stream_ptr),y
    sta trk_penv_count,x
    iny
    ora (stream_ptr),y
    iny
    ora (stream_ptr),y
    beq _l4AC1
    inc trk_penv_count,x
    tya
_l4AC1
    sta ram_0572,x
    lda #$00
    tay
    sta trk_patch_lo,x
    sta ram_0554,x
    lda ram_0482,x
    sta stream_ptr
    lda ram_04A0,x
    sta stream_ptr_hi
    lda (stream_ptr),y
    sta ram_0518,x
    iny
    ora (stream_ptr),y
    beq _l4AE5
    inc ram_0518,x
    tya
_l4AE5
    sta ram_04FA,x

; from 47F2; not executed in the make sndtrace runs
other_voice_update
    ldy trk_kind
    beq _l4AF8
    lda ram_02A2,x
    ora ram_02C0,x
    bne _l4AF8
    jmp other_voice_off
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
    sta stream_ptr
    lda ram_04DC,x
    sta stream_ptr_hi
    ldy ram_0572,x
    bne _l4B1C
    tya
    clc
    jmp _l4BBB
_l4B1C
    dec trk_penv_count,x
    bne _l4B77
_l4B21
    iny
    lda (stream_ptr),y
    sta trk_penv_count,x
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
    lda (stream_ptr),y
    sta ram_0608,x
_l4B3E
    iny
    sec
    lda stream_ptr
    sbc (stream_ptr),y
    sta stream_ptr
    sta ram_04BE,x
    bcs _l4B21
    dec stream_ptr_hi
    dec ram_04DC,x
    bcc _l4B21
_l4B52
    ora (stream_ptr),y
    iny
    cpy #$F9
    ora (stream_ptr),y
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
    sta seq_tmp
    lda (stream_ptr),y
    bpl _l4B81
    dec seq_tmp
_l4B81
    sta zp_1C
    dey
    lda (stream_ptr),y
    asl a
    rol zp_1C
    rol seq_tmp
    asl a
    rol zp_1C
    rol seq_tmp
    asl a
    rol zp_1C
    rol seq_tmp
    clc
    adc ram_05AE,x
    sta ram_05AE,x
    lda zp_1C
    adc ram_05CC,x
    sta ram_05CC,x
    sta zp_1C
    lda seq_tmp
    adc ram_05EA,x
    sta ram_05EA,x
    tay
    lda trk_kind
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
    sta glide_lo
    lda trk_kind
    and #$01
    tay
    lda zp_1C
    sta key_note,y
    lda ram_0482,x
    sta stream_ptr
    lda ram_04A0,x
    sta stream_ptr_hi
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
    lda (stream_ptr),y
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
    lda (stream_ptr),y
    sta ram_0554,x
_l4C16
    iny
    sec
    lda stream_ptr
    sbc (stream_ptr),y
    sta stream_ptr
    sta ram_0482,x
    bcs _l4BF9
    dec stream_ptr_hi
    dec ram_04A0,x
    bcc _l4BF9
_l4C2A
    cpy #$F9
    ora (stream_ptr),y
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
    lda (stream_ptr),y
    clc
    adc trk_patch_lo,x
    bvc _l4C59
    lda #$80
    bcs _l4C59
    lda #$7F
_l4C59
    sta trk_patch_lo,x
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
    jmp other_voice_level

; from 47E8, 497C, 4AF5; not executed in the make sndtrace runs
other_voice_off
    lda #$00

; from 4C91; not executed in the make sndtrace runs
other_voice_level
    pha
    lda trk_kind
    and #$01
    tay
    pla
    sta other_level,y
    cpx #$1E
    bcs next_track
    lda ram_0446,x
    sta other_ctl_a,y
    lda ram_0428,x
    sta other_ctl_b,y

; from 4848, 487B, 4979, 4A88
next_track
    lda ram_0860,x
    beq _l4CC0
    stx chain_prev
    tax
    dex
    lda chain_mute
    jmp run_track
_l4CC0
    rts

; from 4829, 4A74
fade_step
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
    jsr add_volume
    ldy #$FF
_l4D68
    pla
    sta zp_1C
    rts

; from 4845, 4A80
prepare_key_on
    ldy track_muted
    bne _l4DBE
    and #$30
    beq _l4D79
    ora key_flags
    bne _l4D7C
_l4D79
    lda key_flags
_l4D7C
    ora #$02
    sta key_flags
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
    sta key_scaling,y
    dey
_l4DB6
    lda (zp_19),y
    sta key_scaling,y
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
    lda track_muted
    bne _l4E55
    lda ram_06F8,x
    sta glide_lo
    lda ram_0716,x
    sta glide_hi
    bpl _l4E32
    dec glide_hi
    lda glide_lo
    eor #$FF
    clc
    adc #$01
    sta glide_lo
_l4E32
    clc
    lda #$30
    adc zp_0D
    tay
    lda ram_0464,x
    clc
    adc glide_lo
    bcc _l4E44
    inc glide_hi
_l4E44
    and #$FC
    sta ram_08AE,y
    lda key_note
    beq _l4E55
    clc
    adc glide_hi
    sta key_note
_l4E55
    rts

; from 5057
tick_other_group
    lda #$05
    sta group_count
    lda group_first_chain,x
    clc
    adc #$05
    tay
_l4E61
    tya
    pha
    ldx ram_0860,y
    beq _l4E71
    sty chain_prev
    dex
    lda #$00
    jsr run_track
_l4E71
    pla
    tay
    dey
    dec group_count
    bpl _l4E61
    rts

; from 501B
tick_ym_channel
    ldx ram_0860,y
    bne _l4E7F
    rts
_l4E7F
    dex
    lda #$00
    sta sounding_prio
    sta key_note
    sty chain_prev
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
    jsr run_track
    lda track_muted
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
    lsr key_flags
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
    lda sounding_prio
    cmp zp_1E
    bcc _l4EA6
    lsr key_flags
    bcc _l4EA6
    ldx key_note
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
    sta key_note
    lda #$20
    clc
    adc zp_0D
    tax
    lda ram_08AE,x
    and #$07
    tax
    lda modulator_mask,x
    sta zp_1A
    ldy #$06
    sty zp_0C
    lda key_flags
    lsr a
    lsr a
    and #$03
    tax
    lda tbl_5FDF,x
    sta trk_kind
    lda key_scaling_2,y
    sec
    sbc trk_kind
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
    lda key_scaling_depth,y
    lsr a
    lsr a
    lsr a
    lsr a
    sta trk_kind
    lda key_note
    ora key_scaling,y
    tay
    lda key_level_curve,y
    eor trk_kind
    and #$F0
    eor trk_kind
    tay
    lda tbl_5EDF,y
    sta key_tl_offset
    ldy zp_0C
    lda key_scaling_depth,y
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
    adc key_tl_offset
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
    lsr key_flags
    bcc _l500D
    php
    sei
    lda key_flags
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
tick_ym_group
    lda #$07
    sta zp_0D
    clc
    lda group_first_chain,x
    adc #$07
    tay
_l5019
    tya
    pha
    jsr tick_ym_channel
    pla
    tay
    dey
    dec zp_0D
    bpl _l5019
    rts

; from 427A, 4286, 428E, 4295, 42A6, 42AE, 439A, 4EAF, 4EC1, 4ED7, 4EFC, 4FAB, 4FB2, 4FE7, 4FF2,
; 4FFC, 55B8, 55D0, 55F2, 5613, 56A8, 58A3, 58D3, 591A, 5925, 5938, 5943, 594E, 5959, 5964, 596F,
; 597A, 5985, 599C, 59A8, 59B5, 59D6, 59E1, 5A4D, 5A5E, 5A6A, 5A77, 5A88, 5A93, 5AA2, 5AAD, 5B66
; Wait until the YM2151 is not busy (status bit 7), at most 255 reads: on a time-out set zp_0E
; (later calls return at once) and zp_02 bit 1 (the status imm_03 sends). Keeps A.
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
tick_group
    lda group_chip_lo,x
    sta zp_08
    lda group_chip_hi,x
    sta zp_09
    lda group_kind,x
    sta cur_group_kind
    cmp #$03
    bne _l505A
    jmp tick_other_group
_l505A
    jmp tick_ym_group

; from 485F
; A stream byte A of 80 and up: BB and up ends the entry (C clear); else op_handlers entry
; A - 80, entered by RTS with Y at the next byte, A that byte and C set.
run_op
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
    lda (stream_ptr),y
    sec
    rts

; from 518E, 5199, 51A9, 51B8, 5237, 52C2, 537D, 5380, 5389, 53A4, 53A7, 53B0, 547A, 547D, 5482,
; 5487, 5531, 554A, 555A, 5641, 5685
next_operand
    lda ram_0266,x
    clc
    adc #$01
    sta ram_0266,x
    bcc _l5089
    inc ram_0284,x
_l5089
    iny
    lda (stream_ptr),y
    rts

; from 452E; not executed in the make sndtrace runs
chain_run_op
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
    jsr call_op_handler
_l50A1
    plp
    rts

; from 509E; not executed in the make sndtrace runs
call_op_handler
    lda op_handlers+1,y
    pha
    lda op_handlers,y
    pha
    lda ram_08AD
    rts

; read at 506D, 5071, 50A3, 50A7
; The 59 stream ops 80-BA, each word the handler's address - 1 (run_op pushes it and returns
; into it; call_op_handler does the same with Y, from 509E). The table ends where the code of op_sync
; starts (5125). Handlers several ops share keep a neutral loc_XXXX.
op_handlers
    .word op_tempo-1                       ; $80
    .word op_tempo_add-1                       ; $81
    .word op_volume-1                       ; $82
    .word op_volume_add-1                       ; $83
    .word op_transpose-1                       ; $84
    .word op_transpose_add-1                       ; $85
    .word op_pitch_env-1                       ; $86
    .word op_level_env-1                       ; $87
    .word op_sync-1                       ; $88
    .word op_sync_group-1                       ; $89
    .word op_ctl_bits-1                       ; $8A
    .word op_ctl_set-1                       ; $8B
    .word op_portamento-1                       ; $8C
    .word op_call-1                       ; $8D
    .word op_loop-1                       ; $8E
    .word op_loop_end-1                       ; $8F
    .word read_item-1                    ; $90
    .word read_item-1                    ; $91
    .word read_item-1                    ; $92
    .word read_item-1                    ; $93
    .word read_item-1                    ; $94
    .word op_95-1                       ; $95
    .word op_respond-1                       ; $96
    .word op_release-1                       ; $97
    .word read_item-1                    ; $98
    .word op_jump-1                       ; $99
    .word read_item-1                    ; $9A
    .word op_ctl_clear-1                       ; $9B
    .word read_item-1                    ; $9C
    .word op_patch-1                       ; $9D
    .word op_lfo-1                       ; $9E
    .word op_noise-1                       ; $9F
    .word op_pan-1                       ; $A0
    .word op_carrier_tl_sub-1                       ; $A1
    .word op_velocity-1                       ; $A2
    .word op_velocity_add-1                       ; $A3
    .word op_fade-1                       ; $A4
    .word cmdtype_11-1                  ; $A5
    .word op_fine_tune-1                       ; $A6
    .word op_bend-1                       ; $A7
    .word op_fade_mode-1                       ; $A8
    .word op_var_add-1                       ; $A9
    .word op_var_sub-1                       ; $AA
    .word op_var_and-1                       ; $AB
    .word op_var_or-1                       ; $AC
    .word op_var_xor-1                       ; $AD
    .word op_jump_table-1                       ; $AE
    .word op_jump_table_inc-1                       ; $AF
    .word op_var_store-1                       ; $B0
    .word op_var_add_to-1                       ; $B1
    .word op_var_load-1                       ; $B2
    .word op_var_shr-1                       ; $B3
    .word op_var_shl-1                       ; $B4
    .word op_branch_zero-1                       ; $B5
    .word op_branch_nonzero-1                       ; $B6
    .word op_branch_plus-1                       ; $B7
    .word op_branch_minus-1                       ; $B8
    .word op_var_cmp_reg-1                       ; $B9
    .word op_var_cmp-1                       ; $BA

; op_handlers entry for stream byte $88; not executed in the make sndtrace runs
op_sync
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
op_sync_group
    sta ram_069E,x
    lda #$00
    sta ram_0680,x
    rts

; op_handlers entry for stream byte $87; not executed in the make sndtrace runs
op_level_env
    sta ram_0482,x
    jsr next_operand
    sta ram_04A0,x
    sec
    rts

; op_handlers entry for stream byte $86; not executed in the make sndtrace runs
op_pitch_env
    sta ram_04BE,x
    jsr next_operand
    sta ram_04DC,x
    sec
    rts

; op_handlers entry for stream byte $81; not executed in the make sndtrace runs
op_tempo_add
    clc
    adc ram_0626,x
    sta ram_0626,x
    php
    jsr next_operand
    plp

; from 5442; not executed in the make sndtrace runs
tempo_add_hi
    adc ram_0644,x
    sta ram_0644,x
    sec
    rts

; op_handlers entry for stream byte $80
op_tempo
    sta ram_0626,x
    jsr next_operand

; from 5408
set_tempo_hi
    sta ram_0644,x
    sec
    rts

; op_handlers entry for stream byte $83; from 5446
op_volume_add
    ldy ram_0248,x
    cpy #$FE
    beq op_refuse

; from 4D63
add_volume
    ldy cur_group_kind
    cpy #$02
    bne _l51D1
    jmp op_carrier_tl_sub
_l51D1
    clc
    adc ram_0464,x
    bpl _l51D9
    lda #$00
_l51D9
    cmp #$10
    bcc store_volume
    lda #$0F
    bne store_volume

; op_handlers entry for stream byte $82; from 540C
op_volume
    ldy ram_0248,x
    cpy #$FE
    beq op_refuse
    ldy cur_group_kind
    cpy #$02
    bne store_volume
    jmp volume_ym

; not executed in the make sndtrace runs
store_volume
    sta ram_0464,x
    sec
    rts

op_refuse
    clc
    rts

; op_handlers entry for stream byte $85; from 543A; not executed in the make sndtrace runs
op_transpose_add
    clc
    adc ram_0662,x

; op_handlers entry for stream byte $84; from 5401
op_transpose
    sta ram_0662,x
    sec
    rts

; op_handlers entry for stream byte $8A; not executed in the make sndtrace runs
op_ctl_bits
    sta ram_06BC,x
    rts

; op_handlers entry for stream byte $8B; not executed in the make sndtrace runs
op_ctl_set
    ldy cur_group_kind
    beq _l5213
    eor other_ctl_a
    and #$09
    eor other_ctl_a
_l5213
    ora ram_0446,x
    sta ram_0446,x
    rts

; op_handlers entry for stream byte $9B; not executed in the make sndtrace runs
op_ctl_clear
    eor #$FF
    ldy cur_group_kind
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
op_portamento
    sta ram_06DA,x
    rts

; op_handlers entry for stream byte $8D
op_call
    sta zp_1C
    jsr next_operand
    sta seq_tmp
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
    lda seq_tmp
    sta ram_0284,x
_l5261
    sec
    rts

; op_handlers entry for stream byte $8E
op_loop
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
op_loop_end
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
op_fade
    sta zp_1C
    jsr next_operand
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
op_var_add
    clc
    adc ram_0824,x

; from 5300, 5306, 530C, 5312, 533F, 536C, 53C1, 544E
store_var
    sta ram_0824,x
    sta ram_0842,x
    sec
    rts

; op_handlers entry for stream byte $AA; not executed in the make sndtrace runs
op_var_sub
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    jmp store_var

; op_handlers entry for stream byte $AB
op_var_and
    and ram_0824,x
    jmp store_var

; op_handlers entry for stream byte $AC; not executed in the make sndtrace runs
op_var_or
    ora ram_0824,x
    jmp store_var

; op_handlers entry for stream byte $AD; not executed in the make sndtrace runs
op_var_xor
    eor ram_0824,x
    jmp store_var

; op_handlers entry for stream byte $B3; not executed in the make sndtrace runs
op_var_shr
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
    jmp store_var

; op_handlers entry for stream byte $B4; not executed in the make sndtrace runs
op_var_shl
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
    jmp store_var

; op_handlers entry for stream byte $AE
op_jump_table
    sta zp_1C
    lda ram_0824,x
    bne _l537B
    lda zp_1C
    jmp _l5389
_l537B
    sta zp_1B
_l537D
    jsr next_operand
    jsr next_operand
    sta zp_1C
    dec zp_1B
    bne _l537D
_l5389
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; op_handlers entry for stream byte $AF; not executed in the make sndtrace runs
op_jump_table_inc
    sta zp_1C
    lda ram_0824,x
    bne _l53A2
    lda zp_1C
    jmp _l53B0
_l53A2
    sta zp_1B
_l53A4
    jsr next_operand
    jsr next_operand
    sta zp_1C
    dec zp_1B
    bne _l53A4
_l53B0
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    inc ram_0824,x
    lda ram_0824,x
    jmp store_var

; op_handlers entry for stream byte $B0
op_var_store
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
    ldy cur_group_kind
    cpy #$02
    bne _l53F5
    tay
    lda ram_0824,x
    cpy #$04
    bcc _l53EE
    jmp op_fine_tune
_l53EE
    cpy #$03
    bcc _l53FD
    jmp op_velocity
_l53F5
    cmp #$03
    bcs _l540F
    tay
    lda ram_0824,x
_l53FD
    cpy #$02
    bcc _l5404
    jmp op_transpose
_l5404
    cpy #$01
    bcc _l540B
    jmp set_tempo_hi
_l540B
    sec
    jmp op_volume
_l540F
    sec
    rts

; op_handlers entry for stream byte $B1; not executed in the make sndtrace runs
op_var_add_to
    ldy cur_group_kind
    cpy #$02
    bne _l542E
    tay
    cpy #$05
    bcs _l5449
    lda ram_0824,x
    cpy #$04
    bcc _l5427
    jmp op_bend
_l5427
    cpy #$03
    bcc _l5436
    jmp op_velocity_add
_l542E
    cmp #$03
    bcs _l5449
    tay
    lda ram_0824,x
_l5436
    cpy #$02
    bcc _l543D
    jmp op_transpose_add
_l543D
    cpy #$01
    bcc _l5445
    clc
    jmp tempo_add_hi
_l5445
    sec
    jmp op_volume_add
_l5449
    sec
    rts

; op_handlers entry for stream byte $B2
op_var_load
    jsr read_register
    jmp store_var

; op_handlers entry for stream byte $B9; not executed in the make sndtrace runs
op_var_cmp_reg
    jsr read_register

; op_handlers entry for stream byte $BA
op_var_cmp
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    sta ram_0842,x
    sec
    rts

; op_handlers entry for stream byte $B5
op_branch_zero
    jsr read_register
    beq branch_taken
    bne branch_not_taken

; op_handlers entry for stream byte $B6; not executed in the make sndtrace runs
op_branch_nonzero
    jsr read_register
    bne branch_taken
    beq branch_not_taken

; op_handlers entry for stream byte $B7
op_branch_plus
    jsr read_register
    bpl branch_taken
    bmi branch_not_taken

; op_handlers entry for stream byte $B8
op_branch_minus
    jsr read_register
    bmi branch_taken

branch_not_taken
    jsr next_operand
    jsr next_operand
    sec
    rts

branch_taken
    jsr next_operand
    sta zp_1C
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; from 544B, 5451, 5460, 5467, 546E, 5475
read_register
    sty zp_1C
    cmp #$26
    bcs _l54FE
    cmp #$06
    bcs _l54EB
    cmp #$05
    beq _l54F6
    ldy cur_group_kind
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
    jsr random
    pha
    ldy zp_1C
    pla
    rts
_l54FE
    ldy zp_1C
    lda ram_0842,x
    rts

; from 4149, 54F6
random
    lda zp_47
    asl a
    bcc _l550B
    eor #$1D
_l550B
    sta zp_47
    rts

; op_handlers entry for stream byte $96; not executed in the make sndtrace runs
op_respond
    jsr queue_response
    sec
    rts

; op_handlers entry for stream byte $97; not executed in the make sndtrace runs
op_release
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
op_jump
    sta zp_1C
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; op_handlers entry for stream byte $9D
op_patch
    sta zp_1C
    lda ram_0248,x
    cmp #$FE
    bne _l554F
    inc ram_0248,x
    jsr next_operand
    clc
    rts
_l554F
    php
    sei
    lda zp_1C
    stx zp_1C
    sta zp_19
    sta trk_patch_lo,x
    jsr next_operand
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
load_patch
    php
    sei
    ldy track_muted
    beq _l558E
    jmp patch_done
_l558E
    stx zp_1C
    ldy cur_group_kind
    cpy #$02
    beq write_patch
    jmp patch_done

; from 5A20, 5A37; not executed in the make sndtrace runs
load_patch_regs
    php
    sei

write_patch
    lda trk_patch_lo,x
    sta zp_19
    clc
    adc #$1C
    sta ram_0428,x
    lda ram_0554,x
    sta zp_1A
    adc #$00
    sta ram_0446,x
    jmp write_patch_regs

; from 589A, 58CA; not executed in the make sndtrace runs
write_patch_regs_at
    php
    sei

; from 55B1
write_patch_regs
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
patch_done
    plp
    sec
    rts

; op_handlers entry for stream byte $9E
op_lfo
    clc
    adc #$24
    sta zp_19
    php
    jsr next_operand
    plp
    adc #$00
    sta zp_1A
    ldy cur_group_kind
    cpy #$02
    bne _l567D
    lda #$80
    sta ram_0572,x
    ldy #$00
    tya
    ldx #$18
    jsr ym_write_record
    ldx #$19
    lda #$00
    jsr ym_write_record
    ldx #$19
    lda #$00
    jsr ym_write_record
    lda ym_1b_shadow
    and #$C0
    ldx #$1B
    jsr ym_write_record
    sta ym_1b_shadow
    lda (zp_19),y
    sta ram_08AE,x
    ldx zp_1C
_l567D
    sec
    rts

; op_handlers entry for stream byte $9F; not executed in the make sndtrace runs
op_noise
    clc
    adc #$29
    sta zp_19
    php
    jsr next_operand
    plp
    adc #$00
    sta zp_1A
    ldy cur_group_kind
    cpy #$02
    bne _l569F
    sec
    ldy #$00
    tya
    ldx #$0F
    jsr ym_write_record
    ldx zp_1C
_l569F
    sec
    rts

; from 565A, 5661, 5668, 5671, 569A
ym_write_record
    php
    sei
    pha
    lda track_muted
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
op_pan
    ldy track_muted
    bne _l56E0
    ldy cur_group_kind
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
op_velocity_add
    ldy cur_group_kind
    cpy #$02
    bne op_done
    eor #$FF
    clc
    adc #$01
    clc
    adc ram_04FA,x
    bvc store_velocity
    bpl _l56FA
    lda #$7F
    bne store_velocity
_l56FA
    lda #$80
    bne store_velocity

; op_handlers entry for stream byte $A2; from 53F2
op_velocity
    ldy cur_group_kind
    cpy #$02
    bne op_done
    eor #$FF
    clc
    adc #$01

store_velocity
    sta ram_04FA,x

; from 5733
op_done
    sec
    rts

; op_handlers entry for stream byte $A7; from 5424
op_bend
    ldy cur_group_kind
    cpy #$02
    bne op_done
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
    jmp op_done

; op_handlers entry for stream byte $A6; from 53EB
op_fine_tune
    ldy cur_group_kind
    cpy #$02
    bne op_done
    asl a
    asl a
    sta ram_0464,x
    sec
    rts

; op_handlers entry for stream byte $A8; not executed in the make sndtrace runs
op_fade_mode
    sta ram_0608,x
    rts

; op_handlers entry for stream byte $A1; from 51CE, 57C0
op_carrier_tl_sub
    ldy cur_group_kind
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
    lda modulator_mask,y
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
volume_ym
    ldy ram_0248,x
    cpy #$FE
    bne _l5791
    clc
    rts
_l5791
    pha
    txa
    pha
    lda trk_patch_lo,x
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
    lda volume_steps,y
    jmp op_carrier_tl_sub

; read at 57BD
volume_steps
    .byte $C0, $D6, $DC, $E1, $E9, $E6, $EE, $EB
    .byte $F2, $F0, $F6, $F5, $FA, $FB, $FE, $00

; read at 4F1B, 575F
modulator_mask
    .byte $E0, $E0, $E0, $E0, $C0, $80, $80, $00

; read at 4269, 5043
group_chip_lo
    .byte $00, $00

; read at 426E, 5048
group_chip_hi
    .byte $20, $00

; read at 4273, 504D
group_kind
    .byte $02, $03

; read at 441C, 4E5A, 5013
group_first_chain
    .byte $1E, $26

    .cerror * != $57E3, "sequencer.asm must end at $57E2"
