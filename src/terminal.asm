%include "macros.asm"


%define TIOCGWINSZ 0x5413


struc st_winsize
  .ws_row resw 1    ; unsigned short int ws_row;
  .ws_col resw 1    ; unsigned short int ws_col;
  .ws_xpixel resw 1 ; unsigned short int ws_xpixel;
  .ws_ypixel resw 1 ; unsigned short int ws_ypixel;
endstruc


section .bss
winsize resb st_winsize_size

; winsize
;   istruc st_winsize
;     at st_winsize.ws_row, dw 0
;     at st_winsize.ws_col, dw 0
;     at st_winsize.ws_xpixel, dw 0
;     at st_winsize.ws_ypixel, dw 0
;   iend


; TODO: get keyboard input and move character
section .text
global _start

_start
  mov rsi, TIOCGWINSZ
  mov rdx, winsize
  sys_ioctl

  term_clear
  term_gotoxy 0, 0

  print_strlit "terminal weight = "
  print_uint 2, [winsize + st_winsize.ws_col]
  print_newline

  print_strlit "terminal height = "
  print_uint 2, [winsize + st_winsize.ws_row]
  print_newline

  sys_exit 0
