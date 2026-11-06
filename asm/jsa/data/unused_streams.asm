; unused_streams.asm: 6FC4-79E2, byte streams no pointer of the program reaches.
;
; No entry of entry_stream, no op of another stream and no instruction points into this range
; (docs/12-sound-music.md section 6); its bytes parse as streams from 6FC4 on, statement after
; statement, with calls, jumps and jump tables that stay inside it and patch ops that name
; records of patches_2.asm. They are structured like the streams that play.

    .cerror * != $6FC4, "unused_streams.asm must start at $6FC4"

unused_stream_03
    #tempo $35C3
    #patch patch_4A
    #velocity $4B
    #volume $01
    #loop $1F
    #note $41, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $41, LEN_32
    #patch patch_63
    #volume $01
    #tempo $2000
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #loop_end
    #loop $3C
    #note $31, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #transpose $00
    #volume $01
    #loop $10
    #call unused_stream_07_sub1
    #note $33, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #loop_end
    #volume $03
    #loop $6C
    #call unused_stream_07_sub1
    #note $33, LEN_32|DOT
    #rest LEN_64
    #loop_end
    #loop $10
    #note $36, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #patch patch_64
    #velocity $32
    #volume $01
    #loop $17
    #note $36, LEN_32|TIE
    #volume_add $01
    #velocity_add $02
    #loop_end
    #note $36, LEN_32
    #transpose $00
    #patch patch_63
    #volume $01
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $20
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #loop_end
    #velocity $00
    #volume $01
    #loop $10
    #note $38, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #velocity_add $08
    #loop_end
    #loop $10
    #note $38, LEN_32|DOT
    #rest LEN_64
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #volume $01
    #loop $10
    #call unused_stream_04_sub3
    #volume_add $01
    #velocity_add $08
    #loop_end
    #loop $10
    #call unused_stream_04_sub3
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #rest LEN_1
    #patch patch_4A
    #velocity $64
    #volume $01
    #loop $1F
    #note $33, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $33, LEN_32
    #patch patch_25
    #transpose $FB
    #loop $06
    #volume $07
    #velocity $4B
    #loop $05
    #note $38, LEN_16|DOT
    #rest LEN_32
    #volume_add $FB
    #velocity_add $EC
    #loop_end
    #loop_end
    #transpose $00
    #patch patch_63
    #volume $01
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #loop_end
    #loop $30
    #note $38, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #loop $0C
    #note $3A, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #loop $30
    #note $38, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #ret

unused_stream_04
    #tempo $35C3
    #patch patch_4A
    #velocity $4B
    #volume $01
    #loop $1F
    #note $3A, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $3A, LEN_32
    #patch patch_63
    #volume $01
    #tempo $2000
    #loop $10
    #call unused_stream_04_sub2
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $10
    #call unused_stream_04_sub2
    #call unused_stream_07_sub1
    #loop_end
    #loop $3C
    #note $38, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #transpose $07
    #volume $01
    #loop $10
    #note $31, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $6C
    #note $31, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #loop $10
    #note $31, LEN_32|DOT
    #rest LEN_64
    #call unused_stream_07_sub1
    #loop_end
    #patch patch_64
    #velocity $32
    #volume $01
    #loop $17
    #note $31, LEN_32|TIE
    #volume_add $01
    #velocity_add $02
    #loop_end
    #note $31, LEN_32
    #transpose $00
    #patch patch_63
    #volume $01
    #loop $10
    #call unused_stream_04_sub2
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $20
    #call unused_stream_04_sub2
    #call unused_stream_07_sub1
    #loop_end
    #velocity $00
    #volume $01
    #loop $10
    #note $33, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #velocity_add $08
    #loop_end
    #loop $10
    #note $33, LEN_32|DOT
    #rest LEN_64
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #loop $10
    #call unused_stream_04_sub4
    #volume_add $01
    #velocity_add $08
    #loop_end
    #loop $10
    #call unused_stream_04_sub4
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #rest LEN_1
    #patch patch_4A
    #velocity $64
    #volume $01
    #loop $1F
    #note $3A, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $3A, LEN_32
    #patch patch_25
    #transpose $FB
    #volume $07
    #velocity $4B
    #rest LEN_4|DOT
    #loop $05
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $FB
    #velocity_add $EC
    #loop_end
    #volume $07
    #velocity $64
    #loop $04
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $FA
    #velocity_add $E7
    #loop_end
    #volume $07
    #velocity $64
    #loop $06
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $FC
    #velocity_add $EC
    #loop_end
    #volume $07
    #velocity $64
    #loop $05
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $FB
    #velocity_add $EC
    #loop_end
    #volume $07
    #velocity $64
    #loop $04
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $FA
    #velocity_add $E7
    #loop_end
    #volume $07
    #velocity $64
    #loop $03
    #note $36, LEN_16|DOT
    #rest LEN_32
    #volume_add $F9
    #velocity_add $E2
    #loop_end
    #transpose $00
    #patch patch_63
    #volume $01
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #volume_add $01
    #loop_end
    #volume $03
    #loop $10
    #call unused_stream_04_sub1
    #call unused_stream_07_sub1
    #loop_end
    #patch patch_4A
    #volume $01
    #loop $10
    #note $38, LEN_32|TIE
    #volume_add $02
    #loop_end
    #loop $0F
    #note $38, LEN_32|TIE
    #volume_add $FE
    #loop_end
    #note $38, LEN_32
    #rest LEN_2
    #volume $01
    #loop $0F
    #note $36, LEN_32|TIE
    #volume_add $03
    #loop_end
    #note $36, LEN_32
    #loop_end
    #patch patch_2D
    #transpose $0F
    #volume $09
    #velocity $46
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FC
    #loop_end
    #patch patch_25
    #volume $07
    #velocity $1E
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #ret

unused_stream_04_sub1
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_04_t1, unused_stream_04_t2

unused_stream_04_t1
    #note $3F, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_t2
    #note $38, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_sub2
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_04_t3, unused_stream_04_t4

unused_stream_04_t3
    #note $3A, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_t4
    #note $33, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_sub3
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_04_t5, unused_stream_04_t6

unused_stream_04_t5
    #note $3A, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_t6
    #note $35, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_sub4
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_04_t7, unused_stream_04_t8

unused_stream_04_t7
    #note $2E, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_04_t8
    #note $33, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_05
    #tempo $35C3
    #patch patch_4A
    #velocity $4B
    #volume $02
    #loop $1F
    #note $38, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $38, LEN_32
    #tempo $2000
    #loop $02
    #var_and $00
    #var_add $10
    #var_store R_GLOBAL+$02
    #loop $08
    #patch patch_23
    #call unused_stream_05_sub1
    #volume_add $05
    #note $3D, LEN_16
    #patch patch_36
    #call unused_stream_05_sub1
    #volume_add $08
    #note $31, LEN_16
    #loop_end
    #rest LEN_2
    #rest LEN_8
    #volume $03
    #loop $06
    #note $31, LEN_16
    #volume_add $07
    #loop_end
    #patch patch_23
    #volume $0A
    #note $3D, LEN_8
    #patch patch_36
    #volume $0D
    #note $31, LEN_8
    #loop $0C
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $03
    #loop $06
    #note $31, LEN_16
    #volume_add $07
    #loop_end
    #loop_end
    #loop $0C
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $03
    #loop $06
    #note $31, LEN_16
    #volume_add $07
    #loop_end
    #loop $04
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #rest LEN_8
    #loop_end
    #loop $02
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #volume $0D
    #loop $08
    #call unused_stream_05_sub2
    #loop_end
    #loop $04
    #call unused_stream_05_sub2
    #volume_add $FA
    #loop_end
    #patch patch_59
    #volume $01
    #velocity $50
    #fade 2, $0C
    #note $20, LEN_1|TIE
    #note $20, LEN_1|TIE
    #fade 2, $F1
    #note $20, LEN_1|TIE
    #note $20, LEN_1
    #velocity $00
    #patch patch_45
    #volume $0A
    #fade 2, $F6
    #note $33, LEN_1|TIE
    #note $33, LEN_1
    #rest LEN_1
    #rest LEN_4|DOT
    #patch patch_36
    #volume $03
    #loop $06
    #note $31, LEN_16
    #volume_add $07
    #loop_end
    #var_and $00
    #var_add $10
    #var_store R_GLOBAL+$02
    #loop $08
    #patch patch_23
    #call unused_stream_05_sub1
    #volume_add $05
    #note $3D, LEN_16
    #patch patch_36
    #call unused_stream_05_sub1
    #volume_add $08
    #note $31, LEN_16
    #loop_end
    #rest LEN_2
    #rest LEN_8
    #volume $03
    #loop $06
    #note $31, LEN_16
    #volume_add $07
    #loop_end
    #loop $0C
    #patch patch_23
    #volume $0A
    #note $3D, LEN_8
    #patch patch_36
    #volume $0D
    #note $31, LEN_8
    #loop_end
    #ret

unused_stream_05_sub1
    #var_and $00
    #var_load R_GLOBAL+$02
    #var_sub $01
    #var_store R_GLOBAL+$02
    #var_shr $01
    #var_store R_VOLUME
    #ret

unused_stream_05_sub2
    #var_load R_RANDOM
    #var_and $03
    #jump_table
    .word unused_stream_05_t1, unused_stream_05_t2, unused_stream_05_t3, unused_stream_05_t4

unused_stream_05_t1
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16
    #note $31, LEN_16
    #rest LEN_16
    #ret

unused_stream_05_t2
    #note $31, LEN_16
    #note $31, LEN_16|ACCENT_2
    #rest LEN_16
    #note $31, LEN_16
    #ret

unused_stream_05_t3
    #note $31, LEN_16
    #rest LEN_16
    #note $31, LEN_16|ACCENT_2
    #note $31, LEN_16
    #ret

unused_stream_05_t4
    #rest LEN_16
    #note $31, LEN_16
    #note $31, LEN_16
    #note $31, LEN_16|ACCENT_2
    #ret

unused_stream_06
    #tempo $35C3
    #patch patch_4A
    #volume $01
    #velocity $4B
    #loop $1F
    #note $33, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $33, LEN_32
    #tempo $2000
    #patch patch_25
    #volume $07
    #velocity $1E
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #rest LEN_4
    #rest LEN_1
    #patch patch_4A
    #volume $01
    #velocity $32
    #loop $08
    #note $38, LEN_16|TIE
    #volume_add $05
    #loop_end
    #loop $07
    #note $38, LEN_16|TIE
    #volume_add $FB
    #loop_end
    #note $38, LEN_16
    #patch patch_2D
    #transpose $0F
    #volume $09
    #velocity $32
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FB
    #loop_end
    #transpose $00
    #patch patch_25
    #volume $07
    #velocity $1E
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #rest LEN_4
    #rest LEN_1
    #rest LEN_2
    #patch patch_4A
    #volume $01
    #velocity $4B
    #loop $07
    #note $36, LEN_16|TIE
    #volume_add $07
    #loop_end
    #note $36, LEN_16
    #patch patch_2D
    #transpose $0F
    #volume $09
    #velocity $46
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #patch patch_59
    #volume $05
    #transpose $F4
    #note $31, LEN_8|ACCENT_1
    #rest LEN_8
    #volume $02
    #loop $07
    #note $31, LEN_8
    #rest LEN_8
    #volume_add $02
    #loop_end
    #loop $06
    #note $33, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #rest LEN_4
    #patch patch_25
    #volume $07
    #velocity $32
    #note $20, LEN_12|ACCENT_1
    #rest LEN_12
    #loop $09
    #note $20, LEN_12
    #rest LEN_12
    #volume_add $FE
    #loop_end
    #rest LEN_12
    #rest LEN_4
    #patch patch_63
    #velocity $00
    #volume $01
    #loop $10
    #note $36, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #velocity_add $08
    #loop_end
    #volume $05
    #loop $10
    #note $36, LEN_32|DOT
    #rest LEN_64
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #volume $01
    #loop $10
    #call unused_stream_06_sub1
    #volume_add $01
    #velocity_add $08
    #loop_end
    #volume $05
    #loop $10
    #call unused_stream_06_sub1
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #patch patch_36
    #volume $03
    #loop $04
    #call unused_stream_05_sub2
    #volume_add $06
    #loop_end
    #loop $10
    #call unused_stream_05_sub2
    #loop_end
    #loop $04
    #call unused_stream_05_sub2
    #volume_add $FA
    #loop_end
    #transpose $00
    #patch patch_4A
    #volume $01
    #velocity $4B
    #loop $17
    #note $33, LEN_32|TIE
    #volume_add $02
    #loop_end
    #note $33, LEN_32
    #patch patch_25
    #volume $07
    #velocity $32
    #note $20, LEN_16|ACCENT_1|DOT
    #rest LEN_32
    #rest LEN_8
    #loop $06
    #note $20, LEN_8
    #rest LEN_8
    #volume_add $FD
    #loop_end
    #rest LEN_4
    #patch patch_59
    #volume $05
    #transpose $F4
    #velocity $6E
    #rest LEN_4
    #note $27, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #rest LEN_4
    #note $27, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #rest LEN_2|DOT
    #note $25, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $25, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #rest LEN_2
    #note $25, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #note $25, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #rest LEN_2
    #note $25, LEN_16|DOT
    #rest LEN_32
    #rest LEN_8
    #patch patch_4A
    #volume $01
    #transpose $00
    #loop $18
    #note $31, LEN_32|TIE
    #volume_add $02
    #loop_end
    #loop $1F
    #note $31, LEN_32|TIE
    #volume_add $FF
    #loop_end
    #note $31, LEN_32
    #ret

unused_stream_06_sub1
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_06_t1, unused_stream_06_t2

unused_stream_06_t1
    #note $31, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_06_t2
    #note $36, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_07
    #tempo $35C3
    #patch patch_4A
    #velocity $4B
    #volume $01
    #loop $1F
    #note $27, LEN_32|TIE
    #volume_add $01
    #loop_end
    #note $27, LEN_32
    #tempo $2000
    #patch patch_45
    #volume $09
    #fade 2, $F6
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1
    #rest LEN_1
    #patch patch_4A
    #volume $01
    #velocity $32
    #loop $08
    #note $33, LEN_16|TIE
    #volume_add $05
    #loop_end
    #loop $07
    #note $33, LEN_16|TIE
    #volume_add $FB
    #loop_end
    #note $33, LEN_16
    #rest LEN_1
    #patch patch_4A
    #volume $01
    #velocity $46
    #loop $0B
    #note $2E, LEN_16|TIE
    #volume_add $05
    #loop_end
    #note $2E, LEN_16
    #patch patch_45
    #volume $09
    #fade 2, $F6
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1
    #patch patch_25
    #volume $05
    #velocity $37
    #loop $02
    #note $20, LEN_8|ACCENT_1
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_8
    #note $1E, LEN_8|ACCENT_1
    #rest LEN_4
    #note $20, LEN_8|ACCENT_1
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_8
    #note $1E, LEN_8
    #rest LEN_4
    #loop_end
    #transpose $00
    #patch patch_45
    #volume $09
    #fade 2, $F6
    #note $33, LEN_1|TIE
    #note $33, LEN_1
    #patch patch_63
    #velocity $00
    #volume $01
    #loop $10
    #note $31, LEN_32|DOT
    #rest LEN_64
    #volume_add $01
    #velocity_add $08
    #loop_end
    #volume $05
    #loop $10
    #note $31, LEN_32|DOT
    #rest LEN_64
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #volume $01
    #loop $10
    #call unused_stream_07_sub2
    #volume_add $01
    #velocity_add $08
    #loop_end
    #volume $05
    #loop $10
    #call unused_stream_07_sub2
    #volume_add $FF
    #velocity_add $F8
    #loop_end
    #rest LEN_1
    #loop $02
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #rest LEN_8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #rest LEN_8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #loop $02
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #rest LEN_8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #rest LEN_8
    #loop $03
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #rest LEN_8
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #rest LEN_8
    #loop $06
    #patch patch_23
    #volume $09
    #note $3D, LEN_8
    #patch patch_36
    #volume $0A
    #note $31, LEN_8
    #loop_end
    #patch patch_45
    #volume $09
    #fade 2, $F6
    #note $2C, LEN_1|TIE
    #note $2C, LEN_1
    #patch patch_25
    #volume $05
    #velocity $37
    #loop $02
    #note $20, LEN_8|ACCENT_1
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_8
    #note $1E, LEN_8|ACCENT_1
    #rest LEN_4
    #note $20, LEN_8|ACCENT_1
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_4
    #note $1E, LEN_8
    #rest LEN_8
    #note $20, LEN_8
    #rest LEN_8
    #note $1E, LEN_8
    #rest LEN_4
    #loop_end
    #ret

unused_stream_07_sub1
    #var_load R_RANDOM
    #var_and $78
    #var_store R_VELOCITY
    #ret

unused_stream_07_sub2
    #var_load R_RANDOM
    #var_and $01
    #jump_table
    .word unused_stream_06_t1, unused_stream_06_t2
    #note $2A, LEN_32|DOT               ; not reached: the stream never gets here
    #rest LEN_64                        ; not reached: the stream never gets here
    #ret                                ; not reached: the stream never gets here

unused_stream_08
    #note $2F, LEN_32|DOT
    #rest LEN_64
    #ret

unused_stream_09
    #patch patch_32
    #volume $07
    #tempo $2148
    #velocity $23
    #transpose $0C
    #note $3A, LEN_2
    #velocity $55
    #patch patch_3A
    #volume $05
    #transpose $F4
    #loop $1F
    #note $3A, LEN_64|TIE
    #bend $F4
    #loop_end
    #note $3A, LEN_64
    #bend $00
    #transpose $00
    #rest LEN_4|DOT
    #rest LEN_16
    #volume $09
    #loop $08
    #note $46, LEN_128|TIE
    #bend $10
    #loop_end
    #bend $00
    #transpose $00
    #velocity $1E
    #note $48, LEN_8
    #rest LEN_16
    #loop $08
    #note $46, LEN_128|TIE
    #bend $10
    #loop_end
    #loop $10
    #note $46, LEN_128|TIE
    #bend $F8
    #loop_end
    #bend $00
    #transpose $00
    #note $46, LEN_8
    #note $44, LEN_8
    #rest LEN_16
    #loop $08
    #note $44, LEN_128|TIE
    #bend $10
    #loop_end
    #bend $00
    #transpose $00
    #note $46, LEN_16
    #note $42, LEN_16
    #note $3C, LEN_16
    #note $3A, LEN_16
    #note $42, LEN_2
    #rest LEN_8
    #note $41, LEN_16|TIE
    #note $42, LEN_16
    #note $41, LEN_8
    #note $3B, LEN_8
    #patch patch_2E
    #velocity $5F
    #volume $09
    #loop $08
    #note $3F, LEN_16|TIE
    #note $34, LEN_16
    #transpose_add $FD
    #loop_end
    #transpose $00
    #patch patch_39
    #volume $09
    #velocity $28
    #loop $10
    #note $27, LEN_128|TIE
    #bend $0C
    #loop_end
    #loop $10
    #note $27, LEN_128|TIE
    #bend $F4
    #loop_end
    #loop $10
    #note $27, LEN_128|TIE
    #bend $18
    #loop_end
    #note $27, LEN_4
    #patch patch_39
    #volume $09
    #loop $30
    #note $33, LEN_128|TIE
    #volume_add $FE
    #bend $EC
    #loop_end
    #note $27, LEN_128
    #ret

unused_stream_10
    #patch patch_30
    #volume $07
    #tempo $2148
    #loop $10
    #note $38, LEN_128|TIE
    #bend $08
    #loop_end
    #note $38, LEN_8|TIE
    #note $38, LEN_2
    #bend $00
    #transpose $00
    #rest LEN_2
    #patch patch_4D
    #tempo $2148
    #volume $01
    #loop $10
    #note $52, LEN_64|TIE
    #volume_add $01
    #loop_end
    #loop $04
    #loop $08
    #note $52, LEN_128|TIE
    #bend $02
    #loop_end
    #loop $08
    #note $52, LEN_128|TIE
    #bend $FE
    #loop_end
    #loop_end
    #loop $1F
    #note $52, LEN_128|TIE
    #volume_add $FE
    #loop_end
    #note $52, LEN_128
    #rest LEN_4
    #patch patch_30
    #volume $07
    #loop $10
    #note $34, LEN_128|TIE
    #bend $08
    #loop_end
    #bend $00
    #transpose $00
    #note $36, LEN_8|TIE
    #note $36, LEN_2
    #ret

unused_stream_11
    #patch patch_3B
    #tempo $2148
    #rest LEN_2
    #volume $01
    #loop $20
    #note $46, LEN_128|TIE
    #volume_add $01
    #loop_end
    #loop $08
    #loop $08
    #note $46, LEN_128|TIE
    #bend $02
    #loop_end
    #loop $08
    #note $46, LEN_128|TIE
    #bend $FE
    #loop_end
    #loop_end
    #loop $1F
    #note $46, LEN_128|TIE
    #volume_add $FE
    #loop_end
    #note $46, LEN_128
    #rest LEN_2
    #volume $03
    #loop $20
    #note $42, LEN_128|TIE
    #volume_add $01
    #loop_end
    #note $42, LEN_2|TIE
    #loop $20
    #note $42, LEN_128|TIE
    #volume_add $FF
    #loop_end
    #ret

unused_stream_12
    #patch patch_45
    #volume $05
    #tempo $2148
    #rest LEN_1
    #note $2C, LEN_1|TIE
    #note $2C, LEN_4
    #note $2A, LEN_1
    #note $2C, LEN_1
    #note $2E, LEN_2|TIE
    #note $2E, LEN_4
    #rest LEN_8
    #note $27, LEN_4|ACCENT_2
    #ret

    .cerror * != $79E3, "unused_streams.asm must end at $79E2"
