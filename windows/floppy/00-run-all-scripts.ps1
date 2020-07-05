$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName

if (Test-PAth C:\temp) {
    Write-Host "C:\temp exists already"
} else {
    mkdir C:\temp
}

$ScriptPath = Split-Path $MyInvocation.InvocationName
& "$ScriptPath\disable-windows-update.ps1"
& "$ScriptPath\install-winrm.ps1"
& "$ScriptPath\power-settings.ps1"
& "$ScriptPath\zz-start-transports.ps1"
if ($OSVersion -match "2019") {
    & "$ScriptPath\install-openssh.ps1"
} else { 
    & "$ScriptPath\install-openssh2016.ps1"
}
& "$ScriptPath\vmware.ps1"




