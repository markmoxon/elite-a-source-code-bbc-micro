\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE W
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
\   * output/S.W.bin
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)
_BUG_FIX                = (_RELEASE = 3)

GUARD &6000             \ Guard against assembling over screen memory

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
\    Summary: Ship blueprints lookup table for the S.W file
\  Deep dive: Ship blueprints in Elite-A
\
\ ******************************************************************************

.XX21

 EQUW SHIP_MISSILE      \ MSL  =  1 = Missile                            Missile
 EQUW SHIP_CORIOLIS     \ SST  =  2 = Coriolis space station             Station
 EQUW SHIP_ESCAPE_POD   \ ESC  =  3 = Escape pod                      Escape pod
 EQUW 0                 \                                                  Cargo
 EQUW SHIP_CANISTER     \ OIL  =  5 = Cargo canister                       Cargo
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                 Mining
 EQUW 0                 \                                                Shuttle
 EQUW SHIP_TRANSPORTER  \        10 = Transporter                    Transporter
 EQUW 0                 \                                                 Trader
 EQUW 0                 \                                                 Trader
 EQUW SHIP_FER_DE_LANCE \        13 = Fer-de-lance                        Trader
 EQUW SHIP_DRAGON       \        14 = Dragon                          Large ship
 EQUW SHIP_SIDEWINDER   \        15 = Sidewinder                      Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_SIDEWINDER   \        17 = Sidewinder                          Pirate
 EQUW SHIP_KRAIT        \        18 = Krait                               Pirate
 EQUW SHIP_MAMBA        \        19 = Mamba                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_FER_DE_LANCE \        24 = Fer-de-lance                        Pirate
 EQUW SHIP_FER_DE_LANCE \        25 = Fer-de-lance                 Bounty hunter
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
\    Summary: Ship blueprints default NEWB flags for the S.W file
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
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %01100001         \ Transporter                      Trader, innocent, cop
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Fer-de-lance                      Innocent, escape pod
 EQUB %00100001         \ Dragon                                Trader, innocent
 EQUB %00001100         \ Sidewinder                             Hostile, pirate
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %00001100         \ Sidewinder                             Hostile, pirate
 EQUB %10001100         \ Krait                      Hostile, pirate, escape pod
 EQUB %10000100         \ Mamba                              Hostile, escape pod
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Fer-de-lance               Hostile, pirate, escape pod
 EQUB %10000010         \ Fer-de-lance                 Bounty hunter, escape pod
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
                        \ Market item when scooped = 2 + 1 = 3 (slaves)
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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 17               \ Max. energy              = 17

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 12                \ Visibility distance      = 12

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 17               \ Max. energy              = 17

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 200               \ Bounty                   = 100

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 23                \ Visibility distance      = 23

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 100              \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 92                \ Max. energy              = 91

                        \ --- End of replacement ------------------------------>

 EQUB 32                \ Max. speed               = 32
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00BE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010001        \ Laser power              = 2
\                       \ Missiles                 = 1

                        \ --- And replaced by: -------------------------------->

 EQUB %00110001         \ Laser power              = 6
                        \ Missiles                 = 1

                        \ --- End of replacement ------------------------------>

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
\       Name: SHIP_DRAGON
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Dragon
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Whole section added for Elite-A: ----------->

.SHIP_DRAGON

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 26192             \ Targetable area          = 161.83 * 161.83
 EQUB &4A               \ Edges data offset (low)  = &004A
 EQUB &9E               \ Faces data offset (low)  = &009E
 EQUB 65                \ Max. edge count          = (65 - 1) / 4 = 16
 EQUB 0                 \ Gun vertex               = 0
 EQUB 60                \ Explosion count          = 13, as (4 * n) + 6 = 60
 EQUB 54                \ Number of vertices       = 54 / 6 = 9
 EQUB 21                \ Number of edges          = 21
 EQUW 200               \ Bounty                   = 200
 EQUB 56                \ Number of faces          = 56 / 4 = 14
 EQUB 32                \ Visibility distance      = 32
 EQUB 255               \ Max. energy              = 255
 EQUB 20                \ Max. speed               = 20
 EQUB &00               \ Edges data offset (high) = &004A
 EQUB &00               \ Faces data offset (high) = &009E
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %01001111         \ Laser power              = 9
                        \ Missiles                 = 7

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,  250,    11,     6,     5,     0,         31     \ Vertex 0
 VERTEX  216,    0,  124,     7,     6,     1,     0,         31     \ Vertex 1
 VERTEX  216,    0, -124,     8,     7,     2,     1,         31     \ Vertex 2
 VERTEX    0,   40, -250,    13,    12,     3,     2,         31     \ Vertex 3
 VERTEX    0,  -40, -250,    13,    12,     9,     8,         31     \ Vertex 4
 VERTEX -216,    0, -124,    10,     9,     4,     3,         31     \ Vertex 5
 VERTEX -216,    0,  124,    11,    10,     5,     4,         31     \ Vertex 6
 VERTEX    0,   80,    0,    15,    15,    15,    15,         31     \ Vertex 7
 VERTEX    0,  -80,    0,    15,    15,    15,    15,         31     \ Vertex 8

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       1,       7,     1,     0,         31    \ Edge 0
 EDGE       2,       7,     2,     1,         31    \ Edge 1
 EDGE       3,       7,     3,     2,         31    \ Edge 2
 EDGE       5,       7,     4,     3,         31    \ Edge 3
 EDGE       6,       7,     5,     4,         31    \ Edge 4
 EDGE       0,       7,     0,     5,         31    \ Edge 5
 EDGE       1,       8,     7,     6,         31    \ Edge 6
 EDGE       2,       8,     8,     7,         31    \ Edge 7
 EDGE       4,       8,     9,     8,         31    \ Edge 8
 EDGE       5,       8,    10,     9,         31    \ Edge 9
 EDGE       6,       8,    11,    10,         31    \ Edge 10
 EDGE       0,       8,     6,    11,         31    \ Edge 11
 EDGE       0,       1,     6,     0,         31    \ Edge 12
 EDGE       1,       2,     7,     1,         31    \ Edge 13
 EDGE       5,       6,    10,     4,         31    \ Edge 14
 EDGE       0,       6,    11,     5,         31    \ Edge 15
 EDGE       2,       3,    12,     2,         31    \ Edge 16
 EDGE       2,       4,    12,     8,         31    \ Edge 17
 EDGE       3,       5,    13,     3,         31    \ Edge 18
 EDGE       4,       5,    13,     9,         31    \ Edge 19
 EDGE       3,       4,    13,    12,         31    \ Edge 20

\FACE normal_x, normal_y, normal_z, visibility
 FACE       16,       90,       28,         31    \ Face 0
 FACE       33,       90,        0,         31    \ Face 1
 FACE       25,       91,      -14,         31    \ Face 2
 FACE      -25,       91,      -14,         31    \ Face 3
 FACE      -33,       90,        0,         31    \ Face 4
 FACE      -16,       90,       28,         31    \ Face 5
 FACE       16,      -90,       28,         31    \ Face 6
 FACE       33,      -90,        0,         31    \ Face 7
 FACE       25,      -91,      -14,         31    \ Face 8
 FACE      -25,      -91,      -14,         31    \ Face 9
 FACE      -33,      -90,        0,         31    \ Face 10
 FACE      -16,      -90,       28,         31    \ Face 11
 FACE       48,        0,      -82,         31    \ Face 12
 FACE      -48,        0,      -82,         31    \ Face 13

                        \ --- End of added section ---------------------------->

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
 EQUB &50               \ Edges data offset (low)  = &0050
 EQUB &8C               \ Faces data offset (low)  = &008C
 EQUB 61                \ Max. edge count          = (61 - 1) / 4 = 15
 EQUB 0                 \ Gun vertex               = 0
 EQUB 30                \ Explosion count          = 6, as (4 * n) + 6 = 30
 EQUB 60                \ Number of vertices       = 60 / 6 = 10
 EQUB 15                \ Number of edges          = 15

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 50               \ Bounty                   = 50

                        \ --- And replaced by: -------------------------------->

 EQUW 300               \ Bounty                   = 300

                        \ --- End of replacement ------------------------------>

 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 20                \ Visibility distance      = 20

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 70               \ Max. energy              = 70

                        \ --- And replaced by: -------------------------------->

 EQUB 81                \ Max. energy              = 81

                        \ --- End of replacement ------------------------------>

 EQUB 37                \ Max. speed               = 37
 EQUB &00               \ Edges data offset (high) = &0050
 EQUB &00               \ Faces data offset (high) = &008C
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010000        \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00101000         \ Laser power              = 5
                        \ Missiles                 = 0

                        \ --- End of replacement ------------------------------>

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,       32,        8,         31    \ Face 0
 FACE      -12,       47,        6,         31    \ Face 1
 FACE       12,       47,        6,         31    \ Face 2
 FACE        0,        0,     -112,         31    \ Face 3
 FACE      -12,      -47,        6,         31    \ Face 4
 FACE        0,      -32,        8,         31    \ Face 5
 FACE       12,      -47,        6,         31    \ Face 6

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 100              \ Bounty                   = 100

                        \ --- And replaced by: -------------------------------->

 EQUW 400               \ Bounty                   = 200

                        \ --- End of replacement ------------------------------>

 EQUB 24                \ Number of faces          = 24 / 4 = 6
 EQUB 25                \ Visibility distance      = 25

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 80               \ Max. energy              = 80

                        \ --- And replaced by: -------------------------------->

 EQUB 82                \ Max. energy              = 82

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &007A
 EQUB &00               \ Faces data offset (high) = &00CE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010000        \ Laser power              = 2
\                       \ Missiles                 = 0

                        \ --- And replaced by: -------------------------------->

 EQUB %00101000         \ Laser power              = 5
                        \ Missiles                 = 0

                        \ --- End of replacement ------------------------------>

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 550               \ Bounty                   = 550

                        \ --- End of replacement ------------------------------>

 EQUB 40                \ Number of faces          = 40 / 4 = 10
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 160              \ Max. energy              = 160

                        \ --- And replaced by: -------------------------------->

 EQUB 92                \ Max. energy              = 92

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &0086
 EQUB &00               \ Faces data offset (high) = &00F2
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010010        \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00111010         \ Laser power              = 7
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

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
 EQUB &F2               \ Edges data offset (low)  = &00F2
 EQUB &AA               \ Faces data offset (low)  = &01AA
 EQUB 145               \ Max. edge count          = (145 - 1) / 4 = 36
 EQUB 48                \ Gun vertex               = 48
 EQUB 26                \ Explosion count          = 5, as (4 * n) + 6 = 26
 EQUB 222               \ Number of vertices       = 222 / 6 = 37
 EQUB 46                \ Number of edges          = 46
 EQUW 0                 \ Bounty                   = 0
 EQUB 56                \ Number of faces          = 56 / 4 = 14
 EQUB 16                \ Visibility distance      = 16
 EQUB 32                \ Max. energy              = 32
 EQUB 10                \ Max. speed               = 10
 EQUB &00               \ Edges data offset (high) = &00F2
 EQUB &01               \ Faces data offset (high) = &01AA

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 2                \ Normals are scaled by    = 2^2 = 4

                        \ --- And replaced by: -------------------------------->

 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- End of replacement ------------------------------>

 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

                        \ --- Mod: Original Acornsoft code removed: ----------->

\\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     7,     0,         31    \ Edge 0
 EDGE       1,       2,     1,     0,         31    \ Edge 1
 EDGE       2,       3,     2,     0,         31    \ Edge 2
 EDGE       3,       4,     3,     0,         31    \ Edge 3
 EDGE       4,       5,     4,     0,         31    \ Edge 4
 EDGE       5,       6,     5,     0,         31    \ Edge 5
 EDGE       0,       6,     6,     0,         31    \ Edge 6

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       0,       7,     7,     6,         16   \ Edge 7

                        \ --- And replaced by: -------------------------------->

 EDGE       0,       7,     7,     6,         15    \ Edge 7

                        \ --- End of replacement ------------------------------>

 EDGE       1,       8,     7,     1,         31    \ Edge 8

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       2,       9,     2,     1,         11   \ Edge 9

                        \ --- And replaced by: -------------------------------->

 EDGE       2,       9,     2,     1,         10    \ Edge 9

                        \ --- End of replacement ------------------------------>

 EDGE       3,       9,     3,     2,         31    \ Edge 10
 EDGE       4,      10,     4,     3,         31    \ Edge 11

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       5,      10,     5,     4,         11   \ Edge 12

                        \ --- And replaced by: -------------------------------->

 EDGE       5,      10,     5,     4,         10    \ Edge 12

                        \ --- End of replacement ------------------------------>

 EDGE       6,      11,     6,     5,         31    \ Edge 13

                        \ --- Mod: Original Acornsoft code removed: ----------->

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,        0,     -103,         31    \ Face 0
 FACE     -111,       48,       -7,         31    \ Face 1
 FACE     -105,      -63,      -21,         31    \ Face 2
 FACE        0,      -34,        0,         31    \ Face 3
 FACE      105,      -63,      -21,         31    \ Face 4
 FACE      111,       48,       -7,         31    \ Face 5
 FACE        8,       32,        3,         31    \ Face 6
 FACE       -8,       32,        3,         31    \ Face 7

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ FACE       -8,       34,       11,         19   \ Face 8

                        \ --- And replaced by: -------------------------------->

 FACE       -8,       34,       11,         18    \ Face 8

                        \ --- End of replacement ------------------------------>

 FACE      -75,       32,       79,         31    \ Face 9
 FACE       75,       32,       79,         31    \ Face 10

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ FACE        8,       34,       11,         19   \ Face 11

                        \ --- And replaced by: -------------------------------->

 FACE        8,       34,       11,         18    \ Face 11

                        \ --- End of replacement ------------------------------>

 FACE        0,       38,       17,         31    \ Face 12
 FACE        0,        0,      121,         31    \ Face 13

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
 EQUB &AA               \ Edges data offset (low)  = &00AA
 EQUB &1A               \ Faces data offset (low)  = &001A
 EQUB 93                \ Max. edge count          = (93 - 1) / 4 = 23
 EQUB 0                 \ Gun vertex               = 0
 EQUB 34                \ Explosion count          = 7, as (4 * n) + 6 = 34
 EQUB 150               \ Number of vertices       = 150 / 6 = 25
 EQUB 28                \ Number of edges          = 28

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 150              \ Bounty                   = 150

                        \ --- And replaced by: -------------------------------->

 EQUW 350               \ Bounty                   = 350

                        \ --- End of replacement ------------------------------>

 EQUB 20                \ Number of faces          = 20 / 4 = 5
 EQUB 25                \ Visibility distance      = 25

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 90               \ Max. energy              = 90

                        \ --- And replaced by: -------------------------------->

 EQUB 81                \ Max. energy              = 81

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &00AA
 EQUB &01               \ Faces data offset (high) = &001A
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010010        \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00101010         \ Laser power              = 5
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,      -24,        2,         30    \ Face 0
 FACE        0,       24,        2,         30    \ Face 1
 FACE      -32,       64,       16,         30    \ Face 2
 FACE       32,       64,       16,         30    \ Face 3
 FACE        0,        0,     -127,         30    \ Face 4

 EQUB 5                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save output/S.W.bin
\
\ ******************************************************************************

PRINT "S.S.W ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/S.W.bin", CODE%, CODE% + &0A00
