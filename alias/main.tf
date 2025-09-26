terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  server_name = "test"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

data "aws_ami" "east-amazon-linux-2" {
  most_recent = true
  owners = [
    "amazon"
  ]
  provider = aws.east

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "west-amazon-linux-2" {
  most_recent = true
  owners = [
    "amazon"
  ]
  provider = aws.west

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "east" {
  ami           = data.aws_ami.east-amazon-linux-2.id
  provider      = aws.east
  instance_type = var.instance_type

  tags = {
    name = "Server-East"
  }
}

resource "aws_instance" "west" {
  ami           = data.aws_ami.west-amazon-linux-2.id
  provider      = aws.west
  instance_type = var.instance_type

  tags = {
    name = "Server-West"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "us-west-1"
  alias  = "west"
}

output "east_ip_addr" {
  value       = aws_instance.east.public_ip
  description = "The private IP address of the main server instance."
}

output "west_ip_addr" {
  value       = aws_instance.west.public_ip
  description = "The private IP address of the backup server instance."
}
