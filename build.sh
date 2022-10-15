#!/bin/sh
set -e

# sh build.sh learn libc
# sh build.sh test

# nasm -f elf64 src/$1.asm -g -o build/$1.o
yasm -p nasm -a x86 -f elf64 -g dwarf2 src/$1.asm -o build/$1.o
if [ ! -z "$2" ] && [ $2 = 'libc' ]; then
  clang build/$1.o -o build/$1
else
  ld -m elf_x86_64 build/$1.o -o build/$1
fi
