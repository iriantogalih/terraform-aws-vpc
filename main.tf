
provider "aws" {
  version = "~> 5.0"
  region     = "ap-southeast-1"  
} 

resource "aws_default_vpc" "project1_VPC" {  

  cidr_block = "12.0.0.0/16"

  tags = {
    Name = "main_VPC"
  }
}


