#!/bin/sh
cd "$(dirname "$0")"
cp orbit.hex.txt program_hex.txt
./padprogram.sh
./gen_mif.sh
