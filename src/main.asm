; main.asm

zeusemulate             "Next"
 zoLogicOperatorsHighPri = false
zoSupportStringEscapes  = false
zxAllowFloatingLabels   = false
zoParaSysNotEmulate     = false
zoDebug                 = true
Zeus_PC                 = Start
Stack                   equ Start
Zeus_P7FFD              = $10
Zeus_IY                 = $5C3A
Zeus_AltHL              = $5C3A
Zeus_IM                 = 1
Zeus_IE                 = false
optionsize 5
Cspect optionbool 15, -15, "Cspect", false
//ZEsarUX optionbool 80, -15, "ZEsarUX", false
ZeusDebug optionbool 155, -15, "Zeus", true
UploadNext optionbool 205, -15, "Next", false
ULAMonochrome optionbool 665, -15, "ULA", true
LogESP optionbool 710, -15, "Log", false
//Carousel optionbool 755, -15, "Carousel", false
NoDivMMC                = ZeusDebug
BuildNex                = Cspect or UploadNext



                        org $6000
Start:
                        di
                        nextreg $52, 13
                        nextreg $53, 12
                        jp Entry6
Entry6:
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
                        include "page6.asm"             ; 16K page 6
                        include "page0.asm"             ; 16K page 0
                        include "page1.asm"             ; 16K page 1
                        include "page3.asm"             ; 16K page 3
                        include "page4.asm"             ; 16K page 4
                        include "mmu-pages.asm"         ; 8k banks

org $8000
                        loop 257
                          db $81
                        lend
org $8181
                        push af
                        push bc
                        push de
                        push hl
                        NextRegRead($56)
                        push af
                        nextreg $56, 6
EnableDisableKBScan:    call ScanKeyboard               ; $CD (call: Enabled) or $21 (ld hl, nnnn: disabled)
                        call DoFlash
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

                        output_sna "..\build\NXtel.sna", $FF40, Start

                        if enabled BuildNex
                          zeusprint "Creating NEX file"
                          zeusinvoke "..\build\deploy.bat"
                        endif

                        if enabled Cspect
                          zeusinvoke "..\build\cspect.bat", "", false
                        endif
                        //if enabled ZEsarUX
                        //  zeusinvoke "..\build\ZEsarUX.bat", "", false
                        //endif
                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNext.bat"
                        endif

                        //zeusmem zeusmmu(18),"Layer 2",256,true,false      ; Show layer 2 screen memory
                        //zeusdatabreakpoint 3, "pc<$4000", 0, zeusmmu(33)
                        if enabled LogESP
                          //zeusmem zeusmmu(32),"ESP Log",24,true,true,false
                        endif

