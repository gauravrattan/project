# variables.tf

# VPC CIDR block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# Enable or disable DNS support in the VPC
variable "enable_dns_support" {
  description = "Enable or disable DNS support in the VPC"
  type        = bool
  default     = true
}

# Enable or disable DNS hostnames in the VPC
variable "enable_dns_hostnames" {
  description = "Enable or disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

# Organization prefix used for resource names
variable "organization_prefix" {
  description = "Prefix for naming resources in the organization"
  type        = string
}

# List of CIDR blocks for public subnets
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

# List of CIDR blocks for app private subnets
variable "app_subnets" {
  description = "List of CIDR blocks for app private subnets"
  type        = list(string)
  default     = []
}

# List of CIDR blocks for DB private subnets
variable "db_subnets" {
  description = "List of CIDR blocks for DB private subnets"
  type        = list(string)
  default     = []
}

# Boolean to determine whether to create a NAT gateway
variable "create_nat_gateway" {
  description = "Boolean to create a NAT gateway"
  type        = bool
  default     = false
}
