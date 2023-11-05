; 32 bit multiply with 64 bit product
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRODUCT 8 bytes
; MULTIPLIER 4 bytes
; MULTIPLICAND 4 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $0003
MULND .bss 4
MULR .bss 4
PROD .bss 8

Multiply:
    lda #00
    ldx #4
Clr:
    sta PROD+3,X
    dex 
    bne Clr

    ldx #$20            ; set binary to 32
Shift_R:
    lsr MULR+3
    ror MULR+2
    ror MULR+1
    ror MULR
    bcc PREP_ROTATE_R

    clc
    txa
    pha 
    ldx #0
MulAdd:
    lda PROD+4,X
    adc MULND,X
    sta PROD+4,X
    inx 
    cpx #4
    bne MulAdd 

    pla 
    tax
PREP_ROTATE_R: 
    txa
    pha
    ldx #0
ROTATE_R:
    ror PROD,X
    inx
    cpx #8
    bne ROTATE_R

    pla 
    tax 
    dex 
    bne Shift_R
    clc
    lda MULXP1
    adc MULXP2
    sta MULXP2
    rts 
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 64 bit divide routine with 32 bit quotient
; DVDQUO 8 bytes
; DVDR 16 bytes:
;       - high 8 bytes for remainder
;       - low 8 bytes stores the dividend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Divide:
    ldy #$40                ; set bit length = 64
NextBit:                    
    asl DVDQUO              ; shift left the dividend
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
    ldx #0
    lda #$08
    sta ADDDP
    sec 
DivSubt:
    lda DVDR+8,X
    sbc DVDR,X 
    sta MULR,X
    inx
    dec ADDDP
    bne DivSubt 
    bcc Next
    inc DVDQUO
    ldx #$08    
RSULT:
    lda MULR-1,X
    sta DVDR+7,X
    dex 
    bne RSULT
Next:
    dey
    bne NextBit
    sec 
    lda DivXP1
    sbc DivXP2
    sta DivXP2
    rts 
    
    