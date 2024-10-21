echo Building bootloader
nasm src/bootloader/Main.asm -f bin -o build/bootloader.bin
echo Building kernel
nasm src/kernel/Main.asm -f bin -o build/kernel.bin
echo Setup the virtual disk image
dd if="/dev/zero" of="build/Main.floppy.img" bs=512 count=2880
mkfs.fat -F 12 -n "EwOS" build/Main.floppy.img
dd if="build/bootloader.bin" of="build/Main.floppy.img" conv=notrunc
mcopy -i build/Main.floppy.img build/kernel.bin "::kernel.bin"
echo Building complete
