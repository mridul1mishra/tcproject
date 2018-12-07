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

.\packages\nuget\nuget.exe pack ".\Reactive.Nissan.Web\Nissan.Web.CDS.nuspec" -Version %2 -Verbosity detailed -BasePath .\_Deployment\Output\CDS\ -OutputDirectory .\_Deployment\Packages
IF ERRORLEVEL 1 GOTO errorHandling

REM CREATE NISSAN.ASSETS NUPKG ARTIFACT
.\packages\nuget\nuget.exe pack ".\Reactive.Nissan.Content\Nissan.Assets.nuspec" -Version %2 -Verbosity detailed -BasePath .\Reactive.Nissan.Content\Nissan-Assets -OutputDirectory .\_Deployment\Packages
IF ERRORLEVEL 1 GOTO errorHandling

REM CREATE TDS UPDATE PACKAGES
"C:\Program Files (x86)\MSBuild\14.0\Bin\MsBuild.exe" /t:Build ".\Reactive.Nissan.Content\Nissan.TDS.01.Core\Nissan.TDS.01.Core.scproj" /p:Configuration=%1
IF ERRORLEVEL 1 GOTO errorHandling

"C:\Program Files (x86)\MSBuild\14.0\Bin\MsBuild.exe" /t:Build ".\Reactive.Nissan.Content\Nissan.TDS.02.Master\Nissan.TDS.02.Master.scproj" /p:Configuration=%1
IF ERRORLEVEL 1 GOTO errorHandling

"C:\Program Files (x86)\MSBuild\14.0\Bin\MsBuild.exe" /t:Build ".\Reactive.Nissan.Content\Nissan.TDS.03.Master.Content.AU\Nissan.TDS.03.Master.Content.AU.scproj" /p:Configuration=%1
IF ERRORLEVEL 1 GOTO errorHandling

"C:\Program Files (x86)\MSBuild\14.0\Bin\MsBuild.exe" /t:Build ".\Reactive.Nissan.Content\Nissan.TDS.04.Master.Content.NZ\Nissan.TDS.04.Master.Content.NZ.scproj" /p:Configuration=%1
IF ERRORLEVEL 1 GOTO errorHandling

REM PACK UPDATE PACKAGES INTO A SINGLE NUPKG ARTIFACT
.\packages\nuget\nuget.exe pack ".\Reactive.Nissan.Content\Nissan.TDS.Packages.nuspec" -Version %2 -Verbosity detailed -BasePath .\Reactive.Nissan.Content -OutputDirectory .\_Deployment\Packages
IF ERRORLEVEL 1 GOTO errorHandling

EXIT /b 0

:errorHandling
EXIT /b -1
