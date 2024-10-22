#!/bin/bash

if [ "$1" == "build" ]; then
    echo -e "\e[1m\e[34mBuilding bootloader\e[0m"
    echo -e "| \e[2;3mnasm src/bootloader/Main.asm -f bin -o build/bootloader.bin\e[0m"
    nasm src/bootloader/Main.asm -f bin -o build/bootloader.bin
    echo -e "\e[1m\e[32mBootloader built\e[0m"
    echo -e "\e[1m\e[34mBuilding kernel\e[0m"
    echo -e "| \e[2;3mnasm src/kernel/Main.asm -f bin -o build/kernel.bin\e[0m"
    nasm src/kernel/Main.asm -f bin -o build/kernel.bin
    echo -e "\e[1m\e[32mKernel built\e[0m"
    echo -e "\e[1m\e[34mSetup the virtual disk image\e[0m"
    echo -e '| \e[2;3mdd if="/dev/zero" of="build/Main.floppy.img" bs=512 count=2880\e[0m'
    dd if="/dev/zero" of="build/Main.floppy.img" bs=512 count=2880
    echo -e '| \e[2;3mmkfs.fat -F 12 -n "EwOS" build/Main.floppy.img\e[0m'
    mkfs.fat -F 12 -n "EWOSBOOTLDR" build/Main.floppy.img
    echo -e '| \e[2;3mdd if="build/bootloader.bin" of="build/Main.floppy.img" conv=notrunc\e[0m'
    dd if="build/bootloader.bin" of="build/Main.floppy.img" conv=notrunc
    echo -e '| \e[2;3mmcopy -i build/Main.floppy.img build/kernel.bin "::kernel.bin"\e[0m'
    mcopy -i build/Main.floppy.img build/kernel.bin "::kernel.bin"
    echo -e "\e[1m\e[32mBuilding complete\e[0m"
    echo ""
    echo -e "\e[1m\e[34mType 'sh ./ewos.sh run' to test it on Qemu\e[0m"
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
        echo -e "\e[1m\e[34mAdding files to the image\e[0m"
        echo -e '| \e[2;3mmcopy -i build/Main.floppy.img "$3"" "::$4"\e[0m'
        mcopy -i build/Main.floppy.img "$3" "::$4"
        echo -e "\e[1m\e[32mFiles added to the image\e[0m"
    fi
fi
if [ "$1" == "run" ]; then
    echo -e "\e[1m\e[34mRunning the OS\e[0m"
    echo -e "| \e[2;3mqemu-system-i386 -fda build/Main.floppy.img\e[0m"
    qemu-system-i386 -fda build/Main.floppy.img
fi
if [ "$1" == "test" ]; then
    echo -e "\e[1m\e[34mTesting the OS\e[0m"
    echo -e "| \e[2;3m./ewos.sh build/*\e[0m"
    ./ewos.sh build
    echo -e "| \e[2;3m./ewos.sh run/*\e[0m"
    ./ewos.sh run
fi
if [ "$1" == "clean" ]; then
    echo -e "\e[1m\e[34mCleaning up the build directory\e[0m"
    echo -e "| \e[2;3mrm -rf build/*\e[0m"
    rm -rf build/*
    echo -e "\e[1m\e[32mBuild directory cleaned up\e[0m"
fi

if [ "$1" == "" ]; then
    echo -e "\e[1m\e[34mUsage: ./ewos.sh [build|run|test|buildtools <tool>]\e[0m"
fi
