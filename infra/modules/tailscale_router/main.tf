terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "router" {
  name        = "${var.name}-tailscale-router-sg"
  description = "Tailscale subnet router"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH (optional)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

locals {
  user_data = templatefile("${path.module}/userdata.sh", {
    tailnet             = var.tailnet
    oauth_client_id     = var.oauth_client_id
    oauth_client_secret = var.oauth_client_secret
    routes              = join(",", var.advertise_routes)
    hostname            = var.hostname
  })
}

resource "aws_instance" "router" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.router.id]
  associate_public_ip_address = true

  user_data = local.user_data

  tags = merge(var.tags, { Name = "${var.name}-tailscale-router" })
}

output "router_sg_id" { value = aws_security_group.router.id }
output "instance_id" { value = aws_instance.router.id }
output "public_ip" { value = aws_instance.router.public_ip }
