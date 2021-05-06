; This file is intended for use with the acme cross-assembler.
; Code formatted with https://github.com/nanochess/pretty6502
; Run with SYS 4096.

*=      $1000                   ; starting memory location

chclrscr        = $93           ; clear screen

!addr   zpfb     = $fb          ; zero page address $fb
!addr   zpfc     = $fc          ; zero page address $fc
!addr   zpfd     = $fd          ; zero page address $fd
!addr   zpfe     = $fe          ; zero page address $fe
!addr   chrcolor = $0268        ; set character color
!addr   scrmem   = $0400        ; start of mapped screen character memory
!addr   rasterln = $d012        ; current raster line
!addr   bordercl = $d020        ; screen outer border color
!addr   sidnsspl = $d40e        ; SID frequency voice 3 high byte
!addr   sidnssph = $d40f        ; SID frequency voice 3 high byte
!addr   sidnswav = $d412        ; SID control register voice 3
!addr   sidnsval = $d41b        ; SID noise random value
!addr   colorram = $d800        ; start of mapped screen color memory

        jsr .sids
.strt
        ldx     #$04  
        lda     #$00
        sta     zpfb
        sta     zpfd
        lda     #$04
        sta     zpfc
        lda     #$d8
        sta     zpfe

.loop   ; label for loop location
        jsr     .rand            ; load pseudo random number in register A
        tay                     ; transfer value of register A to register X
        jsr     .rand            ; load pseudo random number in register A
        sta     (zpfb),y        ; write random character in raw screen memory at 
        sta     (zpfd),y        ; write random character in raw screen memory at 
        inc     zpfc 
        inc     zpfe 
        dex
        bne     .loop
        jmp     .strt           ; repeat

.sids   ; setup sid for noise generation
        lda     #$ff            ; max out
        sta     sidnsspl        ; the noise speed low SID register
        sta     sidnssph        ; the noise speed high SID register
        lda     #%10000000      ; set noise generator mode in:
        sta     sidnswav        ; the waveform SID register
        rts

.rand   ; pseudo random number generator
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        rts                     ; register A is now holding a pseudo random number

