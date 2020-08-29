$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

# Set Syslog env variable if we want other scripts here 
$ENV:SYSLOG_SERVER="10.0.0.16"

$ScriptPath = Split-Path $MyInvocation.InvocationName

if (TEST-PATH ENV:SYSLOG_SERVER){
    Write-Host "sourcing syslog function"
    . $ScriptPath\Send-SyslogMessage.ps1
    Start-Sleep -Seconds 45
}

if (Test-PAth C:\temp) {
    Write-Host "C:\temp exists already"
} else {
    mkdir C:\temp
}

Write-Host "Running create eventlog"
& "$ScriptPath\create-evtlog.ps1"
Write-Host "Running disable windows update"
& "$ScriptPath\disable-windows-update.ps1"
Write-Host "Running install winrm"
& "$ScriptPath\install-winrm.ps1"
Write-Host "Running power settingss script"
& "$ScriptPath\power-settings.ps1"
Write-Host "Running start transports"
& "$ScriptPath\zz-start-transports.ps1"
Write-Host "Calling Install sevenzip"
& "$ScriptPath\sevenzip.ps1"
if ($OSVersion -match "2019") {
    Write-Host "Running Install openssh for 2019"
    & "$ScriptPath\install-openssh.ps1"
} else { 
    Write-Host "Running Install openssh for 2016"    
Stagin    #& "$ScriptPath\install-openssh2016.ps1"
    & "$ScriptPath\install-openssh.ps1"
}
Write-Host "Running Install vmtools"
& "$ScriptPath\vmware.ps1"
if ($OSVersion -match "2016") {
    Restart-Computer
}




