#!/bin/bash
set -e
P=riscv64-unknown-elf
$P-gcc -march=rv32i -mabi=ilp32 -O1 -nostdlib -nostartfiles -ffreestanding \
    -fno-builtin -fno-tree-loop-distribute-patterns -Wl,--no-warn-rwx-segments \
    -T sw/link.ld sw/start.S sw/main2.c -o sw/prog.elf -lgcc
$P-objcopy -O binary sw/prog.elf sw/prog.bin
od -An -v -tx4 -w4 sw/prog.bin | tr -d ' ' > programs/prog.mem
$P-objdump -d sw/prog.elf > sw/prog.dump
HALT=$($P-nm sw/prog.elf | grep ' _halt' | cut -d' ' -f1)