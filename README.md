![EwOS Banner Image](https://github.com/user-attachments/assets/c6d65ddc-cbc1-4a93-9483-3db905cc264d)
![Disclaimer Text Image](https://github.com/user-attachments/assets/48e36d74-cab9-4e88-930a-6b0d7e1e0804)

# EwOS
## Build
### Linux :
Requirements :
- `nasm` for assemble the bootloader and kernel
- `dd` , ~~`mkfs`~~ and ~~`mtools`~~ for setup the virtual disk
- `sh` for executing the programs
### MacOS :
All the linux requirements and :
- `brew` for installing all neccesary tools
### Windows :
All the linux requirements but :
- `Windows Subsystem for Linux` to have compatibility with all these tools

Run `sh ./ewos.sh build` in your terminal and wait

## Run
Requirements :
- `qemu` , `VirtualBox` , `VMWare` or any other virtualisation tool
- `Main.floppy.img` image that you have to build

### Qemu
Simply run `qemu-system-i386 -drive file=build/Main.floppy.img,format=raw` or `sh ./ewos.sh run`

### VirtualBox , VMWare or others
Go to your VM settings and set the floppy image to your built image
