INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

 \ a.icode - ELITE III encyclopedia

INCLUDE "sources/a.global.asm"

CODE% = &11E3
ORG CODE%
LOAD% = &11E3
EXEC% = &11E3


.dcode_in

 JMP dcode_2

.boot_in

 JMP dcode_2

.wrch_in

 JMP wrchdst
 EQUW &114B

.brk_in

 JMP brk_go

\ a.icode_1

.tcode

 LDX #LO(ltcode)
 LDY #HI(ltcode)
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

\ a.icode_2

.beep_wait

 JSR sound_20
 LDY #&32
 JMP y_sync

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
 BNE l_31cb
 LDA #&80
 STA vdu_stat
 RTS

.l_31cb

 DEX
 DEX
 BNE l_31d2
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
 LDA #&00
 STA &22
 LDA #&04
 STA &23
 LDY #&00
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
 JMP info_menu

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
 JSR l_3c91
 BPL jump_data
 JMP launch

.jump_data

 JSR snap_hype
 JMP data_onsys

.not_data

 CMP #&77
 BNE not_invnt
 JMP info_menu

.not_invnt

 CMP #&16
 BNE not_price
 JMP info_menu

.not_price

 CMP #&20
 BEQ jump_menu
 CMP #&71
 BEQ jump_menu
 CMP #&72
 BEQ jump_menu
 CMP #&73
 BNE not_equip

.jump_menu

 JMP info_menu

.not_equip

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
 LDA #&80
 STA vdu_stat
 LDA #&01
 STA cursor_x
 INC cursor_y
 JMP show_nzdist

.err_count

 EQUB &00

.jmp_escape

 JMP escape

.brk_go

 DEC err_count
 BNE jmp_escape
 JSR clr_common

.start_loop

 LDA #&FF
 STA &8E
 LDA #&73
 JMP function

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


.info_menu

 LDX #&00
 JSR menu
 CMP #&01
 BNE n_shipsag
 JMP ships_ag

.n_shipsag

 CMP #&02
 BNE n_shipskw
 JMP ships_kw

.n_shipskw

 CMP #&03
 BNE n_equipdat
 JMP equip_data

.n_equipdat

 CMP #&04
 BNE n_controls
 JMP controls

.n_controls

 CMP #&05
 BNE jmp_start3
 JMP trading

.jmp_start3

 JSR beep_wait
 JMP start_loop

.ships_ag


.ships_kw

 PHA
 TAX
 JSR menu
 SBC #&00
 PLP
 BCS ship_over
 ADC menu_entry+1

.ship_over

 STA &8C
 CLC
 ADC #&07
 PHA
 LDA #&20
 JSR clr_scrn
 JSR clr_deflowr
 LDX &8C
 LDA ship_file,X
 CMP ship_load+&04
 BEQ ship_skip
 STA ship_load+&04
 LDX #LO(ship_load)
 LDY #HI(ship_load)
 JSR oscli

.ship_skip

 LDX &8C
 LDA ship_centre,X
 STA cursor_x
 PLA
 JSR write_msg2
 JSR hline_19
 JSR init_ship
 LDA #&60
 STA &54
 LDA #&B0
 STA &4D
 LDX #&7F
 STX &63
 STX &64
 INX
 STA vdu_stat
 LDA &8C
 JSR write_card
 LDX &8C
 LDA ship_posn,X
 JSR ins_ship

.l_release

 JSR scan_10
 BNE l_release

.l_395a

 LDX &8C
 LDA ship_dist,X
 CMP &4D
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
 JSR sync
 JSR scan_10
 BEQ l_395a
 JMP start_loop

.controls

 LDX #&03
 JSR menu
 ADC #&56
 PHA
 ADC #&04
 PHA
 LDA #&20
 JSR clr_scrn
 JSR clr_deflowr
 LDA #&0B
 STA cursor_x
 PLA
 JSR write_msg2
 JSR hline_19
 JSR set_deflowr
 INC cursor_y
 PLA
 JSR write_msg2
 JMP l_restart

.equip_data

 LDX #&04
 JSR menu
 ADC #&6B
 PHA
 SBC #&0C
 PHA
 LDA #&20
 JSR clr_scrn
 JSR clr_deflowr
 LDA #&0B
 STA cursor_x
 PLA
 JSR write_msg2
 JSR hline_19
 JSR set_deflowr
 JSR set_forclwr
 INC cursor_y
 INC cursor_y
 LDA #&01
 STA cursor_x
 PLA
 JSR write_msg2
 JMP l_restart

.trading


.l_restart

 JSR l_250e
 JMP start_loop


.write_card

 ASL A
 TAY
 LDA card_addr,Y
 STA &22
 LDA card_addr+1,Y
 STA &23

.card_repeat

 JSR clr_deflowr
 LDY #&00
 LDA (&22),Y
 TAX
 BEQ quit_card
 BNE card_check

.card_find

 INY
 INY
 INY
 LDA card_pattern-1,Y
 BNE card_find

.card_check

 DEX
 BNE card_find

.card_found

 LDA card_pattern,Y
 STA cursor_x
 LDA card_pattern+1,Y
 STA cursor_y
 LDA card_pattern+2,Y
 BEQ card_details
 JSR write_msg2
 INY
 INY
 INY
 BNE card_found

.card_details

 JSR set_deflowr
 LDY #&00

.card_loop

 INY
 LDA (&22),Y
 BEQ card_end
 BMI card_msg
 CMP #&20
 BCC card_macro
 JSR msg_alpha
 JMP card_loop

.card_macro

 JSR msg_macro
 JMP card_loop

.card_msg

 CMP #&D7
 BCS card_pairs
 AND #&7F
 JSR write_msg2
 JMP card_loop

.card_pairs

 JSR msg_pairs
 JMP card_loop

.card_end

 TYA
 SEC
 ADC &22
 STA &22
 BCC card_repeat
 INC &23
 BCS card_repeat

.quit_card

 RTS


.ship_load

 EQUS "L.S.0", &0D


.ship_file

 EQUB 'A', 'H', 'I', 'K', 'J', 'P', 'B'
 EQUB 'N', 'A', 'B', 'A', 'M', 'E', 'B'
 EQUB 'G', 'I', 'M', 'A', 'O', 'F', 'E'
 EQUB 'L', 'L', 'C', 'C', 'P', 'A', 'H'


.ship_posn

 EQUB 19, 14, 27, 11, 20, 12, 17
 EQUB 11,  2,  2,  3, 25, 17, 11
 EQUB 20, 17, 17, 11, 22, 21, 11
 EQUB  9, 17, 29, 30, 10, 16, 15


.ship_dist

 EQUB &01, &02, &01, &02, &01, &01, &01
 EQUB &02, &04, &04, &01, &01, &01, &02
 EQUB &01, &02, &01, &02, &01, &01, &02
 EQUB &01, &01, &03, &01, &01, &01, &01


.menu

 LDA menu_entry,X
 STA &03AB
 LDA menu_offset,X
 STA &03AD
 LDA menu_query,X
 PHA
 LDA menu_title,X	
 PHA
 LDA menu_titlex,X
 PHA
 LDA #&20
 JSR clr_scrn
 JSR clr_deflowr
 PLA
 STA cursor_x
 PLA
 JSR write_msg2
 JSR hline_19
 JSR set_deflowr
 LDA #&80
 STA vdu_stat
 INC cursor_y
 LDX #&00

.menu_loop

 STX &89
 JSR new_line
 LDX &89
 INX
 CLC
 JSR writed_3
 JSR price_spc
 CLC
 LDA &89
 ADC &03AD
 JSR write_msg2
 LDX &89
 INX
 CPX &03AB
 BCC menu_loop
 JSR clr_line
 PLA
 JSR write_msg2
 LDA #'?'
 JSR punctuate
 JSR buy_quant
 BEQ menu_start
 BCS menu_start
 RTS

.menu_start

 JMP start_loop


.menu_title

 EQUB &01, &02, &03, &05, &04

.menu_titlex

 EQUB &05, &0C, &0C, &0C, &0B

.menu_offset

 EQUB &02, &07, &15, &5B, &5F

.menu_entry

 EQUB &04, &0E, &0E, &04, &0D

.menu_query

 EQUB &06, &43, &43, &05, &04


\ a.icode_3

.msg_1

 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS &96, &97, " ", &10, &98, &D7
 EQUB &00
 EQUS &B0, "m", &CA, "n", &B1
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS &9A, "'S", &C8
 EQUB &00
 EQUB &00
 EQUS &16
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS &15, &91, &C8, &1A
 EQUB &00
 \	EQUA "|Y|I|W|N|B  C|!_G|!xTU|!y|!{|!_S |!|Z!|L|L|!b|!tE|M W"
 \	EQUA "|!\L |!dWAYS |!w|!PP|!y|!i F|!} |!3 |!p|!S|!L|!|?D |!o"
 \	EQUA "Y|!w |!k|!_|!t |!b|!|? |!3 |!b|!pK..|!T|X"
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
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
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
 EQUB &00
 EQUS &B1, &08, &01, "  M", &ED, "SA", &E7, " ", &F6, "DS"
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS &0F, " UNK", &E3, "WN ", &91
 EQUB &00
 EQUS &09, &08, &17, &01, &F0, "COM", &C3, "M", &ED, "SA", &E7
 EQUB &00
 EQUB &00
 EQUB &00
 EQUS "F", &FD, "T", &ED, &FE, "E"
 EQUB &00
 EQUS &CB, &F2, &ED, &F1, &E9
 EQUB &00
 EQUB &00
 EQUB &00
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
 EQUB &00


.msg_2

 EQUB &00
 EQUS &F6, "CYC", &E0, "P", &FC, "IA G", &E4, "AC", &FB, "CA"
 EQUB &00
 EQUS &CF, "S ", &01, "A-G", &02
 EQUB &00
 EQUS &CF, "S ", &01, "I-W", &02
 EQUB &00
 EQUS "E", &FE, "IPM", &F6, "T"
 EQUB &00
 EQUS "C", &DF, "TROLS"
 EQUB &00
 EQUS &F0, "F", &FD, &EF, &FB, &DF
 EQUB &00
 EQUS "ADD", &F4
 EQUB &00
 EQUS &FF, "AC", &DF, "DA"
 EQUB &00
 EQUS "ASP MK2"
 EQUB &00
 EQUS "BOA"
 EQUB &00
 EQUS "BUSHMASTER"
 EQUB &00
 EQUS "CHAMELEON"
 EQUB &00
 EQUS "COB", &F8, " MK1"
 EQUB &00
 EQUS "COB", &F8, " MK3"
 EQUB &00
 EQUS "C", &FD, "IOLIS ", &DE, &F5, "I", &DF
 EQUB &00
 EQUS "DODECAG", &DF, " ", &DE, &F5, "I", &DF
 EQUB &00
 EQUS &ED, "CAPE CAPSU", &E5
 EQUB &00
 EQUS "F", &F4, "-DE-", &13, &F9, "N", &E9
 EQUB &00
 EQUS &E7, "CKO"
 EQUB &00
 EQUS "GHAVI", &E4
 EQUB &00
 EQUS "IGUANA"
 EQUB &00
 EQUS "K", &F8, &DB
 EQUB &00
 EQUS &EF, "MBA"
 EQUB &00
 EQUS "M", &DF, &DB, &FD
 EQUB &00
 EQUS "MO", &F8, "Y"
 EQUB &00
 EQUS "OPHI", &F1, &FF
 EQUB &00
 EQUS "PY", &E2, &DF
 EQUB &00
 EQUS "SHUTT", &E5
 EQUB &00
 EQUS "SIDEW", &F0, "D", &F4
 EQUB &00
 EQUS &E2, &EE, "GOID"
 EQUB &00
 EQUS &E2, &EE, "G", &DF
 EQUB &00
 EQUS "T", &F8, "NSP", &FD, "T", &F4
 EQUB &00
 EQUS "VIP", &F4
 EQUB &00
 EQUS "W", &FD, "M"
 EQUB &00
 EQUS &EE, &EF, "M", &F6, "TS:"
 EQUB &00
 EQUS "SPE", &FC, ":"
 EQUB &00
 EQUS &F0, &DA, "RVI", &E9, " D", &F5, "E:"
 EQUB &00
 EQUS "COMB", &F5
 EQUB &00
 EQUS "C", &F2, "W:"
 EQUB &00
 EQUS &97, " MOT", &FD, "S:"
 EQUB &00
 EQUS &F8, "N", &E7, ":"
 EQUB &00
 EQUS "FT"
 EQUB &00
 EQUS &F1, "M", &F6, "SI", &DF, "S:"
 EQUB &00
 EQUS "HULL:"	\EQUA "", &F0, "T", &F4, "N", &E4
 EQUB &00
 EQUS "SPA", &E9, ":"
 EQUB &00
 EQUS " MISS", &DC, &ED
 EQUB &00
 EQUS "FACT", &FD, ":"
 EQUB &00
 EQUS &E7, "R", &DD, " ", &DE, &EE, &DA, "EK", &F4
 EQUB &00
 EQUS " ", &F9, &DA, "R"
 EQUB &00
 EQUS " PUL", &DA
 EQUB &00
 EQUS " SY", &DE, "EM"
 EQUB &00
 EQUS &F4, "G", &DF
 EQUB &00
 EQUS &97
 EQUB &00
 EQUS &DA, "EK"
 EQUB &00
 EQUS "LIGHT"
 EQUB &00
 EQUS &F0, "G", &F8, "M"
 EQUB &00
 EQUS &F9, "N", &E9, " & F", &F4, &EF, "N"
 EQUB &00
 EQUS &13, "KRU", &E7, "R "
 EQUB &00
 EQUS "HASS", &DF, "I"
 EQUB &00
 EQUS "VOLTAI", &F2
 EQUB &00
 EQUS "C", &EE, "GO"
 EQUB &00
 EQUS &01, "TC", &02
 EQUB &00
 EQUS &01, "LY", &02
 EQUB &00
 EQUS &01, "LM", &02
 EQUB &00
 EQUS "CF"
 EQUB &00
 EQUS &E2, "RU", &DE
 EQUB &00
 EQUS " ", &CF
 EQUB &00
 EQUS &F0, "V", &F6, &FB, &DF
 EQUB &00
 EQUS &D9, "TW", &FD, "LD"
 EQUB &00
 EQUS "Z", &FD, "G", &DF, " P", &DD, "T", &F4, "S", &DF, ")"
 EQUB &00
 EQUS "DE", &13, &F9, "CY"
 EQUB &00
 EQUS &01, "4*C40KV", &02, " AM", &ED, " ", &97
 EQUB &00
 EQUS "V & K "
 EQUB &00
 EQUS "B", &F9, &DE
 EQUB &00
 EQUS " (", &13, "GA", &DA, "C L", &D8, "S, ", &FA, &FB, &FB, &E9, ")"
 EQUB &00
 EQUS "F", &FC, "E", &F8, &FB, &DF
 EQUB &00
 EQUS "SPA", &E9
 EQUB &00
 EQUS &13, "I", &DF, "IC"
 EQUB &00
 EQUS "HUNT"
 EQUB &00
 EQUS "PROS", &DA, "T "
 EQUB &00
 EQUS " W", &FD, "KSHOPS)"
 EQUB &00
 EQUS &01, "/1L", &02
 EQUB &00
 EQUS &01, "/2L", &02
 EQUB &00
 EQUS &01, "/4L", &02
 EQUB &00
 EQUS " (", &13
 EQUB &00
 EQUS &01, "IFS", &02, " "
 EQUB &00
 EQUS &0C, "FLIGHT C", &DF, "TROLS", &D7
 EQUS "<", &08, &FF, &FB, "-C", &E0, "CKWI", &DA, " ROLL", &0C
 EQUS ">", &08, "C", &E0, "CKWI", &DA, " ROLL", &0C
 EQUS "S", &08, &F1, &FA, &0C
 EQUS "X", &08, "CLIMB", &0C
 EQUS &01, "SPC", &02, &08, &F0, "C", &F2, "A", &DA, " SPE", &FC, &0C
 EQUS "?", &08, "DEC", &F2, "A", &DA, " SPE", &FC, &0C
 EQUS &01, "T", &D8, &02, &08, "HYP", &F4, "SPA", &E9, " ", &ED, "CAPE", &0C
 EQUS &01, &ED, "C", &02, &08, &ED, "CAPE CAPSU", &E5, &0C
 EQUS "F", &08, "TOGG", &E5, " COMPASS", &0C
 EQUS "V", &08, &04, "s", &05, " ", &DF, &0C
 EQUS "P", &08, &04, "s", &05, " OFF", &0C
 EQUS "J", &08, "MICROJUMP", &0C
 EQUS &0D, "F0", &02, &08, "FR", &DF, "T VIEW", &0C
 EQUS &0D, "F1", &02, &08, &F2, &EE, " VIEW", &0C
 EQUS &0D, "F2", &02, &08, &E5, "FT VIEW", &0C
 EQUS &0D, "F3", &02, &08, "RIGHT VIEW", &0C
 EQUB &00
 EQUS &0C, "COMB", &F5, " C", &DF, "TROLS", &D7
 EQUS "A", &08, "FI", &F2, " ", &F9, &DA, "R", &0C
 EQUS "T", &08, "T", &EE, "G", &DD, " ", &04, "j", &05, &0C
 EQUS "M", &08, "FI", &F2, " ", &04, "j", &05, &0C
 EQUS "U", &08, "UN", &EE, "M ", &04, "j", &05, &0C
 EQUS "E", &08, "TRIG", &E7, "R E.C.M.", &0C
 EQUS &0C, "I.F.F. COL", &D9, "R COD", &ED, &D7
 EQUS "WH", &DB, "E", &16, "OFFICI", &E4, " ", &CF, &0C
 EQUS "BLUE", &16, &E5, "G", &E4, " ", &CF, &0C
 EQUS "BLUE/", &13, "WH", &DB, "E", &16, "DEBRIS", &0C
 EQUS "BLUE/", &13, &F2, "D", &16, "N", &DF, "-R", &ED, "P", &DF, "D", &F6, "T", &0C
 EQUS "WH", &DB, "E/", &13, &F2, "D", &16, &04, "j", &05, &0C
 EQUB &00
 EQUS &0C, "NAVIG", &F5, "I", &DF, " C", &DF, "TROLS", &D7
 EQUS "H", &08, "HYP", &F4, "SPA", &E9, " JUMP", &0C
 EQUS "C-", &13, "H", &08, &04, "t", &05, &0C
 EQUS "CUR", &EB, "R KEYS", &0C, &08, "HYP", &F4, "SPA", &E9, " CUR", &EB, "R C", &DF, "TROL", &0C
 EQUS "D", &08, &F1, &DE, &FF, &E9, &C9, "SY", &DE, "EM", &0C
 EQUS "O", &08, "HOME CUR", &EB, "R", &0C
 EQUS "F", &08, "F", &F0, "D SY", &DE, "EM (", &13, &CD, ")", &0C
 EQUS "W", &08, "F", &F0, "D DE", &DE, &F0, &F5, "I", &DF, " SY", &DE, "EM", &0C
 EQUS &0D, "F4", &02, &08, "G", &E4, "AC", &FB, "C ", &EF, "P", &0C
 EQUS &0D, "F5", &02, &08, "SH", &FD, "T ", &F8, "N", &E7, " ", &EF, "P", &0C
 EQUS &0D, "F6", &02, &08, "D", &F5, "A ", &DF, " ", &91, &0C
 EQUB &00
 EQUS &0C, "T", &F8, "D", &C3, "C", &DF, "TROLS", &D7
 EQUS &0D, "F0", &02, &08, &F9, "UNCH FROM ", &DE, &F5, "I", &DF, &0C
 EQUS "C-F0", &02, &08, &F2, &EF, &F0, " ", &CD, &0C
 EQUS &0D, "F1", &02, &08, "BUY C", &EE, "GO", &0C
 EQUS "C-F1", &08, "BUY SPECI", &E4, " C", &EE, "GO", &0C
 EQUS &0D, "F2", &02, &08, &DA, "LL C", &EE, "GO", &0C
 EQUS "C-F2", &08, &DA, "LL EQUIPMENT", &0C
 EQUS &0D, "F3", &02, &08, "EQUIP ", &CF, &0C
 EQUS "C-F3", &08, "BUY ", &CF, &0C
 EQUS "C-F6", &08, &F6, "CYC", &E0, "P", &FC, "IA", &0C
 EQUS &0D, "F7", &02, &08, "M", &EE, "K", &DD, " PRI", &E9, "S", &0C
 EQUS &0D, "F8", &02, &08, &DE, &F5, &EC, " PA", &E7, &0C
 EQUS &0D, "F9", &02, &08, &F0, "V", &F6, "T", &FD, "Y", &0C
 EQUB &00
 EQUS "FLIGHT"
 EQUB &00
 EQUS "COMB", &F5
 EQUB &00
 EQUS "NAVIG", &F5, "I", &DF
 EQUB &00
 EQUS "T", &F8, "D", &F0, "G"
 EQUB &00
 EQUS &04, "j", &05
 EQUB &00
 EQUS &04, "k", &05
 EQUB &00
 EQUS &04, "l", &05
 EQUB &00
 EQUS &04, "g", &05
 EQUB &00
 EQUS &04, "h", &05
 EQUB &00
 EQUS &04, "o", &05
 EQUB &00
 EQUS &04, "p", &05
 EQUB &00
 EQUS &04, "q", &05
 EQUB &00
 EQUS &04, "r", &05
 EQUB &00
 EQUS &04, "s", &05
 EQUB &00
 EQUS &04, "t", &05
 EQUB &00
 EQUS &04, "u", &05
 EQUB &00
 EQUS &04, "v", &05
 EQUB &00
 EQUS &0E, &13, &DA, "LF HOM", &C3, "MISS", &DC, &ED, " ", &EF, "Y ", &F7, " "
 EQUS "B", &D9, "GHT ", &F5, " ", &FF, "Y SY", &DE, "EM.", &D7
 EQUS &13, &F7, "FO", &F2, &D0, "MISS", &DC, "E C", &FF, " ", &F7, " FIR", &C4
 EQUS &DB, " MU", &DE, " ", &F7, " ", &E0, "CK", &C4, &DF, "TO "
 EQUS "A T", &EE, "G", &DD, ".", &D7, &13, "WH", &F6, " FI", &F2, "D, ", &DB, " W", &DC, "L"
 EQUS " HOME ", &F0, &C9, &93, "T", &EE, "G", &DD, " "
 EQUS "UN", &E5, "SS ", &93, "T", &EE, "G", &DD, " C", &FF, " ", &D9, "T", &EF, &E3, "EUV"
 EQUS &F2, " ", &93, "MISS", &DC, "E, "
 EQUS "SHOOT ", &DB, ", ", &FD, " U", &DA, " E", &E5, "CTR", &DF, "IC C", &D9, "NT"
 EQUS &F4, " MEASUR", &ED, " ", &DF, " ", &DB, &B1
 EQUB &00
 EQUS &0E, &13, &FF, " ID", &F6, &FB, "FIC", &F5, "I", &DF, " FRI", &F6, "D ", &FD
 EQUS " FOE SY", &DE, "EM C", &FF, " ", &F7, " OBTA", &F0, &C4
 EQUS &F5, " TECH ", &E5, &FA, "L 2 ", &FD, " ", &D8, "O", &FA, ".", &D7, &13, &FF
 EQUS " ", &01, "I.F.F.", &0D, " SY", &DE, "EM W", &DC, "L ", &F1, "SP", &F9, "Y "
 EQUS &F1, "FFE", &F2, "NT TYP", &ED, " OF OBJECT ", &F0, " ", &F1, "FFE"
 EQUS &F2, "NT COL", &D9, "RS ", &DF, " ", &93
 EQUS &F8, "D", &EE, " ", &F1, "SP", &F9, "Y.", &D7, &13, &DA, "E ", &13, "C", &DF, "TROLS (", &13, "COMB", &F5, ")", &B1
 EQUB &00
 EQUS &0E, &13, &FF, " E", &E5, "CTR", &DF, "IC C", &D9, "NT", &F4, " MEASUR", &ED
 EQUS " SY", &DE, "EM ", &EF, "Y ", &F7, " B", &D9, "GHT ", &F5, " "
 EQUS &FF, "Y SY", &DE, "EM OF TECH ", &E5, &FA, "L 3 ", &FD, " HIGH"
 EQUS &F4, ".", &D7, &13, "WH", &F6, " AC", &FB, "V", &F5, &FC, ", ", &93
 EQUS &01, "E.C.M.", &0D, " SY", &DE, "EM W", &DC, "L ", &F1, "SRUPT ", &93, "GUID"
 EQUS &FF, &E9, " SY", &DE, "EMS OF ", &E4, "L "
 EQUS "MISS", &DC, &ED, " ", &F0, " ", &93, "VIC", &F0, &DB, "Y, ", &EF, "K", &C3, &E2, "EM ", &DA, "LF DE", &DE, "RUCT", &B1
 EQUB &00
 EQUS &0E, &13, "PUL", &DA, " ", &F9, &DA, "RS ", &EE, "E F", &FD, " S", &E4, "E ", &F5
 EQUS " TECH ", &E5, &FA, "L 4 ", &FD, " ", &D8, "O", &FA, ".", &D7
 EQUS &13, "PUL", &DA, " ", &F9, &DA, "RS FI", &F2, " ", &F0, "T", &F4, "M", &DB, "T", &F6, "T ", &F9, &DA, "R ", &F7, "AMS", &B1
 EQUB &00
 EQUS &0E, &13, &F7, "AM ", &F9, &DA, "RS ", &EE, "E AVA", &DC, &D8, &E5, " ", &F5
 EQUS " SY", &DE, "EMS OF TECH ", &E5, &FA, "L 5 ", &FD, " "
 EQUS "HIGH", &F4, ".", &D7, &13, &F7, "AM ", &F9, &DA, "RS FI", &F2, " C", &DF, &FB
 EQUS &E1, &D9, "S ", &F9, &DA, "R ", &DE, &F8, "NDS, W", &DB, "H "
 EQUS &EF, "NY ", &DE, &F8, "NDS ", &F0, " P", &EE, &E4, &E5, "L.", &D7, &13, &F7, "AM"
 EQUS " ", &F9, &DA, "RS OV", &F4, "HE", &F5, " MO", &F2, " "
 EQUS &F8, "PIDLY ", &E2, &FF, " PUL", &DA, " ", &F9, &DA, "RS", &B1
 EQUB &00
 EQUS &0E, &13, "FUEL SCOOPS ", &F6, &D8, &E5, &D0, &CF, &C9, "OBTA", &F0, " "
 EQUS "F", &F2, "E HYP", &F4, "SPA", &E9, " FUEL "
 EQUS "BY 'SUN-SKIMM", &F0, "G' - FLY", &C3, "C", &E0, &DA, &C9, &93, "SUN"
 EQUS ".", &D7, &13, "FUEL SCOOPS "
 EQUS "C", &FF, " ", &E4, &EB, " ", &F7, " ", &EC, &C4, "TO PICK UP SPA", &E9, " DEBRIS,"
 EQUS " SUCH AS C", &EE, "GO "
 EQUS "B", &EE, &F2, "LS ", &FD, " A", &DE, &F4, "OID F", &F8, "GM", &F6, "TS.", &D7, &13, "FUEL"
 EQUS " SCOOPS ", &EE, "E AVA", &DC, &D8, &E5, " "
 EQUS "FROM SY", &DE, "EMS OF TECH ", &E5, &FA, "L 6 ", &FD, " ", &D8, "O", &FA, &B1
 EQUB &00
 EQUS &0E, &13, &FF, " ", &ED, "CAPE POD", &CA, &FF, " ", &ED, &DA, "N", &FB, &E4
 EQUS " PIE", &E9, " OF EQUIPM", &F6, "T F", &FD, " "
 EQUS "MO", &DE, " SPA", &E9, &CF, "S.", &D7, &13, "WH", &F6, " EJECT", &FC, ","
 EQUS " ", &93, "CAPSU", &E5, " W", &DC, "L ", &F7, " T", &F8, "CK", &C4
 EQUS "TO ", &93, "NE", &EE, "E", &DE, " SPA", &E9, " ", &DE, &F5, "I", &DF, ".", &D7, &13
 EQUS "MO", &DE, " ", &ED, "CAPE PODS COME W", &DB, "H "
 EQUS &F0, "SU", &F8, "N", &E9, " POLICI", &ED, &C9, &F2, "P", &F9, &E9, " ", &93
 EQUS &CF, &B2, "EQUIPM", &F6, "T.", &D7
 EQUS &13, "P", &F6, &E4, &FB, &ED, " F", &FD, " ", &F0, "T", &F4, "F", &F4, &C3, "W", &DB, "H"
 EQUS " ", &ED, "CAPE PODS ", &EE, "E ", &DA, &FA, &F2, " "
 EQUS &F0, " MO", &DE, " ", &91, &EE, "Y SY", &DE, "EMS.", &D7, &13, &ED, "CAPE"
 EQUS " PODS ", &EF, "Y ", &F7, " B", &D9, "GHT ", &F5, " "
 EQUS "SY", &DE, "EMS OF TECH ", &E5, &FA, "L 7 ", &FD, " HIGH", &F4, &B1
 EQUB &00
 EQUS &0E, &13, "A ", &F2, &E9, "NT ", &F0, "V", &F6, &FB, &DF, ", ", &93, "HYP", &F4
 EQUS "SPA", &E9, " UN", &DB, &CA, &FF, " ", &E4, "T", &F4, "N", &F5, "I", &FA, " "
 EQUS "TO ", &93, &ED, "CAPE POD F", &FD, " ", &EF, "NY T", &F8, "D", &F4, "S."
 EQUS &D7, &13, "WH", &F6, " TRIG", &E7, &F2, "D, ", &93
 EQUS "HYP", &F4, "SPA", &E9, " UN", &DB, " W", &DC, "L U", &DA, " ", &DB, "S POW", &F4
 EQUS " ", &F0, " E", &E6, "CUT", &C3, "A HYP", &F4, "JUMP "
 EQUS "AWAY FROM ", &93, "CUR", &F2, "NT POS", &DB, "I", &DF, ".", &D7, &13, "UN"
 EQUS "F", &FD, "TUN", &F5, "ELY, ", &F7, "CAU", &DA, " ", &93
 EQUS "HYP", &F4, "JUMP", &CA, &F0, &DE, &FF, "T", &FF, "E", &D9, "S, ", &E2, "E", &F2
 EQUS &CA, &E3, " C", &DF, "TROL OF ", &93
 EQUS "DE", &DE, &F0, &F5, "I", &DF, " POS", &DB, "I", &DF, ".", &D7, &13, "A HYP", &F4, "SPA"
 EQUS &E9, " UN", &DB, &CA, "AVA", &DC, &D8, &E5, " ", &F5, " "
 EQUS "TECH ", &E5, &FA, "L 8 ", &FD, " ", &D8, "O", &FA, &B1
 EQUB &00
 EQUS &0E, &13, &FF, " ", &F6, &F4, "GY UN", &DB, " ", &F0, "C", &F2, "A", &DA, "S ", &93, "R", &F5, "E"
 EQUS " OF ", &F2, "CH", &EE, "G", &C3, "OF ", &93
 EQUS &F6, &F4, "GY B", &FF, "KS FROM SURFA", &E9, " ", &F8, &F1, &F5, "I", &DF
 EQUS " ", &D8, &EB, "RP", &FB, &DF, "."
 EQUS &D7, &13, &F6, &F4, "GY UN", &DB, "S ", &EE, "E AVA", &DC, &D8, &E5, " FROM"
 EQUS " TECH ", &E5, &FA, "L 9 UPW", &EE, "DS", &B1
 EQUB &00
 EQUS &0E, &13, "DOCK", &C3, "COMPUT", &F4, "S ", &EE, "E ", &F2, "COMM", &F6, "D", &C4, "BY ", &E4, "L ", &91, &EE, "Y "
 EQUS "GOV", &F4, "NM", &F6, "TS AS", &D0, "SAFE WAY OF ", &F2, "DUC", &C3, &93
 EQUS &E1, "MB", &F4, " OF DOCK", &C3
 EQUS "ACCID", &F6, "TS.", &D7, &13, "DOCK", &C3, "COMPUT", &F4, "S W", &DC, "L"
 EQUS " AUTO", &EF, &FB, "C", &E4, "LY DOCK", &D0, &CF, " "
 EQUS "WH", &F6, " TURN", &C4, &DF, ".", &D7, &13, "DOCK", &C3, "COMPUT", &F4, "S"
 EQUS " C", &FF, " ", &F7, " B", &D9, "GHT ", &F5, " SY", &DE, "EMS "
 EQUS "OF TECH ", &E5, &FA, "L 10 ", &FD, " MO", &F2, &B1
 EQUB &00
 EQUS &0E, &13, "G", &E4, "AC", &FB, "C HYP", &F4, "SPA", &E9, " ", &97, "S ", &EE, "E "
 EQUS "OBTA", &F0, &D8, &E5, " FROM ", &91, "S OF "
 EQUS "TECH ", &E5, &FA, "L 11 UPW", &EE, "DS.", &D7, &13, "WH", &F6, " "
 EQUS &93, &F0, "T", &F4, "G", &E4, "AC", &FB, "C HYP", &F4, &97, " "
 EQUS "IS ", &F6, "GA", &E7, "D, ", &93, &CF, &CA, "HYP", &F4, "JUMP", &C4, &F0, "TO"
 EQUS " ", &93, "P", &F2, "-PROG", &F8, "MM", &C4
 EQUS "G", &E4, "AXY", &B1
 EQUB &00
 EQUS &0E, &13, "M", &DC, &DB, &EE, "Y ", &F9, &DA, "RS ", &EE, "E ", &93, "HEIGHT"
 EQUS " OF ", &F9, &DA, "R ", &EB, "PHI", &DE, "IC", &F5, "I", &DF, ".", &D7
 EQUS &13, &E2, "EY U", &DA, " HIGH ", &F6, &F4, "GY ", &F9, &DA, "RS FIR", &C3, "C"
 EQUS &DF, &FB, &E1, &D9, "SLY", &C9, "PRODU", &E9, " "
 EQUS "DEVA", &DE, &F5, &C3, "EFFECTS, BUT ", &EE, "E PR", &DF, "E", &C9, "OV", &F4, "HE", &F5, &F0, "G.", &D7
 EQUS &13, "M", &DC, &DB, &EE, "Y ", &F9, &DA, "RS ", &EE, "E AVA", &DC, &D8, &E5, " "
 EQUS "FROM ", &91, "S OF TECH ", &E5, &FA, "L "
 EQUS "12 ", &FD, " MO", &F2, &B1
 EQUB &00
 EQUS &0E, &13, "M", &F0, &C3, &F9, &DA, "RS ", &EE, "E HIGHLY POWE", &F2, "D, "
 EQUS "S", &E0, "W FIR", &C3, "PUL", &DA, " ", &F9, &DA, "RS "
 EQUS "WHICH ", &EE, "E TUN", &C4, "TO F", &F8, "GM", &F6, "T A", &DE, &F4, "OIDS."
 EQUS &D7, &13, "M", &F0, &C3, &F9, &DA, "RS ", &EE, "E "
 EQUS "AVA", &DC, &D8, &E5, " FROM TECH ", &E5, &FA, "L 12 UPW", &EE, "DS", &B1
 EQUB &00


.l_55c0

 EQUB &10, &15, &1A, &1F, &9B, &A0, &2E, &A5, &24, &29, &3D, &33
 EQUB &38, &AA, &42, &47, &4C, &51, &56, &8C, &60, &65, &87, &82
 EQUB &5B, &6A, &B4, &B9, &BE, &E1, &E6, &EB, &F0, &F5, &FA, &73
 EQUB &78, &7D


.ship_centre

 EQUB &0D, &0C, &0C, &0B, &0D, &0C, &0B
 EQUB &0B, &08, &07, &09, &0A, &0D, &0C
 EQUB &0D, &0D, &0D, &0C, &0D, &0C, &0D
 EQUB &0C, &0B, &0C, &0C, &0A, &0D, &0E


.card_pattern

 EQUB  1,  3, &25	\ inservice date
 EQUB  1,  4, &00
 EQUB 24,  6, &26	\ combat factor
 EQUB 24,  7, &2F
 EQUB 24,  8, &41
 EQUB 26,  8, &00
 EQUB  1,  6, &2B	\ dimensions
 EQUB  1,  7, &00
 EQUB  1,  9, &24	\ speed
 EQUB  1, 10, &00
 EQUB 24, 10, &27	\ crew
 EQUB 24, 11, &00
 EQUB 24, 13, &29	\ range
 EQUB 24, 14, &00
 EQUB  1, 12, &3D	\ cargo space
 EQUB  1, 13, &2D
 EQUB  1, 14, &00
 EQUB  1, 16, &23	\ armaments
 EQUB  1, 17, &00
 EQUB 23, 20, &2C	\ hull
 EQUB 23, 21, &00
 EQUB  1, 20, &28	\ drive motors
 EQUB  1, 21, &00
 EQUB  1, 20, &2D	\ space
 EQUB  1, 21, &00


.card_addr

 EQUW adder, anaconda, asp_2, boa, bushmaster, chameleon, cobra_1
 EQUW cobra_3, coriolis, dodecagon, escape_pod
 EQUW fer_de_lance, gecko, ghavial
 EQUW iguana, krait, mamba, monitor, moray, ophidian, python
 EQUW shuttle, sidewinder, thargoid, thargon
 EQUW transporter, viper, worm


.adder

 EQUB 1
 EQUS "2914", &D5, &C5, &D1
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "45/8/30", &AA
 EQUB 0, 4
 EQUS "0.24", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 6
 EQUS "6", &BF
 EQUB 0, 7
 EQUS "4", &BE
 EQUB 0, 8
 EQUS &B8, " 1928 AZ ", &F7, "am", &B1, &0C, &B0, &AE
 EQUB 0, 9
 EQUS "D4-18", &D3
 EQUB 0, 10
 EQUS "AM 18 ", &EA, " ", &C2
 EQUB 0, 0

.anaconda

 EQUB 1
 EQUS "2856", &D5, "Riml", &F0, &F4, " G", &E4, "ac", &FB, "c)"
 EQUB 0, 2
 EQUS "3"
 EQUB 0, 3
 EQUS "170/60/75", &AA
 EQUB 0, 4
 EQUS "0.14", &C0
 EQUB 0, 5
 EQUS "2-10"
 EQUB 0, 6
 EQUS "10", &BF
 EQUB 0, 7
 EQUS "245", &BE
 EQUB 0, 8
 EQUS &BB, " Hi-", &F8, "d", &B2, &B1, &0C, &B0, &AE
 EQUB 0, 9
 EQUS "M8-**", &D4
 EQUB 0, 10
 EQUS &C9, "32.24", &0C, &F4, "g", &EF, &DE, &F4, "s"
 EQUB 0, 0

.asp_2

 EQUB 1
 EQUS "2878", &D5, "G", &E4, "cop", &D1
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "70/20/65", &AA
 EQUB 0, 4
 EQUS "0.40", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 6
 EQUS "12.5", &BF
 EQUB 0, 7
 EQUS "0", &BE
 EQUB 0, 8
 EQUS &BB, "-", &BA, "Bur", &DE, &B1, &0C, &B0, &AE
 EQUB 0, 9
 EQUS "J6-31", &D2
 EQUB 0, 10
 EQUS &BC, " Whip", &F9, "sh", &0C, &01, "HK", &02, " ", &B2, &B5
 EQUB 0, 0

.boa

 EQUB 1
 EQUS "3017", &D5, &E7, &F2, &E7, " ", &CC, ")"
 EQUB 0, 2
 EQUS "4"
 EQUB 0, 3
 EQUS "115/60/65", &AA
 EQUB 0, 4
 EQUS "0.24", &C0
 EQUB 0, 5
 EQUS "2-6"
 EQUB 0, 6
 EQUS "9", &BF
 EQUB 0, 7
 EQUS "125", &BE
 EQUB 0, 8
 EQUS &B4, &B1, &B3, &0C, &D6, &B6, " & ", &CF, &AE
 EQUB 0, 9
 EQUS "J7-24", &D3
 EQUB 0, 10
 EQUS &C8, &0C, &B6, &B7, " ", &C2, &F4, "s"
 EQUB 0, 0

.bushmaster

 EQUB 1
 EQUS "3001", &D5, &DF, "ri", &F8, " ", &FD, "b", &DB, &E4, ")"
 EQUB 0, 2
 EQUS "8"
 EQUB 0, 3
 EQUS "50/20/50", &AA
 EQUB 0, 4
 EQUS "0.35", &C0
 EQUB 0, 5
 EQUS "1-2"
 EQUB 0, 8
 EQUS "Du", &E4, " 22-18", &B1, &0C, &B0, &AE
 \	EQUB 0, 9
 \	EQUA "3|!R"
 EQUB 0, 10
 EQUS &BC, " Whip", &F9, "sh", &0C, &01, "HT", &02, " ", &B2, &B5
 EQUB 0, 0

.chameleon

 EQUB 1
 EQUS "3122", &D5, &EE, "d", &F6, " Co-op", &F4, "a", &FB, &FA, ")"
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "75/24/40", &AA
 EQUB 0, 4
 EQUS "0.29", &C0
 EQUB 0, 5
 EQUS "1-4"
 EQUB 0, 6
 EQUS "8", &BF
 EQUB 0, 7
 EQUS "30", &BE
 EQUB 0, 8
 EQUS &B8, " Mega", &CA, &B2, &B1, &0C, &B6, &F4, " X3", &AE
 EQUB 0, 9
 EQUS "H5-23", &D3
 EQUB 0, 10
 EQUS &BC, " ", &DE, &F0, "g", &F4, &0C, "Pul", &DA, &B5
 EQUB 0, 0

.cobra_1

 EQUB 1
 EQUS "2855", &D5, "Payn", &D9, ", ", &D0, "& S", &E4, "em)"
 EQUB 0, 2
 EQUS "5"
 EQUB 0, 3
 EQUS "55/15/70", &AA
 EQUB 0, 4
 EQUS "0.26", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 6
 EQUS "6", &BF
 EQUB 0, 7
 EQUS "10", &BE
 EQUB 0, 8
 EQUS &BB, " V", &EE, "isc", &FF, &B1, &0C, &B9, &AE
 EQUB 0, 9
 EQUS "E4-20", &D4
 EQUB 0, 10
 EQUS &D0, &B5
 EQUB 0, 0

.cobra_3

 EQUB 1
 EQUS "3100", &D5, "Cowell & Mg", &13, &F8, &E2, ", ", &F9, &FA, ")"
 EQUB 0, 2
 EQUS "7"
 EQUB 0, 3
 EQUS "65/30/130", &AA
 EQUB 0, 4
 EQUS "0.28", &C0
 EQUB 0, 5
 EQUS "1-3"
 EQUB 0, 6
 EQUS "7", &BF
 EQUB 0, 7
 EQUS "35", &BE
 EQUB 0, 8
 EQUS &B8, &B1, &B3, &0C, &B9, &AE
 EQUB 0, 9
 EQUS "G7-24", &D4
 EQUB 0, 10
 EQUS &BA, &B7, "fa", &DE, &0C, "Irrik", &FF, " Thru", &CD
 EQUB 0, 0

.coriolis

 EQUB 1
 EQUS "2752", &CB
 EQUB 0, 3
 EQUS "1/1/1km"
 EQUB 0, 11
 EQUS "2000", &C3, "s"
 EQUB 0, 0

.dodecagon

 EQUB 1
 EQUS "3152", &CB
 EQUB 0, 3
 EQUS "1/1/1km"
 EQUB 0, 11
 EQUS "2700", &C3, "s"
 EQUB 0, 0

.escape_pod

 EQUB 1
 EQUS "p", &F2, "-2500"
 EQUB 0, 3
 EQUS "10/5/5", &AA
 EQUB 0, 4
 EQUS "0.08", &C0
 EQUB 0, 5
 EQUS "1-2"
 EQUB 0, 0

.fer_de_lance

 EQUB 1
 EQUS "3100", &D5, &C6
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "85/20/45", &AA
 EQUB 0, 4
 EQUS "0.30", &C0
 EQUB 0, 5
 EQUS "1-3"
 EQUB 0, 6
 EQUS "8.5", &BF
 EQUB 0, 7
 EQUS "2", &BE
 EQUB 0, 8
 EQUS &B4, &B1, &B3, &0C, &D6, &B6, " & ", &CF, &AE
 EQUB 0, 9
 EQUS "H7-28", &D4
 EQUB 0, 10
 EQUS "T", &DB, "r", &DF, "ix ", &F0, "t", &F4, "sun", &0C, &01, "LT", &02, " ", &CE
 EQUB 0, 0

.gecko

 EQUB 1
 EQUS "2852", &D5, "A", &E9, " & F", &D8, &F4, ", ", &E5, &F2, &F9, &E9, ")"
 EQUB 0, 2
 EQUS "7"
 EQUB 0, 3
 EQUS "40/12/65", &AA
 EQUB 0, 4
 EQUS "0.30", &C0
 EQUB 0, 5
 EQUS "1-2"
 EQUB 0, 6
 EQUS "7", &BF
 EQUB 0, 7
 EQUS "3", &BE
 EQUB 0, 8
 EQUS &B8, " 1919 A4", &B1, &0C, &C0, " Hom", &F0, "g", &AE
 EQUB 0, 9
 EQUS "E6-19", &D3
 EQUB 0, 10
 EQUS "B", &F2, "am", &B2, &B7, " ", &01, "XL", &02
 EQUB 0, 0

.ghavial

 EQUB 1
 EQUS "3077", &D5, &EE, "d", &F6, " Co-op", &F4, "a", &FB, &FA, ")"
 EQUB 0, 2
 EQUS "5"
 EQUB 0, 3
 EQUS "80/30/60", &AA
 EQUB 0, 4
 EQUS "0.25", &C0
 EQUB 0, 5
 EQUS "2-7"
 EQUB 0, 6
 EQUS "8", &BF
 EQUB 0, 7
 EQUS "50", &BE
 EQUB 0, 8
 EQUS "Fai", &F2, "y", &B2, &B1, &0C, &B9, &AE
 EQUB 0, 9
 EQUS "I5-25", &D4
 EQUB 0, 10
 EQUS "Sp", &E4, "d", &F4, " & Prime ", &01, "TT1", &02
 EQUB 0, 0

.iguana

 EQUB 1
 EQUS "3095", &D5, "Faulc", &DF, " ", &EF, "n", &CD, ")"
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "65/20/40", &AA
 EQUB 0, 4
 EQUS "0.33", &C0
 EQUB 0, 5
 EQUS "1-3"
 EQUB 0, 6
 EQUS "7.5", &BF
 EQUB 0, 7
 EQUS "15", &BE
 EQUB 0, 8
 EQUS &B9, &B1, &0C, &B6, &F4, " X1", &AE
 EQUB 0, 9
 EQUS "G6-20", &D4
 EQUB 0, 10
 EQUS &C7, " Sup", &F4, " ", &C2, &0C, &01, "VC", &02, "9"
 EQUB 0, 0

.krait

 EQUB 1
 EQUS "3027", &D5, &C7, &C3, "W", &FD, "ks, ", &F0, &F0, &ED, ")"
 EQUB 0, 2
 EQUS "7"
 EQUB 0, 3
 EQUS "80/20/90", &AA
 EQUB 0, 4
 EQUS "0.30", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 7
 EQUS "10", &BE
 EQUB 0, 8
 EQUS &B4, &B1, &B3
 \	EQUB 0, 9
 \	EQUA "8|!S"
 EQUB 0, 10
 EQUS &C7, " Sp", &F0, &CE, " ZX14"
 EQUB 0, 0

.mamba

 EQUB 1
 EQUS "3110", &D5, &F2, &FD, "te", &C3, " ", &CC, ")"
 EQUB 0, 2
 EQUS "8"
 EQUB 0, 3
 EQUS "55/12/65", &AA
 EQUB 0, 4
 EQUS "0.30", &C0
 EQUB 0, 5
 EQUS "1-2"
 EQUB 0, 7
 EQUS "10", &BE
 EQUB 0, 8
 EQUS &B4, &B1, &B3, &0C, &D6, &B6, " & ", &CF, &AE
 \	EQUB 0, 9
 \	EQUA "7|!R"
 EQUB 0, 10
 EQUS &B6, &B7, " ", &01, "HV", &02, " ", &C2
 EQUB 0, 0

.monitor

 EQUB 1
 EQUS "3112", &D5, &C6
 EQUB 0, 2
 EQUS "4"
 EQUB 0, 3
 EQUS "100/40/50", &AA
 EQUB 0, 4
 EQUS "0.16", &C0
 EQUB 0, 5
 EQUS "7-19"
 EQUB 0, 6
 EQUS "11", &BF
 EQUB 0, 7
 EQUS "75", &BE
 EQUB 0, 8
 EQUS &BA, &01, "HMB", &02, &B1, &0C, &B0, &AE
 EQUB 0, 9
 EQUS "J6-28", &D4
 EQUB 0, 10
 EQUS &C9, "29.01", &0C, &B7, " ", &CA, &F4, "s"
 EQUB 0, 0

.moray

 EQUB 1
 EQUS "3028", &D5, "M", &EE, &F0, "e T", &F2, "nch Co.)"
 EQUB 0, 2
 EQUS "7"
 EQUB 0, 3
 EQUS "60/25/60", &AA
 EQUB 0, 4
 EQUS "0.25", &C0
 EQUB 0, 5
 EQUS "1-4"
 EQUB 0, 6
 EQUS "8", &BF
 EQUB 0, 7
 EQUS "7", &BE
 EQUB 0, 8
 EQUS &B8, &B1, &B3, &0C, &B0, &AE
 EQUB 0, 9
 EQUS "F4-22", &D4
 EQUB 0, 10
 EQUS "Turbul", &F6, " ", &FE, &EE, "k", &0C, &F2, "-ch", &EE, "g", &F4, " 1287"
 EQUB 0, 0

.ophidian

 EQUB 1
 EQUS "2981", &D5, &C5, &D1
 EQUB 0, 2
 EQUS "8"
 EQUB 0, 3
 EQUS "65/15/30", &AA
 EQUB 0, 4
 EQUS "0.34", &C0
 EQUB 0, 5
 EQUS "1-3"
 EQUB 0, 6
 EQUS "7", &BF
 EQUB 0, 7
 EQUS "20", &BE
 EQUB 0, 8
 EQUS &B9, &B1, &0C, &B6, &F4, " X1", &AE
 EQUB 0, 9
 EQUS "D4-16", &D2
 EQUB 0, 10
 EQUS &BC, " ", &DE, &F0, "g", &F4, &0C, "Pul", &DA, &B5
 EQUB 0, 0

.python

 EQUB 1
 EQUS "2700", &D5, "Wh", &F5, "t & Pr", &DB, "ney SC)"
 EQUB 0, 2
 EQUS "3"
 EQUB 0, 3
 EQUS "130/40/80", &AA
 EQUB 0, 4
 EQUS "0.20", &C0
 EQUB 0, 5
 EQUS "2-9"
 EQUB 0, 6
 EQUS "8", &BF
 EQUB 0, 7
 EQUS "100", &BE
 EQUB 0, 8
 EQUS "Volt-", &13, "V", &EE, "isc", &FF, &B2, &B1
 EQUB 0, 9
 EQUS "K6-27", &D4
 EQUB 0, 10
 EQUS &C8, &0C, "Exl", &DF, " 76NN Model"
 EQUB 0, 0

.shuttle

 EQUB 1
 EQUS "2856", &D5, "Saud-", &BA, "A", &DE, "ro)"
 EQUB 0, 2
 EQUS "4"
 EQUB 0, 3
 EQUS "35/20/20", &AA
 EQUB 0, 4
 EQUS "0.08", &C0
 EQUB 0, 5
 EQUS "2"
 EQUB 0, 7
 EQUS "60", &BE
 EQUB 0, 10
 EQUS &C9, "20.20", &0C, &DE, &EE, &EF, "t ", &B5
 EQUB 0, 0

.sidewinder

 EQUB 1
 EQUS "2982", &D5, &DF, "ri", &F8, " ", &FD, "b", &DB, &E4, ")"
 EQUB 0, 2
 EQUS "9"
 EQUB 0, 3
 EQUS "35/15/65", &AA
 EQUB 0, 4
 EQUS "0.37", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 8
 EQUS "Du", &E4, " 22-18", &B1
 \	EQUB 0, 9
 \	EQUA "3|!R"
 EQUB 0, 10
 EQUS &C7, " Sp", &F0, &CE, " ", &01, "MV", &02
 EQUB 0, 0

.thargoid

 EQUB 2
 EQUS "6"
 EQUB 0, 3
 EQUS "180/40/180", &AA
 EQUB 0, 4
 EQUS "0.39", &C0
 EQUB 0, 5
 EQUS "50"
 EQUB 0, 6
 EQUS "Unk", &E3, "wn"
 EQUB 0, 8
 EQUS "Widely v", &EE, "y", &F0, "g"
 \	EQUB 0, 9
 \	EQUA "Unk|!cwn"
 EQUB 0, 10
 EQUS &9E, " ", &C4
 EQUB 0, 0

.thargon

 EQUB 2
 EQUS "6"
 EQUB 0, 3
 EQUS "40/10/35", &AA
 EQUB 0, 4
 EQUS "0.30", &C0
 EQUB 0, 5
 EQUS &E3, "ne"
 EQUB 0, 8
 EQUS &9E, &B1
 \	EQUB 0, 9
 \	EQUA "|!cne"
 EQUB 0, 10
 EQUS &9E, " ", &C4
 EQUB 0, 0

.transporter

 EQUB 1
 EQUS "p", &F2, "-2500", &D5, &CD, "L", &F0, "k", &C3, "y", &EE, "ds)"
 EQUB 0, 3
 EQUS "35/10/30", &AA
 EQUB 0, 4
 EQUS "0.10", &C0
 EQUB 0, 5
 EQUS "5"
 EQUB 0, 7
 EQUS "10", &BE
 EQUB 0, 0

.viper

 EQUB 1
 EQUS "2762", &D5, "Faulc", &DF, " ", &EF, "n", &CD, ")"
 EQUB 0, 2
 EQUS "7"
 EQUB 0, 3
 EQUS "55/20/50", &AA
 EQUB 0, 4
 EQUS "0.32", &C0
 EQUB 0, 5
 EQUS "1-10"
 EQUB 0, 8
 EQUS &B8, " Mega", &CA, &B2, &B1, &0C, &B6, &F4, " X3", &AE
 \	EQUB 0, 9
 \	EQUA "9|!R"
 EQUB 0, 10
 EQUS &C7, " Sup", &F4, " ", &C2, &0C, &01, "VC", &02, "10"
 EQUB 0, 0

.worm

 EQUB 1
 EQUS "3101"
 EQUB 0, 2
 EQUS "6"
 EQUB 0, 3
 EQUS "35/12/35", &AA
 EQUB 0, 4
 EQUS "0.23", &C0
 EQUB 0, 5
 EQUS "1"
 EQUB 0, 8
 EQUS &B8, &B2, &B1
 \	EQUB 0, 9
 \	EQUA "3|!R"
 EQUB 0, 10
 EQUS &B6, &B7, " ", &01, "HV", &02, " ", &C2
 EQUB 0, 0


SAVE "output/1.E.bin", CODE%, P%, LOAD%