; version.asm
;
; Auto-generated by ZXVersion.exe
; On 08 Nov 2018 at 18:44

BuildNo                 macro()
                        db "92"
mend

BuildNoValue            equ "92"
BuildNoWidth            equ 0 + FW9 + FW2



BuildDate               macro()
                        db "08 Nov 2018"
mend

BuildDateValue          equ "08 Nov 2018"
BuildDateWidth          equ 0 + FW0 + FW8 + FWSpace + FWN + FWo + FWv + FWSpace + FW2 + FW0 + FW1 + FW8



BuildTime               macro()
                        db "18:44"
mend

BuildTimeValue          equ "18:44"
BuildTimeWidth          equ 0 + FW1 + FW8 + FWColon + FW4 + FW4



BuildTimeSecs           macro()
                        db "18:44:15"
mend

BuildTimeSecsValue      equ "18:44:15"
BuildTimeSecsWidth      equ 0 + FW1 + FW8 + FWColon + FW4 + FW4 + FWColon + FW1 + FW5
