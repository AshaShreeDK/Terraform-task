variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_types" {
  type = list(string)
}

variable "subnet_count" {
  type = number
}

