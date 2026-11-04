# Kickoff skeleton. The assembler targets arrive with milestone 1 (docs/03-plan.md);
# until then only the ROM-set check exists. ROMs live outside the repo (CLAUDE.md section 2).

PYTHON ?= python3

.PHONY: roms roms-refresh selftest

roms:            ## verify ~/archive/261104-stun-runner/roms/stunrun against tools/romsets/stunrun.json
	$(PYTHON) tools/check-roms

roms-refresh:    ## rewrite tools/romsets/stunrun.json from `mame -listxml stunrun`
	$(PYTHON) tools/check-roms --refresh

selftest:        ## the checker against a synthetic set
	$(PYTHON) tools/check-roms --selftest
