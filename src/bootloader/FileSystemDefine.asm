; Definitions of the file system header for the EwOS disk
; EwoFluffy 2024

OEMLabel db 'MSWIN4.1' ; OEM Label                    => 8 bytes and it's MSWIN4.1 because it's the only one that worked for me
BytesPerSector dw 512 ; Bytes per sector              => 512 bytes
SectorsPerCluster db 1 ; Sectors per cluster          => 1 sector
ReservedSectors dw 1 ; Reserved sectors               => 1 sector for the boot sector
NumberOfFATs db 2 ; Number of FATs                    => 2
RootEntries dw 224 ; Root entries                     => 224 entries
TotalSectors dw 2880 ; Total sectors                  => 1.44 MB
Media db 0xF0 ; Media                                 => 3.5" floppy disk
SectorsPerFAT dw 9 ; Sectors per FAT                  => 9 sectors
SectorsPerTrack dw 18 ; Sectors per track             => 18 sectors
Heads dw 2 ; Number of heads                          => 2
HiddenSectors dd 0 ; Hidden sectors                   => 0
TotalSectorsLarge dd 0 ; Total sectors large          => 0
; Extended boot record                                => used to store more informations about the disk
DriveNumber db 0 ; Drive number                       => the boot drive so 0
db 0 ; Reserved byte                                  => 0
Signature db 0x29 ; Signature                         => 0x29 used to signal that the next 3 fields are present
VolumeID db 0x01, 0x00, 0x00, 0x01 ; Volume ID        => Serial number of the volume so 0x01000001
VolumeLabel db 'EWOFLUFFY  OS', 0 ; Volume label      => 11 bytes
FileSystem db 'FAT12   ', 0 ; File system             => 8 bytes
