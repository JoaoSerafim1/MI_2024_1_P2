all: tetrisg4

tetrisg4: vlib.o game.o
	gcc vlib.o game.o -o tetrisg4
	rm game.o
	rm vlib.o
	
game.o: game.c
	gcc -c game.c -o game.o -lintelfpgaup -lpthread

vlib.o: vlib.s
	as vlib.s -o vlib.o
