; This file is intended for use with the acme cross-assembler.
; Code formatted with https://github.com/nanochess/pretty6502
; Run with SYS 4096.

*=      $1000                   ; starting memory location

black           = $00           ; the color black
white           = $01           ; the color white
chclrscr        = $93           ; clear screen

!addr   zpfb    = $fb           ; zero page address $fb
!addr   zpfc    = $fc           ; zero page address $fc
!addr   zpfd    = $fd           ; zero page address $fd
!addr   zpfe    = $fe           ; zero page address $fe
!addr   scrmem  = $0400         ; start of mapped screen character memory
!addr   scrmode = $d011         ; screen mode
!addr   rasterln = $d012        ; current raster line
!addr   bordercl = $d020        ; screen outer border color
!addr   bordrcl1 = $d021        ; background color #1
!addr   bordrcl2 = $d022        ; background color #2
!addr   bordrcl3 = $d023        ; background color #3
!addr   bordrcl4 = $d024        ; background color #4
!addr   sidnsspl = $d40e        ; SID frequency voice 3 low byte
!addr   sidnssph = $d40f        ; SID frequency voice 3 high byte
!addr   sidnswav = $d412        ; SID control register voice 3
!addr   sidnsval = $d41b        ; SID noise random value
!addr   colorram = $d800        ; start of mapped screen color memory

.init   ; initialization
        jsr     .sids           ; init SID for pseudo random number generation
        lda     #black          ; set black
        sta     bordercl        ; as border color

.strt   ; start of outer loop location
        jsr     .prcg           ; set random color
        sta     bordrcl1        ; as char background color 1
        jsr     .prcg           ; set random color
        sta     bordrcl2        ; as char background color 2
        jsr     .prcg           ; set random color
        sta     bordrcl3        ; as char background color 3
        jsr     .prcg           ; set random color
        sta     bordrcl4        ; as char background color 4
        lda     scrmode         ; load screen mode configuration in accumulator
        ora     #$40            ; set the extended color mode flag
        sta     scrmode         ; set screen mode with extended color mode flag set
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

.loop   ; start of inner loop location
        jsr     .prng           ; load pseudo random number in register A
        tay                     ; transfer value of register A to register Y
        jsr     .prng           ; load pseudo random number in register A
        sta     (zpfb),y        ; write random character in raw screen memory at
        jsr     .prcg           ; load pseudo random color in register A
        sta     (zpfd),y        ; write random color in raw screen memory at
        inc     zpfc            ; increment char memory page
        inc     zpfe            ; increment color memory page
        dex                     ; decrement memory page index
        bne     .loop           ; if memory page index > 0, branch to loop label
        jmp     .strt           ; repeat from start

.sids   ; setup sid for noise generation
        lda     #$ff            ; max out
        sta     sidnsspl        ; the noise speed low SID register
        sta     sidnssph        ; the noise speed high SID register
        lda     #%10000000      ; set noise generator mode in:
        sta     sidnswav        ; the waveform SID register
        rts                     ; return from subroutine

.prng   ; pseudo random number generator
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        rts                     ; register A is now holding a pseudo random number

.prcg   ; pseudo random color generator
        ; picks all 16 colors except black (0) and white (1)
        jsr     .prng           ; load pseudo random number in register A
        !for    i, 1, 4 { lsr } ; right shift 4 times, so we get a 4 bits value
        cmp     #black          ; if black
        beq     .prcg           ; try again
        cmp     #white          ; if white
        beq     .prcg           ; try again
        rts                     ; register A is now holding a pseudo random color number

