# Original source files for Elite-A

This folder contains Angus Duggan's original source files for Elite-A. You can find them in the `sources` folder. They are VIEW-compatible text files (Angus used Acornsoft's VIEW word processor as his IDE).

# Building Elite-A from the original sources

Elite-A was assembled from the source files using Angus's own handwritten assembler ROM. The file format for this assembler is pretty close to the BeebAsm format we need if we want to build the sources on a modern computer, but they do need converting first.

The Python script in this folder converts these sources into a format that compiles in BeebAsm.

## Converting the original sources to BeebAsm

To convert the files into a format that BeebAsm is happy with, `cd` into the folder containing this script, and do the following:

```
python convert-original-to-beebasm.py
```

This will convert the source files in the `source` folder into BeebAsm-compatible format and save them into the `converted` folder.

## Assembling the converted source files in BeebAsm

Once the files are converted, you can them assemble each of them using commands like this:

```
beebasm -i converted/a.tcode.asm
```

This saves the assembled binary (`tcode` in this case) into the `output` folder.

To build the full game you need to mirror the original multi-step assembly process, as follows:

Assemble `a.tcode` to produce `output/tcode`:

```
beebasm -i converted/a.tcode.asm
```

Assemble `a.dcode` to produce `output/1.F`:

```
beebasm -i converted/a.dcode.asm
```

Assemble `a.icode` to produce `output/1.E`:

```
beebasm -i converted/a.icode.asm
```

Assemble `a.qcode` to produce `output/2.T`:

```
beebasm -i converted/a.qcode.asm
```

Assemble `a.qelite` to produce `output/2.H`:

```
beebasm -i converted/a.qelite.asm
```

Assemble `a.elite` to produce `output/ELITE`:

```
beebasm -i converted/a.elite.asm
```

Assemble `1.d.asm` to produce `output/1.D`:

```
beebasm -i 1.d.asm
```

This last step simply concatenates the `tcode` and `S.T` binaries into one file. (Note that `S.T` is currently provided as an assembled binary, as the ship files were produced by a BBC BASIC source, which hasn't been converted to BeebAsm yet).

Note that the `S.T` binary that is incorporated into `1.D` by the above step is not the same as the `S.T` ship file on the final game disc (though confusingly they have the same name). The `S.T` binary that's incorporated into `1.D` contains the ships to be shown in the hanger, while the `S.T` file on the final game disc is one of the in-flight ship files.

## Creating a working game disc

Now that we have finished the assembly process, we can create the final game disc as follows:

```
beebasm -i create-disc.asm -do elite-a-from-source-disc.ssd -opt 3
```

This creates a disc image called `elite-a-from-source-disc.ssd` in the current folder, which can be loaded into an emulator, or a BBC Micro using a Gotek. (Ignore the error about the source file containing no SAVE command - it doesn't have to, as we're creating a disc image, not a binary.)

For reference, the above command does the following:

* Copy the `1.D`, `1.E`, `1.F`, `2.H`, `2.T` and `ELITE` files that we just assembled to the game disc

* Copy the `!BOOT`, `B.CONVERT` and `S.A` to `S.W` files from the main repository's `binaries` folder to the game disc

* Set the disc's boot option to `EXEC` using `*OPT 4 3`

This will create the exact Elite-A disc as produced by the original source disc.

## Verifying the results

The version produced by the original source disc is not the same as the generally available Elite-A. The source discs produce a patched version of the game that contains different ship prices - the same version that can be built from the main repository with this command:

```
make encrypt verify release=patched
```

That said, there are two small differences in the version produced by the source discs when compared to the patched version. These differences mean that the crc32 checksums for the `1.D` and `tcode` files produced by the converted source files will not match those produced by the modern build process in this repository. This is because:

* The repository version incorporates "background noise" that the original BBC Micro assembly process includes in the binary, so we can produce byte-accurate binaries that exactly match the released game. Specifically, this noise occurs in the gap between the concatenated `tcode` and `S.T` binaries. In the BeebAsm process above (i.e. when assembling `1.d.asm`) that gap is filled with zeroes, while the original version included whatever random content was in memory at the time.

* The repository version fixes a bug in `a.tcode` that has the wrong price for the Anaconda (the `a.qcode` file contains the correct price).

As a result, here are the checksums for the above build process:

```
c80972e6        1.D
b1447e60        1.E
14ee8b20        1.F
3d638042        2.H
81d6d436        2.T
171ccea5        ELITE
0e2d62be        tcode
```

If you get the above checksums following the assembly process above, then congratulations - you have successfully assembled Elite-A from the original source discs.

For comparison, here are the checksums for `1.D` and `tcode` that we get from a binary-compatible `release=patched` build:

```
d1ca0224        1.D
327d4a76        tcode
```

---

Right on, Commanders!

_Mark Moxon_