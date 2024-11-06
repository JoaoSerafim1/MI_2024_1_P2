//Bibliotecas basicas do C
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <time.h>

//Biblioteca original de controle da GPU customizada
#include "vlib.h"

int main(){
    MAP();
    DP(100, 200,  77, 0, 1);
    return 0;
}