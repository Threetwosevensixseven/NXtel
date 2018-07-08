; mmu-pages.asm

MMUTemp16 equ $

; PAGE 30 - BANK30.BIN - Layer 2 Teletext renderer
org $E000
dispto zeusmmu(30)
include "c30.asm"
P30Size = $-$E000
output_bin "..\banks\Bank30.bin", zeusmmu(30), P30Size
zeusprinthex "P30Size = ", P30Size

org MMUTemp16
disp 0

