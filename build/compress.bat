@echo off
C:
CD %~dp0
cd ..\pages\zx7

del /F /Q *.zx7
"..\..\tools\zx7.exe" -f ClientWelcome.bin
"..\..\tools\zx7.exe" -f ConnectMenu.bin
"..\..\tools\zx7.exe" -f MainMenu.bin

rem pause
