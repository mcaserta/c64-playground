#include <c64.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include "init.h"

#define TRUE 1
#define FALSE 0

// display modes
#define DM_FUL 0
#define DM_BIN 1
#define DM_HEX 2
#define DM_DNA 3

static unsigned char displaymode = DM_FUL;

typedef struct {
  unsigned char x; // head column
  unsigned char y; // head row
  unsigned char count; // current cycle number
  unsigned char cycles; // total number of cycles
  unsigned char len; // total length = head + tail
} comet_t;

unsigned char randglyph(void) {
  unsigned char glyph = rand();
  
  switch(displaymode) {
    case DM_FUL: break;
    case DM_BIN: glyph = glyph >> 7 == 0 ? '0' : '1'; break;
    case DM_HEX: 
                 glyph = glyph >> 4;
                 if (glyph < 10) {
                   glyph = glyph + 48;
                 } else {
                   glyph = glyph - 9;
                 }
                 break;
    case DM_DNA:
                 glyph = glyph >> 6;
                 switch(glyph) {
                   case 0: glyph = 'a'; break;
                   case 1: glyph = 'c'; break;
                   case 2: glyph = 'g'; break;
                   case 3: glyph = 't'; break;
                 }
                 break;
  }
  return glyph;
}

unsigned char randcolumn(void) {
  unsigned char col;

  do {
    col = rand();
    col = col >> 2;
  } while (col > 39);

  return col;
}

unsigned char randheadcolor() {
  unsigned char c = rand();
  c = c >> 6;

  switch (c) {
    case 0: return COLOR_WHITE;
    case 1: return COLOR_CYAN;
    case 2: return COLOR_GREEN;
    case 3: return COLOR_LIGHTGREEN;
  }
}

unsigned char randtailcolor() {
  unsigned char c = rand();
  c = c >> 7;

  switch (c) {
    case 0: return COLOR_GREEN;
    case 1: return COLOR_LIGHTGREEN;
  }
}

unsigned char randlen(void) {
  unsigned char len = rand();
  len = len >> 4;
  return len;
}

void printcomet(comet_t * c) {
  printf("x=%i, y=%i, count=%i, cycles=%i, len=%i\n", c->x, c->y, c->count, c->cycles, c->len);
}

int main(void) {
  comet_t comets[80];
  unsigned char i, c = 0;

  init();

  for (i = 0; i < 80; i++) {
    comets[i].x = randcolumn();
    comets[i].y = 0;
    comets[i].count = 0;
    comets[i].cycles = rand();
    comets[i].len = randlen();
  //  printcomet(&comets[i]);
  }
  
  do {
    if (kbhit()) {
      switch(cgetc()) {
        case 'b': displaymode = DM_BIN; break;
        case 'd': displaymode = DM_DNA; break;
        case 'q': clrscr(); return EXIT_SUCCESS; break;
        case 'f': displaymode = DM_FUL; break;
        case 'h': displaymode = DM_HEX; break;
      }
    }
    
    for (i = 0; i < 80; i++) {
      if (comets[i].count == comets[i].cycles) {
        textcolor(randtailcolor());
        cputcxy(comets[i].x, comets[i].y, randglyph());
        comets[i].count = 0;
        comets[i].y++;
        if (comets[i].y == 25) {
          comets[i].y = 0;
        }
        continue;
      }
      textcolor(randheadcolor());
      cputcxy(comets[i].x, comets[i].y, randglyph());
      comets[i].count++;
    }
    
  } while (TRUE);

  return EXIT_SUCCESS;
}

