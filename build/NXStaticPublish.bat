:: Set current directory and paths
echo off
C:
CD %~dp0

:: Prepare NXStaticServer for publishing
PATH=%PATH%;C:\Program Files (x86)\MSBuild\14.0\bin
CD ..\server\NXStaticServer 
DEL  /F /Q /S Publish\*.*
RMDIR /S /Q "Publish\bin"
RMDIR /S /Q "Publish\Content"
RMDIR /S /Q "Publish\fonts"
RMDIR /S /Q "Publish\Scripts"
RMDIR /S /Q "Publish\Views"

:: Publish NXStaticServer
msbuild NXStaticServer.csproj /p:DeployOnBuild=true /p:PublishProfile=FolderDeploy /p:Configuration="Release" /p:Platform="x86"

:: Deploy NXStaticServer
DEL  /F /Q Publish\web.config
RMDIR /S /Q "Publish\bin\roslyn"
XCOPY /Y /E "Publish\*.*" "%USERPROFILE%\Documents\Visual Studio 2015\Projects\NXtelDeploy\NXStaticServer\"

:: Stage and commit deployment changes for the server
for /F "tokens=2" %%i in ('date /t') do set mydate=%%i
cd "%USERPROFILE%\Documents\Visual Studio 2015\Projects\NXtelDeploy"
git add *
git commit -a -m "Autocommit %mydate% %time% from build script."
git push

PAUSE
