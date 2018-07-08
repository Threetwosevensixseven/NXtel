; esxDOS.asm
;
; NOTE: File paths use the slash character (‘/’) as directory separator (UNIX style)



esxDOS proc

M_GETSETDRV             equ $89
F_OPEN                  equ $9a
F_CLOSE                 equ $9b
F_READ                  equ $9d
F_WRITE                 equ $9e
F_SEEK                  equ $9f
F_GET_DIR               equ $a8
F_SET_DIR               equ $a9

FA_READ                 equ $01
FA_APPEND               equ $06
FA_OVERWRITE            equ $0C

esx_seek_set            equ $00         ; set the fileposition to BCDE
esx_seek_fwd            equ $01         ; add BCDE to the fileposition
esx_seek_bwd            equ $02         ; subtract BCDE from the fileposition




; Function:             Detect if unit is ready
; Out:                  A = default drive (required for all file access)
;                       Carry flag will be set if error.
GetSetDrive:
                        xor a                           ; A=0, get the default drive
                        Rst8(esxDOS.M_GETSETDRV)
                        ld (DefaultDrive),a
                        ret
::dr:
DefaultDrive db   0



; Function:             Open file
; In:                   IX = oointer to file name (ASCIIZ)
;                       B  = open mode
;                       A  = Drive
; Out:                  A  = file handle
;                       On error: Carry set
;                         A = 5   File not found
;                         A = 7   Name error - not 8.3?
;                         A = 11  Drive not found
;
fOpen:
                        ld a, (DefaultDrive)            ; get drive we're on
                        ld b, FA_READ                   ; b = open mode
                        Rst8(esxDOS.F_OPEN)             ; open read mode
                        ld (Handle), a
                        ret                             ; Returns a file handler in 'A' register.



; Function:             Read bytes from a file
; In:                   A  = file handle
;                       IX = address to load into
;                       BC = number of bytes to read
; Out:                  Carry flag is set if read fails.
fRead:
                        ld a, (Handle)                  ; file handle
                        Rst8(esxDOS.F_READ)             ; read file
                        ret



; Function:             Write bytes to a file
; In:                   A  = file handle
;                       IX = address to save from
;                       BC = number of bytes to write
; Out:                  Carry flag is set if write fails.
fWrite:
                        ld ix, 16384                    ; ix = memory address to save from
                        ld bc, 6912                     ; bc = bytes to write
                        ld a, (Handle)                  ; a  = file handler
                        Rst8(esxDOS.F_WRITE)            ; write file
                        ret



; Function:             Write bytes to a file
; In:                   A  = file handle
; Out:                  Carry flag active if error when closing
fClose:
                        ld a, (Handle)
                        Rst8(esxDOS.F_CLOSE)            ; close file
                        ret



; Function:             Seek into file
; In:                   A    = file handle
;                       L    = mode:  0 - from start of file
;                                     1 - forward from current position
;                                     2 - back from current position
;                       BCDE = bytes to seek
; Out:                  BCDE = Current file pointer. (*does not return this yet)
;
fSeek:
                        ld a, (Handle)                  ; file handle
                        or a                            ; is it zero?
                        ret z                           ; if so return
                        Rst8(esxDOS.F_SEEK)             ; seek into file
                        ret



; Function:             SetDirectory
; In:                   A    = Drive
;                       IX   = pointer to zero terminated path string ("path",0)
; Out:                  carry set if error
;
SetDir:
                        ld a, (DefaultDrive)            ; drive to change directory on
                        ld ix, Name                     ; point to "path",0 to set
                        Rst8(esxDOS.F_SET_DIR)          ; set directory
                        ret



; Function:             Get Directory
; In:                   A    = Drive
;                       IX   = pointer to where to STORE zero terminated path string
; Out:                  carry set if error
;
GetDir:
                        ld a, (DefaultDrive)            ; drive to get current directory from
                        ld ix, Name                     ; location to store path string in
                        Rst8(esxDOS.F_GET_DIR)          ; get directory
                        ret



; Function:             Change to relative subdirectory
; In:                   A    = Drive
;                       DE   = pointer to zero terminated relative subdir string ("subdir",0)
;                       HL   = length of relative subdir string, including null terminator
; Out:                  carry set if error
;
ChSubDir:
                        ld (AppendLen), hl
                        ld hl, Name                     ; Buffer address
                        ld bc, 256                      ; Buffer length
                        xor a                           ; Return when null terminator matched
                        cpir
                        ld hl, 256
                        sbc hl, bc
                        ld bc, Name
                        add hl, bc
                        dec hl                          ; hl points to existing null terminator
                        ex de, hl
AppendLen equ $+1:      ld bc, SMC
                        ldir
                        ld ix, Name
                        call SetDir
                        ret
::na:
Name:                   ds 256                          ; Buffer to store names, paths, etc
                        ds 14                           ; Null terminators to prevent overflow
::ha:
Handle:                 ds 1                            ; File handle (0..255)
::te:                   ds 3
pend

