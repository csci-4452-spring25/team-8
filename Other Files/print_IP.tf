provider "aws" {
  region = "us-west-2"
}

# setting up the ami id for the instance
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  tags = {
    Name = "PrintIPTest"
  }
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
