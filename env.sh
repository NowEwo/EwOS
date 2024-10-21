alias build="sh build.sh"
alias run="qemu-kvm -fda build/Main.floppy.img"
alias test="build && run"
