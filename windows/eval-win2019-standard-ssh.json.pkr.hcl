
source "vsphere-iso" "server_2019" {
  CPUs                 = 2
  RAM                  = 8192
  RAM_reserve_all      = true
  cluster              = "${var.vcenter_cluster}"
  communicator         = "ssh"
  convert_to_template  = "true"
  datacenter           = "${var.vcenter_datacenter}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = ["lsilogic-sas"]
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
  //iso_paths            = ["[F] Windows//17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso", "[] /usr/lib/vmware/isoimages/windows.iso"]
  iso_paths            = ["[F] Windows//17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"]  
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
  sources = ["source.vsphere-iso.server_2019"]

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    scripts           = ["script/cloudbase.ps1"]
  }

  provisioner "powershell" {
    elevated_password = "${var.defaultuserpassword}"
    elevated_user     = "${var.defaultuser}"
    scripts           = ["script/windows_update.ps1"]
  }
  
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout = "30m"
  }
  
  post-processor "manifest" {
  }
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
