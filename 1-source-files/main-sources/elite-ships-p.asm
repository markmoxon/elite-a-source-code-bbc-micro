\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE P
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
\   * S.P.bin
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

 SHIP_MISSILE = &7F00   \ The address of the missile ship blueprint

 CODE% = &5600          \ The flight code loads this file at address &5600, at
 LOAD% = &5600          \ label XX21

 ORG CODE%

\ ******************************************************************************
\
\       Name: XX21
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints lookup table for the S.P file
\  Deep dive: Ship blueprints in Elite-A
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile                            Missile
 EQUW SHIP_DODO         \         2 = Dodo space station                 Station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod                      Escape pod
 EQUW 0                 \                                                  Cargo
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister                       Cargo
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                Shuttle
 EQUW SHIP_TRANSPORTER  \        10 = Transporter                    Transporter
 EQUW 0                 \                                                 Trader
 EQUW SHIP_CHAMELEON    \        12 = Chameleon                           Trader
 EQUW SHIP_OPHIDIAN     \        13 = Ophidian                            Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_MAMBA        \        17 = Mamba                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_OPHIDIAN     \        21 = Ophidian                            Pirate
 EQUW SHIP_CHAMELEON    \        22 = Chameleon                           Pirate
 EQUW SHIP_MORAY        \        23 = Moray                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                          Bounty hunter
 EQUW 0                 \                                          Bounty hunter
 EQUW SHIP_MORAY        \        27 = Moray                        Bounty hunter
 EQUW SHIP_CHAMELEON    \        28 = Chameleon                    Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.P file
\  Deep dive: Ship blueprints in Elite-A
\             Advanced tactics with the NEWB flags
\
\ ******************************************************************************

.E%

 EQUB %00000000         \ Missile
 EQUB %01000000         \ Dodo space station                                 Cop
 EQUB %01000001         \ Escape pod                                 Trader, cop
 EQUB 0
 EQUB %00000000         \ Cargo canister
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %01100001         \ Transporter                      Trader, innocent, cop
 EQUB 0
 EQUB %10100001         \ Chameleon                 Trader, innocent, escape pod
 EQUB %10100000         \ Ophidian                          Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Mamba                      Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB %10001100         \ Chameleon                  Hostile, pirate, escape pod
 EQUB %10000100         \ Moray                              Hostile, escape pod
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10000010         \ Moray                        Bounty hunter, escape pod
 EQUB %10100010         \ Chameleon          Bounty hunter, innocent, escape pod
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
\       Name: SHIP_DODO
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Dodecahedron ("Dodo") space station
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_DODO

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 180 * 180         \ Targetable area          = 180 * 180

 EQUB LO(SHIP_DODO_EDGES - SHIP_DODO)              \ Edges data offset (low)
 EQUB LO(SHIP_DODO_FACES - SHIP_DODO)              \ Faces data offset (low)

 EQUB 97                \ Max. edge count          = (97 - 1) / 4 = 24
 EQUB 0                 \ Gun vertex               = 0
 EQUB 54                \ Explosion count          = 12, as (4 * n) + 6 = 54
 EQUB 144               \ Number of vertices       = 144 / 6 = 24
 EQUB 34                \ Number of edges          = 34
 EQUW 0                 \ Bounty                   = 0
 EQUB 48                \ Number of faces          = 48 / 4 = 12
 EQUB 125               \ Visibility distance      = 125
 EQUB 240               \ Max. energy              = 240
 EQUB 0                 \ Max. speed               = 0

 EQUB HI(SHIP_DODO_EDGES - SHIP_DODO)              \ Edges data offset (high)
 EQUB HI(SHIP_DODO_FACES - SHIP_DODO)              \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_DODO_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  150,  196,     1,      0,    5,     5,         31    \ Vertex 0
 VERTEX  143,   46,  196,     1,      0,    2,     2,         31    \ Vertex 1
 VERTEX   88, -121,  196,     2,      0,    3,     3,         31    \ Vertex 2
 VERTEX  -88, -121,  196,     3,      0,    4,     4,         31    \ Vertex 3
 VERTEX -143,   46,  196,     4,      0,    5,     5,         31    \ Vertex 4
 VERTEX    0,  243,   46,     5,      1,    6,     6,         31    \ Vertex 5
 VERTEX  231,   75,   46,     2,      1,    7,     7,         31    \ Vertex 6
 VERTEX  143, -196,   46,     3,      2,    8,     8,         31    \ Vertex 7
 VERTEX -143, -196,   46,     4,      3,    9,     9,         31    \ Vertex 8
 VERTEX -231,   75,   46,     5,      4,   10,    10,         31    \ Vertex 9
 VERTEX  143,  196,  -46,     6,      1,    7,     7,         31    \ Vertex 10
 VERTEX  231,  -75,  -46,     7,      2,    8,     8,         31    \ Vertex 11
 VERTEX    0, -243,  -46,     8,      3,    9,     9,         31    \ Vertex 12
 VERTEX -231,  -75,  -46,     9,      4,   10,    10,         31    \ Vertex 13
 VERTEX -143,  196,  -46,     6,      5,   10,    10,         31    \ Vertex 14
 VERTEX   88,  121, -196,     7,      6,   11,    11,         31    \ Vertex 15
 VERTEX  143,  -46, -196,     8,      7,   11,    11,         31    \ Vertex 16
 VERTEX    0, -150, -196,     9,      8,   11,    11,         31    \ Vertex 17
 VERTEX -143,  -46, -196,    10,      9,   11,    11,         31    \ Vertex 18
 VERTEX  -88,  121, -196,    10,      6,   11,    11,         31    \ Vertex 19
 VERTEX  -16,   32,  196,     0,      0,    0,     0,         30    \ Vertex 20
 VERTEX  -16,  -32,  196,     0,      0,    0,     0,         30    \ Vertex 21
 VERTEX   16,   32,  196,     0,      0,    0,     0,         23    \ Vertex 22
 VERTEX   16,  -32,  196,     0,      0,    0,     0,         23    \ Vertex 23

.SHIP_DODO_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    \ Edge 0
 EDGE       1,       2,     2,     0,         31    \ Edge 1
 EDGE       2,       3,     3,     0,         31    \ Edge 2
 EDGE       3,       4,     4,     0,         31    \ Edge 3
 EDGE       4,       0,     5,     0,         31    \ Edge 4
 EDGE       5,      10,     6,     1,         31    \ Edge 5
 EDGE      10,       6,     7,     1,         31    \ Edge 6
 EDGE       6,      11,     7,     2,         31    \ Edge 7
 EDGE      11,       7,     8,     2,         31    \ Edge 8
 EDGE       7,      12,     8,     3,         31    \ Edge 9
 EDGE      12,       8,     9,     3,         31    \ Edge 10
 EDGE       8,      13,     9,     4,         31    \ Edge 11
 EDGE      13,       9,    10,     4,         31    \ Edge 12
 EDGE       9,      14,    10,     5,         31    \ Edge 13
 EDGE      14,       5,     6,     5,         31    \ Edge 14
 EDGE      15,      16,    11,     7,         31    \ Edge 15
 EDGE      16,      17,    11,     8,         31    \ Edge 16
 EDGE      17,      18,    11,     9,         31    \ Edge 17
 EDGE      18,      19,    11,    10,         31    \ Edge 18
 EDGE      19,      15,    11,     6,         31    \ Edge 19
 EDGE       0,       5,     5,     1,         31    \ Edge 20
 EDGE       1,       6,     2,     1,         31    \ Edge 21
 EDGE       2,       7,     3,     2,         31    \ Edge 22
 EDGE       3,       8,     4,     3,         31    \ Edge 23
 EDGE       4,       9,     5,     4,         31    \ Edge 24
 EDGE      10,      15,     7,     6,         31    \ Edge 25
 EDGE      11,      16,     8,     7,         31    \ Edge 26
 EDGE      12,      17,     9,     8,         31    \ Edge 27
 EDGE      13,      18,    10,     9,         31    \ Edge 28
 EDGE      14,      19,    10,     6,         31    \ Edge 29
 EDGE      20,      21,     0,     0,         30    \ Edge 30
 EDGE      21,      23,     0,     0,         20    \ Edge 31
 EDGE      23,      22,     0,     0,         23    \ Edge 32
 EDGE      22,      20,     0,     0,         20    \ Edge 33

.SHIP_DODO_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,        0,      196,         31    \ Face 0
 FACE      103,      142,       88,         31    \ Face 1
 FACE      169,      -55,       89,         31    \ Face 2
 FACE        0,     -176,       88,         31    \ Face 3
 FACE     -169,      -55,       89,         31    \ Face 4
 FACE     -103,      142,       88,         31    \ Face 5
 FACE        0,      176,      -88,         31    \ Face 6
 FACE      169,       55,      -89,         31    \ Face 7
 FACE      103,     -142,      -88,         31    \ Face 8
 FACE     -103,     -142,      -88,         31    \ Face 9
 FACE     -169,       55,      -89,         31    \ Face 10
 FACE        0,        0,     -196,         31    \ Face 11

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

\ EQUB 17               \ Max. energy              = 17

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

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 12                \ Visibility distance      = 12

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 17               \ Max. energy              = 17

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

\ EQUB 100              \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 91                \ Max. energy              = 91

                        \ --- End of replacement ------------------------------>

 EQUB 32                \ Max. speed               = 32

 EQUB HI(SHIP_VIPER_EDGES - SHIP_VIPER)            \ Edges data offset (high)
 EQUB HI(SHIP_VIPER_FACES - SHIP_VIPER)            \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00010001        \ Laser power              = 2
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
\       Name: SHIP_TRANSPORTER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Transporter
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_TRANSPORTER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 50 * 50           \ Targetable area          = 50 * 50

 EQUB LO(SHIP_TRANSPORTER_EDGES - SHIP_TRANSPORTER)   \ Edges data offset (low)
 EQUB LO(SHIP_TRANSPORTER_FACES - SHIP_TRANSPORTER)   \ Faces data offset (low)

 EQUB 145               \ Max. edge count          = (145 - 1) / 4 = 36
 EQUB 48                \ Gun vertex               = 48 / 4 = 12
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 222               \ Number of vertices       = 222 / 6 = 37
 EQUB 46                \ Number of edges          = 46
 EQUW 0                 \ Bounty                   = 0
 EQUB 56                \ Number of faces          = 56 / 4 = 14
 EQUB 16                \ Visibility distance      = 16
 EQUB 32                \ Max. energy              = 32
 EQUB 10                \ Max. speed               = 10

 EQUB HI(SHIP_TRANSPORTER_EDGES - SHIP_TRANSPORTER)   \ Edges data offset (high)
 EQUB HI(SHIP_TRANSPORTER_FACES - SHIP_TRANSPORTER)   \ Faces data offset (high)

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 2                \ Normals are scaled by    = 2^2 = 4

                        \ --- And replaced by: -------------------------------->

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- End of replacement ------------------------------>

 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_TRANSPORTER_VERTICES

                        \ --- Mod: Code removed for Elite-A: ------------------>

\     \    x,    y,    z, face1, face2, face3, face4, visibility
\ VERTEX    0,   10,  -26,     6,      0,    7,     7,         31   \ Vertex 0
\ VERTEX  -25,    4,  -26,     1,      0,    7,     7,         31   \ Vertex 1
\ VERTEX  -28,   -3,  -26,     1,      0,    2,     2,         31   \ Vertex 2
\ VERTEX  -25,   -8,  -26,     2,      0,    3,     3,         31   \ Vertex 3
\ VERTEX   26,   -8,  -26,     3,      0,    4,     4,         31   \ Vertex 4
\ VERTEX   29,   -3,  -26,     4,      0,    5,     5,         31   \ Vertex 5
\ VERTEX   26,    4,  -26,     5,      0,    6,     6,         31   \ Vertex 6
\ VERTEX    0,    6,   12,    15,     15,   15,    15,         19   \ Vertex 7
\ VERTEX  -30,   -1,   12,     7,      1,    9,     8,         31   \ Vertex 8
\ VERTEX  -33,   -8,   12,     2,      1,    9,     3,         31   \ Vertex 9
\ VERTEX   33,   -8,   12,     4,      3,   10,     5,         31   \ Vertex 10
\ VERTEX   30,   -1,   12,     6,      5,   11,    10,         31   \ Vertex 11
\ VERTEX  -11,   -2,   30,     9,      8,   13,    12,         31   \ Vertex 12
\ VERTEX  -13,   -8,   30,     9,      3,   13,    13,         31   \ Vertex 13
\ VERTEX   14,   -8,   30,    10,      3,   13,    13,         31   \ Vertex 14
\ VERTEX   11,   -2,   30,    11,     10,   13,    12,         31   \ Vertex 15
\ VERTEX   -5,    6,    2,     7,      7,    7,     7,          7   \ Vertex 16
\ VERTEX  -18,    3,    2,     7,      7,    7,     7,          7   \ Vertex 17
\ VERTEX   -5,    7,   -7,     7,      7,    7,     7,          7   \ Vertex 18
\ VERTEX  -18,    4,   -7,     7,      7,    7,     7,          7   \ Vertex 19
\ VERTEX  -11,    6,  -14,     7,      7,    7,     7,          7   \ Vertex 20
\ VERTEX  -11,    5,   -7,     7,      7,    7,     7,          7   \ Vertex 21
\ VERTEX    5,    7,  -14,     6,      6,    6,     6,          7   \ Vertex 22
\ VERTEX   18,    4,  -14,     6,      6,    6,     6,          7   \ Vertex 23
\ VERTEX   11,    5,   -7,     6,      6,    6,     6,          7   \ Vertex 24
\ VERTEX    5,    6,   -3,     6,      6,    6,     6,          7   \ Vertex 25
\ VERTEX   18,    3,   -3,     6,      6,    6,     6,          7   \ Vertex 26
\ VERTEX   11,    4,    8,     6,      6,    6,     6,          7   \ Vertex 27
\ VERTEX   11,    5,   -3,     6,      6,    6,     6,          7   \ Vertex 28
\ VERTEX  -16,   -8,  -13,     3,      3,    3,     3,          6   \ Vertex 29
\ VERTEX  -16,   -8,   16,     3,      3,    3,     3,          6   \ Vertex 30
\ VERTEX   17,   -8,  -13,     3,      3,    3,     3,          6   \ Vertex 31
\ VERTEX   17,   -8,   16,     3,      3,    3,     3,          6   \ Vertex 32
\ VERTEX  -13,   -3,  -26,     0,      0,    0,     0,          8   \ Vertex 33
\ VERTEX   13,   -3,  -26,     0,      0,    0,     0,          8   \ Vertex 34
\ VERTEX    9,    3,  -26,     0,      0,    0,     0,          5   \ Vertex 35
\ VERTEX   -8,    3,  -26,     0,      0,    0,     0,          5   \ Vertex 36

                        \ --- And replaced by: -------------------------------->

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   19,  -51,     6,     0,     7,     7,         31     \ Vertex 0
 VERTEX  -51,    7,  -51,     1,     0,     7,     7,         31     \ Vertex 1
 VERTEX  -57,   -7,  -51,     1,     0,     2,     2,         31     \ Vertex 2
 VERTEX  -51,  -17,  -51,     2,     0,     3,     3,         31     \ Vertex 3
 VERTEX   51,  -17,  -51,     3,     0,     4,     4,         31     \ Vertex 4
 VERTEX   57,   -7,  -51,     4,     0,     5,     5,         31     \ Vertex 5
 VERTEX   51,    7,  -51,     5,     0,     6,     6,         31     \ Vertex 6
 VERTEX    0,   12,   24,    15,    15,    15,    15,         18     \ Vertex 7
 VERTEX  -60,   -2,   24,     7,     1,     9,     8,         31     \ Vertex 8
 VERTEX  -66,  -17,   24,     2,     1,     9,     3,         31     \ Vertex 9
 VERTEX   66,  -17,   24,     4,     3,    10,     5,         31     \ Vertex 10
 VERTEX   60,   -2,   24,     6,     5,    11,    10,         31     \ Vertex 11
 VERTEX  -22,   -5,   61,     9,     8,    13,    12,         31     \ Vertex 12
 VERTEX  -27,  -17,   61,     9,     3,    13,    13,         31     \ Vertex 13
 VERTEX   27,  -17,   61,    10,     3,    13,    13,         31     \ Vertex 14
 VERTEX   22,   -5,   61,    11,    10,    13,    12,         31     \ Vertex 15
 VERTEX  -10,   11,    5,     7,     7,     7,     7,          6     \ Vertex 16
 VERTEX  -36,    5,    5,     7,     7,     7,     7,          6     \ Vertex 17
 VERTEX  -10,   13,  -14,     7,     7,     7,     7,          6     \ Vertex 18
 VERTEX  -36,    7,  -14,     7,     7,     7,     7,          6     \ Vertex 19
 VERTEX  -23,   12,  -29,     7,     7,     7,     7,          6     \ Vertex 20
 VERTEX  -23,   10,  -14,     7,     7,     7,     7,          6     \ Vertex 21
 VERTEX   10,   15,  -29,     6,     6,     6,     6,          6     \ Vertex 22
 VERTEX   36,    9,  -29,     6,     6,     6,     6,          6     \ Vertex 23
 VERTEX   23,   10,  -14,     6,     6,     6,     6,          6     \ Vertex 24
 VERTEX   10,   12,   -6,     6,     6,     6,     6,          6     \ Vertex 25
 VERTEX   36,    6,   -6,     6,     6,     6,     6,          6     \ Vertex 26
 VERTEX   23,    7,   16,     6,     6,     6,     6,          6     \ Vertex 27
 VERTEX   23,    9,   -6,     6,     6,     6,     6,          6     \ Vertex 28
 VERTEX  -33,  -17,  -26,     3,     3,     3,     3,          5     \ Vertex 29
 VERTEX  -33,  -17,   33,     3,     3,     3,     3,          5     \ Vertex 30
 VERTEX   33,  -17,  -26,     3,     3,     3,     3,          5     \ Vertex 31
 VERTEX   33,  -17,   33,     3,     3,     3,     3,          5     \ Vertex 32
 VERTEX  -25,   -6,  -51,     0,     0,     0,     0,          7     \ Vertex 33
 VERTEX   26,   -6,  -51,     0,     0,     0,     0,          7     \ Vertex 34
 VERTEX   17,    6,  -51,     0,     0,     0,     0,          4     \ Vertex 35
 VERTEX  -17,    6,  -51,     0,     0,     0,     0,          4     \ Vertex 36

                        \ --- End of replacement ------------------------------>

.SHIP_TRANSPORTER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    \ Edge 0
 EDGE       1,       2,     1,     0,         31    \ Edge 1
 EDGE       2,       3,     2,     0,         31    \ Edge 2
 EDGE       3,       4,     3,     0,         31    \ Edge 3
 EDGE       4,       5,     4,     0,         31    \ Edge 4
 EDGE       5,       6,     5,     0,         31    \ Edge 5
 EDGE       0,       6,     6,     0,         31    \ Edge 6

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE       0,       7,     7,     6,         16   \ Edge 7

                        \ --- And replaced by: -------------------------------->

 EDGE       0,       7,     7,     6,         15    \ Edge 7

                        \ --- End of replacement ------------------------------>

 EDGE       1,       8,     7,     1,         31    \ Edge 8

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE       2,       9,     2,     1,         11   \ Edge 9

                        \ --- And replaced by: -------------------------------->

 EDGE       2,       9,     2,     1,         10    \ Edge 9

                        \ --- End of replacement ------------------------------>

 EDGE       3,       9,     3,     2,         31    \ Edge 10
 EDGE       4,      10,     4,     3,         31    \ Edge 11

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE       5,      10,     5,     4,         11   \ Edge 12

                        \ --- And replaced by: -------------------------------->

 EDGE       5,      10,     5,     4,         10    \ Edge 12

                        \ --- End of replacement ------------------------------>

 EDGE       6,      11,     6,     5,         31    \ Edge 13

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE       7,       8,     8,     7,         17   \ Edge 14
\ EDGE       8,       9,     9,     1,         17   \ Edge 15
\ EDGE      10,      11,    10,     5,         17   \ Edge 16
\ EDGE       7,      11,    11,     6,         17   \ Edge 17
\ EDGE       7,      15,    12,    11,         19   \ Edge 18
\ EDGE       7,      12,    12,     8,         19   \ Edge 19

                        \ --- And replaced by: -------------------------------->

 EDGE       7,       8,     8,     7,         16    \ Edge 14
 EDGE       8,       9,     9,     1,         16    \ Edge 15
 EDGE      10,      11,    10,     5,         16    \ Edge 16
 EDGE       7,      11,    11,     6,         16    \ Edge 17
 EDGE       7,      15,    12,    11,         18    \ Edge 18
 EDGE       7,      12,    12,     8,         18    \ Edge 19

                        \ --- End of replacement ------------------------------>

 EDGE       8,      12,     9,     8,         16    \ Edge 20
 EDGE       9,      13,     9,     3,         31    \ Edge 21
 EDGE      10,      14,    10,     3,         31    \ Edge 22
 EDGE      11,      15,    11,    10,         16    \ Edge 23
 EDGE      12,      13,    13,     9,         31    \ Edge 24
 EDGE      13,      14,    13,     3,         31    \ Edge 25
 EDGE      14,      15,    13,    10,         31    \ Edge 26
 EDGE      12,      15,    13,    12,         31    \ Edge 27

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE      16,      17,     7,     7,          7   \ Edge 28
\ EDGE      18,      19,     7,     7,          7   \ Edge 29
\ EDGE      19,      20,     7,     7,          7   \ Edge 30
\ EDGE      18,      20,     7,     7,          7   \ Edge 31
\ EDGE      20,      21,     7,     7,          7   \ Edge 32
\ EDGE      22,      23,     6,     6,          7   \ Edge 33
\ EDGE      23,      24,     6,     6,          7   \ Edge 34
\ EDGE      24,      22,     6,     6,          7   \ Edge 35
\ EDGE      25,      26,     6,     6,          7   \ Edge 36
\ EDGE      26,      27,     6,     6,          7   \ Edge 37
\ EDGE      25,      27,     6,     6,          7   \ Edge 38
\ EDGE      27,      28,     6,     6,          7   \ Edge 39
\ EDGE      29,      30,     3,     3,          6   \ Edge 40
\ EDGE      31,      32,     3,     3,          6   \ Edge 41
\ EDGE      33,      34,     0,     0,          8   \ Edge 42
\ EDGE      34,      35,     0,     0,          5   \ Edge 43
\ EDGE      35,      36,     0,     0,          5   \ Edge 44
\ EDGE      36,      33,     0,     0,          5   \ Edge 45

                        \ --- And replaced by: -------------------------------->

 EDGE      16,      17,     7,     7,          6    \ Edge 28
 EDGE      18,      19,     7,     7,          6    \ Edge 29
 EDGE      19,      20,     7,     7,          6    \ Edge 30
 EDGE      18,      20,     7,     7,          6    \ Edge 31
 EDGE      20,      21,     7,     7,          6    \ Edge 32
 EDGE      22,      23,     6,     6,          6    \ Edge 33
 EDGE      23,      24,     6,     6,          6    \ Edge 34
 EDGE      24,      22,     6,     6,          6    \ Edge 35
 EDGE      25,      26,     6,     6,          6    \ Edge 36
 EDGE      26,      27,     6,     6,          6    \ Edge 37
 EDGE      25,      27,     6,     6,          6    \ Edge 38
 EDGE      27,      28,     6,     6,          6    \ Edge 39
 EDGE      29,      30,     3,     3,          5    \ Edge 40
 EDGE      31,      32,     3,     3,          5    \ Edge 41
 EDGE      33,      34,     0,     0,          7    \ Edge 42
 EDGE      34,      35,     0,     0,          4    \ Edge 43
 EDGE      35,      36,     0,     0,          4    \ Edge 44
 EDGE      36,      33,     0,     0,          4    \ Edge 45

                        \ --- End of replacement ------------------------------>

.SHIP_TRANSPORTER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,        0,     -103,         31    \ Face 0
 FACE     -111,       48,       -7,         31    \ Face 1
 FACE     -105,      -63,      -21,         31    \ Face 2
 FACE        0,      -34,        0,         31    \ Face 3
 FACE      105,      -63,      -21,         31    \ Face 4
 FACE      111,       48,       -7,         31    \ Face 5
 FACE        8,       32,        3,         31    \ Face 6
 FACE       -8,       32,        3,         31    \ Face 7

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ FACE       -8,       34,       11,         19   \ Face 8

                        \ --- And replaced by: -------------------------------->

 FACE       -8,       34,       11,         18    \ Face 8

                        \ --- End of replacement ------------------------------>

 FACE      -75,       32,       79,         31    \ Face 9
 FACE       75,       32,       79,         31    \ Face 10

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ FACE        8,       34,       11,         19   \ Face 11

                        \ --- And replaced by: -------------------------------->

 FACE        8,       34,       11,         18    \ Face 11

                        \ --- End of replacement ------------------------------>

 FACE        0,       38,       17,         31    \ Face 12
 FACE        0,        0,      121,         31    \ Face 13

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
 FACE        0,       90,       31,         31    \ Face 0
 FACE        0,      -90,       31,         31    \ Face 1
 FACE      -57,       76,       11,         31    \ Face 2
 FACE       57,       76,       11,         31    \ Face 3
 FACE       57,      -76,       11,         31    \ Face 4
 FACE      -57,      -76,       11,         31    \ Face 5
 FACE        0,       96,        0,         31    \ Face 6
 FACE        0,      -96,        0,         31    \ Face 7
 FACE      -57,       76,      -11,         31    \ Face 8
 FACE       57,       76,      -11,         31    \ Face 9
 FACE       57,      -76,      -11,         31    \ Face 10
 FACE      -57,      -76,      -11,         31    \ Face 11
 FACE        0,        0,      -96,         31    \ Face 12

                        \ --- End of added code ------------------------------->

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

\ EQUB 90               \ Max. energy              = 90

                        \ --- And replaced by: -------------------------------->

 EQUB 80                \ Max. energy              = 80

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_MAMBA_EDGES - SHIP_MAMBA)            \ Edges data offset (high)
 EQUB HI(SHIP_MAMBA_FACES - SHIP_MAMBA)            \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00010010        \ Laser power              = 2
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
 FACE        0,      -24,        2,         30    \ Face 0
 FACE        0,       24,        2,         30    \ Face 1
 FACE      -32,       64,       16,         30    \ Face 2
 FACE       32,       64,       16,         30    \ Face 3
 FACE        0,        0,     -127,         30    \ Face 4

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
 FACE        0,       37,       12,         31    \ Face 0
 FACE       11,       28,        5,         31    \ Face 1
 FACE      -11,       28,        5,         31    \ Face 2
 FACE       16,       34,        2,         31    \ Face 3
 FACE      -16,       34,        2,         31    \ Face 4
 FACE        0,       37,       -3,         31    \ Face 5
 FACE        0,      -31,       10,         31    \ Face 6
 FACE       10,      -20,        2,         31    \ Face 7
 FACE      -10,      -20,        2,         31    \ Face 8
 FACE       18,      -32,       -2,         31    \ Face 9
 FACE      -18,      -32,       -2,         31    \ Face 10
 FACE        0,        0,      -37,         31    \ Face 11

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

\ EQUB 100              \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 89                \ Max. energy              = 89

                        \ --- End of replacement ------------------------------>

 EQUB 25                \ Max. speed               = 25

 EQUB HI(SHIP_MORAY_EDGES - SHIP_MORAY)            \ Edges data offset (high)
 EQUB HI(SHIP_MORAY_FACES - SHIP_MORAY)            \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00010000        \ Laser power              = 2
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
\ Save S.P.bin
\
\ ******************************************************************************

 PRINT "S.S.P ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/S.P.bin", CODE%, CODE% + &0A00
