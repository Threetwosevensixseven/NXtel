; version.asm
;
; Auto-generated by ZXVersion.exe
; On 05 Jun 2023 at 12:05

BuildNo                 macro()
                        db "274"
mend

BuildNoValue            equ "274"
BuildNoWidth            equ 0 + FW2 + FW7 + FW4



BuildDate               macro()
                        db "05 Jun 2023"
mend

BuildDateValue          equ "05 Jun 2023"
BuildDateWidth          equ 0 + FW0 + FW5 + FWSpace + FWJ + FWu + FWn + FWSpace + FW2 + FW0 + FW2 + FW3



BuildTime               macro()
                        db "12:05"
mend

BuildTimeValue          equ "12:05"
BuildTimeWidth          equ 0 + FW1 + FW2 + FWColon + FW0 + FW5



BuildTimeSecs           macro()
                        db "12:05:50"
mend

BuildTimeSecsValue      equ "12:05:50"
BuildTimeSecsWidth      equ 0 + FW1 + FW2 + FWColon + FW0 + FW5 + FWColon + FW5 + FW0
