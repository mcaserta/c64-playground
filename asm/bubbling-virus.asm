; This file is intended for use with the acme cross-assembler.
; Code formatted with https://github.com/nanochess/pretty6502
; Run with SYS 4096.

*=      $1000                   ; starting memory location

chclrscr        = $93           ; clear screen
chreturn        = $0d
chcursordown    = $11
chhome          = $13
chdel           = $14
chcursoright    = $1d
chshret         = $8d
chcursorup      = $91
chcursorleft    = $9d

!addr   chrcolor = $0268        ; set character color
!addr   sidnsspd = $d40f        ; SID frequency voice 3 high byte
!addr   sidnswav = $d412        ; SID control register voice 3
!addr   sidnsval = $d41b        ; noise random value
!addr   chrout  = $ffd2         ; kernal output char
!addr   plot    = $fff0         ; set x,y cursor coordinates

        lda     #chclrscr
        jsr     chrout          ; clear the screen
        lda     #%10000000      ; set this value in:
        sta     sidnsspd        ; the noise speed hi SID register
        sta     sidnswav        ; and the noise waveform SID register
.loop   ; label for loop location
        lda     sidnsval        ; load a random value
        sta     chrcolor        ; set character color
        clc                     ; clear carry bit
        lda     sidnsval        ; load a random value
        tax                     ; transfer A to X
        lda     sidnsval        ; load a random value
        tay                     ; transfer A to Y
        jsr     plot            ; set x,y cursor coordinates
        lda     sidnsval        ; load a random value
        cmp     #chreturn       ; if return
        beq     .loop           ; repeat
        cmp     #chcursordown   ; if cursor down
        beq     .loop           ; repeat
        cmp     #chhome         ; if home
        beq     .loop           ; repeat
        cmp     #chdel          ; if del
        beq     .loop           ; repeat
        cmp     #chcursorup     ; if cursor up
        beq     .loop           ; repeat
        cmp     #chshret        ; if shift + return
        beq     .loop           ; repeat
        cmp     #chclrscr       ; if clear screen
        beq     .loop           ; repeat
        cmp     #chcursorleft   ; if cursor left
        beq     .loop           ; repeat
        cmp     #chcursoright   ; if cursor left
        beq     .loop           ; repeat
        jsr     chrout          ; output character via KERNAL routine
        jmp     .loop           ; repeat


