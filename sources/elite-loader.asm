\ ******************************************************************************
\
\ ELITE-A LOADER SOURCE
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
\   * output/ELITE.bin
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

Q% = _REMOVE_CHECKSUMS  \ Set Q% to TRUE to max out the default commander, FALSE
                        \ for the standard default commander (this is set to
                        \ TRUE if checksums are disabled, just for convenience)

BRKV = &0202            \ The break vector that we intercept to enable us to
                        \ handle and display system errors

IRQ1V = &0204           \ The IRQ1V vector that we intercept to implement the
                        \ split-sceen mode

WRCHV = &020E           \ The WRCHV vector that we intercept with our custom
                        \ text printing routine

BYTEV = &020A           \ The BYTEV vector that we intercept to AJD

FILEV = &0212           \ The FILEV vector that we intercept to AJD

FSCV = &021E            \ The FSCV vector that we intercept to AJD

NETV = &0224            \ The NETV vector that we intercept as part of the copy
                        \ protection

OSWRCH = &FFEE          \ The address for the OSWRCH routine
OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSWORD = &FFF1          \ The address for the OSWORD routine
OSCLI = &FFF7           \ The address for the OSCLI vector

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

N% = 67                 \ N% is set to the number of bytes in the VDU table, so
                        \ we can loop through them in part 1 below

VSCAN = 57              \ Defines the split position in the split-screen mode

VEC = &7FFE             \ VEC is where we store the original value of the IRQ1
                        \ vector, matching the address in the elite-missile.asm
                        \ source

LASCT = &0346           \ The laser pulse count for the current laser, matching
                        \ the address in the main game code

HFX = &0348             \ A flag that toggles the hyperspace colour effect,
                        \ matching the address in the main game code

cmdr_iff = &036E        \ AJD

ESCP = &0386            \ The flag that determines whether we have an escape pod
                        \ fitted, matching the address in the main game code

S% = &11E3              \ The adress of the main entry point workspace in the
                        \ main game code

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0070 to &008C
\   Category: Workspaces
\    Summary: Important variables used by the loader
\
\ ******************************************************************************

ORG &0004

.key_io

 SKIP 1                 \ AJD

ORG &0020

.INF

 SKIP 2                 \ Temporary storage, typically used for storing the
                        \ address of a ship's data block, so it can be copied
                        \ to and from the internal workspace at INWK

ORG &0070

.ZP

 SKIP 2                 \ Stores addresses used for moving content around

.P

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.YY

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

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

.CHKSM

 SKIP 2                 \ Used in the copy protection code

ORG &008B

.DL

 SKIP 1                 \ Vertical sync flag
                        \
                        \ DL gets set to 30 every time we reach vertical sync on
                        \ the video system, which happens 50 times a second
                        \ (50Hz). The WSCAN routine uses this to pause until the
                        \ vertical sync, by setting DL to 0 and then monitoring
                        \ its value until it changes to 30

.TYPE

 SKIP 1                 \ The current ship type
                        \
                        \ This is where we store the current ship type for when
                        \ we are iterating through the ships in the local bubble
                        \ as part of the main flight loop. See the table at XX21
                        \ for information about ship types

ORG &0090

.key_tube

 SKIP 2                 \ AJD

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

CODE% = &1900
LOAD% = &1900

ORG CODE%

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Screen mode
\    Summary: VDU commands for setting the square mode 4 screen
\  Deep dive: The split-screen mode
\             Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ This block contains the bytes that get written by OSWRCH to set up the screen
\ mode (this is equivalent to using the VDU statement in BASIC).
\
\ It defines the whole screen using a square, monochrome mode 4 configuration;
\ the mode 5 part for the dashboard is implemented in the IRQ1 routine.
\
\ The top part of Elite's screen mode is based on mode 4 but with the following
\ differences:
\
\   * 32 columns, 31 rows (256 x 248 pixels) rather than 40, 32
\
\   * The horizontal sync position is at character 45 rather than 49, which
\     pushes the screen to the right (which centres it as it's not as wide as
\     the normal screen modes)
\
\   * Screen memory goes from &6000 to &7EFF, which leaves another whole page
\     for code (i.e. 256 bytes) after the end of the screen. This is where the
\     Python ship blueprint slots in
\
\   * The text window is 1 row high and 13 columns wide, and is at (2, 16)
\
\   * The cursor is disabled
\
\ This almost-square mode 4 variant makes life a lot easier when drawing to the
\ screen, as there are 256 pixels on each row (or, to put it in screen memory
\ terms, there's one page of memory per row of pixels). For more details of the
\ screen mode, see the deep dive on "Drawing monochrome pixels in mode 4".
\
\ There is also an interrupt-driven routine that switches the bytes-per-pixel
\ setting from that of mode 4 to that of mode 5, when the raster reaches the
\ split between the space view and the dashboard. See the deep dive on "The
\ split-screen mode" for details.
\
\ ******************************************************************************

.B%

 EQUB 22, 4             \ Switch to screen mode 4

 EQUB 28                \ Define a text window as follows:
 EQUB 2, 17, 15, 16     \
                        \   * Left = 2
                        \   * Right = 15
                        \   * Top = 16
                        \   * Bottom = 17
                        \
                        \ i.e. 1 row high, 13 columns wide at (2, 16)

 EQUB 23, 0, 6, 31      \ Set 6845 register R6 = 31
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "vertical displayed" register, and sets
                        \ the number of displayed character rows to 31. For
                        \ comparison, this value is 32 for standard modes 4 and
                        \ 5, but we claw back the last row for storing code just
                        \ above the end of screen memory

 EQUB 23, 0, 12, &0C    \ Set 6845 register R12 = &0C and R13 = &00
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This sets 6845 registers (R12 R13) = &0C00 to point
 EQUB 23, 0, 13, &00    \ to the start of screen memory in terms of character
 EQUB 0, 0, 0           \ rows. There are 8 pixel lines in each character row,
 EQUB 0, 0, 0           \ so to get the actual address of the start of screen
                        \ memory, we multiply by 8:
                        \
                        \   &0C00 * 8 = &6000
                        \
                        \ So this sets the start of screen memory to &6000

 EQUB 23, 0, 1, 32      \ Set 6845 register R1 = 32
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "horizontal displayed" register, which
                        \ defines the number of character blocks per horizontal
                        \ character row. For comparison, this value is 40 for
                        \ modes 4 and 5, but our custom screen is not as wide at
                        \ only 32 character blocks across

 EQUB 23, 0, 2, 45      \ Set 6845 register R2 = 45
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "horizontal sync position" register, which
                        \ defines the position of the horizontal sync pulse on
                        \ the horizontal line in terms of character widths from
                        \ the left-hand side of the screen. For comparison this
                        \ is 49 for modes 4 and 5, but needs to be adjusted for
                        \ our custom screen's width

 EQUB 23, 0, 10, 32     \ Set 6845 register R10 = 32
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "cursor start" register, so this sets the
                        \ cursor start line at 0, effectively disabling the
                        \ cursor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Sound
\    Summary: Sound envelope definitions
\
\ ------------------------------------------------------------------------------
\
\ This table contains the sound envelope data, which is passed to OSWORD by the
\ FNE macro to create the four sound envelopes used in-game. Refer to chapter 30
\ of the BBC Micro User Guide for details of sound envelopes and what all the
\ parameters mean.
\
\ The envelopes are as follows:
\
\   * Envelope 1 is the sound of our own laser firing
\
\   * Envelope 2 is the sound of lasers hitting us, or hyperspace
\
\   * Envelope 3 is the first sound in the two-part sound of us dying, or the
\     second sound in the two-part sound of us making hitting or killing an
\     enemy ship
\
\   * Envelope 4 is the sound of E.C.M. firing
\
\ ******************************************************************************

.E%

 EQUB 1, 1, 0, 111, -8, 4, 1, 8, 8, -2, 0, -1, 126, 44
 EQUB 2, 1, 14, -18, -1, 44, 32, 50, 6, 1, 0, -2, 120, 126
 EQUB 3, 1, 1, -1, -3, 17, 32, 128, 1, 0, 0, -1, 1, 1
 EQUB 4, 1, 4, -8, 44, 4, 6, 8, 22, 0, 0, -127, 126, 0

\ ******************************************************************************
\
\       Name: FNE
\       Type: Macro
\   Category: Sound
\    Summary: Macro definition for defining a sound envelope
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to define the four sound envelopes used in the
\ game. It uses OSWORD 8 to create an envelope using the 14 parameters in the
\ the I%-th block of 14 bytes at location E%. This OSWORD call is the same as
\ BBC BASIC's ENVELOPE command.
\
\ See variable E% for more details of the envelopes themselves.
\
\ ******************************************************************************

MACRO FNE I%

  LDX #LO(E%+I%*14)     \ Set (Y X) to point to the I%-th set of envelope data
  LDY #HI(E%+I%*14)     \ in E%

  LDA #8                \ Call OSWORD with A = 8 to set up sound envelope I%
  JSR OSWORD

ENDMACRO

\ ******************************************************************************
\
\       Name: Elite loader (Part 1 of 3)
\       Type: Subroutine
\   Category: Loader
\    Summary: Set up the split screen mode, move code around, set up the sound
\             envelopes and configure the system
\
\ ******************************************************************************

.ENTRY

                        \ --- Original Acornsoft code removed: ---------------->

\ JSR PROT1             \ Call PROT1 to calculate checksums into CHKSM
\
\ LDA #144              \ Call OSBYTE with A = 144, X = 255 and Y = 0 to move
\ LDX #255              \ the screen down one line and turn screen interlace on
\ JSR OSB

                        \ --- And replaced by: -------------------------------->

 CLI                    \ AJD
 LDA #&90
 LDX #&FF
 LDY #&01
 JSR OSBYTE

                        \ --- End of replacement ------------------------------>

 LDA #LO(B%)            \ Set the low byte of ZP(1 0) to point to the VDU code
 STA ZP                 \ table at B%

 LDA #HI(B%)            \ Set the high byte of ZP(1 0) to point to the VDU code
 STA ZP+1               \ table at B%

 LDY #0                 \ We are now going to send the N% VDU bytes in the table
                        \ at B% to OSWRCH to set up the special mode 4 screen
                        \ that forms the basis for the split-screen mode

.loop1

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #N%                \ Loop back for the next byte until we have done them
 BNE loop1              \ all (the number of bytes was set in N% above)

 JSR PLL1               \ Call PLL1 to draw Saturn

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #16               \ Call OSBYTE with A = 16 and X = 3 to set the ADC to
\ LDX #3                \ sample 3 channels from the joystick/Bitstik
\ JSR OSBYTE

                        \ --- And replaced by: -------------------------------->

 LDA #16                \ Call OSBYTE with A = 16 and X = 2 to set the ADC to
 LDX #2                 \ sample 2 channels from the joystick
 JSR OSBYTE

                        \ --- End of replacement ------------------------------>

 LDA #&60               \ Store an RTS instruction in location &0232
 STA &0232

 LDA #&02               \ Point the NETV vector to &0232, which we just filled
 STA NETV+1             \ with an RTS
 LDA #&32
 STA NETV

 LDA #190               \ Call OSBYTE with A = 190, X = 8 and Y = 0 to set the
 LDX #8                 \ ADC conversion type to 8 bits, for the joystick
 JSR OSB

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #200              \ Call OSBYTE with A = 200, X = 0 and Y = 0 to enable
\ LDX #0                \ the ESCAPE key and disable memory clearing if the
\ JSR OSB               \ BREAK key is pressed

                        \ --- And replaced by: -------------------------------->

 LDA #200               \ Call OSBYTE with A = 200, X = 3 and Y = 0 to disable
 LDX #3                 \ the ESCAPE key and clear memory if the BREAK key is
 JSR OSB                \ pressed

                        \ --- End of replacement ------------------------------>

 LDA #13                \ Call OSBYTE with A = 13, X = 0 and Y = 0 to disable
 LDX #0                 \ the "output buffer empty" event
 JSR OSB

 LDA #225               \ Call OSBYTE with A = 225, X = 128 and Y = 0 to set
 LDX #128               \ the function keys to return ASCII codes for SHIFT-fn
 JSR OSB                \ keys (i.e. add 128)

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #12               \ Set A = 12 and  X = 0 to pretend that this is an to
\ LDX #0                \ innocent call to OSBYTE to reset the keyboard delay
\                       \ and auto-repeat rate to the default, when in reality
\                       \ the OSB address in the next instruction gets modified
\                       \ to point to OSBmod
\
\.OSBjsr
\
\ JSR OSB               \ This JSR gets modified by code inserted into PLL1 so
\                       \ that it points to OSBmod instead of OSB, so this
\                       \ actually calls OSBmod to calculate some checksums

                        \ --- End of removed code ----------------------------->

 LDA #13                \ Call OSBYTE with A = 13, X = 2 and Y = 0 to disable
 LDX #2                 \ the "character entering buffer" event
 JSR OSB

 LDA #4                 \ Call OSBYTE with A = 4, X = 1 and Y = 0 to disable
 LDX #1                 \ cursor editing, so the cursor keys return ASCII values
 JSR OSB                \ and can therefore be used in-game

 LDA #9                 \ Call OSBYTE with A = 9, X = 0 and Y = 0 to disable
 LDX #0                 \ flashing colours
 JSR OSB

                        \ --- Code added for Elite-A: ------------------------->

 LDA #&77               \ AJD
 JSR OSBYTE

                        \ --- End of added code ------------------------------->

 JSR PROT3              \ Call PROT3 to do more checks on the CHKSM checksum

 LDA #&00               \ Set the following:
 STA ZP                 \
 LDA #&11               \   ZP(1 0) = &1100
 STA ZP+1               \   P(1 0) = TVT1code
 LDA #LO(TVT1code)
 STA P
 LDA #HI(TVT1code)
 STA P+1

 JSR MVPG               \ Call MVPG to move and decrypt a page of memory from
                        \ TVT1code to &1100-&11FF

                        \ --- Code added for Elite-A: ------------------------->

 LDA #&EE               \ AJD
 STA BRKV
 LDA #&11
 STA BRKV+1

                        \ --- End of added code ------------------------------->

 LDA #&00               \ Set the following:
 STA ZP                 \
 LDA #&78               \   ZP(1 0) = &7800
 STA ZP+1               \   P(1 0) = DIALS
 LDA #LO(DIALS)         \   X = 8
 STA P
 LDA #HI(DIALS)
 STA P+1
 LDX #8

 JSR MVBL               \ Call MVBL to move and decrypt 8 pages of memory from
                        \ DIALS to &7800-&7FFF

                        \ --- Original Acornsoft code removed: ---------------->

\ SEI                   \ Disable interrupts while we set up our interrupt
\                       \ handler to support the split-screen mode
\
\ LDA VIA+&44           \ Read the 6522 System VIA T1C-L timer 1 low-order
\ STA &0001             \ counter (SHEILA &44), which increments 1000 times a
\                       \ second so this will be pretty random, and store it in
\                       \ &0001 among the random number seeds at &0000
\
\ LDA #%00111001        \ Set 6522 System VIA interrupt enable register IER
\ STA VIA+&4E           \ (SHEILA &4E) bits 0 and 3-5 (i.e. disable the Timer1,
\                       \ CB1, CB2 and CA2 interrupts from the System VIA)
\
\ LDA #%01111111        \ Set 6522 User VIA interrupt enable register IER
\ STA VIA+&6E           \ (SHEILA &6E) bits 0-7 (i.e. disable all hardware
\                       \ interrupts from the User VIA)
\
\ LDA IRQ1V             \ Copy the current IRQ1V vector address into VEC(1 0)
\ STA VEC
\ LDA IRQ1V+1
\ STA VEC+1
\
\ LDA #LO(IRQ1)         \ Set the IRQ1V vector to IRQ1, so IRQ1 is now the
\ STA IRQ1V             \ interrupt handler
\ LDA #HI(IRQ1)
\ STA IRQ1V+1
\
\ LDA #VSCAN            \ Set 6522 System VIA T1C-L timer 1 high-order counter
\ STA VIA+&45           \ (SHEILA &45) to VSCAN (57) to start the T1 counter
\                       \ counting down from 14622 at a rate of 1 MHz
\
\ CLI                   \ Re-enable interrupts

                        \ --- End of removed code ----------------------------->

 LDA #&00               \ Set the following:
 STA ZP                 \
 LDA #&61               \   ZP(1 0) = &6100
 STA ZP+1               \   P(1 0) = ASOFT
 LDA #LO(ASOFT)
 STA P
 LDA #HI(ASOFT)
 STA P+1

 JSR MVPG               \ Call MVPG to move and decrypt a page of memory from
                        \ ASOFT to &6100-&61FF

 LDA #&63               \ Set the following:
 STA ZP+1               \
 LDA #LO(ELITE)         \   ZP(1 0) = &6300
 STA P                  \   P(1 0) = ELITE
 LDA #HI(ELITE)
 STA P+1

 JSR MVPG               \ Call MVPG to move and decrypt a page of memory from
                        \ ELITE to &6300-&63FF

 LDA #&76               \ Set the following:
 STA ZP+1               \
 LDA #LO(CpASOFT)       \   ZP(1 0) = &7600
 STA P                  \   P(1 0) = CpASOFT
 LDA #HI(CpASOFT)
 STA P+1

 JSR MVPG               \ Call MVPG to move and decrypt a page of memory from
                        \ CpASOFT to &7600-&76FF

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #&00              \ Set the following:
\ STA ZP                \
\ LDA #&04              \   ZP(1 0) = &0400
\ STA ZP+1              \   P(1 0) = WORDS
\ LDA #LO(WORDS)        \   X = 4
\ STA P
\ LDA #HI(WORDS)
\ STA P+1
\ LDX #4
\
\ JSR MVBL              \ Call MVBL to move and decrypt 4 pages of memory from
\                       \ WORDS to &0400-&07FF
\
\ LDX #35               \ We now want to copy the disc catalogue routine from
\                       \ CATDcode to CATD, so set a counter in X for the 36
\                       \ bytes to copy
\
\.loop2
\
\ LDA CATDcode,X        \ Copy the X-th byte of CATDcode to the X-th byte of
\ STA CATD,X            \ CATD
\
\ DEX                   \ Decrement the loop counter
\
\ BPL loop2             \ Loop back to copy the next byte until they are all
\                       \ done
\
\ LDA &76               \ Set the drive number in the CATD routine to the
\ STA CATBLOCK          \ contents of &76, which gets set in ELITE3

                        \ --- End of removed code ----------------------------->

 FNE 0                  \ Set up sound envelopes 0-3 using the FNE macro
 FNE 1
 FNE 2
 FNE 3

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR E")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1, which
                        \ changes the disc directory to E

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #LO(LOAD)         \ Set the following:
\ STA ZP                \
\ LDA #HI(LOAD)         \   ZP(1 0) = LOAD
\ STA ZP+1              \   P(1 0) = LOADcode
\ LDA #LO(LOADcode)
\ STA P
\ LDA #HI(LOADcode)
\ STA P+1
\
\ LDY #0                \ We now want to move and decrypt one page of memory
\                       \ from LOADcode to LOAD, so set Y as a byte counter
\
\.loop3
\
\ LDA (P),Y             \ Fetch the Y-th byte of the P(1 0) memory block
\
\ EOR #&18              \ Decrypt it by EOR'ing with &18
\
\ STA (ZP),Y            \ Store the decrypted result in the Y-th byte of the
\                       \ ZP(1 0) memory block
\
\ DEY                   \ Decrement the byte counter
\
\ BNE loop3             \ Loop back to copy the next byte until we have done a
\                       \ whole page of 256 bytes
\
\ JMP LOAD              \ Jump to the start of the routine we just decrypted

                        \ --- And replaced by: -------------------------------->

 LDA #&F0               \ set up DDRB AJD
 STA &FE62
 LDA #0 \ Set up palatte flags
 STA &348
 STA &346
 LDA #&FF
 STA &386
 SEI 
 LDA &FE44
 \ STA &01
 LDA #&39
 STA &FE4E
 LDA #&7F
 STA &FE6E
 LDA IRQ1V
 STA &7FFE
 LDA IRQ1V+&01
 STA &7FFF
 LDA #&4B
 STA IRQ1V
 LDA #&11
 STA IRQ1V+&01
 LDA #&39
 STA &FE45
 CLI 
 LDA #0 \ test for BBC Master
 LDX #1
 JSR OSBYTE \ get OS version
 CPX #3
 BCC not_master
 LDX #0 \ copy master code to DD00

.cpmaster

 LDA to_dd00,X
 STA &DD00,X
 INX
 CPX #dd00_len
 BNE cpmaster
 LDA #&8F \ service call
 LDX #&21 \ ?
 LDY #&C0 \ ? top of absolute workspace
 JSR OSBYTE \ ? in XY
 STX put0+1 \ modify workspace save address
 STX put1+1
 STX put2+1
 STX get0+1 \ modify workspace restore address
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
 LDA FILEV \ modify address for old FILEV
 STA old_FILEV+1
 LDA FILEV+1
 STA old_FILEV+2
 LDA FSCV \ modify address for old FSCV
 STA old_FSCV+1
 LDA FSCV+1
 STA old_FSCV+2
 LDA BYTEV \ modify address for old BYTEV
 STA old_BYTEV+1
 LDA BYTEV+1
 STA old_BYTEV+2
 JSR set_vectors \ replace FILEV and FSCV

.not_master

 LDA #&EA \ test for tube
 LDY #&FF
 LDX #&00
 JSR OSBYTE
 TXA
 BNE tube_go
 LDA #&AC \ keyboard translation table
 LDX #&00
 LDY #&FF
 JSR OSBYTE
 STX key_io
 STY key_io+&01

 LDA #&00               \ Set the following:
 STA ZP                 \
 LDA #&04               \   ZP(1 0) = &0400
 STA ZP+1               \   P(1 0) = WORDS
 LDA #LO(WORDS)         \   X = 4
 STA P
 LDA #HI(WORDS)
 STA P+1
 LDX #4

 JSR MVBL               \ Call MVBL to move and decrypt 4 pages of memory from
                        \ WORDS to &0400-&07FF

 LDA #LO(S%+6)          \ Point BRKV to the third entry in the main docked
 STA WRCHV              \ code's S% workspace, which contains JMP CHPR
 LDA #HI(S%+6)
 STA WRCHV+1

 LDA #LO(LOAD)          \ Set the following:
 STA ZP                 \
 LDA #HI(LOAD)          \   ZP(1 0) = LOAD
 STA ZP+1               \   P(1 0) = LOADcode
 LDA #LO(LOADcode)
 STA P
 LDA #HI(LOADcode)
 STA P+1

 JSR MVPG               \ Call MVPG to move and decrypt a page of memory from
                        \ LOADcode to LOAD

 LDY #35

.copy_d7a

 LDA iff_index_code,Y
 STA iff_index,Y
 DEY
 BPL copy_d7a
 JMP &0B00

.tube_go

 LDA #&AC \ keyboard translation table
 LDX #&00
 LDY #&FF
 JSR OSBYTE
 STX key_tube
 STY key_tube+&01
 \ LDX #LO(tube_400)
 \ LDY #HI(tube_400)
 \ LDA #1
 \ JSR &0406
 \ LDA #LO(WORDS)
 \ STA &72
 \ LDA #HI(WORDS)
 \ STA &73
 \ LDX #&04
 \ LDY #&00
 \tube_wr LDA (&72),Y
 \ JSR tube_wait
 \ BIT tube_r3s
 \ BVC tube_wr
 \ STA tube_r3d
 \ INY
 \ BNE tube_wr
 \ INC &73
 \ DEX
 \ BNE tube_wr
 \ LDA #LO(tube_wrch)
 \ STA WRCHV
 \ LDA #HI(tube_wrch)
 \ STA WRCHV+&01
 LDX #LO(tube_run)
 LDY #HI(tube_run)
 JMP OSCLI

.tube_run

 EQUS "R.2.H", &0D

 \tube_400 EQUD &0400

 \tube_wait
 \ JSR tube_wait2
 \tube_wait2
 \ JSR tube_wait3
 \tube_wait3
 \ RTS

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: iff_index_code
\       Type: Subroutine
\   Category: Dashboard
\    Summary: AJD
\
\ ******************************************************************************

.iff_index_code

ORG &0D7A

\ ******************************************************************************
\
\       Name: iff_index
\       Type: Subroutine
\   Category: Dashboard
\    Summary: AJD
\
\ ------------------------------------------------------------------------------
\
\ This routine is copied to &0D7A in part 1 above.
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

.iff_index

 LDX cmdr_iff           \ iff code
 BEQ iff_not
 LDY #&24
 LDA (INF),Y
 ASL A
 ASL A
 BCS iff_cop
 ASL A
 BCS iff_trade
 LDY TYPE
 DEY
 BEQ iff_missle
 CPY #&08
 BCC iff_aster
 INX \ X=4

.iff_missle

 INX \ X=3

.iff_aster

 INX \ X=2

.iff_cop

 INX \ X=1

.iff_trade

 INX \ X=0

.iff_not

 RTS \ X=0

                        \ --- End of added section ---------------------------->

COPYBLOCK iff_index, P%, iff_index_code

ORG iff_index_code + P% - iff_index

\ ******************************************************************************
\
\       Name: LOADcode
\       Type: Subroutine
\   Category: Loader
\    Summary: Encrypted LOAD routine, bundled up in the loader so it can be
\             moved to &0B00 to be run
\
\ ------------------------------------------------------------------------------
\
\ This section is encrypted by EOR'ing with &18. The encryption is done by the
\ elite-checksum.py script, and decryption is done in part 1 above, at the same
\ time as it is moved to &0B00.
\
\ ******************************************************************************

.LOADcode

ORG &0B00

\ ******************************************************************************
\
\       Name: LOAD
\       Type: Subroutine
\   Category: Loader
\    Summary: Load the main docked code, set up various vectors, run a checksum
\             and start the game
\
\ ******************************************************************************

.LOAD

 LDX #LO(LTLI)          \ Set (Y X) to point to LTLI ("L.T.CODE")
 LDY #HI(LTLI)

 JSR OSCLI              \ Call OSCLI to run the OS command in LTLI, which loads
                        \ the T.CODE binary (the main docked code) to its load
                        \ address of &11E3

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #LO(S%+11)        \ Point BRKV to the fifth entry in the main docked
\ STA BRKV              \ code's S% workspace, which contains JMP BRBR1
\ LDA #HI(S%+11)
\ STA BRKV+1
\
\ LDA #LO(S%+6)         \ Point BRKV to the third entry in the main docked
\ STA WRCHV             \ code's S% workspace, which contains JMP CHPR
\ LDA #HI(S%+6)
\ STA WRCHV+1
\
\ SEC                   \ Set the C flag so the checksum we calculate in A
\                       \ starts with an initial value of 18 (17 plus carry)
\
\ LDY #&00              \ Set Y = 0 to act as a byte pointer
\
\ STY ZP                \ Set the low byte of ZP(1 0) to 0, so ZP(1 0) always
\                       \ points to the start of a page
\
\ LDX #&11              \ Set X = &11, so ZP(1 0) will point to &1100 when we
\                       \ stick X in ZP+1 below
\
\ TXA                   \ Set A = &11 = 17, to set the intial value of the
\                       \ checksum to 18 (17 plus carry)
\
\.l1
\
\ STX ZP+1              \ Set the high byte of ZP(1 0) to the page number in X
\
\ ADC (ZP),Y            \ Set A = A + the Y-th byte of ZP(1 0)
\
\ DEY                   \ Decrement the byte pointer
\
\ BNE l1                \ Loop back to add the next byte until we have added the
\                       \ whole page
\
\ INX                   \ Increment the page number in X
\
\ CPX #&54              \ Loop back to checksum the next page until we have
\ BCC l1                \ checked up to (but not including) page &54
\
\ CMP &55FF             \ Compare the checksum with the value in &55FF, which is
\                       \ in the docked file we just loaded, in the byte before
\                       \ the ship hanger blueprints at XX21
\
\IF _REMOVE_CHECKSUMS
\
\ NOP                   \ If we have disabled checksums, then ignore the result
\ NOP                   \ of the checksum comparison
\
\ELSE
\
\ BNE P%                \ If the checksums don't match then enter an infinite
\                       \ loop, which hangs the computer
\
\ENDIF

                        \ --- End of removed code ----------------------------->

 JMP S%+3               \ Jump to the second entry in the main docked code's S%
                        \ workspace to start a new game

.LTLI

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUS "L.T.CODE"
\ EQUB 13
\
\ EQUB &44, &6F, &65    \ These bytes appear to be unused
\ EQUB &73, &20, &79
\ EQUB &6F, &75, &72
\ EQUB &20, &6D, &6F
\ EQUB &74, &68, &65
\ EQUB &72, &20, &6B
\ EQUB &6E, &6F, &77
\ EQUB &20, &79, &6F
\ EQUB &75, &20, &64
\ EQUB &6F, &20, &74
\ EQUB &68, &69, &73
\ EQUB &3F

                        \ --- And replaced by: -------------------------------->

 EQUS "L.1.D"
 EQUB 13

                        \ --- End of replacement ------------------------------>

COPYBLOCK LOAD, P%, LOADcode

ORG LOADcode + P% - LOAD

\ ******************************************************************************
\
\       Name: PLL1
\       Type: Subroutine
\   Category: Drawing planets
\    Summary: Draw Saturn on the loading screen
\  Deep dive: Drawing Saturn on the loading screen
\
\ ******************************************************************************

.PLL1

                        \ The following loop iterates CNT(1 0) times, i.e. &300
                        \ or 768 times, and draws the planet part of the
                        \ loading screen's Saturn

 LDA VIA+&44            \ Read the 6522 System VIA T1C-L timer 1 low-order
 STA RAND+1             \ counter (SHEILA &44), which increments 1000 times a
                        \ second so this will be pretty random, and store it in
                        \ RAND+1 among the hard-coded random seeds in RAND

 JSR DORND              \ Set A and X to random numbers, say A = r1

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r1^2

 STA ZP+1               \ Set ZP(1 0) = (A P)
 LDA P                  \             = r1^2
 STA ZP

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #LO(OSBmod)       \ As part of the copy protection, the JSR OSB
\ STA OSBjsr+1          \ instruction at OSBjsr gets modified to point to OSBmod
\                       \ instead of OSB, and this is where we modify the low
\                       \ byte of the destination address

                        \ --- End of removed code ----------------------------->

 JSR DORND              \ Set A and X to random numbers, say A = r2

 STA YY                 \ Set YY = A
                        \        = r2

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r2^2

 TAX                    \ Set (X P) = (A P)
                        \           = r2^2

 LDA P                  \ Set (A ZP) = (X P) + ZP(1 0)
 ADC ZP                 \
 STA ZP                 \ first adding the low bytes

 TXA                    \ And then adding the high bytes
 ADC ZP+1

 BCS PLC1               \ If the addition overflowed, jump down to PLC1 to skip
                        \ to the next pixel

 STA ZP+1               \ Set ZP(1 0) = (A ZP)
                        \             = r1^2 + r2^2

 LDA #1                 \ Set ZP(1 0) = &4001 - ZP(1 0) - (1 - C)
 SBC ZP                 \             = 128^2 - ZP(1 0)
 STA ZP                 \
                        \ (as the C flag is clear), first subtracting the low
                        \ bytes

 LDA #&40               \ And then subtracting the high bytes
 SBC ZP+1
 STA ZP+1

 BCC PLC1               \ If the subtraction underflowed, jump down to PLC1 to
                        \ skip to the next pixel

                        \ If we get here, then both calculations fitted into
                        \ 16 bits, and we have:
                        \
                        \   ZP(1 0) = 128^2 - (r1^2 + r2^2)
                        \
                        \ where ZP(1 0) >= 0

 JSR ROOT               \ Set ZP = SQRT(ZP(1 0))

 LDA ZP                 \ Set X = ZP >> 1
 LSR A                  \       = SQRT(128^2 - (a^2 + b^2)) / 2
 TAX

 LDA YY                 \ Set A = YY
                        \       = r2

 CMP #128               \ If YY >= 128, set the C flag (so the C flag is now set
                        \ to bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 6 and 7 are now the same, i.e. A is a random number in
                        \ one of these ranges:
                        \
                        \   %00000000 - %00111111  = 0 to 63    (r2 = 0 - 127)
                        \   %11000000 - %11111111  = 192 to 255 (r2 = 128 - 255)
                        \
                        \ The PIX routine flips bit 7 of A before drawing, and
                        \ that makes -A in these ranges:
                        \
                        \   %10000000 - %10111111  = 128-191
                        \   %01000000 - %01111111  = 64-127
                        \
                        \ so that's in the range 64 to 191

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), i.e. at
                        \
                        \   (ZP / 2, -A)
                        \
                        \ where ZP = SQRT(128^2 - (r1^2 + r2^2))
                        \
                        \ So this is the same as plotting at (x, y) where:
                        \
                        \   r1 = random number from 0 to 255
                        \   r1 = random number from 0 to 255
                        \   (r1^2 + r1^2) < 128^2
                        \
                        \   y = r2, squished into 64 to 191 by negation
                        \
                        \   x = SQRT(128^2 - (r1^2 + r1^2)) / 2
                        \
                        \ which is what we want

.PLC1

 DEC CNT                \ Decrement the counter in CNT (the low byte)

 BNE PLL1               \ Loop back to PLL1 until CNT = 0

 DEC CNT+1              \ Decrement the counter in CNT+1 (the high byte)

 BNE PLL1               \ Loop back to PLL1 until CNT+1 = 0

                        \ The following loop iterates CNT2(1 0) times, i.e. &1DD
                        \ or 477 times, and draws the background stars on the
                        \ loading screen

.PLL2

 JSR DORND              \ Set A and X to random numbers, say A = r3

 TAX                    \ Set X = A
                        \       = r3

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r3^2

 STA ZP+1               \ Set ZP+1 = A
                        \          = r3^2 / 256

 JSR DORND              \ Set A and X to random numbers, say A = r4

 STA YY                 \ Set YY = r4

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r4^2

 ADC ZP+1               \ Set A = A + r3^2 / 256
                        \       = r4^2 / 256 + r3^2 / 256
                        \       = (r3^2 + r4^2) / 256

 CMP #&11               \ If A < 17, jump down to PLC2 to skip to the next pixel
 BCC PLC2

 LDA YY                 \ Set A = r4

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), i.e. at
                        \ (r3, -r4), where (r3^2 + r4^2) / 256 >= 17
                        \
                        \ Negating a random number from 0 to 255 still gives a
                        \ random number from 0 to 255, so this is the same as
                        \ plotting at (x, y) where:
                        \
                        \   x = random number from 0 to 255
                        \   y = random number from 0 to 255
                        \   (x^2 + y^2) div 256 >= 17
                        \
                        \ which is what we want

.PLC2

 DEC CNT2               \ Decrement the counter in CNT2 (the low byte)

 BNE PLL2               \ Loop back to PLL2 until CNT2 = 0

 DEC CNT2+1             \ Decrement the counter in CNT2+1 (the high byte)

 BNE PLL2               \ Loop back to PLL2 until CNT2+1 = 0

                        \ The following loop iterates CNT3(1 0) times, i.e. &333
                        \ or 819 times, and draws the rings around the loading
                        \ screen's Saturn

.PLL3

 JSR DORND              \ Set A and X to random numbers, say A = r5

 STA ZP                 \ Set ZP = r5

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r5^2

 STA ZP+1               \ Set ZP+1 = A
                        \          = r5^2 / 256

                        \ --- Original Acornsoft code removed: ---------------->

\ LDA #HI(OSBmod)       \ As part of the copy protection, the JSR OSB
\ STA OSBjsr+2          \ instruction at OSBjsr gets modified to point to OSBmod
\                       \ instead of OSB, and this is where we modify the high
\                       \ byte of the destination address

                        \ --- End of removed code ----------------------------->

 JSR DORND              \ Set A and X to random numbers, say A = r6

 STA YY                 \ Set YY = r6

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r6^2

 STA T                  \ Set T = A
                        \       = r6^2 / 256

 ADC ZP+1               \ Set ZP+1 = A + r5^2 / 256
 STA ZP+1               \          = r6^2 / 256 + r5^2 / 256
                        \          = (r5^2 + r6^2) / 256

 LDA ZP                 \ Set A = ZP
                        \       = r5

 CMP #128               \ If A >= 128, set the C flag (so the C flag is now set
                        \ to bit 7 of ZP, i.e. bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 6 and 7 are now the same

 CMP #128               \ If A >= 128, set the C flag (so again, the C flag is
                        \ set to bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 5-7 are now the same, i.e. A is a random number in one
                        \ of these ranges:
                        \
                        \   %00000000 - %00011111  = 0-31
                        \   %11100000 - %11111111  = 224-255
                        \
                        \ In terms of signed 8-bit integers, this is a random
                        \ number from -32 to 31. Let's call it r7

 ADC YY                 \ Set X = A + YY
 TAX                    \       = r7 + r6

 JSR SQUA2              \ Set (A P) = r7 * r7

 TAY                    \ Set Y = A
                        \       = r7 * r7 / 256

 ADC ZP+1               \ Set A = A + ZP+1
                        \       = r7^2 / 256 + (r5^2 + r6^2) / 256
                        \       = (r5^2 + r6^2 + r7^2) / 256

 BCS PLC3               \ If the addition overflowed, jump down to PLC3 to skip
                        \ to the next pixel

 CMP #80                \ If A >= 80, jump down to PLC3 to skip to the next
 BCS PLC3               \ pixel

 CMP #32                \ If A < 32, jump down to PLC3 to skip to the next pixel
 BCC PLC3

 TYA                    \ Set A = Y + T
 ADC T                  \       = r7^2 / 256 + r6^2 / 256
                        \       = (r6^2 + r7^2) / 256

 CMP #16                \ If A > 16, skip to PL1 to plot the pixel
 BCS PL1

 LDA ZP                 \ If ZP is positive (50% chance), jump down to PLC3 to
 BPL PLC3               \ skip to the next pixel

.PL1

 LDA YY                 \ Set A = YY
                        \       = r6

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), where:
                        \
                        \   X = (random -32 to 31) + r6
                        \   A = r6
                        \
                        \ Negating a random number from 0 to 255 still gives a
                        \ random number from 0 to 255, so this is the same as
                        \ plotting at (x, y) where:
                        \
                        \   r5 = random number from 0 to 255
                        \   r6 = random number from 0 to 255
                        \   r7 = r5, squashed into -32 to 31
                        \
                        \   x = r5 + r7
                        \   y = r5
                        \
                        \   32 <= (r5^2 + r6^2 + r7^2) / 256 <= 79
                        \   Draw 50% fewer pixels when (r6^2 + r7^2) / 256 <= 16
                        \
                        \ which is what we want

.PLC3

 DEC CNT3               \ Decrement the counter in CNT3 (the low byte)

 BNE PLL3               \ Loop back to PLL3 until CNT3 = 0

 DEC CNT3+1             \ Decrement the counter in CNT3+1 (the high byte)

 BNE PLL3               \ Loop back to PLL3 until CNT3+1 = 0

 LDA #&00               \ Set ZP(1 0) = &6300
 STA ZP
 LDA #&63
 STA ZP+1

 LDA #&62               \ Set P(1 0) = &2A62
 STA P
 LDA #&2A
 STA P+1

 LDX #8                 \ Call MVPG with X = 8 to copy 8 pages of memory from
 JSR MVPG               \ the address in P(1 0) to the address in ZP(1 0)

\ ******************************************************************************
\
\       Name: DORND
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Generate random numbers
\  Deep dive: Generating random numbers
\
\ ------------------------------------------------------------------------------
\
\ Set A and X to random numbers (though note that X is set to the random number
\ that was returned in A the last time DORND was called).
\
\ The C and V flags are also set randomly.
\
\ This is a simplified version of the DORND routine in the main game code. It
\ swaps the two calculations around and omits the ROL A instruction, but is
\ otherwise very similar. See the DORND routine in the main game code for more
\ details.
\
\ ******************************************************************************

.DORND

 LDA RAND+1             \ r1´ = r1 + r3 + C
 TAX                    \ r3´ = r1
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 LDA RAND               \ X = r2´ = r0
 TAX                    \ A = r0´ = r0 + r2
 ADC RAND+2
 STA RAND
 STX RAND+2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: RAND
\       Type: Variable
\   Category: Drawing planets
\    Summary: The random number seed used for drawing Saturn
\
\ ******************************************************************************

.RAND

 EQUD &34785349

\ ******************************************************************************
\
\       Name: SQUA2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = A * A
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of unsigned 8-bit numbers:
\
\   (A P) = A * A
\
\ This uses the same approach as routine SQUA2 in the main game code, which
\ itself uses the MU11 routine to do the multiplication. See those routines for
\ more details.
\
\ ******************************************************************************

.SQUA2

 BPL SQUA               \ If A > 0, jump to SQUA

 EOR #&FF               \ Otherwise we need to negate A for the SQUA algorithm
 CLC                    \ to work, so we do this using two's complement, by
 ADC #1                 \ setting A = ~A + 1

.SQUA

 STA Q                  \ Set Q = A and P = A

 STA P                  \ Set P = A

 LDA #0                 \ Set A = 0 so we can start building the answer in A

 LDY #8                 \ Set up a counter in Y to count the 8 bits in P

 LSR P                  \ Set P = P >> 1
                        \ and C flag = bit 0 of P

.SQL1

 BCC SQ1                \ If C (i.e. the next bit from P) is set, do the
 CLC                    \ addition for this bit of P:
 ADC Q                  \
                        \   A = A + Q

.SQ1

 ROR A                  \ Shift A right to catch the next digit of our result,
                        \ which the next ROR sticks into the left end of P while
                        \ also extracting the next bit of P

 ROR P                  \ Add the overspill from shifting A to the right onto
                        \ the start of P, and shift P right to fetch the next
                        \ bit for the calculation into the C flag

 DEY                    \ Decrement the loop counter

 BNE SQL1               \ Loop back for the next bit until P has been rotated
                        \ all the way

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: PIX
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single pixel at a specific coordinate
\
\ ------------------------------------------------------------------------------
\
\ Draw a pixel at screen coordinate (X, -A). The sign bit of A gets flipped
\ before drawing, and then the routine uses the same approach as the PIXEL
\ routine in the main game code, except it plots a single pixel from TWOS
\ instead of a two pixel dash from TWOS2. This applies to the top part of the
\ screen (the monochrome mode 4 space view).
\
\ See the PIXEL routine in the main game code for more details.
\
\ Arguments:
\
\   X                   The screen x-coordinate of the pixel to draw
\
\   A                   The screen y-coordinate of the pixel to draw, negated
\
\ Other entry points:
\
\   out                 Contains an RTS
\
\ ******************************************************************************

.PIX

 TAY                    \ Copy A into Y, for use later

 EOR #%10000000         \ Flip the sign of A

 LSR A                  \ Set A = A >> 3
 LSR A
 LSR A

 LSR CHKSM+1            \ Rotate the high byte of CHKSM+1 to the right, as part
                        \ of the copy protection

 ORA #&60               \ Set ZP+1 = &60 + A >> 3
 STA ZP+1

 TXA                    \ Set ZP = (X >> 3) * 8
 EOR #%10000000
 AND #%11111000
 STA ZP

 TYA                    \ Set Y = Y AND %111
 AND #%00000111
 TAY

 TXA                    \ Set X = X AND %111
 AND #%00000111
 TAX

 LDA TWOS,X             \ Fetch a pixel from TWOS and poke it into ZP+Y
 STA (ZP),Y

.out

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 4 (the top part of the
\ split screen). See the PIX routine for details.
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
\       Name: CNT
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's planetary body
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL1 loop, which draws the planet part
\ of the loading screen's Saturn.
\
\ ******************************************************************************

.CNT

 EQUW &0300             \ The number of iterations of the PLL1 loop (768)

\ ******************************************************************************
\
\       Name: CNT2
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's background stars
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL2 loop, which draws the background
\ stars on the loading screen.
\
\ ******************************************************************************

.CNT2

 EQUW &01DD             \ The number of iterations of the PLL2 loop (477)

\ ******************************************************************************
\
\       Name: CNT3
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's rings
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL3 loop, which draws the rings
\ around the loading screen's Saturn.
\
\ ******************************************************************************

.CNT3

 EQUW &0333             \ The number of iterations of the PLL3 loop (819)

\ ******************************************************************************
\
\       Name: PROT3
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Part of the CHKSM copy protection checksum calculation
\
\ ******************************************************************************

.PROT3

 LDA CHKSM              \ Update the checksum
 AND CHKSM+1
 ORA #&0C
 ASL A
 STA CHKSM

 RTS                    \ Return from the subroutine

                        \ --- Original Acornsoft code removed: ---------------->

\ JMP P%                \ This would hang the computer, but we never get here as
\                       \ the checksum code has been disabled

                        \ --- End of removed code ----------------------------->

\ ******************************************************************************
\
\       Name: ROOT
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate ZP = SQRT(ZP(1 0))
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following square root:
\
\   ZP = SQRT(ZP(1 0))
\
\ This routine is identical to LL5 in the main game code - it even has the same
\ label names. The only difference is that LL5 calculates Q = SQRT(R Q), but
\ apart from the variables used, the instructions are identical, so see the LL5
\ routine in the main game code for more details on the algorithm used here.
\
\ ******************************************************************************

.ROOT

 LDY ZP+1               \ Set (Y Q) = ZP(1 0)
 LDA ZP
 STA Q

                        \ So now to calculate ZP = SQRT(Y Q)

 LDX #0                 \ Set X = 0, to hold the remainder

 STX ZP                 \ Set ZP = 0, to hold the result

 LDA #8                 \ Set P = 8, to use as a loop counter
 STA P

.LL6

 CPX ZP                 \ If X < ZP, jump to LL7
 BCC LL7

 BNE LL8                \ If X > ZP, jump to LL8

 CPY #64                \ If Y < 64, jump to LL7 with the C flag clear,
 BCC LL7                \ otherwise fall through into LL8 with the C flag set

.LL8

 TYA                    \ Set Y = Y - 64
 SBC #64                \
 TAY                    \ This subtraction will work as we know C is set from
                        \ the BCC above, and the result will not underflow as we
                        \ already checked that Y >= 64, so the C flag is also
                        \ set for the next subtraction

 TXA                    \ Set X = X - ZP
 SBC ZP
 TAX

.LL7

 ROL ZP                 \ Shift the result in Q to the left, shifting the C flag
                        \ into bit 0 and bit 7 into the C flag

 ASL Q                  \ Shift the dividend in (Y S) to the left, inserting
 TYA                    \ bit 7 from above into bit 0
 ROL A
 TAY

 TXA                    \ Shift the remainder in X to the left
 ROL A
 TAX

 ASL Q                  \ Shift the dividend in (Y S) to the left
 TYA
 ROL A
 TAY

 TXA                    \ Shift the remainder in X to the left
 ROL A
 TAX

 DEC P                  \ Decrement the loop counter

 BNE LL6                \ Loop back to LL6 until we have done 8 loops

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: OSB
\       Type: Subroutine
\   Category: Utility routines
\    Summary: A convenience routine for calling OSBYTE with Y = 0
\
\ ******************************************************************************

.OSB

 LDY #0                 \ Call OSBYTE with Y = 0, returning from the subroutine
 JMP OSBYTE             \ using a tail call (so we can call OSB to call OSBYTE
                        \ for when we know we want Y set to 0)

\ ******************************************************************************
\
\       Name: MVPG
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Decrypt and move a page of memory
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   P(1 0)              The source address of the page to move
\
\   ZP(1 0)             The destination address of the page to move
\
\ ******************************************************************************

.MVPG

 LDY #0                 \ We want to move one page of memory, so set Y as a byte
                        \ counter

.MPL

 LDA (P),Y              \ Fetch the Y-th byte of the P(1 0) memory block

                        \ --- Original Acornsoft code removed: ---------------->

\ EOR #&A5              \ Decrypt it by EOR'ing with &A5

                        \ --- End of removed code ----------------------------->

 STA (ZP),Y             \ Store the decrypted result in the Y-th byte of the
                        \ ZP(1 0) memory block

 DEY                    \ Decrement the byte counter

 BNE MPL                \ Loop back to copy the next byte until we have done a
                        \ whole page of 256 bytes

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVBL
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Decrypt and move a multi-page block of memory
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   P(1 0)              The source address of the block to move
\
\   ZP(1 0)             The destination address of the block to move
\
\   X                   Number of pages of memory to move (1 page = 256 bytes)
\
\ ******************************************************************************

.MVBL

 JSR MVPG               \ Call MVPG above to copy one page of memory from the
                        \ address in P(1 0) to the address in ZP(1 0)

 INC ZP+1               \ Increment the high byte of the source address to point
                        \ to the next page

 INC P+1                \ Increment the high byte of the destination address to
                        \ point to the next page

 DEX                    \ Decrement the page counter

 BNE MVBL               \ Loop back to copy the next page until we have done X
                        \ pages

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for changing the disc directory to E
\
\ ******************************************************************************

.MESS1

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUS "*DIR E"
\ EQUB 13

                        \ --- And replaced by: -------------------------------->

 EQUS "DIR e"
 EQUB 13

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: Elite loader (Part 2 of 3)
\       Type: Subroutine
\   Category: Loader
\    Summary: Include binaries for recursive tokens, Missile blueprint and
\             images
\
\ ------------------------------------------------------------------------------
\
\ The loader bundles a number of binary files in with the loader code, and moves
\ them to their correct memory locations in part 1 above.
\
\ This section is encrypted by EOR'ing with &A5. The encryption is done by the
\ elite-checksum.py script, and decryption is done in part 1 above, at the same
\ time as each block is moved to its correct location.
\
\ There are two files containing code:
\
\   * WORDS.bin contains the recursive token table, which is moved to &0400
\     before the main game is loaded
\
\   * MISSILE.bin contains the missile ship blueprint, which gets moved to &7F00
\     before the main game is loaded
\
\ and one file containing an image, which is moved into screen memory by the
\ loader:
\
\   * P.DIALS.bin contains the dashboard, which gets moved to screen address
\     &7800, which is the starting point of the four-colour mode 5 portion at
\     the bottom of the split screen
\
\ There are three other image binaries bundled into the loader, which are
\ described in part 3 below.
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

.DIALS

 INCBIN "binaries/P.DIALS.bin"

.SHIP_MISSILE

 INCBIN "output/MISSILE.bin"

.WORDS

 INCBIN "output/WORDS.bin"

                        \ --- End of added section ---------------------------->

\ ******************************************************************************
\
\       Name: TVT1code
\       Type: Subroutine
\   Category: Loader
\    Summary: Code block at &1100-&11E2 that remains resident in both docked and
\             flight mode (palettes, screen mode routine and commander data)
\
\ ******************************************************************************

.TVT1code

ORG &1100

\ ******************************************************************************
\
\       Name: TVT1
\       Type: Variable
\   Category: Screen mode
\    Summary: Palette data for space and the two dashboard colour schemes
\
\ ------------------------------------------------------------------------------
\
\ Palette bytes for use with the split-screen mode (see IRQ1 below for more
\ details).
\
\ Palette data is given as a set of bytes, with each byte mapping a logical
\ colour to a physical one. In each byte, the logical colour is given in bits
\ 4-7 and the physical colour in bits 0-3. See p.379 of the Advanced User Guide
\ for details of how palette mapping works, as in modes 4 and 5 we have to do
\ multiple palette commands to change the colours correctly, and the physical
\ colour value is EOR'd with 7, just to make things even more confusing.
\
\ Similarly, the palette at TVT1+16 is for the monochrome space view, where
\ logical colour 1 is mapped to physical colour 0 EOR 7 = 7 (white), and
\ logical colour 0 is mapped to physical colour 7 EOR 7 = 0 (black). Each of
\ these mappings requires six calls to SHEILA &21 - see p.379 of the Advanced
\ User Guide for an explanation.
\
\ The mode 5 palette table has two blocks which overlap. The block used depends
\ on whether or not we have an escape pod fitted. The block at TVT1 is used for
\ the standard dashboard colours, while TVT1+8 is used for the dashboard when an
\ escape pod is fitted. The colours are as follows:
\
\                 Normal (TVT1)     Escape pod (TVT1+8)
\
\   Colour 0      Black             Black
\   Colour 1      Red               Red
\   Colour 2      Yellow            White
\   Colour 3      Green             Cyan
\
\ ******************************************************************************

.TVT1

 EQUB &D4, &C4          \ This block of palette data is used to create two
 EQUB &94, &84          \ palettes used in three different places, all of them
 EQUB &F5, &E5          \ redefining four colours in mode 5:
 EQUB &B5, &A5          \
                        \ 12 bytes from TVT1 (i.e. the first 6 rows): applied
 EQUB &76, &66          \ when the T1 timer runs down at the switch from the
 EQUB &36, &26          \ space view to the dashboard, so this is the standard
                        \ dashboard palette
 EQUB &E1, &F1          \
 EQUB &B1, &A1          \ 8 bytes from TVT1+8 (i.e. the last 4 rows): applied
                        \ when the T1 timer runs down at the switch from the
                        \ space view to the dashboard, and we have an escape
                        \ pod fitted, so this is the escape pod dashboard
                        \ palette
                        \
                        \ 8 bytes from TVT1+8 (i.e. the last 4 rows): applied
                        \ at vertical sync in LINSCN when HFX is non-zero, to
                        \ create the hyperspace effect in LINSCN (where the
                        \ whole screen is switched to mode 5 at vertical sync)

 EQUB &F0, &E0          \ 12 bytes of palette data at TVT1+16, used to set the
 EQUB &B0, &A0          \ mode 4 palette in LINSCN when we hit vertical sync,
 EQUB &D0, &C0          \ so the palette is set to monochrome when we start to
 EQUB &90, &80          \ draw the first row of the screen
 EQUB &77, &67
 EQUB &37, &27

\ ******************************************************************************
\
\       Name: IRQ1
\       Type: Subroutine
\   Category: Screen mode
\    Summary: The main screen-mode interrupt handler (IRQ1V points here)
\  Deep dive: The split-screen mode
\
\ ------------------------------------------------------------------------------
\
\ The main interrupt handler, which implements Elite's split-screen mode (see
\ the deep dive on "The split-screen mode" for details).
\
\ IRQ1V is set to point to IRQ1 by the loading process.
\
\ ******************************************************************************

.LINSCN

                        \ This is called from the interrupt handler below, at
                        \ the start of each vertical sync (i.e. when the screen
                        \ refresh starts)

 LDA #30                \ Set the line scan counter to a non-zero value, so
 STA DL                 \ routines like WSCAN can set DL to 0 and then wait for
                        \ it to change to non-zero to catch the vertical sync

 STA VIA+&44            \ Set 6522 System VIA T1C-L timer 1 low-order counter
                        \ (SHEILA &44) to 30

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA VIA+&45            \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14622 at a rate of 1 MHz

 LDA HFX                \ If HFX is non-zero, jump to VNT1 to set the mode 5
 BNE VNT1               \ palette instead of switching to mode 4, which will
                        \ have the effect of blurring and colouring the top
                        \ screen. This is how the white hyperspace rings turn
                        \ to colour when we do a hyperspace jump, and is
                        \ triggered by setting HFX to 1 in routine LL164

 LDA #%00001000         \ Set the Video ULA control register (SHEILA &20) to
 STA VIA+&20            \ %00001000, which is the same as switching to mode 4
                        \ (i.e. the top part of the screen) but with no cursor

.VNT3

 LDA TVT1+16,Y          \ Copy the Y-th palette byte from TVT1+16 to SHEILA &21
 STA VIA+&21            \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BPL VNT3               \ Loop back to VNT3 until we have copied all the
                        \ palette bytes

 LDA LASCT              \ Decrement the value of LASCT, but if we go too far
 BEQ P%+5               \ and it becomes negative, bump it back up again (this
 DEC LASCT              \ controls the pulsing of pulse lasers)

 PLA                    \ Otherwise restore Y from the stack
 TAY

 LDA VIA+&41            \ Read 6522 System VIA input register IRA (SHEILA &41)

 LDA &FC                \ Set A to the interrupt accumulator save register,
                        \ which restores A to the value it had on entering the
                        \ interrupt

 RTI                    \ Return from interrupts, so this interrupt is not
                        \ passed on to the next interrupt handler, but instead
                        \ the interrupt terminates here

.IRQ1

 TYA                    \ Store Y on the stack
 PHA

 LDY #11                \ Set Y as a counter for 12 bytes, to use when setting
                        \ the dashboard palette below

 LDA #%00000010         \ Read the 6522 System VIA status byte bit 1 (SHEILA
 BIT VIA+&4D            \ &4D), which is set if vertical sync has occurred on
                        \ the video system

 BNE LINSCN             \ If we are on the vertical sync pulse, jump to LINSCN
                        \ to set up the timers to enable us to switch the
                        \ screen mode between the space view and dashboard

 BVC jvec               \ Read the 6522 System VIA status byte bit 6, which is
                        \ set if timer 1 has timed out. We set the timer in
                        \ LINSCN above, so this means we only run the next bit
                        \ if the screen redraw has reached the boundary between
                        \ the space view and the dashboard. Otherwise bit 6 is
                        \ clear and we aren't at the boundary, so we jump to
                        \ jvec to pass control to the next interrupt handler

 ASL A                  \ Double the value in A to 4

 STA VIA+&20            \ Set the Video ULA control register (SHEILA &20) to
                        \ %00000100, which is the same as switching to mode 5,
                        \ (i.e. the bottom part of the screen) but with no
                        \ cursor

 LDA ESCP               \ If an escape pod is fitted, jump to VNT1 to set the
 BNE VNT1               \ mode 5 palette differently (so the dashboard is a
                        \ different colour if we have an escape pod)

 LDA TVT1,Y             \ Copy the Y-th palette byte from TVT1 to SHEILA &21
 STA VIA+&21            \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BPL P%-7               \ Loop back to the LDA TVT1,Y instruction until we have
                        \ copied all the palette bytes

.jvec

 PLA                    \ Restore Y from the stack
 TAY

 JMP (VEC)              \ Jump to the address in VEC, which was set to the
                        \ original IRQ1V vector by the loading process, so this
                        \ instruction passes control to the next interrupt
                        \ handler

.VNT1

 LDY #7                 \ Set Y as a counter for 8 bytes

 LDA TVT1+8,Y           \ Copy the Y-th palette byte from TVT1+8 to SHEILA &21
 STA VIA+&21            \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BPL VNT1+2             \ Loop back to the LDA TVT1+8,Y instruction until we
                        \ have copied all the palette bytes

 BMI jvec               \ Jump up to jvec to pass control to the next interrupt
                        \ handler (this BMI is effectively a JMP as we didn't
                        \ loop back with the BPL above, so BMI is always true)

\ ******************************************************************************
\
\       Name: S1%
\       Type: Variable
\   Category: Save and load
\    Summary: The drive and directory number used when saving or loading a
\             commander file
\  Deep dive: Commander save files.
\
\ ------------------------------------------------------------------------------
\
\ The drive part of this string (the "0") is updated with the chosen drive in
\ the QUS1 routine, but the directory part (the "E") is fixed. The variable is
\ followed directly by the commander file at NA%, which starts with the
\ commander name, so the full string at S1% is in the format ":0.E.JAMESON",
\ which gives the full filename of the commander file.
\
\ ******************************************************************************

.S1%

 EQUS ":0.E."

\ ******************************************************************************
\
\       Name: NA%
\       Type: Variable
\   Category: Save and load
\    Summary: The data block for the last saved commander
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Contains the last saved commander data, with the name at NA% and the data at
\ NA%+8 onwards. The size of the data block is given in NT% (which also includes
\ the two checksum bytes that follow this block). This block is initially set up
\ with the default commander, which can be maxed out for testing purposes by
\ setting Q% to TRUE.
\
\ The commander's name is stored at NA%, and can be up to 7 characters long
\ (the DFS filename limit). It is terminated with a carriage return character,
\ ASCII 13.
\
\ The offset of each byte within a saved commander file is also shown as #0, #1
\ and so on, so the kill tally, for example, is in bytes #71 and #72 of the
\ saved file. The related variable name from the current commander block is
\ also shown.
\
\ ******************************************************************************

.NA%

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUS "JAMESON"        \ The current commander name, which defaults to JAMESON
\ EQUB 13               \
\                       \ The commander name can be up to 7 characters (the DFS
\                       \ limit for file names), and is terminated by a carriage
\                       \ return

                        \ --- And replaced by: -------------------------------->

 EQUS "NEWCOME"         \ The current commander name, which defaults to NEWCOME
 EQUB 13                \
                        \ The commander name can be up to 7 characters (the DFS
                        \ limit for file names), and is terminated by a carriage
                        \ return

                        \ --- End of replacement ------------------------------>

                        \ NA%+8 is the start of the commander data block
                        \
                        \ This block contains the last saved commander data
                        \ block. As the game is played it uses an identical
                        \ block at location TP to store the current commander
                        \ state, and that block is copied here when the game is
                        \ saved. Conversely, when the game starts up, the block
                        \ here is copied to TP, which restores the last saved
                        \ commander when we die
                        \
                        \ The initial state of this block defines the default
                        \ commander. Q% can be set to TRUE to give the default
                        \ commander lots of credits and equipment

 EQUB 0                 \ TP = Mission status, #0

 EQUB 20                \ QQ0 = Current system X-coordinate (Lave), #1
 EQUB 173               \ QQ1 = Current system Y-coordinate (Lave), #2

 EQUW &5A4A             \ QQ21 = Seed s0 for system 0, galaxy 0 (Tibedied), #3-4
 EQUW &0248             \ QQ21 = Seed s1 for system 0, galaxy 0 (Tibedied), #5-6
 EQUW &B753             \ QQ21 = Seed s2 for system 0, galaxy 0 (Tibedied), #7-8

                        \ --- Original Acornsoft code removed: ---------------->

\IF Q%
\ EQUD &00CA9A3B        \ CASH = Amount of cash (100,000,000 Cr), #9-12
\ELSE
\ EQUD &E8030000        \ CASH = Amount of cash (100 Cr), #9-12
\ENDIF
\
\ EQUB 70               \ QQ14 = Fuel level, #13

                        \ --- And replaced by: -------------------------------->

IF Q%
 EQUD &00CA9A3B         \ CASH = Amount of cash (100,000,000 Cr), #9-12
ELSE
 EQUD &88130000         \ CASH = Amount of cash (500 Cr), #9-12
ENDIF

 EQUB 60                \ QQ14 = Fuel level, #13

                        \ --- End of replacement ------------------------------>

 EQUB 0                 \ COK = Competition flags, #14

 EQUB 0                 \ GCNT = Galaxy number, 0-7, #15

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB POW+(128 AND Q%) \ LASER = Front laser, #16
\
\ EQUB (POW+128) AND Q% \ LASER+1 = Rear laser, #17

                        \ --- And replaced by: -------------------------------->

 EQUB 0                 \ LASER = Front laser, #16

 EQUB 0                 \ LASER+1 = Rear laser, #17

                        \ --- End of replacement ------------------------------>

 EQUB 0                 \ LASER+2 = Left laser, #18

 EQUB 0                 \ LASER+3 = Right laser, #19

 EQUW 0                 \ These bytes appear to be unused (they were originally
                        \ used for up/down lasers, but they were dropped),
                        \ #20-21

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB 22+(15 AND Q%)   \ CRGO = Cargo capacity, #22

                        \ --- And replaced by: -------------------------------->

 EQUB 0                 \ CRGO = Cargo capacity, #22

                        \ --- End of replacement ------------------------------>

 EQUB 0                 \ QQ20+0  = Amount of food in cargo hold, #23
 EQUB 0                 \ QQ20+1  = Amount of textiles in cargo hold, #24
 EQUB 0                 \ QQ20+2  = Amount of radioactives in cargo hold, #25
 EQUB 0                 \ QQ20+3  = Amount of slaves in cargo hold, #26
 EQUB 0                 \ QQ20+4  = Amount of liquor/Wines in cargo hold, #27
 EQUB 0                 \ QQ20+5  = Amount of luxuries in cargo hold, #28
 EQUB 0                 \ QQ20+6  = Amount of narcotics in cargo hold, #29
 EQUB 0                 \ QQ20+7  = Amount of computers in cargo hold, #30
 EQUB 0                 \ QQ20+8  = Amount of machinery in cargo hold, #31
 EQUB 0                 \ QQ20+9  = Amount of alloys in cargo hold, #32
 EQUB 0                 \ QQ20+10 = Amount of firearms in cargo hold, #33
 EQUB 0                 \ QQ20+11 = Amount of furs in cargo hold, #34
 EQUB 0                 \ QQ20+12 = Amount of minerals in cargo hold, #35
 EQUB 0                 \ QQ20+13 = Amount of gold in cargo hold, #36
 EQUB 0                 \ QQ20+14 = Amount of platinum in cargo hold, #37
 EQUB 0                 \ QQ20+15 = Amount of gem-stones in cargo hold, #38
 EQUB 0                 \ QQ20+16 = Amount of alien items in cargo hold, #39

 EQUB Q%                \ ECM = E.C.M., #40

 EQUB Q%                \ BST = Fuel scoops ("barrel status"), #41

 EQUB Q% AND 127        \ BOMB = Hyperspace unit, #42

 EQUB Q% AND 1          \ ENGY = Energy/shield level, #43

 EQUB Q%                \ DKCMP = Docking computer, #44

 EQUB Q%                \ GHYP = Galactic hyperdrive, #45

 EQUB Q%                \ ESCP = Escape pod, #46

 EQUD 0                 \ These four bytes appear to be unused, #47-50

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB 3+(Q% AND 1)     \ NOMSL = Number of missiles, #51

                        \ --- And replaced by: -------------------------------->

 EQUB 0                 \ NOMSL = Number of missiles, #51

                        \ --- End of replacement ------------------------------>

 EQUB 0                 \ FIST = Legal status ("fugitive/innocent status"), #52

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB 16               \ AVL+0  = Market availability of food, #53

                        \ --- And replaced by: -------------------------------->

 EQUB 0                 \ AVL+0  = Market availability of food, #53

                        \ --- End of replacement ------------------------------>

 EQUB 15                \ AVL+1  = Market availability of textiles, #54
 EQUB 17                \ AVL+2  = Market availability of radioactives, #55
 EQUB 0                 \ AVL+3  = Market availability of slaves, #56
 EQUB 3                 \ AVL+4  = Market availability of liquor/Wines, #57
 EQUB 28                \ AVL+5  = Market availability of luxuries, #58
 EQUB 14                \ AVL+6  = Market availability of narcotics, #59
 EQUB 0                 \ AVL+7  = Market availability of computers, #60
 EQUB 0                 \ AVL+8  = Market availability of machinery, #61
 EQUB 10                \ AVL+9  = Market availability of alloys, #62
 EQUB 0                 \ AVL+10 = Market availability of firearms, #63
 EQUB 17                \ AVL+11 = Market availability of furs, #64
 EQUB 58                \ AVL+12 = Market availability of minerals, #65
 EQUB 7                 \ AVL+13 = Market availability of gold, #66
 EQUB 9                 \ AVL+14 = Market availability of platinum, #67
 EQUB 8                 \ AVL+15 = Market availability of gem-stones, #68
 EQUB 0                 \ AVL+16 = Market availability of alien items, #69

 EQUB 0                 \ QQ26 = Random byte that changes for each visit to a
                        \ system, for randomising market prices, #70

 EQUW 0                 \ TALLY = Number of kills, #71-72

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB 128              \ SVC = Save count, #73

                        \ --- And replaced by: -------------------------------->

 EQUB 32                \ SVC = Save count, #73

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: CHK2
\       Type: Variable
\   Category: Save and load
\    Summary: Second checksum byte for the saved commander data file
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Second commander checksum byte. If the default commander is changed, a new
\ checksum will be calculated and inserted by the elite-checksum.py script.
\
\ The offset of this byte within a saved commander file is also shown (it's at
\ byte #74).
\
\ ******************************************************************************

.CHK2

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB &03 EOR &A9      \ The checksum value for the default commander, EOR'd
\                       \ with &A9 to make it harder to tamper with the checksum
\                       \ byte, #74

                        \ --- And replaced by: -------------------------------->

 EQUB &58 EOR &A9       \ The checksum value for the default commander, EOR'd
                        \ with &A9 to make it harder to tamper with the checksum
                        \ byte, #74

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: CHK
\       Type: Variable
\   Category: Save and load
\    Summary: First checksum byte for the saved commander data file
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Commander checksum byte. If the default commander is changed, a new checksum
\ will be calculated and inserted by the elite-checksum.py script.
\
\ The offset of this byte within a saved commander file is also shown (it's at
\ byte #75).
\
\ ******************************************************************************

.CHK

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB &03              \ The checksum value for the default commander, #75

                        \ --- And replaced by: -------------------------------->

 EQUB &58               \ The checksum value for the default commander, #75

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: BRBR1
\       Type: Subroutine
\   Category: Loader
\    Summary: Loader break handler: print a newline and the error message, and
\             then hang the computer
\
\ ------------------------------------------------------------------------------
\
\ This break handler is used during loading and during flight, and is resident
\ in memory throughout the game's lifecycle. The docked code loads its own
\ break handler and overrides this one until the flight code is run.
\
\ The main difference between the two handlers is that this one display the
\ error and then hangs, while the docked code displays the error and returns.
\ This is because the docked code has to cope gracefully with errors from the
\ disc access menu (such as "File not found"), which we obviously don't want to
\ terminate the game.
\
\ ******************************************************************************

.BRBR1

                        \ The following loop prints out the null-terminated
                        \ message pointed to by (&FD &FE), which is the MOS
                        \ error message pointer - so this prints the error
                        \ message on the next line

 LDY #0                 \ Set Y = 0 to act as a character counter

 LDA #13                \ Set A = 13 so the first character printed is a
                        \ carriage return

.BRBRLOOP

 JSR OSWRCH             \ Print the character in A (which contains a carriage
                        \ return on the first loop iteration), and then any
                        \ characters we fetch from the error message

 INY                    \ Increment the loop counter

 LDA (&FD),Y            \ Fetch the Y-th byte of the block pointed to by
                        \ (&FD &FE), so that's the Y-th character of the message
                        \ pointed to by the MOS error message pointer

 BNE BRBRLOOP           \ If the fetched character is non-zero, loop back to the
                        \ JSR OSWRCH above to print the it, and keep looping
                        \ until we fetch a zero (which marks the end of the
                        \ message)

 BEQ P%                 \ Hang the computer as something has gone wrong

                        \ --- Original Acornsoft code removed: ---------------->

\ EQUB &64, &5F, &61    \ These bytes appear to be unused
\ EQUB &74, &74, &72
\ EQUB &69, &62, &75
\ EQUB &74, &65, &73
\ EQUB &00, &C4, &24
\ EQUB &6A, &43, &67
\ EQUB &65, &74, &72
\ EQUB &64, &69, &73
\ EQUB &63, &00, &B6
\ EQUB &3C, &C6

                        \ --- End of removed code ----------------------------->

COPYBLOCK TVT1, P%, TVT1code

ORG TVT1code + P% - TVT1

\ ******************************************************************************
\
\       Name: Elite loader (Part 3 of 3)
\       Type: Subroutine
\   Category: Loader
\    Summary: Include binaries for the loading screen images
\
\ ------------------------------------------------------------------------------
\
\ The loader bundles a number of binary files in with the loader code, and moves
\ them to their correct memory locations in part 1 above.
\
\ This section is encrypted by EOR'ing with &A5. The encryption is done by the
\ elite-checksum.py script, and decryption is done in part 1 above, at the same
\ time as each block is moved to its correct location.
\
\ This part includes three files containing images, which are all moved into
\ screen memory by the loader:
\
\   * P.A-SOFT.bin contains the "ACORNSOFT" title across the top of the loading
\     screen, which gets moved to screen address &6100, on the second character
\     row of the monochrome mode 4 screen
\
\   * P.ELITE.bin contains the "ELITE" title across the top of the loading
\     screen, which gets moved to screen address &6300, on the fourth character
\     row of the monochrome mode 4 screen
\
\   * P.(C)ASFT.bin contains the "(C) Acornsoft 1984" title across the bottom
\     of the loading screen, which gets moved to screen address &7600, the
\     penultimate character row of the monochrome mode 4 screen, just above the
\     dashboard
\
\ There are three other binaries bundled into the loader, which are described in
\ part 2 above.
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

.ELITE

 INCBIN "binaries/P.ELITE.bin"

.ASOFT

 INCBIN "binaries/P.A-SOFT.bin"

.CpASOFT

 INCBIN "binaries/P.(C)ASFT.bin"

                        \ --- End of added section ---------------------------->

\ ******************************************************************************
\
\       Name: to_dd00
\       Type: Subroutine
\   Category: Loader
\    Summary: BBC Master 128 code for save/restore characters
\
\ ******************************************************************************

CPU 1

.to_dd00

ORG &DD00

\ ******************************************************************************
\
\       Name: do_FILEV
\       Type: Subroutine
\   Category: Loader
\    Summary: AJD
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

 \ trap FILEV

.do_FILEV

 JSR restorews \ restore workspace

.old_FILEV

 JSR &100 \ address modified by master set-up

.savews

 PHP \ save workspace, copy in characters
 PHA
 PHX
 PHY
 LDA #8 \ select ROM workspace at &C000
 TSB &FE34
 LDX #0

.putws

 LDA &C000,X \ save absolute workspace

.put0

 STA &C000,X \ address modified by master set-up
 LDA &C100,X

.put1

 STA &C100,X \ address modified by master set-up
 LDA &C200,X

.put2

 STA &C200,X \ address modified by master set-up
 INX
 BNE putws
 LDA &F4 \ save ROM number
 PHA
 LDA #&80 \ select RAM from &8000-&8FFF
 STA &F4
 STA &FE30
 LDX #0

.copych

 LDA &8900,X \ copy character definitions
 STA &C000,X
 LDA &8A00,X
 STA &C100,X
 LDA &8B00,X
 STA &C200,X
 INX
 BNE copych
 PLA \ restore ROM selection
 STA &F4
 STA &FE30
 PLY
 PLX
 PLA
 PLP
 RTS

                        \ --- End of added section ---------------------------->

\ ******************************************************************************
\
\       Name: do_FSCV
\       Type: Subroutine
\   Category: Loader
\    Summary: AJD
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

 \ trap FSCV

.do_FSCV

 JSR restorews \ restore workspace

.old_FSCV

 JSR &100 \ address modified by master setup
 JMP savews \ save workspace, restore characters

 \ restore ROM workspace

.restorews

 PHA
 PHX
 LDX #0

.getws

 \ restore absolute workspace

.get0

 LDA &C000,X \ address modified by master set-up
 STA &C000,X

.get1

 LDA &C100,X \ address modified by master set-up
 STA &C100,X

.get2

 LDA &C200,X \ address modified by master set-up
 STA &C200,X
 INX
 BNE getws
 PLX
 PLA
 RTS

                        \ --- End of added section ---------------------------->

\ ******************************************************************************
\
\       Name: do_BYTEV
\       Type: Subroutine
\   Category: Loader
\    Summary: AJD
\
\ ******************************************************************************

                        \ --- Whole section added for Elite-A: ---------------->

 \ trap BYTEV

.do_BYTEV

 CMP #&8F \ ROM service request
 BNE old_BYTEV
 CPX #&F \ vector claim?
 BNE old_BYTEV
 JSR old_BYTEV

.set_vectors

 SEI
 PHA
 LDA #LO(do_FILEV) \ reset FILEV
 STA FILEV
 LDA #HI(do_FILEV)
 STA FILEV+1
 LDA #LO(do_FSCV) \ reset FSCV
 STA FSCV
 LDA #HI(do_FSCV)
 STA FSCV+1
 LDA #LO(do_BYTEV) \ replace BYTEV
 STA BYTEV
 LDA #HI(do_BYTEV)
 STA BYTEV+1
 PLA
 CLI
 RTS

.old_BYTEV

 JMP &100 \ address modified by master set_up

                        \ --- End of added section ---------------------------->

dd00_len = P% - do_FILEV

COPYBLOCK do_FILEV, P%, to_dd00

ORG to_dd00 + P% - do_FILEV

\ ******************************************************************************
\
\ Save output/ELITE.bin
\
\ ******************************************************************************

PRINT "S.ELITE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITE.bin", CODE%, P%, LOAD%
