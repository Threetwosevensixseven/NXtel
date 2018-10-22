; utilities.asm

LoadResources           proc

                        //xor a                           ; SNX extended snapshot leaves file handle 0 open
                        //ld (esxDOS.Handle), a

                        ld ix, FileName
                        call esxDOS.fOpen
                        jp c, esxDOS.Error

                        ld bc, $0002
                        ld de, $2000                    ; bcde = $22000 = 139264 = first bank
                        ld ixl, esxDOS.esx_seek_set
                        ld l, esxDOS.esx_seek_set
                        call esxDOS.fSeek
                        jp c, esxDOS.Error
                        xor a
                        push af
                        ld iy, Resources.Table
NextBank:
                        ld a, (ResourcesCount)
                        ld e, a
                        ld a, (iy+Resources.Bank)
                        nextreg $57, a
                        ld ix, $E000
                        ld bc, $2000
                        call esxDOS.fRead
                        jp c, esxDOS.Error
                        pop af
                        inc a
                        cp e
                        jp z, Finish
                        push af
                        inc iy
                        inc iy
                        jp NextBank
Finish:
                        call esxDOS.fClose
                        jp c, esxDOS.Error
                        ret
/*Error:
                        di
                        MMU5(8, false)
                        ld iy, FileName
                        Border(Blue)
                        jp esxDOSerror*/
pend



SetupDataFileSystem     proc
                        call esxDOS.GetSetDrive
                        jp c, esxDOS.Error
                        ld (esxDOS.DefaultDrive), a
                        ret
pend



esxDOSerror             proc
                        nextreg $02, 1
                        ei
                        halt
                        Border(Red)
                        Border(Yellow)
Freeze:                 jp Freeze
pend



ClsAttr                 proc
                        ClsAttrFull(DimBlackBlackP)
                        ret
pend



Cls                     proc
                        ld (EXIT+1), sp                 ; Save the stack
                        ld sp, ATTRS_8x8                ; Set stack to end of screen
                        ld de, $0000                    ; All pixels unset
                        ld b, e                         ; Loop 256 times: 12 words * 256 = 6144 bytes
                        noflow
CLS_LOOP:               defs 12, $D5                    ; 12 lots of push de
                        djnz CLS_LOOP
EXIT:                   ld sp, $0000                    ; Restore the stack
                        ret
pend



DoFlash                 proc
                        ld a, [Frame]SMC
                        inc a
                        and 31
                        ld (Frame), a
                        ret nz
                        nextreg $43, %0 001 000 0       ; Set Layer 2 primary palette, incrementing
                        nextreg $40, 64                 ; Start at index 64
                        ld a, [OnOff]SMC+1
                        xor 1
                        ld (OnOff), a
                        jp nz, On
Off:
                        ld e, 0                         ; Black
                        ld d, 9                         ; 8 sets of colour
OffOuter:               dec d
                        ld b, 8
                        ld a, e                         ; Colour index to set (0..7)
                        ld hl, PaletteL2Primary.Table
                        add hl, a
                        ld a, (hl)                      ; Colour to set (RGB8)
OffInner:               nextreg $41, a
                        djnz OffInner
                        inc e
                        ld b, d
                        djnz OffOuter
                        ret
On:
                        ld c, 8
NextSet:                ld b, 8
                        ld hl, PaletteL2Primary
Loop:                   ld a, (hl)
                        inc hl
                        nextreg $41, a
                        djnz Loop
                        dec c
                        ld a, c
                        jp nz, NextSet
                        //call GetTime
                        ret
pend



WaitNoKey               proc
                        xor a
                        in a, ($FE)
                        cpl
                        and 15
                        halt
                        jr nz, WaitNoKey
                        ret
pend



NextPaletteRGB8Proc     proc
                        ld bc, Sprite_Register_Port     ; Port to select ZX Next register
                        ld a, PaletteControlRegister    ; (R/W) Register $43 (67) => Palette Control
                        out (c), a
                        ld bc, Sprite_Value_Port        ; Port to access ZX Next register
Palette equ $+1:        ld a, %1 010 xxxx               ; 010 = Sprites first palette
                        out (c), a
                        ld bc, Sprite_Register_Port
                        ld a, PaletteIndexRegister      ; (R/W) Register $40 (64) => Palette Index
                        out (c), a
                        ld bc, Sprite_Value_Port
                        out (c), e
                        ld bc, Sprite_Register_Port
                        ld a, PaletteValueRegister      ; (R/W) Register $41 (65) => Palette Value (8 bit colour)
                        out (c), a
                        ld bc, Sprite_Value_Port
                        out (c), d
                        ret
pend



LoadSettings            proc
                        MMU6(31, false)
                        jp LoadSettings31
Return:                 MMU6(0, true)
                        ret
pend



Welcome                 proc
                        MMU6(31, false)
                        MMU7(30, false)
                        jp Welcome31
Return:                 MMU6(0, false)
                        call RenderBuffer
                        ei
                        ld a, -1
Wait:
                        halt
                        inc a
                        cp 1//50
                        jp c, Wait
                        ret
pend



ReadMenuKeys            proc
                        xor a
                        ld (CurrentKey), a
                        ld c, low(K_54321)
Loop:
                        add a, a
                        ld hl, MenuKey.Table
                        add hl, a
                        ld b, (hl)
                        inc hl
                        ld e, (hl)
                        in a, (c)
                        and e
                        jp z, Match
                        ld a, [ItemCount]SMC
                        ld d, a
                        ld a, [CurrentKey]SMC
                        inc a
                        cp d
                        jp c, SaveCurrentKey
                        xor a
SaveCurrentKey:         ld (CurrentKey), a
                        jp Loop
Match:
                        ld a, (CurrentKey)
                        add a, a
                        ld hl, [Addresses]SMC
                        add hl, a
                        ld e, (hl)
                        inc hl
                        ld d, (hl)
                        ex de, hl
                        jp (hl)
pend



MainMenu                proc
                        ld a, ItemCount
                        ld (ReadMenuKeys.ItemCount), a
                        ld hl, Addresses
                        ld (ReadMenuKeys.Addresses), hl
                        MMU6(31, false)
                        MMU7(30, false)
                        jp MainMenu31
Return:                 MMU6(0, false)
                        call RenderBuffer
                        ei
                        call WaitNoKey
                        jp ReadMenuKeys
Addresses:              dw MenuConnect                          ; Key 1
                        dw RunCarousel                             ; Key 2
                        dw MenuNotImplemented                   ; Key 3
                        dw MenuNotImplemented                   ; Key 4
ItemCount               equ ($-Addresses)/2
pend



MenuConnect             proc
                        MMU6(31, false)
                        MMU7(30, false)
                        jp ConnectMenu31
Return:                 MMU6(0, false)
                        call RenderBuffer
                        ei
                        call WaitNoKey
                        jp ReadMenuConnectKeys
Freeze:                 jp Freeze
                        //jp ESPSendTest
None:
                        MMU6(0, false)
                        jp MenuNotImplemented
pend



ReadMenuConnectKeys     proc
                        xor a
                        ld (CurrentKey), a
                        ld c, low(K_54321)
Loop:
                        add a, a
                        ld hl, MenuKey.Table
                        add hl, a
                        ld b, (hl)
                        inc hl
                        ld e, (hl)
                        in a, (c)
                        and e
                        jp z, Match
                        ld a, [ItemCount]SMC
                        ld d, a
                        ld a, [CurrentKey]SMC
                        inc a
                        cp d
                        jp c, SaveCurrentKey
                        xor a
SaveCurrentKey:         ld (CurrentKey), a
                        jp Loop
Match:
                        ld a, (CurrentKey)
                        inc a
                        ld d, a
                        ld a, (ItemCount)
                        cp d
                        jp z, MainMenu
                        di
                        MMU6(31, false)
                        ld a, (CurrentKey)
                        ld d, a
                        ld e, ConnectMenuServer.Size
                        mul
                        add de, ConnectMenuServer.Table
                        ex de, hl
                        push hl
                        ld de, ESPSendTest.Channel
                        ld bc, ConnectMenuServer.Size
                        ldir
                        pop hl
                        push hl
                        ld bc, ConnectMenuServer.Size
                        xor a
                        cpir
                        pop de
                        or a
                        sbc hl, de
                        dec hl
                        ld (ESPSendTest.ChannelLen), hl
                        MMU6(0, false)
                        jp ESPSendTest
pend



MenuNotImplemented      proc
                        Border(Red)
                        halt:halt:halt:halt:halt
                        Border(Black)
                        jp MainMenu
pend



MenuKey                 proc Table:

  ; Address    Mask  Index  Row
  db    $F7, %00001  ;   0  K_54321
  db    $F7, %00010  ;   1  K_54321
  db    $F7, %00100  ;   2  K_54321
  db    $F7, %01000  ;   3  K_54321
  db    $F7, %10000  ;   4  K_54321
  db    $EF, %10000  ;   5  K_67890
  db    $EF, %01000  ;   6  K_67890
  db    $EF, %00100  ;   7  K_67890
  db    $EF, %00010  ;   8  K_67890
  db    $FD, %00001  ;   9  K_GFDSA
  db    $7F, %10000  ;  10  K_BNMSsSp
  db    $FE, %01000  ;  11  K_VCXZCs
  db    $FD, %00100  ;  12  K_GFDSA
  db    $FB, %00100  ;  13  K_TREWQ
  db    $FD, %01000  ;  14  K_GFDSA
  db    $FD, %10000  ;  15  K_GFDSA
  db    $BF, %10000  ;  16  K_HJKLEn
  db    $DF, %00100  ;  17  K_YUIOP
  db    $BF, %01000  ;  18  K_HJKLEn
  db    $BF, %00100  ;  19  K_HJKLEn
  db    $BF, %00010  ;  20  K_HJKLEn
  db    $7F, %00100  ;  21  K_BNMSsSp
  db    $7F, %01000  ;  22  K_BNMSsSp
  db    $DF, %00010  ;  23  K_YUIOP
  db    $DF, %00001  ;  24  K_YUIOP
  db    $FB, %00001  ;  25  K_TREWQ
  db    $FB, %01000  ;  26  K_TREWQ
  db    $FD, %00010  ;  27  K_GFDSA
  db    $FB, %10000  ;  28  K_TREWQ
  db    $DF, %01000  ;  29  K_YUIOP
  db    $FE, %10000  ;  30  K_VCXZCs
  db    $FB, %00010  ;  31  K_TREWQ
  db    $FE, %00100  ;  32  K_VCXZCs
  db    $DF, %10000  ;  33  K_YUIOP
  db    $FE, %00010  ;  34  K_VCXZCs

pend



