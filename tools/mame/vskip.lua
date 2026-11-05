-- MAME autoboot script: which polygon rows does the GSP skip by the V test? (`make vskip`,
-- docs/08 4.2 and section 5)
--
--   VSKIP_OUT=build/mame/vskip-attract.txt VSKIP_TO=1700 VSKIP_PLAY=0 mame stunrun -debug \
--     -debugger none -video none -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 600 \
--     -autoboot_script tools/mame/vskip.lua
--
-- fill_span (FFF454A0) sets B2 = B0 = (y, xl) and B7 = A6 = (y + 1, xr + 1); SUBXY B2,B7
-- (FFF454C0) leaves B7 = (1, xr + 1 - xl) and JRV FFF45500 (FFF454D0) jumps over the FILL and the
-- pattern rotation (RL 4,B9 at FFF454F0) when V is set (xl > xr + 1). A breakpoint at FFF454C0
-- counts every row test (temp1); one at FFF454D0, conditioned on ST bit 28 (V), counts the skips
-- (temp0) and logs the frame (temp9), B2, B7 and B9, the stipple pattern (FFFFFFFF for a solid
-- fill, where a missed rotation changes nothing). The registers are copied to temp2-temp4 in the
-- condition, which MAME evaluates with the GSP's symbols; a breakpoint's action is evaluated with
-- the visible CPU's (the 68k's here), where `b2` is the hex literal B2h. Debugger literals are hex
-- too: ST bit 28 is `st >> 0x1c`. Runs from frame 0 to VSKIP_TO, in attract mode or, with
-- VSKIP_PLAY=1, in a game started as somdump.lua does (coin 900, start 960, trigger 1020); writes
-- one line per skipped row and a summary line (hex counts) to VSKIP_OUT and exits. Registers
-- only, no memory.

local OUT = os.getenv("VSKIP_OUT") or "vskip.txt"
local TO = tonumber(os.getenv("VSKIP_TO") or "1700")
local PLAY = os.getenv("VSKIP_PLAY") == "1"

local machine = manager.machine
local dbg = machine.debugger
assert(dbg, "vskip.lua needs -debug -debugger none")
local gsp = machine.devices[":mainpcb:gsp"]
assert(gsp, "stunrun device :mainpcb:gsp not found")
local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")

for _, v in ipairs({"temp0", "temp1", "temp9"}) do dbg:command(v .. " = 0") end
gsp.debug:bpset(0xfff454c0, "1", "temp1 = temp1 + 1; g")
gsp.debug:bpset(0xfff454d0,
  "((st >> 0x1c) & 1) && ((temp2 = b2) + 1) && ((temp3 = b7) + 1) && ((temp4 = b9) + 1)",
  'temp0 = temp0 + 1; printf "vskip frame=%d B2=%08X B7=%08X B9=%08X",temp9,temp2,temp3,temp4; g')
dbg.execution_state = "run"

local frame = 0
VSKIP_SUB = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  dbg:command(string.format("temp9 = 0x%x", frame))
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  if frame ~= TO then return end
  dbg:command('printf "vskip summary skipped=%X tests=%X (hex)",temp0,temp1')
  local f = assert(io.open(OUT, "w"))
  for _, l in ipairs(dbg.consolelog) do
    local line = tostring(l)
    if line:find("^vskip ") then f:write(line .. "\n") end
  end
  f:close()
  machine:exit()
end)
