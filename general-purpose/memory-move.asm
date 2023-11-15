; Move memory down
; 
; FROM = source start address
;   TO = destination start address
; SIZE = number of bytes to move

MoveDown:   
    ldy #00         ; address index
    ldx SizeH       ; loop counter number of bytes
    beq MD2 
MD1:                ; move hi
    lda (FROM),y    ; move a page at a time
    sta (TO),y 
    iny
    bne MD1
    inc FROM+1
    inc TO+1 
    dex 
    bne MD1 
MD2:
    ldx SizeL 
    beq MD4 
MD3:
    lda (FROM),y    ; move the remaining bytes
    sta (TO),y 
    iny
    dex
    bne MD3
MD4:
    rts 

MoveUp:
    ldx SizeH       ; the last byte must be moved first
    clc             ; start at the final pages of FROM and TO
    txa 
    adc FROM+1
    sta FROM+1 
    clc 
    txa 
    adc TO+1
    sta TO+1
    inx
    ldy SizeL 
    beq MU3
    dey
    beq MU2
MU1:
    lda (FROM),y
    sta (TO),y 
    dey
    bne MU1 
MU2:
    lda (FROM),y 
    sta (TO),y
MU3:
    dey
    dec FROM+1      
    dec TO+1
    dex 
    bne MU1
    rts 

