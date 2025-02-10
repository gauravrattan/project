# terraform.tfvars

# AWS Region
region = "ap-southeast-1"  # Set the desired AWS region

# VPC CIDR block
vpc_cidr = "10.1.0.0/16"

# Enable DNS support and DNS hostnames
enable_dns_support   = true
enable_dns_hostnames = true

# Organization prefix for resource names
organization_prefix = "myorg"

# List of CIDR blocks for public subnets
public_subnets = [
  "10.1.1.0/24",  # Example public subnet 1
  "10.1.2.0/24"  # Example public subnet 2
]

# List of CIDR blocks for app private subnets
app_subnets = [
  "10.1.4.0/24",  # Example app subnet 1
  "10.1.5.0/24"  # Example app subnet 2
  
]

# List of CIDR blocks for DB private subnets
db_subnets = [
  "10.1.7.0/24",  # Example DB subnet 1
  "10.1.8.0/24"  # Example DB subnet 2
  
]

# Boolean flag to create a NAT Gateway (set to true to create a NAT Gateway)
create_nat_gateway = true

