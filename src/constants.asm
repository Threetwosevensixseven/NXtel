; constants.asm

; Testing
PrintIPDPacket          equ true

; UART
UART_RxD                equ $143B                       ; Also used to set the baudrate
UART_TxD                equ $133B                       ; Also reads status
UART_SetBaud            equ UART_RxD                    ; Sets baudrate
UART_GetStatus          equ UART_TxD                    ; Reads status bits
UART_mRX_DATA_READY     equ %xxxxx 0 0 1                ; Status bit masks
UART_mTX_BUSY           equ %xxxxx 0 1 0                ; Status bit masks
UART_mRX_FIFO_FULL      equ %xxxxx 1 0 0                ; Status bit masks



; Sprite I/O ports
Sprite_Pattern_Port     equ $5B
Sprite_Sprite_Port      equ $57
Sprite_Register_Port    equ $243B
Sprite_Value_Port       equ $253B
Sprite_Index_Port       equ $303B                       ; Read for the two flags
TurboRegister           equ $07
MHz35                   equ %00
MHz7                    equ %01
MHz14                   equ %10
MHz28                   equ %01
PaletteIndexRegister    equ $40                         ; (R/W) Register $40 (64) => Palette Index
PaletteValueRegister    equ $41                         ; (R/W) Register $41 (65) => Palette Value (8 bit colour)
PaletteControlRegister  equ $43                         ; (R/W) Register $43 (67) => Palette Control
MMUSlot0                equ $50
MMUSlot1                equ $51
MMUSlot2                equ $52
MMUSlot3                equ $53
MMUSlot4                equ $54
MMUSlot5                equ $55
MMUSlot6                equ $56
MMUSlot7                equ $57
Layer2AccessPort        equ $123B
Layer2RAMPageRegister   equ $12
SpriteControlRegister   equ $15
SpriteControlLoRes      equ %1xxxxxxx
SpriteControlSLU        equ %xxx000xx
SpriteControlLSU        equ %xxx001xx
SpriteControlSUL        equ %xxx010xx
SpriteControlLUS        equ %xxx011xx
SpriteControlUSL        equ %xxx100xx
SpriteControlULS        equ %xxx101xx
SpriteControlOverBorder equ %xxxxxx1x
SpriteControlVisible    equ %xxxxxxx1
DMAPort                 equ $6B
L2BasePage              equ 9
PaletteULAa             equ %1 000 xxxx ; ULA first palette
PaletteULAb             equ %1 100 xxxx ; ULA secondary palette
PaletteL2A              equ %1 001 xxxx ; Layer 2 first palette
PaletteL2B              equ %1 101 xxxx ; Layer 2 secondary palette
PaletteSpriteA          equ %1 010 xxxx ; Sprites first palette
PaletteSpriteB          equ %1 110 xxxx ; Sprites secondary palette
PaletteIncManual        equ %1 111 1111 ; AND this with the values above to not autoincrement
PaletteIncAuto          equ %0 111 1111 ; AND this with the values above to autoincrement
PaletteSelSpriteB       equ %0 000 1000 ; OR this with the values above to select Sprite B palette
PaletteSelL2B           equ %0 000 0100 ; OR this with the values above to select Layer2 B palette
PaletteSelULAb          equ %0 000 0010 ; OR this with the values above to select ULA    B palette



; Copper
CopperStop              equ %00
CopperStartNeverReset   equ %01
CopperStartLoop         equ %10
CopperStartReset        equ %11



; Screen
SCREEN                  equ $4000                       ; Start of screen bitmap
ATTRS_8x8               equ $5800                       ; Start of 8x8 attributes
ATTRS_8x8_END           equ $5B00                       ; End of 8x8 attributes
ATTRS_8x8_COUNT         equ ATTRS_8x8_END-ATTRS_8x8     ; 768
SCREEN_LEN              equ ATTRS_8x8_END-SCREEN
PIXELS_COUNT            equ ATTRS_8x8-SCREEN
FRAMES                  equ 23672                       ; Frame counter
BORDCR                  equ 23624                       ; Border colour system variable
ULA_PORT                equ $FE                         ; out (254), a



; Paging and ROM

LD_BYTES                equ $0556
BlockSize               equ $4000
BlockROM                equ $0000+(BlockSize*0)
BlockROMEnd             equ BlockROM+BlockSize-1
BlockScreen             equ $0000+(BlockSize*1)
BlockScreenEnd          equ BlockScreen+BlockSize-1
BlockMiddle             equ $0000+(BlockSize*2)
BlockMiddleEnd          equ BlockMiddle+BlockSize-1
BlockUpper              equ $0000+(BlockSize*3)
BlockUpperEnd           equ BlockUpper+BlockSize-1
SysVars                 equ 23552
SysVarsSize             equ 23733-SysVars+1
John                    equ BlockROM                    ; John was the heart
Yoko                    equ BlockROMEnd
Paul                    equ BlockScreen                 ; Paul was the head
Linda                   equ BlockScreenEnd
George                  equ BlockMiddle                 ; George was the soul
Patty                   equ BlockMiddleEnd
Ringo                   equ BlockUpper                  ; Ringo was the drummer
PeteBest                equ BlockUpperEnd
StuartSutcliffe         equ PeteBest+1
KEYBOARD                equ $02BF
FLAGS                   equ $5C3B
LAST_K                  equ $5C08



; Maths
EVEN                    equ %11111110                   ; and EVEN   ->  a = a / 2
MOD_8                   equ %00000111                   ; and MOD_8  ->  a = a % 8
SMC                     equ 0                           ; Placeholder for SMC in code
Dummy                   equ 0
None                    equ 0



; Teletext
Teletext                proc
  CLS                   equ 12                          ; $0C
  Escape                equ 27                          ; $1B
  Space                 equ 32                          ; $20
  Enter                 equ 95                          ; $5F
  Pipe                  equ 124                         ; $7C
  ThreeQuarters         equ 125                         ; $7D '}'
  Conceal               equ 152                         ; $98
  Reveal                equ 155                         ; $9B
  PipeZ                 equ chr(Pipe)+"Z"
  PipeQ                 equ chr(Pipe)+"Q"
  ClearBit7             equ 0                           ; $00
  SetBit7               equ 128                         ; $80
  TSFrameSize           equ (23*40)                     ; $0398, 920
  Black                 equ 0                           ; $00
  Red                   equ 1                           ; $01
  Green                 equ 2                           ; $02
  Yellow                equ 3                           ; $03
  Blue                  equ 4                           ; $04
  Magenta               equ 5                           ; $05
  Cyan                  equ 6                           ; $06
  White                 equ 7                           ; $07
  Offset0               equ +0
  Offset1               equ -64
  Offset2               equ +64
  Offset3               equ +96
  Offset4               equ +128
  Offset5               equ +160
pend



; Telnet
Telnet proc
  IAC                   equ 255                         ; Marks the start of a negotiation sequence
  WILL                  equ 251                         ; Confirm willingness to negotiate
  WONT                  equ 252                         ; Confirm unwillingness to negotiate
  DO                    equ 253                         ; Indicate willingness to negotiate
  DONT                  equ 254                         ; Indicate unwillingness to negotiate
  Nop                   equ 241                         ; No operation
  SB                    equ 250                         ; The start of sub-negotiation options
  SE                    equ 240                         ; The end of sub-negotiation options
  IS                    equ   0                         ; Sub-negotiation IS command
  Send                  equ   1                         ; Sub-negotiation SEND command
  INFO                  equ   2                         ; Sub-negotiation INFO command
  NEWENVIRON            equ  39                         ; Environment variables
  VAR                   equ   0                         ; NEW-ENVIRON command
  VALUE                 equ   1                         ; NEW-ENVIRON command
  ESC                   equ   2                         ; NEW-ENVIRON command
  USERVAR               equ   3                         ; NEW-ENVIRON command
pend



; BeepFX Sound Effects
SFX proc
  Key_None              equ 0
  Key_CS                equ 1
  Key_SS                equ 2
pend



; ParaSys
BootParaBase            equ $4010
s                       equ Start



; Keyboard
K_BNMSsSp               equ 32766                       ; B, N, M, Symbol Shift, Space
K_HJKLEn                equ 49150                       ; H, J, K, L, Enter
K_YUIOP                 equ 57342                       ; Y, U, I, O, P
K_67890                 equ 61438                       ; 6, 7, 8, 9, 0
K_54321                 equ 63486                       ; 5, 4, 3, 2, 1
K_TREWQ                 equ 64510                       ; T, R, E, W, Q
K_GFDSA                 equ 65022                       ; G, F, D, S, A
K_VCXZCs                equ 65278



; Printing
BS                      equ 8
CR                      equ 13
LF                      equ 10
Ink                     equ 16
Paper                   equ 17
Flash                   equ 18
Dim                     equ %00000000
Bright                  equ %01000000
PrBright                equ 19
Inverse                 equ 20
Over                    equ 21
At                      equ 22
Tab                     equ 23
Black                   equ 0
Blue                    equ 1
Red                     equ 2
Magenta                 equ 3
Green                   equ 4
Cyan                    equ 5
Yellow                  equ 6
White                   equ 7
BlackP                  equ 8*Black
BlueP                   equ 8*Blue
RedP                    equ 8*Red
MagentaP                equ 8*Magenta
GreenP                  equ 8*Green
CyanP                   equ 8*Cyan
YellowP                 equ 8*Yellow
WhiteP                  equ 8*White
DimBlack                equ Black
DimBlue                 equ Blue
DimRed                  equ Red
DimMagenta              equ Magenta
DimGreen                equ Green
DimCyan                 equ Cyan
DimYellow               equ Yellow
DimWhite                equ White
BrightBlack             equ Black+Bright
BrightBlue              equ Blue+Bright
BrightRed               equ Red+Bright
BrightMagenta           equ Magenta+Bright
BrightGreen             equ Green+Bright
BrightCyan              equ Cyan+Bright
BrightYellow            equ Yellow+Bright
BrightWhite             equ White+Bright
DimBlackBlackP          equ DimBlack+BlackP
DimBlueBlackP           equ DimBlue+BlackP
DimRedBlackP            equ DimRed+BlackP
DimMagentaBlackP        equ DimMagenta+BlackP
DimGreenBlackP          equ DimGreen+BlackP
DimCyanBlackP           equ DimCyan+BlackP
DimYellowBlackP         equ DimYellow+BlackP
DimWhiteBlackP          equ DimWhite+BlackP
BrightBlackBlackP       equ BrightBlack+BlackP
BrightBlueBlackP        equ BrightBlue+BlackP
BrightRedBlackP         equ BrightRed+BlackP
BrightMagentaBlackP     equ BrightMagenta+BlackP
BrightGreenBlackP       equ BrightGreen+BlackP
BrightCyanBlackP        equ BrightCyan+BlackP
BrightYellowBlackP      equ BrightYellow+BlackP
BrightWhiteBlackP       equ BrightWhite+BlackP
DimBlackBlueP           equ DimBlack+BlueP
DimBlueBlueP            equ DimBlue+BlueP
DimRedBlueP             equ DimRed+BlueP
DimMagentaBlueP         equ DimMagenta+BlueP
DimGreenBlueP           equ DimGreen+BlueP
DimCyanBlueP            equ DimCyan+BlueP
DimYellowBlueP          equ DimYellow+BlueP
DimWhiteBlueP           equ DimWhite+BlueP
BrightBlackBlueP        equ BrightBlack+BlueP
BrightBlueBlueP         equ BrightBlue+BlueP
BrightRedBlueP          equ BrightRed+BlueP
BrightMagentaBlueP      equ BrightMagenta+BlueP
BrightGreenBlueP        equ BrightGreen+BlueP
BrightCyanBlueP         equ BrightCyan+BlueP
BrightYellowBlueP       equ BrightYellow+BlueP
BrightWhiteBlueP        equ BrightWhite+BlueP
DimBlackRedP            equ DimBlack+RedP
DimBlueRedP             equ DimBlue+RedP
DimRedRedP              equ DimRed+RedP
DimMagentaRedP          equ DimMagenta+RedP
DimGreenRedP            equ DimGreen+RedP
DimCyanRedP             equ DimCyan+RedP
DimYellowRedP           equ DimYellow+RedP
DimWhiteRedP            equ DimWhite+RedP
BrightBlackRedP         equ BrightBlack+RedP
BrightBlueRedP          equ BrightBlue+RedP
BrightRedRedP           equ BrightRed+RedP
BrightMagentaRedP       equ BrightMagenta+RedP
BrightGreenRedP         equ BrightGreen+RedP
BrightCyanRedP          equ BrightCyan+RedP
BrightYellowRedP        equ BrightYellow+RedP
BrightWhiteRedP         equ BrightWhite+RedP
DimBlackMagentaP        equ DimBlack+MagentaP
DimBlueMagentaP         equ DimBlue+MagentaP
DimRedMagentaP          equ DimRed+MagentaP
DimMagentaMagentaP      equ DimMagenta+MagentaP
DimGreenMagentaP        equ DimGreen+MagentaP
DimCyanMagentaP         equ DimCyan+MagentaP
DimYellowMagentaP       equ DimYellow+MagentaP
DimWhiteMagentaP        equ DimWhite+MagentaP
BrightBlackMagentaP     equ BrightBlack+MagentaP
BrightBlueMagentaP      equ BrightBlue+MagentaP
BrightRedMagentaP       equ BrightRed+MagentaP
BrightMagentaMagentaP   equ BrightMagenta+MagentaP
BrightGreenMagentaP     equ BrightGreen+MagentaP
BrightCyanMagentaP      equ BrightCyan+MagentaP
BrightYellowMagentaP    equ BrightYellow+MagentaP
BrightWhiteMagentaP     equ BrightWhite+MagentaP
DimBlackGreenP          equ DimBlack+GreenP
DimBlueGreenP           equ DimBlue+GreenP
DimRedGreenP            equ DimRed+GreenP
DimMagentaGreenP        equ DimMagenta+GreenP
DimGreenGreenP          equ DimGreen+GreenP
DimCyanGreenP           equ DimCyan+GreenP
DimYellowGreenP         equ DimYellow+GreenP
DimWhiteGreenP          equ DimWhite+GreenP
BrightBlackGreenP       equ BrightBlack+GreenP
BrightBlueGreenP        equ BrightBlue+GreenP
BrightRedGreenP         equ BrightRed+GreenP
BrightMagentaGreenP     equ BrightMagenta+GreenP
BrightGreenGreenP       equ BrightGreen+GreenP
BrightCyanGreenP        equ BrightCyan+GreenP
BrightYellowGreenP      equ BrightYellow+GreenP
BrightWhiteGreenP       equ BrightWhite+GreenP
DimBlackCyanP           equ DimBlack+CyanP
DimBlueCyanP            equ DimBlue+CyanP
DimRedCyanP             equ DimRed+CyanP
DimMagentaCyanP         equ DimMagenta+CyanP
DimGreenCyanP           equ DimGreen+CyanP
DimCyanCyanP            equ DimCyan+CyanP
DimYellowCyanP          equ DimYellow+CyanP
DimWhiteCyanP           equ DimWhite+CyanP
BrightBlackCyanP        equ BrightBlack+CyanP
BrightBlueCyanP         equ BrightBlue+CyanP
BrightRedCyanP          equ BrightRed+CyanP
BrightMagentaCyanP      equ BrightMagenta+CyanP
BrightGreenCyanP        equ BrightGreen+CyanP
BrightCyanCyanP         equ BrightCyan+CyanP
BrightYellowCyanP       equ BrightYellow+CyanP
BrightWhiteCyanP        equ BrightWhite+CyanP
DimBlackYellowP         equ DimBlack+YellowP
DimBlueYellowP          equ DimBlue+YellowP
DimRedYellowP           equ DimRed+YellowP
DimMagentaYellowP       equ DimMagenta+YellowP
DimGreenYellowP         equ DimGreen+YellowP
DimCyanYellowP          equ DimCyan+YellowP
DimYellowYellowP        equ DimYellow+YellowP
DimWhiteYellowP         equ DimWhite+YellowP
BrightBlackYellowP      equ BrightBlack+YellowP
BrightBlueYellowP       equ BrightBlue+YellowP
BrightRedYellowP        equ BrightRed+YellowP
BrightMagentaYellowP    equ BrightMagenta+YellowP
BrightGreenYellowP      equ BrightGreen+YellowP
BrightCyanYellowP       equ BrightCyan+YellowP
BrightYellowYellowP     equ BrightYellow+YellowP
BrightWhiteYellowP      equ BrightWhite+YellowP
DimBlackWhiteP          equ DimBlack+WhiteP
DimBlueWhiteP           equ DimBlue+WhiteP
DimRedWhiteP            equ DimRed+WhiteP
DimMagentaWhiteP        equ DimMagenta+WhiteP
DimGreenWhiteP          equ DimGreen+WhiteP
DimCyanWhiteP           equ DimCyan+WhiteP
DimYellowWhiteP         equ DimYellow+WhiteP
DimWhiteWhiteP          equ DimWhite+WhiteP
BrightBlackWhiteP       equ BrightBlack+WhiteP
BrightBlueWhiteP        equ BrightBlue+WhiteP
BrightRedWhiteP         equ BrightRed+WhiteP
BrightMagentaWhiteP     equ BrightMagenta+WhiteP
BrightGreenWhiteP       equ BrightGreen+WhiteP
BrightCyanWhiteP        equ BrightCyan+WhiteP
BrightYellowWhiteP      equ BrightYellow+WhiteP
BrightWhiteWhiteP       equ BrightWhite+WhiteP



; Font
FWSpace                 equ 2
FWColon                 equ 4
FWFullStop              equ 3
FW0                     equ 4
FW1                     equ 4
FW2                     equ 4
FW3                     equ 4
FW4                     equ 4
FW5                     equ 4
FW6                     equ 4
FW7                     equ 4
FW8                     equ 4
FW9                     equ 4
FWA                     equ 4
FWB                     equ 4
FWC                     equ 4
FWD                     equ 4
FWE                     equ 4
FWF                     equ 4
FWG                     equ 4
FWH                     equ 4
FWI                     equ 4
FWJ                     equ 4
FWK                     equ 4
FWL                     equ 4
FWM                     equ 6
FWN                     equ 4
FWO                     equ 4
FWP                     equ 4
FWQ                     equ 4
FWR                     equ 4
FWS                     equ 4
FWT                     equ 4
FWU                     equ 4
FWV                     equ 4
FWW                     equ 6
FWX                     equ 4
FWY                     equ 4
FWZ                     equ 4
FWa                     equ 4
FWb                     equ 4
FWc                     equ 4
FWd                     equ 4
FWe                     equ 4
FWf                     equ 4
FWg                     equ 4
FWh                     equ 4
FWi                     equ 4
FWj                     equ 4
FWk                     equ 4
FWl                     equ 4
FWm                     equ 6
FWn                     equ 4
FWo                     equ 4
FWp                     equ 4
FWq                     equ 4
FWr                     equ 4
FWs                     equ 4
FWt                     equ 4
FWu                     equ 4
FWv                     equ 4
FWw                     equ 6
FWx                     equ 4
FWy                     equ 4
FWz                     equ 4

