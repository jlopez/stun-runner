; tables.asm: 5DB5-61E3, lookup tables of the code and the command tables.
;
; Every table here is read by the code at the addresses its comment gives (and the MAME trace
; confirms each read: artifacts/sndtrace-summary.json, data_read). A table's length is what the
; index the code builds can reach where that is bounded (an AND, a compare), else up to the next
; table. The command tables (cmd_class, cmd_type, cmd_param, imm_handlers) are the protocol with
; the 68010 (docs/09-sound-program.md section 5); the others are for later legs to name.
;
; Generated once from a recursive descent and checked against the MAME trace (docs/09-sound-
; program.md section 3); hand-maintained from here on.

    .cerror * != $5DB5, "tables.asm must start at $5DB5"

; 4 bytes up to tbl_5DB9. 4718-4725 store its address as a pointer (low byte in ram_0482 and
; ram_04BE, high byte in ram_04A0 and ram_04DC).
dat_5DB5
    .byte $00, $00, $00, $00

; 98 words up to tbl_5E7D (the index is not bounded in the code); read as low/high byte pairs
; at 48BF-48D4 with Y.
tbl_5DB9
    .word $0000, $D5C8, $C9C8, $BE74, $B3C3, $A9AC, $A026, $9728
    .word $8EAC, $86AA, $7F1A, $77F8, $713C, $6AE0, $64E0, $5F37
    .word $59DE, $54D2, $500F, $4B91, $4753, $4351, $3F8A, $3BF8
    .word $389A, $356D, $326D, $2F98, $2CEC, $2A66, $2804, $25C5
    .word $23A6, $21A5, $1FC1, $1DF9, $1C4A, $1AB3, $1933, $17C8
    .word $1672, $152F, $13FF, $12DF, $11CF, $10CF, $0FDD, $0EF9
    .word $0E21, $0D56, $0C96, $0BE1, $0B36, $0A94, $09FC, $096C
    .word $08E4, $0864, $07EB, $0779, $070D, $06A7, $0647, $05ED
    .word $0597, $0547, $04FA, $04B2, $046F, $042F, $03F2, $03B9
    .word $0383, $0350, $0320, $02F3, $02C8, $02A0, $027A, $0256
    .word $0234, $0214, $01F6, $01D9, $01BE, $01A5, $018D, $0176
    .word $0161, $014C, $0139, $0127, $0116, $0106, $00F7, $00E9
    .word $00DC, $00CF

; 98 bytes up to tbl_5EDF; read at 4F02 with X.
tbl_5E7D
    .byte $00, $00, $00, $01, $02, $04, $05, $06, $08, $09, $0A, $0C, $0D, $0E
    .byte $10, $11, $12, $14, $15, $16, $18, $19, $1A, $1C, $1D, $1E, $20, $21
    .byte $22, $24, $25, $26, $28, $29, $2A, $2C, $2D, $2E, $30, $31, $32, $34
    .byte $35, $36, $38, $39, $3A, $3C, $3D, $3E, $40, $41, $42, $44, $45, $46
    .byte $48, $49, $4A, $4C, $4D, $4E, $50, $51, $52, $54, $55, $56, $58, $59
    .byte $5A, $5C, $5D, $5E, $60, $61, $62, $64, $65, $66, $68, $69, $6A, $6C
    .byte $6D, $6E, $70, $71, $72, $74, $75, $76, $78, $79, $7A, $7C, $7D, $7E

; 256 bytes: read at 4F75 and 4F87 with Y made of two nibbles (4F62-4F74, 4F7B-4F86).
tbl_5EDF
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02
    .byte $00, $00, $00, $00, $01, $01, $01, $02, $02, $02, $03, $03, $03, $04, $04, $04
    .byte $00, $00, $00, $01, $01, $02, $02, $03, $03, $03, $04, $04, $05, $05, $06, $06
    .byte $00, $00, $01, $01, $02, $02, $03, $03, $04, $05, $05, $06, $06, $07, $07, $08
    .byte $00, $00, $01, $02, $02, $03, $04, $04, $05, $06, $06, $07, $08, $08, $09, $0A
    .byte $00, $00, $01, $02, $03, $04, $04, $05, $06, $07, $08, $08, $09, $0A, $0B, $0C
    .byte $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E
    .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
    .byte $00, $01, $02, $03, $04, $05, $07, $08, $09, $0A, $0B, $0D, $0E, $0F, $10, $11
    .byte $00, $01, $02, $03, $05, $06, $07, $09, $0A, $0B, $0D, $0E, $0F, $11, $12, $13
    .byte $00, $01, $02, $04, $05, $07, $08, $0A, $0B, $0C, $0D, $0F, $11, $12, $14, $15
    .byte $00, $01, $03, $04, $06, $07, $09, $0A, $0C, $0E, $0F, $11, $12, $14, $15, $17
    .byte $00, $01, $03, $05, $06, $08, $0A, $0B, $0D, $0F, $10, $12, $14, $15, $17, $19
    .byte $00, $01, $03, $05, $07, $09, $0A, $0C, $0E, $10, $12, $13, $15, $17, $19, $1B
    .byte $00, $01, $03, $05, $07, $09, $0B, $0D, $0F, $11, $13, $15, $17, $19, $1B, $1D

; 4 bytes: read at 4F2C with X = ram_08AB bits 3-2 (4F24-4F2B).
tbl_5FDF
    .byte $00, $00, $24, $58

; 16 words: read at 498F-49AD with Y = (A AND 0F) x 2 (498B-498E); 4CD3 and 4CD9 read
; entry 0A (tbl_5FE3+$14).
tbl_5FE3
    .word $0000, $1E00, $0F00, $0780, $03C0, $0A00, $0500, $0280
    .word $0600, $01E0, $00F0, $0078, $003C, $0140, $00A0, $0300

; 16 bytes: read at 4CE8 with Y = A AND 0F (4CE5).
tbl_6003
    .byte $00, $FF, $80, $40, $20, $40, $20, $10, $40, $10, $08, $04, $02, $08, $04, $20

; 128 bytes up to cmd_class; read at 4C60 with Y = ram_040A,x.
tbl_6013
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $C0, $80, $80, $80, $80, $80, $80, $80, $80, $80
    .byte $00, $00, $00, $C0, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    .byte $20, $20, $20, $20, $20, $20, $1F, $1D, $1A, $16, $12, $0C, $06, $03, $01, $00
    .byte $20, $20, $20, $1D, $16, $0C, $04, $01, $00, $00, $00, $00, $00, $00, $00, $00
    .byte $40, $40, $40, $40, $40, $40, $3F, $3B, $35, $2D, $24, $18, $0C, $04, $01, $00
    .byte $40, $40, $40, $3B, $2D, $18, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00

; --- The command tables: one byte per command byte 00-6C (h_nmi and dispatch_command refuse 6D
; and up, 583C and 4371).

; How h_nmi takes the command: bit 7 set (FF), queued for main_loop; 00-03, at once, through
; imm_handlers entry 1-4 (commands 03, 06, 07, 08).
cmd_class
    .byte $FF, $FF, $FF, $00, $FF, $FF, $01, $02 ; 00-07
    .byte $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 08-0F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 10-17
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 18-1F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 20-27
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 28-2F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 30-37
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 38-3F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 40-47
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 48-4F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 50-57
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 58-5F
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ; 60-67
    .byte $FF, $FF, $FF, $FF, $FF       ; 68-6C

; The command's type, the cmdtype_handlers entry dispatch_command runs: 00-14, or FF (the four
; immediate commands, which dispatch_command ignores).
cmd_type
    .byte $03, $00, $00, $FF, $08, $13, $FF, $FF ; 00-07
    .byte $FF, $09, $08, $0B, $08, $08, $0B, $08 ; 08-0F
    .byte $08, $08, $08, $0A, $08, $0A, $08, $08 ; 10-17
    .byte $08, $0A, $08, $08, $08, $08, $01, $01 ; 18-1F
    .byte $01, $01, $01, $01, $08, $08, $08, $0A ; 20-27
    .byte $08, $0A, $08, $08, $08, $08, $05, $08 ; 28-2F
    .byte $08, $08, $08, $08, $08, $08, $05, $08 ; 30-37
    .byte $13, $13, $13, $13, $13, $13, $13, $13 ; 38-3F
    .byte $13, $13, $13, $13, $13, $13, $13, $13 ; 40-47
    .byte $13, $13, $13, $13, $13, $13, $13, $13 ; 48-4F
    .byte $13, $13, $13, $13, $13, $13, $13, $13 ; 50-57
    .byte $13, $13, $13, $13, $13, $13, $13, $13 ; 58-5F
    .byte $13, $13, $13, $13, $13, $13, $14, $13 ; 60-67
    .byte $13, $13, $13, $13, $13       ; 68-6C

; The command's parameter, the A the handler gets.
cmd_param
    .byte $00, $3C, $00, $00, $00, $00, $00, $00 ; 00-07
    .byte $00, $55, $01, $27, $02, $03, $29, $04 ; 08-0F
    .byte $05, $06, $07, $12, $08, $14, $09, $0A ; 10-17
    .byte $0B, $18, $0C, $0D, $0E, $0F, $00, $01 ; 18-1F
    .byte $02, $03, $04, $05, $10, $11, $12, $26 ; 20-27
    .byte $13, $28, $14, $15, $16, $17, $2D, $18 ; 28-2F
    .byte $19, $1A, $1B, $1C, $1D, $1E, $35, $1F ; 30-37
    .byte $01, $02, $03, $04, $05, $06, $07, $08 ; 38-3F
    .byte $09, $0A, $0B, $0C, $0D, $0E, $0F, $10 ; 40-47
    .byte $11, $12, $13, $14, $15, $16, $17, $18 ; 48-4F
    .byte $19, $1A, $1B, $1C, $1D, $1E, $1F, $20 ; 50-57
    .byte $21, $22, $23, $24, $25, $26, $27, $28 ; 58-5F
    .byte $29, $2A, $2B, $2C, $2D, $2E, $30, $2F ; 60-67
    .byte $30, $31, $32, $33, $34       ; 68-6C

; Five handlers, each word the address - 1 (entered by RTS). Entry 0 through cmdtype_03 (43CA,
; A = cmd_param: command 00), entries 1-4 by h_nmi for cmd_class 00-03 (5855-585D).
imm_handlers
    .word imm_00-1                      ; command 00 (through cmdtype_03)
    .word imm_01-1                      ; command 03
    .word imm_02-1                      ; command 06
    .word imm_03-1                      ; command 07
    .word imm_04-1                      ; command 08

    .cerror * != $61E4, "tables.asm must end at $61E3"
