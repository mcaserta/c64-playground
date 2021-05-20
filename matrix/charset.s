zp01            = $01           ; zero page address $01, used in the charset loading routine
charaddr        = $d018         ; character set memory address pointer

_lccs:  ; load custom character set
.export _lccs
        lda     zp01            ; this does some dark magic with
        ora     #4              ; the memory mapping in order to
        sta     zp01            ; make the VIC-II point to the
        lda     charaddr        ; character set we're loading
        and     #240            ; at $3000
        ora     #12
        sta     charaddr
        rts

.segment "CHARSET"
.incbin "../roms/c64_japanese_upper-kanji.bin"
.incbin "../roms/vic-20_japanese_upper-kanji.bin"
