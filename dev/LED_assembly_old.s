@.include "address_map_arm.s"
.text
.global _start

_start:
    @MOV R0, #31 // used to rotate a bit pattern: 31 positions to the
    @ right is equivalent to 1 position to the left
    @LDR R1, =LED_BASE // base address of LED lights
    @LDR R2, =SW_BASE // base address of SW switches
    @LDR R3, =KEY_BASE // base address of KEY pushbuttons
    @LDR R4, LED_bits

    MOV R1, #4227858432 @ HEX 0xFC000000 em DEC, endereco da memoria no qual e encontrada a referencia ao endereco base para os componentes (muda a cada execucao devido a questoes de virtualizacao de memoria, chamado HW_REGS_BASE no manual)
    MOV R2, #0 @ Offset dos botoes (KEYS_BASE) em relacao a base dos componentes
    MOV R3, #96 @ HEX 0x60 em DEC, offset do conjunto de LEDs 0 (HEX0_BASE) em relacao a base dos componentes

    LDR R1, [R1] @ Muda o valor contido em R1 da referencia ao endereco base dos perifericos para o endereco em si

    ADD R2, R1, R2 @ Adiciona o offset do endereco dos botoes a base dos perifericos
    ADD R3, R1, R3 @ Adiciona o offset do endereco conjunto de LEDs 0 a base dos perifericos

DISPLAY_KEY:    LDR R4, [R2] @ Carrega o valor atual dos botoes para um registro
                STR R4, [R3] @ Guarda o valor do registro no endereco de memoria do conjunto de LEDs 0
                B DISPLAY_KEY @ Repete os dois comandos anteriores e este mesmo

@DO_DISPLAY:
@    LDR R5, [R2] // load SW switches
@    LDR R6, [R3] // load pushbutton keys
@    CMP R6, #0 // check if any key is presssed
@    BEQ NO_BUTTON
@    MOV R4, R5 // copy SW switch values onto LED displays
@    ROR R5, R5, #8 // the SW values are copied into the upper three
@    // bytes of the pattern register
@    ORR R4, R4, R5 // needed to make pattern consistent as all 32-bits
@    // of a register are rotated
@    ROR R5, R5, #8 // but only the lowest 8-bits are displayed on LEDs
@    ORR R4, R4, R5
@    ROR R5, R5, #8
@    ORR R4, R4, R5

@WAIT:
@    LDR R6, [R3] // load pushbuttons
@    CMP R6, #0
@    BNE WAIT // wait for button release

@NO_BUTTON:
@    STR R4, [R1] // store pattern to the LED displays
@    ROR R4, R0 // rotate the displayed pattern to the left
@    LDR R6, =50000000 // delay counter

@DELAY:
@    SUBS R6, R6, #1
@    BNE DELAY
@    B DO_DISPLAY

@LED_bits:
@.word 0x0F0F0F0F*/

.end