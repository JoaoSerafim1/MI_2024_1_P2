.text
.global _start

_start:
    
    LDR R0, =pagingfolder
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5
    SVC 0 @ Chama o sistema

    MOV R4, R0 @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema
    LDR R10, =ALT_LWFPGASLVS_OFST
    LDR R5, [R10]

    MOV R0, #0 @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096 @ Tamanho do pagina
    MOV R2, #3 @ Leitura e escrita
    MOV R3, #1 @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R7, #192 @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0 @ Chama o sistema
    CMP R0, #0
    BGT BRIDGE_ERROR
    
    MOV R10, =HW_KEYS_BASE
    MOV R11, =HW_HEX0_BASE

DISPLAY_KEY:
    LDR R1, [R10] @ Carrega o valor atual dos botoes para um registro
    STR R1, [R11] @ Guarda o valor do registro no endereco de memoria do conjunto de LEDs 0
    B DISPLAY_KEY @ Repete os dois comandos anteriores e este mesmo

    MOV R0, #0 @ (Codigo de saida do programa 0)
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
    ALT_LWFPGASLVS_OFST:    .word   0xFF200000
    HW_REGS_BASE:           .word   0xFC000000
    HW_REGS_SPAN:           .word   0x04000000
    HW_KEYS_BASE:           .word   0x0
    HW_HEX0_BASE:           .word   0x60
    pagingfolder:           .asciz  "/dev/mem"
    errmsgbridge:           .ascii  "Erro: Nao foi possivel estabelecer a conexao HPS-FPGA.\n"