\ ******************************************************************************
\
\ ELITE-A LOADER SOURCE
\
\ Elite-A was written by Angus Duggan, and is an extended version of the BBC
\ Micro disc version of Elite; the extra code is copyright Angus Duggan
\
\ Elite was written by Ian Bell and David Braben and is copyright Acornsoft 1984
\
\ The code on this site is identical to Angus Duggan's source discs (it's just
\ been reformatted and variable names changed to be more readable)
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * output/ELITE.bin
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

CODE% = &1900
ORG CODE%
LOAD% = &1900
\EXEC = l_197b

key_io = &04
key_tube = &90

brkv = &0202
irq1v = &0204
bytev = &020A
wrchv = &020E
filev = &0212
fscv = &021E
netv = &0224
ind2v = &0232
cmdr_iff = &036E
OSWRCH = &FFEE
OSWORD = &FFF1
OSBYTE = &FFF4
OSCLI = &FFF7

.l_1900

 EQUB &16, &04, &1C, &02, &11, &0F, &10, &17, &00, &06, &1F, &00
 EQUB &00, &00, &00, &00, &00, &17, &00, &0C, &0C, &00, &00, &00
 EQUB &00, &00, &00, &17, &00, &0D, &00, &00, &00, &00, &00, &00
 EQUB &00, &17, &00, &01, &20, &00, &00, &00, &00, &00, &00, &17
 EQUB &00, &02, &2D, &00, &00, &00, &00, &00, &00, &17, &00, &0A
 EQUB &20, &00, &00, &00, &00, &00, &00

.envelope1

 EQUB &01, &01, &00, &6F, &F8, &04, &01, &08, &08, &FE, &00, &FF
 EQUB &7E, &2C

.envelope2

 EQUB &02, &01, &0E, &EE, &FF, &2C, &20, &32, &06, &01, &00, &FE
 EQUB &78, &7E

.envelope3

 EQUB &03, &01, &01, &FF, &FD, &11, &20, &80, &01, &00, &00, &FF
 EQUB &01, &01

.envelope4

 EQUB &04, &01, &04, &F8, &2C, &04, &06, &08, &16, &00, &00, &81
 EQUB &7E, &00

\OPT NOCMOS

.l_197b

 CLI
 LDA #&90
 LDX #&FF
 LDY #&01
 JSR OSBYTE
 LDA #LO(l_1900)
 STA &70
 LDA #HI(l_1900)
 STA &71
 LDY #&00

.vdu_loop

 LDA (&70),Y
 JSR OSWRCH
 INY 
 CPY #&43
 BNE vdu_loop
 JSR seed
 LDA #&10
 LDX #&02
 JSR OSBYTE
 LDA #&60
 STA ind2v
 LDA #HI(ind2v)
 STA netv+&01
 LDA #LO(ind2v)
 STA netv
 LDA #&BE
 LDX #&08
 JSR osb_set
 LDA #&C8
 LDX #&03
 JSR osb_set
 LDA #&0D
 LDX #&00
 JSR osb_set
 LDA #&E1
 LDX #&80
 JSR osb_set
 LDA #&0D
 LDX #&02
 JSR osb_set
 LDA #&04
 LDX #&01
 JSR osb_set
 LDA #&09
 LDX #&00
 JSR osb_set
 LDA #&77
 JSR OSBYTE
 JSR or789
 LDA #&00
 STA &70
 LDA #&11
 STA &71
 LDA #LO(to1100)
 STA &72
 LDA #HI(to1100)
 STA &73
 JSR decode
 LDA #&EE
 STA brkv
 LDA #&11
 STA brkv+&01
 LDA #&00
 STA &70
 LDA #&78
 STA &71
 LDA #LO(to7800)
 STA &72
 LDA #HI(to7800)
 STA &73
 LDX #&08
 JSR decodex
 LDA #&00
 STA &70
 LDA #&61
 STA &71
 LDA #LO(to6100)
 STA &72
 LDA #HI(to6100)
 STA &73
 JSR decode
 LDA #&63
 STA &71
 LDA #LO(to6300)
 STA &72
 LDA #HI(to6300)
 STA &73
 JSR decode
 LDA #&76
 STA &71
 LDA #LO(to7600)
 STA &72
 LDA #HI(to7600)
 STA &73
 JSR decode
 LDX #LO(envelope1)
 LDY #HI(envelope1)
 LDA #&08
 JSR OSWORD
 LDX #LO(envelope2)
 LDY #HI(envelope2)
 LDA #&08
 JSR OSWORD
 LDX #LO(envelope3)
 LDY #HI(envelope3)
 LDA #&08
 JSR OSWORD
 LDX #LO(envelope4)
 LDY #HI(envelope4)
 LDA #&08
 JSR OSWORD
 LDX #LO(l_1d44)
 LDY #HI(l_1d44)
 JSR OSCLI
 LDA #&F0	\ set up DDRB
 STA &FE62
 LDA #0	\ Set up palatte flags
 STA &348
 STA &346
 LDA #&FF
 STA &386
 SEI 
 LDA &FE44
 \	STA &01
 LDA #&39
 STA &FE4E
 LDA #&7F
 STA &FE6E
 LDA irq1v
 STA &7FFE
 LDA irq1v+&01
 STA &7FFF
 LDA #&4B
 STA irq1v
 LDA #&11
 STA irq1v+&01
 LDA #&39
 STA &FE45
 CLI 
 LDA #0	\ test for BBC Master
 LDX #1
 JSR OSBYTE	\ get OS version
 CPX #3
 BCC not_master
 LDX #0	\ copy master code to DD00

.cpmaster

 LDA to_dd00,X
 STA &DD00,X
 INX
 CPX #dd00_len
 BNE cpmaster
 LDA #&8F	\ service call
 LDX #&21	\ ?
 LDY #&C0	\ ? top of absolute workspace
 JSR OSBYTE	\ ? in XY
 STX put0+1	\ modify workspace save address
 STX put1+1
 STX put2+1
 STX get0+1	\ modify workspace restore address
 STX get1+1
 STX get2+1
 STY put0+2
 STY get0+2
 INY
 STY put1+2
 STY get1+2
 INY
 STY put2+2
 STY get2+2
 LDA filev	\ modify address for old FILEV
 STA old_filev+1
 LDA filev+1
 STA old_filev+2
 LDA fscv	\ modify address for old FSCV
 STA old_fscv+1
 LDA fscv+1
 STA old_fscv+2
 LDA bytev	\ modify address for old BYTEV
 STA old_bytev+1
 LDA bytev+1
 STA old_bytev+2
 JSR set_vectors	\ replace FILEV and FSCV

.not_master

 LDA #&EA	\ test for tube
 LDY #&FF
 LDX #&00
 JSR OSBYTE
 TXA
 BNE tube_go
 LDA #&AC	\ keyboard translation table
 LDX #&00
 LDY #&FF
 JSR OSBYTE
 STX key_io
 STY key_io+&01
 LDA #&00
 STA &70
 LDA #&04
 STA &71
 LDA #LO(to400)
 STA &72
 LDA #HI(to400)
 STA &73
 LDX #&04
 JSR decodex
 LDA #&E9
 STA wrchv
 LDA #&11
 STA wrchv+&01
 LDA #&00
 STA &70
 LDA #&0B
 STA &71
 LDA #LO(tob00)
 STA &72
 LDA #HI(tob00)
 STA &73
 JSR decode
 LDY #&23

.copy_d7a

 LDA tod7a,Y
 STA &0D7A,Y
 DEY
 BPL copy_d7a
 JMP &0B00

.tube_go

 LDA #&AC	\ keyboard translation table
 LDX #&00
 LDY #&FF
 JSR OSBYTE
 STX key_tube
 STY key_tube+&01
 \	LDX #LO(tube_400)
 \	LDY #HI(tube_400)
 \	LDA #1
 \	JSR &0406
 \	LDA #LO(to400)
 \	STA &72
 \	LDA #HI(to400)
 \	STA &73
 \	LDX #&04
 \	LDY #&00
 \tube_wr	LDA (&72),Y
 \	JSR tube_wait
 \	BIT tube_r3s
 \	BVC tube_wr
 \	STA tube_r3d
 \	INY
 \	BNE tube_wr
 \	INC &73
 \	DEX
 \	BNE tube_wr
 \	LDA #LO(tube_wrch)
 \	STA wrchv
 \	LDA #HI(tube_wrch)
 \	STA wrchv+&01
 LDX #LO(tube_run)
 LDY #HI(tube_run)
 JMP OSCLI

.tube_run

 EQUS "R.2.H", &0D

 \tube_400	EQUD &0400

 \tube_wait
 \	JSR tube_wait2
 \tube_wait2
 \	JSR tube_wait3
 \tube_wait3
 \	RTS

.tod7a

 LDX cmdr_iff	\ iff code
 BEQ iff_not
 LDY #&24
 LDA (&20),Y
 ASL A
 ASL A
 BCS iff_cop
 ASL A
 BCS iff_trade
 LDY &8C
 DEY
 BEQ iff_missle
 CPY #&08
 BCC iff_aster
 INX	\ X=4

.iff_missle

 INX	\ X=3

.iff_aster

 INX	\ X=2

.iff_cop

 INX	\ X=1

.iff_trade

 INX	\ X=0

.iff_not

 RTS	\ X=0

.tob00

 LDX #<(l_tcode-tob00+&B00)
 LDY #>(l_tcode-tob00+&B00)
 JSR OSCLI
 JMP &11E6

.l_tcode

 EQUS "L.1.D", &0D

.seed

 LDA &FE44
 STA tlo_copy
 JSR swap
 JSR abs
 STA &71
 LDA &72
 STA &70
 JSR swap
 STA &74
 JSR abs
 TAX 
 LDA &72
 ADC &70
 STA &70
 TXA 
 ADC &71
 BCS l_1bd3
 STA &71
 LDA #&01
 SBC &70
 STA &70
 LDA #&40
 SBC &71
 STA &71
 BCC l_1bd3
 JSR l_1cef
 LDA &70
 LSR A
 TAX 
 LDA &74
 CMP #&80
 ROR A
 JSR power_tab

.l_1bd3

 DEC count
 BNE seed
 DEC count+&01
 BNE seed

.l_1bdd

 JSR swap
 TAX 
 JSR abs
 STA &71
 JSR swap
 STA &74
 JSR abs
 ADC &71
 CMP #&11
 BCC l_1bf9
 LDA &74
 JSR power_tab

.l_1bf9

 DEC count2
 BNE l_1bdd
 DEC count2+&01
 BNE l_1bdd

.l_1c03

 JSR swap
 STA &70
 JSR abs
 STA &71
 JSR swap
 STA &74
 JSR abs
 STA &75
 ADC &71
 STA &71
 LDA &70
 CMP #&80
 ROR A
 CMP #&80
 ROR A
 ADC &74
 TAX 
 JSR abs
 TAY 
 ADC &71
 BCS l_1c4b
 CMP #&50
 BCS l_1c4b
 CMP #&20
 BCC l_1c4b
 TYA 
 ADC &75
 CMP #&10
 BCS l_1c46
 LDA &70
 BPL l_1c4b

.l_1c46

 LDA &74
 JSR power_tab

.l_1c4b

 DEC count3
 BNE l_1c03
 DEC count3+&01
 BNE l_1c03
 LDA #&00
 STA &70
 LDA #&63
 STA &71
 LDA #&62
 STA &72
 LDA #&2A
 STA &73
 LDX #&08
 JSR decode

.swap

 LDA tlo_copy
 TAX 
 ADC tlo_inc
 STA tlo_copy
 STX tlo_inc
 LDA thi_copy
 TAX 
 ADC thi_inc
 STA thi_copy
 STX thi_inc
 RTS 

.thi_copy

 EQUB &49

.tlo_copy

 EQUB &53

.thi_inc

 EQUB &78

.tlo_inc

 EQUB &34

.abs

 BPL notneg
 EOR #&FF
 CLC 
 ADC #&01

.notneg

 STA &73
 STA &72
 LDA #&00
 LDY #&08
 LSR &72

.l_1c9a

 BCC l_1c9f
 CLC 
 ADC &73

.l_1c9f

 ROR A
 ROR &72
 DEY 
 BNE l_1c9a
 RTS 

.power_tab

 TAY 
 EOR #&80
 LSR A
 LSR A
 LSR A
 LSR &79
 ORA #&60
 STA &71
 TXA 
 EOR #&80
 AND #&F8
 STA &70
 TYA 
 AND #&07
 TAY 
 TXA 
 AND #&07
 TAX 
 LDA l_1cc7,X
 STA (&70),Y
 RTS 

.l_1cc7

 EQUB &80, &40, &20, &10, &08, &04, &02, &01

.count

 EQUW &0300

.count2

 EQUW &01DD

.count3

 EQUW &0333

.or789

 LDA &78
 AND &79
 ORA #&0C
 ASL A
 STA &78
 RTS 

.l_1cef

 LDY &71
 LDA &70
 STA &73
 LDX #&00
 STX &70
 LDA #&08
 STA &72

.l_1cfd

 CPX &70
 BCC l_1d0f
 BNE l_1d07
 CPY #&40
 BCC l_1d0f

.l_1d07

 TYA 
 SBC #&40
 TAY 
 TXA 
 SBC &70
 TAX 

.l_1d0f

 ROL &70
 ASL &73
 TYA 
 ROL A
 TAY 
 TXA 
 ROL A
 TAX 
 ASL &73
 TYA 
 ROL A
 TAY 
 TXA 
 ROL A
 TAX 
 DEC &72
 BNE l_1cfd
 RTS 

.osb_set

 LDY #&00
 JMP OSBYTE

.decode

 LDY #&00

.l_1d2e

 LDA (&72),Y
 STA (&70),Y
 DEY 
 BNE l_1d2e
 RTS 

.decodex

 JSR decode
 INC &71
 INC &73
 DEX 
 BNE decodex
 RTS 

.l_1d44

 EQUS "DIR e", &0D

.to7800

 EQUB &F0, &80, &87, &84, &87, &84, &84, &80, &F0, &00, &06, &04
 EQUB &06, &02, &06, &00, &F0, &00, &00, &00, &00, &00, &00, &FF
 EQUB &F0, &00, &00, &00, &00, &00, &00, &FF, &F0, &00, &00, &00
 EQUB &00, &00, &00, &FF, &F0, &00, &00, &00, &00, &00, &00, &FF
 EQUB &F0, &96, &A4, &C0, &80, &80, &80, &80, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00
 EQUB &F0, &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00
 EQUB &F0, &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00
 EQUB &F0, &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00
 EQUB &F0, &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00
 EQUB &F0, &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00
 EQUB &00, &00, &00, &00, &F0, &96, &A4, &C0, &C0, &C0, &C0, &80
 EQUB &F0, &02, &00, &06, &00, &06, &00, &06, &F0, &96, &52, &70
 EQUB &30, &30, &10, &10, &F0, &00, &00, &00, &00, &00, &55, &FF
 EQUB &F0, &00, &00, &00, &00, &00, &55, &FF, &F0, &00, &00, &00
 EQUB &00, &00, &55, &FF, &F0, &00, &00, &00, &00, &00, &55, &FF
 EQUB &F0, &00, &06, &04, &06, &02, &06, &00, &F0, &10, &1E, &1A
 EQUB &1E, &18, &18, &10, &80, &87, &85, &85, &87, &85, &80, &80
 EQUB &00, &06, &04, &06, &02, &06, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &80, &80, &80, &80, &80, &80, &80, &80
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &01, &06, &00, &00, &00, &00
 EQUB &00, &00, &06, &00, &00, &00, &00, &00, &01, &0C, &02, &00
 EQUB &00, &00, &00, &00, &06, &88, &00, &00, &00, &00, &00, &00
 EQUB &0B, &00, &00, &00, &00, &00, &00, &00, &07, &00, &02, &00
 EQUB &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00
 EQUB &0D, &00, &00, &00, &00, &00, &00, &00, &04, &8A, &02, &00
 EQUB &00, &00, &00, &00, &00, &0C, &01, &00, &00, &00, &00, &00
 EQUB &00, &00, &08, &03, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &80, &80, &82, &80
 EQUB &80, &80, &80, &C0, &00, &00, &09, &00, &00, &06, &00, &06
 EQUB &10, &10, &14, &10, &10, &10, &10, &10, &00, &00, &00, &00
 EQUB &00, &00, &22, &FF, &00, &00, &00, &00, &00, &00, &AA, &FF
 EQUB &88, &88, &00, &00, &00, &88, &AA, &FF, &00, &00, &00, &00
 EQUB &00, &00, &AA, &FF, &00, &00, &06, &05, &07, &06, &05, &00
 EQUB &10, &10, &14, &14, &14, &14, &16, &10, &80, &86, &84, &86
 EQUB &84, &84, &80, &80, &00, &0A, &0A, &0A, &0A, &04, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &99, &FF, &00, &00, &00, &00
 EQUB &00, &00, &22, &FF, &00, &00, &00, &00, &00, &00, &44, &FF
 EQUB &00, &00, &00, &00, &00, &00, &99, &FF, &80, &80, &80, &80
 EQUB &80, &80, &80, &80, &00, &00, &00, &00, &00, &00, &01, &02
 EQUB &00, &00, &00, &03, &04, &08, &00, &00, &01, &06, &08, &02
 EQUB &00, &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00, &00
 EQUB &00, &00, &00, &0A, &01, &00, &02, &00, &04, &00, &08, &0A
 EQUB &00, &00, &00, &00, &22, &00, &00, &0A, &00, &00, &00, &00
 EQUB &00, &00, &00, &8A, &00, &00, &22, &00, &02, &00, &02, &08
 EQUB &02, &00, &02, &00, &00, &00, &00, &0A, &00, &00, &22, &00
 EQUB &22, &00, &00, &8A, &00, &00, &00, &00, &01, &00, &00, &0A
 EQUB &00, &00, &00, &00, &00, &00, &08, &02, &04, &00, &02, &00
 EQUB &00, &00, &00, &0A, &00, &00, &00, &00, &08, &03, &00, &0A
 EQUB &00, &00, &00, &00, &00, &00, &08, &06, &01, &00, &00, &00
 EQUB &40, &40, &60, &20, &30, &18, &04, &02, &00, &06, &00, &06
 EQUB &00, &F0, &00, &00, &30, &30, &52, &52, &96, &F0, &10, &10
 EQUB &00, &00, &00, &00, &00, &00, &22, &FF, &00, &00, &00, &00
 EQUB &00, &00, &44, &FF, &88, &88, &00, &00, &00, &88, &99, &FF
 EQUB &00, &00, &00, &00, &00, &00, &22, &FF, &00, &06, &05, &05
 EQUB &05, &06, &00, &00, &10, &16, &14, &14, &14, &16, &10, &10
 EQUB &80, &86, &84, &84, &84, &86, &80, &80, &00, &0E, &04, &04
 EQUB &04, &04, &00, &00, &00, &00, &00, &00, &00, &00, &88, &FF
 EQUB &00, &00, &00, &00, &00, &00, &88, &FF, &00, &00, &00, &00
 EQUB &00, &00, &88, &FF, &00, &00, &00, &00, &00, &00, &88, &FF
 EQUB &80, &80, &80, &80, &80, &80, &80, &80, &00, &04, &04, &08
 EQUB &0A, &00, &08, &00, &00, &00, &00, &00, &0A, &00, &00, &00
 EQUB &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00
 EQUB &0A, &00, &02, &00, &04, &00, &08, &00, &0A, &00, &00, &00
 EQUB &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00
 EQUB &0A, &00, &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00
 EQUB &02, &88, &02, &00, &28, &70, &02, &00, &00, &88, &00, &00
 EQUB &0A, &00, &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00
 EQUB &00, &00, &00, &00, &0A, &00, &00, &00, &01, &00, &00, &00
 EQUB &0A, &00, &00, &00, &00, &00, &08, &00, &0A, &00, &02, &00
 EQUB &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00
 EQUB &0A, &00, &00, &00, &02, &01, &01, &00, &0A, &00, &00, &00
 EQUB &00, &00, &00, &08, &00, &08, &00, &08, &10, &10, &10, &10
 EQUB &10, &10, &10, &10, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &01, &03, &01, &01, &03, &00, &00, &10, &10, &10, &10
 EQUB &10, &18, &10, &10, &80, &84, &84, &84, &84, &86, &80, &80
 EQUB &00, &0E, &04, &04, &04, &04, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &99, &FF, &00, &00, &00, &00, &00, &00, &22, &FF
 EQUB &00, &00, &00, &00, &00, &00, &44, &FF, &00, &00, &00, &00
 EQUB &00, &00, &88, &FF, &80, &80, &80, &80, &80, &80, &80, &80
 EQUB &08, &04, &04, &02, &02, &01, &00, &00, &00, &00, &00, &00
 EQUB &00, &08, &0A, &04, &00, &00, &00, &00, &01, &00, &0A, &00
 EQUB &04, &00, &08, &00, &00, &00, &0A, &00, &00, &00, &00, &00
 EQUB &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00, &0A, &00
 EQUB &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00
 EQUB &00, &00, &0A, &00, &02, &00, &02, &00, &02, &00, &0A, &00
 EQUB &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00, &00, &00
 EQUB &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00, &0A, &00
 EQUB &00, &00, &00, &00, &00, &00, &0A, &00, &01, &00, &00, &00
 EQUB &00, &00, &0A, &00, &00, &00, &08, &00, &04, &00, &0A, &00
 EQUB &00, &00, &00, &00, &00, &00, &0A, &01, &00, &01, &01, &03
 EQUB &02, &04, &08, &00, &08, &00, &00, &00, &00, &00, &00, &00
 EQUB &10, &10, &10, &10, &10, &10, &10, &10, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &03, &00, &03, &02, &03, &00, &00, &00
 EQUB &18, &18, &18, &10, &18, &10, &10, &10, &80, &87, &85, &87
 EQUB &85, &85, &80, &80, &00, &04, &04, &04, &04, &06, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &99, &FF, &00, &00, &00, &00
 EQUB &00, &00, &11, &FF, &00, &00, &00, &00, &00, &00, &11, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &80, &80, &80, &80
 EQUB &80, &80, &80, &80, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &02, &01, &00, &00, &00, &00, &00, &00, &04, &08, &04, &01
 EQUB &00, &00, &00, &00, &00, &00, &00, &08, &06, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &0C, &01, &00, &00, &00, &00, &00
 EQUB &00, &00, &0A, &00, &00, &00, &00, &00, &00, &00, &00, &0D
 EQUB &00, &00, &00, &00, &00, &00, &00, &06, &02, &00, &02, &00
 EQUB &02, &00, &02, &0B, &00, &00, &00, &00, &00, &00, &00, &05
 EQUB &00, &00, &00, &00, &00, &00, &00, &0A, &00, &00, &00, &00
 EQUB &00, &00, &05, &08, &00, &00, &00, &00, &00, &03, &08, &00
 EQUB &00, &00, &00, &00, &06, &00, &00, &00, &01, &00, &03, &0C
 EQUB &00, &00, &00, &00, &02, &08, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &10, &10, &10, &10, &10, &10, &10, &10
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FF, &03, &00, &03, &00
 EQUB &03, &00, &00, &02, &18, &18, &18, &18, &18, &10, &10, &10
 EQUB &80, &80, &D0, &87, &85, &80, &80, &F0, &00, &00, &C0, &2C
 EQUB &0C, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &80, &80, &80, &80, &C0, &A4, &96, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &33, &22, &33
 EQUB &22, &33, &00, &F0, &00, &AA, &22, &22, &22, &BB, &00, &F0
 EQUB &00, &22, &22, &22, &22, &AA, &00, &F0, &00, &EE, &44, &44
 EQUB &44, &44, &00, &F0, &00, &EE, &88, &CC, &88, &EE, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &10, &10, &10, &10
 EQUB &30, &52, &96, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &00, &00, &00, &00, &00, &00, &00, &F0, &00, &00, &00, &00
 EQUB &00, &00, &00, &F0, &00, &00, &00, &00, &00, &00, &00, &F0
 EQUB &02, &02, &02, &03, &00, &00, &00, &F0, &10, &18, &18, &18
 EQUB &18, &10, &10, &F0, &00, &40, &06, &7A, &DA, &51, &00, &0A
 EQUB &66, &18, &00, &00, &24, &0E, &02, &2C, &00, &00, &02, &00
 EQUB &00, &00, &44, &1F, &10, &32, &08, &08, &24, &5F, &21, &54
 EQUB &08, &08, &24, &1F, &32, &74, &08, &08, &24, &9F, &30, &76
 EQUB &08, &08, &24, &DF, &10, &65, &08, &08, &2C, &3F, &74, &88
 EQUB &08, &08, &2C, &7F, &54, &88, &08, &08, &2C, &FF, &65, &88
 EQUB &08, &08, &2C, &BF, &76, &88, &0C, &0C, &2C, &28, &74, &88
 EQUB &0C, &0C, &2C, &68, &54, &88, &0C, &0C, &2C, &E8, &65, &88
 EQUB &0C, &0C, &2C, &A8, &76, &88, &08, &08, &0C, &A8, &76, &77
 EQUB &08, &08, &0C, &E8, &65, &66, &08, &08, &0C, &28, &74, &77
 EQUB &08, &08, &0C, &68, &54, &55, &1F, &21, &00, &04, &1F, &32
 EQUB &00, &08, &1F, &30, &00, &0C, &1F, &10, &00, &10, &1F, &24
 EQUB &04, &08, &1F, &51, &04, &10, &1F, &60, &0C, &10, &1F, &73
 EQUB &08, &0C, &1F, &74, &08, &14, &1F, &54, &04, &18, &1F, &65
 EQUB &10, &1C, &1F, &76, &0C, &20, &1F, &86, &1C, &20, &1F, &87
 EQUB &14, &20, &1F, &84, &14, &18, &1F, &85, &18, &1C, &08, &85
 EQUB &18, &28, &08, &87, &14, &24, &08, &87, &20, &30, &08, &85
 EQUB &1C, &2C, &08, &74, &24, &3C, &08, &54, &28, &40, &08, &76
 EQUB &30, &34, &08, &65, &2C, &38, &9F, &40, &00, &10, &5F, &00
 EQUB &40, &10, &1F, &40, &00, &10, &1F, &00, &40, &10, &1F, &20
 EQUB &00, &00, &5F, &00, &20, &00, &9F, &20, &00, &00, &1F, &00
 EQUB &20, &00, &3F, &00, &00, &B0, &00, &00

.to400

 EQUB &4C, &32, &24, &00, &03, &60, &6B, &A9, &77, &00, &64, &6C
 EQUB &B5, &71, &6D, &6E, &B1, &77, &00, &67, &B2, &62, &32, &20
 EQUB &00, &AF, &B5, &6D, &77, &BA, &7A, &2F, &00, &70, &7A, &70
 EQUB &BF, &6E, &00, &73, &BD, &A6, &00, &21, &03, &A8, &71, &68
 EQUB &66, &77, &03, &85, &70, &00, &AF, &67, &AB, &77, &BD, &A3
 EQUB &00, &62, &64, &BD, &60, &76, &6F, &77, &76, &B7, &6F, &00
 EQUB &BD, &60, &6B, &03, &00, &62, &B5, &B7, &A0, &03, &00, &73
 EQUB &6C, &BA, &03, &00, &A8, &AF, &6F, &7A, &03, &00, &76, &6D
 EQUB &6A, &77, &00, &75, &6A, &66, &74, &03, &00, &B9, &B8, &B4
 EQUB &77, &7A, &00, &B8, &A9, &60, &6B, &7A, &00, &65, &66, &76
 EQUB &67, &A3, &00, &6E, &76, &6F, &B4, &0E, &81, &00, &AE, &60
 EQUB &77, &B2, &BA, &9A, &00, &D8, &6E, &76, &6D, &BE, &77, &00
 EQUB &60, &BC, &65, &BB, &B3, &62, &60, &7A, &00, &67, &66, &6E
 EQUB &6C, &60, &B7, &60, &7A, &00, &60, &BA, &73, &BA, &B2, &66
 EQUB &03, &E8, &B2, &66, &00, &70, &6B, &6A, &73, &00, &73, &DD
 EQUB &67, &76, &60, &77, &00, &03, &B6, &70, &B3, &00, &6B, &76
 EQUB &6E, &B8, &03, &60, &6C, &6F, &BC, &6A, &A3, &00, &6B, &7A
 EQUB &73, &B3, &2D, &03, &00, &70, &6B, &BA, &77, &03, &E9, &82
 EQUB &00, &AE, &E8, &B8, &A6, &00, &73, &6C, &73, &76, &6F, &B2
 EQUB &6A, &BC, &00, &64, &DD, &70, &70, &03, &99, &6A, &75, &6A
 EQUB &77, &7A, &00, &66, &60, &BC, &6C, &6E, &7A, &00, &03, &6F
 EQUB &6A, &64, &6B, &77, &03, &7A, &66, &A9, &70, &00, &BF, &60
 EQUB &6B, &0D, &A2, &B5, &6F, &00, &60, &62, &70, &6B, &00, &03
 EQUB &A5, &2C, &6A, &BC, &00, &59, &82, &22, &00, &77, &A9, &A0
 EQUB &77, &03, &6F, &6C, &E8, &00, &49, &03, &69, &62, &6E, &6E
 EQUB &BB, &00, &71, &B8, &A0, &00, &70, &77, &00, &93, &03, &6C
 EQUB &65, &03, &00, &70, &66, &2C, &00, &03, &60, &A9, &64, &6C
 EQUB &25, &00, &66, &B9, &6A, &73, &00, &65, &6C, &6C, &67, &00
 EQUB &BF, &7B, &B4, &6F, &AA, &00, &B7, &AE, &6C, &62, &60, &B4
 EQUB &B5, &70, &00, &70, &B6, &B5, &70, &00, &6F, &6A, &B9, &BA
 EQUB &0C, &74, &AF, &AA, &00, &6F, &76, &7B, &76, &BD, &AA, &00
 EQUB &6D, &A9, &60, &6C, &B4, &60, &70, &00, &D8, &73, &76, &77
 EQUB &B3, &70, &00, &A8, &60, &6B, &AF, &B3, &7A, &00, &62, &2C
 EQUB &6C, &7A, &70, &00, &65, &6A, &AD, &A9, &6E, &70, &00, &65
 EQUB &76, &71, &70, &00, &6E, &AF, &B3, &A3, &70, &00, &64, &6C
 EQUB &6F, &67, &00, &73, &6F, &B2, &AF, &76, &6E, &00, &A0, &6E
 EQUB &0E, &E8, &BC, &AA, &00, &A3, &6A, &B1, &03, &5C, &70, &00
 EQUB &2F, &12, &13, &23, &16, &23, &00, &03, &60, &71, &00, &6F
 EQUB &A9, &A0, &00, &65, &6A, &B3, &A6, &00, &70, &A8, &2C, &00
 EQUB &64, &AD, &B1, &00, &71, &BB, &00, &7A, &66, &2C, &6C, &74
 EQUB &00, &61, &6F, &76, &66, &00, &61, &B6, &60, &68, &00, &35
 EQUB &00, &70, &6F, &6A, &6E, &7A, &00, &61, &76, &64, &0E, &66
 EQUB &7A, &BB, &00, &6B, &BA, &6D, &BB, &00, &61, &BC, &7A, &00
 EQUB &65, &B2, &00, &65, &76, &71, &71, &7A, &00, &DD, &67, &B1
 EQUB &77, &00, &65, &DD, &64, &00, &6F, &6A, &A7, &71, &67, &00
 EQUB &6F, &6C, &61, &E8, &B3, &00, &A5, &71, &67, &00, &6B, &76
 EQUB &6E, &B8, &6C, &6A, &67, &00, &65, &66, &6F, &AF, &66, &00
 EQUB &AF, &70, &66, &60, &77, &00, &88, &B7, &AE, &AB, &00, &60
 EQUB &6C, &6E, &00, &D8, &6E, &B8, &67, &B3, &00, &03, &67, &AA
 EQUB &77, &DD, &7A, &BB, &00, &71, &6C, &00, &8D, &03, &03, &93
 EQUB &2F, &03, &99, &03, &03, &03, &8D, &03, &85, &03, &65, &BA
 EQUB &03, &70, &62, &A2, &2F, &29, &00, &65, &71, &BC, &77, &00
 EQUB &AD, &A9, &00, &A2, &65, &77, &00, &BD, &64, &6B, &77, &00
 EQUB &5A, &6F, &6C, &74, &24, &00, &40, &32, &DF, &02, &00, &66
 EQUB &7B, &77, &B7, &03, &00, &73, &76, &6F, &70, &66, &98, &00
 EQUB &B0, &62, &6E, &98, &00, &65, &76, &66, &6F, &00, &6E, &BE
 EQUB &70, &6A, &A2, &00, &6A, &0D, &65, &0D, &65, &0D, &86, &00
 EQUB &66, &0D, &60, &0D, &6E, &0D, &86, &00, &45, &44, &70, &00
 EQUB &45, &4B, &70, &00, &4A, &03, &70, &60, &6C, &6C, &73, &70
 EQUB &00, &AA, &60, &62, &73, &66, &03, &73, &6C, &67, &00, &9E
 EQUB &8D, &00, &5A, &8D, &00, &67, &6C, &60, &68, &AF, &64, &03
 EQUB &F4, &00, &59, &03, &9E, &00, &6E, &6A, &6F, &6A, &77, &A9
 EQUB &7A, &98, &00, &6E, &AF, &AF, &64, &98, &00, &E6
 EQUB &19, &23, &00, &AF, &D8, &AF, &64, &03, &49, &00, &B1, &B3
 EQUB &64, &7A, &03, &00, &64, &62, &B6, &60, &B4, &60, &00, &50
 EQUB &03, &BC, &00, &62, &2C, &00, &26, &A2, &64, &A3, &03, &E8
 EQUB &B2, &AB, &19, &00, &DF, &03, &27, &2F, &2F, &2F, &25, &3C
 EQUB &03, &86, &2A, &21, &2F, &9E, &86, &2A, &20, &2F, &60, &BC
 EQUB &AE, &B4, &BC, &2A, &00, &6A, &BF, &6E, &00, &70, &73, &62
 EQUB &A6, &00, &6F, &6F, &00, &B7, &B4, &6D, &64, &19, &00, &03
 EQUB &BC, &03, &00, &2F, &9A, &19, &03, &03, &03, &03, &03, &03
 EQUB &03, &03, &03, &03, &00, &60, &A2, &B8, &00, &6C, &65, &65
 EQUB &B1, &67, &B3, &00, &65, &76, &64, &6A, &B4, &B5, &00, &6B
 EQUB &A9, &6E, &A2, &70, &70, &00, &6E, &6C, &E8, &6F, &7A, &03
 EQUB &35, &00, &8F, &00, &88, &00, &62, &61, &6C, &B5, &03, &88
 EQUB &00, &D8, &73, &66, &77, &B1, &77, &00, &67, &B8, &A0, &DD
 EQUB &AB, &00, &67, &66, &62, &67, &6F, &7A, &00, &0E, &0E, &0E
 EQUB &0E, &03, &66, &03, &6F, &03, &6A, &03, &77, &03, &66, &03
 EQUB &0E, &0E, &0E, &0E, &00, &73, &AD, &70, &B1, &77, &00, &2B
 EQUB &64, &62, &6E, &66, &03, &6C, &B5, &71, &00, &00, &00, &00
 EQUB &00, &00
 EQUB &00, &19, &32, &4A, &62, &79, &8E, &A2, &B5, &C6, &D5, &E2
 EQUB &ED, &F5, &FB, &FF, &FF, &FF, &FB, &F5, &ED, &E2, &D5, &C6
 EQUB &B5, &A2, &8E, &79, &62, &4A, &32, &19, &00, &01, &03, &04
 EQUB &05, &06, &08, &09, &0A, &0B, &0C, &0D, &0F, &10, &11, &12
 EQUB &13, &14, &15, &16, &17, &18, &19, &19, &1A, &1B, &1C, &1D
 EQUB &1D, &1E, &1F, &1F

.to1100

 EQUB &D4, &C4, &94, &84
 EQUB &F5, &E5, &B5, &A5
 EQUB &76, &66, &36, &26
 EQUB &E1, &F1, &B1, &A1
 EQUB &F0, &E0, &B0, &A0
 EQUB &D0, &C0, &90, &80
 EQUB &77, &67, &37, &27

.vsync

 LDA #&1E
 STA &8B
 STA &FE44
 LDA #&39
 STA &FE45
 LDA &0348
 BNE ulaother
 LDA #&08
 STA &FE20

.ulaloop2

 LDA &1110,Y
 STA &FE21
 DEY 
 BPL ulaloop2
 LDA &0346
 BEQ nodec
 DEC &0346

.nodec

 PLA 
 TAY 
 LDA &FE41
 LDA &FC
 RTI 

.irq1

 TYA 
 PHA 
 LDY #&0B
 LDA #&02
 BIT &FE4D
 BNE vsync
 BVC return
 ASL A
 STA &FE20
 LDA &0386
 BNE ulaother

.ulaloop

 LDA &1100,Y
 STA &FE21
 DEY 
 BPL ulaloop

.return

 PLA 
 TAY 
 JMP (&7FFE)

.ulaother

 LDY #&07

.ulaloop3

 LDA &1108,Y
 STA &FE21
 DEY 
 BPL ulaloop3
 BMI return

 EQUS ":0.E.NEWCOME", &0D
 EQUB &00, &14, &AD, &4A, &5A, &48, &02, &53, &B7, &00, &00, &13
 EQUB &88, &3C, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &0F, &11, &00, &03, &1C, &0E
 EQUB &00, &00, &0A, &00, &11, &3A, &07, &09, &08, &00, &00, &00
 EQUB &00, &20, &F1, &58

 LDY #&00
 LDA #&0D

.brkloop

 JSR OSWRCH
 INY 
 LDA (&FD),Y
 BNE brkloop

.halt

 BEQ halt

.to6300

 EQUB &00, &00, &00, &00, &00, &00, &07, &3F, &00, &00, &00, &03
 EQUB &1F, &FF, &FF, &FF, &00, &0F, &7F, &FF, &FF, &FF, &FF, &FF
 EQUB &00, &FF, &FF, &FF, &FF, &E0, &80, &FF, &00, &FF, &E0, &00
 EQUB &FF, &00, &00, &FF, &00, &FF, &00, &00, &FE, &00, &00, &FE
 EQUB &00, &FF, &00, &00, &00, &00, &03, &0F, &00, &E1, &07, &0F
 EQUB &3F, &FF, &FF, &FF, &00, &FF, &FF, &FF, &FF, &FF, &FF, &FF
 EQUB &00, &FF, &FE, &FC, &F0, &E0, &C0, &FF, &00, &00, &00, &00
 EQUB &00, &00, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &83, &00, &3F, &00, &00
 EQUB &00, &00, &00, &FF, &00, &FF, &0F, &0F, &0F, &0F, &1F, &FF
 EQUB &00, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &00, &FF, &FC, &FC
 EQUB &FC, &FC, &FE, &FF, &00, &FF, &00, &00, &00, &00, &00, &FF
 EQUB &00, &87, &00, &00, &00, &00, &00, &E0, &00, &FF, &00, &00
 EQUB &00, &00, &00, &00, &00, &FF, &7F, &7F, &3F, &1F, &0F, &07
 EQUB &00, &FF, &FF, &FF, &FF, &FF, &FF, &FF, &00, &FF, &C0, &E0
 EQUB &F8, &FC, &FE, &FF, &00, &E0, &00, &00, &00, &00, &00, &80
 EQUB &00, &FF, &3F, &1F, &07, &01, &00, &00, &00, &FF, &FF, &FF
 EQUB &FF, &FF, &7F, &1F, &00, &FF, &E0, &F8, &FF, &FF, &FF, &FF
 EQUB &00, &FF, &00, &00, &FF, &C0, &F0, &FF, &00, &FC, &00, &00
 EQUB &FF, &00, &00, &FF, &00, &00, &00, &00, &80, &00, &00, &FF
 EQUB &00, &00, &00, &00, &00, &00, &00, &FE, &00, &00, &00, &00
 EQUB &00, &00, &00, &00

.to6100

 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &07
 EQUB &00, &00, &00, &00, &03, &1F, &F8, &C3, &00, &00, &0F, &7C
 EQUB &FF, &0F, &7C, &F0, &00, &3F, &8F, &7C, &F1, &8F, &3F, &3F
 EQUB &00, &C0, &8F, &7C, &F0, &C0, &1F, &F0, &00, &FF, &9F, &00
 EQUB &00, &03, &8F, &07, &00, &01, &1F, &7C, &F8, &E1, &C7, &FE
 EQUB &00, &FE, &1F, &7C, &F8, &F1, &E3, &07, &00, &1F, &3E, &7C
 EQUB &FF, &FB, &F0, &E1, &00, &FC, &3E, &7C, &F0, &E0, &F8, &F8
 EQUB &00, &3E, &3E, &7F, &7F, &7C, &7C, &FC, &00, &7C, &7C, &BE
 EQUB &FE, &FE, &3E, &3F, &00, &3F, &7C, &3E, &0F, &00, &1F, &03
 EQUB &00, &E0, &7C, &00, &F8, &1F, &0F, &FF, &00, &7F, &F8, &3E
 EQUB &1F, &8F, &C7, &00, &00, &83, &F8, &3E, &1F, &87, &E3, &7F
 EQUB &00, &FF, &F8, &3E, &0F, &C7, &F1, &E0, &00, &CF, &00, &00
 EQUB &FE, &E0, &F8, &7E, &00, &FF, &1F, &03, &00, &00, &00, &00
 EQUB &00, &00, &00, &E0, &7C, &1F, &03, &00, &00, &00, &00, &00
 EQUB &00, &80, &F0, &7E, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00

.to7600

 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &01, &03, &07, &00, &00, &01, &0E, &38, &E0, &C3, &87
 EQUB &00, &38, &C3, &0E, &38, &E0, &9C, &E1, &00, &7C, &B8, &00
 EQUB &03, &07, &38, &C0, &00, &70, &70, &E0, &C0, &00, &00, &00
 EQUB &00, &00, &00, &01, &03, &0F, &1C, &39, &00, &3F, &E7, &DE
 EQUB &FD, &73, &E7, &C7, &00, &00, &00, &7E, &CE, &81, &39, &E1
 EQUB &00, &00, &00, &3F, &E7, &EE, &DE, &F8, &00, &00, &00, &3F
 EQUB &7F, &70, &F0, &E0, &00, &00, &00, &9F, &9D, &3D, &3D, &39
 EQUB &00, &00, &00, &C7, &EE, &E7, &C0, &CF, &00, &00, &00, &F3
 EQUB &07, &E7, &73, &E1, &00, &00, &01, &F1, &B9, &BC, &BC, &F8
 EQUB &00, &F1, &C0, &E1, &F8, &F0, &70, &78, &00, &C0, &E0, &FC
 EQUB &70, &38, &3C, &0F, &00, &00, &00, &00, &00, &00, &00, &80
 EQUB &00, &70, &7C, &0E, &07, &03, &01, &03, &00, &7C, &77, &3D
 EQUB &07, &80, &E0, &FC, &00, &7E, &BB, &DE, &F3, &39, &3C, &7C
 EQUB &00, &0E, &87, &E3, &F3, &DE, &F7, &1F, &00, &00, &80, &E0
 EQUB &F8, &FF, &83, &80, &00, &00, &00, &00, &00, &00, &80, &E0
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00

 \ BBC Master 128 code for save/restore characters
CPU 1
.to_dd00

ORG &DD00

 \ trap FILEV

.do_filev

 JSR restorews	\ restore workspace

.old_filev

 JSR &100	\ address modified by master set-up

.savews

 PHP	\ save workspace, copy in characters
 PHA
 PHX
 PHY
 LDA #8	\ select ROM workspace at &C000
 TSB &FE34
 LDX #0

.putws

 LDA &C000,X	\ save absolute workspace

.put0

 STA &C000,X	\ address modified by master set-up
 LDA &C100,X

.put1

 STA &C100,X	\ address modified by master set-up
 LDA &C200,X

.put2

 STA &C200,X	\ address modified by master set-up
 INX
 BNE putws
 LDA &F4	\ save ROM number
 PHA
 LDA #&80	\ select RAM from &8000-&8FFF
 STA &F4
 STA &FE30
 LDX #0

.copych

 LDA &8900,X	\ copy character definitions
 STA &C000,X
 LDA &8A00,X
 STA &C100,X
 LDA &8B00,X
 STA &C200,X
 INX
 BNE copych
 PLA	\ restore ROM selection
 STA &F4
 STA &FE30
 PLY
 PLX
 PLA
 PLP
 RTS

 \ trap FILEV

.do_fscv

 JSR restorews	\ restore workspace

.old_fscv

 JSR &100	\ address modified by master setup
 JMP savews	\ save workspace, restore characters

 \ restore ROM workspace

.restorews

 PHA
 PHX
 LDX #0

.getws

 \ restore absolute workspace

.get0

 LDA &C000,X	\ address modified by master set-up
 STA &C000,X

.get1

 LDA &C100,X	\ address modified by master set-up
 STA &C100,X

.get2

 LDA &C200,X	\ address modified by master set-up
 STA &C200,X
 INX
 BNE getws
 PLX
 PLA
 RTS

 \ trap BYTEV

.do_bytev

 CMP #&8F	\ ROM service request
 BNE old_bytev
 CPX #&F	\ vector claim?
 BNE old_bytev
 JSR old_bytev

.set_vectors

 SEI
 PHA
 LDA #LO(do_filev)	\ reset FILEV
 STA filev
 LDA #HI(do_filev)
 STA filev+1
 LDA #LO(do_fscv)	\ reset FSCV
 STA fscv
 LDA #HI(do_fscv)
 STA fscv+1
 LDA #LO(do_bytev)	\ replace BYTEV
 STA bytev
 LDA #HI(do_bytev)
 STA bytev+1
 PLA
 CLI
 RTS

.old_bytev

 JMP &100	\ address modified by master set_up

dd00_len = P%-&DD00	\ length of code at DD00

COPYBLOCK &DD00, P%, to_dd00
SAVE "output/ELITE.bin", CODE%, to_dd00+dd00_len, LOAD%