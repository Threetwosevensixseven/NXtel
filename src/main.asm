; main.asm

; NXtel is copyright � 2018-2023 Robin Verhagen-Guest.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see:
; https://github.com/Threetwosevensixseven/NXtel/blob/master/LICENSE
;
; NXtel source code for the Spectrum Next client, server, page manager
; is available at: https://github.com/Threetwosevensixseven/NXtel

zeusemulate             "Next", "RAW"
zoLogicOperatorsHighPri = false
zoSupportStringEscapes  = false
zxAllowFloatingLabels   = true
zoParaSysNotEmulate     = false
zoDebug                 = true
Zeus_PC                 = Start
Stack                   = Start
Zeus_P7FFD              = $10
Zeus_IY                 = SYSVARS
Zeus_AltHL              = SYSVARS
Zeus_IM                 = 1
Zeus_IE                 = false
//bOnlyUse128KSNAVector=true
optionsize 5
Cspect optionbool 15, -15, "Cspect", false
RealESP optionbool 80, -15, "Real ESP", false           ; Launch CSpect with physical ESP in USB adaptor
//ZEsarUX optionbool 80, -15, "ZEsarUX", false
ZeusDebug optionbool 155, -15, "Zeus", false
UploadNext optionbool 205, -15, "Next", false
ULAMonochrome optionbool 665, -15, "ULA", false
LogESP optionbool 710, -15, "Log", false
//Carousel optionbool 755, -15, "Carousel", false
EmulateTime optionbool 755, -15, "Time", false
NoDivMMC                = ZeusDebug
bp alias zeusdatabreakpoint 0, $+disp
dbp alias zeusdatabreakpoint

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
                        exx
                        ex af, af'
                        push af
                        push bc
                        push de
                        push hl
                        push ix
                        push iy
                        ld bc, DivMMC
                        in a, (c)                       ; Read and save divMMC port
                        ld (SavedDivMMC), a
                        ld bc, Sprite_Register_Port
                        in a, (c)                       ; Read and save NextReg port
                        ld (SavedNextReg), a
                        NextRegRead($56)
                        ld (ISR56), a
                        NextRegRead($57)
                        ld (ISR57), a
                        nextreg $56, 6

EnableDisableKBScan:    call ScanKeyboard               ; $CD (call: Enabled) or $21 (ld hl, nnnn: disabled)
                        //call DoFlash
                        nextreg $56, 31
                        nextreg $57, 30
PrintTimeCall:          ld hl, PrintTime
                        nextreg $56, [ISR56]SMC
                        nextreg $57, [ISR57]SMC
                        ld bc, Sprite_Register_Port
                        ld a, [SavedNextReg]SMC
                        out (c), a                      ; Restore NextReg port
                        ld bc, DivMMC
                        ld a, [SavedDivMMC]SMC
                        out (c), a                      ; Restore divMMC port
                        pop iy
                        pop ix
                        pop hl
                        pop de
                        pop bc
                        pop af
                        ex af, af'
                        exx
                        pop hl
                        pop de
                        pop bc
                        pop af
                        ei
                        reti

org $8200
P3DOSCaller             proc
                        di
                        im 1
                        ex af, af'
                        ld l, c

                        NextRegRead($50)
                        ld (Slot0), a
                        nextreg $50, 255

                        NextRegRead($51)
                        ld (Slot1), a
                        nextreg $51, 255

                        NextRegRead($52)
                        ld (Slot2), a
                        nextreg $52, 10

                        NextRegRead($53)
                        ld (Slot3), a
                        nextreg $53, 11

                        NextRegRead($55)
                        ld (Slot5), a
                        nextreg $55, 5

                        NextRegRead($56)
                        ld (Slot6), a
                        nextreg $56, 0

                        NextRegRead($57)
                        ld (Slot7), a
                        nextreg $57, 1

                        ld (StackP), sp
                        ld sp, $A000

                        ld c, l
                        ex af, af'

                        if enabled ZeusDebug
                          nop
                          or a                          ; Clear carry to simulate success
                        else
//DOSFrz:                   jp DOSFrz
                          rst 8
                          noflow
                          db M_P3DOS
                        endif
                        di
                        nextreg $50, [Slot0]SMC
                        nextreg $51, [Slot1]SMC
                        nextreg $52, [Slot2]SMC
                        nextreg $53, [Slot3]SMC
                        nextreg $55, [Slot5]SMC
                        nextreg $56, [Slot6]SMC
                        nextreg $57, [Slot7]SMC
                        ld sp, [StackP]SMC
                        im 2
                        ret
pend

BrowserData             proc
FileTypes:              db $FF
Text:                   db "Cursor keys & ENTER, SPACE=exit, EDIT=up  re", Inv, On, " M ", Inv, Off, "ount"
                        db Inv, On, " D ", Inv, Off, "rive m", Inv, On, " K ", Inv, Off, "dir "
                        db Inv, On, " R ", Inv, Off, "ename ", Inv, On, " C ", Inv, Off, "opy "
                        db Inv, On, " E ", Inv, Off, "rase   ", Inv, On, " U ", Inv, Off, "nmount"
                        db TextWidth, 8, At, 20, 0, Inv, On, Bright, On
                        db "Open Download"
                        db Inv, Off, Bright, Off, TextWidth, 5
                        db $FF
pend

LaunchDot               proc                            ; Part (2). This routine must live at $8000ish
                                                        ; in standard BASIC 16k bank 5.
                        NextRegRead($52)                ; Read and save slot 2
                        ld (Bank52), a
                        NextRegRead($53)                ; Read and save slot 3
                        ld (Bank53), a
                        nextreg $52, 10                 ; Page ULA screen into slot 2
                        nextreg $53, 11                 ; Page BASIC sysvars into slot 3

                        FillLDIR(SCREEN,PIXELS_COUNT,0)
                        FillLDIR(ATTRS_8x8,ATTRS_8x8_COUNT,DimBlackWhiteP)
                        ld iy, SYSVARS                  ; Point to sysvars
                        ld a, 2
                        call 5633                       ; Setup rst 16 printing to upper screen stream
                        ld a, 30:rst 16
                        ld a, 8:rst 16
                        ld a, 29:rst 16
                        ld a, 8:rst 16
                        ld a, At:rst 16
                        xor a:rst 16
                        xor a:rst 16                    ; PRINT AT 0,0

                        ld ix, [Command]SMC             ; Null-terminated dot command line (omitting initial '.')
                        rst 8
                        noflow                          ; Data byte not to be executed: Zeus Data Execution Prevention
                        db esxDOS.M_EXECCMD             ; M_EXECCMD API call to launch the dot command

                        nextreg $52, [Bank52]SMC        ; Restore slot 2
                        nextreg $53, [Bank53]SMC        ; Restore slot 3
                        ret
Guide:                  db "guide NXtel.gde", 0
UartBaud:               db "uart -fi", 0
UartTerm:               db "uart", 0
pend

                        zeusassert zeusver>=74, "Upgrade to Zeus v4.00 (TEST ONLY) or above, available at http://www.desdes.com/products/oldfiles/zeustest.exe"

                        //output_sna "..\build\NXtel.sna", $FF40, Start

OutputNex               macro(FileName)
                        //if enabled Cspect
                        //  output_nex      FileName, $FF40, $6000, "2.0.26"
                        //else
                          output_nex      FileName, $FF40, $C000, "2.0.26", 6
                        //endif
                        output_nex_screen FileName, "..\build\loading-screen3.bmp", false, 0
                        output_nex_data   FileName, "MARKER", 1, 2, dw $1234, 4
mend
                        //if not enabled Cspect
                          mUnmarkBank(5)
                        //endif
                        OutputNex("..\bin\NXtel.nex")
                        OutputNex("..\sd\NXtel.nex")
                        if enabled UploadNext
                          OutputNex("Q:\Mine\NXtel.nex")
                        endif

                        zeusinvoke "..\build\ZXVersion.exe", "", false

                        //nexFile equ "..\bin\NXtel.nex"
                        //output_nex nexFile, $FF40, $C000, "2.0.27", 6
                        //output_nex_screen nexFile, "..\build\loading-screen3.bmp", false, 0
                        //output_nex_data nexFile, "MARKER", 1, 2, dw $1234, 4

                        ; A screen file
                        //sNexScreenFN ="..\scr\ULA.scr"
                        //sNexScreenFN ="..\scr\layer2.bmp"
                        //sNexScreenFN ="..\scr\HiColor.shc"
                        //sNexScreenFN ="..\scr\HiRes.shr"
                        //output_nex_screen sNexFN,"",0,6912,2,3,4;
                        //output_nex_screen sNexFN,sNexScreenFN,true,2
                        ; A palette file
                        //output_nex_palette sNexFN,"",0,256;
                        //zeusinvoke "..\build\UploadNextZ.bat"

                        //if enabled BuildNex
                        //  zeusprint "Creating NEX file"
                        //  zeusinvoke "..\build\deploy.bat"
                        //endif

                        if enabled Cspect
                          if enabled RealESP
                            zeusprint "Running cspect-emulate-esp.bat"
                            zeusinvoke "..\build\cspect-emulate-esp.bat", "", false
                          else
                           zeusprint "Running cspect.bat"
                            zeusinvoke "..\build\cspect.bat", "", false
                          endif
                        endif
                        //if enabled ZEsarUX
                        //  zeusinvoke "..\build\ZEsarUX.bat", "", false
                        //endif

//zeusdatabreakpoint 11, "(addr=$FDC3) || (addr=$4DDC3)", 0, $52400
//zeusdatabreakpoint 4,"([TestData]L:=[TestData]L+1)=0,0", zeuspage(1), $4000

if enabled LogESP
  //zeusmem zeusmmu(2)+$2000-15,"CFG List",CfgList.Size,true,true,false
  //zeusmem CfgList-(7*CfgList.Size),"CFG List",CfgList.Size,true,true,false
  //zeusmem zeusmmu(2),"CFG Buffer",CfgList.Size,true,true,false
  //zeusmem CfgBuffer,"CFG Buffer",CfgList.Size,true,true,false
  //zeusmem ConnectMenuDisplay,"ConnectMenuDisplay",18,true,true,false
  //zeusmem ConnectMenuServer,"ConnectMenuServer",25,true,true,false
  //zeusmem zeusmmu(18),"Layer 2",256,true,false      ; Show layer 2 screen memory
  //zeusmem zeusmmu(32),"ESP Log",24,true,true,false
endif

