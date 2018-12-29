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
ZEsarUX optionbool 80, -15, "ZEsarUX", false
ZeusDebug optionbool 155, -15, "Zeus", true
UploadNext optionbool 205, -15, "Next", false
ULAMonochrome optionbool 665, -15, "ULA", true
LogESP optionbool 710, -15, "Log", false
//Carousel optionbool 755, -15, "Carousel", false
NoDivMMC                = ZeusDebug



                        org $6000
Start:
                        di
                        ld iy, $5C3A
                        ld sp, Stack
                        ld a, $80
                        ld i, a
                        im 1
                        Turbo(MHz14)
                        Contention(false)
                        Border(Black)
                        ClsAttrFull(DimBlackBlackP)
                        EnableKeyboardScan(false)
                        ei
                        halt
Start2:
                        Border(Black)
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 000 1 0      ; Disable sprites, over border, set SLU
                        ESPLogInit()
                        PageBankZX(0, false)            ; Force MMU reset
                        call ClsAttr
                        MMU7(30, false)
                        ei
                        halt
                        di
                        call SetupDataFileSystem
                        //call LoadResources
                        call SetupSprites
                        di
                        MMU7(30, false)
                        call DefinePalettes
                        call InitLayer2
                        NextRegRead(%00)
                        cp 10                           ; Next and CSpect 1.14.1 has clock
                        jp z, IsNext
                        cp 8                            ; ZEsarUX and Zeus doesn't yet
                        jp nz, IsNext
                        ld a, $C9                       ; ret
                        ld (GetTime), a                 ; Disable clock
IsNext:                 ld a, $CD                       ; call NN
                        ld (PrintTimeCall), a
                        ld hl, Resources.Table          ; Calculate Pages.Table address dynamically
                        ld a, (ResourcesCount)
                        add a, a
                        add hl, a
                        ld (PagesTable), hl             ; Store Pages.Table address
                        call Welcome
                        MMU6(2, false)
                        MMU7(3, false)
                        call ParseCfgFile
                        call LoadSettings
                        jp MainMenu
RunCarousel:
                        MMU6(0, false)
                        MMU7(1, false)
                        ld hl, Resources.Table          ; Calculate Pages.Table address dynamically
                        ld a, (ResourcesCount)
                        add a, a
                        add hl, a
                        ld (PagesTable), hl             ; Store Pages.Table address
NextPage:
                        MMU6(0, false)
                        MMU7(1, false)
                        ld a, (PagesCount)
                        ld e, a
                        ld a, (PagesCurrent)            ; Load next page
                        inc a
                        cp e
                        jp c, SavePage
                        xor a
SavePage:               ld (PagesCurrent), a
                        ld hl, [PagesTable]SMC
                        add a, a
                        add a, a
                        add hl, a
                        ld a, (hl)
                        ex af, af'
                        inc hl
                        ld b, (hl)
                        inc hl
                        ld e, (hl)
                        inc hl
                        ld d, (hl)
                        ld a, d
                        and %1000 0000
                        ld (GetTime.ShowClock), a
                        ld a, d
                        and %0111 1111
                        ld d, a
                        ex de, hl
                        ld (PageDuration), hl
                        ex af, af'
                        MMU7(30, false)
                        call LoadPage                   ; Bank in a (e.g. 31), Page in b (0..7)
                        call RenderBuffer               ; display page
                        FlipScreen()
MainLoop:
                        ei
                        halt
                        ld bc, zeuskeyaddr("[shift]")
                        in a, (c)
                        and zeuskeymask("[shift]")
                        jp nz, NoCarouselBreak
                        ld b, high zeuskeyaddr("[space]")
                        in a, (c)
                        and zeuskeymask("[space]")
                        jp z, MainMenu
NoCarouselBreak:
                        call DoFlash
                        MMU7(30, true)
PrintTimeCall:          ld hl, PrintTime

                        ld hl, [PageTimer]SMC
                        inc hl
                        ld (PageTimer), hl
                        ld bc, [PageDuration]SMC
                        CpHL(bc)
                        jp nz, MainLoop
                        ld hl, 0
                        ld (PageTimer), hl
                        jp NextPage
PagesCurrent:           db -1

                        include "utilities.asm"         ; Utility routines
                        include "esxDOS.asm"
                        //include "espat.asm"
                        include "esp.asm"
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
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

                        output_sna "..\bin\NXtel.sna", $FF40, Start

                        zeusinvoke "..\build\deploynex.bat"

                        if enabled Cspect
                          zeusinvoke "..\build\cspectNex.bat", "", false
                        endif
                        if enabled ZEsarUX
                          zeusinvoke "..\build\ZEsarUX.bat", "", false
                        endif
                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNext.bat"
                        endif

                        //zeusmem zeusmmu(18),"Layer 2",256,true,false      ; Show layer 2 screen memory
                        //zeusdatabreakpoint 3, "pc<$4000", 0, zeusmmu(33)
                        if enabled LogESP
                          //zeusmem zeusmmu(32),"ESP Log",24,true,true,false
                        endif

