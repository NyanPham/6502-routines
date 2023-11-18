; 32 bit multiply with 64 bit product
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRODUCT 8 bytes
; MULTIPLIER 4 bytes
; MULTIPLICAND 4 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MULND .bss 4
MULR .bss 4
PRODUCT .bss 8
SIGN .byte 


MultiplyS:
    lda #$80
    bit MULD+7
    bpl MPos
    bit MULND+7
    bpl Swap

; Both are neg, negate them all
Negate:
    asl a 
    sta SIGN
    ldx #04                 ; 4 bytes to negate
    ldy #00 
    sec 
NegateMulnd:
    lda #00
    sbc MULND-1,y
    sta MULND-1,y 
    iny
    dex
    bne NegateMulnd 

    ldx #04                 ; 4 bytes to negate
    ldy #00
    sec 
NegateMulr:
    lda #00
    sbc MULR-1,y
    sta MULR-1,y 
    iny
    dex
    bne NegateMulnd

    jmp GoMultiply
; MULD is neg, but the MULND is pos, swap them 
Swap:
    sta SIGN
    ldx #04                 ; 4 bytes to swap
Swap01: 
    lda MULND-1,x 
    ldy MULR-1,x
    sta MULR-1,x
    sty MULND-1,x 
    dex
    bne Swap01 

    jmp GoMultiply

; MULR is pos, check the MULND is neg or not for product sign
MPos:
    bit MULND+7
    bmi Mask1 
    asl a 
Mask1:
    sta SIGN

GoMultiply:
    lda #00
    ldx #04
ClearProd:
    sta PROD+3,x
    dex 
    bne ClearProd

    lda #32
    sta BitCounter
NextBit:
    lsr MULR+3
    ror MULR+2
    ror MULR+1
    ror MULR 
    bcc Align

    ldy #00
    ldx #04
    clc 
MulAdd:
    lda PROD+4,y
    adc MULND,y
    sta PROD+4,y 
    iny
    dex
    bne MulAdd

Align:
    lsr PROD+7
    lda PROD+7
    ora SIGN
    sta PROD+7

    ldx #07
ProdRight:
    ror PROD-1,x
    dex
    bne ProdRight

    dec BitCounter
    bne NextBit
    rts 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 64 bit divide routine with 32 bit quotient
; DVDQUO 8 bytes
; DVDR 16 bytes:
;       - high 8 bytes for remainder
;       - low 8 bytes stores the dividend
; Subtract SubTemp 8 bytes =
; DVDQUO / low 8 bytes of DVDR = DVDQUO
; DVDQUO % low 8 bytes of DVDR = high 8 bytes of DVDR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DivideS:
    ldy #00
    sty SIGN                    ; track the negative of dividend and divisor
    bit DVDR+7
    bpl CheckDividend
NegateDivisor:
    ldx #08                     ; 8 bytes to negate
    ldy #00
    sec
NegateDivisor01:
    lda #00
    sbc DVDR,y
    iny
    dex
    bne NegateDivisor01    
    lda #$80
    sta SIGN

CheckDividend:
    bit DVDQUO+7 
    bpl GoDivide
NegateDividend:
    ldx #08
    ldy #00
    sec
NegateDividend01:
    lda #00
    sbc DVDQUO,y
    iny
    dex 
    bne NegateDididend01
    lda SIGN
    ora #$40
    sta SIGN 

GoDivide:
    lda #00
    ldx #64             ; 64 bits to process
    stx BitCounter
NextBit:
    asl DVDQUO
    rol DVDQUO+1
    rol DVDQUO+2
    rol DVDQUO+3
    rol DVDQUO+4
    rol DVDQUO+5
    rol DVDQUO+6
    rol DVDQUO+7
    rol DVDR+8
    rol DVDR+9
    rol DVDR+$a
    rol DVDR+$b
    rol DVDR+$c
    rol DVDR+$d
    rol DVDR+$e
    rol DVDR+$f 

    ldx #08                 ; 8 bytes to subtract 
    ldy #00
    sec
Subt:
    lda DVDR+8,y
    sbc DVDR,y
    sta Temp,y 
    iny
    dex
    bne Subt 
    bcc CountDown           ; Carry = 1?

    ldx #08                 ; yes, store the subtraction to the remainder
    ldy #00
Rsult:                      
    lda Temp,y
    sta DVDR+8,y
    iny
    dex 
    bne Rsult           
    inc DVDQUO
Countdown:
    dec BitCounter
    bne NextBit

    lda #$C0
    bit SIGN
    beq Done
    bvs NegateRemainder

NegateQuotient:
    ldx #08
    ldy #00
    sec 
NegateQuotient01:
    lda #00
    sbc DVDQUO,y
    sta DVDQUO,y
    iny
    dex
    bne NegateQuotient01
    rts     
    
NegateRemainder:
    ldx #08
    ldy #00
    sec
NegateRemainder01:
    lda #00
    sbc DVDR+8,y
    sta DVDR+8,y
    iny
    dex
    bne NegateRemainder01
    bit DVDQUO+7
    bpl NegateQuotient

Done:
    rts 