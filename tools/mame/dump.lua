-- MAME autoboot script: dump the memory the 68k loads the GSP and ADSP programs into (`make oracle`).
--
--   DUMP_DIR=build/mame/ DUMP_FRAMES=600 mame stunrun -video none -sound none -nothrottle \
--     -autoboot_script tools/mame/dump.lua -autoboot_delay 0 -seconds_to_run 120
--
-- After DUMP_FRAMES frames (default 600) writes into DUMP_DIR (default ./; end it with /):
--   gsp_vram.bin   GSP bit addresses FF800000-FFFFFFFF, 16-bit words little-endian, byte offset
--                  = (bit address - FF800000) / 8: the same layout as build/gsp/vram.bin
--   adsp_pm.bin    ADSP program RAM words 0000-1FFF as 32-bit little-endian (build/adsp/pm.bin)
--   adsp_dm.bin    ADSP data RAM words 0000-1FFF as 16-bit little-endian
--   state.txt      the frame and the 68k, GSP and ADSP program counters
-- then exits MAME. These dumps hold ROM-derived bytes: build output, never committed.
--
-- MAME 0.289 facts (docs/06-code-map.md section 5): the devices are :mainpcb:maincpu,
-- :mainpcb:gsp and :mainpcb:adsp; the GSP program space is addressed in bits (read_u16 every
-- 0x10); the ADSP program space is 32-bit and data space 16-bit, both addressed in words. ADSP
-- data addresses 2000 and up are the board's I/O (/SIMBUF reads advance the object ROM
-- address), so only 0000-1FFF is read. At 120 frames the boot self-test still holds the GSP
-- halted and nothing is loaded; at 600 the GSP idles at FFF41070.

local OUT = os.getenv("DUMP_DIR") or "./"
local FRAMES = tonumber(os.getenv("DUMP_FRAMES") or "600")

local devices = manager.machine.devices
local maincpu = devices[":mainpcb:maincpu"]
local gsp = devices[":mainpcb:gsp"]
local adsp = devices[":mainpcb:adsp"]
assert(maincpu and gsp and adsp, "stunrun devices :mainpcb:maincpu/gsp/adsp not found")

local function write(name, chunks)
  local f = assert(io.open(OUT .. name, "wb"))
  f:write(table.concat(chunks))
  f:close()
end

local function dump(frame)
  local g = gsp.spaces["program"]
  local t = {}
  for a = 0xFF800000, 0xFFFFFFF0, 0x10 do
    t[#t + 1] = string.pack("<I2", g:read_u16(a))
  end
  write("gsp_vram.bin", t)

  local p = adsp.spaces["program"]
  t = {}
  for a = 0, 0x1FFF do
    t[#t + 1] = string.pack("<I4", p:read_u32(a))
  end
  write("adsp_pm.bin", t)

  local d = adsp.spaces["data"]
  t = {}
  for a = 0, 0x1FFF do
    t[#t + 1] = string.pack("<I2", d:read_u16(a))
  end
  write("adsp_dm.bin", t)

  local state = string.format(
    "frame %d\nmaincpu_pc %06X\ngsp_pc %08X\nadsp_pc %04X\n",
    frame, maincpu.state["PC"].value, gsp.state["PC"].value, adsp.state["PC"].value)
  write("state.txt", { state })
  io.write("dump.lua: ", state:gsub("\n", " "), "-> ", OUT, "\n")
end

local frame = 0
-- Kept in a global: a subscription held only by a local is garbage-collected and the callback
-- silently stops.
DUMP_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if frame == FRAMES then
    dump(frame)
    manager.machine:exit()
  end
end)
