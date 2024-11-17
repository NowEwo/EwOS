org 0x7C00
bits 16

%define LINE_END 0x0D, 0x0A

jmp start
nop

%include "src/bootloader/FileSystemDefine.asm"
%include "src/bootloader/DiskIO.asm"
%include "src/bootloader/Prints.asm"
%include "src/bootloader/KernelLoader.asm"

sector_low db 1 ; Define sector number for `disk_read`

start:
    ; Bootloader initialization code
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear the screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Print a loading message
    mov si, Greetings
    call prints

    ; Call kernel loader
    call load_kernel

    ; Jump to kernel
    jmp 0x0000:0x1000

.halt:
    hlt
    jmp .halt

Greetings db 'Loading EwOS Kernel...', LINE_END, 0

times 510-($-$$) db 0
dw 0xAA55
