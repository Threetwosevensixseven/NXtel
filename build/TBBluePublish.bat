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
copy .\src\*.asm ..\tbblue\src\asm\NXtel\src\*.*
copy .\build\get*.??t ..\tbblue\src\asm\NXtel\build\*.*
copy .\banks\Default.cfg ..\tbblue\src\asm\NXtel\banks\*.*
copy .\fonts\*.fzx ..\tbblue\src\asm\NXtel\fonts\*.*
copy .\sfx\*.asm ..\tbblue\src\asm\NXtel\sfx\*.*
copy .\sfx\*.spj ..\tbblue\src\asm\NXtel\sfx\*.*

pause