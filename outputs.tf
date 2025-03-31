output "vpc_id" {
  value = aws_vpc.task13_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "app_subnets" {
  value = aws_subnet.app[*].id
}

output "db_subnets" {
  value = aws_subnet.db[*].id
}

output "load_balancer_dns" {
  value = aws_lb.task13_lb.dns_name
}

