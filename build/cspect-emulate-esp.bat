:: Set current directory
::@echo off
C:
CD %~dp0

copy ..\bin\NXtel.nex ..\sd\*.*

..\tools\pskill.exe -t cspect.exe

hdfmonkey.exe put E:\Next\NextKS2-Card-RC2.img ..\bin\NXtel.nex apps\wifi\NXtel
::hdfmonkey.exe put E:\Next\NextKS2-Card-RC2.img autoexec.bas nextzxos\autoexec.bas
::hdfmonkey.exe put E:\Next\NextKS2-Card-RC2.img ..\guide\GUIDE DOT
::hdfmonkey.exe put E:\Next\NextKS2-Card-RC2.img ..\guide\NXtel.gde apps\wifi\NXtel
::hdfmonkey.exe put E:\Next\NextKS2-Card-RC2.img ..\build\UART DOT

cd C:\spec\CSpect2_19_0_3
CSpect.exe -w2 -zxnext -nextrom -basickeys -exit -brk -tv -mmc=E:\Next\NextKS2-Card-RC2.img

::pause