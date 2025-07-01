variable "instance_type" {}
variable "region" {}
variable "winrm_username" {}
variable "winrm_password" {}
variable "ami_name" {}

source "amazon-ebs" "jet" {
  region          = var.region
  instance_type   = var.instance_type
  
  source_ami_filter {
    filters = {
      name = "Windows_Server-2025-English-Full-Base-*"
    }
    most_recent = true
    owners = ["amazon"]
  }
  
  ami_name         = var.ami_name
  winrm_username   = var.winrm_username
  winrm_password   = var.winrm_password
  winrm_port       = 5985
  winrm_use_ssl    = false
  winrm_insecure   = true
  winrm_timeout    = "30m"
  communicator     = "winrm"
  
  user_data = <<EOF
<powershell>
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

net user Administrator ${var.winrm_password} /active:yes
</powershell>
EOF

  tags = {
    Name = "jet-dc"
    Type = "Packer Build"
  }
}

build {
  sources = ["source.amazon-ebs.jet"]

  provisioner "powershell" {
    scripts = ["scripts/german-locale.ps1"]
    pause_before = "30s"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }
}
