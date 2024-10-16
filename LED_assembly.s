.text
.global _start

_start:
    
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

    DATA_A:             MOV R1, #0x80
    DATA_B:             MOV R2, #0x70
    WRREG:              MOV R3, #0xc0
    WRFULL:             MOV R4, #0xb0
    SCREEN:             MOV R5, #0xa0
    RESET_PULSECOUNTER: MOV R6, #0x90

    MOV R9, #0b0011 @ Codigo de definir forma (DP)
    LDR R10, =SQR_POL @ pega o endereco da variavel
    LSL R10, R10, #4 @ Shift logico para a esquerda em 4 casa binarias
    ADD R9, R9, R10 @ Adiciona os dois valores binarios

    MOV R7, #0b0010 @ Codigo de modificar background (WBM)
    
    MOV R7, #0b111 @ Red = 7
    MOV R8, #0b000000 @ Green = 0
    ADD R7, R7, R8
    MOV R8, #0b000000000 @ Blue = 0
    ADD R7, R7, R8


    B END_OF_CODE @ Vai ao final do codigo, nao chega aqui, porem ja esta para redirecionar qualquer codigo que chegar ao final da execucao

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
