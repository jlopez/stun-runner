; streams_1.asm: 65E6-6B7F, byte streams of the sequencer: sounds 0F-1F and 00.
;
; Each stream is one track of a sound (snd_NN_V: track V of sound NN, started through
; entry_stream, data/sounds.asm); the statements are the macros of data/macros.asm, one per
; note or op, read by read_item (sequencer.asm, 484B). Labels inside a stream are where other
; statements of the data go: _subN a call target (op 8D), _tN a jump, branch or jump_table
; target. unused_stream_NN is a stream no pointer of the program reaches (docs/12-sound-
; music.md section 6). A statement marked "not reached" follows a jump or a jump table in its
; stream and no pointer reaches it.

    .cerror * != $65E6, "streams_1.asm must start at $65E6"

; entry 66: sound 0F (command 1D), track 0, YM2151 channel 0, priority 19; make musictrace: started
; (1), its statements read
snd_0F_0
    #patch patch_13
    #volume $0A
    #transpose $00
    #fine_tune $00
    #var_and $00
    #var_store R_GLOBAL+$00
    #velocity $1E
    #tempo $3333
    #loop $18
    #note $0F, LEN_64|TIE
    #bend $14
    #loop_end
    #tempo $1EB8
snd_0F_0_t1
    #var_load R_GLOBAL+$00
    #var_and $07
    #jump_table
    .word snd_0F_0_t6, snd_0F_0_t2, snd_0F_0_t3, snd_0F_0_t8
    .word snd_0F_0_t4, snd_0F_0_t5, snd_0F_0_t6, snd_0F_0_t6
    #ret                                ; not reached: the stream never gets here
snd_0F_0_t2
    #tempo $1EB8
    #velocity $1E
    #var_load R_TEMPO_HI
    #var_store R_GLOBAL+$13
    #bend $0A
    #var_load R_FINE
    #var_store R_GLOBAL+$11
    #var_load R_TRANSPOSE
    #var_store R_GLOBAL+$10
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_0_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #var_store R_GLOBAL+$11
    #jump snd_0F_0_t7
snd_0F_0_t3
    #tempo $1EB8
    #velocity $50
    #var_load R_TEMPO_HI
    #var_store R_GLOBAL+$13
    #bend $F6
    #var_load R_FINE
    #var_store R_GLOBAL+$11
    #var_load R_TRANSPOSE
    #var_store R_GLOBAL+$10
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_0_t7
    #transpose $00
    #fine_tune $00
    #var_and $00
    #var_store R_TRANSPOSE
    #var_store R_FINE
    #jump snd_0F_0_t7
snd_0F_0_t4
    #tempo $3D71
    #velocity $1E
    #var_load R_TEMPO_HI
    #var_store R_GLOBAL+$13
    #bend $0A
    #var_load R_FINE
    #var_store R_GLOBAL+$11
    #var_load R_TRANSPOSE
    #var_store R_GLOBAL+$10
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_0_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #var_store R_GLOBAL+$11
    #jump snd_0F_0_t7
snd_0F_0_t5
    #tempo $3D71
    #velocity $50
    #var_load R_TEMPO_HI
    #var_store R_GLOBAL+$13
    #bend $F6
    #var_load R_FINE
    #var_store R_GLOBAL+$11
    #var_load R_TRANSPOSE
    #var_store R_GLOBAL+$10
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_0_t7
    #transpose $00
    #fine_tune $00
    #var_and $00
    #var_store R_TRANSPOSE
    #var_store R_FINE
snd_0F_0_t6
    #tempo $1EB8
    #var_load R_VELOCITY
    #var_cmp $1E
    #branch_minus R_FLAG, snd_0F_0_t7
    #velocity_add $FE
snd_0F_0_t7
    #note $0F, LEN_64|TIE
    #jump snd_0F_0_t1
    #ret                                ; not reached: the stream never gets here
snd_0F_0_t8
    #tempo $3333
    #loop $3C
    #note $0F, LEN_64|TIE
    #bend $EC
    #loop_end
    #note $0F, LEN_128
    #ret

; entry 67: sound 0F (command 1D), track 1, YM2151 channel 3, priority 19; make musictrace: started
; (1), its statements read
snd_0F_1
    #patch patch_13
    #var_and $00
    #var_store R_GLOBAL+$12
    #volume $0A
    #transpose $00
    #fine_tune $00
    #bend $FD
    #velocity $1E
    #tempo $3333
    #loop $18
    #note $0F, LEN_64|TIE
    #bend $14
    #loop_end
snd_0F_1_t1
    #tempo $1EB8
snd_0F_1_t2
    #var_load R_GLOBAL+$00
    #var_and $07
    #jump_table
    .word snd_0F_1_t7, snd_0F_1_t3, snd_0F_1_t4, snd_0F_1_t9
    .word snd_0F_1_t5, snd_0F_1_t6, snd_0F_1_t7, snd_0F_1_t7
    #ret                                ; not reached: the stream never gets here
snd_0F_1_t3
    #tempo $1EB8
    #velocity $1E
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_1_t8
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_1_t8
snd_0F_1_t4
    #tempo $1EB8
    #velocity $50
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_1_t8
    #transpose $00
    #fine_tune $00
    #jump snd_0F_1_t8
snd_0F_1_t5
    #tempo $3D71
    #velocity $1E
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_1_t8
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_1_t8
snd_0F_1_t6
    #tempo $3D71
    #velocity $50
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_1_t8
    #transpose $00
    #fine_tune $00
    #jump snd_0F_1_t8
snd_0F_1_t7
    #tempo $1EB8
    #var_load R_VELOCITY
    #var_cmp $1E
    #branch_minus R_FLAG, snd_0F_1_t8
    #velocity_add $FE
snd_0F_1_t8
    #note $0F, LEN_64|TIE
    #branch_zero R_GLOBAL+$12, snd_0F_1_t2
    #note $0F, LEN_128
    #ret
snd_0F_1_t9
    #tempo $3333
    #loop $3C
    #note $0F, LEN_64|TIE
    #bend $EC
    #loop_end
    #note $0F, LEN_128
    #ret

; entry 68: sound 0F (command 1D), track 2, YM2151 channel 1, priority 19; make musictrace: started
; (1), its statements read
snd_0F_2
    #patch patch_0B
    #tempo $1EB8
    #volume $07
    #transpose $00
    #fine_tune $00
    #tempo $3333
    #loop $18
    #note $22, LEN_64|TIE
    #bend $14
    #loop_end
    #tempo $1EB8
snd_0F_2_t1
    #var_load R_GLOBAL+$00
    #var_and $07
    #jump_table
    .word snd_0F_2_t6, snd_0F_2_t2, snd_0F_2_t3, snd_0F_2_t8
    .word snd_0F_2_t4, snd_0F_2_t5, snd_0F_2_t6, snd_0F_2_t6
    #ret                                ; not reached: the stream never gets here
snd_0F_2_t2
    #tempo $1EB8
    #velocity $00
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_2_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_2_t7
snd_0F_2_t3
    #tempo $1EB8
    #velocity $32
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_2_t7
    #transpose $00
    #fine_tune $00
    #jump snd_0F_2_t7
snd_0F_2_t4
    #tempo $3D71
    #velocity $00
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_2_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_2_t7
snd_0F_2_t5
    #tempo $3D71
    #velocity $32
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_2_t7
    #transpose $00
    #fine_tune $00
    #jump snd_0F_2_t7
snd_0F_2_t6
    #tempo $1EB8
    #var_load R_VELOCITY
    #var_cmp $32
    #branch_minus R_FLAG, snd_0F_2_t7
    #velocity_add $FE
snd_0F_2_t7
    #note $22, LEN_64|TIE
    #jump snd_0F_2_t1
    #ret                                ; not reached: the stream never gets here
snd_0F_2_t8
    #tempo $3333
    #loop $3C
    #note $22, LEN_64|TIE
    #bend $EC
    #loop_end
    #note $22, LEN_128
    #ret

; entry 69: sound 0F (command 1D), track 3, YM2151 channel 2, priority 19; make musictrace: started
; (1), its statements read
snd_0F_3
    #patch patch_16
    #tempo $1EB8
    #volume $09
    #transpose $00
    #fine_tune $00
    #tempo $3333
    #velocity $1E
    #loop $18
    #note $03, LEN_64|TIE
    #bend $14
    #loop_end
    #tempo $1EB8
snd_0F_3_t1
    #var_load R_GLOBAL+$00
    #var_and $07
    #jump_table
    .word snd_0F_3_t6, snd_0F_3_t2, snd_0F_3_t3, snd_0F_3_t8
    .word snd_0F_3_t4, snd_0F_3_t5, snd_0F_3_t6, snd_0F_3_t6
    #ret                                ; not reached: the stream never gets here
snd_0F_3_t2
    #tempo $1EB8
    #velocity $1E
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_3_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_3_t7
snd_0F_3_t3
    #tempo $1EB8
    #velocity $64
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_3_t7
    #transpose $00
    #fine_tune $00
    #jump snd_0F_3_t7
snd_0F_3_t4
    #tempo $3D71
    #velocity $1E
    #bend $0A
    #var_load R_TRANSPOSE
    #var_cmp $25
    #branch_minus R_FLAG, snd_0F_3_t7
    #var_load R_FINE
    #transpose $25
    #var_store R_FINE
    #jump snd_0F_3_t7
snd_0F_3_t5
    #tempo $3D71
    #velocity $64
    #bend $F6
    #var_load R_TRANSPOSE
    #var_cmp $00
    #branch_plus R_FLAG, snd_0F_3_t7
    #transpose $00
    #fine_tune $00
    #jump snd_0F_3_t7
snd_0F_3_t6
    #tempo $1EB8
    #var_load R_VELOCITY
    #var_cmp $1E
    #branch_minus R_FLAG, snd_0F_3_t7
    #velocity_add $FE
snd_0F_3_t7
    #note $03, LEN_64|TIE
    #jump snd_0F_3_t1
    #ret                                ; not reached: the stream never gets here
snd_0F_3_t8
    #tempo $3333
    #loop $3C
    #note $03, LEN_64|TIE
    #bend $F6
    #loop_end
    #note $03, LEN_128
    #ret

; entry 78: sound 1B (command 32), track 0, YM2151 channel 3, priority 3F; make musictrace: started
; (2), its statements read
snd_1B_0
    #patch patch_05
    #note $19, LEN_2|DOT
    #ret
    #ret                                ; not reached: the stream never gets here

; entry 7C: sound 1F (command 37), track 0, YM2151 channel 7, priority 32; make musictrace: started
; (1), its statements read
snd_1F_0
    #patch patch_06
    #velocity $7F
    #lfo patch_06
    #note $4F, LEN_4|DOT
    #lfo patch_12
    #ret

; entry 6C: sound 12 (command 26), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (2), its statements read
snd_12_0
    #patch patch_03
    #tempo $1EB8
    #volume $0D
snd_12_0_t1
    #note $0A, LEN_16|TIE
    #jump snd_12_0_t1
    #ret                                ; not reached: the stream never gets here

; entry 6D: sound 13 (command 28), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_13_0
    #patch patch_0E
    #tempo $13B6
    #volume $0F
    #velocity $50
    #transpose $04
snd_13_0_t1
    #loop $04
    #note $29, LEN_32|TIE
    #bend $F8
    #volume_add $FE
    #loop_end
    #loop $04
    #note $29, LEN_32|TIE
    #bend $08
    #volume_add $03
    #loop_end
    #jump snd_13_0_t1
    #ret                                ; not reached: the stream never gets here

; entry 6B: sound 11 (command 25), track 0, YM2151 channel 1, priority 32; make musictrace: started
; (1), its statements read
snd_11_0
    #patch patch_02
    #tempo $3333
    #note $25, LEN_8|GATE_HALF
    #note $25, LEN_4
    #ret

; entry 6A: sound 10 (command 24), track 0, YM2151 channel 4, priority 32; make musictrace: started
; (1), its statements read
snd_10_0
    #patch patch_0A
    #volume $0D
    #note $22, LEN_32
    #ret

; entry 71: sound 17 (command 2D), track 0, YM2151 channel 7, priority 32; make musictrace: started
; (1), its statements read
snd_17_0
    #patch patch_14
    #tempo $3852
    #velocity $7F
snd_17_0_t1
    #note $47, LEN_128|TIE
    #bend $02
    #jump snd_17_0_t1
    #fine_tune $00                      ; not reached: the stream never gets here
    #transpose $00                      ; not reached: the stream never gets here
    #ret                                ; not reached: the stream never gets here

unused_stream_01
    #patch patch_14
    #tempo $3333
    #volume $0A
    #loop $50
    #note $2B, LEN_128|TIE
    #velocity_add $01
    #bend $14
    #loop_end
    #note $2B, LEN_128
    #ret

; entry 75: sound 19 (command 30), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_19_0
    #patch patch_15
    #note $59, LEN_8
    #ret

; entry 6E: sound 14 (command 2A), track 0, YM2151 channel 0, priority 32; make musictrace: started
; (1), its statements read
snd_14_0
    #patch patch_0F
    #velocity $6E
    #volume $0A
    #oki $63
    #loop $13
    #note $33, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $33, LEN_16
    #ret

; entry 6F: sound 15 (command 2B), track 0, YM2151 channel 4, priority 32; make musictrace: started
; (1), its statements read
snd_15_0
    #patch patch_0F
    #tempo $199A
    #volume $0A
    #velocity $6E
    #oki $63
    #loop $13
    #note $34, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $34, LEN_16
    #ret

; entry 70: sound 16 (command 2C), track 0, YM2151 channel 0, priority 32; make musictrace: started
; (1), its statements read
snd_16_0
    #patch patch_0F
    #volume $0A
    #oki $63
    #loop $13
    #note $31, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #fade 1, $FB
    #note $31, LEN_1
    #ret

; entry 72: sound 18 (command 2F), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_18_0
    #patch patch_17
    #tempo $1EB8
    #note $27, LEN_1
    #ret

; entry 73: sound 18 (command 2F), track 1, YM2151 channel 4, priority 32; make musictrace: started
; (1), its statements read
snd_18_1
    #tempo $28F6
    #patch patch_09
    #lfo patch_08
    #note $29, LEN_1
    #ret

; entry 74: sound 18 (command 2F), track 2, YM2151 channel 6, priority 32; make musictrace: started
; (1), its statements read
snd_18_2
    #tempo $147B
    #patch patch_11
    #lfo patch_08
    #loop $14
    #note $25, LEN_32|TIE
    #volume_add $FF
    #bend $32
    #loop_end
    #note $25, LEN_32
    #rest LEN_4
    #lfo patch_12
    #ret

; entry 76: sound 1A (command 31), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements never read
snd_1A_0
    #patch patch_08
    #lfo patch_08
    #tempo $1EB8
    #fine_tune $40
    #volume $01
    #oki $5D
    #loop $06
    #note $44, LEN_128|TIE
    #volume_add $08
    #loop_end
    #loop $14
    #note $44, LEN_128
    #loop_end
    #fine_tune $00
    #transpose $00
    #ret

unused_stream_02
    #patch patch_08
    #lfo patch_08
    #tempo $1EB8
    #note $43, LEN_1
    #ret

; entry 77: sound 1A (command 31), track 1, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_1A_1
    #var_and $00
    #var_add $01
    #var_store R_GLOBAL+$12
    #patch patch_08
    #lfo patch_08
    #tempo $1EB8
    #volume $01
    #loop $06
    #note $44, LEN_128|TIE
    #volume_add $08
    #loop_end
    #loop $14
    #note $44, LEN_128
    #loop_end
    #note $44, LEN_2
    #patch patch_13
    #volume $09
    #velocity $14
    #var_and $00
    #var_store R_GLOBAL+$12
    #var_load R_GLOBAL+$10
    #var_store R_TRANSPOSE
    #var_load R_GLOBAL+$11
    #var_store R_FINE
    #var_load R_GLOBAL+$13
    #var_store R_TEMPO_HI
    #bend $FD
    #jump snd_0F_1_t1
    #ret                                ; not reached: the stream never gets here

; entry 7B: sound 1E (command 35), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_1E_0
    #patch patch_18
    #tempo $199A
    #volume $03
    #velocity $7F
    #loop $30
    #note $60, LEN_128|TIE
    #bend $F1
    #volume_add $01
    #loop_end
    #note $60, LEN_128
    #ret

; entry 79: sound 1C (command 33), track 0, YM2151 channel 5, priority 32; make musictrace: started
; (1), its statements read
snd_1C_0
    #patch patch_0C
    #tempo $2666
    #var_load R_RANDOM
    #var_and $03
    #jump_table
    .word snd_1C_0_t1, snd_1C_0_t2, snd_1C_0_t3, snd_1C_0_t4
snd_1C_0_t1
    #loop $08
    #note $49, LEN_128|TIE
    #bend $10
    #loop_end
    #fade 1, $EC
    #note $49, LEN_1
    #fine_tune $00
    #transpose $00
    #ret
snd_1C_0_t2
    #loop $08
    #note $50, LEN_128|TIE
    #bend $10
    #loop_end
    #fade 1, $EC
    #note $50, LEN_1
    #fine_tune $00
    #transpose $00
    #ret
snd_1C_0_t3
    #loop $08
    #note $4E, LEN_128|TIE
    #bend $10
    #loop_end
    #fade 1, $EC
    #note $4E, LEN_1
    #fine_tune $00
    #transpose $00
    #ret
snd_1C_0_t4
    #loop $08
    #note $44, LEN_128|TIE
    #bend $10
    #loop_end
    #fade 1, $EC
    #note $44, LEN_1
    #fine_tune $00
    #transpose $00
    #ret

; entry 7A: sound 1D (command 34), track 0, YM2151 channel 4, priority 32; make musictrace: started
; (1), its statements read
snd_1D_0
    #patch patch_01
    #velocity $7F
    #note $3F, LEN_4
    #ret

; entry 00: sound 00 (command 04), track 0, YM2151 channel 0, priority 03; make musictrace: started
; (1), its statements read
snd_00_0
    #patch patch_10
    #lfo patch_10
    #noise patch_10
    #pan $01
    #note $31, LEN_8
    #pan $02
    #note $31, LEN_8
    #ret

; entry 01: sound 00 (command 04), track 1, YM2151 channel 1, priority 03; make musictrace: started
; (1), its statements read
snd_00_1
    #patch patch_10
    #pan $01
    #rest LEN_4
    #note $33, LEN_8
    #pan $02
    #note $33, LEN_8
    #ret

; entry 02: sound 00 (command 04), track 2, YM2151 channel 2, priority 03; make musictrace: started
; (1), its statements read
snd_00_2
    #patch patch_10
    #pan $01
    #rest LEN_4
    #rest LEN_4
    #note $35, LEN_8
    #pan $02
    #note $35, LEN_8
    #ret

; entry 03: sound 00 (command 04), track 3, YM2151 channel 3, priority 03; make musictrace: started
; (1), its statements read
snd_00_3
    #patch patch_10
    #pan $01
    #rest LEN_4
    #rest LEN_4
    #rest LEN_4
    #note $36, LEN_8
    #pan $02
    #note $36, LEN_8
    #ret

; entry 04: sound 00 (command 04), track 4, YM2151 channel 4, priority 03; make musictrace: started
; (1), its statements read
snd_00_4
    #patch patch_10
    #rest LEN_1
    #pan $01
    #note $38, LEN_8
    #pan $02
    #note $38, LEN_8
    #ret

; entry 05: sound 00 (command 04), track 5, YM2151 channel 5, priority 03; make musictrace: started
; (1), its statements read
snd_00_5
    #patch patch_10
    #rest LEN_1
    #pan $01
    #rest LEN_4
    #note $3A, LEN_8
    #pan $02
    #note $3A, LEN_8
    #ret

; entry 06: sound 00 (command 04), track 6, YM2151 channel 6, priority 03; make musictrace: started
; (1), its statements read
snd_00_6
    #patch patch_10
    #rest LEN_1
    #pan $01
    #rest LEN_4
    #rest LEN_4
    #note $3C, LEN_8
    #pan $02
    #note $3C, LEN_8
    #ret

; entry 07: sound 00 (command 04), track 7, YM2151 channel 7, priority 03; make musictrace: started
; (1), its statements read
snd_00_7
    #patch patch_10
    #rest LEN_1
    #pan $01
    #rest LEN_4
    #rest LEN_4
    #rest LEN_4
    #note $3D, LEN_8
    #pan $02
    #note $3D, LEN_8
    #rest LEN_8
    #patch patch_12
    #lfo patch_12
    #noise patch_12
    #volume $09
snd_00_7_t1
    #note $3D, LEN_1|TIE
    #jump snd_00_7_t1
    #ret                                ; not reached: the stream never gets here

    .cerror * != $6B80, "streams_1.asm must end at $6B7F"
