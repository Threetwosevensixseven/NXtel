:: Set current directory
::echo off
@C:
@CD %~dp0

nc64 -L -p 10000
