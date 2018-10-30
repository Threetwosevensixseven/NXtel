; esp.asm

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



ESPReceive              proc
                        ld a, high UART_GetStatus       ; Are there any characters waiting?
                        in a, (low UART_GetStatus)      ; This inputs from the 16-bit address UART_GetStatus
                        rrca                            ; Check UART_mRX_DATA_READY flag in bit 0
                        ret nc                          ; Return immmediately if not ready (we call this in a tight loop)
                        ld a, high UART_RxD             ; Otherwise Read the byte
                        in a, (low UART_RxD)            ; from the UART Rx port
                        cp 32
                        jp c, PrintHex
                        cp 128
                        jp nc, PrintHex
                        rst 16                          ; and print it with the ROM ULA print routine.
                        ret
pend



ESPReceiveWaitOK        proc
                        ld hl, WaitFor
NotReady:               ld a, 255
                        ld(23692), a                    ; Turn off ULA scroll
                        ld a, high UART_GetStatus       ; Are there any characters waiting?
                        in a, (low UART_GetStatus)      ; This inputs from the 16-bit address UART_GetStatus
                        rrca                            ; Check UART_mRX_DATA_READY flag in bit 0
                        jp nc, NotReady                 ; If not, retry
                        ld a, high UART_RxD             ; Otherwise Read the byte
                        in a, (low UART_RxD)            ; from the UART Rx port
                        cp (hl)
                        jp z, Match
                        ld hl, WaitFor
Print:                  push hl
                        cp 32
                        jp c, PrintHex2
                        cp 128
                        jp nc, PrintHex2
                        rst 16                          ; and print it with the ROM ULA print routine.
PrintReturn:            pop hl
                        ld de, WaitForEnd
                        CpHL(de)
                        jp nz, NotReady
                        ret
WaitFor:                db "OK", CR, LF
WaitForEnd:
Match:                  inc hl
                        jp Print
pend



PrintHex2               proc
                        ld d, a
                        ld a, '['
                        rst 16
                        ld a, d
                        and %11110000
                        rrca
                        rrca
                        rrca
                        rrca
                        add 48
                        cp ':'
                        jp c, PrintLeft
                        add a, 7
PrintLeft:              rst 16
                        ld a, d
                        and %00001111
                        add 48
                        cp ':'
                        jp c, PrintRight
                        add a, 7
PrintRight:             rst 16
                        ld a, ']'
                        rst 16
                        jp ESPReceiveWaitOK.PrintReturn
pend

