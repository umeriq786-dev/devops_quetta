terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}


# Security Group
resource "aws_security_group" "web_sg" {
  name        = "ubuntu-web-sg"
  description = "Allow SSH and HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ubuntu-web-sg"
  }
}

# EC2 Instance
resource "aws_instance" "ubuntu_server" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"

  key_name = "corvit_quetta"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "ubuntu-24-server"
    Environment = "dev"
  }
}

output "public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}
