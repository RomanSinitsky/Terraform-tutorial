terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  server_name = "test"
  ami =  "ami-08982f1c5bf93d976"
  instance_type = var.instance_type
}

variable "instance_type" {
  type = string
  description = "The size of the instance"
  sensitive = true
  validation {
  condition     = can(regex("^t2\\..*", var.instance_type))
  error_message = "The vm instance should be within t2 range"
  }
}

resource "aws_instance" "my_server" {
  ami           = local.ami
  instance_type = local.instance_type

  tags = {
    Name = "Server-${local.server_name}"
  }
}

output "instance_ip_addr" {
  value       = aws_instance.my_server.public_ip
  description = "The private IP address of the main server instance."
}
