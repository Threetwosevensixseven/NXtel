; version.asm
;
; Auto-generated by ZXVersion.exe
; On 04 Jun 2023 at 12:08

BuildNo                 macro()
                        db "271"
mend

BuildNoValue            equ "271"
BuildNoWidth            equ 0 + FW2 + FW7 + FW1



BuildDate               macro()
                        db "04 Jun 2023"
mend

BuildDateValue          equ "04 Jun 2023"
BuildDateWidth          equ 0 + FW0 + FW4 + FWSpace + FWJ + FWu + FWn + FWSpace + FW2 + FW0 + FW2 + FW3



BuildTime               macro()
                        db "12:08"
mend

BuildTimeValue          equ "12:08"
BuildTimeWidth          equ 0 + FW1 + FW2 + FWColon + FW0 + FW8



BuildTimeSecs           macro()
                        db "12:08:25"
mend

BuildTimeSecsValue      equ "12:08:25"
BuildTimeSecsWidth      equ 0 + FW1 + FW2 + FWColon + FW0 + FW8 + FWColon + FW2 + FW5
