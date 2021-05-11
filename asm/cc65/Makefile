ASM=cl65
ASMFLAGS=-u __EXEHDR__ -t c64 -C c64-asm.cfg
C1541=c1541

.PHONY: all
all: 10-print.d64

%.prg: %.s
	$(ASM) -o $@ $(ASMFLAGS) $<

%.d64: %.prg
	$(C1541) -format '$@,00' d64 $@ -attach $@ -write $< $@

.PHONY: clean
clean:
	rm -rf *.prg *.d64 *.o
