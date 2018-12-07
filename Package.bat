CLS

IF "%1"=="" (
ECHO No build configuration parameter passed
GOTO errorHandling
)

IF "%2"=="" (
ECHO No version parameter passed
GOTO errorHandling
)

IF ERRORLEVEL 1 GOTO errorHandling

:: Download NuGet if its not already there
IF NOT EXIST .\packages\nuget\nuget.exe (
IF NOT EXIST .\packages\nuget\ MKDIR .\packages\nuget
ECHO ^(New-Object System.Net.WebClient^).DownloadFile('https://dist.nuget.org/win-x86-commandline/latest/nuget.exe', '.\\packages\\nuget\\nuget.exe'^) > .\nuget.ps1
PowerShell.exe -ExecutionPolicy Bypass -File .\nuget.ps1
)

:: Clean up
IF EXIST .\nuget.ps1 DEL .\nuget.ps1

.\packages\nuget\nuget.exe restore
IF ERRORLEVEL 1 GOTO errorHandling

IF EXIST .\_Deployment\Packages RMDIR .\_Deployment\Packages /S /Q
IF EXIST .\_Deployment\Output RMDIR .\_Deployment\Output /S /Q
IF EXIST .\_Deployment\Output RMDIR .\_Deployment\Output\CAS /S /Q
IF EXIST .\_Deployment\Output RMDIR .\_Deployment\Output\CDS /S /Q
MKDIR .\_Deployment\Packages
MKDIR .\_Deployment\Output
MKDIR .\_Deployment\Output\CAS
MKDIR .\_Deployment\Output\CDS

"C:\Program Files (x86)\MSBuild\14.0\Bin\MsBuild.exe" /m /t:Rebuild "test_app.sln" /p:Configuration=%1;ContentAuthoringOutputDir=%~dp0\_Deployment\Output\CAS;ContentDeliveryOutputDir=%~dp0\_Deployment\Output\CDS
IF ERRORLEVEL 1 GOTO errorHandling

.\packages\nuget\nuget.exe pack ".\Reactive.Nissan.Web\Nissan.Web.CAS.nuspec" -Version %2 -Verbosity detailed -BasePath .\_Deployment\Output\CAS\ -OutputDirectory .\_Deployment\Packages
IF ERRORLEVEL 1 GOTO errorHandling

EXIT /b 0

:errorHandling
EXIT /b -1
