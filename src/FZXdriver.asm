; -----------------------------------------------------------------------------
; FZX driver - Copyright (c) 2013 Einar Saukas
; FZX format - Copyright (c) 2013 Andrew Owen
; -----------------------------------------------------------------------------
IF !DEF FZX_ORG
        ORG     65000           ; driver address
ENDIF

IF !DEF FONT
  FONT  EQU     60000           ; font address
ENDIF

IF !DEF FZX_DISP
  FZX_DISP EQU 0
ENDIF

MARGIN  EQU     0               ; left margin (in pixels)

STR_NUM EQU     4               ; stream #4

IF DEF FZX_CHANNEL_ENABLE
; -----------------------------------------------------------------------------
; ENTRY POINT #1 - CREATE CHANNEL AND ATTACH STREAM
; -----------------------------------------------------------------------------
FZX_DRIVER PROC
        push hl
        ld hl, $AA55
        ld (fl), hl
        pop hl
        ld      hl, ($5c53)     ; store system variable PROG in HL
        dec     hl
        ld      bc, 5           ; allocate 5 bytes for channel below BASIC area
        push    bc
        call    $1655           ; call routine MAKE-ROOM
        pop     bc
        ld      hl, CH_DATA + 4
        lddr                    ; copy CH_DATA to new channel space
        ld      hl, ($5c4f)     ; store system variable CHANS in HL
        ex      de, hl
        inc     hl
        inc     hl              ; now HL = allocated address + 1
        sbc     hl, de          ; calculate offset between start of channels
                                ;   area and start of the new channel space
                                ;   (notice the carry flag was already cleared
                                ;   from executing CALL $1655 earlier)
        ld      (STR_OFF), hl   ; attach stream by storing channel address
                                ;   offset in streams table
        ret

STR_OFF EQU $5c10+((STR_NUM+3)*2) ; address of channel offset in streams table

CH_DATA:
        defw    FZX_START       ; address of the PRINT # routine
        defw    $15c4           ; address of the INPUT # routine
        defb    'S'             ; channel type 'S'
ENDP
ENDIF

; -----------------------------------------------------------------------------
; ENTRY POINT #2 - PROPORTIONAL PRINT ROUTINE
; -----------------------------------------------------------------------------
FZX_START proc
/*        ld l, a
        ld a, (TitleTeleportStub.FrameCounter)
        cp $B2
        ld a, l
        jp nz, Continue
        ret
Continue:
*/

        //zeusdatabreakpoint 1, "zeusprinthex(1, hl)", $+Page4Disp32
        //nop

        ld      hl, P_FLAG      ; initial address of local variables
        dec     (hl)            ; check P_FLAG value by decrementing it
        jp      m, CHK_AT       ; expecting a regular character?
        jr      z, GET_COL      ; expecting the AT column?
GET_LIN:
        cpl
        add     a, 192          ; now A = 191 - char
        inc     hl
GET_COL:
        inc     hl
        ld      (hl), a
        ret
CHK_AT:
        cp      22              ; specified keyword 'AT'?
        jr      nz, CHK_CR
        ld      (hl), 2         ; change P_FLAG to expect line value next time
        ret
CHK_CR:
        inc     (hl)            ; increment P_FLAG to restore previous value
        inc     hl
        ld      bc, FONT
::FZX_FONT equ $-2
        push    bc
        pop     ix
        cp      13
        jp      z, NEWLINE
::FZX_BEHAVIOUR equ $-2
CHK_CHAR:
        dec     a               ; now A = char - 1
        cp      (ix+2)          ; compare with lastchar
        jr      nc, UNDEF_CHAR
        sub     31              ; now A = char - 32
        jr      nc, PRINT_CHAR
UNDEF_CHAR:
        ld      a, '?'-32       ; print '?' instead of invalid character
PRINT_CHAR:
        inc     a               ; now A = char - 31
        ld      l, a
        ld      h, 0
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, de          ; now HL = (char - 31) * 3
        add     hl, bc          ; now HL references offset/kern in char table
        ld      e, (hl)
        inc     hl
        ld      a, (hl)
        and     63
        ld      d, a            ; now DE = offset

        xor     (hl)
        rlca
        rlca
        ld      c, a            ; now C = kern

        push    hl
        add     hl, de
        dec     hl              ; now HL = char definition address
        ex      (sp), hl        ; now HL references offset/kern in char table
        inc     hl              ; now HL references shift/width in char table
        xor     a
        rld                     ; now A = char shift
        push    af
        rld                     ; now A = (width - 1)
        ld      (WIDTH1+1), a
        cp      8               ; check if char width is larger than 8 bits
        rld                     ; restore char shift/width

        ld      de, $000e       ; same as "LD C,0"
        jr      c, NARROW_CHAR
        ld      de, $234e       ; same as "LD C,(HL)" and "INC HL"
NARROW_CHAR:
        ld      (SMC), de       ; self-modify code to handle narrow/large chars

        inc     hl              ; now HL references next char offset
        ld      a, (hl)         ; now A = LSB of next char offset
        add     a, l
        ld      e, a            ; now E = LSB of next char definition address

        ld      hl, P_COL
        ld      a, (hl)
        sub     c               ; move left number of pixels specified by kern
        jr      nc, ON_SCREEN   ; stop moving if it would fall outside screen
        xor     a
ON_SCREEN:
        ld      (hl), a

        ld      a, (WIDTH1+1)   ; now A = (width - 1)
        add     a, (hl)         ; now A = (width - 1) + column
        call    c, NEWLINE      ; if char width won't fit then move to new line

        ld      bc, (P_COL)
        ld      a, 1
        sub     (ix+0)          ; now A = 1 - height
        add     a, b            ; now A = P_LIN - height + 1
        jp      nc, $0c86       ; call routine REPORT-5 ("Out of screen")

        pop     af              ; now A = shift

        add     a, 191          ; range 0-191
        call    $22aa + 2       ; call PIXEL-ADD + 2 to calculate screen address
        ex      af, af'
                                ; now A' = (col % 8)
        jr      CHK_LOOP

MAIN_LOOP:
        ld      d, (hl)         ; now D = 1st byte from char definition grid
        inc     hl              ; next character definition
SMC:
        ld      c, (hl)         ; now C = 2nd byte from char definition or zero
        inc     hl              ;   (either "LD C,0" or "LD C,(HL)" + "INC HL")
        xor     a               ; now A = zero (since there's no 3rd byte)
        ex      (sp), hl        ; now HL = screen address

        ex      af, af'
                                ; now A = (col % 8), A' = 0
        jr      z, NO_ROTATE
        ld      b, a            ; now B = (col % 8)
        ex      af, af'
                                ; now A = 0, A' = (col % 8)
ROTATE_PIXELS:
        srl     d               ; rotate right char definition grid in D,C,A
        rr      c
        rra
        djnz    ROTATE_PIXELS
NO_ROTATE:
        inc     l
        inc     l
        or      (hl)
        ld      (hl), a         ; put A on screen
        dec     l
        ld      a, c
        or      (hl)
        ld      (hl), a         ; put C on screen
        dec     l
        ld      a, d
        or      (hl)
        ld      (hl), a         ; put D on screen

        inc     h               ; move screen address by 1 pixel down
        ld      a, h
        and     7
        jr      nz, CHK_LOOP
        ld      a, l
        sub     -32
        ld      l, a
        sbc     a, a
        and     -8
        add     a, h
        ld      h, a
CHK_LOOP:
        ex      (sp), hl        ; now HL = char definition address
        ld      a, l
        cp      e               ; check if reached next char definition address
        jr      nz, MAIN_LOOP   ; loop otherwise

        pop     hl              ; discard screen address from stack
        ld      hl, P_COL
        ld      a, (hl)         ; now A = column
WIDTH1:
        add     a, 0            ; now A = column + (width - 1)
        scf
        adc     a, (ix+1)       ; now A = column + width + tracking
        jr      nc, EXIT        ; if didn't fall outside the screen then exit
NEWLINE:
        ld      (hl), MARGIN    ; move to initial column at left margin
::FZX_MARGIN_L equ $-1
        inc     hl
        ld      a, (hl)         ; now A = line
        sub     (ix+0)          ; now A = line - height
EXIT:
        ld      (hl), a         ; move down a few pixels specified by height
        ret
P_FLAG:
        defb        0
::FZX_COL:
P_COL:
        defb        MARGIN
P_LIN:
        defb        191
endp
; -----------------------------------------------------------------------------

