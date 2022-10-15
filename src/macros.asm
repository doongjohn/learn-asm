FD_STDIN equ 0
FD_STDOUT equ 1
FD_STDERR equ 2

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60


section .rodata
  newline db 10
  seq_clear db 0x1b, "[H", 0x1b, "[J" ; https://stackoverflow.com/a/50482672
  seq_clear_len equ $ - seq_clear


%macro sys_exit 1
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro


; args
; mov rsi, cmd
; mov rdx, arg (ptr)
%macro sys_ioctl 0
  mov rax, 16 ; syscall id
  mov rdi, FD_STDOUT
  syscall
%endmacro


; mov rsi, text
; mov rdx, text_length
%macro sys_write 0
  mov rax, FD_STDOUT
  mov rdi, SYS_WRITE
  syscall
%endmacro


%macro print_strlit 1
section .rodata
  %%str db %1
  %strlen %%len %1

section .text
  mov rsi, %%str
  mov rdx, %%len
  sys_write
%endmacro


%macro println_strlit 1
section .rodata
  %%str db %1, 10
  %strlen %%len %1

section .text
  mov rsi, %%str
  mov rdx, %%len + 1
  sys_write
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
  sys_write

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

  mov rsi, rsp ; rsi (ptr)
  add byte [rsi], '0' ; '0' == 48 add 48
  mov rdx, 1
  sys_write

  mov rsp, rbp
  pop rbp
%endmacro


%macro print_newline 0
  mov rsi, newline
  mov rdx, 1
  sys_write
%endmacro


%macro print_uint 2
  push rbp
  mov rbp, rsp

  push rax
  mov rax, %2 ; the number to print

  ; create bit mask
  push rax
  mov al, 8
  sub al, %1
  mov cl, 8
  mul cl
  mov cl, al
  pop rax
  mov rdx, 0xffffffffffffffff
  shr rdx, cl
  ; remove unwanted bits
  and rax, rdx

  push r8
  mov r8, 0 ; index

%%loop:
  inc r8 ; increase index

  mov rdx, 0 ; if rdx is not zero then it will be concated with rax when `div` is called
  mov rbx, 10
  div rbx ; this will do (rax = rax / rbx)
  ; quotient is stored in the `rax`
  ; remainder is stored in the `rdx`

  sub rsp, 1 ; allocate 1 byte in the stack
  ; more about stack allocation:
  ; https://stackoverflow.com/questions/1018853/why-is-the-use-of-alloca-not-considered-good-practice
  ; https://www.reddit.com/r/cpp_questions/comments/dui3de/why_are_stack_frames_fixed_size/
  mov byte [rsp], dl ; dl = 8bit rdx
  add byte [rsp], '0'

  cmp rax, 0
  jne %%loop
  ; end of loop

  ; write number
  mov rsi, rsp ; rsi: ptr
  mov rdx, r8
  sys_write

  ; restore state
  pop r8
  pop rax

  ; restore stack pointer
  mov rsp, rbp
  pop rbp
%endmacro


%macro print_int 2
  push rbp
  mov rbp, rsp

  push rax
  mov rax, %2 ; the number to print

  push r8
  mov r8, 0 ; index

  push r9
  mov r9, 0 ; sign
            ; 0 => positive
            ; 1 => negative

  inc r8 ; increase index

  bt rax, 63 ; check sign bit and set the cflag
  jnc %%rax_is_now_positive ; rax is positive
  mov r9, 1 ; rax is negative
  ; convert the value to positive number
  ; two's complement
  not rax
  inc rax

%%rax_is_now_positive
  ; save state
  push rax
  push rcx; cl
  ; create bit mask
  mov al, 8
  sub al, %1
  mov cl, 8
  mul cl
  mov cl, al
  ; restore state
  pop rcx
  pop rax
  mov rdx, 0xffffffffffffffff
  shr rdx, cl
  ; remove unwanted bits
  and rax, rdx

%%loop
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
  sys_write

  ; restore state
  pop r9
  pop r8
  pop rax

  ; restore stack pointer
  mov rsp, rbp
  pop rbp
%endmacro


%macro term_clear 0
  mov rsi, seq_clear
  mov rdx, seq_clear_len
  sys_write
%endmacro


%macro term_gotoxy 2
  print_char 0x1b
  print_char '['
  print_uint 8, %2
  print_char ';'
  print_uint 8, %1
  print_char 'f'
%endmacro
