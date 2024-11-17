disk_read:
    ; Inputs: AX = sector number, ES:BX = buffer address
    ; Description: Reads a single sector from the disk
    push ax         ; Save AX
    push bx         ; Save BX
    push cx         ; Save CX
    push dx         ; Save DX

    mov ah, 0x02    ; BIOS read sector function
    mov al, 0x01    ; Read 1 sector
    mov ch, 0x00    ; Cylinder number (high bits in CH)
    mov cl, [sector_low] ; Sector number (low bits in CL)
    mov dh, 0x00    ; Head number
    mov dl, 0x80    ; Drive number (e.g., 0x80 for the first hard drive)
    int 0x13        ; Call BIOS interrupt to read disk

    jc .error       ; Jump if carry flag is set (error occurred)

    pop dx          ; Restore DX
    pop cx          ; Restore CX
    pop bx          ; Restore BX
    pop ax          ; Restore AX
    ret             ; Return from function

.error:
    mov si, DiskErrorMsg ; Load the error message
    call prints          ; Print the error message
    jmp .halt            ; Halt the system

.halt:
    ret

DiskErrorMsg db 'Disk Read Error!', LINE_END, 0
