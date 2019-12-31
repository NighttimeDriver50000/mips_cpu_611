#!/bin/sh
cd "$(dirname "$0")"
cp ../asm/orbit.data.hex.txt ../data_hex.txt
cp ../asm/orbit.hex.txt ../program_hex.txt
./padprogram.sh
./gen_mif.sh
