; sounds.asm: 61E4-65E5, the tables the command handlers index with their parameter.
;
; cmdtype_08 (4569, the commands of type 08) takes a number N in A, the command's parameter (00-1F).
; tbl_61E4 gives a first entry E (an N from 80 up would read its second half, tbl_61E4+$100 on, as
; words, 4575/4581, but no parameter reaches 80), and E, then each next entry tbl_6438 gives until
; 0, indexes four 125-entry tables: tbl_6244 and tbl_62C1 (bytes) and tbl_633E, whose words are the
; addresses of byte streams in data/music.asm, copied to ram_0266/ram_0284 (4632-463A), the pointer
; the stream reader at 4859 reads through zp_06 (4781-4786, 4864-486C). The 125 entries end where
; the next table starts: tbl_6244 + 7D = tbl_62C1, + 7D = tbl_633E, + FA = tbl_6438, + FA =
; tbl_6532. cmdtype_13 (5BFE, the OKI start) indexes the three 53-entry tables tbl_6532, tbl_6567
; and tbl_659C with its parameter (00-34; 5C43 ORs 80 into tbl_6532's byte for the OKI's first
; command byte) and keeps the entry in zp_52,x for the channel. cmdtype_14 (5C6F) does not index
; with its parameter: it compares it with tbl_6532 of each channel's current entry (zp_52,x,
; 5C73-5C76) and stops the channel that matches. cmdtype_01 (commands 1E-23, parameters 00-05) and
; cmdtype_02 (no command) index tbl_65D1 and tbl_65D7. What N, E and the bytes mean for the sound is
; for a later leg.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on.

    .cerror * != $61E4, "sounds.asm must start at $61E4"

; 32 words: read at 4570 and 457C (X = N x 2); the first entry E of N.
tbl_61E4
    .word $0000, $0008, $000D, $0014, $0019, $001F, $0027, $002E ; 00-07
    .word $0034, $003C, $0041, $0049, $0051, $0059, $0061, $0066 ; 08-0F
    .word $006A, $006B, $006C, $006D, $006E, $006F, $0070, $0071 ; 10-17
    .word $0072, $0075, $0076, $0078, $0079, $007A, $007B, $007C ; 18-1F

; 32 bytes: read at 4586 with Y = N.
tbl_6224
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 00-0F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 10-1F

; 125 bytes, one per entry E: read through (zp_15),y at 45B8 and 45FF (base #<tbl_6244 +
; E, 45A9-45B6, 45F0-45FD).
tbl_6244
    .byte $03, $03, $03, $03, $03, $03, $03, $03, $27, $27, $27, $27, $27, $29, $29, $29 ; 00-0F
    .byte $29, $29, $29, $29, $29, $29, $29, $29, $29, $28, $28, $28, $28, $28, $28, $2A ; 10-1F
    .byte $2A, $2A, $2A, $2A, $2A, $2A, $2A, $28, $28, $28, $28, $28, $28, $28, $28, $28 ; 20-2F
    .byte $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $37, $37, $37, $37 ; 30-3F
    .byte $37, $29, $29, $29, $29, $29, $29, $29, $29, $28, $28, $28, $28, $28, $28, $28 ; 40-4F
    .byte $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28 ; 50-5F
    .byte $28, $28, $28, $28, $28, $28, $19, $19, $19, $19, $32, $32, $32, $32, $32, $32 ; 60-6F
    .byte $32, $32, $32, $32, $32, $32, $32, $32, $3F, $32, $32, $32, $32 ; 70-7C

; 125 bytes, one per entry E: read through (zp_15),y at 45C9 and 4614 (base #<tbl_62C1 + E).
tbl_62C1
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $07, $06, $05, $04, $03, $07, $06, $05 ; 00-0F
    .byte $04, $03, $02, $01, $07, $06, $05, $04, $03, $00, $01, $02, $03, $05, $06, $00 ; 10-1F
    .byte $01, $02, $03, $04, $05, $06, $07, $02, $03, $01, $04, $05, $06, $07, $00, $01 ; 20-2F
    .byte $02, $03, $05, $06, $00, $01, $02, $03, $04, $05, $06, $07, $04, $05, $06, $07 ; 30-3F
    .byte $02, $00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06 ; 40-4F
    .byte $07, $00, $01, $02, $03, $04, $05, $06, $07, $00, $01, $02, $03, $04, $05, $06 ; 50-5F
    .byte $07, $03, $04, $05, $06, $07, $00, $03, $01, $02, $04, $01, $05, $05, $00, $04 ; 60-6F
    .byte $00, $07, $05, $04, $06, $05, $05, $05, $03, $05, $04, $05, $07 ; 70-7C

; 125 words, one per entry E: the stream addresses, read at 4632 and 4638 through (zp_15),y
; (base #<tbl_633E + E x 2, 461B-4630).
tbl_633E
    .word dat_6AE0, dat_6AF3, dat_6B02, dat_6B13 ; 00-03
    .word dat_6B26, dat_6B35, dat_6B46, dat_6B59 ; 04-07
    .word dat_9BE3, dat_9C84, dat_9D24, dat_9DE5 ; 08-0B
    .word dat_9E7E, dat_9204, dat_9247, dat_92C6 ; 0C-0F
    .word dat_9312, dat_935E, dat_9390, dat_9401 ; 10-13
    .word dat_79E3, dat_7A29, dat_7A63, dat_7A87 ; 14-17
    .word dat_7AAD, dat_7DFC, dat_7E17, dat_7E64 ; 18-1B
    .word dat_7E9E, dat_7ED7, dat_7F20, dat_7AD5 ; 1C-1F
    .word dat_7AE5, dat_7AF9, dat_7B19, dat_7B39 ; 20-23
    .word dat_7B59, dat_7B7F, dat_7BA9, dat_7BD3 ; 24-27
    .word dat_7C1B, dat_7C45, dat_7C63, dat_7CD0 ; 28-2B
    .word dat_7D41, dat_7DB0, dat_7DFC, dat_7E17 ; 2C-2F
    .word dat_7E64, dat_7E9E, dat_7ED7, dat_7F20 ; 30-33
    .word dat_7F3D, dat_8009, dat_8099, dat_8132 ; 34-37
    .word dat_81ED, dat_8283, dat_834A, dat_83B6 ; 38-3B
    .word dat_8422, dat_842F, dat_843C, dat_8449 ; 3C-3F
    .word dat_845C, dat_863F, dat_8677, dat_86B5 ; 40-43
    .word dat_8713, dat_8771, dat_8798, dat_87E1 ; 44-47
    .word dat_886E, dat_888F, dat_89A4, dat_8AAF ; 48-4B
    .word dat_8BEC, dat_8D2D, dat_8E6E, dat_8FAB ; 4C-4F
    .word dat_90A4, dat_945F, dat_94A7, dat_94F3 ; 50-53
    .word dat_953B, dat_959F, dat_95D0, dat_9651 ; 54-57
    .word dat_96A3, dat_9719, dat_976D, dat_97AE ; 58-5B
    .word dat_97F3, dat_9817, dat_9845, dat_988A ; 5C-5F
    .word dat_98D6, dat_9924, dat_99A9, dat_99DE ; 60-63
    .word dat_9A7C, dat_9B31, dat_65E6, dat_66CE ; 64-67
    .word dat_6786, dat_6836, dat_6940, dat_6934 ; 68-6B
    .word dat_6900, dat_690F, dat_697B, dat_6990 ; 6C-6F
    .word dat_69A8, dat_6949, dat_69BE, dat_69C8 ; 70-73
    .word dat_69D5, dat_6974, dat_69F1, dat_6A21 ; 74-77
    .word dat_68E8, dat_6A78, dat_6AD7, dat_6A60 ; 78-7B
    .word dat_68F1                      ; 7C-7C

; 125 words, one per entry E: the next entry, 0 for the last; read at 4694-469D through
; (zp_15),y (base #<tbl_6438 + E x 2, 467B-4692).
tbl_6438
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

; 53 bytes: read at 5C43 (the OKI phrase byte, ORed with 80) and 5C75 with Y = the parameter.
tbl_6532
    .byte $01, $01, $02, $03, $04, $05, $06, $07, $08, $20, $22, $21, $23, $09, $0A, $0B ; 00-0F
    .byte $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B ; 10-1F
    .byte $1C, $1D, $1E, $1F, $24, $25, $29, $26, $33, $2E, $28, $2C, $2F, $2D, $30, $27 ; 20-2F
    .byte $2A, $32, $31, $34, $2B       ; 30-34

; 53 bytes: read at 5C08, 5C1E and 5C4B (bits 5-4: the OKI channel, 3-0 the second OKI byte;
; bit 7, tested at 5C1E-5C20 on the entry playing on the channel: set, a new start does not
; interrupt it).
tbl_6567
    .byte $01, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $00, $80, $80 ; 00-0F
    .byte $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80 ; 10-1F
    .byte $80, $80, $80, $80, $00, $00, $10, $11, $12, $10, $20, $21, $20, $20, $20, $31 ; 20-2F
    .byte $30, $30, $31, $30, $31       ; 30-34

; 53 bytes: read at 5C56 (into zp_5E,x).
tbl_659C
    .byte $00, $06, $06, $06, $06, $06, $06, $06, $06, $08, $08, $08, $08, $04, $04, $04 ; 00-0F
    .byte $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04 ; 10-1F
    .byte $04, $04, $04, $04, $08, $07, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00 ; 20-2F
    .byte $00, $00, $00, $00, $00       ; 30-34

; 6 bytes: read at 43AE and 43BB (AND 1F: X, a zp_23 offset) with Y = 00-05.
tbl_65D1
    .byte $00, $00, $00, $00, $00, $00

; 6 bytes: read at 43B4 and 43C1 (the value for zp_23,x).
tbl_65D7
    .byte $00, $01, $02, $03, $04, $05

; 9 bytes up to the first stream (dat_65E6); read at 44C5 (Y), 44ED-451B (X: cmdtype_0D, no
; command has type 0D) and 58AB-590F (X = zp_4E and zp_4E x 2: a word at 590A/590F becomes the
; pointer zp_49 of ymtimer.asm). None of these was executed in the make sndtrace runs and no
; command reaches them with a bounded index, so the extent is the space left.
tbl_65DD
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00

    .cerror * != $65E6, "sounds.asm must end at $65E5"
