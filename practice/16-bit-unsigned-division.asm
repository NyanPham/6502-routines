; This routine divides a 16-bit unsigned dividend in locations
; $22 and $23 by a 16-bit divisor in locations $20 and 
; $21. The 16-bit quotient replaces the dividend. The 16-bit
; remainder is returned in locations $24 and $25. The low-order
; byte occupies the low address in all cases.

Div16U:
    lda #00
    sta $24
    sta $25
    ldx #16
NextBit:
    asl $22
    rol $23
    rol $24
    rol $25 
    sec
    lda $24
    sbc $20
    pha 
    lda $25
    sbc $21
    bcc CountDown
    inc $22
    sta $25
    pla 
    sta $24
CountDown:
    dex 
    bne NextBit
    rts