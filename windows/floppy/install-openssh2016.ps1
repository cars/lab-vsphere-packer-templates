$host.ui.RawUI.WindowTitle = "Installing openSSH on Windows 2016.  Please wait..."
If (("$Env:PACKER_BUILDER_TYPE" -ne "vmware-iso") -and ("$Env:PACKER_BUILDER_TYPE" -ne "vsphere-iso")) {
  Write-Host "==> VMware Builder Type not found, aborting tools install.."
  Write-Host "==> Found Env: ${ENV:PACKER_BUILDER_TYPE}"
  Write-Host "==> Found $Packer_Builder_Type"
  Set-Location ENV:
  gci | select name,value | Set-Content C:\temp\envvars_floppy_vmware.txt
  #return
}

if (-not (Test-PAth ENV:OPENSSH_URL)) {
    $ENV:OPENSSH_URL="http://www.mls-software.com/files/setupssh-7.2p2-1-v1.exe"
}

if (-not (Test-PAth ENV:SSHD_PASSWORD)) {
    $ENV:SSHD_PASSWORD="D@rj33l1ng"
}

Write-Host "==> Downloading openSSH"
$ssh_setup = "$($env:TEMP)\ssh_setup.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($ENV:OPENSSH_URL, $ssh_setup)

Write-Host "==> Blocking SSH port 22 on the firewall"
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="${ENV:ProgramFiles}\OpenSSH\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh"  dir=in action=block protocol=TCP localport=22

Write-Host "==> Starting Executable Install"
# &$ssh_setup /s /port=22 /privsep=1 /password=$ENV:SSHD_PASSWORD
$install = Start-process -FilePath $ssh_setup -ArgumentList @('/S','/port=22','/privsep=1',"/passsword=${ENV:SSH_PASSWORD}") -Verb Open


Write-Host "==> Pausing to let install finish"
Start-Sleep -Seconds 45

$SSH_SERVICE=Get-Service OpenSSHd
if ($SSH_SERVICE.Status -ne "Running"){
    Write-Host "==> openSSHD not running continuing"
    # nop
    #ssh_not_running();
} else {
    Write-Host "==> OpenSSHD running need to stop it before proceeding... "
    Stop-Service -name OpenSSHd
    Write-Host "==> OpenSSHD stopped..."
}

#function ssh_not_running{
    Write-Host "==> UnBlocking SSH port 22 on the firewall"
    netsh advfirewall firewall delete rule name="SSHD"
    netsh advfirewall firewall delete rule name="ssh"

    Write-Host "==> starting SSH Config"
    rmdir -Recurse -Force  "${ENV:PROGRAMFILES}\OpenSSH\Tmp"

    New-Item -ItemType SymbolicLink -Path "${ENV:PROGRAMFILES}\OpenSSH\tmp" -Target "${ENV:SYSTEMROOT}\Temp"
    icacls "${ENV:SYSTEMROOT}\Temp" "/grant" "${ENV:USERNAME}:(OI)(CI)F"

    if (-not (Test-Path ($ENV:USERPROFILE+"\.ssh"))) {
        mkdir ($ENV:USERPROFILE+"\.ssh")
    }
    Write-Host "==> Adding missing environment variables to %USERPROFILE%\.ssh\environment"
    $ENV:SSHENV=($ENV:USERPROFILE+ "\.ssh\environment")
    $ENV_LINES ="APPDATA=${ENV:SYSTEMDRIVE}\Users\${ENV:USERNAME}\AppData\Roaming"
    $ENV_LINES +="COMMONPROGRAMFILES=${ENV:SYSTEMDRIVE}\Program Files\Common Files"
    $ENV_LINES +="LOCALAPPDATA=${ENV:SYSTEMDRIVE}\Users\%USERNAME%\AppData\Local"
    $ENV_LINES +="PROGRAMDATA=${ENV:SYSTEMDRIVE}\ProgramData"
    $ENV_LINES +="PROGRAMFILES=${ENV:SYSTEMDRIVE}\Program Files"
    $ENV_LINES +="PSMODULEPATH=${ENV:SYSTEMDRIVE}\Windows\system32\WindowsPowerShell\v1.0\Modules\"
    $ENV_LINES +="PUBLIC=${ENV:SYSTEMDRIVE}\Users\Public"
    $ENV_LINES +="SESSIONNAME=Console"
    $ENV_LINES +="TEMP=${ENV:SYSTEMDRIVE}\Users\%USERNAME%\AppData\Local\Temp"
    $ENV_LINES +="TMP=${ENV:SYSTEMDRIVE}\Users\%USERNAME%\AppData\Local\Temp"
    if (Test-PAth "${ENV:%SystemDrive}\Program Files (x86)" ){
        $ENV_LINES +="COMMONPROGRAMFILES^(X86^)={${ENV:SystemDrive}\Program Files ^(x86^)\Common Files"
        $ENV_LINES +="COMMONPROGRAMW6432=${ENV:SystemDrive}\Program Files\Common Files"
        $ENV_LINES +="PROGRAMFILES^(X86^)=${ENV:SystemDrive}\Program Files ^(x86^)"
        $ENV_LINES +="PROGRAMW6432=${ENV:SystemDrive}\Program Files"
    }
    $ENV_LINES | Set-Content $ENV:SSHENV
    Write-Host "==> Finished updating OpenSSHd environment info"
    Write-Host "==> Fixing OpenSSHd configuration to be less strict"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace 'StrictModes yes', 'StrictModes no' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#UseDNS yes', 'UseDNS no' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    Write-host "==> Done modifying ssh config to be less strict"
    
    Write-Host "==> Opening SSH port 22 on the firewall"
    netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="${ENV:ProgramFiles}\OpenSSH\usr\sbin\sshd.exe" enable=yes
    netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22
    Write-Host "==> Done Opening SSH port 22 on the firewall"

    Write-host "==> Ensuring user ${ENV:USERNAME} can login by modifying file attributes"

    icacls "${ENV:USERPROFILE}" "/grant" "${ENV:USERNAME}:(OI)(CI)F"
    icacls "${ENV:ProgramFiles}\OpenSSH\bin" "/grant" "${ENV:USERNAME}:(OI)RX"
    icacls "${ENV:ProgramFiles}\OpenSSH\usr\sbin" "/grant"  "${ENV:USERNAME}:(OI)RX"

    Write-Host "==> Setting user ${ENV:USERNAME}`s home directories to their windows profile directory"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\passwd") | Foreach-Object { $_ -replace '/home/(\w+)', '/cygdrive/c/Users/$1' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\passwd"


    Write-Host "==> Done Installing OpenSSH om Windows 2016"

#}


