; c32.asm

Sprites32               proc
  Offline equ ($-Sprites32)/256
  import_bin "..\sprites\offline.spr"

  Online equ ($-Sprites32)/256
  import_bin "..\sprites\online.spr"

  Connecting equ ($-Sprites32)/256
  import_bin "..\sprites\connecting.spr"

  Error equ ($-Sprites32)/256
  import_bin "..\sprites\error.spr"

  Disconnected equ ($-Sprites32)/256
  import_bin "..\sprites\disconnected.spr"

  Count equ ($-Sprites32)/256
pend



SetupSprites32          proc
                        ld a, 64
                        ld h, 0
Loop:                   ld bc, Sprite_Index_Port        ; Set the sprite index (port $303B)
                        dec a
                        out (c), a                      ; (0 to 63)
                        ld bc, Sprite_Sprite_Port       ; Send the sprite slot attributes (port $57)
                        out (c), h
                        out (c), h
                        out (c), h
                        out (c), h
                        jp nz, Loop
                        for n = 0 to Sprites32.Count-1
                          SetSpritePattern(Sprites32, n, n)
                        next;n
                        nextreg $15, %0 00 000 1 1      ; Enable sprites, over border, set SLU
                        jp SetupSprites.Return
pend



WriteSpritePattern      proc
                        ld bc, Sprite_Index_Port        ; Set the sprite index
                        out (c), a                      ; (0 to 63)
                        ld a, 0                         ; Send 256 pixel bytes (16*16)
                        ld d, 0                         ; Counter
                        ld bc, Sprite_Pattern_Port
PixelLoop:              ld e, (hl)
                        inc hl
                        out (c), e
                        dec d
                        jr nz PixelLoop
                        ret
pend



NextSpriteProc          proc
                        ld bc, Sprite_Index_Port        ; Set the sprite index (port $303B)
                        out (c), a                      ; (0 to 63)
                        ld bc, Sprite_Sprite_Port       ; Send the sprite slot attributes (port $57)
                        out (c), l
                        out (c), h
                        out (c), e
                        out (c), d
                        ret
End equ $-1
pend



StatusIcon32            proc                            ; e = status icon number
                        ld a, e
                        cp Sprites32.Offline
                        jp z, IconOffline
                        cp Sprites32.Online
                        jp z, IconOnline
                        cp Sprites32.Connecting
                        jp z, IconConnecting
                        cp Sprites32.Error
                        jp z, IconError
                        cp Sprites32.Disconnected
                        jp z, IconDisconnected
                        jp StatusIconProc.Return
pend



IconOffline             proc
                        NextSprite(0, (1*16)-2, 200, 0, false, false, false, true, Sprites32.Offline+0)
                        NextSprite(1, (2*16)-2, 200, 0, false, false, false, true, Sprites32.Offline+1)
                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Offline+2)
                        NextSprite(3, (4*16)-2, 200, 0, false, false, false, true, Sprites32.Offline+3)
                        NextSprite(4, (5*16)-2, 200, 0, false, false, false, true, Sprites32.Offline+4)
                        NextSprite(5, (6*16)-2, 200, 0, false, false, false, false, 0)
                        NextSprite(6, (7*16)-2, 200, 0, false, false, false, false, 0)
                        jp StatusIconProc.Return
pend



IconOnline              proc
                        NextSprite(0, (1*16)-2, 200, 0, false, false, false, true, Sprites32.Online+0)
                        NextSprite(1, (2*16)-2, 200, 0, false, false, false, true, Sprites32.Online+1)
                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Online+2)
                        NextSprite(3, (4*16)-2, 200, 0, false, false, false, true, Sprites32.Online+3)
                        NextSprite(4, (5*16)-2, 200, 0, false, false, false, false, 0)
                        NextSprite(5, (6*16)-2, 200, 0, false, false, false, false, 0)
                        NextSprite(6, (7*16)-2, 200, 0, false, false, false, false, 0)
                        jp StatusIconProc.Return
pend



IconConnecting          proc
                        NextSprite(0, (1*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+0)
                        NextSprite(1, (2*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+1)
                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+2)
                        NextSprite(3, (4*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+3)
                        NextSprite(4, (5*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+4)                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+2)
                        NextSprite(5, (6*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+5)
                        NextSprite(6, (7*16)-2, 200, 0, false, false, false, true, Sprites32.Connecting+6)
                        jp StatusIconProc.Return
pend



IconError               proc
                        NextSprite(0, (1*16)-2, 200, 0, false, false, false, true, Sprites32.Error+0)
                        NextSprite(1, (2*16)-2, 200, 0, false, false, false, true, Sprites32.Error+1)
                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Error+2)
                        NextSprite(3, (4*16)-2, 200, 0, false, false, false, true, Sprites32.Error+3)
                        NextSprite(4, (5*16)-2, 200, 0, false, false, false, false, 0)
                        NextSprite(5, (6*16)-2, 200, 0, false, false, false, false, 0)
                        NextSprite(6, (7*16)-2, 200, 0, false, false, false, false, 0)
                        jp StatusIconProc.Return
pend



IconDisconnected        proc
                        NextSprite(0, (1*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+0)
                        NextSprite(1, (2*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+1)
                        NextSprite(2, (3*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+2)
                        NextSprite(3, (4*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+3)
                        NextSprite(4, (5*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+4)
                        NextSprite(5, (6*16)-2, 200, 0, false, false, false, true, Sprites32.Disconnected+5)
                        NextSprite(6, (7*16)-2, 200, 0, false, false, false, false, 0)
                        jp StatusIconProc.Return
pend



SetupBrowserPalette6    proc
                        NextPaletteRGB8($00, %101 101 10, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($07, %000 000 00, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($08, %111 111 11, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($0F, %000 000 10, PaletteULAa) ; Path text in blue
                        NextPaletteRGB8($10, %101 101 10, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($17, %000 000 00, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($18, %111 111 11, PaletteULAa) ; Swap blacks and whites
                        NextPaletteRGB8($1F, %000 000 10, PaletteULAa) ; "Browser" text in blue
                        NextPaletteRGB8($15, %100 000 10, PaletteULAa) ; Dir highlight in purple
                        NextPaletteRGB8($16, %000 000 10, PaletteULAa) ; File highlight in blue
                        NextPaletteRGB8($0D, %010 010 11, PaletteULAa) ; Darken rainbow flash blue
                        NextPaletteRGB8($0E, %111 110 00, PaletteULAa) ; Darken rainbow flash yellow
                        NextPaletteRGB8($1C, %000 101 00, PaletteULAa) ; Darken rainbow flash green
                        nextreg $52, 10
                        Border(Teletext.Border)
                        xor a
                        ld (STIMEOUT), a                               ; Turn off screensaver
                        nextreg $52, 13
                        jp SetupBrowserPalette.Return
pend

