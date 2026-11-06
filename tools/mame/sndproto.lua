-- MAME autoboot script: the sound command protocol between the 68010 and the JSA II's 6502
-- (`make sndproto`, docs/11-sound-protocol.md).
--
--   PROTO_DIR=build/mame/ PROTO_NAME=sndproto-game PROTO_FRAMES=10800 PROTO_PLAY=1 \
--     SDL_VIDEODRIVER=dummy mame stunrun -video none -sound none -nothrottle -autoboot_delay 0 \
--     -seconds_to_run 900 -nvram_directory <empty dir> -cfg_directory <empty dir> \
--     -autoboot_script tools/mame/sndproto.lua
--
-- Both ends of the latch pair (atariscom.cpp): the 68010 writes the command byte at 600000 (the
-- high byte; harddriv.cpp init_multisync installs main_command_w and main_response_r at
-- 600000-603FFF with mask FF00), reads the response there, and resets the sound board with a
-- read of 604000-607FFF (hd68k_sound_reset_r); the 6502 reads the command at 2802 and writes the
-- response at 2A02 (atarijsa2_map, mirror 01F9). The script taps:
--   * 68010 writes of 600000 (the byte, the instruction, and the call of the send routine when
--     the write is 023EF6's or 023EC0's, from the return address at A7: they run without a
--     frame; "-" for the boot program's own writes),
--   * 68010 reads of 600000 (responses taken) and of 604000-607FFF (sound resets), with CURPC
--     and, for the game's reset (023FA8), the call of reset_sound,
--   * 68010 byte writes into the game's command queue FFDB64-FFDBC3 (written only at 030212 in
--     queue_sound_command, 0301CA): the command and the call instruction, found from the return
--     address at 4(A6) (queue_sound_command runs under link A6), as the word before it says:
--     `jsr abs.l` (4EB9, 6 bytes back) or `jsr (A2)` (4E92, 2 bytes back),
--   * 68010 writes of FFDB5C-FFDB63 (the sound watchdog's counters) with CURPC: only
--     reset_sound (0300F8) writes them unless the watchdog routine at 03001E runs,
--   * 6502 reads of 2802 (commands taken; the NMI is held until then), writes of 2A02
--     (responses, with the 6502 PC), reads of the type table 6100-616C at 4375 (the dispatch of a
--     queued command), of cmd_class 6093-60FF (h_nmi's lookup of every command byte below 6D)
--     and its writes into its command queue 0200-022F (6D first, then the byte if it is queued),
--     and its YM2151 register selects of 10-14 (timer A, timer B, timer control: written only by
--     ymtimer.asm, which only command type 10 enters; the timer A interrupt is what h_irq runs it
--     from, 41C5-41D1).
-- A command the 6502 never takes is a lost one (atariscom.cpp delayed_sound_write logs "Missed
-- command from 680x0" and overwrites the latch): the counts of writes, of reads of 2802 and of
-- dispatches and class lookups tell. Times between the two CPUs are not measured: a tap sees each
-- CPU at its own place in MAME's timeslice, so they would not mean anything at this scale.
--
-- PROTO_PLAY=1: a coin at frame 900, start at 960, the trigger every 20 frames from 1020 (as
-- okitrace.lua). PROTO_MENU=selftest or soundtest holds the self-test switch (IN0 bit 5,
-- "Service Mode") from the start (the game program still starts first and queues 1E; the 68010
-- restarts through boot_reset at frame 445), so the boot program runs its test menus, and drives them with
-- the buttons (MENU_STEPS below; button 1 moves the cursor up, button 2 down, start selects): the
-- boot program's "SA SELF TEST" (008D94: reset, FF, command 07 and its status byte, then 04, 00,
-- 05, 00), or "PLAY SOUNDS", the game's audio test (043718), where every entry of its list is
-- played in turn (button 2 sends the entry's command, 04395C) and the stick moves the cursor down
-- one entry (sending 34, 04392C). PROTO_INJECT="frame:byte,...": at each frame the byte is written to
-- the sound latch as the 68010 writes it (an accepted test stimulus, decision of 2026-11-05 in
-- issue #15).
-- Output, <PROTO_NAME>.txt in PROTO_DIR: "# key value" header lines, then aggregated lines
--   queue <command> <call instruction> <count> <first frame>
--   send <command> <write pc> <call instruction or -> <count> <first frame>
--   inject <command> <count> <first frame>
--   response <value> <6502 pc> <count> <first frame>
--   taken <6502 pc> <count>
--   resp_read <68k pc> <count>
--   reset <68k pc> <call of reset_sound or -> <count> <frames...>
--   watchdog_write <68k pc> <count>
--   dispatch <command> <count>
--   class_lookup <command> <count>
--   jsa_queue <value> <6502 pc> <count>
--   ym_timer_reg <register> <6502 pc> <count>
--   boot <event>  (the first 40 protocol events in order: S reset, C command, R response, T taken)
-- Values are command and response bytes (protocol values, runtime state) and addresses; nothing
-- read from a ROM is recorded. The script writes <PROTO_NAME>done just before it exits: MAME exits
-- 0 when a Lua callback raises, so the make target checks the marker.

local OUT = os.getenv("PROTO_DIR") or "./"
local NAME = os.getenv("PROTO_NAME") or "sndproto"
local FRAMES = tonumber(os.getenv("PROTO_FRAMES") or "3600")
local PLAY = os.getenv("PROTO_PLAY") == "1"
local INJECT = {}
for c in string.gmatch(os.getenv("PROTO_INJECT") or "", "[^,]+") do
  local fr, byte = c:match("^(%d+):(%x%x)$")
  assert(fr, "sndproto.lua: bad PROTO_INJECT entry " .. c)
  INJECT[tonumber(fr)] = tonumber(byte, 16)
end
local MENU = os.getenv("PROTO_MENU") or ""
local SERVICE = MENU ~= ""
-- Input steps {frame, port, field, value}: value 1 presses (or for the stick sets its position),
-- 0 releases. The frames were found by running the menus with snapshots (docs/11 section 5).
local A80000, STICK_Y = ":mainpcb:a80000", ":mainpcb:8BADC.2"
local B1, B2, START, SY = "P1 Button 1", "P1 Button 2", "1 Player Start", "AD Stick Y"
local ACTIONS = {}
local function press(fr, fld, port, value, hold)
  ACTIONS[#ACTIONS + 1] = { fr, port or A80000, fld, value or 1 }
  ACTIONS[#ACTIONS + 1] = { fr + (hold or 10), port or A80000, fld, 0 }
end
local SOUNDTEST_FROM, SOUNDTEST_EVERY, SOUNDTEST_ENTRIES = 1900, 40, 108
if SERVICE then
  press(500, START, nil, 1, 600)  -- "PRESS START TO BYPASS SELFTEST", then the TEST MENU
  press(1200, B1)                 -- up from OPERATOR SCREENS to SPECIAL FUNCTIONS
  press(1300, START)
  press(1400, B1)                 -- up from EXIT to SOUND BOARD TESTS
  press(1450, START)              -- SA AUDIO TEST MENU: EXIT, SA SELF TEST, PLAY SOUNDS
  if MENU == "selftest" then
    press(1600, B2)               -- down to SA SELF TEST
    press(1650, START)
  elseif MENU == "soundtest" then
    press(1600, B1)               -- up to PLAY SOUNDS
    press(1650, START)
    for i = 0, SOUNDTEST_ENTRIES - 1 do
      local fr = SOUNDTEST_FROM + SOUNDTEST_EVERY * i
      press(fr, B2, nil, 1, 5)              -- play the entry under the cursor
      press(fr + 20, SY, STICK_Y, 1, 3)     -- the stick down: the cursor to the next entry
    end
  else
    error("sndproto.lua: PROTO_MENU must be selftest or soundtest")
  end
end

local machine = manager.machine
local main = assert(machine.devices[":mainpcb:maincpu"], "no :mainpcb:maincpu")
local jsa = assert(machine.devices[":mainpcb:jsa:cpu"], "no :mainpcb:jsa:cpu")
local mprog = main.spaces["program"]
local jprog = jsa.spaces["program"]
local mpc = main.state["CURPC"]
local ma6 = main.state["A6"]
local ma7 = main.state["A7"]
local jpc = jsa.state["PC"]

local QUEUE_STORE = 0x030212 -- move.b d2,(a0,d1.w) in queue_sound_command
local frame = 0
local queue, send, inject, response, taken, resp_read, reset, wd = {}, {}, {}, {}, {}, {}, {}, {}
local dispatch, class_lookup, jqueue, ymtimer = {}, {}, {}, {}
local first = {}
local reset_frames = {}
local boot = {}
local counts = { commands = 0, taken = 0, responses = 0, resp_reads = 0, resets = 0,
  injected = 0, queued = 0, queue_clears = 0 }
local injecting = false

local function bump(t, k)
  t[k] = (t[k] or 0) + 1
  if not first[k] then first[k] = frame end
end

local function log_boot(s)
  if #boot < 40 then boot[#boot + 1] = string.format("%d %s", frame, s) end
end

local function caller_of(ret)
  if ret >= 6 and mprog:read_u16(ret - 6) == 0x4EB9 then return ret - 6 end
  if ret >= 2 and mprog:read_u16(ret - 2) == 0x4E92 then return ret - 2 end
  return ret
end

-- Taps stay referenced from globals: a collected tap is removed.
SNDPROTO_CMD = mprog:install_write_tap(0x600000, 0x603FFF, "sndproto_cmd",
  function(offset, value, mask)
    if (mask & 0xFF00) == 0 then return value end
    local cmd = (value >> 8) & 0xFF
    counts.commands = counts.commands + 1
    if injecting then
      counts.injected = counts.injected + 1
      bump(inject, string.format("inject %02X", cmd))
    else
      local pc = mpc.value
      -- the send routines (023EDA/023EDE, 023E96) have no frame: the return address is at A7
      local caller = "-"
      if pc == 0x023EF6 or pc == 0x023EC0 then
        caller = string.format("%06X", caller_of(mprog:read_u32(ma7.value)))
      end
      bump(send, string.format("send %02X %06X %s", cmd, pc, caller))
    end
    log_boot(string.format("C %02X", cmd))
    return value
  end)

SNDPROTO_RESP = mprog:install_read_tap(0x600000, 0x603FFF, "sndproto_resp",
  function(offset, value, mask)
    if (mask & 0xFF00) ~= 0 then
      counts.resp_reads = counts.resp_reads + 1
      bump(resp_read, string.format("resp_read %06X", mpc.value))
    end
    return value
  end)

SNDPROTO_RESET = mprog:install_read_tap(0x604000, 0x607FFF, "sndproto_reset",
  function(offset, value)
    counts.resets = counts.resets + 1
    local pc = mpc.value
    -- 023FA8 is reset_sound_board, called only by reset_sound (0300F8, under link A6): the
    -- call of reset_sound is found from its return address at 4(A6)
    local via = "-"
    if pc == 0x023FA8 then via = string.format("%06X", caller_of(mprog:read_u32(ma6.value + 4))) end
    local k = string.format("reset %06X %s", pc, via)
    bump(reset, k)
    reset_frames[k] = (reset_frames[k] and (reset_frames[k] .. " ") or "") .. frame
    log_boot("S")
    return value
  end)

SNDPROTO_QUEUE = mprog:install_write_tap(0xFFDB64, 0xFFDBC3, "sndproto_queue",
  function(offset, value, mask)
    if mpc.value ~= QUEUE_STORE then
      -- the RAM clear of game_reset (021302) and the like, not a command
      counts.queue_clears = counts.queue_clears + 1
      return value
    end
    local byte = ((mask & 0xFF00) ~= 0) and ((value >> 8) & 0xFF) or (value & 0xFF)
    local ret = mprog:read_u32(ma6.value + 4)
    counts.queued = counts.queued + 1
    bump(queue, string.format("queue %02X %06X", byte, caller_of(ret)))
    return value
  end)

SNDPROTO_WATCHDOG = mprog:install_write_tap(0xFFDB5C, 0xFFDB63, "sndproto_wd",
  function(offset, value, mask)
    bump(wd, string.format("watchdog_write %06X", mpc.value))
    return value
  end)

SNDPROTO_TAKEN = jprog:install_read_tap(0x2800, 0x29FF, "sndproto_taken", function(offset, value)
  if (offset & ~0x01F9 & 0xFFFF) == 0x2802 then
    counts.taken = counts.taken + 1
    bump(taken, string.format("taken %04X", jpc.value))
    log_boot(string.format("T %02X", value))
  end
  return value
end)

SNDPROTO_RESPONSE = jprog:install_write_tap(0x2A00, 0x2BFF, "sndproto_response",
  function(offset, value)
    if (offset & ~0x01F9 & 0xFFFF) == 0x2A02 then
      counts.responses = counts.responses + 1
      bump(response, string.format("response %02X %04X", value, jpc.value))
      log_boot(string.format("R %02X", value))
    end
    return value
  end)

SNDPROTO_DISPATCH = jprog:install_read_tap(0x6100, 0x616C, "sndproto_dispatch",
  function(offset, value)
    if jpc.value == 0x4375 then bump(dispatch, string.format("dispatch %02X", offset - 0x6100)) end
    return value
  end)

SNDPROTO_CLASS = jprog:install_read_tap(0x6093, 0x60FF, "sndproto_class", function(offset, value)
  bump(class_lookup, string.format("class_lookup %02X", offset - 0x6093))
  return value
end)

SNDPROTO_YM = jprog:install_write_tap(0x2000, 0x2000, "sndproto_ym", function(offset, value)
  if value >= 0x10 and value <= 0x14 then
    bump(ymtimer, string.format("ym_timer_reg %02X %04X", value, jpc.value))
  end
  return value
end)

SNDPROTO_JQUEUE = jprog:install_write_tap(0x0200, 0x022F, "sndproto_jqueue",
  function(offset, value)
    bump(jqueue, string.format("jsa_queue %02X %04X", value, jpc.value))
    return value
  end)

local function field(port, name)
  local p = machine.ioport.ports[port]
  return p and p.fields[name]
end
local coin = field(":mainpcb:IN0", "Coin 1")
local start = field(":mainpcb:a80000", "1 Player Start")
local trigger = field(":mainpcb:a80000", "P1 Button 1")
assert(not PLAY or (coin and start and trigger), "stunrun input fields not found")
for _, a in ipairs(ACTIONS) do
  a[5] = assert(field(a[2], a[3]), "sndproto.lua: no input field " .. a[2] .. " " .. a[3])
end
local by_frame = {}
for _, a in ipairs(ACTIONS) do
  by_frame[a[1]] = by_frame[a[1]] or {}
  table.insert(by_frame[a[1]], a)
end
if SERVICE then assert(field(":mainpcb:IN0", "Service Mode"), "no Service Mode"):set_value(1) end

local function dump(f, t, extra)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    f:write(k, " ", t[k], " ", extra and extra[k] or first[k], "\n")
  end
end

SNDPROTO_SUBSCRIPTION = emu.add_machine_frame_notifier(function()
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
  if INJECT[frame] then
    injecting = true
    mprog:write_u16(0x600000, INJECT[frame] << 8)
    injecting = false
  end
  if frame == FRAMES then
    local f = assert(io.open(OUT .. NAME .. ".txt", "w"))
    f:write(string.format("# frames %d\n# play %s\n# menu %s\n# input_steps %d\n", FRAMES,
      PLAY and "yes" or "no", SERVICE and MENU or "-", #ACTIONS))
    local keys = {}
    for k in pairs(counts) do keys[#keys + 1] = k end
    table.sort(keys)
    for _, k in ipairs(keys) do f:write("# ", k, " ", counts[k], "\n") end
    dump(f, queue)
    dump(f, send)
    dump(f, inject)
    dump(f, response)
    dump(f, taken)
    dump(f, resp_read)
    dump(f, reset, reset_frames)
    dump(f, wd)
    dump(f, dispatch)
    dump(f, class_lookup)
    dump(f, jqueue)
    dump(f, ymtimer)
    for _, e in ipairs(boot) do f:write("boot ", e, "\n") end
    f:close()
    local done = assert(io.open(OUT .. NAME .. "done", "w"))
    done:close()
    io.write(string.format("sndproto.lua: %d frames, %d commands, %d responses -> %s%s.txt\n",
      FRAMES, counts.commands, counts.responses, OUT, NAME))
    machine:exit()
  end
end)
