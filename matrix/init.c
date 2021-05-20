#include <c64.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include "init.h"
#include "random.h"

void init(void) {
    clrscr(); // clear screen
    bgcolor(COLOR_BLACK);
    bordercolor(COLOR_BLACK);
    lccs(); // load custom charset
    sids(); // setup sid for pseudo random number generation
}

