:: Set current directory
::@echo off
C:
CD %~dp0

copy ..\bin\NXtel.nex ..\sd\*.*

..\tools\pskill.exe -t cspect.exe

hdfmonkey.exe put C:\spec\sd207\cspect-next-2gb.img ..\bin\NXtel.nex Mine
hdfmonkey.exe put C:\spec\sd207\cspect-next-2gb.img autoexec.bas nextzxos\autoexec.bas
hdfmonkey.exe put C:\spec\sd207\cspect-next-2gb.img ..\guide\GUIDE DOT
hdfmonkey.exe put C:\spec\sd207\cspect-next-2gb.img ..\guide\NXtel.gde Mine
hdfmonkey.exe put C:\spec\sd207\cspect-next-2gb.img ..\build\UART DOT

cd C:\spec\CSpect2_19_0_3
CSpect.exe -w2 -zxnext -nextrom -basickeys -exit -brk -tv -mmc=..\sd207\cspect-next-2gb.img


pause