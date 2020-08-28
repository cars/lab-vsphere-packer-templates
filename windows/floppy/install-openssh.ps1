$host.ui.RawUI.WindowTitle = "Installing OpenSSH.  Please wait..."

if (-not (Test-PAth ENV:OPENSSH_URL)) {
   $ENV:OPENSSH_URL="http://10.0.0.48/packer/openssh-win64.zip"
}

if (-not (Test-PAth ENV:7ZIP_PATH)) {
   $ENV:7ZIP_PATH="C:\progra~1\7-zip\7z.exe"
}




$Error.clear()
# Install the OpenSSH Server
Write-Output "==> Downloading Install"

pushd  C:\temp
# Download the Zip file.... 
wget -useb  $ENV:OPENSSH_URL -Outfile openssh-win64.zip
# Unzip the file

$p = Start-Process -Wait -PassThru -FilePath $ENV:7zip_Path -ArgumentList @("x openssh-win64.zip")
# "C:\Progra~1\7-Zip\7z.exe" x openssh-win64.zip 

if ($p.ExitCode -eq 0) {
   Write-Host "Done."
 } elseif ($p.ExitCode -eq 3010) {
   Write-Host "Done, but a reboot is necessary."
 } else {
   Write-Host "Open SSH  install failed: ExitCode=$($p.ExitCode) "
   Start-Sleep 2; exit $p.ExitCode
 }
 
 
 
# CD to the  source dir
cd OpenSSH-Win64
#
Write-Output "==> Setting up Service to run Automatically"
& .\install-sshd.ps1

# Confirm the Firewall rule is configured. It should be created automatically by setup. 
if ( Get-NetFirewallRule -Name *ssh*) {
   Write-Output "==> Firewall Rule appears to exist"
} else {
   Write-Output "==> Firewall rule does not exist....creating...."
   # There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
   # If the firewall does not exist, create one
   New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

Write-Output "==> Setting up Service to run Automatically"
Set-Service -Name sshd -StartupType 'Automatic'

Write-Output "==> Starting Service"
Start-Service sshd

# Set Powershell as default shell for openssh
#
# Write-Output "==> Changing SSH Shell to powershell"
# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
# Write-Output -NoNewLine 'Press any key to continue...'
# $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
