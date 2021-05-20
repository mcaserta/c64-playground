#include <c64.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>

extern void cdecl lccs(void); // load custom charset

void init(void) {
    clrscr(); // clear screen
    bgcolor(COLOR_BLACK);
    bordercolor(COLOR_BLACK);
    lccs(); // load custom charset
}

