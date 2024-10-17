all: LED_exec
debug: LED_execDB

LED_exec: LED_assembly.o
	ld -s -o LED_exec LED_assembly.o
	rm LED_assembly.o

LED_execDB: LED_assembly.o
	ld -s -o LED_execDB LED_assembly.o
	
LED_assembly.o: LED_assembly.s
	as LED_assembly.s -o LED_assembly.o
