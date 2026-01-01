# Fully documented source code for Elite-A on the BBC Micro

<details>
<summary>Links to my other software archaeology repositories</summary>
<hr>

**Elite:** [BBC Micro cassette](https://github.com/markmoxon/elite-source-code-bbc-micro-cassette) | [BBC Micro disc](https://github.com/markmoxon/elite-source-code-bbc-micro-disc) | [Acorn Electron](https://github.com/markmoxon/elite-source-code-acorn-electron) | [6502 Second Processor](https://github.com/markmoxon/elite-source-code-6502-second-processor) | [Commodore 64](https://github.com/markmoxon/elite-source-code-commodore-64) | [Apple II](https://github.com/markmoxon/elite-source-code-apple-ii) | [BBC Master](https://github.com/markmoxon/elite-source-code-bbc-master) | [NES](https://github.com/markmoxon/elite-source-code-nes) | Elite-A | [Teletext Elite](https://github.com/markmoxon/teletext-elite) | [Elite Universe Editor](https://github.com/markmoxon/elite-universe-editor) | [Flicker-free Commodore 64 Elite](https://github.com/markmoxon/c64-elite-flicker-free) | [Elite over Econet](https://github.com/markmoxon/elite-over-econet) | [!EliteNet](https://github.com/markmoxon/elite-over-econet-acorn-archimedes)

**Elite Compendium:** [BBC Master](https://github.com/markmoxon/elite-compendium-bbc-master) | [BBC Micro](https://github.com/markmoxon/elite-compendium-bbc-micro) | [BBC Micro B+](https://github.com/markmoxon/elite-compendium-bbc-micro-b-plus) | [Acorn Electron](https://github.com/markmoxon/elite-compendium-acorn-electron)

**Other classics:** [Aviator (BBC Micro)](https://github.com/markmoxon/aviator-source-code-bbc-micro) | [Revs (BBC Micro)](https://github.com/markmoxon/revs-source-code-bbc-micro) | [The Sentinel (BBC Micro)](https://github.com/markmoxon/the-sentinel-source-code-bbc-micro) | [Lander (Acorn Archimedes)](https://github.com/markmoxon/lander-source-code-acorn-archimedes)

See [my profile](https://github.com/markmoxon) for more repositories to explore.
<hr>
</details>

![Iguana ship details in the Elite-A encyclopedia](https://elite.bbcelite.com/images/github/encyclopedia-iguana.png)

This repository contains the original source code for Angus Duggan's Elite-A on the BBC Micro, with every single line documented and (for the most part) explained. It is literally the original source code, just heavily commented.

It is a companion to the [elite.bbcelite.com website](https://elite.bbcelite.com).

See the [introduction](#introduction) for more information, or jump straight into the [documented source code](1-source-files/main-sources).

## Contents

* [Introduction](#introduction)

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Browsing the source in an IDE](#browsing-the-source-in-an-ide)

* [Folder structure](#folder-structure)

* [Flicker-free Elite-A](#flicker-free-elite-a)

* [Building Elite-A from the source](#building-elite-a-from-the-source)

  * [Requirements](#requirements)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Build options](#build-options)
  * [Verifying the output](#verifying-the-output)
  * [Log files](#log-files)
  * [Auto-deploying to the b2 emulator](#auto-deploying-to-the-b2-emulator)

* [Building different variants of Elite-A](#building-different-variants-of-elite-a)

  * [Building the released version](#building-the-released-version)
  * [Building the source disc variant](#building-the-source-disc-variant)
  * [Building the bug fix variant](#building-the-bug-fix-variant)
  * [Differences between the variants](#differences-between-the-variants)

* [Notes on the original source files](#notes-on-the-original-source-files)

  * [Converting the original build process to BeebAsm](#converting-the-original-build-process-to-beebasm)

## Introduction

This repository contains the original source code for Angus Duggan's Elite-A on the BBC Micro.

You can build the fully functioning game from this source. [Three variants](#building-different-variants-of-elite-a) are currently supported: the officially released version from Angus's site, the variant produced by the original source discs (which was never released), and a variant that fixes various bugs and which works on the BBC Master (which the original doesn't).

This repository is a companion to the [elite.bbcelite.com website](https://elite.bbcelite.com), which contains all the code from this repository, but laid out in a much more human-friendly fashion. The links at the top of this page will take you to repositories for the other versions of Elite that are covered by this project.

Elite-A is legendary amongst BBC Elite fans, and remains a deeply impressive project that has achieved almost mythical status in the Acorn retro scene (and deservedly so). Ian Bell, co-author of the original Elite, has this to say on his website:

> Also available here is Angus Duggan's Elite-A, a comprehensive enhancement of BBC Elite. He created this by disassembling the object code and then reprogramming the resultant source. A significant achievement for which respect is due.

It's worth noting that Angus coded Elite-A back in the late 1980s, using a BBC Micro fitted with his own handwritten 6502 assembler ROM, which he used to disassemble the original, protected game binaries, and reassemble the enhanced version. He used Acornsoft's VIEW word processor as his IDE, and built the whole thing without the benefit of modern tooling. A significant achievement, indeed.

I am very grateful to Angus for giving me permission to analyse his work on Elite-A, and for providing me with the original source files.

See [Angus's Elite-A site](http://knackered.org/angus/beeb/elite.html) for more information on playing Elite-A.

My hope is that this repository and the [accompanying website](https://elite.bbcelite.com) will be useful for those who want to learn more about Elite and what makes it tick. It is provided on an educational and non-profit basis, with the aim of helping people appreciate one of the most iconic games of the 8-bit era.

## Acknowledgements

Elite-A was written by Angus Duggan, and is an extended version of the BBC Micro disc version of Elite; the extra code is copyright Angus Duggan. The original Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1984.

The code on this site is identical to Angus Duggan's source discs (it's just been reformatted, and the label names have been changed to be consistent with the sources for the original BBC Micro disc version on which it is based).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

Huge thanks are due to Angus Duggan for giving me permission to document his work in extending Elite; to the original authors of Elite for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://elite.bbcelite.com/about_site/about_this_project.html).

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original source code for Elite, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Browsing the source in an IDE

If you want to browse the source in an IDE, you might find the following useful.

* The most interesting files are in the [main-sources](1-source-files/main-sources) folder:

  * The main game's source code is in the [elite-source-flight.asm](1-source-files/main-sources/elite-source-flight.asm), [elite-source-docked.asm](1-source-files/main-sources/elite-source-docked.asm) and [elite-source-encyclopedia.asm](1-source-files/main-sources/elite-source-encyclopedia.asm) files (for when we're in-flight, docked or viewing the encyclopedia) - this is the motherlode and probably contains all the stuff you're interested in.

  * The 6502 Second Processor version's source code is in the [elite-6502sp-parasite.asm](1-source-files/main-sources/elite-6502sp-parasite.asm) file (for the parasite, i.e. the Second Processor) and [elite-6502sp-io-processor.asm](1-source-files/main-sources/elite-6502sp-io-processor.asm) (for the I/O processor, i.e. the BBC Micro).

  * The game's loader is in the [elite-loader.asm](1-source-files/main-sources/elite-loader.asm) file - this is mainly concerned with setup and checking for Tube and BBC Master hardware.

* The source files for Elite-A are unique amongst the annotated versions in this project, in that they contain inline diffs. Angus created Elite-A by taking the original disc version of Elite and modifying the code to include all his new features. The annotated source files in this repository contain both the original disc code and all of Angus's modifications, so you can look through the source to see exactly what Angus changed in order to create Elite-A. Any code that he removed from the disc version is commented out in the source files, so when they are assembled they produce the Elite-A binaries, while still containing details of Angus's modifications. You can find all the diffs by searching the sources for `Mod:`. (Note that this feature does not apply to the two 6502 Second Processor version source files, which just contain the Elite-A code.)

* It's probably worth skimming through the [notes on terminology and notations](https://elite.bbcelite.com/terminology/) on the accompanying website, as this explains a number of terms used in the commentary, without which it might be a bit tricky to follow at times (in particular, you should understand the terminology I use for multi-byte numbers).

* The accompanying website contains [a number of "deep dive" articles](https://elite.bbcelite.com/deep_dives/), each of which goes into an aspect of the game in detail. Routines that are explained further in these articles are tagged with the label `Deep dive:` and the relevant article name.

* There are loads of routines and variables in Elite - literally hundreds. You can find them in the source files by searching for the following: `Type: Subroutine`, `Type: Variable`, `Type: Workspace` and `Type: Macro`.

* If you know the name of a routine, you can find it by searching for `Name: <name>`, as in `Name: SCAN` (for the 3D scanner routine) or `Name: LL9` (for the ship-drawing routine).

* The entry point for the [main game code](1-source-files/main-sources/elite-source-docked.asm) is routine `TT170`, which you can find by searching for `Name: TT170`. If you want to follow the program flow all the way from the title screen around the main game loop, then you can find a number of [deep dives on program flow](https://elite.bbcelite.com/deep_dives/) on the accompanying website.

* The source code is designed to be read at an 80-column width and with a monospaced font, just like in the good old days.

I hope you enjoy exploring the inner workings of Elite-A as much as I have.

## Folder structure

There are five main folders in this repository, which reflect the order of the build process.

* [1-source-files](1-source-files) contains all the different source files, such as the main assembler source files, image binaries, fonts, boot files and so on.

* [2-build-files](2-build-files) contains build-related scripts, such as the checksum, encryption and crc32 verification scripts.

* [3-assembled-output](3-assembled-output) contains the output from the assembly process, when the source files are assembled and the results processed by the build files.

* [4-reference-binaries](4-reference-binaries) contains the correct binaries for each variant, so we can verify that our assembled output matches the reference.

* [5-compiled-game-discs](5-compiled-game-discs) contains the final output of the build process: an SSD disc image that contains the compiled game and which can be run on real hardware or in an emulator.

## Flicker-free Elite-A

This repository also includes a flicker-free version, which incorporates the backported flicker-free ship-drawing routines from the BBC Master. The flicker-free code is in a separate branch called `flicker-free`, and apart from the code differences for reducing flicker, this branch is identical to the main branch and the same build process applies.

The annotated source files in the `flicker-free` branch contain both the original Elite-A code and all of the modifications for flicker-free Elite, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the flicker-free binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on flicker-free Elite, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/flicker-free_elite.html).

## Building Elite-A from the source

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

### Requirements

You will need the following to build Elite-A from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.

* Python. The build process has only been tested on 3.x, but 2.7 might work.

* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

Let's look at how to build Elite-A from the source.

### Windows

For Windows users, there is a batch file called `make.bat` which you can use to build the game. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.bat`).

All being well, entering the following into a command window:

```
make.bat
```

will produce a file called `elite-a-released.ssd` in the `5-compiled-game-discs` folder that contains the released version of Elite-A, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, entering the following into a terminal window:

```
make
```

will produce a file called `elite-a-released.ssd` in the `5-compiled-game-discs` folder that contains the released version of Elite-A, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Build options

By default the build process will create a typical Elite game disc with a standard commander and verified binaries. There are various arguments you can pass to the build to change how it works. They are:

* `variant=<name>` - Build the specified variant:

  * `variant=released` (default)
  * `variant=source-disc`
  * `variant=bug-fix`

* `commander=max` - Start with a maxed-out commander (specifically, this is the test commander file from the original source, which is almost but not quite maxed-out)

* `verify=no` - Disable crc32 verification of the game binaries

So, for example:

`make variant=bug-fix commander=max verify=no`

will build the bug-fix variant with a maxed-out commander and no crc32 verification.

See below for more on the verification process.

### Verifying the output

The default build process prints out checksums of all the generated files, along with the checksums of the files from the original sources. You can disable verification by passing `verify=no` to the build.

The Python script `crc32.py` in the `2-build-files` folder does the actual verification, and shows the checksums and file sizes of both sets of files, alongside each other, and with a Match column that flags any discrepancies.

The binaries in the `4-reference-binaries` folder were taken straight from Angus Duggan's original source discs, while those in the `3-assembled-output` folder are produced by the build process. For example, if you don't make any changes to the code and build the project with `make`, then this is the output of the verification process:

```
Results for variant: released
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
26ae1732  19997  26ae1732  19997   Yes   1.D.bin
b1447e60  16778  b1447e60  16778   Yes   1.E.bin
14ee8b20  17432  14ee8b20  17432   Yes   1.F.bin
3d638042   1956  3d638042   1956   Yes   2.H.bin
1f1783e7  43141  1f1783e7  43141   Yes   2.T.bin
171ccea5   5363  171ccea5   5363   Yes   ELITE.bin
4f2febe4    256  4f2febe4    256   Yes   MISSILE.bin
678c1c7f   2560  678c1c7f   2560   Yes   S.A.bin
cae56eda   2560  cae56eda   2560   Yes   S.B.bin
7b56fbb5   2560  7b56fbb5   2560   Yes   S.C.bin
55e86dde   2560  55e86dde   2560   Yes   S.D.bin
be2665dd   2560  be2665dd   2560   Yes   S.E.bin
c0917c15   2560  c0917c15   2560   Yes   S.F.bin
80f4145e   2560  80f4145e   2560   Yes   S.G.bin
0d9fe4e8   2560  0d9fe4e8   2560   Yes   S.H.bin
31ea0782   2560  31ea0782   2560   Yes   S.I.bin
f444274e   2560  f444274e   2560   Yes   S.J.bin
b9672969   2560  b9672969   2560   Yes   S.K.bin
05f74f36   2560  05f74f36   2560   Yes   S.L.bin
39856010   2560  39856010   2560   Yes   S.M.bin
132980ad   2560  132980ad   2560   Yes   S.N.bin
26525e5c   2560  26525e5c   2560   Yes   S.O.bin
76097753   2560  76097753   2560   Yes   S.P.bin
6bd215b4   2560  6bd215b4   2560   Yes   S.Q.bin
bcd49589   2560  bcd49589   2560   Yes   S.R.bin
8b44b8b6   2560  8b44b8b6   2560   Yes   S.S.bin
155e6a6b   2560  155e6a6b   2560   Yes   S.T.bin
fab17499   2560  fab17499   2560   Yes   S.U.bin
8504604f   2560  8504604f   2560   Yes   S.V.bin
40f96e61   2560  40f96e61   2560   Yes   S.W.bin
b7b3c692   1024  b7b3c692   1024   Yes   WORDS.bin
```

All the compiled binaries match the originals, so we know we are producing the same final game as the released version.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `3-assembled-output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).

### Auto-deploying to the b2 emulator

For users of the excellent [b2 emulator](https://github.com/tom-seddon/b2), you can include the build parameter `b2` to automatically load and boot the assembled disc image in b2. The b2 emulator must be running for this to work.

For example, to build, verify and load the game into b2, you can do this on Windows:

```
make.bat all b2
```

or this on Mac/Linux:

```
make all b2
```

If you omit the `all` target then b2 will start up with the results of the last successful build.

Note that you should manually choose the correct platform in b2 (I intentionally haven't automated this part to make it easier to test across multiple platforms).

## Building different variants of Elite-A

This repository contains the source code for three different variants of Elite-A:

* The released version from Angus Duggan's site

* The variant produced by the source disc (which was never released)

* A variant that fixes two bugs in the original (splinters and Adder stats)

By default the build process builds the released version, but you can build a specified variant using the `variant=` build parameter.

### Building the released version

You can add `variant=released` to produce the `elite-a-released.ssd` file that contains the released version, though that's the default value so it isn't necessary. In other words, you can build it like this:

```
make.bat variant=released
```

or this on a Mac or Linux:

```
make variant=released
```

This will produce a file called `elite-a-released.ssd` in the `5-compiled-game-discs` folder that contains the released version.

The verification checksums for this version are as follows:

```
Results for variant: released
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
26ae1732  19997  26ae1732  19997   Yes   1.D.bin
b1447e60  16778  b1447e60  16778   Yes   1.E.bin
14ee8b20  17432  14ee8b20  17432   Yes   1.F.bin
3d638042   1956  3d638042   1956   Yes   2.H.bin
1f1783e7  43141  1f1783e7  43141   Yes   2.T.bin
171ccea5   5363  171ccea5   5363   Yes   ELITE.bin
4f2febe4    256  4f2febe4    256   Yes   MISSILE.bin
678c1c7f   2560  678c1c7f   2560   Yes   S.A.bin
cae56eda   2560  cae56eda   2560   Yes   S.B.bin
7b56fbb5   2560  7b56fbb5   2560   Yes   S.C.bin
55e86dde   2560  55e86dde   2560   Yes   S.D.bin
be2665dd   2560  be2665dd   2560   Yes   S.E.bin
c0917c15   2560  c0917c15   2560   Yes   S.F.bin
80f4145e   2560  80f4145e   2560   Yes   S.G.bin
0d9fe4e8   2560  0d9fe4e8   2560   Yes   S.H.bin
31ea0782   2560  31ea0782   2560   Yes   S.I.bin
f444274e   2560  f444274e   2560   Yes   S.J.bin
b9672969   2560  b9672969   2560   Yes   S.K.bin
05f74f36   2560  05f74f36   2560   Yes   S.L.bin
39856010   2560  39856010   2560   Yes   S.M.bin
132980ad   2560  132980ad   2560   Yes   S.N.bin
26525e5c   2560  26525e5c   2560   Yes   S.O.bin
76097753   2560  76097753   2560   Yes   S.P.bin
6bd215b4   2560  6bd215b4   2560   Yes   S.Q.bin
bcd49589   2560  bcd49589   2560   Yes   S.R.bin
8b44b8b6   2560  8b44b8b6   2560   Yes   S.S.bin
155e6a6b   2560  155e6a6b   2560   Yes   S.T.bin
fab17499   2560  fab17499   2560   Yes   S.U.bin
8504604f   2560  8504604f   2560   Yes   S.V.bin
40f96e61   2560  40f96e61   2560   Yes   S.W.bin
b7b3c692   1024  b7b3c692   1024   Yes   WORDS.bin
```

### Building the source disc variant

You can build the source disc variant by appending `variant=source-disc` to the `make` command, like this on Windows:

```
make.bat variant=source-disc
```

or this on a Mac or Linux:

```
make variant=source-disc
```

This will produce a file called `elite-a-from-source-disc.ssd` in the `5-compiled-game-discs` folder that contains the source disc variant.

The verification checksums for this version are as follows:

```
Results for variant: source-disc
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
d1ca0224  19997  d1ca0224  19997   Yes   1.D.bin
b1447e60  16778  b1447e60  16778   Yes   1.E.bin
14ee8b20  17432  14ee8b20  17432   Yes   1.F.bin
3d638042   1956  3d638042   1956   Yes   2.H.bin
81d6d436  43141  81d6d436  43141   Yes   2.T.bin
171ccea5   5363  171ccea5   5363   Yes   ELITE.bin
4f2febe4    256  4f2febe4    256   Yes   MISSILE.bin
678c1c7f   2560  678c1c7f   2560   Yes   S.A.bin
cae56eda   2560  cae56eda   2560   Yes   S.B.bin
7b56fbb5   2560  7b56fbb5   2560   Yes   S.C.bin
55e86dde   2560  55e86dde   2560   Yes   S.D.bin
be2665dd   2560  be2665dd   2560   Yes   S.E.bin
c0917c15   2560  c0917c15   2560   Yes   S.F.bin
80f4145e   2560  80f4145e   2560   Yes   S.G.bin
0d9fe4e8   2560  0d9fe4e8   2560   Yes   S.H.bin
31ea0782   2560  31ea0782   2560   Yes   S.I.bin
f444274e   2560  f444274e   2560   Yes   S.J.bin
b9672969   2560  b9672969   2560   Yes   S.K.bin
05f74f36   2560  05f74f36   2560   Yes   S.L.bin
39856010   2560  39856010   2560   Yes   S.M.bin
132980ad   2560  132980ad   2560   Yes   S.N.bin
26525e5c   2560  26525e5c   2560   Yes   S.O.bin
76097753   2560  76097753   2560   Yes   S.P.bin
6bd215b4   2560  6bd215b4   2560   Yes   S.Q.bin
bcd49589   2560  bcd49589   2560   Yes   S.R.bin
8b44b8b6   2560  8b44b8b6   2560   Yes   S.S.bin
155e6a6b   2560  155e6a6b   2560   Yes   S.T.bin
fab17499   2560  fab17499   2560   Yes   S.U.bin
8504604f   2560  8504604f   2560   Yes   S.V.bin
40f96e61   2560  40f96e61   2560   Yes   S.W.bin
b7b3c692   1024  b7b3c692   1024   Yes   WORDS.bin
```

### Building the bug fix variant

You can build the source disc variant by appending `variant=bug-fix` to the `make` command, like this on Windows:

```
make.bat variant=bug-fix
```

or this on a Mac or Linux:

```
make variant=bug-fix
```

This will produce a file called `elite-a-bug-fix.ssd` in the `5-compiled-game-discs` folder that contains the bug fix variant.

The verification checksums for this version are as follows:

```
Results for variant: bug-fix
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
e5ba3c27  19945  e5ba3c27  19945   Yes   1.D.bin
9dc55321  16797  9dc55321  16797   Yes   1.E.bin
14ee8b20  17432  14ee8b20  17432   Yes   1.F.bin
07b3750f   2008  07b3750f   2008   Yes   2.H.bin
d3ed6338  43147  d3ed6338  43147   Yes   2.T.bin
067375d2   5385  067375d2   5385   Yes   ELITE.bin
4f2febe4    256  4f2febe4    256   Yes   MISSILE.bin
678c1c7f   2560  678c1c7f   2560   Yes   S.A.bin
cae56eda   2560  cae56eda   2560   Yes   S.B.bin
7b56fbb5   2560  7b56fbb5   2560   Yes   S.C.bin
55e86dde   2560  55e86dde   2560   Yes   S.D.bin
a119f0d9   2560  a119f0d9   2560   Yes   S.E.bin
c0917c15   2560  c0917c15   2560   Yes   S.F.bin
d3224bc1   2560  d3224bc1   2560   Yes   S.G.bin
0d9fe4e8   2560  0d9fe4e8   2560   Yes   S.H.bin
31ea0782   2560  31ea0782   2560   Yes   S.I.bin
f444274e   2560  f444274e   2560   Yes   S.J.bin
ad98f535   2560  ad98f535   2560   Yes   S.K.bin
05f74f36   2560  05f74f36   2560   Yes   S.L.bin
39856010   2560  39856010   2560   Yes   S.M.bin
132980ad   2560  132980ad   2560   Yes   S.N.bin
a258d111   2560  a258d111   2560   Yes   S.O.bin
76097753   2560  76097753   2560   Yes   S.P.bin
6bd215b4   2560  6bd215b4   2560   Yes   S.Q.bin
2aefc58b   2560  2aefc58b   2560   Yes   S.R.bin
8b44b8b6   2560  8b44b8b6   2560   Yes   S.S.bin
155e6a6b   2560  155e6a6b   2560   Yes   S.T.bin
22336ce1   2560  22336ce1   2560   Yes   S.U.bin
8504604f   2560  8504604f   2560   Yes   S.V.bin
40f96e61   2560  40f96e61   2560   Yes   S.W.bin
b7b3c692   1024  b7b3c692   1024   Yes   WORDS.bin
```

### Differences between the variants

You can see the differences between the variants by searching the source code for `_RELEASED` (for features in the released version), `_BUG_FIX` (for features in the buf fix version) or `_SOURCE_DISC` (for features in the source disc variant).

The only difference in the source disc variant is that the latter has considerably lower ship prices.

The bug fix variant works on the BBC Master and BBC Master with 6502 Second Processor, which the original version of Elite-A doesn't. There is also a bug in the original version that prevents splinters from displaying properly, which makes mining all but impossible. The bug fix variant fixes that bug, and it also adds a quality-of-life improvement to the cargo capacities shown for flyable ships in the encyclopedia, so they reflect the in-game capacity when no equipment is fitted, rather than the "normal configuration" from the original version (which is a bit subjective). It also incorporates the lower ship prices from the source disc.

See the [accompanying website](https://elite.bbcelite.com/elite-a/releases.html) for a comprehensive list of differences between the variants.

## Notes on the original source files

### Converting the original build process to BeebAsm

See [the original source files](1-source-files/original-sources) for details about how Angus's original sources have been converted to assemble in BeebAsm, so Elite-A can be built on modern computers.

---

Right on, Commanders!

_Mark Moxon_