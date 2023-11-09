;===========================================
; Date range from 1900-03-01 to 2155-12-31
; Weekday = (day + offset[month] + year + year/4 + fudge) mod 7
;===========================================

;==============================================
; INPUT
; Y = year (0 = 1900, 1 = 1901, ..., 255=2155)
; X = month (1 = Jan, 2 = Fen, ..., 12 = Dec)
; A = day (1 -> 31)
;==============================================

;====================================================
; OUTPUT
; Weekday in A (0=Sunday, 1=Monday, ..., 6=Saturday)
;====================================================

Temp    equ     $6          ; temporary storage

Weekday:
    cpx #3                  ; year starts in March to bypass
    bcs March               ; leap year problem
    dey
March: 
    eor #$7F                ; Invert A so carry works right
    cpy #200                ; carry is one if 22nd century 
    adc Mtab-1,x            ; A is now day + month offset
    sta Temp 
    tya 
    jsr Mod7
    sbc Temp                
    sta Temp 
    tya                     
    lsr                     ; divide year by 4
    lsr 
    clc 
    adc Temp    
Mod7:
    adc #7
    bcc Mod7
    rts 
Mtab: 
    db 1,5,6,3,1,5,3,0,4,2,6,4

