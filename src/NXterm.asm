; NXterm.asm

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
                        ld a, $BE
                        ld i, a
                        im 2
                        ei
                        Turbo(MHz14)
                        Border(Black)
                        ClsAttrFull(BrightWhiteBlackP)
                        ULAPrintSetup(BrightWhiteBlackP)
                        ESPSend("ATE0")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPCLOSE")
                        call ESPReceiveWaitOK
                        ESPSend("AT+CIPMUX=0")
                        call ESPReceiveWaitOK
                        //ESPSend("AT+CIPSTART=""TCP"",""192.168.1.3"",23280,7200")
                        ESPSend("AT+CIPSTART=""TCP"",""nx.nxtel.org"",23280,7200")
                        //ESPSend("AT+CIPSTART=""TCP"",""IRATA.ONLINE"",8005,7200")
                        /*call ESPReceiveWaitOK
                        ESPSend("AT+CIPSEND=1")
                        call ESPReceiveWaitOK
                        Border(Blue)
                        Pause(100)
                        Border(White)
                        ESPSend("_")*/
                        call ESPReceiveIPDInit
MainLoop:
                        call ESPReceiveIPD
                        //jp z, Received
                        //jp c, Error
                        jp MainLoop
Received:               Border(Green)
                        jp Received
Error:                  Border(Red)
                        jp Error

                        include "nxtermutils.asm"
                        include "constants.asm"         ; Global constants
                        include "macros.asm"            ; Zeus macros
                        include "ParaBootStub.asm"      ; Parasys remote debugger slave stub
                        include "esp.asm"

org $BE00
                        ds 257, $BF
org $BFBF
                        ei
                        reti

                        if zeusver < 73
                          zeuserror "Upgrade to Zeus v3.991 or above, available at http://www.desdes.com/products/oldfiles/zeus.htm."
                        endif

                        output_sna "..\bin\NXterm.sna", $FF40, Start

                        if enabled UploadNext
                          zeusinvoke "..\build\UploadNXterm.bat"
                        endif

