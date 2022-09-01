; let's learn assembly!
; [arch]: x64 (nasm)
; [plat]: linux

; TODO: learn about heap
; TODO: learn about padding https://reverseengineering.stackexchange.com/questions/4084/why-ther-are-some-many-padding-leading-nop-instructions-in-my-binary-code
; TODO: learn about macro https://stackoverflow.com/questions/49541502/basics-of-assembly-programming-in-64-bit-nasm-programming
; TODO: make a simple game

; yasm and nasm
; http://www.tortall.net/projects/yasm/manual/html/index.html
; https://nasm.us/doc/nasmdoc4.html

; x86_64 cheat sheet
; https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html

; all x86 instructions
; https://www.felixcloutier.com/x86/index.html

; initial state of registers
; https://stackoverflow.com/questions/9147455/what-is-the-default-register-state-when-program-launches-asm-linux

; pointer and dereference
; https://stackoverflow.com/questions/47534020/how-to-get-address-of-variable-and-dereference-it-in-nasm-x86-assembly

; instruction: lea
; https://stackoverflow.com/questions/1658294/whats-the-purpose-of-the-lea-instruction

; instruction: div
; https://www.youtube.com/watch?v=XuUD0WQ9kaE&list=PLetF-YjXm-sCH6FrTz4AQhfH6INDQvQSn&index=8

; instruction: je, jz, jne, jnz
; https://stackoverflow.com/questions/14267081/difference-between-je-jne-and-jz-jnz

; list of linux syscalls
; https://filippo.io/linux-syscall-table/

; return value of syscall and function is stored in `rax`
; https://stackoverflow.com/questions/38751614/what-are-the-return-values-of-system-calls-in-assembly

; about stack alignment
; https://stackoverflow.com/questions/672461/what-is-stack-alignment
; https://stackoverflow.com/questions/4175281/what-does-it-mean-to-align-the-stack
; https://community.intel.com/t5/Intel-ISA-Extensions/About-the-x64-stack-Alignment/m-p/881085
; https://hackyboiz.github.io/2020/12/06/fabu1ous/x64-stack-alignment/

; about cacheline
; https://stackoverflow.com/questions/39971639/what-does-cacheline-aligned-mean

; c calling convention
; https://soliduscode.com/nasm-x64-c-calling-convention/
; https://www.mourtada.se/calling-printf-from-the-c-standard-library-in-assembly/

; about pusha
; https://stackoverflow.com/questions/6837392/how-to-save-the-registers-on-x86-64-for-an-interrupt-service-routine

; tutorials
; https://www.youtube.com/playlist?list=PLetF-YjXm-sCH6FrTz4AQhfH6INDQvQSn
; https://www.youtube.com/watch?v=5eWiz3soaEM
; https://www.youtube.com/playlist?list=PLmxT2pVYo5LB5EzTPZGfFN0c2GDiSXgQe


; initialized const global variables are stored in data
; these data occupy file storage space and ROM
section .rodata
  prompt_msg: db "input a number: "
  prompt_len equ $ - prompt_msg ; https://stackoverflow.com/questions/57746534/how-equ-instruction-get-the-length-of-a-string-in-nasm-syntax
  ; equ is like #define in c
  ; https://stackoverflow.com/questions/8006711/whats-the-difference-between-equ-and-db-in-nasm

  prompt_msg2: db "it is not a number", 10
  prompt_len2 equ $ - prompt_msg2

  fmtstr1: db "%d%c", 0
  fmtstr2: db "%d successful conversion happend", 10, 0
  fmtstr3: db "number = %d", 10, 0

; initialized non-const global variables are stored in data
; these data occupy the file storage space and the RAM
section .data

; uninitialized non-const global variables are stored in the bss memory
; these data do not occupy file storage space but only occupy the RAM
section .bss
  input_num: resb 8
  input_whitespace: resb 8

section .text
  global main ; global means it is accessible to the linker
  ; _start is a default entry point for the ld linker
  ; but it needs to be main because I'm going to use clang to link this program with libc

  ; this is possible becuase I will link this program with the libc
  extern printf
  extern scanf

; arguments
; rdi, fmtstr  (ptr)
; rsi, fmtarg1 (val)
; rdx, fmtarg2 (val)
%macro c_printf 0
  push rbp ; align stack
  mov rax, 0 ; rax must be 0 before calling a function that takes multiple parameters (it's a calling convention)
  call printf
  pop rbp
%endmacro

; arguments
; rdi, fmtstr  (ptr)
; rsi, fmtarg1 (ptr)
; rdx, fmtarg2 (ptr)
%macro c_scanf 0
  push rbp
  mov rax, 0
  call scanf
  pop rbp
%endmacro

main:
  mov rsi, prompt_msg
  mov rdx, prompt_len
  call write

  mov rdi, fmtstr1
  mov rsi, input_num
  mov rdx, input_whitespace
  c_scanf
  push rax

  mov rdi, fmtstr2
  mov rsi, rax ; dereference pointer
  c_printf

  pop rax
  mov rcx, rax

  ; if rax == 2 && (rcx == ' ' || rcx == '\n')
  sub rcx, 2
  xor rcx, [input_whitespace]
  cmp rcx, ' '
  je _input_is_num
  cmp rcx, 10
  je _input_is_num

  ; input is not num
  mov rsi, prompt_msg2
  mov rdx, prompt_len2
  call write
  jmp _main_end

_input_is_num:
  mov rdi, fmtstr3
  mov rsi, [input_num] ; dereference pointer
  c_printf

_main_end:
  mov rax, 0 ; rax is a return value
  ret

; arguments
; mov rsi, msg (ptr)
; mov rdx, len (ptr)
write:
  mov rax, 1 ; syscall id
  mov rdi, 1 ; file descriptor
  syscall
  ret
