; nxtermutils.asm

PrintHex                proc
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
                        ret
pend

