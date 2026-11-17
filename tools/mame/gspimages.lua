-- MAME autoboot script: what the 68010's image unpackers write to the GSP (`make imgtrace`,
-- docs/15-gsp-images.md section 8).
--
--   IMG_DIR=build/mame/ IMG_NAME=imgtrace-attract IMG_FRAMES=6000 IMG_PLAY=0 IMG_LEVEL=0 \
--   IMG_PAL=700,2700 SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle \
--     -autoboot_delay 0 -seconds_to_run 900 -nvram_directory <empty dir> \
--     -cfg_directory <empty dir> -autoboot_script tools/mame/gspimages.lua
--
-- `unpack_gsp_image` (0225E4-02274A) and its resumable twin (022766-022954) read a packed stream
-- from pairs U-W and write the decoded words to HSTDATA (C0000C); both set or restore HSTADR
-- (C00002) around their writes. A "call" is the run of HSTDATA writes from those PCs between two
-- HSTADR writes: for each the script records the frame, the GSP destination (HSTADR at its first
-- word), the first and last stream address the unpacker read (read tap on 060000-0B10EB from
-- those PCs), and the words themselves into <IMG_NAME>.words (build output: they are decoded
-- image data, never committed); one frame later it reads the same GSP words back from the GSP's
-- address space into <IMG_NAME>.vram. Lines "call N frame F dest D words W first A last B pc P"
-- go to <IMG_NAME>.txt, with "entry E frame F pc P" for every read of the image pointer table
-- (0BFE00-0BFF17) and "# key value" header lines. tools/gspimages trace checks them.
--
-- IMG_PAL=f1,f2,... writes MAME's palette (256 entries of 8-bit R, G, B from the palette device,
-- run-time state) into <IMG_NAME>.pal at those frames, a "pal F" line each, for the comparison
-- with data/palettes (build output only).
--
-- IMG_PLAY=1 starts a game as tools/mame/objlevels.lua does (coin at 900, start at 960, the
-- trigger every 20 frames from 1020); IMG_LEVEL=N also applies objlevels.lua's level select (every
-- write of 0 to the level words FF9578/FF9556 becomes N; card A4), which reaches the level maps.

if IMG_DONE then return end

local OUT = os.getenv("IMG_DIR") or "./"
local NAME = os.getenv("IMG_NAME") or "imgtrace"
local FRAMES = tonumber(os.getenv("IMG_FRAMES") or "6000")
local PLAY = os.getenv("IMG_PLAY") == "1"
local LEVEL = tonumber(os.getenv("IMG_LEVEL") or "0")
local PAL = {}
for f in (os.getenv("IMG_PAL") or ""):gmatch("%d+") do PAL[tonumber(f)] = true end

local machine = manager.machine
local cpu = machine.devices[":mainpcb:maincpu"]
local gsp = machine.devices[":mainpcb:gsp"]
local sp = cpu.spaces["program"]
local gp = gsp.spaces["program"]
local pc = cpu.state["PC"]

local log = assert(io.open(OUT .. NAME .. ".txt", "w"))
local wout = assert(io.open(OUT .. NAME .. ".words", "wb"))
local vout = assert(io.open(OUT .. NAME .. ".vram", "wb"))
local pout = nil
log:write(string.format("# frames %d\n# play %d\n# level %d\n", FRAMES, PLAY and 1 or 0, LEVEL))

local frame = 0
local hi, lo = 0, 0
local cur = nil
local pending = {}
local ncalls, nwords, replaced = 0, 0, 0

local function unpacker(p)
  return p >= 0x0225E4 and p < 0x022954
end

local function close()
  if not cur then return end
  ncalls = ncalls + 1
  local data = table.concat(cur.words)
  wout:write(data)
  nwords = nwords + #cur.words
  log:write(string.format("call %d frame %d dest %08X words %d first %06X last %06X pc %06X\n",
    ncalls, cur.frame, cur.dest, #cur.words, cur.first or 0, cur.last or 0, cur.pc))
  pending[#pending + 1] = cur
  cur = nil
end

-- Taps stay referenced from globals: a collected tap is removed.
IMG_HOST_TAP = sp:install_write_tap(0xC00000, 0xC0000F, "img_host", function(offset, data, mask)
  local reg = offset & 0xE
  if reg == 0x2 then
    hi = data; close()
  elseif reg == 0x4 then
    lo = data; close()
  elseif reg == 0xC then
    local p = pc.value
    if unpacker(p) then
      if not cur then
        cur = { dest = (hi << 16) | lo, words = {}, frame = frame, pc = p }
      end
      cur.words[#cur.words + 1] = string.pack(">I2", data & 0xFFFF)
    end
  end
end)

IMG_READ_TAP = sp:install_read_tap(0x060000, 0x0B10EB, "img_read", function(offset, data, mask)
  if cur == nil then
    -- the first command of a call is read before its first HSTDATA write
    if unpacker(pc.value) then
      cur = { dest = (hi << 16) | lo, words = {}, frame = frame, pc = pc.value }
    else
      return
    end
  end
  local a = offset
  if mask == 0x00FF then a = offset + 1 end -- a byte read of the odd byte
  if cur.first == nil then cur.first = a end
  cur.last = a
end)

IMG_TABLE_TAP = sp:install_read_tap(0x0BFE00, 0x0BFF17, "img_table", function(offset, data, mask)
  log:write(string.format("entry %d frame %d pc %06X\n", (offset - 0x0BFE00) // 4, frame, pc.value))
end)

local function level_select(offset, value, mask)
  if LEVEL > 0 and value == 0 then
    replaced = replaced + 1
    return LEVEL
  end
end
IMG_LEVEL_1 = sp:install_write_tap(0xFF9556, 0xFF9557, "img_l1", level_select)
IMG_LEVEL_2 = sp:install_write_tap(0xFF9578, 0xFF9579, "img_l2", level_select)

local function field(port, fname)
  local p = machine.ioport.ports[port]
  return p and p.fields[fname]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(coin and start and trigger, "stunrun input fields not found")

local function palette()
  for _, p in pairs(machine.palettes) do
    if p.entries >= 256 then return p end
  end
end

local function finish(reset_frame)
  if IMG_DONE then return end
  IMG_DONE = true
  close()
  if reset_frame then log:write(string.format("# reset_at_frame %d\n", reset_frame)) end
  log:write(string.format("# calls %d\n# words %d\n# replaced_writes %d\n# done\n", ncalls, nwords,
    replaced))
  log:close(); wout:close(); vout:close()
  if pout then pout:close() end
  io.write(string.format("gspimages.lua: %d frames, %d calls, %d words -> %s%s.txt\n", frame,
    ncalls, nwords, OUT, NAME))
  machine:exit()
end

IMG_FRAME = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  -- read back the GSP words of every call closed before this frame
  if #pending > 0 then
    for _, c in ipairs(pending) do
      local t = {}
      for k = 0, #c.words - 1 do
        t[#t + 1] = string.pack(">I2", gp:read_u16(c.dest + 0x10 * k))
      end
      vout:write(table.concat(t))
    end
    pending = {}
  end
  if PAL[frame] then
    local p = palette()
    if not pout then pout = assert(io.open(OUT .. NAME .. ".pal", "wb")) end
    local t = {}
    for i = 0, 255 do
      local c = p:pen_color(i)
      t[#t + 1] = string.pack("BBB", (c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF)
    end
    pout:write(table.concat(t))
    log:write(string.format("pal %d\n", frame))
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

-- A machine reset ends the run (MAME would run this script again; objlevels.lua does the same).
IMG_RESET = emu.add_machine_reset_notifier(function() finish(frame) end)
