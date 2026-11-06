; S.T.U.N. Runner (rev 6), JSA II 6502 sound program: 136070-2123.10c, 64 KB, from source.
;
; The file is the 6502's view in two parts (docs/01-hardware.md section 6): file 0000-3FFF are
; four 4 KB pages the 6502 sees one at a time at 3000-3FFF (WRIO bits 7-6), file 4000-FFFF is
; mapped at its own address. The partition, the classification and its evidence are in
; docs/09-sound-program.md. Assembled with 64tass -q -C -b (docs/04-build.md); the .cerror
; guards fail the assembly when a region moves.

    .include "hardware.asm"
    .include "ram.asm"
    .include "data/macros.asm"

* = $0000

; File 0000-3FFF: the four bank pages are zero in this set. No absolute operand refers to
; 3000-3FFF; the power-up self-test adds them into the ROM checksum (4094-40D5: WRIO bits 7-6 =
; 0-3, then checksum_pages over 3000-3FFF), and the dormant ymtimer path selects a page
; (ymtimer_start, 58FA-5905: WRIO bits 7-6 from tbl_65DD+4) before it reads through ymt_ptr, the
; only other code that could read a page.
bank0
    .fill $1000, 0                      ; page 0, at 3000-3FFF when WRIO bits 7-6 = 0
    .cerror * != $1000, "bank 1 misplaced"
bank1
    .fill $1000, 0                      ; page 1
    .cerror * != $2000, "bank 2 misplaced"
bank2
    .fill $1000, 0                      ; page 2
    .cerror * != $3000, "bank 3 misplaced"
bank3
    .fill $1000, 0                      ; page 3
    .cerror * != $4000, "the $4000-$FFFF window misplaced"

; File 4000-FFFF at its own address: code 4000-5DB4, data 5DB5-AC48
    .include "system.asm"
    .include "commands.asm"
    .include "sequencer.asm"
    .include "nmi.asm"
    .include "ymtimer.asm"
    .include "oki.asm"
    .include "io.asm"
    .include "tables.asm"
    .include "data/sounds.asm"
    .include "data/streams_1.asm"
    .include "data/patches_1.asm"
    .include "data/unused_streams.asm"
    .include "data/streams_2.asm"
    .include "data/patches_2.asm"
    .include "lookup.asm"

; No instruction reads this byte: the power-up self-test (4094-40EC) adds every byte of the
; four bank pages and of 4000-FFFF and expects FF (40E4); with this byte the sum is FF.
checksum_adjust
    .byte $92
    .cerror * != $AC49, "checksum_adjust misplaced"

; AC49-FFF9: zero in this set; nothing refers to it.
unused_AC49
    .fill $FFFA - $AC49, 0

; The 6502 vectors
    .cerror * != $FFFA, "vectors misplaced"
vec_nmi
    .word h_nmi                         ; NMI: a command byte from the 68010 (/RDP pending)
vec_reset
    .word reset
vec_irq
    .word h_irq                         ; IRQ: the timed interrupt (~250 Hz) or the YM2151's
    ; the program counter wraps from $FFFF to $0000 after the last byte
    .cerror * != $0000, "6502 image does not end at $FFFF"
