//Bibliotecas basicas do C
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>

//Biblioteca original de interface com os perifericos
#include "prplib.h"

void main(){
    while(1 == 1){
        int var1 = RDBT();
        printf("%d\n", var1);
        //printf("%d", retorno);
        sleep(1);
    }
}