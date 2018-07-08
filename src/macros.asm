; macros.asm

Rst8                    macro(Command)
                        if NoDivMMC
                          nop                           ; take up same number of bytes
                          or a                          ; and clear carry to indicate success
                        else
                          rst $08
                          noflow
                          db Command
                        endif
mend



Turbo                   macro(Mode)
                        nextreg TurboRegister, Mode
mend



Border                  macro(Colour)
                        if Colour=0
                          xor a
                        else
                          ld a, Colour
                        endif
                        out (ULA_PORT), a
mend



PortOut                 macro(Port, Value)
                        ld bc, Port
                        ld a, Value
                        out (c), a
mend



PageBankZX              macro(Bank, ReEnableInterrupts)
                        ld bc, 0x7ffd
                        di
                        ld a, (Bank & 7) | 16
                        out (c), a
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



ClsAttrFull             macro(Colour)
                        if Colour = DimBlackBlackP
                         xor a
                        else
                          ld a, Colour
                        endif
                        ld hl, ATTRS_8x8
                        ld (hl), a
                        ld de, ATTRS_8x8+1
                        ld bc, ATTRS_8x8_COUNT-1
                        ldir
mend



NextPaletteRGB8         macro(Index, RGB8, Pal)
                        ld de, Index+(RGB8*256)
                        ld a, Pal
                        ld (NextPaletteRGB8Proc.Palette), a
                        call NextPaletteRGB8Proc
mend


FillLDIR                macro(SourceAddr, Size, Value)
                        ld a, Value
                        ld hl, SourceAddr
                        ld (hl), a
                        ld de, SourceAddr+1
                        ld bc, Size-1
                        ldir
mend



MMU0                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $50, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU1                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $51, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU2                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $52, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU3                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $53, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU4                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $54, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU5                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $55, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU6                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $56, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



MMU7                    macro(Bank, ReEnableInterrupts)
                        di
                        nextreg $57, Bank
                        if (ReEnableInterrupts)
                          ei
                        endif
mend



SetSpritePattern        macro (Address, NextPatternNo, DataPatternNo)
                        ld hl, Address+(DataPatternNo*256)
                        ld a, NextPatternNo
                        call WriteSpritePattern
mend



NextSprite              macro(ID, u16X, u8Y, PaletteOffset, bMirrorX, bMirrorY, bRotate, bVisible, Pattern)
                        ; Port $303B, if written, defines the sprite slot to be configured by ports $57 and $5B,
                        ; and also initializes the address of the palette.
                        ; Port $57 is write-only and is used to send the attributes of the selected sprite slot,
                        ; being the address is auto-incremented each writing and after sending the 4 bytes of
                        ; attributes the address points to the next sprite. The description of each byte follows below:
                        ;   1st: X position (bits 7-0).
                        ;   2nd: Y position (0-255).
                        ;   3rd: bits 7-4 is palette offset, bit 3 is X mirror, bit 2 is Y mirror,
                        ;        bit 1 is rotate flag and bit 0 is X MSB.
                        ;   4th: bit 7 is visible flag, bit 6 is reserved, bits 5-0 is Name (pattern index, 0-63).
                        B1 = low(u16X+32);
                        B2 = (u8Y+32) and %11111111
                        B3a = (PaletteOffset and %1111) shl 4           ; OOOOxxxx
                        B3b = (bMirrorX and %1) shl 3                   ; xxxxXxxx
                        B3c = (bMirrorY and %1) shl 2                   ; xxxxxYxx
                        B3d = (bRotate  and %1) shl 1                   ; xxxxxxRx
                        B3e = (((u16X+32) and %1 00000000) shr 8) and %1; xxxxxxxM
                        B3 = B3a+B3b+B3c+B3d+B3e                        ; OOOOXYRM
                        B4a = (bVisible and %1) shl 7                   ; Vxxxxxxx
                        B4b = Pattern and %111111                       ; xxPPPPPP
                        B4 = B4a+B4b                                    ; VxPPPPPP
                        ld a, ID and %111111
                        ld hl, B1+(B2*256)
                        ld de, B3+(B4*256)
                        call NextSpriteProc
mend



FillLDIR                macro(SourceAddr, Size, Value)
                        ld a, Value
                        ld hl, SourceAddr
                        ld (hl), a
                        ld de, SourceAddr+1
                        ld bc, Size-1
                        ldir
mend



PageLayer2Bottom48K     macro(Page)
                        nextreg $50, (Page*2)+0         ; MMU page bottom 48K to layer 2
                        nextreg $51, (Page*2)+1
                        nextreg $52, (Page*2)+2
                        nextreg $53, (Page*2)+3
                        nextreg $54, (Page*2)+4
                        nextreg $55, (Page*2)+5
                        nextreg $12, Page               ; Set layer 2 base page
mend



PageResetBottom48K      macro()
                        nextreg $50,255                 ; MMU page bottom 48K back
                        nextreg $51,255
                        nextreg $52, 10
                        nextreg $53, 11
                        nextreg $54,  4
                        nextreg $55,  5
mend



CpHL                    macro(Register)
                        or a
                        sbc hl, Register
                        add hl, Register
mend

