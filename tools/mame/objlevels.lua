-- MAME autoboot script: which objects a game loads, per level (`make objlevels`, docs/07
-- section 11.4).
--
--   LEVELS_DIR=build/mame/ LEVELS_NAME=objlevels-05 LEVELS_START=5 LEVELS_FRAMES=8000 \
--     mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 900 \
--     -nvram_directory <empty dir> -cfg_directory <empty dir> -autoboot_script tools/mame/objlevels.lua
--
-- A game is started as tools/mame/objtrace.lua starts it (coin at frame 900, start at 960, the
-- trigger at 1020), then the trigger is pressed every 20 frames (5 frames down) so that the
-- vehicle shoots. The yoke is left centred: the game keeps the vehicle in the tunnel.
--
-- Level select (a scratch poke, not a game feature): the level is the word at 0xFF9578, with a
-- copy at 0xFF9556. The game clears both (clr.w at 0x02B95E and 0x02B964; 0xFF9578 also at
-- 0x024322); in 0x02543A a compiled-out debug switch at 0x025712 (`moveq #0,d1` at 0x0256FC selects case 0) would set them to 0Fh, 0Dh, 0Ch or 04h
-- (cases 1, 2, 4, 8 at 0x02572C-0x02581C). With LEVELS_START=N the script replaces every write
-- of 0 to either word by N (a write tap that returns the new value), and nothing else: the level
-- still advances when one is completed, and LEVELS_START=0 changes nothing.
--
-- Every object the ADSP loads starts with a /SIMCLK write of its number at PC 009E (docs/07
-- section 2). The script taps that write and counts, per (object, level word at that moment), the
-- loads; it writes "object level first_frame count" lines to <LEVELS_NAME>.txt after "# key
-- value" header lines (frames, start level, the number of replaced writes). Object numbers,
-- levels, frames and counts only: no ROM or RAM contents.

local OUT = os.getenv("LEVELS_DIR") or "./"
local NAME = os.getenv("LEVELS_NAME") or "objlevels"
local START = tonumber(os.getenv("LEVELS_START") or "0")
local FRAMES = tonumber(os.getenv("LEVELS_FRAMES") or "8000")

local machine = manager.machine
local adsp = machine.devices[":mainpcb:adsp"]
local pc_state = adsp.state["PC"]
local cpu = machine.devices[":mainpcb:maincpu"].spaces["program"]

local frame, replaced = 0, 0
local first, counts = {}, {}

-- Taps stay referenced from globals: a collected tap is removed.
LEVELS_DIR_TAP = adsp.spaces["data"]:install_write_tap(0x2001, 0x2001, "objlevels_w",
  function(offset, value)
    if pc_state.value - 1 == 0x009E then -- the PC already points past the write
      local key = string.format("%d %d", value & 0xFFFF, cpu:read_u16(0xFF9578))
      if not first[key] then first[key] = frame end
      counts[key] = (counts[key] or 0) + 1
    end
  end)

local function level_select(offset, value, mask)
  if START > 0 and value == 0 then
    replaced = replaced + 1
    return START
  end
end
LEVELS_TAP_1 = cpu:install_write_tap(0xFF9556, 0xFF9557, "objlevels_l1", level_select)
LEVELS_TAP_2 = cpu:install_write_tap(0xFF9578, 0xFF9579, "objlevels_l2", level_select)

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(coin and start and trigger, "stunrun input fields not found")

LEVELS_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
  if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
  if frame >= 1020 then
    if frame % 20 == 0 then trigger:set_value(1) elseif frame % 20 == 5 then trigger:clear_value() end
  end
  if frame == FRAMES then
    local keys = {}
    for k in pairs(counts) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
      local a1, a2 = a:match("(%d+) (%d+)")
      local b1, b2 = b:match("(%d+) (%d+)")
      if tonumber(a1) ~= tonumber(b1) then return tonumber(a1) < tonumber(b1) end
      return tonumber(a2) < tonumber(b2)
    end)
    local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
    f:write(string.format("# frames %d\n# start_level %d\n# replaced_writes %d\n", FRAMES, START,
      replaced))
    f:write("# object level first_frame count\n")
    for _, k in ipairs(keys) do f:write(string.format("%s %d %d\n", k, first[k], counts[k])) end
    f:close()
    io.write(string.format("objlevels.lua: %d frames, start %d, %d keys -> %s%s.txt\n", FRAMES,
      START, #keys, OUT, NAME))
    machine:exit()
  end
end)
