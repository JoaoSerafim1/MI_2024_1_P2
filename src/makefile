all: tetrisg4

tetrisg4: Vlib.o game.o
	gcc Vlib.o game.o -o tetrisg4
	rm game.o
	rm Vlib.o
	
game.o: game.c
	gcc -c game.c -o game.o

Vlib.o: Vlib.s
	as Vlib.s -o Vlib.o
