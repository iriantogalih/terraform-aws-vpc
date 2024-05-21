
provider "aws" {
  region     = "ap-southeast-1"  
} 

resource "aws_vpc" "project1_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "project1_VPC"
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

resource "aws_route_table" "project1_private_RT" {
  vpc_id     = "${aws_vpc.project1_VPC.id}"

  tags = {
    Name = "private route table"
  }
}

resource "aws_route_table" "project1_public_RT" {
  vpc_id     = "${aws_vpc.project1_VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.project1_gw.id}"    
  }

  

  tags = {
    Name = "public route table"
  }
}

resource "aws_route_table_association" "project1_private_RT_association" {
  subnet_id      = "${aws_subnet.project1_privatesubnet.id}"
  route_table_id = "${aws_route_table.project1_private_RT.id}"
}

resource "aws_route_table_association" "project1_public_RT_association" {
  subnet_id      = "${aws_subnet.project1_publicsubnet.id}"
  route_table_id = "${aws_route_table.project1_public_RT.id}"
}