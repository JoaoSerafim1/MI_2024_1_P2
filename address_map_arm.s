/*BASE ADDRESS*/
        .equ    ALT_LWFPGASLVS_OFST,    0xFF200000
        .equ    HW_REGS_BASE,           0xFC000000
        .equ    HW_REGS_SPAN,           0x04000000

/*GPU*/
        .equ    DATA_B,                 0x70
        .equ    DATA_A,                 0x80
        .equ    RESET_PULSECOUNTER,     0x90
        .equ    SCREEN,                 0xA0
        .equ    WRFULL,                 0xB0
        .equ    WRREG,                  0xC0

/*LEDS*/
        .equ    HEX5_BASE,              0x10
        .equ    HEX4_BASE,              0x20
        .equ    HEX3_BASE,              0x30
        .equ    HEX2_BASE,              0x40
        .equ    HEX1_BASE,              0x50
        .equ    HEX0_BASE,              0x60

/*PUSH_BUTTONS*/
        .equ    KEYS_BASE,              0x0