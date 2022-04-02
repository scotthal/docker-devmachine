terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {}

resource "aws_vpc" "dev" {
  cidr_block = "10.101.0.0/16"
}

resource "aws_subnet" "dev" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "10.101.0.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_internet_gateway" "dev" {}

resource "aws_internet_gateway_attachment" "dev" {
  vpc_id              = aws_vpc.dev.id
  internet_gateway_id = aws_internet_gateway.dev.id
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id
}

resource "aws_route" "dev_default_route" {
  route_table_id         = aws_route_table.dev.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev.id
}

resource "aws_route_table_association" "dev_subnet_association" {
  route_table_id = aws_route_table.dev.id
  subnet_id      = aws_subnet.dev.id
}

resource "aws_security_group" "dev" {
  name        = "allow_dev_traffic"
  description = "Allow traffic on common development ports"
  vpc_id      = aws_vpc.dev.id
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dev_http"
    from_port   = 8000
    to_port     = 8999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev" {
  key_name   = "dev-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_launch_configuration" "dev" {
  name                        = "dev"
  image_id                    = "ami-005775ff06aa22974"
  instance_type               = "m5a.large"
  spot_price                  = "0.05"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.dev.id]
  key_name                    = aws_key_pair.dev.key_name
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }
}

resource "aws_autoscaling_group" "dev" {
  name                 = "dev-asg"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.dev.id
  vpc_zone_identifier  = [aws_subnet.dev.id]
}