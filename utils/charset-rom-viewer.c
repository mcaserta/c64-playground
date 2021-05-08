#include <stdio.h>

#define BUFSZ 8

void dump(unsigned char c, unsigned int addr) {
  printf(c & 0b10000000 ? " " : "#");
  printf(c & 0b01000000 ? " " : "#");
  printf(c & 0b00100000 ? " " : "#");
  printf(c & 0b00010000 ? " " : "#");
  printf(c & 0b00001000 ? " " : "#");
  printf(c & 0b00000100 ? " " : "#");
  printf(c & 0b00000010 ? " " : "#");
  printf(c & 0b00000001 ? " " : "#");
  printf(" 0x%04x\n", addr);
}

int main(int argc, char ** argv) {

  unsigned char buf[BUFSZ] = { 0 };
  unsigned int charcount = 0;
  size_t bytes = 0, i, readsz = sizeof buf;
  FILE * fp = argc > 1 ? fopen(argv[1], "rb") : stdin;

  if (!fp) {
    fprintf(stderr, "error: file open failed '%s'.\n", argv[1]);
    return 1;
  }

  /* read/output BUFSZ bytes at a time */
  while ((bytes = fread(buf, sizeof * buf, readsz, fp)) == readsz) {
    for (i = 0; i < readsz; i++)
      dump(buf[i], charcount * 8 + i);
    printf("\n======== #%i\n\n", charcount++);
  }
  for (i = 0; i < bytes; i++) /* output final partial buf */
    dump(buf[i], charcount * 8 + i);
  putchar('\n');

  if (fp != stdin)
    fclose(fp);

  return 0;
}
