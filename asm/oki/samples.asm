; S.T.U.N. Runner (rev 6), JSA II OKI M6295 ADPCM image: 256 KB, not banked on JSA II
; (docs/01-hardware.md section 6, docs/10-adpcm.md).
;
; Milestone 4: the phrase table is source; the samples are the bytes recovered from one WAV per
; phrase (tools/adpcm asm writes ../../build/oki/samples.asm from data/oki/samples.json and the
; WAVs in OKI_WAV_DIR, default build/oki/wav, which tools/adpcm split makes from the merged
; image). The WAVs carry the ADPCM bytes verbatim, so the four files are byte-identical only if
; every sample survived WAV and back. The sample bytes stay under build/ (CLAUDE.md section 2).
;
; ROM files: 136070-2124.1fh 00000-0FFFF, -2125.1ef 10000-1FFFF, -2126.1de 20000-2FFFF,
; -2127.1cd 30000-3FFFF. Phrase 11 straddles 1fh/1ef, phrase 32 1ef/1de, phrase 40 1de/1cd; the
; include cuts each of those incbins at the boundary and labels the file (oki_1ef, oki_1de,
; oki_1cd). Assembled with vasmm68k_mot as a plain byte image (docs/04-build.md).

	org	0

; The phrase table (okim6295_device::write): phrase n's entry at 8 * n, the first and the last
; address of its sample, 3 bytes each, big-endian (the chip masks them to 18 bits and plays
; first..last inclusive); bytes 6-7 are not read by the chip and are zero in every entry. The
; 6502 asks for phrases 1-52 only (docs/10-adpcm.md section 4), so the table stops at entry 52
; and phrase 1's sample starts right after it, at 001A8. phrase_NN is a sample's first byte,
; phrase_NN_last its last (both in the include).
oki_1fh:
oki_phrase_table:
	assert	*=$00000,"136070-2124.1fh misplaced"
; phrase 0: not a phrase (the 6502 never asks for it), zero
	dc.b	0,0,0,0,0,0,0,0
; phrase 1
	dc.b	(phrase_01>>16)&$FF,(phrase_01>>8)&$FF,phrase_01&$FF
	dc.b	(phrase_01_last>>16)&$FF,(phrase_01_last>>8)&$FF,phrase_01_last&$FF,0,0
; phrase 2
	dc.b	(phrase_02>>16)&$FF,(phrase_02>>8)&$FF,phrase_02&$FF
	dc.b	(phrase_02_last>>16)&$FF,(phrase_02_last>>8)&$FF,phrase_02_last&$FF,0,0
; phrase 3
	dc.b	(phrase_03>>16)&$FF,(phrase_03>>8)&$FF,phrase_03&$FF
	dc.b	(phrase_03_last>>16)&$FF,(phrase_03_last>>8)&$FF,phrase_03_last&$FF,0,0
; phrase 4
	dc.b	(phrase_04>>16)&$FF,(phrase_04>>8)&$FF,phrase_04&$FF
	dc.b	(phrase_04_last>>16)&$FF,(phrase_04_last>>8)&$FF,phrase_04_last&$FF,0,0
; phrase 5
	dc.b	(phrase_05>>16)&$FF,(phrase_05>>8)&$FF,phrase_05&$FF
	dc.b	(phrase_05_last>>16)&$FF,(phrase_05_last>>8)&$FF,phrase_05_last&$FF,0,0
; phrase 6
	dc.b	(phrase_06>>16)&$FF,(phrase_06>>8)&$FF,phrase_06&$FF
	dc.b	(phrase_06_last>>16)&$FF,(phrase_06_last>>8)&$FF,phrase_06_last&$FF,0,0
; phrase 7
	dc.b	(phrase_07>>16)&$FF,(phrase_07>>8)&$FF,phrase_07&$FF
	dc.b	(phrase_07_last>>16)&$FF,(phrase_07_last>>8)&$FF,phrase_07_last&$FF,0,0
; phrase 8
	dc.b	(phrase_08>>16)&$FF,(phrase_08>>8)&$FF,phrase_08&$FF
	dc.b	(phrase_08_last>>16)&$FF,(phrase_08_last>>8)&$FF,phrase_08_last&$FF,0,0
; phrase 9
	dc.b	(phrase_09>>16)&$FF,(phrase_09>>8)&$FF,phrase_09&$FF
	dc.b	(phrase_09_last>>16)&$FF,(phrase_09_last>>8)&$FF,phrase_09_last&$FF,0,0
; phrase 10
	dc.b	(phrase_10>>16)&$FF,(phrase_10>>8)&$FF,phrase_10&$FF
	dc.b	(phrase_10_last>>16)&$FF,(phrase_10_last>>8)&$FF,phrase_10_last&$FF,0,0
; phrase 11
	dc.b	(phrase_11>>16)&$FF,(phrase_11>>8)&$FF,phrase_11&$FF
	dc.b	(phrase_11_last>>16)&$FF,(phrase_11_last>>8)&$FF,phrase_11_last&$FF,0,0
; phrase 12
	dc.b	(phrase_12>>16)&$FF,(phrase_12>>8)&$FF,phrase_12&$FF
	dc.b	(phrase_12_last>>16)&$FF,(phrase_12_last>>8)&$FF,phrase_12_last&$FF,0,0
; phrase 13
	dc.b	(phrase_13>>16)&$FF,(phrase_13>>8)&$FF,phrase_13&$FF
	dc.b	(phrase_13_last>>16)&$FF,(phrase_13_last>>8)&$FF,phrase_13_last&$FF,0,0
; phrase 14
	dc.b	(phrase_14>>16)&$FF,(phrase_14>>8)&$FF,phrase_14&$FF
	dc.b	(phrase_14_last>>16)&$FF,(phrase_14_last>>8)&$FF,phrase_14_last&$FF,0,0
; phrase 15
	dc.b	(phrase_15>>16)&$FF,(phrase_15>>8)&$FF,phrase_15&$FF
	dc.b	(phrase_15_last>>16)&$FF,(phrase_15_last>>8)&$FF,phrase_15_last&$FF,0,0
; phrase 16
	dc.b	(phrase_16>>16)&$FF,(phrase_16>>8)&$FF,phrase_16&$FF
	dc.b	(phrase_16_last>>16)&$FF,(phrase_16_last>>8)&$FF,phrase_16_last&$FF,0,0
; phrase 17
	dc.b	(phrase_17>>16)&$FF,(phrase_17>>8)&$FF,phrase_17&$FF
	dc.b	(phrase_17_last>>16)&$FF,(phrase_17_last>>8)&$FF,phrase_17_last&$FF,0,0
; phrase 18
	dc.b	(phrase_18>>16)&$FF,(phrase_18>>8)&$FF,phrase_18&$FF
	dc.b	(phrase_18_last>>16)&$FF,(phrase_18_last>>8)&$FF,phrase_18_last&$FF,0,0
; phrase 19
	dc.b	(phrase_19>>16)&$FF,(phrase_19>>8)&$FF,phrase_19&$FF
	dc.b	(phrase_19_last>>16)&$FF,(phrase_19_last>>8)&$FF,phrase_19_last&$FF,0,0
; phrase 20
	dc.b	(phrase_20>>16)&$FF,(phrase_20>>8)&$FF,phrase_20&$FF
	dc.b	(phrase_20_last>>16)&$FF,(phrase_20_last>>8)&$FF,phrase_20_last&$FF,0,0
; phrase 21
	dc.b	(phrase_21>>16)&$FF,(phrase_21>>8)&$FF,phrase_21&$FF
	dc.b	(phrase_21_last>>16)&$FF,(phrase_21_last>>8)&$FF,phrase_21_last&$FF,0,0
; phrase 22
	dc.b	(phrase_22>>16)&$FF,(phrase_22>>8)&$FF,phrase_22&$FF
	dc.b	(phrase_22_last>>16)&$FF,(phrase_22_last>>8)&$FF,phrase_22_last&$FF,0,0
; phrase 23
	dc.b	(phrase_23>>16)&$FF,(phrase_23>>8)&$FF,phrase_23&$FF
	dc.b	(phrase_23_last>>16)&$FF,(phrase_23_last>>8)&$FF,phrase_23_last&$FF,0,0
; phrase 24
	dc.b	(phrase_24>>16)&$FF,(phrase_24>>8)&$FF,phrase_24&$FF
	dc.b	(phrase_24_last>>16)&$FF,(phrase_24_last>>8)&$FF,phrase_24_last&$FF,0,0
; phrase 25
	dc.b	(phrase_25>>16)&$FF,(phrase_25>>8)&$FF,phrase_25&$FF
	dc.b	(phrase_25_last>>16)&$FF,(phrase_25_last>>8)&$FF,phrase_25_last&$FF,0,0
; phrase 26
	dc.b	(phrase_26>>16)&$FF,(phrase_26>>8)&$FF,phrase_26&$FF
	dc.b	(phrase_26_last>>16)&$FF,(phrase_26_last>>8)&$FF,phrase_26_last&$FF,0,0
; phrase 27
	dc.b	(phrase_27>>16)&$FF,(phrase_27>>8)&$FF,phrase_27&$FF
	dc.b	(phrase_27_last>>16)&$FF,(phrase_27_last>>8)&$FF,phrase_27_last&$FF,0,0
; phrase 28
	dc.b	(phrase_28>>16)&$FF,(phrase_28>>8)&$FF,phrase_28&$FF
	dc.b	(phrase_28_last>>16)&$FF,(phrase_28_last>>8)&$FF,phrase_28_last&$FF,0,0
; phrase 29
	dc.b	(phrase_29>>16)&$FF,(phrase_29>>8)&$FF,phrase_29&$FF
	dc.b	(phrase_29_last>>16)&$FF,(phrase_29_last>>8)&$FF,phrase_29_last&$FF,0,0
; phrase 30
	dc.b	(phrase_30>>16)&$FF,(phrase_30>>8)&$FF,phrase_30&$FF
	dc.b	(phrase_30_last>>16)&$FF,(phrase_30_last>>8)&$FF,phrase_30_last&$FF,0,0
; phrase 31
	dc.b	(phrase_31>>16)&$FF,(phrase_31>>8)&$FF,phrase_31&$FF
	dc.b	(phrase_31_last>>16)&$FF,(phrase_31_last>>8)&$FF,phrase_31_last&$FF,0,0
; phrase 32
	dc.b	(phrase_32>>16)&$FF,(phrase_32>>8)&$FF,phrase_32&$FF
	dc.b	(phrase_32_last>>16)&$FF,(phrase_32_last>>8)&$FF,phrase_32_last&$FF,0,0
; phrase 33
	dc.b	(phrase_33>>16)&$FF,(phrase_33>>8)&$FF,phrase_33&$FF
	dc.b	(phrase_33_last>>16)&$FF,(phrase_33_last>>8)&$FF,phrase_33_last&$FF,0,0
; phrase 34
	dc.b	(phrase_34>>16)&$FF,(phrase_34>>8)&$FF,phrase_34&$FF
	dc.b	(phrase_34_last>>16)&$FF,(phrase_34_last>>8)&$FF,phrase_34_last&$FF,0,0
; phrase 35
	dc.b	(phrase_35>>16)&$FF,(phrase_35>>8)&$FF,phrase_35&$FF
	dc.b	(phrase_35_last>>16)&$FF,(phrase_35_last>>8)&$FF,phrase_35_last&$FF,0,0
; phrase 36
	dc.b	(phrase_36>>16)&$FF,(phrase_36>>8)&$FF,phrase_36&$FF
	dc.b	(phrase_36_last>>16)&$FF,(phrase_36_last>>8)&$FF,phrase_36_last&$FF,0,0
; phrase 37
	dc.b	(phrase_37>>16)&$FF,(phrase_37>>8)&$FF,phrase_37&$FF
	dc.b	(phrase_37_last>>16)&$FF,(phrase_37_last>>8)&$FF,phrase_37_last&$FF,0,0
; phrase 38
	dc.b	(phrase_38>>16)&$FF,(phrase_38>>8)&$FF,phrase_38&$FF
	dc.b	(phrase_38_last>>16)&$FF,(phrase_38_last>>8)&$FF,phrase_38_last&$FF,0,0
; phrase 39
	dc.b	(phrase_39>>16)&$FF,(phrase_39>>8)&$FF,phrase_39&$FF
	dc.b	(phrase_39_last>>16)&$FF,(phrase_39_last>>8)&$FF,phrase_39_last&$FF,0,0
; phrase 40
	dc.b	(phrase_40>>16)&$FF,(phrase_40>>8)&$FF,phrase_40&$FF
	dc.b	(phrase_40_last>>16)&$FF,(phrase_40_last>>8)&$FF,phrase_40_last&$FF,0,0
; phrase 41
	dc.b	(phrase_41>>16)&$FF,(phrase_41>>8)&$FF,phrase_41&$FF
	dc.b	(phrase_41_last>>16)&$FF,(phrase_41_last>>8)&$FF,phrase_41_last&$FF,0,0
; phrase 42
	dc.b	(phrase_42>>16)&$FF,(phrase_42>>8)&$FF,phrase_42&$FF
	dc.b	(phrase_42_last>>16)&$FF,(phrase_42_last>>8)&$FF,phrase_42_last&$FF,0,0
; phrase 43
	dc.b	(phrase_43>>16)&$FF,(phrase_43>>8)&$FF,phrase_43&$FF
	dc.b	(phrase_43_last>>16)&$FF,(phrase_43_last>>8)&$FF,phrase_43_last&$FF,0,0
; phrase 44
	dc.b	(phrase_44>>16)&$FF,(phrase_44>>8)&$FF,phrase_44&$FF
	dc.b	(phrase_44_last>>16)&$FF,(phrase_44_last>>8)&$FF,phrase_44_last&$FF,0,0
; phrase 45
	dc.b	(phrase_45>>16)&$FF,(phrase_45>>8)&$FF,phrase_45&$FF
	dc.b	(phrase_45_last>>16)&$FF,(phrase_45_last>>8)&$FF,phrase_45_last&$FF,0,0
; phrase 46
	dc.b	(phrase_46>>16)&$FF,(phrase_46>>8)&$FF,phrase_46&$FF
	dc.b	(phrase_46_last>>16)&$FF,(phrase_46_last>>8)&$FF,phrase_46_last&$FF,0,0
; phrase 47
	dc.b	(phrase_47>>16)&$FF,(phrase_47>>8)&$FF,phrase_47&$FF
	dc.b	(phrase_47_last>>16)&$FF,(phrase_47_last>>8)&$FF,phrase_47_last&$FF,0,0
; phrase 48
	dc.b	(phrase_48>>16)&$FF,(phrase_48>>8)&$FF,phrase_48&$FF
	dc.b	(phrase_48_last>>16)&$FF,(phrase_48_last>>8)&$FF,phrase_48_last&$FF,0,0
; phrase 49
	dc.b	(phrase_49>>16)&$FF,(phrase_49>>8)&$FF,phrase_49&$FF
	dc.b	(phrase_49_last>>16)&$FF,(phrase_49_last>>8)&$FF,phrase_49_last&$FF,0,0
; phrase 50
	dc.b	(phrase_50>>16)&$FF,(phrase_50>>8)&$FF,phrase_50&$FF
	dc.b	(phrase_50_last>>16)&$FF,(phrase_50_last>>8)&$FF,phrase_50_last&$FF,0,0
; phrase 51
	dc.b	(phrase_51>>16)&$FF,(phrase_51>>8)&$FF,phrase_51&$FF
	dc.b	(phrase_51_last>>16)&$FF,(phrase_51_last>>8)&$FF,phrase_51_last&$FF,0,0
; phrase 52
	dc.b	(phrase_52>>16)&$FF,(phrase_52>>8)&$FF,phrase_52&$FF
	dc.b	(phrase_52_last>>16)&$FF,(phrase_52_last>>8)&$FF,phrase_52_last&$FF,0,0
oki_phrase_table_end:
	assert	*=(oki_phrases+1)*8,"the table does not have an entry per phrase of the include"

	include	"../../build/oki/samples.asm"

	assert	*=$40000,"OKI image does not end at 40000"
