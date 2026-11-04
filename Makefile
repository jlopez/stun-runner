# S.T.U.N. Runner: assemble the five trees under asm/ into the 25 files of the stunrun set,
# byte for byte (docs/04-build.md). The ROMs live outside the repo (CLAUDE.md section 2): the
# blobs the trees incbin are build artefacts that tools/merge-roms makes from the reference set.

VASM   ?= vasmm68k_mot
TASS   ?= 64tass
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

.PHONY: all check coverage test lint roms roms-refresh selftest clean
.SECONDEXPANSION:

# The split always runs (cheap): make 3.81 on macOS compares whole-second mtimes, so a stamp file
# could hide an image reassembled in the same second.
all: $(OUTS) tools/split-roms $(ROMSET_TOOLS)
	$(PYTHON) tools/split-roms --set $(SET) --images $(BUILD) --suffix .out --out $(ROMDIR)

# The blobs: rebuilt only when the layout tools change (make clean to re-read the archive). A
# pattern rule with several targets is one recipe for all five, in every make version.
$(BUILD)/%-68k.bin $(BUILD)/%-obj.bin $(BUILD)/%-oki.bin $(BUILD)/%-jsa.bin $(BUILD)/%-nvram.bin: tools/merge-roms $(ROMSET_TOOLS)
	$(PYTHON) tools/merge-roms --set $(SET) --out $(BUILD)

$(VASM_IMAGES:%=$(BUILD)/%.out): $(BUILD)/%.out: $$(SRC_%) $(BUILD)/%.bin $$(wildcard $$(dir $$(SRC_%))*.asm)
	$(VASM) $(VASMFLAGS) -L $(BUILD)/$*.lst -o $@ $<

$(BUILD)/stunrun-jsa.out: $(SRC_stunrun-jsa) $(BUILD)/stunrun-jsa.bin $(wildcard asm/jsa/*.asm)
	$(TASS) $(TASSFLAGS) -L $(BUILD)/stunrun-jsa.lst -o $@ $<

# Without the reference set (CI) there is nothing to build from or compare with: skip, exit 0.
check:
	@$(PYTHON) tools/check-roms --set $(SET) >/dev/null; rc=$$?; \
	if [ $$rc -eq 2 ]; then echo "reference set absent, skipped"; exit 0; fi; \
	if [ $$rc -ne 0 ]; then $(PYTHON) tools/check-roms --set $(SET); exit 1; fi; \
	$(MAKE) --no-print-directory all || exit 1; \
	$(PYTHON) tools/check-roms --set $(SET) --dir $(ROMDIR); hashes=$$?; \
	$(PYTHON) tools/bytecheck --set $(SET) --built $(ROMDIR) && [ $$hashes -eq 0 ]

coverage: all
	$(PYTHON) tools/coverage --set $(SET) $(LISTINGS)

test: selftest
	$(PYTHON) -m pytest -q tools

PYTOOLS := tools/romset.py tools/listings.py tools/test_*.py \
	tools/check-roms tools/merge-roms tools/split-roms tools/bytecheck tools/coverage

lint:
	uv run --frozen ruff check tools
	uv run --frozen mypy --scripts-are-modules $(PYTOOLS)

roms:            ## verify ~/archive/261104-stun-runner/roms/stunrun against tools/romsets/stunrun.json
	$(PYTHON) tools/check-roms

roms-refresh:    ## rewrite tools/romsets/stunrun.json from `mame -listxml stunrun`
	$(PYTHON) tools/check-roms --refresh

selftest:        ## the checker against a synthetic set
	$(PYTHON) tools/check-roms --selftest

clean:
	rm -rf $(BUILD)
