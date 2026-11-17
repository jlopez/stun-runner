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

.PHONY: all check coverage labels test lint roms roms-refresh selftest clean ida ida-export ida-annotate ida-sync \
	dasm oracle pcwatch objects objtrace objlevels pictures view somdump fieldext depthkeys vskip \
	okitrace samples sndtrace soundcheck listen sndproto musictrace FORCE
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

# The OKI image's source (docs/10-adpcm.md): data/oki, the manifest samples.json and one 16-bit
# PCM WAV per phrase (NN-name.wav, the M6295 decoder's output), turned by tools/adpcm asm into
# build/oki/samples.asm, which asm/oki/samples.asm includes after the phrase table: every WAV
# encoded back to ADPCM, the samples laid out in phrase order from their lengths (no address is
# written by hand), the bytes as dc.b. From the committed data alone: the OKI tree never reads
# build/stunrun-oki.bin. The step runs on every make (a fraction of a second; make 3.81 on
# macOS compares whole-second mtimes, so a WAV edited in the same second as the last build must
# still count); it rewrites the include only when it changes.
OKI_MANIFEST := data/oki/samples.json
OKI_TOOLS := tools/adpcm/__init__.py tools/adpcm/__main__.py $(ROMSET_TOOLS)
OKI_ASM := $(BUILD)/oki/samples.asm

$(OKI_ASM): $(OKI_MANIFEST) $(wildcard data/oki/*.wav) $(OKI_TOOLS) FORCE
	$(PYTHON) tools/adpcm asm --data data/oki --out $(BUILD)/oki

.SECONDARY: $(OKI_ASM)

# image -> the files its tree includes: its blob (the merged image) and any others; the 68k tree
# is every file under asm/68k (the region files under boot/ and game/ included, docs/13) plus its
# blobs, the object tree includes only the generated page sources, never build/stunrun-obj.bin,
# the OKI tree only the include generated from data/oki, never build/stunrun-oki.bin, the NVRAM
# tree is two zero fills (M5-0) and includes nothing, and the 6502 tree is all source
# (docs/09-sound-program.md): its own files, data/ included, and nothing from build/
EXTRA_stunrun-68k   := $(BUILD)/stunrun-68k.bin $(PROGRAMS) $(shell find asm/68k -type f -name '*.asm')
EXTRA_stunrun-obj   := $(OBJECT_ASM)
EXTRA_stunrun-oki   := $(OKI_ASM) FORCE
EXTRA_stunrun-nvram :=
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
	$(PYTHON) tools/coverage --set $(SET) $(foreach g,$(MAX_BLOB),--max-blob $(g)) $(LISTINGS)

# The 68k IDA snapshot's names against the tree's labels (docs/13-68k-source.md section 7): a
# name in source must be a label at its address; names in blobs are counted. Listing only, so
# it runs without the reference set on any build of the tree (tools/test_build.py runs it on the
# synthetic one in CI).
labels: $(BUILD)/stunrun-68k.lst
	$(PYTHON) tools/labels --listing $< --snapshot data/ida/stunrun-68k.json

test: selftest
	$(PYTHON) -m pytest -q tools

PYTOOLS := tools/romset.py tools/listings.py tools/programs.py tools/test_*.py \
	tools/check-roms tools/merge-roms tools/split-roms tools/bytecheck tools/coverage tools/labels \
	tools/extract-programs tools/dasm-programs tools/annotate-listing tools/displaylist.py \
	tools/sndtrace.py tools/jsa_music.py

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

# The 6502 source into its database (docs/05-ida.md section 6): names, comments, functions and
# the code/data classification of asm/jsa. A dry run on a copy by default (the changes per
# category); `make ida-sync WRITE=1` writes data/stunrun-jsa.i64, then `make ida-export`.
ida-sync: $(BUILD)/$(SET)-jsa.bin
	$(PYTHON) -m ida.headless.sync $(if $(filter 1,$(WRITE)),--write)

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

# Re-decode the OKI image into data/oki (docs/10-adpcm.md): one PCM WAV per phrase of the image's
# own table, named from the manifest (any other WAV there is removed); run after changing the
# decoder or a name. `make test` fails while the committed WAVs and the image disagree.
samples: $(BUILD)/$(SET)-oki.bin $(OKI_TOOLS)
	$(PYTHON) tools/adpcm samples --image $< --manifest $(OKI_MANIFEST) --out data/oki

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

# The sound command protocol between the 68010 and the 6502 (docs/11-sound-protocol.md):
# tools/mame/sndproto.lua taps both ends of the latch pair (the 68010's writes and reads at 600000,
# its sound resets at 604000, its command queue at FFDB64, the 6502's reads of 2802, its responses
# at 2A02 and its dispatch), in five runs, each from its own empty NVRAM and cfg: attract mode, a
# game (coin at 900, start at 960, the trigger every 20 frames), attract mode with the immediate
# commands and the bytes above 6C written to the sound latch, and the boot program's test menus
# driven with the buttons: "SA SELF TEST" and "PLAY SOUNDS" (the game's audio test, every one of
# its 108 entries played). Into build/mame/sndproto-<run>.txt (addresses, command and response
# values, counts); `make test` (tools/test_sound_commands.py) checks data/sound/commands.json
# against them when they are there. `make -j5 sndproto`. Needs MAME and the ROMs.
SNDPROTO_RUNS := attract game inject selftest soundtest
SNDPROTO_INJECT := 1200:07,1260:06,1320:03,1380:09,1440:08,1442:5A,1500:07,1560:6D,1620:7F
SNDPROTO_INJECT := $(SNDPROTO_INJECT),1680:80,1740:FF,1800:07

$(BUILD)/mame/sndproto-attract.txt: PROTO_ENV = PROTO_FRAMES=10800
$(BUILD)/mame/sndproto-game.txt: PROTO_ENV = PROTO_FRAMES=10800 PROTO_PLAY=1
$(BUILD)/mame/sndproto-inject.txt: PROTO_ENV = PROTO_FRAMES=1900 PROTO_INJECT=$(SNDPROTO_INJECT)
$(BUILD)/mame/sndproto-selftest.txt: PROTO_ENV = PROTO_FRAMES=2800 PROTO_MENU=selftest
$(BUILD)/mame/sndproto-soundtest.txt: PROTO_ENV = PROTO_FRAMES=6400 PROTO_MENU=soundtest

$(SNDPROTO_RUNS:%=$(BUILD)/mame/sndproto-%.txt): $(BUILD)/mame/sndproto-%.txt: tools/mame/sndproto.lua FORCE
	$(call TRACE_STATE,sndproto-$*)
	rm -f $@ $(BUILD)/mame/sndproto-$*done
	PROTO_DIR=$(BUILD)/mame/ PROTO_NAME=sndproto-$* $(PROTO_ENV) SDL_VIDEODRIVER=dummy $(MAME) \
		stunrun $(MAME_FLAGS) $(call TRACE_DIRS,sndproto-$*) -autoboot_script tools/mame/sndproto.lua
	@test -f $(BUILD)/mame/sndproto-$*done || { echo "sndproto: the $* run did not finish"; \
		exit 1; }

sndproto: $(SNDPROTO_RUNS:%=$(BUILD)/mame/sndproto-%.txt)
	$(PYTHON) -m pytest -q tools/test_sound_commands.py

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

# The sequencer in MAME (docs/12-sound-music.md): tools/mame/musictrace.lua injects, headless,
# from an empty private state, each command of type 08 in turn (MUSIC_SOUNDS, MUSIC_WINDOW frames
# each, after command 00 and 02; the 68010's own commands are replaced by the no-op 6D) and
# records the tracks started, the ops dispatched, the stream statements read and the YM2151
# key-ons per sound (build/mame/musictrace.txt); tools/jsa_music.py summary checks them against
# the source (the listing) and rewrites artifacts/musictrace-summary.json (addresses, counts and
# command/sound numbers; commit it when it changes). Needs MAME and the ROMs.
MUSIC_SOUNDS ?= 04,0A,0C,0D,0F,10,11,12,14,16,17,18,1A,1B,1C,1D,24,25,26,28,2A,2B,2C,2D,2F,30,31,32,33,34,35,37
MUSIC_WINDOW ?= 600

musictrace: $(BUILD)/stunrun-jsa.lst
	@mkdir -p $(BUILD)/mame
	rm -f $(BUILD)/mame/musictrace.txt $(BUILD)/mame/musictracedone
	$(call TRACE_STATE,musictrace)
	SDL_VIDEODRIVER=dummy MUSIC_DIR=$(BUILD)/mame/ MUSIC_NAME=musictrace \
		MUSIC_SOUNDS=$(MUSIC_SOUNDS) MUSIC_WINDOW=$(MUSIC_WINDOW) $(MAME) stunrun $(MAME_FLAGS) \
		-rompath $(REF_ROMPATH) $(call TRACE_DIRS,musictrace) \
		-autoboot_script tools/mame/musictrace.lua
	@test -f $(BUILD)/mame/musictracedone || { echo "musictrace: the run did not finish"; exit 1; }
	$(PYTHON) tools/jsa_music.py summary --listing $(BUILD)/stunrun-jsa.lst \
		--out artifacts/musictrace-summary.json $(BUILD)/mame/musictrace.txt

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
# and 01 at its end (2301, 7005: about 38 s, 116 s; from 024E3E/0253A0, docs/11 section 2.1)
# whatever the option is, so a silence from
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

# --- M5g: the 68k descent, classification and generator (docs/14-68k-descent.md) ------------
# tools/m68k is a package run as `uv run python tools/m68k <command>`; its CI tests are
# tools/test_m68k.py (part of `make test`). `make lint` also type-checks the package.
.PHONY: lint-m68k classify pccov m68k-check
lint: lint-m68k
lint-m68k:
	uv run --frozen mypy -p m68k

M68K_TOOLS := $(wildcard tools/m68k/*.py)
CLASSIFICATION := data/68k/classification.json

# Re-run the descent over the image and rewrite data/68k/classification.json (commit it when it
# changes): seeds from the image, data/68k/seeds.json and the five MAME runs of `make pccov`,
# which must be present (run `make -j5 pccov` first): without them three MAME entries are lost
# and executed code becomes data; `tools/m68k classify` also refuses a run file with no PCs or no
# `# run` line (an empty trace). NO_MAME=1 classifies without them, into the same files: do not
# commit that. Needs the reference set.
PCCOV_FILES = $(PCCOV_RUNS:%=$(BUILD)/mame/pccov-%.txt)
classify: $(BUILD)/$(SET)-68k.bin $(M68K_TOOLS)
	@if [ "$(NO_MAME)" != 1 ]; then for f in $(PCCOV_FILES); do test -f $$f || { \
		echo "classify: $$f is missing: run make -j5 pccov first (or NO_MAME=1)"; exit 1; }; \
		done; fi
	$(PYTHON) tools/m68k classify --image $< --out $(CLASSIFICATION) \
		$(if $(filter 1,$(NO_MAME)),--no-mame,$(PCCOV_FILES))

# The checks on the committed tree (M5c, docs/16-68k-code.md section 4): on the tree's own
# listing, the descent check, the address lint, the raw-data check of the code files and the
# shift test (tools/m68k check-tree), every executed PC of the `make pccov` runs present in
# build/mame an instruction statement, `make labels`, and every instruction boundary of the
# classification equal to unidasm's. Needs the reference set and unidasm; CI runs the same
# checks on the tree assembled against a random blob (tools/test_68k_tree.py). Every later leg
# runs it after each change. (The generator is frozen: `tools/m68k check-region` still checks
# it against the image, docs/14 section 6, but no make target runs it over the tree.)
m68k-check: $(BUILD)/$(SET)-68k.lst $(M68K_TOOLS) labels
	@test -n "$(wildcard $(PCCOV_FILES))" || \
		echo "m68k-check: no build/mame/pccov-*.txt: run make -j5 pccov for the MAME check"
	$(PYTHON) tools/m68k check-tree --listing $(BUILD)/$(SET)-68k.lst \
		--binary $(BUILD)/$(SET)-68k.out $(wildcard $(PCCOV_FILES))
	$(PYTHON) tools/m68k check-unidasm --unidasm $(UNIDASM)

# Which 68010 instructions MAME executes (docs/14 section 7): tools/mame/pccov.lua traces the
# 68010 under the debugger into a named pipe that `tools/m68k pccov-read` drains into the
# distinct PCs (build/mame/pccov-<run>.txt; it fails on an empty trace), in five headless runs from empty private state
# (attract, a game, the boot program's test menus to "SA SELF TEST" and to "PLAY SOUNDS" as
# sndproto.lua drives them, and the power-on self-test left to run). Then `tools/m68k pccov`
# fails unless every executed PC starts a code instruction of the classification and rewrites
# artifacts/pccov-summary.json (ranges and counts; commit it when it changes). `make -j5 pccov`.
# Needs MAME and the ROMs.
PCCOV_RUNS := attract game selftest soundtest postest
$(BUILD)/mame/pccov-attract.txt: PCCOV_ENV = PCCOV_FRAMES=7200 PCCOV_PLAY=0
$(BUILD)/mame/pccov-game.txt: PCCOV_ENV = PCCOV_FRAMES=7200 PCCOV_PLAY=1
$(BUILD)/mame/pccov-selftest.txt: PCCOV_ENV = PCCOV_FRAMES=2800 PCCOV_MENU=selftest
$(BUILD)/mame/pccov-soundtest.txt: PCCOV_ENV = PCCOV_FRAMES=6400 PCCOV_MENU=soundtest
$(BUILD)/mame/pccov-postest.txt: PCCOV_ENV = PCCOV_FRAMES=3600 PCCOV_MENU=postest

$(PCCOV_RUNS:%=$(BUILD)/mame/pccov-%.txt): $(BUILD)/mame/pccov-%.txt: tools/mame/pccov.lua FORCE
	$(call TRACE_STATE,pccov-$*)
	rm -f $@ $(BUILD)/mame/pccov-$*.fifo $(BUILD)/mame/pccov-$*done
	mkfifo $(BUILD)/mame/pccov-$*.fifo
	$(PYTHON) tools/m68k pccov-read $(BUILD)/mame/pccov-$*.fifo $@.tmp & reader=$$!; \
	PCCOV_FIFO=$(BUILD)/mame/pccov-$*.fifo PCCOV_DONE=$(BUILD)/mame/pccov-$*done $(PCCOV_ENV) \
		SDL_VIDEODRIVER=dummy $(MAME) stunrun -debug -debugger none $(MAME_FLAGS) \
		$(call TRACE_DIRS,pccov-$*) -autoboot_script tools/mame/pccov.lua; rc=$$?; \
	kill -0 $$reader 2>/dev/null && : <> $(BUILD)/mame/pccov-$*.fifo; \
	wait $$reader; rrc=$$?; rm -f $(BUILD)/mame/pccov-$*.fifo; \
	test $$rc -eq 0 && test -f $(BUILD)/mame/pccov-$*done || \
		{ echo "pccov: the $* run did not finish"; exit 1; }; \
	test $$rrc -eq 0 || { echo "pccov: the $* run traced no PC"; exit 1; }; \
	{ printf '# run '; cat $(BUILD)/mame/pccov-$*done; } >> $@.tmp && mv $@.tmp $@

pccov: $(PCCOV_RUNS:%=$(BUILD)/mame/pccov-%.txt) $(BUILD)/$(SET)-68k.bin $(BUILD)/$(SET)-68k.lst
	$(PYTHON) tools/m68k pccov --image $(BUILD)/$(SET)-68k.bin --classification $(CLASSIFICATION) \
		--listing $(BUILD)/$(SET)-68k.lst \
		--summary artifacts/pccov-summary.json $(PCCOV_RUNS:%=$(BUILD)/mame/pccov-%.txt)

# --- M5d: the sound command equates (docs/17 section 3) ----------------------------------------
# data/sound/commands.json names every sound command (docs/11 section 11); tools/m68k
# sound-equates writes build/68k/sound_commands.asm (`snd_<name> equ $NN`), which
# asm/68k/stunrun.asm includes after ram.asm. On every make (a fraction of a second, rewritten
# only when its text changes), as the image includes below.
SOUND_EQUATES := $(BUILD)/68k/sound_commands.asm

$(SOUND_EQUATES): FORCE
	$(PYTHON) tools/m68k sound-equates --commands data/sound/commands.json --out $@

.SECONDARY: $(SOUND_EQUATES)
EXTRA_stunrun-68k += $(SOUND_EQUATES)

# --- M5i: the packed GSP images and their palettes (docs/15-gsp-images.md) --------------------
# tools/gspimages is a package run as `uv run python tools/gspimages <command>`; its CI tests are
# tools/test_gspimages.py. The 68k tree's 060000-0C0000 comes from data/gsp-images alone:
# tools/gspimages asm re-encodes every stream from the PNGs' pixel indices and writes the
# includes of asm/68k/images.asm and image_table.asm, and since M5d (docs/17) one include per
# palette of data/palettes, build/gsp-images/palettes/<name>.asm, which game/island.asm includes
# at the palette's address; on every make (a fraction of a second; make 3.81 compares
# whole-second mtimes), rewriting a file only when it changes. A PNG whose size differs from the
# manifest's fails the build. (M5i's `palcheck` is gone: the palettes are bytes of the tree now,
# so `make check`'s byte comparison covers them.)
.PHONY: lint-gspimages images imgtrace
lint: lint-gspimages
lint-gspimages:
	uv run --frozen mypy -p gspimages

GSP_DIR := $(BUILD)/gsp-images
GSP_ASM := $(GSP_DIR)/images.asm $(GSP_DIR)/table.asm
GSP_TOOLS := $(wildcard tools/gspimages/*.py)

# two targets, one recipe: a pattern rule (stem "images"), as the object pages above; the same
# run writes the palette includes
$(BUILD)/gsp-%/images.asm $(BUILD)/gsp-%/table.asm: FORCE
	$(PYTHON) tools/gspimages asm --data data/gsp-images --palettes data/palettes --out $(GSP_DIR)

.SECONDARY: $(GSP_ASM)
# FORCE: the includes keep their mtime unless their text changes, and make 3.81's whole-second
# mtimes would otherwise skip an assembly whose include changed in the second of the last one
# (a stale image would then pass or fail make check wrongly). Both take < 1 s.
EXTRA_stunrun-68k += $(GSP_ASM) FORCE

# Re-decode the image into data/gsp-images (docs/15): the manifest and one PNG per distinct
# image, names and palette specs kept; run after changing the decoder. `make test` fails while
# the committed data and the image disagree.
images: $(BUILD)/$(SET)-68k.bin $(GSP_TOOLS)
	$(PYTHON) tools/gspimages decode --image $< --data data/gsp-images --palettes data/palettes

# The unpackers in MAME (docs/15 section 8): tools/mame/gspimages.lua records every HSTDATA word
# the 68010's unpackers write (0225E4-022954) with its GSP destination, the stream bytes they
# read, the image-table reads, the GSP words read back one frame later and MAME's palette every
# 50 frames (every 20 in the level runs), headless, each run from its own empty NVRAM and cfg: attract mode, a game, and a
# game per start level 1-23 (objlevels.lua's level select, card A4) to reach every level map.
# Into build/mame/imgtrace-<run>.{txt,words,vram,pal} (the words and palettes are image data:
# build output only); then tools/gspimages trace checks every unpacking against the decoder and
# rewrites artifacts/gspimages-summary.json (entries, frames, destinations, counts; commit it
# when it changes). `make -j6 imgtrace`. Needs MAME and the ROMs.
IMG_LEVELS := $(shell seq -w 1 23)
IMG_RUNS := attract game $(IMG_LEVELS:%=level%)
$(BUILD)/mame/imgtrace-attract.txt: IMG_ENV = IMG_FRAMES=10800 IMG_PLAY=0 IMG_LEVEL=0 \
	IMG_PAL=$(shell seq -s, 50 50 10800)
$(BUILD)/mame/imgtrace-game.txt: IMG_ENV = IMG_FRAMES=7200 IMG_PLAY=1 IMG_LEVEL=0 \
	IMG_PAL=$(shell seq -s, 50 50 7200)
$(BUILD)/mame/imgtrace-level%.txt: IMG_ENV = IMG_FRAMES=3000 IMG_PLAY=1 \
	IMG_LEVEL=$(patsubst 0%,%,$(patsubst level%,%,$*)) IMG_PAL=$(shell seq -s, 20 20 3000)

$(IMG_RUNS:%=$(BUILD)/mame/imgtrace-%.txt): $(BUILD)/mame/imgtrace-%.txt: tools/mame/gspimages.lua
	$(call TRACE_STATE,imgtrace-$*)
	rm -f $@
	IMG_DIR=$(BUILD)/mame/ IMG_NAME=imgtrace-$* $(IMG_ENV) SDL_VIDEODRIVER=dummy \
		$(MAME) stunrun $(MAME_FLAGS) $(call TRACE_DIRS,imgtrace-$*) \
		-autoboot_script tools/mame/gspimages.lua
	@grep -qx '# done' $@ || { echo "imgtrace: the $* run did not finish"; rm -f $@; exit 1; }

imgtrace: $(IMG_RUNS:%=$(BUILD)/mame/imgtrace-%.txt) $(BUILD)/$(SET)-68k.bin
	$(PYTHON) tools/gspimages trace --image $(BUILD)/$(SET)-68k.bin \
		--summary artifacts/gspimages-summary.json $(IMG_RUNS:%=$(BUILD)/mame/imgtrace-%.txt)

# --- M5d: the moved-build experiment (docs/17 section 5) ------------------------------------
# How relocatable is the 68k tree? tools/m68k moved assembles it with MOVED_PAD zero bytes before
# the game code (020430; the fill at 05CF86 shorter by as much, so pairs U-W stay), its guards
# off, into build/moved/stunrun-68k.out, and tools/split-roms cuts it with the other four images
# into build/moved/roms/stunrun (never committed). tools/mame/movedcheck.lua logs per frame what
# the 68010 writes to the GSP host port, the ADSP and the sound latch, headless, each run from
# its own empty NVRAM and cfg: attract mode and a started game, for the reference set and for
# the moved one; `tools/m68k moved-compare` prints the first frame each stream differs in. An
# experiment, not a check: it reports and exits 0. MOVED_DETAIL=F1-F2 logs every write of those
# frames with its PC (build/mame/moved-*.detail). `make -j4 movedcheck`. Needs MAME and the ROMs.
.PHONY: movedcheck moved
MOVED_PAD ?= 4
MOVED_FRAMES ?= 4000
MOVED_DIR := $(BUILD)/moved
MOVED_RUNS := ref-attract moved-attract ref-game moved-game

moved: all
	$(PYTHON) tools/m68k moved --pad $(MOVED_PAD) --tree asm/68k --build $(BUILD) --out $(MOVED_DIR)
	for i in stunrun-obj stunrun-oki stunrun-nvram stunrun-jsa; do \
		cp $(BUILD)/$$i.out $(MOVED_DIR)/$$i.out || exit 1; done
	$(PYTHON) tools/split-roms --set $(SET) --images $(MOVED_DIR) --suffix .out \
		--out $(MOVED_DIR)/roms/$(SET)

$(BUILD)/mame/moved-ref-%.txt: MOVED_ROMPATH = $(REF_ROMPATH)
$(BUILD)/mame/moved-moved-%.txt: MOVED_ROMPATH = $(MOVED_DIR)/roms
$(BUILD)/mame/moved-%-attract.txt: MOVED_ENV = MOVED_PLAY=0
$(BUILD)/mame/moved-%-game.txt: MOVED_ENV = MOVED_PLAY=1

$(MOVED_RUNS:%=$(BUILD)/mame/moved-%.txt): $(BUILD)/mame/moved-%.txt: tools/mame/movedcheck.lua moved
	$(call TRACE_STATE,moved-$*)
	rm -f $@
	MOVED_DIR=$(BUILD)/mame/ MOVED_NAME=moved-$* MOVED_FRAMES=$(MOVED_FRAMES) $(MOVED_ENV) \
		MOVED_DETAIL=$(MOVED_DETAIL) SDL_VIDEODRIVER=dummy $(MAME) stunrun $(MAME_FLAGS) \
		-rompath $(MOVED_ROMPATH) $(call TRACE_DIRS,moved-$*) \
		-autoboot_script tools/mame/movedcheck.lua
	@grep -qx '# done' $@ || { echo "movedcheck: the $* run did not finish"; exit 1; }

movedcheck: $(MOVED_RUNS:%=$(BUILD)/mame/moved-%.txt)
	$(PYTHON) tools/m68k moved-compare $(BUILD)/mame/moved-ref-attract.txt \
		$(BUILD)/mame/moved-moved-attract.txt $(BUILD)/mame/moved-ref-game.txt \
		$(BUILD)/mame/moved-moved-game.txt
