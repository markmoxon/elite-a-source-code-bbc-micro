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
	$(BEEBASM) -i sources/elite-text-tokens.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-missile.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-source-docked.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-source-flight.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-source-encyclopedia.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-6502sp-parasite.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-6502sp-io-processor.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-a.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-b.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-c.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-d.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-e.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-f.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-g.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-h.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-i.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-j.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-k.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-l.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-m.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-n.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-o.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-p.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-q.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-r.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-s.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-t.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-u.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-v.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-w.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -u -rel$(rel-elite-a)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-a$(suffix-elite-a).ssd -opt 3

.PHONY:encrypt
encrypt:
	echo _VERSION=6 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-elite-a) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-text-tokens.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-missile.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-source-docked.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-source-flight.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-source-encyclopedia.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-6502sp-parasite.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-6502sp-io-processor.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-a.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-b.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-c.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-d.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-e.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-f.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-g.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-h.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-i.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-j.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-k.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-l.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-m.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-n.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-o.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-p.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-q.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-r.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-s.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-t.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-u.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-v.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-ships-w.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -rel$(rel-elite-a)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-a$(suffix-elite-a).ssd -opt 3

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder-elite-a) output
