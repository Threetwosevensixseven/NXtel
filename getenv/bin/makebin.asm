; make a binary containing the listed functions
; the linker will pull in all dependencies for a given reference

org 0xc000

EXTERN asm_env_getenv
defc need_asm_env_getenv = asm_env_getenv

; generate a binary with
; zcc +zxn -vn -g --no-crt -clib=sdcc_ix makebin.asm -o makebin.bin
