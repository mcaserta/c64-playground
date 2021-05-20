#include <c64.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include "init.h"
#include "random.h"

#define TRUE 1
#define FALSE 0

// display modes
#define DM_FUL 0
#define DM_BIN 1
#define DM_HEX 2
#define DM_DNA 3

#define NUM_COMETS 40

typedef struct {
  unsigned char x; // head column
  unsigned char y; // head row
  unsigned char count; // current cycle number
  unsigned char cycles; // total number of cycles
  unsigned char len; // total length = head + tail
} comet_t;

static unsigned char displaymode = DM_FUL;
static comet_t comets[NUM_COMETS];

unsigned char randglyph(void) {
  unsigned char glyph = prng();
  
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
    col = prng();
    col = col >> 2;
  } while (col > 39);

  return col;
}

unsigned char randheadcolor() {
  unsigned char c = prng();
  c = c >> 6;

  switch (c) {
    case 0: return COLOR_WHITE;
    case 1: return COLOR_CYAN;
    case 2: return COLOR_GREEN;
    case 3: return COLOR_LIGHTGREEN;
  }
}

unsigned char randtailcolor() {
  unsigned char c = prng();
  c = c >> 7;

  switch (c) {
    case 0: return COLOR_GREEN;
    case 1: return COLOR_LIGHTGREEN;
  }
}

unsigned char randcycles(void) {
  unsigned char cycles = prng();

  cycles = cycles >> 4;

  if (cycles < 4) {
    cycles = 3;
  }
  return cycles;
}

unsigned char randlen(void) {
  unsigned char len = prng();
  len = len >> 4;

  if (len < 7) {
    len = 6;
  }
  return len;
}

void initcomets(void) {
  unsigned char i;

  for (i = 0; i < 40; i++) {
    comets[i].x = randcolumn();
    comets[i].y = 0;
    comets[i].count = 0;
    comets[i].cycles = randcycles();
    comets[i].len = randlen();
  }
}

void __fastcall__ drawglyph(unsigned char x, unsigned char y, unsigned char glyph, unsigned char color) {
  if (x < 40 && y < 25 && color < 16) {
//    printf("x=%02d, y=%02d, g=%03d, c=%02d\n", x, y, glyph, color);
    textcolor(color);
    cputcxy(x, y, glyph);
  }
}

int main(void) {
  unsigned char i;

  init();
  initcomets();

  do {
    if (kbhit()) {
      clrscr();

      switch(cgetc()) {
        case 'b': displaymode = DM_BIN; break;
        case 'd': displaymode = DM_DNA; break;
        case 'q': return EXIT_SUCCESS; break;
        case 'f': displaymode = DM_FUL; break;
        case 'h': displaymode = DM_HEX; break;
      }
      initcomets();
    }
    
    for (i = 0; i < NUM_COMETS; i++) {
      if (comets[i].count == comets[i].cycles) {
        drawglyph(comets[i].x, comets[i].y, randglyph(), randtailcolor());
        comets[i].count = 0;
        if (comets[i].y > comets[i].len) {
          drawglyph(comets[i].x, comets[i].y - comets[i].len - 1, ' ', COLOR_BLACK);
        }
        comets[i].y++;
        if (comets[i].y == 40) {
          comets[i].x = randcolumn();
          comets[i].y = 0;
          comets[i].cycles = randcycles();
          comets[i].len = randlen();
        }
        continue;
      }

      drawglyph(comets[i].x, comets[i].y, randglyph(), randheadcolor());
      comets[i].count++;
    }
  } while (TRUE);

  return EXIT_SUCCESS;
}

