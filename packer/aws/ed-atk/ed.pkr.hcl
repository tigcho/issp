variable "instance_type" {}
variable "region" {}
variable "ssh_username" {}
variable "keypair_name" {}
variable "key_file" {}
variable "ami_name" {}
variable "source_ami" {}

source "amazon-ebs" "ed" {
  region = var.region
  instance_type = var.instance_type
  source_ami = var.source_ami
  ami_name = var.ami_name
  associate_public_ip_address = true
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_keypair_name = var.keypair_name
  ssh_private_key_file = var.key_file
  ssh_timeout  = "30m"

  tags = {
    Name = "ed-atk"
    Type = "Packer Build"
  }
}

build {
  sources = ["source.amazon-ebs.ed"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl gnupg",
      "curl -fsSL https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg",
      "echo 'deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free' | sudo tee /etc/apt/sources.list.d/kali.list",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kali-tools-top10"
    ]
  }
}
