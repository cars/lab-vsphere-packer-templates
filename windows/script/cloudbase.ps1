#$host.ui.RawUI.WindowTitle = "Installing CloudBase.  Please wait..."

  function Send-SyslogMessage {

        [CMDLetBinding()]
        Param(
          [Parameter(mandatory=$true)] [String] $Server,
          [Parameter(mandatory=$true)] [String] $Message,
          [String] $Hostname,
          [String] $Timestamp,
          [int] $UDPPort = 514
        )
    
        # Create a UDP Client Object
        $UDPCLient = New-Object System.Net.Sockets.UdpClient
        $UDPCLient.Connect($Server, $UDPPort)
    
        # Evaluate the facility and severity based on the enum types
        $Facility_Number = 23
        $Severity_Number = 5
    
        # Calculate the priority
        $Priority = ($Facility_Number * 8) + $Severity_Number
        
    
        # If no hostname parameter specified, then set it
        if (($Hostname -eq "") -or ($Hostname -eq $null)){
          $Hostname = Hostname
        }
    
        # I the hostname hasn't been specified, then we will use the current date and time
        if (($Timestamp -eq "") -or ($Timestamp -eq $null)){
          $Timestamp = Get-Date -Format "yyyy:MM:dd:-HH:mm:ss zzz"
        }
    
        # Assemble the full syslog formatted message
        $FullSyslogMessage = "<{0}>{1} {2} {3}" -f $Priority, $Timestamp, $Hostname, $Message
    
        # create an ASCII Encoding object
        $Encoding = [System.Text.Encoding]::ASCII
    
        # Convert into byte array representation
        $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)
    
        # If the message is too long, shorten it
        if ($ByteSyslogMessage.Length -gt 1024){
            $ByteSyslogMessage = $ByteSyslogMessage.SubString(0, 1024)
        }
    
        # Send the Message
        $UDPCLient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)
    
    }
Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "Starting Cloudbase Install"
Write-Output "==> Installing Cloudbase"

if (Test-Path ENV:SYSLOG_SERVER) {
  $SendSyslog = $true
} else {
  $SendSyslog = $false
}

if (-not $ENV:CB_URL) {
    Write-host "==> Cloudbase URL not set.....setting"
    Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "Cloudbase URL not set"
    if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|Cloudbase URL Not Set"}
    $ENV:CB_URL="https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
    Write-host "==> done setting Cloudbase URL to ${ENV:CB_URL}"
    Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "done setting Cloudbase URL to ${ENV:CB_URL}"
    if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|done setting Cloudbase URL to ${ENV:CB_URL}"}
} else {
    Write-Host "CB URL Set previously to ${ENV:CB_URL}"
    if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|CB URL previously set to  ${ENV:CB_URL}"}
}


if (Test-PAth C:\temp) {
  #nop
} else {
  mdkir c:\temp
}

$cb_setup = "C:\temp\cb_setup.msi"
Write-Host "==> Preparing to download Cloudbase....."
Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "Preparing to d/l cloudbase source"
if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|Preparing to DL Cloudbase source"}
#$wc = New-Object System.Net.WebClient
#Write-Host "==> Created WebClient"
#$wc.DownloadFile($ENV:CB_URL, $cb_setup)
wget -useb $ENV:CB_URL -outfile $cb_setup 
Write-Host "==> Done Downloading Cloudbase..."
Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "done d/ling cloudbase source"
if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|done downloading source"}
Write-Host "==> Starting Cloudbase install..."
Write-EventLog -LogName application -source packer_inst -eventId 1000 -Message "Starting Cloudbase install"
if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|starting cloudbase install"}

$p = Start-Process  -Wait -PassThru -FilePath msiexec -ArgumentList "/i $cb_setup /qn /l*v C:\temp\CB_SETUP.Txt"

if ($p.ExitCode -eq 0) {
    Write-Host "Done."
   if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|Install Done"}

  } elseif ($p.ExitCode -eq 3010) {
    Write-Host "Done, but a reboot is necessary."
    if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|Install done reboot necessary"}

  } else {
    Write-Host "CLoud Base install exited with ExitCode=${p.ExitCode}, Log=C:\temp\cb_setup.txt"
    if ($SendSyslog) {Send-SyslogMessage -Server ${ENV:SYSLOG_SERVER} -Message "PACKER_BLD|Cloudbase install exited with Exitcode${p.exitcode}"}

    Start-Sleep 15; 
    #exit $p.ExitCode
  }
  exit 0
  
