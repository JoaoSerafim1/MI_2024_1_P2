#ifndef test_lib.h
#define test_lib.h

extern void DP(unsigned int x, unsigned int y, unsigned int cor, unsigned int forma, unsigned int tamanho);

extern void WBM(unsigned int x, unsigned int y, unsigned int rgb);

extern void WBR_BACKGROUND(unsigned int rgb);

extern void WBR_SPRITE(unsigned int registrador, unsigned int offset, unsigned int x, unsigned int y, unsigned int sp);

extern void WSM(unsigned int endereco, unsigned int cor);

#endif