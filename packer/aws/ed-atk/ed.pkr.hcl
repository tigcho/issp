variable "instance_type" {}
variable "region" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "ami_name" {}

source "amazon-ebs" "ed" {
  region          = var.region
  instance_type   = var.instance_type

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    most_recent = true
    owners = ["099720109477"] 
  }

  ami_name         = var.ami_name
  ssh_username     = "ubuntu"
  ssh_timeout     = "20m"
  communicator    = "ssh"

  user_data = <<EOF
#!/bin/bash
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
useradd -m -s /bin/bash ed
echo 'ed:kali' | chpasswd
usermod -aG sudo ed
echo 'ed ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ed
chmod 0440 /etc/sudoers.d/ed
hostnamectl set-hostname ED-ATK
echo '127.0.1.1 ED-ATK' >> /etc/hosts
EOF

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
      "sudo apt-get upgrade -y"
    ]
  }

  provisioner "shell" {
    scripts = ["scripts/install-kali-tools.sh"]
    pause_before = "30s"
  }

  provisioner "shell" {
    scripts = ["scripts/german-locale.sh"]
  }

  provisioner "shell" {
    inline = [
      "sudo reboot"
    ]
    expect_disconnect = true
  }
}
