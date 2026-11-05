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
	dasm oracle pcwatch objects objtrace somdump fieldext depthkeys FORCE
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
# /MP page by tools/objects. The image supplies only the residue words the format does not
# explain (incbin slices). Three targets, one recipe: a pattern rule (stem "page"), as above.
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
		$(OBJECT_TOOLS) $(BUILD)/$(SET)-obj.bin
	$(PYTHON) tools/objects asm --data data/objects --image $(BUILD)/$(SET)-obj.bin \
		--out $(BUILD)/obj

.SECONDARY: $(OBJECT_ASM)

# image -> files it includes besides its own image
EXTRA_stunrun-68k := $(PROGRAMS)
EXTRA_stunrun-obj := $(OBJECT_ASM)

# The listing is a co-target of the assembly (a pattern rule with two targets is one recipe for
# both, in every make version), so a missing or stale listing reassembles its image.
ASM = $(if $(filter $(VASM_IMAGES),$*),$(VASM) $(VASMFLAGS),$(TASS) $(TASSFLAGS))

$(BUILD)/%.out $(BUILD)/%.lst: $$(SRC_$$*) $(BUILD)/%.bin $$(EXTRA_$$*) $$(wildcard $$(dir $$(SRC_$$*))*.asm)
	$(ASM) -L $(BUILD)/$*.lst -o $(BUILD)/$*.out $<

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
	tools/extract-programs tools/dasm-programs tools/annotate-listing tools/displaylist.py

lint:
	uv run --frozen ruff check tools ida
	uv run --frozen mypy --scripts-are-modules $(PYTOOLS)
	uv run --frozen mypy -p ida
	uv run --frozen mypy -p objects

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

# Are the image-quad corners read zero-extended (ST FE0 = 0 at FFF49380, docs/08 section 4.4)?
# Breakpoints count the GSP's field-0 extension mode from an empty private NVRAM/cfg state (as
# somdump); writes build/mame/fieldext.txt.

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
SOM_ATTRACT ?= 1200,1500,1800,2100,2700,3000
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

roms:            ## verify ~/archive/261104-stun-runner/roms/stunrun against tools/romsets/stunrun.json
	$(PYTHON) tools/check-roms

roms-refresh:    ## rewrite tools/romsets/stunrun.json from `mame -listxml stunrun`
	$(PYTHON) tools/check-roms --refresh

selftest:        ## the checker against a synthetic set
	$(PYTHON) tools/check-roms --selftest

clean:
	rm -rf $(BUILD)
