:: Set current directory
::@echo off
C:
CD %~dp0

ZXVersion.exe
NexCreator.exe NXtel.big ..\bin\NXtel.nex
copy ..\bin\NXtel.nex ..\sd\*.*

::pause