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

                                jp LoadSettings.Return

ConfigFileName:                 db "NXTEL.CFG", 0               ; Relative to application
ConfigFileNameLen               equ $-ConfigFileName
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
pend

