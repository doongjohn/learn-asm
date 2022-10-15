%include "macros.asm"


TIOCGWINSZ equ 0x5413


section .bss
struc st_winsize
  .ws_row resw 1    ; unsigned short int ws_row;
  .ws_col resw 1    ; unsigned short int ws_col;
  .ws_xpixel resw 1 ; unsigned short int ws_xpixel;
  .ws_ypixel resw 1 ; unsigned short int ws_ypixel;
endstruc

winsize resb st_winsize_size

; winsize
;   istruc st_winsize
;     at st_winsize.ws_row, dw 0
;     at st_winsize.ws_col, dw 0
;     at st_winsize.ws_xpixel, dw 0
;     at st_winsize.ws_ypixel, dw 0
;   iend


section .rodata
str_width db "terminal width = "
str_width_len equ $ - str_width

str_height db "terminal height = "
str_height_len equ $ - str_height

str_esc db "", 0x1b
str_test db "", 0x1b, "[10;10f"
str_test_len equ $ - str_test


section .text
global _start

_start
  mov rsi, TIOCGWINSZ
  mov rdx, winsize
  sys_ioctl

  term_clear
  term_gotoxy 0, 0

  mov rsi, str_width
  mov rdx, str_width_len
  sys_write

  print_uint 2, [winsize + st_winsize.ws_col]
  print_newline

  mov rsi, str_height
  mov rdx, str_height_len
  sys_write

  print_uint 2, [winsize + st_winsize.ws_row]
  print_newline

  sys_exit 0
