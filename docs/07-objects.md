# The object ROMs: format, inventory, and data/objects

**Date**: 2026-11-04 (milestone 3a). What the 384 KB of the six ADSP object ROMs hold, how the
ADSP-2100 reads them and how the 68k chooses what it reads, and how the repository rebuilds them
from `data/objects`. Addresses: ADSP program (PM) and data (DM) words in hex without prefix,
68k addresses as 0x...., object ROM addresses as `page:word` (word = byte offset in
`build/stunrun-obj.bin` / 2 - page × 0x10000). **CODE** means read off the ADSP listing
(`make dasm`, `build/adsp/program.annotated.lst`) or the 68k disassembly at the addresses
given, **MAME** means a MAME 0.289 run with a committed script confirms it, **HYP** is a
hypothesis. MAME source citations are `file:line` in `~/.local/src/mame/src/mame/atari/`.
The SOM display list, the clipper and the GSP side are docs/08 (M3b); this document stops where
the object path hands over to them.

## 1. Summary

- The ADSP reads the object ROMs only as a serial stream: a 64K-word page (/MP), a word
  address (/SIMCLK), and reads that return a word and advance (/SIMBUF). Five places start a
  read sequence (section 2), and a MAME trace of 4.1 million sequences over attract mode and a
  started game matches the decoder's structure: every sequence starts at a structure the
  decoder knows and reads exactly its length (section 7). The trace records no word values;
  those are proven by the byte-identical `make check`. **MAME**
- Page 0 starts with a **directory** of 413 words, one per object, P = page << 14 | address >> 2,
  ended by FFFF. The 68k chooses objects by number through a 24-word **object list entry** per
  object in ADSP data RAM at DM 0A00; a 68k table of 314 **object descriptors** (0x048F9C, 20
  bytes each, 0-313; 313 holds -1/-1) gives each game entity a near and a far object number, cull and level-of-detail
  distances and a radius. **CODE, MAME**
- An **object** is a header (point count, vertex count, normal count), the vertices and the
  normals (three signed words each; the normals are typically of length about 4000h, Q14, an
  observation of the data, section 4), a pointer to the record list, one
  two-word record per face (polygon address; type, count, colour) ended by 0000 0000, and one
  polygon per face (normal point number, vertex point numbers, FFFF). **CODE, MAME**
- Page 1 starts with a 32K-word **reciprocal table** the projection reads (1/z), an exact
  function reproduced by `reciprocal()` in tools/objects. Each page ends with one **checksum
  word** that makes each chip's byte sum equal the last two digits of its part number. **CODE**
  (the table, read at 04C5/04E1), checked over all six chips (the checksum).
- Every one of the 196,608 words is accounted for: 413 objects, the directory, the table, three
  checksum words, zero fill, and **one residue word** (0:019E) the format does not explain.
  `data/objects` (a manifest and 413 mesh files) is now the source of the object image, and
  `make check` rebuilds the six files byte for byte from it (section 8).

## 2. How the ADSP drives the object ROMs (CODE, MAME)

The ADSP's I/O at DM 2000-2FFF (`hdadsp_special_r`/`_w`, harddriv_m.cpp:776-838, decoded on
`offset & 7`):

| DM | Access | MAME | Effect |
|---|---|---|---|
| 2000 | read | `/SIMBUF`, :780-784 | returns `sim_memory[eprom_base + sim_address++]`; past the region it returns FF |
| 2001 | write | `/SIMCLK`, :807-809 | `sim_address = data` (a `uint16_t`, harddriv.h:381: it wraps within the page) |
| 2007 | write | `/MP`, :829-831 | `eprom_base = 0x10000 × data` |

`m_sim_memory` is region `mainpcb:user1`, `ROM_REGION16_BE` 0x60000 bytes (harddriv.cpp:2708):
word n is bytes 2n (high) and 2n+1 (low), so the even-byte chips 90h/10h/9h hold the high bytes.
That is the layout of `build/stunrun-obj.bin` (tools/merge-roms).

Every instruction of the program that touches DM 2000, 2001 or 2007:

| PM | Instruction | Role |
|---|---|---|
| 002E | `DM($2007) = AR` | /MP = DM 1FFE once per frame (`select_object_page`); every object overrides it at 00A0/00A6, so it has no effect on the reads below (HYP: a leftover) |
| 009E | `DM($2001) = AR` | /SIMCLK = the object number (sequence **directory**) |
| 00A0 | `DM($2007) = AR` | /MP = 0 |
| 00A3 | `AR = DM($2000)` | the directory word P |
| 00A6 | `DM($2007) = SR1` | /MP = P >> 14 (00A5: `SR = LSHIFT SI BY 2 (LO)`, SR1 holds the bits shifted out) |
| 00A8 | `DM($2001) = SR0` | /SIMCLK = (P << 2) & FFFF (sequence **header**) |
| 011C, 011F, 0123 | `I0 = DM($2000)` | header: point count (overwritten by 011F), vertex count, normal count |
| 0147 | `I0 = $2000` | with M0 = 0 every `DM(I0,M0)` below reads /SIMBUF |
| 014C, 014F, 0152, 0155 | `SI = DM(I0,M0)` (014F in a multifunction) | vertices, one word ahead |
| 0163, 0166, 0172 | `SI = DM(I0,M0)` | normals, one word ahead; the last read is the record-list pointer |
| 017B | `DM($2001) = AY1` | /SIMCLK = record address (sequence **record**) |
| 017F, 0182 | `AX1 = DM($2000)`, `SI = DM($2000)` | record words 0 and 1 |
| 01A7 | `DM($2001) = AX1` | /SIMCLK = polygon address (sequence **polygon**) |
| 01EC, 01FC | `MR0 = DM($2000)` | the face's normal point, its first vertex |
| 01B1 | `MR0 = DM($2000)` | the other vertices and the FFFF (front-facing faces) |
| 01E4 | `MR0 = DM($2000)` | skip to FFFF (faces that look away, colour-0 faces) |
| 04BC | `DM($2007) = AR` | /MP = 1 |
| 04C2 | `DM($2001) = AR` | /SIMCLK = z of a projected vertex (sequence **reciprocal**) |
| 04C5, 04E1 | `MY0 = DM($2000)` | the reciprocal table entry |
| 04DE | `DM($2007) = AR` | /MP = DM 0031, the object's page (saved at 00A7) |

No other instruction addresses DM 2000, 2001 or 2007 directly, and the only index register
loaded with an address in 2000-2007 besides I0 at 0147 is I2 = 2002 at 081C (SOMLATCH, the SOM
output, docs/08). The trace in
section 7 sees no /SIMBUF read outside the five sequences and no /MP write between two reads of
one sequence.

## 3. From the 68k to an object number

### 3.1 The object list entry at DM 0A00 (CODE, MAME)

`copy_frame_parameters` sets DM 001B = 0A00 (0018-0019); `read_object_list` (0050) reads one
24-word entry per object; DM 001B then points at the next one (0085, 0095). Word 0 = FFFF ends
the frame (0051-0053 -> 00B4).

| Word | Read at | To | Meaning | 68k writer (`fill_object_entry` 0x02E1EC, refreshed by `update_object_entry` 0x02E30C) |
|---:|---|---|---|---|
| 0 | 0051, & 0FFF at 0056-0059 | DM 001C, DM 0009 | near object number | descriptor +0 (0x02E22A, 0x02E35E) |
| 1 | 005A, & 0FFF | DM 001D | far object number | descriptor +2 (0x02E230, 0x02E368) |
| 2-10 | 005D-0061 | DM 0000-0008 | the object's rotation matrix | entity +14h, copied by 0x022DD6 (0x02E23E, 0x02E332) |
| 11-16 | 0062-0066 | DM 001F-0024 | position x, y, z, 32 bits each (high, low) | entity +08h, +0Ch, +10h (0x02E244-0x02E250) |
| 17-18 | 0067-006B | DM 000A-000B | cull distance, 32 bits | descriptor +0Ch (0x02E220); an entity with +38h bit 5 set (0x02E1FC) gets 1 if it is the one whose pointer is at 0xFFDC74 (0x02E204-0x02E20E: a cull distance of 1, HYP: then always culled). The camera reading of that entity is contradicted by MAME: in the DUMP_FRAMES=3000 attract dump, entry 0 at DM 0A00 (the 0xFFDC74 entity, 0x02DEFC-0x02DF06) holds objects 130/131, radius 9600, LOD distance 1900h and cull distance 5DC00h, descriptor 83's values, so bit 5 was clear, and object 131 is in the attract trace's loaded list and is otherwise skipped: `fill_object_entry` returns 0 at 0x02E214 and `update_object_entry` returns 0 for any bit-5 entity at 0x02E318-0x02E320 |
| 19-20 | 006C-0070 | DM 0025-0026 | level-of-detail distance, 32 bits | descriptor +08h (0x02E25A) |
| 21 | 0071-0073 | DM 000F | bounding radius | descriptor +06h (0x02E264) |
| 22 | 0074-0076 | DM 0027, sign into DM 0028 | (not decoded; no reader in the object path) | entity +36h (0x02E26A) |
| 23 | 007E (not advanced), 0090-0094 | DM 002C, DM 002F | flags: bit 15 -> DM 002C (CALL 0887, HYP: an extra transform); bit 14 -> the batch handshake (0043-004F); bits 8-11 -> DM 002F, ORed into every face's colour word (01CE); bit 0 is written back by the ADSP: 1 = drawn, 0 = culled (DM 0013) | built from entity +38h: bit 7 -> flags bit 15 (0x02E2BE-0x02E2D2), bit 0 -> bit 14 (0x02E28A-0x02E2A2), bits 3-4 -> bits 10-11 (asl #3, lsr #6 at 0x02E274-0x02E276), bits 1-2 -> bits 8-9 (asl #5, lsr #6 at 0x02E2AA-0x02E2AC); bits 12-13 and 1-7 cleared (0x02E2D6-0x02E2F2); bit 0: uninitialised in `fill_object_entry`, whose flags word is the local at (-2,A6) of `link A6,#-$4` (0x02E1EC) and is never set before the `andi.b #$1,(-$1,A6)` at 0x02E2DC (the ADSP overwrites it at 0094), kept by `update_object_entry`, which loads the entry's word first (0x02E372); +38h bit 5 is not copied (tested at 0x02E1FC) |

`cull_and_lod` (06A1, called at 0088) culls an entry whose distance from the camera reaches
words 17-18 or that lies outside the view (with the radius), and sets DM 0017 when the distance
reaches words 19-20; 0098-009D then take word 1 instead of word 0. A culled entry never touches
the object ROMs (0096-0097).

MAME (`tools/mame/dump.lua`, DUMP_FRAMES=3000, attract mode): DM 0A00 holds 18 entries and the
FFFF at DM 0BB0 (0A00 + 18 × 24); words 0/1 are pairs such as 48/49, 60/61, 62/63 (near and far
objects that the descriptors pair, section 6), word 21 = 1131 for the vehicles, word 23 shows
bit 14 (entry 1), bits 8-11 (0100h, 0800h, 0C00h) and bit 0 (entry 17).

The 68k builds the list each frame in `build_object_list` (0x02DD9E): it stores 0x809400 (DM
0A00, `hd68k_adsp_data_w` maps DM n to 0x808000 + 2n) in 0xFF9C6E (0x02DDAE), fills one entry
per entity of its lists (the eight vehicles at 0xFF9C80 + 3Eh × k, 0xFF9E70, the list at
0xFFDA96 and the entity whose pointer is the long at 0xFFDC74, 0x02DF00, filled first, into entry 0 at
0x809400, 0x02DEFC-0x02DF06, and always followed by a 30h step, 0x02DF0C-0x02DF10) through `fill_object_entry`, writes FFFF after the last
(0x02DFB6), calls `soft_reset` if the list passes 15E3h words (0x02DFC6), and starts the frame by
clearing DM 1FFF (0x02DFD4). 0x02E064 is the same without rebuilding (it calls
`update_object_entry` per entity). 0x02C85A walks the same entities with their entry index
((+2Ah - 0x809400) / 30h at 0x02C886-0x02C88E; HYP: a debug overlay).

### 3.2 The object descriptors at 0x048F9C (CODE)

`object_descriptor` (0x02ECF0) returns 0x048F9C + 20 × n for n < 13Ah (`cmpi.w #$13a` / `bge`, 0x02ECF8-0x02ECFC: 314 entries, 0-313), else 0. Each
entity holds the pointer at +26h (written at 0x02ECBE, 0x031CF0 and 23 more sites); 63 call
sites pass a descriptor number. The 20-byte descriptor:

| Offset | Size | Meaning |
|---|---|---|
| +0 | word | near object number (entry word 0) |
| +2 | word | far object number (entry word 1) |
| +4 | word | the descriptor number 0x03DAB8 steps from: it calls `object_descriptor`(+4 + 1) (animations); equal to the descriptor's own number except in 115 and 116, which hold each other's (so 115 steps to 117 and 116 to itself) |
| +6 | word | radius (entry word 21) |
| +8 | long | level-of-detail distance (entry words 19-20) |
| +0Ch | long | cull distance (entry words 17-18) |
| +10h | long | not read by `fill_object_entry` (open question) |

Descriptors 0-312 are populated (whether every one is reached from the 63 call sites is not
established); 313, which `object_descriptor` also accepts, holds -1 as both object numbers and
0 elsewhere (HYP: an end marker; no code that reads it as one was found; were it selected,
entry word 0 = FFFF would end the ADSP's frame at 0051-0053). The table is followed at entry 314
by data that is not a descriptor. **Every object 0-412 is the near or far object of at least
one of descriptors 0-312**, and 100 objects are only ever far objects (marked in
the inventory). Examples of call sites: descriptors 1-10 and D2h are taken at 0x0254A4-0x02561A and
0x02BDBA-0x02BEDE and passed with the vehicle entities (0xFF9C80 + 3Eh × k, k = 0-7) to
0x02EC9C; descriptor 7Bh + D2 (0x031D68, 0x0323F0) steps through the iris rings 204-209; 0x0364D4 (A3h -> object 252), 0x03665A and 0x03BFDE (94h -> 230/231), 0x03BE02 (93h
-> 229), 0x037D0C (C1h -> 292), 0x0380EA / 0x03819A (CBh / CAh -> 302 / 301), 0x027B60-0x02842C
(CFh -> 306), 0x025616 / 0x028030 / 0x02BEDA (D2h -> 309). What these entities are in the game is M5's.

### 3.3 The directory (CODE, MAME)

`read_object_pointer` (009E-00A8) sends the object number to /SIMCLK with /MP = 0 and reads one
word P: the object starts at page P >> 14, word (P << 2) & FFFF. Objects therefore start at
multiples of four words, and the directory is page 0 words 0000-019C (413 entries), FFFF at
019D. The ADSP never reads the FFFF (the 68k's descriptors only hold 0-412); it is the
directory's end for the decoder. Within each page the objects lie in number order, each at the
first multiple of 4 after the one before (checked for all 413).

## 4. The object (CODE, MAME)

An object at `page:a` (a = 4k), as `read_object_header` (0114) and `read_object_records` (0174)
read it, with nv vertices and nn normals:

| Words | Field | Width | Meaning | Read at |
|---|---|---|---|---|
| a | points | 1 | nv + nn (always, all 413) | 011C into I0, overwritten at 011F: not used |
| a+1 | vertices | 1 | nv, the DO count of the vertex loop | 011F -> DM 0032 (014D) |
| a+2 | normals | 1 | nn, the DO count of the normal loop | 0123 -> DM 08DA (015F) |
| a+3 ... | vertex i (i = 1..nv) | 3 | x, y, z, signed 16 bits, object space | 014C/014F/0152/0155, transformed at 0157-015C into DM 010D + 3(i-1) |
| ... | normal j (j = 1..nn) | 3 | x, y, z, signed; typically of length about 4000h (Q14), see below | 0163/0166/0172, rotated at 0169-0171 into DM 010D + 3(nv + j - 1) |
| a+3+3(nv+nn) | record pointer | 1 | the address of the record list: always the next word | 0172 (the read after the last normal) -> DM 0034 -> /SIMCLK 017B |
| then, per face k | record | 2 | word 0: the face's polygon address; word 1: type << 12, count << 6, colour | 017F, 0182 |
| | end record | 2 | 0000 0000 (type 0) | 017F, 0182, then `RTS` at 0187 |
| then, per face k | polygon | n + 2 | the normal's point number, the n vertices' point numbers, FFFF | 01EC, 01FC, 01B1 (or 01E4) |

then zero padding to the next multiple of 4.

**Normals** are typically of length about 4000h (unit vectors in Q14), which is what the shading
assumes (HYP); nothing in the code depends on it and the encoder does not check it. Over the
5,071 normals (computed from data/objects), 302 differ from 4000h by more than 50 and 10 by more
than 500, every one of them used by a face: the zero normals of objects 310 and 336 (normal 0),
and normals 26-31 and 52-53 of object 333 (lengths 15,446 to 17,854).

**Point numbers.** Vertices and normals share one numbering from 1: vertex i is point i, normal
j is point nv + j. 01EC-01EF turn a point number n into DM 010A + 3n with `MR = MR + MR0 * MY0
(SS)` and MY0 = 1: the ADSP-2100's multiplier works in fractional mode and shifts the product
left by one, so MR0 = n + 2n = 3n. In the ROM every face's first word is a normal point (nv < n
<= nv + nn) and every vertex word a vertex point (1 <= n <= nv), for all 6,540 faces.

**Record word 1** (0182-01A6):

| Bits | Field | Values in the ROM | Consumed |
|---|---|---|---|
| 15-12 | type | 15 (6,527 faces), 1 (13 faces: objects 335 and 353-363) | 0183-0186 `JUMP (I4)` into `record_type_table` (0187): 0 = RTS (end), 1 -> 0197 (DM 0038 = 1), 2-15 -> 0199 |
| 11-6 | count | always 0 | 01A2-01A6: polygons in this record, 0 meaning 1 |
| 5-0 | colour | 0-63 | 019C-01A0 -> DM 0036; 0 skips the face (019F -> 01E4) |

Type 15 faces are shaded: `shade_face` (0214, called at 01C7) turns colours below 1Fh into
(colour << 4) + 10h ORed with an intensity from the normal and two 3-word vectors at PM
1019-101B and 101C-101E (0221-0228: CNTR = 2 at 0222, three multiply-accumulates per pass, I4
from 1019 with M4 = 1 while L3 = 3 wraps I3 over the normal at DM 0014-0016, so the result is
normal . (PM 1019-101B + PM 101C-101E); `copy_frame_parameters` fills all six from DM 1FEF-1FF4
at 001B-0020; HYP: two light vectors), faded with depth by 0238; colours 1Fh and up become colour & 1Fh. Type 1 faces skip shading and
carry 1000h (01C9-01CC), and the clipper takes another path for them (0273-0276 -> 068B, then
0663 at 01D9; docs/08). Every face's colour word then gets the entry's colour bank, flags bits
8-11 (01CD-01D0). What the colour word selects in the GSP palette is docs/08. HYP for the
meaning of type 1: flat panels drawn without lighting (objects 335 and 353-363 are flat
coloured quadrilaterals).

**A face** (`read_face_normal` 01E8): the normal point goes to DM 0014-0016, the first vertex
to DM 0040-0042; the sign of their dot product in camera space decides visibility (01A9: >= 0
looks away and 01E4 skips to the FFFF). A front-facing face's other vertices are copied to DM
0043 on until the FFFF (01AA-01C1, `copy_polygon_vertices`), and it is handed to the clipper
0271, `project_vertices` 04B2 and the SOM output (01D1-01DB, docs/08). A face has 2 to 16
vertices in the ROM (2 faces have 2: lines).

**Colour 0** hides a face: 019F jumps to 01E4 before /SIMCLK moves to the polygon, so the ADSP
reads on through the record list from the next record until the first FFFF (which is in the
first polygon), then continues with the next record (DM 0035 is still 1 from the previous face).
The polygon of a colour-0 face is never read. 20 faces in 5 objects (87, 179, 193, 195, 197)
have colour 0. **MAME**: the record sequences of these faces read exactly the predicted number
of words (section 7).

**Count above 1 would not work**: 04B2 leaves the address at the last projected vertex's z + 1
(it reads the reciprocal table in page 1 through /SIMCLK at 04C2 and /SIMBUF at 04C5/04E1, then
restores /MP to the object's page at 04DD-04DE, but not /SIMCLK), and 01DF-01E3 jump back to
01A8 with no /SIMCLK write, so a record's second polygon would be read from the object's page at
that address after a front-facing first one. The ROM never uses it, and the encoder rejects it.

**Limits** the encoder checks: three 16-bit coordinates per point, 1 <= vertices <= 3FFFh and
1 <= normals <= 3FFFh (the counts are DO-loop counts loaded into CNTR at 014D and 015F; the
ADSP-2100's counter is 14 bits, so a larger count would be truncated, and a count of 0 does not
skip the loop: MAME runs the body once, 2100ops.hxx `slow_condition` and the `& 0x3fff` of every
CNTR load; HYP for the hardware), types 1-15, colours 0-63, every face with at
least one vertex, object numbers below 1000h (0056: `AND 0FFF`), every object inside its page.
The largest object has 269 points (213), so its transformed points end at DM 010D + 3 × 269 =
0434, below the other DM variables at 08DA up (HYP: the real limit; not probed).

## 5. Everything else in the 384 KB

### 5.1 The reciprocal table, page 1 words 0000-7FFF (CODE)

`project_vertices` (04B2) sets /MP = 1 and /SIMCLK = z for every vertex it projects, and reads
one word: for z > 200h it multiplies x and y by it directly (04C4-04C9), for z <= 200h it shifts
the products left by 9 (04E0-04E9). The table is exactly

    t(z) = int(f32(f32(K / z) + 0.5)),  K = 2^15 for 1 <= z <= 200h, 2^24 for 200h < z < 7FFF
    t(0) = t(7FFF) = 0

where f32 rounds to IEEE single precision: a plain round() differs at five z (2F1h, AC9h, FD3h,
205Bh, 2F79h), whose quotients lie just below n + 0.5 and round up in float32. `reciprocal()` in
tools/objects generates it and the decoder checks all 32,768 words against it, so the table is
not stored in data/objects. **MAME**: every reciprocal read in the traces has page 1 and z in
0064-4E2E.

### 5.2 The checksum words (HYP for their purpose; the rule is checked on all six chips)

After the last object of each page, at the next multiple of 4 (0:F8F8, 1:FF40, 2:4D80), one
word whose high byte makes the byte sum of the page's even chip, and its low byte that of the
odd chip, modulo 256, equal the last two digits of the chip's part number read as hex: 136070-
**2121**.90h sums to 21h, -**2118**.90k to 18h, -**2122**.10h to 22h, -**2119**.10k to 19h,
-**2120**.9h to 20h, -**2117**.9k to 17h. Six chips matching by chance has odds of 256^-6. No
code reads these words (HYP: Atari's ROM checksum convention, checked by a factory tester; the
self-test cannot read the object ROMs except through the ADSP).

### 5.3 The residue word 0:019E

The word after the directory's FFFF, in what would otherwise be the directory's zero padding,
is not zero and nothing reads it: the ADSP reads directory words only at object numbers
0-412, and no structure points at it. Its value interpreted as a directory pointer lands inside
object 30's polygons (on an FFFF), and it matches no count or sum of the directory or the
objects that was tried (sums, XOR, point, face and object counts per page). It stays a residue:
`data/objects/manifest.json` lists its position, never its value, and the generated assembly
takes it from the ROM image with an incbin slice of 2 bytes (`residue_0_019E` in `make
coverage`). Card for Jesus in the M3a report. Because the checksum word of page 0 covers it,
the page-0 chips (90h, 90k) can only be rebuilt with the ROM image present.

### 5.4 The map of all 196,608 words

| Range | Words | What |
|---|---:|---|
| 0:0000-019C | 413 | directory |
| 0:019D | 1 | FFFF, the directory's end |
| 0:019E | 1 | residue (5.3) |
| 0:019F | 1 | zero padding |
| 0:01A0-F8F7 | 62,924 + 396 padding | 221 objects |
| 0:F8F8 | 1 | checksum word |
| 0:F8F9-FFFF | 1,799 | zero |
| 1:0000-7FFF | 32,768 | reciprocal table |
| 1:8000-FF3F | 32,375 + 201 padding | 107 objects |
| 1:FF40 | 1 | checksum word |
| 1:FF41-FFFF | 191 | zero |
| 2:0000-4D7F | 19,651 + 189 padding | 85 objects |
| 2:4D80 | 1 | checksum word |
| 2:4D81-FFFF | 45,695 | zero |

"Padding" is the zero words between objects (and before each page's checksum word) up to the
next multiple of 4. The decoder rebuilds every word from the format alone except the residue
word, and checks that it reproduces the image (`decode()` re-encodes and compares).

## 6. The inventory

413 objects, numbered by their directory index (= entry words 0/1 = descriptor +0/+2). The
names are **provisional** (HYP): they come from the shape of the decoded geometry (looked at in
scratch wireframes, not committed: the viewer is M3c), from the descriptor pairs (far LOD
objects) and from the traces; M3c renders them and refines the names, M5 ties them to the game's
entities. Families:

| Objects | Provisional family | Evidence |
|---|---|---|
| 0-10 | shapes of the eight vehicle entities and their variants | descriptors 0-10 (radius 1131), bound to the vehicle entities at 0x0254A4-0x02561A; 0, 7, 9, 10 have craft-like geometry |
| 11-47 | craft (22-25, 30-31, 39-40), panels, wedges, boxes, slabs | geometry; LOD pairs 11/12, 13/14, 15/16, 22/23, 24/25, 30/31 |
| 48-99, 128-129, 194-196, 350-352 | tunnel sections (open cylinders, straight, curved, tapered, with openings) | geometry; 30 loaded in at least one run (18 in both: 62-63, 68-69 and 86-93 in one only), 30 never loaded (54-55, 58-59, 64-67, 70-85, 194-196, 350-352; section 10's run column); near/far pairs such as 48/49, 60/61, 62/63 in the MAME list dump |
| 74-77, 134-161 | tunnel sections with a second set of colours | geometry, colours |
| 100-121, 197 | flat track sections (108-109 forks) | geometry |
| 122-127 | tunnel mouth, half-pipe, a structure with openings | geometry |
| 162-193 | striped tunnel sections (HYP: the map's "construction") | geometry: orange stripes over the tunnel shape |
| 198-203 | arrow signs, the words "STATION" and "CAUTION" | geometry (letters readable in the faces) |
| 204-209 | an iris ring in six steps (from a full disc to a thin ring) | geometry; descriptor 7Bh + n (0x031D68) |
| 210-249 | rings, arches, pillars, coils, lamp posts, a striped strip, flat pieces, lines, explosion fragments (230-237), rods, craft-like shapes | geometry |
| 250-310 | wings, explosion debris (253-265), domes, discs, shards, winged craft (292-297), blobs, streaks, bolts | geometry; 252, 292, 301, 302, 306, 309 selected by constant descriptors (section 3.2) |
| 311-330 | targets and concentric oval rings (HYP: shockwaves) | geometry |
| 331-349 | craft with arms, panels, bolts, a star disc, lines, bombs, zigzags | geometry |
| 353-363 | coloured panels with type-1 faces | geometry, type 1 |
| 364-367 | bursts | geometry |
| 368-393 | the letters A to Z | geometry (one letter per object, in order) |
| 394-412 | triangles | geometry |

The traces loaded 174 objects (137 in attract mode, 115 in the game, 78 in both); the 239 never
loaded are marked `-` in the run column of section 10 and listed in `artifacts/objtrace-summary.json`.
A run that reached later levels would load more; every one of the 413 is the near or far
object of a populated descriptor.

Columns of the table in section 10: address = word within the page; x, y, z = the vertices' bounding box (object units);
descriptor = the descriptors naming the object as near (n) or far (nf); run = loaded in the
attract (A) or play (P) trace.


## 7. The MAME proof: every object-ROM read (MAME)

`make objtrace` runs `tools/mame/objtrace.lua` twice: attract mode for 3,600 frames, and a game
(coin at frame 900, start at 960, trigger at 1020, as `tools/mame/pcwatch.lua`) for 7,200
frames; snapshots of the second run show the race on screen from frame 2,400 (scratch, not
committed). The script taps DM 2000-2007 of the ADSP's data space (a write tap on the range, a
read tap on 2000; taps observe and do not read the I/O) and cuts the accesses into sequences: a
/SIMCLK write starts one, the /SIMBUF reads until the next /SIMCLK write belong to it. Per
sequence it keeps the PC of the /SIMCLK write, the /MP page at its first read, the start address
and the number of words read, aggregated as "pc page address reads count" in
`build/mame/objtrace-{attract,play}.txt`. It never records a ROM word. The run stops at a frame
boundary, where the ADSP is usually inside a sequence (both runs: `# open_at_end 1`): that last
sequence may be cut short, so the script drops it instead of recording it, and it is not in the
counts below.

Both runs start from the factory state: `make objtrace` gives each its own empty NVRAM and cfg
directories under `build/mame/state-<run>/` (the play run depends on the NVRAM it starts from;
a play run from a copy of the archive NVRAM that `~/.mame/mame.ini` names gave 3,289,155
sequences and 127 objects, also with 0 problems). From that state the trace is deterministic: two consecutive `make
objtrace` runs wrote the same summary. The numbers below assume an empty NVRAM.

`tools/test_objects.py::test_mame_trace_matches_decoder` (skips without the traces) asserts,
for both runs, that every sequence starts where the decoder has a structure of the kind its PC
reads and reads exactly as many words as the decoder says:

| PC | Kind | Must start at | Words |
|---|---|---|---|
| 009E | directory | page 0, an object number 0-412 | 1 |
| 00A8 | header | an object's first word | 4 + 3 (vertices + normals) |
| 017B | record | a record of that object (the end record included) | 2; for a colour-0 face 2 + the words up to and including the next FFFF |
| 01A7 | polygon | the polygon of a face with colour > 0 | vertices + 2 |
| 04C2 | reciprocal | page 1, z in 0001-7FFE | 1 |

and that no /MP write falls between two reads of one sequence and no read precedes the first
/SIMCLK write. Result (`tools/objects trace --summary artifacts/objtrace-summary.json`, the last step of `make objtrace`):

| Run | Frames | Sequences | Directory | Header | Record | Polygon | Reciprocal | Objects loaded |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| attract | 3,600 | 1,036,283 | 13,914 | 13,914 | 238,982 | 225,070 | 544,403 | 137 |
| play | 7,200 | 3,113,316 | 45,086 | 45,086 | 728,772 | 683,506 | 1,610,866 | 115 |

**0 problems**: every one of the 4,149,599 sequences starts at a structure the decoder knows
and reads exactly its length (the trace holds no word values; `make check` proves those), over 3,289 distinct
record starts and 3,109 distinct polygon starts, the colour-0 faces of object 87 included (the
other colour-0 objects, 179, 193, 195 and 197, were not loaded); reciprocal reads use z
0064-4E2E. 174 objects were loaded, 239 never (they are in
the summary's `objects_never_loaded`). The test fails on a planted difference:
`test_trace_check_catches_planted_problems` feeds the checker a sequence one word too long, one
at a non-structure, a reciprocal read at z = 0 and an orphan read, and gets four problems.

## 8. data/objects, the tools and the build

### 8.1 The mesh files

`data/objects/NNN.json`, one per object, integers exactly as in the ROM:

```
{
  "object": 3,
  "vertices": [ [x, y, z], ... ],        signed 16-bit, object space
  "normals": [ [x, y, z], ... ],         signed 16-bit, typically of length about 4000h
  "faces": [
    {"type": 15, "colour": 7, "normal": 0, "vertices": [5, 4, 0, 1]}, ...
  ]
}
```

Indices are 0-based into `vertices` and `normals`; faces are in ROM order (record order = polygon
order). Everything else is derived when encoding: the point count, the point numbers (vertex
i + 1, normal nv + j + 1), the record-list pointer, the polygon addresses, the end record, the
FFFF terminators, the padding, the directory, the reciprocal table and the checksum words.

`data/objects/manifest.json` holds the format name, the object count, per page the chips and the
object numbers in address order (the placement: each page packs its objects in that order at
the first multiple of 4 after the page's fixed part), the reciprocal table's rule, the residue
ranges (position and length, never values) and the provisional names. A person edits a vertex,
a colour or a face in a mesh file, or moves an object to another page in the manifest; the
encoder re-places everything.

### 8.2 tools/objects

`tools/objects/__init__.py` is the format (decoder, encoder, generated assembly, the trace
check); `tools/objects` the CLI:

| Command | What |
|---|---|
| `decode` (`make objects`) | reads `build/stunrun-obj.bin` the way the ADSP does and writes data/objects; keeps the names of the existing manifest (read from the manifest alone, so an invalid mesh file does not lose them) and refuses to overwrite a manifest that does not parse; fails where the image is not the format |
| `asm` (`make`) | writes `build/obj/page0.asm`-`page2.asm` from data/objects |
| `encode` | writes the image itself (tests, experiments) |
| `inventory` | prints the table of section 10 |
| `trace` | checks the traces against the decoder; with `--summary FILE` (as `make objtrace` runs it) also writes their summary, `artifacts/objtrace-summary.json` |

The decoder is strict: a header count that is not vertices + normals, a record list that does
not follow the header, polygons out of record order, a count field, a face normal that is not a
normal point, a vertex that is not a vertex point, an object out of the packed layout, a page 1
that is not the reciprocal table, or a re-encoding that differs are errors. Non-zero words where
the format predicts zero padding become residue ranges.

### 8.3 The build

`asm/obj/objects.asm` includes the three generated page sources, with an assert at each page
boundary and at the end (60000h); each generated source has a label and an assert at every
structure (`object_NNN`, `object_directory`, `reciprocal_table`, `checksum_pageN`), `dc.w` for
every decoded word, `dcb.w n,0` for every zero run, and `incbin "../../build/stunrun-obj.bin"`
for the residue word. The page sources depend on data/objects, the tools and the image (which
supplies the residue word and, through it, page 0's checksum word). `make check`: 25 files,
0 differences.

`make coverage` counts the object image as `data` (296,270 bytes) and `fill` (96,944 bytes) under
the generated sources `../../build/obj/page{0,1,2}.asm`, and 2 bytes of blob (`residue_0_019E`):
the blob share of the set falls from 100.0% to 74.0%.

`make test` (tools/test_objects.py): synthetic objects through encode and decode on random
layouts, planted differences (one vertex word changes exactly that word and its page's checksum
word), residue handling, malformed images and mesh files rejected, the generated assembly
assembled by vasm equal to `encode()`; in CI, the committed data/objects encodes to the four
chips of pages 1 and 2 with the CRC-32 and SHA-1 MAME lists; with the reference set, decode
reproduces data/objects file for file and encode reproduces the image; with the traces, section
7. `tools/test_build.py` keeps `make all` on a synthetic set meaningful: the synthetic set
carries the object image the committed data encodes to (with a random residue word), `make all`
must rebuild it, and an edited mesh in the copy must change exactly two bytes of chip 90k.

## 9. Open questions

1. The residue word 0:019E (section 5.3): what wrote it? Card for Jesus.
2. Descriptor +10h (a long, 6000A0h for many) is not read by `fill_object_entry`; who reads it?
3. Entry word 22 (entity +36h) reaches DM 0027-0028; its reader is outside the object path
   (07B7 loads I3 = 0027: docs/08 or later).
4. Flags bit 15 and routine 0887 (an extra transform of the position, HYP).
5. Which game entity each descriptor is: M5 (the call sites of section 3.2 are the entry points).
6. Type 1 faces (objects 335, 353-363): what the 068B/0663 path does with them (docs/08).
7. The 239 objects no run loaded: later levels, the high-score screen (letters?), and the
   self-test; a longer or steered run would show which.

## 10. Inventory table

Generated by `tools/objects inventory` (with the descriptor and run columns added from the
68k table and `artifacts/objtrace-summary.json`).

| # | page | address | vertices | normals | faces | x | y | z | descriptor | run | provisional name |
|---:|---:|---|---:|---:|---:|---|---|---|---|---|---|
| 0 | 0 | 01A0 | 49 | 38 | 38 | -71..70 | 10..60 | -271..276 | 0 | AP | vehicle-slot shape |
| 1 | 0 | 03D4 | 12 | 16 | 20 | -87..-13 | 0..78 | -19..288 | 1 | AP | vehicle-slot shape |
| 2 | 0 | 04C4 | 12 | 16 | 20 | 12..86 | 0..78 | -19..288 | 2 | AP | vehicle-slot shape |
| 3 | 0 | 05B4 | 6 | 5 | 5 | -133..-69 | 28..34 | -189..-83 | 3 | AP | vehicle-slot shape |
| 4 | 0 | 0604 | 6 | 5 | 5 | 68..132 | 28..34 | -189..-83 | 4 | AP | vehicle-slot shape |
| 5 | 0 | 0654 | 18 | 18 | 18 | -133..-95 | 6..68 | -255..16 | 5 | AP | vehicle-slot shape |
| 6 | 0 | 0754 | 18 | 18 | 18 | 94..132 | 6..68 | -255..16 | 6 | AP | vehicle-slot shape |
| 7 | 0 | 0854 | 122 | 26 | 46 | -27..26 | 54..98 | -161..92 | 7 | AP | vehicle-slot shape |
| 8 | 2 | 0000 | 32 | 20 | 20 | -71..0 | 10..60 | -271..-19 | 8 | P | vehicle-slot shape |
| 9 | 2 | 0140 | 32 | 20 | 20 | 0..70 | 10..60 | -271..-19 | 9 | P | vehicle-slot shape |
| 10 | 2 | 0280 | 32 | 17 | 21 | -49..48 | 10..50 | -157..276 | 10 | P | vehicle-slot shape |
| 11 | 0 | 0B90 | 54 | 29 | 30 | -251..250 | 0..274 | -563..562 | 11 | AP | panel or slab |
| 12 | 0 | 0D80 | 20 | 8 | 8 | -251..250 | 0..274 | -563..562 | 11f | AP | panel or slab (far LOD of 11, descriptor 11) |
| 13 | 0 | 0E1C | 32 | 10 | 12 | -251..250 | 0..274 | -563..562 | 12 | AP | panel or slab |
| 14 | 0 | 0F04 | 20 | 8 | 8 | -251..250 | 0..274 | -563..562 | 12f | AP | panel or slab (far LOD of 13, descriptor 12) |
| 15 | 0 | 0FA0 | 19 | 14 | 14 | -251..250 | 0..274 | -837..-563 | 13 | AP | panel or slab |
| 16 | 0 | 1078 | 6 | 1 | 1 | -251..250 | 0..274 | -563..-563 | 13f | AP | panel or slab (far LOD of 15, descriptor 13) |
| 17 | 0 | 10A0 | 6 | 5 | 5 | -125..124 | -21..18 | -93..84 | 14 | A | panel or slab |
| 18 | 0 | 10F0 | 6 | 5 | 5 | -21..26 | -21..22 | -289..308 | 15 | A | panel or slab |
| 19 | 0 | 1140 | 6 | 5 | 5 | -41..26 | -37..36 | -167..130 | 16 | A | panel or slab |
| 20 | 0 | 1190 | 4 | 4 | 4 | -71..86 | -71..90 | -63..60 | 17 | A | panel or slab |
| 21 | 0 | 11CC | 17 | 7 | 8 | -139..110 | -25..24 | -145..136 | 18 | A | panel or slab |
| 22 | 0 | 1258 | 76 | 63 | 70 | -269..268 | 0..180 | -445..544 | 19 | AP | craft |
| 23 | 0 | 1618 | 55 | 28 | 37 | -281..280 | 0..180 | -461..576 | 19f | - | craft (far LOD of 22, descriptor 19) |
| 24 | 0 | 1838 | 39 | 33 | 33 | -103..102 | 0..204 | -451..410 | 20 | A | craft |
| 25 | 0 | 1A18 | 12 | 10 | 10 | -91..90 | 0..156 | -405..390 | 20f | - | craft (far LOD of 24, descriptor 20) |
| 26 | 0 | 1AA8 | 4 | 4 | 4 | -37..36 | -27..14 | -109..68 | 21 | A | wedge |
| 27 | 0 | 1AE4 | 4 | 4 | 4 | -37..42 | -31..62 | -127..84 | 22 | A | wedge |
| 28 | 0 | 1B20 | 8 | 6 | 6 | -21..46 | -41..60 | -123..104 | 23 | A | wedge |
| 29 | 0 | 1B80 | 6 | 5 | 5 | -37..36 | -59..42 | -51..78 | 24 | A | wedge |
| 30 | 0 | 1BD0 | 67 | 58 | 59 | -361..360 | 0..312 | -665..666 | 25 | A | craft |
| 31 | 0 | 1F10 | 30 | 22 | 22 | -363..362 | 0..312 | -665..666 | 25f | A | craft (far LOD of 30, descriptor 25) |
| 32 | 0 | 205C | 6 | 5 | 5 | -71..62 | -31..24 | -249..252 | 26 | A | box |
| 33 | 0 | 20AC | 6 | 5 | 5 | -71..30 | -67..66 | -223..278 | 27 | A | box |
| 34 | 0 | 20FC | 6 | 5 | 5 | -55..66 | -41..56 | -195..230 | 28 | A | box |
| 35 | 0 | 214C | 4 | 4 | 4 | -61..48 | -35..58 | -75..54 | 29 | A | wedge |
| 36 | 0 | 2188 | 4 | 4 | 4 | -45..76 | -89..20 | -73..60 | 30 | A | wedge |
| 37 | 0 | 21C4 | 4 | 4 | 4 | -101..130 | -45..48 | -113..68 | 31 | A | wedge |
| 38 | 0 | 2200 | 10 | 5 | 5 | -141..140 | -83..76 | -91..100 | 32 | A | wedge |
| 39 | 0 | 225C | 54 | 52 | 52 | -281..280 | 0..320 | -869..864 | 33 | A | craft |
| 40 | 0 | 2534 | 35 | 15 | 16 | -217..216 | 0..300 | -639..694 | 33f | A | craft (far LOD of 39, descriptor 33) |
| 41 | 0 | 2650 | 10 | 5 | 5 | -53..132 | -19..34 | -195..282 | 34 | A | slab or wedge |
| 42 | 0 | 26AC | 7 | 7 | 7 | -139..138 | -49..68 | -59..38 | 35 | A | slab or wedge |
| 43 | 0 | 2710 | 8 | 7 | 7 | -133..132 | -37..52 | -109..132 | 36 | A | slab or wedge |
| 44 | 0 | 277C | 27 | 8 | 9 | -33..16 | -27..42 | -231..302 | 37 | A | slab or wedge |
| 45 | 0 | 2834 | 10 | 8 | 9 | -51..46 | -53..84 | -461..604 | 38 | A | slab or wedge |
| 46 | 0 | 28B8 | 8 | 6 | 6 | -81..80 | -21..20 | -461..360 | 39 | A | slab or wedge |
| 47 | 0 | 2918 | 4 | 4 | 4 | -81..80 | -21..20 | -239..238 | 40 | A | slab or wedge |
| 48 | 0 | 2954 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 41 | AP | tunnel section |
| 49 | 0 | 2AA0 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 41f | AP | tunnel section (far LOD of 48, descriptor 41) |
| 50 | 0 | 2B40 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3304..3304 | 42 | AP | tunnel section |
| 51 | 0 | 2C8C | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3307..3307 | 42f | AP | tunnel section (far LOD of 50, descriptor 42) |
| 52 | 0 | 2D2C | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3304..3304 | 43 | AP | tunnel section |
| 53 | 0 | 2E78 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3415..3200 | 43f | AP | tunnel section (far LOD of 52, descriptor 43) |
| 54 | 0 | 2F18 | 38 | 19 | 19 | -1600..1600 | -1560..1561 | -3241..3186 | 44 | - | tunnel section |
| 55 | 0 | 3064 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3214..3214 | 44f | - | tunnel section (far LOD of 54, descriptor 44) |
| 56 | 0 | 3104 | 38 | 19 | 19 | -1600..1600 | -1552..1570 | -3404..3132 | 45 | AP | tunnel section |
| 57 | 0 | 3250 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3272..3272 | 45f | AP | tunnel section (far LOD of 56, descriptor 45) |
| 58 | 0 | 32F0 | 38 | 19 | 19 | -1600..1600 | -1561..1560 | -3241..3186 | 46 | - | tunnel section |
| 59 | 0 | 343C | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3214..3214 | 46f | - | tunnel section (far LOD of 58, descriptor 46) |
| 60 | 0 | 34DC | 38 | 19 | 19 | -1600..1600 | -1570..1552 | -3404..3132 | 47 | AP | tunnel section |
| 61 | 0 | 3628 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3272..3272 | 47f | AP | tunnel section (far LOD of 60, descriptor 47) |
| 62 | 0 | 36C8 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3323..3323 | 48 | A | tunnel section |
| 63 | 0 | 3814 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3323..3323 | 48f | A | tunnel section (far LOD of 62, descriptor 48) |
| 64 | 0 | 38B4 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3323..3323 | 49 | - | tunnel section |
| 65 | 0 | 3A00 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3323..3323 | 49f | - | tunnel section (far LOD of 64, descriptor 49) |
| 66 | 0 | 3AA0 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3327..3327 | 50 | - | tunnel section |
| 67 | 0 | 3BEC | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3345..3345 | 50f | - | tunnel section (far LOD of 66, descriptor 50) |
| 68 | 0 | 3C8C | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3327..3327 | 51 | A | tunnel section |
| 69 | 0 | 3DD8 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3345..3345 | 51f | A | tunnel section (far LOD of 68, descriptor 51) |
| 70 | 0 | 3E78 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3307..3307 | 52 | - | tunnel section |
| 71 | 0 | 3FC4 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3309..3309 | 52f | - | tunnel section (far LOD of 70, descriptor 52) |
| 72 | 0 | 4064 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3307..3307 | 53 | - | tunnel section |
| 73 | 0 | 41B0 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3417..3200 | 53f | - | tunnel section (far LOD of 72, descriptor 53) |
| 74 | 0 | 4250 | 38 | 19 | 19 | -1200..1200 | -1170..1170 | -3200..3200 | 54 | - | tunnel section, second colour set |
| 75 | 0 | 439C | 18 | 9 | 9 | -1235..1235 | -1233..1233 | -3200..3200 | 54f | - | tunnel section, second colour set (far LOD of 74, descriptor 54) |
| 76 | 0 | 443C | 38 | 19 | 19 | -800..800 | -780..780 | -3200..3200 | 55 | - | tunnel section, second colour set |
| 77 | 0 | 4588 | 18 | 9 | 9 | -823..823 | -781..864 | -6400..0 | 55f | - | tunnel section, second colour set (far LOD of 76, descriptor 55) |
| 78 | 0 | 4628 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 56 | - | tunnel section |
| 79 | 0 | 4774 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 56f | - | tunnel section (far LOD of 78, descriptor 56) |
| 80 | 0 | 4814 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 57 | - | tunnel section |
| 81 | 0 | 4960 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 57f | - | tunnel section (far LOD of 80, descriptor 57) |
| 82 | 0 | 4A00 | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 58 | - | tunnel section |
| 83 | 0 | 4B4C | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 58f | - | tunnel section (far LOD of 82, descriptor 58) |
| 84 | 0 | 4BEC | 38 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 59 | - | tunnel section |
| 85 | 0 | 4D38 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 59f | - | tunnel section (far LOD of 84, descriptor 59) |
| 86 | 1 | 8000 | 38 | 23 | 23 | -1600..1600 | -1561..1561 | -3200..3200 | 60 | P | tunnel section |
| 87 | 1 | 8170 | 18 | 11 | 11 | -1647..1647 | -1561..1728 | -3200..3200 | 60f | P | tunnel section (far LOD of 86, descriptor 60) |
| 88 | 1 | 8224 | 36 | 22 | 22 | -1600..1600 | -1562..1483 | -3204..3196 | 61 | P | tunnel section |
| 89 | 1 | 837C | 18 | 12 | 12 | -1647..1647 | -1561..1728 | -3202..3200 | 61f | P | tunnel section (far LOD of 88, descriptor 61) |
| 90 | 1 | 8438 | 24 | 18 | 18 | -1600..1600 | -1560..980 | -3201..3201 | 62 | P | tunnel section |
| 91 | 1 | 8540 | 15 | 8 | 8 | -1647..1647 | -1561..976 | -3202..3200 | 62f | P | tunnel section (far LOD of 90, descriptor 62) |
| 92 | 1 | 85CC | 15 | 12 | 12 | -1600..1600 | -1562..464 | -3200..3200 | 63 | P | tunnel section |
| 93 | 1 | 867C | 10 | 8 | 8 | -1647..1647 | -1560..466 | -3200..3201 | 63f | P | tunnel section (far LOD of 92, descriptor 63) |
| 94 | 1 | 86F4 | 52 | 27 | 27 | -1599..3194 | -1567..1567 | -3409..3236 | 64 | AP | tunnel section |
| 95 | 1 | 88B8 | 24 | 15 | 15 | -1713..3140 | -1557..1724 | -3408..3193 | 64f | AP | tunnel section (far LOD of 94, descriptor 64) |
| 96 | 1 | 89A8 | 40 | 19 | 19 | -1600..1600 | -1561..1561 | -3254..3254 | 65 | AP | tunnel section |
| 97 | 1 | 8AFC | 20 | 9 | 9 | -1659..1643 | -1569..1736 | -3523..3005 | 65f | AP | tunnel section (far LOD of 96, descriptor 65) |
| 98 | 1 | 8BA4 | 40 | 19 | 19 | -1600..1600 | -1561..1561 | -3254..3254 | 66 | AP | tunnel section |
| 99 | 1 | 8CF8 | 20 | 9 | 9 | -1633..1661 | -1561..1728 | -3519..3014 | 66f | AP | tunnel section (far LOD of 98, descriptor 66) |
| 100 | 0 | 4DD8 | 28 | 5 | 15 | -1632..1632 | -1561..-1401 | -3200..3200 | 67 | AP | flat track section |
| 101 | 0 | 4EBC | 8 | 3 | 5 | -1600..1600 | -1561..-1433 | -3200..3200 | 67f | AP | flat track section (far LOD of 100, descriptor 67) |
| 102 | 0 | 4F0C | 28 | 5 | 11 | -526..526 | -1561..-1401 | -3200..3200 | 68 | AP | flat track section |
| 103 | 0 | 4FD0 | 8 | 3 | 5 | -494..494 | -1561..-1433 | -3200..3200 | 68f | AP | flat track section (far LOD of 102, descriptor 68) |
| 104 | 0 | 5020 | 28 | 8 | 11 | -1632..1632 | -1561..-1401 | -3200..3200 | 69 | AP | flat track section |
| 105 | 0 | 50EC | 8 | 5 | 5 | -1600..1600 | -1561..-1433 | -3200..3200 | 69f | AP | flat track section (far LOD of 104, descriptor 69) |
| 106 | 0 | 5144 | 28 | 8 | 11 | -1632..1632 | -1561..-1401 | -3200..3200 | 70 | AP | flat track section |
| 107 | 0 | 5210 | 8 | 5 | 5 | -1600..1600 | -1561..-1433 | -3200..3200 | 70f | AP | flat track section (far LOD of 106, descriptor 70) |
| 108 | 1 | 8DA0 | 48 | 19 | 33 | -526..2158 | -1561..48 | -3224..3312 | 71 | - | flat track fork |
| 109 | 1 | 8F74 | 19 | 11 | 14 | -495..2127 | -1561..48 | -3223..3312 | 71f | - | flat track fork (far LOD of 108, descriptor 71) |
| 110 | 1 | 9044 | 28 | 9 | 14 | -526..526 | -1561..-1401 | -3254..3214 | 72 | - | flat track section |
| 111 | 1 | 912C | 8 | 5 | 7 | -494..494 | -1561..-1433 | -3254..3210 | 72f | - | flat track section (far LOD of 110, descriptor 72) |
| 112 | 1 | 9194 | 30 | 9 | 20 | -526..526 | -1561..-1401 | -3255..3214 | 73 | - | flat track section |
| 113 | 1 | 92B0 | 10 | 5 | 11 | -494..494 | -1561..-1433 | -3255..3210 | 73f | - | flat track section (far LOD of 112, descriptor 73) |
| 114 | 0 | 5268 | 12 | 5 | 7 | -1632..1632 | -1561..-1401 | -3413..3200 | 74 | P | flat track section |
| 115 | 0 | 52DC | 8 | 3 | 5 | -1600..1600 | -1561..-1433 | -3409..3200 | 74f | P | flat track section (far LOD of 114, descriptor 74) |
| 116 | 0 | 532C | 12 | 5 | 7 | -1632..1632 | -1561..-1401 | -3413..3200 | 75 | P | flat track section |
| 117 | 0 | 53A0 | 8 | 3 | 5 | -1600..1600 | -1561..-1433 | -3409..3200 | 75f | P | flat track section (far LOD of 116, descriptor 75) |
| 118 | 0 | 53F0 | 28 | 9 | 14 | -526..526 | -1561..-1401 | -3214..3254 | 76 | - | flat track section |
| 119 | 0 | 54D8 | 8 | 5 | 7 | -494..494 | -1561..-1433 | -3210..3254 | 76f | - | flat track section (far LOD of 118, descriptor 76) |
| 120 | 0 | 5540 | 30 | 9 | 19 | -526..526 | -1561..-1401 | -3214..3255 | 77 | - | flat track section |
| 121 | 0 | 5654 | 10 | 5 | 11 | -494..494 | -1561..-1433 | -3210..3255 | 77f | - | flat track section (far LOD of 120, descriptor 77) |
| 122 | 1 | 933C | 57 | 37 | 37 | -1600..1600 | -1561..1561 | -3200..3200 | 78 | AP | tunnel mouth |
| 123 | 1 | 9584 | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 78f | AP | tunnel mouth (far LOD of 122, descriptor 78) |
| 124 | 1 | 9624 | 57 | 37 | 37 | -1681..1681 | -1640..1640 | -3357..3200 | 79 | AP | half-pipe section |
| 125 | 1 | 986C | 18 | 9 | 9 | -1647..1647 | -1561..1728 | -3200..3200 | 79f | AP | half-pipe section (far LOD of 124, descriptor 79) |
| 126 | 0 | 56E0 | 152 | 22 | 64 | -3200..3200 | -2560..2560 | -3200..3200 | 80 | P | structure with openings |
| 127 | 0 | 5AE8 | 157 | 21 | 60 | -3200..3200 | -2560..2560 | -3200..3200 | 81 | - | structure with openings |
| 128 | 0 | 5EE4 | 43 | 27 | 27 | -1600..1600 | -1561..1873 | -3200..3203 | 82 | AP | tunnel section |
| 129 | 0 | 6090 | 23 | 12 | 13 | -1647..1647 | -1561..2041 | -3200..3200 | 82f | AP | tunnel section (far LOD of 128, descriptor 82) |
| 130 | 1 | 990C | 5 | 4 | 4 | -1760..1760 | -1760..1760 | 0..6400 | 83 | - | large panel |
| 131 | 1 | 994C | 10 | 9 | 9 | -1647..1647 | -1561..1728 | 0..6400 | 83f | AP | large panel (far LOD of 130, descriptor 83) |
| 132 | 0 | 6168 | 22 | 9 | 9 | -800..800 | 0..659 | -1611..1575 | 84 | A | ramp or flat |
| 133 | 0 | 6214 | 4 | 1 | 1 | -494..494 | 0..501 | -1586..1575 | 84f | A | ramp or flat (far LOD of 132, descriptor 84) |
| 134 | 0 | 6234 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3200..3200 | 85 | - | tunnel section, second colour set |
| 135 | 0 | 6380 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3200..3200 | 85f | - | tunnel section, second colour set (far LOD of 134, descriptor 85) |
| 136 | 0 | 6420 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3200..3200 | 86 | - | tunnel section, second colour set |
| 137 | 0 | 656C | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3200..3200 | 86f | - | tunnel section, second colour set (far LOD of 136, descriptor 86) |
| 138 | 0 | 660C | 38 | 19 | 19 | -800..800 | -780..780 | -3304..3200 | 87 | - | tunnel section, second colour set |
| 139 | 0 | 6758 | 18 | 9 | 9 | -823..823 | -780..864 | -3307..3200 | 87f | - | tunnel section, second colour set (far LOD of 138, descriptor 87) |
| 140 | 0 | 67F8 | 38 | 19 | 19 | -800..800 | -780..780 | -3304..3200 | 88 | - | tunnel section, second colour set |
| 141 | 0 | 6944 | 18 | 9 | 9 | -823..823 | -780..864 | -3307..3200 | 88f | - | tunnel section, second colour set (far LOD of 140, descriptor 88) |
| 142 | 0 | 69E4 | 38 | 19 | 19 | -800..800 | -780..780 | -3214..3200 | 89 | - | tunnel section, second colour set |
| 143 | 0 | 6B30 | 18 | 9 | 9 | -823..823 | -780..864 | -3214..3200 | 89f | - | tunnel section, second colour set (far LOD of 142, descriptor 89) |
| 144 | 0 | 6BD0 | 38 | 19 | 19 | -800..800 | -780..780 | -3268..3200 | 90 | - | tunnel section, second colour set |
| 145 | 0 | 6D1C | 18 | 9 | 9 | -823..823 | -780..864 | -3272..3200 | 90f | - | tunnel section, second colour set (far LOD of 144, descriptor 90) |
| 146 | 0 | 6DBC | 38 | 19 | 19 | -800..800 | -780..780 | -3214..3200 | 91 | - | tunnel section, second colour set |
| 147 | 0 | 6F08 | 18 | 9 | 9 | -823..823 | -780..864 | -3214..3200 | 91f | - | tunnel section, second colour set (far LOD of 146, descriptor 91) |
| 148 | 0 | 6FA8 | 38 | 19 | 19 | -800..800 | -780..780 | -3268..3200 | 92 | - | tunnel section, second colour set |
| 149 | 0 | 70F4 | 18 | 9 | 9 | -823..823 | -780..864 | -3272..3200 | 92f | - | tunnel section, second colour set (far LOD of 148, descriptor 92) |
| 150 | 0 | 7194 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3357..3200 | 93 | - | tunnel section, second colour set |
| 151 | 0 | 72E0 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3361..3200 | 93f | - | tunnel section, second colour set (far LOD of 150, descriptor 93) |
| 152 | 0 | 7380 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3357..3200 | 94 | - | tunnel section, second colour set |
| 153 | 0 | 74CC | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3361..3200 | 94f | - | tunnel section, second colour set (far LOD of 152, descriptor 94) |
| 154 | 0 | 756C | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3220..3200 | 95 | - | tunnel section, second colour set |
| 155 | 0 | 76B8 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3222..3200 | 95f | - | tunnel section, second colour set (far LOD of 154, descriptor 95) |
| 156 | 0 | 7758 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3302..3200 | 96 | - | tunnel section, second colour set |
| 157 | 0 | 78A4 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3307..3200 | 96f | - | tunnel section, second colour set (far LOD of 156, descriptor 96) |
| 158 | 1 | 99CC | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3220..3200 | 97 | - | tunnel section, second colour set |
| 159 | 1 | 9B18 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3222..3200 | 97f | - | tunnel section, second colour set (far LOD of 158, descriptor 97) |
| 160 | 1 | 9BB8 | 38 | 19 | 19 | -1200..1200 | -1171..1171 | -3302..3200 | 98 | - | tunnel section, second colour set |
| 161 | 1 | 9D04 | 18 | 9 | 9 | -1235..1235 | -1171..1296 | -3307..3200 | 98f | - | tunnel section, second colour set (far LOD of 160, descriptor 98) |
| 162 | 0 | 7944 | 72 | 18 | 18 | -1595..1595 | -1561..1558 | -3200..3200 | 99 | - | striped tunnel section (HYP: construction) |
| 163 | 0 | 7AE8 | 72 | 18 | 18 | -1595..1595 | -1561..1558 | -3200..3200 | 99f | - | striped tunnel section (HYP: construction) (far LOD of 162, descriptor 99) |
| 164 | 0 | 7C8C | 80 | 20 | 20 | -1595..1595 | -1561..1558 | -3200..3200 | 100 | - | striped tunnel section (HYP: construction) |
| 165 | 0 | 7E60 | 80 | 20 | 20 | -1595..1595 | -1561..1558 | -3200..3200 | 100f | - | striped tunnel section (HYP: construction) (far LOD of 164, descriptor 100) |
| 166 | 0 | 8034 | 64 | 18 | 18 | -1595..1600 | -1561..1555 | -3200..3200 | 101 | - | striped tunnel section (HYP: construction) |
| 167 | 0 | 81C0 | 60 | 16 | 16 | -1595..1647 | -1561..1558 | -3200..3200 | 101f | - | striped tunnel section (HYP: construction) (far LOD of 166, descriptor 101) |
| 168 | 0 | 832C | 70 | 19 | 19 | -1595..1600 | -1561..1555 | -3200..3200 | 102 | - | striped tunnel section (HYP: construction) |
| 169 | 0 | 84D8 | 66 | 17 | 17 | -1595..1647 | -1561..1558 | -3200..3200 | 102f | - | striped tunnel section (HYP: construction) (far LOD of 168, descriptor 102) |
| 170 | 0 | 8660 | 54 | 18 | 18 | -1595..1600 | -1561..1561 | -3200..3200 | 103 | - | striped tunnel section (HYP: construction) |
| 171 | 0 | 87D0 | 44 | 13 | 13 | -1595..1647 | -1561..1728 | -3200..3200 | 103f | - | striped tunnel section (HYP: construction) (far LOD of 170, descriptor 103) |
| 172 | 0 | 88EC | 60 | 19 | 19 | -1595..1600 | -1561..1561 | -3200..3200 | 104 | - | striped tunnel section (HYP: construction) |
| 173 | 0 | 8A78 | 50 | 14 | 14 | -1595..1647 | -1561..1728 | -3200..3200 | 104f | - | striped tunnel section (HYP: construction) (far LOD of 172, descriptor 104) |
| 174 | 0 | 8BB0 | 44 | 18 | 18 | -1600..1600 | -1561..1561 | -3200..3200 | 105 | - | striped tunnel section (HYP: construction) |
| 175 | 0 | 8D00 | 32 | 11 | 11 | -1647..1647 | -1561..1728 | -3200..3200 | 105f | - | striped tunnel section (HYP: construction) (far LOD of 174, descriptor 105) |
| 176 | 0 | 8DE0 | 50 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 106 | - | striped tunnel section (HYP: construction) |
| 177 | 0 | 8F50 | 38 | 12 | 12 | -1647..1647 | -1561..1728 | -3200..3200 | 106f | - | striped tunnel section (HYP: construction) (far LOD of 176, descriptor 106) |
| 178 | 0 | 904C | 58 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 107 | - | striped tunnel section (HYP: construction) |
| 179 | 0 | 91D4 | 54 | 15 | 15 | -1647..1647 | -1561..1728 | -3200..3200 | 107f | - | striped tunnel section (HYP: construction) (far LOD of 178, descriptor 107) |
| 180 | 0 | 9324 | 50 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 108 | - | striped tunnel section (HYP: construction) |
| 181 | 0 | 9494 | 34 | 11 | 11 | -1647..1647 | -1561..1728 | -3200..3200 | 108f | - | striped tunnel section (HYP: construction) (far LOD of 180, descriptor 108) |
| 182 | 0 | 957C | 64 | 18 | 18 | -1600..1595 | -1561..1558 | -3200..3200 | 109 | - | striped tunnel section (HYP: construction) |
| 183 | 0 | 9708 | 60 | 16 | 16 | -1647..1595 | -1561..1558 | -3200..3200 | 109f | - | striped tunnel section (HYP: construction) (far LOD of 182, descriptor 109) |
| 184 | 0 | 9874 | 70 | 19 | 19 | -1600..1595 | -1561..1558 | -3200..3200 | 110 | - | striped tunnel section (HYP: construction) |
| 185 | 0 | 9A20 | 66 | 17 | 17 | -1647..1595 | -1561..1558 | -3200..3200 | 110f | - | striped tunnel section (HYP: construction) (far LOD of 184, descriptor 110) |
| 186 | 0 | 9BA8 | 56 | 18 | 18 | -1600..1600 | -1561..1555 | -3200..3200 | 111 | P | striped tunnel section (HYP: construction) |
| 187 | 0 | 9D1C | 48 | 14 | 14 | -1647..1647 | -1561..1558 | -3200..3200 | 111f | P | striped tunnel section (HYP: construction) (far LOD of 186, descriptor 111) |
| 188 | 0 | 9E4C | 60 | 18 | 18 | -1600..1600 | -1561..1558 | -3200..3200 | 112 | - | striped tunnel section (HYP: construction) |
| 189 | 0 | 9FCC | 52 | 14 | 14 | -1647..1647 | -1561..1558 | -3200..3200 | 112f | - | striped tunnel section (HYP: construction) (far LOD of 188, descriptor 112) |
| 190 | 0 | A108 | 54 | 18 | 18 | -1600..1595 | -1561..1561 | -3200..3200 | 113 | - | striped tunnel section (HYP: construction) |
| 191 | 0 | A278 | 44 | 13 | 13 | -1647..1595 | -1561..1728 | -3200..3200 | 113f | - | striped tunnel section (HYP: construction) (far LOD of 190, descriptor 113) |
| 192 | 0 | A394 | 60 | 19 | 19 | -1600..1595 | -1561..1561 | -3200..3200 | 114 | - | striped tunnel section (HYP: construction) |
| 193 | 0 | A520 | 50 | 14 | 14 | -1647..1595 | -1561..1728 | -3200..3200 | 114f | - | striped tunnel section (HYP: construction) (far LOD of 192, descriptor 114) |
| 194 | 0 | A658 | 44 | 18 | 18 | -1600..1600 | -1561..1561 | -3200..3200 | 115 | - | tunnel section |
| 195 | 0 | A7A8 | 32 | 11 | 11 | -1647..1647 | -1561..1728 | -3200..3200 | 115f | - | tunnel section (far LOD of 194, descriptor 115) |
| 196 | 0 | A888 | 50 | 19 | 19 | -1600..1600 | -1561..1561 | -3200..3200 | 116 | - | tunnel section |
| 197 | 0 | A9F8 | 38 | 12 | 12 | -1647..1647 | -1561..1728 | -3200..3200 | 116f | - | flat section (far LOD of 196, descriptor 116) |
| 198 | 1 | 9DA4 | 7 | 1 | 2 | -680..436 | -212..28 | 0..0 | 117 | P | arrow sign |
| 199 | 1 | 9DD4 | 7 | 1 | 2 | -436..680 | -212..28 | 0..0 | 118 | P | arrow sign |
| 200 | 1 | 9E04 | 14 | 1 | 4 | -616..616 | -170..10 | 1..1 | 119 | - | arrow sign |
| 201 | 1 | 9E58 | 14 | 1 | 4 | -632..632 | -170..10 | 1..1 | 120 | AP | arrow sign |
| 202 | 1 | 9EAC | 79 | 1 | 20 | -820..814 | -224..156 | 0..0 | 121 | P | "STATION" sign |
| 203 | 1 | A044 | 75 | 1 | 19 | -820..810 | -224..152 | 0..0 | 122 | AP | "CAUTION" sign |
| 204 | 1 | A1C8 | 28 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 123 | AP | iris ring, animation step |
| 205 | 1 | A270 | 35 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 124 | AP | iris ring, animation step |
| 206 | 1 | A32C | 35 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 125 | AP | iris ring, animation step |
| 207 | 1 | A3EC | 36 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 126 | AP | iris ring, animation step |
| 208 | 1 | A4AC | 35 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 127 | AP | iris ring, animation step |
| 209 | 1 | A56C | 35 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 128 | AP | iris ring, animation step |
| 210 | 1 | A62C | 34 | 1 | 8 | -1600..1600 | 0..3122 | 0..0 | 129 | AP | thin ring |
| 211 | 1 | A6E8 | 29 | 1 | 8 | -1600..1600 | 0..3105 | 0..0 | 130 | AP | thin ring |
| 212 | 1 | A788 | 27 | 1 | 19 | -3200..3200 | -999..4121 | 0..0 | 131 | P | octagonal ring |
| 213 | 1 | A870 | 215 | 54 | 132 | -5001..3750 | -2501..8000 | -1501..1500 | 132 | P | arch |
| 214 | 1 | AFB4 | 66 | 1 | 16 | -5001..3750 | -2501..8000 | -1701..-1601 | 132f | P | arch (far LOD of 213, descriptor 132) |
| 215 | 1 | B10C | 71 | 24 | 49 | -5701..-2551 | -2501..4500 | -1601..1550 | 133 | P | pillar or coil |
| 216 | 1 | B3B4 | 128 | 22 | 92 | 2500..5500 | -3001..4500 | -1501..1500 | 134 | P | pillar or coil |
| 217 | 1 | B84C | 42 | 13 | 21 | -5451..-4051 | -4101..3000 | -751..700 | 135 | P | pillar or coil |
| 218 | 1 | B9A0 | 94 | 30 | 45 | 3850..7050 | -4051..4700 | -1651..1550 | 136 | - | pillar or coil |
| 219 | 1 | BC80 | 168 | 18 | 90 | 5750..8750 | -3251..5250 | -1501..1500 | 137 | - | pillar or coil |
| 220 | 1 | C184 | 15 | 9 | 9 | -481..28 | -81..520 | -49..20 | 138 | AP | lamp post |
| 221 | 1 | C218 | 16 | 9 | 9 | -29..480 | -81..520 | -21..48 | 139 | AP | lamp post |
| 222 | 1 | C2B0 | 18 | 1 | 8 | -1600..1600 | 0..0 | -480..480 | 140 | P | striped strip |
| 223 | 1 | C330 | 4 | 1 | 1 | -250..250 | -2..2 | -800..800 | 141 | - | flat piece |
| 224 | 1 | C350 | 12 | 7 | 7 | -125..125 | 6..86 | -1056..1056 | 142 | - | flat piece |
| 225 | 1 | C3CC | 12 | 7 | 7 | -192..192 | 6..86 | -1056..1056 | 143 | - | flat piece |
| 226 | 1 | C448 | 12 | 7 | 7 | -250..250 | 6..80 | -1056..1056 | 144 | AP | flat piece |
| 227 | 1 | C4C4 | 6 | 1 | 1 | -501..501 | 0..0 | -1056..1056 | 145 | - | flat piece |
| 228 | 1 | C4EC | 9 | 2 | 4 | -25..24 | 0..0 | 100..1900 | 146 | AP | thin line |
| 229 | 1 | C530 | 6 | 2 | 4 | -21..28 | 0..0 | -2561..0 | 147 | AP | thin line |
| 230 | 1 | C56C | 72 | 24 | 24 | -101..80 | -65..102 | -69..2 | 148 | AP | explosion fragments |
| 231 | 1 | C73C | 34 | 1 | 13 | -105..90 | -69..118 | -3..8 | 148f | - | explosion fragments (far LOD of 230, descriptor 148) |
| 232 | 1 | C808 | 51 | 15 | 17 | -229..168 | -123..190 | -165..78 | 149 | AP | explosion fragments |
| 233 | 1 | C94C | 36 | 1 | 12 | -275..166 | -133..220 | -3..0 | 149f | - | explosion fragments (far LOD of 232, descriptor 149) |
| 234 | 1 | CA18 | 51 | 15 | 17 | -421..286 | -223..320 | -299..138 | 150 | AP | explosion fragments |
| 235 | 1 | CB5C | 36 | 1 | 12 | -559..282 | -349..420 | 0..0 | 150f | - | explosion fragments (far LOD of 234, descriptor 150) |
| 236 | 1 | CC28 | 45 | 13 | 15 | -503..338 | -297..396 | -353..66 | 151 | AP | explosion fragments |
| 237 | 1 | CD48 | 36 | 2 | 12 | -771..404 | -533..560 | 0..0 | 151f | - | explosion fragments (far LOD of 236, descriptor 151) |
| 238 | 1 | CE14 | 116 | 31 | 63 | 100..500 | 10..60 | -155..-107 | 152 | P | rod with ends |
| 239 | 1 | D1F8 | 116 | 31 | 63 | -501..-101 | 10..60 | -155..-107 | 153 | P | rod with ends |
| 240 | 1 | D5DC | 116 | 29 | 56 | 132..532 | 12..60 | -135..-87 | 154 | P | rod with ends |
| 241 | 1 | D984 | 116 | 29 | 56 | -533..-133 | 12..60 | -135..-87 | 155 | P | rod with ends |
| 242 | 1 | DD2C | 116 | 29 | 56 | 72..472 | 16..64 | 106..154 | 156 | P | rod with ends |
| 243 | 1 | E0D4 | 116 | 29 | 56 | -473..-73 | 16..64 | 106..154 | 157 | P | rod with ends |
| 244 | 1 | E47C | 122 | 31 | 63 | -25..24 | 82..760 | -135..-87 | 158 | P | rod with ends |
| 245 | 0 | AAF4 | 42 | 37 | 37 | -401..400 | -61..280 | -261..164 | 159 | A | craft-like shape |
| 246 | 0 | AD04 | 28 | 17 | 17 | -441..440 | -65..280 | -261..140 | 159f | A | craft-like shape (far LOD of 245, descriptor 159) |
| 247 | 0 | AE10 | 26 | 15 | 17 | -121..120 | -217..40 | -209..118 | 160 | A | craft-like shape |
| 248 | 0 | AF18 | 16 | 9 | 9 | -121..120 | -219..40 | -213..118 | 160f | A | craft-like shape (far LOD of 247, descriptor 160) |
| 249 | 0 | AFB0 | 20 | 12 | 12 | -41..40 | -199..-27 | -335..-85 | 161 | A | craft-like shape |
| 250 | 0 | B078 | 4 | 2 | 2 | -41..40 | -201..-27 | -339..-81 | 161f | A | wing shape (far LOD of 249, descriptor 161) |
| 251 | 0 | B0A0 | 25 | 24 | 24 | -61..60 | -61..60 | -511..-391 | 162 | A | wing shape |
| 252 | 0 | B1EC | 25 | 24 | 24 | -91..90 | -91..90 | -765..-585 | 163 | A | wing shape |
| 253 | 2 | 03B8 | 59 | 23 | 23 | -81..78 | -65..102 | -3..68 | 164 | - | explosion debris |
| 254 | 2 | 0558 | 66 | 19 | 19 | -163..114 | -107..146 | 8..112 | 165 | - | explosion debris |
| 255 | 2 | 06EC | 38 | 13 | 13 | -253..158 | -175..224 | 16..158 | 166 | - | explosion debris |
| 256 | 2 | 07E8 | 39 | 13 | 13 | -377..250 | -271..306 | 56..218 | 167 | - | explosion debris |
| 257 | 2 | 08E8 | 24 | 8 | 8 | -313..314 | -331..400 | 90..204 | 168 | - | explosion debris |
| 258 | 0 | B338 | 164 | 42 | 42 | -397..396 | -211..504 | -309..198 | 169 | - | explosion debris |
| 259 | 0 | B6F8 | 81 | 22 | 22 | -381..380 | -323..540 | -349..192 | 169f | - | explosion debris (far LOD of 258, descriptor 169) |
| 260 | 0 | B8DC | 162 | 42 | 42 | -513..512 | -369..522 | -423..296 | 170 | - | explosion debris |
| 261 | 0 | BC90 | 83 | 23 | 23 | -481..480 | -575..552 | -441..332 | 170f | - | explosion debris (far LOD of 260, descriptor 170) |
| 262 | 0 | BE84 | 162 | 42 | 42 | -385..414 | -397..360 | -315..222 | 171 | - | explosion debris |
| 263 | 0 | C238 | 83 | 23 | 23 | -421..420 | -549..384 | -331..248 | 171f | - | explosion debris (far LOD of 262, descriptor 171) |
| 264 | 0 | C42C | 158 | 40 | 41 | -289..308 | -417..150 | -235..164 | 172 | - | explosion debris |
| 265 | 0 | C7C8 | 83 | 23 | 23 | -315..314 | -531..168 | -247..186 | 172f | - | explosion debris (far LOD of 264, descriptor 172) |
| 266 | 0 | C9BC | 28 | 27 | 27 | -301..300 | -31..300 | -301..300 | 173 | - | dome |
| 267 | 0 | CB48 | 24 | 17 | 19 | -301..300 | -31..300 | -301..300 | 173f | - | dome (far LOD of 266, descriptor 173) |
| 268 | 0 | CC64 | 36 | 19 | 19 | -247..237 | -82..-31 | -172..276 | 174 | - | three-blade shape |
| 269 | 0 | CDA0 | 15 | 1 | 3 | -244..237 | -37..-37 | -172..273 | 174f | - | three-blade shape (far LOD of 268, descriptor 174) |
| 270 | 0 | CDF4 | 26 | 21 | 21 | -184..183 | 63..381 | -217..-4 | 175 | - | octagonal disc |
| 271 | 0 | CF20 | 17 | 10 | 10 | -184..183 | 63..378 | -244..-4 | 175f | - | octagonal disc (far LOD of 270, descriptor 175) |
| 272 | 0 | CFC8 | 4 | 4 | 4 | -71..70 | -61..108 | -31..64 | 176 | - | shard or part |
| 273 | 0 | D004 | 12 | 4 | 4 | -67..56 | -43..32 | -59..118 | 177 | - | shard or part |
| 274 | 0 | D058 | 8 | 6 | 6 | -9..8 | -29..24 | -41..36 | 178 | - | shard or part |
| 275 | 0 | D0B8 | 8 | 6 | 6 | -9..8 | -29..24 | -41..36 | 179 | - | shard or part |
| 276 | 0 | D118 | 12 | 7 | 7 | -79..82 | -27..26 | -49..56 | 180 | - | shard or part |
| 277 | 0 | D190 | 13 | 8 | 8 | -69..64 | -29..24 | -75..72 | 181 | - | shard or part |
| 278 | 0 | D214 | 13 | 6 | 6 | -71..86 | -19..18 | -51..44 | 182 | - | shard or part |
| 279 | 0 | D284 | 75 | 68 | 72 | -1441..1440 | 28..256 | -2161..716 | 183 | A | shard or part |
| 280 | 0 | D678 | 38 | 17 | 18 | -1441..1440 | 28..140 | -2161..716 | 183f | A | shard or part (far LOD of 279, descriptor 183) |
| 281 | 0 | D7CC | 64 | 9 | 12 | -681..680 | -11..14 | -681..680 | 184 | A | shard or part |
| 282 | 0 | D924 | 64 | 9 | 12 | -681..680 | -11..14 | -681..680 | 184f | A | shard or part (far LOD of 281, descriptor 184) |
| 283 | 0 | DA7C | 16 | 2 | 2 | -23..-21 | 34..132 | -781..-683 | 185 | - | shard or part |
| 284 | 0 | DAD0 | 16 | 2 | 2 | -23..-21 | 34..132 | -781..-683 | 185f | - | shard or part (far LOD of 283, descriptor 185) |
| 285 | 0 | DB24 | 12 | 2 | 2 | -455..450 | -17..32 | -323..322 | 186 | - | shard or part |
| 286 | 0 | DB68 | 8 | 6 | 6 | -101..100 | -51..50 | -83..78 | 187 | - | shard or part |
| 287 | 0 | DBC8 | 7 | 7 | 7 | -53..52 | -23..18 | -63..78 | 188 | - | shard or part |
| 288 | 0 | DC2C | 5 | 4 | 4 | -35..46 | -41..40 | -325..316 | 189 | - | shard or part |
| 289 | 0 | DC6C | 18 | 5 | 5 | -65..96 | -9..16 | -49..56 | 190 | - | shard or part |
| 290 | 0 | DCE0 | 18 | 5 | 5 | -21..4 | -51..66 | -125..132 | 191 | - | shard or part |
| 291 | 0 | DD54 | 6 | 5 | 5 | -49..40 | -41..52 | -61..64 | 192 | - | shard or part |
| 292 | 0 | DDA4 | 33 | 27 | 35 | -1286..1267 | -192..93 | -557..659 | 193 | A | winged craft |
| 293 | 0 | DF5C | 33 | 29 | 35 | -1283..1283 | -212..265 | -645..571 | 194 | A | winged craft |
| 294 | 0 | E118 | 35 | 29 | 35 | -946..971 | -240..698 | -557..659 | 195 | A | winged craft |
| 295 | 0 | E2DC | 33 | 27 | 35 | -1266..1266 | -185..186 | -645..571 | 196 | A | winged craft |
| 296 | 0 | E494 | 33 | 29 | 35 | -1226..1226 | -261..180 | -645..571 | 197 | A | winged craft |
| 297 | 0 | E650 | 35 | 29 | 35 | -954..947 | -565..265 | -645..571 | 198 | A | winged craft |
| 298 | 2 | 0988 | 26 | 32 | 32 | -41..40 | 0..330 | -41..40 | 199 | A | blob |
| 299 | 2 | 0B2C | 26 | 32 | 32 | -41..40 | 0..200 | -41..40 | 200 | A | blob |
| 300 | 2 | 0CD0 | 26 | 33 | 33 | -41..40 | 0..120 | -41..40 | 201 | A | blob |
| 301 | 2 | 0E80 | 69 | 45 | 52 | -129..128 | 0..200 | -107..112 | 202 | A | blob |
| 302 | 2 | 115C | 36 | 21 | 23 | -131..156 | 0..20 | -115..124 | 203 | A | blob |
| 303 | 1 | E874 | 66 | 15 | 18 | -69..68 | 10..34 | -385..-181 | 204 | AP | streak cluster |
| 304 | 1 | EA00 | 68 | 15 | 18 | -69..68 | 10..34 | -515..-181 | 205 | AP | streak cluster |
| 305 | 1 | EB90 | 68 | 11 | 18 | -69..68 | 10..34 | -643..-181 | 206 | A | streak cluster |
| 306 | 1 | ED14 | 14 | 1 | 5 | -133..132 | 0..0 | -249..274 | 207 | AP | wing |
| 307 | 1 | ED74 | 12 | 1 | 4 | -69..132 | 0..0 | -249..274 | 208 | - | wing |
| 308 | 1 | EDC4 | 12 | 1 | 4 | -133..68 | 0..0 | -249..274 | 209 | - | wing |
| 309 | 1 | EE14 | 10 | 1 | 3 | -69..68 | 0..0 | -249..274 | 210 | P | wing |
| 310 | 1 | EE58 | 8 | 3 | 3 | -248..248 | -2..2 | -1376..2008 | 211 | - | bolt |
| 311 | 2 | 12CC | 32 | 1 | 4 | -192..192 | 0..384 | -96..0 | 212 | - | octagonal target |
| 312 | 2 | 1368 | 32 | 1 | 4 | -192..192 | 0..384 | -96..0 | 213 | - | octagonal target |
| 313 | 2 | 1404 | 32 | 1 | 4 | -192..192 | 0..384 | -96..0 | 214 | - | octagonal target |
| 314 | 2 | 14A0 | 32 | 1 | 4 | -192..192 | 0..384 | -96..0 | 215 | - | octagonal target |
| 315 | 2 | 153C | 80 | 1 | 8 | -1536..1536 | -1536..1536 | -96..0 | 216 | - | concentric oval rings |
| 316 | 2 | 16A8 | 80 | 1 | 8 | -1531..1531 | -1531..1531 | -96..0 | 217 | - | concentric oval rings |
| 317 | 2 | 1814 | 80 | 1 | 8 | -1517..1517 | -1517..1517 | -96..0 | 218 | - | concentric oval rings |
| 318 | 2 | 1980 | 80 | 1 | 8 | -1531..1531 | -1531..1531 | -96..0 | 219 | - | concentric oval rings |
| 319 | 2 | 1AEC | 80 | 1 | 8 | -1152..1152 | -1152..1152 | -96..0 | 220 | - | concentric oval rings |
| 320 | 2 | 1C58 | 80 | 1 | 8 | -1148..1148 | -1148..1148 | -96..0 | 221 | - | concentric oval rings |
| 321 | 2 | 1DC4 | 80 | 1 | 8 | -1138..1138 | -1138..1138 | -96..0 | 222 | - | concentric oval rings |
| 322 | 2 | 1F30 | 80 | 1 | 8 | -1148..1148 | -1148..1148 | -96..0 | 223 | - | concentric oval rings |
| 323 | 2 | 209C | 80 | 1 | 8 | -768..768 | -768..768 | -96..0 | 224 | - | concentric oval rings |
| 324 | 2 | 2208 | 80 | 1 | 8 | -766..766 | -766..766 | -96..0 | 225 | - | concentric oval rings |
| 325 | 2 | 2374 | 80 | 1 | 8 | -759..759 | -759..759 | -96..0 | 226 | - | concentric oval rings |
| 326 | 2 | 24E0 | 80 | 1 | 8 | -766..766 | -766..766 | -96..0 | 227 | - | concentric oval rings |
| 327 | 2 | 264C | 80 | 1 | 8 | -1920..1920 | -1632..672 | -96..0 | 228 | - | concentric oval rings |
| 328 | 2 | 27B8 | 80 | 1 | 8 | -1914..1914 | -1628..668 | -96..0 | 229 | - | concentric oval rings |
| 329 | 2 | 2924 | 80 | 1 | 8 | -1896..1896 | -1618..658 | -96..0 | 230 | - | concentric oval rings |
| 330 | 2 | 2A90 | 80 | 1 | 8 | -1914..1914 | -1628..668 | -96..0 | 231 | - | concentric oval rings |
| 331 | 1 | EE94 | 124 | 53 | 66 | -23..22 | 60..104 | -193..82 | 232 | - | craft with arms |
| 332 | 1 | F2D4 | 106 | 51 | 63 | -51..50 | 60..170 | -161..-23 | 233 | - | craft with arms |
| 333 | 2 | 2BFC | 202 | 58 | 88 | -27..26 | 54..130 | -161..92 | 234 | - | craft with arms |
| 334 | 2 | 31E0 | 210 | 56 | 88 | -41..40 | 54..160 | -161..92 | 235 | - | craft with arms |
| 335 | 1 | F6AC | 4 | 2 | 2 | -385..384 | 0..1248 | 0..0 | 236 | - | dark panel (type-1 faces) |
| 336 | 1 | F6D4 | 7 | 3 | 3 | -248..248 | -2..2 | -496..2008 | 237 | P | bolt |
| 337 | 1 | F70C | 6 | 2 | 2 | -248..248 | -2..2 | -496..2008 | 238 | - | bolt |
| 338 | 1 | F738 | 59 | 9 | 29 | -1600..1600 | 0..3122 | -448..-320 | 239 | - | star disc |
| 339 | 1 | F8E8 | 6 | 1 | 3 | -665..707 | 0..0 | -5865..6663 | 240 | - | line |
| 340 | 1 | F91C | 6 | 1 | 3 | -675..697 | 0..0 | -5865..6663 | 241 | - | line |
| 341 | 1 | F950 | 6 | 1 | 3 | -665..707 | -3200..-3200 | -5865..6663 | 242 | - | line |
| 342 | 1 | F984 | 6 | 1 | 3 | -675..697 | -3200..-3200 | -5865..6663 | 243 | - | line |
| 343 | 0 | E814 | 101 | 117 | 117 | -271..270 | -271..270 | -769..765 | 244 | - | bomb shape |
| 344 | 0 | EE24 | 20 | 24 | 24 | -271..270 | -271..270 | -844..690 | 244f | - | bomb shape (far LOD of 343, descriptor 244) |
| 345 | 0 | EF60 | 82 | 28 | 38 | -329..328 | 0..300 | -81..0 | 245 | - | zigzag |
| 346 | 2 | 37D4 | 82 | 28 | 38 | -329..328 | 0..300 | -81..0 | 246 | - | zigzag |
| 347 | 0 | F1DC | 40 | 13 | 20 | -1961..1960 | 0..1540 | 0..3360 | 247 | - | zigzag |
| 348 | 1 | F9B8 | 118 | 25 | 68 | -1961..1960 | 0..2100 | -3361..3360 | 248 | - | zigzag |
| 349 | 0 | F324 | 40 | 13 | 20 | -1961..1960 | 0..1540 | -3361..0 | 249 | - | zigzag |
| 350 | 0 | F46C | 56 | 27 | 27 | -1611..1611 | -1533..3182 | -3409..3212 | 250 | - | tunnel section |
| 351 | 0 | F63C | 41 | 21 | 21 | -1601..1600 | -1629..1560 | -3304..3205 | 251 | - | tunnel section |
| 352 | 0 | F7A4 | 40 | 19 | 19 | -1604..1600 | -1574..1548 | -3254..3254 | 252 | - | tunnel section |
| 353 | 1 | FD8C | 12 | 6 | 7 | -1025..1024 | -769..768 | -41..200 | 253 | A | coloured panel (type-1 faces) |
| 354 | 1 | FE00 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 254 | AP | coloured panel (type-1 faces) |
| 355 | 1 | FE20 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 255 | AP | coloured panel (type-1 faces) |
| 356 | 1 | FE40 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 256 | AP | coloured panel (type-1 faces) |
| 357 | 1 | FE60 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 257 | AP | coloured panel (type-1 faces) |
| 358 | 1 | FE80 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 258 | AP | coloured panel (type-1 faces) |
| 359 | 1 | FEA0 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 259 | AP | coloured panel (type-1 faces) |
| 360 | 1 | FEC0 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 260 | AP | coloured panel (type-1 faces) |
| 361 | 1 | FEE0 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 261 | AP | coloured panel (type-1 faces) |
| 362 | 1 | FF00 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 262 | AP | coloured panel (type-1 faces) |
| 363 | 1 | FF20 | 4 | 1 | 1 | -21..20 | -21..20 | 0..0 | 263 | AP | coloured panel (type-1 faces) |
| 364 | 2 | 3A50 | 18 | 1 | 6 | -324..364 | -288..296 | 0..0 | 264 | - | burst |
| 365 | 2 | 3ABC | 27 | 1 | 9 | -480..584 | -500..536 | 0..0 | 265 | - | burst |
| 366 | 2 | 3B58 | 36 | 1 | 12 | -684..884 | -684..756 | 0..0 | 266 | - | burst |
| 367 | 2 | 3C24 | 27 | 1 | 9 | -560..480 | -452..572 | 0..0 | 267 | - | burst |
| 368 | 2 | 3CC0 | 10 | 1 | 3 | -64..64 | -66..66 | 0..0 | 268 | - | letter A |
| 369 | 2 | 3D00 | 23 | 1 | 11 | -52..52 | -66..66 | 0..0 | 269 | - | letter B |
| 370 | 2 | 3DA8 | 24 | 1 | 11 | -60..60 | -71..71 | 0..0 | 270 | - | letter C |
| 371 | 2 | 3E54 | 18 | 1 | 8 | -56..56 | -67..67 | 0..0 | 271 | - | letter D |
| 372 | 2 | 3ED4 | 14 | 1 | 4 | -52..52 | -68..68 | 0..0 | 272 | - | letter E |
| 373 | 2 | 3F28 | 11 | 1 | 3 | -48..48 | -68..68 | 0..0 | 273 | - | letter F |
| 374 | 2 | 3F6C | 29 | 1 | 14 | -63..63 | -71..71 | 0..0 | 274 | - | letter G |
| 375 | 2 | 4040 | 12 | 1 | 3 | -53..53 | -68..68 | 0..0 | 275 | - | letter H |
| 376 | 2 | 4088 | 4 | 1 | 1 | -9..9 | -68..68 | 0..0 | 276 | - | letter I |
| 377 | 2 | 40A8 | 14 | 1 | 5 | -41..41 | -69..69 | 0..0 | 277 | - | letter J |
| 378 | 2 | 4108 | 12 | 1 | 3 | -56..56 | -68..68 | 0..0 | 278 | - | letter K |
| 379 | 2 | 4150 | 7 | 1 | 2 | -45..45 | -68..68 | 0..0 | 279 | - | letter L |
| 380 | 2 | 4180 | 12 | 1 | 4 | -64..64 | -68..68 | 0..0 | 280 | - | letter M |
| 381 | 2 | 41D0 | 10 | 1 | 3 | -53..53 | -68..68 | 0..0 | 281 | - | letter N |
| 382 | 2 | 4210 | 24 | 1 | 12 | -64..64 | -69..69 | 0..0 | 282 | - | letter O |
| 383 | 2 | 42C4 | 17 | 1 | 6 | -53..53 | -63..71 | 0..0 | 283 | - | letter P |
| 384 | 2 | 4334 | 28 | 1 | 13 | -64..64 | -72..72 | 0..0 | 284 | - | letter Q |
| 385 | 2 | 43FC | 23 | 1 | 9 | -59..59 | -64..69 | 0..0 | 285 | - | letter R |
| 386 | 2 | 4494 | 32 | 1 | 13 | -56..56 | -71..71 | 0..0 | 286 | - | letter S |
| 387 | 2 | 456C | 8 | 1 | 2 | -57..57 | -68..68 | 0..0 | 287 | - | letter T |
| 388 | 2 | 45A0 | 18 | 1 | 7 | -56..56 | -69..69 | 0..0 | 288 | - | letter U |
| 389 | 2 | 461C | 6 | 1 | 2 | -63..63 | -68..68 | 0..0 | 289 | - | letter V |
| 390 | 2 | 4648 | 10 | 1 | 4 | -89..89 | -68..68 | 0..0 | 290 | - | letter W |
| 391 | 2 | 4690 | 8 | 1 | 2 | -63..63 | -68..68 | 0..0 | 291 | - | letter X |
| 392 | 2 | 46C4 | 8 | 1 | 3 | -65..65 | -68..68 | 0..0 | 292 | - | letter Y |
| 393 | 2 | 4700 | 10 | 1 | 3 | -56..56 | -68..68 | 0..0 | 293 | - | letter Z |
| 394 | 2 | 4744 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 294 | - | triangle |
| 395 | 2 | 4798 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 295 | - | triangle |
| 396 | 2 | 47EC | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 296 | - | triangle |
| 397 | 2 | 4840 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 297 | - | triangle |
| 398 | 2 | 4894 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 298 | - | triangle |
| 399 | 2 | 48E8 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 299 | - | triangle |
| 400 | 2 | 493C | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 300 | - | triangle |
| 401 | 2 | 4990 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 301 | - | triangle |
| 402 | 2 | 49E4 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 302 | - | triangle |
| 403 | 2 | 4A38 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 303 | - | triangle |
| 404 | 2 | 4A8C | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 304 | - | triangle |
| 405 | 2 | 4AE0 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 305 | - | triangle |
| 406 | 2 | 4B34 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 306 | - | triangle |
| 407 | 2 | 4B88 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 307 | - | triangle |
| 408 | 2 | 4BDC | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 308 | - | triangle |
| 409 | 2 | 4C30 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 309 | - | triangle |
| 410 | 2 | 4C84 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 310 | - | triangle |
| 411 | 2 | 4CD8 | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 311 | - | triangle |
| 412 | 2 | 4D2C | 12 | 4 | 4 | -17..18 | -11..18 | -11..18 | 312 | - | triangle |
