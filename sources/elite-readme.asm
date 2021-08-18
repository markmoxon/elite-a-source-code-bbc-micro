\ ******************************************************************************
\
\ ELITE-A README AND BOOT FILE
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
\   * output/!BOOT.txt
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)
_BUG_FIX                = (_RELEASE = 3)

.readme

 EQUB 13
 EQUS "*| -----------------------------------"
 EQUB 13
 EQUS "*| Angus Duggan's Elite-A"
 EQUB 13
 EQUS "*| (flicker-free version)"
 EQUB 13
 EQUS "*|"
 EQUB 13
 EQUS "*| Version: BBC Micro/Tube/BBC Master"
 EQUB 13
IF _RELEASED
 EQUS "*| Release: From Angus Duggan's site"
 EQUB 13
 EQUS "*|          The original release"
 EQUB 13
ELIF _SOURCE_DISC
 EQUS "*| Release: Angus Duggan's source disc"
 EQUB 13
 EQUS "*|          Not officially released"
 EQUB 13
ELIF _BUG_FIX
 EQUS "*| Release: Bug fixes (mining bug)"
 EQUB 13
 EQUS "*|          Not officially released"
 EQUB 13
ENDIF
 EQUS "*|"
 EQUB 13
 EQUS "*| Contains the flicker-free ship"
 EQUB 13
 EQUS "*| drawing routines from the BBC"
 EQUB 13
 EQUS "*| Master version, backported by"
 EQUB 13
 EQUS "*| Mark Moxon"
 EQUB 13
 EQUS "*|"
 EQUB 13

 EQUS "*| See www.bbcelite.com for details"
 EQUB 13
 EQUS "*| -----------------------------------"
 EQUB 13
 EQUB 13
 EQUS "*DIR :0.$"
 EQUB 13
 EQUS "*ELITE"
 EQUB 13

SAVE "output/!BOOT.txt", readme, P%

