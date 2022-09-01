STDIN equ 0
STDOUT equ 1
STDERR equ 2

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

section .rodata
  newline: db 10

section .text

%macro exit 1
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro

; mov rsi, text
; mov rdx, text_length
%macro write 0
  mov rax, STDOUT
  mov rdi, SYS_WRITE
  syscall
%endmacro

%macro print_char 1
  ; these three lines of code is called
  ; prologue of the function
  push rbp
  mov rbp, rsp
  sub rsp, 1

  mov byte [rsp], %1

  mov rsi, rsp ; rsi: ptr
  mov rdx, 1
  write

  ; these three lines of code is called
  ; epilogue of the function
  mov rsp, rbp
  pop rbp
  ; ret ; don't return in this case because this is a macro (not a call)
%endmacro

%macro print_digit 1
  push rbp
  mov rbp, rsp
  sub rsp, 1

  mov byte [rsp], %1

  mov rsi, rsp ; rsi: ptr
  add byte [rsi], '0' ; '0' == 48 add 48
  mov rdx, 1
  write

  mov rsp, rbp
  pop rbp
%endmacro

%macro print_newline 0
  mov rsi, newline
  mov rdx, 1
  write
%endmacro

%macro print_uint 1
  push rbp
  mov rbp, rsp

  push rax
  mov rax, %1 ; the number to print

  push r8
  mov r8, 0 ; index

%%loop:
  inc r8 ; increase index

  mov rdx, 0 ; if rdx is not zero then it will be concated with rax when the div is called
  mov rbx, 10
  div rbx ; this will do (rax = rax / rbx)
  ; quotient is stored in the `rax`
  ; remainder is stored in the `rdx`

  sub rsp, 1 ; allocate 1 byte in the stack
  ; more about stack allocation:
  ; https://stackoverflow.com/questions/1018853/why-is-the-use-of-alloca-not-considered-good-practice
  ; https://www.reddit.com/r/cpp_questions/comments/dui3de/why_are_stack_frames_fixed_size/
  mov byte [rsp], dl
  add byte [rsp], '0'

  cmp rax, 0
  jne %%loop
  ; end of loop

  ; write number
  mov rsi, rsp ; rsi: ptr
  mov rdx, r8
  write

  ; restore state
  pop r8
  pop rax

  ; restore stack pointer
  mov rsp, rbp
  pop rbp
%endmacro

%macro print_int 1
  push rbp
  mov rbp, rsp

  push rax
  mov rax, %1 ; the number to print

  push r8
  mov r8, 0 ; index

  push r9
  mov r9, 0 ; sign

  inc r8 ; increase index

  bt rax, 63 ; check sign bit and set the cflag
  jnc %%loop ; is positive
  mov r9, 1 ; is negative
  ; convert the value to positive number
  ; two's complement
  not rax
  inc rax

%%loop:
  inc r8 ; increase index

  mov rdx, 0 ; if rdx is not zero then it will be concated with rax when the div is called
  mov rbx, 10
  div rbx ; this will do (rax = rax / rbx)
  ; quotient is stored in the `rax`
  ; remainder is stored in the `rdx`

  sub rsp, 1 ; allocate 1 byte in the stack
  ; more about stack allocation:
  ; https://stackoverflow.com/questions/1018853/why-is-the-use-of-alloca-not-considered-good-practice
  ; https://www.reddit.com/r/cpp_questions/comments/dui3de/why_are_stack_frames_fixed_size/
  mov byte [rsp], dl
  add byte [rsp], '0'

  cmp rax, 0
  jne %%loop
  ; end of loop

  cmp r9, 0 ; check sign
  je %%write_num
  ; if negative add '-'
  sub rsp, 1 ; allocate 1 byte in the stack
  mov byte [rsp], '-'

%%write_num
  ; write number
  mov rsi, rsp ; rsi: ptr
  mov rdx, r8
  write

  ; restore state
  pop r9
  pop r8
  pop rax

  ; restore stack pointer
  mov rsp, rbp
  pop rbp
%endmacro
