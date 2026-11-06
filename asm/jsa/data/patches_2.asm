; patches_2.asm: 9EFA-AB47, YM2151 patch records 1A-64 (75 records of 42 bytes).
;
; Same layout as patches_1.asm.

    .cerror * != $9EFA, "patches_2.asm must start at $9EFA"

; named by the patch, lfo or noise ops of snd_06_0, snd_06_6
patch_1A
    #ym_voice $C4, $00, $00, $00
    #ym_operator $72, $1D, $94, $02, $00, $07 ; M1
    #ym_operator $62, $0F, $85, $0A, $00, $0A ; M2
    #ym_operator $70, $1C, $90, $82, $00, $07 ; C1
    #ym_operator $10, $01, $89, $82, $00, $04 ; C2
    #ym_scaling $00, $40                ; M1
    #ym_scaling $00, $F0                ; M2
    #ym_scaling $00, $40                ; C1
    #ym_scaling $00, $50                ; C2
    #ym_lfo $C3, $E4, $02, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0D_6
patch_1B
    #ym_voice $E8, $00, $00, $00
    #ym_operator $30, $0F, $DF, $0A, $09, $29 ; M1
    #ym_operator $30, $0D, $9F, $00, $00, $00 ; M2
    #ym_operator $33, $26, $DF, $15, $06, $19 ; C1
    #ym_operator $30, $00, $9F, $87, $0D, $F9 ; C2
    #ym_scaling $00, $64                ; M1
    #ym_scaling $00, $44                ; M2
    #ym_scaling $00, $44                ; C1
    #ym_scaling $00, $04                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_4, snd_04_4, snd_0E_4
patch_1C
    #ym_voice $C7, $00, $00, $00
    #ym_operator $00, $00, $1F, $93, $00, $CF ; M1
    #ym_operator $00, $00, $1F, $8E, $14, $1F ; M2
    #ym_operator $00, $00, $1F, $93, $1F, $5F ; C1
    #ym_operator $00, $00, $1F, $8E, $14, $1F ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $01
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_1D
    #ym_voice $E9, $00, $00, $00
    #ym_operator $70, $1F, $1F, $0A, $06, $02 ; M1
    #ym_operator $21, $17, $DF, $1E, $01, $02 ; M2
    #ym_operator $70, $1A, $07, $08, $01, $A6 ; C1
    #ym_operator $31, $00, $1F, $8B, $02, $06 ; C2
    #ym_scaling $00, $03                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0C_0, snd_0C_1
patch_1E
    #ym_voice $FB, $00, $00, $00
    #ym_operator $72, $1D, $12, $0E, $00, $4A ; M1
    #ym_operator $31, $1E, $12, $0E, $00, $5A ; M2
    #ym_operator $31, $19, $14, $00, $00, $0A ; C1
    #ym_operator $71, $00, $14, $82, $01, $3A ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0C_5, snd_0C_7
patch_1F
    #ym_voice $FC, $00, $00, $30
    #ym_operator $31, $1B, $1F, $09, $00, $17 ; M1
    #ym_operator $73, $1B, $1F, $09, $00, $17 ; M2
    #ym_operator $33, $00, $0E, $9F, $00, $07 ; C1
    #ym_operator $71, $00, $0E, $9F, $00, $07 ; C2
    #ym_scaling $00, $50                ; M1
    #ym_scaling $00, $30                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $CD, $FF, $00, $02
    #ym_noise $02, $00

; no patch, lfo or noise op names this record
patch_20
    #ym_voice $C7, $00, $00, $00
    #ym_operator $01, $00, $10, $80, $80, $08 ; M1
    #ym_operator $01, $00, $10, $80, $C0, $08 ; M2
    #ym_operator $01, $00, $10, $80, $40, $08 ; C1
    #ym_operator $01, $00, $10, $80, $00, $08 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_21
    #ym_voice $FB, $00, $00, $00
    #ym_operator $0F, $23, $DF, $0C, $0F, $F3 ; M1
    #ym_operator $00, $23, $1F, $0A, $00, $55 ; M2
    #ym_operator $06, $23, $1F, $00, $00, $05 ; C1
    #ym_operator $01, $03, $DF, $83, $01, $5C ; C2
    #ym_scaling $00, $37                ; M1
    #ym_scaling $00, $37                ; M2
    #ym_scaling $00, $37                ; C1
    #ym_scaling $00, $37                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_22
    #ym_voice $FB, $00, $00, $00
    #ym_operator $00, $7F, $1F, $18, $00, $F6 ; M1
    #ym_operator $71, $1E, $1F, $15, $4D, $36 ; M2
    #ym_operator $52, $21, $1F, $15, $4C, $26 ; C1
    #ym_operator $00, $00, $1F, $93, $10, $29 ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $02                ; M2
    #ym_scaling $00, $03                ; C1
    #ym_scaling $00, $05                ; C2
    #ym_lfo $00, $80, $00, $01
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_2, snd_01_3, snd_04_5, snd_08_5, snd_09_4,
patch_23
; snd_0A_6, snd_0B_5, snd_0B_6, snd_0B_7, snd_0C_6, snd_0E_2, snd_0E_4, unused_stream_05,
; unused_stream_07
    #ym_voice $F4, $00, $00, $00
    #ym_operator $04, $08, $1F, $01, $C7, $F0 ; M1
    #ym_operator $02, $08, $1F, $07, $07, $54 ; M2
    #ym_operator $02, $04, $1F, $8A, $0A, $F5 ; C1
    #ym_operator $00, $00, $1F, $8D, $CA, $F5 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $04                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_24
    #ym_voice $F4, $00, $00, $00
    #ym_operator $04, $08, $1F, $01, $C7, $F7 ; M1
    #ym_operator $02, $08, $1F, $07, $07, $58 ; M2
    #ym_operator $02, $04, $1F, $8A, $0A, $57 ; C1
    #ym_operator $00, $00, $1F, $8F, $CA, $5A ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $04                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_03, unused_stream_04, unused_stream_06,
patch_25
; unused_stream_07
    #ym_voice $E2, $00, $00, $00
    #ym_operator $65, $18, $9E, $1B, $01, $37 ; M1
    #ym_operator $71, $14, $9E, $02, $02, $86 ; M2
    #ym_operator $17, $11, $DD, $16, $01, $32 ; C1
    #ym_operator $31, $00, $DA, $81, $01, $A5 ; C2
    #ym_scaling $00, $66                ; M1
    #ym_scaling $00, $F6                ; M2
    #ym_scaling $00, $F6                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $C8, $80, $01, $02
    #ym_noise $00, $07

; named by the patch, lfo or noise ops of snd_03_0, snd_05_6, snd_05_7
patch_26
    #ym_voice $FC, $00, $00, $00
    #ym_operator $03, $2B, $5F, $0F, $12, $54 ; M1
    #ym_operator $01, $25, $4B, $0D, $00, $17 ; M2
    #ym_operator $31, $00, $5F, $8C, $09, $34 ; C1
    #ym_operator $71, $04, $4A, $8D, $00, $17 ; C2
    #ym_scaling $00, $06                ; M1
    #ym_scaling $00, $06                ; M2
    #ym_scaling $00, $96                ; C1
    #ym_scaling $00, $03                ; C2
    #ym_lfo $C8, $00, $00, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0C_0, snd_0C_1, snd_0C_2, snd_0C_4
patch_27
    #ym_voice $F4, $00, $00, $00
    #ym_operator $72, $1A, $54, $05, $02, $22 ; M1
    #ym_operator $12, $24, $4C, $01, $00, $A3 ; M2
    #ym_operator $02, $01, $4C, $81, $00, $A6 ; C1
    #ym_operator $32, $00, $4C, $83, $00, $F7 ; C2
    #ym_scaling $00, $33                ; M1
    #ym_scaling $00, $21                ; M2
    #ym_scaling $00, $21                ; C1
    #ym_scaling $00, $05                ; C2
    #ym_lfo $CA, $BC, $03, $02
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_28
    #ym_voice $D0, $00, $00, $00
    #ym_operator $06, $2D, $DF, $05, $00, $F7 ; M1
    #ym_operator $00, $13, $1F, $07, $00, $F7 ; M2
    #ym_operator $05, $32, $9F, $07, $00, $F7 ; C1
    #ym_operator $01, $00, $5F, $86, $00, $F8 ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $F7                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_06_3, snd_06_5
patch_29
    #ym_voice $E0, $00, $00, $00
    #ym_operator $36, $1A, $DF, $07, $07, $29 ; M1
    #ym_operator $30, $14, $9F, $09, $06, $19 ; M2
    #ym_operator $35, $38, $DF, $06, $06, $19 ; C1
    #ym_operator $31, $00, $9F, $86, $08, $F9 ; C2
    #ym_scaling $00, $65                ; M1
    #ym_scaling $00, $45                ; M2
    #ym_scaling $00, $45                ; C1
    #ym_scaling $00, $04                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_06_4
patch_2A
    #ym_voice $F0, $00, $00, $01
    #ym_operator $30, $15, $9E, $0E, $08, $B6 ; M1
    #ym_operator $30, $15, $DC, $04, $08, $B6 ; M2
    #ym_operator $30, $3D, $D8, $0A, $08, $B6 ; C1
    #ym_operator $30, $00, $DC, $85, $08, $B6 ; C2
    #ym_scaling $00, $46                ; M1
    #ym_scaling $00, $46                ; M2
    #ym_scaling $00, $46                ; C1
    #ym_scaling $00, $03                ; C2
    #ym_lfo $C8, $80, $02, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_08_5, snd_09_4, snd_0A_6
patch_2B
    #ym_voice $FC, $00, $00, $00
    #ym_operator $0F, $08, $1F, $14, $04, $08 ; M1
    #ym_operator $01, $08, $1F, $18, $40, $F8 ; M2
    #ym_operator $00, $11, $1F, $90, $14, $AC ; C1
    #ym_operator $00, $00, $1F, $90, $14, $AC ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $C8, $FF, $00, $02
    #ym_noise $02, $00

; no patch, lfo or noise op names this record
patch_2C
    #ym_voice $C6, $00, $00, $00
    #ym_operator $00, $12, $1F, $0F, $0F, $0A ; M1
    #ym_operator $00, $00, $1F, $90, $40, $FA ; M2
    #ym_operator $20, $0C, $1F, $91, $00, $FA ; C1
    #ym_operator $00, $00, $1F, $90, $40, $FA ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $AF, $FF, $00, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_02_2, snd_02_3, snd_04_0, snd_04_1, snd_0B_0,
patch_2D
; snd_0B_1, snd_0B_2, snd_0B_3, snd_0B_4, snd_0B_5, unused_stream_04, unused_stream_06
    #ym_voice $FA, $00, $00, $00
    #ym_operator $32, $1E, $1F, $00, $00, $03 ; M1
    #ym_operator $72, $19, $1F, $00, $00, $03 ; M2
    #ym_operator $71, $19, $1F, $00, $00, $03 ; C1
    #ym_operator $01, $0A, $1F, $80, $01, $08 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $80, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_09
patch_2E
    #ym_voice $C1, $00, $00, $00
    #ym_operator $60, $12, $1F, $00, $00, $03 ; M1
    #ym_operator $71, $0A, $1F, $00, $00, $03 ; M2
    #ym_operator $21, $10, $1F, $00, $00, $03 ; C1
    #ym_operator $01, $00, $14, $80, $01, $07 ; C2
    #ym_scaling $00, $64                ; M1
    #ym_scaling $00, $84                ; M2
    #ym_scaling $00, $64                ; C1
    #ym_scaling $80, $20                ; C2
    #ym_lfo $D6, $CD, $00, $03
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_04_3
patch_2F
    #ym_voice $C1, $00, $00, $00
    #ym_operator $60, $12, $1F, $00, $00, $03 ; M1
    #ym_operator $71, $0A, $1F, $00, $00, $03 ; M2
    #ym_operator $21, $10, $1F, $00, $00, $03 ; C1
    #ym_operator $01, $00, $1E, $80, $01, $0A ; C2
    #ym_scaling $00, $64                ; M1
    #ym_scaling $00, $84                ; M2
    #ym_scaling $00, $64                ; C1
    #ym_scaling $80, $20                ; C2
    #ym_lfo $D6, $CD, $00, $03
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_10
patch_30
    #ym_voice $FB, $00, $00, $00
    #ym_operator $1D, $28, $0F, $13, $09, $06 ; M1
    #ym_operator $61, $0A, $1F, $06, $01, $26 ; M2
    #ym_operator $71, $10, $1E, $08, $01, $16 ; C1
    #ym_operator $53, $00, $1F, $87, $02, $2A ; C2
    #ym_scaling $80, $07                ; M1
    #ym_scaling $80, $47                ; M2
    #ym_scaling $80, $07                ; C1
    #ym_scaling $80, $20                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_31
    #ym_voice $DB, $00, $00, $00
    #ym_operator $72, $1F, $5F, $11, $07, $AA ; M1
    #ym_operator $70, $08, $1F, $06, $08, $39 ; M2
    #ym_operator $30, $08, $1F, $07, $06, $36 ; C1
    #ym_operator $22, $00, $11, $85, $06, $D6 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $80                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $BF, $EC, $01, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_02_0, snd_02_1, snd_04_2, snd_0E_0, snd_0E_3,
patch_32
; unused_stream_09
    #ym_voice $E1, $00, $00, $00
    #ym_operator $50, $12, $17, $04, $05, $CB ; M1
    #ym_operator $30, $0E, $16, $01, $04, $2D ; M2
    #ym_operator $3B, $32, $10, $09, $42, $A8 ; C1
    #ym_operator $34, $00, $16, $80, $00, $FA ; C2
    #ym_scaling $00, $56                ; M1
    #ym_scaling $00, $44                ; M2
    #ym_scaling $00, $25                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_3
patch_33
    #ym_voice $E5, $00, $00, $00
    #ym_operator $00, $08, $1F, $00, $1F, $BD ; M1
    #ym_operator $00, $00, $1F, $8A, $0A, $9F ; M2
    #ym_operator $04, $00, $5F, $8C, $0D, $BD ; C1
    #ym_operator $00, $00, $5F, $8A, $03, $8F ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $02                ; M2
    #ym_scaling $00, $04                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0D_0, snd_0D_1, snd_0D_2
patch_34
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

; named by the patch, lfo or noise ops of snd_06_2
patch_35
    #ym_voice $EC, $00, $00, $00
    #ym_operator $71, $16, $C7, $02, $01, $07 ; M1
    #ym_operator $53, $19, $83, $16, $88, $08 ; M2
    #ym_operator $31, $00, $4B, $82, $02, $06 ; C1
    #ym_operator $1C, $00, $86, $8C, $84, $0A ; C2
    #ym_scaling $00, $44                ; M1
    #ym_scaling $00, $83                ; M2
    #ym_scaling $00, $30                ; C1
    #ym_scaling $00, $40                ; C2
    #ym_lfo $AF, $80, $02, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_04_5, unused_stream_05, unused_stream_06,
patch_36
; unused_stream_07
    #ym_voice $FC, $00, $00, $00
    #ym_operator $79, $08, $1F, $00, $C0, $F0 ; M1
    #ym_operator $0F, $19, $1F, $00, $DF, $BF ; M2
    #ym_operator $07, $00, $1F, $93, $1B, $AF ; C1
    #ym_operator $7F, $0D, $1F, $93, $10, $2C ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $04                ; M2
    #ym_scaling $00, $05                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_37
    #ym_voice $FC, $00, $00, $00
    #ym_operator $7F, $08, $1F, $0D, $DF, $AF ; M1
    #ym_operator $7F, $08, $1F, $00, $DF, $BF ; M2
    #ym_operator $79, $00, $1F, $91, $D5, $5F ; C1
    #ym_operator $7E, $07, $9F, $93, $55, $0C ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_2, snd_01_3, snd_02_5, snd_0B_6, snd_0B_7,
patch_38
; snd_0E_2, snd_0E_3, snd_0E_4
    #ym_voice $DB, $00, $00, $00
    #ym_operator $06, $2A, $1F, $00, $00, $FF ; M1
    #ym_operator $03, $08, $1F, $14, $00, $FF ; M2
    #ym_operator $05, $08, $1F, $07, $C8, $87 ; C1
    #ym_operator $00, $00, $1F, $92, $C0, $FA ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_09
patch_39
    #ym_voice $D9, $00, $00, $00
    #ym_operator $70, $0F, $5B, $0B, $0A, $5B ; M1
    #ym_operator $30, $08, $16, $0C, $07, $1D ; M2
    #ym_operator $38, $13, $13, $15, $06, $18 ; C1
    #ym_operator $34, $00, $16, $80, $00, $FA ; C2
    #ym_scaling $00, $54                ; M1
    #ym_scaling $00, $44                ; M2
    #ym_scaling $00, $35                ; C1
    #ym_scaling $00, $06                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_09
patch_3A
    #ym_voice $D9, $00, $00, $00
    #ym_operator $70, $0F, $5B, $04, $05, $5B ; M1
    #ym_operator $30, $0E, $16, $01, $04, $0D ; M2
    #ym_operator $79, $17, $05, $05, $02, $18 ; C1
    #ym_operator $34, $00, $16, $80, $00, $FA ; C2
    #ym_scaling $00, $54                ; M1
    #ym_scaling $00, $44                ; M2
    #ym_scaling $00, $35                ; C1
    #ym_scaling $00, $06                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_11
patch_3B
    #ym_voice $C1, $00, $00, $00
    #ym_operator $21, $17, $12, $02, $00, $2C ; M1
    #ym_operator $11, $17, $12, $02, $00, $2C ; M2
    #ym_operator $31, $0D, $12, $03, $00, $2C ; C1
    #ym_operator $21, $05, $12, $83, $00, $2C ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $04                ; M2
    #ym_scaling $80, $64                ; C1
    #ym_scaling $80, $64                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_03_1
patch_3C
    #ym_voice $F4, $00, $00, $00
    #ym_operator $32, $23, $1F, $00, $00, $00 ; M1
    #ym_operator $72, $19, $1F, $00, $00, $00 ; M2
    #ym_operator $71, $00, $17, $80, $00, $0A ; C1
    #ym_operator $31, $00, $17, $80, $00, $0A ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $80, $37                ; C1
    #ym_scaling $80, $37                ; C2
    #ym_lfo $CB, $EE, $05, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_01_0, snd_01_1
patch_3D
    #ym_voice $F4, $00, $00, $00
    #ym_operator $32, $1B, $1F, $00, $00, $00 ; M1
    #ym_operator $72, $19, $1F, $00, $00, $00 ; M2
    #ym_operator $31, $00, $17, $80, $00, $0A ; C1
    #ym_operator $D1, $00, $17, $80, $00, $0A ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $80, $37                ; C1
    #ym_scaling $80, $30                ; C2
    #ym_lfo $CB, $EE, $05, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_06_1
patch_3E
    #ym_voice $C2, $00, $00, $00
    #ym_operator $31, $19, $0E, $06, $00, $35 ; M1
    #ym_operator $71, $2D, $4F, $08, $00, $55 ; M2
    #ym_operator $3F, $28, $18, $03, $C0, $75 ; C1
    #ym_operator $74, $00, $0D, $83, $00, $28 ; C2
    #ym_scaling $00, $F2                ; M1
    #ym_scaling $00, $73                ; M2
    #ym_scaling $00, $F3                ; C1
    #ym_scaling $00, $64                ; C2
    #ym_lfo $CD, $B9, $03, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0C_7
patch_3F
    #ym_voice $E5, $00, $00, $00
    #ym_operator $71, $0F, $8E, $0A, $00, $15 ; M1
    #ym_operator $00, $02, $50, $8B, $00, $05 ; M2
    #ym_operator $2C, $07, $4A, $86, $13, $AF ; C1
    #ym_operator $11, $00, $4E, $83, $00, $28 ; C2
    #ym_scaling $00, $32                ; M1
    #ym_scaling $00, $03                ; M2
    #ym_scaling $80, $23                ; C1
    #ym_scaling $80, $04                ; C2
    #ym_lfo $C8, $9E, $03, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0A_7, snd_0B_0, snd_0B_1, snd_0D_7
patch_40
    #ym_voice $FC, $00, $00, $00
    #ym_operator $32, $1C, $1F, $07, $00, $12 ; M1
    #ym_operator $71, $13, $1F, $07, $00, $13 ; M2
    #ym_operator $32, $00, $0B, $9F, $00, $05 ; C1
    #ym_operator $02, $00, $0B, $9F, $00, $05 ; C2
    #ym_scaling $00, $03                ; M1
    #ym_scaling $00, $23                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $17                ; C2
    #ym_lfo $C9, $A8, $00, $02
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_41
    #ym_voice $EC, $00, $00, $00
    #ym_operator $73, $1E, $DC, $02, $00, $07 ; M1
    #ym_operator $51, $0D, $9C, $02, $05, $08 ; M2
    #ym_operator $33, $00, $5D, $82, $03, $04 ; C1
    #ym_operator $11, $00, $9F, $82, $02, $06 ; C2
    #ym_scaling $00, $44                ; M1
    #ym_scaling $00, $83                ; M2
    #ym_scaling $00, $30                ; C1
    #ym_scaling $00, $40                ; C2
    #ym_lfo $AF, $80, $02, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_08_0, snd_08_3, snd_0A_1
patch_42
    #ym_voice $FE, $00, $00, $00
    #ym_operator $01, $29, $1F, $0A, $0F, $59 ; M1
    #ym_operator $01, $06, $14, $8B, $00, $19 ; M2
    #ym_operator $01, $0B, $14, $86, $00, $F9 ; C1
    #ym_operator $01, $04, $14, $8B, $00, $19 ; C2
    #ym_scaling $00, $47                ; M1
    #ym_scaling $00, $67                ; M2
    #ym_scaling $00, $27                ; C1
    #ym_scaling $00, $67                ; C2
    #ym_lfo $CD, $9D, $04, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_05_0
patch_43
    #ym_voice $C4, $00, $00, $00
    #ym_operator $04, $23, $55, $0C, $07, $14 ; M1
    #ym_operator $05, $1E, $45, $0E, $05, $05 ; M2
    #ym_operator $31, $00, $54, $9F, $06, $04 ; C1
    #ym_operator $71, $00, $48, $8D, $05, $15 ; C2
    #ym_scaling $00, $06                ; M1
    #ym_scaling $00, $06                ; M2
    #ym_scaling $00, $96                ; C1
    #ym_scaling $00, $03                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_05_1
patch_44
    #ym_voice $C4, $00, $00, $00
    #ym_operator $04, $23, $55, $0C, $07, $14 ; M1
    #ym_operator $06, $2D, $45, $0E, $05, $05 ; M2
    #ym_operator $31, $00, $54, $9F, $06, $04 ; C1
    #ym_operator $71, $00, $48, $8D, $05, $15 ; C2
    #ym_scaling $00, $06                ; M1
    #ym_scaling $00, $06                ; M2
    #ym_scaling $00, $96                ; C1
    #ym_scaling $00, $03                ; C2
    #ym_lfo $00, $80, $00, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_05, unused_stream_07, unused_stream_12
patch_45
    #ym_voice $C0, $00, $00, $00
    #ym_operator $01, $24, $0C, $08, $C0, $F8 ; M1
    #ym_operator $00, $14, $11, $00, $00, $08 ; M2
    #ym_operator $03, $1E, $0F, $07, $40, $F8 ; C1
    #ym_operator $00, $00, $17, $80, $00, $09 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_0, snd_01_2, snd_02_4, snd_04_2, snd_08_0,
patch_46
; snd_09_4, snd_0A_5, snd_0B_0, snd_0B_1, snd_0B_5, snd_0B_7, snd_0E_3
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

; named by the patch, lfo or noise ops of snd_02_6
patch_47
    #ym_voice $E0, $00, $00, $00
    #ym_operator $36, $1A, $DF, $07, $07, $29 ; M1
    #ym_operator $30, $14, $9F, $09, $06, $19 ; M2
    #ym_operator $35, $38, $DF, $06, $06, $19 ; C1
    #ym_operator $31, $04, $9F, $87, $0D, $F9 ; C2
    #ym_scaling $00, $64                ; M1
    #ym_scaling $00, $44                ; M2
    #ym_scaling $00, $44                ; C1
    #ym_scaling $00, $04                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_08_0, snd_08_1, snd_08_2, snd_0A_0, snd_0A_2,
patch_48
; snd_0A_3, snd_0D_2, snd_0D_3
    #ym_voice $F4, $00, $00, $00
    #ym_operator $01, $1E, $10, $01, $00, $18 ; M1
    #ym_operator $01, $1E, $10, $01, $00, $18 ; M2
    #ym_operator $01, $01, $10, $82, $00, $18 ; C1
    #ym_operator $01, $01, $10, $82, $00, $18 ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $04                ; M2
    #ym_scaling $80, $24                ; C1
    #ym_scaling $80, $24                ; C2
    #ym_lfo $00, $80, $00, $02
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_49
    #ym_voice $C4, $00, $00, $00
    #ym_operator $01, $19, $1E, $08, $05, $0A ; M1
    #ym_operator $01, $19, $1E, $0B, $05, $0A ; M2
    #ym_operator $01, $04, $1D, $88, $06, $0F ; C1
    #ym_operator $01, $04, $1D, $8B, $06, $0F ; C2
    #ym_scaling $00, $04                ; M1
    #ym_scaling $00, $04                ; M2
    #ym_scaling $80, $24                ; C1
    #ym_scaling $80, $24                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_0, snd_01_1, snd_01_2, snd_03_0, snd_03_1,
patch_4A
; unused_stream_03, unused_stream_04, unused_stream_05, unused_stream_06, unused_stream_07
    #ym_voice $FA, $00, $00, $00
    #ym_operator $34, $22, $1F, $00, $00, $03 ; M1
    #ym_operator $72, $14, $1F, $00, $00, $03 ; M2
    #ym_operator $72, $19, $1F, $00, $00, $03 ; C1
    #ym_operator $01, $0A, $1F, $80, $01, $08 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $80, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_4B
    #ym_voice $E8, $00, $00, $00
    #ym_operator $3F, $12, $DF, $1F, $07, $00 ; M1
    #ym_operator $31, $14, $9F, $00, $06, $1F ; M2
    #ym_operator $31, $38, $DF, $00, $00, $09 ; C1
    #ym_operator $31, $00, $9F, $86, $06, $FF ; C2
    #ym_scaling $80, $05                ; M1
    #ym_scaling $00, $45                ; M2
    #ym_scaling $00, $05                ; C1
    #ym_scaling $00, $04                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_03_4
patch_4C
    #ym_voice $FD, $00, $00, $00
    #ym_operator $01, $1C, $9F, $0A, $00, $13 ; M1
    #ym_operator $02, $0D, $9F, $8C, $00, $18 ; M2
    #ym_operator $02, $0D, $1F, $8C, $00, $18 ; C1
    #ym_operator $02, $0D, $1F, $8C, $00, $18 ; C2
    #ym_scaling $00, $02                ; M1
    #ym_scaling $00, $07                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_10
patch_4D
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

; no patch, lfo or noise op names this record
patch_4E
    #ym_voice $C2, $00, $00, $31
    #ym_operator $37, $1E, $9F, $06, $02, $01 ; M1
    #ym_operator $21, $1F, $9F, $0C, $02, $01 ; M2
    #ym_operator $39, $23, $9F, $06, $02, $01 ; C1
    #ym_operator $31, $00, $9F, $80, $00, $0B ; C2
    #ym_scaling $00, $43                ; M1
    #ym_scaling $00, $42                ; M2
    #ym_scaling $00, $43                ; C1
    #ym_scaling $00, $40                ; C2
    #ym_lfo $C8, $8A, $03, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_02_5, snd_04_4, snd_0B_6, snd_0B_7, snd_0C_6
patch_4F
    #ym_voice $FC, $00, $00, $00
    #ym_operator $03, $0C, $1F, $00, $00, $08 ; M1
    #ym_operator $01, $1C, $1F, $14, $13, $0F ; M2
    #ym_operator $70, $00, $1F, $90, $11, $0D ; C1
    #ym_operator $00, $01, $1F, $90, $11, $0D ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $05                ; C1
    #ym_scaling $00, $05                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_4, snd_0E_3, snd_0E_4
patch_50
    #ym_voice $FC, $00, $00, $00
    #ym_operator $7F, $08, $1F, $05, $C5, $F8 ; M1
    #ym_operator $70, $0D, $5F, $17, $C7, $BC ; M2
    #ym_operator $3F, $07, $1F, $8F, $CE, $7F ; C1
    #ym_operator $00, $00, $1F, $91, $0B, $BC ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $A0                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_09_4, snd_0E_0
patch_51
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

; named by the patch, lfo or noise ops of snd_0A_0, snd_0A_1
patch_52
    #ym_voice $EA, $00, $00, $00
    #ym_operator $10, $0F, $5C, $07, $00, $13 ; M1
    #ym_operator $65, $23, $5C, $07, $00, $13 ; M2
    #ym_operator $75, $1E, $53, $09, $00, $32 ; C1
    #ym_operator $01, $00, $4D, $84, $00, $07 ; C2
    #ym_scaling $00, $27                ; M1
    #ym_scaling $00, $87                ; M2
    #ym_scaling $00, $C0                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $CA, $BC, $03, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_0D_5, snd_0D_6
patch_53
    #ym_voice $FC, $00, $00, $00
    #ym_operator $31, $20, $1F, $09, $00, $07 ; M1
    #ym_operator $73, $19, $1F, $09, $00, $36 ; M2
    #ym_operator $33, $03, $0D, $9F, $00, $07 ; C1
    #ym_operator $71, $03, $0D, $9F, $00, $06 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $80                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $CD, $FF, $00, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_0D_0, snd_0D_1, snd_0D_2, snd_0D_3, snd_0D_4
patch_54
    #ym_voice $FC, $00, $00, $00
    #ym_operator $31, $1D, $1F, $0A, $00, $16 ; M1
    #ym_operator $73, $19, $1F, $09, $00, $26 ; M2
    #ym_operator $33, $03, $0C, $9F, $00, $06 ; C1
    #ym_operator $71, $03, $0C, $9F, $00, $06 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $80                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $CD, $FF, $00, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_03_2, snd_03_3, snd_05_2, snd_05_3, snd_05_4
patch_55
    #ym_voice $FC, $00, $00, $00
    #ym_operator $72, $1D, $1F, $07, $00, $15 ; M1
    #ym_operator $33, $14, $1F, $07, $00, $15 ; M2
    #ym_operator $72, $00, $0C, $9F, $00, $05 ; C1
    #ym_operator $33, $00, $0C, $9F, $00, $05 ; C2
    #ym_scaling $00, $02                ; M1
    #ym_scaling $00, $22                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $17                ; C2
    #ym_lfo $C9, $A8, $00, $02
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_56
    #ym_voice $EC, $00, $00, $00
    #ym_operator $72, $0F, $1F, $07, $00, $05 ; M1
    #ym_operator $36, $10, $1F, $07, $00, $05 ; M2
    #ym_operator $72, $00, $0C, $9F, $00, $05 ; C1
    #ym_operator $33, $00, $0C, $9F, $00, $05 ; C2
    #ym_scaling $00, $02                ; M1
    #ym_scaling $00, $22                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $17                ; C2
    #ym_lfo $C9, $A8, $00, $02
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_57
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

; named by the patch, lfo or noise ops of snd_05_5
patch_58
    #ym_voice $F9, $00, $00, $00
    #ym_operator $02, $16, $5F, $0C, $00, $F4 ; M1
    #ym_operator $02, $1F, $1F, $06, $03, $15 ; M2
    #ym_operator $01, $23, $5F, $0D, $04, $15 ; C1
    #ym_operator $01, $05, $9F, $8C, $04, $13 ; C2
    #ym_scaling $00, $C6                ; M1
    #ym_scaling $00, $A6                ; M2
    #ym_scaling $00, $46                ; C1
    #ym_scaling $00, $43                ; C2
    #ym_lfo $C8, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_1, snd_09_4, snd_0B_0, snd_0B_1, snd_0B_6,
patch_59
; snd_0B_7, snd_0E_1, unused_stream_05, unused_stream_06
    #ym_voice $DC, $00, $00, $00
    #ym_operator $72, $08, $1F, $07, $00, $18 ; M1
    #ym_operator $33, $0B, $1F, $07, $00, $18 ; M2
    #ym_operator $72, $00, $16, $9F, $00, $08 ; C1
    #ym_operator $33, $00, $16, $9F, $00, $08 ; C2
    #ym_scaling $00, $02                ; M1
    #ym_scaling $00, $22                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $17                ; C2
    #ym_lfo $C9, $A8, $00, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_02_5, snd_04_4, snd_0B_6, snd_0B_7
patch_5A
    #ym_voice $C4, $00, $00, $00
    #ym_operator $00, $7F, $1C, $1F, $1F, $BF ; M1
    #ym_operator $01, $08, $1C, $1F, $5F, $BF ; M2
    #ym_operator $70, $00, $1F, $8E, $0D, $27 ; C1
    #ym_operator $00, $00, $1F, $8E, $0D, $26 ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $00                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_01_4, snd_0E_4
patch_5B
    #ym_voice $FC, $00, $00, $00
    #ym_operator $06, $7F, $1F, $00, $00, $06 ; M1
    #ym_operator $01, $08, $1C, $1F, $5F, $BF ; M2
    #ym_operator $01, $00, $17, $8F, $11, $2C ; C1
    #ym_operator $00, $00, $1F, $93, $10, $2C ; C2
    #ym_scaling $00, $00                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $07                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; no patch, lfo or noise op names this record
patch_5C
    #ym_voice $FD, $00, $00, $00
    #ym_operator $01, $1D, $10, $07, $01, $24 ; M1
    #ym_operator $02, $0C, $50, $88, $00, $18 ; M2
    #ym_operator $02, $0C, $50, $88, $00, $18 ; C1
    #ym_operator $02, $0C, $50, $88, $00, $18 ; C2
    #ym_scaling $00, $03                ; M1
    #ym_scaling $00, $47                ; M2
    #ym_scaling $00, $27                ; C1
    #ym_scaling $00, $47                ; C2
    #ym_lfo $C6, $E4, $05, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_08_0, snd_08_1, snd_08_2, snd_08_3, snd_08_5
patch_5D
    #ym_voice $FA, $00, $00, $00
    #ym_operator $01, $19, $8E, $0E, $00, $13 ; M1
    #ym_operator $01, $28, $8D, $0E, $00, $13 ; M2
    #ym_operator $07, $29, $8E, $0E, $40, $FA ; C1
    #ym_operator $01, $00, $53, $83, $00, $0A ; C2
    #ym_scaling $00, $12                ; M1
    #ym_scaling $00, $03                ; M2
    #ym_scaling $00, $83                ; C1
    #ym_scaling $00, $05                ; C2
    #ym_lfo $C8, $BC, $05, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_08_2, snd_08_3, snd_08_4, snd_08_6, snd_0B_4,
patch_5E
; snd_0C_3, snd_0D_4, snd_0D_5
    #ym_voice $FD, $00, $00, $00
    #ym_operator $01, $1C, $8D, $07, $00, $14 ; M1
    #ym_operator $01, $06, $14, $8E, $00, $18 ; M2
    #ym_operator $02, $06, $52, $88, $00, $18 ; C1
    #ym_operator $01, $06, $55, $83, $00, $1A ; C2
    #ym_scaling $80, $02                ; M1
    #ym_scaling $00, $47                ; M2
    #ym_scaling $00, $47                ; C1
    #ym_scaling $80, $27                ; C2
    #ym_lfo $C6, $A8, $03, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_0A_2, snd_0A_3, snd_0B_0, snd_0B_1, snd_0B_2,
patch_5F
; snd_0B_3, snd_0B_7, snd_0C_0, snd_0C_1, snd_0C_2, snd_0C_4, snd_0C_5, snd_0D_0, snd_0D_1
    #ym_voice $FD, $00, $00, $00
    #ym_operator $01, $1C, $8E, $08, $00, $14 ; M1
    #ym_operator $01, $02, $14, $8E, $00, $18 ; M2
    #ym_operator $01, $02, $52, $88, $00, $18 ; C1
    #ym_operator $01, $09, $4C, $83, $00, $1A ; C2
    #ym_scaling $80, $03                ; M1
    #ym_scaling $00, $47                ; M2
    #ym_scaling $00, $47                ; C1
    #ym_scaling $80, $27                ; C2
    #ym_lfo $C8, $8A, $05, $02
    #ym_noise $02, $00

; named by the patch, lfo or noise ops of snd_0B_0, snd_0B_1
patch_60
    #ym_voice $F2, $00, $00, $00
    #ym_operator $01, $11, $8E, $0E, $00, $13 ; M1
    #ym_operator $01, $28, $8D, $0E, $00, $13 ; M2
    #ym_operator $07, $28, $8E, $0E, $80, $FA ; C1
    #ym_operator $01, $00, $53, $83, $00, $0A ; C2
    #ym_scaling $00, $12                ; M1
    #ym_scaling $00, $03                ; M2
    #ym_scaling $00, $83                ; C1
    #ym_scaling $00, $05                ; C2
    #ym_lfo $C5, $BC, $05, $02
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of snd_08_7, snd_0A_4, snd_0A_5, snd_0C_4, snd_0C_5,
patch_61
; snd_0D_7
    #ym_voice $FD, $00, $00, $00
    #ym_operator $00, $1A, $0F, $08, $00, $14 ; M1
    #ym_operator $01, $00, $12, $8E, $00, $28 ; M2
    #ym_operator $01, $00, $12, $88, $00, $18 ; C1
    #ym_operator $01, $00, $14, $83, $00, $18 ; C2
    #ym_scaling $80, $22                ; M1
    #ym_scaling $00, $47                ; M2
    #ym_scaling $00, $47                ; C1
    #ym_scaling $00, $47                ; C2
    #ym_lfo $C6, $9E, $03, $02
    #ym_noise $02, $00

; no patch, lfo or noise op names this record
patch_62
    #ym_voice $DD, $00, $00, $00
    #ym_operator $01, $25, $1E, $0A, $14, $FA ; M1
    #ym_operator $01, $00, $1F, $8A, $16, $1A ; M2
    #ym_operator $03, $00, $1E, $8A, $18, $1A ; C1
    #ym_operator $01, $00, $1E, $8A, $19, $1A ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_03, unused_stream_04, unused_stream_06,
patch_63
; unused_stream_07
    #ym_voice $ED, $00, $00, $00
    #ym_operator $01, $25, $1E, $0A, $14, $FA ; M1
    #ym_operator $01, $07, $1F, $8A, $16, $1A ; M2
    #ym_operator $03, $07, $1E, $8A, $18, $1A ; C1
    #ym_operator $01, $07, $1E, $8A, $19, $1A ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

; named by the patch, lfo or noise ops of unused_stream_03, unused_stream_04
patch_64
    #ym_voice $DD, $00, $00, $00
    #ym_operator $01, $25, $1E, $00, $00, $1A ; M1
    #ym_operator $01, $00, $1F, $80, $00, $0A ; M2
    #ym_operator $03, $00, $1E, $80, $00, $0A ; C1
    #ym_operator $01, $00, $1E, $86, $00, $0A ; C2
    #ym_scaling $00, $07                ; M1
    #ym_scaling $00, $00                ; M2
    #ym_scaling $00, $07                ; C1
    #ym_scaling $00, $00                ; C2
    #ym_lfo $00, $80, $00, $00
    #ym_noise $00, $00

    .cerror * != $AB48, "patches_2.asm must end at $AB47"
