# S.T.U.N. Runner (Atari Games, 1989): full decompilation

Goal: a complete source reverse-engineering of the S.T.U.N. Runner arcade game (MAME set `stunrun`,
rev 6) that **assembles back into the 25 files of the ROM set byte for byte**, with human-friendly
labels, and the game's assets (3D objects, samples, fonts, palettes, course data) extracted to
editable forms that the build re-embeds. Same spirit as the Spindizzy decomp
(`~/git-repos/personal/spindizzy`, `docs/26-assembler-source.md`).

The game is Hard Drivin' hardware, not a sprite board: a 68010 drives a TMS34010 graphics processor
and an ADSP-2100 that transforms polygon objects streamed from serial ROMs, with a JSA II 6502 sound
board. Four instruction sets, no graphics ROMs. Details with MAME references in
[`docs/01-hardware.md`](docs/01-hardware.md).

`CLAUDE.md` is the design notebook (goal, rules, reading order, milestones, decisions). Start there.

| Document | What |
|---|---|
| [`docs/01-hardware.md`](docs/01-hardware.md) | boards, ROM set and variants, the 68010 / GSP / ADSP / 6502 address spaces |
| [`docs/02-toolchain.md`](docs/02-toolchain.md) | assemblers (vasm, 64tass, in-repo assemblers for the DSPs), IDA, MAME as oracle, the byte-identical check |
| [`docs/03-plan.md`](docs/03-plan.md) | milestones M0-M7 with acceptance checks |
| [`docs/04-build.md`](docs/04-build.md) | the build: five images, assembler trees, split, byte check, coverage, CI |
| [`docs/05-ida.md`](docs/05-ida.md) | the IDA databases: made by `make ida`, never committed; annotation snapshots in `data/ida/` |
| [`docs/06-code-map.md`](docs/06-code-map.md) | the code map: boot and game programs, the GSP and ADSP programs and their loaders, the MAME proof, the partition of the 768 KB |

## ROMs

The ROMs are **not in this repository and never will be** (the repo is public). Put the set at
`~/archive/261104-stun-runner/roms/stunrun/` (the 25 loose files) or
`~/archive/261104-stun-runner/roms/stunrun.zip`, then:

```bash
make roms           # tools/check-roms: every file's size, CRC-32 and SHA-1 against MAME's list
mame -verifyroms stunrun
```

## Build

Needs `vasmm68k_mot` (vasm 2.0f, built from source: `make CPU=m68k SYNTAX=mot`), `64tass` and
`uv`. Details in [`docs/04-build.md`](docs/04-build.md).

```bash
uv sync             # ruff, mypy, pytest (UV_FROZEN=1 outside the canonical checkout, docs/04 section 6)
make                # merge the set into five images, cut out the GSP/ADSP programs, assemble asm/*,
                    # split into build/roms/stunrun/
make check          # the 25 built files against MAME's hashes and byte for byte against the set
make coverage       # bytes per source file: instructions, data, incbin blobs, fills; every blob by label
make test           # tool self-tests on synthetic data (no ROMs needed)
make lint           # ruff + mypy
make clean
```

IDA (optional, needs IDA Professional 9.1 with idalib activated; [`docs/05-ida.md`](docs/05-ida.md)):

```bash
uv sync --group ida
make ida            # data/stunrun-68k.i64, data/stunrun-jsa.i64 (gitignored: they contain the ROM bytes)
make ida-export     # data/ida/*.json + *.functions.jsonl (commit these), build/ida/*.asm
make ida-annotate   # re-apply ida/memory_map.py + ida/code_map.py over the databases, then ida-export
```

The GSP and ADSP programs (needs MAME's `unidasm` on PATH, and `mame` for the oracle;
[`docs/06-code-map.md`](docs/06-code-map.md)):

```bash
make dasm           # build/{gsp,adsp}/program.lst and program.annotated.lst (sidecars data/*/annotations.json)
make oracle         # MAME runs the set and dumps GSP VRAM, ADSP program/data RAM into build/mame/
make test           # now also compares the extracted programs with those dumps (skips without them)
make pcwatch        # MAME -debug: highest and lowest 68k PC over 3,600 frames (code in RAM?)
```

Without the reference set, `make check` prints `reference set absent, skipped` (this is what CI
sees) and `make` itself fails: there is nothing to incbin.

`tools/romsets/stunrun.json` is the committed snapshot of `mame -listxml stunrun` (hashes only);
`make roms-refresh` regenerates it from an installed MAME.

Seeded 2026-11-04 by Vera from Jesus's brief; the kickoff leg (`feat/261104-kickoff`) wrote the
hardware map, toolchain choice, plan and notebook.
