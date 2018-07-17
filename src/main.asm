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

                        Turbo(MHz14)
                        Border(Black)
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 001 1 0      ; Disable sprites, over border, set LSU
                        PageBankZX(0, false)            ; Force MMU reset
                        call ClsAttr
                        MMU7(30, false)
                        ei
                        halt
                        di
                        call SetupDataFileSystem
                        call LoadResources
                        di
                        MMU7(30, false)
                        call DefinePalettes
                        call InitLayer2
                        NextRegRead(%00)
                        //cp 10                           ; Next
                        //jp z, IsNext
                        cp 8                            ; Not ZEsarUX
                        jp nz, IsNext
                        ld a, $C9                       ; ret
                        ld (GetTime), a                 ; Disable clock if not Next
IsNext:                 ld a, $CD                       ; call NN
                        ld (PrintTimeCall), a

NextPage:
                        ld a, (Pages.Current)           ; Load next page
                        inc a
                        cp Pages.Count
                        jp c, SavePage
                        xor a
SavePage:               ld (Pages.Current), a
                        ld hl, Pages.Table
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
                        call LoadPage                   ; Bank in a (e.g. 31), Page in b (0..7)
                        call RenderBuffer               ; display page
MainLoop:
                        ei
                        halt
                        ld hl, [PageTimer]SMC
                        inc hl
                        ld (PageTimer), hl
                        ld bc, [PageDuration]SMC
                        CpHL(bc)
                        jp nz, MainLoop
                        ld hl, 0
                        ld (PageTimer), hl
                        jp NextPage

                        include "utilities.asm"         ; Utility routines
                        include "esxDOS.asm"
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
                        include "mmu-pages.asm"

org $BE00
                        loop 257
                          db $BF
                        lend
org $BFBF
                        push af
                        push bc
                        push de
                        push hl
                        call DoFlash
PrintTimeCall:          ld hl, PrintTime
                        pop hl
                        pop de
                        pop bc
                        pop af
                        ei
                        reti

                        if zeusver < 73
                          zeuserror "Upgrade to Zeus v3.991 or above, available at http://www.desdes.com/products/oldfiles/zeus.htm."
                        endif

                        output_sna "..\bin\NexTel.sna", $FF40, Start

                        zeusinvoke "..\build\deploy.bat"

                        if enabled Cspect
                          zeusinvoke "..\build\cspect.bat", "", false
                        endif
                        if enabled ZEsarUX
                          zeusinvoke "..\build\ZEsarUX.bat", "", false
                        endif
                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNext.bat"
                        endif

                        //zeusmem $4CFE8,"Double Height Cap D",16,true,false      ; Show layer 2 screen memory
                        //zeusdatabreakpoint 11, "addr=$EFE8", zeusmmu(18), $2000

