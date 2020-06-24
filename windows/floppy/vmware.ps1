$host.ui.RawUI.WindowTitle = "Installing VMware Tools.  Please wait..."
If (("$Env:PACKER_BUILDER_TYPE" -ne "vmware-iso") -and ("$Env:PACKER_BUILDER_TYPE" -ne "vsphere-iso")) {
  Write-Host "==> VMware not found, aborting tools install.."
  Write-Host "==> Found Env: ${ENV:PACKER_BUILDER_TYPE}"
  Write-Host "==> Found $Packer_Builder_Type"
  Set-Location ENV:
  gci | select name,value | Set-Content C:\temp\envvars_floppy_vmware.txt
  #return
}


Write-Host "==> Trying to find name of latest vmware tools package"
$toolsSrcPath = "https://packages.vmware.com/tools/releases/latest/windows/x64/"
$dirList = wget $toolsSrcPath -UseBasicParsing
$exeName = ($dirlist.content.split(">")| ? {$_ -match "exe"}).split("`"")[1]
Write-Host "==> Got $exeName for latest tools exe"

Write-Host "==> Installing VMware tools"
$url = "https://packages.vmware.com/tools/releases/latest/windows/x64/$exeName"
$vmware_setup = "$($env:TEMP)\vmware_setup.exe"
Write-Host "Downloading VMware Tools..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $vmware_setup)

Write-Host "Installing VMWare Tools..."
# $p = Start-Process -Wait -PassThru -FilePath d:\setup.exe -ArgumentList "/S /l C:\Windows\Temp\vmware_tools.log /v""/qn REBOOT=R"""
$p = Start-Process -Wait -PassThru -FilePath $vmware_setup -ArgumentList "/S /l C:\Windows\Temp\vmware_tools.log /v""/qn REBOOT=R"""

if ($p.ExitCode -eq 0) {
  Write-Host "Done."
} elseif ($p.ExitCode -eq 3010) {
  Write-Host "Done, but a reboot is necessary."
} else {
  Write-Host "VMWare Tools install failed: ExitCode=$($p.ExitCode), Log=C:\Windows\Temp\vmware_tools.log"
  Start-Sleep 2; exit $p.ExitCode
}

