# Plan: milestones from "ROMs verified" to "full source builds the set"

**Date**: 2026-11-04. Each milestone has an acceptance check that a machine or a second reader can run; a milestone is done when its check passes and its decisions are in `CLAUDE.md`. Milestones after M1 run as rooms under the parallel delivery process (`~/.claude/notes/autonomous-parallel-delivery-process.md`): a coordinator, one issue per work item, Opus agents on Workflow with the adversarial review stage, byte-identical build in CI as the objective gate. Do not start a milestone in a room scoped to the previous one.

Ordering rationale: the object-ROM format and the GSP/ADSP program locations are the two unknowns that decide what the asset pipeline can be, so they come right after the build skeleton, before any large 68k annotation effort.

## M0. Kickoff (this leg, `feat/261104-kickoff`)

Hardware map from MAME, toolchain proposal, this plan, `CLAUDE.md`, ROM location rule and `tools/check-roms`. **Check**: the four documents exist and agree; `tools/check-roms --selftest` passes; the repo has no ROM content.

## M1. ROMs verified, image merged, first disassembly loaded

- The set at `~/archive/261104-stun-runner/roms/stunrun/`; `tools/check-roms` and `mame -verifyroms stunrun` pass; `mame stunrun` runs to attract mode.
- vasm built and pinned; unidasm built; `uv sync`; idalib activated for this repo (Spindizzy recipe).
- `tools/merge-roms` builds `build/stunrun-68k.bin` (768 KB, interleaved) and `tools/split-roms` reverses it; `tools/check-roms` accepts a build directory as well as the archive.
- Makefile skeleton: `make` assembles a 68k tree that is one `incbin` per ROM pair plus the 6502 file and the data ROMs as blobs; `make check` passes trivially. This is the zero point of the coverage number.
- IDA databases created: 68k (`data/stunrun-68k.i64`) and 6502 (`data/stunrun-jsa.i64`), auto-analysed, vector table and the memory-map addresses of docs/01 named as segments and I/O labels. Headless export works. (M1b: the databases are build artefacts of `make ida`, never committed; the annotation snapshots `data/ida/*.json` are, docs/05-ida.md.)

**Check**: `make check` green with 100% blob coverage; `uv run python -m ida.headless.export` writes `functions.jsonl` for both databases; CI runs `make check` with the reference hashes only (no ROMs in CI: the check compares hashes of files that are absent and must report "reference set absent, skipped" without failing, while the assemblers' own tests run).

## M2. Code map: where each program lives

- 68k: find the reset vector path, the copy loops that write the GSP program through C00000 and the ADSP program through 800000, and the ADSP data RAM initialisation. Name them. Record the source ranges of the GSP and ADSP programs in the 68k image and their destination addresses.
- Extract both programs with `tools/extract-programs` into `build/gsp/program.bin` and `build/adsp/program.bin`; prove them against MAME: a debugger dump of GSP VRAM at the program's address and of ADSP program RAM after boot equals the extracted bytes.
- First unidasm listings of both, with sidecar annotation files; identify the ADSP's /SIMBUF reader and the GSP's main loop (the speedup addresses of docs/01 are the hints).
- 68k: segment the 768 KB into code, 68k data, GSP program, ADSP program, and data consumed by each processor (identified by who copies it where). Record the partition.
- Check for 68k code running from RAM; record the answer.

**Check**: `make coverage` shows the GSP and ADSP programs as named blobs with their own files; the extracted blobs equal the MAME dumps byte for byte (a committed `tools/test_programs.py` reproduces the comparison from a `-debug` script or from saved dumps); docs/06 lists the partition with addresses.

## M3. The object ROM format and the display list (the "what are the meshes" question)

- From the ADSP code: how /MP, /SIMCLK and /SIMBUF are driven; the record layout of the object data (headers, vertex lists, polygon lists, colours, scale); which objects exist; how the 68k selects them (indices in ADSP data RAM).
- From the ADSP and GSP code: the SOM display-list format (the structure MAME's `deferred_adsp_bank_switch` logs: command table, slope pairs, index table) and how the GSP rasterises it.
- `tools/objects/` decodes the 384 KB into a mesh file per object (a JSON or OBJ with vertices, faces, colours) plus a manifest, and re-encodes to bytes; round trip byte-identical for the whole region.
- A viewer (Three.js or matplotlib dump) for eyeballing the tunnel segments and vehicles; not a product, a verification aid.

**Check**: `make test` round-trips the six object ROMs through meshes with zero differences; docs/07 names every object and shows at least three rendered; the record layout cites the ADSP instructions that read each field.

## M4. The 6502 sound program as source

- Partition `136070-2123.10c` into regions; 64tass tree; IDA names; the YM2151 patch tables and sequencer data as data files; the command protocol with the 68k (the byte written at 600000 and the response) documented, since the 68k side names its sound commands by it.
- ADPCM: split the 256 KB into samples by the OKI phrase table the code uses; `tools/adpcm` to WAV and back. M4b made it a lossless byte round trip through a WAV that carried the ADPCM bytes as they are; since M4g (Jesus, card A7, option 2) the samples are committed PCM WAVs, the decoder's output, and the build re-encodes them (docs/10).

**Check**: `make check` green with the 6502 ROM entirely from source (coverage: no blob in `10c`) and the OKI image from the committed WAVs (no blob in the OKI image; the encoder gives all 52 samples back byte for byte); a MAME run with the rebuilt file plays the attract-mode music (listening is Jesus's check; the byte check is the machine's). Listening done: Jesus ran `make listen` on 2026-11-05 and heard the sound (card A5).

**Done 2026-11-05** (legs M4a-M4g, docs/09-docs/12), measured: `make check` 25 files, 0 differences; `136070-2123.10c` is assembled from `asm/jsa` alone (`make coverage`: `stunrun-jsa` instr 7,351, data 20,376, fill 37,809, blob 0), and CI assembles it to MAME's CRC-32 and SHA-1 without the ROMs (`tools/test_jsa.py`); the OKI image is built from the 52 committed PCM WAVs of `data/oki` (blob 0) and the encoder gives every sample back byte for byte; CI checks its four chips' CRC-32 and SHA-1 from the WAVs without the ROMs (docs/10, M4g); the 6502's 59 stream ops are documented from their handlers, and its data is structured source, every address a label: the 119 streams the 125 entries of the sound table start, 13 streams no pointer reaches and 101 YM2151 patch records (docs/12); the protocol is documented from both programs and MAME, with the 68010's own name for 108 of the 109 command values (03, which the audio test omits, is `cmd_03_imm`) in `data/sound/commands.json` (docs/11); the 6502 IDA database follows the source through `make ida-sync` (1,018 names, 147 functions, 1,702 comments; docs/05 section 6); `make soundcheck`: the reference and the rebuilt set give equal YM2151 and OKI write streams over 3000 frames of attract mode with its sound on (62,115 YM2151 writes, 261 key-ons, 405 OKI commands). The set's blob share is 52.3% (790,528 of 1,511,424 bytes: the 68k image and the NVRAM). The listening check is done: Jesus ran `make listen`, MAME on the rebuilt set with sound, on 2026-11-05 and heard the sound (card A5; docs/09 section 6 says when attract mode plays).

## M5. 68k source: waves by region

The Spindizzy wave pattern: wave 0 fixes the partition and the shared files (main include, hardware equates for docs/01's map, Makefile, tools, the IDA annotation snapshot); each later leg owns one region file and converts it from `incbin` to source, with IDA names carried in and corrected where the code disproves them. Regions are defined by M2's partition; a leg's acceptance is byte-identical reassembly of its region plus every address in the region accounted for by an instruction, a data statement, a named table or a `ds` fill, with no raw `dc.w` runs left unexplained except documented residue.

Legs, as agreed with Jesus on 2026-11-16 ("mechanical first"; he delegated the order and the split to the coordinator):

1. **Wave 0, M5-0** (issue #28, docs/13-68k-source.md): the partition into region files with guards, the zero fills and the program table as source, `asm/68k/hardware.asm`, the coverage gate, `make labels`. Done 2026-11-16 (below).
2. **M5g** (issue #29, docs/14): the descent and generator tools (`tools/m68k`, `data/68k`, `asm/68k/macros.asm`) the conversion legs use.
3. **Conversion legs**, in parallel, each owning region files of docs/13 section 2 and turning them into byte-identical neutral source (IDA's names and neutral labels): **boot code** (`boot/`), **game code** (`game/`), **game data** (`data.asm`), **images** (`images.asm`, `image_table.asm`: the packed GSP images become committed PNGs, docs/15).
4. **Naming waves** after them, the old sub-milestones: 5a boot, vectors, interrupt handlers, the loaders (already named in M2); 5b the main loop and game state; 5c input, ADC, NVRAM, DUART; 5d the ADSP interface (scene building) and the GSP interface (text, HUD, palette); 5e attract mode, high scores, test mode; 5f the tunnel/course data and tables (data regions as structured source or extracted files, like Spindizzy's `world.asm`).

**Check**: per leg `make check`, `make coverage MAX_BLOB="asm/68k/<file>=0"` (the leg's region file reports 0 blob bytes, or only documented residue), `make labels` (every IDA snapshot name in converted source is a label at its address; docs/13 section 7); at the end the 68k image is 100% source and data files. (For the 6502 the same check as `make labels` is `tools/test_ida_sync.py`, which fails in CI when the committed snapshot's names are not the source's, docs/05 section 6.)

**M5i done 2026-11-16** (issue #34, docs/15-gsp-images.md): pairs U-W are built from `data/gsp-images` (140 indexed PNGs and a manifest) with their colours from `data/palettes` (32 palettes, compared with the image by `make check`); `images.asm` and `image_table.asm` 0 blob; the 68k blob 359,222 bytes (from 691,513), the set's blob share 23.8%; CI checks the six chips' CRC-32 and SHA-1 from the committed data; `make imgtrace` checks every unpacking MAME makes (48 of 54 streams reached, all 23 level maps).
**M5c done 2026-11-16** (issue #33, docs/16), measured: all the 68k code is neutral vasm source (44,683 instructions, 163,638 bytes) in `boot/vectors.asm`, six `boot/code_*.asm`, `game/vectors.asm`, nine `game/code_*.asm` and `game/island.asm`, cut at routine starts into files of about 16 KB, with one shared `asm/68k/ram.asm`; `make check` 25 files, 0 differences; the code files' blob is exactly their unknown and unexplained-data slices (60,999 bytes); the 68k blob 517,266 bytes (from 691,513), the set's blob share 34.2%; `make labels`: 223 snapshot names in ROM, 223 labels, 0 in blob, 0 failures; `make m68k-check` runs the descent check, the address lint, the raw-data check, the shift test and the MAME check on the tree's own listing (0 errors), and CI runs them on the tree assembled against a random blob; the 32 undecided operands are decided.

**Wave 0 done 2026-11-16** (M5-0, docs/13), measured: `make check` 25 files, 0 differences; `asm/68k` is nine region files with guards at both ends; the six zero runs (94,883 bytes) are fills and the program table's pointers and text (36 bytes) data; the 68k blob is 691,513 bytes (from 786,432); the NVRAM images, both entirely zero, are fills; the set's blob share is 45.8% (691,513 of 1,511,424); `make labels`: 223 snapshot names in ROM, 11 labels in the tree, 212 in blob, 0 failures.

## M6. GSP and ADSP programs as source

- `tools/asm34010` and `tools/asm2100`: Python assemblers covering the instruction forms the programs use; unit tests round-trip every form against unidasm; the programs assemble from annotated source into `build/gsp/program.bin` and `build/adsp/program.bin` byte for byte.
- The GSP's bitmap data (fonts, HUD elements, if any are bitmaps) extracted to PNG with a documented layout and re-embedded.

**Check**: `make check` green with no blob anywhere (`make coverage` reports 0 `incbin` bytes); `make test` round-trips both assemblers against unidasm over the whole programs.

## M7. Full source, assets external, variants

- Every asset class outside the binary: meshes (M3), samples (M4), fonts and HUD bitmaps (M6), palettes, course data (M5f), text strings.
- IDA sync: names and comments from the source into both databases; the exports committed. (The 6502's is done, M4f: `make ida-sync`, docs/05 section 6; the 68k's follows M5.)
- Variants: the ten other sets as alternative builds of the same tree where the diff is small (conditional assembly or per-set data files), each verified against its MAME hashes by `tools/check-roms --set <name>`; where a set diverges too far, record it as out of scope with the measured diff.
- README and `CLAUDE.md` final; a `docs/NN-findings.md` with what the original code does that documentation never said (the Spindizzy "findings" section is the model).

**Check**: `make check` for `stunrun` and for every variant that is in scope; CI green; the repo contains no ROM bytes (a CI job greps the tree for the known hashes and for long hex runs).

## Early question carried from the brief

*Where does the pseudo-3D tunnel rendering live, sprite/RLE data or code?* Answered by the hardware (docs/01): neither. The tunnel is polygon geometry in the object ROMs, transformed by the ADSP-2100 and rasterised by the TMS34010. "Assets as meshes" is literal; M3 defines the mesh format from the ADSP reader.

## Decisions taken in M0 (Jesus, 2026-11-04)

- Reference set: `stunrun` (rev 6). Variants are M7.
- Three tiers of source (docs/02 section 2): 68k and 6502 first, GSP and ADSP as verified blobs until M6.
- IDA for 68k and 6502; sidecar annotation for the TMS34010 until the GSP code justifies more.
- This kickoff is a single-session documentation leg; the parallel process starts with M1/M2 in a new room that Vera opens once this one is reaped.
- The repository is public on GitHub (`jlopez/stun-runner`); ROM content stays out of it absolutely.
