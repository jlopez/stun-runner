# S.T.U.N. Runner: assemble the five trees under asm/ into the 25 files of the stunrun set,
# byte for byte (docs/04-build.md). The ROMs live outside the repo (CLAUDE.md section 2): the
# blobs the trees incbin are build artefacts that tools/merge-roms makes from the reference set.

VASM   ?= vasmm68k_mot
TASS   ?= 64tass
UNIDASM ?= unidasm
MAME   ?= mame
PYTHON ?= uv run --frozen python
SET    := stunrun
BUILD  := build
ROMDIR := $(BUILD)/roms/$(SET)

VASMFLAGS := -quiet -Fbin -no-opt -m68010
TASSFLAGS := -q -C -b

VASM_IMAGES := stunrun-68k stunrun-obj stunrun-oki stunrun-nvram
IMAGES      := $(VASM_IMAGES) stunrun-jsa
OUTS        := $(IMAGES:%=$(BUILD)/%.out)
LISTINGS    := $(IMAGES:%=$(BUILD)/%.lst)

# image -> its tree's main source
SRC_stunrun-68k   := asm/68k/stunrun.asm
SRC_stunrun-obj   := asm/obj/objects.asm
SRC_stunrun-oki   := asm/oki/samples.asm
SRC_stunrun-nvram := asm/nvram/nvram.asm
SRC_stunrun-jsa   := asm/jsa/jsa.asm

ROMSET_TOOLS := tools/romset.py tools/romsets/$(SET).json

.PHONY: all check coverage test lint roms roms-refresh selftest clean ida ida-export ida-annotate \
	dasm oracle pcwatch objects objtrace objlevels pictures view somdump fieldext depthkeys vskip \
	okitrace oki-pcm sndtrace soundcheck listen FORCE
.SECONDEXPANSION:

# The split always runs (cheap): make 3.81 on macOS compares whole-second mtimes, so a stamp file
# could hide an image reassembled in the same second.
all: $(OUTS) tools/split-roms $(ROMSET_TOOLS)
	$(PYTHON) tools/split-roms --set $(SET) --images $(BUILD) --suffix .out --out $(ROMDIR)

# The blobs: rebuilt only when the layout tools change (make clean to re-read the archive). A
# pattern rule with several targets is one recipe for all five, in every make version.
$(BUILD)/%-68k.bin $(BUILD)/%-obj.bin $(BUILD)/%-oki.bin $(BUILD)/%-jsa.bin $(BUILD)/%-nvram.bin: tools/merge-roms $(ROMSET_TOOLS)
	$(PYTHON) tools/merge-roms --set $(SET) --out $(BUILD)

# Reached only through the pattern rule below, the blobs would be intermediate files make deletes.
.SECONDARY: $(IMAGES:%=$(BUILD)/%.bin)

# The ADSP and GSP programs, cut out of the 68k image (docs/06-code-map.md): the 68k tree incbins
# build/{adsp,gsp}/program.bin; the same run writes the oracle images pm.bin and vram.bin and
# their ranges (`make oracle`, `make dasm`). Two targets, one recipe: a pattern rule (stem
# "program"), as above.
PROGRAMS := $(BUILD)/adsp/program.bin $(BUILD)/gsp/program.bin
PROGRAM_TOOLS := tools/extract-programs tools/programs.py

$(BUILD)/adsp/%.bin $(BUILD)/gsp/%.bin: $(BUILD)/$(SET)-68k.bin $(PROGRAM_TOOLS)
	$(PYTHON) tools/extract-programs --image $< --out $(BUILD)

.SECONDARY: $(PROGRAMS)

# The object image's source (docs/07-objects.md): data/objects, turned into one vasm source per
# /MP page by tools/objects, from the committed data alone: the object image needs nothing from
# the reference set (the residue word is a constant in the manifest). Three targets, one recipe:
# a pattern rule (stem "page"), as above.
OBJECT_DATA := $(wildcard data/objects/*.json)
OBJECT_TOOLS := tools/objects/__init__.py tools/objects/__main__.py
OBJECT_ASM := $(BUILD)/obj/page0.asm $(BUILD)/obj/page1.asm $(BUILD)/obj/page2.asm

# A deleted or added mesh file leaves nothing newer than the generated sources, so they also
# depend on the list of file names, rewritten (and so touched) only when the list changes.
OBJECT_LIST := $(BUILD)/obj/data.list

$(OBJECT_LIST): FORCE
	@mkdir -p $(@D)
	@printf '%s\n' $(sort $(OBJECT_DATA)) > $@.tmp; \
	if cmp -s $@.tmp $@; then rm -f $@.tmp; else mv $@.tmp $@; fi

FORCE:

$(BUILD)/obj/%0.asm $(BUILD)/obj/%1.asm $(BUILD)/obj/%2.asm: $(OBJECT_DATA) $(OBJECT_LIST) \
		$(OBJECT_TOOLS)
	$(PYTHON) tools/objects asm --data data/objects --out $(BUILD)/obj

.SECONDARY: $(OBJECT_ASM)

# The OKI image's source (docs/10-adpcm.md): asm/oki/samples.asm holds the phrase table and
# includes build/oki/samples.asm, which tools/adpcm asm writes from data/oki/samples.json and one
# WAV per phrase in OKI_WAV_DIR: it recovers each sample's bytes from its WAV into
# build/oki/bin/NN.bin and incbins them. The WAVs come from the merged image (tools/adpcm split
# into build/oki/wav, the default OKI_WAV_DIR), so the image is byte-identical only if every
# sample survived WAV and back. `make OKI_WAV_DIR=dir` builds from edited WAVs (the manifest's
# names; a sample of another length needs its start/end, and every later phrase's, moved in the
# manifest). The split cuts the merged image by the image's own phrase table, never the
# manifest's, so an edited manifest does not stop it. Sample bytes, WAVs and decoded audio stay
# under build/.
OKI_MANIFEST := data/oki/samples.json
OKI_TOOLS := tools/adpcm/__init__.py tools/adpcm/__main__.py $(ROMSET_TOOLS)
OKI_WAV_DIR ?= $(BUILD)/oki/wav
OKI_SPLIT := $(BUILD)/oki/split.done
OKI_ASM := $(BUILD)/oki/samples.asm

$(OKI_SPLIT): $(BUILD)/$(SET)-oki.bin $(OKI_MANIFEST) $(OKI_TOOLS)
	$(PYTHON) tools/adpcm split --image $< --manifest $(OKI_MANIFEST) --out $(BUILD)/oki/wav
	@touch $@

# The WAVs -> bytes step and the OKI tree's assembly run on every `make` (cheap, as the split):
# an edited WAV saved in the same second as the last build, a removed WAV or another OKI_WAV_DIR
# must never leave a stale image (make 3.81 on macOS compares whole-second mtimes). So does
# `split --missing` on build/oki/wav: the stamp above does not see its WAVs, so a WAV deleted
# there, or a phrase renamed in the same second as the last split, is written again from the
# image (the other WAVs there, edited or not, are kept).
OKI_REFILL = $(PYTHON) tools/adpcm split --missing --image $(BUILD)/$(SET)-oki.bin \
	--manifest $(OKI_MANIFEST) --out $(BUILD)/oki/wav

$(OKI_ASM): $(OKI_SPLIT) $(OKI_MANIFEST) $(OKI_TOOLS) FORCE
	@$(OKI_REFILL)
	$(PYTHON) tools/adpcm asm --manifest $(OKI_MANIFEST) --wav $(OKI_WAV_DIR) --out $(BUILD)/oki

.SECONDARY: $(OKI_SPLIT) $(OKI_ASM)

# image -> the files its tree includes: its blob (the merged image) and any others; the object
# tree includes only the generated page sources, never build/stunrun-obj.bin, the OKI tree
# the generated include and the sample bytes recovered from the WAVs, and the 6502 tree is all
# source (docs/09-sound-program.md): its own files, data/ included, and nothing from build/
EXTRA_stunrun-68k   := $(BUILD)/stunrun-68k.bin $(PROGRAMS)
EXTRA_stunrun-obj   := $(OBJECT_ASM)
EXTRA_stunrun-oki   := $(OKI_ASM) FORCE
EXTRA_stunrun-nvram := $(BUILD)/stunrun-nvram.bin
EXTRA_stunrun-jsa   := $(wildcard asm/jsa/data/*.asm)

# The listing is a co-target of the assembly (a pattern rule with two targets is one recipe for
# both, in every make version), so a missing or stale listing reassembles its image.
ASM = $(if $(filter $(VASM_IMAGES),$*),$(VASM) $(VASMFLAGS),$(TASS) $(TASSFLAGS))

$(BUILD)/%.out $(BUILD)/%.lst: $$(SRC_$$*) $$(EXTRA_$$*) $$(wildcard $$(dir $$(SRC_$$*))*.asm)
	$(ASM) -L $(BUILD)/$*.lst -o $(BUILD)/$*.out $<

# The 6502 tree assembles on every make (64tass takes well under a second): make 3.81 compares
# whole-second mtimes, so an edit to asm/jsa in the same second as the last assembly would leave
# a stale image, and a planted-change probe run from a script (edit, make check, restore, make
# check) would check the wrong bytes. The pattern rule above still supplies the recipe.
$(BUILD)/stunrun-jsa.out $(BUILD)/stunrun-jsa.lst: FORCE

# Without the reference set (CI) there is nothing to build from or compare with: skip, exit 0.
check:
	@$(PYTHON) tools/check-roms --set $(SET) >/dev/null; rc=$$?; \
	if [ $$rc -eq 2 ]; then echo "reference set absent, skipped"; exit 0; fi; \
	if [ $$rc -ne 0 ]; then $(PYTHON) tools/check-roms --set $(SET); exit 1; fi; \
	$(MAKE) --no-print-directory all || exit 1; \
	$(PYTHON) tools/check-roms --set $(SET) --dir $(ROMDIR); hashes=$$?; \
	$(PYTHON) tools/bytecheck --set $(SET) --built $(ROMDIR) && [ $$hashes -eq 0 ]

coverage: all $(LISTINGS)
	$(PYTHON) tools/coverage --set $(SET) $(LISTINGS)

test: selftest
	$(PYTHON) -m pytest -q tools

PYTOOLS := tools/romset.py tools/listings.py tools/programs.py tools/test_*.py \
	tools/check-roms tools/merge-roms tools/split-roms tools/bytecheck tools/coverage \
	tools/extract-programs tools/dasm-programs tools/annotate-listing tools/displaylist.py \
	tools/sndtrace.py

lint:
	uv run --frozen ruff check tools ida
	uv run --frozen mypy --scripts-are-modules $(PYTOOLS)
	uv run --frozen mypy -p ida
	uv run --frozen mypy -p objects
	uv run --frozen mypy -p adpcm

# The IDA databases (docs/05-ida.md): build artefacts, never committed (they embed the ROM bytes).
# They need idalib (`uv sync --group ida`, IDA installed and activated), so neither target is part
# of `make test` or CI. `make ida` recreates both from the images and the committed snapshots
# data/ida/*.json; `make ida-export` writes the snapshots and functions.jsonl back (commit them)
# and the .asm listings to build/ida/ (never committed).
ida: $(BUILD)/$(SET)-68k.bin $(BUILD)/$(SET)-jsa.bin
	$(PYTHON) -m ida.headless.create all

ida-export:
	$(PYTHON) -m ida.headless.export all

# Re-apply the setup of ida/memory_map.py (and its code map, ida/code_map.py) over the databases
# `make ida` made: the committed snapshot wins over the setup on create, so a renamed setup entry
# needs this once, then `make ida-export`.
ida-annotate:
	$(PYTHON) -m ida.headless.annotate all

# The GSP and ADSP programs as unidasm listings with the sidecars merged in (docs/06-code-map.md
# section 6). The listings contain the program bytes: build output, never committed.
dasm: $(PROGRAMS) tools/dasm-programs tools/annotate-listing data/adsp/annotations.json \
		data/gsp/annotations.json
	$(PYTHON) tools/dasm-programs --build $(BUILD) --unidasm $(UNIDASM)
	$(PYTHON) tools/annotate-listing data/adsp/annotations.json $(BUILD)/adsp/program.lst \
		$(BUILD)/adsp/program.annotated.lst
	$(PYTHON) tools/annotate-listing data/gsp/annotations.json $(BUILD)/gsp/program.lst \
		$(BUILD)/gsp/program.annotated.lst

# The oracle (docs/06-code-map.md section 5): MAME runs the reference set (rompath from
# ~/.mame/mame.ini) and tools/mame/dump.lua dumps GSP VRAM and ADSP program and data RAM after
# ORACLE_FRAMES frames into build/mame/; `make test` then compares them with the extracted
# images (tools/test_programs.py, which skips without the dumps). Needs MAME and the ROMs.
ORACLE_FRAMES ?= 600
MAME_FLAGS := -video none -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 600

oracle: $(PROGRAMS)
	@mkdir -p $(BUILD)/mame
	DUMP_DIR=$(BUILD)/mame/ DUMP_FRAMES=$(ORACLE_FRAMES) $(MAME) stunrun $(MAME_FLAGS) \
		-autoboot_script tools/mame/dump.lua

# Does the 68010 execute outside its ROM? Registerpoints on every instruction (needs -debug);
# WATCH_PLAY=1 inserts a coin and starts a game. Writes build/mame/pcwatch.txt.
WATCH_FRAMES ?= 3600
WATCH_PLAY ?= 1

pcwatch:
	@mkdir -p $(BUILD)/mame
	WATCH_DIR=$(BUILD)/mame/ WATCH_FRAMES=$(WATCH_FRAMES) WATCH_PLAY=$(WATCH_PLAY) $(MAME) stunrun \
		-debug -debugger none $(MAME_FLAGS) -autoboot_script tools/mame/pcwatch.lua
	@cat $(BUILD)/mame/pcwatch.txt

# Re-decode the object image into data/objects (docs/07-objects.md): run after changing the
# decoder; `make test` fails while the committed data and the image disagree.
objects: $(BUILD)/$(SET)-obj.bin $(OBJECT_TOOLS)
	$(PYTHON) tools/objects decode --image $< --out data/objects

# Every object-ROM access of the ADSP (docs/07-objects.md section 7): tools/mame/objtrace.lua over
# attract mode and over a started game, into build/mame/objtrace-{attract,play}.txt; then
# `tools/objects trace --summary` checks them against the decoder and rewrites
# artifacts/objtrace-summary.json (addresses and counts only; commit it when it changes), and
# `make test` checks them again (tools/test_objects.py). Each run starts from its own empty NVRAM
# and cfg directories (not the archive's NVRAM that mame.ini names): the play run depends on the
# NVRAM, and the factory state makes it reproducible. Needs MAME and the ROMs.
TRACE_FRAMES_ATTRACT ?= 3600
TRACE_FRAMES_PLAY ?= 7200
TRACE_STATE = rm -rf $(BUILD)/mame/state-$(1) && mkdir -p $(BUILD)/mame/state-$(1)/nvram \
	$(BUILD)/mame/state-$(1)/cfg $(BUILD)/mame/state-$(1)/snap
TRACE_DIRS = -nvram_directory $(BUILD)/mame/state-$(1)/nvram \
	-cfg_directory $(BUILD)/mame/state-$(1)/cfg -snapshot_directory $(BUILD)/mame/state-$(1)/snap

objtrace: $(BUILD)/$(SET)-obj.bin $(OBJECT_TOOLS)
	@mkdir -p $(BUILD)/mame
	$(call TRACE_STATE,objtrace-attract)
	TRACE_DIR=$(BUILD)/mame/ TRACE_NAME=objtrace-attract TRACE_FRAMES=$(TRACE_FRAMES_ATTRACT) \
		TRACE_PLAY=0 $(MAME) stunrun $(MAME_FLAGS) $(call TRACE_DIRS,objtrace-attract) \
		-autoboot_script tools/mame/objtrace.lua
	$(call TRACE_STATE,objtrace-play)
	TRACE_DIR=$(BUILD)/mame/ TRACE_NAME=objtrace-play TRACE_FRAMES=$(TRACE_FRAMES_PLAY) \
		TRACE_PLAY=1 $(MAME) stunrun $(MAME_FLAGS) $(call TRACE_DIRS,objtrace-play) \
		-autoboot_script tools/mame/objtrace.lua
	$(PYTHON) tools/objects trace --image $< --summary artifacts/objtrace-summary.json \
		$(BUILD)/mame/objtrace-attract.txt $(BUILD)/mame/objtrace-play.txt

# Which objects a game loads at each level (docs/07-objects.md section 11.4): one MAME run per
# start level 0-23 (tools/mame/objlevels.lua: a level select by replacing the game's clear of the
# level word, the trigger pressed every 20 frames), each from its own empty NVRAM and cfg, into
# build/mame/objlevels-NN.txt; then `tools/objects levels` writes artifacts/objlevels-summary.json
# (object numbers and counts; commit it when it changes). One target per run: `make -j6
# objlevels` runs six at a time. From start level 23 up the watchdog resets the machine (run 23
# at frame 2709, after level words 23 and 24); the script ends a run at a reset. Needs MAME and
# the ROMs.
LEVELS_FRAMES ?= 8000
LEVEL_STARTS := $(shell seq -w 0 23)
LEVEL_RUNS := $(LEVEL_STARTS:%=$(BUILD)/mame/objlevels-%.txt)

$(BUILD)/mame/objlevels-%.txt: tools/mame/objlevels.lua $(BUILD)/$(SET)-obj.bin
	$(call TRACE_STATE,objlevels-$*)
	LEVELS_DIR=$(BUILD)/mame/ LEVELS_NAME=objlevels-$* LEVELS_START=$(patsubst 0%,%,$*) \
		LEVELS_FRAMES=$(LEVELS_FRAMES) $(MAME) stunrun $(MAME_FLAGS) \
		$(call TRACE_DIRS,objlevels-$*) -autoboot_script tools/mame/objlevels.lua

objlevels: $(LEVEL_RUNS)
	$(PYTHON) tools/objects levels --summary artifacts/objlevels-summary.json $(LEVEL_RUNS)

# The object pictures docs/07 shows (section 11), drawn from data/objects by tools/objects
# pictures into artifacts/objects (commit them: tools/test_render.py compares them pixel for
# pixel with what the meshes draw).
pictures:
	$(PYTHON) tools/objects pictures --data data/objects --out artifacts/objects

# The interactive mesh viewer (tools/objects/viewer.html): serves the repository root on
# 127.0.0.1:8000 until interrupted.
VIEW_PORT ?= 8000
view:
	@echo "open http://127.0.0.1:$(VIEW_PORT)/tools/objects/viewer.html#0 (Ctrl-C to stop)"
	python3 -m http.server --bind 127.0.0.1 $(VIEW_PORT)

# How does the GSP extend field 0 (ST FE0, docs/08 section 4.4): at the start of every list
# (FFF46E30, sign-extended after read_list_header), at command 7 and at the image-quad corner read
# FFF49380 (zero-extended after a 9 or 5)? Breakpoints count the mode from an empty private
# NVRAM/cfg state (as somdump); writes build/mame/fieldext.txt.
FIELD_FRAMES ?= 3100

fieldext:
	rm -rf $(BUILD)/mame/fieldstate && mkdir -p $(BUILD)/mame/fieldstate/nvram \
		$(BUILD)/mame/fieldstate/cfg
	FIELD_DIR=$(BUILD)/mame/ FIELD_FRAMES=$(FIELD_FRAMES) $(MAME) stunrun -debug -debugger none \
		$(MAME_FLAGS) -nvram_directory $(BUILD)/mame/fieldstate/nvram \
		-cfg_directory $(BUILD)/mame/fieldstate/cfg -autoboot_script tools/mame/fieldext.lua
	@cat $(BUILD)/mame/fieldext.txt

# How sorted is the draw order (docs/08 section 1.5)? tools/mame/depthkeys.lua walks the ADSP's
# node list at every 7th frame of DEPTH_FROM-DEPTH_TO, in attract mode and in a game, each from an
# empty private NVRAM/cfg state (as somdump); writes build/mame/depthkeys-{attract,game}.txt.
DEPTH_FROM ?= 1000
DEPTH_TO ?= 3000
DEPTH_GAME_TO ?= 6600

depthkeys:
	for play in 0 1; do rm -rf $(BUILD)/mame/depthstate && mkdir -p $(BUILD)/mame/depthstate/nvram \
		$(BUILD)/mame/depthstate/cfg && \
		DEPTH_DIR=$(BUILD)/mame/ DEPTH_FROM=$(DEPTH_FROM) DEPTH_PLAY=$$play \
		DEPTH_TO=$$( [ $$play = 1 ] && echo $(DEPTH_GAME_TO) || echo $(DEPTH_TO) ) \
		$(MAME) stunrun $(MAME_FLAGS) -nvram_directory $(BUILD)/mame/depthstate/nvram \
		-cfg_directory $(BUILD)/mame/depthstate/cfg -autoboot_script tools/mame/depthkeys.lua \
		|| exit 1; done
	@grep -h summary $(BUILD)/mame/depthkeys-attract.txt $(BUILD)/mame/depthkeys-game.txt

# Which polygon rows does the GSP skip by the V test (docs/08 4.2 and section 5)?
# tools/mame/vskip.lua breaks at FFF454C0/FFF454D0 under the debugger, from frame 0 to VSKIP_TO
# in attract mode and to VSKIP_GAME_TO in a game, each from an empty private NVRAM/cfg state (as
# somdump); writes build/mame/vskip-{attract,game}.txt (one line per skipped row, then a summary).
VSKIP_TO ?= 1700
VSKIP_GAME_TO ?= 6600

vskip:
	for play in 0 1; do rm -rf $(BUILD)/mame/vskipstate && mkdir -p $(BUILD)/mame/vskipstate/nvram \
		$(BUILD)/mame/vskipstate/cfg && \
		VSKIP_OUT=$(BUILD)/mame/vskip-$$( [ $$play = 1 ] && echo game || echo attract ).txt \
		VSKIP_PLAY=$$play \
		VSKIP_TO=$$( [ $$play = 1 ] && echo $(VSKIP_GAME_TO) || echo $(VSKIP_TO) ) \
		$(MAME) stunrun -debug -debugger none $(MAME_FLAGS) \
		-nvram_directory $(BUILD)/mame/vskipstate/nvram \
		-cfg_directory $(BUILD)/mame/vskipstate/cfg -autoboot_script tools/mame/vskip.lua \
		|| exit 1; done
	@grep -h summary $(BUILD)/mame/vskip-attract.txt $(BUILD)/mame/vskip-game.txt
	@echo "patterns of the skipped rows:"; grep -ho 'B9=[0-9A-F]*' $(BUILD)/mame/vskip-attract.txt \
		$(BUILD)/mame/vskip-game.txt | sort | uniq -c

# The SOM display list on its way from the ADSP to the GSP (docs/08-display-list.md):
# tools/mame/somdump.lua captures, at each frame of SOM_ATTRACT (attract mode) and SOM_GAME (a game
# started at frame 900), the SOM banks, ADSP data RAM, the GSP command buffer, the frame-buffer
# page before and after the list and a screen snapshot into build/mame/som/<attract|game|dither>-f<N>/;
# tools/displaylist.py decodes and redraws each one and compares it with MAME's page; the target
# fails when a requested frame was not captured in this run (the old captures are removed
# first), a capture does not decode or its redrawing differs from the page. Every MAME
# run starts from an empty private state (SOM_STATE, removed first): no NVRAM file, so the game
# boots from the set's own 200e/210e, and attract mode, which depends on the NVRAM history (high
# scores, the attract cycle), is the same on every machine and every run.
# attract 4000 is captured at frame 5531, an empty list (0003 0002 FFFF FFFF, docs/08 section 1.1)
SOM_ATTRACT ?= 1200,1500,1800,2100,2700,3000,4000
SOM_GAME ?= 1000,1100,2400,3000,3600,4200,4800,6600
# attract mode again with every colour word's two bytes made different (SOM_DITHER, somdump.lua):
# the game's table has equal bytes, so only these captures test the expander's even/odd bytes
SOM_DITHER ?= 1200,1800,2100
SOM_DIR := $(BUILD)/mame/som
SOM_STATE := $(BUILD)/mame/somstate
SOM_MAME = $(MAME) stunrun $(MAME_FLAGS) -nvram_directory $(SOM_STATE)/nvram \
	-cfg_directory $(SOM_STATE)/cfg -snapshot_directory $(BUILD)/mame/snap \
	-autoboot_script tools/mame/somdump.lua

# som_run(prefix, frames, extra env): one MAME run from an empty private state, then every
# requested frame must have left its capture and the run its done marker (somdump.lua writes it
# just before machine:exit()): MAME exits 0 when a Lua callback raises, so a broken capture
# script would otherwise run to -seconds_to_run and leave the previous run's directories behind
define som_run
	rm -rf $(SOM_STATE) && mkdir -p $(SOM_STATE)/nvram $(SOM_STATE)/cfg
	SOM_DIR=$(SOM_DIR)/ SOM_SNAPDIR=$(BUILD)/mame/snap/ SOM_PREFIX=$(1) SOM_FRAMES=$(2) $(3) \
		$(SOM_MAME)
	@test -f $(SOM_DIR)/$(1)done || { echo "somdump: the $(1) run did not finish its captures"; \
		exit 1; }
	@for f in $$(echo $(2) | tr , ' '); do for x in som.bin fb_som.bin snap_1.png; do \
		test -f $(SOM_DIR)/$(1)$$f/$$x || { echo "somdump: no $(1)$$f/$$x"; exit 1; }; \
		done; done
endef

somdump: $(PROGRAMS)
	@mkdir -p $(SOM_DIR) $(BUILD)/mame/snap
	rm -rf $(SOM_DIR)/attract-f* $(SOM_DIR)/game-f* $(SOM_DIR)/dither-f*
	$(call som_run,attract-f,$(SOM_ATTRACT),SOM_PLAY=0)
	$(call som_run,game-f,$(SOM_GAME),SOM_PLAY=1)
	$(call som_run,dither-f,$(SOM_DITHER),SOM_PLAY=0 SOM_DITHER=1)
	@fail=0; for d in $(SOM_DIR)/*/; do echo "== $$d"; \
		$(PYTHON) tools/displaylist.py $$d --render $$d/compare.png > $$d/render.txt \
			|| { fail=1; echo "FAILED: $$d"; }; grep -v 'written at' $$d/render.txt; done; \
		exit $$fail

# What the 6502 tells the OKI M6295 (docs/10-adpcm.md section 4): tools/mame/okitrace.lua taps
# the 6502's OKI, /WRIO and /MIX writes and its command dispatch, in three runs, each from its own
# empty NVRAM and cfg: attract mode, a game (coin at 900, start at 960, the trigger every 20
# frames) and attract mode with every OKI command written to the sound latch in turn (each after
# command 02, which clears RAM 1E: attract mode sets it with 01 and the OKI play handler
# does nothing while it is nonzero), into
# build/mame/okitrace-<run>.txt; then tools/adpcm survey rewrites data/oki/samples.json (the
# table's layout, names kept, the commands that play each phrase by the 6502's tables, the starts
# each run saw; commit it when it changes) and fails if MAME saw a phrase started by a command the
# tables do not map to it. One target per run: `make -j3 okitrace`. Needs MAME and the ROMs.
OKI_RUNS := attract game inject
OKI_INJECT := 05,$(shell seq 56 108 | xargs printf '%02X,' | sed 's/,$$//')

$(BUILD)/mame/okitrace-attract.txt: OKI_ENV = OKI_FRAMES=10800 OKI_PLAY=0
$(BUILD)/mame/okitrace-game.txt: OKI_ENV = OKI_FRAMES=10800 OKI_PLAY=1
$(BUILD)/mame/okitrace-inject.txt: OKI_ENV = OKI_FRAMES=21000 OKI_PLAY=0 \
	OKI_INJECT=$(OKI_INJECT) OKI_INJECT_EVERY=360

$(OKI_RUNS:%=$(BUILD)/mame/okitrace-%.txt): $(BUILD)/mame/okitrace-%.txt: tools/mame/okitrace.lua FORCE
	$(call TRACE_STATE,okitrace-$*)
	rm -f $@ $(BUILD)/mame/okitrace-$*done
	OKI_DIR=$(BUILD)/mame/ OKI_NAME=okitrace-$* $(OKI_ENV) SDL_VIDEODRIVER=dummy $(MAME) stunrun \
		$(MAME_FLAGS) $(call TRACE_DIRS,okitrace-$*) -autoboot_script tools/mame/okitrace.lua
	@test -f $(BUILD)/mame/okitrace-$*done || { echo "okitrace: the $* run did not finish"; \
		exit 1; }

okitrace: $(OKI_RUNS:%=$(BUILD)/mame/okitrace-%.txt) $(BUILD)/$(SET)-oki.bin \
		$(BUILD)/$(SET)-jsa.bin $(OKI_TOOLS)
	$(PYTHON) tools/adpcm survey --image $(BUILD)/$(SET)-oki.bin --jsa $(BUILD)/$(SET)-jsa.bin \
		--manifest $(OKI_MANIFEST) $(OKI_RUNS:%=$(BUILD)/mame/okitrace-%.txt)

# Every phrase the manifest names decoded to 16-bit PCM by MAME's M6295 decoder (tools/adpcm pcm;
# a renamed phrase's old file is removed), at the rate
# MAME plays them, into build/oki/pcm/NN-name.wav: for listening (Jesus's naming pass). Never
# committed.
oki-pcm: $(OKI_SPLIT)
	@$(OKI_REFILL)
	$(PYTHON) tools/adpcm pcm --manifest $(OKI_MANIFEST) --wav $(OKI_WAV_DIR) --out $(BUILD)/oki/pcm

# The JSA II sound program in MAME (docs/09-sound-program.md). tools/mame/sndtrace.lua records
# what the 6502 executes and reads, the command bytes of the 68010 and the 6502's responses, and
# the YM2151 and OKI writes (build/mame/<run>.txt, build artefacts: they carry values the program
# takes from its ROM). Three runs of the reference set, each from its own empty NVRAM and cfg
# (TRACE_STATE): attract mode as the factory NVRAM has it (SND_FRAMES, two attract cycles),
# attract mode with "SOUNDS IN ATTRACT" on (TRACE_ATTRACT_SOUND=1, docs/09 section 6) and a
# started game (SND_PLAY_FRAMES). `make -j3 sndtrace` runs them side by side. Then
# tools/sndtrace.py checks every opcode fetch and data read against the source (the listing of
# asm/jsa) and rewrites artifacts/sndtrace-summary.json (addresses, counts, command and response
# values; commit it when it changes). Needs MAME and the ROMs; headless (SDL dummy driver).
REF_ROMPATH ?= $(or $(STUNRUN_ROMS),$(HOME)/archive/261104-stun-runner/roms)
SND_FRAMES ?= 10800
SND_PLAY_FRAMES ?= 7200
SND_TRACES := $(BUILD)/mame/sndtrace-attract.txt $(BUILD)/mame/sndtrace-sound.txt \
	$(BUILD)/mame/sndtrace-play.txt

# snd_run(run, rompath, frames, play, attract sound): one headless MAME run from an empty private
# state; the target fails unless the run wrote its "# done" line (MAME exits 0 when a Lua
# callback raises)
define snd_run
	@mkdir -p $(BUILD)/mame
	rm -f $(BUILD)/mame/$(1).txt
	$(call TRACE_STATE,$(1))
	SDL_VIDEODRIVER=dummy TRACE_DIR=$(BUILD)/mame/ TRACE_NAME=$(1) TRACE_FRAMES=$(3) \
		TRACE_PLAY=$(4) TRACE_ATTRACT_SOUND=$(5) $(MAME) stunrun $(MAME_FLAGS) -rompath $(2) \
		$(call TRACE_DIRS,$(1)) -autoboot_script tools/mame/sndtrace.lua
	@tail -1 $(BUILD)/mame/$(1).txt 2>/dev/null | grep -qx '# done' || \
		{ echo "sndtrace: the $(1) run did not finish"; exit 1; }
endef

$(BUILD)/mame/sndtrace-attract.txt: FORCE
	$(call snd_run,sndtrace-attract,$(REF_ROMPATH),$(SND_FRAMES),0,0)

$(BUILD)/mame/sndtrace-sound.txt: FORCE
	$(call snd_run,sndtrace-sound,$(REF_ROMPATH),$(SND_FRAMES),0,1)

$(BUILD)/mame/sndtrace-play.txt: FORCE
	$(call snd_run,sndtrace-play,$(REF_ROMPATH),$(SND_PLAY_FRAMES),1,0)

sndtrace: $(SND_TRACES) $(BUILD)/stunrun-jsa.lst
	$(PYTHON) tools/sndtrace.py summary --listing $(BUILD)/stunrun-jsa.lst \
		--out artifacts/sndtrace-summary.json $(SND_TRACES)

# The machine half of M4's acceptance: the reference set and the rebuilt one (build/roms, after
# `make check`; MAME's -verifyroms confirms it finds the set there, and -rompath on the command
# line replaces mame.ini's, so nothing else is read) each run SOUNDCHECK_FRAMES frames of attract
# mode with its sounds on, headless; their YM2151 and OKI write streams, commands and responses
# must be equal, and the reference must key on YM2151 channels (attract mode made sound).
SOUNDCHECK_FRAMES ?= 3000

soundcheck: check
	$(MAME) -rompath $(BUILD)/roms -verifyroms $(SET)
	$(call snd_run,soundcheck-reference,$(REF_ROMPATH),$(SOUNDCHECK_FRAMES),0,1)
	$(call snd_run,soundcheck-rebuilt,$(BUILD)/roms,$(SOUNDCHECK_FRAMES),0,1)
	$(PYTHON) tools/sndtrace.py soundcheck --frames $(SOUNDCHECK_FRAMES) \
		$(BUILD)/mame/soundcheck-reference.txt $(BUILD)/mame/soundcheck-rebuilt.txt

# The listening half (Jesus's check, the one target that opens a window and plays sound): MAME on
# the REBUILT set (build/roms, after `make check`) from an empty private state, attract mode with
# "SOUNDS IN ATTRACT" on (tools/mame/listen.lua; LISTEN_ATTRACT_SOUND=0 leaves the factory
# setting, under which attract mode is silent). Sound plays only during each attract demo: the
# 68010 sends 02 at the demo's start (frames 831, 5534, 10238: about 14 s, 92 s, 170 s after boot)
# and 01 at its end (2301, 7005: about 38 s, 116 s) whatever the option is, so a silence from
# about 38 s to 92 s is expected (docs/09-sound-program.md section 6).
LISTEN_ATTRACT_SOUND ?= 1

listen: check
	$(MAME) -rompath $(BUILD)/roms -verifyroms $(SET)
	rm -rf $(BUILD)/mame/listen && mkdir -p $(BUILD)/mame/listen/nvram $(BUILD)/mame/listen/cfg
	$(MAME) stunrun -rompath $(BUILD)/roms -window -skip_gameinfo -autoboot_delay 0 \
		-nvram_directory $(BUILD)/mame/listen/nvram -cfg_directory $(BUILD)/mame/listen/cfg \
		$(if $(filter 1,$(LISTEN_ATTRACT_SOUND)),-autoboot_script tools/mame/listen.lua)

roms:            ## verify ~/archive/261104-stun-runner/roms/stunrun against tools/romsets/stunrun.json
	$(PYTHON) tools/check-roms

roms-refresh:    ## rewrite tools/romsets/stunrun.json from `mame -listxml stunrun`
	$(PYTHON) tools/check-roms --refresh

selftest:        ## the checker against a synthetic set
	$(PYTHON) tools/check-roms --selftest

clean:
	rm -rf $(BUILD)
