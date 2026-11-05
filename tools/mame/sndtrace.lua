-- MAME autoboot script: what the JSA II 6502 executes and reads, and what the 68010 and the
-- 6502 say to each other (`make sndtrace`, `make soundcheck`; docs/09-sound-program.md).
--
--   TRACE_DIR=build/mame/ TRACE_NAME=sndtrace-attract TRACE_FRAMES=7200 TRACE_PLAY=0 \
--     SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 \
--     -seconds_to_run 900 -nvram_directory <empty dir> -cfg_directory <empty dir> \
--     -autoboot_script tools/mame/sndtrace.lua
--
-- Taps observe; they never change a value. On the 6502's program space:
--   * every read of 3000-FFFF (the banked page and the fixed ROM). MAME's 6502 core sets its
--     NPC to the instruction's address just before the opcode fetch (m6502.cpp prefetch_start),
--     and the "PC" state entry is NPC, so a read at the address PC holds is an opcode fetch; a
--     read at PC+1 or PC+2 is an operand byte (or the dummy read of a one-byte instruction);
--     any other read is a data read, recorded with the PC of the instruction that made it. Two
--     kinds of dummy read the core models are not data and are left out: the reads a taken
--     branch or an RTS makes at its own target, and the read at the wrong page that an indexed
--     access crossing a page makes just before the real one 100h higher (dropped when the next
--     data read of the same instruction is that address + 100h).
--   * writes of 2000-2FFF: the YM2151 (2000 register, 2001 data), and, under the mirror mask
--     01F9 of atarijsa2_map, OKI (2A00), the response to the 68010 (2A02), /WRIO (2A04) and
--     /MIX (2A06); reads of the command latch (2802 under the same mask).
-- On the 68010's program space: writes of the command byte (600000-603FFF, the high byte:
-- harddriv.cpp init_multisync installs main_command_w with mask FF00), recorded with the frame
-- and the 68010 PC (CURPC: the instruction's address), reads of the response there, and reads of
-- 604000-607FFF (hd68k_sound_reset_r: a reset of the sound board).
--
-- Output, TRACE_DIR..TRACE_NAME..".txt" (a build artefact: the YM2151 and OKI streams carry
-- values the program takes from its ROM, so the file never leaves build/; the committed summary
-- tools/jsa-trace writes keeps addresses, counts and command/response values only):
--   # key value          header (frames, play, counters)
--   F addr count         opcode fetches per address (bank page reads as B<n>:3xxx)
--   D addr pc count      data reads per (address, instruction PC)
--   C frame pc value     a command byte written by the 68010 (pc = its instruction)
--   R frame value        a response byte written by the 6502 at 2A02
--   Y frame reg value    a YM2151 register write (the register last written to 2000)
--   O frame value        an OKI M6295 command byte
--   W frame value / X frame value   /WRIO and /MIX writes
--   S frame              a sound-board reset by the 68010 (read of 604000)
-- With TRACE_PLAY=1 the script inserts a coin at frame 900, presses start at 960 and the trigger
-- at 1020, as tools/mame/objtrace.lua does, so the run covers a started game. The last line is
-- "# done": the make target fails without it (MAME exits 0 when a Lua callback raises).

local OUT = os.getenv("TRACE_DIR") or "./"
local NAME = os.getenv("TRACE_NAME") or "sndtrace"
local FRAMES = tonumber(os.getenv("TRACE_FRAMES") or "7200")
local PLAY = os.getenv("TRACE_PLAY") == "1"

local machine = manager.machine
local jsa = machine.devices[":mainpcb:jsa:cpu"]
local main = machine.devices[":mainpcb:maincpu"]
assert(jsa and main, "sndtrace.lua: stunrun devices not found")
local prog = jsa.spaces["program"]
local mprog = main.spaces["program"]
local npc = jsa.state["PC"]
local mpc = main.state["CURPC"]

local frame = 0
local bank = 0
local fetch, data = {}, {}
local events = {}
local counts = { reads = 0, fetches = 0, operands = 0, data = 0, dummy = 0, ym = 0, oki = 0,
  cmd = 0, resp = 0, cmd_reads = 0, resp_reads = 0, resets = 0, wrio = 0, mix = 0 }
local ym_reg = -1
local cur_pc, cur_skip = -1, false
local pend_addr, pend_pc, pend_raw = nil, nil, nil

local function key(addr)
  if addr < 0x4000 then return string.format("B%d:%04X", bank, addr) end
  return string.format("%04X", addr)
end

local function commit()
  if pend_addr then
    local k = pend_addr .. " " .. string.format("%04X", pend_pc)
    data[k] = (data[k] or 0) + 1
    counts.data = counts.data + 1
    pend_addr = nil
  end
end

local function event(s)
  events[#events + 1] = s
end

-- Taps stay referenced from globals: a collected tap is removed.
SNDTRACE_ROM = prog:install_read_tap(0x3000, 0xFFFF, "sndtrace_rom", function(addr, value)
  counts.reads = counts.reads + 1
  local pc = npc.value
  if addr == pc then
    commit()
    local k = key(addr)
    fetch[k] = (fetch[k] or 0) + 1
    counts.fetches = counts.fetches + 1
    cur_pc = pc
    -- 10h/30h/.../F0h: the eight branches; 60h: RTS. Their extra reads are dummy reads.
    cur_skip = (value & 0x1F) == 0x10 or value == 0x60
  elseif addr > pc and addr <= pc + 2 then
    counts.operands = counts.operands + 1
  elseif cur_skip and pc == cur_pc then
    counts.dummy = counts.dummy + 1
  else
    local k = key(addr)
    if pend_addr and pend_pc == pc and addr == pend_raw + 0x100 then
      pend_addr = nil
      counts.dummy = counts.dummy + 1
    else
      commit()
    end
    pend_addr, pend_pc, pend_raw = k, pc, addr
  end
  return value
end)

SNDTRACE_IO_W = prog:install_write_tap(0x2000, 0x2FFF, "sndtrace_io_w", function(addr, value)
  if addr == 0x2000 then
    ym_reg = value
  elseif addr == 0x2001 then
    counts.ym = counts.ym + 1
    event(string.format("Y %d %02X %02X", frame, ym_reg, value))
  else
    local port = addr & ~0x01F9 & 0xFFFF
    if port == 0x2A00 then
      counts.oki = counts.oki + 1
      event(string.format("O %d %02X", frame, value))
    elseif port == 0x2A02 then
      counts.resp = counts.resp + 1
      event(string.format("R %d %02X", frame, value))
    elseif port == 0x2A04 then
      counts.wrio = counts.wrio + 1
      bank = (value >> 6) & 3
      event(string.format("W %d %02X", frame, value))
    elseif port == 0x2A06 then
      counts.mix = counts.mix + 1
      event(string.format("X %d %02X", frame, value))
    end
  end
  return value
end)

SNDTRACE_IO_R = prog:install_read_tap(0x2800, 0x29FF, "sndtrace_io_r", function(addr, value)
  if (addr & ~0x01F9 & 0xFFFF) == 0x2802 then counts.cmd_reads = counts.cmd_reads + 1 end
  return value
end)

SNDTRACE_CMD = mprog:install_write_tap(0x600000, 0x603FFF, "sndtrace_cmd",
  function(addr, value, mask)
    if (mask & 0xFF00) ~= 0 then
      counts.cmd = counts.cmd + 1
      event(string.format("C %d %06X %02X", frame, mpc.value, (value >> 8) & 0xFF))
    end
    return value
  end)

SNDTRACE_RESP = mprog:install_read_tap(0x600000, 0x603FFF, "sndtrace_resp",
  function(addr, value, mask)
    if (mask & 0xFF00) ~= 0 then counts.resp_reads = counts.resp_reads + 1 end
    return value
  end)

SNDTRACE_RESET = mprog:install_read_tap(0x604000, 0x607FFF, "sndtrace_reset",
  function(addr, value)
    counts.resets = counts.resets + 1
    event(string.format("S %d", frame))
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

local function sorted_keys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  return keys
end

SNDTRACE_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  if frame == FRAMES then
    commit()
    local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
    f:write(string.format("# frames %d\n# play %s\n", FRAMES, PLAY and "yes" or "no"))
    for _, k in ipairs(sorted_keys(counts)) do f:write("# ", k, " ", counts[k], "\n") end
    for _, k in ipairs(sorted_keys(fetch)) do f:write("F ", k, " ", fetch[k], "\n") end
    for _, k in ipairs(sorted_keys(data)) do f:write("D ", k, " ", data[k], "\n") end
    for _, e in ipairs(events) do f:write(e, "\n") end
    f:write("# done\n")
    f:close()
    io.write(string.format("sndtrace.lua: %d frames, %d fetch addresses, %d commands, " ..
      "%d responses, %d YM2151 writes, %d OKI writes -> %s%s.txt\n", FRAMES,
      #sorted_keys(fetch), counts.cmd, counts.resp, counts.ym, counts.oki, OUT, NAME))
    machine:exit()
  end
end)
