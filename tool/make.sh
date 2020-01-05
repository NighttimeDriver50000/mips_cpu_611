#!/bin/sh
cd "$(dirname "$0")/.."
verilator -Wall -LDFLAGS -lncurses --cc hex7seg.v --exe hex7seg.cpp
make -j -C obj_dir -f Vhex7seg.mk Vhex7seg
verilator -Wall -LDFLAGS -lSDL2 --cc vga/display_if_sdl.v --exe vga/display_if_sdl.cpp
make -j -C obj_dir -f Vdisplay_if_sdl.mk Vdisplay_if_sdl
