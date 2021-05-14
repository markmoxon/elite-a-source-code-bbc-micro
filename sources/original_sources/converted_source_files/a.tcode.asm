 \ a.tcode - ELITE III docked code

INCLUDE "converted_source_files/a.global.asm"

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

INCLUDE "converted_source_files/a.tcode_1.asm"

INCLUDE "converted_source_files/a.tcode_2.asm"

INCLUDE "converted_source_files/a.tcode_3.asm"

SAVE "output/tcode", CODE%, P%, LOAD%