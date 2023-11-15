; This subroutine multiplies an 8-bit signed multiplicand in
; location $21 by an 8-bit signed multiplier in location $20.
; the 16-bit product is returned in locations $22 (low byte)
; and $23 (high byte). Location $24 is used to hold a multiplicand
; sign bit mask.

Mul8S:
    lda #$80
    bit $20
    bpl Mpos
    bit $21
    bpl Swap
; Both negative, negate both
Negate:
    asl 
    sta $24
    sbc $21
    sta $21
    lda #00
    sec
    sbc $20
    sta $20
    jmp GoMutiply

; Multiplier negative, Muliplicand positive - Swap
Swap:
    sta $24
    lda $21
    ldx $20
    stx $21
    sta $20
    jmp GoMultiply

; Multipler positive, check sign from Multiplicand
Mpos:
    bit $21
    bmi Mask1
    asl
Mask1:
    sta $24

GoMutiply:
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
    sta $23
    rts