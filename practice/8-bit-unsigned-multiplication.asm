; This subroutine multiplies an 8-bit unsigned multiplicand 
; in location $21 by an 8-bit unsigned multiplier in location
; $20, and returns the 16-bit unsigned product in
; locations $22 (low byte) and $23 (high byte).

Mul8U:
    lda #00
    ldx #08
NextBit:
    lsr $20
    bcc Align
    clc 
    adc $21
Align:
    lsr a 
    ror $22
    dex
    bne NextBit
    sta $23
    rts 

