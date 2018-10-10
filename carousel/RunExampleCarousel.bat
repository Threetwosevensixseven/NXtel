:: Set current directory
::@echo off
C:
CD %~dp0

..\tools\pskill.exe -t cspect.exe

copy .\bin\NXtelExampleCarousel.sna ..\sd\NXtelExampleCarousel.sna

"C:\Program Files (x86)\CSpect1_14\CSpect.exe" -s14 -w3 -zxnext -mmc=..\sd\ ..\sd\NXtelExampleCarousel.sna

:: pause