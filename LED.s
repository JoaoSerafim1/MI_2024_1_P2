.global teste
.type teste, %function

teste:
    SUB sp, sp, #8
    STR LR, [sp, #0]
    STR R7, [sp, #4]

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
    MOV R1, #0x0
    MOV R2, #0x60
    ADD R3, R10, R1
    ADD R4, R10, R2


    LDR R6, [R3, #0] @ Carrega o valor atual dos botoes para um registro
    STR R6, [R4, #0] @ Guarda o valor do registro no endereco de memoria do conjunto de LEDs 0
    MOV R0, R6

    LDR LR, [sp, #0]
    LDR R7, [sp, #4]
    ADD sp, sp, #8

    BX LR
    @B DISPLAY_KEY @ Repete os dois comandos anteriores e este mesmo
DISPLAY_KEY:
    
    @MOVi R0, #0 @ (Codigo de saida do programa 0)
    @B END_OF_CODE @ Vai ao final do codigo, nao chega aqui, porem ja esta para redirecionar qualquer codigo que chegar ao final da execucao

BRIDGE_ERROR:
@@ -60,7 +52,10 @@
    SVC 0 @ Chama o sistema

END_OF_CODE:
    @MOV R7, #1
    @SVC 0 @ Chama o sistema

.data
    ALT_LWFPGASLVS_OFST:    .word   0xFF200
    HW_REGS_BASE:           .word   0xFC000000
    HW_REGS_SPAN:           .word   0x04000000
    pagingfolder:           .asciz  "/dev/mem"
    errmsgbridge:           .ascii  "Erro: Nao foi possivel estabelecer a conexao HPS-FPGA.\n"
    @.equ HW_KEYS_BASE,      #0x0
    @.equ HW_HEX0_BASE,      #0x60