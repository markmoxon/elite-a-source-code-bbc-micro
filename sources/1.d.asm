INCLUDE "sources/elite-header.h.asm"

_RELEASED               = (_RELEASE = 1)
_PATCHED                = (_RELEASE = 2)

ORG &11E3

INCBIN "output/tcode.bin"

INCBIN "extracted/patched/workspaces/1.D.bin"

ORG &5600

INCBIN "extracted/patched/S.T.bin"

SAVE "output/1.D.bin", &11E3, &6000
