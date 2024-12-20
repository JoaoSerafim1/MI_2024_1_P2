//Bibliotecas basicas do C
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <time.h>

//Biblioteca sys-time, implementada por padrao em LINUX e Windows
#include <sys/time.h>

//Biblioteca de criacao e gerenciamento de threads para Linux
#include <pthread.h>

//Biblioteca original de mapeamento da memoria do dispositivo DE1-SoC com Linux embutido
#include "map.c"

//Biblioteca original de controle da GPU customizada
#include "vlib.h"

//Funcoes separadas da tela
#include "startscreen.c"

int16_t X_inicial = 0;
int16_t aceleracaoX = 0;
int16_t aceleracaoY = 0;
int16_t aceleracaoZ = 0;

// Função para ler o acelerômetro em uma thread
void* ler_acelerometro(void* arg) {
    int16_t XYZ[3];

    int cont = 0;
    
    while (1) {
      ADXL345_XYZ_Read(XYZ);
      aceleracaoX = XYZ[0];
      aceleracaoY = XYZ[1];
      aceleracaoZ = XYZ[2];
      usleep(100000);

      //Atualiza a medicao do acelerometro ate 10x, para obter um valor inicial de X valido para uso
      if(cont<9) {
        X_inicial = aceleracaoX;
        cont++;
      } 
    }
    return NULL;
}

//Funcao para exibir o numero referente a pontuacao no display de 7 segmentos
void mostrar_numero(char* numero) {
  int str_size = strlen(numero);
  int cont0;
  
  //Repete para cada digito do display de 7 segmentos (indice 0 ao indice 5)
  for(cont0 = 0; cont0 < 6; cont0++) {
    //Inicialmente 127, ou seja 0b111111, o que faz com que todos os segmentos estejam desligados
    int indicador_binario = 127;

    //printf("%d\n", str_size);
    //printf("%d\n", cont0);

    //Se estiver em um indice correspondente a um digito valido
    if((cont0 + str_size) >= 6) {
      int digito = numero[(5 - cont0)];
      
      //De acordo com o digito na casa decimal atual, zera o bit referente ao segmento, o que faz com que este segmento fique ligado
      if(digito == '0' || digito == '2' || digito == '3' || digito == '5' || digito == '6' || digito == '7' || digito == '8' || digito == '9') {
        indicador_binario -= 1;
      }
      if(digito == '0' || digito == '1' || digito == '3' || digito == '4' || digito == '7' || digito == '8' || digito == '9') {
        indicador_binario -= 2;
      }
      if(digito == '0' || digito == '1' || digito == '3' || digito == '4' || digito == '5' || digito == '6' || digito == '7' || digito == '8' || digito == '9') {
        indicador_binario -= 4;
      }
      if(digito == '0' || digito == '2' || digito == '3' || digito == '5' || digito == '6' || digito == '8' || digito == '9') {
        indicador_binario -= 8;
      }
      if(digito == '0' || digito == '2' || digito == '6' || digito == '8') {
        indicador_binario -= 16;
      }
      if(digito == '0' || digito == '4' || digito == '5' || digito == '6' || digito == '8' || digito == '9') {
        indicador_binario -= 32;
      }
      if(digito == '2' || digito == '3' || digito == '4' || digito == '5' || digito == '6' || digito == '8' || digito == '9') {
        indicador_binario -= 64;
      }
    }

    //Manda a informacao para a funcao assembly que controla os displays de 7 segmentos
    TNLD(cont0, indicador_binario);
  }
}

//Funcao para zerar todos os digitos do display de 7 segmentos
void zerar_display_7seg() {
  int cont0;
  
  //Repete para cada digito do display de 7 segmentos (indice 0 ao indice 5)
  for(cont0 = 0; cont0 < 6; cont0++) {
    //Manda a informacao para a funcao assembly que controla os displays de 7 segmentos
    TNLD(cont0, 0);
  }
}

void preparar_sprites() {
  int cont0;
  int cont1;
  int corsprite;

  for(cont0 = 0; cont0 < 21; cont0++) {

      for(cont1 = 0; cont1 < 20; cont1++) {
          corsprite = 292;

          if((cont1 >= 3 && cont1 <= 7) || (cont1 >= 12 && cont1 <= 16)) {
              corsprite = 0;
          }
          
          WSM(((cont0 * 20) + cont1), corsprite);
      }
  }
}


//Funcao que preenche com 0 todas as celulas de uma matriz 10x24
void preenche_zero_10_x_24(int (*tela)[10][24]) {
  int cont0;
  int cont1;
  
  for(cont0 = 0; cont0 < 10; cont0++) {
    
    for(cont1 = 0; cont1 < 24; cont1++) {
      (*tela)[cont0][cont1] = 0;
    }
  }
}

//Funcao que preenche com 0 todas as celulas de uma matriz 4x4
void preenche_zero_4_x_4(int (*tela)[4][4]) {
    int cont0;
    int cont1;

  for(cont0 = 0; cont0 < 4; cont0++) {
    
    for(cont1 = 0; cont1 < 4; cont1++){
      (*tela)[cont0][cont1] = 0;
    }
  }
}


//Funcao que une (modifica matriz tela) uma matriz com posicao absoluta de tamanho 10x24 (estatico) com uma matriz com posicao relativa de tamanho 4x4 (peca em relacao a posx e posy)
void une_matriz(int (*tela)[10][24], int estatico[10][24], int peca[4][4], int posx, int posy) {
  int cont0;
  int cont1;

  for(cont0 = 0; cont0 < 10; cont0++) {
    
    for(cont1 = 0; cont1 < 24; cont1++){
      (*tela)[cont0][cont1] = estatico[cont0][cont1];
      
      if (((cont0 - posx) >= 0) && ((cont1 - posy) >= 0) && ((cont0 - posx) < 4) && ((cont1 - posy) < 4) && peca[(cont0 - posx)][(cont1 - posy)] != 0) {
        (*tela)[cont0][cont1] = peca[(cont0 - posx)][(cont1 - posy)];
      }
    }
  }
}


//Funcao que desenha uma matriz 10x24 em uma tela 640x480 (indexada em 80x60), centralizada na largura e altura da mesma
void desenha_matriz(int t[10][24]){
  int cont0;
  int cont1;
  int posx1;
  int posy1;
  int posx2;
  int posy2;

  for(cont0 = 0; cont0 < 10; cont0++) {
    
    for(cont1 = 0; cont1 < 24; cont1++){
      posx1 = ((cont0 * 2) + 30);
      posy1 = ((cont1 * 2) + 1);
      posx2 = (posx1 + 1);
      posy2 = (posy1 + 1);
      
      //Cinza
      if (t[cont0][cont1] == 0) {
        WBM(posx1, posy1, 292);
        WBM(posx1, posy2, 292);
        WBM(posx2, posy1, 292);
        WBM(posx2, posy2, 292);
      }
      //Vermelho
      else if(t[cont0][cont1] == 1) {
        WBM(posx1, posy1, 7);
        WBM(posx1, posy2, 7);
        WBM(posx2, posy1, 7);
        WBM(posx2, posy2, 7);
      }
      //Laranja
      else if(t[cont0][cont1] == 2) {
        WBM(posx1, posy1, 39);
        WBM(posx1, posy2, 39);
        WBM(posx2, posy1, 39);
        WBM(posx2, posy2, 39);
      }
      //Rosa
      else if(t[cont0][cont1] == 3) {
        WBM(posx1, posy1, 263);
        WBM(posx1, posy2, 263);
        WBM(posx2, posy1, 263);
        WBM(posx2, posy2, 263);
      }
      //Amarelo
      else if(t[cont0][cont1] == 4) {
        WBM(posx1, posy1, 63);
        WBM(posx1, posy2, 63);
        WBM(posx2, posy1, 63);
        WBM(posx2, posy2, 63);
      }
      //Verde
      else if(t[cont0][cont1] == 5) {
        WBM(posx1, posy1, 56);
        WBM(posx1, posy2, 56);
        WBM(posx2, posy1, 56);
        WBM(posx2, posy2, 56);
      }
      //Ciano
      else if(t[cont0][cont1] == 6) {
        WBM(posx1, posy1, 504);
        WBM(posx1, posy2, 504);
        WBM(posx2, posy1, 504);
        WBM(posx2, posy2, 504);
      }
      //Azul
      else if(t[cont0][cont1] == 7) {
        WBM(posx1, posy1, 448);
        WBM(posx1, posy2, 448);
        WBM(posx2, posy1, 448);
        WBM(posx2, posy2, 448);
      }
      //Magenta
      else if(t[cont0][cont1] == 8) {
        WBM(posx1, posy1, 455);
        WBM(posx1, posy2, 455);
        WBM(posx2, posy1, 455);
        WBM(posx2, posy2, 455);
      }
    }
  }
}

//Funcao que limpa a matriz da tela
void limpa_matriz() {
  int cont0;
  int cont1;

  for(cont0 = 0; cont0 < 10; cont0++) {
    
    for(cont1 = 0; cont1 < 24; cont1++){
      int posx1 = ((cont0 * 2) + 30);
      int posy1 = ((cont1 * 2) + 1);
      int posx2 = (posx1 + 1);
      int posy2 = (posy1 + 1);

      WBM(posx1, posy1, 510);
      WBM(posx1, posy2, 510);
      WBM(posx2, posy1, 510);
      WBM(posx2, posy2, 510);
    }
  }
}

//Funcao que exibe a pontuacao do jogador em uma tela 320x240, ao lado da matriz do jogo exibida na funcao anterior
void desenha_pontos(int pontos){
  
  //Converte int em array de caracteres de ate 32 caracteres (o que cabe na tela apartir da posicao inicial)
  char int_array[32];
  sprintf(int_array, "%d", pontos*100);

  mostrar_numero(int_array);

  //char mensagem_pontos[7] = "PONTOS:";
}

//Funcao que exibe a linha limite da colocacao das pecas e diz o estado do jogo caso esteja pausado ou seja "fim de jogo" em tela 640x480
void desenha_estado(int estado_jogo, int linha_limite) {
  int cont0;
  int posx1;
  int posx2;

  //Desenha a linha limite da area de jogo
  for(cont0 = 0; cont0 < 10; cont0++){
    posx1 = ((cont0 * 2) + 30);
    posx2 = (posx1 + 1);

    //Branco
    WBM(posx1, ((linha_limite * 2) + 2), 511);
    WBM(posx2, ((linha_limite * 2) + 2), 511);
  }

  //Exibe as mensagens de estado de jogo para "pausa" e "fim de jogo"
  if(estado_jogo == 1) {
    WBR_SPRITE(1, 0, 310, 160, 1);
  }
  else{
    WBR_SPRITE(1, 0, 300, 200, 0);
  }
  /*else if(estado_jogo == 3) {
    
    char mensagem_estado[11] = "FIM DE JOGO";
    video_text(35, 30, mensagem_estado);
  }

  video_show();
  video_clear();*/
}

//Funcao que consolida as funcoes de atualizacao da tela
void atualiza_tela(int estatico[10][24], int peca[4][4], int posx, int posy, int pontos, int estado_jogo, int linha_limite) {
  
  int tela[10][24];

  une_matriz(&tela, estatico, peca, posx, posy);

  desenha_matriz(tela);
  desenha_pontos(pontos);
  desenha_estado(estado_jogo, linha_limite);
  //printf("\nPONTOS: %d \n", pontos);
}


//Funcao que verifica a possibilidade de mover uma pecao de posicao
int mover(int estatico[10][24], int peca[4][4], int *posx, int *posy, int dx, int dy) {
  int cont0;
  int cont1;

  int result = 0;

  for(cont0 = 0; cont0 < 4; cont0++) {
    
    for(cont1 = 0; cont1 < 4; cont1++) {

      //Condicional para verificar se o bloco atual da peca, caso preenchido, "sai" do limite da tela apos o deslocamento
      //Se passar, significa que o movimento e impossivel
      if ((peca[cont0][cont1] != 0) && (((cont0 + (*posx) + dx) < 0) || ((cont1 + (*posy) + dy) < 0) || ((cont0 + (*posx) + dx) > 9) || ((cont1 + (*posy) + dy) > 23))) {
        result = 1;
      }
      //Condicional para verificar se o bloco atual da peca, caso preenchido, sobreporia os blocos ja estaticos apos o deslocamento
      //Se passar, significa que o movimento e impossivel
      else if ((peca[cont0][cont1] != 0) && (estatico[(cont0 + (*posx) + dx)][(cont1 + (*posy) + dy)] != 0)) {
        result = 1;
      }
    }
  }

  //Se nao houve obstrucao, ocorre o movimento (atualiza a posicao em relacao ao deslocamento requerido)
  if(result == 0) {
    *posx = (*posx + dx);
    *posy = (*posy + dy);
  }

  //Retorna se a operacao foi bem-sucedida (0) ou nao (1)
  return result;
}


//Funcao que detecta uma linha preenchida totalmente e apaga o conteudo
int implodir(int (*estatico)[10][24]) {
  int cont0;
  int cont1;

  //Percorre linha por linha, de cima a baixo
  for(cont1 = 0; cont1 < 24; cont1++) {
    int result = 0;
    int line = (23-cont1);

    //E coluna por coluna, da esquerda para a direita
    for(cont0 = 0; cont0 < 10; cont0++) {
      
      //Caso seja encontrado um espaco vazio na linha, sabemos que nao pode ser eliminada
      if((*estatico)[cont0][line] == 0) {
        result = 1;
      }
    }

    //Se nao existiram espacos vazios
    if(result == 0){
      
      //A linha sera eliminada
      for(cont0 = 0; cont0 < 10; cont0++) {
        (*estatico)[cont0][line] = 0;
      }

      return line;
    }
  }

  return (-1);
}

//Funcao que move para baixo as pecas acima da linha eliminada
int cascada(int (*estatico)[10][24], int inicio) {
  int cont0;
  int cont1;

  for(cont1 = (inicio - 1); cont1 >= 0; cont1--) {
    
    for(cont0 = 0; cont0 < 10; cont0++) {
      (*estatico)[cont0][(cont1 + 1)] = (*estatico)[cont0][cont1];
    }
  }

  return 0;
}


//Funcao que preenche os espacos da peca desejada
int gerar_peca(int (*peca)[4][4], int forma, int cor) {
  preenche_zero_4_x_4(peca);

  if(forma == 0) {
    (*peca)[0][0] = cor;
    (*peca)[0][1] = cor;
    (*peca)[1][0] = cor;
    (*peca)[1][1] = cor;
  }
  else if(forma == 1) {
    (*peca)[0][0] = cor;
  }
  else if(forma == 2) {
    (*peca)[0][0] = cor;
    (*peca)[0][1] = cor;
    (*peca)[0][2] = cor;
  }
  else if(forma == 3) {
    (*peca)[0][0] = cor;
    (*peca)[1][0] = cor;
    (*peca)[2][0] = cor;
  }
  else if(forma == 4) {
    (*peca)[0][0] = cor;
    (*peca)[0][1] = cor;
    (*peca)[1][1] = cor;
  }
  else if(forma == 5) {
    (*peca)[1][0] = cor;
    (*peca)[0][1] = cor;
    (*peca)[1][1] = cor;
  }
 
  return 0;
}

//Funcao que interpreta o movimento
//A direcao na verdade e a quantidade de ciclos necessarias desde a ultima movimentacao lateral com sinal indicando a real direcao do movimento
int ler_movimento() {

  //A direcao inicialmente e 0, mas pode mudar de acordo com a inclinado
  int direcao = 0;

  printf("X_INICIAL = %d, ", X_inicial);
  printf("X = %d, ", aceleracaoX);
  printf("Y = %d, ", aceleracaoY);
  printf("Z = %d\n", aceleracaoZ);
  
  //Decide a quantidade de ciclos necessarios para o proximo movimento, caso a inclinacao seja reconhecida como suficiente
  //As variaveis de inclinacao do dispositivo sao globais pois a biblioteca de criacao de threads nao permite passagem de argumentos facilmente 
  if((aceleracaoX >= (X_inicial + 30)) && (aceleracaoX < (X_inicial + 50))) {
    direcao = 50;
  }
  else if((aceleracaoX <= (X_inicial - 30)) && (aceleracaoX > (X_inicial - 50))) {
    direcao = -50;
  }
  else if((aceleracaoX >= (X_inicial + 50)) && (aceleracaoX < (X_inicial + 70))) {
    direcao = 35;
  }
  else if((aceleracaoX <= (X_inicial - 50)) && (aceleracaoX > (X_inicial - 70))) {
    direcao = -35;
  }
  else if((aceleracaoX >= (X_inicial + 70)) && (aceleracaoX < (X_inicial + 90))) {
    direcao = 20;
  }
  else if((aceleracaoX <= (X_inicial - 70)) && (aceleracaoX > (X_inicial - 90))) {
    direcao = -20;
  }

  return direcao;
}


//Funcao que le a entrada atual de chaves para controle do game
int ler_comando(estado_jogo) {

  int switch_value = RDBT();
  //usleep(500000);
  //int switch_value = 2;
  //Entrar em pausa
  if ((switch_value == 1) && (estado_jogo == 0)) {
    estado_jogo = 1;
  }//Sair da pausa
  else if ((switch_value == 1) && (estado_jogo == 1)) {
    estado_jogo = 0;
  } //Resetar
  else if ((switch_value == 2) || (switch_value == 3)) {
    estado_jogo = 2;
    limpa_matriz();
    //video_erase();

    return estado_jogo;
  }
}


//Desenha a tela inicial do jogo
int tela_inicial(){
  
  //Background
  WBR_BACKGROUND(511);
  limpa_matriz();
  WBR_SPRITE(1, 0, 300, 200, 0);
  zerar_display_7seg();
  display_inicial(1);
}


int main ( void ) {
    int fd = -1;
    int fd1 = -1;
    void *I2C0_virtual;
    int16_t XYZ[3];

    // Abrir /dev/mem e mapear a área de memória do I2C e do SYSMGR
    if ((fd = open_physical(fd)) == -1)
        return (-1);
    if (!(I2C0_virtual = map_physical(fd, I2C0_BASE, I2C0_SPAN)))
        return (-1);
    close_physical(fd);


   //Mapeamento de memória do I2C0
   I2C0_con = (int *) (I2C0_virtual + I2C0_CON);
   I2C0_tar = (int *) (I2C0_virtual + 0x4);
   I2C0_data = (int *) (I2C0_virtual + 0x10);
   I2C0_readbuffer = (int *) (I2C0_virtual + 0x78);
   I2C0_enable = (int *) (I2C0_virtual + 0x6C);
   I2C0_enable_sts = (int *) (I2C0_virtual + 0x9C);
   I2C0_fs_hcnt = (int *) (I2C0_virtual + 0x1C);
   I2C0_fs_lcnt = (int *) (I2C0_virtual + 0x20);

   //Mapear memória assembly
   MAP();

  //Inicializa o controlador I2C e configura a conexao entre o controlador I2C e o acelerometro ADXL345
  I2C0_init();

  //Inicializa e configura o acelerometro
  ADXL_345_init();
  
  //Calibra o acelerometro
  ADXL345_Calibrate();

  //Cria o thread de monitoramento do acelerometro, que constantemente atualiza os valores da medicao das inclinacoes X, Y e Z (medida em g referente a forca de aceleracao sentida em cada eixo)
  pthread_t thread_acelerometro;

    if (pthread_create(&thread_acelerometro, NULL, ler_acelerometro, NULL) != 0) {
            fprintf(stderr, "Erro ao criar a thread do acelerômetro\n");
            return 1;
    }

  //Matriz de objetos estaticos e peca em movimento, respectivamente
  int estatico[10][24];
  int peca[4][4];
  int Rst;

  //Linha limite (minima de cima para baixo) para colocacao das pecas
  int linha_limite = 7;

  //video_open();
  //video_erase();
  //Loop externo que serve para reiniciar o game caso o interno seja quebrado
  while(1 == 1) {
    
    //Inicia com 0 os espacos de jogo e da peca
    preenche_zero_10_x_24(&estatico);
    preenche_zero_4_x_4(&peca);

    //Configura os sprites
    preparar_sprites();

    //Contador de ciclos do game, usado para testes
    int cont = 0;

    //Posicao inicial da peca
    int posx = 4;
    int posy = 0;

    //Obtem o tempo em microsegundos e em segundos, para uso na seed do RNG do formato da peca e da cor
    struct timeval tempo;
    gettimeofday(&tempo, NULL);
    int tempo_preciso = tempo.tv_usec;
    int tempo_simples = tempo.tv_sec;
    
    //Gera um indice do formato da peca aleatorio
    srand (tempo_preciso);
    int rShape = (rand() % 6);
    
    //Gera um indice de cor aleatorio entre 1 e 9
    srand(tempo_simples);
    int rColor = ((rand() % 8) + 1);

    //"Cria" uma peca com as caracteristicas desejadas
    gerar_peca(&peca, rShape, rColor);

    //Contador de pontos
    int contador_pontos = 0;

    //Estado inicial do jogo
    int estado_jogo = 3;

    //Lê o botão de reset
    //Rst = ler_reset();
    //printf("Botao: %d", Rst);
    
    //Estrutura do intervalo de tempo para o sleep da aplicacao (periodo de 10,000,000 nanossegundos ou 10 milissegundos)
    struct timespec intervalo;
    intervalo.tv_sec = 0;
    intervalo.tv_nsec = 10000000;

     //Display inicial da tela
    tela_inicial();
    while (estado_jogo != 1){
      estado_jogo = ler_comando(estado_jogo);
      //Sleep de acordo com o clock da aplicacao
      nanosleep(&intervalo, NULL);
    }

    //Contador de ciclos para o "cooldown" da acao ocasionada por pressionar o botao
    int contador_botao = 0;
    //Contador de ciclos para o "cooldown" da acao de mover
    int contador_movimento = 10;

    //Variavel para determinar se esta sendo pedida exibicao do estado
    int quer_exibir_estado = 0;

    display_inicial(0);
    display_final(0);
    
    //Loop interno da sessao de jogo
    while(estado_jogo != 2) {
      
      //Sleep de acordo com o clock da aplicacao
      nanosleep(&intervalo, NULL);

      //Verifica se e valido atualizar o estado do jogo (passou tempo suficiente sem que um botao estivesse pressionado e existe botao pressionado atualmente)
      if ((contador_botao == 20) && (RDBT() != 0)) {
        
        //Atualiza o estado do jogo
        estado_jogo = ler_comando(estado_jogo);

        //Reseta o contador do "cooldown" do botao
        contador_botao = 0;
      }
      //Se nao for valido atualizar, verifica se nenhum botao esta sendo pressionado e se o contador ainda nao chegou no maximo
      else if ((contador_botao < 20) && (RDBT() == 0)) {

        //Aumenta o contador de "cooldown" dos botoes
        contador_botao += 1;
      }
      
      //printf("%d", estado_jogo);

      //Atualiza a tela caso o estado do jogo tenha mudado de rodando para pausa / game over
      if((quer_exibir_estado == 1) && (estado_jogo != 0)) {
        atualiza_tela(estatico, peca, posx, posy, contador_pontos, estado_jogo, linha_limite);
      }

      //Acoes executadas a cada ciclo do clock, caso o jogo esteja em andamento
      if(((cont % 1) == 0) && (estado_jogo == 0)) {

        quer_exibir_estado = 1;

        //Obtem o vetor movimento
        int valor_movimento = ler_movimento();

        //Espera maxima e direcao do movimento
        int espera_maxima;
        int direcao_movimento;

        //Atualiza a espera maxima e o vetor unitario do movimento de acordo com o valor do movimento, caso a funcao de ler o movimento retorne valor diferente de 0
        if (valor_movimento != 0) {
          espera_maxima = (abs(valor_movimento));
          direcao_movimento = (valor_movimento/espera_maxima);
        }
        //Caso retorne zero, isso quer dizer que nao houve movimento algum
        else {
          espera_maxima = 10;
          direcao_movimento = 0;
        }
        
        //Se ja passou o intervalo necessario para a acao de movimento, ve se esta pedindo isso
        if(contador_movimento >= espera_maxima) {
          
          //Executa o movimento
          if(direcao_movimento != 0) {
            contador_movimento = 1;
            mover(estatico, peca, &posx, &posy, direcao_movimento, 0);

            //Desenha os novos elementos na tela
            atualiza_tela(estatico, peca, posx, posy, contador_pontos, estado_jogo, linha_limite);
          }
        }
        //Caso contrario, aumenta o contador do "cooldown"
        else {
          contador_movimento = (contador_movimento + 1);
        }
      }
      
      //Acoes executadas a cada 50 ciclos do clock, caso o jogo esteja em andamento
      if(((cont % 50) == 0) && (estado_jogo == 0)) {

        quer_exibir_estado = 1;
        
        //Move a peca um espaco para baixo e verifica se houve obstrucao ao executar acao de mover
        int resultado_mover = mover(estatico, peca, &posx, &posy, 0, 1);
        
        //Se houve obstrucao, significa que a peca sera colocada e acontecera uma verificacao para "implodir" linhas
        //Tambem reseta a peca atual
        //Por fim, verifica se a peca colocada esta dentro dos limites da area de jogo, para ver se configura "game over"
        if(resultado_mover == 1) {
          
          //Colocacao da peca (une a matriz dos objetos com a matriz da peca na propria matriz dos objetos)
          une_matriz(&estatico, estatico, peca, posx, posy);
          //A peca atual deixa de existir
          preenche_zero_4_x_4(&peca);
          
          //Tenta eliminar linhas e guarda o resultado
          int linha_eliminada = implodir(&estatico);

          //Caso elimine linha... 
          while (linha_eliminada != (-1)) {
            
            //Aumenta a contagem de pontos
            contador_pontos = (contador_pontos + 1);

            //...E continua tentando ate nao mais eliminar
            cascada(&estatico, linha_eliminada);
            linha_eliminada = implodir(&estatico);
          }

          //Verificacao do limite do jogo
          //Se estiver nos limites, o jogo continua
          if (posy > linha_limite) {

            //"Reset" da peca
            posx = 4;
            posy = 0;

            gettimeofday(&tempo, NULL);
            tempo_preciso = tempo.tv_usec;
            tempo_simples = tempo.tv_sec;
            
            srand (tempo_preciso);
            rShape = (rand() % 6);
            
            srand(tempo_simples);
            rColor = ((rand() % 8) + 1);

            gerar_peca(&peca, rShape, rColor);
          }
          //Se nao estiver, o jogo terminou
          else {
            estado_jogo = 3;
          }
        }

        //Desenha os novos elementos na tela
        atualiza_tela(estatico, peca, posx, posy, contador_pontos, estado_jogo, linha_limite);
      }

      //Artificio para "prender" a execucao do programa quando o estado acabar sendo 3 (so permite sair caso seja mudado para estado 2)
      //Estado 3 significa "fim de jogo", sendo por isso que so permite ser mudado para "restart"
      if (estado_jogo == 3) {
        display_final(1);
        while(estado_jogo != 2) {
          estado_jogo = ler_comando(estado_jogo);
          //Sleep de acordo com o clock da aplicacao
          nanosleep(&intervalo, NULL);
        }
      }

      //Sobe o contador de ciclos
      cont = (cont + 1);

      if (cont == 2001) {
        cont = 1;
      }
    }

    //Artificio para "prender" a execucao do programa ate que o input de restart seja "solto"
    while(estado_jogo == 2) {
      estado_jogo = ler_comando(estado_jogo);
      //Sleep de acordo com o clock da aplicacao
      nanosleep(&intervalo, NULL);
    }
  }

  //video_close();
  unmap_physical(I2C0_virtual, I2C0_SPAN);
  close_physical(fd);
}
