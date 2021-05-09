# Turbo Tape

## History

The original C64 [Turbo Tape](https://en.wikipedia.org/wiki/Fast_loader)
software had an iconic effect which made the screen border flash with colors.

I now understand why: it only requires one cpu instruction (well... if
you exclude the loop setup):

```
.loop     inc    $d020
          jmp    .loop
```

I think this must have been used by the old timers as a debugging technique:
you only needed to throw an `inc $d020` in a subroutine that did something
boring (like reading from tape) and you had a visual feedback that your
assembly loop was running okay. Not only that: by the speed and the patterns in
the flashing border you could see how fast the iterations were going. Brilliant,
isn't it?

## How to Turbo Tape (sort of...)

Open the [Vice
monitor](https://codebase64.org/doku.php?id=base:using_the_vice_monitor) and
type:

```
a $2000 inc $d020
jmp $2000
(enter an empty line)
m 2000 2005
>C:2000  ee 20 d0 4c  00 20
g 2000
```

Let's go through each step:

1. `a $2000 inc $d020`: we are telling the monitor to assemble (a) at memory
   address `$2000` the instruction `inc` (increment, as in "add 1") the value
   at memory address `$d020`. `$2000` is just a convenient memory address to
   store our little program and `$d020` is the location in memory where the
   outer border color is set. Incrementing that value will cycle through all
   the available colors. As the memory location has a size of 1 byte, the
   increment instruction will bring the value from 0 to 255 in 1 increment
   steps. When 255 is reached, the value wraps back to 0 and the cycle starts
   back. The C64 only has 16 colors so what happens when the value hits 16? The
   color cycle wraps and 16 is read as it was 0 (black) and so on.
2. we are still assembling here: `jmp $2000` is an unconditional jump to memory
   location `$2000` which is the start of our program. This means that the PC
   (Program Counter) register is set to `$2000` so that on the next cycle the
   cpu will read its next instruction from there. In other words, this is an
   infinite loop.
3. entering an empty line signals the monitor that we are done assembling and
   we want to go back to normal mode.
4. `m 2000 2005`: we are telling the monitor to make us a memory dump of
   addresses from `$2000` to `$2005`.
5. the monitor shows us that the memory contains the values `ee 20 d0 4c 00
   20`. This is how our 2 line assembly program is represented in memory.
   Let's look at each byte individually:
   - `ee` is the `inc` processor opcode and is followed by its input address
   which is `20 d0`, which is simply `$d020` as the processor very much likes
   to read 16 bit wide addresses starting with the least significant 8 bits.
   Let me explain: if your address is `$d020`, you split it into 2 separate
   bytes: `$d0` and `$20` and then swap them: `$20` `$d0`. This is the cpu
   representation format.
   - `4c` is the `jmp` processor opcode and is also followed by its input
  address which is `00 20`, or `$2000` as we saw how 16 bit memory addresses
  are represented in memory for the processor.  
6. in the last line we are telling the monitor to set the PC (Program Counter)
  to address `$2000` and start execution from there. By running this command
  you should see the border effect in action on screen. 

The whole program takes 6 bytes.

## Basic version

Can we do all this in basic? Sure. First of all, let's convert our hexadecimal
values in our more familiar decimal format:

- `$2000 = 8192`
- `$ee = 238`
- `$d0 = 208`
- `$20 = 32`
- `$4c = 76`

With this conversion table in mind, we can now write a little basic program
that writes our binary code in memory:

```basic
10 a = 8192
20 poke a, 238
30 poke a + 1, 32
40 poke a + 2, 208
50 poke a + 3, 76
60 poke a + 4, 0
70 poke a + 5, 32

run

sys 8192
```

When we issue the `run` command, the basic program executes and the memory gets
set up exactly as we did in the Vice monitor using the assembler.

Now we only need to tell the system to jump to memory location 8192 and start
execution from there, just as we did by typing `g 2000` in the monitor.
