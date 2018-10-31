:: Set current directory
C:
CD %~dp0

del ..\bin\NXtel.snx
robocopy ..\bin\ Q:\ /DCOPY:T