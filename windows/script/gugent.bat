@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

if not defined PREP_URL  set  PREP_URL=http://10.0.0.48/packer/prepare_vra_template_windows.zip

if not defined LABCA_URL set LABCA_URL=http://10.0.0.48/packer/lab-ca.pem

if not defined VRACA_URL set VRACA_URL=http://10.0.0.48/packer/VRA-LCM.cer
::::::::::::
:main
::::::::::::

echo ==^> Getting vRA PowershellScript for template prep
echo ==^> Making C:\TEMP
mkdir C:\temp

echo ==^> Checking IPConfig Info
    IPConfig /all > C:\temp\IPConfig.INFO
echo ==^> Getting LAB CA Certificate
echo ==^> Setting LABCA_PATH
set LABCA_PATH="C:\temp\labca.pem"
echo ==^> LABCA_PATH = "%LABCA_PATH%"

if exist "%SystemRoot%\_download.cmd" (
  echo ==^> Downloading "%LABCA_URL%" to "%LABCA_PATH%" with _download
  call "%SystemRoot%\_download.cmd" "%LABCA_URL%" "%LABCA_PATH%"

) else (
  echo ==^> Downloading "%LABCA_URL%" to "%LABCA_PATH%" with PShell
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%LABCA_URL%', '%LABCA_PATH%')"<NUL
)
if not exist "%LABCA_PATH%" goto exit1
echo ==^> Installing LAB CA  "%LABCA_PATH%"

    certutil -addstore -f -enterprise root "%LABCA_PATH%"


echo ==^> Getting vRA CA cert
echo ==^> Setting VRACA_PATH
set VRACA_PATH="C:\temp\vraca.cer"
echo ==^> VRACA_PATH = "%VRACA_PATH%"

if exist "%SystemRoot%\_download.cmd" (
  echo ==^> Downloading "%VRACA_URL%" to "%VRACA_PATH%" with _download
  call "%SystemRoot%\_download.cmd" "%VRACA_URL%" "%VRACA_PATH%"

) else (
  echo ==^> Downloading "%VRACA_URL%" to "%VRACA_PATH%" with PShell
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VRACA_URL%', '%VRACA_PATH%')"<NUL
)
if not exist "%VRACA_PATH%" goto exit1

echo ==^> Running  "%VRACA_PATH%"

   certutil -addstore -f -enterprise root "%VRACA_PATH%"



echo ==^> Getting vRA PowershellScript for template prep
echo ==^> Making C:\TEMP for vRA Agent
mkdir C:\temp
echo ==^> Setting Prep_PATH
set PREP_PATH="C:\temp\prepare_vra_template_windows.zip"
echo ==^> PREP_PATH = "%PREP_PATH%"
if exist "%SystemRoot%\_download.cmd" (
  echo ==^> Downloading "%PREP_URL%" to "%PREP_PATH%" with _download
  call "%SystemRoot%\_download.cmd" "%PREP_URL%" "%PREP_PATH%"

) else (
  echo ==^> Downloading "%PREP_URL%" to "%PREP_PATH%" with PShell
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PREL_URL%', '%PREP_PATH%')"<NUL

)
if not exist "%PREP_PATH%" goto exit1

echo ==^> Unzipping "%PREP_PATH%"
  pushd C:\temp
  C:\Progra~1\7-Zip\7z.exe x "%PREP_PATH%"

echo ==^> Running  "%PREP_PATH%" 

echo  powershell -NoProfile -ExecutionPolicy ByPass -command "%PREP_PATH%"<NUL
cd prepare_vra_template_windows
.\prepare_vra_template.bat

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%PREP_PATH%"
popd
ver>nul

:exit0

@ping 127.0.0.1
@ver>nul

@goto :exit

:exit1
echo ==^> In Exit1. Prep_PATH DNE? 
@ping 127.0.0.1
@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%
