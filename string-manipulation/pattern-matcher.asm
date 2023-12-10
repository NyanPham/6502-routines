; Input:    A NUL-terminated, < 255-length pattern at address Pattern.
;           A NUL-terminated, < 255-length string pointed to by Str.
; 
; Output:   Carry bit = 1 if the string matches the pattern, = 0 if not.
; 
; Notes:    Clobbers A, X, Y. Each * in the pattern uses 4 bytes of stack.
;

Match1  equ "?"         ; matches exactly 1 character
MatchN  equ "*"         ; matches any string (including "")
Pattern equ $2000       ; address of pattern
Str     equ $6          ; pointer to string to match

PatternMatch:
    ldx #$00            ; x is an index in the pattern
    ldy #$ff            ; y is an index in the string

Next:
    lda Pattern,X       ; look at the next pattern character 
    cmp #MatchN         ; is it a star?
    beq Star            ; yes, do complicated stuff
    iny                 ; No, let's look at the string
    cmp #Match1         ; Is the pattern character a ques?
    bne Reg             ; No, it's a regular character
    lda (Str),Y 
    beq Fail 

Reg:    
    cmp (Str),y         ; Are both characters the same? 
    bne Fail            ; No, so no match 
    inx                 ; yes, keep checking
    cmp #0              ; Are we at the end of string?
    bne Next            ; not yet, loop
Found: 
    rts                 ; Success, return with C = 1
Star:
    inx                 ; skip star in pattern
    cmp Pattern,Y       ; string of stars equals cone star 
    beq Star            ; skip all them
StLoop: 
    txa                 ; we first try to match with * = ""
    pha                 ;   and grow it by 1 character every
    tya                 ;   time we loop 
    pha                 ; Save and Y on stack
    jsr Next            ; Recursive call  
    pla                 ; restore 
    tay
    pla 
    tax     
    bcs Found           ; We found a match, return with C = 1
    iny                 ; No match yet, try to grow * string
    lda (Str),Y         ; Are we at the end of string?
    bne StLoop          ; Not yet, add a character 
Fail:
    clc                 ; No match found, return with C = 0
    rts 