\ ******************************************************************************
\
\ ELITE-A DOCKED SOURCE
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
\   * output/1.D.bin
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

\ ******************************************************************************
\
\       Name: S%
\       Type: Workspace
\    Address: &11E3 to &11F0
\   Category: Workspaces
\    Summary: Entry points and vector addresses in the main docked code
\
\ ******************************************************************************

.S%

 JMP DOENTRY            \ Decrypt the main docked code and dock at the station

 JMP DOBEGIN            \ Decrypt the main docked code and start a new game

 JMP CHPR               \ WRCHV is set to point here by elite-loader3.asm

 EQUW IRQ1              \ IRQ1V is set to point here by elite-loader3.asm

 JMP BRBR               \ AJD

BRKV = P% - 2           \ The address of the destination address in the above
                        \ JMP BRBR1 instruction. This ensures that any code that
                        \ updates BRKV will update this instruction instead of
                        \ the actual vector

.INBAY

 JSR BRKBK
 JMP icode_set
 EQUB 0
 \ dead entry
 LDA #0
 JSR scramble
 JSR RES2
 JMP stack_init

\ ******************************************************************************
\
\       Name: DOBEGIN
\       Type: Subroutine
\   Category: Loader
\    Summary: Decrypt the main docked code, initialise the configuration
\             variables and start the game
\
\ ******************************************************************************

.DOBEGIN

 LDA #0                 \ AJD

 JSR scramble           \ Decrypt the main docked code between &1300 and &5FFF

 JMP BEGIN              \ Jump to BEGIN to initialise the configuration
                        \ variables and start the game

\ ******************************************************************************
\
\       Name: DOENTRY
\       Type: Subroutine
\   Category: Flight
\    Summary: Dock at the space station, show the ship hanger and work out any
\             mission progression
\
\ ******************************************************************************

.DOENTRY

 LDA KL+1               \ AJD
 BNE INBAY
 LDA #&FF

 JSR scramble           \ Decrypt the newly loaded code

 JSR RES2               \ Reset a number of flight variables and workspaces

 JSR HFS1               \ Show the space station docking tunnel

 JSR HALL               \ Show the ship hanger

 LDY #44                \ Wait for 44/50 of a second (0.88 seconds)
 JSR DELAY

 JSR cour_dock          \ AJD

 LDA TP                 \ Fetch bits 0 and 1 of TP, and if they are non-zero
 AND #%00000011         \ (i.e. mission 1 is either in progress or has been
 BNE EN1                \ completed), skip to EN1

 LDA TALLY+1            \ If the high byte of TALLY is zero (so we have a combat
 BEQ EN4                \ rank below Competent), jump to EN4 as we are not yet
                        \ good enough to qualify for a mission

 LDA GCNT               \ Fetch the galaxy number into A, and if any of bits 1-7
 LSR A                  \ are set (i.e. A > 1), jump to EN4 as mission 1 can
 BNE EN4                \ only be triggered in the first two galaxies

 JMP BRIEF              \ If we get here, mission 1 hasn't started, we have
                        \ reached a combat rank of Competent, and we are in
                        \ galaxy 0 or 1 (shown in-game as galaxy 1 or 2), so
                        \ it's time to start mission 1 by calling BRIEF

.EN1

                        \ If we get here then mission 1 is either in progress or
                        \ has been completed

 CMP #%00000011         \ If bits 0 and 1 are not both set, then jump to EN2
 BNE EN2

 JMP DEBRIEF            \ Bits 0 and 1 are both set, so mission 1 is both in
                        \ progress and has been completed, which means we have
                        \ only just completed it, so jump to DEBRIEF to end the
                        \ mission get our reward

.EN2

                        \ Mission 1 has been completed, so now to check for
                        \ mission 2

 LDA TP                 \ Extract bits 0-3 of TP into A
 AND #%00001111

 CMP #%00000010         \ If mission 1 is complete and no longer in progress,
 BNE EN3                \ and mission 2 is not yet started, then bits 0-3 of TP
                        \ will be %0010, so this jumps to EN3 if this is not the
                        \ case

 LDA TALLY+1            \ If the high byte of TALLY is < 5 (so we have a combat
 CMP #5                 \ rank that is less than 3/8 of the way from Dangerous
 BCC EN4                \ to Deadly), jump to EN4 as our rank isn't high enough
                        \ for mission 2

 LDA GCNT               \ Fetch the galaxy number into A

 CMP #2                 \ If this is not galaxy 2 (shown in-game as galaxy 3),
 BNE EN4                \ jump to EN4 as we can only start mission 2 in the
                        \ third galaxy

 JMP BRIEF2             \ If we get here, mission 1 is complete and no longer in
                        \ progress, mission 2 hasn't started, we have reached a
                        \ combat rank of 3/8 of the way from Dangerous to
                        \ Deadly, and we are in galaxy 2 (shown in-game as
                        \ galaxy 3), so it's time to start mission 2 by calling
                        \ BRIEF2

.EN3

 CMP #%00000110         \ If mission 1 is complete and no longer in progress,
 BNE EN5                \ and mission 2 has started but we have not yet been
                        \ briefed and picked up the plans, then bits 0-3 of TP
                        \ will be %0110, so this jumps to EN5 if this is not the
                        \ case

 LDA GCNT               \ Fetch the galaxy number into A

 CMP #2                 \ If this is not galaxy 2 (shown in-game as galaxy 3),
 BNE EN4                \ jump to EN4 as we can only start mission 2 in the
                        \ third galaxy

 LDA QQ0                \ Set A = the current system's galactic x-coordinate

 CMP #215               \ If A <> 215 then jump to EN4
 BNE EN4

 LDA QQ1                \ Set A = the current system's galactic y-coordinate

 CMP #84                \ If A <> 84 then jump to EN4
 BNE EN4

 JMP BRIEF3             \ If we get here, mission 1 is complete and no longer in
                        \ progress, mission 2 has started but we have not yet
                        \ picked up the plans, and we have just arrived at
                        \ Ceerdi at galactic coordinates (215, 84), so we jump
                        \ to BRIEF3 to get a mission brief and pick up the plans
                        \ that we need to carry to Birera

.EN5

 CMP #%00001010         \ If mission 1 is complete and no longer in progress,
 BNE EN4                \ and mission 2 has started and we have picked up the
                        \ plans, then bits 0-3 of TP will be %1010, so this
                        \ jumps to EN5 if this is not the case

 LDA GCNT               \ Fetch the galaxy number into A

 CMP #2                 \ If this is not galaxy 2 (shown in-game as galaxy 3),
 BNE EN4                \ jump to EN4 as we can only start mission 2 in the
                        \ third galaxy

 LDA QQ0                \ Set A = the current system's galactic x-coordinate

 CMP #63                \ If A <> 63 then jump to EN4
 BNE EN4

 LDA QQ1                \ Set A = the current system's galactic y-coordinate

 CMP #72
 BNE EN4                \ If A <> 72 then jump to EN4

 JMP DEBRIEF2           \ If we get here, mission 1 is complete and no longer in
                        \ progress, mission 2 has started and we have picked up
                        \ the plans, and we have just arrived at Birera at
                        \ galactic coordinates (63, 72), so we jump to DEBRIEF2
                        \ to end the mission and get our reward

.icode_set

 JSR RES2               \ AJD

.EN4

 JMP BAY                \ If we get here them we didn't start or any missions,
                        \ so jump to BAY to go to the docking bay (i.e. show the
                        \ Status Mode screen)

.scramble

 STA save_lock

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
\ ******************************************************************************

.MT8

 LDA #6                 \ Move the text cursor to column 6
 STA XC

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

\ ******************************************************************************
\
\       Name: MT6
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
\ Other entry points:
\
\   set_token           AJD
\
\ ******************************************************************************

.MT6

 LDA #%10000000         \ Set bit 7 of QQ17 to switch standard tokens to
 STA QQ17               \ Sentence Case

.set_token

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
 EQUW TT27              \ Token  4: Print the commander's name
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
 EQUW PAUSE2            \ Token 24: Wait for a key press
 EQUW BRIS              \ Token 25: Show incoming message screen, wait 2 seconds
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
\SAVE "output/T.ELTA.bin", CODE%, P%, LOAD%

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
\       Name: PRXS
\       Type: Variable
\   Category: Equipment
\    Summary: Equipment prices
\
\ ------------------------------------------------------------------------------
\
\ Equipment prices are stored as 10 * the actual value, so we can support prices
\ with fractions of credits (0.1 Cr). This is used for the price of fuel only.
\
\ ******************************************************************************

.PRXS

 EQUW &0001
 \ 00 Cobra 3, Boa
 EQUW   250,  4000,  6000,  4000, 10000,  5250, 3000
 EQUW  5500, 15000, 15000, 50000, 30000,  2500
 \ 1A Adder, Cobra 1, Python
 EQUW   250,  2000,  4000,  2000,  4500,  3750, 2000
 EQUW  3750,  9000,  8000, 30000, 23000,  2500
 \ 34 Fer-de-Lance, Asp 2
 EQUW   250,  4000,  5000,  5000, 10000,  7000, 6000
 EQUW  4000, 25000, 10000, 40000, 50000,  2500
 \ 4E Monitor, Anaconda
 EQUW   250,  3000,  8000,  6000,  8000,  6500, 4500
 EQUW  8000, 19000, 20000, 60000, 25000,  2500
 \ 68 Moray, Ophidian
 EQUW   250,  1500,  3000,  3500,  7000,  4500, 2500
 EQUW  4500,  7000,  7000, 30000, 19000,  2500

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

 LDA #205               \ Print extended token 205 ("DOCKED")
 JSR DETOK

 JSR TT67               \ Print a newline

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
 BEQ l_1b57	\ IFF if flag not set
 LDA #&6B
 LDX #&06
 JSR plf2

.l_1b57

 LDA BST                \ AJD
 BEQ l_1b61
 LDA #&6F
 LDX #&19
 JSR plf2

.l_1b61

 LDA ECM
 BEQ l_1b6b
 LDA #&6C
 LDX #&18
 JSR plf2

.l_1b6b

 \	LDA #&71
 \	STA &96
 LDX #&1A

.stqv

 STX &93
 \	TAY
 \	LDX FRIN,Y
 LDY LASER,X
 BEQ l_1b78
 TXA
 CLC
 ADC #&57
 JSR plf2

.l_1b78

 \	INC &96
 \	LDA &96
 \	CMP #&75
 LDX &93
 INX
 CPX #&1E
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

 STX &93
 STA &96
 JSR TT27
 LDX &87
 CPX #&08
 BEQ status_keep
 LDA #&15
 STA XC
 JSR vdu_80
 LDA #&01
 STA &03AB
 JSR sell_yn
 BEQ status_no
 BCS status_no
 LDA &96
 CMP #&6B
 BCS status_over
 ADC #&07

.status_over

 SBC #&68
 JSR equip_price
 LSR A
 TAY
 TXA
 ROR A
 TAX
 JSR MCASH
 INC new_hold	\**
 LDX &93
 LDA #&00
 STA LASER,X

.status_no

 LDX #&01

.status_keep

 STX XC
 LDA #&0A
 JMP TT27

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

 LDA #&10               \ AJD

 JSR DIL2               \ Draw a vertical bar on the roll indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ pitch indicator)

 LDA #&10               \ AJD

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
 AND #3                 \ jumping to R5-1 if it is non-zero. R5-1 contains an
 BNE R5-1               \ RTS, so the following code only runs every 4
                        \ iterations of the main loop, otherwise we return from
                        \ the subroutine

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

 LDA #&3F               \ AJD

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

 LDA #255               \ Draw the forward shield indicator as fully charged,
 JSR DILX               \ and increment SC to point to the next indicator (the
                        \ aft shield)

 LDA #255               \ Draw the aft shield indicator as fully charged, and
 JSR DILX               \ increment SC to point to the next indicator (the fuel
                        \ level)

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

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255,
 JMP DILX               \ returning from the subroutine using a tail call

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

 EQUB &2C               \ AJD

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
\SAVE "elite-a/T.ELTB.bin", CODE_B%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE C FILE
\
\ ******************************************************************************

CODE_C% = P%
LOAD_C% = LOAD% +P% - CODE%

\ ******************************************************************************
\
\       Name: HATB
\       Type: Variable
\   Category: Ship hanger
\    Summary: Ship hanger group table
\
\ ------------------------------------------------------------------------------
\
\ This table contains groups of ships to show in the ship hanger. A group of
\ ships is shown half the time (the other half shows a solo ship), and each of
\ the four groups is equally likely.
\
\ The bytes for each ship in the group contain the following information:
\
\   Byte #0             Non-zero = Ship type to draw
\                       0        = don't draw anything
\
\   Byte #1             Bits 0-7 = Ship's x_hi
\                       Bit 0    = Ship's z_hi (1 if clear, or 2 if set)
\
\   Byte #2             Bits 0-7 = Ship's z_lo
\                       Bit 0    = Ship's x_sign
\
\ Ths ship's y-coordinate is calculated in the has1 routine from the size of
\ its targetable area. Ships of type 0 are not shown.
\
\ Note that ship numbers are for the ship hanger blueprints at XX21 in the
\ docked code, rather than the full set of ships in the flight code. They are:
\
\   1 = Cargo canister
\   2 = Shuttle
\   3 = Transporter
\   4 = Cobra Mk III
\   5 = Python
\   6 = Viper
\   7 = Krait
\   8 = Constrictor
\
\ ******************************************************************************

.HATB

                        \ Hanger group for X = 0
                        \
                        \ Shuttle (left) and Transporter (right)

 EQUB 2                 \ Ship type in the hanger = 2 = Shuttle
 EQUB %01010100         \ x_hi = %01010100 = 84, z_hi   = 1     -> x = -84
 EQUB %00111011         \ z_lo = %00111011 = 59, x_sign = 1        z = +315

 EQUB 3                 \ Ship type in the hanger = 3 = Transporter
 EQUB %10000010         \ x_hi = %10000010 = 130, z_hi   = 1    -> x = +130
 EQUB %10110000         \ z_lo = %10110000 = 176, x_sign = 0       z = +432

 EQUB 0                 \ No third ship
 EQUB 0
 EQUB 0

                        \ Hanger group for X = 9
                        \
                        \ Three cargo canisters (left, far right and forward,
                        \ right)

 EQUB 1                 \ Ship type in the hanger = 1 = Cargo canister
 EQUB %01010000         \ x_hi = %01010000 = 80, z_hi   = 1     -> x = -80
 EQUB %00010001         \ z_lo = %00010001 = 17, x_sign = 1        z = +273

 EQUB 1                 \ Ship type in the hanger = 1 = Cargo canister
 EQUB %11010001         \ x_hi = %11010001 = 209, z_hi = 2      -> x = +209
 EQUB %00101000         \ z_lo = %00101000 =  40, x_sign = 0       z = +552

 EQUB 1                 \ Ship type in the hanger = 1 = Cargo canister
 EQUB %01000000         \ x_hi = %01000000 = 64, z_hi   = 1     -> x = +64
 EQUB %00000110         \ z_lo = %00000110 = 6,  x_sign = 0        z = +262

                        \ Hanger group for X = 18
                        \
                        \ Transporter (right) and Cobra Mk III (left)

 EQUB 3                 \ Ship type in the hanger = 3 = Transporter
 EQUB %01100000         \ x_hi = %01100000 =  96, z_hi   = 1    -> x = +96
 EQUB %10010000         \ z_lo = %10010000 = 144, x_sign = 0       z = +400

 EQUB 4                 \ Ship type in the hanger = 4 = Cobra Mk III
 EQUB %00010000         \ x_hi = %00010000 =  16, z_hi   = 1    -> x = -16
 EQUB %11010001         \ z_lo = %11010001 = 209, x_sign = 1       z = +465

 EQUB 0                 \ No third ship
 EQUB 0
 EQUB 0

                        \ Hanger group for X = 27
                        \
                        \ Viper (right and forward) and Krait (left)

 EQUB 6                 \ Ship type in the hanger = 6 = Viper
 EQUB %01010001         \ x_hi = %01010001 =  81, z_hi  = 2     -> x = +81
 EQUB %11111000         \ z_lo = %11111000 = 248, x_sign = 0       z = +760

 EQUB 7                 \ Ship type in the hanger = 7 = Krait
 EQUB %01100000         \ x_hi = %01100000 = 96,  z_hi   = 1    -> x = -96
 EQUB %01110101         \ z_lo = %01110101 = 117, x_sign = 1       z = +373

 EQUB 0                 \ No third ship
 EQUB 0
 EQUB 0

\ ******************************************************************************
\
\       Name: HALL
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Draw the ships in the ship hanger, then draw the hanger
\
\ ------------------------------------------------------------------------------
\
\ Half the time this will draw one of the four pre-defined ship hanger groups in
\ HATB, and half the time this will draw a solitary Sidewinder, Mamba, Krait or
\ Adder on a random position. In all cases, the ships will be randomly spun
\ around on the ground so they can face in any dirction, and larger ships are
\ drawn higher up off the ground than smaller ships.
\
\ The ships are drawn by the HAS1 routine, which uses the normal ship-drawing
\ routine in LL9, and then the hanger background is drawn by sending an OSWORD
\ 248 command to the I/O processor.
\
\ ******************************************************************************

.HALL

 JSR UNWISE             \ Call UNWISE to switch the main line-drawing routine
                        \ between EOR and OR logic (in this case, switching it
                        \ to OR logic so that it overwrites anything that's
                        \ on-screen)

 LDA #0                 \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 0 (space
                        \ view)

 JSR DORND              \ Set A and X to random numbers

 BPL HA7                \ Jump to HA7 if A is positive (50% chance)

 AND #3                 \ Reduce A to a random number in the range 0-3

 STA T                  \ Set X = A * 8 + A
 ASL A                  \       = 9 * A
 ASL A                  \
 ASL A                  \ so X is a random number, either 0, 9, 18 or 27
 ADC T
 TAX

                        \ The following double loop calls the HAS1 routine three
                        \ times to display three ships on screen. For each call,
                        \ the values passed to HAS1 in XX15+2 to XX15 are taken
                        \ from the HATB table, depending on the value in X, as
                        \ follows:
                        \
                        \   * If X = 0,  pass bytes #0 to #2 of HATB to HAS1
                        \                then bytes #3 to #5
                        \                then bytes #6 to #8
                        \
                        \   * If X = 9,  pass bytes  #9 to #11 of HATB to HAS1
                        \                then bytes #12 to #14
                        \                then bytes #15 to #17
                        \
                        \   * If X = 18, pass bytes #18 to #20 of HATB to HAS1
                        \                then bytes #21 to #23
                        \                then bytes #24 to #26
                        \
                        \   * If X = 27, pass bytes #27 to #29 of HATB to HAS1
                        \                then bytes #30 to #32
                        \                then bytes #33 to #35
                        \
                        \ Note that the values are passed in reverse, so for the
                        \ first call, for example, where we pass bytes #0 to #2
                        \ of HATB to HAS1, we call HAS1 with:
                        \
                        \   XX15   = HATB+2
                        \   XX15+1 = HATB+1
                        \   XX15+2 = HATB

 LDY #3                 \ Set CNT2 = 3 to act as an outer loop counter going
 STY CNT2               \ from 3 to 1, so the HAL8 loop is run 3 times

.HAL8

 LDY #2                 \ Set Y = 2 to act as an inner loop counter going from
                        \ 2 to 0

.HAL9

 LDA HATB,X             \ Copy the X-th byte of HATB to the Y-th byte of XX15,
 STA XX15,Y             \ as described above

 INX                    \ Increment X to point to the next byte in HATB

 DEY                    \ Decrement Y to point to the previous byte in XX15

 BPL HAL9               \ Loop back to copy the next byte until we have copied
                        \ three of them (i.e. Y was 3 before the DEY)

 TXA                    \ Store X on the stack so we can retrieve it after the
 PHA                    \ call to HAS1 (as it contains the index of the next
                        \ byte in HATB

 JSR HAS1               \ Call HAS1 to draw this ship in the hanger

 PLA                    \ Restore the value of X, so X points to the next byte
 TAX                    \ in HATB after the three bytes we copied into XX15

 DEC CNT2               \ Decrement the outer loop counter in CNT2

 BNE HAL8               \ Loop back to HAL8 to do it 3 times, once for each ship
                        \ in the HATB table

 LDY #128               \ Set Y = 128 to send as byte #2 of the parameter block
                        \ to the OSWORD 248 command below, to tell the I/O
                        \ processor that there are multiple ships in the hanger

 BNE HA9                \ Jump to HA9 to display the ship hanger (this BNE is
                        \ effectively a JMP as Y is never zero)

.HA7

                        \ If we get here, A is a positive random number in the
                        \ range 0-127

 LSR A                  \ Set XX15+1 = A / 2 (random number 0-63)
 STA XX15+1

 JSR DORND              \ Set XX15 = random number 0-255
 STA XX15

 JSR DORND              \ Set XX15+2 = random number 0-7
 AND #7                 \
 STA XX15+2             \ which is either 0 (no ships in the hanger) or one of
                        \ the first 7 ship types in the ship hanger blueprints
                        \ table, i.e. a cargo canister, Shuttle, Transporter,
                        \ Cobra Mk III, Python, Viper or Krait

 JSR HAS1               \ Call HAS1 to draw this ship in the hanger, with the
                        \ the following properties:
                        \
                        \   * Random x-coordinate from -63 to +63
                        \
                        \   * Randomly chosen cargo canister, Shuttle,
                        \     Transporter, Cobra Mk III, Python, Viper or Krait
                        \
                        \   * Random z-coordinate from +256 to +639

 LDY #0                 \ Set Y = 0 to use in the following instruction, to tell
                        \ the hanger-drawing routine that there is just one ship
                        \ in the hanger, so it knows not to draw between the
                        \ ships

.HA9

 STY YSAV               \ Store Y in YSAV to specify whether there are multiple
                        \ ships in the hanger

 JSR UNWISE             \ Call UNWISE to switch the main line-drawing routine
                        \ between EOR and OR logic (in this case, switching it
                        \ back to EOR logic so that we can erase anything we
                        \ draw on-screen)

                        \ Fall through into HANGER to draw the hanger background

\ ******************************************************************************
\
\       Name: HANGER
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Display the ship hanger
\
\ ------------------------------------------------------------------------------
\
\ This routine is called after the ships in the hanger have been drawn, so all
\ it has to do is draw the hanger's background.
\
\ The hanger background is made up of two parts:
\
\   * The hanger floor consists of 11 screen-wide horizontal lines, which start
\     out quite spaced out near the bottom of the screen, and bunch ever closer
\     together as the eye moves up towards the horizon, where they merge to give
\     a sense of perspective
\
\   * The back wall of the hanger consists of 15 equally spaced vertical lines
\     that join the horizon to the top of the screen
\
\ The ships in the hangar have already been drawn by this point, so the lines
\ are drawn so they don't overlap anything that's already there, which makes
\ them look like they are behind and below the ships. This is achieved by
\ drawing the lines in from the screen edges until they bump into something
\ already on-screen. For the horizontal lines, when there are multiple ships in
\ the hanger, this also means drawing lines between the ships, as well as in
\ from each side.
\
\ ******************************************************************************

.HANGER

                        \ We start by drawing the floor

 LDX #2                 \ We start with a loop using a counter in T that goes
                        \ from 2 to 12, one for each of the 11 horizontal lines
                        \ in the floor, so set the initial value in X

.HAL1

 STX XSAV               \ Store the loop counter in XSAV

 LDA #130               \ Set A = 130

 LDX XSAV               \ Retrieve the loop counter from XSAV

 STX Q                  \ Set Q = T

 JSR DVID4              \ Calculate the following:
                        \
                        \   (P R) = 256 * A / Q
                        \         = 256 * 130 / T
                        \
                        \ so P = 130 / T, and as the counter T goes from 2 to
                        \ 12, P goes 65, 43, 32 ... 13, 11, 10, with the
                        \ difference between two consecutive numbers getting
                        \ smaller as P gets smaller
                        \
                        \ We can use this value as a y-coordinate to draw a set
                        \ of horizontal lines, spaced out near the bottom of the
                        \ screen (high value of P, high y-coordinate, lower down
                        \ the screen) and bunching up towards the horizon (low
                        \ value of P, low y-coordinate, higher up the screen)

 LDA P                  \ Set Y = #Y + P
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

 STA SCH                \ Store the screen page in the high byte of SC(1 0)

 LDA P                  \ Set the low byte of SC(1 0) to the y-coordinate mod 7,
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

 LDY YSAV               \ Fetch the value of YSAV, which gets set to 0 in the
                        \ HALL routine above if there is only one ship

 BEQ HA2                \ If YSAV is zero, jump to HA2 to skip the following
                        \ as there is only one ship in the hanger

                        \ If we get here then there are multiple ships in the
                        \ hanger, so we also need to draw the horizontal line in
                        \ the gap between the ships

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

.HA2

                        \ We have finished threading our horizontal line behind
                        \ the ships already on-screen, so now for the next line

 LDX XSAV               \ Fetch the loop counter from XSAV and increment it
 INX

 CPX #13                \ If the loop counter is less than 13 (i.e. T = 2 to 12)
 BCC HAL1               \ then loop back to HAL1 to draw the next line

                        \ The floor is done, so now we move on to the back wall

 LDA #16                \ We want to draw 15 vertical lines, one every 16 pixels
                        \ across the screen, with the first at x-coordinate 16,
                        \ so set this in A to act as the x-coordinate of each
                        \ line as we work our way through them from left to
                        \ right, incrementing by 16 for each new line

.HAL6

 LDX #&60               \ Set the high byte of SC(1 0) to &60, the high byte of
 STX SCH                \ the start of screen

 STA XSAV               \ Store this value in XSAV, so we can retrieve it later

 AND #%11111000         \ Each character block contains 8 pixel rows, so to get
                        \ the address of the first byte in the character block
                        \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-2

 STA SC                 \ Set the low byte of SC(1 0) to this value, so SC(1 0)
                        \ now points to the address where the line starts

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

 LDA XSAV               \ Fetch the x-coordinate of the line we just drew from
 CLC                    \ XSAV into A, and add 16 so that A contains the
 ADC #16                \ x-coordinate of the next line to draw

 BNE HAL6               \ Loop back to HAL6 until we have run through the loop
                        \ 60 times, by which point we are most definitely done

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HAS1
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Draw a ship in the ship hanger
\
\ ------------------------------------------------------------------------------
\
\ The ship's position within the hanger is determined by the arguments and the
\ size of the ship's targetable area, as follows:
\
\   * The x-coordinate is (x_sign x_hi 0) from the arguments, so the ship can be
\     left of centre or right of centre
\
\   * The y-coordinate is negative and is lower down the screen for smaller
\     ships, so smaller ships are drawn closer to the ground (because they are)
\
\   * The z-coordinate is positive, with both z_hi (which is 1 or 2) and z_lo
\     coming from the arguments
\
\ Arguments:
\
\   XX15                Bits 0-7 = Ship's z_lo
\                       Bit 0    = Ship's x_sign
\
\   XX15+1              Bits 0-7 = Ship's x_hi
\                       Bit 0    = Ship's z_hi (1 if clear, or 2 if set)
\
\   XX15+2              Non-zero = Ship type to draw
\                       0        = Don't draw anything
\
\ ******************************************************************************

.HAS1

 JSR ZINF               \ Call ZINF to reset the INWK ship workspace and reset
                        \ the orientation vectors, with nosev pointing out of
                        \ the screen, so this puts the ship flat on the
                        \ horizontal deck (the y = 0 plane) with its nose
                        \ pointing towards us

 LDA XX15               \ Set z_lo = XX15
 STA INWK+6

 LSR A                  \ Set the sign bit of x_sign to bit 0 of A
 ROR INWK+2

 LDA XX15+1             \ Set x_hi = XX15+1
 STA INWK

 LSR A                  \ Set z_hi = 1 + bit 0 of XX15+1
 LDA #1
 ADC #0
 STA INWK+7

 LDA #%10000000         \ Set bit 7 of y_sign, so y is negative
 STA INWK+5

 STA RAT2               \ Set RAT2 = %10000000, so the yaw calls in HAL5 below
                        \ are negative

 LDA #&B                \ Set the ship line heap pointer in INWK(35 34) to point
 STA INWK+34            \ to &0B00

 JSR DORND              \ We now perform a random number of small angle (3.6
 STA XSAV               \ degree) rotations to spin the ship on the deck while
                        \ keeping it flat on the deck (a bit like spinning a
                        \ bottle), so we set XSAV to a random number between 0
                        \ and 255 for the number of small yaw rotations to
                        \ perform, so the ship could be pointing in any
                        \ direction by the time we're done

.HAL5

 LDX #21                \ Rotate (sidev_x, nosev_x) by a small angle (yaw)
 LDY #9
 JSR MVS5

 LDX #23                \ Rotate (sidev_y, nosev_y) by a small angle (yaw)
 LDY #11
 JSR MVS5

 LDX #25                \ Rotate (sidev_z, nosev_z) by a small angle (yaw)
 LDY #13
 JSR MVS5

 DEC XSAV               \ Decrement the yaw counter in XSAV

 BNE HAL5               \ Loop back to yaw a little more until we have yawed
                        \ by the number of times in XSAV

 LDY XX15+2             \ Set Y = XX15+2, the ship type of the ship we need to
                        \ draw

 BEQ HA1                \ If Y = 0, return from the subroutine (as HA1 contains
                        \ an RTS)

                        \ We now work our way through the ship blueprints table
                        \ for the hanger, counting valid blueprints until we
                        \ have found the Y-th valid blueprint (we do this as the
                        \ hanger blueprint table at XX21 is not fully populated,
                        \ so the Y-th ship is not necessarily at position Y)

 LDX #4                 \ We can start looking from ship blueprint 3, because we
                        \ don't show ship 1 (missile) or ship 2 (space station)
                        \ in the hanger. Setting X to 4, which then gets
                        \ incremented to 6, will start us at XX21(5 4), which is
                        \ the address of ship blueprint 3 (escape pod)

.hloop

 INX                    \ Increment X by 2 to point to the next blueprint in the
 INX                    \ table

 LDA XX21-2,X           \ Set XX0(1 0) to the X-th address in the ship blueprint
 STA XX0                \ address lookup table at XX21, so XX0(1 0) now points
 LDA XX21-1,X           \ to the blueprint for the ship we need to draw
 STA XX0+1

 BEQ hloop              \ If the high byte of the blueprint address is 0, then
                        \ the blueprint for this ship is not available, so jump
                        \ back to hloop to try the next ship along in the table

 DEY                    \ We have found a valid blueprint, so decrement the ship
                        \ number that we are looking for in Y

 BNE hloop              \ If Y is not yet zero, we still haven't found the Y-th
                        \ valid blueprint, so loop back to hloop to try the next
                        \ ship along in the table

 LDY #1                 \ Set Q = ship byte #1
 LDA (XX0),Y
 STA Q

 INY                    \ Set R = ship byte #2
 LDA (XX0),Y            \
 STA R                  \ so (R Q) contains the ship's targetable area, which is
                        \ a square number

 JSR LL5                \ Set Q = SQRT(R Q)

 LDA #100               \ Set y_lo = (100 - Q) / 2
 SBC Q                  \
 LSR A                  \ so the bigger the ship's targetable area, the smaller
 STA INWK+3             \ the magnitude of the y-coordinate, so because we set
                        \ y_sign to be negative above, this means smaller ships
                        \ are drawn lower down, i.e. closer to the ground, while
                        \ larger ships are drawn higher up, as you would expect

 JSR TIDY               \ Call TIDY to tidy up the orientation vectors, to
                        \ prevent the ship from getting elongated and out of
                        \ shape due to the imprecise nature of trigonometry
                        \ in assembly language

 JMP LL9                \ Jump to LL9 to display the ship and return from the
                        \ subroutine using a tail call

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
 \	LDA LIL3+2
 \	EOR #&40
 STA LIL3+2
 \	LDA LIL5+2
 \	EOR #&40
 STA LIL5+2
 \	LDA LIL6+2
 \	EOR #&40
 STA LIL6+2

.HA1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HFS1
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw the launch or hyperspace tunnel
\
\ ------------------------------------------------------------------------------
\
\ The animation gets drawn like this. First, we draw a circle of radius 8 at the
\ centre, and then double the radius, draw another circle, double the radius
\ again and draw a circle, and we keep doing this until the radius is bigger
\ than 160 (which goes beyond the edge of the screen, which is 256 pixels wide,
\ equivalent to a radius of 128). We then repeat this whole process for an
\ initial circle of radius 9, then radius 10, all the way up to radius 15.
\
\ This has the effect of making the tunnel appear to be racing towards us as we
\ hurtle out into hyperspace or through the space station's docking tunnel.
\
\ The hyperspace effect is done in a full mode 5 screen, which makes the rings
\ all coloured and zig-zaggy, while the launch screen is in the normal
\ monochrome mode 4 screen.
\
\ ******************************************************************************

.HFS1

 LDX #X                 \ Set K3 = #X (the x-coordinate of the centre of the
 STX K3                 \ screen)

 LDX #Y                 \ Set K4 = #Y (the y-coordinate of the centre of the
 STX K4                 \ screen)

 LDX #0                 \ Set X = 0

 STX XX4                \ Set XX4 = 0, which we will use as a counter for
                        \ drawing 8 concentric rings

 STX K3+1               \ Set the high bytes of K3(1 0) and K4(1 0) to 0
 STX K4+1

.HFL5

 JSR HFL1               \ Call HFL1 below to draw a set of rings, with each one
                        \ twice the radius of the previous one, until they won't
                        \ fit on-screen

 INC XX4                \ Increment the counter and fetch it into X
 LDX XX4

 CPX #8                 \ If we haven't drawn 8 sets of rings yet, loop back to
 BNE HFL5               \ HFL5 to draw the next ring

 RTS                    \ Return from the subroutine

.HFL1

 LDA XX4                \ Set K to the ring number in XX4 (0-7) + 8, so K has
 AND #7                 \ a value of 8 to 15, which we will use as the starting
 CLC                    \ radius for our next set of rings
 ADC #8
 STA K

.HFL2

 LDA #1                 \ Set LSP = 1 to reset the ball line heap
 STA LSP

 JSR CIRCLE2            \ Call CIRCLE2 to draw a circle with the centre at
                        \ (K3(1 0), K4(1 0)) and radius K

 ASL K                  \ Double the radius in K

 BCS HF8                \ If the radius had a 1 in bit 7 before the above shift,
                        \ then doubling K will means the circle will no longer
                        \ fit on the screen (which is width 256), so jump to
                        \ HF8 to stop drawing circles

 LDA K                  \ If the radius in K <= 160, loop back to HFL2 to draw
 CMP #160               \ another one
 BCC HFL2

.HF8

 RTS                    \ Return from the subroutine

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
\ ******************************************************************************

.PDESC

 LDA QQ8                \ If either byte in QQ18(1 0) is non-zero, meaning that
 ORA QQ8+1              \ the distance from the current system to the selected
 BNE PD1                \ is non-zero, jump to PD1 to show the standard "goat
                        \ soup" description

                        \ If we get here, then the current system is the same as
                        \ the selected system and we are docked, so now to check
                        \ whether there is a special override token for this
                        \ system

 LDY #NRU%              \ Set Y as a loop counter as we work our way through the
                        \ system numbers in RUPLA, starting at NRU% (which is
                        \ the number of entries in RUPLA, 26) and working our
                        \ way down to 1

.PDL1

 LDA RUPLA-1,Y          \ Fetch the Y-th byte from RUPLA-1 into A (we use
                        \ RUPLA-1 because Y is looping from 26 to 1

 CMP ZZ                 \ If A doesn't match the system whose description we
 BNE PD2                \ are printing (in ZZ), junp to PD2 to keep looping
                        \ through the system numbers in RUPLA

                        \ If we get here we have found a match for this system
                        \ number in RUPLA

 LDA RUGAL-1,Y          \ Fetch the Y-th byte from RUGAL-1 into A

 AND #%01111111         \ Extract bits 0-6 of A

 CMP GCNT               \ If the result does not equal the current galaxy
 BNE PD2                \ number, jump to PD2 to keep looping through the system
                        \ numbers in RUPLA

 LDA RUGAL-1,Y          \ Fetch the Y-th byte from RUGAL-1 into A, once again

 BMI PD3                \ If bit 7 is set, jump to PD3 to print the extended
                        \ token in A from the second table in RUTOK

 LDA TP                 \ Fetch bit 0 of TP into the C flag, and skip to PD1 if
 LSR A                  \ it is clear (i.e. if mission 1 is not in progress) to
 BCC PD1                \ print the "goat soup" extended description

                        \ If we get here then mission 1 is in progress, so we
                        \ print out the corresponding token from RUTOK

 JSR MT14               \ Call MT14 to switch to justified text

 LDA #1                 \ Set A = 1 so that extended token 1 (an empty string)
                        \ gets printed below instead of token 176, followed by
                        \ the Y-th token in RUTOK

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &B0, or BIT &B0A9, which does nothing apart
                        \ from affect the flags

.PD3

 LDA #176               \ Print extended token 176 ("{lower case}{justify}
 JSR DETOK2             \ {single cap}")

 TYA                    \ Print the extended token in Y from the second table
 JSR DETOK3             \ in RUTOK

 LDA #177               \ Set A = 177 so when we jump to PD4 in the next
                        \ instruction, we print token 177 (".{cr}{left align}")

 BNE PD4                \ Jump to PD4 to print the extended token in A and
                        \ return from the subroutine using a tail call

.PD2

 DEY                    \ Decrement the byte counter in Y

 BNE PDL1               \ Loop back to check the next byte in RUPLA until we
                        \ either find a match for the system in ZZ, or we fall
                        \ through into the "goat soup" extended description
                        \ routine

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
\       Name: BRIEF2
\       Type: Subroutine
\   Category: Missions
\    Summary: Start mission 2
\
\ ******************************************************************************

.BRIEF2

 LDA TP                 \ Set bit 2 of TP to indicate mission 2 is in progress
 ORA #%00000100         \ but plans have not yet been picked up
 STA TP

 LDA #11                \ Set A = 11 so the call to BRP prints extended token 11
                        \ (the initial contact at the start of mission 2, asking
                        \ us to head for Ceerdi for a mission briefing)

                        \ Fall through into BRP to print the extended token in A
                        \ and show the Status Mode screen

\ ******************************************************************************
\
\       Name: BRP
\       Type: Subroutine
\   Category: Missions
\    Summary: Print an extended token and show the Status Mode screen
\
\ ******************************************************************************

.BRP

 JSR DETOK              \ Print the extended token in A

 JMP BAY                \ Jump to BAY to go to the docking bay (i.e. show the
                        \ Status Mode screen) and return from the subroutine
                        \ using a tail call

\ ******************************************************************************
\
\       Name: BRIEF3
\       Type: Subroutine
\   Category: Missions
\    Summary: Receive the briefing and plans for mission 2
\
\ ******************************************************************************

.BRIEF3

 LDA TP                 \ Set bits 1 and 3 of TP to indicate that mission 1 is
 AND #%11110000         \ complete, and mission 2 is in progress and the plans
 ORA #%00001010         \ have been picked up
 STA TP

 LDA #222               \ Set A = 222 so the call to BRP prints extended token
                        \ 222 (the briefing for mission 2 where we pick up the
                        \ plans we need to take to Birera)

 BNE BRP                \ Jump to BRP to print the extended token in A and show
                        \ the Status Mode screen), returning from the subroutine
                        \ using a tail call (this BNE is effectively a JMP as A
                        \ is never zero)

\ ******************************************************************************
\
\       Name: DEBRIEF2
\       Type: Subroutine
\   Category: Missions
\    Summary: Finish mission 2
\
\ ******************************************************************************

.DEBRIEF2

 LDA TP                 \ Set bit 2 of TP to indicate mission 2 is complete (so
 ORA #%00000100         \ both bits 2 and 3 are now set)
 STA TP

 LDA ENGY               \ AJD
 BNE rew_notgot
 DEC new_hold	        \** NOT TRAPPED FOR NO SPACE

.rew_notgot

 LDA #2                 \ Set ENGY to 2 so our energy banks recharge at twice
 STA ENGY               \ the speed, as our mission reward is a special navy
                        \ energy unit

 INC TALLY+1            \ Award 256 kill points for completing the mission

 LDA #223               \ Set A = 223 so the call to BRP prints extended token
                        \ 223 (the thank you message at the end of mission 2)

 BNE BRP                \ Jump to BRP to print the extended token in A and show
                        \ the Status Mode screen), returning from the subroutine
                        \ using a tail call (this BNE is effectively a JMP as A
                        \ is never zero)

\ ******************************************************************************
\
\       Name: DEBRIEF
\       Type: Subroutine
\   Category: Missions
\    Summary: Finish mission 1
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   BRPS                Print the extended token in A, show the Status Mode
\                       screen and return from the subroutine
\
\ ******************************************************************************

.DEBRIEF

 LSR TP                 \ Clear bit 0 of TP to indicate that mission 1 is no
 ASL TP                 \ longer in progress, as we have completed it

 INC TALLY+1            \ Award 256 kill points for completing the mission

 LDX #LO(50000)         \ Increase our cash reserves by the generous mission
 LDY #HI(50000)         \ reward of 5,000 CR
 JSR MCASH

 LDA #15                \ Set A = 15 so the call to BRP prints extended token 15
                        \ (the thank you message at the end of mission 1)

.BRPS

 BNE BRP                \ Jump to BRP to print the extended token in A and show
                        \ the Status Mode screen, returning from the subroutine
                        \ using a tail call (this BNE is effectively a JMP as A
                        \ is never zero)

\ ******************************************************************************
\
\       Name: BRIEF
\       Type: Subroutine
\   Category: Missions
\    Summary: Start mission 1 and show the mission briefing
\
\ ------------------------------------------------------------------------------
\
\ This routine does the following:
\
\   * Clear the screen
\   * Display "INCOMING MESSAGE" in the middle of the screen
\   * Wait for 2 seconds
\   * Clear the screen
\   * Show the Constrictor rolling and pitching in the middle of the screen
\   * Do this for 64 loop iterations
\   * Move the ship away from us and up until it's near the top of the screen
\   * Show the mission 1 briefing in extended token 10
\
\ The mission briefing ends with a "{display ship, wait for key press}" token,
\ which calls the PAUSE routine. This continues to display the rotating ship,
\ waiting until a key is pressed, and then removes the ship from the screen.
\
\ ******************************************************************************

.BRIEF

 LSR TP                 \ Set bit 0 of TP to indicate that mission 1 is now in
 SEC                    \ progress
 ROL TP

 JSR BRIS               \ Call BRIS to clear the screen, display "INCOMING
                        \ MESSAGE" and wait for 2 seconds

 JSR ZINF               \ Call ZINF to reset the INWK ship workspace

 LDA #CON               \ Set the ship type in TYPE to the Constrictor
 STA TYPE

 JSR NWSHP              \ Add a new Constrictor to the local bubble (in this
                        \ case, the briefing screen)

 LDA #1                 \ Move the text cursor to column 1
 STA XC

 STA INWK+7             \ Set z_hi = 1, the distance at which we show the
                        \ rotating ship

 JSR TT66               \ Clear the top part of the screen, draw a white border,
                        \ and set the current view type in QQ11 to 1

 LDA #64                \ Set the main loop counter to 64, so the ship rotates
 STA MCNT               \ for 64 iterations through MVEIT
 

.BRL1

 LDX #%01111111         \ Set the ship's roll counter to a positive roll that
 STX INWK+29            \ doesn't dampen

 STX INWK+30            \ Set the ship's pitch counter to a positive pitch that
                        \ doesn't dampen

 JSR LL9                \ Draw the ship on screen

 JSR MVEIT              \ Call MVEIT to rotate the ship in space

 DEC MCNT               \ Decrease the counter in MCNT

 BNE BRL1               \ Loop back to keep moving the ship until we have done
                        \ all 64 iterations

.BRL2

 LSR INWK               \ Halve x_lo so the Constrictor moves towards the centre

 INC INWK+6             \ Increment z_lo so the Constrictor moves away from us

 BEQ BR2                \ If z_lo = 0 (i.e. it just went past 255), jump to BR2
                        \ to show the briefing

 INC INWK+6             \ Increment z_lo so the Constrictor moves a bit further
                        \ away from us

 BEQ BR2                \ If z_lo = 0 (i.e. it just went past 255), jump out of
                        \ the loop to BR2 to stop moving the ship up the screen
                        \ and show the briefing

 LDX INWK+3             \ Set X = y_lo + 1
 INX

 CPX #112               \ If X < 112 then skip the next instruction
 BCC P%+4

 LDX #112               \ X is bigger than 112, so set X = 112 so that X has a
                        \ maximum value of 112

 STX INWK+3             \ Set y_lo = X
                        \          = y_lo + 1
                        \
                        \ so the ship moves up the screen (as space coordinates
                        \ have the y-axis going up)

 JSR LL9                \ Draw the ship on screen

 JSR MVEIT              \ Call MVEIT to move and rotate the ship in space

 JMP BRL2               \ Loop back to keep moving the ship up the screen and
                        \ away from us

.BR2

 INC INWK+7             \ Increment z_hi, to keep the ship at the same distance
                        \ as we just incremented z_lo past 255

 LDA #10                \ Set A = 10 so the call to BRP prints extended token 10
                        \ (the briefing for mission 1 where we find out all
                        \ about the stolen Constrictor)

 BNE BRPS               \ Jump to BRP via BRPS to print the extended token in A
                        \ and show the Status Mode screen), returning from the
                        \ subroutine using a tail call (this BNE is effectively
                        \ a JMP as A is never zero)

\ ******************************************************************************
\
\       Name: BRIS
\       Type: Subroutine
\   Category: Missions
\    Summary: Clear the screen, display "INCOMING MESSAGE" and wait for 2
\             seconds
\
\ ******************************************************************************

.BRIS

 LDA #216               \ Print extended token 216 ("{clear screen}{tab 6}{move
 JSR DETOK              \ to row 10, white, lower case}{white}{all caps}INCOMING
                        \ MESSAGE"

 LDY #100               \ Delay for 100 vertical syncs (100/50 = 2 seconds) and
 JMP DELAY              \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: PAUSE
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Display a rotating ship, waiting until a key is pressed, then
\             remove the ship from the screen
\
\ ******************************************************************************

.PAUSE

 JSR PAS1               \ Call PAS1 to display the rotating ship at space
                        \ coordinates (0, 112, 256) and scan the keyboard,
                        \ returning the internal key number in X (or 0 for no
                        \ key press)

 BNE PAUSE              \ If a key was already being held down when we entered
                        \ this routine, keep looping back up to PAUSE, until
                        \ the key is released

.PAL1

 JSR PAS1               \ Call PAS1 to display the rotating ship at space
                        \ coordinates (0, 112, 256) and scan the keyboard,
                        \ returning the internal key number in X (or 0 for no
                        \ key press)

 BEQ PAL1               \ Keep looping up to PAL1 until a key is pressed

 LDA #0                 \ Set the ship's AI flag to 0 (no AI) so it doesn't get
 STA INWK+31            \ any ideas of its pwn

 LDA #1                 \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 1

 JSR LL9                \ Draw the ship on screen to remove it

                        \ Fall through into MT23 to move to row 10, switch to
                        \ white text, and switch to lower case when printing
                        \ extended tokens

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
\       Name: PAS1
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Display a rotating ship at space coordinates (0, 112, 256) and
\             scan the keyboard
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   X                   If a key is being pressed, X contains the internal key
\                       number, otherwise it contains 0
\
\   A                   Contains the same as X
\
\ ******************************************************************************

.PAS1

 LDA #112               \ Set y_lo = 112
 STA INWK+3

 LDA #0                 \ Set x_lo = 0
 STA INWK

 STA INWK+6             \ Set z_lo = 0

 LDA #2                 \ Set z_hi = 1, so (z_hi z_lo) = 256
 STA INWK+7

 JSR LL9                \ Draw the ship on screen

 JSR MVEIT              \ Call MVEIT to move and rotate the ship in space

 JMP RDKEY              \ Scan the keyboard for a key press and return the
                        \ internal key number in X (or 0 for no key press),
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

 JSR RDKEY              \ Any pre-existing key press is now gone, so we can
                        \ start scanning the keyboard again, returning the
                        \ internal key number in X (or 0 for no key press)

 BEQ PAUSE2             \ Keep looping up to PAUSE2 until a key is pressed

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
\SAVE "output/T.ELTC.bin", CODE_C%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE D FILE
\
\ ******************************************************************************

CODE_D% = P%
LOAD_D% = LOAD% + P% - CODE%

\ ******************************************************************************
\
\       Name: tnpr
\       Type: Subroutine
\   Category: Market
\    Summary: Work out if we have space for a specific amount of cargo
\
\ ------------------------------------------------------------------------------
\
\ Given a market item and an amount, work out whether there is room in the
\ cargo hold for this item.
\
\ For standard tonne canisters, the limit is given by the type of cargo hold we
\ have, with a standard cargo hold having a capacity of 20t and an extended
\ cargo bay being 35t.
\
\ For items measured in kg (gold, platinum), g (gem-stones) and alien items,
\ the individual limit on each of these is 200 units.
\
\ Arguments:
\
\   A                   The number of units of this market item
\
\   QQ29                The type of market item (see QQ23 for a list of market
\                       item numbers)
\
\ Returns:
\
\   A                   A is preserved
\
\   C flag              Returns the result:
\
\                         * Set if there is no room for this item
\
\                         * Clear if there is room for this item
\
\ Other entry points:
\
\   Tml                 AJD
\
\ ******************************************************************************

.tnpr

 LDX #12                \ If QQ29 > 12 then jump to kg below, as this cargo
 CPX QQ29               \ type is gold, platinum, gem-stones or alien items,
 BCC kg                 \ and they have different cargo limits to the standard
                        \ tonne canisters

 CLC                    \ AJD

.Tml

                        \ Here we count the tonne canisters we have in the hold
                        \ and add to A to see if we have enough room for A more
                        \ tonnes of cargo, using X as the loop counter, starting
                        \ with X = 12

 ADC QQ20,X             \ Set A = A + the number of tonnes we have in the hold
                        \ of market item number X. Note that the first time we
                        \ go round this loop, the C flag is set (as we didn't
                        \ branch with the BCC above, so the effect of this loop
                        \ is to count the number of tonne canisters in the hold,
                        \ and add 1

 BCS n_over             \ AJD

 DEX                    \ Decrement the loop counter

 BPL Tml                \ Loop back to add in the next market item in the hold,
                        \ until we have added up all market items from 12
                        \ (minerals) down to 0 (food)

 CMP new_hold	        \ New hold size AJD

.n_over

 RTS                    \ Return from the subroutine

.kg

                        \ Here we count the number of items of this type that
                        \ we already have in the hold, and add to A to see if
                        \ we have enough room for A more units

 LDY QQ29               \ Set Y to the item number we want to add

 ADC QQ20,Y             \ Set A = A + the number of units of this item that we
                        \ already have in the hold

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

 LDA #%10000000         \ Set bit 7 of QQ17 to switch to Sentence Case
 STA QQ17

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

 JSR CTRL               \ AJD
 BPL not_cyclop
 JMP encyclopedia

.not_cyclop

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

 JMP PDESC              \ Jump to PDESC to print the system's extended
                        \ description, returning from the subroutine using a
                        \ tail call

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
 BNE l_27bb
 LDA QQ3
 ORA #&02
 STA QQ3

.l_27bb

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
 STA data_popn
 LDA QQ3
 EOR #&07
 ADC #&03
 STA &1B
 LDA QQ4
 ADC #&04
 STA &81
 JSR MULTU
 LDA data_popn
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

.long_map

 LDA #&40
 JSR TT66
 LDA #&07
 STA XC
 JSR TT81
 LDA #&C7
 JSR TT27
 JSR NLIN
 LDA #&98
 JSR NLIN2
 JSR map_range
 LDX #&00

.l_2830

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
 BNE l_2830
 LDA QQ9
 STA &73
 LDA QQ10
 LSR A
 STA &74
 LDA #&04
 STA &75

.map_cross

 LDA #&18
 LDX &87
 BPL l_2865
 LDA #&00

.l_2865

 STA &78
 LDA &73
 SEC
 SBC &75
 BCS l_2870
 LDA #&00

.l_2870

 STA &34
 LDA &73
 CLC
 ADC &75
 BCC l_287b
 LDA #&FF

.l_287b

 STA &36
 LDA &74
 CLC
 ADC &78
 STA &35
 JSR HLOIN
 LDA &74
 SEC
 SBC &75
 BCS l_2890
 LDA #&00

.l_2890

 CLC
 ADC &78
 STA &35
 LDA &74
 CLC
 ADC &75
 ADC &78
 CMP #&98
 BCC l_28a6
 LDX &87
 BMI l_28a6
 LDA #&97

.l_28a6

 STA &37
 LDA &73
 STA &34
 STA &36
 JMP LOIN

.short_cross

 LDA #&68
 STA &73
 LDA #&5A
 STA &74
 LDA #&10
 STA &75
 JSR map_cross
 LDA QQ14
 STA &40
 JMP map_CIRCLE2

.map_range

 LDA &87
 BMI short_cross
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
 JSR map_cross
 LDA &74
 CLC
 ADC #&18
 STA &74

.map_CIRCLE2

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

.buy_cargo

 LDA #&02
 JSR TT66
 JSR CTRL
 BPL buy_ctrl
 JMP cour_buy

.buy_ctrl

 JSR price_hdr
 \	LDA #&80
 \	STA QQ17
 JSR vdu_80
 JSR FLKB
 LDA #&00
 STA &03AD

.buy_loop

 JSR price_a
 LDA &03AB
 BNE l_292f
 JMP buy_next

.quant_err

 LDY #&B0

.cargo_err

 JSR TT162
 TYA
 JSR token_query
 JSR beep_wait

.l_292f

 JSR CLYNS
 LDA #&CC
 JSR TT27
 LDA &03AD
 CLC
 ADC #&D0
 JSR TT27
 LDA #&2F
 JSR TT27
 JSR price_units
 LDA #&3F
 JSR TT27
 JSR TT67
 JSR buy_quant
 BCS quant_err
 STA &1B
 JSR tnpr
 LDY #&CE
 BCS cargo_err
 LDA &03AA
 STA &81
 JSR price_scale
 JSR sub_money
 LDY #&C5
 BCC cargo_err
 LDY &03AD
 LDA &82
 PHA
 CLC
 ADC QQ20,Y
 STA QQ20,Y
 LDA cmdr_avail,Y
 SEC
 SBC &82
 STA cmdr_avail,Y
 PLA
 BEQ buy_next
 JSR buy_money

.buy_next

 LDA &03AD
 CLC
 ADC #&05
 STA YC
 LDA #&00
 STA XC
 INC &03AD
 LDA &03AD
 CMP #&11
 BCS buy_invnt
 JMP buy_loop

.buy_invnt

 LDA #&77
 JMP function

.sell_yn

 LDA #&CD
 JSR TT27
 LDA #&CE
 JSR DETOK

.buy_quant

 LDX #&00
 STX &82
 LDX #&0C
 STX &06

.buy_repeat

 JSR get_keyy
 LDX &82
 BNE l_29c6
 CMP #&79
 BEQ buy_y
 CMP #&6E
 BEQ buy_n

.l_29c6

 STA &81
 SEC
 SBC #&30
 BCC buy_ret
 CMP #&0A
 BCS buy_invnt
 STA &83
 LDA &82
 CMP #&1A
 BCS buy_ret
 ASL A
 STA &D1
 ASL A
 ASL A
 ADC &D1
 ADC &83
 STA &82
 CMP &03AB
 BEQ l_29eb
 BCS buy_ret

.l_29eb

 LDA &81
 JSR DASC
 DEC &06
 BNE buy_repeat

.buy_ret

 LDA &82
 RTS

.buy_y

 JSR DASC
 LDA &03AB
 STA &82
 RTS

.buy_n

 JSR DASC
 LDA #&00
 STA &82
 RTS

.sell_jump

 INC XC
 LDA #&CF
 JSR NLIN3
 JSR TT69
 JSR TT67
 JSR sell_equip
 LDA ESCP
 BEQ sell_escape
 LDA #&70
 LDX #&1E
 JSR plf2

.sell_escape

 JMP BAY

.l_2a08

 JSR TT67
 LDA #&B0
 JSR token_query
 JSR beep_wait
 LDY &03AD
 JMP l_2a37

.sell_cargo

 LDA #&04
 JSR TT66
 LDA #&0A
 STA XC
 JSR FLKB
 LDA #&CD
 JSR TT27
 JSR CTRL
 BMI sell_jump
 LDA #&CE
 JSR NLIN3
 JSR TT67

.inv_or_sell

 LDY #&00

.l_2a34

 STY &03AD

.l_2a37

 LDX QQ20,Y
 BEQ l_2aa3
 TYA
 ASL A
 ASL A
 TAY
 LDA cargo_data+&01,Y
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
 STA &03AB
 CLC
 JSR pr2
 JSR price_units
 LDA &87
 CMP #&04
 BNE l_2aa3
 JSR sell_yn
 BEQ l_2aa3
 BCS l_2a08
 LDA &03AD
 LDX #&FF
 STX QQ17
 JSR price_a
 LDY &03AD
 LDA QQ20,Y
 SEC
 SBC &82
 STA QQ20,Y
 LDA &82
 STA &1B
 LDA &03AA
 STA &81
 \	JSR price_scale	\--
 JSR MULTU
 JSR price_xy
 JSR MCASH	\++
 JSR MCASH	\++
 JSR MCASH	\++
 JSR MCASH
 LDA #&00
 STA QQ17

.l_2aa3

 LDY &03AD
 INY
 CPY #&11
 BCC l_2a34
 LDA &87
 CMP #&04
 BNE inv_quit
 JSR beep_wait
 JMP buy_invnt

.inv_quit

 RTS

.inventory

 LDA #&08
 JSR TT66
 LDA #&0B
 STA XC
 LDA #&A4
 JSR TT60
 JSR NLIN4
 JSR show_fuel
 LDA #&E	\ print hold size
 JSR TT68
 LDX new_hold
 DEX
 CLC
 JSR pr2
 JSR price_t
 JMP inv_or_sell

.add_dirn

 TXA
 PHA
 DEY
 TYA
 EOR #&FF
 PHA
 JSR WSCAN
 JSR TT103
 PLA
 STA &76
 LDA QQ10
 JSR incdec_dirn
 LDA &77
 STA QQ10
 STA &74
 PLA
 STA &76
 LDA QQ9
 JSR incdec_dirn
 LDA &77
 STA QQ9
 STA &73

.TT103

 LDA &87
 BMI map_shcurs
 LDA QQ9
 STA &73
 LDA QQ10
 LSR A
 STA &74
 LDA #&04
 STA &75
 JMP map_cross

.incdec_dirn

 STA &77
 CLC
 ADC &76
 LDX &76
 BMI l_2b45
 BCC l_2b47
 RTS

.l_2b45

 BCC l_2b49

.l_2b47

 STA &77

.l_2b49

 RTS

.map_shcurs

 LDA QQ9
 SEC
 SBC QQ0
 CMP #&26
 BCC l_2b59
 CMP #&E6
 BCC l_2b49

.l_2b59

 ASL A
 ASL A
 CLC
 ADC #&68
 STA &73
 LDA QQ10
 SEC
 SBC QQ1
 CMP #&26
 BCC l_2b6f
 CMP #&DC
 BCC l_2b49

.l_2b6f

 ASL A
 CLC
 ADC #&5A
 STA &74
 LDA #&08
 STA &75
 JMP map_cross

.short_map

 LDA #&80
 JSR TT66
 LDA #&07
 STA XC
 LDA #&BE
 JSR NLIN3
 JSR map_range
 JSR TT103
 JSR TT81
 LDA #&00
 STA &97
 LDX #&18

.l_2b99

 STA &46,X
 DEX
 BPL l_2b99

.short_loop

 LDA &6F
 SEC
 SBC QQ0
 STA &3A
 BCS l_2baa
 EOR #&FF
 ADC #&01

.l_2baa

 CMP #&14
 BCS l_2c1e
 LDA &6D
 SEC
 SBC QQ1
 STA &E0
 BCS l_2bba
 EOR #&FF
 ADC #&01

.l_2bba

 CMP #&26
 BCS l_2c1e
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
 BEQ l_2bef
 INY
 LDX &46,Y
 BEQ l_2bef
 DEY
 DEY
 LDX &46,Y
 BNE l_2c01

.l_2bef

 STY YC
 CPY #&03
 BCC l_2c1e
 LDA #&FF
 STA &46,Y
 \	LDA #&80
 \	STA QQ17
 JSR vdu_80
 JSR cpl

.l_2c01

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
 JSR l_32b0
 JSR l_33cb
 JSR l_32b0

.l_2c1e

 JSR TT20
 INC &97
 BEQ l_2c32
 JMP short_loop

.TT81

 LDX #&05

.l_2c2a

 LDA cmdr_gseed,X
 STA &6C,X
 DEX
 BPL l_2c2a

.l_2c32

 RTS

.TT111

 JSR TT81
 LDY #&7F
 STY &D1
 LDA #&00
 STA &80

.snap_loop

 LDA &6F
 SEC
 SBC QQ9
 BCS l_2c4a
 EOR #&FF
 ADC #&01

.l_2c4a

 LSR A
 STA &83
 LDA &6D
 SEC
 SBC QQ10
 BCS l_2c59
 EOR #&FF
 ADC #&01

.l_2c59

 LSR A
 CLC
 ADC &83
 CMP &D1
 BCS l_2c70
 STA &D1
 LDX #&05

.l_2c65

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_2c65
 LDA &80
 STA &88

.l_2c70

 JSR TT20
 INC &80
 BNE snap_loop
 LDX #&05

.l_2c79

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_2c79
 LDA &6D
 STA QQ10
 LDA &6F
 STA QQ9
 SEC
 SBC QQ0
 BCS l_2c94
 EOR #&FF
 ADC #&01

.l_2c94

 JSR SQUA2
 STA &41
 LDA &1B
 STA &40
 LDA QQ10
 SEC
 SBC QQ1
 BCS l_2caa
 EOR #&FF
 ADC #&01

.l_2caa

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
 JSR LL5
 LDA &81
 ASL A
 LDX #&00
 STX QQ8+&01
 ROL QQ8+&01
 ASL A
 ROL QQ8+&01
 STA QQ8
 JMP TT24

.data_home

 LDA QQ9
 STA QQ0
 LDA QQ10
 STA QQ1
 RTS

.pr6

 CLC

.pr5

 LDA #&05
 JMP TT11

.token_query

 JSR TT27
 LDA #&3F
 JMP TT27

.price_a

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
 LDA cargo_data+&01,X
 STA &74
 LDA cmdr_price
 AND cargo_data+&03,X
 CLC
 ADC cargo_data,X
 STA &03AA
 JSR price_units
 JSR mult_flag
 LDA &74
 BMI price_add
 LDA &03AA
 ADC &76
 JMP price_sto

.price_add

 LDA &03AA
 SEC
 SBC &76

.price_sto

 STA &03AA
 STA &1B
 LDA #&00
 JSR price_shift
 SEC
 JSR pr5
 LDY &77
 LDA #&05
 LDX cmdr_avail,Y
 STX &03AB
 CLC
 BEQ price_zero
 JSR pr2+2
 JMP price_units

.price_zero

 LDA XC
 ADC #&04
 STA XC
 LDA #&2D
 BNE l_2e07

.price_units

 LDA &74
 AND #&60
 BEQ price_t
 CMP #&20
 BEQ price_kg
 JSR price_g

.TT162

 LDA #&20

.l_2e07

 JMP TT27

.price_t

 LDA #&74
 JSR DASC
 BCC TT162

.price_kg

 LDA #&6B
 JSR DASC

.price_g

 LDA #&67
 JMP DASC

.price_hdr

 LDA #&11
 STA XC
 LDA #&FF
 BNE l_2e07

.mark_price

 LDA #&10
 JSR TT66
 LDA #&05
 STA XC
 LDA #&A7
 JSR NLIN3
 LDA #&03
 STA YC
 JSR price_hdr
 LDA #&00
 STA &03AD

.l_2e3d

 \	LDX #&80
 \	STX QQ17
 JSR vdu_80
 JSR price_a
 INC YC
 INC &03AD
 LDA &03AD
 CMP #&11
 BCC l_2e3d
 RTS

.mult_flag

 LDA &74
 AND #&1F
 LDY home_econ
 STA &75
 CLC
 LDA #&00
 STA cmdr_avail+&10

.l_2e60

 DEY
 BMI l_2e68
 ADC &75
 JMP l_2e60

.l_2e68

 STA &76
 RTS

.home_setup

 JSR TT111
 JSR data_home
 LDX #&05

.l_2e73

 LDA &6C,X
 STA &03B2,X
 DEX
 BPL l_2e73
 INX
 STX &0349
 LDA QQ3
 STA home_econ
 LDA QQ5
 STA home_tech
 LDA QQ4
 STA home_govmt
 RTS

.encyclopedia

 LDA #'E'
 STA rdcode+4

.launch

 LDX #&3F

.l_2e94

 LDA QQ16,X
 STA &0880,X
 DEX
 BPL l_2e94
 LDX #LO(rdcode)
 LDY #HI(rdcode)
 JMP oscli

.sub_money

 STX &06
 LDA cmdr_money+&03
 SEC
 SBC &06
 STA cmdr_money+&03
 STY &06
 LDA cmdr_money+&02
 SBC &06
 STA cmdr_money+&02
 LDA cmdr_money+&01
 SBC #&00
 STA cmdr_money+&01
 LDA cmdr_money
 SBC #&00
 STA cmdr_money
 BCS l_2eee

.MCASH

 TXA
 CLC
 ADC cmdr_money+&03
 STA cmdr_money+&03
 TYA
 ADC cmdr_money+&02
 STA cmdr_money+&02
 LDA cmdr_money+&01
 ADC #&00
 STA cmdr_money+&01
 LDA cmdr_money
 ADC #&00
 STA cmdr_money
 CLC

.l_2eee

 RTS

.price_scale

 JSR MULTU

.price_shift

 ASL &1B
 ROL A
 ASL &1B
 ROL A

.price_xy

 TAY
 LDX &1B
 RTS

.rdcode

 EQUS "R.1.F", &0D

\ a.tcode_2

.equip

 LDA #&20
 JSR TT66
 JSR FLKB
 LDA #&0C
 STA XC
 LDA #&CF
 JSR spc
 LDA #&B9
 JSR NLIN3
 \	LDA #&80
 \	STA QQ17
 JSR vdu_80
 INC YC
 JSR CTRL	\ check CTRL
 BPL n_eqship
 JMP n_buyship	\ branch

.jmp_start2

 JMP BAY

.n_eqship

 LDA home_tech
 CLC
 ADC #&02
 CMP #&0C
 BCC l_2f30
 LDA #&0E

.l_2f30

 STA &81
 STA &03AB
 INC &81
 LDA new_range
 SEC
 SBC QQ14
 ASL A
 STA PRXS
 LDA #0
 ROL A
 STA PRXS+1
 LDX #&01

.l_2f43

 STX &89
 JSR TT67
 LDX &89
 CLC
 JSR pr2
 JSR TT162
 LDA &89
 CLC
 ADC #&68
 JSR TT27
 LDA &89
 JSR equip_price
 SEC
 LDA #&19
 STA XC
 LDA #&06
 JSR TT11
 LDX &89
 INX
 CPX &81
 BCC l_2f43
 JSR CLYNS
 LDA #&7F
 JSR token_query
 JSR buy_quant
 BEQ jmp_start2
 BCS jmp_start2
 SBC #&00
 LDX #&02
 STX XC
 INC YC
 PHA
 CMP #&02
 BCC equip_space
 LDA QQ20+&10
 SEC
 LDX #&C
 JSR Tml
 BCC equip_isspace
 LDA #&0E
 JMP query_beep

.equip_isspace

 \**
 DEC new_hold	\**
 PLA
 PHA

.equip_space

 JSR equip_pay
 PLA
 BNE equip_nfuel
 LDX new_range
 STX QQ14
 JSR DIALS
 LDA #&00

.equip_nfuel

 CMP #&01
 BNE equip_nmisl
 LDX cmdr_misl
 INX
 LDY #&7C
 CPX new_missiles
 BCS l_2fe8
 STX cmdr_misl
 JSR show_missle

.equip_nmisl

 LDY #&6B
 CMP #&02
 BNE equip_nhold
 LDX CRGO
 BNE equip_gotit
 DEC CRGO

.equip_nhold

 CMP #&03
 BNE equip_necm
 INY
 LDX ECM
 BNE equip_gotit
 DEC ECM

.equip_necm

 CMP #&04
 BNE equip_npulse
 LDY new_pulse
 BNE equip_leap

.equip_npulse

 CMP #&05
 BNE equip_nbeam
 LDY new_beam

.equip_leap

 BNE equip_frog

.equip_nbeam

 LDY #&6F
 CMP #&06
 BNE equip_nscoop
 LDX BST
 BEQ l_3000

.equip_gotit

 INC new_hold

.l_2fe8

 STY &40
 JSR equip_price2
 JSR MCASH
 LDA &40
 JSR spc
 LDA #&1F
 JSR TT27

.equip_beep

 JSR beep_wait
 JMP BAY

.l_3000

 DEC BST

.equip_nscoop

 INY
 CMP #&07
 BNE equip_nescape
 LDX ESCP
 BNE equip_gotit
 DEC ESCP

.equip_nescape

 INY
 CMP #&08
 BNE equip_nbomb
 LDX cmdr_bomb
 BNE equip_gotit
 DEC cmdr_bomb

.equip_nbomb

 INY
 CMP #&09
 BNE equip_nunit
 LDX ENGY
 BNE equip_gotit
 LDX new_energy
 STX ENGY

.equip_nunit

 INY
 CMP #&0A
 BNE equip_ndock
 LDX cmdr_dock
 BNE equip_gotit
 DEC cmdr_dock

.equip_ndock

 INY
 CMP #&0B
 BNE equip_nhype
 LDX cmdr_ghype

.equip_gfrog

 BNE equip_gotit
 DEC cmdr_ghype

.equip_nhype

 INY
 CMP #&0C
 BNE equip_nmilt
 LDY new_military

.equip_frog

 BNE equip_merge

.equip_nmilt

 INY
 CMP #&0D
 BNE equip_nmine
 LDY new_mining

.equip_merge

 PHA
 TYA
 PHA
 JSR equip_side
 PLA
 LDY LASER,X
 BEQ l_3113
 PLA
 LDY #&BB
 BNE equip_gfrog

.l_3113

 STA LASER,X
 PLA

.equip_nmine

 JSR buy_money
 JMP equip

.buy_money

 JSR TT162
 LDA #&77
 JSR spc

.beep_wait

 JSR BEEP
 LDY #&32
 JMP DELAY

.equip_pay

 JSR equip_price2
 JSR sub_money
 BCS equip_quit
 LDA #&C5

.query_beep

 JSR token_query
 JMP equip_beep

.equip_price

 SEC
 SBC #&01

.equip_price2

 ASL A
 BEQ n_fcost
 ADC new_costs

.n_fcost

 TAY
 LDX PRXS,Y
 LDA PRXS+&01,Y
 TAY

.equip_quit

 RTS

.equip_side

 LDA home_tech
 CMP #&08
 BCC l_309f
 LDA #&20
 JSR TT66

.l_309f

 LDY #&10
 STY YC

.l_30a3

 LDX #&0C
 STX XC
 LDA YC
 CLC
 ADC #&20
 JSR spc
 LDA YC
 CLC
 ADC #&50
 JSR TT27
 INC YC
 LDA new_mounts
 ORA #&10
 CMP YC
 BNE l_30a3
 JSR CLYNS

.l_30c1

 LDA #&AF
 JSR token_query
 JSR get_keyy
 SEC
 SBC #&30
 CMP new_mounts
 BCC l_30d6
 JSR CLYNS
 JMP l_30c1

.l_30d6

 TAX
 RTS

.snap_cursor

 JSR TT103
 JSR TT111
 JSR TT103
 JMP CLYNS

.cpl

 LDX #&05

.l_311b

 LDA &6C,X
 STA &73,X
 DEX
 BPL l_311b
 LDY #&03
 BIT &6C
 BVS l_3129
 DEY

.l_3129

 STY &D1

.l_312b

 LDA &71
 AND #&1F
 BEQ l_3136
 ORA #&80
 JSR TT27

.l_3136

 JSR TT54
 DEC &D1
 BPL l_312b
 LDX #&05

.l_313f

 LDA &73,X
 STA &6C,X
 DEX
 BPL l_313f
 RTS

.write_cmdr

 JSR MT19
 LDY #&00

.l_314c

 LDA &1181,Y
 CMP #&0D
 BEQ l_3159
 JSR DASC
 INY
 BNE l_314c

.l_3159

 RTS

.l_315a

 JSR l_3160
 JSR cpl

.l_3160

 LDX #&05

.l_3162

 LDA &6C,X
 LDY &03B2,X
 STA &03B2,X
 STY &6C,X
 DEX
 BPL l_3162
 RTS

.l_3170

 CLC
 LDX GCNT
 INX
 JMP pr2

.show_fuel

 LDA #&69
 JSR TT68
 LDX QQ14
 SEC
 JSR pr2
 LDA #&C3
 JSR plf
 LDA #&77
 BNE TT27

.show_money

 LDX #&03

.l_318f

 LDA cmdr_money,X
 STA &40,X
 DEX
 BPL l_318f
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

.l_31aa

 LDA #&3A

.TT27

 TAX
 BEQ show_money
 BMI l_3225
 DEX
 BEQ l_3170
 DEX
 BEQ l_315a
 DEX
 BNE l_31bd
 JMP cpl

.l_31bd

 DEX
 BEQ write_cmdr
 DEX
 BEQ show_fuel
 DEX
 \	BNE l_31cb
 \	LDA #&80
 \	STA QQ17
 \	RTS
 BEQ vdu_80
 \l_31cb
 DEX
 DEX
 BNE l_31d2
 EQUB &2C

.vdu_80

 LDX #&80
 STX QQ17
 RTS

.l_31d2

 DEX
 BEQ l_320d
 CMP #&60
 BCS l_323f
 CMP #&0E
 BCC l_31e1
 CMP #&20
 BCC l_3209

.l_31e1

 LDX QQ17
 BEQ l_3222
 BMI l_31f8
 BIT QQ17
 BVS l_321b

.l_31eb

 CMP #&41
 BCC l_31f5
 CMP #&5B
 BCS l_31f5
 ADC #&20

.l_31f5

 JMP DASC

.l_31f8

 BIT QQ17
 BVS l_3213
 CMP #&41
 BCC l_3222
 PHA
 TXA
 ORA #&40
 STA QQ17
 PLA
 BNE l_31f5

.l_3209

 ADC #&72
 BNE l_323f

.l_320d

 LDA #&15
 STA XC
 BNE l_31aa

.l_3213

 CPX #&FF
 BEQ l_327a
 CMP #&41
 BCS l_31eb

.l_321b

 PHA
 TXA
 AND #&BF
 STA QQ17
 PLA

.l_3222

 JMP DASC

.l_3225

 CMP #&A0
 BCS l_323d
 AND #&7F
 ASL A
 TAY
 LDA QQ16,Y
 JSR TT27
 LDA QQ16+&01,Y
 CMP #&3F
 BEQ l_327a
 JMP TT27

.l_323d

 SBC #&A0

.l_323f

 TAX
 LDY #&00
 STY &22
 LDA #&04
 STA &23
 TXA
 BEQ l_3260

.l_324d

 LDA (&22),Y
 BEQ l_3258
 INY
 BNE l_324d
 INC &23
 BNE l_324d

.l_3258

 INY
 BNE l_325d
 INC &23

.l_325d

 DEX
 BNE l_324d

.l_3260

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
 BNE l_3276
 INC &23

.l_3276

 LDA (&22),Y
 BNE l_3260

.l_327a

 RTS

.l_3283

 LDX #&00

.l_3285

 LDA FRIN,X
 BEQ l_32a8
 BMI l_32a5
 JSR ship_ptr
 LDY #&1F

.l_3291

 LDA (&20),Y
 STA &46,Y
 DEY
 BPL l_3291
 STX &84
 LDX &84
 LDY #&1F
 LDA (&20),Y
 AND #&A7
 STA (&20),Y

.l_32a5

 INX
 BNE l_3285

.l_32a8

 LDX #&FF
 STX &0EC0
 STX &0F0E

.l_32b0

 LDY #&BF
 LDA #&00

.l_32b4

 STA &0E00,Y
 DEY
 BNE l_32b4
 DEY
 STY &0E00
 RTS

.ship_ptr

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA &20
 LDA UNIV+&01,Y
 STA &21
 RTS

.NWSHP

 STA &D1
 LDX #&00

.l_32ff

 LDA FRIN,X
 BEQ l_330b
 INX
 CPX #&0C
 BCC l_32ff
 CLC

.l_330a

 RTS

.l_330b

 JSR ship_ptr
 LDA &D1
 BMI l_3362
 ASL A
 TAY
 LDA XX21-2,Y
 STA &1E
 LDA XX21-1,Y
 STA &1F
 CPY #&04
 BEQ l_3352
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
 BCC l_330a
 BNE l_3348
 CPY #&25
 BCC l_330a

.l_3348

 LDA &67
 STA &03B0
 LDA &68
 STA &03B1

.l_3352

 LDY #&0E
 LDA (&1E),Y
 STA &69
 LDY #&13
 LDA (&1E),Y
 AND #&07
 STA &65
 LDA &D1

.l_3362

 STA FRIN,X
 TAX
 BMI l_336b
 INC &031E,X

.l_336b

 LDY #&24

.l_336d

 LDA &46,Y
 STA (&20),Y
 DEY
 BPL l_336d
 SEC
 RTS

.put_missle

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

.l_33ba

 STA (SC),Y
 DEY
 BNE l_33ba
 RTS

.l_33c0

 TXA
 EOR #&FF
 CLC
 ADC #&01
 TAX

.l_33c7

 LDA #&FF
 BNE l_340e

.l_33cb

 LDA #&01
 STA &0E00
 JSR l_35b7
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
 LDX &1D
 BNE l_33f2
 CMP &1C
 BCC l_33f2
 LDA &1C
 BNE l_33f2
 LDA #&01

.l_33f2

 STA &8F
 LDA #&BF
 SEC
 SBC &E0
 TAX
 LDA #&00
 SBC &E1
 BMI l_33c0
 BNE l_340a
 INX
 DEX
 BEQ l_33c7
 CPX &40
 BCC l_340e

.l_340a

 LDX &40
 LDA #&00

.l_340e

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

.l_3427

 CPY &8F
 BEQ l_3436
 LDA &0E00,Y
 BEQ l_3433
 JSR HLOIN2

.l_3433

 DEY
 BNE l_3427

.l_3436

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
 JSR LL5
 LDY &35
 JSR DORND
 AND &93
 CLC
 ADC &81
 BCC l_345d
 LDA #&FF

.l_345d

 LDX &0E00,Y
 STA &0E00,Y
 BEQ l_34af
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
 BCS l_3494
 LDA &36
 LDX &24
 STX &36
 STA &24
 JSR HLOIN

.l_3494

 LDA &24
 STA &34
 LDA &25
 STA &36

.l_349c

 JSR HLOIN

.l_349f

 DEY
 BEQ l_34e1
 LDA &23
 BNE l_34c3
 DEC &22
 BNE l_3436
 DEC &23

.l_34ac

 JMP l_3436

.l_34af

 LDX &D2
 STX &26
 LDX &D3
 STX &27
 JSR EDGES
 BCC l_349c
 LDA #&00
 STA &0E00,Y
 BEQ l_349f

.l_34c3

 LDX &22
 INX
 STX &22
 CPX &40
 BCC l_34ac
 BEQ l_34ac
 LDA &28
 STA &26
 LDA &29
 STA &27

.l_34d6

 LDA &0E00,Y
 BEQ l_34de
 JSR HLOIN2

.l_34de

 DEY
 BNE l_34d6

.l_34e1

 CLC
 LDA &D2
 STA &28
 LDA &D3
 STA &29
 RTS

.CIRCLE2

 LDX #&FF
 STX &92
 INX
 STX &93

.l_3507

 LDA &93
 JSR FMLTU2
 LDX #&00
 STX &D1
 LDX &93
 CPX #&21
 BCC l_3523
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 TXA
 CLC

.l_3523

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
 BCC l_3551
 TXA
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA &D1
 CLC

.l_3551

 JSR BLINE
 CMP #&41
 BCS l_355b
 JMP l_3507

.l_355b

 CLC
 RTS

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

.l_35b7

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

.clr_boot

 JSR clr_ships
 LDX #&06

.l_3687

 STA &2A,X
 DEX
 BPL l_3687
 TXA
 STA &8E
 LDX #&02

.l_3691

 STA FSH,X
 DEX
 BPL l_3691

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

 JSR l_3283
 JSR clr_ships
 LDA #&FF
 STA &03B0
 LDA #&0C
 STA &03B1
 JSR DIALS

.ZINF

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

.show_missle

 LDX #&03

.l_36ef

 LDY #&00
 CPX cmdr_misl
 BCS miss_miss	\BCC l_36fd
 LDY #&EE

.miss_miss

 JSR put_missle
 DEX
 BPL l_36ef
 RTS
 \l_36fd
 \	LDY #&EE
 \	JSR put_missle
 \	DEX
 \	BPL l_36fd
 \	RTS

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

.function

 JSR check_mode
 LDA &8E
 BNE repeat_fn
 JMP l_374a

.check_mode

 CMP #&76
 BNE not_status
 JMP STATUS

.not_status

 CMP #&14
 BNE not_long
 JMP long_map

.not_long

 CMP #&74
 BNE not_short
 JMP short_map

.not_short

 CMP #&75
 BNE not_data
 JSR TT111
 JMP TT25

.not_data

 CMP #&77
 BNE not_invnt
 JMP inventory

.not_invnt

 CMP #&16
 BNE not_price
 JMP mark_price

.not_price

 CMP #&20
 BNE not_launch
 JSR CTRL
 BMI jump_stay
 JMP launch

.jump_stay

 JMP stay_here

.not_launch

 CMP #&73
 BNE not_equip
 JMP equip

.not_equip

 CMP #&71
 BNE not_buy
 JMP buy_cargo

.not_buy

 CMP #&47
 BNE not_disk
 JSR disk_menu
 BCC not_loaded
 JMP not_loadc

.not_loaded

 JMP BAY

.not_disk

 CMP #&72
 BNE not_sell
 JMP sell_cargo

.not_sell

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

 JSR add_dirn

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
 JSR snap_cursor
 STA QQ17
 JSR cpl
 \	LDA #&80
 \	STA QQ17
 JSR vdu_80
 LDA #&01
 STA XC
 INC YC
 JMP TT146

.brkd

 EQUB &00

.BRBR

 DEC brkd
 BNE escape
 JSR RES2

.BEGIN

 JSR BRKBK
 LDX #&0A
 LDA #&00

.l_387c

 STA &03C5,X
 DEX
 BPL l_387c
 LDA #&7F	\ IN
 STA b_flag	\ IN

.stack_init

 LDX #&FF
 TXS

.escape

 LDX #&03
 STX XC
 JSR fx2000
 LDX #&0B
 LDA #&06
 JSR rotate
 CMP #&44
 BNE not_loadc
 JSR copy_cmdr
 JSR disk_menu

.not_loadc

 JSR copy_cmdr
 JSR show_missle
 LDA #&07
 LDX #&13
 JSR rotate
 JSR set_home
 JSR home_setup

.BAY

 LDA #&FF
 STA &8E
 LDA #&76
 JMP function

.copy_cmdr

 LDX #&53

.l_38bb

 LDA &1180,X
 STA &034F,X
 DEX
 BNE l_38bb
 STX &87

.l_38c6

 JSR cmdr_code
 CMP commander+&4B
 BNE l_38c6
 JMP n_load	\ load ship details

.rotate

 PHA
 STX &8C
 JSR clr_boot
 LDA #&01
 JSR TT66
 DEC &87
 LDA #&60
 STA &54
 LDA #&DB
 STA &4D
 LDX #&7F
 STX &63
 STX &64
 \	INX
 \	STX QQ17
 JSR vdu_80
 LDA &8C
 JSR NWSHP
 LDY #&06
 STY XC
 LDA #&1E
 JSR plf
 LDY #&06
 STY XC
 INC YC
 LDA x_flag
 BEQ l_392b
 LDA #&0D
 JSR DETOK
 INC YC
 INC YC
 LDA #&03
 STA XC
 LDA #&72
 JSR DETOK

.l_392b

 LDA brkd
 BEQ l_3945
 INC brkd
 LDA #&07
 STA XC
 LDA #&0A
 STA YC
 LDY #&00

.l_393d

 JSR oswrch
 INY
 LDA (brk_line),Y
 BNE l_393d

.l_3945

 JSR CLYNS
 STY &7D
 STY k_flag
 PLA
 JSR DETOK
 LDA #&0C
 LDX #&07
 STX XC
 JSR DETOK

.l_395a

 LDA &4D
 CMP #&01
 BEQ l_3962
 DEC &4D

.l_3962

 JSR MVEIT
 LDA #&80
 STA &4C
 ASL A
 STA &46
 STA &49
 JSR LL9
 DEC &8A
 LDA #&51
 STA &FE60
 LDA &FE40
 AND #&10
 BEQ l_3980
 JSR RDKEY
 BEQ l_395a
 RTS

.l_3980

 DEC k_flag
 RTS

.cmdr_code

 LDX #&49
 SEC
 TXA

.l_3988

 ADC &1188,X
 EOR commander,X
 DEX
 BNE l_3988
 RTS

.copy_name

 LDX #&07

.l_3994

 LDA &4B,X
 STA &1181,X
 DEX
 BPL l_3994

.l_399c

 LDX #&07

.l_399e

 LDA &1181,X
 STA &4B,X
 DEX
 BPL l_399e
 RTS

.get_fname

 LDY #&08
 JSR DELAY
 LDX #&04

.l_39ae

 LDA &117C,X
 STA &46,X
 DEX
 BPL l_39ae
 LDA #&07
 STA word_0+&02
 LDA #&08
 JSR DETOK
 JSR MT26
 LDA #&09
 STA word_0+&02
 TYA
 BEQ l_399c
 RTS

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

.clr_bc

 LDX #&0C
 JSR ZES1
 DEX

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

.cat_line

 EQUS ".:0", &0D

.del_line

 EQUS "DEL.:0.E.1234567", &0D

.show_cat

 JSR get_drive
 BCS cat_quit
 STA cat_line+&02
 STA MT16+&01
 LDA #&04
 JSR DETOK
 \	LDA &0355
 \	PHA
 LDA #&01
 STA &0355
 STA &03CF
 STA XC
 LDX #LO(cat_line)
 LDY #HI(cat_line)
 JSR oscli
 DEC &03CF
 \	PLA
 LDA &1186
 STA &0355
 CLC

.cat_quit

 RTS

.disk_del

 JSR show_cat
 BCS disk_menu
 LDA cat_line+&02
 STA del_line+&05
 LDA #&09
 JSR DETOK
 JSR MT26
 TYA
 BEQ disk_menu
 LDX #&09

.l_3a5b

 LDA &4A,X
 STA del_line+&06,X
 DEX
 BNE l_3a5b
 LDX #LO(del_line)
 LDY #HI(del_line)
 JSR oscli
 JMP disk_menu
 \l_3a6d
 \	EQUB &00

.brk_new

 LDX #&FF	\LDX l_3a6d
 TXS
 LDY #&00
 LDA #&07

.l_3a76

 JSR oswrch
 INY
 LDA (brk_line),Y
 BNE l_3a76
 BEQ l_3a83

.disk_cat

 JSR show_cat

.l_3a83

 JSR get_key

.disk_menu

 JSR clr_bc
 TSX
 STX brk_new+&01	\STX l_3a6d
 LDA #LO(brk_new)
 STA BRKV
 LDA #HI(brk_new)
 STA BRKV+1
 LDA #&01
 JSR DETOK
 JSR get_key
 CMP #&31
 BCC disk_exit
 CMP #&34
 BEQ disk_del
 BCS disk_exit
 CMP #&32
 BCS not_dload
 LDA #&00
 JSR confirm
 BNE disk_exit
 JSR get_fname
 JSR read_file
 JSR copy_name
 SEC
 BCS l_3b15

.not_dload

 BNE disk_cat
 LDA #&FF
 JSR confirm
 BNE disk_exit
 JSR get_fname
 JSR copy_name
 LDX #&4B

.l_3acb

 LDA TP,X
 STA &0B00,X
 STA commander,X
 DEX
 BPL l_3acb
 JSR cmdr_code
 STA commander+&4B
 STA &0B4B
 EOR #&A9
 STA commander+&4A
 STA &0B4A
 LDY #&0B
 STY &0C0B
 INY
 STY &0C0F
 LDA #&00
 JSR disk_file

.disk_exit

 CLC

.l_3b15

 JMP BRKBK

.confirm

 CMP save_lock
 BEQ confirmed
 LDA #&03
 JSR DETOK
 JSR get_key
 JSR CHPR
 ORA #&20
 PHA
 JSR TT67
 JSR FEED
 PLA
 CMP #&79

.confirmed

 RTS

.disk_file

 PHA
 JSR get_drive
 STA &47
 PLA
 BCS file_quit
 STA save_lock
 LDX #&46
 STX &0C00
 LDX #&00
 LDY #&0C
 JSR osfile
 CLC

.file_quit

 RTS

.get_drive

 LDA #&02
 JSR DETOK
 JSR get_key
 ORA #&10
 JSR CHPR
 PHA
 JSR FEED
 PLA
 CMP #&30
 BCC bad_stat
 CMP #&34
 RTS

.read_file

 JSR clr_bc
 LDY #&0B
 STY &0C03
 INC &0C0B
 LDA #&FF
 JSR disk_file
 BCS bad_stat
 LDA &0B00
 BMI illegal
 LDX #&4B

.l_3b61

 LDA &0B00,X
 STA commander,X
 DEX
 BPL l_3b61

.bad_stat

 SEC
 RTS

.illegal

 BRK
 EQUB &49
 EQUS "Not ELITE III file"
 BRK

.fx2000

 LDY #&00
 LDA #&C8
 JMP osbyte

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
 \	CPY #&47
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

.get_keyy

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

.cargo_data

 EQUB &13, &82, &06, &01
 EQUB &14, &81, &0A, &03
 EQUB &41, &83, &02, &07
 EQUB &28, &85, &E2, &1F
 EQUB &53, &85, &FB, &0F
 EQUB &C4, &08, &36, &03
 EQUB &EB, &1D, &08, &78
 EQUB &9A, &0E, &38, &03
 EQUB &75, &06, &28, &07
 EQUB &4E, &01, &11, &1F
 EQUB &7C, &0D, &1D, &07
 EQUB &B0, &89, &DC, &3F
 EQUB &20, &81, &35, &03
 EQUB &61, &A1, &42, &07
 EQUB &AB, &A2, &37, &1F
 EQUB &2D, &C1, &FA, &0F
 EQUB &35, &0F, &C0, &07

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

.LL9

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
 JMP l_327a

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
 JMP l_327a

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
 \ additions start here

.n_buyship

 LDX #&00
 SEC
 LDA #&0F	\LDA #&0D
 SBC home_econ
 SBC home_econ	\++
 STA &03AB

.n_bloop

 STX &89
 JSR TT67
 LDX &89
 INX
 CLC
 JSR pr2
 JSR TT162
 LDY &89
 JSR n_name
 LDY &89
 JSR n_price
 LDA #&16
 STA XC
 LDA #&09
 STA &80
 SEC
 JSR BPRNT
 LDX &89
 INX
 CPX &03AB
 BCC n_bloop
 JSR CLYNS
 LDA #&B9
 JSR token_query
 JSR buy_quant
 BEQ jmp_start3
 BCS jmp_start3
 SBC #&00
 CMP &03AB
 BCS jmp_start3
 LDX #&02
 STX XC
 INC YC
 STA &81
 LDY new_type
 JSR n_price
 CLC
 LDX #3

.n_addl

 LDA cmdr_money,X
 ADC &40,X
 STA &09,X
 DEX
 BPL n_addl
 LDY &81
 JSR n_price
 SEC
 LDX #3

.n_subl

 LDA &09,X
 SBC &40,X
 STA &40,X
 DEX
 BPL n_subl
 LDA &81
 BCS n_buy

.cash_query

 LDA #&C5
 JSR token_query

.jmp_start3

 JSR beep_wait
 JMP BAY

.n_buy

 TAX
 LDY #3

.n_cpyl

 LDA &40,Y
 STA cmdr_money,Y
 DEY
 BPL n_cpyl
 LDA #&00
 LDY #&24

.n_wipe

 STA &0368,Y
 DEY
 BPL n_wipe
 STX new_type
 JSR n_load
 LDA new_range
 STA QQ14
 JSR show_missle
 JMP BAY

.n_load

 LDY new_type
 LDX new_offsets,Y
 LDY #0

.n_lname

 CPY #9
 BCS n_linfo
 LDA new_ships,X
 EOR #&23
 STA new_name,Y

.n_linfo

 LDA new_details,X
 STA new_pulse,Y
 INX
 INY
 CPY #13
 BNE n_lname
 LDA new_max
 EOR #&FE
 STA new_min
 LDY #&0B

.count_lasers

 LDX count_offs,Y
 LDA LASER,X
 BEQ count_sys
 DEC new_hold	\**

.count_sys

 DEY
 BPL count_lasers
 RTS

.count_offs

 EQUB &00, &01, &02, &03, &06, &18, &19, &1A, &1B, &1C, &1D, &1E

.n_name

 \ name ship in 0 <= Y <= &C
 LDX new_offsets,Y
 LDA #9
 STA &41

.n_lprint

 LDA new_ships,X
 STX &40
 JSR TT27
 LDX &40
 INX
 DEC &41
 BNE n_lprint
 RTS

.n_price

 \ put price 0 <= Y <= &C into 40-43
 LDX new_offsets,Y
 LDY #3

.n_lprice

 LDA new_price,X
 STA &40,Y
 INX
 DEY
 BPL n_lprice
 RTS

.cour_buy

 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ cour_start
 JMP jmp_start3

.cour_start

 LDA #&0A
 STA XC
 LDA #&6F
 JSR DETOK
 JSR NLIN4
 \	LDA #&80
 \	STA QQ17
 JSR vdu_80
 LDA cmdr_price
 EOR QQ0
 EOR QQ1
 EOR FIST
 EOR TALLY
 STA &46
 SEC
 LDA FIST
 ADC GCNT
 ADC cmdr_ship
 STA &47
 ADC &46
 SBC cmdr_courx
 SBC cmdr_coury
 AND #&0F
 STA &03AB
 BEQ cour_pres
 LDA #&00
 STA &49
 STA &4C
 JSR TT81

.cour_loop

 LDA &49
 CMP &03AB
 BCC cour_count

.cour_menu

 JSR CLYNS
 LDA #&CE
 JSR token_query
 JSR buy_quant
 BEQ cour_pres
 BCS cour_pres
 TAX
 DEX
 CPX &49
 BCS cour_pres
 LDA #&02
 STA XC
 INC YC
 STX &46
 LDY &0C50,X
 LDA &0C40,X
 TAX
 JSR sub_money
 BCS cour_cash
 JMP cash_query

.cour_cash

 LDX &46
 LDA &0C00,X
 STA cmdr_courx
 LDA &0C10,X
 STA cmdr_coury
 CLC
 LDA &0C20,X
 ADC FIST
 STA FIST
 LDA &0C30,X
 STA cmdr_cour+1
 LDA &0C40,X
 STA cmdr_cour

.cour_pres

 JMP jmp_start3

.cour_count

 JSR TT20
 INC &4C
 BEQ cour_menu
 DEC &46
 BNE cour_count	
 LDX &49
 LDA &6F
 CMP QQ0
 BNE cour_star
 LDA &6D
 CMP QQ1
 BNE cour_star
 JMP cour_next

.cour_star

 LDA &6F
 EOR &71
 EOR &47
 CMP FIST
 BCC cour_legal
 LDA #0

.cour_legal

 STA &0C20,X
 LDA &6F
 STA &0C00,X
 SEC
 SBC QQ0
 BCS cour_negx
 EOR #&FF
 ADC #&01

.cour_negx

 JSR SQUA2
 STA &41
 LDA &1B
 STA &40
 LDX &49
 LDA &6D
 STA &0C10,X
 SEC
 SBC QQ1
 BCS cour_negy
 EOR #&FF
 ADC #&01

.cour_negy

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
 JSR LL5
 LDX &49
 LDA &6D
 EOR &71
 EOR &47
 LSR A
 LSR A
 LSR A
 CMP &81
 BCS cour_dist
 LDA &81

.cour_dist

 ORA &0C20,X
 STA &0C30,X
 STA &4A
 LSR A
 ROR &4A
 LSR A
 ROR &4A
 LSR A
 ROR &4A
 STA &4B
 STA &0C50,X
 LDA &4A
 STA &0C40,X
 LDA #&01
 STA XC
 CLC
 LDA &49
 ADC #&03
 STA YC
 LDX &49
 INX
 CLC
 JSR pr2
 JSR TT162
 JSR cpl
 LDX &4A
 LDY &4B
 SEC
 LDA #&19
 STA XC
 LDA #&06
 JSR TT11
 INC &49

.cour_next

 LDA &47
 STA &46
 JMP cour_loop

.cour_dock

 LDA cmdr_cour
 ORA cmdr_cour+1
 BEQ cour_quit
 LDA QQ0
 CMP cmdr_courx
 BNE cour_half
 LDA QQ1
 CMP cmdr_coury
 BNE cour_half
 LDA #&02
 JSR TT66
 LDA #&06
 STA XC
 LDA #&0A
 STA YC
 LDA #&71
 JSR DETOK
 LDX cmdr_cour
 LDY cmdr_cour+1
 SEC
 LDA #&06
 JSR TT11
 LDA #&E2
 JSR TT27
 LDX cmdr_cour
 LDY cmdr_cour+1
 JSR MCASH
 LDA #0
 STA cmdr_cour
 STA cmdr_cour+1
 LDY #&60
 JSR DELAY

.cour_half

 LSR cmdr_cour+1
 ROR cmdr_cour

.cour_quit

 RTS

.stay_here

 LDX #&F4
 LDY #&01
 JSR sub_money
 BCC stay_quit
 JSR cour_dock
 JSR DORND
 STA cmdr_price
 LDX #&00
 STX &96

.d_31d8

 LDA cargo_data+&01,X
 STA &74
 JSR mult_flag
 LDA cargo_data+&03,X
 AND cmdr_price
 CLC
 ADC cargo_data+&02,X
 LDY &74
 BMI d_31f4
 SEC
 SBC &76
 JMP d_31f7

.d_31f4

 CLC
 ADC &76

.d_31f7

 BPL d_31fb
 LDA #&00

.d_31fb

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
 BCC d_31d8

.stay_quit

 JMP BAY

.new_offsets

 EQUB   0,  13,  26,  39,  52,  65,  78,  91
 EQUB 104, 117, 130, 143, 156, 169, 182	\, 195

 \ Name
 \ Price
 \ Pulse, Beam, Military, Mining Lasers, Mounts, Missiles
 \ Shields, Energy, Speed, Hold, Range, Costs
 \ Manouvre-h, Manoevre-l	\, Spare, Spare

.new_ships

.new_adder

 EQUS "ADDER    "

.new_price

IF _SOURCE_DISC

 EQUD 270000

 EQUS "GECKO    "
 EQUD 325000

 EQUS "MORAY    "
 EQUD 360000

 EQUS "COBRA MK1"
 EQUD 395000

 EQUS "IGUANA   "
 EQUD 640000

 EQUS "OPHIDIAN "
 EQUD 645000

 EQUS "CHAMELEON"
 EQUD 975000

 EQUS "COBRA MK3"
 EQUD 1000000

 EQUS "GHAVIAL  "
 EQUD 1365000

 EQUS "F", &90, "-DE-L", &9B, &85
 EQUD 1435000

 EQUS "MONITOR  "
 EQUD 1750000

 EQUS "PYTHON   "
 EQUD 2050000

 EQUS "BOA      "
 EQUD 2400000

 EQUS "ANACONDA "
 EQUD 4000000

 EQUS "ASP MK2  "
 EQUD 8950000

ELIF _RELEASED

 EQUD 310000

 EQUS "GECKO    "
 EQUD 400000

 EQUS "MORAY    "
 EQUD 565000

 EQUS "COBRA MK1"
 EQUD 750000

 EQUS "IGUANA   "
 EQUD 1315000

 EQUS "OPHIDIAN "
 EQUD 1470000

 EQUS "CHAMELEON"
 EQUD 2250000

 EQUS "COBRA MK3"
 EQUD 2870000

 EQUS "F", &90, "-DE-L", &9B, &85
 EQUD 3595000

 EQUS "GHAVIAL  "
 EQUD 3795000

 EQUS "MONITOR  "
 EQUD 5855000

 EQUS "PYTHON   "
 EQUD 7620000

 EQUS "BOA      "
 EQUD 9600000

 EQUS "ASP MK2  "
 EQUD 10120000

 EQUS "ANACONDA "
 EQUD 18695000

ENDIF

.new_details

 EQUB &0E, &8E, &92, &19, &02, &02	\ adder
 EQUB &04, &01,  36, &09,  60, &1A
 EQUB &DF	\, &21, &05, &00

 EQUB &0E, &8F, &93, &19, &04, &03	\ gecko
 EQUB &05, &01,  45, &0A,  70, &1A
 EQUB &EF	\, &11, &06, &00

 EQUB &10, &8F, &96, &19, &04, &03	\ moray
 EQUB &06, &01,  38, &0C,  80, &68
 EQUB &EF	\, &11, &07, &00

 EQUB &0E, &8E, &94, &19, &04, &04	\ cobra 1
 EQUB &05, &01,  39, &0F,  60, &1A
 EQUB &CF	\, &31, &08, &00

 EQUB &0E, &8E, &94, &19, &04, &04	\ iguana
 EQUB &07, &01,  50, &16,  75, &00
 EQUB &DF	\, &21, &08, &00

 EQUB &0D, &8D, &90, &0C, &01, &03	\ ophidian
 EQUB &04, &01,  51, &19,  70, &68
 EQUB &FF	\, &01, &06, &00

 EQUB &10, &8F, &97, &32, &02, &04	\ chameleon
 EQUB &08, &01,  43, &24,  80, &68
 EQUB &DF	\, &21, &05, &00

 EQUB &12, &8F, &98, &32, &04, &05	\ cobra 3
 EQUB &07, &01,  42, &2B,  70, &00
 EQUB &EF	\, &11, &0A, &00

IF _SOURCE_DISC

 EQUB &11, &90, &99, &32, &04, &04	\ ghavial
 EQUB &09, &01,  37, &38,  80, &00
 EQUB &CF	\, &31, &09, &00

 EQUB &12, &92, &9C, &32, &04, &04	\ fer-de-lance
 EQUB &08, &02,  45, &0A,  85, &34
 EQUB &DF	\, &21, &09, &00

ELIF _RELEASED

 EQUB &12, &92, &9C, &32, &04, &04	\ fer-de-lance
 EQUB &08, &02,  45, &0A,  85, &34
 EQUB &DF	\, &21, &09, &00

 EQUB &11, &90, &99, &32, &04, &04	\ ghavial
 EQUB &09, &01,  37, &38,  80, &00
 EQUB &CF	\, &31, &09, &00

ENDIF

 EQUB &18, &93, &9C, &32, &04, &09	\ monitor
 EQUB &0A, &01,  24, &52, 110, &4E
 EQUB &BF	\, &41, &0C, &00

 EQUB &18, &92, &9B, &32, &04, &05	\ python
 EQUB &0B, &01,  30, &6B,  80, &1A
 EQUB &AF	\, &51, &09, &00

 EQUB &14, &8E, &98, &32, &02, &07	\ boa
 EQUB &0A, &01,  36, &85,  90, &00
 EQUB &BF	\, &41, &0A, &00

IF _SOURCE_DISC

 EQUB &1C, &90, &7F, &32, &04, &11	\ anaconda
 EQUB &0D, &01,  21, &FE, 100, &4E
 EQUB &AF	\, &51, &0C, &00

 EQUB &10, &91, &9F, &0C, &01, &02	\ asp 2
 EQUB &0A, &01,  60, &07, 125, &34
 EQUB &DF	\, &21, &07, &00

ELIF _RELEASED

 EQUB &10, &91, &9F, &0C, &01, &02	\ asp 2
 EQUB &0A, &01,  60, &07, 125, &34
 EQUB &DF	\, &21, &07, &00

 EQUB &1C, &90, &7F, &32, &04, &11	\ anaconda
 EQUB &0D, &01,  21, &FE, 100, &4E
 EQUB &AF	\, &51, &0C, &00

ENDIF

\ a.tcode_3

.TKN1

 EQUB &00
 EQUS &09, &0B, &01, &08, " ", &F1, "SK AC", &E9, "SS ME", &E1, &D7, &0A, &02, "1. ", &95, &D7, "2. SA", &FA
 EQUS " ", &9A, " ", &04, &D7, "3. C", &F5, "A", &E0, "GUE", &D7, "4. DEL", &DD, "E", &D0, "FI", &E5, &D7, "5. E"
 EQUS "X", &DB, &D7
 EQUB &00
 EQUS &0C, "WHICH ", &97, "?"
 EQUB &00
 \	EQUA "ARE YOU SURE?"
 EQUS &EE, "E ", &B3, " SU", &F2, "?"
 EQUB &00
 EQUS &96, &97, " ", &10, &98, &D7
 EQUB &00
 EQUS &B0, "m", &CA, "n", &B1
 EQUB &00
 EQUS "  ", &95, " ", &01, "(Y/N)?", &02, &0C, &0C
 EQUB &00
 EQUS "P", &F2, "SS SPA", &E9, " ", &FD, " FI", &F2, ",", &9A, ".", &0C, &0C
 EQUB &00
 EQUS &9A, "'S", &C8
 EQUB &00
 EQUS &15, "FI", &E5, &C9, "DEL", &DD, "E?"
 EQUB &00
 EQUS &17, &0E, &02, "G", &F2, &DD, &F0, "GS", &D5, &B2, &13, "I ", &F7, "G", &D0, "MOM", &F6, "T OF ", &B3, "R V", &E4
 EQUS "U", &D8, &E5, " ", &FB, "ME", &CC, "WE W", &D9, "LD LIKE ", &B3, &C9, "DO", &D0, "L", &DB, "T", &E5, " JO"
 EQUS "B F", &FD, " ", &EC, &CC, &93, &CF, " ", &B3, " ", &DA, "E HE", &F2, &CA, "A", &D2, "MODEL, ", &93
 EQUS &13, "C", &DF, &DE, "RICT", &FD, ", E", &FE, "IP", &C4, "WI", &E2, &D0, "TOP ", &DA, "CR", &DD, &D2, "SHI"
 EQUS "ELD G", &F6, &F4, &F5, &FD, &CC, "UNF", &FD, "TUN", &F5, "ELY ", &DB, "'S ", &F7, &F6, " ", &DE, "O"
 EQUS "L", &F6, &CC, &16, &DB, " W", &F6, "T MISS", &C3, "FROM ", &D9, "R ", &CF, " Y", &EE, "D ", &DF, " ", &13, &E6
 EQUS &F4, " FI", &FA, " M", &DF, &E2, "S AGO", &B2, &1C, &CC, &B3, "R MISSI", &DF, ", SH", &D9, "LD "
 EQUS &B3, " DECIDE", &C9, "AC", &E9, "PT ", &DB, ", IS", &C9, &DA, "EK", &B2, "D", &ED, "TROY ", &94, &CF
 EQUS &CC, &B3, " A", &F2, " CAU", &FB, &DF, &C4, &E2, &F5, " ", &DF, "LY ", &06, "u", &05, "S W", &DC, "L P", &F6
 EQUS &DD, &F8, "TE ", &93, "NEW SHIELDS", &B2, &E2, &F5, " ", &93, &13, "C", &DF, &DE, "RICT", &FD
 EQUS &CA, "F", &DB, "T", &C4, "WI", &E2, " ", &FF, " ", &06, "l", &05, &B1, &02, &08, "GOOD LUCK, ", &9A, &D4, &16
 EQUB &00
 EQUS &19, &09, &17, &0E, &02, "  ", &F5, "T", &F6, &FB, &DF, &D5, ". ", &13, "WE HA", &FA, " NE", &C4, "OF ", &B3, "R"
 EQUS " ", &DA, "RVIC", &ED, " AGA", &F0, &CC, "IF ", &B3, " W", &D9, "LD ", &F7, " ", &EB, " GOOD AS", &C9
 EQUS "GO", &C9, &13, &E9, &F4, &F1, " ", &B3, " W", &DC, "L ", &F7, " BRIEF", &FC, &CC, "IF SUC", &E9, "S"
 EQUS "SFUL, ", &B3, " W", &DC, "L ", &F7, " WELL ", &F2, "W", &EE, "D", &FC, &D4, &18
 EQUB &00
 EQUS "(", &13, "C) AC", &FD, "N", &EB, "FT 1984"
 EQUB &00
 EQUS "BY D.B", &F8, &F7, "N & I.", &F7, "LL"
 EQUB &00
 EQUS &15, &91, &C8, &1A
 EQUB &00
 EQUS &19, &09, &17, &0E, &02, "  C", &DF, "G", &F8, "TU", &F9, &FB, &DF, "S ", &9A, "!", &0C, &0C, &E2, &F4, "E", &0D, " W"
 EQUS &DC, "L ", &E4, "WAYS ", &F7, &D0, "P", &F9, &E9, " F", &FD, " ", &B3, " ", &F0, &D3, &CC, &FF, "D ", &EF
 EQUS "Y", &F7, " ", &EB, &DF, &F4, " ", &E2, &FF, " ", &B3, " ", &E2, &F0, "K..", &D4, &18
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
 EQUS "I HE", &EE, &D0, "r ", &E0, "OK", &C3, &CF, " APPE", &EE, &C4, &F5, &D1
 EQUB &00
 EQUS "YEAH, I HE", &EE, &D0, "r ", &CF, " ", &E5, "FT", &D1, &D0, " WHI", &E5, " BACK"
 EQUB &00
 EQUS "G", &DD, " ", &B3, "R IR", &DF, " ASS OV", &F4, " TO", &D1
 EQUB &00
 EQUS &EB, "ME s", &D2, &CF, " WAS ", &DA, &F6, " ", &F5, &D1
 EQUB &00
 EQUS "TRY", &D1
 EQUB &00
 EQUS &01, "SPECI", &E4, " C", &EE, "GO"
 EQUB &00
 EQUB &00
 EQUS "C", &EE, "GO V", &E4, "UE:"
 EQUB &00
 EQUS " MO", &F1, "FI", &FC, " BY A.J.C.DUGG", &FF
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
 EQUS &02, " H", &F4, " ", &EF, "J", &ED, "TY'S SPA", &E9, " NAVY", &0D
 EQUB &00
 EQUS &B1, &08, &01, "  M", &ED, "SA", &E7, " ", &F6, "DS"
 EQUB &00
 EQUS " ", &9A, " ", &04, ", I ", &0D, "AM", &02, " CAPTA", &F0, " ", &1B, " ", &0D, "OF", &D3
 EQUB &00
 EQUB &00
 EQUS &0F, " UNK", &E3, "WN ", &91
 EQUB &00
 EQUS &09, &08, &17, &01, &F0, "COM", &C3, "M", &ED, "SA", &E7
 EQUB &00
 EQUS "CURRU", &E2, &F4, "S"
 EQUB &00
 EQUS "FOSDYKE SMY", &E2, "E"
 EQUB &00
 EQUS "F", &FD, "T", &ED, &FE, "E"
 EQUB &00
 EQUS &CB, &F2, &ED, &F1, &E9
 EQUB &00
 EQUS "IS ", &F7, "LIEV", &FC, &C9, "HA", &FA, " JUMP", &FC, &C9, &94, "G", &E4, "AXY"
 EQUB &00
 EQUS &19, &09, &1D, &0E, &02, "GOOD DAY ", &9A, " ", &04, &CC, "I", &0D, " AM ", &13, "AG", &F6, "T ", &13, "B", &F9, "KE"
 EQUS " OF ", &13, "NAV", &E4, " ", &13, &F0, "TEL", &E5, "G", &F6, &E9, &CC, "AS ", &B3, " K", &E3, "W, ", &93, &13
 EQUS "NAVY HA", &FA, " ", &F7, &F6, " KEEP", &C3, &93, &13, &E2, &EE, "GOIDS OFF ", &B3, "R A"
 EQUS "SS ", &D9, "T ", &F0, " DEEP SPA", &E9, " F", &FD, " ", &EF, "NY YE", &EE, "S ", &E3, "W. ", &13, "WEL"
 EQUS "L ", &93, "S", &DB, "UA", &FB, &DF, " HAS CH", &FF, "G", &FC, &CC, &D9, "R BOYS ", &EE, "E ", &F2
 EQUS "ADY F", &FD, &D0, "P", &EC, "H RIGHT", &C9, &93, "HOME SY", &DE, "EM OF ", &E2, "O", &DA, " MO"
 EQUS &E2, &F4, "S", &CC, &18, &09, &1D, "I", &0D, " HA", &FA, " OBTA", &F0, &C4, &93, "DEF", &F6, &E9, " P", &F9
 EQUS "NS F", &FD, " ", &E2, "EIR ", &13, "HI", &FA, " ", &13, "W", &FD, "LDS", &CC, &93, &F7, &DD, &E5, "S K", &E3
 EQUS "W WE'", &FA, " GOT ", &EB, "ME", &E2, &C3, "BUT ", &E3, "T WH", &F5, &CC, "IF ", &13, "I T", &F8, "N"
 EQUS "SM", &DB, " ", &93, "P", &F9, "NS", &C9, &D9, "R BA", &DA, " ", &DF, " ", &13, &EA, &F2, &F8, " ", &E2, "EY'L"
 EQUS "L ", &F0, "T", &F4, &E9, "PT ", &93, "TR", &FF, "SMISSI", &DF, ". ", &13, "I NE", &FC, &D0, &CF, &C9
 EQUS &EF, "KE ", &93, "RUN", &CC, &B3, "'", &F2, " E", &E5, "CT", &FC, &CC, &93, "P", &F9, "NS A", &F2, " "
 EQUS "UNIPUL", &DA, " COD", &C4, "WI", &E2, &F0, " ", &94, "TR", &FF, "SMISSI", &DF, &CC, &08, &B3, " "
 EQUS "W", &DC, "L ", &F7, " PAID", &CC, "    ", &13, "GOOD LUCK ", &9A, &D4, &18
 EQUB &00
 EQUS &19, &09, &1D, &08, &0E, &0D, &13, "WELL D", &DF, "E ", &9A, &CC, &B3, " HA", &FA, " ", &DA, "RV", &C4, &EC, " "
 EQUS "WELL", &B2, "WE SH", &E4, "L ", &F2, "MEMB", &F4, &CC, "WE ", &F1, "D ", &E3, "T EXPECT ", &93
 EQUS &13, &E2, &EE, "GOIDS", &C9, "F", &F0, "D ", &D9, "T ", &D8, &D9, "T ", &B3, &CC, "F", &FD, " ", &93, "MOM", &F6
 EQUS "T P", &E5, "A", &DA, " AC", &E9, "PT ", &94, &13, "NAVY ", &06, "r", &05, " AS PAYM", &F6, "T", &D4, &18
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

.l_5338

 EQUB &00

.RUPLA

 EQUB &D3, &96, &24, &1C, &FD, &4F, &35, &76, &64, &20, &44, &A4
 EQUB &DC, &6A, &10, &A2, &03, &6B, &1A, &C0, &B8, &05, &65, &C1

 EQUB &29

.RUGAL

 EQUB &80, &00, &00, &00, &01, &01, &01, &01, &82, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01, &01, &01, &01, &02
 EQUB &01, &82

.RUTOK

 EQUB &00
 EQUS &93, "CO", &E0, "NI", &DE, "S HE", &F2, " HA", &FA, " VIOL", &F5, &FC, &02, " ", &F0, "T", &F4, "G", &E4
 EQUS "AC", &FB, "C C", &E0, "N", &C3, "PROTOCOL", &0D, &B2, "SH", &D9, "LD ", &F7, " AVOID", &FC
 EQUB &00
 EQUS &93, "C", &DF, &DE, "RICT", &FD, " ", &CB, &F2, &ED, &F1, &E9, ", ", &9A
 EQUB &00
 EQUS "A r ", &E0, "OK", &C3, &CF, " ", &E5, "FT HE", &F2, &D0, "WHI", &E5, " BACK. ", &E0, "OK", &C4, "B", &D9
 EQUS "ND F", &FD, " ", &EE, "E", &E6
 EQUB &00
 EQUS "YEP,", &D0, "r", &D2, &CF, " HAD", &D0, "G", &E4, "AC", &FB, "C HYP", &F4, "DRI", &FA, " F", &DB, "T", &C4
 EQUS "HE", &F2, ". ", &EC, &C4, &DB, " TOO"
 EQUB &00
 EQUS &94, " r ", &CF, " DEHYP", &C4, "HE", &F2, " FROM ", &E3, "WHE", &F2, ", SUN SKIMM", &FC
 EQUS &B2, "JUMP", &FC, ". I HE", &EE, " ", &DB, " W", &F6, "T", &C9, &F0, &EA, &F7
 EQUB &00
 EQUS "s ", &CF, " W", &F6, "T F", &FD, " ME ", &F5, " A", &EC, &EE, ". MY ", &F9, "S", &F4, "S ", &F1, "DN'T E"
 EQUS "V", &F6, " SC", &F8, "TCH ", &93, "s"
 EQUB &00
 EQUS "OH DE", &EE, " ME Y", &ED, ".", &D0, "FRIGHTFUL ROGUE WI", &E2, " WH", &F5, " I ", &F7
 EQUS "LIE", &FA, " ", &B3, " PEOP", &E5, " C", &E4, "L", &D0, &E5, "AD PO", &DE, &F4, "I", &FD, " SHOT UP"
 EQUS " ", &E0, "TS OF ", &E2, "O", &DA, " ", &F7, "A", &DE, "LY PI", &F8, "T", &ED, &B2, "W", &F6, "T", &C9, &EC, &E5
 EQUS "RI"
 EQUB &00
 EQUS &B3, " C", &FF, " TACK", &E5, " ", &93, "h s IF ", &B3, " LIKE. HE'S ", &F5, " ", &FD, &EE
 EQUS &F8
 EQUB &00
 EQUS &01, "COM", &C3, &EB, &DF, ": EL", &DB, "E III"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "t"
 EQUB &00
 EQUS "BOY A", &F2, " ", &B3, " ", &F0, " ", &93, "WR", &DF, "G G", &E4, "AXY!"
 EQUB &00
 EQUS &E2, &F4, "E'S", &D0, &F2, &E4, " s PI", &F8, "TE ", &D9, "T ", &E2, &F4, "E"
 EQUB &00
 EQUS &93, &C1, "S OF m A", &F2, " ", &EB, " A", &EF, "Z", &F0, "GLY PRIMI", &FB, &FA, " ", &E2, &F5
 EQUS " ", &E2, "EY ", &DE, &DC, "L ", &E2, &F0, "K ", &13, "EL", &DB, "E", &CA, "A P", &F2, "TTY NE", &F5, " GAME"
 EQUB &00

.MTIN

 EQUB &10, &15, &1A, &1F, &9B, &A0, &2E, &A5, &24, &29, &3D, &33
 EQUB &38, &AA, &42, &47, &4C, &51, &56, &8C, &60, &65, &87, &82
 EQUB &5B, &6A, &B4, &B9, &BE, &E1, &E6, &EB, &F0, &F5, &FA, &73
 EQUB &78, &7D

\SAVE "output/tcode.bin", CODE%, P%, LOAD%

IF _RELEASED
 INCBIN "extracted/released/workspaces/1.D.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/workspaces/1.D.bin"
ENDIF

ORG &5600

.XX21

IF _RELEASED
 INCBIN "extracted/released/S.T.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/S.T.bin"
ENDIF

\ ******************************************************************************
\
\ Save output/1.D.bin
\
\ ******************************************************************************

PRINT "S.1.D ", ~CODE%, " &6000 ", ~LOAD%, " ", ~LOAD%
SAVE "output/1.D.bin", CODE%, &6000