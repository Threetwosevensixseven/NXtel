:: Set current directory and paths
echo off
C:
CD %~dp0

:: Prepare NXtelMonitor for publishing
PATH=%PATH%;C:\Program Files (x86)\MSBuild\14.0\bin
CD ..\server\NXtelMonitor

:: Publish NXtelMonitor
msbuild NXtelMonitor.csproj /p:DeployOnBuild=true /p:PublishProfile=FolderDeploy /p:Configuration="Release" /p:Platform="AnyCPU"

:: Deploy NXtelMonitor
DEL  /F /Q Publish\NXtelMonitor.exe.config
DEL  /F /Q Publish\NXtelMonitor.pdb
XCOPY /Y /E "Publish\*.*" "%USERPROFILE%\Documents\Visual Studio 2015\Projects\NXtelDeploy\NXtelMonitor\"

:: Stage and commit deployment changes for the server
for /F "tokens=2" %%i in ('date /t') do set mydate=%%i
cd "%USERPROFILE%\Documents\Visual Studio 2015\Projects\NXtelDeploy"
git add *
git commit -a -m "Autocommit %mydate% %time% from build script."
git push

PAUSE
