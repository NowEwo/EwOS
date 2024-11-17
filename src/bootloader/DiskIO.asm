disk_read:
    ; Inputs: AX = sector number, ES:BX = buffer address
    push ax bx cx dx         ; Save registers
    mov ah, 0x02             ; BIOS function: Read sectors
    mov al, 0x01             ; Number of sectors to read
    int 0x13                 ; BIOS interrupt
    jc .error                ; Jump if carry flag (error)

    pop dx cx bx ax          ; Restore registers
    ret

.error:
    ; Handle read error
    mov si, DiskErrorMsg
    call prints
    jmp .halt

DiskErrorMsg db 'Disk Read Error!', LINE_END, 0