:: Set current directory
::@echo off
C:
CD %~dp0

..\tools\pskill.exe -t cspect.exe

"C:\Program Files (x86)\CSpect1_13_2\CSpect.exe" -s14 -w2 -zxnext -mmc=..\sd\ ..\bin\NXtel.sna

:: pause