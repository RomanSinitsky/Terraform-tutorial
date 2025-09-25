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

module "aws_server" {
  source        = "./inner"
  instance_type = var.instance_type
}

output "public_ip" {
  value = module.aws_server.instance_ip_addr
  sensitive = false
}

variable "instance_type" {
    type = string
}
