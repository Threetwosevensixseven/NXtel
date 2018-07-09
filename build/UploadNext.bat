:: Set current directory
C:
CD %~dp0

del ..\bin\NexTel.snx
robocopy ..\bin\ Q:\ /DCOPY:T