#$host.ui.RawUI.WindowTitle = "Installing CloudBase.  Please wait..."


Write-Output "==> Installing Cloudbase"


if (-not $ENV:CB_URL) {
    Write-host "==> Cloudbase URL not set.....setting"
    $ENV:CB_URL="https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
    Write-host "==> done setting Cloudbase URL to ${ENV:CB_URL}"
} else {
    Write-Host "CB URL Set previously to ${ENV:CB_URL}"
}


if (Test-PAth C:\temp) {
  #nop
} else {
  mdkir c:\temp
}

$cb_setup = "$($env:TEMP)\cb_setup.msi"
Write-Host "==> Preparing to download Cloudbase....."
$wc = New-Object System.Net.WebClient
Write-Host "==> Created WebClient"
$wc.DownloadFile($ENV:CB_URL, $cb_setup)
Write-Host "==> Done Downloading Cloudbase..."

Write-Host "==> Starting Cloudbase install..."
#C:\windows\system32\msiexec /i %CB_PATH% /qn /l*v c:\temp\CB_setup.txt
$p = Start-Process  -Wait -PassThru -FilePath msiexec -ArgumentList "/i $cb_setup /qn /l*v C:\temp\CB_SETUP.Txt"

if ($p.ExitCode -eq 0) {
    Write-Host "Done."
  } elseif ($p.ExitCode -eq 3010) {
    Write-Host "Done, but a reboot is necessary."
  } else {
    Write-Host "CLoud Base install exited with ExitCode=$($p.ExitCode), Log=C:\temp\cb_setup.txt"
    Start-Sleep 15; 
    #exit $p.ExitCode
  }
  exit 0
  
