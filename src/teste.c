//Bibliotecas basicas do C
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <time.h>

//Biblioteca original de controle da GPU customizada
#include "vlib.h"

//Biblioteca original de interface com os perifericos
#include "prplib.h"

int main(){
    MAP();
    WBR_BACKGROUND(511);
    WBR_SPRITE(1, 1, 100, 50, 1);
    //WSM(1, 7);
    WBM(200, 250, 7);
    DP(100, 200, 7, 1, 2);
    return 0;
}