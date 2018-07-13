; c30.asm

DisplayBuffer           proc
                        //import_bin "..\pages\telstar-91a-raw.bin"
                        //import_bin "..\pages\wenstar-91a-raw.bin"
                        //import_bin "..\pages\dont-panic-raw.bin"
                        //import_bin "..\pages\double-height.bin"
                        //import_bin "..\pages\double-height2.bin"
                        //import_bin "..\pages\flash-steady.bin"
                        import_bin "..\pages\double-height-copy-down.bin"
                        Length equ $-DisplayBuffer
                        if Length <> 1000
                          zeuserror "Invalid DisplayBuffer.Length!"
                        endif
pend



Fonts                   proc
SAA5050:                import_bin "..\fonts\SAA5050.fzx"
                        //include "..\fonts\SAA5050.asm"
                        Temp = $
                        org SAA5050+5                   ; Set spaces to be a full 8 lines high, so
                        defb 16*8+6-1                   ; the font always blanks the background.
                        org SAA5050+293
                        defb 16*8+6-1
                        org Temp

SAADouble:              import_bin "..\fonts\SAADouble.fzx"
                        //include "..\fonts\SAADouble.asm"
                        Temp = $
                        org SAADouble+5                 ; Set spaces to be a full 16 lines high, so
                        defb 16*16+6-1                  ; the font always blanks the background.
                        org SAADouble+293
                        defb 16*16+6-1
                        org Temp
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
                        call DoubleFillBuffer.Clear
                        ld hl, DisplayBuffer.Length
                        //ld hl, 880
                        push hl
                        ld hl, Fonts.SAA5050
                        ld (FontInUse), hl
                        ld hl, DisplayBuffer
                        xor a
                        ld (DoubleHeightThisLine), a
                        ld (IsSeparated), a
                        ld (Background1), a
                        ld (Background2), a
                        ld (Background3), a
                        ld (IsFlashing), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
Read:
                        ld a, (hl)
                        inc hl
ProcessRead:
                        cp 32
                        jp c, Escape                    ; Skip ASCII ctrl codes for now
                        cp 128
                        jp nc, Colours                  ; Skip teletext ctrl codes for now
ProcessRead2:
                        push hl
                        cp 64
                        jp c, NotBlastThrough
                        cp 96
                        jp nc, NotBlastThrough
                        jp BlastThrough
NotBlastThrough:        or [OrOffset]SMC
                        and [AndOffset]SMC              ; Blast through chars are 64..95 inclusive
BlastThrough:           ex af, af'
                        ld hl, [FontInUse]Fonts.SAA5050
                        push af
                        ld a, h
                        cp high Fonts.SAADouble
                        jp z, NoFill

                        push bc
                        push hl
                        push de

                        ld a, 8
                        ld (FillCounter), a
                        add d
                        ld d, a
                        ex de, hl
FillLoop:               ld a, (Background1)
                        ld (hl), a
                        ld de, hl
                        inc e
                        ld bc, 5
                        ldir
                        add hl, 256-5
                        ld a, [FillCounter]SMC
                        dec a
                        ld (FillCounter), a
                        jp nz, FillLoop


                        pop de
                        pop hl
                        pop bc


NoFill:                 pop af
                        ld a, (hl)
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
                        or [IsFlashing]$00
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
                        or a
                        jp z, EndChar
TrailingLoop:           ld a, [Background3]$00
                        for n = 0 to 5
                          ld (de), a
                          inc e
                        next;n
                        inc d
                        ld a, e
                        add a, -6
                        ld e, a
                        djnz TrailingLoop
EndChar:
                        pop bc                          ; Discard, balance stack
                        pop hl                          ; Display buffer next char
NextChar:
                        ld de, (Coordinates)
                        add de, 6
                        ld a, e
                        cp 248
                        jp nz, NoNextRow
                        ld a, [DoubleHeightThisLine]SMC
DoubleHeightPass2:      add de, 256*8
                        or a
                        jp z, NoDoubleHeightThisLine
                        add hl, 40                      ; TODO: Check for end of display buffer
                        pop bc
                        add bc, -40
                        push bc
                        xor a
                        ld (DoubleHeightThisLine), a
                        jp DoubleHeightPass2
NoDoubleHeightThisLine: ld e, 8
                        ld a, 7
                        ld (Foreground), a
                        xor a
                        ld (Background1), a
                        ld (Background2), a
                        ld (Background3), a
                        ld (IsSeparated), a
                        ld (IsFlashing), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
                        push hl
                        ld hl, Fonts.SAA5050
                        ld (FontInUse), hl
                        pop hl
NoNextRow:              ld (Coordinates), de
                        call DoubleFillBuffer.Clear

                        zeusdatabreakpoint 1, "zeusprint(1, (e-8)/6, d/8), ((e-8)/6)=1 && (d/8)=2", $+disp
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
                        xor a
                        ld (DoFlash.Frame), a
                        inc a
                        ld (DoFlash.OnOff), a
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
                        push bc
                        ld b, a
                        ld a, (Background1)
                        and %111000
                        or b
                        ld (Foreground), a              ; Set foreground colour
                        pop bc
                        ld a, 32
                        jp ProcessRead2
Graphics:
                        cp 136
                        jp z, Flash
                        cp 137
                        jp z, Steady
                        cp 140
                        jp z, NormalHeight
                        cp 141
                        jp z, DoubleHeight
                        cp 145
                        jp c, Escape                    ; Skip 136-144 for now
                        cp 152
                        jp z, Escape                    ; Skip 152 for now (Conceal)
                        cp 153
                        jp z, Contiguous
                        cp 154
                        jp z, Separated
                        cp 156
                        jp z, BlackBG
                        cp 157
                        jp z, NewBG
                        jp nc, Escape                   ; Skip 158-159 for now
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
BlackBG:
                        xor a
                        jp NewBGContinue
NewBG:
                        ld a, (Foreground)
                        and %111
                        ld (NewBGFG), a
                        rlca
                        rlca
                        rlca
                        or [NewBGFG]SMC
NewBGContinue:          ld (Background1), a
                        ld (Background2), a
                        ld (Background3), a
                        ld a, 32
                        jp ProcessRead2
NormalHeight:
                        push hl
                        ld hl, Fonts.SAA5050
NormalHeight2:          ld (FontInUse), hl
                        ld a, 32
                        pop hl
                        jp ProcessRead2
DoubleHeight:
                        ld (DoubleHeightThisLine), a
                        push hl
                        ld hl, Fonts.SAADouble
                        jp NormalHeight2
Escape:
                        ld a, 32
                        push hl
                        jp BlastThrough
Flash:
                        ld a, %0100 0000
                        jp Steady2
Steady:
                        xor a
Steady2:                ld (IsFlashing), a
                        ld a, 32
                        jp ProcessRead2
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



DoubleFillBuffer        proc Table:
                        db 0, 0, 0, 0, 0, 0, 0, 0
                        db 0, 0, 0, 0, 0, 0, 0, 0
                        db 0, 0, 0, 0, 0, 0, 0, 0
                        db 0, 0, 0, 0, 0, 0, 0, 0
                        db 0, 0, 0, 0, 0, 0, 0, 0
Clear:
                        push af
                        push bc
                        push de
                        push hl
                        ld hl, Table
                        ld a, -1
                        ld (hl), a
                        ld de, Table+1
                        ld bc, 39
                        ldir
                        pop hl
                        pop de
                        pop bc
                        pop af
                        ret
pend



PaletteL2Primary        proc Table:
                        ;   RRR GGG BB  Index  Colour   Notes
                        db %000 000 00  ;   0  Black    The layer 2 primary palette repeats these
                        db %111 000 00  ;   1  Red      8 colours 32 times through indices 0..255.
                        db %000 111 00  ;   2  Green
                        db %111 111 00  ;   3  Yellow
                        db %001 001 11  ;   4  Blue     Lightened for readability on black background.
                        db %111 001 11  ;   5  Magenta  Uses $E7 because global transparency is $E3.
                        db %000 111 11  ;   6  Cyan
                        db %111 111 11  ;   7  White
pend

//zeusprinthex $-Fonts

