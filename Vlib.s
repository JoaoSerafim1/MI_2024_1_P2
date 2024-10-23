.global video_dp_square_20x20
.type video_dp_square_20x20, %function
.global video_wbm
.type video_wbm, %function

video_dp_square_20x20:
    
    CHK_PARAM_0:
        CMP R0, #0  @ Verifica se a posicao x e menor que 0
        BLT ERR_0a  @ Caso seja, deu erro
        CMP R0, #79 @ Verifica se a posicao x e maior que 79
        BGT ERR_0a  @ Caso seja, deu erro
        CMP R1, #0  @ Verifica se a posicao y e menor que 0
        BLT ERR_0b  @ Caso seja, deu erro
        CMP R1, #59 @ Verifica se a posicao y e maior que 59
        BGT ERR_0b  @ Caso seja, deu erro
        CMP R2, #0  @ Verifica se a cor e menor que 0
        BLT ERR_0c  @ Caso seja, deu erro
        CMP R2, #0  @ Verifica se a cor e maior que 511
        BGT ERR_0c  @ Caso seja, deu erro

    STORE_PARAM_0:
        STMDB SP!, {R0-R2}  @ Guarda os parametros da funcao na pilha

    DIR_OPEN_0:
        LDR R0, =pagingfolder   @ Carrega o endereco da string do caminho de paginacao
        MOV R1, #2              @ Modo da edicao (leitura e escrita)
        MOV R2, #0              @ Modo do arquivo
        MOV R7, #5              @ Codigo da chamada do sistema para abrir um arquivo
        SVC 0                   @ Chama o sistema

    MMAP_0:
        MOV R10, R0                     @ Copia o diretorio retornado
        LDR R9, =ALT_LWFPGASLVS_OFST    @ Carrega o endereco da string referente ao endereco base para a paginacao
        MOV R0, #0                      @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
        MOV R1, #4096                   @ Tamanho da pagina
        MOV R2, #3                      @ Leitura e escrita
        MOV R3, #1                      @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
        MOV R4, R10                     @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
        LDR R5, [R9]                    @ Carrega o endereco base para a paginacao
        MOV R7, #192                    @ Codigo da chamada do sistema para mapeamento (mmap2)
        SVC 0                           @ Chama o sistema
        CMP R0, #-1                     @ Verifica se deu erro
        BEQ END_0                       @ Se deu erro, vai ao final da funcao imediatamente
        MOV R10, R0                     @ Copia o endereco virtual base retornado
        MOV R7, #0x80                   @ Offset de DATA A
        MOV R8, #0x70                   @ Offset de DATA B
        MOV R9, #0xc0                   @ Offset de WRREG
        ADD R7, R10, R7                 @ Endereco virtual de DATA A
        ADD R8, R10, R8                 @ Endereco virtual de DATA B
        ADD R9, R10, R9                 @ Endereco virtual de WRREG

    LOAD_PARAM_0:
        LDMIA SP!, {R0-R2}  @Recupera os parametros da funcao da pilha
        
    DATA_A_SET_0:
        MOV R10, #0b0011    @ Codigo de definir forma (DP)
        LDR R11, =SQR_POL   @ Pega o endereco do poligono
        LSL R11, #4         @ Desloca o endereco do poligono para seu offset final
        ADD R10, R10, R11   @ Soma o codigo com o endereco da forma do poligono
        STR R10, [R7, #0]   @ Guarda o valor dos parametros da instrucao DP que vao em DATA A

    DATA_B_SET_0:
        MOV R10, R0         @ Posicao x do poligono
        LSL R11, R1, #9     @ Desloca a posicao y do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        MOV R11, #0b0001    @ Tamanho do poligono (20x20)
        LSL R11, R11, #18   @ Desloca o tamanho do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        LSL R11, R2, #22    @ Desloca a cor do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        MOV R11, #0         @ Forma do poligono (0 = quadrado)
        LSL R11, R11, #31   @ Desloca a forma do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        STR R10, [R8, #0]   @ Guarda o valor dos parametros da instrucao DP que vao em DATA B

    DATA_SEND_0:
        MOV R10, #1     @ Valor para fazer execucao da instrucao
        STR R9, [R10]   @ Guarda o valor de execucao em WRREG
        MOV R10, #0     @ Valor para resetar o mecanismo da instrucao
        STR R9, [R10]   @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_0         @ Vai ao fim da funcao

    ERR_0a:
        MOV R0, #-2 @ Prepara para retornar codigo -2 (posicao x inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0b:
        MOV R0, #-3 @ Prepara para retornar codigo -3 (posicao y inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0c:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (cor RGB inadequada)

    END_0:
        BX LR   @ Sinal de fim de funcao


video_wbm:
    
    CHK_PARAM_0:
        CMP R0, #0  @ Verifica se a posicao x e menor que 0
        BLT ERR_0a  @ Caso seja, deu erro
        CMP R0, #79 @ Verifica se a posicao x e maior que 79
        BGT ERR_0a  @ Caso seja, deu erro
        CMP R1, #0  @ Verifica se a posicao y e menor que 0
        BLT ERR_0b  @ Caso seja, deu erro
        CMP R1, #59 @ Verifica se a posicao y e maior que 59
        BGT ERR_0b  @ Caso seja, deu erro
        CMP R2, #0  @ Verifica se a cor e menor que 0
        BLT ERR_0c  @ Caso seja, deu erro
        CMP R2, #0  @ Verifica se a cor e maior que 511
        BGT ERR_0c  @ Caso seja, deu erro

    STORE_PARAM_0:
        STMDB SP!, {R0-R2}  @ Guarda os parametros da funcao na pilha

    DIR_OPEN_0:
        LDR R0, =pagingfolder   @ Carrega o endereco da string do caminho de paginacao
        MOV R1, #2              @ Modo da edicao (leitura e escrita)
        MOV R2, #0              @ Modo do arquivo
        MOV R7, #5              @ Codigo da chamada do sistema para abrir um arquivo
        SVC 0                   @ Chama o sistema

    MMAP_0:
        MOV R10, R0                     @ Copia o diretorio retornado
        LDR R9, =ALT_LWFPGASLVS_OFST    @ Carrega o endereco da string referente ao endereco base para a paginacao
        MOV R0, #0                      @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
        MOV R1, #4096                   @ Tamanho da pagina
        MOV R2, #3                      @ Leitura e escrita
        MOV R3, #1                      @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
        MOV R4, R10                     @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
        LDR R5, [R9]                    @ Carrega o endereco base para a paginacao
        MOV R7, #192                    @ Codigo da chamada do sistema para mapeamento (mmap2)
        SVC 0                           @ Chama o sistema
        CMP R0, #-1                     @ Verifica se deu erro
        BEQ END_0                       @ Se deu erro, vai ao final da funcao imediatamente
        MOV R10, R0                     @ Copia o endereco virtual base retornado
        MOV R7, #0x80                   @ Offset de DATA A
        MOV R8, #0x70                   @ Offset de DATA B
        MOV R9, #0xc0                   @ Offset de WRREG
        ADD R7, R10, R7                 @ Endereco virtual de DATA A
        ADD R8, R10, R8                 @ Endereco virtual de DATA B
        ADD R9, R10, R9                 @ Endereco virtual de WRREG

    LOAD_PARAM_0:
        LDMIA SP!, {R0-R2}  @Recupera os parametros da funcao da pilha
        
    DATA_A_SET_0:
        MOV R10, #0b0011    @ Codigo de definir forma (DP)
        LDR R11, =SQR_POL   @ Pega o endereco do poligono
        LSL R11, #4         @ Desloca o endereco do poligono para seu offset final
        ADD R10, R10, R11   @ Soma o codigo com o endereco da forma do poligono
        STR R10, [R7, #0]   @ Guarda o valor dos parametros da instrucao DP que vao em DATA A

    DATA_B_SET_0:
        MOV R10, R0         @ Posicao x do poligono
        LSL R11, R1, #9     @ Desloca a posicao y do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        MOV R11, #0b0001    @ Tamanho do poligono (20x20)
        LSL R11, R11, #18   @ Desloca o tamanho do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        LSL R11, R2, #22    @ Desloca a cor do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        MOV R11, #0         @ Forma do poligono (0 = quadrado)
        LSL R11, R11, #31   @ Desloca a forma do poligono para seu offset final
        ADD R10, R10, R11   @ Soma para a instrucao
        STR R10, [R8, #0]   @ Guarda o valor dos parametros da instrucao DP que vao em DATA B

    DATA_SEND_0:
        MOV R10, #1     @ Valor para fazer execucao da instrucao
        STR R9, [R10]   @ Guarda o valor de execucao em WRREG
        MOV R10, #0     @ Valor para resetar o mecanismo da instrucao
        STR R9, [R10]   @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)
    B END_0         @ Vai ao fim da funcao

    ERR_0a:
        MOV R0, #-2 @ Prepara para retornar codigo -2 (posicao x inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0b:
        MOV R0, #-3 @ Prepara para retornar codigo -3 (posicao y inadequada)
        B END_0     @ Vai ao fim da funcao
    ERR_0c:
        MOV R0, #-4 @ Prepara para retornar codigo -4 (cor RGB inadequada)

    END_0:
        BX LR   @ Sinal de fim de funcao
    MOV R7, #0b0010      @ Codigo de modificar background (WBM)
    LDR R10, =SQR_POL    @ Pega o endereço do poligono
    LSL R10, #4          @ Shift logico para encaixar na instrução
    ADD R7, R7, R10      @ Adiciona o endereço à instrução
    STR R7, [R5, #0]     @ Guarda o valor da instrução na memória de DATA A

    MOV R9, #0b111       @ Red = 7
    MOV R8, #0b000000    @ Green = 0
    ADD R9, R9, R8
    MOV R8, #0b000000000 @ Blue = 0
    ADD R9, R9, R8
    STR R9, [R6, #0]     @ Guarda o valor da instrução na memória de DATA B

    

.data
    ALT_LWFPGASLVS_OFST:    .word   0xff200
    pagingfolder:           .asciz  "/dev/mem"
    SQR_POL:                .byte
