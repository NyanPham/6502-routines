;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input is in register A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Temp .byte 
    
Mult10:
    asl             ; a = num * 2
    sta Temp        ; temp = num * 2
    asl             ; a = num * 4
    asl             ; a = num * 8
    clc 
    adc Temp        ; a = num * 8 + (num * 2) = num * 10
    rts 