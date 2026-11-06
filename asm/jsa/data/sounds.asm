; sounds.asm: 61E4-65E5, the sound tables: what a sound command starts, and the OKI effects.
;
; A command of type 08 (cmdtype_08, 4569) starts sound N, its parameter (00-1F; the commands
; are in docs/12-sound-music.md section 6). sound_first_entry gives N's first entry E and
; entry_next each next one up to 0: every entry is one track (one byte stream) that cmdtype_08
; starts on a free track slot (or on the slot of the track it may take over, 459F-45E8) with
; the priority entry_priority, on the YM2151 channel entry_channel, from the stream
; entry_stream (the labels of the stream files: snd_NN_V is track V of sound N). The four
; entry tables are parallel arrays indexed by E through (zp_15),y with the base as immediates
; (45AB-468E), so their lengths are the 125 entries the chains use and they end where the next
; one starts. cmdtype_13 (5BFE, the OKI start) indexes the three 53-entry effect tables with its
; parameter (00-34; 5C43 ORs 80 into effect_phrase for the OKI's first command byte) and keeps
; the effect in zp_52,x for the channel. cmdtype_14 (5C6F) does not index with its parameter:
; it compares it with effect_phrase of each channel's current effect (zp_52,x, 5C73-5C76) and
; stops the channel that matches (docs/10-adpcm.md section 4). cmdtype_01 (commands 1E-23,
; parameters 00-05) and cmdtype_02 (no command) set a global variable of the stream ops from
; global_set_index and global_set_value.

    .cerror * != $61E4, "sounds.asm must start at $61E4"

; 32 words: the first entry E of sound N, read at 4570 and 457C (X = N x 2; an N from 80 up
; would read past the table as tbl+$100, 4575/4581, but no parameter reaches 80).
sound_first_entry
    .word $0000, $0008, $000D, $0014, $0019, $001F, $0027, $002E ; 00-07
    .word $0034, $003C, $0041, $0049, $0051, $0059, $0061, $0066 ; 08-0F
    .word $006A, $006B, $006C, $006D, $006E, $006F, $0070, $0071 ; 10-17
    .word $0072, $0075, $0076, $0078, $0079, $007A, $007B, $007C ; 18-1F

; 32 bytes: read at 4586 with Y = N. Zero: cmdtype_08 does not start N while a track still
; plays it (458B-459D); nonzero: it starts N again. Every sound here has FF.
sound_restartable
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 00-0F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 10-1F

; 125 bytes, one per entry E: the track's priority, read through (zp_15),y at 45B8 and 45FF
; (base #<entry_priority + E, 45A9-45B6, 45F0-45FD). The track keeps priority x 4 + 1 in
; ram_03EC (4600-4604); a new track takes over a busy channel's slot only with a priority at
; least as high (45D8-45DC), an equal priority replaces the track (465A-4668), and the YM2151
; keys on only when the sounding track's priority x 4 + 1 reaches zp_1E (4EE3-4EE8).
entry_priority
    .byte $03, $03, $03, $03, $03, $03, $03, $03, $27, $27, $27, $27, $27, $29, $29, $29 ; 00-0F
    .byte $29, $29, $29, $29, $29, $29, $29, $29, $29, $28, $28, $28, $28, $28, $28, $2A ; 10-1F
    .byte $2A, $2A, $2A, $2A, $2A, $2A, $2A, $28, $28, $28, $28, $28, $28, $28, $28, $28 ; 20-2F
    .byte $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $37, $37, $37, $37 ; 30-3F
    .byte $37, $29, $29, $29, $29, $29, $29, $29, $29, $28, $28, $28, $28, $28, $28, $28 ; 40-4F
    .byte $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28 ; 50-5F
    .byte $28, $28, $28, $28, $28, $28, $19, $19, $19, $19, $32, $32, $32, $32, $32, $32 ; 60-6F
    .byte $32, $32, $32, $32, $32, $32, $32, $32, $3F, $32, $32, $32, $32 ; 70-7C

; 125 bytes, one per entry E: the YM2151 channel 0-7, read through (zp_15),y at 45C9 and 4614
; (base #<entry_channel + E): the track joins the list headed at ram_0860+1E+channel (4617).
entry_channel
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $07, $06, $05, $04, $03, $07, $06, $05 ; 00-0F
    .byte $04, $03, $02, $01, $07, $06, $05, $04, $03, $00, $01, $02, $03, $05, $06, $00 ; 10-1F
    .byte $01, $02, $03, $04, $05, $06, $07, $02, $03, $01, $04, $05, $06, $07, $00, $01 ; 20-2F
    .byte $02, $03, $05, $06, $00, $01, $02, $03, $04, $05, $06, $07, $04, $05, $06, $07 ; 30-3F
    .byte $02, $00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06 ; 40-4F
    .byte $07, $00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06 ; 50-5F
    .byte $07, $03, $04, $05, $06, $07, $00, $03, $01, $02, $04, $01, $05, $05, $00, $04 ; 60-6F
    .byte $00, $07, $05, $04, $06, $05, $05, $05, $03, $05, $04, $05, $07 ; 70-7C

; 125 words, one per entry E: the stream, read at 4632 and 4638 through (zp_15),y (base
; #<entry_stream + E x 2, 461B-4630) into the track's stream pointer ram_0266/ram_0284. Entries
; 2E-33 (sound 07) start the same six streams as 19-1E (sound 04).
entry_stream
    .word snd_00_0, snd_00_1, snd_00_2, snd_00_3       ; 00-03
    .word snd_00_4, snd_00_5, snd_00_6, snd_00_7       ; 04-07
    .word snd_01_0, snd_01_1, snd_01_2, snd_01_3       ; 08-0B
    .word snd_01_4, snd_02_0, snd_02_1, snd_02_2       ; 0C-0F
    .word snd_02_3, snd_02_4, snd_02_5, snd_02_6       ; 10-13
    .word snd_03_0, snd_03_1, snd_03_2, snd_03_3       ; 14-17
    .word snd_03_4, snd_04_0, snd_04_1, snd_04_2       ; 18-1B
    .word snd_04_3, snd_04_4, snd_04_5, snd_05_0       ; 1C-1F
    .word snd_05_1, snd_05_2, snd_05_3, snd_05_4       ; 20-23
    .word snd_05_5, snd_05_6, snd_05_7, snd_06_0       ; 24-27
    .word snd_06_1, snd_06_2, snd_06_3, snd_06_4       ; 28-2B
    .word snd_06_5, snd_06_6, snd_04_0, snd_04_1       ; 2C-2F
    .word snd_04_2, snd_04_3, snd_04_4, snd_04_5       ; 30-33
    .word snd_08_0, snd_08_1, snd_08_2, snd_08_3       ; 34-37
    .word snd_08_4, snd_08_5, snd_08_6, snd_08_7       ; 38-3B
    .word snd_09_0, snd_09_1, snd_09_2, snd_09_3       ; 3C-3F
    .word snd_09_4, snd_0A_0, snd_0A_1, snd_0A_2       ; 40-43
    .word snd_0A_3, snd_0A_4, snd_0A_5, snd_0A_6       ; 44-47
    .word snd_0A_7, snd_0B_0, snd_0B_1, snd_0B_2       ; 48-4B
    .word snd_0B_3, snd_0B_4, snd_0B_5, snd_0B_6       ; 4C-4F
    .word snd_0B_7, snd_0C_0, snd_0C_1, snd_0C_2       ; 50-53
    .word snd_0C_3, snd_0C_4, snd_0C_5, snd_0C_6       ; 54-57
    .word snd_0C_7, snd_0D_0, snd_0D_1, snd_0D_2       ; 58-5B
    .word snd_0D_3, snd_0D_4, snd_0D_5, snd_0D_6       ; 5C-5F
    .word snd_0D_7, snd_0E_0, snd_0E_1, snd_0E_2       ; 60-63
    .word snd_0E_3, snd_0E_4, snd_0F_0, snd_0F_1       ; 64-67
    .word snd_0F_2, snd_0F_3, snd_10_0, snd_11_0       ; 68-6B
    .word snd_12_0, snd_13_0, snd_14_0, snd_15_0       ; 6C-6F
    .word snd_16_0, snd_17_0, snd_18_0, snd_18_1       ; 70-73
    .word snd_18_2, snd_19_0, snd_1A_0, snd_1A_1       ; 74-77
    .word snd_1B_0, snd_1C_0, snd_1D_0, snd_1E_0       ; 78-7B
    .word snd_1F_0                                     ; 7C-7C

; 125 words, one per entry E: the next entry of the sound, 0 for the last; read at 4694-469D
; through (zp_15),y (base #<entry_next + E x 2, 467B-4692). Entry 0 is never a next entry, so
; 0 can end the chain.
entry_next
    .word $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0000 ; 00-07
    .word $0009, $000A, $000B, $000C, $0000, $000E, $000F, $0010 ; 08-0F
    .word $0011, $0012, $0013, $0000, $0015, $0016, $0017, $0018 ; 10-17
    .word $0000, $001A, $001B, $001C, $001D, $001E, $0000, $0020 ; 18-1F
    .word $0021, $0022, $0023, $0024, $0025, $0026, $0000, $0028 ; 20-27
    .word $0029, $002A, $002B, $002C, $002D, $0000, $002F, $0030 ; 28-2F
    .word $0031, $0032, $0033, $0000, $0035, $0036, $0037, $0038 ; 30-37
    .word $0039, $003A, $003B, $0000, $003D, $003E, $003F, $0040 ; 38-3F
    .word $0000, $0042, $0043, $0044, $0045, $0046, $0047, $0048 ; 40-47
    .word $0000, $004A, $004B, $004C, $004D, $004E, $004F, $0050 ; 48-4F
    .word $0000, $0052, $0053, $0054, $0055, $0056, $0057, $0058 ; 50-57
    .word $0000, $005A, $005B, $005C, $005D, $005E, $005F, $0060 ; 58-5F
    .word $0000, $0062, $0063, $0064, $0065, $0000, $0067, $0068 ; 60-67
    .word $0069, $0000, $0000, $0000, $0000, $0000, $0000, $0000 ; 68-6F
    .word $0000, $0000, $0073, $0074, $0000, $0000, $0077, $0000 ; 70-77
    .word $0000, $0000, $0000, $0000, $0000 ; 78-7C

; 53 bytes, one per OKI effect: the phrase, read at 5C43 (ORed with 80: the OKI's first
; command byte) and 5C75 with Y = the effect.
effect_phrase
    .byte $01, $01, $02, $03, $04, $05, $06, $07, $08, $20, $22, $21, $23, $09, $0A, $0B ; 00-0F
    .byte $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B ; 10-1F
    .byte $1C, $1D, $1E, $1F, $24, $25, $29, $26, $33, $2E, $28, $2C, $2F, $2D, $30, $27 ; 20-2F
    .byte $2A, $32, $31, $34, $2B       ; 30-34

; 53 bytes, one per effect: read at 5C08, 5C1E and 5C4B (bits 5-4: the OKI channel, 3-0 the
; attenuation in the second OKI byte; bit 7, tested at 5C1E-5C20 on the effect playing on the
; channel: set, a new start does not interrupt it).
effect_voice
    .byte $01, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $00, $80, $80 ; 00-0F
    .byte $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80 ; 10-1F
    .byte $80, $80, $80, $80, $00, $00, $10, $11, $12, $10, $20, $21, $20, $20, $20, $31 ; 20-2F
    .byte $30, $30, $31, $30, $31       ; 30-34

; 53 bytes, one per effect: read at 5C56 into zp_5E,x, the channel's level, from which
; sub_5C87 lowers the YM2151 volume in MIX while the effect plays (docs/10-adpcm.md section 4).
effect_duck
    .byte $00, $06, $06, $06, $06, $06, $06, $06, $06, $08, $08, $08, $08, $04, $04, $04 ; 00-0F
    .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04 ; 10-1F
    .byte $04, $04, $04, $04, $08, $07, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00 ; 20-2F
    .byte $00, $00, $00, $00, $00       ; 30-34

; 6 bytes: read at 43AE and 43BB with Y = the parameter 00-05: AND 1F, the global variable
; (zp_23+n, the stream ops' registers R_GLOBAL+n) cmdtype_01 sets or cmdtype_02 adds to.
global_set_index
    .byte $00, $00, $00, $00, $00, $00

; 6 bytes: the value cmdtype_01 stores (43B4) or cmdtype_02 adds (43C1). With these tables
; commands 1E-23 set global 0 to 0-5 (var_load R_GLOBAL+0 reads it).
global_set_value
    .byte $00, $01, $02, $03, $04, $05

; Role unknown (docs/12-sound-music.md section 7): 9 bytes up to the first stream (snd_0F_0);
; read at 44C5 (Y: cmdtype_10), 44ED-451B (X: cmdtype_0D) and 58AB-590F (X = zp_4E and zp_4E x
; 2: a word at 590A/590F becomes the pointer zp_49 of ymtimer.asm). No command has type 0D or
; 10, none of these was executed in the make sndtrace runs and no index is bounded, so the
; extent is the space left.
tbl_65DD
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00

    .cerror * != $65E6, "sounds.asm must end at $65E5"
