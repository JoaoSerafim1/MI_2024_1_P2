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
    WBR_SPRITE(1, 2, 250, 200, 1);
    //WSM(1, 7);
    WBM(100, 100, 511);
    DP(100, 200, 187, 0, 2);
    return 0;
}