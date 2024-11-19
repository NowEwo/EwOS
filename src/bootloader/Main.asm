org 0x7C00
bits 16

%define LINE_END 0x0A, 0x0D

jmp start
nop

sector_low db 1 ; Define sector number for `disk_read`

%include "src/bootloader/FileSystemDefine.asm"
; %include "src/bootloader/DiskIO.asm"
%include "src/bootloader/Prints.asm"
%include "src/bootloader/KernelLoader.asm"

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

    mov ah,2 ; Bios service to cursor move mode
    mov dl,0 ; Column
    mov dh,1 ; Row
    int 0x10

    ; Print a loading message
    mov si, BootingMessage
    call prints

.halt:
    hlt
    jmp .halt

Greetings db 'EwOS Kernel | Ewo (c) 2024', LINE_END
BootingMessage db 'Booting the kernel...', LINE_END

times 510-($-$$) db 0
dw 0xAA55
