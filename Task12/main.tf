data "aws_vpc" "myvpc" {
  default = true
}

data "aws_availability_zones" "az_zones" {}

data "aws_subnet" "selected" {
  count = 3

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }

  filter {
    name   = "availability-zone"
    values = [element(data.aws_availability_zones.az_zones.names, count.index)]
  }
}

resource "aws_instance" "servers" {
  count                       = 3
  ami                         = var.aws_ami_id
  instance_type               = var.aws_instance_type
  subnet_id                   = data.aws_subnet.selected[count.index].id
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
          Name = "task12-server1${substr(element(data.aws_availability_zones.az_zones.names, count.index), -1, 1)}"
  }
}

