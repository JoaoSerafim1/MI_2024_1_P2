.text
.global _start

_start:

    MOV R1, #4227858432 @ HEX FC000000 em DEC, endereco da memoria no qual e encontrada a referencia ao endereco base para os componentes (muda a cada execucao devido a questoes de virtualizacao de memoria, chamado HW_REGS_BASE no manual)
    MOV R2, #0 @ Offset dos botoes (KEYS_BASE) em relacao a base dos componentes
    MOV R3, #96 @ HEX 60 em DEC, offset do conjunto de LEDs 0 (HEX0_BASE) em relacao a base dos componentes

    LDR R1, [R1] @ Muda o valor contido em R1 da referencia ao endereco base dos perifericos para o endereco em si

    ADD R2, R1, R2 @ Adiciona o offset do endereco dos botoes a base dos perifericos
    ADD R3, R1, R3 @ Adiciona o offset do endereco conjunto de LEDs 0 a base dos perifericos

DISPLAY_KEY:
    LDR R4, [R2] @ Carrega o valor atual dos botoes para um registro
    STR R4, [R3] @ Guarda o valor do registro no endereco de memoria do conjunto de LEDs 0
    B DISPLAY_KEY @ Repete os dois comandos anteriores e este mesmo

.end