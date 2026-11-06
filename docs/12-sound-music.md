# The sequencer and its data

**Date**: 2026-11-05 (milestone 4, leg M4d, issue #17). The music half of the JSA II 6502 program: the stream interpreter of `asm/jsa/sequencer.asm` (4759-57E2) is named and commented, its 59 ops are written down from their handlers, and its data, 65E6-AB47, is structured source: the 125 streams of the sound table, 13 streams no pointer reaches and 101 YM2151 patch records, one statement per note, op or record field through the macros of `asm/jsa/data/macros.asm`, every address a label. `make check` is byte-identical, `make coverage` unchanged (the 6502 image: instr 7,351, data 20,376, blob 0, fill 37,809). The system half (reset, commands, NMI, OKI, I/O, the timer voices) is leg M4c's (docs/09); the protocol with the 68010 is leg M4e's (docs/11). Instruction addresses are 6502 addresses; names in `code` are labels of the tree.

## 1. How a sound plays

1. A command of type 08 (cmd_type, tables.asm) reaches `cmdtype_08` (4569, commands.asm) with its parameter N, the sound (00-1F). `sound_first_entry[N]` gives the first entry E of data/sounds.asm and `entry_next[E]` the next, until 0 (467B-469D). Each entry is one track: a byte stream (`entry_stream[E]`), a priority (`entry_priority[E]`) and a YM2151 channel 0-7 (`entry_channel[E]`).
2. For each entry `cmdtype_08` takes a free track slot (X = 1D down to 0 with ram_03EC = 0, 459F-45A6). With no free slot it may take over the slot of the first track of the entry's channel list, when the new priority is at least that track's (45A9-45E8); else `cmdtype_08` returns at once (45E1, also when the channel list is empty, 45D4): that entry and every later entry of the sound are dropped, since the loop over `entry_next` (467B-46A1) is not reached. `sub_46A5` sets the slot's variables (ram_0464 = 07, the tempo 1000, ram_06BC = A0, ram_0428 = FF, the envelope pointers to 5DB5, the rest 0); ram_03EC = priority x 4 + 1 (45F0-4605); the stream address goes into ram_0266/ram_0284 (461B-463A); ram_0248 = N (4670).
3. The track joins the list of its channel (4641-4677): ram_0860 + 1E + channel heads it, ram_0860,x links to the next (track + 1, 0 at the end), in rising priority. A track of the same priority already on the list is freed and replaced (465A-4668).
4. The timed IRQ (`h_irq`, about 249.7 Hz, docs/09 section 1) calls `tick_group` with X = 0 and 1 on alternate ticks (system.asm `sub_4229`, 422B-4235): group 0 is the YM2151 (`tick_ym_group`, channels 7 down to 0, about 124.9 times a second), group 1 six lists of another output kind (`tick_other_group`, lists 26-2B) that no entry reaches in this program.
5. `tick_ym_channel` (4E79) runs every track of the channel's list (`run_track`, 4759, then `next_track` 4CB1 along the links). All tracks advance; only the last of the list, the highest priority, writes the chip: `run_track` sets `track_muted` = FF for a track with a next one (4759-4764). Then the channel's registers go out from the shadow `ram_08AE + register` (4EA7-500B, section 3.4).
6. A track ends with a `ret` at the top level (a note of length 00 with no call pending, 4919-491B), the op `stop` (bytes BB-FF, 505D-5067), the fade of `release` (op 97) or of commands 0A/0B running out (4A5F-4A6E), or a command of type 05/04/06/07 marking it FF. `free_track` (4941) unlinks it; when it was the track heard on its channel and a track before it remains, that track's patch is written again (4966-4976), so the music under a sound effect comes back with its instrument.

Two consequences the data shows: sound 1A has two entries (76, 77) on channel 5 with the same priority 32, so entry 77 replaces entry 76 the moment it starts, and `snd_1A_0` is never read (make musictrace: entry 76 started, none of its statements read, section 8). Sounds 04 and 07 start the same six streams (entries 19-1E and 2E-33).

## 2. The track's variables

The tracks' variables are 30-byte arrays (1E apart, index X) at 0248-085F, and `ram_0860` holds the links (2C bytes: the 30 tracks and the 14 list heads). The arrays are equates of `ram.asm`, owned by leg M4c because commands.asm also uses them; this table gives what the sequencer does with them, by address, for M4c's names.

| RAM | What the sequencer keeps there (evidence) |
|---|---|
| 0248 | the sound number N (cmdtype_08 4670); FE: releasing (op 97, cmdtype_0A/0B), the ops volume, volume_add, fade, patch refuse it; FF: stop (run_op 5062, 4767) |
| 0266/0284 | the stream pointer, two bytes ahead of `stream_ptr` while the statement is read (484B-4859) |
| 02A2/02C0 | the pitch: YM2151 the note (48F6), the other kind a 16-bit frequency (48B9-48DA) |
| 02DE/02FC/031A | the time counter, 24 bits: - tempo per tick (4794-47AB), + the note's length (498B-49A1) |
| 0338/0356/0374 | the gate counter: counter - 2 x tempo at the note (49C8-49F1); 7F: no key-off (49BF) |
| 0392 | the last length byte (4A5C, 4A84) |
| 03EC | priority x 4 + 1; 0 = free slot (45F0-4605, 4941) |
| 040A | the other kind's level envelope index (4A17-4A29, 4C5D) |
| 0428/0446 | YM2151: the patch record + 1C, the scaling bytes (559C-55B1); the other kind: control bytes (8B, 9B) |
| 0464 | YM2151: the pitch fraction (fine_tune x 4, bend); the other kind: the level |
| 0482/04A0 | YM2151: the four operators' TLs at 0482, 04A0, 04BE, 04DC (ram_0482 + n x 1E, 5570-5582); the other kind: the level envelope pointer (87) |
| 04BE/04DC | the other kind: the pitch envelope pointer (86) |
| 04FA | YM2151: the velocity, stored negated (op A2 5706) |
| 0518 | YM2151: the record's register-20 byte, with pan bits 7-6 (op A0); written to the shadow at each note (4900-490B) |
| 0536/0554 | YM2151: the patch record (`trk_patch_lo`, 5557-5561) |
| 0572 | YM2151: 80 after op lfo: every key-on of the track from then on resets the LFO (5652; key_flags is reloaded from it at each run_track, 478B-478E, and only the slot initialisation sub_46A5, 4709, clears it; 4FDE) |
| 05AE/05CC/05EA | YM2151: the fade's step timer (480F-4824, reloaded with LEN_32 at 4CD1-4CDF) |
| 0608 | `fade_mode` (A8); the other kind: the pitch envelope's repeat count |
| 0626/0644 | the tempo (80, 81) |
| 0662 | the transpose (84, 85; bend carries into it) |
| 0680/069E | sync: the arrival mark and the group (88, 89) |
| 06BC | the other kind: bits ORed into the level byte (8A) |
| 06DA | the portamento rate (8C) |
| 06F8/0716 | the portamento offset (48DD-48F0, 4DBE-4E11) |
| 0734 | the top call node (8D, 4919-493E) |
| 0752/0770 | the top loop node and the current loop count (8E, 8F) |
| 078E/07AC | the fade's remaining time; 07CA/07E8 its amount; 0806 the fraction (A4, 97, fade_step) |
| 0824 | `var`, the track's variable (A9-B4, B0-B2) |
| 0842 | the last result (every var write, B9, BA), register 26 and up |

The call and loop nodes are 4-byte records from 09AE, taken from and returned to a free list headed by zp_1F (`sub_4309` and `sub_431A`, commands.asm; `sub_433C` returns a track's nodes when it ends). A call node holds the link, the return address; a loop node the link, the loop's start, the outer loop's count. When the list is empty, `call` and `loop` do nothing (5241, 5267).

Variables only the sequencer uses are this leg's (the split by grep, comments excluded, list in the report): `stream_ptr`/`stream_ptr_hi` (zp_06/07), `chain_mute` (0F), `seq_tmp` (1D), `track_muted` (22), `group_count` (48), `trk_patch_lo` (0536), `trk_penv_count` (0590), `key_tl_offset` (088C), `kind_prio`/`sounding_prio` (088D/088E: the priority of the track read last, 4778, 0 when its reading stopped, 4876; tick_ym_channel compares 088E with zp_1E), `trk_kind` (088F: ram_03EC bits 1-0, always 1 here; reused as scratch at 4F2C-4F98), `other_level` (0893), `key_note` (0895: the note, then the key code), `glide_hi`/`glide_lo` (0896/0897), `chain_prev` (0898), `cur_group_kind` (0899), `other_ctl_a`/`other_ctl_b` (089A/089E), `key_scaling`, `key_scaling_depth` (08A2-08A9: the record's eight scaling bytes, curve bytes at even offsets, depth bytes at odd), `key_velocity` (08AA = key_scaling + 8: the velocity, copied at 4DAF-4DB2 and read at 4F32 as `key_velocity - 6,y` with Y = 6), `key_flags` (08AB: bit 0 the key-off, 47CD-47E0; bit 1 the key code and level update, 4D7C; bit 2 the key-on, 4A27-4A2C; bits 5-4 the accent, 4D6C-4D79; bit 7 the LFO reset, ram_0572 at 478B-478E).

## 3. The interpreter

### 3.1 Reading a stream

`run_track` subtracts the tempo from the time counter; when it borrows below 0, `read_item` (484B) reads statements until a note: the byte at `stream_ptr`, with ram_0266 already two bytes ahead (484B-4859).

- **00-7F, a note**: two bytes, pitch and length. A pitch other than 00 gets the transpose (4887). On a YM2151 track the pitch goes into ram_02A2 (48F6), the change from the last pitch into the portamento offset (48DD-48F0), the patch's register-20 byte into the shadow (4900-490B). A length 00 is a return (`ret`, 4914-4940): from a call when a call node is pending, else the track ends (`free_track`). Any other length goes to `set_note_length` (497F).
- **80-BA, an op**: `run_op` (505D) enters `op_handlers[byte - 80]` by RTS with Y = 1, A = the operand byte and C set. A handler reads further operand bytes through `next_operand` (507B). It returns C set to read on, C clear to end the track's tick (a refused op, `sync` waiting).
- **BB-FF**: `stop`, ram_0248 = FF and C clear (505D-5067); the next tick frees the track (4767-4770). The data has none: its streams end with `ret` or loop with `jump`.

Every address in a stream (call, jump, branch and table targets, patch records) is the address of the statement itself: the handler stores it into ram_0266/ram_0284 and the reader reads at it on its next pass (`op_jump` 552F-553C, 4864-486E). The streams are relocatable once their addresses are labels (section 9).

### 3.2 Notes: length, gate, accent

The length byte (`set_note_length`, 497F):

| Bits | Macro constant | Effect (evidence) |
|---|---|---|
| 3-0 | `LEN_0` ... `LEN_10` | index of `note_lengths` (tables.asm tbl_5FE3), whose word is added to the time counter's bytes 1-2 (498B-49A1). The 16 words are 0, 1E00, and 1E00 divided by 2, 4, 8, 3, 6, 12, 5, 16, 32, 64, 128, 24, 48, 10 (`LEN_n` = 1E00 / n) |
| 6 | `DOT` | half the length again (49A2-49BC) |
| 7 | `TIE` | no gate: ram_0374 = 7F (49BF-49C6), so no key-off before the next note; and the next note is not keyed on again (legato): `set_note_length` sets key_flags bit 2, the key-on, only when the previous length byte (ram_0392, stored after the note at 4A85) has bit 7 clear (4A05-4A08, 4A27-4A2C), so after a TIE note the next one only changes the key code and the levels. The same test keeps the portamento offset after a TIE note (when the rate is not 0) and clears it otherwise (4A0F-4A1C). The data relies on it: `#note $48, LEN_128|TIE` then `#note $48, LEN_2|TIE` (streams_2.asm); 372 TIE lengths in the data files |
| 5-4 | `GATE_HALF` (01), `ACCENT_1` (10), `ACCENT_2` (11) | 01 halves the gate (49F4-4A02); the two bits also select `tbl_5FDF` (00, 00, 24, 58), the accent, added to the velocity at the key-on (prepare_key_on 4D6C-4D82 keeps them in key_flags; tick_ym_channel subtracts the entry from the stored negated velocity, 4F24-4F3D, so the level term grows by it: an accent always makes the note louder, section 3.4) |

With a tempo of 1EB8 (57 of the 188 `tempo` statements), LEN_1 lasts 1E00 x 100 / 1EB8 = 250 ticks, 2.0 s at 124.9 ticks per second. The gate counter is the time counter less twice the tempo: the key-off (key_flags bit 0) comes two ticks before the next note (47CD-47E0).

### 3.3 The patch load (op 9D)

`op_patch` (553E): while the track releases (ram_0248 = FE) it stops the track instead (5540-554E). Else ram_0536/ram_0554 = the record (5555-555F), ram_0518 = record byte 00 (5563-5567), the four TLs (bytes 05, 0B, 11, 17) into ram_0482 + n x 1E (556A-5581), then `load_patch` (5585): only for the heard track of the YM2151 group, `write_patch` sets ram_0428/ram_0446 = record + 1C and `write_patch_regs` (55B6) writes channel zp_0D: register 08 = channel (key-off), TL 7F on the four operators (60, 68, 70, 78), record bytes 00-03 into 20, 28, 30, 38 (55E6-5607), then per operator M1, M2, C1, C2 (+00, +08, +10, +18) the bytes into 40, 80, A0, C0, E0, skipping the TL byte (5609-5634). Every write goes to the shadow too. The record's layout is section 5.

### 3.4 The YM2151 output (tick_ym_channel)

After the list's tracks ran, for the heard track (not muted): registers 20 and 30 of the channel from the shadow (4EA7-4ECD), then the key-off if asked (key_flags bit 0: register 08 = channel, 4ED0-4EE1). The rest happens only when `sounding_prio` (the heard track's priority x 4 + 1) is at least zp_1E (4EE3-4EE8) and an update was asked (key_flags bit 1, set by `prepare_key_on` at every note, fade step and portamento step, 4D7C) for a pitch other than 0; steps 3 and 4 only when key_flags bit 2 is set too (4FD7-4FDA), which `set_note_length` does for a note whose previous note was not tied (section 3.2):

1. **Key code**: register 28 = `tbl_5E7D[note]` (tables.asm, the key codes: 98 bytes, octave in bits 6-4 and the YM2151 note code in bits 3-0, notes 1-97), 4EF1-4F0E. The portamento offset's whole part moves the note (4E4C-4E54), its fraction and the fine tune go to register 30 (key fraction, bits 7-2: 4E32-4E44).
2. **Levels** (4F16-4FD4), per operator C2, C1, M2, M1 (registers 78, 70, 68, 60): TL = the track's TL (the shadow, set from ram_0482 + n x 1E by `prepare_key_on` at the note, 4D8D-4DA0) + a key term + a velocity term, clamped to 00-7F. The key term: `key_level_curve` (lookup.asm, AB48) at the key code OR the operator's curve byte (record bytes 1C, 1E, 20, 22: 00 reads the rising half, 80 the falling half), its high nibble with the depth byte's high nibble (bytes 1D, 1F, 21, 23) into `tbl_5EDF` (a product table, entry a x 10 + b within 1 of a x b / 8). The velocity term: the stored value (-velocity, op A2) minus the accent, -(velocity + accent), clamped to 80 on overflow (4F2C-4F3D); its magnitude (7F for 80) x 2 (4F43-4F54), whose high nibble goes with the depth byte's low nibble into the same table, doubled for the operators the modulator mask passes, and negated when the value is negative (4F92-4F9D). For the velocities 00-7F most `velocity` statements give, the term is subtracted from the TL: velocity + accent sets how much louder the note is (velocity 4B with ACCENT_1: 4B + 24 = 6F).
3. **LFO reset**: on every key-on of a track that ran an `lfo` op (ram_0572 = 80, key_flags bit 7, bit 4 after the three shifts), register 01 = 02 then 00 (4FDE-4FF7).
4. **Key-on**: register 08 = channel + 78, all four operators (4FFA-500B).

Two things the code does that the data's author may not have meant, recorded as found:

- **The M1 curve byte is never loaded.** `prepare_key_on` copies record bytes 1D-23 into key_scaling + 1 to + 7 (4DAD-4DBC: Y = 8 for the velocity, then 7 down to 1); byte 1C, M1's curve, would go to key_scaling + 0, which no instruction writes. M1's key term always reads the curve at key code OR whatever 08A2 holds. Six records have 80 there (section 5).
- **The modulator mask in two orders.** `modulator_mask` (57D3) has, per algorithm, bits 7-4 set for the operators M1, M2, C1, C2 that are not carriers (algorithms 0-3: E0, 4: C0, 5-6: 80, 7: 00). `op_carrier_tl_sub` (5748) reads it in that order, M1 first, and changes exactly the carriers' TL. The level loop of tick_ym_channel runs C2 first and takes the same mask from bit 7 (4F1B, `rol zp_1A` at 4F8C, `asl zp_1C` at 4F90): an operator's velocity term is doubled when the bit it meets is clear. So it doubles M1 for algorithms 0-3, M2 and M1 for 4, C1, M2 and M1 for 5-6, all four for 7, while the carriers are C2; C1 and C2; M2, C1 and C2; all four. Whether the original meant the carriers is not knowable from the code; MAME plays what the code does.

### 3.5 Volume, velocity, fade

- `volume` (82) on a YM2151 track (`volume_ym`, 5788): the four TLs again from the patch record, then the carriers' TL + 40, 2A, 24, 1F, 17, 1A, 12, 15, 0E, 10, 0A, 0B, 06, 05, 02, 00 for volume 0-F (`volume_steps`, 57C3, negated by `op_carrier_tl_sub`).
- `volume_add` (83) and `carrier_tl_sub` (A1): the carriers' TL - A, clamped 00-7F (5750-5785).
- `velocity` (A2) and `velocity_add` (A3): ram_04FA (negated), the level the key-on scales per operator (3.4).
- `fade` (A4) and `release` (97): `fade_step` (4CC1) runs every LEN_32 of the track's time (the step timer ram_05AE-05EA, 480F-482C) while the remaining time ram_07AC:078E is not 0: it loses 8 (`fade_steps`, tables.asm tbl_6003 entry 0A), and the amount ram_07E8:07CA shifted right 5 places goes, with its fraction kept in ram_0806, to `add_volume` (4D63), then `prepare_key_on` writes the new TLs without a new key-on (482C-4845). So `fade steps, rate, frac` changes the carriers' TL by -(rate + frac / 8) per LEN_1 for steps x LEN_1. `release` is a fade of rate D0 for 2 x LEN_1 with ram_0248 = FE; the track ends when it runs out (4A5F-4A6E, 47F5-480C). Commands 0A (a sound) and 0B (a priority) start the same release on the tracks they name (cmdtype_0A 4460, cmdtype_0B 4496).
- `fade_mode` (A8) nonzero: the step timer is not used; the fade steps only at note starts, by the note's length nibble through tbl_6003 (47F5, 4CCF). The data never sets it.

### 3.6 Pitch

- The pitch is note + transpose (ram_0662) with a fraction (ram_0464, in 1/256 of a note): `fine_tune` (A6) sets the fraction to A x 4, `bend` (A7) adds A x 4 signed with the carry into the transpose (570F-5733), `transpose` (84) and `transpose_add` (85) the note offset.
- `portamento` (8C) nonzero: after a TIE note, a new pitch starts from the last one (the offset ram_06F8/0716 = old - new, 48DD-48F0) and the offset moves to 0 by 2 x rate every fourth tick (4DBE-4E11), each step through `prepare_key_on` (482F-4845: the key code and levels, no new key-on). After a note that is not tied the offset is cleared (4A17-4A1C, section 3.2). The data never sets it.

### 3.7 Flow and variables

- `call` (8D) / `ret`; `loop count` (8E) / `loop_end` (8F): nodes, section 2. `jump` (99).
- `var` (ram_0824) is the track's one variable; every write also sets the result ram_0842 (`store_var`, 52F1). `var_add`, `var_sub`, `var_and`, `var_or`, `var_xor` (A9-AD) with the operand; `var_shr`, `var_shl` (B3, B4) by 1-7; `var_load reg` (B2), `var_store reg` (B0), `var_add_to reg` (B1); `var_cmp value` (BA) and `var_cmp_reg reg` (B9) set the result to var - value.
- `jump_table` (AE): the word number var of the list after the op is the next statement (536F-5395); no bound, so the streams mask var first (`var_and 7` before eight entries, `var_and 3` or `1` before four or two). `jump_table_inc` (AF) adds 1 to var after it.
- `branch_zero`, `branch_nonzero`, `branch_plus`, `branch_minus` (B5-B8): register operand, then the target, taken when the register is 0, not 0, bit 7 clear, bit 7 set (545A-5493).
- Registers (`read_register` 5494 for reads, `op_var_store` 53C4 and `op_var_add_to` 5411 for writes), the `R_` constants of macros.asm: 00 volume (a read gives 0 on a YM2151 track), 01 the tempo's high byte, 02 the transpose, 03 the velocity, 04 the fine tune (a write stores A x 4, a read gives the fraction itself), 05 a random byte (`random`, 5504: an 8-bit LFSR, x2 then XOR 1D on carry, also run by `main_loop` on every pass at 4149), 06-25 the 32 global variables zp_23-zp_42 shared by all tracks, 26 and up the last result. Commands 1E-23 (cmdtype_01, `global_set_index`/`global_set_value`) set global 0 to 0-5: the streams of sound 0F branch on it (`var_load R_GLOBAL+0`, `var_and 7`, `jump_table`).
- `sync` (88) and `sync_group` (89): a barrier. `sync` zeroes the track's time counter (5125-512D). Each track that reaches it unmarked (ram_0680 = 0) marks itself with its group (ram_0680 = ram_069E, 513D-5140) and scans the slots: while an active track of the same group has not arrived, the op backs the pointer up and ends the tick (5145-5158, 5170-517E). A track already marked waits the same way without scanning again (5130-5136). The last arrival finds none missing, marks every track of the group FF (515A-516A) and goes on; each other track goes on at its next tick, when it reads FF (5130-5135, 5138-513C, which clears its mark). The data never uses them.
- `oki` (95, oki.asm `op_95`): the OKI effect of the command A (`cmd_param[A]`, then `cmdtype_13`); `respond` (96): `queue_response` A for the 68010 (550E); `ym_ct` (A5, commands.asm `cmdtype_11`): YM2151 register 1B bits 7-6 (the CT outputs).

### 3.8 The other voice kind

The interpreter keeps a second output path: tracks of kind 0 (ram_03EC bits 1-0) and the six lists of group 1 (kind 03). Their pitch comes from a 16-bit table (`tbl_5DB9`, tables.asm: 98 words, 48B9-48DA), their level and pitch from envelopes (`pitch_env` 86, `level_env` 87: pairs of a count and a step, FF to loop, `other_voice_update` 4AE8-4C91), their output into `other_level`, `other_ctl_a`, `other_ctl_b` (4C94-4CB0), bytes no instruction sends to a chip. Every track of this program has kind 1 (ram_03EC = priority x 4 + 1, 45FD-4605) and a YM2151 channel, so these paths never run: make sndtrace never executed `other_voice_update`, `other_voice_off` or `other_voice_level`, and no stream uses ops 86, 87, 8A, 8B, 9B. The names say what the code writes; what chip this path was written for is not in this program.

## 4. The ops

One row per op byte. Length in bytes with the op; handler and its address (labels of the tree); "musictrace" counts the dispatches by `run_op` (506D) in `make musictrace` (section 8); "sndtrace" whether `make sndtrace` (docs/09 section 7) executed the handler's first instruction (for the skip ops that is `read_item` itself, so it says nothing); "streams" the uses in the streams the sound table reaches and in the unreached ones (section 6). Every op the reached streams use ran in MAME, in one trace or the other, but `transpose_add` (85, 42 uses, in statements the runs did not reach); AA and B3 occur only in unreached streams.

| Op | Macro | Bytes | Handler | musictrace | sndtrace | streams (reached / unreached) | Effect |
|---|---|---|---|---|---|---|---|
| 80 | `tempo rate` | 3 | `op_tempo` 51B5 | 1900 | yes | 171 / 17 | the tempo (ram_0626/0644) |
| 81 | `tempo_add delta` | 3 | `op_tempo_add` 51A1 | - | no | 0 / 0 | the tempo + delta |
| 82 | `volume level` | 2 | `op_volume` 51E1 | 277 | yes | 286 / 122 | section 3.5 |
| 83 | `volume_add delta` | 2 | `op_volume_add` 51C0 | 877 | yes | 80 / 81 | the carriers' TL - delta |
| 84 | `transpose steps` | 2 | `op_transpose` 51FD | 78 | yes | 115 / 26 | ram_0662 |
| 85 | `transpose_add delta` | 2 | `op_transpose_add` 51F9 | - | no | 42 / 1 | ram_0662 + delta |
| 86 | `pitch_env table` | 3 | `op_pitch_env` 5196 | - | no | 0 / 0 | other kind (3.8) |
| 87 | `level_env table` | 3 | `op_level_env` 518B | - | no | 0 / 0 | other kind (3.8) |
| 88 | `sync` | 2 | `op_sync` 5125 | - | no | 0 / 0 | barrier (3.7) |
| 89 | `sync_group group` | 2 | `op_sync_group` 5182 | - | no | 0 / 0 | the barrier's group |
| 8A | `ctl_bits bits` | 2 | `op_ctl_bits` 5202 | - | no | 0 / 0 | other kind |
| 8B | `ctl_set bits` | 2 | `op_ctl_set` 5206 | - | no | 0 / 0 | other kind |
| 8C | `portamento rate` | 2 | `op_portamento` 5231 | - | no | 0 / 0 | 3.6 |
| 8D | `call target` | 3 | `op_call` 5235 | 107 | yes | 14 / 52 | 3.7 |
| 8E | `loop count` | 2 | `op_loop` 5263 | 190 | yes | 210 / 127 | 3.7 |
| 8F | `loop_end` | 2 | `op_loop_end` 528E | 1760 | yes | 205 / 128 | 3.7 (operand not read) |
| 90-94, 98, 9A, 9C | `skip op` | 2 | `read_item` 484B | - | (n/a) | 0 / 0 | the reader re-entered from run_op: it skips two bytes and reads on as a nested call, returning into run_op's caller later; unused |
| 95 | `oki command` | 2 | `op_95` 5BFA | 4 | yes | 5 / 0 | the OKI effect of command |
| 96 | `respond value` | 2 | `op_respond` 550E | - | no | 0 / 0 | a response byte |
| 97 | `release` | 2 | `op_release` 5513 | - | no | 0 / 0 | release fade, then the end |
| 99 | `jump target` | 3 | `op_jump` 552F | 2190 | yes | 33 / 0 | |
| 9B | `ctl_clear bits` | 2 | `op_ctl_clear` 521A | - | no | 0 / 0 | other kind |
| 9D | `patch record` | 3 | `op_patch` 553E | 391 | yes | 346 / 96 | 3.3 |
| 9E | `lfo record` | 3 | `op_lfo` 563B | 11 | yes | 12 / 1 | registers 18, 19, 19, 1B from record bytes 24-27 |
| 9F | `noise record` | 3 | `op_noise` 567F | 2 | no | 2 / 0 | register 0F from record byte 29 |
| A0 | `pan side` | 2 | `op_pan` 56BD | 16 | no | 16 / 0 | register 20 bits 7-6 |
| A1 | `carrier_tl_sub delta` | 2 | `op_carrier_tl_sub` 5748 | - | yes | 0 / 0 | the carriers' TL - delta |
| A2 | `velocity level` | 2 | `op_velocity` 56FE | 113 | yes | 139 / 43 | 3.5 |
| A3 | `velocity_add delta` | 2 | `op_velocity_add` 56E2 | 12 | yes | 8 / 26 | 3.5 |
| A4 | `fade steps, rate, frac` | 3 | `op_fade` 52C0 | 78 | yes | 111 / 7 | 3.5 |
| A5 | `ym_ct bits` | 2 | `cmdtype_11` 438F | - | no | 0 / 0 | register 1B bits 7-6 |
| A6 | `fine_tune fraction` | 2 | `op_fine_tune` 5736 | 52 | yes | 73 / 0 | 3.6 |
| A7 | `bend delta` | 2 | `op_bend` 570F | 1877 | yes | 73 / 22 | 3.6 |
| A8 | `fade_mode value` | 2 | `op_fade_mode` 5744 | - | no | 0 / 0 | 3.5 |
| A9 | `var_add value` | 2 | `op_var_add` 52ED | 3 | yes | 3 / 2 | 3.7 |
| AA | `var_sub value` | 2 | `op_var_sub` 52F9 | - | no | 0 / 1 | |
| AB | `var_and value` | 2 | `op_var_and` 5303 | 1856 | yes | 20 / 12 | |
| AC | `var_or value` | 2 | `op_var_or` 5309 | - | no | 0 / 0 | |
| AD | `var_xor value` | 2 | `op_var_xor` 530F | - | no | 0 / 0 | |
| AE | `jump_table` + `.word` | 1 + 2n | `op_jump_table` 536F | 1788 | yes | 11 / 7 | 3.7 |
| AF | `jump_table_inc` + `.word` | 1 + 2n | `op_jump_table_inc` 5396 | - | no | 0 / 0 | |
| B0 | `var_store reg` | 2 | `op_var_store` 53C4 | 78 | yes | 46 / 6 | |
| B1 | `var_add_to reg` | 2 | `op_var_add_to` 5411 | - | no | 0 / 0 | |
| B2 | `var_load reg` | 2 | `op_var_load` 544B | 3610 | yes | 59 / 10 | |
| B3 | `var_shr count` | 2 | `op_var_shr` 5315 | - | no | 0 / 1 | |
| B4 | `var_shl count` | 2 | `op_var_shl` 5342 | - | no | 0 / 0 | |
| B5 | `branch_zero reg, target` | 4 | `op_branch_zero` 5460 | 848 | yes | 1 / 0 | |
| B6 | `branch_nonzero reg, target` | 4 | `op_branch_nonzero` 5467 | - | no | 0 / 0 | |
| B7 | `branch_plus reg, target` | 4 | `op_branch_plus` 546E | - | yes | 8 / 0 | |
| B8 | `branch_minus reg, target` | 4 | `op_branch_minus` 5475 | 1751 | yes | 12 / 0 | |
| B9 | `var_cmp_reg reg` | 2 | `op_var_cmp_reg` 5451 | - | no | 0 / 0 | |
| BA | `var_cmp value` | 2 | `op_var_cmp` 5454 | 1751 | yes | 20 / 0 | |
| BB-FF | `stop` | 1 | `run_op` 505D | - | - | 0 / 0 | the track ends |

Notes: 2,870 statements in the reached streams, 427 in the unreached ones (`note`, `rest`, `ret`). The lengths are the handlers' reads: `tools/test_jsa_music.py` checks each handler's `jsr next_operand` count against the table and each macro's assembled size against it.

## 5. The YM2151 patches

A record is 42 (2A) bytes, the operand of `patch`, `lfo` and `noise`; the macros name the fields in the order the code reads them:

| Bytes | Macro | Fields | Read by |
|---|---|---|---|
| 00-03 | `ym_voice` | `rl_fb_con` (register 20; bits 7-6 replaced by `pan`), `kc`, `kf`, `pms_ams` (registers 28, 30, 38) | write_patch_regs 55E6-5607; byte 00 also into ram_0518 (5565) |
| 04-1B | `ym_operator` x 4 | per operator M1, M2, C1, C2: `dt1_mul` (40), `tl`, `ks_ar` (80), `ams_d1r` (A0), `dt2_d2r` (C0), `d1l_rr` (E0) | 5609-5634; `tl` into ram_0482 + n x 1E (5570-5581, 57A4-57B4) |
| 1C-23 | `ym_scaling` x 4 | per operator: `curve` (ORed with the key code into key_level_curve), `depth` (high nibble: the key term, low nibble: the velocity term) | prepare_key_on 4DAD-4DBC (not byte 1C, 3.4), tick_ym_channel 4F56-4F98 |
| 24-27 | `ym_lfo` | `lfrq` (18), `pmd` (19), `amd` (19), `ct_w` (1B, ORed with the CT bits kept) | op_lfo 5655-5674 |
| 28-29 | `ym_noise` | `shadow_1b` (into the shadow of register 1B, 5677, which nothing reads), `ne_nfrq` (0F) | op_lfo 5676-5678, op_noise 5695-569A |

There are two banks: 26 records at 6B80-6FC3 (`patches_1.asm`, `patch_00`-`patch_19`) and 75 at 9EFA-AB47 (`patches_2.asm`, `patch_1A`-`patch_64`). No byte between or after them is outside a record. 22 records no op names (each such record's comment says so); they are still records by position and shape. Byte 1C (M1's curve, never loaded) is 80 in six records. Byte 28 is 02 in 18 records, 00 in the rest; byte 29 (noise) is 07 in two (the two `noise` ops). Bytes 01-02 (key code and fraction) are 00 in every record; the key-on writes registers 28 and 30 itself.

| Patch | Address | Algorithm | Feedback | Named by |
|---|---|---|---|---|
| `patch_00` | 6B80 | 0 | 7 | - |
| `patch_01` | 6BAA | 2 | 7 | snd_1D_0 |
| `patch_02` | 6BD4 | 2 | 7 | snd_11_0 |
| `patch_03` | 6BFE | 3 | 7 | snd_12_0 |
| `patch_04` | 6C28 | 4 | 0 | - |
| `patch_05` | 6C52 | 4 | 5 | snd_1B_0 |
| `patch_06` | 6C7C | 5 | 3 | snd_1F_0 |
| `patch_07` | 6CA6 | 6 | 7 | - |
| `patch_08` | 6CD0 | 5 | 3 | snd_18_1, snd_18_2, snd_1A_0, snd_1A_1, unused_stream_02 |
| `patch_09` | 6CFA | 5 | 3 | snd_18_1 |
| `patch_0A` | 6D24 | 4 | 1 | snd_10_0 |
| `patch_0B` | 6D4E | 1 | 5 | snd_0F_2 |
| `patch_0C` | 6D78 | 0 | 4 | snd_1C_0 |
| `patch_0D` | 6DA2 | 2 | 0 | - |
| `patch_0E` | 6DCC | 2 | 0 | snd_13_0 |
| `patch_0F` | 6DF6 | 0 | 0 | snd_14_0, snd_15_0, snd_16_0 |
| `patch_10` | 6E20 | 4 | 3 | snd_00_0, snd_00_1, snd_00_2, snd_00_3, snd_00_4, |
| `patch_11` | 6E4A | 3 | 6 | snd_18_2 |
| `patch_12` | 6E74 | 7 | 0 | snd_00_7, snd_18_2, snd_1F_0 |
| `patch_13` | 6E9E | 4 | 6 | snd_0F_0, snd_0F_1, snd_1A_1 |
| `patch_14` | 6EC8 | 3 | 4 | snd_17_0, unused_stream_01 |
| `patch_15` | 6EF2 | 3 | 0 | snd_19_0 |
| `patch_16` | 6F1C | 3 | 6 | snd_0F_3 |
| `patch_17` | 6F46 | 6 | 5 | snd_18_0 |
| `patch_18` | 6F70 | 6 | 7 | snd_1E_0 |
| `patch_19` | 6F9A | 0 | 2 | - |
| `patch_1A` | 9EFA | 4 | 0 | snd_06_0, snd_06_6 |
| `patch_1B` | 9F24 | 0 | 5 | snd_0D_6 |
| `patch_1C` | 9F4E | 7 | 0 | snd_01_4, snd_04_4, snd_0E_4 |
| `patch_1D` | 9F78 | 1 | 5 | - |
| `patch_1E` | 9FA2 | 3 | 7 | snd_0C_0, snd_0C_1 |
| `patch_1F` | 9FCC | 4 | 7 | snd_0C_5, snd_0C_7 |
| `patch_20` | 9FF6 | 7 | 0 | - |
| `patch_21` | A020 | 3 | 7 | - |
| `patch_22` | A04A | 3 | 7 | - |
| `patch_23` | A074 | 4 | 6 | snd_01_2, snd_01_3, snd_04_5, snd_08_5, snd_09_4, |
| `patch_24` | A09E | 4 | 6 | - |
| `patch_25` | A0C8 | 2 | 4 | unused_stream_03, unused_stream_04, unused_stream_06, |
| `patch_26` | A0F2 | 4 | 7 | snd_03_0, snd_05_6, snd_05_7 |
| `patch_27` | A11C | 4 | 6 | snd_0C_0, snd_0C_1, snd_0C_2, snd_0C_4 |
| `patch_28` | A146 | 0 | 2 | - |
| `patch_29` | A170 | 0 | 4 | snd_06_3, snd_06_5 |
| `patch_2A` | A19A | 0 | 6 | snd_06_4 |
| `patch_2B` | A1C4 | 4 | 7 | snd_08_5, snd_09_4, snd_0A_6 |
| `patch_2C` | A1EE | 6 | 0 | - |
| `patch_2D` | A218 | 2 | 7 | snd_02_2, snd_02_3, snd_04_0, snd_04_1, snd_0B_0, |
| `patch_2E` | A242 | 1 | 0 | unused_stream_09 |
| `patch_2F` | A26C | 1 | 0 | snd_04_3 |
| `patch_30` | A296 | 3 | 7 | unused_stream_10 |
| `patch_31` | A2C0 | 3 | 3 | - |
| `patch_32` | A2EA | 1 | 4 | snd_02_0, snd_02_1, snd_04_2, snd_0E_0, snd_0E_3, |
| `patch_33` | A314 | 5 | 4 | snd_01_3 |
| `patch_34` | A33E | 5 | 3 | snd_0D_0, snd_0D_1, snd_0D_2 |
| `patch_35` | A368 | 4 | 5 | snd_06_2 |
| `patch_36` | A392 | 4 | 7 | snd_04_5, unused_stream_05, unused_stream_06, |
| `patch_37` | A3BC | 4 | 7 | - |
| `patch_38` | A3E6 | 3 | 3 | snd_01_2, snd_01_3, snd_02_5, snd_0B_6, snd_0B_7, |
| `patch_39` | A410 | 1 | 3 | unused_stream_09 |
| `patch_3A` | A43A | 1 | 3 | unused_stream_09 |
| `patch_3B` | A464 | 1 | 0 | unused_stream_11 |
| `patch_3C` | A48E | 4 | 6 | snd_03_1 |
| `patch_3D` | A4B8 | 4 | 6 | snd_01_0, snd_01_1 |
| `patch_3E` | A4E2 | 2 | 0 | snd_06_1 |
| `patch_3F` | A50C | 5 | 4 | snd_0C_7 |
| `patch_40` | A536 | 4 | 7 | snd_0A_7, snd_0B_0, snd_0B_1, snd_0D_7 |
| `patch_41` | A560 | 4 | 5 | - |
| `patch_42` | A58A | 6 | 7 | snd_08_0, snd_08_3, snd_0A_1 |
| `patch_43` | A5B4 | 4 | 0 | snd_05_0 |
| `patch_44` | A5DE | 4 | 0 | snd_05_1 |
| `patch_45` | A608 | 0 | 0 | unused_stream_05, unused_stream_07, unused_stream_12 |
| `patch_46` | A632 | 0 | 0 | snd_01_0, snd_01_2, snd_02_4, snd_04_2, snd_08_0, |
| `patch_47` | A65C | 0 | 4 | snd_02_6 |
| `patch_48` | A686 | 4 | 6 | snd_08_0, snd_08_1, snd_08_2, snd_0A_0, snd_0A_2, |
| `patch_49` | A6B0 | 4 | 0 | - |
| `patch_4A` | A6DA | 2 | 7 | snd_01_0, snd_01_1, snd_01_2, snd_03_0, snd_03_1, |
| `patch_4B` | A704 | 0 | 5 | - |
| `patch_4C` | A72E | 5 | 7 | snd_03_4 |
| `patch_4D` | A758 | 7 | 0 | unused_stream_10 |
| `patch_4E` | A782 | 2 | 0 | - |
| `patch_4F` | A7AC | 4 | 7 | snd_02_5, snd_04_4, snd_0B_6, snd_0B_7, snd_0C_6 |
| `patch_50` | A7D6 | 4 | 7 | snd_01_4, snd_0E_3, snd_0E_4 |
| `patch_51` | A800 | 4 | 6 | snd_09_4, snd_0E_0 |
| `patch_52` | A82A | 2 | 5 | snd_0A_0, snd_0A_1 |
| `patch_53` | A854 | 4 | 7 | snd_0D_5, snd_0D_6 |
| `patch_54` | A87E | 4 | 7 | snd_0D_0, snd_0D_1, snd_0D_2, snd_0D_3, snd_0D_4 |
| `patch_55` | A8A8 | 4 | 7 | snd_03_2, snd_03_3, snd_05_2, snd_05_3, snd_05_4 |
| `patch_56` | A8D2 | 4 | 5 | - |
| `patch_57` | A8FC | 3 | 6 | - |
| `patch_58` | A926 | 1 | 7 | snd_05_5 |
| `patch_59` | A950 | 4 | 3 | snd_01_1, snd_09_4, snd_0B_0, snd_0B_1, snd_0B_6, |
| `patch_5A` | A97A | 4 | 0 | snd_02_5, snd_04_4, snd_0B_6, snd_0B_7 |
| `patch_5B` | A9A4 | 4 | 7 | snd_01_4, snd_0E_4 |
| `patch_5C` | A9CE | 5 | 7 | - |
| `patch_5D` | A9F8 | 2 | 7 | snd_08_0, snd_08_1, snd_08_2, snd_08_3, snd_08_5 |
| `patch_5E` | AA22 | 5 | 7 | snd_08_2, snd_08_3, snd_08_4, snd_08_6, snd_0B_4, |
| `patch_5F` | AA4C | 5 | 7 | snd_0A_2, snd_0A_3, snd_0B_0, snd_0B_1, snd_0B_2, |
| `patch_60` | AA76 | 2 | 6 | snd_0B_0, snd_0B_1 |
| `patch_61` | AAA0 | 5 | 7 | snd_08_7, snd_0A_4, snd_0A_5, snd_0C_4, snd_0C_5, |
| `patch_62` | AACA | 5 | 3 | - |
| `patch_63` | AAF4 | 5 | 5 | unused_stream_03, unused_stream_04, unused_stream_06, |
| `patch_64` | AB1E | 5 | 3 | unused_stream_03, unused_stream_04 |

## 6. The sounds

One row per sound N (the parameter of a command of type 08). Entries: entry number, stream label, YM2151 channel and priority. "make musictrace" gives the key-ons of the sound's own 600-frame window, from its command to the window's end, by channel (attributed through the track heard on the channel at each key-on, section 8; a window restarted after a reset counts only its last attempt, and no key-on outside a window counts); every sound keyed on, and each sound's counts add up to its window's total. "make sndtrace" says which of the M4a runs started it (attract mode, the same in the factory and the sound-on runs; the game run). Command names are leg M4e's (`data/sound/commands.json`); the labels here are `snd_NN_V` by number.

| Sound | Command | Entries: track (channel, priority) | make musictrace key-ons by channel | make sndtrace |
|---|---|---|---|---|
| 00 | 04 | 00 `snd_00_0` (0, 03); 01 `snd_00_1` (1, 03); 02 `snd_00_2` (2, 03); 03 `snd_00_3` (3, 03); 04 `snd_00_4` (4, 03); 05 `snd_00_5` (5, 03); 06 `snd_00_6` (6, 03); 07 `snd_00_7` (7, 03) | 0: 2, 1: 2, 2: 2, 3: 2, 4: 2, 5: 2, 6: 2, 7: 3 | - |
| 01 | 0A | 08 `snd_01_0` (7, 27); 09 `snd_01_1` (6, 27); 0A `snd_01_2` (5, 27); 0B `snd_01_3` (4, 27); 0C `snd_01_4` (3, 27) | 3: 51, 4: 63, 5: 6, 6: 67, 7: 5 | attract and game |
| 02 | 0C | 0D `snd_02_0` (7, 29); 0E `snd_02_1` (6, 29); 0F `snd_02_2` (5, 29); 10 `snd_02_3` (4, 29); 11 `snd_02_4` (3, 29); 12 `snd_02_5` (2, 29); 13 `snd_02_6` (1, 29) | 1: 39, 2: 64, 3: 8, 4: 24, 5: 24, 6: 13, 7: 13 | game |
| 03 | 0D | 14 `snd_03_0` (7, 29); 15 `snd_03_1` (6, 29); 16 `snd_03_2` (5, 29); 17 `snd_03_3` (4, 29); 18 `snd_03_4` (3, 29) | 3: 14, 4: 1, 5: 1, 6: 17, 7: 26 | - |
| 04 | 0F | 19 `snd_04_0` (0, 28); 1A `snd_04_1` (1, 28); 1B `snd_04_2` (2, 28); 1C `snd_04_3` (3, 28); 1D `snd_04_4` (5, 28); 1E `snd_04_5` (6, 28) | 0: 4, 1: 6, 2: 9, 3: 9, 5: 21, 6: 10 | - |
| 05 | 10 | 1F `snd_05_0` (0, 2A); 20 `snd_05_1` (1, 2A); 21 `snd_05_2` (2, 2A); 22 `snd_05_3` (3, 2A); 23 `snd_05_4` (4, 2A); 24 `snd_05_5` (5, 2A); 25 `snd_05_6` (6, 2A); 26 `snd_05_7` (7, 2A) | 0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 27, 6: 27, 7: 27 | - |
| 06 | 11 | 27 `snd_06_0` (2, 28); 28 `snd_06_1` (3, 28); 29 `snd_06_2` (1, 28); 2A `snd_06_3` (4, 28); 2B `snd_06_4` (5, 28); 2C `snd_06_5` (6, 28); 2D `snd_06_6` (7, 28) | 1: 1, 2: 1, 3: 50, 4: 23, 5: 23, 6: 23, 7: 1 | game |
| 07 | 12 | 2E `snd_04_0` (0, 28); 2F `snd_04_1` (1, 28); 30 `snd_04_2` (2, 28); 31 `snd_04_3` (3, 28); 32 `snd_04_4` (5, 28); 33 `snd_04_5` (6, 28) | 0: 4, 1: 6, 2: 9, 3: 9, 5: 21, 6: 10 | - |
| 08 | 14 | 34 `snd_08_0` (0, 28); 35 `snd_08_1` (1, 28); 36 `snd_08_2` (2, 28); 37 `snd_08_3` (3, 28); 38 `snd_08_4` (4, 28); 39 `snd_08_5` (5, 28); 3A `snd_08_6` (6, 28); 3B `snd_08_7` (7, 28) | 0: 10, 1: 9, 2: 10, 3: 8, 4: 8, 5: 26, 6: 23, 7: 23 | game |
| 09 | 16 | 3C `snd_09_0` (4, 37); 3D `snd_09_1` (5, 37); 3E `snd_09_2` (6, 37); 3F `snd_09_3` (7, 37); 40 `snd_09_4` (2, 37) | 2: 6, 4: 3, 5: 3, 6: 3, 7: 3 | - |
| 0A | 17 | 41 `snd_0A_0` (0, 29); 42 `snd_0A_1` (1, 29); 43 `snd_0A_2` (2, 29); 44 `snd_0A_3` (3, 29); 45 `snd_0A_4` (4, 29); 46 `snd_0A_5` (5, 29); 47 `snd_0A_6` (6, 29); 48 `snd_0A_7` (7, 29) | 0: 9, 1: 9, 2: 27, 3: 27, 4: 8, 5: 11, 6: 25, 7: 1 | - |
| 0B | 18 | 49 `snd_0B_0` (0, 28); 4A `snd_0B_1` (1, 28); 4B `snd_0B_2` (2, 28); 4C `snd_0B_3` (3, 28); 4D `snd_0B_4` (4, 28); 4E `snd_0B_5` (5, 28); 4F `snd_0B_6` (6, 28); 50 `snd_0B_7` (7, 28) | 0: 6, 1: 6, 2: 54, 3: 54, 4: 54, 5: 53, 6: 53, 7: 4 | - |
| 0C | 1A | 51 `snd_0C_0` (0, 28); 52 `snd_0C_1` (1, 28); 53 `snd_0C_2` (2, 28); 54 `snd_0C_3` (3, 28); 55 `snd_0C_4` (4, 28); 56 `snd_0C_5` (5, 28); 57 `snd_0C_6` (6, 28); 58 `snd_0C_7` (7, 28) | 0: 2, 1: 3, 2: 2, 3: 9, 4: 5, 5: 38, 6: 36, 7: 38 | - |
| 0D | 1B | 59 `snd_0D_0` (0, 28); 5A `snd_0D_1` (1, 28); 5B `snd_0D_2` (2, 28); 5C `snd_0D_3` (3, 28); 5D `snd_0D_4` (4, 28); 5E `snd_0D_5` (5, 28); 5F `snd_0D_6` (6, 28); 60 `snd_0D_7` (7, 28) | 0: 29, 1: 10, 2: 23, 3: 2, 4: 9, 5: 7, 6: 13, 7: 13 | - |
| 0E | 1C | 61 `snd_0E_0` (3, 28); 62 `snd_0E_1` (4, 28); 63 `snd_0E_2` (5, 28); 64 `snd_0E_3` (6, 28); 65 `snd_0E_4` (7, 28) | 3: 10, 4: 22, 5: 54, 6: 32, 7: 54 | attract and game |
| 0F | 1D | 66 `snd_0F_0` (0, 19); 67 `snd_0F_1` (3, 19); 68 `snd_0F_2` (1, 19); 69 `snd_0F_3` (2, 19) | 0: 1, 1: 1, 2: 1, 3: 1 | attract and game |
| 10 | 24 | 6A `snd_10_0` (4, 32) | 4: 1 | game |
| 11 | 25 | 6B `snd_11_0` (1, 32) | 1: 2 | game |
| 12 | 26 | 6C `snd_12_0` (5, 32) | 5: 1 | attract |
| 13 | 28 | 6D `snd_13_0` (5, 32) | 5: 1 | - |
| 14 | 2A | 6E `snd_14_0` (0, 32) | 0: 1 | game |
| 15 | 2B | 6F `snd_15_0` (4, 32) | 4: 1 | game |
| 16 | 2C | 70 `snd_16_0` (0, 32) | 0: 1 | game |
| 17 | 2D | 71 `snd_17_0` (7, 32) | 7: 1 | attract and game |
| 18 | 2F | 72 `snd_18_0` (5, 32); 73 `snd_18_1` (4, 32); 74 `snd_18_2` (6, 32) | 4: 1, 5: 1, 6: 1 | - |
| 19 | 30 | 75 `snd_19_0` (5, 32) | 5: 1 | attract |
| 1A | 31 | 76 `snd_1A_0` (5, 32); 77 `snd_1A_1` (5, 32) | 5: 22 | attract and game |
| 1B | 32 | 78 `snd_1B_0` (3, 3F) | 3: 1 | game |
| 1C | 33 | 79 `snd_1C_0` (5, 32) | 5: 1 | - |
| 1D | 34 | 7A `snd_1D_0` (4, 32) | 4: 1 | - |
| 1E | 35 | 7B `snd_1E_0` (5, 32) | 5: 1 | - |
| 1F | 37 | 7C `snd_1F_0` (7, 32) | 7: 1 | - |

**Attract mode.** With "SOUNDS IN ATTRACT" forced on (`sndtrace-sound`, docs/09 section 6), each attract demo sends 02, 1D, 1C (frame 831), 0A (872), then 31, 26, 2D, 30, and at its end 01 and 0B with parameter 27 (2301): sounds 0F, 0E, 01, then 1A, 12, 17, 19; command 0B releases the tracks of priority 27, sound 01's. The multi-track streams of attract mode are therefore `snd_01_0`-`snd_01_4` (channels 3-7, priority 27, still playing when the demo ends), `snd_0E_0`-`snd_0E_4` (channels 3-7, priority 28: heard over sound 01 while both run) and `snd_0F_0`-`snd_0F_3` (channels 0-3, priority 19, branching on global 0). The factory-NVRAM run starts the same entries and keys on nothing (zp_1E = F0).

**Priorities.** 03 (sound 00, all eight channels), 19 (0F), 27-2A and 37 (the multi-track sounds 01-0E), 32 (the one- to three-track sounds 10-1F but 1B), 3F (1B). With command 01 (zp_1E = F0) only a priority of at least 3C keys on (priority x 4 + 1 >= F0): sound 1B, entry 78, is the one sound that can still key on.

## 7. The data files

`asm/jsa/jsa.asm` includes `data/macros.asm` (no bytes) after `ram.asm`, and the data files in address order, each guarded by `.cerror` at both ends:

| File | Range | Content |
|---|---|---|
| `data/sounds.asm` | 61E4-65E5 | `sound_first_entry`, `sound_restartable`, `entry_priority`, `entry_channel`, `entry_stream` (125 words of stream labels), `entry_next`; the OKI effect tables `effect_phrase`, `effect_voice`, `effect_duck`; `global_set_index`, `global_set_value`; `tbl_65DD` |
| `data/streams_1.asm` | 65E6-6B7F | the streams of sounds 0F-1F and 00 (entries 00-07, 66-7C), two unreached streams |
| `data/patches_1.asm` | 6B80-6FC3 | patch records 00-19 |
| `data/unused_streams.asm` | 6FC4-79E2 | ten unreached streams |
| `data/streams_2.asm` | 79E3-9EF9 | the streams of sounds 01-0E, one unreached stream |
| `data/patches_2.asm` | 9EFA-AB47 | patch records 1A-64 |
| `lookup.asm` | AB48-AC47 | `key_level_curve` |

Labels: `snd_NN_V` (track V of sound NN, the order of its entries); `<stream>_tK` a jump, branch or jump-table target and `<stream>_subK` a call target inside the stream whose label precedes it (a target can be reached from other streams: sound 0E's first track ends by jumping into `snd_0F_1`'s loop, `snd_0F_1_t1`); `unused_stream_NN`; `patch_NN`. The source was generated once by a throwaway walker (not committed) and is hand-maintained.

**Unreached streams.** No word of `entry_stream`, no operand of a reached stream and no instruction points at them (the walk from the 125 entries, and M4a's relocation test for the code, docs/09 section 3 item 6). They parse from their first byte to their last as statements, with calls, jumps and tables that stay inside them and patch ops that name records of both banks: `unused_stream_01` (695E) and `02` (6A14) in streams_1, short streams that start with a `patch`; `03`-`12` (6FC4-79E2), ten streams that start with `tempo` and `patch` and call subroutines and jump tables among themselves (`unused_stream_04_sub1` and the like); `13` (9BDB in streams_2: `var_load R_RANDOM`, `var_and 7F`, `var_store R_VELOCITY`, `ret`). They are structured like the rest; they are labelled, not deleted, because the bytes must stay.

**Not reached statements.** 35 statements follow a `jump` or a `jump_table` inside a stream (a `ret` mostly, a few `fine_tune 0`, `transpose 0`, `ret` tails) and are marked `; not reached` in the source.

**Residue: none.** Every byte of 65E6-AB47 is a statement of a stream or a field of a record; no `.byte` row is left (`tools/test_jsa_music.py` fails on one). The tables of sounds.asm are tables with readers. `tbl_65DD` (65DD-65E5, 9 zero bytes before the first stream) keeps its address label as the one unknown of the owned files: only dormant code reads it (cmdtype_10 at 44C5, cmdtype_0D at 44ED-451B, ymtimer.asm at 58AB-590F), no command has type 0D or 10, and no index is bounded, so neither its role nor its extent is known.

## 8. MAME evidence

**make musictrace** (`tools/mame/musictrace.lua`, new; headless, from an empty private NVRAM/cfg under `build/mame/state-musictrace/`): from frame 1200, one 600-frame window per command of type 08 (the 32 of `MUSIC_SOUNDS`): command 00 (`imm_00`, every track stopped), 02 four frames later (zp_1E = 0), the sound command four frames after that, all written to the latch as the 68010 writes them (issue #15's accepted stimulus). The 68010's own command bytes are replaced by 6D in a write tap (6D is queued by `h_nmi` and ignored by `dispatch_command`), so only the injected commands reach the sequencer (a default the implementer took, pending Jesus's card: the issue delegated injection only, CLAUDE.md section 5); a sound-board reset by the 68010 during a window restarts it 120 frames later. Taps: reads of `entry_stream` at 4632 (with zp_03, the sound), of `op_handlers` at 506D and 50A3, of 65E6-AB47 at 485B (the statements read), YM2151 writes (key-ons attributed to the sound of the heard track: the last of the channel's list, its ram_0248; counted only from a window's sound command to its last frame, and dropped with a window that is restarted). `tools/jsa_music.py summary` checks every statement read against the listing (a macro statement start) and writes `artifacts/musictrace-summary.json` (counts, addresses, labels, command and sound numbers).

Run of 2026-11-05 (MAME 0.289, the reference set, 374 s): 22,577 frames, 32 windows, 7 sound-board resets by the 68010, 4 windows redone; every sound 00-1F started all its entries and keyed on (section 6); 2,811 distinct statements read in 118 of the 119 distinct streams (all but `snd_1A_0`, section 1); 26 ops dispatched (section 4); 1,216 command bytes of the 68010 replaced.

**make sndtrace** (docs/09 section 7, M4a's three runs, rerun 2026-11-05 with the same result and summary): the handlers' execution (section 4) and the entries started in attract mode and the game (section 6). Every data read of 65E6-AB47 in those runs lies inside a statement the walk reaches or a patch record: `tools/test_jsa_music.py` checks it with the committed walker whenever the three `build/mame/sndtrace-*.txt` traces are present (skipped in CI, which has no ROMs); `make sndtrace` itself checks reads against data statements.

## 9. Checks

- `make check`: 25 files, 0 differences. `make coverage`: `stunrun-jsa` instr 7,351, data 20,376, blob 0, fill 37,809, as before; the per-file rows now split the former `data/music.asm` (17,762 bytes) into streams_1 1,434, patches_1 1,092, unused_streams 2,591, streams_2 9,495, patches_2 3,150.
- `tools/test_jsa_music.py` (CI, no ROMs; assembles the tree with 64tass): the op macros assemble to the op table's lengths and op bytes; each handler of `op_handlers` is the op table's and reads `length - 2` bytes through `next_operand` (the branches two in `branch_taken` and `branch_not_taken`; `op_patch` one on each of its two paths); the data files are one statement after another from 65E6 to AB47, no raw `.byte`; every `patch_NN` starts a 42-byte record of the five record macros; a walk of the image from `entry_stream` and the `unused_stream` labels lands on statement starts of the right macro, every target on a label, every record operand on a `patch_` label, and every statement it does not reach is a record field or marked "not reached"; **relocation**: the tree with one byte inserted before `snd_0F_0` (guards removed, the final fill shortened) differs from the original only by words that grew by one, each an address into the moved range, and every pointer of the walk and every `entry_stream` word is among them; the committed musictrace summary covers the 32 sounds with key-ons, its key-on table adds up to the windows' counts, and it names only labels of the source; with a local `build/mame/musictrace.txt`, the trace agrees with the listing; with the local `make sndtrace` traces, every data read of 65E6-AB47 lies in a walked statement or a patch record.
- The data moved by any amount is relocated, but the program's sound is timing-sensitive (docs/09 section 3 item 7): a moved build keeps its YM2151 stream only when page offsets are kept. `make check` remains the gate.

## 10. Not verified, open

- The other voice kind (3.8) and its ops never run; their effects are read from the code only. What chip they were written for is not in this program.
- `sync`, `sync_group`, `portamento`, `fade_mode`, `tempo_add`, `respond`, `release`, `ym_ct`, the skip ops and `jump_table_inc` are used by no stream and were never dispatched; their descriptions are from the code.
- `transpose_add` (85) is used by reached streams but was not dispatched in the runs (600-frame windows, and the game run's 7,200 frames, do not reach those statements).
- That the modulator-mask order of the level loop (3.4) and the unloaded M1 curve byte are oversights of the original is not knowable; they are what the code does, and the sound MAME plays follows it.
- Musical readings (what a sound is in the game) are not made here: the labels are numbers, and leg M4e names the commands.
- 64tass 1.59 (CI) was not run locally; the macros use named parameters and default values as the Spindizzy tree does with 1.59.
