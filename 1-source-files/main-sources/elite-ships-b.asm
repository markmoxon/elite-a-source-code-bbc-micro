\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE B SOURCE
\
\ Elite-A is an extended version of BBC Micro Elite by Angus Duggan
\
\ The original Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984, and the extra code in Elite-A is copyright Angus Duggan
\
\ The code in this file is identical to Angus Duggan's source discs (it's just
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
\   * S.B.bin
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
\    Summary: Ship blueprints lookup table for the S.B file
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
 EQUW SHIP_SHUTTLE_MK_2 \ SHU  =  9 = Shuttle Mk II                      Shuttle
 EQUW 0                 \                                            Transporter
 EQUW SHIP_GHAVIAL      \        11 = Ghavial                             Trader
 EQUW SHIP_MONITOR      \        12 = Monitor                             Trader
 EQUW SHIP_COBRA_MK_1   \        13 = Cobra Mk I                          Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_COBRA_MK_1   \        17 = Cobra Mk I                          Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_IGUANA       \        20 = Iguana                              Pirate
 EQUW SHIP_COBRA_MK_3   \        21 = Cobra Mk III                        Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_MONITOR      \        24 = Monitor                             Pirate
 EQUW SHIP_COBRA_MK_3   \        25 = Cobra Mk III                 Bounty hunter
 EQUW SHIP_IGUANA       \        26 = Iguana                       Bounty hunter
 EQUW SHIP_COBRA_MK_1   \        27 = Cobra Mk I                   Bounty hunter
 EQUW SHIP_GHAVIAL      \        28 = Ghavial                      Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.B file
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
 EQUB %00100001         \ Shuttle Mk II                         Trader, innocent
 EQUB 0
 EQUB %10100000         \ Ghavial                           Innocent, escape pod
 EQUB %10100001         \ Monitor                   Trader, innocent, escape pod
 EQUB %10100000         \ Cobra Mk I                        Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Cobra Mk I                 Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Iguana                     Hostile, pirate, escape pod
 EQUB %10000100         \ Cobra Mk III                       Hostile, escape pod
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Monitor                    Hostile, pirate, escape pod
 EQUB %10000010         \ Cobra Mk III                 Bounty hunter, escape pod
 EQUB %10100010         \ Iguana             Bounty hunter, innocent, escape pod
 EQUB %10000010         \ Cobra Mk I                   Bounty hunter, escape pod
 EQUB %10100010         \ Ghavial            Bounty hunter, innocent, escape pod
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
 FACE        0,        0,      196,         31      \ Face 0
 FACE      103,      142,       88,         31      \ Face 1
 FACE      169,      -55,       89,         31      \ Face 2
 FACE        0,     -176,       88,         31      \ Face 3
 FACE     -169,      -55,       89,         31      \ Face 4
 FACE     -103,      142,       88,         31      \ Face 5
 FACE        0,      176,      -88,         31      \ Face 6
 FACE      169,       55,      -89,         31      \ Face 7
 FACE      103,     -142,      -88,         31      \ Face 8
 FACE     -103,     -142,      -88,         31      \ Face 9
 FACE     -169,       55,      -89,         31      \ Face 10
 FACE        0,        0,     -196,         31      \ Face 11

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
\       Name: SHIP_GHAVIAL
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Ghavial
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_GHAVIAL

 EQUB 3                 \ Max. canisters on demise = 3
 EQUW 9728              \ Targetable area          = 98.63 * 98.63

 EQUB LO(SHIP_GHAVIAL_EDGES - SHIP_GHAVIAL)        \ Edges data offset (low)
 EQUB LO(SHIP_GHAVIAL_FACES - SHIP_GHAVIAL)        \ Faces data offset (low)

 EQUB 97                \ Max. edge count          = (97 - 1) / 4 = 24
 EQUB 0                 \ Gun vertex               = 0
 EQUB 34                \ Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 72                \ Number of vertices       = 72 / 6 = 12
 EQUB 22                \ Number of edges          = 22
 EQUW 100               \ Bounty                   = 100
 EQUB 48                \ Number of faces          = 48 / 4 = 12
 EQUB 10                \ Visibility distance      = 10
 EQUB 114               \ Max. energy              = 114
 EQUB 16                \ Max. speed               = 16

 EQUB HI(SHIP_GHAVIAL_EDGES - SHIP_GHAVIAL)        \ Edges data offset (high)
 EQUB HI(SHIP_GHAVIAL_FACES - SHIP_GHAVIAL)        \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00100111         \ Laser power              = 4
                        \ Missiles                 = 7

.SHIP_GHAVIAL_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   30,    0,  100,     7,     6,     1,     0,         31     \ Vertex 0
 VERTEX  -30,    0,  100,    11,     6,     5,     0,         31     \ Vertex 1
 VERTEX   40,   30,  -26,     3,     2,     1,     0,         31     \ Vertex 2
 VERTEX  -40,   30,  -26,     5,     4,     3,     0,         31     \ Vertex 3
 VERTEX   60,    0,  -20,     8,     7,     2,     1,         31     \ Vertex 4
 VERTEX   40,    0,  -60,     9,     8,     3,     2,         31     \ Vertex 5
 VERTEX  -60,    0,  -20,    11,    10,     5,     4,         31     \ Vertex 6
 VERTEX  -40,    0,  -60,    10,     9,     4,     3,         31     \ Vertex 7
 VERTEX    0,  -30,  -20,    15,    15,    15,    15,         31     \ Vertex 8
 VERTEX   10,   24,    0,     0,     0,     0,     0,          9     \ Vertex 9
 VERTEX  -10,   24,    0,     0,     0,     0,     0,          9     \ Vertex 10
 VERTEX    0,   22,   10,     0,     0,     0,     0,          9     \ Vertex 11

.SHIP_GHAVIAL_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       2,     1,     0,         31    \ Edge 0
 EDGE       4,       2,     2,     1,         31    \ Edge 1
 EDGE       5,       2,     3,     2,         31    \ Edge 2
 EDGE       3,       2,     0,     3,         31    \ Edge 3
 EDGE       7,       3,     4,     3,         31    \ Edge 4
 EDGE       6,       3,     5,     4,         31    \ Edge 5
 EDGE       3,       1,     0,     5,         31    \ Edge 6
 EDGE       0,       8,     7,     6,         31    \ Edge 7
 EDGE       4,       8,     8,     7,         31    \ Edge 8
 EDGE       5,       8,     9,     8,         31    \ Edge 9
 EDGE       7,       8,    10,     9,         31    \ Edge 10
 EDGE       6,       8,    11,    10,         31    \ Edge 11
 EDGE       1,       8,     6,    11,         31    \ Edge 12
 EDGE       1,       0,     6,     0,         31    \ Edge 13
 EDGE       0,       4,     7,     1,         31    \ Edge 14
 EDGE       4,       5,     8,     2,         31    \ Edge 15
 EDGE       5,       7,     9,     3,         31    \ Edge 16
 EDGE       7,       6,    10,     4,         31    \ Edge 17
 EDGE       6,       1,    11,     5,         31    \ Edge 18
 EDGE       9,      10,     0,     0,          9    \ Edge 19
 EDGE      10,      11,     0,     0,          9    \ Edge 20
 EDGE      11,       9,     0,     0,          9    \ Edge 21

.SHIP_GHAVIAL_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       14,         31      \ Face 0
 FACE       51,       36,       12,         31      \ Face 1
 FACE       51,       28,      -25,         31      \ Face 2
 FACE        0,       48,      -42,         31      \ Face 3
 FACE      -51,       28,      -25,         31      \ Face 4
 FACE      -51,       36,       12,         31      \ Face 5
 FACE        0,      -62,       15,         31      \ Face 6
 FACE       28,      -56,        7,         31      \ Face 7
 FACE       27,      -55,      -13,         31      \ Face 8
 FACE        0,      -51,      -38,         31      \ Face 9
 FACE      -27,      -55,      -13,         31      \ Face 10
 FACE      -28,      -56,        7,         31      \ Face 11

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SHIP_MONITOR
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Monitor
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_MONITOR

 EQUB 4                 \ Max. canisters on demise = 4
 EQUW 13824             \ Targetable area          = 117.57 * 117.57

 EQUB LO(SHIP_MONITOR_EDGES - SHIP_MONITOR)        \ Edges data offset (low)
 EQUB LO(SHIP_MONITOR_FACES - SHIP_MONITOR)        \ Faces data offset (low)

 EQUB 101               \ Max. edge count          = (101 - 1) / 4 = 25
 EQUB 0                 \ Gun vertex               = 0
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 23                \ Number of edges          = 23
 EQUW 400               \ Bounty                   = 400
 EQUB 44                \ Number of faces          = 44 / 4 = 11
 EQUB 40                \ Visibility distance      = 40
 EQUB 132               \ Max. energy              = 132
 EQUB 16                \ Max. speed               = 16

 EQUB HI(SHIP_MONITOR_EDGES - SHIP_MONITOR)        \ Edges data offset (high)
 EQUB HI(SHIP_MONITOR_FACES - SHIP_MONITOR)        \ Faces data offset (high)

 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00110111         \ Laser power              = 6
                        \ Missiles                 = 7

.SHIP_MONITOR_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   10,  140,    15,    15,    15,    15,         31     \ Vertex 0
 VERTEX   20,   40,  -20,     3,     2,     1,     0,         31     \ Vertex 1
 VERTEX  -20,   40,  -20,     0,     5,     4,     3,         31     \ Vertex 2
 VERTEX   50,    0,   10,     8,     7,     2,     1,         31     \ Vertex 3
 VERTEX  -50,    0,   10,     6,     9,     5,     4,         31     \ Vertex 4
 VERTEX   30,    4,  -60,    10,    10,     8,     2,         31     \ Vertex 5
 VERTEX  -30,    4,  -60,    10,    10,     9,     4,         31     \ Vertex 6
 VERTEX   18,   20,  -60,    10,    10,     3,     2,         31     \ Vertex 7
 VERTEX  -18,   20,  -60,    10,    10,     4,     3,         31     \ Vertex 8
 VERTEX    0,  -20,  -60,    10,    10,     9,     8,         31     \ Vertex 9
 VERTEX    0,  -40,   10,     9,     8,     7,     6,         31     \ Vertex 10
 VERTEX    0,   34,   10,     0,     0,     0,     0,         10     \ Vertex 11
 VERTEX    0,   26,   50,     0,     0,     0,     0,         10     \ Vertex 12
 VERTEX   20,  -10,   60,     7,     7,     7,     7,         10     \ Vertex 13
 VERTEX   10,    0,  100,     7,     7,     7,     7,         10     \ Vertex 14
 VERTEX  -20,  -10,   60,     6,     6,     6,     6,         10     \ Vertex 15
 VERTEX  -10,    0,  100,     6,     6,     6,     6,         10     \ Vertex 16

.SHIP_MONITOR_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    \ Edge 0
 EDGE       1,       3,     2,     1,         31    \ Edge 1
 EDGE       1,       7,     3,     2,         31    \ Edge 2
 EDGE       2,       8,     4,     3,         31    \ Edge 3
 EDGE       2,       4,     5,     4,         31    \ Edge 4
 EDGE       0,       2,     0,     5,         31    \ Edge 5
 EDGE       1,       2,     3,     0,         31    \ Edge 6
 EDGE       0,      10,     7,     6,         31    \ Edge 7
 EDGE       3,      10,     8,     7,         31    \ Edge 8
 EDGE       9,      10,     9,     8,         31    \ Edge 9
 EDGE       4,      10,     6,     9,         31    \ Edge 10
 EDGE       0,       3,     7,     1,         31    \ Edge 11
 EDGE       3,       5,     8,     2,         31    \ Edge 12
 EDGE       6,       4,     9,     4,         31    \ Edge 13
 EDGE       4,       0,     6,     5,         31    \ Edge 14
 EDGE       7,       5,    10,     2,         31    \ Edge 15
 EDGE       8,       7,    10,     3,         31    \ Edge 16
 EDGE       8,       6,    10,     4,         31    \ Edge 17
 EDGE       5,       9,    10,     8,         31    \ Edge 18
 EDGE       6,       9,    10,     9,         31    \ Edge 19
 EDGE      11,      12,     0,     0,         10    \ Edge 20
 EDGE      13,      14,     7,     7,         10    \ Edge 21
 EDGE      15,      16,     6,     6,         10    \ Edge 22

.SHIP_MONITOR_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       11,         31      \ Face 0
 FACE       44,       43,       13,         31      \ Face 1
 FACE       54,       28,      -16,         31      \ Face 2
 FACE        0,       57,      -28,         31      \ Face 3
 FACE      -54,       28,      -16,         31      \ Face 4
 FACE      -44,       43,       13,         31      \ Face 5
 FACE      -38,      -47,       18,         31      \ Face 6
 FACE       38,      -47,       18,         31      \ Face 7
 FACE       39,      -48,      -13,         31      \ Face 8
 FACE      -39,      -48,      -13,         31      \ Face 9
 FACE        0,        0,      -64,         31      \ Face 10

                        \ --- End of added code ------------------------------->

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
 FACE        0,       62,       31,         31      \ Face 0
 FACE      -18,       55,       16,         31      \ Face 1
 FACE       18,       55,       16,         31      \ Face 2
 FACE      -16,       52,       14,         31      \ Face 3
 FACE       16,       52,       14,         31      \ Face 4
 FACE      -14,       47,        0,         31      \ Face 5
 FACE       14,       47,        0,         31      \ Face 6
 FACE      -61,      102,        0,         31      \ Face 7
 FACE       61,      102,        0,         31      \ Face 8
 FACE        0,        0,      -80,         31      \ Face 9
 FACE       -7,      -42,        9,         31      \ Face 10
 FACE        0,      -30,        6,         31      \ Face 11
 FACE        7,      -42,        9,         31      \ Face 12

\ ******************************************************************************
\
\       Name: SHIP_SHUTTLE_MK_2
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Shuttle Mk II
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Code added for Elite-A: -------------------->

.SHIP_SHUTTLE_MK_2

 EQUB 15                \ Max. canisters on demise = 15
 EQUW 50 * 50           \ Targetable area          = 50 * 50

 EQUB LO(SHIP_SHUTTLE_MK_2_EDGES - SHIP_SHUTTLE_MK_2) \ Edges data offset (low)
 EQUB LO(SHIP_SHUTTLE_MK_2_FACES - SHIP_SHUTTLE_MK_2) \ Faces data offset (low)

 EQUB 89                \ Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 \ Gun vertex               = 0
 EQUB 38                \ Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 28                \ Number of edges          = 28
 EQUW 0                 \ Bounty                   = 0
 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 10                \ Visibility distance      = 10
 EQUB 32                \ Max. energy              = 32
 EQUB 9                 \ Max. speed               = 9

 EQUB HI(SHIP_SHUTTLE_MK_2_EDGES - SHIP_SHUTTLE_MK_2) \ Edges data offset (high)
 EQUB HI(SHIP_SHUTTLE_MK_2_FACES - SHIP_SHUTTLE_MK_2) \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_SHUTTLE_MK_2_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   40,     3,     2,     1,     0,         31     \ Vertex 0
 VERTEX    0,   20,   30,     4,     3,     0,     0,         31     \ Vertex 1
 VERTEX  -20,    0,   30,     5,     1,     0,     0,         31     \ Vertex 2
 VERTEX    0,  -20,   30,     6,     2,     1,     1,         31     \ Vertex 3
 VERTEX   20,    0,   30,     7,     3,     2,     2,         31     \ Vertex 4
 VERTEX  -20,   20,   20,     8,     5,     4,     0,         31     \ Vertex 5
 VERTEX  -20,  -20,   20,     9,     6,     5,     1,         31     \ Vertex 6
 VERTEX   20,  -20,   20,    10,     7,     6,     2,         31     \ Vertex 7
 VERTEX   20,   20,   20,    11,     7,     4,     3,         31     \ Vertex 8
 VERTEX    0,   20,  -40,    12,    11,     8,     4,         31     \ Vertex 9
 VERTEX  -20,    0,  -40,    12,     9,     8,     5,         31     \ Vertex 10
 VERTEX    0,  -20,  -40,    12,    10,     9,     6,         31     \ Vertex 11
 VERTEX   20,    0,  -40,    12,    11,    10,     7,         31     \ Vertex 12
 VERTEX   -4,    4,  -40,    12,    12,    12,    12,         10     \ Vertex 13
 VERTEX   -4,   -4,  -40,    12,    12,    12,    12,         10     \ Vertex 14
 VERTEX    4,   -4,  -40,    12,    12,    12,    12,         10     \ Vertex 15
 VERTEX    4,    4,  -40,    12,    12,    12,    12,         10     \ Vertex 16

.SHIP_SHUTTLE_MK_2_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       2,     1,     0,         31    \ Edge 0
 EDGE       0,       3,     2,     1,         31    \ Edge 1
 EDGE       0,       4,     3,     2,         31    \ Edge 2
 EDGE       0,       1,     0,     3,         31    \ Edge 3
 EDGE       1,       5,     4,     0,         31    \ Edge 4
 EDGE       2,       5,     5,     0,         31    \ Edge 5
 EDGE       2,       6,     5,     1,         31    \ Edge 6
 EDGE       3,       6,     6,     1,         31    \ Edge 7
 EDGE       3,       7,     6,     2,         31    \ Edge 8
 EDGE       4,       7,     7,     2,         31    \ Edge 9
 EDGE       4,       8,     7,     3,         31    \ Edge 10
 EDGE       1,       8,     4,     3,         31    \ Edge 11
 EDGE       5,       9,     8,     4,         31    \ Edge 12
 EDGE       5,      10,     8,     5,         31    \ Edge 13
 EDGE       6,      10,     9,     5,         31    \ Edge 14
 EDGE       6,      11,     9,     6,         31    \ Edge 15
 EDGE       7,      11,    10,     6,         31    \ Edge 16
 EDGE       7,      12,    10,     7,         31    \ Edge 17
 EDGE       8,      12,    11,     7,         31    \ Edge 18
 EDGE       8,       9,    11,     4,         31    \ Edge 19
 EDGE       9,      10,    12,     8,         31    \ Edge 20
 EDGE      10,      11,    12,     9,         31    \ Edge 21
 EDGE      11,      12,    12,    10,         31    \ Edge 22
 EDGE      12,       9,    12,    11,         31    \ Edge 23
 EDGE      13,      14,    12,    12,         10    \ Edge 24
 EDGE      14,      15,    12,    12,         10    \ Edge 25
 EDGE      15,      16,    12,    12,         10    \ Edge 26
 EDGE      16,      13,    12,    12,         10    \ Edge 27

.SHIP_SHUTTLE_MK_2_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE      -39,       39,       78,         31      \ Face 0
 FACE      -39,      -39,       78,         31      \ Face 1
 FACE       39,      -39,       78,         31      \ Face 2
 FACE       39,       39,       78,         31      \ Face 3
 FACE        0,       96,        0,         31      \ Face 4
 FACE      -96,        0,        0,         31      \ Face 5
 FACE        0,      -96,        0,         31      \ Face 6
 FACE       96,        0,        0,         31      \ Face 7
 FACE      -66,       66,      -22,         31      \ Face 8
 FACE      -66,      -66,      -22,         31      \ Face 9
 FACE       66,      -66,      -22,         31      \ Face 10
 FACE       66,       66,      -22,         31      \ Face 11
 FACE        0,        0,      -96,         31      \ Face 12

                        \ --- End of added code ------------------------------->

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
 FACE      -51,       77,       25,         31      \ Face 0
 FACE      -51,      -77,       25,         31      \ Face 1
 FACE       51,       77,       25,         31      \ Face 2
 FACE       51,      -77,       25,         31      \ Face 3
 FACE      -42,       85,        0,         31      \ Face 4
 FACE      -42,      -85,        0,         31      \ Face 5
 FACE       42,       85,        0,         31      \ Face 6
 FACE       42,      -85,        0,         31      \ Face 7
 FACE      -23,        0,      -93,         31      \ Face 8
 FACE       23,        0,      -93,         31      \ Face 9

                        \ --- End of added code ------------------------------->

 EQUB 9                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save S.B.bin
\
\ ******************************************************************************

 PRINT "S.S.B ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/S.B.bin", CODE%, CODE% + &0A00
