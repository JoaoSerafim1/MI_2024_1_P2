.global file_open
.type file_open, %function
.global file_close
.type file_close, %function

.global mem_map
.type mem_map, %function
.global mem_unmap
.type mem_unmap, %function

.global video_wbm
.type video_wbm, %function
.global video_dp_square_20x20
.type video_dp_square_20x20, %function


file_open:

    MOV R1, #2              @ Modo da edicao (leitura e escrita)
    MOV R2, #0              @ Modo do arquivo
    MOV R7, #5              @ Codigo da chamada do sistema para abrir um arquivo
    SVC 0                   @ Chama o sistema

    BX LR   @ Sinal de fim de funcao

file_close:

    MOV R7, #6              @ Codigo da chamada do sistema para fechar um arquivo
    SVC 0                   @ Chama o sistema

    BX LR   @ Sinal de fim de funcao

mem_map:
    MOV R10, R0                     @ Copia o diretorio para o registro 10
    MOV R9, #0xff200                @ Copia o endereco base para a paginacao
    MOV R0, #0                      @ Volta o registro R0 para 0, ja que e um argumento da chamada
    MOV R1, #4096                   @ Tamanho da pagina
    MOV R2, #3                      @ Leitura e escrita
    MOV R3, #1                      @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10                     @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]                    @ Carrega o endereco base para a paginacao
    MOV R7, #192                    @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0                           @ Chama o sistema

    BX LR   @ Sinal de fim de funcao

mem_unmap:
    MOV R2, R1                      @ Copia o diretorio para o registro 2
    MOV R1, #4096                   @ Tamanho da pagina (4096 bits)
    MOV R7, #91                     @ Codigo da chamada do sistema para des-mapeamento (munmap)
    SVC 0                           @ Chama o sistema

    BX LR   @ Sinal de fim de funcao


video_wbrsprite:

    MOV R8, R0  @ Copia o valor de R0 para R8
    
    CHK_PARAM_0:
        CMP R2, #0      @ Verifica se a posicao x e menor que 0
        BLT ERR_0a      @ Caso seja, deu erro
        CMP R2, #639    @ Verifica se a posicao x e maior que 639
        BGT ERR_0a      @ Caso seja, deu erro
        CMP R3, #0      @ Verifica se a posicao y e menor que 0
        BLT ERR_0b      @ Caso seja, deu erro
        CMP R3, #479    @ Verifica se a posicao y e maior que 479
        BGT ERR_0b      @ Caso seja, deu erro
        CMP R4, #0      @ Verifica se sp e menor que 0
        BLT ERR_0c      @ Caso seja, deu erro
        CMP R4, #1      @ Verifica se sp e maior que 1
        BGT ERR_0c      @ Caso seja, deu erro

    DATA_A_SET_0:
        MOV R10, #0             @ Codigo de escrever no banco de registradores (WBR)
        MOV R11, #6             @ Registrador que guarda as informacoes do WBP/sprite (R6)
        LSL R11, R11, #4        @ Desloca o registrador para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R8, #0x80]    @ Guarda o valor dos parametros da instrucao WSM que vao em DATA A

    DATA_B_SET_0:
        MOV R10, R1             @ Offset do sprite
        LSL R11, R3, #9         @ Desloca a posicao y do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        LSL R11, R2, #19        @ Desloca a posicao x do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        LSL R11, R4, #29        @ Desloca o valor sp do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        STR R10, [R8, #0x70]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA B

    DATA_SEND_0:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_0         @ Vai ao fim da funcao

    ERR_0a:
        MOV R0, #-2 @ Prepara para retornar codigo -2 (posicao x inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0b:
        MOV R0, #-3 @ Prepara para retornar codigo -3 (posicao y inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0c:
        MOV R0, #-5 @ Prepara para retornar codigo -5 (valor sp inadequado)

    END_0:
        BX LR   @ Sinal de fim de funcao


video_wbrbackground:

    MOV R8, R0  @ Copia o valor de R0 para R8
    
    CHK_PARAM_1:
        CMP R1, #0  @ Verifica se a cor e menor que 0
        BLT ERR_1a  @ Caso seja, deu erro
        CMP R1, #0  @ Verifica se a cor e maior que 511
        BGT ERR_1a  @ Caso seja, deu erro

    DATA_A_SET_1:
        MOV R10, #0             @ Codigo de escrever no banco de registradores (WBR)
        MOV R11, #12            @ Registrador que guarda as informacoes do WBR/background (R12)
        LSL R11, R11, #4        @ Desloca o registrador para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R8, #0x80]    @ Guarda o valor dos parametros da instrucao WBR que vao em DATA A

    DATA_B_SET_1:
        STR R1, [R8, #0x70]     @ Guarda o valor dos parametros da instrucao WBR que vao em DATA B (cor BGR)

    DATA_SEND_1:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_1         @ Vai ao fim da funcao

    ERR_1a:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (COR BGR inadequada)

    END_1:
        BX LR   @ Sinal de fim de funcao


video_wsm:

    MOV R8, R0  @ Copia o valor de R0 para R8
    
    CHK_PARAM_2:
        CMP R2, #0  @ Verifica se a cor e menor que 0
        BLT ERR_2a  @ Caso seja, deu erro
        CMP R2, #0  @ Verifica se a cor e maior que 511
        BGT ERR_2a  @ Caso seja, deu erro

    DATA_A_SET_2:
        MOV R10, #0b0001        @ Codigo de escrever na memoria de sprintes (WSM)
        LSL R11, R1, #4         @ Desloca o endereco do sprite para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R8, #0x80]    @ Guarda o valor dos parametros da instrucao WSM que vao em DATA A

    DATA_B_SET_2:
        STR R2, [R8, #0x70] @ Guarda o valor dos parametros da instrucao DP que vao em DATA B (cor BGR)

    DATA_SEND_2:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_2         @ Vai ao fim da funcao

    ERR_2a:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (cor BGR inadequada)

    END_2:
        BX LR   @ Sinal de fim de funcao


video_wbm:

    MOV R8, R0  @ Copia o valor de R0 para R8
    
    CHK_PARAM_3:
        CMP R1, #0      @ Verifica se a posicao x e menor que 0
        BLT ERR_3a      @ Caso seja, deu erro
        CMP R1, #79     @ Verifica se a posicao x e maior que 79
        BGT ERR_3a      @ Caso seja, deu erro
        CMP R2, #0      @ Verifica se a posicao y e menor que 0
        BLT ERR_3b      @ Caso seja, deu erro
        CMP R2, #59     @ Verifica se a posicao y e maior que 59
        BGT ERR_3b      @ Caso seja, deu erro
        CMP R3, #0      @ Verifica se a cor e menor que 0
        BLT ERR_3c      @ Caso seja, deu erro
        CMP R3, #511    @ Verifica se a cor e maior que 511
        BGT ERR_3c      @ Caso seja, deu erro

    SQR_INDEX:
        MOV R9, #80     @ Tamanho da linha (numero de colunas por linha)
        MUL R9, R9, R2  @ Multiplica pelo indice da posicao y
        ADD R9, R9, R1  @ Soma com o indice da posicao x

    DATA_A_SET_3:
        MOV R10, #0b0010        @ Codigo de escrever na memoria de background (WBM)
        LSL R11, R9, #4         @ Desloca o indice do poligono para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o indice do poligono
        STR R10, [R8, #0x80]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA A

    DATA_B_SET_3:
        STR R3, [R8, #0x70]     @ Guarda o valor dos parametros da instrucao DP que vao em DATA B (cor BGR)

    DATA_SEND_3:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0xC0]    @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_3         @ Vai ao fim da funcao

    ERR_3a:
        MOV R0, #-2 @ Prepara para retornar codigo -2 (posicao x inadequada)
        B END_3     @ Vai ao fim da funcao
    ERR_3b:
        MOV R0, #-3 @ Prepara para retornar codigo -3 (posicao y inadequada)
        B END_3     @ Vai ao fim da funcao
    ERR_3c:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (cor BGR inadequada)

    END_3:
        BX LR   @ Sinal de fim de funcao


video_dp_square_20x20:
    
    MOV R8, R0  @ Copia o valor de R0 para R8

    CHK_PARAM_4:
        CMP R1, #0      @ Verifica se a posicao x e menor que 0
        BLT ERR_4a      @ Caso seja, deu erro
        CMP R1, #639    @ Verifica se a posicao x e maior que 639
        BGT ERR_4a      @ Caso seja, deu erro
        CMP R2, #0      @ Verifica se a posicao y e menor que 0
        BLT ERR_4b      @ Caso seja, deu erro
        CMP R2, #479    @ Verifica se a posicao y e maior que 479
        BGT ERR_4b      @ Caso seja, deu erro
        CMP R3, #0      @ Verifica se a cor e menor que 0
        BLT ERR_4c      @ Caso seja, deu erro
        CMP R3, #0      @ Verifica se a cor e maior que 511
        BGT ERR_4c      @ Caso seja, deu erro
        
    DATA_A_SET_4:
        MOV R10, #0b0011        @ Codigo de definir forma (DP)
        LSL R11, R8, #4         @ Desloca o endereco do poligono para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco da forma do poligono
        STR R10, [R8, #0x80]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA A

    DATA_B_SET_4:
        MOV R10, R1             @ Posicao x do poligono
        LSL R11, R2, #9         @ Desloca a posicao y do poligono para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        MOV R11, #0b0001        @ Tamanho do poligono (20x20)
        LSL R11, R11, #18       @ Desloca o tamanho do poligono para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        LSL R11, R3, #22        @ Desloca a cor do poligono para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        MOV R11, #0             @ Forma do poligono (0 = quadrado)
        LSL R11, R11, #31       @ Desloca a forma do poligono para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        STR R10, [R8, #0x70]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA B

    DATA_SEND_4:
        MOV R10, #1     @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0xC0]   @ Guarda o valor de execucao em WRREG
        MOV R10, #0     @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0xC0]   @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_4         @ Vai ao fim da funcao

    ERR_4a:
        MOV R0, #-2 @ Prepara para retornar codigo -2 (posicao x inadequada)
        B END_4     @ Vai ao fim da funcao
    ERR_4b:
        MOV R0, #-3 @ Prepara para retornar codigo -3 (posicao y inadequada)
        B END_4     @ Vai ao fim da funcao
    ERR_4c:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (cor BGR inadequada)

    END_4:
        BX LR   @ Sinal de fim de funcao


.data
    ALT_LWFPGASLVS_OFST:    .word   0xff200
    pagingfolder:           .asciz  "/dev/mem"
