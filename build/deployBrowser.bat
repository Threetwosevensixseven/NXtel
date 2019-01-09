:: Set current directory
::@echo off
C:
CD %~dp0

ZXVersion.exe
NexCreator.exe BrowserTest.big ..\bin\BrowserTest.nex

::pause