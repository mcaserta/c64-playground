CC=gcc
CFLAGS= -O1 -g -Wall

charset-rom-viewer: charset-rom-viewer.c
	$(CC) $(CFLAGS) -o $@ $<

charset-rom-mirror: charset-rom-mirror.c
	$(CC) $(CFLAGS) -o $@ $<

all: charset-rom-viewer charset-rom-mirror

clean: 
	rm -fr charset-rom-viewer charset-rom-mirror *.dSYM
