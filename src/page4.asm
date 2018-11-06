; RAM Page 4 ($C000) - FATAL ERROR HANDLER

Page4Temp16 equ $
Page4Start32 equ zeuspage(4)
Page4Disp32 equ Page4Start32 - $A000
org $A000
dispto zeuspage(4)
Page4Start16 equ $

FZX_ORG:                include "FZXdriver.asm"         ; Font routines



Font proc
  ErrorSingle:          import_bin "..\fonts\SAA5050.fzx"
  ErrorDouble:          import_bin "..\fonts\SAADouble.fzx"
pend



esxDOSerror4            proc
                        di
                        ld (ErrorNo), a
                        ld sp, $BDFF
                        nextreg $50,255                 ; MMU page bottom 48K back
                        nextreg $51,255                 ; (apart from this bank)
                        nextreg $52, 10
                        nextreg $53, 11
                        nextreg $54,  4
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging

                        NextPaletteRGB8($0F, %111 111 11, PaletteULAa)
                        NextPaletteRGB8(18, %111 000 00, PaletteULAa)
                        Border(Red)
                        FillLDIR($4000, $1800, $00)
                        FillLDIR($5800, $0300, $57)

                        ld hl, Font.ErrorDouble
                        ld (FZX_FONT), hl
                        ld hl, TextDouble
                        call ErrorPrint

                        ld hl, Font.ErrorSingle
                        ld (FZX_FONT), hl
                        ld hl, TextSingle
                        call ErrorPrint

                        push iy
                        push iy
                        pop hl
                        ld b, 25
CaseLoop:
                        ld a, (hl)
                        cp 97
                        jp c, LeaveCase
                        cp 123
                        jp nc, LeaveCase
                        sub a, 32
LeaveCase:              ld (hl), a
                        inc hl
                        djnz CaseLoop
                        pop hl
                        call ErrorPrint

                        ld hl, Text2
                        call ErrorPrint

ErrorNo equ $+1:        ld a, SMC
                        cp esxDOSerrors.Count
                        jp c, NoReset
                        xor a
NoReset:                ld d, a
                        ld e, esxDOSerrors.Size
                        mul
                        ex de, hl
                        add hl, esxDOSerrors.Table
                        call ErrorPrint

                        ld a, $BE
                        ld i, a
                        im 2
                        //ei
                        //halt
Freeze:                 jp Freeze

TextDouble:             db At,   1, 1, "NXtel", 0
TextSingle:             db At,  21, 1, "Videotex Client for ZX Spectrum Next"
                        db At,  33, 1, "By SevenFFF/Robin Verhagen-Guest"
                        db At,  46, 1
                        VersionOnly()
                        db At,  58, 1
                        BuildDate()
                        db " "
                        BuildTime()
                        db At, 160, 1, "Error reading file:"
                        db At, 172, 1
                        db 0
Text2:                  db At, 184, 1
                        db 0
pend

ErrorPrint              proc
PrintMenu:              ld a, (hl)                      ; for each character of this string...
                        or a
                        ret z                           ; check string terminator
                        or a
                        jp z, Skip                      ; skip padding character
                        push hl                         ; preserve HL
                        call FZX_START                  ; print character
                        pop hl                          ; recover HL
Skip:                   inc hl
                        jp PrintMenu
                        ret
pend



esxDOSerrors proc Table:

  ;  Error                   Padding  ErrCode
  db "Unknown error"         , ds  9  ;     0
  db "OK"                    , ds 20  ;     1
  db "Nonsense in esxDOS"    , ds  4  ;     2
  db "Statement end error"   , ds  3  ;     3
  db "Wrong file type"       , ds  7  ;     4
  db "No such file or dir"   , ds  3  ;     5
  db "I/O error"             , ds 13  ;     6
  db "Invalid filename"      , ds  6  ;     7
  db "Access denied"         , ds  9  ;     8
  db "Drive full"            , ds 12  ;     9
  db "Invalid I/O request"   , ds  3  ;    10
  db "No such drive"         , ds  9  ;    11
  db "Too many files open"   , ds  3  ;    12
  db "Bad file number"       , ds  7  ;    13
  db "No such device"        , ds  8  ;    14
  db "File pointer overflow" , ds  1  ;    15
  db "Is a directory"        , ds  8  ;    16
  db "Not a directory"       , ds  7  ;    17
  db "Already exists"        , ds  8  ;    18
  db "Invalid path"          , ds 10  ;    19
  db "Missing system"        , ds  8  ;    20
  db "Path too long"         , ds  9  ;    21
  db "No such command"       , ds  7  ;    22
  db "In use"                , ds 16  ;    23
  db "Read only"             , ds 13  ;    24
  db "Verify failed"         , ds  9  ;    25
  db "Sys file load error"   , ds  3  ;    26
  db "Directory in use"      , ds  6  ;    27
  db "MAPRAM is active"      , ds  6  ;    28
  db "Drive busy"            , ds 12  ;    29
  db "Unknown filesystem"    , ds  4  ;    30
  db "Device busy"           , ds 11  ;    31
  db "Please run NXtel on a ZX Spectrum Next"   , ds  1  ;    32

  struct
    Error    ds 22
  Size send

  Len           equ $-Table
  Count         equ Len/Size

pend

Page4End16  equ $-$A000
Page4End32  equ Page4End16+zeuspage(4)
Page4Size equ Page4End32-Page4Start32+1
zeusprinthex "Pg4Size = ", Page4Size
org Page4Temp16
dispto Ringo

