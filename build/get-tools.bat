@echo off
if exist "%~dpn0.txt" (
    echo Copying "%~dpn0.txt"
    echo to "%~dpn0.ps1"...
    copy "%~dpn0.txt" "%~dpn0.ps1"
) else goto :scriptexists
:scriptexists
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dpn0.ps1'"
PAUSE