# The 68k source tree

**Date**: 2026-11-16 (milestone 5, wave 0, leg M5-0, issue #28). How `asm/68k` is cut into region
files, one per later owner, what is already source in it, the conventions every later leg
writes in, and the two checks that measure a leg: `make coverage` (with a per-file blob gate) and
`make labels`. The partition is docs/06-code-map.md section 4's, checked against the image here.

## 1. What changed in this leg

Before: `asm/68k/stunrun.asm` was `org 0` and eight `incbin`s (pair R in three pieces around the
ADSP and GSP programs, then pairs S-W). After:

- `asm/68k/stunrun.asm` is `org 0`, `include "hardware.asm"`, the nine region files in address
  order and one final `assert *=$0C0000`.
- The six zero runs (94,883 bytes) are `dcb.b` fills; the program table's two pointers are
  `dc.l adsp_program` and `dc.l gsp_program` and its text a `dc.b` string (36 bytes of data).
- `asm/68k/hardware.asm`: the 17 I/O equates of docs/01 section 3, with ida/memory_map.py's
  names.
- `asm/nvram/nvram.asm`: both NVRAM images are zero and are now two `dcb.b` fills (section 8).
- `make labels` (`tools/labels`), the coverage gate `--max-blob` (`make coverage MAX_BLOB=...`),
  `tools/test_68k_tree.py`.

No byte of the set changed: `make check` gives 25 files, 0 differences.

## 2. The files

| File | Range | Bytes | Today | Owner |
|---|---|---|---|---|
| `boot/vectors.asm` | 000000-000212 | 530 | incbin: the boot vector table (`vec_reset_sp`, 256) and the 274-byte block after it (`dat_100`) | boot leg |
| `boot/boot.asm` | 000212-012F06 | 77,044 | incbin: boot code with data islands (`boot_line_a_etc`, 76,724) and the boot data (`dat_12DC6`, 320) | boot leg |
| `programs.asm` | 012F06-020000 | 53,498 | fill to 017000; the program table (section 3); the ADSP and GSP programs as incbins of `build/adsp/program.bin` and `build/gsp/program.bin`; fill to 020000 | M5-0 (table, fills), M6 (the two programs) |
| `game/vectors.asm` | 020000-020430 | 1,072 | incbin: the game vector table (`game_vec_reset_sp`, 256), `game_entries` (18); fill 020112-020418; incbin `dat_20418` (24) | game leg |
| `game/code.asm` | 020430-04397E | 144,718 | incbin (`sub_20430`) | game leg |
| `game/island.asm` | 04397E-046AEE | 12,656 | incbin: the data island (`dat_4397E`, 12,418) and the last code (`sub_46A00`, 238) | game leg |
| `data.asm` | 046AEE-060000 | 103,698 | incbin (`dat_46AEE`, 91,288); fill 05CF86-060000 | data leg |
| `images.asm` | 060000-0BFE00 | 392,704 | since M5i (docs/15): `dat_60000`, the include `build/gsp-images/images.asm` generated from `data/gsp-images` (54 streams, 3 computed adjust words, 332,011 bytes of data); fill 0B10EB-0BFE00 | images leg |
| `image_table.asm` | 0BFE00-0C0000 | 512 | since M5i: `tbl_BFE00`, the include `build/gsp-images/table.asm` (70 `dc.l`, 280); fill 0BFF18-0C0000 | images leg |

Every region file is one contiguous range and starts and ends with an `assert *=$addr`; a file
may assert more inside (`programs.asm` asserts the table and both programs). Paths of `include`
and `incbin` are relative to the main file's directory (`asm/68k`), also in the files under
`boot/` and `game/`: vasm resolves both against the main source's directory, so an incbin in
`game/code.asm` is written `"../../build/stunrun-68k.bin"` like one in `stunrun.asm` (verified on
vasm 2.0f).

The pair boundaries are not file boundaries: `game/code.asm` crosses 040000 (S/T) because
`sub_3FEA6` runs from 03FEA6 to 040488 (`data/ida/stunrun-68k.functions.jsonl`, checked by
`tools/test_68k_tree.py`), and `images.asm` crosses 080000 and 0A0000 (U/V/W), which are not
image boundaries.

Decision C1 (coordinator, 2026-11-16): this layout. A later leg may split its own file into
several under its directory (included from its file, guards at each boundary); it never moves a
boundary between owners.

### 2.1 The boundaries against the image

Measured on `build/stunrun-68k.bin` (merged from the reference set) by a scratch script: each of
the six ranges is all zero, and each is the whole zero run between its neighbours except where a
neighbour's last or first bytes are themselves zero (the run is then longer than the fill, and
the zero bytes stay with the neighbour, whose format explains them):

| Fill | Bytes | Maximal zero run in the image | The extra zero bytes |
|---|---|---|---|
| 012F06-017000 | 16,634 | 012F06-017001 | 017000: the high byte of `adsp_program_ptr` (01702E) |
| 01EFD4-020000 | 4,140 | 01EFD4-020005 | 020000-020004: the first five bytes of the game vector table (`game_vec_reset_sp` and the high byte of vector 1) |
| 020112-020418 | 774 | 020112-020419 | 020418: the first byte of `dat_20418` |
| 05CF86-060000 | 12,410 | 05CF86-060000 | none |
| 0B10EB-0BFE00 | 60,693 | 0B10EB-0BFE05 | 0BFE00-0BFE04: entry 0 of the image table (0) and the high byte of entry 1 |
| 0BFF18-0C0000 | 232 | 0BFF14-0C0000 | 0BFF14-0BFF17: entry 69 of the image table, the 0 that ends it |

So docs/06 section 4's partition stands as it is; no boundary moved. The program table's
pointers are 01702E and 01907C, and its text is "Copyright 1989 ATARI GAMES" followed by two
zero bytes, as docs/06 section 2 says.

## 3. The program table, 017000-01702E

| Address | Label | Source | Why |
|---|---|---|---|
| 017000 | `adsp_program_ptr` | `dc.l adsp_program` | read at 02C204 for `load_adsp_program` |
| 017004 | `gsp_program_ptr` | `dc.l gsp_program` | read at 02C1B6 and 02DCB0 for `load_gsp_program` |
| 017008 | `program_table_long_8` | incbin, 4 bytes | no reader, not a sum or CRC (docs/06 section 2): residue |
| 01700C | `program_table_long_c` | incbin, 4 bytes | no reader: residue |
| 017010 | `copyright_text` | `dc.b "Copyright 1989 ATARI GAMES",0,0` | text; HYP: NUL-terminated and padded to a word |
| 01702C | `dat_1702C` | incbin, 2 bytes | no reader: residue |

The pointers are the labels of the two programs, so the table follows them if M6 changes their
size; `tools/extract-programs` still checks the same two values in the merged image. The three
unexplained slices (10 bytes) stay blob under the residue rule (CLAUDE.md section 5, card A2): a
word the format does not explain is not committed as a number without Jesus's say-so. Checked
(scratch script) whether they are the programs' lengths or end addresses (0x204E, 0x5F58, their sum,
01907C, 01EFD4, as a long or either half): none is.

## 4. Conventions (decision C2, coordinator, 2026-11-16; binding for every later leg)

- Motorola syntax, lower-case mnemonics and registers; every branch carries its size (`.s` or
  `.w`); absolute short operands are written with `.w`, absolute long without a suffix;
  PC-relative operands name the target label. The tree is assembled with `-no-opt`, so what is
  written is what is emitted.
- Neutral labels are IDA's own spelling: `sub_20430`, `loc_26CD2` (no zero padding, upper-case
  hex); data `dat_XXXXX`, tables `tbl_XXXXX`, strings `str_XXXXX`; vasm locals `.lXXXXX`.
  Names with evidence come from `ida/code_map.py` and the snapshot `data/ida/stunrun-68k.json`.
- Decision C3: a blob is always an `incbin` of `build/stunrun-68k.bin` with offset and length,
  never of the archive; bytes become `dc` statements only when they are explained (text,
  pointers, fills, tables with a named format). A `dc.b` wall transcribing an unexplained blob is
  not source.
- Every blob carries a label at its first byte, the snapshot's name there when it has one
  (`vec_reset_sp`, `boot_line_a_etc`, `game_vec_reset_sp`, `game_entries`), otherwise a neutral
  one by the rule above (`dat_100`, `dat_12DC6`, `dat_20418`, `sub_20430`, `dat_4397E`,
  `sub_46A00`, `dat_46AEE`, `dat_60000`, `tbl_BFE00`); `make coverage` names blobs by it.
- I/O addresses are the equates of `hardware.asm`; RAM equates go to `boot/ram.asm` and
  `game/ram.asm` (the boot and game legs). Macros are `macros.asm` (leg M5g, docs/14).

## 5. How a leg converts its file

1. Take the file's blob(s) apart at the boundaries the leg explains: replace an `incbin` by
   source for the explained part and keep the rest as narrower `incbin` slices of
   `build/stunrun-68k.bin` (offset and length), each with its label. Add guards
   (`assert *=$addr`) wherever a mismatch would otherwise be found late.
2. `make check` must stay at 0 differences at every commit (`touch` the file or wait a second
   after a scripted edit: make 3.81 compares whole-second mtimes, and the 68k tree reassembles by
   mtime, docs/04 section 1).
3. `make coverage MAX_BLOB="asm/68k/<file>=0"` (or the bytes the leg leaves as documented
   residue) is the leg's coverage acceptance (section 6).
4. `make labels` must pass: every snapshot name in the converted range is a label at its address
   (section 7).
5. The leg's names and comments go into the source; the IDA side follows later (`make ida-sync`
   for the 68k is M7's, docs/03).

## 6. Coverage

`make coverage` (2026-11-16, after this leg). vasm names an included file as the `include`
wrote it, relative to the main file's directory; `tools/coverage` now prints it relative to the
repository (`asm/68k/game/code.asm`; the generated object and OKI sources become
`build/obj/page0.asm` and `build/oki/samples.asm`, where they were `../../build/...`):

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `asm/68k/boot/vectors.asm` | 530 | 0 | 0 | 530 | 0 |
| `asm/68k/boot/boot.asm` | 77,044 | 0 | 0 | 77,044 | 0 |
| `asm/68k/programs.asm` | 53,498 | 0 | 36 | 32,688 | 20,774 |
| `asm/68k/game/vectors.asm` | 1,072 | 0 | 0 | 298 | 774 |
| `asm/68k/game/code.asm` | 144,718 | 0 | 0 | 144,718 | 0 |
| `asm/68k/game/island.asm` | 12,656 | 0 | 0 | 12,656 | 0 |
| `asm/68k/data.asm` | 103,698 | 0 | 0 | 91,288 | 12,410 |
| `asm/68k/images.asm` | 392,704 | 0 | 0 | 332,011 | 60,693 |
| `asm/68k/image_table.asm` | 512 | 0 | 0 | 280 | 232 |
| **stunrun-68k** | **786,432** | **0** | **36** | **691,513** | **94,883** |
| `asm/nvram/nvram.asm` | 4,096 | 0 | 0 | 0 | 4,096 |

The 68k blob fell by exactly the bytes converted: 786,432 - 94,883 (fills) - 36 (table) =
691,513; the NVRAM's 4,096 bytes are fills. The set: `blob: 45.8% of 1511424 bytes come from
incbin/.binary` (691,513 blob bytes, all in the 68k image; 790,528 before this leg, 695,609
with the NVRAM still an incbin). `programs.asm`'s blob is the two programs (8,270 + 24,408, M6's) and the 10 residue bytes.

The gate: `tools/coverage --max-blob FILE=BYTES` (repeatable; through make,
`make coverage MAX_BLOB="asm/68k/game/code.asm=0 asm/68k/data.asm=0"`) fails when the file has
more blob bytes than BYTES, or when no listing has that file (a misspelt path never passes). It
prints `OK FILE: N blob bytes, at most M` for each gate that holds. The Makefile sets no gate by
default: parallel legs would otherwise edit the same Makefile line; each leg runs it with its own
file and states the command in its PR. `tools/test_coverage.py` tests the gate on a hand-written
listing, `tools/test_build.py` through `make coverage MAX_BLOB=...` on the synthetic build.

## 7. `make labels`

`tools/labels` reads the 68k listing (`build/stunrun-68k.lst`: the statements with their
addresses and classes, and vasm's "Symbols by name" table) and the committed snapshot
`data/ida/stunrun-68k.json`. For every user name at a ROM address (000000-0BFFFF):

- **label**: the tree has a label of that name at that address (in source or at a blob's start);
- **in blob**: the address lies in an `incbin` and no label of that name is there: not checked
  yet, counted;
- **failure**: the address lies in source (instructions, data or fills) and no label of that
  name is there; or a label of that name is at another address; or no statement holds the
  address.

Names at I/O, ZRAM and RAM addresses are counted as outside ROM (the I/O equates are checked by
`tools/test_68k_tree.py`, section 9). Today, on the reference build and on the synthetic one:

```
labels: 223 snapshot names in ROM: 11 labels in the tree, 212 in blob, 0 failures; 31 outside ROM (I/O, ZRAM, RAM: not checked here)
```

The 11 labels: `vec_reset_sp`, `boot_line_a_etc`, `adsp_program_ptr`, `gsp_program_ptr`,
`program_table_long_8`, `program_table_long_c`, `copyright_text`, `adsp_program`, `gsp_program`,
`game_vec_reset_sp`, `game_entries`; three of them (`adsp_program_ptr`, `gsp_program_ptr`,
`copyright_text`) are in source, the rest name the start of a blob. `-v` lists the 212 names in
blob. It needs only a listing, so it runs without the reference set: `tools/test_build.py` runs
`make labels` on the synthetic build in CI, and `tools/test_68k_tree.py` runs the check on the
tree assembled against a random blob and shows that a label removed from source fails it. The
snapshot is the input, not the output: when a leg's evidence disproves an IDA name, the leg
corrects `ida/code_map.py` (or the snapshot through IDA) in the same PR, so that the check
compares the corrected name.

## 8. The NVRAM images

`stunrun.200e` and `stunrun.210e` (2,048 bytes each) are identical, as docs/01 section 2 says,
and both are entirely zero: blank chips (measured on the reference set; the count of zero bytes
is 2,048 in each). The 68010 sees them interleaved as ZRAM at FF4000-FF4FFF (high byte 200e, the
M48T02, low byte 210e, the 2816 EEPROM; docs/01 section 3) and writes them at run time
(`copy_to_zram` 022578; `game_reset` counts restarts at FF4B90, 02EFB6, `ida/code_map.py`);
every MAME run of this repository starts from these images (an empty private
`-nvram_directory`), and the game boots from them. A zero run is a fill by the same rule as the
68k image's six zero runs, so `asm/nvram/nvram.asm` is now two `dcb.b $0800,0` with their guards
and the NVRAM tree includes nothing from `build/` (the Makefile's `EXTRA_stunrun-nvram` is
empty). How the game lays out ZRAM (the option words, the high scores, the checksums) is not
studied here; it belongs to the game leg (docs/03, M5).

## 9. The tests

- `tools/test_68k_tree.py` (CI): the includes of `stunrun.asm` are `hardware.asm` and the nine
  region files in address order, each file's first and last guards are its range and the ranges
  tile 000000-0C0000; the six fills are the documented 94,883 bytes, each inside one file;
  exactly one snapshot function crosses 040000 (`sub_3FEA6`); `hardware.asm`'s equates are
  `ida/memory_map.py`'s `IO_68K`, same names, same addresses, same order, each citing a docs/01
  row that exists with that start address. With vasm (CI has it): the tree assembled against a
  random blob gives the blob with the fills zero and the table's pointers and text in place, the
  labels at the table's addresses; a byte inserted into `game/code.asm` fails its end guard;
  `tools/labels` passes on the tree and fails when `gsp_program_ptr:` is removed.
- `tools/test_build.py` (CI): the synthetic set's 68k image is what the tree assembles from a
  random blob with a valid program table (the fills zero, the pointers as the tree computes
  them), its NVRAM images zero; `make all` rebuilds it, `make coverage` gives the numbers of
  section 6 with one row per region file, the gate fails and passes as it should, `make labels`
  passes, a planted byte in the blob is reported at its 68k address, and an edit of
  `programs.asm`'s text (017010) is reported as `136070-2102.200r ... = 68k $017010`.
- `tools/test_coverage.py` (CI): the listing helpers (`vasm_symbols`, `vasm_statements`,
  `repo_path`) and the gate.

Planted one-byte changes against the reference set (`make check`, then restored, 0 differences
after): 00A001 in `boot/boot.asm`'s blob (`136070-2101.210r ... = 68k $00A001`), 041234 in
`game/code.asm`'s (`136070-6106.200t ... = 68k $041234`), 046AF0 in `data.asm`'s
(`136070-6106.200t ... = 68k $046AF0`), and a source edit of `data.asm` (one `dc.b 1` before its
fill, the fill shortened by one) at 05CF86 (`136070-6106.200t ... = 68k $05CF86`).

## 10. Open points

- The three residue slices of the program table (017008, 01700C, 01702C): what they are, and
  whether Jesus wants them as named constants (card A2's form) or left blob until explained.
- The NVRAM fills (section 8) were not in this leg's file list (issue #28's acceptance list
  names `asm/68k/**`); the issue's scope item 7 allows converting it when the content is
  explained. If Jesus prefers the incbin until the game leg documents ZRAM, the change is one
  file and the Makefile's `EXTRA_stunrun-nvram`.
- Stale text outside this leg's files: `ida/code_map.py` (and through it the snapshot's comments
  at 01702E and 01907C), `tools/extract-programs` and `tools/programs.py` still say
  `asm/68k/stunrun.asm` where the two programs are now in `asm/68k/programs.asm`.
