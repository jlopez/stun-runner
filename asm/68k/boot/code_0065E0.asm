; boot/code_0065E0.asm, 0065E0-009E80: boot program code (pair R) with the data, text and tables
; that lie between its routines; the first routine is sub_65E0 (0065E0). Cut at routine starts
; into files of about 16 KB named by their first address (decision C11).
; 0065E0-009E80: 26 IDA functions start in this file (data/ida/stunrun-68k.functions.jsonl).
; Owner: the boot naming legs (N1, N3-N5 for the boot program's tests and menus; docs/03).
;
; Generated once by tools/m68k gen 0065E0 009E80 (M5c, issue #33, docs/16-68k-code.md):
; neutral labels (the IDA snapshot's names where it has one), operands as docs/14 decides,
; what is not explained as incbin slices of build/stunrun-68k.bin. From here on this source
; is the truth: rename and comment in place, never run the generator over it again.

	assert	*=$0065E0,"boot/code_0065E0.asm misplaced"
sub_65E0:
	andi.l	#$FF,d0
	mulu.w	#$2800,d0
	addi.l	#$2000000,d0
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$F4000000,GSP_HOST+$2
	move.w	#$0,GSP_HOST+$C
	move.l	#$BFF,d2
	move.l	d0,GSP_HOST+$2
	move.w	#$FFFF,d3
.l661A:
	move.w	d3,GSP_HOST+$C
	dbf	d2,.l661A
	andi.w	#$E7FF,GSP_HOST+$8
	rts
dat_662E:
	incbin	"../../build/stunrun-68k.bin",$662E,$66
str_6694:
	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
dat_66AE:
	incbin	"../../build/stunrun-68k.bin",$66AE,$4
str_66B2:
	dc.b	'ADSP*TEST'
dat_66BB:
	incbin	"../../build/stunrun-68k.bin",$66BB,$4
str_66BF:
	dc.b	'VRAM*VERIFY*TEST'
dat_66CF:
	incbin	"../../build/stunrun-68k.bin",$66CF,$4
str_66D3:
	dc.b	'VRAM*SIMPLE*TEST'
dat_66E3:
	incbin	"../../build/stunrun-68k.bin",$66E3,$4
str_66E7:
	dc.b	'VRAM*COMPLETE*TEST'
dat_66F9:
	incbin	"../../build/stunrun-68k.bin",$66F9,$4
str_66FD:
	dc.b	'MSP*VERIFY*TEST'
dat_670C:
	incbin	"../../build/stunrun-68k.bin",$670C,$4
str_6710:
	dc.b	'MSP*COMPLETE*TEST'
dat_6721:
	incbin	"../../build/stunrun-68k.bin",$6721,$1D
str_673E:
	dc.b	'YOU*HAVE*SELECTED'
dat_674F:
	incbin	"../../build/stunrun-68k.bin",$674F,$4
str_6753:
	dc.b	'GLOBAL*THERMONUCLEAR*WAR'
dat_676B:
	incbin	"../../build/stunrun-68k.bin",$676B,$4
str_676F:
	dc.b	'THANK*YOU*FOR*DECIDING'
dat_6785:
	incbin	"../../build/stunrun-68k.bin",$6785,$4
str_6789:
	dc.b	'TO*SERVICE*THE*ELEVATOR'
dat_67A0:
	incbin	"../../build/stunrun-68k.bin",$67A0,$4
str_67A4:
	dc.b	'HOORAY*FOR*HOLLYWOOD'
dat_67B8:
	incbin	"../../build/stunrun-68k.bin",$67B8,$4
str_67BC:
	dc.b	'THE*WAM*HAS*OVERHEATED*AGAIN'
dat_67D8:
	incbin	"../../build/stunrun-68k.bin",$67D8,$4
str_67DC:
	dc.b	'NOT*IMPLEMENTED*YET'
dat_67EF:
	incbin	"../../build/stunrun-68k.bin",$67EF,$4
str_67F3:
	dc.b	'TEST*MENU'
dat_67FC:
	incbin	"../../build/stunrun-68k.bin",$67FC,$4
str_6800:
	dc.b	'OPERATOR*SCREENS'
dat_6810:
	incbin	"../../build/stunrun-68k.bin",$6810,$4
str_6814:
	dc.b	'CONTROL*INPUTS'
dat_6822:
	incbin	"../../build/stunrun-68k.bin",$6822,$4
str_6826:
	dc.b	'MONITOR*TEST*PATTERNS'
dat_683B:
	incbin	"../../build/stunrun-68k.bin",$683B,$4
str_683F:
	dc.b	'SPECIAL*FUNCTIONS'
dat_6850:
	incbin	"../../build/stunrun-68k.bin",$6850,$4
str_6854:
	dc.b	'STUN*RUNNER*VERSION*V20.2'
dat_686D:
	incbin	"../../build/stunrun-68k.bin",$686D,$4
str_6871:
	dc.b	'COPYRIGHT*ATARI*GAMES*1989'
dat_688B:
	incbin	"../../build/stunrun-68k.bin",$688B,$4
str_688F:
	dc.b	'SPECIAL*FUNCTIONS'
dat_68A0:
	incbin	"../../build/stunrun-68k.bin",$68A0,$C
str_68AC:
	dc.b	'MAIN*BOARD*GSP*TESTS'
dat_68C0:
	incbin	"../../build/stunrun-68k.bin",$68C0,$4
str_68C4:
	dc.b	'RESERVED'
dat_68CC:
	incbin	"../../build/stunrun-68k.bin",$68CC,$4
str_68D0:
	dc.b	'MAIN*BOARD*ROM*CHECKSUMS'
dat_68E8:
	incbin	"../../build/stunrun-68k.bin",$68E8,$4
str_68EC:
	dc.b	'MAIN*BOARD*ZRAM*TEST'
dat_6900:
	incbin	"../../build/stunrun-68k.bin",$6900,$4
str_6904:
	dc.b	'ADSP*BOARD*TESTS'
dat_6914:
	incbin	"../../build/stunrun-68k.bin",$6914,$4
str_6918:
	dc.b	'SOUND*BOARD*TESTS'
dat_6929:
	incbin	"../../build/stunrun-68k.bin",$6929,$4
str_692D:
	dc.b	'PROCESSOR*STATUS*DATA'
dat_6942:
	incbin	"../../build/stunrun-68k.bin",$6942,$4
str_6946:
	dc.b	'INTERFACE*DATA:'
dat_6955:
	incbin	"../../build/stunrun-68k.bin",$6955,$4
str_6959:
	dc.b	'TEST*STATUS:'
dat_6965:
	incbin	"../../build/stunrun-68k.bin",$6965,$4
str_6969:
	dc.b	'MONITOR*BRIGHTNESS'
dat_697B:
	incbin	"../../build/stunrun-68k.bin",$697B,$4
str_697F:
	dc.b	'FOR*PROPER*GAME*OPERATION'
dat_6998:
	incbin	"../../build/stunrun-68k.bin",$6998,$4
str_699C:
	dc.b	'NOT*SEEN'
dat_69A4:
	incbin	"../../build/stunrun-68k.bin",$69A4,$4
str_69A8:
	dc.b	'STILL*NOT*SEEN'
dat_69B6:
	incbin	"../../build/stunrun-68k.bin",$69B6,$4
str_69BA:
	dc.b	'BARELY*SEEN'
dat_69C5:
	incbin	"../../build/stunrun-68k.bin",$69C5,$B
str_69D0:
	dc.b	'BRIGHT'
dat_69D6:
	incbin	"../../build/stunrun-68k.bin",$69D6,$4
str_69DA:
	dc.b	'GSP*TESTS'
dat_69E3:
	incbin	"../../build/stunrun-68k.bin",$69E3,$C
str_69EF:
	dc.b	'VRAM*SIMPLE*TEST:*18*SECONDS'
dat_6A0B:
	incbin	"../../build/stunrun-68k.bin",$6A0B,$4
str_6A0F:
	dc.b	'VRAM*VERIFY*TEST:*90*SECONDS'
dat_6A2B:
	incbin	"../../build/stunrun-68k.bin",$6A2B,$4
str_6A2F:
	dc.b	'VRAM*COMPLETE*TEST:*11*MINUTES'
dat_6A4D:
	incbin	"../../build/stunrun-68k.bin",$6A4D,$4
str_6A51:
	dc.b	'TEST*VRAM*FOR*DISPLAY*ERRORS'
dat_6A6D:
	incbin	"../../build/stunrun-68k.bin",$6A6D,$4
str_6A71:
	dc.b	'COLOR*RAM'
dat_6A7A:
	incbin	"../../build/stunrun-68k.bin",$6A7A,$4
str_6A7E:
	dc.b	'VRAM*SHIFT*REGISTER*TEST'
dat_6A96:
	incbin	"../../build/stunrun-68k.bin",$6A96,$4
str_6A9A:
	dc.b	'VRAM*DID*NOT*PASS*SIMPLE*TEST'
dat_6AB7:
	incbin	"../../build/stunrun-68k.bin",$6AB7,$4
str_6ABB:
	dc.b	'VRAM*DOES*NOT*VERIFY'
dat_6ACF:
	incbin	"../../build/stunrun-68k.bin",$6ACF,$4
str_6AD3:
	dc.b	'THE*WAM*HAS*OVERHEATED'
dat_6AE9:
	incbin	"../../build/stunrun-68k.bin",$6AE9,$1F
str_6B08:
	dc.b	'CONTROL*INPUTS'
dat_6B16:
	incbin	"../../build/stunrun-68k.bin",$6B16,$4
str_6B1A:
	dc.b	'RESERVED'
dat_6B22:
	incbin	"../../build/stunrun-68k.bin",$6B22,$4
str_6B26:
	dc.b	'BUS*ERROR*TEST'
dat_6B34:
	incbin	"../../build/stunrun-68k.bin",$6B34,$4
str_6B38:
	dc.b	'VRAM*SHIFT*REGISTER*TEST'
dat_6B50:
	incbin	"../../build/stunrun-68k.bin",$6B50,$4
str_6B54:
	dc.b	'VRAM*LOCATOR'
dat_6B60:
	incbin	"../../build/stunrun-68k.bin",$6B60,$4
str_6B64:
	dc.b	'PROGRAM*RAM*OK'
dat_6B72:
	incbin	"../../build/stunrun-68k.bin",$6B72,$4
str_6B76:
	dc.b	'BAD*PROGRAM*RAM*AT:'
dat_6B89:
	incbin	"../../build/stunrun-68k.bin",$6B89,$24
str_6BAD:
	dc.b	'PROGRAM*RAM*SHOULD*BE*FIXED'
dat_6BC8:
	incbin	"../../build/stunrun-68k.bin",$6BC8,$4
str_6BCC:
	dc.b	'BEFORE*CONTINUING*SELF-TEST'
dat_6BE7:
	incbin	"../../build/stunrun-68k.bin",$6BE7,$4
str_6BEB:
	dc.b	'PROGRAM*ROM*OK'
dat_6BF9:
	incbin	"../../build/stunrun-68k.bin",$6BF9,$4
str_6BFD:
	dc.b	'BAD*PROGRAM*ROM*IS*BLANK*BOX'
dat_6C19:
	incbin	"../../build/stunrun-68k.bin",$6C19,$4
str_6C1D:
	dc.b	'ROMS*AT*200R*AND*210R'
dat_6C32:
	incbin	"../../build/stunrun-68k.bin",$6C32,$4
str_6C36:
	dc.b	'CONTAIN*THE*SELF-TEST*PROGRAM'
dat_6C53:
	incbin	"../../build/stunrun-68k.bin",$6C53,$4
str_6C57:
	dc.b	'PRESS*START*TO*BYPASS*SELFTEST'
dat_6C75:
	incbin	"../../build/stunrun-68k.bin",$6C75,$4
str_6C79:
	dc.b	'PRESS*START*TO*CONTINUE'
dat_6C90:
	incbin	"../../build/stunrun-68k.bin",$6C90,$4
str_6C94:
	dc.b	'USING*THE*TEST*MENU:'
dat_6CA8:
	incbin	"../../build/stunrun-68k.bin",$6CA8,$4
str_6CAC:
	dc.b	'PRESS*RIGHT*TRIGGER'
dat_6CBF:
	incbin	"../../build/stunrun-68k.bin",$6CBF,$4
str_6CC3:
	dc.b	'TO*MOVE*DOWN*OR*TO*INCREMENT'
dat_6CDF:
	incbin	"../../build/stunrun-68k.bin",$6CDF,$4
str_6CE3:
	dc.b	'PRESS*LEFT*TRIGGER'
dat_6CF5:
	incbin	"../../build/stunrun-68k.bin",$6CF5,$4
str_6CF9:
	dc.b	'TO*MOVE*UP*OR*TO*DECREMENT'
dat_6D13:
	incbin	"../../build/stunrun-68k.bin",$6D13,$4
str_6D17:
	dc.b	'PRESS*START*TO*CHOOSE*ITEM'
dat_6D31:
	incbin	"../../build/stunrun-68k.bin",$6D31,$4
str_6D35:
	dc.b	'OR*TO*RETURN'
dat_6D41:
	incbin	"../../build/stunrun-68k.bin",$6D41,$25
str_6D66:
	dc.b	'PROGRAM*ROM*OK'
dat_6D74:
	incbin	"../../build/stunrun-68k.bin",$6D74,$4
str_6D78:
	dc.b	'BAD*PROGRAM*ROM'
dat_6D87:
	incbin	"../../build/stunrun-68k.bin",$6D87,$4
str_6D8B:
	dc.b	'PROGRAM*RAM*OK'
dat_6D99:
	incbin	"../../build/stunrun-68k.bin",$6D99,$4
str_6D9D:
	dc.b	'BAD*PROGRAM*RAM'
dat_6DAC:
	incbin	"../../build/stunrun-68k.bin",$6DAC,$4
str_6DB0:
	dc.b	'GSP*VRAM*OK*-*SIMPLE*TEST'
dat_6DC9:
	incbin	"../../build/stunrun-68k.bin",$6DC9,$4
str_6DCD:
	dc.b	'BAD*GSP*VRAM'
dat_6DD9:
	incbin	"../../build/stunrun-68k.bin",$6DD9,$18
str_6DF1:
	dc.b	'ADSP*BOARD*DOES*NOT*RESPOND'
dat_6E0C:
	incbin	"../../build/stunrun-68k.bin",$6E0C,$4
str_6E10:
	dc.b	'ADSP*TEST:*35*SECS*-*3*MINS'
dat_6E2B:
	incbin	"../../build/stunrun-68k.bin",$6E2B,$4
str_6E2F:
	dc.b	'ADSP*BOARD*OK'
dat_6E3C:
	incbin	"../../build/stunrun-68k.bin",$6E3C,$4
str_6E40:
	dc.b	'BAD*ADSP*RAM'
dat_6E4C:
	incbin	"../../build/stunrun-68k.bin",$6E4C,$4
str_6E50:
	dc.b	'ADSP-2100*DOES*NOT*RESPOND'
dat_6E6A:
	incbin	"../../build/stunrun-68k.bin",$6E6A,$4
str_6E6E:
	dc.b	'BAD*ADSP*ROM*CHECKSUM'
dat_6E83:
	incbin	"../../build/stunrun-68k.bin",$6E83,$4
str_6E87:
	dc.b	'PRESS*START*TO*SELECT*TEST*MENU'
dat_6EA6:
	incbin	"../../build/stunrun-68k.bin",$6EA6,$4
str_6EAA:
	dc.b	'GSP*COLOR*RAM*OK'
dat_6EBA:
	incbin	"../../build/stunrun-68k.bin",$6EBA,$4
str_6EBE:
	dc.b	'BAD*GSP*COLOR*RAM'
dat_6ECF:
	incbin	"../../build/stunrun-68k.bin",$6ECF,$4
str_6ED3:
	dc.b	'GSP*COLOR*RAM*TEST*IN*PROGRESS'
dat_6EF1:
	incbin	"../../build/stunrun-68k.bin",$6EF1,$23
str_6F14:
	dc.b	'CHECKSUM*TEST'
dat_6F21:
	incbin	"../../build/stunrun-68k.bin",$6F21,$4
str_6F25:
	dc.b	'LOOP*COUNT:'
dat_6F30:
	incbin	"../../build/stunrun-68k.bin",$6F30,$4
str_6F34:
	dc.b	'ROM*0*L*ERRORS:'
dat_6F43:
	incbin	"../../build/stunrun-68k.bin",$6F43,$4
str_6F47:
	dc.b	'ROM*0*H*ERRORS:'
dat_6F56:
	incbin	"../../build/stunrun-68k.bin",$6F56,$4
str_6F5A:
	dc.b	'RAM*TEST'
dat_6F62:
	incbin	"../../build/stunrun-68k.bin",$6F62,$4
str_6F66:
	dc.b	'LOOP*COUNT:'
dat_6F71:
	incbin	"../../build/stunrun-68k.bin",$6F71,$4
str_6F75:
	dc.b	'RAM*0*L*ERRORS:'
dat_6F84:
	incbin	"../../build/stunrun-68k.bin",$6F84,$4
str_6F88:
	dc.b	'RAM*0*H*ERRORS:'
dat_6F97:
	incbin	"../../build/stunrun-68k.bin",$6F97,$4
str_6F9B:
	dc.b	'RAM*1*L*ERRORS:'
dat_6FAA:
	incbin	"../../build/stunrun-68k.bin",$6FAA,$4
str_6FAE:
	dc.b	'RAM*1*H*ERRORS:'
dat_6FBD:
	incbin	"../../build/stunrun-68k.bin",$6FBD,$4
str_6FC1:
	dc.b	'MASS*ERRORS:'
dat_6FCD:
	incbin	"../../build/stunrun-68k.bin",$6FCD,$4
str_6FD1:
	dc.b	'MSP*TEST*1'
dat_6FDB:
	incbin	"../../build/stunrun-68k.bin",$6FDB,$4
str_6FDF:
	dc.b	'LOOP*COUNT:'
dat_6FEA:
	incbin	"../../build/stunrun-68k.bin",$6FEA,$4
str_6FEE:
	dc.b	'INTERFACE*ERRORS:'
dat_6FFF:
	incbin	"../../build/stunrun-68k.bin",$6FFF,$4
str_7003:
	dc.b	'MSP*TEST*2'
dat_700D:
	incbin	"../../build/stunrun-68k.bin",$700D,$4
str_7011:
	dc.b	'AUTO-INCREMENT*ERRORS:'
dat_7027:
	incbin	"../../build/stunrun-68k.bin",$7027,$4
str_702B:
	dc.b	'MSP*TEST*3'
dat_7035:
	incbin	"../../build/stunrun-68k.bin",$7035,$4
str_7039:
	dc.b	'MSP*IRQ*ERRORS:'
dat_7048:
	incbin	"../../build/stunrun-68k.bin",$7048,$4
str_704C:
	dc.b	'MSP*TEST*4'
dat_7056:
	incbin	"../../build/stunrun-68k.bin",$7056,$4
str_705A:
	dc.b	'DRAM*VERIFY*ERRORS:'
dat_706D:
	incbin	"../../build/stunrun-68k.bin",$706D,$4
str_7071:
	dc.b	'VRAM*VERIFY*TEST'
dat_7081:
	incbin	"../../build/stunrun-68k.bin",$7081,$4
str_7085:
	dc.b	'VRAM*VERIFY*ERRORS:'
dat_7098:
	incbin	"../../build/stunrun-68k.bin",$7098,$4
str_709C:
	dc.b	'REMOVE*DUART*AND*CHECK*BERR'
dat_70B7:
	incbin	"../../build/stunrun-68k.bin",$70B7,$4
str_70BB:
	dc.b	'THIS*DIAGNOSTIC*CODE*NOT*USED'
dat_70D8:
	incbin	"../../build/stunrun-68k.bin",$70D8,$4
str_70DC:
	dc.b	'OPTION*SWITCH'
dat_70E9:
	incbin	"../../build/stunrun-68k.bin",$70E9,$2A
str_7113:
	dc.b	'SA*AUDIO*TEST*MENU'
dat_7125:
	incbin	"../../build/stunrun-68k.bin",$7125,$C
str_7131:
	dc.b	'SA*SELF*TEST'
dat_713D:
	incbin	"../../build/stunrun-68k.bin",$713D,$4
str_7141:
	dc.b	'PLAY*SOUNDS'
dat_714C:
	incbin	"../../build/stunrun-68k.bin",$714C,$4
str_7150:
	dc.b	'SA*AUDIO*TEST'
dat_715D:
	incbin	"../../build/stunrun-68k.bin",$715D,$4
str_7161:
	dc.b	'ERROR*80**P1BAD**6502*PROGRAM*PROM*BAD'
dat_7187:
	incbin	"../../build/stunrun-68k.bin",$7187,$4
str_718B:
	dc.b	'ERROR*40**P2BAD**6502*PROGRAM*PROM*BAD'
dat_71B1:
	incbin	"../../build/stunrun-68k.bin",$71B1,$4
str_71B5:
	dc.b	'ERROR*20**P3BAD**6502*PROGRAM*PROM*BAD'
dat_71DB:
	incbin	"../../build/stunrun-68k.bin",$71DB,$4
str_71DF:
	dc.b	'ERROR*10**R1BAD**1ST*0000*RAM*BAD'
dat_7200:
	incbin	"../../build/stunrun-68k.bin",$7200,$4
str_7204:
	dc.b	'ERROR*08**R2BAD**2ND*0800*RAM*BAD'
dat_7225:
	incbin	"../../build/stunrun-68k.bin",$7225,$4
str_7229:
	dc.b	'ERROR*04**IRBAD**IRQS*NOT*PRESENT'
dat_724A:
	incbin	"../../build/stunrun-68k.bin",$724A,$4
str_724E:
	dc.b	'ERROR*02**YMBAD**YAMAHA*TIMED*OUT'
dat_726F:
	incbin	"../../build/stunrun-68k.bin",$726F,$4
str_7273:
	dc.b	'ERROR*01**MLBAD**MAINLINE*NOT*RUNNING'
dat_7298:
	incbin	"../../build/stunrun-68k.bin",$7298,$4
str_729C:
	dc.b	'SA*AUDIO*TIMEOUT*ERROR'
dat_72B2:
	incbin	"../../build/stunrun-68k.bin",$72B2,$4
str_72B6:
	dc.b	'SA*AUDIO*TEST*OK'
dat_72C6:
	incbin	"../../build/stunrun-68k.bin",$72C6,$4
str_72CA:
	dc.b	'SA*II*TEST*IN*PROGRESS'
dat_72E0:
	incbin	"../../build/stunrun-68k.bin",$72E0,$4
str_72E4:
	dc.b	'BUS*ERROR'
dat_72ED:
	incbin	"../../build/stunrun-68k.bin",$72ED,$4
str_72F1:
	dc.b	'ADDRESS*ERROR'
dat_72FE:
	incbin	"../../build/stunrun-68k.bin",$72FE,$4
str_7302:
	dc.b	'ILLEGAL*INSTRUCTION'
dat_7315:
	incbin	"../../build/stunrun-68k.bin",$7315,$4
str_7319:
	dc.b	'ZERO*DIVIDE'
dat_7324:
	incbin	"../../build/stunrun-68k.bin",$7324,$4
str_7328:
	dc.b	'CHK*INSTRUCTION'
dat_7337:
	incbin	"../../build/stunrun-68k.bin",$7337,$4
str_733B:
	dc.b	'TRAPV*INSTRUCTION'
dat_734C:
	incbin	"../../build/stunrun-68k.bin",$734C,$4
str_7350:
	dc.b	'PRIVLEGE*VIOLATION'
dat_7362:
	incbin	"../../build/stunrun-68k.bin",$7362,$D
str_736F:
	dc.b	'FORMAT*ERROR'
dat_737B:
	incbin	"../../build/stunrun-68k.bin",$737B,$4
str_737F:
	dc.b	'UNINITIALIZED*INT*VEC'
dat_7394:
	incbin	"../../build/stunrun-68k.bin",$7394,$4
str_7398:
	dc.b	'SPURIOUS*INTERRUPT'
dat_73AA:
	incbin	"../../build/stunrun-68k.bin",$73AA,$13
str_73BD:
	dc.b	'PROGRAM*ROM*CHECKSUMS'
dat_73D2:
	incbin	"../../build/stunrun-68k.bin",$73D2,$4
str_73D6:
	dc.b	'LOC.*CHKSUM*EXPECT'
dat_73E8:
	incbin	"../../build/stunrun-68k.bin",$73E8,$4
str_73EC:
	dc.b	'LOC.*CHKSUM*EXPECT'
dat_73FE:
	incbin	"../../build/stunrun-68k.bin",$73FE,$94
str_7492:
	dc.b	'XX*=*DO*NOT*CARE'
dat_74A2:
	incbin	"../../build/stunrun-68k.bin",$74A2,$84
str_7526:
	dc.b	'GSP*COLOR*RAM*OK'
dat_7536:
	incbin	"../../build/stunrun-68k.bin",$7536,$4
str_753A:
	dc.b	'BAD*GSP*COLOR*RAM*AT:'
dat_754F:
	incbin	"../../build/stunrun-68k.bin",$754F,$2E
str_757D:
	dc.b	'ZRAM*TEST'
dat_7586:
	incbin	"../../build/stunrun-68k.bin",$7586,$4
str_758A:
	dc.b	'IF*GAME*IS*POWERED*DOWN*OR'
dat_75A4:
	incbin	"../../build/stunrun-68k.bin",$75A4,$4
str_75A8:
	dc.b	'RESET*DURING*THIS*TEST,'
dat_75BF:
	incbin	"../../build/stunrun-68k.bin",$75BF,$4
str_75C3:
	dc.b	'GAME*STATS*AND*SETUP'
dat_75D7:
	incbin	"../../build/stunrun-68k.bin",$75D7,$4
str_75DB:
	dc.b	'WILL*BE*LOST'
dat_75E7:
	incbin	"../../build/stunrun-68k.bin",$75E7,$4
str_75EB:
	dc.b	'PRESS*START*TO*RETURN*TO*THE'
dat_7607:
	incbin	"../../build/stunrun-68k.bin",$7607,$4
str_760B:
	dc.b	'MENU*WITHOUT*RUNNING*THE*TEST'
dat_7628:
	incbin	"../../build/stunrun-68k.bin",$7628,$4
str_762C:
	dc.b	'PRESS*INC*AND*DEC*TO'
dat_7640:
	incbin	"../../build/stunrun-68k.bin",$7640,$4
str_7644:
	dc.b	'TEST*THE*ZRAM'
dat_7651:
	incbin	"../../build/stunrun-68k.bin",$7651,$4
str_7655:
	dc.b	'ZRAM*OK'
dat_765C:
	incbin	"../../build/stunrun-68k.bin",$765C,$24
str_7680:
	dc.b	'ADSP*BOARD*TESTS'
dat_7690:
	incbin	"../../build/stunrun-68k.bin",$7690,$C
str_769C:
	dc.b	'ADSP*RAM*.TESTED*BY*68010.'
dat_76B6:
	incbin	"../../build/stunrun-68k.bin",$76B6,$4
str_76BA:
	dc.b	'ADSP*PROGRAM*MEMORY*TEST*.2100.'
dat_76D9:
	incbin	"../../build/stunrun-68k.bin",$76D9,$4
str_76DD:
	dc.b	'ADSP*DATA*MEMORY*TEST*.2100.'
dat_76F9:
	incbin	"../../build/stunrun-68k.bin",$76F9,$11
str_770A:
	dc.b	'IRQ*TEST'
dat_7712:
	incbin	"../../build/stunrun-68k.bin",$7712,$4
str_7716:
	dc.b	'ROM*CHECKSUMS'
dat_7723:
	incbin	"../../build/stunrun-68k.bin",$7723,$4
str_7727:
	dc.b	'ADSP*SPECIAL*FUNCTIONS'
dat_773D:
	incbin	"../../build/stunrun-68k.bin",$773D,$4
str_7741:
	dc.b	'2100*RESPONDS'
dat_774E:
	incbin	"../../build/stunrun-68k.bin",$774E,$4
str_7752:
	dc.b	'2100*DOES*NOT*RESPOND'
dat_7767:
	incbin	"../../build/stunrun-68k.bin",$7767,$4
str_776B:
	dc.b	'2100*IRQS*OK'
dat_7777:
	incbin	"../../build/stunrun-68k.bin",$7777,$4
str_777B:
	dc.b	'NO*2100*IRQS'
dat_7787:
	incbin	"../../build/stunrun-68k.bin",$7787,$4
str_778B:
	dc.b	'ADSP*TIMEOUT'
dat_7797:
	incbin	"../../build/stunrun-68k.bin",$7797,$4
str_779B:
	dc.b	'ADSP*HIGH*BANK*PROGRAM*MEMORY*TEST*TIMEOUT'
dat_77C5:
	incbin	"../../build/stunrun-68k.bin",$77C5,$4
str_77C9:
	dc.b	'ADSP*LOW*BANK*PROGRAM*MEMORY*TEST*TIMEOUT'
dat_77F2:
	incbin	"../../build/stunrun-68k.bin",$77F2,$4
str_77F6:
	dc.b	'ADSP*TEST*ABORTED'
dat_7807:
	incbin	"../../build/stunrun-68k.bin",$7807,$4
str_780B:
	dc.b	'ADSP*ROM*CHECKSUMS'
dat_781D:
	incbin	"../../build/stunrun-68k.bin",$781D,$DC
str_78F9:
	dc.b	'LOC.****CHKSUM**EXPECT'
dat_790F:
	incbin	"../../build/stunrun-68k.bin",$790F,$4
str_7913:
	dc.b	'XX*=*DO*NOT*CARE'
dat_7923:
	incbin	"../../build/stunrun-68k.bin",$7923,$4
str_7927:
	dc.b	'ADSP*SCOPE*LOOPS'
dat_7937:
	incbin	"../../build/stunrun-68k.bin",$7937,$C
str_7943:
	dc.b	'SEQ*INPUT*MEM*READS'
dat_7956:
	incbin	"../../build/stunrun-68k.bin",$7956,$4
str_795A:
	dc.b	'SEQ*INPUT*MEM*ADR*WRITES'
dat_7972:
	incbin	"../../build/stunrun-68k.bin",$7972,$4
str_7976:
	dc.b	'SEQ*OUTPUT*WRITES,*INC*DATA,*BUF*1'
dat_7998:
	incbin	"../../build/stunrun-68k.bin",$7998,$4
str_799C:
	dc.b	'SEQ*OUTPUT*ADR*WRITES,*BUF*1'
dat_79B8:
	incbin	"../../build/stunrun-68k.bin",$79B8,$4
str_79BC:
	dc.b	'SEQ*OUTPUT*WRITES,*INC*DATA,*BUF*2'
dat_79DE:
	incbin	"../../build/stunrun-68k.bin",$79DE,$4
str_79E2:
	dc.b	'SEQ*OUTPUT*ADR*WRITES,*BUF*2'
dat_79FE:
	incbin	"../../build/stunrun-68k.bin",$79FE,$4
str_7A02:
	dc.b	'TOGGLE*MPAGE'
dat_7A0E:
	incbin	"../../build/stunrun-68k.bin",$7A0E,$4
str_7A12:
	dc.b	'TOGGLE*XFLAG'
dat_7A1E:
	incbin	"../../build/stunrun-68k.bin",$7A1E,$4
str_7A22:
	dc.b	'TOGGLE*BCON'
dat_7A2D:
	incbin	"../../build/stunrun-68k.bin",$7A2D,$12
str_7A3F:
	dc.b	'INC*DM*DATA'
dat_7A4A:
	incbin	"../../build/stunrun-68k.bin",$7A4A,$12
str_7A5C:
	dc.b	'INC*PM*DATA*8-23'
dat_7A6C:
	incbin	"../../build/stunrun-68k.bin",$7A6C,$4
str_7A70:
	dc.b	'INC*PM*DATA*0-7'
dat_7A7F:
	incbin	"../../build/stunrun-68k.bin",$7A7F,$4
str_7A83:
	dc.b	'CONTROL*LEFT/RIGHT'
dat_7A95:
	incbin	"../../build/stunrun-68k.bin",$7A95,$4
str_7A99:
	dc.b	'CONTROL*UP/DOWN'
dat_7AA8:
	incbin	"../../build/stunrun-68k.bin",$7AA8,$4
str_7AAC:
	dc.b	'SA*II*TEST*OK'
dat_7AB9:
	incbin	"../../build/stunrun-68k.bin",$7AB9,$4
str_7ABD:
	dc.b	'SA*II*TEST*ERROR'
dat_7ACD:
	incbin	"../../build/stunrun-68k.bin",$7ACD,$4
str_7AD1:
	dc.b	'SA*II*TIMEOUT*ERROR'
dat_7AE4:
	incbin	"../../build/stunrun-68k.bin",$7AE4,$4
str_7AE8:
	dc.b	'SA*II*TEST*IN*PROGRESS'
dat_7AFE:
	incbin	"../../build/stunrun-68k.bin",$7AFE,$28
str_7B26:
	dc.b	'LEFT*TRIGGER'
dat_7B32:
	incbin	"../../build/stunrun-68k.bin",$7B32,$4
str_7B36:
	dc.b	'LEFT*TRIGGER'
dat_7B42:
	incbin	"../../build/stunrun-68k.bin",$7B42,$4
str_7B46:
	dc.b	'RIGHT*TRIGGER'
dat_7B53:
	incbin	"../../build/stunrun-68k.bin",$7B53,$4
str_7B57:
	dc.b	'RIGHT*TRIGGER'
dat_7B64:
	incbin	"../../build/stunrun-68k.bin",$7B64,$4
str_7B68:
	dc.b	'CONTROL'
dat_7B6F:
	incbin	"../../build/stunrun-68k.bin",$7B6F,$4
str_7B73:
	dc.b	'AUX*COIN'
dat_7B7B:
	incbin	"../../build/stunrun-68k.bin",$7B7B,$4
str_7B7F:
	dc.b	'AUX*COIN'
dat_7B87:
	incbin	"../../build/stunrun-68k.bin",$7B87,$4
str_7B8B:
	dc.b	'WRITE,*THEN*READ'
dat_7B9B:
	incbin	"../../build/stunrun-68k.bin",$7B9B,$4
str_7B9F:
	dc.b	'RED/GREEN*COLOR*RAM'
dat_7BB2:
	incbin	"../../build/stunrun-68k.bin",$7BB2,$1B
str_7BCD:
	dc.b	'ADR=2AA***DATA=AAAA'
dat_7BE0:
	incbin	"../../build/stunrun-68k.bin",$7BE0,$4
str_7BE4:
	dc.b	'BLUE*COLOR*RAM'
dat_7BF2:
	incbin	"../../build/stunrun-68k.bin",$7BF2,$19
str_7C0B:
	dc.b	'ADR=2AA***DATA=AA'
dat_7C1C:
	incbin	"../../build/stunrun-68k.bin",$7C1C,$4
str_7C20:
	dc.b	'LED1*ON*=*ERROR'
dat_7C2F:
	incbin	"../../build/stunrun-68k.bin",$7C2F,$4
str_7C33:
	dc.b	'COLOR*RAM*LOOP*TEST'
dat_7C46:
	incbin	"../../build/stunrun-68k.bin",$7C46,$4
str_7C4A:
	dc.b	'LOOP*COUNT:'
dat_7C55:
	incbin	"../../build/stunrun-68k.bin",$7C55,$4
str_7C59:
	dc.b	'FAILED*TESTS:'
dat_7C66:
	incbin	"../../build/stunrun-68k.bin",$7C66,$4
str_7C6A:
	dc.b	'ADSP*SPECIAL*FUNCTIONS'
dat_7C80:
	incbin	"../../build/stunrun-68k.bin",$7C80,$C
str_7C8C:
	dc.b	'SEQ*OUTPUT*BUFFER*CONTROL*CHECK'
dat_7CAB:
	incbin	"../../build/stunrun-68k.bin",$7CAB,$4
str_7CAF:
	dc.b	'SEQ*OUTPUT*BUFFER*1*TESTS'
dat_7CC8:
	incbin	"../../build/stunrun-68k.bin",$7CC8,$4
str_7CCC:
	dc.b	'SEQ*OUTPUT*BUFFER*2*TESTS'
dat_7CE5:
	incbin	"../../build/stunrun-68k.bin",$7CE5,$4
str_7CE9:
	dc.b	'ADSP*DATA*MEMORY*TESTS'
dat_7CFF:
	incbin	"../../build/stunrun-68k.bin",$7CFF,$4
str_7D03:
	dc.b	'ADSP*PROGRAM*MEMORY*TESTS'
dat_7D1C:
	incbin	"../../build/stunrun-68k.bin",$7D1C,$4
str_7D20:
	dc.b	'SCOPE*LOOPS'
dat_7D2B:
	incbin	"../../build/stunrun-68k.bin",$7D2B,$4
str_7D2F:
	dc.b	'SEQ*OUTPUT*BUFFER*CONTROL*CHECK'
dat_7D4E:
	incbin	"../../build/stunrun-68k.bin",$7D4E,$4
str_7D52:
	dc.b	'68010*WRITES*0000*TO*BUFFER*1*AND*FFFF*TO*BUFFER*2'
dat_7D84:
	incbin	"../../build/stunrun-68k.bin",$7D84,$2D
str_7DB1:
	dc.b	'BUFFER*2*****WRITE*=*FFFF*****READ*=*'
dat_7DD6:
	incbin	"../../build/stunrun-68k.bin",$7DD6,$4
str_7DDA:
	dc.b	'68010*WRITES*FFFF*TO*BUFFER*1*AND*0000*TO*BUFFER*2'
dat_7E0C:
	incbin	"../../build/stunrun-68k.bin",$7E0C,$4
str_7E10:
	dc.b	'BUFFER*1*****WRITE*=*FFFF*****READ*=*'
dat_7E35:
	incbin	"../../build/stunrun-68k.bin",$7E35,$2D
str_7E62:
	dc.b	'BUFFER*CONTROL*.BCON.*OK'
dat_7E7A:
	incbin	"../../build/stunrun-68k.bin",$7E7A,$4
str_7E7E:
	dc.b	'CHECK*.BCON.*SIGNAL'
dat_7E91:
	incbin	"../../build/stunrun-68k.bin",$7E91,$C
str_7E9D:
	dc.b	'ROTATE*ONES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.68010.'
dat_7ED1:
	incbin	"../../build/stunrun-68k.bin",$7ED1,$4
str_7ED5:
	dc.b	'ROTATE*ONES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.2100.'
dat_7F08:
	incbin	"../../build/stunrun-68k.bin",$7F08,$4
str_7F0C:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.68010.'
dat_7F42:
	incbin	"../../build/stunrun-68k.bin",$7F42,$4
str_7F46:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.2100.'
dat_7F7B:
	incbin	"../../build/stunrun-68k.bin",$7F7B,$4
str_7F7F:
	dc.b	'TEST*ALL*DATA*AT*BUFFER*ADDRESS*0000*.68010.'
dat_7FAB:
	incbin	"../../build/stunrun-68k.bin",$7FAB,$4
str_7FAF:
	dc.b	'TEST*ALL*DATA*AT*BUFFER*ADDRESS*0000*.2100.'
dat_7FDA:
	incbin	"../../build/stunrun-68k.bin",$7FDA,$4
str_7FDE:
	dc.b	'ROTATE*ONES*THRU*BUFFER*ADDRESS*.68010.'
dat_8005:
	incbin	"../../build/stunrun-68k.bin",$8005,$4
str_8009:
	dc.b	'ROTATE*ONES*THRU*BUFFER*ADDRESS*.2100.'
dat_802F:
	incbin	"../../build/stunrun-68k.bin",$802F,$4
str_8033:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*ADDRESS*.68010.'
dat_805C:
	incbin	"../../build/stunrun-68k.bin",$805C,$4
str_8060:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*ADDRESS*.2100.'
dat_8088:
	incbin	"../../build/stunrun-68k.bin",$8088,$4
str_808C:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.68010.'
dat_80AF:
	incbin	"../../build/stunrun-68k.bin",$80AF,$4
str_80B3:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.2100*INC'
str_80D8:
	dc.b	'*ADR.'
dat_80DD:
	incbin	"../../build/stunrun-68k.bin",$80DD,$4
str_80E1:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.2100*LOAD*ADR.'
dat_810C:
	incbin	"../../build/stunrun-68k.bin",$810C,$4
str_8110:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.68010.'
dat_8130:
	incbin	"../../build/stunrun-68k.bin",$8130,$4
str_8134:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.2100*INC*ADR.'
dat_815B:
	incbin	"../../build/stunrun-68k.bin",$815B,$4
str_815F:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.2100*LOAD*ADR.'
dat_8187:
	incbin	"../../build/stunrun-68k.bin",$8187,$4
str_818B:
	dc.b	'SEQ*OUTPUT*BUFFER*1*TESTS'
dat_81A4:
	incbin	"../../build/stunrun-68k.bin",$81A4,$4
str_81A8:
	dc.b	'SEQ*OUTPUT*BUFFER*2*TESTS'
dat_81C1:
	incbin	"../../build/stunrun-68k.bin",$81C1,$4
str_81C5:
	dc.b	'ADSP*DATA*MEMORY*TESTS'
dat_81DB:
	incbin	"../../build/stunrun-68k.bin",$81DB,$4
str_81DF:
	dc.b	'ADSP*PROGRAM*MEMORY*TESTS'
dat_81F8:
	incbin	"../../build/stunrun-68k.bin",$81F8,$D
str_8205:
	dc.b	'DATA*ERROR******PRESS*INC*OR*DEC*TO*CONTINUE'
dat_8231:
	incbin	"../../build/stunrun-68k.bin",$8231,$4
str_8235:
	dc.b	'LOOP*COUNT:'
dat_8240:
	incbin	"../../build/stunrun-68k.bin",$8240,$12
str_8252:
	dc.b	'DATA*SHOULD*EQUAL*ADDRESS'
dat_826B:
	incbin	"../../build/stunrun-68k.bin",$826B,$4
str_826F:
	dc.b	'ADDRESS'
dat_8276:
	incbin	"../../build/stunrun-68k.bin",$8276,$C
str_8282:
	dc.b	'ADSP*DATA*MEMORY*TESTS'
dat_8298:
	incbin	"../../build/stunrun-68k.bin",$8298,$4
str_829C:
	dc.b	'ADSP*PROGRAM*MEMORY*TESTS'
dat_82B5:
	incbin	"../../build/stunrun-68k.bin",$82B5,$4
str_82B9:
	dc.b	'ADSP*II*BOARD'
dat_82C6:
	incbin	"../../build/stunrun-68k.bin",$82C6,$4
str_82CA:
	dc.b	'ROTATE*ONES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.68010.'
dat_82FE:
	incbin	"../../build/stunrun-68k.bin",$82FE,$4
str_8302:
	dc.b	'ROTATE*ONES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.2100.'
dat_8335:
	incbin	"../../build/stunrun-68k.bin",$8335,$4
str_8339:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.68010.'
dat_836F:
	incbin	"../../build/stunrun-68k.bin",$836F,$4
str_8373:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*DATA*AT*ADDRESS*0000*.2100.'
dat_83A8:
	incbin	"../../build/stunrun-68k.bin",$83A8,$4
str_83AC:
	dc.b	'TEST*ALL*DATA*AT*BUFFER*ADDRESS*0000*.68010.'
dat_83D8:
	incbin	"../../build/stunrun-68k.bin",$83D8,$4
str_83DC:
	dc.b	'TEST*ALL*DATA*AT*BUFFER*ADDRESS*0000*.2100.'
dat_8407:
	incbin	"../../build/stunrun-68k.bin",$8407,$4
str_840B:
	dc.b	'ROTATE*ONES*THRU*BUFFER*ADDRESS*.68010.'
dat_8432:
	incbin	"../../build/stunrun-68k.bin",$8432,$4
str_8436:
	dc.b	'ROTATE*ONES*THRU*BUFFER*ADDRESS*.2100.'
dat_845C:
	incbin	"../../build/stunrun-68k.bin",$845C,$4
str_8460:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*ADDRESS*.68010.'
dat_8489:
	incbin	"../../build/stunrun-68k.bin",$8489,$4
str_848D:
	dc.b	'ROTATE*ZEROES*THRU*BUFFER*ADDRESS*.2100.'
dat_84B5:
	incbin	"../../build/stunrun-68k.bin",$84B5,$4
str_84B9:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.68010.'
dat_84DC:
	incbin	"../../build/stunrun-68k.bin",$84DC,$4
str_84E0:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.2100*INC*ADR.'
dat_850A:
	incbin	"../../build/stunrun-68k.bin",$850A,$4
str_850E:
	dc.b	'TEST*BUFFER,*DATA*=*ADDRESS*.2100*LOAD*ADR.'
dat_8539:
	incbin	"../../build/stunrun-68k.bin",$8539,$4
str_853D:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.68010.'
dat_855D:
	incbin	"../../build/stunrun-68k.bin",$855D,$4
str_8561:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.2100*INC*ADR.'
dat_8588:
	incbin	"../../build/stunrun-68k.bin",$8588,$4
str_858C:
	dc.b	'TEST*BUFFER,*RANDOM*DATA*.2100*LOAD*ADR.'
dat_85B4:
	incbin	"../../build/stunrun-68k.bin",$85B4,$C
str_85C0:
	dc.b	'ROTATE*ONES*THRU*DM*DATA*AT*ADDRESS*0000*.68010.'
dat_85F0:
	incbin	"../../build/stunrun-68k.bin",$85F0,$4
str_85F4:
	dc.b	'ROTATE*ONES*THRU*DM*DATA*AT*ADDRESS*0000*.2100.'
dat_8623:
	incbin	"../../build/stunrun-68k.bin",$8623,$4
str_8627:
	dc.b	'ROTATE*ZEROES*THRU*DM*DATA*AT*ADDRESS*0000*.68010.'
dat_8659:
	incbin	"../../build/stunrun-68k.bin",$8659,$4
str_865D:
	dc.b	'ROTATE*ZEROES*THRU*DM*DATA*AT*ADDRESS*0000*.2100.'
dat_868E:
	incbin	"../../build/stunrun-68k.bin",$868E,$4
str_8692:
	dc.b	'TEST*ALL*DATA*AT*DM*ADDRESS*0000*.68010.'
dat_86BA:
	incbin	"../../build/stunrun-68k.bin",$86BA,$4
str_86BE:
	dc.b	'TEST*ALL*DATA*AT*DM*ADDRESS*0000*.2100.'
dat_86E5:
	incbin	"../../build/stunrun-68k.bin",$86E5,$4
str_86E9:
	dc.b	'ROTATE*ONES*THRU*DM*ADDRESS*.68010.'
dat_870C:
	incbin	"../../build/stunrun-68k.bin",$870C,$4
str_8710:
	dc.b	'ROTATE*ONES*THRU*DM*ADDRESS*.2100.'
dat_8732:
	incbin	"../../build/stunrun-68k.bin",$8732,$4
str_8736:
	dc.b	'ROTATE*ZEROES*THRU*DM*ADDRESS*.68010.'
dat_875B:
	incbin	"../../build/stunrun-68k.bin",$875B,$4
str_875F:
	dc.b	'ROTATE*ZEROES*THRU*DM*ADDRESS*.2100.'
dat_8783:
	incbin	"../../build/stunrun-68k.bin",$8783,$4
str_8787:
	dc.b	'TEST*DM,*DATA*=*ADDRESS*.68010.'
dat_87A6:
	incbin	"../../build/stunrun-68k.bin",$87A6,$4
str_87AA:
	dc.b	'TEST*DM,*DATA*=*ADDRESS*.2100.'
dat_87C8:
	incbin	"../../build/stunrun-68k.bin",$87C8,$4
str_87CC:
	dc.b	'TEST*DM,*RANDOM*DATA*.68010.'
dat_87E8:
	incbin	"../../build/stunrun-68k.bin",$87E8,$4
str_87EC:
	dc.b	'TEST*DM,*RANDOM*DATA*.2100.'
dat_8807:
	incbin	"../../build/stunrun-68k.bin",$8807,$4
str_880B:
	dc.b	'ROTATE*ONES*THRU*DM*DATA*AT*ADDRESS*0000*.68010.'
dat_883B:
	incbin	"../../build/stunrun-68k.bin",$883B,$4
str_883F:
	dc.b	'ROTATE*ONES*THRU*DM*DATA*AT*ADDRESS*0000*.2100.'
dat_886E:
	incbin	"../../build/stunrun-68k.bin",$886E,$4
str_8872:
	dc.b	'ROTATE*ZEROES*THRU*DM*DATA*AT*ADDRESS*0000*.68010.'
dat_88A4:
	incbin	"../../build/stunrun-68k.bin",$88A4,$4
str_88A8:
	dc.b	'ROTATE*ZEROES*THRU*DM*DATA*AT*ADDRESS*0000*.2100.'
dat_88D9:
	incbin	"../../build/stunrun-68k.bin",$88D9,$4
str_88DD:
	dc.b	'TEST*ALL*DATA*AT*DM*ADDRESS*0000*.68010.'
dat_8905:
	incbin	"../../build/stunrun-68k.bin",$8905,$4
str_8909:
	dc.b	'TEST*ALL*DATA*AT*DM*ADDRESS*0000*.2100.'
dat_8930:
	incbin	"../../build/stunrun-68k.bin",$8930,$4
str_8934:
	dc.b	'ROTATE*ONES*THRU*DM*ADDRESS*.68010.'
dat_8957:
	incbin	"../../build/stunrun-68k.bin",$8957,$4
str_895B:
	dc.b	'ROTATE*ONES*THRU*DM*ADDRESS*.2100.'
dat_897D:
	incbin	"../../build/stunrun-68k.bin",$897D,$4
str_8981:
	dc.b	'ROTATE*ZEROES*THRU*DM*ADDRESS*.68010.'
dat_89A6:
	incbin	"../../build/stunrun-68k.bin",$89A6,$4
str_89AA:
	dc.b	'ROTATE*ZEROES*THRU*DM*ADDRESS*.2100.'
dat_89CE:
	incbin	"../../build/stunrun-68k.bin",$89CE,$4
str_89D2:
	dc.b	'TEST*DM,*DATA*=*ADDRESS*.68010.'
dat_89F1:
	incbin	"../../build/stunrun-68k.bin",$89F1,$4
str_89F5:
	dc.b	'TEST*DM,*DATA*=*ADDRESS*.2100.'
dat_8A13:
	incbin	"../../build/stunrun-68k.bin",$8A13,$4
str_8A17:
	dc.b	'TEST*DM,*RANDOM*DATA*.68010.'
dat_8A33:
	incbin	"../../build/stunrun-68k.bin",$8A33,$4
str_8A37:
	dc.b	'TEST*DM,*RANDOM*DATA*.2100.'
dat_8A52:
	incbin	"../../build/stunrun-68k.bin",$8A52,$C
str_8A5E:
	dc.b	'ROTATE*ONES*THRU*PM*DATA*AT*ADDRESS*0000*.68010.'
dat_8A8E:
	incbin	"../../build/stunrun-68k.bin",$8A8E,$4
str_8A92:
	dc.b	'ROTATE*ONES*THRU*PM*DATA*AT*ADDRESS*0000*.2100.'
dat_8AC1:
	incbin	"../../build/stunrun-68k.bin",$8AC1,$4
str_8AC5:
	dc.b	'ROTATE*ZEROES*THRU*PM*DATA*AT*ADDRESS*0000*.68010.'
dat_8AF7:
	incbin	"../../build/stunrun-68k.bin",$8AF7,$4
str_8AFB:
	dc.b	'ROTATE*ZEROES*THRU*PM*DATA*AT*ADDRESS*0000*.2100.'
dat_8B2C:
	incbin	"../../build/stunrun-68k.bin",$8B2C,$4
str_8B30:
	dc.b	'ROTATE*ONES*THRU*PM*ADDRESS*.68010.'
dat_8B53:
	incbin	"../../build/stunrun-68k.bin",$8B53,$4
str_8B57:
	dc.b	'ROTATE*ZEROES*THRU*PM*ADDRESS*.68010.'
dat_8B7C:
	incbin	"../../build/stunrun-68k.bin",$8B7C,$4
str_8B80:
	dc.b	'ROTATE*ONES*THRU*PM*DATA*AT*ADDRESS*0000*.68010.'
dat_8BB0:
	incbin	"../../build/stunrun-68k.bin",$8BB0,$4
str_8BB4:
	dc.b	'ROTATE*ONES*THRU*PM*DATA*AT*ADDRESS*0000*.2100.'
dat_8BE3:
	incbin	"../../build/stunrun-68k.bin",$8BE3,$4
str_8BE7:
	dc.b	'ROTATE*ZEROES*THRU*PM*DATA*AT*ADDRESS*0000*.68010.'
dat_8C19:
	incbin	"../../build/stunrun-68k.bin",$8C19,$4
str_8C1D:
	dc.b	'ROTATE*ZEROES*THRU*PM*DATA*AT*ADDRESS*0000*.2100.'
dat_8C4E:
	incbin	"../../build/stunrun-68k.bin",$8C4E,$4
str_8C52:
	dc.b	'ROTATE*ONES*THRU*PM*ADDRESS*.68010.'
dat_8C75:
	incbin	"../../build/stunrun-68k.bin",$8C75,$4
str_8C79:
	dc.b	'ROTATE*ZEROES*THRU*PM*ADDRESS*.68010.'
loc_8C9E:
	clr.w	(ram_FF8036-ABS_SHORT).w
	clr.w	(ram_FF8046-ABS_SHORT).w
	clr.w	(ram_FF8056-ABS_SHORT).w
	clr.w	(ram_FF8024-ABS_SHORT).w
	bra.w	.l8D16
.l8CB2:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l8CDC
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addq.w	#1,d0
	cmpi.w	#$3,d0
	bne.w	.l8CD4
	clr.w	d0
.l8CD4:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l8D16
.l8CDC:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l8CFE
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	subq.w	#1,d0
	bpl.w	.l8CF6
	move.w	#$2,d0
.l8CF6:
	move.w	d0,(ram_FF8024-ABS_SHORT).w
	bra.w	.l8D16
.l8CFE:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l8D0E
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l8D30
.l8D0E:
	jsr	sub_13EC
	bra.s	.l8CB2
.l8D16:
	move.w	#$83,d1
	move.w	#$3,d2
	jsr	sub_145E
	bsr.w	sub_8D48
	jsr	sub_13EC
	bra.s	.l8CB2
.l8D30:
	clr.w	(ram_FF8056-ABS_SHORT).w
	lea	tbl_8D60,a0
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	lsl.w	#2,d0
	movea.l	($0,a0,d0.w),a0
	jsr	(a0)
	bra.s	.l8D16
sub_8D48:
	move.w	(ram_FF8024-ABS_SHORT).w,d0
	addi.w	#$84,d0
	move.w	#$FC,d2
	jsr	sub_238E
	rts
dat_8D5C:
	incbin	"../../build/stunrun-68k.bin",$8D5C,$4
tbl_8D60:
	dc.l	sub_8D6C
	dc.l	boot_sa_audio_test
	dc.l	sub_8EF2
sub_8D6C:
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	jsr	boot_load_gsp_palette
	clr.w	io_84C000
	clr.w	io_840000
	addq.l	#4,sp
	rts
boot_sa_audio_test:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$87,d0
	jsr	sub_2326
	move.w	#$92,d0
	jsr	sub_2326
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	move.w	SOUND_RESET,d0
	move.w	#$B4,d1
.l8DC2:
	jsr	sub_13EC
	subq.w	#1,d1
	bne.s	.l8DC2
	move.b	JSA_PORT,d0
	cmpi.b	#$FF,d0
	bne.w	.l8E16
	move.b	#$7,JSA_PORT
	jsr	sub_13EC
	jsr	sub_13EC
	move.w	#$2,d0
	jsr	sub_65E0
	clr.w	d0
	move.b	JSA_PORT,d0
	move.w	d0,(ram_FF8090-ABS_SHORT).w
	bsr.w	boot_show_sound_status
.l8E08:
	bsr.w	boot_play_test_sounds
	jsr	sub_8F40
	move.w	(sp)+,sr
	rts
.l8E16:
	move.w	#$2,d0
	jsr	sub_65E0
	move.w	#$90,d0
	jsr	sub_2326
	bra.s	.l8E08
boot_show_sound_status:
	movea.l	#dat_8ED0,a0
	move.w	(a0)+,(ram_FF8120-ABS_SHORT).w
	move.l	a0,(ram_FF811C-ABS_SHORT).w
	clr.w	(ram_FF8092-ABS_SHORT).w
.l8E3E:
	clr.w	WATCHDOG
	movea.l	(ram_FF811C-ABS_SHORT).w,a0
	move.w	(ram_FF8090-ABS_SHORT).w,d1
	and.w	(a0),d1
	beq.w	.l8E66
	move.w	($2,a0),d0
	move.l	a0,(ram_FF811C-ABS_SHORT).w
	jsr	sub_2326
	move.w	#$FF,(ram_FF8092-ABS_SHORT).w
.l8E66:
	addq.l	#4,(ram_FF811C-ABS_SHORT).w
	subq.w	#1,(ram_FF8120-ABS_SHORT).w
	bne.s	.l8E3E
	tst.w	(ram_FF8092-ABS_SHORT).w
	bne.w	.l8E82
	move.w	#$91,d0
	jsr	sub_2326
.l8E82:
	rts
boot_play_test_sounds:
	move.b	#$4,JSA_PORT
	move.w	#$280,d1
.l8E90:
	jsr	sub_13EC
	subq.w	#1,d1
	bne.s	.l8E90
	move.b	#$0,JSA_PORT
	move.w	#$20,d1
.l8EA6:
	jsr	sub_13EC
	subq.w	#1,d1
	bne.s	.l8EA6
	move.b	#$5,JSA_PORT
	move.w	#$80,d1
.l8EBC:
	jsr	sub_13EC
	subq.w	#1,d1
	bne.s	.l8EBC
	move.b	#$0,JSA_PORT
	rts
dat_8ED0:
	incbin	"../../build/stunrun-68k.bin",$8ED0,$22
sub_8EF2:
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	sr,-(sp)
	move.w	#$2000,sr
	lea	game_vec_reset_sp,a0
	lea	game_entries,a1
	addq.l	#6,a1
	movec	a0,vbr
	clr.w	PORT0
	jsr	(a1)
	movea.l	#$0,a0
	movec	a0,vbr
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	(sp)+,sr
	rts
sub_8F40:
	clr.w	WATCHDOG
	jsr	sub_13EC
	jsr	sub_1368
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.s	sub_8F40
	clr.w	(ram_FF8056-ABS_SHORT).w
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	rts
boot_sa_ii_test:
	move.w	#$108,d0
	jsr	sub_2326
	move.w	SOUND_RESET,d0
	move.w	#$B4,d1
.l8F7C:
	jsr	sub_13EC
	subq.w	#1,d1
	bne.s	.l8F7C
	move.b	JSA_PORT,d0
	cmpi.b	#$FF,d0
	bne.w	.l8FD4
	move.b	#$7,JSA_PORT
	jsr	sub_13EC
	jsr	sub_13EC
	move.w	#$6,d0
	jsr	sub_65E0
	clr.w	d0
	move.b	JSA_PORT,d0
	bne.w	.l8FC6
	move.w	#$105,d0
	bra.w	.l8FCA
.l8FC6:
	move.w	#$106,d0
.l8FCA:
	jsr	sub_2326
	bra.w	.l8FE8
.l8FD4:
	move.w	#$6,d0
	jsr	sub_65E0
	move.w	#$107,d0
	jsr	sub_2326
.l8FE8:
	bsr.w	boot_play_test_sounds
	rts
loc_8FEE:
	move.w	#$2F00,sr
	lea	(sub_8FFA,pc),a0
	bra.w	loc_53F2
sub_8FFA:
	lea	(sub_9002,pc),a0
	bra.w	loc_548E
sub_9002:
	lea	(sub_900A,pc),a0
	bra.w	loc_54C2
sub_900A:
	clr.w	WATCHDOG
	move.b	PORT0,d0
	beq.w	loc_9DA4
	not.b	d0
	andi.b	#$3F,d0
	cmpi.b	#$0,d0
	beq.w	.l9132
	cmpi.b	#$1,d0
	beq.w	.l9138
	cmpi.b	#$3,d0
	beq.w	loc_914A
	cmpi.b	#$7,d0
	beq.w	loc_918A
	cmpi.b	#$F,d0
	beq.w	loc_9204
	cmpi.b	#$1F,d0
	beq.w	loc_926E
	cmpi.b	#$1E,d0
	beq.w	loc_931A
	cmpi.b	#$1C,d0
	beq.w	loc_933A
	cmpi.b	#$18,d0
	beq.w	loc_935A
	cmpi.b	#$10,d0
	beq.w	loc_937A
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	clr.w	WATCHDOG
	move.b	PORT0,d0
	not.b	d0
	andi.b	#$3F,d0
	cmpi.b	#$20,d0
	beq.w	loc_9B1E
	cmpi.b	#$21,d0
	beq.w	loc_93B0
	cmpi.b	#$23,d0
	beq.w	loc_95FC
	cmpi.b	#$27,d0
	beq.w	loc_9ABA
	cmpi.b	#$2F,d0
	beq.w	loc_9ADA
	cmpi.b	#$3F,d0
	beq.w	loc_9AFA
	cmpi.b	#$3E,d0
	beq.w	loc_9B1A
	cmpi.b	#$3C,d0
	beq.w	loc_9BA6
	cmpi.b	#$38,d0
	beq.w	loc_9BBE
	cmpi.b	#$30,d0
	beq.w	loc_9D56
	cmpi.b	#$C,d0
	beq.w	loc_A0F6
	cmpi.b	#$2A,d0
	beq.w	loc_9DD6
	cmpi.b	#$15,d0
	beq.w	loc_9DFA
	cmpi.b	#$2B,d0
	beq.w	loc_9E10
	cmpi.b	#$2,d0
	beq.w	loc_9F0E
	cmpi.b	#$6,d0
	beq.w	loc_9F88
	cmpi.b	#$E,d0
	beq.w	loc_A002
	cmpi.b	#$A,d0
	beq.w	loc_A07C
	bra.w	loc_9D92
.l9132:
	jmp	.l9132
.l9138:
	clr.w	WATCHDOG
	clr.w	PORT0
	jmp	.l9138
loc_914A:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$2
	lea	(sub_915E,pc),a0
	bra.w	loc_9178
sub_915E:
	clr.w	SOUND_RESET+$12
	clr.w	SOUND_RESET
	lea	(sub_9172,pc),a0
	bra.w	loc_9178
sub_9172:
	jmp	loc_914A
loc_9178:
	move.l	#$10000,d0
.l917E:
	clr.w	WATCHDOG
	subq.l	#1,d0
	bne.s	.l917E
	jmp	(a0)
loc_918A:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$12
	lea	(sub_919E,pc),a0
	bra.w	loc_9178
sub_919E:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	movea.l	#$0,a0
	lea	(sub_91B8,pc),a2
	bra.w	loc_95A2
sub_91B8:
	move.b	d0,d6
	movea.l	#$0,a0
	lea	(sub_91C8,pc),a2
	bra.w	loc_95CC
sub_91C8:
	move.b	d0,d5
loc_91CA:
	cmpi.b	#$1,d6
	bne.w	.l91D8
	clr.w	SOUND_RESET+$10
.l91D8:
	cmpi.b	#$2,d5
	bne.w	.l91E6
	clr.w	SOUND_RESET+$12
.l91E6:
	lea	(sub_91EE,pc),a0
	bra.w	loc_9178
sub_91EE:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	lea	(sub_9202,pc),a0
	bra.w	loc_9178
sub_9202:
	bra.s	loc_91CA
loc_9204:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$12
	lea	(sub_9218,pc),a0
	bra.w	loc_9178
sub_9218:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	lea	$FFFF8000,a1
	lea	(ram_FFBFFE-ABS_SHORT).w,a2
	lea	(sub_9236,pc),a4
	bra.w	loc_5B6E
sub_9236:
	move.w	d4,d5
loc_9238:
	tst.b	d4
	bne.w	.l9244
	clr.w	SOUND_RESET+$10
.l9244:
	tst.b	d5
	bne.w	.l9250
	clr.w	SOUND_RESET+$12
.l9250:
	lea	(sub_9258,pc),a0
	bra.w	loc_9178
sub_9258:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	lea	(sub_926C,pc),a0
	bra.w	loc_9178
sub_926C:
	bra.s	loc_9238
loc_926E:
	clr.w	SOUND_RESET+$C
	lea	(sub_927C,pc),a0
	bra.w	loc_9178
sub_927C:
	clr.w	SOUND_RESET+$1C
	ori.w	#$2000,GSP_HOST+$8
	move.l	#$C0000160,GSP_HOST+$2
	move.w	#$5555,GSP_HOST+$C
	move.l	#$C0000150,GSP_HOST+$2
	move.w	#$AAAA,GSP_HOST+$C
	move.l	#$C0000160,GSP_HOST+$2
	move.w	GSP_HOST+$C,d0
	cmpi.w	#$5555,d0
	beq.w	loc_92F0
loc_92C6:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$2
	lea	(sub_92DA,pc),a0
	bra.w	loc_9178
sub_92DA:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$12
	lea	(sub_92EE,pc),a0
	bra.w	loc_9178
sub_92EE:
	bra.s	loc_92C6
loc_92F0:
	clr.w	SOUND_RESET
	clr.w	SOUND_RESET+$2
	lea	(sub_9304,pc),a0
	bra.w	loc_9178
sub_9304:
	clr.w	SOUND_RESET+$10
	clr.w	SOUND_RESET+$12
	lea	(sub_9318,pc),a0
	bra.w	loc_9178
sub_9318:
	bra.s	loc_92F0
loc_931A:
	move.w	#$FF,(ram_FF8018-ABS_SHORT).w
	move.w	#$0,(ram_FF801A-ABS_SHORT).w
	move.w	#$0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
.l9332:
	clr.w	WATCHDOG
	bra.s	.l9332
loc_933A:
	move.w	#$0,(ram_FF8018-ABS_SHORT).w
	move.w	#$FF,(ram_FF801A-ABS_SHORT).w
	move.w	#$0,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
.l9352:
	clr.w	WATCHDOG
	bra.s	.l9352
loc_935A:
	move.w	#$0,(ram_FF8018-ABS_SHORT).w
	move.w	#$0,(ram_FF801A-ABS_SHORT).w
	move.w	#$FF,(ram_FF801C-ABS_SHORT).w
	jsr	sub_6EE
.l9372:
	clr.w	WATCHDOG
	bra.s	.l9372
loc_937A:
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF800000,GSP_HOST+$2
	move.w	#$FFFF,d0
loc_9390:
	lea	(sub_9398,pc),a0
	bra.w	loc_93A6
sub_9398:
	clr.w	WATCHDOG
	move.w	d0,GSP_HOST+$C
	bra.s	loc_9390
loc_93A6:
	move.w	#$3E8,d1
.l93AA:
	subq.w	#1,d1
	bne.s	.l93AA
	jmp	(a0)
loc_93B0:
	move.l	#$0,(ram_FF8098-ABS_SHORT).w
	move.w	#$0,(ram_FF809C-ABS_SHORT).w
	move.w	#$0,(ram_FF809E-ABS_SHORT).w
	clr.w	(ram_FF80C8-ABS_SHORT).w
	move.w	#$68,d0
	jsr	sub_2326
	move.w	#$69,d0
	jsr	sub_2326
	move.w	#$6A,d0
	jsr	sub_2326
	move.w	#$6B,d0
	jsr	sub_2326
.l93F0:
	move.w	#$4,d0
	move.w	#$14,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$4,d0
	move.w	#$10,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$6,d0
	move.w	#$14,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$6,d0
	move.w	#$1A,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$7,d0
	move.w	#$14,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$7,d0
	move.w	#$1A,d1
	jsr	sub_2418
	jsr	sub_24B8
	move.w	#$9F,d2
	jsr	sub_23F2
	move.w	#$4,d0
	move.w	#$10,d1
	jsr	sub_2418
	move.w	(ram_FF8098-ABS_SHORT).w,d1
	jsr	sub_2496
	move.w	#$4,d0
	move.w	#$14,d1
	jsr	sub_2418
	move.w	(ram_FF809A-ABS_SHORT).w,d1
	jsr	sub_2496
	move.w	#$6,d0
	move.w	#$14,d1
	jsr	sub_2418
	move.w	(ram_FF809C-ABS_SHORT).w,d1
	jsr	sub_2496
	move.w	#$7,d0
	move.w	#$14,d1
	jsr	sub_2418
	move.w	(ram_FF809E-ABS_SHORT).w,d1
	jsr	sub_2496
	move.w	#$3F,d2
	jsr	sub_23F2
	move.w	#$6,d0
	move.w	#$1A,d1
	jsr	sub_2418
	move.b	(ram_FF80C9-ABS_SHORT).w,d1
	jsr	sub_245A
	move.w	#$7,d0
	move.w	#$1A,d1
	jsr	sub_2418
	move.b	(ram_FF80C8-ABS_SHORT).w,d1
	jsr	sub_245A
	bsr.w	sub_953A
	bsr.w	sub_956E
	jsr	sub_13EC
	andi	#$EF,ccr
	move.l	#$1,(ram_FF8090-ABS_SHORT).w
	lea	(ram_FF8094-ABS_SHORT).w,a2
	lea	(ram_FF809C-ABS_SHORT).w,a3
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	bra.w	.l93F0
sub_953A:
	lea	sub_954A,a2
	movea.l	#$0,a0
	bra.w	loc_95A2
sub_954A:
	move.b	d0,(ram_FF80C9-ABS_SHORT).w
	cmpi.b	#$1,d0
	beq.w	.l956C
	andi	#$EF,ccr
	move.w	#$1,(ram_FF8090-ABS_SHORT).w
	lea	(ram_FF8092-ABS_SHORT).w,a2
	lea	(ram_FF809E-ABS_SHORT).w,a3
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
.l956C:
	rts
sub_956E:
	lea	sub_957E,a2
	movea.l	#$0,a0
	bra.w	loc_95CC
sub_957E:
	move.b	d0,(ram_FF80C8-ABS_SHORT).w
	cmpi.b	#$2,d0
	beq.w	.l95A0
	andi	#$EF,ccr
	move.w	#$1,(ram_FF8090-ABS_SHORT).w
	lea	(ram_FF8092-ABS_SHORT).w,a2
	lea	(ram_FF80A0-ABS_SHORT).w,a3
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
.l95A0:
	rts
loc_95A2:
	clr.w	WATCHDOG
	clr.w	d0
	move.w	#$7FFF,d1
.l95AE:
	add.w	(a0)+,d0
	dbf	d1,.l95AE
	clr.w	WATCHDOG
	move.w	#$7FFF,d1
.l95BE:
	add.w	(a0)+,d0
	dbf	d1,.l95BE
	clr.w	WATCHDOG
	jmp	(a2)
loc_95CC:
	clr.w	WATCHDOG
	clr.w	d0
	move.w	#$7FFF,d1
.l95D8:
	add.w	(a0)+,d0
	clr.b	d0
	dbf	d1,.l95D8
	clr.w	WATCHDOG
	move.w	#$7FFF,d1
.l95EA:
	add.w	(a0)+,d0
	clr.b	d0
	dbf	d1,.l95EA
	lsr.w	#8,d0
	clr.w	WATCHDOG
	jmp	(a2)
loc_95FC:
	move.w	sr,-(sp)
	move.w	#$2F00,sr
	clr.w	SOUND_RESET+$8
	clr.w	SOUND_RESET+$1A
	lea	$FFFF4064,sp
	move.l	#$0,$FFFF4000
	clr.w	$FFFF4004
	clr.w	$FFFF4006
	clr.w	$FFFF4008
	clr.w	$FFFF400A
	clr.w	$FFFF400C
	move.w	#$6C,d0
	jsr	sub_2326
	move.w	#$6D,d0
	jsr	sub_2326
	move.w	#$6E,d0
	jsr	sub_2326
	move.w	#$6F,d0
	jsr	sub_2326
	move.w	#$70,d0
	jsr	sub_2326
	move.w	#$71,d0
	jsr	sub_2326
	move.w	#$72,d0
	jsr	sub_2326
loc_9682:
	clr.w	$FFFF400E
.l9688:
	lea	dat_9806,a0
	move.w	$FFFF400E,d2
	lsl.w	#3,d2
	move.w	($0,a0,d2.w),d0
	move.w	($2,a0,d2.w),d1
	jsr	sub_2418
	jsr	sub_24B8
	addq.w	#1,$FFFF400E
	cmpi.w	#$7,$FFFF400E
	bne.s	.l9688
	move.w	#$9F,d2
	jsr	sub_23F2
	clr.w	$FFFF400E
.l96CA:
	lea	dat_9806,a0
	move.w	$FFFF400E,d2
	lsl.w	#3,d2
	move.w	($0,a0,d2.w),d0
	move.w	($2,a0,d2.w),d1
	movea.l	($4,a0,d2.w),a1
	jsr	sub_2418
	move.w	(a1),d1
	jsr	sub_2496
	addq.w	#1,$FFFF400E
	cmpi.w	#$7,$FFFF400E
	bne.s	.l96CA
	lea	$FFFF8000,a1
	lea	(ram_FFFFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF819800,GSP_HOST+$2
	lea	(sub_9726,pc),a4
	bra.w	loc_5896
sub_9726:
	tst.w	d4
	beq.w	loc_97DA
	lea	$FFFF400E,a3
	jsr	sub_983E
	lea	$FFFF8000,a1
	lea	(ram_FFBFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF81D800,GSP_HOST+$2
	lea	(sub_975C,pc),a4
	bra.w	loc_5896
sub_975C:
	tst.w	d4
	beq.w	.l978A
	eor.w	d0,d1
	tst.b	d1
	beq.w	.l9776
	lea	$FFFF4006,a3
	jsr	sub_983E
.l9776:
	andi.w	#$FF00,d1
	beq.w	.l978A
	lea	$FFFF4008,a3
	jsr	sub_983E
.l978A:
	lea	(ram_FFC000-ABS_SHORT).w,a1
	lea	(ram_FFFFFE-ABS_SHORT).w,a2
	ori.w	#$1800,GSP_HOST+$8
	move.l	#$FF821800,GSP_HOST+$2
	lea	(sub_97AC,pc),a4
	bra.w	loc_5896
sub_97AC:
	tst.w	d4
	beq.w	loc_97DA
	eor.w	d0,d1
	tst.b	d1
	beq.w	.l97C6
	lea	$FFFF400A,a3
	jsr	sub_983E
.l97C6:
	andi.w	#$FF00,d1
	beq.w	loc_97DA
	lea	$FFFF400C,a3
	jsr	sub_983E
loc_97DA:
	jsr	sub_13EC
	andi	#$EF,ccr
	move.l	#$1,$FFFF400E
	lea	$FFFF4012,a2
	lea	$FFFF4004,a3
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	bra.w	loc_9682
dat_9806:
	incbin	"../../build/stunrun-68k.bin",$9806,$38
sub_983E:
	andi	#$EF,ccr
	move.w	#$1,$FFFF4012
	lea	$FFFF4014,a2
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	rts
sub_9856:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.l985E:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	jsr	sub_2418
	jsr	sub_24B8
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addq.l	#8,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l988A
	bra.s	.l985E
.l988A:
	rts
sub_988C:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.l9894:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	jsr	sub_2418
	jsr	sub_24B8
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$A,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l98C4
	bra.s	.l9894
.l98C4:
	rts
sub_98C6:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.l98CE:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	jsr	sub_2418
	jsr	sub_2712
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$A,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l98FE
	bra.s	.l98CE
.l98FE:
	rts
dat_9900:
	incbin	"../../build/stunrun-68k.bin",$9900,$3A
sub_993A:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
	move.w	#$9F,d2
	jsr	sub_23F2
.l994C:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	movea.l	($4,a0),a1
	jsr	sub_2418
	move.w	(a1),d1
	jsr	sub_2496
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addq.l	#8,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l997E
	bra.s	.l994C
.l997E:
	rts
sub_9980:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.l9988:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($4,a0),d2
	jsr	sub_23F2
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	movea.l	($6,a0),a1
	jsr	sub_2418
	move.w	(a1),d1
	jsr	sub_2496
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$A,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l99C8
	bra.s	.l9988
.l99C8:
	rts
dat_99CA:
	incbin	"../../build/stunrun-68k.bin",$99CA,$4A
sub_9A14:
	move.l	(a0)+,(ram_FF80E4-ABS_SHORT).w
	move.l	a0,(ram_FF80DC-ABS_SHORT).w
.l9A1C:
	movea.l	(ram_FF80DC-ABS_SHORT).w,a0
	move.w	($4,a0),d2
	jsr	sub_23F2
	move.w	($0,a0),d0
	move.w	($2,a0),d1
	movea.l	($6,a0),a1
	jsr	sub_2418
	move.b	(a1),d1
	jsr	sub_245A
	move.l	(ram_FF80DC-ABS_SHORT).w,d0
	addi.l	#$A,d0
	move.l	d0,(ram_FF80DC-ABS_SHORT).w
	cmp.l	(ram_FF80E4-ABS_SHORT).w,d0
	beq.w	.l9A5C
	bra.s	.l9A1C
.l9A5C:
	rts
sub_9A5E:
	andi	#$EF,ccr
	lea	(ram_FF8094-ABS_SHORT).w,a2
	move.w	#$1,(a2)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	rts
sub_9A70:
	andi	#$EF,ccr
	move.l	#$1,(ram_FF8090-ABS_SHORT).w
	lea	(ram_FF8094-ABS_SHORT).w,a2
	lea	(ram_FF80DC-ABS_SHORT).w,a3
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	abcd.b	-(a2),-(a3)
	rts
dat_9A8E:
	incbin	"../../build/stunrun-68k.bin",$9A8E,$2C
loc_9ABA:
	bra.w	loc_9DD6
dat_9ABE:
	incbin	"../../build/stunrun-68k.bin",$9ABE,$1C
loc_9ADA:
	bra.w	loc_9DD6
dat_9ADE:
	incbin	"../../build/stunrun-68k.bin",$9ADE,$1C
loc_9AFA:
	bra.w	loc_9DD6
dat_9AFE:
	incbin	"../../build/stunrun-68k.bin",$9AFE,$1C
loc_9B1A:
	bra.w	loc_9DD6
loc_9B1E:
	clr.w	(ram_FF80E2-ABS_SHORT).w
	clr.l	(ram_FF80D8-ABS_SHORT).w
	move.w	#$2000,sr
.l9B2A:
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	move.w	#$0,d0
	jsr	boot_fill_gsp_vram
	move.w	#$7C,d0
	jsr	sub_2326
	move.w	#$74,d0
	jsr	sub_2326
	move.w	#$7D,d0
	jsr	sub_2326
	lea	dat_9AFE,a0
	bsr.w	sub_993A
	bsr.w	sub_9A70
	move.w	#$12B,d0
.l9B76:
	jsr	sub_13EC
	dbf	d0,.l9B76
	jsr	sub_4F82
	move.w	#$F,d0
	lea	ram_FF945E,a0
.l9B90:
	tst.w	(a0)+
	dbne	d0,.l9B90
	cmpi.w	#$FFFF,d0
	beq.s	.l9B2A
	lea	(ram_FF80E4-ABS_SHORT).w,a3
	bsr.w	sub_9A5E
	bra.s	.l9B2A
loc_9BA6:
	move.w	#$7E,d0
	jsr	sub_2326
.l9BB0:
	move.w	$FFFF0000,d0
	clr.w	WATCHDOG
	bra.s	.l9BB0
loc_9BBE:
	movea.l	#$FFFFC000,sp
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	clr.w	(ram_FF8120-ABS_SHORT).w
	jsr	sub_48E
	move.w	#$FFFF,(ram_FF8056-ABS_SHORT).w
	jsr	sub_C64
	move.w	#$FFFF,(ram_FF8090-ABS_SHORT).w
	move.w	#$2400,sr
loc_9BF6:
	clr.w	(ram_FF8120-ABS_SHORT).w
.l9BFA:
	jsr	sub_1368
	tst.w	(ram_FF8036-ABS_SHORT).w
	beq.w	.l9C16
	clr.w	(ram_FF8036-ABS_SHORT).w
	move.w	(ram_FF8120-ABS_SHORT).w,d0
	addq.w	#1,d0
	bra.w	.l9C44
.l9C16:
	tst.w	(ram_FF8046-ABS_SHORT).w
	beq.w	.l9C2C
	clr.w	(ram_FF8046-ABS_SHORT).w
	move.w	(ram_FF8120-ABS_SHORT).w,d0
	subq.w	#1,d0
	bra.w	.l9C44
.l9C2C:
	tst.w	(ram_FF8056-ABS_SHORT).w
	beq.w	.l9C3C
	clr.w	(ram_FF8056-ABS_SHORT).w
	bra.w	.l9C44
.l9C3C:
	jsr	sub_13EC
	bra.s	.l9BFA
.l9C44:
	andi.w	#$F,d0
	move.w	d0,(ram_FF8120-ABS_SHORT).w
	jsr	sub_13EC
	bsr.w	sub_9C76
	ori.w	#$1800,GSP_HOST+$8
	move.w	#$3A,d0
	jsr	sub_2326
	lea	dat_45C6,a0
	jsr	sub_452A
	bra.s	.l9BFA
sub_9C76:
	clr.w	WATCHDOG
	lea	ram_FF945E,a0
	move.w	#$7,d0
.l9C86:
	clr.l	(a0)+
	dbf	d0,.l9C86
	lea	ram_FF945E,a0
	move.w	(ram_FF8120-ABS_SHORT).w,d0
	move.b	#$FF,($0,a0,d0.w)
	clr.w	WATCHDOG
	jsr	sub_C64
	clr.l	d0
	move.w	(ram_FF8120-ABS_SHORT).w,d0
	move.w	d0,d1
	andi.w	#$3,d1
	cmpi.b	#$0,d1
	bne.w	.l9CC4
	move.w	#$F,d2
	bra.w	.l9CE8
.l9CC4:
	cmpi.b	#$1,d1
	bne.w	.l9CD4
	move.w	#$F0,d2
	bra.w	.l9CE8
.l9CD4:
	cmpi.b	#$2,d1
	bne.w	.l9CE4
	move.w	#$F00,d2
	bra.w	.l9CE8
.l9CE4:
	move.w	#$F000,d2
.l9CE8:
	andi.w	#$1C,d0
	lsl.w	#2,d0
	addi.l	#$FF8A0000,d0
	move.w	#$5FF,d6
	move.w	#$40,d7
	tst.w	(ram_FF8090-ABS_SHORT).w
	beq.w	.l9D2C
.l9D04:
	clr.w	WATCHDOG
	move.l	d0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d5
	or.w	d2,d5
	move.l	d0,GSP_HOST+$2
	move.w	d5,GSP_HOST+$C
	add.l	d7,d0
	dbf	d6,.l9D04
	rts
.l9D2C:
	not.w	d2
.l9D2E:
	clr.w	WATCHDOG
	move.l	d0,GSP_HOST+$2
	move.w	GSP_HOST+$C,d5
	and.w	d2,d5
	move.l	d0,GSP_HOST+$2
	move.w	d5,GSP_HOST+$C
	add.l	d7,d0
	dbf	d6,.l9D2E
	rts
loc_9D56:
	movea.l	#$FFFFC000,sp
	jsr	boot_init_gsp
	jsr	boot_load_gsp_palette
	clr.w	WATCHDOG
	clr.w	(ram_FF8120-ABS_SHORT).w
	jsr	sub_48E
	move.w	#$FFFF,(ram_FF8056-ABS_SHORT).w
	jsr	sub_C64
	move.w	#$0,(ram_FF8090-ABS_SHORT).w
	move.w	#$2400,sr
	bra.w	loc_9BF6
loc_9D92:
	move.w	#$7F,d0
	jsr	sub_2326
.l9D9C:
	clr.w	WATCHDOG
	bra.s	.l9D9C
loc_9DA4:
	move.w	#$80,d0
	lea	(sub_9DB2,pc),a2
	jmp	loc_25E8
sub_9DB2:
	move.w	#$81,d0
	lea	(sub_9DC0,pc),a2
	jmp	loc_25E8
sub_9DC0:
	move.w	#$82,d0
	lea	(sub_9DCE,pc),a2
	jmp	loc_25E8
sub_9DCE:
	clr.w	WATCHDOG
	bra.s	sub_9DCE
loc_9DD6:
	move.w	#$B,d0
	lea	(sub_9DE4,pc),a2
	jmp	loc_25E8
sub_9DE4:
	move.w	#$C,d0
	lea	(sub_9DF2,pc),a2
	jmp	loc_25E8
sub_9DF2:
	clr.w	WATCHDOG
	bra.s	sub_9DF2
loc_9DFA:
	move.w	#$E,d0
	lea	(sub_9E08,pc),a2
	jmp	loc_25E8
sub_9E08:
	clr.w	WATCHDOG
	bra.s	sub_9E08
loc_9E10:
	clr.w	WATCHDOG
	bsr.w	sub_9E26
	bsr.w	sub_9E80
.l9E1E:
	clr.w	WATCHDOG
	bra.s	.l9E1E
sub_9E26:
	clr.w	WATCHDOG
	move.b	$FFFF4FFF,d0
	lsl.w	#8,d0
	move.b	$FFFF4FF9,d0
	move.w	d0,(ram_FF8092-ABS_SHORT).w
	move.b	$FFFF4FFB,d0
	lsl.w	#8,d0
	move.b	$FFFF4FFD,d0
	move.w	d0,(ram_FF8094-ABS_SHORT).w
	clr.w	WATCHDOG
	lea	dat_9E6C,a0
	bsr.w	sub_9856
	lea	dat_9E6C,a0
	bsr.w	sub_993A
	rts
dat_9E6C:
	incbin	"../../build/stunrun-68k.bin",$9E6C,$14
	assert	*=$009E80,"boot/code_0065E0.asm does not end at 009E80"
