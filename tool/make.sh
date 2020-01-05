#!/bin/sh
cd "$(dirname "$0")/.."
verilator -Wall -LDFLAGS -lncurses --cc hex7seg.v --exe hex7seg.cpp
make -j -C obj_dir -f Vhex7seg.mk Vhex7seg
verilator -Wall -LDFLAGS -lSDL2 --cc vga/display_if_sdl.v --exe vga/display_if_sdl.cpp
make -j -C obj_dir -f Vdisplay_if_sdl.mk Vdisplay_if_sdl
./tool/prep_orbit.sh
verilator -Wall -LDFLAGS -lncurses -LDFLAGS -lSDL2 \
    --cc cpu/mips_cpu_inst_for_sdl.v vga/display_if_sdl.v \
        cpu/mips_cpu.v alu/alu.v reg/reg32x32.v \
    --exe cpu/mips_cpu_inst_for_sdl.cpp
make -j -C obj_dir -f Vmips_cpu_inst_for_sdl.mk Vmips_cpu_inst_for_sdl
