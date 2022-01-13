$Error.Clear()
if (-not ([string]::IsNullOrEmpty($env:WINHTTP_PROXY))) {
  Write-Host "==> Setting winhttp proxy to $($env:WINHTTP_PROXY)"
  netsh winhttp set proxy $env:WINHTTP_PROXY
} else {
  Write-Host "==> No winhttp proxy specified"
}
# This should work for Win2016+,stock 2012 doesn't have get-computerinfo cmdlet
$ProductName = (get-computerInfo).windowsProductName
if ( $ProductName -match "2016") {
  $OSVersion = 2016
} elseif ($productname -match "2019") {
  $OSVersion = 2019
}

# Silence progress bars in PowerShell, which can sometimes feed back strange
# XML data to the Packer output.
$ProgressPreference = "SilentlyContinue"
Write-Output "Enhanced logging on"
Write-Output "Starting PSWindowsUpdate Installation"


# Install PSWindowsUpdate for scriptable Windows Updates
# Check for OS version... if 2019+ Use Newer Module

if ($OSVersion -ge 2019) {
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module PSWindowsUpdate -Force
} else {
  $webDeployURL = "http://10.0.0.48/packer/PSWindowsUpdate_1.4.5.zip"
  $filePath = "C:\Temp\PSwindowsUpdate_1.4.5.zip"
  (New-Object System.Net.WebClient).DownloadFile($webDeployURL, $filePath)

  # Older versions of Powershell do not have 'Expand Archive'
  # Use Shell.Application custom object to unzip
  # https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell
  $shell = New-Object -ComObject Shell.Application
  $zipFile = $shell.NameSpace($filePath)
  $PSVersion = $PSVersionTable.PSVersion.Major
  if ($PSVersion -lt 3) {
    $destinationFolder = $shell.NameSpace("C:\Windows\system32\WindowsPowerShell\v1.0\Modules")
  }
  else {
    $destinationFolder = $shell.NameSpace("C:\Program Files\WindowsPowerShell\Modules")
  }

  $copyFlags = 0x00
  $copyFlags += 0x04 # Hide progress dialogs
  $copyFlags += 0x10 # Overwrite existing files

  $destinationFolder.CopyHere($zipFile.Items(), $copyFlags)
  # Clean up
  Remove-Item -Force -Path $filePath
}
Write-Output "Ended PSWindowsUpdate Installation"

Write-Output "Starting Windows Update Installation"

Try {
  Import-Module PSWindowsUpdate -ErrorAction Stop
}
Catch {
  Write-Error "Unable to Import PSWindowsUpdate"
  exit 1
}

if (Test-Path C:\Windows\Temp\PSWindowsUpdate.log) {
  # Save old logs
  Rename-Item -Path C:\Windows\Temp\PSWindowsUpdate.log -NewName PSWindowsUpdate-$((Get-Date).Ticks).log

  # Uncomment the line below to delete old logs instead
  #Remove-Item -Path C:\Windows\Temp\PSWindowsUpdate.log
}

try {
  if ($OSVersion -ge 2019){
#    Enable-MicrosoftUpdate
  }
  $updateCommand = { Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll --AcceptEula -IgnoreReboot | Out-File C:\Windows\Temp\PSWindowsUpdate.log }
  $TaskName = "PackerUpdate"

  $User = [Security.Principal.WindowsIdentity]::GetCurrent()
  $Scheduler = New-Object -ComObject Schedule.Service

  $Task = $Scheduler.NewTask(0)

  $RegistrationInfo = $Task.RegistrationInfo
  $RegistrationInfo.Description = $TaskName
  $RegistrationInfo.Author = $User.Name

  $Settings = $Task.Settings
  $Settings.Enabled = $True
  $Settings.StartWhenAvailable = $True
  $Settings.Hidden = $False

  $Action = $Task.Actions.Create(0)
  $Action.Path = "powershell"
  $Action.Arguments = "-Command $updateCommand"

  $Task.Principal.RunLevel = 1

  $Scheduler.Connect()
  $RootFolder = $Scheduler.GetFolder("\")
  $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, "SYSTEM", $Null, 1) | Out-Null
  $RootFolder.GetTask($TaskName).Run(0) | Out-Null

  Write-Output "The Windows Update log will be displayed below this message. No additional output indicates no updates were needed."
  do {
    Start-Sleep 1
    if ((Test-Path C:\Windows\Temp\PSWindowsUpdate.log) -and $script:reader -eq $null) {
      $script:stream = New-Object System.IO.FileStream -ArgumentList "C:\Windows\Temp\PSWindowsUpdate.log", "Open", "Read", "ReadWrite"
      $script:reader = New-Object System.IO.StreamReader $stream
    }
    if ($script:reader -ne $null) {
      $line = $Null
      do {
        $script:reader.ReadLine()
        $line = $script:reader.ReadLine()
        Write-Output $line
      } while ($line -ne $null)
    }
  } while ($Scheduler.GetRunningTasks(0) | Where-Object { $_.Name -eq $TaskName })
}
catch {
  Write-Output "Issue with installing updates "
  Write-Output $Error[-1]
  #exit 999
}
finally {
  Write-Output "In finally block"
  Write-Output $Error[-1].Message
  $RootFolder.DeleteTask($TaskName, 0)
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Scheduler) | Out-Null
  if ($script:reader -ne $null) {
    $script:reader.Close()
    $script:stream.Dispose()
  }
}
Write-Output "Ended Windows Update Installation"
Write-Output $Error[-1]
Write-Output $Error[-2]
Write-Output $Error[-3]
exit 0