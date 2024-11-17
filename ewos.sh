#!/bin/bash

Message(){
    if [ "$1" == "t" ]; then
        echo -e "\e[1m\e[34m$2\e[0m"
    fi
    if [ "$1" == "s" ]; then
        echo -e "\e[1m\e[32m$2\e[0m"
    fi
    if [ "$1" == "i" ]; then
        echo -e "\e[1m\e[34m$2\e[0m"
    fi
}

CommandVerbose()
{
    echo -e "| \e[2;3m$1\e[0m"
}

if [ "$1" == "build" ]; then
    Message t "Building bootloader"
    CommandVerbose "nasm src/bootloader/Main.asm -f bin -o build/bootloader.bin"
    nasm src/bootloader/Main.asm -f bin -o build/bootloader.bin
    Message t "Building kernel"
    CommandVerbose "nasm src/kernel/Main.asm -f bin -o build/kernel.bin"
    nasm src/kernel/Main.asm -f bin -o build/kernel.bin
    CommandVerbose "if=/dev/zero of=build/Main.floppy.img bs=512 count=2880"
    dd if=/dev/zero of=build/Main.floppy.img bs=512 count=2880
    CommandVerbose "dd if=build/bootloader.bin of=build/Main.floppy.img bs=512 count=1 conv=notrunc"
    dd if=build/bootloader.bin of=build/Main.floppy.img bs=512 count=1 conv=notrunc
    CommandVerbose "dd if=kernel.bin of=build/Main.floppy.img bs=512 seek=1 conv=notrunc"
    dd if=build/kernel.bin of=build/Main.floppy.img bs=512 seek=1 conv=notrunc
    Message s "Building complete"

fi
if [ "$1" == "buildtools" ]; then
    if [ "$2" == "fat" ]; then
        echo -e "\e[1m\e[34mBuilding FAT12 Tools\e[0m"
        echo -e "| \e[2;3mmkdir -p build/tools\e[0m"
        mkdir -p build/tools
        echo -e "| \e[2;3mgcc src/tools/fat/fat.c -o build/tools/fat\e[0m"
        gcc src/tools/fat/fat.c -o build/tools/fat
        echo -e "\e[1m\e[32mFAT12 Tools built\e[0m"
    fi
fi
if [ "$1" == "img" ]; then
    if [ "$2" == "add" ]; then
        message t "Adding files to the image"
        CommandVerbose 'mcopy -i build/Main.floppy.img "$3"" "::$4"'
        mcopy -i build/Main.floppy.img "$3" "::$4"
        message s "Files added to the image"
    fi
fi
if [ "$1" == "run" ]; then
    Message t "Running the OS"
    CommandVerbose "qemu-system-i386 -drive file=build/Main.floppy.img,format=raw"
    qemu-system-i386 -drive file=build/Main.floppy.img,format=raw
fi
if [ "$1" == "test" ]; then
    message t "Testing the OS"
    CommandVerbose "./ewos.sh build"
    ./ewos.sh build
    CommandVerbose "./ewos.sh run"
    ./ewos.sh run
fi
if [ "$1" == "clean" ]; then
    Message t "Cleaning up the build directory"
    CommandVerbose "rm -rf build/*"
    rm -rf build/*
    Message s "Build directory cleaned up"
fi

if [ "$1" == "" ]; then
    Message t "Usage: ./ewos.sh [build|run|test|clean|img <action>|buildtools <tool>]"
fi
