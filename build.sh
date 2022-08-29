#!/bin/sh
set -e

# nasm -f elf64 src/test.nasm -g -o build/test.o
yasm -p nasm -a x86 -f elf64 -g dwarf2 src/test.nasm -o build/test.o
ld -m elf_x86_64 build/test.o -o build/test

# yasm -p nasm -a x86 -f elf64 -g dwarf2 src/learn.nasm -o build/learn.o
# clang build/learn.o -o build/learn
