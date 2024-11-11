all: tetrisg4

tetrisg4: vlibo gameo
	gcc ./src/.vlib.o ./src/game.o -o tetrisg4 -lpthread
	rm ./src/vlib.o
	rm ./src/game.o

vlibo:
	as ./src/vlib.s -o ./src/vlib.o

gameo:
	gcc -c ./src/game.c -o ./src/game.o -lpthread
