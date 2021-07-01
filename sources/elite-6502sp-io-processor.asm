\ ******************************************************************************
\
\ ELITE-A GAME SOURCE (I/O PROCESSOR)
\
\ Elite-A is an extended version of BBC Micro Elite by Angus Duggan
\
\ The original Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984, and the extra code in Elite-A is copyright Angus Duggan
\
\ The code on this site is identical to Angus Duggan's source discs (it's just
\ been reformatted, and the label names have been changed to be consistent with
\ the sources for the original BBC Micro disc version on which it is based)
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
\   * output/2.H.bin
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSCLI = &FFF7           \ The address for the OSCLI routine

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

X = 128                 \ The centre x-coordinate of the 256 x 192 space view
Y = 96                  \ The centre y-coordinate of the 256 x 192 space view

tube_brk = &0016        \ Tube BRK vector AJD

BRKV = &0202            \ The break vector that we intercept to enable us to
                        \ handle and display system errors

WRCHV = &020E           \ The WRCHV vector that we intercept with our custom
                        \ text printing routine

LASCT = &0346           \ The laser pulse count for the current laser, matching
                        \ the address in the main game code

HFX = &0348             \ A flag that toggles the hyperspace colour effect,
                        \ matching the address in the main game code

ESCP = &0386            \ The flag that determines whether we have an escape pod
                        \ fitted, matching the address in the main game code

tube_r1s = &FEE0        \ AJD
tube_r1d = &FEE1
tube_r2s = &FEE2
tube_r2d = &FEE3
tube_r3s = &FEE4
tube_r3d = &FEE5
tube_r4s = &FEE6
tube_r4d = &FEE7

rawrch = &FFBC          \ AJD

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &008B to &009F
\   Category: Workspaces
\    Summary: Important variables used by the I/O processor
\
\ ******************************************************************************

ORG &008B

.DL

 SKIP 1                 \ Vertical sync flag
                        \
                        \ DL gets set to 30 every time we reach vertical sync on
                        \ the video system, which happens 50 times a second
                        \ (50Hz). The WSCAN routine uses this to pause until the
                        \ vertical sync, by setting DL to 0 and then monitoring
                        \ its value until it changes to 30

ORG &0090

.key_tube

 SKIP 2                 \ AJD

.SC

 SKIP 1                 \ Screen address (low byte)
                        \
                        \ Elite draws on-screen by poking bytes directly into
                        \ screen memory, and SC(1 0) is typically set to the
                        \ address of the character block containing the pixel
                        \ we want to draw (see the deep dives on "Drawing
                        \ monochrome pixels in mode 4" and "Drawing colour
                        \ pixels in mode 5" for more details)

.SCH

 SKIP 1                 \ Screen address (high byte)

.font
.ZZ
.bar_1
.angle_1
.missle_1
.picture_1
.print_bits
.X1

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.bar_2
.picture_2
.Y1

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.bar_3
.save_a
.COL
.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.save_x
.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.save_y
.P

 SKIP 1                 \ Temporary storage, used in a number of places

.T
.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

 SKIP 1

.XC

 SKIP 1                 \ The x-coordinate of the text cursor (i.e. the text
                        \ column), which can be from 0 to 32
                        \
                        \ A value of 0 denotes the leftmost column and 32 the
                        \ rightmost column, but because the top part of the
                        \ screen (the space view) has a white border that
                        \ clashes with columns 0 and 32, text is only shown
                        \ in columns 1-31

.YC

 SKIP 1                 \ The y-coordinate of the text cursor (i.e. the text
                        \ row), which can be from 0 to 23
                        \
                        \ The screen actually has 31 character rows if you
                        \ include the dashboard, but the text printing routines
                        \ only work on the top part (the space view), so the
                        \ text cursor only goes up to a maximum of 23, the row
                        \ just before the screen splits
                        \
                        \ A value of 0 denotes the top row, but because the
                        \ top part of the screen has a white border that clashes
                        \ with row 0, text is always shown at row 1 or greater

\ ******************************************************************************
\
\ ELITE I/O PROCESSOR
\
\ ******************************************************************************

CODE% = &1200
LOAD% = &1200

ORG CODE%

\ ******************************************************************************
\
\       Name: tube_elite
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_elite

 LDX #&FF
 TXS
 LDA #LO(tube_wrch)
 STA WRCHV
 LDA #HI(tube_wrch)
 STA WRCHV+&01
 LDA #LO(tube_brk)
 STA BRKV
 LDA #HI(tube_brk)
 STA BRKV+&01
 LDX #LO(tube_run)
 LDY #HI(tube_run)
 JMP OSCLI

\ ******************************************************************************
\
\       Name: tube_run
\       Type: Variable
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_run

 EQUS "R.2.T", &0D

\ ******************************************************************************
\
\       Name: tube_get
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_get

 BIT tube_r1s
 NOP
 BPL tube_get
 LDA tube_r1d
 RTS

\ ******************************************************************************
\
\       Name: tube_put
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_put

 BIT tube_r2s
 NOP
 BVC tube_put
 STA tube_r2d
 RTS

\ ******************************************************************************
\
\       Name: tube_func
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_func

 CMP #&9D  \ OUT
 BCS return  \ OUT
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

\ ******************************************************************************
\
\       Name: tube_table
\       Type: Variable
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.tube_table

 EQUW LL30, HLOIN, PIXEL, clr_scrn
 EQUW CLYNS, sync_in, DILX, DIL2
 EQUW MSBAR, scan_fire, write_fe4e, scan_xin
 EQUW scan_10in, get_key, CHPR, write_pod
 EQUW draw_blob, draw_tail, SPBLB, ECBLB
 EQUW UNWISE, DET1, scan_y, write_0346
 EQUW read_0346, return, HANGER, HA2

\ ******************************************************************************
\
\       Name: CHPR
\       Type: Subroutine
\   Category: Text
\    Summary: AJD
\
\ ******************************************************************************

.CHPR

 JSR tube_get
 STA XC
 JSR tube_get
 STA YC
 JSR tube_get
 CMP #&20
 BNE tube_wrch
 LDA #&09

.tube_wrch

 STA save_a             \ Like CHPR
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

 INC XC

.wrch_quit

 LDY save_y
 LDX save_x
 LDA save_a
 RTS

.wrch_char

 JSR wrch_font
 INC XC
 LDY #&07

.wrch_or

 LDA (font),Y
 EOR (SC),Y \ORA (SC),Y
 STA (SC),Y
 DEY
 BPL wrch_or
 BMI wrch_quit

.wrch_del

 DEC XC
 LDA #&20
 JSR wrch_font
 LDY #&07

.wrch_sta

 LDA (font),Y
 STA (SC),Y
 DEY
 BPL wrch_sta
 BMI wrch_quit

.wrch_nl

 INC YC
 JMP wrch_quit

.wrch_cr

 LDA #&01
 STA XC
 JMP wrch_quit

.wrch_spc

 LDA XC
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
 LDA XC
 ASL A
 ASL A
 ASL A
 STA SC
 LDA YC
 ORA #&60
 STA SC+&01
 RTS

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 4
\  Deep dive: Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 4 (the top part of the
\ split screen). See the PIXEL routine for details.
\
\ ******************************************************************************

.TWOS

 EQUB %10000000
 EQUB %01000000
 EQUB %00100000
 EQUB %00010000
 EQUB %00001000
 EQUB %00000100
 EQUB %00000010
 EQUB %00000001

\ ******************************************************************************
\
\       Name: TWOS2
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made double-pixel character row bytes for mode 4
\  Deep dive: Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting two-pixel dashes in mode 4 (the top part of the
\ split screen). See the PIXEL routine for details.
\
\ ******************************************************************************

.TWOS2

 EQUB %11000000
 EQUB %01100000
 EQUB %00110000
 EQUB %00011000
 EQUB %00001100
 EQUB %00000110
 EQUB %00000011
 EQUB %00000011

\ ******************************************************************************
\
\       Name: CTWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 5
\  Deep dive: Drawing colour pixels in mode 5
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 5 (the bottom part of
\ the split screen). See the dashboard routines SCAN, DIL2 and CPIX2 for
\ details.
\
\ There is one extra row to support the use of CTWOS+1,X indexing in the CPIX2
\ routine. The extra row is a repeat of the first row, and saves us from having
\ to work out whether CTWOS+1+X needs to be wrapped around when drawing a
\ two-pixel dash that crosses from one character block into another. See CPIX2
\ for more details.
\
\ ******************************************************************************

.CTWOS

 EQUB %10001000
 EQUB %01000100
 EQUB %00100010
 EQUB %00010001
 EQUB %10001000

\ ******************************************************************************
\
\       Name: LOIN (Part 1 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Calculate the line gradient in the form of deltas
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ This stage calculates the line deltas.
\
\ Arguments:
\
\   X1                  The screen x-coordinate of the start of the line
\
\   Y1                  The screen y-coordinate of the start of the line
\
\   X2                  The screen x-coordinate of the end of the line
\
\   Y2                  The screen y-coordinate of the end of the line
\
\ Returns:
\
\   Y                   Y is preserved
\
\ Other entry points:
\
\   LL30                LL30 is a synonym for LOIN and draws a line from
\                       (X1, Y1) to (X2, Y2)
\
\   HL6                 Contains an RTS
\
\ ******************************************************************************

.LL30

 SKIP 0                 \ LL30 is a synomym for LOIN
                        \
                        \ In the cassette and disc versions of Elite, LL30 and
                        \ LOIN are synonyms for the same routine, presumably
                        \ because the two developers each had their own line
                        \ routines to start with, and then chose one of them for
                        \ the final game

 JSR tube_get           \ AJD
 STA X1
 JSR tube_get
 STA Y1
 JSR tube_get
 STA X2
 JSR tube_get
 STA Y2

.LOIN

 LDA #128               \ Set S = 128, which is the starting point for the
 STA S                  \ slope error (representing half a pixel)

 ASL A                  \ Set SWAP = 0, as %10000000 << 1 = 0
 STA SWAP

 LDA X2                 \ Set A = X2 - X1
 SBC X1                 \       = delta_x
                        \
                        \ This subtraction works as the ASL A above sets the C
                        \ flag

 BCS LI1                \ If X2 > X1 then A is already positive and we can skip
                        \ the next three instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

 SEC                    \ Set the C flag, ready for the subtraction below

.LI1

 STA P                  \ Store A in P, so P = |X2 - X1|, or |delta_x|

 LDA Y2                 \ Set A = Y2 - Y1
 SBC Y1                 \       = delta_y
                        \
                        \ This subtraction works as we either set the C flag
                        \ above, or we skipped that SEC instruction with a BCS

 BCS LI2                \ If Y2 > Y1 then A is already positive and we can skip
                        \ the next two instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

.LI2

 STA Q                  \ Store A in Q, so Q = |Y2 - Y1|, or |delta_y|

 CMP P                  \ If Q < P, jump to STPX to step along the x-axis, as
 BCC STPX               \ the line is closer to being horizontal than vertical

 JMP STPY               \ Otherwise Q >= P so jump to STPY to step along the
                        \ y-axis, as the line is closer to being vertical than
                        \ horizontal

\ ******************************************************************************
\
\       Name: LOIN (Part 2 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a shallow gradient, step right along x-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| < |delta_x|
\
\   * The line is closer to being horizontal than vertical
\
\   * We are going to step right along the x-axis
\
\   * We potentially swap coordinates to make sure X1 < X2
\
\ ******************************************************************************

.STPX

 LDX X1                 \ Set X = X1

 CPX X2                 \ If X1 < X2, jump down to LI3, as the coordinates are
 BCC LI3                \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

                        \ By this point we know the line is horizontal-ish and
                        \ X1 < X2, so we're going from left to right as we go
                        \ from X1 to X2

 LDA Y1                 \ Set A = Y1 / 8, so A now contains the character row
 LSR A                  \ that will contain our horizontal line
 LSR A
 LSR A

 ORA #&60               \ As A < 32, this effectively adds &60 to A, which gives
                        \ us the screen address of the character row (as each
                        \ character row takes up 256 bytes, and the first
                        \ character row is at screen address &6000, or page &60)

 STA SCH                \ Store the page number of the character row in SCH, so
                        \ the high byte of SC is set correctly for drawing the
                        \ start of our line

 LDA Y1                 \ Set Y = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw the start of
 TAY                    \ our line (as each character block has 8 rows)

 TXA                    \ Set A = bits 3-7 of X1
 AND #%11111000

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw the
                        \ start of our line on

 TXA                    \ Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 8 pixels
                        \ wide)

 LDA TWOS,X             \ Fetch a 1-pixel byte from TWOS where pixel X is set,
 STA R                  \ and store it in R

                        \ The following calculates:
                        \
                        \   Q = Q / P
                        \     = |delta_y| / |delta_x|
                        \
                        \ using the same shift-and-subtract algorithm that's
                        \ documented in TIS2

 LDA Q                  \ Set A = |delta_y|

 LDX #%11111110         \ Set Q to have bits 1-7 set, so we can rotate through 7
 STX Q                  \ loop iterations, getting a 1 each time, and then
                        \ getting a 0 on the 8th iteration... and we can also
                        \ use Q to catch our result bits into bit 0 each time

.LIL1

 ASL A                  \ Shift A to the left

 BCS LI4                \ If bit 7 of A was set, then jump straight to the
                        \ subtraction

 CMP P                  \ If A < P, skip the following subtraction
 BCC LI5

.LI4

 SBC P                  \ A >= P, so set A = A - P

 SEC                    \ Set the C flag to rotate into the result in Q

.LI5

 ROL Q                  \ Rotate the counter in Q to the left, and catch the
                        \ result bit into bit 0 (which will be a 0 if we didn't
                        \ do the subtraction, or 1 if we did)

 BCS LIL1               \ If we still have set bits in Q, loop back to TIL2 to
                        \ do the next iteration of 7

                        \ We now have:
                        \
                        \   Q = A / P
                        \     = |delta_y| / |delta_x|
                        \
                        \ and the C flag is clear

 LDX P                  \ Set X = P + 1
 INX                    \       = |delta_x| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA Y2                 \ Set A = Y2 - Y1 - 1 (as the C flag is clear following
 SBC Y1                 \ the above division)

 BCS DOWN               \ If Y2 >= Y1 - 1 then jump to DOWN, as we need to draw
                        \ the line to the right and down

\ ******************************************************************************
\
\       Name: LOIN (Part 3 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and up or left and down
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and up (no swap) or left and down (swap)
\
\   * X1 < X2 and Y1-1 > Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
\
\ ******************************************************************************

 LDA SWAP               \ If SWAP > 0 then we swapped the coordinates above, so
 BNE LI6                \ jump down to LI6 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL2

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI6

 LSR R                  \ Shift the single pixel in R to the right to step along
                        \ the x-axis, so the next pixel we plot will be at the
                        \ next x-coordinate along

 BCC LI7                \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI7

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

.LI7

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LIC2               \ If the addition didn't overflow, jump to LIC2

 DEY                    \ Otherwise we just overflowed, so decrement Y to move
                        \ to the pixel line above

 BPL LIC2               \ If Y is positive we are still within the same
                        \ character block, so skip to LIC2

 DEC SCH                \ Otherwise we need to move up into the character block
 LDY #7                 \ above, so decrement the high byte of the screen
                        \ address and set the pixel line to the last line in
                        \ that character block

.LIC2

 DEX                    \ Decrement the counter in X

 BNE LIL2               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL2 to plot the next pixel along

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 4 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and down or left and up
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and down (no swap) or left and up (swap)
\
\   * X1 < X2 and Y1-1 <= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
\
\ ******************************************************************************

.DOWN

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI9                \ so jump down to LI9 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL3

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI9

 LSR R                  \ Shift the single pixel in R to the right to step along
                        \ the x-axis, so the next pixel we plot will be at the
                        \ next x-coordinate along

 BCC LI10               \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI10

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

.LI10

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LIC3               \ If the addition didn't overflow, jump to LIC3

 INY                    \ Otherwise we just overflowed, so increment Y to move
                        \ to the pixel line below

 CPY #8                 \ If Y < 8 we are still within the same character block,
 BNE LIC3               \ so skip to LIC3

 INC SCH                \ Otherwise we need to move down into the character
 LDY #0                 \ block below, so increment the high byte of the screen
                        \ address and set the pixel line to the first line in
                        \ that character block

.LIC3

 DEX                    \ Decrement the counter in X

 BNE LIL3               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL3 to plot the next pixel along

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 5 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a steep gradient, step up along y-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| >= |delta_x|
\
\   * The line is closer to being vertical than horizontal
\
\   * We are going to step up along the y-axis
\
\   * We potentially swap coordinates to make sure Y1 >= Y2
\
\ ******************************************************************************

.STPY

 LDY Y1                 \ Set A = Y = Y1
 TYA

 LDX X1                 \ Set X = X1

 CPY Y2                 \ If Y1 >= Y2, jump down to LI15, as the coordinates are
 BCS LI15               \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 STA Y1
 STY Y2

 TAY                    \ Set Y = A = Y1

.LI15

                        \ By this point we know the line is vertical-ish and
                        \ Y1 >= Y2, so we're going from top to bottom as we go
                        \ from Y1 to Y2

 LSR A                  \ Set A = Y1 / 8, so A now contains the character row
 LSR A                  \ that will contain our horizontal line
 LSR A

 ORA #&60               \ As A < 32, this effectively adds &60 to A, which gives
                        \ us the screen address of the character row (as each
                        \ character row takes up 256 bytes, and the first
                        \ character row is at screen address &6000, or page &60)

 STA SCH                \ Store the page number of the character row in SCH, so
                        \ the high byte of SC is set correctly for drawing the
                        \ start of our line

 TXA                    \ Set A = bits 3-7 of X1
 AND #%11111000

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw the
                        \ start of our line on

 TXA                    \ Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 8 pixels
                        \ wide)

 LDA TWOS,X             \ Fetch a 1-pixel byte from TWOS where pixel X is set,
 STA R                  \ and store it in R

 LDA Y1                 \ Set Y = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw the start of
 TAY                    \ our line (as each character block has 8 rows)

                        \ The following calculates:
                        \
                        \   P = P / Q
                        \     = |delta_x| / |delta_y|
                        \
                        \ using the same shift-and-subtract algorithm
                        \ documented in TIS2

 LDA P                  \ Set A = |delta_x|

 LDX #1                 \ Set Q to have bits 1-7 clear, so we can rotate through
 STX P                  \ 7 loop iterations, getting a 1 each time, and then
                        \ getting a 1 on the 8th iteration... and we can also
                        \ use P to catch our result bits into bit 0 each time

.LIL4

 ASL A                  \ Shift A to the left

 BCS LI13               \ If bit 7 of A was set, then jump straight to the
                        \ subtraction

 CMP Q                  \ If A < Q, skip the following subtraction
 BCC LI14

.LI13

 SBC Q                  \ A >= Q, so set A = A - Q

 SEC                    \ Set the C flag to rotate into the result in Q

.LI14

 ROL P                  \ Rotate the counter in P to the left, and catch the
                        \ result bit into bit 0 (which will be a 0 if we didn't
                        \ do the subtraction, or 1 if we did)

 BCC LIL4               \ If we still have set bits in P, loop back to TIL2 to
                        \ do the next iteration of 7

                        \ We now have:
                        \
                        \   P = A / Q
                        \     = |delta_x| / |delta_y|
                        \
                        \ and the C flag is set

 LDX Q                  \ Set X = Q + 1
 INX                    \       = |delta_y| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA X2                 \ Set A = X2 - X1 (the C flag is set as we didn't take
 SBC X1                 \ the above BCC)

 BCC LFT                \ If X2 < X1 then jump to LFT, as we need to draw the
                        \ line to the left and down

\ ******************************************************************************
\
\       Name: LOIN (Part 6 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and left or down and right
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and left (no swap) or down and right (swap)
\
\   * X1 < X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
\
\ ******************************************************************************

 CLC                    \ Clear the C flag

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI17               \ so jump down to LI17 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL5

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI17

 DEY                    \ Decrement Y to step up along the y-axis

 BPL LI16               \ If Y is positive we are still within the same
                        \ character block, so skip to LI16

 DEC SCH                \ Otherwise we need to move up into the character block
 LDY #7                 \ above, so decrement the high byte of the screen
                        \ address and set the pixel line to the last line in
                        \ that character block

.LI16

 LDA S                  \ Set S = S + Q to update the slope error
 ADC P
 STA S

 BCC LIC5               \ If the addition didn't overflow, jump to LIC5

 LSR R                  \ Otherwise we just overflowed, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LIC5               \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LIC5

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

.LIC5

 DEX                    \ Decrement the counter in X

 BNE LIL5               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL5 to plot the next pixel along

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 7 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and right or down and left
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and right (no swap) or down and left (swap)
\
\   * X1 >= X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
\
\ ******************************************************************************

.LFT

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI18               \ jump down to LI18 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL6

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI18

 DEY                    \ Decrement Y to step up along the y-axis

 BPL LI19               \ If Y is positive we are still within the same
                        \ character block, so skip to LI19

 DEC SCH                \ Otherwise we need to move up into the character block
 LDY #7                 \ above, so decrement the high byte of the screen
                        \ address and set the pixel line to the last line in
                        \ that character block

.LI19

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCC LIC6               \ If the addition didn't overflow, jump to LIC6

 ASL R                  \ Otherwise we just overflowed, so shift the single
                        \ pixel in R to the left, so the next pixel we plot
                        \ will be at the previous x-coordinate

 BCC LIC6               \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LIC6

 ROL R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R left so the set C flag goes
                        \ back into the right end, giving %0000001

 LDA SC                 \ Subtract 7 from SC, so SC(1 0) now points to the
 SBC #7                 \ previous character along to the left
 STA SC

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

.LIC6

 DEX                    \ Decrement the counter in X

 BNE LIL6               \ If we haven't yet reached the left end of the line,
                        \ loop back to LIL6 to plot the next pixel along

.HL6

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HLOIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line from (X1, Y1) to (X2, Y1)
\
\ ------------------------------------------------------------------------------
\
\ We do not draw a pixel at the end point (X2, X1).
\
\ To understand how this routine works, you might find it helpful to read the
\ deep dive on "Drawing monochrome pixels in mode 4".
\
\ Returns:
\
\   Y                   Y is preserved
\
\ ******************************************************************************

.HLOIN

 JSR tube_get           \ AJD
 STA X1
 JSR tube_get
 STA Y1
 JSR tube_get
 STA X2

 LDX X1                 \ Set X = X1

 CPX X2                 \ If X1 = X2 then the start and end points are the same,
 BEQ HL6                \ so return from the subroutine (as HL6 contains an RTS)

 BCC HL5                \ If X1 < X2, jump to HL5 to skip the following code, as
                        \ (X1, Y1) is already the left point

 LDA X2                 \ Swap the values of X1 and X2, so we know that (X1, Y1)
 STA X1                 \ is on the left and (X2, Y1) is on the right
 STX X2

 TAX                    \ Set X = X1

.HL5

 DEC X2                 \ Decrement X2 so we do not draw a pixel at the end
                        \ point

 LDA Y1                 \ Set A = Y1 / 8, so A now contains the character row
 LSR A                  \ that will contain our horizontal line
 LSR A
 LSR A

 ORA #&60               \ As A < 32, this effectively adds &60 to A, which gives
                        \ us the screen address of the character row (as each
                        \ character row takes up 256 bytes, and the first
                        \ character row is at screen address &6000, or page &60)

 STA SCH                \ Store the page number of the character row in SCH, so
                        \ the high byte of SC is set correctly for drawing our
                        \ line

 LDA Y1                 \ Set A = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw our line (as
                        \ each character block has 8 rows)

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw our
                        \ horizontal line on

 TXA                    \ Set Y = bits 3-7 of X1
 AND #%11111000
 TAY

.HL1

 TXA                    \ Set T = bits 3-7 of X1, which will contain the
 AND #%11111000         \ the character number of the start of the line * 8
 STA T

 LDA X2                 \ Set A = bits 3-7 of X2, which will contain the
 AND #%11111000         \ the character number of the end of the line * 8

 SEC                    \ Set A = A - T, which will contain the number of
 SBC T                  \ character blocks we need to fill - 1 * 8

 BEQ HL2                \ If A = 0 then the start and end character blocks are
                        \ the same, so the whole line fits within one block, so
                        \ jump down to HL2 to draw the line

                        \ Otherwise the line spans multiple characters, so we
                        \ start with the left character, then do any characters
                        \ in the middle, and finish with the right character

 LSR A                  \ Set P = A / 8, so R now contains the number of
 LSR A                  \ character blocks we need to fill - 1
 LSR A
 STA P

 LDA X1                 \ Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 8 pixels
                        \ wide)

 LDA TWFR,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ right end of the byte (so the filled pixels start at
                        \ point X and go all the way to the end of the byte),
                        \ which is the shape we want for the left end of the
                        \ line

 EOR (SC),Y             \ Store this into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen,
                        \ so we have now drawn the line's left cap

 TYA                    \ Set Y = Y + 8 so (SC),Y points to the next character
 ADC #8                 \ block along, on the same pixel row as before
 TAY

 LDX P                  \ Fetch the number of character blocks we need to fill
                        \ from P

 DEX                    \ Decrement the number of character blocks in X

 BEQ HL3                \ If X = 0 then we only have the last block to do (i.e.
                        \ the right cap), so jump down to HL3 to draw it

 CLC                    \ Otherwise clear the C flag so we can do some additions
                        \ while we draw the character blocks with full-width
                        \ lines in them

.HLL1

 LDA #%11111111         \ Store a full-width 8-pixel horizontal line in SC(1 0)
 EOR (SC),Y             \ so that it draws the line on-screen, using EOR logic
 STA (SC),Y             \ so it merges with whatever is already on-screen

 TYA                    \ Set Y = Y + 8 so (SC),Y points to the next character
 ADC #8                 \ block along, on the same pixel row as before
 TAY

 DEX                    \ Decrement the number of character blocks in X

 BNE HLL1               \ Loop back to draw more full-width lines, if we have
                        \ any more to draw

.HL3

 LDA X2                 \ Now to draw the last character block at the right end
 AND #7                 \ of the line, so set X = X2 mod 8, which is the
 TAX                    \ horizontal pixel number where the line ends

 LDA TWFL,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ left end of the byte (so the filled pixels start at
                        \ the left edge and go up to point X), which is the
                        \ shape we want for the right end of the line

 EOR (SC),Y             \ Store this into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen,
                        \ so we have now drawn the line's right cap

 RTS                    \ Return from the subroutine

.HL2

                        \ If we get here then the entire horizontal line fits
                        \ into one character block

 LDA X1                 \ Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 8 pixels
                        \ wide)

 LDA TWFR,X             \ Fetch a ready-made byte with X pixels filled in at the
 STA T                  \ right end of the byte (so the filled pixels start at
                        \ point X and go all the way to the end of the byte)

 LDA X2                 \ Set X = X2 mod 8, which is the horizontal pixel number
 AND #7                 \ where the line ends
 TAX

 LDA TWFL,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ left end of the byte (so the filled pixels start at
                        \ the left edge and go up to point X)

 AND T                  \ We now have two bytes, one (T) containing pixels from
                        \ the starting point X1 onwards, and the other (A)
                        \ containing pixels up to the end point at X2, so we can
                        \ get the actual line we want to draw by AND'ing them
                        \ together. For example, if we want to draw a line from
                        \ point 2 to point 5 (within the row of 8 pixels
                        \ numbered from 0 to 7), we would have this:
                        \
                        \   T       = %00111111
                        \   A       = %11111100
                        \   T AND A = %00111100
                        \
                        \ so if we stick T AND A in screen memory, that's what
                        \ we do here, setting A = A AND T

 EOR (SC),Y             \ Store our horizontal line byte into screen memory at
 STA (SC),Y             \ SC(1 0), using EOR logic so it merges with whatever is
                        \ already on-screen

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TWFL
\       Type: Variable
\   Category: Drawing lines
\    Summary: Ready-made character rows for the left end of a horizontal line in
\             mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting horizontal line end caps in mode 4 (the top part
\ of the split screen). This table provides a byte with pixels at the left end,
\ which is used for the right end of the line.
\
\ See the HLOIN routine for details.
\
\ ******************************************************************************

.TWFL

 EQUB %10000000
 EQUB %11000000
 EQUB %11100000
 EQUB %11110000
 EQUB %11111000
 EQUB %11111100
 EQUB %11111110

\ ******************************************************************************
\
\       Name: TWFR
\       Type: Variable
\   Category: Drawing lines
\    Summary: Ready-made character rows for the right end of a horizontal line
\             in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting horizontal line end caps in mode 4 (the top part
\ of the split screen). This table provides a byte with pixels at the right end,
\ which is used for the left end of the line.
\
\ See the HLOIN routine for details.
\
\ ******************************************************************************

.TWFR

 EQUB %11111111
 EQUB %01111111
 EQUB %00111111
 EQUB %00011111
 EQUB %00001111
 EQUB %00000111
 EQUB %00000011
 EQUB %00000001

\ ******************************************************************************
\
\       Name: PX3
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Plot a single pixel at (X, Y) within a character block
\
\ ------------------------------------------------------------------------------
\
\ This routine is called from PIXEL to set 1 pixel within a character block for
\ a distant point (i.e. where the distance ZZ >= &90). See the PIXEL routine for
\ details, as this routine is effectively part of PIXEL.
\
\ Arguments:
\
\   X                   The x-coordinate of the pixel within the character block
\
\   Y                   The y-coordinate of the pixel within the character block
\
\   SC(1 0)             The screen address of the character block
\
\   T1                  The value of Y to restore on exit, so Y is preserved by
\                       the call to PIXEL
\
\ ******************************************************************************

.PX3

 LDA TWOS,X             \ Fetch a 1-pixel byte from TWOS and EOR it into SC+Y
 EOR (SC),Y
 STA (SC),Y

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: PIXEL
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a 1-pixel dot, 2-pixel dash or 4-pixel square
\  Deep dive: Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Draw a point at screen coordinate (X, A) with the point size determined by the
\ distance in ZZ. This applies to the top part of the screen (the monochrome
\ mode 4 portion).
\
\ Arguments:
\
\   X                   The screen x-coordinate of the point to draw
\
\   A                   The screen y-coordinate of the point to draw
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ Returns:
\
\   Y                   Y is preserved
\
\ ******************************************************************************

.PIXEL

 JSR tube_get           \ AJD
 TAX
 JSR tube_get
 TAY
 JSR tube_get
 STA ZZ
 TYA

 LSR A                  \ Set SCH = &60 + A >> 3
 LSR A
 LSR A
 ORA #&60
 STA SCH

 TXA                    \ Set SC = (X >> 3) * 8
 AND #%11111000
 STA SC

 TYA                    \ Set Y = Y AND %111
 AND #%00000111
 TAY

 TXA                    \ Set X = X AND %111
 AND #%00000111
 TAX

 LDA ZZ                 \ If distance in ZZ >= 144, then this point is a very
 CMP #144               \ long way away, so jump to PX3 to fetch a 1-pixel point
 BCS PX3                \ from TWOS and EOR it into SC+Y

 LDA TWOS2,X            \ Otherwise fetch a 2-pixel dash from TWOS2 and EOR it
 EOR (SC),Y             \ into SC+Y
 STA (SC),Y

 LDA ZZ                 \ If distance in ZZ >= 80, then this point is a medium
 CMP #80                \ distance away, so jump to PX13 to stop drawing, as a
 BCS PX13               \ 2-pixel dash is enough

                        \ Otherwise we keep going to draw another 2 pixel point
                        \ either above or below the one we just drew, to make a
                        \ 4-pixel square

 DEY                    \ Reduce Y by 1 to point to the pixel row above the one
 BPL PX14               \ we just plotted, and if it is still positive, jump to
                        \ PX14 to draw our second 2-pixel dash

 LDY #1                 \ Reducing Y by 1 made it negative, which means Y was
                        \ 0 before we did the DEY above, so set Y to 1 to point
                        \ to the pixel row after the one we just plotted

.PX14

 LDA TWOS2,X            \ Fetch a 2-pixel dash from TWOS2 and EOR it into this
 EOR (SC),Y             \ second row to make a 4-pixel square
 STA (SC),Y

.PX13

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: clr_scrn
\       Type: Subroutine
\   Category: Utility routines
\    Summary: AJD
\
\ ******************************************************************************

.clr_scrn

 LDX #&60               \ Set X to the screen memory page for the top row of the
                        \ screen (as screen memory starts at &6000)

.BOL1

 JSR ZES1               \ Call ZES1 to zero-fill the page in X, which clears
                        \ that character row on the screen

 INX                    \ Increment X to point to the next page, i.e. the next
                        \ character row

 CPX #&78               \ Loop back to BOL1 until we have cleared page &7700,
 BNE BOL1               \ the last character row in the space view part of the
                        \ screen (the space view)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ZES1
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill the page whose number is in X
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The page we want to zero-fill
\
\ ******************************************************************************

.ZES1

 LDY #0                 \ If we set Y = SC = 0 and fall through into ZES2
 STY SC                 \ below, then we will zero-fill 255 bytes starting from
                        \ SC - in other words, we will zero-fill the whole of
                        \ page X

\ ******************************************************************************
\
\       Name: ZES2
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill a specific page
\
\ ------------------------------------------------------------------------------
\
\
\ Arguments:
\
\   Y                   The offset from (X SC) where we start zeroing, counting
\
\   SC                  The low byte (i.e. the offset into the page) of the
\                       starting point of the zero-fill
\
\ Returns:
\
\   Z flag              Z flag is set
\
\ ******************************************************************************

.ZES2

 TYA                    \ Load A with the byte we want to fill the memory block
                        \ with - i.e. zero

 STX SC+1               \ We want to zero-fill page X, so store this in the
                        \ high byte of SC, so the 16-bit address in SC and
                        \ SC+1 is now pointing to the SC-th byte of page X

.ZEL1

 STA (SC),Y             \ Zero the Y-th byte of the block pointed to by SC,
                        \ so that's effectively the Y-th byte before SC

 INY                    \ Increment the loop counter

 BNE ZEL1               \ Loop back to zero the next byte

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: CLYNS
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear the bottom three text rows of the mode 4 screen
\
\ ------------------------------------------------------------------------------
\
\ Clear some space at the bottom of the screen and move the text cursor to
\ column 1, row 21. Specifically, this zeroes the following screen locations:
\
\   &7507 to &75F0
\   &7607 to &76F0
\   &7707 to &77F0
\
\ which clears the three bottom text rows of the mode 4 screen (rows 21 to 23),
\ clearing each row from text column 1 to 30 (so it doesn't overwrite the box
\ border in columns 0 and 32, or the last usable column in column 31).
\
\ Returns:
\
\   A                   A is set to 0
\
\   Y                   Y is set to 0
\
\ ******************************************************************************

.CLYNS

 LDA #&75               \ Set the two-byte value in SC to &7507
 STA SC+1
 LDA #7
 STA SC

 LDA #0                 \ Call LYN to clear the pixels from &7507 to &75F0
 JSR LYN

 INC SC+1               \ Increment SC+1 so SC points to &7607

 JSR LYN                \ Call LYN to clear the pixels from &7607 to &76F0

 INC SC+1               \ Increment SC+1 so SC points to &7707

                        \ Fall through into LYN to clear the pixels from &7707
                        \ to &77F0

\ ******************************************************************************
\
\       Name: LYN
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear most of a row of pixels
\
\ ------------------------------------------------------------------------------
\
\ Set pixels 0-233 to the value in A, starting at the pixel pointed to by SC.
\
\ Arguments:
\
\   A                   The value to store in pixels 1-233 (the only value that
\                       is actually used is A = 0, which clears those pixels)
\
\ Returns:
\
\   Y                   Y is set to 0
\
\ Other entry points:
\
\   SC5                 Contains an RTS
\
\ ******************************************************************************

.LYN

 LDY #233               \ Set up a counter in Y to count down from pixel 233

.EE2

 STA (SC),Y             \ Store A in the Y-th byte after the address pointed to
                        \ by SC

 DEY                    \ Decrement Y

 BNE EE2                \ Loop back until Y is zero

.SC5

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: sync_in
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Wait for the vertical sync
\
\ ******************************************************************************

.sync_in

 JSR WSCAN              \ AJD
 JMP tube_put

\ ******************************************************************************
\
\       Name: WSCAN
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Wait for the vertical sync
\
\ ------------------------------------------------------------------------------
\
\ Wait for vertical sync to occur on the video system - in other words, wait
\ for the screen to start its refresh cycle, which it does 50 times a second
\ (50Hz).
\
\ ******************************************************************************

.WSCAN

 LDA #0                 \ Set DL to 0
 STA DL

 LDA DL                 \ Loop round these two instructions until DL is no
 BEQ P%-2               \ longer 0 (DL gets set to 30 in the LINSCN routine,
                        \ which is run when vertical sync has occurred on the
                        \ video system, so DL will change to a non-zero value
                        \ at the start of each screen refresh)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DILX
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update a bar-based indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The range of values shown on the indicator depends on which entry point is
\ called. For the default entry point of DILX, the range is 0-255 (as the value
\ passed in A is one byte). The other entry points are shown below.
\
\ Arguments:
\
\   A                   The value to be shown on the indicator (so the larger
\                       the value, the longer the bar)
\
\   T1                  The threshold at which we change the indicator's colour
\                       from the low value colour to the high value colour. The
\                       threshold is in pixels, so it should have a value from
\                       0-16, as each bar indicator is 16 pixels wide
\
\   K                   The colour to use when A is a high value, as a 4-pixel
\                       mode 5 character row byte
\
\   K+1                 The colour to use when A is a low value, as a 4-pixel
\                       mode 5 character row byte
\
\   SC(1 0)             The screen address of the first character block in the
\                       indicator
\
\   DILX+2              The range of the indicator is 0-64 (for the fuel
\                       indicator)
\
\ ******************************************************************************

.DILX

 JSR tube_get           \ AJD
 STA bar_1
 JSR tube_get
 STA bar_2
 JSR tube_get
 STA SC
 JSR tube_get
 STA SC+1

 LDX #&FF               \ Set bar_3 = &FF, to use as a mask for drawing each row
 STX bar_3              \ of each character block of the bar, starting with a
                        \ full character's width of 4 pixels

 LDY #2                 \ We want to start drawing the indicator on the third
                        \ line in this character row, so set Y to point to that
                        \ row's offset

 LDX #3                 \ Set up a counter in X for the width of the indicator,
                        \ which is 4 characters (each of which is 4 pixels wide,
                        \ to give a total width of 16 pixels)

.DL1

 LDA bar_1              \ Fetch the indicator value (0-15) from bar_1 into A

 CMP #4                 \ If bar_1 < 4, then we need to draw the end cap of the
 BCC DL2                \ indicator, which is less than a full character's
                        \ width, so jump down to DL2 to do this

 SBC #4                 \ Otherwise we can draw a 4-pixel wide block, so
 STA bar_1              \ subtract 4 from bar_1 so it contains the amount of the
                        \ indicator that's left to draw after this character

 LDA bar_3              \ Fetch the shape of the indicator row that we need to
                        \ display from bar_3, so we can use it as a mask when
                        \ painting the indicator. It will be &FF at this point
                        \ (i.e. a full 4-pixel row)

.DL5

 AND bar_2              \ Fetch the 4-pixel mode 5 colour byte from bar_2, and
                        \ only keep pixels that have their equivalent bits set
                        \ in the mask byte in A

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 6 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #6                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 DEX                    \ Decrement the loop counter for the next character
                        \ block along in the indicator

 BMI DL6                \ If we just drew the last character block then we are
                        \ done drawing, so jump down to DL6 to finish off

 BPL DL1                \ Loop back to DL1 to draw the next character block of
                        \ the indicator (this BPL is effectively a JMP as A will
                        \ never be negative following the previous BMI)

.DL2

 EOR #3                 \ If we get here then we are drawing the indicator's end
 STA bar_1              \ cap, so bar_1 is < 4, and this EOR flips the bits, so
                        \ instead of containing the number of indicator columns
                        \ we need to fill in on the left side of the cap's
                        \ character block, bar_1 now contains the number of
                        \ blank columns there should be on the right side of the
                        \ cap's character block

 LDA bar_3              \ Fetch the current mask from bar_3, which will be &FF
                        \ at this point, so we need to turn bar_1 of the columns
                        \ on the right side of the mask to black to get the
                        \ correct end cap shape for the indicator

.DL3

 ASL A                  \ Shift the mask left so bit 0 is cleared, and then
 AND #%11101111         \ clear bit 4, which has the effect of shifting zeroes
                        \ from the left into each nibble (i.e. xxxx xxxx becomes
                        \ xxx0 xxx0, which blanks out the last column in the
                        \ 4-pixel mode 5 character block)

 DEC bar_1              \ Decrement the counter for the number of columns to
                        \ blank out

 BPL DL3                \ If we still have columns to blank out in the mask,
                        \ loop back to DL3 until the mask is correct for the
                        \ end cap

 PHA                    \ Store the mask byte on the stack while we use the
                        \ accumulator for a bit

 LDA #0                 \ Change the mask so no bits are set, so the characters
 STA bar_3              \ after the one we're about to draw will be all blank

 LDA #99                \ Set bar_1 to a high number (99, why not) so we will
 STA bar_1              \ keep drawing blank characters until we reach the end
                        \ of the indicator row

 PLA                    \ Restore the mask byte from the stack so we can use it
                        \ to draw the end cap of the indicator

 JMP DL5                \ Jump back up to DL5 to draw the mask byte on-screen

.DL6

.DL9

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DIL2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the roll or pitch indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The indicator can show a vertical bar in 16 positions, with a value of 8
\ showing the bar in the middle of the indicator.
\
\ In practice this routine is only ever called with A in the range 1 to 15, so
\ the vertical bar never appears in the leftmost position (though it does appear
\ in the rightmost).
\
\ Arguments:
\
\   A                   The offset of the vertical bar to show in the indicator,
\                       from 0 at the far left, to 8 in the middle, and 15 at
\                       the far right
\
\ Returns:
\
\   C flag              The C flag is set
\
\ ******************************************************************************

.DIL2

 JSR tube_get           \ AJD
 STA angle_1
 JSR tube_get
 STA SC
 JSR tube_get
 STA SC+1

 LDY #1                 \ We want to start drawing the vertical indicator bar on
                        \ the second line in the indicator's character block, so
                        \ set Y to point to that row's offset

                        \ We are now going to work our way along the indicator
                        \ on the dashboard, from left to right, working our way
                        \ along one character block at a time. Y will be used as
                        \ a pixel row counter to work our way through the
                        \ character blocks, so each time we draw a character
                        \ block, we will increment Y by 8 to move on to the next
                        \ block (as each character block contains 8 rows)

.DLL10

 SEC                    \ Set A = angle_1 - 4, so that A contains the offset of
 LDA angle_1            \ the vertical bar from the start of this character
 SBC #4                 \ block

 BCS DLL11              \ If angle_1 >= 4 then the character block we are
                        \ drawing does not contain the vertical indicator bar,
                        \ so jump to DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX angle_1            \ Set X to the offset of the vertical bar, which we know
                        \ is within this character block

 STA angle_1            \ Set angle_1 to a high number (&FF, why not) so we will
                        \ keep drawing blank characters after this one until we
                        \ reach the end of the indicator row

 LDA CTWOS,X            \ CTWOS is a table of ready-made 1-pixel mode 5 bytes,
                        \ just like the TWOS and TWOS2 tables for mode 4 (see
                        \ the PIXEL routine for details of how they work). This
                        \ fetches a mode 5 1-pixel byte with the pixel position
                        \ at X, so the pixel is at the offset that we want for
                        \ our vertical bar

 AND #&F0               \ The 4-pixel mode 5 colour byte &F0 represents four
                        \ pixels of colour %10 (3), which is yellow in the
                        \ normal dashboard palette and white if we have an
                        \ escape pod fitted. We AND this with A so that we only
                        \ keep the pixel that matches the position of the
                        \ vertical bar (i.e. A is acting as a mask on the
                        \ 4-pixel colour byte)

 JMP DLL12              \ Jump to DLL12 to skip the code for drawing a blank,
                        \ and move on to drawing the indicator

.DLL11

                        \ If we get here then we want to draw a blank for this
                        \ character block

 STA angle_1            \ Update angle_1 with the new offset of the vertical
                        \ bar, so it becomes the offset after the character
                        \ block we are about to draw

 LDA #0                 \ Change the mask so no bits are set, so all of the
                        \ character blocks we display from now on will be blank
.DLL12

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the fourth pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 5 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #5                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 CPY #30                \ If Y < 30 then we still have some more character
 BCC DLL10              \ blocks to draw, so loop back to DLL10 to display the
                        \ next one along

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MSBAR
\       Type: Subroutine
\   Category: Dashboard
\    Summary: AJD
\
\ ******************************************************************************

.MSBAR

 JSR tube_get           \ Like MSBAR
 ASL A
 ASL A
 ASL A
 STA missle_1
 LDA #&31-8
 SBC missle_1
 STA SC
 LDA #&7E
 STA SC+&01
 JSR tube_get
 LDY #&05

.l_33ba

 STA (SC),Y
 DEY
 BNE l_33ba
 RTS

\ ******************************************************************************
\
\       Name: scan_fire
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.scan_fire

 LDA #&51
 STA &FE60
 LDA &FE40
 AND #&10
 JMP tube_put

\ ******************************************************************************
\
\       Name: write_fe4e
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.write_fe4e

 JSR tube_get
 STA &FE4E
 JMP tube_put

\ ******************************************************************************
\
\       Name: scan_xin
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.scan_xin

 JSR tube_get
 TAX
 JSR DKS4
 JMP tube_put

\ ******************************************************************************
\
\       Name: DKS4
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Scan the keyboard to see if a specific key is being pressed
\  Deep dive: The key logger
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The internal number of the key to check (see p.142 of
\                       the Advanced User Guide for a list of internal key
\                       numbers)
\
\ Returns:
\
\   A                   If the key in A is being pressed, A contains the
\                       original argument A, but with bit 7 set (i.e. A + 128).
\                       If the key in A is not being pressed, the value in A is
\                       unchanged
\
\   X                   Contains the same as A
\
\ Other entry points:
\
\   DKS2-1              Contains an RTS
\
\ ******************************************************************************

.DKS4

 LDA #%00000011         \ Set A to %00000011, so it's ready to send to SHEILA
                        \ once interrupts have been disabled

 SEI                    \ Disable interrupts so we can scan the keyboard
                        \ without being hijacked

 STA VIA+&40            \ Set 6522 System VIA output register ORB (SHEILA &40)
                        \ to %00000011 to stop auto scan of keyboard

 LDA #%01111111         \ Set 6522 System VIA data direction register DDRA
 STA VIA+&43            \ (SHEILA &43) to %01111111. This sets the A registers
                        \ (IRA and ORA) so that:
                        \
                        \   * Bits 0-6 of ORA will be sent to the keyboard
                        \
                        \   * Bit 7 of IRA will be read from the keyboard

 STX VIA+&4F            \ Set 6522 System VIA output register ORA (SHEILA &4F)
                        \ to X, the key we want to scan for; bits 0-6 will be
                        \ sent to the keyboard, of which bits 0-3 determine the
                        \ keyboard column, and bits 4-6 the keyboard row

 LDX VIA+&4F            \ Read 6522 System VIA output register IRA (SHEILA &4F)
                        \ into X; bit 7 is the only bit that will have changed.
                        \ If the key is pressed, then bit 7 will be set,
                        \ otherwise it will be clear

 LDA #%00001011         \ Set 6522 System VIA output register ORB (SHEILA &40)
 STA VIA+&40            \ to %00001011 to restart auto scan of keyboard

 CLI                    \ Allow interrupts again

 TXA                    \ Transfer X into A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: scan_10in
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.scan_10in

 JSR RDKEY
 JMP tube_put

\ ******************************************************************************
\
\       Name: RDKEY
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Scan the keyboard for key presses
\
\ ------------------------------------------------------------------------------
\
\ Scan the keyboard, starting with internal key number 16 ("Q") and working
\ through the set of internal key numbers (see p.142 of the Advanced User Guide
\ for a list of internal key numbers).
\
\ This routine is effectively the same as OSBYTE 122, though the OSBYTE call
\ preserves A, unlike this routine.
\
\ Returns:
\
\   X                   If a key is being pressed, X contains the internal key
\                       number, otherwise it contains 0
\
\ ******************************************************************************

.RDKEY

 LDX #16                \ Start the scan with internal key number 16 ("Q")

.Rd1

 JSR DKS4               \ Scan the keyboard to see if the key in X is currently
                        \ being pressed, returning the result in A and X

 BMI Rd2                \ Jump to Rd2 if this key is being pressed (in which
                        \ case DKS4 will have returned the key number with bit
                        \ 7 set, which is negative)

 INX                    \ Increment the key number, which was unchanged by the
                        \ above call to DKS4

 BPL Rd1                \ Loop back to test the next key, ending the loop when
                        \ X is negative (i.e. 128)

 TXA                    \ If we get here, nothing is being pressed, so copy X
                        \ into A so that X = A = 128 = %10000000

.Rd2

 EOR #%10000000         \ EOR A with #%10000000 to flip bit 7, so A now contains
                        \ 0 if no key has been pressed, or the internal key
                        \ number if a key has been pressed

 CMP #&37               \ CTRL-P hack for printer AJD
 BNE scan_test
 LDX #&01
 JSR DKS4
 BPL scan_p
 JSR printer
 LDA #0

 RTS                    \ Return from the subroutine

.scan_p

 LDA #&37

.scan_test

 TAX
 RTS

\ ******************************************************************************
\
\       Name: get_key
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.get_key

 JSR WSCAN
 JSR WSCAN
 JSR RDKEY
 BNE get_key

.press

 JSR RDKEY
 BEQ press
 TAY
 LDA (key_tube),Y
 JMP tube_put

\ ******************************************************************************
\
\       Name: write_pod
\       Type: Subroutine
\   Category: Dashboard
\    Summary: AJD
\
\ ******************************************************************************

.write_pod

 JSR tube_get
 STA ESCP
 JSR tube_get
 STA HFX
 RTS

\ ******************************************************************************
\
\       Name: draw_blob
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: AJD
\
\ ******************************************************************************

.draw_blob

 JSR tube_get
 STA X1
 JSR tube_get
 STA Y1
 JSR tube_get
 STA X2

\ ******************************************************************************
\
\       Name: CPIX2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single-height dot on the dashboard
\  Deep dive: Drawing colour pixels in mode 5
\
\ ------------------------------------------------------------------------------
\
\ Draw a single-height mode 5 dash (1 pixel high, 2 pixels wide).
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the dash
\
\   Y1                  The screen pixel y-coordinate of the dash
\
\   COL                 The colour of the dash as a mode 5 character row byte
\
\ ******************************************************************************

.CPIX2

 LDA Y1                 \ Fetch the y-coordinate into A

 LSR A                  \ Set A = A / 8, so A now contains the character row we
 LSR A                  \ need to draw in (as each character row contains 8
 LSR A                  \ pixel rows)

 ORA #&60               \ Each character row in Elite's screen mode takes up one
                        \ page in memory (256 bytes), so we now OR with &60 to
                        \ get the page containing the dash (see the comments in
                        \ routine TT26 for more discussion about calculating
                        \ screen memory addresses)

 STA SCH                \ Store the screen page in the high byte of SC(1 0)

 LDA X1                 \ Each character block contains 8 pixel rows, so to get
 AND #%11111000         \ the address of the first byte in the character block
                        \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-2

 STA SC                 \ Store the address of the character block in the low
                        \ byte of SC(1 0), so now SC(1 0) points to the
                        \ character block we need to draw into

 LDA Y1                 \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 LDA X1                 \ Copy bits 0-1 of X1 to bits 1-2 of X, and clear the C
 AND #%00000110         \ flag in the process (using the LSR). X will now be
 LSR A                  \ a value between 0 and 3, and will be the pixel number
 TAX                    \ in the character row for the left pixel in the dash.
                        \ This is because each character row is one byte that
                        \ contains 4 pixels, but covers 8 screen coordinates, so
                        \ this effectively does the division by 2 that we need

 LDA CTWOS,X            \ Fetch a mode 5 1-pixel byte with the pixel position
 AND COL                \ at X, and AND with the colour byte so that pixel takes
                        \ on the colour we want to draw (i.e. A is acting as a
                        \ mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 LDA CTWOS+1,X          \ Fetch a mode 5 1-pixel byte with the pixel position
                        \ at X+1, so we can draw the right pixel of the dash

 BPL CP1                \ The CTWOS table has an extra row at the end of it that
                        \ repeats the first value, %10001000, so if we have not
                        \ fetched that value, then the right pixel of the dash
                        \ is in the same character block as the left pixel, so
                        \ jump to CP1 to draw it

 LDA SC                 \ Otherwise the left pixel we drew was at the last
 ADC #8                 \ position of four in this character block, so we add
 STA SC                 \ 8 to the screen address to move onto the next block
                        \ along (as there are 8 bytes in a character block).
                        \ The C flag was cleared above, so this ADC is correct

 LDA CTWOS+1,X          \ Refetch the mode 5 1-pixel byte, as we just overwrote
                        \ A (the byte will still be the fifth byte from the
                        \ table, which is correct as we want to draw the
                        \ leftmost pixel in the next character along as the
                        \ dash's right pixel)

.CP1

 AND COL                \ Apply the colour mask to the pixel byte, as above

 EOR (SC),Y             \ Draw the dash's right pixel according to the mask in
 STA (SC),Y             \ A, with the colour in COL, using EOR logic, just as
                        \ above

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: draw_tail
\       Type: Subroutine
\   Category: Dashboard
\    Summary: AJD
\
\ ******************************************************************************

.draw_tail

 JSR tube_get
 STA X1
 JSR tube_get
 STA Y1
 JSR tube_get
 STA X2
 JSR tube_get
 STA Y2
 JSR tube_get
 STA P

.SC48 

 JSR CPIX2              \ Like SC48 in SCAN
 DEC Y1
 JSR CPIX2

 LDA CTWOS+1,X
 AND COL \ iff
 STA COL

 LDA CTWOS+1,X
 AND Y2 \ COL2?
 STA Y2
 LDX P
 BEQ RTS
 BMI d_55db

.VLL1

 DEY
 BPL VL1
 LDY #&07
 DEC SC+&01

.VL1

 LDA COL
 EOR Y2 \ iff drawpix_4
 STA COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BNE VLL1

.RTS

 RTS

.d_55db

 INY
 CPY #&08
 BNE VLL2
 LDY #&00
 INC SC+&01

.VLL2

 INY
 CPY #&08
 BNE VL2
 LDY #&00
 INC SC+&01

.VL2

 LDA COL
 EOR Y2 \ iff drawpix_4
 STA COL
 EOR (SC),Y
 STA (SC),Y
 INX
 BNE VLL2
 RTS

\ ******************************************************************************
\
\       Name: ECBLB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Light up the E.C.M. indicator bulb ("E") on the dashboard
\
\ ******************************************************************************

.ECBLB

 LDA #7*8               \ The E.C.M. bulb is in character block number 7
                        \ with each character taking 8 bytes, so this sets the
                        \ low byte of the screen address of the character block
                        \ we want to draw to

 LDX #LO(ECBT)          \ Set (Y X) to point to the character definition in
 LDY #HI(ECBT)          \ ECBT

 JMP BULB               \ Jump down to BULB

\ ******************************************************************************
\
\       Name: SPBLB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Draw (or erase) the space station indicator ("S") on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   BULB-2              Set the Y screen address
\
\ ******************************************************************************

.SPBLB

 LDA #24*8              \ The space station bulb is in character block number 24
                        \ with each character taking 8 bytes, so this sets the
                        \ low byte of the screen address of the character block
                        \ we want to draw to

 LDX #LO(SPBT)          \ Set (Y X) to point to the character definition in SPBT
 LDY #HI(SPBT)

                        \ Fall through into BULB to draw the space station bulb

\ ******************************************************************************
\
\       Name: BULB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Draw an indicator bulb on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The y-coordinate of the bulb as a low-byte screen
\                       address offset within screen page &7D (as both bulbs
\                       are on this character row in the dashboard)
\
\   (Y X)               The address of the character definition of the bulb to
\                       be drawn (i.e. ECBT for the E.C.M. bulb, or SPBT for the
\                       space station bulb)
\
\ ******************************************************************************

.BULB

 STA SC                 \ Store the low byte of the screen address in SC

 LDA #&7D               \ Set A to the high byte of the screen address, which is
                        \ &7D as the bulbs are both in the character row from
                        \ &7D00 to &7DFF

 STA SC+1               \ AJD
 STX font
 STY font+1
 LDY #&07

.ECBLBor

 LDA (font),Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL ECBLBor
 RTS

\ ******************************************************************************
\
\       Name: ECBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The character bitmap for the E.C.M. indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The character bitmap for the E.C.M. indicator's "E" bulb that gets displayed
\ on the dashboard.
\
\ The E.C.M. indicator uses the first 5 rows of the space station's "S" bulb
\ below, as the bottom 5 rows of the "E" match the top 5 rows of the "S".
\
\ Each pixel is in mode 5 colour 2 (%10), which is yellow/white.
\
\ ******************************************************************************

.ECBT

 EQUB %11100000         \ x x x .
 EQUB %11100000         \ x x x .
 EQUB %10000000         \ x . . .
                        \ x x x .
                        \ x x x .
                        \ x . . .
                        \ x x x .
                        \ x x x .

\ ******************************************************************************
\
\       Name: SPBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The bitmap definition for the space station indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The bitmap definition for the space station indicator's "S" bulb that gets
\ displayed on the dashboard.
\
\ Each pixel is in mode 5 colour 2 (%10), which is yellow/white.
\
\ ******************************************************************************

.SPBT

 EQUB %11100000         \ x x x .
 EQUB %11100000         \ x x x .
 EQUB %10000000         \ x . . .
 EQUB %11100000         \ x x x .
 EQUB %11100000         \ x x x .
 EQUB %00100000         \ . . x .
 EQUB %11100000         \ x x x .
 EQUB %11100000         \ x x x .

\ ******************************************************************************
\
\       Name: UNWISE
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Switch the main line-drawing routine between EOR and OR logic
\
\ ------------------------------------------------------------------------------
\
\ This routine modifies the instructions in the main line-drawing routine at
\ LOIN/LL30, flipping the drawing logic between the default EOR logic (which
\ merges with whatever is already on screen, allowing us to erase anything we
\ draw for animation purposes) and OR logic (which overwrites the screen,
\ ignoring anything that's already there). We want to use OR logic for drawing
\ the ship hanger, as it looks better and we don't need to animate it).
\
\ The routine name, UNWISE, sums up this approach - if anything goes wrong, the
\ results would be messy.
\
\ Other entry points:
\
\   HA1                 Contains an RTS
\
\ ******************************************************************************

.UNWISE

 LDA LIL2+2             \ AJD
 EOR #&40
 STA LIL2+2
 \LDA LIL3+2
 \EOR #&40
 STA LIL3+2
 \LDA LIL5+2
 \EOR #&40
 STA LIL5+2
 \LDA LIL6+2
 \EOR #&40
 STA LIL6+2

.HA1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DET1
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Show or hide the dashboard (for when we die)
\
\ ------------------------------------------------------------------------------
\
\ Set the screen to show the number of text rows given in X. This is used when
\ we are killed, as reducing the number of rows from the usual 31 to 24 has the
\ effect of hiding the dashboard, leaving a monochrome image of ship debris and
\ explosion clouds. Increasing the rows back up to 31 makes the dashboard
\ reappear, as the dashboard's screen memory doesn't get touched by this
\ process.
\
\ Returns:
\
\   A                   A is set to 6
\
\ ******************************************************************************

.DET1

 JSR tube_get           \ AJD

 LDX #6                 \ Set X to 6 so we can update 6845 register R6 below

 SEI                    \ Disable interrupts so we can update the 6845

 STX VIA+&00            \ Set 6845 register R6 to the value in A. Register R6
 STA VIA+&01            \ is the "vertical displayed" register, which sets the
                        \ number of rows shown on the screen

 CLI                    \ Re-enable interrupts

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: KYTB
\       Type: Variable
\   Category: Keyboard
\    Summary: Lookup table for in-flight keyboard controls
\  Deep dive: The key logger
\
\ ------------------------------------------------------------------------------
\
\ Keyboard table for in-flight controls. This table contains the internal key
\ codes for the flight keys (see p.142 of the Advanced User Guide for a list of
\ internal key numbers).
\
\ The pitch, roll, speed and laser keys (i.e. the seven primary flight
\ control keys) have bit 7 set, so they have 128 added to their internal
\ values. This doesn't appear to be used anywhere.
\
\ ******************************************************************************

.KYTB

                        \ These are the primary flight controls (pitch, roll,
                        \ speed and lasers):

 EQUB &68 + 128         \ ?         KYTB+1      Slow down
 EQUB &62 + 128         \ Space     KYTB+2      Speed up
 EQUB &66 + 128         \ <         KYTB+3      Roll left
 EQUB &67 + 128         \ >         KYTB+4      Roll right
 EQUB &42 + 128         \ X         KYTB+5      Pitch up
 EQUB &51 + 128         \ S         KYTB+6      Pitch down
 EQUB &41 + 128         \ A         KYTB+7      Fire lasers

                        \ These are the secondary flight controls:

 EQUB &60               \ TAB       KYTB+8      Activate hyperspace unit
 EQUB &70               \ ESCAPE    KYTB+9      Launch escape pod
 EQUB &23               \ T         KYTB+10     Arm missile
 EQUB &35               \ U         KYTB+11     Unarm missile
 EQUB &65               \ M         KYTB+12     Fire missile
 EQUB &22               \ E         KYTB+13     E.C.M.
 EQUB &45               \ J         KYTB+14     In-system jump
 EQUB &63               \ AJD

 EQUB &37               \ P         KYTB+16     Cancel docking computer

\ ******************************************************************************
\
\       Name: b_table
\       Type: Variable
\   Category: Keyboard
\    Summary: Lookup table for Delta 14b joystick buttons
\
\ ******************************************************************************

.b_table

 EQUB &61, &31, &80, &80, &80, &80, &51             \ AJD
 EQUB &64, &34, &32, &62, &52, &54, &58, &38, &68

\ ******************************************************************************
\
\       Name: b_14
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Check Delta 14b joystick buttons
\
\ ******************************************************************************

.b_13

 LDA #&00               \ AJD

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

\ ******************************************************************************
\
\       Name: scan_y
\       Type: Subroutine
\   Category: Keyboard
\    Summary: AJD
\
\ ******************************************************************************

.scan_y

 JSR tube_get
 TAY
 JSR tube_get
 BMI b_14
 LDX KYTB-1,Y
 JSR DKS4
 BPL b_quit

.b_pressed

 LDA #&FF

.b_quit

 JMP tube_put

\ ******************************************************************************
\
\       Name: write_0346
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.write_0346

 JSR tube_get
 STA LASCT
 RTS

\ ******************************************************************************
\
\       Name: read_0346
\       Type: Subroutine
\   Category: Tube
\    Summary: AJD
\
\ ******************************************************************************

.read_0346

 LDA LASCT
 JMP tube_put

\ ******************************************************************************
\
\       Name: HANGER
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: AJD
\
\ ******************************************************************************

.HANGER

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
 STA SC+&01
 LDA picture_1
 AND #&07
 STA SC
 LDY #&00
 JSR HAS2
 LDA #&04
 LDY #&F8
 JSR HAS3
 LDY picture_2
 BEQ l_2045
 JSR HAS2
 LDY #&80
 LDA #&40
 JSR HAS3

.l_2045

 RTS

.HA2

 JSR tube_get
 AND #&F8
 STA SC
 LDX #&60
 STX SC+&01
 LDX #&80
 LDY #&01

.HAL7

 TXA
 AND (SC),Y
 BNE HA6
 TXA
 ORA (SC),Y
 STA (SC),Y
 INY
 CPY #&08
 BNE HAL7
 INC SC+&01
 LDY #&00
 BEQ HAL7

.HA6

 RTS

\ ******************************************************************************
\
\       Name: HAS2
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Draw a hanger background line from left to right
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line to the right, starting with the third pixel of the
\ pixel row at screen address SC(1 0), and aborting if we bump into something
\ that's already on-screen. HAL2 draws from the left edge of the screen to the
\ halfway point, and then HAL3 takes over to draw from the halfway point across
\ the right half of the screen.
\
\ Other entry points:
\
\   HA3                 Contains an RTS
\
\ ******************************************************************************

.HAS2

 LDA #%00100000         \ Set A to the pixel pattern for a mode 4 character row
                        \ byte with the third pixel set, so we start drawing the
                        \ horizontal line just to the right of the 2-pixel
                        \ border along the edge of the screen

.HAL2

 TAX                    \ Store A in X so we can retrieve it after the following
                        \ check and again after updating screen memory

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA3                \ mask), then this means it already contains something,
                        \ so we stop drawing because we have run into something
                        \ that's already on-screen, and return from the
                        \ subroutine (as HA3 contains an RTS)

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 LSR A                  \ Shift A to the right to move on to the next pixel

 BCC HAL2               \ If bit 0 before the shift was clear (i.e. we didn't
                        \ just do the fourth pixel in this block), loop back to
                        \ HAL2 to check and draw the next pixel

 TYA                    \ Set Y = Y + 8 (as we know the C flag is set) to point
 ADC #7                 \ to the next character block along
 TAY

 LDA #%10000000         \ Reset the pixel mask in A to the first pixel in the
                        \ new 8-pixel character block

 BCC HAL2               \ If the above addition didn't overflow, jump back to
                        \ HAL2 to keep drawing the line in the next character
                        \ block

.HA3

 RTS                    \ The addition overflowed, so we have reached the last
                        \ character block in this page of memory, which is the
                        \ end of the line, so we return from the subroutine

\ ******************************************************************************
\
\       Name: HAS3
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Draw a hanger background line from right to left
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line to the left, starting with the pixel mask in A at
\ screen address SC(1 0) and character block offset Y, and aborting if we bump
\ into something that's already on-screen.
\
\ ******************************************************************************

.HAS3

 TAX                    \ Store A in X so we can retrieve it after the following
                        \ check and again after updating screen memory

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA3                \ mask), then this means it already contains something,
                        \ so we stop drawing because we have run into something
                        \ that's already on-screen, and return from the
                        \ subroutine (as HA3 contains an RTS)

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 ASL A                  \ Shift A to the left to move to the next pixel to the
                        \ left

 BCC HAS3               \ If bit 7 before the shift was clear (i.e. we didn't
                        \ just do the first pixel in this block), loop back to
                        \ HAS3 to check and draw the next pixel to the left

 TYA                    \ Set Y = Y - 8 (as we know the C flag is set) to point
 SBC #8                 \ to the next character block to the left
 TAY

 LDA #%00000001         \ Set a mask in A to the last pixel in the 8-pixel byte

 BCS HAS3               \ If the above subtraction didn't underflow, jump back
                        \ to HAS3 to keep drawing the line in the next character
                        \ block to the left

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: printer
\       Type: Subroutine
\   Category: Text
\    Summary: AJD
\
\ ******************************************************************************

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
 STA SC+1
 LDA #0
 STA SC

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
 LDA (SC),Y
 STA print_bits,X
 DEY
 BPL print_copy
 LDA SC+1
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
 LDA SC
 ADC #8
 STA SC
 BNE print_outer
 LDA #13
 JSR print_wrch
 INC SC+1
 LDX SC+1
 INX
 BPL print_view
 LDA #3
 JMP print_safe
 \JSR print_safe
 \JMP tube_put

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

\ ******************************************************************************
\
\ Save output/2.H.bin
\
\ ******************************************************************************

PRINT "S.2.H ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/2.H.bin", CODE%, P%, LOAD%