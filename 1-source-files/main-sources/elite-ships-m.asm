\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE M
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
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file contains ship blueprints for Elite-A.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * S.M.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _RELEASED              = (_VARIANT = 1)
 _SOURCE_DISC           = (_VARIANT = 2)
 _BUG_FIX               = (_VARIANT = 3)

 GUARD &6000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE% = &5600          \ The flight code runs this file at address &5600, at
                        \ label XX21

 LOAD% = &5600          \ The flight code loads this file at address &5600, at
                        \ label XX21

 SHIP_MISSILE = &7F00   \ The address of the missile ship blueprint

 ORG CODE%

\ ******************************************************************************
\
\       Name: XX21
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints lookup table for the S.M file
\  Deep dive: Ship blueprints in Elite-A
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile                            Missile
 EQUW SHIP_CORIOLIS     \ SST  =  2 = Coriolis space station             Station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod                      Escape pod
 EQUW SHIP_PLATE        \ PLT  =  4 = Alloy plate                          Cargo
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister                       Cargo
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                Shuttle
 EQUW 0                 \                                            Transporter
 EQUW 0                 \                                                 Trader
 EQUW SHIP_OPHIDIAN     \        12 = Ophidian                            Trader
 EQUW SHIP_FER_DE_LANCE \        13 = Fer-de-lance                        Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_MAMBA        \        17 = Mamba                               Pirate
 EQUW SHIP_COBRA_MK_1   \        18 = Cobra Mk I                          Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_BUSHMASTER   \        20 = Bushmaster                          Pirate
 EQUW SHIP_OPHIDIAN     \        21 = Ophidian                            Pirate
 EQUW SHIP_CHAMELEON    \        22 = Chameleon                           Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_FER_DE_LANCE \        24 = Fer-de-lance                        Pirate
 EQUW SHIP_FER_DE_LANCE \        25 = Fer-de-lance                 Bounty hunter
 EQUW SHIP_BUSHMASTER   \        26 = Bushmaster                   Bounty hunter
 EQUW SHIP_COBRA_MK_1   \        27 = Cobra Mk I                   Bounty hunter
 EQUW SHIP_MAMBA        \        28 = Mamba                        Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.M file
\  Deep dive: Ship blueprints in Elite-A
\             Advanced tactics with the NEWB flags
\
\ ******************************************************************************

.E%

 EQUB %00000000         \ Missile
 EQUB %01000000         \ Coriolis space station                             Cop
 EQUB %01000001         \ Escape pod                                 Trader, cop
 EQUB %00000000         \ Alloy plate
 EQUB %00000000         \ Cargo canister
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10100001         \ Ophidian                  Trader, innocent, escape pod
 EQUB %10100000         \ Fer-de-lance                      Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Mamba                      Hostile, pirate, escape pod
 EQUB %10001100         \ Cobra Mk I                 Hostile, pirate, escape pod
 EQUB 0
 EQUB %10001100         \ Bushmaster                 Hostile, pirate, escape pod
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB %10001100         \ Chameleon                  Hostile, pirate, escape pod
 EQUB 0
 EQUB %10001100         \ Fer-de-lance               Hostile, pirate, escape pod
 EQUB %10000010         \ Fer-de-lance                 Bounty hunter, escape pod
 EQUB %10100010         \ Bushmaster         Bounty hunter, innocent, escape pod
 EQUB %10000010         \ Cobra Mk I                   Bounty hunter, escape pod
 EQUB %10100010         \ Mamba              Bounty hunter, innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB 0

\ ******************************************************************************
\
\       Name: VERTEX
\       Type: Macro
\   Category: Drawing ships
\    Summary: Macro definition for adding vertices to ship blueprints
\  Deep dive: Ship blueprints
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to build the ship blueprints:
\
\   VERTEX x, y, z, face1, face2, face3, face4, visibility
\
\ See the deep dive on "Ship blueprints" for details of how vertices are stored
\ in the ship blueprints, and the deep dive on "Drawing ships" for information
\ on how vertices are used to draw 3D wireframe ships.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   x                   The vertex's x-coordinate
\
\   y                   The vertex's y-coordinate
\
\   z                   The vertex's z-coordinate
\
\   face1               The number of face 1 associated with this vertex
\
\   face2               The number of face 2 associated with this vertex
\
\   face3               The number of face 3 associated with this vertex
\
\   face4               The number of face 4 associated with this vertex
\
\   visibility          The visibility distance, beyond which the vertex is not
\                       shown
\
\ ******************************************************************************

MACRO VERTEX x, y, z, face1, face2, face3, face4, visibility

 IF x < 0
  s_x = 1 << 7
 ELSE
  s_x = 0
 ENDIF

 IF y < 0
  s_y = 1 << 6
 ELSE
  s_y = 0
 ENDIF

 IF z < 0
  s_z = 1 << 5
 ELSE
  s_z = 0
 ENDIF

 s = s_x + s_y + s_z + visibility
 f1 = face1 + (face2 << 4)
 f2 = face3 + (face4 << 4)
 ax = ABS(x)
 ay = ABS(y)
 az = ABS(z)

 EQUB ax, ay, az, s, f1, f2

ENDMACRO

\ ******************************************************************************
\
\       Name: EDGE
\       Type: Macro
\   Category: Drawing ships
\    Summary: Macro definition for adding edges to ship blueprints
\  Deep dive: Ship blueprints
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to build the ship blueprints:
\
\   EDGE vertex1, vertex2, face1, face2, visibility
\
\ See the deep dive on "Ship blueprints" for details of how edges are stored
\ in the ship blueprints, and the deep dive on "Drawing ships" for information
\ on how edges are used to draw 3D wireframe ships.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   vertex1             The number of the vertex at the start of the edge
\
\   vertex1             The number of the vertex at the end of the edge
\
\   face1               The number of face 1 associated with this edge
\
\   face2               The number of face 2 associated with this edge
\
\   visibility          The visibility distance, beyond which the edge is not
\                       shown
\
\ ******************************************************************************

MACRO EDGE vertex1, vertex2, face1, face2, visibility

 f = face1 + (face2 << 4)
 EQUB visibility, f, vertex1 << 2, vertex2 << 2

ENDMACRO

\ ******************************************************************************
\
\       Name: FACE
\       Type: Macro
\   Category: Drawing ships
\    Summary: Macro definition for adding faces to ship blueprints
\  Deep dive: Ship blueprints
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to build the ship blueprints:
\
\   FACE normal_x, normal_y, normal_z, visibility
\
\ See the deep dive on "Ship blueprints" for details of how faces are stored
\ in the ship blueprints, and the deep dive on "Drawing ships" for information
\ on how faces are used to draw 3D wireframe ships.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   normal_x            The face normal's x-coordinate
\
\   normal_y            The face normal's y-coordinate
\
\   normal_z            The face normal's z-coordinate
\
\   visibility          The visibility distance, beyond which the edge is always
\                       shown
\
\ ******************************************************************************

MACRO FACE normal_x, normal_y, normal_z, visibility

 IF normal_x < 0
  s_x = 1 << 7
 ELSE
  s_x = 0
 ENDIF

 IF normal_y < 0
  s_y = 1 << 6
 ELSE
  s_y = 0
 ENDIF

 IF normal_z < 0
  s_z = 1 << 5
 ELSE
  s_z = 0
 ENDIF

 s = s_x + s_y + s_z + visibility
 ax = ABS(normal_x)
 ay = ABS(normal_y)
 az = ABS(normal_z)

 EQUB s, ax, ay, az

ENDMACRO

\ ******************************************************************************
\
\       Name: SHIP_CORIOLIS
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Coriolis space station
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_CORIOLIS

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 160 * 160         \ Targetable area          = 160 * 160

 EQUB LO(SHIP_CORIOLIS_EDGES - SHIP_CORIOLIS)      \ Edges data offset (low)
 EQUB LO(SHIP_CORIOLIS_FACES - SHIP_CORIOLIS)      \ Faces data offset (low)

 EQUB 85                \ Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 \ Gun vertex               = 0
 EQUB 54                \ Explosion count          = 12, as (4 * n) + 6 = 54
 EQUB 96                \ Number of vertices       = 96 / 6 = 16
 EQUB 28                \ Number of edges          = 28
 EQUW 0                 \ Bounty                   = 0
 EQUB 56                \ Number of faces          = 56 / 4 = 14
 EQUB 120               \ Visibility distance      = 120
 EQUB 240               \ Max. energy              = 240
 EQUB 0                 \ Max. speed               = 0

 EQUB HI(SHIP_CORIOLIS_EDGES - SHIP_CORIOLIS)      \ Edges data offset (high)
 EQUB HI(SHIP_CORIOLIS_FACES - SHIP_CORIOLIS)      \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00000110         \ Laser power              = 0
                        \ Missiles                 = 6

.SHIP_CORIOLIS_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  160,    0,  160,     0,      1,    2,     6,         31    \ Vertex 0
 VERTEX    0,  160,  160,     0,      2,    3,     8,         31    \ Vertex 1
 VERTEX -160,    0,  160,     0,      3,    4,     7,         31    \ Vertex 2
 VERTEX    0, -160,  160,     0,      1,    4,     5,         31    \ Vertex 3
 VERTEX  160, -160,    0,     1,      5,    6,    10,         31    \ Vertex 4
 VERTEX  160,  160,    0,     2,      6,    8,    11,         31    \ Vertex 5
 VERTEX -160,  160,    0,     3,      7,    8,    12,         31    \ Vertex 6
 VERTEX -160, -160,    0,     4,      5,    7,     9,         31    \ Vertex 7
 VERTEX  160,    0, -160,     6,     10,   11,    13,         31    \ Vertex 8
 VERTEX    0,  160, -160,     8,     11,   12,    13,         31    \ Vertex 9
 VERTEX -160,    0, -160,     7,      9,   12,    13,         31    \ Vertex 10
 VERTEX    0, -160, -160,     5,      9,   10,    13,         31    \ Vertex 11
 VERTEX   10,  -30,  160,     0,      0,    0,     0,         30    \ Vertex 12
 VERTEX   10,   30,  160,     0,      0,    0,     0,         30    \ Vertex 13
 VERTEX  -10,   30,  160,     0,      0,    0,     0,         30    \ Vertex 14
 VERTEX  -10,  -30,  160,     0,      0,    0,     0,         30    \ Vertex 15

.SHIP_CORIOLIS_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       3,     0,     1,         31    \ Edge 0
 EDGE       0,       1,     0,     2,         31    \ Edge 1
 EDGE       1,       2,     0,     3,         31    \ Edge 2
 EDGE       2,       3,     0,     4,         31    \ Edge 3
 EDGE       3,       4,     1,     5,         31    \ Edge 4
 EDGE       0,       4,     1,     6,         31    \ Edge 5
 EDGE       0,       5,     2,     6,         31    \ Edge 6
 EDGE       5,       1,     2,     8,         31    \ Edge 7
 EDGE       1,       6,     3,     8,         31    \ Edge 8
 EDGE       2,       6,     3,     7,         31    \ Edge 9
 EDGE       2,       7,     4,     7,         31    \ Edge 10
 EDGE       3,       7,     4,     5,         31    \ Edge 11
 EDGE       8,      11,    10,    13,         31    \ Edge 12
 EDGE       8,       9,    11,    13,         31    \ Edge 13
 EDGE       9,      10,    12,    13,         31    \ Edge 14
 EDGE      10,      11,     9,    13,         31    \ Edge 15
 EDGE       4,      11,     5,    10,         31    \ Edge 16
 EDGE       4,       8,     6,    10,         31    \ Edge 17
 EDGE       5,       8,     6,    11,         31    \ Edge 18
 EDGE       5,       9,     8,    11,         31    \ Edge 19
 EDGE       6,       9,     8,    12,         31    \ Edge 20
 EDGE       6,      10,     7,    12,         31    \ Edge 21
 EDGE       7,      10,     7,     9,         31    \ Edge 22
 EDGE       7,      11,     5,     9,         31    \ Edge 23
 EDGE      12,      13,     0,     0,         30    \ Edge 24
 EDGE      13,      14,     0,     0,         30    \ Edge 25
 EDGE      14,      15,     0,     0,         30    \ Edge 26
 EDGE      15,      12,     0,     0,         30    \ Edge 27

.SHIP_CORIOLIS_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,        0,      160,         31      \ Face 0
 FACE      107,     -107,      107,         31      \ Face 1
 FACE      107,      107,      107,         31      \ Face 2
 FACE     -107,      107,      107,         31      \ Face 3
 FACE     -107,     -107,      107,         31      \ Face 4
 FACE        0,     -160,        0,         31      \ Face 5
 FACE      160,        0,        0,         31      \ Face 6
 FACE     -160,        0,        0,         31      \ Face 7
 FACE        0,      160,        0,         31      \ Face 8
 FACE     -107,     -107,     -107,         31      \ Face 9
 FACE      107,     -107,     -107,         31      \ Face 10
 FACE      107,      107,     -107,         31      \ Face 11
 FACE     -107,      107,     -107,         31      \ Face 12
 FACE        0,        0,     -160,         31      \ Face 13

\ ******************************************************************************
\
\       Name: SHIP_ESCAPE_POD
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an escape pod
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_ESCAPE_POD

 EQUB 0 + (2 << 4)      \ Max. canisters on demise = 0
                        \ Market item when scooped = 2 + 1 = 3 (slaves)
 EQUW 16 * 16           \ Targetable area          = 16 * 16

 EQUB LO(SHIP_ESCAPE_POD_EDGES - SHIP_ESCAPE_POD)  \ Edges data offset (low)
 EQUB LO(SHIP_ESCAPE_POD_FACES - SHIP_ESCAPE_POD)  \ Faces data offset (low)

 EQUB 25                \ Max. edge count          = (25 - 1) / 4 = 6
 EQUB 0                 \ Gun vertex               = 0
 EQUB 22                \ Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 24                \ Number of vertices       = 24 / 6 = 4
 EQUB 6                 \ Number of edges          = 6
 EQUW 0                 \ Bounty                   = 0
 EQUB 16                \ Number of faces          = 16 / 4 = 4
 EQUB 8                 \ Visibility distance      = 8

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 17                \ Max. energy              = 17

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

 EQUB 8                 \ Max. speed               = 8

 EQUB HI(SHIP_ESCAPE_POD_EDGES - SHIP_ESCAPE_POD)  \ Edges data offset (high)
 EQUB HI(SHIP_ESCAPE_POD_FACES - SHIP_ESCAPE_POD)  \ Faces data offset (high)

 EQUB 4                 \ Normals are scaled by    =  2^4 = 16
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_ESCAPE_POD_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   -7,    0,   36,     2,      1,    3,     3,         31    \ Vertex 0
 VERTEX   -7,  -14,  -12,     2,      0,    3,     3,         31    \ Vertex 1
 VERTEX   -7,   14,  -12,     1,      0,    3,     3,         31    \ Vertex 2
 VERTEX   21,    0,    0,     1,      0,    2,     2,         31    \ Vertex 3

.SHIP_ESCAPE_POD_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     2,         31    \ Edge 0
 EDGE       1,       2,     3,     0,         31    \ Edge 1
 EDGE       2,       3,     1,     0,         31    \ Edge 2
 EDGE       3,       0,     2,     1,         31    \ Edge 3
 EDGE       0,       2,     3,     1,         31    \ Edge 4
 EDGE       3,       1,     2,     0,         31    \ Edge 5

.SHIP_ESCAPE_POD_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE       52,        0,     -122,         31      \ Face 0
 FACE       39,      103,       30,         31      \ Face 1
 FACE       39,     -103,       30,         31      \ Face 2
 FACE     -112,        0,        0,         31      \ Face 3

\ ******************************************************************************
\
\       Name: SHIP_CANISTER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a cargo canister
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_CANISTER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 20 * 20           \ Targetable area          = 20 * 20

 EQUB LO(SHIP_CANISTER_EDGES - SHIP_CANISTER)      \ Edges data offset (low)
 EQUB LO(SHIP_CANISTER_FACES - SHIP_CANISTER)      \ Faces data offset (low)

 EQUB 49                \ Max. edge count          = (49 - 1) / 4 = 12
 EQUB 0                 \ Gun vertex               = 0
 EQUB 18                \ Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                \ Number of vertices       = 60 / 6 = 10
 EQUB 15                \ Number of edges          = 15

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUW 0                 \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 12                \ Visibility distance      = 12

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 17                \ Max. energy              = 17

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

 EQUB 15                \ Max. speed               = 15

 EQUB HI(SHIP_CANISTER_EDGES - SHIP_CANISTER)      \ Edges data offset (high)
 EQUB HI(SHIP_CANISTER_FACES - SHIP_CANISTER)      \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_CANISTER_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   24,   16,    0,     0,      1,    5,     5,         31    \ Vertex 0
 VERTEX   24,    5,   15,     0,      1,    2,     2,         31    \ Vertex 1
 VERTEX   24,  -13,    9,     0,      2,    3,     3,         31    \ Vertex 2
 VERTEX   24,  -13,   -9,     0,      3,    4,     4,         31    \ Vertex 3
 VERTEX   24,    5,  -15,     0,      4,    5,     5,         31    \ Vertex 4
 VERTEX  -24,   16,    0,     1,      5,    6,     6,         31    \ Vertex 5
 VERTEX  -24,    5,   15,     1,      2,    6,     6,         31    \ Vertex 6
 VERTEX  -24,  -13,    9,     2,      3,    6,     6,         31    \ Vertex 7
 VERTEX  -24,  -13,   -9,     3,      4,    6,     6,         31    \ Vertex 8
 VERTEX  -24,    5,  -15,     4,      5,    6,     6,         31    \ Vertex 9

.SHIP_CANISTER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     1,         31    \ Edge 0
 EDGE       1,       2,     0,     2,         31    \ Edge 1
 EDGE       2,       3,     0,     3,         31    \ Edge 2
 EDGE       3,       4,     0,     4,         31    \ Edge 3
 EDGE       0,       4,     0,     5,         31    \ Edge 4
 EDGE       0,       5,     1,     5,         31    \ Edge 5
 EDGE       1,       6,     1,     2,         31    \ Edge 6
 EDGE       2,       7,     2,     3,         31    \ Edge 7
 EDGE       3,       8,     3,     4,         31    \ Edge 8
 EDGE       4,       9,     4,     5,         31    \ Edge 9
 EDGE       5,       6,     1,     6,         31    \ Edge 10
 EDGE       6,       7,     2,     6,         31    \ Edge 11
 EDGE       7,       8,     3,     6,         31    \ Edge 12
 EDGE       8,       9,     4,     6,         31    \ Edge 13
 EDGE       9,       5,     5,     6,         31    \ Edge 14

.SHIP_CANISTER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE       96,        0,        0,         31      \ Face 0
 FACE        0,       41,       30,         31      \ Face 1
 FACE        0,      -18,       48,         31      \ Face 2
 FACE        0,      -51,        0,         31      \ Face 3
 FACE        0,      -18,      -48,         31      \ Face 4
 FACE        0,       41,      -30,         31      \ Face 5
 FACE      -96,        0,        0,         31      \ Face 6

\ ******************************************************************************
\
\       Name: SHIP_VIPER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Viper
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_VIPER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 75 * 75           \ Targetable area          = 75 * 75

 EQUB LO(SHIP_VIPER_EDGES - SHIP_VIPER)            \ Edges data offset (low)
 EQUB LO(SHIP_VIPER_FACES - SHIP_VIPER)            \ Faces data offset (low)

 EQUB 77                \ Max. edge count          = (77 - 1) / 4 = 19
 EQUB 0                 \ Gun vertex               = 0
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 90                \ Number of vertices       = 90 / 6 = 15
 EQUB 20                \ Number of edges          = 20
 EQUW 0                 \ Bounty                   = 0
 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 23                \ Visibility distance      = 23

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 100               \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 91                \ Max. energy              = 91

                        \ --- End of replacement ------------------------------>

 EQUB 32                \ Max. speed               = 32

 EQUB HI(SHIP_VIPER_EDGES - SHIP_VIPER)            \ Edges data offset (high)
 EQUB HI(SHIP_VIPER_FACES - SHIP_VIPER)            \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010001         \ Laser power              = 2
\                       \ Missiles                 = 1

                        \ --- And replaced by: -------------------------------->

 EQUB %00101001         \ Laser power              = 5
                        \ Missiles                 = 1

                        \ --- End of replacement ------------------------------>

.SHIP_VIPER_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   72,     1,      2,    3,     4,         31    \ Vertex 0
 VERTEX    0,   16,   24,     0,      1,    2,     2,         30    \ Vertex 1
 VERTEX    0,  -16,   24,     3,      4,    5,     5,         30    \ Vertex 2
 VERTEX   48,    0,  -24,     2,      4,    6,     6,         31    \ Vertex 3
 VERTEX  -48,    0,  -24,     1,      3,    6,     6,         31    \ Vertex 4
 VERTEX   24,  -16,  -24,     4,      5,    6,     6,         30    \ Vertex 5
 VERTEX  -24,  -16,  -24,     5,      3,    6,     6,         30    \ Vertex 6
 VERTEX   24,   16,  -24,     0,      2,    6,     6,         31    \ Vertex 7
 VERTEX  -24,   16,  -24,     0,      1,    6,     6,         31    \ Vertex 8
 VERTEX  -32,    0,  -24,     6,      6,    6,     6,         19    \ Vertex 9
 VERTEX   32,    0,  -24,     6,      6,    6,     6,         19    \ Vertex 10
 VERTEX    8,    8,  -24,     6,      6,    6,     6,         19    \ Vertex 11
 VERTEX   -8,    8,  -24,     6,      6,    6,     6,         19    \ Vertex 12
 VERTEX   -8,   -8,  -24,     6,      6,    6,     6,         18    \ Vertex 13
 VERTEX    8,   -8,  -24,     6,      6,    6,     6,         18    \ Vertex 14

.SHIP_VIPER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       3,     2,     4,         31    \ Edge 0
 EDGE       0,       1,     1,     2,         30    \ Edge 1
 EDGE       0,       2,     3,     4,         30    \ Edge 2
 EDGE       0,       4,     1,     3,         31    \ Edge 3
 EDGE       1,       7,     0,     2,         30    \ Edge 4
 EDGE       1,       8,     0,     1,         30    \ Edge 5
 EDGE       2,       5,     4,     5,         30    \ Edge 6
 EDGE       2,       6,     3,     5,         30    \ Edge 7
 EDGE       7,       8,     0,     6,         31    \ Edge 8
 EDGE       5,       6,     5,     6,         30    \ Edge 9
 EDGE       4,       8,     1,     6,         31    \ Edge 10
 EDGE       4,       6,     3,     6,         30    \ Edge 11
 EDGE       3,       7,     2,     6,         31    \ Edge 12
 EDGE       3,       5,     6,     4,         30    \ Edge 13
 EDGE       9,      12,     6,     6,         19    \ Edge 14
 EDGE       9,      13,     6,     6,         18    \ Edge 15
 EDGE      10,      11,     6,     6,         19    \ Edge 16
 EDGE      10,      14,     6,     6,         18    \ Edge 17
 EDGE      11,      14,     6,     6,         16    \ Edge 18
 EDGE      12,      13,     6,     6,         16    \ Edge 19

.SHIP_VIPER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        0,         31      \ Face 0
 FACE      -22,       33,       11,         31      \ Face 1
 FACE       22,       33,       11,         31      \ Face 2
 FACE      -22,      -33,       11,         31      \ Face 3
 FACE       22,      -33,       11,         31      \ Face 4
 FACE        0,      -32,        0,         31      \ Face 5
 FACE        0,        0,      -48,         31      \ Face 6

\ ******************************************************************************
\
\       Name: SHIP_MAMBA
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Mamba
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_MAMBA

 EQUB 1                 \ Max. canisters on demise = 1
 EQUW 70 * 70           \ Targetable area          = 70 * 70

 EQUB LO(SHIP_MAMBA_EDGES - SHIP_MAMBA)            \ Edges data offset (low)
 EQUB LO(SHIP_MAMBA_FACES - SHIP_MAMBA)            \ Faces data offset (low)

 EQUB 93                \ Max. edge count          = (93 - 1) / 4 = 23
 EQUB 0                 \ Gun vertex               = 0
 EQUB 34                \ Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 150               \ Number of vertices       = 150 / 6 = 25
 EQUB 28                \ Number of edges          = 28
 EQUW 150               \ Bounty                   = 150
 EQUB 20                \ Number of faces          = 20 / 4 = 5
 EQUB 25                \ Visibility distance      = 25

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 90                \ Max. energy              = 90

                        \ --- And replaced by: -------------------------------->

 EQUB 80                \ Max. energy              = 80

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_MAMBA_EDGES - SHIP_MAMBA)            \ Edges data offset (high)
 EQUB HI(SHIP_MAMBA_FACES - SHIP_MAMBA)            \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010010         \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00100010         \ Laser power              = 4
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

.SHIP_MAMBA_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   64,     0,      1,    2,     3,         31    \ Vertex 0
 VERTEX  -64,   -8,  -32,     0,      2,    4,     4,         31    \ Vertex 1
 VERTEX  -32,    8,  -32,     1,      2,    4,     4,         30    \ Vertex 2
 VERTEX   32,    8,  -32,     1,      3,    4,     4,         30    \ Vertex 3
 VERTEX   64,   -8,  -32,     0,      3,    4,     4,         31    \ Vertex 4
 VERTEX   -4,    4,   16,     1,      1,    1,     1,         14    \ Vertex 5
 VERTEX    4,    4,   16,     1,      1,    1,     1,         14    \ Vertex 6
 VERTEX    8,    3,   28,     1,      1,    1,     1,         13    \ Vertex 7
 VERTEX   -8,    3,   28,     1,      1,    1,     1,         13    \ Vertex 8
 VERTEX  -20,   -4,   16,     0,      0,    0,     0,         20    \ Vertex 9
 VERTEX   20,   -4,   16,     0,      0,    0,     0,         20    \ Vertex 10
 VERTEX  -24,   -7,  -20,     0,      0,    0,     0,         20    \ Vertex 11
 VERTEX  -16,   -7,  -20,     0,      0,    0,     0,         16    \ Vertex 12
 VERTEX   16,   -7,  -20,     0,      0,    0,     0,         16    \ Vertex 13
 VERTEX   24,   -7,  -20,     0,      0,    0,     0,         20    \ Vertex 14
 VERTEX   -8,    4,  -32,     4,      4,    4,     4,         13    \ Vertex 15
 VERTEX    8,    4,  -32,     4,      4,    4,     4,         13    \ Vertex 16
 VERTEX    8,   -4,  -32,     4,      4,    4,     4,         14    \ Vertex 17
 VERTEX   -8,   -4,  -32,     4,      4,    4,     4,         14    \ Vertex 18
 VERTEX  -32,    4,  -32,     4,      4,    4,     4,          7    \ Vertex 19
 VERTEX   32,    4,  -32,     4,      4,    4,     4,          7    \ Vertex 20
 VERTEX   36,   -4,  -32,     4,      4,    4,     4,          7    \ Vertex 21
 VERTEX  -36,   -4,  -32,     4,      4,    4,     4,          7    \ Vertex 22
 VERTEX  -38,    0,  -32,     4,      4,    4,     4,          5    \ Vertex 23
 VERTEX   38,    0,  -32,     4,      4,    4,     4,          5    \ Vertex 24

.SHIP_MAMBA_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     2,         31    \ Edge 0
 EDGE       0,       4,     0,     3,         31    \ Edge 1
 EDGE       1,       4,     0,     4,         31    \ Edge 2
 EDGE       1,       2,     2,     4,         30    \ Edge 3
 EDGE       2,       3,     1,     4,         30    \ Edge 4
 EDGE       3,       4,     3,     4,         30    \ Edge 5
 EDGE       5,       6,     1,     1,         14    \ Edge 6
 EDGE       6,       7,     1,     1,         12    \ Edge 7
 EDGE       7,       8,     1,     1,         13    \ Edge 8
 EDGE       5,       8,     1,     1,         12    \ Edge 9
 EDGE       9,      11,     0,     0,         20    \ Edge 10
 EDGE       9,      12,     0,     0,         16    \ Edge 11
 EDGE      10,      13,     0,     0,         16    \ Edge 12
 EDGE      10,      14,     0,     0,         20    \ Edge 13
 EDGE      13,      14,     0,     0,         14    \ Edge 14
 EDGE      11,      12,     0,     0,         14    \ Edge 15
 EDGE      15,      16,     4,     4,         13    \ Edge 16
 EDGE      17,      18,     4,     4,         14    \ Edge 17
 EDGE      15,      18,     4,     4,         12    \ Edge 18
 EDGE      16,      17,     4,     4,         12    \ Edge 19
 EDGE      20,      21,     4,     4,          7    \ Edge 20
 EDGE      20,      24,     4,     4,          5    \ Edge 21
 EDGE      21,      24,     4,     4,          5    \ Edge 22
 EDGE      19,      22,     4,     4,          7    \ Edge 23
 EDGE      19,      23,     4,     4,          5    \ Edge 24
 EDGE      22,      23,     4,     4,          5    \ Edge 25
 EDGE       0,       2,     1,     2,         30    \ Edge 26
 EDGE       0,       3,     1,     3,         30    \ Edge 27

.SHIP_MAMBA_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,      -24,        2,         30      \ Face 0
 FACE        0,       24,        2,         30      \ Face 1
 FACE      -32,       64,       16,         30      \ Face 2
 FACE       32,       64,       16,         30      \ Face 3
 FACE        0,        0,     -127,         30      \ Face 4

\ ******************************************************************************
\
\       Name: SHIP_FER_DE_LANCE
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Fer-de-Lance
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_FER_DE_LANCE

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 40 * 40           \ Targetable area          = 40 * 40

 EQUB LO(SHIP_FER_DE_LANCE_EDGES - SHIP_FER_DE_LANCE) \ Edges data offset (low)
 EQUB LO(SHIP_FER_DE_LANCE_FACES - SHIP_FER_DE_LANCE) \ Faces data offset (low)

 EQUB 105               \ Max. edge count          = (105 - 1) / 4 = 26
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 114               \ Number of vertices       = 114 / 6 = 19
 EQUB 27                \ Number of edges          = 27

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUW 0                 \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 250               \ Bounty                   = 250

                        \ --- End of replacement ------------------------------>

 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 160               \ Max. energy              = 160

                        \ --- And replaced by: -------------------------------->

 EQUB 83                \ Max. energy              = 83

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_FER_DE_LANCE_EDGES - SHIP_FER_DE_LANCE) \ Edges data offset (high)
 EQUB HI(SHIP_FER_DE_LANCE_FACES - SHIP_FER_DE_LANCE) \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010010         \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00110010         \ Laser power              = 6
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

.SHIP_FER_DE_LANCE_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -14,  108,     1,      0,    9,     5,         31    \ Vertex 0
 VERTEX  -40,  -14,   -4,     2,      1,    9,     9,         31    \ Vertex 1
 VERTEX  -12,  -14,  -52,     3,      2,    9,     9,         31    \ Vertex 2
 VERTEX   12,  -14,  -52,     4,      3,    9,     9,         31    \ Vertex 3
 VERTEX   40,  -14,   -4,     5,      4,    9,     9,         31    \ Vertex 4
 VERTEX  -40,   14,   -4,     1,      0,    6,     2,         28    \ Vertex 5
 VERTEX  -12,    2,  -52,     3,      2,    7,     6,         28    \ Vertex 6
 VERTEX   12,    2,  -52,     4,      3,    8,     7,         28    \ Vertex 7
 VERTEX   40,   14,   -4,     4,      0,    8,     5,         28    \ Vertex 8
 VERTEX    0,   18,  -20,     6,      0,    8,     7,         15    \ Vertex 9
 VERTEX   -3,  -11,   97,     0,      0,    0,     0,         11    \ Vertex 10
 VERTEX  -26,    8,   18,     0,      0,    0,     0,          9    \ Vertex 11
 VERTEX  -16,   14,   -4,     0,      0,    0,     0,         11    \ Vertex 12
 VERTEX    3,  -11,   97,     0,      0,    0,     0,         11    \ Vertex 13
 VERTEX   26,    8,   18,     0,      0,    0,     0,          9    \ Vertex 14
 VERTEX   16,   14,   -4,     0,      0,    0,     0,         11    \ Vertex 15
 VERTEX    0,  -14,  -20,     9,      9,    9,     9,         12    \ Vertex 16
 VERTEX  -14,  -14,   44,     9,      9,    9,     9,         12    \ Vertex 17
 VERTEX   14,  -14,   44,     9,      9,    9,     9,         12    \ Vertex 18

.SHIP_FER_DE_LANCE_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     9,     1,         31    \ Edge 0
 EDGE       1,       2,     9,     2,         31    \ Edge 1
 EDGE       2,       3,     9,     3,         31    \ Edge 2
 EDGE       3,       4,     9,     4,         31    \ Edge 3
 EDGE       0,       4,     9,     5,         31    \ Edge 4
 EDGE       0,       5,     1,     0,         28    \ Edge 5
 EDGE       5,       6,     6,     2,         28    \ Edge 6
 EDGE       6,       7,     7,     3,         28    \ Edge 7
 EDGE       7,       8,     8,     4,         28    \ Edge 8
 EDGE       0,       8,     5,     0,         28    \ Edge 9
 EDGE       5,       9,     6,     0,         15    \ Edge 10
 EDGE       6,       9,     7,     6,         11    \ Edge 11
 EDGE       7,       9,     8,     7,         11    \ Edge 12
 EDGE       8,       9,     8,     0,         15    \ Edge 13
 EDGE       1,       5,     2,     1,         14    \ Edge 14
 EDGE       2,       6,     3,     2,         14    \ Edge 15
 EDGE       3,       7,     4,     3,         14    \ Edge 16
 EDGE       4,       8,     5,     4,         14    \ Edge 17
 EDGE      10,      11,     0,     0,          8    \ Edge 18
 EDGE      11,      12,     0,     0,          9    \ Edge 19
 EDGE      10,      12,     0,     0,         11    \ Edge 20
 EDGE      13,      14,     0,     0,          8    \ Edge 21
 EDGE      14,      15,     0,     0,          9    \ Edge 22
 EDGE      13,      15,     0,     0,         11    \ Edge 23
 EDGE      16,      17,     9,     9,         12    \ Edge 24
 EDGE      16,      18,     9,     9,         12    \ Edge 25
 EDGE      17,      18,     9,     9,          8    \ Edge 26

.SHIP_FER_DE_LANCE_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       24,        6,         28      \ Face 0
 FACE      -68,        0,       24,         31      \ Face 1
 FACE      -63,        0,      -37,         31      \ Face 2
 FACE        0,        0,     -104,         31      \ Face 3
 FACE       63,        0,      -37,         31      \ Face 4
 FACE       68,        0,       24,         31      \ Face 5
 FACE      -12,       46,      -19,         28      \ Face 6
 FACE        0,       45,      -22,         28      \ Face 7
 FACE       12,       46,      -19,         28      \ Face 8
 FACE        0,      -28,        0,         31      \ Face 9

\ ******************************************************************************
\
\       Name: SHIP_COBRA_MK_1
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Cobra Mk I
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_COBRA_MK_1

 EQUB 3                 \ Max. canisters on demise = 3
 EQUW 99 * 99           \ Targetable area          = 99 * 99

 EQUB LO(SHIP_COBRA_MK_1_EDGES - SHIP_COBRA_MK_1)  \ Edges data offset (low)
 EQUB LO(SHIP_COBRA_MK_1_FACES - SHIP_COBRA_MK_1)  \ Faces data offset (low)

 EQUB 69                \ Max. edge count          = (69 - 1) / 4 = 17
 EQUB 40                \ Gun vertex               = 40 / 4 = 10
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 66                \ Number of vertices       = 66 / 6 = 11
 EQUB 18                \ Number of edges          = 18
 EQUW 75                \ Bounty                   = 75
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 19                \ Visibility distance      = 19

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 90                \ Max. energy              = 90

                        \ --- And replaced by: -------------------------------->

 EQUB 81                \ Max. energy              = 81

                        \ --- End of replacement ------------------------------>

 EQUB 26                \ Max. speed               = 26

 EQUB HI(SHIP_COBRA_MK_1_EDGES - SHIP_COBRA_MK_1)  \ Edges data offset (high)
 EQUB HI(SHIP_COBRA_MK_1_FACES - SHIP_COBRA_MK_1)  \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010010         \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00100010         \ Laser power              = 4
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

.SHIP_COBRA_MK_1_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,   -1,   50,     1,      0,    3,     2,         31    \ Vertex 0
 VERTEX   18,   -1,   50,     1,      0,    5,     4,         31    \ Vertex 1
 VERTEX  -66,    0,    7,     3,      2,    8,     8,         31    \ Vertex 2
 VERTEX   66,    0,    7,     5,      4,    9,     9,         31    \ Vertex 3
 VERTEX  -32,   12,  -38,     6,      2,    8,     7,         31    \ Vertex 4
 VERTEX   32,   12,  -38,     6,      4,    9,     7,         31    \ Vertex 5
 VERTEX  -54,  -12,  -38,     3,      1,    8,     7,         31    \ Vertex 6
 VERTEX   54,  -12,  -38,     5,      1,    9,     7,         31    \ Vertex 7
 VERTEX    0,   12,   -6,     2,      0,    6,     4,         20    \ Vertex 8
 VERTEX    0,   -1,   50,     1,      0,    1,     1,          2    \ Vertex 9
 VERTEX    0,   -1,   60,     1,      0,    1,     1,         31    \ Vertex 10

.SHIP_COBRA_MK_1_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       1,       0,     1,     0,         31    \ Edge 0
 EDGE       0,       2,     3,     2,         31    \ Edge 1
 EDGE       2,       6,     8,     3,         31    \ Edge 2
 EDGE       6,       7,     7,     1,         31    \ Edge 3
 EDGE       7,       3,     9,     5,         31    \ Edge 4
 EDGE       3,       1,     5,     4,         31    \ Edge 5
 EDGE       2,       4,     8,     2,         31    \ Edge 6
 EDGE       4,       5,     7,     6,         31    \ Edge 7
 EDGE       5,       3,     9,     4,         31    \ Edge 8
 EDGE       0,       8,     2,     0,         20    \ Edge 9
 EDGE       8,       1,     4,     0,         20    \ Edge 10
 EDGE       4,       8,     6,     2,         16    \ Edge 11
 EDGE       8,       5,     6,     4,         16    \ Edge 12
 EDGE       4,       6,     8,     7,         31    \ Edge 13
 EDGE       5,       7,     9,     7,         31    \ Edge 14
 EDGE       0,       6,     3,     1,         20    \ Edge 15
 EDGE       1,       7,     5,     1,         20    \ Edge 16
 EDGE      10,       9,     1,     0,          2    \ Edge 17

.SHIP_COBRA_MK_1_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       41,       10,         31      \ Face 0
 FACE        0,      -27,        3,         31      \ Face 1
 FACE       -8,       46,        8,         31      \ Face 2
 FACE      -12,      -57,       12,         31      \ Face 3
 FACE        8,       46,        8,         31      \ Face 4
 FACE       12,      -57,       12,         31      \ Face 5
 FACE        0,       49,        0,         31      \ Face 6
 FACE        0,        0,     -154,         31      \ Face 7
 FACE     -121,      111,      -62,         31      \ Face 8
 FACE      121,      111,      -62,         31      \ Face 9

\ ******************************************************************************
\
\       Name: SHIP_OPHIDIAN
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Ophidian
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_OPHIDIAN

 EQUB 2                 \ Max. canisters on demise = 2
 EQUW 3720              \ Targetable area          = 60.99 * 60.99

 EQUB LO(SHIP_OPHIDIAN_EDGES - SHIP_OPHIDIAN)      \ Edges data offset (low)
 EQUB LO(SHIP_OPHIDIAN_FACES - SHIP_OPHIDIAN)      \ Faces data offset (low)

 EQUB 113               \ Max. edge count          = (113 - 1) / 4 = 28
 EQUB 0                 \ Gun vertex               = 0
 EQUB 60                \ Explosion count          = 13, as (4 * n) + 6 = 60
 EQUB 120               \ Number of vertices       = 120 / 6 = 20
 EQUB 30                \ Number of edges          = 30
 EQUW 50                \ Bounty                   = 50
 EQUB 48                \ Number of faces          = 48 / 4 = 12
 EQUB 20                \ Visibility distance      = 20
 EQUB 64                \ Max. energy              = 64
 EQUB 34                \ Max. speed               = 34

 EQUB HI(SHIP_OPHIDIAN_EDGES - SHIP_OPHIDIAN)      \ Edges data offset (high)
 EQUB HI(SHIP_OPHIDIAN_FACES - SHIP_OPHIDIAN)      \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00011010         \ Laser power              = 3
                        \ Missiles                 = 2

.SHIP_OPHIDIAN_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -20,    0,   70,     8,     6,     2,     0,         31     \ Vertex 0
 VERTEX   20,    0,   70,     7,     6,     1,     0,         31     \ Vertex 1
 VERTEX    0,   10,   40,     2,     2,     1,     0,         31     \ Vertex 2
 VERTEX  -30,    0,   30,    10,     8,     4,     2,         31     \ Vertex 3
 VERTEX   30,    0,   30,     9,     7,     3,     1,         31     \ Vertex 4
 VERTEX    0,   16,   10,    15,    15,    15,    15,         31     \ Vertex 5
 VERTEX   20,   10,  -50,    11,     9,     5,     3,         31     \ Vertex 6
 VERTEX  -20,   10,  -50,    11,    10,     5,     4,         31     \ Vertex 7
 VERTEX  -30,    0,  -50,    11,    11,    10,     4,         31     \ Vertex 8
 VERTEX  -40,    0,  -50,    15,    15,    15,    15,         16     \ Vertex 9
 VERTEX  -30,    0,  -30,    15,    15,    15,    15,         16     \ Vertex 10
 VERTEX   30,    0,  -50,    11,    11,     9,     3,         31     \ Vertex 11
 VERTEX   40,    0,  -50,    15,    15,    15,    15,         16     \ Vertex 12
 VERTEX   30,    0,  -30,    15,    15,    15,    15,         16     \ Vertex 13
 VERTEX    0,  -10,  -50,    11,    11,    10,     9,         31     \ Vertex 14
 VERTEX    0,  -16,   20,    15,    15,    15,    15,         31     \ Vertex 15
 VERTEX   10,    4,  -50,    11,    11,    11,    11,         16     \ Vertex 16
 VERTEX   10,   -2,  -50,    11,    11,    11,    11,         16     \ Vertex 17
 VERTEX  -10,   -2,  -50,    11,    11,    11,    11,         16     \ Vertex 18
 VERTEX  -10,    4,  -50,    11,    11,    11,    11,         16     \ Vertex 19

.SHIP_OPHIDIAN_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     6,     0,         31    \ Edge 0
 EDGE       1,       2,     1,     0,         31    \ Edge 1
 EDGE       0,       2,     2,     0,         31    \ Edge 2
 EDGE       2,       5,     2,     1,         31    \ Edge 3
 EDGE       4,       5,     3,     1,         31    \ Edge 4
 EDGE       3,       5,     4,     2,         31    \ Edge 5
 EDGE       5,       6,     5,     3,         31    \ Edge 6
 EDGE       5,       7,     5,     4,         31    \ Edge 7
 EDGE       0,       3,     8,     2,         31    \ Edge 8
 EDGE       1,       4,     7,     1,         31    \ Edge 9
 EDGE       4,      11,     9,     3,         31    \ Edge 10
 EDGE       3,       8,    10,     4,         31    \ Edge 11
 EDGE       1,      15,     7,     6,         31    \ Edge 12
 EDGE       0,      15,     8,     6,         31    \ Edge 13
 EDGE       4,      15,     9,     7,         31    \ Edge 14
 EDGE       3,      15,    10,     8,         31    \ Edge 15
 EDGE      14,      15,    10,     9,         31    \ Edge 16
 EDGE       6,       7,    11,     5,         31    \ Edge 17
 EDGE       6,      11,    11,     3,         31    \ Edge 18
 EDGE       7,       8,    11,     4,         31    \ Edge 19
 EDGE      11,      14,    11,     9,         31    \ Edge 20
 EDGE       8,      14,    11,    10,         31    \ Edge 21
 EDGE      16,      17,    11,    11,         16    \ Edge 22
 EDGE      17,      18,    11,    11,         16    \ Edge 23
 EDGE      18,      19,    11,    11,         16    \ Edge 24
 EDGE      19,      16,    11,    11,         16    \ Edge 25
 EDGE      12,      13,     9,     3,         16    \ Edge 26
 EDGE      11,      12,     9,     3,         16    \ Edge 27
 EDGE      10,       9,    10,     4,         16    \ Edge 28
 EDGE       9,       8,    10,     4,         16    \ Edge 29

.SHIP_OPHIDIAN_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       37,       12,         31      \ Face 0
 FACE       11,       28,        5,         31      \ Face 1
 FACE      -11,       28,        5,         31      \ Face 2
 FACE       16,       34,        2,         31      \ Face 3
 FACE      -16,       34,        2,         31      \ Face 4
 FACE        0,       37,       -3,         31      \ Face 5
 FACE        0,      -31,       10,         31      \ Face 6
 FACE       10,      -20,        2,         31      \ Face 7
 FACE      -10,      -20,        2,         31      \ Face 8
 FACE       18,      -32,       -2,         31      \ Face 9
 FACE      -18,      -32,       -2,         31      \ Face 10
 FACE        0,        0,      -37,         31      \ Face 11

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_CHAMELEON
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Chameleon
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_CHAMELEON

 EQUB 3                 \ Max. canisters on demise = 3
 EQUW 4000              \ Targetable area          = 63.24 * 63.24

 EQUB LO(SHIP_CHAMELEON_EDGES - SHIP_CHAMELEON)    \ Edges data offset (low)
 EQUB LO(SHIP_CHAMELEON_FACES - SHIP_CHAMELEON)    \ Faces data offset (low)

 EQUB 89                \ Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 108               \ Number of vertices       = 108 / 6 = 18
 EQUB 29                \ Number of edges          = 29
 EQUW 200               \ Bounty                   = 200
 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 10                \ Visibility distance      = 10
 EQUB 100               \ Max. energy              = 100
 EQUB 29                \ Max. speed               = 29

 EQUB HI(SHIP_CHAMELEON_EDGES - SHIP_CHAMELEON)    \ Edges data offset (high)
 EQUB HI(SHIP_CHAMELEON_FACES - SHIP_CHAMELEON)    \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00100011         \ Laser power              = 4
                        \ Missiles                 = 3

.SHIP_CHAMELEON_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,    0,  110,     5,     2,     1,     0,         31     \ Vertex 0
 VERTEX   18,    0,  110,     4,     3,     1,     0,         31     \ Vertex 1
 VERTEX  -40,    0,    0,    11,     8,     5,     2,         31     \ Vertex 2
 VERTEX   -8,   24,    0,     8,     6,     2,     2,         31     \ Vertex 3
 VERTEX    8,   24,    0,     9,     6,     3,     3,         31     \ Vertex 4
 VERTEX   40,    0,    0,    10,     9,     4,     3,         31     \ Vertex 5
 VERTEX    8,  -24,    0,    10,     7,     4,     4,         31     \ Vertex 6
 VERTEX   -8,  -24,    0,    11,     7,     5,     5,         31     \ Vertex 7
 VERTEX    0,   24,   40,     6,     3,     2,     0,         31     \ Vertex 8
 VERTEX    0,  -24,   40,     7,     5,     4,     1,         31     \ Vertex 9
 VERTEX  -32,    0,  -40,    12,    11,     8,     8,         31     \ Vertex 10
 VERTEX    0,   24,  -40,    12,     9,     8,     6,         31     \ Vertex 11
 VERTEX   32,    0,  -40,    12,    10,     9,     9,         31     \ Vertex 12
 VERTEX    0,  -24,  -40,    12,    11,    10,     7,         31     \ Vertex 13
 VERTEX   -8,    0,  -40,    12,    12,    12,    12,         10     \ Vertex 14
 VERTEX    0,    8,  -40,    12,    12,    12,    12,         10     \ Vertex 15
 VERTEX    8,    0,  -40,    12,    12,    12,    12,         10     \ Vertex 16
 VERTEX    0,   -8,  -40,    12,    12,    12,    12,         10     \ Vertex 17

.SHIP_CHAMELEON_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    \ Edge 0
 EDGE       0,       8,     2,     0,         31    \ Edge 1
 EDGE       0,       9,     5,     1,         31    \ Edge 2
 EDGE       1,       8,     3,     0,         31    \ Edge 3
 EDGE       1,       9,     4,     1,         31    \ Edge 4
 EDGE       1,       5,     4,     3,         31    \ Edge 5
 EDGE       0,       2,     5,     2,         31    \ Edge 6
 EDGE       3,       8,     6,     2,         31    \ Edge 7
 EDGE       4,       8,     6,     3,         31    \ Edge 8
 EDGE       7,       9,     5,     7,         31    \ Edge 9
 EDGE       6,       9,     4,     7,         31    \ Edge 10
 EDGE       4,       5,     9,     3,         31    \ Edge 11
 EDGE       5,       6,    10,     4,         31    \ Edge 12
 EDGE       2,       3,     8,     2,         31    \ Edge 13
 EDGE       2,       7,    11,     5,         31    \ Edge 14
 EDGE       2,      10,    11,     8,         31    \ Edge 15
 EDGE       5,      12,    10,     9,         31    \ Edge 16
 EDGE       3,      11,     8,     6,         31    \ Edge 17
 EDGE       7,      13,    11,     7,         31    \ Edge 18
 EDGE       4,      11,     9,     6,         31    \ Edge 19
 EDGE       6,      13,    10,     7,         31    \ Edge 20
 EDGE      10,      11,    12,     8,         31    \ Edge 21
 EDGE      10,      13,    12,    11,         31    \ Edge 22
 EDGE      11,      12,    12,     9,         31    \ Edge 23
 EDGE      12,      13,    12,    10,         31    \ Edge 24
 EDGE      14,      15,    12,    12,         10    \ Edge 25
 EDGE      15,      16,    12,    12,         10    \ Edge 26
 EDGE      16,      17,    12,    12,         10    \ Edge 27
 EDGE      17,      14,    12,    12,         10    \ Edge 28

.SHIP_CHAMELEON_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       90,       31,         31      \ Face 0
 FACE        0,      -90,       31,         31      \ Face 1
 FACE      -57,       76,       11,         31      \ Face 2
 FACE       57,       76,       11,         31      \ Face 3
 FACE       57,      -76,       11,         31      \ Face 4
 FACE      -57,      -76,       11,         31      \ Face 5
 FACE        0,       96,        0,         31      \ Face 6
 FACE        0,      -96,        0,         31      \ Face 7
 FACE      -57,       76,      -11,         31      \ Face 8
 FACE       57,       76,      -11,         31      \ Face 9
 FACE       57,      -76,      -11,         31      \ Face 10
 FACE      -57,      -76,      -11,         31      \ Face 11
 FACE        0,        0,      -96,         31      \ Face 12

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_BUSHMASTER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Bushmaster
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_BUSHMASTER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 4250              \ Targetable area          = 65.19 * 65.19

 EQUB LO(SHIP_BUSHMASTER_EDGES - SHIP_BUSHMASTER)  \ Edges data offset (low)
 EQUB LO(SHIP_BUSHMASTER_FACES - SHIP_BUSHMASTER)  \ Faces data offset (low)

 EQUB 81                \ Max. edge count          = (81 - 1) / 4 = 20
 EQUB 0                 \ Gun vertex               = 0
 EQUB 30                \ Explosion count          = 6, as (4 * n) + 6 = 30
 EQUB 72                \ Number of vertices       = 72 / 6 = 12
 EQUB 19                \ Number of edges          = 19
 EQUW 150               \ Bounty                   = 150
 EQUB 36                \ Number of faces          = 36 / 4 = 9
 EQUB 20                \ Visibility distance      = 20
 EQUB 74                \ Max. energy              = 74
 EQUB 35                \ Max. speed               = 35

 EQUB HI(SHIP_BUSHMASTER_EDGES - SHIP_BUSHMASTER)  \ Edges data offset (high)
 EQUB HI(SHIP_BUSHMASTER_FACES - SHIP_BUSHMASTER)  \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00100001         \ Laser power              = 4
                        \ Missiles                 = 1

.SHIP_BUSHMASTER_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   60,     3,     2,     1,     0,         31     \ Vertex 0
 VERTEX   50,    0,   20,     7,     5,     3,     1,         31     \ Vertex 1
 VERTEX  -50,    0,   20,     6,     4,     2,     0,         31     \ Vertex 2
 VERTEX    0,   20,    0,     5,     4,     1,     0,         31     \ Vertex 3
 VERTEX    0,  -20,  -40,    15,    15,    15,    15,         31     \ Vertex 4
 VERTEX    0,   14,  -40,     8,     8,     5,     4,         31     \ Vertex 5
 VERTEX   40,    0,  -40,     8,     8,     7,     5,         31     \ Vertex 6
 VERTEX  -40,    0,  -40,     8,     8,     6,     4,         31     \ Vertex 7
 VERTEX    0,    4,  -40,     8,     8,     8,     8,         10     \ Vertex 8
 VERTEX   10,    0,  -40,     8,     8,     8,     8,         10     \ Vertex 9
 VERTEX    0,   -4,  -40,     8,     8,     8,     8,         10     \ Vertex 10
 VERTEX  -10,    0,  -40,     8,     8,     8,     8,         10     \ Vertex 11

.SHIP_BUSHMASTER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     1,         31    \ Edge 0
 EDGE       0,       2,     2,     0,         31    \ Edge 1
 EDGE       0,       3,     1,     0,         31    \ Edge 2
 EDGE       0,       4,     3,     2,         31    \ Edge 3
 EDGE       3,       5,     5,     4,         31    \ Edge 4
 EDGE       2,       3,     4,     0,         31    \ Edge 5
 EDGE       1,       3,     5,     1,         31    \ Edge 6
 EDGE       2,       7,     6,     4,         31    \ Edge 7
 EDGE       1,       6,     7,     5,         31    \ Edge 8
 EDGE       2,       4,     6,     2,         31    \ Edge 9
 EDGE       1,       4,     7,     3,         31    \ Edge 10
 EDGE       5,       7,     8,     4,         31    \ Edge 11
 EDGE       5,       6,     8,     5,         31    \ Edge 12
 EDGE       4,       7,     8,     6,         31    \ Edge 13
 EDGE       4,       6,     8,     7,         31    \ Edge 14
 EDGE       8,       9,     8,     8,         10    \ Edge 15
 EDGE       9,      10,     8,     8,         10    \ Edge 16
 EDGE      10,      11,     8,     8,         10    \ Edge 17
 EDGE      11,       8,     8,     8,         10    \ Edge 18

.SHIP_BUSHMASTER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE      -23,       88,       29,         31      \ Face 0
 FACE       23,       88,       29,         31      \ Face 1
 FACE      -14,      -93,       18,         31      \ Face 2
 FACE       14,      -93,       18,         31      \ Face 3
 FACE      -31,       89,      -13,         31      \ Face 4
 FACE       31,       89,      -13,         31      \ Face 5
 FACE      -42,      -85,       -7,         31      \ Face 6
 FACE       42,      -85,       -7,         31      \ Face 7
 FACE        0,        0,      -96,         31      \ Face 8

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_PLATE
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an alloy plate
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_PLATE

 EQUB 0 + (8 << 4)      \ Max. canisters on demise = 0
                        \ Market item when scooped = 8 + 1 = 9 (Alloys)
 EQUW 10 * 10           \ Targetable area          = 10 * 10

 EQUB LO(SHIP_PLATE_EDGES - SHIP_PLATE)            \ Edges data offset (low)
 EQUB LO(SHIP_PLATE_FACES - SHIP_PLATE)            \ Faces data offset (low)

 EQUB 17                \ Max. edge count          = (17 - 1) / 4 = 4
 EQUB 0                 \ Gun vertex               = 0
 EQUB 10                \ Explosion count          = 1, as (4 * n) + 6 = 10
 EQUB 24                \ Number of vertices       = 24 / 6 = 4
 EQUB 4                 \ Number of edges          = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUW 0                 \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 4                 \ Number of faces          = 4 / 4 = 1
 EQUB 5                 \ Visibility distance      = 5

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 16                \ Max. energy              = 16

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

 EQUB 16                \ Max. speed               = 16

 EQUB HI(SHIP_PLATE_EDGES - SHIP_PLATE)            \ Edges data offset (high)
 EQUB HI(SHIP_PLATE_FACES - SHIP_PLATE)            \ Faces data offset (high)

 EQUB 3                 \ Normals are scaled by    = 2^3 = 8
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_PLATE_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -15,  -22,   -9,    15,     15,   15,    15,         31    \ Vertex 0
 VERTEX  -15,   38,   -9,    15,     15,   15,    15,         31    \ Vertex 1
 VERTEX   19,   32,   11,    15,     15,   15,    15,         20    \ Vertex 2
 VERTEX   10,  -46,    6,    15,     15,   15,    15,         20    \ Vertex 3

.SHIP_PLATE_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,    15,    15,         31    \ Edge 0
 EDGE       1,       2,    15,    15,         16    \ Edge 1
 EDGE       2,       3,    15,    15,         20    \ Edge 2
 EDGE       3,       0,    15,    15,         16    \ Edge 3

.SHIP_PLATE_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,        0,        0,          0      \ Face 0

 EQUB 6                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save S.M.bin
\
\ ******************************************************************************

 PRINT "S.S.M ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/S.M.bin", CODE%, CODE% + &0A00
