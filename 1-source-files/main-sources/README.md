# Annotated source code for the Elite-A

This folder contains the annotated source code for Elite-A.

* Main source files:

  * [elite-source-docked.asm](elite-source-docked.asm) contains the main source for the docked portion of the game

  * [elite-source-encyclopedia.asm](elite-source-encyclopedia.asm) contains the main source for the Encyclopedia Galactica

  * [elite-source-flight.asm](elite-source-flight.asm) contains the main source for the flight portion of the game

  * [elite-text-tokens.asm](elite-text-tokens.asm) contains the source for the game's text

  * [elite-missile.asm](elite-missile.asm) contains the source for the missile's ship blueprint

  * [elite-ships-a.asm](elite-ships-a.asm) through [elite-ships-w.asm](elite-ships-w.asm) generate the ship blueprint files S.A to S.W

  * [elite-6502sp-io-processor.asm](elite-6502sp-io-processor.asm) contains the main source for the I/O processor in the 6502 Second Processor version of the game

  * [elite-6502sp-parasite.asm](elite-6502sp-parasite.asm) contains the main source for the parasite in the 6502 Second Processor version of the game

* Other source files:

  * [elite-loader.asm](elite-loader.asm) contains the source for the loader

  * [elite-disc.asm](elite-disc.asm) builds the SSD disc image from the assembled binaries and other source files

  * [elite-readme.asm](elite-readme.asm) generates a README file for inclusion on the SSD disc image

* Files that are generated during the build process:

  * [elite-build-options.asm](elite-build-options.asm) stores the make options in BeebAsm format so they can be included in the assembly process

---

Right on, Commanders!

_Mark Moxon_