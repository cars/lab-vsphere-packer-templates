
variable "cloudbase_source_url" {
  type    = string
  default = "http://10.0.0.48/packer/cloudbaseinit.msi"
}

variable "cm" {
  type    = string
  default = "nocm"
}

variable "cm_version" {
  type    = string
  default = ""
}

variable "defaultuser" {
  type    = string
  default = "vagrant"
}

variable "defaultuserpassword" {
  type    = string
  default = "vagrant"
}

variable "disk_size" {
  type    = string
  default = "40960"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "init_type" {
  type    = string
  default = "cloudbase"
}

variable "iso_checksum" {
  type    = string
  default = "772700802951b36c8cb26a61c040b9a8dc3816a3"
}

variable "iso_url" {
  type    = string
  default = "http://care.dlservice.microsoft.com/dl/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c 'Packer Shutdown'"
}

variable "syslog_log_prefix" {
  type    = string
  default = "PACKER_BLD"
}

variable "syslog_self_hostname" {
  type    = string
  default = "packer_bld"
}

variable "syslog_server" {
  type    = string
  default = "10.0.0.16"
}

variable "update" {
  type    = string
  default = "true"
}

variable "vcenter" {
  type    = string
  default = "vcenter.example.com"
}

variable "vcenter_cluster" {
  type    = string
  default = "esx-cluster-01"
}

variable "vcenter_datacenter" {
  type    = string
  default = "Datacenter"
}

variable "vcenter_datastore" {
  type    = string
  default = "esx-datastore-01"
}

variable "vcenter_folder" {
  type    = string
  default = "VMs"
}

variable "vcenter_host" {
  type    = string
  default = "esx-01.example.com"
}

variable "vcenter_network" {
  type    = string
  default = "VM Network"
}

variable "vcenter_password" {
  type    = string
  default = "N0tMyR3@lP@ssw0rd"
}

variable "vcenter_server" {
  type    = string
  default = "vcenter.example.com"
}

variable "vcenter_template_name" {
  type    = string
  default = "eval-win2016-standard-ssh"
}

variable "vcenter_user" {
  type    = string
  default = "TBD"
}

variable "version" {
  type    = string
  default = "0.1.0"
}

variable "vm_notes" {
  type    = string
  default = "The notes field"
}

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
  floppy_files         = ["floppy/eval-win2016-standard/Autounattend.xml", "floppy/00-run-all-scripts.ps1", "floppy/create-evtlog.ps1", "floppy/disable-windows-update.ps1", "floppy/install-winrm.ps1", "floppy/power-settings.ps1", "floppy/zz-start-transports.ps1", "floppy/vmware.ps1", "floppy/sevenzip.ps1", "floppy/install-openssh.ps1", "floppy/send-syslogmessage.ps1", "floppy/install-openssh2016.ps1"]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "windows9_64Guest"
  host                 = "${var.vcenter_host}"
  insecure_connection  = "true"
  ip_wait_timeout      = "60m"
  iso_paths            = ["[F] Windows/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO", "[] /usr/lib/vmware/isoimages/windows.iso"]
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

build {
  sources = ["source.vsphere-iso.default_win2016"]

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "SYSLOG_SERVER=${var.syslog_server}", "SYSLOG_HOSTNAME=${var.syslog_self_hostname}", "CB_URL=${var.cloudbase_source_url}"]
    execute_command   = "`& {'. {{ .Vars }}'; '{{ .Path }}'; exit `$LastExitCode }"
    scripts           = ["script/cloudbase.ps1"]
    skip_clean        = "true"
  }

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    environment_vars  = ["CM=${var.cm}", "CM_VERSION=${var.cm_version}", "SYSLOG_SERVER=${var.syslog_server}", "SYSLOG_HOSTNAME=${var.syslog_self_hostname}"]
    execute_command   = "`& {'. {{ .Vars }}';'{{ .Path }}'; write-host `$LastExitCode; exit `$LastExitCode }"
    max_retries       = "2"
    scripts           = ["script/windows_update.ps1"]
    skip_clean        = "true"
  }

  post-processor "manifest" {
  }
}
