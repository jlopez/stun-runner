-- MAME autoboot script: what the JSA II's 6502 tells the OKI M6295 (`make okitrace`).
--
--   OKI_DIR=build/mame/ OKI_NAME=okitrace-game OKI_FRAMES=10800 OKI_PLAY=1 \
--     SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 \
--     -seconds_to_run 900 -nvram_directory <empty dir> -cfg_directory <empty dir> \
--     -autoboot_script tools/mame/okitrace.lua
--
-- The 6502 reaches the M6295 through /WRV, a write at 2A00 (atarijsa.cpp atarijsa2_map: 2A00
-- mirror 01F9, oki_w -> okim6295_device::write), sets pin 7 (the sample rate) through /WRIO
-- (2A04, wrio_w: bit 3 -> set_pin7, bit 2 low resets the OKI) and the OKI volume through /MIX
-- (2A06, mix_w), and reads its command byte from the 68010 through /RDP (2802 mirror 01F9). The
-- script taps the 6502's writes to 2A00-2BFF and reads of 2800-29FF and decodes the OKI byte
-- stream as okim6295_device::write does: a byte with bit 7 set starts a two-byte command whose
-- low 7 bits are the phrase number; the next byte's high nibble is the voice mask and its low
-- nibble the attenuation; a byte with bit 7 clear outside a command stops the voices of its
-- bits 6-3.
--
-- Which command played a phrase: the 6502's main loop (4171-4189) takes each command from its
-- queue at 0200 and calls the dispatcher at 4371 with Y = the command, which reads the handler
-- type at 6100+Y (and its parameter at 616D+Y). The OKI handler (type 13h, 5BFE) reads the
-- phrase of its effect at 6532+effect (5C43) before the first command byte. A read tap on
-- 6100-616C records the command being dispatched and one on 6532-6566 the effect; both are the
-- program's own reads (the taps observe them, they read nothing themselves), so a start is
-- attributed to the command whose dispatch led to it, not guessed from timing.
--
-- Output, <OKI_NAME>.txt in OKI_DIR: "# key value" header lines, then aggregated lines
--   start <phrase> <voices> <attenuation> <pc> <command> <effect> <count> <first frame>
--   stop <mask> <pc> <count>
--   wrio <value> <count>        (pin 7 = bit 3, OKI reset = bit 2 low)
--   mix <value> <count>
--   dispatch <command> <count>  (every command the main loop dispatched)
--   muted <command> <count>     (OKI play commands dispatched while RAM 1E is nonzero)
-- PC is the 6502 address of the store (MAME's m6502 PC state holds the address of the
-- instruction in progress; the opcode there is checked to be a store and "pc_unknown" counts
-- the others). Command and effect are hex, "--" when none was read yet. Values written are the
-- program's runtime state, not ROM bytes; nothing read from the OKI ROM is recorded.
--
-- OKI_PLAY=1: a coin at frame 900, start at 960, then the trigger every 20 frames from 1020 (as
-- tools/mame/objlevels.lua), so the run covers a game. OKI_INJECT=38,39,...: from frame
-- OKI_INJECT_FROM (default 1200), every OKI_INJECT_EVERY frames (default 300), the next command
-- of the list is written to the sound latch as the 68010 writes it (a byte write of the high
-- byte at 600000: harddriv.cpp installs main_command_w at 600000-603FFF with mask FF00), so the
-- run shows what each command plays. The script writes <OKI_NAME>done just before it exits:
-- MAME exits 0 when a Lua callback raises, so the make target checks the marker.

local OUT = os.getenv("OKI_DIR") or "./"
local NAME = os.getenv("OKI_NAME") or "okitrace"
local FRAMES = tonumber(os.getenv("OKI_FRAMES") or "3600")
local PLAY = os.getenv("OKI_PLAY") == "1"
local INJECT = {}
for c in string.gmatch(os.getenv("OKI_INJECT") or "", "[^,]+") do
  INJECT[#INJECT + 1] = tonumber(c, 16)
end
local INJECT_FROM = tonumber(os.getenv("OKI_INJECT_FROM") or "1200")
local INJECT_EVERY = tonumber(os.getenv("OKI_INJECT_EVERY") or "300")
local INJECT_UNMUTE = 0x02

local machine = manager.machine
local cpu = assert(machine.devices[":mainpcb:jsa:cpu"], "no :mainpcb:jsa:cpu")
local program = cpu.spaces["program"]
local pc_state = cpu.state["PC"]
local m68k = assert(machine.devices[":mainpcb:maincpu"], "no :mainpcb:maincpu").spaces["program"]

local starts, stops, wrio, mix, dispatches, muted = {}, {}, {}, {}, {}, {}
local first_frame = {}
local pending = nil -- phrase number of a command in progress
local command, effect = nil, nil
local frame = 0
local pc_unknown, start_count, stop_count, oki_reads, injected = 0, 0, 0, 0, 0
local muted_count = 0

local function bump(t, k) t[k] = (t[k] or 0) + 1 end
local function hex(v) return v and string.format("%02X", v) or "--" end

local function store_pc()
  local pc = pc_state.value
  local op = program:read_u8(pc)
  -- 8D STA abs, 8E STX abs, 8C STY abs, 9D STA abs,X, 99 STA abs,Y
  if op == 0x8D or op == 0x8E or op == 0x8C or op == 0x9D or op == 0x99 then
    return string.format("%04X", pc)
  end
  pc_unknown = pc_unknown + 1
  return "????"
end

-- Taps stay referenced from globals: a collected tap is removed.
OKITRACE_WRITE = program:install_write_tap(0x2A00, 0x2BFF, "okitrace_w", function(offset, value)
  local reg = (offset >> 1) & 3
  if reg == 0 then
    local pc = store_pc()
    if pending ~= nil then
      local key = string.format("start %d %X %X %s %s %s", pending, value >> 4, value & 15, pc,
        hex(command), hex(effect))
      bump(starts, key)
      if not first_frame[key] then first_frame[key] = frame end
      start_count = start_count + 1
      pending = nil
    elseif value & 0x80 ~= 0 then
      pending = value & 0x7F
    else
      bump(stops, string.format("stop %X %s", (value >> 3) & 15, pc))
      stop_count = stop_count + 1
    end
  elseif reg == 2 then
    bump(wrio, string.format("wrio %02X", value))
  elseif reg == 3 then
    bump(mix, string.format("mix %02X", value))
  end
end)

OKITRACE_READ = program:install_read_tap(0x2800, 0x29FF, "okitrace_r", function(offset, value)
  if (offset >> 1) & 3 == 0 then oki_reads = oki_reads + 1 end
  return value
end)

OKITRACE_DISPATCH = program:install_read_tap(0x6100, 0x616C, "okitrace_d", function(offset, value)
  command = offset - 0x6100
  effect = nil
  bump(dispatches, string.format("dispatch %02X", command))
  -- an OKI play command (handler type 13h) while RAM 1E is nonzero: the handler returns at
  -- 5C01 without touching the OKI (command 01 sets 1E to F0, 02 clears it; 1E is also a
  -- threshold on YM2151 paths, 44C8 and 4EE6, docs/10 section 4)
  if value == 0x13 and program:read_u8(0x1E) ~= 0 then
    bump(muted, string.format("muted %02X", command))
    muted_count = muted_count + 1
  end
  return value
end)

OKITRACE_EFFECT = program:install_read_tap(0x6532, 0x6566, "okitrace_e", function(offset, value)
  effect = offset - 0x6532
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

local function dump(f, t, extra)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    if extra then f:write(k, " ", t[k], " ", extra[k], "\n") else f:write(k, " ", t[k], "\n") end
  end
end

OKITRACE_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame >= 1020 then
      if frame % 20 == 0 then trigger:set_value(1) elseif frame % 20 == 5 then trigger:clear_value() end
    end
  end
  if #INJECT > 0 and frame >= INJECT_FROM then
    local k = (frame - INJECT_FROM) // INJECT_EVERY + 1
    local at = (frame - INJECT_FROM) % INJECT_EVERY
    if k <= #INJECT then
      -- command 02 first (clears RAM 1E, which command 01 sets in attract mode and which stops the OKI play handler), the
      -- command itself four frames later, once the 6502 has taken 02 from the latch
      if at == 0 then m68k:write_u16(0x600000, INJECT_UNMUTE << 8) end
      if at == 4 then
        m68k:write_u16(0x600000, INJECT[k] << 8)
        injected = injected + 1
      end
    end
  end
  if frame == FRAMES then
    local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
    f:write(string.format("# frames %d\n# play %s\n# injected %d\n# starts %d\n# stops %d\n",
      FRAMES, PLAY and "yes" or "no", injected, start_count, stop_count))
    f:write(string.format("# pc_unknown %d\n# oki_status_reads %d\n# pending_at_end %s\n",
      pc_unknown, oki_reads, pending and tostring(pending) or "-"))
    f:write(string.format("# muted_oki_dispatches %d\n", muted_count))
    f:write("# start phrase voices attenuation pc command effect count first_frame\n")
    dump(f, starts, first_frame)
    dump(f, stops)
    dump(f, wrio)
    dump(f, mix)
    dump(f, dispatches)
    dump(f, muted)
    f:close()
    local done = assert(io.open(OUT .. NAME .. "done", "w"))
    done:close()
    io.write(string.format("okitrace.lua: %d frames, %d starts, %d stops -> %s%s.txt\n",
      FRAMES, start_count, stop_count, OUT, NAME))
    machine:exit()
  end
end)
