
provider "aws" {
  region     = "ap-southeast-1"  
} 

resource "aws_vpc" "project1_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_VPC"
  }
}

resource "aws_subnet" "project1_privatesubnet" {
  vpc_id     = "${aws_vpc.project1_VPC.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_subnet" "project1_publicsubnet" {
  vpc_id     = "${aws_vpc.project1_VPC.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "project1_gw" {
  vpc_id = "${aws_vpc.project1_VPC.id}"

  tags = {
    Name = "main igw"
  }
}


