#!/bin/bash

if [ "$1" == "build" ]; then
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
fi
if [ "$1" == "buildtools" ]; then
    if [ "$2" == "fat"]; then
        echo Building FAT12 tools
        mkdir -p build/tools
        gcc src/tools/fat12.c -o build/tools/fat12
    fi
fi
if [ "$1" == "run" ]; then
    echo Running the OS
    qemu-system-i386 -fda build/Main.floppy.img
fi
if [ "$1" == "test" ]; then
    echo Testing the OS
    ./ewos.sh build
    ./ewos.sh run
fi
if [ "$1" == "clean" ]; then
    echo Cleaning the build directory
    rm -rf build/*
fi

if [ "$1" == "" ]; then
    echo "Usage: ./ewos.sh [build|run|test|buildtools <tool>]"
fi
