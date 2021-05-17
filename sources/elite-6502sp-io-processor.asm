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

.LSY2

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

                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
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

CODE% = &1200
LOAD% = &1200

ORG CODE%

LOAD_A% = LOAD%

 \ a.qelite - tube elite startup file

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