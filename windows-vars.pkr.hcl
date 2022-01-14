
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
