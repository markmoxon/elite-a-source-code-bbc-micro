import re


# Config
source_folder = "original/"
source_files = ["a.global",
                "a.tcode", "a.tcode_1", "a.tcode_2", "a.tcode_3",
                "a.dcode", "a.dcode_1", "a.dcode_2", "a.dcode_3",
                "a.icode", "a.icode_1", "a.icode_2", "a.icode_3",
                "a.qcode", "a.qcode_1", "a.qcode_2", "a.qcode_3", "a.qcode_4", "a.qcode_5", "a.qcode_6",
                "a.qship_1", "a.qship_2",
                "a.qelite",
                "a.elite"
                ]
dest_folder = "sources/"

re_label = re.compile(r'^([a-z0-9A-Z_]+):?(\s+.*)*$')
re_llabel = re.compile(r'(l_[0-9A-F]{4})')
re_instruction = re.compile(r'^\s*(.+)$')
re_labelinstruction = re.compile(r'^([a-z0-9A-Z_]+):?\s+(.+)$')
re_equa = re.compile(r'^\s*EQUA\s*"(.+)"$')
re_var = re.compile(r'^([a-z0-9A-Z_]+):?\s*EQU \s*(\$?)(.+)$')
re_get = re.compile(r'^\s+GET\s*"(.+)"$')


def process_file(input_file, output_file, source_file):
    code_defined = False

    for line in input_file:
        # Manual fixes for scoping and case issues that trigger BeebAsm errors
        if source_file == "a.qcode_4":
            line = line.replace("jmp_start3", "jmp_start3_dup")
        if source_file == "a.qcode_3":
            line = line.replace("_07c0", "_07C0")
            line = line.replace("_07e0", "_07E0")

        if line.endswith(".<\n"):
            continue

        a = re_llabel.search(line)
        while a and a.group(1) != a.group(1).lower():
            line = line.replace(a.group(1), a.group(1).lower())
            a = re_llabel.search(line)
        m = re_label.search(line)
        n = re_equa.search(line)
        p = re_instruction.search(line)
        q = re_var.search(line)
        r = re_get.search(line)
        s = re_labelinstruction.search(line)
        if "EQUD 2#" in line:
            line = line.replace("EQUD 2#", "EQUD %")
        elif s and not s.group(2).startswith("EQU "):
            line = "\n." + s.group(1) + "\n\n"
            if s.group(2).startswith("EQUA"):
                z = re_equa.search(s.group(2))
                line += ' EQUS "' + convert_equa(z.group(1)) + '"\n'
                line = line.replace('EQUS "", ', 'EQUS ').replace(', ""', '')
            else:
                line += " " + s.group(2).replace("$", "&") + "\n"
        elif q:
            amp = q.group(2).replace("$", "&")
            line = q.group(1) + " = " + amp + q.group(3).replace("$", "&").replace("PC", "P%") + "\n"
        elif m:
            line = "\n." + m.group(1) + "\n\n"
        elif n:
            line = ' EQUS "' + convert_equa(n.group(1)) + '"\n'
            line = line.replace('EQUS "", ', 'EQUS ').replace(', ""', '')
        elif r:
            line = 'INCLUDE "sources/' + r.group(1).replace(":0.", "").replace(":2.", "") + '.asm"\n'
        elif p:
            if p.group(1).startswith("LOAD"):
                line = line.replace("$FFFF", "$").replace("\tLOAD $", "LOAD% = &")
            elif p.group(1).startswith("EXEC"):
                line = line.replace("$FFFF", "$").replace("\tEXEC $", "EXEC% = &").replace("\tEXEC ", "\\EXEC = ")
            elif p.group(1).startswith("ORG"):
                if code_defined:
                    line = line.replace("$FFFF", "$").replace("\tORG $", "ORG &")
                else:
                    line = line.replace("$FFFF", "$").replace("\tORG $", "CODE% = &") + "ORG CODE%\n"
                    code_defined = True
            elif p.group(1).startswith("OPT"):
                if p.group(1).startswith("OPT CMOS"):
                    line = "CPU 1"
                else:
                    line = line.replace("\tOPT", "\\OPT")
            else:
                inst = p.group(1)
                if "#<" in inst:
                    inst = re.sub(r'#<(\w+)', r'#LO(\1)', inst)
                elif "#>" in inst:
                    inst = re.sub(r'#>(\w+)', r'#HI(\1)', inst)
                line = " " + inst.replace("$", "&") + "\n"
        output_file.write(line)


def convert_equa(equa):
    result = ""
    ctrl = False
    excl = False

    for char in equa:
        if ctrl:
            if char == '!':
                excl = True
                ctrl = False
                continue
            if char == '|':
                ascii = ord(char)
            else:
                ascii = ord(char) - 0x40
            if ascii < 0:
                ascii += 0x80
            if excl:
                ascii += 0x80
            result += '", &' + ('%02x' % ascii).upper() + ', "'
            ctrl = False
            excl = False
        elif char == '|':
            ctrl = True
        else:
            if excl:
                ascii = ord(char) + 0x80
                if ascii < 0:
                    ascii += 0x80
                result += '", &' + ('%02x' % ascii).upper() + ', "'
            else:
                result += char
            ctrl = False
            excl = False

    return result


for source_file in source_files:
    input = source_folder + source_file

    with open(input, "r", encoding="latin-1") as input_file:
        output = dest_folder + source_file + ".asm"
        print(".", end="", flush=True)

        with open(output, "w") as output_file:
            process_file(input_file, output_file, source_file)

            if source_file == "a.tcode":
                output_file.write('\nSAVE "output/tcode.bin", CODE%, P%, LOAD%')
            if source_file == "a.dcode":
                output_file.write('\nSAVE "output/1.F.bin", CODE%, P%, LOAD%')
            if source_file == "a.icode":
                output_file.write('\nSAVE "output/1.E.bin", CODE%, P%, LOAD%')
            if source_file == "a.qcode":
                output_file.write('\nSAVE "output/2.T.bin", CODE%, P%, LOAD%')
            if source_file == "a.qelite":
                output_file.write('\nSAVE "output/2.H.bin", CODE%, P%, LOAD%')
            if source_file == "a.elite":
                output_file.write('\nCOPYBLOCK &DD00, P%, to_dd00')
                output_file.write('\nSAVE "output/ELITE.bin", CODE%, to_dd00+dd00_len, LOAD%')

print()
