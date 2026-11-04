-- MAME autoboot script: does the 68010 ever execute outside its ROM? (`make pcwatch`)
--
--   WATCH_DIR=build/mame/ WATCH_FRAMES=1800 WATCH_PLAY=1 mame stunrun -debug -debugger none \
--     -video none -sound none -nothrottle -autoboot_script tools/mame/pcwatch.lua \
--     -autoboot_delay 0 -seconds_to_run 600
--
-- Needs -debug (with -debugger none there is no window): MAME's registerpoints (`rpset`) evaluate
-- a condition before every instruction of the focused CPU, so the check is exact, not sampled.
-- The Lua API of MAME 0.289 has no rpset method on device_debug: the script goes through
-- debugger commands (manager.machine.debugger:command), and the debugger starts stopped, so the
-- script sets execution_state to "run". Two registerpoints on the 68010:
--   pc > temp0  -> temp0 = pc   (the highest PC executed)
--   pc < temp1  -> temp1 = pc   (the lowest PC executed)
-- Any instruction fetched from RAM (FF8000 up) or outside the ROM image (C0000 up) raises the
-- maximum, so the maximum answers both. Only one registerpoint acts per instruction (the hit
-- stops the CPU, the action resumes it), which is why there are no separate counters: a counter
-- that fired would hide the instruction from the maximum. The two here coincide only on the
-- first instruction (the reset PC, 000216), which the minimum records.
-- It also samples cpu.state["PC"] once a frame (what works without -debug; CURPC holds the same
-- value), to show how little a per-frame sample sees. With WATCH_PLAY=1 it inserts a coin at
-- frame 900, presses start at 960 and the trigger at 1020 (level select: novice), so the run
-- covers game play after attract mode (the race is on screen by frame 2400).
-- After WATCH_FRAMES frames (default 1800) it writes pcwatch.txt into WATCH_DIR and exits.

local OUT = os.getenv("WATCH_DIR") or "./"
local FRAMES = tonumber(os.getenv("WATCH_FRAMES") or "1800")
local PLAY = os.getenv("WATCH_PLAY") == "1"

local machine = manager.machine
local cpu = machine.devices[":mainpcb:maincpu"]
local dbg = machine.debugger
assert(dbg, "pcwatch.lua needs mame -debug (add -debugger none for no window)")

dbg:command("focus :mainpcb:maincpu")
dbg:command("temp0 = 0")
dbg:command("temp1 = ffffffff")
dbg:command("rpset pc > temp0,{temp0 = pc; g}")
dbg:command("rpset pc < temp1,{temp1 = pc; g}")
dbg.execution_state = "run"

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")

local frame, sampled_max, sampled_ram = 0, 0, 0
WATCH_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  local pc = cpu.state["PC"].value
  if pc > sampled_max then sampled_max = pc end
  if pc >= 0xFF0000 then sampled_ram = sampled_ram + 1 end
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  if frame == FRAMES then
    local before = #dbg.consolelog
    dbg:command('printf "max_pc %X",temp0')
    dbg:command('printf "min_pc %X",temp1')
    local lines = { string.format("frames %d\nplay %s\n", FRAMES, PLAY and "yes" or "no") }
    for i = before + 1, #dbg.consolelog do lines[#lines + 1] = dbg.consolelog[i] .. "\n" end
    lines[#lines + 1] = string.format("sampled_max_pc %X\nsampled_in_ram %d\n", sampled_max,
      sampled_ram)
    local f = assert(io.open(OUT .. "pcwatch.txt", "w"))
    f:write(table.concat(lines))
    f:close()
    io.write("pcwatch.lua: ", table.concat(lines):gsub("\n", " "), "-> ", OUT, "\n")
    machine:exit()
  end
end)
