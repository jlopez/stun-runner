; sequencer.asm: 4759-57E2, the stream interpreter (the sequencer) and its YM2151 output.
;
; Tracks. 30 track slots (X = 00-1D) each play one byte stream of data/streams_*.asm; a track's
; variables are the 1E-byte arrays of ram.asm (0248-085F, index X). cmdtype_08 (commands.asm,
; the commands of type 08) starts the tracks of sound N, one per entry of data/sounds.asm: the
; sound number in ram_0248, priority x 4 + 1 in ram_03EC, the stream address in ram_0266/
; ram_0284, and the YM2151 channel entry_channel: the track joins that channel's list.
;
; Channels. ram_0860 + 1E + c heads the list of the tracks on channel c, linked through
; ram_0860,x (track + 1, 0 ends it) in rising priority (cmdtype_08, 4641-4677): an equal priority
; replaces the track (465A-4668). Two groups of lists (group_first_chain): group 0, lists 1E-25,
; the eight YM2151 channels (group_kind 02); group 1, lists 26-2B, six channels of a kind 03
; whose output this program never writes and no entry_channel reaches (no track joins them).
; Every track of a list runs; only the last, the highest priority, is heard: run_track marks the
; others muted (track_muted = FF, 4759-4764), and they keep time without writing the chip. When
; the heard track ends, free_track reloads the patch of the track that is heard next (4966-4976).
;
; The tick. h_irq (system.asm, about 249.7 Hz) calls tick_group with X = 0 and 1 on alternate
; ticks (sub_4229, 422B-4235): each group runs at about 124.9 Hz. tick_ym_group runs
; tick_ym_channel for channels 7 down to 0: the list's tracks (run_track), then the channel's
; YM2151 registers from the shadow ram_08AE + register (key-off, key code, fraction, levels,
; key-on). A track's time counter (24 bits: ram_02DE, ram_02FC, ram_031A) loses the tempo
; (ram_0626/ram_0644) each tick (4794-47AB); when it runs out, read_item reads statements until a
; note: an op byte (80-BA) runs its handler through op_handlers (run_op), a note sets the pitch
; and adds its length (note_lengths, tables.asm tbl_5FE3) to the counter. The gate counter
; (ram_0338, ram_0356, ram_0374) is the counter less twice the tempo (49C8-49F1): the key-off
; comes two ticks before the next note, at half the length with GATE_HALF, never with TIE.
;
; The other voice kind (kind 0 of ram_03EC bits 1-0, and group 1's output kind): read_item,
; set_note_length and other_voice_update keep its paths (pitch from tbl_5DB9, the envelopes of
; ops 86 and 87, the level and control bytes other_level/other_ctl_a/other_ctl_b); no stream of
; this program runs them (every track has kind 1 and a YM2151 channel) and the make sndtrace
; runs never executed them.
;
; The ops, the note bytes, the data macros and the MAME evidence: docs/12-sound-music.md.
; Generated once from a recursive descent (docs/09-sound-program.md section 3); hand-maintained.
; The few loc_/_lXXXX labels left are 64tass-local branch targets or address-named shared tails.

    .cerror * != $4759, "sequencer.asm must start at $4759"

; Run track X for one tick, then the next track of its list (next_track). A = chain_mute: 0, or
; FF to mute every track of the list (tick_ym_channel, channels 6-7 while the timer voices own
; them, 4E8A-4E9D). track_muted = FF when A or a next track (a higher priority) exists. A track
; with priority 0 or ram_0248 = FF (stopped by a command or the op stop) is freed (4765-4770).
; Then the time counter loses the tempo; at 0 read_item reads the next statements; the gate
; counter at 0 asks for the key-off (key_flags bit 0, 47CD-47E0). On a YM2151 track: a fade step
; (fade_step) every LEN_32 of time while a fade runs, the key-on path again after it to write the
; new TLs (47F5-4845), and the same every fourth tick while a portamento runs (482F-4845).
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

; Read the track's statements until a note (or the track stops): the pointer ram_0266/ram_0284
; runs two bytes ahead of stream_ptr, which addresses the statement read (484B-4859). An op byte
; goes to run_op; a note byte (00-7F) plus the transpose (0662, not for 00) is the pitch (4887);
; on a YM2151 track it goes into ram_02A2, the change since the last pitch into the portamento
; offset (48DD-48F0), and the patch's register-20 byte (ram_0518) into the shadow (4900-490B).
; A length byte 00 returns from a call (op 8D: the return address off the node list, 4919-493E)
; or frees the track (free_track); else set_note_length.
; Also the op_handlers entry of ops 90-94, 98, 9A, 9C: entered by RTS from run_op, it skips the op
; and its operand and reads on as a nested call of itself (the data never uses them).
; from 47AB, 493E
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

; The track ends: its priority 0 (the slot is free), its call and loop nodes back on the free
; list (sub_433C), unlinked from its list (chain_prev). When it was the heard track of a YM2151
; channel and a track before it remains, that track's patch is written again (load_patch,
; 4966-4976).
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

; The note's length byte in A (not 00): bits 3-0 index note_lengths (tables.asm tbl_5FE3), whose
; word is added to the time counter's bytes 1-2 (498B-49A1); DOT adds half of it again
; (49A2-49BC). Unless TIE: the gate counter = counter - 2 x tempo (49C8-49F1), halved with
; GATE_HALF (49F4-4A02). Then the fade's step (fade_step) when one runs, and on a YM2151 track the key-on
; (prepare_key_on with the length byte: its bits 5-4 select the accent, key_flags).
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

; The other voice kind's tick (no track of this program): the pitch envelope (ram_04BE/ram_04DC,
; op 86: pairs of count and 16-bit step, FF loops) into the pitch, the level envelope
; (ram_0482/ram_04A0, op 87) into the level, written to other_level/other_ctl_a/other_ctl_b.
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

; The other voice kind: level 0.
; from 47E8, 497C, 4AF5; not executed in the make sndtrace runs
other_voice_off
    lda #$00

; The other voice kind: A into other_level,y; for a track (X < 1E) the control bytes too.
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

; The next track of the list (ram_0860,x): run it with the same chain_mute (chain_prev = this
; track), else return.
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

; One fade step of track X (op fade A4, op release 97, cmdtype_0A/0B): the remaining time
; (ram_07AC:ram_078E) loses a step (fade_steps, tables.asm tbl_6003; entry 0A = 08 with fade_mode
; 0); the amount (ram_07E8:ram_07CA, signed) shifted right by the step's position (4D1B-4D2B) is
; added to the fraction ram_0806 and the whole part goes to add_volume (the carriers' TL, 4D63).
; With fade_mode 0 the step timer is reloaded with LEN_32 (4CD1-4CDF). Returns Y = 0 when the
; fade is over.
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

; A YM2151 note of the heard track: key_flags bit 1 (key-on) and the length byte's bits 5-4
; (the accent, 4D6C-4D82); the track's four TLs (ram_0482 + n x 1E) into the shadow of registers
; 60-78 (4D8D-4DA0); the patch's scaling bytes (record +1D to +23, through ram_0428/ram_0446 =
; record + 1C) and the velocity (ram_04FA) into key_scaling (4DA3-4DBC). For every track with a
; portamento: the offset ram_06F8/ram_0716 moves toward 0 by the rate (4DBE-4E11); the heard
; track's offset and fine tune go to the shadow of register 30 and the note (4E12-4E54).
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

; Group 1's tick: the six lists 26-2B (group_first_chain + 5 down to + 0), each run with
; chain_mute 0. No track is ever on them here.
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

; YM2151 channel zp_0D (list Y = 1E + channel): run its tracks (run_track; channels 6 and 7
; muted while zp_10 is set, the timer voices of ymtimer.asm, 4E8A-4E9D). When the heard track
; is not muted: registers 20 and 30 from the shadow (4EA7-4ECD); the key-off (key_flags bit 0:
; register 08 = channel, 4ED0-4EE1); then, only when sounding_prio (the heard track's
; priority x 4 + 1) is at least zp_1E (4EE3-4EE8; command 01 sets zp_1E to F0, 02 to 0), and a
; key-on is asked (key_flags bit 1) for a pitch other than 0: the key code key_codes[note]
; (tables.asm tbl_5E7D) into register 28 (4EF1-4F0E), each operator's TL = the track's TL +
; key scaling (key_level_curve by key code, depth nibble) + velocity scaling (velocity and the
; accent, key_accent tbl_5FDF, by the sensitivity nibble) clamped to 00-7F (4F16-4FD4), the LFO
; reset when the patch's lfo op asked for it (key_flags bit 4 after the shifts: register 01 = 02
; then 00, 4FDE-4FF7), and the key-on: register 08 = channel + 78, all four operators (4FFA-500B).
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

; Group 0's tick: tick_ym_channel for channels 7 down to 0 (lists 25 down to 1E).
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

; One group per timed IRQ: X = 0, the YM2151 group (tick_ym_group), X = 1, the other kind
; (tick_other_group); zp_08/zp_09 = the chip's base (group_chip_lo/hi), cur_group_kind = its
; kind (group_kind).
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

; A stream byte A of 80 and up: BB and up stops the track (ram_0248 = FF, C clear); else
; op_handlers entry A - 80, entered by RTS with Y = 1, A = the operand byte and C set. A handler
; returns C set to read on, C clear to end the tick (the op is read again when it backs the
; pointer up, op_sync).
; from 485F
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

; The next operand byte: the track's pointer + 1, Y + 1, A = (stream_ptr),y.
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

; cmdtype_0D (no command has type 0D): along the list from X, the first track playing sound
; ram_08AC runs the op handler Y (call_op_handler) with A = ram_08AD.
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

; Enter op handler Y (op_handlers + Y) by RTS with A = ram_08AD.
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
; into it; call_op_handler does the same with Y, from 509E); the comment is the op's macro in
; data/macros.asm. The table ends where the code of op_sync starts (5125).
op_handlers
    .word op_tempo-1                    ; $80 tempo
    .word op_tempo_add-1                ; $81 tempo_add
    .word op_volume-1                   ; $82 volume
    .word op_volume_add-1               ; $83 volume_add
    .word op_transpose-1                ; $84 transpose
    .word op_transpose_add-1            ; $85 transpose_add
    .word op_pitch_env-1                ; $86 pitch_env
    .word op_level_env-1                ; $87 level_env
    .word op_sync-1                     ; $88 sync
    .word op_sync_group-1               ; $89 sync_group
    .word op_ctl_bits-1                 ; $8A ctl_bits
    .word op_ctl_set-1                  ; $8B ctl_set
    .word op_portamento-1               ; $8C portamento
    .word op_call-1                     ; $8D call
    .word op_loop-1                     ; $8E loop
    .word op_loop_end-1                 ; $8F loop_end
    .word read_item-1                   ; $90 skip
    .word read_item-1                   ; $91 skip
    .word read_item-1                   ; $92 skip
    .word read_item-1                   ; $93 skip
    .word read_item-1                   ; $94 skip
    .word op_95-1                       ; $95 oki
    .word op_respond-1                  ; $96 respond
    .word op_release-1                  ; $97 release
    .word read_item-1                   ; $98 skip
    .word op_jump-1                     ; $99 jump
    .word read_item-1                   ; $9A skip
    .word op_ctl_clear-1                ; $9B ctl_clear
    .word read_item-1                   ; $9C skip
    .word op_patch-1                    ; $9D patch
    .word op_lfo-1                      ; $9E lfo
    .word op_noise-1                    ; $9F noise
    .word op_pan-1                      ; $A0 pan
    .word op_carrier_tl_sub-1           ; $A1 carrier_tl_sub
    .word op_velocity-1                 ; $A2 velocity
    .word op_velocity_add-1             ; $A3 velocity_add
    .word op_fade-1                     ; $A4 fade
    .word cmdtype_11-1                  ; $A5 ym_ct
    .word op_fine_tune-1                ; $A6 fine_tune
    .word op_bend-1                     ; $A7 bend
    .word op_fade_mode-1                ; $A8 fade_mode
    .word op_var_add-1                  ; $A9 var_add
    .word op_var_sub-1                  ; $AA var_sub
    .word op_var_and-1                  ; $AB var_and
    .word op_var_or-1                   ; $AC var_or
    .word op_var_xor-1                  ; $AD var_xor
    .word op_jump_table-1               ; $AE jump_table
    .word op_jump_table_inc-1           ; $AF jump_table_inc
    .word op_var_store-1                ; $B0 var_store
    .word op_var_add_to-1               ; $B1 var_add_to
    .word op_var_load-1                 ; $B2 var_load
    .word op_var_shr-1                  ; $B3 var_shr
    .word op_var_shl-1                  ; $B4 var_shl
    .word op_branch_zero-1              ; $B5 branch_zero
    .word op_branch_nonzero-1           ; $B6 branch_nonzero
    .word op_branch_plus-1              ; $B7 branch_plus
    .word op_branch_minus-1             ; $B8 branch_minus
    .word op_var_cmp_reg-1              ; $B9 var_cmp_reg
    .word op_var_cmp-1                  ; $BA var_cmp

; op 88 (sync): the track's time counter to 0; the first arrival marks the group's
; wait (ram_0680 = ram_069E); it backs the pointer up two bytes and returns C clear (5170-517E:
; the op is read again next tick) while a running track of the same group has not arrived; the
; last arrival marks every track of the group FF, which lets each go on (5138-513C)
; MAME: not dispatched in make musictrace
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

; op 89 (sync_group): ram_069E = the group sync waits on, ram_0680 = 0
; MAME: not dispatched in make musictrace
op_sync_group
    sta ram_069E,x
    lda #$00
    sta ram_0680,x
    rts

; op 87 (level_env): ram_0482/ram_04A0 = the level envelope (other voice kind)
; MAME: not dispatched in make musictrace
op_level_env
    sta ram_0482,x
    jsr next_operand
    sta ram_04A0,x
    sec
    rts

; op 86 (pitch_env): ram_04BE/ram_04DC = the pitch envelope (other voice kind)
; MAME: not dispatched in make musictrace
op_pitch_env
    sta ram_04BE,x
    jsr next_operand
    sta ram_04DC,x
    sec
    rts

; op 81 (tempo_add): the tempo + the 16-bit operand
; MAME: not dispatched in make musictrace
op_tempo_add
    clc
    adc ram_0626,x
    sta ram_0626,x
    php
    jsr next_operand
    plp

; the tempo's high byte + A with the carry (op_tempo_add, op_var_add_to register 1)
; from 5442; not executed in the make sndtrace runs
tempo_add_hi
    adc ram_0644,x
    sta ram_0644,x
    sec
    rts

; op 80 (tempo): the tempo (ram_0626/ram_0644) = the 16-bit operand
; MAME: dispatched in make musictrace
op_tempo
    sta ram_0626,x
    jsr next_operand

; the tempo's high byte = A (op_tempo, op_var_store register 1)
; from 5408
set_tempo_hi
    sta ram_0644,x
    sec
    rts

; op 83 (volume_add): refused while the track is releasing (ram_0248 = FE); YM2151:
; op_carrier_tl_sub (the carriers' TL - A); other kind: level + A within 0-F
; MAME: dispatched in make musictrace
op_volume_add
    ldy ram_0248,x
    cpy #$FE
    beq op_refuse

; The volume + A: YM2151, op_carrier_tl_sub; other kind, the level + A within 0-F. Also the
; fade's step (fade_step 4D63).
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

; op 82 (volume): refused while releasing; YM2151: volume_ym; other kind: level = A
; MAME: dispatched in make musictrace
op_volume
    ldy ram_0248,x
    cpy #$FE
    beq op_refuse
    ldy cur_group_kind
    cpy #$02
    bne store_volume
    jmp volume_ym

; the other kind's level = A
store_volume
    sta ram_0464,x
    sec
    rts

; C clear: the op is refused (the track is releasing)
op_refuse
    clc
    rts

; op 85 (transpose_add): the transpose (ram_0662) + A
; MAME: not dispatched in make musictrace
op_transpose_add
    clc
    adc ram_0662,x

; op 84 (transpose): the transpose (ram_0662) = A, added to every pitch but 00
; MAME: dispatched in make musictrace
op_transpose
    sta ram_0662,x
    sec
    rts

; op 8A (ctl_bits): ram_06BC = A, ORed into the other kind's level byte (4C8E)
; MAME: not dispatched in make musictrace
op_ctl_bits
    sta ram_06BC,x
    rts

; op 8B (ctl_set): the other kind's control bits (ram_0446) | A
; MAME: not dispatched in make musictrace
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

; op 9B (ctl_clear): the other kind's control bits & ~A
; MAME: not dispatched in make musictrace
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

; op 8C (portamento): ram_06DA = the glide rate (prepare_key_on 4DBE-4E11)
; MAME: not dispatched in make musictrace
op_portamento
    sta ram_06DA,x
    rts

; op 8D (call): push a node (sub_4309: ram_0734 link, return address) and go to the
; operand address; a note with length 00 returns (read_item 4919)
; MAME: dispatched in make musictrace
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

; op 8E (loop): push a node (ram_0752 link, the address after the op, ram_0770 count)
; with count A
; MAME: dispatched in make musictrace
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

; op 8F (loop_end): count - 1: not 0, back to the loop's start; 0, pop the node (the
; operand byte is not read)
; MAME: dispatched in make musictrace
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

; op A4 (fade): refused while releasing; the remaining time ram_07AC = operand 1 >> 3,
; ram_078E = 0, the amount ram_07E8 = operand 2, ram_07CA = operand 1 << 5, the fraction 0
; MAME: dispatched in make musictrace
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

; op A9 (var_add): var (ram_0824) + A; the result (ram_0842) = var
; MAME: dispatched in make musictrace
op_var_add
    clc
    adc ram_0824,x

; var (ram_0824) and the result (ram_0842) = A; C set
; from 5300, 5306, 530C, 5312, 533F, 536C, 53C1, 544E
store_var
    sta ram_0824,x
    sta ram_0842,x
    sec
    rts

; op AA (var_sub): var - A (C set by run_op: no borrow in)
; MAME: not dispatched in make musictrace
op_var_sub
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    jmp store_var

; op AB (var_and): var & A
; MAME: dispatched in make musictrace
op_var_and
    and ram_0824,x
    jmp store_var

; op AC (var_or): var | A
; MAME: not dispatched in make musictrace
op_var_or
    ora ram_0824,x
    jmp store_var

; op AD (var_xor): var ^ A
; MAME: not dispatched in make musictrace
op_var_xor
    eor ram_0824,x
    jmp store_var

; op B3 (var_shr): var >> A for A = 1-7 (other values: nothing)
; MAME: not dispatched in make musictrace
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

; op B4 (var_shl): var << A for A = 1-7
; MAME: not dispatched in make musictrace
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

; op AE (jump_table): go to word number var of the list after the op (no bound:
; the streams AND var first)
; MAME: dispatched in make musictrace
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

; op AF (jump_table_inc): as AE, then var + 1
; MAME: not dispatched in make musictrace
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

; op B0 (var_store): register A = var (06-25: the global variables zp_23+n; YM2151
; 0-4: volume, tempo high byte, transpose, velocity, fine tune; 5 and 26 up: nothing)
; MAME: dispatched in make musictrace
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

; op B1 (var_add_to): register A + var (the same registers as B0)
; MAME: not dispatched in make musictrace
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

; op B2 (var_load): var = register A (read_register)
; MAME: dispatched in make musictrace
op_var_load
    jsr read_register
    jmp store_var

; op B9 (var_cmp_reg): the result = var - register A
; MAME: not dispatched in make musictrace
op_var_cmp_reg
    jsr read_register

; op BA (var_cmp): the result (ram_0842) = var - A
; MAME: dispatched in make musictrace
op_var_cmp
    sta zp_1C
    lda ram_0824,x
    sbc zp_1C
    sta ram_0842,x
    sec
    rts

; op B5 (branch_zero): register operand 1 = 0: go to the address after it
; MAME: dispatched in make musictrace
op_branch_zero
    jsr read_register
    beq branch_taken
    bne branch_not_taken

; op B6 (branch_nonzero): register operand 1 not 0: go
; MAME: not dispatched in make musictrace
op_branch_nonzero
    jsr read_register
    bne branch_taken
    beq branch_not_taken

; op B7 (branch_plus): register operand 1 bit 7 clear: go
; MAME: not dispatched in make musictrace
op_branch_plus
    jsr read_register
    bpl branch_taken
    bmi branch_not_taken

; op B8 (branch_minus): register operand 1 bit 7 set: go
; MAME: dispatched in make musictrace
op_branch_minus
    jsr read_register
    bmi branch_taken

; skip the branch's address (two operand bytes)
branch_not_taken
    jsr next_operand
    jsr next_operand
    sec
    rts

; the pointer = the branch's address
branch_taken
    jsr next_operand
    sta zp_1C
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; A = register A of the track (the variable ops): 26 and up, the last result (ram_0842); 06-25,
; global variable A - 6 (zp_23+n, shared by every track; cmdtype_01 sets it); 05, the next random
; byte; YM2151: 04 the pitch fraction ram_0464, 03 -ram_04FA (the velocity), 02 the transpose,
; 01 the tempo's high byte, 00 the value 0; other kind: 00 the level, 01 and 02 the same, 03-04 the
; result. Keeps Y.
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

; The 8-bit random generator: zp_47 << 1, XOR 1D when a bit falls out (a maximal LFSR);
; main_loop runs it on every pass (4149), read_register for register 05.
; from 4149, 54F6
random
    lda zp_47
    asl a
    bcc _l550B
    eor #$1D
_l550B
    sta zp_47
    rts

; op 96 (respond): queue_response A for the 68010
; MAME: not dispatched in make musictrace
op_respond
    jsr queue_response
    sec
    rts

; op 97 (release): the release fade (as cmdtype_0A/0B): amount D0, time 2, ram_0248
; = FE; the track stops when the fade ends (4A5F-4A6E, 47F5-480C)
; MAME: not dispatched in make musictrace
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

; op 99 (jump): the pointer = the operand address
; MAME: dispatched in make musictrace
op_jump
    sta zp_1C
    jsr next_operand
    sta ram_0284,x
    lda zp_1C
    sta ram_0266,x
    sec
    rts

; op 9D (patch): the YM2151 patch record at the operand: while releasing, stop
; instead (ram_0248 = FF); else trk_patch_lo/ram_0554 = the record, ram_0518 = its byte 00
; (register 20), the four TLs (bytes 05, 0B, 11, 17) into ram_0482 + n x 1E, then load_patch
; MAME: dispatched in make musictrace
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

; Write the patch of track X into its YM2151 channel when the track is heard and the group
; is the YM2151 (else only C set); also from free_track for the track heard next.
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

; The timer voices' entry (ymtimer.asm): as load_patch, without the checks.
; from 5A20, 5A37; not executed in the make sndtrace runs
load_patch_regs
    php
    sei

; zp_19 = the record (trk_patch_lo/ram_0554); ram_0428/ram_0446 = record + 1C, the scaling
; bytes prepare_key_on copies.
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

; The timer voices' entry with zp_19 set (ymtimer.asm).
; from 589A, 58CA; not executed in the make sndtrace runs
write_patch_regs_at
    php
    sei

; The record at zp_19 into channel zp_0D: key-off (register 08), TL 7F on the four operators
; (60-78), record bytes 00-03 into 20, 28, 30, 38, then per operator M1, M2, C1, C2 (+00, +08,
; +10, +18) its bytes into 40, 80, A0, C0, E0, the TL byte skipped (55F1-5634); each written to
; the shadow ram_08AE too.
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

; op 9E (lfo): YM2151: registers 18, 19, 19 and 1B (bits 1-0, CT1-CT2 kept) from
; record bytes 24-27, byte 28 into the shadow of 1B (nothing reads it); ram_0572 = 80: the next
; key-on resets the LFO (key_flags bit 4)
; MAME: dispatched in make musictrace
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

; op 9F (noise): YM2151: register 0F from record byte 29
; MAME: dispatched in make musictrace
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

; YM2151 register X = A | record byte Y (the shadow too), Y + 1; nothing when the track is
; muted.
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

; op A0 (pan): YM2151: register 20 bits 7-6 of the track (ram_0518): A = 1 bit 7,
; 2 bit 6, 0 or 3 both
; MAME: dispatched in make musictrace
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

; op A3 (velocity_add): YM2151: ram_04FA - A, clamped to -80..7F
; MAME: dispatched in make musictrace
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

; op A2 (velocity): YM2151: ram_04FA = -A, the level the key-on scales by each
; operator's sensitivity (tick_ym_channel 4F2F-4F98)
; MAME: dispatched in make musictrace
op_velocity
    ldy cur_group_kind
    cpy #$02
    bne op_done
    eor #$FF
    clc
    adc #$01

; ram_04FA = A
store_velocity
    sta ram_04FA,x

; C set: read on
; from 5733
op_done
    sec
    rts

; op A7 (bend): YM2151: the pitch fraction ram_0464 + A x 4 (signed), the carry into
; the transpose ram_0662
; MAME: dispatched in make musictrace
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

; op A6 (fine_tune): YM2151: the pitch fraction ram_0464 = A x 4 (register 30)
; MAME: dispatched in make musictrace
op_fine_tune
    ldy cur_group_kind
    cpy #$02
    bne op_done
    asl a
    asl a
    sta ram_0464,x
    sec
    rts

; op A8 (fade_mode): ram_0608 = A: nonzero, fade steps only at note starts, the step
; by the length byte's low nibble (fade_step 4CCF; the other kind: the pitch envelope's count)
; MAME: not dispatched in make musictrace
op_fade_mode
    sta ram_0608,x
    rts

; op A1 (carrier_tl_sub): YM2151: each carrier's TL (ram_0482 + n x 1E for the
; operators M1, M2, C1, C2 whose modulator_mask bit for the patch's algorithm is clear) - A,
; clamped to 00-7F
; MAME: not dispatched in make musictrace
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

; op_volume on a YM2151 track: refused while releasing; the four TLs again from the patch
; record (bytes 05, 0B, 11, 17), then the carriers lowered by volume_steps[A & 0F]
; (op_carrier_tl_sub).
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

; read at 57BD: the volume's 16 levels as the negated carrier TL increase (volume 0: + 40,
; 0F: + 0)
volume_steps
    .byte $C0, $D6, $DC, $E1, $E9, $E6, $EE, $EB
    .byte $F2, $F0, $F6, $F5, $FA, $FB, $FE, $00

; read at 4F1B and 575F with the algorithm (register 20 bits 2-0): bits 7-4 set for the
; operators M1, M2, C1, C2 (in that order) that are not carriers. op_carrier_tl_sub reads the bits
; in that order; tick_ym_channel's level loop runs the operators C2, C1, M2, M1 (registers 78-60)
; with the same bits from bit 7 down, so its doubling of the velocity term lands on other
; operators (docs/12-sound-music.md section 3)
modulator_mask
    .byte $E0, $E0, $E0, $E0, $C0, $80, $80, $00

; read at 4269 and 5043: the group's chip base, low byte (zp_08)
group_chip_lo
    .byte $00, $00

; read at 426E and 5048: high byte (zp_09): the YM2151 at 2000 for group 0
group_chip_hi
    .byte $20, $00

; read at 4273 and 504D: the group's kind (cur_group_kind): 02 the YM2151, 03 the other
group_kind
    .byte $02, $03

; read at 441C, 4E5A and 5013: the group's first list (ram_0860 + 1E / + 26)
group_first_chain
    .byte $1E, $26

    .cerror * != $57E3, "sequencer.asm must end at $57E2"
