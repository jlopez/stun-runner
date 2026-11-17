# The 68k data as source

**Date**: 2026-11-17 (milestone 5, wave 2, leg M5d, issue #37). What of the 68k image's data is
source after this leg, on what evidence, what stays blob and why, and the moved-build experiment:
how far the tree is from relocatable. **CODE** means read off the instructions at the addresses
given (the tree's own listing, `build/stunrun-68k.lst`), **MAME** a run named with its command,
**HYP** a hypothesis. No byte of the ROM is quoted here: addresses, counts and names only.

## 1. Summary

| Step | What | Bytes out of blob | Files |
|---|---|---:|---|
| Palettes (section 2) | the 32 palettes of `data/palettes` included in `game/island.asm` at their addresses under `pal_<name>` | 6,768 | `tools/gspimages`, `game/island.asm` |
| Image table labels (3.1) | `gsp_image_entry_NN` per entry, the 15 `tbl_BFE00+$N` operands rewritten | 0 | `tools/gspimages`, five code files |
| Sound equates (3.2) | `build/68k/sound_commands.asm` from `data/sound/commands.json` | 0 | `tools/m68k sound-equates`, `stunrun.asm` |
| `audio_test_list` (3.3) | 108 records as `dc.w snd_*`, name, zeros; FFFF | 2,378 | `data.asm` |
| Text (4.1) | every text range of the classification in `data.asm` as `dc.b` strings | 7,825 | `data.asm` |
| Pads (4.1) | 146 zero bytes after a string, to an even address, as `dcb.b 1,0` | 146 | `data.asm` |
| Pointer tables (4.2) | 12 tables (655 longs) of `data.asm` as `dc.l` of labels, each reader cited in `data/68k/tables.json` | 2,620 | `data.asm`, `data/68k/tables.json` |
| Moved build (section 5) | the experiment, `make movedcheck`; the three record pointers at 021650 it found | 12 | `tools/m68k/moved.py`, `tools/mame/movedcheck.lua`, `game/code_020430.asm` |

`make check`: 25 files, 0 differences at every commit. The 68k blob falls from 185,094 to 165,345
bytes (19,749 = 6,768 + 2,378 + 7,825 + 146 + 2,620 + 12, every byte accounted for in the
table above), the set's blob share from 12.2% to 10.9%:

| Source file | Bytes | instr | data | blob | fill | blob before |
|---|---:|---:|---:|---:|---:|---:|
| `asm/68k/game/code_020430.asm` | 16,086 | 6,772 | 658 | 8,617 | 39 | 8,629 |
| `asm/68k/game/island.asm` (with its 32 palette includes) | 12,656 | 262 | 6,829 | 5,565 | 0 | 12,333 |
| `asm/68k/data.asm` | 103,698 | 0 | 11,323 | 78,319 | 14,056 | 91,288 |
| other 68k files | | | | 72,844 | | 72,844 |
| **stunrun-68k** | **786,432** | **163,638** | **360,278** | **165,345** | **97,171** | **185,094** |

(`make coverage` lists each palette include as its own row, `build/gsp-images/palettes/<name>.asm`,
768, 144 or 48 bytes of data; the island's row above adds them. `data.asm`'s 1,646 bytes of new
fill are the 146 pads and the 1,500 zero bytes that end the names of `audio_test_list`.)

## 2. The palettes (follow-up of C13)

`tools/gspimages asm` writes, besides the image includes, `build/gsp-images/palettes/<name>.asm`
for every palette of `data/palettes` (`palette_source`): an assert at the palette's address, one
`dc.b $RR,$GG,$BB` per colour with its index in a comment, an assert at its end; a palette that
is renamed or deleted loses its include (the tool removes any other `.asm` in the folder), so its
`include` fails. `game/island.asm` 044630-046A00 is now 32 includes in address order, each under
its label `pal_<name>` (C19: the colours stay `data/palettes`' JSON, card A13), and six incbin
slices between them: 045830-045B30, 045B60-045E60, 045F20-0461F0, 046790-0467C0, 046820-046850,
046880-0468B0 (labels `dat_45830`, `dat_45B60`, `dat_45F20`, `dat_46790`, `dat_46820`,
`dat_46880`). They are colour tables no image pairs with (HYP: 045B60 is 048068's entry 69,
16 colours; 045830 is the palette 02DCCC stores into FFDB3C, 256 colours; docs/15 section 5 and
data/68k/operands.json), so they are not palettes of `data/palettes`, and this leg may not add
values there: an owner question (section 8).

The code's references follow the labels: `dat_44630` is `pal_level_base_00`, `dat_44930`
`pal_level_base_01`, `dat_461F0` `pal_title`, `dat_466A0` `pal_overlay_25`; the two references
into `level_base_00` are `pal_level_base_00+3*6` and `pal_level_base_00+3*11` (02C59E-02C5C0:
`pea` of the colour, `pea $5.w`, `pea $6.w` or `pea $B.w`, `jsr sub_2F610`: five colours from index
6 and from index 0Bh, CODE; the branch at 02C550-02C588 passes the same counts and indices with
colours from `dat_47CEE` and `dat_47D0C`, the cycling tables, so HYP: this restores the colours the
cycling changed).

**`palcheck` is gone.** It compared the palettes assembled alone with the image; the palettes are
now bytes of the tree, so `make check`'s comparison of every byte of the 25 files covers them and
`palcheck` checked nothing more. Its target, `palettes.bin`, `palettes.map`, the CLI command and
its tests are removed (docs/04, docs/15 follow). A planted change (title colour 6, red, in
`data/palettes/title.json`) now fails `make check` at the right place:
`136070-6106.200t: 1 differing bytes, first at file offset $03101 = 68k $046202` (0461F0 + 3 x 6;
restored, 0 differences). In CI, `tools/test_68k_tree.py::test_palettes_come_from_data_palettes`
assembles the tree against a random blob with a planted colour and finds exactly that byte
changed, and `tools/test_gspimages.py` assembles every include alone and checks its asserts.

## 3. Labels and equates

### 3.1 The image table's entries (follow-up of C10)

`tools/gspimages asm` labels every entry of the image table, `gsp_image_entry_NN` (two decimal
digits, as `gsp_image_NN`), before its `dc.l`. The fifteen operands docs/16 section 2.4 listed are
now the entry's label (`move.l gsp_image_entry_25,-(sp)` at 024AA8, 029C3E, 02AF88; entries 1, 2,
3, 29, 30, 32, 33, 34, 65, 66, 69 elsewhere). The address lint's count of label+offset references
into `images.asm`/`image_table.asm` is 0, and such a reference is now an **error** (the allowance of
C10 is removed: every entry has a label, so there is nothing an offset is needed for);
`test_tree_checks_fail` plants `tbl_BFE00+$64` back and the check fails. `tbl_BFE00` itself stays
(the ten `lea`/`addi.l` that index the table).

### 3.2 The sound command equates

`tools/m68k sound-equates` (`tools/m68k/sound.py`) writes `build/68k/sound_commands.asm` from
`data/sound/commands.json` on every `make` (rewritten only when its text changes): `name equ $NN`
for the 109 values 00-6C, names as the file has them (`snd_` and the audio-test name, `cmd_03_imm`
for 03; docs/11 section 11), the audio-test name as a comment. `stunrun.asm` includes it after
`ram.asm`. The 133 call sites (`pea N.w`) are not rewritten: the naming legs' work. The shift test
no longer counts an equate below 100h as a moving symbol (a small constant, not an address; a
label pinned by an `equ` elsewhere in the ROM still fails it).

### 3.3 `audio_test_list` (05C63C-05CF86)

108 records of 22 bytes, each `dc.w snd_<name>`, `dc.b '<NAME>',0`, `dcb.b N,0` to 22 bytes, then
`dc.w $FFFF` and an assert at 05CF86. Reader (CODE, `audio_test` 043718): `movea.l
#audio_test_list,a4` at 043720, the names at +2 (`lea ($2,a4),a3` at 043828), both pointers
stepped by 16h (043896-04389C) until `cmpi.w #$FFFF,(a2)` at 0438A4, the chosen record's word sent
by `send_sound_byte` (04395C) after `mulu.w #$16,d0` and `move.w ($0,a4,d0.w),d1`
(043950-043954). Every record's name is NUL-terminated and zero to 22 bytes (measured on the
image: no other byte there), and each word's command has that name as its `audio_test` in
`data/sound/commands.json` at that record (`audio_test_entry`); CI checks both
(`test_audio_test_list_is_source`).

## 4. The data

### 4.1 Text and pads

Every range `data/68k/classification.json` holds as `text` in 046AEE-05C63C is `dc.b` strings,
split at their terminators, each under a label (the slice's, else `str_X`): 7,825 bytes (one byte of the classification's text, 05C40D, is a pointer's, section 4.2). All but
one end with a NUL; the one that does not, 04EDA8-04EDC3 (`str_4EDA8`, the 27 characters
`A`-`Z` and a blank), is referenced (`movea.l #str_4EDA8` at five places in `code_03BC3C.asm` and
`code_03FC22.asm`), as the text rule requires. The raw-data check applies the record-field rules of
docs/16 section 3.1 to them: none fails.

146 single bytes the classification calls `unknown` lie right after a NUL-terminated string, at
an odd address, and are zero: each is `dcb.b 1,0` with the comment "a zero byte after a string, to
an even address" (decision of this leg, section 7: HYP, the original tool aligned each string's
successor to a word; the next item starts at an even address in every case).

### 4.2 The pointer tables (C18)

A long is `dc.l label` only when a reading instruction proves it is a pointer, or when it is a
member of a run inside such a table. `data/68k/tables.json` (format `stunrun-68k-data-tables 1`)
records each table: range, label, format and the reader, cited by instruction address; the
raw-data check holds every statement in a table to its format, and every long of the table (of a
record table: of each record's pointer field) must be a `dc.l` (`pointer_coverage`), so the file
cannot claim more than the source holds. Formats: `pointers` (`dc.l` of a label or 0),
`pointer_or_count` (a label, or a number below `below`), `records` (a stride and the pointer
field; the other fields stay incbin slices) and `audio_test_list` (3.3).

| Table | Longs | Format | Reader (CODE) |
|---|---:|---|---|
| 021650 (3 records of 10) | 3 | records, +0-+4 | `sub_2166E`: `movea.l (a0),a1` at 02167E reads 3-byte entries through it (021684-021698); +4 their count, +6 a GSP address (found by section 5) |
| 047406 | 30 | pointers | the level base palettes: 029B20-029B2E index by the level word x 4, `sub_296AA` reads the colours through its first argument (`movea.l ($8,a6),a2` 0296B2, `move.b (a2),(a5)+` 0296EA); 02531C and 02A5D8 store one into FF9558. Entries 24-29 are past the 24 level records, the same run (every long a palette) |
| 047F50 | 70 | pointer_or_count, 400h | per image entry: 02DBCA, 029980, 02DAF0 compare with 400h; below, a raw screen's rows (FF9BAE); at or above, FF9BD8, which `sub_2C686` dereferences (`movea.l (a2),a0` 02C6DC, `move.w ($1E,a0),d0` 02C6DE, `move.w (a0),d0` 02C6F8) |
| 048068 | 70 | pointers | the overlay per image entry: 02DACE-02DAD4 into FFDB40 (GSP command 9's palette address), `sub_296AA`'s second argument (null test 0296CA, `move.b (a3),(a4)+` 029726), 02A5FA into FF955C |
| 048180 (24 records of 40) | 216 | records, +4-+28h | `sub_2DD1E` (called with `pea ($4,a0,d0.l)` at 027902) walks nine string pointers (`movea.l (a2),a0` 02DD38, `move.b (a0)+,(a3)+` 02DD4C, `addq.l #4,a2` 02DD78, `tst.l (a2)` 02DD80); 02B308, 02B3F4, 02B51C pass +4 to `sub_30220` with a format string. +0 (the map's image entry, an index into 048068: `move.b ($0,a0,d1.l),d0` at 02A5F4, then `asl.l #2` and `movea.l #dat_48068,a0` 02A5F8-02A5FA; 024A98 and 26 more, 28 reads of +0 in all, 20 `move.b` and 8 `tst.b`, each after `movea.l #dat_48180,a0`) and +2 (a word into FF954E, 029DE4) stay incbin |
| 04A954 | 17 | pointers | 0307E0-0307E6 pass one to `sub_23898`, which draws the string (`movea.l ($10,sp),a0` 0238D4) |
| 04C712 | 182 | pointers | 0311CC-0311D2 into d3, then `movea.l d3,a5`, `movea.l (a5)+,a4` (0311DA-0311DC); 0358B8, 03A0A8 read it too. The run ends at the first long that points nowhere in the data; the 306 bytes after it stay blob |
| 04D628 | 25 | pointers | indexed by the level word x 4 (0277BE, 0277D8, 0279D0, 0279EA, 02B794), passed to `sub_31ABE`, which stores it into FFDC6C (031B64); `sub_3186A` dereferences that (031872-031878) |
| 04E3B4 | 9 | pointers | 03D64A-03D650 into d4, `movea.l d4,a0`, `tst.w (a0)` (03D7A8-03D7AA) |
| 04E3D8 | 12 | pointers | 03D490-03D496 into d4, `movea.l d4,a0`, `tst.b (a0)` (03D5EA-03D5EC) |
| 04EA6A | 12 | pointers | 04019C-0401A2 and 0401DA-0401E0 pass one to `sub_2E4B4`, a string copy (`movea.l ($C,a6),a1` 02E4BC, `move.b (a1)+,(a0)+` 02E4C2) |
| 05C3F6 | 6 | pointers | 04239C-0423A2 pass one to `sub_41D92`, which takes its length (`move.l ($C,a6),d1` 041D9E, `jsr sub_2E4E6` 041DBA) |
| 05C47C | 6 | pointers | `sub_42262`: `movea.l ($0,a0,d0.w),a3` at 042278, `cmpa.w #$0,a3` at 04227C |

Every target got a label where it had none (`dat_X`, the slice cut there: 047D46, 047D80,
047DBA, 047DF4, 047E2E, 047E68, 047EA2, 047EDC, 047F16, the zero bytes 0485E6/0485E8 that two level
records name as empty strings, and more in 04B142-04C70A and 04F104-05BE04). An incbin slice that a
table split carries its own label (C3). The targets of 048068 are the palettes of section 2
(`pal_overlay_*`, `dat_45B60` for entry 69), of 047406 the six `pal_level_base_*`.

04CB36 is not 048180's +0, though its bytes are 048068 indices too: `movea.l #dat_4CB36,a0` then
`move.b (a0,d1.l),d0` at 029A68-029A70, indexed by the word at (a2) unscaled, and at
029B08-029B10, indexed by the level word minus 1; each byte goes through `asl.l #2` into
`movea.l #dat_48068,a0` (029A74-029A7C, 029B14-029B1C). It is not a table of this leg and stays
blob.

**Finding (05C3F6).** The table is six longs, not five: the sixth long (05C40A-05C40D) points at
05C462 ("Excess Time (1/10th sec)"), and its low byte is the first byte of the classification's
text range 05C40D-05C41D, which the text rule took for a character (as it did with the command
words of `audio_test_list`, docs/16 section 3.1). The source has the long and the string from
05C40E (`str_5C40E`), where the first long points; the classification is unchanged (the raw-data
check finds the `dc.l` in the table first), an open point for `make classify`'s text rule.

What stays blob in `data.asm` and why (78,319 bytes): every long no reader proves (decision C18,
"counting longs that look like addresses is not evidence"), the record fields of 021650 and
048180 outside their pointer fields, the bytes the classification calls data or unknown. The
level object lists that 04D628 points at (04D5EC and the lists in 04F104-05BE04) are streams
that `sub_3186A` reads through a cursor (FFDC6C, and a second one in FFDC70), and which no leg
has turned into source; section 5 shows they are the next thing that breaks a moved build. What
the code shows of them (CODE, unidasm on `build/stunrun-68k.out`):

- each step reads a record pointer (`movea.l (a2),a1`, `addq.l #4,(a2)`, `movea.l (a1),a3`,
  031896-03189A; FFDC70's stream the same at 03198A-03198E);
- the next long is an optional parameter, not a pointer: it is copied to (-4,a6); with bit 31
  set it is masked with 7FFFFFFFh and the cursor steps past it (0318A2-0318C2), otherwise
  (-4,a6) is cleared and the cursor does not move (0318C4-0318C8; FFDC70's stream
  03199A-0319C2). It is passed as the 6th argument of `sub_30F9C` (031938, 0319E6), whose
  `link a6,#-$34` puts it at ($1C,a6): the high word is stored at +18 of the object entry
  (031196) and, masked with 1FFh, indexes 04C712 (0311B8-0311D2, 0 meaning none); a nonzero low
  word goes to `sub_33480` (0311A2-0311B0). Bit 31 is the mark that the parameter is there,
  so a long with bit 31 set is never an address;
- when the record's flags (`movea.l ($E,a3),a1`, 0318CC) have 1000h, the next long is a jump:
  it replaces the cursor (`move.l (a0),(a2)`, 0318DE; FFDC70's stream 0319DC); otherwise, when
  they have 80020h (0318E2-0318F0), the next long is loaded into FFDC70 and the cursor steps
  past it (031922-031926).

How a list ends and what each record is are not proven here.

## 5. The moved-build experiment (report, not acceptance)

**Method.** `tools/m68k moved --pad 4` (`tools/m68k/moved.py`) copies the tree, comments out its
guards, makes its incbin paths absolute (and copies the generated includes the same way) and adds
`dcb.b 4,0` after `include "game/vectors.asm"`: everything from 020430 to 05CF86 moves by 4, the
fill at 05CF86 (`dcb.b $060000-*,0`) is 4 shorter, so the boot program, the ADSP and GSP programs,
the game vector table (020000, installed by `movec` at 000294) and pairs U-W do not move; the
vectors and `game_entries` name the moved handlers. `tools/split-roms` cuts it with the other
four images into `build/moved/roms/stunrun` (never committed). `tools/mame/movedcheck.lua` logs
per frame, for the GSP host port (C00000-C0000F), the ADSP (800000-83FFFF) and the sound latch
(600000-603FFF), the count of the 68010's writes and an FNV-1a hash of their offset, data and mask;
`MOVED_DETAIL=F1-F2` logs every write of those frames with the PC. `tools/m68k moved-compare`
reports the first frame per stream that differs. Commands (2026-11-17, MAME 0.289, headless, each
run from its own empty NVRAM and cfg):

```
make -j4 movedcheck                       # reference and moved, attract and a game, 4000 frames
make MOVED_FRAMES=416 MOVED_DETAIL=415-415 build/mame/moved-moved-attract.txt   # the details
```

MAME runs the moved set with its "WRONG CHECKSUMS" warning and boots it; the boot self-test's ROM
sums are not run on a normal boot.

**First result.** The streams were equal to frame 362. In frame 363 the GSP host-port writes
differed in value, not count: the first differing write is HSTDATA from `move.w d3,GSP_HOST+$C`
at 0216A8 (the tap reports the PC after it, 0216AE in the reference, 0216B2 moved) in `sub_2166E`, which builds D3 from 3-byte entries read through `movea.l (a0),a1` from a 10-byte
record of 021650 (CODE, 02166E-0216AE). The records' +0 longs were blob: in the moved build they
still named the reference addresses, 4 bytes before the moved entries. They are now `dc.l` of
labels (`dat_2160E`, `dat_21623`, `dat_2163B`, the slice 02161D-021650 cut at the two new targets),
a `records` table of `data/68k/tables.json`.

**Second result** (after that fix, the same commands):

```
moved-attract: 871 frames compared (reference 4000, moved 871); moved reset at frame 871
  gsp: first differs at frame 415 (writes, hash: reference 0 811C9DC5, moved 3762 DB9C4D6E)
  adsp: first differs at frame 446 (writes, hash: reference 2 91B619C5, moved 0 811C9DC5)
  snd: first differs at frame 447 (writes, hash: reference 1 D4AC5B60, moved 0 811C9DC5)
moved-game: the same (the game run's start press comes at frame 960)
```

Cause, from breakpoints in a scratch run of the moved set under `-debug -debugger none`: in frame
414 the 68010 enters `h_address_error` (a breakpoint at its moved address 0229B8; A2 odd, the
stacked PC moved 0319CA = reference 0319C6, `movea.l ($E,a2),a1`),
whose handler calls `sub_30692` and the error screen `sub_30972` with code 2 (`init_gsp` at frame
414, the GSP writes of frame 415); the watchdog resets the machine at frame 871. 0319C6 is in the
code after `sub_3186A`, which walks the list that FFDC6C points at: the entry of 04D628 for the
level (a label now), whose longs are numeric pointers in blob (04D5EC is the first list) and name
the reference addresses of records that moved.

The fault's registers, observed (2026-11-17, `make MOVED_FRAMES=430
build/mame/moved-moved-attract.txt`: `movedcheck.lua`'s read tap on the game's bus and address
error vectors 020008-02000F writes one `# exception` line at the first fetch of each): vector 3
in the frame the log numbers 415 (the frame whose GSP writes first differ; the debugger run above
counted it 414), stacked PC 0319CA, A2 = 073283, FFDC70 = 000C08, FFDC6C = 04D614 (in the moved
layout: 04D610 in the reference's, inside the first list 04D5EC). A2 is odd and lies outside the
whole data region 046AEE-05CF86 (in pairs U-W), so it is not a record pointer plus an offset: it
is the long that `movea.l (a1),a2` at 03198E read through the cursor FFDC70 (`movea.l (a0),a1`,
`addq.l #4,(a0)` 03198A-03198C), and the cursor itself, 000C08 after that `addq`, points into
the boot program. FFDC70 is loaded at 031926 (`move.l (a1),$ffdc70.l`, after `movea.l (a2),a1`,
`addq.l #4,(a2)` 031922-031924) from the stream FFDC6C points at, the 04D628 entry's list. HYP:
the stream is out of step because the records it names are read at their reference addresses
(the record's flags, `movea.l ($E,a3),a1` at 0318CC and 0318E2, decide whether the stream jumps,
`move.l (a0),(a2)` at 0318DE, or loads FFDC70, 031922-031926), so the long loaded at 031926 is
not a record pointer. Not fixed
here: the lists' record pointers, parameter longs (bit 31 set), jump longs and FFDC70 longs are
read as section 4.2 says, but how a list ends and what each record is are not proven by this
leg, so the lists stay blob.

**The rest, for the naming legs (a worklist, not evidence).** `tools/m68k moved-candidates
--listing build/stunrun-68k.lst --binary build/stunrun-68k.out` lists the runs of four or more
longs still in incbin slices of 020430-05CF86 whose value lies in the data or is an even address
of the game code (a long with bit 31 set, the lists' parameter long of section 4.2, never counts):
685 runs, 4,499 longs, 15 runs (149 longs) in 046AEE-04F104 and 670 runs (4,350 longs) in
04F104-05BE04, the level data the reviewed operands reach through FFDE82
(docs/16 section 5); none in the code files or the island. Each needs its reader before it becomes
source; until then a moved build diverges, as it does in frame 414.

## 6. The checks

- **`tools/m68k check-tree`'s raw-data check** covers 000000-012F06 and 020000-060000 since this
  leg (`RAW_FILES`), `data.asm` included, with the kinds of section 4 (strings and fills as in the
  code files, palette triples inside a palette of `data/palettes`, the statements of a table of
  `data/68k/tables.json` in its format, under the label the registry names at the table's
  start, which the listing must define there). `load_tables` refuses a table without its reader,
  of an unknown format or overlapping another.
- **The address lint** refuses a label+offset reference into `images.asm`/`image_table.asm`
  through any label the listing defines in 060000-0C0000 (`tbl_BFE00+$64`, `gsp_image_entry_24+4`,
  `4+gsp_image_entry_24`, `gsp_image_NN-$10`; a difference of two labels is no offset).
- **The shift test**: 5,101 statements changed, 5,101 expected (4,589 before: the 512 new
  `dc.l` that name a label, the other 146 being 0 or a count; the references renamed to palette
  and entry labels count as before).
- **CI** (`tools/test_68k_tree.py`, `tools/test_gspimages.py`, `tools/test_build.py`, no ROM): the
  tree assembled against a random blob passes every check (0 label+offset references, 0 raw-data
  errors, the shift test exact); the lint flags `gsp_image_entry_24+4` and `4+gsp_image_entry_24`
  planted in the code (`test_tree_checks_fail`); the palettes are `data/palettes`' bytes and a planted colour
  changes exactly its byte; the sound equates are `commands.json`'s; `audio_test_list` is
  source; the raw-data check fails on a planted `dc.b` wall in `data.asm` (at 04A88C), a record
  header of 048180 written as `dc.l`, a count in a pointer table, 400h in 047F50 and a registered
  table left an incbin slice, three numbers `dc.b $01,$02,$03` outside every palette and a
  registry label the listing does not define at the table's start
  (`test_data_asm_raw_data_check_fails`), and on a broken
  `audio_test_list` record; the moved tree keeps 000000-020000 and 060000-0C0000 and moves the
  labels between by the pad (`test_moved_build`), and `moved-compare` finds the first differing
  frame on made-up logs.
- **Local** (needs the reference set): `make check`, `make m68k-check` (labels, descent, lint,
  raw data, shift, unidasm), `make coverage`, `make test`, `make lint`, `make movedcheck` (MAME).

## 7. Decisions taken in this leg (not in the issue)

1. Palette labels are `pal_<name>` (the tool's existing spelling), written in `game/island.asm`;
   the include holds the asserts and the colours. The neutral labels at the palettes' addresses
   are replaced by them in the code (`dat_44630` and three more), not kept beside them.
2. The zero byte after a string at an odd address is a one-byte fill (`dcb.b 1,0`, 146 bytes):
   the M5c fill rule (a zero run of 32 or more) did not reach them, and they are not text.
3. The pointer formats are a committed registry, `data/68k/tables.json`, read by the raw-data
   check (addresses and citations only), rather than an argument per `dc.l` in comments.
4. A table's run is taken while every long is 0 or a data address, from the table's base up to
   the next label or the first long that is not (047406's 30 longs, past the 24 levels; 04C712's
   182; 04EA6A's 12, after which its targets begin). 05C3F6 has six (section 4.2).
5. 048180's +0 (the map entry, a byte the readers use as an image table index) and +2 (FF954E's
   start value) stay incbin: proven fields, but numbers whose symbolic form (an entry label, a
   named duration) is the naming legs' (residue rule).
6. `palcheck` is removed (section 2).
7. `ida/code_map.py` and the IDA snapshot are unchanged (C20 allows adding names for the new
   labels; none is needed by `make labels`, and the palette and entry names are generated).

## 8. Questions for the owner

1. The six colour tables between the palettes (section 2: 045830, 045B60, 045F20, 046790, 046820,
   046880): add them to `data/palettes` (048068 entry 69 points at 045B60; 02DCCC stores 045830
   into FFDB3C), or keep them blob until an image or a reader pairs them?
2. The 146 pad bytes as `dcb.b 1,0` (decision 2): accept, or keep them one-byte incbin slices?
3. 048180's +0 and +2 fields (decision 5): may they be written as `dc.b` of an entry number and
   `dc.w` of a count now that their readers are cited, or wait for symbolic names?

## 9. Open points

- The classification's text range 05C40D-05C41D starts one byte early (section 4.2): `make
  classify`'s text rule could learn that a pointer table's last long ends where text starts.
- The level object lists (04D5EC, 04F104-05BE04) and the other runs of section 5's worklist.
- 04C712's tail (306 bytes after the run) and the layout records 047D34-047F50 (58-byte records
  that 047F50 points at): formats not read here.
