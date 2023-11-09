; This subroutine adds two multiple-byte numbers, one starting
; in location $21, the other starting in location $51. The
; result replaces the number that starts in location $21. The
; byte count is contained in location $20.

Add:
    ldy $20
    ldx #00
    clc
NextByte:
    lda $21,x
    adc $51,x 
    sta $21,x
    inx
    dey
    bne NextByte
    rts 