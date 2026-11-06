-- MAME autoboot script: what the sequencer of the JSA II 6502 does with each sound command
-- (`make musictrace`; docs/12-sound-music.md).
--
--   MUSIC_DIR=build/mame/ MUSIC_NAME=musictrace MUSIC_SOUNDS=04,0A,... MUSIC_WINDOW=600 \
--     SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 \
--     -seconds_to_run 900 -nvram_directory <empty dir> -cfg_directory <empty dir> \
--     -autoboot_script tools/mame/musictrace.lua
--
-- Stimulus (the accepted kind, issue #15's decision: commands written to the latch as the 68010
-- writes them, a byte write of the high byte at 600000, harddriv.cpp init_multisync installs
-- main_command_w at 600000-603FFF with mask FF00): from frame MUSIC_FROM (1200), one window of
-- MUSIC_WINDOW frames per command of MUSIC_SOUNDS (the commands of type 08): command 00 (the
-- sound initialisation, init_sound through cmdtype_03_immediate: every track stopped), 02 four frames later
-- (min_priority = 0: every priority may key on, docs/09 section 6), the sound command four frames after
-- that. The 68010's own command writes are replaced by 6D, the byte h_nmi queues and
-- dispatch_command ignores (a write tap that returns the changed value), so that only the
-- injected commands reach the sequencer; they are counted as "suppressed". A sound-board reset
-- by the 68010 (a read of 604000, which the script cannot prevent) during a window restarts that
-- window 120 frames later.
--
-- Taps (they read RAM and observe; the only values they change are the 68010's command bytes):
--   * reads of entry_stream (633E-6437) by cmdtype_08_start_sound at 4632: a track started, entry
--     (address - 633E) / 2, for the sound start_sound (stored at 4569);
--   * reads of op_handlers (50AF-5124) by run_op at 506D (the handler's high byte, 50B0 + 2 x
--     (op - 80)) and by call_op_handler at 50A3: an op dispatched;
--   * reads of 65E6-AB47 by read_item at 485B (lda (stream_ptr),y with Y = 0): the address of a
--     stream statement the reader took;
--   * YM2151 writes (2000 register, 2001 data): a write of register 08 with a slot bit (78) is a
--     key-on of channel value & 7, counted for the sound of the track that sounds on that
--     channel (the last track of the list headed at trk_link + 1E + channel, its sound trk_sound).
--     Only the key-ons of a window count, from the sound command to the window's last frame;
--     a window restarted after a reset loses its counts, so the keyon lines are the sums of the
--     windows' counts.
--
-- Output, MUSIC_DIR..MUSIC_NAME..".txt" (addresses, counts, command and sound numbers only):
--   # key value                  header
--   window <cmd> <sound> <key-ons> <frames>   per injected command
--   start <entry> <sound> <count>
--   op <op> <pc> <count>
--   item <address> <count>
--   keyon <sound> <channel> <count>
--   suppressed <cmd> <count>
-- The script writes MUSIC_NAME.."done" before it exits: the make target fails without it (MAME
-- exits 0 when a Lua callback raises).

local OUT = os.getenv("MUSIC_DIR") or "./"
local NAME = os.getenv("MUSIC_NAME") or "musictrace"
local FROM = tonumber(os.getenv("MUSIC_FROM") or "1200")
local WINDOW = tonumber(os.getenv("MUSIC_WINDOW") or "600")
local SOUNDS = {}
for c in string.gmatch(os.getenv("MUSIC_SOUNDS") or "", "[^,]+") do
  SOUNDS[#SOUNDS + 1] = tonumber(c, 16)
end
assert(#SOUNDS > 0, "musictrace.lua: MUSIC_SOUNDS is empty")

local machine = manager.machine
local jsa = assert(machine.devices[":mainpcb:jsa:cpu"], "no :mainpcb:jsa:cpu")
local main = assert(machine.devices[":mainpcb:maincpu"], "no :mainpcb:maincpu")
local prog = jsa.spaces["program"]
local mprog = main.spaces["program"]
local pc = jsa.state["PC"]

local starts, ops, itemreads, keyons, suppressed, windows = {}, {}, {}, {}, {}, {}
local frame = 0
local injecting = false
local k, wstart = 1, FROM
local window_keyons = 0
local window_table = {}
local counting = false
local resets, redone = 0, 0
local ym_reg = 0

local function bump(t, key) t[key] = (t[key] or 0) + 1 end

local function inject(value)
  injecting = true
  mprog:write_u16(0x600000, value << 8)
  injecting = false
end

-- the sound of the track that sounds on YM2151 channel ch: the last of the list at 0860+1E+ch
local function sounding_sound(ch)
  local idx = prog:read_u8(0x0860 + 0x1E + ch)
  local last = nil
  local guard = 0
  while idx ~= 0 and guard < 31 do
    last = idx - 1
    idx = prog:read_u8(0x0860 + last)
    guard = guard + 1
  end
  if last == nil then return nil end
  return prog:read_u8(0x0248 + last)
end

MUSIC_START = prog:install_read_tap(0x633E, 0x6437, "music_start", function(offset, value)
  if pc.value == 0x4632 then
    bump(starts, string.format("start %02X %02X", (offset - 0x633E) // 2, prog:read_u8(0x03)))
  end
  return value
end)

MUSIC_OP = prog:install_read_tap(0x50AF, 0x5124, "music_op", function(offset, value)
  local p = pc.value
  if (p == 0x506D or p == 0x50A3) and (offset - 0x50B0) % 2 == 0 then
    bump(ops, string.format("op %02X %04X", 0x80 + (offset - 0x50B0) // 2, p))
  end
  return value
end)

MUSIC_ITEM = prog:install_read_tap(0x65E6, 0xAB47, "music_item", function(offset, value)
  if pc.value == 0x485B then bump(itemreads, string.format("item %04X", offset)) end
  return value
end)

MUSIC_YM = prog:install_write_tap(0x2000, 0x2001, "music_ym", function(offset, value)
  if offset == 0x2000 then
    ym_reg = value
  elseif ym_reg == 0x08 and (value & 0x78) ~= 0 then
    local ch = value & 7
    local snd = sounding_sound(ch)
    if counting then
      bump(window_table, string.format("keyon %s %d", snd and string.format("%02X", snd) or "--",
        ch))
      window_keyons = window_keyons + 1
    end
  end
  return value
end)

MUSIC_CMD = mprog:install_write_tap(0x600000, 0x603FFF, "music_cmd", function(offset, value, mask)
  if injecting or (mask & 0xFF00) == 0 then return value end
  bump(suppressed, string.format("suppressed %02X", (value >> 8) & 0xFF))
  return (0x6D << 8) | (value & 0x00FF)
end)

local reset_in_window = false
MUSIC_RESET = mprog:install_read_tap(0x604000, 0x607FFF, "music_reset", function(offset, value)
  resets = resets + 1
  if k <= #SOUNDS and frame >= wstart then reset_in_window = true end
  return value
end)

local function dump(f, t)
  local keys = {}
  for key in pairs(t) do keys[#keys + 1] = key end
  table.sort(keys)
  for _, key in ipairs(keys) do f:write(key, " ", t[key], "\n") end
end

MUSIC_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
  frame = frame + 1
  if k <= #SOUNDS then
    if reset_in_window then
      reset_in_window = false
      redone = redone + 1
      wstart = frame + 120
      window_keyons = 0
      window_table = {}
      counting = false
      return
    end
    local at = frame - wstart
    if at == 0 then inject(0x00) end
    if at == 4 then inject(0x02) end
    if at == 8 then
      inject(SOUNDS[k])
      window_keyons = 0
      window_table = {}
      counting = true
    end
    if at == WINDOW - 1 then
      local t = prog:read_u8(0x6100 + SOUNDS[k])
      local n = prog:read_u8(0x616D + SOUNDS[k])
      assert(t == 0x08, "musictrace.lua: command is not of type 08")
      windows[#windows + 1] = string.format("window %02X %02X %d %d", SOUNDS[k], n,
        window_keyons, WINDOW - 8)
      for key, n in pairs(window_table) do keyons[key] = (keyons[key] or 0) + n end
      window_table = {}
      counting = false
      k = k + 1
      wstart = frame + 1
    end
    return
  end
  local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
  f:write(string.format("# frames %d\n# window %d\n# sounds %d\n# resets %d\n# redone %d\n",
    frame, WINDOW, #SOUNDS, resets, redone))
  for _, line in ipairs(windows) do f:write(line, "\n") end
  dump(f, starts)
  dump(f, ops)
  dump(f, itemreads)
  dump(f, keyons)
  dump(f, suppressed)
  f:close()
  local done = assert(io.open(OUT .. NAME .. "done", "w"))
  done:close()
  io.write(string.format("musictrace.lua: %d frames, %d windows, %d resets -> %s%s.txt\n",
    frame, #windows, resets, OUT, NAME))
  machine:exit()
end)
