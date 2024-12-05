\ ******************************************************************************
\
\ ELITE-A MISSILE SHIP BLUEPRINT SOURCE
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
\ This source file contains the missile ship blueprint for Elite-A.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * MISSILE.bin
\
\ This gets loaded as part of elite-loader.asm and gets moved to &7F00 during
\ the loading process.
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

 CODE% = &7F00          \ The address where the code will be run

 LOAD% = &2468          \ The address where the code will be loaded

 ORG CODE%

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
\       Name: SHIP_MISSILE
\       Type: Variable
\   Category: Drawing ships
\    Summary: Ship blueprint for a missile
\  Deep dive: Ship blueprints
\
\ ******************************************************************************

.SHIP_MISSILE

 EQUB 0                 \ Max. canisters on demise = 0
 EQUW 40 * 40           \ Targetable area          = 40 * 40

 EQUB LO(SHIP_MISSILE_EDGES - SHIP_MISSILE)        \ Edges data offset (low)
 EQUB LO(SHIP_MISSILE_FACES - SHIP_MISSILE)        \ Faces data offset (low)

 EQUB 81                \ Max. edge count          = (81 - 1) / 4 = 20
 EQUB 0                 \ Gun vertex               = 0
 EQUB 10                \ Explosion count          = 1, as (4 * n) + 6 = 10
 EQUB 102               \ Number of vertices       = 102 / 6 = 17
 EQUB 24                \ Number of edges          = 24
 EQUW 0                 \ Bounty                   = 0
 EQUB 36                \ Number of faces          = 36 / 4 = 9
 EQUB 14                \ Visibility distance      = 14
 EQUB 2                 \ Max. energy              = 2
 EQUB 44                \ Max. speed               = 44

 EQUB HI(SHIP_MISSILE_EDGES - SHIP_MISSILE)        \ Edges data offset (high)
 EQUB HI(SHIP_MISSILE_FACES - SHIP_MISSILE)        \ Faces data offset (high)

 EQUB 2                 \ Normals are scaled by    = 2^2 = 4
 EQUB %00000000         \ Laser power              = 0
                        \ Missiles                 = 0

.SHIP_MISSILE_VERTICES

      \    x,    y,    z, face1, face2, face3, face4, visibility
 VERTEX    0,    0,   68,     0,      1,    2,     3,         31    \ Vertex 0
 VERTEX    8,   -8,   36,     1,      2,    4,     5,         31    \ Vertex 1
 VERTEX    8,    8,   36,     2,      3,    4,     7,         31    \ Vertex 2
 VERTEX   -8,    8,   36,     0,      3,    6,     7,         31    \ Vertex 3
 VERTEX   -8,   -8,   36,     0,      1,    5,     6,         31    \ Vertex 4
 VERTEX    8,    8,  -44,     4,      7,    8,     8,         31    \ Vertex 5
 VERTEX    8,   -8,  -44,     4,      5,    8,     8,         31    \ Vertex 6
 VERTEX   -8,   -8,  -44,     5,      6,    8,     8,         31    \ Vertex 7
 VERTEX   -8,    8,  -44,     6,      7,    8,     8,         31    \ Vertex 8
 VERTEX   12,   12,  -44,     4,      7,    8,     8,          8    \ Vertex 9
 VERTEX   12,  -12,  -44,     4,      5,    8,     8,          8    \ Vertex 10
 VERTEX  -12,  -12,  -44,     5,      6,    8,     8,          8    \ Vertex 11
 VERTEX  -12,   12,  -44,     6,      7,    8,     8,          8    \ Vertex 12
 VERTEX   -8,    8,  -12,     6,      7,    7,     7,          8    \ Vertex 13
 VERTEX   -8,   -8,  -12,     5,      6,    6,     6,          8    \ Vertex 14
 VERTEX    8,    8,  -12,     4,      7,    7,     7,          8    \ Vertex 15
 VERTEX    8,   -8,  -12,     4,      5,    5,     5,          8    \ Vertex 16

.SHIP_MISSILE_EDGES

    \ vertex1, vertex2, face1, face2, visibility
 EDGE       0,       1,     1,     2,         31    \ Edge 0
 EDGE       0,       2,     2,     3,         31    \ Edge 1
 EDGE       0,       3,     0,     3,         31    \ Edge 2
 EDGE       0,       4,     0,     1,         31    \ Edge 3
 EDGE       1,       2,     4,     2,         31    \ Edge 4
 EDGE       1,       4,     1,     5,         31    \ Edge 5
 EDGE       3,       4,     0,     6,         31    \ Edge 6
 EDGE       2,       3,     3,     7,         31    \ Edge 7
 EDGE       2,       5,     4,     7,         31    \ Edge 8
 EDGE       1,       6,     4,     5,         31    \ Edge 9
 EDGE       4,       7,     5,     6,         31    \ Edge 10
 EDGE       3,       8,     6,     7,         31    \ Edge 11
 EDGE       7,       8,     6,     8,         31    \ Edge 12
 EDGE       5,       8,     7,     8,         31    \ Edge 13
 EDGE       5,       6,     4,     8,         31    \ Edge 14
 EDGE       6,       7,     5,     8,         31    \ Edge 15
 EDGE       6,      10,     5,     8,          8    \ Edge 16
 EDGE       5,       9,     7,     8,          8    \ Edge 17
 EDGE       8,      12,     7,     8,          8    \ Edge 18
 EDGE       7,      11,     5,     8,          8    \ Edge 19
 EDGE       9,      15,     4,     7,          8    \ Edge 20
 EDGE      10,      16,     4,     5,          8    \ Edge 21
 EDGE      12,      13,     6,     7,          8    \ Edge 22
 EDGE      11,      14,     5,     6,          8    \ Edge 23

.SHIP_MISSILE_FACES

    \ normal_x, normal_y, normal_z, visibility
 FACE      -64,        0,       16,         31      \ Face 0
 FACE        0,      -64,       16,         31      \ Face 1
 FACE       64,        0,       16,         31      \ Face 2
 FACE        0,       64,       16,         31      \ Face 3
 FACE       32,        0,        0,         31      \ Face 4
 FACE        0,      -32,        0,         31      \ Face 5
 FACE      -32,        0,        0,         31      \ Face 6

                        \ --- Mod: Code removed for Elite-A: ------------------>

\IF _STH_DISC OR _IB_DISC
\
\FACE        0,      160,      110,         31      \ Face 7
\FACE        0,       64,        4,          0      \ Face 8
\
\ELIF _SRAM_DISC
\
\FACE        0,       32,        0,         31      \ Face 7
\FACE        0,        0,     -176,         31      \ Face 8
\
\ENDIF

                        \ --- And replaced by: -------------------------------->

 FACE        0,       32,        0,         31      \ Face 7
 FACE        0,        0,     -176,         31      \ Face 8

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: VEC
\       Type: Variable
\   Category: Drawing the screen
\    Summary: The original value of the IRQ1 vector
\
\ ******************************************************************************

.VEC

                        \ --- Mod: Code removed for Elite-A: ------------------>

\IF _STH_DISC OR _IB_DISC
\
\EQUW &0004             \ VEC = &7FFE
\                       \
\                       \ This gets set to the value of the original IRQ1 vector
\                       \ by the loading process
\                       \
\                       \ This default value is random workspace noise left over
\                       \ from the BBC Micro assembly process; it gets
\                       \ overwritten
\
\ELIF _SRAM_DISC
\
\SKIP 2                 \ VEC = &7FFE
\                       \
\                       \ This gets set to the value of the original IRQ1 vector
\                       \ by the loading process
\
\ENDIF

                        \ --- And replaced by: -------------------------------->

 SKIP 2                 \ VEC = &7FFE
                        \
                        \ This gets set to the value of the original IRQ1 vector
                        \ by the loading process

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\ Save MISSILE.bin
\
\ ******************************************************************************

 PRINT "MISSILE"
 PRINT "Assembled at ", ~CODE%
 PRINT "Ends at ", ~P%
 PRINT "Code size is ", ~(P% - CODE%)
 PRINT "Execute at ", ~LOAD%
 PRINT "Reload at ", ~LOAD%

 PRINT "S.MISSILE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/MISSILE.bin", CODE%, P%, LOAD%
