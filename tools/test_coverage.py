"""tools/listings.py on small hand-written vasm and 64tass listings (the formats of vasm 2.0f -L
and 64tass 1.60 -L, as `make` writes them)."""

from __future__ import annotations

from listings import Blob, tass, tass_blobs, vasm, vasm_blobs

VASM = """Sections:
00: "org0001:0" (0-130)


Source: "asm/t/main.asm"
                            \t     1: \torg\t0
                            \t     2: start:
00:00000000 D2D08BA73DCBC4F7\t     3: \tincbin\t"../../build/x.bin",0,$20 ; blob
00:00000008 B5F33EC68137C24C
00:00000010 2C2848D51004179D
00:00000018 287C73EDC6098C0C
                            \t     4: \tassert\t*=$20,"misplaced"
00:00000020 1234            \t     5: \tdc.w\t$1234
00:00000022 01              \t     6: tab:\tdc.b\t1,2,3,4
00:00000023 02
00:00000024 03
00:00000025 04
00:00000026 00              \t     7: \tds.b\t10
00:00000027 *
                            \t     8: \tinclude\t"inc.asm"

Source: "asm/t/inc.asm"
00:00000030 7000            \t     1: \tmoveq\t#0,d0 ; dc.w in a comment
00:00000032 4E71            \t     2: lab:\tnop
                            \t     3: \teven
00:00000034 FF              \t     4: \tdcb.b\t$FC,$ff
00:00000035 *

Source: "asm/t/main.asm"
00:00000130 00000007        \t     9: \tDC.L\t7
                            \t    10:


Symbols by name:
start                           00:00000000
"""


def test_vasm_listing() -> None:
    counts = vasm(VASM.replace("(0-130)", "(0-134)"))
    assert counts == {
        "asm/t/main.asm": {"instr": 0, "data": 2 + 4 + 4, "blob": 0x20, "fill": 10},
        "asm/t/inc.asm": {"instr": 4, "data": 0, "blob": 0, "fill": 0xFC},
    }


def test_vasm_section_end_bounds_the_last_statement() -> None:
    counts = vasm(VASM.replace("(0-130)", "(0-138)"))
    assert counts["asm/t/main.asm"]["data"] == 2 + 4 + 8


TASS = """; 64tass Turbo Assembler Macro V1.60.3243 listing file
; 64tass -q -C -b -L build/t.lst -o build/t.out asm/t/t.asm
; Wed Nov  4 13:08:13 2026

;Offset\t;Hex\t\t;Monitor\t;Source

;******  Processing input file: asm/t/t.asm

="../../build/j.bin"\t\t\t\t\tIMAGE = "../../build/j.bin"
>0000\t43 f2 db 77 d2 86 ee a6\t\tbank0\t.binary IMAGE, 0, $20\t; a comment
>0008\t89 54 44 78 c6 11 99 21 30 6a e0 13 8b e8 31 0b
>0018\t43 22 84 e8 a2 c7 40 22
>0020\t01 02 03\t\t\t\t.byte 1,2,3
>0023\t\t\t\t\t\t.fill 20
.0037\ta9 00\t\tlda #$00\t\tlda #$00\t; .binary in a comment
;******  Processing file: asm/t/inc.asm
.0039\tea\t\tnop\t\tnop
>003a\tea ea ea\t\t\t\t.fill 3,$ea
>003d\t\t\t\t\t\t.text "abc"
;******  Return to file: asm/t/t.asm
>0040\t30 31\t\t\t\t.word $3130
>0042\t89 5a fe 16 59 84 e7 52\t\twindow\t.binary IMAGE, $20
>004a\t12 0d a1 dc 9b 8f e3 bf c7 2a f0 45 13 4e 3d 4d

;******  End of listing
"""


def test_tass_listing() -> None:
    counts = tass(TASS, 0x5A)
    assert counts == {
        "asm/t/t.asm": {"instr": 2, "data": 3 + 2, "blob": 0x20 + 0x18, "fill": 20},
        "asm/t/inc.asm": {"instr": 1, "data": 3, "blob": 0, "fill": 3},
    }


def test_tass_logical_pc_column() -> None:
    listing = (
        ";******  Processing input file: b.asm\n"
        ">1000\t3000\ta9 00\t\tlda #$00\t\tlda #$00\n"
        ">1002\t3002\t01 02\t\t\t\t.byte 1,2\n"
    )
    assert tass(listing, 0x1004) == {"b.asm": {"instr": 2, "data": 2, "blob": 0, "fill": 0}}


def test_blobs_are_named_by_label_and_file() -> None:
    listing = VASM.replace("(0-130)", "(0-134)")
    assert vasm_blobs(listing) == [Blob("asm/t/main.asm", "start", "../../build/x.bin", 0, 0x20)]
    assert tass_blobs(TASS, 0x5A) == [
        Blob("asm/t/t.asm", "bank0", "IMAGE", 0, 0x20),
        Blob("asm/t/t.asm", "window", "IMAGE", 0x42, 0x18),
    ]
