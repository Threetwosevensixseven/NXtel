; utilities.asm

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
                        ld a, (ResourcesCount)
                        ld e, a
                        ld a, (iy+Resources.Bank)
                        nextreg $57, a
                        ld ix, $E000
                        ld bc, $2000
                        call esxDOS.fRead
                        jp c, Error
                        pop af
                        inc a
                        cp e
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



ClsAttr                 proc
                        ClsAttrFull(DimBlackBlackP)
                        ret
pend



Cls                     proc
                        ld (EXIT+1), sp                 ; Save the stack
                        ld sp, ATTRS_8x8                ; Set stack to end of screen
                        ld de, $0000                    ; All pixels unset
                        ld b, e                         ; Loop 256 times: 12 words * 256 = 6144 bytes
                        noflow
CLS_LOOP:               defs 12, $D5                    ; 12 lots of push de
                        djnz CLS_LOOP
EXIT:                   ld sp, $0000                    ; Restore the stack
                        ret
pend



DoFlash                 proc
                        ld a, [Frame]SMC
                        inc a
                        and 31
                        ld (Frame), a
                        ret nz
                        nextreg $43, %0 001 000 0       ; Set Layer 2 primary palette, incrementing
                        nextreg $40, 64                 ; Start at index 64
                        ld a, [OnOff]SMC+1
                        xor 1
                        ld (OnOff), a
                        jp nz, On
Off:
                        ld e, 0                         ; Black
                        ld d, 9                         ; 8 sets of colour
OffOuter:               dec d
                        ld b, 8
                        ld a, e                         ; Colour index to set (0..7)
                        ld hl, PaletteL2Primary.Table
                        add hl, a
                        ld a, (hl)                      ; Colour to set (RGB8)
OffInner:               nextreg $41, a
                        djnz OffInner
                        inc e
                        ld b, d
                        djnz OffOuter
                        ret
On:
                        ld c, 8
NextSet:                ld b, 8
                        ld hl, PaletteL2Primary
Loop:                   ld a, (hl)
                        inc hl
                        nextreg $41, a
                        djnz Loop
                        dec c
                        ld a, c
                        jp nz, NextSet
                        //call GetTime
                        ret
pend


/*
WaitKey                 proc
                        ei
                        push af
                        xor a
                        in a, ($FE)
                        cpl
                        and 15
                        halt
                        jr nz, WaitKey
Loop:
                        xor a
                        in a, ($FE)
                        cpl
                        and 15
                        halt
                        jr z, Loop
                        pop af
                        di
                        ret
pend
*/

