; esp.asm

ESPConnect              proc
                        StatusIcon(Sprites32.Connecting)
                        EnableCaptureTSFrame(false)
                        ld hl, ReadKeys
                        ld (KeyJumpState), hl
                        nextreg $56, 6
                        call InitKey
                        ESPSend("ATE0")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPCLOSE")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPMUX=0")
                        call ESPReceiveWaitOK
                        ld hl, ConnStringCommand        ; Start of the command to send
                        ld a, [ConnStringLen]SMC        ; Read the length without preamble
                        add a, ConnStringPreambleLen    ; Add the "AT_CIPSTART=" preamble
                        ld e, a                         ; Length of the command to send, including preamble and CRLF
                        call Connect
                        call ESPReceiveWaitOK
StartReceive:           call ESPReceiveIPDInit
                        EnableKeyboardScan(true)
MainLoop:               call ESPReceiveIPD
                        jp z, Received
                        //jp c, Error

                        NextRegRead($56)
                        ld (RestoreKeyPage), a
                        nextreg $56, 6
                        jp [KeyJumpState]ReadKeys
ReadKeys:
                        call ReadKey
                        jp nc, NoKey
                        cp Matrix.Special
                        jp nc, SpecialKey
SendKey:
                        ld (CharToSend2), a
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        call ESPReceiveWaitPrompt
                        ld d, [CharToSend2]SMC
                        call ESPSendChar
                        call ESPReceiveWaitOK
NoKey:
                        nextreg $56, [RestoreKeyPage]SMC
                        jp MainLoop
Received:
                        EnableKeyboardScan(false)
                        nextreg $57, 30
                        ld hl, ESPBuffer+1
                        ld de, DisplayBuffer
                        ld bc, DisplayBuffer.Length
                        ldir
                        ld a, 1
                        ld (ToggleConcealReveal.ConcealEnabled), a
                        call RenderBuffer
                        FlipScreen()
                        StatusIcon(Sprites32.Online)
CaptureTSFrameOrNot:    ld hl, CaptureTSFrame           ; $CD (call nnnn: enabled) or $21 (ld hl, nnnn: disabled)
                        nextreg $56, 6
                        call InitKey
                        ei
                        jp StartReceive
SpecialKey:
                        cp Matrix.FTBlack
                        jp c, NotFT
                        cp Matrix.FTWhite+1
                        jp c, FTKey
NotFT:                  cp Matrix.DownL
                        jp nz, Conceal
                        //call Browser
                        call [DownloadKeyTarget]DetectTSHeader
                        jp c, SendKey
                        ld hl, NoKey                    ; This is a real telesoftware header
                        ld (KeyJumpState), hl           ; So disable key input for now
                        EnableKeyboardScan(false)
                        EnableCaptureTSFrame(true)
                        //Border(Green)
                        //halt:halt:halt:halt:halt
                        //Border(Teletext.Border)
                        ld a, Teletext.Enter
                        jp SendKey
Conceal:
                        cp Matrix.ConcealReveal
                        jp nz, Break
                        //Border(Blue)
                        //halt:halt:halt:halt:halt
                        //Border(Teletext.Border)
                        di
                        nextreg $57, 30
                        call ToggleConcealReveal
                        FlipScreen()
                        ei
                        jp NoKey
Break:
                        cp Matrix.Break
                        jp nz, MainIndex
                        EnableKeyboardScan(false)
                        jp MainMenu
MainIndex:
                        cp Matrix.MainIndex
                        jp nz, UnknownSpecialKey
                        SendCharWaitOK('*')
                        SendCharWaitOK('1')
                        SendCharWaitOK(Teletext.Enter)
                        jp NoKey
FTKey:
                        and %111
                        add a, 48
                        ld (FTChar), a
                        SendCharWaitOK('*')
                        SendCharWaitOK('*')

                        ld a, [FTChar]SMC
                        ld (SendCharWaitOKProc.CharToSend), a
                        call SendCharWaitOKProc

                        SendCharWaitOK(Teletext.Enter)
                        jp NoKey
UnknownSpecialKey:
                        jp NoKey
Connect:
                        ld bc, UART_GetStatus           ; UART Tx port also gives the UART status when read
ReadNextChar:           ld d, (hl)                      ; Read the next byte of the text to be sent
WaitNotBusy:            in a, (c)                       ; Read the UART status
                        and UART_mTX_BUSY               ; and check the busy bit (bit 1)
                        jr nz, WaitNotBusy              ; If busy, keep trying until not busy
                        out (c), d                      ; Otherwise send the byte to the UART Tx port
                        inc hl                          ; Move to next byte of the text
                        dec e                           ; Check whether there are any more bytes of text
                        jp nz, ReadNextChar             ; If there are, read and repeat
                        ret
ConnStringCommand:      db "AT+CIPSTART="
ConnStringPreambleLen   equ $-ConnStringCommand
ConnString:             ds 102
zeusprinthex ConnStringCommand
pend



ESPReceiveIPDInit       proc
                        ld a, $F3                       ; $F3 = di
                        ld (ESPReceiveIPD), a
                        ld a, Teletext.ClearBit7
                        ld (ESPReceiveIPD.Bit7), a
                        ld hl, ESPReceiveIPD.SizeBuffer
                        ld (ESPReceiveIPD.SizePointer), hl
                        FillLDIR(ESPReceiveIPD.SizeBuffer, ESPReceiveIPD.SizeBufferLen, 0)
                        FillLDIR(ESPBuffer, ESPBuffer.Size, ' ')
                        ld hl, ESPReceiveIPD.FirstChar
                        ld (ESPReceiveIPD.StateJump), hl
                        ld (ESPReceiveIPD.CurrentState), hl
                        ret
pend



ESPReceiveIPD           proc
                        di
                        ld hl, [CurrentState]SMC
                        ld a, high UART_GetStatus       ; Are there any characters waiting?
                        in a, (low UART_GetStatus)      ; This inputs from the 16-bit address UART_GetStatus
                        rrca                            ; Check UART_mRX_DATA_READY flag in bit 0
                        jp nc, Return                   ; Return immmediately if not ready (we call this in a tight loop)
                        ld a, high UART_RxD             ; Otherwise Read the byte
                        in a, (low UART_RxD)            ; from the UART Rx port
                        jp [StateJump]SMC
FirstChar:              cp '+'
                        //zeusdatabreakpoint 1, "zeusprinthex(1, a)", $
                        jp z, MatchPlusIPD
SubsequentChar:         cp (hl)
                        //zeusdatabreakpoint 1, "zeusprinthex(1, a)", $
                        jp z, MatchSubsequent
Print:                  /*if enabled PrintIPDPacket
                          push hl
                          cp 32
                          jp c, Hex
                          cp 128
                          jp nc, Hex
                          //rst 16                          ; and print it with the ROM ULA print routine.
                        endif*/
//PrintReturn:            if enabled PrintIPDPacket
                          //pop hl
                        //endif
                        ld de, [Compare]SMC
                        CpHL(de)
                        jp z, MatchSize
Return:                 ld a, 1
                        or a                            ; Clear Z flag
                        ei
                        ret
MatchPlusIPD:           ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, PlusIPDEnd
                        ld (Compare), hl
                        ld hl, PlusIPD
                        ld (CurrentState), hl
                        jp Print
MatchSize:              ld hl, CaptureSize
                        ld (StateJump), hl
                        ld (Compare), hl
                        jp Return
MatchSubsequent:        inc hl
                        ld (CurrentState), hl
                        jp Print
//Hex:                    call PrintHex
//                        jp PrintReturn
CaptureSize:            cp ':'
                        jp z, EndOfSize
                        cp ';'
                        jp z, EndOfSize
                        ld hl, [SizePointer]SMC
                        ld (hl), a
                        inc hl
                        ld (SizePointer), hl
                        jp Print
FillBuffer:             ld b, a
                        //zeusdatabreakpoint 1, "zeusprinthex(1, a)", $
                        cp Teletext.Escape
                        jp z, EscapeNextChar
                        ld hl, [FillBufferPointer]SMC
                        or [Bit7]SMC
                        ld (hl), a
                        inc hl
                        ld (FillBufferPointer), hl
                        ld hl, (PacketSize)
                        dec hl
                        ld (PacketSize), hl
                        dec hl
                        ld a, h
                        or l
                        ld a, Teletext.ClearBit7
                        ld (Bit7), a
                        ld a, b
                        jp z, PacketCompleted
                        jp Print
EscapeNextChar:         ld a, Teletext.SetBit7
                        ld (Bit7), a
                        ld hl, (PacketSize)
                        dec hl
                        ld (PacketSize), hl
                        ld a, b
                        jp Print
EndOfSize:              ld hl, FillBuffer
                        ld (StateJump), hl
                        ld hl, 0
                        ld (PacketSize), hl
                        ld hl, SizeBuffer-1
                        ld (SizePointer2), hl
                        ld hl, (SizePointer)
DigitLoop:              ld de, SizeBuffer
                        sbc hl, de
                        ld a, l
                        or a
                        jp z, FinishedCounting
                        dec a
                        add a, a
                        ld hl, DecimalDigits
                        add hl, a
                        ld e, (hl)
                        inc hl
                        ld d, (hl)
                        ld hl, [SizePointer2]SMC
                        inc hl
                        ld (SizePointer2), hl
                        ld a, (hl)
                        sub '0'
                        jp z, Zero
                        ld b, a
                        ld hl, [PacketSize]SMC
Add:                    add hl, de
                        djnz Add
                        ld (PacketSize), hl
Zero:                   ld hl, (SizePointer)
                        dec hl
                        ld (SizePointer), hl
                        jp DigitLoop
FinishedCounting:
                        ld hl, (PacketSize)
                        inc hl
                        ld (PacketSize), hl
                        ld hl, ESPBuffer
                        ld (FillBufferPointer), hl
                        jp Print
PacketCompleted:        //ld b, a
                        ld a, $C9                       ; $C9 = ret
                        ld (ESPReceiveIPD), a
                        //ld a, b
                        //jp Print
                        xor a                           ; Clear Z flag
                        ei
                        ret
PlusIPD:                db "IPD,"
PlusIPDEnd:
SizeBuffer:             ds 6
                        ds 6
SizeBufferLen           equ $-SizeBuffer
SizeBufferEnd           equ $-1
pend



DecimalDigits proc Table:

; Multipler  Index  Digits
  dw      1  ;   0       1
  dw     10  ;   1       2
  dw    100  ;   2       3
  dw   1000  ;   3       4
  dw  10000  ;   4       5
pend



SendCharWaitOKProc      proc
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        call ESPReceiveWaitPrompt
                        ld d, [CharToSend]SMC
                        call ESPSendChar
                        call ESPReceiveWaitOK
                        ret
pend



ESPBuffer proc
  ds 2048
  Size equ $-ESPBuffer
pend



ESPReceiveWaitOK        proc
                        di
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
                        jp Print
SubsequentChar:         cp (hl)
                        jp z, MatchSubsequent
                        ld hl, FirstChar
                        ld (StateJump), hl
Print:                  /*push hl
                        cp 32
                        jp c, PrintHex2
                        cp 128
                        jp nc, PrintHex2
                        //rst 16                          ; and print it with the ROM ULA print routine.
PrintReturn:            pop hl*/
                        ld de, [Compare]SMC
                        CpHL(de)
                        jp nz, NotReady
                        ei
                        ld a, [Colour]White
                        //out (ULA_PORT), a
                        //halt
                        ret
MatchSubsequent:        inc hl
                        jp Print
MatchOK:                ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, OKEnd
                        ld (Compare), hl
                        push af
                        ld a, White
                        ld (Colour), a
                        pop af
                        ld hl, OK
                        jp Print
MatchError:             ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, ErrorEnd
                        ld (Compare), hl
                        push af
                        ld a, Red
                        ld (Colour), a
                        pop af
                        ld hl, Error
                        jp Print
MatchSendFail:          ld hl, SubsequentChar
                        ld (StateJump), hl
                        ld hl, SendFailEnd
                        ld (Compare), hl
                        push af
                        ld a, Magenta
                        ld (Colour), a
                        pop af
                        ld hl, Error
                        jp Print
OK:                     db "K", CR, LF
OKEnd:
Error:                  db "RROR", CR, LF
ErrorEnd:
SendFail:               db "END FAIL", CR, LF
SendFailEnd:
pend



ESPSend                 macro(Text)                     ; 1 <= length(Text) <= 253
                        ESPLogText("[SEND]")
                        ld hl, Address                  ; Start of the text to send
                        ld e, length(Text)+2            ; Length of the text to send, including terminating CRLF
                        jp ESPSendProc                  ; Remaining send code is generic and reusable
Address:                db Text                         ; Text bytes get planted at the end of the macro
                        db CR, LF                       ; Followed by CRLF
mend                                                    ; ESPSendProc jumps back to the address after the CRLF.



ESPSendProc             proc
                        ld bc, UART_GetStatus           ; UART Tx port also gives the UART status when read
ReadNextChar:           ld d, (hl)                      ; Read the next byte of the text to be sent
WaitNotBusy:            in a, (c)                       ; Read the UART status
                        and UART_mTX_BUSY               ; and check the busy bit (bit 1)
                        jr nz, WaitNotBusy              ; If busy, keep trying until not busy
                        out (c), d                      ; Otherwise send the byte to the UART Tx port
                        if enabled LogESP
                          ld a, d
                          call ESPLogProc
                        endif
                        inc hl                          ; Move to next byte of the text
                        dec e                           ; Check whether there are any more bytes of text
                        jp nz, ReadNextChar             ; If there are, read and repeat
                        jp (hl)                         ; Otherwise we are now pointing at the byte after the macro
pend                                                    ; So jump there to continue.



ESPSendChar             proc
                        ld bc, UART_GetStatus           ; UART Tx port also gives the UART status when read
WaitNotBusy:            in a, (c)                       ; Read the UART status
                        and UART_mTX_BUSY               ; and check the busy bit (bit 1)
                        jr nz, WaitNotBusy              ; If busy, keep trying until not busy
                        out (c), d                      ; Otherwise send the byte to the UART Tx port
                        if enabled LogESP
                          ESPLogText("[SEND]")
                          ld a, d
                          call ESPLogProc
                        endif
                        ret
pend



ESPReceiveWaitPrompt    proc
                        ld a, high UART_GetStatus       ; Are there any characters waiting?
                        in a, (low UART_GetStatus)      ; This inputs from the 16-bit address UART_GetStatus
                        rrca                            ; Check UART_mRX_DATA_READY flag in bit 0
                        jp nc, ESPReceiveWaitPrompt
                        ld a, high UART_RxD             ; Otherwise Read the byte
                        in a, (low UART_RxD)            ; from the UART Rx port
                        cp '>'
                        ret z
                        jp ESPReceiveWaitPrompt
pend


                        if enabled LogESP
ESPLogStart               equ $A000
ESPLogPointer:            dw ESPLogStart
ESPLogLen:                dw 0
                        endif


if enabled LogESP
ESPLogProc              proc                            ; a = Character to log
                        ld (RestoreA), a
                        push bc
                        push de
                        push hl
                        NextRegRead($55)
                        ld (RestoreBank), a
                        nextreg $55, 32
                        ld a, [RestoreA]SMC
                        ld hl, (ESPLogPointer)
                        ld (hl), a
                        inc hl
                        ld (ESPLogPointer), hl
                        ld hl, (ESPLogLen)
                        inc hl
                        ld (ESPLogLen), hl
                        nextreg $55, [RestoreBank]SMC
                        pop hl
                        pop de
                        pop bc
                        ret
pend
endif



DecodeDecimalProc       proc                            ; IN:   b = digit count
                        ld hl, 0                        ; OUT: hl = return value (0..65535)
                        ld (Total), hl
DigitLoop:              ld a, b
                        dec a
                        add a, a
                        ld hl, DecimalDigits.Table
                        add hl, a
                        ld e, (hl)
                        inc hl
                        ld d, (hl)                      ; de = digit multiplier (1, 10, 100, 1000, 10000)
                        ld (DigitMultiplier), de
                        ld hl, [DecimalBuffer]SMC
                        inc hl
                        ld (DecimalBuffer), hl
                        ld a, (hl)
                        sub '0'                         ; a = digit 0..9 (could also be out of range)
                        exx
                        ld hl, 0
                        or a
                        jp z, DontAdd
MultiplyLoop:           add hl, [DigitMultiplier]SMC
                        dec a
                        jp nz, MultiplyLoop
DontAdd:                add hl, [Total]SMC
                        ld (Total), hl
                        exx
                        djnz DigitLoop                  ; Repeat until no more digits left (b = 0..5)
                        ld hl, (Total)                  ; hl = return value (0..65535)
                        ret
pend



CalculateChecksum       proc                            ; IN: bc = checksummed region length
                                                        ; IN: hl = checksummed region start
                        ld e, 0                         ;  e = running checksum
ChecksumLoop:           ld a, (hl)                      ;  a = read character
                        inc hl
                        xor e
                        ld e, a                         ; Update checksum
                        dec bc
                        ld a, b
                        or c
                        jp nz, ChecksumLoop             ; Repeat until no more characters left
                        ret                             ; OUT: e = calculated checksum
pend



CaptureTSFrame          proc
                        di
                        NextRegRead($56)
                        ld (RestoreKeyPage), a
                        nextreg $56, 6
                        jp CaptureTSFrame6
Return:                 nextreg $56, [RestoreKeyPage]SMC
                        ret c
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        call ESPReceiveWaitPrompt
                        ld d, Teletext.Enter
                        call ESPSendChar
                        call ESPReceiveWaitOK
                        ret
pend

