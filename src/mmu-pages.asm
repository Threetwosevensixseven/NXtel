; mmu-pages.asm

MMUTemp16 equ $

; PAGE 30 - BANK30.BIN - Layer 2 Teletext renderer
org $E000
dispto zeusmmu(30)
include "c30.asm"
P30Size = $-$E000
//output_bin "..\banks\Bank30.bin", zeusmmu(30), P30Size
zeusprinthex "P30Size = ", P30Size

; PAGE 31 - BANK31.BIN - Config file and menus
org $C000
dispto zeusmmu(31)
include "c31.asm"
P31Size = $-$C000
//output_bin "..\banks\Bank31.bin", zeusmmu(31), P31Size
zeusprinthex "P31Size = ", P31Size
//output_bin "..\banks\Page15.bin", zeusmmu(30), $4000

; PAGE 32 - BANK32.BIN - Sprites
org $C000
dispto zeusmmu(32)
include "c32.asm"
P32Size = $-$C000
//output_bin "..\banks\Bank32.bin", zeusmmu(32), P32Size
zeusprinthex "P32Size = ", P32Size

; PAGE 33 - BANK33.BIN - BeepFX
org $E000
dispto zeusmmu(33)
BeepFX proc
  include "..\sfx\BeepFX.asm"
  TempAddr equ $
  org sfxRoutineSample-2
  nop
  noflow
  org play+3
  nop
  noflow
  org TempAddr
pend
P33Size = $-$E000
//output_bin "..\banks\Bank33.bin", zeusmmu(33), P33Size
zeusprinthex "P33Size = ", P33Size
//output_bin "..\banks\Page16.bin", zeusmmu(32), $4000

; PAGE 34 - BANK33.BIN - Pages C
org $C000
dispto zeusmmu(34)
Pages34 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh003.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-91a.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\sh004.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-7a.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-7b.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-7c.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\telstar-7d.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\jellica001.tt8"
pend
P34Size = $-$C000
//output_bin "..\banks\Bank34.bin", zeusmmu(34), P34Size
zeusprinthex "P34Size = ", P34Size

; PAGE 35 - BANK35.BIN - Pages E
org $C000
dispto zeusmmu(35)
Pages35 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-2001i.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-2001j.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-2001k.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-2001l.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-2001m.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-2001n.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\jellica002.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\sh005.tt8"
pend
P35Size = $-$C000
//output_bin "..\banks\Bank35.bin", zeusmmu(35), P35Size
zeusprinthex "P35Size = ", P35Size
//output_bin "..\banks\Page17.bin", zeusmmu(34), $4000

; PAGE 36 - BANK36.BIN - Pages F
org $C000
dispto zeusmmu(36)
Pages36 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh006.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\sh016.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\sh008.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\sh009.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\sh010.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\sh011.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\sh014.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\sh013.tt8"
pend
P36Size = $-$C000
//output_bin "..\banks\Bank36.bin", zeusmmu(36), P36Size
zeusprinthex "P36Size = ", P36Size

; PAGE 37 - BANK37.BIN - Pages G
org $C000
dispto zeusmmu(37)
Pages37 proc
  align 1024
  P0: import_bin "..\pages\demo1\sh017.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\sh018.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\sh019.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\aj001.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\jellica003.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\title.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\credits.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\blank.tt8"
pend
P37Size = $-$C000
//output_bin "..\banks\Bank37.bin", zeusmmu(37), P37Size
zeusprinthex "P37Size = ", P37Size
//output_bin "..\banks\Page18.bin", zeusmmu(36), $4000

; PAGE 38 - BANK38.BIN - Pages H
org $C000
dispto zeusmmu(38)
Pages38 proc
  align 1024
  P0: import_bin "..\pages\welcome-website.tt8"
  align 1024
  P1: import_bin "..\pages\double-height-copy-down.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\sh019.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\aj001.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\jellica003.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\title.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\credits.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\blank.tt8"
pend
P38Size = $-$C000
//output_bin "..\banks\Bank38.bin", zeusmmu(38), P38Size
zeusprinthex "P38Size = ", P38Size

; PAGE 39 - BANK39.BIN - Pages B
org $C000
dispto zeusmmu(39)
Pages39 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-0.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-0a.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-8a.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-91b.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\sh001.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\bizzley.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\sh002.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\charts.tt8"
pend
P39Size = $-$C000
//output_bin "..\banks\Bank39.bin", zeusmmu(39), P39Size
zeusprinthex "P39Size = ", P39Size
//output_bin "..\banks\Page19.bin", zeusmmu(38), $4000

; PAGE 40 - BANK34.BIN - Pages D
org $C000
dispto zeusmmu(40)
Pages40 proc
  align 1024
  P0: import_bin "..\pages\demo1\telstar-2001a.tt8"
  align 1024
  P1: import_bin "..\pages\demo1\telstar-2001b.tt8"
  align 1024
  P2: import_bin "..\pages\demo1\telstar-2001c.tt8"
  align 1024
  P3: import_bin "..\pages\demo1\telstar-2001d.tt8"
  align 1024
  P4: import_bin "..\pages\demo1\telstar-2001e.tt8"
  align 1024
  P5: import_bin "..\pages\demo1\telstar-2001f.tt8"
  align 1024
  P6: import_bin "..\pages\demo1\telstar-2001g.tt8"
  align 1024
  P7: import_bin "..\pages\demo1\telstar-2001h.tt8"
pend
P40Size = $-$C000
//output_bin "..\banks\Bank40.bin", zeusmmu(40), P40Size
zeusprinthex "P40Size = ", P40Size
//output_bin "..\banks\Page20.bin", zeusmmu(40), $4000

org MMUTemp16
disp 0

