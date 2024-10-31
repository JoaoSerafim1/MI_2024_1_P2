all: teste

teste: Vlib.o test.o
	gcc Vlib.o test.o -o teste
	rm test.o
	rm Vlib.o
	
test.o: test.c
	gcc -c test.c -o test.o

Vlib.o: Vlib.s
	as Vlib.s -o Vlib.o
