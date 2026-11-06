; sequencer.asm: 4759-57E2, the stream interpreter and its YM2151 output.
;
; Up to 30 entries (the X of the 1E-byte arrays of ram.asm) each read a byte stream of
; data/music.asm through zp_06 (4859-486E: the pointer from trk_ptr_lo/trk_ptr_hi, which cmdtype_08_start_sound
; sets from tbl_633E). A byte below 80 is handled at 487E on; a byte 80-BA is an op, run by
; sub_505D through op_handlers with the next byte in A; BB and up ends the entry (trk_sound =
; FF). The YM2151 register writes go through ym_wait. h_irq reaches this file through tick_sequencer
; (loc_5043, X = 0 and 1 on alternate ticks). What the ops and the bytes mean is for a later leg;
; the labels name the dispatch only.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on. sub_/loc_/tbl_/dat_/_lXXXX labels are
; neutral address labels for later legs to rename.

    .cerror * != $4759, "sequencer.asm must start at $4759"

; from 4CBD, 4E6E, 4E9F
sub_4759
    sta zp_0F
    ora trk_link,x
    beq _l4762
    lda #$FF
_l4762
    sta zp_22
    lda trk_priority,x
    beq _l4770
    ldy trk_sound,x
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
    lda trk_priority,x
    sta ram_088D,y
    lda trk_ptr_lo,x
    sta zp_06
    lda trk_ptr_hi,x
    sta zp_07
    lda trk_keyon_flags,x
    sta ram_08AB
    lda trk_wait_frac,x
    sec
    sbc trk_tempo_lo,x
    sta trk_wait_frac,x
    lda trk_wait_lo,x
    sbc trk_tempo_hi,x
    sta trk_wait_lo,x
    bcs _l47AE
    dec trk_wait_hi,x
    bpl _l47AE
    jmp loc_484B
_l47AE
    lda trk_gate_hi,x
    bmi _l47CD
    lda trk_gate_frac,x
    sec
    sbc trk_tempo_lo,x
    sta trk_gate_frac,x
    lda trk_gate_lo,x
    sbc trk_tempo_hi,x
    sta trk_gate_lo,x
    bcs _l47EB
    dec trk_gate_hi,x
    bpl _l47EB
_l47CD
    lda ram_0899
    cmp #$02
    bne _l47E3
    lda #$01
    ora ram_08AB
    sta ram_08AB
    lda #$7F
    sta trk_gate_hi,x
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
    lda trk_slide_step,x
    bne _l482F
    lda trk_slide_time_lo,x
    ora trk_slide_time_hi,x
    bne _l480F
    ldy trk_sound,x
    cpy #$FE
    bne _l482F
    inc trk_sound,x
    jmp loc_4941
_l480F
    lda trk_slide_wait_frac,x
    sec
    sbc trk_tempo_lo,x
    sta trk_slide_wait_frac,x
    lda trk_slide_wait_lo,x
    sbc trk_tempo_hi,x
    sta trk_slide_wait_lo,x
    bcs _l482F
    dec trk_slide_wait_hi,x
    bpl _l482F
    jsr sub_4CC1
    tya
    bne _l483A
_l482F
    lda trk_glide_rate,x
    beq _l4848
    lda tick_count
    and #$06
    bne _l4848
_l483A
    lda trk_pitch_lo,x
    beq _l4848
    sta ram_0895
    lda trk_length_byte,x
    jsr sub_4D6C
_l4848
    jmp loc_4CB1

; op_handlers entry for stream byte $90, $91, $92, $93, $94, $98, $9A, $9C; from 47AB, 493E
loc_484B
    lda trk_ptr_lo,x
    clc
    adc #$02
    sta trk_ptr_lo,x
    bcc _l4859
    inc trk_ptr_hi,x
_l4859
    ldy #$00
    lda (zp_06),y
    bpl _l487E
    jsr sub_505D
    bcc _l4870
    lda trk_ptr_hi,x
    sta zp_07
    lda trk_ptr_lo,x
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
    adc trk_transpose,x
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
    sbc trk_pitch_lo,x
    sta trk_glide_lo,x
    asl a
    lda #$FF
    bcs _l48AA
    lda #$00
_l48AA
    sta trk_glide_hi,x
    pla
    sta trk_pitch_lo,x
    lda #$00
    sta trk_pitch_hi,x
    jmp _l490C
_l48B9
    asl a
    tay
    sec
    lda trk_pitch_lo,x
    sbc note_periods,y
    sta trk_glide_lo,x
    lda trk_pitch_hi,x
    sbc note_periods+1,y
    sta trk_glide_hi,x
    lda note_periods,y
    sta trk_pitch_lo,x
    lda note_periods+1,y
    sta trk_pitch_hi,x
    jmp _l490C
_l48DD
    sta tmp_1B
    lda #$00
    sta trk_glide_lo,x
    sta trk_glide_hi,x
    lda tmp_1B
    beq _l48F6
    lda trk_pitch_lo,x
    sec
    sbc tmp_1B
    sta trk_glide_hi,x
    lda tmp_1B
_l48F6
    sta trk_pitch_lo,x
    ldy zp_22
    bne _l490C
    sta ram_0895
    clc
    lda #$20
    adc ym_channel
    tay
    lda trk_reg20,x
    sta ym_shadow,y
_l490C
    ldy #$01
    lda #$00
    sta tmp_1C
    lda (zp_06),y
    beq _l4919
    jmp loc_497F
_l4919
    lda trk_call_frame,x
    beq loc_4941
    pha
    jsr frame_address
    lda (frame_ptr),y
    sta trk_call_frame,x
    lda frame_free
    sta (frame_ptr),y
    pla
    sta frame_free
    iny
    lda (frame_ptr),y
    sta trk_ptr_lo,x
    sta zp_06
    iny
    lda (frame_ptr),y
    sta trk_ptr_hi,x
    sta zp_07
    jmp loc_484B

; from 4770, 480C, 4A71
loc_4941
    sta trk_priority,x
    sta trk_key_fraction,x
    sta trk_length_byte,x
    sta trk_slide_time_lo,x
    sta trk_slide_time_hi,x
    sta ram_0895
    lda #$01
    ora ram_08AB
    sta ram_08AB
    jsr free_track_frames
    lda trk_link,x
    ldx ram_0898
    sta trk_link,x
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
    sta tmp_1C
    and #$0F
    asl a
    tay
    lda note_lengths,y
    clc
    adc trk_wait_lo,x
    sta trk_wait_lo,x
    lda note_lengths+1,y
    adc trk_wait_hi,x
    sta trk_wait_hi,x
    lda tmp_1C
    and #$40
    beq _l49BF
    lda note_lengths+1,y
    lsr a
    pha
    lda note_lengths,y
    ror a
    clc
    adc trk_wait_lo,x
    sta trk_wait_lo,x
    pla
    adc trk_wait_hi,x
    sta trk_wait_hi,x
_l49BF
    lda #$7F
    sta trk_gate_hi,x
    lda tmp_1C
    bmi _l4A05
    lda #$00
    sta tmp_1B
    lda trk_tempo_hi,x
    sta tmp_ptr+1
    lda trk_tempo_lo,x
    asl a
    rol tmp_ptr+1
    rol tmp_1B
    sta tmp_ptr
    lda trk_wait_frac,x
    sec
    sbc tmp_ptr
    sta trk_gate_frac,x
    lda trk_wait_lo,x
    sbc tmp_ptr+1
    sta trk_gate_lo,x
    lda trk_wait_hi,x
    sbc tmp_1B
    sta trk_gate_hi,x
    lda tmp_1C
    and #$30
    cmp #$10
    bne _l4A05
    lsr trk_gate_hi,x
    ror trk_gate_lo,x
    ror trk_gate_frac,x
_l4A05
    lda trk_length_byte,x
    bpl _l4A17
    lda trk_glide_rate,x
    bne _l4A5F
    sta trk_glide_lo,x
    sta trk_glide_hi,x
    beq _l4A5F
_l4A17
    lda #$00
    sta trk_glide_lo,x
    sta trk_glide_hi,x
    lda tmp_1C
    and #$38
    asl a
    sta trk_curve_index,x
    lda #$04
    ora ram_08AB
    sta ram_08AB
    jmp _l4A5F
_l4A32
    sta trk_curve_index,x
    sta trk_glide_lo,x
    sta trk_glide_hi,x
    pla
    and #$7F
    lsr a
    ror tmp_1C
    lsr a
    ror tmp_1C
    lsr a
    ror tmp_1C
    pha
    clc
    lda tmp_1C
    adc trk_wait_lo,x
    sta trk_wait_lo,x
    pla
    adc trk_wait_hi,x
    sta trk_wait_hi,x
    lda (zp_06),y
    sta tmp_1C
    sta trk_length_byte,x
_l4A5F
    lda trk_slide_time_lo,x
    ora trk_slide_time_hi,x
    bne _l4A74
    ldy trk_sound,x
    cpy #$FE
    bne _l4A77
    inc trk_sound,x
    jmp loc_4941
_l4A74
    jsr sub_4CC1
_l4A77
    lda ram_0899
    cmp #$02
    bne _l4A8B
    lda tmp_1C
    jsr sub_4D6C
    lda tmp_1C
    sta trk_length_byte,x
    jmp loc_4CB1
_l4A8B
    lda trk_length_byte,x
    pha
    lda tmp_1C
    sta trk_length_byte,x
    pla
    bmi loc_4AE8
    lda #$00
    tay
    sta trk_slide_wait_frac,x
    sta trk_slide_wait_lo,x
    sta trk_slide_wait_hi,x
    sta trk_slide_step,x
    lda trk_op_tl+$3C,x
    sta zp_06
    lda trk_op_tl+$5A,x
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
    sta trk_keyon_flags,x
    lda #$00
    tay
    sta ram_0536,x
    sta trk_patch_hi,x
    lda trk_op_tl,x
    sta zp_06
    lda trk_op_tl+$1E,x
    sta zp_07
    lda (zp_06),y
    sta trk_reg20,x
    iny
    ora (zp_06),y
    beq _l4AE5
    inc trk_reg20,x
    tya
_l4AE5
    sta trk_level_offset,x

; from 47F2; not executed in the make sndtrace runs
loc_4AE8
    ldy ram_088F
    beq _l4AF8
    lda trk_pitch_lo,x
    ora trk_pitch_hi,x
    bne _l4AF8
    jmp loc_4C94
_l4AF8
    lda tick_count
    and #$06
    bne _l4B08
    lda trk_glide_hi,x
    asl a
    ror trk_glide_hi,x
    ror trk_glide_lo,x
_l4B08
    lda trk_op_tl+$3C,x
    sta zp_06
    lda trk_op_tl+$5A,x
    sta zp_07
    ldy trk_keyon_flags,x
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
    lda trk_slide_step,x
    beq _l4B39
    dec trk_slide_step,x
    bne _l4B3E
    iny
    bne _l4B21
_l4B39
    lda (zp_06),y
    sta trk_slide_step,x
_l4B3E
    iny
    sec
    lda zp_06
    sbc (zp_06),y
    sta zp_06
    sta trk_op_tl+$3C,x
    bcs _l4B21
    dec zp_07
    dec trk_op_tl+$5A,x
    bcc _l4B21
_l4B52
    ora (zp_06),y
    iny
    cpy #$F9
    ora (zp_06),y
    bne _l4B62
    sta trk_keyon_flags,x
    tay
    clc
    beq _l4BBB
_l4B62
    tya
    bcc _l4B74
    sbc #$02
    adc trk_op_tl+$3C,x
    sta trk_op_tl+$3C,x
    lda #$01
    bcc _l4B74
    inc trk_op_tl+$5A,x
_l4B74
    sta trk_keyon_flags,x
_l4B77
    lda #$00
    sta zp_1D
    lda (zp_06),y
    bpl _l4B81
    dec zp_1D
_l4B81
    sta tmp_1C
    dey
    lda (zp_06),y
    asl a
    rol tmp_1C
    rol zp_1D
    asl a
    rol tmp_1C
    rol zp_1D
    asl a
    rol tmp_1C
    rol zp_1D
    clc
    adc trk_slide_wait_frac,x
    sta trk_slide_wait_frac,x
    lda tmp_1C
    adc trk_slide_wait_lo,x
    sta trk_slide_wait_lo,x
    sta tmp_1C
    lda zp_1D
    adc trk_slide_wait_hi,x
    sta trk_slide_wait_hi,x
    tay
    lda ram_088F
    cmp #$02
    bne _l4BB8
    dec tmp_1C
_l4BB8
    lda tmp_1C
    clc
_l4BBB
    adc trk_pitch_lo,x
    sta tmp_1C
    tya
    adc trk_pitch_hi,x
    tay
    clc
    lda tmp_1C
    adc trk_glide_lo,x
    sta tmp_1C
    tya
    adc trk_glide_hi,x
    sta ram_0897
    lda ram_088F
    and #$01
    tay
    lda tmp_1C
    sta ram_0895,y
    lda trk_op_tl,x
    sta zp_06
    lda trk_op_tl+$1E,x
    sta zp_07
    ldy trk_level_offset,x
    bne _l4BF4
_l4BEE
    lda trk_key_fraction,x
    jmp _l4C8E
_l4BF4
    dec trk_reg20,x
    bne _l4C4B
_l4BF9
    iny
    lda (zp_06),y
    sta trk_reg20,x
    iny
    cmp #$FF
    bne _l4C2A
    lda trk_patch_hi,x
    beq _l4C11
    dec trk_patch_hi,x
    bne _l4C16
    iny
    bne _l4BF9
_l4C11
    lda (zp_06),y
    sta trk_patch_hi,x
_l4C16
    iny
    sec
    lda zp_06
    sbc (zp_06),y
    sta zp_06
    sta trk_op_tl,x
    bcs _l4BF9
    dec zp_07
    dec trk_op_tl+$1E,x
    bcc _l4BF9
_l4C2A
    cpy #$F9
    ora (zp_06),y
    bne _l4C36
    sta trk_level_offset,x
    jmp _l4BEE
_l4C36
    tya
    bcc _l4C48
    sbc #$02
    adc trk_op_tl,x
    sta trk_op_tl,x
    lda #$01
    bcc _l4C48
    inc trk_op_tl+$1E,x
_l4C48
    sta trk_level_offset,x
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
    ldy trk_curve_index,x
    clc
    adc level_curves,y
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
    inc trk_curve_index,x
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
    adc trk_key_fraction,x
    bpl _l4C88
    lda #$00
_l4C88
    cmp #$10
    bcc _l4C8E
    lda #$0F
_l4C8E
    ora trk_e1_ctl,x
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
    lda trk_scale_ptr_hi,x
    sta ram_089A,y
    lda trk_scale_ptr_lo,x
    sta ram_089E,y

; from 4848, 487B, 4979, 4A88
loc_4CB1
    lda trk_link,x
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
    lda trk_slide_rate_lo,x
    sta tmp_ptr
    lda trk_slide_rate_hi,x
    sta tmp_ptr+1
    lda tmp_1C
    pha
    lda trk_slide_step,x
    bne _l4CE3
    lda note_lengths+$14
    sta trk_slide_wait_lo,x
    lda note_lengths+$15
    sta trk_slide_wait_hi,x
    lda #$0A
    bne _l4CE5
_l4CE3
    lda tmp_1C
_l4CE5
    and #$0F
    tay
    lda slide_rates,y
    sta tmp_1C
    cmp #$FF
    bne _l4D03
    lda trk_slide_time_hi,x
    bne _l4CFB
    sta trk_slide_time_lo,x
    beq _l4CFE
_l4CFB
    dec trk_slide_time_hi,x
_l4CFE
    lda tmp_ptr+1
    jmp _l4D63
_l4D03
    lda trk_slide_time_lo,x
    sec
    sbc tmp_1C
    sta trk_slide_time_lo,x
    bcs _l4D1B
    dec trk_slide_time_hi,x
    bpl _l4D1B
    lda #$00
    sta trk_slide_time_lo,x
    sta trk_slide_time_hi,x
_l4D1B
    ldy #$07
    lda tmp_ptr+1
_l4D1F
    cmp #$80
    ror a
    ror tmp_ptr
    dey
    bmi _l4D2B
    asl tmp_1C
    bcc _l4D1F
_l4D2B
    ldy #$00
    sty tmp_1C
    sta tmp_ptr+1
    cmp #$80
    bcc _l4D48
    sta tmp_1C
    eor #$FF
    sta tmp_ptr+1
    lda tmp_ptr
    eor #$FF
    clc
    adc #$01
    sta tmp_ptr
    bcc _l4D48
    inc tmp_ptr+1
_l4D48
    lda trk_slide_frac,x
    clc
    adc tmp_ptr
    sta trk_slide_frac,x
    bcc _l4D55
    inc tmp_ptr+1
_l4D55
    lda tmp_ptr+1
    tay
    beq _l4D68
    ldy tmp_1C
    bpl _l4D63
    eor #$FF
    clc
    adc #$01
_l4D63
    jsr sub_51C7
    ldy #$FF
_l4D68
    pla
    sta tmp_1C
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
    sta tmp_ptr
    txa
    pha
    clc
    lda #$60
    adc ym_channel
    tay
_l4D8D
    lda trk_op_tl,x
    sta ym_shadow,y
    tya
    clc
    adc #$08
    tay
    txa
    clc
    adc #$1E
    tax
    dec tmp_ptr
    bpl _l4D8D
    pla
    tax
    lda trk_scale_ptr_lo,x
    sta tmp_ptr
    lda trk_scale_ptr_hi,x
    sta tmp_ptr+1
    ldy #$08
    lda trk_level_offset,x
    sta ram_08A2,y
    dey
_l4DB6
    lda (tmp_ptr),y
    sta ram_08A2,y
    dey
    bne _l4DB6
_l4DBE
    lda trk_glide_rate,x
    beq _l4E12
    lda trk_glide_hi,x
    ora trk_glide_lo,x
    beq _l4E12
    lda tick_count
    and #$06
    bne _l4E12
    lda #$00
    sta tmp_ptr+1
    lda trk_glide_rate,x
    asl a
    rol tmp_ptr+1
    sta tmp_ptr
    lda trk_glide_hi,x
    bmi _l4DF7
    lda trk_glide_lo,x
    sec
    sbc tmp_ptr
    sta trk_glide_lo,x
    lda trk_glide_hi,x
    sbc tmp_ptr+1
    sta trk_glide_hi,x
    bpl _l4E12
    bmi _l4E0A
_l4DF7
    lda trk_glide_lo,x
    clc
    adc tmp_ptr
    sta trk_glide_lo,x
    lda trk_glide_hi,x
    adc tmp_ptr+1
    sta trk_glide_hi,x
    bmi _l4E12
_l4E0A
    lda #$00
    sta trk_glide_hi,x
    sta trk_glide_lo,x
_l4E12
    lda zp_22
    bne _l4E55
    lda trk_glide_lo,x
    sta ram_0897
    lda trk_glide_hi,x
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
    adc ym_channel
    tay
    lda trk_key_fraction,x
    clc
    adc ram_0897
    bcc _l4E44
    inc ram_0896
_l4E44
    and #$FC
    sta ym_shadow,y
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
    ldx trk_link,y
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
    ldx trk_link,y
    bne _l4E7F
    rts
_l4E7F
    dex
    lda #$00
    sta ram_088E
    sta ram_0895
    sty ram_0898
    lda ymtimer_active
    beq _l4E9F
    lda ym_channel
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
    adc ym_channel
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda ym_shadow,y
    sta YM2151_DATA
    lda #$30
    clc
    adc ym_channel
    tay
    jsr ym_wait
    sty YM2151_REG
    lda ym_shadow,y
    sta YM2151_DATA
    plp
    lsr ram_08AB
    bcc _l4EE3
    ldy #$08
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda ym_channel
    sta YM2151_DATA
    plp
_l4EE3
    lda ram_088E
    cmp min_priority
    bcc _l4EA6
    lsr ram_08AB
    bcc _l4EA6
    ldx ram_0895
    beq _l4EA6
    clc
    lda ym_channel
    adc #$28
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    lda key_codes,x
    sta ym_shadow,y
    sta YM2151_DATA
    plp
    sta ram_0895
    lda #$20
    clc
    adc ym_channel
    tax
    lda ym_shadow,x
    and #$07
    tax
    lda tbl_57D3,x
    sta tmp_ptr+1
    ldy #$06
    sty fm_op_index
    lda ram_08AB
    lsr a
    lsr a
    and #$03
    tax
    lda level_bias,x
    sta ram_088F
    lda ram_08A4,y
    sec
    sbc ram_088F
    bmi _l4F3F
    bvc _l4F3F
    lda #$80
_l4F3F
    sta tmp_ptr
    sta tmp_1B
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
    sta tmp_ptr
_l4F54
    asl tmp_ptr
_l4F56
    ldy fm_op_index
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
    lda nibble_scale,y
    sta ram_088C
    ldy fm_op_index
    lda ram_08A3,y
    eor tmp_ptr
    and #$0F
    eor tmp_ptr
    tay
    lda nibble_scale,y
    sta tmp_1C
    rol tmp_ptr+1
    bcs _l4F92
    asl tmp_1C
_l4F92
    lda tmp_1B
    bpl _l4F9F
    lda tmp_1C
    eor #$FF
    clc
    adc #$01
    sta tmp_1C
_l4F9F
    clc
    lda fm_op_index
    asl a
    asl a
    adc ym_channel
    adc #$60
    tay
    php
    sei
    jsr ym_wait
    sty YM2151_REG
    clc
    jsr ym_wait
    lda ym_shadow,y
    adc ram_088C
    bmi _l4FC8
    clc
    adc tmp_1C
    bpl _l4FCA
    bvs _l4FC8
    lda #$00
    beq _l4FCA
_l4FC8
    lda #$7F
_l4FCA
    sta YM2151_DATA
    plp
    dec fm_op_index
    dec fm_op_index
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
    lda ym_channel
    ora #$78
    sta YM2151_DATA
    sta ym_shadow,y
    plp
_l500D
    rts

; from 505A
loc_500E
    lda #$07
    sta ym_channel
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
    dec ym_channel
    bpl _l5019
    rts

; from 427A, 4286, 428E, 4295, 42A6, 42AE, 439A, 4EAF, 4EC1, 4ED7, 4EFC, 4FAB, 4FB2, 4FE7, 4FF2,
; 4FFC, 55B8, 55D0, 55F2, 5613, 56A8, 58A3, 58D3, 591A, 5925, 5938, 5943, 594E, 5959, 5964, 596F,
; 597A, 5985, 599C, 59A8, 59B5, 59D6, 59E1, 5A4D, 5A5E, 5A6A, 5A77, 5A88, 5A93, 5AA2, 5AAD, 5B66
; Wait until the YM2151 is not busy (status bit 7), at most 255 reads: on a time-out set ym_timed_out
; (later calls return at once) and board_status bit 1 (the status imm_03_send_status sends). Keeps A.
ym_wait
    bit ym_timed_out
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
    sta ym_timed_out
    lda board_status
    ora #$02
    sta board_status
_l5041
    pla
_l5042
    rts

; from 4230, 4235
loc_5043
    lda tbl_57DB,x
    sta engine_chip
    lda tbl_57DD,x
    sta engine_chip+1
    lda tbl_57DF,x
    sta ram_0899
    cmp #$03
    bne _l505A
    jmp loc_4E56
_l505A
    jmp loc_500E

; from 485F
; A stream byte A of 80 and up: BB and up ends the entry (C clear); else op_handlers entry
; A - 80, entered by RTS with Y at the next byte, A that byte and C set.
sub_505D
    cmp #$BB
    bcc _l5068
    lda #$FF
    sta trk_sound,x
    clc
    rts
_l5068
    iny
    stx tmp_1C
    asl a
    tax
    lda op_handlers+1,x
    pha
    lda op_handlers,x
    pha
    ldx tmp_1C
    lda (zp_06),y
    sec
    rts

; from 518E, 5199, 51A9, 51B8, 5237, 52C2, 537D, 5380, 5389, 53A4, 53A7, 53B0, 547A, 547D, 5482,
; 5487, 5531, 554A, 555A, 5641, 5685
sub_507B
    lda trk_ptr_lo,x
    clc
    adc #$01
    sta trk_ptr_lo,x
    bcc _l5089
    inc trk_ptr_hi,x
_l5089
    iny
    lda (zp_06),y
    rts

; from 452E; not executed in the make sndtrace runs
loc_508D
    php
    sei
_l508F
    lda trk_link,x
    beq _l50A1
    tax
    dex
    lda trk_sound,x
    cmp cmd_target_sound
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
    lda cmd_op_operand
    rts

; read at 506D, 5071, 50A3, 50A7
; The 59 stream ops 80-BA, each word the handler's address - 1 (sub_505D pushes it and returns
; into it; sub_50A3 does the same with Y, from 509E). The table ends where the code of op_88
; starts (5125). Handlers several ops share keep a neutral loc_XXXX.
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
    .word cmdtype_11_ym_ct-1                  ; $A5
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
    sta trk_wait_frac,x
    sta trk_wait_lo,x
    sta trk_wait_hi,x
    ldy trk_sync_state,x
    beq _l513D
    iny
    bne _l5170
_l5138
    sta trk_sync_state,x
    sec
    rts
_l513D
    lda trk_sync_group,x
    sta trk_sync_state,x
    ldy #$1D
_l5145
    cmp trk_sync_group,y
    bne _l5157
    cmp trk_sync_state,y
    beq _l5157
    lda trk_priority,y
    bne _l5170
    lda trk_sync_group,x
_l5157
    dey
    bpl _l5145
    ldy #$1D
_l515C
    cmp trk_sync_group,y
    bne _l5169
    lda #$FF
    sta trk_sync_state,y
    lda trk_sync_group,x
_l5169
    dey
    bpl _l515C
    lda #$00
    beq _l5138
_l5170
    lda trk_ptr_lo,x
    cmp #$02
    bcs _l517A
    dec trk_ptr_hi,x
_l517A
    dec trk_ptr_lo,x
    dec trk_ptr_lo,x
    clc
    rts

; op_handlers entry for stream byte $89; not executed in the make sndtrace runs
op_89
    sta trk_sync_group,x
    lda #$00
    sta trk_sync_state,x
    rts

; op_handlers entry for stream byte $87; not executed in the make sndtrace runs
op_87
    sta trk_op_tl,x
    jsr sub_507B
    sta trk_op_tl+$1E,x
    sec
    rts

; op_handlers entry for stream byte $86; not executed in the make sndtrace runs
op_86
    sta trk_op_tl+$3C,x
    jsr sub_507B
    sta trk_op_tl+$5A,x
    sec
    rts

; op_handlers entry for stream byte $81; not executed in the make sndtrace runs
op_81
    clc
    adc trk_tempo_lo,x
    sta trk_tempo_lo,x
    php
    jsr sub_507B
    plp

; from 5442; not executed in the make sndtrace runs
loc_51AD
    adc trk_tempo_hi,x
    sta trk_tempo_hi,x
    sec
    rts

; op_handlers entry for stream byte $80
op_80
    sta trk_tempo_lo,x
    jsr sub_507B

; from 5408
loc_51BB
    sta trk_tempo_hi,x
    sec
    rts

; op_handlers entry for stream byte $83; from 5446
op_83
    ldy trk_sound,x
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
    adc trk_key_fraction,x
    bpl _l51D9
    lda #$00
_l51D9
    cmp #$10
    bcc loc_51F2
    lda #$0F
    bne loc_51F2

; op_handlers entry for stream byte $82; from 540C
op_82
    ldy trk_sound,x
    cpy #$FE
    beq loc_51F7
    ldy ram_0899
    cpy #$02
    bne loc_51F2
    jmp loc_5788

; not executed in the make sndtrace runs
loc_51F2
    sta trk_key_fraction,x
    sec
    rts

loc_51F7
    clc
    rts

; op_handlers entry for stream byte $85; from 543A; not executed in the make sndtrace runs
op_85
    clc
    adc trk_transpose,x

; op_handlers entry for stream byte $84; from 5401
op_84
    sta trk_transpose,x
    sec
    rts

; op_handlers entry for stream byte $8A; not executed in the make sndtrace runs
op_8A
    sta trk_e1_ctl,x
    rts

; op_handlers entry for stream byte $8B; not executed in the make sndtrace runs
op_8B
    ldy ram_0899
    beq _l5213
    eor ram_089A
    and #$09
    eor ram_089A
_l5213
    ora trk_scale_ptr_hi,x
    sta trk_scale_ptr_hi,x
    rts

; op_handlers entry for stream byte $9B; not executed in the make sndtrace runs
op_9B
    eor #$FF
    ldy ram_0899
    bne _l5228
    and trk_scale_ptr_lo,x
    sta trk_scale_ptr_lo,x
    rts
_l5228
    ora #$F6
    and trk_scale_ptr_hi,x
    sta trk_scale_ptr_hi,x
    rts

; op_handlers entry for stream byte $8C; not executed in the make sndtrace runs
op_8C
    sta trk_glide_rate,x
    rts

; op_handlers entry for stream byte $8D
op_8D
    sta tmp_1C
    jsr sub_507B
    sta zp_1D
    jsr alloc_frame
    beq _l5261
    pha
    lda trk_call_frame,x
    sta (frame_ptr),y
    pla
    sta trk_call_frame,x
    iny
    lda trk_ptr_lo,x
    sta (frame_ptr),y
    iny
    lda trk_ptr_hi,x
    sta (frame_ptr),y
    lda tmp_1C
    sta trk_ptr_lo,x
    lda zp_1D
    sta trk_ptr_hi,x
_l5261
    sec
    rts

; op_handlers entry for stream byte $8E
op_8E
    pha
    jsr alloc_frame
    beq _l528B
    pha
    lda trk_loop_frame,x
    sta (frame_ptr),y
    pla
    sta trk_loop_frame,x
    iny
    lda trk_ptr_lo,x
    sta (frame_ptr),y
    iny
    lda trk_ptr_hi,x
    sta (frame_ptr),y
    iny
    lda trk_loop_count,x
    sta (frame_ptr),y
    pla
    sta trk_loop_count,x
    sec
    rts
_l528B
    pla
    sec
    rts

; op_handlers entry for stream byte $8F
op_8F
    lda trk_loop_frame,x
    beq _l52A7
    jsr frame_address
    dec trk_loop_count,x
    beq _l52A9
    iny
    lda (frame_ptr),y
    sta trk_ptr_lo,x
    iny
    lda (frame_ptr),y
    sta trk_ptr_hi,x
_l52A7
    sec
    rts
_l52A9
    pha
    lda (frame_ptr),y
    sta trk_loop_frame,x
    lda frame_free
    sta (frame_ptr),y
    pla
    sta frame_free
    iny
    iny
    iny
    lda (frame_ptr),y
    sta trk_loop_count,x
    sec
    rts

; op_handlers entry for stream byte $A4
op_A4
    sta tmp_1C
    jsr sub_507B
    ldy trk_sound,x
    cpy #$FE
    beq _l52EB
    sta trk_slide_rate_hi,x
    lda tmp_1C
    lsr a
    lsr a
    lsr a
    sta trk_slide_time_hi,x
    lda #$00
    sta trk_slide_time_lo,x
    sta trk_slide_frac,x
    lda tmp_1C
    asl a
    asl a
    asl a
    asl a
    asl a
    sta trk_slide_rate_lo,x
    sec
    rts
_l52EB
    clc
    rts

; op_handlers entry for stream byte $A9
op_A9
    clc
    adc trk_acc,x

; from 5300, 5306, 530C, 5312, 533F, 536C, 53C1, 544E
loc_52F1
    sta trk_acc,x
    sta trk_test,x
    sec
    rts

; op_handlers entry for stream byte $AA; not executed in the make sndtrace runs
op_AA
    sta tmp_1C
    lda trk_acc,x
    sbc tmp_1C
    jmp loc_52F1

; op_handlers entry for stream byte $AB
op_AB
    and trk_acc,x
    jmp loc_52F1

; op_handlers entry for stream byte $AC; not executed in the make sndtrace runs
op_AC
    ora trk_acc,x
    jmp loc_52F1

; op_handlers entry for stream byte $AD; not executed in the make sndtrace runs
op_AD
    eor trk_acc,x
    jmp loc_52F1

; op_handlers entry for stream byte $B3; not executed in the make sndtrace runs
op_B3
    clc
    tay
    lda trk_acc,x
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
    lda trk_acc,x
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
    sta tmp_1C
    lda trk_acc,x
    bne _l537B
    lda tmp_1C
    jmp _l5389
_l537B
    sta tmp_1B
_l537D
    jsr sub_507B
    jsr sub_507B
    sta tmp_1C
    dec tmp_1B
    bne _l537D
_l5389
    jsr sub_507B
    sta trk_ptr_hi,x
    lda tmp_1C
    sta trk_ptr_lo,x
    sec
    rts

; op_handlers entry for stream byte $AF; not executed in the make sndtrace runs
op_AF
    sta tmp_1C
    lda trk_acc,x
    bne _l53A2
    lda tmp_1C
    jmp _l53B0
_l53A2
    sta tmp_1B
_l53A4
    jsr sub_507B
    jsr sub_507B
    sta tmp_1C
    dec tmp_1B
    bne _l53A4
_l53B0
    jsr sub_507B
    sta trk_ptr_hi,x
    lda tmp_1C
    sta trk_ptr_lo,x
    inc trk_acc,x
    lda trk_acc,x
    jmp loc_52F1

; op_handlers entry for stream byte $B0
op_B0
    cmp #$26
    bcs _l540F
    cmp #$06
    bcc _l53D8
    sbc #$06
    tay
    lda trk_acc,x
    sta @w seq_vars,y
    jmp _l540F
_l53D8
    cmp #$05
    beq _l540F
    ldy ram_0899
    cpy #$02
    bne _l53F5
    tay
    lda trk_acc,x
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
    lda trk_acc,x
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
    lda trk_acc,x
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
    lda trk_acc,x
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
    sta tmp_1C
    lda trk_acc,x
    sbc tmp_1C
    sta trk_test,x
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
    sta tmp_1C
    jsr sub_507B
    sta trk_ptr_hi,x
    lda tmp_1C
    sta trk_ptr_lo,x
    sec
    rts

; from 544B, 5451, 5460, 5467, 546E, 5475
sub_5494
    sty tmp_1C
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
    ldy tmp_1C
    lda trk_key_fraction,x
    rts
_l54B3
    cmp #$03
    bcc _l54C2
    ldy tmp_1C
    lda trk_level_offset,x
    eor #$FF
    clc
    adc #$01
    rts
_l54C2
    cmp #$02
    beq _l54D5
    cmp #$01
    beq _l54DF
    ldy tmp_1C
    rts
_l54CD
    cmp #$03
    bcs _l54FE
    cmp #$02
    bcc _l54DB
_l54D5
    ldy tmp_1C
    lda trk_transpose,x
    rts
_l54DB
    cmp #$01
    bcc _l54E5
_l54DF
    ldy tmp_1C
    lda trk_tempo_hi,x
    rts
_l54E5
    ldy tmp_1C
    lda trk_key_fraction,x
    rts
_l54EB
    sbc #$06
    tay
    lda @w seq_vars,y
    pha
    ldy tmp_1C
    pla
    rts
_l54F6
    jsr sub_5504
    pha
    ldy tmp_1C
    pla
    rts
_l54FE
    ldy tmp_1C
    lda trk_test,x
    rts

; from 4149, 54F6
sub_5504
    lda rng_state
    asl a
    bcc _l550B
    eor #$1D
_l550B
    sta rng_state
    rts

; op_handlers entry for stream byte $96; not executed in the make sndtrace runs
op_96
    jsr queue_response
    sec
    rts

; op_handlers entry for stream byte $97; not executed in the make sndtrace runs
op_97
    lda #$00
    sta trk_slide_time_lo,x
    sta trk_slide_frac,x
    sta trk_slide_rate_lo,x
    lda #$D0
    sta trk_slide_rate_hi,x
    lda #$02
    sta trk_slide_time_hi,x
    lda #$FE
    sta trk_sound,x
    sec
    rts

; op_handlers entry for stream byte $99
op_99
    sta tmp_1C
    jsr sub_507B
    sta trk_ptr_hi,x
    lda tmp_1C
    sta trk_ptr_lo,x
    sec
    rts

; op_handlers entry for stream byte $9D
op_9D
    sta tmp_1C
    lda trk_sound,x
    cmp #$FE
    bne _l554F
    inc trk_sound,x
    jsr sub_507B
    clc
    rts
_l554F
    php
    sei
    lda tmp_1C
    stx tmp_1C
    sta tmp_ptr
    sta ram_0536,x
    jsr sub_507B
    sta tmp_ptr+1
    sta trk_patch_hi,x
    plp
    ldy #$00
    lda (tmp_ptr),y
    sta trk_reg20,x
    lda #$03
    sta fm_op_index
    ldy #$05
_l5570
    lda (tmp_ptr),y
    sta trk_op_tl,x
    tya
    clc
    adc #$06
    tay
    txa
    clc
    adc #$1E
    tax
    dec fm_op_index
    bpl _l5570
    ldx tmp_1C

; from 4976
sub_5585
    php
    sei
    ldy zp_22
    beq _l558E
    jmp loc_5638
_l558E
    stx tmp_1C
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
    sta tmp_ptr
    clc
    adc #$1C
    sta trk_scale_ptr_lo,x
    lda trk_patch_hi,x
    sta tmp_ptr+1
    adc #$00
    sta trk_scale_ptr_hi,x
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
    lda ym_channel
    sta YM2151_DATA
    sta ym_shadow,x
    lda #$03
    sta fm_op_index
    clc
    lda #$60
    adc ym_channel
_l55CF
    tax
    jsr ym_wait
    stx YM2151_REG
    lda #$7F
    sta ym_shadow,x
    sta YM2151_DATA
    txa
    clc
    adc #$08
    dec fm_op_index
    bpl _l55CF
    ldy #$00
    lda #$03
    sta fm_op_index
    clc
    lda ym_channel
    adc #$20
_l55F1
    tax
    jsr ym_wait
    stx YM2151_REG
    lda (tmp_ptr),y
    sta ym_shadow,x
    sta YM2151_DATA
    txa
    clc
    adc #$08
    iny
    dec fm_op_index
    bpl _l55F1
    lda #$03
    sta fm_op_index
    clc
    lda #$40
    adc ym_channel
_l5612
    tax
    jsr ym_wait
    stx YM2151_REG
    lda (tmp_ptr),y
    sta ym_shadow,x
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
    dec fm_op_index
    bpl _l5612
    ldx tmp_1C

; from 558B, 5597
loc_5638
    plp
    sec
    rts

; op_handlers entry for stream byte $9E
op_9E
    clc
    adc #$24
    sta tmp_ptr
    php
    jsr sub_507B
    plp
    adc #$00
    sta tmp_ptr+1
    ldy ram_0899
    cpy #$02
    bne _l567D
    lda #$80
    sta trk_keyon_flags,x
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
    lda (tmp_ptr),y
    sta ym_shadow,x
    ldx tmp_1C
_l567D
    sec
    rts

; op_handlers entry for stream byte $9F; not executed in the make sndtrace runs
op_9F
    clc
    adc #$29
    sta tmp_ptr
    php
    jsr sub_507B
    plp
    adc #$00
    sta tmp_ptr+1
    ldy ram_0899
    cpy #$02
    bne _l569F
    sec
    ldy #$00
    tya
    ldx #$0F
    jsr sub_56A1
    ldx tmp_1C
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
    ora (tmp_ptr),y
    iny
    sta YM2151_DATA
    sta ym_shadow,x
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
    sta tmp_ptr
    lda trk_reg20,x
    and #$3F
    ora tmp_ptr
    sta trk_reg20,x
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
    adc trk_level_offset,x
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
    sta trk_level_offset,x

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
    sty tmp_1B
    asl a
    bcc _l5721
    ldy #$FF
    sty tmp_1B
_l5721
    asl a
    rol tmp_1B
    clc
    adc trk_key_fraction,x
    sta trk_key_fraction,x
    lda tmp_1B
    adc trk_transpose,x
    sta trk_transpose,x
    jmp loc_570D

; op_handlers entry for stream byte $A6; from 53EB
op_A6
    ldy ram_0899
    cpy #$02
    bne loc_570D
    asl a
    asl a
    sta trk_key_fraction,x
    sec
    rts

; op_handlers entry for stream byte $A8; not executed in the make sndtrace runs
op_A8
    sta trk_slide_step,x
    rts

; op_handlers entry for stream byte $A1; from 51CE, 57C0
op_A1
    ldy ram_0899
    cpy #$02
    beq _l5750
    rts
_l5750
    stx tmp_1C
    eor #$FF
    clc
    adc #$01
    sta tmp_ptr
    lda trk_reg20,x
    and #$07
    tay
    lda tbl_57D3,y
    sta tmp_ptr+1
    ldy #$03
_l5766
    asl tmp_ptr+1
    bcs _l577C
    lda trk_op_tl,x
    adc tmp_ptr
    bpl _l5779
    bvs _l5777
    lda #$00
    beq _l5779
_l5777
    lda #$7F
_l5779
    sta trk_op_tl,x
_l577C
    txa
    clc
    adc #$1E
    tax
    dey
    bpl _l5766
    ldx tmp_1C
    sec
    rts

; from 51EF
loc_5788
    ldy trk_sound,x
    cpy #$FE
    bne _l5791
    clc
    rts
_l5791
    pha
    txa
    pha
    lda ram_0536,x
    sta tmp_ptr
    lda trk_patch_hi,x
    sta tmp_ptr+1
    lda #$03
    sta fm_op_index
    ldy #$05
_l57A4
    lda (tmp_ptr),y
    sta trk_op_tl,x
    tya
    clc
    adc #$06
    tay
    txa
    clc
    adc #$1E
    tax
    dec fm_op_index
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
