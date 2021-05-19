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

 JMP CHPR
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

 JSR l_3ee1
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

 JSR l_29ff
 JSR l_29ff
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

 JSR l_29ff
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
 \	JSR l_3ee1
 \	STY &0341
 INC cmdr_bomb
 INC new_hold	\***
 \	JSR l_32c1
 JSR DORND
 STA data_homex	\QQ0
 STX data_homey	\QQ1
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
 AND cmdr_escape
 BEQ l_130c
 JMP l_20c1

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
 LDA laser_t
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
 JSR l_2a82
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
 INC cmdr_cargo,X
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

.l_143e

 JSR l_3ee1
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
 JSR l_43ba
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

 JSR l_488c

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
 LDX energy
 BPL l_156c
 LDX r_shield
 JSR l_3626
 STX r_shield
 LDX f_shield
 JSR l_3626
 STX f_shield

.l_156c

 SEC
 LDA cmdr_eunit
 ADC energy
 BCS l_1578
 STA energy

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
 CMP energy
 BCC l_15da
 ASL A
 JSR l_45c6

.l_15da

 LDY #&FF
 STY altitude
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
 STA altitude
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
 STA cabin_t
 LDA &0320
 BNE l_1648
 LDY #&25
 JSR MAS2
 BNE l_1648
 JSR MAS3
 EOR #&FF
 ADC #&1E
 STA cabin_t
 BCS l_15fa
 CMP #&E0
 BCC l_1648
 LDA BST
 BEQ l_1648
 LDA &7F
 LSR A
 ADC cmdr_fuel
 CMP new_range
 BCC l_1640
 LDA new_range

.l_1640

 STA cmdr_fuel
 LDA #&A0

.l_1645

 JSR l_45c6

.l_1648

 LDA &0343
 BEQ l_165c
 LDA &0346
 CMP #&08
 BCS l_165c
 JSR l_2aa1
 LDA #&00
 STA &0343

.l_165c

 LDA &0340
 BEQ l_1666
 JSR l_3629
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

.MVT3

 LDA &43
 STA &83
 AND #&80
 STA &D1
 EOR &48,X
 BMI l_1d70
 LDA &41
 CLC
 ADC &46,X
 STA &41
 LDA &42
 ADC &47,X
 STA &42
 LDA &43
 ADC &48,X
 AND #&7F
 ORA &D1
 STA &43
 RTS

.l_1d70

 LDA &83
 AND #&7F
 STA &83
 LDA &46,X
 SEC
 SBC &41
 STA &41
 LDA &47,X
 SBC &42
 STA &42
 LDA &48,X
 AND #&7F
 SBC &83
 ORA #&80
 EOR &D1
 STA &43
 BCS l_1da7
 LDA #&01
 SBC &41
 STA &41
 LDA #&00
 SBC &42
 STA &42
 LDA #&00
 SBC &43
 AND #&7F
 ORA &D1
 STA &43

.l_1da7

 RTS

.MVS5

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
 JSR ADD
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
 JSR ADD
 STA &47,Y
 STX &46,Y
 LDX &81
 LDA &40
 STA &46,X
 LDA &41
 STA &47,X
 RTS

.l_1e34

 EQUD &00E87648

.c_1e38

 CLC

.l_1e38

 LDA #&03

.l_1e3a

 LDY #&00

.l_1e3c

 STA &80
 LDA #&00
 STA &40
 STA &41
 STY &42
 STX &43

.l_1e48

 LDX #&0B
 STX &D1
 PHP
 BCC l_1e53
 DEC &D1
 DEC &80

.l_1e53

 LDA #&0B
 SEC
 STA &86
 SBC &80
 STA &80
 INC &80
 LDY #&00
 STY &83
 JMP l_1ea4

.l_1e65

 ASL &43
 ROL &42
 ROL &41
 ROL &40
 ROL &83
 LDX #&03

.l_1e71

 LDA &40,X
 STA &34,X
 DEX
 BPL l_1e71
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

.l_1e93

 LDA &40,X
 ADC &34,X
 STA &40,X
 DEX
 BPL l_1e93
 LDA &38
 ADC &83
 STA &83
 LDY #&00

.l_1ea4

 LDX #&03
 SEC

.l_1ea7

 LDA &40,X
 SBC l_1e34,X
 STA &34,X
 DEX
 BPL l_1ea7
 LDA &83
 SBC #&17
 STA &38
 BCC l_1eca
 LDX #&03

.l_1ebb

 LDA &34,X
 STA &40,X
 DEX
 BPL l_1ebb
 LDA &38
 STA &83
 INY
 JMP l_1ea4

.l_1eca

 TYA
 BNE l_1ed9
 LDA &D1
 BEQ l_1ed9
 DEC &80
 BPL l_1ee3
 LDA #&20
 BNE l_1ee0

.l_1ed9

 LDY #&00
 STY &D1
 CLC
 ADC #&30

.l_1ee0

 JSR CHPR

.l_1ee3

 DEC &D1
 BPL l_1ee9
 INC &D1

.l_1ee9

 DEC &86
 BMI l_1f5b
 BNE l_1ef7
 PLP
 BCC l_1ef7
 LDA #&2E
 JSR CHPR

.l_1ef7

 JMP l_1e65

.l_1efa

 LDA #&07

.CHPR

 STA &D2
 STY &034F
 STX &034E
 LDY QQ17
 CPY #&FF
 BEQ l_1f52
 CMP #&07
 BEQ l_1f5c
 CMP #&20
 BCS l_1f1e
 CMP #&0A
 BEQ l_1f1a
 LDX #&01
 STX XC

.l_1f1a

 INC YC
 BNE l_1f52

.l_1f1e

 LDX #&BF
 ASL A
 ASL A
 BCC l_1f26
 LDX #&C1

.l_1f26

 ASL A
 BCC l_1f2a
 INX

.l_1f2a

 STA font
 STX font+&01
 LDA XC
 ASL A
 ASL A
 ASL A
 STA SC
 INC XC
 LDA YC
 CMP #&18
 BCC l_1f43
 JSR TT66
 JMP l_1f52

.l_1f43

 ORA #&60

.l_1f45

 STA SC+&01
 LDY #&07

.l_1f49

 LDA (font),Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL l_1f49

.l_1f52

 LDY &034F
 LDX &034E
 LDA &D2
 CLC

.l_1f5b

 RTS

.l_1f5c

 JSR l_43ba
 JMP l_1f52

.l_1f62

 LDA #&D0
 STA SC
 LDA #&78
 STA SC+&01
 JSR l_2026
 STX &41
 STA &40
 LDA #&0E
 STA &06
 LDA &7D
 JSR l_2039
 LDA #&00
 STA &82
 STA &1B
 LDA #&08
 STA &83
 LDA &31
 LSR A
 LSR A
 ORA &32
 EOR #&80
 JSR ADD
 JSR l_208d
 LDA &2A
 LDX &2B
 BEQ l_1f9a
 SBC #&01

.l_1f9a

 JSR ADD
 JSR l_208d
 LDA &8A
 AND #&03
 BNE l_1f5b
 LDY #&00
 JSR l_2026
 STX &40
 STA &41
 LDX #&03
 STX &06

.l_1fb3

 STY &3A,X
 DEX
 BPL l_1fb3
 LDX #&03
 LDA energy
 LSR A
 LSR A
 STA &81

.l_1fc1

 SEC
 SBC #&10
 BCC l_1fd3
 STA &81
 LDA #&10
 STA &3A,X
 LDA &81
 DEX
 BPL l_1fc1
 BMI l_1fd7

.l_1fd3

 LDA &81
 STA &3A,X

.l_1fd7

 LDA &3A,Y
 STY &1B
 JSR l_203a
 LDY &1B
 INY
 CPY #&04
 BNE l_1fd7
 LDA #&78
 STA SC+&01
 LDA #&10
 STA SC
 LDA f_shield
 JSR l_2036
 LDA r_shield
 JSR l_2036
 LDA cmdr_fuel
 JSR l_2038
 JSR l_2026
 STX &41
 STA &40
 LDX #&0B
 STX &06
 LDA cabin_t
 JSR l_2036
 LDA laser_t
 JSR l_2036
 LDA #&F0
 STA &06
 STA &41
 LDA altitude
 JSR l_2036
 JMP l_3634

.l_2026

 LDX #&F0
 LDA &8A
 AND #&08
 AND f_flag
 BEQ l_2033
 TXA
 EQUB &2C

.l_2033

 LDA #&0F
 RTS

.l_2036

 LSR A
 LSR A

.l_2038

 LSR A

.l_2039

 LSR A

.l_203a

 STA &81
 LDX #&FF
 STX &82
 CMP &06
 BCS l_2048
 LDA &41
 BNE l_204a

.l_2048

 LDA &40

.l_204a

 STA &91
 LDY #&02
 LDX #&03

.l_2050

 LDA &81
 CMP #&04
 BCC l_2070
 SBC #&04
 STA &81
 LDA &82

.l_205c

 AND &91
 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 TYA
 CLC
 ADC #&06
 TAY
 DEX
 BMI l_208a
 BPL l_2050

.l_2070

 EOR #&03
 STA &81
 LDA &82

.l_2076

 ASL A
 AND #&EF
 DEC &81
 BPL l_2076
 PHA
 LDA #&00
 STA &82
 LDA #&63
 STA &81
 PLA
 JMP l_205c

.l_208a

 INC SC+&01
 RTS

.l_208d

 LDY #&01
 STA &81

.l_2091

 SEC
 LDA &81
 SBC #&04
 BCS l_20a6
 LDA #&FF
 LDX &81
 STA &81
 LDA TWOS+&10,X
 AND #&F0
 JMP l_20aa

.l_20a6

 STA &81
 LDA #&00

.l_20aa

 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 INY
 STA (SC),Y
 TYA
 CLC
 ADC #&05
 TAY
 CPY #&1E
 BCC l_2091
 INC SC+&01
 RTS

.l_20c1

 JSR l_3ee1
 LDX #&03	\ escape capsule
 STX &8C
 JSR l_2508
 LDA #&10
 STA &61
 LDA #&C2
 STA &64
 LSR A
 STA &66

.l_20dd

 JSR MVEIT
 JSR l_488c
 DEC &66
 BNE l_20dd
 JSR SCAN
 LDA #&00
 STA cmdr_cargo+&10
 LDX #&0C	\LDX #&10	\ save gold/plat/gems

.l_20ee

 STA cmdr_cargo,X
 DEX
 BPL l_20ee
 STA FIST
 STA cmdr_escape
 INC new_hold	\**
 LDA new_range
 STA cmdr_fuel
 JSR l_3d68
 JSR TT111
 JSR l_309f
 JMP l_143e

.l_2102

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
 BMI l_2102
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
 JSR l_28de
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
 JSR l_28e0
 TAX
 JSR l_2332
 STA &64
 LDA &63
 ASL A
 CMP #&20
 BCS l_2305
 LDY #&16
 JSR l_28e0
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

 JSR l_28de
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
 JSR l_28de
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
 JSR l_28d4
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

.l_2508

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
 JSR l_2508
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

.l_2642

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
 JSR l_3b90
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
 JSR l_2961
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
 BEQ l_2838
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

.l_280b

 AND #&7F

.SQUA2

 STA &1B
 TAX
 BNE l_2824

.l_2812

 CLC
 STX &1B
 TXA
 RTS

.MLU1

 LDA &0F82,Y
 STA &35

.MLU2

 AND #&7F
 STA &1B

.l_2820

 LDX &81
 BEQ l_2812

.l_2824

 DEX
 STX &D1
 LDA #&00
 LDX #&08
 LSR &1B

.l_282d

 BCC l_2831
 ADC &D1

.l_2831

 ROR A
 ROR &1B
 DEX
 BNE l_282d
 RTS

.l_2838

 STA font
 STA &1B
 RTS

.l_283d

 AND #&1F
 TAX
 LDA &07C0,X
 STA &81
 LDA &40

.FMLTU

 EOR #&FF
 SEC
 ROR A
 STA &1B
 LDA #&00

.l_284f

 BCS l_2859
 ADC &81
 ROR A
 LSR &1B
 BNE l_284f
 RTS

.l_2859

 LSR A
 LSR &1B
 BNE l_284f
 RTS

.l_286c

 BCC l_2870
 ADC &D1

.l_2870

 ROR A
 ROR &1B
 DEX
 BNE l_286c
 RTS

.l_2877

 STX &81

.MLTU2

 EOR #&FF
 LSR A
 STA font
 LDA #&00
 LDX #&10
 ROR &1B

.l_2884

 BCS l_2891
 ADC &81
 ROR A
 ROR font
 ROR &1B
 DEX
 BNE l_2884
 RTS

.l_2891

 LSR A
 ROR font
 ROR &1B
 DEX
 BNE l_2884
 RTS

.MUT2

 LDX &25
 STX &83

.MUT1

 LDX &24
 STX &82

.l_28a6

 TAX
 AND #&7F
 LSR A
 \	LSR A	\ manoevre
 STA &1B
 TXA
 EOR &81
 AND #&80
 STA &D1
 LDA &81
 AND #&7F
 BEQ l_28d1
 TAX
 DEX
 STX &06
 LDA #&00
 LDX #&07

.l_28c1

 BCC l_28c5
 ADC &06

.l_28c5

 ROR A
 ROR &1B
 DEX
 BNE l_28c1
 LSR A
 ROR &1B
 ORA &D1
 RTS

.l_28d1

 STA &1B
 RTS

.l_28d4

 JSR l_28a6
 STA &83
 LDA &1B
 STA &82
 RTS

.l_28de

 LDY #&0A

.l_28e0

 LDX &46,Y
 STX &81
 LDA &34
 JSR l_28d4
 LDX &48,Y
 STX &81
 LDA &35
 JSR MAD
 STA &83
 STX &82
 LDX &4A,Y
 STX &81
 LDA &36

.MAD

 JSR l_28a6

.ADD

 STA &06
 AND #&80
 STA &D1
 EOR &83
 BMI l_2916
 LDA &82
 CLC
 ADC &1B
 TAX
 LDA &83
 ADC &06
 ORA &D1
 RTS

.l_2916

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
 BCS l_2938
 STA &80
 TXA
 EOR #&FF
 ADC #&01
 TAX
 LDA #&00
 SBC &80
 ORA #&80

.l_2938

 EOR &D1
 RTS

.l_293b

 STX &81
 EOR #&80
 JSR MAD
 TAX
 AND #&80
 STA &D1
 TXA
 AND #&7F
 LDX #&FE
 STX &06

.l_294e

 ASL A
 CMP #&60
 BCC l_2955
 SBC #&60

.l_2955

 ROL &06
 BCS l_294e
 LDA &06
 ORA &D1
 RTS

.DV42

 LDA &0FA8,Y

.l_2961

 STA &81
 LDA &7D

.l_2965

 LDX #&08
 ASL A
 STA &1B
 LDA #&00

.l_296c

 ROL A
 BCS l_2973
 CMP &81
 BCC l_2976

.l_2973

 SBC &81
 SEC

.l_2976

 ROL &1B
 DEX
 BNE l_296c
 JMP l_47f3

.l_297e

 STA font+&01
 LDA &4C
 STA &81
 LDA &4D
 STA &82
 LDA &4E
 STA &83
 LDA &1B
 ORA #&01
 STA &1B
 LDA font+&01
 EOR &83
 AND #&80
 STA &D1
 LDY #&00
 LDA font+&01
 AND #&7F

.l_29a0

 CMP #&40
 BCS l_29ac
 ASL &1B
 ROL font
 ROL A
 INY
 BNE l_29a0

.l_29ac

 STA font+&01
 LDA &83
 AND #&7F
 BMI l_29bc

.l_29b4

 DEY
 ASL &81
 ROL &82
 ROL A
 BPL l_29b4

.l_29bc

 STA &81
 LDA #&FE
 STA &82
 LDA font+&01
 JSR l_47f7
 LDA #&00
 JSR n_store	\ swapped
 TYA
 BPL l_29f0
 LDA &82

.l_29d4

 ASL A
 ROL &41
 ROL &42
 ROL &43
 INY
 BNE l_29d4
 STA &40
 LDA &43
 ORA &D1
 STA &43
 RTS

.l_29e7

 LDA &82
 STA &40
 LDA &D1
 STA &43
 RTS

.l_29f0

 BEQ l_29e7
 LDA &82

.l_29f4

 LSR A
 DEY
 BNE l_29f4
 STA &40
 LDA &D1
 STA &43
 RTS

.l_29ff

 LDA &033F
 BNE l_2a09
 LDA cap_flag
 BNE l_2a15

.l_2a09

 TXA
 BPL l_2a0f
 DEX
 BMI l_2a15

.l_2a0f

 INX
 BNE l_2a15
 DEX
 BEQ l_2a0f

.l_2a15

 RTS

.l_2a16

 STA &D1
 TXA
 CLC
 ADC &D1
 TAX
 BCC l_2a21
 LDX #&FF

.l_2a21

 BPL l_2a33

.l_2a23

 LDA &D1
 RTS

.l_2a26

 STA &D1
 TXA
 SEC
 SBC &D1
 TAX
 BCS l_2a31
 LDX #&01

.l_2a31

 BPL l_2a23

.l_2a33

 LDA a_flag
 BNE l_2a23
 LDX #&80
 BMI l_2a23

.l_2a3c

 LDA &1B
 EOR &81
 STA &06
 LDA &81
 BEQ l_2a6b
 ASL A
 STA &81
 LDA &1B
 ASL A
 CMP &81
 BCS l_2a59
 JSR l_2a75
 SEC

.l_2a54

 LDX &06
 BMI l_2a6e
 RTS

.l_2a59

 LDX &81
 STA &81
 STX &1B
 TXA
 JSR l_2a75
 STA &D1
 LDA #&40
 SBC &D1
 BCS l_2a54

.l_2a6b

 LDA #&3F
 RTS

.l_2a6e

 STA &D1
 LDA #&80
 SBC &D1
 RTS

.l_2a75

 JSR l_47ef
 LDA &82
 LSR A
 LSR A
 LSR A
 TAX
 LDA &07E0,X

.l_2a81

 RTS

.l_2a82

 JSR DORND
 AND #&07
 ADC #&5C
 STA &0FCF
 JSR DORND
 AND #&07
 ADC #&7C
 STA &0FCE
 LDA laser_t
 ADC #&08
 STA laser_t
 JSR l_3629

.l_2aa1

 LDA &87
 BNE l_2a81
 LDA #&20
 LDY #&E0
 JSR l_2ab0
 LDA #&30
 LDY #&D0

.l_2ab0

 STA &36
 LDA &0FCE
 STA &34
 LDA &0FCF
 STA &35
 LDA #&BF
 STA &37
 JSR LOIN
 LDA &0FCE
 STA &34
 LDA &0FCF
 STA &35
 STY &36
 LDA #&BF
 STA &37
 JMP LOIN

.l_2aec

 CPX #&10
 BEQ n_aliens
 CPX #&0D
 BCS l_2b04

.n_aliens

 LDY #&0C
 SEC
 LDA cmdr_cargo+&10

.l_2af9

 ADC cmdr_cargo,Y
 BCS n_cargo
 DEY
 BPL l_2af9
 CMP new_hold

.n_cargo

 RTS

.l_2b04

 LDA cmdr_cargo,X
 ADC #&00
 RTS

.l_2b0e

 JSR l_2b11

.l_2b11

 JSR l_2b14

.l_2b14

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

.l_2b3b

 LDA hype_dist
 ORA hype_dist+&01
 BNE l_2b46
 INC YC
 RTS

.l_2b46

 LDA #&BF
 JSR l_3395
 LDX hype_dist
 LDY hype_dist+&01
 SEC
 JSR l_30b4
 LDA #&C3

.l_2b57

 JSR TT27

.l_2b5a

 INC YC

.l_2b5c

 JSR vdu_80

.TT67

 LDA #&0C
 JMP TT27

.l_2b65

 LDA #&AD
 JSR TT27
 JMP l_2ba9

.spc

 JSR TT27
 JMP TT162

.l_2b73

 LDA #&01
 JSR TT66
 LDA #&09
 STA XC
 LDA #&A3
 JSR TT27
 JSR NLIN
 JSR l_2b5a
 INC YC
 JSR l_2b3b
 LDA #&C2
 JSR l_3395
 LDA data_econ
 CLC
 ADC #&01
 LSR A
 CMP #&02
 BEQ l_2b65
 LDA data_econ
 BCC l_2ba4
 SBC #&05
 CLC

.l_2ba4

 ADC #&AA
 JSR TT27

.l_2ba9

 LDA data_econ
 LSR A
 LSR A
 CLC
 ADC #&A8
 JSR l_2b57
 LDA #&A2
 JSR l_3395
 LDA data_govm
 CLC
 ADC #&B1
 JSR l_2b57
 LDA #&C4
 JSR l_3395
 LDX data_tech
 INX
 JSR c_1e38
 JSR l_2b5a
 LDA #&C0
 JSR l_3395
 SEC
 LDX data_popn
 JSR l_1e38
 LDA #&C6
 JSR l_2b57
 LDA #&28
 JSR TT27
 LDA &70
 BMI l_2bf4
 LDA #&BC
 JSR TT27
 JMP l_2c30

.l_2bf4

 LDA &71
 LSR A
 LSR A
 PHA
 AND #&07
 CMP #&03
 BCS l_2c04
 ADC #&E3
 JSR spc

.l_2c04

 PLA
 LSR A
 LSR A
 LSR A
 CMP #&06
 BCS l_2c11
 ADC #&E6
 JSR spc

.l_2c11

 LDA &6F
 EOR &6D
 AND #&07
 STA &73
 CMP #&06
 BCS l_2c22
 ADC #&EC
 JSR spc

.l_2c22

 LDA &71
 AND #&03
 CLC
 ADC &73
 AND #&07
 ADC #&F2
 JSR TT27

.l_2c30

 LDA #&53
 JSR TT27
 LDA #&29
 JSR l_2b57
 LDA #&C1
 JSR l_3395
 LDX data_gnp
 LDY data_gnp+&01
 JSR l_30b3
 JSR TT162
 JSR vdu_00
 LDA #&4D
 JSR TT27
 LDA #&E2
 JSR l_2b57
 LDA #&FA
 JSR l_3395
 LDA &71
 LDX &6F
 AND #&0F
 CLC
 ADC #&0B
 TAY
 JSR l_30b4
 JSR TT162
 LDA #&6B
 JSR CHPR
 LDA #&6D
 JMP CHPR

.l_2c78

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
 BNE l_2c94
 LDA data_econ
 ORA #&02
 STA data_econ

.l_2c94

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
 JSR l_2820
 LDA data_popn
 STA &81
 JSR l_2820
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
 JSR l_2b0e
 LDX &84
 INX
 BNE l_2d09
 LDA data_homex
 STA &73
 LDA data_homey
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
 LDA cmdr_fuel
 STA &40
 JMP l_2dc5

.l_2da1

 LDA &87
 BMI l_2d8a
 LDA cmdr_fuel
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
 JMP l_3b90

.l_2dde

 LDY #&00

.l_2de0

 STY &03AD
 LDX cmdr_cargo,Y
 BEQ l_2e0c
 TYA
 ASL A
 ASL A
 TAY
 LDA l_4619+&01,Y
 STA &74
 TXA
 PHA
 JSR l_2b5c
 CLC
 LDA &03AD
 ADC #&D0
 JSR TT27
 LDA #&0E
 STA XC
 PLA
 TAX
 JSR c_1e38
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
 JSR l_2b57
 JSR NLIN4
 JSR l_3366
 LDA #&0E
 JSR l_3395
 LDX new_hold
 DEX
 JSR c_1e38
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
 LDA data_homey
 JSR l_2e7b
 LDA &77
 STA data_homey
 STA &74
 PLA
 STA &76
 LDA data_homex
 JSR l_2e7b
 LDA &77
 STA data_homex
 STA &73

.l_2e65

 LDA &87
 BMI l_2e8c
 LDA data_homex
 STA &73
 LDA data_homey
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

 LDA data_homex
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
 LDA data_homey
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

 JSR l_2b0e
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
 SBC data_homex
 BCS l_2f8c
 EOR #&FF
 ADC #&01

.l_2f8c

 LSR A
 STA &83
 LDA &6D
 SEC
 SBC data_homey
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

 JSR l_2b0e
 INC &80
 BNE l_2f80
 LDX #&05

.l_2fb7

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_2fb7
 LDA &6D
 STA data_homey
 LDA &6F
 STA data_homex
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
 LDA data_homey
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
 STX hype_dist+&01
 ROL hype_dist+&01
 ASL A
 ROL hype_dist+&01
 STA hype_dist
 JMP l_2c78

.l_3011

 LDA &2F
 ORA &8E
 BNE l_3084+&01
 JSR l_4437
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

 LDA hype_dist
 ORA hype_dist+&01
 BEQ l_3084+&01
 LDA #&07
 STA XC
 LDA #&17
 STA YC
 JSR vdu_00
 LDA #&BD
 JSR TT27
 LDA hype_dist+&01
 BNE l_30b9
 LDA cmdr_fuel
 CMP hype_dist
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
 STA data_homex
 STA data_homey
 JSR l_3292
 JSR TT111
 LDX #&00
 STX hype_dist
 STX hype_dist+&01
 LDA #&74
 JSR l_45c6

.l_309f

 LDA data_homex
 STA QQ0
 LDA data_homey
 STA QQ1
 RTS

.ee3

 LDY #&01
 STY XC
 STY YC
 DEY

.l_30b3

 CLC

.l_30b4

 LDA #&05
 JMP l_1e3c

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
 JSR l_30b4
 LDY &77
 LDA #&05
 LDX cmdr_avail,Y
 STX &03AB
 CLC
 BEQ l_312b
 JSR l_1e3a
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
 JSR CHPR
 BCC TT162

.l_314e

 LDA #&6B
 JSR CHPR

.l_3153

 LDA #&67
 JMP CHPR

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

 JSR l_309f
 LDX #&05

.l_31b0

 LDA &6C,X
 STA &03B2,X
 DEX
 BPL l_31b0
 INX
 STX &0349
 LDA data_econ
 STA home_econ
 LDA data_tech
 STA home_tech
 LDA data_govm
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
 JSR l_3ee1
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

 LDA cmdr_fuel
 SEC
 SBC hype_dist
 STA cmdr_fuel

.hyper_snap

 LDA &87
 BNE l_3268
 JSR TT66
 JSR l_2623

.l_3268

 \	JSR l_4437
 \	AND x_flag
 \	BMI l_321f
 JSR DORND
 CMP #&FD
 BCS l_3226
 JSR l_31ab
 JSR l_3ee1
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
 JSR l_3ee1
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
 JSR l_2642

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
 JSR CHPR
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
 JMP c_1e38

.l_3366

 LDA #&69
 JSR l_3395
 LDX cmdr_fuel
 SEC
 JSR l_1e38
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
 JSR l_1e48
 LDA #&E2

.plf

 JSR TT27
 JMP TT67

.l_3395

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

 JMP CHPR

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

 JMP CHPR

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

 LDA hype_dist
 LDY #3

.legal_div

 LSR hype_dist+1
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

.l_3d68

 LDX #&01

.l_3d6a

 LDA QQ0,X
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

 JSR WPSHPS
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
 JSR ee3
 LDA #&05
 STA &2E
 LDX &2F
 JSR ee3
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
 STA QQ17
 JSR l_330a
 JSR vdu_80
 LDA #&01
 STA XC
 INC YC
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
 JSR l_4439
 BPL b_quit

.b_pressed

 LDA #&FF
 STA KL,Y

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
 \	LDA cmdr_cargo,X
 LDA CRGO,X
 BEQ l_45b4
 LDA &034A
 BNE l_45b4
 LDY #&03
 STY &034B
 \	STA cmdr_cargo,X
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
 JSR l_47ef
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

.WSCAN

 LDA #&00
 STA &8B

.l_55fb

 LDA &8B
 BEQ l_55fb
 RTS 

SAVE "output/1.F.bin", CODE%, P%, LOAD%