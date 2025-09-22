terraform { 
  /* cloud { 
    hostname = "app.terraform.io"
    organization = "RS-personal" 

    workspaces { 
      name = "provisioners" 
    } 
  } */
  backend "local" {
    path = "terraform.tfstate"
  } 
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_instance" "my_server" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id, ]
  user_data = data.template_file.user_data.rendered
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("/home/roman/.ssh/terraform-provisioners.rsa")}"
      host = self.public_ip
    }
  }
  provisioner "file" {
  content     = "ami used: ${self.id}"
  destination = "/home/ec2-user/instance_ids.txt"

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("/home/roman/.ssh/terraform-provisioners.rsa")}"
      host = self.public_ip
    }
}

  tags = {
    Name = "MyServer"
  }
}

resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.my_server.id}" 
  }
  depends_on = [ aws_instance.my_server ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDejJCTBs/Zm3igNKoqFq9l7+qTCCUcAAf9UphPC63EF0311xVcCZdyrMPDN301ZN6HwgDeMjb1ja8Q7u6m4bJs0GCuxd4D70iGjhczlIJHIDoX3UOQR+Fpe6KRdXnZoPw/6dspq1sRfbGgnpYX5g5RvA6p7M1zX0hk0O+1Tp0zgzdjQVY3aJx8lNwvURzwP91HekS4l5qhnMR9jpziulCyftL5FYRbbUltD+0//u/7JXwXClblw4B1MjYLx+NmGAYvS5JVSU8pm3BD4ozuuhs/qTyRrTdnzmmSxV5rP826rsMUmuVUVGmaXGdyEnA4pIoJWAWpLkPjkMTIrMcwpOwx7fsFBBLW4vrxUU0ubMJ1jKk9j+tTqBp+xTEyvofFHNZf6ifGxm56SHNKqVfKyBKMNPj9XEAmF9I49c9gCL+ij2ZeoLAe8lflhTf5kydCZ0z3RK09jqbE7yDYPeE/YRFrC/1iN+Bpe2QRJp6ZNh2MFE/Fi0nk3oYiweHWAiLtCG0= roman@roman-System-Product-Name"
}

output "public_ip" {
    value = aws_instance.my_server.public_ip
}

data "external" "myipv4" {
  program = ["bash", "-c", "echo '{\"ip\": \"'$(curl -s -4 ifconfig.me)'\"}'"]
}

data "aws_vpc" "main" {
    id = "vpc-0854cc7923906c7b5"
}

data "template_file" "user_data" {
    template = file("./userdata.yaml")
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer security group"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "${chomp(data.external.myipv4.result.ip)}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
