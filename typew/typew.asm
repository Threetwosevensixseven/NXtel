;     Tech demo using a new keyboard handler to improve typing experience
;     (C)2018 Miguel Angel Rodriguez Jodar. ZX Projects. ZX-UNO Team.
;
;     This program is free software: you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation, either version 3 of the License, or
;     (at your option) any later version.
;
;     This program is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.
;
;     You should have received a copy of the GNU General Public License
;     along with this program.  If not, see <http://www.gnu.org/licenses/>.

KEYBUFFER                  equ 5b00h  ;printer buffer for keyboard buffer

                           org 0e0ffh
                           dw NewIM2

Main                       di
                           ld a,0e0h
                           ld i,a
                           xor a
                           ld (PointerRead),a
                           ld (PointerWrite),a
                           ld a,(23560)
                           ld (KeyAnt),a
                           ld a,6
                           out (254),a
                           ei

                           call 0d6bh  ;CLS
                           ld a,2
                           call 1601h  ;CHAN-OPEN
                           
                           ld hl,Welcome
LoopWel                    ld a,(hl)
                           or a
                           jp z,LoopTypewriter
                           rst 10h
                           inc hl
                           jp LoopWel

LoopTypewriter             ld a,143
                           rst 10h
                           ld a,8
                           rst 10h
Again                      call WaitKey
                           cp 13
                           jr nz,NoEnter
                           ld a,32
                           rst 10h
                           ld a,13
                           rst 10h
                           jp LoopTypewriter
NoEnter                    cp 11
                           jr nz,NoCambia
                           ld a,(ChangeRoutine)
                           cpl
                           ld (ChangeRoutine),a
                           and 7
                           xor 110b
                           out (254),a
                           cp 110b
                           jr nz,NuevaRut
                           call WaitNoKey
                           im 1
                           jp Again
NuevaRut                   call WaitNoKey
                           im 2
                           jp Again
NoCambia                   cp 32
                           jp c,Again

                           rst 10h
                           jp LoopTypewriter

WaitNoKey                  di
                           ld bc,00feh
LoopWaitNoKey              in a,(c)
                           and 31
                           cp 31
                           jp nz,LoopWaitNoKey
                           ei
                           ret

WaitKey                    ld a,(ChangeRoutine)
                           or a
                           jp z,WaitKeyROM
                           jp nz,WaitKeyCustom

WaitKeyROM                 ld bc,00feh
                           in a,(c)
                           and 31
                           cp 31
                           jr nz,KeyPressed
                           xor a
                           ld (23560),a
KeyPressed                 ld a,(23560)
                           ld b,a
                           ld a,(KeyAnt)
                           cp b
                           jp z,WaitKeyROM
                           ld a,b
                           ld (KeyAnt),a
                           or a
                           jp z,WaitKeyROM
                           ret
KeyAnt                     db 0

WaitKeyCustom              ld a,(PointerRead)
                           ld l,a
                           ld a,(PointerWrite)
                           cp l
                           jr z,WaitKey
                           di
                           ld h,HIGH(KEYBUFFER)
                           ld b,(hl)
                           inc l
                           ld a,l
                           ld (PointerRead),a
                           ei
                           ld a,b
                           ret

NewIM2                     push af
                           push bc
                           push de
                           push hl
                           push ix

                           ld bc,0fefeh
                           ld ix,Matrix
ScanKeyb                   ld a,b
                           inc a
                           jr z,EndScan

                           ld a,(ix+0)
                           ld (ix+8),a
                           in a,(c)
                           cpl
                           and 1fh
                           ld (ix+0),a
                           inc ix
                           scf
                           rl b
                           jp ScanKeyb

EndScan                    ld hl,NormalKeyMap
                           ld ix,Matrix
                           bit 0,(ix+0)
                           jr z,NoCaps
                           ld hl,CapsKeyMap
NoCaps                     bit 1,(ix+7)
                           jr z,NoSymb
                           ld hl,SymbKeyMap

NoSymb                     ld b,8
ScanColumns                push bc
                           ld a,(ix+0)
                           xor (ix+8)
                           and (ix+0)
                           ld b,5
ScanBit                    bit 0,a
                           call nz,InsertQueue
                           inc hl
                           sra a
                           djnz ScanBit
                           inc ix
                           pop bc
                           djnz ScanColumns

                           pop ix
                           pop hl
                           pop de
                           pop bc
                           pop af
                           ei
                           ret

InsertQueue                push af
                           push hl
                           ld a,(PointerWrite)
                           ld e,a
                           ld d,HIGH(KEYBUFFER)
                           ld a,(hl)
                           or a
                           jr z,NoQueue
                           ld (de),a
                           inc e
                           ld a,e
                           ld (PointerWrite),a
NoQueue                    pop hl
                           pop af
                           ret

NormalKeyMap               db 0,"zxcv","asdfg","qwert","12345","09876","poiuy",13,"lkjh",32,0,"mnb"
CapsKeyMap                 db 0,"ZXCV","ASDFG","QWERT",7,6,4,5,8,12,15,9,11,10,"POIUY",13,"LKJH",32,0,"MNB"
SymbKeyMap                 db 0,":",96,"?/","~|",97,"{}","<",0,"><>","!@#$%","_)('&",34,";",0,"][",13,"=+-^",32,0,".,*"
                           ;   01234567890123456789012345678901
Welcome                    db "Keyboard handler test.",13
                           db 127," 2018 mcleod_ideafix",13
                           db "Use UP ARROW to change handler",13,13,0

PointerRead                db 0
PointerWrite               db 0
ChangeRoutine              db 0

Matrix                     ds 16

                           end Main

