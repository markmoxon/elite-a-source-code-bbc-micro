\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE K
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
\   * output/S.K.bin
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
\    Summary: Ship blueprints lookup table for the S.K file
\  Deep dive: Ship blueprints in the disc version
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile
 EQUW SHIP_CORIOLIS     \ SST  =  2 = Coriolis space station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod
 EQUW 0
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister
 EQUW SHIP_BOULDER      \         6 = Boulder
 EQUW SHIP_ASTEROID     \ AST  =  7 = Asteroid
 EQUW SHIP_SPLINTER     \ SPL  =  8 = Splinter
 EQUW 0
 EQUW 0
 EQUW SHIP_BOA          \        11 = Boa
 EQUW ship_ophidian     \        12 = Ophidian
 EQUW SHIP_FER_DE_LANCE \        13 = Fer-de-lance
 EQUW 0
 EQUW 0
 EQUW SHIP_VIPER        \ COPS = 16 = Viper
 EQUW SHIP_GECKO        \        17 = Gecko
 EQUW SHIP_KRAIT        \        18 = Krait
 EQUW 0
 EQUW 0
 EQUW ship_ophidian     \        21 = Ophidian
 EQUW 0
 EQUW 0
 EQUW SHIP_FER_DE_LANCE \        24 = Fer-de-lance
 EQUW SHIP_FER_DE_LANCE \        25 = Fer-de-lance
 EQUW 0
 EQUW SHIP_GECKO        \        27 = Gecko
 EQUW ship_ophidian     \        28 = Ophidian
 EQUW 0
 EQUW 0
 EQUW 0

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.K file
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
 EQUB %00000000         \ Boulder
 EQUB %00000000         \ Asteroid
 EQUB %00000000         \ Splinter
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Boa                               Innocent, escape pod
 EQUB %10100001         \ Ophidian                  Trader, innocent, escape pod
 EQUB %10100000         \ Fer-de-lance                      Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Gecko                      Hostile, pirate, escape pod
 EQUB %10001100         \ Krait                      Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Fer-de-lance               Hostile, pirate, escape pod
 EQUB %10000010         \ Fer-de-lance                 Bounty hunter, escape pod
 EQUB 0
 EQUB %10000010         \ Gecko                        Bounty hunter, escape pod
 EQUB %10100010         \ Ophidian           Bounty hunter, innocent, escape pod
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

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 17              \ Max. energy              = 17
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 8                 \ Max. energy              = 8

\ <------------------------------------------------------- End of added code -->

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

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 0               \ Bounty                   = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 1                 \ Bounty                   = 1

\ <------------------------------------------------------- End of added code -->

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 12                \ Visibility distance      = 12

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 17              \ Max. energy              = 17
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 8                 \ Max. energy              = 8

\ <------------------------------------------------------- End of added code -->

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

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 0               \ Bounty                   = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 0                 \ Bounty                   = 0

\ <------------------------------------------------------- End of added code -->

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 23                \ Visibility distance      = 23

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 100             \ Max. energy              = 100
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 91                \ Max. energy              = 91

\ <------------------------------------------------------- End of added code -->

 EQUB 32                \ Max. speed               = 32
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00BE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00010001       \ Laser power              = 2
\                       \ Missiles                 = 1
\ 
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00101001         \ Laser power              = 5
                        \ Missiles                 = 1

\ <------------------------------------------------------- End of added code -->

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
 EQUB &62               \ Edges data offset (low)  = &0062
 EQUB &C2               \ Faces data offset (low)  = &00C2
 EQUB 89                \ Max. edge count          = (89 - 1) / 4 = 22
 EQUB 0                 \ Gun vertex               = 0
 EQUB 38                \ Explosion count          = 8, as (4 * n) + 6 = 38
 EQUB 78                \ Number of vertices       = 78 / 6 = 13
 EQUB 24                \ Number of edges          = 24

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 0               \ Bounty                   = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 250               \ Bounty                   = 250

\ <------------------------------------------------------- End of added code -->

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 40                \ Visibility distance      = 40

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 250             \ Max. energy              = 250
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 164               \ Max. energy              = 164

\ <------------------------------------------------------- End of added code -->

 EQUB 24                \ Max. speed               = 24
 EQUB &00               \ Edges data offset (high) = &0062
 EQUB &00               \ Faces data offset (high) = &00C2
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00011100       \ Laser power              = 3
\                       \ Missiles                 = 4
\ 
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00101010         \ Laser power              = 5
                        \ Missiles                 = 2

\ <------------------------------------------------------- End of added code -->

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
\       Name: ship_ophidian
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Ophidian
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

\ <----------------------------------------- Whole routine added for Elite-A -->

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

\ <---------------------------------------------------- End of added routine -->

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
 EQUB &5C               \ Edges data offset (low)  = &005C
 EQUB &A0               \ Faces data offset (low)  = &00A0
 EQUB 65                \ Max. edge count          = (65 - 1) / 4 = 16
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 72                \ Number of vertices       = 72 / 6 = 12
 EQUB 17                \ Number of edges          = 17
 EQUW 55                \ Bounty                   = 55
 EQUB 36                \ Number of faces          = 36 / 4 = 9
 EQUB 18                \ Visibility distance      = 18

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 70              \ Max. energy              = 70
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 65                \ Max. energy              = 65

\ <------------------------------------------------------- End of added code -->

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &005C
 EQUB &00               \ Faces data offset (high) = &00A0
 EQUB 3                 \ Normals are scaled by    = 2^3 = 8

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00010000       \ Laser power              = 2
\                       \ Missiles                 = 0
\ 
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

\ <------------------------------------------------------- End of added code -->

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
 EQUB &86               \ Edges data offset (low)  = &0086
 EQUB &F2               \ Faces data offset (low)  = &00F2
 EQUB 105               \ Max. edge count          = (105 - 1) / 4 = 26
 EQUB 0                 \ Gun vertex               = 0
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 114               \ Number of vertices       = 114 / 6 = 19
 EQUB 27                \ Number of edges          = 27

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 0               \ Bounty                   = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 250               \ Bounty                   = 250

\ <------------------------------------------------------- End of added code -->

 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 40                \ Visibility distance      = 40

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 160             \ Max. energy              = 160
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 83                \ Max. energy              = 83

\ <------------------------------------------------------- End of added code -->

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &0086
 EQUB &00               \ Faces data offset (high) = &00F2
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00010010       \ Laser power              = 2
\                       \ Missiles                 = 2
\ 
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00110010         \ Laser power              = 6
                        \ Missiles                 = 2

\ <------------------------------------------------------- End of added code -->

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       24,        6,         28    \ Face 0
 FACE      -68,        0,       24,         31    \ Face 1
 FACE      -63,        0,      -37,         31    \ Face 2
 FACE        0,        0,     -104,         31    \ Face 3
 FACE       63,        0,      -37,         31    \ Face 4
 FACE       68,        0,       24,         31    \ Face 5
 FACE      -12,       46,      -19,         28    \ Face 6
 FACE        0,       45,      -22,         28    \ Face 7
 FACE       12,       46,      -19,         28    \ Face 8
 FACE        0,      -28,        0,         31    \ Face 9

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

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 80              \ Max. energy              = 80
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 73                \ Max. energy              = 73

\ <------------------------------------------------------- End of added code -->

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &007A
 EQUB &00               \ Faces data offset (high) = &00CE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00010000       \ Laser power              = 2
\                       \ Missiles                 = 0
\ 
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00100000         \ Laser power              = 4
                        \ Missiles                 = 0

\ <------------------------------------------------------- End of added code -->

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
 EQUB &3E               \ Edges data offset (low)  = &003E
 EQUB &7A               \ Faces data offset (low)  = &007A
 EQUB 45                \ Max. edge count          = (45 - 1) / 4 = 11
 EQUB 0                 \ Gun vertex               = 0
 EQUB 14                \ Explosion count          = 2, as (4 * n) + 6 = 14
 EQUB 42                \ Number of vertices       = 42 / 6 = 7
 EQUB 15                \ Number of edges          = 15
 EQUW 1                 \ Bounty                   = 1
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 20                \ Visibility distance      = 20

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 20              \ Max. energy              = 20
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 16                \ Max. energy              = 16

\ <------------------------------------------------------- End of added code -->

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &003E
 EQUB &00               \ Faces data offset (high) = &007A
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,   37,  -11,     1,      0,    9,     5,         31    \ Vertex 0
 VERTEX   30,    7,   12,     2,      1,    6,     5,         31    \ Vertex 1
 VERTEX   28,   -7,  -12,     3,      2,    7,     6,         31    \ Vertex 2
 VERTEX    2,    0,  -39,     4,      3,    8,     7,         31    \ Vertex 3
 VERTEX  -28,   34,  -30,     4,      0,    9,     8,         31    \ Vertex 4
 VERTEX    5,  -10,   13,    15,     15,   15,    15,         31    \ Vertex 5
 VERTEX   20,   17,  -30,    15,     15,   15,    15,         31    \ Vertex 6

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
\       Name: SHIP_ASTEROID
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an asteroid
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_ASTEROID

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 80 * 80           \ Targetable area          = 80 * 80
 EQUB &4A               \ Edges data offset (low)  = &004A
 EQUB &9E               \ Faces data offset (low)  = &009E
 EQUB 65                \ Max. edge count          = (65 - 1) / 4 = 16
 EQUB 0                 \ Gun vertex               = 0
 EQUB 34                \ Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 54                \ Number of vertices       = 54 / 6 = 9
 EQUB 21                \ Number of edges          = 21

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 5               \ Bounty                   = 5
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 15                \ Bounty                   = 15

\ <------------------------------------------------------- End of added code -->

 EQUB 56                \ Number of faces          = 56 / 4 = 14
 EQUB 50                \ Visibility distance      = 50

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 60              \ Max. energy              = 60
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 56                \ Max. energy              = 56

\ <------------------------------------------------------- End of added code -->

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &004A
 EQUB &00               \ Faces data offset (high) = &009E
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,   80,    0,    15,     15,   15,    15,         31    \ Vertex 0
 VERTEX  -80,  -10,    0,    15,     15,   15,    15,         31    \ Vertex 1
 VERTEX    0,  -80,    0,    15,     15,   15,    15,         31    \ Vertex 2
 VERTEX   70,  -40,    0,    15,     15,   15,    15,         31    \ Vertex 3
 VERTEX   60,   50,    0,     5,      6,   12,    13,         31    \ Vertex 4
 VERTEX   50,    0,   60,    15,     15,   15,    15,         31    \ Vertex 5
 VERTEX  -40,    0,   70,     0,      1,    2,     3,         31    \ Vertex 6
 VERTEX    0,   30,  -75,    15,     15,   15,    15,         31    \ Vertex 7
 VERTEX    0,  -50,  -60,     8,      9,   10,    11,         31    \ Vertex 8

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     2,     7,         31    \ Edge 0
 EDGE       0,       4,     6,    13,         31    \ Edge 1
 EDGE       3,       4,     5,    12,         31    \ Edge 2
 EDGE       2,       3,     4,    11,         31    \ Edge 3
 EDGE       1,       2,     3,    10,         31    \ Edge 4
 EDGE       1,       6,     2,     3,         31    \ Edge 5
 EDGE       2,       6,     1,     3,         31    \ Edge 6
 EDGE       2,       5,     1,     4,         31    \ Edge 7
 EDGE       5,       6,     0,     1,         31    \ Edge 8
 EDGE       0,       5,     0,     6,         31    \ Edge 9
 EDGE       3,       5,     4,     5,         31    \ Edge 10
 EDGE       0,       6,     0,     2,         31    \ Edge 11
 EDGE       4,       5,     5,     6,         31    \ Edge 12
 EDGE       1,       8,     8,    10,         31    \ Edge 13
 EDGE       1,       7,     7,     8,         31    \ Edge 14
 EDGE       0,       7,     7,    13,         31    \ Edge 15
 EDGE       4,       7,    12,    13,         31    \ Edge 16
 EDGE       3,       7,     9,    12,         31    \ Edge 17
 EDGE       3,       8,     9,    11,         31    \ Edge 18
 EDGE       2,       8,    10,    11,         31    \ Edge 19
 EDGE       7,       8,     8,     9,         31    \ Edge 20

\FACE normal_x, normal_y, normal_z, visibility
 FACE        9,       66,       81,         31    \ Face 0
 FACE        9,      -66,       81,         31    \ Face 1
 FACE      -72,       64,       31,         31    \ Face 2
 FACE      -64,      -73,       47,         31    \ Face 3
 FACE       45,      -79,       65,         31    \ Face 4
 FACE      135,       15,       35,         31    \ Face 5
 FACE       38,       76,       70,         31    \ Face 6
 FACE      -66,       59,      -39,         31    \ Face 7
 FACE      -67,      -15,      -80,         31    \ Face 8
 FACE       66,      -14,      -75,         31    \ Face 9
 FACE      -70,      -80,      -40,         31    \ Face 10
 FACE       58,     -102,      -51,         31    \ Face 11
 FACE       81,        9,      -67,         31    \ Face 12
 FACE       47,       94,      -63,         31    \ Face 13

\ ******************************************************************************
\
\       Name: SHIP_SPLINTER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a splinter
\  Deep dive: Ship blueprints
\
\ ------------------------------------------------------------------------------
\
\ The ship blueprint for the splinter reuses the edges data from the escape pod,
\ so the edges data offset is negative.
\
\ ******************************************************************************

.SHIP_SPLINTER

 EQUB 0 + (11 << 4)     \ Max. canisters on demise = 0
                        \ Market item when scooped = 11 + 1 = 12 (Minerals)
 EQUW 16 * 16           \ Targetable area          = 16 * 16

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB LO(SHIP_ESCAPE_POD_EDGES - SHIP_SPLINTER)    \ Edges data = escape pod
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB &5A                                            \ AJD

\ <------------------------------------------------------- End of added code -->

 EQUB &44               \ Faces data offset (low)  = &0044
 EQUB 25                \ Max. edge count          = (25 - 1) / 4 = 6
 EQUB 0                 \ Gun vertex               = 0
 EQUB 22                \ Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 24                \ Number of vertices       = 24 / 6 = 4
 EQUB 6                 \ Number of edges          = 6

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUW 0               \ Bounty                   = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUW 1                 \ Bounty                   = 1

\ <------------------------------------------------------- End of added code -->

 EQUB 16                \ Number of faces          = 16 / 4 = 4
 EQUB 8                 \ Visibility distance      = 8

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 20              \ Max. energy              = 20
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 16                \ Max. energy              = 16

\ <------------------------------------------------------- End of added code -->

 EQUB 10                \ Max. speed               = 10

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB HI(SHIP_ESCAPE_POD_EDGES - SHIP_SPLINTER)    \ Edges data = escape pod
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB &FE                                            \ AJD

\ <------------------------------------------------------- End of added code -->

 EQUB &00               \ Faces data offset (high) = &0044
 EQUB 5                 \ Normals are scaled by    = 2^5 = 32
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -24,  -25,   16,     2,      1,    3,     3,         31    \ Vertex 0
 VERTEX    0,   12,  -10,     2,      0,    3,     3,         31    \ Vertex 1
 VERTEX   11,   -6,    2,     1,      0,    3,     3,         31    \ Vertex 2
 VERTEX   12,   42,    7,     1,      0,    2,     2,         31    \ Vertex 3

\FACE normal_x, normal_y, normal_z, visibility
 FACE       35,        0,        4,         31    \ Face 0
 FACE        3,        4,        8,         31    \ Face 1
 FACE        1,        8,       12,         31    \ Face 2
 FACE       18,       12,        0,         31    \ Face 3

 EQUB 7                 \ AJD

\ ******************************************************************************
\
\ Save output/S.K.bin
\
\ ******************************************************************************

PRINT "S.S.K ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/S.K.bin", CODE%, CODE% + &0A00
