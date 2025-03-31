output "server_public_ips" {
  value = aws_instance.servers[*].public_ip
}
