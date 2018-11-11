; page3.asm - KEYBOARD HANDLER

Page3Temp16  equ $
Page3Start32 equ Ringo
Page3Start16 equ Page3Start32
org              Page3Start32
dispto zeuspage(3)

; KEYBOARD HANDLER - 8K PAGE 6 ($C000)

InitKey                 proc
                        ld hl, KeyBuffer
                        ld (KeyBuffer.WritePointer), hl
                        ld (KeyBuffer.ReadPointer), hl
                        ld hl, 0
                        ld (KeyBuffer.CharsAvailable), hl
                        ret
pend



ProcessKey              proc
                        ld hl, Matrix.Table
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoCaps
Caps:                   ld hl, Matrix.Table+Matrix.CS
                        jp NoSymbol
NoCaps                  ld b, high zeuskeyaddr("[sym]")
                        in a, (c)
                        and zeuskeymask("[sym]")
                        jp nz, NoSymbol
Symbol:                 ld hl, Matrix.Table+Matrix.SS
NoSymbol:               ld e, Matrix.Count
NewRow:                 ld a, (hl)
                        inc hl
                        dec e
                        cp $FF
                        jp nz, NotNewRow
                        ld b, (hl)
                        inc hl
                        dec e
                        ld a, Matrix.Mask
                        ld (Mask), a
                        jp NewRow
NotNewRow:              or a
                        jp z, IgnoreKey
                        ld d, a
                        in a, (c)
                        and [Mask]SMC
                        and %000 11111
                        jp z, Pressed
                        ld a, e
                        or a
                        jp z, NonePressed
IgnoreKey:              ld a, (Mask)
                        rlca                    ; Position mask for next key in row
                        ld (Mask), a
                        jp NewRow
NonePressed:
                        ld (LastKey), a
                        ret
Pressed:
                        ld a, [LastKey]SMC
                        cp d
                        ret z
                        ld a, d
                        ld (LastKey), a
                        ld hl, (KeyBuffer.WritePointer)
                        ld de, (KeyBuffer.ReadPointer)
                        ld c, a
                        CpHL(de)
                        jp z, BufferFull
NotReallyFull:
                        ld (hl), c
                        inc hl
                        ld de, KeyBuffer.EndAddr
                        CpHL(de)
                        jp nz, NoWrap
                        ld hl, KeyBuffer
NoWrap:                 ld (KeyBuffer.WritePointer), hl
                        ld hl, (KeyBuffer.CharsAvailable)
                        inc hl
                        ld (KeyBuffer.CharsAvailable), hl
                        ret
BufferFull:
                        ld de, (KeyBuffer.CharsAvailable)
                        ld a, e
                        or d
                        jp z, NotReallyFull
                        Border(Red)
                        Pause(8000)
                        Border(Black)
                        ret
pend

ReadKey                 proc
                        ld hl, (KeyBuffer.CharsAvailable)
                        ld a, h
                        or l
                        ret z                           ; Clear carry (no key)
ProcessChar:
                        ex de, hl
                        ld hl, (KeyBuffer.ReadPointer)
                        ld a, (hl)
                        inc hl
                        ld bc, KeyBuffer.EndAddr
                        CpHL(bc)
                        jp nz, NoReadWrap
                        ld hl, KeyBuffer
NoReadWrap:             ld (KeyBuffer.ReadPointer), hl
                        dec de
                        ld (KeyBuffer.CharsAvailable), de
                        scf                             ; Set carry (key pressed)
                        ret                             ; a = char
pend


KeyBuffer               proc
                        ds 1024
  EndAddr:
  WritePointer:         dw 0
  ReadPointer:          dw 0
  CharsAvailable:       dw 0
pend



Matrix proc Table:

  ; Mark   Row   Bit0   Bit1   Bit2   Bit3   Bit4  Index  Row      Modifier
  db $FF,  $7F,   $20,  None,   $6D,   $6E,   $62  ;   0  BNMSsSp  None
  db $FF,  $BF,   $5F,   $6C,   $6B,   $6A,   $68  ;   1  HJKLEn   None
  db $FF,  $DF,   $70,   $6F,   $69,   $75,   $79  ;   2  YUIOP    None
  db $FF,  $EF,   $30,   $39,   $38,   $37,   $36  ;   3  67890    None
  db $FF,  $F7,   $31,   $32,   $33,   $34,   $35  ;   4  54321    None
  db $FF,  $FB,   $71,   $77,   $65,   $72,   $74  ;   5  TREWQ    None
  db $FF,  $FD,   $61,   $73,   $64,   $66,   $67  ;   6  GFDSA    None
  db $FF,  $FE,  None,   $7A,   $78,   $63,   $76  ;   7  VCXZCs   None
  db $FF,  $7F,  None,  None,   $2E,   $2C,   $2A  ;   8  BNMSsSp  Symbol Shift
  db $FF,  $BF,  None,   $3D,  None,   $2B,  None  ;   9  HJKLEn   Symbol Shift
  db $FF,  $DF,   $22,   $3B,  None,  None,  None  ;  10  YUIOP    Symbol Shift
  db $FF,  $EF,  None,   $29,   $28,   $27,   $26  ;  11  67890    Symbol Shift
  db $FF,  $F7,   $21,   $40,  None,   $24,   $25  ;  12  54321    Symbol Shift
  db $FF,  $FB,  None,  None,  None,   $3C,   $3E  ;  13  TREWQ    Symbol Shift
  db $FF,  $FD,  None,  None,  None,  None,  None  ;  14  GFDSA    Symbol Shift
  db $FF,  $FE,  None,   $3A,   $23,   $3F,   $2F  ;  15  VCXZCs   Symbol Shift
  db $FF,  $7F,  None,  None,   $4D,   $4E,   $42  ;  16  BNMSsSp  Caps Shift
  db $FF,  $BF,  None,   $4C,   $4B,   $4A,   $48  ;  17  HJKLEn   Caps Shift
  db $FF,  $DF,   $50,   $4F,   $49,   $55,   $59  ;  18  YUIOP    Caps Shift
  db $FF,  $EF,   $7F,  None,  None,  None,  None  ;  19  67890    Caps Shift
  db $FF,  $F7,  None,  None,  None,  None,  None  ;  20  54321    Caps Shift
  db $FF,  $FB,   $51,   $57,   $45,   $52,   $54  ;  21  TREWQ    Caps Shift
  db $FF,  $FD,   $41,   $53,   $44,   $46,   $47  ;  22  GFDSA    Caps Shift
  db $FF,  $FE,  None,   $5A,   $58,   $43,   $56  ;  23  VCXZCs   Caps Shift

  struct
    Mark   ds 1
    Row    ds 1
    Bit0   ds 1
    Bit1   ds 1
    Bit2   ds 1
    Bit3   ds 1
    Bit4   ds 1
  Size send

  Len           equ $-Table
  SS            equ Len/3
  CS            equ SS*2
  Count         equ SS
  Mask          equ %000 00001
pend



Page3End32   equ $-1
Page3End16   equ Page3End32
Page3Size equ Page3End32-Page3Start32+1
if Page3Size<>(Page3End16-Page3Start16+1)
  zeuserror "Page3Size calculation error"
endif
zeusprinthex "Pg3Size = ", Page3Size
org Page3Temp16
disp 0

