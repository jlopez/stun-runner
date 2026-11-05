-- MAME autoboot script: every object-ROM access of the ADSP-2100 (`make objtrace`).
--
--   TRACE_DIR=build/mame/ TRACE_NAME=objtrace-play TRACE_FRAMES=3600 TRACE_PLAY=1 \
--     mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 900 \
--     -nvram_directory <empty dir> -cfg_directory <empty dir> -autoboot_script tools/mame/objtrace.lua
--
-- The play run depends on the NVRAM it starts from (the archive's, from mame.ini, by default):
-- `make objtrace` gives each run its own empty NVRAM and cfg directories, so both start from the
-- factory state and the trace is reproducible.
--
-- The ADSP reaches the object ROMs only through its I/O at DM 2000-2007 (hdadsp_special_r/w,
-- harddriv_m.cpp:776-838): a write to DM 2001 (/SIMCLK) sets the word address, a write to DM 2007
-- (/MP) the 64K-word page, and each read of DM 2000 (/SIMBUF) returns the word at page + address
-- and advances the address. The script installs taps on that range of the ADSP data space
-- (word addresses) and cuts the accesses into read sequences: a sequence starts at a /SIMCLK
-- write and holds the reads until the next one. For each sequence it records the ADSP PC of the
-- /SIMCLK write, the /MP page in force at its first read, the start address and the number of
-- words read. It never records a value read from the ROM (CLAUDE.md section 2): only addresses
-- and counts. Taps observe; they do not read the I/O themselves, so the ROM address is not
-- disturbed.
--
-- Sequences are aggregated as "pc page address reads count" lines into <TRACE_NAME>.txt in
-- TRACE_DIR, preceded by a few "# key value" header lines: the frames, whether a game was
-- started, and two anomaly counters (a /MP write between two reads of one sequence; a read with
-- no /SIMCLK write before it). PC is the address of the /SIMCLK write instruction. The run stops
-- at a frame boundary, where the ADSP is usually inside a sequence: that last sequence may be
-- cut short, so it is dropped, not recorded, and "# open_at_end" says whether there was one
-- (it is not counted in "# sequences"). With TRACE_PLAY=1 the script inserts a coin at frame 900, presses
-- start at 960 and the trigger at 1020, as tools/mame/pcwatch.lua does, so the run covers a game.

local OUT = os.getenv("TRACE_DIR") or "./"
local NAME = os.getenv("TRACE_NAME") or "objtrace"
local FRAMES = tonumber(os.getenv("TRACE_FRAMES") or "3600")
local PLAY = os.getenv("TRACE_PLAY") == "1"

local machine = manager.machine
local adsp = machine.devices[":mainpcb:adsp"]
local data = adsp.spaces["data"]
local pc_state = adsp.state["PC"]

local page = 0
local seq = nil -- { pc, page, address, reads, mp }
local counts = {}
local mp_inside, orphan_reads, sequences, open_at_end = 0, 0, 0, 0

local function close()
  if seq then
    local key = string.format("%04X %d %04X %d", seq.pc, seq.page, seq.address, seq.reads)
    counts[key] = (counts[key] or 0) + 1
    sequences = sequences + 1
    seq = nil
  end
end

-- Taps stay referenced from globals: a collected tap is removed.
OBJTRACE_WRITE = data:install_write_tap(0x2000, 0x2007, "objtrace_w", function(offset, value)
  local reg = offset & 7
  if reg == 1 then
    close()
    -- the PC state already points past the write (MAME's adsp2100 core), hence - 1
    seq = { pc = pc_state.value - 1, page = -1, address = value & 0xFFFF, reads = 0, mp = false }
  elseif reg == 7 then
    if seq and seq.reads > 0 then seq.mp = true end
    page = value
  end
end)

OBJTRACE_READ = data:install_read_tap(0x2000, 0x2000, "objtrace_r", function(offset, value)
  if seq then
    if seq.reads == 0 then seq.page = page end
    if seq.mp then
      mp_inside = mp_inside + 1
      seq.mp = false
    end
    seq.reads = seq.reads + 1
  else
    orphan_reads = orphan_reads + 1
  end
  return value
end)

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")

local frame = 0
OBJTRACE_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  if frame == FRAMES then
    -- the sequence in flight may be incomplete: drop it rather than record a short read
    if seq then open_at_end = 1 end
    seq = nil
    local keys = {}
    for k in pairs(counts) do keys[#keys + 1] = k end
    table.sort(keys)
    local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
    f:write(string.format("# frames %d\n# play %s\n# sequences %d\n", FRAMES,
      PLAY and "yes" or "no", sequences))
    f:write(string.format("# mp_inside_sequence %d\n# orphan_reads %d\n# open_at_end %d\n",
      mp_inside, orphan_reads, open_at_end))
    f:write("# pc page address reads count\n")
    for _, k in ipairs(keys) do f:write(k, " ", counts[k], "\n") end
    f:close()
    io.write(string.format("objtrace.lua: %d frames, %d sequences, %d keys -> %s%s.txt\n",
      FRAMES, sequences, #keys, OUT, NAME))
    machine:exit()
  end
end)
