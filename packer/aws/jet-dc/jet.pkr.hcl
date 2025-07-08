variable "instance_type" {}
variable "region" {}
variable "winrm_username" {}
variable "winrm_password" {}
variable "ami_name" {}
variable "source_ami" {}

source "amazon-ebs" "jet" {
  region        = var.region
  instance_type = var.instance_type
  
  source_ami = var.source_ami
  
  ami_name                    = var.ami_name
  associate_public_ip_address = true
  
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_port     = 5985
  winrm_use_ssl  = false
  winrm_insecure = true
  winrm_timeout  = "30m"
  
  user_data = <<EOF
<powershell>
Write-Output "Starting WinRM configuration..."
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

net user Administrator "${var.winrm_password}" /active:yes

rename-computer -newname "JET-DC" -force
set-timezone -Id "W. Europe Standard Time"
Write-Output "WinRM configuration complete"
</powershell>
EOF

  tags = {
    Name        = "jet-dc"
    Type        = "Packer Build"
  }
}

build {
  sources = ["source.amazon-ebs.jet"]
}
