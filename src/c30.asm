; c30.asm

DisplayBuffer           proc
                        ds 1000, 32
                        //import_bin "..\pages\telstar-91a-raw.bin"
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
                        //FillLDIR($0000, $C000, $00)
                        ld hl, $0008                    ; Top Left (8, 0)
                        ld (RenderBuffer.Coordinates), hl
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

                        call GetTime
                        ld a, [WhichLayer2]SMC+1
                        xor 1
                        ld (WhichLayer2), a
                        call z, PageLayer2Primary
                        call nz, PageLayer2Secondary
                        call ClsLayer2

                        ld hl, [PrintLength]DisplayBuffer.Length
                        //ld hl, 880
                        push hl
                        ld hl, Fonts.SAA5050
                        ld (FontInUse), hl
                        ld hl, [PrintStart]DisplayBuffer
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
                        ld a, $FF
                        ld (Foreground), a
                        ld (NextForeground), a
                        xor a
                        ld (IsGraphics), a
                        ld (DoubleHeightThisLine), a
                        ld (IsSeparated), a
                        ld (IsSeparatedForHold), a
                        ld (IsSeparatedNext), a
                        ld (Background1), a
                        ld (Background2), a
                        ld (Background3), a
                        ld (IsFlashing), a
                        ld (HoldActive), a
                        ld (HoldNext), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
Read:
                        ld a, (HoldNext)
                        ld (HoldActive), a
                        ld a, (NextForeground)
                        ld (Foreground), a
                        ld a, (IsSeparatedNext)
                        ld (IsSeparated), a
                        xor a
                        ld (ResetHeldCharNextTime), a
                        ld a, (hl)
                        inc hl
ProcessRead:
                        cp 32
                        jp c, Escape                    ; Skip ASCII ctrl codes for now
                        jp z, Release2
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
BlastThrough:
                        ex af, af'
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
                        cp $C0
                        jp nc, OutOfScreen
                        ld d, a
                        ex de, hl
FillLoop:               ld a, (Background1)
                        ld (hl), a
                        ld de, hl
                        inc e
                        ld bc, 5
                        for n = 1 to 5
                          ldi
                        next ;n
                        add hl, 256-5
                        ld a, [FillCounter]SMC
                        dec a
                        ld (FillCounter), a
                        jp nz, FillLoop
OutOfScreen:
                        pop de
                        pop hl
                        pop bc


NoFill:                 pop af
                        ld a, (hl)
                        ex af, af'
                        ld (DebugPrint.Char), a
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
                        call DebugPrint
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
                        ld a, d
                        cp $C0
                        jp nc, Abort
                        pop bc
                        add bc, -40
                        push bc
                        xor a
                        ld (DoubleHeightThisLine), a
                        jp DoubleHeightPass2
NoDoubleHeightThisLine: ld e, 8
                        ld a, 7
                        ld (Foreground), a
                        ld (NextForeground), a
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
                        xor a
                        ld (IsGraphics), a
                        ld (Background1), a
                        ld (Background2), a
                        ld (Background3), a
                        ld (IsSeparated), a
                        ld (IsSeparatedForHold), a
                        ld (IsSeparatedNext), a
                        ld (IsFlashing), a
                        ld (HoldActive), a
                        ld (HoldNext), a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
                        push hl
                        ld hl, Fonts.SAA5050
                        ld (FontInUse), hl
                        pop hl
NoNextRow:              ld (Coordinates), de

                        ld a, [ResetHeldCharNextTime]SMC
                        or a
                        jp z, NoResetHeldChar
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
NoResetHeldChar:

                        // Breaks at the end of the previous char
                        //                  Coordinates: XX,         YY
                        //                               ||          ||

                        zeusdatabreakpoint 2, "((e-8)/6)=27 && (d/8)= 7", $+disp
                        //zeusdatabreakpoint 2, "((((e-8)/6)>0) && (((e-8)/6)<4)) && ((d/8)= 5)", $+disp
                        nop

                        pop bc                          ; Remaining length
                        dec bc
                        push bc
                        ld a, b
                        or c
                        jp nz, Read
Abort:                  pop bc
Return:
                        PageResetBottom48K()
                        xor a
                        ld (DoFlash.Frame), a
                        inc a
                        ld (DoFlash.OnOff), a
                        nextreg $14, $E3                ; Global L2 transparency colour
                        nextreg $4B, $E3                ; Global sprite transparency index
                        nextreg $4A, $00                ; Transparency fallback colour (black)
                        ld a, (WhichLayer2)
                        or a
                        ld a, 9
                        jp z, ShowLayer2
                        ld a, 12
ShowLayer2:             nextreg $12, a
                        PortOut($123B, $02)             ; Show layer 2 and disable write paging
                        ld sp, [Stack]SMC
                        ret
Colours:
                        cp 128
                        jp z, PrintHeldChar             ; Black text not allowed
                        cp 136
                        jp nc, Graphics
                        push af

                        ld a, (OrOffset)
                        bit 7, a
                        jp z, NotGfx
                        ld a, 1
                        ld (ResetHeldCharNextTime), a
NotGfx:


                        xor a
                        ld (OrOffset), a                ; Clear graphics offset back to plain text
                        dec a
                        ld (AndOffset), a               ; Clear graphics offset back to plain text
                        pop af
SetColour:              and %111                        ; Extract color (0..7)
                        push bc
                        ld b, a
                        xor a
                        ld (IsGraphics), a
                        ld a, (Background1)
                        and %111000
                        or b
                        ld (NextForeground), a          ; Set foreground colour
                        pop bc
                        jp PrintHeldChar
Graphics:
                        cp 136
                        jp z, Flash
                        cp 137
                        jp z, Steady
                        cp 138
                        jp z, PrintHeldChar             ; Black graphics not allowed
                        cp 140
                        jp z, NormalHeight
                        cp 141
                        jp z, DoubleHeight
                        cp 145
                        jp c, NotYetImplemented         ; Skip 136-144 for now
                        cp 152
                        jp z, NotYetImplemented         ; Skip 152 for now (Conceal)
                        cp 153
                        jp z, Contiguous
                        cp 154
                        jp z, Separated
                        cp 156
                        jp z, BlackBG
                        cp 157
                        jp z, NewBG
                        cp 158
                        jp z, Hold
                        cp 159
                        jp z, Release
                        jp nc, Escape
ResetGraphics:          push af
                        ld a, [IsGraphics]SMC
                        or a
                        jp nz, GraphicsContinue
ResetGraphicsAlways:    ld a, 1
                        ld (IsGraphics), a
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
                        ld a, %1000 0000                ; Set Contiguous OR
                        ld (OrOffset), a
GraphicsContinue:
                        pop af
                        and %111                        ; Extract color (0..7)
                        push bc
                        ld b, a
                        ld a, (Background1)
                        and %111000
                        or b
                        ld (NextForeground), a              ; Set foreground colour
                        pop bc
                        jp PrintHeldChar
Contiguous:
                        push af
                        xor a
                        jp SepSave
Separated:
                        push af
                        ld a, 1
SepSave:                ld (IsSeparated), a
                        ld (IsSeparatedNext), a
                        pop af
                        ld a, (Foreground)
                        and %111
                        push af
                        jp ResetGraphicsAlways
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
                        jp PrintHeldChar
NormalHeight:
                        push hl
                        ld a, (FontInUse+1)
                        cp high Fonts.SAA5050
                        jp z, NoChange1
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
NoChange1:              ld hl, Fonts.SAA5050
NormalHeight2:          ld (FontInUse), hl
                        ld a, 32
                        pop hl
                        jp ProcessRead2
DoubleHeight:
                        ld (DoubleHeightThisLine), a
                        push hl
                        ld a, (FontInUse+1)
                        cp high Fonts.SAADouble
                        jp z, NoChange2
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
NoChange2:              ld hl, Fonts.SAADouble
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
                        jp PrintHeldChar
Hold:
                        ld a, (HoldActive)
                        or a
                        jp nz, PrintHeldChar
                        ld a, 1
                        ld (HoldActive), a
                        ld (HoldNext), a
                        ld a, (IsSeparatedNext)
                        ld (IsSeparatedForHold), a
                        jp PrintHeldChar
Release:
                        xor a
                        ld (HoldNext), a
                        jp PrintHeldChar
Release2:
                        ld a, (IsGraphics)
                        or a
                        ld a, 32
                        jp z, PrintHeldChar
                        ld (DebugPrint.HeldChar), a
                        jp Release
HoldActive:
                        db 0
HoldNext:
                        db 0
NextForeground:
                        db 0
IsSeparatedNext:
                        db 0
NotYetImplemented:
PrintHeldChar:
                        ld a, (HoldActive)
                        or a
                        ld a, 32
                        jp z, ProcessRead2
                        ld a, (DebugPrint.HeldChar)
                        push hl
                        cp 64
                        jp c, NotBlastThroughHeld
                        cp 96
                        jp nc, NotBlastThroughHeld
                        jp BlastThrough
NotBlastThroughHeld:
                        push af
                        ld a, [IsSeparatedForHold]SMC
                        or a
                        jp z, SetContiguous2
                        ld a, %1101 1111                ; Set Separated AND
                        ld (AndOffset2), a
                        ld a, %1000 0000                ; Set Separated OR
                        ld (OrOffset2), a
                        jp GraphicsContinue2
SetContiguous2:         ld a, %1111 1111                ; Set Contiguous AND
                        ld (AndOffset2), a
                        ld a, %1000 0000                ; Set Separated OR
                        ld (OrOffset2), a
GraphicsContinue2:
                        pop af
                        or [OrOffset2]SMC
                        and [AndOffset2]SMC              ; Blast through chars are 64..95 inclusive
                        jp BlastThrough
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



DebugPrint              proc
                        push af
                        push bc
                        exx
                        ld a, (RenderBuffer.IsSeparated)
                        ld b, a                                 ; b' = IsSeparated
                        ld a, (RenderBuffer.IsGraphics)
                        ld c, a                                 ; c' = IsGraphics
                        exx
                        ld a, (RenderBuffer.HoldActive)
                        ld c, a                                 ; c = HoldActive
                        ld b, [Char]SMC                         ; b = hold Char
                        ld a, b
                        and %1101 1111
                        cp 128
                        ld a, (HeldChar)
                        jp z, NotHold
                        bit 7, b
                        jp z, NotHold
                        ld a, b
                        cp b
                        jp nz, HeldCharChanged
HeldCharChangedCont:    ld (HeldChar), a                        ; a = HeldChar
NotHold:                nop

                        // Breaks during the hold graphics calculation for the current char
                        //                                                              Coordinates: XX,         YY
                        //                                                                           ||          ||
                        zeusdatabreakpoint 1, "zeusprint(1, (e-8)/6, d/8, b, a, c, b', c'), ((e-8)/6)=99 && (d/8)= 2", $+disp
                        nop


                        pop bc
                        pop af
                        ret
HeldChar:
                        db 0
HeldCharChanged:
                        push af
                        ld a, (RenderBuffer.IsSeparated)
                        ld (RenderBuffer.IsSeparatedForHold), a
                        pop af
                        jp HeldCharChangedCont
pend


LoadPage                proc                    ; Bank in a (e.g. 31), Page in b (0..7)
                        di
                        nextreg $56, a
                        ld a, b
                        add a, a
                        add a, a
                        add a, $C0
                        ld h, a
                        ld l, 0
                        ld de, DisplayBuffer
                        ld bc, DisplayBuffer.Length
                        ldir
                        MMU6(0, false)
                        ret
pend



PageLayer2Primary       proc
                        PageLayer2Bottom48K(9, false)
                        ld a, 9*2
                        ld (GetTime.Page), a
                        ld a, (RenderBuffer.WhichLayer2)
                        or a
                        ret
pend



PageLayer2Secondary     proc
                        PageLayer2Bottom48K(12, false)
                        ld a, 12*2
                        ld (GetTime.Page), a
                        ld a, (RenderBuffer.WhichLayer2)
                        or a
                        ret
pend



InitLayer2              proc
                        PageLayer2Bottom48K(12, false)
                        FillLDIR($0000, $C000, $00)
                        PageLayer2Bottom48K(9, false)
                        FillLDIR($0000, $C000, $00)
                        PageResetBottom48K()
                        ret
pend



GetTime                 proc
                        ld a, [ShowClock]SMC
                        or a
                        ret z

                        call esxDOS.GetDate
                        ret c

                        ld ix, DisplayBuffer+31
                        ld (ix+0), 135                  ; Alpha white

                        ld a, d
                        and %1111 1000
                        rrca
                        rrca
                        rrca                            ; hour

                        cp 25
                        jp nc, Disable

                        ld c, -10
                        call Na1
                        ld (ix+1), b                    ; Hour first digit
                        ld c, -1
                        call Na1
                        ld (ix+2), b                    ; Hour second digit
                        ld (ix+3), ':'                  ; Colon

                        ld a, d
                        and %0000 0111
                        rlca
                        rlca
                        rlca
                        ld c, a
                        ld a, e
                        and %1110 0000
                        rlca
                        rlca
                        rlca
                        add a, c

                        ld c, -10
                        call Na1
                        ld (ix+4), b                    ; Minute first digit
                        ld c, -1
                        call Na1
                        ld (ix+5), b                    ; Minute second digit
                        ld (ix+6), ':'                  ; Colon

                        ld a, e
                        and %0001 1111

                        ld c, -10
                        call Na1
                        ld (ix+7), b                    ; Second first digit
                        ld c, -1
                        call Na1
                        ld (ix+8), b                    ; Second second digit

                        ret
Na1:                    ld b, '0'-1
Na2:                    inc b
                        add a, c
                        jp c, Na2
                        sub c                           ; works as add 100/10/1
                        ret                             ; result is in b
Page:
                        db 0
Disable:
                        ld a, $C9
                        ld (ShowClock), a
                        ret
pend



PrintTime               proc
                        ld a, (RenderBuffer.WhichLayer2)
                        or a
                        ld a, 9*2
                        jp z, Bank18
                        ld a, 12*2
Bank18:                 nextreg $50, a
                        ld hl, DisplayBuffer+31
                        ld (RenderBuffer.PrintStart), hl
                        ld hl, 9
                        ld (RenderBuffer.PrintLength), hl
                        //call RenderBuffer
                        ld hl, DisplayBuffer
                        ld (RenderBuffer.PrintStart), hl
                        ld hl, DisplayBuffer.Length
                        ld (RenderBuffer.PrintLength), hl
                        nextreg $50, 255
                        ret
pend

