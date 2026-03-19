all:	main.o main Makefile

main.o:	main.asm
	fasm main.asm

main:	main.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 main.o -o main \
	-L./raylib-5.5_linux_amd64/lib/ -l:libraylib.a \
	-lc -lm
