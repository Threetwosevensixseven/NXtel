        org 57344

;BeepFX player by Shiru
;You are free to do whatever you want with this code



playBasic:
        ld a,0
play:
        ld hl,sfxData   ;address of sound effects data

        di
        push ix
        push iy

        ld b,0
        ld c,a
        add hl,bc
        add hl,bc
        ld e,(hl)
        inc hl
        ld d,(hl)
        push de
        pop ix                  ;put it into ix

        ld a,(23624)    ;get border color from BASIC vars to keep it unchanged
        rra
        rra
        rra
        and 7
        ld (sfxRoutineToneBorder  +1),a
        ld (sfxRoutineNoiseBorder +1),a
        ld (sfxRoutineSampleBorder+1),a


readData:
        ld a,(ix+0)             ;read block type
        ld c,(ix+1)             ;read duration 1
        ld b,(ix+2)
        ld e,(ix+3)             ;read duration 2
        ld d,(ix+4)
        push de
        pop iy

        dec a
        jr z,sfxRoutineTone
        dec a
        jr z,sfxRoutineNoise
        dec a
        jr z,sfxRoutineSample
        pop iy
        pop ix
        Border(Black)
        ei
        ret



;play sample

sfxRoutineSample:
        ex de,hl
sfxRS0:
        ld e,8
        ld d,(hl)
        inc hl
sfxRS1:
        ld a,(ix+5)
sfxRS2:
        dec a
        jr nz,sfxRS2
        rl d
        sbc a,a
        and 16
sfxRoutineSampleBorder:
        or 0
        //zeusdatabreakpoint 1, "zeusprint(1, 1, a)", $+disp
        out (254),a
        dec e
        jr nz,sfxRS1
        dec bc
        ld a,b
        or c
        jr nz,sfxRS0

        ld c,6

nextData:
        add ix,bc               ;skip to the next block
        jr readData



;generate tone with many parameters

sfxRoutineTone:
        ld e,(ix+5)             ;freq
        ld d,(ix+6)
        ld a,(ix+9)             ;duty
        ld (sfxRoutineToneDuty+1),a
        ld hl,0

sfxRT0:
        push bc
        push iy
        pop bc
sfxRT1:
        add hl,de
        ld a,h
sfxRoutineToneDuty:
        cp 0
        sbc a,a
        and 16
sfxRoutineToneBorder:
        or 0
        out (254),a

        dec bc
        ld a,b
        or c
        jr nz,sfxRT1

        ld a,(sfxRoutineToneDuty+1)      ;duty change
        add a,(ix+10)
        ld (sfxRoutineToneDuty+1),a

        ld c,(ix+7)             ;slide
        ld b,(ix+8)
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        dec bc
        ld a,b
        or c
        jr nz,sfxRT0

        ld c,11
        jr nextData



;generate noise with two parameters

sfxRoutineNoise:
        ld e,(ix+5)             ;pitch

        ld d,1
        ld h,d
        ld l,d
sfxRN0:
        push bc
        push iy
        pop bc
sfxRN1:
        ld a,(hl)
        and 16
sfxRoutineNoiseBorder:
        or 0
        out (254),a
        dec d
        jr nz,sfxRN2
        ld d,e
        inc hl
        ld a,h
        and 31
        ld h,a
sfxRN2:
        dec bc
        ld a,b
        or c
        jr nz,sfxRN1

        ld a,e
        add a,(ix+6)    ;slide
        ld e,a

        pop bc
        dec bc
        ld a,b
        or c
        jr nz,sfxRN0

        ld c,7
        jr nextData


sfxData:

SoundEffectsData:
        defw SoundEffect0Data
        defw SoundEffect1Data
        defw SoundEffect2Data

SoundEffect0Data:
        defb 1 ;tone
        defw 1,1000,1000,0,128
        defb 1 ;pause
        defw 1,1000,0,0,0
        defb 1 ;tone
        defw 1,2000,2000,0,128
        defb 1 ;tone
        defw 1,2000,2000,0,16
        defb 0
SoundEffect1Data:
        defb 1 ;tone
        defw 1,1000,1100,0,128
        defb 1 ;pause
        defw 1,1000,0,0,0
        defb 1 ;tone
        defw 1,2000,2200,0,128
        defb 1 ;tone
        defw 1,2000,2200,0,16
        defb 0
SoundEffect2Data:
        defb 1 ;tone
        defw 1,1000,1210,0,128
        defb 1 ;pause
        defw 1,1000,0,0,0
        defb 1 ;tone
        defw 1,2000,2420,0,128
        defb 1 ;tone
        defw 1,2000,2420,0,16
        defb 0

Sample0Data:
        defb 127,255,255,163,255,255,129,255,255,213,31,255,168,31,255,240
        defb 63,255,232,15,255,171,253,71,254,128,127,224,127,128,255,208
        defb 127,245,127,129,255,240,255,234,255,15,254,175,254,191,250,255
        defb 245,127,250,255,111,255,249,255,175,250,253,250,151,253,127,135
        defb 255,168,175,215,252,63,253,87,254,191,171,255,250,215,237,250
        defb 255,255,87,254,175,255,255,245,127,235,250,255,191,171,127,95
        defb 255,191,250,190,247,255,255,255,244,191,255,255,95,255,173,253
        defb 127,255,255,235,171,251,255,255,255,87,223,254,254,255,245,117
        defb 191,191,239,255,87,91,251,255,255,245,117,181,191,255,255,95
        defb 95,235,255,191,250,191,255,223,121,249,213,242,250,223,215,206
        defb 174,191,214,254,63,117,94,254,215,250,251,215,251,123,127,249
        defb 255,175,183,246,223,233,127,175,167,243,223,227,239,215,219,233
        defb 239,248,113,245,244,250,121,248,120,125,124,126,124,62,62,31
        defb 151,207,143,143,207,7,252,158,124,60,126,60,127,248,120,240
        defb 241,241,225,243,243,225,243,231,243,231,199,249,178,253,211,240
        defb 227,227,239,14,30,60,124,120,241,255,227,227,199,143,143,31
        defb 63,255,159,62,124,254

Sample1Data:
        defb 203,203,247,227,248,120,223,60,127,143,56,247,15,113,227,159
        defb 225,238,60,115,248,127,207,252,255,15,225,243,223,195,252,63
        defb 107,248,127,135,244,63,7,248,63,195,240,31,135,252,63,0
        defb 252,63,225,241,135,195,255,31,30,126,63,249,241,243,227,247
        defb 143,191,254,31,239,255,255,247,248,127,249,249,255,5,255,191
        defb 191,199,223,143,239,240,7,254,3,252,3,255,192,254,1,255
        defb 128,255,128,255,193,255,128,255,131,255,1,255,63,240,15,248
        defb 127,224,63,225,255,128,127,227,255,0,255,227,255,0,255,225
        defb 255,224,63,252,31,252,1,255,228,255,192,31,255,231,255,128
        defb 127,255,240,127,224,31,255,255,255,255,192,63,255,255,255,255
