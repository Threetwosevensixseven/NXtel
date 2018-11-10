; NXkey.asm

zeusemulate             "Next"
zoLogicOperatorsHighPri = false
zoSupportStringEscapes  = false
zxAllowFloatingLabels   = false
zoParaSysNotEmulate     = false
Zeus_PC                 = Start
Stack                   equ Start
Zeus_P7FFD              = $10
Zeus_IY                 = $5C3A
Zeus_AltHL              = $5C3A
Zeus_IM                 = 1
Zeus_IE                 = false
optionsize 5
Cspect optionbool 15, -15, "Cspect", false
ZEsarUX optionbool 80, -15, "ZEsarUX", false
ZeusDebug optionbool 155, -15, "Zeus", true
UploadNext optionbool 205, -15, "Next", false
ULAMonochrome optionbool 665, -15, "ULA", true
//Carousel optionbool 710, -15, "Carousel", false
NoDivMMC                = ZeusDebug

                        org $6000
Start:
                        di
                        ld iy, $5C3A
                        ld sp, Stack
                        ld a, $80
                        ld i, a
                        im 2
                        Turbo(MHz14)
                        Contention(false)
                        Border(Black)
                        ClsAttrFull(DimBlackBlackP)
Start2:
                        Border(Black)
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 001 1 0      ; Disable sprites, over border, set LSU
                        nextreg $56, 6
                        call InitKey
                        ULAPrintSetup(BrightWhiteBlackP)
                        PageBankZX(0, false)            ; Force MMU reset
                        call ClsAttr
                        ei
MainLoop:
                        halt
                        di
                        nextreg $56, 6
                        ei
                        ld hl, (KeyBuffer.CharsAvailable)
                        ld a, h
                        or l
                        jp z, MainLoop
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
                        rst 16
                        ld a, 255
                        ld(23692), a                    ; Turn off ULA scroll
                        jp MainLoop

                        include "nxkeyutils.asm"         ; Utility routines
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
                        include "page3.asm"             ; 16K page 3

org $8000
                        ds 257, $81
org $8181
                        push af
                        push bc
                        push de
                        push hl
                        NextRegRead($56)
                        push af
                        nextreg $56, 6
                        call ReadKey
                        //call DoFlash
//PrintTimeCallX:       //ld hl, PrintTime

                        pop af
                        nextreg $56, a
                        pop hl
                        pop de
                        pop bc
                        pop af
                        ei
                        reti

                        if zeusver < 73
                          zeuserror "Upgrade to Zeus v3.991 or above, available at http://www.desdes.com/products/oldfiles/zeus.htm."
                        endif

                        output_sna "..\bin\NXkey.sna", $FF40, Start

                        zeusinvoke "..\build\deployNXkey.bat"

                        if enabled Cspect
                          zeusinvoke "..\build\cspectNXkey.bat", "", false
                        endif
                        if enabled ZEsarUX
                          //zeusinvoke "..\build\ZEsarUX.bat", "", false
                        endif
                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNext.bat"
                        endif

