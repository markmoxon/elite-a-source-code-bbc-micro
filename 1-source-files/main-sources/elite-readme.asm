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
\   * !BOOT.txt
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _RELEASED              = (_VARIANT = 1)
 _SOURCE_DISC           = (_VARIANT = 2)
 _BUG_FIX               = (_VARIANT = 3)

.readme

 EQUS "*DIR :0.$"
 EQUB 13
 EQUS "*ELITE"
 EQUB 13
 EQUS "*|"
 EQUB 13
 EQUS "*| -----------------------------------"
 EQUB 13
 EQUS "*| Angus Duggan's Elite-A"
 EQUB 13
 EQUS "*|"
 EQUB 13
 EQUS "*| Version: BBC Micro/Tube/BBC Master"
 EQUB 13

IF _RELEASED

 EQUS "*| Variant: From Angus Duggan's site"
 EQUB 13
 EQUS "*| Product: The official release"
 EQUB 13

ELIF _SOURCE_DISC

 EQUS "*| Variant: Angus Duggan's source disc"
 EQUB 13

ELIF _BUG_FIX

 EQUS "*| Variant: Bug fixes (mining bug)"
 EQUB 13

ENDIF

 EQUS "*|"
 EQUB 13
 EQUS "*| See www.bbcelite.com for details"
 EQUB 13
 EQUS "*| -----------------------------------"
 EQUB 13

 SAVE "3-assembled-output/!BOOT.txt", readme, P%

