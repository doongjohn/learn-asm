; let's learn assembly!
; [arch]: x64 (nasm)
; [plat]: linux

; TODO: learn about floating point number
; TODO: learn about heap allocation
; TODO: learn about file io
; TODO: learn about network io
; TODO: learn about multi-threading
; TODO: learn about SIMD
; TODO: learn about nasm macro
;       https://stackoverflow.com/questions/49541502/basics-of-assembly-programming-in-64-bit-nasm-programming

; why use nop
; https://electronics.stackexchange.com/questions/173216/why-do-we-need-the-nop-i-e-no-operation-instruction-in-microprocessor-8085
; https://reverseengineering.stackexchange.com/questions/4084/why-ther-are-some-many-padding-leading-nop-instructions-in-my-binary-code

; yasm and nasm
; http://www.tortall.net/projects/yasm/manual/html/index.html
; https://nasm.us/doc/nasmdoc4.html

; nasm label syntax
; https://stackoverflow.com/questions/17913264/assembly-programming-variables-defined-using-what-looks-like-labels-or-va

; x86_64 cheat sheet
; https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
; https://gist.github.com/justinian/385c70347db8aca7ba93e87db90fc9a6
; https://stackoverflow.com/questions/44860003/how-many-bytes-do-resb-resw-resd-resq-allocate-in-nasm

; c types size
; https://melonicedlatte.com/algorithm/2018/03/04/022437.html

; c calling convention
; https://soliduscode.com/nasm-x64-c-calling-convention/
; https://www.mourtada.se/calling-printf-from-the-c-standard-library-in-assembly/

; all x86 instructions
; https://www.felixcloutier.com/x86/index.html

; all linux syscalls
; https://filippo.io/linux-syscall-table/

; initial state of registers
; https://stackoverflow.com/questions/9147455/what-is-the-default-register-state-when-program-launches-asm-linux

; pointer and dereference
; https://stackoverflow.com/questions/47534020/how-to-get-address-of-variable-and-dereference-it-in-nasm-x86-assembly

; instruction: lea
; https://stackoverflow.com/questions/1658294/whats-the-purpose-of-the-lea-instruction

; instruction: mul
; https://stackoverflow.com/questions/40893026/mul-function-in-assembly

; instruction: div
; https://www.youtube.com/watch?v=XuUD0WQ9kaE&list=PLetF-YjXm-sCH6FrTz4AQhfH6INDQvQSn&index=8

; instruction: je, jz, jne, jnz
; https://stackoverflow.com/questions/14267081/difference-between-je-jne-and-jz-jnz

; return value of syscall and function is stored in `rax`
; https://stackoverflow.com/questions/38751614/what-are-the-return-values-of-system-calls-in-assembly

; about stack alignment
; https://stackoverflow.com/questions/672461/what-is-stack-alignment
; https://stackoverflow.com/questions/4175281/what-does-it-mean-to-align-the-stack
; https://community.intel.com/t5/Intel-ISA-Extensions/About-the-x64-stack-Alignment/m-p/881085
; https://hackyboiz.github.io/2020/12/06/fabu1ous/x64-stack-alignment/

; about cacheline
; https://stackoverflow.com/questions/39971639/what-does-cacheline-aligned-mean

; about pusha
; https://stackoverflow.com/questions/6837392/how-to-save-the-registers-on-x86-64-for-an-interrupt-service-routine

; tutorials
; https://www.youtube.com/playlist?list=PLetF-YjXm-sCH6FrTz4AQhfH6INDQvQSn
; https://www.youtube.com/watch?v=5eWiz3soaEM
; https://www.youtube.com/playlist?list=PLmxT2pVYo5LB5EzTPZGfFN0c2GDiSXgQe


; equ is like define in c
; https://stackoverflow.com/questions/8006711/whats-the-difference-between-equ-and-db-in-nasm
newline equ 10


; initialized const global variables are stored in data
; these data occupy file storage space and ROM
section .rodata
prompt_msg1 db "input a number: "
prompt_len equ $ - prompt_msg1 ; https://stackoverflow.com/questions/57746534/how-equ-instruction-get-the-length-of-a-string-in-nasm-syntax

prompt_msg2 db "it is not a number", newline
prompt_len2 equ $ - prompt_msg2

; white space in scanf fmtstr https://stackoverflow.com/questions/18491390/difference-between-scanfc-c-and-scanf-c-c
fmtstr1 db "%d%c", 0
fmtstr2 db "%d conversion happend", newline, 0
fmtstr3 db "number = %d", newline, 0


; initialized non-const global variables are stored in data
; these data occupy the file storage space and the RAM
section .data


; uninitialized non-const global variables are stored in the bss memory
; these data do not occupy file storage space but only occupy the RAM
section .bss
; Your application's executable file(ELF) has a BSS section's size information,
; when it starts up, kernel allocate a block of memory for BSS section, and clean it to 0
input_num resb 8
input_whitespace resb 8


section .text
; "_start" is a default entry point for the ld linker
; but for this program the entry point needs to be "main" because
; I'm going to use clang or gcc to link this program with the libc
global main ; global means this symbol is accessible to the linker

; libc functions
extern printf ; libc printf
extern scanf  ; libc scanf

; args
; rdi, fmtstr  (ptr)
; rsi, fmtarg1 (val)
; rdx, fmtarg2 (val)
%macro c_printf 0
  push rbp ; align stack
  mov rax, 0 ; rax must be 0 before calling a function that takes multiple parameters (it's a calling convention)
  call printf
  pop rbp
%endmacro

; args
; rdi, fmtstr  (ptr)
; rsi, fmtarg1 (ptr)
; rdx, fmtarg2 (ptr)
%macro c_scanf 0
  push rbp
  mov rax, 0
  call scanf
  pop rbp
%endmacro

main
  mov rsi, prompt_msg1
  mov rdx, prompt_len
  call sys_write

  mov rdi, fmtstr1 ; "%d%c" reads a number and a trailing character
  mov rsi, input_num
  mov rdx, input_whitespace
  c_scanf
  push rax ; result of scanf

  mov rdi, fmtstr2
  mov rsi, rax
  c_printf

  pop rax

  ; if rax == 2 && (rcx == ' ' || rcx == '\n')
  mov rcx, 0
  xor rcx, [input_whitespace]
  cmp rcx, ' '
  je _input_is_number
  cmp rcx, newline
  je _input_is_number

  ; input is not num
  mov rsi, prompt_msg2
  mov rdx, prompt_len2
  call sys_write
  jmp _main_return

_input_is_number
  mov rdi, fmtstr3
  mov rsi, [input_num] ; dereference pointer
  c_printf

_main_return
  mov rax, 0 ; rax is a return value
  ret

; args
; mov rsi, msg (ptr)
; mov rdx, len (ptr)
sys_write
  mov rax, 1 ; syscall id
  mov rdi, 1 ; file descriptor
  syscall
  ret
