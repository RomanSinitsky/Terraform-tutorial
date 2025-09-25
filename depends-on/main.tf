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

resource "aws_instance" "my_server" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = var.instance_type

  tags = {
    name = "Server-${local.server_name}"
  }
}

resource "aws_s3_bucket" "my-bucket" {
  bucket   = "38530938jfe-bucket"
  provider = aws.us

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

  depends_on = [
    aws_instance.my_server
  ]

}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
}

output "instance_ip_addr" {
  value       = aws_instance.my_server.public_ip
  description = "The private IP address of the main server instance."
}
