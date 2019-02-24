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
  db 0                                                  ; EOF marker just in case
endif                                                   ; will already be planted in memory in the buffer.
PreloadedCfgAddr equ $-1
PreloadedCfgLen equ $-CfgBuffer

org CfgFileStart-CfgList.Size                           ; The CfgList linked list is positioned near
CfgList proc                                            ; the top of 8k bank 2, and grows downwards.
  struct                                                ; The first record is at $DFDF-$DFF0.
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
    SectionEntry        ds 2
  Size send
  //zeusprinthex CfgList,CfgList+CfgList.Size-1, Size
pend

SectionList proc
  struct
    NameAddr            ds 2
    NameLen             ds 2
    Number              ds 2
    Dummy               ds CfgList.Size-10
    NextEntry           ds 2
    Dummy2              ds 2
  Size send
  //zeusprinthex Size
pend
                                                       ;
EOLStyle proc                                           ;
  LF       equ 0                                        ; %00     Constants to
  CR       equ 1                                        ; %01     represent the
  LFCR     equ 2                                        ; %10     four different
  CRLF     equ 3                                        ; %11     EOL styles.
  IsDouble equ %10
pend

org $DFF1                                               ; The Cfg global vars are positioned right at
CfgFileStart:      dw CfgBuffer                         ; the top of 8k bank 2, between $DFF1 and $FFFF.
CfgFileEnd:        dw PreloadedCfgAddr
CfgFileLen:        dw PreloadedCfgLen
CfgNextLineStart:  dw 0
CfgLastRecord:     dw 0
CfgSectionsStart:  dw 0
CfgSectionsNext:   dw 0
CfgLineEndings:    db 0

org $E000
ParseCfgFile            proc
                        ld (BalanceStack), sp
ParseCfgFile2:
                        if not enabled ZeusDebug        ; When running in Zeus, the cfg file contents
                          ld ix, FileName               ; will already be planted in memory in the buffer.
                          call esxDOS.fOpen             ; Otherwise, open cfg file.
                          jp c, CreateDefaultCfgFile
                          ld ix, CfgBuffer              ; ix = address to load into
                          ld (CfgFileStart), ix
                          ld bc, $1C00                  ; bc = number of bytes to read
                          call esxDOS.fRead             ; Read the entire file (or most of it if huge)
                          jp c, LoadSettings.Error      ; into the buffer.
                          ld (hl), 0                    ; Set the EOF byte
                          dec hl
                          ld (CfgFileEnd), hl
                          ld (CfgFileLen), bc
                          call esxDOS.fClose            ; Close the cfg file again,ignoring any errors.
                        endif

                        //zeusdatabreakpoint 0, $+disp

                        ld iy, 0
                        ld hl, 0
                        ld (CfgSectionsStart), hl
                        ld (CfgSectionsNext), hl
                        ld (SectionAdjust), hl
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
                          jp ParseCfgFile2              ; Don't save stack a second time
                        endif
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
                        //zeusdatabreakpoint 1, "iy<>0", $+disp
                        //zeusdatabreakpoint 1, "ix<=$DEF5", $+disp
                        //bp

                        ld (ix+CfgList.LineAddr), hl    ; Set the record start
                        ld a, (hl)
                        or a                            ; Is this the last line?
                        jp z, LastLine
                        cp CR                           ; Is this an empty line?
                        jp z, EmptyLine
                        cp LF
                        jp z, EmptyLine
                        jp NonEmptyLine
EmptyLine:
                        ld bc, 1                        ; Line length is potentially 1 or 2, starting with 1
                        inc hl
                        cp (hl)
                        jp z, SngEOL                    ; If next char is the same then we must have a single char EOL,
                        ld a, (hl)                      ; because there is no CRCR or LFLF style.
                        cp CR
                        jp z, DblEOL
                        cp LF
                        jp z, DblEOL
                        jp SngEOL                       ; If next char isn't CR or LF we also have a single char EOL
DblEOL:                 inc c                           ; For double char EOLs, line length is now 2

SngEOL:
                        dec hl                          ; hl is now back at the start of the line, and bc is length
                        ld (ix+CfgList.LineLen), bc     ; Store line length
                        add hl, bc                      ; Calculate start of next line
                        ld (CfgNextLineStart), hl       ; Store start of next line
                        call SetNoKey                   ; Signal there is no key or value on this line
                        jp SetupNextLine
NonEmptyLine:
                        cp ';'                          ; Is this a comment line?
                        jp z, Comment
                        cp '['
                        jp z, SectionStart

                        //zeusdatabreakpoint 1, "ix<=$DEF5", $+disp
                        //nop

                        push hl
                        call FindNextEOL                ; Not a blank line or comment, so fine the line end.
                        pop hl
                        ld bc, (ix+CfgList.LineLen)
                        ld a, '='
                        cpir                            ; Does the line contain an equals?
                        jp po, NoEquals
Equals:
                        ld bc, iy
                        ld (ix+CfgList.SectionEntry), bc
                        dec hl                          ; We have an equals, so work back to find the end of the key.
                        ld (EqualsAddr), hl             ; Save the equals point so we can find the value later.
                        push hl
                        ld de, (ix+CfgList.LineAddr)
                        or a                            ; Clear carry
                        sbc hl, de
                        ld bc, hl                       ; bc = length back to the start of the line
                        pop hl
KeyLoop1:               dec hl
                        dec bc                          ; Keep track of chars back to the start of the line
                        ld a, (hl)
                        cp ' '
                        jp z, KeyLoop1
                        ld a, b
                        or c
                        ld de, hl                       ; de = the address of the end of the key.
                        jp z, KeyStartOfLine
KeyLoop2:               dec hl                          ; Now work back to find the start of the key.
                        dec bc                          ; Keep track of chars back to the start of the line
                        ld a, b
                        or c
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
                        ld bc, hl
                        dec bc                         ; bc = chars remaining from the char after equals to the EOL
                        ld (AfterEqualsLen), bc         ; and save value for later.
                        ld hl, (EqualsAddr)
ValueLoop1:             inc hl
                        dec bc
                        ld a, b
                        or c
                        jp z, ValueEndOfLine
                        ld a, (hl)
                        cp ' '
                        jp z, ValueLoop1
                        ld (ix+CfgList.ValueAddr), hl   ; Set the start of the value into the record
TrimValueEndSpaces:
                        ld hl, (ix+CfgList.LineAddr)
                        ld de, (ix+CfgList.LineLen)
                        add hl, de
                        dec hl
                        ld bc, [AfterEqualsLen]SMC      ; Restore search length
ValueLoop2:             dec hl
                        dec bc
                        ld a, b
                        or c
                        jp z, ValueEndOfLine
                        ld a, (hl)
                        cp CR
                        jp z, ValueLoop2
                        cp LF
                        jp z, ValueLoop2
                        cp ' '
                        jp z, ValueLoop2
                        ld de, (ix+CfgList.ValueAddr)   ; hl = value end address, de = value start address
                        or a
                        sbc hl, de
                        inc hl                          ; hl = value length
                        ld (ix+CfgList.ValueLen), hl    ; Set the length of the value into the record
ValueEndOfLine:         jp SetupNextLine
NoEquals:                                               ; This line has no equals,
                        ld hl, (ix+CfgList.LineAddr)    ; so restore the line start, and treat like a comment
Comment:
                        call SetNoKey                   ; Setting a zero key length will make parsing ignore comments.
                        call FindNextEOL
                        jp SetupNextLine
SectionStart:
                        //bp
                        //zeusdatabreakpoint 0, $+disp
                        ld (StartOfSecName), hl         ; Save start of key for later
                        call SetNoKey                   ; Setting a zero key length will make parsing ignore sections.
NextSectionChar:        inc hl                          ; Start looking for the end of the line after the [
                        ld a, (hl)
                        cp ']'
                        jp z, EndOfSection
                        or a                            ; Is this the last line?
                        jp z, LastLine
                        cp CR                           ; Is this an empty line?
                        jp z, EndOfSection
                        cp LF
                        jp z, EndOfSection
                        jp NextSectionChar

EndOfSection:           dec hl                          ; Address of the end of the section name
                        ld de, [StartOfSecName]SMC
                        push de
                        or a
                        sbc hl, de
                        ld bc, hl                       ; bc = Length of the section name
                        push ix
                        pop hl
                        add hl, -CfgList.Size
                        push hl
                        ld (ix+CfgList.SectionEntry), hl
                        ld de, iy
                        ld a, d
                        or a
                        pop iy
                        jp z, WasFirstConfig
                        add de, SectionList.NextEntry
                        ld a, iyl
                        ld (de), a
                        inc de
                        ld a, iyh
                        ld (de), a
WasFirstConfig:
                        ld hl, -CfgList.Size
                        ld (SectionAdjust), hl
                        pop hl
                        inc hl
                        ld (iy+SectionList.NameAddr), hl
                        ld (iy+SectionList.NameLen), bc
                        ld a, (CfgSectionsStart)
                        or a
                        jp nz, NotFirstSection
                        ld (CfgSectionsStart), iy
NotFirstSection:        ld (CfgSectionsNext), iy
                        dec hl                          ; Back up one to ensure we find the EOL of the current line
                        call FindNextEOL
                        jp SetupNextLine

                        call FindNextEOL
                        jp SetupNextLine
SetNoKey:
                        xor a
                        ld (ix+CfgList.KeyLen), a
                        ld (ix+CfgList.KeyLenMSB), a
                        ret
FindNextEOL:
                        ld a, (hl)
                        or a                            ; Is this the last line?
                        jp z, LastLine
                        cp CR                           ; Is this an empty line?
                        jp z, FoundEOL1
                        cp LF
                        jp z, FoundEOL1
                        inc hl
                        jp FindNextEOL
FoundEOL1:
                        inc hl
                        cp (hl)
                        jp z, SngEOL2                    ; If next char is the same then we must have a single char EOL,
                        ld a, (hl)                       ; because there is no CRCR or LFLF style.
                        cp CR
                        jp z, DblEOL2
                        cp LF
                        jp z, DblEOL2
                        jp SngEOL2                       ; If next char isn't CR or LF we also have a single char EOL
DblEOL2:                inc hl                           ; For double char EOLs, advance pointer again
SngEOL2:                push hl                          ; hl is now at the start of the next line
                        ld de, (ix+CfgList.LineAddr)
                        or a
                        sbc hl, de
                        ld (ix+CfgList.LineLen), hl
                        pop hl
                        ld (CfgNextLineStart), hl
                        ret
EndOfFilex:
                        //zeusdatabreakpoint 0, $+disp
                        bp
                        ld a, 1
                        //ld (IsLastLine), a
                        pop de
                        pop hl
                        //jp ReturnFromEOF // this no longer exists, uncomment out later

                        //pop hl

                        //ld sp, [BalanceStack]SMC        ; Balance the stack
                        //dec sp
                        //dec sp
                        //pop hl
                        //jp (hl)
                        //ret
SetupNextLine:          ld de, ix
                        ld bc, de
                        add de, -CfgList.Size           ; Set the NextEntry of the current (old) record
                        add de, [SectionAdjust]SMC
                        ld (ix+CfgList.NextEntry), de   ; to the new record,
                        ld ix, de                       ; set the link list pointer to the new (now current) record,
                        ld (ix+CfgList.PrevEntry), bc   ; Set the PrevEntry to the previous (old) record,
                        ld hl, 0
                        ld (SectionAdjust), hl
                        ld hl, (CfgNextLineStart)       ; and set hl to the current buffer pointer.
                        jp ParseLine
LastLine:
                        ld (CfgLastRecord), ix          ; Save the last CfgList record
                        ld sp, [BalanceStack]SMC
                        ret

FileName:               db "NXtel.cfg", 0
pend



CfgFindKey              proc                            ; de = address of key to search for
                        ld (SearchKey), de
                        ld ix, CfgList                  ; First linked list record
RecordLoop:             ld de, [SearchKey]SMC           ; de = address of search key
                        ld a, (ix+CfgList.KeyLen)
                        or (ix+CfgList.KeyLenMSB)
                        jp z, NoKey
                        ld c, a
                        ld b, (ix+CfgList.KeyLenMSB)    ; bc = key length
                        ld hl, (ix+CfgList.KeyAddr)     ; hl = address of record key
KeyLoop:                ld a, (de)
                        cp (hl)
                        jp nz, NoKey
                        inc hl
                        inc de
                        dec bc
                        ld a, b
                        or c
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



SkipEOL                 proc                    ; Skips CR, LF, CRLF or LFCR
                        ret
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

TestData: ds 4


Page1End32   equ $-1
Page1End16   equ Page1End32
Page1Size equ Page1End32-Page1Start32+1
zeusassert !(Page1Size<>(Page1End16-Page1Start16+1)), "Page1Size calculation error"
if enabled ReportBankSizes
  zeusprinthex "Pg1Size = ", Page1Size
endif
org Page1Temp16
disp 0

