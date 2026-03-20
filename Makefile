all:	pong.o pong Makefile

pong.o:	pong.asm
	fasm pong.asm

pong:	pong.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 pong.o -o pong \
	-L./raylib-5.5_linux_amd64/ -l:libraylib.a \
	-lc -lm
