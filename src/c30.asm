; c30.asm - Teletext renderer, fonts and buffers

// This gets mapped in at $E000-$FFFF

Page30Start:

DisplayBuffer           proc
                        ds 1000, 32
                        //import_bin "..\pages\telstar-91a-raw.bin"
                        Length equ $-DisplayBuffer
                        zeusassert Length=1000, "Invalid DisplayBuffer.Length!"
pend
//zeusmem DisplayBuffer+disp,"Display Buffer",40,true,true,false



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



ClearESPBuffer          proc
                        FillLDIR(DisplayBuffer, DisplayBuffer.Length, Teletext.Space)
::ResetESPBuffer:       ld hl, [Start]Origin
                        ld (RenderBuffer.Coordinates), hl
                        ret
Origin                  equ $0008                       ; Top Left (8, 0)
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
                        MMU6(14, false)
                        ld a, [WhichLayer2]9
                        xor [Toggle]5
                        ld (WhichLayer2), a
                        cp 12
                        call z, PagePrimaryScreen               ; call z,  NNNN = $CC
                        cp 12
                        call nz, PageSecondaryScreen            ; call nz, NNNN = $C4
                        call ResetESPBuffer
                        if ULAMonochrome
                           ClsAttrFull(BrightWhiteBlackP)
ToggleCLS:                 call Cls30
                        endif
                        ld hl, [PrintLength]DisplayBuffer.Length
                        push hl
                        call GetTime
DoCLS:
                        ld hl, DoubleHeightFlags                ; First pass, to set the top lines
                        ld (DHFlagPointer), hl
                        ld hl, DisplayBuffer
                        ld de, 24                               ; d = 0 (no DH); e = 24 rows
DLHLoop:                ld bc, 40
                        ld a, $CD                               ; $CD = double height
                        cpir
                        jp nz, NoDH
                        inc d
NoDH:                   ld a, d
                        ld c, e
                        ld de, [DHFlagPointer]SMC
                        ld (de), a
                        inc de
                        ld (DHFlagPointer), de
                        ld de, bc
                        dec e
                        jp nz, DLHLoop

                        ld hl, DoubleHeightFlags                ; Second pass, to set the bottom lines
                        ld bc, (24*256)+1                       ; b = 24 rows, c = 1
DHPass2:                ld a, (hl)
                        or a
                        jp z, NotDHUpper
                        inc hl
                        ld (hl), c                              ; Mark lower line of DH as 1, to be sure
                        dec b
NotDHUpper:             inc hl
                        djnz DHPass2

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
                        ld (IsConcealed), a
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
                        cp $C0                          ; Start of control code range
                        jp c, NotControl
                        cp $E0
                        jp nc, NotControl
                        sub 64
NotControl:
                        cp 32
                        jp z, Release2
                        jp c, Escape                    ; Skip ASCII ctrl codes for now

                        cp 128
                        jp nc, Colours                  ; Skip teletext ctrl codes for now
ProcessRead2:
                        push af
                        ld a, [IsConcealed]SMC
                        or a
                        jp z, NotConcealed
                        pop af
                        ld a, 32
                        jp Concealed2
NotConcealed:
                        pop af
Concealed2:
                        push hl
                        cp 64
                        jp c, NotBlastThrough
                        cp 96
                        jp nc, NotBlastThrough
                        jp BlastThrough
NotBlastThrough:        or [OrOffset]SMC
                        and [AndOffset]SMC              ; Blast through chars are 64..95 inclusive
BlastThrough:
                        if not ULAMonochrome
                          ex af, af'
                        endif
                        ld hl, [FontInUse]Fonts.SAA5050
                        push af
                        if ULAMonochrome
                          push af
                          push hl
                          MMU5(8, false)                ; FZX driver is in 16K page 4 at $A000
                          ld (FZX_FONT), hl
                          ld hl, (Coordinates)
                          ld a, 191
                          sub h
                          ld h, a
                          cp $C0
                          jp nc, ULAOutOfRange
                          ld (FZX_COL), hl
                          pop hl
                          pop af
                          ld (DebugPrint.Char), a
                          push de
                          ld de, (Coordinates)
                          call DebugPrint
                          pop de
                          push de
                          push af
                          ld hl, FZX_START.Clear
                          ld (FZX_START.PrintType), hl
                          ld hl, (FZX_COL)
                          ld (FZXPrintPos), hl
                          ld a, 255
                          call FZX_START
                          ld hl, [FZXPrintPos]SMC
                          ld (FZX_COL), hl
                          ld hl, FZX_START.OverPrint
                          ld (FZX_START.PrintType), hl
                          pop af
                          pop de
                          call FZX_START
                          jp ULAContinue1
ULAOutOfRange:            pop hl
                          pop af
                          jp ULAContinue1
Background1:              db 0
Background2:              db 0
Background3:              db 0
IsFlashing:               db 0
Foreground:               db 0
Coordinates:              dw 0
ULAContinue1:
                        else
                          ld a, h                       ; Don't fill char below with b/g colour
                          cp high Fonts.SAADouble       ; if current font is double height
                          jp z, NoFill

                          ld a, d                       ; Only fill char below with b/g colour if line is double height
                          rrca                          ; / 2
                          rrca                          ; / 4
                          rrca                          ; / 8
                          and %11111
                          push hl
                          ld hl, DoubleHeightFlags      ; Look up double height flag
                          add hl, a
                          ld a, (hl)
                          pop hl
                          or a
                          jp z, NoFill                  ; and skip if not

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
FillLoop:                 ld a, (Background1)
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


NoFill:                   pop af
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
BG:                       ld (de), a
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
TrailingLoop:             ld a, [Background3]$00
                          for n = 0 to 5
                            ld (de), a
                            inc e
                          next;n
                          inc d
                          ld a, e
                          add a, -6
                          ld e, a
                          djnz TrailingLoop
                        endif
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
                        ld (IsConcealed), a
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

                        //zeusdatabreakpoint 2, "((e-8)/6)=10 && (d/8)= 5", $+disp
                        //zeusdatabreakpoint 2, "((((e-8)/6)>0) && (((e-8)/6)<4)) && ((d/8)= 5)", $+disp
                        //nop

                        pop bc                          ; Remaining length

                        //zeusdatabreakpoint 4, "zeusprint(1, bc),bc=1", $+disp
                        //nop

                        dec bc
                        push bc
                        ld a, b
                        or c
                        jp nz, Read
Abort:                  pop bc
Return:
                        if not ULAMonochrome
                          PageResetBottom48K()
                        endif
                        //ld a, 1
                        //ld (DoFlash.FlOnOff), a
                        nextreg $14, $E3                ; Global L2 transparency colour
                        nextreg $4B, $E3                ; Global sprite transparency index
                        nextreg $4A, $00                ; Transparency fallback colour (black)
                        ld a, (WhichLayer2)
ShowLayer2:
                        if ULAMonochrome
                          cp 9
                          ld a, 0
                          jp nz, ULASwitchCont
                          ld a, 8
ULASwitchCont:            MMU2(13, false)
                          MMU3(12, false)
                          ld (FlipULAScreen.WhichULAScreen), a
                        else
                          xor 5
                          nextreg $12, a
                          PortOut($123B, $02)           ; Show layer 2 and disable write paging
                        endif
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
                        ld a, (IsConcealed)
                        or a
                        jp z, NoColourClearConceal
                        xor a
                        ld (IsConcealed), a
                        ld (IsGraphics), a
                        ld a, (Background1)
                        and %111000
                        or b
                        ld (NextForeground), a          ; Set foreground colour
                        pop bc
                        ld a, 32
                        jp ProcessRead2
NoColourClearConceal:
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
                        jp c, NotYetImplemented
                        cp 152
                        jp z, Conceal
                        cp 153
                        jp z, Contiguous
                        cp 154
                        jp z, Separated
                        cp 155
                        jp z, NotYetImplemented         ; Escape char, used for reveal
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
                        ld a, (IsConcealed)
                        or a
                        jp z, PrintHeldChar
                        xor a
                        ld (IsConcealed), a
                        ld a, 32
                        jp ProcessRead2
Conceal:
                        ld a, 1
                        ld (IsConcealed), a
                        ld a, ' '
                        jp ProcessRead2
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
                        call nz, HeightModeChanged
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
                        call nz, HeightModeChanged
                        jp z, NoChange2
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
NoChange2:              ld hl, Fonts.SAADouble
                        jp NormalHeight2
HeightModeChanged:
                        push af
                        xor a
                        ld (HoldNext), a
                        ld a, 32
                        ld (DebugPrint.HeldChar), a
                        pop af
                        ret
Escape:
                        ld a, 32
                        push hl
                        jp BlastThrough
CLS:
                        jp DoCLS
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
NotHold:                //nop

                        // Breaks during the hold graphics calculation for the current char
                        //                                                              Coordinates: XX,         YY
                        //                                                                           ||          ||
                        //zeusdatabreakpoint 1, "zeusprint(1, (e-8)/6, d/8, b, a, c, b', c'), ((e-8)/6)=99 && (d/8)= 2", $+disp
                        //nop


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



PagePrimaryScreen       proc
                        if ULAMonochrome
                          MMU2(10, false)
                          MMU3(12, false)
                        else
                          PageLayer2Bottom48K(9, false)
                          ld a, (RenderBuffer.WhichLayer2)
                        endif
                        or a
                        ret
pend



PageSecondaryScreen     proc
                        if ULAMonochrome
                          MMU2(14, false)
                          MMU3(15, false)
                        else
                          PageLayer2Bottom48K(12, false)
                          ld a, (RenderBuffer.WhichLayer2)
                        endif
                        or a
                        ret
pend



InitLayer2              proc
                        if ULAMonochrome
                          ld a, 12
                          ld (RenderBuffer.WhichLayer2), a
                        else
                          PageLayer2Bottom48K(12, false)
                          FillLDIR($0000, $C000, $00)
                          PageLayer2Bottom48K(9, false)
                          FillLDIR($0000, $C000, $00)
                        endif
                        PageResetBottom48K()
                        ret
pend



GetTime                 proc
                        ld a, [ShowClock]SMC
                        or a
                        ret z

                        if enabled ZeusDebug
                          if enabled LogESP
                            zeusmem RTC+disp,"RTC",16,true,true,false
                            zeusmem DisplayBuffer+8+disp,"DisplayBuffer",16,true,true,false

                          endif

                          ld a, $82
                          ld (DisplayBuffer+31), a
                          ld (DisplayBuffer+7), a
                          ld a, '0'
                          ld (DisplayBuffer+12), a

                          ld hl, Zeroes
                          ld de, DisplayBuffer+32
                          ld bc, ZeroesLen
                          ldir
                          zeusemucmd $FD, dw RTC        ; h:n:s.z dddd d of mmmm yyyy

                          ld hl, RTC
                          ld bc, 3
                          ld a, ':'
                          cpir
                          ld (MinStart), hl
                          ld de, DisplayBuffer+32
                          ld a, c
                          add de, a
                          xor %1
                          inc a
                          ld c, a
                          ld hl, RTC
                          ld c, a
                          ldir

                          ld hl, [MinStart]SMC
                          ld bc, 3
                          ld a, ':'
                          cpir
                          ld (SecStart), hl
                          ld de, DisplayBuffer+35
                          ld a, c
                          add de, a
                          xor %1
                          inc a
                          ld c, a
                          ld hl, (MinStart)
                          ld c, a
                          ldir

                          ld hl, [SecStart]SMC
                          ld bc, 3
                          ld a, '.'
                          cpir
                          ld de, DisplayBuffer+38
                          ld a, c
                          add de, a
                          xor %1
                          inc a
                          ld c, a
                          ld hl, (SecStart)
                          ld c, a
                          ldir

                          ld hl, RTC
                          ld bc, 14
                          ld a, ' '
                          cpir
                          ld de, DisplayBuffer+8
                          ldi
                          ldi
                          ldi

                          ld c, 14
                          cpir
                          ld (DayStart), hl
                          ld bc, 3
                          ld a, ' '
                          cpir
                          ld (MonStart), hl
                          ld de, DisplayBuffer+12
                          ld a, c
                          add de, a
                          xor %1
                          inc a
                          ld c, a
                          ld hl, [DayStart]SMC
                          ld c, a
                          ldir

                          ld hl, [MonStart]SMC
                          add hl, 3
                          ld c, 3
                          ld de, DisplayBuffer+15
                          ldir

                          ret
                        else

                          push af
                          push bc
                          push de
                          push hl
                          push ix

                          NextRegRead($50)
                          ld (Restore0), a

                          NextRegRead($51)
                          ld (Restore1), a
/*
                          NextRegRead($52)
                          ld (Restore2), a

                          NextRegRead($53)
                          ld (Restore3), a

                          NextRegRead($54)
                          ld (Restore4), a

                          NextRegRead($55)
                          ld (Restore5), a
*/
                          //NextRegRead($56)
                          //ld (Restore6), a

                          //NextRegRead($57)
                          //ld (Restore7), a

                          //di
                          //PageResetBottom48KStd()
                          nextreg $50,255
                          nextreg $51,255
                          //nextreg $56, 31
                          //nextreg $57, 30

                          //di
                          Rst8(esxDOS.M_GETDATE)
                          //Freeze()
                          di
                          jp c, Restore

                          ld ix, DisplayBuffer+31
                          ld (ix+0), $82                  ; Alpha green

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
                          add a, a
                          ld c, a
                          ld a, h
                          and %1
                          or c

                          ld c, -10
                          call Na1
                          ld (ix+7), b                    ; Second first digit
                          ld c, -1
                          call Na1
                          ld (ix+8), b                    ; Second second digit

Restore:
                          nextreg $50, [Restore0]SMC
                          nextreg $51, [Restore1]SMC
                          //nextreg $52, [Restore2]SMC
                          //nextreg $53, [Restore3]SMC
                          //nextreg $54, [Restore4]SMC
                          //nextreg $55, [Restore5]SMC
                          //nextreg $56, [Restore6]SMC
                          //nextreg $57, [Restore7]SMC

                          pop ix
                          pop hl
                          pop de
                          pop bc
                          pop af

                          ret


Na1:                      ld b, '0'-1
Na2:                      inc b
                          add a, c
                          jp c, Na2
                          sub c                           ; works as add 100/10/1
                          ret                             ; result is in b

                        endif
Disable:
                        ld a, 1
                        ld (ShowClock), a
                        ret
Enable:
                        xor a
                        ld (ShowClock), a
                        ret
Zeroes:                 db "00:00:00"
ZeroesLen               equ $-Zeroes
RTC:                    ds 8
                        ds 8
                        ds 8
                        ds 8
                        ds 8
                        ds 8
pend



PrintTime               proc
                        ld a, [Frame]-1
                        inc a
                        cp PrintTimeFrameCount()
                        jp c, NoSec
                        xor a
NoSec:                  ld (Frame), a
                        or a
                        ret nz

                        call GetTime
                        //di
                        //ld a, (Text)
                        //inc a
                        //cp '9'+1
                        //jp c, NoReset
                        //ld a, '0'
//NoReset:                ld (Text), a
                        ld hl, 40
                        ld (RenderBuffer.PrintLength), hl
                        ld hl, Layer2Addr(0, 0)
                        ld (ClearESPBuffer.Start), hl
                        xor a
                        ld (RenderBuffer.Toggle), a
                        if ULAMonochrome
                          ld a, $21                             ; ld hl, NNNN = $21
                          ld (RenderBuffer.ToggleCLS), a
                        endif
                        //ld hl, Text
                        ld hl, DisplayBuffer// DisplayBufferAddr(0, 0)
                        ld (RenderBuffer.PrintStart), hl
                        //ld bc, TextLen
                        //ldir
                        call RenderBuffer
                        ld hl, ClearESPBuffer.Origin
                        ld (ClearESPBuffer.Start), hl
                        ld hl, DisplayBuffer.Length
                        ld (RenderBuffer.PrintLength), hl
                        ld hl, DisplayBuffer
                        ld (RenderBuffer.PrintStart), hl
                        ld a, 5
                        ld (RenderBuffer.Toggle), a
                        if ULAMonochrome
                          ld a, $CD                             ; call NNNN = $CD
                          ld (RenderBuffer.ToggleCLS), a
                        endif
                        ret
pend



Cls30                   proc
                        ld (EXIT+1), sp                 ; Save the stack
                        ld sp, ATTRS_8x8                ; Set stack to end of screen
                        ld de, $0000                    ; All pixels unset
                        ld b, e                         ; Loop 256 times: 12 words * 256 = 6144 bytes
                        noflow
CLS_LOOP:               defs 12, $D5                    ; 12 lots of push de
                        djnz CLS_LOOP
EXIT:                   ld sp, $0000                    ; Restore the stack
                        ret
pend



ToggleConcealReveal     proc
                        ld a, [ConcealEnabled]SMC
                        bit 1, a
                        jp nz, Finish
                        and 1
                        ld a, Teletext.Conceal          ; Search for Conceal
                        ld e, Teletext.Reveal           ; Replace with Reveal
                        jp nz, Replace                  ; zero means conceal enabled for the current frame
                        ld a, Teletext.Reveal           ; Search for Reveal
                        ld e, Teletext.Conceal          ; Replace with Conceal
Replace:                ld hl, DisplayBuffer            ; Search start
                        ld bc, DisplayBuffer.Length     ; Search size
NextSearch:             cpir                            ; Search for next character
                        jp z, Found
NotFound:               ex af, af'
                        ld a, b
                        or c
                        jp z, Render
                        ex af, af'
                        jp NextSearch
Found:                  dec hl
                        ld (hl), e
                        inc hl
                        jp NotFound
Render:
                        call RenderBuffer
                        ld a, (ConcealEnabled)
                        xor 1
                        or 2
                        ld (ConcealEnabled), a
                        ret
Finish:
                        ld a, (ConcealEnabled)
                        xor 1
                        or 2
                        ld (ConcealEnabled), a
Flip:
                        ld a, (RenderBuffer.WhichLayer2)
                        xor 5
                        ld (RenderBuffer.WhichLayer2), a
ShowLayer2:
                        if ULAMonochrome
                          cp 9
                          ld a, 0
                          jp nz, ULASwitchCont
                          ld a, 8
ULASwitchCont:            MMU2(10, false)
                          MMU3(12, false)
                          ld (FlipULAScreen.WhichULAScreen), a
                        else
                          xor 5
                          nextreg $12, a
                          PortOut($123B, $02)           ; Show layer 2 and disable write paging
                        endif
                        ret
pend



DoubleHeightFlags       proc
                        ds 8
                        ds 8
                        ds 8
pend

zeusassert ($-Page30Start)<$2000, "Page 30 has overflowed to $"+tohex($-Page30Start,4)+"!"

