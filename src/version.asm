; version.asm
;
; Auto-generated by ZXVersion.exe
; On 18 Nov 2018 at 16:57

BuildNo                 macro()
                        db "114"
mend

BuildNoValue            equ "114"
BuildNoWidth            equ 0 + FW1 + FW1 + FW4



BuildDate               macro()
                        db "18 Nov 2018"
mend

BuildDateValue          equ "18 Nov 2018"
BuildDateWidth          equ 0 + FW1 + FW8 + FWSpace + FWN + FWo + FWv + FWSpace + FW2 + FW0 + FW1 + FW8



BuildTime               macro()
                        db "16:57"
mend

BuildTimeValue          equ "16:57"
BuildTimeWidth          equ 0 + FW1 + FW6 + FWColon + FW5 + FW7



BuildTimeSecs           macro()
                        db "16:57:25"
mend

BuildTimeSecsValue      equ "16:57:25"
BuildTimeSecsWidth      equ 0 + FW1 + FW6 + FWColon + FW5 + FW7 + FWColon + FW2 + FW5
