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
                        Border(White)
                        ld hl, Menus.Main               ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        jp MainMenu.Return
pend



MenuConnect31           proc
                        Border(White)
                        FillLDIR(ESPBuffer, ESPBuffer.Size, $00)
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
LastKey:                ld a, (CurrentDigit)
                        ld (DisplayBuffer+932), a
                        ld a, (CurrentItem)
                        inc a
                        ld (ReadMenuConnectKeys.ItemCount), a
                        jp MenuConnect.Return
TempBuffer:             ds 40
pend



MenuNetworkSettings31   proc
                        ld hl, Menus.NetworkSettings    ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        ESPSend("ATE0")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIFSR")
                        call ESPCaptureOK

                        ld hl, ESPBuffer                ; Find IP address
                        ld bc, ESPBuffer.Size
                        ld a, '"'
                        cpir
                        push hl
                        push hl
                        cpir
                        ld (MacStart), hl
                        pop de
                        push bc
                        or a
                        sbc hl, de
                        dec hl
                        ld bc, hl                       ; Copy IP address to display buffer
                        ex de, hl
                        ld de, DisplayBuffer+291
                        ldir
                        pop bc
                        pop hl

                        ld hl, [MacStart]SMC
                        ld a, '"'                       ; Find MAC address
                        cpir
                        push hl
                        push hl
                        cpir
                        pop de
                        push bc
                        or a
                        sbc hl, de
                        dec hl
                        ld bc, hl                       ; Copy MAC address to display buffer
                        ex de, hl
                        ld de, DisplayBuffer+331
                        ldir
                        pop bc
                        pop hl

                        jp MenuNetworkSettings.Return

pend

//zeusmem ESPBuffer, "AT+CIFSR Log",24,true,true,false

ESPCaptureOK            proc
                        di
                        ld hl, ESPBuffer
                        ld (BufferPointer), hl
                        ld hl, FirstChar
                        ld (StateJump), hl
NotReady:               ld a, 255
                        ld(23692), a                    ; Turn off ULA scroll
                        ld a, high UART_GetStatus       ; Are there any characters waiting?
                        in a, (low UART_GetStatus)      ; This inputs from the 16-bit address UART_GetStatus
                        rrca                            ; Check UART_mRX_DATA_READY flag in bit 0
                        jp nc, NotReady                 ; If not, retry
                        ld a, high UART_RxD             ; Otherwise Read the byte
                        in a, (low UART_RxD)            ; from the UART Rx port
                        jp [StateJump]SMC
FirstChar:              cp 'O'
                        jp z, MatchOK
                        cp 'E'
                        jp z, MatchError
                        cp 'S'
                        jp z, MatchSendFail
                        jp Capture
SubsequentChar:         cp (hl)
                        jp z, MatchSubsequent
                        ld hl, FirstChar
                        ld (StateJump), hl
Capture:                push hl
                        ld hl, [BufferPointer]SMC
                        ld (hl), a
                        inc hl
                        ld (BufferPointer), hl
CaptureReturn:          pop hl
                        ld de, [Compare]SMC
                        CpHL(de)
                        jp nz, NotReady
                        ei
                        xor a                   ; Clear carry
                        ret
MatchSubsequent:        inc hl
                        jp Capture
MatchOK:                ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, OKEnd
                        ld (Compare), hl
                        ld hl, OK
                        jp Capture
MatchError:             ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, ErrorEnd
                        ld (Compare), hl
                        ld hl, Error
                        jp Capture
MatchSendFail:          ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, SendFailEnd
                        ld (Compare), hl
                        ld hl, Error
                        jp Capture
OK:                     db "K", CR, LF
OKEnd:
Error:                  db "RROR", CR, LF
ErrorEnd:
SendFail:               db "END FAIL", CR, LF
SendFailEnd:
pend



MenuKeyDescriptions31:  proc
                        Border(White)
                        ld hl, Menus.Keys               ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        jp MainMenu.Return
pend



Menus                   proc
  Welcome:              import_bin "..\pages\zx7\ClientWelcome.tt8.zx7"
  Main:                 import_bin "..\pages\zx7\MainMenu.tt8.zx7"
  Connect:              import_bin "..\pages\zx7\ConnectMenu.tt8.zx7"
  NetworkSettings:      import_bin "..\pages\zx7\NetworkSettingsMenu.tt8.zx7"
  Keys:                 import_bin "..\pages\zx7\KeysMenu.tt8.zx7"
  //StatusMessages:     import_bin "..\pages\zx7\StatusMessages.tt8.zx7"
  Size                  equ 1000
pend

