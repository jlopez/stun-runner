# The OKI M6295 samples: phrase table, PCM WAVs, tools/adpcm

**Date**: 2026-11-05 (milestone 4, legs M4b and M4g). What the 256 KB of ADPCM on the JSA II
board hold, how the 6502 plays them, and how the repository rebuilds the four files
`136070-2124.1fh`, `-2125.1ef`, `-2126.1de` and `-2127.1cd` from one committed PCM WAV per
sample. Addresses: OKI addresses (= offsets in `build/stunrun-oki.bin`) as five hex digits, 6502
addresses as four. **CODE** means read off the 6502 program (`build/stunrun-jsa.bin`,
disassembled with `unidasm -arch m6502`) at the addresses given, **MAME** means a run of the
committed script `tools/mame/okitrace.lua` (`make okitrace`, MAME 0.289) shows it, **SRC** means
MAME's source (`~/.local/src/mame`, tag mame0289) says it. The 6502 program as source is leg M4a
(docs/09); this document cites the 6502 only where it decides which phrase plays.

Decision (Jesus, 2026-11-05, card A7, option 2): the editable form of a sample is a plain PCM
WAV, the only format, and the 52 WAVs are committed under `data/oki`. Like the meshes of
`data/objects`, they are assets in their editable form and the build re-embeds them (CLAUDE.md
section 2). The ROM files, hex dumps of them and MAME recordings still never enter the
repository. M4b's container WAV, which carried the ADPCM bytes as they are, is gone.

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
- The source of the image is `data/oki`: the manifest `samples.json` (numbers, names, Jesus's
  descriptions, play evidence; no addresses) and `NN-name.wav` per phrase, 16-bit mono PCM at
  7231 Hz, the M6295 decoder's output exactly (MAME's `okiadpcm.cpp`, compiled, is the oracle)
  at MAME's output scale. `make` encodes every WAV back to ADPCM and lays the samples out from
  their lengths; `make check` is byte-identical because the encoder gives all 52 samples' bytes
  back from their PCM (section 6). The OKI image needs nothing from the reference set; a CI test
  checks the four chips' CRC-32 and SHA-1 from the committed WAVs alone.
- The encoder is exact on decoder output by construction except where an output sits at a clamp
  (-2048 or 2047), the only place two nibbles reach one output; there it takes the
  lexicographically smallest bytes. The 52 samples have one such output (phrase 50), and the
  ROM agrees with the rule there (section 6). An edited WAV encodes to the nearest ADPCM by the
  same rule and does not come back exactly: `tools/adpcm` reports the error.
- The samples are named by the 68010's own audio test (card A12, section 7): command
  `snd_gun1` plays sample `gun1`. Jesus's words from listening (card A8) are each sample's
  description.

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

`tools/adpcm info` prints the layout the WAVs give and checks the merged image against it. The
phrase table is entries 0-52; the samples tile 001A8-3FCA7 with no gap and no overlap, each
starting where the previous one ends (every length is a multiple of 0x80); 3FCA8-3FFFF is zero.
Three samples cross a ROM file boundary, and the generated include labels each file where it
starts, with an assert, in the middle of the sample's `dc.b` statements:

| Boundary | File that starts | Sample across it |
|---|---|---|
| 10000 | `136070-2125.1ef` | phrase 11 (0FCA8-10627) |
| 20000 | `136070-2126.1de` | phrase 32 (1E528-207A7) |
| 30000 | `136070-2127.1cd` | phrase 40 (2BBA8-30227) |

The reference layout (the build derives it from the WAV lengths, section 5; names per section 7;
seconds at 7231.40 Hz; commands per section 4; starts = how many times each MAME run saw the
6502 start the phrase):

| Phrase | Name | Start | End | Bytes | Seconds | Commands | Starts attract / game / inject |
|---|---|---|---|---|---|---|---|
| 1 | `welcome` | 001A8 | 01AA7 | 6,400 | 1.770 | 05, 38 | 0 / 1 / 2 |
| 2 | `luck` | 01AA8 | 028A7 | 3,584 | 0.991 | 39 | 0 / 3 / 1 |
| 3 | `congrats` | 028A8 | 03C27 | 4,992 | 1.381 | 3A | 0 / 0 / 1 |
| 4 | `better` | 03C28 | 055A7 | 6,528 | 1.805 | 3B | 0 / 0 / 1 |
| 5 | `rails` | 055A8 | 06A27 | 5,248 | 1.451 | 3C | 0 / 1 / 1 |
| 6 | `vslows` | 06A28 | 08F27 | 9,472 | 2.620 | 3D | 0 / 0 / 1 |
| 7 | `owall` | 08F28 | 0B227 | 8,960 | 2.478 | 3E | 0 / 0 / 1 |
| 8 | `swave` | 0B228 | 0DB27 | 10,496 | 2.903 | 3F | 0 / 1 / 1 |
| 9 | `clevel` | 0DB28 | 0F327 | 6,144 | 1.699 | 44 | 0 / 3 / 1 |
| 10 | `one` | 0F328 | 0FCA7 | 2,432 | 0.673 | 45 | 0 / 1 / 1 |
| 11 | `two` | 0FCA8 | 10627 | 2,432 | 0.673 | 46 | 0 / 1 / 1 |
| 12 | `three` | 10628 | 10FA7 | 2,432 | 0.673 | 47 | 0 / 1 / 1 |
| 13 | `four` | 10FA8 | 11A27 | 2,688 | 0.743 | 48 | 0 / 0 / 1 |
| 14 | `five` | 11A28 | 122A7 | 2,176 | 0.602 | 49 | 0 / 0 / 1 |
| 15 | `six` | 122A8 | 12AA7 | 2,048 | 0.566 | 4A | 0 / 0 / 1 |
| 16 | `seven` | 12AA8 | 134A7 | 2,560 | 0.708 | 4B | 0 / 0 / 1 |
| 17 | `eight` | 134A8 | 13BA7 | 1,792 | 0.496 | 4C | 0 / 0 / 1 |
| 18 | `nine` | 13BA8 | 14627 | 2,688 | 0.743 | 4D | 0 / 0 / 1 |
| 19 | `ten` | 14628 | 14FA7 | 2,432 | 0.673 | 4E | 0 / 0 / 1 |
| 20 | `eleven` | 14FA8 | 15A27 | 2,688 | 0.743 | 4F | 0 / 0 / 1 |
| 21 | `twelve` | 15A28 | 16327 | 2,304 | 0.637 | 50 | 0 / 0 / 1 |
| 22 | `thirt` | 16328 | 16F27 | 3,072 | 0.850 | 51 | 0 / 0 / 1 |
| 23 | `fourt` | 16F28 | 17A27 | 2,816 | 0.779 | 52 | 0 / 0 / 1 |
| 24 | `fift` | 17A28 | 18527 | 2,816 | 0.779 | 53 | 0 / 0 / 1 |
| 25 | `sixt` | 18528 | 191A7 | 3,200 | 0.885 | 54 | 0 / 0 / 1 |
| 26 | `sevent` | 191A8 | 19E27 | 3,200 | 0.885 | 55 | 0 / 0 / 1 |
| 27 | `eightt` | 19E28 | 1AAA7 | 3,200 | 0.885 | 56 | 0 / 0 / 1 |
| 28 | `ninet` | 1AAA8 | 1BA27 | 3,968 | 1.097 | 57 | 0 / 0 / 1 |
| 29 | `twenty` | 1BA28 | 1C4A7 | 2,688 | 0.743 | 58 | 0 / 0 / 1 |
| 30 | `twenty1` | 1C4A8 | 1D4A7 | 4,096 | 1.133 | 59 | 0 / 0 / 1 |
| 31 | `twenty2` | 1D4A8 | 1E527 | 4,224 | 1.168 | 5A | 0 / 0 / 1 |
| 32 | `ultimate` | 1E528 | 207A7 | 8,832 | 2.443 | 40 | 0 / 0 / 1 |
| 33 | `killc` | 207A8 | 22BA7 | 9,216 | 2.549 | 42 | 0 / 0 / 1 |
| 34 | `markerc` | 22BA8 | 24AA7 | 7,936 | 2.195 | 41 | 0 / 0 / 1 |
| 35 | `boostc` | 24AA8 | 26FA7 | 9,472 | 2.620 | 43 | 0 / 0 / 1 |
| 36 | `kiss` | 26FA8 | 27EA7 | 3,840 | 1.062 | 5B | 0 / 0 / 1 |
| 37 | `yahoo` | 27EA8 | 29027 | 4,480 | 1.239 | 5C | 0 / 0 / 1 |
| 38 | `prgun` | 29028 | 29AA7 | 2,688 | 0.743 | 5E | 0 / 0 / 29 |
| 39 | `gun1` | 29AA8 | 2BBA7 | 8,448 | 2.336 | 67 | 0 / 312 / 287 |
| 40 | `exp2` | 2BBA8 | 30227 | 18,048 | 4.992 | 61 | 0 / 27 / 40 |
| 41 | `apad` | 30228 | 32AA7 | 10,368 | 2.867 | 5D | 0 / 0 / 1 |
| 42 | `irisop` | 32AA8 | 356A7 | 11,264 | 3.115 | 68 | 0 / 8 / 16 |
| 43 | `star` | 356A8 | 36527 | 3,712 | 1.027 | 6C | 0 / 51 / 1 |
| 44 | `trkhit` | 36528 | 37BA7 | 5,760 | 1.593 | 62 | 0 / 25 / 1 |
| 45 | `arms` | 37BA8 | 38FA7 | 5,120 | 1.416 | 64 | 0 / 0 / 1 |
| 46 | `rmphit` | 38FA8 | 39A27 | 2,688 | 0.743 | 60 | 0 / 0 / 5 |
| 47 | `shield` | 39A28 | 3A3A7 | 2,432 | 0.673 | 63 | 0 / 4 / 1 |
| 48 | `brake` | 3A3A8 | 3BA27 | 5,760 | 1.593 | 65 | 0 / 0 / 5 |
| 49 | `type` | 3BA28 | 3BC27 | 512 | 0.142 | 6A | 0 / 20 / 18 |
| 50 | `bird` | 3BC28 | 3D227 | 5,632 | 1.558 | 69 | 0 / 0 / 17 |
| 51 | `bell` | 3D228 | 3E327 | 4,352 | 1.204 | 5F | 0 / 21 / 1 |
| 52 | `swpikup` | 3E328 | 3FCA7 | 6,528 | 1.805 | 6B | 0 / 0 / 1 |

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

## 5. The PCM WAVs and the build

Decision (Jesus, 2026-11-05, card A7, option 2): one format, a playable one, committed.

- **Format.** `data/oki/NN-name.wav`, NN the phrase number, name the manifest's: RIFF WAVE, a
  16-byte `fmt ` (format tag 1, PCM, mono, 7231 samples per second, the MAME rate rounded,
  14,462 bytes per second, block align 2, 16 bits) and the `data` chunk, nothing else (a
  44-byte header). Two samples per ADPCM byte: sample k is the decoder's output after nibble k,
  high nibble first, from the reset state (section 2), times 16. The factor is MAME's output
  scale: `okim_voice::generate_adpcm` adds `clock(nibble) * m_volume` to its stream with a
  maximum of 2048 (`stream.add_int(..., 2048)`, `okim6295.cpp:352`; `add_int` divides by the
  maximum, `emu/sound.h:253`), so at 0 dB (`s_volume_table[0]` = 0x20 / 0x20) an output s is
  s / 2048 of full scale, which a 16-bit recording writes as s * 16. **SRC.** The attenuation
  the 6502 chooses per play (section 4) is not applied: a WAV is the sample at full volume.
- **Size.** 52 files, 1,045,744 bytes in all (2,288 of headers, 1,043,456 of samples: 521,728
  16-bit samples, twice the 260,864 ADPCM bytes); the largest is phrase 40, 72,236 bytes. Each
  is well under a few hundred KB, so they are plain git files, not LFS (the repository sends only
  larger non-ROM binaries through LFS). `.gitattributes` marks `*.wav` binary.
- **Reading.** `read_wav` accepts what an editor writes: format tag 1 or the extensible header
  with the PCM sub-format, other chunks (LIST, cue and so on) skipped, and any 16-bit value.
  It rejects another format, stereo, another sample size, another rate (resample to 7231 Hz: the
  chip plays every sample at that rate), a missing or doubled `fmt `/`data` chunk, an odd data
  size and an empty sample. A value the decoder cannot produce (off its grid of multiples of 16,
  or beyond -32768..32752) is an edit, not an error.
- **The layout is derived.** The manifest holds no address (`read_manifest` refuses `start`,
  `end`, `length` and M4b's `seconds`). `tools/adpcm asm` encodes every WAV and lays the
  samples out in phrase order: phrase 1 at the end of the table (001A8 with 53 entries), each next one where the
  previous one ends, the rest of the 256 KB zero. A WAV of another length moves every later
  sample; a set of samples that no longer fits fails with the number of bytes too many (`the
  samples end at 40000: 1 bytes more than the 256 KB image holds ...`). A WAV of an odd number
  of samples gets its last value once more (the last byte needs two nibbles; `tools/adpcm`
  says so). A sample needs at least 2 bytes, a WAV at least 3 values: a 1-byte sample would
  have start equal to end in the phrase table, and the M6295 starts a voice only when start <
  stop (`devices/sound/okim6295.cpp:266`), so it would never play; `layout` fails on it.
- **The build** (`Makefile`, docs/04 section 1): `tools/adpcm asm --data data/oki --out
  build/oki` writes `build/oki/samples.asm`; `asm/oki/samples.asm` (committed) is the phrase table
  as `dc.b` statements computed from the include's labels `phrase_NN` (first byte) and
  `phrase_NN_last` (last byte), entry 0 explicit, and includes it. The include has per sample
  `phrase_NN:`, the manifest name as a label alias, an assert at its start and the bytes as
  `dc.b`, 16 per line; at every ROM file boundary, inside a sample or in the zero tail, the
  file's label (`oki_1ef`, `oki_1de`, `oki_1cd`) and an assert; the tail as `dcb.b`; the tree's
  last statement asserts the image ends at 40000. The step runs on every `make` (0.2 s for the
  52 samples; make 3.81 compares whole-second mtimes, and a WAV saved in the same second as the
  last build must count) and rewrites the include only when it changes. It fails on a missing
  WAV, a WAV in `data/oki` no phrase names (a rename is the manifest's name and the file's name
  together), or a WAV it cannot read. Nothing in the OKI tree reads `build/stunrun-oki.bin`.
- **Coverage.** The samples are bytes generated from committed data, so they count as `data`
  under `build/oki/samples.asm` (the M3a rule): `stunrun-oki` is 261,288 bytes of data (424 of
  table, 260,864 of samples), 856 of fill and **0 of blob**; the set's blob goes from 1,051,392
  bytes (69.6%) to 790,528 (52.3%).
- **`make samples`** (`tools/adpcm samples`) re-decodes the merged image into `data/oki`, one
  WAV per phrase of the image's own table, named from the manifest, and removes any other WAV
  there: run it after changing the decoder or a name, as `make objects` for the meshes.
- **Proof.** `make check`: 25 files, 0 differences, with `build/stunrun-oki.bin` deleted before
  the OKI tree assembles (nothing in `make` writes it again). `tools/test_adpcm.py` (CI) encodes
  the committed WAVs and checks the four chips' size, CRC-32 and SHA-1 against `tools/romsets/stunrun.json`; checks that
  `git ls-files` holds no audio but the 52 WAVs, each in the canonical form above, one per
  manifest phrase; and, with the reference set (merged in memory from the set itself, so a
  missing `build/stunrun-oki.bin` skips nothing), that every committed WAV is byte for byte what
  `make samples` would write from the image (so `make test` fails while the two disagree).
  `tools/test_build.py` (CI, synthetic set carrying the image the committed WAVs encode to)
  changes one sample of phrase 2's WAV through `make` and `bytecheck` reports a difference in
  `136070-2124.1fh` only, first at that sample's byte; makes phrase 1 256 samples longer and
  checks every later sample moved by 128 bytes; renames a phrase with its WAV (same bytes) and
  without it (the build fails). On the real set the same one-sample edit (phrase 2, sample
  1000, moved by 4000) gave `136070-2124.1fh: 7 differing bytes, first at file offset $01C9C
  = OKI $01C9C` (= 01AA8 + 1000 / 2) and nothing else.

## 6. Decoding and the encoder

`tools/adpcm decode IN.bin OUT.wav` turns one sample's raw ADPCM bytes into its PCM WAV.

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

**The encoder** (`encode` in `tools/adpcm/__init__.py`, the build's). The decoder's state is
(signal, step index), (0, 0) when a voice starts. The encoder keeps a set of candidate states,
each with one nibble history that reaches it; at first only (0, 0). For each 16-bit value v in
turn, every candidate and every nibble 0-15 gives a successor state with the error
|16 * signal - v|. The new candidates are the successors whose error is the smallest one this
value allows (over all candidates and nibbles), one per distinct state, each with the
lexicographically smallest history that reaches it. After the last value the result is the first
candidate's history (the smallest). An odd number of values gets the last value once more.
Candidates are kept in history order and nibbles tried from 0 up, so "the first successor found
for a state" is the smallest history; the set never holds more than 98 states (the two signals
at the smallest distance, times 49 step indices), and on decoder output it is one state at
almost every step, which a table lookup handles (0.2 s for the 52 samples).

**Lemma.** From any state the 16 nibbles give 16 distinct sums signal + diff: within a sign the
differences step/8, step/8 + step/4, ... are strictly increasing (step >= 16, so step/4 >= 4 and
step > step/2 + step/4), and the two signs never meet (|diff| >= step/8 >= 2). So two nibbles
reach the same output only when the clamp to -2048..2047 makes them equal, and that output is
-2048 or 2047. `test_lemma_distinct_differences` checks every row and 20,000 random states.

**Properties.**

1. *PCM exact.* For any v the decoder produced from some bytes x, `pcm(encode(v)) == v`. Proof:
   the state x's decoder is in after k values is always a candidate (it reaches error 0, the
   smallest possible, so it is kept), and every candidate reaches every value with error 0, so
   the history returned decodes to v.
2. *Bytes exact unless a clamp.* If no output of x is -2048 or 2047, `encode(v) == x`: by the
   lemma each output has exactly one nibble from the state before it, so x is the only nibble
   sequence that decodes to v. Otherwise several sequences may decode to v, and the encoder
   returns the lexicographically smallest of them: every state such a sequence passes through
   is a candidate, with the smallest history that reaches it, and two histories into one state
   continue alike, so the smaller one always wins; the first candidate at the end is the
   smallest of all.
   `test_encoder_picks_the_lexicographically_smallest` checks this against brute force over
   every three-nibble sequence from seven states at and near the clamps;
   `test_encoder_inverts_the_decoder` checks properties 1 and 2 on random and clamp-heavy
   samples.
3. *On this data.* `tools/adpcm encoder-check`: **52 of 52 samples come back byte for byte from
   their PCM**. One output in the 52 samples sits at a clamp: phrase 50, output 661, 2047, at
   step index 48, which four nibbles reach, all leaving the same state (signal 2047, step 48: the
   step index clamps too), so no PCM can tell them apart; the ROM holds the smallest of the four,
   the encoder's choice. That single tie is why the rule for ties matters: with another one the
   image would differ there and nowhere else. `make check` is the proof that decode and encode
   are exact inverses on these 52 samples.
4. *Edits.* For PCM the decoder did not produce, each value is followed as closely as the rule
   allows, one value at a time: the result is a valid ADPCM sample, not a global optimum, and
   decoding it gives a PCM other than the edit. `tools/adpcm check [WAV ...]` prints, per WAV,
   `exact` or how many samples decode to another value and the largest and rms error (16-bit
   units); `make` (`tools/adpcm asm`) prints the same line for every WAV that is not exact
   (`phrase 2 (02-luck.wav): edited, the build plays the encoder's nearest ADPCM: ...`).
   ADPCM has no leak, so an offset the encoder cannot catch up with at once persists: the
   one-sample edit of section 5 changed 7 bytes but left 6,167 of the 7,168 samples a little
   off (rms 41.7, largest 3,296, the edited sample). Re-encoding what an edit decodes to is
   exact (property 1). `tools/adpcm encode IN.wav OUT.bin` encodes one WAV to raw bytes with the
   same report.

## 7. Names

Decision (Jesus, 2026-11-06, card A12): a sample's name is the 68010's own audio-test name of
the command that plays it, in lower case, as the sound commands are named (docs/11): command
`snd_gun1` plays sample `gun1`. The audio test (the table at 05C63C, `data/sound/commands.json`)
is the authority. The rule covers all 52 samples (decision of the M4 coordinator, 2026-11-06,
so that there is one scheme). Phrase 1 is played by two commands, 05 (ADTEST) and 38 (WELCOME);
its name is `welcome`, from the command in 38-6C (the OKI commands: each plays one phrase but
66, `snd_kbrake`, which stops phrase 48) whose only job is that phrase, and ADTEST stays listed
in `audio_test`. The names this replaced (M4g's, from Jesus's words,
with a `maybe_` prefix and `number_NN` for 10-31) are gone.

Decision (Jesus, 2026-11-05, card A8): `description` holds Jesus's words from listening,
verbatim, question marks included: they are the listening evidence, and a question mark is his
doubt, not a fact. For 10-31 he wrote `"One" all the way to "Twenty-two"`, so each of those
descriptions is its number word, derived from his range, not words he wrote per phrase.

`audio_test` lists the audio-test names of every command that plays the phrase (the 6502's
tables, section 4). The file names (`data/oki/NN-name.wav`), the labels of the include and the
tables of this document follow `name`; the build uses the name as a label alias, so it may not
be one of the OKI tree's own labels (`phrase_NN`, `phrase_NN_last` or any `oki_` label; the
manifest reader refuses those). `tools/test_adpcm.py` derives each expected name from
`data/sound/commands.json` (the one command in 38-6C of type 13 that plays the phrase, whose
`name` must be `snd_` + its audio-test name) and fails when the manifest differs, so the two
files cannot drift; it also checks `audio_test` against the same file. All 52 lower-cased names
are unique label identifiers, none starts with a digit, and none is an OKI tree label.

| Phrase | Name | Jesus's words | 68k audio test |
|---|---|---|---|
| 1 | `welcome` | Welcome S.T.U.N. Runner | ADTEST, WELCOME |
| 2 | `luck` | Good luck! | LUCK |
| 3 | `congrats` | Congratulations | CONGRATS |
| 4 | `better` | Better luck next time | BETTER |
| 5 | `rails` | Stay off the rails! | RAILS |
| 6 | `vslows` | Vehicle slows on open areas | VSLOWS |
| 7 | `owall` | The outside wall is faster in turns | OWALL |
| 8 | `swave` | Press FIRE button to fire shockwaves | SWAVE |
| 9 | `clevel` | You have completed level... | CLEVEL |
| 10 | `one` | One | ONE |
| 11 | `two` | Two | TWO |
| 12 | `three` | Three | THREE |
| 13 | `four` | Four | FOUR |
| 14 | `five` | Five | FIVE |
| 15 | `six` | Six | SIX |
| 16 | `seven` | Seven | SEVEN |
| 17 | `eight` | Eight | EIGHT |
| 18 | `nine` | Nine | NINE |
| 19 | `ten` | Ten | TEN |
| 20 | `eleven` | Eleven | ELEVEN |
| 21 | `twelve` | Twelve | TWELVE |
| 22 | `thirt` | Thirteen | THIRT |
| 23 | `fourt` | Fourteen | FOURT |
| 24 | `fift` | Fifteen | FIFT |
| 25 | `sixt` | Sixteen | SIXT |
| 26 | `sevent` | Seventeen | SEVENT |
| 27 | `eightt` | Eighteen | EIGHTT |
| 28 | `ninet` | Nineteen | NINET |
| 29 | `twenty` | Twenty | TWENTY |
| 30 | `twenty1` | Twenty-one | TWENTY1 |
| 31 | `twenty2` | Twenty-two | TWENTY2 |
| 32 | `ultimate` | Welcome to the Ultimate Challenge! | ULTIMATE |
| 33 | `killc` | Welcome to the Kill Challenge! | KILLC |
| 34 | `markerc` | Welcome to the Marker Challenge! | MARKERC |
| 35 | `boostc` | Welcome to the Boost Challenge! | BOOSTC |
| 36 | `kiss` | hmm... tsk | KISS |
| 37 | `yahoo` | yeehoo! | YAHOO |
| 38 | `prgun` | shockwave sound | PRGUN |
| 39 | `gun1` | missile launch? | GUN1 |
| 40 | `exp2` | explosion | EXP2 |
| 41 | `apad` | another sfx, sounds like a mild explosion? | APAD |
| 42 | `irisop` | sound when turret is attached? | IRISOP |
| 43 | `star` | kind of gong sound? | STAR |
| 44 | `trkhit` | metallic bounce sound | TRKHIT |
| 45 | `arms` | another whirring sound | ARMS |
| 46 | `rmphit` | attachment sound? | RMPHIT |
| 47 | `shield` | shockwave hit? | SHIELD |
| 48 | `brake` | screeching tires sound | BRAKE |
| 49 | `type` | rejection sound? | TYPE |
| 50 | `bird` | crow caw | BIRD |
| 51 | `bell` | bell ding | BELL |
| 52 | `swpikup` | higher pitched bell ding sound? | SWPIKUP |

**Where the 68k's names and his descriptions do not obviously agree** (evidence kept from
M4g, when the names followed his words; the names now follow the 68k). The 68k's names are
abbreviations in the audio test (`data/sound/commands.json`); nothing in the repository
expands them, so a reading after "perhaps" is a reading of the letters only and claims no role:

- 36 `kiss` "hmm... tsk": a kiss sound would fit "tsk".
- 38 `prgun` "shockwave sound": role unknown, command 5E, queued at 036DFC. In the game run,
  with button 1 pressed every 20 frames from frame 1020 (`tools/mame/okitrace.lua`), 5E never
  played, while 67 (GUN1, phrase 39) played 312 times.
- 39 `gun1` "missile launch?": possibly a gun; the most frequent phrase in a played game
  (312 starts in the game run).
- 41 `apad` "another sfx, sounds like a mild explosion?": no call site in the 68k program
  queues command 5D (docs/11), only the audio test plays it.
- 42 `irisop` "sound when turret is attached?": perhaps iris open; role unknown.
- 43 `star` "kind of gong sound?".
- 44 `trkhit` "metallic bounce sound": perhaps track hit; role unknown.
- 45 `arms` "another whirring sound".
- 46 `rmphit` "attachment sound?": perhaps ramp hit; role unknown.
- 47 `shield` "shockwave hit?".
- 49 `type` "rejection sound?": role unknown; the 68k queues it at 02792A and 032B06.
- 52 `swpikup` "higher pitched bell ding sound?": perhaps shockwave pick-up; role unknown;
  docs/07 section 11.3 identifies no pickup object.

The others agree: 1-35 are the words the 68k abbreviates (WELCOME, LUCK, CONGRATS, BETTER, RAILS,
VSLOWS, OWALL, SWAVE, CLEVEL, ONE-TWENTY2, ULTIMATE, KILLC, MARKERC, BOOSTC), 37 YAHOO, 40 EXP2,
48 BRAKE, 50 BIRD, 51 BELL. Phrase 1 is also played by command 05 (ADTEST), which the boot
program sends directly at 008EB0 (docs/11).

## 8. Commands

`tools/adpcm` is a package directory, not an executable: it runs as
`uv run python tools/adpcm <command>` (the Makefile's `$(PYTHON) tools/adpcm`); elsewhere this
document writes `tools/adpcm <command>` for short.

| Command | What |
|---|---|
| `make` / `make check` | builds the OKI image from `data/oki` (section 5) |
| `make samples` (`tools/adpcm samples`) | re-decodes the merged image into `data/oki` |
| `uv run python tools/adpcm info` | the layout the WAVs give, checked against the image |
| `uv run python tools/adpcm check [WAV ...]` | the round-trip error per WAV (section 6) |
| `uv run python tools/adpcm decode in.bin out.wav` / `encode in.wav out.bin` | one sample's raw bytes to PCM and back |
| `uv run python tools/adpcm encoder-check` | per phrase of the image: bytes back from PCM, outputs at a clamp |
| `make -j3 okitrace` | the three MAME runs, then `tools/adpcm survey` rewrites the manifest's commands and starts (names, descriptions and audio_test kept) |

## 9. Not verified

- The sample rate on real hardware: 7231 Hz is MAME's reading of /WRIO bit 3 (section 2).
- Whether the phrases that only the injected commands started are reachable in a real game
  (36 of 52 were not seen in the 10,800-frame game run). docs/11 section 6 lists the 68010's
  call sites of each command; the game events behind them are M5's.
- The descriptions are Jesus's hearing of MAME's playback (card A8). The names are the 68010's
  audio-test abbreviations (card A12); nothing in the repository expands them (section 7), so
  what a name stands for is not verified.
