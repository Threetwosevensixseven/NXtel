; constants.asm

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



; Maths
EVEN                    equ %11111110                   ; and EVEN   ->  a = a / 2
MOD_8                   equ %00000111                   ; and MOD_8  ->  a = a % 8
SMC                     equ 0                           ; Placeholder for SMC in code
Dummy                   equ 0



; Printing
BS                      equ 8
CR                      equ 13
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

