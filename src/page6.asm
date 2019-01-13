; page6.asm - OS-FRIENDLY CORE CODE

Page6Temp16  equ $
Page6Start32 equ $6000
Page6Start16 equ Page6Start32
org          $6000
dispto zeuspage(6)

Start6:
                        di
                        nextreg $52, 13
                        nextreg $53, 12
                        jp Entry6
Entry6:
                        ld iy, $5C3A
                        ld sp, Stack
                        ld a, $80
                        ld i, a
                        im 2
                        Turbo(MHz14)
                        Contention(false)
                        call SetupBrowserPalette
                        nextreg $52, 10
                        ClsAttrFull(Teletext.Background)
                        nextreg $52, 13
                        EnableKeyboardScan(false)
                        ei
                        halt
Start2:
                        Border(Teletext.Border)
                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 000 1 0      ; Disable sprites, over border, set SLU

                        //DisplayBrowser()

                        ESPLogInit()
                        PageBankZX(0, false)            ; Force MMU reset
                        call ClsAttr
                        MMU7(30, false)
                        ei
                        halt
                        di
                        call SetupDataFileSystem
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

if $ > $7FFF
  zeuserror "Page 6 has overflowed past $7FFF."
endif

Page6End32   equ $-1
Page6End16   equ Page6End32
Page6Size equ Page6End32-Page6Start32+1
if Page6Size<>(Page6End16-Page6Start16+1)
  zeuserror "Page6Size calculation error"
endif
zeusprinthex "Pg6Size = ", Page6Size
org Page6Temp16
disp 0

