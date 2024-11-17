; Basic ASM based boot sector for EwOS
; EwoFluffy - 2024

; Directive : To the assembler | Intruction : converted to machine code

org 0x7C00 ; Tell the assembler that the code is gonna be loaded at this adress (7C00) | Directive
bits 16 ; Tell the assembler that the code is gonna be 16 bits (Start in 16 bits mode to backward compatibility with 8086) | Directive

; Set a macro for the end of the line => Simpler to use it in the program
%define LINE_END 0x0D, 0x0A

; Add important things to make the bootloader usable with FAT12 => FAT12 Header
jmp short start ; Jump to the start label
nop ; No operation
%include 'src/bootloader/FileSystemDefine.asm' ; Include the file system define file

; mov ax, var => Copy the offset adress of var to ax
; mov ax, [var] => Copy the value of var to ax
; mov a, b is equivalent to a = b in C => move b to a
; mov => Move data from one place to another

start:
    jmp main ; Jump to the main function to prevent the CPU from executing the rest of the code

; .function => label for a function (like a sub-function)

; function to print a string on the screen
%include 'src/bootloader/Prints.asm'

main: ; Main function
    ; Setup the segments
    mov ax, 0 ; Set ax to 0 to make all other values to 0
    mov ds, ax ; Set the data segment to 0 => Useful to access the memory
    mov es, ax ; Same thing for the extra segment

    ; Setup the stack
    mov ss, ax ; Set the stack segment to ax (0)
    mov sp, 0x7C00 ; Set the stack pointer to 0x7C00 , the stacks grows downward so we set it to the start of the boot sector to prevent overwriting the code

    ; Clear the screen using the video services interrupt
    mov ah, 0x00 ; Set ah to 0x00 => Set video mode
    mov al, 0x03 ; Set al to 0x03 => Set video mode to 80x25 text mode , this will clear the screen
    int 0x10 ; Call the video services interrupt from BIOS

    ; Show the greetings using our function
    mov si, Greetings ; Set si to the adress of the greetings string
    call prints ; Call the prints function to print the greetings

    ; End of the boot sector code
    hlt ; Halt the CPU

.halt: ; Halt function
    jmp .halt ; Jump to the halt function

; db : Define byte directive


; Set the "variables"
Greetings: db 'Booting the Kernel...', LINE_END, 0 ; Don't use double quotes for strings in assembly and 0 is for signaling the end of the string

times 510-($-$$) db 0 ; Fill the rest of the sector with 0 ($-$$ = current position in the file) | Directive
dw 0xAA55 ; Boot signature | Directive
