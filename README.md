# Problema 2 Sistemas Digitais - Biblioteca VGA

Com o objetivo de compreender o mapeamento de memória em uma arquitetua ARM, entender os princípios básicos da arquitetura da plataforma DE1-SOC e aplicar conhecimentos da interação hardware software através da programação em Assembly, foi desenvolida essa biblioteca com funções gráficas.

## Como executar

O programa é compatível com linux, sendo desenvolvido para funcionar em uma máquina com processador ARM, mais especificamente numa placa DE1-SoC. Os arquivos do código, escrito em C estão disponíveis no diretório da aplicação. Sendo eles:

- vlib.s
###### (Arquivo da biblioteca implementada em Assembly.)

- vlib.h
###### (Arquivo header com as funções implementadas para uso em C.)

- game.c
###### (Arquivo do jogo implementado no problema anterior.)

- map.c
###### (Arquivo onde ficam as funções de mapeamento de memória e uso do acelerômetro.)

- address_map_arm.h
###### (Arquivo header com os endereços dos registradores usados.)

Para executar o programa, utilize o arquivo makefile também disponível; Em um diretório com os arquivos citados anteriormente, execute os seguintes comandos no terminal linux:

- make all
  
###### (Cria o executável do joo com a biblioteca.)

- sudo ./tetrisg4

###### (Executa o jogo.)
