; utilities.asm


Resources proc Table:

  ; Bank  FName  Index  Notes
  db  30,    30  ;   0  Layer 2 Teletext renderer

  struct
    Bank        ds 1
    FName       ds 1
  Size send

  Len           equ $-Table
  Count         equ Len/Size
  ROM           equ 255

  output_bin "..\build\BankList.bin", Table, Len
pend



LoadResources           proc

                        //xor a                           ; SNX extended snapshot leaves file handle 0 open
                        //ld (esxDOS.Handle), a

                        ld ix, FileName
                        call esxDOS.fOpen
                        jp c, Error

                        ld bc, $0002
                        ld de, $2000                    ; bcde = $22000 = 139264 = first bank
                        ld ixl, esxDOS.esx_seek_set
                        ld l, esxDOS.esx_seek_set
                        call esxDOS.fSeek
                        jp c, Error
                        xor a
                        push af
                        ld iy, Resources.Table
NextBank:
                        ld a, (iy+Resources.Bank)
                        nextreg $57, a
                        ld ix, $E000
                        ld bc, $2000
                        call esxDOS.fRead
                        jp c, Error
                        pop af
                        inc a
                        cp Resources.Count
                        jp z, Finish
                        push af
                        inc iy
                        inc iy
                        jp NextBank

Finish:
                        call esxDOS.fClose
                        jp c, Error
                        ret
Error:
                        di
                        MMU5(8, false)
                        ld iy, FileName
                        jp esxDOSerror
FileName:
  db "nex-tel.sna", 0
pend



SetupDataFileSystem     proc
                        call esxDOS.GetSetDrive
                        jp c, LoadResources.Error
                        ld (esxDOS.DefaultDrive), a
                        ret
pend



esxDOSerror             proc
                        nextreg $02, 1
                        ei
                        halt
Freeze:                 jp Freeze
pend

