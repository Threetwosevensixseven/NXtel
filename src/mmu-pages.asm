; mmu-pages.asm

MMUTemp16 equ $

; PAGE 30 - BANK30.BIN - Layer 2 Teletext renderer
org $E000
dispto zeusmmu(30)
include "c30.asm"
P30Size = $-$E000
output_bin "..\banks\Bank30.bin", zeusmmu(30), P30Size
zeusprinthex "P30Size = ", P30Size

; PAGE 31 - BANK31.BIN - Config file and menus
org $C000
dispto zeusmmu(31)
include "c31.asm"
P31Size = $-$C000
output_bin "..\banks\Bank31.bin", zeusmmu(31), P31Size
zeusprinthex "P31Size = ", P31Size

; PAGE 32 - BANK32.BIN - Sprites
org $C000
dispto zeusmmu(32)
include "c32.asm"
P32Size = $-$C000
output_bin "..\banks\Bank32.bin", zeusmmu(32), P32Size
zeusprinthex "P32Size = ", P32Size

; PAGE 33 - BANK33.BIN - Pages C
org $C000
dispto zeusmmu(33)
Pages33 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh003.bin"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-91a.bin"
  align 1024
  P2: import_bin "..\pages\demo1\sh004.bin"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-7a.bin"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-7b.bin"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-7c.bin"
  align 1024
  P6: import_bin "..\pages\demo1\telstar-7d.bin"
  align 1024
  P7: import_bin "..\pages\demo1\jellica001.bin"
pend
P33Size = $-$C000
output_bin "..\banks\Bank33.bin", zeusmmu(33), P33Size
zeusprinthex "P33Size = ", P33Size

; PAGE 34 - BANK34.BIN - Pages D
org $C000
dispto zeusmmu(34)
Pages34 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-2001a.bin"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-2001b.bin"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-2001c.bin"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-2001d.bin"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-2001e.bin"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-2001f.bin"
  align 1024
  P6: import_bin "..\pages\demo1\telstar-2001g.bin"
  align 1024
  P7: import_bin "..\pages\demo1\telstar-2001h.bin"
pend
P34Size = $-$C000
output_bin "..\banks\Bank34.bin", zeusmmu(34), P34Size
zeusprinthex "P34Size = ", P34Size

; PAGE 35 - BANK35.BIN - Pages E
org $C000
dispto zeusmmu(35)
Pages35 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-2001i.bin"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-2001j.bin"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-2001k.bin"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-2001l.bin"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-2001m.bin"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-2001n.bin"
  align 1024
  P6: import_bin "..\pages\demo1\jellica002.bin"
  align 1024
  P7: import_bin "..\pages\demo1\sh005.bin"
pend
P35Size = $-$C000
output_bin "..\banks\Bank35.bin", zeusmmu(35), P35Size
zeusprinthex "P35Size = ", P35Size

; PAGE 36 - BANK36.BIN - Pages F
org $C000
dispto zeusmmu(36)
Pages36 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh006.bin"
  align 1024
  P1: import_bin "..\pages\demo1\sh016.bin"
  align 1024
  P2: import_bin "..\pages\demo1\sh008.bin"
  align 1024
  P3: import_bin "..\pages\demo1\sh009.bin"
  align 1024
  P4: import_bin "..\pages\demo1\sh010.bin"
  align 1024
  P5: import_bin "..\pages\demo1\sh011.bin"
  align 1024
  P6: import_bin "..\pages\demo1\sh014.bin"
  align 1024
  P7: import_bin "..\pages\demo1\sh013.bin"
pend
P36Size = $-$C000
output_bin "..\banks\Bank36.bin", zeusmmu(36), P36Size
zeusprinthex "P36Size = ", P36Size

; PAGE 37 - BANK37.BIN - Pages G
org $C000
dispto zeusmmu(37)
Pages37 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh017.bin"
  align 1024
  P1: import_bin "..\pages\demo1\sh018.bin"
  align 1024
  P2: import_bin "..\pages\demo1\sh019.bin"
  align 1024
  P3: import_bin "..\pages\demo1\aj001.bin"
  align 1024
  P4: import_bin "..\pages\demo1\jellica003.bin"
  align 1024
  P5: import_bin "..\pages\demo1\title.bin"
  align 1024
  P6: import_bin "..\pages\demo1\credits.bin"
  align 1024
  P7: import_bin "..\pages\demo1\blank.bin"
pend
P37Size = $-$C000
output_bin "..\banks\Bank37.bin", zeusmmu(37), P37Size
zeusprinthex "P37Size = ", P37Size

; PAGE 38 - BANK38.BIN - Pages H
org $C000
dispto zeusmmu(38)
Pages38 proc
  align 1024
  P0: import_bin "..\pages\welcome-website.bin"
  align 1024
  P1: import_bin "..\pages\double-height-copy-down.bin"
  align 1024
  P2: import_bin "..\pages\demo1\sh019.bin"
  align 1024
  P3: import_bin "..\pages\demo1\aj001.bin"
  align 1024
  P4: import_bin "..\pages\demo1\jellica003.bin"
  align 1024
  P5: import_bin "..\pages\demo1\title.bin"
  align 1024
  P6: import_bin "..\pages\demo1\credits.bin"
  align 1024
  P7: import_bin "..\pages\demo1\blank.bin"
pend
P38Size = $-$C000
output_bin "..\banks\Bank38.bin", zeusmmu(38), P38Size
zeusprinthex "P38Size = ", P38Size

; PAGE 39 - BANK39.BIN - Pages B
org $C000
dispto zeusmmu(39)
Pages39 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-0.bin"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-0a.bin"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-8a.bin"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-91b.bin"
  align 1024
  P4: import_bin "..\pages\demo1\sh001.bin"
  align 1024
  P5: import_bin "..\pages\demo1\bizzley.bin"
  align 1024
  P6: import_bin "..\pages\demo1\sh002.bin"
  align 1024
  P7: import_bin "..\pages\demo1\charts.bin"
pend
P39Size = $-$C000
output_bin "..\banks\Bank39.bin", zeusmmu(39), P39Size
zeusprinthex "P39Size = ", P39Size

org MMUTemp16
disp 0

