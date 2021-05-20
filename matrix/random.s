rasterln        = $d012         ; current raster line
sidnsspl        = $d40e         ; SID frequency voice 3 low byte
sidnssph        = $d40f         ; SID frequency voice 3 high byte
sidnswav        = $d412         ; SID control register voice 3
sidnsval        = $d41b         ; SID noise random value

_sids:  ; setup sid for noise generation
.export _sids
        lda     #$ff            ; max out
        sta     sidnsspl        ; the noise speed low SID register
        sta     sidnssph        ; the noise speed high SID register
        lda     #%10000000      ; set noise generator mode in:
        sta     sidnswav        ; the waveform SID register
        rts                     ; return from subroutine

_prng:  ; pseudo random number generator
.export _prng
        lda     sidnsval        ; load a random value from SID noise generator
        eor     rasterln        ; perform an exclusive or with current raster line
        rts                     ; register A is now holding a pseudo random number

