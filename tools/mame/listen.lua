-- MAME autoboot script for `make listen` (docs/09-sound-program.md section 6): attract mode with
-- its sounds on, as "SOUNDS IN ATTRACT" set to ON in the operator menu would have it.
--
-- With the set's factory NVRAM the option is off: the 68010 reads bit 11 of its option word
-- FF94EE when attract mode starts and sends sound command 01 (bit clear) or 02 (bit set)
-- (0x028362-0x02837E). Both are command type 00 (cmdtype_00, 438A), which sets zp_1E to four
-- times the parameter: F0 for 01, 0 for 02. The 6502 starts an OKI sample only while zp_1E is 0
-- (5BFE) and keys on a YM2151 channel only when ram_088E is at least zp_1E (4EE6), so 01
-- silences attract mode. The write tap below returns every value the
-- game writes to FF94EE with bit 11 set, so the game itself sends 02. Nothing else changes: the
-- ROMs are the rebuilt ones the target passes with -rompath, and the NVRAM is a private one that
-- the target removes first.

local main = manager.machine.devices[":mainpcb:maincpu"]
assert(main, "listen.lua: stunrun not running")

-- Taps stay referenced from globals: a collected tap is removed.
LISTEN_OPTION = main.spaces["program"]:install_write_tap(0xFF94EE, 0xFF94EF, "listen_option",
  function(addr, value, mask) return value | (0x0800 & mask) end)
