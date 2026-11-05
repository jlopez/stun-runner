# The build: five images, five trees, 25 files

**Date**: 2026-11-04 (milestone 1, leg M1a; M2 added the program extraction). How `make` turns the reference set into source trees and back into the 25 files of `stunrun`, byte for byte, without a ROM byte in the repository. The IDA databases are leg M1b (docs/05-ida.md); the code map (where the GSP and ADSP programs live) is M2 and will refine the partition below.

## 1. The pipeline

```
reference set (~/archive/261104-stun-runner/roms/stunrun[.zip], outside the repo)
  │ tools/merge-roms                      by tools/romsets/stunrun.json (regions, offsets)
  ▼
build/stunrun-{68k,obj,oki,jsa,nvram}.bin  five images, one per address space (build artefacts)
  │ vasmm68k_mot / 64tass                  asm/68k, asm/obj, asm/oki, asm/nvram, asm/jsa
  ▼
build/stunrun-*.out  + build/stunrun-*.lst  assembled images and their listings
  │ tools/split-roms                       the exact inverse of merge-roms
  ▼
build/roms/stunrun/<25 files>              tools/check-roms --dir + tools/bytecheck
```

Since M2 the 68k image has one more step: `tools/extract-programs` cuts the ADSP and GSP
programs out of `build/stunrun-68k.bin` into `build/adsp/program.bin` and
`build/gsp/program.bin` (plus the unpacked oracle images `pm.bin` and `vram.bin`), and
`asm/68k/stunrun.asm` incbins them under `adsp_program` and `gsp_program` between two slices of
the image (docs/06-code-map.md section 3.4, which also holds the partition of the 768 KB).

Since M3 the object image is not an incbin of `build/stunrun-obj.bin` any more: its source is
`data/objects` (a manifest and one mesh file per object, docs/07-objects.md), which
`tools/objects asm` turns into `build/obj/page0.asm`-`page2.asm` (one per /MP page of 0x10000
words: `dc.w` for every decoded word, `dcb.w` for the zero fill), and `asm/obj/objects.asm`
includes them with an assert at every page boundary. The image still feeds the step, for one
word only: the residue word 0:019E the format does not explain, which the generated source takes
with an incbin slice (2 bytes, `residue_0_019E`), and through it the checksum word of page 0.
The generated sources depend on the mesh files and on `build/obj/data.list`, the list of their
names, rewritten only when it changes, so a deleted or added mesh file regenerates them (and a
missing one fails the build).
`make objects` re-decodes the image into `data/objects` (after a decoder change; `make test`
fails while the two disagree), `make objtrace` records the ADSP's object-ROM reads in MAME
(docs/07 section 7).

`make` (= `make all`) runs the three steps. The images are rebuilt only when the layout tools or the snapshot change (`make clean` re-reads the archive); the trees reassemble when their sources or blobs change; the split always runs (cheap, and make 3.81 on macOS compares whole-second mtimes, so a stamp could hide a reassembly in the same second).

## 2. The five images

Decision (M1a coordinator): the 68k image and the four data images are separate assembler outputs, and the split tool cuts them into files. The only hard-coded layout is the region → image table in `tools/romset.py`; names, sizes and positions come from the snapshot's `region` and `offset` fields (MAME's `ROM_LOAD` offset). A region where any file has an odd offset is a `ROM_LOAD16_BYTE` region: each file takes every other byte from its offset, so the even file (`200x`, `90h`/`10h`/`9h`) is D15-D8 and the odd one (`210x`, `90k`/`10k`/`9k`) D7-D0 of each 16-bit word (docs/01 section 2). `layout()` checks that the files tile each image exactly once.

| Image | Region(s) | Size | Contents | Tree |
|---|---|---|---|---|
| `stunrun-68k` | `mainpcb:maincpu` | 786,432 (0x000000-0x0BFFFF) | six 200x/210x pairs interleaved; image offset = 68010 address | `asm/68k/stunrun.asm` (vasm) |
| `stunrun-obj` | `mainpcb:user1` | 393,216 | `90h/90k` at 0x00000, `10h/10k` at 0x20000, `9h/9k` at 0x40000, interleaved; byte offset / 2 = the ADSP's object-ROM word index (/MP page = offset / 0x20000) | `asm/obj/objects.asm` (vasm) |
| `stunrun-oki` | `mainpcb:jsa:oki1` | 262,144 | `1fh`, `1ef`, `1de`, `1cd` one after the other; offset = OKI M6295 address | `asm/oki/samples.asm` (vasm) |
| `stunrun-jsa` | `mainpcb:jsa:cpu` | 65,536 | `136070-2123.10c` as is: 0000-3FFF the four 4 KB pages banked at 3000-3FFF, 4000-FFFF at its own address | `asm/jsa/jsa.asm` (64tass) |
| `stunrun-nvram` | `mainpcb:200e`, `mainpcb:210e` | 4,096 | `stunrun.200e` then `stunrun.210e` | `asm/nvram/nvram.asm` (vasm) |
| | | **1,511,424** | the whole set | |

Decision (M1a coordinator): every one of the 25 files is produced from an assembler listing, so that one coverage number covers the whole set, data ROMs included; the incbin source is always a build artefact under `build/`, never the archive path.

## 3. The trees at the zero point

Each tree is a list of blobs, one `incbin` (vasm) or `.binary` (64tass) per ROM pair or file, each preceded by a label, a comment naming the file(s) and an assembler-side guard on the address:

```
; 020000-03FFFF: 136070-6104.200s (even) / 136070-6103.210s (odd)
rom_s:
	assert	*=$020000,"pair S misplaced"
	incbin	"../../build/stunrun-68k.bin",$020000,$20000
```

- **vasm incbin syntax** (verified on vasm 2.0f, Motorola syntax module 3.19f): `incbin "file"[,offset[,length]]`, the path relative to the source file's directory (it also works when vasm runs from the repository root). As documented.
- **vasm guards**: `assert <expr>[,"message"]` fails the assembly with `error 48 ... assertion "*=$020000" failed: pair S misplaced`. `if *<>$20000` does **not** work in vasm's Motorola syntax (`<>` gives error 10, "number or identifier expected"); `if *!=$20000` / `fail` and `ifne *-$20000` do. The trees use `assert`.
- **64tass** (1.60): `.binary "file", offset, length`, `.cerror cond, "message"`. The 6502 program counter wraps from $FFFF to $0000 after a full 64 KB, so `* != $10000` is always true at the end of the image: `asm/jsa/jsa.asm` guards the slices at $1000/$2000/$3000/$4000, the end with `* != $0000`, and the blob's size with `len(binary(IMAGE)) != $10000`. The 6502 tree is cut into the four bank pages and the $4000-$FFFF window so that M4 can give each its own file and `.logical $3000`.

Flags: `vasmm68k_mot -quiet -Fbin -no-opt -m68010 -L build/<image>.lst -o build/<image>.out` (the data trees use the same assembler and flags, no instruction is involved); `64tass -q -C -b -L build/stunrun-jsa.lst -o build/stunrun-jsa.out`.

## 4. The checks

- `make check`: verifies the reference set first (`tools/check-roms`); **when it is absent** (CI, exit status 2) prints `reference set absent, skipped` and exits 0. Otherwise `make all`, then `tools/check-roms --dir build/roms/stunrun` (size, CRC-32, SHA-1 of the 25 built files against `tools/romsets/stunrun.json`) and `tools/bytecheck` (each built file against the reference file, byte for byte). Both always run; either failing fails the target.
- `tools/bytecheck` reports, per differing file, the count of differing bytes and the first one as a file offset and as an address in the space of the processor that reads it: 68k byte address for the 200x/210x files, `6502 bank N $3xxx` or `6502 $xxxx` for `10c`, ADSP object-ROM word index for the object ROMs, OKI address for the ADPCM files, byte offset for the NVRAM images. It never prints byte values (the repository and CI logs are public). Example, with one bit flipped at 68k address 0x041234 of the blob (then reassembled):

  ```
  FAIL bytecheck build/roms/stunrun: 1 problems over 25 files
    136070-6106.200t: 1 differing bytes, first at file offset $0091A = 68k $041234
  ```

- `make coverage`: `tools/coverage` reads the five listings (vasm `-L`: a `Sections:` header, `Source:` blocks, `SS:AAAAAAAA hex  \t N: source` lines and `*` for repeated runs; 64tass `-L`: `>addr\thex\t...\tsource` lines and `Processing file` markers) and attributes to each statement the bytes from its address to the next statement's (or the section's / image's end), classified as `instr`, `data` (`dc.*`, `.byte`, `.word`, `.text`...), `blob` (`incbin`, `.binary`) or `fill` (`ds.*`, `dcb.*`, `blk.*`, `.fill`). Per source file, per image, the total, the blob share and a JSON line; it fails unless the total is the set's size, 1,511,424. The blob share only goes down (CLAUDE.md section 2).
- `make test`: `tools/check-roms --selftest`, then pytest over `tools/test_*.py`: the merge/split round trip on a synthetic set (random bytes with the real snapshot's sizes, regions and offsets, never ROM data), the interleave positions, bytecheck's report and CPU addresses on planted differences, the coverage parser on hand-written vasm and 64tass listings, and, when vasm and 64tass are available, the whole `make all` + bytecheck + `make coverage` + a planted blob corruption on a copy of the Makefile, `asm/`, `tools/` and `data/objects` fed with a synthetic set (this is how CI exercises the real trees without ROMs; since M3a the synthetic set carries the object image the committed meshes encode to, with a random residue word, and an edited mesh must change the built chip). `tools/test_objects.py` adds the object format's tests (docs/07 section 8.3), among them one that runs in CI against the real hashes: the committed meshes encode to the four chips of pages 1 and 2 with MAME's CRC-32 and SHA-1.
- `make lint`: ruff and mypy over the tools.
- `make somdump` (needs MAME and the ROMs; never in CI): `tools/mame/somdump.lua` captures the
  SOM display list at the frames of `SOM_ATTRACT` (attract mode), `SOM_GAME` (a game started at
  frame 900) and `SOM_DITHER` (attract mode with every colour word's two bytes made different,
  `SOM_DITHER=1`, docs/08 section 5) into `build/mame/som/<attract|game|dither>-f<N>/` (SOM banks, ADSP data RAM, the GSP command
  buffer, the frame-buffer page before and after the list, colour and image tables, palette,
  snapshots, the frame's protocol events), then runs `tools/displaylist.py` on each: decode,
  redraw, compare with MAME's page (docs/08-display-list.md). Each of its three MAME runs starts
  from an empty private state, `build/mame/somstate` (removed first, then `-nvram_directory` and
  `-cfg_directory` there): the game boots from the set's own 200e/210e, attract mode (which
  follows the NVRAM's history) shows the same scenes on every run and machine, the user's
  `~/.mame` state is never read or written, and parallel worktrees stay apart. `make test` then
  also checks the captures
  (`tools/test_displaylist.py`, which skips without them); the three lists committed under
  `artifacts/display-list/` are decoded and redrawn in CI.

## 5. Coverage at the zero point (M1)

`make coverage`, 2026-11-04:

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `asm/68k/stunrun.asm` | 786,432 | 0 | 0 | 786,432 | 0 |
| `asm/obj/objects.asm` | 393,216 | 0 | 0 | 393,216 | 0 |
| `asm/oki/samples.asm` | 262,144 | 0 | 0 | 262,144 | 0 |
| `asm/nvram/nvram.asm` | 4,096 | 0 | 0 | 4,096 | 0 |
| `asm/jsa/jsa.asm` | 65,536 | 0 | 0 | 65,536 | 0 |
| **total** | **1,511,424** | 0 | 0 | 1,511,424 | 0 |

`blob: 100.0% of 1511424 bytes come from incbin/.binary`.

After M3a (`make coverage`, 2026-11-04) the object image comes from the generated page sources:

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `../../build/obj/page0.asm` | 131,072 | 0 | 126,678 | 2 | 4,392 |
| `../../build/obj/page1.asm` | 131,072 | 0 | 130,288 | 0 | 784 |
| `../../build/obj/page2.asm` | 131,072 | 0 | 39,304 | 0 | 91,768 |

`blob: 74.0% of 1511424 bytes come from incbin/.binary`. Decision (M3a): bytes generated from
committed data count as `data`/`fill` under the generated file's name (a path under `build/`
in the coverage table says where they come from); no separate coverage class.

## 6. Tools and versions

| Tool | Version | Where |
|---|---|---|
| vasm (`vasmm68k_mot`) | 2.0f (m68k backend 2.8c, Motorola syntax 3.19f), `make CPU=m68k SYNTAX=mot` | local: `~/.local/bin/vasmm68k_mot`; CI: built from `http://phoenix.owl.de/tags/vasm2_0f.tar.gz`, sha256 `c84b2de1cbb87831795fe64a85c5d9a7002a766e3a7c30b0a2d7d5e99d878f49`, cached by that hash. The rolling `sun.hasenbraten.de/vasm/release/vasm.tar.gz` is not a pin; `phoenix.owl.de/tags/` keeps every release. Override with `make VASM=...` |
| 64tass | 1.60.3243 locally (brew `tass64`); CI: Ubuntu's `64tass` package, 1.59.3120 on ubuntu-latest (2026-11-04), same listing format (the synthetic `make all` test parses it) | `make TASS=...` |
| Python | 3.13 (`.python-version`), `requires-python >=3.11`, uv; dev group ruff, mypy, pytest | `make PYTHON=...` (default `uv run --frozen python`) |
| make | GNU make 3.81 (macOS) and 4.x (CI); the Makefile avoids 4.3-only grouped targets | |

`uv run --frozen` in the Makefile: `uv.lock` records the `ida` group's local idapro path relative to the checkout, and uv rewrites it from any checkout at another depth (worktrees under `/private/tmp` or `~/.worktrunk`). The committed lock is written for the canonical checkout (`~/git-repos/personal/stun-runner`, five levels below `/`); run `uv sync` / `uv run` with `UV_FROZEN=1` (or `--frozen`) in other worktrees so the lock stays clean.

## 7. CI

`.github/workflows/ci.yml`, one job on `ubuntu-latest` (push to main, pull requests): checkout with LFS, apt `64tass`, vasm from the pinned tarball (sha256 verified, binary cached), `astral-sh/setup-uv@v10.2.0` with Python 3.13 and `UV_FROZEN=1`, `uv sync`, `uv run ruff check tools ida`, `make lint`, `make test` (including the synthetic `make all` through both assemblers) and `make check`, which prints `reference set absent, skipped` there.
