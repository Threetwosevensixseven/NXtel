; utilities.asm

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



ReadMenuKeys            proc
                        xor a
                        ld (CurrentKey), a
                        ld c, low(K_54321)
Loop:                   add a, a
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
CheckForBreak:          ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoBreak
                        ld b, high zeuskeyaddr("[space]")
                        in a, (c)
                        and zeuskeymask("[space]")
                        jp nz, NoBreak
                        EnableKeyboardScan(false)
                        PlaySFX(SFX.Key_CS)
                        jp MainMenu
NoBreak:                xor a
SaveCurrentKey:         ld (CurrentKey), a
                        jp Loop
Match:
                        PlaySFX(SFX.Key_None)
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
CheckForBreak:          ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoBreak
                        ld b, high zeuskeyaddr("[space]")
                        in a, (c)
                        and zeuskeymask("[space]")
                        jp nz, NoBreak
                        EnableKeyboardScan(false)
                        PlaySFX(SFX.Key_CS)
                        jp MainMenu
NoBreak:                xor a
SaveCurrentKey:         ld (CurrentKey), a
                        jp Loop
Match:
                        PlaySFX(SFX.Key_None)
                        ld a, (CurrentKey)
                        inc a
                        ld d, a
                        ld a, (ItemCount)
                        inc a
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
                        ld de, ESPConnect.ConnString
                        ld bc, ConnectMenuServer.Size
                        nextreg $57, 3
                        ldir
                        pop hl
                        push hl
                        ld bc, ConnectMenuServer.Size
                        xor a
                        cpir
                        pop de
                        or a
                        sbc hl, de
                        inc hl
                        ld a, l
                        ld (ESPConnect.ConnStringLen), a
                        dec hl
                        dec hl
                        ld de, ESPConnect.ConnString
                        add hl, de
                        ld a, CR
                        ld (hl), a
                        inc hl
                        ld a, LF
                        ld (hl), a
                        MMU6(0, false)
                        call ESPConnect
pend



FlipULAScreen           proc
                        if ULAMonochrome
                          ld a, $10
                          or [WhichULAScreen]SMC
                          ld bc, $7FFD
ToggleSMC:                out (c), a
                        endif
                        ret
pend



MainMenu                proc
                        ld a, ItemCount
                        ld (ReadMenuKeys.ItemCount), a
                        ld hl, Addresses
                        ld (ReadMenuKeys.Addresses), hl
                        ld hl, MainMenu
                        ld (MenuNotImplemented.Return), hl
                        MMU6(31, false)
                        MMU7(30, false)
                        EnableTime(false, false)
                        jp MainMenu31
Return:                 call RenderBuffer
                        FlipScreen()
                        StatusIcon(Sprites32.Offline)
                        ei
                        call ClockTest
                        call WaitNoKey
                        jp ReadMenuKeys
Addresses:              dw MenuConnect                          ; 1: Connect
                        dw RunCarousel                          ; 2: Carousel Demo
                        dw MenuNetworkSettings                  ; 3: Network Settings
                        dw MenuNotImplemented                   ; 4: Help
                        dw MenuKeyDescriptions                  ; 5: Keys
                        dw MenuNotImplemented                   ; 6: About NXtel
ItemCount               equ ($-Addresses)/2
pend



ClockTest               proc
                        ret
                        MMU6(31, false)
                        MMU7(30, false)
                        ld hl, TextLen
                        ld (RenderBuffer.PrintLength), hl
                        ld hl, Layer2Addr(30, 0)
                        ld (ClearESPBuffer.Start), hl

                        xor a
                        ld (RenderBuffer.Toggle), a

                        if ULAMonochrome
                          ld a, $21                             ; ld hl, NNNN = $21
                          ld (RenderBuffer.ToggleCLS), a
                        endif

                        ld hl, Text
                        ld de, DisplayBufferAddr(2, 0)
                        ld (RenderBuffer.PrintStart), de
                        ld bc, TextLen
                        ldir
                        call RenderBuffer
                        ld hl, ClearESPBuffer.Origin
                        ld (ClearESPBuffer.Start), hl
                        ld hl, DisplayBuffer.Length
                        ld (RenderBuffer.PrintLength), hl
                        ld hl, DisplayBuffer
                        ld (RenderBuffer.PrintStart), hl

                        ld a, 5
                        ld (RenderBuffer.Toggle), a

                        if ULAMonochrome
                          ld a, $CD                             ; call NNNN = $CD
                          ld (RenderBuffer.ToggleCLS), a
                        endif

                        ei
                        ret
Text:                   db $C2, "12:34:56"
TextLen                 equ $-Text
pend



MenuNetworkSettings     proc
                        ld a, ItemCount
                        ld (ReadMenuKeys.ItemCount), a
                        ld hl, Addresses
                        ld (ReadMenuKeys.Addresses), hl
                        ld hl, MenuNetworkSettings
                        ld (MenuNotImplemented.Return), hl
                        MMU6(31, false)
                        MMU7(30, false)
                        jp MenuNetworkSettings31
Return:                 call RenderBuffer
                        FlipScreen()
                        ei
                        call WaitNoKey
                        jp ReadMenuKeys
Addresses:              dw MenuNotImplemented                   ; Key 1 - NXtelBaud
                        dw MenuNotImplemented                   ; Key 2 - Join Wifi Network
                        dw TestLatency                          ; Key 3 - Test Latency
ItemCount               equ ($-Addresses)/2
pend



TestLatency             proc
                        MMU6(31, false)
                        MMU7(30, false)
                        jp SetupTestLatency31
Return:                 call RenderBuffer
                        FlipScreen()
                        MMU6(31, false)
                        MMU7(30, true)
                        jp TestLatency31
pend



MenuKeyDescriptions     proc
                        ld a, ItemCount
                        ld (ReadMenuKeys.ItemCount), a
                        ld hl, Addresses
                        ld (ReadMenuKeys.Addresses), hl
                        ld hl, MenuKeyDescriptions
                        ld (MenuNotImplemented.Return), hl
                        MMU6(31, false)
                        MMU7(30, false)
                        jp MenuKeyDescriptions31
Return:                 call RenderBuffer
                        FlipScreen()
                        ei
                        call WaitNoKey
                        jp ReadMenuKeys
Addresses:
ItemCount               equ ($-Addresses)/2
pend



MenuConnect             proc
                        MMU6(31, false)
                        MMU7(30, false)
                        jp MenuConnect31
Return:                 call RenderBuffer
                        FlipScreen()
                        ei
                        call WaitNoKey
                        jp ReadMenuConnectKeys
None:
                        MMU6(0, false)
                        ld hl, MainMenu
                        ld (MenuNotImplemented.Return), hl
                        jp MenuNotImplemented
ItemCount:              db 0
pend



MenuNotImplemented      proc
                        Border(Red)
                        halt:halt:halt:halt:halt
                        Border(Teletext.Border)
                        jp [Return]MainMenu
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



Splash proc Table:

  ;    X            Colour  Index   Y
  db  26,    Teletext.Cyan  ;   0  94
  db  32,    Teletext.Cyan  ;   1  94
  db  38,    Teletext.Cyan  ;   2  94
  db  44,    Teletext.Cyan  ;   3  94
  db  50,    Teletext.Cyan  ;   4  94
  db  56,    Teletext.Cyan  ;   5  94
  db  62,    Teletext.Cyan  ;   6  94
  db  68,   Teletext.Green  ;   7  94
  db  74,   Teletext.Green  ;   8  94
  db  80,   Teletext.Green  ;   9  94
  db  86,   Teletext.Green  ;  10  94
  db  92,   Teletext.Green  ;  11  94
  db  98,   Teletext.Green  ;  12  94
  db 104,   Teletext.Green  ;  13  94
  db 110,  Teletext.Yellow  ;  14  94
  db 116,  Teletext.Yellow  ;  15  94
  db 122,  Teletext.Yellow  ;  16  94
  db 128,  Teletext.Yellow  ;  17  94
  db 134,  Teletext.Yellow  ;  18  94
  db 140, Teletext.Magenta  ;  19  94
  db 146, Teletext.Magenta  ;  20  94
  db 152, Teletext.Magenta  ;  21  94
  db 158, Teletext.Magenta  ;  22  94
  db 164, Teletext.Magenta  ;  23  94
  db 170, Teletext.Magenta  ;  24  94
  db 176, Teletext.Magenta  ;  25  94
  db 182,     Teletext.Red  ;  26  94
  db 188,     Teletext.Red  ;  27  94

  struct
    X           ds 1
    Colour      ds 1
  Size send

  Len           equ $-Table
  Count         equ Len/Size
  Y             equ 6
pend



Welcome                 proc
                        MMU6(31, false)
                        MMU7(30, false)
                        jp Welcome31
Return:                 call RenderBuffer
                        FlipScreen()
                        ei
                        ld a, -1
                        ld (Pause), a
                        ld (Record), a
Wait:
                        halt
                        ld a, [Pause]SMC
                        inc a
                        ld (Pause), a
                        and %11
                        jp nz, Wait
                        ld a, [Record]SMC
                        inc a
                        ld (Record), a
                        cp Splash.Count
                        ret z
                        MMU0(21, false)
                        ld a, (Record)
                        add a, a
                        ld hl, Splash.Table
                        add hl, a
                        ld e, (hl)                      ; e = X
                        inc hl
                        ld a, (hl)                      ; a = Colour
                        ld d, Splash.Y                  ; d = Y
                        ex de, hl
                        ld (hl), a
                        inc l
                        ld (hl), a
                        inc l
                        ld (hl), a
                        inc h
                        ld (hl), a
                        dec l
                        ld (hl), a
                        dec l
                        ld (hl), a
                        MMU0(255, true)
                        jp Wait
pend



PauseProc               proc
Wait:                   halt
                        ld hl, [Timer]SMC
                        dec hl
                        ld (Timer), hl
                        ld a, h
                        or l
                        jp nz, Wait
                        ret
pend



KB                      proc
  WritePointer:         dw 0
  ReadPointer:          dw 0
  CharsAvailable:       dw 0
pend



StatusIconProc          proc
                        NextRegRead($56)
                        ld (Restore), a
                        nextreg $56, 32
                        jp StatusIcon32
Return:                 nextreg $56, [Restore]SMC
                        ret
pend


SetupSprites            proc
                        nextreg $56, 32
                        jp SetupSprites32
Return:                 ret
pend



PlaySFXProc             proc                    ; e = SFXNumber
                        NextRegRead($57)
                        ld (Restore), a
                        nextreg $57, 33
                        ld a, e
                        call BeepFX.play
Return:                 nextreg $57, [Restore]SMC
                        ret
pend



SetupBrowserPalette     proc
                        MMU6(32, false)
                        jp SetupBrowserPalette6
                        ei
Return:                 ret
pend



SetupCopperFlash        proc
                        MMU6(32, false)
                        jp SetupCopperFlash32
Return:                 ret
pend

