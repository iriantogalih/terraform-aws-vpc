provider "aws" {
  region     = "ap-southeast-1"  
} 

resource "aws_default_vpc" "default" {
  tags = {
    Name = "main_VPC"
  }
}

