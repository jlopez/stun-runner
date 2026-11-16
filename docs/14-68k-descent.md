# The 68k descent, the classification and the source generator

**Date**: 2026-11-16 (milestone 5, leg M5g, issue #29). How the 68010 code of the 68k image is
told from its data, the committed classification of 000000-05CF86 that results, the one-shot
generator that turns a region into byte-identical neutral vasm source, the checks a code leg runs
on its source, and MAME's coverage of the 68010. Addresses are 68010 addresses (= offsets in
`build/stunrun-68k.bin`). **CODE** means read off the instructions at the addresses given,
**MAME** a run of `make pccov` (MAME 0.289), **HYP** a hypothesis.

## 1. Why a descent

Byte identity cannot tell code from data: data decoded as instructions and written back as
instructions reassembles to the same bytes, and so does an address written as a number. The
committed IDA snapshot is no help for the boot program (12,080 bytes of instructions, 64,632
unexplored) and wrong in places (section 9). So the classification needs its own evidence, and
every operand that could be an address needs a decision and a machine check. The tools live in
`tools/m68k` (a package run as `uv run python tools/m68k <command>`); their CI tests are
`tools/test_m68k.py`.

| Module | What |
|---|---|
| `decode.py` | a 68010 decoder in Python: lengths, structured operands, control flow, vasm text |
| `descent.py` | the recursive descent and its idioms |
| `classify.py` | the stages of seeds, the classification of every byte, the file format |
| `operands.py` | the decisions on long immediates |
| `gen.py` | the one-shot generator |
| `listing.py` | the listing-based checks: descent check, address lint, shift test |
| `pccov.py` | MAME's executed PCs, the checker and the summary |

## 2. The method

### 2.1 The decoder

CI has vasm only, so the descent cannot use unidasm or IDA; `decode.py` decodes the 68010 itself
(no tables taken from a disassembler). It is strict on purpose: a decode is "not code" for line A
and line F, every 68020 form (`bcc.l` with displacement FF, `chk.l`, `mul.l`/`div.l`, a full
extension word or a scale factor, the bit-field instructions), every addressing mode the
instruction does not allow on the 68000/68010 (e.g. `cmpi.w #N,(d16,PC)`, which unidasm decodes
and which the scout saw only in false code; `tst An`; byte operations on An), a `movec` control
register the 68010 does not have, and a byte immediate whose extension word's high byte is
neither 00 nor a sign extension (FFxx with bit 7 of xx set). Checks:

- On the 40,210 instruction heads of IDA's code (the scout's unidasm dump), every one decodes, with
  unidasm's length; formatted as vasm text and reassembled over the image, they give the image back
  but for the ten FFFF byte immediates of section 5.2.
- `tools/m68k check-unidasm` (local): every instruction boundary of the classification's 183 code
  ranges equals unidasm's linear decoding of the range, **44,658 boundaries, 0 ranges differ**.
- `tools/test_m68k.py::test_decoder_round_trip` (CI): about 200 instruction forms covering every
  decoder path are assembled by vasm; each decodes to its statement's length and the decoder's
  text assembles back to the same bytes. `test_not_code` (CI): the forms above decode to nothing.

### 2.2 The descent

A seed's descent is a transaction (`Descent._descend`): it follows every static flow (the
fall-through, `bcc`/`bra`/`dbcc` targets, `jsr`/`jmp`/`bsr` with an absolute or PC-relative
target), and it is committed only if every instruction reached decodes, lies inside the
code-eligible ranges (000100-017000 and 020100-046AEE: pair R below the program table, the
game's entry table and pairs S-T up to the data, docs/06 section 4), does not overlap an
instruction committed at another boundary or a table, and every static target it needs does the
same. Otherwise the whole seed is rejected with its reason. Two things are separate, later
transactions, so that a wrong guess cannot poison the code that led to it: the fall-through after
a call (a call that never returns is followed by data; none was found in this ROM: the
classification's `noreturn` list is empty) and every idiom target (section 2.3).

### 2.3 The idioms

| Idiom | Recognised as | Example (CODE) | In this ROM |
|---|---|---|---|
| C switch | `move.w (T,pc,dN.w),dN` directly before `jmp (B,pc,dN.w)`; the word table starts after the `jmp`, target = B + entry; the first case lo = (table - T) / 2; the last from the bound check before it: `cmp(i) #V,dN` with `bhi`/`bgt` (or `bcc`/`bge`, V - 1), or `moveq #V,dM` / `cmp dN,dM` with `blt`/`bcs` (`ble`/`bls`), less any `sub #K,dN` between; without a bound, up to the lowest target | 026CC6 `cmpi.w #$B,d0`, 026CCA `bhi.s`, 026CCC `add.w d0,d0`, 026CCE `move.w (026CD2,pc,d0.w),d0`, 026CD2 `jmp (026CD6,pc,d0.w)`: cases 2-11 at 026CD6-026CEA (T is the `jmp` itself, two words before the table); 025704 `moveq #8,d0` / 025706 `cmp.l d1,d0` / 025708 `blt.w`; 0380B6 `sub.w #$C7,d0` after the compare at 0380B0 | 33 switches, 780 bytes of tables, 194 cases; every `jmp (d8,pc,Xn)` of the code is one |
| computed call | an address register set to a constant (`lea abs`/`lea (d,pc)`, `movea.l #`, then `adda`/`suba`/`addq`/`subq`/`lea (d,An)` on it) and used by `jsr`/`jmp (An)` or `(d,An)` in the same straight line | 0223E0 `lea $441EC,a0`, 0223E6 `adda.l #$404,a0`, 0223EC `jsr (a0)`: 0445F0 | 4 entries |
| code-pointer table | an address register set to a table base, a long loaded through it with an index (`movea.l (d,An,Xn)`, `movea.l (d,pc,Xn)`) or without (`movea.l (An)`, `(d,An)`), then `jsr`/`jmp (Am)`; the longs are taken while each one descends cleanly | 0010A8 `lea $FA2,a0`, 0010B4 `movea.l (0,a0,d0.w),a0`, 0010B8 `jsr (a0)`: the boot menus' table at 000FA2 | 12 tables (000E16, 000FA2, 001136, 00173A, 001840, 001B3A, 008D60, 00B47A, 00C0FC, 00C340, 00D2CA, 00DCE6), 103 entries |
| return address | the boot program runs without a stack and calls with `lea ret,An` then `bra`/`jmp`; the callee returns with `jmp (An)`: a register holding the address right after an unconditional branch | 005072 `lea (507A,pc),a0`, 005076 `bra.w 53F2`; 00953A `lea $954A,a2`, 009540 `movea.l #0,a0`, 009546 `bra.w 95A2` | 150 entries |

The register tracking forgets a register at anything that may change it (a call, `movem`, `exg`,
a write, `(An)+`/`-(An)`), and it follows only the fall-through, never a branch.

### 2.4 The stages and the evidence

`classify.py` runs the seeds in stages; every entry not reached by plain descent carries the
evidence of the stage that added it (`entries` of the file):

1. plain seeds: the vectors 1-63 of both tables (000000 and 020000; vector 0 is the stack) and
   `game_entries` (020100, 020106, 02010C), with the idioms as they come;
2. code-pointer runs in data: a run of at least three aligned longs outside code, all into the
   code ranges, at least two and at least half of them at routine starts already decided (call
   targets or entries); the others are seeded. This stage adds nothing in this ROM;
3. MAME: every PC the `make pccov` runs executed (section 7);
4. reviewed seeds: `data/68k/seeds.json`, an address and a written argument each. It also lists
   `untaken` branches, whose static target the descent does not follow, each with its argument.
   Today: no seed and one untaken branch, the `dbf d2` at 004B74 (section 9).

What is not a seed, and why: an address loaded by `movea.l #` alone (a callback, or a data table:
the synthetic test program has a table loaded with `movea.l #` whose words decode cleanly up to an
`rts`, and this rule made it code; the three such loads of this ROM that do point to code,
030C0E, 03C1DC and 04154E, are executed in MAME and come in through stage 3); `pea X.l` and
`move.l #X` (mostly constants: 0x10000, 0xFFFF and the like are even addresses in the boot
range); a long in data that merely points into the code ranges.

### 2.5 The bytes that are not code

After the descent, `classify.py` gives every other byte one kind: the vector tables and the
code-pointer tables are `pointers`, the switch tables `switch`, and the code map's ranges keep
their kind (the program table's two pointers at 017000, the ADSP and GSP streams 01702E-01EFD4 as
`data`). Over the rest:

- **text**: a printable run of at least six characters, nine in ten of them letters, digits,
  blanks or the punctuation of messages, half of them letters, with a word of four letters of one
  case (code is often printable: `4E71 4E71 4E75` reads "NqNqNu"), cut where an operand points (a
  string starts there), with its terminating zero;
- **fill**: a run of at least 32 zero bytes, up to the first address an operand references (the
  game's 020112-020418 becomes fill to 020400 and data from there: `movea.l #$20400,a2` at 042356
  is a base, 020418 the table it indexes, HYP);
- **data**: from an address an operand references (absolute, PC-relative, a `movea.l #`; not
  `pea N.w`) to the next boundary, with the first referencing instructions in the note;
- **unknown**: the rest. In a code range the note says when the bytes decode cleanly as
  instructions to a `rts`/`rte`/`jmp`/`bra` and which IDA functions start there.

## 3. The classification

`data/68k/classification.json` (format `stunrun-68k-classification 1`, about 180 KB, one range or
entry per line): `ranges` (start, end, kind, note; a switch also its `jmp` and `base`) cover
000000-05CF86 with no gap and no overlap (`validate`, in CI); `entries` (address, evidence) the
454 entries that plain descent does not reach; `noreturn` the calls whose fall-through is not code
(none). Addresses, kinds, notes and evidence only: no byte of the image. `make classify` rewrites
it (with the MAME runs of `make pccov` when present) together with `data/68k/operands.json`.

Bytes per kind and region (`tools/m68k stats`):

| Region | code | switch | pointers | text | data | fill | unknown |
|---|---:|---:|---:|---:|---:|---:|---:|
| boot vectors 000000-000212 | 0 | 0 | 256 | 0 | 0 | 0 | 274 |
| boot code 000212-012F06 | 35,210 | 0 | 420 | 7,618 | 17,284 | 603 | 15,909 |
| programs 012F06-020000 | 0 | 0 | 8 | 27 | 32,678 | 20,774 | 11 |
| game vectors 020000-020430 | 18 | 0 | 256 | 0 | 48 | 750 | 0 |
| game code 020430-04397E | 128,062 | 780 | 0 | 648 | 857 | 39 | 14,332 |
| game island 04397E-046AEE | 262 | 0 | 0 | 125 | 8,317 | 0 | 3,952 |
| game data 046AEE-05CF86 | 0 | 0 | 0 | 8,269 | 79,066 | 349 | 3,604 |
| **total** | **163,552** | **780** | **940** | **16,687** | **138,250** | **22,515** | **38,082** |

44,658 instructions (boot 8,195, game 36,463) in 183 code ranges. Entries with evidence: 194
switch cases, 150 return addresses, 103 code-pointer table entries, 4 computed calls, 3 MAME
(030C8E, 03C18A, 0410C0). Against IDA's 40,210 instruction heads: no boundary conflicts; 6,893
instructions (28,442 bytes) are code here and not in IDA, 2,445 IDA heads (7,162 bytes) are not
code here (IDA functions nothing references, below).

What is not decided, and why:

- **Unreferenced routines.** 75 unknown ranges inside the code ranges, 10,365 bytes, decode
  cleanly to a `rts` (or `bra`) and nothing references them; 11 of them hold an IDA function
  (3,340 bytes: e.g. 02D382-02D706, where `copy_adsp_dram_to_18000` 02D6D8 lies, docs/06 section
  4.5; 02C9E4-02CCD8; 02D80E-02DA6E). They are most likely dead C functions, but nothing in the
  image or in MAME proves it, so they stay `unknown` (issue #29: "do not guess") and become
  `incbin` slices. A reviewed seed in `data/68k/seeds.json` with its argument makes one code.
- **Dead instructions** such as 02045A (four bytes between a `bra.s` at 020458 and its target,
  a `bclr #5,d2`): `unknown`.
- **The rest of the unknown bytes** (24,102 in the code ranges, 274 of them at 000100-000212;
  3,604 in the data; 11 in the program table) do not decode cleanly or are tables of no known
  format: the boot program's menu
  records (a few control bytes, among them a row and a length, before each string, e.g. at
  006800) are `text` for their strings and `unknown` for the bytes around them, as their format
  is the boot leg's.

## 4. The operand decisions

A long immediate in 000100-0BFFFF may be an address or a number (`#$47406` either way). Every
one of the code (740) gets a decision in `data/68k/operands.json` (instruction address, operand
index, decision, rule; no value), the first rule that matches:

| Rule | Decision | When | Count |
|---|---|---|---:|
| R1 | address | `movea.l #X,An`: a value loaded into an address register | 339 |
| R2 | address | X = 0BFE00, the image pointer table, added to an index (docs/06 4.2) | 9 |
| R3 | address | `move.l`/`pea` of a routine start (a callback) | 8 |
| R4 | address | `move.l` of X >= 020000 that other instructions use as an operand | 11 |
| R5 | constant | `and`/`or`/`eor`: a mask | 104 |
| R6 | constant | `add`/`sub`/`cmp` and their forms, `mul`/`div`: an arithmetic operand | 136 |
| R7 | undecided | `move.l` of X >= 04397E (the island, the data, the images) | 32 |
| R8 | constant | `move.l` of a smaller X: a count, a delay, a fixed-point value | 101 |

The 32 undecided (`move.l #X` into memory with X in the data or the images: a data pointer or a
large 16.16 number) are at 02444E, 0245F8, 024FA8, 025E9C, 026F12, 028476, 02A302, 02A30A,
02A31A, 02A322, 02A334, 02A33C, 02DCCC, 02FC76, 03152A, 03163E, 031644, 03164A, 031F92, 03F572,
03F5C6, 03F61A, 03F66C, 03F6BE, 0405B0, 040620, 0407E6, 04084C, 0408C6, 0409D4, 0409F6, 040F66.
The generator writes them as numbers and the address lint reports them apart; the game data leg,
which will know what lies at each X, decides them (docs/06 names 0461F0 from 02444E as an IDA
cross-reference, which decision C5 does not trust).

## 5. The generator

`tools/m68k gen START END --out FILE [--equates-out FILE] [--externals-out FILE]
[--equates asm/68k/hardware.asm] [--incbin PATH]` writes vasm source for a range from the image,
the classification, the operand decisions, the IDA snapshot (names and function starts only,
decision C5) and the hardware equates (`--equates`, a vasm file of `NAME equ $X`; without it the
names of `ida/memory_map.py`'s `IO_68K`, the same spelling). **It is one-shot scaffolding**: a
code leg runs it once over its region and commits the output; from then on the source is the
truth, and the generator is frozen and never runs over a hand-edited file (its header says so).

### 5.1 What it writes

| Kind | Source |
|---|---|
| code | instructions in decision C2's conventions; flow targets and PC-relative operands as labels; absolute operands in 000000-0BFFFF as labels (`.w` kept for absolute short); I/O and RAM operands as equates; long immediates as section 4 decides; `pea N.w` always a number |
| switch | `dc.w case-base`, one per entry (the base is the table start) |
| pointers | `dc.l label`; 0 and values outside the ROM as numbers (the stack vector `$FFFFC000`) |
| text | `dc.b 'string',0` (`"..."` when the string holds a `'`: vasm has no escapes) |
| fill | `dcb.b n,0` |
| data, unknown | `incbin "<image>",$offset,$length`, split where a label is needed (decision C3) |

Labels: a name the snapshot has at the address, verbatim; else `sub_X` where a routine starts (a
call target, an entry with evidence, a vector or pointer-table target, a snapshot function
start), `loc_X` for another code label reached from another scope, `.lX` (a vasm local) for a
code label or a switch table whose every reference lies between the same two global labels
(computed to a fixed point over the whole image, so every range agrees), `tbl_X` for pointer
tables, `str_X` for each string, `dat_X` for data, unknown bytes and fill. X is IDA's spelling:
upper-case hex, no padding. Every range start and every code range start that does not follow a
switch table is global. An operand into an instruction or table entry is `label+n`. Equates: a
snapshot name for RAM (`game_options`), an `IO_68K`/hardware name plus an offset inside the same
segment (`PORT0+$1`, `ADSP_CONTROL+$1C`), else `ram_FFXXXX` (FF8000 up) or `io_XXXXXX`.
`--equates-out` writes the equates the source uses that the given file does not define;
`--externals-out` the labels it uses and does not define (`name equ $X`, for assembling one range
alone in scratch: in the tree another file defines them).

### 5.2 vasm encoding traps (vasm 2.0f, `-Fbin -no-opt -m68010`), each with its test

| Trap | What the generator does | Tested by |
|---|---|---|
| `move.b #$FF,<ea>` with the immediate word FFFF (ten in the game: 024350, 0244B2, 02B97C, 03AB90, 03B206, 03D0DE, 041726, 04172E, 04174A, 04174E): vasm writes 00FF and refuses `#$FFFF` | `moveb_ffff_ind n` (`(An)`: 03D0DE, 04174A) and `moveb_ffff_abs addr` (absolute long: the other eight), `asm/68k/macros.asm`, operand symbolic | `test_macros`, the synthetic program |
| absolute short of a RAM equate: error 2033 for `move.w ram_FF9518.w,d0` with the equate 24-bit | `(ram_FF9518-ABS_SHORT).w`, `ABS_SHORT equ $1000000` in `macros.asm`; RAM equates stay 24-bit for the absolute long operands | `test_macros`, the synthetic program |
| an unsized branch assembles as `.w` | every branch carries `.s` or `.w`, from the encoding (`bcc.l` is not 68010) | `test_decoder_round_trip` |
| a `d8(PC,Xn)` written as a raw displacement: error 2030 | the target is written: `(label,pc,d0.w)` | `test_decoder_round_trip` |
| `-no-opt` keeps what is written | `add.l #imm,Dn` (D0BC) and `addi.l` (0680), `cmp.w #imm` and `cmpi.w`, `move.w #0`, `lea (0,a0)`, zero `d16`, `adda.w` all as the encoding has them; an absolute operand without suffix is long (`lea $400,a0` is 41F9) | `test_decoder_round_trip` |
| an absolute short numeric RAM address | `$FFFF8000.w` (the decoder's number form, never needed by generated source) | `test_decoder_round_trip` |
| strings | vasm has no escapes; `''` or the other quote | the synthetic program (`"DON'T PANIC"`) |
| local labels | `.lX` is local to the last global label: the generator promotes a label to `loc_X` when a reference crosses a global label | the synthetic program, the three regions |

### 5.3 The listing checks

`listing.py` reads a vasm listing (`-L`: each statement's address and source; the symbol table;
local labels from their definition lines, as vasm does not list them) and the assembled binary.
A statement that invokes a macro of `asm/68k/macros.asm` is one instruction.

- **Descent check** (`descent_check`, `tools/m68k check-listing`): the descent of section 2 over
  the binary, with the instruction statements as its only code ranges, from the source's own
  seeds (every `dc.l` that names an instruction, every `dc.w a-b` whose `a` is one) and the listed
  entries (the classification's evidence entries and reviewed seeds). It fails on a flow into a
  `dc`/`dcb`/`ds`/`incbin` statement or outside the code, an instruction decoded where no
  instruction statement starts or with another length, a call falling through into data unless
  the classification lists it as `noreturn`; it reports every instruction statement not reached.
- **Address lint** (`address_lint`): fails on an absolute operand written as a number in
  000000-0BFFFF (but `pea N.w`, a constant in this ROM by issue #29's decision: 1,695 in IDA's
  code, 1,813 in this classification's), a long immediate or a
  `dc.l` value written as a number in 000100-0BFFFF that the operand decisions do not list as a
  constant; the undecided ones are reported apart. (Word immediates are not checked: none can
  hold a game address; 000000-0000FF is the vector table.)
- **Shift test** (`shift_check`): the source is assembled again with a two-byte pad in front of
  it, so everything it defines moves; exactly the statements that name a symbol inside the range
  other than PC-relatively or as a difference must change, and each changed word by the pad. A
  number that should have been a label, a label pinned by an `equ`, or a PC-relative operand
  written as a number fails it.

## 6. The checks of the three code regions

`tools/m68k check-region START END --work DIR` generates the range, assembles it alone in DIR
(`macros.asm`, the equates, the externals, `org START`) with `vasmm68k_mot -Fbin -no-opt
-m68010`, compares it with the image and runs the three listing checks. A reviewer re-runs it for
the three code regions, and `check-unidasm`, with the reference set merged:

```
make m68k-check        # check-region for each code region into build/m68k/, then check-unidasm
```

| Region | Bytes | Differences | Instructions | Labels (locals) | incbin bytes | Descent check | Lint | Shift test |
|---|---:|---:|---:|---:|---:|---|---|---|
| 000212-012F06 | 77,044 | 0 | 8,195 | 2,163 (775) | 33,193 | 8,195 reached, 0 not, 0 errors | 0 errors, 53 constants | 1,229 changed = expected |
| 020430-04397E | 144,718 | 0 | 36,379 (9 macros) | 3,893 (2,938) | 15,189 | 36,379 reached, 0 not, 0 errors | 0 errors, 288 constants, 32 undecided | 2,372 changed = expected |
| 04397E-046AEE | 12,656 | 0 | 81 | 32 (5) | 12,269 | 81 reached, 0 not, 0 errors | 0 errors | 0 changed = expected |

`make test` runs the same per region (`test_regions_reassemble`, skipped without the image).

## 7. MAME coverage

`make pccov` (`tools/mame/pccov.lua`) runs MAME headless under `-debug -debugger none`, each run
from an empty private NVRAM and cfg state. The debugger's `trace` command writes every executed
68010 instruction (`noloop` folds tight loops) into a named pipe, which `tools/m68k pccov-read`
drains into the set of distinct PCs (a trace file would take gigabytes: the attract run traces
70 million lines); `tools/m68k pccov` then fails unless every executed PC is the start of a code
instruction of the classification, and writes `artifacts/pccov-summary.json` (per run the frames,
the counts and the number of ranges; over all runs the ranges of executed instructions). The
self-test runs drive the boot program's menus with sndproto.lua's input steps (docs/11 section 5).
`make -j5 pccov` takes about eight minutes.

| Run | Frames | Distinct PCs | Boot | Game |
|---|---:|---:|---:|---:|
| attract | 7,200 | 17,056 | 215 | 16,841 |
| game (coin 900, start 960, trigger every 20 frames) | 7,200 | 16,299 | 215 | 16,084 |
| selftest (menus to "SA SELF TEST") | 2,800 | 5,371 | 799 | 4,572 |
| soundtest (menus to "PLAY SOUNDS", 108 entries) | 6,400 | 5,895 | 734 | 5,161 |
| postest (self-test switch, nothing pressed) | 3,600 | 5,944 | 1,372 | 4,572 |
| union | | 22,118 | 1,699 | 20,419 |

Every executed PC is a classified instruction start (`0 not a classified instruction start` in
every run). The union covers 78,774 of the 163,552 code bytes in 718 ranges. Without the MAME
seeds the descent reaches all but 192 of the 22,118 executed PCs; those 192 are the routines
entered through the three MAME entries (030C8E, 03C18A, 0410C0: each loaded by a `movea.l #` and
called through a pointer the code keeps in RAM, HYP).

## 8. How the code legs use the tools

1. Fix any wrong range in the classification first, with evidence (a reviewed seed or untaken
   branch in `data/68k/seeds.json`, a corrected idiom in `tools/m68k`), `make classify`, commit.
2. `tools/m68k gen START END --out asm/68k/<file> --equates asm/68k/hardware.asm --equates-out
   <ram equates> --incbin <path relative to the file>` once, into the leg's region file (decision
   C6), with `asm/68k/macros.asm` included before it; `make check` must stay 0 differences.
3. From then on edit the source by hand (names, comments, explained data); never run the
   generator over it again. After each change: `make check`, and `tools/m68k check-listing
   --listing build/stunrun-68k.lst --binary build/stunrun-68k.out --range START END` for the
   descent check and the address lint; the shift test as in `check-region` (pad the region's
   first statement).
4. Decide the undecided operands of the region (section 4) and the unknown ranges that decode
   cleanly (section 3) with written arguments.

## 9. Findings

- **0445F0-044630 is code inside the "data island"** (docs/06 section 4.2 called 04397E-046A00
  data): reached by the computed call at 0223E0-0223EC (`lea $441EC,a0`, `adda.l #$404,a0`,
  `jsr (a0)`), executed in all five MAME runs. docs/06 corrected.
- **026CD2 is a switch `jmp`** (`jmp (026CD6,pc,d0.w)`), which IDA made a data word; its table
  026CD6-026CEA holds cases 2-11 (the `move.w` at 026CCE reads from 026CD2 + 2 x index). docs/06
  corrected.
- **The `dbf d2` at 004B74 targets text** (0080D8, in the menu strings; no instruction at 0080DE)
  where the same loop at 004B82 branches back to its `move.l d0,(a0)`. The count makes the branch
  taken only when FF947E >> 1 is not 0; MAME executed 004B74 and 004B78 and never 0080D8 (HYP: a
  bad displacement the hardware never exercises). Recorded as an untaken branch in
  `data/68k/seeds.json`.
- Every `jmp (d8,pc,Xn)` of the code is a switch (33); some bound their index with `moveq`/`cmp`
  instead of `cmpi` (025704, 041116), some subtract before indexing (0380B6), one index is `.l`
  in the `move.w` and `.w` in the `jmp` (025712).
- No call in the code is followed by data (the `noreturn` list is empty).

## 10. Open questions

1. The 75 unreferenced ranges that decode cleanly (10,365 bytes, section 3): accept a "dead C
   function" argument (a range between two code ranges that starts after a `rts`, decodes to a
   `rts` and branches only inside itself) as evidence, or keep them `unknown` until a reference
   is found?
2. The 32 undecided long immediates (section 4): the data leg's.
3. 000100-000212 (274 bytes) and the boot program's menu records: their formats are the boot
   leg's.
