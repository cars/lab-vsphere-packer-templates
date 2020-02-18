$host.ui.RawUI.WindowTitle = "Installing OpenSSH.  Please wait..."


Write-Output "==> Installing Cloudbase"


@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

#if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

if (-not $ENV:CB_URL) {
    $ENV:CB_URL="https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
} else {
    Write-Host "CB URL Set previously"
}




$cb_setup = "$($env:TEMP)\cb_setup.exe"
Write-Host "Downloading Cloudbase..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $cb_setup)

$p = Start-Process  -Wait -PassThru -FilePath $cb_setup -ArgumentList "/qn /l*v c:\temp\CB_setup.txt"

if ($p.ExitCode -eq 0) {
    Write-Host "Done."
  } elseif ($p.ExitCode -eq 3010) {
    Write-Host "Done, but a reboot is necessary."
  } else {
    Write-Host "VMWare Tools install failed: ExitCode=$($p.ExitCode), Log=C:\Windows\Temp\vmware_tools.log"
    Start-Sleep 2; exit $p.ExitCode
  }
  
  