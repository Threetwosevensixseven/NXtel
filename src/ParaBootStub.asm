; This code is a ParaSys boot stub - it asks Zeus to provide the slave code, loads it into memory and runs it.

; The UART

UART_RxD                equ $143B                       ; Also used to set the baudrate
UART_TxD                equ $133B                       ; Also reads status
UART_SetBaud            equ UART_RxD                    ; Sets baudrate
UART_GetStatus          equ UART_TxD                    ; Reads status bits

; Status bit masks

UART_mRX_DATA_READY     equ %xxxxx 0 0 1                ;
UART_mTX_BUSY           equ %xxxxx 0 1 0                ;
UART_mRX_FIFO_FULL      equ %xxxxx 1 0 0                ;

; Protocol characters

cpcSTUFF                equ $A6                         ; PSSI protocol bytes
cpcSOM                  equ $A7                         ;

; PC <-> AVR commands, etc

PSSI_WordLength         equ 4                           ; Word length on PC

PSSI_Settings           equ $00                         ; Serial commands
PSSI_ReadMemoryBlock    equ $01                         ;
PSSI_ReadMemoryBlockACK equ $81                         ;

PSSI_WriteMemoryBlock   equ $02                         ;
PSSI_WriteMemoryBlockACK equ $82                        ;

PSSI_Execute            equ $03                         ;
PSSI_ExecuteACK         equ $83                         ;

PSSI_Reset              equ $04                         ;
PSSI_ResetACK           equ $84                         ;

PSSI_Enquire            equ $05                         ;
PSSI_EnquireACK         equ $85                         ;

PSSI_Input              equ $06                         ;
PSSI_InputACK           equ $86                         ;

PSSI_Output             equ $07                         ;
PSSI_OutputACK          equ $87                         ;

PSSI_LDIR               equ $08                         ;
PSSI_LDIRACK            equ $88                         ;

PSSI_LDDR               equ $09                         ;
PSSI_LDDRACK            equ $89                         ;

PSSI_CMD                equ $0A                         ;
PSSI_CMDACK             equ $8A                         ;

; Call this once to set the UART up before we can use it

if not enabled NoPara
BootTestSetup           proc                            ; ParaSys will hang indefinitely if UART_GetStatus has bit 0 set.
                                                        ; For emulators that return 255 on unknown ports, disable Parasys.
                        NextRegRead($00)                ; (R) 0x00 (00) => Machine ID
                        cp 10                           ; Machine ID 10 = ZX Spectrum Next
                        jp z, EnableParaSys             ; If a Next then set up UART
                        ld a, $C9                       ; SMC> $C9 = ret
                        ld (BootTest), a                ; Otherwise make Parasys call return immediately
                        ret                             ; and do no further setup.
EnableParaSys:
                        ld bc,$243B                     ; Now adjust for the set Video timing.
                                                        ; Existing BootTestSetup code follows from here...
                        ld a,17                         ;
                        out (c),a                       ;

                        inc b                           ;
                        in a,(c)                        ;

                        ld hl,BaudTable                 ;
                        add a,l                         ;
                        ld l,a                          ;

                        adc a,h                         ;
                        sub l                           ;
                        ld h,a                          ;

                        ld a,(hl)                       ;

                        ld bc,UART_SetBaud              ;

                        out(c),a                        ;

                        ld a,%1 0000000                 ; Top bit set
                        out(c),a                        ;

                        ret                             ; Done

BaudTable               db 14,14,15,15,16,16,17,14      ; 2000000

                        pend                            ;
//zeusprint $-BootTestSetup-1
; Call this periodically and it will "install" ParaSys when there is any comms activity

BootTest                proc                            ; Hide all the labels

                        ld a,high UART_GetStatus        ; Are there any characters waiting?
                        in a,(low UART_GetStatus)       ; This inputs from the 16-bit address UART_GetStatus
                        and UART_mRX_DATA_READY         ; We're just interested in the DATA_READY flag
                        ret z                           ; And we return in there isn't any.

                        ; There are characters in the buffer, assume Zeus wants to talk to us...

        if (BootPara - *) > 0                           ; Jump to BootPara unless we can just fall into it...
          jp BootPara                                   ;
        endif                                           ;

                        pend

BootPara                proc                            ; Hide all the labels

                        ; Now, there's something waiting, so we want to boot ParaSys...

                        di                              ; Kill the interrupts

                        ; We need to tell Zeus we want the code and where it will go.
                        ld hl,BootParaBase              ; Put it here

                        ld d,cpcSTUFF                   ; Tell Zeus to give us the ParaSys code
                        call BootTxD_D                  ;
                        ld d,$FF                        ; STUFF+$FF is the request for the boot code
                        call BootTxD_D                  ;
                        ld d,l                          ; Followed by the base address for where it's to go
                        call BootTxD_D                  ;
                        ld d,h                          ;
                        call BootTxD_D                  ;

                        ; Now wait for the start of the boot code (There will be crap in the buffer)

BootWait                call BootRxD                    ; Get a char
                        cp cpcSTUFF                     ; STUFF?
                        jr nz BootWait                  ; Nope
                        call BootRxD                    ; Get a char
                        inc a                           ; Was it $FF?
                        jr nz BootWait                  ; Nope

                        ; We now expect the terminator code (it can change)

                        call BootRxD                    ; Get the terminator byte
                        ld e,a                          ;

BootPlantLp             ld a,high UART_GetStatus        ; Are there any characters waiting?
                        in a,(low UART_GetStatus)       ; This inputs from the 16-bit address UART_GetStatus
        if UART_mRX_DATA_READY = $01
                        rrca                            ; Test bit zero
                        jr nc BootPlantLp               ; Not ready yet
        else
                        and UART_mRX_DATA_READY         ; We're just interested in the DATA_READY flag
                        jr z BootPlantLp                ; Nothing
        endif
                        ; Read it

                        ld a,high UART_RxD              ; Read it
                        in a,(low UART_RxD)             ;

                        ld (hl),a                       ; Store it
                        inc hl                          ;

                        cp e                            ; End?
                        jr nz BootPlantLp               ; No, loop

                        jp BootParaBase                 ; Start the ParaSys driver

; Read a byte

BootRxD                 ld a,high UART_GetStatus        ; Are there any characters waiting?
                        in a,(low UART_GetStatus)       ; This inputs from the 16-bit address UART_GetStatus
        if UART_mRX_DATA_READY = $01
                        rrca                            ; Test bit zero
                        jr nc BootRxD                   ; Not ready yet
        else
                        and UART_mRX_DATA_READY         ; We're just interested in the DATA_READY flag
                        jr z BootRxD                    ; Nothing
        endif
                        ; Read it

                        ld a,high UART_RxD              ; Read it
                        in a,(low UART_RxD)             ;

                        ret                             ; Done

; Send a byte

BootTxD_D               ld bc,UART_GetStatus            ; Send a byte

BootTxDWait             in a,(c)                        ; Wait until it's sent
                        and UART_mTX_BUSY               ;
                        jr nz BootTxDWait               ; Loop

                        out (c),d                       ; Send it

                        ret                             ; Done

                        pend                            ; And we're done
//zeusprint $-BootTest-1
else
BootTestSetup:
                        ret
                        ds 57
//zeusprint $-BootTestSetup-1
BootTest:
                        ret
                        ds 88
//zeusprint $-BootTest-1
endif

