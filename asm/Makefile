ASM=acme
ASMFLAGS=-f cbm --cpu 6510 -Wtype-mismatch

.PHONY: all
all: prgs

%.prg: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

prgs: bubbling-virus.prg

.PHONY: clean
clean:
	rm -rf *.prg
