; data/macros.asm: the statements of the sequencer's data. Emits no bytes.
;
; One macro per stream command of the interpreter (sequencer.asm: read_item 484B-4880 for the
; notes, run_op 505D and op_handlers for the ops 80-BA) and for the YM2151 patch records the ops
; 9D, 9E and 9F point to. A macro's bytes are exactly what its handler reads: the op byte, the
; operand byte the reader hands every handler in A (505D-5079), and one more byte per call of
; next_operand (507B) the handler makes. Every address operand is a .word of a label, so the
; data assembles anywhere (the stream pointer is 16-bit, 4781-4786 and 4864-486C).
; docs/12-sound-music.md has the op table with the handlers' addresses and what MAME executed.
; Included by jsa.asm before the region files.

; ---------------------------------------------------------------------------------------------
; Note lengths: the low nibble of a note's length byte indexes note_lengths (tables.asm
; tbl_5FE3, 16 words; 498B-49A9 add the word to the track's 24-bit time counter, bytes 1-2).
; LEN_n is 1/n of LEN_1 ($1E00); LEN_0 adds nothing.

LEN_0 = $00                             ; $0000
LEN_1 = $01                             ; $1E00
LEN_2 = $02                             ; $0F00
LEN_4 = $03                             ; $0780
LEN_8 = $04                             ; $03C0
LEN_3 = $05                             ; $0A00
LEN_6 = $06                             ; $0500
LEN_12 = $07                            ; $0280
LEN_5 = $08                             ; $0600
LEN_16 = $09                            ; $01E0
LEN_32 = $0A                            ; $00F0
LEN_64 = $0B                            ; $0078
LEN_128 = $0C                           ; $003C
LEN_24 = $0D                            ; $0140
LEN_48 = $0E                            ; $00A0
LEN_10 = $0F                            ; $0300

; Flags of the length byte (start_note 497F-4A2F; YM2151 output 4D6C-4D82, 4F24-4F2C).
DOT = $40                               ; adds half the length again (49A9-49BD)
TIE = $80                               ; no key-off at the end: the gate counter is not set
                                        ;   (49C4); the next note keys on without a key-off
GATE_HALF = $10                         ; bits 5-4 = 01: the key-off comes at half the length
                                        ;   (49FA-4A02); level offset 0 (key_accent entry 1)
ACCENT_1 = $20                          ; bits 5-4 = 10: key_accent entry 2 (tbl_5FDF, 24)
ACCENT_2 = $30                          ; bits 5-4 = 11: key_accent entry 3 (tbl_5FDF, 58)

; Registers of the variable ops (var_store B0, var_add_to B1: 53C4-5449; var_load B2,
; var_cmp_reg B9, the branches B5-B8: read_register 5494-5503), for the YM2151 tracks.
R_VOLUME = $00                          ; write: volume (op 82); read: 0 (54C8-54CC)
R_TEMPO_HI = $01                        ; the tempo's high byte (ram_0644)
R_TRANSPOSE = $02                       ; transpose (ram_0662)
R_VELOCITY = $03                        ; write: velocity (op A2); read: the same value back
R_FINE = $04                            ; write: fine_tune (op A6, the value x 4); read: the
                                        ;   pitch fraction itself (ram_0464, = the value x 4)
R_RANDOM = $05                          ; read: the next random byte (random 5504); write: none
R_GLOBAL = $06                          ; $06+n: global variable n, n 00-1F (zp_23+n), shared by
                                        ;   all tracks; commands 1E-23 set global 0 to 0-5
R_FLAG = $FF                            ; $26-$FF: read the track's last result (ram_0842)

; ---------------------------------------------------------------------------------------------
; Notes (bytes 00-7F, then a length byte; read_item 487E-4919)

note .macro pitch, len                  ; key a note: pitch 01-7F (+ transpose) indexes
    .cerror \pitch < $01 || \pitch > $7F, "note: pitch 01-7F"      ;   key_codes (5E7D)
    .cerror \len < $01 || \len > $FF, "note: length byte 01-FF (00 is ret)"
    .byte \pitch, \len
.endm

rest .macro len                         ; pitch 00: no transpose, no key-on (4EF0)
    .cerror \len < $01 || \len > $FF, "rest: length byte 01-FF (00 is ret)"
    .byte $00, \len
.endm

ret .macro                              ; length 00: return from a call, or stop the track
    .byte $00, $00                      ;   when none is pending (4914-4940)
.endm

; ---------------------------------------------------------------------------------------------
; Ops (bytes 80-BA; op_handlers, 50AF). A byte BB-FF stops the track (run_op 505D-5067).

tempo .macro rate                       ; 80: the 16-bit amount the time counter loses per
    .byte $80                           ;   tick (ram_0626/ram_0644)
    .word \rate
.endm

tempo_add .macro delta                  ; 81: add to the tempo
    .byte $81
    .word \delta
.endm

volume .macro level                     ; 82: YM2151: the patch's TLs again, then the carriers
    .byte $82, \level                   ;   attenuated by volume_steps[level & 0F] (5788)
.endm

volume_add .macro delta                 ; 83: YM2151: the carriers' TL minus delta (op A1)
    .byte $83, \delta
.endm

transpose .macro steps                  ; 84: added to every pitch but 00 (4887)
    .byte $84, \steps
.endm

transpose_add .macro delta              ; 85
    .byte $85, \delta
.endm

pitch_env .macro table                  ; 86: other voices only: pitch envelope (4B08-4BBB)
    .byte $86
    .word \table
.endm

level_env .macro table                  ; 87: other voices only: level envelope (4BF4-4C4B)
    .byte $87
    .word \table
.endm

sync .macro unused=$00                  ; 88: wait until every track of the group arrives
    .byte $88, \unused                  ;   (5125-517E)
.endm

sync_group .macro group                 ; 89: the group sync waits on (ram_069E)
    .byte $89, \group
.endm

ctl_bits .macro bits                    ; 8A: other voices only: ORed into the level byte
    .byte $8A, \bits                    ;   (ram_06BC, 4C8E)
.endm

ctl_set .macro bits                     ; 8B: other voices only: control bits set (ram_0446)
    .byte $8B, \bits
.endm

portamento .macro rate                  ; 8C: glide from the last pitch, rate per 4 ticks
    .byte $8C, \rate                    ;   (ram_06DA, 4DBE-4E11)
.endm

call .macro target                      ; 8D: run the stream at target until its ret
    .byte $8D
    .word \target
.endm

loop .macro count                       ; 8E: repeat to the next loop_end count times
    .byte $8E, \count
.endm

loop_end .macro                         ; 8F: back to the loop's start until its count runs out
    .byte $8F, $00                      ;   (the operand byte is not read)
.endm

skip .macro op, unused=$00              ; 90-94, 98, 9A, 9C: two bytes the reader passes over
    .cerror (\op < $90 || \op > $94) && \op != $98 && \op != $9A && \op != $9C, "skip: op"
    .byte \op, \unused                  ;   by re-entering itself (read_item, 484B)
.endm

oki .macro command                      ; 95: start the OKI sample of command (cmd_param)
    .byte $95, \command
.endm

respond .macro value                    ; 96: queue a response byte for the 68010
    .byte $96, \value
.endm

release .macro unused=$00               ; 97: start the release fade, then stop the track
    .byte $97, \unused
.endm

jump .macro target                      ; 99
    .byte $99
    .word \target
.endm

ctl_clear .macro bits                   ; 9B: other voices only: control bits cleared
    .byte $9B, \bits
.endm

patch .macro record                     ; 9D: the YM2151 patch (key-off, TL 7F, registers)
    .byte $9D
    .word \record
.endm

lfo .macro record                       ; 9E: the record's LFO bytes into registers 18-1B
    .byte $9E
    .word \record
.endm

noise .macro record                     ; 9F: the record's noise byte into register 0F
    .byte $9F
    .word \record
.endm

pan .macro side                         ; A0: register 20 bits 7-6: 0 or 3 both, 1 bit 7,
    .byte $A0, \side                    ;   2 bit 6
.endm

carrier_tl_sub .macro delta             ; A1: the carriers' TL minus delta
    .byte $A1, \delta
.endm

velocity .macro level                   ; A2: the key-on level the patch scales per operator
    .byte $A2, \level
.endm

velocity_add .macro delta               ; A3
    .byte $A3, \delta
.endm

fade .macro time, rate                  ; A4: carriers' TL + rate per step, time in steps
    .byte $A4, \time, \rate             ;   (fade_step 4CC1)
.endm

ym_ct .macro bits                       ; A5: register 1B bits 7-6 (CT1, CT2)
    .byte $A5, \bits
.endm

fine_tune .macro fraction               ; A6: the pitch fraction (ram_0464) = fraction x 4:
    .byte $A6, \fraction                ;   1/64 of a key step each, register 30 (4E32-4E44)
.endm

bend .macro delta                       ; A7: pitch fraction + delta x 4 (signed), carried into
    .byte $A7, \delta                   ;   the transpose (5711-5733)
.endm

fade_shape .macro value                 ; A8: ram_0608 (fade_step 4CCF; other voices: the
    .byte $A8, \value                   ;   pitch envelope's repeat count)
.endm

var_add .macro value                    ; A9: var + value
    .byte $A9, \value
.endm

var_sub .macro value                    ; AA: var - value
    .byte $AA, \value
.endm

var_and .macro value                    ; AB
    .byte $AB, \value
.endm

var_or .macro value                     ; AC
    .byte $AC, \value
.endm

var_xor .macro value                    ; AD
    .byte $AD, \value
.endm

jump_table .macro                       ; AE: the stream goes to the .word number var of the
    .byte $AE                           ;   list that follows (a .word line of labels)
.endm

jump_table_inc .macro                   ; AF: as AE, then var + 1
    .byte $AF
.endm

var_store .macro reg                    ; B0: register reg = var
    .byte $B0, \reg
.endm

var_add_to .macro reg                   ; B1: register reg + var
    .byte $B1, \reg
.endm

var_load .macro reg                     ; B2: var = register reg
    .byte $B2, \reg
.endm

var_shr .macro count                    ; B3: var >> count (1-7)
    .byte $B3, \count
.endm

var_shl .macro count                    ; B4: var << count (1-7)
    .byte $B4, \count
.endm

branch_zero .macro reg, target          ; B5: go to target when register reg is 0
    .byte $B5, \reg
    .word \target
.endm

branch_nonzero .macro reg, target       ; B6
    .byte $B6, \reg
    .word \target
.endm

branch_plus .macro reg, target          ; B7: bit 7 clear
    .byte $B7, \reg
    .word \target
.endm

branch_minus .macro reg, target         ; B8: bit 7 set
    .byte $B8, \reg
    .word \target
.endm

var_cmp_reg .macro reg                  ; B9: result = var - register reg
    .byte $B9, \reg
.endm

var_cmp .macro value                    ; BA: result = var - value
    .byte $BA, \value
.endm

stop .macro op=$FF                      ; BB-FF: the track ends (ram_0248 = FF)
    .cerror \op < $BB, "stop: BB-FF"
    .byte \op
.endm

; ---------------------------------------------------------------------------------------------
; YM2151 patch records, 42 bytes (2A): what patch (9D: load_patch 5543-55A8 and the register
; loop 55B6-5637), lfo (9E, 563B) and noise (9F, 567F) read through the record's address.

ym_voice .macro rl_fb_con, kc, kf, pms_ams      ; +00: registers 20, 28, 30, 38 (+ channel)
    .byte \rl_fb_con, \kc, \kf, \pms_ams
.endm

; +04, +0A, +10, +16: one per operator, M1, M2, C1, C2 (registers +00, +08, +10, +18): written
; in this order to registers 40, 80, A0, C0, E0; tl is not written by the patch load (TL is set
; to 7F) but copied into the track's TL (5565-5582) for the key-on (4D8D)
ym_operator .macro dt1_mul, tl, ks_ar, ams_d1r, dt2_d2r, d1l_rr
    .byte \dt1_mul, \tl, \ks_ar, \ams_d1r, \dt2_d2r, \d1l_rr
.endm

; +1C, +1E, +20, +22: per operator (M1, M2, C1, C2) the key-on level scaling: curve ORed with
; the key code indexes key_level_curve (lookup.asm), depth's high nibble scales it and its low
; nibble scales the velocity (4F56-4F98). The M1 curve byte (+1C) is never copied (4DB6-4DBC
; stop at Y = 1).
ym_scaling .macro curve, depth
    .byte \curve, \depth
.endm

ym_lfo .macro lfrq, pmd, amd, ct_w      ; +24: registers 18, 19, 19, 1B (bits 1-0) for op 9E
    .byte \lfrq, \pmd, \amd, \ct_w
.endm

ym_noise .macro shadow_1b, ne_nfrq      ; +28: op 9E copies shadow_1b into the shadow slot of
    .byte \shadow_1b, \ne_nfrq          ;   register 1B (5677), which nothing reads; +29:
.endm                                   ;   register 0F for op 9F
