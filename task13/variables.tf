variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_ami_id" {
  type = string
}

variable "aws_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "lb_name" {
  type    = string
  default = "task13-loadbalancer"
}
