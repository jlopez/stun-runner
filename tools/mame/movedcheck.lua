-- MAME autoboot script: what the 68010 sends out, frame by frame (`make movedcheck`, M5d,
-- docs/17-68k-data.md section 5).
--
--   MOVED_DIR=build/mame/ MOVED_NAME=moved-ref-attract MOVED_FRAMES=3600 MOVED_PLAY=0 \
--   SDL_VIDEODRIVER=dummy mame stunrun -rompath <set> -video none -sound none -nothrottle \
--     -autoboot_delay 0 -seconds_to_run 900 -nvram_directory <empty dir> \
--     -cfg_directory <empty dir> -autoboot_script tools/mame/movedcheck.lua
--
-- Write taps on the 68010's program space: the GSP host port (C00000-C0000F), the ADSP
-- (800000-83FFFF: program and data RAM, the SOM buffer, the control and interrupt latches) and
-- the sound latch (600000-603FFF). Per frame one line "f N gsp C H adsp C H snd C H": for each
-- stream the count of writes and a 32-bit FNV-1a hash of their (offset, data, mask) in order. The
-- same run of the reference set and of the moved build (tools/m68k moved) gives equal lines until
-- the moved program does something else; `tools/m68k moved-compare` reports the first frame per
-- stream. MOVED_DETAIL=F1-F2 also writes every write of frames F1-F2 with the 68010's PC to
-- <MOVED_NAME>.detail (build output: the values are run-time data), and with it the writes to
-- the level object list cursors FFDC6C-FFDC73 as "cur" lines. Nothing of the ROM is
-- recorded. MOVED_PLAY=1 starts a game (coin at 900, start at 960, the trigger every 20 frames
-- from 1020, as tools/mame/gspimages.lua). A machine reset ends the run ("# reset_at_frame").
-- A read tap on the game's bus and address error vectors (020008-02000F, VBR 020000 from the
-- movec at 000294) writes one "# exception" line at the first fetch of each: the frame, the
-- vector, the stacked PC and SR, A0-A2 and A7, and the level object list cursors FFDC6C and
-- FFDC70 (sub_3186A, docs/17 section 5): run-time register and RAM values.

if MOVED_DONE then return end

local OUT = os.getenv("MOVED_DIR") or "./"
local NAME = os.getenv("MOVED_NAME") or "moved"
local FRAMES = tonumber(os.getenv("MOVED_FRAMES") or "3600")
local PLAY = os.getenv("MOVED_PLAY") == "1"
local d1, d2 = (os.getenv("MOVED_DETAIL") or ""):match("^(%d+)-(%d+)$")
d1, d2 = tonumber(d1 or "-1"), tonumber(d2 or "-2")

local machine = manager.machine
local cpu = machine.devices[":mainpcb:maincpu"]
local sp = cpu.spaces["program"]
local pc = cpu.state["PC"]

local log = assert(io.open(OUT .. NAME .. ".txt", "w"))
local detail = nil
if d1 >= 0 then detail = assert(io.open(OUT .. NAME .. ".detail", "w")) end
log:write(string.format("# frames %d\n# play %d\n", FRAMES, PLAY and 1 or 0))

local frame = 0
local count = { gsp = 0, adsp = 0, snd = 0 }
local hash = { gsp = 0x811C9DC5, adsp = 0x811C9DC5, snd = 0x811C9DC5 }

local function mix(h, v)
  for _ = 1, 4 do
    h = ((h ~ (v & 0xFF)) * 16777619) & 0xFFFFFFFF
    v = v >> 8
  end
  return h
end

local function tap(stream)
  return function(offset, data, mask)
    count[stream] = count[stream] + 1
    local h = mix(hash[stream], offset)
    h = mix(h, data)
    hash[stream] = mix(h, mask)
    -- the writes before the notifier of frame N are line "f N"
    local f = frame + 1
    if detail and f >= d1 and f <= d2 then
      detail:write(string.format("%d %s pc %06X %06X %04X %04X\n", f, stream, pc.value,
        offset, data & 0xFFFF, mask & 0xFFFF))
    end
  end
end

-- Taps stay referenced from globals: a collected tap is removed.
local seen = {}
MOVED_FAULT = sp:install_read_tap(0x020008, 0x02000F, "moved_fault", function(offset, data, mask)
  local v = (offset - 0x020000) >> 2
  if seen[v] then return end
  seen[v] = true
  local function r(n) return cpu.state[n].value end
  local a7 = r("A7")
  log:write(string.format("# exception frame %d vector %d stacked_pc %06X stacked_sr %04X "
    .. "a0 %08X a1 %08X a2 %08X a7 %08X FFDC6C %08X FFDC70 %08X\n", frame + 1, v,
    sp:read_u32(a7 + 2) & 0xFFFFFF, sp:read_u16(a7), r("A0"), r("A1"), r("A2"), a7,
    sp:read_u32(0xFFDC6C), sp:read_u32(0xFFDC70)))
end)
MOVED_GSP = sp:install_write_tap(0xC00000, 0xC0000F, "moved_gsp", tap("gsp"))
MOVED_ADSP = sp:install_write_tap(0x800000, 0x83FFFF, "moved_adsp", tap("adsp"))
MOVED_SND = sp:install_write_tap(0x600000, 0x603FFF, "moved_snd", tap("snd"))
-- With MOVED_DETAIL, the writes to the two level object list cursors FFDC6C-FFDC73 (sub_3186A)
-- of frames F1-F2 too, as "cur" lines with the PC after the writing instruction (review of #38:
-- which instruction set FFDC70 before the moved build's address error). Not hashed.
if detail then
  MOVED_CUR = sp:install_write_tap(0xFFDC6C, 0xFFDC73, "moved_cur", function(offset, data, mask)
    local f = frame + 1
    if f >= d1 and f <= d2 then
      detail:write(string.format("%d cur pc %06X %06X %04X %04X\n", f, pc.value, offset,
        data & 0xFFFF, mask & 0xFFFF))
    end
  end)
end

local function field(port, fname)
  local p = machine.ioport.ports[port]
  return p and p.fields[fname]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(coin and start and trigger, "stunrun input fields not found")

local function finish(reset_frame)
  if MOVED_DONE then return end
  MOVED_DONE = true
  if reset_frame then log:write(string.format("# reset_at_frame %d\n", reset_frame)) end
  log:write("# done\n")
  log:close()
  if detail then detail:close() end
  io.write(string.format("movedcheck.lua: %d frames -> %s%s.txt\n", frame, OUT, NAME))
  machine:exit()
end

MOVED_FRAME = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  log:write(string.format("f %d gsp %d %08X adsp %d %08X snd %d %08X\n", frame,
    count.gsp, hash.gsp, count.adsp, hash.adsp, count.snd, hash.snd))
  for _, s in ipairs({ "gsp", "adsp", "snd" }) do
    count[s] = 0
    hash[s] = 0x811C9DC5
  end
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame >= 1020 then
      if frame % 20 == 0 then trigger:set_value(1) elseif frame % 20 == 5 then trigger:clear_value() end
    end
  end
  if frame == FRAMES then finish(nil) end
end)

MOVED_RESET = emu.add_machine_reset_notifier(function() finish(frame) end)
