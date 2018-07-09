@echo off
C:
CD "C:\Users\robin\Documents\Visual Studio 2015\Projects\zesarux\src"

zesarux.exe --noconfigfile --machine tbblue --realvideo --enabletimexvideo --frameskip 0 --disable-autoframeskip --nosplash --nowelcomemessage --quickexit --gui-style "ZXSpectr" --def-f-function F4 "HardReset" --def-f-function F10 "ExitEmulator" --tbblue-fast-boot-mode --sna-no-change-machine --enable-esxdos-handler --esxdos-root-dir "C:\Users\robin\Documents\Visual Studio 2015\Projects\NexTel\sd" "C:\Users\robin\Documents\Visual Studio 2015\Projects\NexTel\bin\NexTel.sna"