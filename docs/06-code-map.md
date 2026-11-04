# The code map: where each program lives

**Date**: 2026-11-04 (milestone 2). Where the four programs of the 68k image are, how the 68k
loads the GSP and ADSP programs, the proof against MAME, and the partition of the 768 KB that M5
will cut into region files. Addresses are 68010 addresses (= offsets in
`build/stunrun-68k.bin`) unless marked GSP (bit addresses) or ADSP (PM/DM word addresses).
**CODE** means read off the disassembly at the addresses given, **MAME** means a MAME 0.289 run
confirms it, **HYP** is a hypothesis. MAME source citations are `file:line` in
`~/.local/src/mame/src/mame/atari/` (0.289) unless another directory is named.

## 1. Two 68k programs, two coprocessor programs

The 768 KB hold four programs:

- **The boot program**, pair R (0x000000-0x01FFFF), with its own vector table at 0. A self-test
  and start-up program shared with the Hard Drivin' family (HYP, section 4.4). Its reset path ends
  by installing the game's vector table and jumping to the game.
- **The game program**, pairs S-W (0x020000-0x0BFFFF), with its vector table at 0x020000.
- **The ADSP-2100 program** and **the TMS34010 (GSP) program**, both inside pair R at
  0x01702E-0x01EFD4, reached through a two-long table at 0x017000 and loaded by the game.

### 1.1 Reset and the VBR switch (CODE, IDA names)

```
000216 boot_reset:      lea     $0.w,A0 / movea.l ($0,A0),A7 / movec A0,VBR
000254                  btst    #$5,$60c001.l     ; PORT0 bit 5, SELF-TEST (active low)
00025C                  beq     $2a0              ; boot_select_self_test
000264                  jsr     $3f8.l            ; boot_init_gsp
00026A                  jsr     $570.l            ; boot_load_gsp_palette
00027A                  jsr     $636.l            ; boot_fill_gsp_vram
000286 boot_start_game: lea     $20000.l,A0 / movea.l ($0,A0),A7 / movea.l ($4,A0),A1
000294                  movec   A0,VBR
00029E                  jmp     (A1)              ; 020004 holds 0212AE: game_reset
```

With the self-test switch on, 0x0002A0 reads PORT0 bit 0 (the DIAGN jumper,
harddriv_m.cpp:201-217) and jumps to 0x008FEE or 0x00506C. `game_reset` (0x0212AE) clears RAM,
`clear_gsp_vram`, `clear_msp_ram`, 0x020702, then the main initialisation 0x024306, which calls
`init_coprocessors` (0x02C0D2) at 0x0243AC. `soft_reset` (0x021286) starts with `stop #$2700`,
so a fatal error waits for the watchdog with every interrupt but level 7 masked (HYP); the code
after it sets VBR = 0 and jumps through the boot vector table.

0x020100 holds three `jmp` (`game_entries`) to `game_entry_1..3` (0x021334, 0x021378, 0x0213B6):
reset variants that skip the warm-start check and call 0x02DCE0, 0x043718 or 0x03CE64 instead of
the main initialisation. Nothing in the ROM references 0x020100 (searched as absolute longs and
IDA cross-references); HYP: entry points for development tools.

### 1.2 The two vector tables and their interrupt handlers (CODE)

The autovectors carry this board's interrupt sources (docs/01 section 3). What each handler
acknowledges:

| Level | Boot table (0x000000) | Game table (0x020000) |
|---|---|---|
| 1 MSP | `boot_level1_msp` 0x0007FA: FF80E6 = FFFF, clears the MSP's INTOUT (C04008 &= FF7F) | `h_trace_etc` 0x0229D4 (the default for 9-11, 24, 25, 32-47): reports error 15, `soft_reset` |
| 2 ADSP | `boot_level2_adsp` 0x0007F0: registers only, does **not** clear 818060 | `h_level2_adsp` 0x0213FE: `clr.w $818060` (hd68k_adsp_irq_clear_w, harddriv_m.cpp:751), calls 0x02E418, `clr.w $818010` (control line 0 = 1, an LED) |
| 3 GSP | `boot_level3_gsp` 0x0007D6: FF9046 = FFFF, clears HSTCTL INTOUT (C00008 &= FF7F) | `h_level3_gsp` 0x02143C: FFDB48 = FFFF, clears INTOUT, frame time into FF9BAA |
| 4 sound | `boot_level4_sound` 0x00081C: reads the JSA response 600000 | `h_level4_sound` 0x023F24: appends the response byte to the buffer at FF9470 |
| 5 timer | `boot_level5_timer` 0x00082C: ticks FF9042, ADCs, `boot_read_wheel`, `clr.w $60c000` (IRQ5_ACK) | `h_level5_timer` 0x0222DA: ticks FF8014, calls 0x02FFF0, `clr.w $60c000` |
| 6 DUART | `boot_level6_duart` 0x000812: registers only | `h_level6_duart` 0x0239FE: services both DUART channels |
| 7 | `boot_spurious_interrupt_etc` 0x01082C | `h_level7_nmi` 0x0229C4: reports error 14, `soft_reset` |

The GSP's INTOUT is bit 7 of HSTCTLL: the GSP sets it, the host clears it
(tms34010.cpp `io_register_w`, `src/devices/cpu/tms34010/tms34010.cpp`, the HSTCTLL case). The
game's GSP program sets it after each command buffer (GSP FFF41910, section 6.2). The game's
exception vectors 2-8 go to seven stubs at 0x022954-0x0229B4 that call a reporter and then
`soft_reset`. The IDA names are `boot_*` for the boot table's targets and `h_*` /
`game_reset` for the game's; the vector longs are `vec_*` and `game_vec_*`.

## 2. The program table at 0x017000

| Address | Name | What | Evidence |
|---|---|---|---|
| 0x017000 | `adsp_program_ptr` | long 0x01702E | read at 0x02C204 (`move.l $17000.l,-(A7)`) for `load_adsp_program` |
| 0x017004 | `gsp_program_ptr` | long 0x01907C | read at 0x02C1B6 and 0x02DCB0 for `load_gsp_program` |
| 0x017008 | `program_table_long_8` | long, purpose unknown | no reader; not a byte, word or long sum, nor a CRC-32, of the ADSP stream, the GSP table, both, or pair R (checked) |
| 0x01700C | `program_table_long_c` | long, purpose unknown | no reader |
| 0x017010 | `copyright_text` | the ASCII text "Copyright 1989 ATARI GAMES" (26 bytes), two zero bytes | |
| 0x01702C | | a word, purpose unknown | no reader |

## 3. The two loaders and the two formats

Both are implemented by `tools/programs.py` exactly as the 68k code does them, with the
instruction addresses in its docstring; `tools/extract-programs` runs it (`make`).

### 3.1 ADSP: `load_adsp_program` (0x02D2E0), called from 0x02C20A

Record stream at 0x01702E-0x01907C (8,270 bytes), as the loader reads it:

```
{ flag byte (0 = a record follows; anything else ends the stream, 0x02D30A),
  word address A, big-endian 16 bits (0x02D30E-0x02D31A),
  count N, big-endian 16 bits (0x02D32C-0x02D33A),
  N opcodes, packed big-endian 24 bits (0x02D342-0x02D35A) }* , 0xFF
```

Each opcode is assembled into D0 with a zero top byte and stored with `move.l D0,(A2)+` at
0x800000 + 4·A onwards (0x02D35C). MAME's 68k window over program RAM puts the even 16-bit half
in bits 31-16 of the 32-bit word (`hd68k_adsp_program_w`, harddriv_m.cpp:556), so PM word A
receives the opcode. Seventeen records, 2,728 words:

| Records | PM words | 68k destination |
|---|---|---|
| 15: 0000/F6, 00F6/1E, 0114/60, 0174/A0, 0214/48, 025C/256, 04B2/39, 04EB/F2, 05DD/54, 0631/32, 0663/3E, 06A1/DF, 0780/8B, 080B/29, 0834/67 | 0000-089A | 800000-80226B |
| 2: 1029/0D, 1036/200 | 1029-1235 | 8040A4-8048D7 |

The control lines around it (ADSP control latch at 818000: the word offset's bits 0-2 select the
line, bit 3 is the value; `hd68k_adsp_control_w`, harddriv_m.cpp:685; line 5 /BR at :704, 6
/HALT at :721, 7 reset at :738): before the load `clr.w` 818008 (line 4 = 0), 81800A (/BR
asserted), 81800E (reset asserted), 81800C (/HALT asserted); after it 818018, 81801A, 81801E
(line 4, /BR and reset released, 0x02D366-0x02D372). `init_coprocessors` then restarts the ADSP
at 0x02C212: reset, line 4 and /BR asserted again, DM 1FFF = FFFF through 80BFFE (the frame
trigger's idle value), 818060 (interrupt cleared), 818014 and 818016 (lines 2 and 3 = 1: line 3
is the SOM bank), and reset, line 4, /BR and finally /HALT released (0x02C26E `clr.w $81801c`).
Lines 2 and 4 do nothing in MAME (the default case); their function is unknown.

The ADSP's start address is not written by the 68k: the ADSP-2100 starts at PM 0004
(adsp2100.cpp:636 in `src/devices/cpu/adsp2100/`), and MAME shows PC 4 while the 68k holds it in
reset.

### 3.2 GSP: `load_gsp_program` (0x02FDD0), called from 0x02C1BC

Section table at 0x01907C-0x01EFD4 (24,408 bytes):

```
section count, big-endian 32 bits (0x02FDEA)
{ destination GSP bit address, big-endian 32 bits (0x02FE1A),
  length in bits, big-endian 32 bits (0x02FE1C),
  data: ceil(length / 32) big-endian longs }*
```

`load_gsp_program` calls `init_gsp` (which pulses /GSPRES through `reset_gsp`), sets HSTCTL =
B800 (HLT, LBL, INCR, INCW: the GSP stays halted and the host address autoincrements on write,
0x02FDE2), and `load_gsp_section` (0x02FE0C) writes the destination with `move.l D0,$C00002`
(0x02FE1E). The 68k's host window maps word offset n to host register `(n/2)^1`
(`hd68k_gsp_io_w`, harddriv_m.cpp:150), so C00002 is HSTADRH and C00004 HSTADRL, C00008 HSTCTL
and C0000C HSTDATA (TMS34010_HOST_* in `src/devices/cpu/tms34010/tms34010.h`:1094-1097). While
32 or more bits remain, `write_gsp_long` (0x02FE5E) writes each long to HSTDATA **low word
first** (0x02FE68), then the high word (0x02FE6E); each write stores 16 bits at the host address
and adds 0x10 (`host_w`, tms34010.cpp, HSTCTLH INCW). A 16-bit remainder writes the low word of
one more long (0x02FE4A); any other remainder calls `soft_reset` (0x02FE40).

| Section | 68k source (data) | GSP destination (bits) | Bytes | What |
|---|---|---|---|---|
| 0 | 0x019088-0x01C4B8 (header 0x019080) | FFF40000-FFF5A170 | 13,360 | code (HYP `.text`): `gsp_main` FFF40000, the idle loop FFF41070, the reset entry FFF59920 |
| 1 | 0x01C4C0-0x01C9B0 (header 0x01C4B8) | FFF5A170-FFF5C8F0 | 1,264 | read by the start-up at FFF59B20/FFF59C70 (HYP: TI C `.cinit` records) |
| 2 | 0x01C9B8-0x01EF4C (header 0x01C9B0) | FFF5C8F0-FFF6F580 | 9,620 | initialised data (HYP `.data`) |
| 3 | 0x01EF54-0x01EFD4 (header 0x01EF4C) | FFFFFC00-FFFFFFFF | 128 | the 32 trap vectors; vector 0 (reset, FFFFFFE0) = FFF59920 |

The program occupies 24,368 bytes of VRAM. In this board's GSP map VRAM is 512 KB at FF800000,
mirrored at FFC00000 (`multisync_gsp_map`, harddriv.cpp:628), so the program also appears at
FFB40000. The 68k never writes the GSP's PC: after the load, `init_coprocessors` writes HSTCTL =
7800 then 3800 (0x02C1C4, 0x02C1CC: HLT cleared, cache flushed once) and the GSP starts from its
reset vector.

### 3.3 The serial download monitors

`init_coprocessors` reads two DIP switches before each load (PORT0 high byte, SW1 at
harddriv_m.cpp:201-217; all on, i.e. 0, in MAME's defaults):

- SW1 #2 (`btst #6,$60c000`, 0x02C1A0) selects `download_gsp_program` (0x02FCC0) instead of the
  ROM: it waits for ten `S` and a `G` from the DUART (getc 0x023C9A), then reads sections in the
  ROM format as longs through 0x02FF8E, each followed by a checksum (`soft_reset` on a mismatch,
  0x02FDBE).
- SW1 #4 (`btst #4,$60c000`, 0x02C1EE) selects `download_adsp_program` (0x02D1D4): ten `A` and a
  `G`, then records in the ROM format.

Both are development paths: the ROM formats are the download formats.

### 3.4 Extraction and the 68k tree

`tools/extract-programs` (run by `make` after `tools/merge-roms`, before the 68k tree is
assembled) writes:

| File | What |
|---|---|
| `build/adsp/program.bin` | 0x01702E-0x01907C as is: what `asm/68k/stunrun.asm` incbins under `adsp_program` |
| `build/gsp/program.bin` | 0x01907C-0x01EFD4 as is, under `gsp_program` |
| `build/adsp/pm.bin`, `pm.ranges.json` | program RAM after the loader: 0x2000 words as 32-bit little-endian (top byte 0), zero where nothing is loaded; the loaded word ranges, one per record |
| `build/gsp/vram.bin`, `vram.ranges.json` | a sparse byte image of GSP bit addresses FF800000-FFFFFFFF (byte offset = (bit address - FF800000) / 8, 16-bit words little-endian) written only where loaded; the loaded bit ranges, one per section |

It checks that the table at 0x017000 points to 0x01702E and 0x01907C, that the ADSP stream ends
exactly where the GSP table starts and that the GSP table ends at 0x01EFD4; the 68k tree asserts
the same boundaries. Pair R is split into four statements:

```
rom_r:        incbin "../../build/stunrun-68k.bin",$000000,$1702E
adsp_program: incbin "../../build/adsp/program.bin"      ; asserts * = $01907C after it
gsp_program:  incbin "../../build/gsp/program.bin"       ; asserts * = $01EFD4 after it
rom_r_tail:   incbin "../../build/stunrun-68k.bin",$01EFD4,$20000-$01EFD4
```

`make coverage` now lists every blob by label with the file it includes and its size:

```
adsp_program            1702E     8270  ../../build/adsp/program.bin      asm/68k/stunrun.asm
gsp_program             1907C    24408  ../../build/gsp/program.bin       asm/68k/stunrun.asm
```

## 4. The partition of the 768 KB

Function extents are IDA 9.1's after `make ida` with this leg's snapshot (639 functions); data
references are IDA's cross-references from code heads. "Read by" ranges come from a MAME read
watchpoint on the 68010 over 3,600 frames of attract mode and one game started at frame 960
(`wpset`, method as in section 7; a scratch script, not committed).

### 4.1 Pair R, the boot program (0x000000-0x01FFFF)

| Start | End | Bytes | Owner / consumer | Evidence |
|---|---|---|---|---|
| 0x000000 | 0x000100 | 256 | boot vector table (64 longs) | docs/05 section 3 |
| 0x000100 | 0x000212 | 274 | not a vector table; unclassified | docs/05 section 3 |
| 0x000212 | 0x012DC6 | 76,724 | boot code with data islands | first function `boot_line_a_etc` 0x000212, last `sub_12DBC` 0x012DBC-0x012DC6; 135 functions; islands such as 0x00FB08-0x01076A (referenced from 0x002334, 0x009178) |
| 0x012DC6 | 0x012F06 | 320 | boot data | referenced from 0x00F2A4 (0x012DD2) and 0x00F2B6 (0x012DDE) |
| 0x012F06 | 0x017000 | 16,634 | zero fill | |
| 0x017000 | 0x01702E | 46 | program table, two unknown longs, copyright text, an unknown word | section 2 |
| 0x01702E | 0x01907C | 8,270 | **ADSP program** (`adsp_program`), consumer `load_adsp_program` | section 3.1 |
| 0x01907C | 0x01EFD4 | 24,408 | **GSP program** (`gsp_program`), consumer `load_gsp_program` | section 3.2 |
| 0x01EFD4 | 0x020000 | 4,140 | zero fill | |

### 4.2 Pairs S-W, the game program (0x020000-0x0BFFFF)

| Start | End | Bytes | Owner / consumer | Evidence |
|---|---|---|---|---|
| 0x020000 | 0x020100 | 256 | game vector table | installed by 0x000294 |
| 0x020100 | 0x020112 | 18 | `game_entries`, three `jmp` | section 1.1 |
| 0x020112 | 0x020419 | 775 | zero fill | |
| 0x020419 | 0x020430 | 23 | game data | referenced from 0x0209AC, 0x020A88, 0x042324 |
| 0x020430 | 0x046AEE | 157,374 | game code with data islands | first function `sub_20430`; 427 functions in pair S, 77 in pair T, the last `sub_46AC4` 0x046AC4-0x046AEE; an island 0x0436FE-0x046A00 holds data (32 references, e.g. 0x0439BC from 0x041F1C, 0x0461F0 from 0x02444E) |
| 0x046AEE | 0x05CF86 | 91,288 | game data (68k consumer) | 724 references from code, the first 0x046AEE from 0x046A0C, the last 0x05C63C from 0x043720 |
| 0x05CF86 | 0x060000 | 12,410 | zero fill | |
| 0x060000 | 0x09F1C5 | 258,501 | packed GSP images, consumer `unpack_gsp_image` (0x0225E4), which streams them into HSTDATA | MAME read watch: every read of 0x060002-0x09F1C4 comes from 0x0225BC-0x02270A; no IDA reference into pairs U-V from code |
| 0x09F1C5 | 0x0B10EB | 73,510 | consumer unknown | no read in the watched run, no code reference into 0x0A0000-0x0B10EB; HYP: more packed images (other levels) |
| 0x0B10EB | 0x0BFE05 | 60,698 | zero fill | |
| 0x0BFE05 | 0x0C0000 | 507 | a table read by game code | 14 references (0x0BFE08 from 0x02D7EC ... 0x0BFF14 from 0x02DB62); read watch: 0x0227A2, 0x024F20, 0x029C44, 0x02D780-0x02D7F2, 0x02DAA4, 0x040586 |

Code ends at 0x046AEE: the last IDA function ends there, MAME's highest 68k PC is 0x046AEC
(section 7), and the first data reference past it is to 0x046AEE itself. The zero runs inside
`gsp_program` (0x01D4AC-0x01D80D, 0x01ED4C-0x01EF4C) are program data, not fill. Pair U-V's
packed images carry a 16-entry table (`unpack_gsp_image` builds it at FF902A through 0x0225B0);
their format is M5d's.

### 4.3 Operands outside the docs/01 map (from M1b)

| Operand | Instructions | Hypothesis |
|---|---|---|
| 0x0E0000-0x0E8000 (16 operands in IDA) | boot self-test 0x00619E-0x00626C: reads E0000, E0010, E0000, E0010, then E8000 or E7FFF; the same sequence at 0x001A40-0x001AE0 (unidasm; not yet code in IDA) | a slapstic unlock and bank test: MAME maps a slapstic at E0000-E7FFF for Hard Drivin' (harddriv.cpp:1467-1468) and removes it for stunrun (:1866). MAME maps 0x000000-0x0FFFFF as ROM (`multisync_68k_map`, harddriv.cpp:602) over a 1 MB region (harddriv.cpp:2691), so the reads return zeros |
| 0x400000 (read), 0x408000 (`clr.w`) | `boot_read_wheel` 0x0008C2, called by the boot level-5 handler | the compact Hard Drivin' steering wheel and its edge reset (`hdc68k_wheel_r`, `hdc68k_wheel_edge_reset_w`, installed only for compact boards, harddriv.cpp:4810-4811) |
| 0x840000, 0x84C000 (`clr.w`) | `boot_reset` 0x000248, 0x00024E | no device in stunrun's map (`init_adsp` maps 800000-83FFFF, harddriv.cpp:4821-4835); HYP: other boards of the family |
| 0x818040 (`move.w #4`) | `stop_adsp` 0x021432, `soft_reset` 0x02129C, `game_reset` 0x0212B8 and the entries | outside MAME's ADSP control range 818000-81801F (harddriv.cpp:4833); unknown |

### 4.4 The boot program is the family's self-test (HYP)

The slapstic test and the compact-wheel reads have no hardware on this board, and the boot
program carries its own copies of the GSP set-up (`boot_init_gsp`, `boot_load_gsp_palette`,
`boot_fill_gsp_vram` vs the game's `init_gsp`, palette writers and `fill_gsp_vram`). HYP: pair R
is Atari's common Hard Drivin'-family self-test with the stunrun programs linked in at 0x017000.
Comparing it with a Hard Drivin' set's 0x000000-0x01FFFF would settle it (M7).

### 4.5 The copy to 0x018000

`copy_adsp_dram_to_18000` (0x02D6D8) copies 0x2000 words of ADSP data RAM (808000) to 0x018000,
which is ROM on this board (inside `gsp_program`): the writes go nowhere. No caller exists: no
absolute long equals 0x02D6D8 and IDA had not made it a function. HYP: a leftover from a
development system with RAM at 0x018000.

## 5. The oracle: MAME's memory after boot

`make oracle` runs MAME on the reference set with `tools/mame/dump.lua`:

```
DUMP_DIR=build/mame/ DUMP_FRAMES=600 mame stunrun -video none -sound none -nothrottle \
  -autoboot_delay 0 -seconds_to_run 600 -autoboot_script tools/mame/dump.lua
```

It writes `build/mame/gsp_vram.bin` (FF800000-FFFFFFFF, the layout of `build/gsp/vram.bin`),
`adsp_pm.bin` (PM 0000-1FFF as 32-bit little-endian), `adsp_dm.bin` (DM 0000-1FFF) and
`state.txt` (the three PCs), then exits. MAME 0.289 facts the script relies on: the devices are
`:mainpcb:maincpu`, `:mainpcb:gsp` and `:mainpcb:adsp`; the GSP program space is addressed in
bits (`read_u16` every 0x10); the ADSP program space is 32-bit and its data space 16-bit, both
in words; the frame-notifier subscription must be kept in a global (a local is collected and the
callback silently stops); ADSP DM 2000 and up is the board's I/O (a /SIMBUF read advances the
object ROM address), so only 0000-1FFF is read; at 120 frames the boot self-test still holds the
GSP halted and nothing is loaded, at 600 the GSP idles at FFF41070.

`tools/test_programs.py` (part of `make test`) compares, over the loaded ranges only:

- `build/adsp/pm.bin` with `adsp_pm.bin`: **2,728 of 2,728 loaded words equal**, every top byte
  0, at 600 and at 1,800 frames.
- `build/gsp/vram.bin` with `gsp_vram.bin`: **24,368 loaded bytes equal except one word**,
  FFF5C8F0, at 600 and 1,800 frames. That word is the first of section 2 and a variable the GSP
  program writes: `MOVE B9,@FFF5C8F0h,0` at FFF46340 and FFF479B0. It is the explicit
  exclusion list `GSP_RUNTIME_WORDS` in `tools/programs.py`, with those addresses; without it the
  comparison reports exactly `[FFF5C8F0]`.

The tests skip when the dumps or the extracted images are absent (CI). A planted difference
fails them: flipping one bit of PM word 025C and one of the GSP word at FFF41070 in the dumps
gives

```
E       AssertionError: 1 of 2728 loaded words differ: 025C
E       AssertionError: 1 loaded words differ: FFF41070
2 failed, 7 passed
```

(and the synthetic `test_diffs_find_planted_differences` checks the same on generated images in
CI). Outside the loaded ranges, PM 0000-089A and 1029-1235 hold nothing else: PM 089B-0FFF is
zero, and PM 1000-1FFF holds the program's workspace and runtime data (2,176 non-zero words at
600 frames, the 525 loaded ones included).

## 6. First listings and sidecars

`make dasm` runs `tools/dasm-programs` (unidasm over the oracle images, one run per contiguous
loaded range: `-arch adsp21xx -basepc 0` for PM 0000-089A and `-basepc 1029 -skip 16548` for
1029-1235; `-arch tms34010 -basepc fff40000 -skip 950272 -count 106864` and so on per section)
into `build/{adsp,gsp}/program.lst`, then `tools/annotate-listing` merges the committed sidecars
`data/adsp/annotations.json` and `data/gsp/annotations.json` (names and comments keyed by
address, no bytes) into `build/*/program.annotated.lst`. Every sidecar address must start a
listing line, or the merge fails. The listings contain the program bytes and stay in `build/`.

### 6.1 ADSP-2100 (PM word addresses)

The interrupt vectors are PM 0000-0003, one word each (IRQn vectors to PM n on the ADSP-2100,
adsp2100.cpp:880; the 2101's four-word slots do not apply), all `RTI`: the program runs without
interrupts. Reset enters at 0004. The frame loop:

```
0004 reset:               CALL $0780 / CALL $0834
0006 frame_loop:          L0 = $0000 ...
0013 wait_frame_trigger:  AR = DM($1FFF)
0014                      AR = NOT AR
0015                      IF EQ JUMP $0013          ; spin while DM 1FFF = FFFF
0017                      DM($1FFF) = AR            ; AR = FFFF: re-arm
0018 copy_frame_parameters: I0 = $0A00 ...          ; DM 001B = 0A00, the object list
002D select_object_page:  AR = DM($1FFE)
002E                      DM($2007) = AR            ; /MP
004C                      DM($2006) = AX0           ; /GINT: interrupt the 68k
009E read_object_pointer: DM($2001) = AR            ; /SIMCLK
00A0                      DM($2007) = AR            ; /MP = 0
00A3                      AR = DM($2000)            ; /SIMBUF
00C1                      DM($2006) = AX0           ; /GINT: frame done
00C2                      JUMP $0006
```

I/O (harddriv_m.cpp `hdadsp_special_r` :776 / `hdadsp_special_w` :803; DM 2000-2FFF,
harddriv.cpp:692): /SIMBUF read DM 2000 (case 0, :780), /SIMCLK DM 2001 (:807), SOMLATCH DM
2002 (:811), /SOMCLK DM 2003 (:815), /XOUT DM 2005 (:819), /GINT DM 2006 (:823), /MP DM 2007
(:829). The sidecar comments every access in the program (58 lines). The /SIMBUF readers are
`read_object_pointer` (00A3), `read_object_header` (0114: three reads at 011C, 011F, 0123) and
`read_object_record` (0174: /SIMCLK at 017B, reads at 017F and 0182, then `JUMP (I4)` at 0186
through the record-type table at 0187 on the top four bits of the second word), with the record
loop reading at 01B1, 01E4, 01EC and 01FC. The SOM writes start at 0034/0035 (/SOMCLK 0, first
SOMLATCH) and run through 0515-0682. `wait_frame_trigger` is the idle read of DM 1FFF that MAME's
speedup hooks (`init_stunrun`, harddriv.cpp:5096: `hdadsp_speedup_r` on DM 1FFF). PM 1000-1028
is a workspace that `copy_frame_parameters` fills from DM 1FE9-1FFD; the loaded PM 1029-1235
disassembles as noise (HYP: tables).

### 6.2 TMS34010 (bit addresses)

```
fff59920 reset:       SETF   20h,0,1
fff59930              MOVI   FFF793D0h,A9      ; A13 = A14 = FFF793D0
fff59980              MOVI   FFF98790h,A9      ; SP = FFF98790
fff599c0              MOVI   FFF6F580h,A11
fff599f0              MOVI   FFF98BB0h,A12
fff59a20 clear_bss:   CMP    A12,A11           ; clears FFF6F580-FFF98BB0
fff59b20              MOVI   FFF5A170h,A10     ; section 1
fff59ba0              CALLA  FFF59C70h         ; run_init_records
fff59bd0              CALLA  FFF40000h         ; gsp_main
```

The shape is TI's C start-up (`c_int00`: stacks, BSS clear, auto-initialisation, `main`), HYP:
the GSP program was compiled with TI's TMS340 C compiler. The frame loop:

```
fff40ed0 main_loop:            MOVE   @FFF77E80h,A1,0     ; wait for the frame counter
fff41010 poll_command_buffers: SETF   10h,0,0
fff41030                       MOVI   FFF9FC00h,A3
fff41060                       MOVE   *A3,A0,0
fff41070                       CMPI   FFFFh,A0            ; MAME's speedup PC
fff410f0                       MOVI   FFFCFC00h,A3        ; then the second buffer
fff41160                       JRNE   FFF41010h
fff411a0 process_command_buffer: MOVE A5,@FFF77F30h,1     ; A5 = FFF9FC10 or FFFCFC10
fff41890 command_buffer_done:  CLR    A1 / MOVE A1,*A3,0  ; clear the flag word
fff41910                       MOVE   A4,@C00000F0h,0     ; HSTCTLL |= 80h: INTOUT
fff41940                       JR     FFF40ED0h
```

A command buffer is ready when its flag word reads FFFF (FFF9FC00, list at FFF9FC10; FFFCFC00,
list at FFFCFC10); MAME's speedup sits on exactly this loop (`init_stunrun`, harddriv.cpp:5088-
5093: handlers on FFF9FC00 and FFFCFC00, `m_gsp_speedup_pc = 0xfff41070`). After a buffer the
GSP clears its flag and sets INTOUT, which is the 68k's level-3 interrupt (`h_level3_gsp` clears
it). The frame counter FFF716A0 is incremented by `display_interrupt` (FFF41C00, trap vector 10,
DI), at FFF41F80. Of the 32 trap vectors, 0 (reset) is FFF59920, 10 is FFF41C00, 29 is FFF45FC0
(`trap29_delay`, a busy wait) and the other 29 are FFF40000. The command format, who fills the
buffers (HYP: the 68k through the host port), and what sections 1 and 2 hold are M5d/M6.

## 7. Does 68k code run from RAM? No (MAME)

`make pcwatch` runs `tools/mame/pcwatch.lua` under `mame -debug -debugger none`. MAME's
registerpoints evaluate a condition before every instruction of the focused CPU, so the check is
exact, not sampled. MAME 0.289's Lua `device_debug` has no `rpset` method; the script issues
debugger commands through `manager.machine.debugger:command`, and the debugger starts stopped,
so it sets `execution_state = "run"`:

```
focus :mainpcb:maincpu
temp0 = 0
temp1 = ffffffff
rpset pc > temp0,{temp0 = pc; g}     ; the highest PC executed
rpset pc < temp1,{temp1 = pc; g}     ; the lowest
```

Any instruction fetched from RAM (FF8000 up) or anywhere past the ROM image raises the maximum,
so the maximum answers the question. Only one registerpoint acts per instruction (the hit stops
the CPU and the action resumes it): an extra counter registerpoint that fired would hide that
instruction from the maximum, which a control run showed (with a counter on `pc >= 40000` the
maximum dropped to 0x03FCC8), so the script keeps two. Without `-debug`, sampling
`cpu.state["PC"]` once a frame works (`CURPC` holds the same value) but sees little.

| Run | Frames | Highest PC | Lowest PC | Per-frame sample, highest |
|---|---|---|---|---|
| attract mode | 3,600 | 0x046AEC | 0x000216 | 0x046AB4 |
| coin at 900, start at 960, trigger at 1020 (a game is on screen by frame 2,400) | 3,600 | 0x046AEC | 0x000216 | 0x046AB4 |

0x046AEC is the last instruction of the last IDA function (`sub_46AC4`, ending 0x046AEE). No
instruction ran from RAM or outside the ROM. Statically too: no `jmp`/`jsr` to an absolute
address in FFxxxx exists, and the indirect ones the scout resolved load ROM addresses.

## 8. ADSP data RAM: what the 68k writes there

No ROM block is copied to ADSP data RAM at boot. The 68k's absolute operands in 808000-80BFFF
(DM 0000-1FFF, `hd68k_adsp_data_w`, harddriv_m.cpp:591) are, outside the dead
`copy_adsp_dram_to_18000`:

| 68k | DM | When | What |
|---|---|---|---|
| 0x02C22C `move.w #$ffff,$80bffe` | 1FFF | boot (`init_coprocessors`) | the frame trigger's idle value, before the ADSP is released |
| 0x02DE5C-0x02DEEA, 0x02E106-0x02E176 | 1FE4-1FFE | per frame (HYP) | the parameter block: `copy_frame_parameters` (PM 0018) copies DM 1FE9-1FFD into the PM workspace, `select_object_page` (002D) sends DM 1FFE to /MP |
| 0x02DFD4, 0x02E1C2 `clr.w $80bffe` | 1FFF | per frame | the trigger: `wait_frame_trigger` (0013) leaves its loop when DM 1FFF is not FFFF |
| 0x02C862, 0x02DDAE `#$809400` | 0A00 | per frame | the base of the object list: the ADSP reads its list from DM(001B), initialised to 0A00 (PM 0018) |
| 0x02E402, 0x02E428-0x02E442 (0x02E418 is called by `h_level2_adsp`) | 1FE3 | per object batch | the handshake: the ADSP writes a count to DM 1FE3, raises /GINT (004C) and waits for the 68k to clear it (004D-004F) |

The data dump at 600 frames holds 983 non-zero words, in 0000-02FF, 0800-0CFF and 1F00-1FFF:
runtime state, with no ROM image to compare with. A write to DM 1FFF also makes MAME synchronise
the CPUs (harddriv_m.cpp:595-601).

## 9. Open questions for M3 and M5

1. The object list entry format at DM 0A00 and the object ROM pointer (`read_object_pointer`
   shifts the /SIMBUF word left by 2 into a page and an address: is the pointer in units of four
   words?) and the record types behind the table at PM 0187 (M3).
2. The SOM display list: header words written at 00BB-00C0, the end marker FFFF at 00B5, the
   routine 080B (M3).
3. GSP sections 1 and 2: confirm the `.cinit` reading of section 1 by decoding FFF59C70 (M6), and
   the command-buffer format at FFF9FC10/FFFCFC10 and its writer (M5d).
4. The packed image format of pairs U-V, and the consumer of 0x09F1C5-0x0B10EB (M5d, M5f).
5. The two longs at 0x017008, the word at 0x01702C, ADSP control lines 2 and 4, and 818040.
6. Pair R against a Hard Drivin' set's 0x000000-0x01FFFF (section 4.4).
7. The callers of `game_entries` and of `copy_adsp_dram_to_18000` (none found in the ROM).
