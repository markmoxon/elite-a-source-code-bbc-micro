\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE I
\
\ Elite-A is an extended version of BBC Micro Elite by Angus Duggan
\
\ The original Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984, and the extra code in Elite-A is copyright Angus Duggan
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
\   * output/S.I.bin
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

SHIP_MISSILE = &7F00    \ The address of the missile ship blueprint

CODE% = &5600           \ The flight code loads this file at address &5600, at
LOAD% = &5600           \ label XX21

ORG CODE%

\ ******************************************************************************
\
\       Name: XX21
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints lookup table for the S.I file
\  Deep dive: Ship blueprints in the disc version
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile
 EQUW SHIP_CORIOLIS     \ SST  =  2 = Coriolis space station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod
 EQUW 0
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister
 EQUW 0
 EQUW 0
 EQUW 0
 EQUW 0
 EQUW 0
 EQUW ship_ghavial      \        11 = Ghavial
 EQUW ship_ophidian     \        12 = Ophidian
 EQUW SHIP_COBRA_MK_1   \        13 = Cobra Mk I
 EQUW SHIP_ANACONDA     \ ANA  = 14 = Anaconda
 EQUW SHIP_WORM         \        15 = Worm
 EQUW SHIP_VIPER        \ COPS = 16 = Viper
 EQUW SHIP_KRAIT        \        17 = Krait
 EQUW SHIP_COBRA_MK_1   \        18 = Cobra Mk I
 EQUW 0
 EQUW 0
 EQUW ship_ophidian     \        21 = Ophidian
 EQUW SHIP_WORM         \        22 = Worm
 EQUW 0
 EQUW SHIP_ASP_MK_2     \        24 = Asp Mk II
 EQUW 0
 EQUW 0
 EQUW SHIP_ASP_MK_2     \        27 = Asp Mk II
 EQUW SHIP_KRAIT        \        28 = Krait
 EQUW 0
 EQUW 0
 EQUW 0

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.I file
\  Deep dive: Ship blueprints
\             Advanced tactics with the NEWB flags
\
\ ******************************************************************************

.E%

 EQUB %00000000         \ Missile
 EQUB %01000000         \ Coriolis space station                             Cop
 EQUB %01000001         \ Escape pod                                 Trader, cop
 EQUB 0
 EQUB %00000000         \ Cargo canister
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Ghavial                           Innocent, escape pod
 EQUB %10100001         \ Ophidian                  Trader, innocent, escape pod
 EQUB %10100000         \ Cobra Mk I                        Innocent, escape pod
 EQUB %10100001         \ Anaconda                  Trader, innocent, escape pod
 EQUB %00001100         \ Worm                                   Hostile, pirate
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Krait                      Hostile, pirate, escape pod
 EQUB %10001100         \ Cobra Mk I                 Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB %00001100         \ Worm                                   Hostile, pirate
 EQUB 0
 EQUB %10001100         \ Asp Mk II                  Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10000010         \ Asp Mk II                    Bounty hunter, escape pod
 EQUB %10100010         \ Krait              Bounty hunter, innocent, escape pod
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
\ on how vertices are used to draw 3D wiremesh ships.
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
\ on how edges are used to draw 3D wiremesh ships.
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
\ on how faces are used to draw 3D wiremesh ships.
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
 EQUB &74               \ Edges data offset (low)  = &0074
 EQUB &E4               \ Faces data offset (low)  = &00E4
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
 EQUB &00               \ Edges data offset (high) = &0074
 EQUB &00               \ Faces data offset (high) = &00E4
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00000110         \ Laser power              = 0
                        \ Missiles                 = 6

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
                        \ Market item when scooped = 2 + 1 = 3 (Slaves)
 EQUW 16 * 16           \ Targetable area          = 16 * 16
 EQUB &2C               \ Edges data offset (low)  = &002C
 EQUB &44               \ Faces data offset (low)  = &0044
 EQUB 25                \ Max. edge count          = (25 - 1) / 4 = 6
 EQUB 0                 \ Gun vertex               = 0
 EQUB 22                \ Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 24                \ Number of vertices       = 24 / 6 = 4
 EQUB 6                 \ Number of edges          = 6
 EQUW 0                 \ Bounty                   = 0
 EQUB 16                \ Number of faces          = 16 / 4 = 4
 EQUB 8                 \ Visibility distance      = 8

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 17              \ Max. energy              = 17

                        \ --- And replaced by the following: -------------------

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement code --------------------------

 EQUB 8                 \ Max. speed               = 8
 EQUB &00               \ Edges data offset (high) = &002C
 EQUB &00               \ Faces data offset (high) = &0044
 EQUB 4                 \ Normals are scaled by    =  2^4 = 16
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   -7,    0,   36,     2,      1,    3,     3,         31    \ Vertex 0
 VERTEX   -7,  -14,  -12,     2,      0,    3,     3,         31    \ Vertex 1
 VERTEX   -7,   14,  -12,     1,      0,    3,     3,         31    \ Vertex 2
 VERTEX   21,    0,    0,     1,      0,    2,     2,         31    \ Vertex 3

.SHIP_ESCAPE_POD_EDGES

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     3,     2,         31    \ Edge 0
 EDGE       1,       2,     3,     0,         31    \ Edge 1
 EDGE       2,       3,     1,     0,         31    \ Edge 2
 EDGE       3,       0,     2,     1,         31    \ Edge 3
 EDGE       0,       2,     3,     1,         31    \ Edge 4
 EDGE       3,       1,     2,     0,         31    \ Edge 5

\FACE normal_x, normal_y, normal_z, visibility
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
 EQUB &50               \ Edges data offset (low)  = &0050
 EQUB &8C               \ Faces data offset (low)  = &008C
 EQUB 49                \ Max. edge count          = (49 - 1) / 4 = 12
 EQUB 0                 \ Gun vertex               = 0
 EQUB 18                \ Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                \ Number of vertices       = 60 / 6 = 10
 EQUB 15                \ Number of edges          = 15

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUW 0               \ Bounty                   = 0

                        \ --- And replaced by the following: -------------------

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement code --------------------------

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 12                \ Visibility distance      = 12

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 17              \ Max. energy              = 17

                        \ --- And replaced by the following: -------------------

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement code --------------------------

 EQUB 15                \ Max. speed               = 15
 EQUB &00               \ Edges data offset (high) = &0050
 EQUB &00               \ Faces data offset (high) = &008C
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
 EQUB &6E               \ Edges data offset (low)  = &006E
 EQUB &BE               \ Faces data offset (low)  = &00BE
 EQUB 77                \ Max. edge count          = (77 - 1) / 4 = 19
 EQUB 0                 \ Gun vertex               = 0
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 90                \ Number of vertices       = 90 / 6 = 15
 EQUB 20                \ Number of edges          = 20
 EQUW 0                 \ Bounty                   = 0
 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 23                \ Visibility distance      = 23

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 100             \ Max. energy              = 100

                        \ --- And replaced by the following: -------------------

 EQUB 91                \ Max. energy              = 91

                        \ --- End of replacement code --------------------------

 EQUB 32                \ Max. speed               = 32
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00BE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00010001       \ Laser power              = 2
\                       \ Missiles                 = 1

                        \ --- And replaced by the following: -------------------

 EQUB %00101001         \ Laser power              = 5
                        \ Missiles                 = 1

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        0,         31    \ Face 0
 FACE      -22,       33,       11,         31    \ Face 1
 FACE       22,       33,       11,         31    \ Face 2
 FACE      -22,      -33,       11,         31    \ Face 3
 FACE       22,      -33,       11,         31    \ Face 4
 FACE        0,      -32,        0,         31    \ Face 5
 FACE        0,        0,      -48,         31    \ Face 6

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
 EQUB &7A               \ Edges data offset (low)  = &007A
 EQUB &CE               \ Faces data offset (low)  = &00CE
 EQUB 85                \ Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 \ Gun vertex               = 0
 EQUB 18                \ Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 21                \ Number of edges          = 21
 EQUW 100               \ Bounty                   = 100
 EQUB 24                \ Number of faces          = 24 / 4 = 6
 EQUB 25                \ Visibility distance      = 25

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 80              \ Max. energy              = 80

                        \ --- And replaced by the following: -------------------

 EQUB 73                \ Max. energy              = 73

                        \ --- End of replacement code --------------------------

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &007A
 EQUB &00               \ Faces data offset (high) = &00CE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00010000       \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by the following: -------------------

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        3,       24,        3,         31    \ Face 0
 FACE        3,      -24,        3,         31    \ Face 1
 FACE       -3,      -24,        3,         31    \ Face 2
 FACE       -3,       24,        3,         31    \ Face 3
 FACE       38,        0,      -77,         31    \ Face 4
 FACE      -38,        0,      -77,         31    \ Face 5

\ ******************************************************************************
\
\       Name: SHIP_ASP_MK_2
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Asp Mk II
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_ASP_MK_2

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 60 * 60           \ Targetable area          = 60 * 60
 EQUB &86               \ Edges data offset (low)  = &0086
 EQUB &F6               \ Faces data offset (low)  = &00F6
 EQUB 101               \ Max. edge count          = (101 - 1) / 4 = 25
 EQUB 32                \ Gun vertex               = 32
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 114               \ Number of vertices       = 114 / 6 = 19
 EQUB 28                \ Number of edges          = 28

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUW 200             \ Bounty                   = 200

                        \ --- And replaced by the following: -------------------

 EQUW 450               \ Bounty                   = 450

                        \ --- End of replacement code --------------------------

 EQUB 48                \ Number of faces          = 48 / 4 = 12
 EQUB 40                \ Visibility distance      = 40

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 150             \ Max. energy              = 150

                        \ --- And replaced by the following: -------------------

 EQUB 109               \ Max. energy              = 109

                        \ --- End of replacement code --------------------------

 EQUB 40                \ Max. speed               = 40
 EQUB &00               \ Edges data offset (high) = &0086
 EQUB &00               \ Faces data offset (high) = &00F6
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00101001       \ Laser power              = 5
\                       \ Missiles                 = 1

                        \ --- And replaced by the following: -------------------

 EQUB %01001001         \ Laser power              = 9
                        \ Missiles                 = 1

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,  -18,    0,     1,      0,    2,     2,         22    \ Vertex 0
 VERTEX    0,   -9,  -45,     2,      1,   11,    11,         31    \ Vertex 1
 VERTEX   43,    0,  -45,     6,      1,   11,    11,         31    \ Vertex 2
 VERTEX   69,   -3,    0,     6,      1,    9,     7,         31    \ Vertex 3
 VERTEX   43,  -14,   28,     1,      0,    7,     7,         31    \ Vertex 4
 VERTEX  -43,    0,  -45,     5,      2,   11,    11,         31    \ Vertex 5
 VERTEX  -69,   -3,    0,     5,      2,   10,     8,         31    \ Vertex 6
 VERTEX  -43,  -14,   28,     2,      0,    8,     8,         31    \ Vertex 7
 VERTEX   26,   -7,   73,     4,      0,    9,     7,         31    \ Vertex 8
 VERTEX  -26,   -7,   73,     4,      0,   10,     8,         31    \ Vertex 9
 VERTEX   43,   14,   28,     4,      3,    9,     6,         31    \ Vertex 10
 VERTEX  -43,   14,   28,     4,      3,   10,     5,         31    \ Vertex 11
 VERTEX    0,    9,  -45,     5,      3,   11,     6,         31    \ Vertex 12
 VERTEX  -17,    0,  -45,    11,     11,   11,    11,         10    \ Vertex 13
 VERTEX   17,    0,  -45,    11,     11,   11,    11,          9    \ Vertex 14
 VERTEX    0,   -4,  -45,    11,     11,   11,    11,         10    \ Vertex 15
 VERTEX    0,    4,  -45,    11,     11,   11,    11,          8    \ Vertex 16
 VERTEX    0,   -7,   73,     4,      0,    4,     0,         10    \ Vertex 17
 VERTEX    0,   -7,   83,     4,      0,    4,     0,         10    \ Vertex 18

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     1,         22    \ Edge 0
 EDGE       0,       4,     1,     0,         22    \ Edge 1
 EDGE       0,       7,     2,     0,         22    \ Edge 2
 EDGE       1,       2,    11,     1,         31    \ Edge 3
 EDGE       2,       3,     6,     1,         31    \ Edge 4
 EDGE       3,       8,     9,     7,         16    \ Edge 5
 EDGE       8,       9,     4,     0,         31    \ Edge 6
 EDGE       6,       9,    10,     8,         16    \ Edge 7
 EDGE       5,       6,     5,     2,         31    \ Edge 8
 EDGE       1,       5,    11,     2,         31    \ Edge 9
 EDGE       3,       4,     7,     1,         31    \ Edge 10
 EDGE       4,       8,     7,     0,         31    \ Edge 11
 EDGE       6,       7,     8,     2,         31    \ Edge 12
 EDGE       7,       9,     8,     0,         31    \ Edge 13
 EDGE       2,      12,    11,     6,         31    \ Edge 14
 EDGE       5,      12,    11,     5,         31    \ Edge 15
 EDGE      10,      12,     6,     3,         22    \ Edge 16
 EDGE      11,      12,     5,     3,         22    \ Edge 17
 EDGE      10,      11,     4,     3,         22    \ Edge 18
 EDGE       6,      11,    10,     5,         31    \ Edge 19
 EDGE       9,      11,    10,     4,         31    \ Edge 20
 EDGE       3,      10,     9,     6,         31    \ Edge 21
 EDGE       8,      10,     9,     4,         31    \ Edge 22
 EDGE      13,      15,    11,    11,         10    \ Edge 23
 EDGE      15,      14,    11,    11,          9    \ Edge 24
 EDGE      14,      16,    11,    11,          8    \ Edge 25
 EDGE      16,      13,    11,    11,          8    \ Edge 26
 EDGE      18,      17,     4,     0,         10    \ Edge 27

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,      -35,        5,         31    \ Face 0
 FACE        8,      -38,       -7,         31    \ Face 1
 FACE       -8,      -38,       -7,         31    \ Face 2
 FACE        0,       24,       -1,         22    \ Face 3
 FACE        0,       43,       19,         31    \ Face 4
 FACE       -6,       28,       -2,         31    \ Face 5
 FACE        6,       28,       -2,         31    \ Face 6
 FACE       59,      -64,       31,         31    \ Face 7
 FACE      -59,      -64,       31,         31    \ Face 8
 FACE       80,       46,       50,         31    \ Face 9
 FACE      -80,       46,       50,         31    \ Face 10
 FACE        0,        0,      -90,         31    \ Face 11

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
 EQUB &56               \ Edges data offset (low)  = &0056
 EQUB &9E               \ Faces data offset (low)  = &009E
 EQUB 69                \ Max. edge count          = (69 - 1) / 4 = 17
 EQUB 40                \ Gun vertex               = 40
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 66                \ Number of vertices       = 66 / 6 = 11
 EQUB 18                \ Number of edges          = 18
 EQUW 75                \ Bounty                   = 75
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 19                \ Visibility distance      = 19

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 90              \ Max. energy              = 90

                        \ --- And replaced by the following: -------------------

 EQUB 81                \ Max. energy              = 81

                        \ --- End of replacement code --------------------------

 EQUB 26                \ Max. speed               = 26
 EQUB &00               \ Edges data offset (high) = &0056
 EQUB &00               \ Faces data offset (high) = &009E
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00010010       \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by the following: -------------------

 EQUB %00100010         \ Laser power              = 4
                        \ Missiles                 = 2

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       41,       10,         31    \ Face 0
 FACE        0,      -27,        3,         31    \ Face 1
 FACE       -8,       46,        8,         31    \ Face 2
 FACE      -12,      -57,       12,         31    \ Face 3
 FACE        8,       46,        8,         31    \ Face 4
 FACE       12,      -57,       12,         31    \ Face 5
 FACE        0,       49,        0,         31    \ Face 6
 FACE        0,        0,     -154,         31    \ Face 7
 FACE     -121,      111,      -62,         31    \ Face 8
 FACE      121,      111,      -62,         31    \ Face 9

\ ******************************************************************************
\
\       Name: SHIP_ANACONDA
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Anaconda
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_ANACONDA

 EQUB 7                 \ Max. canisters on demise = 7
 EQUW 100 * 100         \ Targetable area          = 100 * 100
 EQUB &6E               \ Edges data offset (low)  = &006E
 EQUB &D2               \ Faces data offset (low)  = &00D2
 EQUB 89                \ Max. edge count          = (89 - 1) / 4 = 22
 EQUB 48                \ Gun vertex               = 48
 EQUB 46                \ Explosion count          = 10, as (4 * n) + 6 = 46
 EQUB 90                \ Number of vertices       = 90 / 6 = 15
 EQUB 25                \ Number of edges          = 25

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUW 0               \ Bounty                   = 0

                        \ --- And replaced by the following: -------------------

 EQUW 350               \ Bounty                   = 350

                        \ --- End of replacement code --------------------------

 EQUB 48                \ Number of faces          = 48 / 4 = 12
 EQUB 50                \ Visibility distance      = 50
 EQUB 252               \ Max. energy              = 252
 EQUB 14                \ Max. speed               = 14
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00D2
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00111111       \ Laser power              = 7
\                       \ Missiles                 = 7

                        \ --- And replaced by the following: -------------------

 EQUB %01001111         \ Laser power              = 9
                        \ Missiles                 = 7

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    7,  -58,     1,      0,    5,     5,         30    \ Vertex 0
 VERTEX  -43,  -13,  -37,     1,      0,    2,     2,         30    \ Vertex 1
 VERTEX  -26,  -47,   -3,     2,      0,    3,     3,         30    \ Vertex 2
 VERTEX   26,  -47,   -3,     3,      0,    4,     4,         30    \ Vertex 3
 VERTEX   43,  -13,  -37,     4,      0,    5,     5,         30    \ Vertex 4
 VERTEX    0,   48,  -49,     5,      1,    6,     6,         30    \ Vertex 5
 VERTEX  -69,   15,  -15,     2,      1,    7,     7,         30    \ Vertex 6
 VERTEX  -43,  -39,   40,     3,      2,    8,     8,         31    \ Vertex 7
 VERTEX   43,  -39,   40,     4,      3,    9,     9,         31    \ Vertex 8
 VERTEX   69,   15,  -15,     5,      4,   10,    10,         30    \ Vertex 9
 VERTEX  -43,   53,  -23,    15,     15,   15,    15,         31    \ Vertex 10
 VERTEX  -69,   -1,   32,     7,      2,    8,     8,         31    \ Vertex 11
 VERTEX    0,    0,  254,    15,     15,   15,    15,         31    \ Vertex 12
 VERTEX   69,   -1,   32,     9,      4,   10,    10,         31    \ Vertex 13
 VERTEX   43,   53,  -23,    15,     15,   15,    15,         31    \ Vertex 14

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         30    \ Edge 0
 EDGE       1,       2,     2,     0,         30    \ Edge 1
 EDGE       2,       3,     3,     0,         30    \ Edge 2
 EDGE       3,       4,     4,     0,         30    \ Edge 3
 EDGE       0,       4,     5,     0,         30    \ Edge 4
 EDGE       0,       5,     5,     1,         29    \ Edge 5
 EDGE       1,       6,     2,     1,         29    \ Edge 6
 EDGE       2,       7,     3,     2,         29    \ Edge 7
 EDGE       3,       8,     4,     3,         29    \ Edge 8
 EDGE       4,       9,     5,     4,         29    \ Edge 9
 EDGE       5,      10,     6,     1,         30    \ Edge 10
 EDGE       6,      10,     7,     1,         30    \ Edge 11
 EDGE       6,      11,     7,     2,         30    \ Edge 12
 EDGE       7,      11,     8,     2,         30    \ Edge 13
 EDGE       7,      12,     8,     3,         31    \ Edge 14
 EDGE       8,      12,     9,     3,         31    \ Edge 15
 EDGE       8,      13,     9,     4,         30    \ Edge 16
 EDGE       9,      13,    10,     4,         30    \ Edge 17
 EDGE       9,      14,    10,     5,         30    \ Edge 18
 EDGE       5,      14,     6,     5,         30    \ Edge 19
 EDGE      10,      14,    11,     6,         30    \ Edge 20
 EDGE      10,      12,    11,     7,         31    \ Edge 21
 EDGE      11,      12,     8,     7,         31    \ Edge 22
 EDGE      12,      13,    10,     9,         31    \ Edge 23
 EDGE      12,      14,    11,    10,         31    \ Edge 24

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,      -51,      -49,         30    \ Face 0
 FACE      -51,       18,      -87,         30    \ Face 1
 FACE      -77,      -57,      -19,         30    \ Face 2
 FACE        0,      -90,       16,         31    \ Face 3
 FACE       77,      -57,      -19,         30    \ Face 4
 FACE       51,       18,      -87,         30    \ Face 5
 FACE        0,      111,      -20,         30    \ Face 6
 FACE      -97,       72,       24,         31    \ Face 7
 FACE     -108,      -68,       34,         31    \ Face 8
 FACE      108,      -68,       34,         31    \ Face 9
 FACE       97,       72,       24,         31    \ Face 10
 FACE        0,       94,       18,         31    \ Face 11

\ ******************************************************************************
\
\       Name: SHIP_WORM
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Worm
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_WORM

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 99 * 99           \ Targetable area          = 99 * 99
 EQUB &50               \ Edges data offset (low)  = &0050
 EQUB &90               \ Faces data offset (low)  = &0090
 EQUB 73                \ Max. edge count          = (73 - 1) / 4 = 18
 EQUB 0                 \ Gun vertex               = 0
 EQUB 18                \ Explosion count          = 3, as (4 * n) + 6 = 18
 EQUB 60                \ Number of vertices       = 60 / 6 = 10
 EQUB 16                \ Number of edges          = 16
 EQUW 0                 \ Bounty                   = 0
 EQUB 32                \ Number of faces          = 32 / 4 = 8
 EQUB 19                \ Visibility distance      = 19

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB 30              \ Max. energy              = 30

                        \ --- And replaced by the following: -------------------

 EQUB 32                \ Max. energy              = 32

                        \ --- End of replacement code --------------------------

 EQUB 23                \ Max. speed               = 23
 EQUB &00               \ Edges data offset (high) = &0050
 EQUB &00               \ Faces data offset (high) = &0090
 EQUB 3                 \ Normals are scaled by    = 2^3 = 8

                        \ --- Original Acornsoft code removed from Elite-A: ----

\  EQUB %00001000       \ Laser power              = 1
\                       \ Missiles                 = 0

                        \ --- And replaced by the following: -------------------

 EQUB %00011000         \ Laser power              = 3
                        \ Missiles                 = 0

                        \ --- End of replacement code --------------------------

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   10,  -10,   35,     2,      0,    7,     7,         31    \ Vertex 0
 VERTEX  -10,  -10,   35,     3,      0,    7,     7,         31    \ Vertex 1
 VERTEX    5,    6,   15,     1,      0,    4,     2,         31    \ Vertex 2
 VERTEX   -5,    6,   15,     1,      0,    5,     3,         31    \ Vertex 3
 VERTEX   15,  -10,   25,     4,      2,    7,     7,         31    \ Vertex 4
 VERTEX  -15,  -10,   25,     5,      3,    7,     7,         31    \ Vertex 5
 VERTEX   26,  -10,  -25,     6,      4,    7,     7,         31    \ Vertex 6
 VERTEX  -26,  -10,  -25,     6,      5,    7,     7,         31    \ Vertex 7
 VERTEX    8,   14,  -25,     4,      1,    6,     6,         31    \ Vertex 8
 VERTEX   -8,   14,  -25,     5,      1,    6,     6,         31    \ Vertex 9

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    \ Edge 0
 EDGE       1,       5,     7,     3,         31    \ Edge 1
 EDGE       5,       7,     7,     5,         31    \ Edge 2
 EDGE       7,       6,     7,     6,         31    \ Edge 3
 EDGE       6,       4,     7,     4,         31    \ Edge 4
 EDGE       4,       0,     7,     2,         31    \ Edge 5
 EDGE       0,       2,     2,     0,         31    \ Edge 6
 EDGE       1,       3,     3,     0,         31    \ Edge 7
 EDGE       4,       2,     4,     2,         31    \ Edge 8
 EDGE       5,       3,     5,     3,         31    \ Edge 9
 EDGE       2,       8,     4,     1,         31    \ Edge 10
 EDGE       8,       6,     6,     4,         31    \ Edge 11
 EDGE       3,       9,     5,     1,         31    \ Edge 12
 EDGE       9,       7,     6,     5,         31    \ Edge 13
 EDGE       2,       3,     1,     0,         31    \ Edge 14
 EDGE       8,       9,     6,     1,         31    \ Edge 15

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       88,       70,         31    \ Face 0
 FACE        0,       69,       14,         31    \ Face 1
 FACE       70,       66,       35,         31    \ Face 2
 FACE      -70,       66,       35,         31    \ Face 3
 FACE       64,       49,       14,         31    \ Face 4
 FACE      -64,       49,       14,         31    \ Face 5
 FACE        0,        0,     -200,         31    \ Face 6
 FACE        0,      -80,        0,         31    \ Face 7

\ ******************************************************************************
\
\       Name: ship_ghavial
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Ghavial
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Code added for Elite-A: --------------------------

.ship_ghavial

 EQUB 3                 \ Max. canisters on demise = 3
 EQUW 9728              \ Targetable area          = 98.63 * 98.63
 EQUB &5C               \ Edges data offset (low)  = &005C
 EQUB &B4               \ Faces data offset (low)  = &00B4
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
 EQUB &00               \ Edges data offset (high) = &005C
 EQUB &00               \ Faces data offset (high) = &00B4
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00100111         \ Laser power              = 4
                        \ Missiles                 = 7

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       62,       14,         31    \ Face 0
 FACE       51,       36,       12,         31    \ Face 1
 FACE       51,       28,      -25,         31    \ Face 2
 FACE        0,       48,      -42,         31    \ Face 3
 FACE      -51,       28,      -25,         31    \ Face 4
 FACE      -51,       36,       12,         31    \ Face 5
 FACE        0,      -62,       15,         31    \ Face 6
 FACE       28,      -56,        7,         31    \ Face 7
 FACE       27,      -55,      -13,         31    \ Face 8
 FACE        0,      -51,      -38,         31    \ Face 9
 FACE      -27,      -55,      -13,         31    \ Face 10
 FACE      -28,      -56,        7,         31    \ Face 11

                        \ --- End of added code --------------------------------

\ ******************************************************************************
\
\       Name: ship_ophidian
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Ophidian
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Code added for Elite-A: --------------------------

.ship_ophidian

 EQUB 2                 \ Max. canisters on demise = 2
 EQUW 3720              \ Targetable area          = 60.99 * 60.99
 EQUB &8C               \ Edges data offset (low)  = &008C
 EQUB &04               \ Faces data offset (low)  = &0104
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
 EQUB &00               \ Edges data offset (high) = &008C
 EQUB &01               \ Faces data offset (high) = &0104
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00011010         \ Laser power              = 3
                        \ Missiles                 = 2

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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

                        \ --- End of added code --------------------------------

 EQUB 7                 \ AJD

\ ******************************************************************************
\
\ Save output/S.I.bin
\
\ ******************************************************************************

PRINT "S.S.I ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/S.I.bin", CODE%, CODE% + &0A00
