output "vpc_id" {
  value = aws_vpc.task13_vpc.id
}

output "subnet_ids" {
  value = [for subnet in aws_subnet.task13_subnets : subnet.id]
}

output "load_balancer_arn" {
  value = aws_lb.task13_loadbalancer.arn
}

