; hardware.asm: the JSA II board's I/O as the 6502 sees it (no bytes).
;
; atarijsa2_map in MAME 0.289 (src/mame/atari/atarijsa.cpp) and docs/01-hardware.md section 6;
; the names are the IDA names of docs/05-ida.md section 4. The read and write ports 2800-2A06
; decode with mirror mask 01F9 (bits 0 and 3-8 are don't-cares). This program reads them only
; through the +8 mirrors (the _M names) and writes them at their base addresses.

YM2151_REG      = $2000                 ; YM2151 address (write) / status (read: bit 7 busy, 1-0 timer flags)
YM2151_DATA     = $2001                 ; YM2151 data (write) / status (read)

OKI_READ        = $2800                 ; /RDV: OKI M6295 status (bits 3-0: channel 4-1 playing)
CMD_FROM_68K    = $2802                 ; /RDP: the command byte the 68010 wrote at 600000; reading clears the NMI
RDIO            = $2804                 ; /RDIO: 7 self-test, 6 NMI (command pending, low), 5 output buffer full, 4-2 +5V, 1-0 coins
IRQ_ACK         = $2806                 ; /IRQACK: read or write acknowledges the timed IRQ
OKI_READ_M      = OKI_READ + 8          ; mirror of OKI_READ (mask 01F9)
CMD_FROM_68K_M  = CMD_FROM_68K + 8      ; mirror of CMD_FROM_68K (mask 01F9)
RDIO_M          = RDIO + 8              ; mirror of RDIO (mask 01F9)
IRQ_ACK_M       = IRQ_ACK + 8           ; mirror of IRQ_ACK (mask 01F9)

OKI_WRITE       = $2A00                 ; /WRV: OKI M6295 command
RESP_TO_68K     = $2A02                 ; /WRP: the response byte the 68010 reads at 600000
WRIO            = $2A04                 ; /WRIO: 7-6 bank at 3000, 5-4 coin counters, 3 OKI pin 7, 2 OKI reset (low), 0 YM2151 reset (low)
MIX             = $2A06                 ; /MIX: 5 low-pass filter, 3-1 YM2151 volume, 0 OKI volume

BANK_WINDOW     = $3000                 ; 3000-3FFF: one of the four 4 KB pages of file 0000-3FFF (WRIO bits 7-6)
