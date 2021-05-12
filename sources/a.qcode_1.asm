
.dcode_in

 LDA #&00
 STA dockedp
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

.jmp_start

 JMP start_loop

.decode

 STA save_lock

.set_brk

 LDA #LO(brk_go)
 STA brkv
 LDA #HI(brk_go)
 STA brkv+&01
 RTS

.write_msg3

 PHA
 TAX
 TYA
 PHA
 LDA &22
 PHA
 LDA &23
 PHA
 LDA #LO(msg_3)
 STA &22
 LDA #HI(msg_3)
 BNE l_12de

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

.msg_pairs

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

 BIT dockedp
 BPL l_noradar
 LDA &65
 AND #&A0	\AND #&20
 BNE l_155f
 LDA &65
 ORA #&10
 STA &65
 JMP d_5558

.l_155f

 LDA &65
 AND #&EF
 STA &65

.l_noradar

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

.draw_line

 LDA #&80
 JSR tube_write
 LDA &34
 JSR tube_write
 LDA &35
 JSR tube_write
 LDA &36
 JSR tube_write
 LDA &37
 JMP tube_write

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

 LDA #&81
 JSR tube_write
 LDA &34
 JSR tube_write
 LDA &35
 JSR tube_write
 LDA &36
 JMP tube_write

.draw_pixel

 PHA
 LDA #&82
 JSR tube_write
 TXA
 JSR tube_write
 PLA
 JSR tube_write
 LDA &88
 JMP tube_write

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
 BIT dockedp
 BPL stat_dock
 LDA #&E6
 LDY &033E
 LDX ship_type+&02,Y
 BEQ d_1ca5
 LDY energy
 CPY #&80
 ADC #&01

.d_1ca5

 JSR de_tokln
 JMP stat_legal

.stat_dock

 LDA #&CD
 JSR write_msg1
 JSR new_line

.stat_legal

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
 JSR update_pod

.status_no

 LDX #&01

.status_keep

 STX cursor_x
 LDA #&0A
 JMP de_token

.l_1bbc

 EQUD &00E87648

.writec_3

 CLC

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

.dockwrch

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

 LDA cursor_y
 \	INC cursor_x
 CMP #&18
 BCC wrch_or
 PHA
 JSR clr_temp
 PLA
 LDA &D2
 JMP l_1d5e

.wrch_or

 LDA #&8E
 JSR tube_write
 LDA cursor_x
 JSR tube_write
 LDA cursor_y
 JSR tube_write
 TYA
 JSR tube_write
 INC cursor_x

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
 LDA #&00
 STA &82
 STA &1B
 LDA #&08
 STA &83
 LDA &31
 LSR A
 LSR A
 ORA &32
 EOR #&80
 JSR scale_angle
 JSR draw_angle
 LDA &2A
 LDX &2B
 BEQ l_1e1d
 SEC
 SBC #&01

.l_1e1d

 JSR scale_angle
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
 LDA energy
 LSR A
 LSR A
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
 LDA f_shield
 JSR bar_sixtnth
 LDA r_shield
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
 LDA &8A
 AND #&08
 AND f_flag
 BEQ l_1eb3
 TXA

.bit8

 EQUB &2C

.l_1eb3

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

 PHA
 LDA #&86
 JSR tube_write
 PLA
 JSR tube_write
 LDX #&FF
 STX &82
 CMP &06
 BCS flash_gr
 LDA &41
 EQUB &2C

.flash_gr

 LDA &40

.flash_le

 JSR tube_write
 LDA ptr
 JSR tube_write
 LDA ptr+1
 JSR tube_write
 INC ptr+&01
 RTS

.draw_angle

 PHA
 LDA #&87
 JSR tube_write
 PLA
 JSR tube_write
 LDA ptr
 JSR tube_write
 LDA ptr+1
 JSR tube_write
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
 LDA #&9A
 JSR tube_write
 LDA &1B
 JSR tube_write
 LDA &85
 JSR tube_write
 LDX &84
 INX
 CPX #&0D
 BCC l_200e
 LDA #&10

.l_204e

 STA &84
 LDA #&9B
 JSR tube_write
 LDA &84
 JSR tube_write
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

.l_2138

 RTS

.draw_mode

 LDA #&94
 JMP tube_write

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
 LDA _07C0,X
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

.clr_temp

 JSR set_deflowr
 LDA #&80
 STA vdu_stat
 STA upper_switch
 ASL A
 STA &034A
 STA &034B
 JSR write_0346
 LDA #&83
 JSR tube_write
 LDX &2F
 BEQ d_54eb
 JSR d_30ac

.d_54eb

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
 STX vdu_stat
 STX &34
 STX &35
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
 LDY #&01	\INY
 STY cursor_x
 DEY
 LDA #&84
 JMP tube_write

.sync

 LDA #&85
 JSR tube_write
 JMP tube_read

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
 LDA dockedp
 BNE not_cyclop
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
 JSR writec_5
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
 LDA #&80
 STA vdu_stat
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
 LDA #&80
 STA vdu_stat
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

.writec_5

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

 LDX #&80
 STX vdu_stat
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

.update_pod

 LDA #&8F
 JSR tube_write
 LDA cmdr_escape
 JSR tube_write
 LDA &0348
 JMP tube_write


