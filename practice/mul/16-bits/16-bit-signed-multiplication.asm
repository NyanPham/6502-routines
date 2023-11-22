; This subroutine mutliplies the signed contents of locations
; $22 (low) and $23 (high) by the signed contents of locations
; $20 (low) and $21 (high), producing a 32-bit signed product
; in locations $24 (low) through $27 (high).

Mul16S:
    lda #80 
    bit $21
    bpl MPos
    bit $23
    bpl Swap
NegBoth:
    asl a
    sbc $20
    sta $20
    lda #00
    sbc $21
    sta $21

    lda #00
    clc
    sbc $22
    sta $22
    lda #00
    sbc $23
    sta $23 

    jmp GoMultiply
Swap:
    sta $24
    
    lda $22
    ldx $20
    stx $22
    sta $20

    lda $23
    ldx $21
    stx $23
    sta $21

    jmp GoMultiply

MPos:
    bit $23
    bmi MaskNeg
    asl a
MaskNeg:
    sta $24


GoMultiply:
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
    lda $27
    ora $24
    sta $27
    
    lsr $27
    ror $26
    ror $25
    ror $24

    dex
    bne NextBit
    rts 
    




