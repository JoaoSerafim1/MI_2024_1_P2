all: tetrisg4

tetrisg4: vlib.o prplib.o game.o
	gcc vlib.o game.o -o tetrisg4 -lpthread
	rm vlib.o
	rm game.o

vlib.o: vlib.s
	as vlib.s -o vlib.o

game.o: game.c
	gcc -c game.c -o game.o -lpthread
