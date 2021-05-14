 \ a.dcode - ELITE III in-flight code

INCLUDE "converted_source_files/a.global.asm"

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

INCLUDE "converted_source_files/a.dcode_1.asm"

INCLUDE "converted_source_files/a.dcode_2.asm"

INCLUDE "converted_source_files/a.dcode_3.asm"

SAVE "output/1.F", CODE%, P%, LOAD%