%include "macros.asm"


section .text
global _start

_start
  println_strlit "Hello, world!"

  print_int 8, 123
  print_newline

  print_int 8, -12310
  print_newline

  sys_exit 0
