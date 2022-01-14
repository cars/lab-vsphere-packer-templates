
source "vsphere-iso" "default_win2016" {
  CPUs                 = 2
  RAM                  = 8192
  RAM_reserve_all      = true
  cluster              = "${var.vcenter_cluster}"
  communicator         = "ssh"
  convert_to_template  = "true"
  datacenter           = "${var.vcenter_datacenter}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = "lsilogic-sas"
  floppy_files         = [
                            "floppy/eval-win2016-standard/Autounattend.xml", 
                            "floppy/00-run-all-scripts.ps1", 
                            "floppy/create-evtlog.ps1", 
                            "floppy/disable-windows-update.ps1", 
                            "floppy/install-winrm.ps1", 
                            "floppy/power-settings.ps1", 
                            "floppy/zz-start-transports.ps1", 
                            "floppy/vmware.ps1", 
                            "floppy/sevenzip.ps1", 
                            "floppy/install-openssh.ps1", 
                            "floppy/send-syslogmessage.ps1", 
                            "floppy/install-openssh2016.ps1"
                          ]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "windows9_64Guest"
  host                 = "${var.vcenter_host}"
  insecure_connection  = "true"
  ip_wait_timeout      = "60m"
  iso_paths            = [
                          "[F] Windows/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO", 
                          "[] /usr/lib/vmware/isoimages/windows.iso"
                          ]
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "e1000"
  }
  notes        = "${var.vm_notes}"
  password     = "${var.vcenter_password}"
  ssh_password = "vagrant"
  ssh_timeout  = "20m"
  ssh_username = "vagrant"
  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }
  username       = "${var.vcenter_user}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.vcenter_template_name}"
}

source "vsphere-iso" "default_win2019" {
  CPUs                 = 2
  RAM                  = 8192
  RAM_reserve_all      = true
  cluster              = "${var.vcenter_cluster}"
  communicator         = "ssh"
  convert_to_template  = "true"
  datacenter           = "${var.vcenter_datacenter}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = "lsilogic-sas"
  floppy_files         = [
                          "floppy/eval-win2019-standard/autounattend.xml", 
                          "floppy/00-run-all-scripts.ps1", 
                          "floppy/create-evtlog.ps1", 
                          "floppy/disable-windows-update.ps1", 
                          "floppy/install-winrm.ps1", 
                          "floppy/power-settings.ps1", 
                          "floppy/sevenzip.ps1", 
                          "floppy/zz-start-transports.ps1", 
                          "floppy/vmware.ps1", 
                          "floppy/install-openssh.ps1"
                        ]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "windows9_64Guest"
  host                 = "${var.vcenter_host}"
  insecure_connection  = "true"
  ip_wait_timeout      = "60m"
  iso_paths            = [
                          "[F] Windows/17763.737.190906-2324.rs5_release_svc_SERVER_2019_EVAL_x64FRE_en-us_1.iso", 
                          "[] /usr/lib/vmware/isoimages/windows.iso"
                          ]
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "e1000"
  }
  notes            = "${var.vm_notes}"
  password         = "${var.vcenter_password}"
  shutdown_timeout = "20m"
  ssh_password     = "${var.defaultuserpassword}"
  ssh_timeout      = "20m"
  ssh_username     = "${var.defaultuser}"
  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }
  username       = "${var.vcenter_user}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.vcenter_template_name}"
}


build {
  sources = [
              "source.vsphere-iso.default_win2016",
              "source.vsphere-iso.default_win2019"
            ]

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    #environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "SYSLOG_SERVER=${var.syslog_server}", "SYSLOG_HOSTNAME=${var.syslog_self_hostname}", "CB_URL=${var.cloudbase_source_url}"]
    #execute_command   = "`& {'. {{ .Vars }}'; '{{ .Path }}'; exit `$LastExitCode }"
    scripts           = ["script/cloudbase.ps1"]
    skip_clean        = "true"
  }

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    #environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "SYSLOG_SERVER=${var.syslog_server}", "SYSLOG_HOSTNAME=${var.syslog_self_hostname}"]
    #execute_command   = "`& {'. {{ .Vars }}';'{{ .Path }}'; write-host `$LastExitCode; exit `$LastExitCode }"
    max_retries       = "2"
    scripts           = ["script/windows_update.ps1"]
    skip_clean        = "true"
  }

  post-processor "manifest" {
  }
}
