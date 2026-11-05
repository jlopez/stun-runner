; ram.asm: the 6502's RAM, 0000-1FFF, as equates (no bytes).
;
; Named where the code shows the role (docs/09-sound-program.md section 5); every other address
; the code uses is zp_XX (zero page) or ram_XXXX, for later legs to rename. An address is
; listed at the base the code indexes from: most of 0248-085F are arrays of 30 bytes, 1E apart
; and indexed by X up to 1D (imm_00 clears five of them at 4253-4265), for later legs to name
; together.

; zero page
zp_00 = $00
zp_01 = $01
zp_02 = $02
zp_03 = $03
; 2 bytes: where h_nmi stores a byte while nmi_mode is 0 (57FA-5805); imm_04 points it at
; zp_63 (5CC5-5CCE)
nmi_data_ptr = $04
zp_06 = $06
zp_07 = $07
zp_08 = $08
zp_09 = $09
zp_0C = $0C
zp_0D = $0D
zp_0E = $0E
zp_0F = $0F
zp_10 = $10
zp_11 = $11
zp_12 = $12
zp_13 = $13
zp_14 = $14
zp_15 = $15
zp_16 = $16
zp_17 = $17
zp_19 = $19
zp_1A = $1A
zp_1B = $1B
zp_1C = $1C
zp_1D = $1D
zp_1E = $1E
zp_1F = $1F
zp_20 = $20
zp_21 = $21
zp_22 = $22
zp_23 = $23
zp_43 = $43
; the value last written to MIX (written at 42CB and 4729)
mix_shadow = $44
; the value last written to WRIO (written at 4092, 409B, 411C, 5901, 5BB5, 5DA7); bits 7-6
; select the page at 3000, which only the self-test and the dormant ymtimer path (5901) change
wrio_shadow = $45
; the value last written to YM2151 register 1B (written at 4123, 4396, 43A5, 5674)
ym_1b_shadow = $46
zp_47 = $47
zp_48 = $48
zp_49 = $49
zp_4A = $4A
zp_4B = $4B
zp_4C = $4C
zp_4D = $4D
zp_4E = $4E
zp_4F = $4F
zp_50 = $50
zp_51 = $51
zp_52 = $52
zp_56 = $56
zp_5A = $5A
zp_5E = $5E
zp_62 = $62
zp_63 = $63
zp_67 = $67
zp_68 = $68
zp_69 = $69
zp_6A = $6A
zp_6F = $6F
zp_73 = $73
zp_75 = $75

; the stack page (h_irq reads the pushed status at stack+3,x after TSX, 41F9)
stack = $0100

; RAM
; 48 bytes: the commands h_nmi queues (5834-5846) and main_loop runs (4171-4186)
cmd_queue = $0200
; the entry main_loop took last (4171-4180)
cmd_queue_out = $0230
; the entry h_nmi filled last (5815-581F)
cmd_queue_in = $0231
; 2 bytes: the bytes h_nmi stored while nmi_mode is 0 (57F2-57F7)
nmi_data_count = $0232
; FF: h_nmi queues commands; 0: it stores the byte at nmi_data_ptr; else it drops it
nmi_mode = $0234
; 16 bytes: the responses queue_response queues (44D0) and main_loop sends (4159-416E)
resp_queue = $0235
; the next entry main_loop sends
resp_queue_out = $0245
; the next free entry
resp_queue_in = $0246
; 80 when queue_response found resp_queue full (44E6)
resp_queue_full = $0247
ram_0248 = $0248
ram_0266 = $0266
ram_0284 = $0284
ram_02A2 = $02A2
ram_02C0 = $02C0
ram_02DE = $02DE
ram_02FC = $02FC
ram_031A = $031A
ram_0338 = $0338
ram_0356 = $0356
ram_0374 = $0374
ram_0392 = $0392
ram_03EC = $03EC
ram_040A = $040A
ram_0428 = $0428
ram_0446 = $0446
ram_0464 = $0464
ram_0482 = $0482
ram_04A0 = $04A0
ram_04BE = $04BE
ram_04DC = $04DC
ram_04FA = $04FA
ram_0518 = $0518
ram_0536 = $0536
ram_0554 = $0554
ram_0572 = $0572
ram_0590 = $0590
ram_05AE = $05AE
ram_05CC = $05CC
ram_05EA = $05EA
ram_0608 = $0608
ram_0626 = $0626
ram_0644 = $0644
ram_0662 = $0662
ram_0680 = $0680
ram_069E = $069E
ram_06BC = $06BC
ram_06DA = $06DA
ram_06F8 = $06F8
ram_0716 = $0716
ram_0734 = $0734
ram_0752 = $0752
ram_0770 = $0770
ram_078E = $078E
ram_07AC = $07AC
ram_07CA = $07CA
ram_07E8 = $07E8
ram_0806 = $0806
ram_0824 = $0824
ram_0842 = $0842
ram_0860 = $0860
ram_0884 = $0884
ram_0885 = $0885
ram_088C = $088C
ram_088D = $088D
ram_088E = $088E
ram_088F = $088F
ram_0893 = $0893
ram_0895 = $0895
ram_0896 = $0896
ram_0897 = $0897
ram_0898 = $0898
ram_0899 = $0899
ram_089A = $089A
ram_089E = $089E
ram_08A2 = $08A2
ram_08A3 = $08A3
ram_08A4 = $08A4
ram_08AB = $08AB
ram_08AC = $08AC
ram_08AD = $08AD
ram_08AE = $08AE
