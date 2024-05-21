
provider "aws" {
  region     = "ap-southeast-1"  
} 

locals {
  ingress_rule = [{
    port = 80
    description = "Ingress rule for port 80"
  },
  {
    port = 22
    description = "Ingress rule for port 22"
  },
  {
    port = 433
    description = "Ingress rule for port 433"
  }]
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

resource "aws_instance" "ec2_public_example" {
    
    ami = "ami-003c463c8207b4dfa"  
    instance_type = var.instance_type
    key_name = "aws-demo-key"
    vpc_security_group_ids = [aws_security_group.public_sg.id]
    subnet_id = aws_subnet.project1_publicsubnet.id     
    associate_public_ip_address = var.enable_public

    tags = {
      Name = "Public EC2"
    } 
}

resource "aws_instance" "ec2_private_example" {
    
    ami = "ami-003c463c8207b4dfa"  
    instance_type = var.instance_type
    key_name = "aws-demo-key"
    vpc_security_group_ids = [aws_security_group.private_SG.id]
    subnet_id = aws_subnet.project1_privatesubnet.id 
    //count = var.instance_count
    associate_public_ip_address = false

    tags = {
      Name = "private EC2"
    } 
}

resource "aws_security_group" "public_sg" {
   name        = "allow_tls"
   description = "Allow TLS inbound traffic and all outbound traffic"
   vpc_id      = aws_vpc.project1_VPC.id

   dynamic "ingress" {
      for_each = local.ingress_rule

      content {
        description = ingress.value.description
        from_port   = ingress.value.port
        to_port     = ingress.value.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
     Name = " Public Security Group"
   }
}

resource "aws_security_group" "private_SG" {
   name        = "private SG"   
   vpc_id      = aws_vpc.project1_VPC.id

   ingress {
  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"   
    cidr_blocks =["0.0.0.0/0"]
  }

   tags = {
     Name = " Private Security Group"
   }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws-demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmSKz+QIYx1eHJYBbb6/KIr015ebJPyhxV5FDVxMSBt0T6rEWTg6b7hBygUwyeDHDkPN7CA6bJXBJnPW0uwqLSn2Bb7RVHHG+F5muI0HUCgrDWDe10OeHiwCW0icbgBrnlWm6xY/yJElLmNC0fJGYi2I2I7ag56rnREtvHKKY7GpV2IuaF33BVXhQO1O8fE6ty9J9gtrvOs8iYvw2j9Ks0cwQ3wMUf//b1HgPtmy5tn1seXaxagiA62/J5K85PfgZjR32BtSuLg/0gxBAdENhPbPhanBuX5Jt9mJTLM4vbqsMK34GeXGUwsrEqXE3GsAXThVK+Hqiw+hlRxv8xB1Xv galih@galihisaputro"
}