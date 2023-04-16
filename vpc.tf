# Define variables for the CIDRs
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  default = "10.0.2.0/24"
}

variable "private_subnet_cidr_1" {
  default = "10.0.10.0/24"
}

variable "private_subnet_cidr_2" {
  default = "10.0.20.0/24"
}
# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true 
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "TerraformVPC"
  }
}
# Create the internet gateway and attach it to the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
   tags = {
    Name = "TerraformIGW"
  }
}
# Define the public subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr_1
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}
# Define the public subnets-2
resource "aws_subnet" "public-subnet-2" {
  cidr_block = var.public_subnet_cidr_2
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet-2"
  }
}
# Create the private subnets
resource "aws_subnet" "private-subnet-1" {
  cidr_block = var.private_subnet_cidr_1
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}
# Create the private subnets-2
resource "aws_subnet" "private-subnet-2" {
  cidr_block = var.private_subnet_cidr_2
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}
# Create an Elastic IP for the NAT gateway
resource "aws_eip" "my_eip" {
  vpc = true
  tags = {
    Name = "my_eip"
  }
}
# Create the NAT gateway in the public subnet of AZ-a
resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "my_nat"
  }
}
# Create the route tables for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
resource "aws_route_table_association" "public_rt_subnet_association_1" {
  subnet_id        = aws_subnet.public-subnet-1.id
  route_table_id   = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_subnet_association_2" {
  subnet_id        = aws_subnet.public-subnet-2.id
  route_table_id   = aws_route_table.public_rt.id
}
# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion-sg-"
  description = "Bastion Host Security Group"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Private Instances Security Group
resource "aws_security_group" "private_instances_sg" {
  name_prefix = "private-instances-sg-"
  description = "Private Instances Security Group"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Public Web Security Group
resource "aws_security_group" "public_web_sg" {
  name_prefix = "public-web-sg-"
  description = "Public Web Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Get self-IP
data "http" "self_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Define variables
variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

# Set output
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "private_instances_sg_id" {
  value = aws_security_group.private_instances_sg.id
}

output "public_web_sg_id" {
  value = aws_security_group.public_web_sg.id
}