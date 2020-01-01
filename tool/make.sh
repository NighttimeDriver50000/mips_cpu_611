#!/bin/sh
cd "$(dirname "$0")/.."
verilator -Wall -LDFLAGS -lncurses --cc hex7seg.v --exe hex7seg.cpp
make -j -C obj_dir -f Vhex7seg.mk Vhex7seg
