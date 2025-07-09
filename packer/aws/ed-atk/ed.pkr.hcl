variable "instance_type" {}
variable "region" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "ami_name" {}
variable "source_ami" {}

source "amazon-ebs" "ed" {
  region        = var.region
  instance_type = var.instance_type

  source_ami = var.source_ami

  ami_name                    = var.ami_name
  associate_public_ip_address = true

  communicator   = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"

  tags = {
    Name        = "ed-atk"
    Type        = "Packer Build"
  }
}

build {
  sources = ["source.amazon-ebs.jet"]

  provisioner "shell" {
    inline = [
      "echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' | sudo tee /etc/apt/sources.list.d/kali.list",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED444FF07D8D0BF6",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kali-linux-default"
    ]
  } 
}
