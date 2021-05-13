BEEBASM?=beebasm
PYTHON?=python

# You can set the release that gets built by adding 'release=<rel>' to
# the make command, where <rel> is one of:
#
#   released
#   patched
#
# So, for example:
#
#   make encrypt verify release=patched
#
# will build the patched version. If you omit the release parameter,
# it will build the released version.

ifeq ($(release), source-disc)
  rel-elite-a=2
  folder-elite-a=/source-disc
  suffix-elite-a=-from-source-disc
else
  rel-elite-a=1
  folder-elite-a=/released
  suffix-elite-a=-released
endif

.PHONY:build
build:
	echo _VERSION=6 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-elite-a) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/a.tcode.asm -v > output/compile.txt
	$(BEEBASM) -i sources/a.dcode.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/a.icode.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/1.d.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/a.qcode.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/a.qelite.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/a.elite.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-disc.asm -do elite-a$(suffix-elite-a).ssd -opt 3

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder-elite-a) output
