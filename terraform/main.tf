terraform {
  backend "s3" {
    bucket = "ammar-bucket"
    key = "state/main.tf.tfstate"
    region = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "ammar_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Ammar's VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.ammar_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Ammar's Subnnet"
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.ammar_vpc.id
  tags = {
    Name = "Ammar's Gateway"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ammar_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }
  tags = {
    Name = "Ammar's route table"
  }
}
resource "aws_route_table_association" "public_rt_ass" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.ammar_vpc.id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "deployer" {
  key_name   = "d-key"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAj9haz0gam7LOwnFc0DLfOtKQahRRNfIQprnS0QymOWFivEHnbxQxNJL59xAIXEvX2o6nmDMDvwzk4HyxIB9jsl+lUTUgj119StqGdCXmnTR0pJTErv+UP04xsIMOv64hRVdx5XNc+bp+B3XEjjsng37CJb2QDvp9vRHdkIJgGEhHg1bZVhuRyZRrd1IYvOH8Q8Ew8jNrLpT9QNFY5CbayyhNLaxJkF7p8RhdZ6KBM9QiD5bhKygmoQ74IMePuGueNga5+AM2NOw4MHn1LVEtBpAdCZ2hkw8jg7izYvwxJA5D7rljgtJdHwUyST/jHsSN99TG5PugKXqIRX+3EOptBQIDAQAB"
}

resource "aws_instance" "foo" {
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  ami                         = "ami-005e54dee72cc1d00" # us-west-2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  tags = {
    Name = "AMMAR EC2"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}
output "public_ip" {
  value=aws_instance.foo.public_ip
}
