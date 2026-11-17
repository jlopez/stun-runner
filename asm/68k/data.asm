; data.asm, 046AEE-060000: the game program's data, then zero to the end of pair T.
; Owner: the data leg. Not source yet but the zero fill (docs/13-68k-source.md section 4).
;
; 046AEE-05CF86: data with a 68k consumer, as incbin slices of build/stunrun-68k.bin. M5c
; (issue #33, docs/16-68k-code.md) cut the slices at every address the code references and at
; every name of the IDA snapshot, each slice under its label (the snapshot's name, else dat_X,
; tbl_X or str_X by the classification's kind); the bytes stay blob until the data leg explains
; them.

	assert	*=$046AEE,"data.asm misplaced"

dat_46AEE:
	incbin	"../../build/stunrun-68k.bin",$046AEE,$1A
dat_46B08:
	incbin	"../../build/stunrun-68k.bin",$046B08,$D
dat_46B15:
	incbin	"../../build/stunrun-68k.bin",$046B15,$29
str_46B3E:
	dc.b	'PRESS START BUTTON',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46B52:
	dc.b	'INSERT %d COINS',0
str_46B62:
	dc.b	'INSERT 1 COIN',0
str_46B70:
	dc.b	'INSERT %d COINS',0
str_46B80:
	dc.b	'INSERT 1 COIN',0
str_46B8E:
	dc.b	'Copyright 1989 ATARI GAMES',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46BAA:
	dc.b	'Credits: %s %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46BBA:
	dc.b	'GAME OVER',0
str_46BC4:
	dc.b	'OUT OF TIME',0
str_46BD0:
	dc.b	'MORE TO COME SOON',0
str_46BE2:
	dc.b	'DAMAGE REPORT',0
str_46BF0:
	dc.b	'NO DAMAGE',0
str_46BFA:
	dc.b	'STUN RUNNER TEAM',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46C0C:
	dc.b	'COMMISSIONER:        Ed Rotberg',0
str_46C2C:
	dc.b	'TRANSIT AUTHORITY:   Andrew Burgess',0
str_46C50:
	dc.b	'TUNNEL ARCHITECT:    Sam Comstock',0
str_46C72:
	dc.b	'VEHICLE ENGINEER:    Will Noble',0
str_46C92:
	dc.b	'CITY PLANNING:       Kris Moser',0
str_46CB2:
	dc.b	'COMMUNICATIONS:      Don Diekneite',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46CD6:
	dc.b	'ACOUSTICS:           Brad Fuller',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46CF8:
	dc.b	'PROPULSION ENGINEER: Jed Margolin',0
str_46D1A:
	dc.b	'PATRIARCH:           John Ray',0
str_46D38:
	dc.b	'PUBLIC RELATIONS:    Jerry Momoda',0
str_46D5A:
	dc.b	'BLUE SKY:            Carole Cameron',0
str_46D7E:
	dc.b	'DAMAGE CONTROL:      Glenn McNamara',0
str_46DA2:
	dc.b	'PHYSICIST:           Max Behensky',0
str_46DC4:
	dc.b	'OPTICS:              Stephanie Mott',0
str_46DE8:
	dc.b	'AUXILIARY SYSTEMS:   Gary Stempler',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46E0C:
	dc.b	'MATHEMATICS:         Jim Morris',0
str_46E2C:
	dc.b	'CHIEF MECHANIC:      Milt Loper',0
str_46E4C:
	dc.b	'BACKHOE OPERATOR:    Erik Durfey',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46E6E:
	dc.b	'OVERLORD:            Mike Hally',0
str_46E8E:
	dc.b	'CHAINSAW:            Ralph Perez',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46EB0:
	dc.b	'BONDO MAN:           Ken Hata',0
str_46ECE:
	dc.b	'XACTO BLADERUNNER:   Kyoko Dougherty',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46EF4:
	dc.b	'PUB RUNNER:          Andrea Dencker',0
str_46F18:
	dc.b	'WIDGET ARTIST:       Mary Sumner',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46F3A:
	dc.b	'THE ANCIENT ONE:     Rick Moncrief',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46F5E:
	dc.b	'Copyright 1989 ATARI GAMES',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_46F7A:
	dc.b	'Credits: %s %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_46F8A:
	incbin	"../../build/stunrun-68k.bin",$046F8A,$10
dat_46F9A:
	incbin	"../../build/stunrun-68k.bin",$046F9A,$10
dat_46FAA:
	incbin	"../../build/stunrun-68k.bin",$046FAA,$4
dat_46FAE:
	incbin	"../../build/stunrun-68k.bin",$046FAE,$4
dat_46FB2:
	incbin	"../../build/stunrun-68k.bin",$046FB2,$4
dat_46FB6:
	incbin	"../../build/stunrun-68k.bin",$046FB6,$4
dat_46FBA:
	incbin	"../../build/stunrun-68k.bin",$046FBA,$4
str_46FBE:
	dc.b	'Credits: %s %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_46FCE:
	incbin	"../../build/stunrun-68k.bin",$046FCE,$4
dat_46FD2:
	incbin	"../../build/stunrun-68k.bin",$046FD2,$4
dat_46FD6:
	incbin	"../../build/stunrun-68k.bin",$046FD6,$4
dat_46FDA:
	incbin	"../../build/stunrun-68k.bin",$046FDA,$4
dat_46FDE:
	incbin	"../../build/stunrun-68k.bin",$046FDE,$4
dat_46FE2:
	incbin	"../../build/stunrun-68k.bin",$046FE2,$4
dat_46FE6:
	incbin	"../../build/stunrun-68k.bin",$046FE6,$4
dat_46FEA:
	incbin	"../../build/stunrun-68k.bin",$046FEA,$4
dat_46FEE:
	incbin	"../../build/stunrun-68k.bin",$046FEE,$4
str_46FF2:
	dc.b	"WINNERS DON'T USE DRUGS",0
str_4700A:
	dc.b	"WINNERS DON'T USE DRUGS",0
str_47022:
	dc.b	'William S. Sessions, Director, FBI',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47046:
	dc.b	' THE STUN RUNNER TEAM',0
str_4705C:
	dc.b	'NO MAP AT THIS TIME',0
str_47070:
	dc.b	'Get %d STARS & finish level for SHOCKWAVE',0
str_4709A:
	dc.b	'WARP BONUS: 20,000 PTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_470B2:
	dc.b	'NO SHOCKWAVE FOR %d STARS',0
str_470CC:
	dc.b	'1 SHOCKWAVE FOR %d STARS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_470E6:
	dc.b	'MAX 6 SHOCKWAVES',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_470F8:
	dc.b	'%d SHIELDS REMAINING: %d PTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47116:
	dc.b	'1 SHIELD REMAINING: %d PTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47132:
	dc.b	'NO SHIELD BONUS',0
str_47142:
	dc.b	'INTERMEDIATE BONUS: %d PTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4715E:
	dc.b	'ADVANCED BONUS: %d PTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47176:
	dc.b	'NO MAP AT THIS TIME',0
dat_4718A:
	incbin	"../../build/stunrun-68k.bin",$04718A,$4
str_4718E:
	dc.b	'Credits: %s %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4719E:
	dc.b	'INSERT %d COINS %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_471B2:
	dc.b	'INSERT 1 COIN %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_471C4:
	dc.b	'INSERT %d COINS %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_471D8:
	dc.b	'INSERT 1 COIN %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_471EA:
	dc.b	'PRESS START %s',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_471FA:
	dc.b	'STUN RUNNER CONTEST',0
str_4720E:
	dc.b	'QUALIFY FOR THE',0
str_4721E:
	dc.b	'ULTIMATE CHALLENGE',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47232:
	dc.b	'CROSS THE CONTEST MARKER',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4724C:
	dc.b	'AND WIN A FREE',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4725C:
	dc.b	'STUN RUNNER T SHIRT',0
str_47270:
	dc.b	'Offer Expires April 1, 1990',0
str_4728C:
	dc.b	'Limit 1 per person.          Quantities Limited.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_472BE:
	dc.b	'NO MAP AT THIS TIME',0
str_472D2:
	dc.b	'Highest: %6d.%1d feet   Your: %6d.%1d feet',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_472FE:
	incbin	"../../build/stunrun-68k.bin",$0472FE,$4
str_47302:
	dc.b	'RAISE CONTROL TO SELECT LEVEL',0
str_47320:
	dc.b	'PRESS TRIGGER TO BEGIN',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47338:
	dc.b	'Novice',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_47340:
	incbin	"../../build/stunrun-68k.bin",$047340,$4
str_47344:
	dc.b	'Level %d',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4734E:
	dc.b	'Intermediate',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4735C:
	incbin	"../../build/stunrun-68k.bin",$04735C,$4
str_47360:
	dc.b	'Level %d',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4736A:
	dc.b	'%d Bonus',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47374:
	dc.b	'Advanced',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4737E:
	incbin	"../../build/stunrun-68k.bin",$04737E,$4
str_47382:
	dc.b	'Level %d',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4738C:
	dc.b	'%d Bonus',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47396:
	dc.b	'LEGEND',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4739E:
	dc.b	'TUNNEL',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_473A6:
	dc.b	'CONSTRUCTION',0
dat_473B3:
	incbin	"../../build/stunrun-68k.bin",$0473B3,$D
str_473C0:
	dc.b	'BOOSTS',0
dat_473C7:
	incbin	"../../build/stunrun-68k.bin",$0473C7,$3
dat_473CA:
	incbin	"../../build/stunrun-68k.bin",$0473CA,$1
dat_473CB:
	incbin	"../../build/stunrun-68k.bin",$0473CB,$1
dat_473CC:
	incbin	"../../build/stunrun-68k.bin",$0473CC,$2
dat_473CE:
	incbin	"../../build/stunrun-68k.bin",$0473CE,$4
dat_473D2:
	incbin	"../../build/stunrun-68k.bin",$0473D2,$4
dat_473D6:
	incbin	"../../build/stunrun-68k.bin",$0473D6,$4
dat_473DA:
	incbin	"../../build/stunrun-68k.bin",$0473DA,$C
dat_473E6:
	incbin	"../../build/stunrun-68k.bin",$0473E6,$4
dat_473EA:
	incbin	"../../build/stunrun-68k.bin",$0473EA,$1C
dat_47406:
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
	dc.l	pal_level_base_03
	dc.l	pal_level_base_04
	dc.l	pal_level_base_05
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
	dc.l	pal_level_base_03
	dc.l	pal_level_base_04
	dc.l	pal_level_base_05
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
	dc.l	pal_level_base_03
	dc.l	pal_level_base_04
	dc.l	pal_level_base_05
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
	dc.l	pal_level_base_03
	dc.l	pal_level_base_04
	dc.l	pal_level_base_05
	dc.l	pal_level_base_00
	dc.l	pal_level_base_01
	dc.l	pal_level_base_02
dat_4747E:
	incbin	"../../build/stunrun-68k.bin",$04747E,$1E
dat_4749C:
	incbin	"../../build/stunrun-68k.bin",$04749C,$8
str_474A4:
	dc.b	'Shields Destroyed',0
str_474B6:
	dc.b	'Wings Destroyed',0
dat_474C6:
	incbin	"../../build/stunrun-68k.bin",$0474C6,$10
dat_474D6:
	incbin	"../../build/stunrun-68k.bin",$0474D6,$2
dat_474D8:
	incbin	"../../build/stunrun-68k.bin",$0474D8,$1C
str_474F4:
	dc.b	'Sorry STUN Runner, though you have the potential, it',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4752A:
	dc.b	'looks like you need more practice. Try it again and',0
str_4755E:
	dc.b	'maybe next time you can qualify as a member of the',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47592:
	dc.b	'         STUN RUNNER CHAMPIONSHIP TEAM',0
dat_475B9:
	incbin	"../../build/stunrun-68k.bin",$0475B9,$1
dat_475BA:
	incbin	"../../build/stunrun-68k.bin",$0475BA,$8
dat_475C2:
	incbin	"../../build/stunrun-68k.bin",$0475C2,$2
dat_475C4:
	incbin	"../../build/stunrun-68k.bin",$0475C4,$6
str_475CA:
	dc.b	'TO TRY THIS LEVEL AGAIN',0
str_475E2:
	dc.b	'TO ADVANCE TO NEXT LEVEL',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_475FC:
	incbin	"../../build/stunrun-68k.bin",$0475FC,$2
dat_475FE:
	incbin	"../../build/stunrun-68k.bin",$0475FE,$2
dat_47600:
	incbin	"../../build/stunrun-68k.bin",$047600,$2
dat_47602:
	incbin	"../../build/stunrun-68k.bin",$047602,$2
dat_47604:
	incbin	"../../build/stunrun-68k.bin",$047604,$2
dat_47606:
	incbin	"../../build/stunrun-68k.bin",$047606,$28
str_4762E:
	dc.b	'STUN RUNNER',0
str_4763A:
	dc.b	'PROCESSING BACKGROUNDS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_47652:
	dc.b	'DOWNLOADING*GSP',0
str_47662:
	dc.b	'DOWNLOADING*ADSP',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_47674:
	incbin	"../../build/stunrun-68k.bin",$047674,$4
str_47678:
	dc.b	'DOWNLOADING*GSP',0
str_47688:
	dc.b	'OPERATOR SCREENS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4769A:
	incbin	"../../build/stunrun-68k.bin",$04769A,$200
dat_4789A:
	incbin	"../../build/stunrun-68k.bin",$04789A,$200
dat_47A9A:
	incbin	"../../build/stunrun-68k.bin",$047A9A,$200
dat_47C9A:
	incbin	"../../build/stunrun-68k.bin",$047C9A,$18
dat_47CB2:
	incbin	"../../build/stunrun-68k.bin",$047CB2,$3C
dat_47CEE:
	incbin	"../../build/stunrun-68k.bin",$047CEE,$1E
dat_47D0C:
	incbin	"../../build/stunrun-68k.bin",$047D0C,$28
dat_47D34:
	incbin	"../../build/stunrun-68k.bin",$047D34,$12
dat_47D46:
	incbin	"../../build/stunrun-68k.bin",$047D46,$3A
dat_47D80:
	incbin	"../../build/stunrun-68k.bin",$047D80,$3A
dat_47DBA:
	incbin	"../../build/stunrun-68k.bin",$047DBA,$3A
dat_47DF4:
	incbin	"../../build/stunrun-68k.bin",$047DF4,$3A
dat_47E2E:
	incbin	"../../build/stunrun-68k.bin",$047E2E,$3A
dat_47E68:
	incbin	"../../build/stunrun-68k.bin",$047E68,$3A
dat_47EA2:
	incbin	"../../build/stunrun-68k.bin",$047EA2,$3A
dat_47EDC:
	incbin	"../../build/stunrun-68k.bin",$047EDC,$3A
dat_47F16:
	incbin	"../../build/stunrun-68k.bin",$047F16,$3A
dat_47F50:
	dc.l	0
	dc.l	0
dat_47F58:
	dc.l	$F0
dat_47F5C:
	dc.l	$F0
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47F16
	dc.l	dat_47D46
	dc.l	dat_47D80
	dc.l	dat_47DBA
	dc.l	dat_47DBA
	dc.l	dat_47DF4
	dc.l	dat_47E2E
	dc.l	dat_47EA2
	dc.l	dat_47EDC
	dc.l	$D0
dat_47FB4:
	dc.l	$D0
	dc.l	$F0
	dc.l	$F0
	dc.l	$F0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	dat_47E68
	dc.l	0
dat_48064:
	dc.l	$F0
dat_48068:
	dc.l	0
	dc.l	0
	dc.l	0
dat_48074:
	dc.l	pal_overlay_03
	dc.l	pal_overlay_04
	dc.l	pal_overlay_05
	dc.l	pal_overlay_04
	dc.l	pal_overlay_05
	dc.l	pal_overlay_08
	dc.l	pal_overlay_09
	dc.l	pal_overlay_10
	dc.l	pal_overlay_11
	dc.l	pal_overlay_12
	dc.l	pal_overlay_13
	dc.l	pal_overlay_14
	dc.l	pal_overlay_15
dat_480A8:
	dc.l	pal_overlay_16
	dc.l	pal_overlay_17
	dc.l	pal_overlay_18
	dc.l	pal_overlay_19
	dc.l	pal_overlay_20
	dc.l	pal_overlay_21
	dc.l	pal_overlay_22
dat_480C4:
	dc.l	pal_overlay_23
	dc.l	0
dat_480CC:
	dc.l	pal_overlay_25
dat_480D0:
	dc.l	pal_overlay_26
dat_480D4:
	dc.l	pal_overlay_26
	dc.l	pal_overlay_26
dat_480DC:
	dc.l	pal_overlay_29
	dc.l	0
dat_480E4:
	dc.l	pal_overlay_31
	dc.l	0
	dc.l	0
	dc.l	0
dat_480F4:
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_37
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_37
	dc.l	pal_overlay_37
	dc.l	pal_overlay_37
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
	dc.l	pal_overlay_25
dat_4816C:
	dc.l	pal_overlay_65
dat_48170:
	dc.l	pal_overlay_65
	dc.l	pal_overlay_65
	dc.l	pal_overlay_65
dat_4817C:
	dc.l	dat_45B60
dat_48180:
	incbin	"../../build/stunrun-68k.bin",$048180,$4
	dc.l	str_48540
	dc.l	str_4854C
	dc.l	str_48572
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
dat_481A8:
	incbin	"../../build/stunrun-68k.bin",$0481A8,$4
	dc.l	str_48596
	dc.l	str_485A8
	dc.l	str_485CA
	dc.l	dat_485E6
	dc.l	dat_485E8
	dc.l	str_485EA
	dc.l	0
	dc.l	0
	dc.l	0
dat_481D0:
	incbin	"../../build/stunrun-68k.bin",$0481D0,$4
	dc.l	str_4860A
	dc.l	str_48618
	dc.l	str_48640
	dc.l	dat_4865A
	dc.l	dat_4865C
	dc.l	str_4865E
	dc.l	0
	dc.l	0
	dc.l	0
dat_481F8:
	incbin	"../../build/stunrun-68k.bin",$0481F8,$4
	dc.l	str_4867E
	dc.l	str_4868E
	dc.l	dat_486AE
	dc.l	dat_486B0
	dc.l	dat_486B2
	dc.l	str_486B4
	dc.l	0
	dc.l	0
	dc.l	0
dat_48220:
	incbin	"../../build/stunrun-68k.bin",$048220,$4
	dc.l	str_486D6
	dc.l	dat_486EC
	dc.l	str_486EE
	dc.l	str_4870C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
dat_48248:
	incbin	"../../build/stunrun-68k.bin",$048248,$4
	dc.l	str_48722
	dc.l	str_48730
	dc.l	str_4874E
	dc.l	dat_48778
	dc.l	dat_4877A
	dc.l	str_4877C
	dc.l	0
	dc.l	0
	dc.l	0
dat_48270:
	incbin	"../../build/stunrun-68k.bin",$048270,$4
	dc.l	str_4879C
	dc.l	str_487A8
	dc.l	dat_487BA
	dc.l	dat_487BC
	dc.l	dat_487BE
	dc.l	str_487C0
	dc.l	0
	dc.l	0
	dc.l	0
dat_48298:
	incbin	"../../build/stunrun-68k.bin",$048298,$4
	dc.l	str_487E0
	dc.l	str_487F0
	dc.l	dat_48812
	dc.l	dat_48814
	dc.l	dat_48816
	dc.l	str_48818
	dc.l	0
	dc.l	0
	dc.l	0
dat_482C0:
	incbin	"../../build/stunrun-68k.bin",$0482C0,$4
	dc.l	str_48838
	dc.l	str_48844
	dc.l	dat_48864
	dc.l	dat_48866
	dc.l	dat_48868
	dc.l	str_4886A
	dc.l	0
	dc.l	0
	dc.l	0
dat_482E8:
	incbin	"../../build/stunrun-68k.bin",$0482E8,$4
	dc.l	str_4888C
	dc.l	dat_488A6
	dc.l	str_488A8
	dc.l	str_488CA
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
dat_48310:
	incbin	"../../build/stunrun-68k.bin",$048310,$4
	dc.l	str_488DE
	dc.l	str_488EE
	dc.l	dat_48906
	dc.l	dat_48908
	dc.l	dat_4890A
	dc.l	str_4890C
	dc.l	0
	dc.l	0
	dc.l	0
dat_48338:
	incbin	"../../build/stunrun-68k.bin",$048338,$4
	dc.l	str_4892C
	dc.l	str_4893E
	dc.l	dat_48964
	dc.l	dat_48966
	dc.l	dat_48968
	dc.l	str_4896A
	dc.l	0
	dc.l	0
	dc.l	0
dat_48360:
	incbin	"../../build/stunrun-68k.bin",$048360,$4
	dc.l	str_4898A
	dc.l	str_4899C
	dc.l	str_489B8
	dc.l	dat_489DE
	dc.l	dat_489E0
	dc.l	str_489E2
	dc.l	0
	dc.l	0
	dc.l	0
dat_48388:
	incbin	"../../build/stunrun-68k.bin",$048388,$4
	dc.l	str_48A02
	dc.l	str_48A16
	dc.l	str_48A32
	dc.l	dat_48A4A
	dc.l	dat_48A4C
	dc.l	str_48A4E
	dc.l	0
	dc.l	0
	dc.l	0
dat_483B0:
	incbin	"../../build/stunrun-68k.bin",$0483B0,$4
	dc.l	str_48A70
	dc.l	dat_48A84
	dc.l	str_48A86
	dc.l	str_48AA6
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
dat_483D8:
	incbin	"../../build/stunrun-68k.bin",$0483D8,$4
	dc.l	str_48ABC
	dc.l	str_48AC8
	dc.l	str_48ADE
	dc.l	dat_48AF4
	dc.l	dat_48AF6
	dc.l	str_48AF8
	dc.l	0
	dc.l	0
	dc.l	0
dat_48400:
	incbin	"../../build/stunrun-68k.bin",$048400,$4
	dc.l	str_48B1E
	dc.l	str_48B2E
	dc.l	dat_48B58
	dc.l	dat_48B5A
	dc.l	dat_48B5C
	dc.l	str_48B5E
	dc.l	0
	dc.l	0
	dc.l	0
dat_48428:
	incbin	"../../build/stunrun-68k.bin",$048428,$4
	dc.l	str_48B84
	dc.l	str_48B92
	dc.l	dat_48BB8
	dc.l	dat_48BBA
	dc.l	dat_48BBC
	dc.l	str_48BBE
	dc.l	0
	dc.l	0
	dc.l	0
dat_48450:
	incbin	"../../build/stunrun-68k.bin",$048450,$4
	dc.l	str_48BE4
	dc.l	str_48BF4
	dc.l	dat_48C08
	dc.l	dat_48C0A
	dc.l	dat_48C0C
	dc.l	str_48C0E
	dc.l	0
	dc.l	0
	dc.l	0
dat_48478:
	incbin	"../../build/stunrun-68k.bin",$048478,$4
	dc.l	str_48C34
	dc.l	str_48C46
	dc.l	dat_48C68
	dc.l	dat_48C6A
	dc.l	dat_48C6C
	dc.l	str_48C6E
	dc.l	0
	dc.l	0
	dc.l	0
dat_484A0:
	incbin	"../../build/stunrun-68k.bin",$0484A0,$4
	dc.l	str_48C94
	dc.l	str_48C9E
	dc.l	dat_48CB4
	dc.l	dat_48CB6
	dc.l	dat_48CB8
	dc.l	str_48CBA
	dc.l	0
	dc.l	0
	dc.l	0
dat_484C8:
	incbin	"../../build/stunrun-68k.bin",$0484C8,$4
	dc.l	str_48CE0
	dc.l	str_48CEC
	dc.l	dat_48D06
	dc.l	dat_48D08
	dc.l	dat_48D0A
	dc.l	str_48D0C
	dc.l	0
	dc.l	0
	dc.l	0
dat_484F0:
	incbin	"../../build/stunrun-68k.bin",$0484F0,$4
	dc.l	str_48D34
	dc.l	str_48D4C
	dc.l	str_48D6C
	dc.l	str_48D8C
	dc.l	str_48D9A
	dc.l	str_48DB4
	dc.l	0
	dc.l	0
	dc.l	0
dat_48518:
	incbin	"../../build/stunrun-68k.bin",$048518,$4
	dc.l	str_48DC0
	dc.l	str_48DCC
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
str_48540:
	dc.b	'CAKE-WALK:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4854C:
	dc.b	'The RED STARS show the fastest path.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48572:
	dc.b	'Drive over stars for bonus points.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48596:
	dc.b	'BOOST BOULEVARD:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_485A8:
	dc.b	'Touch BOOST PADS for HYPER speed.',0
str_485CA:
	dc.b	'Press triggers for LASERS.',0
dat_485E5:
	incbin	"../../build/stunrun-68k.bin",$0485E5,$1
dat_485E6:
	incbin	"../../build/stunrun-68k.bin",$0485E6,$2
dat_485E8:
	incbin	"../../build/stunrun-68k.bin",$0485E8,$2
str_485EA:
	dc.b	'3 levels to CHALLENGE LEVEL 1 !',0
str_4860A:
	dc.b	'BLOOD ALLEY:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48618:
	dc.b	'Touch the GREEN STARS for bonus points.',0
str_48640:
	dc.b	'Beware of ARMORED DRONES.',0
dat_4865A:
	incbin	"../../build/stunrun-68k.bin",$04865A,$2
dat_4865C:
	incbin	"../../build/stunrun-68k.bin",$04865C,$2
str_4865E:
	dc.b	'2 levels to CHALLENGE LEVEL 1 !',0
str_4867E:
	dc.b	'ROLLER-COASTER:',0
str_4868E:
	dc.b	'Look out for crazy MAG CYCLES.',0
dat_486AD:
	incbin	"../../build/stunrun-68k.bin",$0486AD,$1
dat_486AE:
	incbin	"../../build/stunrun-68k.bin",$0486AE,$2
dat_486B0:
	incbin	"../../build/stunrun-68k.bin",$0486B0,$2
dat_486B2:
	incbin	"../../build/stunrun-68k.bin",$0486B2,$2
str_486B4:
	dc.b	'Next level is CHALLENGE LEVEL 1 !',0
str_486D6:
	dc.b	'THE BOOST CHALLENGE:',0
dat_486EB:
	incbin	"../../build/stunrun-68k.bin",$0486EB,$1
dat_486EC:
	incbin	"../../build/stunrun-68k.bin",$0486EC,$2
str_486EE:
	dc.b	'Goal - Hit as many BOOST PADS',0
str_4870C:
	dc.b	'       as possible !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48722:
	dc.b	'OUTER DRIVE:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48730:
	dc.b	'A universe of possibilities.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4874E:
	dc.b	'Pickup SHOCKWAVE Marker for ultra-weapon.',0
dat_48778:
	incbin	"../../build/stunrun-68k.bin",$048778,$2
dat_4877A:
	incbin	"../../build/stunrun-68k.bin",$04877A,$2
str_4877C:
	dc.b	'4 levels to CHALLENGE LEVEL 2 !',0
str_4879C:
	dc.b	'RAMP-ALOT:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_487A8:
	dc.b	'Catch mass air !',0
dat_487B9:
	incbin	"../../build/stunrun-68k.bin",$0487B9,$1
dat_487BA:
	incbin	"../../build/stunrun-68k.bin",$0487BA,$2
dat_487BC:
	incbin	"../../build/stunrun-68k.bin",$0487BC,$2
dat_487BE:
	incbin	"../../build/stunrun-68k.bin",$0487BE,$2
str_487C0:
	dc.b	'3 levels to CHALLENGE LEVEL 2 !',0
str_487E0:
	dc.b	'SPLIT DECISION:',0
str_487F0:
	dc.b	"Don't get lost S.T.U.N. RUNNER !",0
dat_48811:
	incbin	"../../build/stunrun-68k.bin",$048811,$1
dat_48812:
	incbin	"../../build/stunrun-68k.bin",$048812,$2
dat_48814:
	incbin	"../../build/stunrun-68k.bin",$048814,$2
dat_48816:
	incbin	"../../build/stunrun-68k.bin",$048816,$2
str_48818:
	dc.b	'2 levels to CHALLENGE LEVEL 2 !',0
str_48838:
	dc.b	'CLOSE CALL:',0
str_48844:
	dc.b	"Show ATTACK DRONES who's boss.",0
dat_48863:
	incbin	"../../build/stunrun-68k.bin",$048863,$1
dat_48864:
	incbin	"../../build/stunrun-68k.bin",$048864,$2
dat_48866:
	incbin	"../../build/stunrun-68k.bin",$048866,$2
dat_48868:
	incbin	"../../build/stunrun-68k.bin",$048868,$2
str_4886A:
	dc.b	'Next level is CHALLENGE LEVEL 2 !',0
str_4888C:
	dc.b	'THE BONUS STAR CHALLENGE:',0
dat_488A6:
	incbin	"../../build/stunrun-68k.bin",$0488A6,$2
str_488A8:
	dc.b	'Goal - Touch as many GREEN STARS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_488CA:
	dc.b	'       as possible.',0
str_488DE:
	dc.b	'THE LABYRINTH:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_488EE:
	dc.b	'Go where you wanna go !',0
dat_48906:
	incbin	"../../build/stunrun-68k.bin",$048906,$2
dat_48908:
	incbin	"../../build/stunrun-68k.bin",$048908,$2
dat_4890A:
	incbin	"../../build/stunrun-68k.bin",$04890A,$2
str_4890C:
	dc.b	'4 levels to CHALLENGE LEVEL 3 !',0
str_4892C:
	dc.b	'THE COAT-HANGER:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4893E:
	dc.b	'Zoom through WIDE and NARROW tunnels.',0
dat_48964:
	incbin	"../../build/stunrun-68k.bin",$048964,$2
dat_48966:
	incbin	"../../build/stunrun-68k.bin",$048966,$2
dat_48968:
	incbin	"../../build/stunrun-68k.bin",$048968,$2
str_4896A:
	dc.b	'3 levels to CHALLENGE LEVEL 3 !',0
str_4898A:
	dc.b	'THE CLOVER-LEAF:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4899C:
	dc.b	'Beware of lurking PROBOTS.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_489B8:
	dc.b	'CONSTRUCTION areas rob you of speed.',0
dat_489DD:
	incbin	"../../build/stunrun-68k.bin",$0489DD,$1
dat_489DE:
	incbin	"../../build/stunrun-68k.bin",$0489DE,$2
dat_489E0:
	incbin	"../../build/stunrun-68k.bin",$0489E0,$2
str_489E2:
	dc.b	'2 levels to CHALLENGE LEVEL 3 !',0
str_48A02:
	dc.b	"MCNAMARA'S REVENGE:",0
str_48A16:
	dc.b	'Deranged DRONES everywhere.',0
str_48A32:
	dc.b	'Enter at your own risk.',0
dat_48A4A:
	incbin	"../../build/stunrun-68k.bin",$048A4A,$2
dat_48A4C:
	incbin	"../../build/stunrun-68k.bin",$048A4C,$2
str_48A4E:
	dc.b	'Next level is CHALLENGE LEVEL 3 !',0
str_48A70:
	dc.b	'THE KILL CHALLENGE:',0
dat_48A84:
	incbin	"../../build/stunrun-68k.bin",$048A84,$2
str_48A86:
	dc.b	'Goal - Destroy as many vehicles',0
str_48AA6:
	dc.b	'       as possible !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48ABC:
	dc.b	'KNEE JERK:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48AC8:
	dc.b	'Endurance is the key.',0
str_48ADE:
	dc.b	'The end is in sight.',0
dat_48AF3:
	incbin	"../../build/stunrun-68k.bin",$048AF3,$1
dat_48AF4:
	incbin	"../../build/stunrun-68k.bin",$048AF4,$2
dat_48AF6:
	incbin	"../../build/stunrun-68k.bin",$048AF6,$2
str_48AF8:
	dc.b	'7 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48B1E:
	dc.b	'3-RING-CIRCUS:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48B2E:
	dc.b	'Hit BOOST PADS and leave em in your dust.',0
dat_48B58:
	incbin	"../../build/stunrun-68k.bin",$048B58,$2
dat_48B5A:
	incbin	"../../build/stunrun-68k.bin",$048B5A,$2
dat_48B5C:
	incbin	"../../build/stunrun-68k.bin",$048B5C,$2
str_48B5E:
	dc.b	'6 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48B84:
	dc.b	'PROBOT HELL:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48B92:
	dc.b	'Shoot first and ask questions later!',0
dat_48BB7:
	incbin	"../../build/stunrun-68k.bin",$048BB7,$1
dat_48BB8:
	incbin	"../../build/stunrun-68k.bin",$048BB8,$2
dat_48BBA:
	incbin	"../../build/stunrun-68k.bin",$048BBA,$2
dat_48BBC:
	incbin	"../../build/stunrun-68k.bin",$048BBC,$2
str_48BBE:
	dc.b	'5 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48BE4:
	dc.b	"SATAN'S SLALOM",0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48BF4:
	dc.b	'Devilishly wicked !',0
dat_48C08:
	incbin	"../../build/stunrun-68k.bin",$048C08,$2
dat_48C0A:
	incbin	"../../build/stunrun-68k.bin",$048C0A,$2
dat_48C0C:
	incbin	"../../build/stunrun-68k.bin",$048C0C,$2
str_48C0E:
	dc.b	'4 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48C34:
	dc.b	'THE DEATH SPIRAL:',0
str_48C46:
	dc.b	'Hang in there S.T.U.N. RUNNER ...',0
dat_48C68:
	incbin	"../../build/stunrun-68k.bin",$048C68,$2
dat_48C6A:
	incbin	"../../build/stunrun-68k.bin",$048C6A,$2
dat_48C6C:
	incbin	"../../build/stunrun-68k.bin",$048C6C,$2
str_48C6E:
	dc.b	'3 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48C94:
	dc.b	'FIGURE 8:',0
str_48C9E:
	dc.b	'Figure this one out.',0
dat_48CB3:
	incbin	"../../build/stunrun-68k.bin",$048CB3,$1
dat_48CB4:
	incbin	"../../build/stunrun-68k.bin",$048CB4,$2
dat_48CB6:
	incbin	"../../build/stunrun-68k.bin",$048CB6,$2
dat_48CB8:
	incbin	"../../build/stunrun-68k.bin",$048CB8,$2
str_48CBA:
	dc.b	'2 levels to the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48CE0:
	dc.b	'THE JIGSAW:',0
str_48CEC:
	dc.b	'Cut a path to the finish.',0
dat_48D06:
	incbin	"../../build/stunrun-68k.bin",$048D06,$2
dat_48D08:
	incbin	"../../build/stunrun-68k.bin",$048D08,$2
dat_48D0A:
	incbin	"../../build/stunrun-68k.bin",$048D0A,$2
str_48D0C:
	dc.b	'Next level is the ULTIMATE CHALLENGE !',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48D34:
	dc.b	'THE ULTIMATE CHALLENGE:',0
str_48D4C:
	dc.b	"YOU'VE MADE IT TO THE BIG TIME.",0
str_48D6C:
	dc.b	"IT'S TIME TO PROVE HOW GOOD YOU",0
str_48D8C:
	dc.b	'REALLY ARE...',0
str_48D9A:
	dc.b	'CAN YOU BEAT THE CURRENT',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48DB4:
	dc.b	'CHAMPIONS?',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_48DC0:
	dc.b	'TEST LEVEL:',0
str_48DCC:
	dc.b	'Test Track.',0
dat_48DD8:
	incbin	"../../build/stunrun-68k.bin",$048DD8,$C
dat_48DE4:
	incbin	"../../build/stunrun-68k.bin",$048DE4,$4
dat_48DE8:
	incbin	"../../build/stunrun-68k.bin",$048DE8,$3E
dat_48E26:
	incbin	"../../build/stunrun-68k.bin",$048E26,$4
dat_48E2A:
	incbin	"../../build/stunrun-68k.bin",$048E2A,$2
dat_48E2C:
	incbin	"../../build/stunrun-68k.bin",$048E2C,$2
dat_48E2E:
	incbin	"../../build/stunrun-68k.bin",$048E2E,$16E
object_descriptors:
	incbin	"../../build/stunrun-68k.bin",$048F9C,$188E
dat_4A82A:
	incbin	"../../build/stunrun-68k.bin",$04A82A,$2
dat_4A82C:
	incbin	"../../build/stunrun-68k.bin",$04A82C,$2
dat_4A82E:
	incbin	"../../build/stunrun-68k.bin",$04A82E,$2
str_4A830:
	dc.b	'OUT OF SYNC',0
str_4A83C:
	dc.b	'END GSP BUFFER',0
dat_4A84B:
	incbin	"../../build/stunrun-68k.bin",$04A84B,$41
dat_4A88C:
	incbin	"../../build/stunrun-68k.bin",$04A88C,$1E
dat_4A8AA:
	incbin	"../../build/stunrun-68k.bin",$04A8AA,$2
dat_4A8AC:
	incbin	"../../build/stunrun-68k.bin",$04A8AC,$2E
dat_4A8DA:
	incbin	"../../build/stunrun-68k.bin",$04A8DA,$20
dat_4A8FA:
	incbin	"../../build/stunrun-68k.bin",$04A8FA,$10
dat_4A90A:
	incbin	"../../build/stunrun-68k.bin",$04A90A,$10
dat_4A91A:
	incbin	"../../build/stunrun-68k.bin",$04A91A,$10
dat_4A92A:
	incbin	"../../build/stunrun-68k.bin",$04A92A,$8
dat_4A932:
	incbin	"../../build/stunrun-68k.bin",$04A932,$16
dat_4A948:
	incbin	"../../build/stunrun-68k.bin",$04A948,$C
dat_4A954:
	dc.l	str_4A998
	dc.l	str_4A9A8
	dc.l	str_4A9B4
	dc.l	str_4A9C2
	dc.l	str_4A9D6
	dc.l	str_4A9EA
	dc.l	str_4A9FA
	dc.l	str_4AA06
	dc.l	str_4AA14
	dc.l	str_4AA28
	dc.l	str_4AA3C
	dc.l	str_4AA50
	dc.l	str_4AA64
	dc.l	str_4AA78
	dc.l	str_4AA86
	dc.l	str_4AA90
	dc.l	str_4AAA2
str_4A998:
	dc.b	'WATCH DOG RESET',0
str_4A9A8:
	dc.b	'BUSS ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4A9B4:
	dc.b	'ADDRESS ERROR',0
str_4A9C2:
	dc.b	'ILLEGAL INST ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4A9D6:
	dc.b	'DIVIDE BY ZERO ERR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4A9EA:
	dc.b	'CHK INST ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4A9FA:
	dc.b	'TRAP ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4AA06:
	dc.b	'PRIV VIOL ERR',0
str_4AA14:
	dc.b	'GSP HANDSHAKE ERROR',0
str_4AA28:
	dc.b	'BAD POLY BUFF ERROR',0
str_4AA3C:
	dc.b	'MSP TIME OUT ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4AA50:
	dc.b	'ADSP TIME OUT ERROR',0
str_4AA64:
	dc.b	'GSP TIME OUT ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4AA78:
	dc.b	'GENERIC ERROR',0
str_4AA86:
	dc.b	'NMI ERROR',0
str_4AA90:
	dc.b	'SPUR EXPTN ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4AAA2:
	dc.b	'ILLEGAL ERROR CODE',0
dat_4AAB5:
	incbin	"../../build/stunrun-68k.bin",$04AAB5,$5
dat_4AABA:
	incbin	"../../build/stunrun-68k.bin",$04AABA,$202
dat_4ACBC:
	incbin	"../../build/stunrun-68k.bin",$04ACBC,$202
dat_4AEBE:
	incbin	"../../build/stunrun-68k.bin",$04AEBE,$8
dat_4AEC6:
	incbin	"../../build/stunrun-68k.bin",$04AEC6,$34
dat_4AEFA:
	incbin	"../../build/stunrun-68k.bin",$04AEFA,$16
dat_4AF10:
	incbin	"../../build/stunrun-68k.bin",$04AF10,$12
dat_4AF22:
	incbin	"../../build/stunrun-68k.bin",$04AF22,$48
dat_4AF6A:
	incbin	"../../build/stunrun-68k.bin",$04AF6A,$A
dat_4AF74:
	incbin	"../../build/stunrun-68k.bin",$04AF74,$A
dat_4AF7E:
	incbin	"../../build/stunrun-68k.bin",$04AF7E,$68
str_4AFE6:
	dc.b	'T SHIRT WINNER',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4AFF6:
	dc.b	'YOU HAVE WON A T SHIRT',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4B00E:
	incbin	"../../build/stunrun-68k.bin",$04B00E,$40
dat_4B04E:
	incbin	"../../build/stunrun-68k.bin",$04B04E,$9
dat_4B057:
	incbin	"../../build/stunrun-68k.bin",$04B057,$EB
dat_4B142:
	incbin	"../../build/stunrun-68k.bin",$04B142,$8
dat_4B14A:
	incbin	"../../build/stunrun-68k.bin",$04B14A,$8
dat_4B152:
	incbin	"../../build/stunrun-68k.bin",$04B152,$8
dat_4B15A:
	incbin	"../../build/stunrun-68k.bin",$04B15A,$8
dat_4B162:
	incbin	"../../build/stunrun-68k.bin",$04B162,$8
dat_4B16A:
	incbin	"../../build/stunrun-68k.bin",$04B16A,$8
dat_4B172:
	incbin	"../../build/stunrun-68k.bin",$04B172,$8
dat_4B17A:
	incbin	"../../build/stunrun-68k.bin",$04B17A,$8
dat_4B182:
	incbin	"../../build/stunrun-68k.bin",$04B182,$8
dat_4B18A:
	incbin	"../../build/stunrun-68k.bin",$04B18A,$8
dat_4B192:
	incbin	"../../build/stunrun-68k.bin",$04B192,$8
dat_4B19A:
	incbin	"../../build/stunrun-68k.bin",$04B19A,$8
dat_4B1A2:
	incbin	"../../build/stunrun-68k.bin",$04B1A2,$F2
dat_4B294:
	incbin	"../../build/stunrun-68k.bin",$04B294,$8
dat_4B29C:
	incbin	"../../build/stunrun-68k.bin",$04B29C,$8
dat_4B2A4:
	incbin	"../../build/stunrun-68k.bin",$04B2A4,$8
dat_4B2AC:
	incbin	"../../build/stunrun-68k.bin",$04B2AC,$8
dat_4B2B4:
	incbin	"../../build/stunrun-68k.bin",$04B2B4,$8
dat_4B2BC:
	incbin	"../../build/stunrun-68k.bin",$04B2BC,$8
dat_4B2C4:
	incbin	"../../build/stunrun-68k.bin",$04B2C4,$8
dat_4B2CC:
	incbin	"../../build/stunrun-68k.bin",$04B2CC,$8
dat_4B2D4:
	incbin	"../../build/stunrun-68k.bin",$04B2D4,$8
dat_4B2DC:
	incbin	"../../build/stunrun-68k.bin",$04B2DC,$8
dat_4B2E4:
	incbin	"../../build/stunrun-68k.bin",$04B2E4,$8
dat_4B2EC:
	incbin	"../../build/stunrun-68k.bin",$04B2EC,$8
dat_4B2F4:
	incbin	"../../build/stunrun-68k.bin",$04B2F4,$F2
dat_4B3E6:
	incbin	"../../build/stunrun-68k.bin",$04B3E6,$8
dat_4B3EE:
	incbin	"../../build/stunrun-68k.bin",$04B3EE,$8
dat_4B3F6:
	incbin	"../../build/stunrun-68k.bin",$04B3F6,$8
dat_4B3FE:
	incbin	"../../build/stunrun-68k.bin",$04B3FE,$8
dat_4B406:
	incbin	"../../build/stunrun-68k.bin",$04B406,$8
dat_4B40E:
	incbin	"../../build/stunrun-68k.bin",$04B40E,$8
dat_4B416:
	incbin	"../../build/stunrun-68k.bin",$04B416,$8
dat_4B41E:
	incbin	"../../build/stunrun-68k.bin",$04B41E,$8
dat_4B426:
	incbin	"../../build/stunrun-68k.bin",$04B426,$8
dat_4B42E:
	incbin	"../../build/stunrun-68k.bin",$04B42E,$8
dat_4B436:
	incbin	"../../build/stunrun-68k.bin",$04B436,$8
dat_4B43E:
	incbin	"../../build/stunrun-68k.bin",$04B43E,$8
dat_4B446:
	incbin	"../../build/stunrun-68k.bin",$04B446,$5A8
dat_4B9EE:
	incbin	"../../build/stunrun-68k.bin",$04B9EE,$28
dat_4BA16:
	incbin	"../../build/stunrun-68k.bin",$04BA16,$28
dat_4BA3E:
	incbin	"../../build/stunrun-68k.bin",$04BA3E,$28
dat_4BA66:
	incbin	"../../build/stunrun-68k.bin",$04BA66,$8
dat_4BA6E:
	incbin	"../../build/stunrun-68k.bin",$04BA6E,$8
dat_4BA76:
	incbin	"../../build/stunrun-68k.bin",$04BA76,$8
dat_4BA7E:
	incbin	"../../build/stunrun-68k.bin",$04BA7E,$8
dat_4BA86:
	incbin	"../../build/stunrun-68k.bin",$04BA86,$8
dat_4BA8E:
	incbin	"../../build/stunrun-68k.bin",$04BA8E,$8
dat_4BA96:
	incbin	"../../build/stunrun-68k.bin",$04BA96,$8
dat_4BA9E:
	incbin	"../../build/stunrun-68k.bin",$04BA9E,$8
dat_4BAA6:
	incbin	"../../build/stunrun-68k.bin",$04BAA6,$8
dat_4BAAE:
	incbin	"../../build/stunrun-68k.bin",$04BAAE,$8
dat_4BAB6:
	incbin	"../../build/stunrun-68k.bin",$04BAB6,$8
dat_4BABE:
	incbin	"../../build/stunrun-68k.bin",$04BABE,$8
dat_4BAC6:
	incbin	"../../build/stunrun-68k.bin",$04BAC6,$8
dat_4BACE:
	incbin	"../../build/stunrun-68k.bin",$04BACE,$8
dat_4BAD6:
	incbin	"../../build/stunrun-68k.bin",$04BAD6,$8
dat_4BADE:
	incbin	"../../build/stunrun-68k.bin",$04BADE,$8
dat_4BAE6:
	incbin	"../../build/stunrun-68k.bin",$04BAE6,$8
dat_4BAEE:
	incbin	"../../build/stunrun-68k.bin",$04BAEE,$8
dat_4BAF6:
	incbin	"../../build/stunrun-68k.bin",$04BAF6,$8
dat_4BAFE:
	incbin	"../../build/stunrun-68k.bin",$04BAFE,$8
dat_4BB06:
	incbin	"../../build/stunrun-68k.bin",$04BB06,$8
dat_4BB0E:
	incbin	"../../build/stunrun-68k.bin",$04BB0E,$8
dat_4BB16:
	incbin	"../../build/stunrun-68k.bin",$04BB16,$8
dat_4BB1E:
	incbin	"../../build/stunrun-68k.bin",$04BB1E,$8
dat_4BB26:
	incbin	"../../build/stunrun-68k.bin",$04BB26,$8
dat_4BB2E:
	incbin	"../../build/stunrun-68k.bin",$04BB2E,$8
dat_4BB36:
	incbin	"../../build/stunrun-68k.bin",$04BB36,$8
dat_4BB3E:
	incbin	"../../build/stunrun-68k.bin",$04BB3E,$8
dat_4BB46:
	incbin	"../../build/stunrun-68k.bin",$04BB46,$8
dat_4BB4E:
	incbin	"../../build/stunrun-68k.bin",$04BB4E,$8
dat_4BB56:
	incbin	"../../build/stunrun-68k.bin",$04BB56,$8
dat_4BB5E:
	incbin	"../../build/stunrun-68k.bin",$04BB5E,$8
dat_4BB66:
	incbin	"../../build/stunrun-68k.bin",$04BB66,$8
dat_4BB6E:
	incbin	"../../build/stunrun-68k.bin",$04BB6E,$8
dat_4BB76:
	incbin	"../../build/stunrun-68k.bin",$04BB76,$8
dat_4BB7E:
	incbin	"../../build/stunrun-68k.bin",$04BB7E,$8
dat_4BB86:
	incbin	"../../build/stunrun-68k.bin",$04BB86,$8
dat_4BB8E:
	incbin	"../../build/stunrun-68k.bin",$04BB8E,$8
dat_4BB96:
	incbin	"../../build/stunrun-68k.bin",$04BB96,$8
dat_4BB9E:
	incbin	"../../build/stunrun-68k.bin",$04BB9E,$8
dat_4BBA6:
	incbin	"../../build/stunrun-68k.bin",$04BBA6,$8
dat_4BBAE:
	incbin	"../../build/stunrun-68k.bin",$04BBAE,$8
dat_4BBB6:
	incbin	"../../build/stunrun-68k.bin",$04BBB6,$8
dat_4BBBE:
	incbin	"../../build/stunrun-68k.bin",$04BBBE,$8
dat_4BBC6:
	incbin	"../../build/stunrun-68k.bin",$04BBC6,$8
dat_4BBCE:
	incbin	"../../build/stunrun-68k.bin",$04BBCE,$8
dat_4BBD6:
	incbin	"../../build/stunrun-68k.bin",$04BBD6,$8
dat_4BBDE:
	incbin	"../../build/stunrun-68k.bin",$04BBDE,$8
dat_4BBE6:
	incbin	"../../build/stunrun-68k.bin",$04BBE6,$8
dat_4BBEE:
	incbin	"../../build/stunrun-68k.bin",$04BBEE,$8
dat_4BBF6:
	incbin	"../../build/stunrun-68k.bin",$04BBF6,$8
dat_4BBFE:
	incbin	"../../build/stunrun-68k.bin",$04BBFE,$8
dat_4BC06:
	incbin	"../../build/stunrun-68k.bin",$04BC06,$8
dat_4BC0E:
	incbin	"../../build/stunrun-68k.bin",$04BC0E,$8
dat_4BC16:
	incbin	"../../build/stunrun-68k.bin",$04BC16,$8
dat_4BC1E:
	incbin	"../../build/stunrun-68k.bin",$04BC1E,$8
dat_4BC26:
	incbin	"../../build/stunrun-68k.bin",$04BC26,$8
dat_4BC2E:
	incbin	"../../build/stunrun-68k.bin",$04BC2E,$8
dat_4BC36:
	incbin	"../../build/stunrun-68k.bin",$04BC36,$8
dat_4BC3E:
	incbin	"../../build/stunrun-68k.bin",$04BC3E,$8
dat_4BC46:
	incbin	"../../build/stunrun-68k.bin",$04BC46,$8
dat_4BC4E:
	incbin	"../../build/stunrun-68k.bin",$04BC4E,$8
dat_4BC56:
	incbin	"../../build/stunrun-68k.bin",$04BC56,$8
dat_4BC5E:
	incbin	"../../build/stunrun-68k.bin",$04BC5E,$8
dat_4BC66:
	incbin	"../../build/stunrun-68k.bin",$04BC66,$8
dat_4BC6E:
	incbin	"../../build/stunrun-68k.bin",$04BC6E,$8
dat_4BC76:
	incbin	"../../build/stunrun-68k.bin",$04BC76,$8
dat_4BC7E:
	incbin	"../../build/stunrun-68k.bin",$04BC7E,$8
dat_4BC86:
	incbin	"../../build/stunrun-68k.bin",$04BC86,$8
dat_4BC8E:
	incbin	"../../build/stunrun-68k.bin",$04BC8E,$8
dat_4BC96:
	incbin	"../../build/stunrun-68k.bin",$04BC96,$8
dat_4BC9E:
	incbin	"../../build/stunrun-68k.bin",$04BC9E,$8
dat_4BCA6:
	incbin	"../../build/stunrun-68k.bin",$04BCA6,$8
dat_4BCAE:
	incbin	"../../build/stunrun-68k.bin",$04BCAE,$8
dat_4BCB6:
	incbin	"../../build/stunrun-68k.bin",$04BCB6,$8
dat_4BCBE:
	incbin	"../../build/stunrun-68k.bin",$04BCBE,$8
dat_4BCC6:
	incbin	"../../build/stunrun-68k.bin",$04BCC6,$8
dat_4BCCE:
	incbin	"../../build/stunrun-68k.bin",$04BCCE,$8
dat_4BCD6:
	incbin	"../../build/stunrun-68k.bin",$04BCD6,$8
dat_4BCDE:
	incbin	"../../build/stunrun-68k.bin",$04BCDE,$3E
dat_4BD1C:
	incbin	"../../build/stunrun-68k.bin",$04BD1C,$8
dat_4BD24:
	incbin	"../../build/stunrun-68k.bin",$04BD24,$8
dat_4BD2C:
	incbin	"../../build/stunrun-68k.bin",$04BD2C,$8
dat_4BD34:
	incbin	"../../build/stunrun-68k.bin",$04BD34,$30
dat_4BD64:
	incbin	"../../build/stunrun-68k.bin",$04BD64,$C
dat_4BD70:
	incbin	"../../build/stunrun-68k.bin",$04BD70,$1A
dat_4BD8A:
	incbin	"../../build/stunrun-68k.bin",$04BD8A,$440
dat_4C1CA:
	incbin	"../../build/stunrun-68k.bin",$04C1CA,$50
dat_4C21A:
	incbin	"../../build/stunrun-68k.bin",$04C21A,$8
dat_4C222:
	incbin	"../../build/stunrun-68k.bin",$04C222,$2C
dat_4C24E:
	incbin	"../../build/stunrun-68k.bin",$04C24E,$2C
dat_4C27A:
	incbin	"../../build/stunrun-68k.bin",$04C27A,$2C
dat_4C2A6:
	incbin	"../../build/stunrun-68k.bin",$04C2A6,$74
dat_4C31A:
	incbin	"../../build/stunrun-68k.bin",$04C31A,$C
dat_4C326:
	incbin	"../../build/stunrun-68k.bin",$04C326,$C
dat_4C332:
	incbin	"../../build/stunrun-68k.bin",$04C332,$10
dat_4C342:
	incbin	"../../build/stunrun-68k.bin",$04C342,$10
dat_4C352:
	incbin	"../../build/stunrun-68k.bin",$04C352,$10
dat_4C362:
	incbin	"../../build/stunrun-68k.bin",$04C362,$7C
dat_4C3DE:
	incbin	"../../build/stunrun-68k.bin",$04C3DE,$1E
dat_4C3FC:
	incbin	"../../build/stunrun-68k.bin",$04C3FC,$74
dat_4C470:
	incbin	"../../build/stunrun-68k.bin",$04C470,$8
dat_4C478:
	incbin	"../../build/stunrun-68k.bin",$04C478,$8
dat_4C480:
	incbin	"../../build/stunrun-68k.bin",$04C480,$8
dat_4C488:
	incbin	"../../build/stunrun-68k.bin",$04C488,$8
dat_4C490:
	incbin	"../../build/stunrun-68k.bin",$04C490,$8
dat_4C498:
	incbin	"../../build/stunrun-68k.bin",$04C498,$8
dat_4C4A0:
	incbin	"../../build/stunrun-68k.bin",$04C4A0,$D2
dat_4C572:
	incbin	"../../build/stunrun-68k.bin",$04C572,$8
dat_4C57A:
	incbin	"../../build/stunrun-68k.bin",$04C57A,$C
dat_4C586:
	incbin	"../../build/stunrun-68k.bin",$04C586,$C
dat_4C592:
	incbin	"../../build/stunrun-68k.bin",$04C592,$C
dat_4C59E:
	incbin	"../../build/stunrun-68k.bin",$04C59E,$C
dat_4C5AA:
	incbin	"../../build/stunrun-68k.bin",$04C5AA,$C
dat_4C5B6:
	incbin	"../../build/stunrun-68k.bin",$04C5B6,$C
dat_4C5C2:
	incbin	"../../build/stunrun-68k.bin",$04C5C2,$C
dat_4C5CE:
	incbin	"../../build/stunrun-68k.bin",$04C5CE,$C
dat_4C5DA:
	incbin	"../../build/stunrun-68k.bin",$04C5DA,$C
dat_4C5E6:
	incbin	"../../build/stunrun-68k.bin",$04C5E6,$C
dat_4C5F2:
	incbin	"../../build/stunrun-68k.bin",$04C5F2,$C
dat_4C5FE:
	incbin	"../../build/stunrun-68k.bin",$04C5FE,$C
dat_4C60A:
	incbin	"../../build/stunrun-68k.bin",$04C60A,$C
dat_4C616:
	incbin	"../../build/stunrun-68k.bin",$04C616,$C
dat_4C622:
	incbin	"../../build/stunrun-68k.bin",$04C622,$C
dat_4C62E:
	incbin	"../../build/stunrun-68k.bin",$04C62E,$C
dat_4C63A:
	incbin	"../../build/stunrun-68k.bin",$04C63A,$C
dat_4C646:
	incbin	"../../build/stunrun-68k.bin",$04C646,$C
dat_4C652:
	incbin	"../../build/stunrun-68k.bin",$04C652,$C
dat_4C65E:
	incbin	"../../build/stunrun-68k.bin",$04C65E,$C
dat_4C66A:
	incbin	"../../build/stunrun-68k.bin",$04C66A,$C
dat_4C676:
	incbin	"../../build/stunrun-68k.bin",$04C676,$C
dat_4C682:
	incbin	"../../build/stunrun-68k.bin",$04C682,$C
dat_4C68E:
	incbin	"../../build/stunrun-68k.bin",$04C68E,$C
dat_4C69A:
	incbin	"../../build/stunrun-68k.bin",$04C69A,$1E
dat_4C6B8:
	incbin	"../../build/stunrun-68k.bin",$04C6B8,$42
dat_4C6FA:
	incbin	"../../build/stunrun-68k.bin",$04C6FA,$8
dat_4C702:
	incbin	"../../build/stunrun-68k.bin",$04C702,$8
dat_4C70A:
	incbin	"../../build/stunrun-68k.bin",$04C70A,$8
dat_4C712:
	dc.l	0
	dc.l	dat_4BA3E
	dc.l	dat_4BA86
	dc.l	dat_4BA8E
	dc.l	dat_4BA96
	dc.l	dat_4BA9E
	dc.l	dat_4BAA6
	dc.l	dat_4BAAE
	dc.l	dat_4BAB6
	dc.l	dat_4BABE
	dc.l	dat_4BAC6
	dc.l	dat_4BACE
	dc.l	dat_4BAD6
	dc.l	dat_4BADE
	dc.l	dat_4BAE6
	dc.l	dat_4BAEE
	dc.l	dat_4BAF6
	dc.l	dat_4BAFE
	dc.l	dat_4BB06
	dc.l	dat_4BB0E
	dc.l	dat_4BB16
	dc.l	dat_4BB1E
	dc.l	dat_4BB26
	dc.l	dat_4BB2E
	dc.l	dat_4BB36
	dc.l	dat_4BB3E
	dc.l	dat_4BB46
	dc.l	dat_4BB4E
	dc.l	dat_4BB56
	dc.l	dat_4BB5E
	dc.l	dat_4BB66
	dc.l	dat_4BB6E
	dc.l	dat_4BB76
	dc.l	dat_4BB7E
	dc.l	dat_4BB86
	dc.l	dat_4BB8E
	dc.l	dat_4BB96
	dc.l	dat_4BB9E
	dc.l	dat_4BBA6
	dc.l	dat_4BBAE
	dc.l	dat_4BBB6
	dc.l	dat_4BBBE
	dc.l	dat_4BBC6
	dc.l	dat_4BBCE
	dc.l	dat_4BBD6
	dc.l	dat_4BBDE
	dc.l	dat_4BBE6
	dc.l	dat_4BBEE
	dc.l	dat_4BBF6
	dc.l	dat_4BBFE
	dc.l	dat_4BC06
	dc.l	dat_4BC0E
	dc.l	dat_4BC16
	dc.l	dat_4BC1E
	dc.l	dat_4BC26
	dc.l	dat_4BC2E
	dc.l	dat_4BC36
	dc.l	dat_4BC3E
	dc.l	dat_4BC46
	dc.l	dat_4BC4E
	dc.l	dat_4BC56
	dc.l	dat_4BC5E
	dc.l	dat_4BC66
	dc.l	dat_4BC6E
	dc.l	dat_4BC76
	dc.l	dat_4BC7E
	dc.l	dat_4BC86
	dc.l	dat_4BC8E
	dc.l	dat_4BC96
	dc.l	dat_4BC9E
	dc.l	dat_4BCA6
	dc.l	dat_4BCAE
	dc.l	dat_4BCB6
	dc.l	dat_4BCBE
	dc.l	dat_4BCC6
	dc.l	dat_4BCCE
	dc.l	dat_4BCD6
	dc.l	dat_4BCDE
	dc.l	dat_4BA66
	dc.l	dat_4BA6E
	dc.l	dat_4BA76
	dc.l	dat_4BA7E
	dc.l	dat_4BD64
	dc.l	dat_4BD70
	dc.l	dat_4C31A
	dc.l	dat_4C326
	dc.l	dat_4C470
	dc.l	dat_4C478
	dc.l	dat_4C480
	dc.l	dat_4C488
	dc.l	dat_4C490
	dc.l	dat_4C498
	dc.l	dat_4C4A0
	dc.l	dat_4C572
	dc.l	dat_4C57A
	dc.l	dat_4C586
	dc.l	dat_4C592
	dc.l	dat_4C59E
	dc.l	dat_4C5AA
	dc.l	dat_4C5B6
	dc.l	dat_4C5C2
	dc.l	dat_4C5CE
	dc.l	dat_4C5DA
	dc.l	dat_4C5E6
	dc.l	dat_4C5F2
	dc.l	dat_4C5FE
	dc.l	dat_4C60A
	dc.l	dat_4C616
	dc.l	dat_4C622
	dc.l	dat_4C62E
	dc.l	dat_4C63A
	dc.l	dat_4C646
	dc.l	dat_4C652
	dc.l	dat_4C65E
	dc.l	dat_4C66A
	dc.l	dat_4C676
	dc.l	dat_4C682
	dc.l	dat_4C68E
	dc.l	dat_4C69A
	dc.l	dat_4C6B8
	dc.l	dat_4BD1C
	dc.l	dat_4BD24
	dc.l	dat_4BD2C
	dc.l	dat_4BD34
	dc.l	dat_4C3DE
	dc.l	dat_4C1CA
	dc.l	dat_4C21A
	dc.l	dat_4C222
	dc.l	dat_4C24E
	dc.l	dat_4C27A
	dc.l	dat_4C2A6
	dc.l	dat_4B294
	dc.l	dat_4B29C
	dc.l	dat_4B2A4
	dc.l	dat_4B2AC
	dc.l	dat_4B2B4
	dc.l	dat_4B2BC
	dc.l	dat_4B2C4
	dc.l	dat_4B2CC
	dc.l	dat_4B2D4
	dc.l	dat_4B2DC
	dc.l	dat_4B2E4
	dc.l	dat_4B2EC
	dc.l	dat_4B2F4
	dc.l	dat_4B142
	dc.l	dat_4B14A
	dc.l	dat_4B152
	dc.l	dat_4B15A
	dc.l	dat_4B162
	dc.l	dat_4B16A
	dc.l	dat_4B172
	dc.l	dat_4B17A
	dc.l	dat_4B182
	dc.l	dat_4B18A
	dc.l	dat_4B192
	dc.l	dat_4B19A
	dc.l	dat_4B1A2
	dc.l	dat_4C6FA
	dc.l	dat_4C702
	dc.l	dat_4C70A
	dc.l	dat_4C3FC
	dc.l	dat_4BD8A
	dc.l	dat_4C332
	dc.l	dat_4C342
	dc.l	dat_4C352
	dc.l	dat_4C362
	dc.l	dat_4B3E6
	dc.l	dat_4B3EE
	dc.l	dat_4B3F6
	dc.l	dat_4B3FE
	dc.l	dat_4B406
	dc.l	dat_4B40E
	dc.l	dat_4B416
	dc.l	dat_4B41E
	dc.l	dat_4B426
	dc.l	dat_4B42E
	dc.l	dat_4B436
	dc.l	dat_4B43E
	dc.l	dat_4B446
	dc.l	dat_4B9EE
	dc.l	dat_4BA16
	dc.l	0
dat_4C9EA:
	incbin	"../../build/stunrun-68k.bin",$04C9EA,$132
dat_4CB1C:
	incbin	"../../build/stunrun-68k.bin",$04CB1C,$1A
dat_4CB36:
	incbin	"../../build/stunrun-68k.bin",$04CB36,$AB6
dat_4D5EC:
	incbin	"../../build/stunrun-68k.bin",$04D5EC,$3C
dat_4D628:
	dc.l	dat_4D5EC
	dc.l	dat_503FC
	dc.l	dat_509C8
	dc.l	dat_544C0
	dc.l	dat_57B5C
	dc.l	dat_5B998
	dc.l	dat_51FA0
	dc.l	dat_589B8
	dc.l	dat_52C9C
	dc.l	dat_53ED4
	dc.l	dat_5AF3C
	dc.l	dat_554F8
	dc.l	dat_534F8
	dc.l	dat_526E8
	dc.l	dat_56384
	dc.l	dat_511E0
	dc.l	dat_51934
	dc.l	dat_54E20
	dc.l	dat_56EFC
	dc.l	dat_573C0
	dc.l	dat_58238
	dc.l	dat_59028
	dc.l	dat_596A4
	dc.l	dat_5A5B4
	dc.l	dat_503FC
dat_4D68C:
	incbin	"../../build/stunrun-68k.bin",$04D68C,$4
dat_4D690:
	incbin	"../../build/stunrun-68k.bin",$04D690,$4
dat_4D694:
	incbin	"../../build/stunrun-68k.bin",$04D694,$14
dat_4D6A8:
	incbin	"../../build/stunrun-68k.bin",$04D6A8,$2
dat_4D6AA:
	incbin	"../../build/stunrun-68k.bin",$04D6AA,$BA
dat_4D764:
	incbin	"../../build/stunrun-68k.bin",$04D764,$D
dat_4D771:
	incbin	"../../build/stunrun-68k.bin",$04D771,$2
dat_4D773:
	incbin	"../../build/stunrun-68k.bin",$04D773,$5
dat_4D778:
	incbin	"../../build/stunrun-68k.bin",$04D778,$28
dat_4D7A0:
	incbin	"../../build/stunrun-68k.bin",$04D7A0,$A
dat_4D7AA:
	incbin	"../../build/stunrun-68k.bin",$04D7AA,$2C
dat_4D7D6:
	incbin	"../../build/stunrun-68k.bin",$04D7D6,$38
dat_4D80E:
	incbin	"../../build/stunrun-68k.bin",$04D80E,$18
dat_4D826:
	incbin	"../../build/stunrun-68k.bin",$04D826,$2
dat_4D828:
	incbin	"../../build/stunrun-68k.bin",$04D828,$4
dat_4D82C:
	incbin	"../../build/stunrun-68k.bin",$04D82C,$2
dat_4D82E:
	incbin	"../../build/stunrun-68k.bin",$04D82E,$2
dat_4D830:
	incbin	"../../build/stunrun-68k.bin",$04D830,$2
dat_4D832:
	incbin	"../../build/stunrun-68k.bin",$04D832,$2
dat_4D834:
	incbin	"../../build/stunrun-68k.bin",$04D834,$2
dat_4D836:
	incbin	"../../build/stunrun-68k.bin",$04D836,$2
dat_4D838:
	incbin	"../../build/stunrun-68k.bin",$04D838,$2
dat_4D83A:
	incbin	"../../build/stunrun-68k.bin",$04D83A,$2
dat_4D83C:
	incbin	"../../build/stunrun-68k.bin",$04D83C,$4
dat_4D840:
	incbin	"../../build/stunrun-68k.bin",$04D840,$9
dat_4D849:
	incbin	"../../build/stunrun-68k.bin",$04D849,$2
dat_4D84B:
	incbin	"../../build/stunrun-68k.bin",$04D84B,$1
dat_4D84C:
	incbin	"../../build/stunrun-68k.bin",$04D84C,$2
dat_4D84E:
	incbin	"../../build/stunrun-68k.bin",$04D84E,$2
dat_4D850:
	incbin	"../../build/stunrun-68k.bin",$04D850,$8
dat_4D858:
	incbin	"../../build/stunrun-68k.bin",$04D858,$8
dat_4D860:
	incbin	"../../build/stunrun-68k.bin",$04D860,$8
dat_4D868:
	incbin	"../../build/stunrun-68k.bin",$04D868,$734
dat_4DF9C:
	incbin	"../../build/stunrun-68k.bin",$04DF9C,$252
dat_4E1EE:
	incbin	"../../build/stunrun-68k.bin",$04E1EE,$2
dat_4E1F0:
	incbin	"../../build/stunrun-68k.bin",$04E1F0,$2
dat_4E1F2:
	incbin	"../../build/stunrun-68k.bin",$04E1F2,$2
dat_4E1F4:
	incbin	"../../build/stunrun-68k.bin",$04E1F4,$2
dat_4E1F6:
	incbin	"../../build/stunrun-68k.bin",$04E1F6,$2
dat_4E1F8:
	incbin	"../../build/stunrun-68k.bin",$04E1F8,$2
dat_4E1FA:
	incbin	"../../build/stunrun-68k.bin",$04E1FA,$2
dat_4E1FC:
	incbin	"../../build/stunrun-68k.bin",$04E1FC,$A
dat_4E206:
	incbin	"../../build/stunrun-68k.bin",$04E206,$8
dat_4E20E:
	incbin	"../../build/stunrun-68k.bin",$04E20E,$A
dat_4E218:
	incbin	"../../build/stunrun-68k.bin",$04E218,$C
dat_4E224:
	incbin	"../../build/stunrun-68k.bin",$04E224,$2
dat_4E226:
	incbin	"../../build/stunrun-68k.bin",$04E226,$C
dat_4E232:
	incbin	"../../build/stunrun-68k.bin",$04E232,$C
dat_4E23E:
	incbin	"../../build/stunrun-68k.bin",$04E23E,$C
dat_4E24A:
	incbin	"../../build/stunrun-68k.bin",$04E24A,$2
dat_4E24C:
	incbin	"../../build/stunrun-68k.bin",$04E24C,$28
dat_4E274:
	incbin	"../../build/stunrun-68k.bin",$04E274,$28
dat_4E29C:
	incbin	"../../build/stunrun-68k.bin",$04E29C,$28
dat_4E2C4:
	incbin	"../../build/stunrun-68k.bin",$04E2C4,$28
dat_4E2EC:
	incbin	"../../build/stunrun-68k.bin",$04E2EC,$28
dat_4E314:
	incbin	"../../build/stunrun-68k.bin",$04E314,$28
dat_4E33C:
	incbin	"../../build/stunrun-68k.bin",$04E33C,$28
dat_4E364:
	incbin	"../../build/stunrun-68k.bin",$04E364,$28
dat_4E38C:
	incbin	"../../build/stunrun-68k.bin",$04E38C,$28
dat_4E3B4:
	dc.l	dat_4E24C
	dc.l	dat_4E274
	dc.l	dat_4E29C
	dc.l	dat_4E2C4
	dc.l	dat_4E2EC
	dc.l	dat_4E314
	dc.l	dat_4E33C
	dc.l	dat_4E364
	dc.l	dat_4E38C
dat_4E3D8:
	dc.l	dat_4E1FC
	dc.l	dat_4E1FC
	dc.l	dat_4E1FC
	dc.l	dat_4E206
	dc.l	dat_4E218
	dc.l	dat_4E224
	dc.l	dat_4E20E
	dc.l	dat_4E226
	dc.l	dat_4E232
	dc.l	dat_4E23E
	dc.l	dat_4E24A
	dc.l	dat_4E232
dat_4E408:
	incbin	"../../build/stunrun-68k.bin",$04E408,$2
str_4E40A:
	dc.b	'YOUR NAME HAS BEEN ENTERED',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E426:
	dc.b	'TO THE HIGH SCORES',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E43A:
	dc.b	'ENTER NAME TO HIGH SCORES',0
str_4E454:
	dc.b	'TURN CONTROL TO SELECT LETTER, PRESS TRIGGER TO CHOOSE',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4E48C:
	incbin	"../../build/stunrun-68k.bin",$04E48C,$4
str_4E490:
	dc.b	'YOUR NAME HAS BEEN ENTERED',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E4AC:
	dc.b	'THE CHALLENGE WINNERS',0
str_4E4C2:
	dc.b	'ENTER NAME TO CHALLENGE WINNERS',0
str_4E4E2:
	dc.b	'TURN CONTROL TO SELECT LETTER, PRESS TRIGGER TO CHOOSE',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4E51A:
	incbin	"../../build/stunrun-68k.bin",$04E51A,$4
str_4E51E:
	dc.b	'YOUR NAME HAS BEEN ENTERED',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E53A:
	dc.b	'THE STAR MASTERS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E54C:
	dc.b	'THE SHARPSHOOTERS',0
str_4E55E:
	dc.b	'THE BOOST BUSTERS',0
str_4E570:
	dc.b	'ENTER NAME TO STAR MASTERS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E58C:
	dc.b	'ENTER NAME TO SHARPSHOOTERS',0
str_4E5A8:
	dc.b	'ENTER NAME TO BOOSTER BUNCH',0
str_4E5C4:
	dc.b	'TURN CONTROL TO SELECT LETTER, PRESS TRIGGER TO CHOOSE',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4E5FC:
	incbin	"../../build/stunrun-68k.bin",$04E5FC,$4
dat_4E600:
	incbin	"../../build/stunrun-68k.bin",$04E600,$8
dat_4E608:
	incbin	"../../build/stunrun-68k.bin",$04E608,$4
dat_4E60C:
	incbin	"../../build/stunrun-68k.bin",$04E60C,$4
dat_4E610:
	incbin	"../../build/stunrun-68k.bin",$04E610,$6
dat_4E616:
	incbin	"../../build/stunrun-68k.bin",$04E616,$8
dat_4E61E:
	incbin	"../../build/stunrun-68k.bin",$04E61E,$4
dat_4E622:
	incbin	"../../build/stunrun-68k.bin",$04E622,$2
dat_4E624:
	incbin	"../../build/stunrun-68k.bin",$04E624,$4
dat_4E628:
	incbin	"../../build/stunrun-68k.bin",$04E628,$4
dat_4E62C:
	incbin	"../../build/stunrun-68k.bin",$04E62C,$2
dat_4E62E:
	incbin	"../../build/stunrun-68k.bin",$04E62E,$4
dat_4E632:
	incbin	"../../build/stunrun-68k.bin",$04E632,$6
dat_4E638:
	incbin	"../../build/stunrun-68k.bin",$04E638,$6
str_4E63E:
	dc.b	'BOOSTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4E646:
	incbin	"../../build/stunrun-68k.bin",$04E646,$8
dat_4E64E:
	incbin	"../../build/stunrun-68k.bin",$04E64E,$4
dat_4E652:
	incbin	"../../build/stunrun-68k.bin",$04E652,$4
str_4E656:
	dc.b	'WORLD CLASS STUN RUNNERS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E670:
	dc.b	'PRESS START BUTTON',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E684:
	dc.b	'INSERT COINS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E692:
	dc.b	'YOU DID NOT QUALIFY',0
str_4E6A6:
	dc.b	'AS A STAR MASTER',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E6B8:
	dc.b	'AS A SHARPSHOOTER',0
str_4E6CA:
	dc.b	'FOR THE BOOSTER BUNCH',0
dat_4E6E0:
	incbin	"../../build/stunrun-68k.bin",$04E6E0,$6
str_4E6E6:
	dc.b	'   YOUR TOTAL',0
dat_4E6F4:
	incbin	"../../build/stunrun-68k.bin",$04E6F4,$4
dat_4E6F8:
	incbin	"../../build/stunrun-68k.bin",$04E6F8,$8
dat_4E700:
	incbin	"../../build/stunrun-68k.bin",$04E700,$4
dat_4E704:
	incbin	"../../build/stunrun-68k.bin",$04E704,$4
dat_4E708:
	incbin	"../../build/stunrun-68k.bin",$04E708,$2
dat_4E70A:
	incbin	"../../build/stunrun-68k.bin",$04E70A,$4
dat_4E70E:
	incbin	"../../build/stunrun-68k.bin",$04E70E,$4
dat_4E712:
	incbin	"../../build/stunrun-68k.bin",$04E712,$4
str_4E716:
	dc.b	'YOU HAVE WON A FREE T SHIRT',0
str_4E732:
	dc.b	'Offer Expires April 1, 1990',0
str_4E74E:
	dc.b	'Limit 1 per person.          Quantities Limited.',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E780:
	dc.b	'To get your secret code:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E79A:
	dc.b	'Please enter your initials',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E7B6:
	dc.b	'To get your secret code:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E7D0:
	dc.b	'Please select the month you were born',0
str_4E7F6:
	dc.b	'To get your secret code:',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E810:
	dc.b	'Please select the day you were born',0
dat_4E834:
	incbin	"../../build/stunrun-68k.bin",$04E834,$8
dat_4E83C:
	incbin	"../../build/stunrun-68k.bin",$04E83C,$4
str_4E840:
	dc.b	'Please send your CODE #, Name, Address, Phone #,',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4E872:
	dc.b	'Date of Birth, Age, Adult T-Shirt Size (S,M,L,XL)',0
dat_4E8A4:
	incbin	"../../build/stunrun-68k.bin",$04E8A4,$4
str_4E8A8:
	dc.b	'  S.T.U.N. Runner T-Shirt',0
dat_4E8C2:
	incbin	"../../build/stunrun-68k.bin",$04E8C2,$12
dat_4E8D4:
	incbin	"../../build/stunrun-68k.bin",$04E8D4,$1A
str_4E8EE:
	dc.b	'THIS IS YOUR SECRET CODE:',0
dat_4E908:
	incbin	"../../build/stunrun-68k.bin",$04E908,$C
str_4E914:
	dc.b	'Remember this code and write it down.',0
str_4E93A:
	dc.b	'To Exit, Press START and TRIGGER',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4E95C:
	incbin	"../../build/stunrun-68k.bin",$04E95C,$9E
str_4E9FA:
	dc.b	'MOTHERFUCKER',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4EA08:
	dc.b	'BASTARD',0
str_4EA10:
	dc.b	'ASSHOLE',0
str_4EA18:
	dc.b	'NIGGER',0
dat_4EA1F:
	incbin	"../../build/stunrun-68k.bin",$04EA1F,$7
str_4EA26:
	dc.b	'VAGINA',0
dat_4EA2D:
	incbin	"../../build/stunrun-68k.bin",$04EA2D,$7
str_4EA34:
	dc.b	'EAT MY DICK',0
dat_4EA40:
	incbin	"../../build/stunrun-68k.bin",$04EA40,$10
str_4EA50:
	dc.b	'MY DICK',0
str_4EA58:
	dc.b	'EAT DICK',0
dat_4EA61:
	incbin	"../../build/stunrun-68k.bin",$04EA61,$9
dat_4EA6A:
	dc.l	dat_4EA9A
	dc.l	dat_4EAA0
	dc.l	dat_4EAA6
	dc.l	dat_4EAAC
	dc.l	dat_4EAB2
	dc.l	dat_4EAB8
	dc.l	dat_4EABE
	dc.l	dat_4EAC4
	dc.l	dat_4EACA
	dc.l	dat_4EAD0
	dc.l	dat_4EAD6
	dc.l	dat_4EADC
dat_4EA9A:
	incbin	"../../build/stunrun-68k.bin",$04EA9A,$6
dat_4EAA0:
	incbin	"../../build/stunrun-68k.bin",$04EAA0,$6
dat_4EAA6:
	incbin	"../../build/stunrun-68k.bin",$04EAA6,$6
dat_4EAAC:
	incbin	"../../build/stunrun-68k.bin",$04EAAC,$6
dat_4EAB2:
	incbin	"../../build/stunrun-68k.bin",$04EAB2,$6
dat_4EAB8:
	incbin	"../../build/stunrun-68k.bin",$04EAB8,$6
dat_4EABE:
	incbin	"../../build/stunrun-68k.bin",$04EABE,$6
dat_4EAC4:
	incbin	"../../build/stunrun-68k.bin",$04EAC4,$6
dat_4EACA:
	incbin	"../../build/stunrun-68k.bin",$04EACA,$6
dat_4EAD0:
	incbin	"../../build/stunrun-68k.bin",$04EAD0,$6
dat_4EAD6:
	incbin	"../../build/stunrun-68k.bin",$04EAD6,$6
dat_4EADC:
	incbin	"../../build/stunrun-68k.bin",$04EADC,$6
dat_4EAE2:
	incbin	"../../build/stunrun-68k.bin",$04EAE2,$8
str_4EAEA:
	dc.b	'THE GONZ',0
dat_4EAF3:
	incbin	"../../build/stunrun-68k.bin",$04EAF3,$2F
str_4EB22:
	dc.b	'GUNNER GLENN',0
dat_4EB2F:
	incbin	"../../build/stunrun-68k.bin",$04EB2F,$F
str_4EB3E:
	dc.b	'BAD BABE',0
dat_4EB47:
	incbin	"../../build/stunrun-68k.bin",$04EB47,$13
str_4EB5A:
	dc.b	'THE POTATOE',0
dat_4EB66:
	incbin	"../../build/stunrun-68k.bin",$04EB66,$8
dat_4EB6E:
	incbin	"../../build/stunrun-68k.bin",$04EB6E,$1
str_4EB6F:
	dc.b	'(SCOOTER',0
dat_4EB78:
	incbin	"../../build/stunrun-68k.bin",$04EB78,$D
str_4EB85:
	dc.b	'#THE HOOPLE',0
dat_4EB91:
	incbin	"../../build/stunrun-68k.bin",$04EB91,$B
str_4EB9C:
	dc.b	'RANGER RICK',0
dat_4EBA8:
	incbin	"../../build/stunrun-68k.bin",$04EBA8,$34
dat_4EBDC:
	incbin	"../../build/stunrun-68k.bin",$04EBDC,$44
str_4EC20:
	dc.b	'ERIK NOT THE RED',0
dat_4EC31:
	incbin	"../../build/stunrun-68k.bin",$04EC31,$5
str_4EC36:
	dc.b	'UNCLE MILTY',0
dat_4EC42:
	incbin	"../../build/stunrun-68k.bin",$04EC42,$8
dat_4EC4A:
	incbin	"../../build/stunrun-68k.bin",$04EC4A,$2
str_4EC4C:
	dc.b	'DIRTY DON',0
dat_4EC56:
	incbin	"../../build/stunrun-68k.bin",$04EC56,$C
str_4EC62:
	dc.b	'RIGHTEOUS RALPH',0
dat_4EC72:
	incbin	"../../build/stunrun-68k.bin",$04EC72,$6
str_4EC78:
	dc.b	'HAPPY HATA',0
dat_4EC83:
	incbin	"../../build/stunrun-68k.bin",$04EC83,$35
dat_4ECB8:
	incbin	"../../build/stunrun-68k.bin",$04ECB8,$4
str_4ECBC:
	dc.b	'THE GONZ',0
dat_4ECC5:
	incbin	"../../build/stunrun-68k.bin",$04ECC5,$27
str_4ECEC:
	dc.b	'GUNNER GLENN',0
dat_4ECF9:
	incbin	"../../build/stunrun-68k.bin",$04ECF9,$22
str_4ED1B:
	dc.b	'XTHE POTATOE',0
dat_4ED28:
	incbin	"../../build/stunrun-68k.bin",$04ED28,$C
str_4ED34:
	dc.b	'SCOOTER',0
dat_4ED3C:
	incbin	"../../build/stunrun-68k.bin",$04ED3C,$10
str_4ED4C:
	dc.b	'THE HOOPLE',0
dat_4ED57:
	incbin	"../../build/stunrun-68k.bin",$04ED57,$D
str_4ED64:
	dc.b	'RANGER RICK',0
dat_4ED70:
	incbin	"../../build/stunrun-68k.bin",$04ED70,$38
str_4EDA8:
	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ '
dat_4EDC3:
	incbin	"../../build/stunrun-68k.bin",$04EDC3,$23
dat_4EDE6:
	incbin	"../../build/stunrun-68k.bin",$04EDE6,$68
dat_4EE4E:
	incbin	"../../build/stunrun-68k.bin",$04EE4E,$1A
dat_4EE68:
	incbin	"../../build/stunrun-68k.bin",$04EE68,$3C
dat_4EEA4:
	incbin	"../../build/stunrun-68k.bin",$04EEA4,$8
dat_4EEAC:
	incbin	"../../build/stunrun-68k.bin",$04EEAC,$10
dat_4EEBC:
	incbin	"../../build/stunrun-68k.bin",$04EEBC,$8
dat_4EEC4:
	incbin	"../../build/stunrun-68k.bin",$04EEC4,$8
dat_4EECC:
	incbin	"../../build/stunrun-68k.bin",$04EECC,$8
dat_4EED4:
	incbin	"../../build/stunrun-68k.bin",$04EED4,$8
dat_4EEDC:
	incbin	"../../build/stunrun-68k.bin",$04EEDC,$8
dat_4EEE4:
	incbin	"../../build/stunrun-68k.bin",$04EEE4,$8
dat_4EEEC:
	incbin	"../../build/stunrun-68k.bin",$04EEEC,$8
dat_4EEF4:
	incbin	"../../build/stunrun-68k.bin",$04EEF4,$8
dat_4EEFC:
	incbin	"../../build/stunrun-68k.bin",$04EEFC,$8
dat_4EF04:
	incbin	"../../build/stunrun-68k.bin",$04EF04,$8
dat_4EF0C:
	incbin	"../../build/stunrun-68k.bin",$04EF0C,$4
str_4EF10:
	dc.b	'indestructable',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4EF20:
	incbin	"../../build/stunrun-68k.bin",$04EF20,$30
str_4EF50:
	dc.b	'STAY OFF INSIDE WALL OF TURNS',0
str_4EF6E:
	dc.b	'PRESS START TO FIRE SHOCKWAVE',0
str_4EF8C:
	dc.b	'BOOST PAD INCREASES SPEED',0
str_4EFA6:
	dc.b	'ARMORED DRONE IS INDESTRUCTIBLE',0
dat_4EFC6:
	incbin	"../../build/stunrun-68k.bin",$04EFC6,$90
dat_4F056:
	incbin	"../../build/stunrun-68k.bin",$04F056,$30
str_4F086:
	dc.b	'Train Car',0
dat_4F090:
	incbin	"../../build/stunrun-68k.bin",$04F090,$6
str_4F096:
	dc.b	'Train Car',0
str_4F0A0:
	dc.b	'Mag Cycle',0
str_4F0AA:
	dc.b	'Lorrie',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4F0B2:
	dc.b	'Attack Drone',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4F0C0:
	dc.b	'Armored Drone',0
str_4F0CE:
	dc.b	'Proton Bot',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_4F0DA:
	dc.b	'Radar Bot',0
str_4F0E4:
	dc.b	'Chopper Bot',0
str_4F0F0:
	dc.b	'Ornobot',0
str_4F0F8:
	dc.b	'Terrigible',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_4F104:
	incbin	"../../build/stunrun-68k.bin",$04F104,$18
dat_4F11C:
	incbin	"../../build/stunrun-68k.bin",$04F11C,$4C
dat_4F168:
	incbin	"../../build/stunrun-68k.bin",$04F168,$14
dat_4F17C:
	incbin	"../../build/stunrun-68k.bin",$04F17C,$24
dat_4F1A0:
	incbin	"../../build/stunrun-68k.bin",$04F1A0,$34
dat_4F1D4:
	incbin	"../../build/stunrun-68k.bin",$04F1D4,$4C
dat_4F220:
	incbin	"../../build/stunrun-68k.bin",$04F220,$4
dat_4F224:
	incbin	"../../build/stunrun-68k.bin",$04F224,$14
dat_4F238:
	incbin	"../../build/stunrun-68k.bin",$04F238,$28
dat_4F260:
	incbin	"../../build/stunrun-68k.bin",$04F260,$18
dat_4F278:
	incbin	"../../build/stunrun-68k.bin",$04F278,$14
dat_4F28C:
	incbin	"../../build/stunrun-68k.bin",$04F28C,$24
dat_4F2B0:
	incbin	"../../build/stunrun-68k.bin",$04F2B0,$34
dat_4F2E4:
	incbin	"../../build/stunrun-68k.bin",$04F2E4,$28
dat_4F30C:
	incbin	"../../build/stunrun-68k.bin",$04F30C,$10
dat_4F31C:
	incbin	"../../build/stunrun-68k.bin",$04F31C,$20
dat_4F33C:
	incbin	"../../build/stunrun-68k.bin",$04F33C,$57C
dat_4F8B8:
	incbin	"../../build/stunrun-68k.bin",$04F8B8,$60
dat_4F918:
	incbin	"../../build/stunrun-68k.bin",$04F918,$AE4
dat_503FC:
	incbin	"../../build/stunrun-68k.bin",$0503FC,$5CC
dat_509C8:
	incbin	"../../build/stunrun-68k.bin",$0509C8,$818
dat_511E0:
	incbin	"../../build/stunrun-68k.bin",$0511E0,$754
dat_51934:
	incbin	"../../build/stunrun-68k.bin",$051934,$66C
dat_51FA0:
	incbin	"../../build/stunrun-68k.bin",$051FA0,$748
dat_526E8:
	incbin	"../../build/stunrun-68k.bin",$0526E8,$5B4
dat_52C9C:
	incbin	"../../build/stunrun-68k.bin",$052C9C,$85C
dat_534F8:
	incbin	"../../build/stunrun-68k.bin",$0534F8,$9DC
dat_53ED4:
	incbin	"../../build/stunrun-68k.bin",$053ED4,$5EC
dat_544C0:
	incbin	"../../build/stunrun-68k.bin",$0544C0,$960
dat_54E20:
	incbin	"../../build/stunrun-68k.bin",$054E20,$6D8
dat_554F8:
	incbin	"../../build/stunrun-68k.bin",$0554F8,$E8C
dat_56384:
	incbin	"../../build/stunrun-68k.bin",$056384,$B78
dat_56EFC:
	incbin	"../../build/stunrun-68k.bin",$056EFC,$4C4
dat_573C0:
	incbin	"../../build/stunrun-68k.bin",$0573C0,$79C
dat_57B5C:
	incbin	"../../build/stunrun-68k.bin",$057B5C,$6DC
dat_58238:
	incbin	"../../build/stunrun-68k.bin",$058238,$780
dat_589B8:
	incbin	"../../build/stunrun-68k.bin",$0589B8,$670
dat_59028:
	incbin	"../../build/stunrun-68k.bin",$059028,$67C
dat_596A4:
	incbin	"../../build/stunrun-68k.bin",$0596A4,$F10
dat_5A5B4:
	incbin	"../../build/stunrun-68k.bin",$05A5B4,$988
dat_5AF3C:
	incbin	"../../build/stunrun-68k.bin",$05AF3C,$A5C
dat_5B998:
	incbin	"../../build/stunrun-68k.bin",$05B998,$45C
dat_5BDF4:
	incbin	"../../build/stunrun-68k.bin",$05BDF4,$4
dat_5BDF8:
	incbin	"../../build/stunrun-68k.bin",$05BDF8,$C
str_5BE04:
	dc.b	'1 Coin 1 Credit',0
str_5BE14:
	dc.b	'2 Coins 1 Credit',0
str_5BE25:
	dc.b	'3 Coins 1 Credit',0
str_5BE36:
	dc.b	'4 Coins 1 Credit',0
str_5BE47:
	dc.b	'2Right Mech Multiplier',0
str_5BE5E:
	dc.b	'1 Coin Counts as 1 Coin',0
str_5BE76:
	dc.b	'1 Coin Counts as 4 Coins',0
str_5BE8F:
	dc.b	'1 Coin Counts as 5 Coins',0
str_5BEA8:
	dc.b	'1 Coin Counts as 6 Coins',0
str_5BEC1:
	dc.b	'DLeft Mech Multiplier',0
str_5BED7:
	dc.b	'1 Coin Counts as 1 Coin',0
str_5BEEF:
	dc.b	'1 Coin Counts as 2 Coins',0
str_5BF08:
	dc.b	'uBonus Adder',0
str_5BF15:
	dc.b	'No Bonus Adder',0
str_5BF24:
	dc.b	'2 Coins Give 1 Extra Coin',0
str_5BF3E:
	dc.b	'4 Coins Give 1 Extra Coin',0
str_5BF58:
	dc.b	'4 Coins Give 2 Extra Coins',0
str_5BF73:
	dc.b	'5 Coins Give 1 Extra Coin',0
str_5BF8D:
	dc.b	'3 Coins Give 1 Extra Coin',0
dat_5BFA7:
	incbin	"../../build/stunrun-68k.bin",$05BFA7,$F
dat_5BFB6:
	incbin	"../../build/stunrun-68k.bin",$05BFB6,$8
dat_5BFBE:
	incbin	"../../build/stunrun-68k.bin",$05BFBE,$48
dat_5C006:
	incbin	"../../build/stunrun-68k.bin",$05C006,$2
str_5C008:
	dc.b	'for next screen',0
str_5C018:
	dc.b	'Histogram ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C024:
	dc.b	'Histogram of game times',0
dat_5C03C:
	incbin	"../../build/stunrun-68k.bin",$05C03C,$2
dat_5C03E:
	incbin	"../../build/stunrun-68k.bin",$05C03E,$6
dat_5C044:
	incbin	"../../build/stunrun-68k.bin",$05C044,$2
str_5C046:
	dc.b	'to clear ',0
str_5C050:
	dc.b	'all histograms',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C060:
	dc.b	'histogram',0
dat_5C06A:
	incbin	"../../build/stunrun-68k.bin",$05C06A,$2
str_5C06C:
	dc.b	'for next level',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C07C:
	dc.b	'Total Credits: ',0
str_5C08C:
	dc.b	'Total Coins: ',0
dat_5C09A:
	incbin	"../../build/stunrun-68k.bin",$05C09A,$10
dat_5C0AA:
	incbin	"../../build/stunrun-68k.bin",$05C0AA,$6
str_5C0B0:
	dc.b	'Statistics',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_5C0BC:
	incbin	"../../build/stunrun-68k.bin",$05C0BC,$4E
str_5C10A:
	dc.b	'Left  Coins : ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C11A:
	dc.b	'Right Coins : ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C12A:
	dc.b	'Aux Coins   : ',0
dat_5C139:
	incbin	"../../build/stunrun-68k.bin",$05C139,$11
str_5C14A:
	dc.b	'Active Mins : ',0
dat_5C159:
	incbin	"../../build/stunrun-68k.bin",$05C159,$11
str_5C16A:
	dc.b	'Intermediate: ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C17A:
	dc.b	'Advanced    : ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C18A:
	dc.b	'New Games   : ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C19A:
	dc.b	'Continues   : ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C1AA:
	dc.b	'Finished All: ',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C1BA:
	dc.b	'Error Count : ',0
dat_5C1C9:
	incbin	"../../build/stunrun-68k.bin",$05C1C9,$3
str_5C1CC:
	dc.b	'EEPROM ERROR',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C1DA:
	dc.b	'%s to clear statistics',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C1F2:
	dc.b	'%s for histograms',0
str_5C204:
	dc.b	'HIGH SCORES',0
str_5C210:
	dc.b	'BAD CHECKSUM, DATA MAY BE INVALID',0
str_5C232:
	dc.b	'%s to clear High Scores',0
str_5C24A:
	dc.b	'%s for next menu',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C25C:
	dc.b	'ERROR COUNTS',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_5C26A:
	incbin	"../../build/stunrun-68k.bin",$05C26A,$A
str_5C274:
	dc.b	'BAD CHECKSUM, DATA MAY BE INVALID',0
str_5C296:
	dc.b	'%s to clear error counts',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C2B0:
	dc.b	'%s for next menu',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C2C2:
	dc.b	'Hit LEFT/RIGHT Triggers to move UP/DOWN',0
str_5C2EA:
	dc.b	'Hold a Coin Switch and hit Triggers to cycle through choices',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C328:
	dc.b	'Hold a Coin Switch and press START to restore original setting',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C368:
	dc.b	'Just press START to save this setting and exit',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_5C398:
	incbin	"../../build/stunrun-68k.bin",$05C398,$C
str_5C3A4:
	dc.b	'vv MORE vv',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C3B0:
	dc.b	'Game Options',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C3BE:
	dc.b	'Game Options',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C3CC:
	dc.b	'Coin Options',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C3DA:
	dc.b	'AUDIO TEST',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C3E6:
	dc.b	'Audio Test',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_5C3F2:
	incbin	"../../build/stunrun-68k.bin",$05C3F2,$4
dat_5C3F6:
	dc.l	str_5C40E
	dc.l	str_5C41E
	dc.l	str_5C436
	dc.l	str_5C444
	dc.l	str_5C45A
	dc.l	str_5C462	; the classification's text 05C40D-05C41D starts with this long's low byte
str_5C40E:
	dc.b	'New Game Times',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C41E:
	dc.b	'Continuation Game Times',0
str_5C436:
	dc.b	'Level Died At',0
str_5C444:
	dc.b	'Level Continued From',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C45A:
	dc.b	'Scores',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
str_5C462:
	dc.b	'Excess Time (1/10th sec)',0
	dcb.b	1,0	; a zero byte after a string, to an even address (docs/17)
dat_5C47C:
	dc.l	0
	dc.l	0
	dc.l	dat_5C494
	dc.l	dat_5C4D6
	dc.l	dat_5C518
	dc.l	dat_5C5B2
dat_5C494:
	incbin	"../../build/stunrun-68k.bin",$05C494,$42
dat_5C4D6:
	incbin	"../../build/stunrun-68k.bin",$05C4D6,$42
dat_5C518:
	incbin	"../../build/stunrun-68k.bin",$05C518,$9A
dat_5C5B2:
	incbin	"../../build/stunrun-68k.bin",$05C5B2,$8A
audio_test_list:
; 108 records of 22 bytes (audio_test 043718: base at 043720, the names at +2 by lea ($2,a4),a3
; at 043828, both pointers stepped by 16h at 043892-04389C until cmpi.w #$FFFF,(a2) at 0438A4;
; the chosen record's word sent by send_sound_byte at 04395C after mulu.w #$16 and
; move.w ($0,a4,d0.w),d1 at 043950-043954): the sound command word, then the name, NUL-ended
; and zero to 22 bytes; sorted by name; the word FFFF at 05CF84 ends the list. The words are
; the equates of build/68k/sound_commands.asm (data/sound/commands.json; M5d, docs/17).
	dc.w	snd_acl
	dc.b	'ACL',0
	dcb.b	16,0
	dc.w	snd_adtest
	dc.b	'ADTEST',0
	dcb.b	13,0
	dc.w	snd_apad
	dc.b	'APAD',0
	dcb.b	15,0
	dc.w	snd_arms
	dc.b	'ARMS',0
	dcb.b	15,0
	dc.w	snd_asmus
	dc.b	'ASMUS',0
	dcb.b	14,0
	dc.w	snd_atrctmus
	dc.b	'ATRCTMUS',0
	dcb.b	11,0
	dc.w	snd_bell
	dc.b	'BELL',0
	dcb.b	15,0
	dc.w	snd_better
	dc.b	'BETTER',0
	dcb.b	13,0
	dc.w	snd_bird
	dc.b	'BIRD',0
	dcb.b	15,0
	dc.w	snd_boostc
	dc.b	'BOOSTC',0
	dcb.b	13,0
	dc.w	snd_brake
	dc.b	'BRAKE',0
	dcb.b	14,0
	dc.w	snd_cd
	dc.b	'CD',0
	dcb.b	17,0
	dc.w	snd_chmap
	dc.b	'CHMAP',0
	dcb.b	14,0
	dc.w	snd_clevel
	dc.b	'CLEVEL',0
	dcb.b	13,0
	dc.w	snd_coin
	dc.b	'COIN',0
	dcb.b	15,0
	dc.w	snd_congrats
	dc.b	'CONGRATS',0
	dcb.b	11,0
	dc.w	snd_dcl
	dc.b	'DCL',0
	dcb.b	16,0
	dc.w	snd_dive
	dc.b	'DIVE',0
	dcb.b	15,0
	dc.w	snd_echo
	dc.b	'ECHO',0
	dcb.b	15,0
	dc.w	snd_eight
	dc.b	'EIGHT',0
	dcb.b	14,0
	dc.w	snd_eightt
	dc.b	'EIGHTT',0
	dcb.b	13,0
	dc.w	snd_eleven
	dc.b	'ELEVEN',0
	dcb.b	13,0
	dc.w	snd_eng
	dc.b	'ENG',0
	dcb.b	16,0
	dc.w	snd_exp2
	dc.b	'EXP2',0
	dcb.b	15,0
	dc.w	snd_exp3
	dc.b	'EXP3',0
	dcb.b	15,0
	dc.w	snd_facl
	dc.b	'FACL',0
	dcb.b	15,0
	dc.w	snd_fdcl
	dc.b	'FDCL',0
	dcb.b	15,0
	dc.w	snd_fhelcpt
	dc.b	'FHELCPT',0
	dcb.b	12,0
	dc.w	snd_fhiscor
	dc.b	'FHISCOR',0
	dcb.b	12,0
	dc.w	snd_fift
	dc.b	'FIFT',0
	dcb.b	15,0
	dc.w	snd_five
	dc.b	'FIVE',0
	dcb.b	15,0
	dc.w	snd_fmapmus
	dc.b	'FMAPMUS',0
	dcb.b	12,0
	dc.w	snd_four
	dc.b	'FOUR',0
	dcb.b	15,0
	dc.w	snd_fourt
	dc.b	'FOURT',0
	dcb.b	14,0
	dc.w	snd_fshield
	dc.b	'FSHIELD',0
	dcb.b	12,0
	dc.w	snd_fstbeg
	dc.b	'FSTBEG',0
	dcb.b	13,0
	dc.w	snd_fsubfan
	dc.b	'FSUBFAN',0
	dcb.b	12,0
	dc.w	snd_ftubmus
	dc.b	'FTUBMUS',0
	dcb.b	12,0
	dc.w	snd_fvrcft
	dc.b	'FVRCFT',0
	dcb.b	13,0
	dc.w	snd_gun1
	dc.b	'GUN1',0
	dcb.b	15,0
	dc.w	snd_helcpt
	dc.b	'HELCPT',0
	dcb.b	13,0
	dc.w	snd_hiscor
	dc.b	'HISCOR',0
	dcb.b	13,0
	dc.w	snd_hvrcft
	dc.b	'HVRCFT',0
	dcb.b	13,0
	dc.w	snd_inpass
	dc.b	'INPASS',0
	dcb.b	13,0
	dc.w	snd_irisop
	dc.b	'IRISOP',0
	dcb.b	13,0
	dc.w	snd_kbrake
	dc.b	'KBRAKE',0
	dcb.b	13,0
	dc.w	snd_kdive
	dc.b	'KDIVE',0
	dcb.b	14,0
	dc.w	snd_killc
	dc.b	'KILLC',0
	dcb.b	14,0
	dc.w	snd_kiss
	dc.b	'KISS',0
	dcb.b	15,0
	dc.w	snd_kscrap
	dc.b	'KSCRAP',0
	dcb.b	13,0
	dc.w	snd_letic
	dc.b	'LETIC',0
	dcb.b	14,0
	dc.w	snd_lttr
	dc.b	'LTTR',0
	dcb.b	15,0
	dc.w	snd_luck
	dc.b	'LUCK',0
	dcb.b	15,0
	dc.w	snd_mapmus
	dc.b	'MAPMUS',0
	dcb.b	13,0
	dc.w	snd_markerc
	dc.b	'MARKERC',0
	dcb.b	12,0
	dc.w	snd_nine
	dc.b	'NINE',0
	dcb.b	15,0
	dc.w	snd_ninet
	dc.b	'NINET',0
	dcb.b	14,0
	dc.w	snd_one
	dc.b	'ONE',0
	dcb.b	16,0
	dc.w	snd_owall
	dc.b	'OWALL',0
	dcb.b	14,0
	dc.w	snd_pad
	dc.b	'PAD',0
	dcb.b	16,0
	dc.w	snd_prgun
	dc.b	'PRGUN',0
	dcb.b	14,0
	dc.w	snd_pvskid
	dc.b	'PVSKID',0
	dcb.b	13,0
	dc.w	snd_rails
	dc.b	'RAILS',0
	dcb.b	14,0
	dc.w	snd_rmphit
	dc.b	'RMPHIT',0
	dcb.b	13,0
	dc.w	snd_rshield
	dc.b	'RSHIELD',0
	dcb.b	12,0
	dc.w	snd_same
	dc.b	'SAME',0
	dcb.b	15,0
	dc.w	snd_scrap
	dc.b	'SCRAP',0
	dcb.b	14,0
	dc.w	snd_scum
	dc.b	'SCUM',0
	dcb.b	15,0
	dc.w	snd_seng
	dc.b	'SENG',0
	dcb.b	15,0
	dc.w	snd_seven
	dc.b	'SEVEN',0
	dcb.b	14,0
	dc.w	snd_sevent
	dc.b	'SEVENT',0
	dcb.b	13,0
	dc.w	snd_shield
	dc.b	'SHIELD',0
	dcb.b	13,0
	dc.w	snd_shock
	dc.b	'SHOCK',0
	dcb.b	14,0
	dc.w	snd_six
	dc.b	'SIX',0
	dcb.b	16,0
	dc.w	snd_sixt
	dc.b	'SIXT',0
	dcb.b	15,0
	dc.w	snd_smax
	dc.b	'SMAX',0
	dcb.b	15,0
	dc.w	snd_soff
	dc.b	'SOFF',0
	dcb.b	15,0
	dc.w	snd_son
	dc.b	'SON',0
	dcb.b	16,0
	dc.w	snd_star
	dc.b	'STAR',0
	dcb.b	15,0
	dc.w	snd_stat
	dc.b	'STAT',0
	dcb.b	15,0
	dc.w	snd_stbeg
	dc.b	'STBEG',0
	dcb.b	14,0
	dc.w	snd_stop
	dc.b	'STOP',0
	dcb.b	15,0
	dc.w	snd_subfan
	dc.b	'SUBFAN',0
	dcb.b	13,0
	dc.w	snd_substa2
	dc.b	'SUBSTA2',0
	dcb.b	12,0
	dc.w	snd_swave
	dc.b	'SWAVE',0
	dcb.b	14,0
	dc.w	snd_swpikup
	dc.b	'SWPIKUP',0
	dcb.b	12,0
	dc.w	snd_ten
	dc.b	'TEN',0
	dcb.b	16,0
	dc.w	snd_thirt
	dc.b	'THIRT',0
	dcb.b	14,0
	dc.w	snd_three
	dc.b	'THREE',0
	dcb.b	14,0
	dc.w	snd_trkhit
	dc.b	'TRKHIT',0
	dcb.b	13,0
	dc.w	snd_tubeg
	dc.b	'TUBEG',0
	dcb.b	14,0
	dc.w	snd_tubmus
	dc.b	'TUBMUS',0
	dcb.b	13,0
	dc.w	snd_twelve
	dc.b	'TWELVE',0
	dcb.b	13,0
	dc.w	snd_twenty
	dc.b	'TWENTY',0
	dcb.b	13,0
	dc.w	snd_twenty1
	dc.b	'TWENTY1',0
	dcb.b	12,0
	dc.w	snd_twenty2
	dc.b	'TWENTY2',0
	dcb.b	12,0
	dc.w	snd_two
	dc.b	'TWO',0
	dcb.b	16,0
	dc.w	snd_type
	dc.b	'TYPE',0
	dcb.b	15,0
	dc.w	snd_ultimate
	dc.b	'ULTIMATE',0
	dcb.b	11,0
	dc.w	snd_victory
	dc.b	'VICTORY',0
	dcb.b	12,0
	dc.w	snd_vslows
	dc.b	'VSLOWS',0
	dcb.b	13,0
	dc.w	snd_wait
	dc.b	'WAIT',0
	dcb.b	15,0
	dc.w	snd_warn
	dc.b	'WARN',0
	dcb.b	15,0
	dc.w	snd_warpmus
	dc.b	'WARPMUS',0
	dcb.b	12,0
	dc.w	snd_welcome
	dc.b	'WELCOME',0
	dcb.b	12,0
	dc.w	snd_wings
	dc.b	'WINGS',0
	dcb.b	14,0
	dc.w	snd_yahoo
	dc.b	'YAHOO',0
	dcb.b	14,0
	dc.w	snd_ytst
	dc.b	'YTST',0
	dcb.b	15,0
	dc.w	$FFFF	; the end of the list (0438A4)
	assert	*=$05CF86,"audio_test_list is not 108 records and its end word"

; 05CF86-060000: zero (12,410 bytes)
	dcb.b	$060000-*,0

	assert	*=$060000,"data.asm does not end at 060000"
