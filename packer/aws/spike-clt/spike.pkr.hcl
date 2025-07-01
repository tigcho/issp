variable "instance_type" {}
variable "region" {}
variable "winrm_username" {}
variable "winrm_password" {}
variable "ami_name" {}

source "amazon-ebs" "spike" {
  region          = var.region
  instance_type   = var.instance_type

  source_ami_filter {
    filters = {
      name = "Windows-11-Enterprise-*"
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
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory "Private"
New-NetFirewallRule -DisplayName 'WinRM (HTTP-In)' -Name 'WinRM (HTTP-In)' -Profile Any -LocalPort 5985 -Protocol TCP
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh firewall add portopening TCP 5985 "Port 5985"
net stop winrm
sc config winrm start= auto
net start winrm
net user Administrator ${var.winrm_password} /active:yes
</powershell>
EOF

  tags = {
    Name = "spike-client"
    Type = "Packer Build"
  }
}

build {
  sources = ["source.amazon-ebs.spike"]

  provisioner "powershell" {
    scripts = ["scripts/german-locale.ps1"]
    pause_before = "30s"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
  }
}
