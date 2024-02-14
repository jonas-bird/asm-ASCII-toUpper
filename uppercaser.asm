; Executable name : uppercaser
; Version         : 1.0
; Typed Up        : 2023/10/22
; Last updated    : 2024/02/12
; Author          : Jeff Duntemann with error checking added by JBird
; Description     : Simple assembly app for Linux. Assembled with NASM 2.14
;
;Build using:
;    nasm -f elf -g -F stabs uppercaser.asm -l uppercaser.lst
;    ld -o uppercaser uppercaser.o -melf_i386

section .data                                   ; section containing initialized data
ErrorOpen:      db "Error opening file",10      ; Error msg if the file specified at
                                                ; runtime can't be opened
ErrorOpenLen:   equ $-ErrorOpen                 ; length of ErrorOpen (calculated at
                                                ; assemblytime)
ErrorWrite:     db "Error writing to file",10   ; Error msg for write errors
ErrorWriteLen:   equ $-ErrorWrite               ; Length of write error msg

section .bss
    Buff resb 1

section .data

section .text
    global _start

_start:
    nop                         ; This no-op is for debugger

Read:   mov eax,3               ; Specify sys_read call
        mov ebx,0               ; Specify File Descriptor 0: Standard In
        mov ecx,Buff            ; Pass address of the buffer to read into
        mov edx,1               ; Tell sys_read to read a single! FIX THIS
                                ; character from stdin
        int 80h                 ; Call sys_read

        cmp eax,0               ; Look at sys_read's return value
        je Exit                 ; Jump If Equal to 0 (EOF) to Exit
                                ;  OR fall through
        cmp eax,-1               ;  Look at sys_read's return value
        jle Openerr              ;  Jump if less than 0 to error handling
                                ;  OR fall through
        cmp byte [Buff],61h     ; Test input char agains lowercase 'a'
        jb Write                ; If below 'a' in ASCII, not lowercase
        cmp byte [Buff], 7Ah    ; Test input against lowercase 'z'
        ja Write                ; If above 'z' in ASCII, not lowercase
                                ; At this we have a lowercase character
        sub byte [Buff],20h     ; Subtract 20h from lowercase to get uppercase
                                ;
                                ; now we write char to stdout
Write:  mov eax,4               ; Specify sys_write call
        mov ebx,1               ; Specify File Descriptor 1 for stdout
        mov ecx, Buff           ; Pass address of the character to write
        mov edx, 1              ; Pass number of chars to write
        int 80h                 ; Call sys_write
        cmp eax,-1               ; Look at sys_write return value
        jle Writerr              ; Juml if less than 0 to error handling
        jmp Read                ; ...back to the beginning to get another character

Openerr:        mov ecx, ErrorOpen      ; Pass offset of the error msg
                mov edx, ErrorOpenLen   ; Pass the length of the error msg
                mov eax,4               ; Specify sys_write syscall
                mov ebx,2               ; Specify File Descriptor 2: Std Error
                int 80H                 ; Make syscall to output the error msg
                mov ebx,1               ; set return code of 1 to indicate an error
                mov eax,1               ; Code to exit Syscall
                int 80H                 ; Make kernel call to exit on error

Writerr:      mov ecx, ErrorWrite      ; Pass offset of the error msg
                mov edx, ErrorWriteLen   ; Pass the length of the error msg
                mov eax,4                ; Specify sys_write syscall
                mov ebx,2                ; Specify File Descriptor 2: Std Error
                int 80H                  ; Make syscall to output the error msg
                mov ebx,1                ; set return code of 1 to indicate an error
                mov eax,1                ; Code to exit Syscall
                int 80H                  ; Make kernel call to exit on error

Exit:   mov eax,1               ; Code for Exit Syscall
        mov ebx,0               ; Return a code of zero to *nix
        int 80H                 ; Make kernel call to exit program
