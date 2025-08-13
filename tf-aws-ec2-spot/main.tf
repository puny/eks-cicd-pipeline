# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
  required_version = "~>1.12.0"
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "random_pet" "sg" {}

data "aws_vpc" "cleanlab" {
  id = "vpc-076f592a8b697e873" # Replace with your VPC ID
}


data "aws_subnet" "public1" {
  id = "subnet-0de9fe753d14600b0" # Replace with your public subnet ID
}

data "aws_subnet" "public2" {
  id = "subnet-0943671ecd42cc95d" # Replace with your public subnet ID
}

data "aws_security_group" "new-ec2-sg" {
  id = "sg-0a5517d3e0e4cad9b"
  name   = "new-ec2-sg"
  vpc_id = data.aws_vpc.cleanlab.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-08943a151bd468f4e"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # owners = ["533267419021"] # Canonical
}


resource "aws_instance" "web" {
  subnet_id            = data.aws_subnet.public1.id
  associate_public_ip_address = true
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3a.small"
  
  key_name               = "new-ec2-key"
  vpc_security_group_ids = [data.aws_security_group.new-ec2-sg.id]
  tags = {
    Name        = "spot-web-server"
    Environment = "dev"
    Terraform   = "true"
  }

  # spot instance configuration
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price                   = "0.0092" # Set your desired max price here
      spot_instance_type          = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2

              # Install and start the SSM agent
              # This is necessary for SSM to manage the instance
              snap install amazon-ssm-agent --classic
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}