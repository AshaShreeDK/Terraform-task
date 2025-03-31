resource "aws_vpc" "task13_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "task13-vpc"
  }
}

data "aws_availability_zones" "az_zones" {}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.task13_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = element(data.aws_availability_zones.az_zones.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "task13-subnet-public-${substr(element(data.aws_availability_zones.az_zones.names, count.index), -1, 1)}"
  }
}

resource "aws_subnet" "app" {
  count             = 3
  vpc_id            = aws_vpc.task13_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 3)
  availability_zone = element(data.aws_availability_zones.az_zones.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "task13-subnet-app-${substr(element(data.aws_availability_zones.az_zones.names, count.index), -1, 1)}"
  }
}

resource "aws_subnet" "db" {
  count             = 3
  vpc_id            = aws_vpc.task13_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 6)
  availability_zone = element(data.aws_availability_zones.az_zones.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "task13-subnet-db-${substr(element(data.aws_availability_zones.az_zones.names, count.index), -1, 1)}"
  }
}

resource "aws_lb" "task13_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = var.lb_name
  }
}

