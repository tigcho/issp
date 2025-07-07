variable "region" {}
variable "instance_type" {}
variable "trusted_ips" {
  sensitive = true
}

provider "aws" {
  region = var.region
}

data "aws_ami" "jet_dc_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["JET-DC-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "jet_dc_sg" {
  name_prefix = "jet-dc-sg-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JET-DC-SecurityGroup"
  }
}

resource "aws_eip" "jet_dc_static_ip" {
  domain = "vpc"
  
  tags = {
    Name = "JET-DC-Static-IP"
  }
}

resource "aws_instance" "jet_dc" {
  ami                    = data.aws_ami.jet_dc_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.jet_dc_sg.id]

  tags = {
    Name = "JET-DC"
  }
}

resource "aws_eip_association" "jet_dc_static_ip_assoc" {
  instance_id   = aws_instance.jet_dc.id
  allocation_id = aws_eip.jet_dc_static_ip.id
}
