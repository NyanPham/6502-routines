;========================================================
; FP REPRESENTATION DESIGN
; Exponent      Two's Complement Mantissa
; SEEEEEEE       SM.MMMMMM      MMMMMMMM    MMMMMMMM
;    n              n + 1          n + 2       n + 3
;========================================================

;========================================================
; Apple-II Floating point routines
;========================================================

Sign    .byte
X2      .byte
M2      .bss 3
X1      .byte 
M1      .bss 3
E       .bss 3
Ovloc = $3F5

    org $F425

Add:
    clc                 ; clear carry
    ldx #02             ; index for 3-byte add.
Add1:
    lda M1,x
    adc M2,x
    sta M1,x 
    dex
    bpl Add1
    rts 

MD1:
    asl Sign            ; clear LSB of sign
    jsr Abswap          ; 
Abswap:
    bit M1              ; mant1 negative?
    bpl Abswap1         ; NO, swap with mant2 and return
    jsr FCompl          ; complement it
    inc Sign            ; increment sign complementing LSB
Abswap1:
    sec
Swap:
    ldx #04
Swap1:
    sty E-1,x
    lda X1-1,x 
    ldy X2-1,x
    sty X1-1,x
    sty X2-1,x
    dex
    bne Swap1 
    rts 
Float:
    lda #$8E            ; exponent init to 14 
    sta X1              ;   (14 bits in Mantissa)
Norm1:
    lda M1
    cmp #$C0            ; %11000000
    bmi Rts1    
    dec X1              ; decrement Exponent 1
    asl M1+2            ; shift the 3 bytes of Mant1 left
    rol M1+1
    rol M1 
Norm:
    lda X1
    bne Norm1
Rts1:
    rts 

FSub:
    jsr FCompl
SwpAlgn:
    jsr AlgnSwp 
FAdd:
    lda X2
    cmp X1
    bne SwpAlgn
    jsr Add

AddEnd:
    bvc Norm            ; no overflow, normalize result
    bvs RtLog           ; OV: shift M1 right, carry into Sign
AlgnSwp:
    bcc Swap            ; swap if carry clear
; * else shift right arith.
RtAr:  
    lda M1
    asl 
RtLog:
    inc X1 
    beq Ovfl
RtLog1:
    ldx #$FA            ; %11111010 , #-6
Ror1:
    ror E+3,x 
    inx 
    bne Ror1
    rts 

FMul:
    jsr MD1             ; abs val of Mant1 and Mant2
    adc X1              ; add Exp1 to Exp2 for product exp
    jsr MD2             ; check Prod. Exp and Prep. For Mul
    clc 
Mul1:
    jsr RtLog1
    bcc Mul2 
    jsr Add
Mul2:
    dey
    bpl Mul1 
MDEnd:
    lsr Sign            ; test sign LSB
NormX:
    bcc Norm            ; if even, normalize Prod, else Comp

FCompl:
    sec 
    ldx #03
Compl1:
    lda #00
    sbc X1,x 
    sta X1,x
    dex
    bne Compl1
    beq AddEnd

FDiv:
    jsr MD1
    sbc X1 
    jsr MD2 
Div1:
    sec
    ldx #02
Div2:
    lda M2,x 
    sbc E,x 
    pha
    dex 
    bpl Div2 
    
    // TODO, working on Div

MD2:
    stx M1+2
    stx M1+1                ; x now is 0 after MD1 from FMul and FDiv
    stx M1 
    bcs OvChk
    bmi MD3
    pla 
    pla 
    bcc NormX
MD3:    
    eor #$80 
    sta X1 
    ldy #$17
    rts 
OvChk:
    bpl MD3
Ovfl:
    jmp Ovloc