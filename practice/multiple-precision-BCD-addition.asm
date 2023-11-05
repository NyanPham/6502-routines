; This subroutine adds two multiple-byte BCD numbers, one starting
; in location $21, the other starting in location $51. The result
; replaces the number that starts in location $21. The byte
; count is contained in location $20.

AddBCD:
    ldy $20
    ldx #00
    clc
    sed
NextByte:
    lda $21,x
    adc $51,x
    sta $21,x
    inx
    dey 
    bne NextByte
    cld
    rts 