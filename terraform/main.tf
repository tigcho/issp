variable "region" {}
variable "instance_type" {}
variable "jet_dc_ami" {}
variable "ed_atk_ami" {}
variable "trusted_ips" {
  sensitive = true
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "issp_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "ISSP-VPC"
  }
}

resource "aws_subnet" "issp_subnet" {
  vpc_id = aws_vpc.issp_vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "ISSP-Subnet"
  }
}

resource "aws_security_group" "internal_sg" {
  name = "internal-sg"
  vpc_id = aws_vpc.issp_vpc.id

  ingress {
    from_port = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["192.168.1.0/24"] 
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.trusted_ips
  }

  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = var.trusted_ips
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }

  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }
}

resource "aws_instance" "jet_dc" {
  ami = var.jet_dc_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.issp_subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  private_ip = "192.168.1.10"
  associate_public_ip_address = true

  tags = {
    Name = "Jet-DC"
  }
}

resource "aws_instance" "ed_atk" {
  ami = var.ed_atk_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.issp_subnet.id
  vpc_security_group_ids = [aws_security_group.internal_sg.id]
  private_ip = "192.168.1.100"
  associate_public_ip_address = true

  tags = {
    Name = "ED-ATK"
  }
}

output "jet_dc_public_ip" {
  value = aws_instance.jet_dc.public_ip
}

output "ed_atk_public_ip" {
  value = aws_instance.ed_atk.public_ip
}
