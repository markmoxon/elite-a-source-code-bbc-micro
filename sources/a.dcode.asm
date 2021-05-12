 \ a.dcode - ELITE III in-flight code

INCLUDE "sources/a.global.asm"

CODE% = &11E3
ORG CODE%
LOAD% = &11E3
EXEC% = &11E3


.dcode_in

 JMP start

.boot_in

 JMP start

.wrch_in

 JMP wrchdst
 EQUW &114B

.brk_in

 JMP brkdst

INCLUDE "sources/a.dcode_1.asm"

INCLUDE "sources/a.dcode_2.asm"

INCLUDE "sources/a.dcode_3.asm"

SAVE "output/1.F.bin", CODE%, P%, LOAD%