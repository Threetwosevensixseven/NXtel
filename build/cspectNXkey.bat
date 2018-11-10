:: Set current directory
::@echo off
C:
CD %~dp0

..\tools\pskill.exe -t cspect.exe

"C:\Program Files (x86)\CSpect1_14\CSpect.exe" -s14 -w3 -zxnext -exit -brk -mmc=..\sd\ ..\sd\NXkey.sna

:: pause