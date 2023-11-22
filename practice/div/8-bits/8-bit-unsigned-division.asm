; This routine divides an 8-bit unsigned dividend in location
; $21 by an 8-bit unsigned divisor in location $20. The 8-bit
; quotient is returned in location $21, replacing the dividend,
; and the 8-bit remainder is returned in location $22.
    
Div8U:
    lda #00
    ldx #08
NextBit:
    asl $21
    rol a 
    cmp $20
    bcc Countdown

    sbc $20
    inc $21
Countdown:  
    dex
    bne NextBit
    sta $22
    rts 