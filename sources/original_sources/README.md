# Original source files for Elite-A

This folder contains a selection of Angus Duggan's [original source files for Elite-A](original_sources/sources). They are VIEW-compatible text files (Angus used Acornsoft's VIEW word processor as his IDE).

# Building Elite-A from the original sources

Elite-A was assembled from the source files using Angus's own handwritten assembler ROM. The file format for this assembler is pretty close to the BeebAsm format we need for building the sources on a modern computer, but they do need to be converted first.

The Python script in this folder converts these sources into a format that compiles in BeebAsm. These files form the basis of the main repository.

## Converting the original sources to BeebAsm

To convert the files into a format that BeebAsm is happy with, `cd` into the folder containing these instructions and do the following:

```
python convert-original-to-beebasm.py
```

This will convert the original source files in the `source_source_files` folder into a BeebAsm-compatible format and save them into the `converted_source_files` folder.

## Assembling the converted source files in BeebAsm

Once the files are converted, you can use the following commands to assemble the game files into the `output` folder. These steps mirror the original multi-step assembly process, as follows:

Assemble `a.tcode.asm` to produce `output/tcode`:

```
beebasm -i converted_source_files/a.tcode.asm
```

Assemble `a.dcode.asm` to produce `output/1.F`:

```
beebasm -i converted_source_files/a.dcode.asm
```

Assemble `a.icode.asm` to produce `output/1.E`:

```
beebasm -i converted_source_files/a.icode.asm
```

Assemble `a.qcode.asm` to produce `output/2.T`:

```
beebasm -i converted_source_files/a.qcode.asm
```

Assemble `a.qelite.asm` to produce `output/2.H`:

```
beebasm -i converted_source_files/a.qelite.asm
```

Assemble `a.elite.asm` to produce `output/ELITE`:

```
beebasm -i converted_source_files/a.elite.asm
```

Assemble `1.d.asm` to produce `output/1.D`:

```
beebasm -i 1.d.asm
```

This last step simply concatenates the `tcode` and `S.T` binaries into one file. The `S.T` binary is currently provided as an assembled binary, as the ship files are created by a BBC BASIC source file that hasn't been converted to BeebAsm yet.

Note that the `S.T` binary that is incorporated into `1.D` by the above step is not the same as the `S.T` ship file on the final game disc (though confusingly they have the same name). The `S.T` binary that's incorporated into `1.D` contains the ships to be shown in the hanger, while the `S.T` file on the final game disc is one of the in-flight ship files.

## Creating a working game disc

Now that we have finished the assembly process, we can create the final game disc as follows:

```
beebasm -i create-disc.asm -do elite-a-from-source-disc.ssd -opt 3
```

This creates a disc image called `elite-a-from-source-disc.ssd` in the current folder, which can be loaded into an emulator, or a BBC Micro using a Gotek. (Ignore the warning about the source file containing no SAVE command - it doesn't have to, as we're creating a disc image, not a binary.)

For reference, the above command does the following:

* Copy the `1.D`, `1.E`, `1.F`, `2.H`, `2.T` and `ELITE` files that we just assembled to the game disc

* Copy the `!BOOT`, `B.CONVERT` and `S.A` to `S.W` files from the main repository's `binaries` folder to the game disc

* Set the disc's boot option to `EXEC` using `*OPT 4 3`

This will create the exact Elite-A disc as produced by the original source disc.

## Verifying the results

To verify that the build has worked, run a crc32 check, as follows:

```
crc32 output/*
```

If everything has worked, you should see the following checksums:

```
c80972e6        output/1.D
b1447e60        output/1.E
14ee8b20        output/1.F
3d638042        output/2.H
81d6d436        output/2.T
171ccea5        output/ELITE
0e2d62be        output/tcode
```

If you get the above checksums after following the conversion process above, then congratulations - you have successfully assembled Elite-A from the original source discs.

## Comparing the results with the main repository

The version produced by the original source discs is not the same as the generally available version of Elite-A: the source discs produce a version of the game with different ship prices to the released version.

There are two ways to build this different version. One is the above process of converting and asssmbling the original source files, and the other is by building a specific release in the main repository, with this command:

```
make build verify release=source-disc
```

This builds the version from the original source discs, just like the above process to assemble the converted sources, but there are two small differences:

* The `release=source-disc` build incorporates "background noise" that the original BBC Micro assembly process includes in the binary, so we can produce byte-accurate binaries that exactly match the released game. Specifically, this noise occurs in the gap between the concatenated `tcode` and `S.T` binaries. When assembling the converted sources above, and specifically when assembling `1.d.asm`, that gap is filled with zeroes by BeebAsm, while the original version includes whatever content was already in memory at the time of the original assembly (typically a snippet of the original source code).

* The `release=source-disc` build fixes a bug in the original `a.tcode` source file, which contains the wrong price for the Anaconda (the `a.qcode` source file, meanwhile, contains the correct price).

These differences mean that the crc32 checksums for the `1.D` and `tcode` files produced by the converted source files will not match those produced by building the `make` version in the main repository.

For comparison, here are the checksums for `1.D` and `tcode` that we get from the `release=source-disc` build:

```
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
d1ca0224  19997  d1ca0224  19997   Yes   1.D.bin
327d4a76  17422  327d4a76  17422   Yes   tcode.bin
```

All other files should match the results from the converted sources.

---

Right on, Commanders!

_Mark Moxon_