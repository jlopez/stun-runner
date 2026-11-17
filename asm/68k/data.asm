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
	incbin	"../../build/stunrun-68k.bin",$046B3E,$14
str_46B52:
	incbin	"../../build/stunrun-68k.bin",$046B52,$10
str_46B62:
	incbin	"../../build/stunrun-68k.bin",$046B62,$E
str_46B70:
	incbin	"../../build/stunrun-68k.bin",$046B70,$10
str_46B80:
	incbin	"../../build/stunrun-68k.bin",$046B80,$E
str_46B8E:
	incbin	"../../build/stunrun-68k.bin",$046B8E,$1C
str_46BAA:
	incbin	"../../build/stunrun-68k.bin",$046BAA,$10
str_46BBA:
	incbin	"../../build/stunrun-68k.bin",$046BBA,$A
str_46BC4:
	incbin	"../../build/stunrun-68k.bin",$046BC4,$C
str_46BD0:
	incbin	"../../build/stunrun-68k.bin",$046BD0,$12
str_46BE2:
	incbin	"../../build/stunrun-68k.bin",$046BE2,$E
str_46BF0:
	incbin	"../../build/stunrun-68k.bin",$046BF0,$A
str_46BFA:
	incbin	"../../build/stunrun-68k.bin",$046BFA,$12
str_46C0C:
	incbin	"../../build/stunrun-68k.bin",$046C0C,$20
str_46C2C:
	incbin	"../../build/stunrun-68k.bin",$046C2C,$24
str_46C50:
	incbin	"../../build/stunrun-68k.bin",$046C50,$22
str_46C72:
	incbin	"../../build/stunrun-68k.bin",$046C72,$20
str_46C92:
	incbin	"../../build/stunrun-68k.bin",$046C92,$20
str_46CB2:
	incbin	"../../build/stunrun-68k.bin",$046CB2,$24
str_46CD6:
	incbin	"../../build/stunrun-68k.bin",$046CD6,$22
str_46CF8:
	incbin	"../../build/stunrun-68k.bin",$046CF8,$22
str_46D1A:
	incbin	"../../build/stunrun-68k.bin",$046D1A,$1E
str_46D38:
	incbin	"../../build/stunrun-68k.bin",$046D38,$22
str_46D5A:
	incbin	"../../build/stunrun-68k.bin",$046D5A,$24
str_46D7E:
	incbin	"../../build/stunrun-68k.bin",$046D7E,$24
str_46DA2:
	incbin	"../../build/stunrun-68k.bin",$046DA2,$22
str_46DC4:
	incbin	"../../build/stunrun-68k.bin",$046DC4,$24
str_46DE8:
	incbin	"../../build/stunrun-68k.bin",$046DE8,$24
str_46E0C:
	incbin	"../../build/stunrun-68k.bin",$046E0C,$20
str_46E2C:
	incbin	"../../build/stunrun-68k.bin",$046E2C,$20
str_46E4C:
	incbin	"../../build/stunrun-68k.bin",$046E4C,$22
str_46E6E:
	incbin	"../../build/stunrun-68k.bin",$046E6E,$20
str_46E8E:
	incbin	"../../build/stunrun-68k.bin",$046E8E,$22
str_46EB0:
	incbin	"../../build/stunrun-68k.bin",$046EB0,$1E
str_46ECE:
	incbin	"../../build/stunrun-68k.bin",$046ECE,$26
str_46EF4:
	incbin	"../../build/stunrun-68k.bin",$046EF4,$24
str_46F18:
	incbin	"../../build/stunrun-68k.bin",$046F18,$22
str_46F3A:
	incbin	"../../build/stunrun-68k.bin",$046F3A,$24
str_46F5E:
	incbin	"../../build/stunrun-68k.bin",$046F5E,$1C
str_46F7A:
	incbin	"../../build/stunrun-68k.bin",$046F7A,$10
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
	incbin	"../../build/stunrun-68k.bin",$046FBE,$10
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
	incbin	"../../build/stunrun-68k.bin",$046FF2,$18
str_4700A:
	incbin	"../../build/stunrun-68k.bin",$04700A,$18
str_47022:
	incbin	"../../build/stunrun-68k.bin",$047022,$24
str_47046:
	incbin	"../../build/stunrun-68k.bin",$047046,$16
str_4705C:
	incbin	"../../build/stunrun-68k.bin",$04705C,$14
str_47070:
	incbin	"../../build/stunrun-68k.bin",$047070,$2A
str_4709A:
	incbin	"../../build/stunrun-68k.bin",$04709A,$18
str_470B2:
	incbin	"../../build/stunrun-68k.bin",$0470B2,$1A
str_470CC:
	incbin	"../../build/stunrun-68k.bin",$0470CC,$1A
str_470E6:
	incbin	"../../build/stunrun-68k.bin",$0470E6,$12
str_470F8:
	incbin	"../../build/stunrun-68k.bin",$0470F8,$1E
str_47116:
	incbin	"../../build/stunrun-68k.bin",$047116,$1C
str_47132:
	incbin	"../../build/stunrun-68k.bin",$047132,$10
str_47142:
	incbin	"../../build/stunrun-68k.bin",$047142,$1C
str_4715E:
	incbin	"../../build/stunrun-68k.bin",$04715E,$18
str_47176:
	incbin	"../../build/stunrun-68k.bin",$047176,$14
dat_4718A:
	incbin	"../../build/stunrun-68k.bin",$04718A,$4
str_4718E:
	incbin	"../../build/stunrun-68k.bin",$04718E,$10
str_4719E:
	incbin	"../../build/stunrun-68k.bin",$04719E,$14
str_471B2:
	incbin	"../../build/stunrun-68k.bin",$0471B2,$12
str_471C4:
	incbin	"../../build/stunrun-68k.bin",$0471C4,$14
str_471D8:
	incbin	"../../build/stunrun-68k.bin",$0471D8,$12
str_471EA:
	incbin	"../../build/stunrun-68k.bin",$0471EA,$10
str_471FA:
	incbin	"../../build/stunrun-68k.bin",$0471FA,$14
str_4720E:
	incbin	"../../build/stunrun-68k.bin",$04720E,$10
str_4721E:
	incbin	"../../build/stunrun-68k.bin",$04721E,$14
str_47232:
	incbin	"../../build/stunrun-68k.bin",$047232,$1A
str_4724C:
	incbin	"../../build/stunrun-68k.bin",$04724C,$10
str_4725C:
	incbin	"../../build/stunrun-68k.bin",$04725C,$14
str_47270:
	incbin	"../../build/stunrun-68k.bin",$047270,$1C
str_4728C:
	incbin	"../../build/stunrun-68k.bin",$04728C,$32
str_472BE:
	incbin	"../../build/stunrun-68k.bin",$0472BE,$14
str_472D2:
	incbin	"../../build/stunrun-68k.bin",$0472D2,$2C
dat_472FE:
	incbin	"../../build/stunrun-68k.bin",$0472FE,$4
str_47302:
	incbin	"../../build/stunrun-68k.bin",$047302,$1E
str_47320:
	incbin	"../../build/stunrun-68k.bin",$047320,$18
str_47338:
	incbin	"../../build/stunrun-68k.bin",$047338,$8
dat_47340:
	incbin	"../../build/stunrun-68k.bin",$047340,$4
str_47344:
	incbin	"../../build/stunrun-68k.bin",$047344,$A
str_4734E:
	incbin	"../../build/stunrun-68k.bin",$04734E,$E
dat_4735C:
	incbin	"../../build/stunrun-68k.bin",$04735C,$4
str_47360:
	incbin	"../../build/stunrun-68k.bin",$047360,$A
str_4736A:
	incbin	"../../build/stunrun-68k.bin",$04736A,$A
str_47374:
	incbin	"../../build/stunrun-68k.bin",$047374,$A
dat_4737E:
	incbin	"../../build/stunrun-68k.bin",$04737E,$4
str_47382:
	incbin	"../../build/stunrun-68k.bin",$047382,$A
str_4738C:
	incbin	"../../build/stunrun-68k.bin",$04738C,$3E
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
	incbin	"../../build/stunrun-68k.bin",$047406,$78
dat_4747E:
	incbin	"../../build/stunrun-68k.bin",$04747E,$1E
dat_4749C:
	incbin	"../../build/stunrun-68k.bin",$04749C,$2A
dat_474C6:
	incbin	"../../build/stunrun-68k.bin",$0474C6,$10
dat_474D6:
	incbin	"../../build/stunrun-68k.bin",$0474D6,$2
dat_474D8:
	incbin	"../../build/stunrun-68k.bin",$0474D8,$E2
dat_475BA:
	incbin	"../../build/stunrun-68k.bin",$0475BA,$8
dat_475C2:
	incbin	"../../build/stunrun-68k.bin",$0475C2,$2
dat_475C4:
	incbin	"../../build/stunrun-68k.bin",$0475C4,$6
str_475CA:
	incbin	"../../build/stunrun-68k.bin",$0475CA,$18
str_475E2:
	incbin	"../../build/stunrun-68k.bin",$0475E2,$1A
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
	incbin	"../../build/stunrun-68k.bin",$04762E,$C
str_4763A:
	incbin	"../../build/stunrun-68k.bin",$04763A,$18
str_47652:
	incbin	"../../build/stunrun-68k.bin",$047652,$10
str_47662:
	incbin	"../../build/stunrun-68k.bin",$047662,$12
dat_47674:
	incbin	"../../build/stunrun-68k.bin",$047674,$4
str_47678:
	incbin	"../../build/stunrun-68k.bin",$047678,$10
str_47688:
	incbin	"../../build/stunrun-68k.bin",$047688,$12
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
	incbin	"../../build/stunrun-68k.bin",$047D34,$21C
dat_47F50:
	incbin	"../../build/stunrun-68k.bin",$047F50,$8
dat_47F58:
	incbin	"../../build/stunrun-68k.bin",$047F58,$4
dat_47F5C:
	incbin	"../../build/stunrun-68k.bin",$047F5C,$58
dat_47FB4:
	incbin	"../../build/stunrun-68k.bin",$047FB4,$B0
dat_48064:
	incbin	"../../build/stunrun-68k.bin",$048064,$4
dat_48068:
	incbin	"../../build/stunrun-68k.bin",$048068,$C
dat_48074:
	incbin	"../../build/stunrun-68k.bin",$048074,$34
dat_480A8:
	incbin	"../../build/stunrun-68k.bin",$0480A8,$1C
dat_480C4:
	incbin	"../../build/stunrun-68k.bin",$0480C4,$8
dat_480CC:
	incbin	"../../build/stunrun-68k.bin",$0480CC,$4
dat_480D0:
	incbin	"../../build/stunrun-68k.bin",$0480D0,$4
dat_480D4:
	incbin	"../../build/stunrun-68k.bin",$0480D4,$8
dat_480DC:
	incbin	"../../build/stunrun-68k.bin",$0480DC,$8
dat_480E4:
	incbin	"../../build/stunrun-68k.bin",$0480E4,$10
dat_480F4:
	incbin	"../../build/stunrun-68k.bin",$0480F4,$78
dat_4816C:
	incbin	"../../build/stunrun-68k.bin",$04816C,$4
dat_48170:
	incbin	"../../build/stunrun-68k.bin",$048170,$C
dat_4817C:
	incbin	"../../build/stunrun-68k.bin",$04817C,$4
dat_48180:
	incbin	"../../build/stunrun-68k.bin",$048180,$C64
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
	incbin	"../../build/stunrun-68k.bin",$04A830,$C
str_4A83C:
	incbin	"../../build/stunrun-68k.bin",$04A83C,$50
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
	incbin	"../../build/stunrun-68k.bin",$04A954,$166
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
	incbin	"../../build/stunrun-68k.bin",$04AFE6,$10
str_4AFF6:
	incbin	"../../build/stunrun-68k.bin",$04AFF6,$18
dat_4B00E:
	incbin	"../../build/stunrun-68k.bin",$04B00E,$40
dat_4B04E:
	incbin	"../../build/stunrun-68k.bin",$04B04E,$9
dat_4B057:
	incbin	"../../build/stunrun-68k.bin",$04B057,$16BB
dat_4C712:
	incbin	"../../build/stunrun-68k.bin",$04C712,$40A
dat_4CB1C:
	incbin	"../../build/stunrun-68k.bin",$04CB1C,$1A
dat_4CB36:
	incbin	"../../build/stunrun-68k.bin",$04CB36,$AB6
dat_4D5EC:
	incbin	"../../build/stunrun-68k.bin",$04D5EC,$3C
dat_4D628:
	incbin	"../../build/stunrun-68k.bin",$04D628,$64
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
	incbin	"../../build/stunrun-68k.bin",$04E1FA,$1BA
dat_4E3B4:
	incbin	"../../build/stunrun-68k.bin",$04E3B4,$24
dat_4E3D8:
	incbin	"../../build/stunrun-68k.bin",$04E3D8,$30
dat_4E408:
	incbin	"../../build/stunrun-68k.bin",$04E408,$2
str_4E40A:
	incbin	"../../build/stunrun-68k.bin",$04E40A,$1C
str_4E426:
	incbin	"../../build/stunrun-68k.bin",$04E426,$14
str_4E43A:
	incbin	"../../build/stunrun-68k.bin",$04E43A,$1A
str_4E454:
	incbin	"../../build/stunrun-68k.bin",$04E454,$38
dat_4E48C:
	incbin	"../../build/stunrun-68k.bin",$04E48C,$4
str_4E490:
	incbin	"../../build/stunrun-68k.bin",$04E490,$1C
str_4E4AC:
	incbin	"../../build/stunrun-68k.bin",$04E4AC,$16
str_4E4C2:
	incbin	"../../build/stunrun-68k.bin",$04E4C2,$20
str_4E4E2:
	incbin	"../../build/stunrun-68k.bin",$04E4E2,$38
dat_4E51A:
	incbin	"../../build/stunrun-68k.bin",$04E51A,$4
str_4E51E:
	incbin	"../../build/stunrun-68k.bin",$04E51E,$1C
str_4E53A:
	incbin	"../../build/stunrun-68k.bin",$04E53A,$12
str_4E54C:
	incbin	"../../build/stunrun-68k.bin",$04E54C,$12
str_4E55E:
	incbin	"../../build/stunrun-68k.bin",$04E55E,$12
str_4E570:
	incbin	"../../build/stunrun-68k.bin",$04E570,$1C
str_4E58C:
	incbin	"../../build/stunrun-68k.bin",$04E58C,$1C
str_4E5A8:
	incbin	"../../build/stunrun-68k.bin",$04E5A8,$1C
str_4E5C4:
	incbin	"../../build/stunrun-68k.bin",$04E5C4,$38
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
	incbin	"../../build/stunrun-68k.bin",$04E63E,$8
dat_4E646:
	incbin	"../../build/stunrun-68k.bin",$04E646,$8
dat_4E64E:
	incbin	"../../build/stunrun-68k.bin",$04E64E,$4
dat_4E652:
	incbin	"../../build/stunrun-68k.bin",$04E652,$4
str_4E656:
	incbin	"../../build/stunrun-68k.bin",$04E656,$1A
str_4E670:
	incbin	"../../build/stunrun-68k.bin",$04E670,$14
str_4E684:
	incbin	"../../build/stunrun-68k.bin",$04E684,$E
str_4E692:
	incbin	"../../build/stunrun-68k.bin",$04E692,$14
str_4E6A6:
	incbin	"../../build/stunrun-68k.bin",$04E6A6,$12
str_4E6B8:
	incbin	"../../build/stunrun-68k.bin",$04E6B8,$12
str_4E6CA:
	incbin	"../../build/stunrun-68k.bin",$04E6CA,$16
dat_4E6E0:
	incbin	"../../build/stunrun-68k.bin",$04E6E0,$6
str_4E6E6:
	incbin	"../../build/stunrun-68k.bin",$04E6E6,$E
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
	incbin	"../../build/stunrun-68k.bin",$04E716,$1C
str_4E732:
	incbin	"../../build/stunrun-68k.bin",$04E732,$1C
str_4E74E:
	incbin	"../../build/stunrun-68k.bin",$04E74E,$32
str_4E780:
	incbin	"../../build/stunrun-68k.bin",$04E780,$1A
str_4E79A:
	incbin	"../../build/stunrun-68k.bin",$04E79A,$1C
str_4E7B6:
	incbin	"../../build/stunrun-68k.bin",$04E7B6,$1A
str_4E7D0:
	incbin	"../../build/stunrun-68k.bin",$04E7D0,$26
str_4E7F6:
	incbin	"../../build/stunrun-68k.bin",$04E7F6,$1A
str_4E810:
	incbin	"../../build/stunrun-68k.bin",$04E810,$24
dat_4E834:
	incbin	"../../build/stunrun-68k.bin",$04E834,$8
dat_4E83C:
	incbin	"../../build/stunrun-68k.bin",$04E83C,$4
str_4E840:
	incbin	"../../build/stunrun-68k.bin",$04E840,$32
str_4E872:
	incbin	"../../build/stunrun-68k.bin",$04E872,$32
dat_4E8A4:
	incbin	"../../build/stunrun-68k.bin",$04E8A4,$4
str_4E8A8:
	incbin	"../../build/stunrun-68k.bin",$04E8A8,$1A
dat_4E8C2:
	incbin	"../../build/stunrun-68k.bin",$04E8C2,$12
dat_4E8D4:
	incbin	"../../build/stunrun-68k.bin",$04E8D4,$1A
str_4E8EE:
	incbin	"../../build/stunrun-68k.bin",$04E8EE,$1A
dat_4E908:
	incbin	"../../build/stunrun-68k.bin",$04E908,$C
str_4E914:
	incbin	"../../build/stunrun-68k.bin",$04E914,$26
str_4E93A:
	incbin	"../../build/stunrun-68k.bin",$04E93A,$22
dat_4E95C:
	incbin	"../../build/stunrun-68k.bin",$04E95C,$10E
dat_4EA6A:
	incbin	"../../build/stunrun-68k.bin",$04EA6A,$78
dat_4EAE2:
	incbin	"../../build/stunrun-68k.bin",$04EAE2,$8C
dat_4EB6E:
	incbin	"../../build/stunrun-68k.bin",$04EB6E,$6E
dat_4EBDC:
	incbin	"../../build/stunrun-68k.bin",$04EBDC,$6E
dat_4EC4A:
	incbin	"../../build/stunrun-68k.bin",$04EC4A,$6E
dat_4ECB8:
	incbin	"../../build/stunrun-68k.bin",$04ECB8,$F0
str_4EDA8:
	incbin	"../../build/stunrun-68k.bin",$04EDA8,$3E
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
	incbin	"../../build/stunrun-68k.bin",$04EF10,$10
dat_4EF20:
	incbin	"../../build/stunrun-68k.bin",$04EF20,$A6
dat_4EFC6:
	incbin	"../../build/stunrun-68k.bin",$04EFC6,$90
dat_4F056:
	incbin	"../../build/stunrun-68k.bin",$04F056,$AE
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
	incbin	"../../build/stunrun-68k.bin",$04F918,$201C
dat_51934:
	incbin	"../../build/stunrun-68k.bin",$051934,$3BC4
dat_554F8:
	incbin	"../../build/stunrun-68k.bin",$0554F8,$E8C
dat_56384:
	incbin	"../../build/stunrun-68k.bin",$056384,$103C
dat_573C0:
	incbin	"../../build/stunrun-68k.bin",$0573C0,$31F4
dat_5A5B4:
	incbin	"../../build/stunrun-68k.bin",$05A5B4,$1840
dat_5BDF4:
	incbin	"../../build/stunrun-68k.bin",$05BDF4,$4
dat_5BDF8:
	incbin	"../../build/stunrun-68k.bin",$05BDF8,$1BE
dat_5BFB6:
	incbin	"../../build/stunrun-68k.bin",$05BFB6,$8
dat_5BFBE:
	incbin	"../../build/stunrun-68k.bin",$05BFBE,$48
dat_5C006:
	incbin	"../../build/stunrun-68k.bin",$05C006,$2
str_5C008:
	incbin	"../../build/stunrun-68k.bin",$05C008,$10
str_5C018:
	incbin	"../../build/stunrun-68k.bin",$05C018,$C
str_5C024:
	incbin	"../../build/stunrun-68k.bin",$05C024,$18
dat_5C03C:
	incbin	"../../build/stunrun-68k.bin",$05C03C,$2
dat_5C03E:
	incbin	"../../build/stunrun-68k.bin",$05C03E,$6
dat_5C044:
	incbin	"../../build/stunrun-68k.bin",$05C044,$2
str_5C046:
	incbin	"../../build/stunrun-68k.bin",$05C046,$A
str_5C050:
	incbin	"../../build/stunrun-68k.bin",$05C050,$10
str_5C060:
	incbin	"../../build/stunrun-68k.bin",$05C060,$A
dat_5C06A:
	incbin	"../../build/stunrun-68k.bin",$05C06A,$2
str_5C06C:
	incbin	"../../build/stunrun-68k.bin",$05C06C,$10
str_5C07C:
	incbin	"../../build/stunrun-68k.bin",$05C07C,$10
str_5C08C:
	incbin	"../../build/stunrun-68k.bin",$05C08C,$E
dat_5C09A:
	incbin	"../../build/stunrun-68k.bin",$05C09A,$10
dat_5C0AA:
	incbin	"../../build/stunrun-68k.bin",$05C0AA,$6
str_5C0B0:
	incbin	"../../build/stunrun-68k.bin",$05C0B0,$C
dat_5C0BC:
	incbin	"../../build/stunrun-68k.bin",$05C0BC,$110
str_5C1CC:
	incbin	"../../build/stunrun-68k.bin",$05C1CC,$E
str_5C1DA:
	incbin	"../../build/stunrun-68k.bin",$05C1DA,$18
str_5C1F2:
	incbin	"../../build/stunrun-68k.bin",$05C1F2,$12
str_5C204:
	incbin	"../../build/stunrun-68k.bin",$05C204,$C
str_5C210:
	incbin	"../../build/stunrun-68k.bin",$05C210,$22
str_5C232:
	incbin	"../../build/stunrun-68k.bin",$05C232,$18
str_5C24A:
	incbin	"../../build/stunrun-68k.bin",$05C24A,$12
str_5C25C:
	incbin	"../../build/stunrun-68k.bin",$05C25C,$E
dat_5C26A:
	incbin	"../../build/stunrun-68k.bin",$05C26A,$A
str_5C274:
	incbin	"../../build/stunrun-68k.bin",$05C274,$22
str_5C296:
	incbin	"../../build/stunrun-68k.bin",$05C296,$1A
str_5C2B0:
	incbin	"../../build/stunrun-68k.bin",$05C2B0,$12
str_5C2C2:
	incbin	"../../build/stunrun-68k.bin",$05C2C2,$28
str_5C2EA:
	incbin	"../../build/stunrun-68k.bin",$05C2EA,$3E
str_5C328:
	incbin	"../../build/stunrun-68k.bin",$05C328,$40
str_5C368:
	incbin	"../../build/stunrun-68k.bin",$05C368,$30
dat_5C398:
	incbin	"../../build/stunrun-68k.bin",$05C398,$C
str_5C3A4:
	incbin	"../../build/stunrun-68k.bin",$05C3A4,$C
str_5C3B0:
	incbin	"../../build/stunrun-68k.bin",$05C3B0,$E
str_5C3BE:
	incbin	"../../build/stunrun-68k.bin",$05C3BE,$E
str_5C3CC:
	incbin	"../../build/stunrun-68k.bin",$05C3CC,$E
str_5C3DA:
	incbin	"../../build/stunrun-68k.bin",$05C3DA,$C
str_5C3E6:
	incbin	"../../build/stunrun-68k.bin",$05C3E6,$C
dat_5C3F2:
	incbin	"../../build/stunrun-68k.bin",$05C3F2,$4
dat_5C3F6:
	incbin	"../../build/stunrun-68k.bin",$05C3F6,$86
dat_5C47C:
	incbin	"../../build/stunrun-68k.bin",$05C47C,$1C0
audio_test_list:
	incbin	"../../build/stunrun-68k.bin",$05C63C,$94A

; 05CF86-060000: zero (12,410 bytes)
	dcb.b	$060000-*,0

	assert	*=$060000,"data.asm does not end at 060000"
