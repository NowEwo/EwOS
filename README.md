# EwOS
## Build
### Linux :
Requirements :
- `nasm` for assemble the bootloader and kernel
- `dd` , `mkfs` and `mtools` for setup the virtual disk
- `sh` for executing the programs
### MacOS :
All the linux requirements and :
- `brew` for installing all neccesary tools
### Windows :
All the linux requirements but :
- `Windows Subsystem for Linux` to have compatibility with all these tools

Run `sh build.sh` in your terminal and wait

## Run
Requirements :
- `qemu` , `VirtualBox` , `VMWare` or any other virtualisation tool
- `Main.floppy.img` image that you have to build

### Qemu
Simply run `qemu-system-i386 fda build/Main.floppy.img`

### VirtualBox , VMWare or others
Go to your VM settings and set the floppy image to your built image