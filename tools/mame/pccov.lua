-- MAME autoboot script: which 68010 instructions execute (`make pccov`, docs/14-68k-descent.md).
--
--   PCCOV_FIFO=build/mame/pccov-attract.fifo PCCOV_DONE=build/mame/pccov-attractdone \
--     PCCOV_FRAMES=7200 PCCOV_PLAY=0 PCCOV_MENU= SDL_VIDEODRIVER=dummy mame stunrun -debug \
--     -debugger none -video none -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 900 \
--     -nvram_directory <empty dir> -cfg_directory <empty dir> -autoboot_script tools/mame/pccov.lua
--
-- Needs -debug (with -debugger none there is no window): the debugger's `trace` command writes one
-- line per executed instruction of the focused CPU ("PC: disassembly"; `noloop` folds a loop that
-- repeats into one "(loops for N instructions)" line) into PCCOV_FIFO, a named pipe that
-- `tools/m68k pccov-read` drains into the set of distinct PCs (a trace file would take gigabytes).
-- The debugger starts stopped, so the script sets execution_state to "run" (as pcwatch.lua).
--
-- Runs (PCCOV_PLAY, PCCOV_MENU), each from an empty private NVRAM and cfg state:
--   attract    PCCOV_PLAY=0: attract mode as the factory NVRAM has it;
--   game       PCCOV_PLAY=1: a coin at frame 900, start at 960, the trigger every 20 frames
--              from 1020 (as okitrace.lua and sndproto.lua);
--   selftest   PCCOV_MENU=selftest: the self-test switch held from the start, start pressed to
--              bypass the power-on test, then the boot program's test menus to the sound board's
--              "SA SELF TEST", the input steps of sndproto.lua (docs/11 section 5);
--   soundtest  PCCOV_MENU=soundtest: the same menus to "PLAY SOUNDS", the game's audio test
--              (043718), every one of its 108 entries played;
--   postest    PCCOV_MENU=postest: the self-test switch held and nothing pressed, so the boot
--              program's power-on tests (RAM, ROM checksums) run to their end.
-- After PCCOV_FRAMES frames it stops the trace, writes PCCOV_DONE and exits (MAME exits 0 when a
-- Lua callback raises, so the make target checks the marker). Nothing read from a ROM is recorded:
-- the reader keeps addresses only.

local FIFO = assert(os.getenv("PCCOV_FIFO"), "pccov.lua: PCCOV_FIFO not set")
local DONE = assert(os.getenv("PCCOV_DONE"), "pccov.lua: PCCOV_DONE not set")
local FRAMES = tonumber(os.getenv("PCCOV_FRAMES") or "3600")
local PLAY = os.getenv("PCCOV_PLAY") == "1"
local MENU = os.getenv("PCCOV_MENU") or ""
local SERVICE = MENU ~= ""

-- input steps {frame, port, field, value}, as sndproto.lua drives the menus
local A80000, STICK_Y = ":mainpcb:a80000", ":mainpcb:8BADC.2"
local B1, B2, START, SY = "P1 Button 1", "P1 Button 2", "1 Player Start", "AD Stick Y"
local ACTIONS = {}
local function press(fr, fld, port, value, hold)
  ACTIONS[#ACTIONS + 1] = { fr, port or A80000, fld, value or 1 }
  ACTIONS[#ACTIONS + 1] = { fr + (hold or 10), port or A80000, fld, 0 }
end
if MENU == "selftest" or MENU == "soundtest" then
  press(500, START, nil, 1, 600)  -- "PRESS START TO BYPASS SELFTEST", then the TEST MENU
  press(1200, B1)                 -- up from OPERATOR SCREENS to SPECIAL FUNCTIONS
  press(1300, START)
  press(1400, B1)                 -- up from EXIT to SOUND BOARD TESTS
  press(1450, START)              -- SA AUDIO TEST MENU: EXIT, SA SELF TEST, PLAY SOUNDS
  if MENU == "selftest" then
    press(1600, B2)               -- down to SA SELF TEST
    press(1650, START)
  else
    press(1600, B1)               -- up to PLAY SOUNDS
    press(1650, START)
    for i = 0, 107 do
      local fr = 1900 + 40 * i
      press(fr, B2, nil, 1, 5)              -- play the entry under the cursor
      press(fr + 20, SY, STICK_Y, 1, 3)     -- the stick down: the cursor to the next entry
    end
  end
elseif MENU ~= "" and MENU ~= "postest" then
  error("pccov.lua: PCCOV_MENU must be empty, selftest, soundtest or postest")
end

local machine = manager.machine
local dbg = assert(machine.debugger, "pccov.lua needs mame -debug (add -debugger none)")
dbg:command("trace " .. FIFO .. ",:mainpcb:maincpu,noloop")
dbg.execution_state = "run"

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")
local by_frame = {}
for _, a in ipairs(ACTIONS) do
  a[5] = assert(field(a[2], a[3]), "pccov.lua: no input field " .. a[2] .. " " .. a[3])
  by_frame[a[1]] = by_frame[a[1]] or {}
  table.insert(by_frame[a[1]], a)
end
if SERVICE then assert(field(":mainpcb:IN0", "Service Mode"), "no Service Mode"):set_value(1) end

local frame = 0
PCCOV_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame >= 1020 then
      if frame % 20 == 0 then trigger:set_value(1) elseif frame % 20 == 5 then trigger:clear_value() end
    end
  end
  for _, a in ipairs(by_frame[frame] or {}) do
    if a[4] == 0 then a[5]:clear_value() else a[5]:set_value(a[4]) end
  end
  if frame == FRAMES then
    dbg:command("trace off,:mainpcb:maincpu")
    local f = assert(io.open(DONE, "w"))
    f:write(string.format("frames %d play %s menu %s\n", FRAMES, PLAY and "yes" or "no",
      SERVICE and MENU or "-"))
    f:close()
    machine:exit()
  end
end)
