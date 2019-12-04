:: Set current directory
::@echo off
C:
CD %~dp0

copy ..\bin\NXtel.nex ..\sd\*.*

..\tools\pskill.exe -t cspect.exe

::"C:\Program Files (x86)\CSpect1_14\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex
::"C:\Program Files (x86)\CSpect_2_0_0\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex
::"C:\Program Files (x86)\CSpect2_3_3\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex
::"C:\Program Files (x86)\CSpect2_4_0\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -mmc=..\sd\ ..\sd\NXtel.nex
::"C:\Program Files (x86)\CSpect2_7_0\CSpect.exe" -s14 -w2 -zxnext -exit -brk -zx128 -com="COM5:115200" -mmc=..\sd\ ..\sd\NXtel.nex

C:\spec\next\CSpect2_8_2\hdfmonkey.exe put C:\spec\next\CSpect2_8_2\cspect-next-2gb.img ..\bin\NXtel.nex Mine

cd C:\spec\next\CSpect2_8_2
C:\spec\next\CSpect2_8_2\CSpect.exe -w2 -zxnext -nextrom -basickeys -esc -mmc=cspect-next-2gb.img


pause