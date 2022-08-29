%include "macros.nasm"

section .rodata
  hello: db "hello, world", 10
  hello_len equ $ - hello

section .text
  global _start

_start:
  mov rsi, hello
  mov rdx, hello_len
  write

  print_uint 456123
  print_newline

  exit 0
