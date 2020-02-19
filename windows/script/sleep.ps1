#$host.ui.RawUI.WindowTitle = "Installing CloudBase.  Please wait..."


Write-Output "==> Sleeping"


if (-not $ENV:SLEEPTIME) {
    Write-host "==> SleepTime not set.....setting to default 120 seconds"
    $ENV:SLEEPTIME=120
    Write-host "==> done setting Cloudbase URL to ${ENV:CB_URL}"
} else {
    Write-Host "SleepTime set to  ${ENV:SLEEPTIME}"
}


Start-Sleep $ENV:SLEEPTIME