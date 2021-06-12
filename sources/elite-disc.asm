\ ******************************************************************************
\
\ ELITE-A DISC IMAGE SCRIPT
\
\ Elite-A is an extended version of BBC Micro Elite, written by Angus Duggan
\
\ The original Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984, and the extra code in Elite-A is copyright Angus Duggan
\
\ The code on this site is identical to Angus Duggan's source discs (it's just
\ been reformatted and variable names changed to be more readable)
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces one of the following SSD disc images, depending on
\ which release is being built:
\
\   * elite-a-released.ssd
\   * elite-a-from-source-disc.ssd
\
\ This can be loaded into an emulator or a real BBC Micro.
\
\ ******************************************************************************

PUTFILE "binaries/$.!BOOT.bin", "!BOOT", &FFFFFF, &FFFFFF

PUTFILE "output/ELITE.bin", "ELITE", &FF1900, &FF197B

PUTFILE "output/1.D.bin", "1.D", &FF11E3, &FF11E3
PUTFILE "output/1.E.bin", "1.E", &FF11E3, &FF11E3
PUTFILE "output/1.F.bin", "1.F", &FF11E3, &FF11E3

PUTFILE "output/2.H.bin", "2.H", &FF1200, &FF1200
PUTFILE "output/2.T.bin", "2.T", &001000, &002E93

PUTFILE "binaries/S.A.bin", "S.A", &FF5600, &FF5600
PUTFILE "binaries/S.B.bin", "S.B", &FF5600, &FF5600
PUTFILE "binaries/S.C.bin", "S.C", &FF5600, &FF5600
PUTFILE "binaries/S.D.bin", "S.D", &FF5600, &FF5600
PUTFILE "binaries/S.E.bin", "S.E", &FF5600, &FF5600
PUTFILE "binaries/S.F.bin", "S.F", &FF5600, &FF5600
PUTFILE "binaries/S.G.bin", "S.G", &FF5600, &FF5600
PUTFILE "binaries/S.H.bin", "S.H", &FF5600, &FF5600
PUTFILE "binaries/S.I.bin", "S.I", &FF5600, &FF5600
PUTFILE "binaries/S.J.bin", "S.J", &FF5600, &FF5600
PUTFILE "binaries/S.K.bin", "S.K", &FF5600, &FF5600
PUTFILE "binaries/S.L.bin", "S.L", &FF5600, &FF5600
PUTFILE "binaries/S.M.bin", "S.M", &FF5600, &FF5600
PUTFILE "binaries/S.N.bin", "S.N", &FF5600, &FF5600
PUTFILE "binaries/S.O.bin", "S.O", &FF5600, &FF5600
PUTFILE "binaries/S.P.bin", "S.P", &FF5600, &FF5600
PUTFILE "binaries/S.Q.bin", "S.Q", &FF5600, &FF5600
PUTFILE "binaries/S.R.bin", "S.R", &FF5600, &FF5600
PUTFILE "binaries/S.S.bin", "S.S", &FF5600, &FF5600
PUTFILE "binaries/S.T.bin", "S.T", &FF5600, &FF5600
PUTFILE "binaries/S.U.bin", "S.U", &FF5600, &FF5600
PUTFILE "binaries/S.V.bin", "S.V", &FF5600, &FF5600
PUTFILE "binaries/S.W.bin", "S.W", &FF5600, &FF5600

PUTFILE "binaries/B.CONVERT.bin", "B.CONVERT", &FF1900, &FF8023
