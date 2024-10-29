all: teste video_boxDB

teste: Vlib.o test.o
	gcc Vlib.o test.o -o teste

video_boxDB: Vlib.o
	ld -s -o video_boxDB Vlib.o
	
test.o: test.c
	gcc -c test.c -o test.o

Vlib.o: Vlib.s
	as Vlib.s -o Vlib.o
