all: video_box
debug: video_boxDB

video_box: Vlib.o
	ld -s -o video_box Vlib.o
	rm Vlib.o

video_boxDB: Vlib.o
	ld -s -o video_boxDB Vlib.o
	
Vlib.o: Vlib.s
	as Vlib.s -o Vlib.o
