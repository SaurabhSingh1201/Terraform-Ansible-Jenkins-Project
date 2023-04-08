data "aws_ami" "ubuntu3" {
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

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu3.id
  instance_type = "t2.micro"
  key_name      = "assignment-c7key"
  vpc_security_group_ids = [aws_security_group.ingress-all.id]
  subnet_id = module.vpc.private_subnets[0]
 tags = {
    Name = "JenkinsEC2"
  }
}
