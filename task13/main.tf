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
      }
    ]
  ])
}

resource "aws_subnet" "task13_subnets" {
  for_each          = { for subnet_index, subnet_info in local.subnets_def : subnet_index => subnet_info }
  vpc_id            = aws_vpc.task13_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.key)
  availability_zone = data.aws_availability_zones.available.names[each.key % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = each.value.is_public
  tags = { Name = each.value.name }
}

resource "aws_route_table_association" "task13_rt_assoc" {
  for_each       = { for subnet_index, subnet_info in local.subnets_def : subnet_index => subnet_info if subnet_info.is_public }
  subnet_id      = aws_subnet.task13_subnets[each.key].id
  route_table_id = aws_route_table.task13_public_rt.id
}

locals {
  lb_subnet_ids = [for subnet_index, subnet_info in local.subnets_def : aws_subnet.task13_subnets[subnet_index].id if subnet_info.is_public]
}

resource "aws_lb" "task13_loadbalancer" {
  name               = "task13-loadbalancer"
  load_balancer_type = "application"
  subnets            = local.lb_subnet_ids
  security_groups    = []
  tags               = { Name = "task13-loadbalancer" }
}

