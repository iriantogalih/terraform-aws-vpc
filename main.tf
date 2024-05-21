
provider "aws" {
  region     = "ap-southeast-1"  
} 

resource "aws_vpc" "project1_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_VPC"
  }
}


