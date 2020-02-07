@echo off
C:
CD %~dp0
cd ..\pages\zx7

del /F /Q *.zx7
"..\..\build\zx7.exe" -f ClientWelcome.tt8
"..\..\build\zx7.exe" -f ConnectMenu.tt8
"..\..\build\zx7.exe" -f MainMenu.tt8
"..\..\build\zx7.exe" -f NetworkSettingsMenu.tt8
"..\..\build\zx7.exe" -f KeysMenu.tt8
"..\..\build\zx7.exe" -f StatusMessages.tt8

pause
