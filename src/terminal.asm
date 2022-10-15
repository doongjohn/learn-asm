%include "macros.asm"


TIOCGWINSZ equ 21523 ; 0x5413


section .bss
struc st_winsize
  .ws_row resw 1    ; unsigned short int ws_row;
  .ws_col resw 1    ; unsigned short int ws_col;
  .ws_xpixel resw 1 ; unsigned short int ws_xpixel;
  .ws_ypixel resw 1 ; unsigned short int ws_ypixel;
endstruc

winsize resb st_winsize_size


section .rodata
str_width db "terminal width = "
str_width_len equ $ - str_width

str_height db "terminal height = "
str_height_len equ $ - str_height


section .text
global _start

_start
  mov rsi, TIOCGWINSZ
  mov rdx, winsize
  call sys_ioctl

  mov rsi, str_width
  mov rdx, str_width_len
  sys_write

  print_uint [winsize + st_winsize.ws_col] ; ws_col
  print_newline

  mov rsi, str_height
  mov rdx, str_height_len
  sys_write

  print_uint [winsize + st_winsize.ws_row] ; ws_row
  print_newline

  sys_exit 0

; args
; mov rsi, cmd
; mov rdx, arg (ptr)
sys_ioctl
  mov rax, 16 ; syscall id
  mov rdi, 0 ; file descriptor
  syscall
  ret
