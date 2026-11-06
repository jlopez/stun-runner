; streams_2.asm: 79E3-9EF9, byte streams of the sequencer: sounds 01-0E.
;
; Same conventions as streams_1.asm.

    .cerror * != $79E3, "streams_2.asm must start at $79E3"

; entry 14: sound 03 (command 0D), track 0, YM2151 channel 7, priority 29; make musictrace: started
; (1), its statements read
snd_03_0
    #patch patch_4A
    #tempo $0F5C
    #volume $01
    #rest LEN_4|DOT
    #loop $10
    #note $48, LEN_128|TIE
    #volume_add $02
    #loop_end
    #note $48, LEN_2|TIE
    #loop $0F
    #note $48, LEN_128|TIE
    #volume_add $FE
    #loop_end
    #note $48, LEN_128
    #rest LEN_8
    #rest LEN_4
    #patch patch_26
    #volume $0D
    #velocity $32
    #tempo $1C29
    #note $48, LEN_16|TIE
    #note $42, LEN_16
    #note $3F, LEN_16
    #note $46, LEN_16
    #note $4D, LEN_16
    #loop $07
    #note $3F, LEN_16
    #note $46, LEN_16
    #note $4D, LEN_16
    #volume_add $FA
    #loop_end
    #rest LEN_4
    #ret

; entry 15: sound 03 (command 0D), track 1, YM2151 channel 6, priority 29; make musictrace: started
; (1), its statements read
snd_03_1
    #patch patch_4A
    #tempo $0F5C
    #volume $01
    #rest LEN_2
    #rest LEN_4|DOT
    #loop $10
    #note $46, LEN_128|TIE
    #volume_add $02
    #loop_end
    #note $46, LEN_2|TIE
    #loop $0F
    #note $46, LEN_128|TIE
    #volume_add $FF
    #loop_end
    #note $46, LEN_128
    #rest LEN_8
    #tempo $1D71
    #patch patch_3C
    #rest LEN_4|DOT
    #volume $07
    #loop $07
    #note $3F, LEN_16
    #note $3A, LEN_16
    #note $35, LEN_16
    #volume_add $F9
    #loop_end
    #ret

; entry 16: sound 03 (command 0D), track 2, YM2151 channel 5, priority 29; make musictrace: started
; (1), its statements read
snd_03_2
    #patch patch_55
    #tempo $0F5C
    #volume $01
    #transpose $F4
    #loop $08
    #note $3A, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $1F
    #note $3A, LEN_2|TIE
    #note $3A, LEN_1|TIE
    #loop $0F
    #note $3A, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $3A, LEN_16
    #ret

; entry 17: sound 03 (command 0D), track 3, YM2151 channel 4, priority 29; make musictrace: started
; (1), its statements read
snd_03_3
    #patch patch_55
    #tempo $0F5C
    #volume $01
    #transpose $F4
    #loop $08
    #note $38, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $1F
    #note $38, LEN_2|TIE
    #note $38, LEN_1|TIE
    #loop $0F
    #note $38, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $38, LEN_16
    #ret
    #ret                                ; not reached: the stream never gets here

; entry 18: sound 03 (command 0D), track 4, YM2151 channel 3, priority 29; make musictrace: started
; (1), its statements read
snd_03_4
    #patch patch_4C
    #tempo $0F5C
    #velocity $3F
    #volume $0A
    #loop $02
    #rest LEN_6
    #note $19, LEN_12
    #note $19, LEN_12
    #note $19, LEN_12
    #rest LEN_12
    #rest LEN_6
    #note $19, LEN_12
    #rest LEN_6
    #note $19, LEN_12
    #note $19, LEN_12
    #note $19, LEN_12
    #rest LEN_12
    #loop_end
    #ret

; entry 1F: sound 05 (command 10), track 0, YM2151 channel 0, priority 2A; make musictrace: started
; (1), its statements read
snd_05_0
    #patch patch_43
    #tempo $10A4
    #transpose $FB
    #volume $0A
    #rest LEN_8
    #note $41, LEN_1
    #ret

; entry 20: sound 05 (command 10), track 1, YM2151 channel 1, priority 2A; make musictrace: started
; (1), its statements read
snd_05_1
    #patch patch_44
    #tempo $10A4
    #volume $0A
    #transpose $FB
    #velocity $1E
    #rest LEN_8
    #rest LEN_2
    #note $3F, LEN_2
    #ret

; entry 21: sound 05 (command 10), track 2, YM2151 channel 2, priority 2A; make musictrace: started
; (1), its statements read
snd_05_2
    #patch patch_55
    #tempo $147B
    #transpose $F4
    #volume $03
    #loop $10
    #note $41, LEN_64|TIE
    #volume_add $01
    #loop_end
    #note $41, LEN_2|DOT|TIE
    #loop $0F
    #note $41, LEN_64|TIE
    #volume_add $FF
    #loop_end
    #note $41, LEN_64
    #ret

; entry 22: sound 05 (command 10), track 3, YM2151 channel 3, priority 2A; make musictrace: started
; (1), its statements read
snd_05_3
    #patch patch_55
    #tempo $147B
    #volume $03
    #loop $10
    #note $33, LEN_64|TIE
    #volume_add $01
    #loop_end
    #note $33, LEN_2|TIE
    #note $33, LEN_8|TIE
    #loop $0F
    #note $33, LEN_64|TIE
    #volume_add $FF
    #loop_end
    #note $33, LEN_64
    #ret

; entry 23: sound 05 (command 10), track 4, YM2151 channel 4, priority 2A; make musictrace: started
; (1), its statements read
snd_05_4
    #patch patch_55
    #tempo $147B
    #transpose $0C
    #volume $03
    #loop $10
    #note $25, LEN_64|TIE
    #volume_add $01
    #loop_end
    #note $25, LEN_2|TIE
    #loop $0F
    #note $25, LEN_64|TIE
    #volume_add $FF
    #loop_end
    #note $25, LEN_64
    #ret

; entry 24: sound 05 (command 10), track 5, YM2151 channel 5, priority 2A; make musictrace: started
; (1), its statements read
snd_05_5
    #patch patch_58
    #tempo $1687
    #rest LEN_2
    #rest LEN_8|DOT
    #volume $03
    #loop $04
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $08
    #loop_end
    #loop $05
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $F8
    #loop_end
    #ret

; entry 25: sound 05 (command 10), track 6, YM2151 channel 6, priority 2A; make musictrace: started
; (1), its statements read
snd_05_6
    #patch patch_26
    #tempo $1687
    #rest LEN_2
    #rest LEN_8|DOT
    #rest LEN_16
    #volume $03
    #transpose $02
    #loop $04
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $08
    #loop_end
    #loop $05
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $F8
    #loop_end
    #ret

; entry 26: sound 05 (command 10), track 7, YM2151 channel 7, priority 2A; make musictrace: started
; (1), its statements read
snd_05_7
    #patch patch_26
    #tempo $1687
    #transpose $04
    #rest LEN_2
    #rest LEN_8|DOT
    #rest LEN_8
    #volume $03
    #loop $04
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $08
    #loop_end
    #loop $05
    #note $38, LEN_32
    #note $3A, LEN_32
    #note $3C, LEN_32
    #volume_add $F8
    #loop_end
    #ret

; entry 27: sound 06 (command 11), track 0, YM2151 channel 2, priority 28; make musictrace: started
; (1), its statements read
snd_06_0
    #patch patch_1A
    #volume $02
    #tempo $199A
    #rest LEN_1
    #loop $08
    #note $31, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $08
    #note $31, LEN_16|TIE
    #loop_end
    #loop $08
    #note $33, LEN_16|TIE
    #loop_end
    #loop $08
    #note $33, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #volume $01
    #loop $08
    #note $34, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #volume_add $FE
    #loop_end
    #note $34, LEN_32
    #ret

; entry 28: sound 06 (command 11), track 1, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_06_1
    #patch patch_3E
    #tempo $199A
    #rest LEN_1
    #velocity $7F
    #volume $03
    #loop $10
    #note $19, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #loop_end
    #loop $20
    #note $19, LEN_32|DOT
    #rest LEN_64
    #loop_end
    #loop $10
    #note $19, LEN_32|DOT
    #rest LEN_64
    #volume_add $FE
    #loop_end
    #ret

; entry 29: sound 06 (command 11), track 2, YM2151 channel 1, priority 28; make musictrace: started
; (1), its statements read
snd_06_2
    #patch patch_35
    #tempo $199A
    #velocity $6E
    #volume $01
    #loop $1F
    #note $19, LEN_32|TIE
    #volume_add $01
    #loop_end
    #loop $10
    #note $19, LEN_32|TIE
    #volume_add $FF
    #loop_end
    #note $19, LEN_32
    #ret

; entry 2A: sound 06 (command 11), track 3, YM2151 channel 4, priority 28; make musictrace: started
; (1), its statements read
snd_06_3
    #patch patch_29
    #tempo $199A
    #volume $09
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #fade 1, $E2
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #ret

; entry 2B: sound 06 (command 11), track 4, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_06_4
    #patch patch_2A
    #transpose $0C
    #tempo $199A
    #velocity $3F
    #volume $09
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #fade 1, $E2
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #ret

; entry 2C: sound 06 (command 11), track 5, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_06_5
    #patch patch_29
    #tempo $199A
    #volume $07
    #rest LEN_16
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #fade 1, $E2
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #rest LEN_8
    #note $19, LEN_8
    #ret

; entry 2D: sound 06 (command 11), track 6, YM2151 channel 7, priority 28; make musictrace: started
; (1), its statements read
snd_06_6
    #patch patch_1A
    #volume $02
    #fine_tune $0A
    #tempo $199A
    #rest LEN_1
    #rest LEN_16
    #loop $08
    #note $31, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $08
    #note $31, LEN_16|TIE
    #loop_end
    #loop $08
    #note $33, LEN_16|TIE
    #loop_end
    #loop $08
    #note $33, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #volume $01
    #loop $08
    #note $34, LEN_16|TIE
    #volume_add $02
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #loop_end
    #loop $08
    #note $34, LEN_16|TIE
    #volume_add $FE
    #loop_end
    #note $34, LEN_32
    #ret

; entry 19: sound 04 (command 0F), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (2), its statements read
; entry 2E: sound 07 (command 12), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (1), its statements read
snd_04_0
    #tempo $2148
    #rest LEN_2
    #patch patch_2D
    #volume $0A
    #note $41, LEN_4|DOT
    #rest LEN_4
    #note $44, LEN_8
    #rest LEN_8
    #note $46, LEN_2
    #fade 1, $DC
    #note $46, LEN_2
    #ret

; entry 1A: sound 04 (command 0F), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (2), its statements read
; entry 2F: sound 07 (command 12), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (1), its statements read
snd_04_1
    #tempo $2148
    #rest LEN_8
    #patch patch_2D
    #volume $0A
    #note $3A, LEN_16|ACCENT_1|TIE
    #note $38, LEN_16
    #note $3A, LEN_16|ACCENT_1|TIE
    #note $38, LEN_16
    #note $36, LEN_16|TIE
    #note $38, LEN_16
    #loop $0F
    #note $3F, LEN_128|TIE
    #bend $08
    #loop_end
    #note $3F, LEN_128|TIE
    #note $3F, LEN_4
    #rest LEN_4
    #fine_tune $00
    #transpose $00
    #loop $0F
    #note $42, LEN_128|TIE
    #bend $08
    #loop_end
    #note $42, LEN_128
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #loop $0F
    #note $44, LEN_128|TIE
    #bend $08
    #loop_end
    #note $44, LEN_4|TIE
    #fade 1, $DC
    #note $44, LEN_2|DOT
    #fine_tune $00
    #transpose $00
    #ret

; entry 1B: sound 04 (command 0F), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (2), its statements read
; entry 30: sound 07 (command 12), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (1), its statements read
snd_04_2
    #tempo $2148
    #patch patch_32
    #rest LEN_8
    #velocity $14
    #volume $0A
    #transpose $0C
    #note $22, LEN_16|ACCENT_1|TIE
    #note $20, LEN_16
    #note $22, LEN_16|ACCENT_1|TIE
    #note $20, LEN_16
    #note $1E, LEN_16|TIE
    #note $20, LEN_16
    #patch patch_46
    #volume $07
    #note $22, LEN_8|ACCENT_1|TIE
    #note $20, LEN_16|DOT
    #rest LEN_32
    #note $1D, LEN_8
    #note $20, LEN_4|ACCENT_1
    #note $1B, LEN_16|DOT
    #rest LEN_32
    #note $19, LEN_16|DOT
    #rest LEN_32
    #fade 1, $EC
    #note $22, LEN_8|ACCENT_1|TIE
    #note $22, LEN_1
    #ret

; entry 1C: sound 04 (command 0F), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (2), its statements read
; entry 31: sound 07 (command 12), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_04_3
    #tempo $2148
    #velocity $D8
    #rest LEN_8
    #patch patch_2F
    #volume $09
    #note $22, LEN_16|ACCENT_1|TIE
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $22, LEN_16|ACCENT_1|TIE
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $1E, LEN_16|TIE
    #note $20, LEN_16
    #volume $07
    #note $22, LEN_8|ACCENT_1|TIE
    #note $20, LEN_16|DOT
    #rest LEN_32
    #note $1D, LEN_8
    #note $20, LEN_4|ACCENT_1
    #note $1B, LEN_16|DOT
    #rest LEN_32
    #note $19, LEN_16|DOT
    #rest LEN_32
    #fade 1, $EC
    #note $22, LEN_8|ACCENT_1|TIE
    #note $22, LEN_2
    #ret

; entry 1D: sound 04 (command 0F), track 4, YM2151 channel 5, priority 28; make musictrace: started
; (2), its statements read
; entry 32: sound 07 (command 12), track 4, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_04_4
    #tempo $2148
    #patch patch_5A
    #rest LEN_8
    #note $31, LEN_16
    #note $31, LEN_16
    #note $2F, LEN_16
    #note $2F, LEN_16
    #note $2D, LEN_16
    #note $2D, LEN_16
    #loop $02
    #patch patch_4F
    #note $31, LEN_8
    #patch patch_1C
    #note $27, LEN_8
    #loop_end
    #patch patch_1C
    #note $27, LEN_8|ACCENT_2
    #note $27, LEN_8|ACCENT_2
    #patch patch_4F
    #note $31, LEN_8
    #patch patch_5A
    #note $31, LEN_16
    #note $31, LEN_16
    #note $2F, LEN_16
    #note $2F, LEN_16
    #note $2D, LEN_16
    #note $2D, LEN_16
    #patch patch_4F
    #note $31, LEN_8
    #patch patch_1C
    #note $27, LEN_8|ACCENT_2
    #ret

; entry 1E: sound 04 (command 0F), track 5, YM2151 channel 6, priority 28; make musictrace: started
; (2), its statements read
; entry 33: sound 07 (command 12), track 5, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_04_5
    #tempo $2148
    #patch patch_36
    #volume $07
    #loop $08
    #note $3D, LEN_16
    #volume_add $04
    #loop_end
    #patch patch_23
    #volume $0D
    #note $3D, LEN_1
    #rest LEN_4
    #note $3D, LEN_2
    #ret

; entry 34: sound 08 (command 14), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (1), its statements read
snd_08_0
    #tempo $1EB8
    #rest LEN_4
    #patch patch_46
    #volume $09
    #fade 1, $F2
    #note $31, LEN_1
    #patch patch_5D
    #velocity $5F
    #volume $02
    #fade 1, $24
    #note $42, LEN_1|TIE
    #note $42, LEN_2
    #tempo $2666
    #patch patch_48
    #volume $0A
    #note $49, LEN_8|ACCENT_1
    #loop $05
    #volume_add $FA
    #note $49, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #patch patch_5D
    #volume $0A
    #rest LEN_2|DOT
    #note $44, LEN_8|ACCENT_2|DOT
    #rest LEN_16
    #rest LEN_2
    #rest LEN_8
    #note $44, LEN_8|ACCENT_2
    #rest LEN_2
    #note $44, LEN_8|ACCENT_2
    #rest LEN_4|DOT
    #note $44, LEN_8|ACCENT_2
    #rest LEN_4
    #note $44, LEN_8|ACCENT_2
    #rest LEN_8
    #note $44, LEN_8|ACCENT_2
    #note $44, LEN_8|GATE_HALF
    #note $44, LEN_8|GATE_HALF
    #volume $07
    #fade 1, $0A
    #note $40, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $40, LEN_8|GATE_HALF
    #note $40, LEN_8|GATE_HALF
    #rest LEN_8
    #note $40, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $40, LEN_8|GATE_HALF
    #rest LEN_8
    #note $40, LEN_8|GATE_HALF
    #patch patch_5D
    #volume $09
    #note $41, LEN_8
    #rest LEN_8
    #note $44, LEN_8|ACCENT_1|DOT
    #rest LEN_16
    #note $45, LEN_2|ACCENT_1
    #patch patch_42
    #tempo $11EC
    #volume $09
    #loop $02
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #note $55, LEN_32|TIE
    #note $57, LEN_32|TIE
    #loop_end
    #ret

; entry 35: sound 08 (command 14), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (1), its statements read
snd_08_1
    #tempo $1EB8
    #patch patch_5D
    #velocity $4B
    #volume $01
    #rest LEN_1
    #fade 1, $30
    #note $3D, LEN_4|TIE
    #note $3D, LEN_1|TIE
    #note $3D, LEN_2
    #tempo $2666
    #patch patch_48
    #volume $0A
    #note $42, LEN_8|ACCENT_1
    #loop $05
    #volume_add $FA
    #note $42, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #patch patch_5D
    #rest LEN_2|DOT
    #volume $0A
    #note $3D, LEN_8|ACCENT_2|DOT
    #rest LEN_16
    #rest LEN_2
    #rest LEN_8
    #note $3D, LEN_8|ACCENT_2
    #rest LEN_2
    #note $3D, LEN_8|ACCENT_2
    #rest LEN_4|DOT
    #note $3D, LEN_8|ACCENT_2
    #rest LEN_4
    #note $3D, LEN_8|ACCENT_2
    #rest LEN_8
    #note $3D, LEN_8|ACCENT_2
    #note $3D, LEN_8|GATE_HALF
    #note $3D, LEN_8|GATE_HALF
    #volume $07
    #fade 1, $0A
    #note $3B, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $3B, LEN_8|GATE_HALF
    #note $3B, LEN_8|GATE_HALF
    #rest LEN_8
    #note $3B, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $3B, LEN_8|GATE_HALF
    #rest LEN_8
    #note $3B, LEN_8|GATE_HALF
    #patch patch_5D
    #volume $09
    #note $3C, LEN_8
    #rest LEN_8
    #note $3D, LEN_8|ACCENT_1|DOT
    #rest LEN_16
    #note $40, LEN_2|ACCENT_1
    #tempo $11EC
    #patch patch_48
    #volume $05
    #velocity $4B
    #rest LEN_4
    #note $49, LEN_4
    #note $4A, LEN_4
    #note $33, LEN_4|ACCENT_1
    #note $4E, LEN_4
    #note $4A, LEN_4
    #note $49, LEN_2|DOT
    #ret

; entry 36: sound 08 (command 14), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (1), its statements read
snd_08_2
    #tempo $1EB8
    #patch patch_5D
    #velocity $32
    #volume $01
    #rest LEN_4
    #rest LEN_2
    #fade 1, $30
    #note $38, LEN_2|TIE
    #note $38, LEN_2
    #volume $03
    #fade 1, $28
    #note $47, LEN_2|TIE
    #note $47, LEN_2
    #tempo $2666
    #patch patch_48
    #volume $0A
    #note $3B, LEN_8|ACCENT_1
    #loop $05
    #volume_add $FA
    #note $3B, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #patch patch_5E
    #volume $09
    #rest LEN_2|DOT
    #note $36, LEN_8|ACCENT_1|DOT
    #rest LEN_16
    #rest LEN_2
    #rest LEN_8
    #note $36, LEN_8|ACCENT_2
    #rest LEN_2
    #note $36, LEN_8|ACCENT_2
    #rest LEN_4|DOT
    #note $36, LEN_8|ACCENT_2
    #rest LEN_4
    #note $36, LEN_8|ACCENT_2
    #rest LEN_8
    #note $36, LEN_8|ACCENT_2
    #note $36, LEN_8|GATE_HALF
    #note $36, LEN_8|GATE_HALF
    #volume $09
    #fade 1, $0A
    #note $36, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $36, LEN_8|GATE_HALF
    #note $36, LEN_8|GATE_HALF
    #rest LEN_8
    #note $36, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $36, LEN_8|GATE_HALF
    #rest LEN_8
    #note $36, LEN_8|GATE_HALF
    #patch patch_5D
    #volume $09
    #note $36, LEN_8
    #rest LEN_8
    #note $36, LEN_8|ACCENT_1|DOT
    #rest LEN_16
    #note $3B, LEN_2|ACCENT_1
    #tempo $11EC
    #patch patch_5D
    #volume $07
    #velocity $50
    #rest LEN_4
    #note $3D, LEN_4
    #note $3E, LEN_4|DOT
    #rest LEN_8
    #note $42, LEN_4
    #note $3E, LEN_4
    #note $41, LEN_2|DOT
    #ret

; entry 37: sound 08 (command 14), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_08_3
    #tempo $1EB8
    #patch patch_5E
    #volume $01
    #velocity $4B
    #rest LEN_4
    #rest LEN_4
    #fade 1, $18
    #note $31, LEN_2|DOT|TIE
    #note $31, LEN_1|TIE
    #note $31, LEN_2
    #tempo $2666
    #note $34, LEN_8|ACCENT_1
    #rest LEN_8
    #rest LEN_4
    #rest LEN_1
    #volume $07
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #note $31, LEN_8|GATE_HALF
    #rest LEN_4
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #rest LEN_8
    #note $31, LEN_16|DOT
    #rest LEN_32
    #note $31, LEN_8|GATE_HALF
    #rest LEN_8
    #patch patch_42
    #volume $09
    #note $45, LEN_32|TIE
    #note $46, LEN_32|TIE
    #note $47, LEN_32|TIE
    #note $48, LEN_32|TIE
    #note $49, LEN_32|TIE
    #note $4A, LEN_32|TIE
    #note $4B, LEN_32|TIE
    #note $4C, LEN_32
    #note $4D, LEN_32|TIE
    #note $4E, LEN_32|TIE
    #note $4F, LEN_32|TIE
    #note $50, LEN_32|TIE
    #note $51, LEN_32|TIE
    #note $52, LEN_32|TIE
    #note $53, LEN_32|TIE
    #note $54, LEN_32
    #tempo $11EC
    #patch patch_5D
    #transpose $F4
    #volume $07
    #velocity $4B
    #rest LEN_4
    #note $47, LEN_4
    #note $46, LEN_4|DOT
    #rest LEN_8
    #note $47, LEN_4
    #note $45, LEN_4
    #note $42, LEN_2|DOT
    #ret

; entry 38: sound 08 (command 14), track 4, YM2151 channel 4, priority 28; make musictrace: started
; (1), its statements read
snd_08_4
    #tempo $1EB8
    #patch patch_5E
    #velocity $4B
    #rest LEN_4
    #volume $01
    #fade 1, $24
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1|TIE
    #note $2C, LEN_2
    #tempo $2666
    #note $2D, LEN_8|ACCENT_1
    #rest LEN_8
    #rest LEN_4
    #rest LEN_1
    #volume $07
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_4
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #rest LEN_8
    #note $2F, LEN_16|DOT
    #rest LEN_32
    #note $2F, LEN_8|GATE_HALF
    #rest LEN_8
    #rest LEN_2
    #tempo $11EC
    #patch patch_5E
    #transpose $F4
    #velocity $4B
    #volume $07
    #rest LEN_4
    #note $42, LEN_4
    #note $45, LEN_4|DOT
    #rest LEN_8
    #note $40, LEN_4
    #note $3C, LEN_4
    #note $3F, LEN_2|DOT
    #ret

; entry 39: sound 08 (command 14), track 5, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_08_5
    #tempo $1EB8
    #patch patch_23
    #volume $01
    #loop $10
    #note $3D, LEN_64
    #volume_add $03
    #loop_end
    #note $3D, LEN_1|ACCENT_2
    #patch patch_5D
    #velocity $4B
    #volume $02
    #rest LEN_4
    #fade 1, $23
    #note $44, LEN_2|DOT|TIE
    #note $44, LEN_2
    #tempo $2666
    #patch patch_23
    #note $3D, LEN_4
    #patch patch_2B
    #velocity $7F
    #note $22, LEN_4
    #note $22, LEN_4
    #rest LEN_8
    #note $22, LEN_4
    #note $22, LEN_4
    #rest LEN_8
    #patch patch_23
    #note $3D, LEN_2|DOT
    #patch patch_2B
    #velocity $7F
    #note $2E, LEN_8
    #patch patch_23
    #note $3D, LEN_8
    #rest LEN_4|DOT
    #patch patch_2B
    #velocity $7F
    #note $2E, LEN_8
    #patch patch_23
    #note $3D, LEN_8
    #rest LEN_4
    #patch patch_2B
    #velocity $7F
    #note $2E, LEN_8
    #patch patch_23
    #note $3D, LEN_8
    #rest LEN_8
    #patch patch_2B
    #velocity $7F
    #note $2E, LEN_8
    #patch patch_23
    #note $3D, LEN_8
    #patch patch_2B
    #velocity $7F
    #note $2E, LEN_8
    #patch patch_23
    #note $3D, LEN_8
    #patch patch_2B
    #note $35, LEN_16
    #note $35, LEN_16
    #note $35, LEN_16
    #note $35, LEN_16
    #patch patch_23
    #note $3D, LEN_4|DOT
    #patch patch_2B
    #note $2E, LEN_8|ACCENT_2
    #patch patch_23
    #note $3D, LEN_4
    #patch patch_2B
    #note $2E, LEN_4|ACCENT_2
    #patch patch_23
    #rest LEN_2
    #note $3D, LEN_2
    #tempo $11EC
    #note $3D, LEN_2|DOT
    #note $3D, LEN_4
    #volume $05
    #loop $20
    #note $3D, LEN_64
    #volume_add $01
    #loop_end
    #note $3D, LEN_2
    #volume $03
    #loop $10
    #note $3D, LEN_64
    #volume_add $02
    #loop_end
    #ret

; entry 3A: sound 08 (command 14), track 6, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_08_6
    #tempo $1EB8
    #patch patch_5E
    #velocity $4B
    #volume $07
    #rest LEN_4
    #note $25, LEN_1|TIE
    #note $25, LEN_1|TIE
    #note $25, LEN_2
    #tempo $2666
    #loop $04
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #note $23, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $23, LEN_16|DOT
    #rest LEN_32
    #note $17, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $17, LEN_16|DOT
    #rest LEN_32
    #tempo $11EC
    #volume $07
    #note $19, LEN_4
    #note $1E, LEN_4
    #note $1C, LEN_4
    #note $1B, LEN_4|ACCENT_1
    #note $1F, LEN_4
    #note $20, LEN_1
    #ret

; entry 3B: sound 08 (command 14), track 7, YM2151 channel 7, priority 28; make musictrace: started
; (1), its statements read
snd_08_7
    #tempo $1EB8
    #patch patch_61
    #velocity $4B
    #volume $07
    #rest LEN_4
    #note $25, LEN_1|TIE
    #note $25, LEN_1|TIE
    #note $25, LEN_2
    #tempo $2666
    #loop $04
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #note $1E, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #note $23, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $23, LEN_16|DOT
    #rest LEN_32
    #note $17, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #note $17, LEN_16|DOT
    #rest LEN_32
    #tempo $11EC
    #volume $07
    #note $19, LEN_4
    #note $1E, LEN_4
    #note $1C, LEN_4
    #note $1B, LEN_4|ACCENT_1
    #note $1F, LEN_4
    #note $20, LEN_1
    #ret

; entry 3C: sound 09 (command 16), track 0, YM2151 channel 4, priority 37; make musictrace: started
; (1), its statements read
snd_09_0
    #var_load R_GLOBAL+$19
    #jump_table
    .word snd_09_4_t1, snd_09_4_t5, snd_09_4_t9, snd_09_4_t13
    #ret                                ; not reached: the stream never gets here

; entry 3D: sound 09 (command 16), track 1, YM2151 channel 5, priority 37; make musictrace: started
; (1), its statements read
snd_09_1
    #var_load R_GLOBAL+$19
    #jump_table
    .word snd_09_4_t2, snd_09_4_t6, snd_09_4_t10, snd_09_4_t14
    #ret                                ; not reached: the stream never gets here

; entry 3E: sound 09 (command 16), track 2, YM2151 channel 6, priority 37; make musictrace: started
; (1), its statements read
snd_09_2
    #var_load R_GLOBAL+$19
    #jump_table
    .word snd_09_4_t3, snd_09_4_t7, snd_09_4_t11, snd_09_4_t15
    #ret                                ; not reached: the stream never gets here

; entry 3F: sound 09 (command 16), track 3, YM2151 channel 7, priority 37; make musictrace: started
; (1), its statements read
snd_09_3
    #var_load R_RANDOM
    #var_and $03
    #var_store R_GLOBAL+$19
    #var_load R_GLOBAL+$19
    #jump_table
    .word snd_09_4_t4, snd_09_4_t8, snd_09_4_t12, snd_09_4_t16
    #ret                                ; not reached: the stream never gets here

; entry 40: sound 09 (command 16), track 4, YM2151 channel 2, priority 37; make musictrace: started
; (1), its statements read
snd_09_4
    #var_and $00
    #var_add $01
    #var_store R_GLOBAL+$12
    #tempo $3333
    #patch patch_2B
    #velocity $7F
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_8
    #note $2F, LEN_8
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_51
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
snd_09_4_t1
    #tempo $3333
    #transpose $00
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2F, LEN_1
    #ret
snd_09_4_t2
    #tempo $3333
    #transpose $00
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2A, LEN_1
    #ret
snd_09_4_t3
    #tempo $3333
    #transpose $00
    #patch patch_46
    #velocity $4B
    #note $31, LEN_32|DOT
    #rest LEN_64
    #note $31, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $31, LEN_1
    #ret
snd_09_4_t4
    #tempo $3333
    #transpose $00
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $20, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $20, LEN_1
    #ret
snd_09_4_t5
    #tempo $3333
    #transpose $02
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2F, LEN_1
    #ret
snd_09_4_t6
    #tempo $3333
    #transpose $02
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2A, LEN_1
    #ret
snd_09_4_t7
    #tempo $3333
    #transpose $02
    #patch patch_46
    #velocity $4B
    #note $31, LEN_32|DOT
    #rest LEN_64
    #note $31, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $31, LEN_1
    #ret
snd_09_4_t8
    #tempo $3333
    #transpose $02
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $20, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $20, LEN_1
    #ret
snd_09_4_t9
    #tempo $3333
    #transpose $04
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2F, LEN_1
    #ret
snd_09_4_t10
    #tempo $3333
    #transpose $04
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2A, LEN_1
    #ret
snd_09_4_t11
    #tempo $3333
    #transpose $04
    #patch patch_46
    #velocity $4B
    #note $31, LEN_32|DOT
    #rest LEN_64
    #note $31, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $31, LEN_1
    #ret
snd_09_4_t12
    #tempo $3333
    #transpose $04
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $20, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $20, LEN_1
    #ret
snd_09_4_t13
    #tempo $3333
    #transpose $06
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2F, LEN_1
    #ret
snd_09_4_t14
    #tempo $3333
    #transpose $06
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #note $2A, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $2A, LEN_1
    #ret
snd_09_4_t15
    #tempo $3333
    #transpose $06
    #patch patch_46
    #velocity $4B
    #note $31, LEN_32|DOT
    #rest LEN_64
    #note $31, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $31, LEN_1
    #ret
snd_09_4_t16
    #tempo $3333
    #transpose $06
    #patch patch_59
    #velocity $4B
    #volume $0D
    #note $20, LEN_32|DOT
    #rest LEN_64
    #note $20, LEN_32|DOT
    #rest LEN_64
    #fade 1, $EC
    #note $20, LEN_1
    #ret
    #ret                                ; not reached: the stream never gets here

; entry 41: sound 0A (command 17), track 0, YM2151 channel 0, priority 29; make musictrace: started
; (1), its statements read
snd_0A_0
    #tempo $1EB8
    #patch patch_48
    #velocity $46
    #volume $07
    #note $3F, LEN_16
    #note $44, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #note $46, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #note $46, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #fade 1, $E8
    #note $48, LEN_1|ACCENT_1
    #patch patch_52
    #volume $01
    #fade 1, $14
    #note $54, LEN_1|TIE
    #note $54, LEN_1|TIE
    #note $54, LEN_1|TIE
    #fade 1, $E8
    #note $54, LEN_1
    #ret

; entry 42: sound 0A (command 17), track 1, YM2151 channel 1, priority 29; make musictrace: started
; (1), its statements read
snd_0A_1
    #tempo $1EB8
    #patch patch_42
    #fine_tune $0A
    #transpose $0C
    #velocity $32
    #volume $09
    #note $3F, LEN_16
    #note $44, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #note $46, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #note $46, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $3F, LEN_16
    #fade 1, $E8
    #note $48, LEN_1|ACCENT_1
    #transpose $00
    #patch patch_52
    #volume $01
    #fade 1, $14
    #note $54, LEN_1|TIE
    #note $54, LEN_1|TIE
    #note $54, LEN_1|TIE
    #fade 1, $E8
    #note $54, LEN_1
    #ret

; entry 43: sound 0A (command 17), track 2, YM2151 channel 2, priority 29; make musictrace: started
; (1), its statements read
snd_0A_2
    #tempo $1EB8
    #patch patch_5F
    #velocity $46
    #volume $07
    #note $33, LEN_16
    #note $3D, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #note $3D, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #note $3D, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #patch patch_48
    #velocity $64
    #volume $05
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_8|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #note $3F, LEN_16|GATE_HALF
    #loop_end
    #fade 1, $EC
    #note $3F, LEN_1
    #ret

; entry 44: sound 0A (command 17), track 3, YM2151 channel 3, priority 29; make musictrace: started
; (1), its statements read
snd_0A_3
    #tempo $1EB8
    #patch patch_5F
    #volume $07
    #velocity $46
    #note $33, LEN_16
    #note $36, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #note $38, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #note $38, LEN_2|DOT
    #rest LEN_8|DOT
    #note $33, LEN_16
    #patch patch_48
    #velocity $64
    #volume $05
    #loop $02
    #note $38, LEN_8
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_8|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #note $38, LEN_16|GATE_HALF
    #loop_end
    #fade 1, $EC
    #note $38, LEN_1
    #ret

; entry 45: sound 0A (command 17), track 4, YM2151 channel 4, priority 29; make musictrace: started
; (1), its statements read
snd_0A_4
    #tempo $1EB8
    #patch patch_61
    #velocity $32
    #volume $07
    #transpose $0C
    #note $27, LEN_16
    #note $23, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #note $1D, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #note $1B, LEN_2|ACCENT_1|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #fade 1, $E8
    #note $14, LEN_1|ACCENT_1
    #ret

; entry 46: sound 0A (command 17), track 5, YM2151 channel 5, priority 29; make musictrace: started
; (1), its statements read
snd_0A_5
    #tempo $1EB8
    #patch patch_61
    #velocity $32
    #fine_tune $0A
    #volume $07
    #transpose $18
    #note $27, LEN_16
    #note $23, LEN_2|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #note $1D, LEN_2|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #note $1B, LEN_2|DOT
    #rest LEN_8|DOT
    #note $27, LEN_16
    #note $14, LEN_2|DOT
    #rest LEN_8
    #transpose $00
    #patch patch_46
    #volume $09
    #note $33, LEN_16|GATE_HALF
    #note $33, LEN_16|GATE_HALF
    #fade 2, $F4
    #note $33, LEN_1|TIE
    #note $33, LEN_2|DOT|TIE
    #note $33, LEN_8
    #volume $0A
    #note $2C, LEN_16|GATE_HALF
    #note $2C, LEN_16|GATE_HALF
    #note $2C, LEN_1
    #fade 1, $E8
    #note $2C, LEN_1
    #ret

; entry 47: sound 0A (command 17), track 6, YM2151 channel 6, priority 29; make musictrace: started
; (1), its statements read
snd_0A_6
    #tempo $1EB8
    #patch patch_2B
    #note $31, LEN_16
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_4|ACCENT_2
    #rest LEN_8|DOT
    #note $31, LEN_16|ACCENT_2
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_4|ACCENT_2
    #note $31, LEN_8|ACCENT_2|DOT
    #note $31, LEN_16|ACCENT_2
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_8|ACCENT_2|DOT
    #note $31, LEN_16|ACCENT_2
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #note $3D, LEN_4
    #patch patch_2B
    #note $31, LEN_8
    #note $31, LEN_8
    #note $31, LEN_8
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_4|ACCENT_2
    #patch patch_23
    #note $3D, LEN_2
    #patch patch_2B
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_8|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #patch patch_23
    #note $3D, LEN_1
    #ret

; entry 48: sound 0A (command 17), track 7, YM2151 channel 7, priority 29; make musictrace: started
; (1), its statements read
snd_0A_7
    #tempo $1EB8
    #patch patch_40
    #velocity $5A
    #volume $05
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #note $14, LEN_1|TIE
    #fade 1, $EC
    #note $14, LEN_1
    #ret

; entry 49: sound 0B (command 18), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (2), its statements read
snd_0B_0
    #tempo $2666
    #patch patch_2D
    #volume $0A
    #velocity $32
    #note $46, LEN_4
    #rest LEN_8
    #note $49, LEN_4
    #rest LEN_8
    #note $4B, LEN_4|TIE
    #fade 2, $F6
    #note $4B, LEN_1
    #note $4B, LEN_1
    #rest LEN_2
    #rest LEN_4|DOT
    #patch patch_46
    #fine_tune $05
    #volume $09
    #loop $10
    #note $2E, LEN_128|TIE
    #bend $14
    #loop_end
    #fade 1, $E8
    #note $2E, LEN_2|DOT
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #volume $0A
    #loop $10
    #note $33, LEN_128|TIE
    #bend $1C
    #loop_end
    #note $33, LEN_1|TIE
    #note $33, LEN_2|DOT
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #volume $0A
    #loop $10
    #note $33, LEN_128|TIE
    #bend $1C
    #loop_end
    #note $33, LEN_2|DOT
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #patch patch_59
    #velocity $64
    #volume $01
    #fade 1, $18
    #note $25, LEN_8|TIE
    #note $25, LEN_1|TIE
    #fade 1, $E8
    #note $25, LEN_1
snd_0B_0_t1
    #patch patch_2D
    #velocity $28
    #volume $09
    #note $38, LEN_1
    #patch patch_60
    #volume $09
    #velocity $4B
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $38, LEN_4
    #rest LEN_8
    #note $38, LEN_8|DOT
    #rest LEN_16
    #note $41, LEN_8|TIE
    #fade 1, $E6
    #note $41, LEN_1
    #volume $09
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $38, LEN_4
    #rest LEN_8
    #note $38, LEN_8|DOT
    #rest LEN_16
    #note $43, LEN_8|TIE
    #fade 1, $E6
    #note $43, LEN_1
    #patch patch_5F
    #velocity $32
    #volume $09
    #note $44, LEN_4
    #note $3A, LEN_4
    #note $3C, LEN_4
    #note $3E, LEN_4
    #note $46, LEN_4
    #note $3C, LEN_4
    #note $3E, LEN_4
    #note $3F, LEN_4
    #note $48, LEN_2|ACCENT_1
    #note $46, LEN_2|ACCENT_1
    #note $3D, LEN_2|ACCENT_1
    #note $3F, LEN_2|ACCENT_1
    #fade 1, $EC
    #note $3F, LEN_1
    #patch patch_40
    #volume $01
    #fade 1, $15
    #note $43, LEN_1|TIE
    #note $43, LEN_1
    #volume $05
    #note $41, LEN_4|DOT
    #note $3F, LEN_8|TIE
    #note $3F, LEN_2|TIE
    #note $3F, LEN_1
    #note $46, LEN_1|TIE
    #note $46, LEN_1
    #note $49, LEN_4|DOT
    #note $44, LEN_8|TIE
    #note $44, LEN_2|TIE
    #note $44, LEN_1
    #note $4B, LEN_4|DOT
    #note $46, LEN_8|TIE
    #note $46, LEN_2
    #note $4D, LEN_4|DOT
    #note $46, LEN_8|TIE
    #note $46, LEN_2
    #note $4B, LEN_4|DOT
    #note $46, LEN_8|TIE
    #note $46, LEN_2|TIE
    #note $46, LEN_1|TIE
    #note $46, LEN_1
    #transpose $00
    #jump snd_0B_0_t1
    #ret                                ; not reached: the stream never gets here

; entry 4A: sound 0B (command 18), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (2), its statements read
snd_0B_1
    #tempo $2666
    #patch patch_2D
    #volume $0A
    #velocity $32
    #fine_tune $0A
    #loop $10
    #note $44, LEN_128|TIE
    #bend $08
    #loop_end
    #note $44, LEN_8
    #rest LEN_8
    #transpose $00
    #fine_tune $0A
    #loop $10
    #note $47, LEN_128|TIE
    #bend $08
    #loop_end
    #note $47, LEN_8
    #rest LEN_8
    #transpose $00
    #fine_tune $0A
    #loop $10
    #note $49, LEN_128|TIE
    #bend $08
    #loop_end
    #note $49, LEN_8|TIE
    #fade 2, $F6
    #note $49, LEN_1
    #note $49, LEN_1
    #fine_tune $00
    #transpose $00
    #rest LEN_2
    #rest LEN_4|DOT
    #patch patch_46
    #volume $09
    #bend $FB
    #loop $10
    #note $2E, LEN_128|TIE
    #bend $14
    #loop_end
    #fade 1, $E8
    #note $2E, LEN_2|DOT
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #patch patch_59
    #loop $02
    #volume $01
    #velocity $5F
    #fade 1, $1E
    #note $22, LEN_1|TIE
    #fade 1, $E2
    #note $22, LEN_1
    #loop_end
    #volume $07
    #rest LEN_1
    #note $22, LEN_8|ACCENT_2
snd_0B_1_t1
    #note $27, LEN_1|TIE
    #note $27, LEN_4
    #rest LEN_8
    #patch patch_60
    #volume $09
    #velocity $4B
    #note $35, LEN_16|DOT
    #rest LEN_32
    #note $35, LEN_8|DOT
    #rest LEN_16
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $3A, LEN_8|TIE
    #fade 1, $E6
    #note $3A, LEN_1
    #volume $09
    #rest LEN_4|DOT
    #note $35, LEN_16|DOT
    #rest LEN_32
    #note $35, LEN_8|DOT
    #rest LEN_16
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $3C, LEN_8|TIE
    #fade 1, $E6
    #note $3C, LEN_1
    #patch patch_5F
    #velocity $32
    #volume $09
    #rest LEN_8
    #note $3F, LEN_4
    #note $41, LEN_4
    #note $43, LEN_4
    #note $45, LEN_8|TIE
    #note $45, LEN_8
    #note $41, LEN_4
    #note $43, LEN_4
    #note $45, LEN_4
    #note $46, LEN_8|TIE
    #note $46, LEN_8|DOT
    #rest LEN_16
    #note $41, LEN_2|ACCENT_1
    #note $3F, LEN_4|ACCENT_1
    #note $3F, LEN_4|ACCENT_1
    #note $44, LEN_2|ACCENT_1
    #note $46, LEN_4|ACCENT_1
    #note $46, LEN_1|TIE
    #note $46, LEN_1|TIE
    #note $46, LEN_1
    #patch patch_40
    #volume $05
    #note $44, LEN_1|TIE
    #note $44, LEN_1
    #note $43, LEN_1|TIE
    #note $43, LEN_1
    #note $41, LEN_1|TIE
    #note $41, LEN_1
    #note $43, LEN_1
    #note $44, LEN_1
    #note $43, LEN_1
    #note $44, LEN_1|TIE
    #note $44, LEN_2|DOT
    #rest LEN_8
    #transpose $00
    #patch patch_59
    #volume $07
    #note $22, LEN_8|ACCENT_2
    #jump snd_0B_1_t1
    #ret                                ; not reached: the stream never gets here

; entry 4B: sound 0B (command 18), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (2), its statements read
snd_0B_2
    #tempo $2666
    #patch patch_5F
    #velocity $32
    #volume $09
    #rest LEN_8
    #note $3F, LEN_16|DOT
    #rest LEN_32
    #note $38, LEN_4
    #rest LEN_8
    #note $44, LEN_4|DOT
    #patch patch_2D
    #transpose $F4
    #velocity $0A
    #volume $01
    #rest LEN_32
    #fade 1, $1A
    #loop $07
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $07
snd_0B_2_t1
    #loop $05
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $F9
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #transpose_add $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #transpose_add $05
    #loop $05
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $07
    #loop $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #volume $09
    #loop $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #loop $03
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $02
    #loop $02
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_16
    #note $44, LEN_16
    #note $44, LEN_8
    #note $44, LEN_8
    #note $44, LEN_8
    #loop_end
    #transpose_add $FE
    #jump snd_0B_2_t1
    #ret                                ; not reached: the stream never gets here

; entry 4C: sound 0B (command 18), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (2), its statements read
snd_0B_3
    #tempo $2666
    #patch patch_5F
    #velocity $32
    #volume $09
    #rest LEN_8
    #note $3A, LEN_16|DOT
    #rest LEN_32
    #note $33, LEN_4
    #rest LEN_8
    #note $3F, LEN_4|DOT
    #patch patch_2D
    #transpose $F4
    #velocity $0A
    #volume $01
    #rest LEN_64|DOT
    #fade 1, $1A
    #loop $07
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $07
snd_0B_3_t1
    #loop $05
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $F9
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #transpose_add $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #transpose_add $05
    #loop $05
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $07
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #volume $09
    #transpose_add $02
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $FE
    #loop $03
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $05
    #loop $02
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_16
    #note $3F, LEN_16
    #note $3F, LEN_8
    #note $3F, LEN_8
    #note $3F, LEN_8
    #loop_end
    #transpose_add $FB
    #jump snd_0B_3_t1
    #ret                                ; not reached: the stream never gets here

; entry 4D: sound 0B (command 18), track 4, YM2151 channel 4, priority 28; make musictrace: started
; (2), its statements read
snd_0B_4
    #tempo $2666
    #patch patch_5E
    #velocity $32
    #volume $07
    #rest LEN_8
    #note $33, LEN_16|DOT
    #rest LEN_32
    #note $2C, LEN_4
    #rest LEN_8
    #note $2E, LEN_4|ACCENT_1|DOT
    #patch patch_2D
    #transpose $F4
    #velocity $0A
    #volume $01
    #rest LEN_64
    #fade 1, $1A
    #loop $07
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $07
snd_0B_4_t1
    #loop $05
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $F9
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #transpose_add $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #transpose_add $05
    #loop $05
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $07
    #loop $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #volume $09
    #transpose_add $03
    #loop $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $FD
    #loop $03
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $07
    #loop $02
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_16
    #note $3A, LEN_16
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3A, LEN_8
    #loop_end
    #transpose_add $F9
    #jump snd_0B_4_t1
    #ret                                ; not reached: the stream never gets here

; entry 4E: sound 0B (command 18), track 5, YM2151 channel 5, priority 28; make musictrace: started
; (2), its statements read
snd_0B_5
    #tempo $2666
    #patch patch_46
    #volume $09
    #fade 1, $F1
    #note $33, LEN_2|DOT
    #patch patch_23
    #volume $0A
    #note $3D, LEN_4
    #patch patch_2D
    #transpose $F4
    #velocity $0A
    #volume $01
    #fade 1, $1A
    #loop $07
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $07
snd_0B_5_t1
    #loop $05
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $F9
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #transpose_add $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #transpose_add $05
    #loop $05
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $F9
    #loop $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $07
    #loop $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #volume $09
    #transpose_add $FE
    #loop $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $02
    #loop $03
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $FB
    #loop $02
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_16
    #note $33, LEN_16
    #note $33, LEN_8
    #note $33, LEN_8
    #note $33, LEN_8
    #loop_end
    #transpose_add $05
    #jump snd_0B_5_t1
    #ret                                ; not reached: the stream never gets here

; entry 4F: sound 0B (command 18), track 6, YM2151 channel 6, priority 28; make musictrace: started
; (2), its statements read
snd_0B_6
    #tempo $2666
    #patch patch_5A
    #velocity $7F
    #note $25, LEN_8
    #patch patch_4F
    #volume $0D
    #note $31, LEN_8
    #patch patch_5A
    #note $31, LEN_8
    #patch patch_23
    #volume $0D
    #note $3D, LEN_4
    #patch patch_4F
    #note $31, LEN_8
    #patch patch_59
    #velocity $64
    #volume $09
    #fade 1, $EC
    #note $1B, LEN_4|TIE
    #note $1B, LEN_1
    #patch patch_38
    #volume $01
    #loop $10
    #note $31, LEN_16
    #volume_add $02
    #loop_end
    #loop $30
    #call snd_0B_7_sub1
    #loop_end
    #patch patch_4F
    #volume $0A
    #note $25, LEN_8
    #note $31, LEN_8
    #note $31, LEN_8|DOT
    #note $31, LEN_16
    #rest LEN_16
    #note $31, LEN_16
    #rest LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
snd_0B_6_t1
    #loop $50
    #call snd_0B_7_sub2
    #loop_end
    #patch patch_23
    #volume $0A
    #note $3D, LEN_1
    #rest LEN_1
    #rest LEN_1
    #patch patch_5A
    #note $25, LEN_8
    #note $25, LEN_8
    #note $25, LEN_8
    #rest LEN_8
    #note $25, LEN_8
    #rest LEN_8
    #note $25, LEN_8
    #note $25, LEN_8
    #rest LEN_1
    #rest LEN_1
    #patch patch_23
    #volume $09
    #note $3D, LEN_1
    #patch patch_5A
    #note $25, LEN_8
    #note $25, LEN_8
    #note $25, LEN_8
    #rest LEN_8
    #note $25, LEN_8
    #rest LEN_8
    #note $25, LEN_8
    #note $25, LEN_8
    #patch patch_23
    #volume $0A
    #note $3D, LEN_2|DOT
    #patch patch_5A
    #note $31, LEN_8
    #note $31, LEN_8
    #patch patch_23
    #volume $0A
    #note $3D, LEN_2|DOT
    #patch patch_5A
    #note $31, LEN_8
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #volume $0A
    #note $3D, LEN_2
    #rest LEN_4
    #volume $03
    #loop $08
    #note $3D, LEN_32
    #volume_add $03
    #loop_end
    #note $3D, LEN_1
    #patch patch_4F
    #volume $0A
    #rest LEN_8
    #note $31, LEN_8
    #note $31, LEN_8|DOT
    #note $31, LEN_16
    #rest LEN_16
    #note $31, LEN_16
    #rest LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #jump snd_0B_6_t1
    #ret                                ; not reached: the stream never gets here

; entry 50: sound 0B (command 18), track 7, YM2151 channel 7, priority 28; make musictrace: started
; (2), its statements read
snd_0B_7
    #tempo $2666
    #patch patch_46
    #volume $0A
    #velocity $1E
    #rest LEN_2|DOT
    #fade 3, $F8, 5
    #note $27, LEN_4|ACCENT_1
    #note $27, LEN_1|TIE
    #note $27, LEN_1
    #velocity $70
    #volume $0A
    #rest LEN_2|DOT
    #rest LEN_8
    #loop $02
    #call snd_0B_7_sub3
    #note $33, LEN_1|ACCENT_1|TIE
    #note $33, LEN_2|DOT
    #rest LEN_8
    #loop_end
    #volume $0A
    #note $2C, LEN_8|TIE
    #note $2C, LEN_1|TIE
    #note $2C, LEN_2|DOT
    #rest LEN_8
snd_0B_7_t1
    #volume $0A
    #call snd_0B_7_sub3
    #note $33, LEN_1
    #rest LEN_1
    #patch patch_59
    #velocity $64
    #volume $05
    #loop $04
    #note $2E, LEN_8|DOT
    #rest LEN_16
    #volume_add $FC
    #loop_end
    #patch patch_46
    #volume $09
    #note $33, LEN_1
    #patch patch_59
    #velocity $64
    #volume $05
    #loop $03
    #note $30, LEN_8|DOT
    #rest LEN_16
    #volume_add $FC
    #loop_end
    #note $24, LEN_8
    #patch patch_46
    #volume $09
    #fade 1, $EC
    #note $2C, LEN_8|TIE
    #note $2C, LEN_2|DOT
    #rest LEN_8
    #volume $09
    #fade 3, $FA, 3
    #note $2E, LEN_8|TIE
    #note $2E, LEN_1|TIE
    #note $2E, LEN_1|TIE
    #note $2E, LEN_2|DOT
    #rest LEN_8
    #volume $0A
    #call snd_0B_7_sub3
    #fade 2, $F6
    #note $33, LEN_1|TIE
    #note $33, LEN_1
    #rest LEN_1
    #rest LEN_1
    #patch patch_5F
    #velocity $32
    #volume $09
    #note $33, LEN_8
    #note $33, LEN_8
    #note $38, LEN_8|TIE
    #note $35, LEN_8
    #note $35, LEN_8
    #note $38, LEN_8
    #note $33, LEN_8
    #note $3A, LEN_8|TIE
    #fade 1, $EC
    #note $3A, LEN_1|TIE
    #note $3A, LEN_1
    #rest LEN_1
    #volume $09
    #note $38, LEN_8
    #note $38, LEN_8
    #note $3D, LEN_8|TIE
    #note $3A, LEN_8
    #note $3A, LEN_8
    #note $3D, LEN_8
    #note $38, LEN_8
    #note $3F, LEN_8|TIE
    #note $3F, LEN_1
    #patch patch_46
    #volume $09
    #note $2C, LEN_2|DOT
    #rest LEN_8
    #note $33, LEN_32|DOT
    #rest LEN_64
    #note $33, LEN_16
    #note $33, LEN_2|DOT
    #rest LEN_8
    #note $33, LEN_16|DOT
    #rest LEN_32
    #fade 1, $EC
    #note $2E, LEN_1|TIE
    #note $2E, LEN_2|DOT
    #rest LEN_8
    #jump snd_0B_7_t1
    #ret                                ; not reached: the stream never gets here
snd_0B_7_sub1
    #var_load R_RANDOM
    #var_and $03
    #jump_table
    .word snd_0B_7_t2, snd_0B_7_t3, snd_0B_7_t4, snd_0B_7_t5
snd_0B_7_t2
    #patch patch_38
    #volume $0A
    #note $31, LEN_16
    #note $31, LEN_16
    #ret
snd_0B_7_t3
    #patch patch_38
    #volume $0A
    #note $31, LEN_8
    #ret
snd_0B_7_t4
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #ret
snd_0B_7_t5
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #ret
snd_0B_7_sub2
    #var_load R_RANDOM
    #var_and $03
    #jump_table
    .word snd_0B_7_t6, snd_0B_7_t7, snd_0B_7_t8, snd_0B_7_t9
snd_0B_7_t6
    #patch patch_38
    #volume $0A
    #note $31, LEN_16
    #note $31, LEN_16
    #ret
snd_0B_7_t7
    #patch patch_4F
    #volume $0A
    #note $31, LEN_8
    #ret
snd_0B_7_t8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #ret
snd_0B_7_t9
    #patch patch_5A
    #note $25, LEN_8|ACCENT_2
    #ret
snd_0B_7_sub3
    #loop $10
    #note $2E, LEN_128|TIE
    #bend $14
    #loop_end
    #fine_tune $00
    #transpose $00
    #ret

; entry 0D: sound 02 (command 0C), track 0, YM2151 channel 7, priority 29; make musictrace: started
; (1), its statements read
snd_02_0
    #tempo $1EB8
    #rest LEN_8
    #patch patch_32
    #volume $07
    #transpose $0C
    #rest LEN_2
    #note $41, LEN_8|DOT
    #rest LEN_16
    #rest LEN_4
    #rest LEN_8
    #note $41, LEN_8
    #rest LEN_8
    #note $44, LEN_4|DOT
    #rest LEN_4
    #note $41, LEN_8|GATE_HALF
    #note $41, LEN_8|GATE_HALF
    #rest LEN_8|DOT
    #note $41, LEN_16|TIE
    #note $41, LEN_8
    #note $3F, LEN_16|ACCENT_1
    #rest LEN_16
    #rest LEN_4
    #note $41, LEN_16|TIE
    #note $3F, LEN_16
    #note $3C, LEN_16|TIE
    #note $3A, LEN_16
    #note $38, LEN_4
    #note $3A, LEN_4
    #note $38, LEN_4
    #fade 1, $E2
    #note $35, LEN_1
    #ret

; entry 0E: sound 02 (command 0C), track 1, YM2151 channel 6, priority 29; make musictrace: started
; (1), its statements read
snd_02_1
    #tempo $1EB8
    #rest LEN_8
    #patch patch_32
    #volume $09
    #transpose $0C
    #rest LEN_2
    #loop $08
    #note $3F, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3F, LEN_8
    #rest LEN_16
    #rest LEN_4
    #fine_tune $0A
    #transpose $0C
    #rest LEN_8
    #loop $08
    #note $3F, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3F, LEN_16
    #rest LEN_8
    #fine_tune $00
    #transpose $0C
    #loop $08
    #note $42, LEN_128|TIE
    #bend $10
    #loop_end
    #note $42, LEN_16|TIE
    #note $42, LEN_4
    #rest LEN_4
    #fine_tune $0A
    #transpose $0C
    #note $41, LEN_8|GATE_HALF
    #note $41, LEN_8|GATE_HALF
    #rest LEN_8|DOT
    #loop $08
    #note $3F, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3F, LEN_8
    #note $3D, LEN_16|ACCENT_1
    #rest LEN_16
    #rest LEN_4
    #fine_tune $00
    #transpose $0C
    #note $41, LEN_16|TIE
    #note $3F, LEN_16
    #note $3C, LEN_16|TIE
    #note $3A, LEN_16
    #note $38, LEN_4
    #loop $08
    #note $38, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3A, LEN_8|DOT
    #fine_tune $00
    #transpose $0C
    #note $38, LEN_4
    #fade 1, $E2
    #note $30, LEN_1
    #ret

; entry 0F: sound 02 (command 0C), track 2, YM2151 channel 5, priority 29; make musictrace: started
; (1), its statements read
snd_02_2
    #tempo $1EB8
    #rest LEN_8
    #patch patch_2D
    #loop $02
    #volume $0A
    #rest LEN_4
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #rest LEN_16
    #rest LEN_4
    #rest LEN_8
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #volume $09
    #note $35, LEN_16|ACCENT_1
    #rest LEN_8|DOT
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $3C, LEN_16|ACCENT_1|TIE
    #note $3C, LEN_4|ACCENT_1
    #rest LEN_8
    #note $35, LEN_32|DOT
    #rest LEN_64
    #note $35, LEN_32|DOT
    #rest LEN_64
    #loop_end
    #ret

; entry 10: sound 02 (command 0C), track 3, YM2151 channel 4, priority 29; make musictrace: started
; (1), its statements read
snd_02_3
    #tempo $1EB8
    #rest LEN_8
    #patch patch_2D
    #loop $02
    #volume $0A
    #rest LEN_4
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #rest LEN_16
    #rest LEN_4
    #rest LEN_8
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #volume $09
    #note $30, LEN_16|ACCENT_1
    #rest LEN_8|DOT
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $3A, LEN_16|ACCENT_1|TIE
    #note $3A, LEN_4|ACCENT_1
    #rest LEN_8
    #note $30, LEN_32|DOT
    #rest LEN_64
    #note $30, LEN_32|DOT
    #rest LEN_64
    #loop_end
    #ret

; entry 11: sound 02 (command 0C), track 4, YM2151 channel 3, priority 29; make musictrace: started
; (1), its statements read
snd_02_4
    #tempo $1EB8
    #patch patch_46
    #transpose $0C
    #volume $09
    #note $29, LEN_32|DOT
    #rest LEN_64
    #note $29, LEN_32|DOT
    #rest LEN_64
    #fade 1, $E1
    #note $29, LEN_1
    #rest LEN_1
    #volume $09
    #fade 1, $E1
    #note $29, LEN_1
    #rest LEN_2
    #volume $09
    #note $2E, LEN_4|DOT
    #note $29, LEN_32|DOT
    #rest LEN_64
    #note $29, LEN_32|DOT
    #rest LEN_64
    #note $29, LEN_1
    #ret

; entry 12: sound 02 (command 0C), track 5, YM2151 channel 2, priority 29; make musictrace: started
; (1), its statements read
snd_02_5
    #tempo $1EB8
    #rest LEN_8
    #loop $04
    #patch patch_5A
    #note $25, LEN_16|ACCENT_2
    #patch patch_38
    #volume $0D
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_4F
    #note $31, LEN_8|ACCENT_2
    #patch patch_5A
    #note $25, LEN_8|ACCENT_2
    #note $25, LEN_16|ACCENT_2
    #patch patch_38
    #volume $0D
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_5A
    #note $31, LEN_16
    #patch patch_4F
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop_end
    #patch patch_5A
    #note $25, LEN_16|ACCENT_2
    #patch patch_38
    #volume $0D
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_4F
    #note $31, LEN_8|ACCENT_2
    #patch patch_5A
    #note $25, LEN_8|ACCENT_2
    #note $25, LEN_8|ACCENT_2
    #volume $0D
    #patch patch_4F
    #note $3D, LEN_8
    #patch patch_5A
    #note $25, LEN_8|ACCENT_2
    #patch patch_4F
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_8|ACCENT_2
    #ret

; entry 13: sound 02 (command 0C), track 6, YM2151 channel 1, priority 29; make musictrace: started
; (1), its statements read
snd_02_6
    #tempo $1EB8
    #rest LEN_8
    #patch patch_47
    #volume $0A
    #velocity $46
    #loop $02
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_16|GATE_HALF
    #note $20, LEN_8|ACCENT_1
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_16|GATE_HALF
    #note $1B, LEN_8|ACCENT_1|TIE
    #note $1C, LEN_8|ACCENT_1
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_8|GATE_HALF
    #note $20, LEN_8|GATE_HALF
    #note $1D, LEN_16
    #note $24, LEN_8|ACCENT_1
    #note $22, LEN_8|GATE_HALF
    #note $20, LEN_16|TIE
    #note $22, LEN_8
    #note $20, LEN_8
    #loop_end
    #volume $0D
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_8|GATE_HALF
    #note $1D, LEN_32|ACCENT_1|DOT
    #rest LEN_64
    #note $1B, LEN_32|ACCENT_1|DOT
    #rest LEN_64
    #note $1D, LEN_32|ACCENT_1|DOT
    #rest LEN_64
    #note $20, LEN_16|TIE
    #note $20, LEN_8
    #note $1D, LEN_8|GATE_HALF
    #loop $10
    #note $22, LEN_128|ACCENT_1|TIE
    #bend $08
    #loop_end
    #note $22, LEN_8|ACCENT_1
    #fine_tune $00
    #transpose $00
    #note $1D, LEN_8|ACCENT_2
    #ret

; entry 51: sound 0C (command 1A), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (1), its statements read
snd_0C_0
    #tempo $170A
    #rest LEN_4
    #patch patch_1E
    #velocity $64
    #volume $09
    #fade 2, $F1
    #note $4D, LEN_1|TIE
    #note $4D, LEN_1
    #patch patch_27
    #volume $0A
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1
    #patch patch_5F
    #volume $05
    #fade 1, $08
    #note $3D, LEN_8
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_8
    #note $3D, LEN_8
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_8
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_24|GATE_HALF
    #note $3D, LEN_1
    #ret

; entry 52: sound 0C (command 1A), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (1), its statements read
snd_0C_1
    #tempo $170A
    #rest LEN_4
    #patch patch_1E
    #velocity $4B
    #volume $09
    #fade 2, $F1
    #note $49, LEN_1|TIE
    #note $49, LEN_1
    #rest LEN_2
    #patch patch_27
    #volume $0A
    #note $2E, LEN_2|TIE
    #note $2E, LEN_4
    #note $31, LEN_2|DOT
    #patch patch_5F
    #volume $05
    #fade 1, $08
    #note $38, LEN_8
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_8
    #note $38, LEN_8
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_8
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $38, LEN_24|GATE_HALF
    #note $3D, LEN_1
    #ret

; entry 53: sound 0C (command 1A), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (1), its statements read
snd_0C_2
    #tempo $170A
    #rest LEN_4
    #patch patch_5F
    #velocity $4B
    #volume $09
    #fade 2, $F1
    #note $44, LEN_1|TIE
    #note $44, LEN_1
    #rest LEN_1
    #patch patch_27
    #volume $0A
    #note $30, LEN_1
    #patch patch_5F
    #volume $05
    #fade 1, $08
    #note $35, LEN_8
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_8
    #note $35, LEN_8
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_8
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_24|GATE_HALF
    #note $35, LEN_1
    #ret

; entry 54: sound 0C (command 1A), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_0C_3
    #tempo $170A
    #rest LEN_4
    #patch patch_5E
    #velocity $4B
    #volume $09
    #fade 2, $F1
    #note $31, LEN_1|TIE
    #note $31, LEN_2|DOT
    #volume $09
    #rest LEN_16
    #note $31, LEN_16|TIE
    #note $30, LEN_16|TIE
    #note $31, LEN_16
    #note $38, LEN_4|ACCENT_1
    #rest LEN_16
    #note $31, LEN_16|TIE
    #note $30, LEN_16|TIE
    #note $31, LEN_16
    #note $3A, LEN_4|ACCENT_1
    #rest LEN_16
    #note $31, LEN_16|TIE
    #note $30, LEN_16|TIE
    #note $31, LEN_16
    #note $3C, LEN_16|ACCENT_1
    #note $31, LEN_16|TIE
    #note $30, LEN_16|TIE
    #note $31, LEN_16
    #note $3D, LEN_2|DOT
    #volume $05
    #fade 1, $08
    #note $31, LEN_8
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_8
    #note $31, LEN_8
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_8
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_24|GATE_HALF
    #note $31, LEN_1
    #ret

; entry 55: sound 0C (command 1A), track 4, YM2151 channel 4, priority 28; make musictrace: started
; (1), its statements read
snd_0C_4
    #tempo $170A
    #rest LEN_4
    #patch patch_5F
    #velocity $4B
    #volume $09
    #fade 2, $F1
    #note $35, LEN_1|TIE
    #note $35, LEN_1
    #volume $09
    #patch patch_27
    #volume $09
    #bend $0A
    #note $2C, LEN_2
    #note $2E, LEN_2
    #note $30, LEN_4
    #note $31, LEN_2|DOT
    #fine_tune $00
    #patch patch_61
    #volume $07
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1
    #ret

; entry 56: sound 0C (command 1A), track 5, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_0C_5
    #tempo $170A
    #rest LEN_4
    #patch patch_61
    #velocity $4B
    #volume $09
    #note $25, LEN_2|DOT|TIE
    #note $25, LEN_8
    #patch patch_1F
    #volume $07
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #note $20, LEN_8
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24
    #note $20, LEN_8
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_24|GATE_HALF
    #note $20, LEN_8
    #patch patch_5F
    #velocity $32
    #volume $09
    #fade 1, $08
    #note $44, LEN_16|TIE
    #note $3D, LEN_16|TIE
    #note $3C, LEN_16|TIE
    #note $3D, LEN_16
    #note $46, LEN_16|ACCENT_1
    #note $3D, LEN_16|TIE
    #note $3C, LEN_16|TIE
    #note $31, LEN_16
    #note $48, LEN_16|ACCENT_1
    #note $3D, LEN_16
    #note $49, LEN_1
    #note $49, LEN_1
    #ret

; entry 57: sound 0C (command 1A), track 6, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_0C_6
    #tempo $170A
    #patch patch_23
    #volume $01
    #loop $10
    #note $3D, LEN_64
    #volume_add $03
    #loop_end
    #note $3D, LEN_1
    #rest LEN_1
    #note $3D, LEN_2
    #note $3D, LEN_2
    #volume $01
    #loop $10
    #note $3D, LEN_64
    #volume_add $03
    #loop_end
    #note $3D, LEN_2|DOT
    #note $3D, LEN_1
    #patch patch_4F
    #note $31, LEN_8
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_8
    #note $31, LEN_8
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_24
    #note $31, LEN_24
    #volume $01
    #loop $10
    #note $31, LEN_64
    #volume_add $03
    #loop_end
    #patch patch_23
    #note $3D, LEN_1
    #ret

; entry 58: sound 0C (command 1A), track 7, YM2151 channel 7, priority 28; make musictrace: started
; (1), its statements read
snd_0C_7
    #tempo $170A
    #rest LEN_4
    #patch patch_3F
    #velocity $4B
    #volume $09
    #note $19, LEN_2|DOT|TIE
    #note $19, LEN_8
    #patch patch_1F
    #volume $09
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_8
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_24|GATE_HALF
    #note $19, LEN_8
    #note $19, LEN_8
    #patch patch_3F
    #volume $07
    #note $19, LEN_1|TIE
    #note $19, LEN_1
    #ret

; entry 59: sound 0D (command 1B), track 0, YM2151 channel 0, priority 28; make musictrace: started
; (1), its statements read
snd_0D_0
    #tempo $1EB8
    #patch patch_54
    #volume $01
    #rest LEN_1
    #rest LEN_1
    #loop $0D
    #note $3E, LEN_16|TIE
    #volume_add $03
    #loop_end
    #note $3E, LEN_16
    #patch patch_5F
    #velocity $32
    #volume $09
    #note $3C, LEN_16|ACCENT_1
    #rest LEN_16
    #note $40, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #loop $06
    #volume_add $F9
    #note $40, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #loop_end
    #rest LEN_8
    #patch patch_34
    #lfo patch_34
    #tempo $1EB8
    #fine_tune $40
    #volume $01
    #oki $5D
    #loop $06
    #note $44, LEN_128|TIE
    #volume_add $05
    #loop_end
    #loop $14
    #note $44, LEN_128
    #loop_end
    #fine_tune $00
    #transpose $00
    #ret

; entry 5A: sound 0D (command 1B), track 1, YM2151 channel 1, priority 28; make musictrace: started
; (1), its statements read
snd_0D_1
    #tempo $1EB8
    #patch patch_54
    #volume $02
    #rest LEN_1
    #rest LEN_2
    #fade 1, $14
    #bend $0A
    #note $39, LEN_2|TIE
    #note $39, LEN_2|DOT|TIE
    #note $39, LEN_8
    #note $3A, LEN_16|ACCENT_1
    #rest LEN_16
    #note $39, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #patch patch_5F
    #velocity $32
    #volume $09
    #loop $06
    #volume_add $F9
    #note $39, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #rest LEN_8
    #patch patch_34
    #lfo patch_34
    #volume $0A
    #tempo $1EB8
    #note $43, LEN_1
    #ret

; entry 5B: sound 0D (command 1B), track 2, YM2151 channel 2, priority 28; make musictrace: started
; (1), its statements read
snd_0D_2
    #tempo $1EB8
    #patch patch_54
    #volume $02
    #rest LEN_1
    #rest LEN_2
    #fade 1, $14
    #note $39, LEN_2|TIE
    #note $39, LEN_2|DOT|TIE
    #note $39, LEN_8
    #rest LEN_8
    #patch patch_48
    #velocity $46
    #volume $09
    #note $4C, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #rest LEN_2
    #rest LEN_4
    #patch patch_34
    #lfo patch_34
    #tempo $1EB8
    #volume $01
    #loop $06
    #note $44, LEN_128|TIE
    #volume_add $05
    #loop_end
    #loop $14
    #note $44, LEN_128
    #loop_end
    #note $44, LEN_2
    #ret

; entry 5C: sound 0D (command 1B), track 3, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_0D_3
    #tempo $1EB8
    #patch patch_54
    #volume $03
    #rest LEN_1
    #fade 1, $14
    #bend $0A
    #note $31, LEN_1|TIE
    #note $31, LEN_2|DOT|TIE
    #note $31, LEN_8
    #rest LEN_8
    #patch patch_48
    #velocity $46
    #volume $09
    #note $45, LEN_16|ACCENT_2|DOT
    #rest LEN_32
    #ret

; entry 5D: sound 0D (command 1B), track 4, YM2151 channel 4, priority 28; make musictrace: started
; (1), its statements read
snd_0D_4
    #tempo $1EB8
    #patch patch_54
    #volume $03
    #rest LEN_1
    #fade 1, $14
    #note $31, LEN_1|TIE
    #note $31, LEN_2|DOT|TIE
    #note $31, LEN_8
    #patch patch_5E
    #velocity $32
    #volume $09
    #note $37, LEN_16|ACCENT_1
    #rest LEN_16
    #note $35, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #loop $06
    #volume_add $FB
    #note $35, LEN_16|DOT
    #rest LEN_32
    #loop_end
    #ret

; entry 5E: sound 0D (command 1B), track 5, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_0D_5
    #tempo $1EB8
    #patch patch_53
    #velocity $78
    #volume $05
    #fade 1, $14
    #note $19, LEN_1|TIE
    #note $19, LEN_1|TIE
    #note $19, LEN_2|DOT|TIE
    #note $19, LEN_8
    #patch patch_5E
    #velocity $32
    #volume $09
    #note $2B, LEN_16|ACCENT_1
    #rest LEN_16
    #tempo $24DD
    #note $25, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #transpose $E8
    #rest LEN_8
    #note $2D, LEN_16|ACCENT_1
    #rest LEN_16
    #rest LEN_8
    #note $2D, LEN_16|ACCENT_1
    #rest LEN_16
    #rest LEN_8
    #rest LEN_8
    #note $2D, LEN_16|ACCENT_1
    #rest LEN_16
    #rest LEN_8
    #note $2D, LEN_16|ACCENT_1
    #rest LEN_16
    #ret

; entry 5F: sound 0D (command 1B), track 6, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_0D_6
    #tempo $1EB8
    #patch patch_53
    #velocity $78
    #volume $05
    #fade 1, $14
    #note $0D, LEN_1|TIE
    #note $0D, LEN_1|TIE
    #note $0D, LEN_2|DOT|TIE
    #note $0D, LEN_8
    #rest LEN_8
    #patch patch_1B
    #velocity $0A
    #tempo $24DD
    #volume $07
    #fade 1, $07
    #transpose $0C
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_8|GATE_HALF
    #ret
    #ret                                ; not reached: the stream never gets here

; entry 60: sound 0D (command 1B), track 7, YM2151 channel 7, priority 28; make musictrace: started
; (1), its statements read
snd_0D_7
    #tempo $1EB8
    #patch patch_40
    #velocity $32
    #volume $05
    #fade 1, $14
    #bend $0A
    #note $0D, LEN_1|TIE
    #note $0D, LEN_1|TIE
    #note $0D, LEN_2|DOT|TIE
    #note $0D, LEN_8
    #rest LEN_8
    #fine_tune $00
    #patch patch_61
    #velocity $0A
    #tempo $24DD
    #volume $09
    #fade 1, $07
    #transpose $0C
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_16|ACCENT_1
    #rest LEN_16
    #note $19, LEN_8|GATE_HALF
    #note $19, LEN_8|GATE_HALF
    #ret

; entry 61: sound 0E (command 1C), track 0, YM2151 channel 3, priority 28; make musictrace: started
; (1), its statements read
snd_0E_0
    #tempo $21CB
    #rest LEN_1
    #rest LEN_1
    #rest LEN_1
    #rest LEN_1
    #patch patch_32
    #velocity $E7
    #volume $09
    #note $3B, LEN_16
    #note $3B, LEN_16
    #note $3B, LEN_16
    #rest LEN_16
    #note $3B, LEN_16
    #rest LEN_8
    #note $3B, LEN_16
    #rest LEN_4
    #transpose $0C
    #bend $0A
    #note $3F, LEN_4|ACCENT_1
    #fine_tune $00
    #transpose $00
    #note $3B, LEN_16
    #note $3B, LEN_16
    #note $3B, LEN_16
    #rest LEN_16
    #note $3B, LEN_16
    #rest LEN_8
    #note $3B, LEN_16
    #transpose $0C
    #fine_tune $0A
    #fade 1, $F0
    #note $3F, LEN_8
    #rest LEN_16
    #note $3D, LEN_16
    #rest LEN_16
    #note $3B, LEN_16|TIE
    #note $3D, LEN_8|GATE_HALF
    #transpose $00
    #fine_tune $00
    #transpose $0C
    #bend $0A
    #note $3D, LEN_4|TIE
    #note $3D, LEN_16
    #rest LEN_16
    #note $3A, LEN_16|TIE
    #note $38, LEN_16|TIE
    #note $3A, LEN_4|DOT
    #rest LEN_8
    #transpose $00
    #fine_tune $00
    #patch patch_51
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

; entry 62: sound 0E (command 1C), track 1, YM2151 channel 4, priority 28; make musictrace: started
; (1), its statements read
snd_0E_1
    #tempo $21CB
    #rest LEN_1
    #rest LEN_2
    #patch patch_59
    #velocity $46
    #volume $01
    #loop $08
    #note $22, LEN_16|GATE_HALF
    #volume_add $04
    #velocity_add $08
    #loop_end
    #velocity $46
    #volume $05
    #loop $04
    #loop $04
    #note $20, LEN_8
    #rest LEN_8
    #loop_end
    #loop_end
    #fade 1, $F0
    #loop $04
    #note $1E, LEN_8
    #rest LEN_8
    #loop_end
    #ret

; entry 63: sound 0E (command 1C), track 2, YM2151 channel 5, priority 28; make musictrace: started
; (1), its statements read
snd_0E_2
    #tempo $21CB
    #rest LEN_1
    #rest LEN_1
    #patch patch_38
    #loop $10
    #note $31, LEN_16
    #loop_end
    #loop $03
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop $02
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop $02
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #volume $07
    #note $3D, LEN_16
    #patch patch_38
    #volume $09
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop $02
    #patch patch_23
    #volume $03
    #note $3D, LEN_16
    #patch patch_38
    #volume $05
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #ret

; entry 64: sound 0E (command 1C), track 3, YM2151 channel 6, priority 28; make musictrace: started
; (1), its statements read
snd_0E_3
    #tempo $21CB
    #patch patch_50
    #volume $09
    #velocity $7F
    #fade 1, $0F
    #rest LEN_2
    #note $2E, LEN_8
    #note $2E, LEN_8
    #note $2E, LEN_8
    #note $2E, LEN_8
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_46
    #volume $0A
    #fade 2, $F6
    #note $2C, LEN_1
    #note $2C, LEN_1
    #patch patch_32
    #volume $09
    #velocity $E7
    #note $38, LEN_16
    #note $38, LEN_16
    #note $38, LEN_16
    #rest LEN_16
    #note $38, LEN_16
    #rest LEN_8
    #note $38, LEN_16
    #rest LEN_4
    #transpose $0C
    #loop $08
    #note $3D, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3D, LEN_8|DOT
    #fine_tune $00
    #transpose $00
    #note $38, LEN_16
    #note $38, LEN_16
    #note $38, LEN_16
    #rest LEN_16
    #note $38, LEN_16
    #rest LEN_8
    #note $38, LEN_16
    #transpose $0C
    #loop $08
    #note $3D, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3D, LEN_8
    #fine_tune $00
    #transpose $0C
    #note $3D, LEN_8
    #note $3B, LEN_16|TIE
    #note $3D, LEN_8
    #transpose $00
    #transpose $0C
    #loop $08
    #note $3B, LEN_128|TIE
    #bend $10
    #loop_end
    #note $3B, LEN_8|DOT
    #note $3B, LEN_16
    #rest LEN_16
    #fine_tune $00
    #transpose $0C
    #note $3A, LEN_16|TIE
    #note $38, LEN_16|TIE
    #note $3A, LEN_4|DOT
    #rest LEN_8
    #transpose $00
    #transpose $0C
    #ret

; entry 65: sound 0E (command 1C), track 4, YM2151 channel 7, priority 28; make musictrace: started
; (1), its statements read
snd_0E_4
    #var_and $00
    #var_add $01
    #var_store R_GLOBAL+$12
    #tempo $21CB
    #tempo $21CB
    #patch patch_38
    #volume $07
    #loop $0E
    #note $31, LEN_16
    #volume_add $03
    #loop_end
    #patch patch_23
    #note $3D, LEN_8
    #loop $04
    #call snd_0E_4_sub1
    #loop_end
    #patch patch_1C
    #velocity $7F
    #volume $09
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $09
    #note $2E, LEN_8
    #patch patch_1C
    #volume $09
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $09
    #note $2E, LEN_8
    #patch patch_5B
    #volume $09
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #patch patch_1C
    #velocity $7F
    #volume $03
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $02
    #note $2E, LEN_8
    #patch patch_1C
    #volume $03
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $02
    #note $2E, LEN_8
    #patch patch_5B
    #volume $03
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #ret
snd_0E_4_sub1
    #patch patch_1C
    #velocity $7F
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $0D
    #note $2E, LEN_8
    #patch patch_1C
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $0D
    #note $2E, LEN_8
    #patch patch_5B
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #ret

unused_stream_13
    #var_load R_RANDOM
    #var_and $7F
    #var_store R_VELOCITY
    #ret

; entry 08: sound 01 (command 0A), track 0, YM2151 channel 7, priority 27; make musictrace: started
; (1), its statements read
snd_01_0
    #tempo $21CB
    #loop $02
    #patch patch_46
    #fine_tune $0A
    #volume $05
    #transpose $00
    #loop $10
    #note $38, LEN_64|TIE
    #volume_add $01
    #loop_end
    #loop $10
    #note $38, LEN_64|TIE
    #bend $F8
    #loop_end
    #loop $0F
    #note $38, LEN_16|TIE
    #volume_add $FE
    #loop_end
    #note $38, LEN_16
    #rest LEN_2
    #transpose $00
    #fine_tune $00
    #fine_tune $0A
    #volume $05
    #loop $10
    #note $3A, LEN_64|TIE
    #volume_add $01
    #loop_end
    #loop $10
    #note $3A, LEN_64|TIE
    #bend $F8
    #loop_end
    #loop $0F
    #note $3A, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $3A, LEN_16
    #rest LEN_2
    #transpose $00
    #fine_tune $00
    #patch patch_3D
    #fine_tune $0A
    #volume $07
    #velocity $32
    #note $3F, LEN_1
    #fine_tune $00
    #fine_tune $0A
    #fade 1, $F1
    #note $3F, LEN_8|DOT
    #rest LEN_16
    #note $3F, LEN_8|DOT
    #rest LEN_16
    #note $3F, LEN_8|DOT
    #rest LEN_16
    #note $3F, LEN_8|DOT
    #rest LEN_16
    #patch patch_4A
    #volume $02
    #loop $08
    #note $3D, LEN_32|TIE
    #volume_add $03
    #loop_end
    #fade 2, $F4
    #note $3D, LEN_2|DOT
    #note $3D, LEN_1
    #patch patch_3D
    #fine_tune $0A
    #volume $07
    #note $3B, LEN_1
    #fine_tune $00
    #fine_tune $0A
    #note $3D, LEN_1
    #fine_tune $00
    #fine_tune $0A
    #note $3F, LEN_1
    #fine_tune $00
    #ret

; entry 09: sound 01 (command 0A), track 1, YM2151 channel 6, priority 27; make musictrace: started
; (1), its statements read
snd_01_1
    #tempo $21CB
    #patch patch_59
    #volume $02
    #loop $02
    #volume $05
    #loop $20
    #note $20, LEN_16|GATE_HALF
    #call snd_01_4_sub1
    #loop_end
    #loop $20
    #note $20, LEN_16|GATE_HALF
    #call snd_01_4_sub1
    #loop_end
    #patch patch_3D
    #volume $07
    #velocity $32
    #loop $08
    #note $3D, LEN_64|TIE
    #bend $10
    #loop_end
    #note $3D, LEN_8|TIE
    #note $3D, LEN_2|DOT
    #fine_tune $00
    #transpose $00
    #loop $02
    #fine_tune $00
    #transpose $00
    #loop $08
    #note $3D, LEN_64|TIE
    #bend $10
    #loop_end
    #note $3D, LEN_16
    #rest LEN_16
    #volume_add $F8
    #loop_end
    #fine_tune $00
    #transpose $00
    #patch patch_4A
    #volume $02
    #velocity $1E
    #loop $08
    #note $3D, LEN_16|TIE
    #volume_add $03
    #loop_end
    #fade 2, $F4
    #note $3D, LEN_1|TIE
    #note $3D, LEN_1
    #patch patch_3D
    #fine_tune $0A
    #volume $07
    #velocity $32
    #loop $08
    #note $3A, LEN_64|TIE
    #bend $08
    #loop_end
    #note $3A, LEN_8|TIE
    #note $3A, LEN_2|DOT
    #fine_tune $00
    #transpose $00
    #loop $08
    #note $3B, LEN_64|TIE
    #bend $10
    #loop_end
    #note $3B, LEN_8|TIE
    #note $3B, LEN_2|DOT
    #fine_tune $00
    #transpose $00
    #loop $08
    #note $3D, LEN_64|TIE
    #bend $10
    #loop_end
    #note $3D, LEN_8|TIE
    #note $3D, LEN_2|DOT
    #fine_tune $00
    #transpose $00
    #ret

; entry 0A: sound 01 (command 0A), track 2, YM2151 channel 5, priority 27; make musictrace: started
; (1), its statements read
snd_01_2
    #tempo $21CB
    #loop $02
    #patch patch_46
    #volume $05
    #loop $10
    #note $38, LEN_64|TIE
    #volume_add $01
    #loop_end
    #loop $10
    #note $38, LEN_64|TIE
    #bend $F8
    #loop_end
    #loop $0F
    #note $38, LEN_16|TIE
    #volume_add $FE
    #loop_end
    #note $38, LEN_16
    #rest LEN_2
    #fine_tune $00
    #transpose $00
    #volume $05
    #loop $10
    #note $3A, LEN_64|TIE
    #volume_add $01
    #loop_end
    #loop $10
    #note $3A, LEN_64|TIE
    #bend $F8
    #loop_end
    #loop $0F
    #note $3A, LEN_16|TIE
    #volume_add $FF
    #loop_end
    #note $3A, LEN_16
    #rest LEN_4
    #rest LEN_8
    #fine_tune $00
    #transpose $00
    #volume $09
    #note $2C, LEN_16
    #note $2C, LEN_16
    #fade 1, $EC
    #note $2C, LEN_1|ACCENT_2
    #volume $09
    #fade 1, $F1
    #note $2C, LEN_1
    #patch patch_38
    #volume $03
    #rest LEN_4
    #loop $0C
    #note $31, LEN_16
    #volume_add $04
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop $02
    #patch patch_23
    #volume $0A
    #note $3D, LEN_16
    #patch patch_38
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #patch patch_46
    #volume $09
    #fade 2, $F6, 4
    #note $2C, LEN_1
    #note $2C, LEN_1
    #patch patch_4A
    #velocity $00
    #volume $02
    #fade 1, $1C
    #rest LEN_4
    #note $33, LEN_4
    #note $31, LEN_8
    #note $33, LEN_4
    #note $31, LEN_8
    #ret

; entry 0B: sound 01 (command 0A), track 3, YM2151 channel 4, priority 27; make musictrace: started
; (1), its statements read
snd_01_3
    #tempo $21CB
    #loop $04
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop_end
    #loop $02
    #patch patch_38
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop_end
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #loop $02
    #patch patch_23
    #volume $0D
    #note $3D, LEN_8
    #patch patch_38
    #note $31, LEN_8
    #loop_end
    #patch patch_23
    #note $3D, LEN_1
    #rest LEN_4
    #patch patch_33
    #volume $02
    #loop $0C
    #note $2C, LEN_16|GATE_HALF
    #volume_add $02
    #velocity_add $0A
    #loop_end
    #loop $0C
    #note $2C, LEN_16|GATE_HALF
    #volume_add $FE
    #velocity_add $F6
    #loop_end
    #rest LEN_4
    #rest LEN_1
    #volume $02
    #loop $08
    #note $2C, LEN_16|GATE_HALF
    #volume_add $02
    #velocity_add $08
    #loop_end
    #loop $08
    #note $2C, LEN_16|GATE_HALF
    #call snd_01_4_sub2
    #loop_end
    #loop $02
    #loop $10
    #note $2C, LEN_16|GATE_HALF
    #call snd_01_4_sub2
    #loop_end
    #loop_end
    #ret

; entry 0C: sound 01 (command 0A), track 4, YM2151 channel 3, priority 27; make musictrace: started
; (1), its statements read
snd_01_4
    #tempo $21CB
    #loop $02
    #call snd_01_4_sub3
    #loop_end
    #call snd_01_4_sub3
    #patch patch_1C
    #velocity $7F
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $0D
    #note $2E, LEN_8
    #patch patch_1C
    #note $2B, LEN_8
    #patch patch_50
    #volume $0D
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #note $2E, LEN_16
    #call snd_01_4_sub3
    #loop $06
    #call snd_01_4_sub3
    #loop_end
    #ret
snd_01_4_sub1
    #var_load R_RANDOM
    #var_and $3F
    #var_store R_VELOCITY
    #ret
snd_01_4_sub2
    #var_load R_RANDOM
    #var_and $FF
    #var_store R_VELOCITY
    #ret
snd_01_4_sub3
    #patch patch_1C
    #velocity $7F
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $0D
    #note $2E, LEN_8
    #patch patch_1C
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #note $2B, LEN_8|ACCENT_2
    #patch patch_50
    #volume $0D
    #note $2E, LEN_8
    #patch patch_5B
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16|ACCENT_2
    #ret

    .cerror * != $9EFA, "streams_2.asm must end at $9EF9"
