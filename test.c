# include <stdio.h>
# include <stdlib.h>
#include "test_lib.h"

int main(){
    char dir[8] = "/dev/mem";
    int fd;
    int base_adr;

    printf("%s\n", dir);

    fd = file_open();
    
    /*if(fd < 0){
        return -1;
    }

    printf("%d", fd);

    base_adr = mem_map(fd);
    if(base_adr == (-1)){
        return -1;
    }

    printf("%d", base_adr);

    file_close(fd);*/

    return 0;
}
