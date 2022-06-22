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
\   * 2.H.bin
\
\ ******************************************************************************

INCLUDE "1-source-files/main-sources/elite-header.h.asm"

_RELEASED               = (_VARIANT = 1)
_SOURCE_DISC            = (_VARIANT = 2)
_BUG_FIX                = (_VARIANT = 3)

GUARD &6000             \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

X = 128                 \ The centre x-coordinate of the 256 x 192 space view
Y = 96                  \ The centre y-coordinate of the 256 x 192 space view

tube_brk = &0016        \ The location of the Tube host code's break handler

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

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

tube_r1s = &FEE0        \ The Tube's memory-mapped FIFO 1 status register
tube_r1d = &FEE1        \ The Tube's memory-mapped FIFO 1 data register
tube_r2s = &FEE2        \ The Tube's memory-mapped FIFO 2 status register
tube_r2d = &FEE3        \ The Tube's memory-mapped FIFO 2 data register
tube_r3s = &FEE4        \ The Tube's memory-mapped FIFO 3 status register
tube_r3d = &FEE5        \ The Tube's memory-mapped FIFO 3 data register
tube_r4s = &FEE6        \ The Tube's memory-mapped FIFO 4 status register
tube_r4d = &FEE7        \ The Tube's memory-mapped FIFO 4 data register

rawrch = &FFBC          \ The address of the MOS's VDU character output routine

OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSCLI = &FFF7           \ The address for the OSCLI routine

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

 SKIP 2                 \ Contains the address of the I/O processor's keyboard
                        \ translation table (as opposed to the parasite's
                        \ table), which is used to translate internal key
                        \ numbers to ASCII in the I/O processor code

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
.K3
.COL
.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.XSAV2
.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.YSAV2
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
\    Summary: Set the vectors to receive Tube communications, run the parasite
\             code, and terminate the I/O processor's loading process
\
\ ******************************************************************************

.tube_elite

 LDX #&FF               \ Set the stack pointer to &01FF, which is the standard
 TXS                    \ location for the 6502 stack, so this instruction
                        \ effectively resets the stack

 LDA #LO(tube_wrch)     \ Set WRCHV to point to the tube_wrch routine, so when
 STA WRCHV              \ bytes are sent to the I/O processor from the parasite,
 LDA #HI(tube_wrch)     \ the tube_wrch routine is called to handle them
 STA WRCHV+1

 LDA #LO(tube_brk)      \ Set BRKV to point to the tube_brk routine (i.e. to the
 STA BRKV               \ Tube host code's break handler)
 LDA #HI(tube_brk)
 STA BRKV+1

 LDX #LO(tube_run)      \ Set (Y X) to point to tube_run ("R.2.T")
 LDY #HI(tube_run)

 JMP OSCLI              \ Call OSCLI to run the OS command in tube_run, which
                        \ *RUNs the parasite code in the 2.T file before
                        \ returning from the subroutine using a tail call

                        \ This terminates the I/O processor code, leaving the
                        \ BBC Micro to sit idle until a command arrives from the
                        \ parasite and calls tube_wrch via WRCHV

\ ******************************************************************************
\
\       Name: tube_run
\       Type: Variable
\   Category: Tube
\    Summary: The OS command string for running the Tube version's parasite code
\             in file 2.T
\
\ ******************************************************************************

.tube_run

 EQUS "R.2.T"           \ This is short for "*RUN 2.T"
 EQUB 13

\ ******************************************************************************
\
\       Name: tube_get
\       Type: Subroutine
\   Category: Tube
\    Summary: As the I/O processor, fetch a byte that's been sent over the Tube
\             from the parasite
\  Deep dive: Tube communication in Elite-A
\
\ ------------------------------------------------------------------------------
\
\ Tube communication in Elite-A uses the following protocol:
\
\ Parasite -> I/O processor
\
\   * Uses the FIFO 1 status and data registers to transmit the data
\   * The parasite calls tube_write to send a byte to the I/O processor
\   * The I/O processor calls tube_get to receive that byte from the parasite
\
\ I/O processor -> Parasite
\
\   * Uses the FIFO 2 status and data registers to transmit the data
\   * The I/O processor calls tube_put to send a byte to the parasite
\   * The parasite calls tube_read to receive that byte from the I/O processor
\
\ This routine is called by the I/O processor to receive a byte from the
\ parasite.
\
\ The code is identical to Acorn's MOS routine that runs on the parasite to
\ implement OSWRCH across the Tube.
\
\ ******************************************************************************

.tube_get

 BIT tube_r1s           \ Check whether FIFO 1 has received a byte from the
                        \ parasite (which it will have sent by calling its own
                        \ tube_write routine). We do this by checking bit 7 of
                        \ the FIFO 1 status register

 NOP                    \ Pause while the register is checked

 BPL tube_get           \ If FIFO 1 has received a byte then bit 7 of the status
                        \ register will be set, so this loops back to tube_get
                        \ until FIFO 1 contains the byte transmitted from the
                        \ parasite

 LDA tube_r1d           \ Fetch the transmitted byte by reading the FIFO 1 data
                        \ register into A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: tube_put
\       Type: Subroutine
\   Category: Tube
\    Summary: As the I/O processor, send a byte across the Tube to the parasite
\  Deep dive: Tube communication in Elite-A
\
\ ------------------------------------------------------------------------------
\
\ Tube communication in Elite-A uses the following protocol:
\
\ Parasite -> I/O processor
\
\   * Uses the FIFO 1 status and data registers to transmit the data
\   * The parasite calls tube_write to send a byte to the I/O processor
\   * The I/O processor calls tube_get to receive that byte from the parasite
\
\ I/O processor -> Parasite
\
\   * Uses the FIFO 2 status and data registers to transmit the data
\   * The I/O processor calls tube_put to send a byte to the parasite
\   * The parasite calls tube_read to receive that byte from the I/O processor
\
\ This routine is called by the I/O processor to send a byte to the parasite.
\
\ The code is identical to Acorn's MOS routine that runs on the parasite to
\ implement OSWRCH across the Tube (except this uses FIFO 2 instead of FIFO 1).
\
\ ******************************************************************************

.tube_put

 BIT tube_r2s           \ Check whether FIFO 2 is available for use, so we can
                        \ use it to transmit a byte to the I/O processor. We do
                        \ this by checking bit 6 of the FIFO 2 status register

 NOP                    \ Pause while the register is checked

 BVC tube_put           \ If FIFO 2 is available for use then bit 6 of the
                        \ status register will be set, so this loops back to
                        \ tube_put until FIFO 2 is available for us to use

 STA tube_r2d           \ FIFO 2 is available for use, so store the value we
                        \ want to transmit in the FIFO 2 data register, so it
                        \ gets sent to the parasite

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: tube_func
\       Type: Subroutine
\   Category: Tube
\    Summary: Call the corresponding routine for a Tube command
\  Deep dive: Tube communication in Elite-A
\
\ ------------------------------------------------------------------------------
\
\ This routine calls the routine given in the tube_table lookup table for the
\ Tube command specified in A.
\
\ Arguments:
\
\   A                   The command number (&80-&FF)
\
\ ******************************************************************************

.tube_func

 CMP #&9D               \ If A >= &9D then there isn't a corresponding command,
 BCS return             \ so jump to return to return from the subroutine

 ASL A                  \ Set Y = A * 2, so we can use it as an index into the
 TAY                    \ lookup table, which has two bytes per entry
                        \
                        \ Note that this also shifts bit 7 off the end, so the
                        \ result is actually ((A - 128) * 2), which means if A
                        \ starts out at &80, then Y = 0, if A is &81, Y = 2,
                        \ and so on

 LDA tube_table,Y       \ Copy the Y-th address from tube_table over the &FFFF
 STA tube_jump+1        \ address of the JMP instruction below, so this modifies
 LDA tube_table+1,Y     \ the instruction so that it jumps to the coresponding
 STA tube_jump+2        \ address from the lookup table

.tube_jump

 JMP &FFFF              \ Jump to the routine whose address we just copied from
                        \ the tube_table, which will be the routine that
                        \ corresponds to this Tube command, and return from the
                        \ subroutine using a tail call

.return

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: tube_table
\       Type: Variable
\   Category: Tube
\    Summary: Lookup table for Tube commands sent from the parasite to the I/O
\             processor
\  Deep dive: Tube communication in Elite-A
\
\ ------------------------------------------------------------------------------
\
\ This table lists all the commands that can be sent from the parasite to the
\ I/O processor.
\
\ The hexadecimal number is the number of that command, and is the first byte to
\ be sent over the Tube. The parameters shown in brackets are sent next, in the
\ order shown, and if the command returns a result (denoted by a leading = sign
\ in the command name), then this is then sent back to the parasite.
\
\ Consider the following command, which scans the keyboard or Delta 14b keypad
\ for a specific flight key:
\
\   =scan_y(key_offset, delta_14b)
\
\ To run this command, the parasite would first send a value of &96 to the I/O
\ processor (using the tube_write routine), then it would send the key_offset
\ and delta_14b parameters (in that order), and finally it would wait for the
\ result to be returned by calling the tube_read routine.
\
\ Meanwhile, at the other end, the receipt of the &96 value would trigger a call
\ to the routine in WRCHV, which is the tube_wrch routine. This routine sees
\ that the received value is greater than 127, so it calls the tube_func
\ routine, which then looks up the corresponding routine from this table
\ (routine scan_y in this case) and calls it to implement the command. The
\ scan_y routine then fetches the parameter values using the tube_get routine,
\ performs the keyboard or keypad scan according to the command's parameters,
\ and finally sends the result back to the parasite using the tube_put routine.
\
\ ******************************************************************************

.tube_table

 EQUW LL30              \ &80   draw_line(x1, y1, x2, y2)
 EQUW HLOIN             \ &81   draw_hline(x1, y1, x2)
 EQUW PIXEL             \ &82   draw_pixel(x, y, distance)
 EQUW clr_scrn          \ &83   clr_scrn()
 EQUW CLYNS             \ &84   clr_line()
 EQUW sync_in           \ &85   =sync_in()
 EQUW DILX              \ &86   draw_bar(value, colour, screen_low, screen_high)
 EQUW DIL2              \ &87   draw_angle(value, screen_low, screen_high)
 EQUW MSBAR             \ &88   put_missle(number, colour)
 EQUW scan_fire         \ &89   =scan_fire()
 EQUW write_fe4e        \ &8A   =write_fe4e(value)
 EQUW scan_xin          \ &8B   =scan_xin(key_number)
 EQUW scan_10in         \ &8C   =scan_10in()
 EQUW get_key           \ &8D   =get_key()
 EQUW CHPR              \ &8E   write_xyc(x, y, char)
 EQUW write_pod         \ &8F   write_pod(escp, hfx)
 EQUW draw_blob         \ &90   draw_blob(x, y, colour)
 EQUW draw_tail         \ &91   draw_tail(x, y, base_colour, alt_colour, height)
 EQUW SPBLB             \ &92   draw_S()
 EQUW ECBLB             \ &93   draw_E()
 EQUW UNWISE            \ &94   draw_mode()
 EQUW DET1              \ &95   write_crtc(rows)
 EQUW scan_y            \ &96   =scan_y(key_offset, delta_14b)
 EQUW write_0346        \ &97   write_0346(value)
 EQUW read_0346         \ &98   =read_0346()
 EQUW return            \ &99   return()
 EQUW HANGER            \ &9A   picture_h(line_count, multiple_ships)
 EQUW HA2               \ &9B   picture_v(line_count)

\ ******************************************************************************
\
\       Name: CHPR
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the write_xyc command (write a character to the screen)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a write_xyc command. It writes a
\ text character to the screen at specified position. If the character is null
\ (i.e. A = 0) then it just moves the text cursor and doesn't print anything.
\
\ ******************************************************************************

.CHPR

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA XC                 \
 JSR tube_get           \   write_xyc(x, y, char)
 STA YC                 \
 JSR tube_get           \ and store them as follows:
                        \
                        \   * XC = text column (x-coordinate)
                        \
                        \   * YC = text row (y-coordinate)
                        \
                        \   * A = the character to print

 CMP #' '               \ If we are not printing a space character, jump to
 BNE tube_wrch          \ tube_wrch to print the character, returning from the
                        \ subroutine using a tail call

 LDA #9                 \ We are printing a space, so set A to 9 and fall
                        \ through into tube_wrch to print the character

\ ******************************************************************************
\
\       Name: tube_wrch
\       Type: Subroutine
\   Category: Text
\    Summary: Write characters to the screen and process Tube commands from the
\             parasite
\  Deep dive: Tube communication in Elite-A
\
\ ------------------------------------------------------------------------------
\
\ This routine prints characters to the screen.
\
\ It also processes Tube commands from the parasite, because those commands are
\ sent over the Tube via FIFO 1, and Acorn's Tube host code considers arrivals
\ on FIFO 1 to be OSWRCH commands executed on the parasite, and calls the WRCHV
\ handler to implement the call. We already set WRCHV to point here in the
\ tube_elite routine, so when the I/O processor receives a byte from the
\ parasite over FIFO 1, the Tube host code calls this routine.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 0 (do not print anything)
\
\                         * 9 (space)
\
\                         * 10 (line feed)
\
\                         * 13 (carriage return)
\
\                         * 32 (space, but do not print anything if it's on
\                           column 17, so the disc catalogue will fit on-screen)
\
\                         * 33-126 (ASCII capital letters, numbers and
\                           punctuation)
\
\                         * 127 (delete the character to the left of the text
\                           cursor and move the cursor to the left)
\
\                         * 128-255 (Tube command &80-&FF)
\
\ ******************************************************************************

.tube_wrch

 STA K3                 \ Store the A, X and Y registers, so we can restore
 STX XSAV2              \ them at the end (so they don't get changed by this
 STY YSAV2              \ routine)

 TAY                    \ Copy the character to be printed from A into Y

 BMI tube_func          \ If bit 7 of the character is set (i.e. A >= 128) then
                        \ this is a Tube command rather than a printable
                        \ character, so jump to tube_func to process it

 BEQ wrch_quit          \ If A = 0 then there is no character to print, so jump
                        \ to wrch_quit to return from the subroutine

 CMP #127               \ If A = 127 then this is a delete character, so jump
 BEQ wrch_del           \ to wrch_del to erase the character to the left of the
                        \ cursor

 CMP #32                \ If A = 32 then this is a space character, so jump to
 BEQ wrch_spc           \ wrch_spc to move the text cursor to the right

 BCS wrch_char          \ If this is an ASCII character (A > 32), jump to
                        \ wrch_char to print the character on-screen

 CMP #10                \ If A = 10 then this is a line feed, so jump to wrch_nl
 BEQ wrch_nl            \ to move the text cursor down a line

 CMP #13                \ If A = 13 then this is a carriage return, so jump to
 BEQ wrch_cr            \ wrch_cr to move the text cursor to the start of the
                        \ line

 CMP #9                 \ If A <> 9 then this isn't a character we can print,
 BNE wrch_quit          \ so jump to wrch_quit to return from the subroutine

                        \ If we get here then A = 9, which is a space character

.wrch_tab

 INC XC                 \ Move the text cursor to the right by 1 column

.wrch_quit

 LDY YSAV2              \ Restore the values of the A, X and Y registers that we
 LDX XSAV2              \ saved above
 LDA K3

 RTS                    \ Return from the subroutine

.wrch_char

                        \ If we get here then we want to print the character in
                        \ A onto the screen

 JSR wrch_font          \ Call wrch_font to set the following:
                        \
                        \   * font(1 0) points to the character definition of
                        \     the character to print in A
                        \
                        \   * SC(1 0) points to the screen address where we
                        \     should print the character

                        \ Now to actually print the character

 INC XC                 \ Once we print the character, we want to move the text
                        \ cursor to the right, so we do this by incrementing
                        \ XC. Note that this doesn't have anything to do
                        \ with the actual printing below, we're just updating
                        \ the cursor so it's in the right position following
                        \ the print

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.wrch_or

 LDA (font),Y           \ The character definition is at font(1 0), so load the
                        \ Y-th byte from font(1 0), which will contain the
                        \ bitmap for the Y-th row of the character

 EOR (SC),Y             \ If we EOR this value with the existing screen
                        \ contents, then it's reversible (so reprinting the
                        \ same character in the same place will revert the
                        \ screen to what it looked like before we printed
                        \ anything); this means that printing a white pixel on
                        \ onto a white background results in a black pixel, but
                        \ that's a small price to pay for easily erasable text

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL wrch_or            \ Loop back for the next byte to print to the screen

 BMI wrch_quit          \ Jump to wrch_quit to return from the subroutine (the
                        \ BMI is effectively a JMP as we just passed through a
                        \ BPL instruction)

.wrch_del

                        \ If we get here then we want to delete the character to
                        \ the left of the text cursor, which we can do by
                        \ printing a space over the top of it

 DEC XC                 \ We want to delete the character to the left of the
                        \ text cursor and move the cursor back one, so let's
                        \ do that by decrementing YC. Note that this doesn't
                        \ have anything to do with the actual deletion below,
                        \ we're just updating the cursor so it's in the right
                        \ position following the deletion

 LDA #' '               \ Call wrch_font to set the following:
 JSR wrch_font          \
                        \   * font(1 0) points to the character definition of
                        \     the space character
                        \
                        \   * SC(1 0) points to the screen address where we
                        \     should print the space

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.wrch_sta

 LDA (font),Y           \ The character definition is at font(1 0), so load the
                        \ Y-th byte from font(1 0), which will contain the
                        \ bitmap for the Y-th row of the space character

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL wrch_sta           \ Loop back for the next byte to print to the screen

 BMI wrch_quit          \ Jump to wrch_quit to return from the subroutine (the
                        \ BMI is effectively a JMP as we just passed through a
                        \ BPL instruction)

.wrch_nl

                        \ If we get here then we want to print a line feed

 INC YC                 \ Print a line feed, simply by incrementing the row
                        \ number (y-coordinate) of the text cursor, which is
                        \ stored in YC

 JMP wrch_quit          \ Jump to wrch_quit to return from the subroutine

.wrch_cr

                        \ If we get here then we want to print a carriage return

 LDA #1                 \ Print a carriage return by returning the text cursor
 STA XC                 \ to the start of the line, i.e. column 1

 JMP wrch_quit          \ Jump to wrch_quit to return from the subroutine

.wrch_spc

                        \ If we get here then we want to print a space, but not
                        \ if we are in column 17 (this is so the disc catalogue
                        \ will fit on-screen, and performs the same duty as the
                        \ CATF flag in the disc version)

 LDA XC                 \ If the text cursor is in column 32, then we are
 CMP #32                \ already at the right edge of the screen and can't
 BEQ wrch_quit          \ print a space, so jump to wrch_quit to return from
                        \ the subroutine

 CMP #17                \ If the text cursor is in column 17, then we want to
 BEQ wrch_quit          \ omit this space, so jump to wrch_quit to return from
                        \ the subroutine

 BNE wrch_tab           \ Otherwise jump to wrch_tab to move the cursor right by
                        \ one character (the BNE is effectively a JMP as we just
                        \ passed through a BEQ)

\ ******************************************************************************
\
\       Name: wrch_font
\       Type: Subroutine
\   Category: Text
\    Summary: Set the font and screen address for printing characters on-screen
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to be printed (ASCII)
\
\ Returns:
\
\   font(1 0)           The address of the MOS character definition of the
\                       character to be printed
\
\   SC(1 0)             The screen address where we should print the character
\                       (i.e. the screen address of the text cursor)
\
\ ******************************************************************************

.wrch_font

 LDX #&BF               \ Set X to point to the first font page in ROM minus 1,
                        \ which is &C0 - 1, or &BF

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC font_c0

 LDX #&C1               \ A is 64-126, so set X to point to page &C1

.font_c0

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC font_cl            \ then skip the following instruction

 INX                    \ Increment X
                        \
                        \ By this point, we started with X = &BF, and then
                        \ we did the following:
                        \
                        \   If A = 32-63:   skip    then INX  so X = &C0
                        \   If A = 64-95:   X = &C1 then skip so X = &C1
                        \   If A = 96-126:  X = &C1 then INX  so X = &C2
                        \
                        \ In other words, X points to the relevant page. But
                        \ what about the value of A? That gets shifted to the
                        \ left three times during the above code, which
                        \ multiplies the number by 8 but also drops bits 7, 6
                        \ and 5 in the process. Look at the above binary
                        \ figures and you can see that if we cleared bits 5-7,
                        \ then that would change 32-53 to 0-31... but it would
                        \ do exactly the same to 64-95 and 96-125. And because
                        \ we also multiply this figure by 8, A now points to
                        \ the start of the character's definition within its
                        \ page (because there are 8 bytes per character
                        \ definition)
                        \
                        \ Or, to put it another way, X contains the high byte
                        \ (the page) of the address of the definition that we
                        \ want, while A contains the low byte (the offset into
                        \ the page) of the address

.font_cl

 STA font               \ Store the address of this character's definition in
 STX font+1             \ font(1 0)

 LDA XC                 \ Fetch XC, the x-coordinate (column) of the text cursor
                        \ into A

 ASL A                  \ Multiply A by 8, and store in SC. As each character is
 ASL A                  \ 8 pixels wide, and the special screen mode Elite uses
 ASL A                  \ for the top part of the screen is 256 pixels across
 STA SC                 \ with one bit per pixel, this value is not only the
                        \ screen address offset of the text cursor from the left
                        \ side of the screen, it's also the least significant
                        \ byte of the screen address where we want to print this
                        \ character, as each row of on-screen pixels corresponds
                        \ to one page. To put this more explicitly, the screen
                        \ starts at &6000, so the text rows are stored in screen
                        \ memory like this:
                        \
                        \   Row 1: &6000 - &60FF    YC = 1, XC = 0 to 31
                        \   Row 2: &6100 - &61FF    YC = 2, XC = 0 to 31
                        \   Row 3: &6200 - &62FF    YC = 3, XC = 0 to 31
                        \
                        \ and so on

 LDA YC                 \ Fetch YC, the y-coordinate (row) of the text cursor

 ORA #&60               \ We already stored the least significant byte
                        \ of this screen address in SC above (see the STA SC
                        \ instruction above), so all we need is the most
                        \ significant byte. As mentioned above, in Elite's
                        \ square mode 4 screen, each row of text on-screen
                        \ takes up exactly one page, so the first row is page
                        \ &60xx, the second row is page &61xx, so we can get
                        \ the page for character (XC, YC) by OR'ing with &60.
                        \ To see this in action, consider that our two values
                        \ are, in binary:
                        \
                        \   YC is between:  %00000000
                        \             and:  %00010111
                        \          &60 is:  %01100000
                        \
                        \ so YC OR &60 effectively adds &60 to YC, giving us
                        \ the page number that we want

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 RTS                    \ Return from the subroutine

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
\    Summary: Implement the draw_line command (draw a line)
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_line command. It draws a
\ line from (X1, Y1) to (X2, Y2). It has multiple stages.
\
\ This stage calculates the line deltas.
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
\ ******************************************************************************

.LL30

 SKIP 0                 \ LL30 is a synomym for LOIN
                        \
                        \ In the cassette and disc versions of Elite, LL30 and
                        \ LOIN are synonyms for the same routine, presumably
                        \ because the two developers each had their own line
                        \ routines to start with, and then chose one of them for
                        \ the final game

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA X1                 \
 JSR tube_get           \   draw_line(x1, y1, x2, y2)
 STA Y1                 \
 JSR tube_get           \ and store them as follows:
 STA X2                 \
 JSR tube_get           \   * X1 = the start point's x-coordinate
 STA Y2                 \
                        \   * Y1 = the start point's y-coordinate
                        \
                        \   * X2 = the end point's x-coordinate
                        \
                        \   * Y2 = the end point's y-coordinate

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
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right, omitting the
\     first pixel
\
\ ******************************************************************************

 LDA SWAP               \ If SWAP > 0 then we swapped the coordinates above, so
 BNE LI6                \ jump down to LI6 to skip plotting the first pixel
                        \
                        \ This appears to be a bug that omits the last pixel
                        \ of this type of shallow line, rather than the first
                        \ pixel, which makes the treatment of this kind of line
                        \ different to the other kinds of slope (they all have a
                        \ BEQ instruction at this point, rather than a BNE)
                        \
                        \ The result is a rather messy line join when a shallow
                        \ line that goes right and up or left and down joins a
                        \ line with any of the other three types of slope
                        \
                        \ This bug was fixed in the advanced versions of ELite,
                        \ where the BNE is replaced by a BEQ to bring it in line
                        \ with the other three slopes

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
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right, omitting the
\     first pixel
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
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right, omitting the
\     first pixel
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

 LDA S                  \ Set S = S + P to update the slope error
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
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right, omitting the
\     first pixel
\
\ Other entry points:
\
\   HL6                 Contains an RTS
\
\ ******************************************************************************

.LFT

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI18               \ so jump down to LI18 to skip plotting the first pixel

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
\    Summary: Implement the draw_hline command (draw a horizontal line
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_hline command. It draws a
\ horizontal line.
\
\ We do not draw a pixel at the right end of the line.
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

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA X1                 \
 JSR tube_get           \   draw_hline(x1, y1, x2)
 STA Y1                 \
 JSR tube_get           \ and store them as follows:
 STA X2                 \
                        \   * X1 = the start point's x-coordinate
                        \
                        \   * Y1 = the horizontal line's y-coordinate
                        \
                        \   * X2 = the end point's x-coordinate

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
\    Summary: Implement the draw_pixel command (draw space view pixels)
\  Deep dive: Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_pixel command. It draws a
\ dot in the space view.
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

 JSR tube_get           \ Get the parameters from the parasite for the command:
 TAX                    \
 JSR tube_get           \   draw_pixel(x, y, distance)
 TAY                    \
 JSR tube_get           \ and store them as follows:
 STA ZZ                 \
                        \   * X = the pixel's x-coordinate
                        \
                        \   * Y = the pixel's y-coordinate
                        \
                        \   * ZZ = the pixel's distance

 TYA                    \ Copy the pixel's y-coordinate from Y into A

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
\    Summary: Clear the top part of the screen (the space view)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a clr_scrn command. It clears the
\ top part of the screen (the mode 4 space view).
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
                        \ screen (the top part)

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
\ This routine is run when the parasite sends a clr_line command. It clears some
\ space at the bottom of the screen and moves the text cursor to column 1, row
\ 21.
\
\ Specifically, it zeroes the following screen locations:
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
\    Summary: Implement the sync_in command (wait for the vertical sync)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a sync_in command. It waits for
\ the next vertical sync and returns a value to the parasite so it can wait
\ until the sync occurs. The value returned to the parasite isn't important, as
\ it's just about the timing of the response.
\
\ ******************************************************************************

.sync_in

 JSR WSCAN              \ Call WSCAN to wait for the vertical sync

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

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
\    Summary: Implement the draw_bar command (update a bar-based indicator on
\             the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_bar command. It updates a
\ bar-based indicator on the dashboard.
\
\ The range of values shown on the indicator depends on which entry point is
\ called. For the default entry point of DILX, the range is 0-255 (as the value
\ passed in A is one byte). The other entry points are shown below.
\
\ ******************************************************************************

.DILX

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA bar_1              \
 JSR tube_get           \   draw_bar(value, colour, screen_low, screen_high)
 STA bar_2              \
 JSR tube_get           \ and store them as follows:
 STA SC                 \
 JSR tube_get           \   * bar_1 = the value to display in the indicator
 STA SC+1               \
                        \   * bar_2 = the mode 5 colour of the indicator
                        \
                        \   * SC(1 0) = the screen address of the indicator

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
\    Summary: Implement the draw_angle command (update the roll or pitch
\             indicator on the dashboard)
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_angle command. It updates
\ the roll or pitch indicator on the dashboard.
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

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA angle_1            \
 JSR tube_get           \   draw_angle(value, screen_low, screen_high)
 STA SC                 \
 JSR tube_get           \ and store them as follows:
 STA SC+1               \
                        \   * angle_1 = the value to display in the indicator
                        \
                        \   * SC(1 0) = the screen address of the indicator

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
\    Summary: Implement the put_missle command (update a missile indicator on
\             the dashboard)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a put_missle command. It updates
\ a specified missile indicator on the dashboard to the specified colour.
\
\ ******************************************************************************

.MSBAR

 JSR tube_get           \ Get the first parameter from the parasite for the
                        \ command:
                        \
                        \   put_missle(number, colour)
                        \
                        \ and store it as follows:
                        \
                        \   * A = missile number

 ASL A                  \ Set missle_1 = A * 8
 ASL A
 ASL A
 STA missle_1

 LDA #41                \ Set SC = 41 - missle_1
 SBC missle_1           \        = 40 + 1 - (A * 8)
 STA SC                 \        = 48 + 1 - ((A + 1) * 8)
                        \
                        \ This is the same calculation as in the disc version's
                        \ MSBAR routine, but because the missile number in the
                        \ Elite-A version is in the range 0-3 rather than 1-3,
                        \ we subtract from 41 instead of 49 to get the screen
                        \ address

                        \ So the low byte of SC(1 0) contains the row address
                        \ for the rightmost missile indicator, made up as
                        \ follows:
                        \
                        \   * 48 (character block 7, as byte #7 * 8 = 48), the
                        \     character block of the rightmost missile
                        \
                        \   * 1 (so we start drawing on the second row of the
                        \     character block)
                        \
                        \   * Move right one character (8 bytes) for each count
                        \     of A, so when A = 0 we are drawing the rightmost
                        \     missile, for A = 1 we hop to the left by one
                        \     character, and so on

 LDA #&7E               \ Set the high byte of SC(1 0) to &7E, the character row
 STA SC+1               \ that contains the missile indicators (i.e. the bottom
                        \ row of the screen)

 JSR tube_get           \ Get the second parameter from the parasite for the
                        \ command:
                        \
                        \   put_missle(number, colour)
                        \
                        \ and store it as follows:
                        \
                        \   * A = new colour for this indicator

 LDY #5                 \ We now want to draw this line five times to do the
                        \ left two pixels of the indicator, so set a counter in
                        \ Y

.MBL1

 STA (SC),Y             \ Draw the 3-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

 DEY                    \ Decrement the counter for the next row

 BNE MBL1               \ Loop back to MBL1 if have more rows to draw

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: scan_fire
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the scan_fire command (scan the joystick's fire button)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a scan_fire command. It checks the
\ joystick's fire button and returns a value to the parasite with bit 4 clear if
\ the joystick's fire button is being pressed, or bit 4 set if it isn't.
\
\ ******************************************************************************

.scan_fire

 LDA #&51               \ Set 6522 User VIA output register ORB (SHEILA &60) to
 STA VIA+&60            \ the Delta 14b joystick button in the middle column
                        \ (upper nibble &5) and top row (lower nibble &1), which
                        \ corresponds to the fire button

 LDA VIA+&40            \ Read 6522 System VIA input register IRB (SHEILA &40)

 AND #%00010000         \ Bit 4 of IRB (PB4) is clear if joystick 1's fire
                        \ button is pressed, otherwise it is set, so AND'ing
                        \ the value of IRB with %10000 extracts this bit

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: write_fe4e
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the write_fe4e command (update the System VIA interrupt
\             enable register)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a write_fe4e command. It updates
\ the System VIA interrupt enable register in the I/O processor to the value
\ sent by the parasite, and returns that value back to the parasite once the
\ register has been set, so the parasite can know when the register has been
\ updated.
\
\ ******************************************************************************

.write_fe4e

 JSR tube_get           \ Get the parameter from the parasite for the command:
                        \
                        \   =write_fe4e(value)
                        \
                        \ and store it as follows:
                        \
                        \   * A = new value for the interrupt register

 STA VIA+&4E            \ Set 6522 System VIA interrupt enable register IER
                        \ (SHEILA &4E) to the new value

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: scan_xin
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the scan_xin command (scan the keyboard for a specific
\             key press)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a scan_xin command. It scans the
\ keyboard to see if the specified key is being pressed and returns the result
\ to the parasite as follows. If the key is being pressed, the result contains
\ the original key number in but with bit 7 set (i.e. key number +128). If the
\ key is not being pressed, the result contains the unchanged key number.
\
\ ******************************************************************************

.scan_xin

 JSR tube_get           \ Get the parameter from the parasite for the command:
 TAX                    \
                        \ =scan_xin(key_number)
                        \
                        \ and store it as follows:
                        \
                        \   * X = the internal key number to scan for

 JSR DKS4               \ Scan the keyboard to see if the key in X is currently
                        \ being pressed, returning the result in A and X

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

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
\    Summary: Implement the scan_10in command (scan the keyboard)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a scan_10in command. It scans the
\ keyboard for a key press and returns the internal key number of the key being
\ to the parasite (or it returns 0 if no keys are being pressed).
\
\ ******************************************************************************

.scan_10in

 JSR RDKEY              \ Scan the keyboard for a key press and return the
                        \ internal key number in X (or 0 for no key press)

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

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
\ If CTRL-P is pressed, then the routine calls the printer routine to print the
\ screen, and returns 0 in A and X.
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

 CMP #&37               \ If "P" was not pressed, jump to scan_test to return
 BNE scan_test          \ the key press

 LDX #1                 \ Set X to the internal key number for CTRL

 JSR DKS4               \ Scan the keyboard to see if the key in X (i.e. CTRL)
                        \ is currently pressed

 BPL scan_p             \ If it is not being pressed, jump to scan_p to return
                        \ "P" as the key press

 JSR printer            \ CTRL-P was pressed, so call printer to output the
                        \ screen to the printer

 LDA #0                 \ Set A to 0 to return no key press from the routine, as
                        \ we already acted on it

 RTS                    \ Return from the subroutine

.scan_p

 LDA #&37               \ Set A to the internal key number for "P", to return as
                        \ the result

.scan_test

 TAX                    \ Copy the key value into X

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: get_key
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the get_key command (wait for a key press)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a get_key command. It waits until
\ a key is pressed, and returns the key's ASCII code to the parasite.
\
\ If, on entry, a key is already being held down, then it waits until that key
\ is released first, so this routine detects the first key down event following
\ the receipt of the get_key command.
\
\ ******************************************************************************

.get_key

 JSR WSCAN              \ Call WSCAN twice to wait for two vertical syncs
 JSR WSCAN

 JSR RDKEY              \ Scan the keyboard for a key press and return the
                        \ internal key number in X (or 0 for no key press)

 BNE get_key            \ If a key was already being held down when we entered
                        \ this routine, keep looping back up to get_key, until
                        \ the key is released

.press

 JSR RDKEY              \ Any pre-existing key press is now gone, so we can
                        \ start scanning the keyboard again, returning the
                        \ internal key number in X (or 0 for no key press)

 BEQ press              \ Keep looping up to press until a key is pressed

 TAY                    \ Copy A to Y, so Y contains the internal key number
                        \ of the key pressed

 LDA (key_tube),Y       \ The address in key_tube points to the MOS key
                        \ translation table in the I/O processor, which is used
                        \ to translate internal key numbers to ASCII, so this
                        \ fetches the key's ASCII code into A

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: write_pod
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the write_pod command (show the correct palette for the
\             dashboard and hyperspace tunnel)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a write_pod command. It sets the
\ I/O processor's ESCP and HFX flags to ensure that the correct palette is
\ shown for the dashboard and hyperspace tunnel (ESCP affects the dashboard and
\ HFX affects the hyperspace tunnel).
\
\ ******************************************************************************

.write_pod

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA ESCP               \
 JSR tube_get           \   write_pod(escp, hfx)
 STA HFX                \
                        \ and store them as follows:
                        \
                        \   * ESCP = the new value of ESCP
                        \
                        \   * HFX = the new value of HFX

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: draw_blob
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Implement the draw_blob command (draw a single-height dash on the
\             dashboard)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_blob command. It draws a
\ single-height dash on the dashboard.
\
\ ******************************************************************************

.draw_blob

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA X1                 \
 JSR tube_get           \   draw_blob(x, y, colour)
 STA Y1                 \
 JSR tube_get           \ and store them as follows:
 STA COL                \
                        \   * X1 = the dash's x-coordinate
                        \
                        \   * Y1 = the dash's y-coordinate
                        \
                        \   * COL = the dash's colour

                        \ Fall through into CPIX2 to draw a single-height dash
                        \ at the above coordinates and in the specified colour

\ ******************************************************************************
\
\       Name: CPIX2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single-height dash on the dashboard
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
\    Summary: Implement the draw_tail command (draw a ship on the 3D scanner)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_tail command. It draws a
\ ship on the 3D scanner, as a dot and (if applicable) a tail, using the base
\ and alternating colours specified (so it can draw a striped tail for when an
\ I.F.F. system is fitted).
\
\ ******************************************************************************

.draw_tail

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA X1                 \
 JSR tube_get           \   draw_tail(x, y, base_colour, alt_colour, height)
 STA Y1                 \
 JSR tube_get           \ and store them as follows:
 STA COL                \
 JSR tube_get           \   * X1 = ship's screen x-coordinate on the scanner
 STA Y2                 \
 JSR tube_get           \   * Y1 = ship's screen y-coordinate on the scanner
 STA P                  \
                        \   * COL = base colour
                        \
                        \   * Y2 = alternating (EOR) colour
                        \
                        \   * P = stick height

.SC48

 JSR CPIX2              \ Call CPIX2 to draw a single-height dash at (X1, Y1)

 DEC Y1                 \ Decrement the y-coordinate in Y1 so the next call to
                        \ CPIX2 draws another dash on the line above, resulting
                        \ in a double-height dash

 JSR CPIX2              \ Call CPIX2 to draw a single-height dash at (X1, Y1)

                        \ These calls also leave the following variables set up
                        \ for the dot's top-right pixel, the last pixel to be
                        \ drawn by the second call to CPIX2:
                        \
                        \   SC(1 0) = screen address of the pixel's character
                        \             block
                        \
                        \   Y = number of the character row containing the pixel
                        \
                        \   X = the pixel's number (0-3) in that row
                        \
                        \ We can use there as the starting point for drawing the
                        \ stick, if there is one

 LDA CTWOS+1,X          \ Load the same mode 5 1-pixel byte that we just used
 AND COL                \ for the top-right pixel, mask it with the base colour
 STA COL                \ in COL, and store the result in COL, so we can use it
                        \ as the character row byte for the base colour stripes
                        \ in the stick

 LDA CTWOS+1,X          \ Load the same mode 5 1-pixel byte that we just used
 AND Y2                 \ for the top-right pixel, mask it with the EOR colour
 STA Y2                 \ in Y2, and store the result in Y2, so we can use it
                        \ as the character row byte for the alternate colour
                        \ stripes in the stick

 LDX P                  \ Fetch the stick height from P into X

 BEQ RTS                \ If the stick height is zero, then there is no stick to
                        \ draw, so return from the subroutine (as RTS contains
                        \ an RTS)

 BMI RTS+1              \ If the stick height in A is negative, jump down to
                        \ RTS+1

.VLL1

                        \ If we get here then the stick length is positive (so
                        \ the dot is below the ellipse and the stick is above
                        \ the dot, and we need to draw the stick upwards from
                        \ the dot)

 DEY                    \ We want to draw the stick upwards, so decrement the
                        \ pixel row in Y

 BPL VL1                \ If Y is still positive then it correctly points at the
                        \ line above, so jump to VL1 to skip the following

 LDY #7                 \ We just decremented Y up through the top of the
                        \ character block, so we need to move it to the last row
                        \ in the character above, so set Y to 7, the number of
                        \ the last row

 DEC SC+1               \ Decrement the high byte of the screen address to move
                        \ to the character block above

.VL1

 LDA COL                \ Set A to the character row byte for the stick, which
                        \ we stored in COL above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR Y2                 \ Apply the alternating colour in Y2 to the stick

 STA COL                \ Update the value in COL so the alternating colour is
                        \ applied every other row (as doing an EOR twice
                        \ reverses it)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y             \ EOR logic

 DEX                    \ Decrement the (positive) stick height in X

 BNE VLL1               \ If we still have more stick to draw, jump up to VLL1
                        \ to draw the next pixel

.RTS

 RTS                    \ Return from the subroutine

                        \ If we get here then the stick length is negative (so
                        \ the dot is above the ellipse and the stick is below
                        \ the dot, and we need to draw the stick downwards from
                        \ the dot)

 INY                    \ We want to draw the stick downwards, so we first
                        \ increment the row counter so that it's pointing to the
                        \ bottom-right pixel in the dot (as opposed to the top-
                        \ right pixel that the call to CPIX4 finished on)

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE P%+6               \ correctly points at the next line down, so jump to
                        \ VLL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address to move
                        \ to the character block above

.VLL2

 INY                    \ We want to draw the stick itself, heading downwards,
                        \ so increment the pixel row in Y

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE VL2                \ correctly points at the next line down, so jump to
                        \ VL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address to move
                        \ to the character block above

.VL2

 LDA COL                \ Set A to the character row byte for the stick, which
                        \ we stored in COL above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR Y2                 \ Apply the alternating colour in Y2 to the stick

 STA COL                \ Update the value in COL so the alternating colour is
                        \ applied every other row (as doing an EOR twice
                        \ reverses it)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y             \ EOR logic

 INX                    \ Increment the (negative) stick height in X

 BNE VLL2               \ If we still have more stick to draw, jump up to VLL2
                        \ to draw the next pixel

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ECBLB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Light up the E.C.M. indicator bulb ("E") on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_E command. It lights up the
\ E.C.M. indicator bulb ("E") on the dashboard.
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
\    Summary: Light up the space station indicator ("S") on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a draw_S command. It lights up the
\ space station indicator ("S") on the dashboard.
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
\ Other entry points:
\
\   BULB-2              Set the Y screen address
\
\ ******************************************************************************

.BULB

 STA SC                 \ Store the low byte of the screen address in SC

 LDA #&7D               \ Set A to the high byte of the screen address, which is
                        \ &7D as the bulbs are both in the character row from
                        \ &7D00 to &7DFF

 STA SC+1               \ Set the high byte of SC(1 0) to &7D, so SC now points
                        \ to the screen address of the bulb we want to draw

 STX font               \ Set font(1 0) = (Y X)
 STY font+1

 LDY #7                 \ We now want to draw the bulb by copying the bulb
                        \ character definition from font(1 0) into the screen
                        \ address at SC(1 0), so set a counter in Y to work
                        \ through the eight bytes (one per row) in the bulb

.ECBLBor

 LDA (font),Y           \ Fetch the Y-th row of the bulb character definition
                        \ from font(1 0)

 EOR (SC),Y             \ Draw the row on-screen using EOR logic, so if the bulb
 STA (SC),Y             \ is already on-screen this will remove it, otherwise it
                        \ will light the bulb up

 DEY                    \ Decrement the row counter

 BPL ECBLBor            \ Loop back to ECBLBor until we have drawn all 8 rows of
                        \ the bulb

 RTS                    \ Return from the subroutine

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
\ This routine is run when the parasite sends a draw_mode command. It toggles
\ the main line-drawing routine between EOR and OR logic, for use when drawing
\ the ship hanger.
\
\ It does this by modifying the instructions in the main line-drawing routine at
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

 LDA LIL2+2             \ Flip bit 6 of LIL2+2 to change the EOR (SC),Y in LIL2
 EOR #%01000000         \ to an ORA (SC),Y (or back again)
 STA LIL2+2

 STA LIL3+2             \ Change the EOR (SC),Y in LIL3 to an ORA (SC),Y (or
                        \ back again)

 STA LIL5+2             \ Change the EOR (SC),Y in LIL5 to an ORA (SC),Y (or
                        \ back again)

 STA LIL6+2             \ Change the EOR (SC),Y in LIL6 to an ORA (SC),Y (or
                        \ back again)

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
\ This routine is run when the parasite sends a write_crtc command. It updates
\ the number of text rows shown on the screen, which has the effect of hiding or
\ showing the dashboard.
\
\ It is used when we are killed, as reducing the number of rows from the usual
\ 31 to 24 has the effect of hiding the dashboard, leaving a monochrome image
\ of ship debris and explosion clouds. Increasing the rows back up to 31 makes
\ the dashboard reappear, as the dashboard's screen memory doesn't get touched
\ by this process.
\
\ ******************************************************************************

.DET1

 JSR tube_get           \ Get the number of rows from the parasite into A

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
 EQUB &63               \ V         KYTB+15     Docking computer

 EQUB &37               \ P         KYTB+16     Cancel docking computer

\ ******************************************************************************
\
\       Name: b_table
\       Type: Variable
\   Category: Keyboard
\    Summary: Lookup table for Delta 14b joystick buttons
\  Deep dive: Delta 14b joystick support
\
\ ------------------------------------------------------------------------------
\
\ In the following table, which maps buttons on the Delta 14b to the flight
\ controls, the high nibble of the value gives the column:
\
\   &6 = %110 = left column
\   &5 = %101 = middle column
\   &3 = %011 = right column
\
\ while the lower nibble gives the row:
\
\   &1 = %0001 = top row
\   &2 = %0010 = second row
\   &4 = %0100 = third row
\   &8 = %1000 = bottom row
\
\ This results in the following mapping (as the top two fire buttons are treated
\ the same as the top button in the middle row):
\
\   Fire laser                                    Fire laser
\
\   Slow down              Fire laser             Speed up
\   Unarm Missile          Fire Missile           Target missile
\   Hyperspace Unit        E.C.M.                 Escape pod
\   Docking computer on    In-system jump         Docking computer off
\
\ ******************************************************************************

.b_table

 EQUB &61               \ Left column    Top row      KYTB+1    Slow down
 EQUB &31               \ Right column   Top row      KYTB+2    Speed up
 EQUB &80               \ -                           KYTB+3    Roll left
 EQUB &80               \ -                           KYTB+4    Roll right
 EQUB &80               \ -                           KYTB+5    Pitch up
 EQUB &80               \ -                           KYTB+6    Pitch down
 EQUB &51               \ Middle column  Top row      KYTB+7    Fire lasers
 EQUB &64               \ Left column    Third row    KYTB+8    Hyperspace unit
 EQUB &34               \ Right column   Third row    KYTB+9    Escape pod
 EQUB &32               \ Right column   Second row   KYTB+10   Arm missile
 EQUB &62               \ Left column    Second row   KYTB+11   Unarm missile
 EQUB &52               \ Middle column  Second row   KYTB+12   Fire missile
 EQUB &54               \ Middle column  Third row    KYTB+13   E.C.M.
 EQUB &58               \ Middle column  Bottom row   KYTB+14   In-system jump
 EQUB &38               \ Right column   Bottom row   KYTB+15   Docking computer
 EQUB &68               \ Left column    Bottom row   KYTB+16   Cancel docking

\ ******************************************************************************
\
\       Name: b_14
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Scan the Delta 14b joystick buttons
\  Deep dive: Delta 14b joystick support
\
\ ------------------------------------------------------------------------------
\
\ Scan the Delta 14b for the flight key given in register Y, where Y is the
\ offset into the KYTB table above (so this is the same approach as in DKS1).
\
\ The keys on the Delta 14b are laid out as follows (the top two fire buttons
\ are treated the same as the top button in the middle row):
\
\   Fire laser                                    Fire laser
\
\   Slow down              Fire laser             Speed up
\   Unarm Missile          Fire Missile           Target missile
\   Hyperspace Unit        E.C.M.                 Escape pod
\   Docking computer on    In-system jump         Docking computer off
\
\ Arguments:
\
\   Y                   The offset into the KYTB table of the key that we want
\                       to scan on the Delta 14b
\
\ ******************************************************************************

.b_13

 LDA #0                 \ Set A = 0 for the second pass through the following,
                        \ so we can check the joystick plugged into the rear
                        \ socket of the Delta 14b adaptor

.b_14

                        \ This is the entry point for the routine, which is
                        \ called with A = 128 (the value of BTSK when the Delta
                        \ 14b is enabled), and if the key we are checking has a
                        \ corresponding button on the Delta 14b, it is run a
                        \ second time with A = 0

 TAX                    \ Store A in X so we can restore it below

 EOR b_table-1,Y        \ We now EOR the value in A with the Y-th entry in
 BEQ b_quit             \ b_table, and jump to b_quit to return from the
                        \ subroutine if the table entry is 128 (&80) - in other
                        \ words, we quit if Y is the offset for the roll and
                        \ pitch controls

                        \ If we get here, then the offset in Y points to a
                        \ control with a corresponding button on the Delta 14b,
                        \ and we pass through the following twice, once with a
                        \ starting value of A = 128, and again with a starting
                        \ value of A = 0
                        \
                        \ On the first pass, the EOR will set A to the value
                        \ from b_table but with bit 7 set, which means we scan
                        \ the joystick plugged into the side socket of the
                        \ Delta 14b adaptor
                        \
                        \ On the second pass, the EOR will set A to the value
                        \ from b_table (i.e. with bit 7 clear), which means we
                        \ scan the joystick plugged into the rear socket of the
                        \ Delta 14b adaptor

 STA VIA+&60            \ Set 6522 User VIA output register ORB (SHEILA &60) to
                        \ the value in A, which tells the Delta 14b adaptor box
                        \ that we want to read the buttons specified in PB4 to
                        \ PB7 (i.e. bits 4-7), as follows:
                        \
                        \ On the side socket joystick (bit 7 set):
                        \
                        \   %1110 = read buttons in left column   (bit 4 clear)
                        \   %1101 = read buttons in middle column (bit 5 clear)
                        \   %1011 = read buttons in right column  (bit 6 clear)
                        \
                        \ On the rear socket joystick (bit 7 clear):
                        \
                        \   %0110 = read buttons in left column   (bit 4 clear)
                        \   %0101 = read buttons in middle column (bit 5 clear)
                        \   %0011 = read buttons in right column  (bit 6 clear)

 AND #%00001111         \ We now read the 6522 User VIA to fetch PB0 to PB3 from
 AND VIA+&60            \ the user port (PB0 = bit 0 to PB3 = bit 3), which
                        \ tells us whether any buttons in the specified column
                        \ are being pressed, and if they are, in which row. The
                        \ values read are as follows:
                        \
                        \   %1111 = no button is being pressed in this column
                        \   %1110 = button pressed in top row    (bit 0 clear)
                        \   %1101 = button pressed in second row (bit 1 clear)
                        \   %1011 = button pressed in third row  (bit 2 clear)
                        \   %0111 = button pressed in bottom row (bit 3 clear)
                        \
                        \ In other words, if a button is being pressed in the
                        \ top row in the previously specified column, then PB0
                        \ (bit 0) will go low in the value we read from the user
                        \ port

 BEQ b_pressed          \ In the above we AND'd the result from the user port
                        \ with the bottom four bits of the table value (the
                        \ lower nibble). The lower nibble in b_table contains
                        \ a 1 in the relevant position for that row that
                        \ corresponds with the clear bit in the response from
                        \ the user port, so if we AND the two together and get
                        \ a zero, that means that button is being pressed, in
                        \ which case we jump to b_pressed to update the key
                        \ logger for that button
                        \
                        \ For example, take the b_table entry for the escape pod
                        \ button, in the right column and third row. The value
                        \ in b_table is &34. The high nibble denotes the column,
                        \ which is &3 = %011, which means in the STA VIA+&60
                        \ above, we write %1011 in the first pass (when A = 128)
                        \ to set the right column for the side socket joystick,
                        \ and we write %0011 in the first pass (when A = 0) to
                        \ set the right column for the rear socket joystick
                        \
                        \ Now for the row. The lower nibble of the &34 value
                        \ from b_table contains the row, so that's &4 = %0100.
                        \ When we read the user port, then we will fetch %1011
                        \ from VIA+&60 if the button in the third row is being
                        \ pressed, so when we AND the two together, we get:
                        \
                        \   %0100 AND %1011 = 0
                        \
                        \ which will indicate the button is being pressed. If
                        \ any other button is being pressed, or no buttons at
                        \ all, then the result will be non-zero and we move on
                        \ to the next buttton

 TXA                    \ Restore the original value of A that we stored in X

 BMI b_13               \ If we just did the above with A = 128, then loop back
                        \ to b_13 to do it again with A = 0

 BPL b_quit             \ Jump to b_quit to return the result over the Tube (the
                        \ BPL is effectively a JMP as we just passed through the
                        \ BMI above)

\ ******************************************************************************
\
\       Name: scan_y
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the scan_y command (scan for a specific flight key or
\             Delta 14b button press)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a scan_y command. If the game is
\ configured to use the keyboard or standard joystick, then it scans the
\ keyboard for a specified flight key (given as an offset into the KYTB table),
\ or if the game is configured to use the Delta 14b joystick, it scans the
\ Delta 14b keyboard for the relevant button press. It returns 0 to the parasite
\ if the key is not being pressed, or &FF if it is.
\
\ ******************************************************************************

.scan_y

 JSR tube_get           \ Get the parameters from the parasite for the command:
 TAY                    \
 JSR tube_get           \   =scan_y(key_offset, delta_14b)
                        \
                        \ and store them as follows:
                        \
                        \   * Y = the KYTB offset of the key to scan for (1 for
                        \         the first key, 2 for the second etc.)
                        \
                        \   * A = the configuration byte for the Delta 14b
                        \         joystick

 BMI b_14               \ If bit 7 of A is set, then the configuration byte for
                        \ the Delta 14b joystick in BTSK must be &FF and the
                        \ Delta 14b stick is configured for use, so jump to b_14
                        \ to scan the Delta 14b joystick buttons

                        \ If we get here then we know A = 0, as BTSK is either
                        \ 0 or &FF, and we just confirmed that it's not the
                        \ latter

 LDX KYTB-1,Y           \ Set X to the relevant internal key number from the
                        \ KYTB table (we add Y to KYTB-1 rather than KYTB as Y
                        \ is 1 for the first key in KYTB, 2 for the second key
                        \ and so on)

 JSR DKS4               \ Scan the keyboard to see if the key in X is currently
                        \ being pressed, returning the result in A and X

 BPL b_quit             \ If the key is being pressed then bit 7 will be set, so
                        \ this jumps to b_quit if the key is not being pressed,
                        \ in which case A = 0 will be returned to the parasite

.b_pressed

 LDA #&FF               \ The key is being pressed, so set A to &FF so we can
                        \ return it to the parasite

.b_quit

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: write_0346
\       Type: Subroutine
\   Category: Tube
\    Summary: Implement the write_0346 command (update LASCT)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a write_0346 command. It updates
\ the I/O processor's value of LASCT to the value sent by the parasite.
\
\ ******************************************************************************

.write_0346

 JSR tube_get           \ Get the parameter from the parasite for the command:
                        \
                        \   write_0346(value)
                        \
                        \ and store it as follows:
                        \
                        \   * A = the new value of LASCT

 STA LASCT              \ Update the value in LASCT to the value we just
                        \ received from the parasite

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: read_0346
\       Type: Subroutine
\   Category: Tube
\    Summary: Implement the read_0346 command (read LASCT)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a read_0346 command. It sends the
\ I/O processor's value of LASCT back to the parasite.
\
\ ******************************************************************************

.read_0346

 LDA LASCT              \ Fetch the current value of LASCT into A

 JMP tube_put           \ Send A back to the parasite and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: HANGER
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Implement the picture_h command (draw horizontal lines for the
\             ship hanger floor)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a picture_h command. It draws a
\ specified number of horizontal lines for the ship hanger's floor, making sure
\ it draws between the ships when there are multiple ships in the hanger.
\
\ ******************************************************************************

.HANGER

 JSR tube_get           \ Get the parameters from the parasite for the command:
 STA picture_1          \
 JSR tube_get           \   picture_h(line_count, multiple_ships)
 STA picture_2          \
                        \ and store them as follows:
                        \
                        \   * picture_1 = the number of horizontal lines to draw
                        \
                        \   * picture_2 = 0 if there is only one ship, non-zero
                        \                 otherwise

 LDA picture_1          \ Set Y = #Y + picture_1
 CLC                    \
 ADC #Y                 \ where #Y is the y-coordinate of the centre of the
                        \ screen, so Y is now the horizontal pixel row of the
                        \ line we want to draw to display the hanger floor

 LSR A                  \ Set A = A >> 3
 LSR A
 LSR A

 ORA #&60               \ Each character row in Elite's screen mode takes up one
                        \ page in memory (256 bytes), so we now OR with &60 to
                        \ get the page containing the line

 STA SC+1               \ Store the screen page in the high byte of SC(1 0)

 LDA picture_1          \ Set the low byte of SC(1 0) to the y-coordinate mod 7,
 AND #7                 \ which determines the pixel row in the character block
 STA SC                 \ we need to draw in (as each character row is 8 pixels
                        \ high), so SC(1 0) now points to the address of the
                        \ start of the horizontal line we want to draw

 LDY #0                 \ Set Y = 0 so the call to HAS2 starts drawing the line
                        \ in the first byte of the screen row, at the left edge
                        \ of the screen

 JSR HAS2               \ Draw a horizontal line from the left edge of the
                        \ screen, going right until we bump into something
                        \ already on-screen, at which point stop drawing

 LDA #%00000100         \ Now to draw the same line but from the right edge of
                        \ the screen, so set a pixel mask in A to check the
                        \ sixth pixel of the last byte, so we skip the 2-pixel
                        \ scren border at the right edge of the screen

 LDY #248               \ Set Y = 248 so the call to HAS3 starts drawing the
                        \ line in the last byte of the screen row, at the right
                        \ edge of the screen

 JSR HAS3               \ Draw a horizontal line from the right edge of the
                        \ screen, going left until we bump into something
                        \ already on-screen, at which point stop drawing

 LDY picture_2          \ Fetch the value of picture_2, which is 0 if there is
                        \ only one ship

 BEQ l_2045             \ If picture_2 is zero, jump to l_2045 to return from
                        \ the subroutine as there is only one ship in the
                        \ hanger, so we are done

 JSR HAS2               \ Call HAS2 to a line to the right, starting with the
                        \ third pixel of the pixel row at screen address SC(1 0)

 LDY #128               \ We now draw the line from the centre of the screen
                        \ to the left. SC(1 0) points to the start address of
                        \ the screen row, so we set Y to 128 so the call to
                        \ HAS3 starts drawing from halfway along the row (i.e.
                        \ from the centre of the screen)

 LDA #%01000000         \ We want to start drawing from the second pixel, to
                        \ avoid the border, so we set a pixel mask accordingly

 JSR HAS3               \ Call HAS3, which draws a line from the halfway point
                        \ across the left half of the screen, going left until
                        \ we bump into something already on-screen, at which
                        \ point it stops drawing

.l_2045

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HA2
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Implement the picture_v command (draw vertical lines for the ship
\             hanger background)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a picture_v command. It draws the
\ specified number of vertical lines for the ship hanger's background.
\
\ ******************************************************************************

.HA2

 JSR tube_get           \ Get the parameter from the parasite for the command:
                        \
                        \   picture_v(line_count)
                        \
                        \ and store it as follows:
                        \
                        \   * A = the number of vertical lines to draw

 AND #%11111000         \ Each character block contains 8 pixel rows, so to get
                        \ the address of the first byte in the character block
                        \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-2

 STA SC                 \ Set the low byte of SC(1 0) to this value

 LDX #&60               \ Set the high byte of SC(1 0) to &60, the high byte of
 STX SC+1               \ the start of screen, so SC(1 0) now points to the
                        \ address where the line starts

 LDX #%10000000         \ Set a mask in X to the first pixel the 8-pixel byte

 LDY #1                 \ We are going to start drawing the line from the second
                        \ pixel from the top (to avoid drawing on the 1-pixel
                        \ border), so set Y to 1 to point to the second row in
                        \ the first character block

.HAL7

 TXA                    \ Copy the pixel mask to A

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA6                \ mask), then this means it already contains something,
                        \ so jump to HA6 to stop drawing this line

 TXA                    \ Copy the pixel mask to A again

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set

 STA (SC),Y             \ Store the updated pixel in screen memory

 INY                    \ Increment Y to point to the next row in the character
                        \ block, i.e. the next pixel down

 CPY #8                 \ Loop back to HAL7 to draw this next pixel until we
 BNE HAL7               \ have drawn all 8 in the character block

 INC SC+1               \ Point SC(1 0) to the next page in memory, i.e. the
                        \ next character row

 LDY #0                 \ Set Y = 0 to point to the first row in this character
                        \ block

 BEQ HAL7               \ Loop back up to HAL7 to keep drawing the line (this
                        \ BEQ is effectively a JMP as Y is always zero)

.HA6

 RTS                    \ Return from the subroutine

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
\    Summary: Send the screen to the printer, following a CTRL-P key press
\
\ ------------------------------------------------------------------------------
\
\ In the following, the escape sequences sent to the printer are standard Epson
\ printer codes.
\
\ ******************************************************************************

.printer

 LDA #2                 \ Print ASCII 2 using the VDU routine in the MOS, which
 JSR print_safe         \ means "start sending characters to the printer"

 LDA #'@'               \ Send "ESC @" to the printer to initialise the printer
 JSR print_esc

 LDA #'A'               \ Send "ESC A 8" to the printer to select line spacing
 JSR print_esc          \ of 8/72 inches (1/9")
 LDA #8
 JSR print_wrch

 LDA #&60               \ Set SC(1 0) = &6000, so it points to the start of
 STA SC+1               \ screen memory
 LDA #0
 STA SC

.print_view

 LDA #'K'               \ Send "ESC K 0 1" to the printer to select single
 JSR print_esc          \ density graphics (60 dpi)
 LDA #0
 JSR print_wrch
 LDA #1
 JSR print_wrch

                        \ We print the screen one character block at a time
                        \ (where each character block is made up of 8 rows,
                        \ with each row being one byte of screen memory)
                        \
                        \ We do this in three parts. First, we extract the
                        \ screen memory for the character block and stick it
                        \ into a buffer at print_bits. Second, if this is the
                        \ dashboard, which is in colour, then we process the
                        \ contents of the buffer into pixel patterns (as the
                        \ printer can only print monochrome dots). Finally, we
                        \ send the character block to the printer as a sequence
                        \ of one-pixel-wide vertical slices of eight pixels in
                        \ height, working our way from left to right until the
                        \ character block is printed. And then we move onto the
                        \ next character block until the whole screen is printed

.print_outer

 LDY #7                 \ We want to print a single character block of screen
                        \ memory, so set a counter in Y for the 8 rows in the
                        \ character block

 LDX #&FF               \ Set X as an index into the print_bits buffer, starting
                        \ at &FF so the initial INX increments it to an index of
                        \ 0 for the first entry in the buffer

.print_copy

 INX                    \ Increment the pointer into the print_bits buffer, so
                        \ we can store the character rows in the buffer,
                        \ starting with the bottom row of the character and
                        \ working our way to the top

 LDA (SC),Y             \ Grab the Y-th row from the character block and store
 STA print_bits,X       \ it in the X-th byte of print_bits

 DEY                    \ Decrement the character row counter

 BPL print_copy         \ Loop back to print_copy until we have copied all eight
                        \ rows of the character block into the buffer

 LDA SC+1               \ If the high byte in SC(1 0) < &78 then we are still
 CMP #&78               \ printing the space view, so jump down to print_inner
 BCC print_inner

                        \ Otherwise we are printing the dashboard, so we now
                        \ need to process the data in the buffer to use pixel
                        \ patterns, as the structure of each mode 5 screen
                        \ memory byte is interleaved so that the first pixel is
                        \ in bits 0 and 4, the second is in bits 1 and 5, and
                        \ so on (see the deep dive on "Drawing colour pixels in
                        \ mode 5" for more on this)
                        \
                        \ The idea is that we convert each interleaved pixel
                        \ pair into a two-dot wide pixel, so the colour screen
                        \ gets translated into monochrome pixels that match the
                        \ screen layout

                        \ Note that at this point, X is 7, so we can use it as
                        \ an index into the print_bits buffer as we work our way
                        \ through each byte

.print_radar

 LDY #7                 \ For each character pixel row we loop through each bit
                        \ in the interleaved byte, so set a counter in Y for 8
                        \ bits

 LDA #0                 \ We build up the new pixel row in A, so start with 0
                        \ so we can fill it up with the correct bit pattern

                        \ The following loop works through each bit in the X-th
                        \ pixel row byte, converting it to a monochrome pattern
                        \ that we can print, which gets stored in the print_bits
                        \ buffer in place of the original colour byte

.print_split

 ASL print_bits,X       \ Shift the pixel row byte to the left, so the leftmost
                        \ bit falls off the end and into the C flag

 BCC print_merge        \ If that bit is clear, jump to print_merge to skip the
                        \ following instruction and move onto the next bit

 ORA print_tone,Y       \ The Y-th bit in the original colour byte was set, so
                        \ we grab the Y-th entry from print_tone and OR it into
                        \ the new pixel row byte in A. If you look at the pixel
                        \ rows in the print_tone table, you can see that:
                        \
                        \   * If Y is 0 or 4, we set monochrome pixels 0 and 1
                        \   * If Y is 1 or 5, we set monochrome pixels 2 and 3
                        \   * If Y is 2 or 6, we set monochrome pixels 4 and 5
                        \   * If Y is 3 or 7, we set monochrome pixels 6 and 7
                        \
                        \ The above equates to:
                        \
                        \   * If colour pixel 0 is non-zero, we set monochrome
                        \     pixels 0 and 1
                        \
                        \   * If colour pixel 1 is non-zero, we set monochrome
                        \     pixels 2 and 3
                        \
                        \   * If colour pixel 2 is non-zero, we set monochrome
                        \     pixels 4 and 5
                        \
                        \   * If colour pixel 3 is non-zero, we set monochrome
                        \     pixels 6 and 7
                        \
                        \ So this takes a four-pixel wide character row, and
                        \ creates an eight-pixel wide character row made up of
                        \ two-pixel wide blocks that match the original pattern,
                        \ which is what we want for our printer-friendly version
                        \ of the mode 5 colour dashboard

.print_merge

 DEY                    \ Decrement the bit counter in Y to move onto the next
                        \ bit in the pixel row byte

 BPL print_split        \ Loop back to print_split until we have shifted all
                        \ eight bits, at which point we have our new monochrome
                        \ pixel row byte

 STA print_bits,X       \ Store the new pixel row byte in A into the X-th entry
                        \ in the print_bits buffer, replacing the unprintable
                        \ colour byte that was there before

 DEX                    \ Decrement the pointer into the print_bits buffer

 BPL print_radar        \ Loop back to process the next entry in the print_bits
                        \ buffer until we have processed all eight rows in the
                        \ character block

                        \ We now want to print the character block that we
                        \ stored in the print_bits buffer, which we do by
                        \ printing one-pixel wide vertical slices of the
                        \ character, starting from the left edge of the block
                        \ and working our way to the right edge of the block

.print_inner

 LDY #7                 \ We want to work our way through the eight columns in
                        \ the character block, so set a counter in Y for this

.print_block

 LDX #7                 \ We want to work our way through the eight rows in
                        \ the character block, so set a counter in X for this,
                        \ starting with the last row as we put the rows into
                        \ the print_bits buffer in reverse order (so this will
                        \ pull them out in the correct order, from top to
                        \ bottom, as we put them into print_bits with the bottom
                        \ row first, so starting with X = 7 will pull out the
                        \ top row first)

.print_slice

 ASL print_bits,X       \ Shift the byte for the X-th row in the character block
                        \ to the left, so the leftmost pixel falls off the end
                        \ and into the C flag

 ROL A                  \ Shift the pixel from the C flag into bit 0 of A, so we
                        \ build up the vertical slice of 8 pixels in A, one
                        \ pixel at a time

 DEX                    \ Decrement the vertical pixel counter

 BPL print_slice        \ Loop back until we have extracted all 8 pixels in the
                        \ vertical slice into A

 JSR print_wrch         \ Send the one-pixel vertical slice to the printer, so
                        \ we print 8 vertical pixels and shift along one pixel

 DEY                    \ Decrement the column counter to move onto the next
                        \ vertical slice in the character block

 BPL print_block        \ Loop back until we have printer 8 vertical slices of
                        \ one-pixel width, at which point we have printed the
                        \ whole character block

.print_next

                        \ We now want to move onto the next character block on
                        \ the row, so we add 8 to the screen address in SC(1 0)
                        \ as there are 8 bytes in each character block

 CLC                    \ Set SC(1 0) = SC(1 0) + 8
 LDA SC                 \
 ADC #8                 \ starting with the low byte in SC
 STA SC

 BNE print_outer        \ If the above addition didn't wrap wround back to 0,
                        \ the addition is correct, so loop back up to
                        \ print_outer to print the next character block along

                        \ If we get here then we have just wrapped around to the
                        \ next page in screen memory, which means we have
                        \ reached the end of the current character row and need
                        \ to move onto the next row

 LDA #13                \ Send a carriage return character (ASCII 13) to the
 JSR print_wrch         \ printer to move the printer head down to the next line

 INC SC+1               \ Increment the high byte of SC(1 0) to point the screen
                        \ address to the start of the next character row

 LDX SC+1               \ Set X to the high byte of SC(1 0) plus 1, which points
 INX                    \ to the character row after the one we are about to
                        \ print

 BPL print_view         \ If bit 7 of X is clear, this means that X < &80, so
                        \ the high byte of SC(1 0) < &7F, which means we haven't
                        \ yet reached the end of screen memory at &76FF, so
                        \ loop back to print_view to set the graphics density
                        \ again (as we have to do this on each row) and move
                        \ onto the next character row

 LDA #3                 \ Print ASCII 3 using the VDU routine in the MOS, which
 JMP print_safe         \ means "stop sending characters to the printer", and
                        \ return from the subroutine using a tail call

\JSR print_safe         \ These instructions are commented out in the original
\JMP tube_put           \ source

\ ******************************************************************************
\
\       Name: print_tone
\       Type: Variable
\   Category: Text
\    Summary: Lookup table for converting mode 5 colour pixel rows to monochrome
\             pixel pairs
\
\ ******************************************************************************

.print_tone

 EQUB %00000011         \ Bit 0 of the mode 5 pixel row (pixel 0) is set
 EQUB %00001100         \ Bit 1 of the mode 5 pixel row (pixel 1) is set
 EQUB %00110000         \ Bit 2 of the mode 5 pixel row (pixel 2) is set
 EQUB %11000000         \ Bit 3 of the mode 5 pixel row (pixel 3) is set

 EQUB %00000011         \ Bit 4 of the mode 5 pixel row (pixel 0) is set
 EQUB %00001100         \ Bit 5 of the mode 5 pixel row (pixel 1) is set
 EQUB %00110000         \ Bit 6 of the mode 5 pixel row (pixel 2) is set
 EQUB %11000000         \ Bit 7 of the mode 5 pixel row (pixel 3) is set

\ ******************************************************************************
\
\       Name: print_esc
\       Type: Subroutine
\   Category: Text
\    Summary: Send an escape sequence to the printer
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The parameter of the escape sequence, so ESC A is sent
\                       to the printer
\
\ ******************************************************************************

.print_esc

 PHA                    \ Store A on the stack so we can retrieve it below

 LDA #27                \ Send ASCII 27 to the printer, which starts a printer
 JSR print_wrch         \ ESC escape sequence

 PLA                    \ Retrieve the value of A from the stack

                        \ Fall through into print_safe to send the character in
                        \ A to the printer

\ ******************************************************************************
\
\       Name: print_wrch
\       Type: Subroutine
\   Category: Text
\    Summary: Send a character to the printer
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The ASCII character to send to the printer
\
\ ******************************************************************************

.print_wrch

 PHA                    \ Store A on the stack so we can retrieve it below

 LDA #1                 \ Print ASCII 1 using the VDU routine in the MOS, which
 JSR print_safe         \ means "send the next character to the printer only"

 PLA                    \ Retrieve the value of A from the stack

                        \ Fall through into print_safe to print the character
                        \ in A, which will send it to the printer

\ ******************************************************************************
\
\       Name: print_safe
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character using the VDU routine in the MOS, to bypass our
\             custom WRCHV handler
\
\ ******************************************************************************

.print_safe

 PHA                    \ Store the A, Y and X registers on the stack so we can
 TYA                    \ retrieve them after the call to rawrch
 PHA
 TXA
 PHA

 TSX                    \ Transfer the stack pointer S to X

 LDA &103,X             \ The stack starts at &100, with &100+S pointing to the
                        \ top of the stack, so this fetches the third value from
                        \ the stack into A, which is the value of A that we just
                        \ stored on the stack - i.e. the character that we want
                        \ to print

 JSR rawrch             \ Print the character by calling the VDU character
                        \ output routine in the MOS

 PLA                    \ Retrieve the A, Y and X registers from the stack
 TAX
 PLA
 TAY
 PLA

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\ Save 2.H.bin
\
\ ******************************************************************************

PRINT "S.2.H ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "3-assembled-output/2.H.bin", CODE%, P%, LOAD%