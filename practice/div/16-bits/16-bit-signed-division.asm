; This routine divides a 16-bit signed dividend in locations
; $22 and $23 by a 16-bit divisor in locations $20 and 
; $21. The 16-bit quotient replaces the dividend. The 16-bit
; remainder is returned in locations $24 and $25. The low-order
; byte occupies the low address in all cases. The sign is
; stored in $26

Div16S:
    ldy #00
    bit $21
    bpl CheckDividend 
    tya 
    sbc $20
    sta $20
    lda #00
    sbc $21
    sta $21
    ldy #80

CheckDividend:
    bit $23
    bpl GoDivide
    lda #00
    sec
    sbc $22
    sta $22
    lda #00
    sbc $23
    sta $23
    tya
    ora #40
    tay

GoDivide:
    sty $26
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
    tay 
    lda $25
    sbc $21
    bcc Countdown       
    
    inc $22
    sty $24
    sta $25
Countdown:
    dex 
    bne NextBit

RtsSign:
    lda #$C0
    bit $26
    beq Done
    bvs NegR
NegQ:
    lda #00
    sec
    sbc $22
    sta $22
    lda #00
    sbc $23
    sta $23
    rts 

NegR:
    lda #00
    sec
    sbc $24
    sta $24
    lda #00
    sbc $25
    sta $25
    bit $26
    bpl NegQ

Done:
    rts 
