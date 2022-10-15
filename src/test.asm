%include "macros.asm"

section .rodata
  hello: db "Hello, world!", 10
  hello_len equ $ - hello

section .text
  global _start

_start:
  mov rsi, hello
  mov rdx, hello_len
  sys_write

  print_int 8, 123
  print_newline

  print_int 8, -12310
  print_newline

  sys_exit 0
