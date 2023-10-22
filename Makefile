##
# ASCII to uppercase
#
# @file
# @version 0.1
uppercaser: uppercaser.o
		ld -o uppercaser uppercaser.o -melf_i386
uppercaser.o: uppercaser.asm
		nasm -f elf -g -F stabs uppercaser.asm -l uppercaser.lst



# end
