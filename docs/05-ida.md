# The IDA databases: made by the build, annotated through snapshots

**Date**: 2026-11-04 (milestone 1, leg M1b). How the 68010 and 6502 IDA databases are created headlessly from the build images, the memory map they carry, the 6502 bank scheme, and the rule that keeps them out of the repository. Where the GSP and ADSP programs live is M2; this leg names nothing beyond the vector targets and the I/O map.

## 1. Databases are build artefacts; snapshots are committed

Decision (Jesus, 2026-11-04, approving the M1b coordinator's card A1): an IDA database embeds every byte of the image it was made from, and this repository is public, so CLAUDE.md rule 2 wins over the earlier plan of committing the `.i64` through Git LFS (docs/02 section 3 as written at kickoff). The databases are build artefacts:

```
build/stunrun-68k.bin ──┐                           ┌── data/stunrun-68k.i64   (gitignored)
build/stunrun-jsa.bin ──┤ make ida                  ├── data/stunrun-jsa.i64   (gitignored)
data/ida/*.json ────────┘ (ida.headless.create)     │
                                                    │ make ida-export (ida.headless.export)
                                                    ├── data/ida/stunrun-{68k,jsa}.json             committed
                                                    ├── data/ida/stunrun-{68k,jsa}.functions.jsonl  committed
                                                    └── build/ida/stunrun-{68k,jsa}.asm             never committed
```

- **The snapshot** (`data/ida/<name>.json`, `ida/snapshot.py`) holds the annotations and nothing else: segments (bounds, name, class, bitness, the image offset their bytes come from, comment), every user name with its address (a local name marked `"local": true`), every function start (including the `sub_` ones, as addresses only), comments (regular, repeatable, function, function repeatable, and the anterior lines above an address as one `anterior` text), and the data items at named addresses (type, count, whether the value is an offset). For a database whose source owns the classification (`classified` in `ida/memory_map.py`: the 6502's, since M4f, section 6) it also holds every data item and the instruction ranges (`code`) of those ranges, so that `make ida` rebuilds what `make ida-sync` wrote. Never a byte. One entry per line, sorted by address, so that a review reads the diff; the keys a database does not use (`code`, `local`) are left out, so the 68k snapshot is unchanged by them.
- **What IDA writes on its own is left out**: the switch analysis gives `jpt_`/`def_` names the user-name flag and writes `switch N cases`, `jumptable … case N` comments; the mc68k module writes `…_entry` comments at vector targets; the binary loader writes three anterior lines at the first address (`; File Name : <the image's local path>`, `; Format`, `; Base Address`). Auto-analysis makes them again, so the snapshot drops them (full-pattern matches only: an edited one is kept). The patterns are `IDA_GENERATED_NAMES` / `IDA_GENERATED_COMMENTS` in `ida/snapshot.py`.
- **Creation** (`ida.headless.create_database`): idalib opens the raw image with `-p<processor> -o<data/name.i64>`; loader segments the setup does not have are deleted; the setup of section 2/4 is applied (segments with their bytes, I/O names and comments, the vector table, a function at each vector target); auto-analysis (`ida_auto.auto_wait`); the committed snapshot is applied (segments, data items, instructions, functions from the highest address down, a function the analysis ran into from the one before ended where the next starts, global then local names, comments); the analysis that triggers; the local names set once more (that analysis can turn a local name at the end of a function into a global one); saved.
- **The round trip**: `create → export` reproduces the committed snapshot and `functions.jsonl` byte for byte. `tools/test_ida.py` runs it in a temporary directory, and also checks that an added name and comments survive create and export (what a GUI session would add). Both tests skip without idalib or the build images (CI), while the pure tests of the snapshot helpers and of the memory-map setups run everywhere.
- **Rule: export before commit, never commit the `.i64`.** Annotate in the GUI (or headlessly with `database(path, write=True)`), run `make ida-export`, commit `data/ida/`. `make ida` rebuilds the databases from scratch, so annotations that were not exported are lost. A deletion (a function or name removed in the GUI) does not travel: the snapshot adds, it does not subtract; auto-analysis may make the item again.

### Commands

```bash
UV_FROZEN=1 uv sync --group ida   # idapro from the local IDA (docs/04 section 6 for UV_FROZEN)
make                              # the build images
make ida                          # data/stunrun-68k.i64 and data/stunrun-jsa.i64 (about 3 s)
make ida-export                   # data/ida/*.json, *.functions.jsonl; build/ida/*.asm
make test                         # includes the round trip when idalib is present
```

**Open in the GUI**: `open -a "IDA Professional 9.1" data/stunrun-68k.i64` (or File > Open). Close and save in the GUI, then `make ida-export` before committing; never `git add` the database (`.gitignore` covers `data/*.i64` and IDA's unpacked components).

**idalib notes** (IDA 9.1, verified 2026-11-04): `idapro.open_database(path, run_auto_analysis, args)` accepts IDA command-line switches; `-p68010` and `-pM6502` select the processor for a raw file, which the loaders detect as "Binary file", loaded at 0; `-o<file>.i64` names the database (its directory must exist). `-T` is rejected as an unknown switch. The switches are split on whitespace, so neither path may contain a space (`create_database` refuses one). One database per process: `create all` and `export all` run one child process per database. The 68k binary loader marks typical code sequences when it loads; keeping its `ROM` segment (instead of deleting and recreating it) gives 593 functions after auto-analysis instead of 124.

`uv sync --group ida` in a worktree at another depth than the canonical checkout fails (`uv.lock` records the idapro path relative to the checkout, docs/04 section 6); there `UV_FROZEN=1 uv sync` followed by `uv pip install "/Applications/IDA Professional 9.1.app/Contents/MacOS/idalib/python"` gives the same environment, and `uv run` keeps it.

## 2. The 68k database (`stunrun-68k`)

Processor `68010` (IDA mc68k), 32-bit segments, the image `build/stunrun-68k.bin` at 0. The segments follow docs/01 section 3:

| Segment | Range | Bytes | What |
|---|---|---|---|
| `ROM` | 000000-0BFFFF | image 0x000000 | program ROM, the 12 files interleaved (code and data) |
| `MAINIO` | 600000-60FFFF | none | JSA II port, sound reset / NWR latch, watchdog, port 0 |
| `ADSP` | 800000-83FFFF | none | ADSP program/data RAM windows, output buffer, control, status |
| `LATCH` | A00000-BFFFFF | none | WR0/WR1/WR2 latches, buttons, ADCs |
| `GSP` | C00000-C07FFF | none | TMS34010 and MSP host interfaces |
| `DUART` | FF0000-FF001F | none | MC68681 |
| `ZRAM` | FF4000-FF4FFF | none | M48T02 (high byte) and 2816 (low byte) |
| `RAM` | FF8000-FFFFFF | none | 32 KB work RAM |

The 68010 has a 24-bit bus; IDA's mc68k folds absolute addresses to 24 bits for the 68010 (`$FFFF8000.w` lands in `RAM`), so the segments sit at their 24-bit addresses.

I/O labels (`IO_68K` in `ida/memory_map.py`), each with a repeatable comment so that every reference shows it. Where a read and a write do different things at one address, the read is the name and the write is in the comment:

| Address | Name | Comment carries |
|---|---|---|
| 600000 | `JSA_PORT` | response (read) / command (write), high byte |
| 604000 | `SOUND_RESET` | write: `NWR_LATCH` |
| 608000 | `WATCHDOG` | |
| 60C000 | `PORT0` | write: `IRQ5_ACK` |
| 800000 | `ADSP_PRAM` | |
| 808000 | `ADSP_DRAM` | word 0x1FFF raises the ADSP IRQ |
| 810000 | `ADSP_BUFFER` | |
| 818000 | `ADSP_CONTROL` | |
| 818060 | `ADSP_IRQ_CLEAR` | |
| 838000 | `ADSP_STATUS` | |
| A00000 | `WR0_LATCH` | |
| A80000 | `BUTTONS` | write: `WR1_LATCH` |
| B00000 | `ADC8_DATA` | write: `WR2_LATCH` |
| B80000 | `ADC12` | |
| C00000 | `GSP_HOST` | |
| C04000 | `MSP_HOST` | |
| FF0000 | `DUART` | |

## 3. The 68010 vector table

Vectors 0-63 (0x000-0x0FF) are named longs: `vec_reset_sp`, `vec_reset_pc`, `vec_bus_error`, `vec_address_error`, `vec_illegal_instruction`, `vec_zero_divide`, `vec_chk`, `vec_trapv`, `vec_privilege_violation`, `vec_trace`, `vec_line_a`, `vec_line_f`, `vec_format_error` (14), `vec_uninitialized_interrupt` (15), `vec_spurious_interrupt` (24), the autovectors with this board's sources `vec_level1_msp`, `vec_level2_adsp`, `vec_level3_gsp`, `vec_level4_sound`, `vec_level5_timer`, `vec_level6_duart`, `vec_level7_nmi` (25-31), `vec_trap_0`..`vec_trap_15` (32-47), and `vec_reserved_N` for 12, 13, 16-23 and 48-63 (reserved on the 68010). Each long whose value is a non-zero even ROM address is an offset, and a function is created at its target.

Decision (M1b): **vectors 64-255 are not a table on this ROM.** The reset PC is 0x000216 and the shared line-A/line-F handler is at 0x000212, both inside the user-vector area (0x100-0x3FF), and the longs there take odd values and values that are not code. The names `vec_user_N` exist in `vector_name_68k` but are not applied.

The table (values are addresses; `make ida` reads them from the image):

| Vector(s) | Value | Target name |
|---|---|---|
| 0 reset SP | 0xFFFFC000 (= FFC000, in `RAM`) | (not code) |
| 1 reset PC | 0x000216 | `reset` |
| 2 bus error | 0x01076A | `h_bus_error` |
| 3 address error | 0x01078E | `h_address_error` |
| 4 illegal instruction | 0x0107B0 | `h_illegal_instruction` |
| 5 zero divide | 0x0107C2 | `h_zero_divide` |
| 6 CHK | 0x0107D4 | `h_chk` |
| 7 TRAPV | 0x0107E2 | `h_trapv` |
| 8 privilege violation | 0x0107F0 | `h_privilege_violation` |
| 9 trace | 0x0107FE | `h_trace` |
| 10, 11, 12, 13 line A, line F, reserved | 0x000212 | `h_line_a_etc` |
| 14 format error | 0x01080C | `h_format_error` |
| 15 uninitialised interrupt | 0x01081E | `h_uninitialized_interrupt` |
| 16-23, 48-63 reserved | 0 | (none) |
| 24 spurious, 31 level 7 | 0x01082C | `h_spurious_interrupt_etc` |
| 25 level 1 (MSP) | 0x0007FA | `h_level1_msp` |
| 26 level 2 (ADSP) | 0x0007F0 | `h_level2_adsp` |
| 27 level 3 (GSP) | 0x0007D6 | `h_level3_gsp` |
| 28 level 4 (sound) | 0x00081C | `h_level4_sound` |
| 29 level 5 (timer) | 0x00082C | `h_level5_timer` |
| 30 level 6 (DUART) | 0x000812 | `h_level6_duart` |
| 32-47 TRAP #0-#15 | 0x010848 | `h_trap_0_etc` |

M2 renamed the targets of this (the boot program's) table `boot_*` (`boot_reset`, `boot_level2_adsp`, ...) and added the game's table at 0x020000 with `game_vec_*` longs and `h_*` / `game_reset` targets (docs/06 section 1.2). A target shared by several vectors is named after the first with `_etc`; every target has a function comment listing its vectors. The functions are created from the highest address down: the exception handlers at 0x01076A-0x010848 share code, and creating them in ascending order let the first one swallow the next eight (IDA refused the later starts as inside it).

## 4. The 6502 database (`stunrun-jsa`) and the bank scheme

Processor `M6502` (IDA m65), 16-bit segments, from `build/stunrun-jsa.bin` (the file `136070-2123.10c` as is). The binary loader puts the file flat at 0; `create` deletes that segment and builds the map of docs/01 section 6:

| Segment | Linear range | Bytes from file | The 6502 sees |
|---|---|---|---|
| `RAM` | 0000-1FFF | none | 0000-1FFF |
| `IO` | 2000-2FFF | none | 2000-2FFF |
| `ROM` | 4000-FFFF | 0x4000-0xFFFF | 4000-FFFF |
| `BANK0` | 13000-13FFF | 0x0000-0x0FFF | 3000-3FFF, WRIO bits 7-6 = 0 |
| `BANK1` | 23000-23FFF | 0x1000-0x1FFF | 3000-3FFF, WRIO bits 7-6 = 1 |
| `BANK2` | 33000-33FFF | 0x2000-0x2FFF | 3000-3FFF, WRIO bits 7-6 = 2 |
| `BANK3` | 43000-43FFF | 0x3000-0x3FFF | 3000-3FFF, WRIO bits 7-6 = 3 |

I/O labels: `YM2151_REG` 2000, `YM2151_DATA` 2001, `OKI_READ` 2800, `CMD_FROM_68K` 2802, `RDIO` 2804, `IRQ_ACK` 2806, `OKI_WRITE` 2A00, `RESP_TO_68K` 2A02, `WRIO` 2A04, `MIX` 2A06, each with a repeatable comment. Since M4f the setup reads them from `asm/jsa/hardware.asm` (`ida.jsa_source.hardware_io`: every equate whose value lies in the IO segment, with the comment the sync writes), so the source is their one definition; `tools/test_ida_sync.py` checks them against the values 64tass resolves. Mirror rule: the read ports 2800-2806 decode with mirror mask 01F9 (docs/01 section 6; bits 0 and 3-8 are don't-cares), and rev 6 reads them only through the +8 mirrors, so the base labels alone reach none of its 13 read-port accesses. The mirrors the code uses get the base name with `_M`: `OKI_READ_M` 2808 (1 access, `AND`), `CMD_FROM_68K_M` 280A (4: `LDA` ×3, `LDX`), `RDIO_M` 280C (6: `BIT` ×3, `LDA` ×3), `IRQ_ACK_M` 280E (2), equates `<base> + 8` in `hardware.asm` (until M4f generated in `ida/memory_map.py` from `JSA_READ_MIRRORS_USED`); a mirror found later is added there. The write ports 2A00-2A06 and the YM2151 are accessed at their base addresses. Vectors: `vec_nmi` FFFA → 0x57E3 `h_nmi`, `vec_reset` FFFC → 0x4000 `reset`, `vec_irq` FFFE → 0x41C1 `h_irq`, as offset words with a function at each target.

Decision (M1b): **bank n at linear `(n+1)<<16 | 0x3000`, segment base 0.** IDA cannot overlap segments on one linear address. The alternative, a segment with a selector base so that IDA displays the bank as `BANK0:3000`, was tried and rejected: IDA's m65 module resolves every absolute operand of a based segment relative to that base, so a bank's `LDA $2802` referenced linear 12802 and its `JMP $C000` nothing, while `JSR $3010` correctly reached 13010 (probe with synthetic instructions patched into a throwaway database, never saved). With base 0, the references from a bank to RAM, I/O and the fixed ROM resolve, and a reference inside the bank (`$3xxx`) shows unresolved; when a bank holds code, those operands need an offset with the bank's base (`op_offset` with a reference base) or a manual cross-reference. Each bank segment's comment says where the 6502 sees it.

Finding: in rev 6, all four bank pages (file 0x0000-0x3FFF) are zero bytes, so the bank scheme carries no code or data for this set; the 29 functions of section 5 are all in 4000-FFFF.

Since M4a (docs/09-sound-program.md) the 6502 program is source in `asm/jsa/`, and since M4f the database follows it: `make ida-sync` writes the source's names, comments, functions and classification into it (section 6). The write ports decode with the same mirror mask 01F9 as the read ports (`atarijsa2_map`); the program writes them at their base addresses only.

## 5. First numbers (2026-11-04, IDA 9.1, `make ida` from a clean `data/`)

| Database | Functions | User names | Comments | Data items at names | Size |
|---|---|---|---|---|---|
| `stunrun-68k` | 593 | 101 (64 vectors, 20 targets, 17 I/O) | 37 | 73 (64 vectors, 9 I/O typed by the analysis) | 14.5 MB |
| `stunrun-jsa` | 29 | 20 (3 vectors, 3 targets, 14 I/O) | 17 | 13 (3 vectors, 10 I/O typed by the analysis) | 0.4 MB |
| `stunrun-jsa` after `make ida-sync` (M4f, 2026-11-05) | 147 | 1,018 (675 global: 531 labels of the image, 130 RAM and 14 I/O equates; 343 local) | 1,702 (146 function, 1,182 regular, 370 repeatable, 4 anterior) | 8,517 (8,443 of the source, 74 at RAM and I/O names typed by the analysis); 7 instruction ranges | 0.8 MB |

The 68k listing (`build/ida/stunrun-68k.asm`, 0x000000-0x0BFFFF only: the I/O and RAM segments would add millions of `ds.b 1` lines) has 697,862 lines; the 6502 one 76,410. In the 68k ROM, 39,610 heads are instructions after auto-analysis; memory operands reach `RAM` 3,134 times, `ROM` 2,442, `GSP` 462, `MAINIO` 207, `ZRAM` 107, `ADSP` 84, `LATCH` 62, `DUART` 1.

Left for M2 (answered in docs/06 section 4.3): a few absolute operands fall outside every segment of docs/01's map: 0x0E0000-0x0E8000 (beyond the ROM, inside MAME's `0x000000-0x0FFFFF` ROM mapping; 16 operands), 0x400000 and 0x408000 (1 each), 0x840000 and 0x84C000 (1 each).

## 6. The 6502 database follows the source (`make ida-sync`, M4f)

**Date**: 2026-11-05 (milestone 4, leg M4f, issue #21). CLAUDE.md section 2: once a region is source, the source is the truth and IDA follows it. For the 6502 the whole file is source (docs/09), so the whole database follows `asm/jsa`.

```
asm/jsa ──64tass──> listing + labels ──ida.jsa_source──> what the source carries
                                                              │ ida.headless.sync (make ida-sync [WRITE=1])
data/stunrun-jsa.i64 <────────────────────────────────────────┘
        │ make ida-export
        └──> data/ida/stunrun-jsa.json, .functions.jsonl (committed; make ida rebuilds the same database)
```

**What the source carries** (`ida/jsa_source.py`, pure Python, tested in CI by `tools/test_ida_sync.py`). The tree is assembled as `make` does (`64tass -q -C -b`), with a listing (`-L`) and a labels file (`-l`); a copy with a marker `sync__N = *` before every label and statement line is assembled too (it must give the same 64 KB), and its labels file gives every source line's address, macro calls included. The listing gives the statements the image is made of, macro expansions included, with their sizes.

- **Addresses**: file 4000-FFFF is `ROM` at its own address; a bank page's offset goes to `BANK0`-`BANK3` (section 4; a statement over two pages is cut at the page end). `ram.asm`'s equates are names in `RAM`, `hardware.asm`'s in `IO` when their value is in 2000-2FFF; the bit constants, register numbers and `BANK_WINDOW` (3000, in no segment) are not addresses.
- **Names**: every global label is the IDA name at its address; every `_local` an IDA local name, with its underscore, in the function that holds it. IDA has one name per address: a second label at an address would be reported, not carried (none in this tree: 0 labels left out).
- **Functions**: a function starts at every global label of the code files (`system.asm` ... `io.asm`, `ROUTINE_FILES`) whose first statement is an instruction: 147. So each 64tass local scope is one IDA function and every local lies in its own scope's function. A label reached only by a jump (`warm_start`, `branch_taken`, `loc_` labels) is a function start too; IDA shows the jump as a tail call.
- **Code and data**: every instruction is code (3,555); every data statement is one data item of its size (8,443): bytes, words for `.word`, offsets where every operand of the `.word` names a label of the image (719 word items). The source's statements tile the image exactly (`tools/test_ida_sync.py`).
- **Comments**: a column-0 comment block directly above a global label (its `; ---` rules dropped) is the routine's function comment, or the repeatable comment of a data label; the comment on a line, its continuation lines (comment-only lines at the column of the line's comment) and an indented block directly above it are the regular comment at the line's address; the block above an equate and its line comment are the equate's repeatable comment. A block followed by a blank line, or above a directive that makes no bytes (a `.cerror`), belongs to no address (62 such blocks, among them each file's header, the section headings of `ram.asm`, `hardware.asm` and `tables.asm`, the vectors' heading in `jsa.asm` and the comments of the bit constants). IDA 9.1 keeps 1,024 characters of a comment: the four routine headers longer than 1,023 characters (`read_item`, `tick_ym_channel`, `ymtimer_start`, `count_coins`) are kept whole as anterior lines above the routine, with their leading paragraphs in the function comment.

**The sync** (`ida/headless/sync.py`). The dry run (`make ida-sync`) opens a copy of `data/stunrun-jsa.i64` and prints, per category (data, code, functions, names, names deleted, locals, locals deleted, function comments, repeatable comments, comments, anterior comments), how many changes the source asks for (`--list` prints each); `make ida-sync WRITE=1` applies them in place, saves, and runs the dry run again in a child process, which must report 0. Decision (M4f): **the source wins, in the whole database**. A user name the source does not have, in any segment, is deleted; a comment the source does not carry (regular, repeatable, function, anterior or posterior) is deleted; whatever IDA had over a statement is undefined and remade as the source's instruction or data item; a function the analysis ran into from the routine before is ended where the routine starts. An IDA function at no routine label would be reported and kept (auto-analysis would make it again at the next `make ida`); after the sync there is none. The loader's anterior lines at address 0 are IDA's and are left alone. The 20 names of the M1 snapshot are all in the source at the same addresses, so the first sync deleted none.

Counts of the first sync (against the database `make ida` built from the M1 snapshot): 8,440 data items, 1,424 instructions over bytes the analysis had left as data or unexplored, 108 functions (the dry run's 118 counts the starts the analysis had inside other functions as well), 655 names, 343 local names, 146 function comments, 370 repeatable comments (the 14 I/O comments among them, now `hardware.asm`'s), 1,182 regular comments, 4 anterior blocks; a second run reports 0. Then `make ida-export`; `make ida` from the new snapshot and `make ida-sync` report 0 changes, and `tools/test_ida.py` (create, export, compare) reproduces both snapshots byte for byte.

**The checks without IDA** (`tools/test_ida_sync.py`, CI): the extraction on a synthetic tree assembled with 64tass (names, locals and their scope, functions, every comment rule, the classification, macro expansions); on `asm/jsa`, the statements tile the image; the committed snapshot's names are exactly the source's, globals and locals, so a label renamed in the source without a sync fails (a planted rename is caught); the snapshot has the source's functions, instruction ranges and data items; `ida/memory_map.py`'s I/O names and comments are `hardware.asm`'s. Comments are not compared in CI: a comment edited in the source shows up as a change in the next `make ida-sync` dry run.

**After an edit to `asm/jsa`** (labels or comments): `make ida`, `make ida-sync WRITE=1`, `make ida-export`, commit `data/ida/stunrun-jsa.*`. After `make ida-annotate` (which re-applies the setup, and with it the setup's `vectors: ...` function comments over the source's headers), run `make ida-sync WRITE=1` before exporting.

**Not done**: the 68k database follows no source yet (M5); only its code map's comments that cite 6502 labels were checked (they use the current names).
