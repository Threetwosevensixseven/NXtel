:: Set current directory and paths
::@echo off
C:
CD %~dp0
CD ..\

:: BINARIES
copy .\bin\NXtel.nex ..\tbblue\demos\NXtel\*.*
copy .\build\readme.txt ..\tbblue\demos\NXtel\*.*

:: SOURCE
copy .\build\readme-source.txt ..\tbblue\src\asm\NXtel\readme.txt
copy .\build\compress-distro.bat ..\tbblue\src\asm\NXtel\build\compress.bat
copy .\build\loading-screen3.bmp ..\tbblue\src\asm\NXtel\build\*.*
copy .\src\*.asm ..\tbblue\src\asm\NXtel\src\*.*
copy .\build\get*.??t ..\tbblue\src\asm\NXtel\build\*.*
copy .\banks\Default.cfg ..\tbblue\src\asm\NXtel\banks\*.*
copy .\fonts\*.fzx ..\tbblue\src\asm\NXtel\fonts\*.*
copy .\sfx\*.asm ..\tbblue\src\asm\NXtel\sfx\*.*
copy .\pages\welcome-website.tt8 ..\tbblue\src\asm\NXtel\pages\*.*
copy .\pages\double-height-copy-down.tt8 ..\tbblue\src\asm\NXtel\pages\*.*
copy .\pages\zx7\ClientWelcome.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\zx7\ConnectMenu.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\zx7\MainMenu.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\zx7\NetworkSettingsMenu.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\zx7\KeysMenu.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\zx7\StatusMessages.tt8 ..\tbblue\src\asm\NXtel\pages\zx7\*.*
copy .\pages\demo1\*.tt8 ..\tbblue\src\asm\NXtel\pages\demo1\*.*
copy .\sprites\*.spr ..\tbblue\src\asm\NXtel\sprites\*.*

pause