//Bibliotecas basicas do C
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <time.h>

//Biblioteca original de controle da GPU customizada
#include "vlib.h"

int main(){
    MAP();
    WBR_BACKGROUND(511);
    WSM(8, 7);
    WSM(18, 281);
    WSM(19, 312);
    WSM(20, 407);
    WSM(21, 7);
    WBR_SPRITE(1, 0, 250, 200, 1);
    WBM(100, 100, 511);
    DP(100, 200, 187, 0, 2);
    return 0;
}