\ ******************************************************************************
\
\ ELITE-A SHIP BLUEPRINTS FILE F
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
\   * output/S.F.bin
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
\    Summary: Ship blueprints lookup table for the S.F file
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
 EQUW 0                 \                                                Shuttle
 EQUW 0                 \                                            Transporter
 EQUW SHIP_PYTHON       \        11 = Python                              Trader
 EQUW SHIP_OPHIDIAN     \        12 = Ophidian                            Trader
 EQUW SHIP_BOA          \        13 = Boa                                 Trader
 EQUW 0                 \                                             Large ship
 EQUW 0                 \                                             Small ship
 EQUW SHIP_VIPER        \ COPS = 16 = Viper                                  Cop
 EQUW SHIP_MAMBA        \        17 = Mamba                               Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                                 Pirate
 EQUW SHIP_BUSHMASTER   \        20 = Bushmaster                          Pirate
 EQUW SHIP_OPHIDIAN     \        21 = Ophidian                            Pirate
 EQUW SHIP_PYTHON       \        22 = Python                              Pirate
 EQUW SHIP_IGUANA       \        23 = Iguana                              Pirate
 EQUW 0                 \                                                 Pirate
 EQUW 0                 \                                          Bounty hunter
 EQUW SHIP_BUSHMASTER   \        26 = Bushmaster                   Bounty hunter
 EQUW SHIP_PYTHON       \        27 = Python                       Bounty hunter
 EQUW SHIP_OPHIDIAN     \        28 = Ophidian                     Bounty hunter
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                               Thargoid
 EQUW 0                 \                                            Constrictor

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprints default NEWB flags for the S.F file
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
 EQUB 0
 EQUB 0
 EQUB %10100000         \ Python                            Innocent, escape pod
 EQUB %10100001         \ Ophidian                  Trader, innocent, escape pod
 EQUB %10100000         \ Boa                               Innocent, escape pod
 EQUB 0
 EQUB 0
 EQUB %11000010         \ Viper                   Bounty hunter, cop, escape pod
 EQUB %10001100         \ Mamba                      Hostile, pirate, escape pod
 EQUB 0
 EQUB 0
 EQUB %10001100         \ Bushmaster                 Hostile, pirate, escape pod
 EQUB %10000100         \ Ophidian                           Hostile, escape pod
 EQUB %10001100         \ Python                     Hostile, pirate, escape pod
 EQUB %10000100         \ Iguana                             Hostile, escape pod
 EQUB 0
 EQUB 0
 EQUB %10100010         \ Bushmaster         Bounty hunter, innocent, escape pod
 EQUB %10000010         \ Python                       Bounty hunter, escape pod
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
 EQUB &A4               \ Edges data offset (low)  = &00A4
 EQUB &2C               \ Faces data offset (low)  = &012C
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
 EQUB &00               \ Edges data offset (high) = &00A4
 EQUB &01               \ Faces data offset (high) = &012C
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
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
 EQUW 0                 \ Bounty                   = 0
 EQUB 28                \ Number of faces          = 28 / 4 = 7
 EQUB 23                \ Visibility distance      = 23

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 100              \ Max. energy              = 100

                        \ --- And replaced by: -------------------------------->

 EQUB 91                \ Max. energy              = 91

                        \ --- End of replacement ------------------------------>

 EQUB 32                \ Max. speed               = 32
 EQUB &00               \ Edges data offset (high) = &006E
 EQUB &00               \ Faces data offset (high) = &00BE
 EQUB 1                 \ Normals are scaled by    = 2^1 = 2

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010001        \ Laser power              = 2
\                       \ Missiles                 = 1

                        \ --- And replaced by: -------------------------------->

 EQUB %00101001         \ Laser power              = 5
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
\       Name: SHIP_OPHIDIAN
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Ophidian
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Whole section added for Elite-A: ----------->

.SHIP_OPHIDIAN

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

                        \ --- End of added section ---------------------------->

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
 EQUB &56               \ Edges data offset (low)  = &0056
 EQUB &BE               \ Faces data offset (low)  = &00BE
 EQUB 85                \ Max. edge count          = (85 - 1) / 4 = 21
 EQUB 0                 \ Gun vertex               = 0
 EQUB 42                \ Explosion count          = 9, as (4 * n) + 6 = 42
 EQUB 66                \ Number of vertices       = 66 / 6 = 11
 EQUB 26                \ Number of edges          = 26

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 300               \ Bounty                   = 300

                        \ --- End of replacement ------------------------------>

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 250              \ Max. energy              = 250

                        \ --- And replaced by: -------------------------------->

 EQUB 125               \ Max. energy              = 125

                        \ --- End of replacement ------------------------------>

 EQUB 20                \ Max. speed               = 20
 EQUB &00               \ Edges data offset (high) = &0056
 EQUB &00               \ Faces data offset (high) = &00BE
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00011011        \ Laser power              = 3
\                       \ Missiles                 = 3

                        \ --- And replaced by: -------------------------------->

 EQUB %00101100         \ Laser power              = 5
                        \ Missiles                 = 4

                        \ --- End of replacement ------------------------------>

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,  224,     0,      1,    2,     3,         31    \ Vertex 0

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ VERTEX    0,   48,   48,     0,      1,    4,     5,         31   \ Vertex 1

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,   48,   48,     0,      1,    4,     5,         30    \ Vertex 1

                        \ --- End of replacement ------------------------------>

 VERTEX   96,    0,  -16,    15,     15,   15,    15,         31    \ Vertex 2
 VERTEX  -96,    0,  -16,    15,     15,   15,    15,         31    \ Vertex 3

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ VERTEX    0,   48,  -32,     4,      5,    8,     9,         31   \ Vertex 4

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,   48,  -32,     4,      5,    8,     9,         30    \ Vertex 4

                        \ --- End of replacement ------------------------------>

 VERTEX    0,   24, -112,     9,      8,   12,    12,         31    \ Vertex 5
 VERTEX  -48,    0, -112,     8,     11,   12,    12,         31    \ Vertex 6
 VERTEX   48,    0, -112,     9,     10,   12,    12,         31    \ Vertex 7

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ VERTEX    0,  -48,   48,     2,      3,    6,     7,         31   \ Vertex 8
\ VERTEX    0,  -48,  -32,     6,      7,   10,    11,         31   \ Vertex 9
\ VERTEX    0,  -24, -112,    10,     11,   12,    12,         31   \ Vertex 10

                        \ --- And replaced by: -------------------------------->

 VERTEX    0,  -48,   48,     2,      3,    6,     7,         30    \ Vertex 8
 VERTEX    0,  -48,  -32,     6,      7,   10,    11,         30    \ Vertex 9
 VERTEX    0,  -24, -112,    10,     11,   12,    12,         30    \ Vertex 10

                        \ --- End of replacement ------------------------------>

\EDGE vertex1, vertex2, face1, face2, visibility

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       0,       8,     2,     3,         31   \ Edge 0

                        \ --- And replaced by: -------------------------------->

 EDGE       0,       8,     2,     3,         30    \ Edge 0

                        \ --- End of replacement ------------------------------>

 EDGE       0,       3,     0,     2,         31    \ Edge 1
 EDGE       0,       2,     1,     3,         31    \ Edge 2

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       0,       1,     0,     1,         31   \ Edge 3
\ EDGE       2,       4,     9,     5,         31   \ Edge 4
\ EDGE       1,       2,     1,     5,         31   \ Edge 5
\ EDGE       2,       8,     7,     3,         31   \ Edge 6
\ EDGE       1,       3,     0,     4,         31   \ Edge 7
\ EDGE       3,       8,     2,     6,         31   \ Edge 8
\ EDGE       2,       9,     7,    10,         31   \ Edge 9
\ EDGE       3,       4,     4,     8,         31   \ Edge 10
\ EDGE       3,       9,     6,    11,         31   \ Edge 11
\ EDGE       3,       5,     8,     8,          7   \ Edge 12
\ EDGE       3,      10,    11,    11,          7   \ Edge 13
\ EDGE       2,       5,     9,     9,          7   \ Edge 14
\ EDGE       2,      10,    10,    10,          7   \ Edge 15

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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EDGE       7,      10,    12,    10,         31   \ Edge 20
\ EDGE       6,      10,    11,    12,         31   \ Edge 21
\ EDGE       4,       5,     8,     9,         31   \ Edge 22
\ EDGE       9,      10,    10,    11,         31   \ Edge 23
\ EDGE       1,       4,     4,     5,         31   \ Edge 24
\ EDGE       8,       9,     6,     7,         31   \ Edge 25
\
\\FACE normal_x, normal_y, normal_z, visibility
\ FACE      -27,       40,       11,        31   \ Face 0
\ FACE       27,       40,       11,        31   \ Face 1
\ FACE      -27,      -40,       11,        31   \ Face 2
\ FACE       27,      -40,       11,        31   \ Face 3
\ FACE      -19,       38,        0,        31   \ Face 4
\ FACE       19,       38,        0,        31   \ Face 5
\ FACE      -19,      -38,        0,        31   \ Face 6
\ FACE       19,      -38,        0,        31   \ Face 7
\ FACE      -25,       37,      -11,        31   \ Face 8
\ FACE       25,       37,      -11,        31   \ Face 9
\ FACE       25,      -37,      -11,        31   \ Face 10
\ FACE      -25,      -37,      -11,        31   \ Face 11
\ FACE        0,        0,     -112,        31   \ Face 12

                        \ --- And replaced by: -------------------------------->

 EDGE       7,      10,    12,    10,         29    \ Edge 20
 EDGE       6,      10,    11,    12,         29    \ Edge 21
 EDGE       4,       5,     8,     9,         29    \ Edge 22
 EDGE       9,      10,    10,    11,         29    \ Edge 23
 EDGE       1,       4,     4,     5,         29    \ Edge 24
 EDGE       8,       9,     6,     7,         29    \ Edge 25

\FACE normal_x, normal_y, normal_z, visibility
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

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 250               \ Bounty                   = 250

                        \ --- End of replacement ------------------------------>

 EQUB 52                \ Number of faces          = 52 / 4 = 13
 EQUB 40                \ Visibility distance      = 40

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 250              \ Max. energy              = 250

                        \ --- And replaced by: -------------------------------->

 EQUB 164               \ Max. energy              = 164

                        \ --- End of replacement ------------------------------>

 EQUB 24                \ Max. speed               = 24
 EQUB &00               \ Edges data offset (high) = &0062
 EQUB &00               \ Faces data offset (high) = &00C2
 EQUB 0                 \ Normals are scaled by    = 2^0 = 1

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00011100        \ Laser power              = 3
\                       \ Missiles                 = 4

                        \ --- And replaced by: -------------------------------->

 EQUB %00101010         \ Laser power              = 5
                        \ Missiles                 = 2

                        \ --- End of replacement ------------------------------>

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
\       Name: SHIP_BUSHMASTER
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a Bushmaster
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Whole section added for Elite-A: ----------->

.SHIP_BUSHMASTER

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 4250              \ Targetable area          = 65.19 * 65.19
 EQUB &5C               \ Edges data offset (low)  = &005C
 EQUB &A8               \ Faces data offset (low)  = &00A8
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
 EQUB &00               \ Edges data offset (high) = &005C
 EQUB &00               \ Faces data offset (high) = &00A8
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00100001         \ Laser power              = 4
                        \ Missiles                 = 1

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
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

\EDGE vertex1, vertex2, face1, face2, visibility
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

\FACE normal_x, normal_y, normal_z, visibility
 FACE      -23,       88,       29,         31    \ Face 0
 FACE       23,       88,       29,         31    \ Face 1
 FACE      -14,      -93,       18,         31    \ Face 2
 FACE       14,      -93,       18,         31    \ Face 3
 FACE      -31,       89,      -13,         31    \ Face 4
 FACE       31,       89,      -13,         31    \ Face 5
 FACE      -42,      -85,       -7,         31    \ Face 6
 FACE       42,      -85,       -7,         31    \ Face 7
 FACE        0,        0,      -96,         31    \ Face 8

                        \ --- End of added section ---------------------------->

\ ******************************************************************************
\
\       Name: SHIP_IGUANA
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for an Iguana
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

                        \ --- Mod: Whole section added for Elite-A: ----------->

.SHIP_IGUANA

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

                        \ --- End of added section ---------------------------->

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
 EQUW 150               \ Bounty                   = 150
 EQUB 20                \ Number of faces          = 20 / 4 = 5
 EQUB 25                \ Visibility distance      = 25

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 90               \ Max. energy              = 90

                        \ --- And replaced by: -------------------------------->

 EQUB 80                \ Max. energy              = 80

                        \ --- End of replacement ------------------------------>

 EQUB 30                \ Max. speed               = 30
 EQUB &00               \ Edges data offset (high) = &00AA
 EQUB &01               \ Faces data offset (high) = &001A
 EQUB 2                 \ Normals are scaled by    = 2^2 = 4

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB %00010010        \ Laser power              = 2
\                       \ Missiles                 = 2

                        \ --- And replaced by: -------------------------------->

 EQUB %00100010         \ Laser power              = 4
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
 EQUB &2C               \ Edges data offset (low)  = &002C
 EQUB &3C               \ Faces data offset (low)  = &003C
 EQUB 17                \ Max. edge count          = (17 - 1) / 4 = 4
 EQUB 0                 \ Gun vertex               = 0
 EQUB 10                \ Explosion count          = 1, as (4 * n) + 6 = 10
 EQUB 24                \ Number of vertices       = 24 / 6 = 4
 EQUB 4                 \ Number of edges          = 4

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUW 0                \ Bounty                   = 0

                        \ --- And replaced by: -------------------------------->

 EQUW 1                 \ Bounty                   = 1

                        \ --- End of replacement ------------------------------>

 EQUB 4                 \ Number of faces          = 4 / 4 = 1
 EQUB 5                 \ Visibility distance      = 5

                        \ --- Mod: Original Acornsoft code removed: ----------->

\ EQUB 16               \ Max. energy              = 16

                        \ --- And replaced by: -------------------------------->

 EQUB 8                 \ Max. energy              = 8

                        \ --- End of replacement ------------------------------>

 EQUB 16                \ Max. speed               = 16
 EQUB &00               \ Edges data offset (high) = &002C
 EQUB &00               \ Faces data offset (high) = &003C
 EQUB 3                 \ Normals are scaled by    = 2^3 = 8
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

\VERTEX    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX  -15,  -22,   -9,    15,     15,   15,    15,         31    \ Vertex 0
 VERTEX  -15,   38,   -9,    15,     15,   15,    15,         31    \ Vertex 1
 VERTEX   19,   32,   11,    15,     15,   15,    15,         20    \ Vertex 2
 VERTEX   10,  -46,    6,    15,     15,   15,    15,         20    \ Vertex 3

\EDGE vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,    15,    15,         31    \ Edge 0
 EDGE       1,       2,    15,    15,         16    \ Edge 1
 EDGE       2,       3,    15,    15,         20    \ Edge 2
 EDGE       3,       0,    15,    15,         16    \ Edge 3

\FACE normal_x, normal_y, normal_z, visibility
 FACE        0,        0,        0,          0    \ Face 0

 EQUB 6                 \ This byte appears to be unused

\ ******************************************************************************
\
\ Save output/S.F.bin
\
\ ******************************************************************************

PRINT "S.S.F ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/S.F.bin", CODE%, CODE% + &0A00
