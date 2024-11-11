# 💻 Problema 2 Sistemas Digitais - Biblioteca VGA

Com o objetivo de compreender o mapeamento de memória em uma arquitetua ARM, entender os princípios básicos da arquitetura da plataforma DE1-SOC e aplicar conhecimentos da interação hardware software através da programação em Assembly, foi desenvolida essa biblioteca com funções gráficas. Através de um processador gráfico, a biblioteca permite que o usuário exiba polígonos, sprites e modifique o fundo completamente ou em partes.

##### DEMO da aplicação utilizando a biblioteca da GPU:
https://github.com/JoaoSerafim1/MI_2024_1_P2/blob/main/media/tetris_wLib.mp4

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

Para executar o programa, utilize um dos arquivo makefile também disponíveis; No diretório principal do projeto (ou ainda, caso isso resulte em falha, no sub-diretório "src" que contém os arquivos citados anteriormente), execute os seguintes comandos no terminal linux:

- make all
  
###### (Cria o executável do jogo utilizando as bibliotecas nativas e implementadas.)

- sudo ./tetrisg4

###### (Executa o jogo.)

## Funções da biblioteca

#### WBR_SPRITE (Escrever em registrador de sprite)
```c
void WBR_SPRITE(unsigned int registrador, unsigned int offset, unsigned int x, unsigned int y, unsigned int sp);
```
Função utilizada para gravar informação nos registradores referentes aos sprite. A função recebe os seguintes parâmetros: número do registrador (1-32), offset (índice do sprite a ser considerado para a instrução, 0-31), coordenada x do sprite (0-639), coordenada y do sprite (0-479) e dígito de controle sp (0 para parar de exibir o sprite, 1 para exibir).

#### WBR_BACKGROUND (Escrever em registrador de background)
```c
void WBR_BACKGROUND(unsigned int rgb);
```
Função utilizada para gravar informação da cor de background (fundo) no registrador adequado (apenas o de número 0). A função recebe os seguintes parâmetros: código BGR da cor de fundo (0-511, 3 bits binarios para cada cor num total de 9 bits).

#### WBM (Escrita na Memória de Background)
```c
void WBM(unsigned int x, unsigned int y, unsigned int rgb);
```
Função que permite escrever na memória de background, que nada mais é que uma coleção de 4800 quadrados de 8x8 pixels na tela. A função recebe os seguintes parâmetros: índice x do bloco do background (0-80), índice y do bloco do background (0-59) e código BGR da cor do polígono (0-511, 3 bits binarios para cada cor num total de 9 bits).

#### WSM (Escrita na Memória de Sprites)
```c
void WSM(unsigned int endereco, unsigned int cor);
```
Função que permite escrever na memória de sprites, uma sequência de 12800 espaços de 9 bits de memória referentes às cores de cada um dos pixels dos 32 sprites de tamanho 20x20. A função recebe os seguintes parâmetros: endereço de memória (0-12799, percorrendo linha por linha e sprite por sprite cada um dos 32 sprites) e código BGR da cor do pixel (0-511, 3 bits binarios para cada cor num total de 9 bits).

#### DP (Definição de Polígono)
```c
void DP(unsigned int x, unsigned int y, unsigned int cor, unsigned int forma, unsigned int tamanho);
```
Essa função permite que seja desehado um polígono bidimensional na tela, mais especificamente um quadrado ou um triângulo. A função recebe os seguintes parâmetros: coordenada x do polígono (0-639), coordenada y do polígono (0-479), código BGR da cor do polígono (0-511, 3 bits binarios para cada cor num total de 9 bits) formato do polígono (0 é quadrado, 1 é triângulo) e tamanho (0-15), que é o múltiplo de 20 referente ao comprimento do(s) lado(s) reto(s) do polígono.

## Funções essenciais do sistema

#### MAP (Mapear Memória)
```c
void MAP();
```
Função que faz chamada de sistema para mapear o endereço de memória físico utilizado pela ponte FPGA-HPS a um endereço de memória virtual que poderá ser acessado pelas demais funções da biblioteca. É necessário que seja acionada em um programa ao menos uma vez antes de ser utilizada qualquer outra função. Devido à sua especificidade para sistema operacional Linux, é provável que exista a necessidade desta função ser reescrita caso a biblioteca seja utilizada em outro sistema operacional, mesmo que o processador permaneça o mesmo (obrigatório).

## Funções de acesso aos periféricos auxiliares

#### RDBT (Ler valor dos botões)
```c
int RDBT();
```
Função que lê e retorna o valor dos botões acoplados à placa DE1-SoC.

#### TNLD ("Ligar" LED)
```c
void TNLD(unsigned int indice_led, unsigned int valor_bit);
```
Função que define o valor dos segmentos de um dos 6 displays de 7 segmentos acoplados à placa DE1-SoC. A função recebe os seguintes parâmetros: índice do LED (qual dos displays será alterado, 0-5) e valor dos bits referentes aos segmentos (0-127, lembrando que os segmentos ficam ligados quando em nível lógico baixo).
