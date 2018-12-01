@echo off
C:
CD %~dp0
cd ..\pages\zx7

del /F /Q *.zx7
"..\..\tools\zx7.exe" -f ClientWelcome.tt8
"..\..\tools\zx7.exe" -f ConnectMenu.tt8
"..\..\tools\zx7.exe" -f MainMenu.tt8
"..\..\tools\zx7.exe" -f NetworkSettingsMenu.tt8
"..\..\tools\zx7.exe" -f KeysMenu.tt8

"..\..\tools\zx7.exe" -f StatusMessages.tt8

rem pause
