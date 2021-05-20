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

#define COLOR_MODE_GREEN 0
#define COLOR_MODE_AMBER 1
#define COLOR_MODE_LGBTQ 2

#define NUM_COMETS 80

typedef struct {
  unsigned char x; // head column
  unsigned char y; // head row
  unsigned char count; // current cycle number
  unsigned char cycles; // total number of cycles
  unsigned char len; // total length = head + tail
} comet_t;

static unsigned char displaymode = DM_FUL;
static unsigned char colormode = COLOR_MODE_GREEN;
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

  switch(colormode) {
    case COLOR_MODE_GREEN:
      c = c >> 6;
      switch (c) {
        case 0: return COLOR_WHITE;
        case 1: return COLOR_CYAN;
        case 2: return COLOR_GREEN;
        case 3: return COLOR_LIGHTGREEN;
      }
    case COLOR_MODE_AMBER:
      c = c >> 6;
      switch (c) {
        case 0: return COLOR_RED;
        case 1: return COLOR_VIOLET;
        case 2: return COLOR_ORANGE;
        case 3: return COLOR_LIGHTRED;
      }
  }

  return c;
}

unsigned char randtailcolor() {
  unsigned char c = prng();

  switch(colormode) {
    case COLOR_MODE_GREEN:
      c = c >> 7;
      switch (c) {
        case 0: return COLOR_GREEN;
        case 1: return COLOR_LIGHTGREEN;
      }
    case COLOR_MODE_AMBER:
      c = c >> 7;
      switch (c) {
        case 0: return COLOR_ORANGE;
        case 1: return COLOR_LIGHTRED;
      }
  }

  c = c >> 4;
  return c;
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

  for (i = 0; i < NUM_COMETS; i++) {
    comets[i].x = randcolumn();
    comets[i].y = 0;
    comets[i].count = 0;
    comets[i].cycles = randcycles();
    comets[i].len = randlen();
  }
}

void __fastcall__ drawglyph(unsigned char x, unsigned char y, unsigned char glyph, unsigned char color) {
  if (x < 40 && y < 25 && color < 16) {
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
        case 'a': colormode = COLOR_MODE_AMBER; break;
        case 'b': displaymode = DM_BIN; lcc2(); break;
        case 'd': displaymode = DM_DNA; lcc2(); break;
        case 'g': colormode = COLOR_MODE_GREEN; break;
        case 'l': colormode = COLOR_MODE_LGBTQ; break;
        case 'q': return EXIT_SUCCESS; break;
        case 'f': displaymode = DM_FUL; lcc1(); break;
        case 'h': displaymode = DM_HEX; lcc2(); break;
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

