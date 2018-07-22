; utilities.asm


Resources proc Table:

  ; Bank  FName  Index  Notes
  db  30,    30  ;   0  Layer 2 Teletext renderer
  //db  31,    31  ;   1  Pages31.P0 to Pages31.P7
  db  32,    32  ;   1  Pages32.P0 to Pages32.P7
  db  33,    33  ;   2  Pages33.P0 to Pages33.P7
  db  34,    34  ;   3  Pages34.P0 to Pages34.P7
  db  35,    35  ;   4  Pages35.P0 to Pages35.P7
  db  36,    36  ;   5  Pages36.P0 to Pages36.P7
  db  37,    37  ;   6  Pages37.P0 to Pages37.P7
  db  38,    38  ;   7  Pages38.P0 to Pages38.P7

  struct
    Bank        ds 1
    FName       ds 1
  Size send

  Len           equ $-Table
  Count         equ Len/Size
  ROM           equ 255

  output_bin "..\build\BankList.bin", Table, Len
pend



Pages proc Table:

  ; Bank  Slot  Duration    Notes

  db  33,    1, dw 32767+NOC;   Engineering Test Page

  db  37,    5, dw 350+NOC  ;   Title
  db  37,    7, dw  50+NOC  ;   Blank

  db  32,    0, dw 200+CLK  ;   0
  db  32,    1, dw 200+CLK  ;   1
  db  32,    2, dw 200+CLK  ;   2
  db  32,    3, dw 200+CLK  ;   3
  db  32,    4, dw 200+NOC  ;   4
  db  32,    5, dw 200+NOC  ;   5
  db  32,    6, dw 200+NOC  ;   6
  db  32,    7, dw 200+CLK  ;   7

  db  33,    0, dw 200+NOC  ;   0
  db  33,    1, dw 200+CLK  ;   1
  db  33,    2, dw 200+NOC  ;   2
  db  33,    3, dw 200+CLK  ;   3
  db  33,    4, dw 100+CLK  ;   4
  db  33,    5, dw 100+CLK  ;   5
  db  33,    6, dw 100+CLK  ;   6
  db  33,    7, dw 100+NOC  ;   7

  db  34,    0, dw 200+CLK  ;   0
  db  34,    1, dw 100+CLK  ;   1
  db  34,    2, dw 100+CLK  ;   2
  db  34,    3, dw 100+CLK  ;   3
  db  34,    4, dw 100+CLK  ;   4
  db  34,    5, dw 100+CLK  ;   5
  db  34,    6, dw 100+CLK  ;   6
  db  34,    7, dw 100+CLK  ;   7

  db  35,    0, dw 100+CLK  ;   0
  db  35,    1, dw 100+CLK  ;   1
  db  35,    2, dw 100+CLK  ;   2
  db  35,    3, dw 100+CLK  ;   3
  db  35,    4, dw 100+CLK  ;   4
  db  35,    5, dw 100+CLK  ;   5
  db  35,    6, dw 200+NOC  ;   6
  db  35,    7, dw 200+NOC  ;   7

  db  36,    0, dw 200+NOC  ;   0
  db  36,    1, dw 200+NOC  ;   1
  db  36,    2, dw 200+NOC  ;   2
  db  36,    3, dw 200+NOC  ;   3
  db  36,    4, dw 200+NOC  ;   4
  db  36,    5, dw 200+NOC  ;   5
  db  36,    6, dw 200+NOC  ;   6
  db  36,    7, dw 200+NOC  ;   7

  db  37,    0, dw 200+NOC  ;   0
  db  37,    1, dw 200+NOC  ;   1
  db  37,    2, dw 200+NOC  ;   2
  db  37,    3, dw 200+NOC  ;   3
  db  37,    4, dw 200+NOC  ;   4
  db  37,    7, dw 100+NOC  ;   7
  db  37,    6, dw 350+NOC  ;   5
  db  37,    7, dw 100+NOC  ;   7

  //db  31,    0  ;   1  dont-panic
  //db  31,    1  ;   1  dont-panic
  //db  31,    2  ;   2  double-height
  //db  31,    3  ;   3  double-height2
  //db  31,    4  ;   4  flash-steady.bin
  //db  31,    5  ;   5  double-height-copy-down
  //db  31,    6  ;   6  double-height-overflow
  //db  31,    7  ;   7  double-height-overflow2

  struct
    Bank        ds 1
    Slot        ds 1
    Duration    ds 2
  Size send

  Len           equ $-Table
  Count         equ Len/Size

  Current:      db -1
  CLK           equ %1000 0000 0000 0000
  NOC           equ %0000 0000 0000 0000
pend



LoadResources           proc

                        //xor a                           ; SNX extended snapshot leaves file handle 0 open
                        //ld (esxDOS.Handle), a

                        ld ix, FileName
                        call esxDOS.fOpen
                        jp c, Error

                        ld bc, $0002
                        ld de, $2000                    ; bcde = $22000 = 139264 = first bank
                        ld ixl, esxDOS.esx_seek_set
                        ld l, esxDOS.esx_seek_set
                        call esxDOS.fSeek
                        jp c, Error
                        xor a
                        push af
                        ld iy, Resources.Table
NextBank:
                        ld a, (iy+Resources.Bank)
                        nextreg $57, a
                        ld ix, $E000
                        ld bc, $2000
                        call esxDOS.fRead
                        jp c, Error
                        pop af
                        inc a
                        cp Resources.Count
                        jp z, Finish
                        push af
                        inc iy
                        inc iy
                        jp NextBank

Finish:
                        call esxDOS.fClose
                        jp c, Error
                        ret
Error:
                        di
                        MMU5(8, false)
                        ld iy, FileName
                        jp esxDOSerror
FileName:
  db "NXtel.sna", 0
pend



SetupDataFileSystem     proc
                        call esxDOS.GetSetDrive
                        jp c, LoadResources.Error
                        ld (esxDOS.DefaultDrive), a
                        ret
pend



esxDOSerror             proc
                        nextreg $02, 1
                        ei
                        halt
Freeze:                 jp Freeze
pend



ClsAttr                 proc
                        ClsAttrFull(DimBlackBlackP)
                        ret
pend


DoFlash                 proc
                        ld a, [Frame]SMC
                        inc a
                        and 31
                        ld (Frame), a
                        ret nz
                        nextreg $43, %0 001 000 0       ; Set Layer 2 primary palette, incrementing
                        nextreg $40, 64                 ; Start at index 64
                        ld a, [OnOff]SMC+1
                        xor 1
                        ld (OnOff), a
                        jp nz, On
Off:
                        ld e, 0                         ; Black
                        ld d, 9                         ; 8 sets of colour
OffOuter:               dec d
                        ld b, 8
                        ld a, e                         ; Colour index to set (0..7)
                        ld hl, PaletteL2Primary.Table
                        add hl, a
                        ld a, (hl)                      ; Colour to set (RGB8)
OffInner:               nextreg $41, a
                        djnz OffInner
                        inc e
                        ld b, d
                        djnz OffOuter
                        ret
On:
                        ld c, 8
NextSet:                ld b, 8
                        ld hl, PaletteL2Primary
Loop:                   ld a, (hl)
                        inc hl
                        nextreg $41, a
                        djnz Loop
                        dec c
                        ld a, c
                        jp nz, NextSet
                        //call GetTime
                        ret
pend


/*
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
*/

