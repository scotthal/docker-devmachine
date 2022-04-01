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

