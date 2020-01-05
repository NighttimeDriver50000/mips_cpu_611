# Bog-Standard Classwork MIPS CPU

I wrote this MIPS CPU as part of CSCE 611 at USC in 2016. We wrote it for the
Altera tools, but this gets it to work somewhat with Verilator.

Currently, it *can* run the final project from that class, but the simulator is
extremely slow. To test it with the SDL frontend:

```bash
$ git clone https://github.com/NighttimeDriver50000/mips_cpu_611.git
$ cd mips_cpu_611
$ ./tool/make.sh
$ ./obj_dir/Vmips_cpu_inst_for_sdl
```

This is probably all I'll do on getting this to run on Verilator, seeing as the
simulation is so slow.

The code is MIT licensed, but there are *far* better MIPS CPUs out there.
