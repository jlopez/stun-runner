# The IDA databases: made by the build, annotated through snapshots

**Date**: 2026-11-04 (milestone 1, leg M1b). How the 68010 and 6502 IDA databases are created headlessly from the build images, the memory map they carry, the 6502 bank scheme, and the rule that keeps them out of the repository. Where the GSP and ADSP programs live is M2; this leg names nothing beyond the vector targets and the I/O map.

## 1. Databases are build artefacts; snapshots are committed

Decision (coordinator, 2026-11-04, **pending Jesus**, attention card A1): an IDA database embeds every byte of the image it was made from, and this repository is public, so CLAUDE.md rule 2 wins over the earlier plan of committing the `.i64` through Git LFS (docs/02 section 3 as written at kickoff). The databases are build artefacts:

```
build/stunrun-68k.bin ──┐                           ┌── data/stunrun-68k.i64   (gitignored)
build/stunrun-jsa.bin ──┤ make ida                  ├── data/stunrun-jsa.i64   (gitignored)
data/ida/*.json ────────┘ (ida.headless.create)     │
                                                    │ make ida-export (ida.headless.export)
                                                    ├── data/ida/stunrun-{68k,jsa}.json             committed
                                                    ├── data/ida/stunrun-{68k,jsa}.functions.jsonl  committed
                                                    └── build/ida/stunrun-{68k,jsa}.asm             never committed
```

- **The snapshot** (`data/ida/<name>.json`, `ida/snapshot.py`) holds the annotations and nothing else: segments (bounds, name, class, bitness, the image offset their bytes come from, comment), every user name with its address, every function start (including the `sub_` ones, as addresses only), comments (regular, repeatable, function, function repeatable), and the data items at named addresses (type, count, whether the value is an offset). Never a byte. One entry per line, sorted by address, so that a review reads the diff.
- **What IDA writes on its own is left out**: the switch analysis gives `jpt_`/`def_` names the user-name flag and writes `switch N cases`, `jumptable … case N` comments; the mc68k module writes `…_entry` comments at vector targets. Auto-analysis makes them again, so the snapshot drops them (full-pattern matches only: an edited one is kept). The patterns are `IDA_GENERATED_NAMES` / `IDA_GENERATED_COMMENTS` in `ida/snapshot.py`.
- **Creation** (`ida.headless.create_database`): idalib opens the raw image with `-p<processor> -o<data/name.i64>`; loader segments the setup does not have are deleted; the setup of section 2/4 is applied (segments with their bytes, I/O names and comments, the vector table, a function at each vector target); auto-analysis (`ida_auto.auto_wait`); the committed snapshot is applied; the analysis that triggers; saved.
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

I/O labels: `YM2151_REG` 2000, `YM2151_DATA` 2001, `OKI_READ` 2800, `CMD_FROM_68K` 2802, `RDIO` 2804, `IRQ_ACK` 2806, `OKI_WRITE` 2A00, `RESP_TO_68K` 2A02, `WRIO` 2A04, `MIX` 2A06, each with a repeatable comment. Mirror rule: the read ports 2800-2806 decode with mirror mask 01F9 (docs/01 section 6; bits 0 and 3-8 are don't-cares), and rev 6 reads them only through the +8 mirrors, so the base labels alone reach none of its 13 read-port accesses. The mirrors the code uses get the base name with `_M` and the base comment plus `mirror of <base> (mask 01F9)`: `OKI_READ_M` 2808 (1 access, `AND`), `CMD_FROM_68K_M` 280A (4: `LDA` ×3, `LDX`), `RDIO_M` 280C (6: `BIT` ×3, `LDA` ×3), `IRQ_ACK_M` 280E (2), generated in `ida/memory_map.py` from `JSA_READ_MIRRORS_USED`; a mirror found later is added there. The write ports 2A00-2A06 and the YM2151 are accessed at their base addresses. Vectors: `vec_nmi` FFFA → 0x57E3 `h_nmi`, `vec_reset` FFFC → 0x4000 `reset`, `vec_irq` FFFE → 0x41C1 `h_irq`, as offset words with a function at each target.

Decision (M1b): **bank n at linear `(n+1)<<16 | 0x3000`, segment base 0.** IDA cannot overlap segments on one linear address. The alternative, a segment with a selector base so that IDA displays the bank as `BANK0:3000`, was tried and rejected: IDA's m65 module resolves every absolute operand of a based segment relative to that base, so a bank's `LDA $2802` referenced linear 12802 and its `JMP $C000` nothing, while `JSR $3010` correctly reached 13010 (probe with synthetic instructions patched into a throwaway database, never saved). With base 0, the references from a bank to RAM, I/O and the fixed ROM resolve, and a reference inside the bank (`$3xxx`) shows unresolved; when a bank holds code, those operands need an offset with the bank's base (`op_offset` with a reference base) or a manual cross-reference. Each bank segment's comment says where the 6502 sees it.

Finding: in rev 6, all four bank pages (file 0x0000-0x3FFF) are zero bytes, so the bank scheme carries no code or data for this set; the 29 functions of section 5 are all in 4000-FFFF.

## 5. First numbers (2026-11-04, IDA 9.1, `make ida` from a clean `data/`)

| Database | Functions | User names | Comments | Data items at names | Size |
|---|---|---|---|---|---|
| `stunrun-68k` | 593 | 101 (64 vectors, 20 targets, 17 I/O) | 37 | 73 (64 vectors, 9 I/O typed by the analysis) | 14.5 MB |
| `stunrun-jsa` | 29 | 20 (3 vectors, 3 targets, 14 I/O) | 17 | 13 (3 vectors, 10 I/O typed by the analysis) | 0.4 MB |

The 68k listing (`build/ida/stunrun-68k.asm`, 0x000000-0x0BFFFF only: the I/O and RAM segments would add millions of `ds.b 1` lines) has 697,862 lines; the 6502 one 76,410. In the 68k ROM, 39,610 heads are instructions after auto-analysis; memory operands reach `RAM` 3,134 times, `ROM` 2,442, `GSP` 462, `MAINIO` 207, `ZRAM` 107, `ADSP` 84, `LATCH` 62, `DUART` 1.

Left for M2 (answered in docs/06 section 4.3): a few absolute operands fall outside every segment of docs/01's map: 0x0E0000-0x0E8000 (beyond the ROM, inside MAME's `0x000000-0x0FFFFF` ROM mapping; 16 operands), 0x400000 and 0x408000 (1 each), 0x840000 and 0x84C000 (1 each).
