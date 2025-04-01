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

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidrs" {
  type = map(list(string))
}

variable "availability_zones" {
  type = list(string)
}

variable "subnet_types" {
  type    = list(string)
}


