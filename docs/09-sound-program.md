# The 6502 sound program as source

**Date**: 2026-11-05 (milestone 4, leg M4a, issue #11). `136070-2123.10c`, the JSA II board's 64 KB 6502 program, is rebuilt entirely from the 64tass tree `asm/jsa/`: no `.binary` is left, `make check` is byte-identical, `make coverage` reports 0 blob bytes for `stunrun-jsa`. This document gives the hardware facts the source relies on (section 1), the partition and its evidence (sections 2 and 3), the tree (section 4), the command protocol with the 68010 as far as this leg proves it (section 5), attract-mode sound (section 6), the trace (section 7) and the checks (section 8); section 10 (leg M4c, issue #16) names the system code and gives the evidence for each name. The ADPCM samples are leg M4b; the YM2151 patch tables and the stream data structured as data are a later leg.

## 1. Hardware facts, verified against MAME 0.289

Source: `src/mame/atari/atarijsa.cpp` (`atarijsa2_map`, `atari_jsa_ii_device`, `atari_jsa_oki_base_device`), `atariscom.cpp`, `harddriv.cpp` (stunrun's machine config and `init_multisync`), `src/devices/sound/okim6295.cpp`, `src/devices/cpu/m6502/m6502.cpp`.

| 6502 address | What | Evidence |
|---|---|---|
| 0000-1FFF | RAM | `atarijsa2_map` |
| 2000-2001 | YM2151, no mirror; write 2000 register, 2001 value; read 2001: status (bit 7 busy, 1 timer B, 0 timer A); a read of 2000 returns FF | `atarijsa2_map`; ymfm `ym2151::read` (offset 1 only); `ym_wait` (5026) polls bit 7 at 502E, `h_irq` (41C5) tests bit 0; the program reads only 2001 |
| 2800 | /RDV, OKI M6295 status: bits 3-0 channel 4-1 playing (bits 7-4 read 1) | `oki_r`, `okim6295_device::read` |
| 2802 | /RDP, the command byte; reading clears the 6502's NMI | `sound_command_r` |
| 2804 | /RDIO: 7 self-test, 6 NMI pending (active low), 5 output buffer full, 4-3 unused, 2-0 coins 3-1 (live in MAME 0.289, below) | `jsa_ii_ioports`, `rdio_r` |
| 2806 | /IRQACK, read or write: clears the timed IRQ | `sound_irq_ack_r/_w` |
| 2A00 | /WRV, OKI command byte | `oki_w` |
| 2A02 | /WRP, the response byte | `sound_response_w` |
| 2A04 | /WRIO: 7-6 page at 3000, 5-4 coin counters 2-1, 3 OKI pin 7, 2 OKI reset (low), 1 OKI bank (JSA III only), 0 YM2151 reset (low) | `wrio_w` |
| 2A06 | /MIX: 5 low-pass filter (not emulated), 4 OKI bank (JSA III only), 3-1 YM2151 volume 0-7, 0 OKI volume (half/full) | `mix_w` |
| 3000-3FFF | bank: four 4 KB pages from file 0000-3FFF | `configure_entries(0, 4, base, 0x1000)` |
| 4000-FFFF | ROM, file 4000-FFFF | `map(0x4000, 0xffff).rom()` |

- Every port 2800-2A06 decodes with mirror mask 01F9 (reads and writes). The program reads only through the +8 mirrors (2808, 280A, 280C, 280E: the `_M` names of docs/05 section 4) and writes at the base addresses.
- Clocks: the 6502 runs at 3.579545 MHz / 2; the YM2151 at 3.579545 MHz; the M6295 at 3.579545 MHz / 3. MAME configures the M6295's pin 7 high (`PIN7_HIGH`, divisor 132), but `wrio_w` sets the pin from WRIO bit 3 (`set_pin7(data & 8)`) and every WRIO write the traces record has bit 3 clear (the stores `sta WRIO` at 4007 01, 400C 00, 4011 01, the self-test's 409D, 40AD, 40BD and 40CD (05 with page bits 7-6), 411E 05, and 5BB0, 5BB7 and 5DA9, which change only bits 2 and 5-4 of `wrio_shadow`; the traces' WRIO values are only 00, 01 and 05). The one other store, 5903 in the never-run timer-A code, ORs `tbl_65DD+4,x` into its value (58FE) with X not bounded by the code, so its own bit 3 is not proven clear; but it is reached only through `JMP ymtimer_start` at 44CC in `cmdtype_10_ymtimer`, and no command has type 10 (`cmd_type`, section 5; docs/10-adpcm.md section 2 makes the same argument). So the M6295 runs with pin 7 low: 1,193,182 Hz / 165, about 7,231 Hz, not the 9,039 Hz of the power-on setting; this is the rate `tools/adpcm` writes into its WAV headers (docs/10 section 2). The 6502's IRQ is the OR of the timed interrupt (3.579545 MHz / 4 / 16 / 16 / 14, about 249.7 Hz, held until /IRQACK) and the YM2151's IRQ; its NMI is held from a command write until /RDP is read.
- The 68010 side (`harddriv.cpp` `init_multisync`): a write at 600000-603FFF with byte mask FF00 (the high byte) is the command (`main_command_w`, which raises the NMI); a read there returns the response and clears the 68010's sound interrupt (`main_response_r`); a read at 604000-607FFF resets the sound board (`hd68k_sound_reset_r`). The 68010 code tests bit 15 of A80000 before it writes a command (023EEC `btst #$f,$a80000` and a retry loop, then 023EF6; also 023EB0); its role as "may I write" is inferred from that code alone. MAME 0.289 does not emulate the bit (stunrun's `mainpcb:a80000` port has bits 3-15 `IPT_UNUSED`, active low, so it always reads 1: always ready); the real board's signal is unverified.
- RDIO bit 7 always reads 0 in MAME 0.289: the port gives `main_test_read_line()`, which is the inverted test line, and `rdio_r` inverts bit 7 again when the test line is low. Reset's self-test (bit 7 set, 4016-401B) therefore never runs in MAME.
- RDIO bits 2-0 are `IPT_COIN3`-`IPT_COIN1` (active high) in `jsa_ii_ioports`. `harddriv.cpp` has a "stunrun has its own coins" override of that port, but it is a commented-out todo, so in MAME 0.289 a coin key sets these bits as well as the main board's coin input. The `sndtrace-play` run inserts its coin through `:mainpcb:IN0` only (`sndtrace.lua`), so it shows nothing either way; how the real board is wired is not established.
- **Corrections to docs/01 section 6**: its WRIO and MIX rows now agree with this table (corrected by M4b). Still open (not edited by this leg; for the coordinator): RDIO bits 4-2 are unused and coin 3 in `jsa_ii_ioports` (the "+5V" of docs/01 is the comment in `rdio_r`, which the port definition contradicts). The header comment of `atarijsa.cpp` ("Interrupt acknowledge 2A00") describes the JSA I.

The coordinator's hypotheses (issue #11), checked: file 0000-3FFF zero, yes; vectors NMI 57E3, reset 4000, IRQ 41C1, yes; AC49-FFF9 zero, yes; 4000-AC48 program and data, yes, but the code ends at 5DB4, not 609B, and the run of FF at 609C-60FF is not padding: it is `cmd_class` for the commands 09-6C (section 5).

## 2. The partition

Every byte of the file belongs to one statement of one file; the region files are the ownership units of the later legs.

| Range | File | Class | Content and evidence |
|---|---|---|---|
| file 0000-3FFF | `jsa.asm` | fill | the four bank pages, zero; no absolute operand refers to 3000-3FFF; the self-test adds them into the ROM checksum (4094-40D5), and the dormant `ymtimer.asm` path selects a page (58FA-5905, WRIO bits 7-6 from `tbl_65DD+4`) before reading through `ymt_ptr`, the pages' only candidate reader outside the self-test |
| 4000-4237 | `system.asm` | code (282 instructions) | reset, self-test, initialisation, `main_loop`, `h_irq` |
| 4238-4758 | `commands.asm` | code (644), `cmdtype_handlers` | `init_sound`, `dispatch_command`, the 21 command-type handlers, `send_response`, `queue_response` |
| 4759-57E2 | `sequencer.asm` | code (1950), `op_handlers`, 6 small tables (57C3-57E2) | the stream interpreter, its ops, the YM2151 writes, `ym_wait` |
| 57E3-585D | `nmi.asm` | code (62) | `h_nmi`, the command byte |
| 585E-5BAB | `ymtimer.asm` | code (362), `ymtimer_patch` | YM2151 channels 6-7 driven by timer A (never run) |
| 5BAC-5CB7 | `oki.asm` | code (131), 3 tables | the M6295 driver |
| 5CB8-5DB4 | `io.asm` | code (124), 2 tables | RDIO inputs and coin counters, commands 03 and 08 |
| 5DB5-61E3 | `tables.asm` | data | 7 lookup tables of the code, `cmd_class`, `cmd_type`, `cmd_param`, `imm_handlers` |
| 61E4-65E5 | `data/sounds.asm` | data | the tables the command handlers index with their parameter, `tbl_633E` (125 stream addresses as `.word dat_XXXX`) |
| 65E6-AB47 | `data/music.asm` | data | the 125 byte streams and the data they point to, `.byte` rows under `dat_XXXX` labels |
| AB48-AC47 | `lookup.asm` | data | a 256-byte table read at 4F69 |
| AC48 | `jsa.asm` | data | `checksum_adjust`: no instruction reads it; it makes the byte sum of the file FF, which the self-test checks (40E4) |
| AC49-FFF9 | `jsa.asm` | fill | zero, unreferenced |
| FFFA-FFFF | `jsa.asm` | data | the vectors `.word h_nmi, reset, h_irq` |

`hardware.asm` and `ram.asm` hold equates only. `make coverage` (2026-11-05):

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `asm/jsa/jsa.asm` | 37,816 | 0 | 7 | 0 | 37,809 |
| `asm/jsa/system.asm` | 568 | 568 | 0 | 0 | 0 |
| `asm/jsa/commands.asm` | 1,313 | 1,271 | 42 | 0 | 0 |
| `asm/jsa/sequencer.asm` | 4,234 | 4,084 | 150 | 0 | 0 |
| `asm/jsa/nmi.asm` | 123 | 123 | 0 | 0 | 0 |
| `asm/jsa/ymtimer.asm` | 846 | 804 | 42 | 0 | 0 |
| `asm/jsa/oki.asm` | 268 | 256 | 12 | 0 | 0 |
| `asm/jsa/io.asm` | 253 | 245 | 8 | 0 | 0 |
| `asm/jsa/tables.asm` | 1,071 | 0 | 1,071 | 0 | 0 |
| `asm/jsa/data/sounds.asm` | 1,026 | 0 | 1,026 | 0 | 0 |
| `asm/jsa/data/music.asm` | 17,762 | 0 | 17,762 | 0 | 0 |
| `asm/jsa/lookup.asm` | 256 | 0 | 256 | 0 | 0 |
| **stunrun-jsa** | **65,536** | **7,351** | **20,376** | **0** | **37,809** |

The file names follow the code, not the coordinator's proposal word for word: the protocol pieces are spread over the address space (`h_nmi` at 57E3, the immediate commands at 4533, 4543, 5CB8 and 5DAD, `send_response` at 4553), so they stay in the region files their addresses fall in, and the contiguous blocks got their own files (`commands.asm`, `nmi.asm`, `ymtimer.asm`, `io.asm`, `lookup.asm`). Every file is one contiguous range included once, in address order, so a file's bytes are its range and nothing else.

## 3. How the classification was made

1. **Recursive descent** (a throwaway disassembler in the session scratchpad, not committed) from the three vectors, following `JSR`, `JMP abs` and branches. The program has no `JMP (ind)`; it dispatches by pushing a table word and returning (RTS), from three tables the descent found by their users:
   - `cmdtype_handlers` 472F, 21 words (`dispatch_command`, 4371-4389: `cmp #$15`);
   - `op_handlers` 50AF, 59 words, stream bytes 80-BA (`sub_505D`, 505D-507A: `cmp #$BB`, `asl`; the 59 words end where the code at 5125 starts, which entry 08 points to);
   - `imm_handlers` 61DA, 5 words (`h_nmi` 584F-585D for `cmd_class` 0-3, and `cmdtype_03_immediate` 43CA-43D4 for entry 0).
   With these, the descent reaches 3,555 instructions (7,351 bytes) in 4000-5DB4 and no overlap, no illegal opcode, no fall into data. The rest of 4000-5DB4 is tables the code indexes (472F, 50AF, 57C3-57E2, 5C63-5C6E, 5D09-5D10) and one block reached only through `#<`/`#>` immediates (`ymtimer_patch` from 5892-5898 and 58C2-58C8); `empty_envelope`, just after the range at the start of `tables.asm`, is reached the same way (4718-4725).
2. **Tables**: each data region's tables start at an address an instruction reads (absolute, indexed, or through `(zp),y` with a base loaded as immediates: `tbl_6244`, `tbl_62C1`, `tbl_633E`, `tbl_6438` at 45AB-468E). A table's length is what the code's index can reach where it is bounded (an `AND`, a compare: `cmd_*` 6D bytes at 583C and 4371, `nibble_scale` 256, `note_lengths` 16 words), else up to the next table; each table's comment in the source gives its readers and the bound. The 125 stream addresses of `tbl_633E` are the only pointers in the data that the code proves; they are `.word dat_XXXX`.
3. **The MAME trace** (section 7) confirms it: every one of the 1,961 instruction addresses the 6502 fetched an opcode from is an instruction of the descent, and every data read (outside the instructions' own bytes) falls inside a data statement, never inside an instruction or a `.fill`: `tools/sndtrace.py summary` checks both, and fails otherwise. No opcode is ever fetched from the bank window.
4. **Bytes the trace never executes but the descent calls code** (1,594 instructions; `never_executed` in `artifacts/sndtrace-summary.json`): the self-test (402A-4112, 418C-41BC, unreachable in MAME, section 1), the immediate commands (none sent in the runs), the command types no command uses (02, 04, 06, 07, 0D, 0E, 10, 11 and the shared return 0C/0F/12; `cmd_type` over 00-6C holds only 00, 01, 03, 05, 08, 09, 0A, 0B, 13, 14 and FF), the types used by commands the runs did not send (03, command 00; 09, command 09), all of `ymtimer.asm` but its reset (no command has type 10), and stream ops the traced sounds do not use. Each is reached by a `JSR`, a branch or a dispatch table entry from code that is itself reached, which is the argument that they are code.
5. **Bytes neither reaches**: none in 4000-5DB4. In the data regions, the bytes of `data/music.asm` between and after the streams that no trace read, `tbl_65DD` (only dead code reads it) and `checksum_adjust` (read by no instruction, explained by the checksum) are data by position: they lie inside the data regions, and no instruction could execute them.
6. **Relocation test** (scratch, not committed): the tree assembled with one byte inserted before `reset` (guards removed) moves every absolute operand into 4000-AC48 by one, every RTS-table word and `tbl_633E` word by one, and changes nothing else in the code but the nine `#<` immediates; so no instruction holds a hard-coded ROM address. The stream bytes of `data/music.asm` do hold addresses (the op AE lists of addresses, for one: 536F-5398 picks a word from the list after the op and jumps the stream there) and are not relocatable yet; structuring them is the later data leg.
7. **Relocation and timing, in MAME** (scratch, not committed; found in the review of PR #14, the 1-byte `soundcheck` result run again by the fix with the same build and the same failure): static relocation is not enough for `make soundcheck`. The program's output depends on cycle counts, through indexed reads and branches that cross a page or not. A build moved by 1 byte inside 4000-5BAB (a `.byte $00` before `reset`, the last `$00` of `ymtimer_patch` removed, guards stripped) relocates every one of the 333 absolute ROM operands, every branch and the 87 table words, and its data reads and fetches match the original but one read whose index comes from RAM (5F73 by 4F88); yet its YM2151 stream differs: `soundcheck` over 3000 frames gives 62,115 writes in both runs, first difference at event 41,638 (register 74 written 16 in the reference, 1A rebuilt), and the play run 253,010 writes against 252,956. A build moved by 256 bytes (256 bytes inserted before `reset`, 256 never-executed bytes of `ymtimer.asm` removed: every page crossing preserved) is equal: `OK soundcheck: 3000 frames` and, against `sndtrace-play`, 7,200 frames, 253,010 YM2151 writes, 1,444 key-ons, equal. **For the later legs**: `make check` is the gate, and a change that keeps the bytes keeps the sound; a change that moves code or data (an instruction length, a table resized) keeps the YM2151 stream only when the move preserves every page offset, even with fully symbolic source; a different stream after such a move is timing, not a wrong operand, and is expected. `make soundcheck` itself runs only on a byte-identical set (its `check` prerequisite stops on any differing byte before MAME starts), so it proves that MAME loads `build/roms` and that attract mode keys on, never a moved build; the comparisons above were made by hand: the moved tree assembled to a scratch copy of `build/roms/stunrun/`, then the two `snd_run` MAME commands of the Makefile's `soundcheck` recipe (without `-verifyroms`, which a moved set fails) with `-rompath` pointing at the copy, then `tools/sndtrace.py soundcheck` on the two traces.

## 4. The tree

`asm/jsa/jsa.asm` includes `hardware.asm`, `ram.asm`, then the region files in address order; each region file starts and ends with a `.cerror` on `*`, and `jsa.asm` guards the bank pages, `checksum_adjust`, the vectors and the wrap to 0000. Conventions (Spindizzy's docs/26 section 5): lowercase mnemonics, `$` hex, labels alone on their line, four-space indentation, comments at column 40, `@w` on the 11 instructions whose operand is a zero-page address in the 3-byte form (402E-404C, 53D2, 54EE, 5BFE, 5C8D, 5CC9, 5CCE), every branch and jump to a symbol.

Labels: the IDA names are carried in (`reset`, `h_irq`, `h_nmi`, `vec_nmi`, `vec_reset`, `vec_irq`, and the I/O names with their `_M` mirrors in `hardware.asm`; `tools/test_jsa.py` checks every name of `data/ida/stunrun-jsa.json` against the source). This leg names what the code proves: `main_loop`, `dispatch_command`, `send_response`, `queue_response`, `ym_wait`, `checksum_adjust`; the dispatch tables and their entries (`cmdtype_handlers` and `cmdtype_XX`, `op_handlers` and `op_XX`, `imm_handlers` and `imm_XX`, a handler shared by several entries keeping a neutral `loc_XXXX`); the command tables `cmd_class`, `cmd_type`, `cmd_param`; and in `ram.asm` the queues (`cmd_queue`, `resp_queue` and their indexes), `nmi_mode`, `nmi_data_ptr`, `nmi_data_count` and the register shadows `wrio_shadow`, `mix_shadow`, `ym_1b_shadow`. Everything else has a neutral address label for the later legs to rename: `sub_XXXX` (a `JSR` target), `loc_XXXX` (a jump or branch target that cannot be a 64tass local: reached from another file, from a dispatch table, or across another global label of its file, since a local is visible only between two global labels; `tools/test_jsa.py` checks the rule), `_lXXXX` (every other branch or jump target, a 64tass local of the global label above it), `tbl_XXXX` and `dat_XXXX`, `zp_XX` and `ram_XXXX`. A label never claims a role the code does not show; the comments say what the code does with addresses. Leg M4c (section 10) renamed the labels of the system files (`system.asm`, `commands.asm`, `nmi.asm`, `ymtimer.asm`, `oki.asm`, `io.asm`, `tables.asm`) and the RAM variables they use; the sequencer's files keep the neutral labels for leg M4d.

Each region file's header says what is in it and how the code reaches it; each global label's comment lists its callers and dispatch entries, and whether the trace executed it. The source was generated once by the scratch disassembler and is hand-maintained from now on; no generator is committed.

## 5. The command protocol (what the code shows)

- **Reset handshake**: after a reset the 6502 drops any pending command (reads 280A, 4139) and writes FF (413C-413E). In the traces every one of the 68010's sound resets (604000 reads: frames 0, 367, 410 and then 3964 and 8668 in attract mode, 965, 981, 1779 and 4726 in the game run) is followed by one FF, and FF is the only response the runs saw.
- **A command byte** raises the NMI. `h_nmi` waits until the 68010 has read the last response (RDIO bit 5 clear), then, in the command mode (`nmi_mode` FF), looks the byte up in `cmd_class`: bit 7 set, the byte goes into `cmd_queue` (48 entries, the oldest dropped when full); 00-03, the byte is an immediate command, run inside the NMI through `imm_handlers` entry class+1; a byte 6D or above queues 6D, which does nothing.
- **Queued commands**: `main_loop` takes one per pass and `dispatch_command` runs `cmdtype_handlers[cmd_type]` with A = `cmd_param`. The 109 commands 00-6C use 10 types and FF: 08 (32 commands, parameters 00-1F: `cmdtype_08_start_sound`, which starts the streams of `data/sounds.asm` number N), 13 (53 commands, parameters 00-34: `cmdtype_13_oki_play`, an OKI sample, `oki.asm`), 01 (commands 1E-23: `seq_vars` = 0-5), 0A (5), 0B (2), 05 (2), 00 (01 and 02: `min_priority` = F0 or 0, section 6), 03 (00: `init_sound`, the sound initialisation), 09 (09: queues the response 55), 14 (66: stops the OKI channel playing the phrase its parameter names, 48, compared at 5C75; docs/10 section 4), and FF, the four immediate commands. What each type does to the sound is for the later legs.
- **Immediate commands** (none was sent in the traced runs; the 68010's "SOUND*BOARD*TESTS" screen, text at 0x006918, may be what sends them, not traced; M4c's probe injected each, section 10.2): 03, `imm_01_send_inputs`, sends `coin_state` (the RDIO input state, `io.asm`); 06, `imm_02_send_count`, sends 6D; 07, `imm_03_send_status`, sends the status byte `board_status` (bit 7 ROM checksum, 4 and 3 RAM, 2 no timed IRQ, 1 YM2151 time-out) and then sets its bits 0 and 2, which `main_loop` and the timed IRQ clear, so the next 07 tells whether both still run; 08, `imm_04_loopback`, sends AA, takes the next byte the 68010 writes and sends it back (a loop-back).
- **Responses**: the immediate commands write through `send_response` (waits for the 68010 to read each byte); `queue_response` (command 09, and stream op 96 with its operand) leaves a byte in `resp_queue` (16 entries; `resp_queue_full` = 80 when a byte is dropped) for `main_loop`, which sends one per pass when the 68010 has read the last. The self-test's fatal RAM error writes 10 and stops (41A1).
- **The 68010 side**, as far as the trace shows it: every command byte in the three runs was written by the instruction at 0x023EF6 (`move.b d0,$600000`, in the routine at 0x023EDA/0x023EDE that tests A80000 bit 15 first). Two scratch probes (write taps with the 68010's stack, not committed) showed it called from 0x030170, which empties a queue at FFDB64 that the game fills through 0x0301CA. The 68010's names for the commands are M5's; this table is what they will name.

## 6. Attract mode and its sound

With the set's factory NVRAM (the empty private NVRAM of every `make` MAME run boots from the set's 200e/210e), **attract mode is silent**: in the 10,800-frame `sndtrace-attract` run the 6502 writes the YM2151 113,529 times but keys on no channel (0 writes of register 08 with a slot bit) and sends the M6295 no command. The reason, traced: when attract mode starts (frame 822) the 68010 queues command 01 if bit 11 of its option word FF94EE is clear and 02 if it is set (0x028362-0x02837E); the option word is 0 after boot (scratch taps, not committed: written 0 at 0x021302, frame 36, and 0x0243BE, frame 410; read at 0x028364, frame 822). Command 01 is type 00 with parameter 3C: `min_priority` = F0, and with that the OKI start returns at once (5BFE-5C01), and in `sub_4E79` the compare at 4EE3-4EE8 returns unless `ram_088E` reaches `min_priority`, which skips the rest of the routine: the key code (4EF4-4F08), the total levels (4F20-4FD4) and the key-on, register 08 with the slot bits 78 (4FFA-5006); the key-off before it (4ED3-4EDF) does not depend on `min_priority`. `ram_088E` holds the `trk_priority` of the track being played (477B-477E), so `min_priority` is a priority floor: M4c's probe (section 10.2) keys a sound of priority 3F on with `min_priority` F0. Command 02 sets `min_priority` to 0; the game run sends 01 at frame 831 and 02 when the game starts (frame 1047), and keys on 1,444 times.

The 68010's operator menu has the option "SOUNDS IN ATTRACT" (OFF/ON, text at 0x020F52 in the game-options table at 0x020ED0, referenced from 0x0432D4). That this entry is bit 11 of FF94EE is an inference, not traced: the table's entries start with a byte whose low nibble would be the bit (BB before "SOUNDS IN ATTRACT", CC and AA around it). The machine evidence is the effect: `sndtrace-sound`, the same attract run with bit 11 forced on (a write tap that ORs 0800 into every value the game writes to FF94EE, `TRACE_ATTRACT_SOUND=1`), sends 02 at each demo start, keys on YM2151 channels 643 times and sends the M6295 966 commands. It is not continuous. In every run, whatever bit 11 is, the 68010 also sends 01 at the end of each attract demo, from a path other than 0x028362 (not identified; the commands all leave through 0x023EF6): `sndtrace-sound` has `C 831 02`, `C 2301 01`, `C 5534 02`, `C 7005 01`, `C 10238 02`, and `sndtrace-attract` 01 at the same five frames. The YM2151 key-ons of `sndtrace-sound` follow the windows: 261 in frames 831-2300, 0 in 2301-5533, 261 in 5534-7004, 121 from 10238 to the end; the OKI commands 405, 0, 408, 153. At the multisync screen's 60.2 Hz (`set_raw(5000000*2, 317*2, 0, 256*2, 262, 0, 228)`, 10 MHz / 634 / 262) the sound plays from about 13.8 s to 38.2 s after boot, is silent until about 91.9 s, plays to about 116.4 s, and starts again at about 170.1 s: about 24 s of sound in each 4,704-frame (78 s) attract cycle. Making it continuous would need the 01 path found and tapped; this leg does not.

`make listen` uses the same tap (`tools/mame/listen.lua`) so that attract mode plays without touching the NVRAM or the operator menu; `LISTEN_ATTRACT_SOUND=0` leaves the factory setting (silent attract mode). The sound starts about 14 seconds after boot (frame 831) and stops at about 38 seconds (frame 2301, the 01 at the demo's end); it comes back at about 92 seconds (frame 5534) to about 116 seconds (frame 7005), and so on each cycle. A silence between about 38 s and 92 s is the game, not a fault of the rebuilt file. On a real board the operator menu's "SOUNDS IN ATTRACT: ON" is the equivalent, if the inference above holds.

## 7. The trace (`make sndtrace`)

`tools/mame/sndtrace.lua` taps, headless (`SDL_VIDEODRIVER=dummy`, `-video none -sound none`), from an empty private NVRAM/cfg per run:

- every 6502 read of 3000-FFFF. MAME's 6502 sets NPC (the "PC" state) to the instruction's address just before the opcode fetch (`prefetch_start`), so a read at PC is an opcode fetch, a read at PC+1 or PC+2 an operand, and any other read a data read, recorded with the instruction's PC (PC 0 for the vectors). The core's dummy reads are left out: those of a taken branch and of RTS, and the wrong-page read of an indexed access that crosses a page (the next data read of the instruction 100 higher). Counted over the play run: 64,847,639 fetches, 94,208,524 operand reads, 2,989,843 dummy reads dropped, 934,495 data reads;
- the 6502's writes of 2000-2FFF (YM2151 register and value, OKI, response, WRIO, MIX) and reads of the command latch;
- the 68010's writes of the command byte (600000-603FFF, high byte) with the frame and the instruction's address (CURPC), its reads of the response and of 604000 (sound resets).

The raw traces stay in `build/mame/` (the YM2151 and OKI streams carry values from the ROM). `tools/sndtrace.py summary` checks each against the source (section 3) and writes `artifacts/sndtrace-summary.json`: per run the counters, the executed instructions and the data reads as address ranges (with the instructions that read), the command values (count, first frame, the 68010 instruction), the response values, the YM2151 writes and key-ons, the OKI commands; over all runs the instructions never executed, per file and as ranges. Results (`make -j3 sndtrace`, 2026-11-05, MAME 0.289, the reference set):

| Run | Frames | Instructions executed | Data bytes read | Commands (values) | Responses | YM2151 writes / key-ons | OKI commands |
|---|---|---|---|---|---|---|---|
| `sndtrace-attract` (factory) | 10,800 | 1,708 | 3,186 | 558 (26) | FF ×5 | 113,529 / 0 | 0 |
| `sndtrace-sound` (bit 11 on) | 10,800 | 1,927 | 3,464 | 558 (27) | FF ×5 | 147,572 / 643 | 966 |
| `sndtrace-play` (coin 900, start 960, trigger 1020) | 7,200 | 1,961 | 5,813 | 391 (40) | FF ×7 | 253,010 / 1,444 | 312 |

10,800 frames cover the first attract cycle and a whole second one: the 68010 resets the sound board at frames 3964 and 8668, 4,704 frames apart. Over the three runs 1,961 of the 3,555 instructions execute; per file, executed of total: `system.asm` 121/282, `commands.asm` 412/644, `sequencer.asm` 1,231/1,950, `nmi.asm` 35/62, `ymtimer.asm` 6/362, `oki.asm` 110/131, `io.asm` 46/124.

## 8. Build and checks

- `make check`: 25 files, 0 differences; the 6502 tree depends on its own files only (`EXTRA_stunrun-jsa` is `asm/jsa/data/*.asm`; `build/stunrun-jsa.bin` is still made by `tools/merge-roms` for `make ida`).
- `make coverage`: `stunrun-jsa` instr 7,351, data 20,376, blob 0, fill 37,809; the set's blob share goes from 73.9% after M4b to 69.6% (1,051,392 bytes).
- `tools/test_jsa.py` (CI, no ROMs): `asm/jsa/jsa.asm` assembles with 64tass to MAME's size, CRC-32 and SHA-1 of `136070-2123.10c`; one operand changed (reset's `ldx #$FF` to `#$FE`) changes exactly byte 4003 and the hash; a byte inserted in `commands.asm` fails the assembly at its end guard; the tree has no `.binary` and nothing from `build/`; every IDA name is in the source at its address; the committed summary's executed ranges are whole instructions of the source, its data reads lie in data statements, and executed plus never-executed are exactly the instructions; `tools/sndtrace.py` on synthetic traces of a synthetic program; and the `make sndtrace` traces against the source when they are present. `tools/test_build.py`'s synthetic set carries the 6502 image the source assembles to, and the synthetic `make all` checks that an operand edited in the copy's source reaches 10c (bytecheck: `136070-2123.10c: 1 differing bytes, first at file offset $04003 = 6502 $4003`).
- `make sndtrace` (`-j3` runs the three side by side, about 3 minutes): section 7.
- `make soundcheck` (on a byte-identical set only: `make check` is its prerequisite, section 3 item 7 for a moved build): after `make check`, MAME's `-verifyroms` on `build/roms` (a `-rompath` on the command line replaces `mame.ini`'s, so the rebuilt run reads nothing else), then `SOUNDCHECK_FRAMES` (3000) frames of attract mode with its sound on from the reference set and from the rebuilt one, headless; the YM2151 and OKI write streams, the commands and the responses must be equal and the reference must key on. 2026-11-05: `OK soundcheck: 3000 frames, 62115 YM2151 writes (261 key-ons), 405 OKI commands, equal in both runs`.
- `make listen`: Jesus's listening check, the one target that opens a window: `make check`, `-verifyroms`, then MAME on `build/roms` with sound, from an empty private state under `build/mame/listen/`, attract mode with its sound on (section 6). Never run by an agent.

## 9. Not verified, open

- The self-test path (402A-4112) cannot run in MAME 0.289 (section 1); it is code by the descent alone.
- No immediate command (03, 06, 07, 08) was sent in the traced runs; M4c's probe (section 10.2) injected each and saw the responses the code predicts, but which 68010 code sends them (the sound-board test screen, presumably) is M5's.
- That "SOUNDS IN ATTRACT" is bit 11 of FF94EE is inferred from the option table, not traced through the operator menu.
- `ymtimer.asm` never runs (no command of type 10); whether any 68010 path sends such a command is M5's question.
- `tbl_65DD`'s extent (9 bytes up to the first stream) is the space left, not a bound in the code.
- 64tass 1.59 (CI) was not run locally on the new tree; the CI job assembles it.

## 10. The system code named (M4c)

**Date**: 2026-11-05 (milestone 4, leg M4c, issue #16). The system half of the tree, `system.asm`, `commands.asm`, `nmi.asm`, `ymtimer.asm`, `oki.asm`, `io.asm`, `tables.asm` and the equates of `hardware.asm` and `ram.asm`, has names instead of address labels: every routine has a header block in the Spindizzy style (what it does, its inputs and outputs, who calls it, whether the traces ran it), every branch target inside a routine is a 64tass `_local` with a name, and every table and RAM variable these files use has a name that says what is stored there. `make check` is unchanged (0 differences): only labels, comments and equates changed, and immediates became the equates of `hardware.asm` where the value is that constant. `tools/test_jsa.py` checks that no `sub_`, `loc_`, `tbl_`, `dat_` or `_lXXXX` label is left in these files and that every `zp_XX`/`ram_XXXX` equate left in `ram.asm` is used by the sequencer's files (`sequencer.asm`, `lookup.asm`, `data/`) and by no system file; once M4d has named them all, none is left and the check still passes.

Terms the names use (from the code, sections 10.2 and 10.9):

- **Track**: one of the 30 stream players, X = 00-1D, the index of the 1E-byte arrays at 0248-085F (`trk_*`). A type-08 command starts one track per entry of its sound (`cmdtype_08_start_sound`).
- **List**: `trk_link` chains the tracks of one channel, in ascending `trk_priority`; `chan_list` (087E, 14 bytes) holds the heads. Only a list's last track (the highest priority) writes the chip: the sequencer runs the others silently (zp_22, 475B-4762, M4d's).
- **Engine**: `tick_sequencer` runs engine 0 (X = 0, `tbl_57DF` = 02: the lists 0-7, YM2151 channels 0-7) and engine 1 (X = 1, `tbl_57DF` = 03: the lists 8-D, `engine_chip` 0000) on alternate timed IRQs. No sound of this ROM uses engine 1: `tbl_62C1`, the list of each of the 125 entries, holds 0-7 only. Arrays that mean one thing to each engine are named by their engine-0 use, the comment giving both.
- **Frame**: a 4-byte record of `frame_pool` at 09AE (room for 199, 1-C7, but `init_frame_pool` chains only 1-86, section 10.10) that the stream ops 8D (a call) and 8E (a loop) push the stream address into.

The names of the sequencer's own routines and variables (`sequencer.asm`, `data/**`, `lookup.asm`) are leg M4d's; where these files call them, the call keeps the neutral label (`sub_5504`, `loc_5043`, `sub_55B4`, ...).

### 10.1 `system.asm`

| Name | Address | What the code does | Evidence |
|---|---|---|---|
| `reset` | 4000 | pulses the YM2151 reset, then the self-test or a zero-page clear | 4005-4011 (WRIO 01, 00, 01), 4016-401B (RDIO bit 7) |
| `self_test` | 402A | zero page and pages 01-1F with a walking bit, the ROM checksum, the timed IRQ | 402A-4052, 4053-408A, 408B-40ED, 40EE-4112 |
| `init_board` | 4113 | WRIO 05, `ym_1b_shadow` C0, `nmi_mode` FF, queues empty, drops a command, sends FF | 4113-413E; the FF after every sound reset (section 5) |
| `warm_start` | 4141 | `init_sound`, seeds `rng_state` 0D, falls into `main_loop`; the BRK path of `h_irq` jumps here with an empty stack | 4141-4148, 4201-4204 |
| `main_loop` | 4149 | one response out, one command run per pass | 4149-4189 |
| `self_test_bad_page` | 418C | page 01 fatal; else `board_status` 10 (page below 08) or bit 3 | 418C-41A0 |
| `self_test_fatal` | 41A1 | sends 10, loops forever | 41A1-41A8 |
| `checksum_pages` | 41A9 | A += every byte of Y+1 pages from page X | 41A9-41BC; the callers 40A5-40E1 |
| `ack_timed_irq` | 41BD | reads `IRQ_ACK_M` | 41BD; `sound_irq_ack_r` |
| `h_irq` | 41C1 | timer A: `ymtimer_irq`; else the tick (sequencer, OKI, inputs), re-entrant through `irq_busy`/`irq_again`; BRK restarts | 41C1-4228 |
| `tick_sequencer` | 4229 | engine 0 on odd `tick_count`, engine 1 on even, through `loc_5043` | 4229-4237, `tbl_57DF` |

### 10.2 `commands.asm`

| Name | Address | Commands (type) | What the code does | Evidence |
|---|---|---|---|---|
| `init_sound` | 4238 | 00 (03), reset | OKI reset, frame pool, lists and tracks freed, channels 7-0 keyed off, register 1B, MIX 0F | 4238-42D7 |
| `init_frame_pool` | 42D8 | | chains the frames 1-86 (meant 1-C7, fault below) | 42D8-4308 |
| `alloc_frame` | 4309 | | pops a frame off `frame_free` | 4309-4319 (fault below) |
| `frame_address` | 431A | | `frame_ptr` = `frame_pool` (09AE) + (A - 1) x 4 | 431A-433B |
| `free_track_frames` | 433C | | returns a track's loop and call frames to the pool | 433C-4370 |
| `dispatch_command` | 4371 | all | the type's handler with A = `cmd_param` | 4371-4389 |
| `cmdtype_00_min_priority` | 438A | 01, 02 (00) | `min_priority` = 4 x A | 438A-438E; MAME below |
| `cmdtype_11_ym_ct` | 438F | none (11), op A5 | bits 7-6 of YM2151 register 1B (CT2, CT1) | 4392-43AA; CT1 gates the M6295 (atarijsa.cpp 328, 630) |
| `cmdtype_01_set_var` | 43AD | 1E-23 (01) | `seq_vars`+(`tbl_65D1` AND 1F) = `tbl_65D7` | 43AD-43B9 |
| `cmdtype_02_add_var` | 43BA | none (02) | the same, adding | 43BA-43C9 |
| `cmdtype_03_immediate` | 43CA | 00 (03) | `imm_handlers` entry A | 43CA-43D4 |
| `cmdtype_04_stop_priority` | 43D5 | none (04) | `trk_sound` FF where `trk_priority` / 4 = A | 43D5-43ED |
| `cmdtype_05_stop_sound` | 43EE | 2E, 36 (05) | `trk_sound` FF for the sound of command A | 43EE-440F; MAME below |
| `cmdtype_06_stop_list` | 4410 | none (06) | `trk_sound` FF for every track of a list | 4410-4434 |
| `cmdtype_07_stop_side` | 4435 | none (07) | `trk_sound` FF where `trk_reg20` bit 7 (A = 0) or 6 is set | 4435-445E |
| `cmdtype_0A_release_sound` | 445F | 13, 15, 19, 27, 29 (0A) | level slide 0200/D000 and `trk_sound` FE for the sound of command A | 445F-4495; MAME below |
| `cmdtype_0B_release_priority` | 4496 | 0B, 0E (0B) | the same where `trk_priority` / 4 = A | 4496-44C3; MAME below |
| `cmdtype_10_ymtimer` | 44C4 | none (10) | `ymtimer_start` unless below `min_priority` | 44C4-44CF |
| `queue_response` | 44D0 | 09 (09), op 96 | A into `resp_queue` | 44D0-44EB |
| `cmdtype_0D_run_op` | 44EC | none (0D) | runs a stream op on a sound's tracks, from `tbl_65DD` | 44EC-4532 |
| `imm_03_send_status` | 4533 | 07 (immediate) | sends `board_status`, sets its bits 0 and 2 | 4533-4542; MAME below |
| `imm_02_send_count` | 4543 | 06 (immediate) | sends 6D | 4543-4547; MAME below |
| `imm_return` | 4548 | | pulls X and Y, `nmi_mode` FF, pulls A, RTI | 4548-4552 |
| `send_response` | 4553 | | waits for the buffer, writes, waits for the read | 4553-4568 |
| `cmdtype_08_start_sound` | 4569 | 32 commands (08) | one track per entry, linked by priority | 4569-46A3 |
| `cmdtype_none` | 46A4 | none (0C, 0F, 12) | RTS | 46A4 |
| `init_track` | 46A5 | | presets a track's arrays | 46A5-4728 |
| `cmdtype_0E_set_mix` | 4729 | none (0E) | `mix_shadow` = MIX = A | 4729-472E |

The handlers are named by what the 6502 does; the 68010's names for the commands are leg M4e's (`data/sound/commands.json`).

**MAME evidence (probe, not committed).** A scratch Lua script (the session scratchpad's `m4c/jsaprobe.lua`) writes command bytes at 600000 from the 68010's address space on chosen frames (as `okitrace.lua` does), presses the JSA II coin inputs (`:mainpcb:jsa:JSAII`, "Coin 1"-"Coin 3"), and logs YM2151 key-ons, responses (write tap on 2A02 with the PC), WRIO writes, writes of RAM 1E, 67-6A and 75, writes of `trk_sound` (0248-0265), and every read of 088E at 4EE3 with RAM 1E at that moment. Two runs, each headless (`SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle -autoboot_delay 0`) from an empty private NVRAM and cfg under `build/mame/m4c-probe/`, with the reference set:

- Run A, 4000 frames: `PROBE_INJECT="1200:31,1500:04,1800:02,1804:04,2400:03,2500:06,2600:07,2700:08,2710:5A,2800:07,3900:03"`, `PROBE_COINS="3000:1:10,3300:2:10,3600:3:10"`. Attract mode writes `min_priority` F0 at 438C (frame 831, command 01). Command 31 (sound 1A, priority 32, priority byte C9) at 1200 and command 04 (sound 00, priority 03) at 1500 key nothing on; after 02 (`min_priority` 0 at 438C, frame 1800) key-ons follow at once. The reads at 4EE3 saw 0D, 65, 9D, A1 and C9 against F0 and against 00, never a value at or above F0. The immediate commands answered through `send_response` (PC 455D): 03 gave 00, 06 gave 6D, 07 gave 00 (twice: `main_loop` and the timed IRQ both run), 08 gave AA and then 5A, the byte written 10 frames later. The coins: section 10.6; 03 at frame 3900 then gave 45.
- Run B, 2200 frames, the same and the `trk_sound` writes: `PROBE_INJECT="1200:32,1500:2D,1560:2E,1700:12,1760:13,1900:0A,1960:0B"`. Command 32 (sound 1B, entry 78, priority 3F, priority byte FD) keyed channel 3 on at frame 1200 with `min_priority` F0; the gate read FD against F0 361 times. Command 2E (type 05, A = 2D) set `trk_sound` FF at 4406 on the track command 2D had started. Command 13 (type 0A, A = 12) set FE at 448C on the six tracks of command 12's sound (07); they ended (FE to FF) at 5547 (op 9D) and 4809 (the slide's end). Command 0B (type 0B, A = 27) set FE at 44BC on five tracks of priority 27, ended at 5547 and 4809.

So `min_priority` is a floor on the track priority, as its name says, and not a volume: a sound of priority 3F plays through command 01's F0.

### 10.3 `nmi.asm`

| Name | Address | What the code does | Evidence |
|---|---|---|---|
| `h_nmi` | 57E3 | waits for the response buffer, then stores (mode 0), drops (other modes) or queues/dispatches (mode FF) the command byte | 57E3-5848 |
| `nmi_return_x`, `nmi_return` | 5849, 584B | the exits: pull X; pull Y and A, RTI | 5849-584E |
| `nmi_immediate` | 584F | `cmd_class` 0-3: `imm_handlers` entry class+1 by RTS; 4-7F dropped | 584F-585D; executed by the probe (section 10.2) |

### 10.4 `oki.asm`

| Name | Address | What the code does | Evidence |
|---|---|---|---|
| `oki_reset` | 5BAC | WRIO bit 2 low then high; clears 56-67 | 5BAC-5BC5 |
| `oki_tick` | 5BC6 | every eighth tick: stops a channel playing for 256 of them (about 8.2 s), clears `oki_duck` of idle channels and, in the same tick, of a channel it stops (5BE9 falls into 5BEB) | 5BC6-5BF9 |
| `op_95` | 5BFA | stream op 95: the OKI start of command A's parameter | 5BFA-5BFD (op names are M4d's) |
| `cmdtype_13_oki_play` | 5BFE | the effect entry A: phrase `tbl_6532`, channel and attenuation `tbl_6567`, duck `tbl_659C` | 5BFE-5C62; `make okitrace` (docs/10) |
| `oki_start_bits`, `oki_busy_bits`, `oki_stop_bits` | 5C63, 5C67, 5C6B | channels 1-4's bit in the start's second byte, the status, the stop byte | okim6295.cpp 220-222, 238-247, 303-308 |
| `cmdtype_14_oki_stop` | 5C6F | stops the first channel (from 4) playing phrase A | 5C6F-5C86 (not executed in the `make sndtrace` runs: no run sends command 66); docs/10 section 4 |
| `oki_duck_ym` | 5C87 | MIX's YM2151 volume = `mix_shadow`'s - the largest `oki_duck` / 2 | 5C87-5CB7 |

### 10.5 `ymtimer.asm`

| Name | Address | What the code does | Evidence |
|---|---|---|---|
| `ymtimer_reset` | 585E | clears `ymt_phase`, `ymt_count`, `ymt_toggle`, `ymtimer_active` | 585E-5868; called by `init_sound` 42A9 |
| `ymtimer_start` | 5869 | loads `ymtimer_patch` into channels 6-7, filter on, page select, `ymt_ptr`, key codes and attack rates, timer A on | 5869-59BF |
| `ymtimer_irq` | 59C0 | one timer-A step: key 6 or 7, period, operator registers by groups of 0E bytes; a 0 byte ends it | 59C0-5B62 |
| `ymtimer_write` | 5B63 | register X = the next data byte | 5B63-5B6F |
| `cmp_list_priority` | 5B70 | C set when `ymt_priority` OR 1 (5B7A-5B7E) is not below the priority of the last track from X | 5B70-5B81 |
| `ymtimer_patch` | 5B82 | 42 bytes, the patch `sub_55B4` loads (its fields are M4d's patch format) | 5892-5898, 58C2-58C8 |

None of it runs (no command has type 10, section 3). `tbl_65DD`, which the path indexes for its priority, outputs, page and data pointer, is 9 zero bytes before the first stream: for entry 0 the data pointer would be 0000, so the data this path was written for is not in this ROM's tables. `cmp_list_priority` is entered with X = a list head (1 + the first track, 5872-5877 and 587E-5883) without the DEX the other walk of the same lists does (5A0C-5A11), so it starts from the wrong track: a latent fault in dead code.

### 10.6 `io.asm`

| Name | Address | What the code does | Evidence |
|---|---|---|---|
| `imm_04_loopback` | 5CB8 | sends AA, receives one byte, sends it back | 5CB8-5CC4; MAME (section 10.2) |
| `receive_bytes` | 5CC5 | `nmi_mode` 0 with `nmi_data_ptr` at `rx_buffer`, sends AA, waits for A bytes | 5CC5-5CE7 |
| `read_inputs` | 5CE8 | self-test mode: the four RDIO bits into `coin_state`; else `count_coins` | 5CE8-5D08 |
| `coin_field_one`, `coin_field_mask` | 5D09, 5D0D | each input's 2-bit field in `coin_state` | 5CF4, 5CFD, 5D48, 5D50 |
| `count_coins` | 5D11 | debounce, count, one WRIO counter pulse per coin | 5D11-5DAC; MAME below |
| `imm_01_send_inputs` | 5DAD | sends `coin_state` | 5DAD-5DB4; MAME (section 10.2) |

The inputs, X = 3-0, are RDIO bits 0-3: coin 1, coin 2, coin 3 and bit 3 (unused in `jsa_ii_ioports`). **MAME (run A of section 10.2)**: JSA "Coin 1" held for frames 3000-3010 was counted at frame 3012, 2 frames after the release (`coin_state` 04 at 5D55, `coin_pulse`+3 01 then F0 at 5D8E), and WRIO went 05 to 15 (counter 1) for frames 3012-3016 while `coin_pulse`+3 counted F0 down to 80 by 10 every other tick; "Coin 2" gave `coin_state` 05 and WRIO 25 (counter 2); "Coin 3" `coin_state` 45 and WRIO 15. So coin 1 and coin 3 drive counter 1, coin 2 (and bit 3) counter 2, and a coin counts on its release, about 8 ticks after it, if it was held at least 5 ticks (`count_coins`'s header has the debounce). Whether the real JSA II board has coin switches on these bits is not established (section 1); the 68010 has its own coin inputs.

### 10.7 `tables.asm`

| Name | Address | What it is | Evidence |
|---|---|---|---|
| `empty_envelope` | 5DB5 | 4 zero bytes, `init_track`'s envelope pointers point here | 4718-4725; 4AB0-4AC1 |
| `note_periods` | 5DB9 | 98 words, each the one before / 2^(1/12): engine 1's pitch per note | 48BF-48D4 |
| `key_codes` | 5E7D | 98 bytes: the YM2151 key code (octave, note without 3, 7, B, F) per note | 4F02, written to register 28+ch 4F08 |
| `nibble_scale` | 5EDF | 16 x 16: a scaled product of two nibbles, added to the operators' levels | 4F75, 4F87 |
| `level_bias` | 5FDF | 00 00 24 58 by the note's length-byte bits 5-4, subtracted from the level offset | 4F24-4F38 |
| `note_lengths` | 5FE3 | 16 words: the wait of a length code (1E00 the longest, halves, thirds, fifths) | 498F-49BC, 4CD3-4CD9 |
| `slide_rates` | 6003 | 16 bytes: the level slide's step by its length code | 4CE5-4D2A |
| `level_curves` | 6013 | 8 x 16 signed steps added to engine 1's level | 4C5C-4C75 |
| `cmd_class`, `cmd_type`, `cmd_param`, `imm_handlers` | 6093, 6100, 616D, 61DA | the command tables (section 5) | |

### 10.8 `hardware.asm`

The port equates and their `_M` mirrors are the IDA names (docs/05 section 4) and do not change. New equates, each with the MAME 0.289 line that defines it: the RDIO bits (`RDIO_SELF_TEST`, `RDIO_NMI_LOW`, `RDIO_RESP_FULL`, `RDIO_COIN1`-`3`; `rdio_r` and `jsa_ii_ioports` 189-199), the WRIO bits (`WRIO_BANK`, `WRIO_COUNTER2`/`1`, `WRIO_OKI_PIN7`, `WRIO_OKI_RUN`, `WRIO_OKI_BANK`, `WRIO_YM_RUN`; `wrio_w` 487-528), the MIX bits (`MIX_LPF`, `MIX_OKI_BANK`, `MIX_YM_VOLUME`, `MIX_OKI_FULL`; `mix_w` 536-560), the YM2151 status bits and the register numbers the system code writes (ymfm `ymfm_opm.h` 121-123, 175-217), the two timer-control values (`YM_TIMER_A_RUN` 15, `YM_TIMER_A_STOP` 14) and the M6295's `OKI_PHRASE` (okim6295.cpp 232-310). The bits come from atarijsa.cpp, not from docs/01 (whose RDIO row M4e corrects). One fact the names make visible: YM2151 register 1B bits 7-6 are the chip's CT2 and CT1 outputs, MAME's `ym2151_port_w` (328) takes them, and `update_all_volumes` (630) multiplies the M6295's gain by CT1. `init_board` sets both (`ym_1b_shadow` C0, written by `init_sound`), so the samples are heard; `cmdtype_11_ym_ct` (no command) and op A5 could silence them.

### 10.9 `ram.asm`

The split (issue #16): a variable only `sequencer.asm`, `data/**` or `lookup.asm` use is M4d's and keeps its neutral equate line; every other one is named here. Computed with grep over the code (comments excluded) of every file:

- **M4d's (unchanged)**: `zp_06`, `zp_07`, `zp_0F`, `zp_1D`, `zp_22`, `zp_48`, `ram_0536`, `ram_0590`, `ram_088C`, `ram_088D`, `ram_088E`, `ram_088F`, `ram_0893`, `ram_0895`-`ram_0899`, `ram_089A`, `ram_089E`, `ram_08A2`-`ram_08A4`, `ram_08AB`.
- **Named by M4c**: every other variable. The zero page: `tick_count`, `irq_test_mode`, `board_status`, `start_sound`, `engine_chip` (08-09, written, never read), `fm_op_index`, `ym_channel`, `ym_timed_out`, `ymtimer_active`, `irq_busy`, `irq_again`, `start_entry`, `start_ptr`, `start_tmp`, `tmp_ptr`, `tmp_1B`, `tmp_1C`, `min_priority`, `frame_free`, `frame_ptr`, `seq_vars` (23-42), `unused_43`, `rng_state`, `ymt_ptr`, `ymt_count`, `ymt_phase`, `ymt_toggle`, `ymt_entry`, `ymt_priority`, `oki_tmp`, `oki_divider`, `oki_entry`, `oki_time_lo`, `oki_time_hi`, `oki_duck`, `rx_count`, `rx_buffer`, `coin_pulse`, `coin_debounce`, `coin_ticks`, `coin_state` (with the M4a names `nmi_data_ptr`, `mix_shadow`, `wrio_shadow`, `ym_1b_shadow`). The track arrays: `trk_sound`, `trk_ptr_lo`/`hi`, `trk_pitch_lo`/`hi`, `trk_wait_frac`/`lo`/`hi`, `trk_gate_frac`/`lo`/`hi`, `trk_length_byte`, `trk_priority`, `trk_curve_index`, `trk_scale_ptr_lo`/`hi`, `trk_key_fraction`, `trk_op_tl` (four rows: the former `ram_0482`, `ram_04A0`, `ram_04BE`, `ram_04DC` are `trk_op_tl`, `+$1E`, `+$3C`, `+$5A`), `trk_level_offset`, `trk_reg20`, `trk_patch_hi`, `trk_keyon_flags`, `trk_slide_wait_frac`/`lo`/`hi`, `trk_slide_step`, `trk_tempo_lo`/`hi`, `trk_transpose`, `trk_sync_state`, `trk_sync_group`, `trk_e1_ctl`, `trk_glide_rate`, `trk_glide_lo`/`hi`, `trk_call_frame`, `trk_loop_frame`, `trk_loop_count`, `trk_slide_time_lo`/`hi`, `trk_slide_rate_lo`/`hi`, `trk_slide_frac`, `trk_acc`, `trk_test`, `trk_link`, `chan_list` (the former `ram_0884` and `ram_0885` are `chan_list+6` and `+7`); and `cmd_target_sound`, `cmd_op_operand`, `ym_shadow` (08AE, 256 bytes: the last value written to each YM2151 register).

Each equate's comment in `ram.asm` gives the instructions that write and read it. Most track arrays are read and written mostly by the sequencer, so their names rest on its code: the timers (`trk_wait`, `trk_gate`, `trk_slide_wait`) on the subtraction of `trk_tempo` each tick (4791-47CB, 480F-4826) and the additions of `note_lengths` (498F-49BC); the frames on ops 8D, 8E and 8F (5235-52BC) and the pops at 4919-493E; the slide on op A4 (52C5-52E7) and its step (4CC1-4D6A); the sync on ops 88 and 89 (5125-5187); `trk_op_tl` on 4D8D-4DA0 (to registers 60-7F) and op 9D (5570-5580). M4d, which documents the sequencer, may refine them; a rename there is a rename of this file's line (whichever PR merges second re-applies the other's renames).

Kept neutral on purpose: `tmp_1B` and `tmp_1C` are scratch bytes with no meaning across routines (the Spindizzy rule: general-purpose zero-page scratch is not given a role name); `tmp_ptr` is scratch too but a pointer in most of its uses; `unused_43` is written 0 by `init_sound` (42C3) and read by nothing.

### 10.10 Latent faults the names make visible

The first runs at every `init_sound`; the others are not reached in the traces and are from the code alone.

- `init_frame_pool` (42D8-4308): the loop links frame 1 to 2 and so on up to C6 to C7 and leaves at C8 (42F7-42F9), but `_last` begins with `DEC frame_ptr+1` (42FB), which undoes the INC of the other exit (42EE, when the pool would reach 1F00) and is wrong on this one, where no carry happened: `frame_ptr` goes from 0CC6 (frame C7) to 0BC2, not to 0CC2, and the terminating 0 lands on frame 86's link (4306). The free chain is frames 1-86, 134 of them; frames 87-C7 are never reached. A headless MAME probe (a frame notifier reading the 6502's RAM at frame 400 of the rebuilt set, from empty private state) walked the chain: `frame_free` 01, the chain ends at frame 86 after 134 frames, 0BC2 = 00, 0CC2 = C7.
- `alloc_frame` (4309-4319): when the free frame is the last (its link 0, frame 86), it returns with the A it pushed at 430E still on the stack, so the RTS goes to a wrong address. Only frames 1-85 (133) can be taken, so the 134th frame held at once takes this path; no trace came near. `frame_free` is never 0: `_none` does not store it.
- `cmdtype_08_start_sound` (45E4-45E9): a track taken from the head of a full list is re-initialised by `init_track` without `free_track_frames`, so frames it held are never returned (the same-priority replacement at 465A-4664 does free them).
- `cmp_list_priority` (5B70) is entered one track off (section 10.5); dead code.
- `oki_reset` (5BBC-5BC4) clears 18 bytes from 56: besides the OKI state, `rx_count`, `rx_buffer`, three unused bytes and `coin_pulse`+0.

### 10.11 Not verified

- The self-test (402A-4112, 418C-41BC) still cannot run in MAME 0.289; its names rest on the code.
- `ymtimer.asm` never runs; its names rest on the code and the YM2151 register map.
- Engine 1's uses of the shared arrays (envelopes, `note_periods`, `level_curves`, `trk_e1_ctl`) are from code no trace executes (no sound uses engine 1); what chip engine 1 was written for is not in this program (`engine_chip` 0000).
- `level_bias` and `nibble_scale` are described by what the code computes with them; what the computed level means musically (velocity, key scaling) is M4d's to establish.
- The probes of section 10.2 are scratch scripts, not committed; their commands and results are above.
