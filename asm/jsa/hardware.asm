; hardware.asm: the JSA II board's I/O as the 6502 sees it (equates, no bytes).
;
; atarijsa2_map in MAME 0.289 (src/mame/atari/atarijsa.cpp) and docs/09-sound-program.md
; section 1; the port names are the IDA names of docs/05-ida.md section 4. The ports 2800-2A06
; decode with mirror mask 01F9 (bits 0 and 3-8 are don't-cares). This program reads them only
; through the +8 mirrors (the _M names) and writes them at their base addresses. The bit
; constants below cite the MAME 0.289 line that defines each bit (atarijsa.cpp unless named).

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

; Write ports
OKI_WRITE       = $2A00                 ; /WRV: an OKI M6295 command byte
RESP_TO_68K     = $2A02                 ; /WRP: the response the 68010 reads at 600000
WRIO            = $2A04                 ; /WRIO, below
MIX             = $2A06                 ; /MIX, below

BANK_WINDOW     = $3000                 ; one of the four 4 KB pages of file 0000-3FFF

; RDIO bits (atari_jsa_ii_device::rdio_r 893-911 and the port jsa_ii_ioports 189-199). In MAME
; 0.289 bit 7 always reads 0: the port gives the inverted test line (main_test_read_line, 198)
; and rdio_r inverts it again when the line is low (907-908), so reset's self-test never runs
; there. Bits 2-0 are IPT_COIN3-1 (191-193): harddriv.cpp's "stunrun has its own coins" override
; is a commented-out todo, so a coin key sets them as well as the main board's coin inputs; how
; the real board is wired is not established. read_inputs (io.asm) also reads bit 3, unused in
; jsa_ii_ioports (194).
RDIO_SELF_TEST  = $80                   ; 198: self-test requested
RDIO_NMI_LOW    = $40                   ; 197: low while a command waits (not read by the code)
RDIO_RESP_FULL  = $20                   ; 196: the 68010 has not read RESP_TO_68K yet
RDIO_COIN3      = $04                   ; 193
RDIO_COIN2      = $02                   ; 192
RDIO_COIN1      = $01                   ; 191

; WRIO bits (atari_jsa_oki_base_device::wrio_w 487-528). MAME configures the M6295's pin 7 high at
; power-on (935, PIN7_HIGH), but wrio_w sets it from bit 3 on every write (509) and every WRIO
; write a command can reach has bit 3 clear (4005 on), so the M6295 runs with pin 7 low:
; 3.579545 MHz / 3 / 165, about 7,231 Hz, not / 132. The one store that could set it, 5903
; (ymtimer.asm), is reached only through cmdtype_10_ymtimer, and no command has type 10
; (docs/10-adpcm.md section 2).
WRIO_BANK       = $C0                   ; 490, 500: the page at 3000-3FFF
WRIO_COUNTER2   = $20                   ; 491, 503: coin counter 2
WRIO_COUNTER1   = $10                   ; 492, 504: coin counter 1
WRIO_OKI_PIN7   = $08                   ; 493, 509: the M6295's pin 7 (its clock divisor)
WRIO_OKI_RUN    = $04                   ; 494, 510: the M6295 out of reset (reset is low)
WRIO_OKI_BANK   = $02                   ; 495, 524: OKI bank, JSA III only
WRIO_YM_RUN     = $01                   ; 496, 527: the YM2151 out of reset (reset is low)

; MIX bits (atari_jsa_oki_base_device::mix_w 536-560)
MIX_LPF         = $20                   ; 540, 550: low-pass filter (not emulated)
MIX_OKI_BANK    = $10                   ; 541, 554: OKI bank, JSA III only
MIX_YM_VOLUME   = $0E                   ; 542, 557: the YM2151 volume, 0-7
MIX_OKI_FULL    = $01                   ; 543, 558: the M6295 at full volume (else half)

; YM2151 status bits (3rdparty/ymfm/src/ymfm_opm.h 121-123)
YM_BUSY         = $80
YM_TIMER_A      = $01

; YM2151 registers the system code writes (ymfm_opm.h 175-217, ymfm_opm.cpp 157 and 488-491). A
; per-channel register is the base + the channel 0-7; a per-operator one the base + 8 x the
; operator slot 0-3 + the channel.
YM_KEY_ON       = $08                   ; bits 6-3 the operators keyed on, 2-0 the channel
YM_TIMER_A_HI   = $10                   ; timer A period, bits 9-2
YM_TIMER_A_LO   = $11                   ; timer A period, bits 1-0
YM_TIMER_CTRL   = $14                   ; 5-4 reset the timer flags, 3-2 IRQ enables, 1-0 load
YM_CT_LFO_WAVE  = $1B                   ; 7-6 the CT2 and CT1 outputs, 1-0 the LFO waveform
YM_CONNECT      = $20                   ; 7-6 right/left output, 5-3 feedback, 2-0 algorithm
YM_KEY_CODE     = $28                   ; octave and note
YM_DT1_MUL      = $40                   ; per operator: detune 1, multiple
YM_TOTAL_LEVEL  = $60                   ; per operator: attenuation, 0-7F
YM_KS_AR        = $80                   ; per operator: key scaling, attack rate
YM_DT2_D2R      = $C0                   ; per operator: detune 2, second decay rate

; Values the code writes to YM_TIMER_CTRL (ymfm_opm.h 182-187)
YM_TIMER_A_RUN  = $15                   ; reset the timer A flag, timer A IRQ on, load timer A
YM_TIMER_A_STOP = $14                   ; reset the timer A flag, timer A IRQ on, timer stopped

; OKI M6295 commands (src/devices/sound/okim6295.cpp write 232-310): 80 + a phrase number, then
; a byte with the channel bits 7-4 (one per channel) and the attenuation 3-0 (238-276); or a
; stop byte with the channel bits 6-3 (303-308). The status read (214-225) has bits 3-0 set for
; the channels playing.
OKI_PHRASE      = $80
