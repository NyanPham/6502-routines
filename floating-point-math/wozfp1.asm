;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   FLOATING POINT DESIGN PREFERENCES
;   Exponent      Two's Complement Mantissa
;   SEEEEEEE        SM.MMMMMM       MMMMMMMM      MMMMMMMM
;      n               n+1             n+2           n+3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org 3               ; set base page addresses
Sign .byte 
X2  .byte 
M2  .bss 3
X1  .byte 
M1  .bss 3
E   .bss 4
Z   .bss 4
T   .bss 4
Sexp .bss4 
Int .bss 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic floating point routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $1F00           ;start of basic floating point routines
Add:
    clc 
    ldx #02             ; index ofr 3-byte add 
Add1:
    lda M1,X 
    adc M2,X            ; add a byte of mant2 to mant1
    sta M1,X 
    dex 
    bpl Add1 
    rts 

MD1:    
    asl Sign            ; clear LSB of Sign
    jsr AbSwap          ; Abs the value of Mant1, then swap Mant2
AbSwap:
    bit M1              ; Mant1 neg?
    bpl AbSwap1         ; No, swap with mant2 and return
    jsr FCompl          ; Yes, complement it 
    inc Sign            ; increment sign, complementing LSB
AbSwap1:
    sec 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Swap exp/mant1 with exp/mant2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Swap:
    ldx #04             ; index for 4-byte swap.
Swap1:
    sty E-1,X 
    lda X1-1,X 
    ldy X2-1,X
    sty X1-1,X
    sta X2-1,X
    dex 
    bne Swap1
    rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert 16 bit integer in M1(high) and M1+1(low) to 
; result in Exp/mant1. Exp/mant2 uneffected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float:
    lda #$8E
    sta X1              ; set exponent to 14
    lda #0
    sta M1+2            ; clear low byte of Mant1 as we don't use it here
    beq Norm            ; Normalize result 
Norm1:
    dec X1              ; decrement Exp1 for the shift left of F.P
    asl M1+2            
    rol M1+1
    rol M1 
Norm:
    lda M1              ; high order mant1 byte
    asl a               ; left shift to align the second bit to first
    eor M1              ; xor the second bit with first bit of M1 
    bmi Rts1            ; if one, then they unequal, return.
    lda X1 
    bne Norm1           ; Exp1 zero? no then continue normalizing
Rts1:
    rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exp/mant2 - Exp/mant1 result in Exp/mant1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FSub:
    jsr FCompl
SwapAlign:
    jsr AlignSwap       ; right shift Mant1 or swap with Mant2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add Exp/mant1 and exp/mant2 result exp/mant1 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FAdd:
    lda X2 
    cmp X1              ; Compare Exp1 with Exp2 
    bne SwapAlign       ; if unequal, swap addends and align

    jsr Add             ; add aligned mantissas 
AddEnd:
    bvc Norm            ; no overflow, normalize results 
    bvs RtLog           ; OV: shift mant1 right. Note carry is correct sign
AlignSwap:
    bcc Swap            ; swap if carry clear, else shift right
RTAR:   
    lda M1              
    asl                 ; right arith shift
RTLog:
    inc X1              ; increment Exp1 to compenstate for RT Shift
    beq Overflow    
RTLog1:
    ldx #$FA            ; index for 6 byte right shift
Ror1:
    lda #$80
    bcs Ror2 
    asl 
Ror2:
    lsr E+3,X           ; simulate for E+3,X 
    ora E+3,X 
    sta E+3,X 
    inx                 ; next byte of shift
    bne Ror1            ; loop until done
    rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exp/mant1 * Exp/mant2 result in Exp/mant1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FMul:
    jsr MD1             ; abs value of Mant1, mant2 
    adc X1              ; add Exp1 to exp2 for product exponent 
    jsr MD2             ; check Product exp and prepare for mul
    clc 
Mul1:
    jsr RTlog1          ; mant1 and e right. (Product and MPlier)
    bcc Mul2            ; if carry clear, skip partial product
    jsr Add             ; add multiplicand to product 

Mul2:
    dey                 ; next mul iteration
    bpl Mul1            ; loop until done
MDEnd:
    lsr Sign            ; test sign (even/odd)
NormX:
    bcc Norm            ; if even, normalize product, else complement 
FCompl:
    sec                 ; set carry for subtract
    ldx #03             ; index for 3 byte subtraction 
Compl1:
    lda #00             ; clear A
    sbc X1,X
    sta X1,X 
    dex
    bne Compl1
    beq AddEnd    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exp/Mant2 / Exp/Mant1 result in Exp/mant1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDiv:
    jsr MD1             ; take abs value of mant1, mant2
    sbc X1              ; subtract Exp1 from Exp2 
    jsr MD2             ; save as quotient exp
Div1:
    sec     
    ldx #02             ; index for 3-byte instruction
Div2:
    lda M2,X 
    sbc E,X             ; subtract a byte of e from Mant2
    pha                 ; save on stack
    dex                 
    bpl Div2 
    ldx #$FD            ; index ofr 3-byte conditional move
Div3:
    pla                 ; pull a byte of difference off stack
    bcc Div4            ; if mant2 < E then don't restore mant2
    sta M2+3,X          
Div4:
    inx
    bne Div3
    rol M1+2
    rol M1+1
    rol M1
    asl M2+2
    rol M2+1
    rol M2
    bcs Overflow
    dey
    bne Div1 
    beq MDEnd
MD2:
    stx M1+2            ; X is 0 after FCompl
    stx M1+1            ; clear Mant1 (3 bytes) for mul/div
    stx M1
    bcs OverCheck       ; if exp calc set carry, check for Overflow
    bmi MD3             ; 
    pla
    pla 
    bcc NormX

MD3:
    eor #$80            ; complement sign bit of Exp 
    sta X1              ; store it 
    ldy #$17            ; count for 24 mul or 23 div iterations
    rts 
OverCheck:
    bpl MD3 
Overflow:
    brk 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert Exp/mant1 to integer in M1 (high) and M1+1(low)
; Exp/mant2 uneffected
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    jsr RTAR            ; shift mant1 rt and increment Exponent
Fix:
    lda X1              ; check exponent
    cmp #$8E            ; is exponent 14?
    bne Fix-3           ; no, shift
RTRN:
    rts                 ; return
    