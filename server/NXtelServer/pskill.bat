:: Set current directory
::@echo off
C:
CD %~dp0

pskill.exe -t NXtelServer.exe
::exit /B 0

