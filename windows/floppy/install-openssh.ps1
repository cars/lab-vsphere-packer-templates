$host.ui.RawUI.WindowTitle = "Installing OpenSSH.  Please wait..."

Write-Output "==> Installing Client"

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0


# Install the OpenSSH Server
Write-Output "==> Installing Server"
Add-WindowsCapability -Online -LogLevel 4 -LogPath C:\temp\addcap.txt -Name OpenSSH.Server~~~~0.0.1.0

Write-Output "==> Writing Status file to temp"
Get-WindowsCapability -online -name *ssh* |select *|convertto-csv | Set-Content C:\temp\sshstat.txt

Write-Output "==> Setting up Service to run Automatically"
Start-Service sshd
# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup. 
if ( Get-NetFirewallRule -Name *ssh*) {
   Write-Output "==> Firewall Rule appears to exist"
} else {
   Write-Output "==> Firewall rule does not exist....creating...."
   # There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
   # If the firewall does not exist, create one
   New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}


# Set Powershell as default shell for openssh
#
Write-Output "==> Changing SSH Shell to powershell"
 New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
# Write-Output -NoNewLine 'Press any key to continue...'
# $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
