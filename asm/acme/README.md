# C64 Assembly stuff in ACME

These are some 6510 assembly experiments.

## Compiling

I am using the [acme](https://sourceforge.net/projects/acme-crossass/)
cross-assembler and GNU make.

The assembly sources can be compiled by typing `make` or, if you 
don't want to use make, by typing:

```shell
acme -f cbm --cpu 6510 -Wtype-mismatch -o <filename>.prg \ 
     <filename>.asm
```

## Running

The compiled `.prg` files can then be run in any emulator of your 
choice. For instance, with Vice:

```shell
x64sc <filename>.prg
```

This will automatically load the program as if it was read from a 
floppy disk. You will then need to start the program with a `SYS` 
command, followed by the program's address in memory. In most 
cases the address will be `4096`. However, you can check the correct 
value in the assembly source. For instance:

```nasm
*= $1000 ; starting memory location
```

`$1000` hexadecimal is `4096` in decimal.
