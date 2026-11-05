-- MAME autoboot script: how sorted is the ADSP's draw-order list? (`make depthkeys`, docs/08 1.5)
--
--   DEPTH_DIR=build/mame/ DEPTH_FROM=1000 DEPTH_TO=3000 DEPTH_PLAY=0 mame stunrun -video none \
--     -sound none -nothrottle -autoboot_delay 0 -seconds_to_run 600 \
--     -autoboot_script tools/mame/depthkeys.lua
--
-- insert_depth_node (07A2) stores the node's 32-bit key (07BD/07BE) and then compares the key
-- minus 10h (07C1-07C5) with the nodes it walks past (07D5/07D6, 07D9/07DC, 07F5/07F8). At every
-- 7th frame from DEPTH_FROM to DEPTH_TO at which the ADSP is idle in wait_frame_trigger (PC
-- 0013-0015, the list complete), this walks the list in PM from the head's next link (PM 123F)
-- to the tail (PM 1242) through the +3 links, reads each node's key (+0 low, +1 high, signed) and
-- counts the adjacent pairs whose second key is larger (a rise), the largest such rise, and the
-- largest rise of a node over any node before it. Writes depthkeys-<DEPTH_PREFIX>.txt into
-- DEPTH_DIR: one line per sampled frame and a summary line, then exits. With DEPTH_PLAY=1 it
-- starts a game as somdump.lua does (coin 900, start 960, trigger 1020). The keys are runtime
-- PM state (the ADSP's own node area), not ROM bytes.

local OUT = os.getenv("DEPTH_DIR") or "./"
local FROM = tonumber(os.getenv("DEPTH_FROM") or "1000")
local TO = tonumber(os.getenv("DEPTH_TO") or "3000")
local PLAY = os.getenv("DEPTH_PLAY") == "1"
local PREFIX = os.getenv("DEPTH_PREFIX") or (PLAY and "game" or "attract")

local machine = manager.machine
local adsp = machine.devices[":mainpcb:adsp"]
assert(adsp, "stunrun device :mainpcb:adsp not found")
local pmspace = adsp.spaces["program"]
local function pm(a) return (pmspace:read_u32(a) >> 8) & 0xFFFF end -- PM words: 24 bits, top
local function s32(lo, hi)
  local v = (hi << 16) | lo
  if v >= 0x80000000 then v = v - 0x100000000 end
  return v
end

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")

local f = assert(io.open(OUT .. "depthkeys-" .. PREFIX .. ".txt", "w"))
local frame = 0
local total = { frames = 0, pairs = 0, rises = 0, max_rise = 0, max_over_any = 0, bad = 0 }

-- Kept in a global: a subscription held only by a local is garbage-collected.
DEPTH_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  if frame > TO then
    f:write(string.format(
      "summary %s frames %d pairs %d rises %d max_rise %X max_rise_over_any_earlier %X unended %d\n",
      PREFIX, total.frames, total.pairs, total.rises, total.max_rise, total.max_over_any,
      total.bad))
    f:close()
    machine:exit()
    return
  end
  if frame < FROM or frame % 7 ~= 0 then return end
  local pc = adsp.state["PC"].value
  if pc < 0x13 or pc > 0x15 then return end
  local node = pm(0x123F)
  local n, rises, max_rise, max_any = 0, 0, 0, 0
  local prev, lowest = nil, nil
  while node ~= 0x1242 and n < 0x800 do
    local k = s32(pm(node), pm(node + 1))
    if prev then
      if k > prev then
        rises = rises + 1
        max_rise = math.max(max_rise, k - prev)
      end
      max_any = math.max(max_any, k - lowest)
    end
    prev = k
    lowest = lowest and math.min(lowest, k) or k
    node = pm(node + 3)
    n = n + 1
  end
  if node ~= 0x1242 then total.bad = total.bad + 1 end
  total.frames = total.frames + 1
  total.pairs = total.pairs + math.max(n - 1, 0)
  total.rises = total.rises + rises
  total.max_rise = math.max(total.max_rise, max_rise)
  total.max_over_any = math.max(total.max_over_any, max_any)
  f:write(string.format("frame %d nodes %d rises %d max_rise %X max_rise_over_any_earlier %X\n",
    frame, n, rises, max_rise, max_any))
end)
