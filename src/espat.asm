; espat.asm

ESPSendTest             proc
                        Turbo(MHz35)
                        PageBankZX(0, true)

                        xor a
                        ld (Bit7Mask), a                ; Clear bit 7 mask

                        /*ld c, 'N'
                        ld b, 9                         ; B=9: Specific UART BAUD rate to be set from lookup table.
                        ld de, -12                        ; DEFW 14,14,15,15,16,16,17,14 ;2000000 -14
                        rst 8
                        noflow
                        db $92*/                          ; m_DRVAPI
                        //jr c, Error

                        ld c, 'N'                       ; We want to open the ESPAT driver for use
                        ld b, $F9                       ; Open the channel
                        ld ix, Channel                  ; D>N>TCP,192.168.1.3,2380
                        ld de, ChannelLen
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jp c, TextError
                        ld (ESPAT_cmd_handle), a

                        ld c, 'N'
                        ld b, 10                        ; B=10: Set output buffer mode for channel
                        ld e, a                         ; DE is channel, 0 for default - IPD only will not work on CMD channel.
                        ld d, 0
                        ld ix, 0                        ; HL is mode 2-255 characters 1=immediate send, 0=wait for CR or 256 chars.
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jp c, Error

                        ld c, 'N'
                        ld b, $05                       ; B=5: Set CMD and IPD timeouts
                        ld de, 10                       ; DE=receive (1st parameter)
                        ld ix, 10                       ; HL=send (2nd parameter)
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jp c, Error
/*
                        ld c, 'N'
                        ld b, $04                       ; B=4: Set CMD or IPD values
                        ld de, 0                        ; DE=0 clear buffer (1st parameter)
                        ld ix, 0                        ; HL=0 clear buffer (2st parameter)
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jp c, Error
*/

Reprint:
                        ld hl, Text
                        ld (Pointer), hl
                        ld hl, TextLen
                        ld (ToPrint), hl
PrintLoop:
                        /*ld hl, (Pointer)
                        ld e, (hl)
                        ld c, 'N'
                        ld b, $FB                       ; B=$FB: Output character
                        ld a, (ESPAT_cmd_handle)
                        ld d, a
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, SendError*/

                        ld c, 'N'
                        ld b, $FC                       ; B=$fc: input character
                        ld a, (ESPAT_cmd_handle)
                        ld d, a
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, NoInput
                        cp Teletext.CLS
                        jp nz, NotCLS

                        MMU7(30, false)                 ; CLS marks the start of the buffer filling.
                        call ClearESPBuffer             ; 960 characters of the page should follow.
                        ei
                        ld hl, DisplayBuffer
                        ld (BufferPointer), hl
                        ld hl, 960
                        ld (BufferFillCount), hl
                        jp NoInput
NotCLS:
                        cp Teletext.Escape              ; 27 ($1B) means next character should have bit 7 set
                        jp nz, NotEscape
                        ld a, Teletext.SetBit7
                        ld (Bit7Mask), a                ; Set bit 7 mask
                        jp NoInput                      ; And read next character
NotEscape:
                        or [Bit7Mask]SMC
                        push af
                        //rst 16                          ; Print input character in a

                        ld hl, [BufferFillCount]SMC    ; Check to see if buffer filled yet
                        dec hl
                        ld (BufferFillCount), hl
                        ld a, l
                        or h
                        jp z, BufferFilled

                        ld a, 255
                        ld(23692), a                    ; Turn off ULA scroll
                        pop af

                        ld hl, [BufferPointer]SMC
                        MMU7(30, false)
                        ld (hl), a
                        ei
                        inc hl
                        ld (BufferPointer), hl

                        xor a
                        ld (Bit7Mask), a                ; Clear bit 7 mask
NoInput:
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, PrintLoop

                        ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp z, Close
NoKey:

                        ld hl, (Pointer)
                        inc hl
                        ld (Pointer), hl
                        ld hl, (ToPrint)
                        dec hl
                        ld (ToPrint), hl
                        ld a, h
                        or l
                        jp nz, PrintLoop

                        jp Reprint
BufferFilled:
                        MMU7(30, false)
                        call RenderBuffer               ; display page
Freeze:
                        jp Freeze
Error:
                        ld (ErrNo), a
                        Border(Red)
Error2:                 ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp nz, Error2
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, Error2
                        jp Close
SendError:
                        cp 1
                        jp nz, Error
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, PrintLoop

                        ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp z, Close

                        jp PrintLoop

ErrNo:                  db 0
ESPAT_cmd_handle:       db 0
Channel:                db "TCP,192.168.1.3,23280"
//Channel:              db "TCP,nx.nxtel.org,23280"
ChannelLen              equ $-Channel
Text:                   SendESP("")
                        SendESP("Far out in the uncharted backwaters of the unfashionable end of ")
                        SendESP("the western spiral arm of the Galaxy lies a small unregarded ")
                        SendESP("yellow sun. ")
                        SendESP("")
                        SendESP("Orbiting this at a distance of roughly ninety-two million miles ")
                        SendESP("is an utterly insignificant little blue green planet whose ape-")
                        SendESP("descended life forms are so amazingly primitive that they still ")
                        SendESP("think digital watches are a pretty neat idea. ")
                        SendESP("")
                        SendESP("This planet has - or rather had - a problem, which was this: most ")
                        SendESP("of the people on it were unhappy for pretty much of the time. ")
                        SendESP("Many solutions were suggested for this problem, but most of these ")
                        SendESP("were largely concerned with the movements of small green pieces ")
                        SendESP("of paper, which is odd because on the whole it wasn't the small ")
                        SendESP("green pieces of paper that were unhappy. ")
TextLen                 equ $-Text
Pointer:                dw 0
ToPrint:                dw 0
TestChar:               db 0

Close:
                        ld c, 'N'
                        ld b, $FA                       ; B=$fa: close channel
                        ld a, (ESPAT_cmd_handle)
                        ld d, a                         ; D=handle
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        //jp c, Error
                        jp MainMenu
pend



TextError               proc
                        sub a, $80
                        cp 1
                        jp c, Unknown
                        cp 9
                        jp nc, Unknown
Print:
                        ld (ErrValue), a

                        ld d, a
                        ld e, ErrorMessages.Size
                        mul
                        ld hl, ErrorMessages.Table - 1
                        add hl, de
                        push hl

                        ld (MsgAddr), hl
                        ei
Loop:
                        pop hl
                        inc hl
                        push hl
                        ld a, (hl)
                        or a
                        jp z, End
                        rst 16
                        jp Loop
End:
                        pop hl
                        Border(Red)
                        jp ESPSendTest.Error
Unknown:
                        xor a
                        jp Print
ErrValue                db 0
MsgAddr                 dw 0
pend



ErrorMessages           proc Table:

  ; Message                                              Index  ErrNo
  PadString("Unknown error", 40)                         ;   0    $80
  PadString("Max channels of this type open", 40)        ;   1    $81
  PadString("Invalid parameter", 40)                     ;   2    $82
  PadString("Invalid connect type", 40)                  ;   3    $83
  PadString("Syntax error in string", 40)                ;   4    $84
  PadString("Parse error in connect address", 40)        ;   5    $85
  PadString("Parse error at end of connect address", 40) ;   6    $86
  PadString("Error sending on connection", 40)           ;   7    $87
  PadString("Failed to connect to destination", 40)      ;   8    $88
  PadString("Connect address is a far call", 40)         ;   9    $89

  Size          equ 40
  Len           equ $-Table
  Count         equ Len/Size
pend



