
source "vsphere-iso" "centos_7" {
  CPUs                 = 2
  RAM                  = 8192
  RAM_reserve_all      = true
  boot_command         = ["<up><wait><tab> text ks=http://${var.cHTTPIP}:${var.cHTTPPORT}/${var.kickstart}<enter>"]
  cluster              = "${var.vcenter_cluster}"
  communicator         = "ssh"
  convert_to_template  = "true"
  datacenter           = "${var.vcenter_datacenter}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = ["pvscsi"]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "rhel7_64Guest"
  host                 = "${var.vcenter_host}"
  insecure_connection  = "true"
  iso_paths            = ["[F] Linuxes/CentOS/CentOS-7-x86_64-DVD-1810.iso", "[] /usr/lib/vmware/isoimages/linux.iso"]
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "vmxnet3"
  }
  notes        = "${var.vm_notes}"
  password     = "${var.vcenter_password}"
  ssh_password = "vagrant"
  ssh_username = "vagrant"
  storage {
    disk_size             = 65536
    disk_thin_provisioned = true
  }
  username       = "${var.vcenter_user}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.vcenter_template_name}"
}

build {
  sources = ["source.vsphere-iso.centos_7"]

  provisioner "shell" {
    environment_vars  = ["CLEANUP_BUILD_TOOLS=${var.cleanup_build_tools}", "DESKTOP=${var.desktop}", "UPDATE=${var.update}", "INSTALL_VAGRANT_KEY=${var.install_vagrant_key}", "SSH_USERNAME=${var.ssh_username}", "SSH_PASSWORD=${var.ssh_password}", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "ftp_proxy=${var.ftp_proxy}", "rsync_proxy=${var.rsync_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = "true"
    scripts           = ["script/update.sh"]
  }

  provisioner "shell" {
    environment_vars = ["CLEANUP_BUILD_TOOLS=${var.cleanup_build_tools}", "DESKTOP=${var.desktop}", "UPDATE=${var.update}", "INSTALL_VAGRANT_KEY=${var.install_vagrant_key}", "SSH_USERNAME=${var.ssh_username}", "SSH_PASSWORD=${var.ssh_password}", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "ftp_proxy=${var.ftp_proxy}", "rsync_proxy=${var.rsync_proxy}", "no_proxy=${var.no_proxy}", "VRA_URL=${var.VRA_URL}", "VRA_PREP_URL=${var.VRA_PREP_URL}", "LABCA_URL=${var.LABCA_URL}", "VRACA_URL=${var.VRACA_URL}", "VRALCMCERT_URL=${var.VRALCMCERT_URL}", "VRA_MGR_HOST=${var.VRA_MGR_HOST}", "VRA_APP_HOST=${var.VRA_APP_HOST}", "VRA_MGR_CRT_PRINT=${var.VRA_MGR_CRT_PRINT}", "VRA_APP_CERT_PRINT=${var.VRA_APP_CERT_PRINT}", "VRA_JAVA_INST=${var.VRA_JAVA_INST}", "VRA_CLOUD=${var.VRA_CLOUD}"]
    execute_command  = "echo 'vagrant' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    pause_before     = "10s"
    scripts          = ["script/fix-slow-dns.sh", "script/sshd.sh", "script/vagrant.sh", "script/desktop.sh", "script/vmware.sh", "script/virtualbox.sh", "script/parallels.sh", "script/motd.sh", "custom-script.sh", "script/${var.init_type}.sh", "script/cleanup.sh"]
  }

  post-processor "manifest" {
  }
}


variable "LABCA_URL:LABCA_URL" {
  type    = string
  default = "http://10.0.0.48/packer/lab-ca.pem"
}

variable "VRACA_URL:VRACA_URL" {
  type    = string
  default = "http://10.0.0.48/packer/VRA-LCM.cer"
}

variable "VRAURL" {
  type    = string
  default = "vra-01.ad.lab.lostroncos.net"
}

variable "VRA_APP_CERT_PRINT" {
  type    = string
  default = "78:86:45:19:F2:E6:52:06:BF:62:35:25:78:A1:C8:70:2F:52:C0:6F"
}

variable "VRA_APP_HOST" {
  type    = string
  default = "vra-01.ad.lab.lostroncos.net"
}

variable "VRA_APP_PORT" {
  type    = string
  default = "443"
}

variable "VRA_CLOUD" {
  type    = string
  default = "vsphere"
}

variable "VRA_JAVA_INST" {
  type    = string
  default = "true"
}

variable "VRA_MGR_CERT_PRINT" {
  type    = string
  default = "78:86:45:19:F2:E6:52:06:BF:62:35:25:78:A1:C8:70:2F:52:C0:6F"
}

variable "VRA_MGR_HOST" {
  type    = string
  default = "vra-iaas-01.ad.lab.lostroncos.net"
}

variable "VRA_MGR_PORT" {
  type    = string
  default = "443"
}

variable "VRA_PREP_URL:VRA_PREP_URL" {
  type    = string
  default = "http://10.0.0.48/packer/prepare_vra_template_linux.tar.gz"
}

variable "VRLCMCERT_URL" {
  type    = string
  default = "http://10.0.0.48/packer/vrlcm.cer"
}

variable "cHTTPIP" {
  type    = string
  default = "10.0.0.48"
}

variable "cHTTPPORT" {
  type    = string
  default = "80"
}

variable "cleanup_build_tools" {
  type    = string
  default = "false"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "desktop" {
  type    = string
  default = "false"
}

variable "disk_size" {
  type    = string
  default = "65536"
}

variable "ftp_proxy" {
  type    = string
  default = "${env("ftp_proxy")}"
}

variable "headless" {
  type    = string
  default = ""
}

variable "http_directory" {
  type    = string
  default = "kickstart/centos7"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "init_type" {
  type    = string
  default = "cloudbase"
}

variable "install_vagrant_key" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "6D44331CC4F6C506C7BBE9FEB8468FAD6C51A88CA1393CA6B8B486EA04BEC3C1"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_name" {
  type    = string
  default = "CentOS-7-x86_64-DVD-1708.iso"
}

variable "iso_path" {
  type    = string
  default = "iso"
}

variable "iso_url" {
  type    = string
  default = "http://10.0.0.48/ISO/Linuxes/Centos/CentOS-7-x86_64-DVD-1810.iso"
}

variable "kickstart" {
  type    = string
  default = "packer/packer-centos7-ks.cfg"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "rsync_proxy" {
  type    = string
  default = "${env("rsync_proxy")}"
}

variable "shutdown_command" {
  type    = string
  default = "echo 'vagrant'|sudo -S shutdown -P now"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "update" {
  type    = string
  default = "false"
}

variable "version" {
  type    = string
  default = "0.0.99"
}

variable "vm_name" {
  type    = string
  default = "centos7"
}

variable "vm_notes" {
  type    = string
  default = "The notes field"
}

variable "vmware_guest_os_type" {
  type    = string
  default = "centos-64"
}
