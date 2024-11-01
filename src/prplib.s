.global RDBT
.type RDBT, %function

RDBT:
    LDR R0, =pagingfolder   @ Caminho de paginacao
    MOV R1, #2
    MOV R2, #0
    MOV R7, #5              @ Codigo de chamada do sistema para abertura de arquivo
    SVC 0                   @ Chama o sistema
    
    MOV R10, R0                     @ Copia o endereco virtual base de R0 para 10
    LDR R9, =ALT_LWFPGASLVS_OFST    @ Carrega em R9 o valor contido 

    MOV R0, #0      @ Volta o registro R0 para 0, ja que este sera usado para avaliar se houve erro
    MOV R1, #4096   @ Tamanho do pagina
    MOV R2, #3      @ Leitura e escrita
    MOV R3, #1      @ Modo MAP_SHARED, automaticamente guarda todas as alteracoes feitas na regiao mapeada na pagina
    MOV R4, R10     @ Copia o caminho de paginacao para o registro que corresponde ao argumento da chamada de sistema 
    LDR R5, [R9]
    MOV R7, #192    @ Codigo da chamada do sistema para mapeamento (mmap2)
    SVC 0           @ Chama o sistema
    CMP R0, #-1     @ Verifica se deu erro (codigo -1)
    BEQ END_OF_CODE @ Vai ao final do codigo imediatamente caso de erro

    MOV R10, R0         @ Copia o endereco virtual base de R0 para 10
    LDR R0, [R10, #0]   @ Carrega o valor dos botoes para R0 (Registro de retorno)

    MOV R1, #0b1111     @ 15 utilizado para operacoes logicas (todos os 4 primeiros bits sao 1)
    EOR R0, R0, R1      @ Inverte os bits dos botoes (4 primeiros), na medida em que todos os 4 primeiros bits de R1 sao 1
    AND R0, R0, R1      @ Descarta os valores que possam estourar acima de 4 bits

END_OF_CODE:
    MOV R7, #1  @ Codigo de chamada do sistema para retorno de uma funcao
    SVC 0       @ Chama o sistema

.data
    ALT_LWFPGASLVS_OFST:    .word   0xff200
    pagingfolder:           .asciz  "/dev/mem"