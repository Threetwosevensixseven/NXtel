; c30.asm

DisplayBuffer           proc
                        //import_bin "..\docs\data\telstar-91a-raw.bin"
                        import_bin "..\docs\data\wenstar-91a-raw.bin"
                        Length equ $-DisplayBuffer
pend



Fonts                   proc
SAA5050:                //import_bin "..\fonts\SAA5050.fzx"
                        include "..\fonts\SAA5050.asm"
pend



ClsLayer2               proc
                        PageLayer2Bottom48K(9)
                        FillLDIR($0000, $C000, $00)
                        PageResetBottom48K()
                        ld hl, RenderBuffer.Coordinates
                        ld (hl), $0000                  ; Top Left (0, 0)
                        ret
pend



RenderBuffer            proc
                        ld (Stack), sp
                        ld sp, $FFFF
                        PageLayer2Bottom48K(9)
                        ld hl, DisplayBuffer.Length
                        push hl
                        ld hl, DisplayBuffer
Read:
                        ld a, (hl)
                        inc hl
                        cp 32
                        jp c, NextChar                  ; Skip ASCII ctrl codes for now
                        cp 128
                        jp nc, NextChar                 ; Skip teletext ctrl codes for now
                        push hl

                        ex af, af'
                        ld hl, Fonts.SAA5050
                        ld a, (hl)
                        //ld (LineHeight), a
                        ex af, af'
                        inc hl
                        inc hl
                        add a, -32
                        ld d, a
                        ld e, 3
                        mul
                        add hl, de
                        ld a, (hl)
                        inc hl
                        ld e, (hl)
                        inc hl
                        ld d, (hl)                      ; de = Character offset
                        inc hl
                        inc hl
                        ld c, (hl)
                        inc hl
                        ld b, (hl)                      ; bc = next Character offset
                        swapnib
                        and %1111                       ; a  = Character leading
                        //inc a:inc a
                        push hl
                        add hl, bc
                        dec hl
                        ld bc, hl                       ; bc = next Character address
                        pop hl
                        add hl, de
                        add hl, -4

                        ld de, [Coordinates]SMC
                        or a
                        jp z, FontLines
                        push bc
                        ld b, a
Leading:
                        ld a, [Background1]$00
                        for n = 0 to 5
                          ld (de), a
                          inc e
                        next;n
                        inc d
                        ld a, e
                        add a, -6
                        ld e, a
                        ex af, af'
                        dec a
                        ex af, af'
                        djnz Leading
                        pop bc
FontLines:

zeusprinthex Fonts.latin_capital_letter_t, Fonts.latin_capital_letter_u

                        CpHL(bc)
                        push bc
                        jp z, Trailing
CharLines:
                        ex af, af'
                        dec a
                        ex af, af'
                        ld c, (hl)
                        inc hl
                        ld b, 6
                        push de
Rotate:
                        bit 7, c
                        ld a, [Background2]%00
                        jp z, BG
                        ld a, [Foreground]$FF
BG:                     ld (de), a
                        rlc c
                        inc e
                        djnz Rotate
                        pop de
                        inc d

                        pop bc
                        jp FontLines

Trailing:
                        ex af, af'
                        ld b, a
                        jp z, EndChar
                        ld a, [Background3]$00
                        for n = 0 to 5
                          ld (de), a
                          inc e
                        next;n
                        inc d
                        ld a, e
                        add a, -6
                        ld e, a
                        djnz Trailing
EndChar:

                        pop bc
                        pop hl

                        jp Return


NextChar:
                        pop bc                          ; Remaining length
                        dec bc
                        push bc
                        ld a, b
                        or c
                        jp nz, Read
                        pop bc
Return:
                        PageResetBottom48K()
                        ld sp, [Stack]SMC
                        ret
pend



PrintChar               proc

pend



