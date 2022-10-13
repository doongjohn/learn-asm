#!/bin/sh
set -e

# nasm -f elf64 src/test.nasm -g -o build/test.o
yasm -p nasm -a x86 -f elf64 -g dwarf2 src/$1.nasm -o build/$1.o
if [ $2 = 'libc' ]; then
  clang build/$1.o -o build/$1
else
  ld -m elf_x86_64 build/$1.o -o build/$1
fi
