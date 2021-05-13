INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_SOURCE_DISC            = (_RELEASE = 2)

ORG &11E3

INCBIN "output/tcode.bin"

IF _RELEASED
 INCBIN "extracted/released/workspaces/1.D.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/workspaces/1.D.bin"
ENDIF

ORG &5600

IF _RELEASED
 INCBIN "extracted/released/S.T.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/S.T.bin"
ENDIF

SAVE "output/1.D.bin", &11E3, &6000
