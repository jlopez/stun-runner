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
-- Level select (a poke, not a game feature; committed pending Jesus, CLAUDE.md section 5): the
-- level is the word at 0xFF9578, with a copy at 0xFF9556. The game clears both (clr.w at 0x02B95E
-- and 0x02B964; 0xFF9578 also at 0x024322); in 0x02543A a compiled-out debug switch at 0x025712
-- (`moveq #0,d1` at 0x0256FC selects case 0) would set them to 0Fh, 0Dh, 0Ch or 04h (cases 1, 2, 4,
-- 8 at 0x02572C-0x02581C). With LEVELS_START=N the script replaces every write of 0 to either word
-- by N (a write tap that returns the new value), and nothing else: the level still advances when
-- one is completed, and LEVELS_START=0 changes nothing.
--
-- Every object the ADSP loads starts with a /SIMCLK write of its number at PC 009E (docs/07
-- section 2). The script taps that write and counts, per (object, level word at that moment), the
-- loads; it writes "object level first_frame count" lines to <LEVELS_NAME>.txt after "# key
-- value" header lines (frames, start level, the number of replaced writes, the first frame
-- counted, and the frame of a machine reset that ended the run, if one did: see the end of
-- this file). Object numbers, levels, frames and counts only: no ROM or RAM contents.
--
-- Attract mode is not counted: the attract demo goes on loading objects until frame 965, when
-- the start button is released (94-99, 201 and 226 among them), and the level select already
-- turns the level word to N there. Only loads from the first trigger press on (LEVELS_FROM,
-- frame 1020) are counted; no object is loaded from frame 966 to 1025 (start levels 0, 5 and
-- 12 checked frame by frame), and the game's first load is at frame 1026 or later
-- (tools/test_objects.py checks it on the runs in build/mame/).
--
-- LEVELS_SNAP=f1,f2,... also saves a snapshot (manager.machine.video:snapshot(), headless) at
-- each of those frames into the -snapshot_directory (`make objlevels` gives each run its own,
-- build/mame/state-objlevels-NN/snap), named 0000.png, 0001.png, ... in frame order; the
-- frames are listed in the output header. Docs/07 section 11.2 cites its pictures this way.
--
-- LEVELS_MATRIX=o1,o2,... also writes <LEVELS_NAME>.matrix.txt: for each load of those objects,
-- the entry's rotation matrix as the ADSP holds it at PC 009E (DM 0000-0008, signed Q14, copied
-- from entity +14h, docs/07 section 2), one line per distinct (object, matrix) with its first
-- frame and count: "object first_frame count m00 m01 m02 m10 ... m22". ADSP data RAM, run-time
-- state, not ROM bytes.

-- MAME runs the script again after a machine reset; the first run has already written its output.
if LEVELS_DONE then return end

local OUT = os.getenv("LEVELS_DIR") or "./"
local NAME = os.getenv("LEVELS_NAME") or "objlevels"
local START = tonumber(os.getenv("LEVELS_START") or "0")
local FRAMES = tonumber(os.getenv("LEVELS_FRAMES") or "8000")
local FROM = tonumber(os.getenv("LEVELS_FROM") or "1020")
local SNAP = {}
for f in (os.getenv("LEVELS_SNAP") or ""):gmatch("%d+") do SNAP[tonumber(f)] = true end
local SNAP_LIST = os.getenv("LEVELS_SNAP") or ""
local MATRIX = {}
for o in (os.getenv("LEVELS_MATRIX") or ""):gmatch("%d+") do MATRIX[tonumber(o)] = true end
local matrices, matrix_keys = {}, {}

local machine = manager.machine
local adsp = machine.devices[":mainpcb:adsp"]
local pc_state = adsp.state["PC"]
local cpu = machine.devices[":mainpcb:maincpu"].spaces["program"]
local dm = adsp.spaces["data"]

local frame, replaced = 0, 0
local first, counts = {}, {}

-- Taps stay referenced from globals: a collected tap is removed.
LEVELS_DIR_TAP = adsp.spaces["data"]:install_write_tap(0x2001, 0x2001, "objlevels_w",
  function(offset, value)
    if frame >= FROM and pc_state.value - 1 == 0x009E then -- the PC already points past the write
      local key = string.format("%d %d", value & 0xFFFF, cpu:read_u16(0xFF9578))
      if not first[key] then first[key] = frame end
      counts[key] = (counts[key] or 0) + 1
      if MATRIX[value & 0xFFFF] then
        local m = {}
        for i = 0, 8 do
          local w = dm:read_u16(i)
          m[#m + 1] = w >= 0x8000 and w - 0x10000 or w
        end
        local mk = string.format("%d %s", value & 0xFFFF, table.concat(m, " "))
        if not matrices[mk] then
          matrices[mk] = { frame, 0 }
          matrix_keys[#matrix_keys + 1] = mk
        end
        matrices[mk][2] = matrices[mk][2] + 1
      end
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

local function finish(reset_frame)
  if LEVELS_DONE then return end
  LEVELS_DONE = true
  local frames = reset_frame or FRAMES
  local keys = {}
  for k in pairs(counts) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    local a1, a2 = a:match("(%d+) (%d+)")
    local b1, b2 = b:match("(%d+) (%d+)")
    if tonumber(a1) ~= tonumber(b1) then return tonumber(a1) < tonumber(b1) end
    return tonumber(a2) < tonumber(b2)
  end)
  local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
  f:write(string.format("# frames %d\n# start_level %d\n# replaced_writes %d\n# counted_from %d\n",
    frames, START, replaced, FROM))
  if reset_frame then f:write(string.format("# reset_at_frame %d\n", reset_frame)) end
  if SNAP_LIST ~= "" then f:write(string.format("# snapshots %s\n", SNAP_LIST)) end
  f:write("# object level first_frame count\n")
  for _, k in ipairs(keys) do f:write(string.format("%s %d %d\n", k, first[k], counts[k])) end
  f:close()
  if #matrix_keys > 0 then
    local g = assert(io.open(OUT .. NAME .. ".matrix.txt", "w"))
    g:write("# object first_frame count m00 m01 m02 m10 m11 m12 m20 m21 m22\n")
    for _, mk in ipairs(matrix_keys) do
      local o, rest = mk:match("^(%d+) (.*)$")
      g:write(string.format("%s %d %d %s\n", o, matrices[mk][1], matrices[mk][2], rest))
    end
    g:close()
  end
  io.write(string.format("objlevels.lua: %d frames%s, start %d, %d keys -> %s%s.txt\n", frames,
    reset_frame and " (machine reset)" or "", START, #keys, OUT, NAME))
  machine:exit()
end

LEVELS_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if SNAP[frame] then machine.video:snapshot() end
  if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
  if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
  if frame >= 1020 then
    if frame % 20 == 0 then trigger:set_value(1) elseif frame % 20 == 5 then trigger:clear_value() end
  end
  if frame == FRAMES then finish(nil) end
end)

-- A machine reset ends the run where it is, with "# reset_at_frame N" in the header: from start
-- level 23 up the 68k stops servicing the watchdog and MAME resets the machine
-- ("watchdog_fired: reset issued" in error.log with -log; docs/07 section 11.4), and MAME then
-- runs this script again, whose frame count would start over and never reach LEVELS_FRAMES.
LEVELS_RESET = emu.add_machine_reset_notifier(function() finish(frame) end)
