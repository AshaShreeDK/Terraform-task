data "aws_availability_zones" "available" {}

resource "aws_vpc" "task13_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "task13-vpc" }
}

resource "aws_internet_gateway" "task13_igw" {
  vpc_id = aws_vpc.task13_vpc.id
  tags   = { Name = "task13-igw" }
}

resource "aws_route_table" "task13_public_rt" {
  vpc_id = aws_vpc.task13_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task13_igw.id
  }
  tags = { Name = "task13-public-rt" }
}

locals {
  subnets_def = flatten([
    for subnet_type in var.subnet_types : [
      for subnet_index in range(var.subnet_count) : {
        name      = format("task13-subnets-%s-%d", subnet_type, subnet_index + 1)
        type      = subnet_type
        is_public = subnet_type == "loadbalancer" ? true : false
        cidr      = var.subnet_cidrs[subnet_type][subnet_index]
      }
    ]
  ])
}

resource "aws_subnet" "task13_subnets" {
  for_each = { for subnet_index, subnet_info in local.subnets_def : subnet_index => subnet_info }

  vpc_id            = aws_vpc.task13_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = data.aws_availability_zones.available.names[each.key % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = each.value.is_public

  tags = {
    Name         = each.value.name
    subnet_type  = each.value.type
  }
}

resource "aws_route_table_association" "task13_rt_assoc" {
  for_each       = { for subnet_index, subnet_info in local.subnets_def : subnet_index => subnet_info if subnet_info.is_public }
  subnet_id      = aws_subnet.task13_subnets[each.key].id
  route_table_id = aws_route_table.task13_public_rt.id
}

resource "aws_security_group" "task13_lb_sg" {
  name        = "task13-loadbalancer-sg"
  description = "SG for task13 loadbalancer"
  vpc_id      = aws_vpc.task13_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_lb" "task13_loadbalancer" {
  name               = "task13-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.task13_lb_sg.id]
  subnets            = [for subnet in aws_subnet.task13_subnets : subnet.id if lookup(subnet.tags, "subnet_type", "") == "loadbalancer"]
  enable_deletion_protection = false
  depends_on         = [aws_security_group.task13_lb_sg]
}
