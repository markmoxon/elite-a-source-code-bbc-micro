\ ******************************************************************************
\
\ ELITE-A FLIGHT SOURCE
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
\   * output/1.F.bin
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

 \ a.dcode - ELITE III in-flight code

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

 JMP start

.boot_in

 JMP start

.wrch_in

 JMP TT26
 EQUW IRQ1

.brk_in

 JMP brkdst

BRKV = P% - 2

\ a.dcode_1

.l_11f1

 LDX #LO(l_11f8)
 LDY #HI(l_11f8)
 JSR oscli

.l_11f8

 EQUS "L.1.D", &0D

.run_tcode

 LDA #'R'
 STA l_11f8

.l_1220

 JSR RES2
 \	JMP l_11f1
 BMI l_11f1

.l_1228

 LDA &0900
 STA &00
 LDX adval_x
 CPX new_max
 BCC n_highx
 LDX new_max

.n_highx

 CPX new_min
 BCS n_lowx
 LDX new_min

.n_lowx

 JSR cntr
 JSR cntr
 TXA
 EOR #&80
 TAY
 AND #&80
 STA &32
 STX adval_x
 EOR #&80
 STA &33
 TYA
 BPL l_124d
 EOR #&FF
 CLC
 ADC #&01

.l_124d

 LSR A
 LSR A
 CMP #&08
 BCS l_1254
 LSR A

.l_1254

 STA &31
 ORA &32
 STA &8D
 LDX adval_y
 CPX new_max
 BCC n_highy
 LDX new_max

.n_highy

 CPX new_min
 BCS n_lowy
 LDX new_min

.n_lowy

 JSR cntr
 TXA
 EOR #&80
 TAY
 AND #&80
 STX adval_y
 STA &7C
 EOR #&80
 STA &7B
 TYA
 BPL l_1274
 EOR #&FF

.l_1274

 ADC #&04
 LSR A
 LSR A
 LSR A
 LSR A
 CMP #&03
 BCS l_127f
 LSR A

.l_127f

 STA &2B
 ORA &7B
 STA &2A
 \	LDA b_flag
 \	BEQ l_129e
 \	LDX #&03
 \	LDA #&80
 \	JSR osbyte
 \	TYA
 \	LSR A
 \	LSR A
 \	CMP new_speed
 \	BCC l_129a
 \	LDA new_speed
 \l_129a
 \	STA &7D
 \	BNE l_12b6
 \l_129e
 LDA &0302
 BEQ l_12ab
 LDA &7D
 CMP new_speed
 BCC speed_up
 \	BCS l_12ab
 \	INC &7D

.l_12ab

 LDA &0301
 BEQ l_12b6
 DEC &7D
 BNE l_12b6

.speed_up

 INC &7D

.l_12b6

 LDA &030B
 AND cmdr_misl
 BEQ l_12cd
 LDY #&EE
 JSR l_3805
 JSR l_439f
 LDA #&00
 STA target

.l_12cd

 LDA &45
 BPL l_12e3
 LDA &030A
 BEQ l_12e3
 LDX cmdr_misl
 BEQ l_12e3
 STA target
 LDY #&E0
 DEX
 JSR l_383d

.l_12e3

 LDA &030C
 BEQ l_12ef
 LDA &45
 BMI l_1326
 JSR l_252e

.l_12ef

 LDA &0308
 AND cmdr_bomb
 BEQ l_12f7
 \	LDA #&03
 \	JSR TT66
 \	JSR l_2623
 \	JSR RES2
 \	STY &0341
 INC cmdr_bomb
 INC new_hold	\***
 \	JSR l_32c1
 JSR DORND
 STA QQ9	\QQ0
 STX QQ10	\QQ1
 JSR TT111
 JSR hyper_snap

.l_12f7

 LDA &030F
 AND cmdr_dock
 BNE dock_toggle
 \	BEQ l_1331
 \	STA &033F
 \l_1331
 LDA &0310
 BEQ l_1301
 LDA #&00

.dock_toggle

 STA &033F

.l_1301

 LDA &0309
 AND ESCP
 BEQ l_130c
 JMP ESCAPE

.l_130c

 LDA &030E
 BEQ l_1314
 JSR l_434e

.l_1314

 LDA &030D
 AND ECM
 BEQ l_1326
 LDA &30
 BNE l_1326
 DEC &0340
 JSR l_3813

.l_1326

 LDA #&00
 STA &44
 STA &7E
 LDA &7D
 LSR A
 ROR &7E
 LSR A
 ROR &7E
 STA &7F
 LDA &0346
 BNE l_1374
 LDA &0307
 BEQ l_1374
 LDA GNTMP
 CMP #&F2
 BCS l_1374
 LDX VIEW
 LDA LASER,X
 BEQ l_1374
 PHA
 AND #&7F
 STA &0343
 STA &44
 LDA #&00
 JSR l_43f3
 JSR LASLI
 PLA
 BPL l_136f
 LDA #&00

.l_136f

 STA &0346

.l_1374

 LDX #&00

.l_1376

 STX &84
 LDA FRIN,X
 BNE ins_ship
 JMP l_153f

.ins_ship

 STA &8C
 JSR ship_SC
 LDY #&24

.l_1387

 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_1387
 LDA &8C
 BMI l_13b6
 ASL A
 TAY
 LDA &55FE,Y
 STA &1E
 LDA &55FF,Y
 STA &1F

.l_13b6

 JSR MVEIT
 LDY #&24

.l_13bb

 LDA &46,Y
 STA (&20),Y
 DEY
 BPL l_13bb
 LDA &65
 AND #&A0
 JSR l_41bf
 BNE l_141d
 LDA &46
 ORA &49
 ORA &4C
 BMI l_141d
 LDX &8C
 BMI l_141d
 CPX #&02
 BEQ l_1420
 AND #&C0
 BNE l_141d
 CPX #&01
 BEQ l_141d
 LDA BST
 AND &4B
 BPL l_1464
 CPX #&05
 BEQ l_13fd
 LDY #&00
 LDA (&1E),Y
 LSR A
 LSR A
 LSR A
 LSR A
 BEQ l_1464
 ADC #&01
 BNE l_1402

.l_13fd

 JSR DORND
 \	AND #&07
 AND #&0F

.l_1402

 TAX
 JSR l_2aec
 BCS l_1464
 INC QQ20,X
 TXA
 ADC #&D0
 JSR l_45c6
 JSR top_6a

.l_141d

 JMP l_1473

.l_1420

 LDA &0949
 AND #&04
 BNE l_1449
 LDA &54
 CMP #&D6
 BCC l_1449
 LDY #&25
 JSR l_42ae
 LDA &36
 CMP #&56
 BCC l_1449
 LDA &56
 AND #&7F
 CMP #&50
 BCC l_1449

.GOIN

 JSR RES2
 LDA #&08
 JSR l_263d
 JMP run_tcode
 \l_1452
 \	JSR l_43b1
 \	JSR l_2160
 \	BNE l_1473

.l_1449

 LDA &7D
 CMP #&05
 BCS n_crunch
 LDA &033F
 AND #&04
 EOR #&05
 \	LDA #&04
 BNE l_146d

.l_1464

 LDA #&40
 JSR n_hit
 JSR anger_8c

.n_crunch

 LDA #&80

.l_146d

 JSR n_through
 JSR l_43b1

.l_1473

 LDA &6A
 BPL l_147a
 JSR SCAN

.l_147a

 LDA &87
 BNE l_14f0
 LDX VIEW
 BEQ l_1486
 JSR PU1

.l_1486

 JSR l_24c7
 BCC l_14ed
 LDA target
 BEQ l_149a
 JSR BEEP
 LDX &84
 LDY #&0E
 JSR l_3807

.l_149a

 LDA &44
 BEQ l_14ed
 LDX #&0F
 JSR l_43dd
 LDA &44
 LDY &8C
 CPY #&02
 BEQ l_14e8
 CPY #&1F
 BNE l_14b7
 LSR A

.l_14b7

 LSR A
 JSR n_hit	\ hit enemy
 BCS l_14e6
 LDA &8C
 CMP #&07
 BNE l_14d9
 LDA &44
 CMP new_mining
 BNE l_14d9
 JSR DORND
 LDX #&08
 AND #&03
 JSR l_1687

.l_14d9

 LDY #&04
 JSR l_1678
 LDY #&05
 JSR l_1678
 JSR l_43ce

.l_14e6

.l_14e8

 JSR anger_8c

.l_14ed

 JSR LL9

.l_14f0

 LDY #&23
 LDA &69
 STA (&20),Y
 LDA &6A
 BMI l_1527
 LDA &65
 BPL l_152a
 AND #&20
 BEQ l_152a
 \	AND &6A	\ A=&20
 \	BEQ n_trader
 \	INC FIST
 \	BNE n_trader
 \	DEC FIST
 \n_trader
 \	LDA &6A
 \	AND #&40
 \	ORA FIST
 \	STA FIST
 BIT &6A	\ A=&20
 BVS n_badboy
 BEQ n_goodboy
 LDA #&80

.n_badboy

 ASL A
 ROL A

.n_bitlegal

 LSR A
 BIT FIST
 BNE n_bitlegal
 ADC FIST
 BCS l_1527
 STA FIST
 BCC l_1527

.n_goodboy

 LDA &034A
 ORA &0341
 BNE l_1527
 \	LDA &6A
 \	AND #&60
 \	BNE l_1527
 LDY #&0A
 LDA (&1E),Y
 \	BEQ l_1527
 TAX
 INY
 LDA (&1E),Y
 TAY
 JSR l_32d0
 LDA #&00
 JSR l_45c6

.l_1527

 JMP l_3d7f

.n_hit

 \ hit opponent
 STA &D1
 SEC
 LDY #&0E	\ opponent shield
 LDA (&1E),Y
 AND #&07
 SBC &D1
 BCS n_kill
 \	BCC n_defense
 \	LDA #&FF
 \n_defense
 CLC
 ADC &69
 STA &69
 BCS n_kill
 JSR l_2160

.n_kill

 \ C clear if dead
 RTS

.l_152a

 LDA &8C
 BMI l_1533
 JSR l_41b2
 BCC l_1527

.l_1533

 LDY #&1F
 LDA &65
 STA (&20),Y
 LDX &84
 INX
 JMP l_1376

.l_153f

 LDA &8A
 AND #&07
 BNE l_15c2
 LDX ENERGY
 BPL l_156c
 LDX ASH
 JSR l_3626
 STX ASH
 LDX FSH
 JSR l_3626
 STX FSH

.l_156c

 SEC
 LDA cmdr_eunit
 ADC ENERGY
 BCS l_1578
 STA ENERGY

.l_1578

 LDA &0341
 BNE l_15bf
 LDA &8A
 AND #&1F
 BNE l_15cb
 LDA &0320
 BNE l_15bf
 TAY
 JSR MAS2
 BNE l_15bf
 LDX #&1C

.l_1590

 LDA &0900,X
 STA &46,X
 DEX
 BPL l_1590
 INX
 LDY #&09
 JSR MAS1
 BNE l_15bf
 LDX #&03
 LDY #&0B
 JSR MAS1
 BNE l_15bf
 LDX #&06
 LDY #&0D
 JSR MAS1
 BNE l_15bf
 LDA #&C0
 JSR l_41b4
 BCC l_15bf
 JSR l_3c30
 JSR l_3740

.l_15bf

 JMP l_1648

.l_15c2

 LDA &0341
 BNE l_15bf
 LDA &8A
 AND #&1F

.l_15cb

 CMP #&0A
 BNE l_15fd
 LDA #&32
 CMP ENERGY
 BCC l_15da
 ASL A
 JSR l_45c6

.l_15da

 LDY #&FF
 STY ALTIT
 INY
 JSR m
 BNE l_1648
 JSR MAS3
 BCS l_1648
 SBC #&24
 BCC l_15fa
 STA &82
 JSR l_47b8
 LDA &81
 STA ALTIT
 BNE l_1648

.l_15fa

 JMP l_41c6

.l_15fd

 CMP #&0F
 BNE l_160a
 LDA &033F
 BEQ l_1648
 LDA #&7B
 BNE l_1645

.l_160a

 CMP #&14
 BNE l_1648
 LDA #&1E
 STA CABTMP
 LDA &0320
 BNE l_1648
 LDY #&25
 JSR MAS2
 BNE l_1648
 JSR MAS3
 EOR #&FF
 ADC #&1E
 STA CABTMP
 BCS l_15fa
 CMP #&E0
 BCC l_1648
 LDA BST
 BEQ l_1648
 LDA &7F
 LSR A
 ADC QQ14
 CMP new_range
 BCC l_1640
 LDA new_range

.l_1640

 STA QQ14
 LDA #&A0

.l_1645

 JSR l_45c6

.l_1648

 LDA &0343
 BEQ l_165c
 LDA &0346
 CMP #&08
 BCS l_165c
 JSR LASLI2
 LDA #&00
 STA &0343

.l_165c

 LDA &0340
 BEQ l_1666
 JSR DENGY
 BEQ l_166e

.l_1666

 LDA &30
 BEQ l_1671
 DEC &30
 BNE l_1671

.l_166e

 JSR l_43a3

.l_1671

 LDA &87
 BNE l_1694
 JMP STARS

.l_1678

 JSR DORND
 BPL l_1694
 PHA
 TYA
 TAX
 PLA
 LDY #&00
 AND (&1E),Y
 AND #&0F

.l_1687

 STA &93
 BEQ l_1694

.l_168b

 LDA #&00
 JSR l_2592
 DEC &93
 BNE l_168b

.l_1694

 RTS

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
\SAVE "output/D.ELTA.bin", CODE%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE B FILE
\
\ ******************************************************************************

CODE_B% = P%
LOAD_B% = LOAD% + P% - CODE%

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
\       Name: PIX1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (YY+1 SYL+Y) = (A P) + (S R) and draw stardust particle
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following:
\
\   (YY+1 SYL+Y) = (A P) + (S R)
\
\ and draw a stardust particle at (X1,Y1) with distance ZZ.
\
\ Arguments:
\
\   (A P)               A is the angle ALPHA or BETA, P is always 0
\
\   (S R)               YY(1 0) or YY(1 0) + Q * A
\
\   Y                   Stardust particle number
\
\   X1                  The x-coordinate offset
\
\   Y1                  The y-coordinate offset
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ ******************************************************************************

.PIX1

 JSR ADD                \ Set (A X) = (A P) + (S R)

 STA YY+1               \ Set YY+1 to A, the high byte of the result

 TXA                    \ Set SYL+Y to X, the low byte of the result
 STA SYL,Y

                        \ Fall through into PIX1 to draw the stardust particle
                        \ at (X1,Y1)

\ ******************************************************************************
\
\       Name: PIXEL2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a stardust particle relative to the screen centre
\
\ ------------------------------------------------------------------------------
\
\ Draw a point (X1, Y1) from the middle of the screen with a size determined by
\ a distance value. Used to draw stardust particles.
\
\ Arguments:
\
\   X1                  The x-coordinate offset
\
\   Y1                  The y-coordinate offset (positive means up the screen
\                       from the centre, negative means down the screen)
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ ******************************************************************************

.PIXEL2

 LDA X1                 \ Fetch the x-coordinate offset into A

 BPL PX1                \ If the x-coordinate offset is positive, jump to PX1
                        \ to skip the following negation

 EOR #%01111111         \ The x-coordinate offset is negative, so flip all the
 CLC                    \ bits apart from the sign bit and add 1, to negate
 ADC #1                 \ it to a positive number, i.e. A is now |X1|

.PX1

 EOR #%10000000         \ Set X = -|A|
 TAX                    \       = -|X1|

 LDA Y1                 \ Fetch the y-coordinate offset into A and clear the
 AND #%01111111         \ sign bit, so A = |Y1|

 CMP #96                \ If |Y1| >= 96 then it's off the screen (as 96 is half
 BCS PX4                \ the screen height), so return from the subroutine (as
                        \ PX4 contains an RTS)

 LDA Y1                 \ Fetch the y-coordinate offset into A

 BPL PX2                \ If the y-coordinate offset is positive, jump to PX2
                        \ to skip the following negation

 EOR #%01111111         \ The y-coordinate offset is negative, so flip all the
 ADC #1                 \ bits apart from the sign bit and subtract 1, to negate
                        \ it to a positive number, i.e. A is now |Y1|

.PX2

 STA T                  \ Set A = 97 - A
 LDA #97                \       = 97 - |Y1|
 SBC T                  \
                        \ so if Y is positive we display the point up from the
                        \ centre, while a negative Y means down from the centre

                        \ Fall through into PIXEL to draw the stardust at the
                        \ screen coordinates in (X, A)

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

 LDA ZZ                 \ AJD
 CMP #144
 BCC thick_dot
 LDA TWOS,X
 BCS PX14+3

.thick_dot

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
\       Name: FLIP
\       Type: Subroutine
\   Category: Stardust
\    Summary: Reflect the stardust particles in the screen diagonal
\
\ ------------------------------------------------------------------------------
\
\ Swap the x- and y-coordinates of all the stardust particles and draw the new
\ set of particles. Called by LOOK1 when we switch views.
\
\ This is a quick way of making the stardust field in the new view feel
\ different without having to generate a whole new field. If you look carefully
\ at the stardust field when you switch views, you can just about see that the
\ new field is a reflection of the previous field in the screen diagonal, i.e.
\ in the line from bottom left to top right. This is the line where x = y when
\ the origin is in the middle of the screen, and positive x and y are right and
\ up, which is the coordinate system we use for stardust).
\
\ ******************************************************************************

.FLIP

\LDA MJ                 \ These instructions are commented out in the original
\BNE FLIP-1             \ source. They would have the effect of not swapping the
                        \ stardust if we had mis-jumped into witchspace

 LDY NOSTM              \ Set Y to the current number of stardust particles, so
                        \ we can use it as a counter through all the stardust

.FLL1

 LDX SY,Y               \ Copy the Y-th particle's y-coordinate from SY+Y into X

 LDA SX,Y               \ Copy the Y-th particle's x-coordinate from SX+Y into
 STA Y1                 \ both Y1 and the particle's y-coordinate
 STA SY,Y

 TXA                    \ Copy the Y-th particle's original y-coordinate into
 STA X1                 \ both X1 and the particle's x-coordinate, so the x- and
 STA SX,Y               \ y-coordinates are now swapped and (X1, Y1) contains
                        \ the particle's new coordinates

 LDA SZ,Y               \ Fetch the Y-th particle's distance from SZ+Y into ZZ
 STA ZZ

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ

 DEY                    \ Decrement the counter to point to the next particle of
                        \ stardust

 BNE FLL1               \ Loop back to FLL1 until we have moved all the stardust
                        \ particles

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: STARS
\       Type: Subroutine
\   Category: Stardust
\    Summary: The main routine for processing the stardust
\
\ ------------------------------------------------------------------------------
\
\ Called at the very end of the main flight loop.
\
\ ******************************************************************************

.STARS

 LDX VIEW               \ Load the current view into X:
                        \
                        \   0 = front
                        \   1 = rear
                        \   2 = left
                        \   3 = right

 BEQ STARS1             \ If this 0, jump to STARS1 to process the stardust for
                        \ the front view

 DEX                    \ If this is view 2 or 3, jump to STARS2 (via ST11) to
 BNE ST11               \ process the stardust for the left or right views

 JMP STARS6             \ Otherwise this is the rear view, so jump to STARS6 to
                        \ process the stardust for the rear view

.ST11

 JMP STARS2             \ Jump to STARS2 for the left or right views, as it's
                        \ too far for the branch instruction above

\ ******************************************************************************
\
\       Name: STARS1
\       Type: Subroutine
\   Category: Stardust
\    Summary: Process the stardust for the front view
\  Deep dive: Stardust in the front view
\
\ ------------------------------------------------------------------------------
\
\ This moves the stardust towards us according to our speed (so the dust rushes
\ past us), and applies our current pitch and roll to each particle of dust, so
\ the stardust moves correctly when we steer our ship.
\
\ When a stardust particle rushes past us and falls off the side of the screen,
\ its memory is recycled as a new particle that's positioned randomly on-screen.
\
\ ******************************************************************************

.STARS1

 LDY NOSTM              \ Set Y to the current number of stardust particles, so
                        \ we can use it as a counter through all the stardust

                        \ In the following, we're going to refer to the 16-bit
                        \ space coordinates of the current particle of stardust
                        \ (i.e. the Y-th particle) like this:
                        \
                        \   x = (x_hi x_lo)
                        \   y = (y_hi y_lo)
                        \   z = (z_hi z_lo)
                        \
                        \ These values are stored in (SX+Y SXL+Y), (SY+Y SYL+Y)
                        \ and (SZ+Y SZL+Y) respectively

.STL1

 JSR DV42               \ Call DV42 to set the following:
                        \
                        \   (P R) = 256 * DELTA / z_hi
                        \         = 256 * speed / z_hi
                        \
                        \ The maximum value returned is P = 2 and R = 128 (see
                        \ DV42 for an explanation)

 LDA R                  \ Set A = R, so now:
                        \
                        \   (P A) = 256 * speed / z_hi

 LSR P                  \ Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  \ has a maximum value of 2) and leaves:
 LSR P                  \
 ROR A                  \   A = 64 * speed / z_hi

 ORA #1                 \ Make sure A is at least 1, and store it in Q, so we
 STA Q                  \ now have result 1 above:
                        \
                        \   Q = 64 * speed / z_hi

 LDA SZL,Y              \ We now calculate the following:
 SBC DELT4              \
 STA SZL,Y              \  (z_hi z_lo) = (z_hi z_lo) - DELT4(1 0)
                        \
                        \ starting with the low bytes

 LDA SZ,Y               \ And then we do the high bytes
 STA ZZ                 \
 SBC DELT4+1            \ We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               \ use below to remove the existing particle
                        \
                        \ So now we have result 2 above:
                        \
                        \   z = z - DELT4(1 0)
                        \     = z - speed * 64

 JSR MLU1               \ Call MLU1 to set:
                        \
                        \   Y1 = y_hi
                        \
                        \   (A P) = |y_hi| * Q
                        \
                        \ So Y1 contains the original value of y_hi, which we
                        \ use below to remove the existing particle

                        \ We now calculate:
                        \
                        \   (S R) = YY(1 0) = (A P) + y

 STA YY+1               \ First we do the low bytes with:
 LDA P                  \
 ADC SYL,Y              \   YY+1 = A
 STA YY                 \   R = YY = P + y_lo
 STA R                  \
                        \ so we get this:
                        \
                        \   (? R) = YY(1 0) = (A P) + y_lo

 LDA Y1                 \ And then we do the high bytes with:
 ADC YY+1               \
 STA YY+1               \   S = YY+1 = y_hi + YY+1
 STA S                  \
                        \ so we get our result:
                        \
                        \   (S R) = YY(1 0) = (A P) + (y_hi y_lo)
                        \                   = |y_hi| * Q + y
                        \
                        \ which is result 3 above, and (S R) is set to the new
                        \ value of y

 LDA SX,Y               \ Set X1 = A = x_hi
 STA X1                 \
                        \ So X1 contains the original value of x_hi, which we
                        \ use below to remove the existing particle

 JSR MLU2               \ Set (A P) = |x_hi| * Q

                        \ We now calculate:
                        \
                        \   XX(1 0) = (A P) + x

 STA XX+1               \ First we do the low bytes:
 LDA P                  \
 ADC SXL,Y              \   XX(1 0) = (A P) + x_lo
 STA XX

 LDA X1                 \ And then we do the high bytes:
 ADC XX+1               \
 STA XX+1               \   XX(1 0) = XX(1 0) + (x_hi 0)
                        \
                        \ so we get our result:
                        \
                        \   XX(1 0) = (A P) + x
                        \           = |x_hi| * Q + x
                        \
                        \ which is result 4 above, and we also have:
                        \
                        \   A = XX+1 = (|x_hi| * Q + x) / 256
                        \
                        \ i.e. A is the new value of x, divided by 256

 EOR ALP2+1             \ EOR with the flipped sign of the roll angle alpha, so
                        \ A has the opposite sign to the flipped roll angle
                        \ alpha, i.e. it gets the same sign as alpha

 JSR MLS1               \ Call MLS1 to calculate:
                        \
                        \   (A P) = A * ALP1
                        \         = (x / 256) * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = (x / 256) * alpha + y
                        \         = y + alpha * x / 256

 STA YY+1               \ Set YY(1 0) = (A X) to give:
 STX YY                 \
                        \   YY(1 0) = y + alpha * x / 256
                        \
                        \ which is result 5 above, and we also have:
                        \
                        \   A = YY+1 = y + alpha * x / 256
                        \
                        \ i.e. A is the new value of y, divided by 256

 EOR ALP2               \ EOR A with the correct sign of the roll angle alpha,
                        \ so A has the opposite sign to the roll angle alpha

 JSR MLS2               \ Call MLS2 to calculate:
                        \
                        \   (S R) = XX(1 0)
                        \         = x
                        \
                        \   (A P) = A * ALP1
                        \         = -y / 256 * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = -y / 256 * alpha + x

 STA XX+1               \ Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 \
                        \   x = x - alpha * y / 256

 LDX BET1               \ Fetch the pitch magnitude into X

 LDA YY+1               \ Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 JSR MULTS-2            \ Call MULTS-2 to calculate:
                        \
                        \   (A P) = X * A
                        \         = -beta * y_hi

 STA Q                  \ Store the high byte of the result in Q, so:
                        \
                        \   Q = -beta * y_hi / 256

 JSR MUT2               \ Call MUT2 to calculate:
                        \
                        \   (S R) = XX(1 0) = x
                        \
                        \   (A P) = Q * A
                        \         = (-beta * y_hi / 256) * (-beta * y_hi / 256)
                        \         = (beta * y / 256) ^ 2

 ASL P                  \ Double (A P), store the top byte in A and set the C
 ROL A                  \ flag to bit 7 of the original A, so this does:
 STA T                  \
                        \   (T P) = (A P) << 1
                        \         = 2 * (beta * y / 256) ^ 2

 LDA #0                 \ Set bit 7 in A to the sign bit from the A in the
 ROR A                  \ calculation above and apply it to T, so we now have:
 ORA T                  \
                        \   (A P) = (A P) * 2
                        \         = 2 * (beta * y / 256) ^ 2
                        \
                        \ with the doubling retaining the sign of (A P)

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = 2 * (beta * y / 256) ^ 2 + x

 STA XX+1               \ Store the high byte A in XX+1

 TXA
 STA SXL,Y              \ Store the low byte X in x_lo

                        \ So (XX+1 x_lo) now contains:
                        \
                        \   x = x + 2 * (beta * y / 256) ^ 2
                        \
                        \ which is result 7 above

 LDA YY                 \ Set (S R) = YY(1 0) = y
 STA R
 LDA YY+1
\JSR MAD                \ These instructions are commented out in the original
\STA S                  \ source
\STX R
 STA S

 LDA #0                 \ Set P = 0
 STA P

 LDA BETA               \ Set A = -beta, so:
 EOR #%10000000         \
                        \   (A P) = (-beta 0)
                        \         = -beta * 256

 JSR PIX1               \ Call PIX1 to calculate the following:
                        \
                        \   (YY+1 y_lo) = (A P) + (S R)
                        \               = -beta * 256 + y
                        \
                        \ i.e. y = y - beta * 256, which is result 8 above
                        \
                        \ PIX1 also draws a particle at (X1, Y1) with distance
                        \ ZZ, which will remove the old stardust particle, as we
                        \ set X1, Y1 and ZZ to the original values for this
                        \ particle during the calculations above

                        \ We now have our newly moved stardust particle at
                        \ x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        \ and distance z_hi, so we draw it if it's still on
                        \ screen, otherwise we recycle it as a new bit of
                        \ stardust and draw that

 LDA XX+1               \ Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 \ the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               \ byte is in X1

 AND #%01111111         \ If |x_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               \ particle, as it's gone off the side of the screen,
 BCS KILL1              \ and re-join at STC1 with the new particle

 LDA YY+1               \ Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               \ the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 \ byte is in Y1

 AND #%01111111         \ If |y_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               \ particle, as it's gone off the top or bottom of the
 BCS KILL1              \ screen, and re-join at STC1 with the new particle

 LDA SZ,Y               \ If z_hi < 16 then jump to KILL1 to recycle this
 CMP #16                \ particle, as it's so close that it's effectively gone
 BCC KILL1              \ past us, and re-join at STC1 with the new particle

 STA ZZ                 \ Set ZZ to the z-coordinate in z_hi

.STC1

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ,
                        \ i.e. draw the newly moved particle at (x_hi, y_hi)
                        \ with distance z_hi

 DEY                    \ Decrement the loop counter to point to the next
                        \ stardust particle

 BEQ P%+5               \ If we have just done the last particle, skip the next
                        \ instruction to return from the subroutine

 JMP STL1               \ We have more stardust to process, so jump back up to
                        \ STL1 for the next particle

 RTS                    \ Return from the subroutine

.KILL1

                        \ Our particle of stardust just flew past us, so let's
                        \ recycle that particle, starting it at a random
                        \ position that isn't too close to the centre point

 JSR DORND              \ Set A and X to random numbers

 ORA #4                 \ Make sure A is at least 4 and store it in Y1 and y_hi,
 STA Y1                 \ so the new particle starts at least 4 pixels above or
 STA SY,Y               \ below the centre of the screen

 JSR DORND              \ Set A and X to random numbers

 ORA #8                 \ Make sure A is at least 8 and store it in X1 and x_hi,
 STA X1                 \ so the new particle starts at least 8 pixels either
 STA SX,Y               \ side of the centre of the screen

 JSR DORND              \ Set A and X to random numbers

 ORA #144               \ Make sure A is at least 144 and store it in ZZ and
 STA SZ,Y               \ z_hi so the new particle starts in the far distance
 STA ZZ

 LDA Y1                 \ Set A to the new value of y_hi. This has no effect as
                        \ STC1 starts with a jump to PIXEL2, which starts with a
                        \ LDA instruction

 JMP STC1               \ Jump up to STC1 to draw this new particle

\ ******************************************************************************
\
\       Name: STARS6
\       Type: Subroutine
\   Category: Stardust
\    Summary: Process the stardust for the rear view
\
\ ------------------------------------------------------------------------------
\
\ This routine is very similar to STARS1, which processes stardust for the front
\ view. The main difference is that the direction of travel is reversed, so the
\ signs in the calculations are different, as well as the order of the first
\ batch of calculations.
\
\ When a stardust particle falls away into the far distance, it is removed from
\ the screen and its memory is recycled as a new particle, positioned randomly
\ along one of the four edges of the screen.
\
\ See STARS1 for an explanation of the maths used in this routine. The
\ calculations are as follows:
\
\   1. q = 64 * speed / z_hi
\   2. x = x - |x_hi| * q
\   3. y = y - |y_hi| * q
\   4. z = z + speed * 64
\
\   5. y = y - alpha * x / 256
\   6. x = x + alpha * y / 256
\
\   7. x = x - 2 * (beta * y / 256) ^ 2
\   8. y = y + beta * 256
\
\ ******************************************************************************

.STARS6

 LDY NOSTM              \ Set Y to the current number of stardust particles, so
                        \ we can use it as a counter through all the stardust

.STL6

 JSR DV42               \ Call DV42 to set the following:
                        \
                        \   (P R) = 256 * DELTA / z_hi
                        \         = 256 * speed / z_hi
                        \
                        \ The maximum value returned is P = 2 and R = 128 (see
                        \ DV42 for an explanation)

 LDA R                  \ Set A = R, so now:
                        \
                        \   (P A) = 256 * speed / z_hi

 LSR P                  \ Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  \ has a maximum value of 2) and leaves:
 LSR P                  \
 ROR A                  \   A = 64 * speed / z_hi

 ORA #1                 \ Make sure A is at least 1, and store it in Q, so we
 STA Q                  \ now have result 1 above:
                        \
                        \   Q = 64 * speed / z_hi

 LDA SX,Y               \ Set X1 = A = x_hi
 STA X1                 \
                        \ So X1 contains the original value of x_hi, which we
                        \ use below to remove the existing particle

 JSR MLU2               \ Set (A P) = |x_hi| * Q

                        \ We now calculate:
                        \
                        \   XX(1 0) = x - (A P)

 STA XX+1               \ First we do the low bytes:
 LDA SXL,Y              \
 SBC P                  \   XX(1 0) = x_lo - (A P)
 STA XX

 LDA X1                 \ And then we do the high bytes:
 SBC XX+1               \
 STA XX+1               \   XX(1 0) = (x_hi 0) - XX(1 0)
                        \
                        \ so we get our result:
                        \
                        \   XX(1 0) = x - (A P)
                        \           = x - |x_hi| * Q
                        \
                        \ which is result 2 above, and we also have:

 JSR MLU1               \ Call MLU1 to set:
                        \
                        \   Y1 = y_hi
                        \
                        \   (A P) = |y_hi| * Q
                        \
                        \ So Y1 contains the original value of y_hi, which we
                        \ use below to remove the existing particle

                        \ We now calculate:
                        \
                        \   (S R) = YY(1 0) = y - (A P)

 STA YY+1               \ First we do the low bytes with:
 LDA SYL,Y              \
 SBC P                  \   YY+1 = A
 STA YY                 \   R = YY = y_lo - P
 STA R                  \
                        \ so we get this:
                        \
                        \   (? R) = YY(1 0) = y_lo - (A P)

 LDA Y1                 \ And then we do the high bytes with:
 SBC YY+1               \
 STA YY+1               \   S = YY+1 = y_hi - YY+1
 STA S                  \
                        \ so we get our result:
                        \
                        \   (S R) = YY(1 0) = (y_hi y_lo) - (A P)
                        \                   = y - |y_hi| * Q
                        \
                        \ which is result 3 above, and (S R) is set to the new
                        \ value of y

 LDA SZL,Y              \ We now calculate the following:
 ADC DELT4              \
 STA SZL,Y              \  (z_hi z_lo) = (z_hi z_lo) + DELT4(1 0)
                        \
                        \ starting with the low bytes

 LDA SZ,Y               \ And then we do the high bytes
 STA ZZ                 \
 ADC DELT4+1            \ We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               \ use below to remove the existing particle
                        \
                        \ So now we have result 4 above:
                        \
                        \   z = z + DELT4(1 0)
                        \     = z + speed * 64

 LDA XX+1               \ EOR x with the correct sign of the roll angle alpha,
 EOR ALP2               \ so A has the opposite sign to the roll angle alpha

 JSR MLS1               \ Call MLS1 to calculate:
                        \
                        \   (A P) = A * ALP1
                        \         = (-x / 256) * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = (-x / 256) * alpha + y
                        \         = y - alpha * x / 256

 STA YY+1               \ Set YY(1 0) = (A X) to give:
 STX YY                 \
                        \   YY(1 0) = y - alpha * x / 256
                        \
                        \ which is result 5 above, and we also have:
                        \
                        \   A = YY+1 = y - alpha * x / 256
                        \
                        \ i.e. A is the new value of y, divided by 256

 EOR ALP2+1             \ EOR with the flipped sign of the roll angle alpha, so
                        \ A has the opposite sign to the flipped roll angle
                        \ alpha, i.e. it gets the same sign as alpha

 JSR MLS2               \ Call MLS2 to calculate:
                        \
                        \   (S R) = XX(1 0)
                        \         = x
                        \
                        \   (A P) = A * ALP1
                        \         = y / 256 * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = y / 256 * alpha + x

 STA XX+1               \ Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 \
                        \   x = x + alpha * y / 256

 LDA YY+1               \ Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 LDX BET1               \ Fetch the pitch magnitude into X

 JSR MULTS-2            \ Call MULTS-2 to calculate:
                        \
                        \   (A P) = X * A
                        \         = beta * y_hi

 STA Q                  \ Store the high byte of the result in Q, so:
                        \
                        \   Q = beta * y_hi / 256

 LDA XX+1               \ Set S = x_hi
 STA S

 EOR #%10000000         \ Flip the sign of A, so A now contains -x

 JSR MUT1               \ Call MUT1 to calculate:
                        \
                        \   R = XX = x_lo
                        \
                        \   (A P) = Q * A
                        \         = (beta * y_hi / 256) * (-beta * y_hi / 256)
                        \         = (-beta * y / 256) ^ 2

 ASL P                  \ Double (A P), store the top byte in A and set the C
 ROL A                  \ flag to bit 7 of the original A, so this does:
 STA T                  \
                        \   (T P) = (A P) << 1
                        \         = 2 * (-beta * y / 256) ^ 2

 LDA #0                 \ Set bit 7 in A to the sign bit from the A in the
 ROR A                  \ calculation above and apply it to T, so we now have:
 ORA T                  \
                        \   (A P) = -2 * (beta * y / 256) ^ 2
                        \
                        \ with the doubling retaining the sign of (A P)

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = -2 * (beta * y / 256) ^ 2 + x

 STA XX+1               \ Store the high byte A in XX+1

 TXA
 STA SXL,Y              \ Store the low byte X in x_lo

                        \ So (XX+1 x_lo) now contains:
                        \
                        \   x = x - 2 * (beta * y / 256) ^ 2
                        \
                        \ which is result 7 above

 LDA YY                 \ Set (S R) = YY(1 0) = y
 STA R
 LDA YY+1
 STA S

\EOR #128               \ These instructions are commented out in the original
\JSR MAD                \ source
\STA S
\STX R

 LDA #0                 \ Set P = 0
 STA P

 LDA BETA               \ Set A = beta, so (A P) = (beta 0) = beta * 256

 JSR PIX1               \ Call PIX1 to calculate the following:
                        \
                        \   (YY+1 y_lo) = (A P) + (S R)
                        \               = beta * 256 + y
                        \
                        \ i.e. y = y + beta * 256, which is result 8 above
                        \
                        \ PIX1 also draws a particle at (X1, Y1) with distance
                        \ ZZ, which will remove the old stardust particle, as we
                        \ set X1, Y1 and ZZ to the original values for this
                        \ particle during the calculations above

                        \ We now have our newly moved stardust particle at
                        \ x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        \ and distance z_hi, so we draw it if it's still on
                        \ screen, otherwise we recycle it as a new bit of
                        \ stardust and draw that

 LDA XX+1               \ Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 \ the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               \ byte is in X1

 LDA YY+1               \ Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               \ the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 \ byte is in Y1

 AND #%01111111         \ If |y_hi| >= 110 then jump to KILL6 to recycle this
 CMP #110               \ particle, as it's gone off the top or bottom of the
 BCS KILL6              \ screen, and re-join at STC6 with the new particle

 LDA SZ,Y               \ If z_hi >= 160 then jump to KILL6 to recycle this
 CMP #160               \ particle, as it's so far away that it's too far to
 BCS KILL6              \ see, and re-join at STC1 with the new particle

 STA ZZ                 \ Set ZZ to the z-coordinate in z_hi

.STC6

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ,
                        \ i.e. draw the newly moved particle at (x_hi, y_hi)
                        \ with distance z_hi

 DEY                    \ Decrement the loop counter to point to the next
                        \ stardust particle

 BEQ MA9                \ If we have just done the last particle, return from
                        \ the subroutine (as MA9 contains an RTS)

 JMP STL6               \ We have more stardust to process, so jump back up to
                        \ STL6 for the next particle

.KILL6

 JSR DORND              \ Set A and X to random numbers

 AND #%01111111         \ Clear the sign bit of A to get |A|

 ADC #10                \ Make sure A is at least 10 and store it in z_hi and
 STA SZ,Y               \ ZZ, so the new particle starts close to us
 STA ZZ

 LSR A                  \ Divide A by 2 and randomly set the C flag

 BCS ST4                \ Jump to ST4 half the time

 LSR A                  \ Randomly set the C flag again

 LDA #252               \ Set A to either +126 or -126 (252 >> 1) depending on
 ROR A                  \ the C flag, as this is a sign-magnitude number with
                        \ the C flag rotated into its sign bit

 STA X1                 \ Set x_hi and X1 to A, so this particle starts on
 STA SX,Y               \ either the left or right edge of the screen

 JSR DORND              \ Set A and X to random numbers

 STA Y1                 \ Set y_hi and Y1 to random numbers, so the particle
 STA SY,Y               \ starts anywhere along either the left or right edge

 JMP STC6               \ Jump up to STC6 to draw this new particle

.ST4

 JSR DORND              \ Set A and X to random numbers

 STA X1                 \ Set x_hi and X1 to random numbers, so the particle
 STA SX,Y               \ starts anywhere along the x-axis

 LSR A                  \ Randomly set the C flag

 LDA #230               \ Set A to either +115 or -115 (230 >> 1) depending on
 ROR A                  \ the C flag, as this is a sign-magnitude number with
                        \ the C flag rotated into its sign bit

 STA Y1                 \ Set y_hi and Y1 to A, so the particle starts anywhere
 STA SY,Y               \ along either the top or bottom edge of the screen

 BNE STC6               \ Jump up to STC6 to draw this new particle (this BNE is
                        \ effectively a JMP as A will never be zero)

\ ******************************************************************************
\
\       Name: MAS1
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Add an orientation vector coordinate to an INWK coordinate
\
\ ------------------------------------------------------------------------------
\
\ Add a doubled nosev vector coordinate, e.g. (nosev_y_hi nosev_y_lo) * 2, to
\ an INWK coordinate, e.g. (x_sign x_hi x_lo), storing the result in the INWK
\ coordinate. The axes used in each side of the addition are specified by the
\ arguments X and Y.
\
\ In the comments below, we document the routine as if we are doing the
\ following, i.e. if X = 0 and Y = 11:
\
\   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (nosev_y_hi nosev_y_lo) * 2
\
\ as that way the variable names in the comments contain "x" and "y" to match
\ the registers that specify the vector axis to use.
\
\ Arguments:
\
\   X                   The coordinate to add, as follows:
\
\                         * If X = 0, add (x_sign x_hi x_lo)
\                         * If X = 3, add (y_sign y_hi y_lo)
\                         * If X = 6, add (z_sign z_hi z_lo)
\
\   Y                   The vector to add, as follows:
\
\                         * If Y = 9,  add (nosev_x_hi nosev_x_lo)
\                         * If Y = 11, add (nosev_y_hi nosev_y_lo)
\                         * If Y = 13, add (nosev_z_hi nosev_z_lo)
\
\ Returns:
\
\   A                   The high byte of the result with the sign cleared (e.g.
\                       |x_hi| if X = 0, etc.)
\
\ Other entry points:
\
\   MA9                 Contains an RTS
\
\ ******************************************************************************

.MAS1

 LDA INWK,Y             \ Set K(2 1) = (nosev_y_hi nosev_y_lo) * 2
 ASL A
 STA K+1
 LDA INWK+1,Y
 ROL A
 STA K+2

 LDA #0                 \ Set K+3 bit 7 to the C flag, so the sign bit of the
 ROR A                  \ above result goes into K+3
 STA K+3

 JSR MVT3               \ Add (x_sign x_hi x_lo) to K(3 2 1)

 STA INWK+2,X           \ Store the sign of the result in x_sign

 LDY K+1                \ Store K(2 1) in (x_hi x_lo)
 STY INWK,X
 LDY K+2
 STY INWK+1,X

 AND #%01111111         \ Set A to the sign byte with the sign cleared

.MA9

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MAS2
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Calculate a cap on the maximum distance to the planet or sun
\
\ ------------------------------------------------------------------------------
\
\ Given a value in Y that points to the start of a ship data block as an offset
\ from K%, calculate the following:
\
\   A = A OR x_sign OR y_sign OR z_sign
\
\ and clear the sign bit of the result. The K% workspace contains the ship data
\ blocks, so the offset in Y must be 0 or a multiple of NI% (as each block in
\ K% contains NI% bytes).
\
\ The result effectively contains a maximum cap of the three values (though it
\ might not be one of the three input values - it's just guaranteed to be
\ larger than all of them).
\
\ If Y = 0 and A = 0, then this calculates the maximum cap of the highest byte
\ containing the distance to the planet, as K%+2 = x_sign, K%+5 = y_sign and
\ K%+8 = z_sign (the first slot in the K% workspace represents the planet).
\
\ Arguments:
\
\   Y                   The offset from K% for the start of the ship data block
\                       to use
\
\ Returns:
\
\   A                   A OR K%+2+Y OR K%+5+Y OR K%+8+Y, with bit 7 cleared
\
\ Other entry points:
\
\   m                   Do not include A in the calculation
\
\ ******************************************************************************

.m

 LDA #0                 \ Set A = 0 and fall through into MAS2 to calculate the
                        \ OR of the three bytes at K%+2+Y, K%+5+Y and K%+8+Y

.MAS2

 ORA K%+2,Y             \ Set A = A OR x_sign OR y_sign OR z_sign
 ORA K%+5,Y
 ORA K%+8,Y

 AND #%01111111         \ Clear bit 7 in A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MAS3
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate A = x_hi^2 + y_hi^2 + z_hi^2 in the K% block
\
\ ------------------------------------------------------------------------------
\
\ Given a value in Y that points to the start of a ship data block as an offset
\ from K%, calculate the following:
\
\   A = x_hi^2 + y_hi^2 + z_hi^2
\
\ returning A = &FF if the calculation overflows a one-byte result. The K%
\ workspace contains the ship data blocks, so the offset in Y must be 0 or a
\ multiple of NI% (as each block in K% contains NI% bytes).
\
\ Arguments:
\
\   Y                   The offset from K% for the start of the ship data block
\                       to use
\
\ Returns
\
\   A                   A = x_hi^2 + y_hi^2 + z_hi^2
\
\                       A = &FF if the calculation overflows a one-byte result
\
\ ******************************************************************************

.MAS3

 LDA K%+1,Y             \ Set (A P) = x_hi * x_hi
 JSR SQUA2

 STA R                  \ Store A (high byte of result) in R

 LDA K%+4,Y             \ Set (A P) = y_hi * y_hi
 JSR SQUA2

 ADC R                  \ Add A (high byte of second result) to R

 BCS MA30               \ If the addition of the two high bytes caused a carry
                        \ (i.e. they overflowed), jump to MA30 to return A = &FF

 STA R                  \ Store A (sum of the two high bytes) in R

 LDA K%+7,Y             \ Set (A P) = z_hi * z_hi
 JSR SQUA2

 ADC R                  \ Add A (high byte of third result) to R, so R now
                        \ contains the sum of x_hi^2 + y_hi^2 + z_hi^2

 BCC P%+4               \ If there is no carry, skip the following instruction
                        \ to return straight from the subroutine

.MA30

 LDA #&FF               \ The calculation has overflowed, so set A = &FF

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: STATUS
\       Type: Subroutine
\   Category: Status
\    Summary: Show the Status Mode screen (red key f8)
\  Deep dive: Combat rank
\
\ ******************************************************************************

.st4

                        \ We call this from st5 below with the high byte of the
                        \ kill tally in A, which is non-zero, and want to return
                        \ with the following in X, depending on our rating:
                        \
                        \   Competent = 6
                        \   Dangerous = 7
                        \   Deadly    = 8
                        \   Elite     = 9
                        \
                        \ The high bytes of the top tier ratings are as follows,
                        \ so this a relatively simple calculation:
                        \
                        \   Competent       = 1 to 2
                        \   Dangerous       = 2 to 9
                        \   Deadly          = 10 to 24
                        \   Elite           = 25 and up

 LDX #9                 \ Set X to 9 for an Elite rating

 CMP #25                \ If A >= 25, jump to st3 to print out our rating, as we
 BCS st3                \ are Elite

 DEX                    \ Decrement X to 8 for a Deadly rating

 CMP #10                \ If A >= 10, jump to st3 to print out our rating, as we
 BCS st3                \ are Deadly

 DEX                    \ Decrement X to 7 for a Dangerous rating

 CMP #2                 \ If A >= 2, jump to st3 to print out our rating, as we
 BCS st3                \ are Dangerous

 DEX                    \ Decrement X to 6 for a Competent rating

 BNE st3                \ Jump to st3 to print out our rating, as we are
                        \ Competent (this BNE is effectively a JMP as A will
                        \ never be zero)

.STATUS

 LDA #8                 \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 8 (Status
                        \ Mode screen)

 JSR TT111              \ Select the system closest to galactic coordinates
                        \ (QQ9, QQ10)

 LDA #7                 \ Move the text cursor to column 7
 STA XC

 LDA #126               \ Print recursive token 126, which prints the top
 JSR NLIN3              \ four lines of the Status Mode screen:
                        \
                        \         COMMANDER {commander name}
                        \
                        \
                        \   Present System      : {current system name}
                        \   Hyperspace System   : {selected system name}
                        \   Condition           :
                        \
                        \ and draw a horizontal line at pixel row 19 to box
                        \ in the title

 LDA #230               \ Otherwise we are in space, so start off by setting A
                        \ to token 70 ("GREEN")

 LDY JUNK               \ Set Y to the number of junk items in our local bubble
                        \ of universe (where junk is asteroids, canisters,
                        \ escape pods and so on)

 LDX FRIN+2,Y           \ The ship slots at FRIN are ordered with the first two
                        \ slots reserved for the planet and sun/space station,
                        \ and then any ships, so if the slot at FRIN+2+Y is not
                        \ empty (i.e is non-zero), then that means the number of
                        \ non-asteroids in the vicinity is at least 1

 BEQ st6                \ So if X = 0, there are no ships in the vicinity, so
                        \ jump to st6 to print "Green" for our ship's condition

 LDY ENERGY             \ Otherwise we have ships in the vicinity, so we load
                        \ our energy levels into Y

 CPY #128               \ Set the C flag if Y >= 128, so C is set if we have
                        \ more than half of our energy banks charged

 ADC #1                 \ Add 1 + C to A, so if C is not set (i.e. we have low
                        \ energy levels) then A is set to token 231 ("RED"),
                        \ and if C is set (i.e. we have healthy energy levels)
                        \ then A is set to token 232 ("YELLOW")

.st6

 JSR plf                \ Print the text token in A (which contains our ship's
                        \ condition) followed by a newline

 LDA #125               \ Print recursive token 125, which prints the next
 JSR spc                \ three lines of the Status Mode screen:
                        \
                        \   Fuel: {fuel level} Light Years
                        \   Cash: {cash} Cr
                        \   Legal Status:
                        \
                        \ followed by a space

 LDA #19                \ Set A to token 133 ("CLEAN")

 LDY FIST               \ Fetch our legal status, and if it is 0, we are clean,
 BEQ st5                \ so jump to st5 to print "Clean"

 CPY #50                \ Set the C flag if Y >= 50, so C is set if we have
                        \ a legal status of 50+ (i.e. we are a fugitive)

 ADC #1                 \ Add 1 + C to A, so if C is not set (i.e. we have a
                        \ legal status between 1 and 49) then A is set to token
                        \ 134 ("OFFENDER"), and if C is set (i.e. we have a
                        \ legal status of 50+) then A is set to token 135
                        \ ("FUGITIVE")

.st5

 JSR plf                \ Print the text token in A (which contains our legal
                        \ status) followed by a newline

 LDA #16                \ Print recursive token 130 ("RATING:")
 JSR spc

 LDA TALLY+1            \ Fetch the high byte of the kill tally, and if it is
 BNE st4                \ not zero, then we have more than 256 kills, so jump
                        \ to st4 to work out whether we are Competent,
                        \ Dangerous, Deadly or Elite

                        \ Otherwise we have fewer than 256 kills, so we are one
                        \ of Harmless, Mostly Harmless, Poor, Average or Above
                        \ Average

 TAX                    \ Set X to 0 (as A is 0)

 LDA TALLY              \ Set A = lower byte of tally / 4
 LSR A
 LSR A

.st5L

                        \ We now loop through bits 2 to 7, shifting each of them
                        \ off the end of A until there are no set bits left, and
                        \ incrementing X for each shift, so at the end of the
                        \ process, X contains the position of the leftmost 1 in
                        \ A. Looking at the rank values in TALLY:
                        \
                        \   Harmless        = %00000000 to %00000011
                        \   Mostly Harmless = %00000100 to %00000111
                        \   Poor            = %00001000 to %00001111
                        \   Average         = %00010000 to %00011111
                        \   Above Average   = %00100000 to %11111111
                        \
                        \ we can see that the values returned by this process
                        \ are:
                        \
                        \   Harmless        = 1
                        \   Mostly Harmless = 2
                        \   Poor            = 3
                        \   Average         = 4
                        \   Above Average   = 5

 INX                    \ Increment X for each shift

 LSR A                  \ Shift A to the right

 BNE st5L               \ Keep looping around until A = 0, which means there are
                        \ no set bits left in A

.st3

 TXA                    \ A now contains our rating as a value of 1 to 9, so
                        \ transfer X to A, so we can print it out

 CLC                    \ Print recursive token 135 + A, which will be in the
 ADC #21                \ range 136 ("HARMLESS") to 144 ("---- E L I T E ----")
 JSR plf                \ followed by a newline

 LDA #18                \ Print recursive token 132, which prints the next bit
 JSR plf2               \ of the Status Mode screen:
                        \
                        \   EQUIPMENT:
                        \
                        \ followed by a newline and an indent of 6 characters

.sell_equip

 LDA CRGO               \ AJD
 BEQ l_1ce7	\ IFF if flag not set
 LDA #&6B
 JSR plf2

.l_1ce7

 LDA BST
 BEQ l_1cf1
 LDA #&6F
 JSR plf2

.l_1cf1

 LDA ECM
 BEQ l_1cfb
 LDA #&6C
 JSR plf2

.l_1cfb

 LDA #&71
 STA &96

.stqv

 TAY
 LDX FRIN,Y
 BEQ l_1d08
 JSR plf2

.l_1d08

 INC &96
 LDA &96
 CMP #&75
 BCC stqv

 LDX #0                 \ Now to print our ship's lasers, so set a counter in X
                        \ to count through the four views (0 = front, 1 = rear,
                        \ 2 = left, 3 = right)

.st

 STX CNT                \ Store the view number in CNT

 LDY LASER,X            \ Fetch the laser power for view X, and if we do not
 BEQ st1                \ have a laser fitted to that view, jump to st1 to move
                        \ on to the next one

 TXA                    \ AJD
 ORA #&60
 JSR spc

 LDA #103               \ Set A to token 103 ("PULSE LASER")

 LDX &93                \ AJD
 LDY LASER,X
 CPY new_beam	\ beam laser
 BNE l_1b9d
 LDA #&68

.l_1b9d

 CPY new_military	\ military laser
 BNE l_1ba3
 LDA #&75

.l_1ba3

 CPY new_mining	\ mining laser
 BNE l_1ba9
 LDA #&76

.l_1ba9

 JSR plf2               \ Print the text token in A (which contains our legal
                        \ status) followed by a newline and an indent of 6
                        \ characters

.st1

 LDX CNT                \ Increment the counter in X and CNT to point to the
 INX                    \ next view

 CPX #4                 \ If this isn't the last of the four views, jump back up
 BCC st                 \ to st to print out the next one

 RTS                    \ Return from the subroutine

.plf2

 JSR plf
 LDX #&08
 STX XC
 RTS

\ ******************************************************************************
\
\       Name: MVT3
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
\
\ ------------------------------------------------------------------------------
\
\ Add an INWK position coordinate - i.e. x, y or z - to K(3 2 1), like this:
\
\   K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
\
\ The INWK coordinate to add to K(3 2 1) is specified by X.
\
\ Arguments:
\
\   X                   The coordinate to add to K(3 2 1), as follows:
\
\                         * If X = 0, add (x_sign x_hi x_lo)
\
\                         * If X = 3, add (y_sign y_hi y_lo)
\
\                         * If X = 6, add (z_sign z_hi z_lo)
\
\ Returns:
\
\   A                   Contains a copy of the high byte of the result, K+3
\
\   X                   X is preserved
\
\ ******************************************************************************

.MVT3

 LDA K+3                \ Set S = K+3
 STA S

 AND #%10000000         \ Set T = sign bit of K(3 2 1)
 STA T

 EOR INWK+2,X           \ If x_sign has a different sign to K(3 2 1), jump to
 BMI MV13               \ MV13 to process the addition as a subtraction

 LDA K+1                \ Set K(3 2 1) = K(3 2 1) + (x_sign x_hi x_lo)
 CLC                    \ starting with the low bytes
 ADC INWK,X
 STA K+1

 LDA K+2                \ Then the middle bytes
 ADC INWK+1,X
 STA K+2

 LDA K+3                \ And finally the high bytes
 ADC INWK+2,X

 AND #%01111111         \ Setting the sign bit of K+3 to T, the original sign
 ORA T                  \ of K(3 2 1)
 STA K+3

 RTS                    \ Return from the subroutine

.MV13

 LDA S                  \ Set S = |K+3| (i.e. K+3 with the sign bit cleared)
 AND #%01111111
 STA S

 LDA INWK,X             \ Set K(3 2 1) = (x_sign x_hi x_lo) - K(3 2 1)
 SEC                    \ starting with the low bytes
 SBC K+1
 STA K+1

 LDA INWK+1,X           \ Then the middle bytes
 SBC K+2
 STA K+2

 LDA INWK+2,X           \ And finally the high bytes, doing A = |x_sign| - |K+3|
 AND #%01111111         \ and setting the C flag for testing below
 SBC S

 ORA #%10000000         \ Set the sign bit of K+3 to the opposite sign of T,
 EOR T                  \ i.e. the opposite sign to the original K(3 2 1)
 STA K+3

 BCS MV14               \ If the C flag is set, i.e. |x_sign| >= |K+3|, then
                        \ the sign of K(3 2 1). In this case, we want the
                        \ result to have the same sign as the largest argument,
                        \ which is (x_sign x_hi x_lo), which we know has the
                        \ opposite sign to K(3 2 1), and that's what we just set
                        \ the sign of K(3 2 1) to... so we can jump to MV14 to
                        \ return from the subroutine

 LDA #1                 \ We need to swap the sign of the result in K(3 2 1),
 SBC K+1                \ which we do by calculating 0 - K(3 2 1), which we can
 STA K+1                \ do with 1 - C - K(3 2 1), as we know the C flag is
                        \ clear. We start with the low bytes

 LDA #0                 \ Then the middle bytes
 SBC K+2
 STA K+2

 LDA #0                 \ And finally the high bytes
 SBC K+3

 AND #%01111111         \ Set the sign bit of K+3 to the same sign as T,
 ORA T                  \ i.e. the same sign as the original K(3 2 1), as
 STA K+3                \ that's the largest argument

.MV14

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
\   pr2-1               Print X without a decimal point
\
\ ******************************************************************************

 CLC

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

 BMI rT9                \ If the result is negative, we have printed all the
                        \ characters, so jump down to rT9 to return from the
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
\       Name: TT26
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
\   rT9                 Contains an RTS
\
\ ******************************************************************************

.TT26

 STA K3                 \ Store the A, X and Y registers, so we can restore
 STY YSAV2              \ them at the end (so they don't get changed by this
 STX XSAV2              \ routine)

 LDY QQ17               \ Load the QQ17 flag, which contains the text printing
                        \ flags

 CPY #255               \ If QQ17 = 255 then printing is disabled, so jump to
 BEQ RR4                \ RR4, which doesn't print anything, it just restores
                        \ the registers and returns from the subroutine

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

 INC XC                 \ Move the text cursor to the right by 1 column

 LDA YC                 \ Fetch YC, the y-coordinate (row) of the text cursor

 CMP #24                \ If the text cursor is on the screen (i.e. YC < 24, so
 BCC RR3                \ we are on rows 1-23), then jump to RR3 to print the
                        \ character

 JSR TT66               \ Otherwise we are off the bottom of the screen, so
                        \ clear the screen and draw a white border

 JMP RR4                \ And restore the registers and return from the
                        \ subroutine

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

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 LDY YSAV2              \ We're done printing, so restore the values of the
 LDX XSAV2              \ A, X and Y registers that we saved above and clear
 LDA K3                 \ the C flag, so everything is back to how it was
 CLC

.rT9

 RTS                    \ Return from the subroutine

.R5

 JSR BEEP               \ Call the BEEP subroutine to make a short, high beep

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DIALS (Part 1 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: speed indicator
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This routine updates the dashboard. First we draw all the indicators in the
\ right part of the dashboard, from top (speed) to bottom (energy banks), and
\ then we move on to the left part, again drawing from top (forward shield) to
\ bottom (altitude).
\
\ This first section starts us off with the speedometer in the top right.
\
\ ******************************************************************************

.DIALS

 LDA #&D0               \ Set SC(1 0) = &78D0, which is the screen address for
 STA SC                 \ the character block containing the left end of the
 LDA #&78               \ top indicator in the right part of the dashboard, the
 STA SC+1               \ one showing our speed

 JSR PZW                \ Call PZW to set A to the colour for dangerous values
                        \ and X to the colour for safe values

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values

 LDA #14                \ Set T1 to 14, the threshold at which we change the
 STA T1                 \ indicator's colour

 LDA DELTA              \ Fetch our ship's speed into A, in the range 0-40

\LSR A                  \ Draw the speed indicator using a range of 0-31, and
 JSR DIL-1              \ increment SC to point to the next indicator (the roll
                        \ indicator). The LSR is commented out as it isn't
                        \ required with a call to DIL-1, so perhaps this was
                        \ originally a call to DIL that got optimised

\ ******************************************************************************
\
\       Name: DIALS (Part 2 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: pitch and roll indicators
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #0                 \ Set R = P = 0 for the low bytes in the call to the ADD
 STA R                  \ routine below
 STA P

 LDA #8                 \ Set S = 8, which is the value of the centre of the
 STA S                  \ roll indicator

 LDA ALP1               \ Fetch the roll angle alpha as a value between 0 and
 LSR A                  \ 31, and divide by 4 to get a value of 0 to 7
 LSR A

 ORA ALP2               \ Apply the roll sign to the value, and flip the sign,
 EOR #%10000000         \ so it's now in the range -7 to +7, with a positive
                        \ roll angle alpha giving a negative value in A

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position. We use the ADD
                        \ routine like this:
                        \
                        \ (A X) = (A 0) + (S 0)
                        \
                        \ and just take the high byte of the result. We use ADD
                        \ rather than a normal ADC because ADD separates out the
                        \ sign bit and does the arithmetic using absolute values
                        \ and separate sign bits, which we want here rather than
                        \ the two's complement that ADC uses

 JSR DIL2               \ Draw a vertical bar on the roll indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ pitch indicator)

 LDA BETA               \ Fetch the pitch angle beta as a value between -8 and
                        \ +8

 LDX BET1               \ Fetch the magnitude of the pitch angle beta, and if it
 BEQ P%+4               \ is 0 (i.e. we are not pitching), skip the next
                        \ instruction

 SBC #1                 \ The pitch angle beta is non-zero, so set A = A - 1
                        \ (the C flag is set by the call to DIL2 above, so we
                        \ don't need to do a SEC). This gives us a value of A
                        \ from -7 to +7 because these are magnitude-based
                        \ numbers with sign bits, rather than two's complement
                        \ numbers

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position (see the JSR ADD
                        \ above for more on this)

 JSR DIL2               \ Draw a vertical bar on the pitch indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ four energy banks)

\ ******************************************************************************
\
\       Name: DIALS (Part 3 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: four energy banks
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This and the next section only run once every four iterations of the main
\ loop, so while the speed, pitch and roll indicators update every iteration,
\ the other indicators update less often.
\
\ ******************************************************************************

 LDA MCNT               \ Fetch the main loop counter and calculate MCNT mod 4,
 AND #3                 \ jumping to rT9 if it is non-zero. rT9 contains an RTS,
 BNE rT9                \ so the following code only runs every 4 iterations of
                        \ the main loop, otherwise we return from the subroutine

 LDY #0                 \ Set Y = 0, for use in various places below

 JSR PZW                \ Call PZW to set A to the colour for dangerous values
                        \ and X to the colour for safe values

 STX K                  \ Set K (the colour we should show for high values) to X
                        \ (the colour to use for safe values)

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for low values and yellow/white for high values, which
                        \ we use not only for the energy banks, but also for the
                        \ shield levels and current fuel

 LDX #3                 \ Set up a counter in X so we can zero the four bytes at
                        \ XX12, so we can then calculate each of the four energy
                        \ banks' values before drawing them later

 STX T1                 \ Set T1 to 3, the threshold at which we change the
                        \ indicator's colour

.DLL23

 STY XX12,X             \ Set the X-th byte of XX12 to 0

 DEX                    \ Decrement the counter

 BPL DLL23              \ Loop back for the next byte until the four bytes at
                        \ XX12 are all zeroed

 LDX #3                 \ Set up a counter in X to loop through the 4 energy
                        \ bank indicators, so we can calculate each of the four
                        \ energy banks' values and store them in XX12

 LDA ENERGY             \ Set A = Q = ENERGY / 4, so they are both now in the
 LSR A                  \ range 0-63 (so that's a maximum of 16 in each of the
 LSR A                  \ banks, and a maximum of 15 in the top bank)

 STA Q                  \ Set Q to A, so we can use Q to hold the remaining
                        \ energy as we work our way through each bank, from the
                        \ full ones at the bottom to the empty ones at the top

.DLL24

 SEC                    \ Set A = A - 16 to reduce the energy count by a full
 SBC #16                \ bank

 BCC DLL26              \ If the C flag is clear then A < 16, so this bank is
                        \ not full to the brim, and is therefore the last one
                        \ with any energy in it, so jump to DLL26

 STA Q                  \ This bank is full, so update Q with the energy of the
                        \ remaining banks

 LDA #16                \ Store this bank's level in XX12 as 16, as it is full,
 STA XX12,X             \ with XX12+3 for the bottom bank and XX12+0 for the top

 LDA Q                  \ Set A to the remaining energy level again

 DEX                    \ Decrement X to point to the next bank, i.e. the one
                        \ above the bank we just processed

 BPL DLL24              \ Loop back to DLL24 until we have either processed all
                        \ four banks, or jumped out early to DLL26 if the top
                        \ banks have no charge

 BMI DLL9               \ Jump to DLL9 as we have processed all four banks (this
                        \ BMI is effectively a JMP as A will never be positive)

.DLL26

 LDA Q                  \ If we get here then the bank we just checked is not
 STA XX12,X             \ fully charged, so store its value in XX12 (using Q,
                        \ which contains the energy of the remaining banks -
                        \ i.e. this one)

                        \ Now that we have the four energy bank values in XX12,
                        \ we can draw them, starting with the top bank in XX12
                        \ and looping down to the bottom bank in XX12+3, using Y
                        \ as a loop counter, which was set to 0 above

.DLL9

 LDA XX12,Y             \ Fetch the value of the Y-th indicator, starting from
                        \ the top

 STY P                  \ Store the indicator number in P for retrieval later

 JSR DIL                \ Draw the energy bank using a range of 0-15, and
                        \ increment SC to point to the next indicator (the
                        \ next energy bank down)

 LDY P                  \ Restore the indicator number into Y

 INY                    \ Increment the indicator number

 CPY #4                 \ Check to see if we have drawn the last energy bank

 BNE DLL9               \ Loop back to DLL9 if we have more banks to draw,
                        \ otherwise we are done

\ ******************************************************************************
\
\       Name: DIALS (Part 4 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: shields, fuel, laser & cabin temp, altitude
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #&78               \ Set SC(1 0) = &7810, which is the screen address for
 STA SC+1               \ the character block containing the left end of the
 LDA #&10               \ top indicator in the left part of the dashboard, the
 STA SC                 \ one showing the forward shield

 LDA FSH                \ Draw the forward shield indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the aft shield)

 LDA ASH                \ Draw the aft shield indicator using a range of 0-255,
 JSR DILX               \ and increment SC to point to the next indicator (the
                        \ fuel level)

 LDA QQ14               \ Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             \ and increment SC to point to the next indicator (the
                        \ cabin temperature)

 JSR PZW                \ Call PZW to set A to the colour for dangerous values
                        \ and X to the colour for safe values

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values, which
                        \ we use for the cabin and laser temperature bars

 LDX #11                \ Set T1 to 11, the threshold at which we change the
 STX T1                 \ cabin and laser temperature indicators' colours

 LDA CABTMP             \ Draw the cabin temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the laser temperature)

 LDA GNTMP              \ Draw the laser temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the altitude)

 LDA #240               \ Set T1 to 240, the threshold at which we change the
 STA T1                 \ altitude indicator's colour. As the altitude has a
                        \ range of 0-255, pixel 16 will not be filled in, and
                        \ 240 would change the colour when moving between pixels
                        \ 15 and 16, so this effectively switches off the colour
                        \ change for the altitude indicator

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ 240, or &F0 (dashboard colour 2, yellow/white), so the
                        \ altitude indicator always shows in this colour

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255
 JSR DILX

 JMP COMPAS             \ We have now drawn all the indicators, so jump to
                        \ COMPAS to draw the compass, returning from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: PZW
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Fetch the current dashboard colours, to support flashing
\
\ ------------------------------------------------------------------------------
\
\ Set A and X to the colours we should use for indicators showing dangerous and
\ safe values respectively. This enables us to implement flashing indicators,
\ which is one of the game's configurable options.
\
\ If flashing is enabled, the colour returned in A (dangerous values) will be
\ red for 8 iterations of the main loop, and yellow/white for the next 8, before
\ going back to red. If we always use PZW to decide which colours we should use
\ when updating indicators, flashing colours will be automatically taken care of
\ for us.
\
\ The values returned are &F0 for yellow/white and &0F for red. These are mode 5
\ bytes that contain 4 pixels, with the colour of each pixel given in two bits,
\ the high bit from the first nibble (bits 4-7) and the low bit from the second
\ nibble (bits 0-3). So in &F0 each pixel is %10, or colour 2 (yellow or white,
\ depending on the dashboard palette), while in &0F each pixel is %01, or colour
\ 1 (red).
\
\ Returns:
\
\   A                   The colour to use for indicators with dangerous values
\
\   X                   The colour to use for indicators with safe values
\
\ ******************************************************************************

.PZW

 LDX #&F0               \ Set X to dashboard colour 2 (yellow/white)

 LDA MCNT               \ A will be non-zero for 8 out of every 16 main loop
 AND #%00001000         \ counts, when bit 4 is set, so this is what we use to
                        \ flash the "danger" colour

 AND FLH                \ A will be zeroed if flashing colours are disabled

 BEQ P%+4               \ If A is zero, skip to the LDA instruction below

 TXA                    \ Otherwise flashing colours are enabled and it's the
                        \ main loop iteration where we flash them, so set A to
                        \ colour 2 (yellow/white) and use the BIT trick below to
                        \ return from the subroutine

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &0F, or BIT &0FA9, which does nothing apart
                        \ from affect the flags

 LDA #&0F               \ Set A to dashboard colour 1 (red)

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
\ Other entry points:
\
\   DILX+2              The range of the indicator is 0-64 (for the fuel
\                       indicator)
\
\   DIL-1               The range of the indicator is 0-32 (for the speed
\                       indicator)
\
\   DIL                 The range of the indicator is 0-16 (for the energy
\                       banks)
\
\ ******************************************************************************

.DILX

 LSR A                  \ If we call DILX, we set A = A / 16, so A is 0-15
 LSR A

 LSR A                  \ If we call DILX+2, we set A = A / 4, so A is 0-15

 LSR A                  \ If we call DIL-1, we set A = A / 2, so A is 0-15

.DIL

                        \ If we call DIL, we leave A alone, so A is 0-15

 STA Q                  \ Store the indicator value in Q, now reduced to 0-15,
                        \ which is the length of the indicator to draw in pixels

 LDX #&FF               \ Set R = &FF, to use as a mask for drawing each row of
 STX R                  \ each character block of the bar, starting with a full
                        \ character's width of 4 pixels

 CMP T1                 \ If A >= T1 then we have passed the threshold where we
 BCS DL30               \ change bar colour, so jump to DL30 to set A to the
                        \ "high value" colour

 LDA K+1                \ Set A to K+1, the "low value" colour to use

 BNE DL31               \ Jump down to DL31 (this BNE is effectively a JMP as A
                        \ will never be zero)

.DL30

 LDA K                  \ Set A to K, the "high value" colour to use

.DL31

 STA COL                \ Store the colour of the indicator in COL

 LDY #2                 \ We want to start drawing the indicator on the third
                        \ line in this character row, so set Y to point to that
                        \ row's offset

 LDX #3                 \ Set up a counter in X for the width of the indicator,
                        \ which is 4 characters (each of which is 4 pixels wide,
                        \ to give a total width of 16 pixels)

.DL1

 LDA Q                  \ Fetch the indicator value (0-15) from Q into A

 CMP #4                 \ If Q < 4, then we need to draw the end cap of the
 BCC DL2                \ indicator, which is less than a full character's
                        \ width, so jump down to DL2 to do this

 SBC #4                 \ Otherwise we can draw a 4-pixel wide block, so
 STA Q                  \ subtract 4 from Q so it contains the amount of the
                        \ indicator that's left to draw after this character

 LDA R                  \ Fetch the shape of the indicator row that we need to
                        \ display from R, so we can use it as a mask when
                        \ painting the indicator. It will be &FF at this point
                        \ (i.e. a full 4-pixel row)

.DL5

 AND COL                \ Fetch the 4-pixel mode 5 colour byte from COL, and
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

 EOR #3                 \ If we get here then we are drawing the indicator's
 STA Q                  \ end cap, so Q is < 4, and this EOR flips the bits, so
                        \ instead of containing the number of indicator columns
                        \ we need to fill in on the left side of the cap's
                        \ character block, Q now contains the number of blank
                        \ columns there should be on the right side of the cap's
                        \ character block

 LDA R                  \ Fetch the current mask from R, which will be &FF at
                        \ this point, so we need to turn Q of the columns on the
                        \ right side of the mask to black to get the correct end
                        \ cap shape for the indicator

.DL3

 ASL A                  \ Shift the mask left so bit 0 is cleared, and then
 AND #%11101111         \ clear bit 4, which has the effect of shifting zeroes
                        \ from the left into each nibble (i.e. xxxx xxxx becomes
                        \ xxx0 xxx0, which blanks out the last column in the
                        \ 4-pixel mode 5 character block)

 DEC Q                  \ Decrement the counter for the number of columns to
                        \ blank out

 BPL DL3                \ If we still have columns to blank out in the mask,
                        \ loop back to DL3 until the mask is correct for the
                        \ end cap

 PHA                    \ Store the mask byte on the stack while we use the
                        \ accumulator for a bit

 LDA #0                 \ Change the mask so no bits are set, so the characters
 STA R                  \ after the one we're about to draw will be all blank

 LDA #99                \ Set Q to a high number (99, why not) so we will keep
 STA Q                  \ drawing blank characters until we reach the end of
                        \ the indicator row

 PLA                    \ Restore the mask byte from the stack so we can use it
                        \ to draw the end cap of the indicator

 JMP DL5                \ Jump back up to DL5 to draw the mask byte on-screen

.DL6

 INC SC+1               \ Increment the high byte of SC to point to the next
                        \ character row on-screen (as each row takes up exactly
                        \ one page of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

.DL9                    \ This label is not used but is in the original source

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

 LDY #1                 \ We want to start drawing the vertical indicator bar on
                        \ the second line in the indicator's character block, so
                        \ set Y to point to that row's offset

 STA Q                  \ Store the offset of the vertical bar to draw in Q

                        \ We are now going to work our way along the indicator
                        \ on the dashboard, from left to right, working our way
                        \ along one character block at a time. Y will be used as
                        \ a pixel row counter to work our way through the
                        \ character blocks, so each time we draw a character
                        \ block, we will increment Y by 8 to move on to the next
                        \ block (as each character block contains 8 rows)

.DLL10

 SEC                    \ Set A = Q - 4, so that A contains the offset of the
 LDA Q                  \ vertical bar from the start of this character block
 SBC #4

 BCS DLL11              \ If Q >= 4 then the character block we are drawing does
                        \ not contain the vertical indicator bar, so jump to
                        \ DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX Q                  \ Set X to the offset of the vertical bar, which we know
                        \ is within this character block

 STA Q                  \ Set Q to a high number (&FF, why not) so we will keep
                        \ drawing blank characters after this one until we reach
                        \ the end of the indicator row

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

 STA Q                  \ Update Q with the new offset of the vertical bar, so
                        \ it becomes the offset after the character block we
                        \ are about to draw

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

 INC SC+1               \ Increment the high byte of SC to point to the next
                        \ character row on-screen (as each row takes up exactly
                        \ one page of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ESCAPE
\       Type: Subroutine
\   Category: Flight
\    Summary: Launch our escape pod
\
\ ------------------------------------------------------------------------------
\
\ This routine displays our doomed Cobra Mk III disappearing off into the ether
\ before arranging our replacement ship. Called when we press ESCAPE during
\ flight and have an escape pod fitted.
\
\ ******************************************************************************

.ESCAPE

 JSR RES2               \ Reset a number of flight variables and workspaces

 LDX #ESC	            \ AJD
 STX &8C
 JSR FRS1

 LDA #&10               \ AJD
 STA &61
 LDA #&C2
 STA &64
 LSR A
 STA &66

.ESL1

 JSR MVEIT              \ Call MVEIT to move the escape pod in space AJD

 JSR LL9                \ Call LL9 to draw the Cobra on-screen

 DEC INWK+32            \ Decrement the counter in byte #32

 BNE ESL1               \ Loop back to keep moving the Cobra until the AI flag
                        \ is 0, which gives it time to drift away from our pod

 JSR SCAN               \ Call SCAN to remove the Cobra from the scanner (by
                        \ redrawing it)

 LDA #0                 \ Set A = 0 so we can use it to zero the contents of
                        \ the cargo hold

 STA QQ20+&10
 LDX #&0C	\LDX #&10	\ save gold/plat/gems

.ESL2

 STA QQ20,X             \ Set the X-th byte of QQ20 to zero, so we no longer
                        \ have any of item type X in the cargo hold

 DEX                    \ Decrement the counter

 BPL ESL2               \ Loop back to ESL2 until we have emptied the entire
                        \ cargo hold

 STA FIST               \ Launching an escape pod also clears our criminal
                        \ record, so set our legal status in FIST to 0 ("clean")

 STA ESCP               \ The escape pod is a one-use item, so set ESCP to 0 so
                        \ we no longer have one fitted

 INC new_hold           \ AJD
 LDA new_range
 STA QQ14
 JSR ping
 JSR TT111
 JSR jmp

 JMP GOIN               \ Go to the docking bay (i.e. show the ship hanger
                        \ screen) and return from the subroutine with a tail
                        \ call

\ ******************************************************************************
\
\ Save output/ELTB.bin
\
\ ******************************************************************************

PRINT "ELITE B"
PRINT "Assembled at ", ~CODE_B%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE_B%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD_B%

PRINT "S.ELTB ", ~CODE_B%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD_B%
\SAVE "output/D.ELTB.bin", CODE_B%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE C FILE
\
\ ******************************************************************************

CODE_C% = P%
LOAD_C% = LOAD% +P% - CODE%

.TA34

 LDA #&00
 JSR l_41bf
 BEQ l_210c
 JMP l_21c5

.l_210c

 JSR l_2160
 JSR l_43b1
 LDA #&FA
 JMP l_36e4

.l_2117

 LDA &30
 BNE l_2150
 LDA &66
 ASL A
 BMI TA34
 LSR A
 TAX
 LDA UNIV,X
 STA &22
 LDA UNIV+&01,X
 JSR l_2409
 LDA &D4
 ORA &D7
 ORA &DA
 AND #&7F
 ORA &D3
 ORA &D6
 ORA &D9
 BNE l_2166
 LDA &66
 CMP #&82
 BEQ l_2150
 LDY #&23	\ missile damage
 SEC
 LDA (&22),Y
 SBC #&40
 BCS n_misshit
 LDY #&1F
 LDA (&22),Y
 BIT l_216d+&01
 BNE l_2150
 ORA #&80	\ missile hits

.n_misshit

 STA (&22),Y

.l_2150

 LDA &46
 ORA &49
 ORA &4C
 BNE l_215d
 LDA #&50
 JSR l_36e4

.l_215d

 JSR l_43ce

.l_2160

 ASL &65
 SEC
 ROR &65

.l_2165

 RTS

.l_2166

 JSR DORND
 CMP #&10
 BCS l_2174

.l_216d

 LDY #&20
 LDA (&22),Y
 LSR A
 BCS l_2177

.l_2174

 JMP l_221a

.l_2177

 JMP l_3813

.TACTICS

 LDY #&03
 STY &99
 INY
 STY &9A
 LDA #&16
 STA &94
 CPX #&01
 BEQ l_2117
 CPX #&02
 BNE l_21bb
 LDA &6A
 AND #&04
 BNE l_21a6
 LDA &0328
 ORA &033F	\ no shuttles if docking computer on
 BNE l_2165
 JSR DORND
 CMP #&FD
 BCC l_2165
 AND #&01
 ADC #&08
 TAX
 BNE l_21b6	\ BRA

.l_21a6

 JSR DORND
 CMP #&F0
 BCC l_2165
 LDA &032E
 CMP #&07	\ viper hordes
 BCS l_21d4
 LDX #&10

.l_21b6

 LDA #&F1
 JMP l_2592

.l_21bb

 LDY #&0E
 LDA &69
 CMP (&1E),Y
 BCS l_21c5
 INC &69

.l_21c5

 CPX #&1E
 BNE l_21d5
 LDA &033B
 BNE l_21d5
 LSR &66
 ASL &66
 LSR &61

.l_21d4

 RTS

.l_21d5

 JSR DORND
 LDA &6A
 LSR A
 BCC l_21e1
 CPX #&64
 BCS l_21d4

.l_21e1

 LSR A
 BCC l_21f3
 LDX FIST
 CPX #&28
 BCC l_21f3
 LDA &6A
 ORA #&04
 STA &6A
 LSR A
 LSR A

.l_21f3

 LSR A
 BCS l_2203
 LSR A
 LSR A
 BCC l_21fd
 JMP l_2346

.l_21fd

 LDY #&00
 JSR l_42ae
 JMP l_2324

.l_2203

 LSR A
 BCC l_2211
 LDA &0320
 BEQ l_2211
 LDA &66
 AND #&81
 STA &66

.l_2211

 LDX #&08

.l_2213

 LDA &46,X
 STA &D2,X
 DEX
 BPL l_2213

.l_221a

 JSR l_42bd
 JSR TAS3-2
 STA &93
 LDA &8C
 CMP #&01
 BNE l_222b
 JMP l_22dd

.l_222b

 CMP #&0E
 BNE l_223b
 JSR DORND
 CMP #&C8
 BCC l_223b
 LDX #&0F
 JMP l_21b6

.l_223b

 JSR DORND
 CMP #&FA
 BCC l_2249
 JSR DORND
 ORA #&68
 STA &63

.l_2249

 LDY #&0E
 LDA (&1E),Y
 LSR A
 CMP &69
 BCC l_2294
 LSR A
 LSR A
 CMP &69
 BCC l_226d
 JSR DORND
 CMP #&E6
 BCC l_226d
 LDX &8C
 LDA l_563d,X
 BPL l_226d
 LDA #&00
 STA &66
 JMP l_258e

.l_226d

 LDA &65
 AND #&07
 BEQ l_2294
 STA &D1
 JSR DORND
 \	AND #&1F
 AND #&0F
 CMP &D1
 BCS l_2294
 LDA &30
 BNE l_2294
 DEC &65
 LDA &8C
 CMP #&1D
 BNE l_2291
 LDX #&1E
 LDA &66
 JMP l_2592

.l_2291

 JMP l_43be

.l_2294

 LDA #&00
 JSR l_41bf
 AND #&E0
 BNE l_22c6
 LDX &93
 CPX #&A0
 BCC l_22c6
 LDY #&13
 LDA (&1E),Y
 AND #&F8
 BEQ l_22c6
 LDA &65
 ORA #&40
 STA &65
 CPX #&A3
 BCC l_22c6
 LDA (&1E),Y
 LSR A
 JSR l_36e4
 DEC &62
 LDA &30
 BNE l_2311
 LDA #&08
 JMP l_43f3

.l_22c6

 LDA &4D
 CMP #&03
 BCS l_22d4
 LDA &47
 ORA &4A
 AND #&FE
 BEQ l_22e6

.l_22d4

 JSR DORND
 ORA #&80
 CMP &66
 BCS l_22e6

.l_22dd

 JSR l_245d
 LDA &93
 EOR #&80

.l_22e4

 STA &93

.l_22e6

 LDY #&10
 JSR TAS3
 TAX
 JSR l_2332
 STA &64
 LDA &63
 ASL A
 CMP #&20
 BCS l_2305
 LDY #&16
 JSR TAS3
 TAX
 EOR &64
 JSR l_2332
 STA &63

.l_2305

 LDA &93
 BMI l_2312
 CMP &94
 BCC l_2312
 LDA #&03
 STA &62

.l_2311

 RTS

.l_2312

 AND #&7F
 CMP #&12
 BCC l_2323
 LDA #&FF
 LDX &8C
 CPX #&01
 BNE l_2321
 ASL A

.l_2321

 STA &62

.l_2323

 RTS

.l_2324

 JSR TAS3-2
 CMP #&98
 BCC l_232f
 LDX #&00
 STX &9A

.l_232f

 JMP l_22e4

.l_2332

 EOR #&80
 AND #&80
 STA &D1
 TXA
 ASL A
 CMP &9A
 BCC l_2343
 LDA &99
 ORA &D1
 RTS

.l_2343

 LDA &D1
 RTS

.l_2346

 LDA #&06
 STA &9A
 LSR A
 STA &99
 LDA #&1D
 STA &94
 LDA &0320
 BNE l_2359

.l_2356

 JMP l_21fd

.l_2359

 JSR l_2403
 LDA &D4
 ORA &D7
 ORA &DA
 AND #&7F
 BNE l_2356
 JSR l_42e0
 LDA &81
 STA &40
 JSR l_42bd
 LDY #&0A
 JSR l_243b
 BMI l_239a
 CMP #&23
 BCC l_239a
 JSR TAS3-2
 CMP #&A2
 BCS l_23b4
 LDA &40
 CMP #&9D
 BCC l_238c
 LDA &8C
 BMI l_23b4

.l_238c

 JSR l_245d
 JSR l_2324

.l_2392

 LDX #&00
 STX &62
 INX
 STX &61
 RTS

.l_239a

 JSR l_2403
 JSR l_2470
 JSR l_2470
 JSR l_42bd
 JSR l_245d
 JMP l_2324

.l_23ac

 INC &62
 LDA #&7F
 STA &63
 BNE l_23f9

.l_23b4

 LDX #&00
 STX &9A
 STX &64
 LDA &8C
 BPL l_23de
 EOR &34
 EOR &35
 ASL A
 LDA #&02
 ROR A
 STA &63
 LDA &34
 ASL A
 CMP #&0C
 BCS l_2392
 LDA &35
 ASL A
 LDA #&02
 ROR A
 STA &64
 LDA &35
 ASL A
 CMP #&0C
 BCS l_2392

.l_23de

 STX &63
 LDA &5C
 STA &34
 LDA &5E
 STA &35
 LDA &60
 STA &36
 LDY #&10
 JSR l_243b
 ASL A
 CMP #&42
 BCS l_23ac
 JSR l_2392

.l_23f9

 LDA &DC
 BNE l_2402

.top_6a

 ASL &6A
 SEC
 ROR &6A

.l_2402

 RTS

.l_2403

 LDA #&25
 STA &22
 LDA #&09

.l_2409

 STA &23
 LDY #&02
 JSR l_2417
 LDY #&05
 JSR l_2417
 LDY #&08

.l_2417

 LDA (&22),Y
 EOR #&80
 STA &43
 DEY
 LDA (&22),Y
 STA &42
 DEY
 LDA (&22),Y
 STA &41
 STY &80
 LDX &80
 JSR MVT3
 LDY &80
 STA &D4,X
 LDA &42
 STA &D3,X
 LDA &41
 STA &D2,X
 RTS

.l_243b

 LDX &0925,Y
 STX &81
 LDA &34
 JSR MULT12
 LDX &0927,Y
 STX &81
 LDA &35
 JSR MAD
 STA &83
 STX &82
 LDX &0929,Y
 STX &81
 LDA &36
 JMP MAD

.l_245d

 LDA &34
 EOR #&80
 STA &34
 LDA &35
 EOR #&80
 STA &35
 LDA &36
 EOR #&80
 STA &36
 RTS

.l_2470

 JSR l_2473

.l_2473

 LDA &092F
 LDX #&00
 JSR l_2488
 LDA &0931
 LDX #&03
 JSR l_2488
 LDA &0933
 LDX #&06

.l_2488

 ASL A
 STA &82
 LDA #&00
 ROR A
 EOR #&80
 EOR &D4,X
 BMI l_249f
 LDA &82
 ADC &D2,X
 STA &D2,X
 BCC l_249e
 INC &D3,X

.l_249e

 RTS

.l_249f

 LDA &D2,X
 SEC
 SBC &82
 STA &D2,X
 LDA &D3,X
 SBC #&00
 STA &D3,X
 BCS l_249e
 LDA &D2,X
 EOR #&FF
 ADC #&01
 STA &D2,X
 LDA &D3,X
 EOR #&FF
 ADC #&00
 STA &D3,X
 LDA &D4,X
 EOR #&80
 STA &D4,X
 JMP l_249e

.l_24c7

 CLC
 LDA &4E
 BNE l_2505
 LDA &8C
 BMI l_2505
 LDA &65
 AND #&20
 ORA &47
 ORA &4A
 BNE l_2505
 LDA &46
 JSR SQUA2
 STA &83
 LDA &1B
 STA &82
 LDA &49
 JSR SQUA2
 TAX
 LDA &1B
 ADC &82
 STA &82
 TXA
 ADC &83
 BCS l_2506
 STA &83
 LDY #&02
 LDA (&1E),Y
 CMP &83
 BNE l_2505
 DEY
 LDA (&1E),Y
 CMP &82

.l_2505

 RTS

.l_2506

 CLC
 RTS

.FRS1

 JSR l_3f26
 LDA #&1C
 STA &49
 LSR A
 STA &4C
 LDA #&80
 STA &4B
 LDA &45
 ASL A
 ORA #&80
 STA &66

.l_251d

 LDA #&60
 STA &54
 ORA #&80
 STA &5C
 LDA &7D
 ROL A
 STA &61
 TXA
 JMP l_3768

.l_252e

 LDX #&01
 JSR FRS1
 BCC l_2589
 LDX &45
 JSR ship_SC
 LDA FRIN,X
 JSR l_254d
 DEC cmdr_misl
 JSR l_3f3b	\ redraw missiles
 STY target
 STX &45
 JMP n_sound30

.anger_8c

 LDA &8C

.l_254d

 CMP #&02
 BEQ l_2580
 LDY #&24
 LDA (&20),Y
 AND #&20
 BEQ l_255c
 JSR l_2580

.l_255c

 LDY #&20
 LDA (&20),Y
 BEQ l_2505
 ORA #&80
 STA (&20),Y
 LDY #&1C
 LDA #&02
 STA (&20),Y
 ASL A
 LDY #&1E
 STA (&20),Y
 LDA &8C
 CMP #&0B
 BCC l_257f
 LDY #&24
 LDA (&20),Y
 ORA #&04
 STA (&20),Y

.l_257f

 RTS

.l_2580

 LDA &0949
 ORA #&04
 STA &0949
 RTS

.l_2589

 LDA #&C9
 JMP l_45c6

.l_258e

 LDX #&03

.l_2590

 LDA #&FE

.l_2592

 STA &06
 TXA
 PHA
 LDA &1E
 PHA
 LDA &1F
 PHA
 LDA &20
 PHA
 LDA &21
 PHA
 LDY #&24

.l_25a4

 LDA &46,Y
 STA &0100,Y
 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_25a4
 LDA &6A
 AND #&1C
 STA &6A
 LDA &8C
 CMP #&02
 BNE l_25db
 TXA
 PHA
 LDA #&20
 STA &61
 LDX #&00
 LDA &50
 JSR l_261a
 LDX #&03
 LDA &52
 JSR l_261a
 LDX #&06
 LDA &54
 JSR l_261a
 PLA
 TAX

.l_25db

 LDA &06
 STA &66
 LSR &63
 ASL &63
 TXA
 CMP #&09
 BCS l_25fe
 CMP #&04
 BCC l_25fe
 PHA
 JSR DORND
 ASL A
 STA &64
 TXA
 AND #&0F
 STA &61
 LDA #&FF
 ROR A
 STA &63
 PLA

.l_25fe

 JSR l_3768
 PLA
 STA &21
 PLA
 STA &20
 LDX #&24

.l_2609

 LDA &0100,X
 STA &46,X
 DEX
 BPL l_2609
 PLA
 STA &1F
 PLA
 STA &1E
 PLA
 TAX
 RTS

.l_261a

 ASL A
 STA &82
 LDA #&00
 ROR A
 JMP MVT1

.l_2623

 LDA #&38
 JSR l_43f3
 LDA #&01
 STA &0348
 LDA #&04
 JSR l_263d
 DEC &0348
 RTS

.l_2636

 JSR n_sound30
 LDA #&08

.l_263d

 STA &95
 JSR TTX66

.HFS1

 LDX #&80
 STX &D2
 LDX #&60
 STX &E0
 LDX #&00
 STX &96
 STX &D3
 STX &E1

.l_2652

 JSR l_265e
 INC &96
 LDX &96
 CPX #&08
 BNE l_2652
 RTS

.l_265e

 LDA &96
 AND #&07
 CLC
 ADC #&08
 STA &40

.l_2667

 LDA #&01
 STA &6B
 JSR CIRCLE2
 ASL &40
 BCS l_2678
 LDA &40
 CMP #&A0
 BCC l_2667

.l_2678

 RTS

.STARS2

 LDA #&00
 CPX #&02
 ROR A
 STA &99
 EOR #&80
 STA &9A
 JSR l_272d
 LDY &03C3

.l_268a

 LDA &0FA8,Y
 STA &88
 LSR A
 LSR A
 LSR A
 JSR DV41
 LDA &1B
 EOR &9A
 STA &83
 LDA &0F6F,Y
 STA &1B
 LDA &0F5C,Y
 STA &34
 JSR ADD
 STA &83
 STX &82
 LDA &0F82,Y
 STA &35
 EOR &7B
 LDX &2B
 JSR MULTS-2
 JSR ADD
 STX &24
 STA &25
 LDX &0F95,Y
 STX &82
 LDX &35
 STX &83
 LDX &2B
 EOR &7C
 JSR MULTS-2
 JSR ADD
 STX &26
 STA &27
 LDX &31
 EOR &32
 JSR MULTS-2
 STA &81
 LDA &24
 STA &82
 LDA &25
 STA &83
 EOR #&80
 JSR MAD
 STA &25
 TXA
 STA &0F6F,Y
 LDA &26
 STA &82
 LDA &27
 STA &83
 JSR MAD
 STA &83
 STX &82
 LDA #&00
 STA &1B
 LDA &8D
 JSR PIX1
 LDA &25
 STA &0F5C,Y
 STA &34
 AND #&7F
 CMP #&74
 BCS l_2748
 LDA &27
 STA &0F82,Y
 STA &35
 AND #&7F
 CMP #&74
 BCS l_275b

.l_2724

 JSR PIXEL2
 DEY
 BEQ l_272d
 JMP l_268a

.l_272d

 LDA &8D
 EOR &99
 STA &8D
 LDA &32
 EOR &99
 STA &32
 EOR #&80
 STA &33
 LDA &7B
 EOR &99
 STA &7B
 EOR #&80
 STA &7C
 RTS

.l_2748

 JSR DORND
 STA &35
 STA &0F82,Y
 LDA #&73
 ORA &99
 STA &34
 STA &0F5C,Y
 BNE l_276c

.l_275b

 JSR DORND
 STA &34
 STA &0F5C,Y
 LDA #&6E
 ORA &33
 STA &35
 STA &0F82,Y

.l_276c

 JSR DORND
 ORA #&08
 STA &88
 STA &0FA8,Y
 BNE l_2724

.l_2778

 STA &40

.n_store

 STA &41
 STA &42
 STA &43
 CLC
 RTS

.MULT3

 STA &82
 AND #&7F
 STA &42
 LDA &81
 AND #&7F
 BEQ l_2778
 SEC
 SBC #&01
 STA &D1
 LDA font
 LSR &42
 ROR A
 STA &41
 LDA &1B
 ROR A
 STA &40
 LDA #&00
 LDX #&18

.l_27a3

 BCC l_27a7
 ADC &D1

.l_27a7

 ROR A
 ROR &42
 ROR &41
 ROR &40
 DEX
 BNE l_27a3
 STA &D1
 LDA &82
 EOR &81
 AND #&80
 ORA &D1
 STA &43
 RTS

.MLS2

 LDX &24
 STX &82
 LDX &25
 STX &83

.MLS1

 LDX &31

 STX &1B

.MULTS

 TAX
 AND #&80
 STA &D1
 TXA
 AND #&7F
 BEQ MU6
 TAX
 DEX
 STX &06
 LDA #&00
 LSR &1B
 BCC l_27e0
 ADC &06

.l_27e0

 ROR A
 ROR &1B
 BCC l_27e7
 ADC &06

.l_27e7

 ROR A
 ROR &1B
 BCC l_27ee
 ADC &06

.l_27ee

 ROR A
 ROR &1B
 BCC l_27f5
 ADC &06

.l_27f5

 ROR A
 ROR &1B
 BCC l_27fc
 ADC &06

.l_27fc

 ROR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 LSR A
 ROR &1B
 ORA &D1
 RTS

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
\       Name: MLU1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate Y1 = y_hi and (A P) = |y_hi| * Q for Y-th stardust
\
\ ------------------------------------------------------------------------------
\
\ Do the following assignment, and multiply the Y-th stardust particle's
\ y-coordinate with an unsigned number Q:
\
\   Y1 = y_hi
\
\   (A P) = |y_hi| * Q
\
\ ******************************************************************************

.MLU1

 LDA SY,Y               \ Set Y1 the Y-th byte of SY
 STA Y1

                        \ Fall through into MLU2 to calculate:
                        \
                        \   (A P) = |A| * Q

\ ******************************************************************************
\
\       Name: MLU2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = |A| * Q
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of a sign-magnitude 8-bit number P with an
\ unsigned number Q:
\
\   (A P) = |A| * Q
\
\ ******************************************************************************

.MLU2

 AND #%01111111         \ Clear the sign bit in P, so P = |A|
 STA P

                        \ Fall through into MULTU to calculate:
                        \
                        \   (A P) = P * Q
                        \         = |A| * Q

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
\       Name: MU6
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Set P(1 0) = (A A)
\
\ ------------------------------------------------------------------------------
\
\ In practice this is only called via a BEQ following an AND instruction, in
\ which case A = 0, so this routine effectively does this:
\
\   P(1 0) = 0
\
\ ******************************************************************************

.MU6

 STA P+1                \ Set P(1 0) = (A A)
 STA P

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

.l_286c

 BCC l_2870
 ADC &D1

.l_2870

 ROR A
 ROR &1B
 DEX
 BNE l_286c
 RTS

\ ******************************************************************************
\
\       Name: MLTU2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P+1 P) = (A ~P) * Q
\  Deep dive: Shift-and-add multiplication
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of an unsigned 16-bit number and an unsigned
\ 8-bit number:
\
\   (A P+1 P) = (A ~P) * Q
\
\ where ~P means P EOR %11111111 (i.e. P with all its bits flipped). In other
\ words, if you wanted to calculate &1234 * &56, you would:
\
\   * Set A to &12
\   * Set P to &34 EOR %11111111 = &CB
\   * Set Q to &56
\
\ before calling MLTU2.
\
\ This routine is like a mash-up of MU11 and FMLTU. It uses part of FMLTU's
\ inverted argument trick to work out whether or not to do an addition, and like
\ MU11 it sets up a counter in X to extract bits from (P+1 P). But this time we
\ extract 16 bits from (P+1 P), so the result is a 24-bit number. The core of
\ the algorithm is still the shift-and-add approach explained in MULT1, just
\ with more bits.
\
\ Returns:
\
\   Q                   Q is preserved
\
\ Other entry points:
\
\   MLTU2-2             Set Q to X, so this calculates (A P+1 P) = (A ~P) * X
\
\ ******************************************************************************

 STX Q                  \ Store X in Q

.MLTU2

 EOR #%11111111         \ Flip the bits in A and rotate right, storing the
 LSR A                  \ result in P+1, so we now calculate (P+1 P) * Q
 STA P+1

 LDA #0                 \ Set A = 0 so we can start building the answer in A

 LDX #16                \ Set up a counter in X to count the 16 bits in (P+1 P)

 ROR P                  \ Set P = P >> 1 with bit 7 = bit 0 of A
                        \ and C flag = bit 0 of P

.MUL7

 BCS MU21               \ If C (i.e. the next bit from P) is set, do not do the
                        \ addition for this bit of P, and instead skip to MU21
                        \ to just do the shifts

 ADC Q                  \ Do the addition for this bit of P:
                        \
                        \   A = A + Q + C
                        \     = A + Q

 ROR A                  \ Rotate (A P+1 P) to the right, so we capture the next
 ROR P+1                \ digit of the result in P+1, and extract the next digit
 ROR P                  \ of (P+1 P) in the C flag

 DEX                    \ Decrement the loop counter

 BNE MUL7               \ Loop back for the next bit until P has been rotated
                        \ all the way

 RTS                    \ Return from the subroutine

.MU21

 LSR A                  \ Shift (A P+1 P) to the right, so we capture the next
 ROR P+1                \ digit of the result in P+1, and extract the next digit
 ROR P                  \ of (P+1 P) in the C flag

 DEX                    \ Decrement the loop counter

 BNE MUL7               \ Loop back for the next bit until P has been rotated
                        \ all the way

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MUT2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (S R) = XX(1 0) and (A P) = Q * A
\
\ ------------------------------------------------------------------------------
\
\ Do the following assignment, and multiplication of two signed 8-bit numbers:
\
\   (S R) = XX(1 0)
\   (A P) = Q * A
\
\ ******************************************************************************

.MUT2

 LDX XX+1               \ Set S = XX+1
 STX S

                        \ Fall through into MUT1 to do the following:
                        \
                        \   R = XX
                        \   (A P) = Q * A

\ ******************************************************************************
\
\       Name: MUT1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate R = XX and (A P) = Q * A
\
\ ------------------------------------------------------------------------------
\
\ Do the following assignment, and multiplication of two signed 8-bit numbers:
\
\   R = XX
\   (A P) = Q * A
\
\ ******************************************************************************

.MUT1

 LDX XX                 \ Set R = XX
 STX R

                        \ Fall through into MULT1 to do the following:
                        \
                        \   (A P) = Q * A

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
\       Name: TAS3
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Calculate the dot product of XX15 and an orientation vector
\
\ ------------------------------------------------------------------------------
\
\ Calculate the dot product of the vector in XX15 and one of the orientation
\ vectors, as determined by the value of Y. If vect is the orientation vector,
\ we calculate this:
\
\   (A X) = vect . XX15
\         = vect_x * XX15 + vect_y * XX15+1 + vect_z * XX15+2
\
\ Arguments:
\
\   Y                   The orientation vector:
\
\                         * If Y = 10, calculate nosev . XX15
\
\                         * If Y = 16, calculate roofv . XX15
\
\                         * If Y = 22, calculate sidev . XX15
\
\ Returns:
\
\   (A X)               The result of the dot product
\
\ Other entry points:
\
\   TAS3-2              Calculate nosev . XX15
\
\ ******************************************************************************

 LDY #10                \ Set Y = 10 so we calculate nosev . XX15

.TAS3

 LDX INWK,Y             \ Set Q = the Y-th byte of INWK, i.e. vect_x
 STX Q

 LDA XX15               \ Set A = XX15

 JSR MULT12             \ Set (S R) = Q * A
                        \           = vect_x * XX15

 LDX INWK+2,Y           \ Set Q = the Y+2-th byte of INWK, i.e. vect_y
 STX Q

 LDA XX15+1             \ Set A = XX15+1

 JSR MAD                \ Set (A X) = Q * A + (S R)
                        \           = vect_y * XX15+1 + vect_x * XX15

 STA S                  \ Set (S R) = (A X)
 STX R

 LDX INWK+4,Y           \ Set Q = the Y+2-th byte of INWK, i.e. vect_z
 STX Q

 LDA XX15+2             \ Set A = XX15+2

                        \ Fall through into MAD to set:
                        \
                        \   (A X) = Q * A + (S R)
                        \           = vect_z * XX15+2 + vect_y * XX15+1 +
                        \             vect_x * XX15

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
\       Name: DV42
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (P R) = 256 * DELTA / z_hi
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following division and remainder:
\
\   P = DELTA / (the Y-th stardust particle's z_hi coordinate)
\
\   R = remainder as a fraction of A, where 1.0 = 255
\
\ Another way of saying the above is this:
\
\   (P R) = 256 * DELTA / z_hi
\
\ DELTA is a value between 1 and 40, and the minimum z_hi is 16 (dust particles
\ are removed at lower values than this), so this means P is between 0 and 2
\ (as 40 / 16 = 2.5, so the maximum result is P = 2 and R = 128.
\
\ This uses the same shift-and-subtract algorithm as TIS2, but this time we
\ keep the remainder.
\
\ Arguments:
\
\   Y                   The number of the stardust particle to process
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.DV42

 LDA SZ,Y               \ Fetch the Y-th dust particle's z_hi coordinate into A

                        \ Fall through into DV41 to do:
                        \
                        \   (P R) = 256 * DELTA / A
                        \         = 256 * DELTA / Y-th stardust particle's z_hi

\ ******************************************************************************
\
\       Name: DV41
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (P R) = 256 * DELTA / A
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following division and remainder:
\
\   P = DELTA / A
\
\   R = remainder as a fraction of A, where 1.0 = 255
\
\ Another way of saying the above is this:
\
\   (P R) = 256 * DELTA / A
\
\ This uses the same shift-and-subtract algorithm as TIS2, but this time we
\ keep the remainder.
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.DV41

 STA Q                  \ Store A in Q

 LDA DELTA              \ Fetch the speed from DELTA into A

                        \ Fall through into DVID4 to do:
                        \
                        \   (P R) = 256 * A / Q
                        \         = 256 * DELTA / A

\ ******************************************************************************
\
\       Name: DVID4
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (P R) = 256 * A / Q
\  Deep dive: Shift-and-subtract division
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following division and remainder:
\
\   P = A / Q
\
\   R = remainder as a fraction of Q, where 1.0 = 255
\
\ Another way of saying the above is this:
\
\   (P R) = 256 * A / Q
\
\ This uses the same shift-and-subtract algorithm as TIS2, but this time we
\ keep the remainder.
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.DVID4

 LDX #8                 \ Set a counter in X to count the 8 bits in A

 ASL A                  \ Shift A left and store in P (we will build the result
 STA P                  \ in P)

 LDA #0                 \ Set A = 0 for us to build a remainder

.DVL4

 ROL A                  \ Shift A to the left

 BCS DV8                \ If the C flag is set (i.e. bit 7 of A was set) then
                        \ skip straight to the subtraction

 CMP Q                  \ If A < Q skip the following subtraction
 BCC DV5

.DV8

 SBC Q                  \ A >= Q, so set A = A - Q

 SEC                    \ Set the C flag, so that P gets a 1 shifted into bit 0

.DV5

 ROL P                  \ Shift P to the left, pulling the C flag into bit 0

 DEX                    \ Decrement the loop counter

 BNE DVL4               \ Loop back for the next bit until we have done all 8
                        \ bits of P

 JMP LL28+4             \ Jump to LL28+4 to convert the remainder in A into an
                        \ integer representation of the fractional value A / Q,
                        \ in R, where 1.0 = 255. LL28+4 always returns with the
                        \ C flag cleared, and we return from the subroutine
                        \ using a tail call

\ ******************************************************************************
\
\       Name: DVID3B2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)
\  Deep dive: Shift-and-subtract division
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following:
\
\   K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)
\
\ The actual division here is done as an 8-bit calculation using LL31, but this
\ routine shifts both the numerator (the top part of the division) and the
\ denominator (the bottom part of the division) around to get the multi-byte
\ result we want.
\
\ Specifically, it shifts both of them to the left as far as possible, keeping a
\ tally of how many shifts get done in each one - and specifically, the
\ difference in the number of shifts between the top and bottom (as shifting
\ both of them once in the same direction won't change the result). It then
\ divides the two highest bytes with the simple 8-bit routine in LL31, and
\ shifts the result by the difference in the number of shifts, which acts as a
\ scale factor to get the correct result.
\
\ Returns:
\
\   K(3 2 1 0)          The result of the division
\
\   X                   X is preserved
\
\ ******************************************************************************

.DVID3B2

 STA P+2                \ Set P+2 = A

 LDA INWK+6             \ Set Q = z_lo
 STA Q

 LDA INWK+7             \ Set R = z_hi
 STA R

 LDA INWK+8             \ Set S = z_sign
 STA S

.DVID3B

                        \ Given the above assignments, we now want to calculate
                        \ the following to get the result we want:
                        \
                        \   K(3 2 1 0) = P(2 1 0) / (S R Q)

 LDA P                  \ Make sure P(2 1 0) is at least 1
 ORA #1
 STA P

 LDA P+2                \ Set T to the sign of P+2 * S (i.e. the sign of the
 EOR S                  \ result) and store it in T
 AND #%10000000
 STA T

 LDY #0                 \ Set Y = 0 to store the scale factor

 LDA P+2                \ Clear the sign bit of P+2, so the division can be done
 AND #%01111111         \ with positive numbers and we'll set the correct sign
                        \ below, once all the maths is done
                        \
                        \ This also leaves A = P+2, which we use below

.DVL9

                        \ We now shift (A P+1 P) left until A >= 64, counting
                        \ the number of shifts in Y. This makes the top part of
                        \ the division as large as possible, thus retaining as
                        \ much accuracy as we can.  When we come to return the
                        \ final result, we shift the result by the number of
                        \ places in Y, and in the correct direction

 CMP #64                \ If A >= 64, jump down to DV14
 BCS DV14

 ASL P                  \ Shift (A P+1 P) to the left
 ROL P+1
 ROL A

 INY                    \ Increment the scale factor in Y

 BNE DVL9               \ Loop up to DVL9 (this BNE is effectively a JMP, as Y
                        \ will never be zero)

.DV14

                        \ If we get here, A >= 64 and contains the highest byte
                        \ of the numerator, scaled up by the number of left
                        \ shifts in Y

 STA P+2                \ Store A in P+2, so we now have the scaled value of
                        \ the numerator in P(2 1 0)

 LDA S                  \ Set A = |S|
 AND #%01111111

 BMI DV9                \ If bit 7 of A is set, jump down to DV9 to skip the
                        \ left-shifting of the denominator (though this branch
                        \ instruction has no effect as bit 7 of the above AND
                        \ can never be set, which is why this instruction was
                        \ removed from later versions)

.DVL6

                        \ We now shift (S R Q) left until bit 7 of S is set,
                        \ reducing Y by the number of shifts. This makes the
                        \ bottom part of the division as large as possible, thus
                        \ retaining as much accuracy as we can. When we come to
                        \ return the final result, we shift the result by the
                        \ total number of places in Y, and in the correct
                        \ direction, to give us the correct result
                        \
                        \ We set A to |S| above, so the following actually
                        \ shifts (A R Q)

 DEY                    \ Decrement the scale factor in Y

 ASL Q                  \ Shift (A R Q) to the left
 ROL R
 ROL A

 BPL DVL6               \ Loop up to DVL6 to do another shift, until bit 7 of A
                        \ is set and we can't shift left any further

.DV9

                        \ We have now shifted both the numerator and denominator
                        \ left as far as they will go, keeping a tally of the
                        \ overall scale factor of the various shifts in Y. We
                        \ can now divide just the two highest bytes to get our
                        \ result

 STA Q                  \ Set Q = A, the highest byte of the denominator

 LDA #254               \ Set R to have bits 1-7 set, so we can pass this to
 STA R                  \ LL31 to act as the bit counter in the division

 LDA P+2                \ Set A to the highest byte of the numerator

 JSR LL31               \ Call LL31 to calculate:
                        \
                        \   R = 256 * A / Q
                        \     = 256 * numerator / denominator

                        \ The result of our division is now in R, so we just
                        \ need to shift it back by the scale factor in Y

 LDA #0                 \ AJD
 JSR n_store

 TYA                    \ If Y is positive, jump to DV12
 BPL DV12

                        \ If we get here then Y is negative, so we need to shift
                        \ the result R to the left by Y places, and then set the
                        \ correct sign for the result

 LDA R                  \ Set A = R

.DVL8

 ASL A                  \ Shift (K+3 K+2 K+1 A) left
 ROL K+1
 ROL K+2
 ROL K+3

 INY                    \ Increment the scale factor in Y

 BNE DVL8               \ Loop back to DVL8 until we have shifted left by Y
                        \ places

 STA K                  \ Store A in K so the result is now in K(3 2 1 0)

 LDA K+3                \ Set K+3 to the sign in T, which we set above to the
 ORA T                  \ correct sign for the result
 STA K+3

 RTS                    \ Return from the subroutine

.DV13

                        \ If we get here then Y is zero, so we don't need to
                        \ shift the result R, we just need to set the correct
                        \ sign for the result

 LDA R                  \ Store R in K so the result is now in K(3 2 1 0)
 STA K

 LDA T                  \ Set K+3 to the sign in T, which we set above to the
 STA K+3                \ correct sign for the result

 RTS                    \ Return from the subroutine

.DV12

 BEQ DV13               \ We jumped here having set A to the scale factor in Y,
                        \ so this jumps up to DV13 if Y = 0

                        \ If we get here then Y is positive and non-zero, so we
                        \ need to shift the result R to the right by Y places
                        \ and then set the correct sign for the result. We also
                        \ know that K(3 2 1) will stay 0, as we are shifting the
                        \ lowest byte to the right, so no set bits will make
                        \ their way into the top three bytes

 LDA R                  \ Set A = R

.DVL10

 LSR A                  \ Shift A right

 DEY                    \ Decrement the scale factor in Y

 BNE DVL10              \ Loop back to DVL10 until we have shifted right by Y
                        \ places

 STA K                  \ Store the shifted A in K so the result is now in
                        \ K(3 2 1 0)

 LDA T                  \ Set K+3 to the sign in T, which we set above to the
 STA K+3                \ correct sign for the result

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: cntr
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Apply damping to the pitch or roll dashboard indicator
\
\ ------------------------------------------------------------------------------
\
\ Apply damping to the value in X, where X ranges from 1 to 255 with 128 as the
\ centre point (so X represents a position on a centre-based dashboard slider,
\ such as pitch or roll). If the value is in the left-hand side of the slider
\ (1-127) then it bumps the value up by 1 so it moves towards the centre, and
\ if it's in the right-hand side, it reduces it by 1, also moving it towards the
\ centre.
\
\ ******************************************************************************

.cntr

 LDA auto               \ If the docking computer is currently activated, jump
 BNE cnt2               \ to cnt2 to skip the following as we always want to
                        \ enable damping for the docking computer

 LDA DAMP               \ If DAMP is non-zero, then keyboard damping is not
 BNE RE1                \ enabled, so jump to RE1 to return from the subroutine

.cnt2

 TXA                    \ If X < 128, then it's in the left-hand side of the
 BPL BUMP               \ dashboard slider, so jump to BUMP to bump it up by 1,
                        \ to move it closer to the centre

 DEX                    \ Otherwise X >= 128, so it's in the right-hand side
 BMI RE1                \ of the dashboard slider, so decrement X by 1, and if
                        \ it's still >= 128, jump to RE1 to return from the
                        \ subroutine, otherwise fall through to BUMP to undo
                        \ the bump and then return

.BUMP

 INX                    \ Bump X up by 1, and if it hasn't overshot the end of
 BNE RE1                \ the dashboard slider, jump to RE1 to return from the
                        \ subroutine, otherwise fall through to REDU to drop
                        \ it down by 1 again

.REDU

 DEX                    \ Reduce X by 1, and if we have reached 0 jump up to
 BEQ BUMP               \ BUMP to add 1, because we need the value to be in the
                        \ range 1 to 255

.RE1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BUMP2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Bump up the value of the pitch or roll dashboard indicator
\
\ ------------------------------------------------------------------------------
\
\ Increase ("bump up") X by A, where X is either the current rate of pitch or
\ the current rate of roll.
\
\ The rate of pitch or roll ranges from 1 to 255 with 128 as the centre point.
\ This is the amount by which the pitch or roll is currently changing, so 1
\ means it is decreasing at the maximum rate, 128 means it is not changing,
\ and 255 means it is increasing at the maximum rate. These values correspond
\ to the line on the DC or RL indicators on the dashboard, with 1 meaning full
\ left, 128 meaning the middle, and 255 meaning full right.
\
\ If bumping up X would push it past 255, then X is set to 255.
\
\ If keyboard auto-recentre is configured and the result is less than 128, we
\ bump X up to the mid-point, 128. This is the equivalent of having a roll or
\ pitch in the left half of the indicator, when increasing the roll or pitch
\ should jump us straight to the mid-point.
\
\ Other entry points:
\
\   RE2+2               Restore A from T and return from the subroutine
\
\ ******************************************************************************

.BUMP2

 STA T                  \ Store argument A in T so we can restore it later

 TXA                    \ Copy argument X into A

 CLC                    \ Clear the C flag so we can do addition without the
                        \ C flag affecting the result

 ADC T                  \ Set X = A = argument X + argument A
 TAX

 BCC RE2                \ If the C flag is clear, then we didn't overflow, so
                        \ jump to RE2 to auto-recentre and return the result

 LDX #255               \ We have an overflow, so set X to the maximum possible
                        \ value of 255

.RE2

 BPL RE3+2              \ If X has bit 7 clear (i.e. the result < 128), then
                        \ jump to RE3+2 in routine REDU2 to do an auto-recentre,
                        \ if configured, because the result is on the left side
                        \ of the centre point of 128

                        \ Jumps to RE2+2 end up here

 LDA T                  \ Restore the original argument A from T into A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: REDU2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Reduce the value of the pitch or roll dashboard indicator
\
\ ------------------------------------------------------------------------------
\
\ Reduce X by A, where X is either the current rate of pitch or the current
\ rate of roll.
\
\ The rate of pitch or roll ranges from 1 to 255 with 128 as the centre point.
\ This is the amount by which the pitch or roll is currently changing, so 1
\ means it is decreasing at the maximum rate, 128 means it is not changing,
\ and 255 means it is increasing at the maximum rate. These values correspond
\ to the line on the DC or RL indicators on the dashboard, with 1 meaning full
\ left, 128 meaning the middle, and 255 meaning full right.
\
\ If reducing X would bring it below 1, then X is set to 1.
\
\ If keyboard auto-recentre is configured and the result is greater than 128, we
\ reduce X down to the mid-point, 128. This is the equivalent of having a roll
\ or pitch in the right half of the indicator, when decreasing the roll or pitch
\ should jump us straight to the mid-point.
\
\ Other entry points:
\
\   RE3+2               Auto-recentre the value in X, if keyboard auto-recentre
\                       is configured
\
\ ******************************************************************************

.REDU2

 STA T                  \ Store argument A in T so we can restore it later

 TXA                    \ Copy argument X into A

 SEC                    \ Set the C flag so we can do subtraction without the
                        \ C flag affecting the result

 SBC T                  \ Set X = A = argument X - argument A
 TAX

 BCS RE3                \ If the C flag is set, then we didn't underflow, so
                        \ jump to RE3 to auto-recentre and return the result

 LDX #1                 \ We have an underflow, so set X to the minimum possible
                        \ value, 1

.RE3

 BPL RE2+2              \ If X has bit 7 clear (i.e. the result < 128), then
                        \ jump to RE2+2 above to return the result as is,
                        \ because the result is on the left side of the centre
                        \ point of 128, so we don't need to auto-centre

                        \ Jumps to RE3+2 end up here

                        \ If we get here, then we need to apply auto-recentre,
                        \ if it is configured

 LDA DJD                \ If keyboard auto-recentre is disabled, then
 BNE RE2+2              \ jump to RE2+2 to restore A and return

 LDX #128               \ If keyboard auto-recentre is enabled, set X to 128
 BMI RE2+2              \ (the middle of our range) and jump to RE2+2 to
                        \ restore A and return

\ ******************************************************************************
\
\       Name: ARCTAN
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Calculate A = arctan(P / Q)
\  Deep dive: The sine, cosine and arctan tables
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following:
\
\   A = arctan(P / Q)
\
\ In other words, this finds the angle in the right-angled triangle where the
\ opposite side to angle A is length P and the adjacent side to angle A has
\ length Q, so:
\
\   tan(A) = P / Q
\
\ ******************************************************************************

.ARCTAN

 LDA P                  \ Set T1 = P EOR Q, which will have the sign of P * Q
 EOR Q
 STA T1

 LDA Q                  \ If Q = 0, jump to AR2 to return a right angle
 BEQ AR2

 ASL A                  \ Set Q = |Q| * 2 (this is a quick way of clearing the
 STA Q                  \ sign bit, and we don't need to shift right again as we
                        \ only ever use this value in the division with |P| * 2,
                        \ which we set next)

 LDA P                  \ Set A = |P| * 2
 ASL A

 CMP Q                  \ If A >= Q, i.e. |P| > |Q|, jump to AR1 to swap P
 BCS AR1                \ and Q around, so we can still use the lookup table

 JSR ARS1               \ Call ARS1 to set the following from the lookup table:
                        \
                        \   A = arctan(A / Q)
                        \     = arctan(|P / Q|)

 SEC                    \ Set the C flag so the SBC instruction in AR3 will be
                        \ correct, should we jump there

.AR4

 LDX T1                 \ If T1 is negative, i.e. P and Q have different signs,
 BMI AR3                \ jump down to AR3 to return arctan(-|P / Q|)

 RTS                    \ Otherwise P and Q have the same sign, so our result is
                        \ correct and we can return from the subroutine

.AR1

                        \ We want to calculate arctan(t) where |t| > 1, so we
                        \ can use the calculation described in the documentation
                        \ for the ACT table, i.e. 64 - arctan(1 / t)

 LDX Q                  \ Swap the values in Q and P, using the fact that we
 STA Q                  \ called AR1 with A = P
 STX P                  \
 TXA                    \ This also sets A = P (which now contains the original
                        \ argument |Q|)

 JSR ARS1               \ Call ARS1 to set the following from the lookup table:
                        \
                        \   A = arctan(A / Q)
                        \     = arctan(|Q / P|)
                        \     = arctan(1 / |P / Q|)

 STA T                  \ Set T = 64 - T
 LDA #64
 SBC T

 BCS AR4                \ Jump to AR4 to continue the calculation (this BCS is
                        \ effectively a JMP as the subtraction will never
                        \ underflow, as ARS1 returns values in the range 0-31)

.AR2

                        \ If we get here then Q = 0, so tan(A) = infinity and
                        \ A is a right angle, or 0.25 of a circle. We allocate
                        \ 255 to a full circle, so we should return 63 for a
                        \ right angle

 LDA #63                \ Set A to 63, to represent a right angle

 RTS                    \ Return from the subroutine

.AR3

                        \ A contains arctan(|P / Q|) but P and Q have different
                        \ signs, so we need to return arctan(-|P / Q|), using
                        \ the calculation described in the documentation for the
                        \ ACT table, i.e. 128 - A

 STA T                  \ Set A = 128 - A
 LDA #128               \
\SEC                    \ The SEC instruction is commented out in the original
 SBC T                  \ source, and isn't required as we did a SEC before
                        \ calling AR3

 RTS                    \ Return from the subroutine

.ARS1

                        \ This routine fetches arctan(A / Q) from the ACT table

 JSR LL28               \ Call LL28 to calculate:
                        \
                        \   R = 256 * A / Q

 LDA R                  \ Set X = R / 8
 LSR A                  \       = 32 * A / Q
 LSR A                  \
 LSR A                  \ so X has the value t * 32 where t = A / Q, which is
 TAX                    \ what we need to look up values in the ACT table

 LDA ACT,X              \ Fetch ACT+X from the ACT table into A, so now:
                        \
                        \   A = value in ACT + X
                        \     = value in ACT + (32 * A / Q)
                        \     = arctan(A / Q)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LASLI
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw the laser lines for when we fire our lasers
\
\ ------------------------------------------------------------------------------
\
\ Draw the laser lines, aiming them to slightly different place each time so
\ they appear to flicker and dance. Also heat up the laser temperature and drain
\ some energy.
\
\ Other entry points:
\
\   LASLI2              Just draw the current laser lines without moving the
\                       centre point, draining energy or heating up. This has
\                       the effect of removing the lines from the screen
\
\   LASLI-1             Contains an RTS
\
\ ******************************************************************************

.LASLI

 JSR DORND              \ Set A and X to random numbers

 AND #7                 \ Restrict A to a random value in the range 0 to 7

 ADC #Y-4               \ Set LASY to four pixels above the centre of the
 STA LASY               \ screen (#Y), plus our random number, so the laser
                        \ dances above and below the centre point

 JSR DORND              \ Set A and X to random numbers

 AND #7                 \ Restrict A to a random value in the range 0 to 7

 ADC #X-4               \ Set LASX to four pixels left of the centre of the
 STA LASX               \ screen (#X), plus our random number, so the laser
                        \ dances to the left and right of the centre point

 LDA GNTMP              \ Add 8 to the laser temperature in GNTMP
 ADC #8
 STA GNTMP

 JSR DENGY              \ Call DENGY to deplete our energy banks by 1

.LASLI2

 LDA QQ11               \ If this is not a space view (i.e. QQ11 is non-zero)
 BNE LASLI-1            \ then jump to MA9 to return from the main flight loop
                        \ (as LASLI-1 is an RTS)

 LDA #32                \ Set A = 32 and Y = 224 for the first set of laser
 LDY #224               \ lines (the wider pair of lines)

 JSR las                \ Call las below to draw the first set of laser lines

 LDA #48                \ Fall through into las with A = 48 and Y = 208 to draw
 LDY #208               \ a second set of lines (the narrower pair)

                        \ The following routine draws two laser lines, one from
                        \ the centre point down to point A on the bottom row,
                        \ and the other from the centre point down to point Y
                        \ on the bottom row. We therefore get lines from the
                        \ centre point to points 32, 48, 208 and 224 along the
                        \ bottom row, giving us the triangular laser effect
                        \ we're after

.las

 STA X2                 \ Set X2 = A

 LDA LASX               \ Set (X1, Y1) to the random centre point we set above
 STA X1
 LDA LASY
 STA Y1

 LDA #2*Y-1             \ Set Y2 = 2 * #Y - 1. The constant #Y is 96, the
 STA Y2                 \ y-coordinate of the mid-point of the space view, so
                        \ this sets Y2 to 191, the y-coordinate of the bottom
                        \ pixel row of the space view

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2), so that's from
                        \ the centre point to (A, 191)

 LDA LASX               \ Set (X1, Y1) to the random centre point we set above
 STA X1
 LDA LASY
 STA Y1

 STY X2                 \ Set X2 = Y

 LDA #2*Y-1             \ Set Y2 = 2 * #Y - 1, the y-coordinate of the bottom
 STA Y2                 \ pixel row of the space view (as before)

 JMP LOIN               \ Draw a line from (X1, Y1) to (X2, Y2), so that's from
                        \ the centre point to (Y, 191), and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\ Save output/ELTC.bin
\
\ ******************************************************************************

PRINT "ELITE C"
PRINT "Assembled at ", ~CODE_C%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE_C%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD_C%

PRINT "S.ELTC ", ~CODE_C%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD_C%
\SAVE "output/D.ELTC.bin", CODE_C%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE D FILE
\
\ ******************************************************************************

CODE_D% = P%
LOAD_D% = LOAD% + P% - CODE%

.l_2aec

 CPX #&10
 BEQ n_aliens
 CPX #&0D
 BCS l_2b04

.n_aliens

 LDY #&0C               \ Similar to tnpr
 SEC
 LDA QQ20+&10

.l_2af9

 ADC QQ20,Y
 BCS n_cargo
 DEY
 BPL l_2af9
 CMP new_hold

.n_cargo

 RTS

.l_2b04

 LDA QQ20,X
 ADC #&00
 RTS

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
\ down a line, setting Sentence Case, and then printing a newline.
\
\ ******************************************************************************

.TTX69

 INC YC                 \ Move the text cursor down a line

                        \ Fall through into TT69 to set Sentence Case and print
                        \ a newline

\ ******************************************************************************
\
\       Name: TT69
\       Type: Subroutine
\   Category: Text
\    Summary: Set Sentence Case and print a newline
\
\ ******************************************************************************

.TT69

 JSR vdu_80             \ AJD

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

 LDA #163               \ Print recursive token 3 as a title in capitals at
 JSR TT27               \ the top ("DATA ON {selected system name}")

 JSR NLIN               \ Draw a horizontal line underneath the title

 JSR TTX69              \ Print a paragraph break and set Sentence Case

 INC YC                 \ Move the text cursor down one more line

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

 JSR pr2-1              \ AJD

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

 JSR vdu_00             \ AJD

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

 LDA #'k'               \ Print "km", returning from the subroutine using a
 JSR TT26               \ tail call
 LDA #'m'
 JMP TT26

.TT24

 LDA &6D
 AND #&07
 STA QQ3
 LDA &6E
 LSR A
 LSR A
 LSR A
 AND #&07
 STA QQ4
 LSR A
 BNE l_2c94
 LDA QQ3
 ORA #&02
 STA QQ3

.l_2c94

 LDA QQ3
 EOR #&07
 CLC
 STA QQ5
 LDA &6F
 AND #&03
 ADC QQ5
 STA QQ5
 LDA QQ4
 LSR A
 ADC QQ5
 STA QQ5
 ASL A
 ASL A
 ADC QQ3
 ADC QQ4
 ADC #&01
 STA QQ6
 LDA QQ3
 EOR #&07
 ADC #&03
 STA &1B
 LDA QQ4
 ADC #&04
 STA &81
 JSR MULTU
 LDA QQ6
 STA &81
 JSR MULTU
 ASL &1B
 ROL A
 ASL &1B
 ROL A
 ASL &1B
 ROL A
 STA QQ7+&01
 LDA &1B
 STA QQ7
 RTS

.l_2ceb

 LDA #&40
 JSR TT66
 LDA #&07
 STA XC
 JSR l_2f6a
 LDA #&C7
 JSR TT27
 JSR NLIN
 LDA #&98
 JSR NLIN2
 JSR l_2da1
 LDX #&00

.l_2d09

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
 JSR PIXEL
 JSR TT20
 LDX &84
 INX
 BNE l_2d09
 LDA QQ9
 STA &73
 LDA QQ10
 LSR A
 STA &74
 LDA #&04
 STA &75

.TT15

 LDA #&18
 LDX &87
 BPL l_2d3e
 LDA #&00

.l_2d3e

 STA &78
 LDA &73
 SEC
 SBC &75
 BCS l_2d49
 LDA #&00

.l_2d49

 STA &34
 LDA &73
 CLC
 ADC &75
 BCC l_2d54
 LDA #&FF

.l_2d54

 STA &36
 LDA &74
 CLC
 ADC &78
 STA &35
 JSR HLOIN
 LDA &74
 SEC
 SBC &75
 BCS l_2d69
 LDA #&00

.l_2d69

 CLC
 ADC &78
 STA &35
 LDA &74
 CLC
 ADC &75
 ADC &78
 CMP #&98
 BCC l_2d7f
 LDX &87
 BMI l_2d7f
 LDA #&97

.l_2d7f

 STA &37
 LDA &73
 STA &34
 STA &36
 JMP LOIN

.l_2d8a

 LDA #&68
 STA &73
 LDA #&5A
 STA &74
 LDA #&10
 STA &75
 JSR TT15
 LDA QQ14
 STA &40
 JMP l_2dc5

.l_2da1

 LDA &87
 BMI l_2d8a
 LDA QQ14
 LSR A
 LSR A
 STA &40
 LDA QQ0
 STA &73
 LDA QQ1
 LSR A
 STA &74
 LDA #&07
 STA &75
 JSR TT15
 LDA &74
 CLC
 ADC #&18
 STA &74

.l_2dc5

 LDA &73
 STA &D2
 LDA &74
 STA &E0
 LDX #&00
 STX &E1
 STX &D3
 INX
 STX &6B
 INX
 STX &95
 JMP CIRCLE2

.l_2dde

 LDY #&00

.l_2de0

 STY &03AD
 LDX QQ20,Y
 BEQ l_2e0c
 TYA
 ASL A
 ASL A
 TAY
 LDA l_4619+&01,Y
 STA &74
 TXA
 PHA
 JSR TT69
 CLC
 LDA &03AD
 ADC #&D0
 JSR TT27
 LDA #&0E
 STA XC
 PLA
 TAX
 JSR pr2-1
 JSR l_3135

.l_2e0c

 LDY &03AD
 INY
 CPY #&11
 BCC l_2de0
 RTS

.l_2e15

 LDA #&08
 JSR TT66
 LDA #&0B
 STA XC
 LDA #&A4
 JSR TT60
 JSR NLIN4
 JSR l_3366
 LDA #&0E
 JSR TT68
 LDX new_hold
 DEX
 JSR pr2-1
 JSR l_3147
 JMP l_2dde

.l_2e38

 TXA
 PHA
 DEY
 TYA
 EOR #&FF
 PHA
 \	JSR WSCAN
 JSR l_2e65
 PLA
 STA &76
 LDA QQ10
 JSR l_2e7b
 LDA &77
 STA QQ10
 STA &74
 PLA
 STA &76
 LDA QQ9
 JSR l_2e7b
 LDA &77
 STA QQ9
 STA &73

.l_2e65

 LDA &87
 BMI l_2e8c
 LDA QQ9
 STA &73
 LDA QQ10
 LSR A
 STA &74
 LDA #&04
 STA &75
 JMP TT15

.l_2e7b

 STA &77
 CLC
 ADC &76
 LDX &76
 BMI l_2e87
 BCC l_2e89
 RTS

.l_2e87

 BCC l_2e8b

.l_2e89

 STA &77

.l_2e8b

 RTS

.l_2e8c

 LDA QQ9
 SEC
 SBC QQ0
 CMP #&26
 BCC l_2e9b
 CMP #&E6
 BCC l_2e8b

.l_2e9b

 ASL A
 ASL A
 CLC
 ADC #&68
 STA &73
 LDA QQ10
 SEC
 SBC QQ1
 CMP #&26
 BCC l_2eb1
 CMP #&DC
 BCC l_2e8b

.l_2eb1

 ASL A
 CLC
 ADC #&5A
 STA &74
 LDA #&08
 STA &75
 JMP TT15

.l_2ebe

 LDA #&80
 JSR TT66
 LDA #&07
 STA XC
 LDA #&BE
 JSR NLIN3
 JSR l_2da1
 JSR l_2e65
 JSR l_2f6a
 LDA #&00
 STA &97
 LDX #&18

.l_2edb

 STA &46,X
 DEX
 BPL l_2edb

.l_2ee0

 LDA &6F
 SEC
 SBC QQ0
 STA &3A
 BCS l_2eec
 EOR #&FF
 ADC #&01

.l_2eec

 CMP #&14
 BCS l_2f60
 LDA &6D
 SEC
 SBC QQ1
 STA &E0
 BCS l_2efc
 EOR #&FF
 ADC #&01

.l_2efc

 CMP #&26
 BCS l_2f60
 LDA &3A
 ASL A
 ASL A
 ADC #&68
 STA &3A
 LSR A
 LSR A
 LSR A
 STA XC
 INC XC
 LDA &E0
 ASL A
 ADC #&5A
 STA &E0
 LSR A
 LSR A
 LSR A
 TAY
 LDX &46,Y
 BEQ l_2f31
 INY
 LDX &46,Y
 BEQ l_2f31
 DEY
 DEY
 LDX &46,Y
 BNE l_2f43

.l_2f31

 STY YC
 CPY #&03
 BCC l_2f60
 LDA #&FF
 STA &46,Y
 JSR vdu_80
 JSR l_330a

.l_2f43

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
 JSR FLFLLS
 JSR l_3a54
 JSR FLFLLS

.l_2f60

 JSR TT20
 INC &97
 BEQ l_2f74
 JMP l_2ee0

.l_2f6a

 LDX #&05

.l_2f6c

 LDA cmdr_gseed,X
 STA &6C,X
 DEX
 BPL l_2f6c

.l_2f74

 RTS

.TT111

 JSR l_2f6a
 LDY #&7F
 STY &D1
 LDA #&00
 STA &80

.l_2f80

 LDA &6F
 SEC
 SBC QQ9
 BCS l_2f8c
 EOR #&FF
 ADC #&01

.l_2f8c

 LSR A
 STA &83
 LDA &6D
 SEC
 SBC QQ10
 BCS l_2f9b
 EOR #&FF
 ADC #&01

.l_2f9b

 LSR A
 CLC
 ADC &83
 CMP &D1
 BCS l_2fae
 STA &D1
 LDX #&05

.l_2fa7

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_2fa7

.l_2fae

 JSR TT20
 INC &80
 BNE l_2f80
 LDX #&05

.l_2fb7

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_2fb7
 LDA &6D
 STA QQ10
 LDA &6F
 STA QQ9
 SEC
 SBC QQ0
 BCS l_2fd2
 EOR #&FF
 ADC #&01

.l_2fd2

 JSR SQUA2
 STA &41
 LDA &1B
 STA &40
 LDA QQ10
 SEC
 SBC QQ1
 BCS l_2fe8
 EOR #&FF
 ADC #&01

.l_2fe8

 LSR A
 JSR SQUA2
 PHA
 LDA &1B
 CLC
 ADC &40
 STA &81
 PLA
 ADC &41
 STA &82
 JSR l_47b8
 LDA &81
 ASL A
 LDX #&00
 STX QQ8+&01
 ROL QQ8+&01
 ASL A
 ROL QQ8+&01
 STA QQ8
 JMP TT24

.l_3011

 LDA &2F
 ORA &8E
 BNE l_3084+&01
 JSR CTRL
 BMI l_305e
 LDA &87
 BNE l_3023
 \	JMP l_30c3
 \l_30c3
 JSR TT111
 JMP l_3026

.l_3023

 JSR l_32fe

.l_3026

 LDA QQ8
 ORA QQ8+&01
 BEQ l_3084+&01
 LDA #&07
 STA XC
 LDA #&17
 STA YC
 JSR vdu_00
 LDA #&BD
 JSR TT27
 LDA QQ8+&01
 BNE l_30b9
 LDA QQ14
 CMP QQ8
 BCC l_30b9
 LDA #&2D
 JSR TT27
 JSR l_330a

.l_3054

 LDA #&0F
 STA &2F
 STA &2E
 TAX
 \	JMP ee3
 BNE ee3

.l_305e

 LDX cmdr_ghype
 BEQ l_3084+&01
 INC new_hold	\**
 INX
 STX cmdr_ghype
 STX FIST
 STX cmdr_cour
 STX cmdr_cour+1
 JSR l_3054
 LDX #&05
 INC GCNT
 LDA GCNT
 AND #&07
 STA GCNT

.l_307a

 LDA cmdr_gseed,X
 ASL A
 ROL cmdr_gseed,X
 DEX
 BPL l_307a

.l_3084

 LDA #&60
 STA QQ9
 STA QQ10
 JSR l_3292
 JSR TT111
 LDX #&00
 STX QQ8
 STX QQ8+&01
 LDA #&74
 JSR l_45c6

.jmp

 LDA QQ9
 STA QQ0
 LDA QQ10
 STA QQ1

.hy5

 RTS

.ee3

 LDY #&01
 STY XC
 STY YC
 DEY

.pr6

 CLC

.pr5

 LDA #&05
 JMP TT11

.l_30b9

 LDA #&CA
 JSR TT27
 LDA #&3F
 JMP TT27

.l_30c9

 PHA
 STA &77
 ASL A
 ASL A
 STA &73
 LDA #&01
 STA XC
 PLA
 ADC #&D0
 JSR TT27
 LDA #&0E
 STA XC
 LDX &73
 LDA l_4619+&01,X
 STA &74
 LDA cmdr_price
 AND l_4619+&03,X
 CLC
 ADC l_4619,X
 STA &03AA
 JSR l_3135
 JSR l_318e
 LDA &74
 BMI l_3104
 LDA &03AA
 ADC &76
 JMP l_310a

.l_3104

 LDA &03AA
 SEC
 SBC &76

.l_310a

 STA &03AA
 STA &1B
 LDA #&00
 JSR l_32f4
 SEC
 JSR pr5
 LDY &77
 LDA #&05
 LDX cmdr_avail,Y
 STX &03AB
 CLC
 BEQ l_312b
 JSR pr2+2
 JMP l_3135

.l_312b

 LDA XC
 ADC #&04
 STA XC
 LDA #&2D
 BNE l_3144

.l_3135

 LDA &74
 AND #&60
 BEQ l_3147
 CMP #&20
 BEQ l_314e
 JSR l_3153

.TT162

 LDA #&20

.l_3144

 JMP TT27

.l_3147

 LDA #&74
 JSR TT26
 BCC TT162

.l_314e

 LDA #&6B
 JSR TT26

.l_3153

 LDA #&67
 JMP TT26

.l_3158

 LDA #&11
 STA XC
 LDA #&FF
 BNE l_3144

.l_3160

 LDA #&10
 JSR TT66
 LDA #&05
 STA XC
 LDA #&A7
 JSR NLIN3
 LDA #&03
 STA YC
 JSR l_3158
 LDA #&00
 STA &03AD

.l_317a

 \	LDX #&80
 \	STX QQ17
 JSR vdu_80
 JSR l_30c9
 INC YC
 INC &03AD
 LDA &03AD
 CMP #&11
 BCC l_317a
 RTS

.l_318e

 LDA &74
 AND #&1F
 LDY home_econ
 STA &75
 CLC
 LDA #&00
 STA cmdr_avail+&10

.l_319d

 DEY
 BMI l_31a5
 ADC &75
 JMP l_319d

.l_31a5

 STA &76
 RTS

.l_31ab

 JSR jmp
 LDX #&05

.l_31b0

 LDA &6C,X
 STA &03B2,X
 DEX
 BPL l_31b0
 INX
 STX &0349
 LDA QQ3
 STA home_econ
 LDA QQ5
 STA home_tech
 LDA QQ4
 STA home_govmt
 JSR DORND
 STA cmdr_price
 LDX #&00
 STX &96

.l_31d8

 LDA l_4619+&01,X
 STA &74
 JSR l_318e
 LDA l_4619+&03,X
 AND cmdr_price
 CLC
 ADC l_4619+&02,X
 LDY &74
 BMI l_31f4
 SEC
 SBC &76
 JMP l_31f7

.l_31f4

 CLC
 ADC &76

.l_31f7

 BPL l_31fb
 LDA #&00

.l_31fb

 LDY &96
 AND #&3F
 STA cmdr_avail,Y
 INY
 TYA
 STA &96
 ASL A
 ASL A
 TAX
 CMP #&3F
 BCC l_31d8
 RTS

.l_320e

 JSR l_3f62
 LDA #&FF
 STA &66
 LDA #&1D
 JSR l_3768
 LDA #&1E
 JMP l_3768

.l_3226

 LDA #&03
 JSR l_427e
 LDA #&03
 JSR TT66
 JSR l_2623
 JSR RES2
 STY &0341

.l_3239

 JSR l_320e
 LDA #&03
 CMP &033B
 BCS l_3239
 STA &03C3
 LDX #&00
 JSR LOOK1
 LDA QQ1
 EOR #&1F
 STA QQ1

.r_rts

 RTS

.l_3254

 LDA QQ14
 SEC
 SBC QQ8
 STA QQ14

.hyper_snap

 LDA &87
 BNE l_3268
 JSR TT66
 JSR l_2623

.l_3268

 \	JSR CTRL
 \	AND x_flag
 \	BMI l_321f
 JSR DORND
 CMP #&FD
 BCS l_3226
 JSR l_31ab
 JSR RES2
 JSR l_3580
 JSR l_4255
 LDA &87
 AND #&3F
 BNE r_rts
 JSR TTX66
 LDA &87
 BNE l_32c8
 INC &87

.l_3292

 LDX &8E
 BEQ l_32c1
 JSR l_2636
 JSR RES2
 JSR TT111
 INC &4E
 JSR l_356d
 LDA #&80
 STA &4E
 INC &4D
 JSR l_3740
 LDA #&0C
 STA &7D
 JSR l_41a6
 ORA FIST
 STA FIST
 LDA #&FF
 STA &87
 JSR HFS1

.l_32c1

 LDX #&00
 STX &8E
 JMP LOOK1

.l_32c8

 BMI l_32cd
 JMP l_2ceb

.l_32cd

 JMP l_2ebe

\ a.DOENTRY

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
 JSR TT111
 JSR l_2e65
 JMP CLYNS

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
 JSR TT27

.l_3327

 JSR TT54
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
 JSR TT26
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

 LDX GCNT
 INX
 JMP pr2-1

.l_3366

 LDA #&69
 JSR TT68
 LDX QQ14
 SEC
 JSR pr2
 LDA #&C3
 JSR plf
 LDA #&77
 BNE TT27

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
 JSR BPRNT
 LDA #&E2

.plf

 JSR TT27
 JMP TT67

.TT68

 JSR TT27

.l_3398

 LDA #&3A

.TT27

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
 STX QQ17
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

 LDX QQ17
 BEQ l_3410
 BMI l_33e6
 BIT QQ17
 BVS l_3409

.l_33d9

 CMP #&41
 BCC l_33e3
 CMP #&5B
 BCS l_33e3
 ADC #&20

.l_33e3

 JMP TT26

.l_33e6

 BIT QQ17
 BVS l_3401
 CMP #&41
 BCC l_3410
 PHA
 TXA
 ORA #&40
 STA QQ17
 PLA
 BNE l_33e3

.l_33f7

 ADC #&72
 BNE l_342d

.l_33fb

 LDA #&15
 STA XC
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
 STA QQ17
 PLA

.l_3410

 JMP TT26

.l_3413

 CMP #&A0
 BCS l_342b
 AND #&7F
 ASL A
 TAY
 LDA &0880,Y
 JSR TT27
 LDA &0881,Y
 CMP #&3F
 BEQ l_3468
 JMP TT27

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
 JSR TT27
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
 JSR DVID4
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

 JSR DORND2
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
 JSR PIXEL

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

 JSR DORND2
 JMP l_3533

.l_354b

 STA &83
 JSR DORND2
 ROL A
 BCS l_355e
 JSR FMLTU
 ADC &82
 TAX
 LDA &83
 ADC #&00
 RTS

.l_355e

 JSR FMLTU
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

 LDA QQ8
 LDY #3

.legal_div

 LSR QQ8+1
 ROR A
 DEY
 BNE legal_div
 SEC
 SBC FIST
 BCC legal_over
 LDA #&FF

.legal_over

 EOR #&FF
 STA FIST
 \	LDA FIST
 \	BEQ legal_over
 \legal_next
 \	DEC FIST
 \	LSR a
 \	BNE legal_next
 \legal_over
 \\	LSR FIST
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

.NWSTARS

 LDA &87
 BNE WPSHPS

.l_35b5

 LDY &03C3

.l_35b8

 JSR DORND
 ORA #&08
 STA &0FA8,Y
 STA &88
 JSR DORND
 STA &0F5C,Y
 STA &34
 JSR DORND
 STA &0F82,Y
 STA &35
 JSR PIXEL2
 DEY
 BNE l_35b8

.WPSHPS

 LDX #&00

.l_35da

 LDA FRIN,X
 BEQ l_3602
 BMI l_35ff
 STA &8C
 JSR ship_SC
 LDY #&1F

.l_35e8

 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_35e8
 STX &84
 JSR SCAN
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

.FLFLLS

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

.DENGY

 DEC ENERGY
 PHP
 BNE l_3632
 INC ENERGY

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
 JSR DVID4
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

.COMPAS

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

.CPIX4

 JSR l_36ac
 DEC &35

.l_36ac

 LDA &35
 TAY
 LSR A
 LSR A
 LSR A
 ORA #&60
 STA SC+&01
 LDA &34
 AND #&F8
 STA SC
 TYA
 AND #&07
 TAY
 LDA &34
 AND #&06
 LSR A
 TAX
 LDA TWOS+&10,X
 AND &91
 EOR (SC),Y
 STA (SC),Y
 LDA TWOS+&11,X
 BPL l_36dd
 LDA SC
 ADC #&08
 STA SC
 LDA TWOS+&11,X

.l_36dd

 AND &91
 EOR (SC),Y
 STA (SC),Y
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
 LDA FSH
 SBC &D1
 BCC l_36f9
 STA FSH

.n_shok

 RTS

.l_36f9

 STX FSH
 BCC l_370c

.l_36fe

 LDA ASH
 SBC &D1
 BCC l_3709
 STA ASH
 RTS

.l_3709

 STX ASH

.l_370c

 ADC ENERGY
 STA ENERGY
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

.ship_SC

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA &20
 LDA UNIV+&01,Y
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
 STX FRIN+&01
 STX &67
 LDA FIST
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

 LDA FRIN,X
 BEQ l_3778
 INX
 CPX #&0C
 BCC l_376c

.l_3776

 CLC

.l_3777

 RTS

.l_3778

 JSR ship_SC
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

 STA FRIN,X
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
 STA SC
 LDA #&7D
 STX font
 STY font+&01
 JMP RREN

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
 STA SC
 LDA #&7E
 STA SC+&01
 TYA
 LDY #&05

.l_3850

 STA (SC),Y
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
 JSR DVID3B2
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
 JSR DVID3B2
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
 JSR FMLTU
 STA &82
 LDA &9E
 JSR FMLTU
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
 JSR FMLTU
 STA &42
 LDA &9B
 JSR FMLTU
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
 JSR ADD
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
 JSR ADD
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

 JSR BLINE
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
 JSR SQUA2
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
 JSR HLOIN2

.l_3abe

 DEY
 BNE l_3ab2

.l_3ac1

 LDA &22
 JSR SQUA2
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
 JSR DORND
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
 JSR EDGES
 LDA &34
 STA &24
 LDA &36
 STA &25
 LDA &D2
 STA &26
 LDA &D3
 STA &27
 LDA &0E00,Y
 JSR EDGES
 BCS l_3b1f
 LDA &36
 LDX &24
 STX &36
 STA &24
 JSR HLOIN

.l_3b1f

 LDA &24
 STA &34
 LDA &25
 STA &36

.l_3b27

 JSR HLOIN

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
 JSR EDGES
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
 JSR HLOIN2

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

.CIRCLE2

 LDX #&FF
 STX &92
 INX
 STX &93

.l_3b97

 LDA &93
 JSR FMLTU2
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
 JSR FMLTU2
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

 JSR BLINE
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
 JSR LOIN
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
 JSR HLOIN2

.l_3c47

 DEY
 BNE l_3c3f
 DEY
 STY &0E00
 RTS

.EDGES

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
 JSR MULTU
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
 JSR ARCTAN
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

 JSR DVID3B2
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
 LDA KL
 RTS

.l_3d4c

 LDA KL
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

.ping

 LDX #&01

.l_3d6a

 LDA QQ0,X
 STA QQ9,X
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
 JSR FLFLLS
 STA FRIN+&01
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
 LDA FRIN,X
 BEQ l_3d74
 CMP #&01
 BNE l_3da3
 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA SC
 LDA UNIV+&01,Y
 STA SC+&01
 LDY #&20
 LDA (SC),Y
 BPL l_3da3
 AND #&7F
 LSR A
 CMP &96
 BCC l_3da3
 BEQ l_3dd2
 SBC #&01
 ASL A
 ORA #&80
 STA (SC),Y
 BNE l_3da3

.l_3dd2

 LDA #&00
 STA (SC),Y
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
 LDX FRIN,Y
 CPX #&02
 BEQ l_3d89
 CPX #&1F
 BNE l_3dfd
 LDA TP
 ORA #&02
 STA TP

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
 LDA FRIN,X
 STA &0310,X
 BNE l_3e2b
 JMP l_3da1

.l_3e2b

 ASL A
 TAY
 LDA &55FE,Y
 STA SC
 LDA &55FF,Y
 STA SC+&01
 LDY #&05
 LDA (SC),Y
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
 LDA UNIV,Y
 STA SC
 LDA UNIV+&01,Y
 STA SC+&01
 LDY #&24
 LDA (SC),Y
 STA (&20),Y
 DEY
 LDA (SC),Y
 STA (&20),Y
 DEY
 LDA (SC),Y
 STA &41
 LDA font
 STA (&20),Y
 DEY
 LDA (SC),Y
 STA &40
 LDA &1B
 STA (&20),Y
 DEY

.l_3e75

 LDA (SC),Y
 STA (&20),Y
 DEY
 BPL l_3e75
 LDA SC
 STA &20
 LDA SC+&01
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
 JSR DORND
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
 JMP DORND

.l_3eb8

 LDX GCNT
 DEX
 BNE l_3ecc
 LDA QQ0
 CMP #&90
 BNE l_3ecc
 LDA QQ1
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

 STA FSH,X
 DEX
 BPL l_3edb

.RES2

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

 JSR WPSHPS
 JSR clr_ships
 LDA #&FF
 STA &03B0
 LDA #&0C
 STA &03B1
 JSR DIALS
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
\ Other entry points:
\
\   DORND2              Restricts the value of RAND+2 so that bit 0 is always 0
\
\ ******************************************************************************

.DORND2

 CLC                    \ This ensures that bit 0 of r2 is 0

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

.l_3f9a

 JSR DORND
 LSR A
 STA &66
 STA &63
 ROL &65
 AND #&0F
 STA &61
 JSR DORND
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
 JSR DORND
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

 JSR DORND
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
 ORA FIST

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
 LDA TP
 AND #&0C
 CMP #&08
 BNE l_4070
 JSR DORND
 CMP #&C8
 BCC l_4070
 JSR l_320e

.l_4070

 JSR DORND
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
 LDA TP
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
 JSR DORND
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

 JSR DORND
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
 LDX GNTMP
 BEQ l_40e6
 DEC GNTMP

.l_40e6

 JSR DIALS
 LDA &87
 BEQ l_40f8
 \	AND x_flag
 \	LSR A
 \	BCS l_40f8
 LDY #&02
 JSR DELAY

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
 JMP STATUS

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
 JSR TT111
 JMP TT25

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
 JMP LOOK1

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
 JMP WSCAN	\RTS

.n_finder

 STA &06
 LDA &87
 AND #&C0
 BEQ l_416c
 LDA &06
 CMP #&36
 BNE l_notdist
 JSR l_2e65
 JSR ping
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
 JSR ee3
 LDA #&05
 STA &2E
 LDX &2F
 JSR ee3
 DEC &2F
 BNE l_418a
 JMP l_3254

.l_41a6

 LDA QQ20+&03
 CLC
 ADC QQ20+&06
 ASL A
 ADC QQ20+&0A
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
 STA QQ9
 LDA cmdr_coury
 STA QQ10
 JSR l_2e65

.l_418b

 LDA &87
 AND #&C0
 BEQ l_418a
 JSR l_32fe
 STA QQ17
 JSR l_330a
 JSR vdu_80
 LDA #&01
 STA XC
 INC YC
 JMP TT146

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
 JSR RES2
 ASL &7D
 ASL &7D
 LDX #&18
 JSR l_3619
 JSR TT66
 JSR BOX
 JSR l_35b5
 LDA #&0C
 STA YC
 STA XC
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
 JSR DORND
 AND #&80
 LDY #&1F
 STA (&20),Y
 LDA FRIN+&04
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
 JSR DORND
 AND #&03
 LDX home_govmt
 CPX #&03
 ROL A
 LDX home_tech
 CPX #&0A
 ROL A
 ADC GCNT	\ 16+7 -> 23 files !
 TAX
 LDA TP
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

 STA FRIN,X
 DEX
 BPL l_429a
 RTS

.ZES1

 STX SC+&01
 LDA #&00
 STA SC
 TAY

.l_42a8

 STA (SC),Y
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
 JSR SQUA
 STA &82
 LDA &1B
 STA &81
 LDA &35
 JSR SQUA
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
 JSR SQUA
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

 JSR DKS4
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
 LDA FRIN+&02,X
 ORA &033E	\ no jump if any ship
 ORA &0320
 ORA &0341
 BNE l_439f
 LDY &0908
 BMI l_4368
 TAY
 JSR MAS2
 LSR A
 BEQ l_439f

.l_4368

 LDY &092D
 BMI l_4375
 LDY #&25
 JSR m
 LSR A
 BEQ l_439f

.l_4375

 LDA #&81
 STA &83
 STA &82
 STA &1B
 LDA &0908
 JSR ADD
 STA &0908
 LDA &092D
 JSR ADD
 STA &092D
 LDA #&01
 STA &87
 STA &8A
 LSR A
 STA &0349
 LDX VIEW
 JMP LOOK1

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

.BEEP

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

 INC TALLY
 BNE l_43db
 INC TALLY+&01
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
 JSR DKS4
 BPL b_quit

.b_pressed

 LDA #&FF
 STA KL,Y

.b_quit

 RTS

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
 JSR BELL
 JSR DELAY
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

 STA KL,Y
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
 JSR BUMP2

.l_4533

 LDY &0304
 BEQ l_453b
 JSR REDU2

.l_453b

 STX adval_x
 ASL A
 LDX adval_y
 LDY &0305
 BEQ l_454a
 JSR REDU2

.l_454a

 LDY &0306
 BEQ l_4552
 JSR BUMP2

.l_4552

 STX adval_y

.l_4555

 JSR l_433f
 STX KL
 CPX #&69
 BNE l_459c

.l_455f

 JSR WSCAN
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
 \	CPX KL
 \	BNE l_45af
 \	STA KL,Y
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
 \	STX QQ17
 JSR vdu_00
 LDY #&09
 STY XC
 LDY #&16
 STY YC
 CPX &034A
 BNE l_45b5
 STY &034A
 STA &03A4

.l_45dd

 JSR TT27
 LSR &034B
 BCC l_45b4
 LDA #&FD
 JMP TT27

.l_45ea

 JSR DORND
 BMI l_45b4
 \	CPX #&16
 CPX #&18
 BCS l_45b4
 \	LDA QQ20,X
 LDA CRGO,X
 BEQ l_45b4
 LDA &034A
 BNE l_45b4
 LDY #&03
 STY &034B
 \	STA QQ20,X
 STA CRGO,X
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

.TIDY

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
 JSR MULT12
 LDX &50,Y
 STX &81
 LDA &56,Y
 JSR MAD
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

.LL28

 CMP &81
 BCS l_480d

 LDX #&FE
 STX &82

.LL31

 ASL A
 BCS l_4805
 CMP &81
 BCC l_4800
 SBC &81

.l_4800

 ROL &82
 BCS LL31
 RTS

.l_4805

 SBC &81
 SEC
 ROL &82
 BCS LL31
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
 JSR l_4812
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

.LL9

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
 JSR DORND
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
 JSR LL28
 LDX &82
 STX &09,Y
 DEY
 DEY
 BPL l_4957
 LDX #&08

.l_496c

 LDA &46,X
 STA QQ17,X
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
 ROR QQ17
 LSR A
 ROR &78
 TAY
 BNE l_49a1

.l_49b0

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
 JSR l_4832
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
 JMP l_4aaf

.l_4a49

 LSR QQ17
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
 LDA QQ17
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
 JSR l_4812
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
 JSR LL28
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

 JSR LL28

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

 JSR LL28

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

 JSR LL145
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

.LL145

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
 JSR LL28
 JMP l_4ef0

.l_4ee5

 LDA &3E
 STA &81
 LDA &3C
 JSR LL28
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
 JSR LOIN
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

 LDA INWK+31            \ If bits 5 or 7 of ship byte #31 are set, jump to MV30
 AND #%10100000         \ as the ship is either exploding or has been killed, so
 BNE MV30               \ we don't need to tidy its orientation vectors or apply
                        \ tactics

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

\ ******************************************************************************
\
\       Name: MVEIT (Part 2 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Call tactics routine, remove ship from scanner
\  Deep dive: Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Apply tactics to ships with AI enabled (by calling the TACTICS routine)
\
\   * Remove the ship from the scanner, so we can move it
\
\ ******************************************************************************

.MV3

 LDX TYPE               \ If the type of the ship we are moving is positive,
 BPL P%+5               \ i.e. it is not a planet (types 128 and 130) or sun
                        \ (type 129), then skip the following instruction

 JMP MV40               \ This item is the planet or sun, so jump to MV40 to
                        \ move it, which ends by jumping back into this routine
                        \ at MV45 (after all the rotation, tactics and scanner
                        \ code, which we don't need to apply to planets or suns)

 LDA INWK+32            \ Fetch the ship's byte #32 (AI flag) into A

 BPL MV30               \ If bit 7 of the AI flag is clear, then if this is a
                        \ ship or missile it is dumb and has no AI, and if this
                        \ is the space station it is not hostile, so in both
                        \ cases skip the following as it has no tactics

 CPX #MSL               \ If the ship is a missile, skip straight to MV26 to
 BEQ MV26               \ call the TACTICS routine, as we do this every
                        \ iteration of the main loop for missiles only

 LDA MCNT               \ Fetch the main loop counter

 EOR XSAV               \ Fetch the slot number of the ship we are moving, EOR
 AND #7                 \ with the loop counter and apply mod 8 to the result.
 BNE MV30               \ The result will be zero when "counter mod 8" matches
                        \ the slot number mod 8, so this makes sure we call
                        \ TACTICS 12 times every 8 main loop iterations, like
                        \ this:
                        \
                        \   Iteration 0, apply tactics to slots 0 and 8
                        \   Iteration 1, apply tactics to slots 1 and 9
                        \   Iteration 2, apply tactics to slots 2 and 10
                        \   Iteration 3, apply tactics to slots 3 and 11
                        \   Iteration 4, apply tactics to slot 4
                        \   Iteration 5, apply tactics to slot 5
                        \   Iteration 6, apply tactics to slot 6
                        \   Iteration 7, apply tactics to slot 7
                        \   Iteration 8, apply tactics to slots 0 and 8
                        \     ...
                        \
                        \ and so on

.MV26

 JSR TACTICS            \ Call TACTICS to apply AI tactics to this ship

.MV30

 JSR SCAN               \ Draw the ship on the scanner, which has the effect of
                        \ removing it, as it's already at this point and hasn't
                        \ yet moved

\ ******************************************************************************
\
\       Name: MVEIT (Part 3 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Move ship forward according to its speed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Move the ship forward (along the vector pointing in the direction of
\     travel) according to its speed:
\
\     (x, y, z) += nosev_hi * speed / 64
\
\ ******************************************************************************

 LDA INWK+27            \ Set Q = the ship's speed byte #27 * 4
 ASL A
 ASL A
 STA Q

 LDA INWK+10            \ Set A = |nosev_x_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_x_hi| * speed / 64

 LDA INWK+10            \ If nosev_x_hi is positive, then:
 LDX #0                 \
 JSR MVT1-2             \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + R
                        \
                        \ If nosev_x_hi is negative, then:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (x_sign x_hi x_lo) += nosev_x_hi * speed / 64

 LDA INWK+12            \ Set A = |nosev_y_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_y_hi| * speed / 64

 LDA INWK+12            \ If nosev_y_hi is positive, then:
 LDX #3                 \
 JSR MVT1-2             \   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) + R
                        \
                        \ If nosev_y_hi is negative, then:
                        \
                        \   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (y_sign y_hi y_lo) += nosev_y_hi * speed / 64

 LDA INWK+14            \ Set A = |nosev_z_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_z_hi| * speed / 64

 LDA INWK+14            \ If nosev_y_hi is positive, then:
 LDX #6                 \
 JSR MVT1-2             \   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + R
                        \
                        \ If nosev_z_hi is negative, then:
                        \
                        \   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (z_sign z_hi z_lo) += nosev_z_hi * speed / 64

\ ******************************************************************************
\
\       Name: MVEIT (Part 4 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Apply acceleration to ship's speed as a one-off
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Apply acceleration to the ship's speed (if acceleration is non-zero),
\     and then zero the acceleration as it's a one-off change
\
\ ******************************************************************************

 LDA INWK+27            \ Set A = the ship's speed in byte #24 + the ship's
 CLC                    \ acceleration in byte #28
 ADC INWK+28

 BPL P%+4               \ If the result is positive, skip the following
                        \ instruction

 LDA #0                 \ Set A to 0 to stop the speed from going negative

 LDY #15                \ Fetch byte #15 from the ship's blueprint, which
                        \ contains the ship's maximum speed

 CMP (XX0),Y            \ If A < the ship's maximum speed, skip the following
 BCC P%+4               \ instruction

 LDA (XX0),Y            \ Set A to the ship's maximum speed

 STA INWK+27            \ We have now calculated the new ship's speed after
                        \ accelerating and keeping the speed within the ship's
                        \ limits, so store the updated speed in byte #27

 LDA #0                 \ We have added the ship's acceleration, so we now set
 STA INWK+28            \ it back to 0 in byte #28, as it's a one-off change

\ ******************************************************************************
\
\       Name: MVEIT (Part 5 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship's location by our pitch and roll
\  Deep dive: Rotating the universe
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Rotate the ship's location in space by the amount of pitch and roll of
\     our ship. See below for a deeper explanation of this routine
\
\ ******************************************************************************

 LDX ALP1               \ Fetch the magnitude of the current roll into X, so
                        \ if the roll angle is alpha, X contains |alpha|

 LDA INWK               \ Set P = ~x_lo (i.e. with all its bits flipped) so that
 EOR #%11111111         \ we can pass x_lo to MLTU2 below)
 STA P

 LDA INWK+1             \ Set A = x_hi

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = (x_hi x_lo) * alpha

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = (x_hi x_lo) * alpha

 LDA ALP2+1             \ Fetch the flipped sign of the current roll angle alpha
 EOR INWK+2             \ from ALP2+1 and EOR with byte #2 (x_sign), so if the
                        \ flipped roll angle and x_sign have the same sign, A
                        \ will be positive, else it will be negative. So A will
                        \ contain the sign bit of x_sign * flipped alpha sign,
                        \ which is the opposite to the sign of the above result,
                        \ so we now have:
                        \
                        \ (A P+2 P+1) = - (x_sign x_hi x_lo) * alpha / 256

 LDX #3                 \ Set (A P+2 P+1) = (y_sign y_hi y_lo) + (A P+2 P+1)
 JSR MVT6               \                 = y - x * alpha / 256

 STA K2+3               \ Set K2(3) = A = the sign of the result

 LDA P+1                \ Set K2(1) = P+1, the low byte of the result
 STA K2+1

 EOR #%11111111         \ Set P = ~K2+1 (i.e. with all its bits flipped) so
 STA P                  \ that we can pass K2+1 to MLTU2 below)

 LDA P+2                \ Set K2(2) = A = P+2
 STA K2+2

                        \ So we now have result 1 above:
                        \
                        \ K2(3 2 1) = (A P+2 P+1)
                        \           = y - x * alpha / 256

 LDX BET1               \ Fetch the magnitude of the current pitch into X, so
                        \ if the pitch angle is beta, X contains |beta|

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = K2(2 1) * beta

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = K2(2 1) * beta

 LDA K2+3               \ Fetch the sign of the above result in K(3 2 1) from
 EOR BET2               \ K2+3 and EOR with BET2, the sign of the current pitch
                        \ rate, so if the pitch and K(3 2 1) have the same sign,
                        \ A will be positive, else it will be negative. So A
                        \ will contain the sign bit of K(3 2 1) * beta, which is
                        \ the same as the sign of the above result, so we now
                        \ have:
                        \
                        \ (A P+2 P+1) = K2(3 2 1) * beta / 256

 LDX #6                 \ Set (A P+2 P+1) = (z_sign z_hi z_lo) + (A P+2 P+1)
 JSR MVT6               \                 = z + K2 * beta / 256

 STA INWK+8             \ Set z_sign = A = the sign of the result

 LDA P+1                \ Set z_lo = P+1, the low byte of the result
 STA INWK+6

 EOR #%11111111         \ Set P = ~z_lo (i.e. with all its bits flipped) so that
 STA P                  \ we can pass z_lo to MLTU2 below)

 LDA P+2                \ Set z_hi = P+2
 STA INWK+7

                        \ So we now have result 2 above:
                        \
                        \ (z_sign z_hi z_lo) = (A P+2 P+1)
                        \                    = z + K2 * beta / 256

 JSR MLTU2              \ MLTU2 doesn't change Q, and Q was set to beta in
                        \ the previous call to MLTU2, so this call does:
                        \
                        \ (A P+1 P) = (A ~P) * Q
                        \           = (z_hi z_lo) * beta

 STA P+2                \ Set P+2 = A = the high byte of the result, so we
                        \ now have:
                        \
                        \ P(2 1 0) = (z_hi z_lo) * beta

 LDA K2+3               \ Set y_sign = K2+3
 STA INWK+5

 EOR BET2               \ EOR y_sign with BET2, the sign of the current pitch
 EOR INWK+8             \ rate, and z_sign. If the result is positive jump to
 BPL MV43               \ MV43, otherwise this means beta * z and y have
                        \ different signs, i.e. P(2 1) and K2(3 2 1) have
                        \ different signs, so we need to add them in order to
                        \ calculate K2(2 1) - P(2 1)

 LDA P+1                \ Set (y_hi y_lo) = K2(2 1) + P(2 1)
 ADC K2+1
 STA INWK+3
 LDA P+2
 ADC K2+2
 STA INWK+4

 JMP MV44               \ Jump to MV44 to continue the calculation

.MV43

 LDA K2+1               \ Reversing the logic above, we need to subtract P(2 1)
 SBC P+1                \ and K2(3 2 1) to calculate K2(2 1) - P(2 1), so this
 STA INWK+3             \ sets (y_hi y_lo) = K2(2 1) - P(2 1)
 LDA K2+2
 SBC P+2
 STA INWK+4

 BCS MV44               \ If the above subtraction did not underflow, then
                        \ jump to MV44, otherwise we need to negate the result

 LDA #1                 \ Negate (y_sign y_hi y_lo) using two's complement,
 SBC INWK+3             \ first doing the low bytes:
 STA INWK+3             \
                        \ y_lo = 1 - y_lo

 LDA #0                 \ Then the high bytes:
 SBC INWK+4             \
 STA INWK+4             \ y_hi = 0 - y_hi

 LDA INWK+5             \ And finally flip the sign in y_sign
 EOR #%10000000
 STA INWK+5

.MV44

                        \ So we now have result 3 above:
                        \
                        \ (y_sign y_hi y_lo) = K2(2 1) - P(2 1)
                        \                    = K2 - beta * z

 LDX ALP1               \ Fetch the magnitude of the current roll into X, so
                        \ if the roll angle is alpha, X contains |alpha|

 LDA INWK+3             \ Set P = ~y_lo (i.e. with all its bits flipped) so that
 EOR #&FF               \ we can pass y_lo to MLTU2 below)
 STA P

 LDA INWK+4             \ Set A = y_hi

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = (y_hi y_lo) * alpha

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = (y_hi y_lo) * alpha

 LDA ALP2               \ Fetch the correct sign of the current roll angle alpha
 EOR INWK+5             \ from ALP2 and EOR with byte #5 (y_sign), so if the
                        \ correct roll angle and y_sign have the same sign, A
                        \ will be positive, else it will be negative. So A will
                        \ contain the sign bit of x_sign * correct alpha sign,
                        \ which is the same as the sign of the above result,
                        \ so we now have:
                        \
                        \ (A P+2 P+1) = (y_sign y_hi y_lo) * alpha / 256

 LDX #0                 \ Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
 JSR MVT6               \                 = x + y * alpha / 256

 STA INWK+2             \ Set x_sign = A = the sign of the result

 LDA P+2                \ Set x_hi = P+2, the high byte of the result
 STA INWK+1

 LDA P+1                \ Set x_lo = P+1, the low byte of the result
 STA INWK

                        \ So we now have result 4 above:
                        \
                        \ x = x + alpha * y
                        \
                        \ and the rotation of (x, y, z) is done

\ ******************************************************************************
\
\       Name: MVEIT (Part 6 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Move the ship in space according to our speed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Move the ship in space according to our speed (we already moved it
\     according to its own speed in part 3).
\
\ We do this by subtracting our speed (i.e. the distance we travel in this
\ iteration of the loop) from the other ship's z-coordinate. We subtract because
\ they appear to be "moving" in the opposite direction to us, and the whole
\ MVEIT routine is about moving the other ships rather than us (even though we
\ are the one doing the moving).
\
\ Other entry points:
\
\   MV45                Rejoin the MVEIT routine after the rotation, tactics and
\                       scanner code
\
\ ******************************************************************************

.MV45

 LDA DELTA              \ Set R to our speed in DELTA
 STA R

 LDA #%10000000         \ Set A to zeroes but with bit 7 set, so that (A R) is
                        \ a 16-bit number containing -R, or -speed

 LDX #6                 \ Set X to the z-axis so the call to MVT1 does this:
 JSR MVT1               \
                        \ (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + (A R)
                        \                    = (z_sign z_hi z_lo) - speed

 LDA TYPE               \ If the ship type is not the sun (129) then skip the
 AND #%10000001         \ next instruction, otherwise return from the subroutine
 CMP #129               \ as we don't need to rotate the sun around its origin.
 BNE P%+3               \ Having both the AND and the CMP is a little odd, as
                        \ the sun is the only ship type with bits 0 and 7 set,
                        \ so the AND has no effect and could be removed

 RTS                    \ Return from the subroutine, as the ship we are moving
                        \ is the sun and doesn't need any of the following

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

 AND #%10100000         \ If we are exploding or removing this ship then jump to
 BNE MVD1               \ MVD1 to remove it from the scanner permanently

 LDA INWK+31            \ Set bit 4 to keep the ship visible on the scanner
 ORA #%00010000
 STA INWK+31

 JMP SCAN               \ Display the ship on the scanner, returning from the
                        \ subroutine using a tail call

.MVD1

 LDA INWK+31            \ Clear bit 4 to hide the ship on the scanner
 AND #%11101111
 STA INWK+31

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVT1
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
\
\ ------------------------------------------------------------------------------
\
\ Add the signed delta (A R) to a ship's coordinate, along the axis given in X.
\ Mathematically speaking, this routine translates the ship along a single axis
\ by a signed delta. Taking the example of X = 0, the x-axis, it does the
\ following:
\
\   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
\
\ (In practice, MVT1 is only ever called directly with A = 0 or 128, otherwise
\ it is always called via MVT-2, which clears A apart from the sign bit. The
\ routine is written to cope with a non-zero delta_hi, so it supports a full
\ 16-bit delta, but it appears that delta_hi is only ever used to hold the
\ sign of the delta.)
\
\ The comments below assume we are adding delta to the x-axis, though the axis
\ is determined by the value of X.
\
\ Arguments:
\
\   (A R)               The signed delta, so A = delta_hi and R = delta_lo
\
\   X                   Determines which coordinate axis of INWK to change:
\
\                         * X = 0 adds the delta to (x_lo, x_hi, x_sign)
\
\                         * X = 3 adds the delta to (y_lo, y_hi, y_sign)
\
\                         * X = 6 adds the delta to (z_lo, z_hi, z_sign)
\
\ Other entry points:
\
\   MVT1-2              Clear bits 0-6 of A before entering MVT1
\
\ ******************************************************************************

 AND #%10000000         \ Clear bits 0-6 of A

.MVT1

 ASL A                  \ Set the C flag to the sign bit of the delta, leaving
                        \ delta_hi << 1 in A

 STA S                  \ Set S = delta_hi << 1
                        \
                        \ This also clears bit 0 of S

 LDA #0                 \ Set T = just the sign bit of delta (in bit 7)
 ROR A
 STA T

 LSR S                  \ Set S = delta_hi >> 1
                        \       = |delta_hi|
                        \
                        \ This also clear the C flag, as we know that bit 0 of
                        \ S was clear before the LSR

 EOR INWK+2,X           \ If T EOR x_sign has bit 7 set, then x_sign and delta
 BMI MV10               \ have different signs, so jump to MV10

                        \ At this point, we know x_sign and delta have the same
                        \ sign, that sign is in T, and S contains |delta_hi|,
                        \ so now we want to do:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (S R)
                        \
                        \ and then set the sign of the result to the same sign
                        \ as x_sign and delta

 LDA R                  \ First we add the low bytes, so:
 ADC INWK,X             \
 STA INWK,X             \   x_lo = x_lo + R

 LDA S                  \ Then we add the high bytes:
 ADC INWK+1,X           \
 STA INWK+1,X           \   x_hi = x_hi + S

 LDA INWK+2,X           \ And finally we add any carry into x_sign, and if the
 ADC #0                 \ sign of x_sign and delta in T is negative, make sure
 ORA T                  \ the result is negative (by OR'ing with T)
 STA INWK+2,X

 RTS                    \ Return from the subroutine

.MV10

                        \ If we get here, we know x_sign and delta have
                        \ different signs, with delta's sign in T, and
                        \ |delta_hi| in S, so now we want to do:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - (S R)
                        \
                        \ and then set the sign of the result according to
                        \ the signs of x_sign and delta

 LDA INWK,X             \ First we subtract the low bytes, so:
 SEC                    \
 SBC R                  \   x_lo = x_lo - R
 STA INWK,X

 LDA INWK+1,X           \ Then we subtract the high bytes:
 SBC S                  \
 STA INWK+1,X           \   x_hi = x_hi - S

 LDA INWK+2,X           \ And finally we subtract any borrow from bits 0-6 of
 AND #%01111111         \ x_sign, and give the result the opposite sign bit to T
 SBC #0                 \ (i.e. give it the sign of the original x_sign)
 ORA #%10000000
 EOR T
 STA INWK+2,X

 BCS MV11               \ If the C flag is set by the above SBC, then our sum
                        \ above didn't underflow and is correct - to put it
                        \ another way, (x_sign x_hi x_lo) >= (S R) so the result
                        \ should indeed have the same sign as x_sign, so jump to
                        \ MV11 to return from the subroutine

                        \ Otherwise our subtraction underflowed because
                        \ (x_sign x_hi x_lo) < (S R), so we now need to flip the
                        \ subtraction around by using two's complement to this:
                        \
                        \   (S R) - (x_sign x_hi x_lo)
                        \
                        \ and then we need to give the result the same sign as
                        \ (S R), the delta, as that's the dominant figure in the
                        \ sum

 LDA #1                 \ First we subtract the low bytes, so:
 SBC INWK,X             \
 STA INWK,X             \   x_lo = 1 - x_lo

 LDA #0                 \ Then we subtract the high bytes:
 SBC INWK+1,X           \
 STA INWK+1,X           \   x_hi = 0 - x_hi

 LDA #0                 \ And then we subtract the sign bytes:
 SBC INWK+2,X           \
                        \   x_sign = 0 - x_sign

 AND #%01111111         \ Finally, we set the sign bit to the sign in T, the
 ORA T                  \ sign of the original delta, as the delta is the
 STA INWK+2,X           \ dominant figure in the sum

.MV11

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
\       Name: MVT6
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
\
\ ------------------------------------------------------------------------------
\
\ Do the following calculation, for the coordinate given by X (so this is what
\ it does for the x-coordinate):
\
\   (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
\
\ A is a sign bit and is not included in the calculation, but bits 0-6 of A are
\ preserved. Bit 7 is set to the sign of the result.
\
\ Arguments:
\
\   A                   The sign of P(2 1) in bit 7
\
\   P(2 1)              The 16-bit value we want to add the coordinate to
\
\   X                   The coordinate to add, as follows:
\
\                         * If X = 0, add to (x_sign x_hi x_lo)
\
\                         * If X = 3, add to (y_sign y_hi y_lo)
\
\                         * If X = 6, add to (z_sign z_hi z_lo)
\
\ Returns:
\
\   A                   The sign of the result (in bit 7)
\
\ ******************************************************************************

.MVT6

 TAY                    \ Store argument A into Y, for later use

 EOR INWK+2,X           \ Set A = A EOR x_sign

 BMI MV50               \ If the sign is negative, i.e. A and x_sign have
                        \ different signs, jump to MV50

                        \ The signs are the same, so we can add the two
                        \ arguments and keep the sign to get the result

 LDA P+1                \ First we add the low bytes:
 CLC                    \
 ADC INWK,X             \   P+1 = P+1 + x_lo
 STA P+1

 LDA P+2                \ And then the high bytes:
 ADC INWK+1,X           \
 STA P+2                \   P+2 = P+2 + x_hi

 TYA                    \ Restore the original A argument that we stored earlier
                        \ so that we keep the original sign

 RTS                    \ Return from the subroutine

.MV50

 LDA INWK,X             \ First we subtract the low bytes:
 SEC                    \
 SBC P+1                \   P+1 = x_lo - P+1
 STA P+1

 LDA INWK+1,X           \ And then the high bytes:
 SBC P+2                \
 STA P+2                \   P+2 = x_hi - P+2

 BCC MV51               \ If the last subtraction underflowed, then the C flag
                        \ will be clear and x_hi < P+2, so jump to MV51 to
                        \ negate the result

 TYA                    \ Restore the original A argument that we stored earlier
 EOR #%10000000         \ but flip bit 7, which flips the sign. We do this
                        \ because x_hi >= P+2 so we want the result to have the
                        \ same sign as x_hi (as it's the dominant side in this
                        \ calculation). The sign of x_hi is x_sign, and x_sign
                        \ has the opposite sign to A, so we flip the sign in A
                        \ to return the correct result

 RTS                    \ Return from the subroutine

.MV51

 LDA #1                 \ Our subtraction underflowed, so we negate the result
 SBC P+1                \ using two's complement, first with the low byte:
 STA P+1                \
                        \   P+1 = 1 - P+1

 LDA #0                 \ And then the high byte:
 SBC P+2                \
 STA P+2                \   P+2 = 0 - P+2

 TYA                    \ Restore the original A argument that we stored earlier
                        \ as this is the correct sign for the result. This is
                        \ because x_hi < P+2, so we want to return the same sign
                        \ as P+2, the dominant side

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MV40
\       Type: Subroutine
\   Category: Moving
\    Summary: Rotate the planet or sun's location in space by the amount of
\             pitch and roll of our ship
\
\ ------------------------------------------------------------------------------
\
\ We implement this using the same equations as in part 5 of MVEIT, where we
\ rotated the current ship's location by our pitch and roll. Specifically, the
\ calculation is as follows:
\
\   1. K2 = y - alpha * x
\   2. z = z + beta * K2
\   3. y = K2 - beta * z
\   4. x = x + alpha * y
\
\ See the deep dive on "Rotating the universe" for more details on the above.
\
\ ******************************************************************************

.MV40

 LDA ALPHA              \ Set Q = -ALPHA, so Q contains the angle we want to
 EOR #%10000000         \ roll the planet through (i.e. in the opposite
 STA Q                  \ direction to our ship's roll angle alpha)

 LDA INWK               \ Set P(1 0) = (x_hi x_lo)
 STA P
 LDA INWK+1
 STA P+1

 LDA INWK+2             \ Set A = x_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \
                        \ which also means:
                        \
                        \   K(3 2 1) = (A P+1 P) * Q / 256
                        \            = x * -alpha / 256
                        \            = - alpha * x / 256

 LDX #3                 \ Set K(3 2 1) = (y_sign y_hi y_lo) + K(3 2 1)
 JSR MVT3               \              = y - alpha * x / 256

 LDA K+1                \ Set K2(2 1) = P(1 0) = K(2 1)
 STA K2+1
 STA P

 LDA K+2                \ Set K2+2 = K+2
 STA K2+2

 STA P+1                \ Set P+1 = K+2

 LDA BETA               \ Set Q = beta, the pitch angle of our ship
 STA Q

 LDA K+3                \ Set K+3 to K2+3, so now we have result 1 above:
 STA K2+3               \
                        \   K2(3 2 1) = K(3 2 1)
                        \             = y - alpha * x / 256

                        \ We also have:
                        \
                        \   A = K+3
                        \
                        \   P(1 0) = K(2 1)
                        \
                        \ so combined, these mean:
                        \
                        \   (A P+1 P) = K(3 2 1)
                        \             = K2(3 2 1)

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \
                        \ which also means:
                        \
                        \   K(3 2 1) = (A P+1 P) * Q / 256
                        \            = K2(3 2 1) * beta / 256
                        \            = beta * K2 / 256

 LDX #6                 \ K(3 2 1) = (z_sign z_hi z_lo) + K(3 2 1)
 JSR MVT3               \          = z + beta * K2 / 256

 LDA K+1                \ Set P = K+1
 STA P

 STA INWK+6             \ Set z_lo = K+1

 LDA K+2                \ Set P+1 = K+2
 STA P+1

 STA INWK+7             \ Set z_hi = K+2

 LDA K+3                \ Set A = z_sign = K+3, so now we have:
 STA INWK+8             \
                        \   (z_sign z_hi z_lo) = K(3 2 1)
                        \                      = z + beta * K2 / 256

                        \ So we now have result 2 above:
                        \
                        \   z = z + beta * K2

 EOR #%10000000         \ Flip the sign bit of A to give A = -z_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \                = (-z_sign z_hi z_lo) * beta
                        \                = -z * beta

 LDA K+3                \ Set T to the sign bit of K(3 2 1 0), i.e. to the sign
 AND #%10000000         \ bit of -z * beta
 STA T

 EOR K2+3               \ If K2(3 2 1 0) has a different sign to K(3 2 1 0),
 BMI MV1                \ then EOR'ing them will produce a 1 in bit 7, so jump
                        \ to MV1 to take this into account

                        \ If we get here, K and K2 have the same sign, so we can
                        \ add them together to get the result we're after, and
                        \ then set the sign afterwards

 LDA K                  \ We now do the following sum:
 CLC                    \
 ADC K2                 \   (A y_hi y_lo -) = K(3 2 1 0) + K2(3 2 1 0)
                        \
                        \ starting with the low bytes (which we don't keep)
                        \
                        \ The CLC has no effect because MULT3 clears the C
                        \ flag, so this instruction could be removed (as it is
                        \ in the cassette version, for example)

 LDA K+1                \ We then do the middle bytes, which go into y_lo
 ADC K2+1
 STA INWK+3

 LDA K+2                \ And then the high bytes, which go into y_hi
 ADC K2+2
 STA INWK+4

 LDA K+3                \ And then the sign bytes into A, so overall we have the
 ADC K2+3               \ following, if we drop the low bytes from the result:
                        \
                        \   (A y_hi y_lo) = (K + K2) / 256

 JMP MV2                \ Jump to MV2 to skip the calculation for when K and K2
                        \ have different signs

.MV1

 LDA K                  \ If we get here then K2 and K have different signs, so
 SEC                    \ instead of adding, we need to subtract to get the
 SBC K2                 \ result we want, like this:
                        \
                        \   (A y_hi y_lo -) = K(3 2 1 0) - K2(3 2 1 0)
                        \
                        \ starting with the low bytes (which we don't keep)

 LDA K+1                \ We then do the middle bytes, which go into y_lo
 SBC K2+1
 STA INWK+3

 LDA K+2                \ And then the high bytes, which go into y_hi
 SBC K2+2
 STA INWK+4

 LDA K2+3               \ Now for the sign bytes, so first we extract the sign
 AND #%01111111         \ byte from K2 without the sign bit, so P = |K2+3|
 STA P

 LDA K+3                \ And then we extract the sign byte from K without the
 AND #%01111111         \ sign bit, so A = |K+3|

 SBC P                  \ And finally we subtract the sign bytes, so P = A - P
 STA P

                        \ By now we have the following, if we drop the low bytes
                        \ from the result:
                        \
                        \   (A y_hi y_lo) = (K - K2) / 256
                        \
                        \ so now we just need to make sure the sign of the
                        \ result is correct

 BCS MV2                \ If the C flag is set, then the last subtraction above
                        \ didn't underflow and the result is correct, so jump to
                        \ MV2 as we are done with this particular stage

 LDA #1                 \ Otherwise the subtraction above underflowed, as K2 is
 SBC INWK+3             \ the dominant part of the subtraction, so we need to
 STA INWK+3             \ negate the result using two's complement, starting
                        \ with the low bytes:
                        \
                        \   y_lo = 1 - y_lo

 LDA #0                 \ And then the high bytes:
 SBC INWK+4             \
 STA INWK+4             \   y_hi = 0 - y_hi

 LDA #0                 \ And finally the sign bytes:
 SBC P                  \
                        \   A = 0 - P

 ORA #%10000000         \ We now force the sign bit to be negative, so that the
                        \ final result below gets the opposite sign to K, which
                        \ we want as K2 is the dominant part of the sum

.MV2

 EOR T                  \ T contains the sign bit of K, so if K is negative,
                        \ this flips the sign of A

 STA INWK+5             \ Store A in y_sign

                        \ So we now have result 3 above:
                        \
                        \   y = K2 + K
                        \     = K2 - beta * z

 LDA ALPHA              \ Set A = alpha
 STA Q

 LDA INWK+3             \ Set P(1 0) = (y_hi y_lo)
 STA P
 LDA INWK+4
 STA P+1

 LDA INWK+5             \ Set A = y_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \                = (y_sign y_hi y_lo) * alpha
                        \                = y * alpha

 LDX #0                 \ Set K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
 JSR MVT3               \              = x + y * alpha / 256

 LDA K+1                \ Set (x_sign x_hi x_lo) = K(3 2 1)
 STA INWK               \                        = x + y * alpha / 256
 LDA K+2
 STA INWK+1
 LDA K+3
 STA INWK+2

                        \ So we now have result 4 above:
                        \
                        \   x = x + y * alpha

 JMP MV45               \ We have now finished rotating the planet or sun by
                        \ our pitch and roll, so jump back into the MVEIT
                        \ routine at MV45 to apply all the other movements

\ ******************************************************************************
\
\       Name: PU1
\       Type: Subroutine
\   Category: Flight
\    Summary: Flip the coordinate axes for the four different views
\  Deep dive: Flipping axes between space views
\
\ ------------------------------------------------------------------------------
\
\ This routine flips the relevant geometric axes in INWK depending on which
\ view we are looking through (front, rear, left, right).
\
\ Other entry points:
\
\   LO2                 Contains an RTS
\
\ ******************************************************************************

.PU1

 DEX                    \ Decrement the view, so now:
                        \
                        \   0 = rear
                        \   1 = left
                        \   2 = right

 BNE PU2                \ If the current view is left or right, jump to PU2,
                        \ otherwise this is the rear view, so continue on

 LDA INWK+2             \ Flip the sign of x_sign
 EOR #%10000000
 STA INWK+2

 LDA INWK+8             \ Flip the sign of z_sign
 EOR #%10000000
 STA INWK+8

 LDA INWK+10            \ Flip the sign of nosev_x_hi
 EOR #%10000000
 STA INWK+10

 LDA INWK+14            \ Flip the sign of nosev_z_hi
 EOR #%10000000
 STA INWK+14

 LDA INWK+16            \ Flip the sign of roofv_x_hi
 EOR #%10000000
 STA INWK+16

 LDA INWK+20            \ Flip the sign of roofv_z_hi
 EOR #%10000000
 STA INWK+20

 LDA INWK+22            \ Flip the sign of sidev_x_hi
 EOR #%10000000
 STA INWK+22

 LDA INWK+26            \ Flip the sign of roofv_z_hi
 EOR #%10000000
 STA INWK+26

 RTS                    \ Return from the subroutine

.PU2

                        \ We enter this with X set to the view, as follows:
                        \
                        \   1 = left
                        \   2 = right

 LDA #0                 \ Set RAT2 = 0 (left view) or -1 (right view)
 CPX #2
 ROR A
 STA RAT2

 EOR #%10000000         \ Set RAT = -1 (left view) or 0 (right view)
 STA RAT

 LDA INWK               \ Swap x_lo and z_lo
 LDX INWK+6
 STA INWK+6
 STX INWK

 LDA INWK+1             \ Swap x_hi and z_hi
 LDX INWK+7
 STA INWK+7
 STX INWK+1

 LDA INWK+2             \ Swap x_sign and z_sign
 EOR RAT                \ If left view, flip sign of new z_sign
 TAX                    \ If right view, flip sign of new x_sign
 LDA INWK+8
 EOR RAT2
 STA INWK+2
 STX INWK+8

 LDY #9                 \ Swap nosev_x_lo and nosev_z_lo
 JSR PUS1               \ Swap nosev_x_hi and nosev_z_hi
                        \ If left view, flip sign of new nosev_z_hi
                        \ If right view, flip sign of new nosev_x_hi

 LDY #15                \ Swap roofv_x_lo and roofv_z_lo
 JSR PUS1               \ Swap roofv_x_hi and roofv_z_hi
                        \ If left view, flip sign of new roofv_z_hi
                        \ If right view, flip sign of new roofv_x_hi

 LDY #21                \ Swap sidev_x_lo and sidev_z_lo
                        \ Swap sidev_x_hi and sidev_z_hi
                        \ If left view, flip sign of new sidev_z_hi
                        \ If right view, flip sign of new sidev_x_hi

.PUS1

 LDA INWK,Y             \ Swap the low x and z bytes for the vector in Y:
 LDX INWK+4,Y           \
 STA INWK+4,Y           \   * For Y =  9 swap nosev_x_lo and nosev_z_lo
 STX INWK,Y             \   * For Y = 15 swap roofv_x_lo and roofv_z_lo
                        \   * For Y = 21 swap sidev_x_lo and sidev_z_lo

 LDA INWK+1,Y           \ Swap the high x and z bytes for the offset in Y:
 EOR RAT                \
 TAX                    \   * If left view, flip sign of new z-coordinate
 LDA INWK+5,Y           \   * If right view, flip sign of new x-coordinate
 EOR RAT2
 STA INWK+1,Y
 STX INWK+5,Y

                        \ Fall through into LOOK1 to return from the subroutine

\ ******************************************************************************
\
\       Name: LOOK1
\       Type: Subroutine
\   Category: Flight
\    Summary: Initialise the space view
\
\ ------------------------------------------------------------------------------
\
\ Initialise the space view, with the direction of view given in X. This clears
\ the upper screen and draws the laser crosshairs, if the view in X has lasers
\ fitted. It also wipes all the ships from the scanner, so we can recalculate
\ ship positions for the new view (they get put back in the main flight loop).
\
\ Arguments:
\
\   X                   The space view to set:
\
\                         * 0 = front
\
\                         * 1 = rear
\
\                         * 2 = left
\
\                         * 3 = right
\
\ Other entry points:
\
\   LO2                 Contains an RTS
\
\ ******************************************************************************

.LO2

 RTS                    \ Return from the subroutine

.LQ

 STX VIEW               \ Set the current space view to X

 JSR TT66               \ Clear the top part of the screen, draw a white border,
                        \ and set the current view type in QQ11 to 0 (space
                        \ view)

 JSR SIGHT              \ Draw the laser crosshairs

 JMP NWSTARS            \ Set up a new stardust field and return from the
                        \ subroutine using a tail call

.LOOK1

 LDA #0                 \ Set A = 0, the type number of a space view

 LDY QQ11               \ If the current view is not a space view, jump up to LQ
 BNE LQ                 \ to set up a new space view

 CPX VIEW               \ If the current view is already of type X, jump to LO2
 BEQ LO2                \ to return from the subroutine (as LO2 contains an RTS)

 STX VIEW               \ Change the current space view to X

 JSR TT66               \ Clear the top part of the screen, draw a white border,
                        \ and set the current view type in QQ11 to 0 (space
                        \ view)

 JSR FLIP               \ Swap the x- and y-coordinates of all the stardust
                        \ particles

 JSR WPSHPS             \ Wipe all the ships from the scanner

                        \ And fall through into SIGHT to draw the laser
                        \ crosshairs

\ ******************************************************************************
\
\       Name: SIGHT
\       Type: Subroutine
\   Category: Flight
\    Summary: Draw the laser crosshairs
\
\ ******************************************************************************

.SIGHT

 LDY VIEW               \ Fetch the laser power for our new view
 LDA LASER,Y

 BEQ LO2                \ If it is zero (i.e. there is no laser fitted to this
                        \ view), jump to LO2 to return from the subroutine (as
                        \ LO2 contains an RTS)

 LDA #128               \ Set QQ19 to the x-coordinate of the centre of the
 STA QQ19               \ screen

 LDA #Y-24              \ Set QQ19+1 to the y-coordinate of the centre of the
 STA QQ19+1             \ screen, minus 24 (because TT15 will add 24 to the
                        \ coordinate when it draws the crosshairs)

 LDA #20                \ Set QQ19+2 to size 20 for the crosshairs size
 STA QQ19+2

 JSR TT15               \ Call TT15 to draw crosshairs of size 20 just to the
                        \ left of the middle of the screen

 LDA #10                \ Set QQ19+2 to size 10 for the crosshairs size
 STA QQ19+2

 JMP TT15               \ Call TT15 to draw crosshairs of size 10 at the same
                        \ location, which will remove the centre part from the
                        \ laser crosshairs, leaving a gap in the middle, and
                        \ return from the subroutine using a tail call

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
\   BOX                 Just draw the border and (if this is a space view) the
\                       view name. This can be used to remove the border and
\                       view name, as it is drawn using EOR logic
\
\ Other entry points:
\
\   BOL1-1              Contains an RTS
\
\ ******************************************************************************

.TTX66

 JSR vdu_80             \ AJD

 JSR FLFLLS             \ Call FLFLLS to reset the LSO block

 STA LAS2               \ Set LAS2 = 0 to stop any laser pulsing (the call to
                        \ FLFLLS sets A = 0)

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

 LDX QQ22+1             \ Fetch into X the number that's shown on-screen during
                        \ the hyperspace countdown

 BEQ BOX                \ If the counter is zero then we are not counting down
                        \ to hyperspace, so jump to BOX to skip the next
                        \ instruction

 JSR ee3                \ Print the 8-bit number in X at text location (0, 1),
                        \ i.e. print the hyperspace countdown in the top-left
                        \ corner

.BOX

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

 LDA #20                \ Move the text cursor to row 20, near the bottom of
 STA YC                 \ the screen

 LDA #&75               \ Set the two-byte value in SC to &7507
 STA SC+1
 LDA #7
 STA SC

 JSR TT67               \ Print a newline, which will move the text cursor down
                        \ a line (to row 21) and back to column 1

 LDA #0                 \ Call LYN to clear the pixels from &7507 to &75F0
 JSR LYN

 INC SC+1               \ Increment SC+1 so SC points to &7607

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

.iff_xor

 EQUB &00, &00, &0F	\, &FF, &F0 overlap

.iff_base

 EQUB &FF, &F0, &FF, &F0, &FF

.SCAN

 LDA &65
 AND #&10
 BEQ SC5
 LDA &8C
 BMI SC5

 JSR iff_index          \ AJD
 LDA iff_base,X
 STA &91
 LDA iff_xor,X
 STA &37

 LDA &47
 ORA &4A
 ORA &4D
 AND #&C0
 BNE SC5
 LDA &47
 CLC
 LDX &48
 BPL SC2
 EOR #&FF
 ADC #&01

.SC2

 ADC #&7B
 STA &34
 LDA &4D
 LSR A
 LSR A
 CLC
 LDX &4E
 BPL SC3
 EOR #&FF
 SEC

.SC3

 ADC #&23
 EOR #&FF
 STA SC
 LDA &4A
 LSR A
 CLC
 LDX &4B
 BMI SCD6
 EOR #&FF
 SEC

.SCD6

 ADC SC
 BPL ld246
 CMP #&C2
 BCS l_55ac
 LDA #&C2

.l_55ac

 CMP #&F7
 BCC l_55b2

.ld246

 LDA #&F6

.l_55b2

 STA &35
 SEC
 SBC SC
 \	PHP
 PHA
 JSR CPIX4
 LDA TWOS+&11,X
 TAX
 AND &91	\ iff
 STA &34
 TXA
 AND &37
 STA &35
 PLA
 \	PLP
 TAX
 BEQ l_55da
 \	BCC l_55db
 BMI l_55db

.l_55ca

 DEY
 BPL l_55d1
 LDY #&07
 DEC SC+&01

.l_55d1

 LDA &34
 EOR &35	\ iff
 STA &34	\ iff
 EOR (SC),Y
 STA (SC),Y
 DEX
 BNE l_55ca

.l_55da

 RTS

.l_55db

 INY
 CPY #&08
 BNE l_55e4
 LDY #&00
 INC SC+&01

.l_55e4

 INY
 CPY #&08
 BNE l_55ed
 LDY #&00
 INC SC+&01

.l_55ed

 LDA &34
 EOR &35	\ iff
 STA &34	\ iff
 EOR (SC),Y
 STA (SC),Y
 INX
 BNE l_55e4
 RTS

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
\ Save output/1.F.bin
\
\ ******************************************************************************

PRINT "S.1.F ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/1.F.bin", CODE%, P%, LOAD%