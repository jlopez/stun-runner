# The sound command protocol between the 68010 and the 6502

**Date**: 2026-11-05 (milestone 4, leg M4e, issue #15). How the 68010 talks to the JSA II board's
6502: the latch pair at 600000, the reset at 604000, the level 4 interrupt, both programs' code
for it, the command set 00-6C with the 68010's own name for each command, and the MAME runs that
show it. Addresses: 68010 addresses as six hex digits, 6502 addresses as four. **CODE** means
read off the image (`build/stunrun-68k.bin` with `unidasm -arch m68010`; the 6502 program in its
source `asm/jsa/`, leg M4a, docs/09), **MAME** a run of the committed script
`tools/mame/sndproto.lua` (`make sndproto`, MAME 0.289, section 8), **SRC** MAME's source
(`~/.local/src/mame`, tag mame0289, file:line). 6502 label names are the source's (M4a, M4c
and M4d named them: docs/09 sections 4 and 10, docs/12); the sequencer's terms (sound, track,
list, priority) are docs/12's. 68010 names are the ones this leg puts into `ida/code_map.py`.

The machine form of section 6 is `data/sound/commands.json`: one entry per command value, with
its name, the 6502's tables, the 68010 call sites and the MAME counts. The 6502 source legs and
M5 take their command names from it (decision of 2026-11-05, issue #15).

## 1. The transport

| What | Where | Evidence |
|---|---|---|
| Command, 68010 to 6502 | a byte write of the high byte (D8-D15) at 600000-603FFF | `init_multisync` installs `main_command_w` with mask FF00, harddriv.cpp:4805 **SRC**; the game writes with `move.b d0,$600000` (023EF6, 023EC0), the boot program with `move.b #n,$600000` (008DDA ...) **CODE** |
| What the write does | the byte goes into the latch, `main_to_sound_ready` is set, the 6502's NMI is asserted and held | atariscom.cpp:180-195 (`delayed_sound_write`; a write over an unread byte logs "Missed command" and overwrites it) **SRC** |
| The 6502 takes it | a read of 2802 (/RDP; the program reads the +8 mirror 280A) clears the flag and the NMI | atariscom.cpp:140-150, atarijsa.cpp:121 **SRC** |
| Response, 6502 to 68010 | a write at 2A02 (/WRP) sets `sound_to_main_ready` and asserts the 68010's level 4 | atariscom.cpp:128-133, 202-212; atarijsa.cpp:125; harddriv.cpp:1875 (`main_int_cb` to `sound_int_write_line`), harddriv_m.cpp:98 (level 4, "/LINKIRQ on STUN Runner") **SRC** |
| The 68010 takes it | a read of the high byte at 600000 returns the byte, clears the flag and the interrupt | atariscom.cpp:112-120 **SRC**; `h_level4_sound` reads at 023F66 **CODE** |
| The 6502's view of both flags | /RDIO (2804, read at 280C) bit 5 = a response not yet read (active high), bit 6 = a command not yet read (active low) | atarijsa.cpp:189-198 (`jsa_ii_ioports`) **SRC** |
| The 68010's view | none of the two flags. The game tests A80000 bit 15 before every write (023EB0, 023EEC) and writes only when it is 1 | **CODE**. MAME's `mainpcb:a80000` port has bits 3-15 `IPT_UNUSED`, active low (harddriv.cpp:1123-1127), so the bit always reads 1 **SRC**. That bit 15 is the board's "latch free" signal is inferred from the code alone |
| Reset | any read of 604000-607FFF resets the whole JSA device: the 6502, the YM2151, the M6295 and the latch pair (both flags and both bytes cleared); the read returns FFFF. A write there is the NWR latch (docs/01 section 3), not a reset | harddriv.cpp:603, harddriv_m.cpp:288-293 (`m_jsa->reset()`), atariscom.cpp:72-77 **SRC** |

The reset does not clear the 68010's level 4 line: a response pending at the reset keeps it
asserted. Both reset paths of the 68010 therefore read 600000 straight after 604000: the boot
program at 00023C/000242, the game in `reset_sound_board` at 023FA8/023FAE **CODE**.

```
 68010 (game)                         latch pair                        6502
 queue_sound_command(n) -> sound_queue
 ... sent at the third flush (main loop pass) after ...
 flush_sound_queue
   send_sound_byte: A80000 bit 15 = 1?
   move.b n,$600000  ---------------> command byte, NMI asserted
                                                         h_nmi: wait RDIO bit 5 = 0
                                                         ldx $280A (5839) -> NMI cleared
                                                         cmd_class bit 7: cmd_queue
                                                         class 0-3: imm handler, now
                                                         main_loop: dispatch_command
                                                         ... a response, sometimes:
                     level 4 <------- response byte <--- stx/sta $2A02 (413E, 455D, 4164)
 h_level4_sound: move.b $600000 -> sound_resp_ring (nobody reads it)

 reset_sound -> reset_sound_board:
   move.w $604000 ------------------> JSA reset            6502 reset (4000)
   move.b $600000 (drop a response)                         ... initialisation
                     level 4 <------- FF <------------------ lda $280A (4139), stx $2A02 (413E)
```

## 2. The 68010 side

### 2.1 The game program

- **Queue** (`queue_sound_command`, 0301CA, `queue_sound_command(n)`): appends the byte to one of
  three 32-byte buffers (`sound_queue`, FFDB64-FFDBC3; counts `sound_queue_count`, FFDBC4-FFDBC6;
  the buffer filled is `sound_queue_fill`, FFDBC8). A full buffer drops the byte (0301E6-0301EC)
  **CODE**. Every command of game play goes through it: 133 calls, 96 `jsr $301CA.l` and 37
  `jsr (A2)` in the four routines that load A2 with it (02430E, 02819C, 028350, 029B82), section 6.
  Two parts of the game program send without the queue: the audio test calls `send_sound_byte`
  (023EDA) directly at 04392C, 04393E and 04395C (section 5), and `sound_watchdog` (03001E, which
  nothing calls) calls `send_sound_byte_once` (023EDE) at 0300B8 **CODE**; `data/sound/commands.json`
  lists them as `direct_sends`.
- **Flush** (`flush_sound_queue`, 03013C): called once per pass of the main loop (024500, inside
  the game's main loop 024306). Sends every byte of the buffer `sound_queue_send` (FFDBCA) through
  `send_sound_byte` (030170), three empty loop turns after each (03017A-030182), empties it, then
  advances both buffer numbers modulo 3 (030194-0301BE). `reset_sound` starts them at fill 0,
  send 1, so a command goes out at the third flush after it is queued: the two flushes before
  send the other two buffers. The code does not say why. MAME: the 01 queued at frame 822 is
  written at frame 831 **CODE, MAME**.
- **Send** (`send_sound_byte`, 023EDA): with SR = 2400 (level 4 masked), if A80000 bit 15 is set,
  writes the byte (023EF6) and returns 1; else restores SR and tries again, 256 tries in all,
  then returns 0 and the byte is lost (the flush ignores the result). `send_sound_byte_once`
  (023EDE) is the same with one try. `send_sound_with_reply` (023E96) writes a command and points
  the next N responses at a buffer; it has no caller **CODE**.
- **Responses** (`h_level4_sound`, 023F24, the game's level 4 vector at 020070): reads the byte
  (023F66) into the reply buffer when one is pending (`sound_reply_ptr`, FF9474, counted down
  by `sound_reply_count`, FF9472), else into the 16-byte ring `sound_resp_ring` (FF9478, in
  index `sound_resp_in` FF9471, wrapping at 16 with no full check, 023F38-023F52). The only
  reader of the ring is `get_sound_response` (023F72), and its only caller is the routine at
  03001E, which nothing calls. **The game reads no response.** A second entry 023F0C, 24 bytes
  before the vector target, drops the exception frame when the interrupted level is 4 or more;
  nothing reaches it either **CODE**.
- **The unused watchdog** (`sound_watchdog`, 03001E): no absolute or PC-relative reference, no
  pointer to it anywhere in the image **CODE**, and in MAME its counters FFDB5C-FFDB63 are written
  only by `reset_sound` (030102-030110) and the RAM clears (021302, 021392, 00133A) **MAME**. Read
  as code it is a health check: after a reset it waits up to 180 calls (`sound_wait_ready`
  = B4) for the FF; every 240 calls (`sound_check_timer`) it sends 07 with
  `send_sound_byte_once` (0300B8) and expects, within 30 calls (`sound_wait_status`), a status
  byte whose bits 0-2 are clear; a wrong byte, a timeout, or more than 181 failed sends
  (`sound_check_tries` above B4, 0300D6-0300E6: the count before the increment is compared,
  so the 182nd consecutive failure) call `reset_sound`. So the game has the code to supervise the board and
  does not run it.
- **Reset** (`reset_sound`, 0300F8): `reset_sound_board` (023FA2: 604000, 600000, reply pointer
  cleared), the watchdog counters, the queue emptied. Callers: 0243B2, 029B42, 02BA16, 02BB4A,
  02BD5E, 02C144, 030070 (the watchdog) and 043728 (the audio test). MAME: 02C144 (in
  `init_coprocessors`) at frame 367 and 0243B2 (the main initialisation 024306) at 410, 02BA16
  at each attract cycle (3964, 8668) and once when the game run starts (981), 02BB4A at 965,
  029B42 four times during play (1233, 3383, 6280, 9900); 02BD5E never **MAME**.
- **Attract mode's sound**: when attract mode starts, 028362-02837E queues 02 if bit 11 of
  `game_options` (FF94EE) is set and 01 if it is clear (section 7.1). At the end of each attract
  demo a case of the main loop's state switch (024540) queues 01, 0B and 21 (024E3E-024E54; the
  same three at 0253A0-0253B6): MAME, attract run, frame 2295 **CODE, MAME**. This is the "other
  path" docs/09 section 6 left open.

### 2.2 The boot program (pair R, VBR = 0)

The boot program's tests talk to the board directly, with interrupts masked, never through the
game's queue **CODE, MAME**:

- `boot_reset` (000216) reads 604000 (00023C) and 600000 (000242); the boot program's level 4
  handler (00081C) reads 600000 into D0.
- The test menus (self-test switch, IN0 bit 5, harddriv.cpp:1093): TEST MENU > SPECIAL FUNCTIONS
  > SOUND BOARD TESTS (menu text 006918) opens the SA AUDIO TEST MENU (menu table 008D60: EXIT
  008D6C, SA SELF TEST 008D94, PLAY SOUNDS 008EF2). The boot program's re-entry at 000FB2 (VBR
  0, a new stack) also resets the board (000FC2): MAME frame 543, after start has bypassed the
  power-up self-test, and again when the audio test is left.
- `boot_sa_audio_test` (008D94): 604000 (008DB8), 180 vertical syncs (0013EC waits on PORT0 bit
  2), the response must be FF (008DCC), else message 90; then 07 (008DDA), two syncs, the status
  byte (008DFA) into FF8090, `boot_show_sound_status` (008E2C), `boot_play_test_sounds`
  (008E84). MAME, selftest run: reset at frame 1659, FF, 07 at 1839, status 00, then 04, 00, 05,
  00 at 1841, 2481, 2513 and 2641, and the screen says the audio test is OK **MAME**.
- `boot_show_sound_status` prints one message per status bit from the table at 008ED0 (a count,
  8, then {bit, message number} pairs; message pointers at 010136). The messages name the bits:
  80, 40, 20 the 6502 program PROM (P1BAD, P2BAD, P3BAD; the JSA II program sets only bit 7), 10
  the first RAM at 0000 (R1BAD), 08 the second RAM at 0800 (R2BAD), 04 IRQs not present (IRBAD),
  02 the YM2151 timed out (YMBAD), 01 the main loop not running (MLBAD) **CODE**. This is the
  68010's reading of the 6502's `board_status` (section 3.3).
- `boot_sa_ii_test` (008F68), called from the power-up self-test sequence (00533C): the same with
  messages 105-108 (SA II test OK, error, timeout error, in progress): status 0 is OK **CODE**.
- PLAY SOUNDS enters the game program's `audio_test` (043718) through `game_entry_2` (021378):
  section 5.

## 3. The 6502 side

### 3.1 The command byte (`h_nmi`, 57E3)

1. Waits while RDIO bit 5 is set (57E4-57E9): a command is not taken while the 68010 has not
   read the last response.
2. `nmi_mode` (set to FF at reset, 4127): FF is the command mode; 0 is the data mode of command
   08 (the byte is stored at `nmi_data_ptr`, 57F2-5807, read at 57FC); anything else drops the
   byte.
3. Command mode: the next slot of `cmd_queue` (48 slots at 0200, at most 47 commands pending: in
   = out is empty, 4171-4177; when full the oldest entry is dropped, 5815-5831) gets 6D, then the byte is read (5839). A byte of 6D or more stays 6D
   (583C-583E). Else `cmd_class` (6093+byte): bit 7 set, the byte replaces the 6D (5845-5846);
   0-3, the byte is an **immediate command**, run at once inside the NMI through `imm_handlers`
   (61DA) entry class+1 (584F-585D); 4-7F (no command has one) leaves the 6D **CODE**.
4. `main_loop` (4149) takes one queued byte per pass (4171-4186) and calls `dispatch_command`
   (4371): Y of 6D or more, or a `cmd_type` (6100+Y) of 15 or more (FF, the immediate commands),
   does nothing; else the handler `cmdtype_handlers` (472F) gives for the type runs with A =
   `cmd_param` (616D+Y) **CODE**.

MAME, inject run: the bytes 6D, 7F, 80 and FF written at 600000 are each taken and left in their
slot as the 6D written first (5836): `h_nmi`'s queue write of the byte itself (5846) wrote none of
them; no byte is lost in any run (section 8) **MAME**. That `dispatch_command` then skips a 6D
slot is the code (`cpy #$6D`, `bcs` at 4371-4373) **CODE**: the trace's dispatch lines are reads
of `cmd_type` at 4375, after that test, so they cannot show it.

### 3.2 Responses

| Byte | When | Where |
|---|---|---|
| FF | after every reset, once the initialisation has dropped any pending command (4139) | 413C-413E |
| 10 | the self-test found the zero page or the stack bad; the 6502 then stops (never in MAME: RDIO bit 7 cannot be set, docs/09 section 1) | 41A1-41A3 |
| the status byte `board_status` | command 07 (imm_03_send_status, 4533) | `send_response` 4553-4568 (the write at 455D) |
| 6D | command 06 (imm_02_send_count, 4543) | `send_response` |
| `coin_state` | command 03 (imm_01_send_inputs, 5DAD): `read_inputs`'s four 2-bit coin counters (5D11-5D57: RDIO bits 0-3 debounced in `coin_debounce`,x, `coin_field_one`,x added inside the field mask `coin_field_mask`,x), or the raw RDIO bits 0-3 when RDIO bit 7, the self-test, is set (5CE8-5D08; never in MAME) | `send_response` |
| AA, then the next byte written | command 08 (imm_04_loopback, 5CB8): a loop-back | `send_response` |
| 55 | command 09 (type 09, `queue_response` 44D0) | `main_loop` 4159-4164 |
| a stream's operand | stream op 96 (`op_respond`, 550E, through `queue_response`) | `main_loop` |

`send_response` waits for RDIO bit 5 to clear before and after its write, so the immediate
commands hold the 6502 inside its NMI until the 68010 has read their answer. `main_loop` sends a
queued response only when bit 5 is clear (4152-4157) and never waits; `resp_queue` has 16 slots, at most 15 responses pending
(44D0-44E6: the new in may not equal out), and
sets `resp_queue_full` = 80 when a byte is dropped **CODE**.

MAME saw FF after every reset (29 resets over the five runs), 00 for 07, 00 for 03, 6D for 06,
55 for 09, AA and the echoed byte for 08 (inject run: 5A; in the audio test the next byte
written is the cursor command 34, which comes back), and nothing else; no stream sent an op 96
response **MAME**.

### 3.3 The status byte (`board_status`)

The self-test (402A-4112, only when RDIO bit 7 is set) leaves bits 7 (ROM checksum not FF,
40E4-40EC), 4 or 3 (a RAM page below 0800 or from 0800 bad, 418C-419F) and 2 (no timed IRQ in
65,536 loops, 410D-4111). `ym_wait` sets bit 1 on a YM2151 time-out. `imm_03_send_status` sends the byte,
then sets bits 0 and 2; `main_loop` clears bit 0 every pass (414C-4150) and the timed IRQ clears
bit 2 (41F3-41F7), so a second 07 reads 0 in those bits only if both still run **CODE**. The
68010's messages for the bits are in section 2.2.

## 4. Timing and capacity

| Where | Limit | What happens beyond it |
|---|---|---|
| 68010 `sound_queue` | 32 commands per buffer, one buffer sent per main loop pass | the command is dropped (0301E6-0301EC) |
| 68010 `send_sound_byte` | 256 tests of A80000 bit 15 | the command is dropped |
| 68010 spacing | three empty loop turns and the next call between two bytes of one flush (03015A-030192) | none: no other wait for the 6502 |
| 6502 `h_nmi` | waits for RDIO bit 5 clear, without a limit | a response the 68010 never reads stops command intake |
| 6502 `cmd_queue` | 47 commands (48 slots) | the oldest is dropped |
| 6502 `resp_queue` | 15 responses (16 slots) | the new one is dropped, `resp_queue_full` = 80 |
| 68010 `sound_resp_ring` | 16 responses | the oldest is overwritten (no reader anyway) |
| boot tests | 180 vertical syncs after a reset before the FF is read, two after the 07 | message 90 or 107 when the FF is missing |

The game relies on A80000 bit 15 to know that the 6502 has taken the previous byte: nothing else
in its send path waits. In MAME, where the bit always reads 1, the flush writes the bytes of one
buffer a few tens of microseconds apart; MAME's scheduler interleaves the two CPUs finely around
each write (atariscom.cpp:171-193, `add_quantum` of 5 us for 1 ms) and no byte was lost in any
run: every byte written was read by `h_nmi` (section 8) **MAME**. On the real board the bit is
the only protection against overwriting the latch; its source on the schematic is not known.

After a reset the 6502 answers FF within a frame in MAME (reset at frame 367, FF at 368); the
game does not wait for it (only the unused watchdog would), the boot tests wait 180 syncs
**MAME, CODE**.

## 5. The 68010's names for the commands: the audio test

The game program's audio test (`audio_test`, 043718; title AUDIO TEST at 05C3DA, drawn through
`reload_gsp` at 04373A) lists `audio_test_list` (05C63C): 108 entries of 22 bytes, a word (the
command value) and a name of up to 20 characters, sorted by name, ended by a word FFFF at 05CF84.
The cursor (index D4) selects an entry; button 2 sends its word (`move.w (a4,d0.w),d1` at
043954, after the index D4 times 16h at 04394E-043950, `send_sound_byte` at 04395C), button 1 sends 00 (04393E), and each move of the stick
sends 34 (04392C) **CODE**. The 108 words are 00-6C less 03, each once, so the list names every
command the game can send by its own name **CODE**.

MAME, soundtest run: the boot program's menus driven with the buttons (frames in
`tools/mame/sndproto.lua`; button 1 moves up, button 2 down, start selects), PLAY SOUNDS, then
each of the 108 entries played in list order: 04395C wrote each entry's own word, all 108 values
once **MAME**. The names in `data/sound/commands.json` are `snd_` and the entry's name in lower
case (`snd_tubmus` for 0A); 03, which the list leaves out, is `cmd_03_imm`.

## 6. The command set

Classes, types and parameters are the 6502's tables at 6093, 6100 and 616D (`cmd_class`,
`cmd_type` and `cmd_param` in `asm/jsa/tables.asm`, which `tools/test_sound_commands.py` checks
`data/sound/commands.json` against in CI) **CODE**; the types:

| Type | Handler | What it does |
|---|---|---|
| 00 | `cmdtype_00_min_priority` 438A | `min_priority` = 4 x param, a floor on the track priority (docs/09 section 10.2): F0 for 01, 0 for 02. While `min_priority` is not 0 the OKI start returns at once (5BFE-5C01), and a YM2151 key-on needs the track's priority byte `sounding_prio` >= `min_priority` (4EE3-4EF0): with F0 only the priority-3F sound (command 32, byte FD) keys on |
| 01 | `cmdtype_01_set_var` 43AD | `seq_vars` + (`global_set_index`+param AND 1F) = `global_set_value`+param; a stream op reads `seq_vars,y` (54EE) |
| 03 | `cmdtype_03_immediate` 43CA | `imm_handlers` entry param: entry 0 is `init_sound` (4238), the initialisation reset also runs (OKI reset, response queue emptied, voice tables cleared, key-off on the eight YM2151 channels, MIX set) |
| 05 | `cmdtype_05_stop_sound` 43EE | if command param is of type 08, every track playing its sound gets `trk_sound` = FF (stopped) |
| 08 | `cmdtype_08_start_sound` 4569 | starts sound param, one track per entry (`sound_first_entry` first entry, `entry_next` next; priority `entry_priority`, YM2151 channel `entry_channel`, byte stream `entry_stream`; docs/12 section 1) |
| 09 | `queue_response` 44D0 | param into `resp_queue` |
| 0A | `cmdtype_0A_release_sound` 445F | if command param is of type 08, every track playing its sound is released (`trk_slide_rate_hi` = D0, `trk_slide_time_hi` = 2, `trk_sound` = FE) |
| 0B | `cmdtype_0B_release_priority` 4496 | every track whose priority (`trk_priority` / 4) is param is released as by type 0A |
| 13 | `cmdtype_13_oki_play` 5BFE | OKI phrase `effect_phrase`+param on the channel and attenuation of `effect_voice`+param, unless `min_priority` is not 0 (docs/10) |
| 14 | `cmdtype_14_oki_stop` 5C6F | stops the OKI channel whose current phrase is param |
| FF | `imm_handlers` 61DA | an immediate command (class 00-03), inside `h_nmi` |

The names fit what the 6502 does with them, which is a check on both: SOFF/SON raise and clear the
priority floor (`min_priority` F0 starts no OKI sample and keys on only priority 3F), STAT the status, SMAX sends the command count 6D, ECHO queues 55; the K names (KSCRAP
2E, KDIVE 36) are type 05 and stop exactly the sound of SCRAP (2D) and DIVE (35); the F names
of type 0A (FSUBFAN 13, FSTBEG 15, FHISCOR 19, FHELCPT 27, FVRCFT 29) release the sound of
SUBFAN, STBEG, HISCOR, HELCPT and HVRCFT; FTUBMUS (0B) releases priority 27, the tracks of TUBMUS
(0A), and FMAPMUS (0E) priority 29, those of MAPMUS, WAIT and CHMAP; KBRAKE (66) stops phrase 48,
which BRAKE (65) plays **CODE**.

Columns: the 68010's name (section 5), the 6502's class, type and parameter, what the 6502 does
with it, how many times MAME saw the 68010 write it in the attract and game runs, and the call
sites of `queue_sound_command` that can queue it (the full lists, with the routine around each
site, are in `data/sound/commands.json`; `site_notes` there says how the 17 computed or
alternative values are chosen). "Audio test only" means no instruction of the game sends it
except the audio test's 04395C.

| Cmd | 68k name | Class | Type | Param | What the 6502 does | MAME attract / game | Call sites (queue_sound_command) |
|---|---|---|---|---|---|---|---|
| 00 | STOP | FF | 03 | 00 | the sound initialisation (init_sound, 4238) | 0 / 0 | none; written by 008E9A, 008EC6, 04393E |
| 01 | SOFF | FF | 00 | 3C | priority floor: min_priority = F0 (no OKI start, only priority 3F keys on) | 5 / 1 | 024E42, 0253A4, 02837E |
| 02 | SON | FF | 00 | 00 | no floor: min_priority = 0 | 0 / 1 | 027178, 02837E |
| 03 | (not listed) | 00 | FF | 00 | sends coin_state, read_inputs's four 2-bit coin counters (raw RDIO bits 0-3 under the self-test) | 0 / 0 | none |
| 04 | YTST | FF | 08 | 00 | starts sound 00 | 0 / 0 | none; written by 008E84 |
| 05 | ADTEST | FF | 13 | 00 | plays OKI phrase 1 | 0 / 0 | none; written by 008EB0 |
| 06 | SMAX | 01 | FF | 00 | sends 6D, the number of command values the tables cover | 0 / 0 | none (audio test only) |
| 07 | STAT | 02 | FF | 00 | sends board_status, the status byte, then sets its bits 0 and 2 | 0 / 0 | none; written by 008DDA, 008F94, 0300B8 |
| 08 | SCUM | 03 | FF | 00 | sends AA, takes the next byte written and sends it back | 0 / 0 | none (audio test only) |
| 09 | ECHO | FF | 09 | 55 | queues the response 55 | 0 / 0 | none (audio test only) |
| 0A | TUBMUS | FF | 08 | 01 | starts sound 01 | 3 / 8 | 032278 |
| 0B | FTUBMUS | FF | 0B | 27 | releases every track of priority 27 (the sound of command 0A) | 2 / 6 | 024E4E, 0253B0, 0268A8, 028B94 and 2 more |
| 0C | MAPMUS | FF | 08 | 02 | starts sound 02 | 0 / 4 | 024A7C, 029C0E, 02AF58 |
| 0D | WAIT | FF | 08 | 03 | starts sound 03 | 0 / 0 | 029C0E |
| 0E | FMAPMUS | FF | 0B | 29 | releases every track of priority 29 (the sounds of commands 0C, 0D, 17) | 0 / 4 | 02769C, 027A0A, 02ABEC |
| 0F | SUBSTA2 | FF | 08 | 04 | starts sound 04 | 0 / 1 | 028F8A |
| 10 | WARPMUS | FF | 08 | 05 | starts sound 05 | 0 / 0 | none (audio test only) |
| 11 | ASMUS | FF | 08 | 06 | starts sound 06 | 0 / 1 | 028F8A |
| 12 | SUBFAN | FF | 08 | 07 | starts sound 07 | 0 / 1 | 028F8A |
| 13 | FSUBFAN | FF | 0A | 12 | releases the tracks of sound 07 (command 12) | 0 / 4 | 027782, 027994 |
| 14 | STBEG | FF | 08 | 08 | starts sound 08 | 0 / 1 | 024FF2 |
| 15 | FSTBEG | FF | 0A | 14 | releases the tracks of sound 08 (command 14) | 0 / 1 | 02763E, 02B6C0, 038F3A |
| 16 | INPASS | FF | 08 | 09 | starts sound 09 | 0 / 1 | 031FAE, 03262E, 03A2D2 |
| 17 | CHMAP | FF | 08 | 0A | starts sound 0A | 0 / 0 | 024A72, 029BF8 |
| 18 | HISCOR | FF | 08 | 0B | starts sound 0B | 0 / 0 | 024D5C, 02509A, 0250D6, 02516E and 3 more |
| 19 | FHISCOR | FF | 0A | 18 | releases the tracks of sound 0B (command 18) | 0 / 0 | 024D74, 024DE8, 03EE82, 03EEAE and 1 more |
| 1A | VICTORY | FF | 08 | 0C | starts sound 0C | 0 / 0 | 02732A, 02749C |
| 1B | ATRCTMUS | FF | 08 | 0D | starts sound 0D | 0 / 0 | 0245F4, 02466A |
| 1C | TUBEG | FF | 08 | 0E | starts sound 0E | 3 / 5 | 024B98, 028498 |
| 1D | ENG | FF | 08 | 0F | starts sound 0F | 3 / 5 | 024B92, 027BFC, 028492 |
| 1E | SAME | FF | 01 | 00 | seq_vars = 00 | 62 / 124 | 02822A, 028244, 028C54, 03ADD0 and 1 more |
| 1F | ACL | FF | 01 | 01 | seq_vars = 01 | 44 / 120 | 02822A, 03ADD0 |
| 20 | DCL | FF | 01 | 02 | seq_vars = 02 | 45 / 71 | 03ADD0 |
| 21 | SENG | FF | 01 | 03 | seq_vars = 03 | 2 / 6 | 024E54, 0253B6, 0268B2, 028B8A and 2 more |
| 22 | FACL | FF | 01 | 04 | seq_vars = 04 | 29 / 87 | 028244, 028332, 03ADD0 |
| 23 | FDCL | FF | 01 | 05 | seq_vars = 05 | 25 / 33 | 03ADD0 |
| 24 | CD | FF | 08 | 10 | starts sound 10 | 0 / 21 | 02912A, 03E7FA, 03EAF4, 03EEDE and 1 more |
| 25 | WARN | FF | 08 | 11 | starts sound 11 | 0 / 24 | 0280C0 |
| 26 | HELCPT | FF | 08 | 12 | starts sound 12 | 3 / 0 | 033B82 |
| 27 | FHELCPT | FF | 0A | 26 | releases the tracks of sound 12 (command 26) | 2 / 0 | 0268BC, 03568A |
| 28 | HVRCFT | FF | 08 | 13 | starts sound 13 | 0 / 0 | 033A8E |
| 29 | FVRCFT | FF | 0A | 28 | releases the tracks of sound 13 (command 28) | 0 / 0 | 0268C6, 03568A |
| 2A | WINGS | FF | 08 | 14 | starts sound 14 | 0 / 0 | 025B02 |
| 2B | RSHIELD | FF | 08 | 15 | starts sound 15 | 0 / 0 | 025B02 |
| 2C | FSHIELD | FF | 08 | 16 | starts sound 16 | 0 / 0 | 025B02 |
| 2D | SCRAP | FF | 08 | 17 | starts sound 17 | 2 / 8 | 033174 |
| 2E | KSCRAP | FF | 05 | 2D | stops the tracks of sound 17 (command 2D) | 2 / 10 | 033174, 03A1C2 |
| 2F | SHOCK | FF | 08 | 18 | starts sound 18 | 0 / 0 | 03B01C |
| 30 | PVSKID | FF | 08 | 19 | starts sound 19 | 2 / 0 | 0382E0 |
| 31 | PAD | FF | 08 | 1A | starts sound 1A | 3 / 8 | 03A144, 03A210 |
| 32 | COIN | FF | 08 | 1B | starts sound 1B | 0 / 1 | 024522 |
| 33 | LTTR | FF | 08 | 1C | starts sound 1C | 0 / 0 | 03E728, 03EA22, 03EDEE, 040086 and 2 more |
| 34 | LETIC | FF | 08 | 1D | starts sound 1D | 0 / 0 | 03E5AE, 040184, 040300 |
| 35 | DIVE | FF | 08 | 1E | starts sound 1E | 0 / 0 | 0374BE |
| 36 | KDIVE | FF | 05 | 35 | stops the tracks of sound 1E (command 35) | 0 / 0 | 036E86 |
| 37 | EXP3 | FF | 08 | 1F | starts sound 1F | 0 / 0 | none (audio test only) |
| 38 | WELCOME | FF | 13 | 01 | plays OKI phrase 1 | 0 / 1 | 027236, 0275C2 |
| 39 | LUCK | FF | 13 | 02 | plays OKI phrase 2 | 0 / 4 | 024BD2 |
| 3A | CONGRATS | FF | 13 | 03 | plays OKI phrase 3 | 0 / 0 | none (audio test only) |
| 3B | BETTER | FF | 13 | 04 | plays OKI phrase 4 | 0 / 0 | 02512A, 0251BC, 02524E, 0252E0 and 1 more |
| 3C | RAILS | FF | 13 | 05 | plays OKI phrase 5 | 0 / 1 | 041660 |
| 3D | VSLOWS | FF | 13 | 06 | plays OKI phrase 6 | 0 / 0 | 041660 |
| 3E | OWALL | FF | 13 | 07 | plays OKI phrase 7 | 0 / 0 | 041660 |
| 3F | SWAVE | FF | 13 | 08 | plays OKI phrase 8 | 0 / 1 | 041660 |
| 40 | ULTIMATE | FF | 13 | 09 | plays OKI phrase 32 | 0 / 0 | 024A6C, 029BF2 |
| 41 | MARKERC | FF | 13 | 0A | plays OKI phrase 34 | 0 / 0 | 024A6C, 029BF2 |
| 42 | KILLC | FF | 13 | 0B | plays OKI phrase 33 | 0 / 0 | 024A6C, 029BF2 |
| 43 | BOOSTC | FF | 13 | 0C | plays OKI phrase 35 | 0 / 0 | 024A6C, 029BF2 |
| 44 | CLEVEL | FF | 13 | 0D | plays OKI phrase 9 | 0 / 3 | 028E16, 028E22 |
| 45 | ONE | FF | 13 | 0E | plays OKI phrase 10 | 0 / 1 | 029078 |
| 46 | TWO | FF | 13 | 0F | plays OKI phrase 11 | 0 / 1 | 029078 |
| 47 | THREE | FF | 13 | 10 | plays OKI phrase 12 | 0 / 1 | 029078 |
| 48 | FOUR | FF | 13 | 11 | plays OKI phrase 13 | 0 / 0 | 029078 |
| 49 | FIVE | FF | 13 | 12 | plays OKI phrase 14 | 0 / 0 | 029078 |
| 4A | SIX | FF | 13 | 13 | plays OKI phrase 15 | 0 / 0 | 029078 |
| 4B | SEVEN | FF | 13 | 14 | plays OKI phrase 16 | 0 / 0 | 029078 |
| 4C | EIGHT | FF | 13 | 15 | plays OKI phrase 17 | 0 / 0 | 029078 |
| 4D | NINE | FF | 13 | 16 | plays OKI phrase 18 | 0 / 0 | 029078 |
| 4E | TEN | FF | 13 | 17 | plays OKI phrase 19 | 0 / 0 | 029078 |
| 4F | ELEVEN | FF | 13 | 18 | plays OKI phrase 20 | 0 / 0 | 029078 |
| 50 | TWELVE | FF | 13 | 19 | plays OKI phrase 21 | 0 / 0 | 029078 |
| 51 | THIRT | FF | 13 | 1A | plays OKI phrase 22 | 0 / 0 | 029078 |
| 52 | FOURT | FF | 13 | 1B | plays OKI phrase 23 | 0 / 0 | 029078 |
| 53 | FIFT | FF | 13 | 1C | plays OKI phrase 24 | 0 / 0 | 029078 |
| 54 | SIXT | FF | 13 | 1D | plays OKI phrase 25 | 0 / 0 | 029078 |
| 55 | SEVENT | FF | 13 | 1E | plays OKI phrase 26 | 0 / 0 | 029078 |
| 56 | EIGHTT | FF | 13 | 1F | plays OKI phrase 27 | 0 / 0 | 029078 |
| 57 | NINET | FF | 13 | 20 | plays OKI phrase 28 | 0 / 0 | 029078 |
| 58 | TWENTY | FF | 13 | 21 | plays OKI phrase 29 | 0 / 0 | 029078 |
| 59 | TWENTY1 | FF | 13 | 22 | plays OKI phrase 30 | 0 / 0 | 029078 |
| 5A | TWENTY2 | FF | 13 | 23 | plays OKI phrase 31 | 0 / 0 | 029078 |
| 5B | KISS | FF | 13 | 24 | plays OKI phrase 36 | 0 / 0 | 040A04 |
| 5C | YAHOO | FF | 13 | 25 | plays OKI phrase 37 | 0 / 0 | 03A16A, 03A44A |
| 5D | APAD | FF | 13 | 26 | plays OKI phrase 41 | 0 / 0 | none (audio test only) |
| 5E | PRGUN | FF | 13 | 27 | plays OKI phrase 38 | 14 / 0 | 036DFC |
| 5F | BELL | FF | 13 | 28 | plays OKI phrase 51 | 0 / 21 | 03A30C |
| 60 | RMPHIT | FF | 13 | 29 | plays OKI phrase 46 | 2 / 0 | 03A430 |
| 61 | EXP2 | FF | 13 | 2A | plays OKI phrase 40 | 22 / 27 | 02C0B2, 0356F4 |
| 62 | TRKHIT | FF | 13 | 2B | plays OKI phrase 44 | 23 / 31 | 0356F4, 0361F0, 03621A, 03BB42 |
| 63 | SHIELD | FF | 13 | 2C | plays OKI phrase 47 | 0 / 4 | 025D2E, 025FB0, 027DCE, 028F8A and 2 more |
| 64 | ARMS | FF | 13 | 2D | plays OKI phrase 45 | 0 / 0 | 0258DC, 025C9E, 025E0A, 0275A8 |
| 65 | BRAKE | FF | 13 | 2E | plays OKI phrase 48 | 3 / 0 | 034A04 |
| 66 | KBRAKE | FF | 14 | 30 | stops the OKI channel playing phrase 48 | 0 / 0 | none (audio test only) |
| 67 | GUN1 | FF | 13 | 2F | plays OKI phrase 39 | 232 / 325 | 03AFE4 |
| 68 | IRISOP | FF | 13 | 30 | plays OKI phrase 42 | 9 / 8 | 032420 |
| 69 | BIRD | FF | 13 | 31 | plays OKI phrase 50 | 8 / 0 | 037D4C |
| 6A | TYPE | FF | 13 | 32 | plays OKI phrase 49 | 8 / 20 | 02792A, 032B06 |
| 6B | SWPIKUP | FF | 13 | 33 | plays OKI phrase 52 | 0 / 0 | 03A3A2 |
| 6C | STAR | FF | 13 | 34 | plays OKI phrase 43 | 0 / 51 | 02B248, 03A30C |

Over 00-6C: 53 commands of type 13 (OKI phrases), 32 of type 08 (sounds), 6 of type 01, 5 of
type 0A, 2 each of types 00, 05 and 0B, 1 each of types 03, 09 and 14, and the 4 immediate
commands. 13 commands have no call site in the game (00, 03, 04, 05, 06, 07, 08, 09, and 10
WARPMUS, 37 EXP3, 3A CONGRATS, 5D APAD, 66 KBRAKE): the game program can play them only from its
audio test (03 not even there: the game has no way to send it), the boot program 00, 04, 05 and 07 from its sound tests **CODE**. MAME saw the 68010
write 26 different commands in attract mode and 43 in the game run, 50 in the two; the other 46
that have call sites were not reached in 10,800 frames of each **MAME**.

## 7. The two inferences of M4a, settled

### 7.1 SOUNDS IN ATTRACT is bit 11 of FF94EE

Settled by the code, and consistent with M4a's MAME run:

1. The game options menu (`0432A4`) reads option word 0D (`020B4E` with 0D, 0432C4-0432C8),
   edits it with the item table at 020ED0 (`042E4E`) and stores it back as option 0D
   (`020BB4`, 043316-04331A). The second table, 021024, is the same without the item CONTINUE IS
   ONE COIN LESS, and its result is ANDed with EFFF (04330E): that item is bit 12 **CODE**.
2. Each item starts with a byte that the item routine 042CE4 decodes (042CF8-042D2C): the low
   nibble is the shift of the field in the option word, and 2 << (high nibble - low nibble) is the
   number of choices; the choices follow as strings, the first for the value 0. GAME DIFFICULTY
   is FD (bits 13-15, eight choices, and the table has eight), CONTINUE IS ONE COIN LESS CC (bit
   12), SOUNDS IN ATTRACT BB (020F51: bit 11, OFF = 0, ON = 1), AUTO RESET HIGH SCORES AA (bit
   10), HIGH SCORE NAME CENSOR 99 (bit 9), T-SHIRT CONTEST 88 (bit 8), CONTINUE ADVANCES TO NEXT
   LEVEL 76 (bits 6-7, four choices) **CODE**.
3. The main initialisation stores the same option word in `game_options` (FF94EE) through
   `get_game_options` (0433A4: `020B4E` with 0D; 0243B8-0243BE), and attract mode tests 0800 of it
   (028364-028372): set, command 02; clear, command 01 **CODE**.
4. M4a's `sndtrace-sound` run forced the bit with a write tap and attract mode sent 02 and played
   (docs/09 section 6); the factory option word is 0, OFF, and attract mode is silent **MAME**.
   `tools/test_sound_commands.py` checks the item byte, the shift and the 0800 test against the
   image.

The operator menu was not driven headless to flip the option: the code above is the whole path
from the menu item to the bit, so it was not needed.

### 7.2 Command type 10 (`ymtimer.asm`, 585E-5BAB) is unreachable in this set

1. `cmd_type` (6100-616C) holds only 00, 01, 03, 05, 08, 09, 0A, 0B, 13, 14 and FF: no command
   is of type 10 **CODE** (checked by `tools/test_sound_commands.py`).
2. `cmdtype_10_ymtimer` (44C4) is referenced once in the whole file, by its entry in `cmdtype_handlers`
   (474F, the word 44C3); the only reader of that table is `dispatch_command` (437E, 4382), with
   the type from `cmd_type`. No `jsr` or `jmp` reaches 44C4, and no stream op: `op_handlers`
   (50AF, 59 words) has no entry inside 44C4-44CF or 585E-5BAB **CODE**.
3. The only ways into `ymtimer.asm` are `cmdtype_10_ymtimer`'s `jmp ymtimer_start` (44CC), `init_sound`'s `jsr
   ymtimer_reset` (42A9), which clears its state, and `h_irq`'s `jsr ymtimer_irq` (41D1), taken only when
   the YM2151's status has the timer A flag. Timer A is loaded and started only inside
   `ymtimer.asm` (registers 10, 11 and 14 at 5A59-5A7C); no other code loads 10, 11 or 14 as a
   register number **CODE**.
4. MAME: in all five `make sndproto` runs, the soundtest run among them with every command the
   game knows played once, the 6502 never selects a YM2151 register 10-14; M4a's traces never ran
   the timer path either **MAME**.

So `ymtimer.asm` is dead code in rev 6: the 68010 has no command for it and the 6502 has no other
way in. Whether another revision's sound ROM uses it is outside this set (the sound ROM is the
same in all eleven sets, docs/01 section 2).

## 8. MAME evidence (`make sndproto`)

Five runs (`make -j5 sndproto`, about 20 seconds), headless (`SDL_VIDEODRIVER=dummy`, `-video
none -sound none`), each from its own empty NVRAM and cfg under `build/mame/state-sndproto-<run>/`;
the traces stay in `build/mame/sndproto-<run>.txt` (commands, responses, addresses and counts).
`tools/test_sound_commands.py` checks `data/sound/commands.json` against them: per command the
count of writes at 600000, every call site the run saw queue a command among the sites listed for
it, every byte written taken by `h_nmi`, and per run exactly the responses (byte and writing
address) of the table below, FF once per reset.

| Run | Frames | Commands written | Different | Queued | Resets | Responses |
|---|---|---|---|---|---|---|
| attract | 10,800 | 558 | 26 | 560 | 5 | FF x5 |
| game (coin 900, start 960, trigger every 20 frames) | 10,800 | 1,057 | 43 | 1,059 | 9 | FF x9 |
| selftest (SA SELF TEST) | 2,800 | 5 | 4 | 1 | 6 | FF x6, 00 |
| soundtest (PLAY SOUNDS, 108 entries) | 6,400 | 216 | 108 | 1 | 6 | FF x6, 00, 34, 55, 6D, AA |
| inject (07, 06, 03, 09, 08 5A, 07, 6D, 7F, 80, FF, 07) | 1,900 | 165 (12 injected) | 33 | 155 | 3 | FF x3, 00 x4, 55, 5A, 6D, AA |

- In every run the number of command bytes the 6502 read in `h_nmi` (5839) and as `imm_04_loopback`'s data
  byte (57FC) equals the number the 68010 wrote; the other reads of 2802 are the one after each
  reset (4139). No command is lost in MAME.
- Queued but not written (2 in attract, 2 in the game): commands still in `sound_queue` when
  `reset_sound` empties it or the run ends.
- 51 of the 133 call sites queued a command; every (command, site) pair seen is one
  `data/sound/commands.json` lists, including the computed ones (sections 2.1 and 6).
- The menu runs press button 1, button 2 and start at fixed frames (`tools/mame/sndproto.lua`,
  found with snapshots kept in `build/`); the self-test switch is held from the start. The game
  program still starts first: `reset_sound` is called from 02C144 (frame 367) and 0243B2
  (frame 410), and command 1E is queued at 03ADD0 (frame 420), which is the one command the run
  table counts as queued. The 68010 then runs `boot_reset` again (00023C, frame 445) and the boot
  program runs its test menu; start bypasses the power-up self-test and the re-entry resets the
  board at 000FC2 (frame 543) **MAME** (the `reset` and `queue` lines of
  `build/mame/sndproto-selftest.txt` and `-soundtest.txt`). The restart is the game's main loop
  seeing the switch: 0244F0 tests 60C001 bit 5 (the self-test switch, active low, MAME's
  `PORT_SERVICE( 0x20, IP_ACTIVE_LOW )` in harddriv.cpp) and, when it is 0, 0244FA calls
  `soft_reset` past its `stop` (02128A: A7 from $0.w, SR = 2700, VBR = 0, FF8018 cleared,
  `jmp (A0)` through $4.w), which is `boot_reset` (000216); its read at 00023C is the frame-445
  reset, and 000254-00025C sends it to the test menus. The call comes before the flush (024500),
  so the 1E queued at 420 is never written **CODE**.

## 9. Findings

1. **The game ignores the sound board's answers.** Every response goes into a ring nobody reads;
   the supervision code (`sound_watchdog`, 03001E: status request 07 every 240 calls, reset on
   a bad status or a timeout) and the request-reply sender (`send_sound_with_reply`, 023E96) are
   in the ROM with no caller. Only the boot program's tests use a response.
2. **The 68010's names for all its sound commands are in the ROM** (`audio_test_list`, 05C63C),
   and MAME plays each through the audio test, which is reachable headless from the boot
   program's test menu.
3. **The handshake is A80000 bit 15**, which MAME does not emulate; MAME's scheduler is why no
   command is lost there. The real board's behaviour when the 68010 sends faster than the 6502
   takes the bytes depends on that signal (section 4).
4. **Latency of three flushes**: `flush_sound_queue` sends a command at the third flush after it
   was queued, one flush per main loop pass (section 2.1).
5. **Thirteen commands the game never sends**: besides the test and immediate commands, the
   sounds WARPMUS (10) and EXP3 (37), the OKI phrases CONGRATS (3A) and APAD (5D), and KBRAKE
   (66), which would stop BRAKE (section 6).
6. **The end-of-demo command 01** comes from the main loop's state switch (024E3E, 0253A0: 01, 0B, 21).
7. docs/01 section 6's /RDIO row was wrong (bits 4-2 "+5V"): MAME's `jsa_ii_ioports` has bits 4-3
   unused and bit 2 coin 3, and bit 7 always reads 0 for stunrun; corrected there.

## 10. Not verified, open

- What drives A80000 bit 15 on the real main board, and whether the game ever waits on it.
- The range of the level word FF9578 at 029078 (the number announcements 45-5A are listed for
  levels 1-22).
- The game events behind most call sites: this leg names the sound path, not the game logic (M5).
  The routine around each site is in `data/sound/commands.json`.
- Real-hardware timing of the reset handshake (MAME answers FF within a frame).

## 11. Settled by the other M4 legs, and the entry points for M5

Two questions of section 10 as M4e wrote it are answered by the sequencer leg (docs/12):

- **Stream op 96's responses**: no stream sent one in the runs, and none can: no stream of the
  data uses op 96 (`respond`, docs/12 section 4, the walk of every reached and unreached stream).
- **What the streams do with `seq_vars`** (type 01, the SAME/ACL/DCL/SENG/FACL/FDCL commands): they
  set global 0 to 0-5, and the four streams of sound 0F (ENG, 1D) branch on it (`var_load
  R_GLOBAL+0`, `var_and 7`, `jump_table`, docs/12 section 3.7); `snd_0F_0` clears it when the
  sound starts (`var_and 0`, `var_store R_GLOBAL+0`), and no other stream uses global 0
  (`asm/jsa/data/streams_1.asm`). So the six commands choose the branch sound 0F's streams take
  while it plays; which game states send which is M5's.

What M5 (the 68k source) starts from on the sound path:

- **The names.** The 68010's sound routines and RAM are named in `ida/code_map.py` (section 2;
  `h_level4_sound`, a vector target, in `ida/memory_map.py`:
  `queue_sound_command` 0301CA, `flush_sound_queue` 03013C, `send_sound_byte` 023EDA,
  `send_sound_byte_once` 023EDE, `send_sound_with_reply` 023E96, `h_level4_sound` 023F24,
  `get_sound_response` 023F72, `reset_sound` 0300F8, `reset_sound_board` 023FA2,
  `sound_watchdog` 03001E, `audio_test` 043718, `audio_test_list` 05C63C, `game_options` FF94EE,
  `sound_queue` FFDB64 and its counters) and carried by the 68k snapshot `data/ida/stunrun-68k.json`.
- **The command values.** `data/sound/commands.json` is the name of every value 00-6C (`snd_` and
  the audio test's name, `cmd_03_imm` for 03), so that the 68k source can write `#snd_tubmus`,
  not `#$0A` (equates generated from the file), and the 133 call sites with the routine around
  each (and `site_notes` for the 17 computed or alternative values) say where they go.
  `tools/test_sound_commands.py` checks the file against the 6502's tables and the 68k image.
- **The 6502 side** is source (`asm/jsa`, docs/09, docs/12); its IDA database follows it through
  `make ida-sync` (docs/05 section 6). A 6502 name M5 cites is a label of that tree.
- **Questions for M5** (from the code, not answered by the sound legs): the game events behind
  the call sites (section 10); the range of the level word FF9578 at 029078; whether the 36 OKI
  phrases that only the injected commands started (docs/10 section 9) and the 46 commands with
  call sites that no 10,800-frame run reached (section 6) are reachable in play; why the queue
  sends at the third flush (section 2.1); what drives A80000 bit 15 (section 4).
- **Questions for M7** (the hardware, not the code): the real board's pin 7 polarity (docs/10
  section 2), whether the JSA II coin inputs are wired on a STUN Runner cabinet (docs/09
  section 1), the reset handshake's timing, and what the samples and sounds are (the listening
  pass, Jesus's: `make listen`, `make oki-pcm`).
