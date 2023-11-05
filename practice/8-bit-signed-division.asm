; This subroutine divides an 8-bit signed dividend in location $21
; by an 8-bit signed divisor in location $20. The 8-bit quotient is
; returned in location $21, replacing the dividend, and the 8-bit
; remainder is returned in location $22. Location $23 is used to hold
; a divisor/dividend sign flag.

Div8S:
    ldy #$00
    bit $20
    bpl CheckDividend

    lda #00
    sec
    sbc $20
    sta $20
    ldy #$80
CheckDividend:
    bit $21
    bpl DoDivision
    
    lda #00
    sec
    sbc $21
    sta $21
    tya
    ora #$40
    tay

DoDivision:
    sty $23
    lda #00
    ldx #08
NextBit:
    asl $21
    rol a
    cmp $20
    bcc SkipSub
    sbc $20
    inc $21

SkipSub:
    dex
    bne NextBit
    sta $22
; Restore signs for remainder and quotient
    lda #$C0
    bit $23
    beq Done
    bvs NegR                        ; Sign of the remainder same as the sign of dividend
NegQ:
    lda #00
    sec
    sbc $21
    sta $21
    rts
NegR:
    lda #00
    sec
    sbc $22
    sta $22
    bit $23
    bmi NegQ
Done:
    rts