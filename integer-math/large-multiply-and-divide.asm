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
    sta PRO+7
    sta PRO+6
    sta PRO+5
    sta PRO+4
    ldx #32 

NextBit:
    lsr MULR+3
    ror MULR+2
    ror MULR+1
    ror MULR
    bcc Align
    clc
    lda PRO+4 
    adc MULND
    sta PRO+4 
    lda PRO+5
    adc MULND+1
    sta PRO+5
    lda PRO+6 
    adc MULND+2
    sta PRO+6 
    lda PRO+7 
    adc MULND+3 
    sta PRO+7

Align:
    lsr PRO+7
    ror PRO+6
    ror PRO+5
    ror PRO+4
    ror PRO+3
    ror PRO+2
    ror PRO+1
    ror PRO
    dex
    bne NextBit 
    rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 64 bit divide routine with 32 bit quotient
; DVDQUO 8 bytes
; DVDR 16 bytes:
;       - high 8 bytes for remainder
;       - low 8 bytes stores the dividend
; Subtract SubTemp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Divide:
    lda #00
    ldx #64

NextBit:
    asl DVDQUO
    rol DVDQUO+1
    rol DVDQUO+2
    rol DVDQUO+3
    rol DVDQUO+4
    rol DVDQUO+5
    rol DVDQUO+6
    rol DVDQUO+7
    // Shift carry to the hight 8 bytes of DVDR to check 
    rol DVDR+$8
    rol DVDR+$9
    rol DVDR+$A
    rol DVDR+$B
    rol DVDR+$C
    rol DVDR+$D
    rol DVDR+$E
    rol DVDR+$F

    ldx #$00
    lda #08
    sta ADDDP
    sec 
SUBT:
    lda DVDR+8,x
    sbc DVDR,x 
    sta SubTemp,x
    inx 
    dec ADDP 
    bne SUBT
    bcc Next                ; after subtracting 8 bytes, result > 0
    inc DVDQUO              ; Yes, sta subtraction to back to DVDR 8 high bytes
    
    ldx #08
Result:
    lda SubTemp-1,x 
    sta DVDR+7,x 
    dex 
    bne Result

Next:
    dey 
    bne NexBit
    rts 
