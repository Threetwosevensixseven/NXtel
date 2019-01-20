; page1.asm - CONFIG BUFFER, LINKED LIST & READ/WRITE CODE

Page1Temp16  equ $
Page1Start32 equ Ringo
Page1Start16 equ Page1Start32
org              Page1Start32
dispto zeuspage(1)

CfgBuffer:                                              ; CfgBuffer is 8KB minus the size of the linked list.
                                                        ; It starts at the bottom of 8k bank 2 ($C000),
                                                        ; and grows upwards.
if enabled ZeusDebug
  import_bin "..\sd\NXtel.cfg"                          ; When running in Zeus, the cfg file contents
endif                                                   ; will already be planted in memory in the buffer.
PreloadedCfgAddr equ $-1
PreloadedCfgLen equ $-CfgBuffer

org CfgFileStart-CfgList.Size                           ; The CfgList linked list is positioned near
CfgList proc                                            ; the top of 8k bank 2, and grows downwards.
  struct                                                ; The first record is at $DFE4-$DFF3.
    LineAddr            ds 1
    LineAddrMSB         ds 1
    KeyAddr             ds 2
    KeyLen              ds 1
    KeyLenMSB           ds 1
    ValueAddr           ds 2
    ValueLen            ds 2
    LineLen             ds 2
    PrevEntry           ds 1
    PrevEntryMSB        ds 1
    NextEntry           ds 2
  Size send
  //zeusprinthex CfgList,CfgList+CfgList.Size-1, Size
pend

                                                        ;
EOLStyle proc                                           ;
  LF       equ 0                                        ; %00     Constants to
  CR       equ 1                                        ; %01     represent the
  LFCR     equ 2                                        ; %10     four different
  CRLF     equ 3                                        ; %11     EOL styles.
  IsDouble equ %10
pend

org $DFF4                                               ; The Cfg global vars are positioned right at
CfgFileStart:      dw CfgBuffer                         ; the top of 8k bank 2, between $DFF4 and $FFFF.
CfgFileEnd:        dw PreloadedCfgAddr
CfgFileLen:        dw PreloadedCfgLen
CfgNextLineStart:  dw 0
CfgLastRecord:     dw 0
CfgLineEndings:    db 0

org $E000
ParseCfgFile            proc
                        if not enabled ZeusDebug        ; When running in Zeus, the cfg file contents
                          ld ix, FileName               ; will already be planted in memory in the buffer.
                          call esxDOS.fOpen             ; Otherwise, open cfg file.
                          jp c, CreateDefaultCfgFile
                          ld ix, CfgBuffer              ; ix = address to load into
                          ld (CfgFileStart), ix
                          ld bc, $1C00                  ; bc = number of bytes to read
                          call esxDOS.fRead             ; Read the entire file (or most of it if huge)
                          jp c, LoadSettings.Error      ; into the buffer.
                          dec hl
                          ld (CfgFileEnd), hl
                          ld (CfgFileLen), bc
                          call esxDOS.fClose            ; Close the cfg file again,ignoring any errors.
                        endif

                        xor a
                        ld (IsLastLine), a
                        ld hl, CfgBuffer                ; Detect a CR line ending
                        ld bc, (CfgFileLen)
                        ld a, CR
                        cpir
                        jp z, IsCR
                        ld hl, CfgBuffer                ; No CR at all, so detect a LF ending
                        ld bc, (CfgFileLen)
                        ld a, LF
                        cpir
                        jp z, IsLF
                        ld a, EOLStyle.LF               ; There are no line endings at all!
                        ld (CfgLineEndings), a          ; Why not assume LF, for simplicity ;)
                        jp SetupEOL

CreateDefaultCfgFile:
                        if not enabled ZeusDebug
                          cp 5                          ; Only trap "No such file or dir"
                          jp nz, LoadSettings.Error     ; Otherwise display standard error message
                          ld ix, FileName
                          call esxDOS.fCreate
                          jp c, LoadSettings.Error
                          ld ix, DefaultCfg.File
                          ld bc, DefaultCfg.Len
                          call esxDOS.fWrite
                          jp c, LoadSettings.Error
                          call esxDOS.fClose
                          jp ParseCfgFile
                        endif
IsCR:
                        ld b, a                         ; Preserve first char of line ending
                        inc hl
                        ld a, (hl)
                        or a
                        ld a, EOLStyle.CR               ; Are we CR?
                        cp LF                           ; Or CRLF?
                        jp z, IsCRLF
                        jp SaveCR                       ; We are CR /
IsCRLF:                 ld a, EOLStyle.CRLF             ; We are CRLF
SaveCR:                 ld (CfgLineEndings), a
                        jp SetupEOL
IsLF:
                        ld b, a                         ; Preserve first char of line ending
                        inc hl
                        ld a, (hl)
                        or a
                        ld a, EOLStyle.LF               ; Are we LF?
                        cp LF                           ; Or LFCR?
                        jp z, IsLFCR
                        jp SaveLF                       ; We are LR /
IsLFCR:                 ld a, EOLStyle.LFCR             ; We are LFCR
SaveLF:                 ld (CfgLineEndings), a
                        call ExtendFileByOneLine
SetupEOL:
                        and EOLStyle.IsDouble           ; a is 0..4 (EOL Style)
                        ld a, $00                       ; $00 = nop
                        ld c, a
                        jp z, SingleEOL
                        ld a, $23                       ; $23 = inc hl
                        ld c, $2B                       ; $2b = dec hl
SingleEOL:              ld (DoubleEOL1), a              ; SMC> nop or inc hl
                        ld (DoubleEOL2), a              ; SMC> nop or inc hl
                        ld a, b
                        ld (FirstEOLChar1), a           ; SMC> CR or LF
                        ld (FirstEOLChar2), a           ; SMC> CR or LF
                        ld a, c
                        ld (DoubleEOL3), a              ; SMC> nop or dec hl
ParseFile:
                        ld ix, CfgList                  ; Set up linked list at the first record,
                        xor a
                        ld (ix+CfgList.PrevEntry), a    ; set a blank previous entry
                        ld (ix+CfgList.PrevEntryMSB), a ; to signify the first record,
                        ld hl, CfgBuffer                ; and start reading at the beginning of the buffer.

//=========================================================================================================
// EACH NEW LINE STARTS AT THIS POINT
//   ix: Linked list pointer to current record
//   hl: Start of new line in the file buffer
//=========================================================================================================

ParseLine:
                        //zeusdatabreakpoint 1, "zeusdisplayaddr(true, 0, ix)", $+disp
                        //zeusdatabreakpoint 0, $+disp

                        ld (ix+CfgList.LineAddr), hl    ; Set the record start
                        ld a, (hl)
                        cp [FirstEOLChar1]SMC           ; <SMC: Is this an empty line?
                        jp nz, NonEmptyLine
DoubleEOL1:             nop//inc hl                     ; <SMC: nop (single EOL) or inc hl (double EOL)

EmptyLine:
                        ld de, (ix+CfgList.LineAddr)
                        or a                            ; Clear carry
                        sbc hl, de                      ; Since this is an empty line,
                        inc hl                          ; line length is
                        ld (ix+CfgList.LineLen), hl     ; either 1 or 2
                        inc de
                        ld (CfgNextLineStart), de       ; Set the next line start
                        call SetNoKey                   ; Signal there is no key or value on this line
                        jp SetupNextLine
NonEmptyLine:
                        cp ';'                          ; Is this a comment line?
                        jp z, Comment
                        call FindNextEOL                ; Not a blank line or comment, so fine the line end.
                        ld bc, (ix+CfgList.LineLen)
                        ld a, '='
                        cpir                            ; Does the line contain an equals?
                        jp po, NoEquals
Equals:
                        dec hl                          ; We have an equals, so work back to find the end of the key.
                        ld (EqualsAddr), hl             ; Save the equals point so we can find the value later.
                        push hl
                        ld de, (ix+CfgList.LineAddr)
                        or a                            ; Clear carry
                        sbc hl, de
                        ld b, l                         ; b = length back to the start of the line (assumes key <= 255)
                        pop hl
KeyLoop1:               dec hl
                        dec b                           ; Keep track of chars back to the start of the line
                        ld a, (hl)
                        cp ' '
                        jp z, KeyLoop1
                        ld a, b
                        or a
                        ld de, hl                       ; de = the address of the end of the key.
                        jp z, KeyStartOfLine
KeyLoop2:               dec hl                          ; Now work back to find the start of the key.
                        dec b                           ; Keep track of chars back to the start of the line
                        ld a, b
                        or a
                        jp z, KeyStartOfLine
                        ld a, (hl)
                        cp ' '
                        jp nz, KeyLoop2
                        inc hl
KeyStartOfLine:         ld (ix+CfgList.KeyAddr), hl     ; Set start of key in record
                        or a                            ; Clear carry
                        ex de, hl
                        sbc hl, de
                        inc hl
                        ld (ix+CfgList.KeyLen), hl      ; Set length of key in record

FindValue:                                              ; Now we have the key, Find the value.
                        ld hl, [EqualsAddr]SMC
                        ld de, (ix+CfgList.LineAddr)
                        or a                            ; Clear carry
                        sbc hl, de
                        ex de, hl
                        ld hl, (ix+CfgList.LineLen)
                        or a                            ; Clear carry
                        sbc hl, de
                        ld b, l
                        dec b
                        dec b                           ; b = chars remaining from the char after equals to the EOL,
                        ld a, b
                        ld (AfterEqualsLen), a          ; and save value for later.
                        ld hl, (EqualsAddr)
ValueLoop1:             inc hl
                        dec b
                        ld a, b
                        or a
                        jp z, ValueEndOfLine
                        ld a, (hl)
                        cp ' '
                        jp z, ValueLoop1
                        ld (ix+CfgList.ValueAddr), hl   ; Set the start of the value into the record
TrimValueEndSpaces:
                        ld hl, (ix+CfgList.LineAddr)
                        ld de, (ix+CfgList.LineLen)
                        add hl, de
DoubleEOL3:             nop//dec hl                     ; <SMC: nop (single EOL) or dec hl (double EOL)
                        dec hl
                        ld b, [AfterEqualsLen]SMC       ; Restore search length
ValueLoop2:             dec hl
                        dec b
                        ld a, b
                        or a
                        jp z, ValueEndOfLine
                        ld a, (hl)
                        cp ' '
                        jp z, ValueLoop2
                        ld de, (ix+CfgList.ValueAddr)   ; hl = value end address, de = value start address
                        or a
                        sbc hl, de                      ; de = value length
                        inc hl
                        ld (ix+CfgList.ValueLen), hl    ; Set the length of the value into the record
ValueEndOfLine:         jp SetupNextLine

NoEquals:                                               ; This line has no equals,
                        ld hl, (ix+CfgList.LineAddr)    ; so restore the line start, and treat like a comment
Comment:
                        call SetNoKey                   ; Setting a zero key length will make parsing ignore comments.
                        call FindNextEOL
                        jp SetupNextLine
SetNoKey:
                        xor a
                        ld (ix+CfgList.KeyLen), a
                        ld (ix+CfgList.KeyLenMSB), a
                        ret
FindNextEOL:
                        ld a, [FirstEOLChar2]SMC        ; <SMC: CR or LF
                        push hl                         ; hl is already the start of the search
                        ex de, hl
                        ld hl, (CfgFileStart)
                        or a                            ; Clear carry
                        sbc hl, de
                        ex de, hl                       ; This is amount of the file we've processed so far
                        ld hl, (CfgFileLen)
                        or a                            ; Clear carry
                        sbc hl, de
                        ld bc, hl                       ; This is the number of bytes until the end of the file
                        pop hl
                        push hl
                        cpir                            ; Search for the first EOL char
DoubleEOL2:             nop//inc hl                     ; <SMC: nop (single EOL) or inc hl (double EOL)

                        push hl
                        push de
                        ex de, hl
                        ld hl, (CfgFileEnd)
                        CpHL(de)
                        jp c, EndOfFile
                        pop de
                        pop hl

                        ld (CfgNextLineStart), hl
                        pop de
                        push de
                        or a
                        sbc hl, de
                        ld (ix+CfgList.LineLen), hl
                        pop hl
                        ret
EndOfFile:
                        ld a, 1
                        ld (IsLastLine), a
                        pop hl                          ; Balance the stack
                        pop hl
                        pop hl
                        ret
SetupNextLine:
                        ld a, [IsLastLine]SMC
                        or a
                        jp z, NotLastLine
                        xor a
                        ld (ix+(CfgList.Size*2)-1), a   ; Clear NextLine pointer
                        ld (ix+(CfgList.Size*2)-2), a   ; on last record of linked list
                        ld de, ix
                        add de, CfgList.Size
                        ld (CfgLastRecord), de          ; Save the last CfgList record
                        ret                             ; Return to the routine that called ParseCfgFile
NotLastLine:            ld de, ix
                        ld bc, de
                        add de, -CfgList.Size           ; Set the NextEntry of the current (old) record
                        ld (ix+CfgList.NextEntry), de   ; to the new record,
                        ld ix, de                       ; set the link list pointer to the new (now current) record,
                        ld (ix+CfgList.PrevEntry), bc   ; Set the PrevEntry to the previous (old) record,
                        ld hl, (CfgNextLineStart)       ; and set hl to the current buffer pointer.
                        jp ParseLine
ExtendFileByOneLine:
                        push af
                        cp EOLStyle.LF
                        jp z, ExtendLF
                        cp EOLStyle.CR
                        jp z, ExtendCR
                        cp EOLStyle.LF
                        jp z, ExtendLFCR
ExtendCRLF:
                        ld hl, (CfgFileLen)
                        inc hl
                        inc hl
                        ld (CfgFileLen), hl
                        ld hl, (CfgFileEnd)
                        inc hl
                        ld (hl), CR
                        inc hl
                        ld (hl), LF
                        ld (CfgFileEnd), hl
                        pop af
                        ret
ExtendLFCR:
                        ld hl, (CfgFileLen)
                        inc hl
                        inc hl
                        ld (CfgFileLen), hl
                        ld hl, (CfgFileEnd)
                        inc hl
                        ld (hl), LF
                        inc hl
                        ld (hl), CR
                        ld (CfgFileEnd), hl
                        pop af
                        ret
ExtendCR:
                        ld hl, (CfgFileLen)
                        inc hl
                        ld (CfgFileLen), hl
                        ld hl, (CfgFileEnd)
                        inc hl
                        ld (hl), CR
                        ld (CfgFileEnd), hl
                        pop af
                        ret
ExtendLF:
                        ld hl, (CfgFileLen)
                        inc hl
                        ld (CfgFileLen), hl
                        ld hl, (CfgFileEnd)
                        inc hl
                        ld (hl), LF
                        ld (CfgFileEnd), hl
                        pop af
                        ret

FileName:               db "NXtel.cfg", 0
pend



CfgFindKey              proc                            ; de = address of key to search for
                        //zeusdatabreakpoint 1, "zeusdisplayaddr(true, 0, de)", $+disp
                        ld (SearchKey), de
                        ld ix, CfgList                  ; First linked list record
RecordLoop:             ld de, [SearchKey]SMC
                        ld a, (ix+CfgList.KeyLen)
                        or (ix+CfgList.KeyLenMSB)
                        jp z, NoKey
                        ld b, a                         ; b = key length
                        ld hl, (ix+CfgList.KeyAddr)     ; hl = address of record key
                        //zeusdatabreakpoint 2, "zeusdisplayaddr(true, 1, hl)", $+disp
KeyLoop:                ld a, (de)
                        ld c, (hl)
                        cp (hl)
                        jp nz, NoKey
                        inc hl
                        inc de
                        dec b
                        jp nz, KeyLoop
Success:
                        ld hl, (ix+CfgList.ValueAddr)   ; Return hl = Value Address
                        ld bc, (ix+CfgList.ValueLen)    ; Return bc = Value Length
                        or a                            ; Return nc = Success
                        ret
NoKey:
                        ld bc, -CfgList.Size
                        add ix, bc
                        push hl
                        ld hl, CfgLastRecord
                        ld bc, ix
                        CpHL(bc)
                        jp c, NotFound
                        pop hl
                        jp RecordLoop
NotFound:
                        pop hl
                        scf
                        ret
pend



LoadSettings            proc
                        FillLDIR(ConnectMenuDisplay, ConnectMenuDisplay.Length, 0)
                        ld a, "1"
                        ld (URLNumber), a
                        xor a
                        ld (CurrentRow), a
ReadURLLoop:
                        FillLDIR(LoadSettings.ValueBuffer, LoadSettings.ValueBufferLen, 0)

                        ld de, KeyBuffer                ; Address of key to search for (URL1..URL7)
                        call CfgFindKey
                        jp c, NoMoreLines               ; If key isn't present then return

                        push hl
                        ld a, [CurrentRow]SMC
                        ld d, a
                        ld e, ConnectMenuDisplay.Size
                        mul
                        ld hl, ConnectMenuDisplay.Table
                        add hl, de
                        pop de
                        ex de, hl
CopyDisplayLoop:
                        ld a, (hl)
                        or a
                        jp z, EndServerLine
                        cp ","
                        jp z, EndDisplayLine
                        ldi
                        ld a, b
                        or c
                        jp nz, CopyDisplayLoop
EndDisplayLine:
                        inc hl                          ; Skip comma after display text
                        dec bc
                        push hl
                        ld a, (CurrentRow)
                        ld d, a
                        ld e, ConnectMenuServer.Size
                        mul
                        ld hl, ConnectMenuServer.Table
                        add hl, de
                        ex de, hl
                        pop hl
CopyServerLoop:
                        ld a, (hl)
                        or a
                        jp z, EndServerLine
                        ldi
                        ld a, b
                        or c
                        jp nz, CopyServerLoop
EndServerLine:
                        ld a, (URLNumber)
                        inc a
                        cp "9"+1
                        jp nc, NoMoreLines
                        ld (URLNumber), a
                        ld a, (CurrentRow)
                        inc a
                        ld (CurrentRow), a
                        jp ReadURLLoop
NoMoreLines:
                        ld a, (CurrentRow)
                        ld (MenuConnect.ItemCount), a
                        ret

ConfigFileName:         db "nxtel.cfg", 0               ; Relative to application
ConfigFileNameLen       equ $-ConfigFileName
KeyBuffer:              db "URL", [URLNumber]"1", 0
KeyBufferLen            equ $-KeyBuffer
Error:
                        push af
                        ld hl, ConfigFileName
                        ld de, esxDOS.FileNameBuffer
                        ld iy, de
                        ld bc, ConfigFileNameLen
                        ldir
                        MMU5(8, false)
                        pop af
                        jp esxDOS.Error2
ValueBuffer:            ds 151
ValueBufferLen          equ $-ValueBuffer-1
FileBuffer:             ds 128
FileBufferLen           equ $-FileBuffer

pend


ConnectMenuDisplay proc Table:
  Size   equ 36
  Count  equ 8
  Length equ Size*Count
  ds Length, 0
pend



ConnectMenuServer proc Table:
  Size   equ 100
  Count  equ 8
  Length equ Size*Count
  ds Length, 0
pend



DefaultCfg proc File:
  import_bin "..\banks\Default.cfg"
  Len equ $-File
pend



Page1End32   equ $-1
Page1End16   equ Page1End32
Page1Size equ Page1End32-Page1Start32+1
if Page1Size<>(Page1End16-Page1Start16+1)
  zeuserror "Page1Size calculation error"
endif
zeusprinthex "Pg1Size = ", Page1Size
org Page1Temp16
disp 0

