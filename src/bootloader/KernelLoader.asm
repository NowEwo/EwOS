find_file:
    ; Placeholder: Search for a file in the root directory
    ret

load_file_clusters:
    ; Placeholder: Load file content from disk using FAT table
    ret

load_kernel:

    RootCluster dd 0 ; Store the root directory's cluster number

    ; Read FAT32 BPB and locate the kernel file
    mov ax, 0x0000
    mov bx, 0x7E00
    call disk_read

    mov ax, [bx + BPB_BytsPerSec]
    mov [BytesPerSector], ax
    mov al, [bx + BPB_SecPerClus]
    mov [SectorsPerCluster], al
    mov ax, [bx + BPB_RsvdSecCnt]
    mov [ReservedSectors], ax
    mov ax, [bx + BPB_FATSz32]
    mov [SectorsPerFAT], ax
    mov eax, [bx + BPB_RootClus]
    mov [RootCluster], eax

    mov eax, [RootCluster]
    call find_file
    mov di, 0x1000
    call load_file_clusters
    ret