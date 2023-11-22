; This subroutine multiplies an 8-bit signed multiplicand in
; location $21 by an 8-bit signed multiplier in location $20.
; the 16-bit product is returned in locations $22 (low byte)
; and $23 (high byte). Location $24 is used to hold a multiplicand
; sign bit mask.

Mul8S:
    lda #80         
    bit $21
    bpl MPos
    bit $20
    bpl Swap 
NegBoth:
    asl a 
    sta $24
    sbc $20
    sta $20
    lda #00
    clc
    sbc $21
    sta $21
    jmp GoMultiply

Swap:
    sta $24
    lda $20
    ldx $21
    stx $20
    sta $21
    jmp GoMultiply
MPos:
    bit $21
    bmi MaskNeg
    asl a
MaskNeg:
    sta $24

GoMultiply:
    lda #00
    ldx #08
NextBit:
    lsr $20
    bcc Align 
    clc 
    adc $21

Align:
    lsr a
    ora $24
    ror $22
    dex
    bne NextBit
    
    rts