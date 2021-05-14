# Source code for Elite-A on the BBC Micro

[BBC Micro (cassette)](https://github.com/markmoxon/elite-beebasm) | [BBC Micro (disc)](https://github.com/markmoxon/disc-elite-beebasm) | [6502 Second Processor](https://github.com/markmoxon/6502sp-elite-beebasm) | [BBC Master](https://github.com/markmoxon/master-elite-beebasm) | [Acorn Electron](https://github.com/markmoxon/electron-elite-beebasm) | **Elite-A**

This repository contains the original source code for Angus Duggan's Elite-A on the BBC Micro. I am planning to document it fully.

It is a companion to the [bbcelite.com website](https://www.bbcelite.com).

See the [introduction](#introduction) for more information.

## Contents

* [Introduction](#introduction)

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Building Elite-A from the source](#building-elite-a-from-the-source)

  * [Requirements](#requirements)
  * [Build targets](#build-targets)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Verifying the output](#verifying-the-output)
  * [Log files](#log-files)

* [Building different releases of Elite](#building-different-releases-of-elite)

  * [Building the released version](#building-the-sng45-release)
  * [Building the patched release](#building-the-source-disc-release)
  * [Differences between the releases](#differences-between-the-releases)

* [Notes on the original source files](#notes-on-the-original-source-files)

  * [Converting the original build process to BeebAsm](#converting-the-original-build-process-to-beebasm)
  * [Producing byte-accurate binaries](#producing-byte-accurate-binaries)

## Introduction

This repository contains the original source code for Angus Duggan's Elite-A on the BBC Micro.

Elite-A is legendary amongst BBC Elite fans, and remains a deeply impressive project that has achieved almost mythical status in the Acorn retro scene (and deservedly so). Ian Bell, co-author of the original Elite, has this to say on his website:

> Also available here is Angus Duggan's Elite-A, a comprehensive enhancement of BBC Elite. He created this by disassembling the object code and then reprograming the resultant source. A significant achievement for which respect is due.

I am very grateful to Angus for giving me permission to analyse his work on Elite-A, and for providing me with the original source files. Thank you Angus.

You can build the fully functioning game from this source. [Two releases](#building-different-releases-of-elite) are currently supported: the released version from Angus's site, and the version produced by the original source discs (which was never released).

See [Angus's Elite-A site](http://knackered.org/angus/beeb/elite.html) for more information on playing Elite-A.

My hope is that this repository and the [accompanying website](https://www.bbcelite.com) will be useful for those who want to learn more about Elite and what makes it tick. It is provided on an educational and non-profit basis, with the aim of helping people appreciate one of the most iconic games of the 8-bit era.

## Acknowledgements

Elite-A was written by Angus Duggan, and is an extended version of the BBC Micro disc version of Elite. The original Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1984.

The code on this site is identical to Angus Duggan's source discs (it's just been reformatted to be more readable).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

Huge thanks are due to Angus Duggan for giving me permission to document his work in extending Elite; to the original authors of Elite for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://www.bbcelite.com/about_site/about_this_project.html).

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Building Elite-A from the source

### Requirements

You will need the following to build Elite-A from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.

* Python. Both versions 2.7 and 3.x should work.

* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

Let's look at how to build Elite-A from the source.

### Build targets

There is only one build target available: `build`. Unlike the official versions of Elite, Elite-A is not encrypted, so there is no need for an `encrypt` target.

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

Note that the build ends with a warning that there is no `SAVE` command in the source file. You can ignore this, as the source file contains a `PUTFILE` command instead, but BeebAsm still reports this as a warning.

### Windows

For Windows users, there is a batch file called `make.bat` to which you can pass one of the build targets above. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.exe`).

All being well, doing the following:

```
make.bat build
```

will produce a file called `elite-a-released.ssd` containing the released version of Elite-A, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, doing the following:

```
make build
```

will produce a file called `elite-a-released.ssd` containing the released version of Elite-A, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Verifying the output

The build process also supports a verification target that prints out checksums of all the generated files, along with the checksums of the files extracted from the original sources.

You can run this verification step on its own, or you can run it once a build has finished. To run it on its own, use the following command on Windows:

```
make.bat verify
```

or on Mac/Linux:

```
make verify
```

To run a build and then verify the results, you can add two targets, like this on Windows:

```
make.bat build verify
```

or this on Mac/Linux:

```
make build verify
```

The Python script `crc32.py` does the actual verification, and shows the checksums and file sizes of both sets of files, alongside each other, and with a Match column that flags any discrepancies.

The binaries in the `extracted` folder were taken straight from Angus Duggan's original source discs, while those in the `output` folder are produced by the build process. For example, if you don't make any changes to the code and build the project with `make build verify`, then this is the output of the verification process:

```
[--extracted--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
26ae1732  19997  26ae1732  19997   Yes   1.D.bin
b1447e60  16778  b1447e60  16778   Yes   1.E.bin
14ee8b20  17432  14ee8b20  17432   Yes   1.F.bin
3d638042   1956  3d638042   1956   Yes   2.H.bin
1f1783e7  43141  1f1783e7  43141   Yes   2.T.bin
171ccea5   5363  171ccea5   5363   Yes   ELITE.bin
538d2d54   2560  -             -    -    S.T.bin
fc10cbad  17422  fc10cbad  17422   Yes   tcode.bin
```

All the compiled binaries match the extracts, so we know we are producing the same final game as the release version.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).

## Building different releases of Elite

This repository contains the source code for two different releases of Elite-A:

* The released version from Angus Duggan's site

* The version produced by the source disc (which was never released)

By default the build process builds the released version, but you can build the other release as follows.

### Building the source disc release

You can build the source disc release by appending `release=source-disc` to the `make` command, like this on Windows:

```
make.bat build verify release=source-disc
```

or this on a Mac or Linux:

```
make build verify release=source-disc
```

This will produce a file called `elite-a-from-source-disc.ssd` that contains the source disc release.

### Building the released version

You can add `release=released` to produce the `elite-a-released.ssd` file that contains the released version, though that's the default value so it isn't necessary.

### Differences between the releases

You can see the differences between the releases by searching the source code for `_RELEASED` (for features in the released version) or `_SOURCE_DISC` (for features in the source disc release). The only difference in the source disc release is that the latter has considerably lower ship prices.

## Notes on the original source files

### Converting the original build process to BeebAsm

See [the original source files](sources/original_sources) for details about how Angus's original sources have been converted to assemble in BeebAsm, so Elite-A can be built on modern computers.

### Producing byte-accurate binaries

The `extracted/<release>/workspaces` folders (where `<release>` is the release version) contain binary files that match the workspaces in the original game binaries (a workspace being a block of memory). Instead of initialising workspaces with null values like BeebAsm, the original BBC Micro source code creates the `1.D` file by loading `tcode` and `S.T` into memory and then saving them out in one file. This saving process will also save out the bytes in the gap between the two files, which can contain anything, so if we want to be able to produce byte-accurate binaries from the modern BeebAsm assembly process, we need to include this "workspace noise" when building the project, and that's what the binaries in the `extracted/<release>/workspaces` folder are for.

Here's an example of how these binaries are included:

```
IF _RELEASED
 INCBIN "extracted/released/workspaces/1.D.bin"
ELIF _SOURCE_DISC
 INCBIN "extracted/source-disc/workspaces/1.D.bin"
ENDIF
```

This is where we load the correct workspace noise for the gap between `tcode` and `S.T` when creating the `1.D` binary.

---

Right on, Commanders!

_Mark Moxon_