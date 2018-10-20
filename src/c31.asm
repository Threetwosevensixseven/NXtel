; c31.asm

GetEnv:
   ; Search for "name = value" pair in file and return value in val if found.
   ; Must hold exclusive access to environment file while searching it.
   ;
   ; enter : hl = char *name
   ;         de = char *val
   ;         bc = valsz not including space for terminating 0 > 0
   ;
   ;          e'= file handle
   ;         hl'= char *buf
   ;         bc'= bufsz > 0
   ;
   ; exit  : success if valsz == 0
   ;
   ;            hl = length of value string (val not written)
   ;            carry reset
   ;
   ;         success if valsz != 0
   ;
   ;            hl = char *val, zero terminated value written into buffer
   ;            carry reset
   ;
   ;         fail
   ;
   ;            hl = 0
   ;            carry set
   ;
   ; uses  : af, bc, de, hl, bc', de', hl', ix
import_bin "..\getenv\bin\makebin.bin"



LoadSettings31                  proc
                                ld ix, ConfigFileName
                                call esxDOS.fOpen
                                jp c, Error

                                ld a, (esxDOS.Handle)
                                ld e, a                         ; e'= file handle
                                ld hl, FileBuffer               ; hl'= char *buf
                                ld bc, FileBufferLen            ; bc'= bufsz > 0
                                exx
                                ld hl, KeyBuffer                ; hl = char *name
                                ld de, ValueBuffer              ; de = char *val
                                ld bc, ValueBufferLen           ; bc = valsz not including space for terminating 0 > 0
                                call GetEnv
                                jp c, Red
                                jp LoadSettings.Return
Freeze:
                                jp Freeze
Red:
                                Border(Red)
                                jp Freeze
                                jp LoadSettings.Return

ConfigFileName:                 db "NXTEL.CFG", 0               ; Relative to application
ConfigFileNameLen               equ $-ConfigFileName
KeyBuffer:                      db "URL2", 0
KeyBufferLen                    equ $-KeyBuffer
Error:
                                push af
                                ld hl, ConfigFileName
                                ld de, esxDOS.FileNameBuffer
                                ld iy, de
                                ld bc, ConfigFileNameLen
                                ldir
                                MMU5(8, false)
                                pop af
                                jp esxDOS.Error2
ValueBuffer:                    ds 151
ValueBufferLen                  equ $-ValueBuffer-1
FileBuffer:                     ds 128
FileBufferLen                   equ $-FileBuffer

pend


Welcome31                       proc
                                ld hl, Menus.Welcome
                                ld de, DisplayBuffer
                                ld bc, Menus.Size
                                ldir
                                ld hl, Version
                                ld de, DisplayBuffer+667
                                ld bc, 12
                                ldir
                                jp Welcome.Return
Version:                        PadStringLeftSpaces(VersionOnlyValue, 12)
pend


MainMenu31                      proc
                                ld hl, Menus.Main
                                ld de, DisplayBuffer
                                ld bc, Menus.Size
                                ldir
                                jp MainMenu.Return
pend



Menus                           proc
  Welcome:                      import_bin "..\pages\ClientWelcome.bin"
  Main:                         import_bin "..\pages\MainMenu.bin"
  Connect:                      import_bin "..\pages\ConnectMenu.bin"
  Size                          equ 1000
pend

