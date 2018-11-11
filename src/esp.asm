; esp.asm

ESPConnect              proc
                        Turbo(MHz14)
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
StartReceive:           Pause(10)
                        call ESPReceiveIPDInit
MainLoop:
                        call ESPReceiveIPD
                        jp z, Received
                        //jp c, Error
                        NextRegRead($56)
                        ld (RestoreKeyPage), a
                        nextreg $56, 6
                        call ReadKey
                        jp nc, NoKey
SendKey:
                        ld (CharToSend2), a
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        call ESPReceiveWaitPrompt
                        ld d, [CharToSend2]SMC
                        call ESPSendChar

NoKey:                  nextreg $56, [RestoreKeyPage]SMC
                        jp MainLoop
Received:
                        nextreg $57, 30
                        ld hl, ESPBuffer+1
                        ld de, DisplayBuffer
                        ld bc, DisplayBuffer.Length
                        ldir
                        call RenderBuffer
                        FlipScreen()
                        nextreg $56, 6
                        call InitKey
                        ei
                        jp StartReceive



                        ResetLastKeypress()
WaitForKeyPress:
                        call ReadKeyOLD                 ; a = char
                        jp c, KeyPressed                ; carry = char received
                        jp WaitForKeyPress
KeyPressed:
                        ld (CharToSend), a
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        call ESPReceiveWaitPrompt
                        ld d, [CharToSend]SMC
                        call ESPSendChar
                        jp StartReceive
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



MatrixOLD proc Table:

  ; Mark   Row   Bit0   Bit1   Bit2   Bit3   Bit4  Index  Row      Modifier
  db $FF,  $7F,   $20,  None,   $6D,   $6E,   $62  ;   0  BNMSsSp  None
  db $FF,  $BF,   $5F,   $6C,   $6B,   $6A,   $68  ;   1  HJKLEn   None
  db $FF,  $DF,   $70,   $6F,   $69,   $75,   $79  ;   2  YUIOP    None
  db $FF,  $EF,   $30,   $39,   $38,   $37,   $36  ;   3  67890    None
  db $FF,  $F7,   $31,   $32,   $33,   $34,   $35  ;   4  54321    None
  db $FF,  $FB,   $71,   $77,   $65,   $72,   $74  ;   5  TREWQ    None
  db $FF,  $FD,   $61,   $73,   $64,   $66,   $67  ;   6  GFDSA    None
  db $FF,  $FE,  None,   $7A,   $78,   $63,   $76  ;   7  VCXZCs   None
  db $FF,  $7F,  None,  None,   $2E,   $2C,   $2A  ;   8  BNMSsSp  Symbol Shift
  db $FF,  $BF,  None,   $3D,  None,   $2B,  None  ;   9  HJKLEn   Symbol Shift
  db $FF,  $DF,   $22,   $3B,  None,  None,  None  ;  10  YUIOP    Symbol Shift
  db $FF,  $EF,  None,   $29,   $28,   $27,   $26  ;  11  67890    Symbol Shift
  db $FF,  $F7,   $21,   $40,  None,   $24,   $25  ;  12  54321    Symbol Shift
  db $FF,  $FB,  None,  None,  None,   $3C,   $3E  ;  13  TREWQ    Symbol Shift
  db $FF,  $FD,  None,  None,  None,  None,  None  ;  14  GFDSA    Symbol Shift
  db $FF,  $FE,  None,   $3A,   $23,   $3F,   $2F  ;  15  VCXZCs   Symbol Shift
  db $FF,  $7F,  None,  None,   $4D,   $4E,   $42  ;  16  BNMSsSp  Caps Shift
  db $FF,  $BF,  None,   $4C,   $4B,   $4A,   $48  ;  17  HJKLEn   Caps Shift
  db $FF,  $DF,   $50,   $4F,   $49,   $55,   $59  ;  18  YUIOP    Caps Shift
  db $FF,  $EF,   $7F,  None,  None,  None,  None  ;  19  67890    Caps Shift
  db $FF,  $F7,  None,  None,  None,  None,  None  ;  20  54321    Caps Shift
  db $FF,  $FB,   $51,   $57,   $45,   $52,   $54  ;  21  TREWQ    Caps Shift
  db $FF,  $FD,   $41,   $53,   $44,   $46,   $47  ;  22  GFDSA    Caps Shift
  db $FF,  $FE,  None,   $5A,   $58,   $43,   $56  ;  23  VCXZCs   Caps Shift

  struct
    Mark   ds 1
    Row    ds 1
    Bit0   ds 1
    Bit1   ds 1
    Bit2   ds 1
    Bit3   ds 1
    Bit4   ds 1
  Size send

  Len           equ $-Table
  SS            equ Len/3
  CS            equ SS*2
  Count         equ SS
  Mask          equ %000 00001

//zeusprint Size, Len, SS, CS, Count
pend



ReadKeyOLD              proc
                        ld hl, MatrixOLD.Table
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoCaps
Caps:                   ld hl, MatrixOLD.Table+MatrixOLD.CS
                        jp NoSymbol
NoCaps                  ld b, high zeuskeyaddr("[sym]")
                        in a, (c)
                        and zeuskeymask("[sym]")
                        jp nz, NoSymbol
Symbol:                 ld hl, MatrixOLD.Table+MatrixOLD.SS
NoSymbol:               ld e, MatrixOLD.Count
NewRow:                 ld a, (hl)
                        inc hl
                        dec e
                        cp $FF
                        jp nz, NotNewRow
                        ld b, (hl)
                        inc hl
                        dec e
                        ld a, MatrixOLD.Mask
                        ld (Mask), a
                        jp NewRow
NotNewRow:              or a
                        jp z, IgnoreKey
                        ld d, a
                        in a, (c)
                        and [Mask]SMC
                        and %000 11111
                        jp z, Pressed
                        ld a, e
                        or a
                        jp z, NonePressed
IgnoreKey:              ld a, (Mask)
                        rlca                    ; Position mask for next key in row
                        ld (Mask), a
                        jp NewRow
NonePressed:
                        ld (LastKey), a
IgnoreRepeat:           xor a                   ; Clear carry (no key pressed)
                        ret
Pressed:
                        ld a, [LastKey]SMC
                        cp d
                        jp z, IgnoreRepeat
                        ld a, d
                        ld (LastKey), a         ; a = key pressed
                        scf                     ; Set carry (key pressed)
                        ret
pend

