$ScriptPath = Split-Path $MyInvocation.InvocationName
& "$ScriptPath\disable-windows-update.ps1"
& "$ScriptPath\install-winrm.ps1"
& "$ScriptPath\power-settings.ps1"
& "$ScriptPath\zz-start-transports.ps1"
& "$ScriptPath\install-openssh.ps1"
& "$ScriptPath\vmware.ps1"
