-- MAME autoboot script: does the GSP read the image-quad corners sign-extended? (`make fieldext`)
--
--   FIELD_DIR=build/mame/ FIELD_FRAMES=3100 mame stunrun -debug -debugger none \
--     -video none -sound none -nothrottle -autoboot_script tools/mame/fieldext.lua \
--     -autoboot_delay 0 -seconds_to_run 600
--
-- `MOVE *A5+,A1,0` (FFF49380, cmd_1_image_quad) reads point 1's x through field 0; with ST FE0
-- (bit 5) clear the 16-bit field is zero-extended (MAME: MOVE_NI_R, 34010ops.hxx, SET_NZ_VAL on
-- the RFIELD0 result), so N is never set and the JRNN at FFF49390 is always taken. Breakpoints
-- count the hits with FE0 = 1 and FE0 = 0 at FFF49380 and at FFF45010 (the SOM list's per-command
-- loop), and keep the last ST. Attract mode reaches its image quads (the story screen) by frame
-- 2700. After FIELD_FRAMES frames it writes fieldext.txt into FIELD_DIR and exits.

local OUT = os.getenv("FIELD_DIR") or "./"
local FRAMES = tonumber(os.getenv("FIELD_FRAMES") or "3100")

local machine = manager.machine
local dbg = machine.debugger
assert(dbg, "fieldext.lua needs mame -debug (add -debugger none for no window)")
local gsp = machine.devices[":mainpcb:gsp"]

for i = 0, 5 do dbg:command("temp" .. i .. " = 0") end
gsp.debug:bpset(0xfff49380, "1",
  "temp0 = temp0 + ((st >> 5) & 1); temp1 = temp1 + 1 - ((st >> 5) & 1); temp4 = st; g")
gsp.debug:bpset(0xfff45010, "1",
  "temp2 = temp2 + ((st >> 5) & 1); temp3 = temp3 + 1 - ((st >> 5) & 1); temp5 = st; g")
dbg.execution_state = "run"

local frame = 0
FIELDEXT_SUB = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame ~= FRAMES then return end
  local start = #dbg.consolelog
  for i = 0, 5 do dbg:command("print temp" .. i) end
  local log = dbg.consolelog
  local v = {}
  for i = start + 1, #log do v[#v + 1] = tostring(log[i]) end
  local f = assert(io.open(OUT .. "fieldext.txt", "w"))
  f:write(string.format("frames %d\n", FRAMES))
  f:write(string.format("FFF49380 (p1.x read): FE0=1 %s hits, FE0=0 %s hits, last ST %s\n",
    v[1] or "?", v[2] or "?", v[5] or "?"))
  f:write(string.format("FFF45010 (SOM command loop): FE0=1 %s hits, FE0=0 %s hits, last ST %s\n",
    v[3] or "?", v[4] or "?", v[6] or "?"))
  f:close()
  machine:exit()
end)
