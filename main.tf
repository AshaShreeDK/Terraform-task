data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "subnet_1a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["eu-north-1a"]
  }
}

resource "aws_instance" "task11_server1a" {
  ami                         = var.aws_ami_id
  instance_type               = var.aws_instance_type
  subnet_id                   = data.aws_subnet.subnet_1a.id
  associate_public_ip_address = true

  tags = {
    Name = var.server_name
  }
}

