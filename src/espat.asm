; espat.asm

ESPSendTest             proc

                        ld c, 'N'
                        ld b, 9                         ; B=9: Specific UART BAUD rate to be set from lookup table.
                        ld de, -12                      ; DEFW 14,14,15,15,16,16,17,14 ;2000000 -14
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        //jr c, Error

                        ld c, 'N'                       ; We want to open the ESPAT driver for use
                        ld b, $F9                       ; Open the channel
                        ld ix, Channel                  ; D>N>TCP,192.168.1.3,10000
                        ld de, ChannelLen
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, Error
                        ld (ESPAT_cmd_handle), a

                        ld c, 'N'
                        ld b, 10                        ; B=10: Set output buffer mode for channel
                        ld e, a                         ; DE is channel, 0 for default - IPD only will not work on CMD channel.
                        ld d, 0
                        ld ix, 0                        ; HL is mode 2-255 characters 1=immediate send, 0=wait for CR or 256 chars.
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, Error

                        ld c, 'N'
                        ld b, $05                       ; B=5: Set CMD and IPD timeouts
                        ld de, 10                       ; DE=receive (1st parameter)
                        ld ix, 10                       ; HL=send (2nd parameter)
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, Error

Reprint:
                        ld hl, Text
                        ld (Pointer), hl
                        ld hl, TextLen
                        ld (ToPrint), hl
PrintLoop:
                        ld hl, (Pointer)
                        ld e, (hl)
                        ld c, 'N'
                        ld b, $FB                       ; B=$FB: Output character
                        ld a, (ESPAT_cmd_handle)
                        ld d, a
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        jr c, SendError

Wait:                   ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp nz, NoKey
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
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

                        Border(Blue)
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
                        ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp nz, PrintLoop
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp z, Close
                        jp PrintLoop

ErrNo:                  db 0
ESPAT_cmd_handle:       db 0
Channel:                db "TCP,192.168.1.3,10000"
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
ToPrint                 dw 0

Close:
                        ld c, 'N'
                        ld b, $FA                       ; B=$fa: close channel
                        ld a, (ESPAT_cmd_handle)
                        ld d, a                         ; D=handle
                        rst 8
                        noflow
                        db $92                          ; m_DRVAPI
                        //jp c, Error
                        jp ESPTestMenu
pend



ESPTestMenu             proc
                        di
                        ClsAttrFull(BrightWhiteBlackP)
                        ei
                        halt
                        di
                        call Cls
                        PrintULAString(ESPTestMenu.Menu, ESPTestMenu.MenuLen)
                        ei
                        Border(Black)
Wait:                   ld bc, zeuskeyaddr("1")
                        in a, (c)
                        ld d, a
                        and zeuskeymask("1")
                        jp z, TestSend
                        ld a, d
                        and zeuskeymask("2")
                        jp z, TestReceive
                        ld a, d
                        and zeuskeymask("3")
                        jp z, Start2
                        jp Wait

Menu:                   db At, 0, 0, Ink, 7, Paper, 0, PrBright, 1, Flash, 0
                        db "ESPAT TEST MENU", CR, CR, CR
                        db "   1    Send", CR
                        db "   2    Receive", CR
                        db "   3    NXtel Demo", CR
                        db "CS+4    Back to this menu", CR, CR, CR
                        db At, 21, 0, "Choose Option..."
MenuLen                 equ $-Menu
pend



TestSend                proc
                        di
                        ClsAttrFull(BrightWhiteBlackP)
                        ei
                        halt
                        di
                        call Cls
                        PrintULAString(TestSend.Text, TestSend.TextLen)
                        ei
                        jp ESPSendTest
Text                    db At, 0, 0, Ink, 7, Paper, 0, PrBright, 1, Flash, 0
                        db "ESPAT TEST SEND", CR, CR
TextLen                 equ $-Text
pend



TestReceive             proc
                        Border(Green)
                        di
                        ClsAttrFull(BrightWhiteBlackP)
                        ei
                        halt
                        di
                        call Cls
                        PrintULAString(TestReceive.Text, TestReceive.TextLen)
                        ei
Wait:                   ld bc, zeuskeyaddr("4")
                        in a, (c)
                        and zeuskeymask("4")
                        jp nz, Wait
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, Wait
                        jp ESPTestMenu
Text                    db At, 0, 0, Ink, 7, Paper, 0, PrBright, 1, Flash, 0
                        db "ESPAT TEST RECEIVE", CR, CR
TextLen                 equ $-Text
pend

