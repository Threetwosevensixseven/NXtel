; nxkeyutils.asm

ClsAttr                 proc
                        ClsAttrFull(DimBlackBlackP)
                        ret
pend



PauseProc               proc
Wait:                   ld hl, [Timer]SMC
                        dec hl
                        ld (Timer), hl
                        ld a, h
                        or l
                        jp nz, Wait
                        ret
pend

