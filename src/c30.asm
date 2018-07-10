; c30.asm

DisplayBuffer           proc
                        import_bin "..\docs\data\telstar-91a-raw.bin"
                        //import_bin "..\docs\data\wenstar-91a-raw.bin"
                        //import_bin "..\docs\data\dont-panic-raw.bin"
                        Length equ $-DisplayBuffer
pend



Fonts                   proc
SAA5050:                //import_bin "..\fonts\SAA5050.fzx"
                        include "..\fonts\SAA5050.asm"
                        Temp := $
                        org SAA5050+5
                        defb 16*8+6-1                   ; Set space to be a full 8 lines high, so
                        org Temp                        ; the font always blanks the background.
pend



ClsLayer2               proc
                        PageLayer2Bottom48K(9)
                        FillLDIR($0000, $C000, $00)
                        PageResetBottom48K()
                        ld hl, $0008                    ; Top Left (8, 0)
                        ld (RenderBuffer.Coordinates), hl

                        zeusdatabreakpoint 2, "zeusprint(1, (l-8)/6, h/8)", $+disp
                        nop

                        ret
pend



DefinePalettes          proc
                        nextreg $43, %0 001 000 0       ; Set Layer 2 primary palette, incrementing
                        nextreg $40, 00                 ; Start at index 0
                        ld c, 32
NextSet:                ld b, 8
                        ld hl, PaletteL2Primary
Loop:                   ld a, (hl)
                        inc hl
                        nextreg $41, a
                        djnz Loop
                        dec c
                        ld a, c
                        jp nz, NextSet
                        ret
pend



RenderBuffer            proc
                        ld (Stack), sp
                        ld sp, $FFFF
                        PageLayer2Bottom48K(9)
                        ld hl, DisplayBuffer.Length
                        //ld hl, 87
                        push hl
                        ld hl, DisplayBuffer
                        xor a
                        ld (IsSeparated), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
Read:
                        ld a, (hl)
                        inc hl
ProcessRead:
                        cp 32
                        jp c, NextChar                  ; Skip ASCII ctrl codes for now
                        cp 128
                        jp nc, Colours                  ; Skip teletext ctrl codes for now
ProcessRead2:
                        push hl
                        or [OrOffset]SMC
                        and [AndOffset]SMC
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
                        inc hl
                        ld e, (hl)
                        inc hl
                        ld d, (hl)                      ; de = Character offset
                        inc hl
                        ld a, (hl)
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
                        //dec b
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
                        //call WaitKey
                        pop bc                          ; Discard, balance stack
                        pop hl                          ; Display buffer next char

NextChar:
                        ld de, (Coordinates)
                        add de, 6
                        ld a, e
                        cp 248
                        jp nz, NoNextRow
                        add de, 256*8
                        ld e, 8
                        ld a, 7
                        ld (Foreground), a
                        xor a
                        ld (IsSeparated), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text

NoNextRow:              ld (Coordinates), de

                        zeusdatabreakpoint 1, "zeusprint(1, (e-8)/6, d/8), ((e-8)/6)=20 && (d/8)=18", $+disp
                        nop

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
Colours:
                        cp 136
                        jp nc, Graphics
                        push af
                        xor a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
                        pop af
SetColour:              and %111                        ; Extract color (0..7)
                        ld (Foreground), a              ; Set foreground colour
                        ld a, 32
                        jp ProcessRead2
Graphics:
                        cp 145
                        jp c, NextChar                  ; Skip 136-144 for now
                        cp 152
                        jp z, NextChar                  ; Skip 152 for now (Conceal)
                        cp 153
                        jp z, Contiguous
                        cp 154
                        jp z, Separated
                        jp nc, NextChar                 ; Skip 155-159 for now
ResetGraphics:          push af
                        ld a, [IsSeparated]SMC
                        or a
                        jp z, SetContiguous
                        ld a, %1101 1111                ; Set Separated AND
                        ld (AndOffset), a
                        ld a, %1000 0000                ; Set Separated OR
                        ld (OrOffset), a
                        jp GraphicsContinue
SetContiguous:          ld a, %1111 1111                ; Set Contiguous AND
                        ld (AndOffset), a
                        ld a, %1000 0000                ; Set Separated OR
                        ld (OrOffset), a
GraphicsContinue:
                        pop af
                        jp SetColour
Contiguous:
                        push af
                        xor a
                        jp SepSave
Separated:
                        push af
                        ld a, 1
SepSave:                ld (IsSeparated), a
NoGfxSepz:               pop af
                        ld a, (Foreground)
                        and %111
                        jp ResetGraphics
//IsSeparated:            db 0
pend



PrintChar               proc

pend



WaitKey                 proc
                        ei
                        push af
                        xor a
                        in a, ($FE)
                        cpl
                        and 15
                        halt
                        jr nz, WaitKey
Loop:
                        xor a
                        in a, ($FE)
                        cpl
                        and 15
                        halt
                        jr z, Loop
                        pop af
                        di
                        ret
pend



PaletteL2Primary        proc Table:
                        ;   RRR GGG BB  Index  Colour   Notes
                        db %000 000 00  ;   0  Black    The layer 2 primary palette repeats these
                        db %111 000 00  ;   1  Red      8 colours 32 times through indices 0..255.
                        db %000 111 00  ;   2  Green
                        db %111 111 00  ;   3  Yellow
                        db %010 010 11  ;   4  Blue     Lightened for readability on black background.
                        db %111 001 11  ;   5  Magenta  Uses $E7 because global transparency is $E3.
                        db %000 111 11  ;   6  Cyan
                        db %111 111 11  ;   7  White
pend

