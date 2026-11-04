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

**Check**: `make test` round-trips the six object ROMs through meshes with zero differences; docs/05 names every object and shows at least three rendered; the record layout cites the ADSP instructions that read each field.

## M4. The 6502 sound program as source

- Partition `136070-2123.10c` into regions; 64tass tree; IDA names; the YM2151 patch tables and sequencer data as data files; the command protocol with the 68k (the byte written at 600000 and the response) documented, since the 68k side names its sound commands by it.
- ADPCM: split the 256 KB into samples by the OKI phrase table the code uses; `tools/adpcm` to WAV and back (lossless byte round trip, not re-encoding).

**Check**: `make check` green with the 6502 ROM entirely from source (coverage: no blob in `10c`); samples round-trip byte-identical; a MAME run with the rebuilt file plays the attract-mode music (listening is Jesus's check; the byte check is the machine's).

## M5. 68k source: waves by region

The Spindizzy wave pattern: wave 0 fixes the partition and the shared files (main include, hardware equates for docs/01's map, Makefile, tools, the IDA annotation snapshot); each later leg owns one region file and converts it from `incbin` to source, with IDA names carried in and corrected where the code disproves them. Regions are defined by M2's partition; a leg's acceptance is byte-identical reassembly of its region plus every address in the region accounted for by an instruction, a data statement, a named table or a `ds` fill, with no raw `dc.w` runs left unexplained except documented residue.

Sub-milestones in dependency order: 5a boot, vectors, interrupt handlers, the loaders (already named in M2); 5b the main loop and game state; 5c input, ADC, NVRAM, DUART; 5d the ADSP interface (scene building) and the GSP interface (text, HUD, palette); 5e attract mode, high scores, test mode; 5f the tunnel/course data and tables (data regions as structured source or extracted files, like Spindizzy's `world.asm`).

**Check**: per leg `make check`, `make coverage` (the leg's region reports 0 blob bytes), `make labels`; at the end the 68k image is 100% source and data files.

## M6. GSP and ADSP programs as source

- `tools/asm34010` and `tools/asm2100`: Python assemblers covering the instruction forms the programs use; unit tests round-trip every form against unidasm; the programs assemble from annotated source into `build/gsp/program.bin` and `build/adsp/program.bin` byte for byte.
- The GSP's bitmap data (fonts, HUD elements, if any are bitmaps) extracted to PNG with a documented layout and re-embedded.

**Check**: `make check` green with no blob anywhere (`make coverage` reports 0 `incbin` bytes); `make test` round-trips both assemblers against unidasm over the whole programs.

## M7. Full source, assets external, variants

- Every asset class outside the binary: meshes (M3), samples (M4), fonts and HUD bitmaps (M6), palettes, course data (M5f), text strings.
- IDA sync: names and comments from the source into both databases; the exports committed.
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
