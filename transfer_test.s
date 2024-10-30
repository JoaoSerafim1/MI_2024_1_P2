SUB R1, R1, R1
SUB R2, R2, R2
SUB R3, R3, R3

ADDI R1, R1, #0
ADDI R2, R2, #0
ADDI R3, R3, #16.global DP
.type DP, %function

DP:
    SUB sp, sp, #12
    STR R0, [sp, #12]
    STR R1, [sp, #8]
    STR R2, [sp, #4]
    STR R3, [sp, #0]


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

    LDR R0, [sp, #12]
    LDR R1, [sp, #8]
    LDR R2, [sp, #4]
    LDR R3, [sp, #0]
    ADD sp, sp, #12

    MOV R10, R0      @ Valor do eixo x
    MOV R11, R1       @ Valor do eixo y
    LSL R11, R11, #9   @ Adapta o valor de R11 para a soma
    ADD R10, R10, R11
    MOV R11, #3        @ Tamanho do poligono (20x20)
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

WBM:
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

LDUR R1, [R1, #0]

ADD R2, R1, R2
ADD R3, R1, R3

DISPLAY_KEY:    LDUR R4, [R2, #0]
				STUR R4, [R3, #0]
    			B DISPLAY_KEY
