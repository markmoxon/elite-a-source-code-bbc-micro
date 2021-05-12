beebasm -i "sources/a.tcode.asm" -v > output/compile.txt
beebasm -i "sources/a.dcode.asm" -v >> output/compile.txt
beebasm -i "sources/a.icode.asm" -v >> output/compile.txt
beebasm -i "sources/1.d.asm" -v >> output/compile.txt
beebasm -i "sources/a.qcode.asm" -v >> output/compile.txt
beebasm -i "sources/a.qelite.asm" -v >> output/compile.txt
beebasm -i "sources/a.elite.asm" -v >> output/compile.txt
python sources/crc32.py extracted/patched output
