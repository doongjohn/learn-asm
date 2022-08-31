%include "macros.nasm"

section .rodata
  hello: db "hello, world", 10
  hello_len equ $ - hello

section .text
  global _start

_start:
  print_int 123
  print_newline

  print_int -123
  print_newline

  exit 0
