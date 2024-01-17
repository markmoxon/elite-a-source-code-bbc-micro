#!/usr/bin/env python
#
# ******************************************************************************
#
# ELITE-A CHECKSUM SCRIPT
#
# Written by Mark Moxon
#
# This script applies checksums to the compiled binary for the main game code.
# It reads this binary file:
#
#   * ELITE.bin
#
# and generates a checksum version as follows:
#
#   * ELITE.bin
#
# ******************************************************************************

from __future__ import print_function
import sys

argv = sys.argv
Encrypt = True
release = 1

for arg in argv[1:]:
    if arg == "-u":
        Encrypt = False
    if arg == "-rel1":
        release = 1
    if arg == "-rel2":
        release = 2
    if arg == "-rel3":
        release = 3

print("Elite-A Checksum")
print("Encryption = ", Encrypt)

# Configuration variables for scrambling code and calculating checksums
#
# Values must match those in 3-assembled-output/compile.txt
#
# If you alter the source code, then you should extract the correct values for
# the following variables and plug them into the following, otherwise the game
# will fail the checksum process and will hang on loading
#
# You can find the correct values for these variables by building your updated
# source, and then searching compile.txt for "elite-checksum.py", where the new
# values will be listed

if release == 1:
    # Released
    tvt1_code = 0x2968          # TVT1code
    tvt1 = 0x1100               # TVT1
    na_per_cent = 0x1181        # NA%
    chk2 = 0x11D3               # CHK2

elif release == 2:
    # Source disc
    tvt1_code = 0x2968          # TVT1code
    tvt1 = 0x1100               # TVT1
    na_per_cent = 0x1181        # NA%
    chk2 = 0x11D3               # CHK2

elif release == 3:
    # Bug fix
    tvt1_code = 0x296B          # TVT1code
    tvt1 = 0x1100               # TVT1
    na_per_cent = 0x1181        # NA%
    chk2 = 0x11D3               # CHK2

# Configuration variables for ELITE

load_address = 0x1900

data_block = bytearray()

# Load assembled code file

elite_file = open("3-assembled-output/ELITE.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()

# Commander data checksum
# Note, the starting value of CY is different to the other Elites

na_per_cent_offset = na_per_cent - tvt1 + tvt1_code - load_address
CH = 0x4B - 2
CY = 1
for i in range(CH, 0, -1):
    CH = CH + CY + data_block[na_per_cent_offset + i + 7]
    CY = (CH > 255) & 1
    CH = CH % 256
    CH = CH ^ data_block[na_per_cent_offset + i + 8]

print("Commander checksum = ", hex(CH))

# Must have Commander checksum otherwise game will lock:

if Encrypt:
    checksum_offset = chk2 - tvt1 + tvt1_code - load_address
    data_block[checksum_offset] = CH ^ 0xA9
    data_block[checksum_offset + 1] = CH

# Write output file for ELITE

output_file = open("3-assembled-output/ELITE.bin", "wb")
output_file.write(data_block)
output_file.close()

print("3-assembled-output/ELITE.bin file saved")
