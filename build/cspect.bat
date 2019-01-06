:: Set current directory
::@echo off
C:
CD %~dp0

..\tools\pskill.exe -t cspect.exe

::"C:\Program Files (x86)\CSpect1_14\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex
"C:\Program Files (x86)\CSpect_2_0_0\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex


:: pause