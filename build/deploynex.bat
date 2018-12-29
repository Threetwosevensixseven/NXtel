:: Set current directory
::@echo off
C:
CD %~dp0

ZXVersion.exe
NexCreator.exe NXtel.big ..\bin\NXtel.nex
SpectronPackager.exe
copy ..\bin\NXtel.sna ..\sd\*.*
copy ..\bin\NXtel.nex ..\sd\*.*

::pause