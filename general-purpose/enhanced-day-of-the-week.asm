; Calling Syntax 
; ldx #<date            ; Starting address of date data
; ldy #>date 
; jsr cdow                ; this subroutine
; sta dow                 ; day of week return in A
; X and Y are preserved.

; The information at Date must be in the following format:

; Offset        Data    
; -------------------------------------------------------------
; $00           Year MSB. For eg, year 2008 -> $07 
; $01           Year LSB. For eg, year 2008 -> $D8 (07D8 = 2008)
; $02           Month, ranging from $01 to $0C (12)
; $03           Date, ranging from $01 to $1F(31)
; -------------------------------------------------------------

; On return, A has the day ranging $01-$07, with $01 being Sunday.

; Declarations 
_origin_ = $02000               ; assembly address
zpptr    = $10                  ; working ZP pointer

dayswk = 7                    ; days in a week 
march    = $03                  ; March in binary 
s_bits   = 8                    ; number of bits in a byte
s_byte   = 1                    ; size of a byte or char 
s_date   = 4                    ; size of the input date
s_dword  = 4                    ; size of a double word 
s_word   = 2                    ; size of a word 
y2fac    = 4                    ; Y2 computation factor
y3fac    = 100                  ; Y3 computation factor 
y4fac    = 400                  ; Y4 computation factor 


;==========================================================
; Compute day of week

    org _origin_                ; set program counter 

cdow:
    stx zpptr                   ; save pointer to...
    sty zpptr+1                 ; date info
    ldy #s_date-1               ; bytes in date - 1 = 3

cdow01:
    lda (zpptr),y               ; copy user's date...
    sta userdate,y              ; into our storage
    dey 
    bpl cdow01 

    lda month
    ldx yearlo 
    ldy yearhi 
    pha                         ; save month
    cmp #march                  ; month March or later?
    bcs cdow03                  ; yes, no year adjustment.

    txa                         ; year LSB 
    sec 
    sbc #1                      ; move back a year 
    bcs cdow02          
    dey     
cdow02:     
    tax                         ; hold LSB

cdow03:
    stx y1                      ; save Y1
    sty y1+1    

; Compute Y1/4

    jsr stafaca                 ; store Y1 in accumulator #1
    ldx #<y2fac                 ; 4
    ldy #>y2fac         
    jsr stafacb 
    jsr dpdiv                   ; Y2 = Y1 / 4
    stx y2                      ; store 
    sty y2+1

; Compute Y1/100
    jsr stay1fac
    ldx #<y3fac                 
    ldy #>y3fac
    jsr stafacb                 ; store to accumulator #2 
    jsr dpdiv 
    stx y3 
    sty y3+1 

; Compute Y1/400
    jsr stay1fac 
    ldx #<y4fac
    ldy #>y4fac 
    jsr stafacb                 ; copy to accumulator #2
    jsr dpdiv 
    stx y4
    sty y4+1 

; Combine terms
    clc 
    lda y1 
    adc y2 
    sta acm1 
    lda y1+1 
    adc y2+1
    sta acm1+1 
    sec 
    lda acm1 
    sbc y3 
    sta acm1
    lda acm1+1
    sbc y3+1
    sta acm1+1 
    clc 
    lda acm1
    adc y4
    sta acm1 
    lda acm1+1
    adc y4+1 
    sta acm1+1 
    pla                         ; get month 
    tax 
    dex 
    clc 
    lda acm1 
    adc dowmctab,x 
    bcc codnw04

    inc acm1+1 
cdown04:
    sta acm1 
    clc 
    lda date 
    adc acm1 
    bcc cdown05

    inc acm1+1 

cdown05:
    sta acm1 
    ldx #<dayswk 
    ldy #>dayswk 
    jsr stafacb 
    jsr dpdiv 
    adc #1 
    
    ldx zpptr
    ldy zpptr+1
    rts 




;========================================================
; Double-Precision division 
; ------------------------------------------------------
; acm1 = 16 bit dividend
; acm2 = 16 bit divisor 
; ------------------------------------------------------
; acm1 = 16 bit quotient
; A = remainder 
; X = quotient LSB 
; Y = quotient MSB 
; Remainder is also available in acm1+2 
; No check is made for division by zero.
; ------------------------------------------------------
;========================================================
dpdiv:
    lda #0 
    sta acm1+s_word 
    sta acm1+s_word+s_byte 
    ldx #s_bits*s_word          ; 16 bits to process
    clc 

dpdiv01:
    rol acm1 
    rol acm1+s_byte 
    rol acm1+s_word 
    rol acm1+s_word+s_byte
    sec 

    lda acm1+s_word 
    sbc acm2 
    tay 
    lda acm1+s_word+s_byte 
    sbc acm2+s_byte 
    bcc dpdiv02
    sty acm1+s_word 
    sta acm1+s_word+s_byte 

dpdiv02:
    dex 
    bne dpdiv01

    rol acm1 
    rol acm1+s_byte 
    lda acm1+s_word 
    ldx acm1 
    ldy acm1+s_byte 
    rts 

;========================================================
; Store Y1 in accumulator #1
;========================================================
stay1fac:
    ldx y1 
    ldy y1+1 

;========================================================
; Store in accumulator #1
;========================================================
stafaca:
    stx acm1 
    sty acm1+1
    rts 

;========================================================
; Store in accumulator #1
;========================================================
stafacb:
    stx acm2 
    sty acm2+1
    rts 

;========================================================
; Compensation table
;========================================================
dowmctab: 
    .byte 0               ;January
    .byte 3               ;February
    .byte 2               ;March
    .byte 5               ;April
    .byte 0               ;May
    .byte 3               ;June
    .byte 5               ;July
    .byte 1               ;August
    .byte 4               ;September
    .byte 6               ;October
    .byte 2               ;November
    .byte 4               ;December

;========================================================
; Working storage
;========================================================

acm1 *=*+s_dword                ; accumulator #1 
acm2 *=*+s_dword                ; accumulator #2 
y1   *=*+s_word                 ; adjusted year (Y1)
y2   *=*+s_word                 ; Y1 / 4 
y3   *=*+s_word                 ; y / 100
y4   *=*+s_word                 ; y / 400



userdate *=*+s_date             ; input date storage...

yearhi = userdate 
yearlo = userdate+s_byte 
month = yearlo+s_byte 
date = month+s_byte 