
provider "aws" {
  region     = "ap-southeast-1"  
} 

# 
    Create local for map port in ec2 security group
# 

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
  },
  {
    port = 3389
    description = "Ingress rule for port 3389"
  }
  
  
  ]
}

# 
    Create VPC
# 
resource "aws_vpc" "project1_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "project1_VPC"
  }
}

# 
    Create subnet private and public
# 

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

# 
    Create Internet Gateway
# 

resource "aws_internet_gateway" "project1_gw" {
  vpc_id = "${aws_vpc.project1_VPC.id}"

  tags = {
    Name = "main igw"
  }
}

# 
    Create elasticIP for nat gateweay
# 
resource "aws_eip" "nat_gw" {
  depends_on = [aws_internet_gateway.project1_gw]
  
}

resource "aws_nat_gateway" "project1_ngw" {
  subnet_id = "${aws_subnet.project1_publicsubnet.id}"  
  allocation_id = aws_eip.nat_gw.id

  tags = {
    Name = "main  nat_gw"
  }
}

# 
    Create route table for connectiong subnet with local server and IGW and NAT GW
# 

resource "aws_route_table" "project1_private_RT" {
  vpc_id     = "${aws_vpc.project1_VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.project1_ngw.id}"
  }

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


# 
    Create EC2 instance_count
# 

resource "aws_instance" "ec2_public_example" {
    
    ami = var.ami_windows  
    instance_type = "t2.medium"
    key_name = "aws-demo-key"    
    vpc_security_group_ids = [aws_security_group.public_sg.id]    
    subnet_id = aws_subnet.project1_publicsubnet.id     
    associate_public_ip_address = var.enable_public
    //iam_instance_profile = var.iam_instance_profile
     iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
    

    tags = {
      Name = "Public EC2"
    } 
}

resource "aws_instance" "ec2_private_example" {
    
    ami = var.ami_linux
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

# 
    Create Security Group
# 

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
    cidr_blocks = ["10.0.2.0/24"]
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

# 
    setting resources for crate aws key pair and download it in local directory
# 

resource "aws_key_pair" "project1_key" {
  key_name   = "aws-demo-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "aws-demo-key.pem"
}
