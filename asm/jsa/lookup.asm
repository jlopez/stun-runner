; lookup.asm: AB48-AC47, the 256-byte table read at 4F69.
;
; Generated once from the recursive descent and the MAME trace (docs/09-sound-program.md);
; hand-maintained from here on.

    .cerror * != $AB48, "lookup.asm must start at $AB48"

; read at 4F69
tbl_AB48
    .byte $00, $02, $04, $06, $07, $09, $0B, $0D, $0F, $11, $12, $14, $16, $18, $1A, $1C
    .byte $1D, $1F, $21, $23, $25, $27, $29, $2A, $2C, $2E, $30, $32, $34, $35, $37, $39
    .byte $3B, $3D, $3F, $40, $42, $44, $46, $48, $4A, $4B, $4D, $4F, $51, $53, $55, $57
    .byte $58, $5A, $5C, $5E, $60, $62, $63, $65, $67, $69, $6B, $6D, $6E, $70, $72, $74
    .byte $76, $78, $7A, $7B, $7D, $7F, $81, $83, $85, $86, $88, $8A, $8C, $8E, $90, $91
    .byte $93, $95, $97, $99, $9B, $9D, $9E, $A0, $A2, $A4, $A6, $A8, $A9, $AB, $AD, $AF
    .byte $B1, $B3, $B4, $B6, $B8, $BA, $BC, $BE, $BF, $C1, $C3, $C5, $C7, $C9, $CB, $CC
    .byte $CE, $D0, $D2, $D4, $D6, $D7, $D9, $DB, $DD, $DF, $E1, $E2, $E4, $E6, $E8, $EA
    .byte $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F5
    .byte $F4, $F2, $F1, $EF, $EE, $EC, $EB, $E9, $E7, $E6, $E4, $E3, $E1, $E0, $DE, $DC
    .byte $DA, $D8, $D6, $D3, $D1, $CF, $CD, $CB, $C9, $C7, $C5, $C2, $C0, $BE, $BC, $B9
    .byte $B7, $B4, $B1, $AF, $AC, $A9, $A6, $A4, $A1, $9E, $9C, $99, $96, $94, $91, $8D
    .byte $8A, $86, $82, $7E, $7B, $77, $73, $6F, $6C, $68, $64, $60, $5D, $59, $55, $52
    .byte $50, $4D, $4B, $48, $45, $43, $40, $3D, $3B, $38, $36, $33, $30, $2E, $2B, $29
    .byte $28, $26, $24, $23, $21, $20, $1E, $1C, $1B, $19, $17, $16, $14, $13, $11, $10
    .byte $0F, $0E, $0D, $0C, $0B, $0A, $09, $07, $06, $05, $04, $03, $02, $01, $00, $00

    .cerror * != $AC48, "lookup.asm must end at $AC47"
