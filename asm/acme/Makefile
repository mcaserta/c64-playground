ASM=acme
ASMFLAGS=-f cbm --cpu 6510 -Wtype-mismatch

.PHONY: all
all: prgs

%.prg: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

prgs: 10-print.prg bubbling-virus.prg the-matrix.prg virus-2.prg

.PHONY: clean
clean:
	rm -rf *.prg
