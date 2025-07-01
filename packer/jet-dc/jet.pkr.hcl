variable "cpus" {}
variable "memory" {}
variable "disk_size" {}
variable "winrm_username" {}
variable "winrm_password" {}
variable "vm_name" {}
variable "headless" {}
variable "iso_url" {}
variable "iso_checksum" {}

source "virtualbox-iso" "jet" {
  floppy_files         = ["scripts/autounattend.xml"]
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum 
  winrm_username       = var.winrm_username
  winrm_password       = var.winrm_password
  vm_name              = var.vm_name
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  headless             = var.headless
  winrm_port           = 5985
  winrm_use_ssl        = false
  winrm_insecure       = true
  guest_additions_mode = "disable"
  winrm_timeout        = "4h"
  communicator         = "winrm"
  guest_os_type        = "Windows2025_64"
  boot_wait            = "15s"
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""

  vboxmanage   = [
    ["modifyvm", "{{ .Name }}", "--nic2", "hostonly"],
    ["modifyvm", "{{ .Name }}", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"]
  ]
}

build {
  sources = ["source.virtualbox-iso.jet"]

  provisioner "powershell" {
    scripts = ["scripts/guest-adds.ps1"]
    pause_before = "30s"
  }

  provisioner "powershell" {
    scripts = ["scripts/static-ip.ps1"]
    pause_before = "30s"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }
}
