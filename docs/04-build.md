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
includes them with an assert at every page boundary. Since 2026-11-05 (Jesus, card A2) the image
does not feed the step at all: the one word the format does not explain, the residue word
0:019E, is a named constant in the manifest (`residue_0_019E`, a `dc.w`; docs/07 section 5.3),
so the object tree's output depends on the committed data and the tools only, never on
`build/stunrun-obj.bin` (`make` builds the object image with that file absent; the other four
trees depend on the blobs they incbin). The generated sources depend on the mesh files and on `build/obj/data.list`, the list of their
names, rewritten only when it changes, so a deleted or added mesh file regenerates them (and a
missing one fails the build).
`make objects` re-decodes the image into `data/objects` (after a decoder change; `make test`
fails while the two disagree), `make objtrace` records the ADSP's object-ROM reads in MAME
(docs/07 section 7). `make objlevels` (`-j6` runs six at a time) records which objects each
start level 0-23 loads (docs/07 section 11.4), `make pictures` redraws the object pictures under
`artifacts/objects/` from `data/objects` (docs/07 section 11.3; `make test` compares them), and
`make view` serves the repository on 127.0.0.1:8000 for the mesh viewer
`tools/objects/viewer.html` (docs/07 section 11.5).

Since M4b the OKI image goes through one WAV per sample (docs/10-adpcm.md): `tools/adpcm split`
cuts `build/stunrun-oki.bin` by the image's own phrase table (names from `data/oki/samples.json`;
`tools/adpcm info` and `make check` compare the image with the manifest) into
`build/oki/wav/NN-name.wav`, removing any other WAV there, each a WAV whose data chunk is the sample's ADPCM
bytes verbatim; `tools/adpcm asm` reads the WAVs of `OKI_WAV_DIR` (default `build/oki/wav`),
recovers the bytes into `build/oki/bin/NN.bin` and writes `build/oki/samples.asm`, which
`asm/oki/samples.asm` (the phrase table as `dc.b`, computed from the samples' labels) includes:
one `incbin` per sample, cut at each file boundary, and the zero tail as `dcb.b`. The image is
byte-identical only if every sample survived WAV and back. The WAV step and the OKI assembly
run on every `make` (cheap), so an edited WAV is never hidden by the whole-second mtimes of make
3.81, and so does `tools/adpcm split --missing` on `build/oki/wav`, which writes back a WAV
missing there (deleted, or a phrase renamed behind the split's stamp) and keeps the others;
`tools/adpcm` is a package directory, run as `uv run python tools/adpcm <command>`; `make OKI_WAV_DIR=dir` builds from edited WAVs. `make okitrace` (`-j3`: three MAME runs of
`tools/mame/okitrace.lua`) records what the 6502 tells the OKI and rewrites the manifest's play
evidence; `make oki-pcm` decodes every phrase the manifest names to 16-bit PCM under `build/oki/pcm/` for
listening (other WAVs there are removed, so a rename leaves no stale copy).
Sample bytes, WAVs and PCM stay under `build/`.
Since M4a the 6502 image is not an incbin of `build/stunrun-jsa.bin` either: `asm/jsa/jsa.asm`
and the files it includes (`hardware.asm`, `ram.asm` and eleven region files,
`data/sounds.asm` and `data/music.asm` among them) are the whole program as 64tass source, instructions, tables and fills
(docs/09-sound-program.md section 4), so the tree's output depends on its own files only; the
Makefile's prerequisites for it are `asm/jsa/*.asm` and `asm/jsa/data/*.asm`.
`build/stunrun-jsa.bin` is still made by `tools/merge-roms`, for `make ida`.

`make` (= `make all`) runs the three steps. The images are rebuilt only when the layout tools or the snapshot change (`make clean` re-reads the archive); the trees reassemble when their sources or blobs change; the split always runs (cheap, and make 3.81 on macOS compares whole-second mtimes, so a stamp could hide a reassembly in the same second). For the same reason the 6502 tree assembles on every make (64tass takes well under a second): an edit to `asm/jsa` in the same second as the last assembly would otherwise leave a stale image, and a planted-change probe run from a script would check the wrong bytes. The other trees still reassemble by mtime: after a scripted edit to `asm/` (68k) or `data/objects`, `touch` the file or wait a second before `make check`.

## 2. The five images

Decision (M1a coordinator): the 68k image and the four data images are separate assembler outputs, and the split tool cuts them into files. The only hard-coded layout is the region → image table in `tools/romset.py`; names, sizes and positions come from the snapshot's `region` and `offset` fields (MAME's `ROM_LOAD` offset). A region where any file has an odd offset is a `ROM_LOAD16_BYTE` region: each file takes every other byte from its offset, so the even file (`200x`, `90h`/`10h`/`9h`) is D15-D8 and the odd one (`210x`, `90k`/`10k`/`9k`) D7-D0 of each 16-bit word (docs/01 section 2). `layout()` checks that the files tile each image exactly once.

| Image | Region(s) | Size | Contents | Tree |
|---|---|---|---|---|
| `stunrun-68k` | `mainpcb:maincpu` | 786,432 (0x000000-0x0BFFFF) | six 200x/210x pairs interleaved; image offset = 68010 address | `asm/68k/stunrun.asm` (vasm) |
| `stunrun-obj` | `mainpcb:user1` | 393,216 | `90h/90k` at 0x00000, `10h/10k` at 0x20000, `9h/9k` at 0x40000, interleaved; byte offset / 2 = the ADSP's object-ROM word index (/MP page = offset / 0x20000) | `asm/obj/objects.asm` (vasm) |
| `stunrun-oki` | `mainpcb:jsa:oki1` | 262,144 | `1fh`, `1ef`, `1de`, `1cd` one after the other; offset = OKI M6295 address | `asm/oki/samples.asm` (vasm) + `build/oki/samples.asm` (`tools/adpcm asm`) |
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
- **64tass** (1.60): `.binary "file", offset, length`, `.cerror cond, "message"`. The 6502 program counter wraps from $FFFF to $0000 after a full 64 KB, so `* != $10000` is always true at the end of the image: `asm/jsa/jsa.asm` guards the slices at $1000/$2000/$3000/$4000, the end with `* != $0000`, and the blob's size with `len(binary(IMAGE)) != $10000`. The 6502 tree is cut into the four bank pages and the $4000-$FFFF window so that M4 can give each its own file and `.logical $3000`. (M4a: the four pages are zero in this set, so they became `.fill`s with no `.logical`; the window became the region files of docs/09 section 2.)

Flags: `vasmm68k_mot -quiet -Fbin -no-opt -m68010 -L build/<image>.lst -o build/<image>.out` (the data trees use the same assembler and flags, no instruction is involved); `64tass -q -C -b -L build/stunrun-jsa.lst -o build/stunrun-jsa.out`.

## 4. The checks

- `make check`: verifies the reference set first (`tools/check-roms`); **when it is absent** (CI, exit status 2) prints `reference set absent, skipped` and exits 0. Otherwise `make all`, then `tools/check-roms --dir build/roms/stunrun` (size, CRC-32, SHA-1 of the 25 built files against `tools/romsets/stunrun.json`) and `tools/bytecheck` (each built file against the reference file, byte for byte). Both always run; either failing fails the target.
- `tools/bytecheck` reports, per differing file, the count of differing bytes and the first one as a file offset and as an address in the space of the processor that reads it: 68k byte address for the 200x/210x files, `6502 bank N $3xxx` or `6502 $xxxx` for `10c`, ADSP object-ROM word index for the object ROMs, OKI address for the ADPCM files, byte offset for the NVRAM images. It never prints byte values (the repository and CI logs are public). Example, with one bit flipped at 68k address 0x041234 of the blob (then reassembled):

  ```
  FAIL bytecheck build/roms/stunrun: 1 problems over 25 files
    136070-6106.200t: 1 differing bytes, first at file offset $0091A = 68k $041234
  ```

- `make coverage`: `tools/coverage` reads the five listings (vasm `-L`: a `Sections:` header, `Source:` blocks, `SS:AAAAAAAA hex  \t N: source` lines and `*` for repeated runs; 64tass `-L`: `>addr\thex\t...\tsource` lines and `Processing file` markers) and attributes to each statement the bytes from its address to the next statement's (or the section's / image's end), classified as `instr`, `data` (`dc.*`, `.byte`, `.word`, `.text`...), `blob` (`incbin`, `.binary`) or `fill` (`ds.*`, `dcb.*`, `blk.*`, `.fill`). Per source file, per image, the total, the blob share and a JSON line; it fails unless the total is the set's size, 1,511,424. The blob share only goes down (CLAUDE.md section 2).
- `make test`: `tools/check-roms --selftest`, then pytest over `tools/test_*.py`: the merge/split round trip on a synthetic set (random bytes with the real snapshot's sizes, regions and offsets, never ROM data), the interleave positions, bytecheck's report and CPU addresses on planted differences, the coverage parser on hand-written vasm and 64tass listings, and, when vasm and 64tass are available, the whole `make all` + bytecheck + `make coverage` + a planted blob corruption on a copy of the Makefile, `asm/`, `tools/` and `data/objects` fed with a synthetic set (this is how CI exercises the real trees without ROMs; since M3a the synthetic set carries the object image the committed data encodes to, `make all` must rebuild it, also with `build/stunrun-obj.bin` deleted, and an edited mesh must change the built chip; since M4b it carries a valid OKI image, the manifest's phrase table over random sample bytes, and one data byte changed in a WAV, in `build/oki/wav` or in another `OKI_WAV_DIR`, must change the built file at that sample's address). `tools/test_adpcm.py` adds the WAV round trip, the phrase table, the malformed WAVs and the decoder (docs/10-adpcm.md sections 5-6). `tools/test_objects.py` adds the object format's tests (docs/07 section 8.3), among them one that runs in CI against the real hashes: the committed data/objects (meshes and the residue constant) encodes to all six object chips with MAME's CRC-32 and SHA-1.
- `make lint`: ruff and mypy over the tools.
- `make okitrace` (needs MAME and the ROMs; never in CI; `-j3` runs the three runs at once):
  `tools/mame/okitrace.lua` taps the 6502's OKI, /WRIO and /MIX writes and its reads of the
  command dispatcher's type table (a dispatch only at PC 4375; other reads of the table are
  `lookup` lines) and of the effect-to-phrase table, in attract mode, a game and
  attract mode with every OKI command injected, each from an empty private state
  (`build/mame/state-okitrace-<run>`), into `build/mame/okitrace-<run>.txt` (each run must
  write its done marker); then `tools/adpcm survey` rewrites `data/oki/samples.json` (layout,
  names kept, commands, starts per run) and fails on a start the 6502's tables do not explain
  (docs/10-adpcm.md section 4).
- `tools/test_jsa.py` (CI, no ROMs; docs/09 section 8): `asm/jsa/jsa.asm` assembles with 64tass
  to MAME's size, CRC-32 and SHA-1 of `136070-2123.10c`; a changed operand changes the hash, a
  moved region fails its guard, the IDA names are in the source, and the committed
  `artifacts/sndtrace-summary.json` agrees with the source. The synthetic `make all` of
  `tools/test_build.py` carries the image the 6502 source assembles to and checks that an
  operand edited in the copy reaches 10c.
- `make sndtrace` (needs MAME and the ROMs; never in CI; `-j3` runs its three MAME runs side by
  side): `tools/mame/sndtrace.lua` records what the 6502 executes and reads, the 68010's command
  bytes and the 6502's responses, the YM2151 and OKI writes, in attract mode with the factory
  NVRAM, in attract mode with "SOUNDS IN ATTRACT" on and in a started game, each from its own
  empty private state, into `build/mame/sndtrace-*.txt`; `tools/sndtrace.py summary` checks
  them against the source and rewrites `artifacts/sndtrace-summary.json` (docs/09 section 7).
- `make soundcheck` (needs MAME and the ROMs; never in CI): after `make check`, the reference
  set and the rebuilt one (`-rompath build/roms`, confirmed by `-verifyroms`) each run 3000
  frames of attract mode with its sound on, headless; their YM2151 and OKI write streams,
  commands and responses must be equal and the reference must key on (docs/09 section 8). It runs
  only on a byte-identical set: `make check` is its prerequisite and stops on any differing byte
  before MAME starts, so it never compares a moved build (that comparison is a manual procedure,
  docs/09 section 3 item 7).
- `make listen`: the listening check, Jesus's: MAME on the rebuilt set in a window with sound,
  from an empty private state, attract mode with its sound on (docs/09 section 6). The one
  target that opens a window.
- `make somdump` (needs MAME and the ROMs; never in CI): `tools/mame/somdump.lua` captures the
  SOM display list at the frames of `SOM_ATTRACT` (attract mode), `SOM_GAME` (a game started at
  frame 900) and `SOM_DITHER` (attract mode with every colour word's two bytes made different,
  `SOM_DITHER=1`, docs/08 section 5) into `build/mame/som/<attract|game|dither>-f<N>/` (SOM banks, ADSP data RAM, the GSP command
  buffer, the frame-buffer page before and after the list, colour and image tables, palette,
  snapshots, the frame's protocol events), then runs `tools/displaylist.py` on each: decode,
  redraw, compare with MAME's page (docs/08-display-list.md). It removes the previous
  `attract-f*`, `game-f*` and `dither-f*` captures first, and the target fails when a run did not
  write its done marker (`<prefix>done`, written by `somdump.lua` just before it exits: MAME exits
  0 even when a Lua callback raises, so a broken script would otherwise run out its 600 seconds
  silently) or left no `som.bin`, `fb_som.bin` or `snap_1.png` for a requested frame, when a
  capture does not decode, or when its redrawing differs from the page (`--render` exits 2; each
  capture's output also goes to `render.txt` in its directory). Each of its three MAME runs starts
  from an empty private state, `build/mame/somstate` (removed first, then `-nvram_directory` and
  `-cfg_directory` there): the game boots from the set's own 200e/210e, attract mode (which
  follows the NVRAM's history) shows the same scenes on every run and machine, the user's
  `~/.mame` state is never read or written, and parallel worktrees stay apart. `make test` then
  also checks the captures
  (`tools/test_displaylist.py`, which skips without them); the three lists committed under
  `artifacts/display-list/` are decoded and redrawn in CI.
- `make fieldext` (needs MAME and the ROMs; never in CI): `tools/mame/fieldext.lua` counts, under
  `-debug -debugger none` and from an empty private state (`build/mame/fieldstate`), the GSP's
  ST FE0 (field 0 sign-extended) at the start of every list FFF46E30, at command 7 FFF44BF0, at
  the image-quad corner read FFF49380 and at the SOM command loop FFF45010 over `FIELD_FRAMES`
  attract frames, into `build/mame/fieldext.txt` (docs/08 section 4.4: each list starts
  sign-extended, and the 9 and 5 before every captured 7 reset field 0 to zero-extended).
- `make depthkeys` (needs MAME and the ROMs; never in CI): `tools/mame/depthkeys.lua` walks the
  ADSP's draw-order node list in PM (head PM 123F to tail 1242) at every 7th frame while the
  ADSP waits at 0013-0015, over `DEPTH_FROM`-`DEPTH_TO` in attract mode and up to
  `DEPTH_GAME_TO` in a game, each from an empty private state (`build/mame/depthstate`), and
  writes `build/mame/depthkeys-{attract,game}.txt`: per frame the adjacent pairs whose key rises
  and the largest rise (docs/08 section 1.5: never above 10h, the bias of 07C1-07C5).
- `make vskip` (needs MAME and the ROMs; never in CI): `tools/mame/vskip.lua`, under
  `-debug -debugger none` and from an empty private state (`build/mame/vskipstate`), counts the
  GSP's polygon row tests (FFF454C0) and the rows its V test skips (FFF454D0, ST bit 28), each
  skipped row logged with its frame, B2 (y, xl) and the stipple pattern B9, from frame 0 to
  `VSKIP_TO` in attract mode and to `VSKIP_GAME_TO` in a game, into
  `build/mame/vskip-{attract,game}.txt` (docs/08 section 5).

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

Since the residue word became a constant (`make coverage`, 2026-11-05), page 0 has no blob and
the object image none at all:

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `../../build/obj/page0.asm` | 131,072 | 0 | 126,680 | 0 | 4,392 |
| `../../build/obj/page1.asm` | 131,072 | 0 | 130,288 | 0 | 784 |
| `../../build/obj/page2.asm` | 131,072 | 0 | 39,304 | 0 | 91,768 |

`blob: 74.0% of 1511424 bytes come from incbin/.binary` (1,118,208 blob bytes, 2 fewer than
after M3a; 73.98% in the JSON line before and after).

After M4b (`make coverage`, 2026-11-05) the OKI image's phrase table is source and its tail a
fill; the 52 samples stay blob (they are ROM content, recovered from the WAVs under `build/`):

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `asm/oki/samples.asm` | 424 | 0 | 424 | 0 | 0 |
| `../../build/oki/samples.asm` | 261,720 | 0 | 0 | 260,864 | 856 |

`blob: 73.9% of 1511424 bytes come from incbin/.binary` (1,116,928 blob bytes, 1,280 fewer).

After M4a (`make coverage`, 2026-11-05, on top of M4b) the 6502 image has no blob:

| Source file | Bytes | instr | data | blob | fill |
|---|---|---|---|---|---|
| `asm/jsa/jsa.asm` | 37,816 | 0 | 7 | 0 | 37,809 |
| `asm/jsa/*.asm`, `asm/jsa/data/*.asm` (region files) | 27,720 | 7,351 | 20,369 | 0 | 0 |
| **stunrun-jsa** | **65,536** | **7,351** | **20,376** | **0** | **37,809** |

`blob: 69.6% of 1511424 bytes come from incbin/.binary` (1,051,392 blob bytes, 65,536 fewer);
the per-file table is docs/09 section 2.

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
