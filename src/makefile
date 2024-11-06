all: tetrisg4

test: test_sprite

tetrisg4: vlib.o game.o
	gcc vlib.o game.o -o tetrisg4 -lpthread
	rm vlib.o
	rm game.o

test_sprite: vlib.o teste.o
	gcc vlib.o teste.o -o test_sprite
	rm vlib.o
	rm teste.o

vlib.o: vlib.s
	as vlib.s -o vlib.o

game.o: game.c
	gcc -c game.c -o game.o -lpthread

teste.o: teste.c
	gcc -c teste.c -o teste.o
