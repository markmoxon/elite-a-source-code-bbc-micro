
.tcode

 LDX #<ltcode
 LDY #>ltcode
 JSR oscli

.ltcode

 EQUS "L.1.D", &0D

.launch

 LDA #'R'
 STA ltcode
 EQUB &2C

.escape

 LDA #&00
 STA last_key+1
 JMP tcode

.dcode_2

 JSR set_brk
 JSR clr_common
 JMP start_loop

.set_brk

 LDA #<brk_go
 STA brk_in+&01
 LDA #>brk_go
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
 LDA #<msg_2
 STA &22
 LDA #>msg_2
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
 LDA #<msg_1
 STA &22
 LDA #>msg_1

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

.l_24d7

 LDA #&10
 EQUB &2C

.column_6

 LDA #&06
 STA cursor_x

.set_vdustat

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

.clr_vdustat

 LDA #&01
 EQUB &2C

.set_token

 LDA #&80
 STA vdu_stat
 LDA #&FF
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

 EQUW clr_deflowr, set_deflowr, de_token, set_token
 EQUW clr_token, set_vdustat, punctuate, column_6
 EQUW msg_cls, punctuate, hline_19, punctuate
 EQUW set_forclwr, format_on, format_off, l_1c8d
 EQUW l_13ec, name_gen, set_upprmsk, punctuate
 EQUW clr_line, l_24d7, l_24ed, clr_vdustat
 EQUW punctuate, get_line, l_12b1, l_12b4
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

 LDA &65
 AND #&20
 BNE l_155f
 LDA &65
 ORA #&10
 STA &65

.l_155f

 LDA &65
 AND #&EF
 STA &65
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
 RTS

.wrch_bell

 JSR sound_20
 JMP wrch_quit

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

.l_23e8

 LDX #&03

.l_2426

 LDA &6E,X
 STA &00,X
 DEX
 BPL l_2426
 LDA #&05
 JMP write_msg1

.l_24ed

 LDA #&0A

.bit7

 EQUB &2C

.l_24f0

 LDA #&06
 STA cursor_y
 JMP set_forclwr

.l_250e

 JSR scan_10
 BNE l_250e

.l_out

 JSR scan_10
 BEQ l_out
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
 \new_pgph
 \	LDA #&80
 \	STA vdu_stat

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
 LDX #&02
 STX &95
 JMP circle

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
 BCS l_2baa
 EOR #&FF
 ADC #&01

.l_2baa

 CMP #&14
 BCS l_2c1e
 LDA &6D
 SEC
 SBC cmdr_homey
 BCS l_2bba
 EOR #&FF
 ADC #&01

.l_2bba

 CMP #&26
 BCS l_2c1e
 LDA &6F
 SEC
 SBC cmdr_homex
 ASL A
 ASL A
 ADC #&68
 STA &3A
 LSR A
 LSR A
 LSR A
 STA cursor_x
 INC cursor_x
 LDA &6D
 SEC
 SBC cmdr_homey
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

.writed_5c

 CLC

.writed_5

 LDA #&05
 JMP writed_word
 \token_query:
 \	JSR de_token
 \	LDA #&3F
 \	JMP de_token

.price_spc

 LDA #&20
 JMP de_token

.func_tab

 EQUB &20, &71, &72, &73, &14, &74, &75, &16, &76, &77

.buy_invnt

 SBC #&50
 BCC buy_top
 CMP #&0A
 BCC buy_func

.buy_top

 LDA #&01

.buy_func

 TAX
 LDA func_tab,X
 JMP function

.buy_quant

 LDX #&00
 STX &82
 LDX #&0C
 STX &06

.buy_repeat

 JSR get_keyy
 LDX &82
 BNE l_29c6

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
