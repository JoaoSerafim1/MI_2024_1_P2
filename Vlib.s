.global video_box
.type video_box, %function

video_box:
    
    
    DIR_OPEN_0:
        LDR R0, =pagingfolder
        MOV R1, #2
        MOV R2, #0
        MOV R7, #5
        SVC 0       @ Chama o sistema

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
        CMP R0, #-1
        BEQ END_0
        MOV R10, R0         @ Copia o endereco virtual base retornado
        MOV R1, #0x80       @ Offset de DATA A
        MOV R2, #0x70       @ Offset de DATA B
        MOV R3, #0xc0       @ Offset de WRREG
        @MOV R4, #0xb0      @ Offset de WRFULL
        @MOV R5, #0xa0      @ Offset de SCREEN
        @MOV R6, #0x90      @ Offset de RESET_PULSECOUNTER
        ADD R1, R10, R1 @ Endereco virtual de DATA A
        ADD R2, R10, R2 @ Endereco virtual de DATA B
        ADD R3, R10, R3 @ Endereco virtual de WRREG

    DATA_A_SET_0:
        MOV R4, #0b0011    @ Codigo de definir forma (DP)
        STR R4, [R1, #0]   @ Guarda o valor do codigo da instrucao DP em DATA A
        LDR R4, =SQR_POL   @ Pega o endereco da variavel da forma do poligono
        STR R4, [R1, #4]   @ Guarda o valor do endereco do poligono em DATA A

    DATA_B_SET_0:
    MOV R10, #40       @ Valor do eixo x
    MOV R11, #30       @ Valor do eixo y
    LSL R11, R11, #9   @ Adapta o valor de R11 para a soma
    ADD R10, R10, R11
    MOV R11, #3        @ Tamanho do poligono (20x20)
    LSL R11, #18
    ADD R10, R10, R11
    MOV R11, #7        @ Valor RGB (7, 0, 0)
    LSL R11, #22
    ADD R10, R10, R11
    MOV R11, #0        @ Forma do poligono (Quadrado)
    LSL R11, #31
    ADD R10, R10, R11
    STR R10, [R6, #0]  @ Guarda o valor da instrução na memória de DATA B

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

    END_0:
        BX LR

BRIDGE_ERROR:
    MOV R0, #1
    LDR R1, =errmsgbridge
    MOV R2, #7
    MOV R7, #4
    SVC 0 @ Chama o sistema
    MOV R0, #1 @ (Codigo de saida do programa 1)
    B END_OF_CODE @ Vai ao final do codigo

END_OF_CODE:
    MOV R7, #1 @ Codigo de chamada do sistema para sair de um programa
    SVC 0 @ Chama o sistema

.data
    ALT_LWFPGASLVS_OFST:    .word   0xff200
    pagingfolder:           .asciz  "/dev/mem"
    errmsgbridge:           .ascii  "Erro: Nao foi possivel estabelecer a conexao HPS-FPGA.\n"
    SQR_POL:                .byte
