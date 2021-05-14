\ This file replicates the following part of the original Elite-A build process:
\
\ *lo.:0.tcode
\ *lo.:0.S.T
\ *sa.:0.1.D 11e3 6000

ORG &11E3
INCBIN "output/tcode"

ORG &5600
INCBIN "original_source_files/S.T"

SAVE "output/1.D", &11E3, &6000
