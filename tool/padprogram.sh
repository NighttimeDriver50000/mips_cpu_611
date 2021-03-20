#!/bin/sh
cd "$(dirname "$0")/.."
python -c "print('\n'.join(['00000000']*(1024-($(wc -l program_hex.txt | cut -d' ' -f1)))))" \
    >> program_hex.txt
python -c "print('\n'.join(['00000000']*(1024-($(wc -l data_hex.txt | cut -d' ' -f1)))))" \
    >> data_hex.txt
