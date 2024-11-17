org 0x1000
bits 16

%define LINE_END 0x0D, 0x0A

%include 'src/bootloader/Prints.asm'

start:
    mov si, KernelMessage
    call prints
    hlt

KernelMessage db 'Hello from EwOS Kernel', LINE_END, 0
