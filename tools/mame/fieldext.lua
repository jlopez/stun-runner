-- MAME autoboot script: does the GSP read the image-quad corners sign-extended? (`make fieldext`)
--
--   FIELD_DIR=build/mame/ FIELD_FRAMES=3100 mame stunrun -debug -debugger none \
--     -video none -sound none -nothrottle -autoboot_script tools/mame/fieldext.lua \
--     -autoboot_delay 0 -seconds_to_run 600
--
-- `MOVE *A5+,An,0` reads the image-quad corners through field 0 (FFF49380: point 1's x,
-- cmd_1_image_quad), and the handler has no SETF: with ST FE0 (bit 5) set the 16-bit field is
-- sign-extended, clear zero-extended (MAME: MOVE_NI_R, 34010ops.hxx, SET_NZ_VAL on the RFIELD0
-- result). read_list_header sets FE0 (`SETF 10h,1,0`, FFF4D990) before every list; handlers 4, 5,
-- 6, 8, 9, C and E0 clear it. Breakpoints count the hits with FE0 = 1 and FE0 = 0 at
-- FFF46E30 (run_command_list, the start of every list), FFF44BF0 (cmd_7_som_list), FFF49380 and
-- FFF45010 (the SOM list's per-command loop), and keep the last ST at the last two. Attract mode
-- reaches its image quads (the story screen) by frame 2700. After FIELD_FRAMES frames it writes
-- fieldext.txt into FIELD_DIR and exits.

local OUT = os.getenv("FIELD_DIR") or "./"
local FRAMES = tonumber(os.getenv("FIELD_FRAMES") or "3100")

local machine = manager.machine
local dbg = machine.debugger
assert(dbg, "fieldext.lua needs mame -debug (add -debugger none for no window)")
local gsp = machine.devices[":mainpcb:gsp"]

-- the debugger has ten temporaries: two counts per breakpoint, the last ST at the last two
local POINTS = {
  {0xfff46e30, "FFF46E30 (list start)"},
  {0xfff44bf0, "FFF44BF0 (command 7)"},
  {0xfff49380, "FFF49380 (p1.x read)"},
  {0xfff45010, "FFF45010 (SOM command loop)"},
}
for i = 0, 9 do dbg:command("temp" .. i .. " = 0") end
for k, p in ipairs(POINTS) do
  local one, zero = "temp" .. (2 * k - 2), "temp" .. (2 * k - 1)
  local action = string.format("%s = %s + ((st >> 5) & 1); %s = %s + 1 - ((st >> 5) & 1); ",
    one, one, zero, zero)
  if k >= 3 then action = action .. "temp" .. (k + 5) .. " = st; " end
  gsp.debug:bpset(p[1], "1", action .. "g")
end
dbg.execution_state = "run"

local frame = 0
FIELDEXT_SUB = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame ~= FRAMES then return end
  local start = #dbg.consolelog
  for i = 0, 9 do dbg:command("print temp" .. i) end
  local log = dbg.consolelog
  local v = {}
  for i = start + 1, #log do v[#v + 1] = tostring(log[i]) end
  local f = assert(io.open(OUT .. "fieldext.txt", "w"))
  f:write(string.format("frames %d\n", FRAMES))
  for k, p in ipairs(POINTS) do
    f:write(string.format("%s: FE0=1 %s hits, FE0=0 %s hits", p[2], v[2 * k - 1] or "?",
      v[2 * k] or "?"))
    if k >= 3 then f:write(", last ST " .. (v[k + 6] or "?")) end
    f:write("\n")
  end
  f:close()
  machine:exit()
end)
