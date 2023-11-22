; This routine converts a packed 8 digit BCD value in memory locations
; BINARY to BINARY+3 to a binary value with the dp value in location
; EXP and stores it in location BCD to BCD+3. It then packs the dp value
; in the MSBY high nibble location BCD+3.

BCN_BIN: 
    stz BINARY_3            ; reset MSBY
    jsr NXT_BCD             ; get next BCD 4 bit value 
    sta BINARY              ; store in LSBY
    ldx #$07
GET_NXT:
    jsr NXT_BCD             ; get next BCD value 
    jsr MPY10 
    dex
    bne GET_NXT
    asl EXP                 ; move dp nibble left
    asl EXP
    asl EXP
    asl EXP
    lda BINARY+3            ; get MSBY and filter it
    and #$0f 
    ora EXP
    sta BINARY+3
    rts
NXT_BCD:
    ldy #$04
    lda #$00
MV_BITS:
    asl BCD
    rol BCD+1 
    rol BCD+2
    rol BCD+3
    rol a
    dey
    bne MV_BITS
    rts 

; Conversion subroutine for BCD_BIN
MPY10:
    sta TEMP2               ; save digit just entered
    lda BINARY+3            ; save partial result on
    pha                     ; stack 
    lda BINARY+2
    pha 
    lda BINARY+1
    pha 
    lda BINARY
    pha
    asl BINARY              ; 
    rol BINARY+1
    rol BINARY+2
    rol BINARY+3
    asl BINARY
    rol BINARY+1
    rol BINARY+2
    rol BINARY+3
    pla 
    adc BINARY
    sta BINARY
    pla
    adc BINARY+1
    sta BINARY+1
    pla 
    adc BINARY+2
    sta BINARY+2
    pla
    adc BINARY+3
    sta BINARY+3
    asl BINARY
    rol BINARY+1
    rol BINARY+2
    rol BINARY+3 
    lda Temp2 
    adc BINARY
    sta BINARY
    lda #00
    adc BINARY+1
    sta BINARY+1
    lda #00
    adc BINARY+2
    sta BINARY+2
    lda #00
    adc BINARY+3
    sta BINARY+3 
    rts 