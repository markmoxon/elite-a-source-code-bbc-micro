\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE L
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
\   * S.L.bin
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
\    Summary: Ship blueprints lookup table for the S.L file
\  Deep dive: Ship blueprints in Elite-A
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile                            Missile
 EQUW SHIP_DODO         \         2 = Dodo space station                 Station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod                      Escape pod
 EQUW SHIP_PLATE        \ PLT  =  4 = Alloy plate                          Cargo
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister                       Cargo
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW SHIP_SHUTTLE      \ SHU  =  9 = Shuttle                            Shuttle
 EQUW 0                 \                                            Transporter
 EQUW SHIP_BOA          \        11 = Boa                                 Trader
 EQUW SHIP_OPHIDIAN     \        12 = Ophidian                            Trader
 EQUW SHIP_CHAMELEON    \        13 = Chameleon                           Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_SIDEWINDER   \        17 = Sidewinder                          Pirate
 EQUW SHIP_KRAIT        \        18 = Krait                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_OPHIDIAN     \        21 = Ophidian                            Pirate
 EQUW SHIP_CHAMELEON    \        22 = Chameleon                           Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                          Bounty hunter
 EQUW 0                 \                                          Bounty hunter
 EQUW 0                 \                                          Bounty hunter
 EQUW SHIP_SIDEWINDER   \        28 = Sidewinder                   Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.L file
\  Deep dive: Ship blueprints in Elite-A
\             Advanced tactics with the NEWB flags
\
\ ******************************************************************************

.E%

 EQUB %00000000         \ Missile
 EQUB %01000000         \ Dodo space station                                 Cop
 EQUB %01000001         \ Escape pod                                 Trader, cop
 EQUB %00000000         \ Alloy plate
 EQUB %00000000         \ Cargo canister
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %00100001         \ Shuttle                               Trader, innocent
 EQUB 0
 EQUB %10100000         \ Boa                               Innocent, escape pod
 EQUB %10100001         \ Ophidian                  Trader, innocent, escape pod
 EQUB %10100000         \ Chameleon                         Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %00001100         \ Sidewinder                             Hostile, pirate
 EQUB %10001100         \ Krait                      Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB %10001100         \ Chameleon                  Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %00100010         \ Sidewinder                     Bounty hunter, innocent
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
\       Name: SHIP_SHUTTLE
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Shuttle
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_SHUTTLE

 EQUB 15                \ Max. canisters on demise = 15
 EQUW 50 * 50           \ Targetable area          = 50 * 50

 EQUB LO(SHIP_SHUTTLE_EDGES - SHIP_SHUTTLE)        \ Edges data offset (low)
 EQUB LO(SHIP_SHUTTLE_FACES - SHIP_SHUTTLE)        \ Faces data offset (low)

 EQUB 109               \ Max. edge count          = (109 - 1) / 4 = 27
 EQUB 0                 \ Gun vertex               = 0
 EQUB 38                \ Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 114               \ Number of vertices       = 114 / 6 = 19
 EQUB 30                \ Number of edges          = 30
 EQUW 0                 \ Bounty                   = 0
 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 22                \ Visibility distance      = 22
 EQUB 32                \ Max. energy              = 32
 EQUB 8                 \ Max. speed               = 8

 EQUB HI(SHIP_SHUTTLE_EDGES - SHIP_SHUTTLE)        \ Edges data offset (high)
 EQUB HI(SHIP_SHUTTLE_FACES - SHIP_SHUTTLE)        \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_SHUTTLE_VERTICES

                        \ --- Mod: Code removed for Elite-A: ------------------>

\     \    x,    y,    z, face1, face2, face3, face4, visibility
\ VERTEX    0,  -17,   23,    15,     15,   15,    15,         31   \ Vertex 0
\ VERTEX  -17,    0,   23,    15,     15,   15,    15,         31   \ Vertex 1
\ VERTEX    0,   18,   23,    15,     15,   15,    15,         31   \ Vertex 2
\ VERTEX   18,    0,   23,    15,     15,   15,    15,         31   \ Vertex 3
\ VERTEX  -20,  -20,  -27,     2,      1,    9,     3,         31   \ Vertex 4
\ VERTEX  -20,   20,  -27,     4,      3,    9,     5,         31   \ Vertex 5
\ VERTEX   20,   20,  -27,     6,      5,    9,     7,         31   \ Vertex 6
\ VERTEX   20,  -20,  -27,     7,      1,    9,     8,         31   \ Vertex 7
\ VERTEX    5,    0,  -27,     9,      9,    9,     9,         16   \ Vertex 8
\ VERTEX    0,   -2,  -27,     9,      9,    9,     9,         16   \ Vertex 9
\ VERTEX   -5,    0,  -27,     9,      9,    9,     9,          9   \ Vertex 10
\ VERTEX    0,    3,  -27,     9,      9,    9,     9,          9   \ Vertex 11
\ VERTEX    0,   -9,   35,    10,      0,   12,    11,         16   \ Vertex 12
\ VERTEX    3,   -1,   31,    15,     15,    2,     0,          7   \ Vertex 13
\ VERTEX    4,   11,   25,     1,      0,    4,    15,          8   \ Vertex 14
\ VERTEX   11,    4,   25,     1,     10,   15,     3,          8   \ Vertex 15
\ VERTEX   -3,   -1,   31,    11,      6,    3,     2,          7   \ Vertex 16
\ VERTEX   -3,   11,   25,     8,     15,    0,    12,          8   \ Vertex 17
\ VERTEX  -10,    4,   25,    15,      4,    8,     1,          8   \ Vertex 18

                        \ --- And replaced by: -------------------------------->

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -35,   47,    15,    15,    15,    15,         31     \ Vertex 0
 VERTEX  -35,    0,   47,    15,    15,    15,    15,         31     \ Vertex 1
 VERTEX    0,   35,   47,    15,    15,    15,    15,         31     \ Vertex 2
 VERTEX   35,    0,   47,    15,    15,    15,    15,         31     \ Vertex 3
 VERTEX  -40,  -40,  -53,     2,     1,     9,     3,         31     \ Vertex 4
 VERTEX  -40,   40,  -53,     4,     3,     9,     5,         31     \ Vertex 5
 VERTEX   40,   40,  -53,     6,     5,     9,     7,         31     \ Vertex 6
 VERTEX   40,  -40,  -53,     7,     1,     9,     8,         31     \ Vertex 7
 VERTEX   10,    0,  -53,     9,     9,     9,     9,         16     \ Vertex 8
 VERTEX    0,   -5,  -53,     9,     9,     9,     9,         16     \ Vertex 9
 VERTEX  -10,    0,  -53,     9,     9,     9,     9,          8     \ Vertex 10
 VERTEX    0,    5,  -53,     9,     9,     9,     9,          8     \ Vertex 11
 VERTEX    0,  -17,   71,    10,     0,    12,    11,         16     \ Vertex 12
 VERTEX    5,   -2,   61,    15,    15,     2,     0,          6     \ Vertex 13
 VERTEX    7,   23,   49,     1,     0,     4,    15,          7     \ Vertex 14
 VERTEX   21,    9,   49,     1,    10,    15,     3,          7     \ Vertex 15
 VERTEX   -5,   -2,   61,    11,     6,     3,     2,          6     \ Vertex 16
 VERTEX   -7,   23,   49,     8,    15,     0,    12,          7     \ Vertex 17
 VERTEX  -21,    9,   49,    15,     4,     8,     1,          7     \ Vertex 18

                        \ --- End of replacement ------------------------------>

.SHIP_SHUTTLE_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     0,         31    \ Edge 0
 EDGE       1,       2,    10,     4,         31    \ Edge 1
 EDGE       2,       3,    11,     6,         31    \ Edge 2
 EDGE       0,       3,    12,     8,         31    \ Edge 3
 EDGE       0,       7,     8,     1,         31    \ Edge 4
 EDGE       0,       4,     2,     1,         24    \ Edge 5
 EDGE       1,       4,     3,     2,         31    \ Edge 6
 EDGE       1,       5,     4,     3,         24    \ Edge 7
 EDGE       2,       5,     5,     4,         31    \ Edge 8
 EDGE       2,       6,     6,     5,         12    \ Edge 9
 EDGE       3,       6,     7,     6,         31    \ Edge 10
 EDGE       3,       7,     8,     7,         24    \ Edge 11
 EDGE       4,       5,     9,     3,         31    \ Edge 12
 EDGE       5,       6,     9,     5,         31    \ Edge 13
 EDGE       6,       7,     9,     7,         31    \ Edge 14
 EDGE       4,       7,     9,     1,         31    \ Edge 15
 EDGE       0,      12,    12,     0,         16    \ Edge 16
 EDGE       1,      12,    10,     0,         16    \ Edge 17
 EDGE       2,      12,    11,    10,         16    \ Edge 18
 EDGE       3,      12,    12,    11,         16    \ Edge 19
 EDGE       8,       9,     9,     9,         16    \ Edge 20

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EDGE       9,      10,     9,     9,          7   \ Edge 21
\ EDGE      10,      11,     9,     9,          9   \ Edge 22
\ EDGE       8,      11,     9,     9,          7   \ Edge 23
\ EDGE      13,      14,    11,    11,          5   \ Edge 24
\ EDGE      14,      15,    11,    11,          8   \ Edge 25
\ EDGE      13,      15,    11,    11,          7   \ Edge 26
\ EDGE      16,      17,    10,    10,          5   \ Edge 27
\ EDGE      17,      18,    10,    10,          8   \ Edge 28
\ EDGE      16,      18,    10,    10,          7   \ Edge 29

                        \ --- And replaced by: -------------------------------->

 EDGE       9,      10,     9,     9,          6    \ Edge 21
 EDGE      10,      11,     9,     9,          8    \ Edge 22
 EDGE       8,      11,     9,     9,          6    \ Edge 23
 EDGE      13,      14,    11,    11,          4    \ Edge 24
 EDGE      14,      15,    11,    11,          7    \ Edge 25
 EDGE      13,      15,    11,    11,          6    \ Edge 26
 EDGE      16,      17,    10,    10,          4    \ Edge 27
 EDGE      17,      18,    10,    10,          7    \ Edge 28
 EDGE      16,      18,    10,    10,          6    \ Edge 29

                        \ --- End of replacement ------------------------------>

.SHIP_SHUTTLE_FACES

                        \ --- Mod: Code removed for Elite-A: ------------------>

\   \ normal_x, normal_y, normal_z, visibility
\ FACE      -55,      -55,       40,         31   \ Face 0
\ FACE        0,      -74,        4,         31   \ Face 1
\ FACE      -51,      -51,       23,         31   \ Face 2
\ FACE      -74,        0,        4,         31   \ Face 3
\ FACE      -51,       51,       23,         31   \ Face 4
\ FACE        0,       74,        4,         31   \ Face 5
\ FACE       51,       51,       23,         31   \ Face 6
\ FACE       74,        0,        4,         31   \ Face 7
\ FACE       51,      -51,       23,         31   \ Face 8
\ FACE        0,        0,     -107,         31   \ Face 9
\ FACE      -41,       41,       90,         31   \ Face 10
\ FACE       41,       41,       90,         31   \ Face 11
\ FACE       55,      -55,       40,         31   \ Face 12

                        \ --- And replaced by: -------------------------------->

    \ normal_x, normal_y, normal_z, visibility
 FACE     -110,     -110,       80,         31    \ Face 0
 FACE        0,     -149,        7,         31    \ Face 1
 FACE     -102,     -102,       46,         31    \ Face 2
 FACE     -149,        0,        7,         31    \ Face 3
 FACE     -102,      102,       46,         31    \ Face 4
 FACE        0,      149,        7,         31    \ Face 5
 FACE      102,      102,       46,         31    \ Face 6
 FACE      149,        0,        7,         31    \ Face 7
 FACE      102,     -102,       46,         31    \ Face 8
 FACE        0,        0,     -213,         31    \ Face 9
 FACE      -81,       81,      177,         31    \ Face 10
 FACE       81,       81,      177,         31    \ Face 11
 FACE      110,     -110,       80,         31    \ Face 12

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: SHIP_SIDEWINDER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Sidewinder
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_SIDEWINDER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 65 * 65           \ Targetable area          = 65 * 65

 EQUB LO(SHIP_SIDEWINDER_EDGES - SHIP_SIDEWINDER)  \ Edges data offset (low)
 EQUB LO(SHIP_SIDEWINDER_FACES - SHIP_SIDEWINDER)  \ Faces data offset (low)

 EQUB 61                \ Max. edge count          = (61 - 1) / 4 = 15
 EQUB 0                 \ Gun vertex               = 0
 EQUB 30                \ Explosion count          = 6, as (4 * n) + 6 = 30
 EQUB 60                \ Number of vertices       = 60 / 6 = 10
 EQUB 15                \ Number of edges          = 15

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUW 50               \ Bounty                   = 50

                        \ --- And replaced by: -------------------------------->

 EQUW 100               \ Bounty                   = 100

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 20                \ Visibility distance      = 20

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 70               \ Max. energy              = 70

                        \ --- And replaced by: -------------------------------->

 EQUB 73                \ Max. energy              = 73

                        \ --- End of replacement ------------------------------>

 EQUB 37                \ Max. speed               = 37

 EQUB HI(SHIP_SIDEWINDER_EDGES - SHIP_SIDEWINDER)  \ Edges data offset (high)
 EQUB HI(SHIP_SIDEWINDER_FACES - SHIP_SIDEWINDER)  \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00010000        \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

                        \ --- End of replacement ------------------------------>

.SHIP_SIDEWINDER_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -32,    0,   36,     0,      1,    4,     5,         31    \ Vertex 0
 VERTEX   32,    0,   36,     0,      2,    5,     6,         31    \ Vertex 1
 VERTEX   64,    0,  -28,     2,      3,    6,     6,         31    \ Vertex 2
 VERTEX  -64,    0,  -28,     1,      3,    4,     4,         31    \ Vertex 3
 VERTEX    0,   16,  -28,     0,      1,    2,     3,         31    \ Vertex 4
 VERTEX    0,  -16,  -28,     3,      4,    5,     6,         31    \ Vertex 5
 VERTEX  -12,    6,  -28,     3,      3,    3,     3,         15    \ Vertex 6
 VERTEX   12,    6,  -28,     3,      3,    3,     3,         15    \ Vertex 7
 VERTEX   12,   -6,  -28,     3,      3,    3,     3,         12    \ Vertex 8
 VERTEX  -12,   -6,  -28,     3,      3,    3,     3,         12    \ Vertex 9

.SHIP_SIDEWINDER_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     0,     5,         31    \ Edge 0
 EDGE       1,       2,     2,     6,         31    \ Edge 1
 EDGE       1,       4,     0,     2,         31    \ Edge 2
 EDGE       0,       4,     0,     1,         31    \ Edge 3
 EDGE       0,       3,     1,     4,         31    \ Edge 4
 EDGE       3,       4,     1,     3,         31    \ Edge 5
 EDGE       2,       4,     2,     3,         31    \ Edge 6
 EDGE       3,       5,     3,     4,         31    \ Edge 7
 EDGE       2,       5,     3,     6,         31    \ Edge 8
 EDGE       1,       5,     5,     6,         31    \ Edge 9
 EDGE       0,       5,     4,     5,         31    \ Edge 10
 EDGE       6,       7,     3,     3,         15    \ Edge 11
 EDGE       7,       8,     3,     3,         12    \ Edge 12
 EDGE       6,       9,     3,     3,         12    \ Edge 13
 EDGE       8,       9,     3,     3,         12    \ Edge 14

.SHIP_SIDEWINDER_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        8,         31    \ Face 0
 FACE      -12,       47,        6,         31    \ Face 1
 FACE       12,       47,        6,         31    \ Face 2
 FACE        0,        0,     -112,         31    \ Face 3
 FACE      -12,      -47,        6,         31    \ Face 4
 FACE        0,      -32,        8,         31    \ Face 5
 FACE       12,      -47,        6,         31    \ Face 6

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
\       Name: SHIP_BOA
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Boa
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_BOA

 EQUB 5                 \ Max. canisters on demise = 5
 EQUW 70 * 70           \ Targetable area          = 70 * 70

 EQUB LO(SHIP_BOA_EDGES - SHIP_BOA)                \ Edges data offset (low)
 EQUB LO(SHIP_BOA_FACES - SHIP_BOA)                \ Faces data offset (low)

 EQUB 89                \ Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 \ Gun vertex               = 0
 EQUB 38                \ Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 78                \ Number of vertices       = 78 / 6 = 13
 EQUB 24                \ Number of edges          = 24

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 250               \ Bounty                   = 250

                        \ --- End of replacement ------------------------------>

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 250              \ Max. energy              = 250

                        \ --- And replaced by: -------------------------------->

 EQUB 164               \ Max. energy              = 164

                        \ --- End of replacement ------------------------------>

 EQUB 24                \ Max. speed               = 24

 EQUB HI(SHIP_BOA_EDGES - SHIP_BOA)                \ Edges data offset (high)
 EQUB HI(SHIP_BOA_FACES - SHIP_BOA)                \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00011100        \ Laser power              = 3
\                       \ Missiles                 = 4

                        \ --- And replaced by: -------------------------------->

 EQUB %00101010         \ Laser power              = 5
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

.SHIP_BOA_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   93,    15,     15,   15,    15,         31    \ Vertex 0
 VERTEX    0,   40,  -87,     2,      0,    3,     3,         24    \ Vertex 1
 VERTEX   38,  -25,  -99,     1,      0,    4,     4,         24    \ Vertex 2
 VERTEX  -38,  -25,  -99,     2,      1,    5,     5,         24    \ Vertex 3
 VERTEX  -38,   40,  -59,     3,      2,    9,     6,         31    \ Vertex 4
 VERTEX   38,   40,  -59,     3,      0,   11,     6,         31    \ Vertex 5
 VERTEX   62,    0,  -67,     4,      0,   11,     8,         31    \ Vertex 6
 VERTEX   24,  -65,  -79,     4,      1,   10,     8,         31    \ Vertex 7
 VERTEX  -24,  -65,  -79,     5,      1,   10,     7,         31    \ Vertex 8
 VERTEX  -62,    0,  -67,     5,      2,    9,     7,         31    \ Vertex 9
 VERTEX    0,    7, -107,     2,      0,   10,    10,         22    \ Vertex 10
 VERTEX   13,   -9, -107,     1,      0,   10,    10,         22    \ Vertex 11
 VERTEX  -13,   -9, -107,     2,      1,   12,    12,         22    \ Vertex 12

.SHIP_BOA_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       5,    11,     6,         31    \ Edge 0
 EDGE       0,       7,    10,     8,         31    \ Edge 1
 EDGE       0,       9,     9,     7,         31    \ Edge 2
 EDGE       0,       4,     9,     6,         29    \ Edge 3
 EDGE       0,       6,    11,     8,         29    \ Edge 4
 EDGE       0,       8,    10,     7,         29    \ Edge 5
 EDGE       4,       5,     6,     3,         31    \ Edge 6
 EDGE       5,       6,    11,     0,         31    \ Edge 7
 EDGE       6,       7,     8,     4,         31    \ Edge 8
 EDGE       7,       8,    10,     1,         31    \ Edge 9
 EDGE       8,       9,     7,     5,         31    \ Edge 10
 EDGE       4,       9,     9,     2,         31    \ Edge 11
 EDGE       1,       4,     3,     2,         24    \ Edge 12
 EDGE       1,       5,     3,     0,         24    \ Edge 13
 EDGE       3,       9,     5,     2,         24    \ Edge 14
 EDGE       3,       8,     5,     1,         24    \ Edge 15
 EDGE       2,       6,     4,     0,         24    \ Edge 16
 EDGE       2,       7,     4,     1,         24    \ Edge 17
 EDGE       1,      10,     2,     0,         22    \ Edge 18
 EDGE       2,      11,     1,     0,         22    \ Edge 19
 EDGE       3,      12,     2,     1,         22    \ Edge 20
 EDGE      10,      11,    12,     0,         14    \ Edge 21
 EDGE      11,      12,    12,     1,         14    \ Edge 22
 EDGE      12,      10,    12,     2,         14    \ Edge 23

.SHIP_BOA_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE       43,       37,      -60,         31    \ Face 0
 FACE        0,      -45,      -89,         31    \ Face 1
 FACE      -43,       37,      -60,         31    \ Face 2
 FACE        0,       40,        0,         31    \ Face 3
 FACE       62,      -32,      -20,         31    \ Face 4
 FACE      -62,      -32,      -20,         31    \ Face 5
 FACE        0,       23,        6,         31    \ Face 6
 FACE      -23,      -15,        9,         31    \ Face 7
 FACE       23,      -15,        9,         31    \ Face 8
 FACE      -26,       13,       10,         31    \ Face 9
 FACE        0,      -31,       12,         31    \ Face 10
 FACE       26,       13,       10,         31    \ Face 11
 FACE        0,        0,     -107,         14    \ Face 12

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
\       Name: SHIP_KRAIT
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Krait
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_KRAIT

 EQUB 1                 \ Max. canisters on demise = 1
 EQUW 60 * 60           \ Targetable area          = 60 * 60

 EQUB LO(SHIP_KRAIT_EDGES - SHIP_KRAIT)            \ Edges data offset (low)
 EQUB LO(SHIP_KRAIT_FACES - SHIP_KRAIT)            \ Faces data offset (low)

 EQUB 85                \ Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 \ Gun vertex               = 0
 EQUB 18                \ Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 21                \ Number of edges          = 21
 EQUW 100               \ Bounty                   = 100
 EQUB 24                \ Number of faces          = 24 / 4 = 6
 EQUB 25                \ Visibility distance      = 25

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 80               \ Max. energy              = 80

                        \ --- And replaced by: -------------------------------->

 EQUB 73                \ Max. energy              = 73

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30

 EQUB HI(SHIP_KRAIT_EDGES - SHIP_KRAIT)            \ Edges data offset (high)
 EQUB HI(SHIP_KRAIT_FACES - SHIP_KRAIT)            \ Faces data offset (high)

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB %00010000        \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

                        \ --- End of replacement ------------------------------>

.SHIP_KRAIT_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   96,     1,      0,    3,     2,         31    \ Vertex 0
 VERTEX    0,   18,  -48,     3,      0,    5,     4,         31    \ Vertex 1
 VERTEX    0,  -18,  -48,     2,      1,    5,     4,         31    \ Vertex 2
 VERTEX   90,    0,   -3,     1,      0,    4,     4,         31    \ Vertex 3
 VERTEX  -90,    0,   -3,     3,      2,    5,     5,         31    \ Vertex 4
 VERTEX   90,    0,   87,     1,      0,    1,     1,         30    \ Vertex 5
 VERTEX  -90,    0,   87,     3,      2,    3,     3,         30    \ Vertex 6
 VERTEX    0,    5,   53,     0,      0,    3,     3,          9    \ Vertex 7
 VERTEX    0,    7,   38,     0,      0,    3,     3,          6    \ Vertex 8
 VERTEX  -18,    7,   19,     3,      3,    3,     3,          9    \ Vertex 9
 VERTEX   18,    7,   19,     0,      0,    0,     0,          9    \ Vertex 10
 VERTEX   18,   11,  -39,     4,      4,    4,     4,          8    \ Vertex 11
 VERTEX   18,  -11,  -39,     4,      4,    4,     4,          8    \ Vertex 12
 VERTEX   36,    0,  -30,     4,      4,    4,     4,          8    \ Vertex 13
 VERTEX  -18,   11,  -39,     5,      5,    5,     5,          8    \ Vertex 14
 VERTEX  -18,  -11,  -39,     5,      5,    5,     5,          8    \ Vertex 15
 VERTEX  -36,    0,  -30,     5,      5,    5,     5,          8    \ Vertex 16

.SHIP_KRAIT_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     0,         31    \ Edge 0
 EDGE       0,       2,     2,     1,         31    \ Edge 1
 EDGE       0,       3,     1,     0,         31    \ Edge 2
 EDGE       0,       4,     3,     2,         31    \ Edge 3
 EDGE       1,       4,     5,     3,         31    \ Edge 4
 EDGE       4,       2,     5,     2,         31    \ Edge 5
 EDGE       2,       3,     4,     1,         31    \ Edge 6
 EDGE       3,       1,     4,     0,         31    \ Edge 7
 EDGE       3,       5,     1,     0,         30    \ Edge 8
 EDGE       4,       6,     3,     2,         30    \ Edge 9
 EDGE       1,       2,     5,     4,          8    \ Edge 10
 EDGE       7,      10,     0,     0,          9    \ Edge 11
 EDGE       8,      10,     0,     0,          6    \ Edge 12
 EDGE       7,       9,     3,     3,          9    \ Edge 13
 EDGE       8,       9,     3,     3,          6    \ Edge 14
 EDGE      11,      13,     4,     4,          8    \ Edge 15
 EDGE      13,      12,     4,     4,          8    \ Edge 16
 EDGE      12,      11,     4,     4,          7    \ Edge 17
 EDGE      14,      15,     5,     5,          7    \ Edge 18
 EDGE      15,      16,     5,     5,          8    \ Edge 19
 EDGE      16,      14,     5,     5,          8    \ Edge 20

.SHIP_KRAIT_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        3,       24,        3,         31    \ Face 0
 FACE        3,      -24,        3,         31    \ Face 1
 FACE       -3,      -24,        3,         31    \ Face 2
 FACE       -3,       24,        3,         31    \ Face 3
 FACE       38,        0,      -77,         31    \ Face 4
 FACE      -38,        0,      -77,         31    \ Face 5

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

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 4                 \ Number of faces          = 4 / 4 = 1
 EQUB 5                 \ Visibility distance      = 5

                        \ --- Mod: Code removed for Elite-A: ------------------>

\ EQUB 16               \ Max. energy              = 16

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
 FACE        0,        0,        0,          0    \ Face 0

 EQUB 6                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save S.L.bin
\
\ ******************************************************************************

 PRINT "S.S.L ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/S.L.bin", CODE%, CODE% + &0A00
