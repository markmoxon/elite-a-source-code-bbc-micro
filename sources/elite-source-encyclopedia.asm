\ ******************************************************************************
\
\ ELITE-A ENCYCLOPEDIA SOURCE
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
\   * output/1.E.bin
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

LS% = &0CFF             \ The start of the descending ship line heap

NOST = 18               \ The number of stardust particles in normal space (this
                        \ goes down to 3 in witchspace)

NOSH = 12               \ The maximum number of ships in our local bubble of
                        \ universe

NTY = 31                \ The number of different ship types

MSL = 1                 \ Ship type for a missile
SST = 2                 \ Ship type for a Coriolis space station
ESC = 3                 \ Ship type for an escape pod
PLT = 4                 \ Ship type for an alloy plate
OIL = 5                 \ Ship type for a cargo canister
AST = 7                 \ Ship type for an asteroid
SPL = 8                 \ Ship type for a splinter
SHU = 9                 \ Ship type for a Shuttle
CYL = 11                \ Ship type for a Cobra Mk III
ANA = 14                \ Ship type for an Anaconda
COPS = 16               \ Ship type for a Viper
SH3 = 17                \ Ship type for a Sidewinder
KRA = 19                \ Ship type for a Krait
ADA = 20                \ Ship type for a Adder
WRM = 23                \ Ship type for a Worm
CYL2 = 24               \ Ship type for a Cobra Mk III (pirate)
ASP = 25                \ Ship type for an Asp Mk II
THG = 29                \ Ship type for a Thargoid
TGL = 30                \ Ship type for a Thargon
CON = 31                \ Ship type for a Constrictor

JL = ESC                \ Junk is defined as starting from the escape pod

JH = SHU+2              \ Junk is defined as ending before the Cobra Mk III
                        \
                        \ So junk is defined as the following: escape pod,
                        \ alloy plate, cargo canister, asteroid, splinter,
                        \ Shuttle or Transporter

PACK = SH3              \ The first of the eight pack-hunter ships, which tend
                        \ to spawn in groups. With the default value of PACK the
                        \ pack-hunters are the Sidewinder, Mamba, Krait, Adder,
                        \ Gecko, Cobra Mk I, Worm and Cobra Mk III (pirate)

POW = 15                \ Pulse laser power

Mlas = 50               \ Mining laser power

Armlas = INT(128.5+1.5*POW) \ Military laser power

NI% = 37                \ The number of bytes in each ship's data block (as
                        \ stored in INWK and K%)

OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSWORD = &FFF1          \ The address for the OSWORD routine
OSFILE = &FFDD          \ The address for the OSFILE routine
OSWRCH = &FFEE          \ The address for the OSWRCH routine
OSCLI = &FFF7           \ The address for the OSCLI routine

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

VSCAN = 57              \ Defines the split position in the split-screen mode

X = 128                 \ The centre x-coordinate of the 256 x 192 space view
Y = 96                  \ The centre y-coordinate of the 256 x 192 space view

f0 = &20                \ Internal key number for red key f0 (Launch, Front)
f1 = &71                \ Internal key number for red key f1 (Buy Cargo, Rear)
f2 = &72                \ Internal key number for red key f2 (Sell Cargo, Left)
f3 = &73                \ Internal key number for red key f3 (Equip Ship, Right)
f4 = &14                \ Internal key number for red key f4 (Long-range Chart)
f5 = &74                \ Internal key number for red key f5 (Short-range Chart)
f6 = &75                \ Internal key number for red key f6 (Data on System)
f7 = &16                \ Internal key number for red key f7 (Market Price)
f8 = &76                \ Internal key number for red key f8 (Status Mode)
f9 = &77                \ Internal key number for red key f9 (Inventory)

NRU% = 25               \ The number of planetary systems with extended system
                        \ description overrides in the RUTOK table

VE = &57                \ The obfuscation byte used to hide the extended tokens
                        \ table from crackers viewing the binary code

LL = 30                 \ The length of lines (in characters) of justified text
                        \ in the extended tokens system

QQ18 = &0400            \ The address of the text token table, as set in
                        \ elite-loader3.asm

SNE = &07C0             \ The address of the sine lookup table, as set in
                        \ elite-loader3.asm

ACT = &07E0             \ The address of the arctan lookup table, as set in
                        \ elite-loader3.asm

QQ16_FLIGHT = &0880     \ The address of the two-letter text token table in the
                        \ flight code (this gets populated by the docked code at
                        \ the start of the game)

CATD = &0D7A            \ The address of the CATD routine that is put in place
                        \ by the third loader, as set in elite-loader3.asm

IRQ1 = &114B            \ The address of the IRQ1 routine that implements the
                        \ split screen interrupt handler, as set in
                        \ elite-loader3.asm

BRBR1 = &11D5           \ The address of the main break handler, which BRKV
                        \ points to as set in elite-loader3.asm

NA% = &1181             \ The address of the data block for the last saved
                        \ commander, as set in elite-loader3.asm

CHK2 = &11D3            \ The address of the second checksum byte for the saved
                        \ commander data file, as set in elite-loader3.asm

CHK = &11D4             \ The address of the first checksum byte for the saved
                        \ commander data file, as set in elite-loader3.asm

XX21 = &5600            \ The address of the ship blueprints lookup table, where
                        \ the chosen ship blueprints file is loaded

E% = &563E              \ The address of the default NEWB ship bytes within the
                        \ loaded ship blueprints file

SHIP_MISSILE = &7F00    \ The address of the missile ship blueprint, as set in
                        \ elite-loader3.asm

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0000 to &00B0
\   Category: Workspaces
\    Summary: Lots of important variables are stored in the zero page workspace
\             as it is quicker and more space-efficient to access memory here
\
\ ******************************************************************************

ORG &0000

.ZP

 SKIP 0                 \ The start of the zero page workspace

.RAND

 SKIP 4                 \ Four 8-bit seeds for the random number generation
                        \ system implemented in the DORND routine

.TRTB%

 SKIP 2                 \ TRTB%(1 0) points to the keyboard translation table,
                        \ which is used to translate internal key numbers to
                        \ ASCII

.T1

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

.XX16

 SKIP 18                \ Temporary storage for a block of values, used in a
                        \ number of places

.P

 SKIP 3                 \ Temporary storage, used in a number of places

.XX0

 SKIP 2                 \ Temporary storage, used to store the address of a ship
                        \ blueprint. For example, it is used when we add a new
                        \ ship to the local bubble in routine NWSHP, and it
                        \ contains the address of the current ship's blueprint
                        \ as we loop through all the nearby ships in the main
                        \ flight loop

.INF

 SKIP 2                 \ Temporary storage, typically used for storing the
                        \ address of a ship's data block, so it can be copied
                        \ to and from the internal workspace at INWK

.V

 SKIP 2                 \ Temporary storage, typically used for storing an
                        \ address pointer

.XX

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ x-coordinate

.YY

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ y-coordinate

.SUNX

 SKIP 2                 \ The 16-bit x-coordinate of the vertical centre axis
                        \ of the sun (which might be off-screen)

.BETA

 SKIP 1                 \ The current pitch angle beta, which is reduced from
                        \ JSTY to a sign-magnitude value between -8 and +8
                        \
                        \ This describes how fast we are pitching our ship, and
                        \ determines how fast the universe pitches around us
                        \
                        \ The sign bit is also stored in BET2, while the
                        \ opposite sign is stored in BET2+1

.BET1

 SKIP 1                 \ The magnitude of the pitch angle beta, i.e. |beta|,
                        \ which is a positive value between 0 and 8

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

.QQ22

 SKIP 2                 \ The two hyperspace countdown counters
                        \
                        \ Before a hyperspace jump, both QQ22 and QQ22+1 are
                        \ set to 15
                        \
                        \ QQ22 is an internal counter that counts down by 1
                        \ each time TT102 is called, which happens every
                        \ iteration of the main game loop. When it reaches
                        \ zero, the on-screen counter in QQ22+1 gets
                        \ decremented, and QQ22 gets set to 5 and the countdown
                        \ continues (so the first tick of the hyperspace counter
                        \ takes 15 iterations to happen, but subsequent ticks
                        \ take 5 iterations each)
                        \
                        \ QQ22+1 contains the number that's shown on-screen
                        \ during the countdown. It counts down from 15 to 1, and
                        \ when it hits 0, the hyperspace engines kick in

.ECMA

 SKIP 1                 \ The E.C.M. countdown timer, which determines whether
                        \ an E.C.M. system is currently operating:
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on and is counting down
                        \
                        \ The counter starts at 32 when an E.C.M. is activated,
                        \ either by us or by an opponent, and it decreases by 1
                        \ in each iteration of the main flight loop until it
                        \ reaches zero, at which point the E.C.M. switches off.
                        \ Only one E.C.M. can be active at any one time, so
                        \ there is only one counter

.ALP1

 SKIP 1                 \ Magnitude of the roll angle alpha, i.e. |alpha|,
                        \ which is a positive value between 0 and 31

.ALP2

 SKIP 2                 \ Bit 7 of ALP2 = sign of the roll angle in ALPHA
                        \
                        \ Bit 7 of ALP2+1 = opposite sign to ALP2 and ALPHA

.XX15

 SKIP 0                 \ Temporary storage, typically used for storing screen
                        \ coordinates in line-drawing routines
                        \
                        \ There are six bytes of storage, from XX15 TO XX15+5.
                        \ The first four bytes have the following aliases:
                        \
                        \   X1 = XX15
                        \   Y1 = XX15+1
                        \   X2 = XX15+2
                        \   Y2 = XX15+3
                        \
                        \ These are typically used for describing lines in terms
                        \ of screen coordinates, i.e. (X1, Y1) to (X2, Y2)
                        \
                        \ The last two bytes of XX15 do not have aliases

.X1

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y1

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

 SKIP 2                 \ The last two bytes of the XX15 block

.XX12

 SKIP 6                 \ Temporary storage for a block of values, used in a
                        \ number of places

.K

 SKIP 4                 \ Temporary storage, used in a number of places

.LAS

 SKIP 1                 \ Contains the laser power of the laser fitted to the
                        \ current space view (or 0 if there is no laser fitted
                        \ to the current view)
                        \
                        \ This gets set to bits 0-6 of the laser power byte from
                        \ the commander data block, which contains the laser's
                        \ power (bit 7 doesn't denote laser power, just whether
                        \ or not the laser pulses, so that is not stored here)

.MSTG

 SKIP 1                 \ The current missile lock target
                        \
                        \   * &FF = no target
                        \
                        \   * 1-13 = the slot number of the ship that our
                        \            missile is locked onto

.XX1

 SKIP 0                 \ This is an alias for INWK that is used in the main
                        \ ship-drawing routine at LL9

.INWK

 SKIP 33                \ The zero-page internal workspace for the current ship
                        \ data block
                        \
                        \ As operations on zero page locations are faster and
                        \ have smaller opcodes than operations on the rest of
                        \ the addressable memory, Elite tends to store oft-used
                        \ data here. A lot of the routines in Elite need to
                        \ access and manipulate ship data, so to make this an
                        \ efficient exercise, the ship data is first copied from
                        \ the ship data blocks at K% into INWK (or, when new
                        \ ships are spawned, from the blueprints at XX21). See
                        \ the deep dive on "Ship data blocks" for details of
                        \ what each of the bytes in the INWK data block
                        \ represents

.XX19

 SKIP NI% - 34          \ XX19(1 0) shares its location with INWK(34 33), which
                        \ contains the address of the ship line heap

.NEWB

 SKIP 1                 \ The ship's "new byte flags" (or NEWB flags)
                        \
                        \ Contains details about the ship's type and associated
                        \ behaviour, such as whether they are a trader, a bounty
                        \ hunter, a pirate, currently hostile, in the process of
                        \ docking, inside the hold having been scooped, and so
                        \ on. The default values for each ship type are taken
                        \ from the table at E%, and you can find out more detail
                        \ in the deep dive on "Advanced tactics with the NEWB
                        \ flags"

.LSP

 SKIP 1                 \ The ball line heap pointer, which contains the number
                        \ of the first free byte after the end of the LSX2 and
                        \ LSY2 heaps (see the deep dive on "The ball line heap"
                        \ for details)

.QQ15

 SKIP 6                 \ The three 16-bit seeds for the selected system, i.e.
                        \ the one in the crosshairs in the Short-range Chart
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.K5

 SKIP 0                 \ Temporary storage used to store segment coordinates
                        \ across successive calls to BLINE, the ball line
                        \ routine

.XX18

 SKIP 0                 \ Temporary storage used to store coordinates in the
                        \ LL9 ship-drawing routine

.QQ17

 SKIP 1                 \ Contains a number of flags that affect how text tokens
                        \ are printed, particularly capitalisation:
                        \
                        \   * If all bits are set (255) then text printing is
                        \     disabled
                        \
                        \   * Bit 7: 0 = ALL CAPS
                        \            1 = Sentence Case, bit 6 determines the
                        \                case of the next letter to print
                        \
                        \   * Bit 6: 0 = print the next letter in upper case
                        \            1 = print the next letter in lower case
                        \
                        \   * Bits 0-5: If any of bits 0-5 are set, print in
                        \               lower case
                        \
                        \ So:
                        \
                        \   * QQ17 = 0 means case is set to ALL CAPS
                        \
                        \   * QQ17 = %10000000 means Sentence Case, currently
                        \            printing upper case
                        \
                        \   * QQ17 = %11000000 means Sentence Case, currently
                        \            printing lower case
                        \
                        \   * QQ17 = %11111111 means printing is disabled

.QQ19

 SKIP 3                 \ Temporary storage, used in a number of places

.K6

 SKIP 5                 \ Temporary storage, typically used for storing
                        \ coordinates during vector calculations

.BET2

 SKIP 2                 \ Bit 7 of BET2 = sign of the pitch angle in BETA
                        \
                        \ Bit 7 of BET2+1 = opposite sign to BET2 and BETA

.DELTA

 SKIP 1                 \ Our current speed, in the range 1-40

.DELT4

 SKIP 2                 \ Our current speed * 64 as a 16-bit value
                        \
                        \ This is stored as DELT4(1 0), so the high byte in
                        \ DELT4+1 therefore contains our current speed / 4

.U

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.XSAV

 SKIP 1                 \ Temporary storage for saving the value of the X
                        \ register, used in a number of places

.YSAV

 SKIP 1                 \ Temporary storage for saving the value of the Y
                        \ register, used in a number of places

.XX17

 SKIP 1                 \ Temporary storage, used in BPRNT to store the number
                        \ of characters to print, and as the edge counter in the
                        \ main ship-drawing routine

.QQ11

 SKIP 1                 \ The number of the current view:
                        \
                        \   0   = Space view
                        \   1   = Title screen
                        \         Get commander name ("@", save/load commander)
                        \         In-system jump just arrived ("J")
                        \         Data on System screen (red key f6)
                        \         Buy Cargo screen (red key f1)
                        \         Mis-jump just arrived (witchspace)
                        \   4   = Sell Cargo screen (red key f2)
                        \   6   = Death screen
                        \   8   = Status Mode screen (red key f8)
                        \         Inventory screen (red key f9)
                        \   16  = Market Price screen (red key f7)
                        \   32  = Equip Ship screen (red key f3)
                        \   64  = Long-range Chart (red key f4)
                        \   128 = Short-range Chart (red key f5)
                        \   255 = Launch view
                        \
                        \ This value is typically set by calling routine TT66

.ZZ

 SKIP 1                 \ Temporary storage, typically used for distance values

.XX13

 SKIP 1                 \ Temporary storage, typically used in the line-drawing
                        \ routines

.MCNT

 SKIP 1                 \ The main loop counter
                        \
                        \ This counter determines how often certain actions are
                        \ performed within the main loop. See the deep dive on
                        \ "Scheduling tasks with the main loop counter" for more
                        \ details

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

.ALPHA

 SKIP 1                 \ The current roll angle alpha, which is reduced from
                        \ JSTX to a sign-magnitude value between -31 and +31
                        \
                        \ This describes how fast we are rolling our ship, and
                        \ determines how fast the universe rolls around us
                        \
                        \ The sign bit is also stored in ALP2, while the
                        \ opposite sign is stored in ALP2+1

.QQ12

 SKIP 1                 \ Our "docked" status
                        \
                        \   * 0 = we are not docked
                        \
                        \   * &FF = we are docked

.TGT

 SKIP 1                 \ Temporary storage, typically used as a target value
                        \ for counters when drawing explosion clouds and partial
                        \ circles

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

.COL

 SKIP 1                 \ Temporary storage, used to store colour information
                        \ when drawing pixels in the dashboard

.FLAG

 SKIP 1                 \ A flag that's used to define whether this is the first
                        \ call to the ball line routine in BLINE, so it knows
                        \ whether to wait for the second call before storing
                        \ segment data in the ball line heap

.CNT

 SKIP 1                 \ Temporary storage, typically used for storing the
                        \ number of iterations required when looping

.CNT2

 SKIP 1                 \ Temporary storage, used in the planet-drawing routine
                        \ to store the segment number where the arc of a partial
                        \ circle should start

.STP

 SKIP 1                 \ The step size for drawing circles
                        \
                        \ Circles in Elite are split up into 64 points, and the
                        \ step size determines how many points to skip with each
                        \ straight-line segment, so the smaller the step size,
                        \ the smoother the circle. The values used are:
                        \
                        \   * 2 for big planets and the circles on the charts
                        \   * 4 for medium planets and the launch tunnel
                        \   * 8 for small planets and the hyperspace tunnel
                        \
                        \ As the step size increases we move from smoother
                        \ circles at the top to more polygonal at the bottom.
                        \ See the CIRCLE2 routine for more details

.XX4

 SKIP 1                 \ Temporary storage, used in a number of places

.XX20

 SKIP 1                 \ Temporary storage, used in a number of places

.XX14

 SKIP 1                 \ This byte appears to be unused

.RAT

 SKIP 1                 \ Used to store different signs depending on the current
                        \ space view, for use in calculating stardust movement

.RAT2

 SKIP 1                 \ Temporary storage, used to store the pitch and roll
                        \ signs when moving objects and stardust

.K2

 SKIP 4                 \ Temporary storage, used in a number of places

ORG &00D1

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.K3

 SKIP 0                 \ Temporary storage, used in a number of places

.XX2

 SKIP 14                \ Temporary storage, used to store the visibility of the
                        \ ship's faces during the ship-drawing routine at LL9

.K4

 SKIP 2                 \ Temporary storage, used in a number of places

PRINT "Zero page variables from ", ~ZP, " to ", ~P%

\ ******************************************************************************
\
\       Name: XX3
\       Type: Workspace
\    Address: &0100 to the top of the descending stack
\   Category: Workspaces
\    Summary: Temporary storage space for complex calculations
\
\ ------------------------------------------------------------------------------
\
\ Used as heap space for storing temporary data during calculations. Shared with
\ the descending 6502 stack, which works down from &01FF.
\
\ ******************************************************************************

ORG &0100

.XX3

 SKIP 0                 \ Temporary storage, typically used for storing tables
                        \ of values such as screen coordinates or ship data

\ ******************************************************************************
\
\       Name: UP
\       Type: Workspace
\    Address: &0300 to &03CF
\   Category: Workspaces
\    Summary: Ship slots, variables
\
\ ******************************************************************************

ORG &0300

.KL

 SKIP 1                 \ The following bytes implement a key logger that
                        \ enables Elite to scan for concurrent key presses of
                        \ the primary flight keys, plus a secondary flight key
                        \
                        \ See the deep dive on "The key logger" for more details
                        \
                        \ If a key is being pressed that is not in the keyboard
                        \ table at KYTB, it can be stored here (as seen in
                        \ routine DK4, for example)

.KY1

 SKIP 1                 \ "?" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY2

 SKIP 1                 \ Space is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY3

 SKIP 1                 \ "<" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY4

 SKIP 1                 \ ">" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY5

 SKIP 1                 \ "X" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY6

 SKIP 1                 \ "S" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY7

 SKIP 1                 \ "A" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes
                        \
                        \ This is also set when the joystick fire button has
                        \ been pressed

.KY12

 SKIP 1                 \ TAB is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY13

 SKIP 1                 \ ESCAPE is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY14

 SKIP 1                 \ "T" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY15

 SKIP 1                 \ "U" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY16

 SKIP 1                 \ "M" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY17

 SKIP 1                 \ "E" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY18

 SKIP 1                 \ "J" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY19

 SKIP 1                 \ "C" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY20

 SKIP 1                 \ "P" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.FRIN

 SKIP NOSH + 1          \ Slots for the ships in the local bubble of universe
                        \
                        \ There are #NOSH + 1 slots, but the ship-spawning
                        \ routine at NWSHP only populates #NOSH of them, so
                        \ there are 13 slots but only 12 are used for ships
                        \ (the last slot is effectively used as a null
                        \ terminator when shuffling the slots down in the
                        \ KILLSHP routine)
                        \
                        \ See the deep dive on "The local bubble of universe"
                        \ for details of how Elite stores the local universe in
                        \ FRIN, UNIV and K%

.MANY

 SKIP SST               \ The number of ships of each type in the local bubble
                        \ of universe
                        \
                        \ The number of ships of type X in the local bubble is
                        \ stored at MANY+X, so the number of Sidewinders is at
                        \ MANY+1, the number of Mambas is at MANY+2, and so on
                        \
                        \ See the deep dive on "Ship blueprints" for a list of
                        \ ship types

.SSPR

 SKIP NTY + 1 - SST     \ "Space station present" flag
                        \
                        \   * Non-zero if we are inside the space station's safe
                        \     zone
                        \
                        \   * 0 if we aren't (in which case we can show the sun)
                        \
                        \ This flag is at MANY+SST, which is no coincidence, as
                        \ MANY+SST is a count of how many space stations there
                        \ are in our local bubble, which is the same as saying
                        \ "space station present"

.JUNK

 SKIP 1                 \ The amount of junk in the local bubble
                        \
                        \ "Junk" is defined as being one of these:
                        \
                        \   * Escape pod
                        \   * Alloy plate
                        \   * Cargo canister
                        \   * Asteroid
                        \   * Splinter
                        \   * Shuttle
                        \   * Transporter
                        \
                        \ Junk is the range of ship types from #JL to #JH - 1

.auto

 SKIP 1                 \ Docking computer activation status
                        \
                        \   * 0 = Docking computer is off
                        \
                        \   * Non-zero = Docking computer is running

.ECMP

 SKIP 1                 \ Our E.C.M. status
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on

.MJ

 SKIP 1                 \ Are we in witchspace (i.e. have we mis-jumped)?
                        \
                        \   * 0 = no, we are in normal space
                        \
                        \   * &FF = yes, we are in witchspace

.CABTMP

 SKIP 1                 \ Cabin temperature
                        \
                        \ The ambient cabin temperature in deep space is 30,
                        \ which is displayed as one notch on the dashboard bar
                        \
                        \ We get higher temperatures closer to the sun
                        \
                        \ CABTMP shares a location with MANY, but that's OK as
                        \ MANY+0 would contain the number of ships of type 0,
                        \ and as there is no ship type 0 (they start at 1), the
                        \ byte at MANY+0 is not used for storing a ship type
                        \ and can be used for the cabin temperature instead

.LAS2

 SKIP 1                 \ Laser power for the current laser
                        \
                        \   * Bits 0-6 contain the laser power of the current
                        \     space view
                        \
                        \   * Bit 7 denotes whether or not the laser pulses:
                        \
                        \     * 0 = pulsing laser
                        \
                        \     * 1 = beam laser (i.e. always on)

.MSAR

 SKIP 1                 \ The targeting state of our leftmost missile
                        \
                        \   * 0 = missile is not looking for a target, or it
                        \     already has a target lock (indicator is not
                        \     yellow/white)
                        \
                        \   * Non-zero = missile is currently looking for a
                        \     target (indicator is yellow/white)

.VIEW

 SKIP 1                 \ The number of the current space view
                        \
                        \   * 0 = front
                        \   * 1 = rear
                        \   * 2 = left
                        \   * 3 = right

.LASCT

 SKIP 1                 \ The laser pulse count for the current laser
                        \
                        \ This is a counter that defines the gap between the
                        \ pulses of a pulse laser. It is set as follows:
                        \
                        \   * 0 for a beam laser
                        \
                        \   * 10 for a pulse laser
                        \
                        \ It gets decremented every vertical sync (in the LINSCN
                        \ routine, which is called 50 times a second) and is set
                        \ to a non-zero value for pulse lasers only
                        \
                        \ The laser only fires when the value of LASCT hits
                        \ zero, so for pulse lasers with a value of 10, that
                        \ means the laser fires once every 10 vertical syncs (or
                        \ 5 times a second)
                        \
                        \ In comparison, beam lasers fire continuously as the
                        \ value of LASCT is always 0

.GNTMP

 SKIP 1                 \ Laser temperature (or "gun temperature")
                        \
                        \ If the laser temperature exceeds 242 then the laser
                        \ overheats and cannot be fired again until it has
                        \ cooled down

.HFX

 SKIP 1                 \ A flag that toggles the hyperspace colour effect
                        \
                        \   * 0 = no colour effect
                        \
                        \   * Non-zero = hyperspace colour effect enabled
                        \
                        \ When HFX is set to 1, the mode 4 screen that makes
                        \ up the top part of the display is temporarily switched
                        \ to mode 5 (the same screen mode as the dashboard),
                        \ which has the effect of blurring and colouring the
                        \ hyperspace rings in the top part of the screen. The
                        \ code to do this is in the LINSCN routine, which is
                        \ called as part of the screen mode routine at IRQ1.
                        \ It's in LINSCN that HFX is checked, and if it is
                        \ non-zero, the top part of the screen is not switched
                        \ to mode 4, thus leaving the top part of the screen in
                        \ the more colourful mode 5

.EV

 SKIP 1                 \ The "extra vessels" spawning counter
                        \
                        \ This counter is set to 0 on arrival in a system and
                        \ following an in-system jump, and is bumped up when we
                        \ spawn bounty hunters or pirates (i.e. "extra vessels")
                        \
                        \ It decreases by 1 each time we consider spawning more
                        \ "extra vessels" in part 4 of the main game loop, so
                        \ increasing the value of EV has the effect of delaying
                        \ the spawning of more vessels
                        \
                        \ In other words, this counter stops bounty hunters and
                        \ pirates from continually appearing, and ensures that
                        \ there's a delay between spawnings

.DLY

 SKIP 1                 \ In-flight message delay
                        \
                        \ This counter is used to keep an in-flight message up
                        \ for a specified time before it gets removed. The value
                        \ in DLY is decremented each time we start another
                        \ iteration of the main game loop at TT100

.de

 SKIP 1                 \ Equipment destruction flag
                        \
                        \   * Bit 1 denotes whether or not the in-flight message
                        \     about to be shown by the MESS routine is about
                        \     destroyed equipment:
                        \
                        \     * 0 = the message is shown normally
                        \
                        \     * 1 = the string " DESTROYED" gets added to the
                        \       end of the message

.JSTX

 SKIP 1                 \ Our current roll rate
                        \
                        \ This value is shown in the dashboard's RL indicator,
                        \ and determines the rate at which we are rolling
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means roll is decreasing at the
                        \ maximum rate, 128 means roll is not changing, and
                        \ 255 means roll is increasing at the maximum rate
                        \
                        \ This value is updated by "<" and ">" key presses, or
                        \ if joysticks are enabled, from the joystick. If
                        \ keyboard damping is enabled (which it is by default),
                        \ the value is slowly moved towards the centre value of
                        \ 128 (no roll) if there are no key presses or joystick
                        \ movement

.JSTY

 SKIP 1                 \ Our current pitch rate
                        \
                        \ This value is shown in the dashboard's DC indicator,
                        \ and determines the rate at which we are pitching
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means pitch is decreasing at the
                        \ maximum rate, 128 means pitch is not changing, and
                        \ 255 means pitch is increasing at the maximum rate
                        \
                        \ This value is updated by "S" and "X" key presses, or
                        \ if joysticks are enabled, from the joystick. If
                        \ keyboard damping is enabled (which it is by default),
                        \ the value is slowly moved towards the centre value of
                        \ 128 (no pitch) if there are no key presses or joystick
                        \ movement
.XSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the X
                        \ register in the TT26 routine

.YSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the Y
                        \ register in the TT26 routine

.NAME

 SKIP 8                 \ The current commander name
                        \
                        \ The commander name can be up to 7 characters (the DFS
                        \ limit for file names), and is terminated by a carriage
                        \ return

.TP

 SKIP 1                 \ The current mission status
                        \
                        \   * Bits 0-1 = Mission 1 status
                        \
                        \     * %00 = Mission not started
                        \     * %01 = Mission in progress, hunting for ship
                        \     * %11 = Constrictor killed, not debriefed yet
                        \     * %10 = Mission and debrief complete
                        \
                        \   * Bits 2-3 = Mission 2 status
                        \
                        \     * %00 = Mission not started
                        \     * %01 = Mission in progress, plans not picked up
                        \     * %10 = Mission in progress, plans picked up
                        \     * %11 = Mission complete

.QQ0

 SKIP 1                 \ The current system's galactic x-coordinate (0-256)

.QQ1

 SKIP 1                 \ The current system's galactic y-coordinate (0-256)

.QQ21

 SKIP 6                 \ The three 16-bit seeds for the current galaxy
                        \
                        \ These seeds define system 0 in the current galaxy, so
                        \ they can be used as a starting point to generate all
                        \ 256 systems in the galaxy
                        \
                        \ Using a galactic hyperdrive rotates each byte to the
                        \ left (rolling each byte within itself) to get the
                        \ seeds for the next galaxy, so after eight galactic
                        \ jumps, the seeds roll around to the first galaxy again
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details
.CASH

 SKIP 4                 \ Our current cash pot
                        \
                        \ The cash stash is stored as a 32-bit unsigned integer,
                        \ with the most significant byte in CASH and the least
                        \ significant in CASH+3. This is big-endian, which is
                        \ the opposite way round to most of the numbers used in
                        \ Elite - to use our notation for multi-byte numbers,
                        \ the amount of cash is CASH(0 1 2 3)

.QQ14

 SKIP 1                 \ Our current fuel level (0-70)
                        \
                        \ The fuel level is stored as the number of light years
                        \ multiplied by 10, so QQ14 = 1 represents 0.1 light
                        \ years, and the maximum possible value is 70, for 7.0
                        \ light years

.COK

 SKIP 1                 \ Flags used to generate the competition code
                        \
                        \ See the deep dive on "The competition code" for
                        \ details of these flags and how they are used in
                        \ generating and decoding the competition code

.GCNT

 SKIP 1                 \ The number of the current galaxy (0-7)
                        \
                        \ When this is displayed in-game, 1 is added to the
                        \ number, so we start in galaxy 1 in-game, but it's
                        \ stored as galaxy 0 internally
                        \
                        \ The galaxy number increases by one every time a
                        \ galactic hyperdrive is used, and wraps back round to
                        \ the start after eight galaxies

.LASER

 SKIP 4                 \ The specifications of the lasers fitted to each of the
                        \ four space views:
                        \
                        \   * Byte #0 = front view (red key f0)
                        \   * Byte #1 = rear view (red key f1)
                        \   * Byte #2 = left view (red key f2)
                        \   * Byte #3 = right view (red key f3)
                        \
                        \ For each of the views:
                        \
                        \   * 0 = no laser is fitted to this view
                        \
                        \   * Non-zero = a laser is fitted to this view, with
                        \     the following specification:
                        \
                        \     * Bits 0-6 contain the laser's power
                        \
                        \     * Bit 7 determines whether or not the laser pulses
                        \       (0 = pulse or mining laser) or is always on
                        \       (1 = beam or military laser)

 SKIP 2                 \ These bytes appear to be unused (they were originally
                        \ used for up/down lasers, but they were dropped)

.CRGO

 SKIP 1                 \ Our ship's cargo capacity
                        \
                        \   * 22 = standard cargo bay of 20 tonnes
                        \
                        \   * 37 = large cargo bay of 35 tonnes
                        \
                        \ The value is two greater than the actual capacity to
                        \ male the maths in tnpr slightly more efficient

.QQ20

 SKIP 17                \ The contents of our cargo hold
                        \
                        \ The amount of market item X that we have in our hold
                        \ can be found in the X-th byte of QQ20. For example:
                        \
                        \   * QQ20 contains the amount of food (item 0)
                        \
                        \   * QQ20+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units

.ECM

 SKIP 1                 \ E.C.M. system
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BST

 SKIP 1                 \ Fuel scoops (BST stands for "barrel status")
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BOMB

 SKIP 1                 \ Energy bomb
                        \
                        \   * 0 = not fitted
                        \
                        \   * &7F = fitted

.ENGY

 SKIP 1                 \ Energy unit
                        \
                        \   * 0 = not fitted
                        \
                        \   * 1 = fitted

.DKCMP

 SKIP 1                 \ Docking computer
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.GHYP

 SKIP 1                 \ Galactic hyperdrive
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.ESCP

 SKIP 1                 \ Escape pod
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

 SKIP 4                 \ These bytes appear to be unused

.NOMSL

 SKIP 1                 \ The number of missiles we have fitted (0-4)

.FIST

 SKIP 1                 \ Our legal status (FIST stands for "fugitive/innocent
                        \ status"):
                        \
                        \   * 0 = Clean
                        \
                        \   * 1-49 = Offender
                        \
                        \   * 50+ = Fugitive
                        \
                        \ You get 64 points if you kill a cop, so that's a fast
                        \ ticket to fugitive status

.AVL

 SKIP 17                \ Market availability in the current system
                        \
                        \ The available amount of market item X is stored in
                        \ the X-th byte of AVL, so for example:
                        \
                        \   * AVL contains the amount of food (item 0)
                        \
                        \   * AVL+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units, and the deep dive on "Market item
                        \ prices and availability" for details of the algorithm
                        \ used for calculating each item's availability

.QQ26

 SKIP 1                 \ A random value used to randomise market data
                        \
                        \ This value is set to a new random number for each
                        \ change of system, so we can add a random factor into
                        \ the calculations for market prices (for details of how
                        \ this is used, see the deep dive on "Market prices")

.TALLY

 SKIP 2                 \ Our combat rank
                        \
                        \ The combat rank is stored as the number of kills, in a
                        \ 16-bit number TALLY(1 0) - so the high byte is in
                        \ TALLY+1 and the low byte in TALLY
                        \
                        \ If the high byte in TALLY+1 is 0 then we have between
                        \ 0 and 255 kills, so our rank is Harmless, Mostly
                        \ Harmless, Poor, Average or Above Average, according to
                        \ the value of the low byte in TALLY:
                        \
                        \   Harmless        = %00000000 to %00000011 = 0 to 3
                        \   Mostly Harmless = %00000100 to %00000111 = 4 to 7
                        \   Poor            = %00001000 to %00001111 = 8 to 15
                        \   Average         = %00010000 to %00011111 = 16 to 31
                        \   Above Average   = %00100000 to %11111111 = 32 to 255
                        \
                        \ If the high byte in TALLY+1 is non-zero then we are
                        \ Competent, Dangerous, Deadly or Elite, according to
                        \ the high byte in TALLY+1:
                        \
                        \   Competent       = 1           = 256 to 511 kills
                        \   Dangerous       = 2 to 9      = 512 to 2559 kills
                        \   Deadly          = 10 to 24    = 2560 to 6399 kills
                        \   Elite           = 25 and up   = 6400 kills and up
                        \
                        \ You can see the rating calculation in STATUS

.SVC

 SKIP 1                 \ The save count
                        \
                        \ When a new commander is created, the save count gets
                        \ set to 128. This value gets halved each time the
                        \ commander file is saved, but it is otherwise unused.
                        \ It is presumably part of the security system for the
                        \ competition, possibly another flag to catch out
                        \ entries with manually altered commander files

 SKIP 2                 \ The commander file checksum
                        \
                        \ These two bytes are reserved for the commander file
                        \ checksum, so when the current commander block is
                        \ copied from here to the last saved commander block at
                        \ NA%, CHK and CHK2 get overwritten

NT% = SVC + 2 - TP      \ This sets the variable NT% to the size of the current
                        \ commander data block, which starts at TP and ends at
                        \ SVC+2 (inclusive)

.MCH

 SKIP 1                 \ The text token number of the in-flight message that is
                        \ currently being shown, and which will be removed by
                        \ the me2 routine when the counter in DLY reaches zero

.FSH

 SKIP 1                 \ Forward shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ASH

 SKIP 1                 \ Aft shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ENERGY

 SKIP 1                 \ Energy bank status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.COMX

 SKIP 1                 \ The x-coordinate of the compass dot

.COMY

 SKIP 1                 \ The y-coordinate of the compass dot

.QQ24

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's price in routine TT151

.QQ25

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's availability in routine TT151

.QQ28

 SKIP 1                 \ Temporary storage, used to store the economy byte of
                        \ the current system in routine var

.QQ29

 SKIP 1                 \ Temporary storage, used in a number of places

.gov

 SKIP 1                 \ The current system's government type (0-7)
                        \
                        \ See the deep dive on "Generating system data" for
                        \ details of the various government types

.tek

 SKIP 1                 \ The current system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.SLSP

 SKIP 2                 \ The address of the bottom of the ship line heap
                        \
                        \ The ship line heap is a descending block of memory
                        \ that starts at WP and descends down to SLSP. It can be
                        \ extended downwards by the NWSHP routine when adding
                        \ new ships (and their associated ship line heaps), in
                        \ which case SLSP is lowered to provide more heap space,
                        \ assuming there is enough free memory to do so

.QQ2

 SKIP 6                 \ The three 16-bit seeds for the current system, i.e.
                        \ the one we are currently in
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.QQ3

 SKIP 1                 \ The selected system's economy (0-7)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on economies

.QQ4

 SKIP 1                 \ The selected system's government (0-7)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details of the various government types

.QQ5

 SKIP 1                 \ The selected system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.QQ6

 SKIP 2                 \ The selected system's population in billions * 10
                        \ (1-71), so the maximum population is 7.1 billion
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details on population levels

.QQ7

 SKIP 2                 \ The selected system's productivity in M CR (96-62480)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details about productivity levels

.QQ8

 SKIP 2                 \ The distance from the current system to the selected
                        \ system in light years * 10, stored as a 16-bit number
                        \
                        \ The distance will be 0 if the selected sysyem is the
                        \ current system
                        \
                        \ The galaxy chart is 102.4 light years wide and 51.2
                        \ light years tall (see the intra-system distance
                        \ calculations in routine TT111 for details), which
                        \ equates to 1024 x 512 in terms of QQ8

.QQ9

 SKIP 1                 \ The galactic x-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic x-coordinate)

.QQ10

 SKIP 1                 \ The galactic y-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic y-coordinate)

.NOSTM

 SKIP 1                 \ The number of stardust particles shown on screen,
                        \ which is 18 (#NOST) for normal space, and 3 for
                        \ witchspace

 SKIP 1                 \ This byte appears to be unused

.COMC

 SKIP 1                 \ The colour of the dot on the compass
                        \
                        \   * &F0 = the object in the compass is in front of us,
                        \     so the dot is yellow/white
                        \
                        \   * &FF = the object in the compass is behind us, so
                        \     the dot is green/cyan

.DNOIZ

 SKIP 1                 \ Sound on/off configuration setting
                        \
                        \   * 0 = sound is on (default)
                        \
                        \   * Non-zero = sound is off
                        \
                        \ Toggled by pressing "S" when paused, see the DK4
                        \ routine for details

.DAMP

 SKIP 1                 \ Keyboard damping configuration setting
                        \
                        \   * 0 = damping is enabled (default)
                        \
                        \   * &FF = damping is disabled
                        \
                        \ Toggled by pressing CAPS LOCK when paused, see the
                        \ DKS3 routine for details

.DJD

 SKIP 1                 \ Keyboard auto-recentre configuration setting
                        \
                        \   * 0 = auto-recentre is enabled (default)
                        \
                        \   * &FF = auto-recentre is disabled
                        \
                        \ Toggled by pressing "A" when paused, see the DKS3
                        \ routine for details

.PATG

 SKIP 1                 \ Configuration setting to show the author names on the
                        \ start-up screen and enable manual hyperspace mis-jumps
                        \
                        \   * 0 = no author names or manual mis-jumps (default)
                        \
                        \   * &FF = show author names and allow manual mis-jumps
                        \
                        \ Toggled by pressing "X" when paused, see the DKS3
                        \ routine for details
                        \
                        \ This needs to be turned on for manual mis-jumps to be
                        \ possible. To do a manual mis-jump, first toggle the
                        \ author display by pausing the game (COPY) and pressing
                        \ "X", and during the next hyperspace, hold down CTRL to
                        \ force a mis-jump. See routine ee5 for the "AND PATG"
                        \ instruction that implements this logic

.FLH

 SKIP 1                 \ Flashing console bars configuration setting
                        \
                        \   * 0 = static bars (default)
                        \
                        \   * &FF = flashing bars
                        \
                        \ Toggled by pressing "F" when paused, see the DKS3
                        \ routine for details

.JSTGY

 SKIP 1                 \ Reverse joystick Y-channel configuration setting
                        \
                        \   * 0 = standard Y-channel (default)
                        \
                        \   * &FF = reversed Y-channel
                        \
                        \ Toggled by pressing "Y" when paused, see the DKS3
                        \ routine for details

.JSTE

 SKIP 1                 \ Reverse both joystick channels configuration setting
                        \
                        \   * 0 = standard channels (default)
                        \
                        \   * &FF = reversed channels
                        \
                        \ Toggled by pressing "J" when paused, see the DKS3
                        \ routine for details

.JSTK

 SKIP 1                 \ Keyboard or joystick configuration setting
                        \
                        \   * 0 = keyboard (default)
                        \
                        \   * &FF = joystick
                        \
                        \ Toggled by pressing "K" when paused, see the DKS3
                        \ routine for details

.BSTK

 SKIP 1                 \ Bitstik configuration setting
                        \
                        \   * 0 = keyboard or joystick (default)
                        \
                        \   * &FF = Bitstik
                        \
                        \ Toggled by pressing "B" when paused, see the DKS3
                        \ routine for details

.CATF

 SKIP 1                 \ The disc catalogue flag
                        \
                        \ Determines whether a disc catalogue is currently in
                        \ progress, so the TT26 print routine can format the
                        \ output correctly:
                        \
                        \   * 0 = disc is not currently being catalogued
                        \
                        \   * 1 = disc is currently being catalogued
                        \
                        \ Specifically, when CATF is non-zero, TT26 will omit
                        \ column 17 from the catalogue so that it will fit
                        \ on-screen (column 17 is blank column in the middle
                        \ of the catalogue, between the two lists of filenames,
                        \ so it can be dropped without affecting the layout)

\ ******************************************************************************
\
\       Name: K%
\       Type: Workspace
\    Address: &0900 to &0D3F
\   Category: Workspaces
\    Summary: Ship data blocks and ship line heaps
\  Deep dive: Ship data blocks
\             The local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ Contains ship data for all the ships, planets, suns and space stations in our
\ local bubble of universe, along with their corresponding ship line heaps.
\
\ The blocks are pointed to by the lookup table at location UNIV. The first 444
\ bytes of the K% workspace hold ship data on up to 12 ships, with 37 (NI%)
\ bytes per ship, and the ship line heap grows downwards from WP at the end of
\ the K% workspace.
\
\ See the deep dive on "Ship data blocks" for details on ship data blocks, and
\ the deep dive on "The local bubble of universe" for details of how Elite
\ stores the local universe in K%, FRIN and UNIV.
\
\ ******************************************************************************

ORG &0900

.K%

 SKIP 0                 \ Ship data blocks and ship line heap

\ ******************************************************************************
\
\       Name: WP
\       Type: Workspace
\    Address: &0E00 to &0E3B
\   Category: Workspaces
\    Summary: Variables
\
\ ******************************************************************************

ORG &0E00

.WP

 SKIP 0                 \ The start of the WP workspace

.LSX

 SKIP 0                 \ LSX is an alias that points to the first byte of the
                        \ sun line heap at LSO
                        \
                        \   * &FF indicates the sun line heap is empty
                        \
                        \   * Otherwise the LSO heap contains the line data for
                        \     the sun

.LSO

 SKIP 1                 \ This space has three uses:
                        \
.BUF                    \   * The ship line heap for the space station (see
                        \     NWSPS for details)
 SKIP 191               \
                        \   * The sun line heap (see SUN for details)
                        \
                        \   * The line buffer used by DASC to print justified
                        \     text (BUF = LSO + 1)
                        \
                        \ The spaces can be shared as our local bubble of
                        \ universe can support either the sun or a space
                        \ station, but not both

.LSX2

 SKIP 78                \ The ball line heap for storing x-coordinates (see the
                        \ deep dive on "The ball line heap" for details)

.LSY2

 SKIP 78                \ The ball line heap for storing y-coordinates (see the
                        \ deep dive on "The ball line heap" for details)

.SX

 SKIP NOST + 1          \ This is where we store the x_hi coordinates for all
                        \ the stardust particles

.SXL

 SKIP NOST + 1          \ This is where we store the x_lo coordinates for all
                        \ the stardust particles

.SY

 SKIP NOST + 1          \ This is where we store the y_hi coordinates for all
                        \ the stardust particles

.SYL

 SKIP NOST + 1          \ This is where we store the y_lo coordinates for all
                        \ the stardust particles

.SZ

 SKIP NOST + 1          \ This is where we store the z_hi coordinates for all
                        \ the stardust particles

.SZL

 SKIP NOST + 1          \ This is where we store the z_lo coordinates for all
                        \ the stardust particles

.LASX

 SKIP 1                 \ The x-coordinate of the tip of the laser line

.LASY

 SKIP 1                 \ The y-coordinate of the tip of the laser line

.XX24

 SKIP 1                 \ This byte appears to be unused

.ALTIT

 SKIP 1                 \ Our altitude above the surface of the planet or sun
                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
                        \     planet/sun is at (x_hi, y_hi, z_hi), and the
                        \     radius of the planet/sun is 6
                        \
                        \   * 0 = we have crashed into the surface

.CPIR

 SKIP 1                 \ A counter used when spawning pirates, to work our way
                        \ through the list of pirate ship blueprints until we
                        \ find one that has been loaded

PRINT "WP workspace from  ", ~WP," to ", ~P%

\ ******************************************************************************
\
\ ELITE A FILE
\
\ ******************************************************************************

CODE% = &11E3
LOAD% = &11E3

ORG CODE%

LOAD_A% = LOAD%

 \ a.icode - ELITE III encyclopedia

\OPT TABS=16

key_table = &04
ptr = &07
font = &1C
cursor_x = &2C
cursor_y = &2D
vdu_stat = &72
brk_line = &FD
last_key = &300
ship_type = &311
cabin_t = &342
target = &344
view_dirn = &345
laser_t = &347
adval_x = &34C
adval_y = &34D
cmdr_mission = &358
cmdr_homex = &359
cmdr_homey = &35A
cmdr_gseed = &35B
cmdr_money = &361
cmdr_fuel = &365
cmdr_galxy = &367
cmdr_laser = &368
cmdr_ship = &36D
cmdr_hold = &36E
cmdr_cargo = &36F
cmdr_ecm = &380
cmdr_scoop = &381
cmdr_bomb = &382
cmdr_eunit = &383
cmdr_dock = &384
cmdr_ghype = &385
cmdr_escape = &386
cmdr_cour = &387
cmdr_courx = &389
cmdr_coury = &38A
cmdr_misl = &38B
cmdr_legal = &38C
cmdr_avail = &38D
cmdr_price = &39E
cmdr_kills = &39F
f_shield = &3A5
r_shield = &3A6
energy = &3A7
home_econ = &3AC
home_govmt = &3AE
home_tech = &3AF
data_econ = &3B8
data_govm = &3B9
data_tech = &3BA
data_popn = &3BB
data_gnp = &3BD
hype_dist = &3BF
data_homex = &3C1
data_homey = &3C2
s_flag = &3C6
cap_flag = &3C7
a_flag = &3C8
x_flag = &3C9
f_flag = &3CA
y_flag = &3CB
j_flag = &3CC
k_flag = &3CD
b_flag = &3CE
 \
save_lock = &233
new_file = &234
new_posn = &235
new_type = &36D
new_pulse = &3D0
new_beam = &3D1
new_military = &3D2
new_mining = &3D3
new_mounts = &3D4
new_missiles = &3D5
new_shields = &3D6
new_energy = &3D7
new_speed = &3D8
new_hold = &3D9
new_range = &3DA
new_costs = &3DB
new_max = &3DC
new_min = &3DD
new_space = &3DE
 \new_:	EQU &3DF
new_name = &74D
 \
iff_index = &D7A
altitude = &FD1
irq1 = &114B
commander = &1189
brkdst = &11D5
ship_data = &55FE
l_563d = &563D
osfile = &FFDD
oswrch = &FFEE
osword = &FFF1
osbyte = &FFF4
oscli = &FFF7

EXEC% = &11E3

.S%

 JMP DOENTRY

 JMP DOENTRY

 JMP CHPR

 EQUW IRQ1

 JMP BRBR

BRKV = P% - 2

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
 STA KL+1
 JMP tcode

.DOENTRY

 JSR BRKBK
 JSR RES2
 JMP BAY

\ ******************************************************************************
\
\       Name: BRKBK
\       Type: Subroutine
\   Category: Save and load
\    Summary: Set the standard BRKV handler for the game
\
\ ******************************************************************************

.BRKBK

 LDA #LO(BRBR)          \ Set BRKV to point to the BRBR routine
 STA BRKV
 LDA #HI(BRBR)
 STA BRKV+1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DETOK3
\       Type: Subroutine
\   Category: Text
\    Summary: Print an extended recursive token from the RUTOK token table
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The recursive token to be printed, in the range 0-255
\
\ Returns:
\
\   A                   A is preserved
\
\   Y                   Y is preserved
\
\   V(1 0)              V(1 0) is preserved
\
\ ******************************************************************************

.DETOK3

 PHA                    \ Store A on the stack, so we can retrieve it later

 TAX                    \ Copy the token number from A into X

 TYA                    \ Store Y on the stack
 PHA

 LDA V                  \ Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 LDA #LO(RUTOK)         \ Set V to the low byte of RUTOK
 STA V

 LDA #HI(RUTOK)         \ Set A to the high byte of RUTOK

 BNE DTEN               \ Call DTEN to print token number X from the RUTOK
                        \ table and restore the values of A, Y and V(1 0) from
                        \ the stack, returning from the subroutine using a tail
                        \ call (this BNE is effectively a JMP as A is never
                        \ zero)

\ ******************************************************************************
\
\       Name: MT27
\       Type: Subroutine
\   Category: Text
\    Summary: Print the captain's name during mission briefings
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine prints the following tokens, depending on the galaxy number:
\
\   * Token 217 ("CURRUTHERS") in galaxy 0
\
\   * Token 218 ("FOSDYKE SMYTHE") in galaxy 1
\
\   * Token 219 ("FORTESQUE") in galaxy 2
\
\ This is used when printing extended token 213 as part of the mission
\ briefings, which looks like this when printed:
\
\   Commander {commander name}, I am Captain {mission captain's name} of Her
\   Majesty's Space Navy
\
\ where {mission captain's name} is replaced by one of the names above.
\
\ ******************************************************************************

.MT27

 LDA #217               \ Set A = 217, so when we fall through into MT28, the
                        \ 217 gets added to the current galaxy number, so the
                        \ extended token that is printed is 217-219 (as this is
                        \ only called in galaxies 0 through 2)

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &DC, or BIT &DCA9, which does nothing apart
                        \ from affect the flags

\ ******************************************************************************
\
\       Name: MT28
\       Type: Subroutine
\   Category: Text
\    Summary: Print the location hint during the mission 1 briefing
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine prints the following tokens, depending on the galaxy number:
\
\   * Token 220 ("WAS LAST SEEN AT {single cap}REESDICE") in galaxy 0
\
\   * Token 221 ("IS BELIEVED TO HAVE JUMPED TO THIS GALAXY") in galaxy 1
\
\ This is used when printing extended token 10 as part of the mission 1
\ briefing, which looks like this when printed:
\
\   It went missing from our ship yard on Xeer five months ago and {mission 1
\   location hint}
\
\ where {mission 1 location hint} is replaced by one of the names above.
\
\ ******************************************************************************

.MT28

 LDA #220               \ Set A = galaxy number in GCNT + 220, which is in the
 CLC                    \ range 220-221, as this is only called in galaxies 0
 ADC GCNT               \ and 1

\ ******************************************************************************
\
\       Name: DETOK
\       Type: Subroutine
\   Category: Text
\    Summary: Print an extended recursive token from the TKN1 token table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The recursive token to be printed, in the range 1-255
\
\ Returns:
\
\   A                   A is preserved
\
\   Y                   Y is preserved
\
\   V(1 0)              V(1 0) is preserved
\
\ Other entry points:
\
\   DTEN                Print recursive token number X from the token table
\                       pointed to by (A V), used to print tokens from the RUTOK
\                       table via calls to DETOK3
\
\ ******************************************************************************

.DETOK

 PHA                    \ Store A on the stack, so we can retrieve it later

 TAX                    \ Copy the token number from A into X

 TYA                    \ Store Y on the stack
 PHA

 LDA V                  \ Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 LDA #LO(TKN1)          \ Set V to the low byte of TKN1
 STA V

 LDA #HI(TKN1)          \ Set A to the high byte of TKN1, so when we fall
                        \ through into DTEN, V(1 0) gets set to the address of
                        \ the TKN1 token table

.DTEN

 STA V+1                \ Set the high byte of V(1 0) to A, so V(1 0) now points
                        \ to the start of the token table to use

 LDY #0                 \ First, we need to work our way through the table until
                        \ we get to the token that we want to print. Tokens are
                        \ delimited by #VE, and VE EOR VE = 0, so we work our
                        \ way through the table in, counting #VE delimiters
                        \ until we have passed X of them, at which point we jump
                        \ down to DTL2 to do the actual printing. So first, we
                        \ set a counter Y to point to the character offset as we
                        \ scan through the table
.DTL1

 LDA (V),Y              \ Load the character at offset Y in the token table,
                        \ which is the next character from the token table

 BNE DT1                \ If the result is non-zero, then this is a character
                        \ in a token rather than the delimiter (which is #VE),
                        \ so jump to DT1

 DEX                    \ We have just scanned the end of a token, so decrement
                        \ X, which contains the token number we are looking for

 BEQ DTL2               \ If X has now reached zero then we have found the token
                        \ we are looking for, so jump down to DTL2 to print it

.DT1

 INY                    \ Otherwise this isn't the token we are looking for, so
                        \ increment the character pointer

 BNE DTL1               \ If Y hasn't just wrapped around to 0, loop back to
                        \ DTL1 to process the next character

 INC V+1                \ We have just crossed into a new page, so increment
                        \ V+1 so that V points to the start of the new page

 BNE DTL1               \ Jump back to DTL1 to process the next character (this
                        \ BNE is effectively a JMP as V+1 won't reach zero
                        \ before we reach the end of the token table)

.DTL2

 INY                    \ We just detected the delimiter byte before the token
                        \ that we want to print, so increment the character
                        \ pointer to point to the first character of the token,
                        \ rather than the delimiter

 BNE P%+4               \ If Y hasn't just wrapped around to 0, skip the next
                        \ instruction

 INC V+1                \ We have just crossed into a new page, so increment
                        \ V+1 so that V points to the start of the new page

 LDA (V),Y              \ Load the character at offset Y in the token table,
                        \ which is the next character from the token we want to
                        \ print

 BEQ DTEX               \ If the result is zero, then this is the delimiter at
                        \ the end of the token to print (which is #VE), so jump
                        \ to DTEX to return from the subroutine, as we are done
                        \ printing

 JSR DETOK2             \ Otherwise call DETOK2 to print this part of the token

 JMP DTL2               \ Jump back to DTL2 to process the next character

.DTEX

 PLA                    \ Restore V(1 0) from the stack, so it is preserved
 STA V+1                \ through calls to this routine
 PLA
 STA V

 PLA                    \ Restore Y from the stack, so it is preserved through
 TAY                    \ calls to this routine

 PLA                    \ Restore A from the stack, so it is preserved through
                        \ calls to this routine

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DETOK2
\       Type: Subroutine
\   Category: Text
\    Summary: Print an extended text token (1-255)
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The token to be printed (1-255)
\
\ Returns:
\
\   A                   A is preserved
\
\   Y                   Y is preserved
\
\   V(1 0)              V(1 0) is preserved
\
\ Other entry points:
\
\   DTS                 Print the single letter pointed to by A, where A is an
\                       address within the extended two-letter token tables of
\                       TKN2 and QQ16
\
\   msg_pairs           AJD
\
\ ******************************************************************************

.DETOK2

 CMP #32                \ If A < 32 then this is a jump token, so skip to DT3 to
 BCC DT3                \ process it

 BIT DTW3               \ If bit 7 of DTW3 is clear, then extended tokens are
 BPL DT8                \ enabled, so jump to DT8 to process them

                        \ If we get there then this is not a jump token and
                        \ extended tokens are not enabled, so we can call the
                        \ standard text token routine at TT27 to print the token

 TAX                    \ Copy the token number from A into X

 TYA                    \ Store Y on the stack
 PHA

 LDA V                  \ Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 TXA                    \ Copy the token number from X back into A

 JSR TT27               \ Call TT27 to print the text token

 JMP DT7                \ Jump to DT7 to restore V(1 0) and Y from the stack and
                        \ return from the subroutine

.DT8

                        \ If we get here then this is not a jump token and
                        \ extended tokens are enabled

 CMP #'['               \ If A < ASCII "[" (i.e. A <= ASCII "Z", or 90) then
 BCC DTS                \ this is a printable ASCII character, so jump down to
                        \ DTS to print it

 CMP #129               \ If A < 129, so A is in the range 91-128, jump down to
 BCC DT6                \ DT6 to print a randomised token from the MTIN table

 CMP #215               \ If A < 215, so A is in the range 129-214, jump to
 BCC DETOK              \ DETOK as this is a recursive token, returning from the
                        \ subroutine using a tail call

                        \ If we get here then A >= 215, so this is a two-letter
                        \ token from the extended TKN2/QQ16 table

.msg_pairs

 SBC #215               \ Subtract 215 to get a token number in the range 0-12
                        \ (the C flag is set as we passed through the BCC above,
                        \ so this subtraction is correct)

 ASL A                  \ Set A = A * 2, so it can be used as a pointer into the
                        \ two-letter token tables at TKN2 and QQ16

 PHA                    \ Store A on the stack, so we can restore it for the
                        \ second letter below

 TAX                    \ Fetch the first letter of the two-letter token from
 LDA TKN2,X             \ TKN2, which is at TKN2 + X

 JSR DTS                \ Call DTS to print it

 PLA                    \ Restore A from the stack and transfer it into X
 TAX

 LDA TKN2+1,X           \ Fetch the second letter of the two-letter token from
                        \ TKN2, which is at TKN2 + X + 1, and fall through into
                        \ DTS to print it

.DTS

 CMP #'A'               \ If A < ASCII "A", jump to DT9 to print this as ASCII
 BCC DT9

 BIT DTW6               \ If bit 7 of DTW6 is set, then lower case has been
 BMI DT10               \ enabled by jump token 13, {lower case}, so jump to
                        \ DT10 to apply the lower case and single cap masks

 BIT DTW2               \ If bit 7 of DTW2 is set, then we are not currently
 BMI DT5                \ printing a word, so jump to DT5 so we skip the setting
                        \ of lower case in Sentence Case (which we only want to
                        \ do when we are already printing a word)

.DT10

 ORA DTW1               \ Convert the character to lower case if DTW1 is
                        \ %00100000 (i.e. if we are in {sentence case} mode)

.DT5

 AND DTW8               \ Convert the character to upper case if DTW8 is
                        \ %11011111 (i.e. after a {single cap} token)

.DT9

 JMP DASC               \ Jump to DASC to print the ASCII character in A,
                        \ returning from the routine using a tail call

.DT3

                        \ If we get here then the token number in A is in the
                        \ range 1 to 32, so this is a jump token that should
                        \ call the corresponding address in the jump table at
                        \ JMTB

 TAX                    \ Copy the token number from A into X

 TYA                    \ Store Y on the stack
 PHA

 LDA V                  \ Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 TXA                    \ Copy the token number from X back into A

 ASL A                  \ Set A = A * 2, so it can be used as a pointer into the
                        \ jump table at JMTB, though because the original range
                        \ of values is 1-32, so the doubled range is 2-64, we
                        \ need to take the offset into the jump table from
                        \ JMTB-2 rather than JMTB

 TAX                    \ Copy the doubled token number from A into X

 LDA JMTB-2,X           \ Set DTM(2 1) to the X-th address from the table at
 STA DTM+1              \ JTM-2, which modifies the JSR DASC instruction at
 LDA JMTB-1,X           \ label DTM below so that it calls the subroutine at the
 STA DTM+2              \ relevant address from the JMTB table

 TXA                    \ Copy the doubled token number from X back into A

 LSR A                  \ Halve A to get the original token number

.DTM

 JSR DASC               \ Call the relevant JMTB subroutine, as this instruction
                        \ will have been modified by the above to point to the
                        \ relevant address

.DT7

 PLA                    \ Restore V(1 0) from the stack, so it is preserved
 STA V+1                \ through calls to this routine
 PLA
 STA V

 PLA                    \ Restore Y from the stack, so it is preserved through
 TAY                    \ calls to this routine

 RTS                    \ Return from the subroutine

.DT6

                        \ If we get here then the token number in A is in the
                        \ range 91-128, which means we print a randomly picked
                        \ token from the token range given in the corresponding
                        \ entry in the MTIN table

 STA SC                 \ Store the token number in SC

 TYA                    \ Store Y on the stack
 PHA

 LDA V                  \ Store V(1 0) on the stack
 PHA
 LDA V+1
 PHA

 JSR DORND              \ Set X to a random number
 TAX

 LDA #0                 \ Set A to 0, so we can build a random number from 0 to
                        \ 4 in A plus the C flag, with each number being equally
                        \ likely

 CPX #51                \ Add 1 to A if X >= 51
 ADC #0

 CPX #102               \ Add 1 to A if X >= 102
 ADC #0

 CPX #153               \ Add 1 to A if X >= 153
 ADC #0

 CPX #204               \ Set the C flag if X >= 204

 LDX SC                 \ Fetch the token number from SC into X, so X is now in
                        \ the range 91-128

 ADC MTIN-91,X          \ Set A = MTIN-91 + token number (91-128) + random (0-4)
                        \       = MTIN + token number (0-37) + random (0-4)

 JSR DETOK              \ Call DETOK to print the extended recursive token in A

 JMP DT7                \ Jump to DT7 to restore V(1 0) and Y from the stack and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: MT1
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to ALL CAPS when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW1 = %00000000 (do not change case to lower case)
\
\   * DTW6 = %00000000 (lower case is not enabled)
\
\ ******************************************************************************

.MT1

 LDA #%00000000         \ Set A = %00000000, so when we fall through into MT2,
                        \ both DTW1 and DTW6 get set to %00000000

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &20, or BIT &20A9, which does nothing apart
                        \ from affect the flags

\ ******************************************************************************
\
\       Name: MT2
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to Sentence Case when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW1 = %00100000 (apply lower case to the second letter of a word onwards)
\
\   * DTW6 = %00000000 (lower case is not enabled)
\
\ ******************************************************************************

.MT2

 LDA #%00100000         \ Set DTW1 = %00100000
 STA DTW1

 LDA #00000000          \ Set DTW6 = %00000000
 STA DTW6

 RTS                    \ Return from the subroutine

.PAUSE

 LDA #&10
 EQUB &2C

\ ******************************************************************************
\
\       Name: MT8
\       Type: Subroutine
\   Category: Text
\    Summary: Tab to column 6 and start a new word when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * XC = 6 (tab to column 6)
\
\   * DTW2 = %11111111 (we are not currently printing a word)
\
\ Other entry points:
\
\   MT6                 AJD
\
\ ******************************************************************************

.MT8

 LDA #6                 \ Move the text cursor to column 6
 STA XC

.MT6

 LDA #%11111111         \ Set all the bits in DTW2
 STA DTW2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MT9
\       Type: Subroutine
\   Category: Text
\    Summary: Clear the screen and set the current view type to 1
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * XC = 1 (tab to column 1)
\
\ before calling TT66 to clear the screen and set the view type to 1.
\
\ ******************************************************************************

.MT9

 LDA #1                 \ Move the text cursor to column 1
 STA XC

 JMP TT66               \ Jump to TT66 to clear the screen and set the current
                        \ view type to 1, returning from the subroutine using a
                        \ tail call

\ ******************************************************************************
\
\       Name: MT13
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to lower case when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW1 = %00100000 (apply lower case to the second letter of a word onwards)
\
\   * DTW6 = %10000000 (lower case is enabled)
\
\ ******************************************************************************

.MT13

 LDA #%10000000         \ Set DTW6 = %10000000
 STA DTW6

 LDA #%00100000         \ Set DTW1 = %00100000
 STA DTW1

 RTS                    \ Return from the subroutine

.clr_vdustat

 LDA #&01
 EQUB &2C

\ ******************************************************************************
\
\       Name: set_token
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to standard tokens in Sentence Case
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * QQ17 = %10000000 (set Sentence Case for standard tokens)
\
\   * DTW3 = %11111111 (print standard tokens)
\
\ ******************************************************************************

.set_token

 LDA #%10000000         \ Set bit 7 of QQ17 to switch standard tokens to
 STA QQ17               \ Sentence Case

 LDA #%11111111         \ Set A = %11111111, so when we fall through into MT5,
                        \ DTW3 gets set to %11111111 and calls to DETOK print
                        \ standard tokens

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &00, or BIT &00A9, which does nothing apart
                        \ from affect the flags

\ ******************************************************************************
\
\       Name: MT5
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW3 = %00000000 (print extended tokens)
\
\ ******************************************************************************

.MT5

 LDA #%00000000         \ Set DTW3 = %00000000, so that calls to DETOK print
 STA DTW3               \ extended tokens

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MT14
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to justified text when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW4 = %10000000 (justify text, print buffer on carriage return)
\
\   * DTW5 = 0 (reset line buffer size)
\
\ ******************************************************************************

.MT14

 LDA #%10000000         \ Set A = %10000000, so when we fall through into MT15,
                        \ DTW4 gets set to %10000000

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &00, or BIT &00A9, which does nothing apart
                        \ from affect the flags

\ ******************************************************************************
\
\       Name: MT15
\       Type: Subroutine
\   Category: Text
\    Summary: Switch to left-aligned text when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW4 = %00000000 (do not justify text, print buffer on carriage return)
\
\   * DTW5 = 0 (reset line buffer size)
\
\ ******************************************************************************

.MT15

 LDA #0                 \ Set DTW4 = %00000000
 STA DTW4

 ASL A                  \ Set DTW5 = 0 (even when we fall through from MT14 with
 STA DTW5               \ A set to %10000000)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MT17
\       Type: Subroutine
\   Category: Text
\    Summary: Print the selected system's adjective, e.g. Lavian for Lave
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ The adjective for the current system is generated by taking the system name,
\ removing the last character if it is a vowel, and adding "-ian" to the end,
\ so:
\
\   * Lave gives Lavian (as in "Lavian tree grub")
\
\   * Leesti gives Leestian (as in "Leestian Evil Juice")
\
\ This routine is called by jump token 17, {system name adjective}, and it can
\ only be used when justified text is being printed - i.e. following jump token
\ 14, {justify} - because the routine needs to use the line buffer to work.
\
\ ******************************************************************************

.MT17

 LDA QQ17               \ Set QQ17 = %10111111 to switch to Sentence Case
 AND #%10111111
 STA QQ17

 LDA #3                 \ Print control code 3 (selected system name) into the
 JSR TT27               \ line buffer

 LDX DTW5               \ Load the last character of the line buffer BUF into A
 LDA BUF-1,X            \ (as DTW5 contains the buffer size, so character DTW5-1
                        \ is the last character in the buffer BUF)

 JSR VOWEL              \ Test whether the character is a vowel, in which case
                        \ this will set the C flag

 BCC MT171              \ If the character is not a vowel, skip the following
                        \ instruction

 DEC DTW5               \ The character is a vowel, so decrement DTW5, which
                        \ removes the last character from the line buffer (i.e.
                        \ it removes the trailing vowel from the system name)

.MT171

 LDA #153               \ Print extended token 153 ("IAN"), returning from the
 JMP DETOK              \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: MT18
\       Type: Subroutine
\   Category: Text
\    Summary: Print a random 1-8 letter word in Sentence Case
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.MT18

 JSR MT19               \ Call MT19 to capitalise the next letter (i.e. set
                        \ Sentence Case for this word only)

 JSR DORND              \ Set A and X to random numbers and reduce A to a
 AND #3                 \ random number in the range 0-3

 TAY                    \ Copy the random number into Y, so we can use Y as a
                        \ loop counter to print 1-4 words (i.e. Y+1 words)

.MT18L

 JSR DORND              \ Set A and X to random numbers and reduce A to an even
 AND #62                \ random number in the range 0-62 (as bit 0 of 62 is 0)

 TAX                    \ Copy the random number into X, so X contains the table
                        \ offset of a random extended two-letter token from 0-31
                        \ which we can now use to pick a token from the combined
                        \ tables at TKN2+2 and QQ16 (we intentionally exclude
                        \ the first token in TKN2, which contains a newline)

 LDA TKN2+2,X           \ Print the first letter of the token at TKN2+2 + X
 JSR DTS

 LDA TKN2+3,X           \ Print the second letter of the token at TKN2+2 + X
 JSR DTS

 DEY                    \ Decrement the loop counter

 BPL MT18L              \ Loop back to MT18L to print another two-letter token
                        \ until we have printed Y+1 of them

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MT19
\       Type: Subroutine
\   Category: Text
\    Summary: Capitalise the next letter
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * DTW8 = %11011111 (capitalise the next letter)
\
\ ******************************************************************************

.MT19

 LDA #%11011111         \ Set DTW8 = %11011111
 STA DTW8

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: VOWEL
\       Type: Subroutine
\   Category: Text
\    Summary: Test whether a character is a vowel
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to be tested
\
\ Returns:
\
\   C flag              The C flag is set if the character is a vowel, otherwise
\                       it is clear
\
\ ******************************************************************************

.VOWEL

 ORA #%00100000         \ Set bit 5 of the character to make it lower case

 CMP #'a'               \ If the letter is a vowel, jump to VRTS to return from
 BEQ VRTS               \ the subroutine with the C flag set (as the CMP will
 CMP #'e'               \ set the C flag if the comparison is equal)
 BEQ VRTS
 CMP #'i'
 BEQ VRTS
 CMP #'o'
 BEQ VRTS
 CMP #'u'
 BEQ VRTS

 CLC                    \ The character is not a vowel, so clear the C flag

.VRTS

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: JMTB
\       Type: Variable
\   Category: Text
\    Summary: The extended token table for jump tokens 1-32 (DETOK)
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.JMTB

 EQUW MT1               \ Token  1: Switch to ALL CAPS
 EQUW MT2               \ Token  2: Switch to Sentence Case
 EQUW TT27              \ Token  3: Print the selected system name
 EQUW set_token         \ Token  4: AJD
 EQUW MT5               \ Token  5: Switch to extended tokens
 EQUW MT6               \ Token  6: Switch to standard tokens, in Sentence Case
 EQUW DASC              \ Token  7: Beep
 EQUW MT8               \ Token  8: Tab to column 6
 EQUW MT9               \ Token  9: Clear screen, tab to column 1, view type = 1
 EQUW DASC              \ Token 10: Line feed
 EQUW NLIN4             \ Token 11: Draw box around title (line at pixel row 19)
 EQUW DASC              \ Token 12: Carriage return
 EQUW MT13              \ Token 13: Switch to lower case
 EQUW MT14              \ Token 14: Switch to justified text
 EQUW MT15              \ Token 15: Switch to left-aligned text
 EQUW MT16              \ Token 16: Print the character in DTW7 (drive number)
 EQUW MT17              \ Token 17: Print system name adjective in Sentence Case
 EQUW MT18              \ Token 18: Randomly print 1 to 4 two-letter tokens
 EQUW MT19              \ Token 19: Capitalise first letter of next word only
 EQUW DASC              \ Token 20: Unused
 EQUW CLYNS             \ Token 21: Clear the bottom few lines of the space view
 EQUW PAUSE             \ Token 22: Display ship and wait for key press
 EQUW MT23              \ Token 23: Move to row 10, white text, set lower case
 EQUW clr_vdustat       \ Token 24: AJD
 EQUW DASC              \ Token 25: Unused
 EQUW MT26              \ Token 26: Fetch line input from keyboard (filename)
 EQUW MT27              \ Token 27: Print mission captain's name (217-219)
 EQUW MT28              \ Token 28: Print mission 1 location hint (220-221)
 EQUW MT29              \ Token 29: Column 6, white text, lower case in words
 EQUW DASC              \ Token 30: Unused
 EQUW DASC              \ Token 31: Unused
 EQUW DASC              \ Token 32: Unused

\ ******************************************************************************
\
\       Name: TKN2
\       Type: Variable
\   Category: Text
\    Summary: The extended two-letter token lookup table
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Two-letter token lookup table for extended tokens 215-227.
\
\ ******************************************************************************

.TKN2

 EQUB 12, 10            \ Token 215 = {crlf}
 EQUS "AB"              \ Token 216
 EQUS "OU"              \ Token 217
 EQUS "SE"              \ Token 218
 EQUS "IT"              \ Token 219
 EQUS "IL"              \ Token 220
 EQUS "ET"              \ Token 221
 EQUS "ST"              \ Token 222
 EQUS "ON"              \ Token 223
 EQUS "LO"              \ Token 224
 EQUS "NU"              \ Token 225
 EQUS "TH"              \ Token 226
 EQUS "NO"              \ Token 227

\ ******************************************************************************
\
\       Name: QQ16
\       Type: Variable
\   Category: Text
\    Summary: The two-letter token lookup table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ Two-letter token lookup table for tokens 128-159. See the deep dive on
\ "Printing text tokens" for details of how the two-letter token system works.
\
\ ******************************************************************************

.QQ16

 EQUS "AL"              \ Token 128
 EQUS "LE"              \ Token 129
 EQUS "XE"              \ Token 130
 EQUS "GE"              \ Token 131
 EQUS "ZA"              \ Token 132
 EQUS "CE"              \ Token 133
 EQUS "BI"              \ Token 134
 EQUS "SO"              \ Token 135
 EQUS "US"              \ Token 136
 EQUS "ES"              \ Token 137
 EQUS "AR"              \ Token 138
 EQUS "MA"              \ Token 139
 EQUS "IN"              \ Token 140
 EQUS "DI"              \ Token 141
 EQUS "RE"              \ Token 142
 EQUS "A?"              \ Token 143
 EQUS "ER"              \ Token 144
 EQUS "AT"              \ Token 145
 EQUS "EN"              \ Token 146
 EQUS "BE"              \ Token 147
 EQUS "RA"              \ Token 148
 EQUS "LA"              \ Token 149
 EQUS "VE"              \ Token 150
 EQUS "TI"              \ Token 151
 EQUS "ED"              \ Token 152
 EQUS "OR"              \ Token 153
 EQUS "QU"              \ Token 154
 EQUS "AN"              \ Token 155
 EQUS "TE"              \ Token 156
 EQUS "IS"              \ Token 157
 EQUS "RI"              \ Token 158
 EQUS "ON"              \ Token 159

\ ******************************************************************************
\
\       Name: MVEIT (Part 1 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Tidy the orientation vectors
\  Deep dive: Program flow of the ship-moving routine
\             Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Tidy the orientation vectors for one of the ship slots
\
\ Arguments:
\
\   INWK                The current ship/planet/sun's data block
\
\   XSAV                The slot number of the current ship/planet/sun
\
\   TYPE                The type of the current ship/planet/sun
\
\ ******************************************************************************

.MVEIT

 LDA INWK+31            \ If bit 5 of ship byte #31 is set, jump to MV3 as the
 AND #%00100000         \ ship is exploding, so we don't need to tidy its
 BNE MV3                \ orientation vectors

 LDA MCNT               \ Fetch the main loop counter

 EOR XSAV               \ Fetch the slot number of the ship we are moving, EOR
 AND #15                \ with the loop counter and apply mod 15 to the result.
 BNE MV3                \ The result will be zero when "counter mod 15" matches
                        \ the slot number, so this makes sure we call TIDY 12
                        \ times every 16 main loop iterations, like this:
                        \
                        \   Iteration 0, tidy the ship in slot 0
                        \   Iteration 1, tidy the ship in slot 1
                        \   Iteration 2, tidy the ship in slot 2
                        \     ...
                        \   Iteration 11, tidy the ship in slot 11
                        \   Iteration 12, do nothing
                        \   Iteration 13, do nothing
                        \   Iteration 14, do nothing
                        \   Iteration 15, do nothing
                        \   Iteration 16, tidy the ship in slot 0
                        \     ...
                        \
                        \ and so on

 JSR TIDY               \ Call TIDY to tidy up the orientation vectors, to
                        \ prevent the ship from getting elongated and out of
                        \ shape due to the imprecise nature of trigonometry
                        \ in assembly language

.MV3

                        \ Fall through into part 7 (parts 2-6 are not required
                        \ when we are docked)

\ ******************************************************************************
\
\       Name: MVEIT (Part 7 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship's orientation vectors by pitch/roll
\  Deep dive: Orientation vectors
\             Pitching and rolling
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Rotate the ship's orientation vectors according to our pitch and roll
\
\ As with the previous step, this is all about moving the other ships rather
\ than us (even though we are the one doing the moving). So we rotate the
\ current ship's orientation vectors (which defines its orientation in space),
\ by the angles we are "moving" the rest of the sky through (alpha and beta, our
\ roll and pitch), so the ship appears to us to be stationary while we rotate.
\
\ ******************************************************************************

 LDY #9                 \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's nosev vector

 LDY #15                \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's roofv vector

 LDY #21                \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's sidev vector

\ ******************************************************************************
\
\       Name: MVEIT (Part 8 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship about itself by its own pitch/roll
\  Deep dive: Orientation vectors
\             Pitching and rolling by a fixed angle
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * If the ship we are processing is rolling or pitching itself, rotate it and
\     apply damping if required
\
\ ******************************************************************************

 LDA INWK+30            \ Fetch the ship's pitch counter and extract the sign
 AND #%10000000         \ into RAT2
 STA RAT2

 LDA INWK+30            \ Fetch the ship's pitch counter and extract the value
 AND #%01111111         \ without the sign bit into A

 BEQ MV8                \ If the pitch counter is 0, then jump to MV8 to skip
                        \ the following, as the ship is not pitching

 CMP #%01111111         \ If bits 0-6 are set in the pitch counter (i.e. the
                        \ ship's pitch is not damping down), then the C flag
                        \ will be set by this instruction

 SBC #0                 \ Set A = A - 0 - (1 - C), so if we are damping then we
                        \ reduce A by 1, otherwise it is unchanged

 ORA RAT2               \ Change bit 7 of A to the sign we saved in RAT2, so
                        \ the updated pitch counter in A retains its sign

 STA INWK+30            \ Store the updated pitch counter in byte #30

 LDX #15                \ Rotate (roofv_x, nosev_x) by a small angle (pitch)
 LDY #9
 JSR MVS5

 LDX #17                \ Rotate (roofv_y, nosev_y) by a small angle (pitch)
 LDY #11
 JSR MVS5

 LDX #19                \ Rotate (roofv_z, nosev_z) by a small angle (pitch)
 LDY #13
 JSR MVS5

.MV8

 LDA INWK+29            \ Fetch the ship's roll counter and extract the sign
 AND #%10000000         \ into RAT2
 STA RAT2

 LDA INWK+29            \ Fetch the ship's roll counter and extract the value
 AND #%01111111         \ without the sign bit into A

 BEQ MV5                \ If the roll counter is 0, then jump to MV5 to skip the
                        \ following, as the ship is not rolling

 CMP #%01111111         \ If bits 0-6 are set in the roll counter (i.e. the
                        \ ship's roll is not damping down), then the C flag
                        \ will be set by this instruction

 SBC #0                 \ Set A = A - 0 - (1 - C), so if we are damping then we
                        \ reduce A by 1, otherwise it is unchanged

 ORA RAT2               \ Change bit 7 of A to the sign we saved in RAT2, so
                        \ the updated roll counter in A retains its sign

 STA INWK+29            \ Store the updated pitch counter in byte #29

 LDX #15                \ Rotate (roofv_x, sidev_x) by a small angle (roll)
 LDY #21
 JSR MVS5

 LDX #17                \ Rotate (roofv_y, sidev_y) by a small angle (roll)
 LDY #23
 JSR MVS5

 LDX #19                \ Rotate (roofv_z, sidev_z) by a small angle (roll)
 LDY #25
 JSR MVS5

\ ******************************************************************************
\
\       Name: MVEIT (Part 9 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Redraw on scanner, if it hasn't been destroyed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * If the ship is exploding or being removed, hide it on the scanner
\
\   * Otherwise redraw the ship on the scanner, now that it's been moved
\
\ ******************************************************************************

.MV5

 LDA INWK+31            \ Fetch the ship's exploding/killed state from byte #31

 AND #%00100000         \ If we are exploding then jump to MVD1 to remove it
 BNE MVD1               \ from the scanner permanently

 LDA INWK+31            \ Set bit 4 to keep the ship visible on the scanner
 ORA #%00010000
 STA INWK+31

.MVD1

 LDA INWK+31            \ Clear bit 4 to hide the ship on the scanner
 AND #%11101111
 STA INWK+31

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVS4
\       Type: Subroutine
\   Category: Moving
\    Summary: Apply pitch and roll to an orientation vector
\  Deep dive: Orientation vectors
\             Pitching and rolling
\
\ ------------------------------------------------------------------------------
\
\ Apply pitch and roll angles alpha and beta to the orientation vector in Y.
\
\ Specifically, this routine rotates a point (x, y, z) around the origin by
\ pitch alpha and roll beta, using the small angle approximation to make the
\ maths easier, and incorporating the Minsky circle algorithm to make the
\ rotation more stable (though more elliptic).
\
\ If that paragraph makes sense to you, then you should probably be writing
\ this commentary! For the rest of us, there's a detailed explanation of all
\ this in the deep dive on "Pitching and rolling".
\
\ Arguments:
\
\   Y                   Determines which of the INWK orientation vectors to
\                       transform:
\
\                         * Y = 9 rotates nosev: (nosev_x, nosev_y, nosev_z)
\
\                         * Y = 15 rotates roofv: (roofv_x, roofv_y, roofv_z)
\
\                         * Y = 21 rotates sidev: (sidev_x, sidev_y, sidev_z)
\
\ ******************************************************************************

.MVS4

 LDA ALPHA              \ Set Q = alpha (the roll angle to rotate through)
 STA Q

 LDX INWK+2,Y           \ Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S

 LDX INWK,Y             \ These instructions have no effect as MAD overwrites
 STX P                  \ X and P when called, but they set X = P = nosev_x_lo

 LDA INWK+1,Y           \ Set A = -nosev_x_hi
 EOR #%10000000

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+3,Y           \           = alpha * -nosev_x_hi + nosev_y
 STX INWK+2,Y           \
                        \ and store (A X) in nosev_y, so this does:
                        \
                        \ nosev_y = nosev_y - alpha * nosev_x_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y_lo

 LDX INWK,Y             \ Set (S R) = nosev_x
 STX R
 LDX INWK+1,Y
 STX S

 LDA INWK+3,Y           \ Set A = nosev_y_hi

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+1,Y           \           = alpha * nosev_y_hi + nosev_x
 STX INWK,Y             \
                        \ and store (A X) in nosev_x, so this does:
                        \
                        \ nosev_x = nosev_x + alpha * nosev_y_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_x_lo

 LDA BETA               \ Set Q = beta (the pitch angle to rotate through)
 STA Q

 LDX INWK+2,Y           \ Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S
 LDX INWK+4,Y

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y

 LDA INWK+5,Y           \ Set A = -nosev_z_hi
 EOR #%10000000

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+3,Y           \           = beta * -nosev_z_hi + nosev_y
 STX INWK+2,Y           \
                        \ and store (A X) in nosev_y, so this does:
                        \
                        \ nosev_y = nosev_y - beta * nosev_z_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y_lo

 LDX INWK+4,Y           \ Set (S R) = nosev_z
 STX R
 LDX INWK+5,Y
 STX S

 LDA INWK+3,Y           \ Set A = nosev_y_hi

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+5,Y           \           = beta * nosev_y_hi + nosev_z
 STX INWK+4,Y           \
                        \ and store (A X) in nosev_z, so this does:
                        \
                        \ nosev_z = nosev_z + beta * nosev_y_hi

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVS5
\       Type: Subroutine
\   Category: Moving
\    Summary: Apply a 3.6 degree pitch or roll to an orientation vector
\  Deep dive: Orientation vectors
\             Pitching and rolling by a fixed angle
\
\ ------------------------------------------------------------------------------
\
\ Pitch or roll a ship by a small, fixed amount (1/16 radians, or 3.6 degrees),
\ in a specified direction, by rotating the orientation vectors. The vectors to
\ rotate are given in X and Y, and the direction of the rotation is given in
\ RAT2. The calculation is as follows:
\
\   * If the direction is positive:
\
\     X = X * (1 - 1/512) + Y / 16
\     Y = Y * (1 - 1/512) - X / 16
\
\   * If the direction is negative:
\
\     X = X * (1 - 1/512) - Y / 16
\     Y = Y * (1 - 1/512) + X / 16
\
\ So if X = 15 (roofv_x), Y = 21 (sidev_x) and RAT2 is positive, it does this:
\
\   roofv_x = roofv_x * (1 - 1/512)  + sidev_x / 16
\   sidev_x = sidev_x * (1 - 1/512)  - roofv_x / 16
\
\ Arguments:
\
\   X                   The first vector to rotate:
\
\                         * If X = 15, rotate roofv_x
\
\                         * If X = 17, rotate roofv_y
\
\                         * If X = 19, rotate roofv_z
\
\                         * If X = 21, rotate sidev_x
\
\                         * If X = 23, rotate sidev_y
\
\                         * If X = 25, rotate sidev_z
\
\   Y                   The second vector to rotate:
\
\                         * If Y = 9,  rotate nosev_x
\
\                         * If Y = 11, rotate nosev_y
\
\                         * If Y = 13, rotate nosev_z
\
\                         * If Y = 21, rotate sidev_x
\
\                         * If Y = 23, rotate sidev_y
\
\                         * If Y = 25, rotate sidev_z
\
\   RAT2                The direction of the pitch or roll to perform, positive
\                       or negative (i.e. the sign of the roll or pitch counter
\                       in bit 7)
\
\ ******************************************************************************

.MVS5

 LDA INWK+1,X           \ Fetch roofv_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         \ store in T, so:
 LSR A                  \
 STA T                  \ T = |roofv_x_hi| / 2
                        \   = |roofv_x| / 512
                        \
                        \ The above is true because:
                        \
                        \ |roofv_x| = |roofv_x_hi| * 256 + roofv_x_lo
                        \
                        \ so:
                        \
                        \ |roofv_x| / 512 = |roofv_x_hi| * 256 / 512
                        \                    + roofv_x_lo / 512
                        \                  = |roofv_x_hi| / 2

 LDA INWK,X             \ Now we do the following subtraction:
 SEC                    \
 SBC T                  \ (S R) = (roofv_x_hi roofv_x_lo) - |roofv_x| / 512
 STA R                  \       = (1 - 1/512) * roofv_x
                        \
                        \ by doing the low bytes first

 LDA INWK+1,X           \ And then the high bytes (the high byte of the right
 SBC #0                 \ side of the subtraction being 0)
 STA S

 LDA INWK,Y             \ Set P = nosev_x_lo
 STA P

 LDA INWK+1,Y           \ Fetch the sign of nosev_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,Y           \ Fetch nosev_x_hi into A and clear the sign bit, so
 AND #%01111111         \ A = |nosev_x_hi|

 LSR A                  \ Set (A P) = (A P) / 16
 ROR P                  \           = |nosev_x_hi nosev_x_lo| / 16
 LSR A                  \           = |nosev_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  \ Set the sign of A to the sign in T (i.e. the sign of
                        \ the original nosev_x), so now:
                        \
                        \ (A P) = nosev_x / 16

 EOR RAT2               \ Give it the sign as if we multiplied by the direction
                        \ by the pitch or roll direction

 STX Q                  \ Store the value of X so it can be restored after the
                        \ call to ADD

 JSR ADD                \ (A X) = (A P) + (S R)
                        \       = +/-nosev_x / 16 + (1 - 1/512) * roofv_x

 STA K+1                \ Set K(1 0) = (1 - 1/512) * roofv_x +/- nosev_x / 16
 STX K

 LDX Q                  \ Restore the value of X from before the call to ADD

 LDA INWK+1,Y           \ Fetch nosev_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         \ store in T, so:
 LSR A                  \
 STA T                  \ T = |nosev_x_hi| / 2
                        \   = |nosev_x| / 512

 LDA INWK,Y             \ Now we do the following subtraction:
 SEC                    \
 SBC T                  \ (S R) = (nosev_x_hi nosev_x_lo) - |nosev_x| / 512
 STA R                  \       = (1 - 1/512) * nosev_x
                        \
                        \ by doing the low bytes first

 LDA INWK+1,Y           \ And then the high bytes (the high byte of the right
 SBC #0                 \ side of the subtraction being 0)
 STA S

 LDA INWK,X             \ Set P = roofv_x_lo
 STA P

 LDA INWK+1,X           \ Fetch the sign of roofv_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,X           \ Fetch roofv_x_hi into A and clear the sign bit, so
 AND #%01111111         \ A = |roofv_x_hi|

 LSR A                  \ Set (A P) = (A P) / 16
 ROR P                  \           = |roofv_x_hi roofv_x_lo| / 16
 LSR A                  \           = |roofv_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  \ Set the sign of A to the opposite sign to T (i.e. the
 EOR #%10000000         \ sign of the original -roofv_x), so now:
                        \
                        \ (A P) = -roofv_x / 16

 EOR RAT2               \ Give it the sign as if we multiplied by the direction
                        \ by the pitch or roll direction

 STX Q                  \ Store the value of X so it can be restored after the
                        \ call to ADD

 JSR ADD                \ (A X) = (A P) + (S R)
                        \       = -/+roofv_x / 16 + (1 - 1/512) * nosev_x

 STA INWK+1,Y           \ Set nosev_x = (1-1/512) * nosev_x -/+ roofv_x / 16
 STX INWK,Y

 LDX Q                  \ Restore the value of X from before the call to ADD

 LDA K                  \ Set roofv_x = K(1 0)
 STA INWK,X             \              = (1-1/512) * roofv_x +/- nosev_x / 16
 LDA K+1
 STA INWK+1,X

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: UNIV
\       Type: Variable
\   Category: Universe
\    Summary: Table of pointers to the local universe's ship data blocks
\  Deep dive: The local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ See the deep dive on "Ship data blocks" for details on ship data blocks, and
\ the deep dive on "The local bubble of universe" for details of how Elite
\ stores the local universe in K%, FRIN and UNIV.
\
\ ******************************************************************************

.UNIV

FOR I%, 0, NOSH
  EQUW K% + I% * NI%    \ Address of block no. I%, of size NI%, in workspace K%
NEXT

\ ******************************************************************************
\
\ Save output/ELTA.bin
\
\ ******************************************************************************

PRINT "ELITE A"
PRINT "Assembled at ", ~CODE%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD_A%

PRINT "S.ELTA ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD_A%
\SAVE "output/F.ELTA.bin", CODE%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE B FILE
\
\ ******************************************************************************

CODE_B% = P%
LOAD_B% = LOAD% + P% - CODE%

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
\ ******************************************************************************

.CTWOS

 EQUB %10001000
 EQUB %01000100
 EQUB %00100010
 EQUB %00010001

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

.LOIN

 STY YSAV               \ Store Y into YSAV, so we can preserve it across the
                        \ call to this subroutine

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

.HL6

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: FLKB
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Flush the keyboard buffer
\
\ ******************************************************************************

.FLKB

 LDA #15                \ Call OSBYTE with A = 15 and Y <> 0 to flush the input
 TAX                    \ buffers (i.e. flush the operating system's keyboard
 JMP OSBYTE             \ buffer) and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: NLIN3
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Print a title and a horizontal line at row 19 to box it in
\
\ ------------------------------------------------------------------------------
\
\ This routine print a text token at the cursor position and draws a horizontal
\ line at pixel row 19. It is used for the Status Mode screen, the Short-range
\ Chart, the Market Price screen and the Equip Ship screen.
\
\ ******************************************************************************

.NLIN3

 JSR TT27               \ Print the text token in A

                        \ Fall through into NLIN4 to draw a horizontal line at
                        \ pixel row 19

\ ******************************************************************************
\
\       Name: NLIN4
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line at pixel row 19 to box in a title
\
\ ------------------------------------------------------------------------------
\
\ This routine is used on the Inventory screen to draw a horizontal line at
\ pixel row 19 to box in the title.
\
\ ******************************************************************************

.NLIN4

 LDA #19                \ Jump to NLIN2 to draw a horizontal line at pixel row
 BNE NLIN2              \ 19, returning from the subroutine with using a tail
                        \ call (this BNE is effectively a JMP as A will never
                        \ be zero)

\ ******************************************************************************
\
\       Name: NLIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line at pixel row 23 to box in a title
\
\ ------------------------------------------------------------------------------
\
\ Draw a horizontal line at pixel row 23 and move the text cursor down one
\ line.
\
\ ******************************************************************************

.NLIN

 LDA #23                \ Set A = 23 so NLIN2 below draws a horizontal line at
                        \ pixel row 23

 INC YC                 \ Move the text cursor down one line

                        \ Fall through into NLIN2 to draw the horizontal line
                        \ at row 23

\ ******************************************************************************
\
\       Name: NLIN2
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a screen-wide horizontal line at the pixel row in A
\
\ ------------------------------------------------------------------------------
\
\ This draws a line from (2, A) to (254, A), which is almost screen-wide and
\ fits in nicely between the white borders without clashing with it.
\
\ Arguments:
\
\   A                   The pixel row on which to draw the horizontal line
\
\ ******************************************************************************

.NLIN2

 STA Y1                 \ Set Y1 = A

 LDX #2                 \ Set X1 = 2, so (X1, Y1) = (2, A)
 STX X1

 LDX #254               \ Set X2 = 254, so (X2, Y2) = (254, A)
 STX X2

 BNE HLOIN              \ Call HLOIN to draw a horizontal line from (2, A) to
                        \ (254, A) and return from the subroutine (this BNE is
                        \ effectively a JMP as A will never be zero)

\ ******************************************************************************
\
\       Name: HLOIN2
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Remove a line from the sun line heap and draw it on-screen
\
\ ------------------------------------------------------------------------------
\
\ Specifically, this does the following:
\
\   * Set X1 and X2 to the x-coordinates of the ends of the horizontal line with
\     centre YY(1 0) and length A to the left and right
\
\   * Set the Y-th byte of the LSO block to 0 (i.e. remove this line from the
\     sun line heap)
\
\   * Draw a horizontal line from (X1, Y) to (X2, Y)
\
\ Arguments:
\
\   YY(1 0)             The x-coordinate of the centre point of the line
\
\   A                   The half-width of the line, i.e. the contents of the
\                       Y-th byte of the sun line heap
\
\   Y                   The number of the entry in the sun line heap (which is
\                       also the y-coordinate of the line)
\
\ Returns:
\
\   Y                   Y is preserved
\
\ ******************************************************************************

.HLOIN2

 JSR EDGES              \ Call EDGES to calculate X1 and X2 for the horizontal
                        \ line centred on YY(1 0) and with half-width A

 STY Y1                 \ Set Y1 = Y

 LDA #0                 \ Set the Y-th byte of the LSO block to 0
 STA LSO,Y

                        \ Fall through into HLOIN to draw a horizontal line from
                        \ (X1, Y) to (X2, Y)

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

 STY YSAV               \ Store Y into YSAV, so we can preserve it across the
                        \ call to this subroutine

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

 LSR A                  \ Set R = A / 8, so R now contains the number of
 LSR A                  \ character blocks we need to fill - 1
 LSR A
 STA R

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

 LDX R                  \ Fetch the number of character blocks we need to fill
                        \ from R

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved across the
                        \ call to this subroutine

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

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

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

 LDY T1                 \ Restore Y from T1, so Y is preserved by the routine

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
\ Other entry points:
\
\   PX4                 Contains an RTS
\
\ ******************************************************************************

.PIXEL

 STY T1                 \ Store Y in T1

 TAY                    \ Copy A into Y, for use later

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

 LDY T1                 \ Restore Y from T1, so Y is preserved by the routine

.PX4

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BLINE
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw a circle segment and add it to the ball line heap
\  Deep dive: The ball line heap
\             Drawing circles
\
\ ------------------------------------------------------------------------------
\
\ Draw a single segment of a circle, adding the point to the ball line heap.
\
\ Arguments:
\
\   CNT                 The number of this segment
\
\   STP                 The step size for the circle
\
\   K6(1 0)             The x-coordinate of the new point on the circle, as
\                       a screen coordinate
\
\   (T X)               The y-coordinate of the new point on the circle, as
\                       an offset from the centre of the circle
\
\   FLAG                Set to &FF for the first call, so it sets up the first
\                       point in the heap but waits until the second call before
\                       drawing anything (as we need two points, i.e. two calls,
\                       before we can draw a line)
\
\   K                   The circle's radius
\
\   K3(1 0)             Pixel x-coordinate of the centre of the circle
\
\   K4(1 0)             Pixel y-coordinate of the centre of the circle
\
\   SWAP                If non-zero, we swap (X1, Y1) and (X2, Y2)
\
\ Returns:
\
\   CNT                 CNT is updated to CNT + STP
\
\   A                   The new value of CNT
\
\   FLAG                Set to 0
\
\ ******************************************************************************

.BLINE

 TXA                    \ Set K6(3 2) = (T X) + K4(1 0)
 ADC K4                 \             = y-coord of centre + y-coord of new point
 STA K6+2               \
 LDA K4+1               \ so K6(3 2) now contains the y-coordinate of the new
 ADC T                  \ point on the circle but as a screen coordinate, to go
 STA K6+3               \ along with the screen y-coordinate in K6(1 0)

 LDA FLAG               \ If FLAG = 0, jump down to BL1
 BEQ BL1

 INC FLAG               \ Flag is &FF so this is the first call to BLINE, so
                        \ increment FLAG to set it to 0, as then the next time
                        \ we call BLINE it can draw the first line, from this
                        \ point to the next

.BL5

                        \ The following inserts a &FF marker into the LSY2 line
                        \ heap to indicate that the next call to BLINE should
                        \ store both the (X1, Y1) and (X2, Y2) points. We do
                        \ this on the very first call to BLINE (when FLAG is
                        \ &FF), and on subsequent calls if the segment does not
                        \ fit on-screen, in which case we don't draw or store
                        \ that segment, and we start a new segment with the next
                        \ call to BLINE that does fit on-screen

 LDY LSP                \ If byte LSP-1 of LSY2 = &FF, jump to BL7 to tidy up
 LDA #&FF               \ and return from the subroutine, as the point that has
 CMP LSY2-1,Y           \ been passed to BLINE is the start of a segment, so all
 BEQ BL7                \ we need to do is save the coordinate in K5, without
                        \ moving the pointer in LSP

 STA LSY2,Y             \ Otherwise we just tried to plot a segment but it
                        \ didn't fit on-screen, so put the &FF marker into the
                        \ heap for this point, so the next call to BLINE starts
                        \ a new segment

 INC LSP                \ Increment LSP to point to the next point in the heap

 BNE BL7                \ Jump to BL7 to tidy up and return from the subroutine
                        \ (this BNE is effectively a JMP, as LSP will never be
                        \ zero)

.BL1

 LDA K5                 \ Set XX15 = K5 = x_lo of previous point
 STA XX15

 LDA K5+1               \ Set XX15+1 = K5+1 = x_hi of previous point
 STA XX15+1

 LDA K5+2               \ Set XX15+2 = K5+2 = y_lo of previous point
 STA XX15+2

 LDA K5+3               \ Set XX15+3 = K5+3 = y_hi of previous point
 STA XX15+3

 LDA K6                 \ Set XX15+4 = x_lo of new point
 STA XX15+4

 LDA K6+1               \ Set XX15+5 = x_hi of new point
 STA XX15+5

 LDA K6+2               \ Set XX12 = y_lo of new point
 STA XX12

 LDA K6+3               \ Set XX12+1 = y_hi of new point
 STA XX12+1

 JSR LL145              \ Call LL145 to see if the new line segment needs to be
                        \ clipped to fit on-screen, returning the clipped line's
                        \ end-points in (X1, Y1) and (X2, Y2)

 BCS BL5                \ If the C flag is set then the line is not visible on
                        \ screen anyway, so jump to BL5, to avoid drawing and
                        \ storing this line

 LDA SWAP               \ If SWAP = 0, then we didn't have to swap the line
 BEQ BL9                \ coordinates around during the clipping process, so
                        \ jump to BL9 to skip the following swap

 LDA X1                 \ Otherwise the coordinates were swapped by the call to
 LDY X2                 \ LL145 above, so we swap (X1, Y1) and (X2, Y2) back
 STA X2                 \ again
 STY X1
 LDA Y1
 LDY Y2
 STA Y2
 STY Y1

.BL9

 LDY LSP                \ Set Y = LSP

 LDA LSY2-1,Y           \ If byte LSP-1 of LSY2 is not &FF, jump down to BL8
 CMP #&FF               \ to skip the following (X1, Y1) code
 BNE BL8

                        \ Byte LSP-1 of LSY2 is &FF, which indicates that we
                        \ need to store (X1, Y1) in the heap

 LDA X1                 \ Store X1 in the LSP-th byte of LSX2
 STA LSX2,Y

 LDA Y1                 \ Store Y1 in the LSP-th byte of LSY2
 STA LSY2,Y

 INY                    \ Increment Y to point to the next byte in LSX2/LSY2

.BL8

 LDA X2                 \ Store X2 in the LSP-th byte of LSX2
 STA LSX2,Y

 LDA Y2                 \ Store Y2 in the LSP-th byte of LSX2
 STA LSY2,Y

 INY                    \ Increment Y to point to the next byte in LSX2/LSY2

 STY LSP                \ Update LSP to point to the same as Y

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 LDA XX13               \ If XX13 is non-zero, jump up to BL5 to add a &FF
 BNE BL5                \ marker to the end of the line heap. XX13 is non-zero
                        \ after the call to the clipping routine LL145 above if
                        \ the end of the line was clipped, meaning the next line
                        \ sent to BLINE can't join onto the end but has to start
                        \ a new segment, and that's what inserting the &FF
                        \ marker does

.BL7

 LDA K6                 \ Copy the data for this step point from K6(3 2 1 0)
 STA K5                 \ into K5(3 2 1 0), for use in the next call to BLINE:
 LDA K6+1               \
 STA K5+1               \   * K5(1 0) = screen x-coordinate of this point
 LDA K6+2               \
 STA K5+2               \   * K5(3 2) = screen y-coordinate of this point
 LDA K6+3               \
 STA K5+3               \ They now become the "previous point" in the next call

 LDA CNT                \ Set CNT = CNT + STP
 CLC
 ADC STP
 STA CNT

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TENS
\       Type: Variable
\   Category: Text
\    Summary: A constant used when printing large numbers in BPRNT
\  Deep dive: Printing decimal numbers
\
\ ------------------------------------------------------------------------------
\
\ Contains the four low bytes of the value 100,000,000,000 (100 billion).
\
\ The maximum number of digits that we can print with the BPRNT routine is 11,
\ so the biggest number we can print is 99,999,999,999. This maximum number
\ plus 1 is 100,000,000,000, which in hexadecimal is:
\
\   & 17 48 76 E8 00
\
\ The TENS variable contains the lowest four bytes in this number, with the
\ most significant byte first, i.e. 48 76 E8 00. This value is used in the
\ BPRNT routine when working out which decimal digits to print when printing a
\ number.
\
\ ******************************************************************************

.TENS

 EQUD &00E87648

\ ******************************************************************************
\
\       Name: pr2
\       Type: Subroutine
\   Category: Text
\    Summary: Print an 8-bit number, left-padded to 3 digits, and optional point
\
\ ------------------------------------------------------------------------------
\
\ Print the 8-bit number in X to 3 digits, left-padding with spaces for numbers
\ with fewer than 3 digits (so numbers < 100 are right-aligned). Optionally
\ include a decimal point.
\
\ Arguments:
\
\   X                   The number to print
\
\   C flag              If set, include a decimal point
\
\ Other entry points:
\
\   pr2+2               Print the 8-bit number in X to the number of digits in A
\
\ ******************************************************************************

.pr2

 LDA #3                 \ Set A to the number of digits (3)

 LDY #0                 \ Zero the Y register, so we can fall through into TT11
                        \ to print the 16-bit number (Y X) to 3 digits, which
                        \ effectively prints X to 3 digits as the high byte is
                        \ zero

\ ******************************************************************************
\
\       Name: TT11
\       Type: Subroutine
\   Category: Text
\    Summary: Print a 16-bit number, left-padded to n digits, and optional point
\
\ ------------------------------------------------------------------------------
\
\ Print the 16-bit number in (Y X) to a specific number of digits, left-padding
\ with spaces for numbers with fewer digits (so lower numbers will be right-
\ aligned). Optionally include a decimal point.
\
\ Arguments:
\
\   X                   The low byte of the number to print
\
\   Y                   The high byte of the number to print
\
\   A                   The number of digits
\
\   C flag              If set, include a decimal point
\
\ ******************************************************************************

.TT11

 STA U                  \ We are going to use the BPRNT routine (below) to
                        \ print this number, so we store the number of digits
                        \ in U, as that's what BPRNT takes as an argument

 LDA #0                 \ BPRNT takes a 32-bit number in K to K+3, with the
 STA K                  \ most significant byte first (big-endian), so we set
 STA K+1                \ the two most significant bytes to zero (K and K+1)
 STY K+2                \ and store (Y X) in the least two significant bytes
 STX K+3                \ (K+2 and K+3), so we are going to print the 32-bit
                        \ number (0 0 Y X)

                        \ Finally we fall through into BPRNT to print out the
                        \ number in K to K+3, which now contains (Y X), to 3
                        \ digits (as U = 3), using the same C flag as when pr2
                        \ was called to control the decimal point

\ ******************************************************************************
\
\       Name: BPRNT
\       Type: Subroutine
\   Category: Text
\    Summary: Print a 32-bit number, left-padded to a specific number of digits,
\             with an optional decimal point
\  Deep dive: Printing decimal numbers
\
\ ------------------------------------------------------------------------------
\
\ Print the 32-bit number stored in K(0 1 2 3) to a specific number of digits,
\ left-padding with spaces for numbers with fewer digits (so lower numbers are
\ right-aligned). Optionally include a decimal point.
\
\ See the deep dive on "Printing decimal numbers" for details of the algorithm
\ used in this routine.
\
\ Arguments:
\
\   K(0 1 2 3)          The number to print, stored with the most significant
\                       byte in K and the least significant in K+3 (i.e. as a
\                       big-endian number, which is the opposite way to how the
\                       6502 assembler stores addresses, for example)
\
\   U                   The maximum number of digits to print, including the
\                       decimal point (spaces will be used on the left to pad
\                       out the result to this width, so the number is right-
\                       aligned to this width). U must be 11 or less
\
\   C flag              If set, include a decimal point followed by one
\                       fractional digit (i.e. show the number to 1 decimal
\                       place). In this case, the number in K(0 1 2 3) contains
\                       10 * the number we end up printing, so to print 123.4,
\                       we would pass 1234 in K(0 1 2 3) and would set the C
\                       flag to include the decimal point
\
\ ******************************************************************************

.BPRNT

 LDX #11                \ Set T to the maximum number of digits allowed (11
 STX T                  \ characters, which is the number of digits in 10
                        \ billion). We will use this as a flag when printing
                        \ characters in TT37 below

 PHP                    \ Make a copy of the status register (in particular
                        \ the C flag) so we can retrieve it later

 BCC TT30               \ If the C flag is clear, we do not want to print a
                        \ decimal point, so skip the next two instructions

 DEC T                  \ As we are going to show a decimal point, decrement
 DEC U                  \ both the number of characters and the number of
                        \ digits (as one of them is now a decimal point)

.TT30

 LDA #11                \ Set A to 11, the maximum number of digits allowed

 SEC                    \ Set the C flag so we can do subtraction without the
                        \ C flag affecting the result

 STA XX17               \ Store the maximum number of digits allowed (11) in
                        \ XX17

 SBC U                  \ Set U = 11 - U + 1, so U now contains the maximum
 STA U                  \ number of digits minus the number of digits we want
 INC U                  \ to display, plus 1 (so this is the number of digits
                        \ we should skip before starting to print the number
                        \ itself, and the plus 1 is there to ensure we print at
                        \ least one digit)

 LDY #0                 \ In the main loop below, we use Y to count the number
                        \ of times we subtract 10 billion to get the leftmost
                        \ digit, so set this to zero

 STY S                  \ In the main loop below, we use location S as an
                        \ 8-bit overflow for the 32-bit calculations, so
                        \ we need to set this to 0 before joining the loop

 JMP TT36               \ Jump to TT36 to start the process of printing this
                        \ number's digits

.TT35

                        \ This subroutine multiplies K(S 0 1 2 3) by 10 and
                        \ stores the result back in K(S 0 1 2 3), using the fact
                        \ that K * 10 = (K * 2) + (K * 2 * 2 * 2)

 ASL K+3                \ Set K(S 0 1 2 3) = K(S 0 1 2 3) * 2 by rotating left
 ROL K+2
 ROL K+1
 ROL K
 ROL S

 LDX #3                 \ Now we want to make a copy of the newly doubled K in
                        \ XX15, so we can use it for the first (K * 2) in the
                        \ equation above, so set up a counter in X for copying
                        \ four bytes, starting with the last byte in memory
                        \ (i.e. the least significant)

.tt35

 LDA K,X                \ Copy the X-th byte of K(0 1 2 3) to the X-th byte of
 STA XX15,X             \ XX15(0 1 2 3), so that XX15 will contain a copy of
                        \ K(0 1 2 3) once we've copied all four bytes

 DEX                    \ Decrement the loop counter

 BPL tt35               \ Loop back to copy the next byte until we have copied
                        \ all four

 LDA S                  \ Store the value of location S, our overflow byte, in
 STA XX15+4             \ XX15+4, so now XX15(4 0 1 2 3) contains a copy of
                        \ K(S 0 1 2 3), which is the value of (K * 2) that we
                        \ want to use in our calculation

 ASL K+3                \ Now to calculate the (K * 2 * 2 * 2) part. We still
 ROL K+2                \ have (K * 2) in K(S 0 1 2 3), so we just need to shift
 ROL K+1                \ it twice. This is the first one, so we do this:
 ROL K                  \
 ROL S                  \   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 4

 ASL K+3                \ And then we do it again, so that means:
 ROL K+2                \
 ROL K+1                \   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 8
 ROL K
 ROL S

 CLC                    \ Clear the C flag so we can do addition without the
                        \ C flag affecting the result

 LDX #3                 \ By now we've got (K * 2) in XX15(4 0 1 2 3) and
                        \ (K * 8) in K(S 0 1 2 3), so the final step is to add
                        \ these two 32-bit numbers together to get K * 10.
                        \ So we set a counter in X for four bytes, starting
                        \ with the last byte in memory (i.e. the least
                        \ significant)

.tt36

 LDA K,X                \ Fetch the X-th byte of K into A

 ADC XX15,X             \ Add the X-th byte of XX15 to A, with carry

 STA K,X                \ Store the result in the X-th byte of K

 DEX                    \ Decrement the loop counter

 BPL tt36               \ Loop back to add the next byte, moving from the least
                        \ significant byte to the most significant, until we
                        \ have added all four

 LDA XX15+4             \ Finally, fetch the overflow byte from XX15(4 0 1 2 3)

 ADC S                  \ And add it to the overflow byte from K(S 0 1 2 3),
                        \ with carry

 STA S                  \ And store the result in the overflow byte from
                        \ K(S 0 1 2 3), so now we have our desired result, i.e.
                        \
                        \   K(S 0 1 2 3) = K(S 0 1 2 3) * 10

 LDY #0                 \ In the main loop below, we use Y to count the number
                        \ of times we subtract 10 billion to get the leftmost
                        \ digit, so set this to zero so we can rejoin the main
                        \ loop for another subtraction process

.TT36

                        \ This is the main loop of our digit-printing routine.
                        \ In the following loop, we are going to count the
                        \ number of times that we can subtract 10 million and
                        \ store that count in Y, which we have already set to 0

 LDX #3                 \ Our first calculation concerns 32-bit numbers, so
                        \ set up a counter for a four-byte loop

 SEC                    \ Set the C flag so we can do subtraction without the
                        \ C flag affecting the result

.tt37

                        \ We now loop through each byte in turn to do this:
                        \
                        \   XX15(4 0 1 2 3) = K(S 0 1 2 3) - 100,000,000,000

 LDA K,X                \ Subtract the X-th byte of TENS (i.e. 10 billion) from
 SBC TENS,X             \ the X-th byte of K

 STA XX15,X             \ Store the result in the X-th byte of XX15

 DEX                    \ Decrement the loop counter

 BPL tt37               \ Loop back to subtract the next byte, moving from the
                        \ least significant byte to the most significant, until
                        \ we have subtracted all four

 LDA S                  \ Subtract the fifth byte of 10 billion (i.e. &17) from
 SBC #&17               \ the fifth (overflow) byte of K, which is S

 STA XX15+4             \ Store the result in the overflow byte of XX15

 BCC TT37               \ If subtracting 10 billion took us below zero, jump to
                        \ TT37 to print out this digit, which is now in Y

 LDX #3                 \ We now want to copy XX15(4 0 1 2 3) back into
                        \ K(S 0 1 2 3), so we can loop back up to do the next
                        \ subtraction, so set up a counter for a four-byte loop

.tt38

 LDA XX15,X             \ Copy the X-th byte of XX15(0 1 2 3) to the X-th byte
 STA K,X                \ of K(0 1 2 3), so that K(0 1 2 3) will contain a copy
                        \ of XX15(0 1 2 3) once we've copied all four bytes

 DEX                    \ Decrement the loop counter

 BPL tt38               \ Loop back to copy the next byte, until we have copied
                        \ all four

 LDA XX15+4             \ Store the value of location XX15+4, our overflow
 STA S                  \ byte in S, so now K(S 0 1 2 3) contains a copy of
                        \ XX15(4 0 1 2 3)

 INY                    \ We have now managed to subtract 10 billion from our
                        \ number, so increment Y, which is where we are keeping
                        \ a count of the number of subtractions so far

 JMP TT36               \ Jump back to TT36 to subtract the next 10 billion

.TT37

 TYA                    \ If we get here then Y contains the digit that we want
                        \ to print (as Y has now counted the total number of
                        \ subtractions of 10 billion), so transfer Y into A

 BNE TT32               \ If the digit is non-zero, jump to TT32 to print it

 LDA T                  \ Otherwise the digit is zero. If we are already
                        \ printing the number then we will want to print a 0,
                        \ but if we haven't started printing the number yet,
                        \ then we probably don't, as we don't want to print
                        \ leading zeroes unless this is the only digit before
                        \ the decimal point
                        \
                        \ To help with this, we are going to use T as a flag
                        \ that tells us whether we have already started
                        \ printing digits:
                        \
                        \   * If T <> 0 we haven't printed anything yet
                        \
                        \   * If T = 0 then we have started printing digits
                        \
                        \ We initially set T above to the maximum number of
                        \ characters allowed, less 1 if we are printing a
                        \ decimal point, so the first time we enter the digit
                        \ printing routine at TT37, it is definitely non-zero

 BEQ TT32               \ If T = 0, jump straight to the print routine at TT32,
                        \ as we have already started printing the number, so we
                        \ definitely want to print this digit too

 DEC U                  \ We initially set U to the number of digits we want to
 BPL TT34               \ skip before starting to print the number. If we get
                        \ here then we haven't printed any digits yet, so
                        \ decrement U to see if we have reached the point where
                        \ we should start printing the number, and if not, jump
                        \ to TT34 to set up things for the next digit

 LDA #' '               \ We haven't started printing any digits yet, but we
 BNE tt34               \ have reached the point where we should start printing
                        \ our number, so call TT26 (via tt34) to print a space
                        \ so that the number is left-padded with spaces (this
                        \ BNE is effectively a JMP as A will never be zero)

.TT32

 LDY #0                 \ We are printing an actual digit, so first set T to 0,
 STY T                  \ to denote that we have now started printing digits as
                        \ opposed to spaces

 CLC                    \ The digit value is in A, so add ASCII "0" to get the
 ADC #'0'               \ ASCII character number to print

.tt34

 JSR TT26               \ Call TT26 to print the character in A and fall through
                        \ into TT34 to get things ready for the next digit

.TT34

 DEC T                  \ Decrement T but keep T >= 0 (by incrementing it
 BPL P%+4               \ again if the above decrement made T negative)
 INC T

 DEC XX17               \ Decrement the total number of characters left to
                        \ print, which we stored in XX17

 BMI rT10               \ If the result is negative, we have printed all the
                        \ characters, so jump down to rT10 to return from the
                        \ subroutine

 BNE P%+10              \ If the result is positive (> 0) then we still have
                        \ characters left to print, so loop back to TT35 (via
                        \ the JMP TT35 instruction below) to print the next
                        \ digit

 PLP                    \ If we get here then we have printed the exact number
                        \ of digits that we wanted to, so restore the C flag
                        \ that we stored at the start of the routine

 BCC P%+7               \ If the C flag is clear, we don't want a decimal point,
                        \ so loop back to TT35 (via the JMP TT35 instruction
                        \ below) to print the next digit

 LDA #'.'               \ Otherwise the C flag is set, so print the decimal
 JSR TT26               \ point

 JMP TT35               \ Loop back to TT35 to print the next digit

.rT10

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DTW1
\       Type: Variable
\   Category: Text
\    Summary: A mask for applying the lower case part of Sentence Case to
\             extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to change characters to lower case as part of applying
\ Sentence Case to extended text tokens. It has two values:
\
\   * %00100000 = apply lower case to the second letter of a word onwards
\
\   * %00000000 = do not change case to lower case
\
\ The default value is %00100000 (apply lower case).
\
\ The flag is set to %00100000 (apply lower case) by jump token 2, {sentence
\ case}, which calls routine MT2 to change the value of DTW1.
\
\ The flag is set to %00000000 (do not change case to lower case) by jump token
\ 1, {all caps}, which calls routine MT1 to change the value of DTW1.
\
\ The letter to print is OR'd with DTW1 in DETOK2, which lower-cases the letter
\ by setting bit 5 (if DTW1 is %00100000). However, this OR is only done if bit
\ 7 of DTW2 is clear, i.e. we are printing a word, so this doesn't affect the
\ first letter of the word, which remains capitalised.
\
\ ******************************************************************************

.DTW1

 EQUB %00100000

\ ******************************************************************************
\
\       Name: DTW2
\       Type: Variable
\   Category: Text
\    Summary: A flag that indicates whether we are currently printing a word
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether we are currently printing a word. It
\ has two values:
\
\   * 0 = we are currently printing a word
\
\   * Non-zero = we are not currently printing a word
\
\ The default value is %11111111 (we are not currently printing a word).
\
\ The flag is set to %00000000 (we are currently printing a word) whenever a
\ non-terminator character is passed to DASC for printing.
\
\ The flag is set to %11111111 (we are not currently printing a word) whenever a
\ terminator character (full stop, colon, carriage return, line feed, space) is
\ passed to DASC for printing. It is also set to %11111111 by jump token 8,
\ {tab 6}, which calls routine MT8 to change the value of DTW2, and to %10000000
\ by TTX66 when we clear the screen.
\
\ ******************************************************************************

.DTW2

 EQUB %11111111

\ ******************************************************************************
\
\       Name: DTW3
\       Type: Variable
\   Category: Text
\    Summary: A flag for switching between standard and extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether standard or extended text tokens
\ should be printed by calls to DETOK. It allows us to mix standard tokens in
\ with extended tokens. It has two values:
\
\   * %00000000 = print extended tokens (i.e. those in TKN1 and RUTOK)
\
\   * %11111111 = print standard tokens (i.e. those in QQ18)
\
\ The default value is %00000000 (extended tokens).
\
\ Standard tokens are set by jump token {6}, which calls routine MT6 to change
\ the value of DTW3 to %11111111.
\
\ Extended tokens are set by jump token {5}, which calls routine MT5 to change
\ the value of DTW3 to %00000000.
\
\ ******************************************************************************

.DTW3

 EQUB %00000000

\ ******************************************************************************
\
\       Name: DTW4
\       Type: Variable
\   Category: Text
\    Summary: Flags that govern how justified extended text tokens are printed
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to control how justified text tokens are printed as part
\ of the extended text token system. There are two bits that affect justified
\ text:
\
\   * Bit 7: 1 = justify text
\            0 = do not justify text
\
\   * Bit 6: 1 = buffer the entire token before printing, including carriage
\                returns (used for in-flight messages only)
\            0 = print the contents of the buffer whenever a carriage return
\                appears in the token
\
\ The default value is %00000000 (do not justify text, print buffer on carriage
\ return).
\
\ The flag is set to %10000000 (justify text, print buffer on carriage return)
\ by jump token 14, {justify}, which calls routine MT14 to change the value of
\ DTW4.
\
\ The flag is set to %11000000 (justify text, buffer entire token) by routine
\ MESS, which printe in-flight messages.
\
\ The flag is set to %00000000 (do not justify text, print buffer on carriage
\ return) by jump token 15, {left align}, which calls routine MT1 to change the
\ value of DTW4.
\
\ ******************************************************************************

.DTW4

 EQUB 0

\ ******************************************************************************
\
\       Name: DTW5
\       Type: Variable
\   Category: Text
\    Summary: The size of the justified text buffer at BUF
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ When justified text is enabled by jump token 14, {justify}, during printing of
\ extended text tokens, text is fed into a buffer at BUF instead of being
\ printed straight away, so it can be padded out with spaces to justify the
\ text. DTW5 contains the size of the buffer, so BUF + DTW5 points to the first
\ free byte after the end of the buffer.
\
\ ******************************************************************************

.DTW5

 EQUB 0

\ ******************************************************************************
\
\       Name: DTW6
\       Type: Variable
\   Category: Text
\    Summary: A flag to denote whether printing in lower case is enabled for
\             extended text tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is used to indicate whether lower case is currently enabled. It
\ has two values:
\
\   * %10000000 = lower case is enabled
\
\   * %00000000 = lower case is not enabled
\
\ The default value is %00000000 (lower case is not enabled).
\
\ The flag is set to %10000000 (lower case is enabled) by jump token 13 {lower
\ case}, which calls routine MT10 to change the value of DTW6.
\
\ The flag is set to %00000000 (lower case is not enabled) by jump token 1, {all
\ caps}, and jump token 1, {sentence case}, which call routines MT1 and MT2 to
\ change the value of DTW6.
\
\ ******************************************************************************

.DTW6

 EQUB %00000000

\ ******************************************************************************
\
\       Name: DTW8
\       Type: Variable
\   Category: Text
\    Summary: A mask for capitalising the next letter in an extended text token
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This variable is only used by one specific extended token, the {single cap}
\ jump token, which capitalises the next letter only. It has two values:
\
\   * %11011111 = capitalise the next letter
\
\   * %11111111 = do not change case
\
\ The default value is %11111111 (do not change case).
\
\ The flag is set to %11011111 (capitalise the next letter) by jump token 19,
\ {single cap}, which calls routine MT19 to change the value of DTW.
\
\ The flag is set to %11111111 (do not change case) at the start of DASC, after
\ the letter has been capitalised in DETOK2, so the effect is to capitalise one
\ letter only.
\
\ The letter to print is AND'd with DTW8 in DETOK2, which capitalises the letter
\ by clearing bit 5 (if DTW8 is %11011111). However, this AND is only done if at
\ least one of the following is true:
\
\   * Bit 7 of DTW2 is set (we are not currently printing a word)
\
\   * Bit 7 of DTW6 is set (lower case has been enabled by jump token 13, {lower
\     case}
\
\ In other words, we only capitalise the next letter if it's the first letter in
\ a word, or we are printing in lower case.
\
\ ******************************************************************************

.DTW8

 EQUB %11111111

\ ******************************************************************************
\
\       Name: FEED
\       Type: Subroutine
\   Category: Text
\    Summary: Print a newline
\
\ ******************************************************************************

.FEED

 LDA #12                \ Set A = 12, so when we skip MT16 and fall through into
                        \ TT26, we print character 12, which is a newline

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &41, or BIT &41A9, which does nothing apart
                        \ from affect the flags

                        \ Fall through into TT26 (skipping MT16) to print the
                        \ newline character

\ ******************************************************************************
\
\       Name: MT16
\       Type: Subroutine
\   Category: Text
\    Summary: Print the character in variable DTW7
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.MT16

 LDA #'A'               \ Set A to the contents of DTW7, as DTW7 points to the
                        \ second byte of this instruction, so updating DTW7 will
                        \ modify this instruction (the default value of DTW7 is
                        \ an "A")

DTW7 = MT16 + 1         \ Point DTW7 to the second byte of the instruction above
                        \ so that modifying DTW7 changes the value loaded into A

                        \ Fall through into TT26 to print the character in A

\ ******************************************************************************
\
\       Name: TT26
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor, with support for verified
\             text in extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to print
\
\ Returns:
\
\   X                   X is preserved
\
\   C flag              The C flag is cleared
\
\ Other entry points:
\
\   DASC                DASC does exactly the same as TT26 and prints a
\                       character at the text cursor, with support for verified
\                       text in extended tokens
\
\   rT9                 Contains an RTS
\
\ ******************************************************************************

.DASC

.TT26

 STX SC                 \ Store X in SC, so we can retrieve it below

 LDX #%11111111         \ Set DTW8 = %11111111, to disable the effect of {19} if
 STX DTW8               \ it was set (as {19} capitalises one character only)

 CMP #'.'               \ If the character in A is a word terminator:
 BEQ DA8                \
 CMP #':'               \   * Full stop
 BEQ DA8                \   * Colon
 CMP #10                \   * Line feed
 BEQ DA8                \   * Carriage return
 CMP #12                \   * Space
 BEQ DA8                \
 CMP #' '               \ then skip the following instruction
 BEQ DA8

 INX                    \ Increment X to 0, so DTW2 gets set to %00000000 below

.DA8

 STX DTW2               \ Store X in DTW2, so DTW2 is now:
                        \
                        \   * %00000000 if this character is a word terminator
                        \
                        \   * %11111111 if it isn't
                        \
                        \ so DTW2 indicates whether or not we are currently
                        \ printing a word

 LDX SC                 \ Retrieve the original value of X from SC

 BIT DTW4               \ If bit 7 of DTW4 is set then we are currently printing
 BMI P%+5               \ justified text, so skip the next instruction

 JMP CHPR               \ Bit 7 of DTW4 is clear, so jump down to CHPR to print
                        \ this character, as we are not printing justified text

                        \ If we get here then we are printing justified text, so
                        \ we need to buffer the text until we reach the end of
                        \ the paragraph, so we can then pad it out with spaces

 CMP #12                \ If the character in A is a carriage return, then we
 BEQ DA1                \ have reached the end of the paragraph, so jump down to
                        \ DA1 to print out the contents of the buffer,
                        \ justifying it as we go

                        \ If we get here then we need to buffer this character
                        \ in the line buffer at BUF

 LDX DTW5               \ DTW5 contains the current size of the buffer, so this
 STA BUF,X              \ stores the character in A at BUF + DTW5, the next free
                        \ space in the buffer

 LDX SC                 \ Retrieve the original value of X from SC so we can
                        \ preserve it through this subroutine call

 INC DTW5               \ Increment the size of the BUF buffer that is stored in
                        \ DTW5

 CLC                    \ Clear the C flag

 RTS                    \ Return from the subroutine

.DA1

                        \ If we get here then we are justifying text and we have
                        \ reached the end of the paragraph, so we need to print
                        \ out the contents of the buffer, justifying it as we go

 TXA                    \ Store X and Y on the stack
 PHA
 TYA
 PHA

.DA5

 LDX DTW5               \ Set X = DTW5, which contains the size of the buffer

 BEQ DA6+3              \ If X = 0 then the buffer is empty, so jump down to
                        \ DA6+3 to print a newline

 CPX #(LL+1)            \ If X < LL+1, i.e. X <= LL, then the buffer contains
 BCC DA6                \ fewer than LL characters, which is less then a line
                        \ length, so jump down to DA6 to print the contents of
                        \ BUF followed by a newline, as we don't justify the
                        \ last line of the paragraph

                        \ Otherwise X > LL, so the buffer does not fit into one
                        \ line, and we therefore need to justify the text, which
                        \ we do one line at a time

 LSR SC+1               \ Shift SC+1 to the right, which clears bit 7 of SC+1,
                        \ so we pass through the following comparison on the
                        \ first iteration of the loop and set SC+1 to %01000000

.DA11

 LDA SC+1               \ If bit 7 of SC+1 is set, skip the following two
 BMI P%+6               \ instructions

 LDA #%01000000         \ Set SC+1 = %01000000
 STA SC+1

 LDY #(LL-1)            \ Set Y = line length, so we can loop backwards from the
                        \ end of the first line in the buffer using Y as the
                        \ loop counter

.DAL1

 LDA BUF+LL             \ If the LL-th byte in BUF is a space, jump down to DA2
 CMP #' '               \ to print out the first line from the buffer, as it
 BEQ DA2                \ fits the line width exactly (i.e. it's justified)

                        \ We now want to find the last space character in the
                        \ first line in the buffer, so we loop through the line
                        \ using Y as a counter

.DAL2

 DEY                    \ Decrement the loop counter in Y

 BMI DA11               \ If Y <= 0, loop back to DA11, as we have now looped
 BEQ DA11               \ through the whole line

 LDA BUF,Y              \ If the Y-th byte in BUF is not a space, loop back up
 CMP #' '               \ to DAL2 to check the next character
 BNE DAL2

                        \ Y now points to a space character in the line buffer

 ASL SC+1               \ Shift SC+1 to the left

 BMI DAL2               \ If bit 7 of SC+1 is set, jump to DAL2 to find the next
                        \ space character

                        \ We now want to insert a space into the line buffer at
                        \ position Y, which we do by shifting every character
                        \ after position Y along by 1, and then inserting the
                        \ space

 STY SC                 \ Store Y in SC, so we want to insert the space at
                        \ position SC

 LDY DTW5               \ Fetch the buffer size from DTW5 into Y, to act as a
                        \ loop counter for moving the line buffer along by 1

.DAL6

 LDA BUF,Y              \ Copy the Y-th character from BUF into the Y+1-th
 STA BUF+1,Y            \ position

 DEY                    \ Decrement the loop counter in Y

 CPY SC                 \ Loop back to shift the next character along, until we
 BCS DAL6               \ have moved the SC-th character (i.e. Y < SC)

 INC DTW5               \ Increment the buffer size in DTW5

\LDA #' '               \ This instruction is commented out in the original
                        \ source, as it has no effect because A already contains
                        \ ASCII " ". This is because the last character that is
                        \ tested in the above loop is at position SC, which we
                        \ know contains a space, so we know A contains a space
                        \ character when the loop finishes

                        \ We've now shifted the line to the right by 1 from
                        \ position SC onwards, so SC and SC+1 both contain
                        \ spaces, and Y is now SC-1 as we did a DEY just before
                        \ the end of the loop - in other words, we have inserted
                        \ a space at position SC, and Y points to the character
                        \ before the newly inserted space

                        \ We now want to move the pointer Y left to find the
                        \ next space in the line buffer, before looping back to
                        \ check whether we are done, and if not, insert another
                        \ space

.DAL3

 CMP BUF,Y              \ If the character at position Y is not a space, jump to
 BNE DAL1               \ DAL1 to see whether we have now justified the line

 DEY                    \ Decrement the loop counter in Y

 BPL DAL3               \ Loop back to check the next character to the left,
                        \ until we have found a space

 BMI DA11               \ Jump back to DA11 (this BMI is effectively a JMP as
                        \ we already passed through a BPL to get here)

.DA2

                        \ This subroutine prints out a full line of characters
                        \ from the start of the line buffer in BUF, followed by
                        \ a newline. It then removes that line from the buffer,
                        \ shuffling the rest of the buffer contents down

 LDX #LL                \ Call DAS1 to print out the first LL characters from
 JSR DAS1               \ the line buffer in BUF

 LDA #12                \ Print a newline
 JSR CHPR

 LDA DTW5               \ Subtract #LL from the end-of-buffer pointer in DTW5
\CLC                    \
 SBC #LL                \ The CLC instruction is commented out in the original
 STA DTW5               \ source. It isn't needed as CHPR clears the C flag

 TAX                    \ Copy the new value of DTW5 into X

 BEQ DA6+3              \ If DTW5 = 0 then jump down to DA6+3 to print a newline
                        \ as the buffer is now empty

                        \ If we get here then we have printed our line but there
                        \ is more in the buffer, so we now want to remove the
                        \ line we just printed from the start of BUF

 LDY #0                 \ Set Y = 0 to count through the characters in BUF

 INX                    \ Increment X, so it now contains the number of
                        \ characters in the buffer (as DTW5 is a zero-based
                        \ pointer and is therefore equal to the number of
                        \ characters minus 1)

.DAL4

 LDA BUF+LL+1,Y         \ Copy the Y-th character from BUF+LL to BUF
 STA BUF,Y

 INY                    \ Increment the character pointer

 DEX                    \ Decrement the character count

 BNE DAL4               \ Loop back to copy the next character until we have
                        \ shuffled down the whole buffer

 BEQ DA5                \ Jump back to DA5 (this BEQ is effectively a JMP as we
                        \ have already passed through the BNE above)

.DAS1

                        \ This subroutine prints out X characters from BUF,
                        \ returning with X = 0

 LDY #0                 \ Set Y = 0 to point to the first character in BUF

.DAL5

 LDA BUF,Y              \ Print the Y-th character in BUF using CHPR, which also
 JSR CHPR               \ clears the C flag for when we return from the
                        \ subroutine below

 INY                    \ Increment Y to point to the next character

 DEX                    \ Decrement the loop counter

 BNE DAL5               \ Loop back for the next character until we have printed
                        \ X characters from BUF

.rT9

 RTS                    \ Return from the subroutine

.DA6

 JSR DAS1               \ Call DAS1 to print X characters from BUF, returning
                        \ with X = 0

 STX DTW5               \ Set the buffer size in DTW5 to 0, as the buffer is now
                        \ empty

 PLA                    \ Restore Y and X from the stack
 TAY
 PLA
 TAX

 LDA #12                \ Set A = 12, so when we skip BELL and fall through into
                        \ CHPR, we print character 12, which is a newline

.DA7

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &07, or BIT &07A9, which does nothing apart
                        \ from affect the flags

                        \ Fall through into CHPR (skipping BELL) to print the
                        \ character and return with the C flag cleared

\ ******************************************************************************
\
\       Name: BELL
\       Type: Subroutine
\   Category: Sound
\    Summary: Make a standard system beep
\
\ ------------------------------------------------------------------------------
\
\ This is the standard system beep as made by the VDU 7 statement in BBC BASIC.
\
\ ******************************************************************************

.BELL

 LDA #7                 \ Control code 7 makes a beep, so load this into A

                        \ Fall through into the TT26 print routine to
                        \ actually make the sound

\ ******************************************************************************
\
\       Name: CHPR
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor by poking into screen memory
\  Deep dive: Drawing text
\
\ ------------------------------------------------------------------------------
\
\ Print a character at the text cursor (XC, YC), do a beep, print a newline,
\ or delete left (backspace).
\
\ WRCHV is set to point here by the loading process.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\                         * 127 (delete the character to the left of the text
\                           cursor and move the cursor to the left)
\
\   XC                  Contains the text column to print at (the x-coordinate)
\
\   YC                  Contains the line number to print on (the y-coordinate)
\
\ Returns:
\
\   A                   A is preserved
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\   C flag              The C flag is cleared
\
\ Other entry points:
\
\   RR3+1               Contains an RTS
\
\   RREN                Prints the character definition pointed to by P(2 1) at
\                       the screen address pointed to by (A SC). Used by the
\                       BULB routine
\
\ ******************************************************************************

.CHPR

 STA K3                 \ Store the A, X and Y registers, so we can restore
 STY YSAV2              \ them at the end (so they don't get changed by this
 STX XSAV2              \ routine)

.RRNEW

 LDY QQ17               \ Load the QQ17 flag, which contains the text printing
                        \ flags

 INY                    \ If QQ17 = 255 then printing is disabled, so jump to
 BEQ RR4                \ RR4, which doesn't print anything, it just restores
                        \ the registers and returns from the subroutine

 TAY                    \ Set Y = the character to be printed

 BEQ RR4                \ If the character is zero, which is typically a string
                        \ terminator character, jump down to RR4 to restore the
                        \ registers and return from the subroutine

 BMI RR4                \ If A > 127 then there is nothing to print, so jump to
                        \ RR4 to restore the registers and return from the
                        \ subroutine

 CMP #7                 \ If this is a beep character (A = 7), jump to R5,
 BEQ R5                 \ which will emit the beep, restore the registers and
                        \ return from the subroutine

 CMP #32                \ If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                \ below, which will print the character, restore the
                        \ registers and return from the subroutine

 CMP #10                \ If this is control code 10 (line feed) then jump to
 BEQ RRX1               \ RRX1, which will move down a line, restore the
                        \ registers and return from the subroutine

 LDX #1                 \ If we get here, then this is control code 11-13, of
 STX XC                 \ which only 13 is used. This code prints a newline,
                        \ which we can achieve by moving the text cursor
                        \ to the start of the line (carriage return) and down
                        \ one line (line feed). These two lines do the first
                        \ bit by setting XC = 1, and we then fall through into
                        \ the line feed routine that's used by control code 10

 CMP #13                \ If this is control code 13 (carriage return) then jump
 BEQ RR4                \ RR4 to restore the registers and return from the
                        \ subroutine

.RRX1

 INC YC                 \ Print a line feed, simply by incrementing the row
                        \ number (y-coordinate) of the text cursor, which is
                        \ stored in YC

 BNE RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine (this BNE is effectively a JMP as Y
                        \ will never be zero)

.RR1

                        \ If we get here, then the character to print is an
                        \ ASCII character in the range 32-95. The quickest way
                        \ to display text on-screen is to poke the character
                        \ pixel by pixel, directly into screen memory, so
                        \ that's what the rest of this routine does
                        \
                        \ The first step, then, is to get hold of the bitmap
                        \ definition for the character we want to draw on the
                        \ screen (i.e. we need the pixel shape of this
                        \ character). The MOS ROM contains bitmap definitions
                        \ of the system's ASCII characters, starting from &C000
                        \ for space (ASCII 32) and ending with the £ symbol
                        \ (ASCII 126)
                        \
                        \ There are definitions for 32 characters in each of the
                        \ three pages of MOS memory, as each definition takes up
                        \ 8 bytes (8 rows of 8 pixels) and 32 * 8 = 256 bytes =
                        \ 1 page. So:
                        \
                        \   ASCII 32-63  are defined in &C000-&C0FF (page 0)
                        \   ASCII 64-95  are defined in &C100-&C1FF (page 1)
                        \   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
                        \
                        \ The following code reads the relevant character
                        \ bitmap from the above locations in ROM and pokes
                        \ those values into the correct position in screen
                        \ memory, thus printing the character on-screen
                        \
                        \ It's a long way from 10 PRINT "Hello world!":GOTO 10

                        \ Now we want to set X to point to the relevant page
                        \ number for this character - i.e. &C0, &C1 or &C2.

                        \ The following logic is easier to follow if we look
                        \ at the three character number ranges in binary:
                        \
                        \   Bit #  76543210
                        \
                        \   32  = %00100000     Page 0 of bitmap definitions
                        \   63  = %00111111
                        \
                        \   64  = %01000000     Page 1 of bitmap definitions
                        \   95  = %01011111
                        \
                        \   96  = %01100000     Page 2 of bitmap definitions
                        \   125 = %01111101
                        \
                        \ We'll refer to this below

 LDX #&BF               \ Set X to point to the first font page in ROM minus 1,
                        \ which is &C0 - 1, or &BF

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC P%+4

 LDX #&C1               \ A is 64-126, so set X to point to page &C1

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC P%+3               \ then skip the following instruction

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

 STA P+1                \ Store the address of this character's definition in
 STX P+2                \ P(2 1)

 LDA XC                 \ Fetch XC, the x-coordinate (column) of the text cursor
                        \ into A

 LDX CATF               \ If CATF = 0, jump to RR5, otherwise we are printing a
 BEQ RR5                \ disc catalogue

 CPY #' '               \ If the character we want to print in Y is a space,
 BNE RR5                \ jump to RR5

                        \ If we get here, then CATF is non-zero, so we are
                        \ printing a disc catalogue and we are not printing a
                        \ space, so we drop column 17 from the output so the
                        \ catalogue will fit on-screen (column 17 is a blank
                        \ column in the middle of the catalogue, between the
                        \ two lists of filenames, so it can be dropped without
                        \ affecting the layout). Without this, the catalogue
                        \ would be one character too wide for the square screen
                        \ mode (it's 34 characters wide, while the screen mode
                        \ is only 33 characters across)

 CMP #17                \ If A = 17, i.e. the text cursor is in column 17, jump
 BEQ RR4                \ to RR4 to restore the registers and return from the
                        \ subroutine, thus omitting this column

.RR5

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

 CPY #127               \ If the character number (which is in Y) <> 127, then
 BNE RR2                \ skip to RR2 to print that character, otherwise this is
                        \ the delete character, so continue on

 DEC XC                 \ We want to delete the character to the left of the
                        \ text cursor and move the cursor back one, so let's
                        \ do that by decrementing YC. Note that this doesn't
                        \ have anything to do with the actual deletion below,
                        \ we're just updating the cursor so it's in the right
                        \ position following the deletion

 ADC #&5E               \ A contains YC (from above) and the C flag is set (from
 TAX                    \ the CPY #127 above), so these instructions do this:
                        \
                        \   X = YC + &5E + 1
                        \     = YC + &5F

                        \ Because YC starts at 0 for the first text row, this
                        \ means that X will be &5F for row 0, &60 for row 1 and
                        \ so on. In other words, X is now set to the page number
                        \ for the row before the one containing the text cursor,
                        \ and given that we set SC above to point to the offset
                        \ in memory of the text cursor within the row's page,
                        \ this means that (X SC) now points to the character
                        \ above the text cursor

 LDY #&F8               \ Set Y = &F8, so the following call to ZES2 will count
                        \ Y upwards from &F8 to &FF

 JSR ZES2               \ Call ZES2, which zero-fills from address (X SC) + Y to
                        \ (X SC) + &FF. (X SC) points to the character above the
                        \ text cursor, and adding &FF to this would point to the
                        \ cursor, so adding &F8 points to the character before
                        \ the cursor, which is the one we want to delete. So
                        \ this call zero-fills the character to the left of the
                        \ cursor, which erases it from the screen

 BEQ RR4                \ We are done deleting, so restore the registers and
                        \ return from the subroutine (this BNE is effectively
                        \ a JMP as ZES2 always returns with the Z flag set)

.RR2

                        \ Now to actually print the character

 INC XC                 \ Once we print the character, we want to move the text
                        \ cursor to the right, so we do this by incrementing
                        \ XC. Note that this doesn't have anything to do
                        \ with the actual printing below, we're just updating
                        \ the cursor so it's in the right position following
                        \ the print

 CMP #24                \ If the text cursor is on the screen (i.e. YC < 24, so
 BCC RR3                \ we are on rows 1-23), then jump to RR3 to print the
                        \ character

 PHA                    \ Store A on the stack so we can retrieve it below

 JSR TTX66              \ Otherwise we are off the bottom of the screen, so
                        \ clear the screen and draw a white border

 PLA                    \ Retrieve A from the stack... only to overwrite it with
                        \ the next instruction, so presumably we didn't need to
                        \ preserve it and this and the PHA above have no effect

 LDA K3                 \ Set A to the character to be printed

 JMP RRNEW              \ Jump back to RRNEW to print the character

.RR3

                        \ A contains the value of YC - the screen row where we
                        \ want to print this character - so now we need to
                        \ convert this into a screen address, so we can poke
                        \ the character data to the right place in screen
                        \ memory

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

.RREN

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.RRL1

 LDA (P+1),Y            \ The character definition is at P(2 1) - we set this up
                        \ above - so load the Y-th byte from P(2 1), which will
                        \ contain the bitmap for the Y-th row of the character

 ORA (SC),Y             \ OR this value with the current contents of screen
                        \ memory, so the pixels we want to draw are set

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 LDY YSAV2              \ We're done printing, so restore the values of the
 LDX XSAV2              \ A, X and Y registers that we saved above and clear
 LDA K3                 \ the C flag, so everything is back to how it was
 CLC

 RTS                    \ Return from the subroutine

.R5

 JSR BEEP               \ Call the BEEP subroutine to make a short, high beep

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: HME2
\       Type: Subroutine
\   Category: Charts
\    Summary: Search the galaxy for a system
\
\ ******************************************************************************

.HME2

 LDA #14                \ Print extended token 14 ("{clear bottom of screen}
 JSR DETOK              \ PLANET NAME?{fetch line input from keyboard}"). The
                        \ last token calls MT26, which puts the entered search
                        \ term in INWK+5 and the term length in Y

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10),
                        \ which will erase the crosshairs currently there

 JSR TT81               \ Set the seeds in QQ15 (the selected system) to those
                        \ of system 0 in the current galaxy (i.e. copy the seeds
                        \ from QQ21 to QQ15)

 LDA #0                 \ We now loop through the galaxy's systems in order,
 STA XX20               \ until we find a match, so set XX20 to act as a system
                        \ counter, starting with system 0

.HME3

 JSR MT14               \ Switch to justified text when printing extended
                        \ tokens, so the call to cpl prints into the justified
                        \ text buffer at BUF instead of the screen, and DTW5
                        \ gets set to the length of the system name

 JSR cpl                \ Print the selected system name into the justified text
                        \ buffer

 LDX DTW5               \ Fetch DTW5 into X, so X is now equal to the length of
                        \ the selected system name

 LDA INWK+5,X           \ Fetch the X-th character from the entered search term

 CMP #13                \ If the X-th character is not a carriage return, then
 BNE HME6               \ the selected system name and the entered search term
                        \ are different lengths, so jump to HME6 to move on to
                        \ the next system

.HME4

 DEX                    \ Decrement X so it points to the last letter of the
                        \ selected system name (and, when we loop back here, it
                        \ points to the next letter to the left)

 LDA INWK+5,X           \ Set A to the X-th character of the entered search term

 ORA #%00100000         \ Set bit 5 of the character to make it lower case

 CMP BUF,X              \ If the character in A matches the X-th character of
 BEQ HME4               \ the selected system name in BUF, loop back to HME4 to
                        \ check the next letter to the left

 TXA                    \ The last comparison didn't match, so copy the letter
 BMI HME5               \ number into A, and if it's negative, that means we
                        \ managed to go past the first letters of each term
                        \ before we failed to get a match, so the terms are the
                        \ same, so jump to HME5 to process a successful search

.HME6

                        \ If we get here then the selected system name and the
                        \ entered search term did not match

 JSR TT20               \ We want to move on to the next system, so call TT20
                        \ to twist the three 16-bit seeds in QQ15

 INC XX20               \ Incrememt the system counter in XX20

 BNE HME3               \ If we haven't yet checked all 256 systems in the
                        \ current galaxy, loop back to HME3 to check the next
                        \ system

                        \ If we get here then the entered search term did not
                        \ match any systems in the current galaxy

 JSR TT111              \ Select the system closest to galactic coordinates
                        \ (QQ9, QQ10), so we can put the crosshairs back where
                        \ they were before the search

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10)

 LDA #40                \ Call the NOISE routine with A = 40 to make a low,
 JSR NOISE              \ long beep to indicate a failed search

 LDA #215               \ Print extended token 215 ("{left align} UNKNOWN
 JMP DETOK              \ PLANET"), which will print on-screem as the left align
                        \ code disables justified text, and return from the
                        \ subroutine using a tail call

.HME5

                        \ If we get here then we have found a match for the
                        \ entered search

 LDA QQ15+3             \ The x-coordinate of the system described by the seeds
 STA QQ9                \ in QQ15 is in QQ15+3 (s1_hi), so we copy this to QQ9
                        \ as the x-coordinate of the search result

 LDA QQ15+1             \ The y-coordinate of the system described by the seeds
 STA QQ10               \ in QQ15 is in QQ15+1 (s0_hi), so we copy this to QQ10
                        \ as the y-coordinate of the search result

 JSR TT111              \ Select the system closest to galactic coordinates
                        \ (QQ9, QQ10)

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10)

 JSR MT15               \ Switch to left-aligned text when printing extended
                        \ tokens so future tokens will print to the screen (as
                        \ this disables justified text)

 JMP T95                \ Jump to T95 to print the distance to the selected
                        \ system and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: SQUA
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Clear bit 7 of A and calculate (A P) = A * A
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of unsigned 8-bit numbers, after first
\ clearing bit 7 of A:
\
\   (A P) = A * A
\
\ ******************************************************************************

.SQUA

 AND #%01111111         \ Clear bit 7 of A and fall through into SQUA2 to set
                        \ (A P) = A * A

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
\ ******************************************************************************

.SQUA2

 STA P                  \ Copy A into P and X
 TAX

 BNE MU11               \ If X = 0 fall through into MU1 to return a 0,
                        \ otherwise jump to MU11 to return P * X

\ ******************************************************************************
\
\       Name: MU1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Copy X into P and A, and clear the C flag
\
\ ------------------------------------------------------------------------------
\
\ Used to return a 0 result quickly from MULTU below.
\
\ ******************************************************************************

.MU1

 CLC                    \ Clear the C flag

 STX P                  \ Copy X into P and A
 TXA

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MULTU
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = P * Q
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of unsigned 8-bit numbers:
\
\   (A P) = P * Q
\
\ ******************************************************************************

.MULTU

 LDX Q                  \ Set X = Q

 BEQ MU1                \ If X = Q = 0, jump to MU1 to copy X into P and A,
                        \ clear the C flag and return from the subroutine using
                        \ a tail call

                        \ Otherwise fall through into MU11 to set (A P) = P * X

\ ******************************************************************************
\
\       Name: MU11
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = P * X
\  Deep dive: Shift-and-add multiplication
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of two unsigned 8-bit numbers:
\
\   (A P) = P * X
\
\ This uses the same shift-and-add approach as MULT1, but it's simpler as we
\ are dealing with unsigned numbers in P and X. See the deep dive on
\ "Shift-and-add multiplication" for a discussion of how this algorithm works.
\
\ ******************************************************************************

.MU11

 DEX                    \ Set T = X - 1
 STX T                  \
                        \ We subtract 1 as the C flag will be set when we want
                        \ to do an addition in the loop below

 LDA #0                 \ Set A = 0 so we can start building the answer in A

 LDX #8                 \ Set up a counter in X to count the 8 bits in P

 LSR P                  \ Set P = P >> 1
                        \ and C flag = bit 0 of P

                        \ We are now going to work our way through the bits of
                        \ P, and do a shift-add for any bits that are set,
                        \ keeping the running total in A. We just did the first
                        \ shift right, so we now need to do the first add and
                        \ loop through the other bits in P

.MUL6

 BCC P%+4               \ If C (i.e. the next bit from P) is set, do the
 ADC T                  \ addition for this bit of P:
                        \
                        \   A = A + T + C
                        \     = A + X - 1 + 1
                        \     = A + X

 ROR A                  \ Shift A right to catch the next digit of our result,
                        \ which the next ROR sticks into the left end of P while
                        \ also extracting the next bit of P

 ROR P                  \ Add the overspill from shifting A to the right onto
                        \ the start of P, and shift P right to fetch the next
                        \ bit for the calculation into the C flag

 DEX                    \ Decrement the loop counter

 BNE MUL6               \ Loop back for the next bit until P has been rotated
                        \ all the way

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: FMLTU2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate A = K * sin(A)
\  Deep dive: The sine, cosine and arctan tables
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following:
\
\   A = K * sin(A)
\
\ Because this routine uses the sine lookup table SNE, we can also call this
\ routine to calculate cosine multiplication. To calculate the following:
\
\   A = K * cos(B)
\
\ call this routine with B + 16 in the accumulator, as sin(B + 16) = cos(B).
\
\ ******************************************************************************

.FMLTU2

 AND #%00011111         \ Restrict A to bits 0-5 (so it's in the range 0-31)

 TAX                    \ Set Q = sin(A) * 256
 LDA SNE,X
 STA Q

 LDA K                  \ Set A to the radius in K

                        \ Fall through into FMLTU to do the following:
                        \
                        \   (A ?) = A * Q
                        \         = K * sin(A) * 256
                        \
                        \ which is equivalent to:
                        \
                        \   A = K * sin(A)

\ ******************************************************************************
\
\       Name: FMLTU
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate A = A * Q / 256
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of two unsigned 8-bit numbers, returning only
\ the high byte of the result:
\
\   (A ?) = A * Q
\
\ or, to put it another way:
\
\   A = A * Q / 256
\
\ ******************************************************************************

.FMLTU

 EOR #%11111111         \ Flip the bits in A, set the C flag and rotate right,
 SEC                    \ so the C flag now contains bit 0 of A inverted, and P
 ROR A                  \ contains A inverted and shifted right by one, with bit
 STA P                  \ 7 set to a 1. We can now use P as our source of bits
                        \ to shift right, just as in MU11, just with the logic
                        \ reversed

 LDA #0                 \ Set A = 0 so we can start building the answer in A

.MUL3

 BCS MU7                \ If C (i.e. the next bit from P) is set, do not do the
                        \ addition for this bit of P, and instead skip to MU7
                        \ to just do the shifts

 ADC Q                  \ Do the addition for this bit of P:
                        \
                        \   A = A + Q + C
                        \     = A + Q

 ROR A                  \ Shift A right to catch the next digit of our result.
                        \ If we were interested in the low byte of the result we
                        \ would want to save the bit that falls off the end, but
                        \ we aren't, so we can ignore it

 LSR P                  \ Shift P right to fetch the next bit for the
                        \ calculation into the C flag

 BNE MUL3               \ Loop back to MUL3 if P still contains some set bits
                        \ (so we loop through the bits of P until we get to the
                        \ 1 we inserted before the loop, and then we stop)

 RTS                    \ Return from the subroutine

.MU7

 LSR A                  \ Shift A right to catch the next digit of our result,
                        \ pushing a 0 into bit 7 as we aren't adding anything
                        \ here (we can't use a ROR here as the C flag is set, so
                        \ a ROR would push a 1 into bit 7)

 LSR P                  \ Fetch the next bit from P into the C flag

 BNE MUL3               \ Loop back to MUL3 if P still contains some set bits
                        \ (so we loop through the bits of P until we get to the
                        \ 1 we inserted before the loop, and then we stop)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MULT1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = Q * A
\  Deep dive: Shift-and-add multiplication
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of two 8-bit sign-magnitude numbers:
\
\   (A P) = Q * A
\
\ ******************************************************************************

.MULT1

 TAX                    \ Store A in X

 AND #%01111111         \ Set P = |A| >> 1
 LSR A                  \ and C flag = bit 0 of A
 STA P

 TXA                    \ Restore argument A

 EOR Q                  \ Set bit 7 of A and T if Q and A have different signs,
 AND #%10000000         \ clear bit 7 if they have the same signs, 0 all other
 STA T                  \ bits, i.e. T contains the sign bit of Q * A

 LDA Q                  \ Set A = |Q|
 AND #%01111111

 BEQ mu10               \ If |Q| = 0 jump to mu10 (with A set to 0)

 TAX                    \ Set T1 = |Q| - 1
 DEX                    \
 STX T1                 \ We subtract 1 as the C flag will be set when we want
                        \ to do an addition in the loop below

                        \ We are now going to work our way through the bits of
                        \ P, and do a shift-add for any bits that are set,
                        \ keeping the running total in A. We already set up
                        \ the first shift at the start of this routine, as
                        \ P = |A| >> 1 and C = bit 0 of A, so we now need to set
                        \ up a loop to sift through the other 7 bits in P

 LDA #0                 \ Set A = 0 so we can start building the answer in A

 LDX #7                 \ Set up a counter in X to count the 7 bits remaining
                        \ in P

.MUL4

 BCC P%+4               \ If C (i.e. the next bit from P) is set, do the
 ADC T1                 \ addition for this bit of P:
                        \
                        \   A = A + T1 + C
                        \     = A + |Q| - 1 + 1
                        \     = A + |Q|

 ROR A                  \ As mentioned above, this ROR shifts A right and
                        \ catches bit 0 in C - giving another digit for our
                        \ result - and the next ROR sticks that bit into the
                        \ left end of P while also extracting the next bit of P
                        \ for the next addition

 ROR P                  \ Add the overspill from shifting A to the right onto
                        \ the start of P, and shift P right to fetch the next
                        \ bit for the calculation

 DEX                    \ Decrement the loop counter

 BNE MUL4               \ Loop back for the next bit until P has been rotated
                        \ all the way

 LSR A                  \ Rotate (A P) once more to get the final result, as
 ROR P                  \ we only pushed 7 bits through the above process

 ORA T                  \ Set the sign bit of the result that we stored in T

 RTS                    \ Return from the subroutine

.mu10

 STA P                  \ If we get here, the result is 0 and A = 0, so set
                        \ P = 0 so (A P) = 0

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MULT12
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (S R) = Q * A
\
\ ------------------------------------------------------------------------------
\
\ Calculate:
\
\   (S R) = Q * A
\
\ ******************************************************************************

.MULT12

 JSR MULT1              \ Set (A P) = Q * A

 STA S                  \ Set (S R) = (A P)
 LDA P
 STA R

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MAD
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A X) = Q * A + (S R)
\
\ ------------------------------------------------------------------------------
\
\ Calculate
\
\   (A X) = Q * A + (S R)
\
\ ******************************************************************************

.MAD

 JSR MULT1              \ Call MULT1 to set (A P) = Q * A

                        \ Fall through into ADD to do:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = Q * A + (S R)

\ ******************************************************************************
\
\       Name: ADD
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A X) = (A P) + (S R)
\  Deep dive: Adding sign-magnitude numbers
\
\ ------------------------------------------------------------------------------
\
\ Add two 16-bit sign-magnitude numbers together, calculating:
\
\   (A X) = (A P) + (S R)
\
\ ******************************************************************************

.ADD

 STA T1                 \ Store argument A in T1

 AND #%10000000         \ Extract the sign (bit 7) of A and store it in T
 STA T

 EOR S                  \ EOR bit 7 of A with S. If they have different bit 7s
 BMI MU8                \ (i.e. they have different signs) then bit 7 in the
                        \ EOR result will be 1, which means the EOR result is
                        \ negative. So the AND, EOR and BMI together mean "jump
                        \ to MU8 if A and S have different signs"

                        \ If we reach here, then A and S have the same sign, so
                        \ we can add them and set the sign to get the result

 LDA R                  \ Add the least significant bytes together into X:
 CLC                    \
 ADC P                  \   X = P + R
 TAX

 LDA S                  \ Add the most significant bytes together into A. We
 ADC T1                 \ stored the original argument A in T1 earlier, so we
                        \ can do this with:
                        \
                        \   A = A  + S + C
                        \     = T1 + S + C

 ORA T                  \ If argument A was negative (and therefore S was also
                        \ negative) then make sure result A is negative by
                        \ OR-ing the result with the sign bit from argument A
                        \ (which we stored in T)

 RTS                    \ Return from the subroutine

.MU8

                        \ If we reach here, then A and S have different signs,
                        \ so we can subtract their absolute values and set the
                        \ sign to get the result

 LDA S                  \ Clear the sign (bit 7) in S and store the result in
 AND #%01111111         \ U, so U now contains |S|
 STA U

 LDA P                  \ Subtract the least significant bytes into X:
 SEC                    \
 SBC R                  \   X = P - R
 TAX

 LDA T1                 \ Restore the A of the argument (A P) from T1 and
 AND #%01111111         \ clear the sign (bit 7), so A now contains |A|

 SBC U                  \ Set A = |A| - |S|

                        \ At this point we have |A P| - |S R| in (A X), so we
                        \ need to check whether the subtraction above was the
                        \ the right way round (i.e. that we subtracted the
                        \ smaller absolute value from the larger absolute
                        \ value)

 BCS MU9                \ If |A| >= |S|, our subtraction was the right way
                        \ round, so jump to MU9 to set the sign

                        \ If we get here, then |A| < |S|, so our subtraction
                        \ above was the wrong way round (we actually subtracted
                        \ the larger absolute value from the smaller absolute
                        \ value). So let's subtract the result we have in (A X)
                        \ from zero, so that the subtraction is the right way
                        \ round

 STA U                  \ Store A in U

 TXA                    \ Set X = 0 - X using two's complement (to negate a
 EOR #&FF               \ number in two's complement, you can invert the bits
 ADC #1                 \ and add one - and we know the C flag is clear as we
 TAX                    \ didn't take the BCS branch above, so the ADC will do
                        \ the correct addition)

 LDA #0                 \ Set A = 0 - A, which we can do this time using a
 SBC U                  \ a subtraction with the C flag clear

 ORA #%10000000         \ We now set the sign bit of A, so that the EOR on the
                        \ next line will give the result the opposite sign to
                        \ argument A (as T contains the sign bit of argument
                        \ A). This is the same as giving the result the same
                        \ sign as argument S (as A and S have different signs),
                        \ which is what we want, as S has the larger absolute
                        \ value

.MU9

 EOR T                  \ If we get here from the BCS above, then |A| >= |S|,
                        \ so we want to give the result the same sign as
                        \ argument A, so if argument A was negative, we flip
                        \ the sign of the result with an EOR (to make it
                        \ negative)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TIS1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A ?) = (-X * A + (S R)) / 96
\  Deep dive: Shift-and-subtract division
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following expression between sign-magnitude numbers, ignoring
\ the low byte of the result:
\
\   (A ?) = (-X * A + (S R)) / 96
\
\ This uses the same shift-and-subtract algorithm as TIS2, just with the
\ quotient A hard-coded to 96.
\
\ Returns:
\
\   Q                   Gets set to the value of argument X
\
\ ******************************************************************************

.TIS1

 STX Q                  \ Set Q = X

 EOR #%10000000         \ Flip the sign bit in A

 JSR MAD                \ Set (A X) = Q * A + (S R)
                        \           = X * -A + (S R)

.DVID96

 TAX                    \ Set T to the sign bit of the result
 AND #%10000000
 STA T

 TXA                    \ Set A to the high byte of the result with the sign bit
 AND #%01111111         \ cleared, so (A ?) = |X * A + (S R)|

                        \ The following is identical to TIS2, except Q is
                        \ hard-coded to 96, so this does A = A / 96

 LDX #254               \ Set T1 to have bits 1-7 set, so we can rotate through
 STX T1                 \ 7 loop iterations, getting a 1 each time, and then
                        \ getting a 0 on the 8th iteration... and we can also
                        \ use T1 to catch our result bits into bit 0 each time

.DVL3

 ASL A                  \ Shift A to the left

 CMP #96                \ If A < 96 skip the following subtraction
 BCC DV4

 SBC #96                \ Set A = A - 96
                        \
                        \ Going into this subtraction we know the C flag is
                        \ set as we passed through the BCC above, and we also
                        \ know that A >= 96, so the C flag will still be set
                        \ once we are done

.DV4

 ROL T1                 \ Rotate the counter in T1 to the left, and catch the
                        \ result bit into bit 0 (which will be a 0 if we didn't
                        \ do the subtraction, or 1 if we did)

 BCS DVL3               \ If we still have set bits in T1, loop back to DVL3 to
                        \ do the next iteration of 7

 LDA T1                 \ Fetch the result from T1 into A

 ORA T                  \ Give A the sign of the result that we stored above

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: PDESC
\       Type: Subroutine
\   Category: Text
\    Summary: Print the system's extended description or a mission 1 directive
\  Deep dive: Extended system descriptions
\             Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This prints a specific system's extended description. This is called the "pink
\ volcanoes string" in a comment in the original source, and the "goat soup"
\ recipe by Ian Bell on his website (where he also refers to the species string
\ as the "pink felines" string).
\
\ For some special systems, when you are docked at them, the procedurally
\ generated extended description is overridden and a text token from the RUTOK
\ table is shown instead. If mission 1 is in progress, then a number of systems
\ along the route of that mission's story will show custom mission-related
\ directives in place of that system's normal "goat soup" phrase.
\
\ Arguments:
\
\   ZZ                  The system number (0-255)
\
\ Other entry points:
\
\   PD1                 Print the standard "goat soup" description without
\                       checking for overrides
\
\ ******************************************************************************

.PDESC

.PD1

                        \ We now print the "goat soup" extended description

 LDX #3                 \ We now want to seed the random number generator with
                        \ the s1 and s2 16-bit seeds from the current system, so
                        \ we get the same extended description for each system
                        \ every time we call PDESC, so set a counter in X for
                        \ copying 4 bytes

{
.PDL1                   \ This label is a duplicate of the label above (which is
                        \ why we need to surround it with braces, as BeebAsm
                        \ doesn't allow us to redefine labels, unlike BBC BASIC)

 LDA QQ15+2,X           \ Copy QQ15+2 to QQ15+5 (s1 and s2) to RAND to RAND+3
 STA RAND,X

 DEX                    \ Decrement the loop counter

 BPL PDL1               \ Loop back to PDL1 until we have copied all

 LDA #5                 \ Set A = 5, so we print extended token 5 in the next
                        \ instruction ("{lower case}{justify}{single cap}[86-90]
                        \ IS [140-144].{cr}{left align}"
}

.PD4

 JMP DETOK              \ Print the extended token given in A, and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: MT23
\       Type: Subroutine
\   Category: Text
\    Summary: Move to row 10, switch to white text, and switch to lower case
\             when printing extended tokens
\  Deep dive: Extended text tokens
\
\ ******************************************************************************

.MT23

 LDA #10                \ Set A = 10, so when we fall through into MT29, the
                        \ text cursor gets moved to row 10

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &06, or BIT &06A9, which does nothing apart
                        \ from affect the flags

                        \ Fall through into MT29 to move to the row in A, switch
                        \ to white text, and switch to lower case

\ ******************************************************************************
\
\       Name: MT29
\       Type: Subroutine
\   Category: Text
\    Summary: Move to row 6, switch to white text, and switch to lower case when
\             printing extended tokens
\  Deep dive: Extended text tokens
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the following:
\
\   * YC = 6 (move to row 6)
\
\ Then it calls WHITETEXT to switch to white text, before jumping to MT13 to
\ switch to lower case when printing extended tokens.
\
\ ******************************************************************************

.MT29

 LDA #6                 \ Move the text cursor to row 6
 STA YC

 JMP MT13               \ Jump to MT13 to set bit 7 of DTW6 and bit 5 of DTW1,
                        \ returning from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: PAUSE2
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Wait until a key is pressed, ignoring any existing key press
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   X                   The internal key number of the key that was pressed
\
\ ******************************************************************************

.PAUSE2

 JSR RDKEY              \ Scan the keyboard for a key press and return the
                        \ internal key number in X (or 0 for no key press)

 BNE PAUSE2             \ If a key was already being held down when we entered
                        \ this routine, keep looping back up to PAUSE2, until
                        \ the key is released

.l_out

 JSR RDKEY              \ Any pre-existing key press is now gone, so we can
                        \ start scanning the keyboard again, returning the
                        \ internal key number in X (or 0 for no key press)

 BEQ l_out              \ AJD

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TT66
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear the screen and set the current view type
\
\ ------------------------------------------------------------------------------
\
\ Clear the top part of the screen, draw a white border, and set the current
\ view type in QQ11 to A.
\
\ Arguments:
\
\   A                   The type of the new current view (see QQ11 for a list of
\                       view types)
\
\ ******************************************************************************

.TT66

 STA QQ11               \ Set the current view type in QQ11 to A

                        \ Fall through into TTX66 to clear the screen and draw a
                        \ white border

\ ******************************************************************************
\
\       Name: TTX66
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear the top part of the screen and draw a white border
\
\ ------------------------------------------------------------------------------
\
\ Clear the top part of the screen (the space view) and draw a white border
\ along the top and sides.
\
\ Other entry points:
\
\   BOL1-1              Contains an RTS
\
\ ******************************************************************************

.TTX66

 JSR MT2                \ Switch to Sentence Case when printing extended tokens

 LDA #%10000000         \ Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

 STA DTW2               \ Set bit 7 of DTW2 to indicate we are not currently
                        \ printing a word

 ASL A                  \ Set LASCT to 0, as 128 << 1 = %10000000 << 1 = 0. This
 STA LASCT              \ stops any laser pulsing

 STA DLY                \ Set the delay in DLY to 0, to indicate that we are
                        \ no longer showing an in-flight message, so any new
                        \ in-flight messages will be shown instantly

 STA de                 \ Clear de, the flag that appends " DESTROYED" to the
                        \ end of the next text token, so that it doesn't

 LDX #&60               \ Set X to the screen memory page for the top row of the
                        \ screen (as screen memory starts at &6000)

.BOL1

 JSR ZES1               \ Call ZES1  to zero-fill the page in X, which clears
                        \ that character row on the screen

 INX                    \ Increment X to point to the next page, i.e. the next
                        \ character row

 CPX #&78               \ Loop back to BOL1 until we have cleared page &7700,
 BNE BOL1               \ the last character row in the space view part of the
                        \ screen (the space view)

 LDY #1                 \ Move the text cursor to row 1
 STY YC

 LDA QQ11               \ If this is not a space view, jump to tt66 to skip
 BNE tt66               \ displaying the view name

 LDY #11                \ Move the text cursor to row 11
 STY XC

 LDA VIEW               \ Load the current view into A:
                        \
                        \   0 = front
                        \   1 = rear
                        \   2 = left
                        \   3 = right

 ORA #&60               \ OR with &60 so we get a value of &60 to &63 (96 to 99)

 JSR TT27               \ Print recursive token 96 to 99, which will be in the
                        \ range "FRONT" to "RIGHT"

 JSR TT162              \ Print a space

 LDA #175               \ Print recursive token 15 ("VIEW ")
 JSR TT27

.tt66

 LDX #0                 \ Set (X1, Y1) to (0, 0)
 STX X1
 STX Y1

 STX QQ17               \ Set QQ17 = 0 to switch to ALL CAPS

 DEX                    \ Set X2 = 255
 STX X2

 JSR HLOIN              \ Draw a horizontal line from (X1, Y1) to (X2, Y1), so
                        \ that's (0, 0) to (255, 0), along the very top of the
                        \ screen

 LDA #2                 \ Set X1 = X2 = 2
 STA X1
 STA X2

 JSR BOS2               \ Call BOS2 below, which will call BOS1 twice, and then
                        \ fall through into BOS2 again, so we effectively do
                        \ BOS1 four times, decrementing X1 and X2 each time
                        \ before calling LOIN, so this whole loop-within-a-loop
                        \ mind-bender ends up drawing these four lines:
                        \
                        \   (1, 0)   to (1, 191)
                        \   (0, 0)   to (0, 191)
                        \   (255, 0) to (255, 191)
                        \   (254, 0) to (254, 191)
                        \
                        \ So that's a 2-pixel wide vertical border along the
                        \ left edge of the upper part of the screen, and a
                        \ 2-pixel wide vertical border along the right edge

.BOS2

 JSR BOS1               \ Call BOS1 below and then fall through into it, which
                        \ ends up running BOS1 twice. This is all part of the
                        \ loop-the-loop border-drawing mind-bender explained
                        \ above

.BOS1

 LDA #0                 \ Set Y1 = 0
 STA Y1

 LDA #2*Y-1             \ Set Y2 = 2 * #Y - 1. The constant #Y is 96, the
 STA Y2                 \ y-coordinate of the mid-point of the space view, so
                        \ this sets Y2 to 191, the y-coordinate of the bottom
                        \ pixel row of the space view

 DEC X1                 \ Decrement X1 and X2
 DEC X2

 JMP LOIN               \ Draw a line from (X1, Y1) to (X2, Y2), and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DELAY
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Wait for a specified time, in 1/50s of a second
\
\ ------------------------------------------------------------------------------
\
\ Wait for the number of vertical syncs given in Y, so this effectively waits
\ for Y/50 of a second (as the vertical sync occurs 50 times a second).
\
\ Arguments:
\
\   Y                   The number of vertical sync events to wait for
\
\ ******************************************************************************

.DELAY

 JSR WSCAN              \ Call WSCAN to wait for the vertical sync, so the whole
                        \ screen gets drawn

 DEY                    \ Decrement the counter in Y

 BNE DELAY              \ If Y isn't yet at zero, jump back to DELAY to wait
                        \ for another vertical sync

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

 LDA #%11111111         \ Set DTW2 = %11111111 to denote that we are not
 STA DTW2               \ currently printing a word

 LDA #20                \ Move the text cursor to row 20, near the bottom of
 STA YC                 \ the screen

 JSR TT67               \ Print a newline, which will move the text cursor down
                        \ a line (to row 21) and back to column 1

 LDA #&75               \ Set the two-byte value in SC to &7507
 STA SC+1
 LDA #7
 STA SC

 LDA #0                 \ Call LYN to clear the pixels from &7507 to &75F0
 JSR LYN

 INC SC+1               \ Increment SC+1 so SC points to &7607

 JSR LYN                \ Call LYN to clear the pixels from &7607 to &76F0

 INC SC+1               \ Increment SC+1 so SC points to &7707

 INY                    \ Move the text cursor to column 1 (as LYN sets Y to 0)
 STY XC

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
\       Name: TT20
\       Type: Subroutine
\   Category: Universe
\    Summary: Twist the selected system's seeds four times
\  Deep dive: Twisting the system seeds
\             Galaxy and system seeds
\
\ ------------------------------------------------------------------------------
\
\ Twist the three 16-bit seeds in QQ15 (selected system) four times, to
\ generate the next system.
\
\ ******************************************************************************

.TT20

 JSR P%+3               \ This line calls the line below as a subroutine, which
                        \ does two twists before returning here, and then we
                        \ fall through to the line below for another two
                        \ twists, so the net effect of these two consecutive
                        \ JSR calls is four twists, not counting the ones
                        \ inside your head as you try to follow this process

 JSR P%+3               \ This line calls TT54 as a subroutine to do a twist,
                        \ and then falls through into TT54 to do another twist
                        \ before returning from the subroutine

\ ******************************************************************************
\
\       Name: TT54
\       Type: Subroutine
\   Category: Universe
\    Summary: Twist the selected system's seeds
\  Deep dive: Twisting the system seeds
\             Galaxy and system seeds
\
\ ------------------------------------------------------------------------------
\
\ This routine twists the three 16-bit seeds in QQ15 once.
\
\ ******************************************************************************

.TT54

 LDA QQ15               \ X = tmp_lo = s0_lo + s1_lo
 CLC
 ADC QQ15+2
 TAX

 LDA QQ15+1             \ Y = tmp_hi = s1_hi + s1_hi + C
 ADC QQ15+3
 TAY

 LDA QQ15+2             \ s0_lo = s1_lo
 STA QQ15

 LDA QQ15+3             \ s0_hi = s1_hi
 STA QQ15+1

 LDA QQ15+5             \ s1_hi = s2_hi
 STA QQ15+3

 LDA QQ15+4             \ s1_lo = s2_lo
 STA QQ15+2

 CLC                    \ s2_lo = X + s1_lo
 TXA
 ADC QQ15+2
 STA QQ15+4

 TYA                    \ s2_hi = Y + s1_hi + C
 ADC QQ15+3
 STA QQ15+5

 RTS                    \ The twist is complete so return from the subroutine

\ ******************************************************************************
\
\       Name: TT146
\       Type: Subroutine
\   Category: Text
\    Summary: Print the distance to the selected system in light years
\
\ ------------------------------------------------------------------------------
\
\ If it is non-zero, print the distance to the selected system in light years.
\ If it is zero, just move the text cursor down a line.
\
\ Specifically, if the distance in QQ8 is non-zero, print token 31 ("DISTANCE"),
\ then a colon, then the distance to one decimal place, then token 35 ("LIGHT
\ YEARS"). If the distance is zero, move the cursor down one line.
\
\ ******************************************************************************

.TT146

 LDA QQ8                \ Take the two bytes of the 16-bit value in QQ8 and
 ORA QQ8+1              \ OR them together to check whether there are any
 BNE TT63               \ non-zero bits, and if so, jump to TT63 to print the
                        \ distance

 INC YC                 \ The distance is zero, so we just move the text cursor
 RTS                    \ in YC down by one line and return from the subroutine

.TT63

 LDA #191               \ Print recursive token 31 ("DISTANCE") followed by
 JSR TT68               \ a colon

 LDX QQ8                \ Load (Y X) from QQ8, which contains the 16-bit
 LDY QQ8+1              \ distance we want to show

 SEC                    \ Set the C flag so that the call to pr5 will include a
                        \ decimal point, and display the value as (Y X) / 10

 JSR pr5                \ Print (Y X) to 5 digits, including a decimal point

 LDA #195               \ Set A to the recursive token 35 (" LIGHT YEARS") and
                        \ fall through into TT60 to print the token followed
                        \ by a paragraph break

\ ******************************************************************************
\
\       Name: TT60
\       Type: Subroutine
\   Category: Text
\    Summary: Print a text token and a paragraph break
\
\ ------------------------------------------------------------------------------
\
\ Print a text token (i.e. a character, control code, two-letter token or
\ recursive token). Then print a paragraph break (a blank line between
\ paragraphs) by moving the cursor down a line, setting Sentence Case, and then
\ printing a newline.
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.TT60

 JSR TT27               \ Print the text token in A and fall through into TTX69
                        \ to print the paragraph break

\ ******************************************************************************
\
\       Name: TTX69
\       Type: Subroutine
\   Category: Text
\    Summary: Print a paragraph break
\
\ ------------------------------------------------------------------------------
\
\ Print a paragraph break (a blank line between paragraphs) by moving the cursor
\ down a line, and then printing a newline.
\
\ ******************************************************************************

.TTX69

 INC YC                 \ Move the text cursor down a line

                        \ Fall through into TT67 to print a newline

\ ******************************************************************************
\
\       Name: TT67
\       Type: Subroutine
\   Category: Text
\    Summary: Print a newline
\
\ ******************************************************************************

.TT67

 LDA #12                \ Load a newline character into A

 JMP TT27               \ Print the text token in A and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: TT70
\       Type: Subroutine
\   Category: Text
\    Summary: Display "MAINLY " and jump to TT72
\
\ ------------------------------------------------------------------------------
\
\ This subroutine is called by TT25 when displaying a system's economy.
\
\ ******************************************************************************

.TT70

 LDA #173               \ Print recursive token 13 ("MAINLY ")
 JSR TT27

 JMP TT72               \ Jump to TT72 to continue printing system data as part
                        \ of routine TT25

\ ******************************************************************************
\
\       Name: spc
\       Type: Subroutine
\   Category: Text
\    Summary: Print a text token followed by a space
\
\ ------------------------------------------------------------------------------
\
\ Print a text token (i.e. a character, control code, two-letter token or
\ recursive token) followed by a space.
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.spc

 JSR TT27               \ Print the text token in A

 JMP TT162              \ Print a space and return from the subroutine using a
                        \ tail call

\ ******************************************************************************
\
\       Name: TT25
\       Type: Subroutine
\   Category: Universe
\    Summary: Show the Data on System screen (red key f6)
\  Deep dive: Generating system data
\             Galaxy and system seeds
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   TT72                Used by TT70 to re-enter the routine after displaying
\                       "MAINLY" for the economy type
\
\ ******************************************************************************

.TT25

 LDA #1                 \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 1

 LDA #9                 \ Move the text cursor to column 9
 STA XC

 LDA #163               \ Print recursive token 3 ("DATA ON {selected system
 JSR NLIN3              \ name}" and draw a horizontal line at pixel row 19
                        \ to box in the title

 JSR TTX69              \ Print a paragraph break and set Sentence Case

 JSR TT146              \ If the distance to this system is non-zero, print
                        \ "DISTANCE", then the distance, "LIGHT YEARS" and a
                        \ paragraph break, otherwise just move the cursor down
                        \ a line

 LDA #194               \ Print recursive token 34 ("ECONOMY") followed by
 JSR TT68               \ a colon

 LDA QQ3                \ The system economy is determined by the value in QQ3,
                        \ so fetch it into A. First we work out the system's
                        \ prosperity as follows:
                        \
                        \   QQ3 = 0 or 5 = %000 or %101 = Rich
                        \   QQ3 = 1 or 6 = %001 or %110 = Average
                        \   QQ3 = 2 or 7 = %010 or %111 = Poor
                        \   QQ3 = 3 or 4 = %011 or %100 = Mainly

 CLC                    \ If (QQ3 + 1) >> 1 = %10, i.e. if QQ3 = %011 or %100
 ADC #1                 \ (3 or 4), then call TT70, which prints "MAINLY " and
 LSR A                  \ jumps down to TT72 to print the type of economy
 CMP #%00000010
 BEQ TT70

 LDA QQ3                \ The LSR A above shifted bit 0 of QQ3 into the C flag,
 BCC TT71               \ so this jumps to TT71 if bit 0 of QQ3 is 0, in other
                        \ words if QQ3 = %000, %001 or %010 (0, 1 or 2)

 SBC #5                 \ Here QQ3 = %101, %110 or %111 (5, 6 or 7), so subtract
 CLC                    \ 5 to bring it down to 0, 1 or 2 (the C flag is already
                        \ set so the SBC will be correct)

.TT71

 ADC #170               \ A is now 0, 1 or 2, so print recursive token 10 + A.
 JSR TT27               \ This means that:
                        \
                        \   QQ3 = 0 or 5 prints token 10 ("RICH ")
                        \   QQ3 = 1 or 6 prints token 11 ("AVERAGE ")
                        \   QQ3 = 2 or 7 prints token 12 ("POOR ")

.TT72

 LDA QQ3                \ Now to work out the type of economy, which is
 LSR A                  \ determined by bit 2 of QQ3, as follows:
 LSR A                  \
                        \   QQ3 bit 2 = 0 = Industrial
                        \   QQ3 bit 2 = 1 = Agricultural
                        \
                        \ So we fetch QQ3 into A and set A = bit 2 of QQ3 using
                        \ two right shifts (which will work as QQ3 is only a
                        \ 3-bit number)

 CLC                    \ Print recursive token 8 + A, followed by a paragraph
 ADC #168               \ break and Sentence Case, so:
 JSR TT60               \
                        \   QQ3 bit 2 = 0 prints token 8 ("INDUSTRIAL")
                        \   QQ3 bit 2 = 1 prints token 9 ("AGRICULTURAL")

 LDA #162               \ Print recursive token 2 ("GOVERNMENT") followed by
 JSR TT68               \ a colon

 LDA QQ4                \ The system economy is determined by the value in QQ4,
                        \ so fetch it into A

 CLC                    \ Print recursive token 17 + A, followed by a paragraph
 ADC #177               \ break and Sentence Case, so:
 JSR TT60               \
                        \   QQ4 = 0 prints token 17 ("ANARCHY")
                        \   QQ4 = 1 prints token 18 ("FEUDAL")
                        \   QQ4 = 2 prints token 19 ("MULTI-GOVERNMENT")
                        \   QQ4 = 3 prints token 20 ("DICTATORSHIP")
                        \   QQ4 = 4 prints token 21 ("COMMUNIST")
                        \   QQ4 = 5 prints token 22 ("CONFEDERACY")
                        \   QQ4 = 6 prints token 23 ("DEMOCRACY")
                        \   QQ4 = 7 prints token 24 ("CORPORATE STATE")

 LDA #196               \ Print recursive token 36 ("TECH.LEVEL") followed by a
 JSR TT68               \ colon

 LDX QQ5                \ Fetch the tech level from QQ5 and increment it, as it
 INX                    \ is stored in the range 0-14 but the displayed range
                        \ should be 1-15

 CLC                    \ Call pr2 to print the technology level as a 3-digit
 JSR pr2                \ number without a decimal point (by clearing the C
                        \ flag)

 JSR TTX69              \ Print a paragraph break and set Sentence Case

 LDA #192               \ Print recursive token 32 ("POPULATION") followed by a
 JSR TT68               \ colon

 SEC                    \ Call pr2 to print the population as a 3-digit number
 LDX QQ6                \ with a decimal point (by setting the C flag), so the
 JSR pr2                \ number printed will be population / 10

 LDA #198               \ Print recursive token 38 (" BILLION"), followed by a
 JSR TT60               \ paragraph break and Sentence Case

 LDA #'('               \ Print an opening bracket
 JSR TT27

 LDA QQ15+4             \ Now to calculate the species, so first check bit 7 of
 BMI TT75               \ s2_lo, and if it is set, jump to TT75 as this is an
                        \ alien species

 LDA #188               \ Bit 7 of s2_lo is clear, so print recursive token 28
 JSR TT27               \ ("HUMAN COLONIAL")

 JMP TT76               \ Jump to TT76 to print "S)" and a paragraph break, so
                        \ the whole species string is "(HUMAN COLONIALS)"

.TT75

 LDA QQ15+5             \ This is an alien species, and we start with the first
 LSR A                  \ adjective, so fetch bits 2-7 of s2_hi into A and push
 LSR A                  \ onto the stack so we can use this later
 PHA

 AND #%00000111         \ Set A = bits 0-2 of A (so that's bits 2-4 of s2_hi)

 CMP #3                 \ If A >= 3, jump to TT205 to skip the first adjective,
 BCS TT205

 ADC #227               \ Otherwise A = 0, 1 or 2, so print recursive token
 JSR spc                \ 67 + A, followed by a space, so:
                        \
                        \   A = 0 prints token 67 ("LARGE") and a space
                        \   A = 1 prints token 67 ("FIERCE") and a space
                        \   A = 2 prints token 67 ("SMALL") and a space

.TT205

 PLA                    \ Now for the second adjective, so restore A to bits
 LSR A                  \ 2-7 of s2_hi, and throw away bits 2-4 to leave
 LSR A                  \ A = bits 5-7 of s2_hi
 LSR A

 CMP #6                 \ If A >= 6, jump to TT206 to skip the second adjective
 BCS TT206

 ADC #230               \ Otherwise A = 0 to 5, so print recursive token
 JSR spc                \ 70 + A, followed by a space, so:
                        \
                        \   A = 0 prints token 70 ("GREEN") and a space
                        \   A = 1 prints token 71 ("RED") and a space
                        \   A = 2 prints token 72 ("YELLOW") and a space
                        \   A = 3 prints token 73 ("BLUE") and a space
                        \   A = 4 prints token 74 ("BLACK") and a space
                        \   A = 5 prints token 75 ("HARMLESS") and a space

.TT206

 LDA QQ15+3             \ Now for the third adjective, so EOR the high bytes of
 EOR QQ15+1             \ s0 and s1 and extract bits 0-2 of the result:
 AND #%00000111         \
 STA QQ19               \   A = (s0_hi EOR s1_hi) AND %111
                        \
                        \ storing the result in QQ19 so we can use it later

 CMP #6                 \ If A >= 6, jump to TT207 to skip the third adjective
 BCS TT207

 ADC #236               \ Otherwise A = 0 to 5, so print recursive token
 JSR spc                \ 76 + A, followed by a space, so:
                        \
                        \   A = 0 prints token 76 ("SLIMY") and a space
                        \   A = 1 prints token 77 ("BUG-EYED") and a space
                        \   A = 2 prints token 78 ("HORNED") and a space
                        \   A = 3 prints token 79 ("BONY") and a space
                        \   A = 4 prints token 80 ("FAT") and a space
                        \   A = 5 prints token 81 ("FURRY") and a space

.TT207

 LDA QQ15+5             \ Now for the actual species, so take bits 0-1 of
 AND #%00000011         \ s2_hi, add this to the value of A that we used for
 CLC                    \ the third adjective, and take bits 0-2 of the result
 ADC QQ19
 AND #%00000111

 ADC #242               \ A = 0 to 7, so print recursive token 82 + A, so:
 JSR TT27               \
                        \   A = 0 prints token 76 ("RODENT")
                        \   A = 1 prints token 76 ("FROG")
                        \   A = 2 prints token 76 ("LIZARD")
                        \   A = 3 prints token 76 ("LOBSTER")
                        \   A = 4 prints token 76 ("BIRD")
                        \   A = 5 prints token 76 ("HUMANOID")
                        \   A = 6 prints token 76 ("FELINE")
                        \   A = 7 prints token 76 ("INSECT")

.TT76

 LDA #'S'               \ Print an "S" to pluralise the species
 JSR TT27

 LDA #')'               \ And finally, print a closing bracket, followed by a
 JSR TT60               \ paragraph break and Sentence Case, to end the species
                        \ section

 LDA #193               \ Print recursive token 33 ("GROSS PRODUCTIVITY"),
 JSR TT68               \ followed by colon

 LDX QQ7                \ Fetch the 16-bit productivity value from QQ7 into
 LDY QQ7+1              \ (Y X)

 JSR pr6                \ Print (Y X) to 5 digits with no decimal point

 JSR TT162              \ Print a space

 LDA #0                 \ Set QQ17 = 0 to switch to ALL CAPS
 STA QQ17

 LDA #'M'               \ Print "M"
 JSR TT27

 LDA #226               \ Print recursive token 66 (" CR"), followed by a
 JSR TT60               \ paragraph break and Sentence Case

 LDA #250               \ Print recursive token 90 ("AVERAGE RADIUS"), followed
 JSR TT68               \ by a colon

                        \ The average radius is calculated like this:
                        \
                        \   ((s2_hi AND %1111) + 11) * 256 + s1_hi
                        \
                        \ or, in terms of memory locations:
                        \
                        \   ((QQ15+5 AND %1111) + 11) * 256 + QQ15+3
                        \
                        \ Because the multiplication is by 256, this is the
                        \ same as saying a 16-bit number, with high byte:
                        \
                        \   (QQ15+5 AND %1111) + 11
                        \
                        \ and low byte:
                        \
                        \   QQ15+3
                        \
                        \ so we can set this up in (Y X) and call the pr5
                        \ routine to print it out

 LDA QQ15+5             \ Set A = QQ15+5
 LDX QQ15+3             \ Set X = QQ15+3

 AND #%00001111         \ Set Y = (A AND %1111) + 11
 CLC
 ADC #11
 TAY

 JSR pr5                \ Print (Y X) to 5 digits, not including a decimal
                        \ point, as the C flag will be clear (as the maximum
                        \ radius will always fit into 16 bits)

 JSR TT162              \ Print a space

 LDA #'k'               \ Print "km"
 JSR TT26
 LDA #'m'
 JSR TT26

 JSR TTX69              \ Print a paragraph break and set Sentence Case

                        \ By this point, ZZ contains the current system number
                        \ which PDESC requires. It gets put there in the TT102
                        \ routine, which calls TT111 to populate ZZ before
                        \ calling TT25 (this routine)

 JMP PD1                \ AJD

\ ******************************************************************************
\
\       Name: TT24
\       Type: Subroutine
\   Category: Universe
\    Summary: Calculate system data from the system seeds
\  Deep dive: Generating system data
\             Galaxy and system seeds
\
\ ------------------------------------------------------------------------------
\
\ Calculate system data from the seeds in QQ15 and store them in the relevant
\ locations. Specifically, this routine calculates the following from the three
\ 16-bit seeds in QQ15 (using only s0_hi, s1_hi and s1_lo):
\
\   QQ3 = economy (0-7)
\   QQ4 = government (0-7)
\   QQ5 = technology level (0-14)
\   QQ6 = population * 10 (1-71)
\   QQ7 = productivity (96-62480)
\
\ The ranges of the various values are shown in brackets. Note that the radius
\ and type of inhabitant are calculated on-the-fly in the TT25 routine when
\ the system data gets displayed, so they aren't calculated here.
\
\ ******************************************************************************

.TT24

 LDA QQ15+1             \ Fetch s0_hi and extract bits 0-2 to determine the
 AND #%00000111         \ system's economy, and store in QQ3
 STA QQ3

 LDA QQ15+2             \ Fetch s1_lo and extract bits 3-5 to determine the
 LSR A                  \ system's government, and store in QQ4
 LSR A
 LSR A
 AND #%00000111
 STA QQ4

 LSR A                  \ If government isn't anarchy or feudal, skip to TT77,
 BNE TT77               \ as we need to fix the economy of anarchy and feudal
                        \ systems so they can't be rich

 LDA QQ3                \ Set bit 1 of the economy in QQ3 to fix the economy
 ORA #%00000010         \ for anarchy and feudal governments
 STA QQ3

.TT77

 LDA QQ3                \ Now to work out the tech level, which we do like this:
 EOR #%00000111         \
 CLC                    \   flipped_economy + (s1_hi AND %11) + (government / 2)
 STA QQ5                \
                        \ or, in terms of memory locations:
                        \
                        \   QQ5 = (QQ3 EOR %111) + (QQ15+3 AND %11) + (QQ4 / 2)
                        \
                        \ We start by setting QQ5 = QQ3 EOR %111

 LDA QQ15+3             \ We then take the first 2 bits of s1_hi (QQ15+3) and
 AND #%00000011         \ add it into QQ5
 ADC QQ5
 STA QQ5

 LDA QQ4                \ And finally we add QQ4 / 2 and store the result in
 LSR A                  \ QQ5, using LSR then ADC to divide by 2, which rounds
 ADC QQ5                \ up the result for odd-numbered government types
 STA QQ5

 ASL A                  \ Now to work out the population, like so:
 ASL A                  \
 ADC QQ3                \   (tech level * 4) + economy + government + 1
 ADC QQ4                \
 ADC #1                 \ or, in terms of memory locations:
 STA QQ6                \
                        \   QQ6 = (QQ5 * 4) + QQ3 + QQ4 + 1

 LDA QQ3                \ Finally, we work out productivity, like this:
 EOR #%00000111         \
 ADC #3                 \  (flipped_economy + 3) * (government + 4)
 STA P                  \                        * population
 LDA QQ4                \                        * 8
 ADC #4                 \
 STA Q                  \ or, in terms of memory locations:
 JSR MULTU              \
                        \   QQ7 = (QQ3 EOR %111 + 3) * (QQ4 + 4) * QQ6 * 8
                        \
                        \ We do the first step by setting P to the first
                        \ expression in brackets and Q to the second, and
                        \ calling MULTU, so now (A P) = P * Q. The highest this
                        \ can be is 10 * 11 (as the maximum values of economy
                        \ and government are 7), so the high byte of the result
                        \ will always be 0, so we actually have:
                        \
                        \   P = P * Q
                        \     = (flipped_economy + 3) * (government + 4)

 LDA QQ6                \ We now take the result in P and multiply by the
 STA Q                  \ population to get the productivity, by setting Q to
 JSR MULTU              \ the population from QQ6 and calling MULTU again, so
                        \ now we have:
                        \
                        \   (A P) = P * population

 ASL P                  \ Next we multiply the result by 8, as a 16-bit number,
 ROL A                  \ so we shift both bytes to the left three times, using
 ASL P                  \ the C flag to carry bits from bit 7 of the low byte
 ROL A                  \ into bit 0 of the high byte
 ASL P
 ROL A

 STA QQ7+1              \ Finally, we store the productivity in two bytes, with
 LDA P                  \ the low byte in QQ7 and the high byte in QQ7+1
 STA QQ7

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TT22
\       Type: Subroutine
\   Category: Charts
\    Summary: Show the Long-range Chart (red key f4)
\
\ ******************************************************************************

.TT22

 LDA #64                \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 32 (Long-
                        \ range Chart)

 LDA #7                 \ Move the text cursor to column 7
 STA XC

 JSR TT81               \ Set the seeds in QQ15 to those of system 0 in the
                        \ current galaxy (i.e. copy the seeds from QQ21 to QQ15)

 LDA #199               \ Print recursive token 39 ("GALACTIC CHART{galaxy
 JSR TT27               \ number right-aligned to width 3}")

 JSR NLIN               \ Draw a horizontal line at pixel row 23 to box in the
                        \ title and act as the top frame of the chart, and move
                        \ the text cursor down one line

 LDA #152               \ Draw a screen-wide horizontal line at pixel row 152
 JSR NLIN2              \ for the bottom edge of the chart, so the chart itself
                        \ is 128 pixels high, starting on row 24 and ending on
                        \ row 151

 JSR TT14               \ Call TT14 to draw a circle with crosshairs at the
                        \ current system's galactic coordinates

 LDX #0                 \ We're now going to plot each of the galaxy's systems,
                        \ so set up a counter in X for each system, starting at
                        \ 0 and looping through to 255

.TT83

 STX XSAV               \ Store the counter in XSAV

 LDX QQ15+3             \ Fetch the s1_hi seed into X, which gives us the
                        \ galactic x-coordinate of this system

 LDY QQ15+4             \ Fetch the s2_lo seed and set bits 4 and 6, storing the
 TYA                    \ result in ZZ to give a random number between 80 and
 ORA #%01010000         \ (but which will always be the same for this system).
 STA ZZ                 \ We use this value to determine the size of the point
                        \ for this system on the chart by passing it as the
                        \ distance argument to the PIXEL routine below

 LDA QQ15+1             \ Fetch the s0_hi seed into A, which gives us the
                        \ galactic y-coordinate of this system

 LSR A                  \ We halve the y-coordinate because the galaxy in
                        \ in Elite is rectangular rather than square, and is
                        \ twice as wide (x-axis) as it is high (y-axis), so the
                        \ chart is 256 pixels wide and 128 high

 CLC                    \ Add 24 to the halved y-coordinate and store in XX15+1
 ADC #24                \ (as the top of the chart is on pixel row 24, just
 STA XX15+1             \ below the line we drew on row 23 above)

 JSR PIXEL              \ Call PIXEL to draw a point at (X, A), with the size of
                        \ the point dependent on the distance specified in ZZ
                        \ (so a high value of ZZ will produce a 1-pixel point,
                        \ a medium value will produce a 2-pixel dash, and a
                        \ small value will produce a 4-pixel square)

 JSR TT20               \ We want to move on to the next system, so call TT20
                        \ to twist the three 16-bit seeds in QQ15

 LDX XSAV               \ Restore the loop counter from XSAV

 INX                    \ Increment the counter

 BNE TT83               \ If X > 0 then we haven't done all 256 systems yet, so
                        \ loop back up to TT83

 LDA QQ9                \ Set QQ19 to the selected system's x-coordinate
 STA QQ19

 LDA QQ10               \ Set QQ19+1 to the selected system's y-coordinate,
 LSR A                  \ halved to fit it into the chart
 STA QQ19+1

 LDA #4                 \ Set QQ19+2 to size 4 for the crosshairs size
 STA QQ19+2

                        \ Fall through into TT15 to draw crosshairs of size 4 at
                        \ the selected system's coordinates

\ ******************************************************************************
\
\       Name: TT15
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a set of crosshairs
\
\ ------------------------------------------------------------------------------
\
\ For all views except the Short-range Chart, the centre is drawn 24 pixels to
\ the right of the y-coordinate given.
\
\ Arguments:
\
\   QQ19                The pixel x-coordinate of the centre of the crosshairs
\
\   QQ19+1              The pixel y-coordinate of the centre of the crosshairs
\
\   QQ19+2              The size of the crosshairs
\
\ ******************************************************************************

.TT15

 LDA #24                \ Set A to 24, which we will use as the minimum
                        \ screen indent for the crosshairs (i.e. the minimum
                        \ distance from the top-left corner of the screen)

 LDX QQ11               \ If the current view is not the Short-range Chart,
 BPL P%+4               \ which is the only view with bit 7 set, then skip the
                        \ following instruction

 LDA #0                 \ This is the Short-range Chart, so set A to 0, so the
                        \ crosshairs can go right up against the screen edges

 STA QQ19+5             \ Set QQ19+5 to A, which now contains the correct indent
                        \ for this view

 LDA QQ19               \ Set A = crosshairs x-coordinate - crosshairs size
 SEC                    \ to get the x-coordinate of the left edge of the
 SBC QQ19+2             \ crosshairs

 BCS TT84               \ If the above subtraction didn't underflow, then A is
                        \ positive, so skip the next instruction

 LDA #0                 \ The subtraction underflowed, so set A to 0 so the
                        \ crosshairs don't spill out of the left of the screen

.TT84

                        \ In the following, the authors have used XX15 for
                        \ temporary storage. XX15 shares location with X1, Y1,
                        \ X2 and Y2, so in the following, you can consider
                        \ the variables like this:
                        \
                        \   XX15   is the same as X1
                        \   XX15+1 is the same as Y1
                        \   XX15+2 is the same as X2
                        \   XX15+3 is the same as Y2
                        \
                        \ Presumably this routine was written at a different
                        \ time to the line-drawing routine, before the two
                        \ workspaces were merged to save space

 STA XX15               \ Set XX15 (X1) = A (the x-coordinate of the left edge
                        \ of the crosshairs)

 LDA QQ19               \ Set A = crosshairs x-coordinate + crosshairs size
 CLC                    \ to get the x-coordinate of the right edge of the
 ADC QQ19+2             \ crosshairs

 BCC P%+4               \ If the above addition didn't overflow, then A is
                        \ correct, so skip the next instruction

 LDA #255               \ The addition overflowed, so set A to 255 so the
                        \ crosshairs don't spill out of the right of the screen
                        \ (as 255 is the x-coordinate of the rightmost pixel
                        \ on-screen)

 STA XX15+2             \ Set XX15+2 (X2) = A (the x-coordinate of the right
                        \ edge of the crosshairs)

 LDA QQ19+1             \ Set XX15+1 (Y1) = crosshairs y-coordinate + indent
 CLC                    \ to get the y-coordinate of the centre of the
 ADC QQ19+5             \ crosshairs
 STA XX15+1

 JSR HLOIN              \ Draw a horizontal line from (X1, Y1) to (X2, Y1),
                        \ which will draw from the left edge of the crosshairs
                        \ to the right edge, through the centre of the
                        \ crosshairs

 LDA QQ19+1             \ Set A = crosshairs y-coordinate - crosshairs size
 SEC                    \ to get the y-coordinate of the top edge of the
 SBC QQ19+2             \ crosshairs

 BCS TT86               \ If the above subtraction didn't underflow, then A is
                        \ correct, so skip the next instruction

 LDA #0                 \ The subtraction underflowed, so set A to 0 so the
                        \ crosshairs don't spill out of the top of the screen

.TT86

 CLC                    \ Set XX15+1 (Y1) = A + indent to get the y-coordinate
 ADC QQ19+5             \ of the top edge of the indented crosshairs
 STA XX15+1

 LDA QQ19+1             \ Set A = crosshairs y-coordinate + crosshairs size
 CLC                    \ + indent to get the y-coordinate of the bottom edge
 ADC QQ19+2             \ of the indented crosshairs
 ADC QQ19+5

 CMP #152               \ If A < 152 then skip the following, as the crosshairs
 BCC TT87               \ won't spill out of the bottom of the screen

 LDX QQ11               \ A >= 152, so we need to check whether this will fit in
                        \ this view, so fetch the view number

 BMI TT87               \ If this is the Short-range Chart then the y-coordinate
                        \ is fine, so skip to TT87

 LDA #151               \ Otherwise this is the Long-range Chart, so we need to
                        \ clip the crosshairs at a maximum y-coordinate of 151

.TT87

 STA XX15+3             \ Set XX15+3 (Y2) = A (the y-coordinate of the bottom
                        \ edge of the crosshairs)

 LDA QQ19               \ Set XX15 (X1) = the x-coordinate of the centre of the
 STA XX15               \ crosshairs

 STA XX15+2             \ Set XX15+2 (X2) = the x-coordinate of the centre of
                        \ the crosshairs

 JMP LL30               \ Draw a vertical line (X1, Y1) to (X2, Y2), which will
                        \ draw from the top edge of the crosshairs to the bottom
                        \ edge, through the centre of the crosshairs, returning
                        \ from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: TT14
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw a circle with crosshairs on a chart
\
\ ------------------------------------------------------------------------------
\
\ Draw a circle with crosshairs at the current system's galactic coordinates.
\
\ ******************************************************************************

.TT126

 LDA #104               \ Set QQ19 = 104, for the x-coordinate of the centre of
 STA QQ19               \ the fixed circle on the Short-range Chart

 LDA #90                \ Set QQ19+1 = 90, for the y-coordinate of the centre of
 STA QQ19+1             \ the fixed circle on the Short-range Chart

 LDA #16                \ Set QQ19+2 = 16, the size of the crosshairs on the
 STA QQ19+2             \ Short-range Chart

 JSR TT15               \ Draw the set of crosshairs defined in QQ19, at the
                        \ exact coordinates as this is the Short-range Chart

 LDA QQ14               \ Set K to the fuel level from QQ14, so this can act as
 STA K                  \ the circle's radius (70 being a full tank)

 JMP TT128              \ Jump to TT128 to draw a circle with the centre at the
                        \ same coordinates as the crosshairs, (QQ19, QQ19+1),
                        \ and radius K that reflects the current fuel levels,
                        \ returning from the subroutine using a tail call

.TT14

 LDA QQ11               \ If the current view is the Short-range Chart, which
 BMI TT126              \ is the only view with bit 7 set, then jump up to TT126
                        \ to draw the crosshairs and circle for that view

                        \ Otherwise this is the Long-range Chart, so we draw the
                        \ crosshairs and circle for that view instead

 LDA QQ14               \ Set K to the fuel level from QQ14 divided by 4, so
 LSR A                  \ this can act as the circle's radius (70 being a full
 LSR A                  \ tank, which divides down to a radius of 17)
 STA K

 LDA QQ0                \ Set QQ19 to the x-coordinate of the current system,
 STA QQ19               \ which will be the centre of the circle and crosshairs
                        \ we draw

 LDA QQ1                \ Set QQ19+1 to the y-coordinate of the current system,
 LSR A                  \ halved because the galactic chart is half as high as
 STA QQ19+1             \ it is wide, which will again be the centre of the
                        \ circle and crosshairs we draw

 LDA #7                 \ Set QQ19+2 = 7, the size of the crosshairs on the
 STA QQ19+2             \ Long-range Chart

 JSR TT15               \ Draw the set of crosshairs defined in QQ19, which will
                        \ be drawn 24 pixels to the right of QQ19+1

 LDA QQ19+1             \ Add 24 to the y-coordinate of the crosshairs in QQ19+1
 CLC                    \ so that the centre of the circle matches the centre
 ADC #24                \ of the crosshairs
 STA QQ19+1

                        \ Fall through into TT128 to draw a circle with the
                        \ centre at the same coordinates as the crosshairs,
                        \ (QQ19, QQ19+1), and radius K that reflects the
                        \ current fuel levels

\ ******************************************************************************
\
\       Name: TT128
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw a circle on a chart
\  Deep dive: Drawing circles
\
\ ------------------------------------------------------------------------------
\
\ Draw a circle with the centre at (QQ19, QQ19+1) and radius K.
\
\ Arguments:
\
\   QQ19                The x-coordinate of the centre of the circle
\
\   QQ19+1              The y-coordinate of the centre of the circle
\
\   K                   The radius of the circle
\
\ ******************************************************************************

.TT128

 LDA QQ19               \ Set K3 = the x-coordinate of the centre
 STA K3

 LDA QQ19+1             \ Set K4 = the y-coordinate of the centre
 STA K4

 LDX #0                 \ Set the high bytes of K3(1 0) and K4(1 0) to 0
 STX K4+1
 STX K3+1

 INX                    \ Set LSP = 1 to reset the ball line heap
 STX LSP

 LDX #2                 \ Set STP = 2, the step size for the circle
 STX STP

 JMP CIRCLE2            \ Jump to CIRCLE2 to draw a circle with the centre at
                        \ (K3(1 0), K4(1 0)) and radius K, returning from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: TT16
\       Type: Subroutine
\   Category: Charts
\    Summary: Move the crosshairs on a chart
\
\ ------------------------------------------------------------------------------
\
\ Move the chart crosshairs by the amount in X and Y.
\
\ Arguments:
\
\   X                   The amount to move the crosshairs in the x-axis
\
\   Y                   The amount to move the crosshairs in the y-axis
\
\ ******************************************************************************

.TT16

 TXA                    \ Push the change in X onto the stack (let's call this
 PHA                    \ the x-delta)

 DEY                    \ Negate the change in Y and push it onto the stack
 TYA                    \ (let's call this the y-delta)
 EOR #&FF
 PHA

 JSR WSCAN              \ Call WSCAN to wait for the vertical sync, so the whole
                        \ screen gets drawn and we can move the crosshairs with
                        \ no screen flicker

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10),
                        \ which will erase the crosshairs currently there

 PLA                    \ Store the y-delta in QQ19+3 and fetch the current
 STA QQ19+3             \ y-coordinate of the crosshairs from QQ10 into A, ready
 LDA QQ10               \ for the call to TT123

 JSR TT123              \ Call TT123 to move the selected system's galactic
                        \ y-coordinate by the y-delta, putting the new value in
                        \ QQ19+4

 LDA QQ19+4             \ Store the updated y-coordinate in QQ10 (the current
 STA QQ10               \ y-coordinate of the crosshairs)

 STA QQ19+1             \ This instruction has no effect, as QQ19+1 is
                        \ overwritten below, both in TT103 and TT105

 PLA                    \ Store the x-delta in QQ19+3 and fetch the current
 STA QQ19+3             \ x-coordinate of the crosshairs from QQ10 into A, ready
 LDA QQ9                \ for the call to TT123

 JSR TT123              \ Call TT123 to move the selected system's galactic
                        \ x-coordinate by the x-delta, putting the new value in
                        \ QQ19+4

 LDA QQ19+4             \ Store the updated x-coordinate in QQ9 (the current
 STA QQ9                \ x-coordinate of the crosshairs)

 STA QQ19               \ This instruction has no effect, as QQ19 is overwritten
                        \ below, both in TT103 and TT105

                        \ Now we've updated the coordinates of the crosshairs,
                        \ fall through into TT103 to redraw them at their new
                        \ location

\ ******************************************************************************
\
\       Name: TT103
\       Type: Subroutine
\   Category: Charts
\    Summary: Draw a small set of crosshairs on a chart
\
\ ------------------------------------------------------------------------------
\
\ Draw a small set of crosshairs on a galactic chart at the coordinates in
\ (QQ9, QQ10).
\
\ ******************************************************************************

.TT103

 LDA QQ11               \ Fetch the current view type into A

 BMI TT105              \ If this is the Short-range Chart screen, jump to TT105

 LDA QQ9                \ Store the crosshairs x-coordinate in QQ19
 STA QQ19

 LDA QQ10               \ Halve the crosshairs y-coordinate and store it in QQ19
 LSR A                  \ (we halve it because the Long-range Chart is half as
 STA QQ19+1             \ high as it is wide)

 LDA #4                 \ Set QQ19+2 to 4 denote crosshairs of size 4
 STA QQ19+2

 JMP TT15               \ Jump to TT15 to draw crosshairs of size 4 at the
                        \ crosshairs coordinates, returning from the subroutine
                        \ using a tail call

\ ******************************************************************************
\
\       Name: TT123
\       Type: Subroutine
\   Category: Charts
\    Summary: Move galactic coordinates by a signed delta
\
\ ------------------------------------------------------------------------------
\
\ Move an 8-bit galactic coordinate by a certain distance in either direction
\ (i.e. a signed 8-bit delta), but only if it doesn't cause the coordinate to
\ overflow. The coordinate is in a single axis, so it's either an x-coordinate
\ or a y-coordinate.
\
\ Arguments:
\
\   A                   The galactic coordinate to update
\
\   QQ19+3              The delta (can be positive or negative)
\
\ Returns:
\
\   QQ19+4              The updated coordinate after moving by the delta (this
\                       will be the same as A if moving by the delta overflows)
\
\ Other entry points:
\
\   TT180               Contains an RTS
\
\ ******************************************************************************

.TT123

 STA QQ19+4             \ Store the original coordinate in temporary storage at
                        \ QQ19+4

 CLC                    \ Set A = A + QQ19+3, so A now contains the original
 ADC QQ19+3             \ coordinate, moved by the delta

 LDX QQ19+3             \ If the delta is negative, jump to TT124
 BMI TT124

 BCC TT125              \ If the C flag is clear, then the above addition didn't
                        \ overflow, so jump to TT125 to return the updated value

 RTS                    \ Otherwise the C flag is set and the above addition
                        \ overflowed, so do not update the return value

.TT124

 BCC TT180              \ If the C flag is clear, then because the delta is
                        \ negative, this indicates the addition (which is
                        \ effectively a subtraction) underflowed, so jump to
                        \ TT180 to return from the subroutine without updating
                        \ the return value

.TT125

 STA QQ19+4             \ Store the updated coordinate in QQ19+4

.TT180

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TT105
\       Type: Subroutine
\   Category: Charts
\    Summary: Draw crosshairs on the Short-range Chart, with clipping
\
\ ------------------------------------------------------------------------------
\
\ Check whether the crosshairs are close enough to the current system to appear
\ on the Short-range Chart, and if so, draw them.
\
\ ******************************************************************************

.TT105

 LDA QQ9                \ Set A = QQ9 - QQ0, the horizontal distance between the
 SEC                    \ crosshairs (QQ9) and the current system (QQ0)
 SBC QQ0

 CMP #38                \ If the horizontal distance in A < 38, then the
 BCC TT179              \ crosshairs are close enough to the current system to
                        \ appear in the Short-range Chart, so jump to TT179 to
                        \ check the vertical distance

 CMP #230               \ If the horizontal distance in A < -26, then the
 BCC TT180              \ crosshairs are too far from the current system to
                        \ appear in the Short-range Chart, so jump to TT180 to
                        \ return from the subroutine (as TT180 contains an RTS)

.TT179

 ASL A                  \ Set QQ19 = 104 + A * 4
 ASL A                  \
 CLC                    \ 104 is the x-coordinate of the centre of the chart,
 ADC #104               \ so this sets QQ19 to the screen pixel x-coordinate
 STA QQ19               \ of the crosshairs

 LDA QQ10               \ Set A = QQ10 - QQ1, the vertical distance between the
 SEC                    \ crosshairs (QQ10) and the current system (QQ1)
 SBC QQ1

 CMP #38                \ If the vertical distance in A is < 38, then the
 BCC P%+6               \ crosshairs are close enough to the current system to
                        \ appear in the Short-range Chart, so skip the next two
                        \ instructions

 CMP #220               \ If the horizontal distance in A is < -36, then the
 BCC TT180              \ crosshairs are too far from the current system to
                        \ appear in the Short-range Chart, so jump to TT180 to
                        \ return from the subroutine (as TT180 contains an RTS)

 ASL A                  \ Set QQ19+1 = 90 + A * 2
 CLC                    \
 ADC #90                \ 90 is the y-coordinate of the centre of the chart,
 STA QQ19+1             \ so this sets QQ19+1 to the screen pixel x-coordinate
                        \ of the crosshairs

 LDA #8                 \ Set QQ19+2 to 8 denote crosshairs of size 8
 STA QQ19+2

 JMP TT15               \ Jump to TT15 to draw crosshairs of size 8 at the
                        \ crosshairs coordinates, returning from the subroutine
                        \ using a tail call

\ ******************************************************************************
\
\       Name: TT23
\       Type: Subroutine
\   Category: Charts
\    Summary: Show the Short-range Chart (red key f5)
\
\ ******************************************************************************

.TT23

 LDA #128               \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 128 (Short-
                        \ range Chart)

 LDA #7                 \ Move the text cursor to column 7
 STA XC

 LDA #190               \ Print recursive token 30 ("SHORT RANGE CHART") and
 JSR NLIN3              \ draw a horizontal line at pixel row 19 to box in the
                        \ title

 JSR TT14               \ Call TT14 to draw a circle with crosshairs at the
                        \ current system's galactic coordinates

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10),
                        \ i.e. at the selected system

 JSR TT81               \ Set the seeds in QQ15 to those of system 0 in the
                        \ current galaxy (i.e. copy the seeds from QQ21 to QQ15)

 LDA #0                 \ Set A = 0, which we'll use below to zero out the INWK
                        \ workspace

 STA XX20               \ We're about to start working our way through each of
                        \ the galaxy's systems, so set up a counter in XX20 for
                        \ each system, starting at 0 and looping through to 255

 LDX #24                \ First, though, we need to zero out the 25 bytes at
                        \ INWK so we can use them to work out which systems have
                        \ room for a label, so set a counter in X for 25 bytes

.EE3

 STA INWK,X             \ Set the X-th byte of INWK to zero

 DEX                    \ Decrement the counter

 BPL EE3                \ Loop back to EE3 for the next byte until we've zeroed
                        \ all 25 bytes

                        \ We now loop through every single system in the galaxy
                        \ and check the distance from the current system whose
                        \ coordinates are in (QQ0, QQ1). We get the galactic
                        \ coordinates of each system from the system's seeds,
                        \ like this:
                        \
                        \   x = s1_hi (which is stored in QQ15+3)
                        \   y = s0_hi (which is stored in QQ15+1)
                        \
                        \ so the following loops through each system in the
                        \ galaxy in turn and calculates the distance between
                        \ (QQ0, QQ1) and (s1_hi, s0_hi) to find the closest one

.TT182

 LDA QQ15+3             \ Set A = s1_hi - QQ0, the horizontal distance between
 SEC                    \ (s1_hi, s0_hi) and (QQ0, QQ1)
 SBC QQ0

 BCS TT184              \ If a borrow didn't occur, i.e. s1_hi >= QQ0, then the
                        \ result is positive, so jump to TT184 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |s1_hi - QQ0|)

.TT184

 CMP #20                \ If the horizontal distance in A is >= 20, then this
 BCS TT187              \ system is too far away from the current system to
                        \ appear in the Short-range Chart, so jump to TT187 to
                        \ move on to the next system

 LDA QQ15+1             \ Set A = s0_hi - QQ1, the vertical distance between
 SEC                    \ (s1_hi, s0_hi) and (QQ0, QQ1)
 SBC QQ1

 BCS TT186              \ If a borrow didn't occur, i.e. s0_hi >= QQ1, then the
                        \ result is positive, so jump to TT186 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |s0_hi - QQ1|)

.TT186

 CMP #38                \ If the vertical distance in A is >= 38, then this
 BCS TT187              \ system is too far away from the current system to
                        \ appear in the Short-range Chart, so jump to TT187 to
                        \ move on to the next system

                        \ This system should be shown on the Short-range Chart,
                        \ so now we need to work out where the label should go,
                        \ and set up the various variables we need to draw the
                        \ system's filled circle on the chart

 LDA QQ15+3             \ Set A = s1_hi - QQ0, the horizontal distance between
 SEC                    \ this system and the current system, where |A| < 20.
 SBC QQ0                \ Let's call this the x-delta, as it's the horizontal
                        \ difference between the current system at the centre of
                        \ the chart, and this system (and this time we keep the
                        \ sign of A, so it can be negative if it's to the left
                        \ of the chart's centre, or positive if it's to the
                        \ right)

 ASL A                  \ Set XX12 = 104 + x-delta * 4
 ASL A                  \
 ADC #104               \ 104 is the x-coordinate of the centre of the chart,
 STA XX12               \ so this sets XX12 to the centre 104 +/- 76, the pixel
                        \ x-coordinate of this system

 LSR A                  \ Move the text cursor to column x-delta / 2 + 1
 LSR A                  \ which will be in the range 1-10
 LSR A
 STA XC
 INC XC

 LDA QQ15+1             \ Set A = s0_hi - QQ1, the vertical distance between
 SEC                    \ this system and the current system, where |A| < 38.
 SBC QQ1                \ Let's call this the y-delta, as it's the vertical
                        \ difference between the current system at the centre of
                        \ the chart, and this system (and this time we keep the
                        \ sign of A, so it can be negative if it's above the
                        \ chart's centre, or positive if it's below)

 ASL A                  \ Set K4 = 90 + y-delta * 2
 ADC #90                \
 STA K4                 \ 90 is the y-coordinate of the centre of the chart,
                        \ so this sets K4 to the centre 90 +/- 74, the pixel
                        \ y-coordinate of this system

 LSR A                  \ Set Y = K4 / 8, so Y contains the number of the text
 LSR A                  \ row that contains this system
 LSR A
 TAY

                        \ Now to see if there is room for this system's label.
                        \ Ideally we would print the system name on the same
                        \ text row as the system, but we only want to print one
                        \ label per row, to prevent overlap, so now we check
                        \ this system's row, and if that's already occupied,
                        \ the row above, and if that's already occupied, the
                        \ row below... and if that's already occupied, we give
                        \ up and don't print a label for this system

 LDX INWK,Y             \ If the value in INWK+Y is 0 (i.e. the text row
 BEQ EE4                \ containing this system does not already have another
                        \ system's label on it), jump to EE4 to store this
                        \ system's label on this row

 INY                    \ If the value in INWK+Y+1 is 0 (i.e. the text row below
 LDX INWK,Y             \ the one containing this system does not already have
 BEQ EE4                \ another system's label on it), jump to EE4 to store
                        \ this system's label on this row

 DEY                    \ If the value in INWK+Y-1 is 0 (i.e. the text row above
 DEY                    \ the one containing this system does not already have
 LDX INWK,Y             \ another system's label on it), fall through into to
 BNE ee1                \ EE4 to store this system's label on this row,
                        \ otherwise jump to ee1 to skip printing a label for
                        \ this system (as there simply isn't room)

.EE4

 STY YC                 \ Now to print the label, so move the text cursor to row
                        \ Y (which contains the row where we can print this
                        \ system's label)

 CPY #3                 \ If Y < 3, then the system would clash with the chart
 BCC TT187              \ title, so jump to TT187 to skip showing the system

 LDA #&FF               \ Store &FF in INWK+Y, to denote that this row is now
 STA INWK,Y             \ occupied so we don't try to print another system's
                        \ label on this row

 LDA #%10000000         \ Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

 JSR cpl                \ Call cpl to print out the system name for the seeds
                        \ in QQ15 (which now contains the seeds for the current
                        \ system)

.ee1

 LDA #0                 \ Now to plot the star, so set the high bytes of K, K3
 STA K3+1               \ and K4 to 0
 STA K4+1
 STA K+1

 LDA XX12               \ Set the low byte of K3 to XX12, the pixel x-coordinate
 STA K3                 \ of this system

 LDA QQ15+5             \ Fetch s2_hi for this system from QQ15+5, extract bit 0
 AND #1                 \ and add 2 to get the size of the star, which we store
 ADC #2                 \ in K. This will be either 2, 3 or 4, depending on the
 STA K                  \ value of bit 0, and whether the C flag is set (which
                        \ will vary depending on what happens in the above call
                        \ to cpl). Incidentally, the planet's average radius
                        \ also uses s2_hi, bits 0-3 to be precise, but that
                        \ doesn't mean the two sizes affect each other

                        \ We now have the following:
                        \
                        \   K(1 0)  = radius of star (2, 3 or 4)
                        \
                        \   K3(1 0) = pixel x-coordinate of system
                        \
                        \   K4(1 0) = pixel y-coordinate of system
                        \
                        \ which we can now pass to the SUN routine to draw a
                        \ small "sun" on the Short-range Chart for this system

 JSR FLFLLS             \ Call FLFLLS to reset the LSO block

 JSR SUN                \ Call SUN to plot a sun with radius K at pixel
                        \ coordinate (K3, K4)

 JSR FLFLLS             \ Call FLFLLS to reset the LSO block

.TT187

 JSR TT20               \ We want to move on to the next system, so call TT20
                        \ to twist the three 16-bit seeds in QQ15

 INC XX20               \ Increment the counter

 BEQ TT111-1            \ If X = 0 then we have done all 256 systems, so return
                        \ from the subroutine (as TT111-1 contains an RTS)

 JMP TT182              \ Otherwise jump back up to TT182 to process the next
                        \ system

\ ******************************************************************************
\
\       Name: TT81
\       Type: Subroutine
\   Category: Universe
\    Summary: Set the selected system's seeds to those of system 0
\
\ ------------------------------------------------------------------------------
\
\ Copy the three 16-bit seeds for the current galaxy's system 0 (QQ21) into the
\ seeds for the selected system (QQ15) - in other words, set the selected
\ system's seeds to those of system 0.
\
\ ******************************************************************************

.TT81

 LDX #5                 \ Set up a counter in X to copy six bytes (for three
                        \ 16-bit numbers)

 LDA QQ21,X             \ Copy the X-th byte in QQ21 to the X-th byte in QQ15
 STA QQ15,X

 DEX                    \ Decrement the counter

 BPL TT81+2             \ Loop back up to the LDA instruction if we still have
                        \ more bytes to copy

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TT111
\       Type: Subroutine
\   Category: Universe
\    Summary: Set the current system to the nearest system to a point
\
\ ------------------------------------------------------------------------------
\
\ Given a set of galactic coordinates in (QQ9, QQ10), find the nearest system
\ to this point in the galaxy, and set this as the currently selected system.
\
\ Arguments:
\
\   QQ9                 The x-coordinate near which we want to find a system
\
\   QQ10                The y-coordinate near which we want to find a system
\
\ Returns:
\
\   QQ8(1 0)            The distance from the current system to the nearest
\                       system to the original coordinates
\
\   QQ9                 The x-coordinate of the nearest system to the original
\                       coordinates
\
\   QQ10                The y-coordinate of the nearest system to the original
\                       coordinates
\
\   QQ15 to QQ15+5      The three 16-bit seeds of the nearest system to the
\                       original coordinates
\
\   ZZ                  The system number of the nearest system
\
\ Other entry points:
\
\   TT111-1             Contains an RTS
\
\ ******************************************************************************

.TT111

 JSR TT81               \ Set the seeds in QQ15 to those of system 0 in the
                        \ current galaxy (i.e. copy the seeds from QQ21 to QQ15)

                        \ We now loop through every single system in the galaxy
                        \ and check the distance from (QQ9, QQ10). We get the
                        \ galactic coordinates of each system from the system's
                        \ seeds, like this:
                        \
                        \   x = s1_hi (which is stored in QQ15+3)
                        \   y = s0_hi (which is stored in QQ15+1)
                        \
                        \ so the following loops through each system in the
                        \ galaxy in turn and calculates the distance between
                        \ (QQ9, QQ10) and (s1_hi, s0_hi) to find the closest one

 LDY #127               \ Set Y = T = 127 to hold the shortest distance we've
 STY T                  \ found so far, which we initially set to half the
                        \ distance across the galaxy, or 127, as our coordinate
                        \ system ranges from (0,0) to (255, 255)

 LDA #0                 \ Set A = U = 0 to act as a counter for each system in
 STA U                  \ the current galaxy, which we start at system 0 and
                        \ loop through to 255, the last system

.TT130

 LDA QQ15+3             \ Set A = s1_hi - QQ9, the horizontal distance between
 SEC                    \ (s1_hi, s0_hi) and (QQ9, QQ10)
 SBC QQ9

 BCS TT132              \ If a borrow didn't occur, i.e. s1_hi >= QQ9, then the
                        \ result is positive, so jump to TT132 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |s1_hi - QQ9|)

.TT132

 LSR A                  \ Set S = A / 2
 STA S                  \       = |s1_hi - QQ9| / 2

 LDA QQ15+1             \ Set A = s0_hi - QQ10, the vertical distance between
 SEC                    \ (s1_hi, s0_hi) and (QQ9, QQ10)
 SBC QQ10

 BCS TT134              \ If a borrow didn't occur, i.e. s0_hi >= QQ10, then the
                        \ result is positive, so jump to TT134 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |s0_hi - QQ10|)

.TT134

 LSR A                  \ Set A = S + A / 2
 CLC                    \       = |s1_hi - QQ9| / 2 + |s0_hi - QQ10| / 2
 ADC S                  \
                        \ So A now contains the sum of the horizontal and
                        \ vertical distances, both divided by 2 so the result
                        \ fits into one byte, and although this doesn't contain
                        \ the actual distance between the systems, it's a good
                        \ enough approximation to use for comparing distances

 CMP T                  \ If A >= T, then this system's distance is bigger than
 BCS TT135              \ our "minimum distance so far" stored in T, so it's no
                        \ closer than the systems we have already found, so
                        \ skip to TT135 to move on to the next system

 STA T                  \ This system is the closest to (QQ9, QQ10) so far, so
                        \ update T with the new "distance" approximation

 LDX #5                 \ As this system is the closest we have found yet, we
                        \ want to store the system's seeds in case it ends up
                        \ being the closest of all, so we set up a counter in X
                        \ to copy six bytes (for three 16-bit numbers)

.TT136

 LDA QQ15,X             \ Copy the X-th byte in QQ15 to the X-th byte in QQ19,
 STA QQ19,X             \ where QQ15 contains the seeds for the system we just
                        \ found to be the closest so far, and QQ19 is temporary
                        \ storage

 DEX                    \ Decrement the counter

 BPL TT136              \ Loop back to TT136 if we still have more bytes to
                        \ copy

 LDA U                  \ Store the system number U in ZZ, so when we are done
 STA ZZ                 \ looping through all the candidates, the winner's
                        \ number will be in ZZ

.TT135

 JSR TT20               \ We want to move on to the next system, so call TT20
                        \ to twist the three 16-bit seeds in QQ15

 INC U                  \ Increment the system counter in U

 BNE TT130              \ If U > 0 then we haven't done all 256 systems yet, so
                        \ loop back up to TT130

                        \ We have now finished checking all the systems in the
                        \ galaxy, and the seeds for the closest system are in
                        \ QQ19, so now we want to copy these seeds to QQ15,
                        \ to set the selected system to this closest system

 LDX #5                 \ So we set up a counter in X to copy six bytes (for
                        \ three 16-bit numbers)

.TT137

 LDA QQ19,X             \ Copy the X-th byte in QQ19 to the X-th byte in QQ15,
 STA QQ15,X

 DEX                    \ Decrement the counter

 BPL TT137              \ Loop back to TT137 if we still have more bytes to
                        \ copy

 LDA QQ15+1             \ The y-coordinate of the system described by the seeds
 STA QQ10               \ in QQ15 is in QQ15+1 (s0_hi), so we copy this to QQ10
                        \ as this is where we store the selected system's
                        \ y-coordinate

 LDA QQ15+3             \ The x-coordinate of the system described by the seeds
 STA QQ9                \ in QQ15 is in QQ15+3 (s1_hi), so we copy this to QQ9
                        \ as this is where we store the selected system's
                        \ x-coordinate

                        \ We have now found the closest system to (QQ9, QQ10)
                        \ and have set it as the selected system, so now we
                        \ need to work out the distance between the selected
                        \ system and the current system

 SEC                    \ Set A = QQ9 - QQ0, the horizontal distance between
 SBC QQ0                \ the selected system's x-coordinate (QQ9) and the
                        \ current system's x-coordinate (QQ0)

 BCS TT139              \ If a borrow didn't occur, i.e. QQ9 >= QQ0, then the
                        \ result is positive, so jump to TT139 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |QQ9 - QQ0|)

                        \ A now contains the difference between the two
                        \ systems' x-coordinates, with the sign removed. We
                        \ will refer to this as the x-delta ("delta" means
                        \ change or difference in maths)

.TT139

 JSR SQUA2              \ Set (A P) = A * A
                        \           = |QQ9 - QQ0| ^ 2
                        \           = x_delta ^ 2

 STA K+1                \ Store (A P) in K(1 0)
 LDA P
 STA K

 LDA QQ10               \ Set A = QQ10 - QQ1, the vertical distance between the
 SEC                    \ selected system's y-coordinate (QQ10) and the current
 SBC QQ1                \ system's y-coordinate (QQ1)

 BCS TT141              \ If a borrow didn't occur, i.e. QQ10 >= QQ1, then the
                        \ result is positive, so jump to TT141 and skip the
                        \ following two instructions

 EOR #&FF               \ Otherwise negate the result in A, so A is always
 ADC #1                 \ positive (i.e. A = |QQ10 - QQ1|)

.TT141

 LSR A                  \ Set A = A / 2

                        \ A now contains the difference between the two
                        \ systems' y-coordinates, with the sign removed, and
                        \ halved. We halve the value because the galaxy in
                        \ in Elite is rectangular rather than square, and is
                        \ twice as wide (x-axis) as it is high (y-axis), so to
                        \ get a distance that matches the shape of the
                        \ long-range galaxy chart, we need to halve the
                        \ distance between the vertical y-coordinates. We will
                        \ refer to this as the y-delta

 JSR SQUA2              \ Set (A P) = A * A
                        \           = (|QQ10 - QQ1| / 2) ^ 2
                        \           = y_delta ^ 2

                        \ By this point we have the following results:
                        \
                        \   K(1 0) = x_delta ^ 2
                        \    (A P) = y_delta ^ 2
                        \
                        \ so to find the distance between the two points, we
                        \ can use Pythagoras - so first we need to add the two
                        \ results together, and then take the square root

 PHA                    \ Store the high byte of the y-axis value on the stack,
                        \ so we can use A for another purpose

 LDA P                  \ Set Q = P + K, which adds the low bytes of the two
 CLC                    \ calculated values
 ADC K
 STA Q

 PLA                    \ Restore the high byte of the y-axis value from the
                        \ stack into A again

 ADC K+1                \ Set R = A + K+1, which adds the high bytes of the two
 STA R                  \ calculated values, so we now have:
                        \
                        \   (R Q) = K(1 0) + (A P)
                        \         = (x_delta ^ 2) + (y_delta ^ 2)

 JSR LL5                \ Set Q = SQRT(R Q), so Q now contains the distance
                        \ between the two systems, in terms of coordinates

                        \ We now store the distance to the selected system * 4
                        \ in the two-byte location QQ8, by taking (0 Q) and
                        \ shifting it left twice, storing it in QQ8(1 0)

 LDA Q                  \ First we shift the low byte left by setting
 ASL A                  \ A = Q * 2, with bit 7 of A going into the C flag

 LDX #0                 \ Now we set the high byte in QQ8+1 to 0 and rotate
 STX QQ8+1              \ the C flag into bit 0 of QQ8+1
 ROL QQ8+1

 ASL A                  \ And then we repeat the shift left of (QQ8+1 A)
 ROL QQ8+1

 STA QQ8                \ And store A in the low byte, QQ8, so QQ8(1 0) now
                        \ contains Q * 4. Given that the width of the galaxy is
                        \ 256 in coordinate terms, the width of the galaxy
                        \ would be 1024 in the units we store in QQ8

 JMP TT24               \ Call TT24 to calculate system data from the seeds in
                        \ QQ15 and store them in the relevant locations, so our
                        \ new selected system is fully set up, and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: pr6
\       Type: Subroutine
\   Category: Text
\    Summary: Print 16-bit number, left-padded to 5 digits, no point
\
\ ------------------------------------------------------------------------------
\
\ Print the 16-bit number in (Y X) to 5 digits, left-padding with spaces for
\ numbers with fewer than 3 digits (so numbers < 10000 are right-aligned),
\ with no decimal point.
\
\ Arguments:
\
\   X                   The low byte of the number to print
\
\   Y                   The high byte of the number to print
\
\ ******************************************************************************

.pr6

 CLC                    \ Do not display a decimal point when printing

                        \ Fall through into pr5 to print X to 5 digits

\ ******************************************************************************
\
\       Name: pr5
\       Type: Subroutine
\   Category: Text
\    Summary: Print a 16-bit number, left-padded to 5 digits, and optional point
\
\ ------------------------------------------------------------------------------
\
\ Print the 16-bit number in (Y X) to 5 digits, left-padding with spaces for
\ numbers with fewer than 3 digits (so numbers < 10000 are right-aligned).
\ Optionally include a decimal point.
\
\ Arguments:
\
\   X                   The low byte of the number to print
\
\   Y                   The high byte of the number to print
\
\   C flag              If set, include a decimal point
\
\ ******************************************************************************

.pr5

 LDA #5                 \ Set the number of digits to print to 5

 JMP TT11               \ Call TT11 to print (Y X) to 5 digits and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: TT162
\       Type: Subroutine
\   Category: Text
\    Summary: Print a space
\
\ Other entry points:
\
\   TT162+2             Jump to TT27 to print the text token in A
\
\ ******************************************************************************

.TT162

 LDA #' '               \ Load a space character into A

 JMP TT27               \ Print the text token in A and return from the
                        \ subroutine using a tail call

.func_tab

 EQUB &20, &71, &72, &73, &14, &74, &75, &16, &76, &77

.BAY2

 SBC #&50
 BCC buy_top
 CMP #&0A
 BCC buy_func

.buy_top

 LDA #&01

.buy_func

 TAX
 LDA func_tab,X
 JMP FRCE

\ ******************************************************************************
\
\       Name: gnum
\       Type: Subroutine
\   Category: Market
\    Summary: Get a number from the keyboard
\
\ ------------------------------------------------------------------------------
\
\ Get a number from the keyboard, up to the maximum number in QQ25, for the
\ buying and selling of cargo and equipment.
\
\ Pressing "Y" will return the maximum number (i.e. buy/sell all items), while
\ pressing "N" will abort the sale and return a 0.
\
\ Pressing a key with an ASCII code less than ASCII "0" will return a 0 in A (so
\ that includes pressing Space or Return), while pressing a key with an ASCII
\ code greater than ASCII "9" will jump to the Inventory screen (so that
\ includes all letters and most punctuation).
\
\ Arguments:
\
\   QQ25                The maximum number allowed
\
\ Returns:
\
\   A                   The number entered
\
\   R                   Also contains the number entered
\
\   C flag              Set if the number is too large (> QQ25), clear otherwise
\
\ ******************************************************************************

.gnum

 LDX #0                 \ We will build the number entered in R, so initialise
 STX R                  \ it with 0

 LDX #12                \ We will check for up to 12 key presses, so set a
 STX T1                 \ counter in T1

.TT223

 JSR TT217              \ Scan the keyboard until a key is pressed, and return
                        \ the key's ASCII code in A (and X)

 LDX R                  \ If R is non-zero then skip to NWDAV2, as we are
 BNE NWDAV2             \ already building a number

.NWDAV2

 STA Q                  \ Store the key pressed in Q

 SEC                    \ Subtract ASCII '0' from the key pressed, to leave the
 SBC #'0'               \ numeric value of the key in A (if it was a number key)

 BCC OUT                \ If A < 0, jump to OUT to return from the subroutine
                        \ with a result of 0, as the key pressed was not a
                        \ number or letter and is less than ASCII "0"

 CMP #10                \ If A >= 10, jump to BAY2 to display the Inventory
 BCS BAY2               \ screen, as the key pressed was a letter or other
                        \ non-digit and is greater than ASCII "9"

 STA S                  \ Store the numeric value of the key pressed in S

 LDA R                  \ Fetch the result so far into A

 CMP #26                \ If A >= 26, where A is the number entered so far, then
 BCS OUT                \ adding a further digit will make it bigger than 256,
                        \ so jump to OUT to return from the subroutine with the
                        \ result in R (i.e. ignore the last key press)

 ASL A                  \ Set A = (A * 2) + (A * 8) = A * 10
 STA T
 ASL A
 ASL A
 ADC T

 ADC S                  \ Add the pressed digit to A and store in R, so R now
 STA R                  \ contains its previous value with the new key press
                        \ tacked onto the end

 CMP QQ25               \ If the result in R = the maximum allowed in QQ25, jump
 BEQ TT226              \ to TT226 to print the key press and keep looping (the
                        \ BEQ is needed because the BCS below would jump to OUT
                        \ if R >= QQ25, which we don't want)

 BCS OUT                \ If the result in R > QQ25, jump to OUT to return from
                        \ the subroutine with the result in R

.TT226

 LDA Q                  \ Print the character in Q (i.e. the key that was
 JSR TT26               \ pressed, as we stored the ASCII value in Q earlier)

 DEC T1                 \ Decrement the loop counter

 BNE TT223              \ Loop back to TT223 until we have checked for 12 digits

.OUT

 LDA R                  \ Set A to the result we have been building in R

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: dn2
\       Type: Subroutine
\   Category: Text
\    Summary: Make a short, high beep and delay for 1 second
\
\ ******************************************************************************

.dn2

 JSR BEEP               \ Call the BEEP subroutine to make a short, high beep

 LDY #50                \ Delay for 50 vertical syncs (50/50 = 1 second) and
 JMP DELAY              \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: hm
\       Type: Subroutine
\   Category: Charts
\    Summary: Select the closest system and redraw the chart crosshairs
\
\ ------------------------------------------------------------------------------
\
\ Set the system closest to galactic coordinates (QQ9, QQ10) as the selected
\ system, redraw the crosshairs on the chart accordingly (if they are being
\ shown), and, if this is not a space view, clear the bottom three text rows of
\ the screen.
\
\ ******************************************************************************

.hm

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10),
                        \ which will erase the crosshairs currently there

 JSR TT111              \ Select the system closest to galactic coordinates
                        \ (QQ9, QQ10)

 JSR TT103              \ Draw small crosshairs at coordinates (QQ9, QQ10),
                        \ which will draw the crosshairs at our current home
                        \ system

 JMP CLYNS              \ Clear the bottom three text rows of the upper screen,
                        \ and move the text cursor to column 1 on row 21, i.e.
                        \ the start of the top row of the three bottom rows

                        \ Return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: cpl
\       Type: Subroutine
\   Category: Text
\    Summary: Print the selected system name
\  Deep dive: Generating system names
\             Galaxy and system seeds
\
\ ------------------------------------------------------------------------------
\
\ Print control code 3 (the selected system name, i.e. the one in the crosshairs
\ in the Short-range Chart).
\
\ Other entry points:
\
\   cmn-1               Contains an RTS
\
\ ******************************************************************************

.cpl

 LDX #5                 \ First we need to backup the seeds in QQ15, so set up
                        \ a counter in X to cover three 16-bit seeds (i.e.
                        \ 6 bytes)

.TT53

 LDA QQ15,X             \ Copy byte X from QQ15 to QQ19
 STA QQ19,X

 DEX                    \ Decrement the loop counter

 BPL TT53               \ Loop back for the next byte to backup

 LDY #3                 \ Step 1: Now that the seeds are backed up, we can
                        \ start the name-generation process. We will either
                        \ need to loop three or four times, so for now set
                        \ up a counter in Y to loop four times

 BIT QQ15               \ Check bit 6 of s0_lo, which is stored in QQ15

 BVS P%+3               \ If bit 6 is set then skip over the next instruction

 DEY                    \ Bit 6 is clear, so we only want to loop three times,
                        \ so decrement the loop counter in Y

 STY T                  \ Store the loop counter in T

.TT55

 LDA QQ15+5             \ Step 2: Load s2_hi, which is stored in QQ15+5, and
 AND #%00011111         \ extract bits 0-4 by AND'ing with %11111

 BEQ P%+7               \ If all those bits are zero, then skip the following
                        \ 2 instructions to go to step 3

 ORA #%10000000         \ We now have a number in the range 1-31, which we can
                        \ easily convert into a two-letter token, but first we
                        \ need to add 128 (or set bit 7) to get a range of
                        \ 129-159

 JSR TT27               \ Print the two-letter token in A

 JSR TT54               \ Step 3: twist the seeds in QQ15

 DEC T                  \ Decrement the loop counter

 BPL TT55               \ Loop back for the next two letters

 LDX #5                 \ We have printed the system name, so we can now
                        \ restore the seeds we backed up earlier. Set up a
                        \ counter in X to cover three 16-bit seeds (i.e. 6
                        \ bytes)

.TT56

 LDA QQ19,X             \ Copy byte X from QQ19 to QQ15
 STA QQ15,X

 DEX                    \ Decrement the loop counter

 BPL TT56               \ Loop back for the next byte to restore

 RTS                    \ Once all the seeds are restored, return from the
                        \ subroutine

\ ******************************************************************************
\
\       Name: cmn
\       Type: Subroutine
\   Category: Text
\    Summary: Print the commander's name
\
\ ------------------------------------------------------------------------------
\
\ Print control code 4 (the commander's name).
\
\ Other entry points:
\
\   ypl-1               Contains an RTS
\
\ ******************************************************************************

.cmn

 JSR MT19               \ Call MT19 to capitalise the next letter (i.e. set
                        \ Sentence Case for this word only)

 LDY #0                 \ Set up a counter in Y, starting from 0

.QUL4

 LDA NA%,Y              \ The commander's name is stored at NA%, so load the
                        \ Y-th character from NA%

 CMP #13                \ If we have reached the end of the name, return from
 BEQ ypl-1              \ the subroutine (ypl-1 points to the RTS below)

 JSR TT26               \ Print the character we just loaded

 INY                    \ Increment the loop counter

 BNE QUL4               \ Loop back for the next character

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ypl
\       Type: Subroutine
\   Category: Text
\    Summary: Print the current system name
\
\ ------------------------------------------------------------------------------
\
\ Print control code 2 (the current system name).
\
\ ******************************************************************************

.ypl

 JSR TT62               \ Call TT62 below to swap the three 16-bit seeds in
                        \ QQ2 and QQ15 (before the swap, QQ2 contains the seeds
                        \ for the current system, while QQ15 contains the seeds
                        \ for the selected system)

 JSR cpl                \ Call cpl to print out the system name for the seeds
                        \ in QQ15 (which now contains the seeds for the current
                        \ system)

                        \ Now we fall through into the TT62 subroutine, which
                        \ will swap QQ2 and QQ15 once again, so everything goes
                        \ back into the right place, and the RTS at the end of
                        \ TT62 will return from the subroutine

.TT62

 LDX #5                 \ Set up a counter in X for the three 16-bit seeds we
                        \ want to swap (i.e. 6 bytes)

.TT78

 LDA QQ15,X             \ Swap byte X between QQ2 and QQ15
 LDY QQ2,X
 STA QQ2,X
 STY QQ15,X

 DEX                    \ Decrement the loop counter

 BPL TT78               \ Loop back for the next byte to swap

 RTS                    \ Once all bytes are swapped, return from the
                        \ subroutine

\ ******************************************************************************
\
\       Name: tal
\       Type: Subroutine
\   Category: Text
\    Summary: Print the current galaxy numbe
\
\ ------------------------------------------------------------------------------
\
\ Print control code 1 (the current galaxy number, right-aligned to width 3).
\
\ ******************************************************************************

.tal

 CLC                    \ We don't want to print the galaxy number with a
                        \ decimal point, so clear the C flag for pr2 to take as
                        \ an argument

 LDX GCNT               \ Load the current galaxy number from GCNT into X

 INX                    \ Add 1 to the galaxy number, as the galaxy numbers
                        \ are 0-7 internally, but we want to display them as
                        \ galaxy 1 through 8

 JMP pr2                \ Jump to pr2, which prints the number in X to a width
                        \ of 3 figures, left-padding with spaces to a width of
                        \ 3, and once done, return from the subroutine (as pr2
                        \ ends with an RTS)

\ ******************************************************************************
\
\       Name: fwl
\       Type: Subroutine
\   Category: Text
\    Summary: Print fuel and cash levels
\
\ ------------------------------------------------------------------------------
\
\ Print control code 5 ("FUEL: ", fuel level, " LIGHT YEARS", newline, "CASH:",
\ control code 0).
\
\ ******************************************************************************

.fwl

 LDA #105               \ Print recursive token 105 ("FUEL") followed by a
 JSR TT68               \ colon

 LDX QQ14               \ Load the current fuel level from QQ14

 SEC                    \ We want to print the fuel level with a decimal point,
                        \ so set the C flag for pr2 to take as an argument

 JSR pr2                \ Call pr2, which prints the number in X to a width of
                        \ 3 figures (i.e. in the format x.x, which will always
                        \ be exactly 3 characters as the maximum fuel is 7.0)

 LDA #195               \ Print recursive token 35 ("LIGHT YEARS") followed by
 JSR plf                \ a newline

.PCASH                  \ This label is not used but is in the original source

 LDA #119               \ Print recursive token 119 ("CASH:" then control code
 BNE TT27               \ 0, which prints cash levels, then " CR" and newline)

\ ******************************************************************************
\
\       Name: csh
\       Type: Subroutine
\   Category: Text
\    Summary: Print the current amount of cash
\
\ ------------------------------------------------------------------------------
\
\ Print control code 0 (the current amount of cash, right-aligned to width 9,
\ followed by " CR" and a newline).
\
\ ******************************************************************************

.csh

 LDX #3                 \ We are going to use the BPRNT routine to print out
                        \ the current amount of cash, which is stored as a
                        \ 32-bit number at location CASH. BPRNT prints out
                        \ the 32-bit number stored in K, so before we call
                        \ BPRNT, we need to copy the four bytes from CASH into
                        \ K, so first we set up a counter in X for the 4 bytes

.pc1

 LDA CASH,X             \ Copy byte X from CASH to K
 STA K,X

 DEX                    \ Decrement the loop counter

 BPL pc1                \ Loop back for the next byte to copy

 LDA #9                 \ We want to print the cash using up to 9 digits
 STA U                  \ (including the decimal point), so store this in U
                        \ for BRPNT to take as an argument

 SEC                    \ We want to print the fuel level with a decimal point,
                        \ so set the C flag for BRPNT to take as an argument

 JSR BPRNT              \ Print the amount of cash to 9 digits with a decimal
                        \ point

 LDA #226               \ Print recursive token 66 (" CR") followed by a
                        \ newline by falling through into plf

\ ******************************************************************************
\
\       Name: plf
\       Type: Subroutine
\   Category: Text
\    Summary: Print a text token followed by a newline
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.plf

 JSR TT27               \ Print the text token in A

 JMP TT67               \ Jump to TT67 to print a newline and return from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: TT68
\       Type: Subroutine
\   Category: Text
\    Summary: Print a text token followed by a colon
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.TT68

 JSR TT27               \ Print the text token in A and fall through into TT73
                        \ to print a colon

\ ******************************************************************************
\
\       Name: TT73
\       Type: Subroutine
\   Category: Text
\    Summary: Print a colon
\
\ ******************************************************************************

.TT73

 LDA #':'               \ Set A to ASCII ":" and fall through into TT27 to
                        \ actually print the colon

\ ******************************************************************************
\
\       Name: TT27
\       Type: Subroutine
\   Category: Text
\    Summary: Print a text token
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ Print a text token (i.e. a character, control code, two-letter token or
\ recursive token). See variable QQ18 for a discussion of the token system
\ used in Elite.
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.TT27

 TAX                    \ Copy the token number from A to X. We can then keep
                        \ decrementing X and testing it against zero, while
                        \ keeping the original token number intact in A; this
                        \ effectively implements a switch statement on the
                        \ value of the token

 BEQ csh                \ If token = 0, this is control code 0 (current amount
                        \ of cash and newline), so jump to csh

 BMI TT43               \ If token > 127, this is either a two-letter token
                        \ (128-159) or a recursive token (160-255), so jump
                        \ to TT43 to process tokens

 DEX                    \ If token = 1, this is control code 1 (current galaxy
 BEQ tal                \ number), so jump to tal

 DEX                    \ If token = 2, this is control code 2 (current system
 BEQ ypl                \ name), so jump to ypl

 DEX                    \ If token > 3, skip the following instruction
 BNE P%+5

 JMP cpl                \ This token is control code 3 (selected system name)
                        \ so jump to cpl

 DEX                    \ If token = 4, this is control code 4 (commander
 BEQ cmn                \ name), so jump to cmm

 DEX                    \ If token = 5, this is control code 5 (fuel, newline,
 BEQ fwl                \ cash, newline), so jump to fwl

 DEX                    \ If token > 6, skip the following 3 instructions
 BNE P%+7

 LDA #%10000000         \ This token is control code 6 (switch to Sentence
 STA QQ17               \ Case), so set bit 7 of QQ17 to switch to Sentence Case
 RTS                    \ and return from the subroutine as we are done

 DEX                    \ If token > 8, skip the following 2 instructions
 DEX
 BNE P%+5

 STX QQ17               \ This token is control code 8 (switch to ALL CAPS), so
 RTS                    \ set QQ17 to 0 to switch to ALL CAPS and return from
                        \ the subroutine as we are done

 DEX                    \ If token = 9, this is control code 9 (tab to column
 BEQ crlf               \ 21 and print a colon), so jump to crlf

 CMP #96                \ By this point, token is either 7, or in 10-127.
 BCS ex                 \ Check token number in A and if token >= 96, then the
                        \ token is in 96-127, which is a recursive token, so
                        \ jump to ex, which prints recursive tokens in this
                        \ range (i.e. where the recursive token number is
                        \ correct and doesn't need correcting)

 CMP #14                \ If token < 14, skip the following 2 instructions
 BCC P%+6

 CMP #32                \ If token < 32, then this means token is in 14-31, so
 BCC qw                 \ this is a recursive token that needs 114 adding to it
                        \ to get the recursive token number, so jump to qw
                        \ which will do this

                        \ By this point, token is either 7 (beep) or in 10-13
                        \ (line feeds and carriage returns), or in 32-95
                        \ (ASCII letters, numbers and punctuation)

 LDX QQ17               \ Fetch QQ17, which controls letter case, into X

 BEQ TT74               \ If QQ17 = 0, then ALL CAPS is set, so jump to TT27
                        \ to print this character as is (i.e. as a capital)

 BMI TT41               \ If QQ17 has bit 7 set, then we are using Sentence
                        \ Case, so jump to TT41, which will print the
                        \ character in upper or lower case, depending on
                        \ whether this is the first letter in a word

 BIT QQ17               \ If we get here, QQ17 is not 0 and bit 7 is clear, so
 BVS TT46               \ either it is bit 6 that is set, or some other flag in
                        \ QQ17 is set (bits 0-5). So check whether bit 6 is set.
                        \ If it is, then ALL CAPS has been set (as bit 7 is
                        \ clear) but bit 6 is still indicating that the next
                        \ character should be printed in lower case, so we need
                        \ to fix this. We do this with a jump to TT46, which
                        \ will print this character in upper case and clear bit
                        \ 6, so the flags are consistent with ALL CAPS going
                        \ forward

                        \ If we get here, some other flag is set in QQ17 (one
                        \ of bits 0-5 is set), which shouldn't happen in this
                        \ version of Elite. If this were the case, then we
                        \ would fall through into TT42 to print in lower case,
                        \ which is how printing all words in lower case could
                        \ be supported (by setting QQ17 to 1, say)

\ ******************************************************************************
\
\       Name: TT42
\       Type: Subroutine
\   Category: Text
\    Summary: Print a letter in lower case
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\ Other entry points:
\
\   TT44                Jumps to TT26 to print the character in A (used to
\                       enable us to use a branch instruction to jump to TT26)
\
\ ******************************************************************************

.TT42

 CMP #'A'               \ If A < ASCII "A", then this is punctuation, so jump
 BCC TT44               \ to TT26 (via TT44) to print the character as is, as
                        \ we don't care about the character's case

 CMP #'Z'+1             \ If A >= (ASCII "Z" + 1), then this is also
 BCS TT44               \ punctuation, so jump to TT26 (via TT44) to print the
                        \ character as is, as we don't care about the
                        \ character's case

 ADC #32                \ Add 32 to the character, to convert it from upper to
                        \ to lower case

.TT44

 JMP TT26               \ Print the character in A

\ ******************************************************************************
\
\       Name: TT41
\       Type: Subroutine
\   Category: Text
\    Summary: Print a letter according to Sentence Case
\
\ ------------------------------------------------------------------------------
\
\ The rules for printing in Sentence Case are as follows:
\
\   * If QQ17 bit 6 is set, print lower case (via TT45)
\
\   * If QQ17 bit 6 clear, then:
\
\       * If character is punctuation, just print it
\
\       * If character is a letter, set QQ17 bit 6 and print letter as a capital
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\   X                   Contains the current value of QQ17
\
\   QQ17                Bit 7 is set
\
\ ******************************************************************************

.TT41

                        \ If we get here, then QQ17 has bit 7 set, so we are in
                        \ Sentence Case

 BIT QQ17               \ If QQ17 also has bit 6 set, jump to TT45 to print
 BVS TT45               \ this character in lower case

                        \ If we get here, then QQ17 has bit 6 clear and bit 7
                        \ set, so we are in Sentence Case and we need to print
                        \ the next letter in upper case

 CMP #'A'               \ If A < ASCII "A", then this is punctuation, so jump
 BCC TT74               \ to TT26 (via TT44) to print the character as is, as
                        \ we don't care about the character's case

 PHA                    \ Otherwise this is a letter, so store the token number

 TXA                    \ Set bit 6 in QQ17 (X contains the current QQ17)
 ORA #%1000000          \ so the next letter after this one is printed in lower
 STA QQ17               \ case

 PLA                    \ Restore the token number into A

 BNE TT44               \ Jump to TT26 (via TT44) to print the character in A
                        \ (this BNE is effectively a JMP as A will never be
                        \ zero)

\ ******************************************************************************
\
\       Name: qw
\       Type: Subroutine
\   Category: Text
\    Summary: Print a recursive token in the range 128-145
\
\ ------------------------------------------------------------------------------
\
\ Print a recursive token where the token number is in 128-145 (so the value
\ passed to TT27 is in the range 14-31).
\
\ Arguments:
\
\   A                   A value from 128-145, which refers to a recursive token
\                       in the range 14-31
\
\ ******************************************************************************

.qw

 ADC #114               \ This is a recursive token in the range 0-95, so add
 BNE ex                 \ 114 to the argument to get the token number 128-145
                        \ and jump to ex to print it

\ ******************************************************************************
\
\       Name: crlf
\       Type: Subroutine
\   Category: Text
\    Summary: Tab to column 21 and print a colon
\
\ ------------------------------------------------------------------------------
\
\ Print control code 9 (tab to column 21 and print a colon). The subroutine
\ name is pretty misleading, as it doesn't have anything to do with carriage
\ returns or line feeds.
\
\ ******************************************************************************

.crlf

 LDA #21                \ Set the X-column in XC to 21
 STA XC

 BNE TT73               \ Jump to TT73, which prints a colon (this BNE is
                        \ effectively a JMP as A will never be zero)

\ ******************************************************************************
\
\       Name: TT45
\       Type: Subroutine
\   Category: Text
\    Summary: Print a letter in lower case
\
\ ------------------------------------------------------------------------------
\
\ This routine prints a letter in lower case. Specifically:
\
\   * If QQ17 = 255, abort printing this character as printing is disabled
\
\   * If this is a letter then print in lower case
\
\   * Otherwise this is punctuation, so clear bit 6 in QQ17 and print
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\   X                   Contains the current value of QQ17
\
\   QQ17                Bits 6 and 7 are set
\
\ ******************************************************************************

.TT45

                        \ If we get here, then QQ17 has bit 6 and 7 set, so we
                        \ are in Sentence Case and we need to print the next
                        \ letter in lower case

 CPX #255               \ If QQ17 = 255 then printing is disabled, so return
 BEQ TT48               \ from the subroutine (as TT48 contains an RTS)

 CMP #'A'               \ If A >= ASCII "A", then jump to TT42, which will
 BCS TT42               \ print the letter in lowercase

                        \ Otherwise this is not a letter, it's punctuation, so
                        \ this is effectively a word break. We therefore fall
                        \ through to TT46 to print the character and set QQ17
                        \ to ensure the next word starts with a capital letter

\ ******************************************************************************
\
\       Name: TT46
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character and switch to capitals
\
\ ------------------------------------------------------------------------------
\
\ Print a character and clear bit 6 in QQ17, so that the next letter that gets
\ printed after this will start with a capital letter.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\   X                   Contains the current value of QQ17
\
\   QQ17                Bits 6 and 7 are set
\
\ ******************************************************************************

.TT46

 PHA                    \ Store the token number

 TXA                    \ Clear bit 6 in QQ17 (X contains the current QQ17) so
 AND #%10111111         \ the next letter after this one is printed in upper
 STA QQ17               \ case

 PLA                    \ Restore the token number into A

                        \ Now fall through into TT74 to print the character

\ ******************************************************************************
\
\       Name: TT74
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to be printed
\
\ ******************************************************************************

.TT74

 JMP TT26               \ Print the character in A

\ ******************************************************************************
\
\       Name: TT43
\       Type: Subroutine
\   Category: Text
\    Summary: Print a two-letter token or recursive token 0-95
\
\ ------------------------------------------------------------------------------
\
\ Print a two-letter token, or a recursive token where the token number is in
\ 0-95 (so the value passed to TT27 is in the range 160-255).
\
\ Arguments:
\
\   A                   One of the following:
\
\                         * 128-159 (two-letter token)
\
\                         * 160-255 (the argument to TT27 that refers to a
\                           recursive token in the range 0-95)
\
\ ******************************************************************************

.TT43

 CMP #160               \ If token >= 160, then this is a recursive token, so
 BCS TT47               \ jump to TT47 below to process it

 AND #127               \ This is a two-letter token with number 128-159. The
 ASL A                  \ set of two-letter tokens is stored in a lookup table
                        \ at QQ16, with each token taking up two bytes, so to
                        \ convert this into the token's position in the table,
                        \ we subtract 128 (or just clear bit 7) and multiply
                        \ by 2 (or shift left)

 TAY                    \ Transfer the token's position into Y so we can look
                        \ up the token using absolute indexed mode

 LDA QQ16,Y             \ Get the first letter of the token and print it
 JSR TT27

 LDA QQ16+1,Y           \ Get the second letter of the token

 CMP #'?'               \ If the second letter of the token is a question mark
 BEQ TT48               \ then this is a one-letter token, so just return from
                        \ the subroutine without printing (as TT48 contains an
                        \ RTS)

 JMP TT27               \ Print the second letter and return from the
                        \ subroutine

.TT47

 SBC #160               \ This is a recursive token in the range 160-255, so
                        \ subtract 160 from the argument to get the token
                        \ number 0-95 and fall through into ex to print it

\ ******************************************************************************
\
\       Name: ex
\       Type: Subroutine
\   Category: Text
\    Summary: Print a recursive token
\
\ ------------------------------------------------------------------------------
\
\ This routine works its way through the recursive tokens that are stored in
\ tokenised form in memory at &0400 to &06FF, and when it finds token number A,
\ it prints it. Tokens are null-terminated in memory and fill three pages,
\ but there is no lookup table as that would consume too much memory, so the
\ only way to find the correct token is to start at the beginning and look
\ through the table byte by byte, counting tokens as we go until we are in the
\ right place. This approach might not be terribly speed efficient, but it is
\ certainly memory-efficient.
\
\ For details of the tokenisation system, see variable QQ18.
\
\ Arguments:
\
\   A                   The recursive token to be printed, in the range 0-148
\
\ Other entry points:
\
\   TT48                Contains an RTS
\
\ ******************************************************************************

.ex

 TAX                    \ Copy the token number into X

 LDA #LO(QQ18)          \ Set V, V+1 to point to the recursive token table at
 STA V                  \ location QQ18
 LDA #HI(QQ18)
 STA V+1

 LDY #0                 \ Set a counter Y to point to the character offset
                        \ as we scan through the table

 TXA                    \ Copy the token number back into A, so both A and X
                        \ now contain the token number we want to print

 BEQ TT50               \ If the token number we want is 0, then we have
                        \ already found the token we are looking for, so jump
                        \ to TT50, otherwise start working our way through the
                        \ null-terminated token table until we find the X-th
                        \ token

.TT51

 LDA (V),Y              \ Fetch the Y-th character from the token table page
                        \ we are currently scanning

 BEQ TT49               \ If the character is null, we've reached the end of
                        \ this token, so jump to TT49

 INY                    \ Increment character pointer and loop back round for
 BNE TT51               \ the next character in this token, assuming Y hasn't
                        \ yet wrapped around to 0

 INC V+1                \ If it has wrapped round to 0, we have just crossed
 BNE TT51               \ into a new page, so increment V+1 so that V points
                        \ to the start of the new page

.TT49

 INY                    \ Increment the character pointer

 BNE TT59               \ If Y hasn't just wrapped around to 0, skip the next
                        \ instruction

 INC V+1                \ We have just crossed into a new page, so increment
                        \ V+1 so that V points to the start of the new page

.TT59

 DEX                    \ We have just reached a new token, so decrement the
                        \ token number we are looking for

 BNE TT51               \ Assuming we haven't yet reached the token number in
                        \ X, look back up to keep fetching characters

.TT50

                        \ We have now reached the correct token in the token
                        \ table, with Y pointing to the start of the token as
                        \ an offset within the page pointed to by V, so let's
                        \ print the recursive token. Because recursive tokens
                        \ can contain other recursive tokens, we need to store
                        \ our current state on the stack, so we can retrieve
                        \ it after printing each character in this token

 TYA                    \ Store the offset in Y on the stack
 PHA

 LDA V+1                \ Store the high byte of V (the page containing the
 PHA                    \ token we have found) on the stack, so the stack now
                        \ contains the address of the start of this token

 LDA (V),Y              \ Load the character at offset Y in the token table,
                        \ which is the next character of this token that we
                        \ want to print

 EOR #35                \ Tokens are stored in memory having been EOR'd with 35
                        \ (see variable QQ18 for details), so we repeat the
                        \ EOR to get the actual character to print

 JSR TT27               \ Print the text token in A, which could be a letter,
                        \ number, control code, two-letter token or another
                        \ recursive token

 PLA                    \ Restore the high byte of V (the page containing the
 STA V+1                \ token we have found) into V+1

 PLA                    \ Restore the offset into Y
 TAY

 INY                    \ Increment Y to point to the next character in the
                        \ token we are printing

 BNE P%+4               \ If Y is zero then we have just crossed into a new
 INC V+1                \ page, so increment V+1 so that V points to the start
                        \ of the new page

 LDA (V),Y              \ Load the next character we want to print into A

 BNE TT50               \ If this is not the null character at the end of the
                        \ token, jump back up to TT50 to print the next
                        \ character, otherwise we are done printing

.TT48

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: WPSHPS
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Clear the scanner, reset the ball line and sun line heaps
\
\ ------------------------------------------------------------------------------
\
\ Remove all ships from the scanner, reset the sun line heap at LSO, and reset
\ the ball line heap at LSX2 and LSY2.
\
\ ******************************************************************************

.WPSHPS

 LDX #0                 \ Set up a counter in X to work our way through all the
                        \ ship slots in FRIN

.WSL1

 LDA FRIN,X             \ Fetch the ship type in slot X

 BEQ WS2                \ If the slot contains 0 then it is empty and we have
                        \ checked all the slots (as they are always shuffled
                        \ down in the main loop to close up and gaps), so jump
                        \ to WS2 as we are done

 BMI WS1                \ If the slot contains a ship type with bit 7 set, then
                        \ it contains the planet or the sun, so jump down to WS1
                        \ to skip this slot, as the planet and sun don't appear
                        \ on the scanner

 JSR GINF               \ Call GINF to get the address of the data block for
                        \ ship slot X and store it in INF

 LDY #31                \ We now want to copy the first 32 bytes from the ship's
                        \ data block into INWK, so set a counter in Y

.WSL2

 LDA (INF),Y            \ Copy the Y-th byte from the data block pointed to by
 STA INWK,Y             \ INF into the Y-th byte of INWK workspace

 DEY                    \ Decrement the counter to point at the next byte

 BPL WSL2               \ Loop back to WSL2 until we have copied all 32 bytes

 STX XSAV               \ Store the ship slot number in XSAV while we call SCAN

 LDX XSAV               \ Restore the ship slot number from XSAV into X

 LDY #31                \ Clear bits 3, 4 and 6 in the ship's byte #31, which
 LDA (INF),Y            \ stops drawing the ship on-screen (bit 3), hides it
 AND #%10100111         \ from the scanner (bit 4) and stops any lasers firing
 STA (INF),Y            \ at it (bit 6)

.WS1

 INX                    \ Increment X to point to the next ship slot

 BNE WSL1               \ Loop back up to process the next slot (this BNE is
                        \ effectively a JMP as X will never be zero)

.WS2

 LDX #&FF               \ Set LSX2 = LSY2 = &FF to clear the ball line heap
 STX LSX2
 STX LSY2

                        \ Fall through into FLFLLS to reset the LSO block

\ ******************************************************************************
\
\       Name: FLFLLS
\       Type: Subroutine
\   Category: Drawing suns
\    Summary: Reset the sun line heap
\
\ ------------------------------------------------------------------------------
\
\ Reset the sun line heap at LSO by zero-filling it and setting the first byte
\ to &FF.
\
\ Returns:
\
\   A                   A is set to 0
\
\ ******************************************************************************

.FLFLLS

 LDY #2*Y-1             \ #Y is the y-coordinate of the centre of the space
                        \ view, so this sets Y as a counter for the number of
                        \ lines in the space view (i.e. 191), which is also the
                        \ number of lines in the LSO block

 LDA #0                 \ Set A to 0 so we can zero-fill the LSO block

.SAL6

 STA LSO,Y              \ Set the Y-th byte of the LSO block to 0

 DEY                    \ Decrement the counter

 BNE SAL6               \ Loop back until we have filled all the way to LSO+1

 DEY                    \ Decrement Y to value of &FF (as we exit the above loop
                        \ with Y = 0)

 STY LSX                \ Set the first byte of the LSO block, which has its own
                        \ label LSX, to &FF, to indicate that the sun line heap
                        \ is empty

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: GINF
\       Type: Subroutine
\   Category: Universe
\    Summary: Fetch the address of a ship's data block into INF
\
\ ------------------------------------------------------------------------------
\
\ Get the address of the data block for ship slot X and store it in INF. This
\ address is fetched from the UNIV table, which stores the addresses of the 13
\ ship data blocks in workspace K%.
\
\ Arguments:
\
\   X                   The ship slot number for which we want the data block
\                       address
\
\ ******************************************************************************

.GINF

 TXA                    \ Set Y = X * 2
 ASL A
 TAY

 LDA UNIV,Y             \ Get the high byte of the address of the X-th ship
 STA INF                \ from UNIV and store it in INF

 LDA UNIV+1,Y           \ Get the low byte of the address of the X-th ship
 STA INF+1              \ from UNIV and store it in INF

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: NWSHP
\       Type: Subroutine
\   Category: Universe
\    Summary: Add a new ship to our local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ This creates a new block of ship data in the K% workspace, allocates a new
\ block in the ship line heap at WP, adds the new ship's type into the first
\ empty slot in FRIN, and adds a pointer to the ship data into UNIV. If there
\ isn't enough free memory for the new ship, it isn't added.
\
\ Arguments:
\
\   A                   The type of the ship to add (see variable XX21 for a
\                       list of ship types)
\
\ Returns:
\
\   C flag              Set if the ship was successfully added, clear if it
\                       wasn't (as there wasn't enough free memory)
\
\   INF                 Points to the new ship's data block in K%
\
\ ******************************************************************************

.NWSHP

 STA T                  \ Store the ship type in location T

 LDX #0                 \ Before we can add a new ship, we need to check
                        \ whether we have an empty slot we can put it in. To do
                        \ this, we need to loop through all the slots to look
                        \ for an empty one, so set a counter in X that starts
                        \ from the first slot at 0. When ships are killed, then
                        \ the slots are shuffled down by the KILLSHP routine, so
                        \ the first empty slot will always come after the last
                        \ filled slot. This allows us to tack the new ship's
                        \ data block and ship line heap onto the end of the
                        \ existing ship data and heap, as shown in the memory
                        \ map below

.NWL1

 LDA FRIN,X             \ Load the ship type for the X-th slot

 BEQ NW1                \ If it is zero, then this slot is empty and we can use
                        \ it for our new ship, so jump down to NW1

 INX                    \ Otherwise increment X to point to the next slot

 CPX #NOSH              \ If we haven't reached the last slot yet, loop back up
 BCC NWL1               \ to NWL1 to check the next slot (note that this means
                        \ only slots from 0 to #NOSH - 1 are populated by this
                        \ routine, but there is one more slot reserved in FRIN,
                        \ which is used to identify the end of the slot list
                        \ when shuffling the slots down in the KILLSHP routine)

.NW3

 CLC                    \ Otherwise we don't have an empty slot, so we can't
 RTS                    \ add a new ship, so clear the C flag to indicate that
                        \ we have not managed to create the new ship, and return
                        \ from the subroutine

.NW1

                        \ If we get here, then we have found an empty slot at
                        \ index X, so we can go ahead and create our new ship.
                        \ We do that by creating a ship data block at INWK and,
                        \ when we are done, copying the block from INWK into
                        \ the K% workspace (specifically, to INF)

 JSR GINF               \ Get the address of the data block for ship slot X
                        \ (which is in workspace K%) and store it in INF

 LDA T                  \ If the type of ship that we want to create is
 BMI NW2                \ negative, then this indicates a planet or sun, so
                        \ jump down to NW2, as the next section sets up a ship
                        \ data block, which doesn't apply to planets and suns,
                        \ as they don't have things like shields, missiles,
                        \ vertices and edges

                        \ This is a ship, so first we need to set up various
                        \ pointers to the ship blueprint we will need. The
                        \ blueprints for each ship type in Elite are stored
                        \ in a table at location XX21, so refer to the comments
                        \ on that variable for more details on the data we're
                        \ about to access

 ASL A                  \ Set Y = ship type * 2
 TAY

 LDA XX21-2,Y           \ The ship blueprints at XX21 start with a lookup
 STA XX0                \ table that points to the individual ship blueprints,
                        \ so this fetches the low byte of this particular ship
                        \ type's blueprint and stores it in XX0

 LDA XX21-1,Y           \ Fetch the high byte of this particular ship type's
 STA XX0+1              \ blueprint and store it in XX0+1, so XX0(1 0) now
                        \ contains the address of this ship's blueprint

                        \ We now want to allocate space for a heap that we can
                        \ use to store the lines we draw for our new ship (so it
                        \ can easily be erased from the screen again). SLSP
                        \ points to the start of the current heap space, and we
                        \ can extend it downwards with the heap for our new ship
                        \ (as the heap space always ends just before the WP
                        \ workspace)

 LDY #5                 \ Fetch ship blueprint byte #5, which contains the
 LDA (XX0),Y            \ maximum heap size required for plotting the new ship,
 STA T1                 \ and store it in T1

 LDA SLSP               \ Take the 16-bit address in SLSP and subtract T1,
 SEC                    \ storing the 16-bit result in INWK(34 33), so this now
 SBC T1                 \ points to the start of the line heap for our new ship
 STA INWK+33
 LDA SLSP+1
 SBC #0
 STA INWK+34

                        \ We now need to check that there is enough free space
                        \ for both this new line heap and the new data block
                        \ for our ship. In memory, this is the layout of the
                        \ ship data blocks and ship line heaps:
                        \
                        \   +-----------------------------------+   &0F34
                        \   |                                   |
                        \   | WP workspace                      |
                        \   |                                   |
                        \   +-----------------------------------+   &0D40 = WP
                        \   |                                   |
                        \   | Current ship line heap            |
                        \   |                                   |
                        \   +-----------------------------------+   SLSP
                        \   |                                   |
                        \   | Proposed heap for new ship        |
                        \   |                                   |
                        \   +-----------------------------------+   INWK(34 33)
                        \   |                                   |
                        \   .                                   .
                        \   .                                   .
                        \   .                                   .
                        \   .                                   .
                        \   .                                   .
                        \   |                                   |
                        \   +-----------------------------------+   INF + NI%
                        \   |                                   |
                        \   | Proposed data block for new ship  |
                        \   |                                   |
                        \   +-----------------------------------+   INF
                        \   |                                   |
                        \   | Existing ship data blocks         |
                        \   |                                   |
                        \   +-----------------------------------+   &0900 = K%
                        \
                        \ So, to work out if we have enough space, we have to
                        \ make sure there is room between the end of our new
                        \ ship data block at INF + NI%, and the start of the
                        \ proposed heap for our new ship at the address we
                        \ stored in INWK(34 33). Or, to put it another way, we
                        \ and to make sure that:
                        \
                        \   INWK(34 33) > INF + NI%
                        \
                        \ which is the same as saying:
                        \
                        \   INWK+33 - INF > NI%
                        \
                        \ because INWK is in zero page, so INWK+34 = 0

 LDA INWK+33            \ Calculate INWK+33 - INF, again using 16-bit
\SEC                    \ arithmetic, and put the result in (A Y), so the high
 SBC INF                \ byte is in A and the low byte in Y. The SEC
 TAY                    \ instruction is commented out in the original source;
 LDA INWK+34            \ as the previous subtraction will never underflow, it
 SBC INF+1              \ is superfluous

 BCC NW3+1              \ If we have an underflow from the subtraction, then
                        \ INF > INWK+33 and we definitely don't have enough
                        \ room for this ship, so jump to NW3+1, which returns
                        \ from the subroutine (with the C flag already cleared)

 BNE NW4                \ If the subtraction of the high bytes in A is not
                        \ zero, and we don't have underflow, then we definitely
                        \ have enough space, so jump to NW4 to continue setting
                        \ up the new ship

 CPY #NI%               \ Otherwise the high bytes are the same in our
 BCC NW3+1              \ subtraction, so now we compare the low byte of the
                        \ result (which is in Y) with NI%. This is the same as
                        \ doing INWK+33 - INF > NI% (see above). If this isn't
                        \ true, the C flag will be clear and we don't have
                        \ enough space, so we jump to NW3+1, which returns
                        \ from the subroutine (with the C flag already cleared)

.NW4

 LDA INWK+33            \ If we get here then we do have enough space for our
 STA SLSP               \ new ship, so store the new bottom of the ship line
 LDA INWK+34            \ heap (i.e. INWK+33) in SLSP, doing both the high and
 STA SLSP+1             \ low bytes

.NW6

 LDY #14                \ Fetch ship blueprint byte #14, which contains the
 LDA (XX0),Y            \ ship's energy, and store it in byte #35
 STA INWK+35

 LDY #19                \ Fetch ship blueprint byte #19, which contains the
 LDA (XX0),Y            \ number of missiles and laser power, and AND with %111
 AND #%00000111         \ to extract the number of missiles before storing in
 STA INWK+31            \ byte #31

 LDA T                  \ Restore the ship type we stored above

.NW2

 STA FRIN,X             \ Store the ship type in the X-th byte of FRIN, so the
                        \ this slot is now shown as occupied in the index table

 TAX                    \ Copy the ship type into X

 BMI P%+5               \ If the ship type is negative (planet or sun), then
                        \ skip the following instruction

 INC MANY,X             \ Increment the total number of ships of type X

 LDY #(NI%-1)           \ The final step is to copy the new ship's data block
                        \ from INWK to INF, so set up a counter for NI% bytes
                        \ in Y

.NWL3

 LDA INWK,Y             \ Load the Y-th byte of INWK and store in the Y-th byte
 STA (INF),Y            \ of the workspace pointed to by INF

 DEY                    \ Decrement the loop counter

 BPL NWL3               \ Loop back for the next byte until we have copied them
                        \ all over

 SEC                    \ We have successfully created our new ship, so set the
                        \ C flag to indicate success

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SUN (Part 1 of 4)
\       Type: Subroutine
\   Category: Drawing suns
\    Summary: Draw the sun: Set up all the variables needed
\  Deep dive: Drawing the sun
\
\ ------------------------------------------------------------------------------
\
\ Draw a new sun with radius K at pixel coordinate (K3, K4), removing the old
\ sun if there is one. This routine is used to draw the sun, as well as the
\ star systems on the Short-range Chart.
\
\ The first part sets up all the variables needed to draw the new sun.
\
\ Arguments:
\
\   K                   The new sun's radius
\
\   K3(1 0)             Pixel x-coordinate of the centre of the new sun
\
\   K4(1 0)             Pixel y-coordinate of the centre of the new sun
\
\   SUNX(1 0)           The x-coordinate of the vertical centre axis of the old
\                       sun (the one currently on-screen)
\
\ Other entry points:
\
\   RTS2                Contains an RTS
\
\ ******************************************************************************

.PLF3

                        \ This is called from below to negate X and set A to
                        \ &FF, for when the new sun's centre is off the bottom
                        \ of the screen (so we don't need to draw its bottom
                        \ half)

 TXA                    \ Negate X using two's complement, so X = ~X + 1
 EOR #%11111111         \
 CLC                    \ We do this because X is negative at this point, as it
 ADC #1                 \ is calculated as 191 - the y-coordinate of the sun's
 TAX                    \ centre, and the centre is off the bottom of the
                        \ screen, past 191. So we negate it to make it positive

.PLF17

                        \ This is called from below to set A to &FF, for when
                        \ the new sun's centre is right on the bottom of the
                        \ screen (so we don't need to draw its bottom half)

 LDA #&FF               \ Set A = &FF

 BNE PLF5               \ Jump to PLF5 (this BNE is effectively a JMP as A is
                        \ never zero)

.SUN

 LDA #1                 \ Set LSX = 1 to indicate the sun line heap is about to
 STA LSX                \ be filled up

 JSR CHKON              \ Call CHKON to check whether any part of the new sun's
                        \ circle appears on-screen, and of it does, set P(2 1)
                        \ to the maximum y-coordinate of the new sun on-screen

 LDA #0                 \ Set A = 0

 LDX K                  \ Set X = K = radius of the new sun

 CPX #96                \ If X >= 96, set the C flag and rotate it into bit 0
 ROL A                  \ of A, otherwise rotate a 0 into bit 0

 CPX #40                \ If X >= 40, set the C flag and rotate it into bit 0
 ROL A                  \ of A, otherwise rotate a 0 into bit 0

 CPX #16                \ If X >= 16, set the C flag and rotate it into bit 0
 ROL A                  \ of A, otherwise rotate a 0 into bit 0

                        \ By now, A contains the following:
                        \
                        \   * If radius is 96-255 then A = %111 = 7
                        \
                        \   * If radius is 40-95  then A = %11  = 3
                        \
                        \   * If radius is 16-39  then A = %1   = 1
                        \
                        \   * If radius is 0-15   then A = %0   = 0
                        \
                        \ The value of A determines the size of the new sun's
                        \ ragged fringes - the bigger the sun, the bigger the
                        \ fringes

.PLF18

 STA CNT                \ Store the fringe size in CNT

                        \ We now calculate the highest pixel y-coordinate of the
                        \ new sun, given that P(2 1) contains the 16-bit maximum
                        \ y-coordinate of the new sun on-screen

 LDA #2*Y-1             \ #Y is the y-coordinate of the centre of the space
                        \ view, so this sets Y to the y-coordinate of the bottom
                        \ of the space view, i.e. 191

 LDX P+2                \ If P+2 is non-zero, the maximum y-coordinate is off
 BNE PLF2               \ the bottom of the screen, so skip to PLF2 with A = 191

 CMP P+1                \ If A < P+1, the maximum y-coordinate is underneath the
 BCC PLF2               \ the dashboard, so skip to PLF2 with A = 191

 LDA P+1                \ Set A = P+1, the low byte of the maximum y-coordinate
                        \ of the sun on-screen

 BNE PLF2               \ If A is non-zero, skip to PLF2 as it contains the
                        \ value we are after

 LDA #1                 \ Otherwise set A = 1, the top line of the screen

.PLF2

 STA TGT                \ Set TGT to A, the maximum y-coordinate of the sun on
                        \ screen

                        \ We now calculate the number of lines we need to draw
                        \ and the direction in which we need to draw them, both
                        \ from the centre of the new sun

 LDA #2*Y-1             \ Set (A X) = y-coordinate of bottom of screen - K4(1 0)
 SEC                    \
 SBC K4                 \ Starting with the low bytes
 TAX

 LDA #0                 \ And then doing the high bytes, so (A X) now contains
 SBC K4+1               \ the number of lines between the centre of the sun and
                        \ the bottom of the screen. If it is positive then the
                        \ centre of the sun is above the bottom of the screen,
                        \ if it is negative then the centre of the sun is below
                        \ the bottom of the screen

 BMI PLF3               \ If A < 0, then this means the new sun's centre is off
                        \ the bottom of the screen, so jump up to PLF3 to negate
                        \ the height in X (so it becomes positive), set A to &FF
                        \ and jump down to PLF5

 BNE PLF4               \ If A > 0, then the new sun's centre is at least a full
                        \ screen above the bottom of the space view, so jump
                        \ down to PLF4 to set X = radius and A = 0

 INX                    \ Set the flags depending on the value of X
 DEX

 BEQ PLF17              \ If X = 0 (we already know A = 0 by this point) then
                        \ jump up to PLF17 to set A to &FF before jumping down
                        \ to PLF5

 CPX K                  \ If X < the radius in K, jump down to PLF5, so if
 BCC PLF5               \ X >= the radius in K, we set X = radius and A = 0

.PLF4

 LDX K                  \ Set X to the radius

 LDA #0                 \ Set A = 0

.PLF5

 STX V                  \ Store the height in V

 STA V+1                \ Store the direction in V+1

 LDA K                  \ Set (A P) = K * K
 JSR SQUA2

 STA K2+1               \ Set K2(1 0) = (A P) = K * K
 LDA P
 STA K2

                        \ By the time we get here, the variables should be set
                        \ up as shown in the header for part 3 below

\ ******************************************************************************
\
\       Name: SUN (Part 2 of 4)
\       Type: Subroutine
\   Category: Drawing suns
\    Summary: Draw the sun: Start from bottom of screen and erase the old sun
\  Deep dive: Drawing the sun
\
\ ------------------------------------------------------------------------------
\
\ This part erases the old sun, starting at the bottom of the screen and working
\ upwards until we reach the bottom of the new sun.
\
\ ******************************************************************************

 LDY #2*Y-1             \ Set Y = y-coordinate of the bottom of the screen,
                        \ which we use as a counter in the following routine to
                        \ redraw the old sun

 LDA SUNX               \ Set YY(1 0) = SUNX(1 0), the x-coordinate of the
 STA YY                 \ vertical centre axis of the old sun that's currently
 LDA SUNX+1             \ on-screen
 STA YY+1

.PLFL2

 CPY TGT                \ If Y = TGT, we have reached the line where we will
 BEQ PLFL               \ start drawing the new sun, so there is no need to
                        \ keep erasing the old one, so jump down to PLFL

 LDA LSO,Y              \ Fetch the Y-th point from the sun line heap, which
                        \ gives us the half-width of the old sun's line on this
                        \ line of the screen

 BEQ PLF13              \ If A = 0, skip the following call to HLOIN2 as there
                        \ is no sun line on this line of the screen

 JSR HLOIN2             \ Call HLOIN2 to draw a horizontal line on pixel line Y,
                        \ with centre point YY(1 0) and half-width A, and remove
                        \ the line from the sun line heap once done

.PLF13

 DEY                    \ Decrement the loop counter

 BNE PLFL2              \ Loop back for the next line in the line heap until
                        \ we have either gone through the entire heap, or
                        \ reached the bottom row of the new sun

\ ******************************************************************************
\
\       Name: SUN (Part 3 of 4)
\       Type: Subroutine
\   Category: Drawing suns
\    Summary: Draw the sun: Continue to move up the screen, drawing the new sun
\  Deep dive: Drawing the sun
\
\ ------------------------------------------------------------------------------
\
\ This part draws the new sun. By the time we get to this point, the following
\ variables should have been set up by parts 1 and 2:
\
\   V                   As we draw lines for the new sun, V contains the
\                       vertical distance between the line we're drawing and the
\                       centre of the new sun. As we draw lines and move up the
\                       screen, we either decrement (bottom half) or increment
\                       (top half) this value. See the deep dive on "Drawing the
\                       sun" to see a diagram that shows V in action
\
\   V+1                 This determines which half of the new sun we are drawing
\                       as we work our way up the screen, line by line:
\
\                         * 0 means we are drawing the bottom half, so the lines
\                           get wider as we work our way up towards the centre,
\                           at which point we will move into the top half, and
\                           V+1 will switch to &FF
\
\                         * &FF means we are drawing the top half, so the lines
\                           get smaller as we work our way up, away from the
\                           centre
\
\   TGT                 The maximum y-coordinate of the new sun on-screen (i.e.
\                       the screen y-coordinate of the bottom row of the new
\                       sun)
\
\   CNT                 The fringe size of the new sun
\
\   K2(1 0)             The new sun's radius squared, i.e. K^2
\
\   Y                   The y-coordinate of the bottom row of the new sun
\
\ ******************************************************************************

.PLFL

 LDA V                  \ Set (T P) = V * V
 JSR SQUA2              \           = V^2
 STA T

 LDA K2                 \ Set (R Q) = K^2 - V^2
 SEC                    \
 SBC P                  \ First calculating the low bytes
 STA Q

 LDA K2+1               \ And then doing the high bytes
 SBC T
 STA R

 STY Y1                 \ Store Y in Y1, so we can restore it after the call to
                        \ LL5

 JSR LL5                \ Set Q = SQRT(R Q)
                        \       = SQRT(K^2 - V^2)
                        \
                        \ So Q contains the half-width of the new sun's line at
                        \ height V from the sun's centre - in other words, it
                        \ contains the half-width of the sun's line on the
                        \ current pixel row Y

 LDY Y1                 \ Restore Y from Y1

 JSR DORND              \ Set A and X to random numbers

 AND CNT                \ Reduce A to a random number in the range 0 to CNT,
                        \ where CNT is the fringe size of the new sun

 CLC                    \ Set A = A + Q
 ADC Q                  \
                        \ So A now contains the half-width of the sun on row
                        \ V, plus a random variation based on the fringe size

 BCC PLF44              \ If the above addition did not overflow, skip the
                        \ following instruction

 LDA #255               \ The above overflowed, so set the value of A to 255

                        \ So A contains the half-width of the new sun on pixel
                        \ line Y, changed by a random amount within the size of
                        \ the sun's fringe

.PLF44

 LDX LSO,Y              \ Set X to the line heap value for the old sun's line
                        \ at row Y

 STA LSO,Y              \ Store the half-width of the new row Y line in the line
                        \ heap

 BEQ PLF11              \ If X = 0 then there was no sun line on pixel row Y, so
                        \ jump to PLF11

 LDA SUNX               \ Set YY(1 0) = SUNX(1 0), the x-coordinate of the
 STA YY                 \ vertical centre axis of the old sun that's currently
 LDA SUNX+1             \ on-screen
 STA YY+1

 TXA                    \ Transfer the line heap value for the old sun's line
                        \ from X into A

 JSR EDGES              \ Call EDGES to calculate X1 and X2 for the horizontal
                        \ line centred on YY(1 0) and with half-width A, i.e.
                        \ the line for the old sun

 LDA X1                 \ Store X1 and X2, the ends of the line for the old sun,
 STA XX                 \ in XX and XX+1
 LDA X2
 STA XX+1

 LDA K3                 \ Set YY(1 0) = K3(1 0), the x-coordinate of the centre
 STA YY                 \ of the new sun
 LDA K3+1
 STA YY+1

 LDA LSO,Y              \ Fetch the half-width of the new row Y line from the
                        \ line heap (which we stored above)

 JSR EDGES              \ Call EDGES to calculate X1 and X2 for the horizontal
                        \ line centred on YY(1 0) and with half-width A, i.e.
                        \ the line for the new sun

 BCS PLF23              \ If the C flag is set, the new line doesn't fit on the
                        \ screen, so jump to PLF23 to just draw the old line
                        \ without drawing the new one

                        \ At this point the old line is from XX to XX+1 and the
                        \ new line is from X1 to X2, and both fit on-screen. We
                        \ now want to remove the old line and draw the new one.
                        \ We could do this by simply drawing the old one then
                        \ drawing the new one, but instead Elite does this by
                        \ drawing first from X1 to XX and then from X2 to XX+1,
                        \ which you can see in action by looking at all the
                        \ permutations below of the four points on the line and
                        \ imagining what happens if you draw from X1 to XX and
                        \ X2 to XX+1 using EOR logic. The six possible
                        \ permutations are as follows, along with the result of
                        \ drawing X1 to XX and then X2 to XX+1:
                        \
                        \   X1    X2    XX____XX+1      ->      +__+  +  +
                        \
                        \   X1    XX____X2____XX+1      ->      +__+__+  +
                        \
                        \   X1    XX____XX+1  X2        ->      +__+__+__+
                        \
                        \   XX____X1____XX+1  X2        ->      +  +__+__+
                        \
                        \   XX____XX+1  X1    X2        ->      +  +  +__+
                        \
                        \   XX____X1____X2____XX+1      ->      +  +__+  +
                        \
                        \ They all end up with a line between X1 and Y1, which
                        \ is what we want. There's probably a mathematical proof
                        \ of why this works somewhere, but the above is probably
                        \ easier to follow.
                        \
                        \ We can draw from X1 to XX and X2 to XX+1 by swapping
                        \ XX and X2 and drawing from X1 to X2, and then drawing
                        \ from XX to XX+1, so let's do this now

 LDA X2                 \ Swap XX and X2
 LDX XX
 STX X2
 STA XX

 JSR HLOIN              \ Draw a horizontal line from (X1, Y1) to (X2, Y1)

.PLF23

                        \ If we jump here from the BCS above when there is no
                        \ new line this will just draw the old line

 LDA XX                 \ Set X1 = XX
 STA X1

 LDA XX+1               \ Set X2 = XX+1
 STA X2

.PLF16

 JSR HLOIN              \ Draw a horizontal line from (X1, Y1) to (X2, Y1)

.PLF6

 DEY                    \ Decrement the line number in Y to move to the line
                        \ above

 BEQ PLF8               \ If we have reached the top of the screen, jump to PLF8
                        \ as we are done drawing (the top line of the screen is
                        \ the border, so we don't draw there)

 LDA V+1                \ If V+1 is non-zero then we are doing the top half of
 BNE PLF10              \ the new sun, so jump down to PLF10 to increment V and
                        \ decrease the width of the line we draw

 DEC V                  \ Decrement V, the height of the sun that we use to work
                        \ out the width, so this makes the line get wider, as we
                        \ move up towards the sun's centre

 BNE PLFL               \ If V is non-zero, jump back up to PLFL to do the next
                        \ screen line up

 DEC V+1                \ Otherwise V is 0 and we have reached the centre of the
                        \ sun, so decrement V+1 to -1 so we start incrementing V
                        \ each time, thus doing the top half of the new sun

.PLFLS

 JMP PLFL               \ Jump back up to PLFL to do the next screen line up

.PLF11

                        \ If we get here then there is no old sun line on this
                        \ line, so we can just draw the new sun's line. The new

 LDX K3                 \ Set YY(1 0) = K3(1 0), the x-coordinate of the centre
 STX YY                 \ of the new sun's line
 LDX K3+1
 STX YY+1

 JSR EDGES              \ Call EDGES to calculate X1 and X2 for the horizontal
                        \ line centred on YY(1 0) and with half-width A, i.e.
                        \ the line for the new sun

 BCC PLF16              \ If the line is on-screen, jump up to PLF16 to draw the
                        \ line and loop round for the next line up

 LDA #0                 \ The line is not on-screen, so set the line heap for
 STA LSO,Y              \ line Y to 0, which means there is no sun line here

 BEQ PLF6               \ Jump up to PLF6 to loop round for the next line up
                        \ (this BEQ is effectively a JMP as A is always zero)

.PLF10

 LDX V                  \ Increment V, the height of the sun that we use to work
 INX                    \ out the width, so this makes the line get narrower, as
 STX V                  \ we move up and away from the sun's centre

 CPX K                  \ If V <= the radius of the sun, we still have lines to
 BCC PLFLS              \ draw, so jump up to PLFL (via PLFLS) to do the next
 BEQ PLFLS              \ screen line up

\ ******************************************************************************
\
\       Name: SUN (Part 4 of 4)
\       Type: Subroutine
\   Category: Drawing suns
\    Summary: Draw the sun: Continue to the top of the screen, erasing old sun
\  Deep dive: Drawing the sun
\
\ ------------------------------------------------------------------------------
\
\ This part erases any remaining traces of the old sun, now that we have drawn
\ all the way to the top of the new sun.
\
\ ******************************************************************************

 LDA SUNX               \ Set YY(1 0) = SUNX(1 0), the x-coordinate of the
 STA YY                 \ vertical centre axis of the old sun that's currently
 LDA SUNX+1             \ on-screen
 STA YY+1

.PLFL3

 LDA LSO,Y              \ Fetch the Y-th point from the sun line heap, which
                        \ gives us the half-width of the old sun's line on this
                        \ line of the screen

 BEQ PLF9               \ If A = 0, skip the following call to HLOIN2 as there
                        \ is no sun line on this line of the screen

 JSR HLOIN2             \ Call HLOIN2 to draw a horizontal line on pixel line Y,
                        \ with centre point YY(1 0) and half-width A, and remove
                        \ the line from the sun line heap once done

.PLF9

 DEY                    \ Decrement the line number in Y to move to the line
                        \ above

 BNE PLFL3              \ Jump up to PLFL3 to redraw the next line up, until we
                        \ have reached the top of the screen

.PLF8

                        \ If we get here, we have successfully made it from the
                        \ bottom line of the screen to the top, and the old sun
                        \ has been replaced by the new one

 CLC                    \ Clear the C flag to indicate success in drawing the
                        \ sun

 LDA K3                 \ Set SUNX(1 0) = K3(1 0)
 STA SUNX
 LDA K3+1
 STA SUNX+1

.RTS2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: CIRCLE2
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw a circle (for the planet or chart)
\  Deep dive: Drawing circles
\
\ ------------------------------------------------------------------------------
\
\ Draw a circle with the centre at (K3, K4) and radius K. Used to draw the
\ planet and the chart circles.
\
\ Arguments:
\
\   STP                 The step size for the circle
\
\   K                   The circle's radius
\
\   K3(1 0)             Pixel x-coordinate of the centre of the circle
\
\   K4(1 0)             Pixel y-coordinate of the centre of the circle
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.CIRCLE2

 LDX #&FF               \ Set FLAG = &FF to reset the ball line heap in the call
 STX FLAG               \ to the BLINE routine below

 INX                    \ Set CNT = 0, our counter that goes up to 64, counting
 STX CNT                \ segments in our circle

.PLL3

 LDA CNT                \ Set A = CNT

 JSR FMLTU2             \ Call FMLTU2 to calculate:
                        \
                        \   A = K * sin(A)
                        \     = K * sin(CNT)

 LDX #0                 \ Set T = 0, so we have the following:
 STX T                  \
                        \   (T A) = K * sin(CNT)
                        \
                        \ which is the x-coordinate of the circle for this count

 LDX CNT                \ If CNT < 33 then jump to PL37, as this is the right
 CPX #33                \ half of the circle and the sign of the x-coordinate is
 BCC PL37               \ correct

 EOR #%11111111         \ This is the left half of the circle, so we want to
 ADC #0                 \ flip the sign of the x-coordinate in (T A) using two's
 TAX                    \ complement, so we start with the low byte and store it
                        \ in X (the ADC adds 1 as we know the C flag is set)

 LDA #&FF               \ And then we flip the high byte in T
 ADC #0
 STA T

 TXA                    \ Finally, we restore the low byte from X, so we have
                        \ now negated the x-coordinate in (T A)

 CLC                    \ Clear the C flag so we can do some more addition below

.PL37

 ADC K3                 \ We now calculate the following:
 STA K6                 \
                        \   K6(1 0) = (T A) + K3(1 0)
                        \
                        \ to add the coordinates of the centre to our circle
                        \ point, starting with the low bytes

 LDA K3+1               \ And then doing the high bytes, so we now have:
 ADC T                  \
 STA K6+1               \   K6(1 0) = K * sin(CNT) + K3(1 0)
                        \
                        \ which is the result we want for the x-coordinate

 LDA CNT                \ Set A = CNT + 16
 CLC
 ADC #16

 JSR FMLTU2             \ Call FMLTU2 to calculate:
                        \
                        \   A = K * sin(A)
                        \     = K * sin(CNT + 16)
                        \     = K * cos(CNT)

 TAX                    \ Set X = A
                        \       = K * cos(CNT)

 LDA #0                 \ Set T = 0, so we have the following:
 STA T                  \
                        \   (T X) = K * cos(CNT)
                        \
                        \ which is the y-coordinate of the circle for this count

 LDA CNT                \ Set A = (CNT + 15) mod 64
 ADC #15
 AND #63

 CMP #33                \ If A < 33 (i.e. CNT is 0-16 or 48-64) then jump to
 BCC PL38               \ PL38, as this is the bottom half of the circle and the
                        \ sign of the y-coordinate is correct

 TXA                    \ This is the top half of the circle, so we want to
 EOR #%11111111         \ flip the sign of the y-coordinate in (T X) using two's
 ADC #0                 \ complement, so we start with the low byte in X (the
 TAX                    \ ADC adds 1 as we know the C flag is set)

 LDA #&FF               \ And then we flip the high byte in T, so we have
 ADC #0                 \ now negated the y-coordinate in (T X)
 STA T

 CLC                    \ Clear the C flag so we can do some more addition below

.PL38

 JSR BLINE              \ Call BLINE to draw this segment, which also increases
                        \ CNT by STP, the step size

 CMP #65                \ If CNT >=65 then skip the next instruction
 BCS P%+5

 JMP PLL3               \ Jump back for the next segment

 CLC                    \ Clear the C flag to indicate success

 RTS                    \ Return from the subroutine

.EDGES

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

.CHKON

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
 LDA KL
 RTS

.keybd_dirn

 LDA KL
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
 JSR DKS4
 BPL not_shift
 ASL &D1
 ASL &D1
 TYA
 ASL A
 ASL A
 TAY

.not_shift

 LDX &D1
 LDA KL
 RTS

.set_home

 LDX #&01

.l_3650

 LDA QQ0,X
 STA QQ9,X
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

.RES2

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

 JSR WPSHPS
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
\ Set A and X to random numbers. The C and V flags are also set randomly.
\
\ ******************************************************************************

.DORND

 LDA RAND               \ r2´ = ((r0 << 1) mod 256) + C
 ROL A                  \ r0´ = r2´ + r2 + bit 7 of r0
 TAX
 ADC RAND+2             \ C = C flag from r0´ calculation
 STA RAND
 STX RAND+2

 LDA RAND+1             \ A = r1´ = r1 + r3 + C
 TAX                    \ X = r3´ = r1
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 RTS                    \ Return from the subroutine

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
 JSR DELAY
 JSR get_dirn

.FRCE

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
 JMP TT22

.not_long

 CMP #&74
 BNE not_short
 JMP TT23

.not_short

 CMP #&75
 BNE not_data
 JSR CTRL
 BPL jump_data
 JMP launch

.jump_data

 JSR TT111
 JMP TT25

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
 JSR CLYNS
 LDA #&0F
 STA XC
 LDA #&CD
 JMP DETOK

.not_hype

 CMP #&32
 BEQ T95
 CMP #&43
 BNE not_find
 LDA &87
 AND #&C0
 BEQ not_map
 JMP HME2

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
 JSR TT103
 JSR set_home
 JSR TT103

.not_cour

 JSR TT16

.not_map

 RTS

.not_home

 CMP #&21
 BNE not_cour
 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ not_cour
 JSR TT103
 LDA cmdr_courx
 STA QQ9
 LDA cmdr_coury
 STA QQ10
 JSR TT103

.T95

 LDA &87
 AND #&C0
 BEQ not_map
 JSR hm
 STA QQ17
 JSR cpl
 LDA #&80
 STA QQ17
 LDA #&01
 STA XC
 INC YC
 JMP TT146

.brkd

 EQUB &00

.jmp_escape

 JMP escape

.BRBR

 DEC brkd
 BNE jmp_escape
 JSR RES2

.BAY

 LDA #&FF
 STA &8E
 LDA #&73
 JMP FRCE

.MT26

 LDA #&81
 STA &FE4E
 JSR FLKB
 LDX #LO(word_0)
 LDY #HI(word_0)
 LDA #&00
 JSR osword
 BCC l_39e1
 LDY #&00

.l_39e1

 LDA #&01
 STA &FE4E
 JMP FEED

.word_0

 EQUW &004B
 EQUB &09, &21, &7B

.clr_ships

 LDX #&3A
 LDA #&00

.l_39f2

 STA FRIN,X
 DEX
 BPL l_39f2
 RTS

.ZES1

 LDY #&00
 STY SC

.ZES2

 LDA #&00
 STX SC+&01

.l_3a07

 STA (SC),Y
 INY
 BNE l_3a07
 RTS

.l_3bd6

 LDA &34
 JSR SQUA
 STA &82
 LDA &1B
 STA &81
 LDA &35
 JSR SQUA
 STA &D1
 LDA &1B
 ADC &81
 STA &81
 LDA &D1
 ADC &82
 STA &82
 LDA &36
 JSR SQUA
 STA &D1
 LDA &1B
 ADC &81
 STA &81
 LDA &D1
 ADC &82
 STA &82
 JSR LL5
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

.RDKEY

 LDX #&10

.scan_loop

 JSR DKS4
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
 BNE NOISE

.BEEP

 LDA #&20

.NOISE

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

.CTRL

 LDX #&01

.DKS4

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
 JSR BELL
 JSR DELAY
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

 JSR RDKEY
 STX KL
 CPX #&69
 BNE no_freeze

.no_thaw

 JSR WSCAN
 JSR RDKEY
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

.TT217

 STY &85

.get_key

 LDY #&02
 JSR DELAY
 JSR RDKEY
 BNE get_key

.press

 JSR RDKEY
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
 STX QQ17
 LDY #&09
 STY XC
 LDY #&16
 STY YC
 CPX &034A
 BNE l_3d77
 STY &034A
 STA &03A4

.l_3d99

 JSR TT27
 LSR &034B
 BEQ frz_ret
 LDA #&FD
 JMP TT27

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

.TIDY

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
 JSR MULT12
 LDX &54
 LDA &58
 JSR TIS1
 EOR #&80
 STA &5C
 LDA &56
 JSR MULT12
 LDX &50
 LDA &5A
 JSR TIS1
 EOR #&80
 STA &5E
 LDA &58
 JSR MULT12
 LDX &52
 LDA &56
 JSR TIS1
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
 JSR MULT12
 LDX &50,Y
 STX &81
 LDA &56,Y
 JSR MAD
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

.LL5

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

.LL28

 CMP &81
 BCS l_3f93
 LDX #&FE
 STX &82

.LL31

 ASL A
 BCS l_3f8b
 CMP &81
 BCC l_3f86
 SBC &81

.l_3f86

 ROL &82
 BCS LL31
 RTS

.l_3f8b

 SBC &81
 SEC
 ROL &82
 BCS LL31
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
 JSR FMLTU
 STA &D1
 LDA &35
 EOR &0A,X
 STA &83
 LDA &36
 STA &81
 LDA &0B,X
 JSR FMLTU
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
 JSR FMLTU
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
 JSR DORND
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
 JMP TT48

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
 JSR LL28
 LDX &82
 STX &09,Y
 DEY
 DEY
 BPL l_40d2
 LDX #&08

.l_40e7

 LDA &46,X
 STA QQ17,X
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
 ROR QQ17
 LSR A
 ROR &78
 TAY
 BNE l_411c

.l_412b

 STX &86
 LDA &7A
 STA &39
 LDA QQ17
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
 STA QQ17
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
 LDA QQ17
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

 LSR QQ17
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
 LDA QQ17
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
 JSR FMLTU
 STA &D1
 LDA &3B
 EOR &35
 STA &83
 LDA &3C
 STA &81
 LDA &36
 JSR FMLTU
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
 JSR FMLTU
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
 JSR LL28
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

 JSR LL28

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

 JSR LL28

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
 JMP TT48

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

 JSR LL145
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

.LL145

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
 JSR LL28
 JMP l_466b

.l_4660

 LDA &3E
 STA &81
 LDA &3C
 JSR LL28
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
 JSR LOIN
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

 JSR dn2
 JMP BAY

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
 JSR TT66
 JSR MT1
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
 STA XC
 PLA
 JSR DETOK3
 JSR NLIN4
 JSR init_ship
 LDA #&60
 STA &54
 LDA #&B0
 STA &4D
 LDX #&7F
 STX &63
 STX &64
 INX
 STA QQ17
 LDA &8C
 JSR write_card
 LDX &8C
 LDA ship_posn,X
 JSR NWSHP

.l_release

 JSR RDKEY
 BNE l_release

.l_395a

 LDX &8C
 LDA ship_dist,X
 CMP &4D
 BEQ l_3962
 DEC &4D

.l_3962

 JSR MVEIT
 LDA #&80
 STA &4C
 ASL A
 STA &46
 STA &49
 JSR l_400f
 DEC &8A
 JSR WSCAN
 JSR RDKEY
 BEQ l_395a
 JMP BAY

.controls

 LDX #&03
 JSR menu
 ADC #&56
 PHA
 ADC #&04
 PHA
 LDA #&20
 JSR TT66
 JSR MT1
 LDA #&0B
 STA XC
 PLA
 JSR DETOK3
 JSR NLIN4
 JSR MT2
 INC YC
 PLA
 JSR DETOK3
 JMP l_restart

.equip_data

 LDX #&04
 JSR menu
 ADC #&6B
 PHA
 SBC #&0C
 PHA
 LDA #&20
 JSR TT66
 JSR MT1
 LDA #&0B
 STA XC
 PLA
 JSR DETOK3
 JSR NLIN4
 JSR MT2
 JSR MT13
 INC YC
 INC YC
 LDA #&01
 STA XC
 PLA
 JSR DETOK3
 JMP l_restart

.trading

.l_restart

 JSR PAUSE2
 JMP BAY

.write_card

 ASL A
 TAY
 LDA card_addr,Y
 STA &22
 LDA card_addr+1,Y
 STA &23

.card_repeat

 JSR MT1
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
 STA XC
 LDA card_pattern+1,Y
 STA YC
 LDA card_pattern+2,Y
 BEQ card_details
 JSR DETOK3
 INY
 INY
 INY
 BNE card_found

.card_details

 JSR MT2
 LDY #&00

.card_loop

 INY
 LDA (&22),Y
 BEQ card_end
 BMI card_msg
 CMP #&20
 BCC card_macro
 JSR DTS
 JMP card_loop

.card_macro

 JSR DT3
 JMP card_loop

.card_msg

 CMP #&D7
 BCS card_pairs
 AND #&7F
 JSR DETOK3
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
 JSR TT66
 JSR MT1
 PLA
 STA XC
 PLA
 JSR DETOK3
 JSR NLIN4
 JSR MT2
 LDA #&80
 STA QQ17
 INC YC
 LDX #&00

.menu_loop

 STX &89
 JSR TT67
 LDX &89
 INX
 CLC
 JSR pr2
 JSR TT162
 CLC
 LDA &89
 ADC &03AD
 JSR DETOK3
 LDX &89
 INX
 CPX &03AB
 BCC menu_loop
 JSR CLYNS
 PLA
 JSR DETOK3
 LDA #'?'
 JSR DASC
 JSR gnum
 BEQ menu_start
 BCS menu_start
 RTS

.menu_start

 JMP BAY

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

.TKN1

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

.RUTOK

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

.MTIN

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

\ ******************************************************************************
\
\ Save output/1.E.bin
\
\ ******************************************************************************

PRINT "S.1.E ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/1.E.bin", CODE%, P%, LOAD%