section .text
org 0x7C00                        ; Make the bootloader start at 0x7C00 for BIOS to load it

start:
    ; Set up the segment registers for real mode (16-bit)
    xor ax, ax                     ; Clear AX register (Basically a XOR with itself)
    mov ds, ax                     ; Set DS to 0x0000 (real mode memory setup)
    mov es, ax                     ; Set ES to 0x0000 (not strictly needed here but good practice)
    call clear_screen              ; Call the clear_screen function to clear the screen

main:
    ; Load the address of the message into SI to print it later
    mov si, EwOS_Splash
    call printf_loop               ; Call the print_message function to print the message
    mov si, NL                     ; Set SI to the new line character
    call printf_loop               ; Call the print_message function to print the new line character
    mov si, EwOS_Splash_B
    call printf_loop               ; Call the print_message function to print the bootloader size
    call setGdt
    call realmodeinit
    call load_kernel               ; Call the load_kernel function to load the kernel
    jmp inf_loop                   ; Jump to an infinite loop to avoid unexpected behavior

printf_loop:
    ; Print each character in the string using BIOS interrupt 0x10 (Video text output)
    mov ah, 0x0E                   ; Set AH register from AX to 0x0E (BIOS Video teletype output function)
    mov al, [si]                   ; Set AL register to the character in the message (pointed by SI)
    cmp al, 0                      ; Check if the character is null (end of the string ", 0")
    je done                        ; If null , jump to done
    int 0x10                       ; Call an BIOS video interrupt to print the character
    inc si                         ; Set SI to the next character in the message
    jmp printf_loop                ; Repeat the loop for the next character

clear_screen:
    ; Clear the screen using BIOS interrupt 0x10 (Video text output)
    mov ah, 0x00                   ; Set AH register from AX to 0x00 (BIOS Set video mode function)
    mov al, 0x03                   ; Set AL register to 0x03 (80x25 text mode)
    int 0x10                       ; Call an BIOS video interrupt to set the video mode

    gdtr DW 0 ; For limit storage
         DD 0 ; For base storage

setGdt:
    mov   ax, [esp + 4]
    mov   [gdtr], ax
    mov   eax, [esp + 8]
    mov   [gdtr + 2], eax
    lgdt  [gdtr]
    ret

realmodeinit:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    sti
    ret

done:
    ret                            ; Return to the BIOS
inf_loop:
    jmp inf_loop                   ; Halt here to avoid unexpected behavior (Executing the RAM)

load_kernel:
    ; Load the kernel from the disk to memory
    mov bx, 0x8000                  ; Set BX to 0x8000 (where the kernel will be loaded)
    mov ah, 0x02                    ; Set AH register from AX to 0x02 (BIOS Read sector function)
    mov al, 1                       ; Set AL register to 1 (number of sectors to read)
    mov ch, 0                       ; Set CH register to 0 (cylinder number)
    mov dh, 0                       ; Set DH register to 0 (head number)
    mov dl, 0x80                    ; Set DL register to 0x80 (boot drive number)
    int 0x13                        ; Call an BIOS disk interrupt to read the sector
    jc load_kernel                  ; If the carry flag is set, try again

    jmp 0x8000                      ; Jump to the kernel (0x8000) to start executing it

EwOS_Splash:
    db 'EwOS bootloader working', 0          ; Define message as a Null-terminated string
EwOS_Splash_B:
    dw 'Booting the kernel...' , 0           ; Calculate the bootloader size in bytes

NL:
    db 0x0A, 0x0D, 0x00                      ; New line character

times 510-($-$$) db 0              ; Fill the rest of the 512-byte boot sector to make it executable (512 bytes)
dw 0xAA55                          ; Boot signature (0xAA55) to the BIOS knows it's bootable
