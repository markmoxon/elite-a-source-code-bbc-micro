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

\ ******************************************************************************
\
\       Name: CHAR
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for characters in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CHAR 'x'            Insert ASCII character "x"
\
\ To include an apostrophe, use a backtick character, as in i.e. CHAR '`'.
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The character to insert into the table
\
\ ******************************************************************************

MACRO CHAR x

  IF x = '`'
    EQUB 39 EOR 35
  ELSE
    EQUB x EOR 35
  ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: TWOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for two-letter tokens in the token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   TWOK 'x', 'y'       Insert two-letter token "xy"
\
\ See the deep dive on "Printing text tokens" for details on how two-letter
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The first letter of the two-letter token to insert into
\                       the table
\
\   'y'                 The second letter of the two-letter token to insert into
\                       the table
\
\ ******************************************************************************

MACRO TWOK t, k

  IF t = 'A' AND k = 'L' : EQUB 128 EOR 35 : ENDIF
  IF t = 'L' AND k = 'E' : EQUB 129 EOR 35 : ENDIF
  IF t = 'X' AND k = 'E' : EQUB 130 EOR 35 : ENDIF
  IF t = 'G' AND k = 'E' : EQUB 131 EOR 35 : ENDIF
  IF t = 'Z' AND k = 'A' : EQUB 132 EOR 35 : ENDIF
  IF t = 'C' AND k = 'E' : EQUB 133 EOR 35 : ENDIF
  IF t = 'B' AND k = 'I' : EQUB 134 EOR 35 : ENDIF
  IF t = 'S' AND k = 'O' : EQUB 135 EOR 35 : ENDIF
  IF t = 'U' AND k = 'S' : EQUB 136 EOR 35 : ENDIF
  IF t = 'E' AND k = 'S' : EQUB 137 EOR 35 : ENDIF
  IF t = 'A' AND k = 'R' : EQUB 138 EOR 35 : ENDIF
  IF t = 'M' AND k = 'A' : EQUB 139 EOR 35 : ENDIF
  IF t = 'I' AND k = 'N' : EQUB 140 EOR 35 : ENDIF
  IF t = 'D' AND k = 'I' : EQUB 141 EOR 35 : ENDIF
  IF t = 'R' AND k = 'E' : EQUB 142 EOR 35 : ENDIF
  IF t = 'A' AND k = '?' : EQUB 143 EOR 35 : ENDIF
  IF t = 'E' AND k = 'R' : EQUB 144 EOR 35 : ENDIF
  IF t = 'A' AND k = 'T' : EQUB 145 EOR 35 : ENDIF
  IF t = 'E' AND k = 'N' : EQUB 146 EOR 35 : ENDIF
  IF t = 'B' AND k = 'E' : EQUB 147 EOR 35 : ENDIF
  IF t = 'R' AND k = 'A' : EQUB 148 EOR 35 : ENDIF
  IF t = 'L' AND k = 'A' : EQUB 149 EOR 35 : ENDIF
  IF t = 'V' AND k = 'E' : EQUB 150 EOR 35 : ENDIF
  IF t = 'T' AND k = 'I' : EQUB 151 EOR 35 : ENDIF
  IF t = 'E' AND k = 'D' : EQUB 152 EOR 35 : ENDIF
  IF t = 'O' AND k = 'R' : EQUB 153 EOR 35 : ENDIF
  IF t = 'Q' AND k = 'U' : EQUB 154 EOR 35 : ENDIF
  IF t = 'A' AND k = 'N' : EQUB 155 EOR 35 : ENDIF
  IF t = 'T' AND k = 'E' : EQUB 156 EOR 35 : ENDIF
  IF t = 'I' AND k = 'S' : EQUB 157 EOR 35 : ENDIF
  IF t = 'R' AND k = 'I' : EQUB 158 EOR 35 : ENDIF
  IF t = 'O' AND k = 'N' : EQUB 159 EOR 35 : ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: CONT
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for control codes in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CONT n              Insert control code token {n}
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   n                   The control code to insert into the table
\
\ ******************************************************************************

MACRO CONT n

  EQUB n EOR 35

ENDMACRO

\ ******************************************************************************
\
\       Name: RTOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for recursive tokens in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   RTOK n              Insert recursive token [n]
\
\                         * Tokens 0-95 get stored as n + 160
\
\                         * Tokens 128-145 get stored as n - 114
\
\                         * Tokens 96-127 get stored as n
\
\ See the deep dive on "Printing text tokens" for details on how recursive
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 0 to 145
\
\ ******************************************************************************

MACRO RTOK n

  IF n >= 0 AND n <= 95
    t = n + 160
  ELIF n >= 128
    t = n - 114
  ELSE
    t = n
  ENDIF

  EQUB t EOR 35

ENDMACRO

\ ******************************************************************************
\
\       Name: QQ18
\       Type: Variable
\   Category: Text
\    Summary: The recursive token table for tokens 0-148
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   new_name            AJD
\
\ ******************************************************************************

.QQ18

 RTOK 111               \ Token 0:      "FUEL SCOOPS ON {beep}"
 RTOK 131               \
 CONT 7                 \ Encoded as:   "[111][131]{7}"
 EQUB 0

 CHAR ' '               \ Token 1:      " CHART"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   " CH<138>T"
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               \ Token 2:      "GOVERNMENT"
 CHAR 'O'               \
 TWOK 'V', 'E'          \ Encoded as:   "GO<150>RNM<146>T"
 CHAR 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 3:      "DATA ON {selected system name}"
 TWOK 'A', 'T'          \
 CHAR 'A'               \ Encoded as:   "D<145>A[131]{3}"
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      "INVENTORY{cr}
 TWOK 'V', 'E'          \               "
 CHAR 'N'               \
 CHAR 'T'               \ Encoded as:   "<140><150>NT<153>Y{12}"
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 12
 EQUB 0

 CHAR 'S'               \ Token 5:      "SYSTEM"
 CHAR 'Y'               \
 CHAR 'S'               \ Encoded as:   "SYS<156>M"
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               \ Token 6:      "PRICE"
 TWOK 'R', 'I'          \
 TWOK 'C', 'E'          \ Encoded as:   "P<158><133>"
 EQUB 0

 CONT 2                 \ Token 7:      "{current system name} MARKET PRICES"
 CHAR ' '               \
 TWOK 'M', 'A'          \ Encoded as:   "{2} <139>RKET [6]S"
 CHAR 'R'
 CHAR 'K'
 CHAR 'E'
 CHAR 'T'
 CHAR ' '
 RTOK 6
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      "INDUSTRIAL"
 CHAR 'D'               \
 TWOK 'U', 'S'          \ Encoded as:   "<140>D<136>T<158><128>"
 CHAR 'T'
 TWOK 'R', 'I'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'A'               \ Token 9:      "AGRICULTURAL"
 CHAR 'G'               \
 TWOK 'R', 'I'          \ Encoded as:   "AG<158>CULTU<148>L"
 CHAR 'C'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'A'
 CHAR 'L'
 EQUB 0

 TWOK 'R', 'I'          \ Token 10:     "RICH "
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<158>CH "
 CHAR ' '
 EQUB 0

 CHAR 'A'               \ Token 11:     "AVERAGE "
 TWOK 'V', 'E'          \
 TWOK 'R', 'A'          \ Encoded as:   "A<150><148><131> "
 TWOK 'G', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 12:     "POOR "
 CHAR 'O'               \
 TWOK 'O', 'R'          \ Encoded as:   "PO<153> "
 CHAR ' '
 EQUB 0

 TWOK 'M', 'A'          \ Token 13:     "MAINLY "
 TWOK 'I', 'N'          \
 CHAR 'L'               \ Encoded as:   "<139><140>LY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               \ Token 14:     "UNIT"
 CHAR 'N'               \
 CHAR 'I'               \ Encoded as:   "UNIT"
 CHAR 'T'
 EQUB 0

 CHAR 'V'               \ Token 15:     "VIEW "
 CHAR 'I'               \
 CHAR 'E'               \ Encoded as:   "VIEW "
 CHAR 'W'
 CHAR ' '
 EQUB 0

 TWOK 'Q', 'U'          \ Token 16:     "QUANTITY"
 TWOK 'A', 'N'          \
 TWOK 'T', 'I'          \ Encoded as:   "<154><155><151>TY"
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 TWOK 'A', 'N'          \ Token 17:     "ANARCHY"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "<155><138>CHY"
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 18:     "FEUDAL"
 CHAR 'E'               \
 CHAR 'U'               \ Encoded as:   "FEUD<128>"
 CHAR 'D'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'M'               \ Token 19:     "MULTI-GOVERNMENT"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "MUL<151>-[2]"
 TWOK 'T', 'I'
 CHAR '-'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          \ Token 20:     "DICTATORSHIP"
 CHAR 'C'               \
 CHAR 'T'               \ Encoded as:   "<141>CT<145><153>[25]"
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                \ Token 21:     "COMMUNIST"
 CHAR 'M'               \
 CHAR 'U'               \ Encoded as:   "[91]MUN<157>T"
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               \ Token 22:     "CONFEDERACY"
 TWOK 'O', 'N'          \
 CHAR 'F'               \ Encoded as:   "C<159>F<152><144>ACY"
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               \ Token 23:     "DEMOCRACY"
 CHAR 'E'               \
 CHAR 'M'               \ Encoded as:   "DEMOC<148>CY"
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               \ Token 24:     "CORPORATE STATE"
 TWOK 'O', 'R'          \
 CHAR 'P'               \ Encoded as:   "C<153>P<153><145>E [43]<145>E"
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 25:     "SHIP"
 CHAR 'H'               \
 CHAR 'I'               \ Encoded as:   "SHIP"
 CHAR 'P'
 EQUB 0

 CHAR 'P'               \ Token 26:     "PRODUCT"
 RTOK 94                \
 CHAR 'D'               \ Encoded as:   "P[94]]DUCT"
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 27:     " LASER"
 TWOK 'L', 'A'          \
 CHAR 'S'               \ Encoded as:   " <149>S<144>"
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               \ Token 28:     "HUMAN COLONIAL"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155> COL<159>I<128>"
 TWOK 'A', 'N'
 CHAR ' '
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 CHAR 'I'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'H'               \ Token 29:     "HYPERSPACE "
 CHAR 'Y'               \
 CHAR 'P'               \ Encoded as:   "HYP<144>[128] "
 TWOK 'E', 'R'
 RTOK 128
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 30:     "SHORT RANGE CHART"
 CHAR 'H'               \
 TWOK 'O', 'R'          \ Encoded as:   "SH<153>T [42][1]"
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          \ Token 31:     "DISTANCE"
 RTOK 43                \
 TWOK 'A', 'N'          \ Encoded as:   "<141>[43]<155><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               \ Token 32:     "POPULATION"
 CHAR 'O'               \
 CHAR 'P'               \ Encoded as:   "POPUL<145>I<159>"
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'G'               \ Token 33:     "GROSS PRODUCTIVITY"
 RTOK 94                \
 CHAR 'S'               \ Encoded as:   "G[94]SS [26]IVITY"
 CHAR 'S'
 CHAR ' '
 RTOK 26
 CHAR 'I'
 CHAR 'V'
 CHAR 'I'
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 CHAR 'E'               \ Token 34:     "ECONOMY"
 CHAR 'C'               \
 TWOK 'O', 'N'          \ Encoded as:   "EC<159>OMY"
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               \ Token 35:     " LIGHT YEARS"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   " LIGHT YE<138>S"
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 CHAR ' '
 CHAR 'Y'
 CHAR 'E'
 TWOK 'A', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'T', 'E'          \ Token 36:     "TECH.LEVEL"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<156>CH.<129><150>L"
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               \ Token 37:     "CASH"
 CHAR 'A'               \
 CHAR 'S'               \ Encoded as:   "CASH"
 CHAR 'H'
 EQUB 0

 CHAR ' '               \ Token 38:     " BILLION"
 TWOK 'B', 'I'          \
 RTOK 129               \ Encoded as:   " <134>[129]I<159>"
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               \ Token 39:     "GALACTIC CHART{galaxy number}"
 RTOK 1                 \
 CONT 1                 \ Encoded as:   "[122][1]{1}"
 EQUB 0

 CHAR 'T'               \ Token 40:     "TARGET LOST"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "T<138><131>T LO[43]"
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               \ Token 41:     "MISSILE JAMMED"
 CHAR ' '               \
 CHAR 'J'               \ Encoded as:   "[106] JAMM<152>"
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 42:     "RANGE"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "R<155><131>"
 EQUB 0

 CHAR 'S'               \ Token 43:     "ST"
 CHAR 'T'               \
 EQUB 0                 \ Encoded as:   "ST"

 RTOK 16                \ Token 44:     "QUANTITY OF "
 CHAR ' '               \
 CHAR 'O'               \ Encoded as:   "[16] OF "
 CHAR 'F'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 45:     "SELL"
 CHAR 'E'               \
 RTOK 129               \ Encoded as:   "SE[129]"
 EQUB 0

 CHAR ' '               \ Token 46:     " CARGO{sentence case}"
 CHAR 'C'               \
 TWOK 'A', 'R'          \ Encoded as:   " C<138>GO{6}"
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               \ Token 47:     "EQUIP"
 TWOK 'Q', 'U'          \
 CHAR 'I'               \ Encoded as:   "E<154>IP"
 CHAR 'P'
 EQUB 0

 CHAR 'F'               \ Token 48:     "FOOD"
 CHAR 'O'               \
 CHAR 'O'               \ Encoded as:   "FOOD"
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     "TEXTILES"
 CHAR 'X'               \
 TWOK 'T', 'I'          \ Encoded as:   "<156>X<151>L<137>"
 CHAR 'L'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     "RADIOACTIVES"
 TWOK 'D', 'I'          \
 CHAR 'O'               \ Encoded as:   "<148><141>OAC<151><150>S"
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'S'               \ Token 51:     "SLAVES"
 TWOK 'L', 'A'          \
 TWOK 'V', 'E'          \ Encoded as:   "S<149><150>S"
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 52:     "LIQUOR/WINES"
 CHAR 'I'               \
 TWOK 'Q', 'U'          \ Encoded as:   "LI<154><153>/W<140><137>"
 TWOK 'O', 'R'
 CHAR '/'
 CHAR 'W'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'L'               \ Token 53:     "LUXURIES"
 CHAR 'U'               \
 CHAR 'X'               \ Encoded as:   "LUXU<158><137>"
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'N'               \ Token 54:     "NARCOTICS"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "N<138>CO<151>CS"
 CHAR 'O'
 TWOK 'T', 'I'
 CHAR 'C'
 CHAR 'S'
 EQUB 0

 RTOK 91                \ Token 55:     "COMPUTERS"
 CHAR 'P'               \
 CHAR 'U'               \ Encoded as:   "[91]PUT<144>S"
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     "MACHINERY"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<139>CH<140><144>Y"
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

 CHAR 'A'               \ Token 57:     "ALLOYS"
 RTOK 129               \
 CHAR 'O'               \ Encoded as:   "A[129]OYS"
 CHAR 'Y'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 58:     "FIREARMS"
 CHAR 'I'               \
 TWOK 'R', 'E'          \ Encoded as:   "FI<142><138>MS"
 TWOK 'A', 'R'
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 59:     "FURS"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURS"
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 60:     "MINERALS"
 TWOK 'I', 'N'          \
 TWOK 'E', 'R'          \ Encoded as:   "M<140><144><128>S"
 TWOK 'A', 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               \ Token 61:     "GOLD"
 CHAR 'O'               \
 CHAR 'L'               \ Encoded as:   "GOLD"
 CHAR 'D'
 EQUB 0

 CHAR 'P'               \ Token 62:     "PLATINUM"
 CHAR 'L'               \
 TWOK 'A', 'T'          \ Encoded as:   "PL<145><140>UM"
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          \ Token 63:     "GEM-STONES"
 CHAR 'M'               \
 CHAR '-'               \ Encoded as:   "<131>M-[43]<159><137>"
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'L'          \ Token 64:     "ALIEN ITEMS"
 CHAR 'I'               \
 TWOK 'E', 'N'          \ Encoded as:   "<128>I<146> [127]S"
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 CONT 12                \ Token 65:     "{cr}
 CHAR '1'               \                10{cash} CR5{cash} CR"
 CHAR '0'               \
 CONT 0                 \ Encoded as:   "{12}10{0}5{0}"
 CHAR '5'
 CONT 0
 EQUB 0

 CHAR ' '               \ Token 66:     " CR"
 CHAR 'C'               \
 CHAR 'R'               \ Encoded as:   " CR"
 EQUB 0

 CHAR 'L'               \ Token 67:     "LARGE"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "L<138><131>"
 EQUB 0

 CHAR 'F'               \ Token 68:     "FIERCE"
 CHAR 'I'               \
 TWOK 'E', 'R'          \ Encoded as:   "FI<144><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'S'               \ Token 69:     "SMALL"
 TWOK 'M', 'A'          \
 RTOK 129               \ Encoded as:   "S<139>[129]"
 EQUB 0

 CHAR 'G'               \ Token 70:     "GREEN"
 TWOK 'R', 'E'          \
 TWOK 'E', 'N'          \ Encoded as:   "G<142><146>"
 EQUB 0

 CHAR 'R'               \ Token 71:     "RED"
 TWOK 'E', 'D'          \
 EQUB 0                 \ Encoded as:   "R<152>"

 CHAR 'Y'               \ Token 72:     "YELLOW"
 CHAR 'E'               \
 RTOK 129               \ Encoded as:   "YE[129]OW"
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               \ Token 73:     "BLUE"
 CHAR 'L'               \
 CHAR 'U'               \ Encoded as:   "BLUE"
 CHAR 'E'
 EQUB 0

 CHAR 'B'               \ Token 74:     "BLACK"
 TWOK 'L', 'A'          \
 CHAR 'C'               \ Encoded as:   "B<149>CK"
 CHAR 'K'
 EQUB 0

 RTOK 136               \ Token 75:     "HARMLESS"
 EQUB 0                 \
                        \ Encoded as:   "[136]"

 CHAR 'S'               \ Token 76:     "SLIMY"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   "SLIMY"
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               \ Token 77:     "BUG-EYED"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "BUG-EY<152>"
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               \ Token 78:     "HORNED"
 TWOK 'O', 'R'          \
 CHAR 'N'               \ Encoded as:   "H<153>N<152>"
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               \ Token 79:     "BONY"
 TWOK 'O', 'N'          \
 CHAR 'Y'               \ Encoded as:   "B<159>Y"
 EQUB 0

 CHAR 'F'               \ Token 80:     "FAT"
 TWOK 'A', 'T'          \
 EQUB 0                 \ Encoded as:   "F<145>"

 CHAR 'F'               \ Token 81:     "FURRY"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURRY"
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 94                \ Token 82:     "RODENT"
 CHAR 'D'               \
 TWOK 'E', 'N'          \ Encoded as:   "[94]D<146>T"
 CHAR 'T'
 EQUB 0

 CHAR 'F'               \ Token 83:     "FROG"
 RTOK 94                \
 CHAR 'G'               \ Encoded as:   "F[94]G"
 EQUB 0

 CHAR 'L'               \ Token 84:     "LIZARD"
 CHAR 'I'               \
 TWOK 'Z', 'A'          \ Encoded as:   "LI<132>RD"
 CHAR 'R'
 CHAR 'D'
 EQUB 0

 CHAR 'L'               \ Token 85:     "LOBSTER"
 CHAR 'O'               \
 CHAR 'B'               \ Encoded as:   "LOB[43]<144>"
 RTOK 43
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'B', 'I'          \ Token 86:     "BIRD"
 CHAR 'R'               \
 CHAR 'D'               \ Encoded as:   "<134>RD"
 EQUB 0

 CHAR 'H'               \ Token 87:     "HUMANOID"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155>OID"
 TWOK 'A', 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 EQUB 0

 CHAR 'F'               \ Token 88:     "FELINE"
 CHAR 'E'               \
 CHAR 'L'               \ Encoded as:   "FEL<140>E"
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'I', 'N'          \ Token 89:     "INSECT"
 CHAR 'S'               \
 CHAR 'E'               \ Encoded as:   "<140>SECT"
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 RTOK 11                \ Token 90:     "AVERAGE RADIUS"
 TWOK 'R', 'A'          \
 TWOK 'D', 'I'          \ Encoded as:   "[11]<148><141><136>"
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               \ Token 91:     "COM"
 CHAR 'O'               \
 CHAR 'M'               \ Encoded as:   "COM"
 EQUB 0

 RTOK 91                \ Token 92:     "COMMANDER"
 CHAR 'M'               \
 TWOK 'A', 'N'          \ Encoded as:   "[91]M<155>D<144>"
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               \ Token 93:     " DESTROYED"
 CHAR 'D'               \
 TWOK 'E', 'S'          \ Encoded as:   " D<137>T[94]Y<152>"
 CHAR 'T'
 RTOK 94
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 94:     "RO"
 CHAR 'O'               \
 EQUB 0                 \ Encoded as:   "RO"

 RTOK 14                \ Token 95:     "UNIT  QUANTITY{cr}
 CHAR ' '               \                 PRODUCT   UNIT PRICE FOR SALE{cr}{lf}
 CHAR ' '               \               "
 RTOK 16                \
 CONT 12                \ Encoded as:   "[14]  [16]{13} [26]   [14] [6] F<153>
 CHAR ' '               \                 SA<129>{12}{10}"
 RTOK 26
 CHAR ' '
 CHAR ' '
 CHAR ' '
 RTOK 14
 CHAR ' '
 RTOK 6
 CHAR ' '
 CHAR 'F'
 TWOK 'O', 'R'
 CHAR ' '
 CHAR 'S'
 CHAR 'A'
 TWOK 'L', 'E'
 CONT 12
 CONT 10
 EQUB 0

 CHAR 'F'               \ Token 96:     "FRONT"
 CHAR 'R'               \
 TWOK 'O', 'N'          \ Encoded as:   "FR<159>T"
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          \ Token 97:     "REAR"
 TWOK 'A', 'R'          \
 EQUB 0                 \ Encoded as:   "<142><138>"

 TWOK 'L', 'E'          \ Token 98:     "LEFT"
 CHAR 'F'               \
 CHAR 'T'               \ Encoded as:   "<129>FT"
 EQUB 0

 TWOK 'R', 'I'          \ Token 99:     "RIGHT"
 CHAR 'G'               \
 CHAR 'H'               \ Encoded as:   "<158>GHT"
 CHAR 'T'
 EQUB 0

 RTOK 121               \ Token 100:    "ENERGY LOW{beep}"
 CHAR 'L'               \
 CHAR 'O'               \ Encoded as:   "[121]LOW{7}"
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                \ Token 101:    "RIGHT ON COMMANDER!"
 RTOK 131               \
 RTOK 92                \ Encoded as:   "[99][131][92]!"
 CHAR '!'
 EQUB 0

 CHAR 'E'               \ Token 102:    "EXTRA "
 CHAR 'X'               \
 CHAR 'T'               \ Encoded as:   "EXT<148> "
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 103:    "PULSE LASER"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "PULSE[27]"
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          \ Token 104:    "BEAM LASER"
 CHAR 'A'               \
 CHAR 'M'               \ Encoded as:   "<147>AM[27]"
 RTOK 27
 EQUB 0

 CHAR 'F'               \ Token 105:    "FUEL"
 CHAR 'U'               \
 CHAR 'E'               \ Encoded as:   "FUEL"
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 106:    "MISSILE"
 TWOK 'I', 'S'          \
 CHAR 'S'               \ Encoded as:   "M<157>SI<129>"
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 CHAR 'I'               \ Token 107:    "I.F.F.SYSTEM"
 CHAR '.'               \
 CHAR 'F'               \ Encoded as:   "I.F.F.[5]"
 CHAR '.'
 CHAR 'F'
 CHAR '.'
 RTOK 5
 EQUB 0

 CHAR 'E'               \ Token 108:    "E.C.M.SYSTEM"
 CHAR '.'               \
 CHAR 'C'               \ Encoded as:   "E.C.M.[5]"
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               \ Token 109:    "EXTRA PULSE LASERS"
 RTOK 103               \
 CHAR 'S'               \ Encoded as:   "[102][103]S"
 EQUB 0

 RTOK 102               \ Token 110:    "EXTRA BEAM LASERS"
 RTOK 104               \
 CHAR 'S'               \ Encoded as:   "[102][104]S"
 EQUB 0

 RTOK 105               \ Token 111:    "FUEL SCOOPS"
 CHAR ' '               \
 CHAR 'S'               \ Encoded as:   "[105] SCOOPS"
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          \ Token 112:    "ESCAPE POD"
 CHAR 'C'               \
 CHAR 'A'               \ Encoded as:   "<137>CAPE POD"
 CHAR 'P'
 CHAR 'E'
 CHAR ' '
 CHAR 'P'
 CHAR 'O'
 CHAR 'D'
 EQUB 0

 RTOK 29                \ Token 113:    "HYPERSPACE UNIT"
 RTOK 14                \
 EQUB 0                 \ Encoded as:   "[29][14]"

 RTOK 121               \ Token 114:    "ENERGY UNIT"
 RTOK 14                \
 EQUB 0                 \ Encoded as:   "[121][14]"

 CHAR 'D'               \ Token 115:    "DOCKING COMPUTERS"
 CHAR 'O'               \
 CHAR 'C'               \ Encoded as:   "DOCK<140>G [55]"
 CHAR 'K'
 TWOK 'I', 'N'
 CHAR 'G'
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               \ Token 116:    "GALACTIC HYPERSPACE "
 CHAR ' '               \
 RTOK 29                \ Encoded as:   "[122] [29]"
 EQUB 0

 CHAR 'M'               \ Token 117:    "MILITARY LASER"
 CHAR 'I'               \
 CHAR 'L'               \ Encoded as:   "MILIT<138>Y[27]"
 CHAR 'I'
 CHAR 'T'
 TWOK 'A', 'R'
 CHAR 'Y'
 RTOK 27
 EQUB 0

 CHAR 'M'               \ Token 118:    "MINING LASER"
 TWOK 'I', 'N'          \
 TWOK 'I', 'N'          \ Encoded as:   "M<140><140>G[27]"
 CHAR 'G'
 RTOK 27
 EQUB 0

 RTOK 37                \ Token 119:    "CASH:{cash} CR{cr}
 CHAR ':'               \               "
 CONT 0                 \
 EQUB 0                 \ Encoded as:   "[37]:{0}"

 TWOK 'I', 'N'          \ Token 120:    "INCOMING MISSILE"
 RTOK 91                \
 TWOK 'I', 'N'          \ Encoded as:   "<140>[91]<140>G [106]"
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          \ Token 121:    "ENERGY "
 TWOK 'E', 'R'          \
 CHAR 'G'               \ Encoded as:   "<146><144>GY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    "GALACTIC"
 CHAR 'A'               \
 TWOK 'L', 'A'          \ Encoded as:   "GA<149>C<151>C"
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

 RTOK 115               \ Token 123:    "DOCKING COMPUTERS ON"
 CHAR ' '               \
 TWOK 'O', 'N'          \ Encoded as:   "[115] <159>"
 EQUB 0

 CHAR 'A'               \ Token 124:    "ALL"
 RTOK 129               \
 EQUB 0                 \ Encoded as:   "A[129]"

 CONT 5                 \ Token 125:    "FUEL: {fuel level} LIGHT YEARS{cr}
 TWOK 'L', 'E'          \                CASH:{cash} CR{cr}
 CHAR 'G'               \                LEGAL STATUS:"
 TWOK 'A', 'L'          \
 CHAR ' '               \ Encoded as:   "{5}<129>G<128> [43]<145><136>:"
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    "COMMANDER {commander name}{cr}
 CHAR ' '               \                {cr}
 CONT 4                 \                {cr}
 CONT 12                \                {sentence case}PRESENT SYSTEM{tab to
 CONT 12                \                column 21}:{current system name}{cr}
 CONT 12                \                HYPERSPACE SYSTEM{tab to column 21}:
 CONT 6                 \                {selected system name}{cr}
 RTOK 145               \                CONDITION{tab to column 21}:"
 CHAR ' '               \
 RTOK 5                 \ Encoded as:   "[92] {4}{12}{12}{12}{6}[145] [5]{9}{2}
 CONT 9                 \                {12}[29][5]{9}{3}{13}C<159><141><151>
 CONT 2                 \                <159>{9}"
 CONT 12
 RTOK 29
 RTOK 5
 CONT 9
 CONT 3
 CONT 12
 CHAR 'C'
 TWOK 'O', 'N'
 TWOK 'D', 'I'
 TWOK 'T', 'I'
 TWOK 'O', 'N'
 CONT 9
 EQUB 0

 CHAR 'I'               \ Token 127:    "ITEM"
 TWOK 'T', 'E'          \
 CHAR 'M'               \ Encoded as:   "I<156>M"
 EQUB 0

 CHAR 'S'               \ Token 128:    "SPACE"
 CHAR 'P'               \
 CHAR 'A'               \ Encoded as:   "SPA<133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'L'               \ Token 129:    "LL"
 CHAR 'L'               \
 EQUB 0                 \ Encoded as:   "LL"

 TWOK 'R', 'A'          \ Token 130:    "RATING:"
 TWOK 'T', 'I'          \
 CHAR 'N'               \ Encoded as:   "<148><151>NG:"
 CHAR 'G'
 CHAR ':'
 EQUB 0

 CHAR ' '               \ Token 131:    " ON "
 TWOK 'O', 'N'          \
 CHAR ' '               \ Encoded as:   " <159> "
 EQUB 0

 CONT 12                \ Token 132:    "{cr}
 RTOK 25                \                SHIP:          "
 CHAR ':'               \
 CHAR ' '               \ Encoded as:   "{12}[25]:          "

.new_name

 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 CHAR ' '
 EQUB 0

 CHAR 'C'               \ Token 133:    "CLEAN"
 TWOK 'L', 'E'          \
 TWOK 'A', 'N'          \ Encoded as:   "C<129><155>"
 EQUB 0

 CHAR 'O'               \ Token 134:    "OFFENDER"
 CHAR 'F'               \
 CHAR 'F'               \ Encoded as:   "OFF<146>D<144>"
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               \ Token 135:    "FUGITIVE"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "FUGI<151><150>"
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               \ Token 136:    "HARMLESS"
 TWOK 'A', 'R'          \
 CHAR 'M'               \ Encoded as:   "H<138>M<129>SS"
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 137:    "MOSTLY HARMLESS"
 CHAR 'O'               \
 RTOK 43                \ Encoded as:   "MO[43]LY [136]"
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 RTOK 12                \ Token 138:    "POOR "
 EQUB 0                 \
                        \ Encoded as:   "[12]"

 RTOK 11                \ Token 139:    "AVERAGE "
 EQUB 0                 \
                        \ Encoded as:   "[11]"

 CHAR 'A'               \ Token 140:    "ABOVE AVERAGE "
 CHAR 'B'               \
 CHAR 'O'               \ Encoded as:   "ABO<150> [11]"
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 11
 EQUB 0

 RTOK 91                \ Token 141:    "COMPETENT"
 CHAR 'P'               \
 CHAR 'E'               \ Encoded as:   "[91]PET<146>T"
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 142:    "DANGEROUS"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "D<155><131>[94]<136>"
 RTOK 94
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               \ Token 143:    "DEADLY"
 CHAR 'E'               \
 CHAR 'A'               \ Encoded as:   "DEADLY"
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               \ Token 144:    "---- E L I T E ----"
 CHAR '-'               \
 CHAR '-'               \ Encoded as:   "---- E L I T E ----"
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 CHAR 'P'               \ Token 145:    "PRESENT"
 TWOK 'R', 'E'          \
 CHAR 'S'               \ Encoded as:   "P<142>S<146>T"
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 \ Token 146:    "{all caps}GAME OVER"
 CHAR 'G'               \
 CHAR 'A'               \ Encoded as:   "{8}GAME O<150>R"
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 TWOK 'V', 'E'
 CHAR 'R'
 EQUB 0

 SKIP 5                 \ These bytes appear to be unused

.SNE

 EQUB &00, &19, &32, &4A, &62, &79, &8E, &A2, &B5, &C6, &D5, &E2
 EQUB &ED, &F5, &FB, &FF, &FF, &FF, &FB, &F5, &ED, &E2, &D5, &C6
 EQUB &B5, &A2, &8E, &79, &62, &4A, &32, &19

.ACT

 EQUB &00, &01, &03, &04, &05, &06, &08, &09, &0A, &0B, &0C, &0D
 EQUB &0F, &10, &11, &12, &13, &14, &15, &16, &17, &18, &19, &19
 EQUB &1A, &1B, &1C, &1D, &1D, &1E, &1F, &1F

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