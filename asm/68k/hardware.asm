; hardware.asm: the main board's I/O as the 68010 sees it (equates, no bytes).
;
; docs/01-hardware.md section 3 (multisync_68k_map, init_multisync and init_adsp in MAME 0.289's
; harddriv.cpp); each equate is the base address of one row of that table and cites it. The names
; are the IDA names of ida/memory_map.py (IO_68K): one spelling in both places, which
; tools/test_68k_tree.py checks in CI. Where the read and the write of an address are different
; devices, the name is the read's and the comment says what a write does (docs/05 section 2).
; RAM (FF8000-FFFFFF) and ZRAM (FF4000-FF4FFF) variables are not here: they are the one shared
; ram.asm (decision C9, M5c, docs/16-68k-code.md).

; MAINIO, 600000-60FFFF
JSA_PORT	equ	$600000		; docs/01 row 600000-603FFF: JSA II, high byte; read the response, write a command
SOUND_RESET	equ	$604000		; docs/01 rows 604000-607FFF: read resets the sound board; write is the NWR latch (A0-A2 line, A3 value)
WATCHDOG	equ	$608000		; docs/01 row 608000-60BFFF: write kicks the watchdog
PORT0		equ	$60C000		; docs/01 rows 60C000-60FFFF: read port 0 (DIAGN, sync, EOC, self-test, coins, DIP SW1); write acknowledges IRQ 5

; ADSP-2100, 800000-83FFFF
ADSP_PRAM	equ	$800000		; docs/01 row 800000-807FFF: ADSP program RAM, 8K x 24-bit words as 32-bit pairs
ADSP_DRAM	equ	$808000		; docs/01 row 808000-80BFFF: ADSP data RAM, 8K x 16; a write to word 1FFF raises the ADSP IRQ
ADSP_BUFFER	equ	$810000		; docs/01 row 810000-813FFF: ADSP output buffer (SOM), bank from ADSP_CONTROL line 3
ADSP_CONTROL	equ	$818000		; docs/01 row 818000-81801F: write, A0-A2 line, bit 3 value; 0-1 LEDs, 3 bank, 5 /BR, 6 /HALT, 7 reset
ADSP_IRQ_CLEAR	equ	$818060		; docs/01 row 818060-81807F: write clears the ADSP interrupt (level 2)
ADSP_STATUS	equ	$838000		; docs/01 row 838000-83FFFF: read, bit 0 low = ADSP IRQ pending, bit 1 low = XFLAG

; Latches, buttons and ADCs, A00000-BFFFFF
WR0_LATCH	equ	$A00000		; docs/01 row A00000-A7FFFF: write, A0-A2 line, bit 3 value; 1-4 SEL1-SEL4, 6-7 coin counters
BUTTONS		equ	$A80000		; docs/01 rows A80000-AFFFFF: read buttons (0 button 1, 1 button 2, 2 start, 15 sound latch free); write WR1
ADC8_DATA	equ	$B00000		; docs/01 rows B00000-B7FFFF: read, odd byte, the ADC0809 result; write WR2 (unused)
ADC12		equ	$B80000		; docs/01 row B80000-BFFFFF: 12-bit ADC, read the result, write the channel select and start

; GSP and MSP host interfaces, C00000-C07FFF
GSP_HOST	equ	$C00000		; docs/01 row C00000-C03FFF: TMS34010 host interface (HSTADRL/HSTADRH/HSTDATA/HSTCTL, swapped in pairs)
MSP_HOST	equ	$C04000		; docs/01 row C04000-C07FFF: MSP host interface, reads FFFF (no MSP on this board)

; DUART, FF0000-FF001F
DUART		equ	$FF0000		; docs/01 row FF0000-FF001F: MC68681 DUART, high byte
