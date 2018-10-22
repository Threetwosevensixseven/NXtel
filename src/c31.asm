; c31.asm

GetEnv:
   ; Search for "name = value" pair in file and return value in val if found.
   ; Must hold exclusive access to environment file while searching it.
   ;
   ; enter : hl = char *name
   ;         de = char *val
   ;         bc = valsz not including space for terminating 0 > 0
   ;
   ;          e'= file handle
   ;         hl'= char *buf
   ;         bc'= bufsz > 0
   ;
   ; exit  : success if valsz == 0
   ;
   ;            hl = length of value string (val not written)
   ;            carry reset
   ;
   ;         success if valsz != 0
   ;
   ;            hl = char *val, zero terminated value written into buffer
   ;            carry reset
   ;
   ;         fail
   ;
   ;            hl = 0
   ;            carry set
   ;
   ; uses  : af, bc, de, hl, bc', de', hl', ix
import_bin "..\getenv\bin\makebin.bin"



LoadSettings31                  proc
                                //call esxDOS.fClose
                                //jp c, Error

                                FillLDIR(ConnectMenuDisplay, ConnectMenuDisplay.Length, 0)
                                ld a, "1"
                                ld (URLNumber), a
                                xor a
                                ld (CurrentRow), a
ReadURLLoop:

                                ld ix, ConfigFileName
                                ld hl, ConfigFileName
                                call esxDOS.fOpen
                                jp c, Error

                                /*ld bc, 0
                                ld de, bc
                                ld l, c
                                call esxDOS.fSeek
                                jp c, Error
                                ld bc, 1
                                ld hl, LoadSettings31.ValueBuffer
                                call esxDOS.fRead
                                jp c, Error */

                                FillLDIR(LoadSettings31.ValueBuffer, LoadSettings31.ValueBufferLen, 0)

                                ld a, (esxDOS.Handle)
                                ld e, a                         ; e'= file handle
                                ld hl, FileBuffer               ; hl'= char *buf
                                ld bc, FileBufferLen            ; bc'= bufsz > 0
                                exx
                                ld hl, KeyBuffer                ; hl = char *name
                                ld de, ValueBuffer              ; de = char *val
                                ld bc, ValueBufferLen           ; bc = valsz not including space for terminating 0 > 0
                                call GetEnv
                                jp c, NoMoreLines               ; If key isn't present then return

                                inc hl
                                push hl
                                ld a, [CurrentRow]SMC
                                ld d, a
                                ld e, ConnectMenuDisplay.Size
                                mul
                                ld hl, ConnectMenuDisplay.Table
                                add hl, de
                                ex de, hl
                                pop hl
                                ld bc, ConnectMenuDisplay.Size-1
CopyDisplayLoop:
                                ld a, (hl)
                                or a
                                jp z, EndServerLine
                                cp ","
                                jp z, EndDisplayLine
                                ldi
                                ld a, b
                                or c
                                jp nz, CopyDisplayLoop
EndDisplayLine:
                                inc hl                          ; Skip comma after display text
                                push hl
                                ld a, (CurrentRow)
                                ld d, a
                                ld e, ConnectMenuServer.Size
                                mul
                                ld hl, ConnectMenuServer.Table
                                add hl, de
                                ex de, hl
                                pop hl
                                ld bc, ConnectMenuServer.Size-1
CopyServerLoop:
                                ld a, (hl)
                                or a
                                jp z, EndServerLine
                                ldi
                                ld a, b
                                or c
                                jp nz, CopyServerLoop
EndServerLine:
                                ld a, (URLNumber)
                                inc a
                                cp "8"
                                jp nc, NoMoreLines
                                ld (URLNumber), a
                                ld a, (CurrentRow)
                                inc a
                                ld (CurrentRow), a
                                jp ReadURLLoop
NoMoreLines:

                                call esxDOS.fClose
                                jp c, Error

                                ld a, (CurrentRow)
                                ld (ConnectMenu31.ItemCount), a
                                jp LoadSettings.Return

ConfigFileName:                 db "NXTEL.CFG", 0               ; Relative to application
ConfigFileNameLen               equ $-ConfigFileName
KeyBuffer:                      db "URL", [URLNumber]"1", 0
KeyBufferLen                    equ $-KeyBuffer
Error:
                                push af
                                ld hl, ConfigFileName
                                ld de, esxDOS.FileNameBuffer
                                ld iy, de
                                ld bc, ConfigFileNameLen
                                ldir
                                MMU5(8, false)
                                pop af
                                jp esxDOS.Error2
ValueBuffer:                    ds 151
ValueBufferLen                  equ $-ValueBuffer-1
FileBuffer:                     ds 128
FileBufferLen                   equ $-FileBuffer

pend


Welcome31                       proc
                                ld hl, Menus.Welcome
                                ld de, DisplayBuffer
                                ld bc, Menus.Size
                                ldir
                                ld hl, Version
                                ld de, DisplayBuffer+667
                                ld bc, 12
                                ldir
                                jp Welcome.Return
Version:                        PadStringLeftSpaces(VersionOnlyValue, 12)
pend



MainMenu31                      proc
                                Border(Black)
                                ld hl, Menus.Main
                                ld de, DisplayBuffer
                                ld bc, Menus.Size
                                ldir
                                jp MainMenu.Return
pend



ConnectMenu31                   proc
                                Border(Black)
                                ld a, (ItemCount)
                                or a
                                jp z, MenuConnect.None
                                xor a
                                ld (CurrentItem), a
                                ld a, "1"
                                ld (CurrentDigit), a

                                ld hl, Menus.Connect
                                ld de, DisplayBuffer
                                ld bc, Menus.Size
                                ldir
FillItemsLoop:
                                ld hl, DisplayBuffer+282
                                ld a, [CurrentItem]SMC
                                ld e, a
                                ld d, 80                        ; Two teletext display lines
                                mul
                                add hl, de
                                ld a, [CurrentDigit]SMC
                                ld (hl), a
                                add hl, 3
                                push hl                         ; Position in display buffer

                                ld hl, ConnectMenuDisplay.Table
                                ld a, (CurrentItem)
                                ld e, a
                                ld d, ConnectMenuDisplay.Size
                                mul
                                add hl, de                      ; hl = Source position
                                pop de                          ; de = Destination position
                                ld bc, ConnectMenuDisplay.Size

                                ld a, (hl)
                                or a
                                jp z, NextLine
                                ldir
                                ld a, b
                                or c
                                jp z, NextLine
NextLine:
                                ld a, [ItemCount]SMC
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
LastKey:
                                ld hl, DisplayBuffer+282
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
BackText:                       db "Back to Main Menu"
BackTextLen                     equ $-BackText
pend



Menus                           proc
  Welcome:                      import_bin "..\pages\ClientWelcome.bin"
  Main:                         import_bin "..\pages\MainMenu.bin"
  Connect:                      import_bin "..\pages\ConnectMenu.bin"
  Size                          equ 1000
pend



ConnectMenuDisplay proc Table:
  Size   equ 36
  Count  equ 7
  Length equ Size*Count
  ds Length, 0
pend



ConnectMenuServer proc Table:
  Size   equ 100
  Count  equ 7
  Length equ Size*Count
  ds Length, 0
pend

