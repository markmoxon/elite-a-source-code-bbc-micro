INCLUDE "sources/elite-header.h.asm"

_DISC_DOCKED            = FALSE
_DISC_FLIGHT            = FALSE
_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

 \ a.tcode - ELITE III docked code

\OPT TABS=16

key_table = &04
ptr = &07
font = &1C
cursor_x = &2C
cursor_y = &2D
vdu_stat = &72
brk_line = &FD
last_key = &300
ship_type = &311
cabin_t = &342
target = &344
view_dirn = &345
laser_t = &347
adval_x = &34C
adval_y = &34D
cmdr_mission = &358
cmdr_homex = &359
cmdr_homey = &35A
cmdr_gseed = &35B
cmdr_money = &361
cmdr_fuel = &365
cmdr_galxy = &367
cmdr_laser = &368
cmdr_ship = &36D
cmdr_hold = &36E
cmdr_cargo = &36F
cmdr_ecm = &380
cmdr_scoop = &381
cmdr_bomb = &382
cmdr_eunit = &383
cmdr_dock = &384
cmdr_ghype = &385
cmdr_escape = &386
cmdr_cour = &387
cmdr_courx = &389
cmdr_coury = &38A
cmdr_misl = &38B
cmdr_legal = &38C
cmdr_avail = &38D
cmdr_price = &39E
cmdr_kills = &39F
f_shield = &3A5
r_shield = &3A6
energy = &3A7
home_econ = &3AC
home_govmt = &3AE
home_tech = &3AF
data_econ = &3B8
data_govm = &3B9
data_tech = &3BA
data_popn = &3BB
data_gnp = &3BD
hype_dist = &3BF
data_homex = &3C1
data_homey = &3C2
s_flag = &3C6
cap_flag = &3C7
a_flag = &3C8
x_flag = &3C9
f_flag = &3CA
y_flag = &3CB
j_flag = &3CC
k_flag = &3CD
b_flag = &3CE
 \
save_lock = &233
new_file = &234
new_posn = &235
new_type = &36D
new_pulse = &3D0
new_beam = &3D1
new_military = &3D2
new_mining = &3D3
new_mounts = &3D4
new_missiles = &3D5
new_shields = &3D6
new_energy = &3D7
new_speed = &3D8
new_hold = &3D9
new_range = &3DA
new_costs = &3DB
new_max = &3DC
new_min = &3DD
new_space = &3DE
 \new_:	EQU &3DF
new_name = &74D
 \
iff_index = &D7A
altitude = &FD1
irq1 = &114B
commander = &1189
brkdst = &11D5
ship_data = &55FE
l_563d = &563D
osfile = &FFDD
oswrch = &FFEE
osword = &FFF1
osbyte = &FFF4
oscli = &FFF7

CODE% = &11E3
ORG CODE%
LOAD% = &11E3
EXEC% = &11E3

.dcode_in

 JMP dcode_2

.boot_in

 JMP boot_2

.wrch_in

 JMP wrchdst
 EQUW &114B

.brk_in

 JMP brk_go

\ a.tcode_1

.icode_in

 JSR set_brk
 JMP icode_set
 EQUB 0
 \ dead entry
 LDA #0
 JSR decode
 JSR clr_common
 JMP stack_init

.boot_2

 LDA #0
 JSR decode
 JMP boot_go

.dcode_2

 LDA last_key+1
 BNE icode_in
 LDA #&FF
 JSR decode
 JSR clr_common
 JSR pattern
 JSR picture
 LDY #&2C
 JSR y_sync
 JSR cour_dock
 LDA cmdr_mission
 AND #&03
 BNE l_1241
 LDA cmdr_kills+&01
 BEQ jmp_start
 LDA cmdr_galxy
 LSR A
 BNE jmp_start
 JMP mission_1

.l_1241

 CMP #&03
 BNE l_1248
 JMP reward_1

.l_1248

 LDA cmdr_mission
 AND #&0F
 CMP #&02
 BNE l_1262
 LDA cmdr_kills+&01
 CMP #&05
 BCC jmp_start
 LDA cmdr_galxy
 CMP #&02
 BNE jmp_start
 JMP mission_2

.l_1262

 CMP #&06
 BNE l_127e
 LDA cmdr_galxy
 CMP #&02
 BNE jmp_start
 LDA cmdr_homex
 CMP #&D7
 BNE jmp_start
 LDA cmdr_homey
 CMP #&54
 BNE jmp_start
 JMP constrictor

.l_127e

 CMP #&0A
 BNE jmp_start
 LDA cmdr_galxy
 CMP #&02
 BNE jmp_start
 LDA cmdr_homex
 CMP #&3F
 BNE jmp_start
 LDA cmdr_homey
 CMP #&48
 BNE jmp_start
 JMP reward_2

.icode_set

 JSR clr_common

.jmp_start

 JMP start_loop

.decode

 STA save_lock

.set_brk

 LDA #LO(brk_go)
 STA brk_in+&01
 LDA #HI(brk_go)
 STA brk_in+&02
 RTS

.write_msg2

 PHA
 TAX
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 LDA #LO(msg_2)
 STA &22
 LDA #HI(msg_2)
 BNE l_12de

.l_12b1

 LDA #&D9

.bit2

 EQUB &2C

.l_12b4

 LDA #&DC
 CLC
 ADC cmdr_galxy

.write_msg1

 PHA
 TAX
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 LDA #LO(msg_1)
 STA &22
 LDA #HI(msg_1)

.l_12de

 STA &23
 LDY #&00

.l_12e2

 LDA (&22),Y
 BNE l_12eb
 DEX
 BEQ msg_loop

.l_12eb

 INY
 BNE l_12e2
 INC &23
 BNE l_12e2

.msg_loop

 INY
 BNE l_12f7
 INC &23

.l_12f7

 LDA (&22),Y
 BEQ msg_quit
 JSR xpand_msg
 JMP msg_loop

.msg_quit

 PLA
 STA &23
 PLA
 STA &22
 PLA
 TAY
 PLA
 RTS

.xpand_msg

 CMP #&20
 BCC msg_macro
 BIT token_switch
 BPL msg_ntoken
 TAX
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 TXA
 JSR de_token
 JMP msg_retn

.msg_ntoken

 CMP #&5B
 BCC msg_alpha
 CMP #&81
 BCC msg_nmacro
 CMP #&D7
 BCC write_msg1
 SBC #&D7
 ASL A
 PHA
 TAX
 LDA pair_list,X
 JSR msg_alpha
 PLA
 TAX
 LDA pair_list+&01,X

.msg_alpha

 CMP #&41
 BCC l_1356
 BIT lower_switch
 BMI l_1350
 BIT upper_switch
 BMI l_1353

.l_1350

 ORA or_mask

.l_1353

 AND and_mask

.l_1356

 JMP punctuate

.msg_macro

 TAX
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 TXA
 ASL A
 TAX
 LDA macro_addr-2,X
 STA l_1373+&01
 LDA macro_addr-1,X
 STA l_1373+&02
 TXA
 LSR A

.l_1373

 JSR punctuate

.msg_retn

 PLA
 STA &23
 PLA
 STA &22
 PLA
 TAY
 RTS

.msg_nmacro

 STA ptr
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 JSR rnd_seq
 TAX
 LDA #&00
 CPX #&33
 ADC #&00
 CPX #&66
 ADC #&00
 CPX #&99
 ADC #&00
 CPX #&CC
 LDX ptr
 ADC l_55c0-&5B,X
 JSR write_msg1
 JMP msg_retn

.clr_deflowr

 LDA #&00

.bit3

 EQUB &2C

.set_deflowr

 LDA #&20
 STA or_mask
 LDA #&00
 STA lower_switch
 RTS

.column_6

 LDA #&06
 STA cursor_x
 LDA #&FF
 STA upper_switch
 RTS

.msg_cls

 LDA #&01
 STA cursor_x
 JMP clr_scrn

.set_forclwr

 LDA #&80
 STA lower_switch
 LDA #&20
 STA or_mask
 RTS

.set_vdustat

 LDA #&80
 STA vdu_stat

.set_token

 LDA #&FF

.bit4

 EQUB &2C

.clr_token

 LDA #&00
 STA token_switch
 RTS

.format_on

 LDA #&80

.bit5

 EQUB &2C

.format_off

 LDA #&00
 STA format_switch
 ASL A
 STA format_posn
 RTS

.l_13ec

 LDA vdu_stat
 AND #&BF
 STA vdu_stat
 LDA #&03
 JSR de_token
 LDX format_posn
 LDA &0E00,X
 JSR vowel
 BCC l_1405
 DEC format_posn

.l_1405

 LDA #&99
 JMP write_msg1

.name_gen

 JSR set_upprmsk
 JSR rnd_seq
 AND #&03
 TAY

.l_1413

 JSR rnd_seq
 AND #&3E
 TAX
 LDA pair_list+&02,X
 JSR msg_alpha
 LDA pair_list+&03,X
 JSR msg_alpha
 DEY
 BPL l_1413
 RTS

.set_upprmsk

 LDA #&DF
 STA and_mask
 RTS

.vowel

 ORA #&20
 CMP #&61
 BEQ l_1446
 CMP #&65
 BEQ l_1446
 CMP #&69
 BEQ l_1446
 CMP #&6F
 BEQ l_1446
 CMP #&75
 BEQ l_1446
 CLC

.l_1446

 RTS

.macro_addr

 EQUW clr_deflowr, set_deflowr, de_token, de_token
 EQUW clr_token, set_vdustat, punctuate, column_6
 EQUW msg_cls, punctuate, hline_19, punctuate
 EQUW set_forclwr, format_on, format_off, l_1c8d
 EQUW l_13ec, name_gen, set_upprmsk, punctuate
 EQUW clr_line, l_24d7, l_24ed, l_250e
 EQUW incoming, get_line, l_12b1, l_12b4
 EQUW l_24f0, punctuate, punctuate, punctuate

.pair_list

 EQUS &0C, &0A, "ABOUSEITILETSTONLONUTHNO"

.to880

 EQUS "ALLEXEGEZACEBISOUSESARMAINDIREA?ERATENBERALAVETIEDORQ"
 EQUS "UANTEISRION"

.l_14e1

 LDA &65
 AND #&20
 BNE l_14f2
 LDA &8A
 EOR &84
 AND #&0F
 BNE l_14f2
 JSR l_3e06

.l_14f2

 LDY #&09
 JSR l_1619
 LDY #&0F
 JSR l_1619
 LDY #&15
 JSR l_1619
 LDA &64
 AND #&80
 STA &9A
 LDA &64
 AND #&7F
 BEQ l_152a
 CMP #&7F
 SBC #&00
 ORA &9A
 STA &64
 LDX #&0F
 LDY #&09
 JSR l_1680
 LDX #&11
 LDY #&0B
 JSR l_1680
 LDX #&13
 LDY #&0D
 JSR l_1680

.l_152a

 LDA &63
 AND #&80
 STA &9A
 LDA &63
 AND #&7F
 BEQ l_1553
 CMP #&7F
 SBC #&00
 ORA &9A
 STA &63
 LDX #&0F
 LDY #&15
 JSR l_1680
 LDX #&11
 LDY #&17
 JSR l_1680
 LDX #&13
 LDY #&19
 JSR l_1680

.l_1553

 \	LDA &65
 \	AND #&20
 \	BNE l_155f
 \	LDA &65
 \	ORA #&10
 \	STA &65
 \l_155f
 \	LDA &65
 \	AND #&EF
 \	STA &65
 RTS

.l_1619

 LDA &8D
 STA &81
 LDX &48,Y
 STX &82
 LDX &49,Y
 STX &83
 LDX &46,Y
 STX &1B
 LDA &47,Y
 EOR #&80
 JSR l_22ad
 STA &49,Y
 STX &48,Y
 STX &1B
 LDX &46,Y
 STX &82
 LDX &47,Y
 STX &83
 LDA &49,Y
 JSR l_22ad
 STA &47,Y
 STX &46,Y
 STX &1B
 LDA &2A
 STA &81
 LDX &48,Y
 STX &82
 LDX &49,Y
 STX &83
 LDX &4A,Y
 STX &1B
 LDA &4B,Y
 EOR #&80
 JSR l_22ad
 STA &49,Y
 STX &48,Y
 STX &1B
 LDX &4A,Y
 STX &82
 LDX &4B,Y
 STX &83
 LDA &49,Y
 JSR l_22ad
 STA &4B,Y
 STX &4A,Y
 RTS

.l_1680

 LDA &47,X
 AND #&7F
 LSR A
 STA &D1
 LDA &46,X
 SEC
 SBC &D1
 STA &82
 LDA &47,X
 SBC #&00
 STA &83
 LDA &46,Y
 STA &1B
 LDA &47,Y
 AND #&80
 STA &D1
 LDA &47,Y
 AND #&7F
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 ORA &D1
 EOR &9A
 STX &81
 JSR scale_angle
 STA &41
 STX &40
 LDX &81
 LDA &47,Y
 AND #&7F
 LSR A
 STA &D1
 LDA &46,Y
 SEC
 SBC &D1
 STA &82
 LDA &47,Y
 SBC #&00
 STA &83
 LDA &46,X
 STA &1B
 LDA &47,X
 AND #&80
 STA &D1
 LDA &47,X
 AND #&7F
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 ORA &D1
 EOR #&80
 EOR &9A
 STX &81
 JSR scale_angle
 STA &47,Y
 STX &46,Y
 LDX &81
 LDA &40
 STA &46,X
 LDA &41
 STA &47,X
 RTS

.ship_addr

 EQUW &0900, &0925, &094A, &096F, &0994, &09B9, &09DE, &0A03
 EQUW &0A28, &0A4D, &0A72, &0A97, &0ABC

.pixel_1

 EQUB &80, &40, &20, &10, &08, &04, &02, &01

.pixel_2

 EQUB &C0, &60, &30, &18, &0C, &06, &03, &03

.pixel_3

 EQUB &88, &44, &22, &11

.draw_line

 STY &85
 LDA #&80
 STA &83
 ASL A
 STA &90
 LDA &36
 SBC &34
 BCS l_1783
 EOR #&FF
 ADC #&01
 SEC

.l_1783

 STA &1B
 LDA &37
 SBC &35
 BCS l_178f
 EOR #&FF
 ADC #&01

.l_178f

 STA &81
 CMP &1B
 BCC l_1798
 JMP l_1842

.l_1798

 LDX &34
 CPX &36
 BCC l_17af
 DEC &90
 LDA &36
 STA &34
 STX &36
 TAX
 LDA &37
 LDY &35
 STA &35
 STY &37

.l_17af

 LDA &35
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA &35
 AND #&07
 TAY
 TXA
 AND #&F8
 STA ptr
 TXA
 AND #&07
 TAX
 LDA pixel_1,X
 STA &82
 LDA &81
 LDX #&FE
 STX &81

.l_17d1

 ASL A
 BCS l_17d8
 CMP &1B
 BCC l_17db

.l_17d8

 SBC &1B
 SEC

.l_17db

 ROL &81
 BCS l_17d1
 LDX &1B
 INX
 LDA &37
 SBC &35
 BCS l_1814
 LDA &90
 BNE l_17f3
 DEX

.l_17ed

 LDA &82

.change_1

 EOR (ptr),Y
 STA (ptr),Y

.l_17f3

 LSR &82
 BCC l_17ff
 ROR &82
 LDA ptr
 ADC #&08
 STA ptr

.l_17ff

 LDA &83
 ADC &81
 STA &83
 BCC l_180e
 DEY
 BPL l_180e
 DEC ptr+&01
 LDY #&07

.l_180e

 DEX
 BNE l_17ed
 LDY &85
 RTS

.l_1814

 LDA &90
 BEQ l_181f
 DEX

.l_1819

 LDA &82

.change_2

 EOR (ptr),Y
 STA (ptr),Y

.l_181f

 LSR &82
 BCC l_182b
 ROR &82
 LDA ptr
 ADC #&08
 STA ptr

.l_182b

 LDA &83
 ADC &81
 STA &83
 BCC l_183c
 INY
 CPY #&08
 BNE l_183c
 INC ptr+&01
 LDY #&00

.l_183c

 DEX
 BNE l_1819
 LDY &85
 RTS

.l_1842

 LDY &35
 TYA
 LDX &34
 CPY &37
 BCS l_185b
 DEC &90
 LDA &36
 STA &34
 STX &36
 TAX
 LDA &37
 STA &35
 STY &37
 TAY

.l_185b

 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 TXA
 AND #&F8
 STA ptr
 TXA
 AND #&07
 TAX
 LDA pixel_1,X
 STA &82
 LDA &35
 AND #&07
 TAY
 LDA &1B
 LDX #&01
 STX &1B

.l_187b

 ASL A
 BCS l_1882
 CMP &81
 BCC l_1885

.l_1882

 SBC &81
 SEC

.l_1885

 ROL &1B
 BCC l_187b
 LDX &81
 INX
 LDA &36
 SBC &34
 BCC l_18bf
 CLC
 LDA &90
 BEQ l_189e
 DEX

.l_1898

 LDA &82

.change_3

 EOR (ptr),Y
 STA (ptr),Y

.l_189e

 DEY
 BPL l_18a5
 DEC ptr+&01
 LDY #&07

.l_18a5

 LDA &83
 ADC &1B
 STA &83
 BCC l_18b9
 LSR &82
 BCC l_18b9
 ROR &82
 LDA ptr
 ADC #&08
 STA ptr

.l_18b9

 DEX
 BNE l_1898
 LDY &85
 RTS

.l_18bf

 LDA &90
 BEQ l_18ca
 DEX

.l_18c4

 LDA &82

.change_4

 EOR (ptr),Y
 STA (ptr),Y

.l_18ca

 DEY
 BPL l_18d1
 DEC ptr+&01
 LDY #&07

.l_18d1

 LDA &83
 ADC &1B
 STA &83
 BCC l_18e6
 ASL &82
 BCC l_18e6
 ROL &82
 LDA ptr
 SBC #&07
 STA ptr
 CLC

.l_18e6

 DEX
 BNE l_18c4
 LDY &85

.l_18eb

 RTS

.flush_inp

 LDA #&0F
 TAX
 JMP osbyte

.header

 JSR de_token

.hline_19

 LDA #&13
 BNE hline_acc

.hline_23

 LDA #&17
 INC cursor_y

.hline_acc

 STA &35
 LDX #&02
 STX &34
 LDX #&FE
 STX &36
 BNE draw_hline

.l_1909

 JSR l_3586
 STY &35
 LDA #&00
 STA &0E00,Y

.draw_hline

 STY &85
 LDX &34
 CPX &36
 BEQ l_18eb
 BCC l_1924
 LDA &36
 STA &34
 STX &36
 TAX

.l_1924

 DEC &36
 LDA &35
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA &35
 AND #&07
 STA ptr
 TXA
 AND #&F8
 TAY
 TXA
 AND #&F8
 STA &D1
 LDA &36
 AND #&F8
 SEC
 SBC &D1
 BEQ l_197e
 LSR A
 LSR A
 LSR A
 STA &82
 LDA &34
 AND #&07
 TAX
 LDA horiz_seg+&07,X
 EOR (ptr),Y
 STA (ptr),Y
 TYA
 ADC #&08
 TAY
 LDX &82
 DEX
 BEQ l_196f
 CLC

.l_1962

 LDA #&FF
 EOR (ptr),Y
 STA (ptr),Y
 TYA
 ADC #&08
 TAY
 DEX
 BNE l_1962

.l_196f

 LDA &36
 AND #&07
 TAX
 LDA horiz_seg,X
 EOR (ptr),Y
 STA (ptr),Y
 LDY &85
 RTS

.l_197e

 LDA &34
 AND #&07
 TAX
 LDA horiz_seg+&07,X
 STA &D1
 LDA &36
 AND #&07
 TAX
 LDA horiz_seg,X
 AND &D1
 EOR (ptr),Y
 STA (ptr),Y
 LDY &85
 RTS

.horiz_seg

 EQUB &80, &C0, &E0, &F0, &F8, &FC, &FE
 EQUB &FF, &7F, &3F, &1F, &0F, &07, &03, &01

.l_19a8

 LDA pixel_1,X
 EOR (ptr),Y
 STA (ptr),Y
 LDY &06
 RTS

.draw_pixel

 STY &06
 TAY
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 TXA
 AND #&F8
 STA ptr
 TYA
 AND #&07
 TAY
 TXA
 AND #&07
 TAX
 LDA &88
 CMP #&90
 BCS l_19a8
 LDA pixel_2,X
 EOR (ptr),Y
 STA (ptr),Y
 LDA &88
 CMP #&50
 BCS l_1a13
 DEY
 BPL l_1a0c
 LDY #&01

.l_1a0c

 LDA pixel_2,X
 EOR (ptr),Y
 STA (ptr),Y

.l_1a13

 LDY &06
 RTS

.l_1a16

 TXA
 ADC &E0
 STA &78
 LDA &E1
 ADC &D1
 STA &79
 LDA &92
 BEQ l_1a37
 INC &92

.l_1a27

 LDY &6B
 LDA #&FF
 CMP &0F0D,Y
 BEQ l_1a98
 STA &0F0E,Y
 INC &6B
 BNE l_1a98

.l_1a37

 LDA vdu_stat
 STA &34
 LDA &73
 STA &35
 LDA &74
 STA &36
 LDA &75
 STA &37
 LDA &76
 STA &38
 LDA &77
 STA &39
 LDA &78
 STA &3A
 LDA &79
 STA &3B
 JSR l_4594
 BCS l_1a27
 LDA &90
 BEQ l_1a70
 LDA &34
 LDY &36
 STA &36
 STY &34
 LDA &35
 LDY &37
 STA &37
 STY &35

.l_1a70

 LDY &6B
 LDA &0F0D,Y
 CMP #&FF
 BNE l_1a84
 LDA &34
 STA &0EC0,Y
 LDA &35
 STA &0F0E,Y
 INY

.l_1a84

 LDA &36
 STA &0EC0,Y
 LDA &37
 STA &0F0E,Y
 INY
 STY &6B
 JSR draw_line
 LDA &89
 BNE l_1a27

.l_1a98

 LDA &76
 STA vdu_stat
 LDA &77
 STA &73
 LDA &78
 STA &74
 LDA &79
 STA &75
 LDA &93
 CLC
 ADC &95
 STA &93
 RTS

.equip_costs

 EQUW &0001
 \ 00 Cobra 3, Boa
 EQUW   250,  4000,  6000,  4000, 10000,  5250, 3000
 EQUW  5500, 15000, 15000, 50000, 30000,  2500
 \ 1A Adder, Cobra 1, Python
 EQUW   250,  2000,  4000,  2000,  4500,  3750, 2000
 EQUW  3750,  9000,  8000, 30000, 23000,  2500
 \ 34 Fer-de-Lance, Asp 2
 EQUW   250,  4000,  5000,  5000, 10000,  7000, 6000
 EQUW  4000, 25000, 10000, 40000, 50000,  2500
 \ 4E Monitor, Anaconda
 EQUW   250,  3000,  8000,  6000,  8000,  6500, 4500
 EQUW  8000, 19000, 20000, 60000, 25000,  2500
 \ 68 Moray, Ophidian
 EQUW   250,  1500,  3000,  3500,  7000,  4500, 2500
 EQUW  4500,  7000,  7000, 30000, 19000,  2500

.l_1aec

 LDX #&09
 CMP #&19
 BCS l_1b3f
 DEX
 CMP #&0A
 BCS l_1b3f
 DEX
 CMP #&02
 BCS l_1b3f
 DEX
 BNE l_1b3f

.status

 LDA #&08
 JSR clr_scrn
 JSR snap_hype
 LDA #&07
 STA cursor_x
 LDA #&7E
 JSR header
 LDA #&CD
 JSR write_msg1
 JSR new_line
 LDA #&7D
 JSR spc_token
 LDA #&13
 LDY cmdr_legal
 BEQ l_1b28
 CPY #&32
 ADC #&01

.l_1b28

 JSR de_tokln
 LDA #&10
 JSR spc_token
 LDA cmdr_kills+&01
 BNE l_1aec
 TAX
 LDA cmdr_kills
 LSR A
 LSR A

.l_1b3b

 INX
 LSR A
 BNE l_1b3b

.l_1b3f

 TXA
 CLC
 ADC #&15
 JSR de_tokln
 LDA #&12
 JSR status_equip

.sell_equip

 LDA cmdr_hold
 BEQ l_1b57	\ IFF if flag not set
 LDA #&6B
 LDX #&06
 JSR status_equip

.l_1b57

 LDA cmdr_scoop
 BEQ l_1b61
 LDA #&6F
 LDX #&19
 JSR status_equip

.l_1b61

 LDA cmdr_ecm
 BEQ l_1b6b
 LDA #&6C
 LDX #&18
 JSR status_equip

.l_1b6b

 \	LDA #&71
 \	STA &96
 LDX #&1A

.l_1b6f

 STX &93
 \	TAY
 \	LDX ship_type,Y
 LDY cmdr_laser,X
 BEQ l_1b78
 TXA
 CLC
 ADC #&57
 JSR status_equip

.l_1b78

 \	INC &96
 \	LDA &96
 \	CMP #&75
 LDX &93
 INX
 CPX #&1E
 BCC l_1b6f
 LDX #&00

.l_1b82

 STX &93
 LDY cmdr_laser,X
 BEQ l_1bac
 TXA
 ORA #&60
 JSR spc_token
 LDA #&67
 LDX &93
 LDY cmdr_laser,X
 CPY new_beam	\ beam laser
 BNE l_1b9d
 LDA #&68

.l_1b9d

 CPY new_military	\ military laser
 BNE l_1ba3
 LDA #&75

.l_1ba3

 CPY new_mining	\ mining laser
 BNE l_1ba9
 LDA #&76

.l_1ba9

 JSR status_equip

.l_1bac

 LDX &93
 INX
 CPX #&04
 BCC l_1b82
 RTS

.status_equip

 STX &93
 STA &96
 JSR de_token
 LDX &87
 CPX #&08
 BEQ status_keep
 LDA #&15
 STA cursor_x
 JSR vdu_80
 LDA #&01
 STA &03AB
 JSR sell_yn
 BEQ status_no
 BCS status_no
 LDA &96
 CMP #&6B
 BCS status_over
 ADC #&07

.status_over

 SBC #&68
 JSR equip_price
 LSR A
 TAY
 TXA
 ROR A
 TAX
 JSR add_money
 INC new_hold	\**
 LDX &93
 LDA #&00
 STA cmdr_laser,X

.status_no

 LDX #&01

.status_keep

 STX cursor_x
 LDA #&0A
 JMP de_token

.l_1bbc

 EQUD &00E87648

.writed_3

 LDA #&03

.writed_byte

 LDY #&00

.writed_word

 STA &80
 LDA #&00
 STA &40
 STA &41
 STY &42
 STX &43

.l_1bd0

 LDX #&0B
 STX &D1
 PHP
 BCC l_1bdb
 DEC &D1
 DEC &80

.l_1bdb

 LDA #&0B
 SEC
 STA &86
 SBC &80
 STA &80
 INC &80
 LDY #&00
 STY &83
 JMP l_1c2c

.l_1bed

 ASL &43
 ROL &42
 ROL &41
 ROL &40
 ROL &83
 LDX #&03

.l_1bf9

 LDA &40,X
 STA &34,X
 DEX
 BPL l_1bf9
 LDA &83
 STA &38
 ASL &43
 ROL &42
 ROL &41
 ROL &40
 ROL &83
 ASL &43
 ROL &42
 ROL &41
 ROL &40
 ROL &83
 CLC
 LDX #&03

.l_1c1b

 LDA &40,X
 ADC &34,X
 STA &40,X
 DEX
 BPL l_1c1b
 LDA &38
 ADC &83
 STA &83
 LDY #&00

.l_1c2c

 LDX #&03
 SEC

.l_1c2f

 LDA &40,X
 SBC l_1bbc,X
 STA &34,X
 DEX
 BPL l_1c2f
 LDA &83
 SBC #&17
 STA &38
 BCC l_1c52
 LDX #&03

.l_1c43

 LDA &34,X
 STA &40,X
 DEX
 BPL l_1c43
 LDA &38
 STA &83
 INY
 JMP l_1c2c

.l_1c52

 TYA
 BNE l_1c61
 LDA &D1
 BEQ l_1c61
 DEC &80
 BPL l_1c6b
 LDA #&20
 BNE l_1c68

.l_1c61

 LDY #&00
 STY &D1
 CLC
 ADC #&30

.l_1c68

 JSR punctuate

.l_1c6b

 DEC &D1
 BPL l_1c71
 INC &D1

.l_1c71

 DEC &86
 BMI l_1c82
 BNE l_1c7f
 PLP
 BCC l_1c7f
 LDA #&2E
 JSR punctuate

.l_1c7f

 JMP l_1bed

.l_1c82

 RTS

.or_mask

 EQUB &20

.upper_switch

 EQUB &FF

.token_switch

 EQUB &00

.format_switch

 EQUB &00

.format_posn

 EQUB &00

.lower_switch

 EQUB &00

.and_mask

 EQUB &FF

.l_1c8a

 LDA #&0C

.bit13

 EQUB &2C

.l_1c8d

 LDA #&41

.punctuate

 STX ptr
 LDX #&FF
 STX and_mask
 CMP #&2E
 BEQ is_punct
 CMP #&3A
 BEQ is_punct
 CMP #&0A
 BEQ is_punct
 CMP #&0C
 BEQ is_punct
 CMP #&20
 BEQ is_punct
 INX

.is_punct

 STX upper_switch
 LDX ptr
 BIT format_switch
 BMI format
 JMP wrchdst

.format

 CMP #&0C
 BEQ l_1cc9
 LDX format_posn
 STA &0E01,X
 LDX ptr
 INC format_posn
 CLC
 RTS

.l_1cc9

 TXA
 PHA
 TYA
 PHA

.l_1ccd

 LDX format_posn
 BEQ l_1d4a
 CPX #&1F
 BCC l_1d47
 LSR ptr+&01

.l_1cd8

 LDA ptr+&01
 BMI l_1ce0
 LDA #&40
 STA ptr+&01

.l_1ce0

 LDY #&1D

.l_1ce2

 LDA &0E1F
 CMP #&20
 BEQ l_1d16

.l_1ce9

 DEY
 BMI l_1cd8
 BEQ l_1cd8
 LDA &0E01,Y
 CMP #&20
 BNE l_1ce9
 ASL ptr+&01
 BMI l_1ce9
 STY ptr
 LDY format_posn

.l_1cfe

 LDA &0E01,Y
 STA &0E02,Y
 DEY
 CPY ptr
 BCS l_1cfe
 INC format_posn

.l_1d0c

 CMP &0E01,Y
 BNE l_1ce2
 DEY
 BPL l_1d0c
 BMI l_1cd8

.l_1d16

 LDX #&1E
 JSR l_1d3a
 LDA #&0C
 JSR wrchdst
 LDA format_posn
 SBC #&1E
 STA format_posn
 TAX
 BEQ l_1d4a
 LDY #&00
 INX

.l_1d2e

 LDA &0E20,Y
 STA &0E01,Y
 INY
 DEX
 BNE l_1d2e
 BEQ l_1ccd

.l_1d3a

 LDY #&00

.l_1d3c

 LDA &0E01,Y
 JSR wrchdst
 INY
 DEX
 BNE l_1d3c
 RTS

.l_1d47

 JSR l_1d3a

.l_1d4a

 STX format_posn
 PLA
 TAY
 PLA
 TAX
 LDA #&0C

.bit

 EQUB &2C

.bell

 LDA #&07

.wrchdst

 STA &D2
 STY &034F
 STX &034E

.l_1d5e

 LDY vdu_stat
 INY
 BEQ wrch_quit
 TAY
 BEQ wrch_quit
 BMI wrch_quit
 CMP #&07
 BEQ wrch_bell
 CMP #&20
 BCS wrch_hard
 CMP #&0A
 BEQ next_line
 LDX #&01
 STX cursor_x
 CMP #&0D
 BEQ wrch_quit

.next_line

 INC cursor_y
 BNE wrch_quit

.wrch_hard

 LDX #&BF
 ASL A
 ASL A
 BCC font_c0
 LDX #&C1

.font_c0

 ASL A
 BCC font_cl
 INX

.font_cl

 STA &1C
 STX &1D
 LDA cursor_x
 LDX &03CF
 BEQ wrch_addr
 CPY #&20
 BNE wrch_addr
 CMP #&11
 BEQ wrch_quit

.wrch_addr

 ASL A
 ASL A
 ASL A
 STA ptr
 LDA cursor_y
 CPY #&7F
 BNE not_del
 DEC cursor_x
 ADC #&5E
 TAX
 LDY #&F8
 JSR l_3a03
 BEQ wrch_quit

.not_del

 INC cursor_x
 CMP #&18
 BCC wrch_or
 PHA
 JSR l_2539
 PLA
 LDA &D2
 JMP l_1d5e

.wrch_or

 ORA #&60
 STA ptr+&01
 LDY #&07

.wrch_matrix

 LDA (&1C),Y
 ORA (ptr),Y
 STA (ptr),Y
 DEY
 BPL wrch_matrix

.wrch_quit

 LDY &034F
 LDX &034E
 LDA &D2
 CLC

.l_1dde

 RTS

.wrch_bell

 JSR sound_20
 JMP wrch_quit

.console

 LDA #&D0
 STA ptr
 LDA #&78
 STA ptr+&01
 JSR flash_col
 STX &41
 STA &40
 LDA #&0E
 STA &06
 LDA &7D
 JSR bar_half
 \	LDA #&00
 \	STA &82
 \	STA &1B
 \	LDA #&08
 \	STA &83
 \	LDA &31
 \	LSR A
 \	LSR A
 \	ORA &32
 \	EOR #&80
 LDA #&10
 \	JSR scale_angle
 JSR draw_angle
 \	LDA &2A
 \	LDX &2B
 \	BEQ l_1e1d
 \	SBC #&01
 LDA #&10
 \l_1e1d
 \	JSR scale_angle
 JSR draw_angle
 LDA &8A
 AND #&03
 BNE l_1dde
 LDY #&00
 JSR flash_col
 STX &40
 STA &41
 LDX #&03
 STX &06

.l_1e36

 STY &3A,X
 DEX
 BPL l_1e36
 LDX #&03
 \	LDA energy
 \	LSR A
 \	LSR A
 LDA #&3F
 STA &81

.l_1e44

 SEC
 SBC #&10
 BCC l_1e56
 STA &81
 LDA #&10
 STA &3A,X
 LDA &81
 DEX
 BPL l_1e44
 BMI l_1e5a

.l_1e56

 LDA &81
 STA &3A,X

.l_1e5a

 LDA &3A,Y
 STY &1B
 JSR draw_bar
 LDY &1B
 INY
 CPY #&04
 BNE l_1e5a
 LDA #&78
 STA ptr+&01
 LDA #&10
 STA ptr
 \	LDA f_shield
 LDA #&FF
 JSR bar_sixtnth
 \	LDA r_shield
 LDA #&FF
 JSR bar_sixtnth
 LDA cmdr_fuel
 JSR bar_fourth
 JSR flash_col
 STX &41
 STA &40
 LDX #&0B
 STX &06
 LDA cabin_t
 JSR bar_sixtnth
 LDA laser_t
 JSR bar_sixtnth
 LDA #&F0
 STA &06
 STA &41
 LDA altitude
 JMP bar_sixtnth

.flash_col

 LDX #&F0
 \	LDA &8A
 \	AND #&08
 \	AND f_flag
 \	BEQ l_1eb3
 \	TXA
 \bit8
 \	EQUB &2C
 \l_1eb3
 LDA #&0F
 RTS

.bar_sixtnth

 LSR A

.bar_eighth

 LSR A

.bar_fourth

 LSR A

.bar_half

 LSR A

.draw_bar

 STA &81
 LDX #&FF
 STX &82
 CMP &06
 BCS flash_gr
 LDA &41
 \	BNE flash_le
 EQUB &2C

.flash_gr

 LDA &40

.flash_le

 STA &91
 LDY #&02
 LDX #&03

.bar_byte

 LDA &81
 CMP #&04
 BCC bar_part
 SBC #&04
 STA &81
 LDA &82

.l_1edc

 AND &91
 STA (ptr),Y
 INY
 STA (ptr),Y
 INY
 STA (ptr),Y
 TYA
 CLC
 ADC #&06
 TAY
 DEX
 BMI l_1f0a
 BPL bar_byte

.bar_part

 EOR #&03
 STA &81
 LDA &82

.l_1ef6

 ASL A
 AND #&EF
 DEC &81
 BPL l_1ef6
 PHA
 LDA #&00
 STA &82
 LDA #&63
 STA &81
 PLA
 JMP l_1edc

.l_1f0a

 INC ptr+&01
 RTS

.draw_angle

 LDY #&01
 STA &81

.l_1f11

 SEC
 LDA &81
 SBC #&04
 BCS l_1f26
 LDA #&FF
 LDX &81
 STA &81
 LDA pixel_3,X
 AND #&F0
 JMP l_1f2a

.l_1f26

 STA &81
 LDA #&00

.l_1f2a

 STA (ptr),Y
 INY
 STA (ptr),Y
 INY
 STA (ptr),Y
 INY
 STA (ptr),Y
 TYA
 CLC
 ADC #&05
 TAY
 CPY #&1E
 BCC l_1f11
 INC ptr+&01
 RTS

.find_plant

 LDA #&0E
 JSR write_msg1
 JSR map_cursor
 JSR copy_xy
 LDA #&00
 STA &97

.find_loop

 JSR format_on
 JSR write_planet
 LDX format_posn
 LDA &4B,X
 CMP #&0D
 BNE l_1f6c

.l_1f5f

 DEX
 LDA &4B,X
 ORA #&20
 CMP &0E01,X
 BEQ l_1f5f
 TXA
 BMI found_plant

.l_1f6c

 JSR permute_4
 INC &97
 BNE find_loop
 JSR snap_hype
 JSR map_cursor
 LDA #&28
 JSR sound
 LDA #&D7
 JMP write_msg1

.found_plant

 LDA &6F
 STA data_homex
 LDA &6D
 STA data_homey
 JSR snap_hype
 JSR map_cursor
 JSR format_off
 JMP distance

.l_1f99

 EQUB &02, &54, &3B
 EQUB &03, &82, &B0
 EQUB &00, &00, &00
 EQUB &01, &50, &11
 EQUB &01, &D1, &28
 EQUB &01, &40, &06
 EQUB &03, &60, &90
 EQUB &04, &10, &D1
 EQUB &00, &00, &00
 EQUB &06, &51, &F8
 EQUB &07, &60, &75
 EQUB &00, &00, &00

.picture

 JSR draw_mode
 LDA #&00
 JSR clr_scrn
 JSR rnd_seq
 BPL l_1ff3
 AND #&03
 STA &D1
 ASL A
 ASL A
 ASL A
 ADC &D1
 TAX
 LDY #&03
 STY &94

.l_1fd8

 LDY #&02

.l_1fda

 LDA l_1f99,X
 STA &34,Y
 INX
 DEY
 BPL l_1fda
 TXA
 PHA
 JSR l_2079
 PLA
 TAX
 DEC &94
 BNE l_1fd8
 LDY #&80
 BNE l_2007

.l_1ff3

 LSR A
 STA &35
 JSR rnd_seq
 STA &34
 JSR rnd_seq
 AND #&07
 STA &36
 JSR l_2079
 LDY #&00

.l_2007

 STY &85
 JSR draw_mode
 LDX #&02

.l_200e

 STX &84
 LDA #&82
 LDX &84
 STX &81
 JSR l_2316
 LDA &1B
 CLC
 ADC #&60
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA &1B
 AND #&07
 STA ptr
 LDY #&00
 JSR l_20e8
 LDA #&04
 LDY #&F8
 JSR l_2101
 LDY &85
 BEQ l_2045
 JSR l_20e8
 LDY #&80
 LDA #&40
 JSR l_2101

.l_2045

 LDX &84
 INX
 CPX #&0D
 BCC l_200e
 LDA #&10

.l_204e

 LDX #&60
 STX ptr+&01
 STA &84
 AND #&F8
 STA ptr
 LDX #&80
 LDY #&01

.l_205c

 TXA
 AND (ptr),Y
 BNE l_2071
 TXA
 ORA (ptr),Y
 STA (ptr),Y
 INY
 CPY #&08
 BNE l_205c
 INC ptr+&01
 LDY #&00
 BEQ l_205c

.l_2071

 LDA &84
 CLC
 ADC #&10
 BNE l_204e
 RTS

.l_2079

 JSR init_ship
 LDA &34
 STA &4C
 LSR A
 ROR &48
 LDA &35
 STA &46
 LSR A
 LDA #&01
 ADC #&00
 STA &4D
 LDA #&80
 STA &4B
 STA &9A
 LDA #&0B
 STA &68
 JSR rnd_seq
 STA &84

.l_209d

 LDX #&15
 LDY #&09
 JSR l_1680
 LDX #&17
 LDY #&0B
 JSR l_1680
 LDX #&19
 LDY #&0D
 JSR l_1680
 DEC &84
 BNE l_209d
 LDY &36
 BEQ l_2138
 LDX #&04

.l_20bc

 INX
 INX
 LDA ship_data,X
 STA &1E
 LDA ship_data+&01,X
 STA &1F
 BEQ l_20bc
 DEY
 BNE l_20bc
 LDY #&01
 LDA (&1E),Y
 STA &81
 INY
 LDA (&1E),Y
 STA &82
 JSR sqr_root
 LDA #&64
 SBC &81
 LSR A
 STA &49
 JSR l_3e06
 JMP l_400f

.l_20e8

 LDA #&20

.l_20ea

 TAX
 AND (ptr),Y
 BNE l_2100
 TXA
 ORA (ptr),Y
 STA (ptr),Y
 TXA
 LSR A
 BCC l_20ea
 TYA
 ADC #&07
 TAY
 LDA #&80
 BCC l_20ea

.l_2100

 RTS

.l_2101

 TAX
 AND (ptr),Y
 BNE l_2100
 TXA
 ORA (ptr),Y
 STA (ptr),Y
 TXA
 ASL A
 BCC l_2101
 TYA
 SBC #&08
 TAY
 LDA #&01
 BCS l_2101
 RTS

.draw_mode

 LDA change_1
 EOR #&40
 STA change_1
 \	LDA change_2
 \	EOR #&40
 STA change_2
 \	LDA change_3
 \	EOR #&40
 STA change_3
 \	LDA change_4
 \	EOR #&40
 STA change_4

.l_2138

 RTS

.pattern

 LDX #&80
 STX &D2
 LDX #&60
 STX &E0
 LDX #&00
 STX &96
 STX &D3
 STX &E1

.l_216b

 JSR l_2177
 INC &96
 LDX &96
 CPX #&08
 BNE l_216b
 RTS

.l_2177

 LDA &96
 AND #&07
 CLC
 ADC #&08
 STA &40

.l_2180

 LDA #&01
 STA &6B
 JSR circle
 ASL &40
 BCS l_2191
 LDA &40
 CMP #&A0
 BCC l_2180

.l_2191

 RTS

.l_21be

 AND #&7F

.square

 STA &1B
 TAX
 BNE l_21d7

.l_21c5

 CLC
 STX &1B
 TXA
 RTS

.price_mult

 LDX &81
 BEQ l_21c5

.l_21d7

 DEX
 STX &D1
 LDA #&00
 LDX #&08
 LSR &1B

.l_21e0

 BCC l_21e4
 ADC &D1

.l_21e4

 ROR A
 ROR &1B
 DEX
 BNE l_21e0
 RTS

.l_21f0

 AND #&1F
 TAX
 LDA &07C0,X
 STA &81
 LDA &40

.l_21fa

 EOR #&FF
 SEC
 ROR A
 STA &1B
 LDA #&00

.l_2202

 BCS l_220c
 ADC &81
 ROR A
 LSR &1B
 BNE l_2202
 RTS

.l_220c

 LSR A
 LSR &1B
 BNE l_2202
 RTS

.l_2259

 TAX
 AND #&7F
 LSR A
 STA &1B
 TXA
 EOR &81
 AND #&80
 STA &D1
 LDA &81
 AND #&7F
 BEQ l_2284
 TAX
 DEX
 STX &06
 LDA #&00
 LDX #&07

.l_2274

 BCC l_2278
 ADC &06

.l_2278

 ROR A
 ROR &1B
 DEX
 BNE l_2274
 LSR A
 ROR &1B
 ORA &D1
 RTS

.l_2284

 STA &1B
 RTS

.l_2287

 JSR l_2259
 STA &83
 LDA &1B
 STA &82
 RTS

.l_22ad

 JSR l_2259

.scale_angle

 STA &06
 AND #&80
 STA &D1
 EOR &83
 BMI l_22c7
 LDA &82
 CLC
 ADC &1B
 TAX
 LDA &83
 ADC &06
 ORA &D1
 RTS

.l_22c7

 LDA &83
 AND #&7F
 STA &80
 LDA &1B
 SEC
 SBC &82
 TAX
 LDA &06
 AND #&7F
 SBC &80
 BCS l_22e9
 STA &80
 TXA
 EOR #&FF
 ADC #&01
 TAX
 LDA #&00
 SBC &80
 ORA #&80

.l_22e9

 EOR &D1
 RTS

.l_22ec

 STX &81
 EOR #&80
 JSR l_22ad
 TAX
 AND #&80
 STA &D1
 TXA
 AND #&7F
 LDX #&FE
 STX &06

.l_22ff

 ASL A
 CMP #&60
 BCC l_2306
 SBC #&60

.l_2306

 ROL &06
 BCS l_22ff
 LDA &06
 ORA &D1
 RTS

.l_2316

 LDX #&08
 ASL A
 STA &1B
 LDA #&00

.l_231d

 ROL A
 BCS l_2324
 CMP &81
 BCC l_2327

.l_2324

 SBC &81
 SEC

.l_2327

 ROL &1B
 DEX
 BNE l_231d
 JMP l_3f79

.l_23e8

 LDA hype_dist
 ORA hype_dist+&01
 BNE l_2424
 LDY #&19

.l_23f2

 LDA l_5338,Y
 CMP &88
 BNE l_2421
 LDA misn_data2,Y
 AND #&7F
 CMP cmdr_galxy
 BNE l_2421
 LDA misn_data2,Y
 BMI l_2414
 LDA cmdr_mission
 LSR A
 BCC l_2424
 JSR format_on
 LDA #&01

.bit9

 EQUB &2C

.l_2414

 LDA #&B0
 JSR xpand_msg
 TYA
 JSR write_msg2
 LDA #&B1
 BNE l_242f

.l_2421

 DEY
 BNE l_23f2

.l_2424

 LDX #&03

.l_2426

 LDA &6E,X
 STA &00,X
 DEX
 BPL l_2426
 LDA #&05

.l_242f

 JMP write_msg1

.mission_2

 LDA cmdr_mission
 ORA #&04
 STA cmdr_mission
 LDA #&0B

.l_243c

 JSR write_msg1
 JMP start_loop

.constrictor

 LDA cmdr_mission
 AND #&F0
 ORA #&0A
 STA cmdr_mission
 LDA #&DE
 BNE l_243c

.reward_2

 LDA cmdr_mission
 ORA #&04
 STA cmdr_mission
 LDA cmdr_eunit	\**
 BNE rew_notgot	\**
 DEC new_hold	\** NOT TRAPPED FOR NO SPACE

.rew_notgot

 \**
 LDA #&02
 STA cmdr_eunit
 INC cmdr_kills+&01
 LDA #&DF
 BNE l_243c

.reward_1

 LSR cmdr_mission
 ASL cmdr_mission
 INC cmdr_kills+&01
 LDX #&50
 LDY #&C3
 JSR add_money
 LDA #&0F

.l_2476

 BNE l_243c

.mission_1

 LSR cmdr_mission
 SEC
 ROL cmdr_mission
 JSR incoming
 JSR init_ship
 LDA #&1F
 STA &8C
 JSR ins_ship
 LDA #&01
 STA cursor_x
 STA &4D
 JSR clr_scrn
 LDA #&40
 STA &8A

.l_2499

 LDX #&7F
 STX &63
 STX &64
 JSR l_400f
 JSR l_14e1
 DEC &8A
 BNE l_2499

.l_24a9

 LSR &46
 INC &4C
 BEQ l_24c7
 INC &4C
 BEQ l_24c7
 LDX &49
 INX
 CPX #&70
 BCC l_24bc
 LDX #&70

.l_24bc

 STX &49
 JSR l_400f
 JSR l_14e1
 JMP l_24a9

.l_24c7

 INC &4D
 LDA #&0A
 BNE l_2476

.incoming

 LDA #&D8
 JSR write_msg1
 LDY #&64
 JMP y_sync

.l_24d7

 JSR l_24f7
 BNE l_24d7

.l_24dc

 JSR l_24f7
 BEQ l_24dc
 LDA #&00
 STA &65
 LDA #&01
 JSR clr_scrn
 JSR l_400f

.l_24ed

 LDA #&0A

.bit7

 EQUB &2C

.l_24f0

 LDA #&06
 STA cursor_y
 JMP set_forclwr

.l_24f7

 LDA #&70
 STA &49
 LDA #&00
 STA &46
 STA &4C
 LDA #&02
 STA &4D
 JSR l_400f
 JSR l_14e1
 JMP scan_10

.l_250e

 JSR scan_10
 BNE l_250e
 JSR scan_10
 BEQ l_250e
 RTS

.clr_scrn

 STA &87

.l_2539

 JSR set_deflowr
 LDA #&80
 STA vdu_stat
 STA upper_switch
 ASL A
 STA &0346
 STA &034A
 STA &034B
 LDX #&60

.l_254f

 JSR clr_page
 INX
 CPX #&78
 BNE l_254f
 LDY #&01
 STY cursor_y
 LDA &87
 BNE l_2573
 LDY #&0B
 STY cursor_x
 LDA view_dirn
 ORA #&60
 JSR de_token
 JSR price_spc
 LDA #&AF
 JSR de_token

.l_2573

 LDX #&00
 STX &34
 STX &35
 STX vdu_stat
 DEX
 STX &36
 JSR draw_hline
 LDA #&02
 STA &34
 STA &36
 JSR l_258a

.l_258a

 JSR l_258d

.l_258d

 LDA #&00
 STA &35
 LDA #&BF
 STA &37
 DEC &34
 DEC &36
 JMP draw_line

.y_sync

 JSR sync
 DEY
 BNE y_sync
 RTS

.clr_line

 LDA #&FF
 STA upper_switch
 LDA #&14
 STA cursor_y
 JSR new_line
 LDA #&75
 STA ptr+&01
 LDA #&07
 STA ptr
 LDA #&00
 JSR clr_e9
 INC ptr+&01
 JSR clr_e9
 INC ptr+&01
 INY
 STY cursor_x

.clr_e9

 LDY #&E9

.l_25c8

 STA (ptr),Y
 DEY
 BNE l_25c8
 RTS

.sync

 LDA #&00
 STA &8B

.sync_wait

 LDA &8B
 BEQ sync_wait
 RTS

.chk_cargo

 \	PHA
 LDX #&0C
 CPX &03AD
 BCC chk_quant
 CLC

.tot_cargo

 ADC cmdr_cargo,X
 BCS n_over
 DEX
 BPL tot_cargo
 CMP new_hold	\ New hold size

.n_over

 \	PLA
 RTS

.chk_quant

 LDY &03AD
 ADC cmdr_cargo,Y
 \	PLA
 RTS

.permute_4

 JSR permute_2

.permute_2

 JSR permute_1

.permute_1

 LDA &6C
 CLC
 ADC &6E
 TAX
 LDA &6D
 ADC &6F
 TAY
 LDA &6E
 STA &6C
 LDA &6F
 STA &6D
 LDA &71
 STA &6F
 LDA &70
 STA &6E
 CLC
 TXA
 ADC &6E
 STA &70
 TYA
 ADC &6F
 STA &71
 RTS

.show_nzdist

 LDA hype_dist
 ORA hype_dist+&01
 BNE show_dist
 INC cursor_y
 RTS

.show_dist

 LDA #&BF
 JSR pre_colon
 LDX hype_dist
 LDY hype_dist+&01
 SEC
 JSR writed_5
 LDA #&C3

.tok_nxtpar

 JSR de_token

.next_par

 INC cursor_y

.new_pgph

 LDA #&80
 STA vdu_stat

.new_line

 LDA #&0C
 JMP de_token

.l_2688

 LDA #&AD
 JSR de_token
 JMP l_26c7

.spc_token

 JSR de_token
 JMP price_spc

.data_onsys

 JSR l_3c91
 BPL not_cyclop
 JMP encyclopedia

.not_cyclop

 LDA #&01
 JSR clr_scrn
 LDA #&09
 STA cursor_x
 LDA #&A3
 JSR header
 JSR next_par
 JSR show_nzdist
 LDA #&C2
 JSR pre_colon
 LDA data_econ
 CLC
 ADC #&01
 LSR A
 CMP #&02
 BEQ l_2688
 LDA data_econ
 BCC l_26c2
 SBC #&05
 CLC

.l_26c2

 ADC #&AA
 JSR de_token

.l_26c7

 LDA data_econ
 LSR A
 LSR A
 CLC
 ADC #&A8
 JSR tok_nxtpar
 LDA #&A2
 JSR pre_colon
 LDA data_govm
 CLC
 ADC #&B1
 JSR tok_nxtpar
 LDA #&C4
 JSR pre_colon
 LDX data_tech
 INX
 CLC
 JSR writed_3
 JSR next_par
 LDA #&C0
 JSR pre_colon
 SEC
 LDX data_popn
 JSR writed_3
 LDA #&C6
 JSR tok_nxtpar
 LDA #&28
 JSR de_token
 LDA &70
 BMI l_2712
 LDA #&BC
 JSR de_token
 JMP l_274e

.l_2712

 LDA &71
 LSR A
 LSR A
 PHA
 AND #&07
 CMP #&03
 BCS l_2722
 ADC #&E3
 JSR spc_token

.l_2722

 PLA
 LSR A
 LSR A
 LSR A
 CMP #&06
 BCS l_272f
 ADC #&E6
 JSR spc_token

.l_272f

 LDA &6F
 EOR &6D
 AND #&07
 STA &73
 CMP #&06
 BCS l_2740
 ADC #&EC
 JSR spc_token

.l_2740

 LDA &71
 AND #&03
 CLC
 ADC &73
 AND #&07
 ADC #&F2
 JSR de_token

.l_274e

 LDA #&53
 JSR de_token
 LDA #&29
 JSR tok_nxtpar
 LDA #&C1
 JSR pre_colon
 LDX data_gnp
 LDY data_gnp+&01
 JSR writed_5c
 JSR price_spc
 LDA #&00
 STA vdu_stat
 LDA #&4D
 JSR de_token
 LDA #&E2
 JSR tok_nxtpar
 LDA #&FA
 JSR pre_colon
 LDA &71
 LDX &6F
 AND #&0F
 CLC
 ADC #&0B
 TAY
 JSR writed_5
 JSR price_spc
 LDA #&6B
 JSR punctuate
 LDA #&6D
 JSR punctuate
 JSR next_par
 JMP l_23e8

.setup_data

 LDA &6D
 AND #&07
 STA data_econ
 LDA &6E
 LSR A
 LSR A
 LSR A
 AND #&07
 STA data_govm
 LSR A
 BNE l_27bb
 LDA data_econ
 ORA #&02
 STA data_econ

.l_27bb

 LDA data_econ
 EOR #&07
 CLC
 STA data_tech
 LDA &6F
 AND #&03
 ADC data_tech
 STA data_tech
 LDA data_govm
 LSR A
 ADC data_tech
 STA data_tech
 ASL A
 ASL A
 ADC data_econ
 ADC data_govm
 ADC #&01
 STA data_popn
 LDA data_econ
 EOR #&07
 ADC #&03
 STA &1B
 LDA data_govm
 ADC #&04
 STA &81
 JSR price_mult
 LDA data_popn
 STA &81
 JSR price_mult
 ASL &1B
 ROL A
 ASL &1B
 ROL A
 ASL &1B
 ROL A
 STA data_gnp+&01
 LDA &1B
 STA data_gnp
 RTS

.long_map

 LDA #&40
 JSR clr_scrn
 LDA #&07
 STA cursor_x
 JSR copy_xy
 LDA #&C7
 JSR de_token
 JSR hline_23
 LDA #&98
 JSR hline_acc
 JSR map_range
 LDX #&00

.l_2830

 STX &84
 LDX &6F
 LDY &70
 TYA
 ORA #&50
 STA &88
 LDA &6D
 LSR A
 CLC
 ADC #&18
 STA &35
 JSR draw_pixel
 JSR permute_4
 LDX &84
 INX
 BNE l_2830
 LDA data_homex
 STA &73
 LDA data_homey
 LSR A
 STA &74
 LDA #&04
 STA &75

.map_cross

 LDA #&18
 LDX &87
 BPL l_2865
 LDA #&00

.l_2865

 STA &78
 LDA &73
 SEC
 SBC &75
 BCS l_2870
 LDA #&00

.l_2870

 STA &34
 LDA &73
 CLC
 ADC &75
 BCC l_287b
 LDA #&FF

.l_287b

 STA &36
 LDA &74
 CLC
 ADC &78
 STA &35
 JSR draw_hline
 LDA &74
 SEC
 SBC &75
 BCS l_2890
 LDA #&00

.l_2890

 CLC
 ADC &78
 STA &35
 LDA &74
 CLC
 ADC &75
 ADC &78
 CMP #&98
 BCC l_28a6
 LDX &87
 BMI l_28a6
 LDA #&97

.l_28a6

 STA &37
 LDA &73
 STA &34
 STA &36
 JMP draw_line

.short_cross

 LDA #&68
 STA &73
 LDA #&5A
 STA &74
 LDA #&10
 STA &75
 JSR map_cross
 LDA cmdr_fuel
 STA &40
 JMP map_circle

.map_range

 LDA &87
 BMI short_cross
 LDA cmdr_fuel
 LSR A
 LSR A
 STA &40
 LDA cmdr_homex
 STA &73
 LDA cmdr_homey
 LSR A
 STA &74
 LDA #&07
 STA &75
 JSR map_cross
 LDA &74
 CLC
 ADC #&18
 STA &74

.map_circle

 LDA &73
 STA &D2
 LDA &74
 STA &E0
 LDX #&00
 STX &E1
 STX &D3
 INX
 STX &6B
 INX
 STX &95
 JMP circle

.buy_cargo

 LDA #&02
 JSR clr_scrn
 JSR l_3c91
 BPL buy_ctrl
 JMP cour_buy

.buy_ctrl

 JSR price_hdr
 \	LDA #&80
 \	STA vdu_stat
 JSR vdu_80
 JSR flush_inp
 LDA #&00
 STA &03AD

.buy_loop

 JSR price_a
 LDA &03AB
 BNE l_292f
 JMP buy_next

.quant_err

 LDY #&B0

.cargo_err

 JSR price_spc
 TYA
 JSR token_query
 JSR beep_wait

.l_292f

 JSR clr_line
 LDA #&CC
 JSR de_token
 LDA &03AD
 CLC
 ADC #&D0
 JSR de_token
 LDA #&2F
 JSR de_token
 JSR price_units
 LDA #&3F
 JSR de_token
 JSR new_line
 JSR buy_quant
 BCS quant_err
 STA &1B
 JSR chk_cargo
 LDY #&CE
 BCS cargo_err
 LDA &03AA
 STA &81
 JSR price_scale
 JSR sub_money
 LDY #&C5
 BCC cargo_err
 LDY &03AD
 LDA &82
 PHA
 CLC
 ADC cmdr_cargo,Y
 STA cmdr_cargo,Y
 LDA cmdr_avail,Y
 SEC
 SBC &82
 STA cmdr_avail,Y
 PLA
 BEQ buy_next
 JSR buy_money

.buy_next

 LDA &03AD
 CLC
 ADC #&05
 STA cursor_y
 LDA #&00
 STA cursor_x
 INC &03AD
 LDA &03AD
 CMP #&11
 BCS buy_invnt
 JMP buy_loop

.buy_invnt

 LDA #&77
 JMP function

.sell_yn

 LDA #&CD
 JSR de_token
 LDA #&CE
 JSR write_msg1

.buy_quant

 LDX #&00
 STX &82
 LDX #&0C
 STX &06

.buy_repeat

 JSR get_keyy
 LDX &82
 BNE l_29c6
 CMP #&79
 BEQ buy_y
 CMP #&6E
 BEQ buy_n

.l_29c6

 STA &81
 SEC
 SBC #&30
 BCC buy_ret
 CMP #&0A
 BCS buy_invnt
 STA &83
 LDA &82
 CMP #&1A
 BCS buy_ret
 ASL A
 STA &D1
 ASL A
 ASL A
 ADC &D1
 ADC &83
 STA &82
 CMP &03AB
 BEQ l_29eb
 BCS buy_ret

.l_29eb

 LDA &81
 JSR punctuate
 DEC &06
 BNE buy_repeat

.buy_ret

 LDA &82
 RTS

.buy_y

 JSR punctuate
 LDA &03AB
 STA &82
 RTS

.buy_n

 JSR punctuate
 LDA #&00
 STA &82
 RTS

.sell_jump

 INC cursor_x
 LDA #&CF
 JSR header
 JSR new_pgph
 JSR new_line
 JSR sell_equip
 LDA cmdr_escape
 BEQ sell_escape
 LDA #&70
 LDX #&1E
 JSR status_equip

.sell_escape

 JMP start_loop

.l_2a08

 JSR new_line
 LDA #&B0
 JSR token_query
 JSR beep_wait
 LDY &03AD
 JMP l_2a37

.sell_cargo

 LDA #&04
 JSR clr_scrn
 LDA #&0A
 STA cursor_x
 JSR flush_inp
 LDA #&CD
 JSR de_token
 JSR l_3c91
 BMI sell_jump
 LDA #&CE
 JSR header
 JSR new_line

.inv_or_sell

 LDY #&00

.l_2a34

 STY &03AD

.l_2a37

 LDX cmdr_cargo,Y
 BEQ l_2aa3
 TYA
 ASL A
 ASL A
 TAY
 LDA cargo_data+&01,Y
 STA &74
 TXA
 PHA
 JSR new_pgph
 CLC
 LDA &03AD
 ADC #&D0
 JSR de_token
 LDA #&0E
 STA cursor_x
 PLA
 TAX
 STA &03AB
 CLC
 JSR writed_3
 JSR price_units
 LDA &87
 CMP #&04
 BNE l_2aa3
 JSR sell_yn
 BEQ l_2aa3
 BCS l_2a08
 LDA &03AD
 LDX #&FF
 STX vdu_stat
 JSR price_a
 LDY &03AD
 LDA cmdr_cargo,Y
 SEC
 SBC &82
 STA cmdr_cargo,Y
 LDA &82
 STA &1B
 LDA &03AA
 STA &81
 \	JSR price_scale	\--
 JSR price_mult
 JSR price_xy
 JSR add_money	\++
 JSR add_money	\++
 JSR add_money	\++
 JSR add_money
 LDA #&00
 STA vdu_stat

.l_2aa3

 LDY &03AD
 INY
 CPY #&11
 BCC l_2a34
 LDA &87
 CMP #&04
 BNE inv_quit
 JSR beep_wait
 JMP buy_invnt

.inv_quit

 RTS

.inventory

 LDA #&08
 JSR clr_scrn
 LDA #&0B
 STA cursor_x
 LDA #&A4
 JSR tok_nxtpar
 JSR hline_19
 JSR show_fuel
 LDA #&E	\ print hold size
 JSR pre_colon
 LDX new_hold
 DEX
 CLC
 JSR writed_3
 JSR price_t
 JMP inv_or_sell

.add_dirn

 TXA
 PHA
 DEY
 TYA
 EOR #&FF
 PHA
 JSR sync
 JSR map_cursor
 PLA
 STA &76
 LDA data_homey
 JSR incdec_dirn
 LDA &77
 STA data_homey
 STA &74
 PLA
 STA &76
 LDA data_homex
 JSR incdec_dirn
 LDA &77
 STA data_homex
 STA &73

.map_cursor

 LDA &87
 BMI map_shcurs
 LDA data_homex
 STA &73
 LDA data_homey
 LSR A
 STA &74
 LDA #&04
 STA &75
 JMP map_cross

.incdec_dirn

 STA &77
 CLC
 ADC &76
 LDX &76
 BMI l_2b45
 BCC l_2b47
 RTS

.l_2b45

 BCC l_2b49

.l_2b47

 STA &77

.l_2b49

 RTS

.map_shcurs

 LDA data_homex
 SEC
 SBC cmdr_homex
 CMP #&26
 BCC l_2b59
 CMP #&E6
 BCC l_2b49

.l_2b59

 ASL A
 ASL A
 CLC
 ADC #&68
 STA &73
 LDA data_homey
 SEC
 SBC cmdr_homey
 CMP #&26
 BCC l_2b6f
 CMP #&DC
 BCC l_2b49

.l_2b6f

 ASL A
 CLC
 ADC #&5A
 STA &74
 LDA #&08
 STA &75
 JMP map_cross

.short_map

 LDA #&80
 JSR clr_scrn
 LDA #&07
 STA cursor_x
 LDA #&BE
 JSR header
 JSR map_range
 JSR map_cursor
 JSR copy_xy
 LDA #&00
 STA &97
 LDX #&18

.l_2b99

 STA &46,X
 DEX
 BPL l_2b99

.short_loop

 LDA &6F
 SEC
 SBC cmdr_homex
 STA &3A
 BCS l_2baa
 EOR #&FF
 ADC #&01

.l_2baa

 CMP #&14
 BCS l_2c1e
 LDA &6D
 SEC
 SBC cmdr_homey
 STA &E0
 BCS l_2bba
 EOR #&FF
 ADC #&01

.l_2bba

 CMP #&26
 BCS l_2c1e
 LDA &3A
 ASL A
 ASL A
 ADC #&68
 STA &3A
 LSR A
 LSR A
 LSR A
 STA cursor_x
 INC cursor_x
 LDA &E0
 ASL A
 ADC #&5A
 STA &E0
 LSR A
 LSR A
 LSR A
 TAY
 LDX &46,Y
 BEQ l_2bef
 INY
 LDX &46,Y
 BEQ l_2bef
 DEY
 DEY
 LDX &46,Y
 BNE l_2c01

.l_2bef

 STY cursor_y
 CPY #&03
 BCC l_2c1e
 LDA #&FF
 STA &46,Y
 \	LDA #&80
 \	STA vdu_stat
 JSR vdu_80
 JSR write_planet

.l_2c01

 LDA #&00
 STA &D3
 STA &E1
 STA &41
 LDA &3A
 STA &D2
 LDA &71
 AND #&01
 ADC #&02
 STA &40
 JSR l_32b0
 JSR l_33cb
 JSR l_32b0

.l_2c1e

 JSR permute_4
 INC &97
 BEQ l_2c32
 JMP short_loop

.copy_xy

 LDX #&05

.l_2c2a

 LDA cmdr_gseed,X
 STA &6C,X
 DEX
 BPL l_2c2a

.l_2c32

 RTS

.snap_hype

 JSR copy_xy
 LDY #&7F
 STY &D1
 LDA #&00
 STA &80

.snap_loop

 LDA &6F
 SEC
 SBC data_homex
 BCS l_2c4a
 EOR #&FF
 ADC #&01

.l_2c4a

 LSR A
 STA &83
 LDA &6D
 SEC
 SBC data_homey
 BCS l_2c59
 EOR #&FF
 ADC #&01

.l_2c59

 LSR A
 CLC
 ADC &83
 CMP &D1
 BCS l_2c70
 STA &D1
 LDX #&05

.l_2c65

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_2c65
 LDA &80
 STA &88

.l_2c70

 JSR permute_4
 INC &80
 BNE snap_loop
 LDX #&05

.l_2c79

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_2c79
 LDA &6D
 STA data_homey
 LDA &6F
 STA data_homex
 SEC
 SBC cmdr_homex
 BCS l_2c94
 EOR #&FF
 ADC #&01

.l_2c94

 JSR square
 STA &41
 LDA &1B
 STA &40
 LDA data_homey
 SEC
 SBC cmdr_homey
 BCS l_2caa
 EOR #&FF
 ADC #&01

.l_2caa

 LSR A
 JSR square
 PHA
 LDA &1B
 CLC
 ADC &40
 STA &81
 PLA
 ADC &41
 STA &82
 JSR sqr_root
 LDA &81
 ASL A
 LDX #&00
 STX hype_dist+&01
 ROL hype_dist+&01
 ASL A
 ROL hype_dist+&01
 STA hype_dist
 JMP setup_data

.data_home

 LDA data_homex
 STA cmdr_homex
 LDA data_homey
 STA cmdr_homey
 RTS

.writed_5c

 CLC

.writed_5

 LDA #&05
 JMP writed_word

.token_query

 JSR de_token
 LDA #&3F
 JMP de_token

.price_a

 PHA
 STA &77
 ASL A
 ASL A
 STA &73
 LDA #&01
 STA cursor_x
 PLA
 ADC #&D0
 JSR de_token
 LDA #&0E
 STA cursor_x
 LDX &73
 LDA cargo_data+&01,X
 STA &74
 LDA cmdr_price
 AND cargo_data+&03,X
 CLC
 ADC cargo_data,X
 STA &03AA
 JSR price_units
 JSR mult_flag
 LDA &74
 BMI price_add
 LDA &03AA
 ADC &76
 JMP price_sto

.price_add

 LDA &03AA
 SEC
 SBC &76

.price_sto

 STA &03AA
 STA &1B
 LDA #&00
 JSR price_shift
 SEC
 JSR writed_5
 LDY &77
 LDA #&05
 LDX cmdr_avail,Y
 STX &03AB
 CLC
 BEQ price_zero
 JSR writed_byte
 JMP price_units

.price_zero

 LDA cursor_x
 ADC #&04
 STA cursor_x
 LDA #&2D
 BNE l_2e07

.price_units

 LDA &74
 AND #&60
 BEQ price_t
 CMP #&20
 BEQ price_kg
 JSR price_g

.price_spc

 LDA #&20

.l_2e07

 JMP de_token

.price_t

 LDA #&74
 JSR punctuate
 BCC price_spc

.price_kg

 LDA #&6B
 JSR punctuate

.price_g

 LDA #&67
 JMP punctuate

.price_hdr

 LDA #&11
 STA cursor_x
 LDA #&FF
 BNE l_2e07

.mark_price

 LDA #&10
 JSR clr_scrn
 LDA #&05
 STA cursor_x
 LDA #&A7
 JSR header
 LDA #&03
 STA cursor_y
 JSR price_hdr
 LDA #&00
 STA &03AD

.l_2e3d

 \	LDX #&80
 \	STX vdu_stat
 JSR vdu_80
 JSR price_a
 INC cursor_y
 INC &03AD
 LDA &03AD
 CMP #&11
 BCC l_2e3d
 RTS

.mult_flag

 LDA &74
 AND #&1F
 LDY home_econ
 STA &75
 CLC
 LDA #&00
 STA cmdr_avail+&10

.l_2e60

 DEY
 BMI l_2e68
 ADC &75
 JMP l_2e60

.l_2e68

 STA &76
 RTS

.home_setup

 JSR snap_hype
 JSR data_home
 LDX #&05

.l_2e73

 LDA &6C,X
 STA &03B2,X
 DEX
 BPL l_2e73
 INX
 STX &0349
 LDA data_econ
 STA home_econ
 LDA data_tech
 STA home_tech
 LDA data_govm
 STA home_govmt
 RTS

.encyclopedia

 LDA #'E'
 STA rdcode+4

.launch

 LDX #&3F

.l_2e94

 LDA to880,X
 STA &0880,X
 DEX
 BPL l_2e94
 LDX #LO(rdcode)
 LDY #HI(rdcode)
 JMP oscli

.sub_money

 STX &06
 LDA cmdr_money+&03
 SEC
 SBC &06
 STA cmdr_money+&03
 STY &06
 LDA cmdr_money+&02
 SBC &06
 STA cmdr_money+&02
 LDA cmdr_money+&01
 SBC #&00
 STA cmdr_money+&01
 LDA cmdr_money
 SBC #&00
 STA cmdr_money
 BCS l_2eee

.add_money

 TXA
 CLC
 ADC cmdr_money+&03
 STA cmdr_money+&03
 TYA
 ADC cmdr_money+&02
 STA cmdr_money+&02
 LDA cmdr_money+&01
 ADC #&00
 STA cmdr_money+&01
 LDA cmdr_money
 ADC #&00
 STA cmdr_money
 CLC

.l_2eee

 RTS

.price_scale

 JSR price_mult

.price_shift

 ASL &1B
 ROL A
 ASL &1B
 ROL A

.price_xy

 TAY
 LDX &1B
 RTS

.rdcode

 EQUS "R.1.F", &0D

\ a.tcode_2

.equip

 LDA #&20
 JSR clr_scrn
 JSR flush_inp
 LDA #&0C
 STA cursor_x
 LDA #&CF
 JSR spc_token
 LDA #&B9
 JSR header
 \	LDA #&80
 \	STA vdu_stat
 JSR vdu_80
 INC cursor_y
 JSR l_3c91	\ check CTRL
 BPL n_eqship
 JMP n_buyship	\ branch

.jmp_start2

 JMP start_loop

.n_eqship

 LDA home_tech
 CLC
 ADC #&02
 CMP #&0C
 BCC l_2f30
 LDA #&0E

.l_2f30

 STA &81
 STA &03AB
 INC &81
 LDA new_range
 SEC
 SBC cmdr_fuel
 ASL A
 STA equip_costs
 LDA #0
 ROL A
 STA equip_costs+1
 LDX #&01

.l_2f43

 STX &89
 JSR new_line
 LDX &89
 CLC
 JSR writed_3
 JSR price_spc
 LDA &89
 CLC
 ADC #&68
 JSR de_token
 LDA &89
 JSR equip_price
 SEC
 LDA #&19
 STA cursor_x
 LDA #&06
 JSR writed_word
 LDX &89
 INX
 CPX &81
 BCC l_2f43
 JSR clr_line
 LDA #&7F
 JSR token_query
 JSR buy_quant
 BEQ jmp_start2
 BCS jmp_start2
 SBC #&00
 LDX #&02
 STX cursor_x
 INC cursor_y
 PHA
 CMP #&02
 BCC equip_space
 LDA cmdr_cargo+&10
 SEC
 LDX #&C
 JSR tot_cargo
 BCC equip_isspace
 LDA #&0E
 JMP query_beep

.equip_isspace

 \**
 DEC new_hold	\**
 PLA
 PHA

.equip_space

 JSR equip_pay
 PLA
 BNE equip_nfuel
 LDX new_range
 STX cmdr_fuel
 JSR console
 LDA #&00

.equip_nfuel

 CMP #&01
 BNE equip_nmisl
 LDX cmdr_misl
 INX
 LDY #&7C
 CPX new_missiles
 BCS l_2fe8
 STX cmdr_misl
 JSR show_missle

.equip_nmisl

 LDY #&6B
 CMP #&02
 BNE equip_nhold
 LDX cmdr_hold
 BNE equip_gotit
 DEC cmdr_hold

.equip_nhold

 CMP #&03
 BNE equip_necm
 INY
 LDX cmdr_ecm
 BNE equip_gotit
 DEC cmdr_ecm

.equip_necm

 CMP #&04
 BNE equip_npulse
 LDY new_pulse
 BNE equip_leap

.equip_npulse

 CMP #&05
 BNE equip_nbeam
 LDY new_beam

.equip_leap

 BNE equip_frog

.equip_nbeam

 LDY #&6F
 CMP #&06
 BNE equip_nscoop
 LDX cmdr_scoop
 BEQ l_3000

.equip_gotit

 INC new_hold

.l_2fe8

 STY &40
 JSR equip_price2
 JSR add_money
 LDA &40
 JSR spc_token
 LDA #&1F
 JSR de_token

.equip_beep

 JSR beep_wait
 JMP start_loop

.l_3000

 DEC cmdr_scoop

.equip_nscoop

 INY
 CMP #&07
 BNE equip_nescape
 LDX cmdr_escape
 BNE equip_gotit
 DEC cmdr_escape

.equip_nescape

 INY
 CMP #&08
 BNE equip_nbomb
 LDX cmdr_bomb
 BNE equip_gotit
 DEC cmdr_bomb

.equip_nbomb

 INY
 CMP #&09
 BNE equip_nunit
 LDX cmdr_eunit
 BNE equip_gotit
 LDX new_energy
 STX cmdr_eunit

.equip_nunit

 INY
 CMP #&0A
 BNE equip_ndock
 LDX cmdr_dock
 BNE equip_gotit
 DEC cmdr_dock

.equip_ndock

 INY
 CMP #&0B
 BNE equip_nhype
 LDX cmdr_ghype

.equip_gfrog

 BNE equip_gotit
 DEC cmdr_ghype

.equip_nhype

 INY
 CMP #&0C
 BNE equip_nmilt
 LDY new_military

.equip_frog

 BNE equip_merge

.equip_nmilt

 INY
 CMP #&0D
 BNE equip_nmine
 LDY new_mining

.equip_merge

 PHA
 TYA
 PHA
 JSR equip_side
 PLA
 LDY cmdr_laser,X
 BEQ l_3113
 PLA
 LDY #&BB
 BNE equip_gfrog

.l_3113

 STA cmdr_laser,X
 PLA

.equip_nmine

 JSR buy_money
 JMP equip

.buy_money

 JSR price_spc
 LDA #&77
 JSR spc_token

.beep_wait

 JSR sound_20
 LDY #&32
 JMP y_sync

.equip_pay

 JSR equip_price2
 JSR sub_money
 BCS equip_quit
 LDA #&C5

.query_beep

 JSR token_query
 JMP equip_beep

.equip_price

 SEC
 SBC #&01

.equip_price2

 ASL A
 BEQ n_fcost
 ADC new_costs

.n_fcost

 TAY
 LDX equip_costs,Y
 LDA equip_costs+&01,Y
 TAY

.equip_quit

 RTS

.equip_side

 LDA home_tech
 CMP #&08
 BCC l_309f
 LDA #&20
 JSR clr_scrn

.l_309f

 LDY #&10
 STY cursor_y

.l_30a3

 LDX #&0C
 STX cursor_x
 LDA cursor_y
 CLC
 ADC #&20
 JSR spc_token
 LDA cursor_y
 CLC
 ADC #&50
 JSR de_token
 INC cursor_y
 LDA new_mounts
 ORA #&10
 CMP cursor_y
 BNE l_30a3
 JSR clr_line

.l_30c1

 LDA #&AF
 JSR token_query
 JSR get_keyy
 SEC
 SBC #&30
 CMP new_mounts
 BCC l_30d6
 JSR clr_line
 JMP l_30c1

.l_30d6

 TAX
 RTS

.snap_cursor

 JSR map_cursor
 JSR snap_hype
 JSR map_cursor
 JMP clr_line

.write_planet

 LDX #&05

.l_311b

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_311b
 LDY #&03
 BIT &6C
 BVS l_3129
 DEY

.l_3129

 STY &D1

.l_312b

 LDA &71
 AND #&1F
 BEQ l_3136
 ORA #&80
 JSR de_token

.l_3136

 JSR permute_1
 DEC &D1
 BPL l_312b
 LDX #&05

.l_313f

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_313f
 RTS

.write_cmdr

 JSR set_upprmsk
 LDY #&00

.l_314c

 LDA &1181,Y
 CMP #&0D
 BEQ l_3159
 JSR punctuate
 INY
 BNE l_314c

.l_3159

 RTS

.l_315a

 JSR l_3160
 JSR write_planet

.l_3160

 LDX #&05

.l_3162

 LDA &6C,X
 LDY &03B2,X
 STA &03B2,X
 STY &6C,X
 DEX
 BPL l_3162
 RTS

.l_3170

 CLC
 LDX cmdr_galxy
 INX
 JMP writed_3

.show_fuel

 LDA #&69
 JSR pre_colon
 LDX cmdr_fuel
 SEC
 JSR writed_3
 LDA #&C3
 JSR de_tokln
 LDA #&77
 BNE de_token

.show_money

 LDX #&03

.l_318f

 LDA cmdr_money,X
 STA &40,X
 DEX
 BPL l_318f
 LDA #&09
 STA &80
 SEC
 JSR l_1bd0
 LDA #&E2

.de_tokln

 JSR de_token
 JMP new_line

.pre_colon

 JSR de_token

.l_31aa

 LDA #&3A

.de_token

 TAX
 BEQ show_money
 BMI l_3225
 DEX
 BEQ l_3170
 DEX
 BEQ l_315a
 DEX
 BNE l_31bd
 JMP write_planet

.l_31bd

 DEX
 BEQ write_cmdr
 DEX
 BEQ show_fuel
 DEX
 \	BNE l_31cb
 \	LDA #&80
 \	STA vdu_stat
 \	RTS
 BEQ vdu_80
 \l_31cb
 DEX
 DEX
 BNE l_31d2
 EQUB &2C

.vdu_80

 LDX #&80
 STX vdu_stat
 RTS

.l_31d2

 DEX
 BEQ l_320d
 CMP #&60
 BCS l_323f
 CMP #&0E
 BCC l_31e1
 CMP #&20
 BCC l_3209

.l_31e1

 LDX vdu_stat
 BEQ l_3222
 BMI l_31f8
 BIT vdu_stat
 BVS l_321b

.l_31eb

 CMP #&41
 BCC l_31f5
 CMP #&5B
 BCS l_31f5
 ADC #&20

.l_31f5

 JMP punctuate

.l_31f8

 BIT vdu_stat
 BVS l_3213
 CMP #&41
 BCC l_3222
 PHA
 TXA
 ORA #&40
 STA vdu_stat
 PLA
 BNE l_31f5

.l_3209

 ADC #&72
 BNE l_323f

.l_320d

 LDA #&15
 STA cursor_x
 BNE l_31aa

.l_3213

 CPX #&FF
 BEQ l_327a
 CMP #&41
 BCS l_31eb

.l_321b

 PHA
 TXA
 AND #&BF
 STA vdu_stat
 PLA

.l_3222

 JMP punctuate

.l_3225

 CMP #&A0
 BCS l_323d
 AND #&7F
 ASL A
 TAY
 LDA to880,Y
 JSR de_token
 LDA to880+&01,Y
 CMP #&3F
 BEQ l_327a
 JMP de_token

.l_323d

 SBC #&A0

.l_323f

 TAX
 LDY #&00
 STY &22
 LDA #&04
 STA &23
 TXA
 BEQ l_3260

.l_324d

 LDA (&22),Y
 BEQ l_3258
 INY
 BNE l_324d
 INC &23
 BNE l_324d

.l_3258

 INY
 BNE l_325d
 INC &23

.l_325d

 DEX
 BNE l_324d

.l_3260

 TYA
 PHA
 LDA &23
 PHA
 LDA (&22),Y
 EOR #&23
 JSR de_token
 PLA
 STA &23
 PLA
 TAY
 INY
 BNE l_3276
 INC &23

.l_3276

 LDA (&22),Y
 BNE l_3260

.l_327a

 RTS

.l_3283

 LDX #&00

.l_3285

 LDA ship_type,X
 BEQ l_32a8
 BMI l_32a5
 JSR ship_ptr
 LDY #&1F

.l_3291

 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_3291
 STX &84
 LDX &84
 LDY #&1F
 LDA (&20),Y
 AND #&A7
 STA (&20),Y

.l_32a5

 INX
 BNE l_3285

.l_32a8

 LDX #&FF
 STX &0EC0
 STX &0F0E

.l_32b0

 LDY #&BF
 LDA #&00

.l_32b4

 STA &0E00,Y
 DEY
 BNE l_32b4
 DEY
 STY &0E00
 RTS

.ship_ptr

 TXA
 ASL A
 TAY
 LDA ship_addr,Y
 STA &20
 LDA ship_addr+&01,Y
 STA &21
 RTS

.ins_ship

 STA &D1
 LDX #&00

.l_32ff

 LDA ship_type,X
 BEQ l_330b
 INX
 CPX #&0C
 BCC l_32ff
 CLC

.l_330a

 RTS

.l_330b

 JSR ship_ptr
 LDA &D1
 BMI l_3362
 ASL A
 TAY
 LDA ship_data,Y
 STA &1E
 LDA ship_data+&01,Y
 STA &1F
 CPY #&04
 BEQ l_3352
 LDY #&05
 LDA (&1E),Y
 STA &06
 LDA &03B0
 SEC
 SBC &06
 STA &67
 LDA &03B1
 SBC #&00
 STA &68
 LDA &67
 SBC &20
 TAY
 LDA &68
 SBC &21
 BCC l_330a
 BNE l_3348
 CPY #&25
 BCC l_330a

.l_3348

 LDA &67
 STA &03B0
 LDA &68
 STA &03B1

.l_3352

 LDY #&0E
 LDA (&1E),Y
 STA &69
 LDY #&13
 LDA (&1E),Y
 AND #&07
 STA &65
 LDA &D1

.l_3362

 STA ship_type,X
 TAX
 BMI l_336b
 INC &031E,X

.l_336b

 LDY #&24

.l_336d

 LDA &46,Y
 STA (&20),Y
 DEY
 BPL l_336d
 SEC
 RTS

.put_missle

 TXA
 ASL A
 ASL A
 ASL A
 STA &D1
 LDA #&31-8
 SBC &D1
 STA ptr
 LDA #&7E
 STA ptr+&01
 TYA
 LDY #&05

.l_33ba

 STA (ptr),Y
 DEY
 BNE l_33ba
 RTS

.l_33c0

 TXA
 EOR #&FF
 CLC
 ADC #&01
 TAX

.l_33c7

 LDA #&FF
 BNE l_340e

.l_33cb

 LDA #&01
 STA &0E00
 JSR l_35b7
 LDA #&00
 LDX &40
 CPX #&60
 ROL A
 CPX #&28
 ROL A
 CPX #&10
 ROL A
 STA &93
 LDA #&BF
 LDX &1D
 BNE l_33f2
 CMP &1C
 BCC l_33f2
 LDA &1C
 BNE l_33f2
 LDA #&01

.l_33f2

 STA &8F
 LDA #&BF
 SEC
 SBC &E0
 TAX
 LDA #&00
 SBC &E1
 BMI l_33c0
 BNE l_340a
 INX
 DEX
 BEQ l_33c7
 CPX &40
 BCC l_340e

.l_340a

 LDX &40
 LDA #&00

.l_340e

 STX &22
 STA &23
 LDA &40
 JSR square
 STA &9C
 LDA &1B
 STA &9B
 LDY #&BF
 LDA &28
 STA &26
 LDA &29
 STA &27

.l_3427

 CPY &8F
 BEQ l_3436
 LDA &0E00,Y
 BEQ l_3433
 JSR l_1909

.l_3433

 DEY
 BNE l_3427

.l_3436

 LDA &22
 JSR square
 STA &D1
 LDA &9B
 SEC
 SBC &1B
 STA &81
 LDA &9C
 SBC &D1
 STA &82
 STY &35
 JSR sqr_root
 LDY &35
 JSR rnd_seq
 AND &93
 CLC
 ADC &81
 BCC l_345d
 LDA #&FF

.l_345d

 LDX &0E00,Y
 STA &0E00,Y
 BEQ l_34af
 LDA &28
 STA &26
 LDA &29
 STA &27
 TXA
 JSR l_3586
 LDA &34
 STA &24
 LDA &36
 STA &25
 LDA &D2
 STA &26
 LDA &D3
 STA &27
 LDA &0E00,Y
 JSR l_3586
 BCS l_3494
 LDA &36
 LDX &24
 STX &36
 STA &24
 JSR draw_hline

.l_3494

 LDA &24
 STA &34
 LDA &25
 STA &36

.l_349c

 JSR draw_hline

.l_349f

 DEY
 BEQ l_34e1
 LDA &23
 BNE l_34c3
 DEC &22
 BNE l_3436
 DEC &23

.l_34ac

 JMP l_3436

.l_34af

 LDX &D2
 STX &26
 LDX &D3
 STX &27
 JSR l_3586
 BCC l_349c
 LDA #&00
 STA &0E00,Y
 BEQ l_349f

.l_34c3

 LDX &22
 INX
 STX &22
 CPX &40
 BCC l_34ac
 BEQ l_34ac
 LDA &28
 STA &26
 LDA &29
 STA &27

.l_34d6

 LDA &0E00,Y
 BEQ l_34de
 JSR l_1909

.l_34de

 DEY
 BNE l_34d6

.l_34e1

 CLC
 LDA &D2
 STA &28
 LDA &D3
 STA &29
 RTS

.circle

 LDX #&FF
 STX &92
 INX
 STX &93

.l_3507

 LDA &93
 JSR l_21f0
 LDX #&00
 STX &D1
 LDX &93
 CPX #&21
 BCC l_3523
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 TXA
 CLC

.l_3523

 ADC &D2
 STA &76
 LDA &D3
 ADC &D1
 STA &77
 LDA &93
 CLC
 ADC #&10
 JSR l_21f0
 TAX
 LDA #&00
 STA &D1
 LDA &93
 ADC #&0F
 AND #&3F
 CMP #&21
 BCC l_3551
 TXA
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 CLC

.l_3551

 JSR l_1a16
 CMP #&41
 BCS l_355b
 JMP l_3507

.l_355b

 CLC
 RTS

.l_3586

 STA &D1
 CLC
 ADC &26
 STA &36
 LDA &27
 ADC #&00
 BMI l_35b0
 BEQ l_3599
 LDA #&FE
 STA &36

.l_3599

 LDA &26
 SEC
 SBC &D1
 STA &34
 LDA &27
 SBC #&00
 BNE l_35a8
 CLC
 RTS

.l_35a8

 BPL l_35b0
 LDA #&02
 STA &34

.l_35ae

 CLC
 RTS

.l_35b0

 LDA #&00
 STA &0E00,Y

.l_35b5

 SEC
 RTS

.l_35b7

 LDA &D2
 CLC
 ADC &40
 LDA &D3
 ADC #&00
 BMI l_35b5
 LDA &D2
 SEC
 SBC &40
 LDA &D3
 SBC #&00
 BMI l_35cf
 BNE l_35b5

.l_35cf

 LDA &E0
 CLC
 ADC &40
 STA &1C
 LDA &E1
 ADC #&00
 BMI l_35b5
 STA &1D
 LDA &E0
 SEC
 SBC &40
 TAX
 LDA &E1
 SBC #&00
 BMI l_35ae
 BNE l_35b5
 CPX #&BF
 RTS

.get_dirn

 JSR direction
 LDA k_flag
 BEQ keybd_dirn
 LDA adval_x
 EOR #&FF
 JSR adval_chop
 TYA
 TAX
 LDA adval_y

.adval_chop

 TAY
 LDA #&00
 CPY #&10
 SBC #&00
 CPY #&40
 SBC #&00
 CPY #&C0
 ADC #&00
 CPY #&E0
 ADC #&00
 TAY
 LDA last_key
 RTS

.keybd_dirn

 LDA last_key
 LDX #&00
 LDY #&00
 CMP #&19
 BNE not_lcurs
 DEX

.not_lcurs

 CMP #&79
 BNE not_rcurs
 INX

.not_rcurs

 CMP #&39
 BNE not_ucurs
 INY

.not_ucurs

 CMP #&29
 BNE not_dcurs
 DEY

.not_dcurs

 STX &D1
 LDX #&00
 JSR scan_x
 BPL not_shift
 ASL &D1
 ASL &D1
 TYA
 ASL A
 ASL A
 TAY

.not_shift

 LDX &D1
 LDA last_key
 RTS

.set_home

 LDX #&01

.l_3650

 LDA cmdr_homex,X
 STA data_homex,X
 DEX
 BPL l_3650
 RTS

.sound_tab

 EQUB &12, &01, &00, &10
 EQUB &12, &02, &2C, &08
 EQUB &11, &03, &F0, &18
 EQUB &10, &F1, &07, &1A
 EQUB &03, &F1, &BC, &01
 EQUB &13, &F4, &0C, &08
 EQUB &10, &F1, &06, &0C
 EQUB &10, &02, &60, &10
 EQUB &13, &04, &C2, &FF
 EQUB &13, &00, &00, &00

.clr_boot

 JSR clr_ships
 LDX #&06

.l_3687

 STA &2A,X
 DEX
 BPL l_3687
 TXA
 STA &8E
 LDX #&02

.l_3691

 STA f_shield,X
 DEX
 BPL l_3691

.clr_common

 LDA #&12
 STA &03C3
 LDX #&FF
 STX &0EC0
 STX &0F0E
 STX &45
 LDA #&80
 STA adval_y
 STA &32
 STA &7B
 ASL A
 STA &33
 STA &7C
 STA &8A
 LDA #&03
 STA &7D
 STA &8D
 STA &31
 LDA &30
 BEQ l_36c5
 JSR sound_0

.l_36c5

 JSR l_3283
 JSR clr_ships
 LDA #&FF
 STA &03B0
 LDA #&0C
 STA &03B1
 JSR console

.init_ship

 LDY #&24
 LDA #&00

.l_36dc

 STA &46,Y
 DEY
 BPL l_36dc
 LDA #&60
 STA &58
 STA &5C
 ORA #&80
 STA &54
 RTS

.show_missle

 LDX #&03

.l_36ef

 LDY #&00
 CPX cmdr_misl
 BCS miss_miss	\BCC l_36fd
 LDY #&EE

.miss_miss

 JSR put_missle
 DEX
 BPL l_36ef
 RTS
 \l_36fd
 \	LDY #&EE
 \	JSR put_missle
 \	DEX
 \	BPL l_36fd
 \	RTS

.l_3706

 LDA &03A4
 JSR l_3d82
 LDA #&00
 STA &034A
 JMP l_3754

.rnd_seq

 LDA &00
 ROL A
 TAX
 ADC &02
 STA &00
 STX &02
 LDA &01
 TAX
 ADC &03
 STA &01
 STX &03
 RTS

.l_374a

 DEC &034A
 BEQ l_3706
 BPL l_3754
 INC &034A

.l_3754

 DEC &8A

.repeat_fn

 LDX #&FF
 TXS
 LDY #&02
 JSR y_sync
 JSR get_dirn

.function

 JSR check_mode
 LDA &8E
 BNE repeat_fn
 JMP l_374a

.check_mode

 CMP #&76
 BNE not_status
 JMP status

.not_status

 CMP #&14
 BNE not_long
 JMP long_map

.not_long

 CMP #&74
 BNE not_short
 JMP short_map

.not_short

 CMP #&75
 BNE not_data
 JSR snap_hype
 JMP data_onsys

.not_data

 CMP #&77
 BNE not_invnt
 JMP inventory

.not_invnt

 CMP #&16
 BNE not_price
 JMP mark_price

.not_price

 CMP #&20
 BNE not_launch
 JSR l_3c91
 BMI jump_stay
 JMP launch

.jump_stay

 JMP stay_here

.not_launch

 CMP #&73
 BNE not_equip
 JMP equip

.not_equip

 CMP #&71
 BNE not_buy
 JMP buy_cargo

.not_buy

 CMP #&47
 BNE not_disk
 JSR disk_menu
 BCC not_loaded
 JMP not_loadc

.not_loaded

 JMP start_loop

.not_disk

 CMP #&72
 BNE not_sell
 JMP sell_cargo

.not_sell

 CMP #&54
 BNE not_hype
 JSR clr_line
 LDA #&0F
 STA cursor_x
 LDA #&CD
 JMP write_msg1

.not_hype

 CMP #&32
 BEQ distance
 CMP #&43
 BNE not_find
 LDA &87
 AND #&C0
 BEQ not_map
 JMP find_plant

.not_find

 STA &06
 LDA &87
 AND #&C0
 BEQ not_map
 LDA &2F
 BNE not_map
 LDA &06
 CMP #&36
 BNE not_home
 JSR map_cursor
 JSR set_home
 JSR map_cursor

.not_cour

 JSR add_dirn

.not_map

 RTS

.not_home

 CMP #&21
 BNE not_cour
 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ not_cour
 JSR map_cursor
 LDA cmdr_courx
 STA data_homex
 LDA cmdr_coury
 STA data_homey
 JSR map_cursor

.distance

 LDA &87
 AND #&C0
 BEQ not_map
 JSR snap_cursor
 STA vdu_stat
 JSR write_planet
 \	LDA #&80
 \	STA vdu_stat
 JSR vdu_80
 LDA #&01
 STA cursor_x
 INC cursor_y
 JMP show_nzdist

.err_count

 EQUB &00

.brk_go

 DEC err_count
 BNE escape
 JSR clr_common

.boot_go

 JSR set_brk
 LDX #&0A
 LDA #&00

.l_387c

 STA &03C5,X
 DEX
 BPL l_387c
 LDA #&7F	\ IN
 STA b_flag	\ IN

.stack_init

 LDX #&FF
 TXS

.escape

 LDX #&03
 STX cursor_x
 JSR fx2000
 LDX #&0B
 LDA #&06
 JSR rotate
 CMP #&44
 BNE not_loadc
 JSR copy_cmdr
 JSR disk_menu

.not_loadc

 JSR copy_cmdr
 JSR show_missle
 LDA #&07
 LDX #&13
 JSR rotate
 JSR set_home
 JSR home_setup

.start_loop

 LDA #&FF
 STA &8E
 LDA #&76
 JMP function

.copy_cmdr

 LDX #&53

.l_38bb

 LDA &1180,X
 STA &034F,X
 DEX
 BNE l_38bb
 STX &87

.l_38c6

 JSR cmdr_code
 CMP commander+&4B
 BNE l_38c6
 JMP n_load	\ load ship details

.rotate

 PHA
 STX &8C
 JSR clr_boot
 LDA #&01
 JSR clr_scrn
 DEC &87
 LDA #&60
 STA &54
 LDA #&DB
 STA &4D
 LDX #&7F
 STX &63
 STX &64
 \	INX
 \	STX vdu_stat
 JSR vdu_80
 LDA &8C
 JSR ins_ship
 LDY #&06
 STY cursor_x
 LDA #&1E
 JSR de_tokln
 LDY #&06
 STY cursor_x
 INC cursor_y
 LDA x_flag
 BEQ l_392b
 LDA #&0D
 JSR write_msg1
 INC cursor_y
 INC cursor_y
 LDA #&03
 STA cursor_x
 LDA #&72
 JSR write_msg1

.l_392b

 LDA err_count
 BEQ l_3945
 INC err_count
 LDA #&07
 STA cursor_x
 LDA #&0A
 STA cursor_y
 LDY #&00

.l_393d

 JSR oswrch
 INY
 LDA (brk_line),Y
 BNE l_393d

.l_3945

 JSR clr_line
 STY &7D
 STY k_flag
 PLA
 JSR write_msg1
 LDA #&0C
 LDX #&07
 STX cursor_x
 JSR write_msg1

.l_395a

 LDA &4D
 CMP #&01
 BEQ l_3962
 DEC &4D

.l_3962

 JSR l_14e1
 LDA #&80
 STA &4C
 ASL A
 STA &46
 STA &49
 JSR l_400f
 DEC &8A
 LDA #&51
 STA &FE60
 LDA &FE40
 AND #&10
 BEQ l_3980
 JSR scan_10
 BEQ l_395a
 RTS

.l_3980

 DEC k_flag
 RTS

.cmdr_code

 LDX #&49
 SEC
 TXA

.l_3988

 ADC &1188,X
 EOR commander,X
 DEX
 BNE l_3988
 RTS

.copy_name

 LDX #&07

.l_3994

 LDA &4B,X
 STA &1181,X
 DEX
 BPL l_3994

.l_399c

 LDX #&07

.l_399e

 LDA &1181,X
 STA &4B,X
 DEX
 BPL l_399e
 RTS

.get_fname

 LDY #&08
 JSR y_sync
 LDX #&04

.l_39ae

 LDA &117C,X
 STA &46,X
 DEX
 BPL l_39ae
 LDA #&07
 STA word_0+&02
 LDA #&08
 JSR write_msg1
 JSR get_line
 LDA #&09
 STA word_0+&02
 TYA
 BEQ l_399c
 RTS

.get_line

 LDA #&81
 STA &FE4E
 JSR flush_inp
 LDX #LO(word_0)
 LDY #HI(word_0)
 LDA #&00
 JSR osword
 BCC l_39e1
 LDY #&00

.l_39e1

 LDA #&01
 STA &FE4E
 JMP l_1c8a

.word_0

 EQUW &004B
 EQUB &09, &21, &7B

.clr_ships

 LDX #&3A
 LDA #&00

.l_39f2

 STA ship_type,X
 DEX
 BPL l_39f2
 RTS

.clr_bc

 LDX #&0C
 JSR clr_page
 DEX

.clr_page

 LDY #&00
 STY ptr

.l_3a03

 LDA #&00
 STX ptr+&01

.l_3a07

 STA (ptr),Y
 INY
 BNE l_3a07
 RTS

.cat_line

 EQUS ".:0", &0D

.del_line

 EQUS "DEL.:0.E.1234567", &0D

.show_cat

 JSR get_drive
 BCS cat_quit
 STA cat_line+&02
 STA l_1c8d+&01
 LDA #&04
 JSR write_msg1
 \	LDA &0355
 \	PHA
 LDA #&01
 STA &0355
 STA &03CF
 STA cursor_x
 LDX #LO(cat_line)
 LDY #HI(cat_line)
 JSR oscli
 DEC &03CF
 \	PLA
 LDA &1186
 STA &0355
 CLC

.cat_quit

 RTS

.disk_del

 JSR show_cat
 BCS disk_menu
 LDA cat_line+&02
 STA del_line+&05
 LDA #&09
 JSR write_msg1
 JSR get_line
 TYA
 BEQ disk_menu
 LDX #&09

.l_3a5b

 LDA &4A,X
 STA del_line+&06,X
 DEX
 BNE l_3a5b
 LDX #LO(del_line)
 LDY #HI(del_line)
 JSR oscli
 JMP disk_menu
 \l_3a6d
 \	EQUB &00

.brk_new

 LDX #&FF	\LDX l_3a6d
 TXS
 LDY #&00
 LDA #&07

.l_3a76

 JSR oswrch
 INY
 LDA (brk_line),Y
 BNE l_3a76
 BEQ l_3a83

.disk_cat

 JSR show_cat

.l_3a83

 JSR get_key

.disk_menu

 JSR clr_bc
 TSX
 STX brk_new+&01	\STX l_3a6d
 LDA #LO(brk_new)
 STA brk_in+&01
 LDA #HI(brk_new)
 STA brk_in+&02
 LDA #&01
 JSR write_msg1
 JSR get_key
 CMP #&31
 BCC disk_exit
 CMP #&34
 BEQ disk_del
 BCS disk_exit
 CMP #&32
 BCS not_dload
 LDA #&00
 JSR confirm
 BNE disk_exit
 JSR get_fname
 JSR read_file
 JSR copy_name
 SEC
 BCS l_3b15

.not_dload

 BNE disk_cat
 LDA #&FF
 JSR confirm
 BNE disk_exit
 JSR get_fname
 JSR copy_name
 LDX #&4B

.l_3acb

 LDA cmdr_mission,X
 STA &0B00,X
 STA commander,X
 DEX
 BPL l_3acb
 JSR cmdr_code
 STA commander+&4B
 STA &0B4B
 EOR #&A9
 STA commander+&4A
 STA &0B4A
 LDY #&0B
 STY &0C0B
 INY
 STY &0C0F
 LDA #&00
 JSR disk_file

.disk_exit

 CLC

.l_3b15

 JMP set_brk

.confirm

 CMP save_lock
 BEQ confirmed
 LDA #&03
 JSR write_msg1
 JSR get_key
 JSR wrchdst
 ORA #&20
 PHA
 JSR new_line
 JSR l_1c8a
 PLA
 CMP #&79

.confirmed

 RTS

.disk_file

 PHA
 JSR get_drive
 STA &47
 PLA
 BCS file_quit
 STA save_lock
 LDX #&46
 STX &0C00
 LDX #&00
 LDY #&0C
 JSR osfile
 CLC

.file_quit

 RTS

.get_drive

 LDA #&02
 JSR write_msg1
 JSR get_key
 ORA #&10
 JSR wrchdst
 PHA
 JSR l_1c8a
 PLA
 CMP #&30
 BCC bad_stat
 CMP #&34
 RTS

.read_file

 JSR clr_bc
 LDY #&0B
 STY &0C03
 INC &0C0B
 LDA #&FF
 JSR disk_file
 BCS bad_stat
 LDA &0B00
 BMI illegal
 LDX #&4B

.l_3b61

 LDA &0B00,X
 STA commander,X
 DEX
 BPL l_3b61

.bad_stat

 SEC
 RTS

.illegal

 BRK
 EQUB &49
 EQUS "Not ELITE III file"
 BRK

.fx2000

 LDY #&00
 LDA #&C8
 JMP osbyte

.l_3bd6

 LDA &34
 JSR l_21be
 STA &82
 LDA &1B
 STA &81
 LDA &35
 JSR l_21be
 STA &D1
 LDA &1B
 ADC &81
 STA &81
 LDA &D1
 ADC &82
 STA &82
 LDA &36
 JSR l_21be
 STA &D1
 LDA &1B
 ADC &81
 STA &81
 LDA &D1
 ADC &82
 STA &82
 JSR sqr_root
 LDA &34
 JSR l_3e8c
 STA &34
 LDA &35
 JSR l_3e8c
 STA &35
 LDA &36
 JSR l_3e8c
 STA &36

.l_3c1f

 RTS

.scan_10

 LDX #&10

.scan_loop

 JSR scan_x
 BMI scan_key
 INX
 BPL scan_loop
 TXA

.scan_key

 EOR #&80
 TAX
 RTS

.sound_0

 LDA #&00
 STA &30
 STA &0340
 LDA #&48
 BNE sound

.sound_20

 LDA #&20

.sound

 JSR pp_sound
 LDX s_flag
 BNE l_3c1f
 LDX #&09
 LDY #&00
 LDA #&07
 JMP osword

.pp_sound

 LSR A
 ADC #&03
 TAY
 LDX #&07

.l_3c83

 LDA #&00
 STA &09,X
 DEX
 LDA sound_tab,Y
 STA &09,X
 DEY
 DEX
 BPL l_3c83

.l_3c91

 LDX #&01

.scan_x

 LDA #&03
 SEI
 STA &FE40
 LDA #&7F
 STA &FE43
 STX &FE4F
 LDX &FE4F
 LDA #&0B
 STA &FE40
 CLI
 TXA
 RTS

.adval

 LDA #&80
 JSR osbyte
 TYA
 EOR j_flag
 RTS

.tog_flag

 STY &D1
 CPX &D1
 BNE tog_end
 LDA &0387,X
 EOR #&FF
 STA &0387,X
 JSR bell
 JSR y_sync
 LDY &D1

.tog_end

 RTS

.direction

 LDA k_flag
 BEQ spec_key
 LDX #&01
 JSR adval
 ORA #&01
 STA adval_x
 LDX #&02
 JSR adval
 EOR y_flag
 STA adval_y

.spec_key

 JSR scan_10
 STX last_key
 CPX #&69
 BNE no_freeze

.no_thaw

 JSR sync
 JSR scan_10
 CPX #&51
 BNE not_sound
 LDA #&00
 STA s_flag

.not_sound

 LDY #&40

.flag_loop

 JSR tog_flag
 INY
 \	CPY #&47
 CPY #&48
 BNE flag_loop
 CPX #&10
 BNE not_quiet
 STX s_flag

.not_quiet

 CPX #&70
 BNE not_escape
 JMP escape

.not_escape

 CPX #&59
 BNE no_thaw

.no_freeze

 LDA &87
 BNE frz_ret
 LDY #&10
 LDA #&FF
 RTS

.get_keyy

 STY &85

.get_key

 LDY #&02
 JSR y_sync
 JSR scan_10
 BNE get_key

.press

 JSR scan_10
 BEQ press
 TAY
 LDA (key_table),Y
 LDY &85
 TAX

.frz_ret

 RTS

.l_3d77

 STX &034A
 PHA
 LDA &03A4
 JSR l_3d99
 PLA

.l_3d82

 LDX #&00
 STX vdu_stat
 LDY #&09
 STY cursor_x
 LDY #&16
 STY cursor_y
 CPX &034A
 BNE l_3d77
 STY &034A
 STA &03A4

.l_3d99

 JSR de_token
 LSR &034B
 BEQ frz_ret
 LDA #&FD
 JMP de_token

.cargo_data

 EQUB &13, &82, &06, &01
 EQUB &14, &81, &0A, &03
 EQUB &41, &83, &02, &07
 EQUB &28, &85, &E2, &1F
 EQUB &53, &85, &FB, &0F
 EQUB &C4, &08, &36, &03
 EQUB &EB, &1D, &08, &78
 EQUB &9A, &0E, &38, &03
 EQUB &75, &06, &28, &07
 EQUB &4E, &01, &11, &1F
 EQUB &7C, &0D, &1D, &07
 EQUB &B0, &89, &DC, &3F
 EQUB &20, &81, &35, &03
 EQUB &61, &A1, &42, &07
 EQUB &AB, &A2, &37, &1F
 EQUB &2D, &C1, &FA, &0F
 EQUB &35, &0F, &C0, &07

.l_3dea

 TYA
 LDY #&02
 JSR l_3eb9
 STA &5A
 JMP l_3e32

.l_3df5

 TAX
 LDA &35
 AND #&60
 BEQ l_3dea
 LDA #&02
 JSR l_3eb9
 STA &58
 JMP l_3e32

.l_3e06

 LDA &50
 STA &34
 LDA &52
 STA &35
 LDA &54
 STA &36
 JSR l_3bd6
 LDA &34
 STA &50
 LDA &35
 STA &52
 LDA &36
 STA &54
 LDY #&04
 LDA &34
 AND #&60
 BEQ l_3df5
 LDX #&02
 LDA #&00
 JSR l_3eb9
 STA &56

.l_3e32

 LDA &56
 STA &34
 LDA &58
 STA &35
 LDA &5A
 STA &36
 JSR l_3bd6
 LDA &34
 STA &56
 LDA &35
 STA &58
 LDA &36
 STA &5A
 LDA &52
 STA &81
 LDA &5A
 JSR l_2287
 LDX &54
 LDA &58
 JSR l_22ec
 EOR #&80
 STA &5C
 LDA &56
 JSR l_2287
 LDX &50
 LDA &5A
 JSR l_22ec
 EOR #&80
 STA &5E
 LDA &58
 JSR l_2287
 LDX &52
 LDA &56
 JSR l_22ec
 EOR #&80
 STA &60
 LDA #&00
 LDX #&0E

.l_3e85

 STA &4F,X
 DEX
 DEX
 BPL l_3e85
 RTS

.l_3e8c

 TAY
 AND #&7F
 CMP &81
 BCS l_3eb3
 LDX #&FE
 STX &D1

.l_3e97

 ASL A
 CMP &81
 BCC l_3e9e
 SBC &81

.l_3e9e

 ROL &D1
 BCS l_3e97
 LDA &D1
 LSR A
 LSR A
 STA &D1
 LSR A
 ADC &D1
 STA &D1
 TYA
 AND #&80
 ORA &D1
 RTS

.l_3eb3

 TYA
 AND #&80
 ORA #&60
 RTS

.l_3eb9

 STA &1D
 LDA &50,X
 STA &81
 LDA &56,X
 JSR l_2287
 LDX &50,Y
 STX &81
 LDA &56,Y
 JSR l_22ad
 STX &1B
 LDY &1D
 LDX &50,Y
 STX &81
 EOR #&80
 STA &1C
 EOR &81
 AND #&80
 STA &D1
 LDA #&00
 LDX #&10
 ASL &1B
 ROL &1C
 ASL &81
 LSR &81

.l_3eec

 ROL A
 CMP &81
 BCC l_3ef3
 SBC &81

.l_3ef3

 ROL &1B
 ROL &1C
 DEX
 BNE l_3eec
 LDA &1B
 ORA &D1
 RTS

.l_3eff

 JSR l_4059
 LDA #&60
 CMP #&BE
 BCS l_3f23
 LDY #&02
 JSR l_3f2a
 LDY #&06
 LDA #&60
 ADC #&01
 JSR l_3f2a
 LDA #&08
 ORA &65
 STA &65
 LDA #&08
 JMP l_46ef

.l_3f21

 PLA
 PLA

.l_3f23

 LDA #&F7
 AND &65
 STA &65
 RTS

.l_3f2a

 STA (&67),Y
 INY
 INY
 STA (&67),Y
 LDA #&80
 DEY
 STA (&67),Y
 ADC #&03
 BCS l_3f21
 DEY
 DEY
 STA (&67),Y
 RTS

.sqr_root

 LDY &82
 LDA &81
 STA &83
 LDX #&00
 STX &81
 LDA #&08
 STA &D1

.l_3f4c

 CPX &81
 BCC l_3f5e
 BNE l_3f56
 CPY #&40
 BCC l_3f5e

.l_3f56

 TYA
 SBC #&40
 TAY
 TXA
 SBC &81
 TAX

.l_3f5e

 ROL &81
 ASL &83
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 ASL &83
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 DEC &D1
 BNE l_3f4c
 RTS

.l_3f75

 CMP &81
 BCS l_3f93

.l_3f79

 LDX #&FE
 STX &82

.l_3f7d

 ASL A
 BCS l_3f8b
 CMP &81
 BCC l_3f86
 SBC &81

.l_3f86

 ROL &82
 BCS l_3f7d
 RTS

.l_3f8b

 SBC &81
 SEC
 ROL &82
 BCS l_3f7d
 RTS

.l_3f93

 LDA #&FF
 STA &82
 RTS

.l_3f98

 EOR &83
 BMI l_3fa2
 LDA &81
 CLC
 ADC &82
 RTS

.l_3fa2

 LDA &82
 SEC
 SBC &81
 BCC l_3fab
 CLC
 RTS

.l_3fab

 PHA
 LDA &83
 EOR #&80
 STA &83
 PLA
 EOR #&FF
 ADC #&01
 RTS

.l_3fb8

 LDX #&00
 LDY #&00

.l_3fbc

 LDA &34
 STA &81
 LDA &09,X
 JSR l_21fa
 STA &D1
 LDA &35
 EOR &0A,X
 STA &83
 LDA &36
 STA &81
 LDA &0B,X
 JSR l_21fa
 STA &81
 LDA &D1
 STA &82
 LDA &37
 EOR &0C,X
 JSR l_3f98
 STA &D1
 LDA &38
 STA &81
 LDA &0D,X
 JSR l_21fa
 STA &81
 LDA &D1
 STA &82
 LDA &39
 EOR &0E,X
 JSR l_3f98
 STA &3A,Y
 LDA &83
 STA &3B,Y
 INY
 INY
 TXA
 CLC
 ADC #&06
 TAX
 CMP #&11
 BCC l_3fbc
 RTS

.l_400f

 LDA #&1F
 STA &96
 LDA #&20
 BIT &65
 BNE l_4046
 BPL l_4046
 ORA &65
 AND #&3F
 STA &65
 LDA #&00
 LDY #&1C
 STA (&20),Y
 LDY #&1E
 STA (&20),Y
 JSR l_4059
 LDY #&01
 LDA #&12
 STA (&67),Y
 LDY #&07
 LDA (&1E),Y
 LDY #&02
 STA (&67),Y

.l_403c

 INY
 JSR rnd_seq
 STA (&67),Y
 CPY #&06
 BNE l_403c

.l_4046

 LDA &4E
 BPL l_4067

.l_404a

 LDA &65
 AND #&20
 BEQ l_4059
 LDA &65
 AND #&F7
 STA &65
 JMP l_327a

.l_4059

 LDA #&08
 BIT &65
 BEQ l_4066
 EOR &65
 STA &65
 JMP l_46f3

.l_4066

 RTS

.l_4067

 LDA &4D
 CMP #&C0
 BCS l_404a
 LDA &46
 CMP &4C
 LDA &47
 SBC &4D
 BCS l_404a
 LDA &49
 CMP &4C
 LDA &4A
 SBC &4D
 BCS l_404a
 LDY #&06
 LDA (&1E),Y
 TAX
 LDA #&FF
 STA &0100,X
 STA &0101,X
 LDA &4C
 STA &D1
 LDA &4D
 LSR A
 ROR &D1
 LSR A
 ROR &D1
 LSR A
 ROR &D1
 LSR A
 BNE l_40aa
 LDA &D1
 ROR A
 LSR A
 LSR A
 LSR A
 STA &96
 BPL l_40bb

.l_40aa

 LDY #&0D
 LDA (&1E),Y
 CMP &4D
 BCS l_40bb
 LDA #&20
 AND &65
 BNE l_40bb
 JMP l_3eff

.l_40bb

 LDX #&05

.l_40bd

 LDA &5B,X
 STA &09,X
 LDA &55,X
 STA &0F,X
 LDA &4F,X
 STA &15,X
 DEX
 BPL l_40bd
 LDA #&C5
 STA &81
 LDY #&10

.l_40d2

 LDA &09,Y
 ASL A
 LDA &0A,Y
 ROL A
 JSR l_3f75
 LDX &82
 STX &09,Y
 DEY
 DEY
 BPL l_40d2
 LDX #&08

.l_40e7

 LDA &46,X
 STA vdu_stat,X
 DEX
 BPL l_40e7
 LDA #&FF
 STA &E1
 LDY #&0C
 LDA &65
 AND #&20
 BEQ l_410c
 LDA (&1E),Y
 LSR A
 LSR A
 TAX
 LDA #&FF

.l_4101

 STA &D2,X
 DEX
 BPL l_4101
 INX
 STX &96

.l_4109

 JMP l_427f

.l_410c

 LDA (&1E),Y
 BEQ l_4109
 STA &97
 LDY #&12
 LDA (&1E),Y
 TAX
 LDA &79
 TAY
 BEQ l_412b

.l_411c

 INX
 LSR &76
 ROR &75
 LSR &73
 ROR vdu_stat
 LSR A
 ROR &78
 TAY
 BNE l_411c

.l_412b

 STX &86
 LDA &7A
 STA &39
 LDA vdu_stat
 STA &34
 LDA &74
 STA &35
 LDA &75
 STA &36
 LDA &77
 STA &37
 LDA &78
 STA &38
 JSR l_3fb8
 LDA &3A
 STA vdu_stat
 LDA &3B
 STA &74
 LDA &3C
 STA &75
 LDA &3D
 STA &77
 LDA &3E
 STA &78
 LDA &3F
 STA &7A
 LDY #&04
 LDA (&1E),Y
 CLC
 ADC &1E
 STA &22
 LDY #&11
 LDA (&1E),Y
 ADC &1F
 STA &23
 LDY #&00

.l_4173

 LDA (&22),Y
 STA &3B
 AND #&1F
 CMP &96
 BCS l_418c
 TYA
 LSR A
 LSR A
 TAX
 LDA #&FF
 STA &D2,X
 TYA
 ADC #&04
 TAY
 JMP l_4278

.l_418c

 LDA &3B
 ASL A
 STA &3D
 ASL A
 STA &3F
 INY
 LDA (&22),Y
 STA &3A
 INY
 LDA (&22),Y
 STA &3C
 INY
 LDA (&22),Y
 STA &3E
 LDX &86
 CPX #&04
 BCC l_41cc
 LDA vdu_stat
 STA &34
 LDA &74
 STA &35
 LDA &75
 STA &36
 LDA &77
 STA &37
 LDA &78
 STA &38
 LDA &7A
 STA &39
 JMP l_422a

.l_41c4

 LSR vdu_stat
 LSR &78
 LSR &75
 LDX #&01

.l_41cc

 LDA &3A
 STA &34
 LDA &3C
 STA &36
 LDA &3E
 DEX
 BMI l_41e1

.l_41d9

 LSR &34
 LSR &36
 LSR A
 DEX
 BPL l_41d9

.l_41e1

 STA &82
 LDA &3F
 STA &83
 LDA &78
 STA &81
 LDA &7A
 JSR l_3f98
 BCS l_41c4
 STA &38
 LDA &83
 STA &39
 LDA &34
 STA &82
 LDA &3B
 STA &83
 LDA vdu_stat
 STA &81
 LDA &74
 JSR l_3f98
 BCS l_41c4
 STA &34
 LDA &83
 STA &35
 LDA &36
 STA &82
 LDA &3D
 STA &83
 LDA &75
 STA &81
 LDA &77
 JSR l_3f98
 BCS l_41c4
 STA &36
 LDA &83
 STA &37

.l_422a

 LDA &3A
 STA &81
 LDA &34
 JSR l_21fa
 STA &D1
 LDA &3B
 EOR &35
 STA &83
 LDA &3C
 STA &81
 LDA &36
 JSR l_21fa
 STA &81
 LDA &D1
 STA &82
 LDA &3D
 EOR &37
 JSR l_3f98
 STA &D1
 LDA &3E
 STA &81
 LDA &38
 JSR l_21fa
 STA &81
 LDA &D1
 STA &82
 LDA &39
 EOR &3F
 JSR l_3f98
 PHA
 TYA
 LSR A
 LSR A
 TAX
 PLA
 BIT &83
 BMI l_4275
 LDA #&00

.l_4275

 STA &D2,X
 INY

.l_4278

 CPY &97
 BCS l_427f
 JMP l_4173

.l_427f

 LDY &0B
 LDX &0C
 LDA &0F
 STA &0B
 LDA &10
 STA &0C
 STY &0F
 STX &10
 LDY &0D
 LDX &0E
 LDA &15
 STA &0D
 LDA &16
 STA &0E
 STY &15
 STX &16
 LDY &13
 LDX &14
 LDA &17
 STA &13
 LDA &18
 STA &14
 STY &17
 STX &18
 LDY #&08
 LDA (&1E),Y
 STA &97
 LDA &1E
 CLC
 ADC #&14
 STA &22
 LDA &1F
 ADC #&00
 STA &23
 LDY #&00
 STY &93

.l_42c6

 STY &86
 LDA (&22),Y
 STA &34
 INY
 LDA (&22),Y
 STA &36
 INY
 LDA (&22),Y
 STA &38
 INY
 LDA (&22),Y
 STA &D1
 AND #&1F
 CMP &96
 BCC l_430f
 INY
 LDA (&22),Y
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_4312
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_4312
 INY
 LDA (&22),Y
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_4312
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_4312

.l_430f

 JMP l_4487

.l_4312

 LDA &D1
 STA &35
 ASL A
 STA &37
 ASL A
 STA &39
 JSR l_3fb8
 LDA &48
 STA &36
 EOR &3B
 BMI l_4337
 CLC
 LDA &3A
 ADC &46
 STA &34
 LDA &47
 ADC #&00
 STA &35
 JMP l_435a

.l_4337

 LDA &46
 SEC
 SBC &3A
 STA &34
 LDA &47
 SBC #&00
 STA &35
 BCS l_435a
 EOR #&FF
 STA &35
 LDA #&01
 SBC &34
 STA &34
 BCC l_4354
 INC &35

.l_4354

 LDA &36
 EOR #&80
 STA &36

.l_435a

 LDA &4B
 STA &39
 EOR &3D
 BMI l_4372
 CLC
 LDA &3C
 ADC &49
 STA &37
 LDA &4A
 ADC #&00
 STA &38
 JMP l_4397

.l_4372

 LDA &49
 SEC
 SBC &3C
 STA &37
 LDA &4A
 SBC #&00
 STA &38
 BCS l_4397
 EOR #&FF
 STA &38
 LDA &37
 EOR #&FF
 ADC #&01
 STA &37
 LDA &39
 EOR #&80
 STA &39
 BCC l_4397
 INC &38

.l_4397

 LDA &3F
 BMI l_43e5
 LDA &3E
 CLC
 ADC &4C
 STA &D1
 LDA &4D
 ADC #&00
 STA &80
 JMP l_4404

.l_43ab

 LDX &81
 BEQ l_43cb
 LDX #&00

.l_43b1

 LSR A
 INX
 CMP &81
 BCS l_43b1
 STX &83
 JSR l_3f75
 LDX &83
 LDA &82

.l_43c0

 ASL A
 ROL &80
 BMI l_43cb
 DEX
 BNE l_43c0
 STA &82
 RTS

.l_43cb

 LDA #&32
 STA &82
 STA &80
 RTS

.l_43d2

 LDA #&80
 SEC
 SBC &82
 STA &0100,X
 INX
 LDA #&00
 SBC &80
 STA &0100,X
 JMP l_4444

.l_43e5

 LDA &4C
 SEC
 SBC &3E
 STA &D1
 LDA &4D
 SBC #&00
 STA &80
 BCC l_43fc
 BNE l_4404
 LDA &D1
 CMP #&04
 BCS l_4404

.l_43fc

 LDA #&00
 STA &80
 LDA #&04
 STA &D1

.l_4404

 LDA &80
 ORA &35
 ORA &38
 BEQ l_441b
 LSR &35
 ROR &34
 LSR &38
 ROR &37
 LSR &80
 ROR &D1
 JMP l_4404

.l_441b

 LDA &D1
 STA &81
 LDA &34
 CMP &81
 BCC l_442b
 JSR l_43ab
 JMP l_442e

.l_442b

 JSR l_3f75

.l_442e

 LDX &93
 LDA &36
 BMI l_43d2
 LDA &82
 CLC
 ADC #&80
 STA &0100,X
 INX
 LDA &80
 ADC #&00
 STA &0100,X

.l_4444

 TXA
 PHA
 LDA #&00
 STA &80
 LDA &D1
 STA &81
 LDA &37
 CMP &81
 BCC l_446d
 JSR l_43ab
 JMP l_4470

.l_445a

 LDA #&60
 CLC
 ADC &82
 STA &0100,X
 INX
 LDA #&00
 ADC &80
 STA &0100,X
 JMP l_4487

.l_446d

 JSR l_3f75

.l_4470

 PLA
 TAX
 INX
 LDA &39
 BMI l_445a
 LDA #&60
 SEC
 SBC &82
 STA &0100,X
 INX
 LDA #&00
 SBC &80
 STA &0100,X

.l_4487

 CLC
 LDA &93
 ADC #&04
 STA &93
 LDA &86
 ADC #&06
 TAY
 BCS l_449c
 CMP &97
 BCS l_449c
 JMP l_42c6

.l_449c

 LDA &65
 AND #&20
 BEQ l_44ab
 LDA &65
 ORA #&08
 STA &65
 JMP l_327a

.l_44ab

 LDA #&08
 BIT &65
 BEQ l_44b6
 JSR l_46f3
 LDA #&08

.l_44b6

 ORA &65
 STA &65
 LDY #&09
 LDA (&1E),Y
 STA &97
 LDY #&00
 STY &80
 STY &86
 INC &80
 BIT &65
 BVC l_4520
 LDA &65
 AND #&BF
 STA &65
 LDY #&06
 LDA (&1E),Y
 TAY
 LDX &0100,Y
 STX &34
 INX
 BEQ l_4520
 LDX &0101,Y
 STX &35
 INX
 BEQ l_4520
 LDX &0102,Y
 STX &36
 LDX &0103,Y
 STX &37
 LDA #&00
 STA &38
 STA &39
 STA &3B
 LDA &4C
 STA &3A
 LDA &48
 BPL l_4503
 DEC &38

.l_4503

 JSR l_4594
 BCS l_4520
 LDY &80
 LDA &34
 STA (&67),Y
 INY
 LDA &35
 STA (&67),Y
 INY
 LDA &36
 STA (&67),Y
 INY
 LDA &37
 STA (&67),Y
 INY
 STY &80

.l_4520

 LDY #&03
 CLC
 LDA (&1E),Y
 ADC &1E
 STA &22
 LDY #&10
 LDA (&1E),Y
 ADC &1F
 STA &23
 LDY #&05
 LDA (&1E),Y
 STA &06
 LDY &86

.l_4539

 LDA (&22),Y
 CMP &96
 BCC l_4557
 INY
 LDA (&22),Y
 INY
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_455a
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_455a

.l_4557

 JMP l_46d6

.l_455a

 LDA (&22),Y
 TAX
 INY
 LDA (&22),Y
 STA &81
 LDA &0101,X
 STA &35
 LDA &0100,X
 STA &34
 LDA &0102,X
 STA &36
 LDA &0103,X
 STA &37
 LDX &81
 LDA &0100,X
 STA &38
 LDA &0103,X
 STA &3B
 LDA &0102,X
 STA &3A
 LDA &0101,X
 STA &39
 JSR l_459a
 BCS l_4557
 JMP l_46ba

.l_4594

 LDA #&00
 STA &90
 LDA &39

.l_459a

 LDX #&BF
 ORA &3B
 BNE l_45a6
 CPX &3A
 BCC l_45a6
 LDX #&00

.l_45a6

 STX &89
 LDA &35
 ORA &37
 BNE l_45ca
 LDA #&BF
 CMP &36
 BCC l_45ca
 LDA &89
 BNE l_45c8

.l_45b8

 LDA &36
 STA &35
 LDA &38
 STA &36
 LDA &3A
 STA &37
 CLC
 RTS

.l_45c6

 SEC
 RTS

.l_45c8

 LSR &89

.l_45ca

 LDA &89
 BPL l_45fd
 LDA &35
 AND &39
 BMI l_45c6
 LDA &37
 AND &3B
 BMI l_45c6
 LDX &35
 DEX
 TXA
 LDX &39
 DEX
 STX &3C
 ORA &3C
 BPL l_45c6
 LDA &36
 CMP #&C0
 LDA &37
 SBC #&00
 STA &3C
 LDA &3A
 CMP #&C0
 LDA &3B
 SBC #&00
 ORA &3C
 BPL l_45c6

.l_45fd

 TYA
 PHA
 LDA &38
 SEC
 SBC &34
 STA &3C
 LDA &39
 SBC &35
 STA &3D
 LDA &3A
 SEC
 SBC &36
 STA &3E
 LDA &3B
 SBC &37
 STA &3F
 EOR &3D
 STA &83
 LDA &3F
 BPL l_462e
 LDA #&00
 SEC
 SBC &3E
 STA &3E
 LDA #&00
 SBC &3F
 STA &3F

.l_462e

 LDA &3D
 BPL l_463d
 SEC
 LDA #&00
 SBC &3C
 STA &3C
 LDA #&00
 SBC &3D

.l_463d

 TAX
 BNE l_4644
 LDX &3F
 BEQ l_464e

.l_4644

 LSR A
 ROR &3C
 LSR &3F
 ROR &3E
 JMP l_463d

.l_464e

 STX &D1
 LDA &3C
 CMP &3E
 BCC l_4660
 STA &81
 LDA &3E
 JSR l_3f75
 JMP l_466b

.l_4660

 LDA &3E
 STA &81
 LDA &3C
 JSR l_3f75
 DEC &D1

.l_466b

 LDA &82
 STA &3C
 LDA &83
 STA &3D
 LDA &89
 BEQ l_4679
 BPL l_468c

.l_4679

 JSR l_471a
 LDA &89
 BPL l_46b1
 LDA &35
 ORA &37
 BNE l_46b6
 LDA &36
 CMP #&C0
 BCS l_46b6

.l_468c

 LDX &34
 LDA &38
 STA &34
 STX &38
 LDA &39
 LDX &35
 STX &39
 STA &35
 LDX &36
 LDA &3A
 STA &36
 STX &3A
 LDA &3B
 LDX &37
 STX &3B
 STA &37
 JSR l_471a
 DEC &90

.l_46b1

 PLA
 TAY
 JMP l_45b8

.l_46b6

 PLA
 TAY
 SEC
 RTS

.l_46ba

 LDY &80
 LDA &34
 STA (&67),Y
 INY
 LDA &35
 STA (&67),Y
 INY
 LDA &36
 STA (&67),Y
 INY
 LDA &37
 STA (&67),Y
 INY
 STY &80
 CPY &06
 BCS l_46ed

.l_46d6

 INC &86
 LDY &86
 CPY &97
 BCS l_46ed
 LDY #&00
 LDA &22
 ADC #&04
 STA &22
 BCC l_46ea
 INC &23

.l_46ea

 JMP l_4539

.l_46ed

 LDA &80

.l_46ef

 LDY #&00
 STA (&67),Y

.l_46f3

 LDY #&00
 LDA (&67),Y
 STA &97
 CMP #&04
 BCC l_4719
 INY

.l_46fe

 LDA (&67),Y
 STA &34
 INY
 LDA (&67),Y
 STA &35
 INY
 LDA (&67),Y
 STA &36
 INY
 LDA (&67),Y
 STA &37
 JSR draw_line
 INY
 CPY &97
 BCC l_46fe

.l_4719

 RTS

.l_471a

 LDA &35
 BPL l_4735
 STA &83
 JSR l_4794
 TXA
 CLC
 ADC &36
 STA &36
 TYA
 ADC &37
 STA &37
 LDA #&00
 STA &34
 STA &35
 TAX

.l_4735

 BEQ l_4750
 STA &83
 DEC &83
 JSR l_4794
 TXA
 CLC
 ADC &36
 STA &36
 TYA
 ADC &37
 STA &37
 LDX #&FF
 STX &34
 INX
 STX &35

.l_4750

 LDA &37
 BPL l_476e
 STA &83
 LDA &36
 STA &82
 JSR l_47c3
 TXA
 CLC
 ADC &34
 STA &34
 TYA
 ADC &35
 STA &35
 LDA #&00
 STA &36
 STA &37

.l_476e

 LDA &36
 SEC
 SBC #&C0
 STA &82
 LDA &37
 SBC #&00
 STA &83
 BCC l_4793
 JSR l_47c3
 TXA
 CLC
 ADC &34
 STA &34
 TYA
 ADC &35
 STA &35
 LDA #&BF
 STA &36
 LDA #&00
 STA &37

.l_4793

 RTS

.l_4794

 LDA &34
 STA &82
 JSR l_47ff
 PHA
 LDX &D1
 BNE l_47cb

.l_47a0

 LDA #&00
 TAX
 TAY
 LSR &83
 ROR &82
 ASL &81
 BCC l_47b5

.l_47ac

 TXA
 CLC
 ADC &82
 TAX
 TYA
 ADC &83
 TAY

.l_47b5

 LSR &83
 ROR &82
 ASL &81
 BCS l_47ac
 BNE l_47b5
 PLA
 BPL l_47f2
 RTS

.l_47c3

 JSR l_47ff
 PHA
 LDX &D1
 BNE l_47a0

.l_47cb

 LDA #&FF
 TAY
 ASL A
 TAX

.l_47d0

 ASL &82
 ROL &83
 LDA &83
 BCS l_47dc
 CMP &81
 BCC l_47e7

.l_47dc

 SBC &81
 STA &83
 LDA &82
 SBC #&00
 STA &82
 SEC

.l_47e7

 TXA
 ROL A
 TAX
 TYA
 ROL A
 TAY
 BCS l_47d0
 PLA
 BMI l_47fe

.l_47f2

 TXA
 EOR #&FF
 ADC #&01
 TAX
 TYA
 EOR #&FF
 ADC #&00
 TAY

.l_47fe

 RTS

.l_47ff

 LDX &3C
 STX &81
 LDA &83
 BPL l_4818
 LDA #&00
 SEC
 SBC &82
 STA &82
 LDA &83
 PHA
 EOR #&FF
 ADC #&00
 STA &83
 PLA

.l_4818

 EOR &3D
 RTS
 \ additions start here

.n_buyship

 LDX #&00
 SEC
 LDA #&0F	\LDA #&0D
 SBC home_econ
 SBC home_econ	\++
 STA &03AB

.n_bloop

 STX &89
 JSR new_line
 LDX &89
 INX
 CLC
 JSR writed_3
 JSR price_spc
 LDY &89
 JSR n_name
 LDY &89
 JSR n_price
 LDA #&16
 STA cursor_x
 LDA #&09
 STA &80
 SEC
 JSR l_1bd0
 LDX &89
 INX
 CPX &03AB
 BCC n_bloop
 JSR clr_line
 LDA #&B9
 JSR token_query
 JSR buy_quant
 BEQ jmp_start3
 BCS jmp_start3
 SBC #&00
 CMP &03AB
 BCS jmp_start3
 LDX #&02
 STX cursor_x
 INC cursor_y
 STA &81
 LDY new_type
 JSR n_price
 CLC
 LDX #3

.n_addl

 LDA cmdr_money,X
 ADC &40,X
 STA &09,X
 DEX
 BPL n_addl
 LDY &81
 JSR n_price
 SEC
 LDX #3

.n_subl

 LDA &09,X
 SBC &40,X
 STA &40,X
 DEX
 BPL n_subl
 LDA &81
 BCS n_buy

.cash_query

 LDA #&C5
 JSR token_query

.jmp_start3

 JSR beep_wait
 JMP start_loop

.n_buy

 TAX
 LDY #3

.n_cpyl

 LDA &40,Y
 STA cmdr_money,Y
 DEY
 BPL n_cpyl
 LDA #&00
 LDY #&24

.n_wipe

 STA &0368,Y
 DEY
 BPL n_wipe
 STX new_type
 JSR n_load
 LDA new_range
 STA cmdr_fuel
 JSR show_missle
 JMP start_loop

.n_load

 LDY new_type
 LDX new_offsets,Y
 LDY #0

.n_lname

 CPY #9
 BCS n_linfo
 LDA new_ships,X
 EOR #&23
 STA new_name,Y

.n_linfo

 LDA new_details,X
 STA new_pulse,Y
 INX
 INY
 CPY #13
 BNE n_lname
 LDA new_max
 EOR #&FE
 STA new_min
 LDY #&0B

.count_lasers

 LDX count_offs,Y
 LDA cmdr_laser,X
 BEQ count_sys
 DEC new_hold	\**

.count_sys

 DEY
 BPL count_lasers
 RTS

.count_offs

 EQUB &00, &01, &02, &03, &06, &18, &19, &1A, &1B, &1C, &1D, &1E

.n_name

 \ name ship in 0 <= Y <= &C
 LDX new_offsets,Y
 LDA #9
 STA &41

.n_lprint

 LDA new_ships,X
 STX &40
 JSR de_token
 LDX &40
 INX
 DEC &41
 BNE n_lprint
 RTS

.n_price

 \ put price 0 <= Y <= &C into 40-43
 LDX new_offsets,Y
 LDY #3

.n_lprice

 LDA new_price,X
 STA &40,Y
 INX
 DEY
 BPL n_lprice
 RTS

.cour_buy

 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ cour_start
 JMP jmp_start3

.cour_start

 LDA #&0A
 STA cursor_x
 LDA #&6F
 JSR write_msg1
 JSR hline_19
 \	LDA #&80
 \	STA vdu_stat
 JSR vdu_80
 LDA cmdr_price
 EOR cmdr_homex
 EOR cmdr_homey
 EOR cmdr_legal
 EOR cmdr_kills
 STA &46
 SEC
 LDA cmdr_legal
 ADC cmdr_galxy
 ADC cmdr_ship
 STA &47
 ADC &46
 SBC cmdr_courx
 SBC cmdr_coury
 AND #&0F
 STA &03AB
 BEQ cour_pres
 LDA #&00
 STA &49
 STA &4C
 JSR copy_xy

.cour_loop

 LDA &49
 CMP &03AB
 BCC cour_count

.cour_menu

 JSR clr_line
 LDA #&CE
 JSR token_query
 JSR buy_quant
 BEQ cour_pres
 BCS cour_pres
 TAX
 DEX
 CPX &49
 BCS cour_pres
 LDA #&02
 STA cursor_x
 INC cursor_y
 STX &46
 LDY &0C50,X
 LDA &0C40,X
 TAX
 JSR sub_money
 BCS cour_cash
 JMP cash_query

.cour_cash

 LDX &46
 LDA &0C00,X
 STA cmdr_courx
 LDA &0C10,X
 STA cmdr_coury
 CLC
 LDA &0C20,X
 ADC cmdr_legal
 STA cmdr_legal
 LDA &0C30,X
 STA cmdr_cour+1
 LDA &0C40,X
 STA cmdr_cour

.cour_pres

 JMP jmp_start3

.cour_count

 JSR permute_4
 INC &4C
 BEQ cour_menu
 DEC &46
 BNE cour_count	
 LDX &49
 LDA &6F
 CMP cmdr_homex
 BNE cour_star
 LDA &6D
 CMP cmdr_homey
 BNE cour_star
 JMP cour_next

.cour_star

 LDA &6F
 EOR &71
 EOR &47
 CMP cmdr_legal
 BCC cour_legal
 LDA #0

.cour_legal

 STA &0C20,X
 LDA &6F
 STA &0C00,X
 SEC
 SBC cmdr_homex
 BCS cour_negx
 EOR #&FF
 ADC #&01

.cour_negx

 JSR square
 STA &41
 LDA &1B
 STA &40
 LDX &49
 LDA &6D
 STA &0C10,X
 SEC
 SBC cmdr_homey
 BCS cour_negy
 EOR #&FF
 ADC #&01

.cour_negy

 LSR A
 JSR square
 PHA
 LDA &1B
 CLC
 ADC &40
 STA &81
 PLA
 ADC &41
 STA &82
 JSR sqr_root
 LDX &49
 LDA &6D
 EOR &71
 EOR &47
 LSR A
 LSR A
 LSR A
 CMP &81
 BCS cour_dist
 LDA &81

.cour_dist

 ORA &0C20,X
 STA &0C30,X
 STA &4A
 LSR A
 ROR &4A
 LSR A
 ROR &4A
 LSR A
 ROR &4A
 STA &4B
 STA &0C50,X
 LDA &4A
 STA &0C40,X
 LDA #&01
 STA cursor_x
 CLC
 LDA &49
 ADC #&03
 STA cursor_y
 LDX &49
 INX
 CLC
 JSR writed_3
 JSR price_spc
 JSR write_planet
 LDX &4A
 LDY &4B
 SEC
 LDA #&19
 STA cursor_x
 LDA #&06
 JSR writed_word
 INC &49

.cour_next

 LDA &47
 STA &46
 JMP cour_loop

.cour_dock

 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ cour_quit
 LDA cmdr_homex
 CMP cmdr_courx
 BNE cour_half
 LDA cmdr_homey
 CMP cmdr_coury
 BNE cour_half
 LDA #&02
 JSR clr_scrn
 LDA #&06
 STA cursor_x
 LDA #&0A
 STA cursor_y
 LDA #&71
 JSR write_msg1
 LDX cmdr_cour
 LDY cmdr_cour+1
 SEC
 LDA #&06
 JSR writed_word
 LDA #&E2
 JSR de_token
 LDX cmdr_cour
 LDY cmdr_cour+1
 JSR add_money
 LDA #0
 STA cmdr_cour
 STA cmdr_cour+1
 LDY #&60
 JSR y_sync

.cour_half

 LSR cmdr_cour+1
 ROR cmdr_cour

.cour_quit

 RTS

.stay_here

 LDX #&F4
 LDY #&01
 JSR sub_money
 BCC stay_quit
 JSR cour_dock
 JSR rnd_seq
 STA cmdr_price
 LDX #&00
 STX &96

.d_31d8

 LDA cargo_data+&01,X
 STA &74
 JSR mult_flag
 LDA cargo_data+&03,X
 AND cmdr_price
 CLC
 ADC cargo_data+&02,X
 LDY &74
 BMI d_31f4
 SEC
 SBC &76
 JMP d_31f7

.d_31f4

 CLC
 ADC &76

.d_31f7

 BPL d_31fb
 LDA #&00

.d_31fb

 LDY &96
 AND #&3F
 STA cmdr_avail,Y
 INY
 TYA
 STA &96
 ASL A
 ASL A
 TAX
 CMP #&3F
 BCC d_31d8

.stay_quit

 JMP start_loop

.new_offsets

 EQUB   0,  13,  26,  39,  52,  65,  78,  91
 EQUB 104, 117, 130, 143, 156, 169, 182	\, 195

 \ Name
 \ Price
 \ Pulse, Beam, Military, Mining Lasers, Mounts, Missiles
 \ Shields, Energy, Speed, Hold, Range, Costs
 \ Manouvre-h, Manoevre-l	\, Spare, Spare

.new_ships

.new_adder

 EQUS "ADDER    "

.new_price

IF _SOURCE_DISC

 EQUD 270000

 EQUS "GECKO    "
 EQUD 325000

 EQUS "MORAY    "
 EQUD 360000

 EQUS "COBRA MK1"
 EQUD 395000

 EQUS "IGUANA   "
 EQUD 640000

 EQUS "OPHIDIAN "
 EQUD 645000

 EQUS "CHAMELEON"
 EQUD 975000

 EQUS "COBRA MK3"
 EQUD 1000000

 EQUS "GHAVIAL  "
 EQUD 1365000

 EQUS "F", &90, "-DE-L", &9B, &85
 EQUD 1435000

 EQUS "MONITOR  "
 EQUD 1750000

 EQUS "PYTHON   "
 EQUD 2050000

 EQUS "BOA      "
 EQUD 2400000

 EQUS "ANACONDA "
 EQUD 4000000

 EQUS "ASP MK2  "
 EQUD 8950000

ELIF _RELEASED

 EQUD 310000

 EQUS "GECKO    "
 EQUD 400000

 EQUS "MORAY    "
 EQUD 565000

 EQUS "COBRA MK1"
 EQUD 750000

 EQUS "IGUANA   "
 EQUD 1315000

 EQUS "OPHIDIAN "
 EQUD 1470000

 EQUS "CHAMELEON"
 EQUD 2250000

 EQUS "COBRA MK3"
 EQUD 2870000

 EQUS "F", &90, "-DE-L", &9B, &85
 EQUD 3595000

 EQUS "GHAVIAL  "
 EQUD 3795000

 EQUS "MONITOR  "
 EQUD 5855000

 EQUS "PYTHON   "
 EQUD 7620000

 EQUS "BOA      "
 EQUD 9600000

 EQUS "ASP MK2  "
 EQUD 10120000

 EQUS "ANACONDA "
 EQUD 18695000

ENDIF

.new_details

 EQUB &0E, &8E, &92, &19, &02, &02	\ adder
 EQUB &04, &01,  36, &09,  60, &1A
 EQUB &DF	\, &21, &05, &00

 EQUB &0E, &8F, &93, &19, &04, &03	\ gecko
 EQUB &05, &01,  45, &0A,  70, &1A
 EQUB &EF	\, &11, &06, &00

 EQUB &10, &8F, &96, &19, &04, &03	\ moray
 EQUB &06, &01,  38, &0C,  80, &68
 EQUB &EF	\, &11, &07, &00

 EQUB &0E, &8E, &94, &19, &04, &04	\ cobra 1
 EQUB &05, &01,  39, &0F,  60, &1A
 EQUB &CF	\, &31, &08, &00

 EQUB &0E, &8E, &94, &19, &04, &04	\ iguana
 EQUB &07, &01,  50, &16,  75, &00
 EQUB &DF	\, &21, &08, &00

 EQUB &0D, &8D, &90, &0C, &01, &03	\ ophidian
 EQUB &04, &01,  51, &19,  70, &68
 EQUB &FF	\, &01, &06, &00

 EQUB &10, &8F, &97, &32, &02, &04	\ chameleon
 EQUB &08, &01,  43, &24,  80, &68
 EQUB &DF	\, &21, &05, &00

 EQUB &12, &8F, &98, &32, &04, &05	\ cobra 3
 EQUB &07, &01,  42, &2B,  70, &00
 EQUB &EF	\, &11, &0A, &00

IF _SOURCE_DISC

 EQUB &11, &90, &99, &32, &04, &04	\ ghavial
 EQUB &09, &01,  37, &38,  80, &00
 EQUB &CF	\, &31, &09, &00

 EQUB &12, &92, &9C, &32, &04, &04	\ fer-de-lance
 EQUB &08, &02,  45, &0A,  85, &34
 EQUB &DF	\, &21, &09, &00

ELIF _RELEASED

 EQUB &12, &92, &9C, &32, &04, &04	\ fer-de-lance
 EQUB &08, &02,  45, &0A,  85, &34
 EQUB &DF	\, &21, &09, &00

 EQUB &11, &90, &99, &32, &04, &04	\ ghavial
 EQUB &09, &01,  37, &38,  80, &00
 EQUB &CF	\, &31, &09, &00

ENDIF

 EQUB &18, &93, &9C, &32, &04, &09	\ monitor
 EQUB &0A, &01,  24, &52, 110, &4E
 EQUB &BF	\, &41, &0C, &00

 EQUB &18, &92, &9B, &32, &04, &05	\ python
 EQUB &0B, &01,  30, &6B,  80, &1A
 EQUB &AF	\, &51, &09, &00

 EQUB &14, &8E, &98, &32, &02, &07	\ boa
 EQUB &0A, &01,  36, &85,  90, &00
 EQUB &BF	\, &41, &0A, &00

IF _SOURCE_DISC

 EQUB &1C, &90, &7F, &32, &04, &11	\ anaconda
 EQUB &0D, &01,  21, &FE, 100, &4E
 EQUB &AF	\, &51, &0C, &00

 EQUB &10, &91, &9F, &0C, &01, &02	\ asp 2
 EQUB &0A, &01,  60, &07, 125, &34
 EQUB &DF	\, &21, &07, &00

ELIF _RELEASED

 EQUB &10, &91, &9F, &0C, &01, &02	\ asp 2
 EQUB &0A, &01,  60, &07, 125, &34
 EQUB &DF	\, &21, &07, &00

 EQUB &1C, &90, &7F, &32, &04, &11	\ anaconda
 EQUB &0D, &01,  21, &FE, 100, &4E
 EQUB &AF	\, &51, &0C, &00

ENDIF

\ a.tcode_3

.msg_1

 EQUB &00
 EQUS &09, &0B, &01, &08, " ", &F1, "SK AC", &E9, "SS ME", &E1, &D7, &0A, &02, "1. ", &95, &D7, "2. SA", &FA
 EQUS " ", &9A, " ", &04, &D7, "3. C", &F5, "A", &E0, "GUE", &D7, "4. DEL", &DD, "E", &D0, "FI", &E5, &D7, "5. E"
 EQUS "X", &DB, &D7
 EQUB &00
 EQUS &0C, "WHICH ", &97, "?"
 EQUB &00
 \	EQUA "ARE YOU SURE?"
 EQUS &EE, "E ", &B3, " SU", &F2, "?"
 EQUB &00
 EQUS &96, &97, " ", &10, &98, &D7
 EQUB &00
 EQUS &B0, "m", &CA, "n", &B1
 EQUB &00
 EQUS "  ", &95, " ", &01, "(Y/N)?", &02, &0C, &0C
 EQUB &00
 EQUS "P", &F2, "SS SPA", &E9, " ", &FD, " FI", &F2, ",", &9A, ".", &0C, &0C
 EQUB &00
 EQUS &9A, "'S", &C8
 EQUB &00
 EQUS &15, "FI", &E5, &C9, "DEL", &DD, "E?"
 EQUB &00
 EQUS &17, &0E, &02, "G", &F2, &DD, &F0, "GS", &D5, &B2, &13, "I ", &F7, "G", &D0, "MOM", &F6, "T OF ", &B3, "R V", &E4
 EQUS "U", &D8, &E5, " ", &FB, "ME", &CC, "WE W", &D9, "LD LIKE ", &B3, &C9, "DO", &D0, "L", &DB, "T", &E5, " JO"
 EQUS "B F", &FD, " ", &EC, &CC, &93, &CF, " ", &B3, " ", &DA, "E HE", &F2, &CA, "A", &D2, "MODEL, ", &93
 EQUS &13, "C", &DF, &DE, "RICT", &FD, ", E", &FE, "IP", &C4, "WI", &E2, &D0, "TOP ", &DA, "CR", &DD, &D2, "SHI"
 EQUS "ELD G", &F6, &F4, &F5, &FD, &CC, "UNF", &FD, "TUN", &F5, "ELY ", &DB, "'S ", &F7, &F6, " ", &DE, "O"
 EQUS "L", &F6, &CC, &16, &DB, " W", &F6, "T MISS", &C3, "FROM ", &D9, "R ", &CF, " Y", &EE, "D ", &DF, " ", &13, &E6
 EQUS &F4, " FI", &FA, " M", &DF, &E2, "S AGO", &B2, &1C, &CC, &B3, "R MISSI", &DF, ", SH", &D9, "LD "
 EQUS &B3, " DECIDE", &C9, "AC", &E9, "PT ", &DB, ", IS", &C9, &DA, "EK", &B2, "D", &ED, "TROY ", &94, &CF
 EQUS &CC, &B3, " A", &F2, " CAU", &FB, &DF, &C4, &E2, &F5, " ", &DF, "LY ", &06, "u", &05, "S W", &DC, "L P", &F6
 EQUS &DD, &F8, "TE ", &93, "NEW SHIELDS", &B2, &E2, &F5, " ", &93, &13, "C", &DF, &DE, "RICT", &FD
 EQUS &CA, "F", &DB, "T", &C4, "WI", &E2, " ", &FF, " ", &06, "l", &05, &B1, &02, &08, "GOOD LUCK, ", &9A, &D4, &16
 EQUB &00
 EQUS &19, &09, &17, &0E, &02, "  ", &F5, "T", &F6, &FB, &DF, &D5, ". ", &13, "WE HA", &FA, " NE", &C4, "OF ", &B3, "R"
 EQUS " ", &DA, "RVIC", &ED, " AGA", &F0, &CC, "IF ", &B3, " W", &D9, "LD ", &F7, " ", &EB, " GOOD AS", &C9
 EQUS "GO", &C9, &13, &E9, &F4, &F1, " ", &B3, " W", &DC, "L ", &F7, " BRIEF", &FC, &CC, "IF SUC", &E9, "S"
 EQUS "SFUL, ", &B3, " W", &DC, "L ", &F7, " WELL ", &F2, "W", &EE, "D", &FC, &D4, &18
 EQUB &00
 EQUS "(", &13, "C) AC", &FD, "N", &EB, "FT 1984"
 EQUB &00
 EQUS "BY D.B", &F8, &F7, "N & I.", &F7, "LL"
 EQUB &00
 EQUS &15, &91, &C8, &1A
 EQUB &00
 EQUS &19, &09, &17, &0E, &02, "  C", &DF, "G", &F8, "TU", &F9, &FB, &DF, "S ", &9A, "!", &0C, &0C, &E2, &F4, "E", &0D, " W"
 EQUS &DC, "L ", &E4, "WAYS ", &F7, &D0, "P", &F9, &E9, " F", &FD, " ", &B3, " ", &F0, &D3, &CC, &FF, "D ", &EF
 EQUS "Y", &F7, " ", &EB, &DF, &F4, " ", &E2, &FF, " ", &B3, " ", &E2, &F0, "K..", &D4, &18
 EQUB &00
 EQUS "F", &D8, &E5, "D"
 EQUB &00
 EQUS &E3, "T", &D8, &E5
 EQUB &00
 EQUS "WELL K", &E3, "WN"
 EQUB &00
 EQUS "FAMO", &EC
 EQUB &00
 EQUS &E3, "T", &FC
 EQUB &00
 EQUS &FA, "RY"
 EQUB &00
 EQUS "M", &DC, "DLY"
 EQUB &00
 EQUS "MO", &DE
 EQUB &00
 EQUS &F2, "AS", &DF, &D8, "LY"
 EQUB &00
 EQUB &00
 EQUS &A5
 EQUB &00
 EQUS "r"
 EQUB &00
 EQUS "G", &F2, &F5
 EQUB &00
 EQUS "VA", &DE
 EQUB &00
 EQUS "P", &F0, "K"
 EQUB &00
 EQUS &02, "w v", &0D, " ", &B9, "A", &FB, &DF, "S"
 EQUB &00
 EQUS &9C, "S"
 EQUB &00
 EQUS "u"
 EQUB &00
 EQUS &80, " F", &FD, &ED, "TS"
 EQUB &00
 EQUS "O", &E9, &FF, "S"
 EQUB &00
 EQUS "SHYN", &ED, "S"
 EQUB &00
 EQUS "S", &DC, "L", &F0, &ED, "S"
 EQUB &00
 EQUS &EF, "T", &C3, "T", &F8, &F1, &FB, &DF, "S"
 EQUB &00
 EQUS &E0, &F5, "H", &C3, "OF d"
 EQUB &00
 EQUS &E0, &FA, " F", &FD, " d"
 EQUB &00
 EQUS "FOOD B", &E5, "ND", &F4, "S"
 EQUB &00
 EQUS "T", &D9, "RI", &DE, "S"
 EQUB &00
 EQUS "PO", &DD, "RY"
 EQUB &00
 EQUS &F1, "SCOS"
 EQUB &00
 EQUS "l"
 EQUB &00
 EQUS "W", &E4, "K", &C3, &9E
 EQUB &00
 EQUS "C", &F8, "B"
 EQUB &00
 EQUS "B", &F5
 EQUB &00
 EQUS &E0, "B", &DE
 EQUB &00
 EQUS &12
 EQUB &00
 EQUS &F7, "S", &DD
 EQUB &00
 EQUS "P", &F9, "GU", &FC
 EQUB &00
 EQUS &F8, "VAG", &FC
 EQUB &00
 EQUS "CURS", &FC
 EQUB &00
 EQUS "SC", &D9, "RG", &FC
 EQUB &00
 EQUS "q CIV", &DC, " W", &EE
 EQUB &00
 EQUS "h _ `S"
 EQUB &00
 EQUS "A h ", &F1, &DA, "A", &DA
 EQUB &00
 EQUS "q E", &EE, &E2, &FE, "AK", &ED
 EQUB &00
 EQUS "q ", &EB, &F9, "R AC", &FB, "V", &DB, "Y"
 EQUB &00
 EQUS &AF, "] ^"
 EQUB &00
 EQUS &93, &11, " _ `"
 EQUB &00
 EQUS &AF, &C1, "S' b c"
 EQUB &00
 EQUS &02, "z", &0D
 EQUB &00
 EQUS &AF, "k l"
 EQUB &00
 EQUS "JUI", &E9
 EQUB &00
 EQUS "B", &F8, "NDY"
 EQUB &00
 EQUS "W", &F5, &F4
 EQUB &00
 EQUS "B", &F2, "W"
 EQUB &00
 EQUS "G", &EE, "G", &E5, " B", &F9, &DE, &F4, "S"
 EQUB &00
 EQUS &12
 EQUB &00
 EQUS &11, " `"
 EQUB &00
 EQUS &11, " ", &12
 EQUB &00
 EQUS &11, " h"
 EQUB &00
 EQUS "h ", &12
 EQUB &00
 EQUS "F", &D8, "U", &E0, &EC
 EQUB &00
 EQUS "EXO", &FB, "C"
 EQUB &00
 EQUS "HOOPY"
 EQUB &00
 EQUS "U", &E1, "SU", &E4
 EQUB &00
 EQUS "EXC", &DB, &F0, "G"
 EQUB &00
 EQUS "CUIS", &F0, "E"
 EQUB &00
 EQUS "NIGHT LIFE"
 EQUB &00
 EQUS "CASI", &E3, "S"
 EQUB &00
 EQUS "S", &DB, " COMS"
 EQUB &00
 EQUS &02, "z", &0D
 EQUB &00
 EQUS &03
 EQUB &00
 EQUS &93, &91, " ", &03
 EQUB &00
 EQUS &93, &92, " ", &03
 EQUB &00
 EQUS &94, &91
 EQUB &00
 EQUS &94, &92
 EQUB &00
 EQUS "S", &DF, " OF", &D0, "B", &DB, "CH"
 EQUB &00
 EQUS "SC", &D9, "ND", &F2, "L"
 EQUB &00
 EQUS "B", &F9, "CKGU", &EE, "D"
 EQUB &00
 EQUS "ROGUE"
 EQUB &00
 EQUS "WH", &FD, &ED, &DF, " ", &F7, &DD, &E5, " HEAD", &C6, "F", &F9, "P E", &EE, "'D KNA", &FA
 EQUB &00
 EQUS "N UN", &F2, &EF, "RK", &D8, &E5
 EQUB &00
 EQUS " B", &FD, &F0, "G"
 EQUB &00
 EQUS " DULL"
 EQUB &00
 EQUS " TE", &F1, "O", &EC
 EQUB &00
 EQUS " ", &F2, "VOLT", &F0, "G"
 EQUB &00
 EQUS &91
 EQUB &00
 EQUS &92
 EQUB &00
 EQUS "P", &F9, &E9
 EQUB &00
 EQUS "L", &DB, "T", &E5, " ", &91
 EQUB &00
 EQUS "DUMP"
 EQUB &00
 EQUS "I HE", &EE, &D0, "r ", &E0, "OK", &C3, &CF, " APPE", &EE, &C4, &F5, &D1
 EQUB &00
 EQUS "YEAH, I HE", &EE, &D0, "r ", &CF, " ", &E5, "FT", &D1, &D0, " WHI", &E5, " BACK"
 EQUB &00
 EQUS "G", &DD, " ", &B3, "R IR", &DF, " ASS OV", &F4, " TO", &D1
 EQUB &00
 EQUS &EB, "ME s", &D2, &CF, " WAS ", &DA, &F6, " ", &F5, &D1
 EQUB &00
 EQUS "TRY", &D1
 EQUB &00
 EQUS &01, "SPECI", &E4, " C", &EE, "GO"
 EQUB &00
 EQUB &00
 EQUS "C", &EE, "GO V", &E4, "UE:"
 EQUB &00
 EQUS " MO", &F1, "FI", &FC, " BY A.J.C.DUGG", &FF
 EQUB &00
 EQUS "WASP"
 EQUB &00
 EQUS "MO", &E2
 EQUB &00
 EQUS "GRUB"
 EQUB &00
 EQUS &FF, "T"
 EQUB &00
 EQUS &12
 EQUB &00
 EQUS "PO", &DD
 EQUB &00
 EQUS &EE, "TS G", &F8, "DU", &F5, "E"
 EQUB &00
 EQUS "YAK"
 EQUB &00
 EQUS "SNA", &DC
 EQUB &00
 EQUS "SLUG"
 EQUB &00
 EQUS "TROPIC", &E4
 EQUB &00
 EQUS "D", &F6, &DA
 EQUB &00
 EQUS &F8, &F0
 EQUB &00
 EQUS "IMP", &F6, &DD, &F8, "B", &E5
 EQUB &00
 EQUS "EXU", &F7, &F8, "NT"
 EQUB &00
 EQUS "FUNNY"
 EQUB &00
 EQUS "WI", &F4, "D"
 EQUB &00
 EQUS "U", &E1, "SU", &E4
 EQUB &00
 EQUS &DE, &F8, "N", &E7
 EQUB &00
 EQUS "PECULI", &EE
 EQUB &00
 EQUS "F", &F2, &FE, &F6, "T"
 EQUB &00
 EQUS "OCCASI", &DF, &E4
 EQUB &00
 EQUS "UNP", &F2, &F1, "CT", &D8, &E5
 EQUB &00
 EQUS "D", &F2, "ADFUL"
 EQUB &00
 EQUS &AB
 EQUB &00
 EQUS "\ [ F", &FD, " e"
 EQUB &00
 EQUS &8C, &B2, "e"
 EQUB &00
 EQUS "f BY g"
 EQUB &00
 EQUS &8C, " BUT ", &8E
 EQUB &00
 EQUS " Ao p"
 EQUB &00
 EQUS "PL", &FF, &DD
 EQUB &00
 EQUS "W", &FD, "LD"
 EQUB &00
 EQUS &E2, "E "
 EQUB &00
 EQUS &E2, "IS "
 EQUB &00
 EQUS &E0, "AD", &D2, &9A
 EQUB &00
 EQUS &09, &0B, &01, &08
 EQUB &00
 EQUS "DRI", &FA
 EQUB &00
 EQUS " C", &F5, "A", &E0, "GUE"
 EQUB &00
 EQUS "I", &FF
 EQUB &00
 EQUS &13, "COMM", &FF, "D", &F4
 EQUB &00
 EQUS "h"
 EQUB &00
 EQUS "M", &D9, "NTA", &F0
 EQUB &00
 EQUS &FC, "IB", &E5
 EQUB &00
 EQUS "T", &F2, "E"
 EQUB &00
 EQUS "SPOTT", &FC
 EQUB &00
 EQUS "x"
 EQUB &00
 EQUS "y"
 EQUB &00
 EQUS "aOID"
 EQUB &00
 EQUS &7F
 EQUB &00
 EQUS "~"
 EQUB &00
 EQUS &FF, "CI", &F6, "T"
 EQUB &00
 EQUS "EX", &E9, "P", &FB, &DF, &E4
 EQUB &00
 EQUS "EC", &E9, "NTRIC"
 EQUB &00
 EQUS &F0, "G", &F8, &F0, &FC
 EQUB &00
 EQUS "r"
 EQUB &00
 EQUS "K", &DC, "L", &F4
 EQUB &00
 EQUS "DEADLY"
 EQUB &00
 EQUS "EV", &DC
 EQUB &00
 EQUS &E5, &E2, &E4
 EQUB &00
 EQUS "VICIO", &EC
 EQUB &00
 EQUS &DB, "S "
 EQUB &00
 EQUS &0D, &0E, &13
 EQUB &00
 EQUS ".", &0C, &0F
 EQUB &00
 EQUS " ", &FF, "D "
 EQUB &00
 EQUS "Y", &D9
 EQUB &00
 EQUS "P", &EE, "K", &C3, "M", &DD, &F4, "S"
 EQUB &00
 EQUS "D", &EC, "T C", &E0, "UDS"
 EQUB &00
 EQUS "I", &E9, " ", &F7, "RGS"
 EQUB &00
 EQUS "ROCK F", &FD, &EF, &FB, &DF, "S"
 EQUB &00
 EQUS "VOLCA", &E3, &ED
 EQUB &00
 EQUS "PL", &FF, "T"
 EQUB &00
 EQUS "TULIP"
 EQUB &00
 EQUS "B", &FF, &FF, "A"
 EQUB &00
 EQUS "C", &FD, "N"
 EQUB &00
 EQUS &12, "WE", &FC
 EQUB &00
 EQUS &12
 EQUB &00
 EQUS &11, " ", &12
 EQUB &00
 EQUS &11, " h"
 EQUB &00
 EQUS &F0, "HA", &EA, "T", &FF, "T"
 EQUB &00
 EQUS &BF
 EQUB &00
 EQUS &F0, "G "
 EQUB &00
 EQUS &FC, " "
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS " NAME? "
 EQUB &00
 EQUS " TO "
 EQUB &00
 EQUS " IS "
 EQUB &00
 EQUS "WAS ", &F9, &DE, " ", &DA, &F6, " ", &F5, " ", &13
 EQUB &00
 EQUS ".", &0C, " ", &13
 EQUB &00
 EQUS "DOCK", &FC
 EQUB &00
 EQUS &01, "(Y/N)?"
 EQUB &00
 EQUS "SHIP"
 EQUB &00
 EQUS " A "
 EQUB &00
 EQUS " ", &F4, "RI", &EC
 EQUB &00
 EQUS " NEW "
 EQUB &00
 EQUS &02, " H", &F4, " ", &EF, "J", &ED, "TY'S SPA", &E9, " NAVY", &0D
 EQUB &00
 EQUS &B1, &08, &01, "  M", &ED, "SA", &E7, " ", &F6, "DS"
 EQUB &00
 EQUS " ", &9A, " ", &04, ", I ", &0D, "AM", &02, " CAPTA", &F0, " ", &1B, " ", &0D, "OF", &D3
 EQUB &00
 EQUB &00
 EQUS &0F, " UNK", &E3, "WN ", &91
 EQUB &00
 EQUS &09, &08, &17, &01, &F0, "COM", &C3, "M", &ED, "SA", &E7
 EQUB &00
 EQUS "CURRU", &E2, &F4, "S"
 EQUB &00
 EQUS "FOSDYKE SMY", &E2, "E"
 EQUB &00
 EQUS "F", &FD, "T", &ED, &FE, "E"
 EQUB &00
 EQUS &CB, &F2, &ED, &F1, &E9
 EQUB &00
 EQUS "IS ", &F7, "LIEV", &FC, &C9, "HA", &FA, " JUMP", &FC, &C9, &94, "G", &E4, "AXY"
 EQUB &00
 EQUS &19, &09, &1D, &0E, &02, "GOOD DAY ", &9A, " ", &04, &CC, "I", &0D, " AM ", &13, "AG", &F6, "T ", &13, "B", &F9, "KE"
 EQUS " OF ", &13, "NAV", &E4, " ", &13, &F0, "TEL", &E5, "G", &F6, &E9, &CC, "AS ", &B3, " K", &E3, "W, ", &93, &13
 EQUS "NAVY HA", &FA, " ", &F7, &F6, " KEEP", &C3, &93, &13, &E2, &EE, "GOIDS OFF ", &B3, "R A"
 EQUS "SS ", &D9, "T ", &F0, " DEEP SPA", &E9, " F", &FD, " ", &EF, "NY YE", &EE, "S ", &E3, "W. ", &13, "WEL"
 EQUS "L ", &93, "S", &DB, "UA", &FB, &DF, " HAS CH", &FF, "G", &FC, &CC, &D9, "R BOYS ", &EE, "E ", &F2
 EQUS "ADY F", &FD, &D0, "P", &EC, "H RIGHT", &C9, &93, "HOME SY", &DE, "EM OF ", &E2, "O", &DA, " MO"
 EQUS &E2, &F4, "S", &CC, &18, &09, &1D, "I", &0D, " HA", &FA, " OBTA", &F0, &C4, &93, "DEF", &F6, &E9, " P", &F9
 EQUS "NS F", &FD, " ", &E2, "EIR ", &13, "HI", &FA, " ", &13, "W", &FD, "LDS", &CC, &93, &F7, &DD, &E5, "S K", &E3
 EQUS "W WE'", &FA, " GOT ", &EB, "ME", &E2, &C3, "BUT ", &E3, "T WH", &F5, &CC, "IF ", &13, "I T", &F8, "N"
 EQUS "SM", &DB, " ", &93, "P", &F9, "NS", &C9, &D9, "R BA", &DA, " ", &DF, " ", &13, &EA, &F2, &F8, " ", &E2, "EY'L"
 EQUS "L ", &F0, "T", &F4, &E9, "PT ", &93, "TR", &FF, "SMISSI", &DF, ". ", &13, "I NE", &FC, &D0, &CF, &C9
 EQUS &EF, "KE ", &93, "RUN", &CC, &B3, "'", &F2, " E", &E5, "CT", &FC, &CC, &93, "P", &F9, "NS A", &F2, " "
 EQUS "UNIPUL", &DA, " COD", &C4, "WI", &E2, &F0, " ", &94, "TR", &FF, "SMISSI", &DF, &CC, &08, &B3, " "
 EQUS "W", &DC, "L ", &F7, " PAID", &CC, "    ", &13, "GOOD LUCK ", &9A, &D4, &18
 EQUB &00
 EQUS &19, &09, &1D, &08, &0E, &0D, &13, "WELL D", &DF, "E ", &9A, &CC, &B3, " HA", &FA, " ", &DA, "RV", &C4, &EC, " "
 EQUS "WELL", &B2, "WE SH", &E4, "L ", &F2, "MEMB", &F4, &CC, "WE ", &F1, "D ", &E3, "T EXPECT ", &93
 EQUS &13, &E2, &EE, "GOIDS", &C9, "F", &F0, "D ", &D9, "T ", &D8, &D9, "T ", &B3, &CC, "F", &FD, " ", &93, "MOM", &F6
 EQUS "T P", &E5, "A", &DA, " AC", &E9, "PT ", &94, &13, "NAVY ", &06, "r", &05, " AS PAYM", &F6, "T", &D4, &18
 EQUB &00
 EQUB &00
 EQUS "SH", &F2, "W"
 EQUB &00
 EQUS &F7, "A", &DE
 EQUB &00
 EQUS &EA, "S", &DF
 EQUB &00
 EQUS "SNAKE"
 EQUB &00
 EQUS "WOLF"
 EQUB &00
 EQUS &E5, "OP", &EE, "D"
 EQUB &00
 EQUS "C", &F5
 EQUB &00
 EQUS "M", &DF, "KEY"
 EQUB &00
 EQUS "GO", &F5
 EQUB &00
 EQUS "FISH"
 EQUB &00
 EQUS "j i"
 EQUB &00
 EQUS &11, " x {"
 EQUB &00
 EQUS &AF, "k y {"
 EQUB &00
 EQUS &7C, " }"
 EQUB &00
 EQUS "j i"
 EQUB &00
 EQUS "ME", &F5
 EQUB &00
 EQUS "CUTL", &DD
 EQUB &00
 EQUS &DE, "EAK"
 EQUB &00
 EQUS "BURG", &F4, "S"
 EQUB &00
 EQUS &EB, "UP"
 EQUB &00
 EQUS "I", &E9
 EQUB &00
 EQUS "MUD"
 EQUB &00
 EQUS "Z", &F4, "O-", &13, "G"
 EQUB &00
 EQUS "VACUUM"
 EQUB &00
 EQUS &11, " ULT", &F8
 EQUB &00
 EQUS "HOCKEY"
 EQUB &00
 EQUS "CRICK", &DD
 EQUB &00
 EQUS "K", &EE, &F5, "E"
 EQUB &00
 EQUS "PO", &E0
 EQUB &00
 EQUS "T", &F6, "NIS"
 EQUB &00

.l_5338

 EQUB &00

.misn_data1

 EQUB &D3, &96, &24, &1C, &FD, &4F, &35, &76, &64, &20, &44, &A4
 EQUB &DC, &6A, &10, &A2, &03, &6B, &1A, &C0, &B8, &05, &65, &C1

.misn_data2

 EQUB &29, &80, &00, &00, &00, &01, &01, &01, &01, &82, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01, &01, &01, &01, &02
 EQUB &01, &82

.msg_2

 EQUB &00
 EQUS &93, "CO", &E0, "NI", &DE, "S HE", &F2, " HA", &FA, " VIOL", &F5, &FC, &02, " ", &F0, "T", &F4, "G", &E4
 EQUS "AC", &FB, "C C", &E0, "N", &C3, "PROTOCOL", &0D, &B2, "SH", &D9, "LD ", &F7, " AVOID", &FC
 EQUB &00
 EQUS &93, "C", &DF, &DE, "RICT", &FD, " ", &CB, &F2, &ED, &F1, &E9, ", ", &9A
 EQUB &00
 EQUS "A r ", &E0, "OK", &C3, &CF, " ", &E5, "FT HE", &F2, &D0, "WHI", &E5, " BACK. ", &E0, "OK", &C4, "B", &D9
 EQUS "ND F", &FD, " ", &EE, "E", &E6
 EQUB &00
 EQUS "YEP,", &D0, "r", &D2, &CF, " HAD", &D0, "G", &E4, "AC", &FB, "C HYP", &F4, "DRI", &FA, " F", &DB, "T", &C4
 EQUS "HE", &F2, ". ", &EC, &C4, &DB, " TOO"
 EQUB &00
 EQUS &94, " r ", &CF, " DEHYP", &C4, "HE", &F2, " FROM ", &E3, "WHE", &F2, ", SUN SKIMM", &FC
 EQUS &B2, "JUMP", &FC, ". I HE", &EE, " ", &DB, " W", &F6, "T", &C9, &F0, &EA, &F7
 EQUB &00
 EQUS "s ", &CF, " W", &F6, "T F", &FD, " ME ", &F5, " A", &EC, &EE, ". MY ", &F9, "S", &F4, "S ", &F1, "DN'T E"
 EQUS "V", &F6, " SC", &F8, "TCH ", &93, "s"
 EQUB &00
 EQUS "OH DE", &EE, " ME Y", &ED, ".", &D0, "FRIGHTFUL ROGUE WI", &E2, " WH", &F5, " I ", &F7
 EQUS "LIE", &FA, " ", &B3, " PEOP", &E5, " C", &E4, "L", &D0, &E5, "AD PO", &DE, &F4, "I", &FD, " SHOT UP"
 EQUS " ", &E0, "TS OF ", &E2, "O", &DA, " ", &F7, "A", &DE, "LY PI", &F8, "T", &ED, &B2, "W", &F6, "T", &C9, &EC, &E5
 EQUS "RI"
 EQUB &00
 EQUS &B3, " C", &FF, " TACK", &E5, " ", &93, "h s IF ", &B3, " LIKE. HE'S ", &F5, " ", &FD, &EE
 EQUS &F8
 EQUB &00
 EQUS &01, "COM", &C3, &EB, &DF, ": EL", &DB, "E III"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "BOY A", &F2, " ", &B3, " ", &F0, " ", &93, "WR", &DF, "G G", &E4, "AXY!"
 EQUB &00
 EQUS &E2, &F4, "E'S", &D0, &F2, &E4, " s PI", &F8, "TE ", &D9, "T ", &E2, &F4, "E"
 EQUB &00
 EQUS &93, &C1, "S OF m A", &F2, " ", &EB, " A", &EF, "Z", &F0, "GLY PRIMI", &FB, &FA, " ", &E2, &F5
 EQUS " ", &E2, "EY ", &DE, &DC, "L ", &E2, &F0, "K ", &13, "EL", &DB, "E", &CA, "A P", &F2, "TTY NE", &F5, " GAME"
 EQUB &00

.l_55c0

 EQUB &10, &15, &1A, &1F, &9B, &A0, &2E, &A5, &24, &29, &3D, &33
 EQUB &38, &AA, &42, &47, &4C, &51, &56, &8C, &60, &65, &87, &82
 EQUB &5B, &6A, &B4, &B9, &BE, &E1, &E6, &EB, &F0, &F5, &FA, &73
 EQUB &78, &7D

\SAVE "output/tcode.bin", CODE%, P%, LOAD%

IF _RELEASED
 INCBIN "extracted/released/workspaces/1.D.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/workspaces/1.D.bin"
ENDIF

ORG &5600

IF _RELEASED
 INCBIN "extracted/released/S.T.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/S.T.bin"
ENDIF

SAVE "output/1.D.bin", CODE%, &6000
