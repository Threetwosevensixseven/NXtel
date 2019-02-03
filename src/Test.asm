org $8000

ds Test4-(Test4/256*256), Test4-(Test4/256*256) ; Forward reference

ld hl, $1234                                    ; Immediate
ld hl, ($1234)                                  ; Indirect

ld hl,  (((35*3)+4)-7)-(17+(16*2))              ; Immediate
ld hl, ((((35*3)+4)-7)-(17+(16*2)))             ; Indirect

ld hl,  (((Test3*3)+Test2)-7)-(Test+(Test4*2))  ; Immediate, 3x forward reference
ld hl, ((((Test3*3)+Test2)-7)-(Test+(Test4*2))) ; Indirect, 3x forward reference

Test:
nop
Test2:
Test3 equ Test4                                 ; Forward reference
jr $

ds Test2-(Test2/256*256), Test2-(Test2/256*256) ; Backward reference
Test4:                                          ; Backward reference











