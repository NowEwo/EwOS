; Basic ASM based boot sector , EwoFluffy - 2024

; Directive : To the assembler | Intruction : converted to machine code

org 0x7C00 ; Tell the assembler that the code is gonna be loaded at this adress (7C00) | Directive
bits 16 ; Tell the assembler that the code is gonna be 16 bits (Start in 16 bits mode to backward compatibility with 8086) | Directive

; Set a macro for the end of the line => Simpler to use it in the program
%define LINE_END 0x0D, 0x0A

; Add important things to make the bootloader usable with FAT12 => FAT12 Header
jmp short start ; Jump to the start label
nop ; No operation
OEMLabel db 'MSWIN4.1' ; OEM Label => 8 bytes
BytesPerSector dw 512 ; Bytes per sector => 512 bytes
SectorsPerCluster db 1 ; Sectors per cluster => 1 sector
ReservedSectors dw 1 ; Reserved sectors => 1 sector for the boot sector
NumberOfFATs db 2 ; Number of FATs => 2
RootEntries dw 224 ; Root entries => 224 entries
TotalSectors dw 2880 ; Total sectors => 1.44 MB
Media db 0xF0 ; Media => 3.5" floppy disk
SectorsPerFAT dw 9 ; Sectors per FAT => 9 sectors
SectorsPerTrack dw 18 ; Sectors per track => 18 sectors
Heads dw 2 ; Number of heads => 2
HiddenSectors dd 0 ; Hidden sectors => 0
TotalSectorsLarge dd 0 ; Total sectors large => 0
; Extended boot record => used to store more informations about the disk
DriveNumber db 0 ; Drive number => the boot drive so 0
db 0 ; Reserved byte => 0
Signature db 0x29 ; Signature => 0x29 used to signal that the next 3 fields are present
VolumeID db 0x01, 0x00, 0x00, 0x01 ; Volume ID => Serial number of the volume so 0x01000001
VolumeLabel db 'EWOFLUFFY  OS', 0 ; Volume label => 11 bytes
FileSystem db 'FAT12   ', 0 ; File system => 8 bytes

; mov ax, var => Copy the offset adress of var to ax
; mov ax, [var] => Copy the value of var to ax
; mov a, b is equivalent to a = b in C => move b to a
; mov => Move data from one place to another

start:
    jmp main ; Jump to the main function to prevent the CPU from executing the rest of the code

; .function => label for a function (like a sub-function)

; function to print a string on the screen
prints:
    ; Save registers we have to modify so we can restore them later
    pusha ; Push all the registers to the stack => Equivalent to push ax, cx, dx, bx, sp, bp, si, di even if we don't use all of them (ax , si)

.loop: ; Loop for the prints function
    lodsb ; Increment the si register and load the value at the adress of si to al (Next character)

    ; Print the character in al
    ; Values to be set : AH = 0x0E (Teletype output) | AL = ASCII character to print | BH = Page number (0) | BL = Color of foreground
    ; Int 0x10 => Video services interrupt and int is not integer but interrupt
    mov ah, 0x0E ; Set ah to 0x0E => Teletype output
    mov bh, 0 ; Set bh to 0 => Page number
    int 0x10 ; Call the video services interrupt from BIOS

    ; Condition to check if the program is at the end of the string
    or al, al ; Check if al is 0 or null (End of the string) => if al = 0 or null so al or al is 0
    jz .done ; If al is 0 jump to the done label => Conditionnal jump

    jmp .loop ; continue the loop if al is not 0

.done: ; Done for the prints function
    popa ; Restore the registers as we saved them before
    ret ; Return to the main function

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

    ; Show the oops message using our function
    mov si, BootingMessage
    call prints

    ; End of the boot sector code
    hlt ; Halt the CPU

.halt: ; Halt function
    jmp .halt ; Jump to the halt function

; db : Define byte directive


; Set the "variables"
Greetings: db 'Welcome to the boot sector :3', LINE_END, 0 ; Don't use double quotes for strings in assembly and 0 is for signaling the end of the string
BootingMessage: db 'Booting the kernel ...', LINE_END, 0

times 510-($-$$) db 0 ; Fill the rest of the sector with 0 ($-$$ = current position in the file) | Directive
dw 0xAA55 ; Boot signature | Directive
