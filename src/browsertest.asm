; browsertest.asm

zeusemulate             "Next"
 zoLogicOperatorsHighPri = false
zoSupportStringEscapes  = false
zxAllowFloatingLabels   = false
zoParaSysNotEmulate     = false
zoDebug                 = true
Zeus_PC                 = Start
Zeus_P7FFD              = $10
Zeus_IY                 = $5C3A
Zeus_AltHL              = $5C3A
Zeus_IM                 = 1
Zeus_IE                 = false
optionsize 5
//Cspect optionbool 15, -15, "Cspect", false
//ZEsarUX optionbool 80, -15, "ZEsarUX", false
//ZeusDebug optionbool 155, -15, "Zeus", true
UploadNext optionbool 205, -15, "Next", false
//ULAMonochrome optionbool 665, -15, "ULA", true
//LogESP optionbool 710, -15, "Log", false
//Carousel optionbool 755, -15, "Carousel", false
//NoDivMMC                = ZeusDebug
Cspect                  equ 0
BuildNex                = Cspect or UploadNext

                        org $8000

Start                   proc
                        di
                        im 1
                        ld iy, $5C3A
                        ld sp, Stack
                        Border(7)
                        FillLDIR($4000, $1800, $00)
                        FillLDIR($5800, $0300, $38)
                        NextPaletteRGB8($00, %101 101 10, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($07, %000 000 00, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($08, %111 111 11, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($0F, %000 000 10, PaletteULAb) ; Path text in blue
                        NextPaletteRGB8($10, %101 101 10, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($17, %000 000 00, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($18, %111 111 11, PaletteULAb) ; Swap blacks and whites
                        NextPaletteRGB8($1F, %000 000 10, PaletteULAb) ; "Browser" text in blue
                        NextPaletteRGB8($15, %100 000 10, PaletteULAb) ; Dir highlight in purple
                        NextPaletteRGB8($16, %000 000 10, PaletteULAb) ; File highlight in blue
                        NextPaletteRGB8($0D, %010 010 11, PaletteULAb) ; Darken rainbow flash blue
                        NextPaletteRGB8($0E, %111 110 00, PaletteULAb) ; Darken rainbow flash yellow
                        NextPaletteRGB8($1C, %000 101 00, PaletteULAb) ; Darken rainbow flash green
                        xor a
                        ld (STIMEOUT), a                               ; Turn off screensaver
                        ei

                        PortOut($123B, $00)             ; Hide layer 2 and disable write paging
                        nextreg $15, %0 00 101 1 0      ; Disable sprites, over border, set ULS

                        ld hl, 0
                        ld de, hl
                        CallP3DOS(DOS_SET_1346, 7)

                        ld hl, FileTypes2
                        ld de, BrowserText
                        ld a, $3F
                        CallP3DOS(IDE_BROWSER, 7)

                        //MFBreak()
                        HaltFreeze()

Frz:                    jp Frz

FileTypes:              db 14, "NEX:.nexload |"
FileTypes2:             db $FF
BrowserText:            db "Cursor keys & ENTER, SPACE=exit, EDIT=up  re", Inv, On, " M ", Inv, Off, "ount"
                        db Inv, On, " D ", Inv, Off, "rive m", Inv, On, " K ", Inv, Off, "dir "
                        db Inv, On, " R ", Inv, Off, "ename ", Inv, On, " C ", Inv, Off, "opy "
                        db Inv, On, " E ", Inv, Off, "rase   ", Inv, On, " U ", Inv, Off, "nmount"
                        db TextWidth, 8, At, 21, 0, Inv, On, Bright, On
                        db "Open Download"
                        db Inv, Off, Bright, Off, TextWidth, 5
                        db $FF
DriveBuffer:            ds 18
pend

Border                  macro(Colour)
                        if Colour=0
                          xor a
                        else
                          ld a, Colour
                        endif
                        out ($FE), a
                        if Colour=0
                          xor a
                        else
                          ld a, Colour*8
                        endif
                        ld (23624), a
mend

Freeze                  macro()
Loop:                   Border(2)
                        Border(1)
                        jp Loop
mend

PortOut                 macro(Port, Value)
                        ld bc, Port
                        ld a, Value
                        out (c), a
mend

FillLDIR                macro(SourceAddr, Size, Value)
                        ld a, Value
                        ld hl, SourceAddr
                        ld (hl), a
                        ld de, SourceAddr+1
                        ld bc, Size-1
                        ldir
mend

HaltFreeze              macro()
HaltLoop:
                        halt
                        ld a, [BorderCol]-1
                        inc a
                        and %111
                        ld (BorderCol), a
                        out ($FE), a
                        add a, a
                        add a, a
                        add a, a
                        ld (23624), a
                        jp HaltLoop
mend

MFBreak                 macro()
                        push af                         ; This sequence triggers the Debug menu
                        ld a, r                         ; on the Next Multiface replacement
                        di                              ; when booted into NextZXOS.
                        in a, ($3F)                     ; The MF must have been activated and returned from
                        rst $8                          ; once, in order for this code to trigger a breakpoint.
mend

PaletteULAa             equ %1 000 xx1x ; ULA first palette
PaletteULAb             equ %1 100 xx1x ; ULA secondary palette
M_P3DOS                 equ $94
DOS_SET_1346            equ $013F
IDE_BROWSER             equ $01BA
STIMEOUT                equ $5C81                       ; Screensaver control sysvar
Bright                  equ 19
Inv                     equ 20
At                      equ 22
TextWidth               equ 30
Off                     equ 0
On                      equ 1

CallP3DOS               macro(CallAddress, bank)
                        exx
                        ld de, CallAddress
                        ld c, bank
                        rst 8
                        noflow
                        db M_P3DOS
mend

NextPaletteRGB8         macro(Index, RGB8, Pal)
                        ld de, Index+(RGB8*256)
                        ld a, Pal
                        ld (NextPaletteRGB8Proc.Palette), a
                        call NextPaletteRGB8Proc
mend

NextPaletteRGB8Proc     proc
                        ld bc, $243B                    ; Port to select ZX Next register
                        ld a, $43                       ; (R/W) Register $43 (67) => Palette Control
                        out (c), a
                        ld bc, $253B                    ; Port to access ZX Next register
Palette equ $+1:        ld a, %1 010 xxxx               ; 010 = Sprites first palette
                        out (c), a
                        ld bc, $243B
                        ld a, $40                       ; (R/W) Register $40 (64) => Palette Index
                        out (c), a
                        ld bc, $253B
                        out (c), e
                        ld bc, $243B
                        ld a, $41                       ; (R/W) Register $41 (65) => Palette Value (8 bit colour)
                        out (c), a
                        ld bc, $253B
                        out (c), d
                        ret
pend

org $FFFD
Stack:
                        rst $8
                        noflow
                        db M_P3DOS
                        ret

                        output_sna "..\build\BrowserTest.sna", $FF40, Start

                        if enabled BuildNex
                          zeusprint "Creating NEX file"
                          zeusinvoke "..\build\deployBrowser.bat"
                        endif

                        if enabled UploadNext
                          zeusinvoke "..\build\UploadBrowser.bat"
                        endif
