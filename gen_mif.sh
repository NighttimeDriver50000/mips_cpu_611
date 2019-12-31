#!/bin/sh
echo 'DEPTH = 1024;' > program.mif
echo 'WIDTH = 32;' >> program.mif
echo 'ADDRESS_RADIX = UNS;' >> program.mif
echo 'DATA_RADIX = HEX;' >> program.mif
echo 'CONTENT' >> program.mif
echo 'BEGIN' >> program.mif

sed 's/^/: /g' < program_hex.txt | sed '/:\s*$/d' | nl -v 0 -n rz \
    | sed 's/^ *//g' | sed 's/\t/ /g' | sed 's/$/;/g' >> program.mif

echo 'END;' >> program.mif
