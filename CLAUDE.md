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
5. Spindizzy's `CLAUDE.md` sections 5-7 and 12 and `docs/26-assembler-source.md`: the method (bottom-up, evidence standard, naming conventions), the partition-by-region wave pattern and the IDA sync.
6. `~/.claude/notes/autonomous-parallel-delivery-process.md` when you coordinate a wave.

## 4. Milestones (short list; checks in docs/03)

0. **Kickoff** (this leg, 2026-11-04): hardware map, toolchain, plan, this notebook, `tools/check-roms`.
1. ROMs verified, image merged and split, Makefile skeleton with 100% blob coverage, IDA databases loaded, CI.
2. Code map: the GSP and ADSP programs located in the 68k image, extracted and proven against MAME dumps; partition of the 768 KB.
3. Object ROM format and display list: meshes out, meshes in, byte-identical.
4. 6502 sound program as source; ADPCM samples external.
5. 68k source by region waves.
6. GSP and ADSP programs as source through in-repo assemblers proven against unidasm.
7. Everything external, variants, final docs.

## 5. Decisions log

- 2026-11-04 (Jesus): reference set `stunrun` rev 6; three tiers of source; IDA for 68k and 6502, sidecar annotation for the TMS34010 until justified otherwise; kickoff stays a single-session doc leg, the parallel process begins at M1/M2 in a new room; repository public; MAME installed from brew, unidasm to be built from source.
- 2026-11-04 (finding): the brief's hardware list was wrong. Not atarig1: Hard Drivin' multisync hardware, no SLOOP, no RLE objects, no graphics ROMs; the tunnel is polygon geometry in the ADSP object ROMs (docs/01).

## 6. Repository conventions

- Python with `uv`, `ruff` (line length 100), `mypy`; `uv run ruff check tools` before committing.
- Branch per leg `feat/<yymmdd>-<slug>` or `fix/…`, PR against `main`, squash merge with a holistic message (never the concatenated default when a PR has several commits).
- `docs/NN-<slug>.md` per leg for narrative and evidence; decisions in this file in the same PR.
- IDA databases (`*.i64`, packed, closed before committing) and other binaries over a few hundred KB through Git LFS.
- Commit trailers as the session's system reminder specifies.
