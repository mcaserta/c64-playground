zp01            = $01           ; zero page address $01, used in the charset loading routine
charaddr        = $d018         ; character set memory address pointer

_lcc1:  ; load custom character set 1
.export _lcc1
        lda     zp01            ; this does some dark magic with
        ora     #4              ; the memory mapping in order to
        sta     zp01            ; make the VIC-II point to the
        lda     charaddr        ; character set we're loading
        and     #$f0            ; at $3000
        ora     #$0c
        sta     charaddr
        rts

_lcc2:  ; load custom character set 2
.export _lcc2
        lda     zp01            ; this does some dark magic with
        ora     #4              ; the memory mapping in order to
        sta     zp01            ; make the VIC-II point to the
        lda     charaddr        ; character set we're loading
        and     #$f0            ; at $2800
        ora     #$0a
        sta     charaddr
        rts

.segment "CHARSET1"
.incbin "../roms/matrix-mirrored.bin"

.segment "CHARSET2"
.incbin "../roms/matrix.bin"
