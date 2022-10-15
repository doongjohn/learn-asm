%include "macros.asm"

section .rodata
  hello: db "Hello, world!", 10
  hello_len equ $ - hello

section .text
  global _start

_start:
  mov rsi, hello
  mov rdx, hello_len
  write

  print_int 123
  print_newline

  print_int -12310
  print_newline

  exit 0
