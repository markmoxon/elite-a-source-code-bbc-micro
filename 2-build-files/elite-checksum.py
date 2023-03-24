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
argc = len(argv)
Encrypt = True

if argc > 1 and argv[1] == "-u":
    Encrypt = False

print("Elite-A Checksum")
print("Encryption = ", Encrypt)

# Configuration variables for ELITE

load_address = 0x1900

data_block = bytearray()

# Load assembled code file

elite_file = open("3-assembled-output/ELITE.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()

# Commander data checksum
# Note, the starting value of CY is different to the other Elites

na_per_cent_offset = 0x29E9 - load_address
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
    checksum_offset = 0x2A3B - load_address
    data_block[checksum_offset] = CH ^ 0xA9
    data_block[checksum_offset + 1] = CH

# Write output file for ELITE

output_file = open("3-assembled-output/ELITE.bin", "wb")
output_file.write(data_block)
output_file.close()

print("3-assembled-output/ELITE.bin file saved")
