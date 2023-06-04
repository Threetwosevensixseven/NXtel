; c31.asm - Old Cfg Reading code (deprecated)

; NXtel is copyright © 2018-2023 Robin Verhagen-Guest.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see:
; https://github.com/Threetwosevensixseven/NXtel/blob/master/LICENSE
;
; NXtel source code for the Spectrum Next client, server, page manager
; is available at: https://github.com/Threetwosevensixseven/NXtel

// This gets mapped in at $C000-$DFFF

include "dzx7_mega.asm"

Welcome31               proc
                        ld hl, Menus.Welcome            ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        ld hl, Version
                        ld de, DisplayBuffer+747
                        ld bc, 12
                        ldir
                        jp Welcome.Return
Version:                PadStringLeftSpaces(VersionOnlyValue, 12)
pend



MainMenu31              proc
                        Border(Teletext.Border)
                        ld hl, Menus.Main               ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        jp MainMenu.Return
pend

MenuConnect31           proc
                        Border(Teletext.Border)
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



FindPrintStrProc        proc
                        ld (Print), bc
                        ld (Print2), bc
                        ld (ErrStr), ix
                        ld (Term), a
                        call StrStrProc
                        jp c, NotFound
                        push hl
                        ld a, [Term]SMC
                        cpir
                        pop de
                        or a
                        sbc hl, de
                        dec hl
                        ld bc, hl
                        ex de, hl
                        ld de, [Print]SMC
                        ldir
                        ret
NotFound:               ld hl, [ErrStr]SMC
                        ld de, [Print2]SMC
Loop:                   ld a, (hl)
                        or a
                        ret z
                        ld (de), a
                        inc hl
                        inc de
                        jr Loop
pend

MenuNetworkSettings31   proc
                        ld hl, Menus.NetworkSettings    ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        ESPSend("AT")
                        call ESPReceiveWaitOKTimeout
                        jp c, Ret
                        ld hl, NetStr.b115200
                        ld bc, NetStr.b115200Len
                        ld de, DisplayBuffer+692
                        ldir
                        ESPSend("ATE0")
                        call ESPReceiveWaitOKTimeout
                        jp c, Ret
CIFSR:                  ESPSend("AT+CIFSR")
                        call ESPCaptureOK
                        jr c, CWJAP
                        FindPrintStr(NetStr.IP, '"', ESPBuffer, DisplayBuffer+292, NetStr.NA)
                        FindPrintStr(NetStr.MAC, '"', ESPBuffer, DisplayBuffer+332, NetStr.NA)
CWJAP:                  ESPSend("AT+CWJAP?")
                        call ESPCaptureOK
                        jr c, CIPSTA
                        FindPrintStr(NetStr.SSID, '"', ESPBuffer, DisplayBuffer+372, NetStr.NA)
                        FindPrintStr(NetStr.APMAC, '"', ESPBuffer, DisplayBuffer+412, NetStr.NA)
CIPSTA:                 ESPSend("AT+CIPSTA?")
                        call ESPCaptureOK
                        jr c, CIPDNS_CUR
                        FindPrintStr(NetStr.Gateway, '"', ESPBuffer, DisplayBuffer+452, NetStr.NA)
                        FindPrintStr(NetStr.Netmask, '"', ESPBuffer, DisplayBuffer+492, NetStr.NA)
CIPDNS_CUR:             ESPSend("AT+CIPDNS_CUR?")
                        call ESPCaptureOK
                        jr c, GMR
                        FindPrintStr(NetStr.DNS1, CR, ESPBuffer, DisplayBuffer+532, NetStr.NA)
                        FindPrintStr(NetStr.DNS2, CR, ESPBuffer, DisplayBuffer+572, NetStr.NA)
GMR:                    ESPSend("AT+GMR")
                        call ESPCaptureOK
                        jr c, Ret
                        FindPrintStr(NetStr.SDKVer, '(', ESPBuffer, DisplayBuffer+612, NetStr.NA)
                        FindPrintStr(NetStr.ATVer, '(', ESPBuffer, DisplayBuffer+652, NetStr.NA)
Ret:                    jp MenuNetworkSettings.Return
pend



NetStr:                 proc                            ; Null-terminated strings
  IP:                   db "TAIP,", '"', 0
  MAC:                  db "TAMAC,", '"', 0
  SSID:                 db "CWJAP:", '"', 0
  APMAC:                db '"', ",", '"', 0
  Gateway:              db "gateway:", '"', 0
  Netmask:              db "netmask:", '"', 0
  DNS2:                 db LF, "+CIPDNS_CUR:", 0
  DNS1:                 equ DNS2+1
  SDKVer:               db "T version:", 0
  ATVer:                db "DK version:", 0
  NA:                   db 0
  b115200               db "115200"
  b115200Len            equ $-b115200
pend



// Uses asm_strstr routine, with grateful thanks to Allen Albright and z88dk project
// https://github.com/z88dk/z88dk/blob/master/libsrc/_DEVELOPMENT/string/z80/asm_strstr.asm
StrStrProc              proc                            ; Return ptr in s1 to first occurrence of substring s2.
                                                        ; If s2 has zero length, s1 is returned.
                                                        ; enter:     de = char *s1 = string
                                                        ;            hl = char *s2 = substring
                                                        ; exit:      de = char *s2 = substring
                                                        ; found:     carry reset
                                                        ;            hl = ptr in s1 to substring s2
                                                        ; not found: carry set
                                                        ;            hl = 0
                                                        ; uses:      af, de, hl
                        ld a, (hl)
                        or a
                        jr z, EmptySubstring
Match1:                 ld a, (de)                      ; try to locate first char of substring in s1
                        cp (hl)                         ; a = *string
                        jr z, MatchRest                 ; string char matches first substring char
                        inc de
                        or a                            ; end of string reached?
                        jr nz, Match1
NotFound:               ex de, hl                       ; de = char *s2 = substring
                        scf
                        ret
MatchRest:              push de                         ; save s1 = string
                        push hl                         ; save s2 = substring
                        ex de, hl                       ; de = char *s2 = substring, hl = char *s1 = string
Loop:                   inc de
                        inc hl
                        ld a, (de)                      ; a = *substring
                        or a
                        jr z, MatchFound
                        cp (hl)
                        jr z, Loop                      ; char matches so still hope
NoMatch:                ld a, (hl)                      ; a = mismatch char in string
                        pop hl                          ; hl = char *s2 = substring
                        pop de                          ; de = char *s1 = string
                        inc de
                        or a                            ; if first mismatch occurred at end of string,
                        jr nz, Match1                   ; substring cannot fit so abandon early
                        jr NotFound
MatchFound:             pop de                          ; de = char *s2 = substring
                        //pop hl                        ; hl = ptr to match in s1
                        pop de                          ; Leave next buffer char in HL
                        ret
EmptySubstring:         ex de, hl
                        ret
pend



ESPCaptureOK            proc
                        di
                        ld a, $37                       ; $37 = scf
                        ld (ReturnStatus), a            ; SMC>
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
                        ld hl, (BufferPointer)  ; Ensure Buffer is null-terminated,
                        ld (hl), 0              ; so we can safely search for strings
ReturnStatus:           scf                     ; <SMC (clear or set carry)
                        ei
                        ret
MatchSubsequent:        inc hl
                        jp Capture
MatchOK:                ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, OKEnd
                        ld (Compare), hl
                        ld hl, OK
                        ld a, $AF                       ; $AF = xor a
                        ld (ReturnStatus), a
                        jp Capture
MatchError:             ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, ErrorEnd
SetError:               ld (Compare), hl
                        ld hl, Error
                        ld a, $3F
                        ld (ReturnStatus), a
                        jp Capture
MatchSendFail:          ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, SendFailEnd
                        jr SetError
OK:                     db "K", CR, LF
OKEnd:
Error:                  db "RROR", CR, LF
ErrorEnd:
SendFail:               db "END FAIL", CR, LF
SendFailEnd:
pend



MenuKeyDescriptions31   proc
                        Border(Teletext.Border)
                        ld hl, Menus.Keys               ; Source address (compressed data)
                        ld de, DisplayBuffer            ; Destination address (decompressing)
                        call dzx7_mega
                        jp MainMenu.Return
pend



SetupTestLatency31      proc
                        ld hl, Message
                        ld de, DisplayBuffer+856
                        ld bc, MessageEnd
                        ldir
                        jp TestLatency.Return
Message:                db $82, "** Press", $86, "Q", $82, "to finish **"
MessageEnd              equ $-Message
pend



TestLatency31           proc
                        ESPSend("ATE0")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPCLOSE")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPMUX=0")
                        call ESPReceiveWaitOK
                        //ESPSend("AT+CIPSTART=""TCP"",""192.168.1.3"",23280")    ; LOCAL
                        ESPSend("AT+CIPSTART=""TCP"",""nx.nxtel.org"",23281") ; TEST
                        //ESPSend("AT+CIPSTART=""TCP"",""nx.nxtel.org"",23280") ; WENDY
                        call ESPReceiveWaitOK ; The welcome page will get sent, but we can ignore it
SendLatencyMessage:
                        ESPSend("AT+CIPSEND=10")
                        call ESPReceiveWaitOK
                        ESPSendBytes(TestLatency31.Command, TestLatency31.CommandLen) ; Bytes follow inline
Command:                db 255, 253, 142, 6, "LATENT", CR, LF
CommandLen              equ $-Command
                        call ESPReceiveWaitOK
WaitForQ:
                        ld bc, zeuskeyaddr("Q")
                        in a, (c)
                        and zeuskeymask("Q")
                        jp nz, SendLatencyMessage
                        jp MenuNetworkSettings
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

