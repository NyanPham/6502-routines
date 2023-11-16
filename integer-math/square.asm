; Calculates the 16 bit unsigned integer square of the
; signed 16 bit integer in Numberl/Numberh. The result
; is always in the range 0 to 65025 and is held in 
; Squarel/Squareh

; The max input range is +/- 255 and no checking is
; done to ensure that this is so.

; This routine is useful if you are trying to draw circles

; x^2 + y^2 = r^2 where x and y are the coodirnates of
; any point on the circle and r is the circle radius.

;===================================================
; What the code does:
; Check the input number is negative or not, if 
; neg, negate it. 
; take the result and multiply itself.
; Tempsq is the multiplicand, and a is multiplier
; to be shifted and checked for 1.
;===================================================

    *=  8000                ; these must be in RAM
Numberl                     ; number to square low byte
Numberh = Numberl+1         ; number to square high byte 
    .word $FFFF 

Squarel                     ; square low byte 
Squareh                     ; square high byte 
    .word $FFFF

Tempsq:                     ; temp byte for intermediate result 
    .byte $00

    *= 8192                 ; any address will do
Square:
    lda #$00                ; clear A 
    sta Squarel             ; clear square low byte
                            ; no need to clear the high byte
                            ; it's shifted out 

    lda Numberl             ; get number low byte 
    ldx Numberh             ; get number high byte
    bpl NoNneg              ; if negative, negate it

    eor #$FF                ; invert 
    sec                     ; +1
    adc #$00                ; and add it 
NoNneg:
    sta Tempsq              ; save ABS(number)
    ldx #$08                ; 8 bit count
Nextr2bit:
    asl Squarel
    rol Squareh
    asl a 
    bcc NoSqAdd             
    tay 
    clc
    lda Tempsq 
    adc Squarel 
    sta Squarel 
    lda #$00 
    adc Squareh
    sta Squareh
    tya 
    
NoSqAdd:
    dex 
    bne Nextr2bit 
    rts 