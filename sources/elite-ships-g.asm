\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE G
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
\   * output/S.G.bin
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
\    Summary: Ship blueprints lookup table for the S.G file
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
 EQUW SHIP_ASTEROID     \ AST  =  7 = Asteroid
 EQUW SHIP_SPLINTER     \ SPL  =  8 = Splinter
 EQUW 0
 EQUW 0
 EQUW SHIP_BOA          \        11 = Boa
 EQUW SHIP_ADDER        \        12 = Adder
 EQUW ship_iguana       \        13 = Iguana
 EQUW 0
 EQUW 0
 EQUW SHIP_VIPER        \ COPS = 16 = Viper
 EQUW SHIP_GECKO        \        17 = Gecko
 EQUW 0
 EQUW SHIP_ADDER        \        19 = Adder
 EQUW ship_iguana       \        20 = Iguana
 EQUW 0
 EQUW SHIP_WORM         \        22 = Worm
 EQUW 0
 EQUW 0
 EQUW 0
 EQUW ship_iguana       \        26 = Iguana
 EQUW SHIP_ADDER        \        27 = Adder
 EQUW SHIP_GECKO        \        28 = Gecko
 EQUW 0
 EQUW 0
 EQUW SHIP_CONSTRICTOR  \ CON  = 31 = Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.G file
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
 EQUB %00000000         \ Asteroid
 EQUB %00000000         \ Splinter
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Boa                               Innocent, escape pod
 EQUB %10100001         \ Adder                     Trader, innocent, escape pod
 EQUB %10100000         \ Iguana                            Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Gecko                      Hostile, pirate, escape pod
 EQUB 0
 EQUB %10000100         \ Adder                              Hostile, escape pod
 EQUB %10001100         \ Iguana                     Hostile, pirate, escape pod
 EQUB 0
 EQUB %00001100         \ Worm                                   Hostile, pirate
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10100010         \ Iguana             Bounty hunter, innocent, escape pod
 EQUB %10000010         \ Adder                        Bounty hunter, escape pod
 EQUB %10100010         \ Gecko              Bounty hunter, innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %00001100         \ Constrictor                            Hostile, pirate

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

 EQUW 0                 \ Bounty                   = 0

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
\       Name: SHIP_CONSTRICTOR
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Constrictor
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_CONSTRICTOR

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 3               \ Max. canisters on demise = 3
\  EQUW 65 * 65         \ Targetable area          = 65 * 65
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 3 + (15 << 4)     \ Max. canisters on demise = 3
                        \ Market item when scooped = 15 + 1 = 16 (Alien items)
 EQUW 99 * 99           \ Targetable area          = 99 * 99

\ <------------------------------------------------------- End of added code -->

 EQUB &7A               \ Edges data offset (low)  = &007A
 EQUB &DA               \ Faces data offset (low)  = &00DA
 EQUB 77                \ Max. edge count          = (77 - 1) / 4 = 19
 EQUB 0                 \ Gun vertex               = 0
 EQUB 46                \ Explosion count          = 10, as (4 * n) + 6 = 46
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 24                \ Number of edges          = 24
 EQUW 0                 \ Bounty                   = 0
 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 45                \ Visibility distance      = 45

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 252             \ Max. energy              = 252
\  EQUB 36              \ Max. speed               = 36
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 115               \ Max. energy              = 115
 EQUB 55                \ Max. speed               = 55

\ <------------------------------------------------------- End of added code -->

 EQUB &00               \ Edges data offset (high) = &007A
 EQUB &00               \ Faces data offset (high) = &00DA
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00110100       \ Laser power              = 6
\                       \ Missiles                 = 4
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %01000111         \ Laser power              = 8
                        \ Missiles                 = 7

\ <------------------------------------------------------- End of added code -->

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX   20,   -7,   80,     2,      0,    9,     9,         31    \ Vertex 0
 VERTEX  -20,   -7,   80,     1,      0,    9,     9,         31    \ Vertex 1
 VERTEX  -54,   -7,   40,     4,      1,    9,     9,         31    \ Vertex 2
 VERTEX  -54,   -7,  -40,     5,      4,    9,     8,         31    \ Vertex 3
 VERTEX  -20,   13,  -40,     6,      5,    8,     8,         31    \ Vertex 4
 VERTEX   20,   13,  -40,     7,      6,    8,     8,         31    \ Vertex 5
 VERTEX   54,   -7,  -40,     7,      3,    9,     8,         31    \ Vertex 6
 VERTEX   54,   -7,   40,     3,      2,    9,     9,         31    \ Vertex 7
 VERTEX   20,   13,    5,    15,     15,   15,    15,         31    \ Vertex 8
 VERTEX  -20,   13,    5,    15,     15,   15,    15,         31    \ Vertex 9
 VERTEX   20,   -7,   62,     9,      9,    9,     9,         18    \ Vertex 10
 VERTEX  -20,   -7,   62,     9,      9,    9,     9,         18    \ Vertex 11
 VERTEX   25,   -7,  -25,     9,      9,    9,     9,         18    \ Vertex 12
 VERTEX  -25,   -7,  -25,     9,      9,    9,     9,         18    \ Vertex 13
 VERTEX   15,   -7,  -15,     9,      9,    9,     9,         10    \ Vertex 14
 VERTEX  -15,   -7,  -15,     9,      9,    9,     9,         10    \ Vertex 15
 VERTEX    0,   -7,    0,    15,      9,    1,     0,          0    \ Vertex 16

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     9,     0,         31    \ Edge 0
 EDGE       1,       2,     9,     1,         31    \ Edge 1
 EDGE       1,       9,     1,     0,         31    \ Edge 2
 EDGE       0,       8,     2,     0,         31    \ Edge 3
 EDGE       0,       7,     9,     2,         31    \ Edge 4
 EDGE       7,       8,     3,     2,         31    \ Edge 5
 EDGE       2,       9,     4,     1,         31    \ Edge 6
 EDGE       2,       3,     9,     4,         31    \ Edge 7
 EDGE       6,       7,     9,     3,         31    \ Edge 8
 EDGE       6,       8,     7,     3,         31    \ Edge 9
 EDGE       5,       8,     7,     6,         31    \ Edge 10
 EDGE       4,       9,     6,     5,         31    \ Edge 11
 EDGE       3,       9,     5,     4,         31    \ Edge 12
 EDGE       3,       4,     8,     5,         31    \ Edge 13
 EDGE       4,       5,     8,     6,         31    \ Edge 14
 EDGE       5,       6,     8,     7,         31    \ Edge 15
 EDGE       3,       6,     9,     8,         31    \ Edge 16
 EDGE       8,       9,     6,     0,         31    \ Edge 17
 EDGE      10,      12,     9,     9,         18    \ Edge 18
 EDGE      12,      14,     9,     9,          5    \ Edge 19
 EDGE      14,      10,     9,     9,         10    \ Edge 20
 EDGE      11,      15,     9,     9,         10    \ Edge 21
 EDGE      13,      15,     9,     9,          5    \ Edge 22
 EDGE      11,      13,     9,     9,         18    \ Edge 23

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       55,       15,         31    \ Face 0
 FACE      -24,       75,       20,         31    \ Face 1
 FACE       24,       75,       20,         31    \ Face 2
 FACE       44,       75,        0,         31    \ Face 3
 FACE      -44,       75,        0,         31    \ Face 4
 FACE      -44,       75,        0,         31    \ Face 5
 FACE        0,       53,        0,         31    \ Face 6
 FACE       44,       75,        0,         31    \ Face 7
 FACE        0,        0,     -160,         31    \ Face 8
 FACE        0,      -27,        0,         31    \ Face 9

\ ******************************************************************************
\
\       Name: ship_iguana
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Iguana
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.ship_iguana

 EQUB 1                 \ Max. canisters on demise = 1
 EQUW 3500              \ Targetable area          = 59.16 * 59.16
 EQUB &6E               \ Edges data offset (low)  = &006E
 EQUB &CA               \ Faces data offset (low)  = &00CA
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
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00CA
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2
 EQUB %00100011         \ Laser power              = 4
                        \ Missiles                 = 3

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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

\ ******************************************************************************
\
\       Name: SHIP_ADDER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Adder
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_ADDER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 50 * 50           \ Targetable area          = 50 * 50
 EQUB &80               \ Edges data offset (low)  = &0080
 EQUB &F4               \ Faces data offset (low)  = &00F4
 EQUB 97                \ Max. edge count          = (97 - 1) / 4 = 24
 EQUB 0                 \ Gun vertex               = 0
 EQUB 22                \ Explosion count          = 4, as (4 * n) + 6 = 22
 EQUB 108               \ Number of vertices       = 108 / 6 = 18
 EQUB 29                \ Number of edges          = 29
 EQUW 40                \ Bounty                   = 40
 EQUB 60                \ Number of faces          = 60 / 4 = 15
 EQUB 23                \ Visibility distance      = 23

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 85              \ Max. energy              = 85
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 72                \ Max. energy              = 72

\ <------------------------------------------------------- End of added code -->

 EQUB 24                \ Max. speed               = 24
 EQUB &00               \ Edges data offset (high) = &0080
 EQUB &00               \ Faces data offset (high) = &00F4
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00010000       \ Laser power              = 2
\                       \ Missiles                 = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00100001         \ Laser power              = 4
                        \ Missiles                 = 1

\ <------------------------------------------------------- End of added code -->

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -18,    0,   40,     1,      0,   12,    11,         31    \ Vertex 0
 VERTEX   18,    0,   40,     1,      0,    3,     2,         31    \ Vertex 1
 VERTEX   30,    0,  -24,     3,      2,    5,     4,         31    \ Vertex 2
 VERTEX   30,    0,  -40,     5,      4,    6,     6,         31    \ Vertex 3
 VERTEX   18,   -7,  -40,     6,      5,   14,     7,         31    \ Vertex 4
 VERTEX  -18,   -7,  -40,     8,      7,   14,    10,         31    \ Vertex 5
 VERTEX  -30,    0,  -40,     9,      8,   10,    10,         31    \ Vertex 6
 VERTEX  -30,    0,  -24,    10,      9,   12,    11,         31    \ Vertex 7
 VERTEX  -18,    7,  -40,     8,      7,   13,     9,         31    \ Vertex 8
 VERTEX   18,    7,  -40,     6,      4,   13,     7,         31    \ Vertex 9
 VERTEX  -18,    7,   13,     9,      0,   13,    11,         31    \ Vertex 10
 VERTEX   18,    7,   13,     2,      0,   13,     4,         31    \ Vertex 11
 VERTEX  -18,   -7,   13,    10,      1,   14,    12,         31    \ Vertex 12
 VERTEX   18,   -7,   13,     3,      1,   14,     5,         31    \ Vertex 13
 VERTEX  -11,    3,   29,     0,      0,    0,     0,          5    \ Vertex 14
 VERTEX   11,    3,   29,     0,      0,    0,     0,          5    \ Vertex 15
 VERTEX   11,    4,   24,     0,      0,    0,     0,          4    \ Vertex 16
 VERTEX  -11,    4,   24,     0,      0,    0,     0,          4    \ Vertex 17

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     0,         31    \ Edge 0
 EDGE       1,       2,     3,     2,          7    \ Edge 1
 EDGE       2,       3,     5,     4,         31    \ Edge 2
 EDGE       3,       4,     6,     5,         31    \ Edge 3
 EDGE       4,       5,    14,     7,         31    \ Edge 4
 EDGE       5,       6,    10,     8,         31    \ Edge 5
 EDGE       6,       7,    10,     9,         31    \ Edge 6
 EDGE       7,       0,    12,    11,          7    \ Edge 7
 EDGE       3,       9,     6,     4,         31    \ Edge 8
 EDGE       9,       8,    13,     7,         31    \ Edge 9
 EDGE       8,       6,     9,     8,         31    \ Edge 10
 EDGE       0,      10,    11,     0,         31    \ Edge 11
 EDGE       7,      10,    11,     9,         31    \ Edge 12
 EDGE       1,      11,     2,     0,         31    \ Edge 13
 EDGE       2,      11,     4,     2,         31    \ Edge 14
 EDGE       0,      12,    12,     1,         31    \ Edge 15
 EDGE       7,      12,    12,    10,         31    \ Edge 16
 EDGE       1,      13,     3,     1,         31    \ Edge 17
 EDGE       2,      13,     5,     3,         31    \ Edge 18
 EDGE      10,      11,    13,     0,         31    \ Edge 19
 EDGE      12,      13,    14,     1,         31    \ Edge 20
 EDGE       8,      10,    13,     9,         31    \ Edge 21
 EDGE       9,      11,    13,     4,         31    \ Edge 22
 EDGE       5,      12,    14,    10,         31    \ Edge 23
 EDGE       4,      13,    14,     5,         31    \ Edge 24
 EDGE      14,      15,     0,     0,          5    \ Edge 25
 EDGE      15,      16,     0,     0,          3    \ Edge 26
 EDGE      16,      17,     0,     0,          4    \ Edge 27
 EDGE      17,      14,     0,     0,          3    \ Edge 28

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       39,       10,         31    \ Face 0
 FACE        0,      -39,       10,         31    \ Face 1
 FACE       69,       50,       13,         31    \ Face 2
 FACE       69,      -50,       13,         31    \ Face 3
 FACE       30,       52,        0,         31    \ Face 4
 FACE       30,      -52,        0,         31    \ Face 5
 FACE        0,        0,     -160,         31    \ Face 6
 FACE        0,        0,     -160,         31    \ Face 7
 FACE        0,        0,     -160,         31    \ Face 8
 FACE      -30,       52,        0,         31    \ Face 9
 FACE      -30,      -52,        0,         31    \ Face 10
 FACE      -69,       50,       13,         31    \ Face 11
 FACE      -69,      -50,       13,         31    \ Face 12
 FACE        0,       28,        0,         31    \ Face 13
 FACE        0,      -28,        0,         31    \ Face 14

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

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB 30              \ Max. energy              = 30
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB 32                \ Max. energy              = 32

\ <------------------------------------------------------- End of added code -->

 EQUB 23                \ Max. speed               = 23
 EQUB &00               \ Edges data offset (high) = &0050
 EQUB &00               \ Faces data offset (high) = &0090
 EQUB 3                 \ Normals are scaled by    = 2^3 = 8

\ <----------------------------- Code deleted from the original disc version -->
\
\  EQUB %00001000       \ Laser power              = 1
\                       \ Missiles                 = 0
\
\ <----------------------------------------------------- End of deleted code -->

\ <-------------------------------------------------- Code added for Elite-A -->

 EQUB %00011000         \ Laser power              = 3
                        \ Missiles                 = 0

\ <------------------------------------------------------- End of added code -->

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

 EQUB 8                 \ AJD

\ ******************************************************************************
\
\ Save output/S.G.bin
\
\ ******************************************************************************

PRINT "S.S.G ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/S.G.bin", CODE%, CODE% + &0A00
