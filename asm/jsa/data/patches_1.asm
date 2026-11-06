; patches_1.asm: 6B80-6FC3, YM2151 patch records 00-19 (26 records of 42 bytes).
;
; A record is what the ops patch (9D), lfo (9E) and noise (9F) read through their address
; operand (the macros ym_voice, ym_operator, ym_scaling, ym_lfo and ym_noise of
; data/macros.asm, in record order; docs/12-sound-music.md section 4). Each record's comment
; lists the streams whose patch, lfo or noise ops name it.

    .cerror * != $6B80, "patches_1.asm must start at $6B80"

; no patch op points here
patch_00
    #ym_voice $F8, $00, $00, $00
    #ym_operator $72, $20, $1F, $00, $00, $00 ; M1
    #ym_operator $34, $23, $1F, $00, $00, $00 ; M2
    #ym_operator $78, $23, $0C, $00, $00, $06 ; C1
    #ym_operator $34, $00, $0C, $80, $00, $06 ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $06                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_1D_0
patch_01
    #ym_voice $FA, $00, $00, $00
    #ym_operator $05, $20, $1F, $17, $08, $FC ; M1
    #ym_operator $45, $2D, $1D, $15, $08, $FC ; M2
    #ym_operator $05, $2D, $5F, $0F, $08, $F9 ; C1
    #ym_operator $01, $00, $DC, $86, $08, $29 ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_11_0
patch_02
    #ym_voice $FA, $00, $00, $00
    #ym_operator $00, $18, $54, $00, $00, $FF ; M1
    #ym_operator $00, $0F, $14, $00, $00, $FF ; M2
    #ym_operator $05, $23, $94, $00, $00, $FF ; C1
    #ym_operator $04, $00, $14, $86, $00, $FF ; C2
    #ym_scaling $00, $66                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $56                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $07

; used by snd_12_0
patch_03
    #ym_voice $FB, $00, $00, $00
    #ym_operator $30, $19, $8E, $0E, $00, $13 ; M1
    #ym_operator $00, $1E, $9F, $0E, $00, $1F ; M2
    #ym_operator $71, $0A, $0F, $00, $00, $0A ; C1
    #ym_operator $03, $00, $13, $83, $00, $0A ; C2
    #ym_scaling $00, $10                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $80                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch op points here
patch_04
    #ym_voice $C4, $00, $00, $00
    #ym_operator $05, $08, $1F, $1F, $16, $37 ; M1
    #ym_operator $05, $08, $1F, $1F, $16, $37 ; M2
    #ym_operator $02, $00, $9F, $92, $1F, $27 ; C1
    #ym_operator $33, $00, $9F, $92, $1F, $29 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $30                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_1B_0
patch_05
    #ym_voice $EC, $00, $00, $00
    #ym_operator $01, $7F, $09, $04, $05, $25 ; M1
    #ym_operator $27, $19, $DE, $02, $05, $A5 ; M2
    #ym_operator $21, $07, $1D, $84, $05, $05 ; C1
    #ym_operator $32, $09, $5D, $89, $05, $A5 ; C2
    #ym_scaling $00, $F2                ; M1
    #ym_scaling $00, $42                ; M2
    #ym_scaling $00, $F7                ; C1
    #ym_scaling $00, $47                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_1F_0
patch_06
    #ym_voice $DD, $00, $00, $70
    #ym_operator $00, $08, $1F, $0B, $49, $79 ; M1
    #ym_operator $70, $00, $1F, $90, $06, $F8 ; M2
    #ym_operator $70, $00, $1F, $87, $0C, $D8 ; C1
    #ym_operator $60, $00, $09, $8B, $10, $38 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $B4, $FF, $00, $03
    #ym_noise $02, $00

; no patch op points here
patch_07
    #ym_voice $FE, $00, $00, $00
    #ym_operator $05, $08, $1F, $03, $48, $B4 ; M1
    #ym_operator $04, $00, $0C, $82, $41, $26 ; M2
    #ym_operator $01, $00, $10, $87, $81, $56 ; C1
    #ym_operator $03, $04, $0C, $82, $C1, $28 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $04                ; C2
    #ym_lfo $CB, $F8, $08, $02
    #ym_noise $00, $00

; used by snd_1A_0, snd_1A_1, unused_stream_02
patch_08
    #ym_voice $DD, $00, $00, $70
    #ym_operator $00, $08, $1F, $0B, $49, $04 ; M1
    #ym_operator $70, $00, $5F, $8A, $0A, $25 ; M2
    #ym_operator $70, $00, $9F, $9D, $07, $03 ; C1
    #ym_operator $60, $00, $5F, $8A, $0A, $04 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $B4, $FF, $00, $03
    #ym_noise $02, $00

; used by snd_18_1
patch_09
    #ym_voice $DD, $00, $00, $70
    #ym_operator $00, $08, $0C, $0B, $49, $04 ; M1
    #ym_operator $70, $00, $4C, $8A, $0A, $05 ; M2
    #ym_operator $70, $00, $8D, $9D, $07, $03 ; C1
    #ym_operator $60, $00, $4D, $8A, $0A, $04 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $B4, $FF, $00, $03
    #ym_noise $02, $00

; used by snd_10_0
patch_0A
    #ym_voice $CC, $00, $00, $00
    #ym_operator $71, $20, $1F, $00, $00, $F0 ; M1
    #ym_operator $32, $26, $1F, $00, $00, $F0 ; M2
    #ym_operator $72, $00, $14, $8E, $00, $F9 ; C1
    #ym_operator $32, $00, $14, $8E, $00, $F9 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_0F_2
patch_0B
    #ym_voice $E9, $00, $00, $00
    #ym_operator $20, $3C, $17, $00, $00, $06 ; M1
    #ym_operator $32, $14, $18, $1F, $00, $06 ; M2
    #ym_operator $13, $20, $13, $00, $00, $26 ; C1
    #ym_operator $51, $00, $12, $80, $00, $06 ; C2
    #ym_scaling $00, $02                ; M1
    #ym_scaling $00, $04                ; M2
    #ym_scaling $00, $03                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_1C_0
patch_0C
    #ym_voice $E0, $00, $00, $00
    #ym_operator $70, $1F, $DF, $02, $00, $07 ; M1
    #ym_operator $50, $0F, $9C, $02, $05, $08 ; M2
    #ym_operator $31, $0C, $51, $02, $03, $04 ; C1
    #ym_operator $10, $00, $9F, $82, $02, $06 ; C2
    #ym_scaling $80, $20                ; M1
    #ym_scaling $80, $20                ; M2
    #ym_scaling $80, $20                ; C1
    #ym_scaling $80, $20                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch op points here
patch_0D
    #ym_voice $42, $00, $00, $42
    #ym_operator $26, $1C, $1A, $00, $80, $F5 ; M1
    #ym_operator $34, $1B, $1F, $00, $C0, $05 ; M2
    #ym_operator $76, $23, $19, $00, $80, $F5 ; C1
    #ym_operator $30, $00, $0A, $80, $C0, $07 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $CD, $E4, $0F, $02
    #ym_noise $00, $00

; used by snd_13_0
patch_0E
    #ym_voice $42, $00, $00, $42
    #ym_operator $26, $1C, $1A, $00, $80, $F5 ; M1
    #ym_operator $34, $1B, $1F, $00, $C0, $05 ; M2
    #ym_operator $76, $23, $19, $00, $80, $F5 ; C1
    #ym_operator $30, $00, $0A, $80, $C0, $07 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $CD, $E4, $0F, $02
    #ym_noise $00, $00

; used by snd_14_0, snd_15_0, snd_16_0
patch_0F
    #ym_voice $C0, $00, $00, $00
    #ym_operator $01, $24, $16, $08, $C0, $F8 ; M1
    #ym_operator $00, $14, $1B, $00, $00, $08 ; M2
    #ym_operator $03, $1E, $19, $07, $40, $F8 ; C1
    #ym_operator $00, $00, $1F, $80, $00, $09 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_00_0, snd_00_1, snd_00_2, snd_00_3, snd_00_4, snd_00_5, snd_00_6, snd_00_7
patch_10
    #ym_voice $DC, $00, $00, $01
    #ym_operator $7F, $23, $1F, $0F, $00, $8A ; M1
    #ym_operator $01, $23, $9E, $06, $0B, $F6 ; M2
    #ym_operator $01, $12, $DB, $87, $0A, $86 ; C1
    #ym_operator $01, $00, $1F, $80, $00, $F7 ; C2
    #ym_scaling $00, $40                ; M1
    #ym_scaling $00, $40                ; M2
    #ym_scaling $80, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $B4, $8A, $0C, $02
    #ym_noise $00, $00

; used by snd_18_2
patch_11
    #ym_voice $F3, $00, $00, $70
    #ym_operator $22, $23, $09, $00, $C0, $F1 ; M1
    #ym_operator $76, $19, $09, $00, $40, $F1 ; M2
    #ym_operator $10, $12, $09, $00, $81, $F1 ; C1
    #ym_operator $00, $00, $09, $80, $00, $F7 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $A0, $FF, $00, $03
    #ym_noise $00, $00

; used by snd_00_7
patch_12
    #ym_voice $C7, $00, $00, $00
    #ym_operator $01, $00, $1F, $80, $1F, $FF ; M1
    #ym_operator $01, $00, $1F, $80, $1F, $FF ; M2
    #ym_operator $01, $00, $1F, $80, $1F, $FF ; C1
    #ym_operator $01, $00, $1F, $80, $1F, $FF ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_0F_0, snd_0F_1, snd_1A_1
patch_13
    #ym_voice $F4, $00, $00, $00
    #ym_operator $73, $23, $18, $00, $C0, $0A ; M1
    #ym_operator $33, $23, $18, $00, $C0, $0A ; M2
    #ym_operator $30, $00, $18, $80, $00, $0A ; C1
    #ym_operator $70, $00, $18, $80, $00, $0A ; C2
    #ym_scaling $00, $06                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $60                ; C1
    #ym_scaling $00, $60                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_17_0, unused_stream_01
patch_14
    #ym_voice $E3, $00, $00, $00
    #ym_operator $38, $1B, $0B, $00, $40, $FA ; M1
    #ym_operator $23, $11, $0B, $00, $80, $F0 ; M2
    #ym_operator $53, $19, $0E, $00, $82, $0A ; C1
    #ym_operator $71, $00, $0C, $81, $5F, $6F ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_19_0
patch_15
    #ym_voice $C3, $00, $00, $00
    #ym_operator $39, $1B, $0B, $00, $40, $F7 ; M1
    #ym_operator $23, $11, $0B, $00, $80, $F7 ; M2
    #ym_operator $F3, $16, $0E, $00, $82, $07 ; C1
    #ym_operator $DF, $00, $0C, $81, $5F, $67 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_0F_3
patch_16
    #ym_voice $F3, $00, $00, $00
    #ym_operator $32, $18, $1F, $00, $00, $00 ; M1
    #ym_operator $32, $10, $1F, $00, $00, $00 ; M2
    #ym_operator $D2, $1B, $0C, $00, $00, $06 ; C1
    #ym_operator $DA, $00, $0C, $80, $00, $06 ; C2
    #ym_scaling $00, $03                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $06                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; used by snd_18_0
patch_17
    #ym_voice $EE, $00, $00, $71
    #ym_operator $06, $08, $1F, $09, $01, $93 ; M1
    #ym_operator $03, $00, $1F, $8B, $8E, $36 ; M2
    #ym_operator $06, $00, $1F, $87, $01, $24 ; C1
    #ym_operator $01, $00, $1F, $89, $07, $06 ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $03                ; M2
    #ym_scaling $00, $05                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $C1, $FF, $0B, $03
    #ym_noise $00, $00

; used by snd_1E_0
patch_18
    #ym_voice $FE, $00, $00, $00
    #ym_operator $0F, $0E, $1F, $00, $00, $00 ; M1
    #ym_operator $01, $06, $14, $87, $00, $FA ; M2
    #ym_operator $01, $06, $14, $87, $00, $FA ; C1
    #ym_operator $01, $06, $14, $87, $C0, $FA ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $62, $FF, $00, $00
    #ym_noise $02, $00

; no patch op points here
patch_19
    #ym_voice $D0, $00, $00, $70
    #ym_operator $22, $1C, $0C, $17, $CE, $88 ; M1
    #ym_operator $03, $19, $0B, $0F, $CC, $07 ; M2
    #ym_operator $1F, $13, $0B, $11, $8D, $08 ; C1
    #ym_operator $73, $00, $0C, $8B, $4B, $07 ; C2
    #ym_scaling $00, $06                ; M1
    #ym_scaling $00, $06                ; M2
    #ym_scaling $00, $06                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $DC, $FF, $00, $03
    #ym_noise $00, $00

    .cerror * != $6FC4, "patches_1.asm must end at $6FC3"
