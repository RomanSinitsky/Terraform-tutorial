terraform {
  cloud { 
    hostname = "app.terraform.io"
    organization = "RS-personal" 

    workspaces {
      name = "getting-started" 
    }
  }

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
  type = string
}

resource "aws_instance" "my_server" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = var.instance_type

  tags = {
    Name = "Server-${local.server_name}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.eu
    }

  name = "europe-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}