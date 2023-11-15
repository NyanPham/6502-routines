; This subroutine subtracts two multiple-byte numbers, one starting
; in location $51 from a multiple-byte number starting in location 
; $21. The result replaces the number that starts in 
; location $21. The byte count is contained in location $20.

MPSub:
    ldy $20
    ldx #00
    sec 
NextByte:
    lda $21,x
    sbc $51,x 
    sta $21,x
    inx
    dey
    bne NextByte
    rts 