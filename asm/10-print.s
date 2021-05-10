SID1            = $d40f         ; SID register
SID2            = $d412         ; other SID register
PRNG            = $d41b
PUTC            = $ffd2

        lda     #$80            ; set this value in:
        sta     SID1            ; the noise speed hi SID register
        sta     SID2            ; and the noise waveform SID register
loop:
        lda     PRNG            ; load a random value
        and     #1              ; lose all but the low bit
        adc     #$6d            ; value of "\" PETSCII
        jsr     PUTC            ; output character via KERNAL routine
        bne     loop            ; repeat
