# 💻 Problema 2 Sistemas Digitais - Biblioteca VGA

Com o objetivo de compreender o mapeamento de memória em uma arquitetua ARM, entender os princípios básicos da arquitetura da plataforma DE1-SOC e aplicar conhecimentos da interação hardware software através da programação em Assembly, foi desenvolida essa biblioteca com funções gráficas. Através de um processador gráfico, a biblioteca permite que o usuário exiba polígonos, sprites e modifique o fundo completamente ou em partes.

##### DEMO da aplicação utilizando a biblioteca da GPU:
https://github.com/user-attachments/assets/44bb90be-4ec5-40d9-a5e4-c849fa2916cb



## Requisitos
O projeto desenvolvido precisa atender a uma série de restrições e requisitos técnicos. A seguir, são detalhados os requisitos essenciais para a construção da solução:

- **Requisitos de linguagem:**
  - O código da biblioteca deve ser escrito em linguagem assembly. Isso implica que todas as funções e rotinas de baixo nível que compõem a biblioteca precisam ser implementadas utilizando as instruções de assembly do processador.
- **Funções da biblioteca:**
  - Todas as funções existentes no processador gráfico devem ser implementadas.
  - Essas funções devem ser projetadas para facilitar a interação com a GPU, possibilitando a criação e manipulação de elementos gráficos, como a renderização de imagens, animações, controle de resolução, cores e outros aspectos visuais essenciais para o funcionamento do jogo.
- **Implementação da biblioteca desenvolvida no jogo:**
  - A biblioteca deve fornecer interfaces de alto nível que permitam ao desenvolvedor focar na lógica do jogo, enquanto abstrai os detalhes de implementação gráfica de baixo nível

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

Cada função aqui desenvolvida segue uma sequência clara de passos: salvar o contexto, preparar os dados, verificar a fila, enviar os dados, e restaurar o contexto. A interação com o hardware é feita por meio dos barramentos DATA_A e DATA_B, e a comunicação com o sistema é controlada pelo registrador WRREG. A verificação da fila garante que os dados só sejam enviados quando o sistema estiver pronto para recebê-los. Esse padrão é repetido de forma consistente em todas as funções, assegurando uma operação sincronizada e eficiente.

#### WBR_SPRITE (Escrever em registrador de sprite)
```c
void WBR_SPRITE(unsigned int registrador, unsigned int offset, unsigned int x, unsigned int y, unsigned int sp);
```
Função utilizada para gravar informação nos registradores referentes aos sprite. A função recebe os seguintes parâmetros: número do registrador (1-32), offset (índice do sprite a ser considerado para a instrução, 0-31), coordenada x do sprite (0-639), coordenada y do sprite (0-479) e dígito de controle sp (0 para parar de exibir o sprite, 1 para exibir).

![WBR_SPRITE](https://github.com/user-attachments/assets/d0d4566a-745f-4b71-b3e3-8ba1ed8562e0)
*Formato da instrução WBR para sprites*

#### WBR_BACKGROUND (Escrever em registrador de background)
```c
void WBR_BACKGROUND(unsigned int rgb);
```
Função utilizada para gravar informação da cor de background (fundo) no registrador adequado (apenas o de número 0). A função recebe os seguintes parâmetros: código BGR da cor de fundo (0-511, 3 bits binarios para cada cor num total de 9 bits).

![WBR_BACKGROUND](https://github.com/user-attachments/assets/fb845a3e-3c8a-40e9-a1aa-5afc754857d0)
*Formato da instrução WBR para o background*

#### WBM (Escrita na Memória de Background)
```c
void WBM(unsigned int x, unsigned int y, unsigned int rgb);
```
Função que permite escrever na memória de background, que nada mais é que uma coleção de 4800 quadrados de 8x8 pixels na tela. A função recebe os seguintes parâmetros: índice x do bloco do background (0-80), índice y do bloco do background (0-59) e código BGR da cor do polígono (0-511, 3 bits binarios para cada cor num total de 9 bits).
![WBM](https://github.com/user-attachments/assets/be158dec-50ea-4b00-b189-143c8830f6aa)
*Formato da instrução WBM*

#### WSM (Escrita na Memória de Sprites)
```c
void WSM(unsigned int endereco, unsigned int cor);
```
Função que permite escrever na memória de sprites, uma sequência de 12800 espaços de 9 bits de memória referentes às cores de cada um dos pixels dos 32 sprites de tamanho 20x20. A função recebe os seguintes parâmetros: endereço de memória (0-12799, percorrendo linha por linha e sprite por sprite cada um dos 32 sprites) e código BGR da cor do pixel (0-511, 3 bits binarios para cada cor num total de 9 bits).

![WSM](https://github.com/user-attachments/assets/346e2cb3-58d6-4d2e-82fa-b73a97107498)
*Formato da instrução WSM*

#### DP (Definição de Polígono)
```c
void DP(unsigned int x, unsigned int y, unsigned int cor, unsigned int forma, unsigned int tamanho);
```
Essa função permite que seja desehado um polígono bidimensional na tela, mais especificamente um quadrado ou um triângulo. A função recebe os seguintes parâmetros: coordenada x do polígono (0-639), coordenada y do polígono (0-479), código BGR da cor do polígono (0-511, 3 bits binarios para cada cor num total de 9 bits) formato do polígono (0 é quadrado, 1 é triângulo) e tamanho (0-15), que é o múltiplo de 20 referente ao comprimento do(s) lado(s) reto(s) do polígono.

![DP](https://github.com/user-attachments/assets/4efe7e77-d87d-4bdd-9ee8-81f80a2b55fb)
*Formato da instrução DP*

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

## Recursos utilizados

Este projeto foi desenvolvido utilizando os seguintes recursos:

- **Placa DE1-Soc**: Utilizada como plataforma de desenvolvimento, com o processador gráfico desenvolvido por **Gabriel Sá Barreto**.
- **IDE e Ferramentas de Desenvolvimento**:
  - **Visual Studio Code**: Utilizado como ambiente de desenvolvimento para escrever e depurar o código.
- **Linguagens de Programação**:
  - **C**: Utilizado para a maior parte da lógica de programação do sistema.
  - **Assembly ARMv7**: Usado para criação da biblioteca com as funções presentes na GPU.
- **Ferramenta de Criação de Telas**:
  - **Piskel**: Utilizado para criar as tela inicial e a tela de "game over".

## Conclusão
Este projeto permitiu explorar o mapeamento de memória e a interação entre hardware e software em sistemas embarcados, utilizando a placa DE1-Soc e um processador gráfico desenvolvido por Gabriel Sá Barreto. A biblioteca gráfica criada oferece funções essenciais para manipulação de sprites, polígonos e o fundo da tela, implementadas em Assembly ARMv7, garantindo eficiência na comunicação com o hardware.

A biblioteca foi projetada de forma modular, permitindo fácil integração com jogos e outros sistemas. Ao abstrair a complexidade do acesso direto aos registradores, foi possível desenvolver soluções gráficas de maneira simples e eficiente. O projeto não apenas atingiu os objetivos iniciais, mas também aprofundou o entendimento sobre sistemas gráficos embarcados.
