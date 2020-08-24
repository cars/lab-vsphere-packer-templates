$host.ui.RawUI.WindowTitle = "Installing 7Zip  Please wait..."
If (("$Env:PACKER_BUILDER_TYPE" -ne "vmware-iso") -and ("$Env:PACKER_BUILDER_TYPE" -ne "vsphere-iso")) {
  Write-Host "==> VMware not found, aborting tools install.."
  Write-Host "==> Found Env: ${ENV:PACKER_BUILDER_TYPE}"
  Write-Host "==> Found $Packer_Builder_Type"
  Set-Location ENV:
  gci | select name,value | Set-Content C:\temp\envvars_floppy_vmware.txt
  #return
}
Write-Host "==> Trying to find name of latest vmware tools package"
$ToolSrcPath = "http://10.0.0.48/packer/7z1900-x64.exe"

Write-Host "==> Installing 7Zip"

$7z_setup = "$($env:TEMP)\7z1900-x64.exe"
Write-Host "Downloading 7-Zip..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($ToolSrcPath, $7z_setup)

Write-Host "Installing 7-Zip..."
# $p = Start-Process -Wait -PassThru -FilePath d:\setup.exe -ArgumentList "/S /l C:\Windows\Temp\vmware_tools.log /v""/qn REBOOT=R"""
$p = Start-Process -Wait -PassThru -FilePath $7z_setup -ArgumentList "/S"

if ($p.ExitCode -eq 0) {
  Write-Host "Done."
} elseif ($p.ExitCode -eq 3010) {
  Write-Host "Done, but a reboot is necessary."
} else {
  Write-Host "7-ZIP install failed: ExitCode=$($p.ExitCode) "
  Start-Sleep 2; exit $p.ExitCode
}


