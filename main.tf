terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "first_ec2_instance" {
  ami           = "ami-00385a401487aefa4"
  instance_type = "t2.micro"
  tags = {
    Name = "My first ec2 instance"
  }
}
