; This file is intended for use with the cc65 cross-assembler.
; Code formatted with https://github.com/nanochess/pretty6502

.macpack        generic

black           = $00           ; the color black
white           = $01           ; the color white
binmod          = $00           ; display mode: binary
hexmod          = $01           ; display mode: hex
rndmod          = $02           ; display mode: random

zp01            = $01           ; zero page address $01
zp02            = $02           ; zero page address $02, we use this to store the display mode
zpb0            = $b0           ; zero page address $b0, we use this to store the delay amount
zpb1            = $b1           ; zero page address $b1, delay counter
zpfb            = $fb           ; zero page address $fb
zpfc            = $fc           ; zero page address $fc
zpfd            = $fd           ; zero page address $fd
zpfe            = $fe           ; zero page address $fe
keybuffr        = $0289         ; keyboard buffer
keyrpeat        = $028a         ; key repeat
rasterln        = $d012         ; current raster line
charaddr        = $d018         ; character set memory address pointer
bordercl        = $d020         ; screen outer border color
bordrcl1        = $d021         ; background color #1
sidnsspl        = $d40e         ; SID frequency voice 3 low byte
sidnssph        = $d40f         ; SID frequency voice 3 high byte
sidnswav        = $d412         ; SID control register voice 3
sidnsval        = $d41b         ; SID noise random value
keyscan         = $ff9f         ; scan keyboard - kernal routine
keyread         = $ffe4         ; read keyboard buffer - kernal routine

init:   ; initialization
        jsr     sids            ; init SID for pseudo random number generation
        jsr     lccs            ; load japanese character set
        lda     #black          ; set black
        sta     bordercl        ; as border color
        sta     bordrcl1        ; as screen background color
        lda     #1
        sta     keybuffr        ; disable keyboard buffer
        lda     #127
        sta     keyrpeat        ; disable key repeat
        lda     #rndmod
        sta     zp02            ; start in random display mode
        lda     #$7f
        sta     zpb0            ; start in mid speed mode

strt:   ; start of outer loop location
        ldx     #$04            ; initialize register X with 4
                                ; we will later use this register to index
                                ; the screen char and color address pages
        lda     #$00            ; initialize zero page addresses $fb-$fc with
        sta     zpfb            ; the screen character ($0400) and $fd-$fe with
        sta     zpfd            ; with color ($d800) addresses
        lda     #$04
        sta     zpfc
        lda     #$d8
        sta     zpfe

loop:   ; start of inner loop location
        jsr     dlay            ; introduce delay
        jsr     prng            ; load pseudo random number in register A
        tay                     ; transfer value of register A to register Y
        lda     zp02            ; read display mode
        cmp     #binmod
        beq     bina
        cmp     #hexmod
        beq     hexa
        cmp     #rndmod
        beq     rnda
reta:
        jsr     genc            ; load pseudo random color in register A
        sta     (zpfd),y        ; write random color in raw screen memory
        inc     zpfc            ; increment char memory page
        inc     zpfe            ; increment color memory page
        dex                     ; decrement memory page index
        bne     loop            ; if memory page index > 0, branch to loop label
        jsr     keyb            ; read keyboard
        jmp     strt            ; repeat from start

bina:   ; write binary char to screen memory
        jsr     genb
        sta     (zpfb),y        ; write character in raw screen memory
        jmp     reta

hexa:   ; write hex char to screen memory
        jsr     genx
        sta     (zpfb),y        ; write character in raw screen memory
        jmp     reta

rnda:   ; write random char to screen memory
        jsr     prng
        sta     (zpfb),y        ; write character in raw screen memory
        jmp     reta

keyb:   ; keyboard reading routine
        jsr     keyscan
        jsr     keyread
        cmp     #$42            ; 'B'
        beq     binm            ; binary display mode
        cmp     #$43            ; 'C'
        beq     clsc            ; clear screen
        cmp     #$44            ; 'D'
        beq     mids            ; middle speed mode
        cmp     #$46            ; 'F'
        beq     fast            ; fast mode
        cmp     #$4d            ; 'M'
        beq     col1            ; increment background color
        cmp     #$4e            ; 'N'
        beq     col2            ; increment border color
        cmp     #$51            ; 'Q'
        beq     quit            ; return to basic
        cmp     #$52            ; 'R'
        beq     rndm            ; random display mode
        cmp     #$53            ; 'S'
        beq     slow            ; slow mode
        cmp     #$58            ; 'X'
        beq     hexm            ; hex display mode
        rts

binm:   ; sets binary display mode
        lda     #binmod
        sta     zp02
        rts

hexm:   ; sets hex display mode
        lda     #hexmod
        sta     zp02
        rts

rndm:   ; sets random display mode
        lda     #rndmod
        sta     zp02
        rts

col1:   ; increment background color
        inc     bordrcl1
        rts

col2:   ; increment border color
        inc     bordercl
        rts

quit:   ; well... I guess this returns to basic
        brk                     ; return to basic

fast:   ; fast mode
        lda     #$01
        sta     zpb0
        rts

mids:   ; middle speed mode
        lda     #$7f
        sta     zpb0
        rts

slow:   ; slow mode
        lda     #$00
        sta     zpb0
        rts

clsc:   ; clear screen
        ldx     #$ff            ; inner loop counter
        ldy     #$00
        lda     #$14            ; repeat inner loop this many times
        pha
clsl:   ; clear screen start of loop
        jsr     prng
        sta     zpfb
        jsr     pr2g
        add     #$04
        sta     zpfc
        lda     #$20
        sta     (zpfb),y        ; write character in raw screen memory
        jsr     dlay
        dex
        bne     clsl
        pla
        sub     #$01
        bne     cls2
        rts
cls2:
        pha
        jmp     clsl

sids:   ; setup sid for noise generation
        lda     #$ff            ; max out
        sta     sidnsspl        ; the noise speed low SID register
        sta     sidnssph        ; the noise speed high SID register
        lda     #%10000000      ; set noise generator mode in:
        sta     sidnswav        ; the waveform SID register
        rts                     ; return from subroutine

prng:   ; pseudo random number generator
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        rts                     ; register A is now holding a pseudo random number

prbg:   ; pseudo random bit generator
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        and     #$01            ; mask the rightmost bit
        rts                     ; register A is now holding a pseudo random bit

pr2g:   ; pseudo random 2 bit value generator (0-3)
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        .repeat    6 
        lsr  ; shift bits right 4 times
        .endrep
        rts                     ; register A is now holding a pseudo random 2 bit value

preg:   ; pseudo random nibble generator
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        .repeat    4 
        lsr  ; shift bits right 4 times
        .endrep
        rts                     ; register A is now holding a pseudo random nibble

genc:   ; generate random color
        ; picks from green ($05) and light green ($0d)
        jsr     prbg            ; load pseudo random bit in register A
        cmp     #$00            ; if off
        beq     slg             ; branch to set light green
        lda     #$05            ; set green
        rts                     ; return from subroutine
slg:
        lda     #$0d            ; set light green
        rts                     ; return from subroutine

genb:   ; generate random binary char (0/1)
        jsr     prbg            ; load pseudo random bit in register A
        adc     #47             ; make it either a 0 or a 1 character
        rts                     ; return from subroutine

genx:   ; generate random hexadecimal char (0-9,a-f)
        jsr     preg            ; load pseudo random nibble in register A
        cmp     #$00
        beq     rt00
        cmp     #$01
        beq     rt01
        cmp     #$02
        beq     rt02
        cmp     #$03
        beq     rt03
        cmp     #$04
        beq     rt04
        cmp     #$05
        beq     rt05
        cmp     #$06
        beq     rt06
        cmp     #$07
        beq     rt07
        cmp     #$08
        beq     rt08
        cmp     #$09
        beq     rt09
        cmp     #$0a
        beq     rt0a
        cmp     #$0b
        beq     rt0b
        cmp     #$0c
        beq     rt0c
        cmp     #$0d
        beq     rt0d
        cmp     #$0e
        beq     rt0e
        cmp     #$0f
        beq     rt0f
        rts

rt00:
        lda     #48
        rts
rt01:
        lda     #49
        rts
rt02:
        lda     #50
        rts
rt03:
        lda     #51
        rts
rt04:
        lda     #52
        rts
rt05:
        lda     #53
        rts
rt06:
        lda     #54
        rts
rt07:
        lda     #55
        rts
rt08:
        lda     #56
        rts
rt09:
        lda     #57
        rts
rt0a:
        lda     #01
        rts
rt0b:
        lda     #02
        rts
rt0c:
        lda     #03
        rts
rt0d:
        lda     #04
        rts
rt0e:
        lda     #05
        rts
rt0f:
        lda     #06
        rts

lccs:   ; load custom character set
        lda     zp01            ; this does some dark magic with
        ora     #4              ; the memory mapping in order to
        sta     zp01            ; make the VIC-II point to the
        lda     charaddr        ; character set we're loading
        and     #240            ; at $3000
        ora     #12
        sta     charaddr
        rts

dlay:   ; delay
        lda     zpb0
        sta     zpb1
dlal:
        dec     zpb1        
        bne     dlal
        rts

.segment "CHARSET"
.incbin "../../roms/characters.906143-02.bin"
