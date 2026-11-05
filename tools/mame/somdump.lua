-- MAME autoboot script: capture the SOM display list on its way from the ADSP to the GSP
-- (`make somdump`, docs/08-display-list.md).
--
--   SOM_DIR=build/mame/som/ SOM_FRAMES=700,2400 SOM_PLAY=1 mame stunrun -video none -sound none \
--     -nothrottle -autoboot_delay 0 -seconds_to_run 600 -autoboot_script tools/mame/somdump.lua
--
-- How it sees the SOM buffer. MAME keeps the two 8K-word SOM banks in a plain array that Lua cannot
-- reach (m_som_memory, harddriv.h:386), and the 68k sees only one bank at 810000 (hd68k_adsp_buffer_r,
-- harddriv_m.cpp:614). So the script rebuilds both banks from the ADSP's own writes: a write tap on
-- ADSP data 2002-2003 follows /SOMCLK (the SOM address) and SOMLATCH (a word into bank
-- m68k_bank ^ 1 at the address, which then advances; hdadsp_special_w, harddriv_m.cpp:803), and a
-- write tap on the 68k's ADSP control latch 818000-81801F follows line 3, the 68k's bank
-- (hd68k_adsp_control_w, harddriv_m.cpp:685). For every word it also keeps the address of the
-- writing instruction (CURPC, the state MAME's debugger shows as the current instruction; "PC"
-- is already past it). Every event below names its instruction the same way. When the 68k starts the copy
-- into the GSP (the word 7000 to HSTDATA, 0x02F0BA) it also reads 810000-813FFF through the 68k's
-- own window, which the decoder test compares with the rebuilt bank.
--
-- For each frame number in SOM_FRAMES (comma-separated; default 700,2400) it waits until the GSP
-- has finished a command buffer that holds a copied SOM list (the GSP clears the buffer's flag
-- word, FFF41890) and writes into SOM_DIR/f<frame>/:
--   cmdbuf.bin    the GSP command buffer from flag + 10h for 0x2FF0 words (16-bit little-endian):
--                 the header block process_command_buffer (FFF411A0) skips by the word at
--                 FFF77F50 (meta.txt "FFF77F50", in bits), then the commands it read
--   som.bin       the SOM bank the 68k copied into that buffer, rebuilt (0x2000 words, 16-bit LE)
--   som_pc.bin    for each SOM word, the address of the ADSP instruction whose SOMLATCH write
--                 stored it (FFFF: none)
--   som68k.bin    810000-813FFF read through the 68k at the copy (0x2000 words): the same bank
--   som_other.bin the other bank as rebuilt at the same moment (the ADSP is filling it)
--   adsp_dm.bin   ADSP data RAM 0000-1FFF at the ADSP's end-of-frame /GINT (00C1) of that list
--   fb.bin        VRAM bytes 000000-03BFFF: the two 512 x 240 frame buffers, 8 bits per pixel
--   colors.bin    GSP FFF71D20-FFF75D20: the 0x400 colour words the polygon fill indexes
--   fb_som.bin    the page being drawn when the GSP has just finished the SOM command (its first
--                 read past the list, a read tap; 512 x 240 bytes)
--   fb_pre.bin    the same page when the GSP reads the 7000 (before the list; 512 x 240 bytes)
--   images.bin    the image table FFF78150 and its images at the same moment (ROM-derived)
--   palette.bin   the pens of :mainpcb:palette as 32-bit little-endian xRGB
--   meta.txt      frame, buffer, B4 (frame-buffer offset), the protocol events of the frame
--   snap_<n>.png  screen snapshots 1 and 2 frames after the capture (in MAME's snapshot dir,
--                 renamed here: MAME writes them under -snapshot_directory)
-- With SOM_PLAY=1 it inserts a coin at frame 900, presses start at 960 and the trigger at 1020
-- (pcwatch.lua). With SOM_DITHER=1 it rewrites, every frame, each colour word at FFF71D20 (the
-- table the SOM polygons index, GSP FFF452D0) as lo | (lo ^ 80h) << 8: the game's own table has
-- equal bytes in every word, and this makes the expander's even/odd byte rule visible in the
-- page (docs/08 section 4.3). The GSP only reads the table, so the game runs as without it. It
-- exits after the last capture, writing SOM_DIR/<SOM_PREFIX>done first. The SOM banks, ADSP data RAM, the colour table and the GSP
-- buffer are runtime RAM state; images.bin is ROM-derived, and fb*.bin and the snapshots hold
-- pages those images were drawn into. All of it stays under build/: only the bare SOM list (a
-- .som, through tools/displaylist.py --export) is ever committed.

local OUT = os.getenv("SOM_DIR") or "./"
local PLAY = os.getenv("SOM_PLAY") == "1"
local SNAPDIR = os.getenv("SOM_SNAPDIR")
local PREFIX = os.getenv("SOM_PREFIX") or "f"
local DITHER = os.getenv("SOM_DITHER") == "1"
local FRAMES = {}
for n in string.gmatch(os.getenv("SOM_FRAMES") or "700,2400", "%d+") do
  FRAMES[#FRAMES + 1] = tonumber(n)
end
table.sort(FRAMES)

local machine = manager.machine
local maincpu = machine.devices[":mainpcb:maincpu"]
local gsp = machine.devices[":mainpcb:gsp"]
local adsp = machine.devices[":mainpcb:adsp"]
assert(maincpu and gsp and adsp, "stunrun devices :mainpcb:maincpu/gsp/adsp not found")
local m68 = maincpu.spaces["program"]
local gs = gsp.spaces["program"]
local dm = adsp.spaces["data"]

local frame = 0
local next_capture = 1
local events = {}
local function ev(s)
  local f = FRAMES[next_capture]
  if f and frame >= f - 1 then
    events[#events + 1] = string.format("%6d %.7f %s", frame, machine.time:as_double(), s)
  end
end

-- the two SOM banks, rebuilt
local som = { [0] = {}, [1] = {} }
local sompc = { [0] = {}, [1] = {} }
for b = 0, 1 do
  for a = 0, 0x1FFF do som[b][a] = 0; sompc[b][a] = 0xFFFF end
end
local bank68 = 0 -- the bank the 68k sees; the ADSP writes the other
local somaddr = 0
local last_dm = nil -- ADSP data RAM at the last end-of-frame /GINT
local frame_dm = nil

local function copy_bank(b)
  local t, p = {}, {}
  for a = 0, 0x1FFF do t[a] = som[b][a]; p[a] = sompc[b][a] end
  return t, p
end

local function read_dm()
  local t = {}
  for a = 0, 0x1FFF do t[a] = dm:read_u16(a) end
  return t
end

local function pack16(t, n)
  local c = {}
  for a = 0, n - 1 do c[#c + 1] = string.pack("<I2", t[a] or 0) end
  return table.concat(c)
end

local function write(dir, name, data)
  local f = assert(io.open(dir .. name, "wb"))
  f:write(data)
  f:close()
end

TAPS = {}
-- 68k: the ADSP control latch (line 3 = the 68k's SOM bank), the frame trigger and handshake
TAPS[#TAPS + 1] = m68:install_write_tap(0x818000, 0x81801F, "som_ctl", function(off, data, mask)
  local w = (off - 0x818000) // 2
  local line, val = w & 7, (w >> 3) & 1
  if line == 3 then
    bank68 = val
    ev(string.format("68k %06X: ADSP control line 3 = %d (68k sees bank %d)", maincpu.state["CURPC"].value, val, val))
  elseif line == 5 then
    ev(string.format("68k %06X: ADSP /BR = %d", maincpu.state["CURPC"].value, val))
  end
end)
TAPS[#TAPS + 1] = m68:install_write_tap(0x80BFC6, 0x80BFC7, "som_1fe3", function(off, data, mask)
  ev(string.format("68k %06X: DM 1FE3 = %04X (handshake)", maincpu.state["CURPC"].value, data))
end)
TAPS[#TAPS + 1] = m68:install_write_tap(0x80BFFE, 0x80BFFF, "som_1fff", function(off, data, mask)
  ev(string.format("68k %06X: DM 1FFF = %04X (frame trigger)", maincpu.state["CURPC"].value, data))
end)

-- 68k: the copy into the GSP. Per buffer: which list went in.
local hostadr = 0 -- HSTADRH:HSTADRL as the 68k last wrote them
local hostptr = 0 -- where the next HSTDATA word lands (HSTCTL INCW: +10h bits per write)
local copies = {} -- GSP buffer flag address -> { som, pc, som68k, other, dm, bank, after }
local building = nil
local fb_page -- forward: the frame buffer page reader, defined below
TAPS[#TAPS + 1] = m68:install_write_tap(0xC00000, 0xC0000F, "som_host", function(off, data, mask)
  if off == 0xC00008 then
    ev(string.format("68k %06X: HSTCTL = %04X%s", maincpu.state["CURPC"].value, data,
      (data & 0x80) == 0 and " (INTOUT cleared)" or ""))
  elseif off == 0xC00002 then
    hostadr = (data << 16) | (hostadr & 0xFFFF)
    hostptr = hostadr
  elseif off == 0xC00004 then
    hostadr = (hostadr & 0xFFFF0000) | data
    hostptr = hostadr
    if hostadr == 0xFFF9FC10 or hostadr == 0xFFFCFC10 then
      building = hostadr - 0x10
      ev(string.format("68k %06X: host address %08X, start of a command list", maincpu.state["CURPC"].value, hostadr))
    end
  elseif off == 0xC0000C or off == 0xC0000E then
    -- a long write (move.l to C0000C) is two word writes, C0000C then C0000E, both HSTDATA
    local at = hostptr
    hostptr = hostptr + 0x10
    -- 0x02F0BA `move.w #$7000,$c0000c` in 0x02F0AE, the SOM copy
    if off == 0xC0000C and data == 0x7000 and maincpu.state["CURPC"].value == 0x02F0BA then
      local f = FRAMES[next_capture]
      ev(string.format("68k %06X: HSTDATA 7000 at %08X, SOM copy from bank %d (%d words)",
        maincpu.state["CURPC"].value, at, bank68, som[bank68][0]))
      if f and frame >= f - 1 and building then
        local t, p = copy_bank(bank68)
        local v = {}
        for a = 0, 0x1FFF do v[a] = m68:read_u16(0x810000 + 2 * a) end
        local o = copy_bank(bank68 ~ 1)
        -- the GSP's first read past the copied list (words 1..N follow 7000) means the SOM
        -- command (7) has returned to the dispatcher: the polygons are drawn, nothing else yet
        local after = at + 0x10 * (1 + t[0])
        if copies[building] and copies[building].tap then
          copies[building].tap:remove()
          copies[building].pretap:remove()
        end
        copies[building] = { som = t, pc = p, som68k = v, other = o, dm = frame_dm,
          bank = bank68, after = after }
        local c = copies[building]
        -- and its read of the 7000 itself: the page before the list (FFF46F90)
        c.pretap = gs:install_read_tap(at, at + 0xF, "som_before", function(o2, d2, m2)
          if not c.fb_pre then c.fb_pre = fb_page() end
        end)
        c.tap = gs:install_read_tap(after, after + 0xF, "som_after", function(o2, d2, m2)
          if not c.fb_som then
            c.fb_som = fb_page()
            c.fb_som_pc = gsp.state["CURPC"].value
            c.fb_som_b4 = gsp.state["B4"].value
            c.colors = {}
            for i = 0, 0x3FF do c.colors[i] = gs:read_u16(0xFFF71D20 + 16 * i) end
            c.images = read_images()
          end
        end)
      end
    end
  end
end)

-- ADSP: SOMCLK, SOMLATCH, /GINT
TAPS[#TAPS + 1] = dm:install_write_tap(0x2002, 0x2006, "som_adsp", function(off, data, mask)
  local pc = adsp.state["CURPC"].value
  if off == 0x2003 then
    somaddr = data
    ev(string.format("ADSP %04X: /SOMCLK = %04X (writes go to bank %d)", pc, data, bank68 ~ 1))
  elseif off == 0x2002 then
    local b, a = bank68 ~ 1, somaddr & 0x1FFF
    som[b][a] = data
    sompc[b][a] = pc
    somaddr = somaddr + 1
  elseif off == 0x2006 then
    local h = dm:read_u16(0x1FE3)
    ev(string.format("ADSP %04X: /GINT, DM 1FE3 = %04X, SOM address %04X", pc, h, somaddr))
    if h == 0 then
      local f = FRAMES[next_capture]
      if f and frame >= f - 2 then frame_dm = read_dm() end
    end
  end
end)

-- The frame buffer page the GSP draws into: process_command_buffer's callee FFF46E30 subtracts
-- A000h (40 rows of 400h bits) from B4 (FFF46E70), so a page starts at B4 + A000h in the 2 bpp
-- window at 02000000, whose pixel n is VRAM byte n (hdgsp_vram_2bpp_w, harddriv_v.cpp:300).
fb_page = function()
  local b4 = gsp.state["B4"].value
  local base = ((b4 + 0xA000) & 0xFFFFFFFF) - 0x2000000
  base = base // 2
  local t = {}
  for a = base, base + 512 * 240 - 2, 2 do
    t[#t + 1] = string.pack("<I2", gs:read_u16(0xFF800000 + a * 8))
  end
  return { base = base, data = table.concat(t) }
end

-- The image table FFF78150 (64 longs, loaded by GSP command E0, FFF4A6F0) and the images it
-- points at, as the image quad (FFF48FC0) reads them: height (FFF49690), width (FFF496A0), then
-- 8-bit pixels from 60h bits after the image's address (FFF49840), row after row.
-- images.bin: per entry a 32-bit address, and when it is not 0 the 16-bit height and width and
-- height * width pixel bytes. ROM-derived (the 68k unpacks them from pairs U-V): build/ only.
function read_images()
  local t = {}
  for i = 0, 63 do
    local ptr = gs:read_u32(0xFFF78150 + 32 * i)
    t[#t + 1] = string.pack("<I4", ptr)
    if ptr ~= 0 then
      local h, w = gs:read_u16(ptr), gs:read_u16(ptr + 16)
      if h * w > 0x40000 then h, w = 0, 0 end
      t[#t + 1] = string.pack("<I2I2", h, w)
      local px = {}
      for k = 0, h * w - 1 do px[#px + 1] = string.char(gs:read_u8(ptr + 0x60 + 8 * k)) end
      t[#t + 1] = table.concat(px)
    end
  end
  return table.concat(t)
end

local snaps = {}
local function capture(flag, c)
  local f = FRAMES[next_capture]
  local dir = OUT .. PREFIX .. f .. "/"
  os.execute("mkdir -p '" .. dir .. "'")
  -- process_command_buffer adds the 16-bit word at FFF77F50 (field 0: 16 bits, zero-extended,
  -- SETF at FFF41010) to the list address as a bit offset (FFF411D0-FFF41200)
  local off = gs:read_u16(0xFFF77F50)
  local start = flag + 0x10 + off
  local w = {}
  for i = 0, 0x2FEF do w[i] = gs:read_u16(flag + 0x10 + 16 * i) end
  write(dir, "cmdbuf.bin", pack16(w, 0x2FF0))
  write(dir, "som.bin", pack16(c.som, 0x2000))
  write(dir, "som_pc.bin", pack16(c.pc, 0x2000))
  write(dir, "som68k.bin", pack16(c.som68k, 0x2000))
  write(dir, "som_other.bin", pack16(c.other, 0x2000))
  if c.dm then write(dir, "adsp_dm.bin", pack16(c.dm, 0x2000)) end
  if c.tap then c.tap:remove(); c.pretap:remove() end
  if c.fb_pre then write(dir, "fb_pre.bin", c.fb_pre.data) end
  if c.fb_som then write(dir, "fb_som.bin", c.fb_som.data) end
  if c.images then write(dir, "images.bin", c.images) end
  local fb = {}
  for a = 0, 0x3BFFF, 2 do fb[#fb + 1] = string.pack("<I2", gs:read_u16(0xFF800000 + a * 8)) end
  write(dir, "fb.bin", table.concat(fb))
  local col = c.colors
  if not col then
    col = {}
    for i = 0, 0x3FF do col[i] = gs:read_u16(0xFFF71D20 + 16 * i) end
  end
  write(dir, "colors.bin", pack16(col, 0x400))
  local pal = machine.palettes[":mainpcb:palette"]
  local p = {}
  for i = 0, pal.entries - 1 do p[#p + 1] = string.pack("<I4", pal:pen_color(i)) end
  write(dir, "palette.bin", table.concat(p))
  local meta = {
    string.format("frame %d", frame),
    string.format("capture %d", f),
    string.format("buffer %08X", flag),
    string.format("list %08X", start),
    string.format("FFF77F50 %04X", off),
    string.format("B4 %08X", gsp.state["B4"].value),
    string.format("FFF71660 %08X", gs:read_u32(0xFFF71660)),
    string.format("FFF77E60 %04X", gs:read_u16(0xFFF77E60)),
    string.format("bank %d", c.bank),
    string.format("after %08X", c.after),
    string.format("fb_som_page %05X", c.fb_som and c.fb_som.base or 0xFFFFF),
    string.format("fb_som_pc %08X", c.fb_som_pc or 0),
    string.format("palette_entries %d", pal.entries),
    "events:",
  }
  write(dir, "meta.txt", table.concat(meta, "\n") .. "\n" .. table.concat(events, "\n") .. "\n")
  io.write(string.format("somdump.lua: frame %d buffer %08X -> %s\n", frame, flag, dir))
  -- a copy into the other buffer belongs to this capture window: drop it, or the next capture
  -- would pair it with a later buffer
  for k, other in pairs(copies) do
    if other.tap then other.tap:remove(); other.pretap:remove() end
    copies[k] = nil
  end
  snaps[#snaps + 1] = { at = frame + 1, dir = dir, n = 1 }
  snaps[#snaps + 1] = { at = frame + 2, dir = dir, n = 2 }
  events = {}
  next_capture = next_capture + 1
end

-- GSP: HSTCTLL, where command_buffer_done sets INTOUT (FFF41910), the 68k's level-3 interrupt
TAPS[#TAPS + 1] = gs:install_write_tap(0xC00000F0, 0xC00000FF, "som_intout", function(off, data, mask)
  if (data & 0x80) ~= 0 then
    ev(string.format("GSP %08X: HSTCTLL = %04X (INTOUT set)", gsp.state["CURPC"].value, data))
  end
end)

-- GSP: the flag words. The 68k writes FFFF (ready), the GSP writes 0 at FFF418A0 (done).
for _, flag in ipairs({ 0xFFF9FC00, 0xFFFCFC00 }) do
  TAPS[#TAPS + 1] = gs:install_write_tap(flag, flag + 0xF, "som_flag", function(off, data, mask)
    if data == 0 then
      ev(string.format("GSP %08X: flag %08X = 0, buffer done", gsp.state["CURPC"].value, flag))
      local f = FRAMES[next_capture]
      local c = copies[flag]
      if f and frame >= f and c then
        copies[flag] = nil
        capture(flag, c)
      end
    else
      ev(string.format("68k %06X: flag %08X = %04X, buffer ready", maincpu.state["CURPC"].value, flag, data))
    end
  end)
end

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")

-- Kept in a global: a subscription held only by a local is garbage-collected.
SOM_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  ev("frame")
  if DITHER then
    for i = 0, 0x3FF do
      local lo = gs:read_u16(0xFFF71D20 + 16 * i) & 0xFF
      gs:write_u16(0xFFF71D20 + 16 * i, lo | ((lo ~ 0x80) << 8))
    end
  end
  if PLAY then
    if frame == 900 then coin:set_value(1) elseif frame == 905 then coin:clear_value() end
    if frame == 960 then start:set_value(1) elseif frame == 965 then start:clear_value() end
    if frame == 1020 then trigger:set_value(1) elseif frame == 1025 then trigger:clear_value() end
  end
  local keep = {}
  for _, s in ipairs(snaps) do
    if frame == s.at then
      machine.video:snapshot()
      if SNAPDIR then
        -- MAME names snapshots stunrun/NNNN.png under the snapshot directory: move the newest
        os.execute(string.format("f=$(ls -t '%sstunrun/'*.png 2>/dev/null | head -1); [ -n \"$f\" ] && mv \"$f\" '%ssnap_%d.png'", SNAPDIR, s.dir, s.n))
      end
    else
      keep[#keep + 1] = s
    end
  end
  snaps = keep
  if next_capture > #FRAMES and #snaps == 0 then
    -- the done marker `make somdump` requires: MAME exits 0 even when a callback raised, so
    -- only this file says that every frame was captured
    write(OUT, PREFIX .. "done", string.format("%d captures, frame %d\n", #FRAMES, frame))
    machine:exit()
  end
end)
