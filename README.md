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

Para executar o programa, utilize um dos arquivo makefile também disponíveis; No diretório principal do projeto (ou ainda, caso isso resulte em falha, no diretório "src" que contém os arquivos citados anteriormente), execute os seguintes comandos no terminal linux:

- make all
  
###### (Cria o executável do jogo utilizando as bibliotecas nativas e implementadas.)

- sudo ./tetrisg4

###### (Executa o jogo.)

## Funções da biblioteca

#### DP (Definição de Polígono)

Essa função permite que seja desehado um polígono bidimensional na tela, mais especificamnte um quadrado ou um triângulo. A função recebe os seguintes parâmetros: coordenada x do polígono, coordenada y o polígono, código RGB da cor do polígono, formato do polígono (0 é quadrado, 1 é triângulo) e tamanho (0-15).

#### WBM (Escrita na Memória de Background)
