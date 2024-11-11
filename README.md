# 💻 Problema 2 Sistemas Digitais - Biblioteca VGA

Com o objetivo de compreender o mapeamento de memória em uma arquitetua ARM, entender os princípios básicos da arquitetura da plataforma DE1-SOC e aplicar conhecimentos da interação hardware software através da programação em Assembly, foi desenvolida essa biblioteca com funções gráficas. Através de um processador gráfico, a biblioteca permite que o usuário exiba polígonos, sprites e modifique o fundo completamente ou em partes.

## Como executar

O programa é compatível com linux, sendo desenvolvido para funcionar numa placa DE1-SoC com um processador gráfico embarcado, que é descrito no documento citado nas referências. Os arquivos, escritos em C e em Assembly estão disponíveis no diretório da aplicação. Sendo eles:

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
