; version.asm
;
; Auto-generated by ZXVersion.exe
; On 06 Nov 2018 at 18:04

BuildNo                 macro()
                        db "88"
mend

BuildNoValue            equ "88"
BuildNoWidth            equ 0 + FW8 + FW8



BuildDate               macro()
                        db "06 Nov 2018"
mend

BuildDateValue          equ "06 Nov 2018"
BuildDateWidth          equ 0 + FW0 + FW6 + FWSpace + FWN + FWo + FWv + FWSpace + FW2 + FW0 + FW1 + FW8



BuildTime               macro()
                        db "18:04"
mend

BuildTimeValue          equ "18:04"
BuildTimeWidth          equ 0 + FW1 + FW8 + FWColon + FW0 + FW4



BuildTimeSecs           macro()
                        db "18:04:55"
mend

BuildTimeSecsValue      equ "18:04:55"
BuildTimeSecsWidth      equ 0 + FW1 + FW8 + FWColon + FW0 + FW4 + FWColon + FW5 + FW5
