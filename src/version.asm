; version.asm
;
; Auto-generated by ZXVersion.exe
; On 01 Nov 2018 at 18:04

BuildNo                 macro()
                        db "81"
mend

BuildNoValue            equ "81"
BuildNoWidth            equ 0 + FW8 + FW1



BuildDate               macro()
                        db "01 Nov 2018"
mend

BuildDateValue          equ "01 Nov 2018"
BuildDateWidth          equ 0 + FW0 + FW1 + FWSpace + FWN + FWo + FWv + FWSpace + FW2 + FW0 + FW1 + FW8



BuildTime               macro()
                        db "18:04"
mend

BuildTimeValue          equ "18:04"
BuildTimeWidth          equ 0 + FW1 + FW8 + FWColon + FW0 + FW4



BuildTimeSecs           macro()
                        db "18:04:45"
mend

BuildTimeSecsValue      equ "18:04:45"
BuildTimeSecsWidth      equ 0 + FW1 + FW8 + FWColon + FW0 + FW4 + FWColon + FW4 + FW5
