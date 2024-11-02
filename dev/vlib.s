.global DP
.type DP, %function
.global WBM
.type WBM, %function
.global WBR_BACKGROUND
.type WBR_BACKGROUND, %function
.global WBR_SPRITE
.type WBR_SPRITE, %function
.global WSM
.type WSM, %function

@testando DP
DP:
    SUB sp, sp, #20
    STR R0, [sp, #16]
    STR R1, [sp, #12]
    STR R2, [sp, #8]
    STR R3, [sp, #4]
    STR R4, [sp, #0]


    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema
    
    MOV R10, R0
    LDR R9, =ALT_LWFPGASLVS_OFST

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #-1
    BEQ BRIDGE_ERROR

    MOV R10, R0
    MOV R1, #0x80       @ DATA A
    MOV R2, #0x70       @ DATA B
    MOV R3, #0xc0       @ WRREG
    MOV R4, #0xb0       @ WRFULL
    @MOV R5, #0xa0        SCREEN
    @MOV R6, #0x90        RESET_PULSECOUNTER

    ADD R5, R10, R1
    ADD R6, R10, R2
    ADD R8, R10, R3

    MOV R9, #0b0011    @ Codigo de definir forma (DP)
    LDR R10, =SQR_POL  @ pega o endereco da variavel
    LSL R10, R10, #4   @ Shift logico para a esquerda em 4 casa binarias
    ADD R9, R9, R10    @ Adiciona os dois valores binarios
    STR R9, [R5, #0]   @ Guarda o valor da instrução na memória de DATA A

    LDR R4, [sp, #20]
    LDR R3, [sp, #4]
    LDR R2, [sp, #8]
    LDR R1, [sp, #12]
    LDR R0, [sp, #16]
    ADD sp, sp, #16

    MOV R10, R0      @ Valor do eixo x
    MOV R11, R1       @ Valor do eixo y
    LSL R11, R11, #9   @ Adapta o valor de R11 para a soma
    ADD R10, R10, R11
    MOV R11, R4        @ Tamanho do poligono (20x20)
    LSL R11, #18
    ADD R10, R10, R11
    MOV R11, R2        @ Valor RGB
    LSL R11, #22
    ADD R10, R10, R11
    MOV R11, R3        @ Forma do poligono
    LSL R11, #31
    ADD R10, R10, R11
    STR R10, [R6, #0]  @ Guarda o valor da instrução na memória de DATA B

    MOV R11, #1
    STR R11, [R8, #0]  @ Sinal de start

    MOV R11, #0
    STR R11, [R8, #0]  @ Sinal de start

    B END_OF_CODE @ Vai ao final do codigo, nao chega aqui, porem ja esta para redirecionar qualquer codigo que chegar ao final da execucao


@ Argumentos: R0 = indice x do bloco do background (0-79); R1 = indice y do bloco do background (0-59); R2 = COR BGR
@ Retorna: void
WBM:

    SUB sp, sp, #12
    STR R0, [sp, #8]
    STR R1, [sp, #4]
    STR R2, [sp, #0]


    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema
    
    MOV R10, R0
    LDR R9, =ALT_LWFPGASLVS_OFST

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #-1
    BEQ BRIDGE_ERROR

    MOV R10, R0
    MOV R1, #0x80       @ DATA A
    MOV R2, #0x70       @ DATA B
    MOV R3, #0xc0       @ WRREG
    MOV R4, #0xb0       @ WRFULL
    @MOV R5, #0xa0        SCREEN
    @MOV R6, #0x90        RESET_PULSECOUNTER

    ADD R5, R10, R1
    ADD R6, R10, R2
    ADD R8, R10, R3

    LDR R2, [sp, #0]
    LDR R1, [sp, #4]
    LDR R0, [sp, #8]
    ADD sp, sp, #12

    SQR_INDEX:
        MOV R9, #80         @ Tamanho da linha (numero de colunas por linha)
        MUL R10, R9, R1     @ Multiplica pelo indice da posicao y
        ADD R11, R10, R0    @ Soma com o indice da posicao x

    DATA_A_SET_3:
        MOV R10, #0b0010        @ Codigo de escrever na memoria de background (WBM)
        LSL R11, R11, #4         @ Desloca o indice do poligono para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o indice do poligono
        STR R10, [R5, #0]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA A

    DATA_B_SET_3:
        STR R2, [R6, #0]     @ Guarda o valor dos parametros da instrucao DP que vao em DATA B (cor BGR)

    DATA_SEND_3:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG

    B END_OF_CODE

@ Argumentos: R0 = COR BGR, R1 = Registrador
@ Retorna: void
@Para background
WBR_BACKGROUND:
    
    SUB sp, sp, #4
    STR R0, [sp, #0]

    MOV R11, R0    @ Salva o valor de RGB

    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema
    
    MOV R10, R0
    LDR R9, =ALT_LWFPGASLVS_OFST

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #-1
    BEQ BRIDGE_ERROR

    

    MOV R10, R0
    MOV R1, #0x80       @ DATA A
    MOV R2, #0x70       @ DATA B
    MOV R3, #0xc0       @ WRREG
    @MOV R4, #0xb0       @ WRFULL
    @MOV R5, #0xa0        SCREEN
    @MOV R6, #0x90        RESET_PULSECOUNTER

    ADD R5, R10, R1
    ADD R6, R10, R2
    ADD R8, R10, R3
    
    LDR R0, [sp, #0]
    ADD sp, sp, #4

    DATA_A_SET_1:
        MOV R10, #0b0000       @ Codigo de escrever no banco de registradores (WBR)
        MOV R11, #0            @ Registrador que guarda as informacoes do WBR (R6)
        LSL R11, R11, #4        @ Desloca o registrador para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R5, #0]    @ Guarda o valor dos parametros da instrucao WBR que vao em DATA A

    DATA_B_SET_1:
        STR R0, [R6, #0]     @ Guarda o valor dos parametros da instrucao WBR que vao em DATA B (cor BGR)

    DATA_SEND_1:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG

    B END_OF_CODE



@ Argumentos: R0 = Registrador Sprite; R1 = Offset do sprite; R2 = posicao x; R3 = posicao y; R4 = valor sp de ligar/desligar sprite
@ Retorna: void
@Para Sprites
WBR_SPRITE:
    SUB sp, sp, #20
    STR R0, [sp, #16]
    STR R1, [sp, #12]
    STR R2, [sp, #8]
    STR R3, [sp, #4]
    STR R4, [sp, #0]
    

    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema
    
    MOV R10, R0
    LDR R9, =ALT_LWFPGASLVS_OFST

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #-1
    BEQ BRIDGE_ERROR

    MOV R10, R0
    MOV R1, #0x80       @ DATA A
    MOV R2, #0x70       @ DATA B
    MOV R3, #0xc0       @ WRREG
    MOV R4, #0xb0       @ WRFULL
    @MOV R5, #0xa0        SCREEN
    @MOV R6, #0x90        RESET_PULSECOUNTER

    ADD R5, R10, R1
    ADD R6, R10, R2
    ADD R8, R10, R3

    LDR R4, [sp, #20]
    LDR R3, [sp, #4]
    LDR R2, [sp, #8]
    LDR R1, [sp, #12]
    LDR R0, [sp, #16]
    ADD sp, sp, #20

    DATA_A_SET_0:
        MOV R10, #0             @ Codigo de escrever no banco de registradores (WBR)
        MOV R11, R0             @ Registrador que guarda as informacoes do WBR (R6)
        LSL R11, R11, #4        @ Desloca o registrador para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R5, #0]    @ Guarda o valor dos parametros da instrucao WSM que vao em DATA A

    DATA_B_SET_0:
        MOV R10, R1             @ Offset do sprite
        LSL R11, R3, #9         @ Desloca a posicao y do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        LSL R11, R2, #19        @ Desloca a posicao x do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        LSL R11, R4, #29        @ Desloca o valor sp do sprite para seu offset final
        ADD R10, R10, R11       @ Soma para a instrucao
        STR R10, [R6, #0]    @ Guarda o valor dos parametros da instrucao DP que vao em DATA B

    DATA_SEND_0:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG

    B END_OF_CODE   @ Sinal de fim de funcao

@ Argumentos: R0 = Endereco do sprite (1- 31); R1 = COR BGR
@ Retorna: void
WSM:

    SUB sp, sp, #12
    STR R0, [sp, #0]
    STR R1, [sp, #4]
    STR R2, [sp, #8]


    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema
    
    MOV R10, R0
    LDR R9, =ALT_LWFPGASLVS_OFST

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #-1
    BEQ BRIDGE_ERROR

    MOV R10, R0
    MOV R1, #0x80       @ DATA A
    MOV R2, #0x70       @ DATA B
    MOV R3, #0xc0       @ WRREG
    @MOV R4, #0xb0       @ WRFULL
    @MOV R5, #0xa0        SCREEN
    @MOV R6, #0x90        RESET_PULSECOUNTER

    ADD R5, R10, R1
    ADD R6, R10, R2
    ADD R8, R10, R3

    LDR R0, [sp, #0]
    LDR R1, [sp, #4]
    LDR R2, [sp, #8]
    ADD sp, sp, #12

    DATA_A_SET_2:
        MOV R10, #0b0001        @ Codigo de escrever na memoria de sprintes (WSM)
        LSL R11, R0, #4         @ Desloca o endereco do sprite para seu offset final
        ADD R10, R10, R11       @ Soma o codigo com o endereco do sprite
        STR R10, [R5, #0]    @ Guarda o valor dos parametros da instrucao WSM que vao em DATA A

    DATA_B_SET_2:
        STR R1, [R6, #0] @ Guarda o valor dos parametros da instrucao DP que vao em DATA B (cor BGR)

    DATA_SEND_2:
        MOV R10, #1             @ Valor para fazer execucao da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG
        MOV R10, #0             @ Valor para resetar o mecanismo da instrucao
        STR R10, [R8, #0]    @ Guarda o valor de execucao em WRREG

    MOV R0, #0      @ Prepara para retornar codigo 0 (Operacao bem-sucedida)

    B END_OF_CODE   @ Sinal de fim de funcao



BRIDGE_ERROR:
    MOV R0, #1
    LDR R1, =errmsgbridge
    MOV R2, #7
    MOV R7, #4
    SVC 0 @ Chama o sistema
    MOV R0, #1 @ (Codigo de saida do programa 1)
    B END_OF_CODE @ Vai ao final do codigo

END_OF_CODE:
    MOV R7, #1
    SVC 0 @ Chama o sistema

.data
    ALT_LWFPGASLVS_OFST:    .word   0xff200
    pagingfolder:           .asciz  "/dev/mem"
    errmsgbridge:           .ascii  "Erro: Nao foi possivel estabelecer a conexao HPS-FPGA.\n"
    SQR_POL:                .byte
