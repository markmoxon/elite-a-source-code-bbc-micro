
.l_32d0

 TXA
 CLC
 ADC cmdr_money+&03
 STA cmdr_money+&03
 TYA
 ADC cmdr_money+&02
 STA cmdr_money+&02
 BCC l_32f0
 INC cmdr_money+&01
 BNE n_addmny
 INC cmdr_money

.n_addmny

 CLC

.l_32f0

 RTS

.l_32f4

 ASL &1B
 ROL A
 ASL &1B
 ROL A
 TAY
 LDX &1B
 RTS

.l_32fe

 JSR l_2e65
 JSR l_2f75
 JSR l_2e65
 JMP l_5537

.l_330a

 LDX #&05

.l_330c

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_330c
 LDY #&03
 BIT &6C
 BVS l_331a
 DEY

.l_331a

 STY &D1

.l_331c

 LDA &71
 AND #&1F
 BEQ l_3327
 ORA #&80
 JSR l_339a

.l_3327

 JSR l_2b14
 DEC &D1
 BPL l_331c
 LDX #&05

.l_3330

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_3330
 RTS

.l_3338

 LDY #&00

.l_333a

 LDA &0350,Y
 CMP #&0D
 BEQ l_3347
 JSR wrchdst
 INY
 BNE l_333a

.l_3347

 RTS

.l_3348

 JSR l_334e
 JSR l_330a

.l_334e

 LDX #&05

.l_3350

 LDA &6C,X
 LDY &03B2,X
 STA &03B2,X
 STY &6C,X
 DEX
 BPL l_3350
 RTS

.l_335e

 LDX cmdr_galxy
 INX
 JMP c_1e38

.l_3366

 LDA #&69
 JSR l_3395
 LDX cmdr_fuel
 SEC
 JSR l_1e38
 LDA #&C3
 JSR l_338f
 LDA #&77
 BNE l_339a

.l_337b

 LDX #&03

.l_337d

 LDA cmdr_money,X
 STA &40,X
 DEX
 BPL l_337d
 LDA #&09
 STA &80
 SEC
 JSR l_1e48
 LDA #&E2

.l_338f

 JSR l_339a
 JMP l_2b60

.l_3395

 JSR l_339a

.l_3398

 LDA #&3A

.l_339a

 TAX
 BEQ l_337b
 BMI l_3413
 DEX
 BEQ l_335e
 DEX
 BEQ l_3348
 DEX
 BNE l_33ab
 JMP l_330a

.l_33ab

 DEX
 BEQ l_3338
 DEX
 BEQ l_3366
 DEX
 BNE l_33b9

.vdu_80

 LDX #&80
 EQUB &2C

.vdu_00

 LDX #&00
 STX vdu_stat
 RTS

.l_33b9

 DEX
 DEX
 BEQ vdu_00
 DEX
 BEQ l_33fb
 CMP #&60
 BCS l_342d
 CMP #&0E
 BCC l_33cf
 CMP #&20
 BCC l_33f7

.l_33cf

 LDX vdu_stat
 BEQ l_3410
 BMI l_33e6
 BIT vdu_stat
 BVS l_3409

.l_33d9

 CMP #&41
 BCC l_33e3
 CMP #&5B
 BCS l_33e3
 ADC #&20

.l_33e3

 JMP wrchdst

.l_33e6

 BIT vdu_stat
 BVS l_3401
 CMP #&41
 BCC l_3410
 PHA
 TXA
 ORA #&40
 STA vdu_stat
 PLA
 BNE l_33e3

.l_33f7

 ADC #&72
 BNE l_342d

.l_33fb

 LDA #&15
 STA cursor_x
 BNE l_3398

.l_3401

 CPX #&FF
 BEQ l_3468
 CMP #&41
 BCS l_33d9

.l_3409

 PHA
 TXA
 AND #&BF
 STA vdu_stat
 PLA

.l_3410

 JMP wrchdst

.l_3413

 CMP #&A0
 BCS l_342b
 AND #&7F
 ASL A
 TAY
 LDA &0880,Y
 JSR l_339a
 LDA &0881,Y
 CMP #&3F
 BEQ l_3468
 JMP l_339a

.l_342b

 SBC #&A0

.l_342d

 TAX
 LDY #&00
 STY &22
 LDA #&04
 STA &23
 TXA
 BEQ l_344e

.l_343b

 LDA (&22),Y
 BEQ l_3446
 INY
 BNE l_343b
 INC &23
 BNE l_343b

.l_3446

 INY
 BNE l_344b
 INC &23

.l_344b

 DEX
 BNE l_343b

.l_344e

 TYA
 PHA
 LDA &23
 PHA
 LDA (&22),Y
 EOR #&23
 JSR l_339a
 PLA
 STA &23
 PLA
 TAY
 INY
 BNE l_3464
 INC &23

.l_3464

 LDA (&22),Y
 BNE l_344e

.l_3468

 RTS

.l_3469

 LDA &65
 ORA #&A0
 STA &65
 RTS

.l_3470

 LDA &65
 AND #&40
 BEQ l_3479
 JSR l_34d3

.l_3479

 LDA &4C
 STA &D1
 LDA &4D
 CMP #&20
 BCC l_3487
 LDA #&FE
 BNE l_348f

.l_3487

 ASL &D1
 ROL A
 ASL &D1
 ROL A
 SEC
 ROL A

.l_348f

 STA &81
 LDY #&01
 LDA (&67),Y
 ADC #&04
 BCS l_3469
 STA (&67),Y
 JSR l_2965
 LDA &1B
 CMP #&1C
 BCC l_34a8
 LDA #&FE
 BNE l_34b1

.l_34a8

 ASL &82
 ROL A
 ASL &82
 ROL A
 ASL &82
 ROL A

.l_34b1

 DEY
 STA (&67),Y
 LDA &65
 AND #&BF
 STA &65
 AND #&08
 BEQ l_3468
 LDY #&02
 LDA (&67),Y
 TAY

.l_34c3

 LDA &F9,Y
 STA (&67),Y
 DEY
 CPY #&06
 BNE l_34c3
 LDA &65
 ORA #&40
 STA &65

.l_34d3

 LDY #&00
 LDA (&67),Y
 STA &81
 INY
 LDA (&67),Y
 BPL l_34e0
 EOR #&FF

.l_34e0

 LSR A
 LSR A
 LSR A
 ORA #&01
 STA &80
 INY
 LDA (&67),Y
 STA &8F
 LDA &01
 PHA
 LDY #&06

.l_34f1

 LDX #&03

.l_34f3

 INY
 LDA (&67),Y
 STA &D2,X
 DEX
 BPL l_34f3
 STY &93
 LDY #&02

.l_34ff

 INY
 LDA (&67),Y
 EOR &93
 STA &FFFD,Y
 CPY #&06
 BNE l_34ff
 LDY &80

.l_350d

 JSR l_3f85
 STA &88
 LDA &D3
 STA &82
 LDA &D2
 JSR l_354b
 BNE l_3545
 CPX #&BF
 BCS l_3545
 STX &35
 LDA &D5
 STA &82
 LDA &D4
 JSR l_354b
 BNE l_3533
 LDA &35
 JSR l_1932

.l_3533

 DEY
 BPL l_350d
 LDY &93
 CPY &8F
 BCC l_34f1
 PLA
 STA &01
 LDA &0906
 STA &03
 RTS

.l_3545

 JSR l_3f85
 JMP l_3533

.l_354b

 STA &83
 JSR l_3f85
 ROL A
 BCS l_355e
 JSR l_2847
 ADC &82
 TAX
 LDA &83
 ADC #&00
 RTS

.l_355e

 JSR l_2847
 STA &D1
 LDA &82
 SBC &D1
 TAX
 LDA &83
 SBC #&00
 RTS

.l_356d

 JSR l_3f3b
 LDA #&7F
 STA &63
 STA &64
 LDA home_tech
 AND #&02
 ORA #&80
 JMP l_3768

.l_3580

 LDA hype_dist
 LDY #3

.legal_div

 LSR hype_dist+1
 ROR A
 DEY
 BNE legal_div
 SEC
 SBC cmdr_legal
 BCC legal_over
 LDA #&FF

.legal_over

 EOR #&FF
 STA cmdr_legal
 \	LDA cmdr_legal
 \	BEQ legal_over
 \legal_next
 \	DEC cmdr_legal
 \	LSR a
 \	BNE legal_next
 \legal_over
 \\	LSR cmdr_legal
 JSR l_3f26
 LDA &6D
 AND #&03
 ADC #&03
 STA &4E
 ROR A
 STA &48
 STA &4B
 JSR l_356d
 LDA &6F
 AND #&07
 ORA #&81
 STA &4E
 LDA &71
 AND #&03
 STA &48
 STA &47
 LDA #&00
 STA &63
 STA &64
 LDA #&81
 JSR l_3768

.l_35b1

 LDA &87
 BNE l_35d8

.l_35b5

 LDY &03C3

.l_35b8

 JSR l_3f86
 ORA #&08
 STA &0FA8,Y
 STA &88
 JSR l_3f86
 STA &0F5C,Y
 STA &34
 JSR l_3f86
 STA &0F82,Y
 STA &35
 JSR l_1910
 DEY
 BNE l_35b8

.l_35d8

 LDX #&00

.l_35da

 LDA ship_type,X
 BEQ l_3602
 BMI l_35ff
 STA &8C
 JSR ship_ptr
 LDY #&1F

.l_35e8

 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_35e8
 STX &84
 JSR l_5558
 LDX &84
 LDY #&1F
 LDA (&20),Y
 AND #&A7
 STA (&20),Y

.l_35ff

 INX
 BNE l_35da

.l_3602

 LDX #&FF
 STX &0EC0
 STX &0F0E

.l_360a

 LDY #&BF
 LDA #&00

.l_360e

 STA &0E00,Y
 DEY
 BNE l_360e
 DEY
 STY &0E00
 RTS

.l_3619

 LDA #&06
 SEI
 STA &FE00
 STX &FE01
 CLI
 RTS

.l_3624

 DEX
 RTS

.l_3626

 INX
 BEQ l_3624

.l_3629

 DEC energy
 PHP
 BNE l_3632
 INC energy

.l_3632

 PLP
 RTS

.l_3642

 ASL A
 TAX
 LDA #&00
 ROR A
 TAY
 LDA #&14
 STA &81
 TXA
 JSR l_2965
 LDX &1B
 TYA
 BMI l_3658
 LDY #&00
 RTS

.l_3658

 LDY #&FF
 TXA
 EOR #&FF
 TAX
 INX
 RTS

.l_3634

 JSR l_3694
 LDY #&25
 LDA &0320
 BNE l_station
 LDY &9F	\ finder

.l_station

 JSR l_42ae
 LDA &34
 JSR l_3642
 TXA
 ADC #&C3
 STA &03A8
 LDA &35
 JSR l_3642
 STX &D1
 LDA #&CC
 SBC &D1
 STA &03A9
 LDA #&F0
 LDX &36
 BPL l_3691
 LDA #&FF

.l_3691

 STA &03C5

.l_3694

 LDA &03A9
 STA &35
 LDA &03A8
 STA &34
 LDA &03C5
 STA &91
 CMP #&F0
 BNE l_36ac

.l_36a7

 JSR l_36ac
 DEC &35

.l_36ac

 LDA &35
 TAY
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA &34
 AND #&F8
 STA ptr
 TYA
 AND #&07
 TAY
 LDA &34
 AND #&06
 LSR A
 TAX
 LDA pixels+&10,X
 AND &91
 EOR (ptr),Y
 STA (ptr),Y
 LDA pixels+&11,X
 BPL l_36dd
 LDA ptr
 ADC #&08
 STA ptr
 LDA pixels+&11,X

.l_36dd

 AND &91
 EOR (ptr),Y
 STA (ptr),Y
 RTS

.l_36e4

 SEC	\ reduce damage
 SBC new_shields
 BCC n_shok

.n_through

 STA &D1
 LDX #&00
 LDY #&08
 LDA (&20),Y
 BMI l_36fe
 LDA f_shield
 SBC &D1
 BCC l_36f9
 STA f_shield

.n_shok

 RTS

.l_36f9

 STX f_shield
 BCC l_370c

.l_36fe

 LDA r_shield
 SBC &D1
 BCC l_3709
 STA r_shield
 RTS

.l_3709

 STX r_shield

.l_370c

 ADC energy
 STA energy
 BEQ l_3716
 BCS l_3719

.l_3716

 JMP l_41c6

.l_3719

 JSR l_43b1
 JMP l_45ea

.l_371f

 LDA &0901,Y
 STA &D2,X
 LDA &0902,Y
 PHA
 AND #&7F
 STA &D3,X
 PLA
 AND #&80
 STA &D4,X
 INY
 INY
 INY
 INX
 INX
 INX
 RTS

.ship_ptr

 TXA
 ASL A
 TAY
 LDA l_1695,Y
 STA &20
 LDA l_1695+&01,Y
 STA &21
 RTS

.l_3740

 JSR l_3821
 LDX #&81
 STX &66
 LDX #&FF
 STX &63
 INX
 STX &64
 STX ship_type+&01
 STX &67
 LDA cmdr_legal
 BPL n_enemy
 LDX #&04

.n_enemy

 STX &6A
 LDX #&0A
 JSR l_37fc
 JSR l_37fc
 STX &68
 JSR l_37fc
 LDA #&02

.l_3768

 STA &D1
 LDX #&00

.l_376c

 LDA ship_type,X
 BEQ l_3778
 INX
 CPX #&0C
 BCC l_376c

.l_3776

 CLC

.l_3777

 RTS

.l_3778

 JSR ship_ptr
 LDA &D1
 BMI l_37d1
 ASL A
 TAY
 LDA &55FF,Y
 BEQ l_3776
 STA &1F
 LDA &55FE,Y
 STA &1E
 CPY #&04
 BEQ l_37c1
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
 BCC l_3777
 BNE l_37b7
 CPY #&25
 BCC l_3777

.l_37b7

 LDA &67
 STA &03B0
 LDA &68
 STA &03B1

.l_37c1

 LDY #&0E
 LDA (&1E),Y
 STA &69
 LDY #&13
 LDA (&1E),Y
 AND #&07
 STA &65
 LDA &D1

.l_37d1

 STA ship_type,X
 TAX
 BMI l_37e5
 CPX #&03
 BCC l_37e2
 CPX #&0B
 BCS l_37e2
 INC &033E

.l_37e2

 INC &031E,X

.l_37e5

 LDY &D1
 LDA l_563d,Y
 AND #&6F
 ORA &6A
 STA &6A
 LDY #&24

.l_37f2

 LDA &46,Y
 STA (&20),Y
 DEY
 BPL l_37f2
 SEC
 RTS

.l_37fc

 LDA &46,X
 EOR #&80
 STA &46,X
 INX
 INX
 RTS

.l_3805

 LDX #&FF

.l_3807

 STX &45
 LDX cmdr_misl
 DEX
 JSR l_383d
 STY target
 RTS

.l_3813

 LDA #&20
 STA &30
 ASL A
 JSR l_43f3

.l_381b

 LDA #&38
 LDX #LO(l_3832)
 BNE l_3825

.l_3821

 LDA #&C0
 LDX #LO(l_3832)+3

.l_3825

 LDY #HI(l_3832)
 STA ptr
 LDA #&7D
 STX font
 STY font+&01
 JMP l_1f45

.l_3832

 EQUB &E0, &E0, &80, &E0, &E0, &80, &E0, &E0, &20, &E0, &E0

.l_383d

 CPX #4
 BCC n_mok
 LDX #3

.n_mok

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

.l_3850

 STA (ptr),Y
 DEY
 BNE l_3850
 RTS

.l_3856

 LDA &46
 STA &1B
 LDA &47
 STA font
 LDA &48
 JSR l_3cfa
 BCS l_388d
 LDA &40
 ADC #&80
 STA &D2
 TXA
 ADC #&00
 STA &D3
 LDA &49
 STA &1B
 LDA &4A
 STA font
 LDA &4B
 EOR #&80
 JSR l_3cfa
 BCS l_388d
 LDA &40
 ADC #&60
 STA &E0
 TXA
 ADC #&00
 STA &E1
 CLC

.l_388d

 RTS

.l_388e

 LDA &8C
 LSR A
 BCS l_3896
 JMP l_3bed

.l_3896

 JMP l_3c30

.l_3899

 LDA &4E
 BMI l_388e
 CMP #&30
 BCS l_388e
 ORA &4D
 BEQ l_388e
 JSR l_3856
 BCS l_388e
 LDA #&60
 STA font
 LDA #&00
 STA &1B
 JSR l_297e
 LDA &41
 BEQ l_38bd
 LDA #&F8
 STA &40

.l_38bd

 LDA &8C
 LSR A
 BCC l_38c5
 JMP l_3a54

.l_38c5

 JSR l_3bed
 JSR l_3b76
 BCS l_38d1
 LDA &41
 BEQ l_38d2

.l_38d1

 RTS

.l_38d2

 LDA &8C
 CMP #&80
 BNE l_3914
 LDA &40
 CMP #&06
 BCC l_38d1
 LDA &54
 EOR #&80
 STA &1B
 LDA &5A
 JSR l_3cdb
 LDX #&09
 JSR l_3969
 STA &9B
 STY &09
 JSR l_3969
 STA &9C
 STY &0A
 LDX #&0F
 JSR l_3ceb
 JSR l_3987
 LDA &54
 EOR #&80
 STA &1B
 LDA &60
 JSR l_3cdb
 LDX #&15
 JSR l_3ceb
 JMP l_3987

.l_3914

 LDA &5A
 BMI l_38d1
 LDX #&0F
 JSR l_3cba
 CLC
 ADC &D2
 STA &D2
 TYA
 ADC &D3
 STA &D3
 JSR l_3cba
 STA &1B
 LDA &E0
 SEC
 SBC &1B
 STA &E0
 STY &1B
 LDA &E1
 SBC &1B
 STA &E1
 LDX #&09
 JSR l_3969
 LSR A
 STA &9B
 STY &09
 JSR l_3969
 LSR A
 STA &9C
 STY &0A
 LDX #&15
 JSR l_3969
 LSR A
 STA &9D
 STY &0B
 JSR l_3969
 LSR A
 STA &9E
 STY &0C
 LDA #&40
 STA &8F
 LDA #&00
 STA &94
 BEQ l_398b

.l_3969

 LDA &46,X
 STA &1B
 LDA &47,X
 AND #&7F
 STA font
 LDA &47,X
 AND #&80
 JSR l_297e
 LDA &40
 LDY &41
 BEQ l_3982
 LDA #&FE

.l_3982

 LDY &43
 INX
 INX
 RTS

.l_3987

 LDA #&1F
 STA &8F

.l_398b

 LDX #&00
 STX &93
 DEX
 STX &92

.l_3992

 LDA &94
 AND #&1F
 TAX
 LDA &07C0,X
 STA &81
 LDA &9D
 JSR l_2847
 STA &82
 LDA &9E
 JSR l_2847
 STA &40
 LDX &94
 CPX #&21
 LDA #&00
 ROR A
 STA &0E
 LDA &94
 CLC
 ADC #&10
 AND #&1F
 TAX
 LDA &07C0,X
 STA &81
 LDA &9C
 JSR l_2847
 STA &42
 LDA &9B
 JSR l_2847
 STA &1B
 LDA &94
 ADC #&0F
 AND #&3F
 CMP #&21
 LDA #&00
 ROR A
 STA &0D
 LDA &0E
 EOR &0B
 STA &83
 LDA &0D
 EOR &09
 JSR l_28ff
 STA &D1
 BPL l_39fb
 TXA
 EOR #&FF
 CLC
 ADC #&01
 TAX
 LDA &D1
 EOR #&7F
 ADC #&00
 STA &D1

.l_39fb

 TXA
 ADC &D2
 STA &76
 LDA &D1
 ADC &D3
 STA &77
 LDA &40
 STA &82
 LDA &0E
 EOR &0C
 STA &83
 LDA &42
 STA &1B
 LDA &0D
 EOR &0A
 JSR l_28ff
 EOR #&80
 STA &D1
 BPL l_3a30
 TXA
 EOR #&FF
 CLC
 ADC #&01
 TAX
 LDA &D1
 EOR #&7F
 ADC #&00
 STA &D1

.l_3a30

 JSR l_196b
 CMP &8F
 BEQ l_3a39
 BCS l_3a45

.l_3a39

 LDA &94
 CLC
 ADC &95
 AND #&3F
 STA &94
 JMP l_3992

.l_3a45

 RTS

.l_3a46

 JMP l_3c30

.l_3a49

 TXA
 EOR #&FF
 TAX
 INX

.l_3a50

 LDA #&FF
 BNE l_3a99

.l_3a54

 LDA #&01
 STA &0E00
 JSR l_3c80
 BCS l_3a46
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
 LDX font+&01
 BNE l_3a7d
 CMP font
 BCC l_3a7d
 LDA font
 BNE l_3a7d
 LDA #&01

.l_3a7d

 STA &8F
 LDA #&BF
 SEC
 SBC &E0
 TAX
 LDA #&00
 SBC &E1
 BMI l_3a49
 BNE l_3a95
 INX
 DEX
 BEQ l_3a50
 CPX &40
 BCC l_3a99

.l_3a95

 LDX &40
 LDA #&00

.l_3a99

 STX &22
 STA &23
 LDA &40
 JSR l_280d
 STA &9C
 LDA &1B
 STA &9B
 LDY #&BF
 LDA &28
 STA &26
 LDA &29
 STA &27

.l_3ab2

 CPY &8F
 BEQ l_3ac1
 LDA &0E00,Y
 BEQ l_3abe
 JSR l_185e

.l_3abe

 DEY
 BNE l_3ab2

.l_3ac1

 LDA &22
 JSR l_280d
 STA &D1
 LDA &9B
 SEC
 SBC &1B
 STA &81
 LDA &9C
 SBC &D1
 STA &82
 STY &35
 JSR l_47b8
 LDY &35
 JSR l_3f86
 AND &93
 CLC
 ADC &81
 BCC l_3ae8
 LDA #&FF

.l_3ae8

 LDX &0E00,Y
 STA &0E00,Y
 BEQ l_3b3a
 LDA &28
 STA &26
 LDA &29
 STA &27
 TXA
 JSR l_3c4f
 LDA &34
 STA &24
 LDA &36
 STA &25
 LDA &D2
 STA &26
 LDA &D3
 STA &27
 LDA &0E00,Y
 JSR l_3c4f
 BCS l_3b1f
 LDA &36
 LDX &24
 STX &36
 STA &24
 JSR l_1868

.l_3b1f

 LDA &24
 STA &34
 LDA &25
 STA &36

.l_3b27

 JSR l_1868

.l_3b2a

 DEY
 BEQ l_3b6c
 LDA &23
 BNE l_3b4e
 DEC &22
 BNE l_3ac1
 DEC &23

.l_3b37

 JMP l_3ac1

.l_3b3a

 LDX &D2
 STX &26
 LDX &D3
 STX &27
 JSR l_3c4f
 BCC l_3b27
 LDA #&00
 STA &0E00,Y
 BEQ l_3b2a

.l_3b4e

 LDX &22
 INX
 STX &22
 CPX &40
 BCC l_3b37
 BEQ l_3b37
 LDA &28
 STA &26
 LDA &29
 STA &27

.l_3b61

 LDA &0E00,Y
 BEQ l_3b69
 JSR l_185e

.l_3b69

 DEY
 BNE l_3b61

.l_3b6c

 CLC
 LDA &D2
 STA &28
 LDA &D3
 STA &29

.l_3b75

 RTS

.l_3b76

 JSR l_3c80
 BCS l_3b75
 LDA #&00
 STA &0EC0
 LDX &40
 LDA #&08
 CPX #&08
 BCC l_3b8e
 LSR A
 CPX #&3C
 BCC l_3b8e
 LSR A

.l_3b8e

 STA &95

.l_3b90

 LDX #&FF
 STX &92
 INX
 STX &93

.l_3b97

 LDA &93
 JSR l_283d
 LDX #&00
 STX &D1
 LDX &93
 CPX #&21
 BCC l_3bb3
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 TXA
 CLC

.l_3bb3

 ADC &D2
 STA &76
 LDA &D3
 ADC &D1
 STA &77
 LDA &93
 CLC
 ADC #&10
 JSR l_283d
 TAX
 LDA #&00
 STA &D1
 LDA &93
 ADC #&0F
 AND #&3F
 CMP #&21
 BCC l_3be1
 TXA
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 CLC

.l_3be1

 JSR l_196b
 CMP #&41
 BCS l_3beb
 JMP l_3b97

.l_3beb

 CLC
 RTS

.l_3bed

 LDY &0EC0
 BNE l_3c26

.l_3bf2

 CPY &6B
 BCS l_3c26
 LDA &0F0E,Y
 CMP #&FF
 BEQ l_3c17
 STA &37
 LDA &0EC0,Y
 STA &36
 JSR l_16c4
 INY
 LDA &90
 BNE l_3bf2
 LDA &36
 STA &34
 LDA &37
 STA &35
 JMP l_3bf2

.l_3c17

 INY
 LDA &0EC0,Y
 STA &34
 LDA &0F0E,Y
 STA &35
 INY
 JMP l_3bf2

.l_3c26

 LDA #&01
 STA &6B
 LDA #&FF
 STA &0EC0

.l_3c2f

 RTS

.l_3c30

 LDA &0E00
 BMI l_3c2f
 LDA &28
 STA &26
 LDA &29
 STA &27
 LDY #&BF

.l_3c3f

 LDA &0E00,Y
 BEQ l_3c47
 JSR l_185e

.l_3c47

 DEY
 BNE l_3c3f
 DEY
 STY &0E00
 RTS

.l_3c4f

 STA &D1
 CLC
 ADC &26
 STA &36
 LDA &27
 ADC #&00
 BMI l_3c79
 BEQ l_3c62
 LDA #&FE
 STA &36

.l_3c62

 LDA &26
 SEC
 SBC &D1
 STA &34
 LDA &27
 SBC #&00
 BEQ n_clcrts
 BPL l_3c79
 LDA #&02
 STA &34

.n_clcrts

 CLC
 RTS

.l_3c79

 LDA #&00
 STA &0E00,Y
 SEC
 RTS

.l_3c80

 LDA &D2
 CLC
 ADC &40
 LDA &D3
 ADC #&00
 BMI l_3cb8
 LDA &D2
 SEC
 SBC &40
 LDA &D3
 SBC #&00
 BMI l_3c98
 BNE l_3cb8

.l_3c98

 LDA &E0
 CLC
 ADC &40
 STA font
 LDA &E1
 ADC #&00
 BMI l_3cb8
 STA font+&01
 LDA &E0
 SEC
 SBC &40
 TAX
 LDA &E1
 SBC #&00
 BMI l_3d1d
 BNE l_3cb8
 CPX #&BF
 RTS

.l_3cb8

 SEC
 RTS

.l_3cba

 JSR l_3969
 STA &1B
 LDA #&DE
 STA &81
 STX &80
 JSR l_2820
 LDX &80
 LDY &43
 BPL l_3cd8
 EOR #&FF
 CLC
 ADC #&01
 BEQ l_3cd8
 LDY #&FF
 RTS

.l_3cd8

 LDY #&00
 RTS

.l_3cdb

 STA &81
 JSR l_2a3c
 LDX &54
 BMI l_3ce6
 EOR #&80

.l_3ce6

 LSR A
 LSR A
 STA &94
 RTS

.l_3ceb

 JSR l_3969
 STA &9D
 STY &0B
 JSR l_3969
 STA &9E
 STY &0C
 RTS

.l_3cfa

 JSR l_297e
 LDA &43
 AND #&7F
 ORA &42
 BNE l_3cb8
 LDX &41
 CPX #&04
 BCS l_3d1e
 LDA &43
 BPL l_3d1e
 LDA &40
 EOR #&FF
 ADC #&01
 STA &40
 TXA
 EOR #&FF
 ADC #&00
 TAX

.l_3d1d

 CLC

.l_3d1e

 RTS

.l_3d1f

 JSR l_44af
 LDA k_flag
 BEQ l_3d4c
 LDA adval_x
 EOR #&FF
 JSR l_3d34
 TYA
 TAX
 LDA adval_y

.l_3d34

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

.l_3d4c

 LDA last_key
 LDX #&00
 LDY #&00
 CMP #&19
 BNE l_3d58
 DEX

.l_3d58

 CMP #&79
 BNE l_3d5d
 INX

.l_3d5d

 CMP #&39
 BNE l_3d62
 INY

.l_3d62

 CMP #&29
 BNE l_3d67
 DEY

.l_3d67

 RTS

.l_3d68

 LDX #&01

.l_3d6a

 LDA cmdr_homex,X
 STA data_homex,X
 DEX
 BPL l_3d6a
 RTS

.l_3d74

 LDA &1B
 STA &03B0
 LDA font
 STA &03B1
 RTS

.l_3d7f

 LDX &84
 JSR l_3dd8
 LDX &84
 JMP l_1376

.l_3d89

 JSR l_3f26
 JSR l_360a
 STA ship_type+&01
 STA &0320
 JSR l_3821
 LDA #&06
 STA &4B
 LDA #&81
 JMP l_3768

.l_3da1

 LDX #&FF

.l_3da3

 INX
 LDA ship_type,X
 BEQ l_3d74
 CMP #&01
 BNE l_3da3
 TXA
 ASL A
 TAY
 LDA l_1695,Y
 STA ptr
 LDA l_1695+&01,Y
 STA ptr+&01
 LDY #&20
 LDA (ptr),Y
 BPL l_3da3
 AND #&7F
 LSR A
 CMP &96
 BCC l_3da3
 BEQ l_3dd2
 SBC #&01
 ASL A
 ORA #&80
 STA (ptr),Y
 BNE l_3da3

.l_3dd2

 LDA #&00
 STA (ptr),Y
 BEQ l_3da3

.l_3dd8

 STX &96
 CPX &45
 BNE l_3de8
 LDY #&EE
 JSR l_3805
 LDA #&C8
 JSR l_45c6

.l_3de8

 LDY &96
 LDX ship_type,Y
 CPX #&02
 BEQ l_3d89
 CPX #&1F
 BNE l_3dfd
 LDA cmdr_mission
 ORA #&02
 STA cmdr_mission

.l_3dfd

 CPX #&03
 BCC l_3e08
 CPX #&0B
 BCS l_3e08
 DEC &033E

.l_3e08

 DEC &031E,X
 LDX &96
 LDY #&05
 LDA (&1E),Y
 LDY #&21
 CLC
 ADC (&20),Y
 STA &1B
 INY
 LDA (&20),Y
 ADC #&00
 STA font

.l_3e1f

 INX
 LDA ship_type,X
 STA &0310,X
 BNE l_3e2b
 JMP l_3da1

.l_3e2b

 ASL A
 TAY
 LDA &55FE,Y
 STA ptr
 LDA &55FF,Y
 STA ptr+&01
 LDY #&05
 LDA (ptr),Y
 STA &D1
 LDA &1B
 SEC
 SBC &D1
 STA &1B
 LDA font
 SBC #&00
 STA font
 TXA
 ASL A
 TAY
 LDA l_1695,Y
 STA ptr
 LDA l_1695+&01,Y
 STA ptr+&01
 LDY #&24
 LDA (ptr),Y
 STA (&20),Y
 DEY
 LDA (ptr),Y
 STA (&20),Y
 DEY
 LDA (ptr),Y
 STA &41
 LDA font
 STA (&20),Y
 DEY
 LDA (ptr),Y
 STA &40
 LDA &1B
 STA (&20),Y
 DEY

.l_3e75

 LDA (ptr),Y
 STA (&20),Y
 DEY
 BPL l_3e75
 LDA ptr
 STA &20
 LDA ptr+&01
 STA &21
 LDY &D1

.l_3e86

 DEY
 LDA (&40),Y
 STA (&1B),Y
 TYA
 BNE l_3e86
 BEQ l_3e1f

.l_3e90

 EQUB &12, &01, &00, &10, &12, &02, &2C, &08, &11, &03, &F0, &18
 EQUB &10, &F1, &07, &1A, &03, &F1, &BC, &01, &13, &F4, &0C, &08
 EQUB &10, &F1, &06, &0C, &10, &02, &60, &10, &13, &04, &C2, &FF
 EQUB &13, &00, &00, &00

.rand_posn

 JSR l_3f26
 JSR l_3f86
 STA &46
 STX &49
 STA &06
 LSR A
 ROR &48
 LSR A
 ROR &4B
 LSR A
 STA &4A
 TXA
 AND #&1F
 STA &47
 LDA #&50
 SBC &47
 SBC &4A
 STA &4D
 JMP l_3f86

.l_3eb8

 LDX cmdr_galxy
 DEX
 BNE l_3ecc
 LDA cmdr_homex
 CMP #&90
 BNE l_3ecc
 LDA cmdr_homey
 CMP #&21
 BEQ l_3ecd

.l_3ecc

 CLC

.l_3ecd

 RTS

.l_3ece

 JSR clr_ships
 LDX #&08

.l_3ed3

 STA &2A,X
 DEX
 BPL l_3ed3
 TXA
 LDX #&02

.l_3edb

 STA f_shield,X
 DEX
 BPL l_3edb

.l_3ee1

 LDA #&12
 STA &03C3
 LDX #&FF
 STX &0EC0
 STX &0F0E
 STX &45
 LDA #&80
 STA adval_x
 STA adval_y
 ASL A
 STA &8A
 STA &2F
 LDA #&03
 STA &7D
 LDA &0320
 BEQ l_3f09
 JSR l_3821

.l_3f09

 LDA &30
 BEQ l_3f10
 JSR l_43a3

.l_3f10

 JSR l_35d8
 JSR clr_ships
 LDA #&FF
 STA &03B0
 LDA #&0C
 STA &03B1
 JSR l_1f62
 JSR l_44a4

.l_3f26

 LDY #&24
 LDA #&00

.l_3f2a

 STA &46,Y
 DEY
 BPL l_3f2a
 LDA #&60
 STA &58
 STA &5C
 ORA #&80
 STA &54
 RTS

.l_3f3b

 LDX #&03

.l_3f3d

 LDY #&00
 CPX cmdr_misl
 BCS miss_miss	\BCC l_3f4b
 LDY #&EE

.miss_miss

 JSR l_383d
 DEX
 BPL l_3f3d
 RTS
 \l_3f4b
 \	LDY #&EE
 \	JSR l_383d
 \	DEX
 \	BPL l_3f4b
 \	RTS

.l_3f54

 LDA &03A4
 JSR l_45c6
 LDA #&00
 STA &034A
 JMP l_3fcd

.l_3f62

 JSR rand_posn	\ IN
 CMP #&F5
 ROL A
 ORA #&C0
 STA &66

.l_3f85

 CLC

.l_3f86

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

.l_3f9a

 JSR l_3f86
 LSR A
 STA &66
 STA &63
 ROL &65
 AND #&0F
 STA &61
 JSR l_3f86
 BMI l_3fb9
 LDA &66
 ORA #&C0
 STA &66
 LDX #&10
 STX &6A

.l_3fb9

 LDA #&0B
 LDX #&03
 JMP hordes

.l_3fc0

 JSR l_1228
 DEC &034A
 BEQ l_3f54
 BPL l_3fcd
 INC &034A

.l_3fcd

 DEC &8A
 BEQ l_3fd4

.l_3fd1

 JMP l_40db

.l_3fd4

 LDA &0341
 BNE l_3fd1
 JSR l_3f86
 CMP #&33	\ trader fraction
 BCS l_402e
 LDA &033E
 CMP #&03
 BCS l_402e
 JSR rand_posn	\ IN
 BVS l_3f9a
 ORA #&6F
 STA &63
 LDA &0320
 BNE l_4033
 TXA
 BCS l_401e
 AND #&0F
 STA &61
 BCC l_4022

.l_401e

 ORA #&7F
 STA &64

.l_4022

 JSR l_3f86
 CMP #&0A
 AND #&01
 ADC #&05
 BNE horde_plain

.l_402e

 LDA &0320
 BEQ l_4036

.l_4033

 JMP l_40db

.l_4036

 JSR l_41a6
 ASL A
 LDX &032E
 BEQ l_4042
 ORA cmdr_legal

.l_4042

 STA &D1
 JSR l_3f62
 CMP &D1
 BCS l_4050
 LDA #&10

.horde_plain

 LDX #&00
 BEQ hordes

.l_4050

 LDA &032E
 BNE l_4033
 DEC &0349
 BPL l_4033
 INC &0349
 LDA cmdr_mission
 AND #&0C
 CMP #&08
 BNE l_4070
 JSR l_3f86
 CMP #&C8
 BCC l_4070
 JSR l_320e

.l_4070

 JSR l_3f86
 LDY home_govmt
 BEQ l_4083
 CMP #&78
 BCS l_4033
 AND #&07
 CMP home_govmt
 BCC l_4033

.l_4083

 CPX #&64
 BCS l_40b2
 INC &0349
 AND #&03
 ADC #&19
 TAY
 JSR l_3eb8
 BCC l_40a8
 LDA #&F9
 STA &66
 LDA cmdr_mission
 AND #&03
 LSR A
 BCC l_40a8
 ORA &033D
 BEQ l_40aa

.l_40a8

 TYA
 EQUB &2C

.l_40aa

 LDA #&1F
 JSR l_3768
 JMP l_40db

.l_40b2

 LDA #&11
 LDX #&07

.hordes

 STA horde_base+1
 STX horde_mask+1
 JSR l_3f86
 CMP #&F8
 BCS horde_large
 STA &89
 TXA
 AND &89
 AND #&03

.horde_large

 AND #&07
 STA &0349
 STA &89

.l_40b9

 JSR l_3f86
 STA &D1
 TXA
 AND &D1

.horde_mask

 AND #&FF
 STA &0FD2

.l_40c8

 LDA &0FD2
 CLC

.horde_base

 ADC #&00
 INC &61	\ space out horde
 INC &47
 INC &4A
 JSR l_3768
 CMP #&18
 BCS l_40d7
 DEC &0FD2
 BPL l_40c8

.l_40d7

 DEC &89
 BPL l_40b9

.l_40db

 LDX #&FF
 TXS
 LDX laser_t
 BEQ l_40e6
 DEC laser_t

.l_40e6

 JSR l_1f62
 LDA &87
 BEQ l_40f8
 \	AND x_flag
 \	LSR A
 \	BCS l_40f8
 LDY #&02
 JSR l_5530

.l_40f8

 JSR l_3d1f

.l_40fb

 PHA
 LDA &2F
 BNE l_locked
 PLA
 JSR l_4101
 JMP l_3fc0

.l_locked

 PLA
 JSR l_416c
 JMP l_3fc0

.l_4101

 CMP #&76
 BNE l_4108
 JMP l_1c83

.l_4108

 CMP #&14
 BNE l_410f
 JMP l_2ceb

.l_410f

 CMP #&74
 BNE l_4116
 JMP l_2ebe

.l_4116

 CMP #&75
 BNE l_4120
 JSR l_2f75
 JMP l_2b73

.l_4120

 CMP #&77
 BNE l_4127
 JMP l_2e15

.l_4127

 CMP #&16
 BNE l_412e
 JMP l_3160

.l_412e

 CMP #&20
 BNE l_4135
 JMP l_3292

.l_4135

 CMP #&71
 BCC l_4143
 CMP #&74
 BCS l_4143
 AND #&03
 TAX
 JMP l_5493

.l_4143

 CMP #&54
 BNE l_414a
 JMP l_3011

.l_414a

 CMP #&32
 BEQ l_418b
 CMP #&43	\ planet finder
 BNE n_finder
 LDA &9F
 EOR #&25
 STA &9F
 JMP l_55f7	\RTS

.n_finder

 STA &06
 LDA &87
 AND #&C0
 BEQ l_416c
 LDA &06
 CMP #&36
 BNE l_notdist
 JSR l_2e65
 JSR l_3d68
 JMP l_2e65	\JSR l_2e65

.l_4169

 JSR l_2e38

.l_416c

 LDA &2F
 BEQ l_418a
 DEC &2E
 BNE l_418a
 LDX &2F
 DEX
 JSR l_30ac
 LDA #&05
 STA &2E
 LDX &2F
 JSR l_30ac
 DEC &2F
 BNE l_418a
 JMP l_3254

.l_41a6

 LDA cmdr_cargo+&03
 CLC
 ADC cmdr_cargo+&06
 ASL A
 ADC cmdr_cargo+&0A
 \	RTS

.l_418a

 RTS

.l_notdist

 CMP #&21
 BNE l_4169
 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ l_4169
 JSR l_2e65
 LDA cmdr_courx
 STA data_homex
 LDA cmdr_coury
 STA data_homey
 JSR l_2e65

.l_418b

 LDA &87
 AND #&C0
 BEQ l_418a
 JSR l_32fe
 STA vdu_stat
 JSR l_330a
 JSR vdu_80
 LDA #&01
 STA cursor_x
 INC cursor_y
 JMP l_2b3b

.l_41b2

 LDA #&E0

.l_41b4

 CMP &47
 BCC l_41be
 CMP &4A
 BCC l_41be
 CMP &4D

.l_41be

 RTS

.l_41bf

 ORA &47
 ORA &4A
 ORA &4D
 RTS

.l_41c6

 JSR l_43b1
 JSR l_3ee1
 ASL &7D
 ASL &7D
 LDX #&18
 JSR l_3619
 JSR l_54c8
 JSR l_54eb
 JSR l_35b5
 LDA #&0C
 STA cursor_y
 STA cursor_x
 LDA #&92
 JSR l_342d

.l_41e9

 JSR l_3f62
 LSR A
 LSR A
 STA &46
 LDY #&00
 STY &87
 STY &47
 STY &4A
 STY &4D
 STY &66
 DEY
 STY &8A
 STY &0346
 EOR #&2A
 STA &49
 ORA #&50
 STA &4C
 TXA
 AND #&8F
 STA &63
 ROR A
 AND #&87
 STA &64
 LDX #&05
 LDA &5607
 BEQ l_421e
 BCC l_421e
 DEX

.l_421e

 JSR l_251d
 JSR l_3f86
 AND #&80
 LDY #&1F
 STA (&20),Y
 LDA ship_type+&04
 BEQ l_41e9
 JSR l_44a4
 STA &7D

.l_4234

 JSR l_1228
 LDA &0346
 BNE l_4234
 LDX #&1F
 JSR l_3619
 JMP l_1220

.start

 JSR l_4255
 JSR l_3ece
 LDA #&FF
 STA &8E
 STA &87
 LDA #&20
 JMP l_40fb

.l_4255

 LDA #0
 STA &9F	\ reset finder
 JSR l_3eb8
 LDA #&06
 BCS l_427e
 JSR l_3f86
 AND #&03
 LDX home_govmt
 CPX #&03
 ROL A
 LDX home_tech
 CPX #&0A
 ROL A
 ADC cmdr_galxy	\ 16+7 -> 23 files !
 TAX
 LDA cmdr_mission
 AND #&0C
 CMP #&08
 BNE l_427d
 TXA
 AND #&01
 ORA #&02
 TAX

.l_427d

 TXA

.l_427e

 CLC
 ADC #&41
 STA d_mox+&04
 LDX #LO(d_mox)
 LDY #HI(d_mox)
 JMP oscli

.d_mox

 EQUS "L.S.0", &0D

.clr_ships

 LDX #&3A
 LDA #&00

.l_429a

 STA ship_type,X
 DEX
 BPL l_429a
 RTS

.l_42a1

 STX ptr+&01
 LDA #&00
 STA ptr
 TAY

.l_42a8

 STA (ptr),Y
 DEY
 BNE l_42a8
 RTS

.l_42ae

 LDX #&00
 JSR l_371f
 JSR l_371f
 JSR l_371f

.l_42bd

 LDA &D2
 ORA &D5
 ORA &D8
 ORA #&01
 STA &DB
 LDA &D3
 ORA &D6
 ORA &D9

.l_42cd

 ASL &DB
 ROL A
 BCS l_42e0
 ASL &D2
 ROL &D3
 ASL &D5
 ROL &D6
 ASL &D8
 ROL &D9
 BCC l_42cd

.l_42e0

 LDA &D3
 LSR A
 ORA &D4
 STA &34
 LDA &D6
 LSR A
 ORA &D7
 STA &35
 LDA &D9
 LSR A
 ORA &DA
 STA &36

.l_42f5

 LDA &34
 JSR l_280b
 STA &82
 LDA &1B
 STA &81
 LDA &35
 JSR l_280b
 \	STA &D1
 TAY
 LDA &1B
 ADC &81
 STA &81
 \	LDA &D1
 TYA
 ADC &82
 STA &82
 LDA &36
 JSR l_280b
 \	STA &D1
 TAY
 LDA &1B
 ADC &81
 STA &81
 \	LDA &D1
 TYA
 ADC &82
 STA &82
 JSR l_47b8
 LDA &34
 JSR l_46ff
 STA &34
 LDA &35
 JSR l_46ff
 STA &35
 LDA &36
 JSR l_46ff
 STA &36
 RTS

.l_433f

 LDX #&10

.l_4341

 JSR l_4439
 BMI l_434a
 INX
 BPL l_4341
 TXA

.l_434a

 EOR #&80
 TAX
 RTS

.l_434e

 LDX &033E
 LDA ship_type+&02,X
 ORA &033E	\ no jump if any ship
 ORA &0320
 ORA &0341
 BNE l_439f
 LDY &0908
 BMI l_4368
 TAY
 JSR l_1c43
 LSR A
 BEQ l_439f

.l_4368

 LDY &092D
 BMI l_4375
 LDY #&25
 JSR l_1c41
 LSR A
 BEQ l_439f

.l_4375

 LDA #&81
 STA &83
 STA &82
 STA &1B
 LDA &0908
 JSR l_28ff
 STA &0908
 LDA &092D
 JSR l_28ff
 STA &092D
 LDA #&01
 STA &87
 STA &8A
 LSR A
 STA &0349
 LDX view_dirn
 JMP l_5493

.l_439f

 LDA #&28
 BNE l_43f3

.l_43a3

 LDA #&00
 STA &30
 STA &0340
 JSR l_381b
 LDA #&48
 BNE l_43f3

.l_43b1

 JSR n_sound10
 LDA #&18
 BNE l_43f3

.l_43ba

 LDA #&20
 BNE l_43f3

.l_43be

 LDX #&01
 JSR l_2590
 BCC l_4418
 LDA #&78
 JSR l_45c6

.n_sound30

 LDA #&30
 BNE l_43f3

.l_43ce

 INC cmdr_kills
 BNE l_43db
 INC cmdr_kills+&01
 LDA #&65
 JSR l_45c6

.l_43db

 LDX #&07

.l_43dd

 STX &D1
 LDA #&18
 JSR l_4404
 LDA &4D
 LSR A
 LSR A
 AND &D1
 ORA #&F1
 STA &0B
 JSR l_43f6

.n_sound10

 LDA #&10

.l_43f3

 JSR l_4404

.l_43f6

 \	LDX s_flag
 LDY s_flag
 BNE l_4418
 LDX #&09
 \	LDY #&00
 LDA #&07
 JMP osword

.l_4404

 LSR A
 ADC #&03
 TAY
 LDX #&07

.l_440a

 LDA #&00
 STA &09,X
 DEX
 LDA l_3e90,Y
 STA &09,X
 DEY
 DEX
 BPL l_440a

.l_4418

 RTS

.l_4419

 EQUB &E8, &E2, &E6, &E7, &C2, &D1, &C1
 EQUB &60, &70, &23, &35, &65, &22, &45, &63, &37

.b_table

 EQUB &61, &31, &80, &80, &80, &80, &51
 EQUB &64, &34, &32, &62, &52, &54, &58, &38, &68

.b_13

 LDA #&00

.b_14

 TAX
 EOR b_table-1,Y
 BEQ b_quit
 STA &FE60
 AND #&0F
 AND &FE60
 BEQ b_pressed
 TXA
 BMI b_13
 RTS

.l_4429

 LDA b_flag
 BMI b_14
 LDX l_4419-1,Y
 JSR l_4439
 BPL b_quit

.b_pressed

 LDA #&FF
 STA last_key,Y

.b_quit

 RTS

.l_4437

 LDX #&01

.l_4439

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

.l_4452

 LDA #&80
 JSR osbyte
 TYA
 EOR j_flag
 RTS

.l_445c

 STY &D1
 CPX &D1
 BNE l_4472
 LDA &0387,X
 EOR #&FF
 STA &0387,X
 JSR l_1efa
 JSR l_5530
 LDY &D1

.l_4472

 RTS

.l_4473

 LDA &033F
 BNE l_44c7
 LDY #&01
 JSR l_4429
 INY
 JSR l_4429
 LDA #&51
 STA &FE60
 LDA &FE40
 TAX
 AND #&10
 EOR #&10
 STA &0307
 LDX #&01
 JSR l_4452
 ORA #&01
 STA adval_x
 LDX #&02
 JSR l_4452
 EOR y_flag
 STA adval_y
 JMP l_4555

.l_44a4

 LDA #&00
 LDY #&10

.l_44a8

 STA last_key,Y
 DEY
 BNE l_44a8
 RTS

.l_44af

 JSR l_44a4
 LDA &2F
 BEQ l_open
 JMP l_4555

.l_open

 LDA k_flag
 BNE l_4473
 \	STA b_flag
 LDY #&07

.l_44bc

 JSR l_4429
 DEY
 BNE l_44bc
 LDA &033F
 BEQ l_4526

.l_44c7

 JSR l_3f26
 LDA #&60
 STA &54
 ORA #&80
 STA &5C
 STA &8C
 LDA &7D	\ ? Too Fast
 STA &61
 JSR l_2346
 LDA &61
 CMP #&16
 BCC l_44e3
 LDA #&16

.l_44e3

 STA &7D
 LDA #&FF
 LDX #&00
 LDY &62
 BEQ l_44f3
 BMI l_44f0
 INX

.l_44f0

 STA &0301,X

.l_44f3

 LDA #&80
 LDX #&00
 ASL &63
 BEQ l_450f
 BCC l_44fe
 INX

.l_44fe

 BIT &63
 BPL l_4509
 LDA #&40
 STA adval_x
 LDA #&00

.l_4509

 STA &0303,X
 LDA adval_x

.l_450f

 STA adval_x
 LDA #&80
 LDX #&00
 ASL &64
 BEQ l_4523
 BCS l_451d
 INX

.l_451d

 STA &0305,X
 LDA adval_y

.l_4523

 STA adval_y

.l_4526

 LDX adval_x
 LDA #&07
 LDY &0303
 BEQ l_4533
 JSR l_2a16

.l_4533

 LDY &0304
 BEQ l_453b
 JSR l_2a26

.l_453b

 STX adval_x
 ASL A
 LDX adval_y
 LDY &0305
 BEQ l_454a
 JSR l_2a26

.l_454a

 LDY &0306
 BEQ l_4552
 JSR l_2a16

.l_4552

 STX adval_y

.l_4555

 JSR l_433f
 STX last_key
 CPX #&69
 BNE l_459c

.l_455f

 JSR l_55f7
 JSR l_433f
 CPX #&51
 BNE l_456e
 LDA #&00
 STA s_flag

.l_456e

 LDY #&40

.l_4570

 JSR l_445c
 INY
 \	CPY #&47
 CPY #&48
 BNE l_4570
 CPX #&10
 BNE l_457f
 STX s_flag

.l_457f

 CPX #&70
 BNE l_4586
 JMP l_1220

.l_4586

 CPX #&59
 BNE l_455f

.l_459c

 LDA &87
 BNE l_45b4
 LDY #&10
 \	LDA #&FF

.l_45a4

 JSR l_4429
 \	LDX l_4419-1,Y
 \	CPX last_key
 \	BNE l_45af
 \	STA last_key,Y
 \l_45af
 DEY
 CPY #&07
 BNE l_45a4

.l_45b4

 RTS

.l_45b5

 STX &034A
 PHA
 LDA &03A4
 JSR l_45dd
 PLA
 EQUB &2C

.cargo_mtok

 ADC #&D0

.l_45c6

 \	LDX #&00
 \	STX vdu_stat
 JSR vdu_00
 LDY #&09
 STY cursor_x
 LDY #&16
 STY cursor_y
 CPX &034A
 BNE l_45b5
 STY &034A
 STA &03A4

.l_45dd

 JSR l_339a
 LSR &034B
 BCC l_45b4
 LDA #&FD
 JMP l_339a

.l_45ea

 JSR l_3f86
 BMI l_45b4
 \	CPX #&16
 CPX #&18
 BCS l_45b4
 \	LDA cmdr_cargo,X
 LDA cmdr_hold,X
 BEQ l_45b4
 LDA &034A
 BNE l_45b4
 LDY #&03
 STY &034B
 \	STA cmdr_cargo,X
 STA cmdr_hold,X
 DEX
 BMI l_45c1
 CPX #&11
 BEQ l_45c1
 TXA
 BCC cargo_mtok	\BCS l_460e

.l_460e

 CMP #&12
 BNE equip_mtok	\BEQ l_45c4
 \l_45c4
 LDA #&6F-&6B-1
 \	EQUB &2C

.l_45c1

 \	LDA #&6C
 ADC #&6B-&5D
 \	EQUB &2C

.equip_mtok

 ADC #&5D
 INC new_hold	\**
 BNE l_45c6

.l_4619

 EQUB &13, &82, &06, &01, &14, &81, &0A, &03, &41, &83, &02, &07
 EQUB &28, &85, &E2, &1F, &53, &85, &FB, &0F, &C4, &08, &36, &03
 EQUB &EB, &1D, &08, &78, &9A, &0E, &38, &03, &75, &06, &28, &07
 EQUB &4E, &01, &11, &1F, &7C, &0D, &1D, &07, &B0, &89, &DC, &3F
 EQUB &20, &81, &35, &03, &61, &A1, &42, &07, &AB, &A2, &37, &1F
 EQUB &2D, &C1, &FA, &0F, &35, &0F, &C0, &07

.l_465d

 TYA
 LDY #&02
 JSR l_472c
 STA &5A
 JMP l_46a5

.l_4668

 TAX
 LDA &35
 AND #&60
 BEQ l_465d
 LDA #&02
 JSR l_472c
 STA &58
 JMP l_46a5

.l_4679

 LDA &50
 STA &34
 LDA &52
 STA &35
 LDA &54
 STA &36
 JSR l_42f5
 LDA &34
 STA &50
 LDA &35
 STA &52
 LDA &36
 STA &54
 LDY #&04
 LDA &34
 AND #&60
 BEQ l_4668
 LDX #&02
 LDA #&00
 JSR l_472c
 STA &56

.l_46a5

 LDA &56
 STA &34
 LDA &58
 STA &35
 LDA &5A
 STA &36
 JSR l_42f5
 LDA &34
 STA &56
 LDA &35
 STA &58
 LDA &36
 STA &5A
 LDA &52
 STA &81
 LDA &5A
 JSR l_28d4
 LDX &54
 LDA &58
 JSR l_293b
 EOR #&80
 STA &5C
 LDA &56
 JSR l_28d4
 LDX &50
 LDA &5A
 JSR l_293b
 EOR #&80
 STA &5E
 LDA &58
 JSR l_28d4
 LDX &52
 LDA &56
 JSR l_293b
 EOR #&80
 STA &60
 LDA #&00
 LDX #&0E

.l_46f8

 STA &4F,X
 DEX
 DEX
 BPL l_46f8
 RTS

.l_46ff

 TAY
 AND #&7F
 CMP &81
 BCS l_4726
 LDX #&FE
 STX &D1

.l_470a

 ASL A
 CMP &81
 BCC l_4711
 SBC &81

.l_4711

 ROL &D1
 BCS l_470a
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

.l_4726

 TYA
 AND #&80
 ORA #&60
 RTS

.l_472c

 STA font+&01
 LDA &50,X
 STA &81
 LDA &56,X
 JSR l_28d4
 LDX &50,Y
 STX &81
 LDA &56,Y
 JSR l_28fc
 STX &1B
 LDY font+&01
 LDX &50,Y
 STX &81
 EOR #&80
 STA font
 EOR &81
 AND #&80
 STA &D1
 LDA #&00
 LDX #&10
 ASL &1B
 ROL font
 ASL &81
 LSR &81

.l_475f

 ROL A
 CMP &81
 BCC l_4766
 SBC &81

.l_4766

 ROL &1B
 ROL font
 DEX
 BNE l_475f
 LDA &1B
 ORA &D1
 RTS

.l_4772

 JSR l_48de
 JSR l_3856
 ORA &D3
 BNE l_479d
 LDA &E0
 CMP #&BE
 BCS l_479d
 LDY #&02
 JSR l_47a4
 LDY #&06
 LDA &E0
 ADC #&01
 JSR l_47a4
 LDA #&08
 ORA &65
 STA &65
 LDA #&08
 JMP l_4f74

.l_479b

 PLA
 PLA

.l_479d

 LDA #&F7
 AND &65
 STA &65
 RTS

.l_47a4

 STA (&67),Y
 INY
 INY
 STA (&67),Y
 LDA &D2
 DEY
 STA (&67),Y
 ADC #&03
 BCS l_479b
 DEY
 DEY
 STA (&67),Y
 RTS

.l_47b8

 LDY &82
 LDA &81
 STA &83
 LDX #&00
 STX &81
 LDA #&08
 STA &D1

.l_47c6

 CPX &81
 BCC l_47d8
 BNE l_47d0
 CPY #&40
 BCC l_47d8

.l_47d0

 TYA
 SBC #&40
 TAY
 TXA
 SBC &81
 TAX

.l_47d8

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
 BNE l_47c6
 RTS

.l_47ef

 CMP &81
 BCS l_480d

.l_47f3

 LDX #&FE
 STX &82

.l_47f7

 ASL A
 BCS l_4805
 CMP &81
 BCC l_4800
 SBC &81

.l_4800

 ROL &82
 BCS l_47f7
 RTS

.l_4805

 SBC &81
 SEC
 ROL &82
 BCS l_47f7
 RTS

.l_480d

 LDA #&FF
 STA &82
 RTS

.l_4812

 EOR &83
 BMI l_481c
 LDA &81
 CLC
 ADC &82
 RTS

.l_481c

 LDA &82
 SEC
 SBC &81
 BCC l_4825
 CLC
 RTS

.l_4825

 PHA
 LDA &83
 EOR #&80
 STA &83
 PLA
 EOR #&FF
 ADC #&01
 RTS

.l_4832

 LDX #&00
 LDY #&00

.l_4836

 LDA &34
 STA &81
 LDA &09,X
 JSR l_2847
 STA &D1
 LDA &35
 EOR &0A,X
 STA &83
 LDA &36
 STA &81
 LDA &0B,X
 JSR l_2847
 STA &81
 LDA &D1
 STA &82
 LDA &37
 EOR &0C,X
 JSR l_4812
 STA &D1
 LDA &38
 STA &81
 LDA &0D,X
 JSR l_2847
 STA &81
 LDA &D1
 STA &82
 LDA &39
 EOR &0E,X
 JSR l_4812
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
 BCC l_4836
 RTS

.l_4889

 JMP l_3899

.l_488c

 LDA &8C
 BMI l_4889
 LDA #&1F
 STA &96
 LDA &6A
 BMI l_48de
 LDA #&20
 BIT &65
 BNE l_48cb
 BPL l_48cb
 ORA &65
 AND #&3F
 STA &65
 LDA #&00
 LDY #&1C
 STA (&20),Y
 LDY #&1E
 STA (&20),Y
 JSR l_48de
 LDY #&01
 LDA #&12
 STA (&67),Y
 LDY #&07
 LDA (&1E),Y
 LDY #&02
 STA (&67),Y

.l_48c1

 INY
 JSR l_3f86
 STA (&67),Y
 CPY #&06
 BNE l_48c1

.l_48cb

 LDA &4E
 BPL l_48ec

.l_48cf

 LDA &65
 AND #&20
 BEQ l_48de
 LDA &65
 AND #&F7
 STA &65
 JMP l_3470

.l_48de

 LDA #&08
 BIT &65
 BEQ l_48eb
 EOR &65
 STA &65
 JMP l_4f78

.l_48eb

 RTS

.l_48ec

 LDA &4D
 CMP #&C0
 BCS l_48cf
 LDA &46
 CMP &4C
 LDA &47
 SBC &4D
 BCS l_48cf
 LDA &49
 CMP &4C
 LDA &4A
 SBC &4D
 BCS l_48cf
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
 BNE l_492f
 LDA &D1
 ROR A
 LSR A
 LSR A
 LSR A
 STA &96
 BPL l_4940

.l_492f

 LDY #&0D
 LDA (&1E),Y
 CMP &4D
 BCS l_4940
 LDA #&20
 AND &65
 BNE l_4940
 JMP l_4772

.l_4940

 LDX #&05

.l_4942

 LDA &5B,X
 STA &09,X
 LDA &55,X
 STA &0F,X
 LDA &4F,X
 STA &15,X
 DEX
 BPL l_4942
 LDA #&C5
 STA &81
 LDY #&10

.l_4957

 LDA &09,Y
 ASL A
 LDA &0A,Y
 ROL A
 JSR l_47ef
 LDX &82
 STX &09,Y
 DEY
 DEY
 BPL l_4957
 LDX #&08

.l_496c

 LDA &46,X
 STA vdu_stat,X
 DEX
 BPL l_496c
 LDA #&FF
 STA &E1
 LDY #&0C
 LDA &65
 AND #&20
 BEQ l_4991
 LDA (&1E),Y
 LSR A
 LSR A
 TAX
 LDA #&FF

.l_4986

 STA &D2,X
 DEX
 BPL l_4986
 INX
 STX &96

.l_498e

 JMP l_4b04

.l_4991

 LDA (&1E),Y
 BEQ l_498e
 STA &97
 LDY #&12
 LDA (&1E),Y
 TAX
 LDA &79
 TAY
 BEQ l_49b0

.l_49a1

 INX
 LSR &76
 ROR &75
 LSR &73
 ROR vdu_stat
 LSR A
 ROR &78
 TAY
 BNE l_49a1

.l_49b0

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
 JSR l_4832
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

.l_49f8

 LDA (&22),Y
 STA &3B
 AND #&1F
 CMP &96
 BCS l_4a11
 TYA
 LSR A
 LSR A
 TAX
 LDA #&FF
 STA &D2,X
 TYA
 ADC #&04
 TAY
 JMP l_4afd

.l_4a11

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
 BCC l_4a51
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
 JMP l_4aaf

.l_4a49

 LSR vdu_stat
 LSR &78
 LSR &75
 LDX #&01

.l_4a51

 LDA &3A
 STA &34
 LDA &3C
 STA &36
 LDA &3E
 DEX
 BMI l_4a66

.l_4a5e

 LSR &34
 LSR &36
 LSR A
 DEX
 BPL l_4a5e

.l_4a66

 STA &82
 LDA &3F
 STA &83
 LDA &78
 STA &81
 LDA &7A
 JSR l_4812
 BCS l_4a49
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
 JSR l_4812
 BCS l_4a49
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
 JSR l_4812
 BCS l_4a49
 STA &36
 LDA &83
 STA &37

.l_4aaf

 LDA &3A
 STA &81
 LDA &34
 JSR l_2847
 STA &D1
 LDA &3B
 EOR &35
 STA &83
 LDA &3C
 STA &81
 LDA &36
 JSR l_2847
 STA &81
 LDA &D1
 STA &82
 LDA &3D
 EOR &37
 JSR l_4812
 STA &D1
 LDA &3E
 STA &81
 LDA &38
 JSR l_2847
 STA &81
 LDA &D1
 STA &82
 LDA &39
 EOR &3F
 JSR l_4812
 PHA
 TYA
 LSR A
 LSR A
 TAX
 PLA
 BIT &83
 BMI l_4afa
 LDA #&00

.l_4afa

 STA &D2,X
 INY

.l_4afd

 CPY &97
 BCS l_4b04
 JMP l_49f8

.l_4b04

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

.l_4b4b

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
 BCC l_4b94
 INY
 LDA (&22),Y
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_4b97
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_4b97
 INY
 LDA (&22),Y
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_4b97
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_4b97

.l_4b94

 JMP l_4d0c

.l_4b97

 LDA &D1
 STA &35
 ASL A
 STA &37
 ASL A
 STA &39
 JSR l_4832
 LDA &48
 STA &36
 EOR &3B
 BMI l_4bbc
 CLC
 LDA &3A
 ADC &46
 STA &34
 LDA &47
 ADC #&00
 STA &35
 JMP l_4bdf

.l_4bbc

 LDA &46
 SEC
 SBC &3A
 STA &34
 LDA &47
 SBC #&00
 STA &35
 BCS l_4bdf
 EOR #&FF
 STA &35
 LDA #&01
 SBC &34
 STA &34
 BCC l_4bd9
 INC &35

.l_4bd9

 LDA &36
 EOR #&80
 STA &36

.l_4bdf

 LDA &4B
 STA &39
 EOR &3D
 BMI l_4bf7
 CLC
 LDA &3C
 ADC &49
 STA &37
 LDA &4A
 ADC #&00
 STA &38
 JMP l_4c1c

.l_4bf7

 LDA &49
 SEC
 SBC &3C
 STA &37
 LDA &4A
 SBC #&00
 STA &38
 BCS l_4c1c
 EOR #&FF
 STA &38
 LDA &37
 EOR #&FF
 ADC #&01
 STA &37
 LDA &39
 EOR #&80
 STA &39
 BCC l_4c1c
 INC &38

.l_4c1c

 LDA &3F
 BMI l_4c6a
 LDA &3E
 CLC
 ADC &4C
 STA &D1
 LDA &4D
 ADC #&00
 STA &80
 JMP l_4c89

.l_4c30

 LDX &81
 BEQ l_4c50
 LDX #&00

.l_4c36

 LSR A
 INX
 CMP &81
 BCS l_4c36
 STX &83
 JSR l_47ef
 LDX &83
 LDA &82

.l_4c45

 ASL A
 ROL &80
 BMI l_4c50
 DEX
 BNE l_4c45
 STA &82
 RTS

.l_4c50

 LDA #&32
 STA &82
 STA &80
 RTS

.l_4c57

 LDA #&80
 SEC
 SBC &82
 STA &0100,X
 INX
 LDA #&00
 SBC &80
 STA &0100,X
 JMP l_4cc9

.l_4c6a

 LDA &4C
 SEC
 SBC &3E
 STA &D1
 LDA &4D
 SBC #&00
 STA &80
 BCC l_4c81
 BNE l_4c89
 LDA &D1
 CMP #&04
 BCS l_4c89

.l_4c81

 LDA #&00
 STA &80
 LDA #&04
 STA &D1

.l_4c89

 LDA &80
 ORA &35
 ORA &38
 BEQ l_4ca0
 LSR &35
 ROR &34
 LSR &38
 ROR &37
 LSR &80
 ROR &D1
 JMP l_4c89

.l_4ca0

 LDA &D1
 STA &81
 LDA &34
 CMP &81
 BCC l_4cb0
 JSR l_4c30
 JMP l_4cb3

.l_4cb0

 JSR l_47ef

.l_4cb3

 LDX &93
 LDA &36
 BMI l_4c57
 LDA &82
 CLC
 ADC #&80
 STA &0100,X
 INX
 LDA &80
 ADC #&00
 STA &0100,X

.l_4cc9

 TXA
 PHA
 LDA #&00
 STA &80
 LDA &D1
 STA &81
 LDA &37
 CMP &81
 BCC l_4cf2
 JSR l_4c30
 JMP l_4cf5

.l_4cdf

 LDA #&60
 CLC
 ADC &82
 STA &0100,X
 INX
 LDA #&00
 ADC &80
 STA &0100,X
 JMP l_4d0c

.l_4cf2

 JSR l_47ef

.l_4cf5

 PLA
 TAX
 INX
 LDA &39
 BMI l_4cdf
 LDA #&60
 SEC
 SBC &82
 STA &0100,X
 INX
 LDA #&00
 SBC &80
 STA &0100,X

.l_4d0c

 CLC
 LDA &93
 ADC #&04
 STA &93
 LDA &86
 ADC #&06
 TAY
 BCS l_4d21
 CMP &97
 BCS l_4d21
 JMP l_4b4b

.l_4d21

 LDA &65
 AND #&20
 BEQ l_4d30
 LDA &65
 ORA #&08
 STA &65
 JMP l_3470

.l_4d30

 LDA #&08
 BIT &65
 BEQ l_4d3b
 JSR l_4f78
 LDA #&08

.l_4d3b

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
 BVC l_4da5
 LDA &65
 AND #&BF
 STA &65
 LDY #&06
 LDA (&1E),Y
 TAY
 LDX &0100,Y
 STX &34
 INX
 BEQ l_4da5
 LDX &0101,Y
 STX &35
 INX
 BEQ l_4da5
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
 BPL l_4d88
 DEC &38

.l_4d88

 JSR l_4e19
 BCS l_4da5
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

.l_4da5

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

.l_4dbe

 LDA (&22),Y
 CMP &96
 BCC l_4ddc
 INY
 LDA (&22),Y
 INY
 STA &1B
 AND #&0F
 TAX
 LDA &D2,X
 BNE l_4ddf
 LDA &1B
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA &D2,X
 BNE l_4ddf

.l_4ddc

 JMP l_4f5b

.l_4ddf

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
 JSR l_4e1f
 BCS l_4ddc
 JMP l_4f3f

.l_4e19

 LDA #&00
 STA &90
 LDA &39

.l_4e1f

 LDX #&BF
 ORA &3B
 BNE l_4e2b
 CPX &3A
 BCC l_4e2b
 LDX #&00

.l_4e2b

 STX &89
 LDA &35
 ORA &37
 BNE l_4e4f
 LDA #&BF
 CMP &36
 BCC l_4e4f
 LDA &89
 BNE l_4e4d

.l_4e3d

 LDA &36
 STA &35
 LDA &38
 STA &36
 LDA &3A
 STA &37
 CLC
 RTS

.l_4e4b

 SEC
 RTS

.l_4e4d

 LSR &89

.l_4e4f

 LDA &89
 BPL l_4e82
 LDA &35
 AND &39
 BMI l_4e4b
 LDA &37
 AND &3B
 BMI l_4e4b
 LDX &35
 DEX
 TXA
 LDX &39
 DEX
 STX &3C
 ORA &3C
 BPL l_4e4b
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
 BPL l_4e4b

.l_4e82

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
 BPL l_4eb3
 LDA #&00
 SEC
 SBC &3E
 STA &3E
 LDA #&00
 SBC &3F
 STA &3F

.l_4eb3

 LDA &3D
 BPL l_4ec2
 SEC
 LDA #&00
 SBC &3C
 STA &3C
 LDA #&00
 SBC &3D

.l_4ec2

 TAX
 BNE l_4ec9
 LDX &3F
 BEQ l_4ed3

.l_4ec9

 LSR A
 ROR &3C
 LSR &3F
 ROR &3E
 JMP l_4ec2

.l_4ed3

 STX &D1
 LDA &3C
 CMP &3E
 BCC l_4ee5
 STA &81
 LDA &3E
 JSR l_47ef
 JMP l_4ef0

.l_4ee5

 LDA &3E
 STA &81
 LDA &3C
 JSR l_47ef
 DEC &D1

.l_4ef0

 LDA &82
 STA &3C
 LDA &83
 STA &3D
 LDA &89
 BEQ l_4efe
 BPL l_4f11

.l_4efe

 JSR l_4f9f
 LDA &89
 BPL l_4f36
 LDA &35
 ORA &37
 BNE l_4f3b
 LDA &36
 CMP #&C0
 BCS l_4f3b

.l_4f11

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
 JSR l_4f9f
 DEC &90

.l_4f36

 PLA
 TAY
 JMP l_4e3d

.l_4f3b

 PLA
 TAY
 SEC
 RTS

.l_4f3f

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
 BCS l_4f72

.l_4f5b

 INC &86
 LDY &86
 CPY &97
 BCS l_4f72
 LDY #&00
 LDA &22
 ADC #&04
 STA &22
 BCC l_4f6f
 INC &23

.l_4f6f

 JMP l_4dbe

.l_4f72

 LDA &80

.l_4f74

 LDY #&00
 STA (&67),Y

.l_4f78

 LDY #&00
 LDA (&67),Y
 STA &97
 CMP #&04
 BCC l_4f9e
 INY

.l_4f83

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
 JSR l_16c4
 INY
 CPY &97
 BCC l_4f83

.l_4f9e

 RTS

.l_4f9f

 LDA &35
 BPL l_4fba
 STA &83
 JSR l_5019
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

.l_4fba

 BEQ l_4fd5
 STA &83
 DEC &83
 JSR l_5019
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

.l_4fd5

 LDA &37
 BPL l_4ff3
 STA &83
 LDA &36
 STA &82
 JSR l_5048
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

.l_4ff3

 LDA &36
 SEC
 SBC #&C0
 STA &82
 LDA &37
 SBC #&00
 STA &83
 BCC l_5018
 JSR l_5048
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

.l_5018

 RTS

.l_5019

 LDA &34
 STA &82
 JSR l_5084
 PHA
 LDX &D1
 BNE l_5050

.l_5025

 LDA #&00
 TAX
 TAY
 LSR &83
 ROR &82
 ASL &81
 BCC l_503a

.l_5031

 TXA
 CLC
 ADC &82
 TAX
 TYA
 ADC &83
 TAY

.l_503a

 LSR &83
 ROR &82
 ASL &81
 BCS l_5031
 BNE l_503a
 PLA
 BPL l_5077
 RTS

.l_5048

 JSR l_5084
 PHA
 LDX &D1
 BNE l_5025

.l_5050

 LDA #&FF
 TAY
 ASL A
 TAX

.l_5055

 ASL &82
 ROL &83
 LDA &83
 BCS l_5061
 CMP &81
 BCC l_506c

.l_5061

 SBC &81
 STA &83
 LDA &82
 SBC #&00
 STA &82
 SEC

.l_506c

 TXA
 ROL A
 TAX
 TYA
 ROL A
 TAY
 BCS l_5055
 PLA
 BMI l_5083

.l_5077

 TXA
 EOR #&FF
 ADC #&01
 TAX
 TYA
 EOR #&FF
 ADC #&00
 TAY

.l_5083

 RTS

.l_5084

 LDX &3C
 STX &81
 LDA &83
 BPL l_509d
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

.l_509d

 EOR &3D
 RTS

.l_50a0

 LDA &65
 AND #&A0
 BNE l_50cb
 LDA &8A
 EOR &84
 AND #&0F
 BNE l_50b1
 JSR l_4679

.l_50b1

 LDX &8C
 BPL l_50b8
 JMP l_533d

.l_50b8

 LDA &66
 BPL l_50cb
 CPX #&01
 BEQ l_50c8
 LDA &8A
 EOR &84
 AND #&07
 BNE l_50cb

.l_50c8

 JSR l_217a

.l_50cb

 JSR l_5558
 LDA &61
 ASL A
 ASL A
 STA &81
 LDA &50
 AND #&7F
 JSR l_2847
 STA &82
 LDA &50
 LDX #&00
 JSR l_524a
 LDA &52
 AND #&7F
 JSR l_2847
 STA &82
 LDA &52
 LDX #&03
 JSR l_524a
 LDA &54
 AND #&7F
 JSR l_2847
 STA &82
 LDA &54
 LDX #&06
 JSR l_524a
 LDA &61
 CLC
 ADC &62
 BPL l_510d
 LDA #&00

.l_510d

 LDY #&0F
 CMP (&1E),Y
 BCC l_5115
 LDA (&1E),Y

.l_5115

 STA &61
 LDA #&00
 STA &62
 LDX &31
 LDA &46
 EOR #&FF
 STA &1B
 LDA &47
 JSR l_2877
 STA font+&01
 LDA &33
 EOR &48
 LDX #&03
 JSR l_5308
 STA &9E
 LDA font
 STA &9C
 EOR #&FF
 STA &1B
 LDA font+&01
 STA &9D
 LDX &2B
 JSR l_2877
 STA font+&01
 LDA &9E
 EOR &7B
 LDX #&06
 JSR l_5308
 STA &4E
 LDA font
 STA &4C
 EOR #&FF
 STA &1B
 LDA font+&01
 STA &4D
 JSR l_2879
 STA font+&01
 LDA &9E
 STA &4B
 EOR &7B
 EOR &4E
 BPL l_517d
 LDA font
 ADC &9C
 STA &49
 LDA font+&01
 ADC &9D
 STA &4A
 JMP l_519d

.l_517d

 LDA &9C
 SBC font
 STA &49
 LDA &9D
 SBC font+&01
 STA &4A
 BCS l_519d
 LDA #&01
 SBC &49
 STA &49
 LDA #&00
 SBC &4A
 STA &4A
 LDA &4B
 EOR #&80
 STA &4B

.l_519d

 LDX &31
 LDA &49
 EOR #&FF
 STA &1B
 LDA &4A
 JSR l_2877
 STA font+&01
 LDA &32
 EOR &4B
 LDX #&00
 JSR l_5308
 STA &48
 LDA font+&01
 STA &47
 LDA font
 STA &46

.l_51bf

 LDA &7D
 STA &82
 LDA #&80
 LDX #&06
 JSR l_524c
 LDA &8C
 AND #&81
 CMP #&81
 BNE l_51d3
 RTS

.l_51d3

 LDY #&09
 JSR l_52a1
 LDY #&0F
 JSR l_52a1
 LDY #&15
 JSR l_52a1
 LDA &64
 AND #&80
 STA &9A
 LDA &64
 AND #&7F
 BEQ l_520b
 CMP #&7F
 SBC #&00
 ORA &9A
 STA &64
 LDX #&0F
 LDY #&09
 JSR l_1da8
 LDX #&11
 LDY #&0B
 JSR l_1da8
 LDX #&13
 LDY #&0D
 JSR l_1da8

.l_520b

 LDA &63
 AND #&80
 STA &9A
 LDA &63
 AND #&7F
 BEQ l_5234
 CMP #&7F
 SBC #&00
 ORA &9A
 STA &63
 LDX #&0F
 LDY #&15
 JSR l_1da8
 LDX #&11
 LDY #&17
 JSR l_1da8
 LDX #&13
 LDY #&19
 JSR l_1da8

.l_5234

 LDA &65
 AND #&A0
 BNE l_5243
 LDA &65
 ORA #&10
 STA &65
 JMP l_5558

.l_5243

 LDA &65
 AND #&EF
 STA &65
 RTS

.l_524a

 AND #&80

.l_524c

 ASL A
 STA &83
 LDA #&00
 ROR A
 STA &D1
 LSR &83
 EOR &48,X
 BMI l_526f
 LDA &82
 ADC &46,X
 STA &46,X
 LDA &83
 ADC &47,X
 STA &47,X
 LDA &48,X
 ADC #&00
 ORA &D1
 STA &48,X
 RTS

.l_526f

 LDA &46,X
 SEC
 SBC &82
 STA &46,X
 LDA &47,X
 SBC &83
 STA &47,X
 LDA &48,X
 AND #&7F
 SBC #&00
 ORA #&80
 EOR &D1
 STA &48,X
 BCS l_52a0
 LDA #&01
 SBC &46,X
 STA &46,X
 LDA #&00
 SBC &47,X
 STA &47,X
 LDA #&00
 SBC &48,X
 AND #&7F
 ORA &D1
 STA &48,X

.l_52a0

 RTS

.l_52a1

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
 JSR l_28fc
 STA &49,Y
 STX &48,Y
 STX &1B
 LDX &46,Y
 STX &82
 LDX &47,Y
 STX &83
 LDA &49,Y
 JSR l_28fc
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
 JSR l_28fc
 STA &49,Y
 STX &48,Y
 STX &1B
 LDX &4A,Y
 STX &82
 LDX &4B,Y
 STX &83
 LDA &49,Y
 JSR l_28fc
 STA &4B,Y
 STX &4A,Y
 RTS

.l_5308

 TAY
 EOR &48,X
 BMI l_531c
 LDA font
 CLC
 ADC &46,X
 STA font
 LDA font+&01
 ADC &47,X
 STA font+&01
 TYA
 RTS

.l_531c

 LDA &46,X
 SEC
 SBC font
 STA font
 LDA &47,X
 SBC font+&01
 STA font+&01
 BCC l_532f
 TYA
 EOR #&80
 RTS

.l_532f

 LDA #&01
 SBC font
 STA font
 LDA #&00
 SBC font+&01
 STA font+&01
 TYA
 RTS

.l_533d

 LDA &8D
 EOR #&80
 STA &81
 LDA &46
 STA &1B
 LDA &47
 STA font
 LDA &48
 JSR l_2782
 LDX #&03
 JSR l_1d4c
 LDA &41
 STA &9C
 STA &1B
 LDA &42
 STA &9D
 STA font
 LDA &2A
 STA &81
 LDA &43
 STA &9E
 JSR l_2782
 LDX #&06
 JSR l_1d4c
 LDA &41
 STA &1B
 STA &4C
 LDA &42
 STA font
 STA &4D
 LDA &43
 STA &4E
 EOR #&80
 JSR l_2782
 LDA &43
 AND #&80
 STA &D1
 EOR &9E
 BMI l_53a8
 LDA &40
 CLC
 ADC &9B
 LDA &41
 ADC &9C
 STA &49
 LDA &42
 ADC &9D
 STA &4A
 LDA &43
 ADC &9E
 JMP l_53db

.l_53a8

 LDA &40
 SEC
 SBC &9B
 LDA &41
 SBC &9C
 STA &49
 LDA &42
 SBC &9D
 STA &4A
 LDA &9E
 AND #&7F
 STA &1B
 LDA &43
 AND #&7F
 SBC &1B
 STA &1B
 BCS l_53db
 LDA #&01
 SBC &49
 STA &49
 LDA #&00
 SBC &4A
 STA &4A
 LDA #&00
 SBC &1B
 ORA #&80

.l_53db

 EOR &D1
 STA &4B
 LDA &8D
 STA &81
 LDA &49
 STA &1B
 LDA &4A
 STA font
 LDA &4B
 JSR l_2782
 LDX #&00
 JSR l_1d4c
 LDA &41
 STA &46
 LDA &42
 STA &47
 LDA &43
 STA &48
 JMP l_51bf

.l_5404

 DEX
 BNE l_5438
 LDA &48
 EOR #&80
 STA &48
 LDA &4E
 EOR #&80
 STA &4E
 LDA &50
 EOR #&80
 STA &50
 LDA &54
 EOR #&80
 STA &54
 LDA &56
 EOR #&80
 STA &56
 LDA &5A
 EOR #&80
 STA &5A
 LDA &5C
 EOR #&80
 STA &5C
 LDA &60
 EOR #&80
 STA &60
 RTS

.l_5438

 LDA #&00
 CPX #&02
 ROR A
 STA &9A
 EOR #&80
 STA &99
 LDA &46
 LDX &4C
 STA &4C
 STX &46
 LDA &47
 LDX &4D
 STA &4D
 STX &47
 LDA &48
 EOR &99
 TAX
 LDA &4E
 EOR &9A
 STA &48
 STX &4E
 LDY #&09
 JSR l_546c
 LDY #&0F
 JSR l_546c
 LDY #&15

.l_546c

 LDA &46,Y
 LDX &4A,Y
 STA &4A,Y
 STX &46,Y
 LDA &47,Y
 EOR &99
 TAX
 LDA &4B,Y
 EOR &9A
 STA &47,Y
 STX &4B,Y

.l_5486

 RTS

.l_5487

 STX view_dirn
 JSR l_54c8
 JSR l_54aa
 JMP l_35b1

.l_5493

 LDA #&00
 LDY &87
 BNE l_5487
 CPX view_dirn
 BEQ l_5486
 STX view_dirn
 JSR l_54c8
 JSR l_1a05
 JSR l_35d8

.l_54aa

 LDY view_dirn
 LDA cmdr_laser,Y
 BEQ l_5486
 LDA #&80
 STA &73
 LDA #&48
 STA &74
 LDA #&14
 STA &75
 JSR l_2d36
 LDA #&0A
 STA &75
 JMP l_2d36
