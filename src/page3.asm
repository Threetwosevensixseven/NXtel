; page3.asm - KEYBOARD HANDLER

Page3Temp16  equ $
Page3Start32 equ Ringo
Page3Start16 equ Page3Start32
org              Page3Start32
dispto zeuspage(3)

; KEYBOARD HANDLER - 8K PAGE 6 ($C000)

InitKey                 proc
                        ld hl, KeyBuffer
                        ld (KB.WritePointer), hl
                        ld (KB.ReadPointer), hl
                        ld hl, 0
                        ld (KB.CharsAvailable), hl
                        ret
pend



ScanKeyboard            proc
                        ld de, 0
                        ld (SFXNumber), a
                        ld hl, Matrix.Table
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoCaps
Caps:                   ld d, Matrix.CS                 ; d = CapsShift offset
NoCaps:                 ld b, high zeuskeyaddr("[sym]")
                        in a, (c)
                        and zeuskeymask("[sym]")
                        jp nz, NoSymbol
Symbol:                 ld e, Matrix.SS                 ; 3 = SymbolShift offset
NoSymbol:               ld a, d
                        add e
                        ld hl, Matrix.Table
                        add hl, a
                        xor a
                        ld (SFXNumber), a
                        ld e, Matrix.Count
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
IgnoreKey:              ld a, e
                        or a
                        jp z, NonePressed
                        ld a, (Mask)
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
                        ld hl, (KB.WritePointer)
                        ld de, (KB.ReadPointer)
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
NoWrap:                 ld (KB.WritePointer), hl
                        ld hl, (KB.CharsAvailable)
                        inc hl
                        ld (KB.CharsAvailable), hl
                        ld e, [SFXNumber]SMC
                        call PlaySFXProc
                        ret
BufferFull:
                        ld de, (KB.CharsAvailable)
                        ld a, e
                        or d
                        jp z, NotReallyFull
                        Border(Red)
                        Pause(8000)
                        Border(Black)
                        ret
pend



ReadKey                 proc
                        ld hl, (KB.CharsAvailable)
                        ld a, h
                        or l
                        ret z                           ; Clear carry (no key)
ProcessChar:
                        ex de, hl
                        ld hl, (KB.ReadPointer)
                        ld a, (hl)
                        inc hl
                        ld bc, KeyBuffer.EndAddr
                        CpHL(bc)
                        jp nz, NoReadWrap
                        ld hl, KeyBuffer
NoReadWrap:             ld (KB.ReadPointer), hl
                        dec de
                        ld (KB.CharsAvailable), de
                        scf                             ; Set carry (key pressed)
                        ret                             ; a = char
pend



KeyBuffer               proc
                        ds 1024
  EndAddr:
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
  db $FF,  $DF,   $22,   $3B, Index,  None,  None  ;  10  YUIOP    Symbol Shift
  db $FF,  $EF,  None,   $29,   $28,   $27,   $26  ;  11  67890    Symbol Shift
  db $FF,  $F7,   $21,   $40,  None,   $24,   $25  ;  12  54321    Symbol Shift
  db $FF,  $FB,  None,  None,  None,   $3C,   $3E  ;  13  TREWQ    Symbol Shift
  db $FF,  $FD,  None, Concl, DownL,  None,  None  ;  14  GFDSA    Symbol Shift
  db $FF,  $FE,  None,   $3A,   $23,   $3F,   $2F  ;  15  VCXZCs   Symbol Shift
  db $FF,  $7F, Break,  None,   $4D,   $4E, Break  ;  16  BNMSsSp  Caps Shift
  db $FF,  $BF,  None,   $4C,   $4B,   $4A,   $48  ;  17  HJKLEn   Caps Shift
  db $FF,  $DF,   $50,   $4F,   $49,   $55,   $59  ;  18  YUIOP    Caps Shift
  db $FF,  $EF,   $7F,  None,  None,  None,  None  ;  19  67890    Caps Shift
  db $FF,  $F7,  None,  None,  None,  None,  None  ;  20  54321    Caps Shift
  db $FF,  $FB,   $51,   $57,   $45,   $52,   $54  ;  21  TREWQ    Caps Shift
  db $FF,  $FD,   $41,   $53,   $44,   $46,   $47  ;  22  GFDSA    Caps Shift
  db $FF,  $FE,  None,   $5A,   $58,   $43,   $56  ;  23  VCXZCs   Caps Shift
  db $FF,  $7F,  None,  None,  None,  None,  None  ;  24  BNMSsSp  Symbol+Caps Shift
  db $FF,  $BF,  None,  None,  None,  None,  None  ;  25  HJKLEn   Symbol+Caps Shift
  db $FF,  $DF,  None,  None,  None,  None,  None  ;  26  YUIOP    Symbol+Caps Shift
  db $FF,  $EF, FTBla,  None,  None, FTWhi, FTYel  ;  27  67890    Symbol+Caps Shift
  db $FF,  $F7, FTBlu, FTRed, FTMag, FTGre, FTCya  ;  28  54321    Symbol+Caps Shift
  db $FF,  $FB,  None,  None,  None,  None,  None  ;  29  TREWQ    Symbol+Caps Shift
  db $FF,  $FD,  None,  None,  None,  None,  None  ;  30  GFDSA    Symbol+Caps Shift
  db $FF,  $FE,  None,  None,  None,  None,  None  ;  31  VCXZCs   Symbol+Caps Shift

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
  SS            equ Len/4
  CS            equ SS*2
  SSCS          equ SS*3
  Count         equ SS
  Mask          equ %000 00001
  Special       equ $80
  DownL         equ $FE
  Concl         equ $FD
  ConcealReveal equ Concl
  Break         equ $FC
  Index         equ $FB
  MainIndex     equ Index
  // Insert special keys $FA..F8 here
  FTWhi         equ $F7
  FTWhite       equ FTWhi
  FTYel         equ $F6
  FTYellow      equ FTYel
  FTCya         equ $F5
  FTCyan        equ FTCya
  FTGre         equ $F4
  FTGreen       equ FTGre
  FTMag         equ $F3
  FTMagenta     equ FTMag
  FTRed         equ $F2
  FTBlu         equ $F1
  FTBlue        equ FTBlu
  FTBla         equ $F0
  FTBlack       equ FTBla
pend



DetectTSHeader          proc
                        if enabled LogESP
                          //zeusmem $4C000,"Display Buffer",20,true,true,false
                        endif
                        di
                        ld (Stack), sp
                        NextRegRead($57)
                        ld (RestorePage), a
                        nextreg $57, 30
                        ld hl, DisplayBuffer+40
                        ld bc, Teletext.TSFrameSize
                        TSHeaderMatch(Teletext.Pipe)
                        TSHeaderMatch('A')
                        push hl                         ; Save start of checksummed region
                        TSHeaderMatch(Teletext.Pipe)
                        TSHeaderMatch('G')
                        TSHeaderBodySkip(1)             ; Skip frame letter. This will break if there are two
                        TSHeaderMatch(Teletext.Pipe)    ; frames, which is a possibility in the specification.
                        TSHeaderMatch('I')
                        push hl                         ; Save start of filename
                        TSHeaderFind(Teletext.Pipe)
                        push hl                         ; Save end of filename
                        TSHeaderMatch('L')
                        TSHeaderBodySkip(3)             ; Skip frame count (we don't need to use it)
                        TSHeaderMatch(Teletext.Pipe)
                        push hl                         ; Save end of checksummed region
                        TSHeaderMatch('Z')
                        ld de, ESPBuffer
                        ldi:ldi:ldi                     ; Copy checksum to buffer
                        DecodeDecimal(ESPBuffer, 3)
                        ld a, l                         ; In this case we only want the LSB (0..255)
                        ld (Checksum), a                ; so save it for later
                        pop hl
                        pop de
                        pop de
                        pop de
                        scf
                        sbc hl, de
                        ld bc, hl                       ; bc = checksummed region length
                        ex de, hl                       ; hl = checksummed region start
                        call CalculateChecksum          ;  e = calculated checksum
                        ld a, [Checksum]SMC             ;  a = stored checksum
                        cp e
                        jp nz, NotTSHeader              ; Abort if checksum mismatch
                        loop 6
                          dec sp                        ; Move the stack pointer to the filename end
                        lend
                        pop hl                          ; hl = Filename end
                        pop de                          ; de = filename start
                        scf
                        sbc hl, de
                        ex de, hl                       ; hl = Source
                        ld bc, de                       ; bc = Length
                        ld de, FileName                 ; de = Destination
                        ldir                            ; Copy filename
                        xor a
                        ld (de), a                      ; Add a terminating null
                        xor a                           ; Clear carry (valid header)
                        jp IsTSHeader
NotTSHeader:
                        scf                             ; Set carry (invalid header)
IsTSHeader:
                        ld a, $CD                       ; $CD (call nnnn: enabled)
                        ld (CaptureTSFrame6.CreateFileOrNot), a
                        ld a, Teletext.Offset0
                        ld (CaptureTSFrame6.Offset), a
                        nextreg $57, [RestorePage]SMC
                        ld sp, [Stack]SMC
                        ei
                        ret
FileName:               ds 260
FileNameLen             equ $-FileName
pend



CaptureTSFrame6         proc                            ; Interrupts are already off
                        if enabled LogESP
                          //zeusmem $4C000,"Display Buffer",20,true,true,false
                          //zeusmem TSDecodeBuffer,"TS Decode Buffer",20,true,true,false
                        endif
                        ld (Stack), sp
                        NextRegRead($57)
                        ld (RestorePage), a
                        nextreg $57, 30
                        ld hl, DisplayBuffer+40
                        ld bc, Teletext.TSFrameSize
                        TSBodyMatch(Teletext.Pipe)
                        TSBodyMatch('A')
                        push hl                         ; Save start of checksummed region
                        TSBodyMatch(Teletext.Pipe)
                        TSBodyMatch('G')
                        TSHeaderBodySkip(1)             ; Skip frame letter. This will break if there are two
                        TSBodyMatch(Teletext.Pipe)      ; frames, which is a possibility in the specification.
                        TSBodyMatch('I')
                        push hl                         ; Save start of file body
                        TSBodyFind(Teletext.PipeZ)
                        push hl                         ; Save end of checksumsummed region
                        ld de, ESPBuffer
                        ldi:ldi:ldi                     ; Copy checksum to buffer
                        DecodeDecimal(ESPBuffer, 3)
                        ld a, l                         ; In this case we only want the LSB (0..255)
                        ld (Checksum), a                ; so save it for later
                        pop hl                          ; hl = end of checksummed region
                        pop de
                        pop de                          ; de = start of checksummed region
                        scf
                        sbc hl, de
                        dec hl
                        ld bc, hl                       ; bc = checksummed region length
                        ex de, hl                       ; hl = checksummed region start
                        call CalculateChecksum          ;  e = calculated checksum
                        ld a, [Checksum]SMC             ;  a = stored checksum
                        cp e
                        jp nz, NotTSBody                ; Abort if checksum mismatch
                        nop
                        loop 6
                          dec sp                        ; Move the stack pointer to the file body start
                        lend
                        pop hl                          ; hl = end of checksummed region
                        pop de                          ; de = start of file body
                        scf
                        sbc hl, de
                        dec hl
                        ld bc, hl                       ; bc = file body length (including possible |F EOF marker)
                        ld hl, de
                        add hl, bc
                        dec hl
                        dec hl
                        ld a, (hl)
                        cp '|'
                        jp nz, NotEOF
                        inc hl
                        ld a, (hl)
                        cp 'F'
                        jp nz, NotEOF
EOF:                    ld a, 1
                        ld (IsEOF), a
                        dec bc
                        dec bc                          ; Remove the |F EOF marker from the file length
                        jp SaveFileFrame
NotEOF:                 nop
                        xor a
                        ld (IsEOF), a
SaveFileFrame:
                        //ld ix, de                       ; ix = source, bc = length
                        push de
                        push bc
CreateFileOrNot:        ld hl, TSCreateFile             ; $CD (call nnnn: enabled) or $21 (ld hl, nnnn: disabled)

// Decode frame
                        pop bc                          ; bc = source length
                        pop hl                          ; hl = source start
                        ld de, TSDecodeBuffer           ; de = destination start
                        ld iyl, [Offset]SMC             ; Offset starts at 0 (0,-64,+64,+96,+128,+160)
DecodeNextChar:
                        ld a, (hl)
                        cp Teletext.Pipe
                        jp nz, NotPipe
Pipe:
                        inc hl
                        dec bc                          ; Skip pipe
                        ld a, (hl)                      ; and look at next character

                                                        ; AZ            - Only in header, ignored in body, not terminated
                                                        ; L102345FE¾    - In body, not terminated
                                                        ; GTD           - Terminated with |I
                                                        ; Anything else - Ignored and terminated with |I
Pipe0:
                        cp '0'                          ; |0 - Offset is +0
                        jp nz, Pipe1
                        ld iyl, Teletext.Offset0
                        jp Advance2
Pipe1:
                        cp '1'                          ; |1 - Offset is -64
                        jp nz, Pipe2
                        ld iyl, Teletext.Offset1
                        jp Advance2
Pipe2:
                        cp '2'                          ; |2 - Offset is +64
                        jp nz, Pipe3
                        ld iyl, Teletext.Offset2
                        jp Advance2
Pipe3:
                        cp '3'                          ; |3 - Offset is +96
                        jp nz, Pipe4
                        ld iyl, Teletext.Offset3
                        jp Advance2
Pipe4:
                        cp '4'                          ; |4 - Offset is +128
                        jp nz, Pipe5
                        ld iyl, Teletext.Offset4
                        jp Advance2
Pipe5:
                        cp '5'                          ; |5 - Offset is +160
                        jp nz, PipeL
                        ld iyl, Teletext.Offset5
                        jp Advance2
PipeL:
                        cp 'L'                          ; |L - EOL - Replace with CR (eventually specify in cfg)
                        jp nz, PipeE
                        ld a, CR
                        ld (de), a
                        jp Advance
PipeE:
                        cp 'E'                          ; |E - Escaped pipe - Replace with |
                        jp nz, PipeThreeQuarters
                        ld a, Teletext.Pipe
                        ld (de), a
                        jp Advance
PipeThreeQuarters:
                        cp Teletext.ThreeQuarters       ; |¾ - Escaped ¾ - Replace with ¾
                        jp nz, PipeUnknown
                        ld (de), a
                        jp Advance
PipeUnknown:






NotPipe:
                        cp Teletext.ThreeQuarters       ; ¾ - Replace with space
                        jp nz, NormalChar
                        ld a, ' '
NormalChar:
                        add a, iyl                      ; Add current offset
                        ld (de), a                      ; Not pipe, copy directly
Advance:
                        inc de
Advance2:
                        inc hl
                        dec bc
                        ld a, c
                        or b
                        jp nz, DecodeNextChar
SaveOffset:
                        ld a, iyl
                        ld (Offset), a
WriteFile:
                        ex de, hl
                        ld de, TSDecodeBuffer
                        or a
                        sbc hl, de
                        ld bc, hl                       ; bc = length
                        ld ix, TSDecodeBuffer           ; ix = source
                        call esxDOS.fWrite              ; ix = source, bc = length
                        jp c, TSCreateFile.Error
                        xor a                           ; Clear carry (valid body)
                        jp IsTSBody
NotTSBody:
                        call esxDOS.fClose              ; In case we were writing a file. Ignore error.
                        ld a, $CD                       ; $CD (call nnnn: enabled)
                        ld (CreateFileOrNot), a
                        ld hl, ESPConnect.ReadKeys
                        ld (ESPConnect.KeyJumpState), hl
                        EnableCaptureTSFrame(false)
                        ld a, (RestorePage)
                        nextreg $57, a
                        scf                             ; Set carry (invalid body)
                        ld hl, (Stack)
                        ld sp, hl
                        jp CaptureTSFrame.Return
IsTSBody:
                        ld a, [IsEOF]SMC
                        cp 1
                        jp z, NotTSBody
                        nextreg $57, [RestorePage]SMC
                        ld sp, [Stack]SMC
                        or a                            ; Clear carry (valid body)
                        jp CaptureTSFrame.Return
pend



TSCreateFile            proc
                        push hl
                        push bc
                        call esxDOS.fClose              ; Just in case there was a file already open. Ignore error.
                        ld ix, DetectTSHeader.FileName
                        call esxDOS.fCreate
                        jp c, Error
                        ld a, $21                       ; $21 (ld hl, nnnn: disabled)
                        ld (CaptureTSFrame6.CreateFileOrNot), a
                        pop bc
                        pop hl
                        ret
Error:                  push af
                        ld hl, DetectTSHeader.FileName
                        ld de, esxDOS.FileNameBuffer
                        ld iy, de
                        ld bc, esxDOS.FileNameBufferLen
                        ldir
                        MMU5(8, false)
                        pop af
                        jp esxDOS.Error2
pend



TSBodyFindProc          proc
                        push hl
                        ld hl, [SearchText]SMC
                        ld a, (hl)
                        ld iyl, a                       ; iyl = search text length
                        inc hl
                        ld (Buffer), hl
                        pop hl
                        ld de, [Buffer]SMC
                        ld a, (de)
                        cpir
                        jp po, NotFound
FindNextChar:           dec iyl
                        ld a, iyl
                        or a
                        jp z, Found
                        inc de
                        ld a, (de)
                        cpi
                        jp po, NotFound
                        jp nz, TSBodyFindProc
                        jp FindNextChar
Found:                  xor a                           ; Set zero (found)
                        ret
NotFound:               pop de                          ; Lose return address
                        jp CaptureTSFrame6.NotTSBody    ; and jp straight to failure point
pend



TSDecodeBuffer          proc
                        ds Teletext.TSFrameSize+10
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

