 \ a.qelite - tube elite startup file

CODE% = &1200
ORG CODE%
LOAD% = &1200
\EXEC = tube_elite

key_tube = &90

brkv = &0202
wrchv = &020E
oscli = &FFF7

tube_r1s = &FEE0
tube_r1d = &FEE1
tube_r2s = &FEE2
tube_r2d = &FEE3
tube_r3s = &FEE4
tube_r3d = &FEE5
tube_r4s = &FEE6
tube_r4d = &FEE7

ptr = &92

font = &94
save_a = &96
save_x = &97
save_y = &98

x_lo = &94
y_lo = &95
x_hi = &96
y_hi = &97
line_1 = &98
line_2 = &99
line_3 = &9A
line_4 = &9B
line_5 = &9C

drawpix_1 = &94
drawpix_2 = &95
drawpix_3 = &96
drawpix_4 = &97
drawpix_5 = &98

bar_1 = &94
bar_2 = &95
bar_3 = &96

angle_1 = &94

missle_1 = &94

picture_1 = &94
picture_2 = &95

print_bits = &94

cursor_x = &9E
cursor_y = &9F


.tube_elite

 LDX #&FF
 TXS
 LDA #LO(tube_wrch)
 STA wrchv
 LDA #HI(tube_wrch)
 STA wrchv+&01
 LDA #LO(tube_brk)
 STA brkv
 LDA #HI(tube_brk)
 STA brkv+&01
 LDX #LO(tube_run)
 LDY #HI(tube_run)
 JMP oscli

tube_brk = &16	\ tube BRK vector


.tube_run

 EQUS "R.2.T", &0D


.tube_get

 BIT tube_r1s
 NOP
 BPL tube_get
 LDA tube_r1d
 RTS


.tube_put

 BIT tube_r2s
 NOP
 BVC tube_put
 STA tube_r2d
 RTS


.tube_func

 CMP #&9D		\ OUT
 BCS return		\ OUT
 ASL A
 TAY
 LDA tube_table,Y
 STA tube_jump+&01
 LDA tube_table+&01,Y
 STA tube_jump+&02

.tube_jump

 JMP &FFFF

.return

 RTS


.tube_table

 EQUW draw_line, draw_hline, draw_pixel, clr_scrn
 EQUW clr_line, sync_in, draw_bar, draw_angle
 EQUW put_missle, scan_fire, write_fe4e, scan_xin
 EQUW scan_10in, get_key, write_xyc, write_pod
 EQUW draw_blob, draw_tail, draw_S, draw_E
 EQUW draw_mode, write_crtc, scan_y, write_0346
 EQUW read_0346, return, picture_h, picture_v


.write_xyc

 JSR tube_get
 STA cursor_x
 JSR tube_get
 STA cursor_y
 JSR tube_get
 CMP #&20
 BNE tube_wrch
 LDA #&09

.tube_wrch

 STA save_a
 STX save_x
 STY save_y
 TAY
 BMI tube_func
 BEQ wrch_quit
 CMP #&7F
 BEQ wrch_del
 CMP #&20
 BEQ wrch_spc 
 BCS wrch_char
 CMP #&0A
 BEQ wrch_nl
 CMP #&0D
 BEQ wrch_cr
 CMP #&09
 BNE wrch_quit

.wrch_tab

 INC cursor_x

.wrch_quit

 LDY save_y
 LDX save_x
 LDA save_a
 RTS

.wrch_char

 JSR wrch_font
 INC cursor_x
 LDY #&07

.wrch_or

 LDA (font),Y
 EOR (ptr),Y	\ORA (ptr),Y
 STA (ptr),Y
 DEY
 BPL wrch_or
 BMI wrch_quit

.wrch_del

 DEC cursor_x
 LDA #&20
 JSR wrch_font
 LDY #&07

.wrch_sta

 LDA (font),Y
 STA (ptr),Y
 DEY
 BPL wrch_sta
 BMI wrch_quit

.wrch_nl

 INC cursor_y
 JMP wrch_quit

.wrch_cr

 LDA #&01
 STA cursor_x
 JMP wrch_quit

.wrch_spc

 LDA cursor_x
 CMP #&20
 BEQ wrch_quit
 CMP #&11
 BEQ wrch_quit
 BNE wrch_tab

.wrch_font

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

 STA font
 STX font+1
 LDA cursor_x
 ASL A
 ASL A
 ASL A
 STA ptr
 LDA cursor_y
 ORA #&60
 STA ptr+&01
 RTS


.pixel_1

 EQUB &80, &40, &20, &10, &08, &04, &02, &01

.pixel_2

 EQUB &C0, &60, &30, &18, &0C, &06, &03, &03

.pixel_3

 EQUB &88, &44, &22, &11, &88

.draw_line

 JSR tube_get
 STA x_lo
 JSR tube_get
 STA y_lo
 JSR tube_get
 STA x_hi
 JSR tube_get
 STA y_hi

.draw_line2

 LDA #&80
 STA line_4
 ASL A
 STA line_5
 LDA x_hi
 SBC x_lo
 BCS l_1783
 EOR #&FF
 ADC #&01
 SEC

.l_1783

 STA line_1
 LDA y_hi
 SBC y_lo
 BCS l_178f
 EOR #&FF
 ADC #&01

.l_178f

 STA line_2
 CMP line_1
 BCC l_1798
 JMP l_1842

.l_1798

 LDX x_lo
 CPX x_hi
 BCC l_17af
 DEC line_5
 LDA x_hi
 STA x_lo
 STX x_hi
 TAX
 LDA y_hi
 LDY y_lo
 STA y_lo
 STY y_hi

.l_17af

 LDA y_lo
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA y_lo
 AND #&07
 TAY
 TXA
 AND #&F8
 STA ptr
 TXA
 AND #&07
 TAX
 LDA pixel_1,X
 STA line_3
 LDA line_2
 LDX #&FE
 STX line_2

.l_17d1

 ASL A
 BCS l_17d8
 CMP line_1
 BCC l_17db

.l_17d8

 SBC line_1
 SEC

.l_17db

 ROL line_2
 BCS l_17d1
 LDX line_1
 INX
 LDA y_hi
 SBC y_lo
 BCS l_1814
 LDA line_5
 BNE l_17f3
 DEX

.l_17ed

 LDA line_3

.change_1

 EOR (ptr),Y
 STA (ptr),Y

.l_17f3

 LSR line_3
 BCC l_17ff
 ROR line_3
 LDA ptr
 ADC #&08
 STA ptr

.l_17ff

 LDA line_4
 ADC line_2
 STA line_4
 BCC l_180e
 DEY
 BPL l_180e
 DEC ptr+&01
 LDY #&07

.l_180e

 DEX
 BNE l_17ed
 RTS

.l_1814

 LDA line_5
 BEQ l_181f
 DEX

.l_1819

 LDA line_3

.change_2

 EOR (ptr),Y
 STA (ptr),Y

.l_181f

 LSR line_3
 BCC l_182b
 ROR line_3
 LDA ptr
 ADC #&08
 STA ptr

.l_182b

 LDA line_4
 ADC line_2
 STA line_4
 BCC l_183c
 INY
 CPY #&08
 BNE l_183c
 INC ptr+&01
 LDY #&00

.l_183c

 DEX
 BNE l_1819
 RTS

.l_1842

 LDY y_lo
 TYA
 LDX x_lo
 CPY y_hi
 BCS l_185b
 DEC line_5
 LDA x_hi
 STA x_lo
 STX x_hi
 TAX
 LDA y_hi
 STA y_lo
 STY y_hi
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
 STA line_3
 LDA y_lo
 AND #&07
 TAY
 LDA line_1
 LDX #&01
 STX line_1

.l_187b

 ASL A
 BCS l_1882
 CMP line_2
 BCC l_1885

.l_1882

 SBC line_2
 SEC

.l_1885

 ROL line_1
 BCC l_187b
 LDX line_2
 INX
 LDA x_hi
 SBC x_lo
 BCC l_18bf
 CLC
 LDA line_5
 BEQ l_189e
 DEX

.l_1898

 LDA line_3

.change_3

 EOR (ptr),Y
 STA (ptr),Y

.l_189e

 DEY
 BPL l_18a5
 DEC ptr+&01
 LDY #&07

.l_18a5

 LDA line_4
 ADC line_1
 STA line_4
 BCC l_18b9
 LSR line_3
 BCC l_18b9
 ROR line_3
 LDA ptr
 ADC #&08
 STA ptr

.l_18b9

 DEX
 BNE l_1898
 RTS

.l_18bf

 LDA line_5
 BEQ l_18ca
 DEX

.l_18c4

 LDA line_3

.change_4

 EOR (ptr),Y
 STA (ptr),Y

.l_18ca

 DEY
 BPL l_18d1
 DEC ptr+&01
 LDY #&07

.l_18d1

 LDA line_4
 ADC line_1
 STA line_4
 BCC l_18e6
 ASL line_3
 BCC l_18e6
 ROL line_3
 LDA ptr
 SBC #&07
 STA ptr
 CLC

.l_18e6

 DEX
 BNE l_18c4

.l_18eb

 RTS


.draw_hline

 JSR tube_get
 STA x_lo
 JSR tube_get
 STA y_lo
 JSR tube_get
 STA x_hi

.draw_hline2

 LDX x_lo
 CPX x_hi
 BEQ l_18eb
 BCC l_1924
 LDA x_hi
 STA x_lo
 STX x_hi
 TAX

.l_1924

 DEC x_hi
 LDA y_lo
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA y_lo
 AND #&07
 STA ptr
 TXA
 AND #&F8
 TAY
 TXA
 AND #&F8
 STA line_2
 LDA x_hi
 AND #&F8
 SEC
 SBC line_2
 BEQ l_197e
 LSR A
 LSR A
 LSR A
 STA line_1
 LDA x_lo
 AND #&07
 TAX
 LDA horiz_seg+&07,X
 EOR (ptr),Y
 STA (ptr),Y
 TYA
 ADC #&08
 TAY
 LDX line_1
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

 LDA x_hi
 AND #&07
 TAX
 LDA horiz_seg,X
 EOR (ptr),Y
 STA (ptr),Y
 RTS

.l_197e

 LDA x_lo
 AND #&07
 TAX
 LDA horiz_seg+&07,X
 STA line_2
 LDA x_hi
 AND #&07
 TAX
 LDA horiz_seg,X
 AND line_2
 EOR (ptr),Y
 STA (ptr),Y
 RTS

.horiz_seg

 EQUB &80, &C0, &E0, &F0, &F8, &FC, &FE
 EQUB &FF, &7F, &3F, &1F, &0F, &07, &03, &01


.l_19a8

 LDA pixel_1,X
 EOR (ptr),Y
 STA (ptr),Y
 RTS

.draw_pixel

 JSR tube_get
 TAX
 JSR tube_get
 TAY
 JSR tube_get
 STA drawpix_1
 TYA
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
 LDA drawpix_1
 CMP #&90
 BCS l_19a8
 LDA pixel_2,X
 EOR (ptr),Y
 STA (ptr),Y
 LDA drawpix_1
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

 RTS


.clr_scrn

 LDX #&60

.l_254f

 JSR clr_page
 INX
 CPX #&78
 BNE l_254f
 RTS


.clr_page

 LDY #&00
 STY ptr
 TYA
 STX ptr+&01

.l_3a07

 STA (ptr),Y
 INY
 BNE l_3a07
 RTS


.clr_line

 LDA #&75
 STA ptr+&01
 LDA #&07
 STA ptr
 LDA #&00
 JSR clr_e9
 INC ptr+&01
 JSR clr_e9
 INC ptr+&01

.clr_e9

 LDY #&E9

.l_25c8

 STA (ptr),Y
 DEY
 BNE l_25c8
 RTS


.sync_in

 JSR sync
 JMP tube_put


.sync

 LDA #&00
 STA &8B

.sync_wait

 LDA &8B
 BEQ sync_wait
 RTS


.draw_bar

 JSR tube_get
 STA bar_1
 JSR tube_get
 STA bar_2
 JSR tube_get
 STA ptr
 JSR tube_get
 STA ptr+1
 LDX #&FF
 STX bar_3
 LDY #&02
 LDX #&03

.bar_byte

 LDA bar_1
 CMP #&04
 BCC bar_part
 SBC #&04
 STA bar_1
 LDA bar_3

.l_1edc

 AND bar_2
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
 STA bar_1
 LDA bar_3

.l_1ef6

 ASL A
 AND #&EF
 DEC bar_1
 BPL l_1ef6
 PHA
 LDA #&00
 STA bar_3
 LDA #&63
 STA bar_1
 PLA
 JMP l_1edc

.l_1f0a

 RTS


.draw_angle

 JSR tube_get
 STA angle_1
 JSR tube_get
 STA ptr
 JSR tube_get
 STA ptr+1
 LDY #&01

.l_1f11

 SEC
 LDA angle_1
 SBC #&04
 BCS l_1f26
 LDA #&FF
 LDX angle_1
 STA angle_1
 LDA pixel_3,X
 AND #&F0
 JMP l_1f2a

.l_1f26

 STA angle_1
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
 RTS


.put_missle

 JSR tube_get
 ASL A
 ASL A
 ASL A
 STA missle_1
 LDA #&31-8
 SBC missle_1
 STA ptr
 LDA #&7E
 STA ptr+&01
 JSR tube_get
 LDY #&05

.l_33ba

 STA (ptr),Y
 DEY
 BNE l_33ba
 RTS


.scan_fire

 LDA #&51
 STA &FE60
 LDA &FE40
 AND #&10
 JMP tube_put


.write_fe4e

 JSR tube_get
 STA &FE4E
 JMP tube_put


.scan_xin

 JSR tube_get
 TAX
 JSR scan_x
 JMP tube_put


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


.scan_10in

 JSR scan_10
 JMP tube_put


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
 CMP #&37	\ CTRL-P hack for printer
 BNE scan_test
 LDX #&01
 JSR scan_x
 BPL scan_p
 JSR printer
 LDA #0
 RTS	

.scan_p

 LDA #&37

.scan_test

 TAX
 RTS


.get_key

 JSR sync
 JSR sync
 JSR scan_10
 BNE get_key

.press

 JSR scan_10
 BEQ press
 TAY
 LDA (key_tube),Y
 JMP tube_put


.write_pod

 JSR tube_get
 STA &0386
 JSR tube_get
 STA &0348
 RTS


.draw_blob

 JSR tube_get
 STA drawpix_1
 JSR tube_get
 STA drawpix_2
 JSR tube_get
 STA drawpix_3

.d_36ac

 LDA drawpix_2
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA drawpix_1
 AND #&F8
 STA ptr
 LDA drawpix_2
 AND #&07
 TAY
 LDA drawpix_1
 AND #&06
 LSR A
 TAX
 LDA pixel_3,X
 AND drawpix_3
 EOR (ptr),Y
 STA (ptr),Y
 LDA pixel_3+1,X
 BPL d_36dd
 LDA ptr
 ADC #&08
 STA ptr
 LDA pixel_3+1,X

.d_36dd

 AND drawpix_3
 EOR (ptr),Y
 STA (ptr),Y
 RTS


.draw_tail

 JSR tube_get
 STA drawpix_1
 JSR tube_get
 STA drawpix_2
 JSR tube_get
 STA drawpix_3
 JSR tube_get
 STA drawpix_4
 JSR tube_get
 STA drawpix_5
 JSR d_36ac
 DEC drawpix_2
 JSR d_36ac
 LDA pixel_3+1,X
 AND drawpix_3	\ iff
 STA drawpix_3
 LDA pixel_3+1,X
 AND drawpix_4
 STA drawpix_4
 LDX drawpix_5
 BEQ d_55da
 BMI d_55db

.d_55ca

 DEY
 BPL d_55d1
 LDY #&07
 DEC ptr+&01

.d_55d1

 LDA drawpix_3
 EOR drawpix_4	\ iff
 STA drawpix_3	\ iff
 EOR (ptr),Y
 STA (ptr),Y
 DEX
 BNE d_55ca

.d_55da

 RTS

.d_55db

 INY
 CPY #&08
 BNE d_55e4
 LDY #&00
 INC ptr+&01

.d_55e4

 INY
 CPY #&08
 BNE d_55ed
 LDY #&00
 INC ptr+&01

.d_55ed

 LDA drawpix_3
 EOR drawpix_4	\ iff
 STA drawpix_3	\ iff
 EOR (ptr),Y
 STA (ptr),Y
 INX
 BNE d_55e4
 RTS


.draw_E

 LDA #&38
 LDX #LO(d_3832)
 LDY #HI(d_3832)
 JMP draw_let

.draw_S

 LDA #&C0
 LDX #<(d_3832+3)
 LDY #>(d_3832+3)

.draw_let

 STA ptr
 LDA #&7D
 STA ptr+1
 STX font
 STY font+1
 LDY #&07

.draw_eor

 LDA (font),Y
 EOR (ptr),Y
 STA (ptr),Y
 DEY
 BPL draw_eor
 RTS


.d_3832

 EQUB &E0, &E0, &80, &E0, &E0, &80, &E0, &E0, &20, &E0, &E0


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
 RTS


.write_crtc

 JSR tube_get
 LDX #&06
 SEI
 STX &FE00
 STA &FE01
 CLI
 RTS


.d_4419

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
 BPL b_quit

.scan_y

 JSR tube_get
 TAY
 JSR tube_get
 BMI b_14
 LDX d_4419-1,Y
 JSR scan_x
 BPL b_quit

.b_pressed

 LDA #&FF

.b_quit

 JMP tube_put


.write_0346

 JSR tube_get
 STA &0346
 RTS


.read_0346

 LDA &0346
 JMP tube_put


.picture_h

 JSR tube_get
 STA picture_1
 JSR tube_get
 STA picture_2
 LDA picture_1
 CLC
 ADC #&60
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA ptr+&01
 LDA picture_1
 AND #&07
 STA ptr
 LDY #&00
 JSR l_20e8
 LDA #&04
 LDY #&F8
 JSR l_2101
 LDY picture_2
 BEQ l_2045
 JSR l_20e8
 LDY #&80
 LDA #&40
 JSR l_2101

.l_2045

 RTS


.picture_v

 JSR tube_get
 AND #&F8
 STA ptr
 LDX #&60
 STX ptr+&01
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

 RTS


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

rawrch = &FFBC


.printer

 LDA #2
 JSR print_safe
 LDA #'@'
 JSR print_esc
 LDA #'A'
 JSR print_esc
 LDA #8
 JSR print_wrch
 LDA #&60
 STA ptr+1
 LDA #0
 STA ptr

.print_view

 LDA #'K'
 JSR print_esc
 LDA #0
 JSR print_wrch
 LDA #1
 JSR print_wrch

.print_outer

 LDY #7
 LDX #&FF

.print_copy

 INX
 LDA (ptr),Y
 STA print_bits,X
 DEY	
 BPL print_copy
 LDA ptr+1
 CMP #&78
 BCC print_inner

.print_radar

 LDY #7
 LDA #0

.print_split

 ASL print_bits,X
 BCC print_merge
 ORA print_tone,Y

.print_merge

 DEY
 BPL print_split
 STA print_bits,X
 DEX
 BPL print_radar

.print_inner

 LDY #7

.print_block

 LDX #7

.print_slice

 ASL print_bits,X
 ROL A
 DEX
 BPL print_slice
 JSR print_wrch
 DEY
 BPL print_block

.print_next

 CLC
 LDA ptr
 ADC #8
 STA ptr
 BNE print_outer
 LDA #13
 JSR print_wrch
 INC ptr+1
 LDX ptr+1
 INX
 BPL print_view
 LDA #3
 JMP print_safe
 \	JSR print_safe
 \	JMP tube_put


.print_tone

 EQUB &03, &0C, &30, &C0, &03, &0C, &30, &C0


.print_esc

 PHA
 LDA #27
 JSR print_wrch
 PLA

.print_wrch

 PHA
 LDA #1
 JSR print_safe
 PLA

.print_safe

 PHA
 TYA
 PHA
 TXA
 PHA
 TSX
 LDA &103,X
 JSR rawrch
 PLA
 TAX
 PLA
 TAY
 PLA
 RTS

SAVE "output/2.H.bin", CODE%, P%, LOAD%