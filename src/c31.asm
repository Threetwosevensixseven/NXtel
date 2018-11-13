; c31.asm - Old Cfg Reading code (deprecated)

// This gets mapped in at $C000-$DFFF

include "dzx7_mega.asm"

Welcome31               proc
                        ld hl, Menus.Welcome            ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        ld hl, Version
                        ld de, DisplayBuffer+667
                        ld bc, 12
                        ldir
                        jp Welcome.Return
Version:                PadStringLeftSpaces(VersionOnlyValue, 12)
pend



MainMenu31              proc
                        Border(Black)
                        ld hl, Menus.Main               ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        jp MainMenu.Return
pend



MenuConnect31           proc
                        Border(Black)
                        ld a, (MenuConnect.ItemCount)
                        ld (ItemCount), a
                        or a
                        jp z, MenuConnect.None
                        xor a
                        ld (CurrentItem), a
                        ld a, "1"
                        ld (CurrentDigit), a
                        ld hl, Menus.Connect            ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
FillItemsLoop:          ld hl, DisplayBuffer+282
                        ld a, [CurrentItem]SMC
                        ld e, a
                        ld d, 80                        ; Two teletext display lines
                        mul
                        add hl, de
                        ld a, [CurrentDigit]SMC
                        ld (hl), a
                        add hl, 3
                        push hl                         ; Position in display buffer
                        nextreg $57, 3
                        ld hl, ConnectMenuDisplay.Table
                        ld a, (CurrentItem)
                        ld e, a
                        ld d, ConnectMenuDisplay.Size
                        mul
                        add hl, de                      ; hl = Source position
                        ld de, TempBuffer
                        ld bc, ConnectMenuDisplay.Size
                        ldir
                        nextreg $57, 30
                        ld hl, TempBuffer
                        pop de                          ; de = Destination position
                        ld bc, ConnectMenuDisplay.Size
                        ldir
                        ld a, (hl)
                        or a
                        jp z, NextLine
                        ldir
                        ld a, b
                        or c
                        jp z, NextLine
NextLine:               ld a, [ItemCount]SMC
                        ld d, a
                        ld a, (CurrentItem)
                        inc a
                        cp d
                        jp z, LastKey
                        ld (CurrentItem), a
                        ld a, (CurrentDigit)
                        inc a
                        ld (CurrentDigit), a
                        jp FillItemsLoop
LastKey:                ld hl, DisplayBuffer+282
                        ld a, (CurrentItem)
                        inc a
                        ld e, a
                        ld d, 80                        ; Two teletext display lines
                        mul
                        add hl, de
                        ld a, (CurrentDigit)
                        inc a
                        ld (hl), a
                        add hl, 3
                        ex de, hl                       ; de = Position in display buffer
                        ld hl, BackText                 ; hl = Source Back to Main Menu text
                        ld bc, BackTextLen
                        ldir
                        ld (DisplayBuffer+932), a
                        ld a, (CurrentItem)
                        add a, 2
                        ld (ReadMenuConnectKeys.ItemCount), a
                        jp MenuConnect.Return
BackText:               db "Back to Main Menu"
BackTextLen             equ $-BackText
TempBuffer:             ds 40
pend



Menus                   proc
  Welcome:              import_bin "..\pages\zx7\ClientWelcome.bin.zx7"
  Main:                 import_bin "..\pages\zx7\MainMenu.bin.zx7"
  Connect:              import_bin "..\pages\zx7\ConnectMenu.bin.zx7"
  Size                  equ 1000
pend

