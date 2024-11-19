// Program that can read sectors from disk
// EwoFluffy 2024

ReadDisk:
    pusha ; Save registers
    push dx

    mov ah, 02h ; Read sector (can be 0x02 too)
    mov al, dl ; Number of sectors to read
    mov cl, 0x02 ; Cylinder number (0x01 is boot so we skip it)
    mov ch, 0x00 ; Track number
    mov dh, 0x00 ; Head number

    int 0x13 ; Call BIOS
    jc ReadDiskError ; If carry flag is set, error

    pop dx
    popa ; Restore registers
    ret

ReadDiskError:
    mov si, ErrorMessage ; Print error message
    call PrintString
    jmp $ ; Infinite loop

ErrorMessage db "ReadDisk: Error reading disk", 0x0A, 0x0D, 0
