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
