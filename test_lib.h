#ifndef test_lib.h
#define test_lib.h
extern int file_open();
extern int file_close(unsigned int dir);

extern int mem_map(unsigned int dir);
extern int mem_unmap(unsigned int base_virtual_address, unsigned int dir);

extern int video_wbrsprite(unsigned int base_virtual_address, int offset, int x, int y, int sp);
extern int video_wbrbackground(unsigned int base_virtual_address, int color);
extern int video_wsm(unsigned int base_virtual_address, int base_sprite_address, int color);
extern int video_wbm(unsigned int base_virtual_address, int ix, int iy, int color);
extern int video_dp_square_20x20(unsigned int base_virtual_address, int x, int y, int color);

#endif
