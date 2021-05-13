INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

 \ a.icode - ELITE III encyclopedia

INCLUDE "sources/a.global.asm"

CODE% = &11E3
ORG CODE%
LOAD% = &11E3
EXEC% = &11E3


.dcode_in

 JMP dcode_2

.boot_in

 JMP dcode_2

.wrch_in

 JMP wrchdst
 EQUW &114B

.brk_in

 JMP brk_go

INCLUDE "sources/a.icode_1.asm"

INCLUDE "sources/a.icode_2.asm"

INCLUDE "sources/a.icode_3.asm"

SAVE "output/1.E.bin", CODE%, P%, LOAD%