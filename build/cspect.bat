:: Set current directory
::@echo off
C:
CD %~dp0

..\tools\pskill.exe -t cspect.exe

"C:\Program Files (x86)\CSpect1_11\CSpect.exe" -s14 -zxnext -mmc=..\sd\ ..\bin\NexTel.sna

:: pause