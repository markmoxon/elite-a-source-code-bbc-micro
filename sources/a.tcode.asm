 \ a.tcode - ELITE III docked code

INCLUDE "sources/a.global.asm"

CODE% = &11E3
ORG CODE%
LOAD% = &11E3
EXEC% = &11E3


.dcode_in

 JMP dcode_2

.boot_in

 JMP boot_2

.wrch_in

 JMP wrchdst
 EQUW &114B

.brk_in

 JMP brk_go

INCLUDE "sources/a.tcode_1.asm"

INCLUDE "sources/a.tcode_2.asm"

INCLUDE "sources/a.tcode_3.asm"

SAVE "output/tcode.bin", CODE%, P%, LOAD%