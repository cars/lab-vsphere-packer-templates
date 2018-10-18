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

echo ==^> Checking IPConfig Info
    IPConfig /all > C:\temp\IPConfig.INFO
ver>nul
pushd \temp
echo ==^> Boxstarter
 powershell -Command ". { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force"<NUL

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
