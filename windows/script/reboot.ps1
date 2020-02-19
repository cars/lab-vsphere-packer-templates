$host.ui.RawUI.WindowTitle = "Rebooting VM  Please wait..."


Write-Output "==> Rebooting VM"

shutdown.exe /r /d u:2:4 /C "Packer intitiated reboot"
Write-Output "==> Shutdown initiated"