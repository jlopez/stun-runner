# The 68k code as source

**Date**: 2026-11-16 (milestone 5, wave 1, leg M5c, issue #33). All the 68010 code of the 68k
image is byte-identical neutral vasm source in `asm/68k`: the boot program, the game program and
the code in the game's island, with their vector tables, switch and pointer tables and text.
What the classification (docs/14) does not explain stays `incbin` slices of
`build/stunrun-68k.bin`, each under its label. The checks of docs/14 now run on the tree's own
listing, locally (`make m68k-check`) and in CI. Names and comments are the naming legs' work
(docs/03 M5); this document says how they work on the files. **CODE** means read off the
instructions at the addresses given, **MAME** a run of `make pccov`, **HYP** a hypothesis.

## 1. What changed

- The classification was checked first (docs/14 section 8 step 1): `make -j5 pccov` and `make
  classify` were re-run on the reference set and gave the committed `classification.json` and
  `pccov-summary.json` unchanged (1,637 ranges, 163,638 bytes of code, 457 entries, every
  executed PC a classified instruction start). The unreferenced ranges that decode cleanly
  stay `unknown` (decision C8, docs/14 section 3). The review of the leg found the text rule
  wrong in two ways, and the rule is fixed (section 3.1, `make classify` again: 1,635 ranges):
  record fields had been read as the first characters of strings, and the printable middle of
  three numeric tables in the island as text.
- The 32 long immediates docs/14 section 4 left undecided are decided, each with a written
  reason, in `data/68k/operands.json` (section 5).
- `tools/m68k gen` ran once over each file of the layout below (one model of the whole image,
  so every file agrees on which labels are global and which are vasm locals) and its output was
  committed with a header per file; the generator is frozen from here on (decision C12; section
  6).
- `asm/68k/ram.asm`: one shared file of the 533 equates the source uses beyond `hardware.asm`
  (decision C9; section 2.2).
- `data.asm`'s one incbin is cut at the 429 addresses the code references, each slice under its
  label; the bytes stay blob (the data leg's).
- `tools/m68k check-tree` and the reworked `make m68k-check`, `tools/m68k pccov --listing`, and
  the CI tests in `tools/test_68k_tree.py` (section 4).

`make check`: 25 files, 0 differences at every commit of the leg.

## 2. The files

### 2.1 The layout

`stunrun.asm` includes, in this order, `hardware.asm`, `ram.asm`, `macros.asm`, then the region
files in address order. The code is cut at routine starts (a `sub_` label or a snapshot name, so
a global label: no vasm local crosses a cut) into files of at most about 16 KB, named by their
first address (decision C11); the routine at 03FEA6, which crosses the S/T pair boundary 040000,
lies whole in `game/code_03FC22.asm`. The boot program has long stretches of data and text
without a routine start, so its cuts fall short of 16 KB.

Bytes per class (`make coverage`, on the reference build), and the classification's data and
unknown bytes in the same range:

| File | Range | Bytes | instr | data | blob | fill | data (cl.) | unknown (cl.) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| `boot/vectors.asm` | 000000-000212 | 530 | 0 | 256 | 274 | 0 | 0 | 274 |
| `boot/code_000212.asm` | 000212-00394E | 14,140 | 9,378 | 160 | 4,523 | 79 | 1,836 | 2,687 |
| `boot/code_00394E.asm` | 00394E-0065E0 | 11,410 | 6,822 | 0 | 4,588 | 0 | 3,950 | 638 |
| `boot/code_0065E0.asm` | 0065E0-009E80 | 14,496 | 4,270 | 7,445 | 2,781 | 0 | 138 | 2,643 |
| `boot/code_009E80.asm` | 009E80-00DDF2 | 16,242 | 9,800 | 244 | 6,198 | 0 | 1,610 | 4,588 |
| `boot/code_00DDF2.asm` | 00DDF2-0109D4 | 11,234 | 4,992 | 0 | 6,242 | 0 | 5,950 | 292 |
| `boot/code_0109D4.asm` | 0109D4-012F06 | 9,522 | 34 | 0 | 8,964 | 524 | 3,900 | 5,064 |
| `game/vectors.asm` | 020000-020430 | 1,072 | 18 | 256 | 24 | 774 | 48 | 0 |
| `game/code_020430.asm` | 020430-024306 | 16,086 | 6,772 | 646 | 8,629 | 39 | 857 | 7,772 |
| `game/code_024306.asm` | 024306-028194 | 16,014 | 15,704 | 310 | 0 | 0 | 0 | 0 |
| `game/code_028194.asm` | 028194-02C0D2 | 16,190 | 15,922 | 112 | 156 | 0 | 0 | 156 |
| `game/code_02C0D2.asm` | 02C0D2-030012 | 16,192 | 11,560 | 52 | 4,580 | 0 | 0 | 4,580 |
| `game/code_030012.asm` | 030012-034010 | 16,382 | 15,768 | 46 | 568 | 0 | 0 | 568 |
| `game/code_034010.asm` | 034010-037C52 | 15,426 | 14,922 | 62 | 442 | 0 | 0 | 442 |
| `game/code_037C52.asm` | 037C52-03BC3C | 16,362 | 15,916 | 74 | 372 | 0 | 0 | 372 |
| `game/code_03BC3C.asm` | 03BC3C-03FC22 | 16,358 | 16,108 | 70 | 180 | 0 | 0 | 180 |
| `game/code_03FC22.asm` | 03FC22-04397E | 15,708 | 15,390 | 54 | 264 | 0 | 0 | 264 |
| `game/island.asm` | 04397E-046AEE | 12,656 | 262 | 61 | 12,333 | 0 | 12,292 | 41 |
| **code files** | | **236,020** | **163,638** | **9,848** | **61,118** | **1,416** | **30,581** | **30,561** |

Instructions, labels (vasm locals) per file as generated: boot 8,220 instructions in six files
(2,152 labels, 777 locals), game 36,463 (9 of them the `moveb_ffff_*` macros) in nine files and
the island (3,929 labels, 2,943 locals), the vectors 65 + 70 labels; 44,683 instructions, 6,216
labels, 3,720 locals in all.

In every code file the blob is exactly the classification's data and unknown bytes of its range
(`data (cl.)` + `unknown (cl.)` = `blob`), but in `game/vectors.asm`: 020400-020418 is data by
the classification (020400 is the base `movea.l #$20400,a2` loads at 042356) and all zero, so it
is a `dcb.b 24,0` under its label `dat_20400`, as wave 0 had it inside the fill 020112-020418.
The six zero runs of wave 0 stay fills (94,883 bytes); the generator added the classification's
fills inside the code (642 bytes: 603 in the boot program, 39 in the game).

The 68k image: instr 163,638, data 9,884, blob 517,385, fill 95,525 (wave 0: 0, 36, 691,513,
94,883). The blob fell by 174,128 bytes, exactly the bytes that became instructions (163,638),
data (9,848) and fills (642). (Before the review's text fixes, section 3.1: data 10,003 and blob
517,266; the 119 bytes of record fields and island tables went back to blob.) The set: `blob: 34.2% of 1511424 bytes come from incbin/.binary`
(45.8% before). `data.asm`, `programs.asm`, `images.asm` and `image_table.asm` keep their
blobs (91,288, 32,688, 332,011, 280).

### 2.2 `ram.asm`

The 533 equates the generated source uses that `hardware.asm` does not define, sorted by value
in three groups: RAM FF8000-FFFFFF (484 `ram_FFXXXX` and 9 snapshot names: `sound_resp_out`,
`game_options`, `sound_wait_ready`, `sound_wait_status`, `sound_check_tries`, `sound_queue`,
`sound_queue_count`, `sound_queue_fill`, `sound_queue_send`), ZRAM FF4000-FF4FFF (`io_FF4XXX`:
the generator names any non-RAM address outside the I/O equates `io_X`) and the other addresses
outside the ROM and the I/O equates (`io_400000`, `io_408000`, `io_840000`, `io_84C000`,
`io_E0000`-`io_E8000`: what the boot program's tests address; their role is the boot naming
legs'). Values are 24-bit; an absolute short operand subtracts `ABS_SHORT` (`macros.asm`).
`tools/test_68k_tree.py` checks that every equate is used, defined once, not in the ROM, not a
hardware name, and that a neutral name spells its value.

### 2.3 `data.asm`

`data.asm` (the data leg's) is cut at the 429 addresses inside 046AEE-05CF86 that the code
references (the two snapshot names there among them), each slice an `incbin` under the label the
generator gives that address: the snapshot's name (`audio_test_list` at 05C63C, `object_descriptors`
at 048F9C, ...), else `dat_X`, `str_X` or `tbl_X` by the classification's kind. No byte became a
`dc` statement there (the issue's scope 5), and the code-pointer tables stay blob. Nothing in the
code references the fill 05CF86-060000.

### 2.4 References into files this leg does not own

`programs.asm`: the code reads `adsp_program_ptr` (02C204) and `gsp_program_ptr` (02C1B6,
02DCB0), labels that exist there. `images.asm`: no reference. `image_table.asm`: ten operands use
`tbl_BFE00` itself (the `lea`/`addi.l #tbl_BFE00` that index the table) and fifteen read an
entry, written `tbl_BFE00+$N` (decision C10; listed by `tools/m68k check-tree -v`, counted by the
lint):

| Address | Operand | Address | Operand | Address | Operand |
|---|---|---|---|---|---|
| 024AA8 | `tbl_BFE00+$64` | 02D79E | `tbl_BFE00+$84` | 02DB62 | `tbl_BFE00+$114` |
| 029C3E | `tbl_BFE00+$64` | 02D7B0 | `tbl_BFE00+$88` | 02DB92 | `tbl_BFE00+$8` |
| 02AF88 | `tbl_BFE00+$64` | 02D7D0 | `tbl_BFE00+$4` | 040580 | `tbl_BFE00+$74` |
| 02D77A | `tbl_BFE00+$78` | 02D7EC | `tbl_BFE00+$8` | 0407B6 | `tbl_BFE00+$104` |
| 02D78C | `tbl_BFE00+$80` | 02DB32 | `tbl_BFE00+$C` | 04081C | `tbl_BFE00+$108` |

All are `move.l tbl_BFE00+$N,-(sp)`: an entry of the image table pushed as an argument. The
images leg may give the entries labels and replace these operands.

## 3. What stays blob, and why

- **unknown** (30,561 bytes in the code files): the routines no decided code reaches that
  decode cleanly (76 ranges, 11,169 bytes, docs/14 section 3) (decision C8: they stay `unknown` until a reviewed seed argues each, the naming
  legs' work; docs/14 sections 3 and 10), the dead bytes between code, the `jmp abs.l` table at
  000100-0001F0 and the rest of 000100-000212, and the boot program's screen records around
  their strings: the header of each (column, row, attribute, count; section 3.1), and the
  record at 007660 whose count, 9, is not its 12 characters.
- **data** (30,581 bytes, less the 24 zero bytes at 020400): bytes an operand references whose
  format no leg has explained yet (record tables, the 000E12 record table, the island's data at
  0439BC-0445F0 and 044630-046A00 (its numeric tables included, section 3.1), the option
  records' item bytes, ...).

### 3.1 The text rule, corrected in review

The leg's first tree committed record fields and table bytes as characters of `dc.b` strings,
because the text rule of docs/14 took every printable byte of a run. Three readings now keep
them out (`tools/m68k/classify.py`, `_text_runs` and `_counted`; tests `test_text_rule_record_fields`,
`test_committed_classification`):

- **Counted strings.** The boot program's screen records are a 4-byte header, then the
  characters, no terminator; the last header byte is the count of the characters (read off the
  image: the 214 records whose count is a non-printable byte, such as 00714C-007150 `0600FF0D`
  before the 13 characters of `SA*AUDIO*TEST`). HYP: the other three are column, row and an
  attribute (the records of one line, 00766C and 007674, share the second byte). A count of
  20h-3Fh is printable, and an attribute of 3Fh or 70h too, so 47 strings began with their
  count and 32 with attribute and count (`str_7FDC` was `"?'ROTATE*ONES..."`, 27h = 39 the
  characters after it). The count is now never text: an unterminated run is a counted string
  when the byte before it, its first byte or its second byte (up to 3Fh) equals the characters
  after it, or one fewer (006D9D, 007398, 0088DD, 008909: the ROM's count is one short of the
  characters, which all stay text). One fewer only when the run's last byte does not start the
  next record: at 007A7F, 007A95, 007B42 and 007B53 the run's last byte is 20h, the column of
  a header whose count is the run after it (007A7F-007A82 before the 18 characters of
  `CONTROL*LEFT/RIGHT`), and the count before the run is exact (0Fh for `INC*PM*DATA*0-7`), so
  that byte ends the text and is the next header's first byte (`classify.trailing_header`;
  found in the second review: the four strings had ended with a blank). 007DB1 and 007E10 are
  new text (attribute 3Fh and count 25h had kept the run from reading as text).
- **Item bytes.** The game's option records (020ED0-021148) start with an item byte before the
  title (FDh, CCh, BBh, AAh, 99h, 88h; BBh at 020F51 is the one 042CE4 decodes, CLAUDE.md M4e).
  The one at 020FD5 and 0210FC is 76h, `v`, and was the first character of
  `CONTINUE ADVANCES TO NEXT LEVEL`. A lower-case first byte before upper-case text is now no
  character (`dat_20FD5`, `str_20FD6`; the same reading drops six such bytes in `data.asm`'s
  records at 05C719-05CDE3, where only the classification changes: at 05C719 what is left is
  too short to be text).
- **Numeric tables.** `str_45A79`, `str_45AD6` and `str_4659B` in the island were the printable
  middle of byte tables: no terminator, no reference, the table's values continuing in
  non-printable bytes past both ends of each run (045A79's run is eleven values three times
  each, rising by 8 or 9, in a table that starts at 045A70 and goes on past 045A9A; 045AD6's
  rises from 045AD0 to past 045AEA). An unterminated run is now text only
  when it is counted or an operand references its start; the three are data again under the
  references at 045830 and 0461F0, as incbin slices.

`BAD*ZRAM*AT:` at 007660 (count 9 before 12 characters) is no counted string by this rule and is
blob now; which of its bytes the screen shows is the boot naming leg's to find in MAME. The
raw-data check (section 4.1) applies the same readings to the source: a quoted `dc.b` in a code
file whose first or second character is a count of the characters after it, or whose first
character is a lower-case item byte, fails.

## 4. The checks

### 4.1 `tools/m68k check-tree` and `make m68k-check`

`tools/m68k check-tree --listing build/stunrun-68k.lst --binary build/stunrun-68k.out
[PCCOV_RUN ...]` (`tools/m68k/tree.py`) runs on the tree's own listing:

- the descent check of docs/14 section 5.3 over the whole listing (seeds: the source's own
  `dc.l` and `dc.w a-b`, the vectors, `game_entries`, the classification's entries with evidence,
  the reviewed seeds; the untaken branch at 004B74), and every classified instruction start is
  an instruction statement (code turned back into a blob or data fails); conversely, every
  instruction statement is a classified instruction start, so a range the classification does
  not call code cannot become instructions by hand: a `dc.l` naming it would seed the descent
  and reach it, but promoting a range needs a reviewed seed in `data/68k/seeds.json` and
  `make classify` (decision C8);
- the address lint over 000000-0C0000; the references into `images.asm` and `image_table.asm`
  as label+offset are counted (section 2.4); a long immediate `data/68k/operands.json` decides
  is a constant fails when it is written as a ROM label (`#dat_100` for `#$100`: the shift test
  cannot see it, since the label moves with the pad, review fix 2);
- the raw-data check: in the code files (000000-012F06, 020000-046AEE) every `dc`/`dcb`
  statement is an explained kind: `dc.l` in a vector or pointer table, `dc.w a-b` in a switch
  table, `dc.b` of quoted strings and zeros in text, a `dcb.b N,0` fill. A `dc.b` wall in place
  of an incbin slice fails (decision C3), as `tools/test_jsa_music.py` does for the 6502, and so
  does a string that starts with a record field (a count or an item byte, section 3.1);
- the shift test: the tree copied to a temporary directory, its guards commented out, a
  two-byte pad after `org 0` (each `dcb.b $X-*` fill lengthened by the pad so that it does not
  absorb it), its incbin paths made absolute, assembled again; exactly the statements that name
  a ROM symbol other than PC-relatively or as a difference change, each word by the pad; a
  source file the tree includes from `build/` (a generator's output, such as issue #34's
  `build/gsp-images/*.asm`) is copied and padded the same way, its asserts commented out;
- with the run files of `make pccov`: every executed PC starts an instruction statement (two
  run files with one name, `pccov-game.txt` from two directories, fail, here and in `tools/m68k
  pccov`, so that none goes unchecked).

`make m68k-check` runs `make labels`, `check-tree` with the run files present in `build/mame`
(it says so when there are none) and `check-unidasm`. On the reference build, 2026-11-16:

```
labels: 223 snapshot names in ROM: 223 labels in the tree, 0 in blob, 0 failures; 31 outside ROM (I/O, ZRAM, RAM: not checked here)
descent check: 44683 instruction statements reached, 0 not, 0 errors; 0 classified instruction starts without a statement, 0 instruction statements at no classified instruction start
address lint: 0 errors, 337 listed constants, 0 undecided; 15 references into images.asm/image_table.asm as label+offset
raw-data check: 0 errors
shift test: 4521 statements changed, 4521 expected, 0 errors
pccov attract: 17056 distinct PCs, 0 not an instruction statement
pccov game: 16299 distinct PCs, 0 not an instruction statement
pccov selftest: 5371 distinct PCs, 0 not an instruction statement
pccov soundtest: 5895 distinct PCs, 0 not an instruction statement
pccov postest: 5944 distinct PCs, 0 not an instruction statement
ok
44683 instruction boundaries in 180 code ranges; 0 ranges differ from unidasm
```

`make pccov` passes `--listing build/stunrun-68k.lst` to `tools/m68k pccov`, which then also
fails on an executed PC that starts no instruction statement of the tree (0 in each of the five
runs). `make labels`: every one of the 223 snapshot names in ROM is now a label of the tree at
its address (wave 0: 11), none is left in a blob.

### 4.2 In CI

`tools/test_68k_tree.py` assembles the committed tree against a random blob (vasm only, no ROM)
and runs `check-tree`'s checks on that listing (`test_tree_checks_pass`: no error, every
statement reached, every classified instruction start a statement and no other, no undecided
operand, 337 listed constants, 15 label+offset references, the shift test exact).
`test_tree_checks_fail` plants one fault per copy of the tree and checks that the right check
fails: an unknown slice written as `nop`s (the descent check: each `nop` unreached), the same
slice as a `dc.b` wall (the raw-data check, at its address), a `jsr sub_X` written `jsr $X` (the
lint), a label pinned by an `equ` (the shift test). `test_raw_data_check_fails` plants the other
raw-data faults in one copy (a `dc.l` wall in a data range, a text string as numeric `dc.b`, a
`dcb.b 40,$FF`, a switch entry written as a number, a count written back as the first
character of `str_7161`, an item byte as the first of `str_20FD6`, the next record's column 20h written back as the last
character of `str_7A70`) and finds each. `test_constant_written_as_a_label_fails` writes a listed
constant (020CB4) and a reviewed one (02FC76) as ROM labels of the same value and the lint
refuses both. `test_shift_test_pads_generated_includes` moves a fill of `game/vectors.asm` into
a file under `build/` with an assert, and the shift test still passes. `test_runs_need_distinct_names`
(`tools/test_m68k.py`) gives `pccov` and `check-tree` two run files with one name. `test_code_turned_blob_fails`
writes a routine's first instruction as an incbin slice of its own bytes: the classified start
without a statement, an executed PC there (through `check-tree`'s runs and `tools/m68k pccov
--listing`) and `check-tree`'s exit status 1 each fail. `test_promoted_range_fails` writes an
unknown range as instructions under a label that a `dc.l` in `data.asm` names, so the descent
reaches them, and the converse check fails on them (decision C8). `test_labels_on_the_tree` takes a label out of source and moves another,
and `make labels` fails on each. `test_tree_assembles_a_random_blob` checks that every incbin
slice of `build/stunrun-68k.bin` takes the blob's bytes from its own address, and the fills and
the program table. `tools/test_build.py` builds the synthetic set (whose 68k image is now mostly
the tree's own code) and checks `make coverage`'s rows against the files' ranges, the code
files' 61,118 blob bytes and 163,638 instruction bytes, and `make labels`.

What CI cannot check: the bytes of the code against the ROM (no reference set), unidasm's
boundaries and the MAME runs. `make check`, `make m68k-check` and `make pccov` are the local
proof.

### 4.3 The generator, frozen

`tools/m68k gen` refuses to write any of its outputs (`--out`, `--equates-out`,
`--externals-out`) over a file of `asm/68k` (exit 2, before writing anything;
`test_gen_is_frozen_over_the_tree` tries each)
and its header says it is frozen (decision C12). It stays for `check-region`, which still
regenerates a region in scratch and checks it against the image (`test_regions_reassemble`,
local), and for scratch output. `make m68k-check` no longer runs `check-region`: the tree is the
thing checked.

## 5. The operand decisions

The 32 long immediates rule R7 left undecided (docs/14 section 4) carry `"rule": "reviewed"` and
a `reason` in `data/68k/operands.json`; `tools/m68k classify` keeps every reviewed entry when it
rewrites the file (`operands.load_reviewed`, CI: `test_operand_rule_table_base`), and `load`
refuses a reviewed entry without its reason. 31 are addresses, one a constant (CODE):

| Instructions | Decision | Why |
|---|---|---|
| 02444E, 0245F8 (`#$461F0` into FF9558) | address | FF9558 is a pointer variable: 024D0E, 026F98, 0286DC, 0287C6, 0288D0, 02A8C4 store 044630 there and 0284A4, 02AA7E 044930 (R4), five instructions a long from a table; every read pushes it as an argument |
| 026F12 (`#$461F0`), 02DCCC (`#$45830`) into FFDB3C | address | FFDB3C holds the RAM address FF9584 (fourteen stores), 044630 (02716A, 02B69A) or a long read from the data |
| 024FA8 (`#$466A0` into FFDB40) | address | 04055C and 02DAD4 store longs from tables there; 02F1DE tests it for zero and 02F1E6 pushes it |
| 028476 (`#$439C8` into FF9B90) | address | 028480 `movea.l $FF9B90,a0` |
| 031F92 (`#$4AFF6` into FFDE74) | address | a string start (text 04AFF6-04B00D); 04168A stores a table long there, 028C88 pushes it |
| 0405B0, 040620, 0407E6, 04084C, 0408C6, 0409D4, 0409F6 (into FFDE82) | address | 0405F0, 040640, ... `adda.l $FFDE82,a0`: table bases in the data range 04F104-05BE04 |
| 025E9C (D2) | address | 025F7E, 025F8E, 02601C, 02602A `movea.l d2,a5` |
| 02A302, 02A30A, 02A31A, 02A322, 02A334, 02A33C (D3) | address | the starts of two strings of 0475CA-0475FB, picked by the switch at 02A2F6; D3 pushed next to a `pea` of text at 02A490, 02A49C, 02A4BC, 02A4C8, 02A4DC |
| 03152A (D3), 03163E (D4), 031644 (D5) | address | moved into an address register at 0315EE, 0317CA, 031706 |
| 03164A (into -4(A6)) | address | the same value as 031644 and 03152A load; sub_30F9C reads the local back as a table base: 031800 `movea.l (-$4,a6),a1`, then 031806 `move.w ($0,a1,d0.w),d1` with D0 = (character - 41h) x 2 |
| 03F572, 03F5C6, 03F61A, 03F66C, 03F6BE (D5) | address | pushed as the source argument of `copy_to_zram` 022578 next to the ZRAM address in D4 |
| 040F66 (D3) | address | 040F9E `movea.l d3,a1`, 040FCA, 040FDC, 041010 `movea.l d3,a5` |
| 02FC76 (`#$80000` into D5) | constant | a countdown: 02FC8E-02FC92 `move.l d5,d0`, `subq.l #1,d5`, `tst.l d0` |

The decided addresses gave the generator 31 more labelled operands, and so some more cuts in the
island and the data (`dat_461F0`, `dat_466A0`, ...). The lint now lists 337 constants (336 + the
countdown) and no undecided operand.

## 6. How a naming leg works on its file

1. Own one or more files of section 2.1 (the issue says which). Rename in place: a label and
   every use of it (other files use it too: search the tree), an equate in `ram.asm` and its
   uses. Comment in the source. A name claims a role only with evidence (CLAUDE.md section 2).
2. Never run the generator over the tree (it refuses); edit by hand. A file may be split further
   at routine starts or renamed after what its code is, with its guards and the include list of
   `stunrun.asm` (and `tools/test_68k_tree.py`'s `REGIONS`) updated.
3. Turning blob into source: replace an `incbin` slice by source only for explained bytes (text,
   pointers, a table with a documented format) and keep the rest as narrower slices with labels
   (decision C3); the raw-data check refuses a `dc` statement of another kind in the code files,
   so a new explained kind is added to the check with its argument. Promoting an `unknown` range
   to code needs a reviewed seed in `data/68k/seeds.json` (C8) and `make classify`.
4. After each change: `make check` (0 differences; `touch` the file first, make 3.81 compares
   whole seconds), `make m68k-check` (labels, descent, lint, raw data, shift, MAME, unidasm),
   `make coverage MAX_BLOB="asm/68k/<file>=N"` and `make test`.
5. A name that corrects or adds to the IDA snapshot goes into `ida/code_map.py` or the snapshot
   in the same PR, so that `make labels` compares it (docs/13 section 7); the IDA side follows
   with M7's sync.

## 7. Findings

- **020DB4 is classified as text starting with `Nu`** (`str_20DB4`, `dc.b 'Nu ABCD...',0` in
  `game/code_020430.asm`): 4E75 is `rts`. The unknown range before it, 020D56-020DB4, "decodes as
  36 instructions, then stops" at that boundary, and the unknown range after the text,
  020DE1-020ED0, decodes from the even address 020DE2. HYP: 020D56-020DB6 is an unreferenced
  routine ending with that `rts`, the string is the character set " ABCDEFGHIJKLMNOPQRSTUVWXYZ
  0123456789:;<..." from 020DB6, and 020DE1 a pad byte. The bytes are the same either way; the
  game naming leg decides it (the text rule of docs/14 section 2.5 does not look at the bytes
  before a run).
- The listing parser of `tools/m68k` cut a statement at a `;` inside a quoted string (020DB4's
  string holds one), which made that `dc.b` look like something else to the checks; it now
  ignores a `;` between quotes.
- `asm/68k/hardware.asm`'s header and docs/13 still named `boot/ram.asm` and `game/ram.asm`
  (wave 0's plan); both now name `ram.asm` (decision C9). docs/13's coverage gate example named
  `game/code.asm`; it now names a file of this layout. docs/04 section 1 and the usage of
  `tools/coverage` still name wave 0's `boot/boot.asm` and `game/code.asm`; neither file is this
  leg's (section 8).
- The boot program's screen records (4-byte header column, row, attribute, count; no terminator)
  and the game's option records (an item byte before each title) are record formats the text
  rule had not known; the leg's first tree committed the counts, attributes and item bytes of
  81 strings and 64 bytes of three island tables as characters (section 3.1, found in review).

## 8. Open questions

1. The unreferenced ranges that decode cleanly (C8) and the classification's reading of 020DB4
   (section 7): the naming legs'.
2. ZRAM equates are named `io_FF4XXX` by the generator's rule; a later leg may prefer `zram_X`
   (a rename in `ram.asm` and its uses).
3. docs/04 section 1 and `tools/coverage`'s usage still name wave 0's `boot/boot.asm` and
   `game/code.asm` (`make coverage MAX_BLOB="asm/68k/game/code.asm=0"`, the usage's example,
   fails with "no listing has the file"); neither file is in issue #33's list.
4. The 24 zero bytes at 020400 are a fill under `dat_20400` although the classification says
   data (section 2.1): the alternative is an incbin slice (24 more blob bytes, the fill count of
   wave 0 changed).
