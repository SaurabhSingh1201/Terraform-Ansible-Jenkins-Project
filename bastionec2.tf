data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "assignment-c7key"
  vpc_security_group_ids = [aws_security_group.ingress-all-test.id]
  subnet_id = module.vpc.public_subnets[0]
 tags = {
    Name = "Bastion"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  vpc      = true
}
