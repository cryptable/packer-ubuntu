# VM Section
# ----------

variable "vm_name" {
  type    = string
  default = "ubuntu"
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "ram_size" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "iso_checksum" {
  type    = string
  default = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

# This is different and configured in the variable templates
variable "eth_point" {
  type    = string
  default = "ens18"
}

# VMware Section
# --------------

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "output_directory" {
  type    = string
  default = "output-vmware"
}

# Proxmox Section
# ---------------

variable "pve_username" {
  type    = string
  default = "root"
}

variable "pve_token" {
  type    = string
  default = "secret"
}

variable "pve_url" {
  type    = string
  default = "https://127.0.0.1:8006/api2/json"
}

variable "iso_file"  {
  type    = string
  default = "local:iso/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "vm_id" {
  type    = string
  default = "9000"
}

# Ubuntu Section
# --------------

variable "username" {
  type    = string
  default = "ubuntu"  
}

variable "password" {
  type    = string
  default = "Ubuntu20.04"  
}

variable "hostname" {
  type    = string
  default = "ubuntu"
}

variable "salt" {
  type    = string
  default = "0A1675EF"
}

# Vagrant Section
# ---------------

variable "vagrant_token" {
  type    = string
  default = "<Atlas token>"
}

variable "vagrant_version" {
  type    = string
  default = "0.0.0"
}

# VMWARE image section
# --------------------

source "vmware-iso" "ubuntu" {
  boot_command         = [
    "<wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    "<bs><bs><bs><bs><wait>",
    " autoinstall<wait5>",
    " ds=nocloud-net<wait5>",
    ";s=http://<wait5>{{.HTTPIP}}<wait5>:{{.HTTPPort}}/<wait5>",
    " hostname=temporary",
    " ---<wait5>",
    "<enter><wait5>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./http/vmware/linux/ubuntu/20.04"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo 'vagrant' | sudo -S -E shutdown -P now"
  ssh_timeout          = "10m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "ubuntu-64"
  output_directory     = "${var.output_directory}"
  format = "ova"
}

# Proxmox image section
# ---------------------

source "proxmox-iso" "ubuntu" {
  proxmox_url = "${var.pve_url}"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node =  "pve"
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_file = "${var.iso_file}"
  insecure_skip_tls_verify = true
  boot_command         = [
    "<wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    "<bs><bs><bs><bs><wait>",
    " autoinstall",
    " ds=nocloud-net",
    ";s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    " hostname=temporary",
    " ---",
    "<enter>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cores                = "${var.cpu}"
  http_directory       = "./http/proxmox/linux/ubuntu/20.04"
  memory               = "${var.ram_size}"
  ssh_timeout          = "30m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  vm_id                = "${var.vm_id}"
  os        = "l26"
  network_adapters {
    model = "e1000"
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-pci"
  disks {
    type = "scsi"
    disk_size  = "${var.disk_size}"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm-thin"
    format = "raw"
  }
  template_name = "ubuntu-template"
  template_description = "Ubuntu 20.04 template to build Ubuntu server"
}

source "null" "vagrant" {
  communicator = "none"
}

build {
  sources = [
    "source.vmware-iso.ubuntu",
    "source.proxmox-iso.ubuntu",
    "source.null.vagrant"
  ]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./scripts/update.sh", 
      "./scripts/cleanup.sh",
      "./scripts/harden.sh",
    ]
    only = [ 
      "vmware-iso.ubuntu", 
      "proxmox-iso.ubuntu" 
    ]
  }

  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/disk-s001.vmdk",
        "output-vmware/disk-s002.vmdk",
        "output-vmware/disk-s003.vmdk",
        "output-vmware/disk.vmdk",
        "output-vmware/ubuntu-template.nvram",
        "output-vmware/ubuntu-template.vmsd",
        "output-vmware/ubuntu-template.vmx",
        "output-vmware/ubuntu-template.vmxf"
      ]
      only = [ 
        "vmware-iso.ubuntu", 
        "null.vagrant" 
      ]
    }
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "vmware"
      output = "output-vmware/packer_ubuntu_vmware.box"
      only = [ 
        "vmware-iso.ubuntu", 
        "null.vagrant" 
      ]
    }
  }
  post-processors {  
    post-processor "artifice" {
      files = [
        "output-vmware/packer_ubuntu_vmware.box"
      ]
      only = [ 
        "null.vagrant"
      ]
    }
    post-processor "vagrant-cloud" {
      access_token = "${var.vagrant_token}"
      box_tag      = "cryptable/ubuntu2004"
      version      = "${var.vagrant_version}"
      version_description = "Empty Ubuntu 20.04 Linux"
      only = [ 
        "null.vagrant"
      ]
    }
  } 
}
