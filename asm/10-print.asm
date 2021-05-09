*= $1000 ; starting memory location

!addr sid1  = $d40f
!addr sid2  = $d412
!addr prng  = $d41b
!addr putc  = $ffd2

    lda #$80  ; set this value in:
    sta sid1  ; the noise speed hi SID register
    sta sid2  ; and the noise waveform SID register
.loop         ; label for loop location
    lda prng  ; load a random value
    and #1    ; lose all but the low bit
    adc #$6d  ; value of "\" PETSCII
    jsr putc  ; output character via KERNAL routine
    bne .loop ; repeat
