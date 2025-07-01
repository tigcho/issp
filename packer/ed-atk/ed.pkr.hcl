variable "iso_url" {}
variable "iso_checksum" {}
variable "disk_size" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "vm_name" {}
variable "cpus" {}
variable "memory" {}
variable "headless" {}

source "virtualbox-iso" "ed" {
  iso_url           = var.iso_url
  iso_checksum      = var.iso_checksum
  disk_size         = var.disk_size
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  vm_name           = var.vm_name
  cpus              = var.cpus
  memory            = var.memory
  headless          = var.headless
  guest_os_type     = "Debian_64"
  shutdown_command  = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_wait_timeout  = "4h"
  boot_wait         = "15s"
  http_directory    = "http"

  vboxmanage   = [
    ["modifyvm", "{{ .Name }}", "--nic2", "hostonly"],
    ["modifyvm", "{{ .Name }}", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"]
  ]

  boot_command = [
  "<esc><wait>",
  "install <wait>",
  "auto=true <wait>",
  "priority=critical <wait>",
  "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
  "debian-installer/locale=de_DE <wait>",
  "console-setup/ask_detect=false <wait>",
  "keyboard-configuration/xkb-keymap=de <wait>",
  "netcfg/choose_interface=auto <wait>",
  "netcfg/get_hostname=ED-ATK <wait>",
  "netcfg/get_domain=issp.local <wait>",
  "passwd/user-fullname=Edward Wong Hau Pepelu Tivruski IV <wait>",
  "passwd/username=ed <wait>",
  "passwd/user-password=kali <wait>",
  "passwd/user-password-again=kali <wait>",
  "grub-installer/bootdev=/dev/sda <wait>",
  "<enter><wait>"
]
}

build {
  sources = [
    "source.virtualbox-iso.ed"
  ]
  
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh"
    ]
  }

  provisioner "file" {
    source      = "static-ip.sh"
    destination = "/tmp/static-ip.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/static-ip.sh",
      "/tmp/static-ip.sh"
    ]
  }
}
