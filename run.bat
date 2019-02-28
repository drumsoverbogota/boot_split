rm boot.bin
rm floppy.img
nasm programa512.asm -f bin -o boot.bin
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=boot.bin of=floppy.img