vpc_cidr = "10.10.0.0/16"

subnet_cidrs = {
    application  = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
    database     = ["10.10.20.0/26", "10.10.20.64/26", "10.10.20.128/26"]
    loadbalancer = ["10.10.30.0/27", "10.10.30.32/27", "10.10.30.64/27"]
}

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

