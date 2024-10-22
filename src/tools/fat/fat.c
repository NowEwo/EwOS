#include <ctype.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>

typedef uint8_t bool;
#define true 1
#define false 0

typedef struct {
    uint8_t BootJumpInstruction[3];
    uint8_t OemIdentifier[8];
    uint16_t BytesPerSector;
    uint8_t SectorsPerCluster;
    uint16_t ReservedSectors;
    uint8_t FatCount;
    uint16_t DirEntryCount;
    uint16_t TotalSectors;
    uint8_t MediaDescriptorType;
    uint16_t SectorsPerFat;
    uint16_t SectorsPerTrack;
    uint16_t Heads;
    uint32_t HiddenSectors;
    uint32_t LargeSectorCount;

    // extended boot record
    uint8_t DriveNumber;
    uint8_t _Reserved;
    uint8_t Signature;
    uint32_t VolumeId;          // serial number, value doesn't matter
    uint8_t VolumeLabel[11];    // 11 bytes, padded with spaces
    uint8_t SystemId[8];

} __attribute__((packed)) BootSector;

typedef struct {
    uint8_t Name[11];
    uint8_t Attributes;
    uint8_t _Reserved;
    uint8_t CreationTimeTenths;
    uint16_t CreationTime;
    uint16_t CreationDate;
    uint16_t LastAccessDate;
    uint16_t FirstClusterHigh;
    uint16_t LastWriteTime;
    uint16_t LastWriteDate;
    uint16_t FirstClusterLow;
    uint32_t FileSize;
} __attribute__((packed)) Directory;

BootSector boot_sector;

uint8_t* FileAllocationTable = NULL;
Directory* RootDir = NULL;

uint32_t RootDirEnd;

bool ReadBootSector(FILE* Disk) {
    return fread(&boot_sector, sizeof(boot_sector), 1, Disk) > 0;
}

bool ReadSectors(FILE* disk, uint32_t lba, uint32_t count, void* bufferOut) {
    bool state = true;
    if (fseek(disk, lba * boot_sector.BytesPerSector, SEEK_SET) != 0) {
        fprintf(stderr, "Error: Unable to seek to sector %d\n", lba);
        state = false;
    }
    if (fread(bufferOut, boot_sector.BytesPerSector, count, disk) != count) {
        fprintf(stderr, "Error: Unable to read %d sectors\n", count);
        state = false;
    }
    return state;
}

bool ReadFileAllocationTable(FILE* disk) {
    FileAllocationTable = (uint8_t*) malloc(boot_sector.SectorsPerFat * boot_sector.BytesPerSector);
    return ReadSectors(disk, boot_sector.ReservedSectors, boot_sector.SectorsPerFat, FileAllocationTable);
}

bool ReadRootDir(FILE* disk) {
    uint32_t lba = boot_sector.ReservedSectors + (boot_sector.FatCount * boot_sector.SectorsPerFat);
    uint32_t size = boot_sector.DirEntryCount * sizeof(Directory);
    uint32_t sectors = size / boot_sector.BytesPerSector;
    if (size % boot_sector.BytesPerSector > 0) {
        sectors++;
    }
    RootDirEnd = lba + sectors;
    RootDir = (Directory*) malloc(size);
    return ReadSectors(disk, lba, sectors, RootDir);  // Pass correct sector count
}

bool ReadFile(Directory FileEntry, FILE* disk, uint8_t* OutputBuffer){
    uint16_t currentCluster = FileEntry.FirstClusterLow;
    bool ok = true;
    do {
        uint32_t lba = boot_sector.ReservedSectors + (boot_sector.FatCount * boot_sector.SectorsPerFat) + (currentCluster - 2) * boot_sector.SectorsPerCluster;
        ok = ok && ReadSectors(disk, lba, boot_sector.SectorsPerCluster, OutputBuffer);
        OutputBuffer += boot_sector.SectorsPerCluster * boot_sector.BytesPerSector;

        uint32_t FATINDEX = currentCluster * 3 / 2;
        if(FATINDEX % 2 == 0){
            currentCluster = (FileAllocationTable[FATINDEX] | (FileAllocationTable[FATINDEX + 1] & 0x0F) << 8);
        } else {
            currentCluster = (FileAllocationTable[FATINDEX] >> 4) | (FileAllocationTable[FATINDEX + 1] << 4);
        }
    } while (ok && currentCluster < 0x0FF8);

    return ok;
}

Directory* FindFileInRootDir(const char* filename) {
    char formattedName[12]; // 11 + null terminator
    memset(formattedName, ' ', 11); // Fill with spaces
    strncpy(formattedName, filename, strlen(filename)); // Copy filename into formattedName

    for (uint32_t i = 0; i < boot_sector.DirEntryCount; i++) {
        if (memcmp(formattedName, RootDir[i].Name, 11) == 0) {
            return &RootDir[i];
        }
    }
    return NULL;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        printf("Usage: %s <file> <cluster>\n", argv[0]);
        return -1;
    }

    FILE* disk_file = fopen(argv[1], "rb");
    if (disk_file == NULL) {
        printf("Error: Unable to open disk file\n");
        return -1;
    }

    if (!ReadBootSector(disk_file)) {
        fprintf(stderr, "Could not read boot sector");
        fclose(disk_file);
        return -2;
    }

    if (!ReadFileAllocationTable(disk_file)) {
        fprintf(stderr, "Could not read file allocation table");
        free(FileAllocationTable);
        fclose(disk_file);
        return -3;
    }

    if (!ReadRootDir(disk_file)) {
        fprintf(stderr, "Could not read root directory");
        free(FileAllocationTable);
        free(RootDir);
        fclose(disk_file);
        return -4;
    }


    for (uint32_t i = 0; i < boot_sector.DirEntryCount; i++) {
        if (RootDir[i].Name[0] == 0x00) {
            break;  // Fin des entrées du répertoire
        }
        if (RootDir[i].Name[0] == 0xE5) {
            continue;  // Entrée supprimée
        }
        printf("File %d: %.11s\n", i, RootDir[i].Name);  // Affiche le nom du fichier en format FAT12
    }

    Directory* File = FindFileInRootDir(argv[2]);
    if (!File) {
        fprintf(stderr, "File not found\n");
        free(FileAllocationTable);
        free(RootDir);
        fclose(disk_file);
        return -5;
    }

    uint8_t* FileBuffer = (uint8_t*) malloc(File->FileSize + boot_sector.BytesPerSector);
    if (!ReadFile(*File, disk_file, FileBuffer)) {
        fprintf(stderr, "Could not read file\n");
        free(FileBuffer);
        free(FileAllocationTable);
        free(RootDir);
        fclose(disk_file);
        return -6;
    }

    for (uint32_t i = 0; i < File->FileSize; i++) {
        if(isprint(FileBuffer[i])){
            putc(FileBuffer[i], stdout);
        }else{
            printf("<%02x>", FileBuffer[i]);
        }
    }
    printf("\n");


    free(FileAllocationTable);
    free(RootDir);
    fclose(disk_file);  // Ensure disk file is closed

    return 0;
}
