$host.ui.RawUI.WindowTitle = "setting Up Event log for tracing.  Please wait..."

New-Eventlog -LogName application -source packer_inst

Write-EventLog -LogName Application -source packer_inst -EntryType information -eventId 1000 -Message "Eventlog source packer_inst created"
