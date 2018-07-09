; main.asm

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
NoDivMMC                = ZeusDebug

                        org $6000
Start:
                        di
                        ld iy, $5C3A
                        ld sp, Stack
                        ld a, $BE
                        ld i, a
                        im 2

Loooop:
                        Turbo(MHz14)
                        Border(Black)
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 001 1 0      ; Disable sprites, over border, set LSU
                        PageBankZX(0, false)            ; Force MMU reset
                        call ClsAttr
                        call SetupDataFileSystem
                        call LoadResources
                        di

                        MMU7(30, false)
                        call ClsLayer2
                        call DefinePalettes
                        call RenderBuffer

                        nextreg $14, $E3                ; Global L2 transparency colour
                        nextreg $4B, $E3                ; Global sprite transparency index
                        nextreg $4A, $00                ; Transparency fallback colour (black)
                        nextreg $12, 9                  ; Set Layer 2 to bank 18
                        PortOut($123B, $02)             ; Show layer 2 and disable write paging
                        //nextreg $15, %0 00 000 1 1      ; Enable sprites, over border, set SLU
Freeze:
                        ei
                        halt
                        jp Freeze

                        include "utilities.asm"         ; Utility routines
                        include "esxDOS.asm"
FZX_ORG:                include "FZXdriver.asm"
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
                        include "mmu-pages.asm"

org $BE00
                        loop 257
                          db $BF
                        lend
org $BFBF
                        ei
                        reti

                        if zeusver < 73
                          zeuserror "Upgrade to Zeus v3.991 or above, available at http://www.desdes.com/products/oldfiles/zeus.htm."
                        endif

                        output_sna "..\bin\nex-tel.sna", $FF40, Start

                        zeusinvoke "..\build\deploy.bat"

                        if enabled Cspect
                          zeusinvoke "..\build\cspect.bat"
                        endif
                        if enabled ZEsarUX
                          zeusinvoke "..\build\ZEsarUX.bat"
                        endif
                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNext.bat"
                        endif

