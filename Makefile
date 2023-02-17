BEEBASM?=beebasm
PYTHON?=python

# You can set the variant that gets built by adding 'variant=<rel>' to
# the make command, where <rel> is one of:
#
#   released
#   patched
#   bug-fix
#
# So, for example:
#
#   make encrypt verify variant=patched
#
# will build the patched version. If you omit the variant parameter,
# it will build the released version.

ifeq ($(variant), source-disc)
  variant-elite-a=2
  folder-elite-a=/source-disc
  suffix-elite-a=-flicker-free-from-source-disc
else ifeq ($(variant), bug-fix)
  variant-elite-a=3
  folder-elite-a=/bug-fix
  suffix-elite-a=-flicker-free-bug-fix
else
  variant-elite-a=1
  folder-elite-a=/released
  suffix-elite-a=-flicker-free-released
endif

.PHONY:build
build:
	echo _VERSION=6 > 1-source-files/main-sources/elite-build-options.asm
	echo _VARIANT=$(variant-elite-a) >> 1-source-files/main-sources/elite-build-options.asm
	echo _REMOVE_CHECKSUMS=TRUE >> 1-source-files/main-sources/elite-build-options.asm
	echo _MATCH_ORIGINAL_BINARIES=FALSE >> 1-source-files/main-sources/elite-build-options.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-text-tokens.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-missile.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-docked.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-flight.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-encyclopedia.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-6502sp-parasite.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-6502sp-io-processor.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-a.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-b.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-c.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-d.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-e.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-f.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-g.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-h.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-i.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-j.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-k.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-l.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-m.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-n.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-o.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-p.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-q.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-r.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-s.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-t.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-u.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-v.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-w.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -u -rel$(variant-elite-a)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-a$(suffix-elite-a).ssd -opt 3 -title "E L I T E"

.PHONY:encrypt
encrypt:
	echo _VERSION=6 > 1-source-files/main-sources/elite-build-options.asm
	echo _VARIANT=$(variant-elite-a) >> 1-source-files/main-sources/elite-build-options.asm
	echo _REMOVE_CHECKSUMS=FALSE >> 1-source-files/main-sources/elite-build-options.asm
	echo _MATCH_ORIGINAL_BINARIES=TRUE >> 1-source-files/main-sources/elite-build-options.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-text-tokens.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-missile.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-docked.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-flight.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-source-encyclopedia.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-6502sp-parasite.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-6502sp-io-processor.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-a.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-b.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-c.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-d.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-e.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-f.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-g.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-h.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-i.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-j.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-k.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-l.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-m.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-n.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-o.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-p.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-q.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-r.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-s.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-t.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-u.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-v.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-ships-w.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -rel$(variant-elite-a)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-a$(suffix-elite-a).ssd -opt 3 -title "E L I T E"

.PHONY:verify
verify:
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries$(folder-elite-a) 3-assembled-output

.PHONY:b2
b2:
	curl -G "http://localhost:48075/reset/b2"
	curl -H "Content-Type:application/binary" --upload-file "5-compiled-game-discs/elite-a$(suffix-elite-a).ssd" "http://localhost:48075/run/b2?name=elite-a$(suffix-elite-a).ssd"
