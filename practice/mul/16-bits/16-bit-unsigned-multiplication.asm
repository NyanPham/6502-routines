; This subroutine mutliplies the unsigned contents of locations
; $22 (low) and $23 (high) by the unsigned contents of locations
; $20 (low) and $21 (high), producing a 32-bit unsigned product
; in locations $24 (low) through $27 (high).

Mul16U:
    lda #00
    sta $26
    sta $27
    ldx #16

NextBit:
    lsr $21
    ror $20
    bcc Align
    clc 
    lda $26
    adc $22
    sta $26
    lda $27
    adc $23
    sta $27
Align:  
    lsr $27
    ror $26
    ror $25
    ror $24
    dex
    bne NextBit
    rts 