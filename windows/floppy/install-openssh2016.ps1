$host.ui.RawUI.WindowTitle = "Installing openSSH on Windows 2016.  Please wait..."
If (("$Env:PACKER_BUILDER_TYPE" -ne "vmware-iso") -and ("$Env:PACKER_BUILDER_TYPE" -ne "vsphere-iso")) {
  Write-Host "==> VMware Builder Type not found, aborting tools install.."
  Write-Host "==> Found Env: ${ENV:PACKER_BUILDER_TYPE}"
  Write-Host "==> Found $Packer_Builder_Type"
  Set-Location ENV:
  gci | select name,value | Set-Content C:\temp\envvars_floppy_vmware.txt
  #return
}

if (Test-PAth ENV:SYSLOG_SERVER){
    $DoSysLog = $true
} else {
    $DoSyslog = $false
}
if (-not (Test-PAth ENV:OPENSSH_URL)) {
    $ENV:OPENSSH_URL="http://10.0.0.48/packer/setupssh-8.3p1-1.exe"
    #$ENV:OPENSSH_URL="http://www.mls-software.com/files/setupssh-7.2p2-1-v1.exe"
}

if (-not (Test-PAth ENV:SSHD_PASSWORD)) {
    $ENV:SSHD_PASSWORD="D@rj33l1ng" 
}

if ($DoSysLog) { Send-SyslogMessage -Message "Downloading openSSH"}
Write-Host "==> Downloading openSSH"
$ssh_setup = "${env:TEMP}\ssh_setup.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($ENV:OPENSSH_URL, $ssh_setup)
if ($DoSysLog) { Send-SyslogMessage -Message " openSSH downloaded"}

Write-Host "==> Blocking SSH port 22 on the firewall"
if ($DoSysLog) { Send-SyslogMessage -Message "Blocking SSH port 22 on the firewall"}
#netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="${ENV:ProgramFiles}\OpenSSH\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="SSHD" dir=in action=block program="${ENV:ProgramFiles}\OpenSSH\bin\cygunsrv.exe.exe" enable=yes
netsh advfirewall firewall add rule name="ssh"  dir=in action=block protocol=TCP localport=22

Write-Host "==> Starting SSH Executable Install"
if ($DoSysLog) { Send-SyslogMessage -Message "Starting SSH Executable install"}
#Start-process -FilePath $ssh_setup -ArgumentList @("/S","/passsword=${ENV:SSHD_PASSWORD}") 
& $ssh_setup "/S" "/password=${ENV:SSHD_PASSWORD}"

Write-Host "==> Pausing to let install finish"
if ($DoSysLog) { Send-SyslogMessage -Message "Pausing to let install finish"}
Start-Sleep -Seconds 45

if ($DoSysLog) { Send-SyslogMessage -Message "Checking SSH Service Status"}
$SSH_SERVICE=Get-Service -name *SSH*
if ($SSH_SERVICE.Status -ne "Running"){
    Write-Host "==> openSSHD not running continuing"
    if ($DoSysLog) { Send-SyslogMessage -Message "openSSH not running...continuing process"}
} else {
    Write-Host "==> OpenSSHD running need to stop it before proceeding... "
    if ($DoSysLog) { Send-SyslogMessage -Message "openSSH running... stopping it"}
    Stop-Service -name *ssh*
    Write-Host "==> OpenSSHD stopped..."
}
if ($DoSysLog) { Send-SyslogMessage -Message "unblocking port 22 on the firewall"}
    Write-Host "==> UnBlocking SSH port 22 on the firewall"
    netsh advfirewall firewall delete rule name="SSHD"
    netsh advfirewall firewall delete rule name="ssh"
    if ($DoSysLog) { Send-SyslogMessage -Message "Starting SSH config"}
    Write-Host "==> starting SSH Config"
    rmdir -Recurse -Force  "${ENV:PROGRAMFILES}\OpenSSH\Tmp"

    New-Item -ItemType SymbolicLink -Path "${ENV:PROGRAMFILES}\OpenSSH\tmp" -Target "${ENV:SYSTEMROOT}\Temp"
    icacls "${ENV:SYSTEMROOT}\Temp" "/grant" "${ENV:USERNAME}:(OI)(CI)F"

    if (-not (Test-Path ($ENV:USERPROFILE+"\.ssh"))) {
        mkdir ($ENV:USERPROFILE+"\.ssh")
    }
    if ($DoSysLog) { Send-SyslogMessage -Message "Adding missing environment variables to %USERPROFILE%\.ssh\environment"}
    Write-Host "==> Adding missing environment variables to %USERPROFILE%\.ssh\environment"
    $ENV:SSHENV=($ENV:USERPROFILE+ "\.ssh\environment")
    $ENV_LINES ="APPDATA=${ENV:SYSTEMDRIVE}\Users\${ENV:USERNAME}\AppData\Roaming"
    $ENV_LINES +="COMMONPROGRAMFILES=${ENV:SYSTEMDRIVE}\Program Files\Common Files"
    $ENV_LINES +="LOCALAPPDATA=${ENV:SYSTEMDRIVE}\Users\${ENV:USERNAME}\AppData\Local"
    $ENV_LINES +="PROGRAMDATA=${ENV:SYSTEMDRIVE}\ProgramData"
    $ENV_LINES +="PROGRAMFILES=${ENV:SYSTEMDRIVE}\Program Files"
    $ENV_LINES +="PSMODULEPATH=${ENV:SYSTEMDRIVE}\Windows\system32\WindowsPowerShell\v1.0\Modules\"
    $ENV_LINES +="PUBLIC=${ENV:SYSTEMDRIVE}\Users\Public"
    $ENV_LINES +="SESSIONNAME=Console"
    $ENV_LINES +="TEMP=${ENV:SYSTEMDRIVE}\Users\${ENV:USERNAME}\AppData\Local\Temp"
    $ENV_LINES +="TMP=${ENV:SYSTEMDRIVE}\Users\${ENV:USERNAME}\AppData\Local\Temp"
    if (Test-PAth "${ENV:%SystemDrive}\Program Files (x86)" ){
        $ENV_LINES +="COMMONPROGRAMFILES^(X86^)={${ENV:SystemDrive}\Program Files ^(x86^)\Common Files"
        $ENV_LINES +="COMMONPROGRAMW6432=${ENV:SystemDrive}\Program Files\Common Files"
        $ENV_LINES +="PROGRAMFILES^(X86^)=${ENV:SystemDrive}\Program Files ^(x86^)"
        $ENV_LINES +="PROGRAMW6432=${ENV:SystemDrive}\Program Files"
    }
    $ENV_LINES | Set-Content $ENV:SSHENV
    if ($DoSysLog) { Send-SyslogMessage -Message "Finsihed updating OpenSSH env info"}
    Write-Host "==> Finished updating OpenSSHd environment info"
    if ($DoSysLog) { Send-SyslogMessage -Message "setting openssh config to be less strict"}
    Write-Host "==> Fixing OpenSSHd configuration to be less strict"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace 'StrictModes yes', 'StrictModes no' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace '#UseDNS yes', 'UseDNS no' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config") | Foreach-Object { $_ -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\sshd_config"
    Write-host "==> Done modifying ssh config to be less strict"
    if ($DoSysLog) { Send-SyslogMessage -Message "done modifying openssh config to be less strict"}
    
    if ($DoSysLog) { Send-SyslogMessage -Message "opening ssh port 22"}
    Write-Host "==> Opening SSH port 22 on the firewall"
    netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="${ENV:ProgramFiles}\OpenSSH\cygrunsrv.exe" enable=yes
    netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22
    Write-Host "==> Done Opening SSH port 22 on the firewall"

    Write-host "==> Ensuring user ${ENV:USERNAME} can login by modifying file attributes"
    if ($DoSysLog) { Send-SyslogMessage -Message "ensuring ${ENV:USERNAME} can login by modifying file attributes"}
    icacls "${ENV:USERPROFILE}" "/grant" "${ENV:USERNAME}:(OI)(CI)F"
    icacls "${ENV:ProgramFiles}\OpenSSH\bin" "/grant" "${ENV:USERNAME}:(OI)RX"
    icacls "${ENV:ProgramFiles}\OpenSSH\usr\sbin" "/grant"  "${ENV:USERNAME}:(OI)RX"
    if ($DoSysLog) { Send-SyslogMessage -Message "setting user ${ENV:USERNAME} home dir to their windows profile dir"}
    Write-Host "==> Setting user ${ENV:USERNAME}`s home directories to their windows profile directory"
    (Get-Content "${ENV:ProgramFiles}\OpenSSH\etc\passwd") | Foreach-Object { $_ -replace '/home/(\w+)', '/cygdrive/c/Users/$1' } | Set-Content "${ENV:ProgramFiles}\OpenSSH\etc\passwd"
    
    Write-Host "==> Re-Starting OpenSSHd Windows 2016"
    
    #Start-service openSSHD
    
    
    Write-Host "==> Done Installing OpenSSH on Windows 2016"
    if ($DoSysLog) { Send-SyslogMessage -Message "Done installing Openssh on Windows 2016"}



