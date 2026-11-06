; hardware.asm: the JSA II board's I/O as the 6502 sees it (equates, no bytes).
;
; atarijsa2_map in MAME 0.289 (src/mame/atari/atarijsa.cpp) and docs/09-sound-program.md
; section 1; the names are the IDA names of docs/05-ida.md section 4. The ports 2800-2A06 decode
; with mirror mask 01F9 (bits 0 and 3-8 are don't-cares). This program reads them only through
; the +8 mirrors (the _M names) and writes them at their base addresses.

; YM2151 (atarijsa.cpp: 2000-2001, no mirror). Write: 2000 the register, 2001 its value. Read:
; the status at 2001 (offset 1), bit 7 busy, bit 1 timer B, bit 0 timer A; a read of 2000 returns
; FF in MAME 0.289 (ymfm ym2151::read). The program reads only 2001 (41C5, 502E).
YM2151_REG      = $2000
YM2151_DATA     = $2001

; Read ports
OKI_READ        = $2800                 ; /RDV: OKI M6295 status, bits 3-0 channel 4-1 playing
CMD_FROM_68K    = $2802                 ; /RDP: the 68010's command byte; reading clears the NMI
RDIO            = $2804                 ; /RDIO, below
IRQ_ACK         = $2806                 ; /IRQACK: a read or a write acknowledges the timed IRQ
OKI_READ_M      = OKI_READ + 8          ; mirror of OKI_READ (mask 01F9)
CMD_FROM_68K_M  = CMD_FROM_68K + 8      ; mirror of CMD_FROM_68K (mask 01F9)
RDIO_M          = RDIO + 8              ; mirror of RDIO (mask 01F9)
IRQ_ACK_M       = IRQ_ACK + 8           ; mirror of IRQ_ACK (mask 01F9)

; RDIO (atari_jsa_ii_device::rdio_r, jsa_ii_ioports): bit 7 self-test, 6 NMI state (low: a
; command is waiting), 5 output buffer full (the 68010 has not read RESP_TO_68K yet), 4-3 unused,
; 2-0 coins 3-1. In MAME 0.289 these are IPT_COIN3-1 (jsa_ii_ioports): harddriv.cpp's "stunrun
; has its own coins" override is a commented-out todo, so a coin key sets them as well as the
; main board's coin inputs; how the real board is wired is not established. In MAME 0.289 bit 7 is
; always 0: the port gives the inverted test line (main_test_read_line) and rdio_r inverts it
; again when the line is low, so reset's self-test (bit 7 set) never runs there.

; Write ports
OKI_WRITE       = $2A00                 ; /WRV: an OKI M6295 command byte
RESP_TO_68K     = $2A02                 ; /WRP: the response the 68010 reads at 600000
WRIO            = $2A04                 ; /WRIO, below
MIX             = $2A06                 ; /MIX, below

; WRIO (atari_jsa_oki_base_device::wrio_w): bits 7-6 the page at 3000-3FFF, 5-4 coin counters
; 2 and 1, 3 OKI pin 7 (sample rate), 2 OKI reset (low), 1 OKI bank (JSA III only), 0 YM2151
; reset (low). MAME configures pin 7 high at power-on, but every WRIO write a command can reach
; has bit 3 clear (4005 on), so the M6295 runs with pin 7 low: 3.579545 MHz / 3 / 165, about
; 7,231 Hz, not / 132. The one store that could set it, 5903 (ymtimer.asm), is reached only
; through cmdtype_10, and no command has type 10 (docs/10-adpcm.md section 2).
; MIX (mix_w): bit 5 low-pass filter (not emulated), 4 OKI bank (JSA III only), 3-1 YM2151
; volume 0-7, 0 OKI volume (half or full).

BANK_WINDOW     = $3000                 ; one of the four 4 KB pages of file 0000-3FFF
