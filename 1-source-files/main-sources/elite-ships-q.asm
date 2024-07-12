\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE Q
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
\ This source file produces the following binary file:
\
\   * S.Q.bin
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
\    Summary: Ship blueprints lookup table for the S.Q file
\  Deep dive: Ship blueprints in Elite-A
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile                            Missile
 EQUW SHIP_CORIOLIS     \ SST  =  2 = Coriolis space station             Station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod                      Escape pod
 EQUW 0                 \                                                  Cargo
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister                       Cargo
 EQUW SHIP_BOULDER      \         6 = Boulder                             Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                Shuttle
 EQUW 0                 \                                            Transporter
 EQUW SHIP_COBRA_MK_3   \        11 = Cobra Mk III                        Trader
 EQUW SHIP_PYTHON       \        12 = Python                              Trader
 EQUW SHIP_IGUANA       \        13 = Iguana                              Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_GECKO        \        17 = Gecko                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_BUSHMASTER   \        20 = Bushmaster                          Pirate
 EQUW SHIP_COBRA_MK_3   \        21 = Cobra Mk III                        Pirate
 EQUW SHIP_PYTHON       \        22 = Python                              Pirate
 EQUW SHIP_IGUANA       \        23 = Iguana                              Pirate
 EQUW SHIP_MORAY        \        24 = Moray                               Pirate
 EQUW SHIP_COBRA_MK_3   \        25 = Cobra Mk III                 Bounty hunter
 EQUW SHIP_BUSHMASTER   \        26 = Bushmaster                   Bounty hunter
 EQUW SHIP_GECKO        \        27 = Gecko                        Bounty hunter
 EQUW SHIP_PYTHON       \        28 = Python                       Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.Q file
\  Deep dive: Ship blueprints in Elite-A
\             Advanced tactics with the NEWB flags
\
\ ******************************************************************************

.E%

 EQUB %00000000         \ Missile
 EQUB %01000000         \ Coriolis space station                             Cop
 EQUB %01000001         \ Escape pod                                 Trader, cop
 EQUB 0
 EQUB %00000000         \ Cargo canister
 EQUB %00000000         \ Boulder
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Cobra Mk III                      Innocent, escape pod
 EQUB %10100001         \ Python                    Trader, innocent, escape pod
 EQUB %10100000         \ Iguana                            Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Gecko                      Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Bushmaster                 Hostile, pirate, escape pod
 EQUB %10000100         \ Cobra Mk III                       Hostile, escape pod
 EQUB %10001100         \ Python                     Hostile, pirate, escape pod
 EQUB %10000100         \ Iguana                             Hostile, escape pod
 EQUB %10001100         \ Moray                      Hostile, pirate, escape pod
 EQUB %10000010         \ Cobra Mk III                 Bounty hunter, escape pod
 EQUB %10100010         \ Bushmaster         Bounty hunter, innocent, escape pod
 EQUB %10000010         \ Gecko                        Bounty hunter, escape pod
 EQUB %10100010         \ Python             Bounty hunter, innocent, escape pod
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
 FACE        0,        0,      160,         31    \ Face 0
 FACE      107,     -107,      107,         31    \ Face 1
 FACE      107,      107,      107,         31    \ Face 2
 FACE     -107,      107,      107,         31    \ Face 3
 FACE     -107,     -107,      107,         31    \ Face 4
 FACE        0,     -160,        0,         31    \ Face 5
 FACE      160,        0,        0,         31    \ Face 6
 FACE     -160,        0,        0,         31    \ Face 7
 FACE        0,      160,        0,         31    \ Face 8
 FACE     -107,     -107,     -107,         31    \ Face 9
 FACE      107,     -107,     -107,         31    \ Face 10
 FACE      107,      107,     -107,         31    \ Face 11
 FACE     -107,      107,     -107,         31    \ Face 12
 FACE        0,        0,     -160,         31    \ Face 13

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
 FACE       52,        0,     -122,         31    \ Face 0
 FACE       39,      103,       30,         31    \ Face 1
 FACE       39,     -103,       30,         31    \ Face 2
 FACE     -112,        0,        0,         31    \ Face 3

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
 FACE       96,        0,        0,         31    \ Face 0
 FACE        0,       41,       30,         31    \ Face 1
 FACE        0,      -18,       48,         31    \ Face 2
 FACE        0,      -51,        0,         31    \ Face 3
 FACE        0,      -18,      -48,         31    \ Face 4
 FACE        0,       41,      -30,         31    \ Face 5
 FACE      -96,        0,        0,         31    \ Face 6

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
 FACE        0,       32,        0,         31    \ Face 0
 FACE      -22,       33,       11,         31    \ Face 1
 FACE       22,       33,       11,         31    \ Face 2
 FACE      -22,      -33,       11,         31    \ Face 3
 FACE       22,      -33,       11,         31    \ Face 4
 FACE        0,      -32,        0,         31    \ Face 5
 FACE        0,        0,      -48,         31    \ Face 6

\ ******************************************************************************
\
\       Name: SHIP_BOULDER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a boulder
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_BOULDER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 30 * 30           \ Targetable area          = 30 * 30

 EQUB LO(SHIP_BOULDER_EDGES - SHIP_BOULDER)        \ Edges data offset (low)
 EQUB LO(SHIP_BOULDER_FACES - SHIP_BOULDER)        \ Faces data offset (low)

 EQUB 45                \ Max. edge count          = (45 - 1) / 4 = 11
 EQUB 0                 \ Gun vertex               = 0
 EQUB 14                \ Explosion count          = 2, as (4 * n) + 6 = 14
 EQUB 42                \ Number of vertices       = 42 / 6 = 7
 EQUB 15                \ Number of edges          = 15
 EQUW 1                 \ Bounty                   = 1
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 20                \ Visibility distance      = 20

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 20                \ Max. energy              = 20

                        \ --- And replaced by: -------------------------------->

 EQUB 16                \ Max. energy              = 16

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_BOULDER_EDGES - SHIP_BOULDER)        \ Edges data offset (high)
 EQUB HI(SHIP_BOULDER_FACES - SHIP_BOULDER)        \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_BOULDER_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,   37,  -11,     1,      0,    9,     5,         31    \ Vertex 0
 VERTEX   30,    7,   12,     2,      1,    6,     5,         31    \ Vertex 1
 VERTEX   28,   -7,  -12,     3,      2,    7,     6,         31    \ Vertex 2
 VERTEX    2,    0,  -39,     4,      3,    8,     7,         31    \ Vertex 3
 VERTEX  -28,   34,  -30,     4,      0,    9,     8,         31    \ Vertex 4
 VERTEX    5,  -10,   13,    15,     15,   15,    15,         31    \ Vertex 5
 VERTEX   20,   17,  -30,    15,     15,   15,    15,         31    \ Vertex 6

.SHIP_BOULDER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     5,     1,         31    \ Edge 0
 EDGE       1,       2,     6,     2,         31    \ Edge 1
 EDGE       2,       3,     7,     3,         31    \ Edge 2
 EDGE       3,       4,     8,     4,         31    \ Edge 3
 EDGE       4,       0,     9,     0,         31    \ Edge 4
 EDGE       0,       5,     1,     0,         31    \ Edge 5
 EDGE       1,       5,     2,     1,         31    \ Edge 6
 EDGE       2,       5,     3,     2,         31    \ Edge 7
 EDGE       3,       5,     4,     3,         31    \ Edge 8
 EDGE       4,       5,     4,     0,         31    \ Edge 9
 EDGE       0,       6,     9,     5,         31    \ Edge 10
 EDGE       1,       6,     6,     5,         31    \ Edge 11
 EDGE       2,       6,     7,     6,         31    \ Edge 12
 EDGE       3,       6,     8,     7,         31    \ Edge 13
 EDGE       4,       6,     9,     8,         31    \ Edge 14

.SHIP_BOULDER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE      -15,       -3,        8,         31    \ Face 0
 FACE       -7,       12,       30,         31    \ Face 1
 FACE       32,      -47,       24,         31    \ Face 2
 FACE       -3,      -39,       -7,         31    \ Face 3
 FACE       -5,       -4,       -1,         31    \ Face 4
 FACE       49,       84,        8,         31    \ Face 5
 FACE      112,       21,      -21,         31    \ Face 6
 FACE       76,      -35,      -82,         31    \ Face 7
 FACE       22,       56,     -137,         31    \ Face 8
 FACE       40,      110,      -38,         31    \ Face 9

\ ******************************************************************************
\
\       Name: SHIP_GECKO
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Gecko
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_GECKO

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 99 * 99           \ Targetable area          = 99 * 99

 EQUB LO(SHIP_GECKO_EDGES - SHIP_GECKO)            \ Edges data offset (low)
 EQUB LO(SHIP_GECKO_FACES - SHIP_GECKO)            \ Faces data offset (low)

 EQUB 65                \ Max. edge count          = (65 - 1) / 4 = 16
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 72                \ Number of vertices       = 72 / 6 = 12
 EQUB 17                \ Number of edges          = 17
 EQUW 55                \ Bounty                   = 55
 EQUB 36                \ Number of faces          = 36 / 4 = 9
 EQUB 18                \ Visibility distance      = 18

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 70                \ Max. energy              = 70

                        \ --- And replaced by: -------------------------------->

 EQUB 65                \ Max. energy              = 65

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_GECKO_EDGES - SHIP_GECKO)            \ Edges data offset (high)
 EQUB HI(SHIP_GECKO_FACES - SHIP_GECKO)            \ Faces data offset (high)

 EQUB 3                 \ Normals are scaled by    = 2^3 = 8

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010000         \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

                        \ --- End of replacement ------------------------------>

.SHIP_GECKO_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -10,   -4,   47,     3,      0,    5,     4,         31    \ Vertex 0
 VERTEX   10,   -4,   47,     1,      0,    3,     2,         31    \ Vertex 1
 VERTEX  -16,    8,  -23,     5,      0,    7,     6,         31    \ Vertex 2
 VERTEX   16,    8,  -23,     1,      0,    8,     7,         31    \ Vertex 3
 VERTEX  -66,    0,   -3,     5,      4,    6,     6,         31    \ Vertex 4
 VERTEX   66,    0,   -3,     2,      1,    8,     8,         31    \ Vertex 5
 VERTEX  -20,  -14,  -23,     4,      3,    7,     6,         31    \ Vertex 6
 VERTEX   20,  -14,  -23,     3,      2,    8,     7,         31    \ Vertex 7
 VERTEX   -8,   -6,   33,     3,      3,    3,     3,         16    \ Vertex 8
 VERTEX    8,   -6,   33,     3,      3,    3,     3,         17    \ Vertex 9
 VERTEX   -8,  -13,  -16,     3,      3,    3,     3,         16    \ Vertex 10
 VERTEX    8,  -13,  -16,     3,      3,    3,     3,         17    \ Vertex 11

.SHIP_GECKO_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     0,         31    \ Edge 0
 EDGE       1,       5,     2,     1,         31    \ Edge 1
 EDGE       5,       3,     8,     1,         31    \ Edge 2
 EDGE       3,       2,     7,     0,         31    \ Edge 3
 EDGE       2,       4,     6,     5,         31    \ Edge 4
 EDGE       4,       0,     5,     4,         31    \ Edge 5
 EDGE       5,       7,     8,     2,         31    \ Edge 6
 EDGE       7,       6,     7,     3,         31    \ Edge 7
 EDGE       6,       4,     6,     4,         31    \ Edge 8
 EDGE       0,       2,     5,     0,         29    \ Edge 9
 EDGE       1,       3,     1,     0,         30    \ Edge 10
 EDGE       0,       6,     4,     3,         29    \ Edge 11
 EDGE       1,       7,     3,     2,         30    \ Edge 12
 EDGE       2,       6,     7,     6,         20    \ Edge 13
 EDGE       3,       7,     8,     7,         20    \ Edge 14
 EDGE       8,      10,     3,     3,         16    \ Edge 15
 EDGE       9,      11,     3,     3,         17    \ Edge 16

.SHIP_GECKO_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       31,        5,         31    \ Face 0
 FACE        4,       45,        8,         31    \ Face 1
 FACE       25,     -108,       19,         31    \ Face 2
 FACE        0,      -84,       12,         31    \ Face 3
 FACE      -25,     -108,       19,         31    \ Face 4
 FACE       -4,       45,        8,         31    \ Face 5
 FACE      -88,       16,     -214,         31    \ Face 6
 FACE        0,        0,     -187,         31    \ Face 7
 FACE       88,       16,     -214,         31    \ Face 8

\ ******************************************************************************
\
\       Name: SHIP_COBRA_MK_3
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Cobra Mk III
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_COBRA_MK_3

 EQUB 3                 \ Max. canisters on demise = 3
 EQUW 95 * 95           \ Targetable area          = 95 * 95

 EQUB LO(SHIP_COBRA_MK_3_EDGES - SHIP_COBRA_MK_3)  \ Edges data offset (low)
 EQUB LO(SHIP_COBRA_MK_3_FACES - SHIP_COBRA_MK_3)  \ Faces data offset (low)

 EQUB 153               \ Max. edge count          = (153 - 1) / 4 = 38
 EQUB 84                \ Gun vertex               = 84 / 4 = 21
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 168               \ Number of vertices       = 168 / 6 = 28
 EQUB 38                \ Number of edges          = 38

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUW 0                 \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 200               \ Bounty                   = 200

                        \ --- End of replacement ------------------------------>

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 50                \ Visibility distance      = 50

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 150               \ Max. energy              = 150

                        \ --- And replaced by: -------------------------------->

 EQUB 98                \ Max. energy              = 98

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Max. speed               = 28

 EQUB HI(SHIP_COBRA_MK_3_EDGES - SHIP_COBRA_MK_3)  \ Edges data offset (low)
 EQUB HI(SHIP_COBRA_MK_3_FACES - SHIP_COBRA_MK_3)  \ Faces data offset (low)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010011         \ Laser power              = 2
\                       \ Missiles                 = 3

                        \ --- And replaced by: -------------------------------->

 EQUB %00100100         \ Laser power              = 4
                        \ Missiles                 = 4

                        \ --- End of replacement ------------------------------>

.SHIP_COBRA_MK_3_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   32,    0,   76,    15,     15,   15,    15,         31    \ Vertex 0
 VERTEX  -32,    0,   76,    15,     15,   15,    15,         31    \ Vertex 1
 VERTEX    0,   26,   24,    15,     15,   15,    15,         31    \ Vertex 2
 VERTEX -120,   -3,   -8,     3,      7,   10,    10,         31    \ Vertex 3
 VERTEX  120,   -3,   -8,     4,      8,   12,    12,         31    \ Vertex 4
 VERTEX  -88,   16,  -40,    15,     15,   15,    15,         31    \ Vertex 5
 VERTEX   88,   16,  -40,    15,     15,   15,    15,         31    \ Vertex 6
 VERTEX  128,   -8,  -40,     8,      9,   12,    12,         31    \ Vertex 7
 VERTEX -128,   -8,  -40,     7,      9,   10,    10,         31    \ Vertex 8
 VERTEX    0,   26,  -40,     5,      6,    9,     9,         31    \ Vertex 9
 VERTEX  -32,  -24,  -40,     9,     10,   11,    11,         31    \ Vertex 10
 VERTEX   32,  -24,  -40,     9,     11,   12,    12,         31    \ Vertex 11
 VERTEX  -36,    8,  -40,     9,      9,    9,     9,         20    \ Vertex 12
 VERTEX   -8,   12,  -40,     9,      9,    9,     9,         20    \ Vertex 13
 VERTEX    8,   12,  -40,     9,      9,    9,     9,         20    \ Vertex 14
 VERTEX   36,    8,  -40,     9,      9,    9,     9,         20    \ Vertex 15
 VERTEX   36,  -12,  -40,     9,      9,    9,     9,         20    \ Vertex 16
 VERTEX    8,  -16,  -40,     9,      9,    9,     9,         20    \ Vertex 17
 VERTEX   -8,  -16,  -40,     9,      9,    9,     9,         20    \ Vertex 18
 VERTEX  -36,  -12,  -40,     9,      9,    9,     9,         20    \ Vertex 19
 VERTEX    0,    0,   76,     0,     11,   11,    11,          6    \ Vertex 20
 VERTEX    0,    0,   90,     0,     11,   11,    11,         31    \ Vertex 21
 VERTEX  -80,   -6,  -40,     9,      9,    9,     9,          8    \ Vertex 22
 VERTEX  -80,    6,  -40,     9,      9,    9,     9,          8    \ Vertex 23
 VERTEX  -88,    0,  -40,     9,      9,    9,     9,          6    \ Vertex 24
 VERTEX   80,    6,  -40,     9,      9,    9,     9,          8    \ Vertex 25
 VERTEX   88,    0,  -40,     9,      9,    9,     9,          6    \ Vertex 26
 VERTEX   80,   -6,  -40,     9,      9,    9,     9,          8    \ Vertex 27

.SHIP_COBRA_MK_3_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,    11,         31    \ Edge 0
 EDGE       0,       4,     4,    12,         31    \ Edge 1
 EDGE       1,       3,     3,    10,         31    \ Edge 2
 EDGE       3,       8,     7,    10,         31    \ Edge 3
 EDGE       4,       7,     8,    12,         31    \ Edge 4
 EDGE       6,       7,     8,     9,         31    \ Edge 5
 EDGE       6,       9,     6,     9,         31    \ Edge 6
 EDGE       5,       9,     5,     9,         31    \ Edge 7
 EDGE       5,       8,     7,     9,         31    \ Edge 8
 EDGE       2,       5,     1,     5,         31    \ Edge 9
 EDGE       2,       6,     2,     6,         31    \ Edge 10
 EDGE       3,       5,     3,     7,         31    \ Edge 11
 EDGE       4,       6,     4,     8,         31    \ Edge 12
 EDGE       1,       2,     0,     1,         31    \ Edge 13
 EDGE       0,       2,     0,     2,         31    \ Edge 14
 EDGE       8,      10,     9,    10,         31    \ Edge 15
 EDGE      10,      11,     9,    11,         31    \ Edge 16
 EDGE       7,      11,     9,    12,         31    \ Edge 17
 EDGE       1,      10,    10,    11,         31    \ Edge 18
 EDGE       0,      11,    11,    12,         31    \ Edge 19
 EDGE       1,       5,     1,     3,         29    \ Edge 20
 EDGE       0,       6,     2,     4,         29    \ Edge 21
 EDGE      20,      21,     0,    11,          6    \ Edge 22
 EDGE      12,      13,     9,     9,         20    \ Edge 23
 EDGE      18,      19,     9,     9,         20    \ Edge 24
 EDGE      14,      15,     9,     9,         20    \ Edge 25
 EDGE      16,      17,     9,     9,         20    \ Edge 26
 EDGE      15,      16,     9,     9,         19    \ Edge 27
 EDGE      14,      17,     9,     9,         17    \ Edge 28
 EDGE      13,      18,     9,     9,         19    \ Edge 29
 EDGE      12,      19,     9,     9,         19    \ Edge 30
 EDGE       2,       9,     5,     6,         30    \ Edge 31
 EDGE      22,      24,     9,     9,          6    \ Edge 32
 EDGE      23,      24,     9,     9,          6    \ Edge 33
 EDGE      22,      23,     9,     9,          8    \ Edge 34
 EDGE      25,      26,     9,     9,          6    \ Edge 35
 EDGE      26,      27,     9,     9,          6    \ Edge 36
 EDGE      25,      27,     9,     9,          8    \ Edge 37

.SHIP_COBRA_MK_3_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       31,         31    \ Face 0
 FACE      -18,       55,       16,         31    \ Face 1
 FACE       18,       55,       16,         31    \ Face 2
 FACE      -16,       52,       14,         31    \ Face 3
 FACE       16,       52,       14,         31    \ Face 4
 FACE      -14,       47,        0,         31    \ Face 5
 FACE       14,       47,        0,         31    \ Face 6
 FACE      -61,      102,        0,         31    \ Face 7
 FACE       61,      102,        0,         31    \ Face 8
 FACE        0,        0,      -80,         31    \ Face 9
 FACE       -7,      -42,        9,         31    \ Face 10
 FACE        0,      -30,        6,         31    \ Face 11
 FACE        7,      -42,        9,         31    \ Face 12

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
 FACE      -23,       88,       29,         31    \ Face 0
 FACE       23,       88,       29,         31    \ Face 1
 FACE      -14,      -93,       18,         31    \ Face 2
 FACE       14,      -93,       18,         31    \ Face 3
 FACE      -31,       89,      -13,         31    \ Face 4
 FACE       31,       89,      -13,         31    \ Face 5
 FACE      -42,      -85,       -7,         31    \ Face 6
 FACE       42,      -85,       -7,         31    \ Face 7
 FACE        0,        0,      -96,         31    \ Face 8

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_PYTHON
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Python
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_PYTHON

 EQUB 5                 \ Max. canisters on demise = 5
 EQUW 80 * 80           \ Targetable area          = 80 * 80

 EQUB LO(SHIP_PYTHON_EDGES - SHIP_PYTHON)          \ Edges data offset (low)
 EQUB LO(SHIP_PYTHON_FACES - SHIP_PYTHON)          \ Faces data offset (low)

 EQUB 85                \ Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 \ Gun vertex               = 0
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 66                \ Number of vertices       = 66 / 6 = 11
 EQUB 26                \ Number of edges          = 26

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUW 0                 \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 300               \ Bounty                   = 300

                        \ --- End of replacement ------------------------------>

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 250               \ Max. energy              = 250

                        \ --- And replaced by: -------------------------------->

 EQUB 125               \ Max. energy              = 125

                        \ --- End of replacement ------------------------------>

 EQUB 20                \ Max. speed               = 20

 EQUB HI(SHIP_PYTHON_EDGES - SHIP_PYTHON)          \ Edges data offset (high)
 EQUB HI(SHIP_PYTHON_FACES - SHIP_PYTHON)          \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00011011         \ Laser power              = 3
\                       \ Missiles                 = 3

                        \ --- And replaced by: -------------------------------->

 EQUB %00101100         \ Laser power              = 5
                        \ Missiles                 = 4

                        \ --- End of replacement ------------------------------>

.SHIP_PYTHON_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,  224,     0,      1,    2,     3,         31    \ Vertex 0

                        \ --- Mod: Code removed for Elite-A: ------------------>

\VERTEX    0,   48,   48,     0,      1,    4,     5,         31    \ Vertex 1

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,   48,   48,     0,      1,    4,     5,         30    \ Vertex 1

                        \ --- End of replacement ------------------------------>

 VERTEX   96,    0,  -16,    15,     15,   15,    15,         31    \ Vertex 2
 VERTEX  -96,    0,  -16,    15,     15,   15,    15,         31    \ Vertex 3

                        \ --- Mod: Code removed for Elite-A: ------------------>

\VERTEX    0,   48,  -32,     4,      5,    8,     9,         31    \ Vertex 4

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,   48,  -32,     4,      5,    8,     9,         30    \ Vertex 4

                        \ --- End of replacement ------------------------------>

 VERTEX    0,   24, -112,     9,      8,   12,    12,         31    \ Vertex 5
 VERTEX  -48,    0, -112,     8,     11,   12,    12,         31    \ Vertex 6
 VERTEX   48,    0, -112,     9,     10,   12,    12,         31    \ Vertex 7

                        \ --- Mod: Code removed for Elite-A: ------------------>

\VERTEX    0,  -48,   48,     2,      3,    6,     7,         31    \ Vertex 8
\VERTEX    0,  -48,  -32,     6,      7,   10,    11,         31    \ Vertex 9
\VERTEX    0,  -24, -112,    10,     11,   12,    12,         31    \ Vertex 10

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,  -48,   48,     2,      3,    6,     7,         30    \ Vertex 8
 VERTEX    0,  -48,  -32,     6,      7,   10,    11,         30    \ Vertex 9
 VERTEX    0,  -24, -112,    10,     11,   12,    12,         30    \ Vertex 10

                        \ --- End of replacement ------------------------------>

.SHIP_PYTHON_EDGES

    \ vertex1, vertex2, face1, face2, visibility

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EDGE       0,       8,     2,     3,         31    \ Edge 0

                        \ --- And replaced by: -------------------------------->

 EDGE       0,       8,     2,     3,         30    \ Edge 0

                        \ --- End of replacement ------------------------------>

 EDGE       0,       3,     0,     2,         31    \ Edge 1
 EDGE       0,       2,     1,     3,         31    \ Edge 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EDGE       0,       1,     0,     1,         31    \ Edge 3
\EDGE       2,       4,     9,     5,         31    \ Edge 4
\EDGE       1,       2,     1,     5,         31    \ Edge 5
\EDGE       2,       8,     7,     3,         31    \ Edge 6
\EDGE       1,       3,     0,     4,         31    \ Edge 7
\EDGE       3,       8,     2,     6,         31    \ Edge 8
\EDGE       2,       9,     7,    10,         31    \ Edge 9
\EDGE       3,       4,     4,     8,         31    \ Edge 10
\EDGE       3,       9,     6,    11,         31    \ Edge 11
\EDGE       3,       5,     8,     8,          7    \ Edge 12
\EDGE       3,      10,    11,    11,          7    \ Edge 13
\EDGE       2,       5,     9,     9,          7    \ Edge 14
\EDGE       2,      10,    10,    10,          7    \ Edge 15

                        \ --- And replaced by: -------------------------------->

 EDGE       0,       1,     0,     1,         30    \ Edge 3
 EDGE       2,       4,     9,     5,         29    \ Edge 4
 EDGE       1,       2,     1,     5,         29    \ Edge 5
 EDGE       2,       8,     7,     3,         29    \ Edge 6
 EDGE       1,       3,     0,     4,         29    \ Edge 7
 EDGE       3,       8,     2,     6,         29    \ Edge 8
 EDGE       2,       9,     7,    10,         29    \ Edge 9
 EDGE       3,       4,     4,     8,         29    \ Edge 10
 EDGE       3,       9,     6,    11,         29    \ Edge 11
 EDGE       3,       5,     8,     8,          5    \ Edge 12
 EDGE       3,      10,    11,    11,          5    \ Edge 13
 EDGE       2,       5,     9,     9,          5    \ Edge 14
 EDGE       2,      10,    10,    10,          5    \ Edge 15

                        \ --- End of replacement ------------------------------>

 EDGE       2,       7,     9,    10,         31    \ Edge 16
 EDGE       3,       6,     8,    11,         31    \ Edge 17
 EDGE       5,       6,     8,    12,         31    \ Edge 18
 EDGE       5,       7,     9,    12,         31    \ Edge 19

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EDGE       7,      10,    12,    10,         31    \ Edge 20
\EDGE       6,      10,    11,    12,         31    \ Edge 21
\EDGE       4,       5,     8,     9,         31    \ Edge 22
\EDGE       9,      10,    10,    11,         31    \ Edge 23
\EDGE       1,       4,     4,     5,         31    \ Edge 24
\EDGE       8,       9,     6,     7,         31    \ Edge 25

                        \ --- And replaced by: -------------------------------->

 EDGE       7,      10,    12,    10,         29    \ Edge 20
 EDGE       6,      10,    11,    12,         29    \ Edge 21
 EDGE       4,       5,     8,     9,         29    \ Edge 22
 EDGE       9,      10,    10,    11,         29    \ Edge 23
 EDGE       1,       4,     4,     5,         29    \ Edge 24
 EDGE       8,       9,     6,     7,         29    \ Edge 25

                        \ --- End of replacement ------------------------------>

.SHIP_PYTHON_FACES

                        \ --- Mod: Code removed for Elite-A: ------------------>

\   \ normal_x, normal_y, normal_z, visibility
\FACE      -27,       40,       11,        31    \ Face 0
\FACE       27,       40,       11,        31    \ Face 1
\FACE      -27,      -40,       11,        31    \ Face 2
\FACE       27,      -40,       11,        31    \ Face 3
\FACE      -19,       38,        0,        31    \ Face 4
\FACE       19,       38,        0,        31    \ Face 5
\FACE      -19,      -38,        0,        31    \ Face 6
\FACE       19,      -38,        0,        31    \ Face 7
\FACE      -25,       37,      -11,        31    \ Face 8
\FACE       25,       37,      -11,        31    \ Face 9
\FACE       25,      -37,      -11,        31    \ Face 10
\FACE      -25,      -37,      -11,        31    \ Face 11
\FACE        0,        0,     -112,        31    \ Face 12

                        \ --- And replaced by: -------------------------------->

    \ normal_x, normal_y, normal_z, visibility
 FACE      -27,       40,       11,         30    \ Face 0
 FACE       27,       40,       11,         30    \ Face 1
 FACE      -27,      -40,       11,         30    \ Face 2
 FACE       27,      -40,       11,         30    \ Face 3
 FACE      -19,       38,        0,         30    \ Face 4
 FACE       19,       38,        0,         30    \ Face 5
 FACE      -19,      -38,        0,         30    \ Face 6
 FACE       19,      -38,        0,         30    \ Face 7
 FACE      -25,       37,      -11,         30    \ Face 8
 FACE       25,       37,      -11,         30    \ Face 9
 FACE       25,      -37,      -11,         30    \ Face 10
 FACE      -25,      -37,      -11,         30    \ Face 11
 FACE        0,        0,     -112,         30    \ Face 12

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: SHIP_IGUANA
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Iguana
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_IGUANA

 EQUB 1                 \ Max. canisters on demise = 1
 EQUW 3500              \ Targetable area          = 59.16 * 59.16

 EQUB LO(SHIP_IGUANA_EDGES - SHIP_IGUANA)          \ Edges data offset (low)
 EQUB LO(SHIP_IGUANA_FACES - SHIP_IGUANA)          \ Faces data offset (low)

 EQUB 81                \ Max. edge count          = (81 - 1) / 4 = 20
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 90                \ Number of vertices       = 90 / 6 = 15
 EQUB 23                \ Number of edges          = 23
 EQUW 150               \ Bounty                   = 150
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 10                \ Visibility distance      = 10
 EQUB 90                \ Max. energy              = 90
 EQUB 33                \ Max. speed               = 33

 EQUB HI(SHIP_IGUANA_EDGES - SHIP_IGUANA)          \ Edges data offset (high)
 EQUB HI(SHIP_IGUANA_FACES - SHIP_IGUANA)          \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00100011         \ Laser power              = 4
                        \ Missiles                 = 3

.SHIP_IGUANA_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   90,     3,     2,     1,     0,         31     \ Vertex 0
 VERTEX    0,   20,   30,     6,     4,     2,     0,         31     \ Vertex 1
 VERTEX  -40,    0,   10,     5,     4,     1,     0,         31     \ Vertex 2
 VERTEX    0,  -20,   30,     7,     5,     3,     1,         31     \ Vertex 3
 VERTEX   40,    0,   10,     7,     6,     3,     2,         31     \ Vertex 4
 VERTEX    0,   20,  -40,     9,     8,     6,     4,         31     \ Vertex 5
 VERTEX  -40,    0,  -30,     8,     8,     5,     4,         31     \ Vertex 6
 VERTEX    0,  -20,  -40,     9,     8,     7,     5,         31     \ Vertex 7
 VERTEX   40,    0,  -30,     9,     9,     7,     6,         31     \ Vertex 8
 VERTEX  -40,    0,   40,     1,     1,     0,     0,         30     \ Vertex 9
 VERTEX   40,    0,   40,     3,     3,     2,     2,         30     \ Vertex 10
 VERTEX    0,    8,  -40,     9,     9,     8,     8,         10     \ Vertex 11
 VERTEX  -16,    0,  -36,     8,     8,     8,     8,         10     \ Vertex 12
 VERTEX    0,   -8,  -40,     9,     9,     8,     8,         10     \ Vertex 13
 VERTEX   16,    0,  -36,     9,     9,     9,     9,         10     \ Vertex 14

.SHIP_IGUANA_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     0,         31    \ Edge 0
 EDGE       0,       2,     1,     0,         31    \ Edge 1
 EDGE       0,       3,     3,     1,         31    \ Edge 2
 EDGE       0,       4,     3,     2,         31    \ Edge 3
 EDGE       1,       5,     6,     4,         31    \ Edge 4
 EDGE       2,       6,     5,     4,         31    \ Edge 5
 EDGE       3,       7,     7,     5,         31    \ Edge 6
 EDGE       4,       8,     7,     6,         31    \ Edge 7
 EDGE       5,       6,     8,     4,         31    \ Edge 8
 EDGE       6,       7,     8,     5,         31    \ Edge 9
 EDGE       5,       8,     9,     6,         31    \ Edge 10
 EDGE       7,       8,     9,     7,         31    \ Edge 11
 EDGE       1,       2,     4,     0,         31    \ Edge 12
 EDGE       2,       3,     5,     1,         31    \ Edge 13
 EDGE       1,       4,     6,     2,         31    \ Edge 14
 EDGE       3,       4,     7,     3,         31    \ Edge 15
 EDGE       5,       7,     9,     8,         31    \ Edge 16
 EDGE       2,       9,     1,     0,         30    \ Edge 17
 EDGE       4,      10,     3,     2,         30    \ Edge 18
 EDGE      11,      12,     8,     8,         10    \ Edge 19
 EDGE      13,      12,     8,     8,         10    \ Edge 20
 EDGE      11,      14,     9,     9,         10    \ Edge 21
 EDGE      13,      14,     9,     9,         10    \ Edge 22

.SHIP_IGUANA_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE      -51,       77,       25,         31    \ Face 0
 FACE      -51,      -77,       25,         31    \ Face 1
 FACE       51,       77,       25,         31    \ Face 2
 FACE       51,      -77,       25,         31    \ Face 3
 FACE      -42,       85,        0,         31    \ Face 4
 FACE      -42,      -85,        0,         31    \ Face 5
 FACE       42,       85,        0,         31    \ Face 6
 FACE       42,      -85,        0,         31    \ Face 7
 FACE      -23,        0,      -93,         31    \ Face 8
 FACE       23,        0,      -93,         31    \ Face 9

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_MORAY
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Moray
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_MORAY

 EQUB 1                 \ Max. canisters on demise = 1
 EQUW 30 * 30           \ Targetable area          = 30 * 30

 EQUB LO(SHIP_MORAY_EDGES - SHIP_MORAY)            \ Edges data offset (low)
 EQUB LO(SHIP_MORAY_FACES - SHIP_MORAY)            \ Faces data offset (low)

 EQUB 69                \ Max. edge count          = (69 - 1) / 4 = 17
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 84                \ Number of vertices       = 84 / 6 = 14
 EQUB 19                \ Number of edges          = 19
 EQUW 50                \ Bounty                   = 50
 EQUB 36                \ Number of faces          = 36 / 4 = 9
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB 100               \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 89                \ Max. energy              = 89

                        \ --- End of replacement ------------------------------>

 EQUB 25                \ Max. speed               = 25

 EQUB HI(SHIP_MORAY_EDGES - SHIP_MORAY)            \ Edges data offset (high)
 EQUB HI(SHIP_MORAY_FACES - SHIP_MORAY)            \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\EQUB %00010000         \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00101010         \ Laser power              = 5
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

.SHIP_MORAY_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   15,    0,   65,     2,      0,    8,     7,         31    \ Vertex 0
 VERTEX  -15,    0,   65,     1,      0,    7,     6,         31    \ Vertex 1
 VERTEX    0,   18,  -40,    15,     15,   15,    15,         17    \ Vertex 2
 VERTEX  -60,    0,    0,     3,      1,    6,     6,         31    \ Vertex 3
 VERTEX   60,    0,    0,     5,      2,    8,     8,         31    \ Vertex 4
 VERTEX   30,  -27,  -10,     5,      4,    8,     7,         24    \ Vertex 5
 VERTEX  -30,  -27,  -10,     4,      3,    7,     6,         24    \ Vertex 6
 VERTEX   -9,   -4,  -25,     4,      4,    4,     4,          7    \ Vertex 7
 VERTEX    9,   -4,  -25,     4,      4,    4,     4,          7    \ Vertex 8
 VERTEX    0,  -18,  -16,     4,      4,    4,     4,          7    \ Vertex 9
 VERTEX   13,    3,   49,     0,      0,    0,     0,          5    \ Vertex 10
 VERTEX    6,    0,   65,     0,      0,    0,     0,          5    \ Vertex 11
 VERTEX  -13,    3,   49,     0,      0,    0,     0,          5    \ Vertex 12
 VERTEX   -6,    0,   65,     0,      0,    0,     0,          5    \ Vertex 13

.SHIP_MORAY_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    \ Edge 0
 EDGE       1,       3,     6,     1,         31    \ Edge 1
 EDGE       3,       6,     6,     3,         24    \ Edge 2
 EDGE       5,       6,     7,     4,         24    \ Edge 3
 EDGE       4,       5,     8,     5,         24    \ Edge 4
 EDGE       0,       4,     8,     2,         31    \ Edge 5
 EDGE       1,       6,     7,     6,         15    \ Edge 6
 EDGE       0,       5,     8,     7,         15    \ Edge 7
 EDGE       0,       2,     2,     0,         15    \ Edge 8
 EDGE       1,       2,     1,     0,         15    \ Edge 9
 EDGE       2,       3,     3,     1,         17    \ Edge 10
 EDGE       2,       4,     5,     2,         17    \ Edge 11
 EDGE       2,       5,     5,     4,         13    \ Edge 12
 EDGE       2,       6,     4,     3,         13    \ Edge 13
 EDGE       7,       8,     4,     4,          5    \ Edge 14
 EDGE       7,       9,     4,     4,          7    \ Edge 15
 EDGE       8,       9,     4,     4,          7    \ Edge 16
 EDGE      10,      11,     0,     0,          5    \ Edge 17
 EDGE      12,      13,     0,     0,          5    \ Edge 18

.SHIP_MORAY_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       43,        7,         31    \ Face 0
 FACE      -10,       49,        7,         31    \ Face 1
 FACE       10,       49,        7,         31    \ Face 2
 FACE      -59,      -28,     -101,         24    \ Face 3
 FACE        0,      -52,      -78,         24    \ Face 4
 FACE       59,      -28,     -101,         24    \ Face 5
 FACE      -72,      -99,       50,         31    \ Face 6
 FACE        0,      -83,       30,         31    \ Face 7
 FACE       72,      -99,       50,         31    \ Face 8

 EQUB 8                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save S.Q.bin
\
\ ******************************************************************************

 PRINT "S.S.Q ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/S.Q.bin", CODE%, CODE% + &0A00
