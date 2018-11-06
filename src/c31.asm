; c31.asm - Old Cfg Reading code (deprecated)

// This gets mapped in at $C000-$DFFF

Welcome31               proc
                        ld hl, Menus.Welcome
                        ld de, DisplayBuffer
                        ld bc, Menus.Size
                        ldir
                        ld hl, Version
                        ld de, DisplayBuffer+667
                        ld bc, 12
                        ldir
                        jp Welcome.Return
Version:                PadStringLeftSpaces(VersionOnlyValue, 12)
pend

//zeusprinthex Welcome31, MainMenu31, Menus.Welcome, Menus.Main, DisplayBuffer

MainMenu31              proc
                        Border(Black)
                        ld hl, Menus.Main
                        ld de, DisplayBuffer
                        ld bc, Menus.Size
                        ldir
                        jp MainMenu.Return
pend



Menus                   proc
  Welcome:              import_bin "..\pages\ClientWelcome.bin"
  Main:                 import_bin "..\pages\MainMenu.bin"
  Connect:              import_bin "..\pages\ConnectMenu.bin"
  Size                   equ 1000
pend

