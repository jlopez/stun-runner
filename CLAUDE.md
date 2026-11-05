# S.T.U.N. Runner decompilation: design notebook

This file is the memory every agent inherits. It records decisions, not code: `docs/` holds the evidence and the code holds the details. When you change a decision, change it here in the same PR.

Owner: Jesus (reverse engineer; the Spindizzy decomp at `~/git-repos/personal/spindizzy` is the precedent for method, tooling and standard of evidence). Agents work autonomously on bounded legs and discuss conclusions that change the architecture before committing them.

## 1. Goal (agreed 2026-11-04)

A complete source reverse-engineering of S.T.U.N. Runner (Atari Games, 1989, MAME set `stunrun`, rev 6) that **assembles back into the 25 files of the ROM set byte for byte**, with human-friendly labels (local labels where they help), and every asset (3D objects, samples, fonts, palettes, course data, text) extracted to an editable external form that the build re-embeds. Assembly, not C: the game is four programs on four instruction sets, 68010, TMS34010, ADSP-2100 and 6502 (docs/01), and all four end up as source (docs/02 section 2, three tiers).

## 2. The rules

- **Byte-identical or it isn't done.** `make check` compares every built file with the reference hashes (`tools/romsets/stunrun.json`, the same CRC-32 and SHA-1 MAME lists) and is the definition of done for every leg. Coverage of "source versus blob" only goes down (`make coverage`). No step may leave the image different from the original, not even "temporarily".
- **ROMs stay outside the repository, always.** The set lives at `~/archive/261104-stun-runner/roms/stunrun/` (loose files) or `…/roms/stunrun.zip`; MAME's `~/.mame/mame.ini` points there. The repo holds hashes, offsets and names, never bytes: no ROM files, no `incbin` of the archive path, no hex dumps of ROM content in documents beyond the few bytes an argument needs, no MAME dumps of ROM-derived memory as committed artefacts unless they are the game's RAM state. `.gitignore` covers `roms/`, `build/` and `*.zip`. ROMs are Jesus's to obtain; nobody downloads sets. This repo is public.
- **Bytes come from the ROM files, never from a database.** IDA gives names, comments and the code/data classification. Every claim about the code cites an instruction address or a MAME dump.
- **MAME is the oracle** (docs/02 section 4): the behaviour of a rebuilt image is checked by running it; a claim about where a program lives is checked by a debugger dump.
- **Annotate in the database or the source, never only in prose.** Once a region is source, the source is the truth and IDA follows it through `make ida-sync`.
- **Scratch outputs** go to the session scratchpad; durable evidence goes to `artifacts/` (small) or LFS (large).

## 3. Reading order for a new agent

1. This file.
2. `docs/01-hardware.md`: the boards, the ROM set, the three address spaces and the sound board, with the MAME references. Read it before touching any address.
3. `docs/02-toolchain.md`: assemblers, disassemblers, MAME and the build check.
4. `docs/03-plan.md`: milestones and acceptance checks; find the milestone your room is scoped to and do not cross into the next.
5. `docs/04-build.md`: how `make`, `make check` and `make coverage` work, the five images and the tool versions.
6. `docs/05-ida.md`: the IDA databases (built by `make ida`, never committed), the snapshot rule and the 6502 bank scheme.
7. `docs/06-code-map.md` (where the four programs live) and `docs/07-objects.md` (the object ROMs, `data/objects`) when your work touches them.
8. Spindizzy's `CLAUDE.md` sections 5-7 and 12 and `docs/26-assembler-source.md`: the method (bottom-up, evidence standard, naming conventions), the partition-by-region wave pattern and the IDA sync.
9. `~/.claude/notes/autonomous-parallel-delivery-process.md` when you coordinate a wave.

## 4. Milestones (short list; checks in docs/03)

0. **Kickoff** (this leg, 2026-11-04): hardware map, toolchain, plan, this notebook, `tools/check-roms`.
1. ROMs verified, image merged and split, Makefile skeleton with 100% blob coverage, IDA databases loaded, CI.
2. Code map: the GSP and ADSP programs located in the 68k image, extracted and proven against MAME dumps; partition of the 768 KB. Done 2026-11-04 (docs/06): both programs in pair R at 0x01702E-0x01EFD4 through the table at 0x017000, equal to MAME's memory but one runtime word; no 68k code in RAM.
3. Object ROM format and display list: meshes out, meshes in, byte-identical.
4. 6502 sound program as source; ADPCM samples external.
5. 68k source by region waves.
6. GSP and ADSP programs as source through in-repo assemblers proven against unidasm.
7. Everything external, variants, final docs.

## 5. Decisions log

- 2026-11-04 (Jesus): reference set `stunrun` rev 6; three tiers of source; IDA for 68k and 6502, sidecar annotation for the TMS34010 until justified otherwise; kickoff stays a single-session doc leg, the parallel process begins at M1/M2 in a new room; repository public; MAME installed from brew, unidasm to be built from source.
- 2026-11-04 (Jesus, card A1 approved; proposed by the M1b coordinator): the IDA databases are never committed, not even through LFS: an `.i64` embeds the ROM bytes and the repo is public (rule 2 wins over docs/02's kickoff plan). `make ida` builds them from `build/*.bin`; the repo commits per database an annotation snapshot `data/ida/<name>.json` and `functions.jsonl`, and create -> export reproduces them exactly (docs/05).
- 2026-11-04 (M1b): the 68010 vector table is vectors 0-63 only (the reset PC, 0x216, lies in the user-vector area); 6502 bank n lives at linear `(n+1)<<16 | 0x3000` with base 0, because m65 resolves operands relative to a based segment and would break references to I/O and the fixed ROM (docs/05).
- 2026-11-04 (finding): the brief's hardware list was wrong. Not atarig1: Hard Drivin' multisync hardware, no SLOOP, no RLE objects, no graphics ROMs; the tunnel is polygon geometry in the ADSP object ROMs (docs/01).
- 2026-11-04 (M1a, coordinator): the build works on five images, one per address space: `stunrun-68k` (768 KB, the 200x/210x pairs interleaved, offset = 68010 address), `stunrun-obj` (384 KB object ROMs interleaved), `stunrun-oki` (256 KB), `stunrun-jsa` (64 KB) and `stunrun-nvram` (200e + 210e); `tools/merge-roms` makes them from the set by the snapshot's regions and offsets, each is a separate assembler output, and `tools/split-roms` cuts them into the 25 files (docs/04).
- 2026-11-04 (M1a, coordinator): every one of the 25 files comes from an assembler listing (vasm for the 68k and data trees, 64tass for the 6502), so one coverage number covers the whole set; an `incbin`/`.binary` source is always a build artefact under `build/`, never the archive path.
- 2026-11-04 (M1a): vasm pinned to 2.0f (`phoenix.owl.de/tags/vasm2_0f.tar.gz`, sha256 in docs/04); guards are `assert *=$addr,"msg"` in vasm and `.cerror` in 64tass; `make check` without the reference set prints `reference set absent, skipped` and exits 0 (CI), and `tools/bytecheck` reports offsets and counts, never byte values.
- 2026-11-04 (M2): the GSP and ADSP programs are extracted at build time by `tools/extract-programs` from `build/stunrun-68k.bin` (through the table at 0x017000; it checks the boundaries 0x01702E/0x01907C/0x01EFD4) into `build/{adsp,gsp}/program.bin`, the raw ROM streams, and pair R's incbin is split there: `rom_r`, `adsp_program`, `gsp_program`, `rom_r_tail`, with asserts at each boundary. The unpacked oracle images are `build/adsp/pm.bin` (0x2000 words, 32-bit little-endian, top byte 0) and `build/gsp/vram.bin` (a sparse image of GSP bit addresses FF800000-FFFFFFFF, words little-endian), each with a `*.ranges.json` of the loaded ranges; `tools/programs.py` implements the loaders instruction for instruction (docs/06 section 3).
- 2026-11-04 (M2): the oracle test `tools/test_programs.py` compares the extracted images with MAME's memory (`make oracle`, `tools/mame/dump.lua`, after 600 frames) over the loaded ranges only, word for word, and skips without dumps (CI). Its only exclusions are loaded words the coprocessor program itself writes, each listed in `GSP_RUNTIME_WORDS` (`tools/programs.py`) with the writing instructions' addresses; today one, GSP FFF5C8F0 (FFF46340, FFF479B0). A new exclusion needs the same evidence.
- 2026-11-04 (M2): GSP and ADSP annotations live in sidecars `data/{gsp,adsp}/annotations.json` (names and comments keyed by address in the listing's unit: GSP bits, ADSP PM words; no bytes); `make dasm` writes unidasm listings to `build/{gsp,adsp}/program.lst` and `tools/annotate-listing` merges the sidecar into `program.annotated.lst`, failing on an address that starts no listing line. M6's assemblers will read the same sidecars.
- 2026-11-04 (M2): the 68k code map's names are code (`ida/code_map.py`, applied with the memory map by `make ida`; `make ida-annotate` re-applies it over a database whose snapshot predates it). The boot program's vector targets are `boot_*`, the game's (table at 0x020000, installed by `movec` at 0x000294) `h_*` and `game_reset`; the game's vector longs `game_vec_*`.
- 2026-11-04 (M3a): the object ROMs are decoded (docs/07). Mesh format: `data/objects/NNN.json` per object (vertices and normals as signed 16-bit triples, faces as type, colour, 0-based normal index and 0-based vertex indices, in ROM order: integers exactly as in the ROM) plus `data/objects/manifest.json` (per page the object numbers in address order, the residue positions, provisional names); everything else (directory, point numbers, record pointers, polygon addresses, terminators, padding, the page-1 reciprocal table, the per-chip checksum words) is derived by `tools/objects`. Mesh files are derived data and committed; names in the manifest are provisional until M3c.
- 2026-11-04 (M3a): build wiring: `data/objects` is the source of the object image; `tools/objects asm` generates `build/obj/page{0,1,2}.asm` (`dc.w`/`dcb.w`, an assert per structure) and `asm/obj/objects.asm` includes them; `make check` proves the committed meshes rebuild the six files. Coverage: bytes generated from committed data count as `data`/`fill` under the generated file's path, no new class (blob 100.0% -> 74.0%). `tools/test_build.py` plants the encoded object image into its synthetic set; a CI test checks the four chips of pages 1 and 2 against MAME's hashes from the committed data alone.
- 2026-11-04 (M3a): residue rule outcome: one word, 0:019E (after the directory's FFFF), is unexplained; it stays an incbin slice of `build/stunrun-obj.bin` (2 bytes, position in the manifest, never its value), so the page-0 chips need the ROM image to rebuild. Pending Jesus (M3a report card): keep it as a blob, or accept it as a named constant.
- 2026-11-04 (M3a): `tools/mame/objtrace.lua` (`make objtrace`) is the object-ROM oracle: every ADSP read sequence (PC, page, address, words) in attract mode and a game, checked against the decoder by `tools/test_objects.py`; the committed summary `artifacts/objtrace-summary.json` holds addresses and counts only.
- 2026-11-04 (M1a): `uv.lock` is committed as resolved from the canonical checkout (the idapro path is checkout-relative); the Makefile runs `uv run --frozen`, other worktrees use `UV_FROZEN=1`.

## 6. Repository conventions

- Python with `uv`, `ruff` (line length 100), `mypy`; `make lint` (ruff on `tools` and `ida`, mypy) before committing.
- Branch per leg `feat/<yymmdd>-<slug>` or `fix/…`, PR against `main`, squash merge with a holistic message (never the concatenated default when a PR has several commits).
- `docs/NN-<slug>.md` per leg for narrative and evidence; decisions in this file in the same PR.
- IDA databases (`data/*.i64`) are build artefacts of `make ida`, gitignored, never committed. Annotate in IDA, then `make ida-export` and commit `data/ida/` (the snapshot is what the next `make ida` re-applies; an unexported annotation is lost). Other non-ROM binaries over a few hundred KB through Git LFS.
- Commit trailers as the session's system reminder specifies.
