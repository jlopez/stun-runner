# The packed GSP images (pairs U, V, W)

**Date**: 2026-11-16 (milestone 5, wave 1, leg M5i, issue #34). The 393,216 bytes of pairs U, V and W
(060000-0BFFFF) are 54 packed image streams, three checksum-adjust words, zero, and the image
pointer table. This leg decodes them into 140 committed indexed PNGs (`data/gsp-images`) whose
colours come from 32 committed palettes (`data/palettes`), and builds the region back from that
data alone, byte for byte: `asm/68k/images.asm` and `image_table.asm` have no blob left.

Precedents: the object meshes (docs/07, `tools/objects`) and the samples (docs/10 section 6,
`tools/adpcm`): an editable committed form, an encoder that gives the original bytes back, a CI
test of the chip hashes without the ROMs.

## 1. Summary

| | |
|---|---|
| Source | `data/gsp-images/manifest.json` and 140 PNGs (263 KB), `data/palettes/*.json` (32 files) |
| Tool | `tools/gspimages` (package: `__init__.py` format and build, `stream.py` codec, `png.py`, `trace.py`, `__main__.py` CLI) |
| Build | `tools/gspimages asm` on every `make` writes `build/gsp-images/images.asm` and `table.asm`, which the two region files include |
| Checks | `make check` (25 files, 0 differences; since M5d the palettes are bytes of the tree, docs/17 section 2), `make coverage` (both region files 0 blob), `tools/test_gspimages.py` (CI), `make imgtrace` (MAME) |
| Coverage | the 68k blob falls by 332,291 bytes, from 691,513 to 359,222; the set's blob share from 45.8% to 23.8% |
| Re-decode | `make images` (as `make objects` and `make samples`) |

## 2. The consumer and the stream format

`unpack_gsp_image` (0225E4-02274A, `jsr` with the stream address on the stack) streams a packed
image into the GSP through the host port: the caller sets HSTADR (C00002) and the routine writes
16-bit words to HSTDATA (C0000C, A2 = C0000C at 0225EC), clearing the watchdog (608000) per command
(022608). Its resumable twin 022766-022954 (`sub_22766`) runs the same command loop D6 commands per
call, its state in RAM: FF9BCC the entry to start (read at 022788 and indexed into the image table
at 022798), FF9BCE the current entry, FF9BD0 the stream pointer, FF9BD4 the GSP address,
FF9C64/FF9C66 the odd-byte state (0227D0-0227F2). Both build their table with `sub_225B0`
(0225B0-0225CC): 16 bytes, each stored as the high byte of a word at FF900A+2k and as the word
00vv at FF902A+2k, so a nibble pair is one word read and one byte read (022690, 02268C).

The command loop (0225E4 version; the twin is the same code at 0227DC-022950):

| Byte c (n = c & 3F) | Meaning | Code |
|---|---|---|
| first byte | must be 00, else `soft_reset` (021286 through 0225CE); it is the new-table command (the twin reads it as one, 02280E) | 022600-022604 |
| 00 | a new 16-byte table follows | 02261A-02261C, 022604 |
| 01-3F | n literal bytes | 02261E-022670 |
| 40 | end: a pending odd byte is written with a zero low byte, the routine returns the address after the stream | 022672-022674, 0225D4-0225E2 |
| 41-7F | n bytes, each two 4-bit codes (high nibble first), each code a table value | 022678-0226C6 |
| 80, C0 | `soft_reset` | 0226D4, 022704 |
| 81-BF | the next byte, n times | 0226D8-0226FE |
| C1-FF | the next byte's two codes as a pair of table values, n times | 022708-022746 |

The routine keeps a byte pending (D2 = FFFF, the byte in D3's high half) whenever a command ends
on an odd count (022650, 02266A, 0226EA, 022726), so commands are not aligned to words: the
decoded stream is a plain byte sequence, and every pair of it is one HSTDATA word, its first
byte the high byte. `tools/gspimages/stream.py` `unpack` is this loop; `make imgtrace` (section 8)
checks it against every word MAME saw the two routines write.

## 3. The encoder

`stream.pack` gives all 54 streams of the ROM back byte for byte from their decoded bytes (the
rules are the original packer's choices, measured, not the format's; the scout's prototype found
them, this leg re-implemented them from the description and checks them on every stream):

- the table is the 16 most frequent byte values of the decoded stream, by count descending then
  value ascending, padded with 00; a value's code is its highest index (only 00 can occur twice);
- where this byte and the next are both in the table and one more byte follows them: a pair run
  (C1-FF) when the pair repeats at least 3 times, or 2 times right after a full nibble block (62
  bytes) or when those 4 bytes end the data; otherwise a nibble block (41-7F) of at most 62 bytes
  that stops where a pair run would start;
- elsewhere a value outside the table repeated at least twice is a byte run (81-BF, at most 63);
  otherwise a literal block (01-3F, at most 63) that stops where a nibble pair or a byte run would
  start; then the end command.

Every stream of the ROM loads exactly one table (the leading one); command 00 inside a stream
never occurs, and the encoder never emits it. An edited image encodes by the same rules to other
bytes (the streams after it move; section 5 shows what follows them).

## 4. Images

### 4.1 Raw screens and headed images

A decoded stream is a block of GSP memory, one of two kinds (the manifest states which):

- **raw**: one screen of whole 512-pixel rows (the GSP frame buffer's pitch; the rows follow
  from the length: 32, 208 or 240). Entries 1, 2, 3, 24-28. For entries 2, 3 and 24-28 the
  per-entry table 047F50 holds the row count (a value below 400h, tested at 02DAF0 and 02DBCA);
  for entry 1 it is 0.
- **headed**: images back to back, each a 12-byte header, its pixels and zero bytes to the next
  32-bit boundary. The header is four words and a long: height, width, the size in bits as a GSP
  long (low word first) = 16 x ceil(width x height / 2), and a long that is 0 in all 149 headed
  images. The decoder fails on any other size, a nonzero reserved long or nonzero padding.

Pixels are bytes (8-bit indices). In each word the low byte is the pixel at the lower address,
which the GSP's little-endian bit addressing puts at the lower x: the decoded bytes are the
pixels with each pair swapped. A PNG holds the pixels in row-major order, `width` per row.

### 4.2 The PNGs and the manifest

One indexed 8-bit PNG per distinct image (C15): 157 images in the 54 streams (165 counted per
table entry, since 7 streams serve two entries), 140 distinct by content (149 headed images minus
17 repeats among the figure streams 65, 66 and 68, plus the 8 raw screens); the repeats are one
PNG each, named in every stream that holds them. Entries that share a stream (4/5, 6/7, 8/9,
10/11, 12/13, 14/15, 18/19) are one stream with several entries. The 7 placeholder entries 58-64
point at 060000, the pair-U adjust word (section 5), not at a stream.

`data/gsp-images/manifest.json` (format `stunrun-gsp-images 1`) holds the streams in entry order
(their entries, kind and image names), the placeholders, the adjust words' places, the six
expected chip sums with their evidence, and per image its width, height and palette spec. It
stores no derived field: no header size or reserved long, no padding, no stream address or
order (streams are laid out by first entry), no table, no command, no adjust word.

The build (`tools/gspimages asm`) takes only the pixel indices from a PNG, never its colours, and
accepts any non-interlaced indexed PNG (bit depth 1-8, any filter, any PLTE length) as an editor
may save it; `make images` writes them canonically (8-bit, filter 0, 256-entry PLTE).

## 5. The layout of 060000-0C0000

| Range | What |
|---|---|
| 060000-060001 | `gsp_images_sum_u`, the pair-U adjust word (also `dat_60000`) |
| 060002-09848D | the streams of entries 1-34 (27 streams) |
| 09848E-09848F | `gsp_images_sum_v` |
| 098490-0A5B65 | the streams of entries 35-57, the level maps |
| 0A5B66-0A5B67 | `gsp_images_sum_w` |
| 0A5B68-0B10EA | the streams of entries 65-68 |
| 0B10EB-0BFDFF | zero (`images.asm`'s fill) |
| 0BFE00-0BFF17 | `tbl_BFE00`, the 70 longs: `dc.l` of the stream labels, 0 for entries 0 and 69, `gsp_images_sum_u` for 58-64 |
| 0BFF18-0BFFFF | zero (`image_table.asm`'s fill) |

Every byte of 060000-0B10EB is a stream byte but the three adjust words; the decoder fails on any
other gap. Stream labels are `gsp_image_NN` (NN its first entry), each with an assert at its
address; the includes assert the pair boundaries 080000 and 0A0000 inside streams 22 and 48.

**The adjust words (C14).** Each pair's two chips sum to the value the boot self-test expects: the
table at 005FF6 has 8 records of 18 bytes, record n for pair R+n (its +6 long is the pair's
address, read at 0060C8); `0060AC-00616E` sums each pair's 64K words twice, the first time
comparing the low byte of the word sum (the odd chip, 210x) with the record's byte +2 (`cmp.b` at
0060F4), the second time, clearing the low byte at every step, the high bytes' sum (the even chip,
200x) with byte +3 (`cmp.b` at 00615A); a difference sets an error bit from +4/+5 (0060FC,
006162). The expected sums are the last two digits of each part number read as hex: 200u 08,
210u 07, 200v 10, 210v 09, 200w 12, 210w 11 (the scout's HYP, now settled by the code). The
manifest commits these six sums as named values with that evidence; the tool computes each
adjust word's two bytes last, from the sums of every other byte of the pair (pair W includes the
table and the fills), and fails if a layout change would move an adjust word out of its pair.
The words sit before entries 1, 35 and 65 (the manifest's `before_entry`): the boundaries of
three groups of streams (screens and sprites, maps, figures); that the original build placed
them there is HYP (one word per file of three). No raw adjust word is committed.

**Entry 69 is not only a terminator (finding).** `sub_2DB54` (02DB54) unpacks table entry 69
(`move.l $bff14.l,-(a7)` at 02DB62) to FFE00000 and sets FF9BAE from 047F50's entry 69 (a raw
screen's 240 rows) and FF9BCE to 45h; 048068's entry 69 is a 16-colour palette (045B60). With the
pointer 0 the unpacker would read the boot vector table. 02DB54's only caller, 0270A4, never ran
in `make pccov` or `make imgtrace`. HYP: a screen that was removed from the ROM.

**Past the last level (finding).** In the level-23 run of `make imgtrace` the level word reaches
24: 029C28 reads the map entry of record 24 of table 048180, one record past its 24, and loads
entry 67 (`strip_67`) as a map at FFED0000 (frame 2453); then 029942-02996A take an entry from
table 04CB36 that is 0 and unpack table entry 0 (frame 2529), reading the stream at 000000; the
watchdog resets the machine at frame 2709. This is the reset docs/07 section 11.4 reports from
start level 23 up; it follows from the level-select poke, not from the images.

## 6. Image sizes in the 68k code (C17)

The 68010 code places images by constant GSP addresses that depend on the sizes of the images before
them: the maps at FFE00000, FFE5CFE0 and FFEB9FC0 (024EEA-024F98) and FFED0000 (024AB4, 029C4A,
02AF94), the HUD images at FFF23F00, FFF2B760, FFF3FD80, FFF3FB20 (02D770-02D7A6), screens at
FFE00000 and FFDE0000 (02D7C6), the figures of entries 65 and 66 at FFE30060 (0407AC, 040812).
FFED0000 is FFE00000 plus `map_screen`'s 512x208 bytes (D0000h bits), so it moves with entry 25's
size; 02AF7E-02AFAE is the third loader that uses it (entry 25 at FFE00000 through the table long at
0BFE64, then at 02AF94 the map entry of the level's 048180 record, `addi.l` of 0BFE00 at 02AFA4).
The drawing code takes the same addresses as constants: FFED0000 at 027836, 02A380 and 02AB0C and
FFF3FB20 at 026DDC, each passed to 02F7D6, which writes it as the last long of a command 8000 to the
GSP (C0000C); FFF23F00 at 02C310 and FFF2B760 at 02C332, passed to 02F742 (the second stepped by D3
at 02C34C). The GSP program reads the headers it is given. Until that code is symbolic source, a
size change must not build: the manifest records each image's width and height, and `tools/gspimages
asm` fails, naming the PNG and both sizes, when they differ. Pixel edits are free (the streams
re-encode and move; the table follows their labels).

## 7. Palettes (card A13, C13)

The colours are not in the streams. The code pairs them with images in three ways:

- **table 048068** (70 longs, per entry): a 16-colour overlay loaded at F0, 16 colours
  (`sub_2DA6E`, 02DAD4-02DAE4, sent later as GSP command 9: FFDB40 address, FFDB44 index F0,
  FFDB46 count 10h), or used by the fades with a larger count: 32 colours at E0 for the maps
  (024AF4-024B3A, n = 20h) and 48 at D0 for entries 26 and 27 (0286E6, 02A8CE, 0287D0: n = 30h);
- **the fades** `sub_296AA` and `sub_297A6` (args: a 256-colour base, an overlay, n, the step
  count): the palette they fade (FF9584 the current colours, FF9884 the steps) is the base's first
  256-n colours followed by n overlay colours, or the base's 256 when the overlay is 0
  (0296DE-02974C, 0297DA-029848; 0296AA starts from those colours, 0297A6 from black, 0297E8); the bases are the title palette 0461F0 and the six level bases of table 047406
  (24 longs indexed by the level word FF9578, 0249F4 and 024B30);
- the map palette 0466A0 at E0, 32 colours (024FA8-024FBA) with base 047406's first (024F9E).

`data/palettes` holds the 32 palettes the images need, one JSON file each (name, 68k address,
count, comment with the evidence, the R, G, B values): `title` (0461F0, 256), `level_base_00`-`05`
(by the first level using each base of 047406, 256 each), and `overlay_NN` (by the first entry
of 048068 that points at it; 16, 32 or 48 colours). The cycling tables (047C9A-047D0C) and the
pointer tables 047406, 047F50, 048068, 048180 stay with the data leg and are only referenced here.

Each image's manifest `palette` spec says how its PNG's PLTE is composed (`tools/gspimages`
`compose`), with `kind` and `evidence`:

- `full` where the code pairs a base with the screen statically: `title` (0245D0 loads entry 2,
  0245F8 fades to 0461F0 alone), `fbi_seal` (026F88: entry 3, `level_base_00` + `overlay_03` at F0),
  `horizon_16_*` (02849E: `level_base_01` + `overlay_16`), `frame_26` (0286CC: `level_base_00` +
  `overlay_26` at D0, 48), `frame_27` (028830 loads entry 27 after 0287BC-0287FE fade to
  `level_base_00` + 048068 entry 27, which is `overlay_26`, at D0, 48), `story_text` (0288C0:
  `level_base_00` + `overlay_31`), and the 23 level maps (024A9E-024B3A: the base of the level whose
  record selects the map + its 048068 overlay at E0, 32);
- `overlay` (the 048068 colours, grey elsewhere) for the other entries 048068 gives a palette;
  entries that share a stream list their own overlay under `aliases`;
- `grey` (a 0-255 ramp) where 048068 is 0 (entries 1, 24, 30, 32, 33, 34).

`tools/test_gspimages.py` fails when a PNG's PLTE differs from its spec. **The palettes are bytes
of the 68k tree since M5d** (docs/17 section 2): `tools/gspimages asm` writes one include per
palette, `build/gsp-images/palettes/<name>.asm` (`dc.b` per colour, an assert at both ends), and
`game/island.asm` includes each at its address under `pal_<name>`, so `make check` compares them
with the reference set as it compares every byte. (In M5i, `palettes.asm` held them as one block
and `tools/gspimages palcheck` compared each with the image, a prerequisite of `make check`; M5d
removed both.) A planted change (one red component of `title` colour 6) now fails `make check` at
`68k $046202`. All 32 lie in 044630-0469FF (`level_base_00` to `overlay_31`), that is in
`game/island.asm` (04397E-046AEE), none in `data.asm` (C13 named both).

## 8. MAME: `make imgtrace`

`tools/mame/gspimages.lua` (headless, each run from its own empty NVRAM and cfg): a write tap on
the host port records every HSTDATA word written from 0225E4-022954 with its HSTADR, a read tap on
060000-0B10EB the stream bytes those PCs read, a read tap on the table every entry read; one frame
later it reads the written words back from GSP memory; every 50 frames (20 in the level runs) it
saves MAME's palette. Runs: attract (10,800 frames), a game (7,200), and a game per start level
1-23 (3,000 each, objlevels.lua's level select, card A4). `tools/gspimages trace` rebuilds each
unpacking from the calls (a call starting at a stream's first byte opens it, the twin's later
calls continue it), checks that its words are the decoder's (all of them when the stream's end
was read) and that its destination advances 16 bits per word, and writes
`artifacts/gspimages-summary.json` (entries, runs, destinations, counts; per palette spec the
best match; no bytes).

Result (2026-11-16): no problem; 48 of the 54 streams unpacked, every unpacking complete and equal
to the decoder's words; the read-back equals the written words for all but 10 of the 2,080 words of
the dot images (entry 33). Not reached: entries 3 (`fbi_seal`), 26 and 28 (`frame_26`, `frame_28`)
and 65, 66, 68 (the figures). All 23 level maps were reached, each at FFED0000 in the run of its
level (and 35, 39, 46 also at FFE00000, FFE5CFE0, FFEB9FC0 on the screen shown after Start,
024EEA-024F98, the three levels named by the bytes at 0473CA-0473CC: only in the game runs, frames
965-975 after the start press at 960, never in the attract run).

Palettes (best dump of all runs): `title` 256 of 256 (attract, frame 450); every other `full` spec
reached (story text, `horizon_16`, `frame_27`, on screen at attract frame 4050 after its unpacking
at 3969, the maps of every level base) 255 of 256, the one difference always colour 1D, which the
game cycles (tables at 047C9A, read at 02C4C8 and 02C658); every `overlay` spec matched all its
colours at some dump, the aliases' included, but `overlay_65` (1 of 16: the figures were not
reached); `fbi_seal`'s spec (`level_base_00` + `overlay_03`) was never on screen: its best is 240 of
256 (the base alone).

## 9. The images and their names

Names are provisional (C15): evidence-based where a MAME picture or the code shows the role
(`title`: the picture and the palette pairing; `story_text`: the picture, "Sometime in the future:
S.T.U.N. Running, the Ultimate Challenge ..."; `map_screen`: 024A9E, 029C34 and 02AF7E load it with
the level map at FFED0000 (section 6), whose frame and legend it draws; `level_map_NN`: the level
whose record of table 048180 selects it, the first if two do, 21 and 23 both select entry 54),
otherwise descriptive of the picture: `fbi_seal` (the FBI anti-piracy seal), `horizon_*` (512-wide
panoramas), `frame_*` (screen borders), `pilot_*`, `emblem_*`, `figure_*`, `tree`, `tuft_*`,
`dot_*`, `strip_67`, `screen_01`, `screen_24`. Jesus may rename any of them (the manifest and the
PNG file names; the build ignores names). To look at in real colours: `title.png`, `story_text.png`,
`level_map_00.png`, `map_screen.png`, `horizon_16_00.png`, `fbi_seal.png`.

| Entries | Stream | Packed | Kind | Images | Palette | MAME (`make imgtrace`) |
|---|---|---|---|---|---|---|
| 1 | 060002 | 4,493 | raw | `screen_01` 512x32 | grey | 25 unpackings, FFDE0000 |
| 2 | 06118F | 22,580 | raw | `title` 512x240 | full | 52 unpackings, FFE00000 |
| 3 | 0669C3 | 9,481 | raw | `fbi_seal` 512x240 | full | not reached |
| 4-5 | 068ECC | 7,193 | headed | `horizon_04` 512x96 | overlay | 8 unpackings, FFE00000 |
| 6-7 | 06AAE5 | 4,211 | headed | `horizon_06` 512x96 | overlay | 3 unpackings, FFE00000 |
| 8-9 | 06BB58 | 9,414 | headed | `horizon_08` 512x96 | overlay | 4 unpackings, FFE00000 |
| 10-11 | 06E01E | 9,169 | headed | `horizon_10` 512x96 | overlay | 3 unpackings, FFE00000 |
| 12-13 | 0703EF | 12,527 | headed | `horizon_12` 512x96 | overlay | 7 unpackings, FFE00000 |
| 14-15 | 0734DE | 8,055 | headed | `horizon_14` 512x96 | overlay | 3 unpackings, FFE00000 |
| 16 | 075455 | 13,435 | headed | `horizon_16_00`, `_01` 512x48 | full | 31 unpackings, FFE00000 |
| 17 | 0788D0 | 11,719 | headed | `horizon_17_00`, `_01` 512x48 | overlay | 4 unpackings, FFE00000 |
| 18-19 | 07B697 | 5,690 | headed | `horizon_18_00`, `_01` 512x48 | overlay | 6 unpackings, FFE00000 |
| 20 | 07CCD1 | 3,327 | headed | `horizon_20_00`, `_01` 512x48 | overlay | 4 unpackings, FFE00000 |
| 21 | 07D9D0 | 7,270 | headed | `horizon_21` 512x48 | overlay | 3 unpackings, FFE00000 |
| 22 | 07F636 | 7,355 | headed | `horizon_22` 512x64 | overlay | 2 unpackings, FFE00000 |
| 23 | 0812F1 | 22,549 | headed | `horizon_23_00`-`_02` 512x96 | overlay | 3 unpackings, FFE00000 |
| 24 | 086B06 | 2,577 | raw | `screen_24` 512x208 | grey | 1 unpacking, FFE00000 |
| 25 | 087517 | 31,162 | raw | `map_screen` 512x208 | overlay | 27 unpackings, FFE00000 |
| 26 | 08EED1 | 3,662 | raw | `frame_26` 512x240 | full | not reached |
| 27 | 08FD1F | 2,721 | raw | `frame_27` 512x240 | full | 2 unpackings, FFE00000 |
| 28 | 0907C0 | 2,991 | raw | `frame_28` 512x240 | overlay | not reached |
| 29 | 09136F | 14,746 | headed | 24: `pilot_29_00`-`_19`, `emblem_29_20`-`_23`, 72x72 | overlay | 1 unpacking, FFE00000 |
| 30 | 094D09 | 1,238 | headed | `tree` 48x80 | grey | 52 unpackings, FFF23F00 |
| 31 | 0951DF | 11,628 | headed | `story_text` 360x168 | full | 2 unpackings, FFE00000 |
| 32 | 097F4B | 1,233 | headed | 10: `tuft_32_00`-`_09` 32x32 | grey | 52 unpackings, FFF2B760 |
| 33 | 09841C | 59 | headed | `dot_33_00`, `_01` 5x5 | grey | 52 unpackings, FFF3FD80 |
| 34 | 098457 | 55 | headed | `dot_34` 8x8 | grey | 52 unpackings, FFF3FB20 |
| 35-57 | 098490-0A51B1 | 1,471-3,499 each | headed | `level_map_NN` 340x140 (one per stream) | full | each reached, FFED0000 |
| 65 | 0A5B68 | 17,087 | headed | 25: `figure_65_00`-`_24` 72x72 | overlay | not reached (loader 0407A8) |
| 66 | 0A9E27 | 13,159 | headed | 21 72x72, 12 shared with 65 | overlay | not reached (loader 04080E) |
| 67 | 0AD18E | 3,314 | headed | `strip_67` 512x48 | overlay | 1 unpacking (past the last level, section 5); loaders 0407A8, 04080E not reached |
| 68 | 0ADE80 | 12,907 | headed | 21 72x72, 5 shared with 65 and 66 | overlay | not reached |

The maps by entry: 35 `level_map_00`, 36 `_01`, 37 `_14`, 38 `_15`, 39 `_05`, 40 `_12`, 41 `_07`,
42 `_11`, 43 `_08`, 44 `_02`, 45 `_16`, 46 `_10`, 47 `_13`, 48 `_17`, 49 `_18`, 50 `_03`, 51
`_19`, 52 `_06`, 53 `_20`, 54 `_21` (and level 23), 55 `_22`, 56 `_09`, 57 `_04`.

Entries 65-67: 0407A8 (`jsr` at 0273C6) and 04080E (`jsr` at 02725C) unpack entry 65 or 66
at FFE30060 (HSTADR at 0407AC, 040812; the table read at 0407B6, 04081C; `unpack_gsp_image`
0225E4) and then load entry 67 at FFE00000 (`pea $43.w` and `jsr 02DBB4` at 040800/040804,
040866/04086A): `strip_67` is the figure animations' companion screen, with the same 048068
overlay (045EF0, entries 65-68). Neither loader ran in any `make imgtrace` run; entry 67's one
unpacking there is the past-the-last-level read of section 5.

## 10. Names proposed for the naming legs (C16)

This leg changes neither `ida/code_map.py` nor the snapshot. Proposed, with the evidence above:

| Address | Proposed name | Evidence |
|---|---|---|
| 0225B0 | `load_unpack_table` | builds the 16-entry tables at FF900A/FF902A (section 2) |
| 022766 | `unpack_gsp_image_step` | the resumable twin, D6 commands per call, state FF9BCC-FF9BD4, FF9C64-FF9C66 |
| 02DA6E | `start_gsp_image` | queues an entry for the twin (FF9BCC), its 048068 overlay at F0 |
| 02DBB4 | `load_gsp_screen` | unpacks an entry to FFE00000, its 047F50 value to FF9BAE/FF9BD8 |
| 02DB84 | `load_title_screen` | entry 2 to FFE00000 |
| 02DB24 | `load_screen_3` | entry 3 (`fbi_seal`) |
| 02DB54 | `load_screen_69` | entry 69, whose pointer is 0 (section 5) |
| 02D762 | `load_hud_images` | entries 30, 32, 33, 34 to FFF23F00, FFF2B760, FFF3FD80, FFF3FB20 |
| 02D7C2 | `load_boot_screens` | entry 1 to FFDE0000, `load_hud_images`, entry 2 |
| 0296AA, 0297A6 | `palette_fade_out` (HYP), `palette_fade_in` (HYP) | the fades of section 7: 0296AA sets the current colours (FF9584) to the palette, 0297A6 clears them (0297E8); both set FF9884 to the palette / steps |
| 0BFE00 | `gsp_image_table` | the 70 image pointers (now `tbl_BFE00`) |
| 047406 | `level_base_palettes` | 24 pointers to 256-colour bases, by level |
| 047F50 | `gsp_image_layouts` | per entry: a raw screen's rows or a layout record |
| 048068 | `gsp_image_overlays` | per entry: an overlay palette |
| 048180 | `level_records` | 24 records of 40 bytes, byte 0 the map entry |
| 0461F0 | `title_palette` | the title's 256 colours |
| 005FF6 | `boot_rom_checksums` | the self-test's 8 records of 18 bytes |

## 11. Tests

`tools/test_gspimages.py`. In CI, without ROMs: the committed data builds the six chips with the
CRC-32 and SHA-1 MAME lists, in Python and through vasm (the two region files assembled with the
generated includes); every committed stream decodes to its images; the stream codec on a stream
with every command and the odd-byte carry, the commands the unpacker refuses (a first byte other
than 00, 80, C0, a stream that runs past the data), the table rule, the encoder's choices (pair
run, the end-of-data pair run, nibble blocks of at most 62, byte runs of at most 63) and a random
round trip; the headed image layout (a 5x5 image's size field, padding, the pair swap); the PNG
reader on filters 1-4 and a 4-bit file; a one-pixel edit (a value outside the stream's table)
re-encodes and decodes to the edit with the chip sums still right; a size change fails with the
message of section 6; a broken manifest fails; every PNG's PLTE is its spec; every palette is
used; the PNGs are the only images under `data/`; each palette include assembles to its colours
and fails one byte away from its address (M5d; `palcheck`'s test before); this document's stream and image counts (sections 4.2 and 5) are the
manifest's, and every `full` spec that no MAME dump matched but for colour 1D is named, with its
best count, here (section 8) and in `CLAUDE.md`'s `make imgtrace` bullet. With the reference set:
the committed data is what the image decodes to and builds back to it; every palette equals the
image; with `unidasm` too, every instruction of 000000-05FFFF that loads one of section 6's
size-dependent constants (FFE5CFE0, FFEB9FC0, FFED0000, FFF23F00, FFF2B760, FFF3FD80, FFF3FB20,
FFE30060) is cited in section 6. With `make imgtrace`'s runs: the trace check passes.
`tools/test_68k_tree.py` and `tools/test_build.py` generate the includes and expect pairs U-W from
the data.

## 12. Open points

- Six streams were not reached in MAME (section 8); their decoding rests on the decoder alone.
- The palette specs of `overlay` images leave the colours outside the overlay grey: their real
  values depend on the level or the previous screen. The figure streams 65, 66, 68 use colours
  21-3F that their 048068 overlay (F0-FF) does not cover.
- `frame_28`'s and the `figure_*` and `strip_67` streams' palettes rest on table 048068 alone; no
  code pairing them with a base was found. The figure screen's loaders (0407A8, 04080E, section 9)
  were found but never ran in MAME.
- (Answered by issue #37: the data leg, M5d, embedded them, one include per palette written by
  `tools/gspimages`; docs/17 section 2.)
- The adjust words' places (before entries 1, 35, 65) are kept as the ROM has them; why there is
  HYP (section 5).
