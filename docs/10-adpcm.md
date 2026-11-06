# The OKI M6295 samples: phrase table, WAVs, tools/adpcm

**Date**: 2026-11-05 (milestone 4, leg M4b). What the 256 KB of ADPCM on the JSA II board hold,
how the 6502 plays them, and how the repository rebuilds the four files `136070-2124.1fh`,
`-2125.1ef`, `-2126.1de` and `-2127.1cd` through one WAV per sample. Addresses: OKI addresses
(= offsets in `build/stunrun-oki.bin`) as five hex digits, 6502 addresses as four. **CODE**
means read off the 6502 program (`build/stunrun-jsa.bin`, disassembled with
`unidasm -arch m6502`) at the addresses given, **MAME** means a run of the committed script
`tools/mame/okitrace.lua` (`make okitrace`, MAME 0.289) shows it, **SRC** means MAME's source
(`~/.local/src/mame`, tag mame0289) says it. The 6502 program as source is leg M4a (docs/09);
this document cites the 6502 only where it decides which phrase plays.

The sample bytes, the WAVs and anything decoded from them are ROM content: they live under
`build/` only and are never committed (CLAUDE.md section 2). The repository holds the manifest
`data/oki/samples.json` (numbers, names, addresses, lengths, play evidence), the tools and the
phrase table as source.

## 1. Summary

- The image is the M6295's phrase table, entries 0-52 (00000-001A7, entry 0 zero), then the 52
  samples back to back in phrase order (001A8-3FCA7), then zero to the end (3FCA8-3FFFF, 856
  bytes). Every byte is accounted for; no residue. **SRC** (the table format), checked on the
  image by `tools/adpcm info`.
- The 6502 asks for phrases 1-52 and no other: its OKI play handler (5BFE) takes the phrase
  from a 53-entry effect table at 6532 that holds each of 1-52 (effects 0 and 1 both play
  phrase 1), and every effect is reached by a sound command (05, 38-65, 67-6C). Command 66 is
  the stop handler (5C6F), whose parameter is a phrase number, not an effect: it stops phrase 48
  (the phrase of command 65). **CODE, MAME**. MAME saw each of the 52 phrases start by exactly
  the command the tables give, 16 of them in a played game; attract mode starts none (the 68k
  sends command 01, which sets RAM 1E, `min_priority`, to F0, and the play handler does nothing
  while 1E is nonzero). **MAME**
- MAME plays the samples at 3.579545 MHz / 3 / 165 = 7231.4 Hz, not / 132: JSA II's /WRIO bit 3
  drives the M6295's pin 7 (**SRC**), and in the three okitrace runs /WRIO only took the values
  00, 01 and 05 (**MAME**). The code never sets bit 3: the one write that could (5903) is in a
  routine no sound command reaches (section 2, **CODE**). Only the real board's pin 7 polarity is
  unverified.
- `tools/adpcm` keeps each sample as a WAV whose data chunk is the sample's ADPCM bytes
  verbatim (format tag 0x0017, Dialogic OKI ADPCM, 4 bits, high nibble first), so WAV -> bytes
  is a copy. `make` goes image -> WAVs -> bytes -> vasm, and `make check` is byte-identical
  only if every sample survived the round trip. `tools/adpcm decode` gives 16-bit PCM through a
  decoder equal to MAME's on every sample (MAME's own `okiadpcm.cpp`, compiled, is the oracle).
- Finding: a deterministic greedy encoder gives back all 52 samples byte for byte from the PCM
  they decode to (section 6). The build does not depend on it; the editable form is card A7.

## 2. The M6295 as MAME emulates it (SRC)

Citations are `file:line` under `~/.local/src/mame/src/`.

- **Wiring.** JSA II maps the OKI write (/WRV) at 6502 2A00 mirror 01F9 and the status read
  (/RDV) at 2800 mirror 01F9 (`mame/atari/atarijsa.cpp:116`, `atarijsa2_map`; the program
  reads status at 2808, a mirror). The ROM region is `mainpcb:jsa:oki1`, 0x40000 bytes, the
  four files at 0x00000, 0x10000, 0x20000, 0x30000 (`mame/atari/harddriv.cpp:2716`). JSA II has
  no OKI bank (`atari_jsa_ii_device` configures none; the banks at `atarijsa.cpp:589` exist
  only when the region is 0x80000 bytes or more, JSA III), so the chip sees the 256 KB directly.
- **Clock and pin 7.** `OKIM6295(config, m_oki1, JSA_MASTER_CLOCK/3, okim6295_device::PIN7_HIGH)`
  (`atarijsa.cpp:935`, `JSA_MASTER_CLOCK` 3.579545 MHz at `:80`) is only the power-on state:
  `wrio_w` (`atarijsa.cpp:487`), the handler of /WRIO at 2A04, calls `m_oki1->set_pin7(data & 8)`
  (`:509`) on every write, and `set_pin7` re-derives the stream rate as
  `clock() / (m_pin7_state ? 132 : 165)` (`devices/sound/okim6295.cpp:168`, `:202`). The 6502
  writes /WRIO at 4007, 400C, 4011, 409D, 40AD, 40BD, 40CD, 411E, 5903, 5BB0, 5BB7 and 5DA9
  (**CODE**), and the MAME runs saw only the values 00, 01 and 05 (section 4): bit 3 was never
  set in them, so MAME played every sample at 1,193,181.67 / 165 = **7231.40 Hz** (9039.26 Hz
  with pin 7 high). The code agrees (**CODE**). Every write of /WRIO is a constant or RAM 45
  with bits changed: 01 then 00 then 01 at 4005-4011; RAM 45 = 05 at 408E-4092 and 4118-411C;
  RAM 45 AND 3F at 4097-409B; RAM 45 OR 40, 80 or C0 at 40A9-40CD (the self-test); AND FB then
  OR 04 at 5BAC-5BB5; bits 5-4 merged in at 5DA1-5DA7. None of them sets bit 3. The one that
  could, 58FA-5903 (RAM 45 AND 3F OR the table byte 65E1+X, some of whose bytes have bit 3 set),
  is in the routine at 5869, and nothing a sound command runs reaches it: the only reference to
  5869 in the 64 KB is `JMP $5869` at 44CC (no RTS table holds 5868), 44CC belongs to the
  handler at 44C4, whose only reference is entry 10h of the dispatcher's jump table (474F = 44C3,
  pushed for an RTS), and the dispatcher takes the type from 6100+Y (4375), a table of 6D types
  with no 10h in it (13h x 53, 08 x 32, 01 x 6, 0Ah x 5, FFh x 4, 00, 0Bh and 05 x 2 each, 03,
  09 and 14h x 1 each). So the 6502 never sets /WRIO bit 3 and pin 7 stays low by the code.
  Whether the real board's pin 7 follows /WRIO bit 3 with the same polarity is MAME's claim (its
  comment calls bit 3 "voice frequency"); nothing here checks the hardware.
- **Commands.** `okim6295_device::write` (`okim6295.cpp:232`): a byte with bit 7 set starts a
  command whose low 7 bits are the phrase number; the next byte's high nibble selects the
  voice(s) and its low nibble the attenuation (`s_volume_table`); a byte with bit 7 clear
  outside a command stops the voices of bits 6-3. The status read returns F0 | one bit per
  playing voice (`:214`).
- **The phrase table.** On a start the chip reads 8 bytes at `phrase * 8`: bytes 0-2 the start,
  3-5 the stop, big-endian, each masked to 18 bits (`:259`), and plays only if start < stop,
  `2 * (stop - start + 1)` nibbles (`:272`): the stop address is the sample's **last** byte.
  Bytes 6-7 of an entry are not read. Phrase numbers go to 127, so the table could reach 003FF;
  stunrun's ends at entry 52 and phrase 1's sample starts at 001A8, so entries 53-127 would
  read sample bytes as addresses (the 6502 never asks for them, section 4).
- **The decoder.** `okim_voice::generate_adpcm` (`okim6295.cpp:338`) fetches nibble `m_sample`
  as `read_byte(base + m_sample / 2) >> (((m_sample & 1) << 2) ^ 4)`: the **high nibble
  first**. Each nibble goes through `oki_adpcm_state::clock` (`devices/sound/okiadpcm.cpp:54`):
  signal += `s_diff_lookup[step * 16 + nibble]`, clamped to -2048..2047; step +=
  `s_index_shift[nibble & 7]` = {-1, -1, -1, -1, 2, 4, 6, 8} (`:33`), clamped to 0..48. The
  table (`compute_tables`, `:109`): stepval = floor(16 * 1.1^step) (`:129`), diff = sign *
  (stepval * b2 + stepval/2 * b1 + stepval/4 * b0 + stepval/8), integer divisions, b3 the
  sign. A voice starts from signal 0, step 0 (`voice.m_adpcm.reset()`). This is the Dialogic
  (VOX) ADPCM coding: the 49 step sizes are the Dialogic table.

## 3. The image

`tools/adpcm info` checks the image against the manifest and prints the table. The phrase table
is entries 0-52; the samples tile 001A8-3FCA7 with no gap and no overlap, each starting where
the previous one ends (every length is a multiple of 0x80); 3FCA8-3FFFF is zero. Three samples
cross a ROM file boundary, and the generated include cuts their incbin there so that each file
starts at a labelled statement with an assert:

| Boundary | File that starts | Sample across it |
|---|---|---|
| 10000 | `136070-2125.1ef` | phrase 11 (0FCA8-10627) |
| 20000 | `136070-2126.1de` | phrase 32 (1E528-207A7) |
| 30000 | `136070-2127.1cd` | phrase 40 (2BBA8-30227) |

The phrases (from `data/oki/samples.json`; seconds at 7231.40 Hz; commands per section 4;
starts = how many times each MAME run saw the 6502 start the phrase):

| Phrase | Name | Start | End | Bytes | Seconds | Commands | Starts attract / game / inject |
|---|---|---|---|---|---|---|---|
| 1 | `sample_01` | 001A8 | 01AA7 | 6,400 | 1.770 | 05, 38 | 0 / 1 / 2 |
| 2 | `sample_02` | 01AA8 | 028A7 | 3,584 | 0.991 | 39 | 0 / 3 / 1 |
| 3 | `sample_03` | 028A8 | 03C27 | 4,992 | 1.381 | 3A | 0 / 0 / 1 |
| 4 | `sample_04` | 03C28 | 055A7 | 6,528 | 1.805 | 3B | 0 / 0 / 1 |
| 5 | `sample_05` | 055A8 | 06A27 | 5,248 | 1.451 | 3C | 0 / 1 / 1 |
| 6 | `sample_06` | 06A28 | 08F27 | 9,472 | 2.620 | 3D | 0 / 0 / 1 |
| 7 | `sample_07` | 08F28 | 0B227 | 8,960 | 2.478 | 3E | 0 / 0 / 1 |
| 8 | `sample_08` | 0B228 | 0DB27 | 10,496 | 2.903 | 3F | 0 / 1 / 1 |
| 9 | `sample_09` | 0DB28 | 0F327 | 6,144 | 1.699 | 44 | 0 / 3 / 1 |
| 10 | `sample_10` | 0F328 | 0FCA7 | 2,432 | 0.673 | 45 | 0 / 1 / 1 |
| 11 | `sample_11` | 0FCA8 | 10627 | 2,432 | 0.673 | 46 | 0 / 1 / 1 |
| 12 | `sample_12` | 10628 | 10FA7 | 2,432 | 0.673 | 47 | 0 / 1 / 1 |
| 13 | `sample_13` | 10FA8 | 11A27 | 2,688 | 0.743 | 48 | 0 / 0 / 1 |
| 14 | `sample_14` | 11A28 | 122A7 | 2,176 | 0.602 | 49 | 0 / 0 / 1 |
| 15 | `sample_15` | 122A8 | 12AA7 | 2,048 | 0.566 | 4A | 0 / 0 / 1 |
| 16 | `sample_16` | 12AA8 | 134A7 | 2,560 | 0.708 | 4B | 0 / 0 / 1 |
| 17 | `sample_17` | 134A8 | 13BA7 | 1,792 | 0.496 | 4C | 0 / 0 / 1 |
| 18 | `sample_18` | 13BA8 | 14627 | 2,688 | 0.743 | 4D | 0 / 0 / 1 |
| 19 | `sample_19` | 14628 | 14FA7 | 2,432 | 0.673 | 4E | 0 / 0 / 1 |
| 20 | `sample_20` | 14FA8 | 15A27 | 2,688 | 0.743 | 4F | 0 / 0 / 1 |
| 21 | `sample_21` | 15A28 | 16327 | 2,304 | 0.637 | 50 | 0 / 0 / 1 |
| 22 | `sample_22` | 16328 | 16F27 | 3,072 | 0.850 | 51 | 0 / 0 / 1 |
| 23 | `sample_23` | 16F28 | 17A27 | 2,816 | 0.779 | 52 | 0 / 0 / 1 |
| 24 | `sample_24` | 17A28 | 18527 | 2,816 | 0.779 | 53 | 0 / 0 / 1 |
| 25 | `sample_25` | 18528 | 191A7 | 3,200 | 0.885 | 54 | 0 / 0 / 1 |
| 26 | `sample_26` | 191A8 | 19E27 | 3,200 | 0.885 | 55 | 0 / 0 / 1 |
| 27 | `sample_27` | 19E28 | 1AAA7 | 3,200 | 0.885 | 56 | 0 / 0 / 1 |
| 28 | `sample_28` | 1AAA8 | 1BA27 | 3,968 | 1.097 | 57 | 0 / 0 / 1 |
| 29 | `sample_29` | 1BA28 | 1C4A7 | 2,688 | 0.743 | 58 | 0 / 0 / 1 |
| 30 | `sample_30` | 1C4A8 | 1D4A7 | 4,096 | 1.133 | 59 | 0 / 0 / 1 |
| 31 | `sample_31` | 1D4A8 | 1E527 | 4,224 | 1.168 | 5A | 0 / 0 / 1 |
| 32 | `sample_32` | 1E528 | 207A7 | 8,832 | 2.443 | 40 | 0 / 0 / 1 |
| 33 | `sample_33` | 207A8 | 22BA7 | 9,216 | 2.549 | 42 | 0 / 0 / 1 |
| 34 | `sample_34` | 22BA8 | 24AA7 | 7,936 | 2.195 | 41 | 0 / 0 / 1 |
| 35 | `sample_35` | 24AA8 | 26FA7 | 9,472 | 2.620 | 43 | 0 / 0 / 1 |
| 36 | `sample_36` | 26FA8 | 27EA7 | 3,840 | 1.062 | 5B | 0 / 0 / 1 |
| 37 | `sample_37` | 27EA8 | 29027 | 4,480 | 1.239 | 5C | 0 / 0 / 1 |
| 38 | `sample_38` | 29028 | 29AA7 | 2,688 | 0.743 | 5E | 0 / 0 / 29 |
| 39 | `sample_39` | 29AA8 | 2BBA7 | 8,448 | 2.336 | 67 | 0 / 312 / 287 |
| 40 | `sample_40` | 2BBA8 | 30227 | 18,048 | 4.992 | 61 | 0 / 27 / 40 |
| 41 | `sample_41` | 30228 | 32AA7 | 10,368 | 2.867 | 5D | 0 / 0 / 1 |
| 42 | `sample_42` | 32AA8 | 356A7 | 11,264 | 3.115 | 68 | 0 / 8 / 16 |
| 43 | `sample_43` | 356A8 | 36527 | 3,712 | 1.027 | 6C | 0 / 51 / 1 |
| 44 | `sample_44` | 36528 | 37BA7 | 5,760 | 1.593 | 62 | 0 / 25 / 1 |
| 45 | `sample_45` | 37BA8 | 38FA7 | 5,120 | 1.416 | 64 | 0 / 0 / 1 |
| 46 | `sample_46` | 38FA8 | 39A27 | 2,688 | 0.743 | 60 | 0 / 0 / 5 |
| 47 | `sample_47` | 39A28 | 3A3A7 | 2,432 | 0.673 | 63 | 0 / 4 / 1 |
| 48 | `sample_48` | 3A3A8 | 3BA27 | 5,760 | 1.593 | 65 | 0 / 0 / 5 |
| 49 | `sample_49` | 3BA28 | 3BC27 | 512 | 0.142 | 6A | 0 / 20 / 18 |
| 50 | `sample_50` | 3BC28 | 3D227 | 5,632 | 1.558 | 69 | 0 / 0 / 17 |
| 51 | `sample_51` | 3D228 | 3E327 | 4,352 | 1.204 | 5F | 0 / 21 / 1 |
| 52 | `sample_52` | 3E328 | 3FCA7 | 6,528 | 1.805 | 6B | 0 / 0 / 1 |

## 4. Which phrases the 6502 plays (CODE, MAME)

**The command path (CODE).** The main loop takes each sound command from its queue at 0200
(4171-4186) and calls the dispatcher at 4371 with Y = the command: commands 6D and up are
ignored (`CPY #$6D`), the handler type is 6100+Y (21 types, jump table at 472F, pushed for an
RTS), the handler's parameter 616D+Y. Type 13h is the OKI play handler at 5BFE, type 14h the
OKI stop handler at 5C6F. The play handler's parameter is an **effect** number, the stop
handler's a **phrase** number (below). Per effect, three tables
of 53 bytes (`data/sounds.asm`): 6532 the phrase (`effect_phrase`), 6567 the voice (bits 5-4),
the attenuation (bits 3-0) and a "do not interrupt" flag (bit 7) (`effect_voice`), 659C a level
the handler stores per voice (5C59, `oki_duck`) and turns into the YM2151 volume of /MIX
(5C87-5CB4, `oki_duck_ym`: the music ducks under the samples) (`effect_duck`). The handlers are
`cmdtype_13_oki_play` (5BFE) and `cmdtype_14_oki_stop` (5C6F), `oki.asm` (docs/09 section 10.4).

The play handler (5BFE-5C62): returns at once when RAM 1E is nonzero (5BFE); picks the voice X
from 6567; if the voice is playing (status at 2808) an effect whose 6567 bit 7 is set, returns
(5C1C-5C21); otherwise stops the voice (stop byte 5C6B+X, 5C26) and waits until the status shows
it stopped, then writes 80h | phrase (5C48) and attenuation | voice bit 5C63+X (5C53). The stop
handler (5C6F-5C86) compares its parameter itself with a phrase: for X = 3 down to 0 it loads the
voice's last effect from RAM 52+X (5C73) and compares A with that effect's phrase, 6532+Y (5C75);
nothing converts the parameter through 6532. On the first match it writes the stop byte 5C6B+X
to the OKI (5C7F-5C82) and returns, so it stops at most one voice, the highest-numbered one whose
last effect plays that phrase.

Commands of type 13h: 05 (effect 0) and 38-6C except 66 (effects 1-52, in an order that is not
the phrase order, see the table above); 66 is type 14h with parameter 48 (616D+66), read as
phrase 48: it stops the voice of command 65 (effect 46, phrase 48, voice 2 by 6567), not that
of effect 48 (phrase 42, voice 3). MAME agrees: the one stop at 5C82 in the `inject` run has
voice mask 4 (voice 2, where command 65 started phrase 48 in that run); phrase 42 started there
on voice mask 8 (voice 3). The 53 effects
name every phrase 1-52 and nothing else. `tools/adpcm survey` reads these tables
(JSA_TYPES/JSA_PARAMS/JSA_EFFECT_PHRASE in tools/adpcm/__main__.py) into the manifest's
`commands`.

**RAM 1E, `min_priority`.** Command 01 (type 0, parameter 3C) runs 438A
(`cmdtype_00_min_priority`), which stores 3C << 2 = F0 into RAM 1E; command 02 (parameter 0)
stores 0; 412B clears it at init. The OKI play handler treats any nonzero value as a mute: it
returns without touching the OKI (5BFE-5C01). 1E is not only an OKI switch: it is a floor on the
track priority (docs/09 sections 6 and 10.2, docs/12 section 3.4). In `tick_ym_channel` the
heard track's priority byte `sounding_prio` (RAM 088E, the track's priority x 4 + 1) is compared
with it at 4EE3-4EE8, and below it the routine returns (at 4EA6) before the key code (register
28 + the channel, from `key_codes` 5E7D, 4EF4-4F08), the total levels (4F20-4FD4), the LFO reset
(4FDE-4FF7) and the key-on (register 08 with the slot bits 78, 4FFA-5006). Registers 20 and 30
(4EA7-4ECD) and the key-off (register 08 with no slot bits, 4ED3-4EDF) come before the compare
and do not depend on it. So with 1E = F0 no YM2151 note keys on unless its priority is at least
3C (priority x 4 + 1 >= F0), which only sound 1B's has: a floor, not a volume (with F0 the
priority-3F sound still keys on, docs/09 section 10.2). A second compare, 44C5-44CC (a byte of
the table 65E0+Y below 1E returns, otherwise it jumps to 5869), is in handler type 10h, which no
command has (section 2), so it never runs. Below, "muted" means only that the OKI play handler
returned at 5C01.

**The MAME runs** (`make -j3 okitrace`, tools/mame/okitrace.lua, each from an empty private
NVRAM and cfg). The script taps the 6502's writes to 2A00-2BFF (OKI, /WRP, /WRIO, /MIX) and its
reads of the dispatcher's type table (6100-616C) and of the effect-to-phrase table (6532-6566),
so each phrase start is attributed to the command whose dispatch led to it and the effect the
handler read, not guessed from timing; it records no ROM byte. A read of the type table counts
as a dispatch only at PC 4375 (`LDA $6100,Y`). The tap also sees the type-08 tests of other
handlers (43F1, 4462, 451F) and, at 4570 and 457C (`LDA $61E4,X`, `LDA $61E5,X`), the dummy
read MAME's m6502 makes at 61xx when the index carries the address into page 62; the script
writes those as `lookup` lines (the three runs saw 43F1, 4462, 4570 and 457C) and never takes
them for a dispatch.

| Run | Frames | What | OKI starts | Mute evidence |
|---|---|---|---|---|
| `attract` | 10,800 | attract mode | 0 | 321 OKI play commands dispatched (67 x 232, 62 x 23, 61 x 22, ...), every one while RAM 1E was nonzero (frames 866-10790); command 01 dispatched 5 times, 02 never |
| `game` | 10,800 | coin at 900, start at 960, the trigger every 20 frames from 1020 | 480 (16 phrases) | 19 OKI commands muted (67 x 13, 62 x 6), all at frames 866-963, before the first trigger; command 01 and 02 dispatched once each |
| `inject` | 21,000 | attract mode; from frame 1200, every 360 frames, command 02 then 4 frames later the next of 05, 38-6C written to the sound latch as the 68k writes it (600000, high byte: `harddriv.cpp:4805`) | 462 (all 52 phrases; the attract's own requests play too once 02 lifts the mute) | 134 muted (the attract mode's own commands after it set 01 again) |

In all three runs /WRIO took only the values 00, 01, 05 (pin 7 low throughout), /MIX 07-0F (the
OKI volume bit set, the YM2151 volume ducked by the handler), every phrase start's second byte
was written at 5C53, every stop at 5C26 (the play handler stopping the voice it is about to use)
except one at 5C82 (command 66, the stop handler, on voice mask 4: phrase 48's voice). Each of the 52 phrases started in the
`inject` run under exactly the command and effect the tables give.

The attribution check: `tools/adpcm survey` fails if any run saw a phrase started by a command
the 6502's tables do not map to it; none did.

## 5. The WAV container and the round trip

Decision (coordinator, 2026-11-05, card A7's default): the lossless form of a sample is a WAV
that carries its ADPCM bytes verbatim.

- **Format.** RIFF WAVE, `fmt ` with format tag **0x0017** (`WAVE_FORMAT_DIALOGIC_OKI_ADPCM`),
  1 channel, 7231 samples per second (the MAME rate rounded), 3616 bytes per second, block align
  1, 4 bits per sample, cbSize 0; a `fact` chunk with the sample count (two per byte); a
  `LIST`/`INFO`/`INAM` chunk with the name; the `data` chunk is the sample's bytes, unchanged,
  high nibble first (the order the M6295 reads), padded to an even size as RIFF requires.
- **Why 0x0017 and not 0x0010.** 0x0010 is `WAVE_FORMAT_OKI_ADPCM`, whose registered header
  (`OKIADPCMWAVEFORMAT`) carries an extra `wPole` field this file would have to invent; 0x0017
  names the Dialogic OKI ADPCM coding, which is the M6295's (section 2). ffmpeg 9.0.2 reads both
  tags as `adpcm_ima_oki` (ffprobe on a synthetic file: "adpcm_ima_oki ([23][0][0][0] / 0x0017),
  7231 Hz, 1 channels"), so audio tools built on ffmpeg play the files; ffmpeg's decoder rounds
  the difference as ((2 * delta + 1) * step) >> 3, not MAME's sum of truncated quarters, so its
  output differs from the M6295's on about a quarter of the outputs (0.22-0.23 on six files of
  4000 random bytes, never ROM data), by a few units of 4096 (per-file maxima 3 to 5 there, up
  to 8 in a model of both formulas over 40 random files): the per-nibble difference is at most
  2 but accumulates through the predictor, so it has no fixed bound. For the exact sound use
  `tools/adpcm decode`.
- **Lossless by construction.** `wav` writes the bytes into the data chunk; `unwav` returns the
  data chunk. No arithmetic touches them. `unwav` rejects anything else: not RIFF WAVE, a format
  tag other than 0x0017, not mono, not 4 bits, block align not 1, no or several `fmt `/`data`
  chunks, a chunk running past the RIFF body, a `fact` count that is not twice the data
  length; it skips chunks it does not know (an editor may add some).
- **The build** (`Makefile`, docs/04 section 1): `tools/adpcm split` cuts
  `build/stunrun-oki.bin` by the image's own phrase table (names from the manifest) into
  `build/oki/wav/NN-name.wav` and removes any other WAV there (a renamed phrase's old file);
  `tools/adpcm info` and `make check` compare the image with the manifest; `tools/adpcm asm` reads `$(OKI_WAV_DIR)/NN-name.wav` for every
  phrase (default `build/oki/wav`), recovers the bytes into `build/oki/bin/NN.bin` (failing on
  a missing WAV, a malformed one, or a length other than the manifest's) and writes
  `build/oki/samples.asm`; `asm/oki/samples.asm` (committed) is the phrase table as `dc.b`
  statements computed from the include's labels `phrase_NN` (first byte) and `phrase_NN_last`
  (last byte), entry 0 explicit, and includes the generated file: one labelled `incbin` per
  sample with an assert at its start, cut at each file boundary inside a sample, every file
  labelled (`oki_1ef`, `oki_1de`, `oki_1cd` with their asserts, before the incbin when a file
  starts at a sample's first byte; `asm` fails if a file would start in the zero tail), the
  tail as `dcb.b`. The WAV step and the OKI assembly run on
  every `make` (make 3.81 compares whole-second mtimes; an edit in the same second must count),
  and so does `tools/adpcm split --missing` on `build/oki/wav`: the split's stamp
  (`build/oki/split.done`) does not see the WAVs, so a WAV deleted there, or a phrase renamed in
  the same second as the last split, is written again from the image while the other WAVs,
  edited or not, are kept.
- **Editing.** `make OKI_WAV_DIR=dir` builds from a directory of edited WAVs (the same file
  names; copy `build/oki/wav` there first). A sample of another length needs the manifest's
  start/end changed, for that phrase and every later one (the asserts and `tools/adpcm asm`
  say so), and its WAVs in a directory of your own: the split still cuts the reference image by
  its own table into `build/oki/wav`, which then no longer matches the manifest. The tail
  absorbs the difference, within the 256 KB. `tools/test_build.py` builds such a relayout
  through `make`.
- **Proof.** `make check`: 25 files, 0 differences, with the OKI image built through the 52
  WAVs. `tools/test_build.py` (CI, synthetic set: the manifest's table over random sample
  bytes) changes one data byte of phrase 2's WAV and `bytecheck` reports exactly
  `136070-2124.1fh: 1 differing bytes, first at file offset $01AB8 = OKI $01AB8`, then builds
  the same edit from another `OKI_WAV_DIR`, fails the build when a WAV is missing from that
  directory, and rebuilds a WAV deleted from `build/oki/wav` (with another one there edited and
  kept) and a rename made behind the split's stamp.
  `tools/test_adpcm.py` round-trips random samples of 1 to 17,497 bytes, rejects a dozen
  malformed WAVs and, with the reference set, all 52 real samples through WAV and back and the
  image through split and build.

## 6. Decoding and the encoder

`tools/adpcm decode IN.wav OUT.wav` writes 16-bit mono PCM at 7231 Hz: the 12-bit decoder
output shifted left by 4 (MAME's stream divides by 2048: the same scale), at full volume (the
attenuation is a play-time choice of the 6502, section 4). `make oki-pcm` (`tools/adpcm pcm`)
decodes the WAV of every phrase the manifest names from `OKI_WAV_DIR` into `build/oki/pcm/` for
listening, and removes any other WAV there, so a rename leaves no copy under the old name.

**The decoder is MAME's.** Two independent checks, both in `tools/test_adpcm.py`:

1. A derivation from the source, by hand: the 49 step sizes of the Dialogic table written out
   and the diff table checked against them for nibbles 0, 5, 7, 8, 15; worked vectors (0x77 ->
   30, 93; 0x88 -> -2, -4; 0x70 0x00 -> 30, 34, 37, 40; the clamps at 2047 and -2048). Runs in
   CI.
2. MAME's own code: `tools/adpcm/mame_oracle.cpp` compiles `okiadpcm.cpp` from the MAME tree
   (with a two-line stub for `emu.h`) and fetches nibbles with `generate_adpcm`'s expression.
   The test compares `decode` with it on random data and, with the reference set, on all 52
   samples: equal, every output of every sample. Skips without a MAME tree or a C++ compiler
   (CI). Not checked: a `-wavwrite` recording of MAME, which would mix the YM2151 and the
   volumes in and could not be compared sample for sample.

**Finding: the encoder.** `tools/adpcm encode` is a deterministic greedy encoder (per sample the
nibble whose output is nearest, the lowest on a tie). `tools/adpcm encoder-check` decodes every
sample and encodes the PCM again: **52 of 52 samples come back byte for byte**. The PCM the
decoder gives is therefore an equivalent lossless form for these 52 samples as they are. This
is a measured property of this data, not of the coding: two nibbles can give the same output
when the signal clamps at -2048 or 2047, and the greedy choice could then differ from the ROM
(none of the 52 samples hits that case). An edited PCM is quantised again, so its bytes are
whatever the encoder chooses. The build never encodes; card A7 asks Jesus which form he wants
to edit.

## 7. Names

Every phrase is `sample_NN` in the manifest: nothing here identifies what a sample sounds like,
and a name claims a role only with evidence. The listening pass is Jesus's (or a later leg's):
`make oki-pcm`, then rename in `data/oki/samples.json` (a unique label; the build uses it as a
label alias and in the WAV file names). A name may not be one of the OKI tree's own labels,
`phrase_NN`, `phrase_NN_last` or any `oki_` label; the manifest reader refuses those. The commands in the manifest say which sound command
plays each sample; the 68010's names for those commands are in `data/sound/commands.json`
(docs/11 section 5), which `tools/test_sound_commands.py` checks against the manifest's
`commands`.

## 8. Commands

`tools/adpcm` is a package directory, not an executable: it runs as
`uv run python tools/adpcm <command>` (the Makefile's `$(PYTHON) tools/adpcm`); elsewhere this
document writes `tools/adpcm <command>` for short.

| Command | What |
|---|---|
| `make` / `make check` | builds the OKI image through the WAVs (section 5) |
| `make OKI_WAV_DIR=dir` | the same from edited WAVs |
| `uv run python tools/adpcm info` | the table, checked against the image |
| `uv run python tools/adpcm split --out dir` | one verbatim ADPCM WAV per phrase |
| `uv run python tools/adpcm wav` / `unwav` | one sample's bytes to its WAV and back |
| `uv run python tools/adpcm decode in.wav out.wav`, `make oki-pcm` (`tools/adpcm pcm`) | 16-bit PCM for listening |
| `uv run python tools/adpcm encode`, `uv run python tools/adpcm encoder-check` | the greedy encoder (section 6) |
| `make -j3 okitrace` | the three MAME runs, then `tools/adpcm survey` rewrites the manifest |

## 9. Not verified

- The sample rate on real hardware: 7231 Hz is MAME's reading of /WRIO bit 3 (section 2).
- What each sample sounds like (no listening here; section 7).
- Whether the phrases that only the injected commands started are reachable in a real game
  (36 of 52 were not seen in the 10,800-frame game run). docs/11 section 6 lists the 68010's
  call sites of each command; the game events behind them are M5's.
