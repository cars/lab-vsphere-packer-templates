@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

if not defined CB_URL set CB_URL=https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi

if not defined PREP_URL  set  PREP_URL=http://10.0.0.48/packer/prepare_vra_template_windows.zip

if not defined LABCA_URL set LABCA_URL=http://10.0.0.48/packer/lab-ca.pem

if not defined VRACA_URL set VRACA_URL=http://10.0.0.48/packer/VRA-LCM.cer
::::::::::::
:main
::::::::::::

echo ==^> Getting CloudbaseInitSetup_Stable_x64
echo ==^> Using "%CB_URL%" for source path

echo ==^> Making C:\TEMP
set CB_PATH=C:\TEMP\CloudBase.MSI
echo ==^> CB_PATH = "%CB_PATH%"



echo ==^> Checking IPConfig Info
    IPConfig /all > C:\temp\IPConfig.INFO
ver>nul
pushd \temp
echo ==^> CloudBase Install 

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%CB_URL%', '%CB_PATH%')"<NUL

C:\windows\system32\msiexec /i %CB_PATH% /qn /l*v c:\temp\CB_setup.txt

popd
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
