#Create a public key 
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}
#Create a private key to store in machine 
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}
#Create a local file 
resource "local_file" "TF-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}
resource "aws_security_group" "bastion" {
  name_prefix = "bastion"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
}

resource "aws_security_group" "ssh" {
  name_prefix = "ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
}
#Baston and private subnet defined for ec2
resource "aws_subnet" "bastion" {
  cidr_block = "10.0.3.0/24"
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name = "bastion-subnet"
  }
}

resource "aws_subnet" "private" {
  cidr_block = "10.0.4.0/24"
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name = "private-subnet"
  }
}

#ec2 instance 
resource "aws_instance" "bastion" {
  ami           = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.bastion.id
  key_name      = aws_key_pair.TF_key.id
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.ssh.id,
  ]
  tags = {
    Name = "bastion-server"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.TF_key.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
  ]
  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0aa2b7722dc1b5612"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = aws_key_pair.TF_key.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
  ]
  tags = {
    Name = "app-server"
  }
}