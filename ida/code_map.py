"""The code map of the 68k database (milestone 2, docs/06-code-map.md): names and comments.

Pure Python, applied by `ida.memory_map.setup_68k_full` with the memory map, so a fresh
`make ida` has them even without a snapshot; `make ida-annotate` re-applies them over a database
whose snapshot predates them. M2 names only what places the programs: the reset paths, the two
vector tables' handlers, the GSP and ADSP loaders and control helpers, the program table and
the serial download monitors. No game logic, but for M3a's object list for the ADSP
(build_object_list, fill_object_entry, update_object_entry, object_descriptor and the
descriptor table, docs/07-objects.md section 3).

MAME 0.289 citations are file:line in src/mame/atari/ (harddriv.cpp, harddriv_m.cpp) and
src/devices/cpu/tms34010/tms34010.cpp. The 68k writes the board's control lines through two
latches that decode the address, not the data: NWR at 604000 (hd68k_nwr_w, harddriv_m.cpp:400:
word offset bits 0-2 the line, bit 3 the value) and the ADSP control at 818000
(hd68k_adsp_control_w, harddriv_m.cpp:685: same scheme; line 5 /BR, 6 /HALT, 7 reset), so
`clr.w $60401C` sets NWR line 6 to 1.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Entry:
    ea: int
    name: str | None  # None: a comment only
    comment: str
    kind: str = "function"  # function (function comment), label or data (regular comment)


# The game program's vector table: VBR = 0x020000 (set by the boot code at 0x000294).
GAME_VECTORS = 0x020000

_GSP_LOAD = (
    "The GSP section table (gsp_program, 01907C) as tools/programs.py parses it: a section "
    "count, then per section a destination bit address, a bit length and the data as longs."
)

CODE_MAP_68K = [
    # --- the boot program (pair R, VBR = 0) ---
    Entry(
        0x000216,
        "boot_reset",
        "Boot reset (vector 1 at 000004). SP and VBR from address 0, then RESET; kicks the "
        "watchdog (608000), clears IRQ5 (60C000) and the ADSP IRQ (818060), reads 604000 and "
        "600000, clears 840000 and 84C000 (outside MAME's map: HYP, options of other "
        "boards). PORT0 bit 5 (SELF-TEST, active low, harddriv_m.cpp:201) high: "
        "boot_init_gsp, boot_load_gsp_palette, boot_fill_gsp_vram, then boot_start_game. Low: "
        "boot_select_self_test.",
    ),
    Entry(
        0x000286,
        "boot_start_game",
        "VBR switch: A0 = 020000, SP = (A0), A1 = 4(A0), movec A0,VBR (000294), clears IRQ5, "
        "jmp (A1) = game_reset (020004 holds 0212AE). From here the game's vector table at "
        "020000 serves every exception.",
        "label",
    ),
    Entry(
        0x0002A0,
        "boot_select_self_test",
        "Self-test switch on: PORT0 bit 0 (DIAGN jumper) picks the self-test entry, 00506C "
        "(set, bne at 0002A8) or 008FEE (clear).",
        "label",
    ),
    Entry(0x000370, "boot_delay", "Busy wait, between the /GSPRES edges of boot_init_gsp."),
    Entry(
        0x0003F8,
        "boot_init_gsp",
        "The boot program's GSP set-up: pulses /GSPRES inline (clr.w 60400C = NWR line 6 low, "
        "boot_delay, clr.w 60401C = line 6 high; hd68k_nwr_w case 6, harddriv_m.cpp:426), "
        "HSTCTL = A000 (halted), then GSP I/O registers through the host port (00037C, "
        "00034A, 0007C2, 0003BE, 00048E). The game has its own copy, init_gsp (022382).",
    ),
    Entry(
        0x000570,
        "boot_load_gsp_palette",
        "HSTCTL |= 1800 (autoincrement), clears F4800020/F4800030, then palette ramps from "
        "F5000000 (palette RAM, harddriv.cpp:626-627) through 0004F6, 000518, 000530.",
    ),
    Entry(
        0x000636,
        "boot_fill_gsp_vram",
        "HSTCTL |= 1800, D0 to the GSP control latch F4000000, then FFFF to 96 x 256 words "
        "from 02000000 (the 2bpp VRAM window, harddriv.cpp:623), kicking the watchdog.",
    ),
    Entry(
        0x0008C2,
        "boot_read_wheel",
        "Called by boot_level5_timer: reads 400000 and clears 408000, the compact Hard "
        "Drivin' wheel ports (MAME installs them only for compact boards, "
        "harddriv.cpp:4810-4811; unmapped on this board). HYP: the boot program is the "
        "Hard Drivin' family self-test.",
    ),
    Entry(
        0x000248,
        None,
        "840000 and 84C000 (and 000248/00024E only): no device in MAME's stunrun map "
        "(harddriv.cpp init_adsp maps 800000-83FFFF). HYP: clears for boards Hard Drivin' has "
        "(DSK, DS III) and this one does not.",
        "label",
    ),
    Entry(
        0x00619E,
        None,
        "E0000, E0010, E0000, E0010 then E8000 (and E7FFF at 00623C): a slapstic unlock and "
        "bank test (MAME maps a slapstic at E0000-E7FFF for Hard Drivin', "
        "harddriv.cpp:1467-1468, and removes it for stunrun, harddriv.cpp:1866). The same "
        "sequence at 001A40-001AE0, not yet code in IDA. HYP: shared self-test code.",
        "label",
    ),
    # --- the program table (pair R) ---
    Entry(
        0x017000,
        "adsp_program_ptr",
        "Long: 01702E, the ADSP record stream (adsp_program). Read at 02C204 by "
        "init_coprocessors for load_adsp_program.",
        "data",
    ),
    Entry(
        0x017004,
        "gsp_program_ptr",
        "Long: 01907C, the GSP section table (gsp_program). Read at 02C1B6 (init_coprocessors) "
        "and 02DCB0 (reload_gsp) for load_gsp_program.",
        "data",
    ),
    Entry(
        0x017008,
        "program_table_long_8",
        "Long, no reader found. Not a byte, word or long sum nor a CRC-32 of the ADSP stream, "
        "the GSP table, both, or pair R (checked, docs/06).",
        "data",
    ),
    Entry(0x01700C, "program_table_long_c", "Long, no reader found (see 017008).", "data"),
    Entry(
        0x017010,
        "copyright_text",
        "'Copyright 1989 ATARI GAMES', 26 ASCII bytes, then two zero bytes and a word with no "
        "reader found (01702C).",
        "data",
    ),
    Entry(
        0x01702E,
        "adsp_program",
        "ADSP-2100 program, 01702E-01907C: records {flag byte 0, word address, count, count x "
        "24-bit opcodes}, a flag byte FF ends it (01907B). 17 records, 2,728 words to PM "
        "0000-089A and 1029-1235. A blob of its own in asm/68k/stunrun.asm "
        "(build/adsp/program.bin).",
        "data",
    ),
    Entry(
        0x01907C,
        "gsp_program",
        "TMS34010 program, 01907C-01EFD4: " + _GSP_LOAD + " 4 sections to FFF40000-FFF5A170, "
        "FFF5A170-FFF5C8F0, FFF5C8F0-FFF6F580 and FFFFFC00-FFFFFFFF (the trap vectors). A blob "
        "of its own in asm/68k/stunrun.asm (build/gsp/program.bin).",
        "data",
    ),
    # --- the game program (pairs S onwards, VBR = 020000) ---
    Entry(
        0x020100,
        "game_entries",
        "Three jmp: game_entry_1 (021334), game_entry_2 (021378), game_entry_3 (0213B6). Entered "
        "by the boot self-test with VBR = 020000: 0010FC jmp (A1) = game_entry_1, 001130 jsr "
        "(A1) = game_entry_3 (A1 + C), 008F1A jsr (A1) = game_entry_2 (A1 + 6).",
        "label",
    ),
    Entry(
        0x021286,
        "soft_reset",
        "stop #2700 (every interrupt but level 7 masked: the watchdog, no longer kicked, "
        "resets the board, HYP); after it, VBR = 0, 818040 = 4, the warm-start magic at "
        "FF8018 cleared, jmp through the boot vector table ($4.w). Called on fatal errors: "
        "load_gsp_section (02FE40), unpack_gsp_image (0225CE), the exception reporters.",
    ),
    Entry(
        0x021334,
        "game_entry_1",
        "Like game_reset without the warm-start check: clears RAM FF8000-FFFFFF, "
        "clear_gsp_vram, clear_msp_ram, 020702, then 02DCE0 instead of the main "
        "initialisation; soft_reset if it returns.",
    ),
    Entry(
        0x021378,
        "game_entry_2",
        "As game_entry_1 without clear_msp_ram, then 043718; soft_reset if it returns.",
    ),
    Entry(
        0x0213B6,
        "game_entry_3",
        "As game_entry_2, then 03CE64; soft_reset if it returns.",
    ),
    Entry(
        0x02141A,
        "stop_adsp",
        "ADSP control: clr.w 81801C (/HALT = 1, released), 81800E (reset = 0, asserted), "
        "818060 (clear the ADSP interrupt), 818014 (line 2 = 1), then 4 to 818040 (outside "
        "MAME's control range 818000-81801F, harddriv.cpp:4833: HYP). Called by "
        "init_coprocessors (02C176) before the loads.",
    ),
    Entry(0x021602, "delay", "Busy wait of 150 iterations, between the /GSPRES edges."),
    Entry(
        0x021700,
        "fill_gsp_vram",
        "HSTCTL |= 1800 (INCR, INCW), D0 to the GSP control latch F4000000, then FFFF to 96 x "
        "256 words from 02000000 (the 2bpp VRAM window, harddriv.cpp:623), kicking the "
        "watchdog. The game's copy of boot_fill_gsp_vram.",
    ),
    Entry(
        0x022370,
        "reset_gsp",
        "The /GSPRES pulse: clr.w 60400C (NWR line 6 = 0: GSP reset asserted), delay, clr.w "
        "60401C (line 6 = 1: released). hd68k_nwr_w case 6, harddriv_m.cpp:426.",
    ),
    Entry(
        0x022382,
        "init_gsp",
        "reset_gsp, then the GSP I/O registers through the host port (02166E, 0215DC, "
        "0216EA, 0216B0), the palette (021462), F4800090/F4800010, and a call to 0441EC+404 "
        "(HYP: the video timing table). The game's copy of boot_init_gsp. Called by "
        "init_coprocessors, reload_gsp, download_gsp_program, load_gsp_program, 030778.",
    ),
    Entry(
        0x0223F4,
        "clear_gsp_vram",
        "HSTADR = FF800000, HSTCTL = B800 (halted, autoincrement), then 5 x 65,536 clr.l of "
        "HSTDATA (C0000C and C0000E both reach HSTDATA: harddriv_m.cpp:150 maps word offset "
        "(n/2)^1), kicking the watchdog. Called by game_reset and the game_entry_* paths.",
    ),
    Entry(
        0x022428,
        "clear_msp_ram",
        "The same through the MSP host port at C04000; this board has no MSP (reads FFFF, "
        "harddriv_m.cpp:166).",
    ),
    Entry(
        0x022468,
        "clear_gsp_screen",
        "fill_gsp_vram with D0 = 0. Called by init_coprocessors, reload_gsp, 030778.",
    ),
    Entry(
        0x02256C,
        "set_sr",
        "SR = the word argument, returns the old SR. init_coprocessors and reload_gsp call it "
        "with 2000 (interrupts on) before the loads.",
    ),
    Entry(
        0x022578,
        "copy_to_zram",
        "Copies bytes with interrupts masked between two NWR writes: clr.w 604008 / 60401A "
        "(ZP1 = 0, ZP2 = 1: harddriv_m.cpp:420-425) before, clr.w 604018 / 60400A (ZP1 = 1, "
        "ZP2 = 0) after. HYP: ZP1/ZP2 unlock the EEPROM/ZRAM write protection.",
    ),
    Entry(
        0x0225E4,
        "unpack_gsp_image",
        "Streams a packed image into HSTDATA (C0000C), kicking the watchdog per run; the first "
        "byte must be 0 (else soft_reset at 0225CE), a 16-entry table built by 0225B0 at "
        "FF902A. In a MAME read watch (docs/06) it is the code that reads pairs U and V "
        "(060000-09F1C4): their consumer is the GSP, through this routine. Format: M5d.",
    ),
    Entry(
        0x02C0D2,
        "init_coprocessors",
        "Called by the main initialisation (0243AC). init_gsp, clear_gsp_screen, messages "
        "through 023898, stop_adsp, set_sr(2000); then the GSP: PORT0 bit 14 (SW1 #2, "
        "harddriv_m.cpp:201) set: download_gsp_program, else load_gsp_program(gsp_program_ptr) "
        "(02C1B6); HSTCTL = 7800 then 3800 (02C1C4: clears HLT, the GSP runs from its reset "
        "vector FFFFFFE0 = FFF59920). Then the ADSP: PORT0 bit 12 (SW1 #4) set: "
        "download_adsp_program, else load_adsp_program(adsp_program_ptr) (02C204); 02C212 "
        "starts it.",
    ),
    Entry(
        0x02C212,
        None,
        "ADSP start: reset, line 4 and /BR asserted (81800E, 818008, 81800A), DM 1FFF = FFFF "
        "(80BFFE: the frame trigger idle value), clear its interrupt (818060), lines 2 and 3 "
        "(818014, 818016: 3 = SOM bank 1), then reset, line 4, /BR and /HALT released "
        "(81801E, 818018, 81801A, 02C26E 81801C).",
        "label",
    ),
    Entry(
        0x02D1D4,
        "download_adsp_program",
        "Serial download monitor (selected by SW1 #4 in init_coprocessors): holds the ADSP "
        "(818008, 81800A, 81800E, 81800C cleared), waits for ten 'A' then 'G' from the DUART "
        "(023C9A), then reads records in the ROM format of adsp_program and writes them to "
        "800000 + 4 x address, until a non-zero flag; releases line 4, /BR and reset.",
    ),
    Entry(
        0x02D2E0,
        "load_adsp_program",
        "ADSP loader: argument = the record stream (adsp_program). Holds the ADSP: clr.w "
        "818008 (line 4 = 0), 81800A (/BR asserted), 81800E (reset asserted), 81800C (/HALT "
        "asserted). Per record (02D304): flag byte (non-zero ends), BE word address A, BE "
        "count N, N packed BE 24-bit opcodes, each stored with move.l D0,(A2)+ at 800000 + 4 "
        "x A onwards (02D35C; hd68k_adsp_program_w, harddriv_m.cpp:556, puts the high half in "
        "bits 31-16). Then clr.w 818018, 81801A, 81801E (02D366-02D372): line 4, /BR, reset "
        "released; /HALT stays asserted until init_coprocessors (02C26E). tools/programs.py "
        "implements it.",
    ),
    Entry(
        0x02D6D8,
        "copy_adsp_dram_to_18000",
        "Copies 2000h words of ADSP data RAM (808000) to 018000, which is ROM on this board "
        "(inside gsp_program): the writes go nowhere. No caller found (no absolute reference, "
        "no cross-reference). HYP: a leftover from a development board with RAM there.",
    ),
    Entry(
        0x02DC32,
        "reload_gsp",
        "As the GSP half of init_coprocessors: init_gsp, clear_gsp_screen, a message, "
        "set_sr(2000), download_gsp_program or load_gsp_program(gsp_program_ptr) (02DCB0), "
        "HSTCTL 7800 then 3800. Called from 02DCF0 and 04373A.",
    ),
    # --- the object list for the ADSP (M3a, docs/07 section 3) ---
    Entry(
        0x02DD9E,
        "build_object_list",
        "Builds the ADSP's object list at DM 0A00 (809400, stored in FF9C6E at 02DDAE): one "
        "24-word entry per entity through fill_object_entry, the entity at the long FFDC74 "
        "first (02DEFC-02DF06), then the vehicles, FF9E70 and the list at FFDA96; FFFF after "
        "the last (02DFB6), soft_reset past 15E3h words (02DFC6), clears DM 1FFF (02DFD4) to "
        "start the ADSP frame. docs/07 section 3.1.",
    ),
    Entry(
        0x02E1EC,
        "fill_object_entry",
        "fill_object_entry(entity, entry): the 24-word object list entry from the entity and "
        "its descriptor (+26h, object_descriptor): near/far objects, matrix, position, radius, "
        "LOD and cull distances, flags from entity +38h; +38h bit 5 set: cull distance 1 for "
        "the FFDC74 entity, else returns 0 (02E214). The flags word's bit 0 is an "
        "uninitialised local (link at 02E1EC). docs/07 section 3.1.",
    ),
    Entry(
        0x02E30C,
        "update_object_entry",
        "As fill_object_entry for an entry already in the list, without rebuilding it; keeps "
        "the flags word's bit 0 (loads it at 02E372); returns 0 for any +38h bit 5 entity "
        "(02E318-02E320). docs/07 section 3.1.",
    ),
    Entry(
        0x02ECF0,
        "object_descriptor",
        "object_descriptor(n): object_descriptors + 20 x n for n < 13Ah (cmpi/bge at "
        "02ECF8-02ECFC, so 0-313), else 0. docs/07 section 3.2.",
    ),
    Entry(
        0x02FCC0,
        "download_gsp_program",
        "Serial download monitor (selected by SW1 #2 in init_coprocessors): waits for ten 'S' "
        "then 'G' from the DUART (023C9A), init_gsp, HSTCTL = B800, then sections in the ROM "
        "format of gsp_program read as longs through 02FF8E, each with a checksum "
        "(soft_reset on a mismatch, 02FDBE).",
    ),
    Entry(
        0x02FDD0,
        "load_gsp_program",
        "GSP loader: argument = the section table (gsp_program). init_gsp, HSTCTL = B800 "
        "(02FDE2: HLT, LBL, INCR, INCW; the GSP stays halted), section count (02FDEA), then "
        "load_gsp_section per section. The caller releases the GSP (02C1C4).",
    ),
    Entry(
        0x02FE0C,
        "load_gsp_section",
        "One section: destination bit address and bit length (02FE1A/02FE1C), move.l D0,"
        "$C00002 (02FE1E: HSTADRH then HSTADRL, harddriv_m.cpp:150 and tms34010.cpp host_w), "
        "write_gsp_long per 32 bits; a 16-bit remainder writes the low word of one more long "
        "(02FE4A), any other remainder calls soft_reset (02FE40). Returns the next section.",
    ),
    Entry(
        0x02FE5E,
        "write_gsp_long",
        "Writes its long argument to HSTDATA (C0000C) low word first (02FE68), then high word "
        "(02FE6E); each write stores 16 bits at HSTADR and adds 10h (INCW).",
    ),
    Entry(
        0x048F9C,
        "object_descriptors",
        "20-byte object descriptors, read through object_descriptor (0-313): near object, far "
        "object, the descriptor number animations step from (03DAB8), radius, LOD distance "
        "(long), cull distance (long), a long fill_object_entry does not read. 313 holds -1/-1 "
        "(HYP: an end marker, no reader found). docs/07 section 3.2.",
        "data",
    ),
]

# Comments for the handlers of both vector tables, by target address: what each acknowledges.
HANDLER_COMMENTS = {
    # boot table (000000)
    0x0007D6: "Sets FF9046 = FFFF and clears HSTCTL bit 7 (C00008 &= FF7F), INTOUT: "
    "acknowledges the GSP's host interrupt (tms34010.cpp io_register_w HSTCTLL).",
    0x0007F0: "Saves and restores registers only: does not clear the ADSP interrupt (818060).",
    0x0007FA: "Sets FF80E6 = FFFF and clears the MSP's INTOUT (C04008 &= FF7F).",
    0x000812: "Saves and restores registers only.",
    0x00081C: "Reads the JSA response byte (600000) into D0.",
    0x00082C: "Counts FF9042, reads the 8-bit ADC (B00001) into FF8007 + channel, starts the "
    "12-bit ADC, calls boot_read_wheel, and acknowledges with clr.w 60C000 (IRQ5_ACK).",
    # game table (020000)
    0x0212AE: "Game reset (vector 1 at 020004). Watchdog, SR = 2700, 818040 = 4; if FF8018 "
    "holds the warm-start magic 31415982, counts the restart in ZRAM (FF4B90, 02EFB6). Clears "
    "RAM FF8000-FFFFFF, sets the magic, clear_gsp_vram, clear_msp_ram, 020702, then the main "
    "initialisation 024306 (which calls init_coprocessors at 0243AC); soft_reset if it "
    "returns.",
    0x0213FE: "Clears the ADSP interrupt (clr.w 818060, hd68k_adsp_irq_clear_w, "
    "harddriv_m.cpp:751), calls 02E418, then clr.w 818010 (control line 0 = 1: an LED).",
    0x02143C: "Sets FFDB48 = FFFF, clears HSTCTL INTOUT (C00008 &= FF7F: acknowledges the GSP; "
    "the GSP sets it after each command buffer, FFF41910), stores the ticks since FFDB36 in "
    "FF9BAA.",
    0x023F24: "Appends the JSA response byte (600000) to the buffer at FF9470.",
    0x0222DA: "Counts the ticks in FF8014, calls 02FFF0, acknowledges with clr.w 60C000 "
    "(IRQ5_ACK).",
    0x0239FE: "Services the DUART channels (FFFF0012, FFFF0002 status bits) through 023A54, "
    "023AA0, 023B0A, 023B54.",
    0x0229C4: "Reports error 14 (030756 -> 030A2C) and soft_reset.",
    0x0229D4: "Reports error 15 (03073A -> 030A2C) and soft_reset.",
}
for _ea, _code in (
    (0x022954, "030676"),
    (0x022964, "030702"),
    (0x022974, "03071E"),
    (0x022984, "0306E6"),
    (0x022994, "0306CA"),
    (0x0229A4, "0306AE"),
    (0x0229B4, "030692"),
):
    HANDLER_COMMENTS[_ea] = f"Reports the exception ({_code}) and soft_reset."
